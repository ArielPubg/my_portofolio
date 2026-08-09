(() => {
  'use strict';

  /* =========================================================
     GOOGLE ANALYTICS — remplace G-XXXXXXXXXX par ton ID GA4
     (Google Analytics > Admin > Flux de données > ID de mesure)
     ========================================================= */
  const GA_MEASUREMENT_ID = 'G-DN1P7SJ6SX';

  const CONSENT_KEY = 'ariel-analytics-consent'; // 'granted' | 'denied'

  const loadGoogleAnalytics = () => {
    if (window.__gaLoaded) return;
    window.__gaLoaded = true;

    const script = document.createElement('script');
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`;
    document.head.appendChild(script);

    window.dataLayer = window.dataLayer || [];
    function gtag() { window.dataLayer.push(arguments); }
    window.gtag = gtag;

    gtag('js', new Date());
    gtag('consent', 'default', {
      analytics_storage: 'granted'
    });
    gtag('config', GA_MEASUREMENT_ID, { anonymize_ip: true });
  };

  /* =========================================================
     BANNIÈRE DE CONSENTEMENT
     ========================================================= */
  const bar = document.getElementById('consent-bar');
  const acceptBtn = document.getElementById('consent-accept');
  const declineBtn = document.getElementById('consent-decline');
  const stored = localStorage.getItem(CONSENT_KEY);

  if (stored === 'granted') {
    loadGoogleAnalytics();
  } else if (stored !== 'denied') {
    // Pas encore de choix : on affiche la bannière après un court délai
    setTimeout(() => { bar.hidden = false; }, 800);
  }

  acceptBtn?.addEventListener('click', () => {
    localStorage.setItem(CONSENT_KEY, 'granted');
    bar.hidden = true;
    loadGoogleAnalytics();
  });

  declineBtn?.addEventListener('click', () => {
    localStorage.setItem(CONSENT_KEY, 'denied');
    bar.hidden = true;
  });

})();