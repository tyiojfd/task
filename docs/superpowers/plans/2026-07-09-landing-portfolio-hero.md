# Landing Portfolio Hero Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the independent React landing page into a motionsites/VIKTOR-inspired creative portfolio hero using the existing airplane video, scroll-driven angle changes, mouse parallax, and designed typography.

**Architecture:** Keep the landing page isolated under `frontend/`. Replace the old six-section scrub narrative with a focused `CinematicHero` component plus a compact feature strip, while extracting reusable local animation helpers (`AnimatedText`, `MagneticLink`, `SpotlightCard`). Use existing GSAP/ScrollTrigger for video scrubbing and card scale/angle changes; use CSS variables and pointer events for mouse depth.

**Tech Stack:** React 18, Vite 5, existing GSAP 3.12.5, CSS, `requestAnimationFrame`, existing `portfolio-hero.mp4`.

## Global Constraints

- Do not install new npm dependencies.
- Use the existing video: `src/main/webapp/assets/landing/video/portfolio-hero.mp4` via `./assets/landing/video/portfolio-hero.mp4`.
- Modify only the independent landing frontend unless building produces webapp assets: `frontend/src/**`, `frontend/index.html`, `frontend/package.json` only if needed.
- Do not modify JSP/Servlet business code.
- Keep all JSP-system links using `CTX` from `frontend/src/context.js`.
- Preserve accessibility: semantic landmarks, readable links, decorative video with `aria-hidden="true"`, and reduced-motion handling.
- Git commits are checkpoints in this plan, but do not run `git commit` unless the user explicitly asks for commits.

---

## File Structure

### Create

- `frontend/src/components/AnimatedText.jsx`  
  Local React Bits-style split text entrance component.

- `frontend/src/components/MagneticLink.jsx`  
  Local magnetic CTA/link component.

- `frontend/src/components/SpotlightCard.jsx`  
  Local spotlight + pointer variable wrapper for card hover effects.

- `frontend/src/components/CinematicHero.jsx`  
  Main hero: video card, scroll video scrub, card angle sequence, mouse parallax, CTAs, and feature strip.

### Modify

- `frontend/src/LandingApp.jsx`  
  Replace the old `SCRUB_SECTIONS` + `ScrubPage` entry with the new `CinematicHero`.

- `frontend/src/styles/landing.css`  
  Keep global reset/tokens and adjust nav/global tokens if needed.

- `frontend/src/styles/portfolio-overrides.css`  
  Replace old scrub-section CSS with new cinematic portfolio hero CSS.

### Leave unchanged unless required by build verification

- `frontend/src/context.js`
- `frontend/src/main.jsx`
- `frontend/vite.config.js`
- JSP/Servlet files

---

### Task 1: Add Local Animation Components

**Files:**
- Create: `frontend/src/components/AnimatedText.jsx`
- Create: `frontend/src/components/MagneticLink.jsx`
- Create: `frontend/src/components/SpotlightCard.jsx`

**Interfaces:**
- Produces: `AnimatedText({ text: string, as?: string, className?: string, delay?: number, stagger?: number, splitBy?: 'char' | 'word' })`
- Produces: `MagneticLink({ href: string, className?: string, strength?: number, children: ReactNode, ...props })`
- Produces: `SpotlightCard({ as?: string, className?: string, children: ReactNode, style?: object, ...props })`
- Consumes: React only; no external dependencies.

- [ ] **Step 1: Create `AnimatedText.jsx`**

Write this file exactly:

```jsx
import React from 'react'

export default function AnimatedText({
  text,
  as: Tag = 'span',
  className = '',
  delay = 0,
  stagger = 0.035,
  splitBy = 'char',
}) {
  const units = splitBy === 'word' ? text.split(' ') : Array.from(text)

  return (
    <Tag className={`animated-text ${className}`.trim()} aria-label={text}>
      {units.map((unit, index) => {
        const value = splitBy === 'word' && index < units.length - 1 ? `${unit} ` : unit
        return (
          <span
            key={`${unit}-${index}`}
            className="animated-text__unit"
            aria-hidden="true"
            style={{ '--unit-delay': `${delay + index * stagger}s` }}
          >
            {value === ' ' ? ' ' : value}
          </span>
        )
      })}
    </Tag>
  )
}
```

- [ ] **Step 2: Create `MagneticLink.jsx`**

Write this file exactly:

```jsx
import React, { useRef } from 'react'

export default function MagneticLink({
  href,
  className = '',
  strength = 0.28,
  children,
  ...props
}) {
  const ref = useRef(null)
  const rafRef = useRef(null)

  const moveTo = (x, y) => {
    if (rafRef.current) cancelAnimationFrame(rafRef.current)
    rafRef.current = requestAnimationFrame(() => {
      if (!ref.current) return
      ref.current.style.transform = `translate3d(${x}px, ${y}px, 0)`
    })
  }

  const handlePointerMove = (event) => {
    const node = ref.current
    if (!node) return
    const rect = node.getBoundingClientRect()
    const x = (event.clientX - rect.left - rect.width / 2) * strength
    const y = (event.clientY - rect.top - rect.height / 2) * strength
    moveTo(x, y)
  }

  const handlePointerLeave = () => {
    moveTo(0, 0)
  }

  return (
    <a
      ref={ref}
      href={href}
      className={`magnetic-link ${className}`.trim()}
      onPointerMove={handlePointerMove}
      onPointerLeave={handlePointerLeave}
      {...props}
    >
      {children}
    </a>
  )
}
```

