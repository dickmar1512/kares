<%@page language="java" contentType="text/html, charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
  String s_idm = request.getParameter("idm");
  String s_id_mov_vnt = "";
	try{		
		COMANDO	=	"select "+
						"round(RAND()*10000000000000000) "+
					"from dual ";
		conn = getConexion();
		pstmt = conn.prepareStatement(COMANDO);		
		rset = pstmt.executeQuery();
		rset.next();
		{ band++;
			s_id_mov_vnt = rset.getString(1);
		}
	} catch(Exception e){ 
        out.println("ERROR: " + e.getMessage()); 
    } finally{ 
        cerrar(rset); cerrar(pstmt); cerrar(conn);
        COMANDO = ""; 
     }

	xsession.putValue("id_mov_vnt", s_id_mov_vnt);
	xsession.putValue("idm",s_idm);	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>..::Sistema de Ventas::..</title>
	
	<!-- Font Awesome -->
	<link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
	<!-- AdminLTE 3 CSS -->
	<link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
	<!-- CSS Personalizado -->
	<link rel="stylesheet" href="../../assets/css/mesa/ope_venta/show_venta.css">
</head>
<body>
	<div class="main-container">
		<!-- Sección Superior: Familias y Productos en Tabs -->
		<div class="top-section">
			<iframe src="show_familia_producto.jsp" name="menu" id="menu" width="100%" height="400px" frameborder="0"></iframe>
		</div>
		
		<!-- Sección Inferior: Formulario de Venta -->
		<div class="bottom-section">
			<iframe src="form_venta.jsp" name="venta" id="venta" width="100%" height="400px" frameborder="0"></iframe>
		</div>
	</div>
	<script>
		function actualizarTotalVenta() {
			// Recargar el contenido del iframe de ventas
			var iframe = document.getElementById('venta');
			if(iframe && iframe.contentWindow) {
				iframe.contentWindow.location.reload();
			}
		}
	</script>
</body>
</html>