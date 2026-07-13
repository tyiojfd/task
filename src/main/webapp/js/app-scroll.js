/**
 * App Scroll Reveal — lightweight Intersection Observer animations
 * No library dependency. Respects prefers-reduced-motion.
 */
(function () {
  'use strict';

  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );

  function scan() {
    document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
  }

  // Initial scan
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', scan);
  } else {
    scan();
  }

  // Re-scan after dynamic content loads (modals, AJAX, etc.)
  window.addEventListener('load', scan);
})();
