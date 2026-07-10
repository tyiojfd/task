# Frontend Optimization Design

**Date:** 2026-07-08  
**Project:** 大学生海报设计竞赛系统  
**Primary goal:** 为课程答辩和项目展示新增一个高级动态进入页，同时统一优化现有 JSP 系统前端质感。  
**Approved direction:** React 动态进入页 + 现有 JSP 系统轻量统一美化。

## 1. Context

当前系统已经完成竞赛发布、报名组队、作品提交、评委评分、获奖设置、新闻公告、电子奖状等核心业务功能。技术栈为 JSP + Servlet + MySQL + Bootstrap 5，现有业务页面分散在 `src/main/webapp/jsp/` 下，入口业务首页由 `IndexServlet` 转发到 `src/main/webapp/jsp/index.jsp`。

本次前端优化不重写后端业务，也不做全站 React 迁移。React 只用于项目根路径的动态进入页；正式竞赛系统继续使用现有 JSP/Servlet 架构，并通过公共样式和重点页面改造减少“普通后台管理系统感”。

## 2. Product and Visual Positioning

进入页定位为“高级创意展馆 + 青春活力气息”。它应像大学生海报创意展的数字入口，而不是后台管理系统首页。

设计关键词：

- 高级：沉浸式视频、克制但有层次的光影、清晰排版、稳定节奏。
- 青春：鲜活渐变色、作品漂浮、创作热情、竞赛参与感。
- 创意：海报墙、滚动叙事、动态视觉、作品展示氛围。

明确避免：

- Bootstrap 默认灰底和后台卡片堆叠。
- 过重的数据大屏、蓝色网格、模板化粒子背景。
- 动画抢内容、影响阅读或影响“进入系统”按钮可用性。
- 幼稚卡通风。

## 3. Routing and Architecture

### 3.1 User-facing routes

Recommended route behavior:

```text
/task/ or project root
  -> React landing page at src/main/webapp/index.html

/task/index
  -> existing IndexServlet
  -> src/main/webapp/jsp/index.jsp

/task/competition?action=list
  -> existing competition hall
```

The existing `web.xml` already declares `index.html` as the welcome file, so the React build should output an `index.html` into `src/main/webapp/`. The original system homepage remains accessible through `/index` and should not be overwritten.

### 3.2 Frontend build structure

Add a small React/Vite frontend dedicated to the landing page:

```text
frontend/
├── package.json
├── vite.config.js
├── index.html
└── src/
    ├── LandingApp.jsx
    ├── components/
    │   ├── HeroSection.jsx
    │   ├── MeaningSection.jsx
    │   ├── FlowSection.jsx
    │   ├── RoleShowcase.jsx
    │   ├── PosterGallery.jsx
    │   └── FinalCTA.jsx
    ├── hooks/
    │   ├── useMouseParallax.js
    │   └── useGsapScroll.js
    └── styles/
        └── landing.css
```

Build output target:

```text
src/main/webapp/
├── index.html
└── assets/landing-build/...
```

This keeps the React landing page independent from the JSP app.

## 4. Landing Page Content Design

### 4.1 Hero section: immersive entrance

Purpose: Create the first impression for答辩展示.

Content:

- Project title: `大学生海报设计竞赛系统`
- Supporting line: `让创意被看见，让竞赛流程数字化`
- Primary CTA: `进入竞赛系统` -> `${contextPath}/index` or `/task/index`
- Secondary CTA: `了解项目亮点` -> scroll to meaning/features section
- Local background video with dark overlay
- Floating poster images layered above the video

Interaction:

- Video autoplays muted and loops; the first screen must feel like a moving video poster wall, not a static banner.
- Floating posters respond to mouse movement with parallax.
- Selected poster layers can use controlled 3D flip / card-turn motion when entering, hovering, or switching focus.
- Main title and CTA enter through a GSAP timeline.
- Hero still works if video cannot play by showing a poster fallback image.

### 4.2 Meaning section: why this project matters

Purpose: Explain project value clearly for teachers and reviewers.

Narrative points:

- Traditional poster competitions often rely on scattered报名、线下沟通、人工统计和分散评审。
- The system provides one digital workflow from publication to certificate viewing.
- It improves organization efficiency and gives student work a more visible展示空间。

Interaction:

- Text blocks reveal on scroll.
- Important phrases receive subtle highlight motion.
- Background poster texture or image layer moves at a slower scroll speed.

### 4.3 Workflow section: full competition chain

Display the core flow:

```text
注册登录 -> 创建队伍 -> 报名竞赛 -> 提交作品 -> 评委评分 -> 获奖公示 -> 查看奖状
```

Design:

- Use a horizontal or diagonal timeline rather than default cards.
- Each step has a short label and one sentence.
- ScrollTrigger lights up steps in sequence.

### 4.4 Role showcase section

Show system roles and responsibilities:

- 管理员：竞赛发布、用户管理、新闻管理、获奖设置。
- 评委：作品查看、评分、评语。
- 队长：创建队伍、邀请队员、报名参赛、提交作品。
- 队员：接受邀请、查看作品、点赞分享、查看奖状。

Design:

- Avoid identical icon-card grids.
- Prefer a stage-like layout: one active role panel with role tabs or flowing bands.
- On scroll or hover, the active role changes with a smooth transition.

### 4.5 Poster gallery section

Purpose: Make the page feel like a creative exhibition.

Content:

- Local poster or design-related images.
- Staggered image wall with varied aspect ratios.
- CTA block embedded near the end.

Interaction:

- Images move at different speeds during scroll.
- Hover adds slight scale, tilt, and focus shadow.
- Reduced motion users see a static gallery.

### 4.6 Final CTA section

Content:

