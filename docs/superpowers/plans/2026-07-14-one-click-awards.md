# One-Click Awards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an admin-only one-click award generator that ranks scored works by average judge score and assigns first/second/third prizes by 10%/15%/20% proportions.

**Architecture:** Keep routing and permission checks in `AwardServlet`, place ranking and batch generation in `AwardServiceImpl`, and keep JSP changes limited to the existing award management page. Add focused model/policy classes so award count math and service return data are independently testable.

**Tech Stack:** Java 8, Servlet API 4.0.1 (`javax.servlet`), JSP, JUnit 5.11.0, Maven WAR project, MySQL-backed DAO layer.

## Global Constraints

- Entry point: existing `/award?action=manage&competitionId=...` award management page.
- Ranking source: average score from the `score` table for each work.
- Eligible works: current competition only, work `status=2` or `status=3`, and at least one score record.
- Award percentages: first prize `ceil(scoredCandidateCount * 10%)`, second prize `ceil(scoredCandidateCount * 15%)`, third prize `ceil(scoredCandidateCount * 20%)`.
- Single-digit work counts still use the same percentage + ceiling rule.
- Total generated awards must never exceed the number of scored candidate works shown as eligible on the award management page.
- Tie behavior: do not expand award counts for boundary ties; use stable fallback ordering.
- Existing awards strategy: delete existing awards and certificates for the selected competition, then regenerate.
- Safety: if there are zero scored candidate works, do not delete existing awards.
- UI copy must clearly warn that one-click generation overwrites current awards and regenerates certificates.
- Do not add new dependencies.
- Do not commit unless the user explicitly asks.

---

## File Structure

- Create `src/main/java/com/poster/model/AutoAwardResult.java`
  - Immutable-style result container for service outcomes and UI flash messages.
- Create `src/main/java/com/poster/util/AutoAwardPolicy.java`
  - Pure functions for prize count calculation and stable sorting support. This keeps the percentage rules testable without database access.
- Create `src/test/java/com/poster/util/AutoAwardPolicyTest.java`
  - Unit tests for award count math, single-digit behavior, truncation, and zero candidates.
- Modify `src/main/java/com/poster/service/AwardService.java`
  - Add `AutoAwardResult autoGenerateAwards(Integer competitionId, Integer issuerId)`.
- Modify `src/main/java/com/poster/service/impl/AwardServiceImpl.java`
  - Implement candidate filtering, ranking, old award cleanup, batch award insertion, and certificate generation.
- Modify `src/main/java/com/poster/controller/AwardServlet.java`
  - Add `autoGenerate` POST action and display support for unscored works.
- Modify `src/main/webapp/jsp/award_manage.jsp`
  - Add the one-click generation form/button and show unscored works as skipped.
- Create `src/test/java/com/poster/web/AwardManageTemplateTest.java`
  - Template-level tests that guard the form action, warning copy, hidden fields, and unscored display copy.

---

### Task 1: Add Pure Award Count Policy

**Files:**
- Create: `src/main/java/com/poster/util/AutoAwardPolicy.java`
- Create: `src/test/java/com/poster/util/AutoAwardPolicyTest.java`

**Interfaces:**
- Consumes: none.
- Produces:
  - `public final class AutoAwardPolicy`
  - `public static PrizeCounts calculatePrizeCounts(int candidateCount)`
  - `public static final class PrizeCounts`
  - `PrizeCounts#getFirstPrizeCount(): int`
  - `PrizeCounts#getSecondPrizeCount(): int`
  - `PrizeCounts#getThirdPrizeCount(): int`
  - `PrizeCounts#getTotalCount(): int`

- [ ] **Step 1: Write failing tests for percentage math**

Create `src/test/java/com/poster/util/AutoAwardPolicyTest.java`:

