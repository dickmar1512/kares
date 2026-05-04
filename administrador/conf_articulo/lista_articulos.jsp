<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    /* ── Listado de Artículos ── */
    java.util.List<String[]> articulos = new java.util.ArrayList<>();
    try {
        conn = getConexion();
        COMANDO = "SELECT idart, idservicio, idalmart, servicio(idservicio) articulo, " +
                  "cu, format(cu,2) cu_fmt, und(unidad) und, stock, estado " +
                  "FROM articulo ORDER BY articulo asc";
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        while (rset.next()) {
            articulos.add(new String[]{
                rset.getString("idart"),
                rset.getString("idservicio"),
                rset.getString("idalmart"),
                rset.getString("articulo"),
                rset.getString("cu"),
                rset.getString("cu_fmt"),
                rset.getString("und"),
                rset.getString("stock"),
                rset.getString("estado")
            });
        }
    } catch(Exception e) {
        out.println("<!-- ERR: " + e.getMessage() + " -->");
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>

<div class="card-kares">
    <div class="card-header">
        <i class="fas fa-boxes" style="font-size:11px; opacity:.85;"></i>
        <span class="card-title">Listado de Artículos</span>
        <span class="badge-count" id="totalCountBadge"><%=articulos.size()%> artículo(s)</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table id="dtArt" class="table table-kares table-hover mb-0">
                <thead>
                    <tr>
                        <th style="width:36px;">#</th>
                        <th style="width:90px;">Código</th>
                        <th>Nombre del Artículo</th>
                        <th style="width:110px; text-align:right;">Costo Unit.</th>
                        <th style="width:70px; text-align:center;">Stock</th>
                        <th style="width:80px; text-align:center;">Unidad</th>
                        <th style="width:90px; text-align:center;">Estado</th>
                        <th style="width:80px; text-align:center;">Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    int i = 0; 
                    for(String[] r : articulos) { 
                        i++; 
                        boolean on = "1".equals(r[8]);
                        String nom = r[3]; if(nom==null) nom="";
                        String nomE = nom.replace("'","\\'").replace("\"","&quot;");
                    %>
                    <tr class="<%=on ? "" : "text-muted"%>" style="<%=on ? "" : "background:#fcfcfc;"%>">
                        <td style="text-align:center; color:#a0aec0; font-size:11px;"><%=i%></td>
                        <td><span class="code"><%=r[2]%></span></td>
                        <td>
                            <span class="<%=on ? "" : "text-decoration-line-through"%>" style="font-weight:600;"><%=nom%></span>
                        </td>
                        <td class="amount">S/ <%=r[5]%></td>
                        <td style="text-align:center;">
                            <% 
                            int stockInt = 0;
                            try { stockInt = (int)Double.parseDouble(r[7]); } catch(Exception ex) {}
                            %>
                            <span class="badge <%= stockInt > 0 ? "badge-success" : "badge-danger"%>" style="font-size:10px; padding:2px 8px;">
                                <%=r[7] == null ? "0" : r[7]%>
                            </span>
                        </td>
                        <td style="text-align:center;"><span class="no-price-badge"><%=r[6]%></span></td>
                        <td style="text-align:center;">
                            <% if(on) { %>
                                <span style="color:#27ae60; font-size:11px; font-weight:700;"><i class="fas fa-check-circle mr-1"></i>Activo</span>
                            <% } else { %>
                                <span style="color:#e74c3c; font-size:11px; font-weight:700;"><i class="fas fa-times-circle mr-1"></i>Inactivo</span>
                            <% } %>
                        </td>
                        <td style="text-align:center;">
                            <div class="btn-group">
                                <a href="javascript:void(0);" onclick="loadForm('<%=r[0]%>','edit','<%=nomE%>')" 
                                   class="btn-kares mr-1" title="Editar">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="javascript:void(0);" onclick="cambioEstado('<%=r[0]%>','<%=nomE%>','<%=on?"desactivar":"activar"%>')" 
                                   class="btn btn-xs <%=on?"btn-outline-danger":"btn-outline-success"%>" style="border-radius:4px; padding:2px 6px;">
                                    <i class="fas <%=on?"fa-ban":"fa-check"%>"></i>
                                </a>
                            </div>
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
    if($.fn.DataTable.isDataTable('#dtArt')) $('#dtArt').DataTable().destroy();
    $('#dtArt').DataTable({
        language: dtES,
        pageLength: 15,
        order: [[2, 'asc']],
        columnDefs: [{ orderable: false, targets: [0, 7] }]
    });
});
</script>
