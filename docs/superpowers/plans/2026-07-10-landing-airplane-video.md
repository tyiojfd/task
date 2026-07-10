# Landing Airplane Video Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the blurry landing hero video with three高清 CloudFront airplane clips that loop in sequence, while scroll reveals stable centered feature cards and mouse movement keeps the existing subtle parallax/tilt feeling.

**Architecture:** Keep the existing React + GSAP `CinematicHero` component. ScrollTrigger will only control stage variables: card entrance, stable centered feature group selection, CTA focus, and CSS custom properties. Video playback will be decoupled from scroll: a playlist state switches clips on `ended`, uses `playbackRate = 1.5`, and starts once the hero is visible.

**Tech Stack:** React 18, Vite 5, GSAP 3.12.5, existing JSP/Tomcat static deployment under `src/main/webapp`.

## Global Constraints

- Do not introduce new frontend dependencies.
- Do not change JSP/backend system pages.
- Use the three CloudFront URLs directly; do not download videos into the repository.
- Preserve the current mouse movement effects: `--pointer-x`, `--pointer-y`, card tilt, title parallax, and spotlight follow.
- Avoid long-lived semi-transparent feature-card states like the user's Image #2.
- Ensure the user's Image #1-style clear centered composition appears and remains readable.
- Update `src/main/webapp/index.html` cache-busting query to a new value after rebuilding.

---

## File Structure

- `frontend/src/LandingApp.jsx` — owns the CloudFront video playlist constant and passes it to `CinematicHero`.
- `frontend/src/components/CinematicHero.jsx` — owns playlist playback, video lifecycle, ScrollTrigger stage variables, and feature-card visibility variables.
- `frontend/src/styles/portfolio-overrides.css` — defines stable centered feature-card presentation and preserves mouse-driven video-card tilt/parallax.
- `src/main/webapp/index.html` — Tomcat welcome page that loads fixed built assets with cache-busting query string.
- `src/main/webapp/js/landing-entry.js` — tracked built JS bundle actually loaded by Tomcat.
- `src/main/webapp/css/landing-entry.css` — tracked built CSS bundle actually loaded by Tomcat.

---

### Task 1: Add video playlist playback to the React hero

**Files:**
- Modify: `frontend/src/LandingApp.jsx`
- Modify: `frontend/src/components/CinematicHero.jsx`

**Interfaces:**
- Consumes: existing `CinematicHero` component.
- Produces: `CinematicHero({ videoSources, playbackRate = 1.5 })`, where `videoSources` is `string[]` and `playbackRate` is `number`.

- [ ] **Step 1: Update `frontend/src/LandingApp.jsx` to pass all three video URLs**

Replace the entire file with:

```jsx
import React from 'react'
import CinematicHero from './components/CinematicHero.jsx'

const AIRPLANE_VIDEOS = [
  'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_030107_874273ea-684a-4e90-bb96-8fdfde48d53d.mp4',
  'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260629_032424_3c9c2a9d-807b-4482-80e6-dd6d9dfd4545.mp4',
  'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260627_094019_4214ea73-b963-46a4-8327-61489192de99.mp4',
]

export default function LandingApp() {
  return (
    <div className="landing-root">
      <CinematicHero videoSources={AIRPLANE_VIDEOS} playbackRate={1.5} />
    </div>
  )
}
```

- [ ] **Step 2: Change the `CinematicHero` function signature and add playlist state**

In `frontend/src/components/CinematicHero.jsx`, change:

```jsx
export default function CinematicHero({ videoSrc }) {
```

to:

```jsx
export default function CinematicHero({ videoSources, playbackRate = 1.5 }) {
```

Then directly after the existing refs and `reducedMotion` declarations, insert:

```jsx
  const safeVideoSources = Array.isArray(videoSources) && videoSources.length > 0
    ? videoSources
    : ['./assets/landing/video/portfolio-hero.mp4']
  const [activeVideoIndex, setActiveVideoIndex] = useState(0)
  const activeVideoSrc = safeVideoSources[activeVideoIndex % safeVideoSources.length]
```

