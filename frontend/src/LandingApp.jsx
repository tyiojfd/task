import React from 'react'
import CinematicHero from './components/CinematicHero.jsx'

export default function LandingApp() {
  return (
    <div className="landing-root">
      <CinematicHero videoSrc="./assets/landing/video/portfolio-hero.mp4" />
    </div>
  )
}
