/* Scripts for Reimpresión Index */
let currentPdfUrl = '';
let basePrintUrl = '';

// Variables para el flujo de canje por producto
let canjeCurrentIdMovVnt = '';
let canjeProductosData = [];
let canjeSelectedMovarts = [];
let canjeSelectedTotal = 0;

$(function() {
    // Initial results count
    const rows = $('table.table-kares tbody tr:not(.no-results-row)').length;
    if(rows > 0) {
        $('#totalResultados').text(rows + ' registro' + (rows !== 1 ? 's' : ''));
    }
});

function openPDFModal(idMovVnt, printUrl) {
    if (printUrl) basePrintUrl = printUrl;
    currentPdfUrl = basePrintUrl + '?f_id_mov_vnt=' + idMovVnt;
    const viewer = document.getElementById('pdfViewer');
    if (viewer) viewer.src = currentPdfUrl;
    $('#pdfModal').modal('show');
}

function downloadPDF() {
    if (!currentPdfUrl) return;
    const link = document.createElement('a');
    link.href = currentPdfUrl;
    link.download = 'comprobante.pdf';
    link.click();
}

function printPDF() {
    if (!currentPdfUrl) return;
    const iframe = document.getElementById('pdfViewer');
    try {
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.print();
        } else {
            window.open(currentPdfUrl, '_blank');
        }
    } catch(e) {
        window.open(currentPdfUrl, '_blank');
    }
}

/* ── PASO 1: Modal de selección de productos a canjear ────────────────── */
async function openCanjeProductosModal(idMovVnt) {
    canjeCurrentIdMovVnt = idMovVnt;
    canjeProductosData = [];
    canjeSelectedMovarts = [];
    canjeSelectedTotal = 0;

    // Mostrar loading, ocultar contenido
    $('#canjeProductosLoading').show();
    $('#canjeProductosContent').hide();
    $('#canjeProductosTbody').empty();
    $('#btnSiguienteCanje').prop('disabled', true);
    $('#chkSelectAllCanje').prop('checked', false);

    $('#canjeProductosModal').modal('show');

    try {
        const response = await fetch('get_detalle_nv_ajax.jsp?id_mov_vnt=' + encodeURIComponent(idMovVnt));
        const data = await response.json();

        $('#canjeProductosLoading').hide();

        if (!data.ok || !data.items || data.items.length === 0) {
            $('#canjeProductosContent').show();
            $('#canjeProductosTbody').html(
                '<tr><td colspan="6" class="text-center text-muted py-3">' +
                '<i class="fas fa-inbox mr-1"></i> No se encontraron productos en esta nota de venta.</td></tr>'
            );
            return;
        }

        canjeProductosData = data.items;
        let html = '';
        let hasPendientes = false;

        data.items.forEach(function(item, idx) {
            const num = idx + 1;
            const esCanjeado = item.canjeado;
            const totalFmt = parseFloat(item.total).toFixed(2);

            if (esCanjeado) {
                html += '<tr style="background:#f0fdf4; opacity:0.7;">' +
                    '<td class="text-center"><input type="checkbox" disabled checked style="opacity:0.5;"></td>' +
                    '<td>' + num + '</td>' +
                    '<td>' + escapeHtml(item.glosa) + '</td>' +
                    '<td class="text-center">' + item.cantidad + '</td>' +
                    '<td class="text-right">S/ ' + totalFmt + '</td>' +
                    '<td class="text-center"><span class="badge badge-success px-2 py-1" style="font-size:9px;"><i class="fas fa-check mr-1"></i>Canjeado</span></td>' +
                    '</tr>';
            } else {
                hasPendientes = true;
                html += '<tr>' +
                    '<td class="text-center"><input type="checkbox" class="chk-canje-prod" data-idx="' + idx + '" data-movart="' + item.id_movart + '" data-total="' + item.total + '"></td>' +
                    '<td><strong>' + num + '</strong></td>' +
                    '<td>' + escapeHtml(item.glosa) + '</td>' +
                    '<td class="text-center"><strong>' + item.cantidad + '</strong></td>' +
                    '<td class="text-right"><strong>S/ ' + totalFmt + '</strong></td>' +
                    '<td class="text-center"><span class="badge badge-light px-2 py-1" style="font-size:9px; color:#64748b; border:1px solid #cbd5e1;"><i class="fas fa-clock mr-1"></i>Pendiente</span></td>' +
                    '</tr>';
            }
        });

        $('#canjeProductosTbody').html(html);
        $('#canjeProductosContent').show();

        // Bind checkbox events
        bindCanjeCheckboxEvents();

        if (!hasPendientes) {
            $('#btnSiguienteCanje').prop('disabled', true).text('Todos los productos ya fueron canjeados');
        }

    } catch (err) {
        $('#canjeProductosLoading').hide();
        $('#canjeProductosContent').show();
        $('#canjeProductosTbody').html(
            '<tr><td colspan="6" class="text-center text-danger py-3">' +
            '<i class="fas fa-exclamation-circle mr-1"></i> Error al cargar los productos.</td></tr>'
        );
    }
}

