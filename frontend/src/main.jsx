import React from 'react'
import { createRoot } from 'react-dom/client'
import LandingApp from './LandingApp.jsx'
import './styles/landing.css'
import './styles/portfolio-overrides.css'

createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <LandingApp />
  </React.StrictMode>
)
