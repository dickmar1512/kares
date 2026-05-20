<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_mov_vnt = (String) xsession.getValue("id_mov_vnt");
    String url_del = "eliminar_ajax.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito · Kares</title>
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/form_venta.css?v=1.0.2">
</head>
<%
    double suma_total = 0;
    int cont_cambios = 0;
    int cont_inac    = 0;
    int i            = 0;
    String s_idm = (String) xsession.getValue("idm");
%>
<body>

<!-- ── Loader overlay ─────────────────────────────────────────── -->
<div id="loader-overlay">
    <div class="spinner-custom"></div>
    <h5>Generando Orden...</h5>
</div>

<!-- ── Panel principal ───────────────────────────────────────── -->
<div class="carrito-panel">

    <!-- Cuerpo scrollable -->
    <div class="carrito-body">

        <!-- ── Card: Nueva Orden ───────────────────────────────── -->
        <div class="card-kares-venta">
            <div class="ckv-header">
                <i class="fas fa-shopping-cart"></i>
                Nueva Orden &nbsp;·&nbsp; Mesa
                <strong><%=s_idm != null ? s_idm : "—"%></strong>
                <span class="ckv-badge" id="badge-items">0 ítem</span>
            </div>
            <div class="ckv-body">
                <form action="" method="post" name="datos" id="datos" target="venta">
                    <div class="table-responsive">
                        <table class="table-orden">
                            <thead>
                                <tr>
                                    <th style="width:28px">#</th>
                                    <th style="width:32px">Cant</th>
                                    <th>Descripción</th>
                                    <th style="width:58px;text-align:right">Tarifa</th>
                                    <th style="width:58px;text-align:right">Dscto</th>
                                    <th style="width:68px;text-align:right">Total</th>
                                    <th style="width:30px;text-align:center"></th>
                                </tr>
                            </thead>
                            <tbody id="detalle-items">
                            <%
                                Connection connDetalle = null;
                                PreparedStatement pstmtDetalle = null;
                                ResultSet rsetDetalle = null;
                                try {
                                    connDetalle = getConexion();
                                    pstmtDetalle = connDetalle.prepareStatement(
                                        "SELECT id_movart, id_articulo, glosa, round(cantidad,0) cantidad, " +
                                        "round(ifnull(valor_venta,0),2) valor_venta, round(ifnull(base_imp,0),2) total, " +
                                        "round(ifnull(descuento,0)+ifnull(descuento_esp,0),2) descuento, " +
                                        "ifnull(cambia_precio,'0') cambia_precio, estado, tipo_serv, nivel2, agregar_igv " +
                                        "FROM vent_regdet WHERE id_mov_vnt = ? ORDER BY fecha"
                                    );
                                    pstmtDetalle.setString(1, s_id_mov_vnt);
                                    rsetDetalle = pstmtDetalle.executeQuery();

                                    while(rsetDetalle.next()) {
                                        i++;
                                        double x_valor_venta = rsetDetalle.getDouble("valor_venta");
                                        double x_descuento   = rsetDetalle.getDouble("descuento");
                                        double x_total       = rsetDetalle.getDouble("total");
                                        double x_porc_desc   = (x_valor_venta > 0) ? (x_descuento / x_valor_venta) * 100 : 0;

                                        String s_tipo_servicio = rsetDetalle.getString("tipo_serv");
                                        if(s_tipo_servicio == null) s_tipo_servicio = "";

                                        String s_cambia_precio = rsetDetalle.getString("cambia_precio");
                                        String s_estado_det    = rsetDetalle.getString("estado");
                                        String s_id_movart     = rsetDetalle.getString("id_movart");
                                        String s_nivel2        = rsetDetalle.getString("nivel2");
                                        if(s_nivel2 == null) s_nivel2 = "";

                                        String rowClass = "";
                                        if (s_estado_det != null && s_estado_det.equals("X")) {
                                            cont_inac++;
                                            rowClass = "row-inac";
                                        }
                                        if (s_estado_det.equals("P")) {
                                            suma_total += x_total;
                                        }
                                        int cantInt = Integer.parseInt(rsetDetalle.getString("cantidad"));
                                        double tarifaUnit = (cantInt > 0) ? x_valor_venta / cantInt : x_valor_venta;
                            %>
                                <tr id="row-<%=s_id_movart%>" class="<%=rowClass%>">
                                    <td><span class="item-num"><%=i%></span></td>
                                    <td><span class="item-qty"><%=rsetDetalle.getString("cantidad")%></span></td>
                                    <td style="max-width:0;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;">
                                        <input name="f_glosa_<%=i%>"
                                               value="<%=rsetDetalle.getString("glosa")%>"
                                               class="input-sin-borde <%=s_tipo_servicio.equals("1") ? "text-consulta" : ""%>"
                                               readonly title="<%=rsetDetalle.getString("glosa")%>">
                                    </td>
                                    <td style="text-align:right;white-space:nowrap;font-size:11px;">
                                        <%=String.format("%.2f", tarifaUnit)%>
                                    </td>
                                    <td style="text-align:right;white-space:nowrap;">
                                        <% if (x_descuento > 0) { %>
                                            <small style="color:#2563eb;display:block;font-size:9.5px;"><%=formateador1.format(x_porc_desc)%>%</small>
                                            <span style="color:#059669;font-size:11px;font-weight:700;"><%=formateador.format(x_descuento)%></span>
                                        <% } else { %>
                                            <span style="color:#94a3b8;font-size:11px;">—</span>
                                        <% } %>
                                    </td>
                                    <td style="text-align:right;white-space:nowrap;">
                                        <% if (s_cambia_precio != null && !s_cambia_precio.equals("3")) { %>
                                            <strong style="font-size:12px;color:#1a3c6e;"><%=String.format("%.2f", x_total)%></strong>
                                        <% } else if (s_cambia_precio != null && s_cambia_precio.equals("3")) {
                                               cont_cambios++; %>
                                            <input type="number"
                                                   name="f_total_nuevo_<%=i%>"
                                                   value="<%=String.format("%.2f", x_total)%>"
                                                   class="input-monto"
                                                   step="0.01"
                                                   onKeyUp="calcular('<%=i%>')">
                                        <% } else { %>
                                            <strong style="font-size:12px;color:#1a3c6e;"><%=String.format("%.2f", x_total)%></strong>
                                        <% } %>
                                        <input type="hidden" name="f_id_movart_<%=i%>"      value="<%=s_id_movart%>">
                                        <input type="hidden" name="f_cambia_precio_<%=i%>"  value="<%=s_cambia_precio%>">
                                        <input type="hidden" name="f_total_<%=i%>"           value="<%=x_total%>">
                                        <input type="hidden" name="f_estado_det_<%=i%>"     value="<%=s_estado_det%>">
                                        <input type="hidden" name="f_tipo_servicio_<%=i%>"  value="<%=s_tipo_servicio%>">
                                        <input type="hidden" name="f_nivel2_<%=i%>"         value="<%=s_nivel2%>">
                                    </td>
                                    <td style="text-align:center;">
                                        <button type="button"
                                                class="btn-del"
                                                onclick="eliminarItem('<%=s_id_movart%>', 'row-<%=s_id_movart%>')"
                                                title="Eliminar">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch(Exception e) {
                                    System.out.println("Error form_venta: " + e.getMessage());
                                } finally {
                                    cerrar(rsetDetalle); cerrar(pstmtDetalle); cerrar(connDetalle);
                                }
                            %>
                            </tbody>
                            <% if (i > 0) { %>
                            <tfoot class="tfoot-orden">
                                <tr>
                                    <td colspan="5">
                                        <strong>Items: <span id="lbl-total-items"><%=i%></span></strong>
                                    </td>
                                    <td class="tfoot-total-val">
                                        <% if (cont_cambios > 0) { %>
                                            <input type="text" name="f_suma"
                                                   value="<%=String.format("%.2f", suma_total)%>"
                                                   class="input-monto" readonly
                                                   style="width:80px;font-weight:800;color:#1a3c6e;">
                                        <% } else { %>
                                            <span id="lbl-suma"><%=String.format("%.2f", suma_total)%></span>
                                        <% } %>
                                    </td>
                                    <td></td>
                                </tr>
                            </tfoot>
                            <% } else { %>
                            <tbody>
                                <tr>
                                    <td colspan="7">
                                        <div class="empty-cart">
                                            <i class="fas fa-shopping-basket"></i>
                                            <p>Agrega productos desde el catálogo</p>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                            <% } %>
                        </table>
                    </div>
                    <input type="hidden" name="cont_items"   value="<%=i%>">
                    <input type="hidden" name="cont_inac"    value="<%=cont_inac%>">
                    <input type="hidden" name="cont_cambios" value="<%=cont_cambios%>">
                    <input type="hidden" name="f_id_mov_vnt" value="<%=s_id_mov_vnt%>">
                </form>
            </div><!-- /ckv-body -->
        </div><!-- /card nueva orden -->

        <!-- ── Card: Órdenes Registradas ──────────────────────── -->
        <div class="card-kares-venta">
            <div class="ckv-header header-info">
                <i class="fas fa-clipboard-list"></i>
                Órdenes Registradas — Mesa <%=s_idm != null ? s_idm : "—"%>
                <span class="ckv-badge" id="badge-ordenes">cargando…</span>
            </div>
            <div class="ckv-body">
                <div class="table-responsive">
                    <table class="table-ordenes">
                        <thead>
                            <tr>
                                <th style="width:24px">#</th>
                                <th style="width:100px">Fecha</th>
                                <th style="width:60px">Orden</th>
                                <th style="width:40px;text-align:center">Cant</th>
                                <th>Descripción</th>
                                <th style="width:72px;text-align:right">Monto</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            float sumtot = 0;
                            int c = 0;
                            Connection connOrdenes = null;
                            PreparedStatement pstmtOrdenes = null;
                            ResultSet rsetOrdenes = null;
                            try {
                                connOrdenes = getConexion();
                                pstmtOrdenes = connOrdenes.prepareStatement(
                                    "SELECT b.numdoc, round(a.total,2) total, " +
                                    "date_format(a.fecha,'%d/%m/%Y %H:%i') fecha2, " +
                                    "a.glosa, a.cantidad FROM vent_regdet a, vent_registro b " +
                                    "WHERE id_mesa = ? AND a.estado = 'V' AND b.estado = 'V' " +
                                    "AND a.id_movart_relacion IS NULL AND a.estado_atencion IN('0','1','2','3') " +
                                    "AND a.id_mov_vnt = b.id_mov_vnt AND tipo_doc = '11' ORDER BY a.fecha DESC"
                                );
                                pstmtOrdenes.setString(1, s_idm);
                                rsetOrdenes = pstmtOrdenes.executeQuery();

                                while(rsetOrdenes.next()) {
                                    c++;
                                    sumtot += rsetOrdenes.getFloat("total");
                        %>
                            <tr>
                                <td><span class="item-num"><%=c%></span></td>
                                <td><small style="color:#64748b;font-size:10px;"><%=rsetOrdenes.getString("fecha2") != null ? rsetOrdenes.getString("fecha2") : ""%></small></td>
                                <td><span class="badge-orden">#<%=rsetOrdenes.getString("numdoc")%></span></td>
                                <td style="text-align:center;"><span class="badge-qty-ord"><%=rsetOrdenes.getString("cantidad")%></span></td>
                                <td style="font-size:11px;color:#1e293b;max-width:0;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;">
                                    <%=rsetOrdenes.getString("glosa")%>
                                </td>
                                <td style="text-align:right;font-size:12px;font-weight:700;color:#1a3c6e;white-space:nowrap;">
                                    S/ <%=String.format("%.2f", rsetOrdenes.getFloat("total"))%>
                                </td>
                            </tr>
                        <%
                                }
                            } catch(Exception e) {
                                System.out.println("Error ordenes: " + e.getMessage());
                            } finally {
                                cerrar(rsetOrdenes); cerrar(pstmtOrdenes); cerrar(connOrdenes);
                            }
                            if (c == 0) {
                        %>
                            <tr>
                                <td colspan="6">
                                    <div class="empty-cart">
                                        <i class="fas fa-receipt"></i>
                                        <p>No hay órdenes activas para esta mesa</p>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                        <% if (c > 0) { %>
                        <tfoot>
                            <tr>
                                <td colspan="5" style="text-align:right;">Total Acumulado:</td>
                                <td style="text-align:right;font-size:12px;font-weight:800;color:#1a3c6e;white-space:nowrap;">
                                    S/ <%=String.format("%.2f", sumtot)%>
                                </td>
                            </tr>
                        </tfoot>
                        <% } %>
                    </table>
                </div>
            </div>
        </div><!-- /card órdenes -->

    </div><!-- /carrito-body -->

    <!-- ── Footer sticky: total + botón generar ───────────────── -->
    <div class="carrito-footer" id="carrito-footer-bar" <%=i == 0 ? "style=\"display:none\"" : ""%>>
        <div>
            <div class="footer-total-label">Total orden</div>
            <div class="footer-total-val">
                <span class="footer-currency">S/</span>
                <span id="footer-total-val"><%=String.format("%.2f", suma_total)%></span>
            </div>
        </div>
        <button type="button"
                id="btn-generar-orden"
                class="btn-generar"
                onclick="generarOrden()">
            <i class="fas fa-check-circle"></i> Generar Orden
        </button>
    </div>

</div><!-- /carrito-panel -->

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
    /* Inicializar badge de items */
    (function() {
        const badge = document.getElementById('badge-items');
        const n = <%=i%>;
        if (badge) badge.textContent = n + ' ítem' + (n !== 1 ? 's' : '');

        const badgeOrd = document.getElementById('badge-ordenes');
        const c = <%=c%>;
        if (badgeOrd) badgeOrd.textContent = c + ' orden' + (c !== 1 ? 'es' : '');
    })();
</script>
<script src="../../assets/js/mesa/ope_venta/form_venta.js"></script>
</body>
</html>