The top of the component should now include these exact declarations:

```jsx
export default function CinematicHero({ videoSources, playbackRate = 1.5 }) {
  const rootRef = useRef(null)
  const cardRef = useRef(null)
  const videoRef = useRef(null)
  const reducedMotion = useReducedMotion()
  const pointerRef = useRef({ x: 0, y: 0, tx: 0, ty: 0, raf: null })
  const safeVideoSources = Array.isArray(videoSources) && videoSources.length > 0
    ? videoSources
    : ['./assets/landing/video/portfolio-hero.mp4']
  const [activeVideoIndex, setActiveVideoIndex] = useState(0)
  const activeVideoSrc = safeVideoSources[activeVideoIndex % safeVideoSources.length]
```

- [ ] **Step 3: Add video playback lifecycle effect**

After the component state block and before the existing `useEffect` that creates `ScrollTrigger`, insert this effect:

```jsx
  useEffect(() => {
    const video = videoRef.current
    if (!video) return undefined

    video.playbackRate = playbackRate
    video.currentTime = 0

    if (reducedMotion) {
      video.pause()
      return undefined
    }

    const playPromise = video.play()
    if (playPromise && typeof playPromise.catch === 'function') {
      playPromise.catch(() => {
        // Browsers can defer autoplay until the first user gesture.
      })
    }

    return undefined
  }, [activeVideoSrc, playbackRate, reducedMotion])
```

- [ ] **Step 4: Add ended handler for playlist looping**

Before the `return (` block in `CinematicHero.jsx`, add:

```jsx
  const handleVideoEnded = () => {
    setActiveVideoIndex((index) => (index + 1) % safeVideoSources.length)
  }
```

- [ ] **Step 5: Update the `<video>` element**

In the `<video>` element, replace:

```jsx
              src={videoSrc}
              muted
              playsInline
              preload="auto"
              aria-hidden="true"
```

with:

```jsx
              key={activeVideoSrc}
              src={activeVideoSrc}
              muted
              playsInline
              preload="auto"
              aria-hidden="true"
              onEnded={handleVideoEnded}
```

- [ ] **Step 6: Run syntax/build check for the source change**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite build completes successfully and prints `✓ built`.

- [ ] **Step 7: Commit source playlist changes**

Run:

```bash
git add frontend/src/LandingApp.jsx frontend/src/components/CinematicHero.jsx
git commit -m "feat: add airplane video playlist"
```

Expected: commit succeeds.

---

### Task 2: Decouple scroll from video time and stabilize feature card stages

**Files:**
- Modify: `frontend/src/components/CinematicHero.jsx`

**Interfaces:**
- Consumes: `CARD_GROUPS`, `CARD_DIRS`, `rootRef`, `videoRef`, `reducedMotion` from the existing file.
- Produces: ScrollTrigger update logic that sets `--group-{index}-vis`, `--group-{index}-active`, `--scroll-rotate-x`, `--scroll-rotate-y`, `--scroll-shift-x`, `--scroll-shift-y`, `--final-focus`, `--content-alpha`, `--panel-width`, `--copy-width`, and `--secondary-width`.

- [ ] **Step 1: Remove the scroll-to-video-currentTime helper**

Inside the first `useEffect` in `CinematicHero.jsx`, delete this entire block:

```jsx
    const setProgress = (progress) => {
      const duration = video.duration || 12
      const sceneProgress = progress < 0.22
        ? progress * 0.86
        : progress < 0.52
          ? 0.19 + (progress - 0.22) * 1.18
          : progress < 0.78
            ? 0.544 + (progress - 0.52) * 1.08
            : 0.825 + (progress - 0.78) * 0.58
      const target = Math.min(duration * 0.96, Math.max(0, sceneProgress * duration))
      const diff = target - video.currentTime
      if (Math.abs(diff) > 0.035) video.currentTime += diff * 0.42
    }
```

- [ ] **Step 2: Replace the first `useEffect` body with stage-based scroll logic**

Replace the whole first `useEffect(() => { ... }, [reducedMotion])` block with:

