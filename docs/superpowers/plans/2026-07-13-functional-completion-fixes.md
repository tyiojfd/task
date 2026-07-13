# Functional Completion Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use inline execution with TDD. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复上次代码审查中除“配置与部署问题”以外的功能缺陷、安全边界和流程一致性问题，并补齐可在现有 JSP + Servlet 架构中直接使用的分享、奖状下载和附件关联能力。

**Architecture:** 保留现有 MVC 分层和路由，先在 Service 层补齐对象权限、状态和失败结果校验，再在 Servlet/JSP 层处理参数错误、编码和入口。文件系统写入与数据库写入采用“先写后更新、失败清理”的补偿策略；不修改 `DBUtil`、`src/main/resources/init.sql` 或 Tomcat 部署映射。

**Tech Stack:** Java 8 source/target, Servlet 4.0 (`javax.servlet`), JSP/JSTL, MySQL 8, JUnit 5, Maven WAR.

---

## Task 1: Establish regression tests for pure validation and authorization decisions

**Files:**
- Create or modify: `src/test/java/com/poster/service/impl/WorkServiceImplTest.java`
- Create or modify: `src/test/java/com/poster/service/impl/AwardServiceImplTest.java`
- Create or modify: `src/test/java/com/poster/util/HtmlEscaperTest.java` if a Java-side escaping helper is introduced

- [ ] Add one failing test for rejecting an award when the competition is not ended or the work has no score.
- [ ] Add one failing test for rejecting an image/file access decision when the user is neither a team member nor an administrator.
- [ ] Add one failing test for malformed/null IDs returning a user-facing error path instead of an uncaught exception.
- [ ] Run the focused tests and verify each fails for the intended missing behavior before implementation.

## Task 2: Close object-level authorization and upload boundaries

**Files:**
- Modify: `src/main/java/com/poster/controller/ImageDataServlet.java`
- Modify: `src/main/java/com/poster/controller/FileUploadServlet.java`
- Modify: `src/main/java/com/poster/filter/AuthFilter.java`
- Modify: `src/main/java/com/poster/controller/ImageServlet.java` only if the route-level check requires it

- [ ] Reuse the work visibility rule for image retrieval and require membership, leader ownership, public submitted visibility, or administrator permission.
- [ ] Validate `teamId`, `competitionId`, and optional `workId` before database access; require the logged-in user to be a member/leader of the target team and verify team/competition relation and deadline.
- [ ] Keep avatar URLs usable while preventing anonymous access to generic uploaded work files.
- [ ] Reject unsafe file names and clean a physical file if the database insert/update fails.
- [ ] Add focused tests for unauthorized, wrong-team, and valid-owner paths; run them red then green.

## Task 3: Fix parameter errors and XSS-prone presentation

**Files:**
- Modify: `src/main/java/com/poster/controller/CompetitionServlet.java`
- Modify: `src/main/java/com/poster/controller/TeamApplicationServlet.java`
- Modify: user-controlled output in `src/main/webapp/jsp/competition/competition_detail.jsp`, `src/main/webapp/jsp/work/submission_list.jsp`, `src/main/webapp/jsp/work/submission_detail.jsp`, `src/main/webapp/jsp/news/news_list.jsp`, `src/main/webapp/jsp/news/news_detail.jsp`, `src/main/webapp/jsp/admin/news_manage.jsp`, `src/main/webapp/jsp/score/score_input.jsp`

- [ ] Redirect missing or unknown competition/work/team/application IDs with a stable error message instead of forwarding null models.
- [ ] Replace HTML-context raw scriptlet output with JSTL escaped output.
- [ ] Remove user-controlled strings from inline JavaScript or pass them through DOM data attributes and `textContent`.
- [ ] Preserve line breaks and safe formatting for news/content without enabling HTML/script injection.
- [ ] Verify the invalid competition detail route no longer returns HTTP 500.

## Task 4: Repair workflow state and failure consistency

**Files:**
- Modify: `src/main/java/com/poster/service/impl/AwardServiceImpl.java`
- Modify: `src/main/java/com/poster/service/impl/ScoreServiceImpl.java`
- Modify: `src/main/java/com/poster/controller/ScoreServlet.java`
- Modify: `src/main/java/com/poster/controller/NewsServlet.java`
- Modify: `src/main/java/com/poster/service/impl/CommentServiceImpl.java`
- Modify: `src/main/java/com/poster/service/impl/InvitationServiceImpl.java`
- Modify: `src/main/java/com/poster/controller/CompetitionServlet.java`
- Modify: `src/main/java/com/poster/service/impl/CompetitionServiceImpl.java`

- [ ] Require ended competitions and an existing score before awarding; report certificate generation failure and prevent duplicate announcements.
- [ ] Set/derive the scored state consistently and restrict judge workspaces to eligible competitions.
- [ ] Hide unpublished news in detail routes and validate news status on update/delete.
- [ ] Reject duplicate comments for the same work/judge or update the existing record consistently.
- [ ] Treat zero-row invitation/application updates as failures and surface the error.
- [ ] Reject invalid competition state transitions and report category deletion failures.
- [ ] Add tests for each changed service decision, then run all Maven tests.

## Task 5: Add missing user-visible capabilities

**Files:**
- Modify: `src/main/java/com/poster/controller/WorkServlet.java`
- Modify: `src/main/java/com/poster/service/impl/WorkServiceImpl.java`
- Modify: `src/main/webapp/jsp/work/submission_list.jsp`
- Modify: `src/main/webapp/jsp/work/submission_detail.jsp`
- Modify: `src/main/java/com/poster/controller/CertificateServlet.java`
- Modify: `src/main/webapp/jsp/certificate/certificate_view.jsp`
- Modify: `src/main/java/com/poster/controller/FileUploadServlet.java` and related WorkFile DAO/model only as required

- [ ] Expose a share action and button that records a valid share event after visibility authorization.
- [ ] Add a certificate download response using the existing certificate view without inventing a PDF dependency.
- [ ] Associate valid uploaded attachments with a work and expose safe download links to authorized viewers.
- [ ] Do not claim a feature is complete unless the route, service, persistence and page entry all exist.

## Task 6: Regression verification and review

**Files:**
- All modified product and test files.

- [ ] Run the focused red/green tests and `.mvnw.cmd clean verify` with JDK 21 targeting Java 8.
- [ ] Run `npm.cmd run build` for the existing frontend and `git diff --check`.
- [ ] Re-test public GET routes and the invalid competition detail URL at `http://localhost:8080/task_war_exploded` without mutating live data.
- [ ] Review the final diff for unrelated changes and preserve the existing user worktree modifications.
- [ ] Request a focused code review for authorization, XSS, state transitions, and file cleanup; fix critical findings before reporting completion.
