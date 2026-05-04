<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestión de Mesas</title>
  
  <!-- Font Awesome -->
  <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="../../assets/plugins/ionicons/css/ionicons.min.css">
  <!-- AdminLTE -->
  <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
  <!-- Google Font -->
  <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
  <%-- Estio personalizado --%>
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/index.css" type="text/css">
</head>
<body>
<div class="wrapper">
  <!-- Content Header -->
  <div class="content-header">
    <div class="container-fluid">
      <div class="row mb-2 align-items-center">
        <div class="col-sm-6">
          <h1 class="page-title">
            <i class="fas fa-utensils"></i>
            Atención de Mesas
          </h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item"><a href="#">Operaciones</a></li>
            <li class="breadcrumb-item active"> Atención Mesas </li>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <%
     int estado = 0;
     String xclas = ""; 
     String btn = "";
     String estadoTexto = "";
  %>

  <!-- Main content -->
  <section class="content mesas-container">
    <div class="mesas-grid">
      <%
      try{
        COMANDO = "CALL sp_kar_listar_mesas()";  
        conn = getConexion();        
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery(); 
        while(rset.next())
        {      
          estado = rset.getInt("estado");

          if(estado == 0)
          {
              xclas = "disponible";
              btn = "GENERAR ORDEN";
              estadoTexto = "Disponible";
          }  
          if(estado == 1)
          {
              xclas = "reservada";
              btn = "GENERAR ORDEN";
              estadoTexto = "Reservada";
          }  
          if(estado == 2)
          {
              xclas = "ocupada";
              btn = "AGREGAR ORDEN";
              estadoTexto = "Ocupada";
          }   
        %>      
        <div class="mesa-card <%=xclas%>">
          <div class="mesa-header">
            <i class="fas fa-chair mesa-icon"></i>
            <h3 class="mesa-nombre"><%=rset.getString("descripcion")%></h3>
          </div>
          
          <div class="mesa-body">
            <div class="mesa-info">
              <i class="fas fa-users"></i>
              <span><strong>Capacidad:</strong> <%=rset.getString("cap")%> personas</span>
            </div>
            
            <div class="mesa-info">
              <i class="fas fa-info-circle"></i>
              <span><strong>Estado:</strong> <%=rset.getString("cond")%></span>
            </div>
            
            <span class="estado-badge <%=xclas%>">
              <i class="fas fa-circle" style="font-size: 0.6rem;"></i> <%=estadoTexto%>
            </span> 
            
            <div class="mesa-action">
              <a href="show_venta.jsp?idm=<%=rset.getString("idm")%>" class="btn-action <%=xclas%>">
                <%=btn%>
                <i class="fas fa-arrow-right"></i>
              </a>

            </div>
          </div>
        </div> 
      <% }
       }catch(Exception e){
        out.println("Error: " + e.getMessage());
       }finally{
        cerrar(rset, pstmt, conn);
        rset = null;
        pstmt = null;
        conn = null;
       }%>   
    </div>
  </section>
</div>

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
</body>
</html>