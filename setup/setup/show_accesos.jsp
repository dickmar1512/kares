<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_area = request.getParameter("f_id_area"); if (s_id_area == null) s_id_area = "";
    String s_nom_area = "";
    
    try {
        conn = getConexion();
        COMANDO = "SELECT nombre FROM acceso_main WHERE id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_area = rset.getString("nombre");
        cerrar(rset, pstmt, null);
    } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accesos por Área | Kares ERP</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .btn-action { width: 28px; height: 28px; border-radius: 4px; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; border: none; font-size: 12px; }
        .btn-action-edit { color: #fff; background: #1a3c6e; }
        .btn-action-del { color: #fff; background: #dc3545; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-key"></i></div>
    <div>
        <h4>Accesos del Área: <%=s_nom_area%></h4>
        <small>Sistema &rsaquo; Configuración &rsaquo; Estructura &rsaquo; Accesos</small>
    </div>
    <div class="ml-auto d-flex gap-2">
        <a href="main.jsp" class="btn btn-sm btn-outline-secondary mr-2" style="border-radius:4px;"><i class="fas fa-chevron-left mr-1"></i>Volver</a>
        <a href="form_accesos.jsp?f_id_area=<%=s_id_area%>&modo=I" class="btn-kares" style="padding: 6px 15px; font-weight:700;">
            <i class="fas fa-plus mr-1"></i> Añadir Acceso
        </a>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Listado de Accesos (Botones/Procesos)</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-kares table-hover mb-0">
                            <thead>
                                <tr>
                                    <th class="text-center" style="width: 60px;">#</th>
                                    <th class="text-center" style="width: 80px;">Cod</th>
                                    <th>Nombre del Proceso</th>
                                    <th>URL / Script</th>
                                    <th class="text-center">Icono</th>
                                    <th class="text-center" style="width: 80px;">Orden</th>
                                    <th class="text-center" style="width: 120px;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int count = 0;
                                    try {
                                        conn = getConexion();
                                        COMANDO = "SELECT id_acceso, nombre, url, icono, orden " +
                                                 "FROM accesos_botones " +
                                                 "WHERE id_area = ? " +
                                                 "ORDER BY CAST(orden AS UNSIGNED), nombre";
                                        pstmt = conn.prepareStatement(COMANDO);
                                        pstmt.setString(1, s_id_area);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            count++;
                                            String idAcceso = rset.getString("id_acceso");
                                            String nombre = rset.getString("nombre");
                                            String url = rset.getString("url");
                                            String icono = rset.getString("icono");
                                            String orden = rset.getString("orden");
                                %>
                                <tr>
                                    <td class="text-center align-middle text-muted small"><%=count%></td>
                                    <td class="text-center align-middle font-weight-bold text-muted small"><%=idAcceso%></td>
                                    <td class="align-middle font-weight-bold text-dark"><%=nombre%></td>
                                    <td class="align-middle small text-muted"><%=url%></td>
                                    <td class="text-center align-middle"><i class="<%=icono%>"></i></td>
                                    <td class="text-center align-middle"><%=orden%></td>
                                    <td class="text-center align-middle">
                                        <a href="form_accesos.jsp?f_id_area=<%=s_id_area%>&f_id_acceso=<%=idAcceso%>&modo=U" class="btn-action btn-action-edit mr-1" title="Editar">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button type="button" class="btn-action btn-action-del" onclick="deleteAcceso('<%=idAcceso%>', '<%=nombre%>')" title="Eliminar">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                        if (count == 0) {
                                            out.println("<tr><td colspan='7' class='text-center p-5 text-muted'><i class='fas fa-info-circle mr-2'></i>No hay accesos configurados para esta área.</td></tr>");
                                        }
                                    } catch(Exception e) {
                                        out.println("<tr><td colspan='7' class='text-center text-danger p-4'>Error: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        cerrar(rset, pstmt, conn);
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
function deleteAcceso(id, name) {
    Swal.fire({
        title: '¿Estás seguro?',
        text: 'Se eliminará el acceso "' + name + '". Esta acción no se puede deshacer.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            Swal.fire({
                title: 'Eliminando...',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); }
            });

            $.ajax({
                url: 'delete_acceso.jsp',
                type: 'GET',
                data: { f_id_acceso: id },
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: '¡Eliminado!',
                            text: response.message,
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire({ icon: 'error', title: 'Error', text: response.message });
                    }
                },
                error: function() {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operación.' });
                }
            });
        }
    });
}
</script>
</body>
</html>
