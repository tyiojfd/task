import React from 'react'
import CinematicHero from './components/CinematicHero.jsx'
import { CTX } from './context.js'

const AIRPLANE_VIDEOS = [
  `${CTX}/assets/landing/video/airplane-01.mp4`,
  `${CTX}/assets/landing/video/airplane-02.mp4`,
  `${CTX}/assets/landing/video/airplane-03.mp4`,
]

export default function LandingApp() {
  return (
    <div className="landing-root">
      <CinematicHero videoSources={AIRPLANE_VIDEOS} playbackRate={16} />
    </div>
  )
}
