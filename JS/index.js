// 1. Initialisation des animations AOS
AOS.init({
    duration: 1000,
    once: true,
    offset: 120
});

// 2. Gestion du Mode Sombre/Clair
const themeButton = document.getElementById('theme-button');
const body = document.body;

// Vérifier si une préférence existe déjà dans le navigateur
const currentTheme = localStorage.getItem('theme');
if (currentTheme) {
    body.setAttribute('data-theme', currentTheme);
    if (currentTheme === 'dark') {
        themeButton.innerHTML = '<i class="fas fa-sun"></i>';
    }
}

themeButton.addEventListener('click', () => {
    let theme = body.getAttribute('data-theme');
    
    if (theme === 'light') {
        body.setAttribute('data-theme', 'dark');
        themeButton.innerHTML = '<i class="fas fa-sun"></i>';
        localStorage.setItem('theme', 'dark');
    } else {
        body.setAttribute('data-theme', 'light');
        themeButton.innerHTML = '<i class="fas fa-moon"></i>';
        localStorage.setItem('theme', 'light');
    }
});

// 3. Défilement fluide (Smooth Scroll) pour tous les liens
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const targetId = this.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - 80, // Offset pour la navbar fixe
                behavior: 'smooth'
            });
            
            // Fermer le menu mobile de bootstrap après clic
            const navbarCollapse = document.querySelector('.navbar-collapse');
            if (navbarCollapse.classList.contains('show')) {
                const bsCollapse = new bootstrap.Collapse(navbarCollapse);
                bsCollapse.hide();
            }
        }
    });
});

// 4. Animation des barres de progression au scroll
window.addEventListener('scroll', () => {
    const sectionSkills = document.getElementById('skills');
    const position = sectionSkills.getBoundingClientRect();
    
    // Si la section skills est visible
    if(position.top < window.innerHeight && position.bottom >= 0) {
        document.querySelectorAll('.progress-bar').forEach(bar => {
            // L'animation CSS se déclenche
            bar.style.opacity = "1";
        });
    }
});