```java
package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AutoAwardPolicyTest {

    @Test
    void nineCandidatesUseCeilingPercentages() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(9);

        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(2, counts.getSecondPrizeCount());
        assertEquals(2, counts.getThirdPrizeCount());
        assertEquals(5, counts.getTotalCount());
    }

    @Test
    void oneCandidateNeverProducesMoreThanOneAward() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(1);

        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(0, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(1, counts.getTotalCount());
    }

    @Test
    void zeroCandidatesProduceNoAwards() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(0);

        assertEquals(0, counts.getFirstPrizeCount());
        assertEquals(0, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(0, counts.getTotalCount());
    }

    @Test
    void twoCandidatesTruncateByPrizeOrder() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(2);

        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(1, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(2, counts.getTotalCount());
    }

    @Test
    void tenCandidatesFollowTenFifteenTwentyPercentCeiling() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(10);

        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(2, counts.getSecondPrizeCount());
        assertEquals(2, counts.getThirdPrizeCount());
        assertEquals(5, counts.getTotalCount());
    }
}
```

- [ ] **Step 2: Run the failing test**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest=AutoAwardPolicyTest test
```

Expected: compilation fails because `AutoAwardPolicy` does not exist.

- [ ] **Step 3: Implement the policy**

Create `src/main/java/com/poster/util/AutoAwardPolicy.java`:

```java
package com.poster.util;

/**
 * Calculates automatic award quotas for a competition.
 */
public final class AutoAwardPolicy {

    private AutoAwardPolicy() {
    }

    public static PrizeCounts calculatePrizeCounts(int candidateCount) {
        if (candidateCount <= 0) {
            return new PrizeCounts(0, 0, 0);
        }

        int first = calculateCeiling(candidateCount, 0.10);
        int second = calculateCeiling(candidateCount, 0.15);
        int third = calculateCeiling(candidateCount, 0.20);

        int remaining = candidateCount;
        int finalFirst = Math.min(first, remaining);
        remaining -= finalFirst;

        int finalSecond = Math.min(second, remaining);
        remaining -= finalSecond;

        int finalThird = Math.min(third, remaining);

        return new PrizeCounts(finalFirst, finalSecond, finalThird);
    }

    private static int calculateCeiling(int candidateCount, double ratio) {
        return (int) Math.ceil(candidateCount * ratio);
    }

    public static final class PrizeCounts {
        private final int firstPrizeCount;
        private final int secondPrizeCount;
        private final int thirdPrizeCount;

        public PrizeCounts(int firstPrizeCount, int secondPrizeCount, int thirdPrizeCount) {
            this.firstPrizeCount = firstPrizeCount;
            this.secondPrizeCount = secondPrizeCount;
            this.thirdPrizeCount = thirdPrizeCount;
        }

        public int getFirstPrizeCount() {
            return firstPrizeCount;
        }

        public int getSecondPrizeCount() {
            return secondPrizeCount;
        }

        public int getThirdPrizeCount() {
            return thirdPrizeCount;
        }

        public int getTotalCount() {
            return firstPrizeCount + secondPrizeCount + thirdPrizeCount;
        }
    }
}
```

- [ ] **Step 4: Run the policy tests**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest=AutoAwardPolicyTest test
```

Expected: test passes.

---

### Task 2: Add Service Result Model and Interface Method

**Files:**
- Create: `src/main/java/com/poster/model/AutoAwardResult.java`
- Modify: `src/main/java/com/poster/service/AwardService.java`

**Interfaces:**
- Consumes: `AutoAwardPolicy.PrizeCounts` from Task 1.
- Produces:
  - `public class AutoAwardResult`
  - `public static AutoAwardResult success(int candidateCount, int skippedUnscoredCount, AutoAwardPolicy.PrizeCounts prizeCounts)`
  - `public static AutoAwardResult failure(String message)`
  - getters for `success`, `message`, `candidateCount`, `skippedUnscoredCount`, `firstPrizeCount`, `secondPrizeCount`, `thirdPrizeCount`
  - `AwardService#autoGenerateAwards(Integer competitionId, Integer issuerId): AutoAwardResult`

- [ ] **Step 1: Create the result model**

Create `src/main/java/com/poster/model/AutoAwardResult.java`:

