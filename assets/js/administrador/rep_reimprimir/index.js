/* Scripts for Reimpresión Index */
let currentPdfUrl = '';
let basePrintUrl = '';

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

/* ── Canje de Nota de Venta por Comprobante Electrónico ────────────────── */
function openGenerateModal(idMovVnt) {
    $('#canje_id_mov_vnt').val(idMovVnt);
    $('#canjeForm')[0].reset();
    
    // Configurar por defecto a Boleta Electrónica
    $('#canje_tipo_compro').val('41').trigger('change');
    $('#canjeModal').modal('show');
}

// Escuchar cambios en el selector de tipo de comprobante en el modal
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

    const formData = new URLSearchParams();
    formData.append('id_mov_vnt', idMovVnt);
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
        text: 'Procesando el canje de la Nota de Venta...',
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
                text: 'La ' + comproName + ' Electrónica ' + data.serie + '-' + data.numero + ' fue generada exitosamente.',
                confirmButtonText: 'Ver Comprobante'
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
