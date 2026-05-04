function cerrarSesion() {
    Swal.fire({
        title: '¿Cerrar sesión?',
        text: "¿Está seguro que desea salir del sistema?",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Sí, cerrar sesión',
        cancelButtonText: 'Cancelar',
        allowOutsideClick: false,
        allowEscapeKey: false
    }).then((result) => {
        if (result.isConfirmed) {
            // Mostrar loading
            Swal.fire({
                title: 'Cerrando sesión...',
                text: 'Por favor espere',
                allowOutsideClick: false,
                allowEscapeKey: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });
            
            // Realizar petición AJAX
            fetch('logout.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Sesión cerrada',
                        text: 'Hasta pronto',
                        timer: 1500,
                        showConfirmButton: false
                    }).then(() => {
                        window.location.href = '../index.jsp';
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'No se pudo cerrar la sesión correctamente'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    icon: 'warning',
                    title: 'Advertencia',
                    text: 'Hubo un problema, redirigiendo...',
                    timer: 2000,
                    showConfirmButton: false
                }).then(() => {
                   //window.location.href = 'index.jsp';
                });
            });
        }
    });
}