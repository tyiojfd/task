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

const FEATURES = [
  { num: '01', title: '发布竞赛', desc: '管理员配置赛题、分类与时间' },
  { num: '02', title: '组队报名', desc: '队长创建队伍并邀请成员' },
  { num: '03', title: '作品提交', desc: '上传海报、描述与展示图' },
  { num: '04', title: '评分获奖', desc: '评委评分，系统生成电子奖状' },
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

export default function CinematicHero({ videoSrc }) {
  const rootRef = useRef(null)
  const cardRef = useRef(null)
  const videoRef = useRef(null)
  const reducedMotion = useReducedMotion()
  const pointerRef = useRef({ x: 0, y: 0, tx: 0, ty: 0, raf: null })

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
      const planeWeightedProgress = progress < 0.58
        ? progress * 1.18
        : 0.684 + (progress - 0.58) * 0.58
      const target = Math.min(duration * 0.95, Math.max(0, planeWeightedProgress * duration))
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
        const zoomIn = gsap.utils.clamp(0, 1, (p - 0.12) / 0.22)
        const zoomOut = gsap.utils.clamp(0, 1, (p - 0.68) / 0.22)
        const zoomPhase = Math.max(0, zoomIn - zoomOut)
        const scale = 1 + Math.sin(zoomPhase * Math.PI / 2) * 0.45
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
