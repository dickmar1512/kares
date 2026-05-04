<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>..::Mesas::..</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="../../assets/plugins/fontawesome-free/css/all.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="../../assets/plugins/ionicons/css/ionicons.min.css">
  <!-- Tempusdominus Bbootstrap 4 -->
  <link rel="stylesheet" href="../../assets/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
  <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
  <!-- Google Font -->
  <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
</head>
<body> <!-- class="hold-transition sidebar-mini layout-fixed"-->
<div class="wrapper">
  <!-- Content Wrapper. Contains page content -->
  <!--div class="content-wrapper"-->
    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
           <h1 class="m-0 text-dark"><i class="fas fa-folder-o icon-title"></i> Mesas</h1>
          </div><!-- /.col -->
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="#">Operaciones</a></li>
              <li class="breadcrumb-item active">Cambio de Mesa</li>
            </ol>
          </div><!-- /.col -->
        </div><!-- /.row -->
      </div><!-- /.container-fluid -->
    </div>
    <!-- /.content-header -->
    <%
       int estado=0;
       String xclas=""; 
       String url="";
       int c=0;
    %>
    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <!-- Small boxes (Stat box) -->
        <div class="row">          
        <%
        COMANDO = "select idm,descripcion, "+
                  "CONCAT(numasi,' ','ASIENTOS') CAP, "+
                  "estado "+
                  "from mesas "+
                  "where estado ='2'";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);          
        rset = pstmt.executeQuery();   
        while(rset.next())
        {   c++;         
        %>
          <div class="col-lg-3 col-6">
            <!-- small box -->
            <div class="small-box bg-danger">
              <div class="inner">
                <h3>
                  <%=rset.getString("descripcion")%>
                </h3>
              </div>
              <div class="icon">
                <i class="ion ion-person-add"></i>
              </div>
              <a href="index2.jsp?idm=<%=rset.getString("idm")%>" class="small-box-footer">
               Ver Consumo <i class="fas fa-arrow-circle-right"></i>
             </a>
            </div>
          </div>
          <!-- ./col -->
       <% }
        cerrar(conn);cerrar(pstmt);cerrar(rset);
       %>   
        </div>
        <!-- /.row -->
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  <!--/div-->
</div>
<!-- ./wrapper -->
</body>
</html>
