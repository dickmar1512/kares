<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
   String s_tipo_doc = request.getParameter("f_tipo_doc");
   String s_numdoc   = request.getParameter("f_numdoc");
   String nomTipoDoc = "";
   int cont = 0;
   String url = "";
   boolean hayBusqueda = (s_tipo_doc != null && s_numdoc != null && !s_numdoc.trim().isEmpty());
   
   if(hayBusqueda) {
       if(s_tipo_doc.equals("11")) {
           url="print_orden.jsp";
           nomTipoDoc = "ORDEN DE VENTA";
       } 
       if(s_tipo_doc.equals("34")) {
           url="print_nota_venta_pdf.jsp";
           nomTipoDoc = "NOTA DE VENTA";
       }
       if(s_tipo_doc.equals("39")) {
           url="print_factura_electronica_pdf.jsp";
           nomTipoDoc = "FACTURA ELECTRÓNICA";
       }
       if(s_tipo_doc.equals("41")) {
           url="print_boleta_electronica_pdf.jsp";
           nomTipoDoc = "BOLETA ELECTRÓNICA";
       }
   }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Reimpresión de Comprobantes</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- AdminLTE 3 + Bootstrap 4 -->
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/administrador/rep_reimprimir/index.css">
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-file-invoice"></i></div>
    <div>
        <h4>Reimpresión de Comprobantes</h4>
        <small>Ventas &rsaquo; Comprobantes &rsaquo; Reimpresión</small>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="card-kares mb-3">
        <div class="card-header">
            <i class="fas fa-search" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Criterios de Búsqueda</span>
        </div>
        <div class="card-body">
            <form name="datos" method="post" action="">
                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group mb-2">
                            <label style="font-size:11px; font-weight:700; color:#4a5568; text-transform:uppercase;">Tipo de Comprobante</label>
                            <select class="form-control form-control-sm" name="f_tipo_doc" required>
                                <option value="" disabled <%= (s_tipo_doc == null) ? "selected" : "" %>>— Seleccione —</option>
                                <option value="41" <%= "41".equals(s_tipo_doc) ? "selected" : "" %>>Boleta Electrónica</option>
                                <option value="39" <%= "39".equals(s_tipo_doc) ? "selected" : "" %>>Factura Electrónica</option>
                                <option value="34" <%= "34".equals(s_tipo_doc) ? "selected" : "" %>>Nota de Venta</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group mb-2">
                            <label style="font-size:11px; font-weight:700; color:#4a5568; text-transform:uppercase;">Número de Documento</label>
                            <input type="text" class="form-control form-control-sm" name="f_numdoc" placeholder="Ej: 000125" value="<%= (s_numdoc != null) ? s_numdoc : "" %>" required>
                        </div>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-corporate w-100 mb-2">
                            <i class="fas fa-search mr-1"></i> Buscar Documento
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

        <!-- ══ RESULTS CARD ════════════════════════════════════════ -->
        <% if(hayBusqueda) { %>
        <div class="card-kares">
            <div class="card-header">
                <i class="fas fa-list-ul" style="font-size:11px; opacity:.85;"></i>
                <span class="card-title">Resultados</span>
                <span class="results-meta ml-auto" id="totalResultados">0 registros</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-kares table-hover mb-0">
                        <thead>
                            <tr>
                                <th style="width:40px">#</th>
                                <th>Cliente</th>
                                <th style="width:110px">RUC / DNI</th>
                                <th style="width:300px">Comprobante</th>
                                <th style="width:140px">Fecha</th>
                                <th style="width:90px; text-align:right">Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                          COMANDO ="select id_mov_vnt, id_personal, "+
                                   "(case when tipo_doc = '39' then razon  else nombre(id_personal) end) nombre, "+
                                   "(case when tipo_doc = '39' then ruc else dni(id_personal) end) docpersona, "+
                                   "date_format(fecha,'%d/%m/%Y %H:%i') fecha, "+
                                   "concat(nom_doc3(tipo_doc),' ',serie,'-',lpad(numdoc,7,0)) doc, total, "+
                                   "id_vnt_ref, ref_doc, ref_obs, ref_motivo "+
                                   "from vent_registro "+
                                   "where tipo_doc = ? "+
                                   "and numdoc = ? ";
                          conn = getConexion();
                          pstmt = conn.prepareStatement(COMANDO);
                          pstmt.setString(1, s_tipo_doc);
                          pstmt.setString(2, s_numdoc);
                          rset = pstmt.executeQuery();
                          boolean hayResultados = false;

                          while(rset.next()) {
                              hayResultados = true;
                              cont++;
                        %>
                            <tr>
                                <td>
                                    <span class="row-num"><%=cont%></span>
                                </td>
                                <td>
                                    <a href="javascript:void(0);"
                                       onclick="openPDFModal('<%=rset.getString("id_mov_vnt")%>', '<%=url%>')"
                                       class="client-link"
                                       title="Ver comprobante PDF">
                                        <span class="link-icon"><i class="fas fa-file-pdf"></i></span>
                                        <%=rset.getString("nombre")%>
                                    </a>
                                </td>
                                <td>
                                    <span class="doc-id"><%=rset.getString("docpersona")%></span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center justify-content-between">
                                        <span class="doc-badge">
                                            <i class="fas fa-receipt"></i>
                                            <%=rset.getString("doc")%>
                                        </span>
                                        <% if("34".equals(s_tipo_doc)) { 
                                                String refObs = rset.getString("ref_obs");
                                                String currentIdMovVnt = rset.getString("id_mov_vnt");
                                                
                                                // Consultar estado de canje a nivel de detalle
                                                int totalDet = 0;
                                                int canjeadosDet = 0;
                                                PreparedStatement pstmtDet = null;
                                                ResultSet rsetDet = null;
                                                try {
                                                    pstmtDet = conn.prepareStatement(
                                                        "SELECT COUNT(*) AS total_det, " +
                                                        "SUM(CASE WHEN IFNULL(det_transf,'') <> '' THEN 1 ELSE 0 END) AS canjeados_det " +
                                                        "FROM vent_regdet WHERE id_mov_vnt = ? AND estado <> 'X'");
                                                    pstmtDet.setString(1, currentIdMovVnt);
                                                    rsetDet = pstmtDet.executeQuery();
                                                    if (rsetDet.next()) {
                                                        totalDet = rsetDet.getInt("total_det");
                                                        canjeadosDet = rsetDet.getInt("canjeados_det");
                                                    }
                                                } finally {
                                                    if (rsetDet != null) try { rsetDet.close(); } catch(Exception ex) {}
                                                    if (pstmtDet != null) try { pstmtDet.close(); } catch(Exception ex) {}
                                                }
                                                
                                                int pendientesDet = totalDet - canjeadosDet;
                                                
                                                if (canjeadosDet > 0 && pendientesDet == 0) {
                                                    // TODOS canjeados
                                         %>
                                                    <span class="badge badge-success ml-2 px-2 py-1" style="font-size:10px; font-weight:700;" title="Nota de Venta Canjeada">
                                                        <i class="fas fa-check-circle mr-1"></i> CANJEADO (<%=canjeadosDet%>/<%=totalDet%>)
                                                    </span>
                                         <%     } else if (canjeadosDet > 0 && pendientesDet > 0) {
                                                    // PARCIALMENTE canjeado
                                         %>
                                                    <span class="badge badge-warning ml-2 px-2 py-1" style="font-size:10px; font-weight:700; color:#744210;" title="Canje Parcial: <%=canjeadosDet%> de <%=totalDet%> productos canjeados">
                                                        <i class="fas fa-exclamation-circle mr-1"></i> PARCIAL (<%=canjeadosDet%>/<%=totalDet%>)
                                                    </span>
                                                    <button type="button" 
                                                            class="btn btn-xs btn-outline-success ml-1 px-2 py-0" 
                                                            style="font-size:10px; font-weight:700;"
                                                            onclick="openCanjeProductosModal('<%=currentIdMovVnt%>')"
                                                            title="Canjear productos restantes">
                                                        <i class="fas fa-file-invoice"></i> Canjear Restantes
                                                    </button>
                                         <%     } else {
                                                    // NINGUNO canjeado
                                         %>
                                                    <button type="button" 
                                                            class="btn btn-xs btn-outline-success ml-2 px-2 py-0" 
                                                            style="font-size:10px; font-weight:700;"
                                                            onclick="openCanjeProductosModal('<%=currentIdMovVnt%>')"
                                                            title="Canjear por Comprobante Electrónico">
                                                        <i class="fas fa-file-invoice"></i> Canjear
                                                    </button>
                                         <%     }
                                            } %>
                                    </div>
                                </td>
                                <td class="date-cell">
                                    <i class="far fa-clock"></i>
                                    <%=rset.getString("fecha")%>
                                </td>
                                <td style="text-align:right">
                                    <span class="total-badge">S/ <%=rset.getString("total")%></span>
                                </td>
                            </tr>
                        <%
                          }
                          if(!hayResultados) {
                        %>
                            <tr class="no-results-row">
                                <td colspan="6">
                                    <div class="no-results-box">
                                        <div class="nr-icon">
                                            <i class="fas fa-search-minus"></i>
                                        </div>
                                        <h6>Sin resultados</h6>
                                        <p>No se encontraron documentos con los criterios ingresados.</p>
                                    </div>
                                </td>
                            </tr>
                        <%
                          }
                        %>
                        </tbody>
                    </table>
                </div><!-- /.table-responsive -->
            </div><!-- /.card-body -->
            <% if(cont > 0) { %>
            <div class="card-footer p-2" style="background:#fafbfd; border-top:1px solid #e4e8ef;">
                <small class="text-muted">
                    <i class="fas fa-info-circle mr-1"></i>
                    Se encontraron <strong><%=cont%></strong> documento(s). Haga clic en el nombre del cliente para ver el PDF.
                </small>
            </div>
            <% } %>
        </div><!-- /.card results -->
        <% } %>

    </div>
