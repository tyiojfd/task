# 全站前端统一与角色首页 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 保留队员首页原样，新增与其风格一致的评委/管理员首页，并让其它 JSP 页面共享统一的视觉壳层。

**Architecture:** `IndexServlet` 继续作为 `/index` 入口，根据 Session 角色把管理员、评委和普通用户/队员转发到各自首页。现有队员首页继续使用 `home.css`；新增角色首页使用 `home.css` 的品牌变量与图片资源，再由 `role-home.css` 补充角色布局；其它 JSP 通过 `app-shell-assets.jspf` 加载 `app-shell.css`，只做表现层覆盖，不改变现有业务 action 和参数。

**Tech Stack:** Java 8, Servlet 4 / JSP, Bootstrap 5.3, Font Awesome 6.4, CSS media queries, JUnit 5, Maven。

---

## 文件地图

- Create: `src/test/java/com/poster/web/HomeViewRoutingTest.java` — 验证 `/index` 的角色视图策略。
- Create: `src/test/java/com/poster/web/UnifiedFrontendTemplateTest.java` — 验证角色首页关键入口和非队员 JSP 的共享样式接入。
- Create: `src/main/webapp/jsp/judge_home.jsp` — 评委工作台首页，只读取 Servlet 准备好的属性。
- Create: `src/main/webapp/jsp/admin_home.jsp` — 管理员运营首页，只读取 Servlet 准备好的属性。
- Create: `src/main/webapp/jsp/includes/app-shell-assets.jspf` — 统一业务页面的样式引用片段。
- Create: `src/main/webapp/css/app-shell.css` — 非队员首页的全站业务页面主题和响应式规则。
- Create: `src/main/webapp/css/role-home.css` — 评委/管理员首页布局、角色色彩与工作区组件。
- Modify: `src/main/java/com/poster/controller/IndexServlet.java` — 准备角色首页统计并按角色转发。
- Modify: `src/main/webapp/jsp/*.jsp`（不含 `index.jsp`）— 在 `</head>` 前接入 `app-shell-assets.jspf`；已有业务结构和 action 保持不变。
- Do not modify: `src/main/webapp/jsp/index.jsp`, `src/main/webapp/css/home.css`, React 进入页、DAO/Service 业务接口和数据库脚本。

## Task 1: Lock the role routing contract with failing tests

**Files:**
- Create: `src/test/java/com/poster/web/HomeViewRoutingTest.java`
- Modify: `src/main/java/com/poster/controller/IndexServlet.java` only after the failing test is observed.

- [ ] **Step 1: Write the failing routing tests**

```java
package com.poster.web;

import com.poster.controller.IndexServlet;
import com.poster.model.Role;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HomeViewRoutingTest {

    @Test
    void administratorUsesTheAdministratorHome() throws Exception {
        assertEquals("/jsp/admin_home.jsp", resolve(role("管理员")));
    }

    @Test
    void judgeUsesTheJudgeHome() throws Exception {
        assertEquals("/jsp/judge_home.jsp", resolve(role("评委")));
    }

    @Test
    void participantAndAnonymousUsersKeepTheExistingHome() throws Exception {
        assertEquals("/jsp/index.jsp", resolve(role("队员")));
        assertEquals("/jsp/index.jsp", resolve());
    }

    @Test
    void administratorWinsWhenAnAccountHasMultipleRoles() throws Exception {
        assertEquals("/jsp/admin_home.jsp", resolve(role("队员"), role("管理员")));
    }

    private static String resolve(Role... roles) throws Exception {
        Method method = IndexServlet.class.getDeclaredMethod("resolveHomeView", java.util.List.class);
        method.setAccessible(true);
        return (String) method.invoke(new IndexServlet(), Arrays.asList(roles));
    }

    private static Role role(String name) {
        Role role = new Role();
        role.setRoleName(name);
        return role;
    }
}
```

- [ ] **Step 2: Run the focused test and confirm the expected failure**

Run: `.\mvnw.cmd -q -Dtest=HomeViewRoutingTest test`

Expected: FAIL because `IndexServlet` does not yet expose the `resolveHomeView(List<Role>)` method and all requests still forward to `index.jsp`.

- [ ] **Step 3: Add the minimal routing helper**

Add a private method to `IndexServlet`:

