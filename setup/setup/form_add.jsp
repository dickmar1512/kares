<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("f_modo"); if (s_modo == null) s_modo = "I";
    String s_id_area = request.getParameter("f_id_area"); if (s_id_area == null) s_id_area = "";
    String s_nombre = request.getParameter("f_nombre"); if (s_nombre == null) s_nombre = "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=s_modo.equals("I") ? "Añadir" : "Editar"%> Área</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        .form-card { border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); border: none; }
        .form-control { border-radius: 8px; padding: 0.6rem 1rem; border: 1px solid #dee2e6; }
        .form-control:focus { box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .btn-modern { border-radius: 8px; padding: 0.6rem 2rem; font-weight: 600; transition: all 0.2s; }
        .btn-modern:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    </style>
</head>
<body class="hold-transition bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6">
            <div class="card form-card">
                <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
                    <div class="d-flex align-items-center">
                        <a href="main.jsp" class="btn btn-sm btn-outline-secondary rounded-circle mr-3" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <h4 class="mb-0 font-weight-bold"><%=s_modo.equals("I") ? "Registrar Nueva" : "Modificar"%> Área</h4>
                    </div>
                </div>
                <div class="card-body p-4">
                    <form id="areaForm" action="add.jsp" method="post">
                        <input type="hidden" name="f_modo" value="<%=s_modo%>">
                        
                        <div class="form-group mb-4">
                            <label class="text-muted small font-weight-bold mb-1">Código de Área</label>
                            <input type="text" name="f_id_area" class="form-control <%=s_modo.equals("U") ? "bg-light" : ""%>" value="<%=s_id_area%>" <%=s_modo.equals("U") ? "readonly" : ""%> placeholder="Ej: 10" required>
                            <% if (s_modo.equals("I")) { %>
                                <small class="text-muted">Ingrese un identificador único numérico.</small>
                            <% } %>
                        </div>

                        <div class="form-group mb-4">
                            <label class="text-muted small font-weight-bold mb-1">Nombre del Área</label>
                            <input type="text" name="f_nombre" class="form-control" value="<%=s_nombre%>" placeholder="Ej: VENTAS" required>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-end">
                            <a href="main.jsp" class="btn btn-light btn-modern mr-2">Cancelar</a>
                            <button type="submit" class="btn btn-primary btn-modern" id="saveBtn">
                                <i class="fas fa-save mr-2"></i><%=s_modo.equals("I") ? "Registrar" : "Guardar"%> Área
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
    $(function() {
        $('#areaForm').on('submit', function(e) {
            e.preventDefault();
            const $btn = $('#saveBtn');
            const originalHtml = $btn.html();
            
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-2"></i> Procesando...');

            $.ajax({
                url: 'add.jsp',
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: '¡Logrado!',
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        }).then(() => {
                            window.location.href = 'main.jsp';
                        });
                    } else {
                        Swal.fire({ icon: 'error', title: 'Error', text: response.message });
                        $btn.prop('disabled', false).html(originalHtml);
                    }
                },
                error: function() {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operación.' });
                    $btn.prop('disabled', false).html(originalHtml);
                }
            });
        });
    });
</script>
</body>
</html>
