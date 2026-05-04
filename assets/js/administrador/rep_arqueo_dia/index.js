/* Scripts for Arqueo Diario Index */
$(function() {
    if (typeof flatpickr !== 'undefined') {
        flatpickr('#f_fecha_ini', { 
            locale: 'es', 
            dateFormat: 'd/m/Y', 
            allowInput: false 
        });
    }

    function resizeFrame() {
        var hdr  = document.querySelector('.page-header-bar');
        var flt  = document.querySelector('.content-area');
        var wrap = document.querySelector('.frame-wrapper');
        if(hdr && flt && wrap) {
            var used = hdr.offsetHeight + flt.offsetHeight + 22;
            wrap.style.height = (window.innerHeight - used) + 'px';
        }
    }

    window.addEventListener('resize', resizeFrame);
    window.addEventListener('load',   resizeFrame);
    
    // Initial resize
    setTimeout(resizeFrame, 100);
});
