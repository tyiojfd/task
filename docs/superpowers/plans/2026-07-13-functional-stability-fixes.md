# Functional Stability Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use inline execution with TDD. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make avatar files durable across Tomcat redeployments, make member applications visible and actionable for each team's `team.leader_id`, and prevent new users from being created without the participant role required by the current authorization filter. Do not infer or rewrite global roles because this project does not enforce a strict leader/member distinction.

**Architecture:** Keep the existing JSP + Servlet + DAO + Service structure. Introduce a small, testable `AvatarStorage` utility backed by `FileUploadUtil.getStorageBasePath()`, keep `/uploads/avatars/...` as the public URL, and preserve the existing `team_application` workflow. Strengthen service failure handling without changing routes or executing SQL from Java.

**Tech Stack:** Java 8 source/target, Servlet 4.0 (`javax.servlet`), JSP, MySQL 8, JUnit 5, Maven WAR.

---

## Files

- Create: `src/main/java/com/poster/util/AvatarStorage.java` — validates and stores avatars outside the deployed webapp, resolves public paths, and deletes old files safely.
- Create: `src/test/java/com/poster/util/AvatarStorageTest.java` — real temporary-directory tests for storage, URL mapping, validation, and cleanup.
- Create: `src/test/java/com/poster/service/impl/UserServiceImplTest.java` — fake DAO tests for default-role lookup/assignment failure behavior.
- Modify: `src/main/java/com/poster/controller/ProfileServlet.java` — use `AvatarStorage`, update the database only after the file is stored, and clean legacy/external files after a successful update.
- Modify: `src/main/java/com/poster/service/impl/UserServiceImpl.java` — add constructor injection for tests and fail registration when the default participant role is absent or cannot be assigned; delete the inserted user on role-assignment failure.
- Keep: `src/main/java/com/poster/dao/impl/TeamApplicationDAOImpl.java` — its existing SQL is correct after `team_application` exists; no schema or DAO rewrite is needed.
- Modify: `src/main/java/com/poster/service/impl/TeamApplicationServiceImpl.java` — add constructor injection for tests, validate null leader IDs, and ensure a failed application status update is reported as failure rather than success.
- Modify: `pom.xml` — configure Maven Surefire 3.2.5 so JUnit 5 tests run under the existing Java 21 environment while compiling for Java 8.
- No role-repair migration: `leader01` is intentionally a judge account, and existing global roles must not be rewritten automatically.

## Database contract

The user has already run the `team_application` migration. Before final verification, run a read-only check that confirms:

```sql
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'team_application';

SELECT u.username, GROUP_CONCAT(r.role_name ORDER BY r.role_id)
FROM user u
LEFT JOIN user_role ur ON ur.user_id = u.user_id
LEFT JOIN role r ON r.role_id = ur.role_id
WHERE u.username = 'member01'
GROUP BY u.user_id, u.username;
```

No production code will execute migration SQL or mutate the live database during tests.

### Task 1: Enable and write the failing storage tests

**Files:**
- Modify: `pom.xml`
- Create: `src/test/java/com/poster/util/AvatarStorageTest.java`

- [ ] Add Maven Surefire 3.2.5 under `<build><plugins>`.
- [ ] Write a test that constructs `AvatarStorage` with a temporary directory, saves a valid PNG stream, and asserts the returned public URL starts with `/uploads/avatars/` while the file exists below the temporary directory's `avatars` folder.
- [ ] Write a test that rejects a non-image MIME type, a non-image extension, and a file larger than 2MB.
- [ ] Write a test that deletes an old public avatar path without allowing `..` traversal outside the storage root.
- [ ] Run `.mvnw.cmd -q -Dtest=AvatarStorageTest test` and observe the expected compile failure because `AvatarStorage` does not exist.

### Task 2: Implement durable avatar storage

**Files:**
- Create: `src/main/java/com/poster/util/AvatarStorage.java`
- Modify: `src/main/java/com/poster/controller/ProfileServlet.java`

- [ ] Implement `AvatarStorage.save(InputStream input, String originalName, String contentType, long size)` with a random `avatar_<uuid>.<ext>` name, a storage directory under `<storage-root>/avatars`, MIME/extension/2MB validation, and `Files.copy`.
- [ ] Implement `publicPathFor(String fileName)` and `resolvePublicPath(String publicPath)` for `/uploads/avatars/<file>` only; reject absolute paths and traversal.
- [ ] Update `ProfileServlet` to read the `Part` stream through `AvatarStorage`, set the new DB path only after the file is written, and delete the old external/legacy file only after `userService.updateUser` succeeds.
- [ ] Keep the existing `/uploads/*` URL so `ImageServlet` can serve external storage first and legacy deployed files second.
- [ ] Run the focused storage tests and confirm they pass.