- [ ] **Step 3: Create `SpotlightCard.jsx`**

Write this file exactly:

```jsx
import React, { useRef } from 'react'

export default function SpotlightCard({
  as: Tag = 'div',
  className = '',
  children,
  style,
  ...props
}) {
  const ref = useRef(null)
  const rafRef = useRef(null)

  const handlePointerMove = (event) => {
    const node = ref.current
    if (!node) return
    const rect = node.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top

    if (rafRef.current) cancelAnimationFrame(rafRef.current)
    rafRef.current = requestAnimationFrame(() => {
      node.style.setProperty('--spotlight-x', `${x}px`)
      node.style.setProperty('--spotlight-y', `${y}px`)
      node.style.setProperty('--spotlight-opacity', '1')
    })
  }

  const handlePointerLeave = () => {
    const node = ref.current
    if (!node) return
    node.style.setProperty('--spotlight-opacity', '0')
  }

  return (
    <Tag
      ref={ref}
      className={`spotlight-card ${className}`.trim()}
      style={style}
      onPointerMove={handlePointerMove}
      onPointerLeave={handlePointerLeave}
      {...props}
    >
      {children}
    </Tag>
  )
}
```

- [ ] **Step 4: Verify imports compile conceptually**

Run:

```bash
cd frontend
npm run build
```

Expected: build may still include the old page, but these new components should not produce syntax errors. If the command fails, fix only syntax/import errors in the three new component files.

- [ ] **Step 5: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src/components/AnimatedText.jsx frontend/src/components/MagneticLink.jsx frontend/src/components/SpotlightCard.jsx
git commit -m "feat: add local landing animation components"
```

---

### Task 2: Build the Cinematic Hero Component

**Files:**
- Create: `frontend/src/components/CinematicHero.jsx`

**Interfaces:**
- Consumes: `CTX` from `frontend/src/context.js`.
- Consumes: `AnimatedText`, `MagneticLink`, `SpotlightCard` from Task 1.
- Produces: `CinematicHero({ videoSrc: string })` React component.

- [ ] **Step 1: Create `CinematicHero.jsx` with layout, scroll scrub, and pointer state**

Write this file exactly:

```jsx
import React, { useEffect, useRef } from 'react'
import gsap from 'gsap'
import ScrollTrigger from 'gsap/ScrollTrigger'
import { CTX } from '../context.js'
import AnimatedText from './AnimatedText.jsx'
import MagneticLink from './MagneticLink.jsx'
import SpotlightCard from './SpotlightCard.jsx'

gsap.registerPlugin(ScrollTrigger)

const QUICK_LINKS = [
  { label: '登录', href: CTX + '/login' },
  { label: '注册', href: CTX + '/register' },
  { label: '竞赛大厅', href: CTX + '/competition?action=list' },
  { label: '获奖名单', href: CTX + '/award?action=list' },
]

const FEATURES = [
  { num: '01', title: '发布竞赛', desc: '管理员配置赛题、分类与时间' },
  { num: '02', title: '组队报名', desc: '队长创建队伍并邀请成员' },
  { num: '03', title: '作品提交', desc: '上传海报、描述与展示图' },
  { num: '04', title: '评分获奖', desc: '评委评分，系统生成电子奖状' },
]

function useReducedMotion() {
  const ref = useRef(false)

  useEffect(() => {
    const media = window.matchMedia('(prefers-reduced-motion: reduce)')
    ref.current = media.matches
    const handleChange = () => { ref.current = media.matches }
    media.addEventListener?.('change', handleChange)
    return () => media.removeEventListener?.('change', handleChange)
  }, [])

  return ref
}

