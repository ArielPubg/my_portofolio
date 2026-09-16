(() => {
  'use strict';
  /* ================= PAGE LOADER (logo rotatif) ================= */
  const pageLoader = document.getElementById('page-loader');
  if (pageLoader) {
    // On impose un temps minimum d'affichage pour éviter un flash
    const MIN_DURATION = 900; // ms
    const startTime = performance.now();

    const hideLoader = () => {
      const elapsed = performance.now() - startTime;
      const remaining = Math.max(0, MIN_DURATION - elapsed);
      setTimeout(() => {
        pageLoader.classList.add('is-hidden');
        // Suppression complète après la transition
        setTimeout(() => pageLoader.remove(), 700);
      }, remaining);
    };

    if (document.readyState === 'complete') {
      hideLoader();
    } else {
      window.addEventListener('load', hideLoader, { once: true });
      // Sécurité : si le load met trop de temps (vidéo lourde), on cache après 4s max
      setTimeout(() => { if (document.body.contains(pageLoader)) hideLoader(); }, 4000);
    }
  }
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

  /* ================= DOC VIEWER (notebook + scripts R + rapports) ================= */
  const docViewerRoot = document.querySelector('[data-doc-viewer]');
  if (docViewerRoot) {
    const contentEl = docViewerRoot.querySelector('[data-doc-content]');
    const titleEl   = docViewerRoot.querySelector('[data-doc-title]');
    const closeBtn  = docViewerRoot.querySelector('[data-doc-close]');
    const backdrop  = docViewerRoot.querySelector('[data-doc-backdrop]');
    const tabs      = Array.from(docViewerRoot.querySelectorAll('[data-doc-tab]'));

    let sources = { notebook: null, report: null };
    let lastFocused = null;
    const cache = new Map();

    const showLoading = () => {
      contentEl.innerHTML =
        '<div class="doc-loading"><i class="fa-solid fa-circle-notch fa-spin" aria-hidden="true"></i>' +
        '<span>Chargement du document…</span></div>';
    };
    const showError = (msg) => {
      contentEl.innerHTML =
        '<div class="doc-error"><i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>' +
        '<span></span></div>';
      contentEl.querySelector('span').textContent = msg;
    };

    const joinSource = (src) => Array.isArray(src) ? src.join('') : (src || '');
    const baseOf = (url) => url.substring(0, url.lastIndexOf('/') + 1);

    const resolveRelative = (base, src) => {
      if (!src) return src;
      if (/^(https?:|data:|blob:|\/\/|\/)/i.test(src)) return src;
      return base + src.replace(/^\.\//, '');
    };

    const mdToHtml = (md) => {
      if (window.marked && typeof window.marked.parse === 'function') {
        try { return window.marked.parse(md); } catch (e) { /* fallback */ }
      }
      const div = document.createElement('div');
      div.textContent = md;
      return div.innerHTML.replace(/\n/g, '<br>');
    };

    const renderMarkdownInto = (el, md, base) => {
      el.innerHTML = mdToHtml(md);
      el.querySelectorAll('img[src]').forEach(img => {
        img.src = resolveRelative(base, img.getAttribute('src'));
      });
      el.querySelectorAll('a[href]').forEach(a => {
        const href = a.getAttribute('href');
        if (href && !/^(https?:|mailto:|tel:|#|\/)/i.test(href)) {
          a.setAttribute('href', resolveRelative(base, href));
        }
      });
    };

    /* --- Construction des documents --- */

    const buildMarkdownDoc = (text, base) => {
      const wrap = document.createElement('article');
      wrap.className = 'doc-markdown';
      renderMarkdownInto(wrap, text, base);
      return wrap;
    };

    const buildRCodeDoc = (text, url) => {
      const wrap = document.createElement('div');
      wrap.className = 'doc-code-wrap';

      const header = document.createElement('div');
      header.className = 'doc-code-header';
      const fileName = url.split('/').pop();
      header.innerHTML =
        '<i class="fa-solid fa-file-code" aria-hidden="true"></i>' +
        '<span></span>' +
        '<span class="doc-code-lines"></span>';
      header.querySelector('span:not(.doc-code-lines)').textContent = fileName;
      header.querySelector('.doc-code-lines').textContent = text.split('\n').length + ' lignes';
      wrap.appendChild(header);

      const pre = document.createElement('pre');
      pre.className = 'doc-code';
      const code = document.createElement('code');
      code.className = 'language-r';

      // Découpage en lignes pour numérotation CSS
      text.split('\n').forEach(line => {
        const span = document.createElement('span');
        span.className = 'line';
        span.textContent = line + '\n';
        code.appendChild(span);
      });

      pre.appendChild(code);
      wrap.appendChild(pre);

      if (window.hljs) {
        try { window.hljs.highlightElement(code); } catch (e) { /* silencieux */ }
      }
      return wrap;
    };

    const buildNotebookCell = (cell, base) => {
      if (cell.cell_type === 'markdown' || cell.cell_type === 'raw') {
        const div = document.createElement('div');
        div.className = 'nb-cell nb-cell--markdown';
        renderMarkdownInto(div, joinSource(cell.source), base);
        return div;
      }
      if (cell.cell_type !== 'code') return null;

      const wrap = document.createElement('div');
      wrap.className = 'nb-cell nb-cell--code';

      const prompt = document.createElement('span');
      prompt.className = 'nb-prompt';
      prompt.textContent = 'In [' + (cell.execution_count != null ? cell.execution_count : ' ') + ']:';
      wrap.appendChild(prompt);

      const input = document.createElement('pre');
      input.className = 'nb-code nb-input';
      const code = document.createElement('code');
      code.textContent = joinSource(cell.source);
      input.appendChild(code);
      wrap.appendChild(input);

      (cell.outputs || []).forEach(out => {
        const outEl = document.createElement('div');
        outEl.className = 'nb-output';

        if (out.output_type === 'stream') {
          const pre = document.createElement('pre');
          pre.className = 'nb-stream';
          pre.textContent = joinSource(out.text);
          outEl.appendChild(pre);
        } else if (out.output_type === 'error') {
          const pre = document.createElement('pre');
          pre.className = 'nb-error';
          pre.textContent = Array.isArray(out.traceback) ? out.traceback.join('\n') : (out.evalue || '');
          outEl.appendChild(pre);
        } else {
          const data = out.data || {};
          const png = data['image/png'];
          const jpg = data['image/jpeg'];
          if (png || jpg) {
            const img = document.createElement('img');
            img.className = 'nb-image';
            img.alt = 'Sortie graphique';
            img.loading = 'lazy';
            const raw = joinSource(png || jpg).replace(/\s+/g, '');
            img.src = 'data:image/' + (png ? 'png' : 'jpeg') + ';base64,' + raw;
            outEl.appendChild(img);
          }
          if (data['text/html']) {
            const div = document.createElement('div');
            div.className = 'nb-html';
            div.innerHTML = joinSource(data['text/html']);
            outEl.appendChild(div);
          }
          if (data['text/plain'] && !png && !jpg && !data['text/html']) {
            const pre = document.createElement('pre');
            pre.className = 'nb-stream';
            pre.textContent = joinSource(data['text/plain']);
            outEl.appendChild(pre);
          }
        }
        if (outEl.childNodes.length) wrap.appendChild(outEl);
      });
      return wrap;
    };

    const buildNotebookDoc = (nb, base) => {
      const wrap = document.createElement('div');
      wrap.className = 'doc-notebook';
      (nb.cells || []).forEach(cell => {
        const el = buildNotebookCell(cell, base);
        if (el) wrap.appendChild(el);
      });
      return wrap;
    };

    /* --- Fetchers par extension --- */

  /* =========================================================
       buildExcelDoc — lecteur Excel (SheetJS)
       ========================================================= */

const buildExcelDoc = (arrayBuffer) => {
  const wb = XLSX.read(arrayBuffer, { type: 'array' });
  const wrap = document.createElement('div');
  wrap.className = 'doc-excel';

  const tabsBar = document.createElement('div');
  tabsBar.className = 'doc-excel-tabs';

  const note = document.createElement('div');
  note.className = 'doc-excel-note';
  note.innerHTML =
    '<i class="fa-solid fa-circle-info" aria-hidden="true"></i>' +
    '<span>Aperçu des données et valeurs calculées. Graphiques, couleurs et macros VBA ' +
    'sont visibles dans le fichier téléchargeable.</span>';

  const tableWrap = document.createElement('div');
  tableWrap.className = 'doc-excel-table-wrap';

  wrap.appendChild(tabsBar);
  wrap.appendChild(note);
  wrap.appendChild(tableWrap);

  const sheetNames = wb.SheetNames;

  const renderSheet = (name) => {
    const ws = wb.Sheets[name];
    tableWrap.innerHTML = XLSX.utils.sheet_to_html(ws, { editable: false, id: undefined });
    const table = tableWrap.querySelector('table');
    if (table) {
      table.classList.add('doc-excel-grid');
      table.removeAttribute('border');
      table.removeAttribute('cellpadding');
      table.removeAttribute('cellspacing');
    }
    Array.from(tabsBar.children).forEach(btn =>
      btn.classList.toggle('is-active', btn.dataset.sheet === name));
  };

  sheetNames.forEach((name) => {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'doc-excel-tab';
    btn.textContent = name;
    btn.dataset.sheet = name;
    btn.addEventListener('click', () => renderSheet(name));
    tabsBar.appendChild(btn);
  });

  // ouvre sur l'onglet "Dashboard" s'il existe, sinon le premier
  renderSheet(sheetNames.includes('Dashboard') ? 'Dashboard' : sheetNames[0]);
  return wrap;
};

/* =========================================================
       fetchDoc — routeur par extension
       (.ipynb | .r | .md | .xlsx/.xlsm/.xls)
 ========================================================= */

const fetchDoc = async (url, kind) => {
  const ext = url.split('.').pop().toLowerCase();
  const base = baseOf(url);

  if (['xlsx', 'xlsm', 'xls'].includes(ext)) {
    const res = await fetch(url, { cache: 'force-cache' });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const buf = await res.arrayBuffer();
    return buildExcelDoc(buf);
  }

  const res = await fetch(url, { cache: 'force-cache' });
  if (!res.ok) throw new Error('HTTP ' + res.status);

  if (ext === 'ipynb') {
    const json = await res.json();
    return buildNotebookDoc(json, base);
  }
  const text = await res.text();
  if (ext === 'r') return buildRCodeDoc(text, url);
  return buildMarkdownDoc(text, base);
};

    /* --- Onglets --- */

    const setActiveTab = (name) => {
      tabs.forEach(t => {
        const active = t.dataset.docTab === name;
        t.classList.toggle('is-active', active);
        t.setAttribute('aria-selected', String(active));
      });
    };

    const renderTab = async (name) => {
      setActiveTab(name);
      const url = sources[name];
      if (!url) { showError('Aucune source pour cet onglet.'); return; }

      if (cache.has(url)) {
        contentEl.innerHTML = '';
        contentEl.appendChild(cache.get(url));
        contentEl.scrollTop = 0;
        return;
      }
      showLoading();
      try {
        const node = await fetchDoc(url, name);
        cache.set(url, node);
        contentEl.innerHTML = '';
        contentEl.appendChild(node);
        contentEl.scrollTop = 0;
      } catch (err) {
        console.error(err);
        showError('Impossible de charger le document (' + url + ').');
      }
    };

    /* --- Ouverture / fermeture --- */

    const openViewer = (tabName, config, title, trigger) => {
      sources = config;
      lastFocused = trigger || document.activeElement;
      if (titleEl) titleEl.textContent = title || 'documentation';
      docViewerRoot.classList.add('is-open');
      docViewerRoot.setAttribute('aria-hidden', 'false');
      document.body.classList.add('lightbox-locked');
      if (closeBtn) closeBtn.focus();
      renderTab(tabName || 'notebook');
    };

    const closeViewer = () => {
      docViewerRoot.classList.remove('is-open');
      docViewerRoot.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('lightbox-locked');
      if (lastFocused && typeof lastFocused.focus === 'function') lastFocused.focus();
    };

    tabs.forEach(t => t.addEventListener('click', () => renderTab(t.dataset.docTab)));
    if (closeBtn) closeBtn.addEventListener('click', closeViewer);
    if (backdrop) backdrop.addEventListener('click', closeViewer);
    document.addEventListener('keydown', (e) => {
      if (!docViewerRoot.classList.contains('is-open')) return;
      if (e.key === 'Escape') closeViewer();
    });

    /* --- Déclencheurs --- */
    document.querySelectorAll('[data-doc-open]').forEach(btn => {
      btn.addEventListener('click', () => {
        const card = btn.closest('[data-project-docs]');
        if (!card) return;
        const config = {
          notebook: card.getAttribute('data-notebook-src'),
          report:   card.getAttribute('data-report-src')
        };
        const title = card.getAttribute('data-doc-title') || 'documentation';
        openViewer(btn.getAttribute('data-doc-open'), config, title, btn);
      });
    });
  }

  /* ================= CERT VIEWER (lecture PDF en grand) ================= */
  const certViewerRoot = document.querySelector('[data-cert-viewer]');
  if (certViewerRoot) {
    const contentEl = certViewerRoot.querySelector('[data-cert-content]');
    const titleEl   = certViewerRoot.querySelector('[data-cert-title]');
    const closeBtn  = certViewerRoot.querySelector('[data-cert-close]');
    const backdrop  = certViewerRoot.querySelector('[data-cert-backdrop]');
    const dlLink    = certViewerRoot.querySelector('[data-cert-download]');
    const extLink   = certViewerRoot.querySelector('[data-cert-external]');

    let lastFocused = null;

    const openCert = (src, title, trigger) => {
      lastFocused = trigger || document.activeElement;

      if (titleEl) titleEl.textContent = title || src.split('/').pop();
      if (dlLink)  dlLink.setAttribute('href', src);
      if (extLink) extLink.setAttribute('href', src);

      // Rendu : PDF → iframe, image → <img>, autre → iframe générique
      const ext = src.split('.').pop().toLowerCase();
      contentEl.innerHTML = '';

      if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'].includes(ext)) {
        const img = document.createElement('img');
        img.src = src;
        img.alt = title || 'Certificat';
        contentEl.appendChild(img);
      } else {
        const iframe = document.createElement('iframe');
        iframe.src = src + '#view=FitH';
        iframe.setAttribute('title', title || 'Certificat');
        iframe.setAttribute('loading', 'eager');
        contentEl.appendChild(iframe);
      }

      certViewerRoot.classList.add('is-open');
      certViewerRoot.setAttribute('aria-hidden', 'false');
      document.body.classList.add('lightbox-locked');
      if (closeBtn) closeBtn.focus();
    };

    const closeCert = () => {
      certViewerRoot.classList.remove('is-open');
      certViewerRoot.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('lightbox-locked');
      // Libère la mémoire : le PDF est rechargé à la prochaine ouverture
      contentEl.innerHTML = '';
      if (lastFocused && typeof lastFocused.focus === 'function') lastFocused.focus();
    };

    if (closeBtn) closeBtn.addEventListener('click', closeCert);
    if (backdrop) backdrop.addEventListener('click', closeCert);
    document.addEventListener('keydown', (e) => {
      if (!certViewerRoot.classList.contains('is-open')) return;
      if (e.key === 'Escape') closeCert();
    });

    document.querySelectorAll('[data-cert-open]').forEach(btn => {
      btn.addEventListener('click', () => {
        const src   = btn.getAttribute('data-cert-src');
        const title = btn.getAttribute('data-cert-title');
        if (!src) return;
        openCert(src, title, btn);
      });
    });
  }})();