</div>

<!-- ══ PDF MODAL ══════════════════════════════════════════════════ -->
<div class="modal fade" id="pdfModal" tabindex="-1" aria-labelledby="pdfModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content" style="border-radius:6px; overflow:hidden; border:none;">
            <div class="modal-header">
                <h5 class="modal-title" id="pdfModalLabel">
                    <i class="fas fa-file-pdf mr-2"></i>
                    Vista Previa &mdash; <%=nomTipoDoc.isEmpty() ? "Comprobante" : nomTipoDoc%>
                </h5>
                <button type="button" class="close text-white ml-auto" data-dismiss="modal" aria-label="Cerrar" style="opacity:.9;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" style="height:78vh; padding:0;">
                <iframe id="pdfViewer" style="width:100%;height:100%;border:none;"></iframe>
            </div>
            <div class="modal-footer" style="background:#f8f9fa; border-top:1px solid #dee2e6;">
                <button type="button" class="btn btn-sm btn-default" data-dismiss="modal">
                    <i class="fas fa-times mr-1"></i>Cerrar
                </button>
                <button type="button" class="btn btn-sm btn-warning" onclick="downloadPDF()">
                    <i class="fas fa-download me-2"></i>Descargar
                </button>
                <button type="button" class="btn btn-sm btn-corporate" onclick="printPDF()">
                    <i class="fas fa-print mr-1"></i>Imprimir
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ══ MODAL PASO 1: SELECCIÓN DE PRODUCTOS A CANJEAR ═══════════════════════ -->
<div class="modal fade" id="canjeProductosModal" tabindex="-1" aria-labelledby="canjeProductosModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="border-radius:6px; overflow:hidden; border:none; box-shadow: 0 10px 25px rgba(0,0,0,.2);">
            <div class="modal-header" style="background:linear-gradient(135deg,#1e40af,#3b82f6); color:#fff; border-bottom:none; padding:12px 20px;">
                <h5 class="modal-title font-weight-bold" id="canjeProductosModalLabel" style="font-size:15px;">
                    <i class="fas fa-boxes mr-2"></i>
                    Paso 1: Seleccione los Productos a Canjear
                </h5>
                <button type="button" class="close text-white ml-auto" data-dismiss="modal" aria-label="Cerrar" style="opacity:.9; outline:none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body p-0" style="background:#f8fafc;">
                <!-- Loading -->
                <div id="canjeProductosLoading" class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                    <p class="mt-2 mb-0 text-muted">Cargando productos...</p>
                </div>
                <!-- Tabla de productos -->
                <div id="canjeProductosContent" style="display:none;">
                    <div class="px-3 pt-3 pb-2">
                        <div class="d-flex justify-content-between align-items-center">
                            <small class="text-muted"><i class="fas fa-info-circle mr-1"></i> Seleccione los productos que desea incluir en el comprobante</small>
                            <span id="canjeProductosResumen" class="badge badge-primary px-2 py-1" style="font-size:11px;">0 seleccionados</span>
                        </div>
                    </div>
                    <div class="table-responsive" style="max-height:350px; overflow-y:auto;">
                        <table class="table table-sm table-hover mb-0" id="tablaCanjeProductos">
                            <thead style="background:#e2e8f0; position:sticky; top:0; z-index:1;">
                                <tr>
                                    <th style="width:40px; text-align:center;"><input type="checkbox" id="chkSelectAllCanje" title="Seleccionar todos"></th>
                                    <th style="width:35px">#</th>
                                    <th>Producto</th>
                                    <th style="width:60px; text-align:center;">Cant.</th>
                                    <th style="width:90px; text-align:right;">Total</th>
                                    <th style="width:90px; text-align:center;">Estado</th>
                                </tr>
                            </thead>
                            <tbody id="canjeProductosTbody"></tbody>
                            <tfoot>
                                <tr style="background:#f1f5f9; font-weight:700;">
                                    <td colspan="4" class="text-right" style="font-size:12px;">TOTAL SELECCIONADO:</td>
                                    <td class="text-right" style="font-size:13px; color:#16a34a;" id="canjeProductosTotalSel">S/ 0.00</td>
                                    <td></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="background:#f1f5f9; border-top:1px solid #e2e8f0; padding:12px 20px;">
                <button type="button" class="btn btn-sm btn-secondary font-weight-bold px-3" data-dismiss="modal" style="border-radius:4px;">
                    <i class="fas fa-times mr-1"></i>Cancelar
                </button>
                <button type="button" class="btn btn-sm btn-primary font-weight-bold px-4" id="btnSiguienteCanje" onclick="siguienteCanjeCliente()" disabled style="border-radius:4px;">
                    <i class="fas fa-arrow-right mr-1"></i>Siguiente: Datos del Cliente
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ══ MODAL PASO 2: DATOS DEL CLIENTE (GENERAR BOLETA O FACTURA) ═══════════ -->
<div class="modal fade" id="canjeModal" tabindex="-1" aria-labelledby="canjeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:6px; overflow:hidden; border:none; box-shadow: 0 10px 25px rgba(0,0,0,.2);">
            <div class="modal-header bg-success text-white" style="border-bottom:none; padding:12px 20px;">
                <h5 class="modal-title font-weight-bold" id="canjeModalLabel" style="font-size:15px;">
                    <i class="fas fa-file-invoice mr-2"></i>
                    Paso 2: Datos del Comprobante Electrónico
                </h5>
                <button type="button" class="close text-white ml-auto" data-dismiss="modal" aria-label="Cerrar" style="opacity:.9; outline:none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form id="canjeForm" onsubmit="procesarCanje(event)">
                <input type="hidden" id="canje_id_mov_vnt" name="id_mov_vnt">
                <input type="hidden" id="canje_id_movarts" name="id_movarts">
                <div class="modal-body p-4" style="background:#f8fafc;">
                    <!-- Resumen de productos seleccionados -->
                    <div class="mb-3 p-2" style="background:#eef2ff; border:1px solid #c7d2fe; border-radius:6px;">
                        <small class="text-muted d-block" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px; font-weight:700;">Productos Seleccionados</small>
                        <span id="canjeResumenProductos" class="font-weight-bold" style="font-size:13px; color:#1e40af;">0 productos — S/ 0.00</span>
                    </div>
                    <div class="row">
                        <!-- Selector de Comprobante -->
                        <div class="col-md-12 mb-3">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Tipo de Comprobante</label>
                            <select class="form-control form-control-sm font-weight-bold" id="canje_tipo_compro" name="tipo_comprobante" required style="border-radius:4px;">
                                <option value="41" selected>Boleta Electrónica</option>
                                <option value="39">Factura Electrónica</option>
                            </select>
                        </div>
                        
                        <!-- DNI o RUC -->
                        <div class="col-md-12 mb-3">
                            <label class="form-label font-weight-bold text-secondary mb-1" id="label_doc_num" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">DNI del Cliente</label>
                            <div class="input-group input-group-sm">
                                <input type="text" class="form-control" id="canje_dni" name="dni" maxlength="8" pattern="\d{8}" placeholder="Ingrese 8 dígitos" required style="border-radius:4px 0 0 4px;">
                                <div class="input-group-append">
                                    <button type="button" class="btn btn-dark font-weight-bold px-3" onclick="buscarDniDinamico()" title="Buscar en sistema" style="border-radius:0 4px 4px 0;">
                                        <i class="fas fa-search mr-1"></i> Buscar
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Campos de Factura: Razón Social -->
                        <div class="col-md-12 mb-3 field-factura" style="display:none;">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Razón Social</label>
                            <input type="text" class="form-control form-control-sm" id="canje_razon_social" name="razon_social" style="border-radius:4px;">
                        </div>
                        
                        <!-- Campos de Boleta: Nombres, Apellidos, Sexo -->
                        <div class="col-md-12 mb-3 field-boleta">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Nombres</label>
                            <input type="text" class="form-control form-control-sm" id="canje_nombre" name="nombre" required style="border-radius:4px;">
                        </div>
                        <div class="col-md-6 mb-3 field-boleta">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Apellido Paterno</label>
                            <input type="text" class="form-control form-control-sm" id="canje_apepat" name="apepat" required style="border-radius:4px;">
                        </div>
                        <div class="col-md-6 mb-3 field-boleta">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Apellido Materno</label>
                            <input type="text" class="form-control form-control-sm" id="canje_apemat" name="apemat" required style="border-radius:4px;">
                        </div>
                        <div class="col-md-12 mb-3 field-boleta">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Sexo</label>
                            <select class="form-control form-control-sm" id="canje_sexo" name="sexo" required style="border-radius:4px;">
                                <option value="" disabled selected>— Seleccione —</option>
                                <option value="M">Masculino</option>
                                <option value="F">Femenino</option>
                            </select>
                        </div>
                        
                        <!-- Dirección (Común) -->
                        <div class="col-md-12 mb-1">
                            <label class="form-label font-weight-bold text-secondary mb-1" style="font-size:10px; text-transform:uppercase; letter-spacing:0.5px;">Dirección</label>
                            <input type="text" class="form-control form-control-sm" id="canje_direccion" name="direccion" placeholder="Opcional" style="border-radius:4px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="background:#f1f5f9; border-top:1px solid #e2e8f0; padding:12px 20px;">
                    <button type="button" class="btn btn-sm btn-outline-primary font-weight-bold px-3" onclick="volverAProductos()" style="border-radius:4px;">
                        <i class="fas fa-arrow-left mr-1"></i>Volver
                    </button>
                    <button type="button" class="btn btn-sm btn-secondary font-weight-bold px-3" data-dismiss="modal" style="border-radius:4px;">
                        <i class="fas fa-times mr-1"></i>Cancelar
                    </button>
                    <button type="submit" class="btn btn-sm btn-success font-weight-bold px-4" style="border-radius:4px; background:#22c55e; border:none;">
                        <i class="fas fa-check mr-1"></i>Generar Comprobante
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- jQuery + Bootstrap 4 + AdminLTE -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<%-- <script src="../../assets/plugins/adminlte3/js/adminlte.min.js"></script> --%>
<script src="../../assets/js/administrador/rep_reimprimir/index.js?v=<%=System.currentTimeMillis()%>"></script>
</body>
</html>
