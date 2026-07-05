// Maestro landing — interactions
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---- Nav: scrolled state + mobile toggle ---- */
  var nav = document.getElementById("nav");
  var navToggle = document.getElementById("navToggle");
  var onScroll = function () {
    if (window.scrollY > 20) nav.classList.add("scrolled");
    else nav.classList.remove("scrolled");
  };
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  if (navToggle) {
    navToggle.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      navToggle.setAttribute("aria-expanded", String(open));
    });
    nav.querySelectorAll(".nav-links a").forEach(function (a) {
      a.addEventListener("click", function () {
        nav.classList.remove("open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  /* ---- Copy install command ---- */
  var copyBtn = document.getElementById("copyBtn");
  var installCmd = document.getElementById("installCmd");
  if (copyBtn && installCmd) {
    copyBtn.addEventListener("click", function () {
      var text = installCmd.textContent.trim();
      var done = function () {
        copyBtn.textContent = "Copied";
        copyBtn.classList.add("copied");
        setTimeout(function () {
          copyBtn.textContent = "Copy";
          copyBtn.classList.remove("copied");
        }, 1800);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done).catch(done);
      } else {
        var ta = document.createElement("textarea");
        ta.value = text; document.body.appendChild(ta); ta.select();
        try { document.execCommand("copy"); } catch (e) {}
        document.body.removeChild(ta); done();
      }
    });
  }

  /* ---- Scroll reveal ---- */
  var revealEls = document.querySelectorAll(".reveal");
  if (reduceMotion || !("IntersectionObserver" in window)) {
    revealEls.forEach(function (el) { el.classList.add("in"); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("in");
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });
    revealEls.forEach(function (el) { io.observe(el); });
  }

  /* ---- Card pointer glow ---- */
  document.querySelectorAll(".card").forEach(function (card) {
    card.addEventListener("pointermove", function (e) {
      var r = card.getBoundingClientRect();
      card.style.setProperty("--mx", (e.clientX - r.left) + "px");
      card.style.setProperty("--my", (e.clientY - r.top) + "px");
    });
  });

  /* ---- Starfield ---- */
  var canvas = document.getElementById("starfield");
  if (!canvas || reduceMotion) return;
  var ctx = canvas.getContext("2d");
  var stars = [];
  var w, h, dpr;

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = canvas.width = Math.floor(window.innerWidth * dpr);
    h = canvas.height = Math.floor(window.innerHeight * dpr);
    canvas.style.width = window.innerWidth + "px";
    canvas.style.height = window.innerHeight + "px";
    var count = Math.min(140, Math.floor((window.innerWidth * window.innerHeight) / 14000));
    stars = [];
    for (var i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * w,
        y: Math.random() * h,
        z: Math.random() * 0.8 + 0.2,
        tw: Math.random() * Math.PI * 2
      });
    }
  }

  function tick(t) {
    ctx.clearRect(0, 0, w, h);
    for (var i = 0; i < stars.length; i++) {
      var s = stars[i];
      s.y += s.z * 0.12 * dpr;
      if (s.y > h) { s.y = 0; s.x = Math.random() * w; }
      var alpha = 0.35 + Math.sin(t * 0.001 + s.tw) * 0.3;
      var size = s.z * 1.6 * dpr;
      ctx.beginPath();
      ctx.fillStyle = "rgba(160, 200, 230, " + (alpha * s.z) + ")";
      ctx.arc(s.x, s.y, size, 0, Math.PI * 2);
      ctx.fill();
    }
    requestAnimationFrame(tick);
  }

  window.addEventListener("resize", resize);
  resize();
  requestAnimationFrame(tick);
})();
