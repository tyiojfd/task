# Landing Page Portfolio Hero Redesign Design

Date: 2026-07-09

## Goal

Redesign the independent React landing page under `frontend/` into a high-impact creative portfolio style hero inspired by the referenced motionsites.ai / VIKTOR example. The page should feel less like a normal product introduction and more like a dynamic moving poster: large video card, designed typography, mouse-responsive depth, and scroll-driven cinematic angle changes.

The redesign must use the existing project video:

```text
src/main/webapp/assets/landing/video/portfolio-hero.mp4
```

No new npm dependencies will be installed. Effects will be implemented locally with React, existing GSAP, CSS transforms, pointer events, and `requestAnimationFrame`.

## Scope

Change only the independent landing page frontend:

```text
frontend/src/LandingApp.jsx
frontend/src/components/*
frontend/src/styles/*
```

The JSP/Servlet business system should not be modified. If a build is later run, the existing static build-output workflow may update files under `src/main/webapp/`, but the design work itself stays in the React landing page.

## Visual Direction

The new page should have a dark portfolio-gallery feel:

- Deep charcoal / black background.
- A large rounded video card as the main object.
- Minimal top navigation placed inside or above the hero.
- Oversized designed typography over the video.
- Small technical labels such as year, module names, route hints, or status text.
- Bright accent dot, preferably purple/pink, echoing the `VIKTOR.` screenshot.
- Bottom information card naming the system and its purpose.

Suggested hero copy:

```text
POSTER.
COMPETITION.
```

with supporting Chinese copy:

```text
大学生海报设计竞赛系统
组队 / 提交 / 评审 / 获奖公示 / 电子奖状
```

Primary CTA:

```text
进入竞赛系统
```

Secondary links:

```text
登录 / 注册 / 竞赛大厅 / 获奖名单
```

## Page Structure

The current six full-screen sections can be reduced. Recommended structure:

1. **Cinematic Hero**
   - Full-screen section.
   - Contains the main video card, big title, top nav, and CTA.
   - Mouse movement drives parallax and 3D tilt.

2. **Scroll Angle Sequence**
   - Pinned or near-pinned section using GSAP ScrollTrigger.
   - As the user scrolls, the video card changes scale, rotation, and perspective.
   - Video time is scrubbed so the airplane moment feels like it moves through the composition.
   - This is the key replacement for the referenced animation where the aircraft appears from different angles while scrolling.

3. **Feature Strip / Final CTA**
   - Compact section showing the core workflow: 发布竞赛, 创建队伍, 提交作品, 评委评分, 获奖公示.
   - Ends with `进入系统` and quick links.

This keeps the page shorter but stronger.

## Scroll-Driven Aircraft / Angle Feeling

The existing video cannot isolate the airplane as a separate transparent object, so the design will simulate the referenced effect through coordinated video scrubbing and camera-like transforms.

Implementation concept:

- Keep one main `<video>` element using `portfolio-hero.mp4`.
- On scroll, map ScrollTrigger progress to `video.currentTime`.
- At key progress bands, apply different visual states to the video card:
  - **0–25%:** wide front-facing card, title overlaid.
  - **25–50%:** card tilts upward and scales slightly, like the camera is looking into the sky.
  - **50–75%:** card rotates in 3D and shifts sideways while the video advances through the plane crossing moment.
  - **75–100%:** card returns to a flatter composition and transitions into the CTA.
- Add lightweight overlay elements to enhance the flight feeling:
  - thin white flight-line streaks,
  - small coordinate labels,
  - a soft glow following the mouse,
  - optional masked duplicate video layer with low opacity for depth, not a separate asset.

The target is not literal frame-perfect extraction of the airplane, but the same feeling: scrolling changes the viewing angle and makes the aircraft/video moment feel cinematic.

## Local React Bits Style Components

No external React Bits package will be installed. Create small local equivalents where useful:

```text
components/AnimatedText.jsx
components/MagneticLink.jsx
components/SpotlightCard.jsx
components/CinematicHero.jsx
```

Responsibilities:

### `AnimatedText`

- Splits a heading into lines or characters.
- Uses CSS transitions or GSAP on mount.
- Supports reduced motion by showing final state immediately.

### `MagneticLink`

- CTA button gently follows cursor while hovered.
- Uses pointer position and transform.
- Resets on pointer leave.

### `SpotlightCard`

- Stores mouse position as CSS variables.
- Creates a radial gradient spotlight on the video card.
- Can also expose parallax variables to children.

### `CinematicHero`

- Owns the main video card layout.
- Handles scroll-triggered video scrubbing and card transforms.
- Keeps the visual logic out of `LandingApp.jsx`.

## Typography Design

Use existing web font stack and CSS techniques rather than adding font packages.

- English title: very large, uppercase, heavy weight, tight tracking.
- Chinese copy: smaller, clean, high contrast, placed as supporting metadata.
- Use line breaks intentionally; avoid long centered paragraphs.
- Accent punctuation: purple/pink dot after one title word.
- Optional text treatments:
  - subtle stroke via `-webkit-text-stroke`,
  - transparent fill for secondary giant words,
  - slight blur-to-sharp entrance animation.

## Mouse Interaction

Pointer movement should affect the hero while staying tasteful:

- Video card rotates within a small range, e.g. `rotateX(-4deg to 4deg)`, `rotateY(-6deg to 6deg)`.
- Foreground title moves less than the card to create depth.
- Tiny labels move at different speeds.
- CTA uses magnetic hover.
- Spotlight follows cursor over the card.

All pointer-based motion must be disabled or greatly reduced under `prefers-reduced-motion: reduce`.

## Data and Routing

Use the existing `CTX` helper from `frontend/src/context.js` for all links into the JSP system.

Examples:

```jsx
href={CTX + '/index'}
href={CTX + '/login'}
href={CTX + '/register'}
href={CTX + '/competition?action=list'}
href={CTX + '/award?action=list'}
```

No API calls are needed.

## Accessibility

- Preserve semantic structure: `<header>`, `<main>`, `<section>`, `<nav>`.
- Video remains decorative and should use `aria-hidden="true"`.
- CTA links must have readable text, not icon-only labels.
- Respect `prefers-reduced-motion: reduce`:
  - disable split text animation,
  - disable pointer tilt,
  - either pause scroll scrubbing or reduce it to simple fade/transform states.
- Maintain strong text contrast over the video with overlays.

## Performance

- Use a single video source where possible.
- Avoid creating many duplicated video elements.
- Use `requestAnimationFrame` for pointer transform updates.
- Use CSS variables for spotlight and parallax values.
- Keep transforms on compositor-friendly properties: `transform`, `opacity`, `filter`.
- Clean up GSAP ScrollTriggers on unmount.

## Testing / Verification

After implementation:

1. Run the frontend build:

```bash
cd frontend
npm run build
```

2. Verify the landing page in browser if the app can be launched.
3. Check that:
   - the video loads,
   - scroll scrubbing works,
   - card angle changes on scroll,
   - mouse parallax works,
   - CTA links include the correct context path,
   - reduced-motion mode remains usable,
   - no JSP/Java business pages are changed unnecessarily.

## Decisions

- Use the project’s existing `portfolio-hero.mp4` video.
- Do not install React Bits or any new animation dependency.
- Recreate React Bits-like effects locally.
- Reduce the number of landing sections.
- Prioritize the scroll feeling of changing camera angles and the airplane moment over preserving the old six-section narrative.
