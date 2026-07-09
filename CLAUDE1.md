# 进入页（Landing Page）前端独立文档

> 负责进入页的 AI/开发者请只读本文档，不要修改业务系统 JSP 或 Java 代码。

---

## 架构概览

进入页是一个独立的 React 单页应用，部署时打包为静态资源放入 JSP 项目的 `webapp/` 目录。  
进入页和 JSP 系统之间通过路由分离：

```
/task_war_exploded/           → React 进入页（index.html）
/task_war_exploded/index      → JSP 系统首页（IndexServlet）
/task_war_exploded/competition → JSP 竞赛模块
...
```

进入页代码放在项目根目录的 `frontend/` 下。

---

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | React 18 |
| 构建 | Vite 5（输出到 `../src/main/webapp/`） |
| 动效 | GSAP + ScrollTrigger（滚动驱动视频进度） |
| 样式 | CSS（无预处理器），BEM 命名 |
| 字体 | Google Fonts — Noto Sans SC |

---

## 目录结构

```
frontend/
├── package.json
├── vite.config.js
├── index.html                  # Vite 开发/构建模板
└── src/
    ├── main.jsx                # React 入口
    ├── LandingApp.jsx          # 页面总控，定义 6 屏内容
    ├── context.js              # 运行时检测 Tomcat context path
    ├── components/
    │   ├── GlassNav.jsx        # 固定顶部玻璃导航栏
    │   └── ScrubPage.jsx       # 滚动驱动视频播放核心组件
    └── styles/
        ├── landing.css         # 全局变量、reset、玻璃导航样式
        └── portfolio-overrides.css  # 视差滚动 + 玻璃卡片样式
```

构建产物输出到 `src/main/webapp/`：

```
src/main/webapp/
├── index.html
├── js/landing/           ← AuthFilter 已放行 /js/ 路径
├── css/landing/          ← AuthFilter 已放行 /css/ 路径
├── assets/landing/
│   ├── video/
│   │   ├── portfolio-hero.mp4    ← 12 秒蓝天花卉视频（~1.3MB）
│   │   └── hero.mp4              ← 备用渐变视频
│   └── images/
│       └── poster-0{1..6}.svg    ← 6 张海报占位 SVG
└── assets/landing-build/  ← Vite 构建原始输出（js/ 和 css/ 是手动同步的副本）
```

---

## 核心设计：滚动驱动视频播放（Video Scrub）

### 原理

固定一个 `<video>` 元素覆盖整个视口。  
用 **GSAP ScrollTrigger** 监听页面滚动进度，把进度映射到 `video.currentTime`。  
用 `requestAnimationFrame` 做 lerp 插值，避免直接设置 `currentTime` 的卡顿感。

### 页面结构（6 屏）

| 屏 | 内容 | 视频帧位置 |
|----|------|-----------|
| 1 | **Hero** — "海报竞赛 CREATIVE" + 描述 + 进入按钮 | 0–2s |
| 2 | **项目意义** — 3 个痛点卡片 | 2–4s |
| 3 | **竞赛流程** — 7 步横向流程标签 | 4–6s |
| 4 | **四种角色** — 管理员/评委/队长/队员 | 6–8s |
| 5 | **作品展示** — 6 张海报缩略图 | 8–10s |
| 6 | **最终 CTA** — "准备好了吗" + 进入系统 + 快速链接 | 10–12s |

每屏内容用 **暗色玻璃卡片** 包裹（`backdrop-filter: blur`），确保在视频上可读。

---

## 开发命令

```bash
cd frontend/

# 安装依赖（首次）
npm install

# 构建（输出到 src/main/webapp/）
npm run build

# 本地开发（Vite dev server，不依赖 Tomcat）
npm run dev
```

构建后需要手动同步：

```bash
# 复制 JS 到 AuthFilter 放行的 /js/ 路径
cp src/main/webapp/assets/landing-build/index-*.js src/main/webapp/js/landing/

# 复制 CSS 到 AuthFilter 放行的 /css/ 路径
cp src/main/webapp/assets/landing-build/index-*.css src/main/webapp/css/landing/

# 更新 index.html 中引用的 hash
# 手动编辑 src/main/webapp/index.html 的 script 和 link 标签
```

---

## 部署关键点

### 路由

`LandingServlet.java` 映射到 `@WebServlet("")`，精确拦截根路径，内部 forward 到 `/index.html`。

### Filter 放行

`AuthFilter.isPublicResource()` 中必须放行以下路径：

- `/`、空字符串、`/index.html`（根路径放行，React 页面是公开资源）
- `/js/`、`/css/`、`/assets/`（静态资源路径）
- `/images/`、`/uploads/`

### EncodingFilter

**已修复**：移除了 `response.setContentType("text/html;charset=UTF-8")`，否则会把 JS/CSS 的 MIME 类型覆盖成 `text/html`，导致浏览器拒绝执行 ES module 脚本。

### Web.xml 欢迎页

```xml
<welcome-file-list>
    <welcome-file>index.html</welcome-file>
</welcome-file-list>
```

### Context Path

进入页用 `context.js` 在运行时检测 Tomcat context path（`/task_war_exploded` 或 `/task` 等），所有指向 JSP 系统的链接都自动拼接正确路径。

---

## 已知注意事项

1. **每次 `npm run build` 后**，`src/main/webapp/index.html` 会被 Vite 覆盖。必须手动修改 hash 指向 `/js/landing/` 和 `/css/landing/` 路径。
2. **视频文件** `portfolio-hero.mp4` 在 `src/main/webapp/assets/landing/video/`，构建不涉及它，直接放入即可。
3. **海报 SVG** 以 `.svg` 后缀保存，浏览器按 SVG 解析。不要用 `.jpg` 后缀存 SVG 内容。
4. **Tomcat 重启后** EncodingFilter 需要重新编译才能生效，否则所有静态资源 Content-Type 仍是 `text/html`。
5. `ReactDOM.createRoot` 需要从 `react-dom/client` 做 named import：`import { createRoot } from 'react-dom/client'`。
6. 不要在 `LandingApp.jsx` 中导出变量后再被其子组件循环引用，会导致 TDZ 错误。公共工具放在独立的 `context.js`。

---

## 替换视频

如需更换进入页视频，替换以下文件即可：

```
src/main/webapp/assets/landing/video/portfolio-hero.mp4
```

建议：12–20 秒、720p+、无音频、H.264、≤15MB。
视频会被滚动驱动播放，画面变化越丰富效果越好。
