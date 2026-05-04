function calcular(i) {   
    document.datos.f_suma.value = suma();
    document.datos.f_monto.value = suma();
}

function suma() {   
    var valor = 0;
    var num = Number(document.datos.cont_items.value);
    
    for(i=1; i<=num; i++) {  
        var cambiar = eval("document.datos.f_cambia_precio_"+i+".value");  
        var temp = "0";
        
        if (cambiar == '3') {   
            temp = eval("document.datos.f_total_nuevo_"+i+".value");    
        } else {
            temp = eval("document.datos.f_total_"+i+".value");             
        }
        
        if (isNaN(parseFloat(temp))) { temp = 0; }
        valor = parseFloat(valor) + parseFloat(temp);
    }
    return valor.toFixed(2);
}

function actualizarTotalVenta() {
    // Recargar el contenido del iframe de ventas
    var iframe = document.getElementById('venta');
    if(iframe && iframe.contentWindow) {
        iframe.contentWindow.location.reload();
    }
}

function generarOrden() {
    const btn = document.getElementById('btn-generar-orden');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
    }
    
    // Mostrar overlay de carga
    const loader = document.getElementById('loader-overlay');
    if (loader) loader.style.display = 'flex';
    
    document.datos.action = 'nueva_orden.jsp';
    document.datos.submit();
}        

function recalcularTotales() {
    let total = 0;
    let count = 0;
    const rows = document.querySelectorAll('#detalle-items tr');
    
    rows.forEach((row, index) => {
        count++;
        const newIndex = count;
        
        // Actualizar el número de badge en la primera celda
        const badge = row.querySelector('.badge-secondary');
        if (badge) badge.textContent = newIndex;
        
        // Re-indexar todos los inputs de la fila
        const inputs = row.querySelectorAll('input');
        inputs.forEach(input => {
            const oldName = input.name;
            if (oldName && oldName.includes('_')) {
                const parts = oldName.split('_');
                // El índice suele ser el último segmento (ej: f_total_1)
                // Pero hay nombres como f_total_nuevo_1
                const nameBase = oldName.substring(0, oldName.lastIndexOf('_'));
                input.name = nameBase + '_' + newIndex;
            }
        });
        
        // Obtener el total de la fila para la suma
        const totalInput = row.querySelector(`input[name="f_total_${newIndex}"]`);
        const estadoInput = row.querySelector(`input[name="f_estado_det_${newIndex}"]`);
        
        if (estadoInput && estadoInput.value === 'P' && totalInput) {
            total += parseFloat(totalInput.value);
        }
    });

    // Actualizar total items
    const totalItemsBadge = document.querySelector('.total-row .badge-info');
    if (totalItemsBadge) totalItemsBadge.textContent = count;

    // Actualizar suma total
    const sumaInput = document.querySelector('input[name="f_suma"]');
    if (sumaInput) {
        sumaInput.value = total.toFixed(2);
    } else {
        const totalText = document.querySelector('.total-row .text-primary');
        if (totalText) totalText.textContent = total.toFixed(2);
    }
    
    // Actualizar contador global
    const contItemsInput = document.querySelector('input[name="cont_items"]');
    if (contItemsInput) contItemsInput.value = count;
}

async function eliminarItem(id_movart, rowId) {
    const result = await Swal.fire({
        title: '¿Estás seguro?',
        text: "Se eliminará este item de la orden.",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: '<i class="fas fa-trash"></i> Sí, eliminar',
        cancelButtonText: 'Cancelar'
    });

    if (!result.isConfirmed) return;

    const row = document.getElementById(rowId);
    row.style.opacity = '0.5';
    row.style.pointerEvents = 'none';
    
    try {
        const response = await fetch('eliminar_ajax.jsp?f_id_movart='+id_movart);
        const data = await response.json();

        if (data.success) {
            Swal.fire({
                icon: 'success',
                title: 'Eliminado',
                text: data.message,
                timer: 1500,
                showConfirmButton: false
            });

            // Animación de desvanecimiento y eliminación
            row.style.transition = 'all 0.5s ease';
            row.style.transform = 'translateX(20px)';
            row.style.opacity = '0';
            
            setTimeout(() => {
                row.remove();
                recalcularTotales();
                
                // Si no quedan items, ocultar botón de Nueva Orden
                const remainingRows = document.querySelectorAll('#detalle-items tr');
                if (remainingRows.length === 0) {
                    const footer = document.querySelector('.card-footer');
                    if (footer) footer.style.display = 'none';
                }
            }, 500);
        } else {
            Swal.fire('Error', data.message, 'error');
            row.style.opacity = '1';
            row.style.pointerEvents = 'auto';
        }
    } catch (error) {
        console.error('Error al eliminar:', error);
        Swal.fire('Error', 'Error de conexión al eliminar el item.', 'error');
        row.style.opacity = '1';
        row.style.pointerEvents = 'auto';
    }
}