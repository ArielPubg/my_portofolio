(() => {
  'use strict';

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ================= THEME ================= */
  const root = document.body;
  const themeToggle = document.getElementById('theme-toggle');
  const savedTheme = localStorage.getItem('ariel-theme');
  if (savedTheme) root.setAttribute('data-theme', savedTheme);

  const syncThemeButton = () => {
    const isLight = root.getAttribute('data-theme') === 'light';
    themeToggle.setAttribute('aria-pressed', String(isLight));
  };
  syncThemeButton();

  themeToggle.addEventListener('click', () => {
    const next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
    root.setAttribute('data-theme', next);
    localStorage.setItem('ariel-theme', next);
    syncThemeButton();
  });

  /* ================= MOBILE NAV ================= */
  const burger = document.getElementById('burger');
  const navLinks = document.getElementById('nav-links');

  burger.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    burger.setAttribute('aria-expanded', String(isOpen));
    burger.setAttribute('aria-label', isOpen ? 'Fermer le menu' : 'Ouvrir le menu');
  });

  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      burger.setAttribute('aria-expanded', 'false');
    });
  });

  /* ================= SCROLL REVEAL ================= */
  const revealTargets = document.querySelectorAll('[data-reveal]');
  const barRows = document.querySelectorAll('.bar');

  if (reduceMotion) {
    revealTargets.forEach(el => el.classList.add('in-view'));
    barRows.forEach(el => el.classList.add('filled'));
  } else {
    const revealObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          revealObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });
    revealTargets.forEach(el => revealObserver.observe(el));

    const barObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('filled');
          barObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.4 });
    barRows.forEach(el => barObserver.observe(el));
  }

  /* ================= NAV BACKGROUND ON SCROLL ================= */
  const nav = document.getElementById('site-nav');
  const onScroll = () => {
    nav.style.boxShadow = window.scrollY > 12 ? '0 1px 0 rgba(0,0,0,.06)' : 'none';
  };
  document.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ================= HERO NAME TYPE-IN ================= */
  const nameEl = document.getElementById('typed-name');
  if (nameEl && !reduceMotion) {
    const fullText = nameEl.textContent;
    nameEl.textContent = '';
    nameEl.classList.add('typing');
    let i = 0;
    const typeName = () => {
      if (i <= fullText.length) {
        nameEl.textContent = fullText.slice(0, i);
        i++;
        setTimeout(typeName, 55);
      } else {
        setTimeout(() => nameEl.classList.remove('typing'), 900);
      }
    };
    setTimeout(typeName, 300);
  }

  /* ================= ROLE ROTATOR ================= */
  const roleEl = document.getElementById('role-rotator');
  const roles = [
    '— Automatisation de tâches',
    '— Analyse de données',
    '— Développement web sur mesure',
    '— Scripts & workflows'
  ];

  if (roleEl) {
    if (reduceMotion) {
      roleEl.textContent = roles[0];
    } else {
      let roleIndex = 0;
      let charIndex = 0;
      let deleting = false;

      const tickRole = () => {
        const current = roles[roleIndex];
        if (!deleting) {
          charIndex++;
          roleEl.textContent = current.slice(0, charIndex);
          if (charIndex === current.length) {
            deleting = true;
            setTimeout(tickRole, 1800);
            return;
          }
        } else {
          charIndex--;
          roleEl.textContent = current.slice(0, charIndex);
          if (charIndex === 0) {
            deleting = false;
            roleIndex = (roleIndex + 1) % roles.length;
          }
        }
        setTimeout(tickRole, deleting ? 28 : 45);
      };
      setTimeout(tickRole, 1600);
    }
  }

  /* ================= TERMINAL SEQUENCE ================= */
  const terminalBody = document.getElementById('terminal-body');
  const script = [
    { type: 'cmd', text: '$ ./analyser_donnees.py --source client_data.csv' },
    { type: 'dim', text: 'Chargement des données…' },
    { type: 'ok', text: '✓ Nettoyage terminé — 12 430 lignes traitées' },
    { type: 'ok', text: '✓ Modèle entraîné — précision 94.2%' },
    { type: 'cmd', text: '$ ./automatiser_taches.sh --schedule daily' },
    { type: 'ok', text: '✓ Pipeline planifié — exécution quotidienne 06:00' },
    { type: 'cmd', text: '$ ./deployer.sh --env production' },
    { type: 'ok', text: '✓ Application en ligne — prête pour le client' },
  ];

  const buildLine = (type, text) => {
    const span = document.createElement('span');
    span.className = type;
    span.textContent = text;
    return span;
  };

  const runTerminal = () => {
    if (!terminalBody) return;

    if (reduceMotion) {
      script.forEach(line => {
        terminalBody.appendChild(buildLine(line.type, line.text));
        terminalBody.appendChild(document.createElement('br'));
      });
      return;
    }

    let lineIndex = 0;

    const typeLine = () => {
      if (lineIndex >= script.length) return;
      const { type, text } = script[lineIndex];
      const lineSpan = buildLine(type, '');
      terminalBody.appendChild(lineSpan);
      let charIndex = 0;

      const typeChar = () => {
        if (charIndex <= text.length) {
          lineSpan.textContent = text.slice(0, charIndex);
          charIndex++;
          setTimeout(typeChar, type === 'cmd' ? 22 : 10);
        } else {
          terminalBody.appendChild(document.createElement('br'));
          lineIndex++;
          setTimeout(typeLine, type === 'cmd' ? 260 : 420);
        }
      };
      typeChar();
    };

    typeLine();
  };

  if (terminalBody) {
    if (reduceMotion) {
      runTerminal();
    } else {
      const terminalObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            runTerminal();
            terminalObserver.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      terminalObserver.observe(terminalBody);
    }
  }

  /* ================= PROJECT VIDEO PLAYERS ================= */
  const formatTime = (seconds) => {
    if (!isFinite(seconds) || seconds < 0) return '00:00';
    const m = Math.floor(seconds / 60).toString().padStart(2, '0');
    const s = Math.floor(seconds % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const playerWindows = Array.from(document.querySelectorAll('.player-window:not(.is-pending)'));

  playerWindows.forEach(win => {
    const video = win.querySelector('.player-video');
    const stage = win.querySelector('.player-stage');
    const playBtn = win.querySelector('.player-play');
    const expandBtn = win.querySelector('.player-expand');
    const timecodeEl = win.querySelector('[data-timecode]');
    const statusEl = win.querySelector('[data-status]');
    if (!video || !playBtn) return;

    const setStatus = (playing) => {
      win.classList.toggle('is-playing', playing);
      playBtn.innerHTML = playing
        ? '<i class="fa-solid fa-pause" aria-hidden="true"></i>'
        : '<i class="fa-solid fa-play" aria-hidden="true"></i>';
      playBtn.setAttribute('aria-label', playing ? 'Mettre en pause' : 'Lire la vidéo');
      if (statusEl) {
        statusEl.innerHTML = playing
          ? '<span class="rec-dot"></span>REC'
          : '<span class="rec-dot"></span>pause';
      }
    };

    const togglePlay = () => {
      if (video.paused) {
        // une seule vidéo jouée à la fois parmi les projets
        playerWindows.forEach(other => {
          if (other === win) return;
          const otherVideo = other.querySelector('.player-video');
          if (otherVideo && !otherVideo.paused) otherVideo.pause();
        });
        video.muted = false;
        const playPromise = video.play();
        if (playPromise && typeof playPromise.catch === 'function') {
          playPromise.catch(() => {
            video.muted = true;
            video.play().catch(() => {});
          });
        }
      } else {
        video.pause();
      }
    };

    playBtn.addEventListener('click', togglePlay);
    video.addEventListener('click', togglePlay);

    video.addEventListener('play', () => setStatus(true));
    video.addEventListener('pause', () => setStatus(false));
    video.addEventListener('ended', () => setStatus(false));

    video.addEventListener('timeupdate', () => {
      if (timecodeEl) timecodeEl.textContent = formatTime(video.currentTime);
    });
    video.addEventListener('loadedmetadata', () => {
      if (timecodeEl) timecodeEl.textContent = formatTime(0);
    });

    // pause automatique quand la vidéo sort de l'écran
    const visibilityObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting && !video.paused) video.pause();
      });
    }, { threshold: 0.2 });
    visibilityObserver.observe(win);

    // agrandir le champ de lecture (plein écran)
    if (expandBtn && stage) {
      const isCurrentlyFullscreen = () => {
        const fsEl = document.fullscreenElement || document.webkitFullscreenElement;
        return fsEl === stage;
      };

      const syncExpandState = () => {
        const active = isCurrentlyFullscreen();
        stage.classList.toggle('is-fullscreen', active);
        expandBtn.innerHTML = active
          ? '<i class="fa-solid fa-compress" aria-hidden="true"></i>'
          : '<i class="fa-solid fa-expand" aria-hidden="true"></i>';
        expandBtn.setAttribute('aria-label', active ? 'Quitter le plein écran' : 'Agrandir la vidéo');
      };

      expandBtn.addEventListener('click', (evt) => {
        evt.stopPropagation();
        if (isCurrentlyFullscreen()) {
          if (document.exitFullscreen) document.exitFullscreen();
          else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
          return;
        }
        if (stage.requestFullscreen) {
          stage.requestFullscreen();
        } else if (stage.webkitRequestFullscreen) {
          stage.webkitRequestFullscreen();
        } else if (video.webkitEnterFullscreen) {
          // Safari iOS : seule la balise <video> supporte le plein écran natif
          video.webkitEnterFullscreen();
        }
      });

      ['fullscreenchange', 'webkitfullscreenchange'].forEach(evt => {
        document.addEventListener(evt, syncExpandState);
      });
    }
  });

  /* ================= LIGHTBOX GALLERY (aperçu -> plein cadre) ================= */
  const createLightboxGallery = (root) => {
    const track = root.querySelector('[data-track]');
    const filmstrip = root.querySelector('[data-filmstrip]');
    const prevBtn = root.querySelector('.gallery-nav--prev');
    const nextBtn = root.querySelector('.gallery-nav--next');
    const counterEl = root.querySelector('[data-counter]');
    const captionEl = root.querySelector('[data-caption]');
    const titleEl = root.querySelector('[data-lightbox-title]');
    const autoplayBtn = root.querySelector('[data-autoplay-toggle]');
    const closeBtn = root.querySelector('[data-lightbox-close]');
    const backdrop = root.querySelector('[data-lightbox-backdrop]');
    const stage = root.querySelector('.gallery-stage');

    let slides = [];
    let thumbs = [];
    let index = 0;
    let autoplayOn = false;
    let autoplayTimer = null;
    let lastFocused = null;

    const pad2 = (n) => String(n).padStart(2, '0');

    const resetAutoplayButton = () => {
      if (!autoplayBtn) return;
      autoplayBtn.classList.remove('is-active');
      autoplayBtn.setAttribute('aria-pressed', 'false');
      autoplayBtn.innerHTML = '<i class="fa-solid fa-play" aria-hidden="true"></i><span>auto</span>';
    };

    const render = () => {
      const total = slides.length;
      if (!total) return;
      track.style.transform = `translateX(-${index * 100}%)`;
      slides.forEach((s, i) => s.classList.toggle('is-active', i === index));
      thumbs.forEach((t, i) => t.classList.toggle('is-active', i === index));
      if (counterEl) counterEl.textContent = `${pad2(index + 1)} / ${pad2(total)}`;
      const img = slides[index].querySelector('img');
      if (captionEl && img) captionEl.textContent = img.alt;
      if (thumbs[index]) thumbs[index].scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
    };

    const goTo = (i) => {
      const total = slides.length;
      if (!total) return;
      index = (i + total) % total;
      render();
    };
    const next = () => goTo(index + 1);
    const prev = () => goTo(index - 1);

    const stopAutoplay = () => {
      if (autoplayTimer) { clearInterval(autoplayTimer); autoplayTimer = null; }
    };
    const startAutoplay = () => {
      stopAutoplay();
      if (!reduceMotion) autoplayTimer = setInterval(next, 3500);
    };

    // reconstruit les diapositives / miniatures à partir du <template> du projet cliqué
    const load = (fragment, title) => {
      track.innerHTML = '';
      filmstrip.innerHTML = '';
      track.appendChild(fragment.cloneNode(true));
      slides = Array.from(track.querySelectorAll('.gallery-slide'));

      slides.forEach((slide, i) => {
        const img = slide.querySelector('img');
        if (!img) return;
        img.loading = 'eager';

        const thumb = document.createElement('button');
        thumb.type = 'button';
        thumb.className = 'gallery-thumb';
        thumb.setAttribute('aria-label', `Aller à l'image ${i + 1}`);

        const thumbImg = document.createElement('img');
        thumbImg.src = img.currentSrc || img.src;
        thumbImg.alt = '';
        thumbImg.loading = 'lazy';
        thumb.appendChild(thumbImg);

        thumb.addEventListener('click', () => { goTo(i); if (autoplayOn) startAutoplay(); });
        filmstrip.appendChild(thumb);
      });

      thumbs = Array.from(filmstrip.querySelectorAll('.gallery-thumb'));
      if (titleEl) titleEl.textContent = title || '';
      index = 0;
      render();
    };

    const open = (fragment, title, trigger) => {
      lastFocused = trigger || document.activeElement;
      load(fragment, title);
      root.classList.add('is-open');
      root.setAttribute('aria-hidden', 'false');
      document.body.classList.add('lightbox-locked');
      if (closeBtn) closeBtn.focus();
    };

    const close = () => {
      root.classList.remove('is-open');
      root.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('lightbox-locked');
      stopAutoplay();
      autoplayOn = false;
      resetAutoplayButton();
      if (lastFocused && typeof lastFocused.focus === 'function') lastFocused.focus();
    };

    if (prevBtn) prevBtn.addEventListener('click', () => { prev(); if (autoplayOn) startAutoplay(); });
    if (nextBtn) nextBtn.addEventListener('click', () => { next(); if (autoplayOn) startAutoplay(); });
    if (closeBtn) closeBtn.addEventListener('click', close);
    if (backdrop) backdrop.addEventListener('click', close);

    document.addEventListener('keydown', (e) => {
      if (!root.classList.contains('is-open')) return;
      if (e.key === 'Escape') close();
      else if (e.key === 'ArrowLeft') { prev(); if (autoplayOn) startAutoplay(); }
      else if (e.key === 'ArrowRight') { next(); if (autoplayOn) startAutoplay(); }
    });

    if (autoplayBtn) {
      autoplayBtn.addEventListener('click', () => {
        autoplayOn = !autoplayOn;
        autoplayBtn.classList.toggle('is-active', autoplayOn);
        autoplayBtn.setAttribute('aria-pressed', String(autoplayOn));
        autoplayBtn.innerHTML = autoplayOn
          ? '<i class="fa-solid fa-pause" aria-hidden="true"></i><span>auto</span>'
          : '<i class="fa-solid fa-play" aria-hidden="true"></i><span>auto</span>';
        if (autoplayOn) startAutoplay(); else stopAutoplay();
      });
    }

    // glisser / balayer pour changer d'image
    let dragging = false;
    let startX = 0;
    let deltaX = 0;
    let widthPx = 1;

    const dragStart = (x) => {
      dragging = true;
      startX = x;
      deltaX = 0;
      widthPx = stage.getBoundingClientRect().width || 1;
      track.style.transition = 'none';
      if (autoplayOn) stopAutoplay();
    };
    const dragMove = (x) => {
      if (!dragging) return;
      deltaX = x - startX;
      const percent = (deltaX / widthPx) * 100;
      track.style.transform = `translateX(calc(-${index * 100}% + ${percent}%))`;
    };
    const dragEnd = () => {
      if (!dragging) return;
      dragging = false;
      track.style.transition = '';
      const threshold = widthPx * 0.15;
      if (deltaX > threshold) prev();
      else if (deltaX < -threshold) next();
      else render();
      if (autoplayOn) startAutoplay();
    };

    stage.addEventListener('touchstart', (e) => dragStart(e.touches[0].clientX), { passive: true });
    stage.addEventListener('touchmove', (e) => dragMove(e.touches[0].clientX), { passive: true });
    stage.addEventListener('touchend', dragEnd);

    stage.addEventListener('pointerdown', (e) => {
      if (e.pointerType === 'touch') return;
      dragStart(e.clientX);
      stage.setPointerCapture(e.pointerId);
    });
    stage.addEventListener('pointermove', (e) => {
      if (e.pointerType === 'touch') return;
      dragMove(e.clientX);
    });
    stage.addEventListener('pointerup', (e) => {
      if (e.pointerType === 'touch') return;
      dragEnd();
    });
    stage.addEventListener('pointerleave', () => { if (dragging) dragEnd(); });

    return { open };
  };

  const lightboxRoot = document.querySelector('[data-lightbox]');
  if (lightboxRoot) {
    const lightbox = createLightboxGallery(lightboxRoot);

    document.querySelectorAll('[data-gallery-trigger]').forEach((trigger) => {
      trigger.addEventListener('click', () => {
        const mediaWrap = trigger.closest('.project-media');
        const template = mediaWrap ? mediaWrap.querySelector('[data-gallery-template]') : null;
        if (!template) return;
        const title = trigger.getAttribute('data-gallery-title') || '';
        lightbox.open(template.content, title, trigger);
      });
    });
  }

})();