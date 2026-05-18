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
                        <div class="col-md-6">
                            <input type="text" class="form-control form-control-sm" name="txtbuscar" id="txtbuscar" placeholder="Nombre o DNI del cliente">
                        </div>
                        <div class="col-md-3">
                            <input type="hidden" name="f_id_personal" id="f_id_personal" value="">
                            <input type="hidden" name="f_idm" id="f_idm" value="<%=s_idm%>">
                            <button type="button" class="btn btn-primary-sm btn-sm btn-block" onclick="generarVenta(datosCliente)">
                                <i class="fas fa-money-bill mr-1"></i> Generar venta
                            </button>
                        </div>
                        <div class="col-md-3">
                            <button type="button" class="btn btn-success-sm btn-sm btn-block" onclick="abrirModalNuevoCliente()">
                                <i class="fas fa-user-plus mr-1"></i> Crear Cliente
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

<!-- Modal Registrar Cliente -->
<div class="modal fade" id="modalNuevoCliente" tabindex="-1" role="dialog" aria-labelledby="modalNuevoClienteLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content" style="border-radius: 8px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
            <div class="modal-header bg-success text-white" style="border-top-left-radius: 8px; border-top-right-radius: 8px; display: flex; align-items: center; justify-content: space-between;">
                <h5 class="modal-title" id="modalNuevoClienteLabel" style="font-size: 16px; font-weight: 700; margin: 0;"><i class="fas fa-user-plus mr-2"></i>Registrar Nuevo Cliente</h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close" style="font-size: 24px; line-height: 1; padding: 0; background: transparent; border: 0; outline: none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" style="background-color: #f8fafc; padding: 25px;">
                <form id="formNuevoCliente">
                    <div class="row">
                        <div class="col-md-6 form-group">
                            <label for="reg_tipdoc" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-id-card mr-1"></i> Tipo de Documento <span class="text-danger">*</span></label>
                            <select class="form-control form-control-sm" id="reg_tipdoc" name="tipdoc" style="border-radius: 6px; height: 38px;" onchange="ajustarCamposDocumento()">
                                <option value="1">DNI (Persona Natural)</option>
                                <option value="E">RUC (Persona Jurídica)</option>
                            </select>
                        </div>
                        <div class="col-md-6 form-group">
                            <label id="lbl_reg_numdoc" for="reg_numdoc" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-fingerprint mr-1"></i> Nro. de Documento (DNI) <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_numdoc" name="numdoc" maxlength="8" placeholder="Ingrese DNI (8 dígitos)" style="border-radius: 6px; height: 38px;">
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 form-group" id="group_nombre">
                            <label id="lbl_reg_nombre" for="reg_nombre" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-user mr-1"></i> Nombres <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_nombre" name="nombre" placeholder="Ingrese nombre" style="border-radius: 6px; height: 38px;">
                        </div>
                        <div class="col-md-3 form-group" id="group_apepat">
                            <label for="reg_apepat" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-user mr-1"></i> Apellido Paterno <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_apepat" name="apepat" placeholder="Apellido paterno" style="border-radius: 6px; height: 38px;">
                        </div>
                        <div class="col-md-3 form-group" id="group_apemat">
                            <label for="reg_apemat" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-user mr-1"></i> Apellido Materno <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_apemat" name="apemat" placeholder="Apellido materno" style="border-radius: 6px; height: 38px;">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 form-group" id="group_sexo">
                            <label for="reg_sexo" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-venus-mars mr-1"></i> Sexo <span class="text-danger">*</span></label>
                            <select class="form-control form-control-sm" id="reg_sexo" name="sexo" style="border-radius: 6px; height: 38px;">
                                <option value="">Seleccione...</option>
                                <option value="M">Masculino</option>
                                <option value="F">Femenino</option>
                            </select>
                        </div>
                        <div class="col-md-6 form-group" id="group_direccion">
                            <label for="reg_direccion" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-map-marker-alt mr-1"></i> Dirección <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_direccion" name="direccion" placeholder="Dirección completa" style="border-radius: 6px; height: 38px;">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 form-group">
                            <label for="reg_telefono" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-phone mr-1"></i> Teléfono <span class="text-muted">(Opcional)</span></label>
                            <input type="text" class="form-control form-control-sm" id="reg_telefono" name="telefono" placeholder="Número de teléfono" style="border-radius: 6px; height: 38px;">
                        </div>
                        <div class="col-md-6 form-group">
                            <label for="reg_correo" style="font-weight: 600; color: #4a5568; font-size: 12px; margin-bottom: 4px;"><i class="fas fa-envelope mr-1"></i> Correo Electrónico <span class="text-muted">(Opcional)</span></label>
                            <input type="email" class="form-control form-control-sm" id="reg_correo" name="correo" placeholder="Correo electrónico" style="border-radius: 6px; height: 38px;">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer" style="background-color: #f1f5f9; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px;">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal" style="border-radius: 6px; padding: 8px 16px;"><i class="fas fa-times mr-1"></i> Cancelar</button>
                <button type="button" class="btn btn-success btn-sm" onclick="guardarNuevoCliente()" style="border-radius: 6px; padding: 8px 16px;"><i class="fas fa-save mr-1"></i> Guardar Cliente</button>
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