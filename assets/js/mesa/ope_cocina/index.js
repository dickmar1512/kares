/* ══════════════════════════════════════════════════════════════════
   Dashboard Cocina — index.js
   Lógica de audio, notificaciones, DataTable y auto-refresh.

   Disparador de sonido:  SOLO cuando aumentan los ítems RECIBIDOS
   (estado_atencion = 0), es decir, llegó un pedido nuevo que aún
   nadie ha tomado.
   ══════════════════════════════════════════════════════════════════ */

'use strict';

/* ── Storage keys ────────────────────────────────────────────────── */
const KEY_REFRESH  = 'kitchen_refresh_enabled';
const KEY_RECIBIDOS = 'kitchen_last_recibidos';   // ← clave del sonido

/* ── Estado de audio ─────────────────────────────────────────────── */
let audioUnlocked    = false;
let pendingAudioPlay = false;

/* ════════════════════════════════════════════════════════════════════
   AUDIO
   ════════════════════════════════════════════════════════════════════ */

/**
 * Intenta desbloquear el AudioContext en el primer gesto del usuario.
 * El navegador bloquea la reproducción automática hasta que hay
 * una interacción (click, touch, teclado).
 */
function unlockAudioMP3() {
    if (audioUnlocked) return;

    const unlock = function () {
        const sound = document.getElementById('order-sound');
        if (!sound) return;

        sound.volume = 0;
        const p = sound.play();

        if (p !== undefined) {
            p.then(() => {
                sound.pause();
                sound.currentTime = 0;
                sound.volume = 1;
                audioUnlocked = true;
                console.log('✅ Audio desbloqueado');

                if (pendingAudioPlay) {
                    pendingAudioPlay = false;
                    playNotificationSoundMP3();
                }
            }).catch(() => { /* silencioso */ });
        }

        document.removeEventListener('click',      unlock);
        document.removeEventListener('touchstart', unlock);
        document.removeEventListener('keydown',    unlock);
    };

    document.addEventListener('click',      unlock);
    document.addEventListener('touchstart', unlock);
    document.addEventListener('keydown',    unlock);
}

/**
 * Reproduce el sonido de notificación.
 * Si el audio aún no está desbloqueado, lo encola para el próximo gesto.
 */
function playNotificationSoundMP3() {
    const sound = document.getElementById('order-sound');
    if (!sound) {
        mostrarNotificacionVisual();
        return;
    }

    if (!audioUnlocked) {
        pendingAudioPlay = true;
        unlockAudioMP3();
        mostrarNotificacionVisual();
        return;
    }

    /* Reiniciar posición sin tocar el src (cambiar src rompe la carga) */
    sound.currentTime = 0;
    sound.volume = 1;

    sound.play().then(() => {
        console.log('🔔 Sonido reproducido');
    }).catch(err => {
        console.warn('❌ Error de audio:', err.name);
        if (err.name === 'NotAllowedError') {
            audioUnlocked    = false;
            pendingAudioPlay = true;
            unlockAudioMP3();
        }
        mostrarNotificacionVisual();
    });

    mostrarNotificacionVisual();
}

/* ── Notificación visual de respaldo ─────────────────────────────── */
function mostrarNotificacionVisual() {
    /* Título de pestaña parpadeante */
    const originalTitle = document.title;
    document.title = '🔔 ¡NUEVO PEDIDO! 🔔';
    setTimeout(() => { document.title = originalTitle; }, 3000);

    /* Vibración en móviles */
    if (navigator.vibrate) navigator.vibrate([200, 100, 200]);

    /* Notificación del sistema */
    if (Notification.permission === 'granted') {
        new Notification('Nuevo pedido en cocina', {
            body: 'Hay ítems RECIBIDOS esperando atención',
            icon: '../../assets/img/favicon.ico'
        });
    } else if (Notification.permission !== 'denied') {
        Notification.requestPermission();
    }

    /* Toast SweetAlert */
    Swal.fire({
        title: '¡Nuevo pedido!',
        text:  'Hay ítems pendientes de atención',
        icon:  'info',
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        background: '#ff9800',
        color: '#fff'
    });
}