```java
private String resolveHomeView(List<Role> roles) {
    if (roles != null) {
        for (Role role : roles) {
            if (role != null && "管理员".equals(role.getRoleName())) {
                return "/jsp/admin_home.jsp";
            }
        }
        for (Role role : roles) {
            if (role != null && "评委".equals(role.getRoleName())) {
                return "/jsp/judge_home.jsp";
            }
        }
    }
    return "/jsp/index.jsp";
}
```

Keep the method deterministic and role-name based so a multi-role administrator cannot be routed to the participant home.

- [ ] **Step 4: Run the focused test and confirm it passes**

Run: `.\mvnw.cmd -q -Dtest=HomeViewRoutingTest test`

Expected: PASS with four tests.

## Task 2: Prepare role-specific dashboard data and views

**Files:**
- Modify: `src/main/java/com/poster/controller/IndexServlet.java`
- Create: `src/main/webapp/jsp/judge_home.jsp`
- Create: `src/main/webapp/jsp/admin_home.jsp`
- Create: `src/main/webapp/css/role-home.css`

- [ ] **Step 1: Add data preparation for both role dashboards**

Keep the existing `competitions` and `globalStats` attributes. Add the following request attributes with empty-list/zero fallbacks:

```java
List<Work> allWorks = workDAO.findAll();
List<Work> pendingWorks = new ArrayList<>();
for (Work work : allWorks) {
    if (work != null && Integer.valueOf(2).equals(work.getStatus())) {
        pendingWorks.add(work);
    }
}

List<Score> myScores = isJudge && user != null
        ? scoreService.getScoresByJudgeId(user.getUserId())
        : Collections.emptyList();
List<User> allUsers = isAdmin ? userService.getAllUsers() : Collections.emptyList();

request.setAttribute("pendingWorks", pendingWorks);
request.setAttribute("myScores", myScores == null ? Collections.emptyList() : myScores);
request.setAttribute("userCount", allUsers == null ? 0 : allUsers.size());
```

Use the existing DAO/Service implementations already used by the project. Do not add new database queries or schema changes. Forward using the result of `resolveHomeView(userRoles)` instead of hard-coding `index.jsp`.

- [ ] **Step 2: Build the judge dashboard markup**

Create a page with:

```jsp
<body class="home-page role-home judge-home">
    <% request.setAttribute("activeNav", "home"); %>
    <%@ include file="includes/navbar.jspf" %>
    <main class="role-home-main">
        <section class="role-hero role-hero-judge">...</section>
        <section class="role-stat-grid">...</section>
        <section class="role-workspace">...</section>
    </main>
</body>
```

The hero must link to `/score?action=list` and `/score?action=myScores`. The workspace loops over `pendingWorks`, shows at most six items, escapes each title, and links each item to `/score?action=input&workId=<id>`. If the list is empty, render an inline empty state linking to `/score?action=list`. Add secondary links for `/award?action=list` and `/news?action=list`.

- [ ] **Step 3: Build the administrator dashboard markup**

Use the same outer structure and component vocabulary, but make the primary actions:

```jsp
<a href="${pageContext.request.contextPath}/competition?action=add">发布新竞赛</a>
<a href="${pageContext.request.contextPath}/competition?action=list">进入竞赛管理</a>
```

Render stat values from `globalStats` and `userCount`. Add operational shortcut cards for `/admin/users`, `/award?action=manage`, `/certificate?action=list`, and `/news?action=manage`. Loop over at most six competitions using the same cover fallback logic as the participant home and show an administrator empty state linking to the competition creation page.

- [ ] **Step 4: Add role-home styling and verify responsive behavior**

In `role-home.css`, reuse the participant palette and local poster/hero assets without editing `home.css`. Define `.role-home-main`, `.role-hero`, `.role-stat-grid`, `.role-stat-card`, `.role-workspace`, `.role-action-grid`, `.role-list-item`, `.role-empty`, and the judge/admin modifier classes. Use a fixed rem spacing scale, 12–24px card radii, visible focus states, 150–250ms transitions, and media queries at 1100px, 720px, and 520px. Add a reduced-motion block that removes transforms and transitions.

- [ ] **Step 5: Run compile and focused tests**

Run: `.\mvnw.cmd -q -Dtest=HomeViewRoutingTest test`

