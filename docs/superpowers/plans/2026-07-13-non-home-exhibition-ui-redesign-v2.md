# 非首页视觉升级 V2 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 消除首页与非首页之间的视觉断层——为所有非首页 JSP 加入阴影层次、玻璃态导航、Hero 标题区，去掉随机图片和紫色残留，让内容页与首页拥有同一水准的视觉品质。

**Architecture:** 两层 CSS 改造（`app-shell.css` 基础组件 + `app-pages.css` 页面家族），然后按 P0→P1→P2 优先级逐页清理 JSP 标记。不改任何后端代码。

**Tech Stack:** JSP, Bootstrap 5, Font Awesome 6.4, CSS custom properties, 现有 Maven/JUnit 模板测试。

## 全局约束

- 禁止修改：`index.jsp`、`home.css`、`admin_home.jsp`、`judge_home.jsp`、`role-home.css`
- 禁止修改任何 Java 后端代码（Servlet/Service/DAO/Model/Filter）
- 禁止修改任何 URL、表单字段名、权限判断
- 禁止使用紫色（`#6C5CE7`、`#A29BFE`、`#667eea`、`#764ba2` 及其变体）
- 禁止使用渐变文字（`background-clip: text`）
- 禁止 `repeating-linear-gradient`
- 不使用竞赛无关的硬编码随机图片作为卡片封面
- 所有动画遵守 `prefers-reduced-motion`
- 保持现有 Bootstrap 5 功能不变

---

### Task 1: app-shell.css — 阴影系统 + 玻璃态导航

**文件:**
- 修改: `src/main/webapp/css/app-shell.css`

- [ ] **Step 1: 在 `:root` 块中新增阴影 CSS 变量**

在现有的 `:root` 块末尾（`--app-focus` 之后）插入：

```css
--shadow-xs: 0 1px 2px rgba(21, 50, 71, 0.04);
--shadow-sm: 0 2px 8px rgba(21, 50, 71, 0.06);
--shadow-md: 0 4px 16px rgba(21, 50, 71, 0.08);
--shadow-lg: 0 8px 32px rgba(21, 50, 71, 0.11);
--shadow-xl: 0 16px 48px rgba(21, 50, 71, 0.14);
```

- [ ] **Step 2: 导航栏改为玻璃态**

把导航栏规则（约第 46-80 行）改为玻璃态。替换 `.app-navbar` 和 `.app-navbar .container` 相关规则：

```css
body:not(.home-page) .app-navbar {
    min-height: 68px;
    background: rgba(21, 50, 71, 0.88) !important;
    backdrop-filter: blur(16px) saturate(1.1);
    -webkit-backdrop-filter: blur(16px) saturate(1.1);
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: var(--shadow-md);
}

body:not(.home-page) .app-navbar::after {
    content: "";
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: var(--app-yellow);
}
```

同时去掉原来的 `border-bottom: 3px solid var(--app-yellow);` 改用 `::after` 伪元素确保它在玻璃模糊层的上方。

- [ ] **Step 3: 卡片和面板加阴影**

替换卡片规则（约第 148-159 行）：

```css
body:not(.home-page) .card,
body:not(.home-page) .card-custom,
body:not(.home-page) .form-card,
body:not(.home-page) .work-card,
body:not(.home-page) .cert-card,
body:not(.home-page) .team-grid-card,
body:not(.home-page) .stat-card {
    border: 1px solid rgba(21, 50, 71, 0.07);
    border-radius: 12px;
    background: var(--app-surface);
    box-shadow: var(--shadow-sm);
    transition: box-shadow 200ms ease, transform 200ms ease;
}

body:not(.home-page) .card:hover,
body:not(.home-page) .card-custom:hover,
body:not(.home-page) .work-card:hover,
body:not(.home-page) .cert-card:hover,
body:not(.home-page) .team-grid-card:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
}
```

- [ ] **Step 4: 表单控件加微阴影**

在 `.form-control` 规则中添加（约第 182 行后）：

```css
body:not(.home-page) .form-control,
body:not(.home-page) .form-select {
    box-shadow: var(--shadow-xs);
}
```

- [ ] **Step 5: 按钮统一微阴影**

在 `.btn` 规则中添加（约第 221 行）：