function bindCanjeCheckboxEvents() {
    // Individual checkboxes
    $(document).off('change', '.chk-canje-prod').on('change', '.chk-canje-prod', function() {
        actualizarResumenCanje();
    });

    // Select all
    $('#chkSelectAllCanje').off('change').on('change', function() {
        const checked = $(this).is(':checked');
        $('.chk-canje-prod').prop('checked', checked);
        actualizarResumenCanje();
    });
}

function actualizarResumenCanje() {
    canjeSelectedMovarts = [];
    canjeSelectedTotal = 0;
    let count = 0;

    $('.chk-canje-prod:checked').each(function() {
        canjeSelectedMovarts.push($(this).data('movart'));
        canjeSelectedTotal += parseFloat($(this).data('total')) || 0;
        count++;
    });

    const totalPendientes = $('.chk-canje-prod').length;
    $('#canjeProductosResumen').text(count + ' de ' + totalPendientes + ' seleccionado' + (count !== 1 ? 's' : ''));
    $('#canjeProductosTotalSel').text('S/ ' + canjeSelectedTotal.toFixed(2));
    $('#btnSiguienteCanje').prop('disabled', count === 0);

    // Update select all state
    $('#chkSelectAllCanje').prop('checked', count === totalPendientes && totalPendientes > 0);
}

/* ── Pasar al PASO 2: Datos del cliente ────────────────────────────────── */
function siguienteCanjeCliente() {
    if (canjeSelectedMovarts.length === 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin Selección',
            text: 'Por favor seleccione al menos un producto para canjear.'
        });
        return;
    }

    // Cerrar modal paso 1
    $('#canjeProductosModal').modal('hide');

    // Configurar modal paso 2
    $('#canje_id_mov_vnt').val(canjeCurrentIdMovVnt);
    $('#canje_id_movarts').val(canjeSelectedMovarts.join(','));
    $('#canjeResumenProductos').text(
        canjeSelectedMovarts.length + ' producto' + (canjeSelectedMovarts.length !== 1 ? 's' : '') + 
        ' — S/ ' + canjeSelectedTotal.toFixed(2)
    );

    // Reset form fields (but keep hidden inputs)
    $('#canje_tipo_compro').val('41').trigger('change');
    $('#canje_dni').val('');
    $('#canje_nombre').val('');
    $('#canje_apepat').val('');
    $('#canje_apemat').val('');
    $('#canje_sexo').val('');
    $('#canje_razon_social').val('');
    $('#canje_direccion').val('');

    setTimeout(function() {
        $('#canjeModal').modal('show');
    }, 300);
}

/* ── Volver al paso 1 desde el paso 2 ──────────────────────────────────── */
function volverAProductos() {
    $('#canjeModal').modal('hide');
    setTimeout(function() {
        $('#canjeProductosModal').modal('show');
    }, 300);
}

/* ── Escuchar cambios en el selector de tipo de comprobante en el modal ── */
$(document).on('change', '#canje_tipo_compro', function() {
    const tipo = $(this).val();
    if (tipo === '41') {
        // Modo Boleta (DNI)
        $('#label_doc_num').text('DNI del Cliente');
        $('#canje_dni').attr('placeholder', 'Ingrese DNI de 8 dígitos').attr('maxlength', '8').attr('pattern', '\\d{8}');
        
        // Mostrar campos de Boleta
        $('.field-boleta').fadeIn().find('input, select').attr('required', true);
        
        // Ocultar campos de Factura
        $('.field-factura').hide().find('input').attr('required', false).val('');
        
        // Dirección en Boleta es opcional
        $('#canje_direccion').attr('required', false).attr('placeholder', 'Opcional');
    } else if (tipo === '39') {
        // Modo Factura (RUC)
        $('#label_doc_num').text('RUC de la Empresa');
        $('#canje_dni').attr('placeholder', 'Ingrese RUC de 11 dígitos').attr('maxlength', '11').attr('pattern', '\\d{11}');
        
        // Ocultar campos de Boleta
        $('.field-boleta').hide().find('input, select').attr('required', false).val('');
        
        // Mostrar campos de Factura
        $('.field-factura').fadeIn().find('input').attr('required', true);
        
        // Dirección en Factura es obligatoria
        $('#canje_direccion').attr('required', true).attr('placeholder', 'Dirección de la empresa (Obligatorio)');
    }
});