Expected: PASS; JSP compilation is checked in the later package step after the pages exist.

## Task 3: Add the shared business-page shell

**Files:**
- Create: `src/main/webapp/jsp/includes/app-shell-assets.jspf`
- Create: `src/main/webapp/css/app-shell.css`
- Modify: every JSP under `src/main/webapp/jsp` except `index.jsp` to include the asset fragment before `</head>`.

- [ ] **Step 1: Add the shared asset fragment**

Create:

```jsp
<%@ page pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-shell.css?v=20260713">
```

- [ ] **Step 2: Add the shared page tokens and scoped base styles**

Start `app-shell.css` with tokens derived from `home.css` and scope page-level rules so the participant home remains untouched:

```css
:root {
    --app-bg: #eef7fb;
    --app-surface: rgba(255, 255, 255, 0.84);
    --app-surface-strong: #ffffff;
    --app-ink: #102032;
    --app-muted: #66758a;
    --app-blue: #3f8fd8;
    --app-blue-deep: #24679f;
    --app-cyan: #7ee7e0;
    --app-pink: #ffc6da;
    --app-line: rgba(55, 78, 112, 0.14);
    --app-focus: rgba(63, 143, 216, 0.28);
}

body:not(.home-page) {
    min-height: 100vh;
    color: var(--app-ink);
    background:
        radial-gradient(circle at 10% 0%, rgba(126, 231, 224, 0.30), transparent 32rem),
        radial-gradient(circle at 94% 8%, rgba(255, 198, 218, 0.28), transparent 30rem),
        linear-gradient(180deg, #f7fcff 0%, var(--app-bg) 52%, #f9fbff 100%);
}

body:not(.home-page) .app-navbar {
    background: rgba(19, 36, 58, 0.88) !important;
    backdrop-filter: blur(18px) saturate(1.3);
}

body:not(.home-page) .card,
body:not(.home-page) .card-custom,
body:not(.home-page) .form-card,
body:not(.home-page) .work-card,
body:not(.home-page) .cert-card,
body:not(.home-page) .team-grid-card {
    border: 1px solid var(--app-line);
    border-radius: 18px;
    background: var(--app-surface);
    box-shadow: 0 8px 14px rgba(83, 127, 177, 0.12);
}
```

Continue with shared styles for `.container`, page headings, `.btn`, `.form-control`, `.form-select`, `.form-check-input`, `.table`, `.badge`, `.alert`, `.text-muted`, `.dropdown-menu`, `.pagination`, links, hover/focus, table overflow, and an inline empty state. Keep selectors scoped to `body:not(.home-page)` so `index.jsp` and `home.css` do not change.

- [ ] **Step 3: Add responsive and reduced-motion rules**

Use these structural rules:

```css
@media (max-width: 720px) {
    body:not(.home-page) .container { width: calc(100% - 32px); }
    body:not(.home-page) .row { --bs-gutter-x: 1rem; }
    body:not(.home-page) .table-responsive { border-radius: 14px; }
}

@media (prefers-reduced-motion: reduce) {
    body:not(.home-page) *,
    body:not(.home-page) *::before,
    body:not(.home-page) *::after {
        animation-duration: 0.001ms !important;
        transition-duration: 0.001ms !important;
        scroll-behavior: auto !important;
    }
}
```

- [ ] **Step 4: Add the asset fragment to all non-participant JSP pages**

Add `<%@ include file="includes/app-shell-assets.jspf" %>` immediately before `</head>` in:

`application_list.jsp`, `award_detail.jsp`, `award_list.jsp`, `award_manage.jsp`, `certificate_list.jsp`, `certificate_view.jsp`, `competition_add.jsp`, `competition_detail.jsp`, `competition_edit.jsp`, `competition_list.jsp`, `competition_works.jsp`, `forgot_password.jsp`, `invitation_list.jsp`, `login.jsp`, `login_admin.jsp`, `login_judge.jsp`, `news_add.jsp`, `news_detail.jsp`, `news_edit.jsp`, `news_list.jsp`, `news_manage.jsp`, `profile.jsp`, `register.jsp`, `score_input.jsp`, `score_list.jsp`, `submission_add.jsp`, `submission_detail.jsp`, `submission_list.jsp`, `team_create.jsp`, `team_detail.jsp`, `team_list.jsp`, and `user_manage.jsp`.

