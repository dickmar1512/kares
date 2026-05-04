<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%//@ include file="../conectadb.jsp" %>
<%//@ include file="../conectadb01.jsp" %>
<%//@ include file="id.jsp" %>
<%//@ include file="../seguro.jsp" %>
<%
  //--------------------------------------------------------------------------------------//
  // Este JSP pinta los menus del izquierdo deacuerdo a los accesos que tiene el usuario  //
  //--------------------------------------------------------------------------------------//
  //--------------------------------------------------------------------------------------//
  // Se cargan las variables.....                             //
  //--------------------------------------------------------------------------------------//
  String id_personal_user =(String) xsession.getValue("id_personal_user");
  String s_id_grupo = "";
  if ( s_id_grupo==null ) s_id_grupo="X";

  String s_ico ="";

  COMANDO = "select id_personal,sexo, "+
            "DATE_FORMAT(NOW(),'%d/%m/%Y') fecha, "+
            "nombre, "+
            "DATE_FORMAT(fecha_ing,'%d %M. %Y') fecing, "+
            "nom_punto('"+s_punto+"') nompunto "+
            "from datos_personales "+
            "where id_personal = '"+id_personal_user+"' ";
  rset = stmt.executeQuery(COMANDO);
  rset.next();
  String ss_fecha = rset.getString("fecha");
  String s_nom_punto=rset.getString("nompunto");
  String s_nomUsu = rset.getString("nombre");
  String s_fi = rset.getString("fecing");
  String sex = rset.getString("sexo");
  String s_img ="";
  if(id_personal_user.equals("1315491728407"))
  {
    s_img=id_personal_user+".jpg";
  }
  else{s_img=sex+".png";}
  if(s_ip.equals("0:0:0:0:0:0:0:1")) s_ip=request.getRemoteAddr();
  //id_personal_user  = (String) xsession.getValue("id_personal_user");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>..::Menu::..</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <!-- Bootstrap 3.3.7 -->
  <link rel="stylesheet" href="../plugins/css/bootstrap.min.css">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="../plugins/css/font-awesome.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="../plugins/css/ionicons.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="../plugins/css/AdminLTE.min.css">
  <!-- AdminLTE Skins. Choose a skin from the css/skins
       folder instead of downloading all of them to reduce the load. -->
  <link rel="stylesheet" href="../plugins/css/_all-skins.min.css">
  <!-- Morris chart -->
  <link rel="stylesheet" href="../plugins/css/morris.css">
  <!-- jvectormap -->
  <link rel="stylesheet" href="../plugins/css/jquery-jvectormap.css">
  <!-- Date Picker -->
  <link rel="stylesheet" href="../plugins/css/bootstrap-datepicker.min.css">
  <!-- Daterange picker -->
  <link rel="stylesheet" href="../plugins/css/daterangepicker.css">
  <!-- bootstrap wysihtml5 - text editor -->
  <link rel="stylesheet" href="../plugins/css/bootstrap3-wysihtml5.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="../plugins/fonts/css.css">