```java
package com.poster.model;

import com.poster.util.AutoAwardPolicy;

/**
 * Result returned after automatic award generation.
 */
public class AutoAwardResult {
    private final boolean success;
    private final String message;
    private final int candidateCount;
    private final int skippedUnscoredCount;
    private final int firstPrizeCount;
    private final int secondPrizeCount;
    private final int thirdPrizeCount;

    private AutoAwardResult(boolean success, String message, int candidateCount,
                            int skippedUnscoredCount, int firstPrizeCount,
                            int secondPrizeCount, int thirdPrizeCount) {
        this.success = success;
        this.message = message;
        this.candidateCount = candidateCount;
        this.skippedUnscoredCount = skippedUnscoredCount;
        this.firstPrizeCount = firstPrizeCount;
        this.secondPrizeCount = secondPrizeCount;
        this.thirdPrizeCount = thirdPrizeCount;
    }

    public static AutoAwardResult success(int candidateCount, int skippedUnscoredCount,
                                          AutoAwardPolicy.PrizeCounts prizeCounts) {
        String message = "已按均分生成获奖名单：一等奖 " + prizeCounts.getFirstPrizeCount()
                + " 名、二等奖 " + prizeCounts.getSecondPrizeCount()
                + " 名、三等奖 " + prizeCounts.getThirdPrizeCount()
                + " 名；跳过未评分作品 " + skippedUnscoredCount + " 件";
        return new AutoAwardResult(true, message, candidateCount, skippedUnscoredCount,
                prizeCounts.getFirstPrizeCount(), prizeCounts.getSecondPrizeCount(),
                prizeCounts.getThirdPrizeCount());
    }

    public static AutoAwardResult failure(String message) {
        return new AutoAwardResult(false, message, 0, 0, 0, 0, 0);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public int getCandidateCount() {
        return candidateCount;
    }

    public int getSkippedUnscoredCount() {
        return skippedUnscoredCount;
    }

    public int getFirstPrizeCount() {
        return firstPrizeCount;
    }

    public int getSecondPrizeCount() {
        return secondPrizeCount;
    }

    public int getThirdPrizeCount() {
        return thirdPrizeCount;
    }
}
```

- [ ] **Step 2: Update the AwardService interface**

Modify `src/main/java/com/poster/service/AwardService.java` to import the result model and add the method. The full file should be:

```java
package com.poster.service;

import com.poster.model.Award;
import com.poster.model.AutoAwardResult;
import java.util.List;

/**
 * 获奖服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface AwardService {

    /**
     * 设置获奖
     */
    boolean setAward(Award award);

    /**
     * 一键生成获奖名单
     */
    AutoAwardResult autoGenerateAwards(Integer competitionId, Integer issuerId);

    /**
     * 根据竞赛ID查询获奖列表
     */
    List<Award> getAwardsByCompetitionId(Integer competitionId);

    /**
     * 根据作品ID查询获奖信息
     */
    Award getAwardByWorkId(Integer workId);

    /**
     * 生成电子奖状
     */
    boolean generateCertificate(Integer awardId);

    /**
     * 发布获奖公告
     */
    boolean publishAwardAnnouncement(Integer competitionId);
}
```

- [ ] **Step 3: Compile to expose missing implementation**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests compile
```

Expected: compilation fails because `AwardServiceImpl` does not yet implement `autoGenerateAwards`.

---

### Task 3: Implement Service Batch Generation

**Files:**
- Modify: `src/main/java/com/poster/service/impl/AwardServiceImpl.java`

**Interfaces:**
- Consumes:
  - `AutoAwardResult` from Task 2.
  - `AutoAwardPolicy.calculatePrizeCounts(int)` from Task 1.
  - Existing `AwardDAO`, `CertificateDAO`, `WorkDAO`, `CompetitionDAO`, `ScoreDAO` methods.
- Produces:
  - `AwardServiceImpl#autoGenerateAwards(Integer competitionId, Integer issuerId): AutoAwardResult`

- [ ] **Step 1: Add imports**

In `src/main/java/com/poster/service/impl/AwardServiceImpl.java`, add imports:

```java
import com.poster.model.AutoAwardResult;
import com.poster.model.Score;
import com.poster.util.AutoAwardPolicy;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
```

Keep existing imports.

- [ ] **Step 2: Add private candidate helper class**

Inside `AwardServiceImpl`, before the final closing brace, add:

```java
    private static class AwardCandidate {
        private final Work work;
        private final double averageScore;

        private AwardCandidate(Work work, double averageScore) {
            this.work = work;
            this.averageScore = averageScore;
        }
    }
```

