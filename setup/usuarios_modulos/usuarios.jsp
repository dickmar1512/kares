<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_area = request.getParameter("f_id_area");
    String s_nom_area = "";
    
    try {
        COMANDO = "SELECT nombre FROM acceso_main WHERE id_area = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_nom_area = rset.getString("nombre");
        }
    } catch(Exception e) {
        System.out.println(e);
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Usuarios - <%=s_nom_area%></title>
    
    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <!-- AdminLTE 3 -->
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .btn-action { width: 28px; height: 28px; border-radius: 4px; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; border: none; font-size: 12px; }
        .btn-outline-info { color: #fff; background: #17a2b8; }
        .btn-outline-primary { color: #fff; background: #1a3c6e; }
        .btn-outline-danger { color: #fff; background: #dc3545; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-users-gear"></i></div>
    <div>
        <h4>Usuarios: <%=s_nom_area%></h4>
        <small>Sistema &rsaquo; Seguridad &rsaquo; Áreas &rsaquo; Usuarios vinculados</small>
    </div>
    <div class="ml-auto d-flex gap-2">
        <a href="main.jsp" class="btn btn-sm btn-outline-secondary mr-2" style="border-radius:4px;"><i class="fas fa-chevron-left mr-1"></i>Volver</a>
        <a href="buscar.jsp?f_id_area=<%=s_id_area%>" class="btn-kares btn-kares-success" style="padding: 6px 15px; font-weight:700;">
            <i class="fas fa-user-plus mr-1"></i> Vincular Usuario
        </a>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-users" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Personal con acceso al área</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive p-3">
                <table class="table table-kares table-hover mb-0" id="usersTable">
                    <thead>
                        <tr>
                            <th width="50">#</th>
                            <th>Nombre Completo</th>
                            <th width="150" class="text-center">Opciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int contador = 0;
                            try {
                                COMANDO = "SELECT a.id_personal, CONCAT(b.apepat,' ',b.apemat,', ',b.nombre) as nombre " +
                                          "FROM areas_usuarios a, datos_personales b " +
                                          "WHERE a.id_personal = b.id_personal AND a.id_area = ? " +
                                          "ORDER BY nombre";
                                conn = getConexion();
                                pstmt = conn.prepareStatement(COMANDO);
                                pstmt.setString(1, s_id_area);
                                rset = pstmt.executeQuery();
                                
                                while(rset.next()) {
                                    contador++;
                                    String idPers = rset.getString("id_personal");
                                    String nombre = rset.getString("nombre");
                        %>
                        <tr>
                            <td><%=contador%></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="avatar-circle mr-3" style="background-color: #<%=Integer.toHexString(nombre.hashCode()).substring(0, 6)%>; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 0.8rem;">
                                        <%=nombre.substring(0, 1)%>
                                    </div>
                                    <span><%=nombre%></span>
                                </div>
                            </td>
                            <td class="text-center">
                                <a href="lista_accesos.jsp?f_id_area=<%=s_id_area%>&f_id_personal=<%=idPers%>" 
                                   class="btn-action btn-outline-info" data-toggle="tooltip" title="Accesos">
                                    <i class="fas fa-key"></i>
                                </a>
                                <a href="user_edit.jsp?f_id_area=<%=s_id_area%>&f_id_personal=<%=idPers%>" 
                                   class="btn-action btn-outline-primary" data-toggle="tooltip" title="Editar">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <button type="button" class="btn-action btn-outline-danger" 
                                        onclick="confirmDelete('user_del.jsp?f_id_area=<%=s_id_area%>&f_id_personal=<%=idPers%>', '¿Quitar este usuario del área?')" 
                                        data-toggle="tooltip" title="Quitar">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='3'>Error: " + e.getMessage() + "</td></tr>");
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

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- DataTables -->
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/datatables-bs4/js/dataTables.bootstrap4.min.js"></script>
<!-- SweetAlert2 -->
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script src="../../assets/js/setup/usuarios_modulos.js"></script>
<script>
    $(function () {
        $('#usersTable').DataTable({
            "paging": true,
            "lengthChange": false,
            "searching": true,
            "ordering": true,
            "info": true,
            "autoWidth": false,
            "responsive": true,
            "language": {
                "url": "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
            }
        });
    });
</script>
</body>
</html>
