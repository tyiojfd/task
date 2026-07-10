// 🚫 Do NOT import ANYTHING from LandingApp — this module
//    must stay dependency-free to avoid circular-import TDZ errors.

const CTX = (() => {
  const path = window.location.pathname
  const parts = path.split('/')
  if (parts.length >= 2 && parts[1]) return '/' + parts[1]
  return ''
})()

export { CTX }
