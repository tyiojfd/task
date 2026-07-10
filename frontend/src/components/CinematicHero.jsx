import React, { useEffect, useRef, useState } from 'react'
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

const CARD_GROUPS = [
  {
    label: '赛事发布',
    cards: [
      { title: '赛题配置', desc: '灵活设定竞赛主题与参赛要求' },
      { title: '分类管理', desc: '多级分类体系，精准匹配赛道' },
      { title: '时间窗口', desc: '报名→提交→评审全流程时间线' },
    ],
  },
  {
    label: '组队报名',
    cards: [
      { title: '创建战队', desc: '队长发起，自定义队伍名称与简介' },
      { title: '邀请队友', desc: '搜索用户，一键发送组队邀请' },
      { title: '报名参赛', desc: '组队完成即可报名目标竞赛' },
    ],
  },
  {
    label: '创意提交',
    cards: [
      { title: '上传作品', desc: '支持多格式海报，拖拽即可上传' },
      { title: '设计理念', desc: '附上创作故事与设计思路说明' },
    ],
  },
  {
    label: '专业评审',
    cards: [
      { title: '评委打分', desc: '多维度量化评分，公平公正' },
      { title: '评语反馈', desc: '文字评价帮助选手成长提升' },
    ],
  },
  {
    label: '获奖公示',
    cards: [
      { title: '公布结果', desc: '优胜名单自动生成，全平台展示' },
      { title: '荣誉表彰', desc: '金银铜奖分级，荣耀永久记录' },
    ],
  },
  {
    label: '电子奖状',
    cards: [
      { title: '证书生成', desc: '获奖自动生成精美电子证书' },
      { title: '永久存档', desc: '随时查看下载，荣誉永不丢失' },
    ],
  },
]

const CARD_DIRS = [
  { x: -44, y: -26, hue: 258 },
  { x: 46, y: 4, hue: 222 },
  { x: 0, y: -38, hue: 272 },
  { x: 2, y: 36, hue: 195 },
  { x: 0, y: 0, hue: 248 },
  { x: 36, y: 28, hue: 235 },
]

function useReducedMotion() {
  const getInitialPreference = () => {
    if (typeof window === 'undefined' || !window.matchMedia) return false
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }

  const [reducedMotion, setReducedMotion] = useState(getInitialPreference)

  useEffect(() => {
    const media = window.matchMedia('(prefers-reduced-motion: reduce)')
    const handleChange = (event) => { setReducedMotion(event.matches) }

    setReducedMotion(media.matches)
    media.addEventListener?.('change', handleChange)
    return () => media.removeEventListener?.('change', handleChange)
  }, [])

  return reducedMotion
}

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

  useEffect(() => {
    const root = rootRef.current
    const card = cardRef.current
    const video = videoRef.current
    if (!root || !card || !video) return

    if (reducedMotion) {
      video.pause()
      return undefined
    }

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

    const trigger = ScrollTrigger.create({
      trigger: root,
      start: 'top top',
      end: 'bottom bottom',
      scrub: 1.15,
      onUpdate: (self) => {
        const p = self.progress
        setProgress(p)
        root.style.setProperty('--scroll-progress', p.toFixed(4))

        const pageTurn = Math.sin(p * Math.PI)
        const rotateY = gsap.utils.interpolate(-8, 8, p) + pageTurn * 4
        const rotateX = gsap.utils.interpolate(5, -6, p)
        const scale = 1
        const shiftX = pageTurn * -2.4
        const shiftY = pageTurn * 1.8

        root.style.setProperty('--scroll-rotate-x', `${rotateX.toFixed(2)}deg`)
        root.style.setProperty('--scroll-rotate-y', `${rotateY.toFixed(2)}deg`)
        root.style.setProperty('--scroll-scale', scale.toFixed(3))
        const finalFocus = gsap.utils.clamp(0, 1, (p - 0.78) / 0.18)
        const contentAlpha = 1 - finalFocus
        const panelWidth = gsap.utils.interpolate(1120, 340, finalFocus)
        const copyWidth = gsap.utils.interpolate(680, 0, finalFocus)
        const secondaryWidth = gsap.utils.interpolate(118, 0, finalFocus)

        CARD_GROUPS.forEach((_, gi) => {
          const start = 0.04 + gi * 0.15
          const intro = gsap.utils.clamp(0, 1, (p - start) / 0.05)
          const fade = gsap.utils.clamp(0, 1, (p - start - 0.10) / 0.05)
          const vis = intro * (1 - fade)
          root.style.setProperty(`--group-${gi}-vis`, vis.toFixed(4))
          root.style.setProperty(`--group-${gi}-x`, `${CARD_DIRS[gi].x}px`)
          root.style.setProperty(`--group-${gi}-y`, `${CARD_DIRS[gi].y}px`)
          root.style.setProperty(`--group-${gi}-hue`, CARD_DIRS[gi].hue)
        })

        root.style.setProperty('--scroll-shift-x', `${shiftX.toFixed(2)}vw`)
        root.style.setProperty('--scroll-shift-y', `${shiftY.toFixed(2)}vh`)
        root.style.setProperty('--final-focus', finalFocus.toFixed(4))
        root.style.setProperty('--content-alpha', contentAlpha.toFixed(4))
        root.style.setProperty('--panel-width', `${panelWidth.toFixed(1)}px`)
        root.style.setProperty('--copy-width', `${copyWidth.toFixed(1)}px`)
        root.style.setProperty('--secondary-width', `${secondaryWidth.toFixed(1)}px`)
      },
    })

    return () => trigger.kill()
  }, [reducedMotion])

  useEffect(() => {
    const root = rootRef.current
    if (!root) return undefined

    if (reducedMotion) return undefined

    const updatePointer = () => {
      const state = pointerRef.current
      state.x += (state.tx - state.x) * 0.12
      state.y += (state.ty - state.y) * 0.12
      root.style.setProperty('--pointer-x', state.x.toFixed(4))
      root.style.setProperty('--pointer-y', state.y.toFixed(4))
      state.raf = requestAnimationFrame(updatePointer)
    }

    const handlePointerMove = (event) => {
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
  }, [reducedMotion])

  const handleVideoEnded = () => {
    setActiveVideoIndex((index) => (index + 1) % safeVideoSources.length)
  }

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
              key={activeVideoSrc}
              src={activeVideoSrc}
              muted
              playsInline
              preload="auto"
              aria-hidden="true"
              onEnded={handleVideoEnded}
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

        <section className="feature-strip" aria-label="系统流程概览">
          {CARD_GROUPS.map((group, gi) => (
            <div className="feature-group" key={gi} style={{
              '--group-vis': `var(--group-${gi}-vis)`,
              '--group-x': `var(--group-${gi}-x)`,
              '--group-y': `var(--group-${gi}-y)`,
              '--group-hue': `var(--group-${gi}-hue)`,
            }}>
              <div className="feature-group__label">{group.label}</div>
              <div className="feature-group__cards">
                {group.cards.map((card, ci) => (
                  <article className="feature-strip__item" key={ci}>
                    <span>{(gi + 1).toString().padStart(2, '0')}.{ci + 1}</span>
                    <h3>{card.title}</h3>
                    <p>{card.desc}</p>
                  </article>
                ))}
              </div>
            </div>
          ))}
        </section>

        <div className="hero-info-panel">
          <div className="hero-info-panel__copy">
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
    </main>
  )
}
