import React, { useRef, useState } from 'react'

export default function MagneticLink({
  href,
  className = '',
  strength = 0.28,
  children,
  onPointerMove,
  onPointerLeave,
  onBlur,
  style,
  ...props
}) {
  const linkRef = useRef(null)
  const [offset, setOffset] = useState({ x: 0, y: 0 })

  const handlePointerMove = (event) => {
    onPointerMove?.(event)

    const node = linkRef.current
    if (!node) return

    const rect = node.getBoundingClientRect()
    const x = (event.clientX - rect.left - rect.width / 2) * strength
    const y = (event.clientY - rect.top - rect.height / 2) * strength

    setOffset({ x, y })
  }

  const resetOffset = (event) => {
    setOffset({ x: 0, y: 0 })

    if (event.type === 'pointerleave') {
      onPointerLeave?.(event)
    }

    if (event.type === 'blur') {
      onBlur?.(event)
    }
  }

  return (
    <a
      href={href}
      className={`magnetic-link ${className}`.trim()}
      ref={linkRef}
      onPointerMove={handlePointerMove}
      onPointerLeave={resetOffset}
      onBlur={resetOffset}
      style={{
        ...style,
        transform: [style?.transform, `translate3d(${offset.x}px, ${offset.y}px, 0)`]
          .filter(Boolean)
          .join(' '),
      }}
      {...props}
    >
      {children}
    </a>
  )
}
