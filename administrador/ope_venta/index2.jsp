<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    String s_idm = request.getParameter("idm");
    if (s_idm == null) s_idm = "";

    // Limpiar variables de sesión
    xsession.putValue("id_personal", "");
    xsession.putValue("id_mov_vnt",  "");
    xsession.putValue("tipo_pac",    "");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Pedidos - Mesa <%=s_idm%></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="../../assets/plugins/bootstrap/css/bootstrap4.6.2.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/jquery-ui/jquery-ui.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/administrador/ope_venta/index2.css">
    <style>
        /* Skeleton loader */
        .skeleton-row { animation: skeleton-pulse 1.4s ease-in-out infinite; border-radius: 4px; background: #e2e8f0; height: 36px; margin-bottom: 6px; }
        @keyframes skeleton-pulse { 0%,100%{opacity:1} 50%{opacity:.4} }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<!-- Campo global para que el JS lea el idm -->
<input type="hidden" id="f_idm_global" value="<%=s_idm%>">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-shopping-cart"></i></div>
    <div>
        <h4>PEDIDOS</h4>
        <small>Operaciones &rsaquo; Ventas &rsaquo; Mesa</small>
    </div>
    <div class="ml-auto">
        <div class="mesa-badge"><i class="fas fa-chair mr-2"></i>MESA <%=s_idm%></div>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="row mb-3">
        <div class="col-md-8">
            <div class="search-box">
                <div class="search-title"><i class="fas fa-id-card"></i> Buscar Cliente por NOMBRE o DNI</div>
                <form name="datosCliente" id="datosCliente">
                    <div class="row">
                        <div class="col-md-8">
                            <input type="text" class="form-control form-control-sm" name="txtbuscar" id="txtbuscar" placeholder="Nombre o DNI del cliente">
                        </div>
                        <div class="col-md-4">
                            <input type="hidden" name="f_id_personal" id="f_id_personal" value="">
                            <input type="hidden" name="f_idm" id="f_idm" value="<%=s_idm%>">
                            <button type="button" class="btn btn-primary-sm btn-sm btn-block" onclick="generarVenta(datosCliente)">
                                <i class="fas fa-money-bill mr-1"></i> Generar venta
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <div class="col-md-4">
            <div class="search-box">
                <div class="search-title"><i class="fas fa-user"></i> Cliente Particular</div>
                <form name="datosParticular" id="datosParticular">
                    <input type="hidden" name="f_id_personal" id="f_id_personal" value="*">
                    <input type="hidden" name="f_idm" id="f_idm" value="<%=s_idm%>">
                    <button type="button" class="btn btn-particular-sm btn-sm btn-block" onclick="generarVenta(datosParticular)">
                        <i class="fas fa-money-bill mr-1"></i> Particular
                    </button>
                </form>
            </div>
        </div>
    </div>

    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">ÓRDENES REGISTRADAS</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <form name="form_ordenes" id="form_ordenes">
                    <input type="hidden" name="f_num" id="f_num" value="0">

                    <!-- Skeleton visible mientras carga el SP -->
                    <div id="ordenes-skeleton" class="p-3">
                        <div class="skeleton-row"></div>
                        <div class="skeleton-row" style="opacity:.7"></div>
                        <div class="skeleton-row" style="opacity:.5"></div>
                    </div>

                    <!-- Órdenes inyectadas por AJAX -->
                    <div id="ordenes-container"></div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/jquery-ui/jquery-ui.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script src="../../assets/js/administrador/ope_venta/index2.js?v=3"></script>
</body>
</html>