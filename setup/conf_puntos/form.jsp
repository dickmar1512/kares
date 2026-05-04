<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("modo"); if (s_modo == null) s_modo = "I";
    s_punto = request.getParameter("f_punto"); if (s_punto == null) s_punto = "";
    
    String s_nombre = "", s_tipo = "", s_sucursal = "", s_modulo = "", s_carga_paquete = "0", s_carga_presup = "0";
    String s_crea_cuenta = "0", s_carga_cuenta = "0", s_ult_consultas = "0", s_id_almacen = "";

    try {
        conn = getConexion();
        if (s_modo.equals("U")) {
            COMANDO = "SELECT * FROM puntos WHERE punto = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_punto);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_nombre = rset.getString("nombre"); if (s_nombre == null) s_nombre = "";
                s_tipo = rset.getString("tipo"); if (s_tipo == null) s_tipo = "";
                s_sucursal = rset.getString("sucursal"); if (s_sucursal == null) s_sucursal = "";
                s_modulo = rset.getString("modulo"); if (s_modulo == null) s_modulo = "";
                s_carga_paquete = rset.getString("carga_paquete"); if (s_carga_paquete == null) s_carga_paquete = "0";
                s_carga_presup = rset.getString("carga_presup"); if (s_carga_presup == null) s_carga_presup = "0";
                s_crea_cuenta = rset.getString("crea_cuenta"); if (s_crea_cuenta == null) s_crea_cuenta = "0";
                s_carga_cuenta = rset.getString("carga_cuenta"); if (s_carga_cuenta == null) s_carga_cuenta = "0";
                s_ult_consultas = rset.getString("ult_consultas"); if (s_ult_consultas == null) s_ult_consultas = "0";
                s_id_almacen = rset.getString("id_almacen"); if (s_id_almacen == null) s_id_almacen = "";
            }
            cerrar(rset, pstmt, null);
        } else {
            COMANDO = "SELECT MAX(CAST(punto AS UNSIGNED)) + 1 FROM puntos";
            pstmt = conn.prepareStatement(COMANDO);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_punto = rset.getString(1);
            }
            if (s_punto == null) s_punto = "1";
            cerrar(rset, pstmt, null);
        }
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=s_modo.equals("I") ? "A\u00f1adir" : "Editar"%> Punto</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        .form-card { border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); border: none; }
        .form-control { border-radius: 8px; padding: 0.6rem 1rem; border: 1px solid #dee2e6; }
        .form-control:focus { box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .custom-control-label { cursor: pointer; padding-top: 2px; }
        .btn-modern { border-radius: 8px; padding: 0.6rem 2rem; font-weight: 600; transition: all 0.2s; }
        .btn-modern:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    </style>
</head>
<body class="hold-transition bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-xl-7">
            <div class="card form-card">
                <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
                    <div class="d-flex align-items-center">
                        <a href="main.jsp" class="btn btn-sm btn-outline-secondary rounded-circle mr-3" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <h4 class="mb-0 font-weight-bold"><%=s_modo.equals("I") ? "Registrar Nuevo" : "Modificar"%> Punto</h4>
                    </div>
                </div>
                <div class="card-body p-4">
                    <form id="puntoForm" action="add.jsp" method="post">
                        <input type="hidden" name="modo" value="<%=s_modo%>">
                        <input type="hidden" name="f_punto" value="<%=s_punto%>">

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Código</label>
                                <input type="text" class="form-control bg-light font-weight-bold" value="<%=s_punto%>" readonly disabled>
                            </div>
                            <div class="col-md-8 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Nombre del Punto</label>
                                <input type="text" name="f_nombre" class="form-control" value="<%=s_nombre%>" placeholder="Ej: Recepci\u00f3n Principal" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Sucursal / Módulo</label>
                                <select name="f_modulo" class="form-control custom-select" required>
                                    <option value="">Seleccione...</option>
                                    <%
                                        try {
                                            conn = getConexion();
                                            COMANDO = "SELECT modulo, nombre FROM modulos ORDER BY nombre";
                                            pstmt = conn.prepareStatement(COMANDO);
                                            rset = pstmt.executeQuery();
                                            while(rset.next()) {
                                                String modId = rset.getString("modulo");
                                                String modNom = rset.getString("nombre");
                                    %>
                                    <option value="<%=modId%>" <%=modId.equals(s_modulo) ? "selected" : ""%>><%=modNom%></option>
                                    <%
                                            }
                                        } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Almac\u00e9n</label>
                                <select name="f_id_almacen" class="form-control custom-select">
                                    <option value="">Ninguno</option>
                                    <%
                                        try {
                                            conn = getConexion();
                                            COMANDO = "SELECT id_almacen, nombre FROM almacenes ORDER BY nombre";
                                            pstmt = conn.prepareStatement(COMANDO);
                                            rset = pstmt.executeQuery();
                                            while(rset.next()) {
                                                String almId = rset.getString("id_almacen");
                                                String almNom = rset.getString("nombre");
                                    %>
                                    <option value="<%=almId%>" <%=almId.equals(s_id_almacen) ? "selected" : ""%>><%=almNom%></option>
                                    <%
                                            }
                                        } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
                                    %>
                                </select>
                            </div>
                        </div>

                        <div class="row mt-3">
                            <div class="col-12 mb-2">
                                <label class="text-muted small font-weight-bold mb-2">Configuración Adicional</label>
                            </div>
                            <div class="col-md-6">
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" name="f_carga_paquete" class="custom-control-input" id="checkPaquete" value="1" <%=s_carga_paquete.equals("1") ? "checked" : ""%>>
                                    <label class="custom-control-label" for="checkPaquete">Habilitar Carga de Paquetes</label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" name="f_carga_presup" class="custom-control-input" id="checkPresup" value="1" <%=s_carga_presup.equals("1") ? "checked" : ""%>>
                                    <label class="custom-control-label" for="checkPresup">Habilitar Carga de Presupuestos</label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" name="f_crea_cuenta" class="custom-control-input" id="checkCrea" value="1" <%=s_crea_cuenta.equals("1") ? "checked" : ""%>>
                                    <label class="custom-control-label" for="checkCrea">Permitir Crear Cuentas</label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" name="f_carga_cuenta" class="custom-control-input" id="checkCarga" value="1" <%=s_carga_cuenta.equals("1") ? "checked" : ""%>>
                                    <label class="custom-control-label" for="checkCarga">Habilitar Carga a Cuenta</label>
                                </div>
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-end">
                            <a href="main.jsp" class="btn btn-light btn-modern mr-2">Cancelar</a>
                            <button type="submit" class="btn btn-primary btn-modern" id="saveBtn">
                                <i class="fas fa-save mr-2"></i><%=s_modo.equals("I") ? "Registrar" : "Guardar"%> Punto
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
        $('#puntoForm').on('submit', function(e) {
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
                            title: '\u00a1Logrado!',
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
                    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operaci\u00f3n.' });
                    $btn.prop('disabled', false).html(originalHtml);
                }
            });
        });
    });
</script>
</body>
</html>