```jsx
  useEffect(() => {
    const root = rootRef.current
    const card = cardRef.current
    const video = videoRef.current
    if (!root || !card || !video) return undefined

    if (reducedMotion) {
      video.pause()
      CARD_GROUPS.forEach((_, gi) => {
        root.style.setProperty(`--group-${gi}-vis`, gi === 0 ? '1' : '0')
        root.style.setProperty(`--group-${gi}-active`, gi === 0 ? '1' : '0')
        root.style.setProperty(`--group-${gi}-x`, '0px')
        root.style.setProperty(`--group-${gi}-y`, '0px')
        root.style.setProperty(`--group-${gi}-hue`, CARD_DIRS[gi].hue)
      })
      return undefined
    }

    const trigger = ScrollTrigger.create({
      trigger: root,
      start: 'top top',
      end: 'bottom bottom',
      scrub: 0.65,
      onUpdate: (self) => {
        const p = self.progress
        root.style.setProperty('--scroll-progress', p.toFixed(4))

        const settle = gsap.utils.clamp(0, 1, (p - 0.04) / 0.16)
        const pageTurn = Math.sin(settle * Math.PI)
        const rotateY = gsap.utils.interpolate(-8, 1.5, settle) + pageTurn * 2.2
        const rotateX = gsap.utils.interpolate(5, 0.8, settle)
        const shiftX = gsap.utils.interpolate(-1.4, 0, settle)
        const shiftY = gsap.utils.interpolate(1.2, 0, settle)

        root.style.setProperty('--scroll-rotate-x', `${rotateX.toFixed(2)}deg`)
        root.style.setProperty('--scroll-rotate-y', `${rotateY.toFixed(2)}deg`)
        root.style.setProperty('--scroll-scale', '1')
        root.style.setProperty('--scroll-shift-x', `${shiftX.toFixed(2)}vw`)
        root.style.setProperty('--scroll-shift-y', `${shiftY.toFixed(2)}vh`)

        const featureStart = 0.12
        const featureEnd = 0.82
        const featureProgress = gsap.utils.clamp(0, 0.9999, (p - featureStart) / (featureEnd - featureStart))
        const activeGroup = Math.min(CARD_GROUPS.length - 1, Math.floor(featureProgress * CARD_GROUPS.length))
        const featureVisible = p >= featureStart && p <= 0.9

        CARD_GROUPS.forEach((_, gi) => {
          const isActive = featureVisible && gi === activeGroup
          root.style.setProperty(`--group-${gi}-vis`, isActive ? '1' : '0')
          root.style.setProperty(`--group-${gi}-active`, isActive ? '1' : '0')
          root.style.setProperty(`--group-${gi}-x`, '0px')
          root.style.setProperty(`--group-${gi}-y`, '0px')
          root.style.setProperty(`--group-${gi}-hue`, CARD_DIRS[gi].hue)
        })

        const finalFocus = gsap.utils.clamp(0, 1, (p - 0.86) / 0.12)
        const contentAlpha = 1 - finalFocus
        const panelWidth = gsap.utils.interpolate(1120, 340, finalFocus)
        const copyWidth = gsap.utils.interpolate(680, 0, finalFocus)
        const secondaryWidth = gsap.utils.interpolate(118, 0, finalFocus)

        root.style.setProperty('--final-focus', finalFocus.toFixed(4))
        root.style.setProperty('--content-alpha', contentAlpha.toFixed(4))
        root.style.setProperty('--panel-width', `${panelWidth.toFixed(1)}px`)
        root.style.setProperty('--copy-width', `${copyWidth.toFixed(1)}px`)
        root.style.setProperty('--secondary-width', `${secondaryWidth.toFixed(1)}px`)
      },
    })

    return () => trigger.kill()
  }, [reducedMotion])
```

- [ ] **Step 3: Verify no `currentTime` scrub remains**

Run:

```bash
python - <<'PY'
from pathlib import Path
text = Path('frontend/src/components/CinematicHero.jsx').read_text(encoding='utf-8')
print('currentTime occurrences:', text.count('currentTime'))
print('setProgress occurrences:', text.count('setProgress'))
PY
```

