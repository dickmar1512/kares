<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>..::Menú de Productos::..</title>
	
	<!-- Google Font: Source Sans Pro -->
	<link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
	<!-- Font Awesome -->
	<link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
	<!-- Ionicons -->
	<link rel="stylesheet" href="../../assets/plugins/ionicons/css/ionicons.min.css">
	<!-- AdminLTE 3 CSS -->
	<link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
	<!-- CSS Personalizado -->
	<link rel="stylesheet" href="../../assets/css/mesa/ope_venta/show_familia_producto.css">
</head>
<body>
<div class="wrapper">
	<div class="content-wrapper">
		<!-- Content Header -->
		<section class="content-header" style="padding: 10px 15px;">
			<div class="container-fluid">
				<div class="row mb-2">
					<div class="col-sm-6">
						<h1 style="font-size: 1.5rem; margin: 0;">
							<i class="fas fa-utensils"></i> Menú de Productos
						</h1>
					</div>
					<div class="col-sm-6">
						<ol class="breadcrumb float-sm-right" style="margin: 0;">
							<li class="breadcrumb-item"><a href="#">Ventas</a></li>
							<li class="breadcrumb-item active">Menú</li>
						</ol>
					</div>
				</div>
			</div>
		</section>

		<!-- Main content -->
		<section class="content" style="padding: 0 15px 15px 15px;">
			<div class="container-fluid">
				
				<!-- Card con Tabs de AdminLTE 3 -->
				<div class="card card-primary card-outline card-outline-tabs">
					<div class="card-header p-0 border-bottom-0">
						<ul class="nav nav-tabs" id="custom-tabs-menu" role="tablist">
							<%
								int tabIndex = 0;
								Connection connTabs = null;
								PreparedStatement pstmtTabs = null;
								ResultSet rsetTabs = null;
								
								try {
									connTabs = getConexion();
									COMANDO = "SELECT ID_NIVEL, NOMBRE, estado " +
											  "FROM NIVEL " +
											  "WHERE estado = 1 " +
											  "ORDER BY nombre ASC";
									pstmtTabs = connTabs.prepareStatement(COMANDO);
									rsetTabs = pstmtTabs.executeQuery();
									
									while(rsetTabs.next()) {
										tabIndex++;
										String idNivel = rsetTabs.getString("ID_NIVEL");
										String nombre = rsetTabs.getString("NOMBRE");

										/* Verifico si hay productos en el nivel */
										Connection connCount = null;
										PreparedStatement pstmtCount = null;
										ResultSet rsetCount = null;
										
										try {
											connCount = getConexion();
											pstmtCount = connCount.prepareStatement(
												"SELECT COUNT(*) FROM patron WHERE id_nivel = ? AND estado = '1'"
											);
											pstmtCount.setString(1, idNivel);
											rsetCount = pstmtCount.executeQuery();

											int count = 0;
											if (rsetCount.next()) {
												count = rsetCount.getInt(1);
											}
											
											if (count == 0) continue;   // Sin productos → salto el tab

											String isActive = (tabIndex == 1) ? "active" : "";
									%>
									<li class="nav-item">
										<a class="nav-link <%=isActive%>" 
										   id="tab-<%=idNivel%>" 
										   data-toggle="pill" 
										   href="#nivel-<%=idNivel%>" 
										   role="tab" 
										   aria-controls="nivel-<%=idNivel%>" 
										   aria-selected="<%=tabIndex == 1%>">
											<i class="fas fa-utensils"></i> <%=nombre%>
										</a>
									</li>
									<%
										} finally {
											cerrar(rsetCount);
											cerrar(pstmtCount);
											cerrar(connCount);
										}
									}
								} finally {
									cerrar(rsetTabs);
									cerrar(pstmtTabs);
									cerrar(connTabs);
								}
							%>
						</ul>
					</div>
					
					<div class="card-body p-0" style="max-height: calc(100vh - 150px); overflow-y: auto;">
						<div class="tab-content" id="custom-tabs-menuContent">
							<%
								tabIndex = 0;
								Connection connContent = null;
								PreparedStatement pstmtContent = null;
								ResultSet rsetContent = null;
								
								try {
									connContent = getConexion();
									COMANDO = "SELECT ID_NIVEL, NOMBRE " +
											  "FROM NIVEL " +
											  "WHERE estado = 1 " +
											  "ORDER BY nombre ASC";
									pstmtContent = connContent.prepareStatement(COMANDO);
									rsetContent = pstmtContent.executeQuery();
									
									while(rsetContent.next()) {
										tabIndex++;
										String idNivel = rsetContent.getString("ID_NIVEL");
										String nombre = rsetContent.getString("NOMBRE");
										
										// Verificar si tiene productos
										Connection connCheck = null;
										PreparedStatement pstmtCheck = null;
										ResultSet rsetCheck = null;
										boolean hasProducts = false;
										
										try {
											connCheck = getConexion();
											pstmtCheck = connCheck.prepareStatement(
												"SELECT COUNT(*) FROM patron WHERE id_nivel = ? AND estado = '1'"
											);
											pstmtCheck.setString(1, idNivel);
											rsetCheck = pstmtCheck.executeQuery();
											
											if (rsetCheck.next() && rsetCheck.getInt(1) > 0) {
												hasProducts = true;
											}
										} finally {
											cerrar(rsetCheck);
											cerrar(pstmtCheck);
											cerrar(connCheck);
										}
										
										if (!hasProducts) continue;
										
										String showActive = (tabIndex == 1) ? "show active" : "";
							%>
							
							<!-- Tab de <%=nombre%> -->
							<div class="tab-pane fade <%=showActive%>" 
								 id="nivel-<%=idNivel%>" 
								 role="tabpanel" 
								 aria-labelledby="tab-<%=idNivel%>">
								
								<div class="products-grid">
									<%
										Connection connProducts = null;
										PreparedStatement pstmtProducts = null;
										ResultSet rsetProducts = null;
										
										try {
											connProducts = getConexion();
											COMANDO2 = "SELECT id_servicio, nombre, tarifa, estado " +
													  "FROM patron " +
													  "WHERE id_nivel = ? " +
													  "AND estado = '1' " +
													  "ORDER BY nombre ASC";
											pstmtProducts = connProducts.prepareStatement(COMANDO2);
											pstmtProducts.setString(1, idNivel);
											rsetProducts = pstmtProducts.executeQuery();
											
											while(rsetProducts.next()) {
												String idServicio = rsetProducts.getString("id_servicio");
												String nombreProd = rsetProducts.getString("nombre");
												String tarifa = rsetProducts.getString("tarifa");
									%>
									<div class="product-box" title="<%=nombreProd%>">
										<h5><%=nombreProd.length() > 20 ? nombreProd.substring(0, 20) + "..." : nombreProd%></h5>
										<div class="price">S/ <%=tarifa%></div>										
										<div style="margin:0">
											<div class="input-group mb-2">
												<div class="input-group-prepend"><span class="btn btn-warning"><b>Cantidad</b></span></div>
												<input type="number" 
													   name="f_cantidad" 													   
													   value="1" 
													   min="1" 
													   class="form-control qty-input cantidad-input">
											</div>
											<button type="submit" data-id-servicio="<%=idServicio%>" class="btn btn-success btn-sm btn-add btn-add-producto">
												<i class="fas fa-plus-circle"></i> Agregar
											</button>
										</div>	
									</div>
									<%
											}
										} finally {
											cerrar(rsetProducts);
											cerrar(pstmtProducts);
											cerrar(connProducts);
										}
									%>
								</div>
							</div>
							<%
									}
								} finally {
									cerrar(rsetContent);
									cerrar(pstmtContent);
									cerrar(connContent);
								}
							%>
						</div>
					</div>
				</div>

			</div>
		</section>
	</div>
</div>

<!-- jQuery -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- js Personalizado -->
<script src="../../assets/js/mesa/ope_venta/show_familia_producto.js"></script>
</body>
</html>