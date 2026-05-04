/* Scripts for user_edit.jsp */
function addIp() {
    const input = document.getElementById('ip_input');
    const list = document.getElementById('ip_list');
    if (!input || !list) return;
    
    const value = input.value.trim();
    if (value) {
        const option = document.createElement('option');
        option.text = value;
        list.add(option);
        input.value = '';
        input.focus();
    }
}

function removeIp() {
    const list = document.getElementById('ip_list');
    if (list && list.selectedIndex !== -1) {
        list.remove(list.selectedIndex);
    }
}

function updateIpField() {
    const list = document.getElementById('ip_list');
    const field = document.getElementById('f_ip');
    if (!list || !field) return;
    
    let ips = [];
    for (let i = 0; i < list.options.length; i++) {
        ips.push(list.options[i].text);
    }
    field.value = ips.join(' ');
}

$(document).ready(function() {
    $('#editForm').on('submit', function(e) {
        e.preventDefault();
        updateIpField();
        
        const $btn = $('#submitBtn');
        if (!$btn.length) return;
        
        const originalContent = $btn.html();
        
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-2"></i> Guardando...');
        
        $.ajax({
            url: 'user_update.jsp',
            type: 'POST',
            data: $(this).serialize(),
            dataType: 'json',
            success: function(response) {
                if (response.status === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: '\u00a1Actualizado!',
                        text: response.message,
                        timer: 2000,
                        showConfirmButton: false
                    }).then(() => {
                        const areaId = $('input[name="f_id_area"]').val();
                        window.location.href = 'usuarios.jsp?f_id_area=' + areaId;
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
