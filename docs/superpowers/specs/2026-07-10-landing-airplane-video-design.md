# Landing 高清飞机视频滚动展示设计

## 背景

当前进入页使用 React + GSAP ScrollTrigger 实现一个视频卡片 hero。用户反馈原视频来自截屏，画面偏糊；同时滚动时功能卡片会停在半透明过渡态，出现文字不清楚、画面不稳定的问题。

用户提供 3 个 CloudFront 高清飞机视频，分别表示飞机从不同方向飞出的片段，希望滚动进入页面时能稳定展示类似参考图 1 的完整 hero 画面，并避免参考图 2 那种半透明、看不清的中间态。

## 目标

1. 使用用户提供的 3 个 CloudFront 高清视频替换当前本地低清/截屏视频。
2. 三个视频按顺序播放：视频 1 → 视频 2 → 视频 3 → 视频 1 循环。
3. 飞机视频在稳定展示状态下自动快速播放，保证飞机飞出过程完整可见。
4. 保留原有滚动时的视频卡片翻转入场效果。
5. 功能卡片组必须在标准中心位置清晰显示，避免长时间半透明过渡态。
6. 保留当前鼠标移动时背景/视频卡片轻微晃动、tilt、parallax、光斑跟随的感觉。
7. 更新入口资源版本号，避免浏览器缓存旧 JS/CSS。

## 非目标

1. 不重做整套 landing 视觉风格。
2. 不引入新的前端依赖。
3. 不改变 JSP 后台系统页面。
4. 不把视频下载到本地仓库，直接使用 CloudFront URL。

## 视频资源

```text
1. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_030107_874273ea-684a-4e90-bb96-8fdfde48d53d.mp4
2. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_032424_3c9c2a9d-807b-4482-80e6-dd6d9dfd4545.mp4
3. https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260627_094019_4214ea73-b963-46a4-8327-61489192de99.mp4
```

## 交互设计

### 滚动控制

滚动不再直接控制视频 `currentTime`。滚动只负责：

1. 视频卡片从初始状态翻转进入；
2. 到达标准展示阶段后稳定在中心构图；
3. 功能卡片组按滚动阶段切换。

这样用户滚动快慢不会导致飞机视频跳帧，也不会让功能卡片长时间停在半透明状态。

### 视频播放

`CinematicHero` 维护一个视频播放列表和当前视频索引。

- 当当前视频播放结束后，切换到下一个 URL；
- 第 3 个视频结束后回到第 1 个；
- 视频设置 `muted`、`playsInline`、`preload="auto"`；
- 播放速度使用 `playbackRate = 1.5`，使飞机飞出更快但过程完整。

### 功能卡片显示

当前逻辑会通过连续的 `intro * (1 - fade)` 产生长时间半透明状态。新逻辑改为阶段式显示：

- 当前阶段对应的功能卡片组：`opacity = 1`；
- 非当前阶段：`opacity = 0`；
- 切换只保留很短的 fade/scale 过渡；
- 卡片固定在中心标准位置，不再大幅从四周漂移。

这保证参考图 1 状态稳定出现，参考图 2 状态尽量只作为极短过渡，不会停留。

### 鼠标交互

保留现有鼠标移动效果：

- `--pointer-x` / `--pointer-y` 继续更新；
- 视频卡片继续轻微 `rotateX` / `rotateY`；
- 标题和视频层保留轻微 parallax；
- spotlight 光斑继续跟随鼠标；
- 功能卡片不做大幅鼠标位移，避免文字晃动影响阅读。

因此标准展示状态不是死板静止，而是中心稳定 + 鼠标轻微动态。

## 实现范围

主要修改：

1. `frontend/src/LandingApp.jsx`
   - 传入 3 个 CloudFront 视频 URL，而不是单个本地视频。

2. `frontend/src/components/CinematicHero.jsx`
   - 接收 `videoSources`；
   - 新增当前视频索引状态；
   - 视频结束后自动切换；
   - 移除滚动 scrub 视频 `currentTime` 的逻辑；
   - 保留 ScrollTrigger 更新滚动变量和鼠标变量；
   - 改造功能卡片显示逻辑为阶段式稳定显示。

3. `frontend/src/styles/portfolio-overrides.css`
   - 调整功能卡片组位置与透明度过渡；
   - 保留视频卡片鼠标 tilt；
   - 降低半透明中间态停留感。

4. `src/main/webapp/index.html`
   - 更新资源 query 版本号，例如 `entry6`。

5. 构建产物
   - 运行前端构建后，同步实际被 JSP/Tomcat 使用的 `src/main/webapp/js/landing-entry.js` 和 `src/main/webapp/css/landing-entry.css`。

## 验证标准

1. 打开 `/task_war_exploded/` 或当前 Tomcat context 后，进入页加载正常。
2. 滚动到功能展示区域时，能清晰看到类似参考图 1 的标准画面。
3. 功能卡片不会长时间停在参考图 2 那种半透明状态。
4. 飞机视频自动播放，能按 1 → 2 → 3 → 1 循环。
5. 停在标准画面时，鼠标移动仍有原来的轻微晃动/tilt/光斑感觉。
6. Ctrl+F5 后浏览器加载新版资源。

## 自检

- 无 TBD/TODO。
- 范围集中在 landing 进入页。
- 不改变后台业务功能。
- 鼠标动态和稳定展示不是矛盾关系：滚动决定标准中心状态，鼠标只在小范围内做动态偏移。