- [ ] **Step 3: Add autoGenerateAwards implementation**

Inside `AwardServiceImpl`, after `setAward` and before `getAwardsByCompetitionId`, add:

```java
    @Override
    public AutoAwardResult autoGenerateAwards(Integer competitionId, Integer issuerId) {
        if (competitionId == null || issuerId == null) {
            return AutoAwardResult.failure("请选择有效竞赛");
        }

        Competition competition = competitionDAO.findById(competitionId);
        if (competition == null) {
            return AutoAwardResult.failure("竞赛不存在");
        }
        if (!Integer.valueOf(3).equals(competition.getStatus())) {
            return AutoAwardResult.failure("仅已结束竞赛可一键生成获奖名单");
        }

        List<Work> works = workDAO.findByCompetitionId(competitionId);
        if (works == null || works.isEmpty()) {
            return AutoAwardResult.failure("该竞赛暂无作品，无法生成获奖名单");
        }

        List<AwardCandidate> candidates = new ArrayList<>();
        int skippedUnscoredCount = 0;
        for (Work work : works) {
            if (work == null || work.getStatus() == null
                    || (!Integer.valueOf(2).equals(work.getStatus())
                    && !Integer.valueOf(3).equals(work.getStatus()))) {
                continue;
            }

            List<Score> scores = scoreDAO.findByWorkId(work.getWorkId());
            if (scores == null || scores.isEmpty()) {
                skippedUnscoredCount++;
                continue;
            }

            Double averageScore = scoreDAO.getAverageScoreByWorkId(work.getWorkId());
            candidates.add(new AwardCandidate(work, averageScore != null ? averageScore : 0.0));
        }

        if (candidates.isEmpty()) {
            return AutoAwardResult.failure("当前没有已评分作品，无法生成获奖名单");
        }

        Collections.sort(candidates, new Comparator<AwardCandidate>() {
            @Override
            public int compare(AwardCandidate a, AwardCandidate b) {
                int scoreCompare = Double.compare(b.averageScore, a.averageScore);
                if (scoreCompare != 0) return scoreCompare;

                if (a.work.getSubmitTime() != null && b.work.getSubmitTime() != null) {
                    int timeCompare = a.work.getSubmitTime().compareTo(b.work.getSubmitTime());
                    if (timeCompare != 0) return timeCompare;
                } else if (a.work.getSubmitTime() != null) {
                    return -1;
                } else if (b.work.getSubmitTime() != null) {
                    return 1;
                }

                return Integer.compare(a.work.getWorkId(), b.work.getWorkId());
            }
        });

        AutoAwardPolicy.PrizeCounts prizeCounts = AutoAwardPolicy.calculatePrizeCounts(candidates.size());
        if (!clearExistingAwardsForCompetition(competitionId)) {
            return AutoAwardResult.failure("生成失败，请稍后重试或手动设置");
        }

        int created = 0;
        created += createAwardsForLevel(candidates, created, prizeCounts.getFirstPrizeCount(),
                "一等奖", competitionId, issuerId);
        created += createAwardsForLevel(candidates, created, prizeCounts.getSecondPrizeCount(),
                "二等奖", competitionId, issuerId);
        created += createAwardsForLevel(candidates, created, prizeCounts.getThirdPrizeCount(),
                "三等奖", competitionId, issuerId);

        if (created != prizeCounts.getTotalCount()) {
            return AutoAwardResult.failure("生成失败，请稍后重试或手动设置");
        }

        return AutoAwardResult.success(candidates.size(), skippedUnscoredCount, prizeCounts);
    }
```

- [ ] **Step 4: Add cleanup and creation helpers**

Inside `AwardServiceImpl`, before the `AwardCandidate` helper class, add:

