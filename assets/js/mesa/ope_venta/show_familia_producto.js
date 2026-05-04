$(document).ready(function () {
	// Guardar tab activo en localStorage
	$('a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
		localStorage.setItem('activeMenuTab', $(e.target).attr('href'));
	});

	// Restaurar tab activo
	var activeTab = localStorage.getItem('activeMenuTab');
	if (activeTab) {
		$('#custom-tabs-menu a[href="' + activeTab + '"]').tab('show');
	}

	// Manejar agregar producto vía AJAX
	$('.btn-add-producto').on('click', function (e) {
		e.preventDefault();

		var $btn = $(this);
		var idServicio = $btn.data('id-servicio');
		var $productBox = $btn.closest('.product-box');
		var cantidad = $productBox.find('.cantidad-input').val();

		// Deshabilitar botón mientras se procesa
		$btn.prop('disabled', true);
		$btn.html('<i class="fas fa-spinner fa-spin"></i> Agregando...');

		// Mostrar loading en el botón
		$.ajax({
			url: 'add_venta_ajax.jsp',
			type: 'POST',
			data: {
				f_id_servicio: idServicio,
				f_cantidad: cantidad,
				modo_venta: 2
			},
			dataType: 'json',
			success: function (response) {
				if (response.success) {
					// Mostrar notificación de éxito
					showNotification('success', 'Producto agregado',
						'Se agregó ' + cantidad + ' unidad(es) correctamente');

					// Animar el producto agregado
					$productBox.addClass('product-added');
					setTimeout(function () {
						$productBox.removeClass('product-added');
					}, 500);

					// Actualizar contador o total en el iframe padre si existe
					if (window.parent && window.parent.actualizarTotalVenta) {
						window.parent.actualizarTotalVenta();
					}

					// Limpiar cantidad a 1 después de agregar (opcional)
					$productBox.find('.cantidad-input').val('1');
				} else {
					showNotification('error', 'Error', response.message);
				}
			},
			error: function (xhr, status, error) {
				showNotification('error', 'Error de conexión',
					'No se pudo agregar el producto: ' + error);
				console.error('Error:', error);
				console.error('Response:', xhr.responseText);
			},
			complete: function () {
				// Restaurar botón
				$btn.prop('disabled', false);
				$btn.html('<i class="fas fa-plus-circle"></i> Agregar');
			}
		});
	});

	// Permitir agregar con Enter en el input de cantidad
	$('.cantidad-input').on('keypress', function (e) {
		if (e.which === 13) { // Enter key
			e.preventDefault();
			$(this).closest('.product-box').find('.btn-add-producto').click();
		}
	});

	// Función para mostrar notificaciones
	function showNotification(type, title, message) {
		// Crear elemento de notificación si no existe
		if ($('#custom-notification').length === 0) {
			$('body').append('<div id="custom-notification" style="position: fixed; top: 20px; right: 20px; z-index: 9999;"></div>');
		}

		var icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
		var bgColor = type === 'success' ? '#28a745' : '#dc3545';

		var notification = $('<div>', {
			class: 'alert alert-' + type,
			style: 'background-color: ' + bgColor + '; color: white; margin-bottom: 10px; padding: 15px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.2); min-width: 250px;'
		}).html('<i class="fas ' + icon + '"></i> <strong>' + title + '</strong><br>' + message);

		$('#custom-notification').append(notification);

		// Auto-cerrar después de 3 segundos
		setTimeout(function () {
			notification.fadeOut(500, function () {
				$(this).remove();
			});
		}, 3000);
	}
});

// Función global para refrescar el contenedor de productos (opcional)
function actualizarProductos() {
	// Recargar solo los tabs que tienen productos
	$('#custom-tabs-menu a[data-toggle="pill"]').each(function () {
		var $tab = $(this);
		var href = $tab.attr('href');
		// Aquí podrías recargar el contenido del tab si es necesario
	});
}