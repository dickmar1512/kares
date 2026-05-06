/* ════════════════════════════════════════════════════════════════
   form_venta.js — Panel de carrito + órdenes
   Kares ERP
   ════════════════════════════════════════════════════════════════ */

'use strict';

/* ── Calcular suma cuando cambia precio ─────────────────────── */
function calcular(i) {
    var s = suma();
    var sumaInput = document.querySelector('input[name="f_suma"]');
    if (sumaInput) sumaInput.value = s;
    actualizarFooterTotal(s);
}

function suma() {
    var valor = 0;
    var num = Number(document.datos.cont_items.value);
    for (var idx = 1; idx <= num; idx++) {
        var cambiar = document.datos['f_cambia_precio_' + idx]
            ? document.datos['f_cambia_precio_' + idx].value : '0';
        var temp = '0';
        if (cambiar === '3') {
            temp = document.datos['f_total_nuevo_' + idx]
                ? document.datos['f_total_nuevo_' + idx].value : '0';
        } else {
            temp = document.datos['f_total_' + idx]
                ? document.datos['f_total_' + idx].value : '0';
        }
        if (isNaN(parseFloat(temp))) temp = 0;
        valor = parseFloat(valor) + parseFloat(temp);
    }
    return valor.toFixed(2);
}

/* ── Sincronizar valor en footer ────────────────────────────── */
function actualizarFooterTotal(val) {
    var el = document.getElementById('footer-total-val');
    if (el) el.textContent = parseFloat(val).toFixed(2);
}

/* ── Generar orden ──────────────────────────────────────────── */
function generarOrden() {
    var btn = document.getElementById('btn-generar-orden');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
    }
    var loader = document.getElementById('loader-overlay');
    if (loader) loader.style.display = 'flex';

    document.datos.action = 'nueva_orden.jsp';
    document.datos.submit();
}

/* ── Recalcular totales tras eliminar fila ──────────────────── */
function recalcularTotales() {
    var total = 0;
    var count = 0;
    var rows  = document.querySelectorAll('#detalle-items tr');

    rows.forEach(function (row) {
        count++;
        /* Actualizar badge de número */
        var badge = row.querySelector('.item-num');
        if (badge) badge.textContent = count;

        /* Re-indexar inputs */
        row.querySelectorAll('input').forEach(function (input) {
            var oldName = input.name;
            if (oldName && oldName.includes('_')) {
                var base = oldName.substring(0, oldName.lastIndexOf('_'));
                input.name = base + '_' + count;
            }
        });

        /* Sumar totales activos */
        var estadoInput = row.querySelector('input[name="f_estado_det_' + count + '"]');
        var totalInput  = row.querySelector('input[name="f_total_' + count + '"]');
        if (estadoInput && estadoInput.value === 'P' && totalInput) {
            total += parseFloat(totalInput.value) || 0;
        }
    });

    /* Actualizar badge header */
    var badge = document.getElementById('badge-items');
    if (badge) badge.textContent = count + ' ítem' + (count !== 1 ? 's' : '');

    /* Actualizar label de items en tfoot */
    var lblItems = document.getElementById('lbl-total-items');
    if (lblItems) lblItems.textContent = count;

    /* Actualizar conteo global */
    var contInput = document.querySelector('input[name="cont_items"]');
    if (contInput) contInput.value = count;

    /* Actualizar total */
    var sumaInput = document.querySelector('input[name="f_suma"]');
    if (sumaInput) {
        sumaInput.value = total.toFixed(2);
    } else {
        var lblSuma = document.getElementById('lbl-suma');
        if (lblSuma) lblSuma.textContent = total.toFixed(2);
    }

    actualizarFooterTotal(total.toFixed(2));

    /* Si no quedan ítems → ocultar footer sticky */
    if (count === 0) {
        var footerBar = document.getElementById('carrito-footer-bar');
        if (footerBar) footerBar.style.display = 'none';
    }
}

/* ── Eliminar ítem ──────────────────────────────────────────── */
async function eliminarItem(id_movart, rowId) {
    var result = await Swal.fire({
        title: '¿Eliminar este ítem?',
        text: 'Se quitará del carrito de la orden.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#991b1b',
        cancelButtonColor: '#64748b',
        confirmButtonText: '<i class="fas fa-trash-alt"></i> Sí, eliminar',
        cancelButtonText: 'Cancelar',
        customClass: { popup: 'swal2-sm' }
    });

    if (!result.isConfirmed) return;

    var row = document.getElementById(rowId);
    if (!row) return;
    row.style.opacity = '0.4';
    row.style.pointerEvents = 'none';

    try {
        var response = await fetch('eliminar_ajax.jsp?f_id_movart=' + id_movart);
        var data = await response.json();

        if (data.success) {
            Swal.mixin({
                toast: true, position: 'top-end',
                showConfirmButton: false,
                timer: 1400, timerProgressBar: true
            }).fire({ icon: 'success', title: 'Ítem eliminado' });

            row.style.transition = 'all .35s ease';
            row.style.transform  = 'translateX(16px)';
            row.style.opacity    = '0';
            setTimeout(function () {
                row.remove();
                recalcularTotales();
            }, 360);
        } else {
            Swal.fire('Error', data.message, 'error');
            row.style.opacity = '1';
            row.style.pointerEvents = 'auto';
        }
    } catch (err) {
        console.error('eliminarItem error:', err);
        Swal.fire('Error', 'Error de conexión al eliminar el ítem.', 'error');
        row.style.opacity = '1';
        row.style.pointerEvents = 'auto';
    }
}