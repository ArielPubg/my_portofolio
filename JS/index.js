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

})();