<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file= "../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    String s_alert = request.getParameter("alert"); if(s_alert==null) s_alert="X";

    /* ── Artículos SIN precio configurado ──────────────────────── */
    java.util.List<String[]> sinPrecio = new java.util.ArrayList<>();
    try {
        COMANDO = "SELECT a.idart, a.idalmart, a.idservicio, " +
                  "servicio(a.idservicio) articulo, format(a.cu,2) cu " +
                  "FROM articulo a " +
                  "where a.estado = '1' " +
                  "and a.idservicio not in(select b.idservicio from utilidad b) " +
                  "ORDER BY articulo asc";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        while(rset.next()) {
            sinPrecio.add(new String[]{
                rset.getString("idart"),
                rset.getString("idalmart"),
                rset.getString("idservicio"),
                rset.getString("articulo"),
                rset.getString("cu")
            });
        }
    } catch(Exception e) {
        out.println("<!-- Error: " + e.getMessage() + " -->");
    } finally {
        cerrar(rset, pstmt, conn);
    }

    /* ── Artículos CON precio configurado ──────────────────────── */
    java.util.List<String[]> conPrecio = new java.util.ArrayList<>();
    try {
        COMANDO = "SELECT a.idart, a.idalmart, a.idservicio, " +
                  "servicio(a.idservicio) articulo, format(a.cu,2) cu, " +
                  "b.porcutil, format(b.utilfijo,2) utilfijo, " +
                  "(case when b.utilfijo=0 " +
                  "  then format((a.cu+(a.cu*(b.porcutil/100))),2) " +
                  "  else format(a.cu+b.utilfijo,2) end) pv " +
                  "FROM articulo a, utilidad b " +
                  "where a.idservicio=b.idservicio " +
                  "ORDER BY articulo asc";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        while(rset.next()) {
            conPrecio.add(new String[]{
                rset.getString("idart"),
                rset.getString("idalmart"),
                rset.getString("idservicio"),
                rset.getString("articulo"),
                rset.getString("cu"),
                rset.getString("porcutil"),
                rset.getString("utilfijo"),
                rset.getString("pv")
            });
        }
    } catch(Exception e) {
        out.println("<!-- Error: " + e.getMessage() + " -->");
    } finally {
        cerrar(rset, pstmt, conn);
    }
    boolean haySinPrecio = !sinPrecio.isEmpty();
%>

<!-- ── Alert ───────────────────────────────────────────────────── -->
<% if(s_alert.equals("1") || s_alert.equals("2")){ %>
<div class="alert-compact alert-success-compact mb-2">
    <i class="fas fa-check-circle"></i>
    <% if(s_alert.equals("1")){ %>Utilidad <strong>registrada</strong> correctamente.<% } %>
    <% if(s_alert.equals("2")){ %>Utilidad <strong>actualizada</strong> correctamente.<% } %>
</div>
<% } %>