Expected output:

```text
currentTime occurrences: 1
setProgress occurrences: 0
```

The remaining `currentTime` occurrence is the reset in the video playback lifecycle effect.

- [ ] **Step 4: Run build check**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite build completes successfully and prints `✓ built`.

- [ ] **Step 5: Commit scroll stabilization changes**

Run:

```bash
git add frontend/src/components/CinematicHero.jsx
git commit -m "feat: stabilize landing feature stages"
```

Expected: commit succeeds.

---

### Task 3: Update CSS so feature cards snap to the clear centered state

**Files:**
- Modify: `frontend/src/styles/portfolio-overrides.css`

**Interfaces:**
- Consumes: CSS variables `--group-vis`, `--group-hue`, `--group-active`, `--pointer-x`, `--pointer-y`, and the existing class names rendered by `CinematicHero`.
- Produces: feature-card groups that stay centered and readable when active, while video-card mouse tilt remains.

- [ ] **Step 1: Replace `.feature-strip` block**

In `frontend/src/styles/portfolio-overrides.css`, replace the `.feature-strip` block with:

```css
.feature-strip {
  position: absolute;
  left: 50%;
  top: 44%;
  z-index: 14;
  pointer-events: none;
  transform: translate3d(-50%, -50%, 78px);
  transform-origin: center center;
  width: min(760px, calc(100vw - clamp(2rem, 4vw, 4rem)));
}
```

- [ ] **Step 2: Replace `.feature-group` block**

Replace the `.feature-group` block with:

```css
.feature-group {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 100%;
  text-align: center;
  transform:
    translate3d(-50%, -50%, 0)
    scale(calc(.985 + var(--group-vis, 0) * .015));
  opacity: var(--group-vis, 0);
  transition: opacity .14s var(--ease-out-expo), transform .14s var(--ease-out-expo);
  will-change: opacity, transform;
}
```

- [ ] **Step 3: Replace `.feature-group__cards` block**

Replace the `.feature-group__cards` block with:

```css
.feature-group__cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
  justify-content: center;
}
```

- [ ] **Step 4: Adjust `.feature-strip__item` readability**

Inside the `.feature-strip__item` block, replace the existing `background`, `border`, and `box-shadow` declarations with:

```css
  background: linear-gradient(
    150deg,
    rgba(255,255,255,.94),
    hsla(var(--group-hue, 250), 55%, 96%, .88)
  );
  border: 1px solid hsla(var(--group-hue, 250), 45%, 68%, .22);
  box-shadow:
    0 .9rem 2.6rem rgba(22,26,52,.12),
    inset 0 1px 0 rgba(255,255,255,.82);
```

The rest of `.feature-strip__item` stays unchanged.

- [ ] **Step 5: Update responsive CSS for feature cards**

In the `@media (max-width: 920px)` block, replace:

```css
  .feature-group { width: min(540px, calc(100vw - 3rem)); }
  .feature-group__cards { flex-wrap: wrap; }
```

with:

```css
  .feature-strip { width: min(540px, calc(100vw - 3rem)); }
  .feature-group__cards { grid-template-columns: 1fr; }
```

In the `@media (max-width: 560px)` block, replace:

```css
  .feature-group { width: calc(100vw - 2.2rem); }
  .feature-group__cards { flex-direction: column; }
```

with:

```css
  .feature-strip { width: calc(100vw - 2.2rem); }
  .feature-group__cards { grid-template-columns: 1fr; }
```

- [ ] **Step 6: Verify mouse tilt CSS is still present**

Run:

```bash
python - <<'PY'
from pathlib import Path
text = Path('frontend/src/styles/portfolio-overrides.css').read_text(encoding='utf-8')
assert 'var(--pointer-x) * 4deg' in text
assert 'var(--pointer-y) * -3deg' in text
assert '.spotlight-card::after' in text
print('mouse tilt and spotlight CSS preserved')
PY
```

Expected output:

