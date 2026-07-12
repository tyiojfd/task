# Functional Completeness Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the remaining training-project business flows: team applications, lifecycle restrictions, ended-competition work gallery, category/statistics correctness, and public competition browsing, while excluding deeper security hardening.

**Architecture:** Keep the current Servlet/JSP/MVC style. Add a small team-application vertical slice and strengthen lifecycle checks in existing services/controllers. Use the existing `competition.status` values (`0=取消`, `1=报名中`, `2=进行中`, `3=已结束`) without introducing a new state machine.

**Tech Stack:** Java 8, Servlet 4.0 (`javax.servlet`), JSP, JSTL, MySQL 8, Maven WAR.

## Global Constraints

- Do not create a new git branch.
- Do not commit unless the user explicitly asks.
- Skip security-only fixes such as CSRF, password hashing, secret management, and broad XSS cleanup.
- Focus on functional/business-completeness problems suitable for a training project.
- Preserve existing UI style and routes where possible.

---

## File Structure

- Create `src/main/java/com/poster/model/TeamApplication.java` for join applications.
- Create `src/main/java/com/poster/dao/TeamApplicationDAO.java` and `src/main/java/com/poster/dao/impl/TeamApplicationDAOImpl.java`.
- Create `src/main/java/com/poster/service/TeamApplicationService.java` and `src/main/java/com/poster/service/impl/TeamApplicationServiceImpl.java`.
- Create `src/main/java/com/poster/controller/TeamApplicationServlet.java`.
- Create `src/main/webapp/jsp/application_list.jsp` for applicant and leader review views.
- Modify `database/schema.sql` and create `database/migrations/V5__team_application.sql`.
- Modify `TeamServlet`, `TeamServiceImpl`, `InvitationServiceImpl`, `CompetitionServlet`, `CompetitionServiceImpl`, `AuthFilter`, `team_detail.jsp`, `competition_detail.jsp`, `team_create.jsp`, and shared navbar.

---

### Task 1: Team application data and service slice

**Files:**
- Create model, DAO, DAO impl, service, service impl, servlet, JSP, and migration SQL listed above.

**Interfaces:**
- Produces `TeamApplicationService.applyToTeam(Integer teamId, Integer applicantId, String message)`.
- Produces `TeamApplicationService.approveApplication(Integer applicationId, Integer leaderId)`.
- Produces `TeamApplicationService.rejectApplication(Integer applicationId, Integer leaderId)`.
- Produces `/application?action=myApplications`, `/application?action=teamApplications&teamId=ID`, POST `/application?action=apply|approve|reject|cancel`.

Steps:
- Add the `team_application` table to schema and migration.
- Implement model/DAO CRUD queries by applicant/team/status.
- Implement service validations: applicants must be participant accounts, not already in a team for the same competition, team must be status `1`, competition must be `1`, team not full, no duplicate pending application.
- Approval inserts `team_member` role `2` and marks application accepted.
- Rejection/cancellation updates status.
- Add application list JSP with tabs for my applications and team applications.

### Task 2: Integrate applications into competition/team pages

**Files:**
- Modify `CompetitionServlet`, `competition_detail.jsp`, `TeamServlet`, `team_detail.jsp`, navbar include.

**Interfaces:**
- Consumes `TeamApplicationService`.
- Produces `availableTeams` attribute on competition detail.
- Produces `pendingApplicationCount` attribute on team detail.

Steps:
- On competition detail, show teams in this competition that are `组建中` and not full, with “申请加入” buttons for eligible users.
- On team detail, show leader-only “入队申请” link/count.
- Navbar adds “入队申请” for participants.

### Task 3: Lifecycle restrictions for team operations

**Files:**
- Modify `TeamServiceImpl`, `InvitationServiceImpl`, `TeamServlet`.

Steps:
- Team creation allowed only for competition status `1` and category belonging to the competition.
- Team registration allowed only for status `1`, category belongs to competition, and all members still valid.
- Team update preserves status and forbids competition/category changes after registration.
- Invitation, acceptance, member removal, and member leave allowed only while team status is `1`.
- Cancel registration allowed only while competition status is `1` or before any works exist; submitted teams cannot cancel.

### Task 4: Competition detail completeness and public browsing

**Files:**
- Modify `AuthFilter`, `CompetitionServlet`, `competition_detail.jsp`, `competition_list.jsp` if needed.

Steps:
- Allow anonymous `GET /competition?action=list|detail`.
- Load and display categories on competition detail.
- Show “作品展厅” button when competition status is `3`.
- Make statistics count registered teams and submitted works only.
- Normalize blank filters and keep global statistics internally consistent.

### Task 5: Verification

**Files:**
- No new product files.

Steps:
- Run `./mvnw test`.
- Run `./mvnw package -DskipTests`.
- Inspect `git diff --stat`.
- Browser-check representative pages after redeploy if server refreshes changed classes/JSPs.