- `准备进入完整竞赛流程？`
- `进入竞赛系统` button
- Optional quick links: 登录、注册、竞赛大厅、获奖名单

Design:

- Strong but clean final composition.
- CTA must remain easy to identify and click.

## 5. Asset Strategy

The user chose local assets for both images and video.

Recommended asset structure:

```text
src/main/webapp/assets/landing/
├── video/
│   ├── hero.mp4
│   └── hero-poster.jpg
└── images/
    ├── poster-01.jpg
    ├── poster-02.jpg
    ├── poster-03.jpg
    ├── poster-04.jpg
    ├── poster-05.jpg
    └── poster-06.jpg
```

Guidelines:

- Hero video should be short, loopable, muted, and ideally 5–15 MB.
- Total landing assets should remain small enough to protect the final source zip size limit.
- Images should be compressed; target 200–500 KB each where possible.
- Use credible poster/design/campus/creative exhibition imagery.
- Every meaningful image needs alt text.

If suitable assets are downloaded from the web, store source notes in a small `assets/landing/README.md` so usage can be explained during答辩.

## 6. Animation System

Use GSAP for advanced animation. If scroll-linked animation is used, add ScrollTrigger.

### 6.1 Page load timeline

Sequence:

1. Background video fades in.
2. Floating posters slide and fade into position with stagger.
3. Main title enters from below.
4. Subtitle and CTA appear after the title.

Use transform properties (`x`, `y`, `scale`, `rotation`) and `autoAlpha`; avoid animating layout-heavy properties like `top`, `left`, `width`, or `height`.

### 6.2 Mouse parallax

Implementation concept:

- Track normalized mouse position inside the hero section.
- Apply different movement multipliers to foreground posters, light layers, and background masks.
- Smooth updates with GSAP quick setters or tweens.
- Return elements to neutral position on mouse leave.

Movement must be subtle enough to feel premium, not game-like.

### 6.3 Scroll animation

Use section-scoped animations:

- Meaning text reveal.
- Workflow step activation.
- Role showcase transitions.
- Poster gallery parallax.
- Final CTA entrance.

Avoid a uniform fade-up on every section. Each animation should match the content it reveals.

### 6.4 Reduced motion and performance

Required:

- Respect `prefers-reduced-motion: reduce`.
- Disable mouse parallax for reduced motion.
- Simplify or skip scroll timelines for reduced motion.
- Keep content visible by default; animations must enhance, not gate visibility.
- Do not rely on animations to make hidden content readable.

## 7. JSP System Visual Optimization

The landing page creates the first impression, but the system behind it also needs a consistent visual upgrade.

### 7.1 Shared style assets

Add:

```text
src/main/webapp/assets/css/app-theme.css
src/main/webapp/assets/js/app-ui.js
```

`app-theme.css` should define:

- Brand colors and gradients.
- Page backgrounds.
- Navbar styling.
- Buttons.
- Cards and panels.
- Forms and tables.
- Status badges.
- Empty states.
- Responsive spacing.

`app-ui.js` may provide small progressive enhancements:

- Active nav highlighting.
- Lightweight scroll reveal for JSP pages.
- Button ripple or hover state, if performance-safe.

### 7.2 Priority JSP pages

Optimize in this order:

1. `jsp/index.jsp`
2. `jsp/competition_list.jsp`
3. `jsp/competition_detail.jsp`
4. `jsp/team_list.jsp`
5. `jsp/team_detail.jsp`
6. `jsp/submission_list.jsp`
7. `jsp/submission_detail.jsp`
8. `jsp/score_input.jsp`
9. `jsp/award_list.jsp`
10. `jsp/certificate_view.jsp`
11. `jsp/login.jsp`
12. `jsp/register.jsp`
13. `jsp/profile.jsp`

### 7.3 Optimization rules

- Preserve existing server-side logic and URLs.
- Do not introduce React into JSP business pages for this phase.
- Reduce duplicated inline CSS over time by moving reusable rules into `app-theme.css`.
- Keep management pages efficient and readable; they can be polished without becoming flashy.
- Public-facing pages such as awards, works, competitions, and certificates can be more exhibition-like.

## 8. Integration Plan Boundaries

This design intentionally excludes:

- Full React SPA migration.
- Rewriting Servlet controllers as JSON APIs.
- Rebuilding all pages from scratch.
- Changing database schema.
- Changing core business logic.

This design includes:

- React landing page at project root.
- Local video and local images.
- GSAP animation system.
- A shared CSS layer for JSP visual consistency.
- Targeted JSP page polishing.

## 9. Verification Criteria

### 9.1 Build verification

- `npm run build` succeeds in the React frontend.
- Built files appear under `src/main/webapp` as expected.
- `mvn clean package` succeeds.

### 9.2 Route verification

- Visiting `/task/` opens the React landing page.
- Clicking `进入竞赛系统` opens `/task/index`.
- Existing login, register, competition, team, work, score, award, news, and certificate routes still work.

### 9.3 Visual verification

- Hero video loads and loops.
- Fallback poster image appears if video fails.
- Mouse parallax works on desktop.
- Scroll animation works without content disappearing.
- Mobile layout does not overflow.
- Reduced motion mode remains readable and usable.

### 9.4 Performance verification

- Landing page assets are compressed.
- Video file size is controlled.
- No large unused libraries are shipped.
- Animations use transforms and opacity rather than layout properties.

## 10. Open Decisions Resolved

- Landing page location: project root welcome page.
- System entry after landing: existing `/index` route.
- React scope: landing page only.
- JSP system: keep architecture, apply visual polish.
- Resource strategy: local video and local images.
- Visual style:高级创意展馆 with青春活力.
- Primary scenario:答辩展示优先.
- Main anti-reference:普通后台管理系统感.