/* ════════════════════════════════════════════════════════════════════
   HELPERS
   ════════════════════════════════════════════════════════════════════ */

function limpiarFiltros() {
    window.location.href = 'index.jsp';
}

/* ── Recarga parcial del dashboard vía AJAX ──────────────────────── */
function recargarDashboard() {
    const container = $('#dashboard-container');
    container.css('opacity', '0.5');

    const fIni = document.getElementById('fecha_inicio').value;
    const fFin = document.getElementById('fecha_fin').value;

    container.load(
        'index.jsp?fecha_inicio=' + fIni + '&fecha_fin=' + fFin + ' #dashboard-container > *',
        function () {
            container.css('opacity', '1');
            initPlugins();
        }
    );
}

/* ── Habilitar/deshabilitar botones masivos según estado actual ───── */
function updateBulkButtonStates() {
    const ribbons = document.querySelectorAll('.status-ribbon');
    if (!ribbons.length) return;

    let allAtLeastProcesando = true;
    let allAtLeastTerminado  = true;
    let allAtLeastEntregado  = true;

    ribbons.forEach(ribbon => {
        const activeBtn = ribbon.querySelector('.status-step.active');
        const val = activeBtn ? parseInt(activeBtn.getAttribute('data-val')) : 0;
        if (val < 2) allAtLeastProcesando = false;
        if (val < 3) allAtLeastTerminado  = false;
        if (val < 4) allAtLeastEntregado  = false;
    });

    const btnTerminar = document.getElementById('btn-terminar-todo');
    const btnEntregar = document.getElementById('btn-entregar-todo');

    if (btnTerminar && !btnTerminar.hasAttribute('data-canceled')) {
        btnTerminar.disabled = !allAtLeastProcesando || allAtLeastTerminado;
    }
    if (btnEntregar && !btnEntregar.hasAttribute('data-canceled')) {
        btnEntregar.disabled = !allAtLeastTerminado || allAtLeastEntregado;
    }
}

/* ── Inicializar DataTable y tooltips ────────────────────────────── */
function initPlugins() {
    $('.tooltip').remove();
    $('[data-toggle="tooltip"]').tooltip();

    if ($.fn.DataTable.isDataTable('#dataTables1')) {
        $('#dataTables1').DataTable().destroy();
    }

    $('#dataTables1').DataTable({
        responsive:   true,
        lengthChange: true,
        autoWidth:    false,
        order:        [[0, 'asc']],
        language: {
            "decimal":        "",
            "emptyTable":     "No hay datos disponibles en la tabla",
            "info":           "Mostrando _START_ a _END_ de _TOTAL_ entradas",
            "infoEmpty":      "Mostrando 0 a 0 de 0 entradas",
            "infoFiltered":   "(filtrado de _MAX_ entradas totales)",
            "infoPostFix":    "",
            "thousands":      ",",
            "lengthMenu":     "Mostrar _MENU_ entradas",
            "loadingRecords": "Cargando...",
            "processing":     "Procesando...",
            "search":         "Buscar:",
            "zeroRecords":    "No se encontraron registros coincidentes",
            "paginate": {
                "first":      "Primero",
                "last":       "Último",
                "next":       "Siguiente",
                "previous":   "Anterior"
            },
            "aria": {
                "sortAscending":  ": activar para ordenar la columna ascendente",
                "sortDescending": ": activar para ordenar la columna descendente"
            }
        }
    });
}

/* ════════════════════════════════════════════════════════════════════
   DETALLE DEL PEDIDO
   ════════════════════════════════════════════════════════════════════ */