export default function CinematicHero({ videoSrc }) {
  const rootRef = useRef(null)
  const cardRef = useRef(null)
  const videoRef = useRef(null)
  const reducedMotionRef = useReducedMotion()
  const pointerRef = useRef({ x: 0, y: 0, tx: 0, ty: 0, raf: null })

  useEffect(() => {
    const root = rootRef.current
    const card = cardRef.current
    const video = videoRef.current
    if (!root || !card || !video) return

    if (reducedMotionRef.current) {
      video.pause()
      return undefined
    }

    const setProgress = (progress) => {
      const duration = video.duration || 12
      const target = Math.min(duration * 0.95, Math.max(0, progress * duration))
      const diff = target - video.currentTime
      if (Math.abs(diff) > 0.035) video.currentTime += diff * 0.42
    }

    const trigger = ScrollTrigger.create({
      trigger: root,
      start: 'top top',
      end: 'bottom bottom',
      scrub: 1.15,
      onUpdate: (self) => {
        const p = self.progress
        setProgress(p)
        root.style.setProperty('--scroll-progress', p.toFixed(4))

        const rotateY = gsap.utils.interpolate(-10, 10, Math.sin(p * Math.PI))
        const rotateX = gsap.utils.interpolate(7, -8, p)
        const scale = p > 0.18 && p < 0.72 ? 1.45 : gsap.utils.interpolate(1, 1.12, p)
        const shiftX = gsap.utils.interpolate(0, -7, Math.sin(p * Math.PI * 1.1))
        const shiftY = gsap.utils.interpolate(0, 5, Math.sin(p * Math.PI))

        root.style.setProperty('--scroll-rotate-x', `${rotateX.toFixed(2)}deg`)
        root.style.setProperty('--scroll-rotate-y', `${rotateY.toFixed(2)}deg`)
        root.style.setProperty('--scroll-scale', scale.toFixed(3))
        root.style.setProperty('--scroll-shift-x', `${shiftX.toFixed(2)}vw`)
        root.style.setProperty('--scroll-shift-y', `${shiftY.toFixed(2)}vh`)
      },
    })

    return () => trigger.kill()
  }, [reducedMotionRef])

  useEffect(() => {
    const root = rootRef.current
    if (!root) return undefined

    const updatePointer = () => {
      const state = pointerRef.current
      state.x += (state.tx - state.x) * 0.12
      state.y += (state.ty - state.y) * 0.12
      root.style.setProperty('--pointer-x', state.x.toFixed(4))
      root.style.setProperty('--pointer-y', state.y.toFixed(4))
      state.raf = requestAnimationFrame(updatePointer)
    }

    const handlePointerMove = (event) => {
      if (reducedMotionRef.current) return
      const rect = root.getBoundingClientRect()
      pointerRef.current.tx = ((event.clientX - rect.left) / rect.width - 0.5) * 2
      pointerRef.current.ty = ((event.clientY - rect.top) / rect.height - 0.5) * 2
    }

    root.addEventListener('pointermove', handlePointerMove)
    pointerRef.current.raf = requestAnimationFrame(updatePointer)

    return () => {
      root.removeEventListener('pointermove', handlePointerMove)
      if (pointerRef.current.raf) cancelAnimationFrame(pointerRef.current.raf)
    }
  }, [reducedMotionRef])

  return (
    <main ref={rootRef} className="cinematic-root">
      <section className="cinematic-hero" aria-labelledby="landing-title">
        <header className="portfolio-nav" aria-label="进入页导航">
          <a href={CTX + '/'} className="portfolio-nav__brand" aria-label="海报竞赛进入页">
            <span className="portfolio-nav__spark">✦</span>
            <span>POSTER WORKS</span>
          </a>
          <nav className="portfolio-nav__links" aria-label="快捷导航">
            {QUICK_LINKS.map((link) => (
              <a key={link.label} href={link.href}>{link.label}</a>
            ))}
          </nav>
          <a className="portfolio-nav__enter" href={CTX + '/index'}>进入系统</a>
        </header>

        <div className="cinematic-stage" aria-hidden="true">
          <div className="flight-line flight-line--one" />
          <div className="flight-line flight-line--two" />
          <div className="flight-dot flight-dot--one" />
          <div className="flight-dot flight-dot--two" />
        </div>

        <SpotlightCard className="hero-video-card" style={{ '--card-depth': '1' }}>
          <div ref={cardRef} className="hero-video-card__inner">
            <video
              ref={videoRef}
              className="hero-video-card__video"
              src={videoSrc}
              muted
              playsInline
              preload="auto"
              aria-hidden="true"
            />
            <div className="hero-video-card__shade" />

            <div className="hero-video-card__micro hero-video-card__micro--left">
              <span>SCROLL TO SCRUB</span>
              <strong>2026</strong>
            </div>
            <div className="hero-video-card__micro hero-video-card__micro--right">
              <span>CREATIVE PLATFORM</span>
              <strong>SHAOXING / CN</strong>
            </div>

            <div className="hero-title-block">
              <p className="hero-eyebrow">COLLEGE POSTER COMPETITION</p>
              <h1 id="landing-title" className="hero-display-title">
                <AnimatedText text="POSTER" as="span" className="hero-display-title__line" />
                <span className="hero-display-title__line hero-display-title__line--accent">
                  <AnimatedText text="COMPETITION" as="span" />
                  <span className="hero-display-title__dot">.</span>
                </span>
              </h1>
            </div>
          </div>
        </SpotlightCard>

        <div className="hero-info-panel">
          <div>
            <p className="hero-info-panel__kicker">Creative Portfolio Hero</p>
            <h2>大学生海报设计竞赛系统</h2>
            <p>以动态作品集首页呈现竞赛系统：组队报名、作品提交、评委评分、获奖公示和电子奖状全流程在线完成。</p>
          </div>
          <div className="hero-actions" aria-label="主要操作">
            <MagneticLink href={CTX + '/index'} className="hero-actions__primary">
              进入竞赛系统
              <span aria-hidden="true">→</span>
            </MagneticLink>
            <a href={CTX + '/competition?action=list'} className="hero-actions__secondary">浏览竞赛</a>
          </div>
        </div>
      </section>

      <section className="feature-strip" aria-label="系统流程概览">
        {FEATURES.map((feature) => (
          <article className="feature-strip__item" key={feature.num}>
            <span>{feature.num}</span>
            <h3>{feature.title}</h3>
            <p>{feature.desc}</p>
          </article>
        ))}
      </section>
    </main>
  )
}
```

- [ ] **Step 2: Run build and fix only syntax errors from `CinematicHero.jsx`**

Run:

```bash
cd frontend
npm run build
```

Expected: If `CinematicHero` is not imported yet, the build should still pass from Task 1. If this new file has syntax errors, fix them before continuing.

- [ ] **Step 3: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src/components/CinematicHero.jsx
git commit -m "feat: add cinematic landing hero component"
```