```text
mouse tilt and spotlight CSS preserved
```

- [ ] **Step 7: Run build check**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite build completes successfully and prints `✓ built`.

- [ ] **Step 8: Commit CSS stabilization changes**

Run:

```bash
git add frontend/src/styles/portfolio-overrides.css
git commit -m "style: center landing feature cards"
```

Expected: commit succeeds.

---

### Task 4: Sync Vite build output to Tomcat fixed assets and bump cache version

**Files:**
- Modify: `src/main/webapp/index.html`
- Modify: `src/main/webapp/js/landing-entry.js`
- Modify: `src/main/webapp/css/landing-entry.css`

**Interfaces:**
- Consumes: Vite build output under ignored `src/main/webapp/assets/landing-build/`.
- Produces: Tomcat-served fixed assets referenced by `src/main/webapp/index.html` using `?v=entry6`.

- [ ] **Step 1: Build the frontend**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite build completes successfully and writes hashed files under `src/main/webapp/assets/landing-build/`.

- [ ] **Step 2: Copy latest hashed JS/CSS into the tracked fixed asset names**

Run from repository root:

```bash
python - <<'PY'
from pathlib import Path
import shutil

build_dir = Path('src/main/webapp/assets/landing-build')
js_files = sorted(build_dir.glob('index-*.js'), key=lambda p: p.stat().st_mtime)
css_files = sorted(build_dir.glob('index-*.css'), key=lambda p: p.stat().st_mtime)
if not js_files:
    raise SystemExit('No built JS file found in src/main/webapp/assets/landing-build')
if not css_files:
    raise SystemExit('No built CSS file found in src/main/webapp/assets/landing-build')

Path('src/main/webapp/js').mkdir(parents=True, exist_ok=True)
Path('src/main/webapp/css').mkdir(parents=True, exist_ok=True)
shutil.copyfile(js_files[-1], 'src/main/webapp/js/landing-entry.js')
shutil.copyfile(css_files[-1], 'src/main/webapp/css/landing-entry.css')
print('copied js:', js_files[-1])
print('copied css:', css_files[-1])
PY
```

Expected output includes:

```text
copied js: src/main/webapp/assets/landing-build/index-...
copied css: src/main/webapp/assets/landing-build/index-...
```

- [ ] **Step 3: Restore fixed `index.html` references with cache version `entry6`**

Replace the entire `src/main/webapp/index.html` file with:

```html
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>大学生海报设计竞赛系统</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <script type="module" crossorigin src="./js/landing-entry.js?v=entry6"></script>
    <link rel="stylesheet" crossorigin href="./css/landing-entry.css?v=entry6">
    <link rel="stylesheet" href="./css/landing-glass-overrides.css?v=entry6">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
```

- [ ] **Step 4: Verify built bundle contains all three CloudFront URLs**

Run:

```bash
python - <<'PY'
from pathlib import Path
bundle = Path('src/main/webapp/js/landing-entry.js').read_text(encoding='utf-8', errors='replace')
urls = [
  'hf_20260629_030107_874273ea-684a-4e90-bb96-8fdfde48d53d.mp4',
  'hf_20260629_032424_3c9c2a9d-807b-4482-80e6-dd6d9dfd4545.mp4',
  'hf_20260627_094019_4214ea73-b963-46a4-8327-61489192de99.mp4',
]
for url in urls:
    assert url in bundle, url
print('all airplane videos present in landing bundle')
PY
```

Expected output:

```text
all airplane videos present in landing bundle
```

- [ ] **Step 5: Verify index uses `entry6` and fixed assets**

Run:

```bash
python - <<'PY'
from pathlib import Path
html = Path('src/main/webapp/index.html').read_text(encoding='utf-8')
assert './js/landing-entry.js?v=entry6' in html
assert './css/landing-entry.css?v=entry6' in html
assert './css/landing-glass-overrides.css?v=entry6' in html
print('index.html fixed asset references verified')
PY
```

Expected output:

```text
index.html fixed asset references verified
```

- [ ] **Step 6: Run Maven package to ensure webapp still packages**

