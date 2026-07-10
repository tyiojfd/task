(function () {
    var slides = document.querySelectorAll(".hero-slide");
    var dots = document.querySelectorAll(".carousel-dots button");
    var revealItems = document.querySelectorAll(".reveal");
    var prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var activeIndex = 0;
    var timer = null;

    function showSlide(index) {
        if (!slides.length) return;
        slides[activeIndex].classList.remove("is-active");
        dots[activeIndex].classList.remove("is-active");
        activeIndex = (index + slides.length) % slides.length;
        slides[activeIndex].classList.add("is-active");
        dots[activeIndex].classList.add("is-active");
    }

    function startCarousel() {
        if (prefersReducedMotion || slides.length < 2) return;
        timer = window.setInterval(function () {
            showSlide(activeIndex + 1);
        }, 5200);
    }

    dots.forEach(function (dot, index) {
        dot.addEventListener("click", function () {
            if (timer) window.clearInterval(timer);
            showSlide(index);
            startCarousel();
        });
    });

    startCarousel();

    if ("IntersectionObserver" in window) {
        var revealObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add("is-visible");
                    revealObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.14, rootMargin: "0px 0px -40px 0px" });

        revealItems.forEach(function (item) {
            revealObserver.observe(item);
        });
    } else {
        revealItems.forEach(function (item) {
            item.classList.add("is-visible");
        });
    }

    window.addEventListener("scroll", function () {
        document.documentElement.style.setProperty("--scroll-y", String(window.scrollY));
    }, { passive: true });
})();
