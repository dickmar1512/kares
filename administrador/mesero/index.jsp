<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Códigos QR para Mesas</title>
  
  <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
  <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
  <style>
    .qr-card {
        text-align: center;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        background: #fff;
        page-break-inside: avoid;
    }
    .qr-img {
        width: 200px;
        height: 200px;
        margin: 15px auto;
        border: 10px solid #fff;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .mesa-title {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1a56a0;
        margin-bottom: 5px;
    }
    .scan-text {
        font-size: 1.1rem;
        color: #6b7a90;
        margin-bottom: 10px;
    }
    .print-btn {
        margin-bottom: 20px;
    }
    @media print {
        .print-btn, .main-header, .main-sidebar, .content-header { display: none !important; }
        .content-wrapper { margin-left: 0 !important; }
        body { background: #fff !important; }
        .row { display: flex; flex-wrap: wrap; }
        .col-md-4 { width: 33.333%; padding: 10px; }
        .qr-card { box-shadow: none; border: 2px dashed #ccc; }
    }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper" style="height:100vh; display:flex; flex-direction:column;">
  
  <%-- <div class="content-wrapper"> --%>
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0"><i class="fas fa-qrcode text-primary"></i> Códigos QR - Mesero Virtual</h1>
          </div>
          <div class="col-sm-6 text-right">
            <button class="btn btn-primary print-btn" onclick="window.print()">
                <i class="fas fa-print"></i> Imprimir Códigos QR
            </button>
          </div>
        </div>
      </div>
    </div>

    <section class="content">
      <div class="container-fluid">
        <div class="row">
          <%
            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/mesero/index.jsp";
            
            try {
                COMANDO = "SELECT idm, descripcion, numasi FROM mesas  ORDER BY CAST(idm AS UNSIGNED)";
                conn = getConexion();          
                pstmt = conn.prepareStatement(COMANDO);
                rset = pstmt.executeQuery(); 
                
                while(rset.next()) {
                    String idm = rset.getString("idm");
                    String desc = rset.getString("descripcion");
                    String cap = rset.getString("numasi");
                    String urlMesa = baseUrl + "?idm=" + idm;
                    String qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&margin=10&data=" + java.net.URLEncoder.encode(urlMesa, "UTF-8");
          %>
            <div class="col-md-4 col-sm-6">
                <div class="qr-card">
                    <div class="mesa-title"><%=desc%></div>
                    <div class="badge badge-info mb-2"><i class="fas fa-users"></i> Capacidad: <%=cap%></div>
                    <div class="scan-text">Escanea para ordenar</div>
                    <img src="<%=qrUrl%>" class="qr-img" alt="QR Mesa <%=idm%>">
                    <div class="text-muted small mt-2"><i class="fas fa-link"></i> <%=urlMesa%></div>
                </div>
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
    </section>
  <%-- </div> --%>
</div>
</body>
</html>
