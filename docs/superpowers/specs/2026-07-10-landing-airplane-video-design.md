# Landing 飞机冲击式翻书进入页设计

## 背景

当前进入页使用 React + GSAP ScrollTrigger 实现视频卡片 hero。上一轮已把低清本地视频替换方向调整为 3 个 CloudFront 高清飞机视频，但滚动逻辑仍存在两个问题：

1. 滚动还在直接控制视频 `currentTime`，飞机画面容易被拖拽跳帧；
2. 功能卡片采用连续透明度过渡，用户停在中间滚动位置时可能出现半透明、文字不清晰的状态。

用户进一步明确希望下滑像翻书一样“一页一页翻”，且书翻过去后下一页内容必须清晰展示。视频时长约 8 秒，用户实测 16 倍速最有冲击力。最终设计采用“飞机先高速冲出，像气流掀开书页，然后下一页翻入并清晰落定”的编排。

## 目标

1. 使用用户提供的 3 个 CloudFront 高清飞机视频作为唯一视频池。
2. 每次翻页动作由一个飞机视频驱动：飞机先以 16x 从头快速播放，随后页面翻转。
3. 滚动呈现翻书感：当前页翻走，下一页翻入。
4. 每次翻页完成后，下一页内容必须完整、清晰、稳定展示。
5. 保留原有视频卡片/背景随鼠标移动轻微倾斜、parallax、光斑跟随的感觉。
6. 不再让滚动 scrub 视频进度，避免画面跳帧。
7. 更新构建产物和入口缓存版本，确保浏览器加载新效果。

## 非目标

1. 不重做后台 JSP 系统页面。
2. 不引入新的前端依赖。
3. 不下载 CloudFront 视频到仓库。
4. 不把功能展示改成多页面路由；仍然是单个 landing hero 内的滚动叙事。
5. 不让功能卡片长期跟随鼠标大幅晃动，避免影响阅读。

## 视频资源

```text
1. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_030107_874273ea-684a-4e90-bb96-8fdfde48d53d.mp4
2. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_032424_3c9c2a9d-807b-4482-80e6-dd6d9dfd4545.mp4
3. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260627_094019_4214ea73-b963-46a4-8327-61489192de99.mp4
```

视频按翻页动作循环使用：

```text
第 1 页 → 第 2 页：视频 1
第 2 页 → 第 3 页：视频 2
第 3 页 → 第 4 页：视频 3
第 4 页 → 第 5 页：视频 1
第 5 页 → 第 6 页：视频 2
```

## 交互编排

### 整体节奏

每个滚动段对应一次翻页动作。推荐节奏：

```text
0% - 24%：当前页稳定清晰展示
24% - 44%：飞机视频 16x 从头爆发播放，形成冲击感
36% - 78%：当前页像被气流掀起一样翻走，下一页翻入
78% - 100%：下一页清晰落定
```

视频略早于翻页开始，让飞机冲出成为翻页原因，而不是翻页后的装饰。

### 翻书模型

功能展示从原来的“多个卡片组淡入淡出”改为“page stack”：

- 每个 `CARD_GROUPS` 项是一页；
- 当前页和下一页在翻页阶段同时参与；
- 当前页从 `rotateY(0deg)` 翻到约 `rotateY(-82deg)`；
- 下一页从 `rotateY(72deg)` 翻到 `rotateY(0deg)`；
- 翻完后下一页 `opacity: 1`、`filter: blur(0)`、文字完全不透明；
- 其他无关页隐藏，不参与视觉叠加。

### 视频播放

`CinematicHero` 维护 `activeVideoIndex` 和 `lastTriggeredTurnRef`。

滚动进入新的翻页段时：

1. 根据翻页序号选择 `videoSources[turnIndex % videoSources.length]`；
2. 切换 `activeVideoSrc`；
3. 视频 `currentTime = 0`；
4. 设置 `playbackRate = 16`；
5. 调用 `video.play()`。

视频元素保持：

```html
muted
playsInline
preload="auto"
aria-hidden="true"
```

稳定展示阶段可以让视频继续停留/播放，不要求慢速循环；主视觉冲击来自每次翻页开始时的 16x 爆发。

### 鼠标交互

保留现有鼠标移动效果：

- `--pointer-x` / `--pointer-y` 继续平滑更新；
- 视频卡片继续轻微 `rotateX` / `rotateY`；
- 标题和视频微文案保留轻微 parallax；
- spotlight 光斑继续跟随鼠标；
- 功能卡片页本身只保留非常小的深度感，不大幅跟随鼠标，保证文字稳定。

## 实现范围

### `frontend/src/LandingApp.jsx`

- 保留 3 个 CloudFront URL 常量；
- 传给 `CinematicHero`：

```jsx
<CinematicHero videoSources={AIRPLANE_VIDEOS} playbackRate={16} />
```

### `frontend/src/components/CinematicHero.jsx`

- 接收 `videoSources` 和 `playbackRate = 16`；
- 移除滚动 scrub 视频 `currentTime` 的逻辑；
- 根据 ScrollTrigger 进度计算：
  - `pageIndex`：当前稳定页；
  - `nextPageIndex`：翻入页；
  - `turnProgress`：当前页翻转进度；
  - `turnIndex`：用于触发视频爆发的翻页序号；
- 当进入新的翻页动作时切换并重播对应视频；
- 给根节点写入 CSS 变量：
  - `--page-{i}-vis`；
  - `--page-{i}-turn`；
  - `--page-{i}-incoming`；
  - `--page-{i}-active`；
  - `--scroll-rotate-x` / `--scroll-rotate-y` / `--scroll-shift-x` / `--scroll-shift-y`；
- 保留 pointer effect 的 `useEffect`。

### `frontend/src/styles/portfolio-overrides.css`

- `.feature-strip` 改为翻书舞台，设置 `perspective`；
- `.feature-group` 改为绝对重叠的 page；
- active page 清晰、实底、可读；
- outgoing/incoming page 使用 3D rotateY、阴影、纸张边缘高光；
- 降低半透明中间态停留：只有正在翻的页会有短暂透明度变化；
- 响应式下保持单页清晰展示。

### `src/main/webapp/index.html` 和构建产物

- 运行 Vite build；
- 同步最新构建到：
  - `src/main/webapp/js/landing-entry.js`
  - `src/main/webapp/css/landing-entry.css`
- `index.html` 使用固定资源路径并增加新缓存版本，例如 `entry7`。

## 验证标准

1. 打开进入页后，首屏正常加载。
2. 下滑时出现明显翻书/翻页感，而不是简单淡入淡出。
3. 飞机视频在每次翻页开始前或开始时以 16x 从头快速播放，形成冲击感。
4. 翻页完成后，下一页内容完整、清晰、稳定展示。
5. 页面不会停在文字半透明、看不清的状态。
6. 鼠标移动时，视频卡片/背景仍有轻微倾斜和视差。
7. 三个 CloudFront 视频都能在构建后的 bundle 中找到。
8. 前端构建成功，Maven 打包成功。
9. 浏览器强刷后加载新的 `entry7` 资源。

## 自检

- 无 TBD/TODO。
- 范围集中在 React/GSAP landing 进入页。
- 用户的 16x 视频要求已写入目标、交互和实现范围。
- “飞机驱动翻页”和“翻完内容清晰展示”不矛盾：视频负责转场冲击，page stack 负责稳定清晰落定。
- 保留鼠标倾斜效果，但限制文字页大幅移动，保证可读性。
