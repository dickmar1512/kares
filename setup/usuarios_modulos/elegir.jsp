<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    s_login = request.getParameter("f_login");
    if (s_login == null) s_login = "";
    String s_id_area = request.getParameter("f_id_area");
    if (s_id_area == null) s_id_area = "";
    
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
    <title>Resultado de Búsqueda</title>
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/setup/usuarios_modulos/main.css">
</head>
<body class="hold-transition bg-light">

<div class="module-container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-8 col-lg-6">
            <div class="card card-modern fade-up">
                <div class="card-header-modern">
                    <h5 class="card-title-modern">
                        <a href="buscar.jsp?f_id_area=<%=s_id_area%>" class="btn btn-sm btn-outline-primary mr-2"><i class="fas fa-chevron-left"></i></a>
                        Resultado de Búsqueda
                    </h5>
                </div>
                <div class="card-body">
                    <%
                        try {
                            COMANDO = "SELECT a.id_personal, CONCAT(a.apepat,' ',a.apemat,', ',a.nombre) as full_name, a.login, " +
                                      "b.id_personal as existe " +
                                      "FROM datos_personales a " +
                                      "LEFT JOIN areas_usuarios b ON a.id_personal = b.id_personal AND b.id_area = ? " +
                                      "WHERE UPPER(a.login) = UPPER(?)";
                            conn = getConexion();
                            pstmt = conn.prepareStatement(COMANDO);
                            pstmt.setString(1, s_id_area);
                            pstmt.setString(2, s_login);
                            rset = pstmt.executeQuery();
                            
                            if (rset.next()) {
                                String idPers = rset.getString("id_personal");
                                String fullName = rset.getString("full_name");
                                String login = rset.getString("login");
                                String existe = rset.getString("existe");
                    %>
                        <div class="text-center py-4">
                            <div class="avatar-circle mx-auto mb-3">
                                <%=fullName.substring(0, 1)%>
                            </div>
                            <h4 class="font-weight-bold mb-1"><%=fullName%></h4>
                            <p class="text-muted mb-4">Usuario: <strong><%=login%></strong></p>

                            <% if (existe == null) { %>
                                <div class="alert alert-info border-0 shadow-sm mb-4">
                                    <i class="fas fa-info-circle mr-2"></i> El usuario está disponible para ser vinculado a <strong><%=s_nom_area%></strong>.
                                </div>
                                <a href="user_form_add.jsp?f_id_area=<%=s_id_area%>&f_id_personal=<%=idPers%>" class="btn btn-success btn-lg btn-block shadow">
                                    <i class="fas fa-link mr-2"></i> Vincular a <%=s_nom_area%>
                                </a>
                            <% } else { %>
                                <div class="alert alert-warning border-0 shadow-sm mb-4">
                                    <i class="fas fa-exclamation-triangle mr-2"></i> El usuario ya se encuentra registrado en <strong><%=s_nom_area%></strong>.
                                </div>
                                <a href="usuarios.jsp?f_id_area=<%=s_id_area%>" class="btn btn-primary btn-block">
                                    <i class="fas fa-users mr-2"></i> Volver a la lista
                                </a>
                            <% } %>
                        </div>
                    <%
                            } else {
                    %>
                        <div class="text-center py-5">
                            <div class="icon-circle bg-light text-muted mx-auto mb-4" style="width: 80px; height: 80px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.5rem;">
                                <i class="fas fa-user-times"></i>
                            </div>
                            <h5 class="text-dark font-weight-bold">Usuario no encontrado</h5>
                            <p class="text-muted">No figura ningún usuario con el login <strong><%=s_login%></strong>.</p>
                            <a href="buscar.jsp?f_id_area=<%=s_id_area%>" class="btn btn-outline-primary mt-3">
                                <i class="fas fa-search mr-2"></i> Intentar otra búsqueda
                            </a>
                        </div>
                    <%
                            }
                        } catch(Exception e) {
                            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                        } finally {
                            cerrar(rset, pstmt, conn);
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