function verDetalle(id_mov_vnt, element, orderStatus) {
    $('.tooltip').remove();
    window.needsReload = false;
    const isCanceled = (orderStatus === 'A');

    Swal.fire({
        title: 'Detalle del Pedido ' +
               (isCanceled ? '<span class="badge badge-danger">ANULADO</span>' : ''),
        html: '<div class="d-flex justify-content-between align-items-center mb-3">' +
                  '<h6 class="text-muted text-uppercase small font-weight-bold mb-0">Lista de Productos</h6>' +
                  '<button id="btn-terminar-todo" class="btn btn-sm btn-info shadow-sm px-3" ' +
                      'onclick="marcarTodoTerminado(\'' + id_mov_vnt + '\')" ' +
                      (isCanceled ? 'disabled data-canceled="true"' : '') + '>' +
                      '<i class="fas fa-check-double mr-2"></i> Marcar Todo Terminado' +
                  '</button>' +
                  '<button id="btn-entregar-todo" class="btn btn-sm btn-success shadow-sm px-3" ' +
                      'onclick="marcarTodoEntregado(\'' + id_mov_vnt + '\')" ' +
                      (isCanceled ? 'disabled data-canceled="true"' : '') + '>' +
                      '<i class="fas fa-check-double mr-2"></i> Marcar Todo Entregado' +
                  '</button>' +
              '</div>' +
              '<div id="pedido-detalle-content">' +
                  '<div class="p-4 text-center">' +
                      '<i class="fas fa-spinner fa-spin fa-2x text-primary"></i>' +
                      '<p class="mt-2">Cargando...</p>' +
                  '</div>' +
              '</div>',
        width: '850px',
        showConfirmButton: false,
        showCloseButton:   true,
        customClass: { popup: 'swal2-popup-custom' },
        didOpen: () => {
            fetch('get_pedido_detalle.jsp?id_mov_vnt=' + id_mov_vnt)
                .then(r => r.json())
                .then(data => {
                    if (!data.success) {
                        document.getElementById('pedido-detalle-content').innerHTML =
                            '<div class="alert alert-danger">' + data.message + '</div>';
                        return;
                    }

                    const states = [
                        { val: 0, label: 'RECIBIDO',   icon: 'fas fa-file-invoice'   },
                        { val: 1, label: 'EN COLA',    icon: 'fas fa-hourglass-start' },
                        { val: 2, label: 'PREPARANDO', icon: 'fas fa-fire'            },
                        { val: 3, label: 'LISTO',      icon: 'fas fa-check-circle'   },
                        { val: 4, label: 'SERVIDO',    icon: 'fas fa-bell'           }
                    ];

                    let html = '<table class="swal-table">' +
                               '<thead><tr>' +
                               '<th style="width:55px">Cant</th>' +
                               '<th>Producto</th>' +
                               '<th style="width:290px;text-align:center">Estado de Atención</th>' +
                               '</tr></thead><tbody>';

                    data.items.forEach(item => {
                        const currentEst = parseInt(item.estado_atencion) || 0;

                        let ribbon = '<div class="status-ribbon">';
                        states.forEach(s => {
                            const isActive   = (s.val === currentEst);
                            // Solo se bloquean estados anteriores al actual (no se puede retroceder)
                            const isDisabled = isCanceled || (s.val < currentEst);

                            ribbon +=
                                '<button type="button" ' +
                                        'class="status-step ' + (isActive ? 'active' : '') + '" ' +
                                        'data-val="' + s.val + '" ' +
                                        'data-id="' + item.id_movart + '" ' +
                                        'title="' + s.label + '" ' +
                                        (isDisabled ? 'disabled' : '') + '>' +
                                    '<i class="' + s.icon + '"></i>' +
                                    '<span>' + s.label.split(' ')[0] + '</span>' +
                                '</button>';
                        });
                        ribbon += '</div>';

                        html +=
                            '<tr>' +
                            '<td><strong>' + item.cantidad + '</strong></td>' +
                            '<td class="font-weight-600">' + item.glosa + '</td>' +
                            '<td>' + ribbon + '</td>' +
                            '</tr>';
                    });

                    html += '</tbody></table>';

                    const content = document.getElementById('pedido-detalle-content');
                    content.innerHTML = html;

                    // Delegación de eventos: un solo listener en el contenedor
                    content.addEventListener('click', function(e) {
                        const btn = e.target.closest('.status-step');
                        if (!btn || btn.disabled) return;

                        const nuevoEstado = parseInt(btn.getAttribute('data-val'));
                        const id_movart   = btn.getAttribute('data-id');

                        // Actualizar UI de la ribbon
                        const ribbon = btn.closest('.status-ribbon');
                        ribbon.querySelectorAll('.status-step').forEach(s => {
                            const sVal = parseInt(s.getAttribute('data-val'));
                            s.classList.toggle('active', sVal === nuevoEstado);
                            if (sVal < nuevoEstado) s.disabled = true;
                            if (nuevoEstado === 4)  s.disabled = true;
                        });

                        // Animación de feedback
                        btn.style.transform = 'scale(1.15)';
                        setTimeout(() => { btn.style.transform = ''; }, 180);

                        updateBulkButtonStates();
                        window.needsReload = true;

                        // Llamada al backend
                        fetch('update_estado_atencion.jsp?id_movart=' + id_movart + '&estado=' + nuevoEstado)
                            .then(r => r.json())
                            .then(data => {
                                if (data.success) {
                                    Swal.mixin({
                                        toast: true, position: 'top-end',
                                        showConfirmButton: false,
                                        timer: 1800, timerProgressBar: true
                                    }).fire({ icon: 'success', title: 'Estado actualizado' });
                                    recargarDashboard();
                                } else {
                                    Swal.fire('Error', data.message, 'error');
                                }
                            })
                            .catch(() => {
                                Swal.fire('Error', 'No se pudo comunicar con el servidor.', 'error');
                            });
                    });

                    if (!isCanceled) updateBulkButtonStates();
                });
        },
        willClose: () => {
            if (window.needsReload) location.reload();
        }
    });
}

