/* ════════════════════════════════════════════════════════════════
   show_familia_producto.js
   Catálogo de productos — Kares ERP
   ════════════════════════════════════════════════════════════════ */

'use strict';

$(document).ready(function () {

    /* ── Variables del buscador — declaradas PRIMERO ────────────
       Deben estar antes de cualquier listener que llame a
       filterProducts(), para evitar que queden en undefined
       cuando el tab restaurado dispare shown.bs.tab.        */
    var $search     = $('#product-search');
    var $countLabel = $('#search-count');

    /* ── Función de filtrado ─────────────────────────────────── */
    function filterProducts() {
        /* Leer directamente del DOM como fallback de seguridad contra hoisting */
        var $s   = (typeof $search !== 'undefined' && $search && $search.length) ? $search : $('#product-search');
        var term = ($s && $s.length) ? $s.val().trim().toLowerCase() : '';

        var visible = 0;
        var total   = 0;

        /* Solo operar sobre el tab activo */
        var $activePane = $('.tab-pane.show.active');
        if (!$activePane.length) $activePane = $('.tab-pane.active');

        $activePane.find('.product-box').each(function () {
            var name = $(this).find('h5').text().toLowerCase();
            total++;
            if (!term || name.includes(term)) {
                $(this).removeClass('hidden');
                visible++;
            } else {
                $(this).addClass('hidden');
            }
        });

        var $lbl = (typeof $countLabel !== 'undefined' && $countLabel && $countLabel.length) ? $countLabel : $('#search-count');
        if ($lbl && $lbl.length) {
            $lbl.text(term ? (visible + '/' + total) : '');
        }
    }

    /* ── 1. Persistir / restaurar tab activo ────────────────── */
    $('a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
        localStorage.setItem('activeMenuTab', $(e.target).attr('href'));
        filterProducts();
    });

    /* Limpiar búsqueda al iniciar cambio de tab */
    $('a[data-toggle="pill"]').on('show.bs.tab', function () {
        $search.val('');
        $countLabel.text('');
    });

    var savedTab = localStorage.getItem('activeMenuTab');
    if (savedTab) {
        var $savedLink = $('#custom-tabs-menu a[href="' + savedTab + '"]');
        if ($savedLink.length) $savedLink.tab('show');
    }

    /* ── 2. Botones +/− de cantidad ─────────────────────────── */
    $(document).on('click', '.qty-plus', function () {
        var $input = $(this).closest('.qty-wrapper').find('.qty-input');
        var val = parseInt($input.val()) || 1;
        $input.val(Math.min(val + 1, 99));
    });

    $(document).on('click', '.qty-minus', function () {
        var $input = $(this).closest('.qty-wrapper').find('.qty-input');
        var val = parseInt($input.val()) || 1;
        $input.val(Math.max(val - 1, 1));
    });

    /* Seleccionar todo al hacer focus en el input de cantidad */
    $(document).on('focus', '.qty-input', function () {
        $(this).select();
    });

    /* ── 3. Agregar producto vía AJAX ───────────────────────── */
    $(document).on('click', '.btn-add-producto', function (e) {
        e.preventDefault();

        var $btn       = $(this);
        var idServicio = $btn.data('id-servicio');
        var $box       = $btn.closest('.product-box');
        var cantidad   = parseInt($box.find('.qty-input').val()) || 1;

        if (cantidad < 1 || cantidad > 99) {
            showToast('error', 'Cantidad inválida (1-99)');
            return;
        }

        $btn.prop('disabled', true);
        $btn.html('<i class="fas fa-spinner fa-spin"></i>');

        $.ajax({
            url:      'add_venta_ajax.jsp',
            type:     'POST',
            data:     { f_id_servicio: idServicio, f_cantidad: cantidad, modo_venta: 2 },
            dataType: 'json',
            success: function (res) {
                if (res.success) {
                    showToast('success', cantidad + ' × ' + $box.find('h5').text().trim() + ' agregado');

                    /* Animación flash */
                    $box.addClass('product-added');
                    setTimeout(function () { $box.removeClass('product-added'); }, 450);

                    /* Resetear cantidad */
                    $box.find('.qty-input').val('1');

                    /* Notificar al shell padre para recargar iframe de venta */
                    if (window.parent && typeof window.parent.actualizarTotalVenta === 'function') {
                        window.parent.actualizarTotalVenta();
                    }
                } else {
                    showToast('error', res.message || 'No se pudo agregar');
                }
            },
            error: function (xhr) {
                showToast('error', 'Error de conexión');
                console.error('AJAX error:', xhr.responseText);
            },
            complete: function () {
                $btn.prop('disabled', false);
                $btn.html('<i class="fas fa-cart-plus"></i> Agregar');
            }
        });
    });

    /* Agregar con Enter en input de cantidad */
    $(document).on('keypress', '.qty-input', function (e) {
        if (e.which === 13) {
            e.preventDefault();
            $(this).closest('.product-box').find('.btn-add-producto').trigger('click');
        }
    });

    /* ── 4. Listener del buscador ────────────────────────────── */
    $search.on('input', filterProducts);

    /* ── 5. Toast nativo ────────────────────────────────────── */
    window.showToast = function (type, msg) {
        var $container = $('#catalog-toast');
        var icon = type === 'success'
            ? '<i class="fas fa-check-circle"></i>'
            : '<i class="fas fa-exclamation-triangle"></i>';

        var $item = $('<div>')
            .addClass('toast-item toast-' + type)
            .html(icon + ' ' + msg);

        $container.append($item);

        setTimeout(function () {
            $item.fadeOut(300, function () { $(this).remove(); });
        }, 2800);
    };

});