```css
body:not(.home-page) .btn {
    box-shadow: var(--shadow-xs);
}
body:not(.home-page) .btn:hover {
    box-shadow: var(--shadow-sm);
}
```

- [ ] **Step 6: 表格容器加阴影**

```css
body:not(.home-page) .table-responsive {
    border: 1px solid rgba(21, 50, 71, 0.06);
    border-radius: 10px;
    box-shadow: var(--shadow-sm);
    background: var(--app-surface);
}
```

- [ ] **Step 7: 空状态容器加阴影**

```css
body:not(.home-page) .empty-state,
body:not(.home-page) .empty-container {
    border: 1px solid rgba(21, 50, 71, 0.06);
    box-shadow: var(--shadow-xs);
}
```

- [ ] **Step 8: 运行现有测试确认不破坏现有合约**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest="ExhibitionUiTemplateTest,UnifiedFrontendTemplateTest" test
```

预期：PASS（所有断言仍然通过）。

- [ ] **Step 9: 提交**

```bash
git add src/main/webapp/css/app-shell.css
git commit -m "feat: add shadow system and glass navbar to app-shell"
```

---

### Task 2: app-pages.css — Hero 区 + 新卡片系统 + 玻璃登录卡

**文件:**
- 修改: `src/main/webapp/css/app-pages.css`

- [ ] **Step 1: 在文件顶部新增 Hero 区组件样式**

在现有内容之前插入：

```css
/* ── Page Hero ── */
body.app-page:not(.home-page) .app-page-hero {
    position: relative;
    margin: 0 0 32px;
    padding: 36px 0;
    border-radius: 12px;
    background: linear-gradient(135deg, var(--app-ink) 0%, #1a4058 100%);
    box-shadow: var(--shadow-md);
    overflow: hidden;
}

body.app-page:not(.home-page) .app-page-hero::before {
    content: "";
    position: absolute;
    inset: 0;
    opacity: 0.06;
    background-image: radial-gradient(circle at 20% 50%, #fff 1px, transparent 1px);
    background-size: 40px 40px;
}

body.app-page:not(.home-page) .app-page-hero-inner {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 24px;
    padding: 0 28px;
}

body.app-page:not(.home-page) .app-page-hero-copy {
    min-width: 0;
}

body.app-page:not(.home-page) .app-page-hero .app-page-kicker {
    color: var(--app-yellow);
    margin-bottom: 10px;
}

body.app-page:not(.home-page) .app-page-hero h1,
body.app-page:not(.home-page) .app-page-hero h2 {
    color: #fff;
    margin: 0;
}

body.app-page:not(.home-page) .app-page-hero .app-page-summary {
    color: rgba(255, 255, 255, 0.66);
    max-width: 560px;
    margin-top: 10px;
    line-height: 1.7;
}

body.app-page:not(.home-page) .app-page-hero-stat {
    display: inline-flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    padding: 16px 22px;
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 10px;
    color: #fff;
    background: rgba(255, 255, 255, 0.06);
    white-space: nowrap;
}

body.app-page:not(.home-page) .app-page-hero-stat strong {
    font-size: 2rem;
    font-weight: 850;
    line-height: 1;
    color: var(--app-yellow);
}

body.app-page:not(.home-page) .app-page-hero-stat span {
    font-size: 0.78rem;
    font-weight: 700;
    color: rgba(255, 255, 255, 0.6);
    text-transform: uppercase;
    letter-spacing: 0.06em;
}
```

- [ ] **Step 2: 增加 Hero 移动端响应式**

在文件末尾的 `@media (max-width: 720px)` 块中添加：

```css
body.app-page:not(.home-page) .app-page-hero {
    padding: 28px 0;
}

body.app-page:not(.home-page) .app-page-hero-inner {
    flex-direction: column;
    align-items: flex-start;
    padding: 0 20px;
}

body.app-page:not(.home-page) .app-page-hero-stat {
    flex-direction: row;
    gap: 10px;
    padding: 10px 14px;
}

body.app-page:not(.home-page) .app-page-hero-stat strong {
    font-size: 1.5rem;
}
```

- [ ] **Step 3: 重写竞赛卡片样式 — 纯排版，无图片依赖**

替换现有的 `.competition-card` 和 `.app-catalog-art` 规则（约第 116-206 行）：

```css
/* Competition card — typographic, no forced image */
body.app-page-catalog:not(.home-page) .competition-card {
    position: relative;
    display: flex;
    flex-direction: column;
    min-height: 180px;
    overflow: hidden;
    border: 1px solid rgba(21, 50, 71, 0.07);
    border-left: 4px solid var(--app-sea);
    border-radius: 10px;
    background: var(--app-surface);
    box-shadow: var(--shadow-sm);
    transition: border-color 200ms ease, box-shadow 200ms ease, transform 200ms ease;
}

body.app-page-catalog:not(.home-page) .competition-card:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
}

/* Status-colored left border */
body.app-page-catalog:not(.home-page) .competition-card.status-open {
    border-left-color: var(--app-sea);
}
body.app-page-catalog:not(.home-page) .competition-card.status-active {
    border-left-color: var(--app-blue);
}
body.app-page-catalog:not(.home-page) .competition-card.status-ended {
    border-left-color: #94a3ac;
}
body.app-page-catalog:not(.home-page) .competition-card.status-cancelled {
    border-left-color: #cb7f8b;
}

body.app-page-catalog:not(.home-page) .competition-card .card-body {
    display: flex;
    flex-direction: column;
    flex: 1;
    padding: 20px 22px 18px;
}

body.app-page-catalog:not(.home-page) .competition-card .card-body::before {
    content: "竞赛";
    order: -1;
    margin-bottom: 8px;
    display: inline-block;
    align-self: flex-start;
    border: 1px solid var(--app-rule);
    border-radius: 4px;
    padding: 2px 8px;
    color: var(--app-ink-soft);
    font-size: 0.68rem;
    font-weight: 800;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    background: var(--app-surface-soft);
}

body.app-page-catalog:not(.home-page) .competition-card .card-title {
    margin-bottom: 8px;
    color: var(--app-ink);
    font-size: 1.2rem;
    font-weight: 850;
    line-height: 1.25;
}

body.app-page-catalog:not(.home-page) .competition-card .card-text {
    color: var(--app-ink-soft);
    font-size: 0.9rem;
    line-height: 1.55;
    margin-bottom: 12px;
    flex: 1;
}

body.app-page-catalog:not(.home-page) .competition-card .status-badge {
    position: absolute;
    top: 18px;
    right: 18px;
    border-radius: 6px;
    font-size: 0.74rem;
    font-weight: 750;
}

/* 移除旧的图片相关样式 */
body.app-page-catalog:not(.home-page) .app-catalog-art {
    display: none;
}

body.app-page-catalog:not(.home-page) .app-catalog-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}
```

- [ ] **Step 4: 新增玻璃登录卡片样式**

在文件末尾添加：

```css
/* ── Auth: glass card ── */
body.app-page-auth:not(.home-page) {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    background: var(--app-paper);
}