---

### Task 3: Replace LandingApp Entry With the New Hero

**Files:**
- Modify: `frontend/src/LandingApp.jsx`

**Interfaces:**
- Consumes: `CinematicHero({ videoSrc })` from Task 2.
- Produces: the app root rendering only the new landing experience.

- [ ] **Step 1: Replace `LandingApp.jsx` completely**

Replace the entire file with:

```jsx
import React from 'react'
import CinematicHero from './components/CinematicHero.jsx'

export default function LandingApp() {
  return (
    <div className="landing-root">
      <CinematicHero videoSrc="./assets/landing/video/portfolio-hero.mp4" />
    </div>
  )
}
```

- [ ] **Step 2: Run build**

Run:

```bash
cd frontend
npm run build
```

Expected: build succeeds or fails only because CSS for new classes is not yet styled. CSS absence should not fail Vite. Any import error means the path is wrong and must be corrected.

- [ ] **Step 3: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src/LandingApp.jsx
git commit -m "feat: switch landing page to cinematic hero"
```

---

### Task 4: Replace Landing CSS With Cinematic Portfolio Styling

**Files:**
- Modify: `frontend/src/styles/landing.css`
- Modify: `frontend/src/styles/portfolio-overrides.css`

**Interfaces:**
- Consumes: class names from `CinematicHero.jsx`, `AnimatedText.jsx`, `MagneticLink.jsx`, `SpotlightCard.jsx`.
- Produces: visual system, card depth, mouse parallax, scroll angle transforms, reduced-motion behavior.

- [ ] **Step 1: Replace `landing.css` with global tokens and reset**

Replace `frontend/src/styles/landing.css` completely with:

```css
/* ============================================================
   Global: reset, tokens, base accessibility
   ============================================================ */

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg: #101010;
  --panel: #242424;
  --panel-2: #2e2e2e;
  --text: #f6f3ed;
  --muted: rgba(246, 243, 237, .68);
  --faint: rgba(246, 243, 237, .38);
  --line: rgba(255, 255, 255, .13);
  --accent: #d66cff;
  --accent-2: #ffdf6e;
  --green: #8dffb2;
  --font: 'Noto Sans SC', 'PingFang SC', 'Microsoft YaHei', Arial, sans-serif;
  --ease-out-expo: cubic-bezier(.16, 1, .3, 1);
}

html { scroll-behavior: smooth; font-size: 16px; background: var(--bg); }
body {
  min-width: 320px;
  font-family: var(--font);
  background:
    radial-gradient(circle at 20% 0%, rgba(214, 108, 255, .16), transparent 32rem),
    radial-gradient(circle at 78% 16%, rgba(141, 255, 178, .1), transparent 30rem),
    var(--bg);
  color: var(--text);
  overflow-x: hidden;
  line-height: 1.55;
}

a { color: inherit; text-decoration: none; }
button, input, textarea, select { font: inherit; }
img, video { display: block; max-width: 100%; }

.landing-root { min-height: 100vh; background: transparent; }

::selection { background: rgba(214, 108, 255, .34); color: white; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: .01ms !important;
  }
}
```

- [ ] **Step 2: Replace `portfolio-overrides.css` with cinematic styling**

Replace `frontend/src/styles/portfolio-overrides.css` completely with:

```css
/* ============================================================
   Cinematic portfolio hero inspired by motionsites/VIKTOR
   ============================================================ */

.cinematic-root {
  --pointer-x: 0;
  --pointer-y: 0;
  --scroll-progress: 0;
  --scroll-rotate-x: 0deg;
  --scroll-rotate-y: 0deg;
  --scroll-scale: 1;
  --scroll-shift-x: 0vw;
  --scroll-shift-y: 0vh;
  position: relative;
  min-height: 238vh;
  overflow: clip;
  isolation: isolate;
}

.cinematic-root::before {
  content: '';
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: -2;
  background:
    linear-gradient(rgba(255,255,255,.025) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,.025) 1px, transparent 1px);
  background-size: 48px 48px;
  mask-image: linear-gradient(to bottom, rgba(0,0,0,.65), transparent 78%);
}

