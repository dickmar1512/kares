$(document).ready(function() {

    // ── Autocomplete cliente ──────────────────────────────────────────
    $("#datosCliente #txtbuscar").autocomplete({
        minLength: 3,
        delay: 300,
        source: function(request, response) {
            $.ajax({
                url: "buscarcliente_ajax.jsp",
                dataType: "json",
                data: { q: request.term },
                success: function(data) {
                    if (data.error) { response([]); return; }
                    response($.map(data.items, function(item) {
                        return {
                            label: item.text + (item.documento ? ' - DNI: ' + item.documento : ''),
                            value: item.text,
                            id: item.id,
                            documento: item.documento
                        };
                    }));
                },
                error: function() { response([]); }
            });
        },
        select: function(event, ui) {
            $('#datosCliente #txtbuscar').val(ui.item.value);
            $('#datosCliente #f_id_personal').val(ui.item.id);
            return false;
        },
        change: function(event, ui) {
            if (!ui.item) $('#datosCliente #f_id_personal').val('');
        },
        focus: function(event, ui) {
            $('#txtbuscar').val(ui.item.value);
            return false;
        }
    }).autocomplete("instance")._renderItem = function(ul, item) {
        return $("<li>")
            .append("<div class='autocomplete-item'><strong>" + item.value + "</strong><br>" +
                    "<small class='text-muted'>" + (item.documento ? 'DNI: ' + item.documento : '') + "</small></div>")
            .appendTo(ul);
    };

    $('#datosCliente #txtbuscar').on('input', function() {
        if ($(this).val().length === 0) $('#datosCliente #f_id_personal').val('');
    });

    // ── Carga órdenes via AJAX al abrir la página ─────────────────────
    cargarOrdenes();
});

/* ─── Carga asíncrona de órdenes: evita esperar el SP en el servidor ──── */
function cargarOrdenes() {
    var idm = (document.getElementById('f_idm_global') || {}).value
           || new URLSearchParams(window.location.search).get('idm')
           || '';

    if (!idm) return;

    function ocultarSkeleton() {
        var sk = document.getElementById('ordenes-skeleton');
        if (sk) sk.style.display = 'none';
    }

    fetch('get_ordenes_ajax.jsp?idm=' + encodeURIComponent(idm))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            ocultarSkeleton();
            var container = document.getElementById('ordenes-container');

            if (!data.success || !data.items || data.items.length === 0) {
                container.innerHTML =
                    '<div class="empty-state-sm">' +
                    '<i class="fas fa-inbox"></i>' +
                    '<p>No hay órdenes para esta mesa</p>' +
                    '</div>';
                document.getElementById('f_num').value = 0;
                return;
            }

            var rows = '';
            var sumtot = 0;
            data.items.forEach(function(item, idx) {
                var c = idx + 1;
                sumtot += parseFloat(item.total) || 0;
                var checkOrBadge = (item.band === '0')
                    ? '<input type="checkbox" name="chk_' + c + '" id="chk_' + c + '" class="case checkbox-xs">'
                    : '<span class="status-badge-sm badge badge-success"><i class="fas fa-check"></i></span>';

                rows +=
                    '<tr>' +
                    '<td><strong>' + c + '</strong></td>' +
                    '<td><small>' + (item.fecha2 || '') + '</small></td>' +
                    '<td class="text-center">' +
                        checkOrBadge +
                        '<input type="hidden" name="f_id_movart_' + c + '" id="f_id_movart_' + c + '" value="' + item.id_movart + '">' +
                    '</td>' +
                    '<td>' + (item.serie || '') + '-' + (item.numdoc || '') + '</td>' +
                    '<td class="text-center"><strong>' + (item.cantidad || '') + '</strong></td>' +
                    '<td>' + (item.glosa || '') + '</td>' +
                    '<td class="text-right"><strong>' + parseFloat(item.total || 0).toFixed(2) + '</strong></td>' +
                    '<td class="text-center">' +
                        '<a href="javascript:void(0);" class="btn btn-danger-sm btn-sm" ' +
                           'onclick="confirmarEliminar(\'' + item.id_mov_vnt + '\',\'' + item.id_movart + '\',\'' + idm + '\')">' +
                            '<i class="fas fa-times"></i>' +
                        '</a>' +
                    '</td>' +
                    '</tr>';
            });

            container.innerHTML =
                '<table class="table table-kares table-hover mb-0" id="tabla_ordenes">' +
                '<thead><tr>' +
                '<th width="5%"><i class="fa fa-hashtag"></i> Item</th>' +
                '<th width="15%"><i class="far fa-calendar"></i> Fecha</th>' +
                '<th width="8%" class="text-center"><input type="checkbox" id="selectall" class="checkbox-xs"> Todo</th>' +
                '<th width="14%"><i class="fas fa-list"></i> Numero Orden</th>' +
                '<th width="8%" class="text-center"><i class="fas fa-sort-numeric-up"></i> Cant.</th>' +
                '<th width="30%"><i class="fas fa-utensils"></i> Descripción</th>' +
                '<th width="10%" class="text-right"><i class="fas fa-dollar-sign"></i> Monto</th>' +
                '<th width="10%" class="text-center"><i class="fas fa-cog"></i> Acciones</th>' +
                '</tr></thead>' +
                '<tbody>' + rows + '</tbody>' +
                '<tfoot><tr class="total-row-sm">' +
                '<td colspan="6" class="text-right"><strong>TOTAL GENERAL S/ :</strong></td>' +
                '<td class="text-right"><strong>' + sumtot.toFixed(2) + '</strong></td>' +
                '<td></td>' +
                '</tr></tfoot>' +
                '</table>';

            document.getElementById('f_num').value = data.items.length;

            // Re-bind selectall
            var sa = document.getElementById('selectall');
            if (sa) {
                sa.addEventListener('click', function() {
                    document.querySelectorAll('.case').forEach(function(c) { c.checked = sa.checked; });
                });
            }
        })
        .catch(function() {
            ocultarSkeleton();
            document.getElementById('ordenes-container').innerHTML =
                '<div class="alert alert-danger m-3"><i class="fas fa-exclamation-circle mr-2"></i>Error al cargar las órdenes.</div>';
        });
}

