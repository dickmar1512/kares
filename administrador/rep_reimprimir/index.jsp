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
                                <th style="width:160px">Comprobante</th>
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
                                   "concat(nom_doc3(tipo_doc),' ',serie,'-',lpad(numdoc,7,0)) doc, total "+
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
                                    <span class="doc-badge">
                                        <i class="fas fa-receipt"></i>
                                        <%=rset.getString("doc")%>
                                    </span>
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

<!-- jQuery + Bootstrap 4 + AdminLTE -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<%-- <script src="../../assets/plugins/adminlte3/js/adminlte.min.js"></script> --%>
<script src="../../assets/js/administrador/rep_reimprimir/index.js"></script>
</body>
</html>
