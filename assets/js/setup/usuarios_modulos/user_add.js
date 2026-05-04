/* Scripts for user_form_add.jsp */
$(document).ready(function() {
    $('#addForm').on('submit', function(e) {
        e.preventDefault();
        
        const $btn = $('#submitBtn');
        if (!$btn.length) return;
        
        const originalContent = $btn.html();
        
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-2"></i> Procesando...');
        
        $.ajax({
            url: 'user_add.jsp',
            type: 'POST',
            data: $(this).serialize(),
            dataType: 'json',
            success: function(response) {
                if (response.status === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: '\u00a1\u00c9xito!',
                        text: response.message,
                        timer: 2000,
                        showConfirmButton: false
                    }).then(() => {
                        const areaId = $('input[name="f_id_area"]').val();
                        const persId = $('input[name="f_id_personal"]').val();
                        window.location.href = 'lista_accesos.jsp?f_id_area=' + areaId + '&f_id_personal=' + persId;
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: response.message
                    });
                    $btn.prop('disabled', false).html(originalContent);
                }
            },
            error: function() {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'No se pudo comunicar con el servidor.'
                });
                $btn.prop('disabled', false).html(originalContent);
            }
        });
    });
});