```java
    private boolean clearExistingAwardsForCompetition(Integer competitionId) {
        List<Award> existingAwards = awardDAO.findByCompetitionId(competitionId);
        if (existingAwards == null || existingAwards.isEmpty()) {
            return true;
        }

        for (Award existingAward : existingAwards) {
            Certificate certificate = certificateDAO.findByAwardId(existingAward.getAwardId());
            if (certificate != null && certificateDAO.deleteById(certificate.getCertificateId()) <= 0) {
                return false;
            }
            if (awardDAO.deleteById(existingAward.getAwardId()) <= 0) {
                return false;
            }
        }
        return true;
    }

    private int createAwardsForLevel(List<AwardCandidate> candidates, int startIndex, int count,
                                     String awardLevel, Integer competitionId, Integer issuerId) {
        int created = 0;
        for (int i = 0; i < count && startIndex + i < candidates.size(); i++) {
            AwardCandidate candidate = candidates.get(startIndex + i);
            Award award = new Award();
            award.setCompetitionId(competitionId);
            award.setWorkId(candidate.work.getWorkId());
            award.setAwardLevel(awardLevel);
            award.setFinalScore(candidate.averageScore);
            award.setIssuerId(issuerId);

            if (awardDAO.insert(award) <= 0) {
                return created;
            }
            if (!generateCertificate(award.getAwardId())) {
                awardDAO.deleteById(award.getAwardId());
                return created;
            }
            created++;
        }
        return created;
    }
```

- [ ] **Step 5: Compile service changes**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests compile
```

Expected: compilation passes.

---

### Task 4: Wire Servlet POST Action

**Files:**
- Modify: `src/main/java/com/poster/controller/AwardServlet.java`

**Interfaces:**
- Consumes:
  - `AwardService#autoGenerateAwards(Integer, Integer): AutoAwardResult` from Task 2.
- Produces:
  - POST `/award` with `action=autoGenerate`.

- [ ] **Step 1: Add import**

In `AwardServlet.java`, add:

```java
import com.poster.model.AutoAwardResult;
```

- [ ] **Step 2: Add POST routing branch**

In `doPost`, after the `set` branch and before the `delete` branch, change the routing block to:

```java
        if ("set".equals(action)) {
            // 设置获奖
            setAward(request, response);
        } else if ("autoGenerate".equals(action)) {
            // 一键生成获奖名单
            autoGenerateAwards(request, response);
        } else if ("delete".equals(action)) {
            // 删除获奖
            deleteAward(request, response);
        } else if ("publishAnnouncement".equals(action)) {
            // 发布获奖公告
            publishAnnouncement(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
```

- [ ] **Step 3: Add handler method**

In `AwardServlet.java`, after `setAward` and before `deleteAward`, add:

```java
    /**
     * 一键生成获奖名单（管理员操作）
     */
    private void autoGenerateAwards(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        User user = (User) session.getAttribute("user");
        String competitionIdStr = request.getParameter("competitionId");

        try {
            Integer competitionId = Integer.parseInt(competitionIdStr);
            AutoAwardResult result = awardService.autoGenerateAwards(competitionId, user.getUserId());
            if (result.isSuccess()) {
                request.getSession().setAttribute("message", result.getMessage());
            } else {
                request.getSession().setAttribute("error", result.getMessage());
            }
            response.sendRedirect(request.getContextPath()
                    + "/award?action=manage&competitionId=" + competitionId);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "请选择有效竞赛");
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
    }
```

- [ ] **Step 4: Compile servlet changes**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests compile
```

Expected: compilation passes.

---

### Task 5: Update Award Management JSP

**Files:**
- Modify: `src/main/webapp/jsp/award_manage.jsp`
- Create: `src/test/java/com/poster/web/AwardManageTemplateTest.java`

**Interfaces:**
- Consumes: POST `/award?action=autoGenerate` from Task 4.
- Produces: Admin UI button with overwrite warning and unscored work copy.

- [ ] **Step 1: Write template tests**

Create `src/test/java/com/poster/web/AwardManageTemplateTest.java`:

```java
package com.poster.web;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.assertTrue;

class AwardManageTemplateTest {

    private static final Path JSP = Paths.get("src", "main", "webapp", "jsp", "award_manage.jsp");

    @Test
    void awardManagePageContainsAutoGenerateForm() throws Exception {
        String jsp = read(JSP);

        assertTrue(jsp.contains("name=\"action\" value=\"autoGenerate\""));
        assertTrue(jsp.contains("一键生成获奖名单"));
        assertTrue(jsp.contains("撤销当前竞赛已有获奖记录并重新生成奖状"));
    }

