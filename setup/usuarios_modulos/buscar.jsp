<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
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
    <title>Buscar Usuario - <%=s_nom_area%></title>
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/setup/usuarios_modulos/main.css">
</head>
<body class="hold-transition bg-light">

<div class="module-container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-6 col-lg-5">
            <div class="card card-modern fade-up">
                <div class="card-header-modern">
                    <h5 class="card-title-modern">
                        <a href="usuarios.jsp?f_id_area=<%=s_id_area%>" class="btn btn-sm btn-outline-primary mr-2"><i class="fas fa-chevron-left"></i></a>
                        Vincular Nuevo Usuario
                    </h5>
                </div>
                <div class="card-body">
                    <div class="text-center mb-4">
                        <div class="icon-circle text-white mx-auto mb-3">
                            <i class="fas fa-user-search"></i>
                        </div>
                        <h6>Módulo: <strong><%=s_nom_area%></strong></h6>
                        <p class="text-muted small">Busque al personal por su nombre de usuario (login)</p>
                    </div>

                    <form name="datos2" method="POST" action="elegir.jsp" onsubmit="return validateSearch()">
                        <input type="hidden" name="f_id_area" value="<%=s_id_area%>">
                        
                        <div class="form-group">
                            <div class="input-group input-group-lg shadow-sm">
                                <div class="input-group-prepend">
                                    <span class="input-group-text bg-white border-right-0"><i class="fas fa-search text-primary"></i></span>
                                </div>
                                <input type="text" name="f_login" id="f_login" class="form-control border-left-0" 
                                       placeholder="Login del usuario..." required autofocus>
                            </div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary btn-block btn-lg shadow">
                                Buscar Personal <i class="fas fa-arrow-right ml-2"></i>
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
<script src="../../assets/js/setup/usuarios_modulos/buscar.js"></script>
</body>
</html>