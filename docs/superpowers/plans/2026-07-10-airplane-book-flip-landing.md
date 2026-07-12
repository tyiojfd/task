# Airplane Book Flip Landing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a landing-page interaction where 16x airplane video bursts drive book-like page turns, and every settled page displays clear readable feature content while preserving mouse tilt/parallax.

**Architecture:** Keep the existing React + GSAP `CinematicHero` component as the interaction owner. ScrollTrigger maps scroll progress into page index and turn progress; video playback is triggered imperatively when a new turn segment starts and is not scrubbed by scroll. CSS renders feature groups as a stacked 3D book-page stage, while the video card retains pointer-driven tilt.

**Tech Stack:** React 18, Vite 5, GSAP 3.12.5, existing Tomcat/JSP static deployment under `src/main/webapp`.

## Global Constraints

- Use only the three CloudFront video URLs from the spec.
- Set airplane burst playback speed to `16`.
- Do not introduce new frontend dependencies.
- Do not change JSP/backend system pages.
- Do not download CloudFront videos into the repository.
- Do not let feature text stay in a long-lived semi-transparent unreadable state.
- Preserve `--pointer-x` / `--pointer-y` mouse movement tilt/parallax and spotlight behavior.
- Do not make git commits unless explicitly requested by the user.

---

## File Structure

- `frontend/src/LandingApp.jsx` — owns the three CloudFront video URLs and passes `playbackRate={16}` into `CinematicHero`.
- `frontend/src/components/CinematicHero.jsx` — owns video burst triggering, scroll-to-page calculations, page CSS variables, and pointer tracking.
- `frontend/src/styles/portfolio-overrides.css` — renders feature groups as clear stacked 3D book pages and preserves video-card tilt.
- `src/main/webapp/index.html` — Tomcat entry page that points to fixed cache-busted landing assets.
- `src/main/webapp/js/landing-entry.js` — fixed deployed JS bundle copied from the latest Vite build.
- `src/main/webapp/css/landing-entry.css` — fixed deployed CSS bundle copied from the latest Vite build.

---

### Task 1: Implement airplane-burst page-turn logic in React

**Files:**
- Modify: `frontend/src/LandingApp.jsx`
- Modify: `frontend/src/components/CinematicHero.jsx`

**Interfaces:**
- Consumes: `CinematicHero` component, `CARD_GROUPS`, `CARD_DIRS`, GSAP `ScrollTrigger`, existing pointer tracking effect.
- Produces: `CinematicHero({ videoSources: string[], playbackRate?: number })`, CSS variables `--page-{i}-vis`, `--page-{i}-turn`, `--page-{i}-incoming`, `--page-{i}-active`, and no scroll-based video `currentTime` scrub.

- [ ] **Step 1: Update `LandingApp.jsx` playback speed to 16**

Replace `frontend/src/LandingApp.jsx` with:

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
      <CinematicHero videoSources={AIRPLANE_VIDEOS} playbackRate={16} />
    </div>
  )
}
```

- [ ] **Step 2: Add turn constants below `CARD_DIRS` in `CinematicHero.jsx`**

Insert this block after the `CARD_DIRS` declaration:

```jsx
const TURN_COUNT = CARD_GROUPS.length - 1
const TURN_VIDEO_START = 0.24
const TURN_PAGE_START = 0.36
const TURN_PAGE_END = 0.78
```

- [ ] **Step 3: Replace the component state area**

Inside `CinematicHero`, replace the current `safeVideoSources`, `activeVideoIndex`, and `activeVideoSrc` declarations with:

```jsx
  const safeVideoSources = Array.isArray(videoSources) && videoSources.length > 0
    ? videoSources
    : ['./assets/landing/video/portfolio-hero.mp4']
  const [activeVideoSrc, setActiveVideoSrc] = useState(safeVideoSources[0])
  const lastTriggeredTurnRef = useRef(-1)