async function buscarDniDinamico() {
    const tipoCompro = $('#canje_tipo_compro').val();
    const docNum = $('#canje_dni').val().trim();
    const isBoleta = (tipoCompro === '41');
    const expectedLength = isBoleta ? 8 : 11;
    const docName = isBoleta ? 'DNI' : 'RUC';
    const docTipo = isBoleta ? 'D' : 'E';

    if (docNum.length !== expectedLength) {
        Swal.fire({
            icon: 'warning',
            title: docName + ' Inválido',
            text: 'Por favor, ingrese un ' + docName + ' válido de ' + expectedLength + ' dígitos para realizar la búsqueda.'
        });
        return;
    }

    Swal.fire({
        title: 'Buscando...',
        text: 'Buscando ' + docName + ' en el sistema...',
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    try {
        const response = await fetch('buscar_dni_ajax.jsp?doc_num=' + docNum + '&doc_tipo=' + docTipo);
        const data = await response.json();
        Swal.close();

        if (data.existe) {
            if (isBoleta) {
                $('#canje_nombre').val(data.nombre);
                $('#canje_apepat').val(data.apepat);
                $('#canje_apemat').val(data.apemat);
                $('#canje_sexo').val(data.sexo);
            } else {
                $('#canje_razon_social').val(data.nombre); // Las personas jurídicas guardan la razón social en 'nombre'
            }
            $('#canje_direccion').val(data.direccion);
            
            Swal.fire({
                icon: 'success',
                title: '¡Cliente encontrado!',
                text: 'Se han auto-completado los datos del cliente.',
                timer: 1500,
                showConfirmButton: false
            });
        } else {
            Swal.fire({
                icon: 'info',
                title: 'No encontrado',
                text: 'El ' + docName + ' no está registrado en el sistema. Complete los datos manualmente.',
                timer: 2000,
                showConfirmButton: false
            });
        }
    } catch(err) {
        Swal.close();
        Swal.fire({
            icon: 'error',
            title: 'Error de Red',
            text: 'No se pudo conectar con el servidor para buscar el documento.'
        });
    }
}

async function procesarCanje(event) {
    event.preventDefault();
    
    const idMovVnt = $('#canje_id_mov_vnt').val();
    const idMovarts = $('#canje_id_movarts').val();
    const tipoCompro = $('#canje_tipo_compro').val();
    const docNum = $('#canje_dni').val().trim();
    const direccion = $('#canje_direccion').val().trim();
    const isBoleta = (tipoCompro === '41');

    if (!idMovVnt || !docNum) {
        Swal.fire({
            icon: 'warning',
            title: 'Datos Incompletos',
            text: 'Por favor complete el número de documento.'
        });
        return;
    }

    if (!idMovarts) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin Productos',
            text: 'No se seleccionaron productos para canjear. Vuelva al paso anterior.'
        });
        return;
    }

    const formData = new URLSearchParams();
    formData.append('id_mov_vnt', idMovVnt);
    formData.append('id_movarts', idMovarts);
    formData.append('tipo_comprobante', tipoCompro);
    formData.append('doc_num', docNum);
    formData.append('direccion', direccion);

    if (isBoleta) {
        const nombre = $('#canje_nombre').val().trim();
        const apepat = $('#canje_apepat').val().trim();
        const apemat = $('#canje_apemat').val().trim();
        const sexo = $('#canje_sexo').val();

        if (!nombre || !apepat || !apemat || !sexo) {
            Swal.fire({
                icon: 'warning',
                title: 'Datos Incompletos',
                text: 'Por favor complete todos los datos requeridos de la Boleta.'
            });
            return;
        }
        formData.append('nombre', nombre);
        formData.append('apepat', apepat);
        formData.append('apemat', apemat);
        formData.append('sexo', sexo);
    } else {
        const razonSocial = $('#canje_razon_social').val().trim();
        if (!razonSocial) {
            Swal.fire({
                icon: 'warning',
                title: 'Datos Incompletos',
                text: 'Por favor complete la Razón Social.'
            });
            return;
        }
        if (!direccion) {
            Swal.fire({
                icon: 'warning',
                title: 'Dirección Requerida',
                text: 'La dirección fiscal es obligatoria para emitir una Factura Electrónica.'
            });
            return;
        }
        formData.append('razon_social', razonSocial);
    }

    const comproName = isBoleta ? 'Boleta' : 'Factura';
    Swal.fire({
        title: 'Generando ' + comproName + '...',
        text: 'Procesando el canje de ' + canjeSelectedMovarts.length + ' producto(s)...',
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    try {
        const response = await fetch('canjear_ajax.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        });

        const data = await response.json();
        Swal.close();

        if (data.ok) {
            $('#canjeModal').modal('hide');
            
            Swal.fire({
                icon: 'success',
                title: '¡Comprobante Generado!',
                html: '<p>La ' + comproName + ' Electrónica <strong>' + data.serie + '-' + data.numero + '</strong> fue generada exitosamente.</p>' +
                      '<p class="text-muted" style="font-size:12px;">Productos canjeados: ' + canjeSelectedMovarts.length + '</p>',
                confirmButtonText: 'Actualizar Página'
            }).then((result) => {
                document.datos.submit();
            });
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Error de Canje',
                text: data.msg || 'Hubo un error al procesar el canje.'
            });
        }
    } catch(err) {
        Swal.close();
        Swal.fire({
            icon: 'error',
            title: 'Error Inesperado',
            text: 'Ocurrió un error en el servidor al intentar canjear la Nota de Venta.'
        });
    }
}

/* ── Utilidad: escape HTML ─────────────────────────────────────────────── */
function escapeHtml(text) {
    if (!text) return '';
    var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}
