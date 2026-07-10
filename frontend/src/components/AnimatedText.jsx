import React from 'react'

const escapeWhitespace = (segment) => {
  if (segment === ' ') return ' '
  if (segment === '\n') return '\n'
  return segment
}

const splitText = (text, splitBy) => {
  const source = String(text ?? '')

  if (splitBy === 'word') {
    return source.split(/(\s+)/).filter(Boolean)
  }

  if (splitBy === 'line') {
    return source.replace(/\r\n/g, '\n').split(/(\n)/).filter(Boolean)
  }

  return Array.from(source)
}

export default function AnimatedText({
  text,
  as = 'span',
  className = '',
  delay = 0,
  stagger = 0.035,
  splitBy = 'char',
}) {
  const Component = as
  const segments = splitText(text, splitBy)

  return (
    <Component className={`animated-text ${className}`.trim()} aria-label={String(text ?? '')}>
      {segments.map((segment, index) => (
        <span
          aria-hidden="true"
          className="animated-text__unit"
          key={`${segment}-${index}`}
          style={{ '--text-delay': `${delay + index * stagger}s` }}
        >
          {escapeWhitespace(segment)}
        </span>
      ))}
    </Component>
  )
}
