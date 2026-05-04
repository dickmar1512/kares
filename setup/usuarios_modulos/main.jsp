<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Módulos de Sistema</title>
    
    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <!-- AdminLTE 3 -->
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .area-card { cursor: pointer; transition: all 0.3s; border: 1px solid #e2e8f0; border-radius: 8px; background: #fff; margin-bottom: 20px; }
        .area-card:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.1); border-color: #1a3c6e; }
        .area-icon { width: 50px; height: 50px; border-radius: 10px; background: #f0f4f8; display: flex; align-items: center; justify-content: center; font-size: 20px; color: #1a3c6e; margin-bottom: 15px; }
        .area-card:hover .area-icon { background: #1a3c6e; color: #fff; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-layer-group"></i></div>
    <div>
        <h4>Módulos y Usuarios</h4>
        <small>Sistema &rsaquo; Seguridad &rsaquo; Áreas</small>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="row">
        <%
            int contador = 0;
            try {
                conn = getConexion();
                COMANDO = "SELECT nombre, id_area FROM acceso_main ORDER BY id_area";
                pstmt = conn.prepareStatement(COMANDO);
                rset = pstmt.executeQuery();
                while(rset.next()) {
                    contador++;
                    String idArea = rset.getString("id_area");
                    String nombre = rset.getString("nombre");
                    
                    // Assign icon based on name or ID
                    String icon = "fas fa-cube";
                    if (nombre.toLowerCase().contains("administr")) icon = "fas fa-shield-alt";
                    else if (nombre.toLowerCase().contains("mesa")) icon = "fas fa-utensils";
                    else if (nombre.toLowerCase().contains("venta")) icon = "fas fa-cash-register";
                    else if (nombre.toLowerCase().contains("compra")) icon = "fas fa-shopping-cart";
                    else if (nombre.toLowerCase().contains("almac")) icon = "fas fa-warehouse";
                    else if (nombre.toLowerCase().contains("setup")) icon = "fas fa-cog";
        %>
        <div class="col-lg-3 col-md-4 col-sm-6 fade-up" style="animation-delay: <%=contador * 0.1%>s">
            <div class="card card-modern area-card" onclick="location.href='usuarios.jsp?f_id_area=<%=idArea%>'">
                <div class="card-body">
                    <div class="area-icon">
                        <i class="<%=icon%>"></i>
                    </div>
                    <h5 class="font-weight-bold text-dark"><%=nombre%></h5>
                    <span class="badge badge-pill badge-light text-muted">ID: <%=idArea%></span>
                </div>
            </div>
        </div>
        <% 
                }
            } catch(Exception e) {
                out.println("<div class='col-12'><div class='alert alert-danger'>Error: " + e.getMessage() + "</div></div>");
            } finally {
                cerrar(rset, pstmt, conn);
            }
        %>
    </div>
</div>

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/js/setup/usuarios_modulos.js"></script>
</body>
</html>