    @Test
    void awardManagePageExplainsUnscoredWorksAreSkipped() throws Exception {
        String jsp = read(JSP);

        assertTrue(jsp.contains("暂无评分，不参与一键获奖"));
    }

    private static String read(Path path) throws Exception {
        return new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
    }
}
```

- [ ] **Step 2: Run failing template test**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest=AwardManageTemplateTest test
```

Expected: test fails because the JSP does not yet contain the form/copy.

- [ ] **Step 3: Add the one-click form to JSP**

In `src/main/webapp/jsp/award_manage.jsp`, immediately after line containing:

```jsp
<h5 class="mb-3"><i class="fas fa-image"></i> <%= HtmlEscaper.escape(selectedCompetition.getName()) %> - 作品列表</h5>
```

replace that single heading with:

```jsp
            <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-3">
                <div>
                    <h5 class="mb-1"><i class="fas fa-image"></i> <%= HtmlEscaper.escape(selectedCompetition.getName()) %> - 作品列表</h5>
                    <small class="text-muted">一键获奖只统计已评分作品，未评分作品会自动跳过。</small>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/award"
                      onsubmit="return confirm('确定要一键生成获奖名单吗？此操作会撤销当前竞赛已有获奖记录并重新生成奖状。')">
                    <input type="hidden" name="action" value="autoGenerate">
                    <input type="hidden" name="competitionId" value="<%= selectedCompetition.getCompetitionId() %>">
                    <button type="submit" class="btn btn-warning btn-sm">
                        <i class="fas fa-wand-magic-sparkles"></i> 一键生成获奖名单
                    </button>
                    <div class="form-text text-end">前10%一等奖，后15%二等奖，后20%三等奖</div>
                </form>
            </div>
```

- [ ] **Step 4: Show unscored works as skipped**

In the work card block, replace:

```jsp
                            <i class="fas fa-star"></i> 均分: <%= String.format("%.1f", avg != null ? avg : 0.0) %>
```

with:

```jsp
                            <% if (avg != null && avg > 0) { %>
                                <i class="fas fa-star"></i> 均分: <%= String.format("%.1f", avg) %>
                            <% } else { %>
                                <i class="fas fa-circle-info"></i> 暂无评分，不参与一键获奖
                            <% } %>
```

- [ ] **Step 5: Run template tests**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest=AwardManageTemplateTest test
```

Expected: test passes.

- [ ] **Step 6: Compile package to catch JSP-adjacent Java issues**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package
```

Expected: build passes.

---

### Task 6: Final Verification

**Files:**
- Verify all changed files from Tasks 1-5.

**Interfaces:**
- Consumes: full implementation from Tasks 1-5.
- Produces: verified build and clear manual verification notes.

- [ ] **Step 1: Run targeted tests**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest=AutoAwardPolicyTest,AwardManageTemplateTest test
```

Expected: both tests pass.

- [ ] **Step 2: Run full test suite**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q test
```

Expected: all tests pass.

- [ ] **Step 3: Run package build**

Run:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package
```

Expected: WAR package build succeeds.

- [ ] **Step 4: Inspect changed files**

Run:

```bash
git diff -- src/main/java/com/poster/model/AutoAwardResult.java src/main/java/com/poster/util/AutoAwardPolicy.java src/main/java/com/poster/service/AwardService.java src/main/java/com/poster/service/impl/AwardServiceImpl.java src/main/java/com/poster/controller/AwardServlet.java src/main/webapp/jsp/award_manage.jsp src/test/java/com/poster/util/AutoAwardPolicyTest.java src/test/java/com/poster/web/AwardManageTemplateTest.java
```

Expected: diff shows only the one-click awards implementation and tests.

- [ ] **Step 5: Manual browser verification if app data is available**

Start the app if needed:

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw jetty:run
```

Open an admin session and verify:

1. Visit `/task/award?action=manage`.
2. Select an ended competition with scored works.
3. Confirm the “一键生成获奖名单” button appears.
4. Click it and accept the confirmation.
5. Confirm the success message lists first/second/third counts and skipped unscored works.
6. Confirm existing award rows are replaced and certificate links still open.

If no suitable local data exists, record that browser verification was skipped because no ended competition with scored works was available.