body.app-page-auth:not(.home-page) .container {
    max-width: 880px;
    width: min(880px, calc(100% - 32px));
}

body.app-page-auth:not(.home-page) .app-auth-glass {
    display: grid;
    grid-template-columns: 1fr 1.1fr;
    overflow: hidden;
    border: 1px solid rgba(21, 50, 71, 0.08);
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.72);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    box-shadow: var(--shadow-lg);
}

body.app-page-auth:not(.home-page) .app-auth-brand {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 48px 36px;
    color: #fff;
    background: linear-gradient(160deg, var(--app-ink) 0%, #1e4260 100%);
}

body.app-page-auth:not(.home-page) .app-auth-brand h1 {
    color: #fff;
    margin: 0 0 12px;
    font-size: 1.8rem;
    font-weight: 850;
}

body.app-page-auth:not(.home-page) .app-auth-brand p {
    color: rgba(255, 255, 255, 0.7);
    line-height: 1.7;
    margin: 0;
}

body.app-page-auth:not(.home-page) .app-auth-form {
    padding: 48px 36px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

body.app-page-auth:not(.home-page) .app-auth-form h2 {
    margin: 0 0 24px;
    font-size: 1.35rem;
}

body.app-page-auth:not(.home-page) .app-auth-form .btn-primary {
    width: 100%;
    min-height: 48px;
    margin-top: 8px;
    font-size: 1rem;
}

body.app-page-auth:not(.home-page) .app-auth-links {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 18px;
    font-size: 0.88rem;
}

body.app-page-auth:not(.home-page) .app-auth-links a {
    color: var(--app-blue);
    font-weight: 700;
}

@media (max-width: 720px) {
    body.app-page-auth:not(.home-page) .app-auth-glass {
        grid-template-columns: 1fr;
    }

    body.app-page-auth:not(.home-page) .app-auth-brand {
        padding: 32px 24px;
    }

    body.app-page-auth:not(.home-page) .app-auth-form {
        padding: 28px 24px;
    }
}
```

- [ ] **Step 5: 替换旧的 auth bridge rules**

删除或注释掉旧的 auth bridge rules 中与新样式冲突的部分（约第 546-731 行），保留 modal、switch-card 等非冲突规则，去掉 `bg-grid`、`bg-orb` 隐藏等不再需要的规则。

- [ ] **Step 6: 运行测试**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest="ExhibitionUiTemplateTest,UnifiedFrontendTemplateTest" test
```

预期：PASS。

- [ ] **Step 7: 提交**

```bash
git add src/main/webapp/css/app-pages.css
git commit -m "feat: add hero sections, typographic competition cards, and glass auth layout"
```

---

### Task 3: P0 — 竞赛列表页改造

**文件:**
- 修改: `src/main/webapp/jsp/competition_list.jsp`

- [ ] **Step 1: 删除随机图片数组**

删除第 25 行：
```jsp
String[] posterSamples = {"poster-1.png", "poster-2.png", "poster-3.png", "poster-4.png", "poster-5.png", "poster-6.png"};
```

- [ ] **Step 2: 将页面标题区改为 Hero**

将第 44-57 行的 `<header class="app-page-head">` 替换为：

```jsp
<header class="app-page-hero">
    <div class="app-page-hero-inner">
        <div class="app-page-hero-copy">
            <p class="app-page-kicker">竞赛目录</p>
            <h1>探索赛事</h1>
            <p class="app-page-summary">从主题、时间和参赛规则开始，找到适合你的海报创作现场。</p>
        </div>
        <div class="app-page-hero-stat">
            <strong><%= competitionCount %></strong>
            <span>场赛事</span>
        </div>
        <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-light" style="border-radius:8px;font-weight:800;">
                <i class="fas fa-plus me-1"></i>发布竞赛
            </a>
        <% } %>
    </div>
</header>
```

- [ ] **Step 3: 去掉竞赛卡片中的图片链接**

将第 98-138 行的竞赛卡片循环中的图片 `<a class="app-catalog-art">` 删除，并为每个卡片添加状态 class：

```jsp
<% for (Competition comp : competitions) {
    String statusColorClass;
    if (comp.getStatus() != null && comp.getStatus() == 1) {
        statusColorClass = "status-open";
        statusLabel = "报名中";
        statusClass = "bg-success";
    } else if (comp.getStatus() != null && comp.getStatus() == 2) {
        statusColorClass = "status-active";
        statusLabel = "进行中";
        statusClass = "bg-primary";
    } else if (comp.getStatus() != null && comp.getStatus() == 3) {
        statusColorClass = "status-ended";
        statusLabel = "已结束";
        statusClass = "bg-secondary";
    } else {
        statusColorClass = "status-cancelled";
        statusLabel = "已取消";
        statusClass = "bg-danger";
    }
%>
    <article class="competition-card <%= statusColorClass %>">
        <!-- 不渲染图片，纯排版 -->
        <div class="card-body">
            ...
        </div>
    </article>
<% } %>
```

- [ ] **Step 4: 运行测试确认编译**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest="ExhibitionUiTemplateTest" test
```

- [ ] **Step 5: 提交**

```bash
git add src/main/webapp/jsp/competition_list.jsp
git commit -m "feat: typographic competition cards with hero header, no forced images"
```

---

### Task 4: P0 — 登录/注册/忘记密码页重做

**文件:**
- 修改: `src/main/webapp/jsp/login.jsp`
- 修改: `src/main/webapp/jsp/login_admin.jsp`
- 修改: `src/main/webapp/jsp/login_judge.jsp`
- 修改: `src/main/webapp/jsp/register.jsp`
- 修改: `src/main/webapp/jsp/forgot_password.jsp`

- [ ] **Step 1: 重做 login.jsp**

将 `login.jsp` 改为玻璃卡片左右分栏布局。关键结构：

```jsp
<body class="app-page app-page-auth">
    <div class="container">
        <div class="app-auth-glass">
            <!-- 左侧品牌区 -->
            <div class="app-auth-brand">
                <h1>🎨 海报竞赛系统</h1>
                <p>大学生海报设计竞赛平台。发布赛事、组建团队、提交作品、专业评审——一站式竞赛管理。</p>
            </div>
            <!-- 右侧表单区 -->
            <div class="app-auth-form">
                <h2>登录</h2>
                <form method="post" action="${pageContext.request.contextPath}/login">
                    <div class="mb-3">
                        <label class="form-label">用户名</label>
                        <input type="text" name="username" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">密码</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger py-2"><%= request.getAttribute("error") %></div>
                    <% } %>
                    <button type="submit" class="btn btn-primary">登录</button>
                </form>
                <div class="app-auth-links">
                    <a href="${pageContext.request.contextPath}/register">注册账号</a>
                    <a href="${pageContext.request.contextPath}/forgot-password">忘记密码？</a>
                </div>
            </div>
        </div>
    </div>
</body>
```

**注意：** 保留原有的 JSP 导入（User、Role、session 逻辑），只改 HTML 结构和 class。保留原有的 `request.getAttribute("error")` 处理。

- [ ] **Step 2: 重做 login_admin.jsp**

与 login.jsp 相同结构，但品牌区文字改为"管理员登录"：

```html
<div class="app-auth-brand">
    <h1>🛡️ 管理员登录</h1>
    <p>竞赛系统管理中心。发布赛事、管理用户、设置获奖——后台运营入口。</p>
</div>
<div class="app-auth-form">
    <h2>管理员登录</h2>
    <!-- 表单同上 -->
</div>
```

- [ ] **Step 3: 重做 login_judge.jsp**

品牌区文字改为"评委登录"：

```html
<div class="app-auth-brand">
    <h1>⭐ 评委登录</h1>
    <p>评审工作台。查看作品、评分打分、撰写评语——专业评审入口。</p>
</div>
<div class="app-auth-form">
    <h2>评委登录</h2>
    <!-- 表单同上 -->
</div>
```

- [ ] **Step 4: 重做 register.jsp**

与 login.jsp 相同玻璃卡片结构，品牌区写"加入我们"，表单区包含所有注册字段（用户名、密码、确认密码、姓名、邮箱等）。**保留原有的 Servlet action 和 input name 属性不变。**

- [ ] **Step 5: 重做 forgot_password.jsp**

玻璃卡片布局，品牌区写"找回密码"。

- [ ] **Step 6: 运行测试**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest="ExhibitionUiTemplateTest,UnifiedFrontendTemplateTest" test
```

- [ ] **Step 7: 提交**

```bash
git add src/main/webapp/jsp/login.jsp src/main/webapp/jsp/login_admin.jsp src/main/webapp/jsp/login_judge.jsp src/main/webapp/jsp/register.jsp src/main/webapp/jsp/forgot_password.jsp
git commit -m "feat: glass-card auth pages with brand panel"
```

---

### Task 5: P0 — 获奖名单 + 新闻列表清理

**文件:**
- 修改: `src/main/webapp/jsp/award_list.jsp`
- 修改: `src/main/webapp/jsp/news_list.jsp`

- [ ] **Step 1: award_list.jsp — 删除嵌入式紫色 `<style>` 块**

找到文件中的 `<style>` 标签块，删除所有紫色相关规则（`#6C5CE7`、`#A29BFE`、`#667eea`、`#764ba2`、渐变背景等）。保留布局相关规则但改用 `app-pages.css` 中的 CSS 变量。为 `<body>` 添加 `app-page app-page-catalog` class。将标题区改为 `.app-page-head` 结构。

- [ ] **Step 2: news_list.jsp — 删除嵌入式紫色 `<style>` 块**

同上操作。找到 `<style>` 块中的紫色/渐变规则，删除。为 `<body>` 添加 `app-page app-page-catalog` class。

- [ ] **Step 3: 运行测试**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -Dtest="ExhibitionUiTemplateTest" test
```

预期：PASS。`innerPageStylesAvoidKnownTemplateSlop` 测试确认无紫色残留。

- [ ] **Step 4: 提交**

```bash
git add src/main/webapp/jsp/award_list.jsp src/main/webapp/jsp/news_list.jsp
git commit -m "fix: remove embedded purple styles from award and news list pages"
```

---

### Task 6: P1 — 详情页重构

**文件:**
- 修改: `src/main/webapp/jsp/competition_detail.jsp`
- 修改: `src/main/webapp/jsp/submission_detail.jsp`
- 修改: `src/main/webapp/jsp/news_detail.jsp`
- 修改: `src/main/webapp/jsp/award_detail.jsp`

- [ ] **Step 1: competition_detail.jsp 使用 detail layout**

将主要内容区域包裹在 `.app-detail-layout` 中：
- `.app-detail-main`：竞赛信息、描述、参赛状态
- `.app-detail-rail`：元数据（年度、截止日期、状态、参赛人数）

保留所有现有 JSP 逻辑变量（`isAdmin`、`hasJoined`、`userTeam` 等）。保留所有表单 action 和链接 URL。

- [ ] **Step 2: submission_detail.jsp 使用 detail layout**

- `.app-detail-main`：作品图片（大图）+ 描述
- `.app-detail-rail`：队伍信息、竞赛信息、提交时间、评分、操作按钮

保留评分/评语/获奖数据加载逻辑。

- [ ] **Step 3: news_detail.jsp 和 award_detail.jsp**

同样包裹在 detail layout 中。award_detail.jsp 保留证书/获奖等级相关逻辑。

- [ ] **Step 4: 提交**

```bash
git add src/main/webapp/jsp/competition_detail.jsp src/main/webapp/jsp/submission_detail.jsp src/main/webapp/jsp/news_detail.jsp src/main/webapp/jsp/award_detail.jsp
git commit -m "feat: restructure detail pages with app-detail-layout"
```

---

### Task 7: P1 — 列表页升级

**文件:**
- 修改: `src/main/webapp/jsp/submission_list.jsp`
- 修改: `src/main/webapp/jsp/team_list.jsp`
- 修改: `src/main/webapp/jsp/score_list.jsp`
- 修改: `src/main/webapp/jsp/certificate_list.jsp`
- 修改: `src/main/webapp/jsp/competition_works.jsp`

- [ ] **Step 1: submission_list.jsp**

确保 body class 为 `app-page app-page-gallery`。作品卡片使用 `.app-art-card` / `.app-art-grid` 结构。图片使用缩略图接口 `type=thumb`。

- [ ] **Step 2: team_list.jsp**

body class 为 `app-page app-page-catalog`。队伍卡片改用 `.competition-card` 风格（彩色左侧竖条、纯排版）。

- [ ] **Step 3: score_list.jsp**

body class 为 `app-page app-page-gallery`（评分列表本质是评审队列）。

- [ ] **Step 4: certificate_list.jsp 和 competition_works.jsp**

统一添加 family class，确保阴影和卡片风格一致。

- [ ] **Step 5: 提交**

```bash
git add src/main/webapp/jsp/submission_list.jsp src/main/webapp/jsp/team_list.jsp src/main/webapp/jsp/score_list.jsp src/main/webapp/jsp/certificate_list.jsp src/main/webapp/jsp/competition_works.jsp
git commit -m "feat: upgrade list pages with page-family classes and shadow system"
```

---

### Task 8: P1 — 表单与工作台页升级

**文件:**
- 修改: `src/main/webapp/jsp/team_create.jsp`
- 修改: `src/main/webapp/jsp/team_detail.jsp`
- 修改: `src/main/webapp/jsp/profile.jsp`
- 修改: `src/main/webapp/jsp/score_input.jsp`
- 修改: `src/main/webapp/jsp/submission_add.jsp`

- [ ] **Step 1: team_detail.jsp**

使用 detail layout（`.app-detail-main` 放队伍信息/Tab，`.app-detail-rail` 放操作面板）。保留所有 Modal（编辑队伍、邀请队员）。保留所有 JS 函数和权限判断。

- [ ] **Step 2: team_create.jsp**

使用 workbench layout（`.app-workbench`），表单分区用 `.app-form-section`。保留竞赛选择卡片和子类动态加载逻辑。

- [ ] **Step 3: profile.jsp**

使用 workbench layout。头像区、基本信息表单、密码修改各放一个 `.app-form-section`。

- [ ] **Step 4: score_input.jsp**

使用 workbench layout。左侧放作品预览，右侧放评分控件。

- [ ] **Step 5: submission_add.jsp**

使用 workbench layout。上传区、表单区分区。

- [ ] **Step 6: 提交**

```bash
git add src/main/webapp/jsp/team_create.jsp src/main/webapp/jsp/team_detail.jsp src/main/webapp/jsp/profile.jsp src/main/webapp/jsp/score_input.jsp src/main/webapp/jsp/submission_add.jsp
git commit -m "feat: restructure form and workbench pages with sectioned layouts"
```

---

### Task 9: P2 — 其余页面统一清理

**文件:**
- 修改: `src/main/webapp/jsp/competition_add.jsp`
- 修改: `src/main/webapp/jsp/competition_edit.jsp`
- 修改: `src/main/webapp/jsp/news_add.jsp`
- 修改: `src/main/webapp/jsp/news_edit.jsp`
- 修改: `src/main/webapp/jsp/news_manage.jsp`
- 修改: `src/main/webapp/jsp/award_manage.jsp`
- 修改: `src/main/webapp/jsp/certificate_view.jsp`
- 修改: `src/main/webapp/jsp/user_manage.jsp`
- 修改: `src/main/webapp/jsp/invitation_list.jsp`
- 修改: `src/main/webapp/jsp/application_list.jsp`

- [ ] **Step 1: 逐页添加 body family class**

按页面类型分配：
- 表单/管理页 → `app-page app-page-workbench`
- 列表页 → `app-page app-page-catalog` 或 `app-page-gallery`

不修改任何后端逻辑。

- [ ] **Step 2: 清理嵌入式样式**

逐页检查 `<style>` 标签，删除任何紫色 token。让 `app-pages.css` 的 bridge rules 处理样式。

- [ ] **Step 3: 运行全量测试**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q test
```

预期：全部 PASS，0 失败。

- [ ] **Step 4: 提交**

```bash
git add src/main/webapp/jsp/competition_add.jsp src/main/webapp/jsp/competition_edit.jsp src/main/webapp/jsp/news_add.jsp src/main/webapp/jsp/news_edit.jsp src/main/webapp/jsp/news_manage.jsp src/main/webapp/jsp/award_manage.jsp src/main/webapp/jsp/certificate_view.jsp src/main/webapp/jsp/user_manage.jsp src/main/webapp/jsp/invitation_list.jsp src/main/webapp/jsp/application_list.jsp
git commit -m "feat: apply page-family classes to all remaining non-home JSPs"
```

---

### Task 10: 最终验证

- [ ] **Step 1: 确认保护文件未被修改**

```bash
cd /c/Users/Lenovo/Desktop/java/task && git diff --name-only HEAD~9..HEAD -- src/main/webapp/jsp/index.jsp src/main/webapp/css/home.css src/main/webapp/jsp/admin_home.jsp src/main/webapp/jsp/judge_home.jsp src/main/webapp/css/role-home.css
```

预期：空输出（这些文件在本次所有 commit 中均未被修改）。

- [ ] **Step 2: 确认紫色已清理**

```bash
cd /c/Users/Lenovo/Desktop/java/task && grep -rn "#6C5CE7\|#A29BFE\|#667eea\|#764ba2" src/main/webapp/jsp/ src/main/webapp/css/app-shell.css src/main/webapp/css/app-pages.css || echo "无紫色残留"
```

预期："无紫色残留"。

- [ ] **Step 3: 确认无渐变文字**

```bash
cd /c/Users/Lenovo/Desktop/java/task && grep -rn "background-clip:\s*text" src/main/webapp/css/app-shell.css src/main/webapp/css/app-pages.css || echo "无渐变文字"
```

预期："无渐变文字"。

- [ ] **Step 4: 运行全量测试**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q test
```

预期：BUILD SUCCESS，全部测试通过。

- [ ] **Step 5: 打包 WAR**

```bash
cd /c/Users/Lenovo/Desktop/java/task && JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package
```

预期：BUILD SUCCESS，生成 `target/task-1.0-SNAPSHOT.war`。

- [ ] **Step 6: 最终提交（如有未提交变更）**

```bash
git status
git add -A
git commit -m "chore: final verification and cleanup for v2 redesign"
```