/* ── Marcar todo terminado ───────────────────────────────────────── */
function marcarTodoTerminado(id_mov_vnt) {
    Swal.fire({
        title: '¿Marcar todo como terminado?',
        text:  'Se actualizarán todos los ítems de este pedido a TERMINADO.',
        icon:  'question',
        showCancelButton:    true,
        confirmButtonColor:  '#10b981',
        cancelButtonColor:   '#64748b',
        confirmButtonText:   'Sí, terminar todo',
        cancelButtonText:    'Cancelar'
    }).then(result => {
        if (!result.isConfirmed) return;
        Swal.showLoading();
        fetch('update_estado_atencion.jsp?id_mov_vnt=' + id_mov_vnt + '&estado=3')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    Swal.fire({
                        icon: 'success', title: '¡Pedido Terminado!',
                        text: 'Todos los ítems han sido actualizados.',
                        timer: 1500, showConfirmButton: false
                    }).then(() => location.reload());
                } else {
                    Swal.fire('Error', data.message, 'error');
                }
            });
    });
}

/* ── Marcar todo entregado ───────────────────────────────────────── */
function marcarTodoEntregado(id_mov_vnt) {
    Swal.fire({
        title: '¿Marcar todo como entregado?',
        text:  'Se actualizarán todos los ítems de este pedido a ENTREGADO.',
        icon:  'question',
        showCancelButton:    true,
        confirmButtonColor:  '#10b981',
        cancelButtonColor:   '#64748b',
        confirmButtonText:   'Sí, entregar todo',
        cancelButtonText:    'Cancelar'
    }).then(result => {
        if (!result.isConfirmed) return;
        Swal.showLoading();
        fetch('update_estado_atencion.jsp?id_mov_vnt=' + id_mov_vnt + '&estado=4')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    Swal.fire({
                        icon: 'success', title: '¡Pedido Entregado!',
                        text: 'Todos los ítems han sido actualizados.',
                        timer: 1500, showConfirmButton: false
                    }).then(() => location.reload());
                } else {
                    Swal.fire('Error', data.message, 'error');
                }
            });
    });
}