/* ─── Generar venta ────────────────────────────────────────────────── */
function generarVenta(formulario) {
    var idFormulario = formulario.id;
    var idPersonal = $('#' + idFormulario + ' #f_id_personal').val();
    var idM = $('#' + idFormulario + ' #f_idm').val();
    var valores = [];
    var totalFilas = parseInt($('#f_num').val()) || 0;

    for (var i = 1; i <= totalFilas; i++) {
        if ($('#chk_' + i).is(':checked')) {
            valores.push($('#f_id_movart_' + i).val());
        }
    }

    if (valores.length === 0) {
        Swal.fire({ icon: 'warning', title: 'Atención', text: 'Por favor seleccione al menos un item', confirmButtonText: 'Entendido' });
        return;
    }

    Swal.fire({
        title: '¿Confirmar venta?',
        text: 'Se procesarán ' + valores.length + ' item(s) seleccionado(s)',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#dc3545',
        confirmButtonText: 'Sí, generar venta',
        cancelButtonText: 'Cancelar'
    }).then(function(result) {
        if (result.isConfirmed) procesarVenta(valores, idPersonal, idM);
    });
}

/* ─── Procesar venta ───────────────────────────────────────────────── */
function procesarVenta(valores, idPersonal, idM) {
    Swal.fire({
        title: 'Procesando...',
        text: 'Generando venta, por favor espere',
        allowOutsideClick: false,
        allowEscapeKey: false,
        didOpen: function() { Swal.showLoading(); }
    });

    $.ajax({
        url: 'addVenta_ajax.jsp',
        type: 'POST',
        dataType: 'json',
        data: { s_id_movart: valores.join(','), f_id_personal: idPersonal, f_idm: idM },
        success: function(data) {
            if (data.success) {
                Swal.fire({
                    icon: 'success',
                    title: '¡Detalle de Venta generada correctamente!',
                    text: data.message,
                    timer: 2000,
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    didOpen: function() { Swal.showLoading(); }
                }).then(function() {
                    window.location.href = 'showVenta.jsp?f_id_personal=' + idPersonal +
                                           '&f_id_mov_vnt=' + data.id_mov_vnt + '&f_idm=' + idM;
                });
            } else {
                Swal.fire({ icon: 'error', title: 'Error al generar venta', text: data.message, confirmButtonColor: '#dc3545' });
            }
        },
        error: function(xhr) {
            Swal.fire({ icon: 'error', title: 'Error de conexión', html: 'No se pudo comunicar con el servidor<br><small>' + xhr.status + '</small>' });
        }
    });
}

/* ─── Confirmar eliminar ítem ──────────────────────────────────────── */
function confirmarEliminar(idMovVnt, idMovart, idm) {
    Swal.fire({
        title: '¿Estás seguro?',
        text: '¿Anular este item?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, anular',
        cancelButtonText: 'Cancelar'
    }).then(function(result) {
        if (!result.isConfirmed) return;

        Swal.fire({ title: 'Procesando...', text: 'Anulando item', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });

        fetch('delPedido_ajax.jsp?f_id_mov_vnt=' + idMovVnt + '&f_id_movart=' + idMovart + '&f_idm=' + idm)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    Swal.fire({ icon: 'success', title: '¡Anulado!', text: data.mensaje, timer: 1500, showConfirmButton: false })
                        .then(function() {
                            if (data.datos > 0) {
                                window.location.href = 'index2.jsp?f_id_mov_vnt=' + data.id_mov_vnt + '&idm=' + data.idm;
                            } else {
                                window.location.href = 'index.jsp';
                            }
                        });
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: data.mensaje });
                }
            })
            .catch(function(err) {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Error al procesar: ' + err });
            });
    });
}