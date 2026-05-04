<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String id_personal_user = (String) xsession.getValue("id_personal_user");
  String s_id_grupo = "";
  if (s_id_grupo == null) s_id_grupo = "X";

  // Variables para los datos del usuario
  String ss_fecha = "";
  String s_nom_punto = "";
  String s_nomUsu = "";
  String s_fi = "";
  String sex = "";
  String s_img = "";

  try {
      COMANDO = "SELECT id_personal, sexo, " +
                "DATE_FORMAT(NOW(),'%d/%m/%Y') fecha, " +
                "nombre, " +
                "DATE_FORMAT(fecha_ing,'%d %M. %Y') fecing, " +
                "nom_punto(?) nompunto " +
                "FROM datos_personales " +
                "WHERE id_personal = ?";
      
      conn = getConexion();
      if (conn == null) {
          throw new Exception("Error de conexión a la base de datos");
      }
      
      pstmt = conn.prepareStatement(COMANDO);
      pstmt.setString(1, s_punto);
      pstmt.setString(2, id_personal_user);
      rset = pstmt.executeQuery();
      
      if (rset.next()) {
          ss_fecha = rset.getString("fecha");
          s_nom_punto = rset.getString("nompunto");
          s_nomUsu = rset.getString("nombre");
          s_fi = rset.getString("fecing");
          sex = rset.getString("sexo");
      } else {
          // Valores por defecto si no se encuentra el usuario
          ss_fecha = new SimpleDateFormat("dd/MM/yyyy").format(new Date());
          s_nom_punto = "No definido";
          s_nomUsu = "Usuario";
          s_fi = "No disponible";
          sex = "M";
      }

      // Determinar la imagen del usuario
      if (id_personal_user != null && id_personal_user.equals("1315491728407")) {
          s_img = id_personal_user + ".jpg";
      } else {
          s_img = (sex != null && !sex.isEmpty()) ? sex + ".png" : "M.png";
      }
      
  } catch (Exception e) {
      // Log del error
      System.err.println("Error en dashboard.jsp al cargar datos del usuario: " + e.getMessage());
      e.printStackTrace();
      
      // Valores por defecto en caso de error
      ss_fecha = new SimpleDateFormat("dd/MM/yyyy").format(new Date());
      s_nom_punto = "Error al cargar";
      s_nomUsu = "Usuario";
      s_fi = "Error";
      sex = "M";
      s_img = "M.png";
      
  } finally {
      // Usar el método cerrar de database.jsp
      cerrar(rset, pstmt, conn);
      // Reiniciar variables para evitar reutilización accidental
      rset = null;
      pstmt = null;
      conn = null;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>..::Menu::..</title>
  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="../assets/plugins/fontsgstatic/css/css.css"/>  
  <!-- Font Awesome Icons -->
  <link rel="stylesheet" href="../assets/plugins/fontawesome-free/css/all.min.css">
  <!-- IonIcons -->
  <link rel="stylesheet" href="../assets/plugins/ionicons/css/ionicons.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="../assets/plugins/adminlte3/css/adminlte.min.css">
  <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon"/>
  <style>
    .bg-lila {
        background: linear-gradient(135deg, #667eea 0%, #4c51bf 100%);
        color: white;
        font-weight: bold;
    }
     .bg-lila:hover {
        background: linear-gradient(135deg, #4c51bf 0%, #667eea 100%);
    }
  </style>
</head>
<body class="sidebar-mini layout-navbar-fixed layout-footer-fixed">
<div class="wrapper">
   <!-- Navbar -->
  <nav class="main-header navbar navbar-expand navbar-light bg-lila">
    <!-- Left navbar links -->
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars" style="color:white;"></i></a>
      </li>
      <li class="nav-item d-none d-sm-inline-block">
        <a href="index.jsp" class="nav-link" style="color:white;">Inicio</a>
      </li>
    </ul>

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">
    <!-- Session Dropdown Menu -->
      <li class="nav-item dropdown">
        <a class="nav-link" data-toggle="dropdown" href="#">
          <i class="fa fa-power-off" style="color:white;"></i>
        </a>
        <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
          <span class="dropdown-item dropdown-header">Datos del usuario</span>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item">
            <i class="fas fa-user-circle mr-2"></i> <%=s_nomUsu%>
            <span class="float-right text-muted text-sm"><%=s_login != null ? s_login : ""%></span>
          </a>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item">
            <i class="fas fa-calendar mr-2"></i> Fecha de ingreso
            <span class="float-right text-muted text-sm"><%=s_fi%></span>
          </a>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item">
            <i class="fas fa-desktop mr-2"></i> Dirección IP
            <span class="float-right text-muted text-sm"><%=s_ip != null ? s_ip : ""%></span>
          </a>
          <div class="dropdown-divider"></div>
          <button class="dropdown-item dropdown-footer bg-danger text-bold" onclick="cerrarSesion()">Cerrar sesión</button>
        </div>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-widget="fullscreen" href="#" role="button">
          <i class="fas fa-expand-arrows-alt" style="color:white;"></i>
        </a>
      </li>
    </ul>
  </nav>
  <!-- /.navbar -->

  <!-- Main Sidebar Container -->
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="index.jsp" class="brand-link bg-lila">
      <img src="../assets/images/logoEmpresa.png" alt="Logo empresa" class="brand-image img-circle elevation-3" style="opacity: .8">
      <span class="brand-text font-weight-bold">Administrador</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
      <!-- Sidebar user panel (optional) -->
      <div class="user-panel mt-3 pb-3 mb-3 d-flex">
        <div class="image">
          <img src="../assets/images/foto/<%=s_img%>" class="img-circle elevation-2" alt="User Image">
        </div>
        <div class="info">
          <a href="#" class="d-block"><%=s_nomUsu%> <i class="fa fa-circle text-success"></i></a>
        </div>
      </div>

      <!-- SidebarSearch Form -->
      <div class="form-inline">
        <div class="input-group" data-widget="sidebar-search">
          <input class="form-control form-control-sidebar" type="search" placeholder="Search" aria-label="Search">
          <div class="input-group-append">
            <button class="btn btn-sidebar">
              <i class="fas fa-search fa-fw"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          <li class="nav-header">NAVEGACIÓN PRINCIPAL</li>
          <% 
          try {
              // Comando que muestra los menus a donde tiene acceso el usuario
              COMANDO = "CALL sp_kar_cargar_menu_submenu(?,?,?,?)";
              conn = getConexion();
              
              if (conn == null) {
                  throw new Exception("Error de conexión al cargar el menú");
              }
              
              pstmt = conn.prepareStatement(COMANDO);
              pstmt.setString(1, "M");
              pstmt.setString(2, id_area);
              pstmt.setString(3, id_personal_user);
              pstmt.setString(4, null);
              rset = pstmt.executeQuery();
              
              while (rset.next()) {
                  String s_color_icono = "";
                  String id_grupo = rset.getString("id_grupo");
                  String icono = rset.getString("icono") != null ? rset.getString("icono") : "fa-circle";
                  String nombreMenu = rset.getString("nombre") != null ? rset.getString("nombre") : "Menú";
                  
                  // Determinar color del ícono según el grupo
                  if (id_grupo != null) {
                      if (id_grupo.equals("0101")) {
                          s_color_icono = "text-danger";
                      } else if (id_grupo.equals("0104")) {
                          s_color_icono = "text-warning";
                      } else if (id_grupo.equals("0105")) {
                          s_color_icono = "text-info";
                      }
                  }
          %>
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas <%=icono%>"></i>
              <p>
                <%=nombreMenu%>
                <i class="right fas fa-angle-left"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              <%
                try {
                    COMANDO2 = "CALL sp_kar_cargar_menu_submenu(?,?,?,?)";
                    conn2 = getConexion();
                    
                    if (conn2 != null) {
                        pstmt2 = conn2.prepareStatement(COMANDO2);
                        pstmt2.setString(1, "S");
                        pstmt2.setString(2, id_area);
                        pstmt2.setString(3, id_personal_user);
                        pstmt2.setString(4, id_grupo);
                        rset2 = pstmt2.executeQuery();
                        
                        while (rset2.next()) {
                            String url = rset2.getString("url") != null ? rset2.getString("url") : "#";
                            String nombreSubmenu = rset2.getString("nombre") != null ? rset2.getString("nombre") : "Submenú";
              %>
              <li class="nav-item">
                <a href="<%=url%>" class="nav-link" target="view">
                  <i class="far fa-circle nav-icon <%=s_color_icono%>"></i>
                  <p><%=nombreSubmenu%></p>
                </a>
              </li>
              <% 
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error al cargar submenú para grupo " + id_grupo + ": " + e.getMessage());
                } finally {
                    // Usar el método cerrar de database.jsp para los recursos del submenú
                    cerrar(rset2, pstmt2, conn2);
                    // Reiniciar variables
                    rset2 = null;
                    pstmt2 = null;
                    conn2 = null;
                }
              %>
            </ul>
          </li>
          <% 
              }
          } catch (Exception e) {
              System.err.println("Error al cargar el menú principal: " + e.getMessage());
              e.printStackTrace();
          %>
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-exclamation-triangle"></i>
              <p>Error al cargar el menú</p>
            </a>
          </li>
          <% 
          } finally {
              // Usar el método cerrar de database.jsp para los recursos del menú principal
              cerrar(rset, pstmt, conn);
              // Reiniciar variables
              rset = null;
              pstmt = null;
              conn = null;
          }
          %>
        </ul>
      </nav>
      <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
  </aside>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Main content -->
    <iframe src="main.jsp" name="view" id="view" width="100%" height="100%" frameborder="0"></iframe>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

  <!-- Control Sidebar -->
  <aside class="control-sidebar control-sidebar-dark">
    <!-- Control sidebar content goes here -->
  </aside>
  <!-- /.control-sidebar -->

  <!-- Main Footer -->
  <footer class="main-footer">
    <strong>Copyright &copy; 2026 <a href="#">dick_mar@hotmail.com</a>.</strong>
    All rights reserved.
    <div class="float-right d-none d-sm-inline-block">
      <b>Version</b> 3.0
    </div>
  </footer>
</div>
<!-- ./wrapper -->

<!-- jQuery -->
<script src="../assets/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap -->
<script src="../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE -->
<script src="../assets/plugins/adminlte3/js/adminlte.min.js"></script>
<%-- Sweetalert 2 --%>
<script src="../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<%-- dashboard JS --%>
<script src="../assets/js/administrador/dashboard.js"></script>
</body>
</html>