document.addEventListener('DOMContentLoaded', function () {

    // Precargar imágenes para mejor rendimiento
    document.querySelectorAll('.module-icon').forEach(img => {
        new Image().src = img.src;
    });

    // Hover & focus en cards (sin sobreescribir la animación inicial)
    document.querySelectorAll('.module-card').forEach(card => {
        const link = card.querySelector('.module-link');

        card.addEventListener('mouseenter', () => card.style.transform = 'translateY(-10px)');
        card.addEventListener('mouseleave', () => card.style.transform = 'translateY(0)');

        link.addEventListener('focus',  () => card.style.transform = 'translateY(-5px)');
        link.addEventListener('blur',   () => card.style.transform = 'translateY(0)');
    });
});

// Reajuste al cambiar orientación en móvil
window.addEventListener('orientationchange', () => {
    setTimeout(() => window.scrollTo(0, 0), 100);
});