<!-- ════════════════════════════════════════════════════════════ -->
<!-- SECCIÓN: SIN PRECIO (solo si hay artículos pendientes)      -->
<!-- ════════════════════════════════════════════════════════════ -->
<% if(haySinPrecio){ %>
<div class="card-kares">
    <div class="card-header warning-header">
        <i class="fas fa-exclamation-triangle" style="font-size:11px; opacity:.85;"></i>
        <span class="card-title">Artículos sin Precio de Venta configurado</span>
        <span class="badge-count"><%=sinPrecio.size()%> pendiente(s)</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table id="tblSinPrecio" class="table table-kares table-hover mb-0">
                <thead>
                    <tr>
                        <th style="width:36px;">#</th>
                        <th style="width:90px;">Código</th>
                        <th>Nombre del Artículo</th>
                        <th style="width:110px; text-align:right;">Costo Unit.</th>
                        <th style="width:80px; text-align:center;">Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <% int i=0; for(String[] r : sinPrecio){ i++; %>
                    <tr>
                        <td style="text-align:center; color:#a0aec0; font-size:11px;"><%=i%></td>
                        <td><span class="code"><%=r[1]%></span></td>
                        <td>
                            <%=r[3]%>
                            <span class="no-price-badge ml-1">Sin precio</span>
                        </td>
                        <td class="amount">S/ <%=r[4]%></td>
                        <td style="text-align:center;">
                            <a href="javascript:void(0);"
                               onclick="loadForm('<%=r[2]%>','I',null)"
                               class="btn-kares" title="Configurar precio">
                                <i class="fas fa-tag"></i> Configurar
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<% } %>

<!-- ════════════════════════════════════════════════════════════ -->
<!-- SECCIÓN: CON PRECIO CONFIGURADO                             -->
<!-- ════════════════════════════════════════════════════════════ -->
<div class="card-kares">
    <div class="card-header">
        <i class="fas fa-tags" style="font-size:11px; opacity:.85;"></i>
        <span class="card-title">Artículos con Margen de Ganancia</span>
        <span class="badge-count"><%=conPrecio.size()%> artículo(s)</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table id="tblConPrecio" class="table table-kares table-hover mb-0">
                <thead>
                    <tr>
                        <th style="width:36px;">#</th>
                        <th style="width:90px;">Código</th>
                        <th>Nombre del Artículo</th>
                        <th style="width:110px; text-align:right;">Costo Unit.</th>
                        <th style="width:80px; text-align:right;">Ganancia %</th>
                        <th style="width:100px; text-align:right;">Util. Fija</th>
                        <th style="width:110px; text-align:right;">Precio Venta</th>
                        <th style="width:70px; text-align:center;">Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <% int i=0; for(String[] r : conPrecio){ i++;
                       boolean usesPct = !r[5].equals("0");
                    %>
                    <tr>
                        <td style="text-align:center; color:#a0aec0; font-size:11px;"><%=i%></td>
                        <td><span class="code"><%=r[1]%></span></td>
                        <td><%=r[3]%></td>
                        <td class="amount">S/ <%=r[4]%></td>
                        <td class="pct">
                            <% if(usesPct){ %>
                            <span style="background:#e8f5e9; border:1px solid #a5d6a7; border-radius:10px; padding:1px 8px; font-size:11px;">
                                <%=r[5]%>%
                            </span>
                            <% } else { %><span style="color:#ccc;">—</span><% } %>
                        </td>
                        <td class="amount">
                            <% if(!r[6].equals("0.00") && !r[6].equals("0")){ %>
                            S/ <%=r[6]%>
                            <% } else { %><span style="color:#ccc;">—</span><% } %>
                        </td>
                        <td class="amount" style="color:#1a3c6e; font-weight:700;">S/ <%=r[7]%></td>
                        <td style="text-align:center;">
                            <a href="javascript:void(0);"
                               onclick="loadForm('<%=r[2]%>','U','<%=r[0]%>')"
                               class="btn-kares" title="Editar">
                                <i class="fas fa-edit"></i>
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    <% if(conPrecio.isEmpty()){ %>
                    <tr>
                        <td colspan="8" style="text-align:center; padding:30px; color:#a0aec0;">
                            <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                            No hay artículos configurados aún.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
$(function(){
    if($.fn.DataTable.isDataTable('#tblSinPrecio')) $('#tblSinPrecio').DataTable().destroy();
    if($.fn.DataTable.isDataTable('#tblConPrecio')) $('#tblConPrecio').DataTable().destroy();
    var dtES = {
        "sProcessing":"Procesando...","sLengthMenu":"Mostrar _MENU_ registros",
        "sZeroRecords":"Sin resultados","sEmptyTable":"Sin datos",
        "sInfo":"Registros _START_–_END_ de _TOTAL_","sInfoEmpty":"0 registros",
        "sSearch":"Buscar:","sLoadingRecords":"Cargando...",
        "oPaginate":{"sFirst":"«","sLast":"»","sNext":"›","sPrevious":"‹"}
    };
    <% if(haySinPrecio){ %>
    $('#tblSinPrecio').DataTable({ language: dtES, pageLength: 10, order:[[2,'asc']] });
    <% } %>
    $('#tblConPrecio').DataTable({ language: dtES, pageLength: 15, order:[[2,'asc']] });
});
</script>