.cinematic-hero {
  position: sticky;
  top: 0;
  min-height: 100svh;
  padding: clamp(1rem, 2vw, 1.5rem);
  display: grid;
  grid-template-rows: auto 1fr auto;
  gap: clamp(1rem, 2vw, 1.25rem);
  perspective: 1400px;
}

.portfolio-nav {
  position: relative;
  z-index: 20;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0 clamp(.35rem, 1vw, .75rem);
  color: rgba(255,255,255,.9);
  font-size: .72rem;
  font-weight: 900;
  letter-spacing: .08em;
  text-transform: uppercase;
}

.portfolio-nav__brand,
.portfolio-nav__links,
.portfolio-nav__enter {
  display: flex;
  align-items: center;
}

.portfolio-nav__brand { gap: .55rem; }
.portfolio-nav__spark {
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: #111;
  background: var(--accent-2);
  box-shadow: 0 0 30px rgba(255, 223, 110, .22);
}

.portfolio-nav__links { gap: clamp(.65rem, 2vw, 1.3rem); color: rgba(255,255,255,.62); }
.portfolio-nav__links a,
.portfolio-nav__enter { transition: color .25s var(--ease-out-expo), transform .25s var(--ease-out-expo); }
.portfolio-nav__links a:hover,
.portfolio-nav__enter:hover { color: #fff; transform: translateY(-1px); }
.portfolio-nav__enter {
  padding: .55rem .85rem;
  border-radius: 999px;
  background: rgba(255,255,255,.08);
  border: 1px solid rgba(255,255,255,.14);
}

.cinematic-stage {
  pointer-events: none;
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
}

.flight-line {
  position: absolute;
  width: 34vw;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,.72), transparent);
  opacity: calc(.18 + var(--scroll-progress) * .48);
  transform-origin: center;
  filter: blur(.2px);
}

.flight-line--one {
  left: 54%;
  top: 20%;
  transform: translate3d(calc(var(--scroll-progress) * -28vw), calc(var(--scroll-progress) * 18vh), 0) rotate(-17deg) scaleX(calc(.4 + var(--scroll-progress) * 1.8));
}

.flight-line--two {
  right: -8%;
  bottom: 28%;
  transform: translate3d(calc(var(--scroll-progress) * -18vw), calc(var(--scroll-progress) * -13vh), 0) rotate(10deg) scaleX(calc(.3 + var(--scroll-progress) * 1.2));
}

.flight-dot {
  position: absolute;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: white;
  box-shadow: 0 0 24px rgba(255,255,255,.78);
  opacity: calc(.25 + var(--scroll-progress) * .55);
}

.flight-dot--one {
  left: calc(68% - var(--scroll-progress) * 36%);
  top: calc(18% + var(--scroll-progress) * 28%);
}

.flight-dot--two {
  left: calc(18% + var(--scroll-progress) * 44%);
  top: calc(70% - var(--scroll-progress) * 24%);
}

.spotlight-card {
  --spotlight-x: 50%;
  --spotlight-y: 50%;
  --spotlight-opacity: 0;
  position: relative;
}

.spotlight-card::after {
  content: '';
  position: absolute;
  inset: 0;
  pointer-events: none;
  border-radius: inherit;
  opacity: var(--spotlight-opacity);
  background: radial-gradient(circle at var(--spotlight-x) var(--spotlight-y), rgba(255,255,255,.28), rgba(214,108,255,.14) 18%, transparent 42%);
  transition: opacity .25s var(--ease-out-expo);
  mix-blend-mode: screen;
  z-index: 5;
}

.hero-video-card {
  align-self: center;
  justify-self: center;
  width: min(1120px, calc(100vw - clamp(2rem, 4vw, 3rem)));
  aspect-ratio: 16 / 9;
  border-radius: clamp(22px, 3vw, 38px);
  z-index: 5;
  transform-style: preserve-3d;
  transform:
    translate3d(
      calc(var(--scroll-shift-x) + var(--pointer-x) * -10px),
      calc(var(--scroll-shift-y) + var(--pointer-y) * -8px),
      0
    )
    rotateX(calc(var(--scroll-rotate-x) + var(--pointer-y) * -3deg))
    rotateY(calc(var(--scroll-rotate-y) + var(--pointer-x) * 4deg))
    scale(var(--scroll-scale));
  transition: transform .12s linear;
}

.hero-video-card__inner {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  border-radius: inherit;
  background: #181818;
  border: 1px solid rgba(255,255,255,.16);
  box-shadow:
    0 2rem 7rem rgba(0,0,0,.56),
    0 .5rem 1.4rem rgba(0,0,0,.42),
    inset 0 0 0 1px rgba(255,255,255,.05);
}

.hero-video-card__video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transform: scale(calc(1.04 + var(--scroll-progress) * .08));
  filter: saturate(1.08) contrast(1.02) brightness(.94);
}

.hero-video-card__shade {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(90deg, rgba(0,0,0,.58), rgba(0,0,0,.12) 52%, rgba(0,0,0,.32)),
    linear-gradient(0deg, rgba(0,0,0,.62), transparent 42%, rgba(0,0,0,.32));
  z-index: 1;
}

