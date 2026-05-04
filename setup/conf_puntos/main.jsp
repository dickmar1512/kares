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
    <title>Configuración de Puntos</title>
    <!-- AdminLTE 3 & Plugins -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .btn-action { width: 28px; height: 28px; border-radius: 4px; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; border: none; font-size: 12px; }
        .btn-action-edit { color: #fff; background: #1a3c6e; }
        .btn-action-del { color: #fff; background: #dc3545; }
        .btn-action-docs { color: #fff; background: #28a745; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-map-marker-alt"></i></div>
    <div>
        <h4>Configuración de Puntos de Atención</h4>
        <small>Sistema &rsaquo; Configuración &rsaquo; Puntos</small>
    </div>
    <a href="form.jsp?modo=I" class="btn-kares ml-auto" style="padding: 6px 15px; font-weight:700;">
        <i class="fas fa-plus mr-1"></i> Añadir Punto
    </a>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Listado de Puntos</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-kares table-hover mb-0">
                            <thead>
                                <tr>
                                    <th class="text-center" style="width: 80px;">Cod</th>
                                    <th>Punto de Atención</th>
                                    <th>Almacén Asociado</th>
                                    <th class="text-center" style="width: 150px;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try {
                                        COMANDO = "SELECT punto, nombre, tipo, nom_suc(sucursal) as nombre_suc, " +
                                                 "ifnull(sucursal,'4') as sucursal, ifnull(nom_alm(id_almacen), 'Sin Almacén') as alm " +
                                                 "FROM puntos ORDER BY CAST(punto AS UNSIGNED)";
                                        conn = getConexion();
                                        pstmt = conn.prepareStatement(COMANDO);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            String punto = rset.getString("punto");
                                            String nombre = rset.getString("nombre");
                                            String sucursal = rset.getString("sucursal");
                                            String nombreSuc = rset.getString("nombre_suc");
                                            String alm = rset.getString("alm");
                                            String colorClass = "badge-secondary";
                                            if (sucursal.equals("1")) colorClass = "bg-primary";
                                            else if (sucursal.equals("2")) colorClass = "bg-info";
                                            else if (sucursal.equals("3")) colorClass = "bg-danger";
                                            else if (sucursal.equals("5")) colorClass = "bg-success";
                                %>
                                <tr>
                                    <td class="text-center align-middle font-weight-bold text-muted"><%=punto%></td>
                                    <td class="align-middle">
                                        <div class="d-flex flex-column">
                                            <span class="font-weight-bold text-dark"><%=nombre%></span>
                                            <small class="text-muted mt-1"><i class="fas fa-building mr-1"></i><%=nombreSuc%></small>
                                        </div>
                                    </td>
                                    <td class="align-middle">
                                        <span class="badge badge-light border px-2 py-1"><i class="fas fa-warehouse mr-1 text-secondary"></i><%=alm%></span>
                                    </td>
                                    <td class="text-center align-middle">
                                        <a href="documentos.jsp?f_punto=<%=punto%>" class="btn-action btn-action-docs mr-1" title="Documentos">
                                            <i class="fas fa-file-invoice"></i>
                                        </a>
                                        <a href="form.jsp?f_punto=<%=punto%>&modo=U" class="btn-action btn-action-edit mr-1" title="Editar">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button type="button" class="btn-action btn-action-del" onclick="deletePunto('<%=punto%>', '<%=nombre%>')" title="Eliminar">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch(Exception e) {
                                        out.println("<tr><td colspan='4' class='text-center text-danger p-4'>Error: " + e.getMessage() + "</td></tr>");
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
function deletePunto(id, name) {
    Swal.fire({
        title: '\u00bfEst\u00e1s seguro?',
        text: 'Se eliminar\u00e1 el punto "' + name + '". Esta acci\u00f3n no se puede deshacer.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'S\u00ed, eliminar',
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
                url: 'del_punto.jsp',
                type: 'GET',
                data: { f_punto: id },
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
                            location.reload();
                        });
                    } else {
                        Swal.fire({ icon: 'error', title: 'Error', text: response.message });
                    }
                },
                error: function() {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operaci\u00f3n.' });
                }
            });
        }
    });
}
</script>
</body>
</html>