### Task 3: Enable and write the failing registration-role tests

**Files:**
- Create: `src/test/java/com/poster/service/impl/UserServiceImplTest.java`

- [ ] Add small in-memory fake implementations of `UserDAO`, `RoleDAO`, and `UserRoleDAO` that implement every interface method and record inserts, deletes, and role assignment calls.
- [ ] Write a test where `RoleDAO.findByName("队员")` returns `null`; assert `register(...)` returns `false` and deletes the inserted user.
- [ ] Write a test where `assignRole(...)` returns `false`; assert registration returns `false` and deletes the inserted user.
- [ ] Write a test for the normal path; assert registration returns `true` and assigns exactly the default role.
- [ ] Run `.mvnw.cmd -q -Dtest=UserServiceImplTest test` and observe the expected failure against current behavior.

### Task 4: Implement registration failure handling

**Files:**
- Modify: `src/main/java/com/poster/service/impl/UserServiceImpl.java`

- [ ] Add a constructor accepting `UserDAO`, `RoleDAO`, and `UserRoleDAO`; keep a no-argument constructor for Servlet usage.
- [ ] After inserting a user, require a non-null `队员` role and a successful `assignRole` call.
- [ ] If either check fails, call `userDAO.deleteById(userId)` and return `false`.
- [ ] Run the focused registration tests and confirm all pass.

### Task 5: Harden the application approval path

**Files:**
- Modify: `src/main/java/com/poster/service/impl/TeamApplicationServiceImpl.java`
- Modify: `src/main/java/com/poster/dao/impl/TeamApplicationDAOImpl.java`

- [ ] Add a constructor accepting the five DAO dependencies while preserving the no-argument constructor.
- [ ] Reject null `leaderId` before comparing it with `team.getLeaderId()`.
- [ ] Keep the existing status, team, competition, participant-role, duplicate-membership, and capacity checks.
- [ ] After inserting a member, update the application and return `false` if the status update affects zero rows; log enough context to diagnose the inconsistent state.
- [ ] In DAO catch blocks, log the operation name and IDs before returning the existing empty/zero result so a missing or incompatible schema is visible in Tomcat logs.
- [ ] Add service-level fake-DAO tests for leader authorization, duplicate pending application, and successful approval if the test seam remains small; otherwise verify these cases through the browser/database smoke test in Task 8.

### Task 6: Verify team ownership without rewriting global roles

**Files:**
- [x] Treat `team.leader_id`/`team_member.role=1` as the per-team ownership source.
- [x] Preserve the intentionally configured `leader01` judge role.
- [x] Verify the selected `member01` team leader through the browser and database read-only checks.

### Task 7: Build and static regression checks

**Files:**
- All files above.

- [ ] Run `.mvnw.cmd -q test` with `JAVA_HOME=C:\Program Files\Java\jdk-21`; expected result is all JUnit tests passing.
- [ ] Run `.mvnw.cmd -q -DskipTests package`; expected result is a WAR at `target/task-1.0-SNAPSHOT.war`.
- [ ] Check that compiled classes include `UserServiceImpl.class`, `ProfileServlet.class`, and `TeamApplicationServlet.class`.
- [ ] Check JSP source for duplicate top-level scriptlet declarations in `submission_add.jsp` and `profile.jsp`.
- [ ] Review `git diff --check` and preserve unrelated `CLAUDE.md`, `.claude/`, and diagnostic files.

### Task 8: Runtime and browser smoke verification

**Files:**
- No new product files.

- [ ] Stop the stale Tomcat deployment and deploy the freshly built `target/task-1.0-SNAPSHOT` directory; do not run a clean while Tomcat is using that directory.
- [ ] Request `/task_war_exploded/login`, `/register`, `/profile`, `/team?action=myTeams`, and `/application?action=myApplications`; verify expected 200/redirect behavior and no class-loading 404.
- [ ] Log in as a participant and submit a join application from a competition detail page.
- [ ] Log in as the repaired leader account, open `/application?action=teamApplications&teamId=<id>`, verify applicant/message, approve it, and verify a new `team_member` row.
- [ ] Upload a JPG/PNG avatar, refresh the profile page, request its `/uploads/avatars/...` URL, restart Tomcat, and request the same URL again.
- [ ] Inspect Tomcat access/error logs for unexpected 404/500 entries and record any remaining missing cover assets separately.

### Task 9: Code review and handoff

**Files:**
- All modified product files.

- [ ] Request a focused code review for avatar storage, role assignment failure handling, and application approval consistency.
- [ ] Fix all critical/important findings before handoff.
- [ ] Report exact source changes, the database migration file, verification commands, and the required Tomcat redeploy step.