```

The top of the component should read:

```jsx
export default function CinematicHero({ videoSources, playbackRate = 16 }) {
  const rootRef = useRef(null)
  const cardRef = useRef(null)
  const videoRef = useRef(null)
  const reducedMotion = useReducedMotion()
  const pointerRef = useRef({ x: 0, y: 0, tx: 0, ty: 0, raf: null })
  const safeVideoSources = Array.isArray(videoSources) && videoSources.length > 0
    ? videoSources
    : ['./assets/landing/video/portfolio-hero.mp4']
  const [activeVideoSrc, setActiveVideoSrc] = useState(safeVideoSources[0])
  const lastTriggeredTurnRef = useRef(-1)
```

- [ ] **Step 4: Replace the video playback lifecycle effect**

Replace the current `useEffect` that sets `video.playbackRate` and plays on `[activeVideoSrc, playbackRate, reducedMotion]` with:

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

- [ ] **Step 5: Add a helper for triggering the airplane burst**

Immediately after the video playback lifecycle effect, insert:

```jsx
  const triggerAirplaneBurst = (turnIndex) => {
    if (turnIndex < 0 || turnIndex >= TURN_COUNT) return
    if (lastTriggeredTurnRef.current === turnIndex) return

    lastTriggeredTurnRef.current = turnIndex
    const nextVideoSrc = safeVideoSources[turnIndex % safeVideoSources.length]
    setActiveVideoSrc(nextVideoSrc)

    const video = videoRef.current
    if (!video || reducedMotion) return

    video.playbackRate = playbackRate
    video.currentTime = 0
    const playPromise = video.play()
    if (playPromise && typeof playPromise.catch === 'function') {
      playPromise.catch(() => {
        // Muted inline autoplay is expected to work; ignore deferred playback.
      })
    }
  }
```

- [ ] **Step 6: Replace the ScrollTrigger effect with page-turn logic**

Replace the current first ScrollTrigger `useEffect` block, including the `setProgress` helper, with:

```jsx
  useEffect(() => {
    const root = rootRef.current
    const card = cardRef.current
    const video = videoRef.current
    if (!root || !card || !video) return undefined

    const setPageVars = ({ pageIndex, nextPageIndex = pageIndex, turnProgress = 0 }) => {
      CARD_GROUPS.forEach((_, gi) => {
        const isCurrent = gi === pageIndex
        const isNext = gi === nextPageIndex && nextPageIndex !== pageIndex
        const visible = isCurrent || isNext
        root.style.setProperty(`--page-${gi}-vis`, visible ? '1' : '0')
        root.style.setProperty(`--page-${gi}-turn`, isCurrent ? turnProgress.toFixed(4) : '0')
        root.style.setProperty(`--page-${gi}-incoming`, isNext ? turnProgress.toFixed(4) : '0')
        root.style.setProperty(`--page-${gi}-active`, isCurrent && turnProgress < 0.5 ? '1' : gi === nextPageIndex && turnProgress >= 0.5 ? '1' : '0')
        root.style.setProperty(`--group-${gi}-hue`, CARD_DIRS[gi].hue)
      })
    }

    if (reducedMotion) {
      video.pause()
      setPageVars({ pageIndex: 0 })
      return undefined
    }

    const trigger = ScrollTrigger.create({
      trigger: root,
      start: 'top top',
      end: 'bottom bottom',
      scrub: 0.7,
      onUpdate: (self) => {
        const p = self.progress
        root.style.setProperty('--scroll-progress', p.toFixed(4))

        const scaled = gsap.utils.clamp(0, TURN_COUNT - 0.0001, p * TURN_COUNT)
        const turnIndex = Math.floor(scaled)
        const local = scaled - turnIndex
        const isFinalRest = p >= 0.995
        const pageIndex = isFinalRest
          ? CARD_GROUPS.length - 1
          : turnIndex + (local >= TURN_PAGE_END ? 1 : 0)
        const nextPageIndex = Math.min(CARD_GROUPS.length - 1, turnIndex + 1)
        const pageTurnProgress = gsap.utils.clamp(0, 1, (local - TURN_PAGE_START) / (TURN_PAGE_END - TURN_PAGE_START))
        const videoBurstProgress = gsap.utils.clamp(0, 1, (local - TURN_VIDEO_START) / (TURN_PAGE_START - TURN_VIDEO_START))

        if (local >= TURN_VIDEO_START && turnIndex < TURN_COUNT) {
          triggerAirplaneBurst(turnIndex)
        }

        const settle = gsap.utils.clamp(0, 1, (local - 0.02) / 0.18)
        const pageTurn = Math.sin(pageTurnProgress * Math.PI)
        const videoImpact = Math.sin(videoBurstProgress * Math.PI)
        const rotateY = gsap.utils.interpolate(-7, 1.5, settle) + pageTurn * 4.5 + videoImpact * 2.5
        const rotateX = gsap.utils.interpolate(4.5, 0.6, settle) - pageTurn * 1.8
        const shiftX = gsap.utils.interpolate(-1.2, 0, settle) - videoImpact * 0.8
        const shiftY = gsap.utils.interpolate(1.1, 0, settle) + pageTurn * 0.6

        root.style.setProperty('--scroll-rotate-x', `${rotateX.toFixed(2)}deg`)
        root.style.setProperty('--scroll-rotate-y', `${rotateY.toFixed(2)}deg`)
        root.style.setProperty('--scroll-scale', '1')
        root.style.setProperty('--scroll-shift-x', `${shiftX.toFixed(2)}vw`)
        root.style.setProperty('--scroll-shift-y', `${shiftY.toFixed(2)}vh`)

        setPageVars({ pageIndex, nextPageIndex, turnProgress: pageTurnProgress })

        const finalFocus = gsap.utils.clamp(0, 1, (p - 0.9) / 0.09)
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
  }, [reducedMotion, playbackRate, activeVideoSrc])
```

- [ ] **Step 7: Remove the obsolete ended handler**

Delete this function from `CinematicHero.jsx`:

```jsx
  const handleVideoEnded = () => {
    setActiveVideoIndex((index) => (index + 1) % safeVideoSources.length)
  }
```

- [ ] **Step 8: Update the video element**

In the `<video>` element, make sure it contains exactly these playback attributes:

```jsx
              key={activeVideoSrc}
              src={activeVideoSrc}
              muted
              playsInline
              preload="auto"
              aria-hidden="true"
```

Remove `onEnded={handleVideoEnded}`.

- [ ] **Step 9: Update feature group inline CSS variables**

In the `CARD_GROUPS.map` render block, replace the `style` object with:

```jsx
            <div className="feature-group" key={gi} style={{
              '--page-vis': `var(--page-${gi}-vis)`,
              '--page-turn': `var(--page-${gi}-turn)`,
              '--page-incoming': `var(--page-${gi}-incoming)`,
              '--page-active': `var(--page-${gi}-active)`,
              '--group-hue': `var(--group-${gi}-hue)`,
            }}>
```

- [ ] **Step 10: Run source-level verification**

Run from repository root:

```bash
python - <<'PY'
from pathlib import Path
text = Path('frontend/src/components/CinematicHero.jsx').read_text(encoding='utf-8')
print('currentTime occurrences:', text.count('currentTime'))
print('setProgress occurrences:', text.count('setProgress'))
print('onEnded occurrences:', text.count('onEnded'))
assert text.count('setProgress') == 0
assert text.count('onEnded') == 0
assert 'playbackRate={16}' in Path('frontend/src/LandingApp.jsx').read_text(encoding='utf-8')
assert 'TURN_PAGE_START' in text
assert 'triggerAirplaneBurst' in text
PY
```

Expected output includes:

```text
currentTime occurrences: 2
setProgress occurrences: 0
onEnded occurrences: 0
```

The two `currentTime` occurrences are the deliberate reset in the playback effect and the burst trigger.

- [ ] **Step 11: Build the frontend**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite exits successfully and prints `✓ built`.

---

### Task 2: Render feature groups as clear 3D book pages

**Files:**
- Modify: `frontend/src/styles/portfolio-overrides.css`

**Interfaces:**
- Consumes: CSS variables `--page-vis`, `--page-turn`, `--page-incoming`, `--page-active`, `--group-hue`, `--pointer-x`, `--pointer-y`.
- Produces: A stable stacked page stage with clear active page, outgoing/incoming 3D page turn, and preserved video-card mouse tilt.

- [ ] **Step 1: Replace the `.feature-strip` block**

Replace the existing `.feature-strip` block with:

```css
.feature-strip {
  position: absolute;
  left: 50%;
  top: 44%;
  z-index: 14;
  pointer-events: none;
  transform: translate3d(-50%, -50%, 96px);
  transform-origin: center center;
  width: min(790px, calc(100vw - clamp(2rem, 4vw, 4rem)));
  min-height: 230px;
  perspective: 1400px;
  perspective-origin: 50% 50%;
}
```

- [ ] **Step 2: Replace the `.feature-group` block**

Replace the existing `.feature-group` block with:

```css
.feature-group {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 100%;
  min-height: 230px;
  padding: 1.1rem;
  text-align: center;
  transform-origin: left center;
  transform:
    translate3d(-50%, -50%, calc(var(--page-active, 0) * 24px))
    rotateY(calc(var(--page-incoming, 0) * 72deg - var(--page-turn, 0) * 82deg))
    rotateZ(calc(var(--page-turn, 0) * -1.8deg));
  opacity: calc(var(--page-vis, 0) * (.08 + var(--page-active, 0) * .92 + var(--page-incoming, 0) * .88));
  filter: blur(calc((1 - var(--page-vis, 0)) * 8px));
  transition: opacity .1s linear, filter .1s linear;
  transform-style: preserve-3d;
  will-change: transform, opacity, filter;
}
```

- [ ] **Step 3: Add page sheet pseudo-elements after `.feature-group`**

Insert this block immediately after `.feature-group`:

```css
.feature-group::before,
.feature-group::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 28px;
  pointer-events: none;
}

.feature-group::before {
  z-index: -2;
  background:
    linear-gradient(105deg, rgba(255,255,255,.96), hsla(var(--group-hue, 250), 72%, 97%, .92)),
    linear-gradient(90deg, rgba(20,24,42,.12), transparent 12%, transparent 88%, rgba(255,255,255,.55));
  border: 1px solid hsla(var(--group-hue, 250), 48%, 64%, .24);
  box-shadow:
    calc(var(--page-active, 0) * 0px + var(--page-turn, 0) * 1.4rem) 1.3rem 3.5rem rgba(18,22,40,.18),
    inset 1px 0 0 rgba(255,255,255,.95),
    inset -10px 0 18px rgba(22,26,52,.06);
}

.feature-group::after {
  z-index: -1;
  opacity: calc(var(--page-turn, 0) * .45 + var(--page-incoming, 0) * .25);
  background: linear-gradient(90deg, rgba(255,255,255,.42), transparent 24%, rgba(20,24,42,.12) 100%);
  mix-blend-mode: multiply;
}
```

- [ ] **Step 4: Replace `.feature-group__cards` block**

Replace the existing `.feature-group__cards` block with:

```css
.feature-group__cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
  justify-content: center;
  position: relative;
  z-index: 1;
}
```

- [ ] **Step 5: Replace readability declarations in `.feature-strip__item`**

Inside `.feature-strip__item`, replace the existing `background`, `border`, `box-shadow`, and `transition` declarations with:

```css
  background: linear-gradient(
    150deg,
    rgba(255,255,255,.96),
    hsla(var(--group-hue, 250), 60%, 96%, .9)
  );
  border: 1px solid hsla(var(--group-hue, 250), 45%, 68%, .24);
  box-shadow:
    0 .75rem 2rem rgba(22,26,52,.11),
    inset 0 1px 0 rgba(255,255,255,.88);
  transition: background .14s linear, border-color .14s linear, box-shadow .14s linear;
```

- [ ] **Step 6: Add active text clarity rules after `.feature-strip__item p`**

Insert:

```css
.feature-group[style] .feature-strip__item,
.feature-group[style] .feature-group__label {
  backface-visibility: hidden;
}
```

- [ ] **Step 7: Replace responsive feature rules**

In the `@media (max-width: 920px)` block, replace:

```css
  .feature-group { width: min(540px, calc(100vw - 3rem)); }
  .feature-group__cards { flex-wrap: wrap; }
```

with:

```css
  .feature-strip { width: min(540px, calc(100vw - 3rem)); min-height: 410px; }
  .feature-group { min-height: 410px; }
  .feature-group__cards { grid-template-columns: 1fr; }
```

In the `@media (max-width: 560px)` block, replace:

```css
  .feature-group { width: calc(100vw - 2.2rem); }
  .feature-group__cards { flex-direction: column; }
```

with:

```css
  .feature-strip { width: calc(100vw - 2.2rem); min-height: 440px; }
  .feature-group { min-height: 440px; padding: .9rem; }
  .feature-group__cards { grid-template-columns: 1fr; }
```

- [ ] **Step 8: Verify mouse tilt CSS stayed intact**

Run from repository root:

```bash
python - <<'PY'
from pathlib import Path
text = Path('frontend/src/styles/portfolio-overrides.css').read_text(encoding='utf-8')
assert 'var(--pointer-x) * 4deg' in text
assert 'var(--pointer-y) * -3deg' in text
assert '.spotlight-card::after' in text
assert 'perspective: 1400px' in text
assert '--page-turn' in text
print('book page CSS and mouse tilt verified')
PY
```

Expected output:

```text
book page CSS and mouse tilt verified
```

- [ ] **Step 9: Build the frontend**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite exits successfully and prints `✓ built`.

---

### Task 3: Sync built assets to Tomcat entry files

**Files:**
- Modify: `src/main/webapp/index.html`
- Modify: `src/main/webapp/js/landing-entry.js`
- Modify: `src/main/webapp/css/landing-entry.css`

**Interfaces:**
- Consumes: Vite build output under `src/main/webapp/assets/landing-build/`.
- Produces: fixed Tomcat-loaded landing files referenced with `?v=entry7`.

- [ ] **Step 1: Build the frontend**

Run:

```bash
cd frontend && npm run build
```

Expected: Vite exits successfully and writes `index-*.js` and `index-*.css` under `src/main/webapp/assets/landing-build/`.

- [ ] **Step 2: Copy latest hashed JS/CSS into fixed names**

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
copied js: src/main/webapp/assets/landing-build/index-
copied css: src/main/webapp/assets/landing-build/index-
```

- [ ] **Step 3: Replace `src/main/webapp/index.html` with fixed cache-busted references**

Replace the whole file with:

```html
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>大学生海报设计竞赛系统</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <script type="module" crossorigin src="./js/landing-entry.js?v=entry7"></script>
    <link rel="stylesheet" crossorigin href="./css/landing-entry.css?v=entry7">
    <link rel="stylesheet" href="./css/landing-glass-overrides.css?v=entry7">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
```

- [ ] **Step 4: Verify the deployed bundle contains all three video URLs and 16x playback**

Run from repository root:

```bash
python - <<'PY'
from pathlib import Path
bundle = Path('src/main/webapp/js/landing-entry.js').read_text(encoding='utf-8', errors='replace')
for part in [
  'hf_20260629_030107_874273ea-684a-4e90-bb96-8fdfde48d53d.mp4',
  'hf_20260629_032424_3c9c2a9d-807b-4482-80e6-dd6d9dfd4545.mp4',
  'hf_20260627_094019_4214ea73-b963-46a4-8327-61489192de99.mp4',
]:
    assert part in bundle, part
assert 'playbackRate' in bundle
html = Path('src/main/webapp/index.html').read_text(encoding='utf-8')
assert './js/landing-entry.js?v=entry7' in html
assert './css/landing-entry.css?v=entry7' in html
assert './css/landing-glass-overrides.css?v=entry7' in html
print('deployed landing assets verified')
PY
```

Expected output:

```text
deployed landing assets verified
```

- [ ] **Step 5: Run Maven package**

Run from repository root:

```bash
mvn package
```

Expected: Maven exits successfully with `BUILD SUCCESS`.

---

### Task 4: Verify the visual behavior in the running app

**Files:**
- No source files should be modified unless verification reveals a defect.

**Interfaces:**
- Consumes: Tomcat/Jetty-served `src/main/webapp/index.html` and fixed landing assets.
- Produces: observed confirmation that the landing page matches the approved interaction.

- [ ] **Step 1: Start the app if it is not already running**

Run one of these depending on the local workflow.

For Maven Jetty:

```bash
mvn jetty:run
```

Expected: server starts on port `8080` and serves context `/task`.

For IntelliJ/Tomcat: restart the existing Tomcat 9 run configuration and use the context path it serves, commonly:

```text
http://localhost:8080/task_war_exploded/
```

- [ ] **Step 2: Verify the live page references `entry7`**

For Jetty context `/task`, run:

```bash
python - <<'PY'
from urllib.request import Request, urlopen
html = urlopen(Request('http://localhost:8080/task/', headers={'Cache-Control':'no-cache'}), timeout=5).read().decode('utf-8', 'replace')
assert 'landing-entry.js?v=entry7' in html
assert 'landing-entry.css?v=entry7' in html
print('live Jetty index uses entry7')
PY
```

For Tomcat context `/task_war_exploded`, run:

```bash
python - <<'PY'
from urllib.request import Request, urlopen
html = urlopen(Request('http://localhost:8080/task_war_exploded/', headers={'Cache-Control':'no-cache'}), timeout=5).read().decode('utf-8', 'replace')
assert 'landing-entry.js?v=entry7' in html
assert 'landing-entry.css?v=entry7' in html
print('live Tomcat index uses entry7')
PY
```

Expected: the chosen command prints the matching `entry7` confirmation.

- [ ] **Step 3: Browser verification checklist**

Open the live landing page and press `Ctrl+F5`. Verify:

```text
1. The first screen loads without a JavaScript error.
2. Moving the mouse over the hero still tilts the video card subtly.
3. Scrolling begins a page-by-page book flip, not a simple fade.
4. Each turn starts with a fast airplane burst using one of the CloudFront videos.
5. After each page turn, the next feature page is clear, solid, and readable.
6. No feature page remains stuck in a semi-transparent unreadable state.
7. Continuing to scroll cycles through all six feature pages.
```

- [ ] **Step 4: Report verification results**

If all checks pass, report:

```text
Frontend build passed, Maven package passed, and the landing page visually matches the airplane-driven book flip interaction.
```

If a check fails, report the exact failed item, the observed behavior, and the file likely needing adjustment.

---

## Self-Review

**Spec coverage:**
- Three CloudFront videos: Task 1 Step 1 and Task 3 Step 4.
- 16x playback: Task 1 Steps 1, 4, 5.
- Airplane drives page turn: Task 1 Steps 5-6.
- Book-style page stack: Task 2 Steps 1-7.
- Clear stable pages: Task 2 Step 5 and browser checklist.
- Preserve mouse tilt: Task 2 Step 8 and browser checklist.
- No scroll video scrub: Task 1 Steps 6 and 10.
- Build/sync/cache bust: Task 3.
- Runtime verification: Task 4.

**Placeholder scan:** No TBD/TODO/implement-later placeholders are present.

**Type consistency:** `videoSources`, `playbackRate`, `activeVideoSrc`, `triggerAirplaneBurst`, `--page-turn`, `--page-incoming`, and `--page-active` names are consistent across tasks.
