<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_area = request.getParameter("f_id_area"); if (s_id_area == null) s_id_area = "";
    String s_modo = request.getParameter("modo"); if (s_modo == null) s_modo = "I";
    String s_id_acceso = request.getParameter("f_id_acceso"); if (s_id_acceso == null) s_id_acceso = "";
    
    String s_nombre = "", s_url = "", s_icono = "", s_id_grupo = "", s_orden = "", s_nom_area = "";

    try {
        conn = getConexion();
        
        // Obtener nombre del área
        COMANDO = "SELECT nombre FROM acceso_main WHERE id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_area = rset.getString("nombre");
        cerrar(rset, pstmt, null);

        if ("U".equals(s_modo)) {
            COMANDO = "SELECT * FROM accesos_botones WHERE id_acceso = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_acceso);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_nombre = rset.getString("nombre"); if (s_nombre == null) s_nombre = "";
                s_url = rset.getString("url"); if (s_url == null) s_url = "";
                s_icono = rset.getString("icono"); if (s_icono == null) s_icono = "";
                s_id_grupo = rset.getString("id_grupo"); if (s_id_grupo == null) s_id_grupo = "";
                s_orden = rset.getString("orden"); if (s_orden == null) s_orden = "";
            }
            cerrar(rset, pstmt, null);
        } else {
            // Sugerir ID acceso y orden
            COMANDO = "SELECT MAX(CAST(id_acceso AS UNSIGNED)) + 1 FROM accesos_botones";
            pstmt = conn.prepareStatement(COMANDO);
            rset = pstmt.executeQuery();
            if (rset.next()) s_id_acceso = rset.getString(1);
            if (s_id_acceso == null) s_id_acceso = "1";
            cerrar(rset, pstmt, null);
            
            COMANDO = "SELECT MAX(CAST(orden AS UNSIGNED)) + 1 FROM accesos_botones WHERE id_area = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_area);
            rset = pstmt.executeQuery();
            if (rset.next()) s_orden = rset.getString(1);
            if (s_orden == null) s_orden = "1";
            cerrar(rset, pstmt, null);
        }
    } catch(Exception e) { e.printStackTrace(); } finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=s_modo.equals("I") ? "Añadir" : "Editar"%> Acceso</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        .form-card { border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); border: none; }
        .form-control { border-radius: 8px; padding: 0.6rem 1rem; border: 1px solid #dee2e6; }
        .form-control:focus { box-shadow: 0 0 0 3px rgba(40,167,69,0.15); }
        .btn-modern { border-radius: 8px; padding: 0.6rem 2rem; font-weight: 600; transition: all 0.2s; }
        .btn-modern:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    </style>
</head>
<body class="hold-transition bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-xl-6">
            <div class="card form-card">
                <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
                    <div class="d-flex align-items-center">
                        <a href="show_accesos.jsp?f_id_area=<%=s_id_area%>" class="btn btn-sm btn-outline-secondary rounded-circle mr-3" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <div>
                            <h4 class="mb-0 font-weight-bold"><%=s_modo.equals("I") ? "Registrar Nuevo" : "Modificar"%> Acceso</h4>
                            <small class="text-muted">Área: <strong><%=s_nom_area%></strong></small>
                        </div>
                    </div>
                </div>
                <div class="card-body p-4">
                    <form id="docForm" action="add_accesos.jsp" method="post">
                        <input type="hidden" name="modo" value="<%=s_modo%>">
                        <input type="hidden" name="f_id_area" value="<%=s_id_area%>">

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">ID Acceso</label>
                                <input type="text" name="f_id_acceso" class="form-control <%=s_modo.equals("U") ? "bg-light" : ""%>" value="<%=s_id_acceso%>" <%=s_modo.equals("U") ? "readonly" : ""%> required>
                            </div>
                            <div class="col-md-8 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Nombre del Proceso</label>
                                <input type="text" name="f_nombre" class="form-control" value="<%=s_nombre%>" placeholder="Ej: Nueva Venta" required>
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="text-muted small font-weight-bold mb-1">URL / Ruta del Script</label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text"><i class="fas fa-link"></i></span>
                                </div>
                                <input type="text" name="f_url" class="form-control" value="<%=s_url%>" placeholder="Ej: ../ope_venta/index.jsp" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-8 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Icono (FontAwesome)</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i id="iconPreview" class="<%=s_icono.isEmpty() ? "fas fa-icons" : s_icono%>"></i></span>
                                    </div>
                                    <input type="text" name="f_icono" id="f_icono" class="form-control" value="<%=s_icono%>" placeholder="Ej: fas fa-cart-plus">
                                </div>
                                <small class="text-muted">Use clases de FontAwesome 6.</small>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Orden</label>
                                <input type="number" name="f_orden" class="form-control" value="<%=s_orden%>" required>
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="text-muted small font-weight-bold mb-1">Grupo (Opcional)</label>
                            <input type="text" name="f_id_grupo" class="form-control" value="<%=s_id_grupo%>" placeholder="ID de grupo si aplica">
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-end">
                            <a href="show_accesos.jsp?f_id_area=<%=s_id_area%>" class="btn btn-light btn-modern mr-2">Cancelar</a>
                            <button type="submit" class="btn btn-success btn-modern" id="saveBtn">
                                <i class="fas fa-save mr-2"></i><%=s_modo.equals("I") ? "Registrar" : "Guardar"%> Acceso
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
        // Preview icono
        $('#f_icono').on('input', function() {
            const icon = $(this).val() || 'fas fa-icons';
            $('#iconPreview').attr('class', icon);
        });

        $('#docForm').on('submit', function(e) {
            e.preventDefault();
            const $btn = $('#saveBtn');
            const originalHtml = $btn.html();
            
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-2"></i> Procesando...');

            $.ajax({
                url: 'add_accesos.jsp',
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: '¡Guardado!',
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        }).then(() => {
                            window.location.href = 'show_accesos.jsp?f_id_area=<%=s_id_area%>';
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
