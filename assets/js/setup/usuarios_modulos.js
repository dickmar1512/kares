/**
 * User & Module Management JS
 */

document.addEventListener('DOMContentLoaded', function() {
    initTooltips();
    initSelectAll();
});

function initTooltips() {
    if (window.jQuery && $.fn.tooltip) {
        $('[data-toggle="tooltip"]').tooltip();
    }
}

function initSelectAll() {
    const selectAllCheckboxes = document.querySelectorAll('.select-all-group');
    selectAllCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const groupName = this.dataset.group;
            const itemCheckboxes = document.querySelectorAll(`.group-item[data-group="${groupName}"]`);
            itemCheckboxes.forEach(item => {
                item.checked = this.checked;
            });
        });
    });
}

function confirmDelete(url, message = '\u00bfEst\u00e1s seguro de eliminar este registro?') {
    if (window.Swal) {
        Swal.fire({
            title: message,
            text: "Esta acci\u00f3n no se puede deshacer",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#e74a3b',
            cancelButtonColor: '#858796',
            confirmButtonText: 'S\u00ed, eliminar',
            cancelButtonText: 'Cancelar',
            reverseButtons: true
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading
                Swal.fire({
                    title: 'Eliminando...',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                $.ajax({
                    url: url,
                    type: 'GET',
                    dataType: 'json',
                    success: function(response) {
                        if (response.status === 'success') {
                            Swal.fire({
                                icon: 'success',
                                title: '\u00a1Eliminado!',
                                text: response.message,
                                timer: 1500,
                                showConfirmButton: false
                            }).then(() => {
                                // If DataTables exists, try to remove row smoothly
                                if ($.fn.DataTable.isDataTable('#usersTable')) {
                                    const table = $('#usersTable').DataTable();
                                    const row = $('button[onclick*="' + url + '"]').closest('tr');
                                    table.row(row).remove().draw(false);
                                } else {
                                    window.location.reload();
                                }
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: response.message
                            });
                        }
                    },
                    error: function() {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: 'No se pudo procesar la eliminación.'
                        });
                    }
                });
            }
        });
    } else {
        if (confirm(message)) {
            window.location.href = url;
        }
    }
}

function showToast(icon, title) {
    if (window.Swal) {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
        Toast.fire({
            icon: icon,
            title: title
        });
    }
}
