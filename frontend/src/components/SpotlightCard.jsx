import React, { useRef } from 'react'

/**
 * When using a custom component for `as`, it must forward DOM props/ref to a
 * real element so pointer handlers, inline CSS variables, and focus behavior work.
 */
export default function SpotlightCard({
  as = 'div',
  className = '',
  children,
  style,
  onPointerMove,
  ...props
}) {
  const Component = as
  const posRef = useRef({ x: 50, y: 50 })
  const rafRef = useRef(null)

  const handlePointerMove = (event) => {
    onPointerMove?.(event)

    const rect = event.currentTarget.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100

    posRef.current.x = x
    posRef.current.y = y

    if (!rafRef.current) {
      rafRef.current = requestAnimationFrame(() => {
        rafRef.current = null
        try {
          event.currentTarget.style.setProperty('--spotlight-x', `${posRef.current.x}%`)
          event.currentTarget.style.setProperty('--spotlight-y', `${posRef.current.y}%`)
        } catch (_) { /* element may be unmounted */ }
      })
    }
  }

  return (
    <Component
      className={`spotlight-card ${className}`.trim()}
      onPointerMove={handlePointerMove}
      style={{
        '--spotlight-x': '50%',
        '--spotlight-y': '50%',
        ...style,
      }}
      {...props}
    >
      {children}
    </Component>
  )
}