/* ── Actualizar estado de un ítem individual ─────────────────────── */
function actualizarEstadoItem(id_movart, nuevoEstado, element) {
    nuevoEstado = parseInt(nuevoEstado);

    // Actualizar clase de color del select según nuevo estado
    if (element && element.tagName === 'SELECT') {
        element.className = 'item-status-select atencion-' + nuevoEstado;
        if (nuevoEstado === 4) element.disabled = true;
        updateBulkButtonStates();
    }

    fetch('update_estado_atencion.jsp?id_movart=' + id_movart + '&estado=' + nuevoEstado)
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                Swal.mixin({
                    toast: true, position: 'top-end',
                    showConfirmButton: false, timer: 2000, timerProgressBar: true
                }).fire({ icon: 'success', title: 'Ítem actualizado' });

                window.needsReload = true;
                recargarDashboard();
            } else {
                Swal.fire('Error', data.message, 'error');
            }
        })
        .catch(() => {
            Swal.fire('Error', 'No se pudo comunicar con el servidor.', 'error');
        });
}

/* ════════════════════════════════════════════════════════════════════
   INIT — DOM Ready
   ════════════════════════════════════════════════════════════════════ */

$(function () {
    /* ── Valores inyectados por JSP ─────────────────────────────── */
    const dashData     = window._dashData || {};
    const recibidos    = dashData.recibidos    || 0;   // ítems RECIBIDOS ahora

    /* ── Plugins ────────────────────────────────────────────────── */
    initPlugins();

    /* ── Notificaciones del sistema ─────────────────────────────── */
    if (Notification.permission === 'default') Notification.requestPermission();

    /* ── Desbloquear audio en primer gesto ──────────────────────── */
    unlockAudioMP3();

    /* ────────────────────────────────────────────────────────────
       DISPARADOR DE SONIDO
       Compara los ítems RECIBIDOS actuales con la última carga.
       Solo suena si el número AUMENTÓ (llegó algo nuevo sin atender).
    ──────────────────────────────────────────────────────────── */
    const lastRecibidos = parseInt(localStorage.getItem(KEY_RECIBIDOS));

    if (!isNaN(lastRecibidos) && recibidos > lastRecibidos) {
        console.log(
            '🎉 Nuevos ítems RECIBIDOS: ' + lastRecibidos + ' → ' + recibidos +
            ' | Reproduciendo notificación...'
        );
        playNotificationSoundMP3();
    } else {
        console.log(
            'ℹ️ Ítems RECIBIDOS: ' + recibidos +
            (isNaN(lastRecibidos) ? ' (primera carga)' : ' — sin cambios')
        );
    }

    /* Guardar el valor actual para la próxima comparación */
    localStorage.setItem(KEY_RECIBIDOS, recibidos);

    /* ── Auto-refresh ───────────────────────────────────────────── */
    let timeLeft       = 30;
    let refreshEnabled = true;

    const timerBadge   = document.getElementById('timer-badge');
    const refreshCheck = document.getElementById('auto-refresh-check');

    const savedRefresh = localStorage.getItem(KEY_REFRESH);
    if (savedRefresh !== null) {
        refreshEnabled        = savedRefresh === 'true';
        refreshCheck.checked  = refreshEnabled;
        timerBadge.textContent = refreshEnabled ? timeLeft + 's' : '--';
    }

    refreshCheck.addEventListener('change', function () {
        refreshEnabled = this.checked;
        localStorage.setItem(KEY_REFRESH, refreshEnabled);
        if (refreshEnabled) {
            timeLeft = 30;
            timerBadge.textContent = timeLeft + 's';
        } else {
            timerBadge.textContent = '--';
        }
    });

    let refreshTimer = setInterval(function () {
        if (!refreshEnabled) return;

        timeLeft--;
        timerBadge.textContent = timeLeft + 's';

        if (timeLeft <= 0) {
            clearInterval(refreshTimer);
            timerBadge.textContent = '...';
            location.reload();
        }
    }, 1000);
});