Run:

```bash
mvn package
```

Expected: Maven exits successfully with `BUILD SUCCESS`.

- [ ] **Step 7: Commit deployed asset sync**

Run:

```bash
git add src/main/webapp/index.html src/main/webapp/js/landing-entry.js src/main/webapp/css/landing-entry.css
git commit -m "build: update landing airplane assets"
```

Expected: commit succeeds.

---

### Task 5: Verify the landing page behavior in the running app

**Files:**
- No source changes expected.

**Interfaces:**
- Consumes: built Tomcat assets from Task 4.
- Produces: manual verification evidence that the landing page works at the active context path.

- [ ] **Step 1: Start or restart the project server**

If using the Maven Jetty plugin, run:

```bash
mvn jetty:run
```

Expected: server starts on port `8080` and serves context `/task`.

If using IntelliJ/Tomcat, stop and restart the `Tomcat 9.0.115` run configuration, then open the context it serves, commonly:

```text
http://localhost:8080/task_war_exploded/
```

- [ ] **Step 2: Verify the live index page references `entry6`**

Run one of these depending on the active context.

For IntelliJ/Tomcat:

```bash
python - <<'PY'
from urllib.request import urlopen, Request
html = urlopen(Request('http://localhost:8080/task_war_exploded/', headers={'Cache-Control':'no-cache'}), timeout=5).read().decode('utf-8', 'replace')
assert 'landing-entry.js?v=entry6' in html
assert 'landing-entry.css?v=entry6' in html
print('live Tomcat index uses entry6')
PY
```

For Maven Jetty:

```bash
python - <<'PY'
from urllib.request import urlopen, Request
html = urlopen(Request('http://localhost:8080/task/', headers={'Cache-Control':'no-cache'}), timeout=5).read().decode('utf-8', 'replace')
assert 'landing-entry.js?v=entry6' in html
assert 'landing-entry.css?v=entry6' in html
print('live Jetty index uses entry6')
PY
```

Expected output for the chosen command confirms the live page uses `entry6`.

- [ ] **Step 3: Browser manual verification**

Open the live landing page and press `Ctrl+F5`. Verify these exact behaviors:

```text
1. The hero video area loads a clear CloudFront airplane clip.
2. Scrolling down first shows the original 3D card entrance/turning feeling.
3. A feature card group such as “赛事发布” appears clearly in the center like the user's Image #1.
4. The feature cards do not remain stuck in a faded, unreadable state like the user's Image #2.
5. While stopped at the clear centered state, moving the mouse still causes subtle background/video-card tilt and spotlight movement.
6. After one airplane clip finishes, the next CloudFront clip starts; after the third clip, the first clip starts again.
```

- [ ] **Step 4: Commit verification note only if source changes were required**

If verification required no source changes, do not commit. If a small fix was needed during verification, commit it with:

```bash
git add frontend/src src/main/webapp/index.html src/main/webapp/js/landing-entry.js src/main/webapp/css/landing-entry.css
git commit -m "fix: polish landing airplane playback"
```

Expected: repository contains only intentional landing changes.

---

## Self-Review

**Spec coverage:**
- Three CloudFront videos: Task 1 and Task 4.
- Sequential loop 1 → 2 → 3 → 1: Task 1.
- Faster complete airplane playback: Task 1 uses `playbackRate={1.5}` and removes scroll scrub in Task 2.
- Preserve original scroll flip entrance: Task 2 keeps `--scroll-rotate-x`, `--scroll-rotate-y`, and settle interpolation.
- Avoid Image #2 semi-transparent stuck state: Task 2 stage logic and Task 3 centered CSS.
- Preserve mouse movement: Task 3 verification checks pointer tilt and spotlight CSS; Task 2 does not remove pointer effect.
- Cache bust: Task 4 changes `entry6`.

**Placeholder scan:** No TBD/TODO/placeholders are present.

**Type consistency:** `videoSources`, `playbackRate`, `activeVideoSrc`, `safeVideoSources`, and `handleVideoEnded` names are consistent across tasks.