.hero-video-card__micro {
  position: absolute;
  z-index: 3;
  display: flex;
  flex-direction: column;
  gap: .2rem;
  color: rgba(255,255,255,.82);
  font-size: clamp(.48rem, .75vw, .68rem);
  font-weight: 900;
  letter-spacing: .08em;
  text-transform: uppercase;
  text-shadow: 0 2px 16px rgba(0,0,0,.45);
  transform: translate3d(calc(var(--pointer-x) * 8px), calc(var(--pointer-y) * 6px), 32px);
}

.hero-video-card__micro span { color: rgba(255,255,255,.48); }
.hero-video-card__micro--left { left: clamp(1rem, 2vw, 1.6rem); top: clamp(1rem, 2vw, 1.5rem); }
.hero-video-card__micro--right { right: clamp(1rem, 2vw, 1.6rem); top: clamp(1rem, 2vw, 1.5rem); align-items: flex-end; }

.hero-title-block {
  position: absolute;
  z-index: 4;
  left: clamp(1.1rem, 4vw, 3.2rem);
  right: clamp(1.1rem, 4vw, 3.2rem);
  bottom: clamp(1rem, 4vw, 3rem);
  transform: translate3d(calc(var(--pointer-x) * -16px), calc(var(--pointer-y) * -10px), 70px);
}

.hero-eyebrow {
  margin-bottom: clamp(.4rem, 1vw, .7rem);
  color: rgba(255,255,255,.68);
  font-size: clamp(.62rem, .9vw, .8rem);
  font-weight: 900;
  letter-spacing: .16em;
  text-transform: uppercase;
}

.hero-display-title {
  color: #fff;
  font-size: clamp(3.2rem, 12vw, 10.5rem);
  font-weight: 900;
  line-height: .78;
  letter-spacing: -.08em;
  text-transform: uppercase;
  text-shadow: 0 1rem 4rem rgba(0,0,0,.55);
}

.hero-display-title__line { display: block; }
.hero-display-title__line--accent { display: flex; align-items: flex-end; }
.hero-display-title__dot { color: var(--accent); letter-spacing: -.04em; text-shadow: 0 0 32px rgba(214,108,255,.66); }

.animated-text { display: inline-flex; overflow: hidden; }
.animated-text__unit {
  display: inline-block;
  opacity: 0;
  transform: translate3d(0, 110%, 0) rotate(7deg);
  animation: text-rise .9s var(--ease-out-expo) forwards;
  animation-delay: var(--unit-delay);
}

@keyframes text-rise {
  to { opacity: 1; transform: translate3d(0, 0, 0) rotate(0deg); }
}

.hero-info-panel {
  position: relative;
  z-index: 12;
  align-self: end;
  justify-self: center;
  width: min(1120px, calc(100vw - clamp(2rem, 4vw, 3rem)));
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 1.4rem;
  padding: clamp(1rem, 2.2vw, 1.45rem) clamp(1.05rem, 2.5vw, 1.7rem);
  border-radius: clamp(20px, 2.5vw, 30px);
  background: rgba(42,42,42,.88);
  border: 1px solid rgba(255,255,255,.1);
  box-shadow: 0 1rem 3rem rgba(0,0,0,.32);
  backdrop-filter: blur(18px);
}

.hero-info-panel__kicker {
  color: var(--accent-2);
  font-size: .76rem;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: .12em;
  margin-bottom: .25rem;
}

.hero-info-panel h2 {
  font-size: clamp(1.55rem, 3vw, 2.55rem);
  line-height: 1.08;
  margin-bottom: .4rem;
}

.hero-info-panel p:not(.hero-info-panel__kicker) {
  max-width: 640px;
  color: var(--muted);
  font-size: clamp(.86rem, 1vw, 1rem);
}

.hero-actions { display: flex; align-items: center; gap: .75rem; flex-shrink: 0; }
.magnetic-link { will-change: transform; transition: transform .2s var(--ease-out-expo); }
.hero-actions__primary,
.hero-actions__secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: .6rem;
  min-height: 48px;
  padding: .85rem 1.1rem;
  border-radius: 999px;
  font-weight: 900;
  white-space: nowrap;
}

.hero-actions__primary {
  color: #171717;
  background: var(--text);
  box-shadow: 0 1rem 2rem rgba(255,255,255,.12);
}

.hero-actions__secondary {
  color: rgba(255,255,255,.78);
  background: rgba(255,255,255,.07);
  border: 1px solid rgba(255,255,255,.1);
}

.feature-strip {
  position: relative;
  z-index: 20;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  width: min(1120px, calc(100vw - clamp(2rem, 4vw, 3rem)));
  margin: 0 auto 8vh;
  padding-top: 8vh;
}

.feature-strip__item {
  padding: 1.25rem;
  min-height: 158px;
  border-radius: 24px;
  background: rgba(255,255,255,.055);
  border: 1px solid rgba(255,255,255,.1);
  backdrop-filter: blur(14px);
}

