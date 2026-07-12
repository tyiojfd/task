# Competition Lifecycle Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the core competition flow so ended/cancelled competitions become read-only, registered teams can submit exactly once while active, participants can view other teams' works only after a competition ends, and award pages show winning works grouped by competition.

**Architecture:** Keep the existing Servlet/JSP/MVC structure and add small service/controller checks rather than a broad refactor. Use existing `competition.status` values: `0=已取消`, `1=报名中`, `2=进行中`, `3=已结束`; status `3` is the read-only/public-to-participants phase. Centralize repeated work visibility checks inside `WorkServlet` for this pass, with minimal DAO/service additions.

**Tech Stack:** Java 8, Servlet 4.0 (`javax.servlet`), JSP, JSTL, MySQL 8, Maven WAR project.

## Global Constraints

- Do not create a new git branch.
- Do not commit unless the user explicitly asks.
- Match the existing code style and naming.
- Keep changes focused on the requested core flow; do not introduce large framework changes.
- Preserve existing routes where possible and add only minimal new routes.

---

## File Structure

- Modify `src/main/java/com/poster/controller/WorkServlet.java`
  - Add lifecycle checks for submit/edit/delete.
  - Add `competitionWorks` list route and enhance detail visibility.
  - Prevent duplicate team submissions.
- Modify `src/main/java/com/poster/controller/TeamServlet.java`
  - Ensure disband remains POST-only and consumes the existing JSP form.
- Modify `src/main/java/com/poster/controller/ScoreServlet.java`
  - Reject score submit/update when the owning competition is ended/cancelled/not running.
- Modify `src/main/java/com/poster/controller/CommentServlet.java`
  - Reject comment add/update/delete when the owning competition is ended/cancelled/not running.
  - Verify comment ownership on update/delete while touching the area.
- Modify `src/main/java/com/poster/dao/WorkDAO.java`
  - Add query for a team's works in a competition if missing.
- Modify `src/main/java/com/poster/dao/impl/WorkDAOImpl.java`
  - Implement duplicate-check query helper if needed.
- Modify `src/main/java/com/poster/service/WorkService.java`
  - Add `getWorksByTeamIdAndCompetitionId(Integer teamId, Integer competitionId)` if not present.
- Modify `src/main/java/com/poster/service/impl/WorkServiceImpl.java`
  - Expose the duplicate-check helper through the service.
- Modify `src/main/webapp/jsp/submission_add.jsp`
  - Hide/disable ineligible teams and fix edit mode team handling.
- Modify `src/main/webapp/jsp/submission_detail.jsp`
  - Support read-only viewing of other teams' works after competition end.
- Create `src/main/webapp/jsp/competition_works.jsp`
  - Display ended-competition works to eligible participants/admin/judges.
- Modify `src/main/webapp/jsp/team_detail.jsp`
  - Change disband link to a POST form.
- Modify `src/main/java/com/poster/controller/AwardServlet.java`
  - Build competition-grouped award data for global list.
- Modify `src/main/webapp/jsp/award_list.jsp`
  - Render grouped winning works by competition.

---

### Task 1: Submission lifecycle and duplicate protections

**Files:**
- Modify: `src/main/java/com/poster/controller/WorkServlet.java`
- Modify: `src/main/java/com/poster/service/WorkService.java`
- Modify: `src/main/java/com/poster/service/impl/WorkServiceImpl.java`
- Modify: `src/main/webapp/jsp/submission_add.jsp`

**Interfaces:**
- Produces: `WorkService.getWorksByTeamIdAndCompetitionId(Integer teamId, Integer competitionId)` returns `List<Work>`.
- Produces: `WorkServlet.isCompetitionRunningAndOpen(Competition competition)` returns `boolean`.

Steps:
- Add service method to query works by team and competition.
- In `showAddForm`, pass only leader teams plus eligibility maps: registered, competition running, before deadline, already submitted.
- In `submitWork`, reject if team status is not `2`, competition status is not `2`, deadline has passed, or the team already has a work in that competition.
- In edit mode, render existing team as fixed/read-only instead of requiring a new `teamId`.
- Run `mvn test` and manually verify submit page behavior.

### Task 2: Work edit/delete/read-only visibility

**Files:**
- Modify: `src/main/java/com/poster/controller/WorkServlet.java`
- Modify: `src/main/webapp/jsp/submission_detail.jsp`
- Create: `src/main/webapp/jsp/competition_works.jsp`

**Interfaces:**
- Produces: `WorkServlet.canViewWork(User user, Work work)` with rules: admin always, judge always, same-team member always, participant in same ended competition can view.
- Produces: `GET /work?action=competitionWorks&competitionId=ID`.

Steps:
- Replace same-team-only detail check with `canViewWork`.
- Compute `isOwnTeam` and `readOnlyView` request attributes.
- Reject edit/delete unless the user is the leader and the competition is status `2` and before deadline.
- Add competition works route that lists works only when the competition status is `3` or current user is admin/judge.
- Add links from detail/list where appropriate.
- Run `mvn test` and manually verify participant can view other works only after ending competition.

### Task 3: Team disband POST fix and lifecycle guard

**Files:**
- Modify: `src/main/webapp/jsp/team_detail.jsp`
- Modify: `src/main/java/com/poster/service/impl/TeamServiceImpl.java`

**Interfaces:**
- Consumes: existing `POST /team?action=delete&id=ID`.

Steps:
- Replace `GET /team?action=delete` disband anchor with a POST form.
- In `TeamServiceImpl.deleteTeam`, allow disband only for leader-owned teams with status `1` and no works.
- Keep registered/submitted teams from being physically deleted.
- Run `mvn test` and manually verify the disband button now calls POST and works for forming teams.

### Task 4: Stop scoring and comments after competition ends

**Files:**
- Modify: `src/main/java/com/poster/controller/ScoreServlet.java`
- Modify: `src/main/java/com/poster/controller/CommentServlet.java`
- Modify: `src/main/java/com/poster/service/CommentService.java`
- Modify: `src/main/java/com/poster/service/impl/CommentServiceImpl.java`

**Interfaces:**
- Produces: `CommentService.getCommentById(Integer commentId)` if not already exposed.

Steps:
- In score submit/update, load the work and competition and require `competition.status == 2`.
- In comment add/update/delete, load the work and competition and require `competition.status == 2`.
- On comment update/delete, verify `comment.judgeId` equals current judge ID.
- Run `mvn test` and manually verify ended competitions reject score/comment changes.

### Task 5: Award list grouped by competition

**Files:**
- Modify: `src/main/java/com/poster/controller/AwardServlet.java`
- Modify: `src/main/webapp/jsp/award_list.jsp`

**Interfaces:**
- Produces request attributes: `groupedAwards` as `Map<Competition, List<Award>>`, existing `workMap`, `teamNameMap`, `avgScoreMap` remain available.

Steps:
- In global award list mode, group awards by `competition_id` and load competition names.
- In filtered competition mode, render only the selected competition group.
- Change page title/copy from “获奖名单” to “获奖作品”.
- Reset display ranking inside each competition group and order by award level/final score.
- Run `mvn test` and inspect `/award?action=list` in browser.

### Task 6: Verification pass

**Files:**
- No new files; verify changed surfaces.

Steps:
- Run `mvn test`.
- Use browser to inspect `/award?action=list`.
- Use browser or route checks for competition works and existing work detail.
- Run `git diff --stat` and review changed files for accidental broad changes.
