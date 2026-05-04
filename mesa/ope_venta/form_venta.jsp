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
    <title>Registro de Ventas</title>
    
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/ionicons/css/ionicons.min.css">    
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/form_venta.css">
    
    <script>
        
    </script>
</head>

<%  
    double suma_total = 0;
    int cont_cambios = 0;
    int cont_inac = 0;
    int i = 0;
    String s_idm = (String) xsession.getValue("idm");
%>

<body class="hold-transition sidebar-mini layout-fixed"><br>
<div id="loader-overlay">
    <div class="spinner-custom"></div>
    <h5 class="mt-3 text-success">Generando Orden...</h5>
</div>
<div class="wrapper">
    <div class="content-wrapper" style="margin-left: 0;">
        <section class="content">
            <div class="container-fluid">
                
                <div class="card card-primary card-outline">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="fas fa-shopping-cart"></i> Detalles de nueva orden - Mesa Nro: 
                            <span class="badge badge-info"><%=s_idm != null ? s_idm : ""%></span>
                        </h3>
                    </div>
                    
                    <form action="" method="post" name="datos" id="datos" target="venta">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-sm table-hover table-bordered table-striped mb-0">
                                <thead class="thead-light">
                                    <tr>
                                        <th width="40">#</th>
                                        <th width="60">Cant.</th>
                                        <th>Descripción</th>
                                        <th width="100">Tarifa</th>               
                                        <th width="100">Descuento</th>
                                        <th width="120">Total</th>                   
                                        <th width="60">Acción</th>
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
                                            "ifnull(cambia_precio, '0') cambia_precio, estado, tipo_serv, nivel2, agregar_igv " +
                                            "FROM vent_regdet WHERE id_mov_vnt = ? ORDER BY fecha"
                                        );
                                        pstmtDetalle.setString(1, s_id_mov_vnt);
                                        rsetDetalle = pstmtDetalle.executeQuery();
                                        
                                        while(rsetDetalle.next()) {
                                            i++;
                                            double x_valor_venta = rsetDetalle.getDouble("valor_venta");
                                            double x_descuento = rsetDetalle.getDouble("descuento");
                                            double x_total = rsetDetalle.getDouble("total");
                                            double x_porc_desc = (x_valor_venta > 0) ? (x_descuento / x_valor_venta) * 100 : 0;
                                            
                                            String s_tipo_servicio = rsetDetalle.getString("tipo_serv");
                                            if(s_tipo_servicio == null) s_tipo_servicio = "";
                                            
                                            String s_cambia_precio = rsetDetalle.getString("cambia_precio");
                                            String s_estado_det = rsetDetalle.getString("estado");
                                            String s_id_movart = rsetDetalle.getString("id_movart");
                                            String s_nivel2 = rsetDetalle.getString("nivel2");
                                            if(s_nivel2 == null) s_nivel2 = "";
                                            
                                            String rowClass = "";
                                            if (s_estado_det != null && s_estado_det.equals("X")) { 
                                                cont_inac++; 
                                                rowClass = "text-muted bg-light";
                                            }
                                            
                                            if (s_estado_det.equals("P")) {
                                                suma_total += x_total;
                                            }
                                %>
                                    <tr id="row-<%=s_id_movart%>">
                                        <td class="text-center"><span class="badge badge-secondary"><%=i%></span></td>
                                        <td class="text-center"><span class="badge badge-primary"><%=rsetDetalle.getString("cantidad")%></span></td>
                                        <td>
                                            <input name="f_glosa_<%=i%>" value="<%=rsetDetalle.getString("glosa")%>" 
                                                   class="input-sin-borde <%=s_tipo_servicio.equals("1") ? "text-consulta" : "text-normal"%>" readonly>
                                        </td>
                                        <td class="text-right"><%=String.format("%.2f", (x_valor_venta / Integer.parseInt(rsetDetalle.getString("cantidad"))))%></td>
                                        <td class="text-right">
                                            <% if (x_descuento > 0) { %>
                                                <small class="text-info d-block"><%=formateador1.format(x_porc_desc)%>%</small>
                                                <span class="text-success"><%=formateador.format(x_descuento)%></span>
                                            <% } else { %>
                                                <span class="text-muted">-</span>
                                            <% } %>
                                        </td>
                                        <td class="text-right">
                                            <% if (s_cambia_precio != null && !s_cambia_precio.equals("3")) { %>
                                                <strong><%=String.format("%.2f", x_total)%></strong>
                                            <% } else if (s_cambia_precio != null && s_cambia_precio.equals("3")) {
                                                cont_cambios++; %>
                                                <div class="input-group input-group-sm">
                                                    <div class="input-group-prepend"><span class="input-group-text"> </span></div>
                                                    <input type="number" name="f_total_nuevo_<%=i%>" value="<%=String.format("%.2f", x_total)%>" 
                                                           class="form-control form-control-sm text-right" step="0.01" onKeyUp="calcular('<%=i%>')">
                                                </div>
                                            <% } else { %>
                                                <strong><%=String.format("%.2f", x_total)%></strong>
                                            <% } %>
                                            <input type="hidden" name="f_id_movart_<%=i%>" value="<%=s_id_movart%>">
                                            <input type="hidden" name="f_cambia_precio_<%=i%>" value="<%=s_cambia_precio%>">
                                            <input type="hidden" name="f_total_<%=i%>" value="<%=x_total%>">
                                            <input type="hidden" name="f_estado_det_<%=i%>" value="<%=s_estado_det%>">
                                            <input type="hidden" name="f_tipo_servicio_<%=i%>" value="<%=s_tipo_servicio%>">
                                            <input type="hidden" name="f_nivel2_<%=i%>" value="<%=s_nivel2%>">
                                        </td>
                                        <td class="text-center">
                                            <button type="button" class="btn btn-danger btn-xs" onclick="eliminarItem('<%=s_id_movart%>', 'row-<%=s_id_movart%>')">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                <%
                                        }
                                    } catch(Exception e) {
                                        System.out.println("Error: " + e.getMessage());
                                    } finally {
                                        cerrar(rsetDetalle);
                                        cerrar(pstmtDetalle);
                                        cerrar(connDetalle);
                                    }
                                %>
                                </tbody>
                                <% if (i > 0) { %>
                                <tfoot class="bg-light">
                                    <tr class="total-row">
                                        <td colspan="5"><strong>Total Items: <span class="badge badge-info"><%=i%></span></strong></td>
                                        <td class="text-right">
                                            <% if (cont_cambios > 0) { %>   
                                                <div class="input-group input-group-sm">
                                                    <div class="input-group-prepend"><span class="input-group-text"> </span></div>
                                                    <input type="text" name="f_suma" value="<%=String.format("%.2f", suma_total)%>" 
                                                           class="form-control form-control-sm text-right font-weight-bold text-primary" readonly>
                                                </div>
                                            <% } else { %>
                                                <strong class="text-primary"> <%=String.format("%.2f", suma_total)%></strong>
                                            <% } %>
                                        </td>
                                        <td></td>
                                    </tr>
                                </tfoot>
                                <% } %>
                            </table>
                        </div>
                    </div>
                    
                    <div class="card-footer">
                        <% if (i > 0) { %>
                            <button type="button" id="btn-generar-orden" class="btn btn-success btn-sm" onClick="generarOrden()">
                                <i class="fas fa-check-circle"></i> Generar Nueva Orden 
                            </button>
                        <% } %>
                    </div>
                    
                    <input type="hidden" name="cont_items" value="<%=i%>">
                    <input type="hidden" name="cont_inac" value="<%=cont_inac%>">
                    <input type="hidden" name="cont_cambios" value="<%=cont_cambios%>">
                    <input type="hidden" name="f_id_mov_vnt" value="<%=s_id_mov_vnt%>">
                    </form>
                </div>
                
                <div class="card card-info card-outline">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-list-alt"></i> Órdenes Registradas</h3>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-sm table-hover table-striped mb-0">
                                <thead class="bg-info">
                                    <tr>
                                        <th width="40">#</th>
                                        <th>Fecha</th>
                                        <th>Orden</th>
                                        <th>Cant.</th>                                      
                                        <th>Descripción</th>
                                        <th class="text-right">Monto</th>
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
                                            "SELECT b.numdoc, round(a.total,2) total, date_format(a.fecha,'%d/%m/%Y %r') fecha2, " +
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
                                        <td class="text-center"><span class="badge badge-secondary"><%=c%></span></td>
                                        <td><small><%=rsetOrdenes.getString("fecha2") != null ? rsetOrdenes.getString("fecha2") : ""%></small></td>
                                        <td><span class="badge badge-primary">#<%=rsetOrdenes.getString("numdoc")%></span></td>
                                        <td><span class="badge badge-info"><%=rsetOrdenes.getString("cantidad")%></span></td>
                                        <td><%=rsetOrdenes.getString("glosa")%></td>
                                        <td class="text-right"><strong>S/ <%=String.format("%.2f", rsetOrdenes.getFloat("total"))%></strong></td>
                                    </tr>
                                <%
                                        }
                                    } catch(Exception e) {
                                        System.out.println("Error: " + e.getMessage());
                                    } finally {
                                        cerrar(rsetOrdenes);
                                        cerrar(pstmtOrdenes);
                                        cerrar(connOrdenes);
                                    }
                                %>
                                </tbody>
                                <% if (c > 0) { %>
                                <tfoot class="bg-light">
                                    <tr class="font-weight-bold">
                                        <td colspan="5" class="text-right">Total General:</td>
                                        <td class="text-right text-primary">S/ <%=String.format("%.2f", sumtot)%></td>
                                    </tr>
                                </tfoot>
                                <% } %>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script src="../../assets/js/mesa/ope_venta/form_venta.js"></script>
</body>
</html>