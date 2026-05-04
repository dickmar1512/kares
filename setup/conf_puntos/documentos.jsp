<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    s_punto = request.getParameter("f_punto"); if (s_punto == null) s_punto = "";
    String s_nom_punto = "";
    
    try {
        conn = getConexion();
        COMANDO = "SELECT nombre FROM puntos WHERE punto = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_punto = rset.getString("nombre");
        cerrar(rset, pstmt, null);
    } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Documentos por Punto</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .btn-action { width: 28px; height: 28px; border-radius: 4px; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; border: none; font-size: 12px; }
        .btn-action-edit { color: #fff; background: #1a3c6e; }
        .btn-action-del { color: #fff; background: #dc3545; }
        .badge-success-light { background: rgba(40,167,69,0.1); color: #28a745; border: 1px solid rgba(40,167,69,0.2); font-size: 10px; padding: 4px 8px; }
        .badge-danger-light { background: rgba(220,53,69,0.1); color: #dc3545; border: 1px solid rgba(220,53,69,0.2); font-size: 10px; padding: 4px 8px; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-file-invoice"></i></div>
    <div>
        <h4>Documentos: <%=s_nom_punto%></h4>
        <small>Sistema &rsaquo; Configuración &rsaquo; Puntos &rsaquo; Documentos</small>
    </div>
    <div class="ml-auto d-flex gap-2">
        <a href="main.jsp" class="btn btn-sm btn-outline-secondary mr-2" style="border-radius:4px;"><i class="fas fa-chevron-left mr-1"></i>Volver</a>
        <a href="form_doc.jsp?f_punto=<%=s_punto%>&modo=I" class="btn-kares" style="padding: 6px 15px; font-weight:700;">
            <i class="fas fa-plus mr-1"></i> Asignar Documento
        </a>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Documentos asignados</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-kares table-hover mb-0">
                            <thead>
                                <tr>
                                    <th class="text-center" style="width: 60px;">#</th>
                                    <th>Tipo de Documento</th>
                                    <th class="text-center">Serie</th>
                                    <th class="text-center">Número</th>
                                    <%-- <th class="text-center">Copias</th> --%>
                                    <th class="text-center">Estado</th>
                                    <th class="text-center" style="width: 120px;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int count = 0;
                                    try {
                                        conn = getConexion();
                                        COMANDO = "SELECT a.*, b.nombre as nom_doc " +
                                                 "FROM puntos_doc a, cont_tipo_doc b " +
                                                 "WHERE a.tipo_doc = b.tipo_doc AND a.punto = ? " +
                                                 "ORDER BY b.nombre";
                                        pstmt = conn.prepareStatement(COMANDO);
                                        pstmt.setString(1, s_punto);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            count++;
                                            String id = rset.getString("id");
                                            String nomDoc = rset.getString("nom_doc");
                                            String serie = rset.getString("serie");
                                            String numero = rset.getString("numero");
                                           // String copias = rset.getString("copias");
                                            String estado = rset.getString("estado");
                                %>
                                <tr>
                                    <td class="text-center align-middle text-muted small"><%=count%></td>
                                    <td class="align-middle font-weight-bold text-dark"><%=nomDoc%></td>
                                    <td class="text-center align-middle"><span class="badge badge-light border px-2"><%=serie%></span></td>
                                    <td class="text-center align-middle"><%=numero%></td>
                                    <%-- <td class="text-center align-middle"><%=copias%></td> --%>
                                    <td class="text-center align-middle">
                                        <a href="javascript:void(0)" onclick="toggleEstado('<%=s_punto%>', '<%=rset.getString("tipo_doc")%>', '<%= "1".equals(estado) ? "0" : "1" %>')" class="text-decoration-none">
                                            <% if ("1".equals(estado)) { %>
                                                <span class="badge badge-success-light" title="Click para desactivar">
                                                    <i class="fas fa-check-circle mr-1"></i>Activo
                                                </span>
                                            <% } else { %>
                                                <span class="badge badge-danger-light" title="Click para activar">
                                                    <i class="fas fa-times-circle mr-1"></i>Inactivo
                                                </span>
                                            <% } %>
                                        </a>
                                    </td>
                                    <td class="text-center align-middle">
                                        <a href="form_doc.jsp?f_punto=<%=s_punto%>&f_id=<%=id%>&modo=U" class="btn-action btn-action-edit mr-1" title="Editar">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button type="button" class="btn-action btn-action-del" onclick="deleteDoc('<%=id%>', '<%=nomDoc%>')" title="Eliminar">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                        if (count == 0) {
                                            out.println("<tr><td colspan='7' class='text-center p-5 text-muted'><i class='fas fa-info-circle mr-2'></i>No hay documentos asignados a este punto.</td></tr>");
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
function toggleEstado(punto, tipoDoc, nuevoEstado) {
    $.ajax({
        url: 'update_estado.jsp',
        type: 'GET',
        data: { f_punto: punto, f_tipo_doc: tipoDoc, f_estado: nuevoEstado },
        dataType: 'json',
        success: function(response) {
            if (response.status === 'success') {
                location.reload();
            } else {
                Swal.fire({ icon: 'error', title: 'Error', text: response.message });
            }
        },
        error: function() {
            Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo actualizar el estado.' });
        }
    });
}

function deleteDoc(id, name) {
    Swal.fire({
        title: '\u00bfEst\u00e1s seguro?',
        text: '\u00bfDeseas quitar el documento "' + name + '" de este punto?',
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
                url: 'del_documento.jsp',
                type: 'GET',
                data: { f_id: id, f_punto: '<%=s_punto%>' },
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