.feature-strip__item span {
  color: var(--accent);
  font-size: .75rem;
  font-weight: 900;
  letter-spacing: .1em;
}

.feature-strip__item h3 {
  margin: .75rem 0 .35rem;
  font-size: 1.16rem;
}

.feature-strip__item p {
  color: var(--muted);
  font-size: .88rem;
}

@media (max-width: 920px) {
  .cinematic-root { min-height: 220vh; }
  .portfolio-nav__links { display: none; }
  .hero-video-card { width: min(94vw, 760px); aspect-ratio: 4 / 5; }
  .hero-video-card__micro--right { display: none; }
  .hero-info-panel { align-items: stretch; flex-direction: column; }
  .hero-actions { flex-wrap: wrap; }
  .feature-strip { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 560px) {
  .cinematic-hero { padding: .85rem; }
  .portfolio-nav { padding: 0; }
  .portfolio-nav__brand span:last-child { display: none; }
  .portfolio-nav__enter { font-size: .68rem; }
  .hero-video-card { width: calc(100vw - 1.7rem); border-radius: 22px; }
  .hero-display-title { font-size: clamp(2.8rem, 17vw, 5.4rem); }
  .hero-info-panel { width: calc(100vw - 1.7rem); }
  .hero-actions { flex-direction: column; align-items: stretch; }
  .hero-actions__primary,
  .hero-actions__secondary { width: 100%; }
  .feature-strip { width: calc(100vw - 1.7rem); grid-template-columns: 1fr; }
}

@media (prefers-reduced-motion: reduce) {
  .cinematic-root {
    --pointer-x: 0 !important;
    --pointer-y: 0 !important;
    --scroll-rotate-x: 0deg !important;
    --scroll-rotate-y: 0deg !important;
    --scroll-scale: 1 !important;
    --scroll-shift-x: 0vw !important;
    --scroll-shift-y: 0vh !important;
    min-height: auto;
  }

  .cinematic-hero { position: relative; }
  .hero-video-card { transform: none !important; }
  .animated-text__unit { opacity: 1; transform: none; animation: none; }
  .flight-line,
  .flight-dot { display: none; }
}
```

- [ ] **Step 3: Run build**

Run:

```bash
cd frontend
npm run build
```

Expected: Vite build succeeds. If CSS has syntax issues, fix the exact reported line.

- [ ] **Step 4: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src/styles/landing.css frontend/src/styles/portfolio-overrides.css
git commit -m "style: add cinematic portfolio landing styles"
```

---

### Task 5: Tune Scroll-Scrub Timing and Plane Moment

**Files:**
- Modify: `frontend/src/components/CinematicHero.jsx`
- Modify: `frontend/src/styles/portfolio-overrides.css` only if visual tuning needs CSS variable ranges.

**Interfaces:**
- Consumes: `videoRef`, ScrollTrigger callback, CSS variables from Tasks 2 and 4.
- Produces: stronger scroll feeling with a scale peak around `1.45`, changing camera angles, and visible flight lines.

- [ ] **Step 1: Adjust `CinematicHero.jsx` scale and video time mapping if the aircraft moment feels late**

In `CinematicHero.jsx`, locate this line:

```js
const target = Math.min(duration * 0.95, Math.max(0, progress * duration))
```

If the airplane crosses too late or too early in the local video, replace it with this weighted mapping:

```js
const planeWeightedProgress = progress < 0.58
  ? progress * 1.18
  : 0.684 + (progress - 0.58) * 0.58
const target = Math.min(duration * 0.95, Math.max(0, planeWeightedProgress * duration))
```

- [ ] **Step 2: Make the scale peak feel like the reference prompt**

In `CinematicHero.jsx`, locate:

```js
const scale = p > 0.18 && p < 0.72 ? 1.45 : gsap.utils.interpolate(1, 1.12, p)
```

If the scale jump feels too abrupt, replace it with:

```js
const zoomIn = gsap.utils.clamp(0, 1, (p - 0.12) / 0.22)
const zoomOut = gsap.utils.clamp(0, 1, (p - 0.68) / 0.22)
const scale = 1 + Math.sin((zoomIn - zoomOut) * Math.PI / 2) * 0.45
```

Expected behavior: the card smoothly reaches approximately `scale(1.45)` during the central aircraft moment, then eases back.

- [ ] **Step 3: Run build**

Run:

```bash
cd frontend
npm run build
```

Expected: PASS.

- [ ] **Step 4: Browser-check the effect if a local server is available**

Run one of these:

```bash
cd frontend
npm run dev
```

or, if testing the Java webapp instead:

```bash
mvn jetty:run
```

Expected visual checks:

- On first load, the large video card appears with `POSTER COMPETITION.` over it.
- Moving the mouse tilts the card and moves labels/title subtly.
- Scrolling down changes the video time.
- In the middle scroll range, the card enlarges close to `scale(1.45)` and rotates, making the airplane moment feel like a camera-angle change.
- Flight-line streaks become more visible during scroll.

- [ ] **Step 5: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src/components/CinematicHero.jsx frontend/src/styles/portfolio-overrides.css
git commit -m "feat: tune aircraft scroll angle sequence"
```

---

### Task 6: Verify Accessibility, Reduced Motion, and Build Output

**Files:**
- Modify only if verification finds issues:
  - `frontend/src/components/CinematicHero.jsx`
  - `frontend/src/styles/portfolio-overrides.css`
  - `frontend/src/styles/landing.css`

**Interfaces:**
- Consumes: final landing implementation.
- Produces: verified build and runtime behavior.

- [ ] **Step 1: Run production build**

Run:

```bash
cd frontend
npm run build
```

Expected output includes Vite success similar to:

```text
✓ built in ...
```

- [ ] **Step 2: Check generated landing entry path manually**

After build, inspect the build output under:

```text
src/main/webapp/assets/landing-build/
src/main/webapp/index.html
```

Expected:

- New hashed JS/CSS files exist under `assets/landing-build/`.
- `src/main/webapp/index.html` is present.
- If the app is deployed through Tomcat and AuthFilter blocks `assets/landing-build`, manually sync according to `CLAUDE1.md` before runtime testing:

```bash
cp src/main/webapp/assets/landing-build/index-*.js src/main/webapp/js/landing/
cp src/main/webapp/assets/landing-build/index-*.css src/main/webapp/css/landing/
```

Then update the `src/main/webapp/index.html` `script` and `link` tags to point at `/js/landing/...` and `/css/landing/...` if needed by the current deployment setup.

- [ ] **Step 3: Verify reduced motion CSS is present**

Open `frontend/src/styles/portfolio-overrides.css` and confirm this block exists exactly once:

```css
@media (prefers-reduced-motion: reduce) {
  .cinematic-root {
    --pointer-x: 0 !important;
    --pointer-y: 0 !important;
    --scroll-rotate-x: 0deg !important;
    --scroll-rotate-y: 0deg !important;
    --scroll-scale: 1 !important;
    --scroll-shift-x: 0vw !important;
    --scroll-shift-y: 0vh !important;
    min-height: auto;
  }
```

Expected: present. If missing, restore it from Task 4.

- [ ] **Step 4: Verify semantic landmarks**

Open `frontend/src/components/CinematicHero.jsx` and confirm these elements exist:

```jsx
<main ref={rootRef} className="cinematic-root">
<section className="cinematic-hero" aria-labelledby="landing-title">
<header className="portfolio-nav" aria-label="进入页导航">
<nav className="portfolio-nav__links" aria-label="快捷导航">
<section className="feature-strip" aria-label="系统流程概览">
```

Expected: all present. If any are missing, restore them from Task 2.

- [ ] **Step 5: Verify decorative video accessibility**

Open `frontend/src/components/CinematicHero.jsx` and confirm the video includes:

```jsx
muted
playsInline
preload="auto"
aria-hidden="true"
```

Expected: all present.

- [ ] **Step 6: Final browser smoke test**

Run:

```bash
cd frontend
npm run dev
```

Open the Vite URL and test:

- Click `进入竞赛系统`: expected link path ends with `/index`.
- Click `登录`: expected link path ends with `/login`.
- Click `注册`: expected link path ends with `/register`.
- Click `竞赛大厅`: expected link path includes `/competition?action=list`.
- Click `获奖名单`: expected link path includes `/award?action=list`.

- [ ] **Step 7: Commit checkpoint only if explicitly authorized**

```bash
git add frontend/src docs/superpowers/specs/2026-07-09-landing-portfolio-hero-design.md docs/superpowers/plans/2026-07-09-landing-portfolio-hero.md
git commit -m "feat: redesign landing portfolio hero"
```

---

## Self-Review

### Spec Coverage

- Existing `portfolio-hero.mp4`: Task 3 passes it into `CinematicHero`.
- No new dependencies: Global Constraints and all tasks use React/CSS/GSAP only.
- Local React Bits style effects: Task 1 creates `AnimatedText`, `MagneticLink`, `SpotlightCard`.
- Creative portfolio hero: Tasks 2 and 4 create the full-screen VIKTOR-inspired layout.
- Scroll aircraft angle feeling: Tasks 2, 4, and 5 implement ScrollTrigger, video time mapping, card `scale(1.45)`, 3D rotation, and flight lines.
- Mouse movement: Tasks 1, 2, and 4 implement pointer variables, spotlight, tilt, and magnetic CTA.
- Accessibility: Task 6 verifies landmarks, decorative video, and reduced motion.
- Build verification: Tasks 1-6 include `npm run build`; Task 6 includes browser smoke testing.

### Placeholder Scan

No `TBD`, `TODO`, or unspecified implementation steps remain. Optional tuning branches include exact replacement code.

### Type Consistency

Component names and props match across tasks:

- `AnimatedText({ text, as, className, delay, stagger, splitBy })`
- `MagneticLink({ href, className, strength, children, ...props })`
- `SpotlightCard({ as, className, children, style, ...props })`
- `CinematicHero({ videoSrc })`