</head>
<body class="hold-transition skin-purple sidebar-mini">
<div class="wrapper">

  <header class="main-header">
    <!-- Logo -->
    <a href="#" class="logo">
      <!-- mini logo for sidebar mini 50x50 pixels -->
      <span class="logo-mini"><b>A</b>D</span>
      <!-- logo for regular state and mobile devices -->
      <span class="logo-lg"><b>ADMI</b>SIÓN</span>
    </a>
    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar navbar-static-top">
      <!-- Sidebar toggle button-->
      <a href="#" class="sidebar-toggle" data-toggle="push-menu" role="button">
        <span class="sr-only">Toggle navigation</span>
      </a>

      <div class="navbar-custom-menu">
        <ul class="nav navbar-nav">
          <li class="dropdown user user-menu">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <img src="../plugins/images/foto/<%=s_img%>" class="user-image" alt="User Image">
              <span class="hidden-xs"><%=s_nomUsu%></span>
              <i class="fa fa-gears"></i>
            </a>
            <ul class="dropdown-menu">
              <!-- User image -->
              <li class="user-header">
                <img src="../plugins/images/foto/<%=s_img%>" class="img-circle" alt="User Image">
                <p>
                  <%=s_nomUsu%>
                  <small>Miembro desde <%=s_fi%></small>
                </p>
              </li>
              <!-- Menu Body -->
              <li class="user-body">
                <div class="row">
                  <div class="col-xs-4 text-center">
                    <a href="#"><%=s_login%></a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#"><%=s_nom_punto%></a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#"><%=ss_fecha%></a>
                  </div>
                </div>
                <!-- /.row -->
              </li>
              <!-- Menu Footer-->
              <li class="user-footer">
                <div class="pull-left">
                 <a href="#" class="btn btn-default btn-flat"><%=s_ip%></a>
                </div>
                <div class="pull-right">
                  <a href="salir.jsp" class="btn btn-default btn-flat">Cerrar Sesión</a>
                </div>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </nav>
  </header>
  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
      <!-- Sidebar user panel -->
      <div class="user-panel">
        <div class="pull-left image">
          <img src="../plugins/images/foto/<%=s_img%>" class="img-circle" alt="User Image">
        </div>
        <div class="pull-left info">
          <p><%=s_nomUsu%></p>
          <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
        </div>
      </div>
      <!-- sidebar menu: : style can be found in sidebar.less -->
      <ul class="sidebar-menu" data-widget="tree">
        <li class="header">NAVEGACIÓN PRINCIPAL</li>
        <% int i=0;
           String s_class="";
        //---------------------------------------------------------------------------------------//
        // Comando que muestra los menus a donde tiene acceso el usuario, deacuerdo al grupo_act,//
        // al codigo personal y al area 05                             //
        //---------------------------------------------------------------------------------------//
        COMANDO = "select "+
              "a.id_grupo, "+
              "b.nombre grupo, "+
              "b.icono "+
              "from accesos_botones A, accesos_grupo B, accesos_usuarios C "+
              "where A.id_area = '"+id_area+"' "+
              "and A.id_grupo = b.id_grupo "+
              "and A.id_acceso = C.id_acceso "+
              "and C.id_personal = '"+id_personal_user+"' "+
              "group by b.id_grupo, b.nombre,b.icono "+
              "order by b.id_grupo, b.nombre ";
          rset = stmt.executeQuery(COMANDO);
          while ( rset.next() )
          {  i++;
            //if(i==1)
            //{s_class="active treeview";}
            //else
            {s_class="treeview";}
         %>
        <li class="<%=s_class%>">
          <a href="#">
            <i class="fa <%=rset.getString("icono")%>"></i> <span><%=rset.getString("grupo")%></span>
            <span class="pull-right-container">
              <i class="fa fa-angle-left pull-right"></i>
            </span>
          </a>
          <ul class="treeview-menu">
            <%
              COMANDO2 = "select "+
                          "a.id_grupo, "+
                          "a.nombre , "+
                          "a.url  "+
                          "from accesos_botones A, accesos_grupo B, accesos_usuarios C "+
                          "where A.id_area = '"+id_area+"' "+
                          "and A.id_grupo = b.id_grupo "+
                          "AND b.ID_GRUPO='"+rset.getString("id_grupo")+"' "+
                          "and A.id_acceso = C.id_acceso "+
                          "and C.id_personal = '"+id_personal_user+"' "+
                          "order by a.nombre asc, b.id_grupo ";
                      rset2 = stmt2.executeQuery(COMANDO2);
                      while ( rset2.next() )
                      { 
            %>
            <li>
              <a href="<%= rset2.getString("url") %>" target="view">
                 <i class="fa fa-circle-o"></i><%= rset2.getString("nombre")%>
              </a>
            </li>
                  <%} %>
          </ul>
        </li>
          <% }%>
      </ul>
    </section>
    <!-- /.sidebar -->
  </aside>
  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!--AQUI VA CONTENIDO MENU-->
    <iframe  src="main.html"  name="view" id="view" width="100%"  height="82%" frameborder="0"></iframe>
  </div>
  <!-- /.content-wrapper -->
  <footer class="main-footer">
    <div class="pull-right hidden-xs">
      <b>Version</b> 2.0.0
    </div>
    <strong>Copy&copy;right 2019 dick_mar@hotmail.com</a>.</strong> Todos los derechos reservados.
  </footer>
  <div class="control-sidebar-bg"></div>
</div>
<!-- ./wrapper -->

<!-- jQuery 3 -->
<script src="../plugins/js/jquery.min.js"></script>
<!-- jQuery UI 1.11.4 -->
<script src="../plugins/js/jquery-ui.min.js"></script>
<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
<script>
  $.widget.bridge('uibutton', $.ui.button);
</script>
<!-- Bootstrap 3.3.7 -->
<script src="../plugins/js/bootstrap.min.js"></script>
<!-- Morris.js charts -->
<script src="../plugins/js/raphael.min.js"></script>
<script src="../plugins/js/morris.min.js"></script>
<!-- Sparkline -->
<script src="../plugins/js/jquery.sparkline.min.js"></script>
<!-- jvectormap -->
<script src="../plugins/js/jquery-jvectormap-1.2.2.min.js"></script>
<script src="../plugins/js/jquery-jvectormap-world-mill-en.js"></script>
<!-- jQuery Knob Chart -->
<script src="../plugins/js/jquery.knob.min.js"></script>
<!-- daterangepicker -->
<script src="../plugins/js/moment.min.js"></script>
<script src="../plugins/js/daterangepicker.js"></script>
<!-- datepicker -->
<script src="../plugins/js/bootstrap-datepicker.min.js"></script>
<!-- Bootstrap WYSIHTML5 -->
<script src="../plugins/js/bootstrap3-wysihtml5.all.min.js"></script>
<!-- Slimscroll -->
<script src="../plugins/js/jquery.slimscroll.min.js"></script>
<!-- FastClick -->
<script src="../plugins/js/fastclick.js"></script>
<!-- AdminLTE App -->
<script src="../plugins/js/adminlte.min.js"></script>
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<!--<script src="../dist/js/pages/dashboard.js"></script>-->
<!-- AdminLTE for demo purposes -->
<script src="../plugins/js/demo.js"></script>
</body>
</html>
<%//@ include file="../cierradb1.jsp" %>
<%//@ include file="../cierradb.jsp" %>