Do not add it to `index.jsp`; the participant home is intentionally preserved.

## Task 4: Verify template coverage and preserve business behavior

**Files:**
- Create: `src/test/java/com/poster/web/UnifiedFrontendTemplateTest.java`
- Modify: only individual JSP head tags if this test finds a missing include.

- [ ] **Step 1: Write the failing template coverage test**

```java
package com.poster.web;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertTrue;

class UnifiedFrontendTemplateTest {

    private static final Path JSP_ROOT = Paths.get("src", "main", "webapp", "jsp");

    @Test
    void everyNonParticipantJspLoadsTheSharedShell() throws Exception {
        try (Stream<Path> files = Files.list(JSP_ROOT)) {
            files.filter(path -> path.getFileName().toString().endsWith(".jsp"))
                    .filter(path -> !path.getFileName().toString().equals("index.jsp"))
                    .forEach(path -> {
                        try {
                            String source = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
                            assertTrue(source.contains("includes/app-shell-assets.jspf"),
                                    path.getFileName() + " is missing the shared app shell");
                        } catch (Exception error) {
                            throw new AssertionError(error);
                        }
                    });
        }
    }

    @Test
    void roleHomesExposeTheirPrimaryWorkflowLinks() throws Exception {
        String judge = read("judge_home.jsp");
        String admin = read("admin_home.jsp");
        assertTrue(judge.contains("/score?action=list"));
        assertTrue(judge.contains("/score?action=myScores"));
        assertTrue(admin.contains("/competition?action=add"));
        assertTrue(admin.contains("/admin/users"));
    }

    private static String read(String name) throws Exception {
        return new String(Files.readAllBytes(JSP_ROOT.resolve(name)), StandardCharsets.UTF_8);
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails before the bulk include changes**

Run: `.\mvnw.cmd -q -Dtest=UnifiedFrontendTemplateTest test`

Expected: FAIL because the new role pages and shared asset include do not exist yet.

- [ ] **Step 3: Add the include and run the focused test**

Run: `.\mvnw.cmd -q -Dtest=UnifiedFrontendTemplateTest test`

Expected: PASS with all JSP coverage checks and role-home link checks.

- [ ] **Step 4: Build the WAR and run all tests**

Run: `.\mvnw.cmd test`

Expected: PASS for all existing and new JUnit tests.

Run: `.\mvnw.cmd package -DskipTests`

Expected: BUILD SUCCESS and a generated WAR under `target/`.

## Task 5: Final visual and integration verification

**Files:**
- No planned source changes; only fix verified regressions in the files above if found.

- [ ] **Step 1: Check the changed-file boundary**

Run: `git diff --name-only HEAD~1..HEAD`

Confirm `src/main/webapp/jsp/index.jsp` and `src/main/webapp/css/home.css` are absent from the changed list.

- [ ] **Step 2: Check all route destinations in the JSP source**

Run: `rg -n "(score\?action=list|score\?action=myScores|competition\?action=add|admin/users|award\?action=manage|news\?action=manage)" src/main/webapp/jsp/admin_home.jsp src/main/webapp/jsp/judge_home.jsp`

Expected: every role dashboard primary/secondary workflow has a matching link.

- [ ] **Step 3: Run the static frontend checks**

Run: `rg -n "app-shell-assets.jspf" src/main/webapp/jsp --glob '*.jsp'`

Expected: every JSP except `index.jsp` has one include; `index.jsp` has none.

- [ ] **Step 4: Manually verify the four role states**

Open `/index` as anonymous, participant, judge and administrator. Confirm:

1. anonymous and participant users see the unchanged participant home;
2. judges see the judge dashboard with scoring links;
3. administrators see the operations dashboard with management links;
4. all other JSP pages share the same background, navigation, cards, forms, tables and responsive behavior.

- [ ] **Step 5: Commit the implementation**

```powershell
git add src/main/java/com/poster/controller/IndexServlet.java src/main/webapp/css/app-shell.css src/main/webapp/css/role-home.css src/main/webapp/jsp/admin_home.jsp src/main/webapp/jsp/judge_home.jsp src/main/webapp/jsp/includes/app-shell-assets.jspf src/main/webapp/jsp src/test/java/com/poster/web
git commit -m "feat: unify frontend and add role home dashboards"
```
