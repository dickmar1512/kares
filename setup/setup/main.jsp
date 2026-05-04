<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    int contador = 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>    
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Configuración de Áreas | Kares ERP</title>
    <!-- AdminLTE 3 & Plugins -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .btn-action { width: 28px; height: 28px; border-radius: 4px; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; border: none; font-size: 12px; }
        .btn-action-edit { color: #fff; background: #1a3c6e; }
        .btn-action-del { color: #fff; background: #dc3545; }
        .btn-action-view { color: #fff; background: #28a745; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-layer-group"></i></div>
    <div>
        <h4>Configuración de Áreas del Menú</h4>
        <small>Sistema &rsaquo; Configuración &rsaquo; Estructura</small>
    </div>
    <a href="form_add.jsp?f_modo=I" class="btn-kares ml-auto" style="padding: 6px 15px; font-weight:700;">
        <i class="fas fa-plus mr-1"></i> Añadir Área
    </a>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Listado de Áreas</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-kares table-hover mb-0">
                            <thead>
                                <tr>
                                    <th class="text-center" style="width: 80px;">Cod</th>
                                    <th>Nombre del Área</th>
                                    <th class="text-center" style="width: 200px;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try {
                                        COMANDO = "SELECT id_area, nombre FROM acceso_main ORDER BY CAST(id_area AS UNSIGNED)";
                                        conn = getConexion();
                                        pstmt = conn.prepareStatement(COMANDO);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            String idArea = rset.getString("id_area");
                                            String nombre = rset.getString("nombre");
                                %>
                                <tr>
                                    <td class="text-center align-middle font-weight-bold text-muted"><%=idArea%></td>
                                    <td class="align-middle">
                                        <span class="font-weight-bold text-dark"><%=nombre%></span>
                                    </td>
                                    <td class="text-center align-middle">
                                        <a href="show_accesos.jsp?f_id_area=<%=idArea%>" class="btn-action btn-action-view mr-1" title="Gestionar Accesos">
                                            <i class="fas fa-list-check"></i>
                                        </a>
                                        <a href="form_add.jsp?f_id_area=<%=idArea%>&f_modo=U&f_nombre=<%=nombre%>" class="btn-action btn-action-edit mr-1" title="Editar">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button type="button" class="btn-action btn-action-del" onclick="deleteArea('<%=idArea%>', '<%=nombre%>')" title="Eliminar">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch(Exception e) {
                                        out.println("<tr><td colspan='3' class='text-center text-danger p-4'>Error: " + e.getMessage() + "</td></tr>");
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

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
function deleteArea(id, name) {
    Swal.fire({
        title: '¿Estás seguro?',
        text: 'Se eliminará el área "' + name + '" y sus accesos asociados. Esta acción no se puede deshacer.',
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
                url: 'del.jsp',
                type: 'GET',
                data: { f_id_area: id },
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
