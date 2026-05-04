<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file= "../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    String s_fecha      = request.getParameter("f_fecha_ini"); if(s_fecha == null) s_fecha = fecha;
    String s_hora       = "";
    String s_fecha_emi  = "";
    String s_caja       = "";
    String x_fecha_ini  = s_fecha.substring(6,10) + s_fecha.substring(3,5) + s_fecha.substring(0,2);

    double c_importe    = 0;
    double t_importe    = 0;
    int    contador     = 0;

    try {
        COMANDO = "Select time_format(sysdate(),'%H:%i') hora, " +
                  "date_format(sysdate(),'%d/%m/%Y') fecha_emi from dual";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        if(rset.next()) {
            s_hora      = rset.getString("hora");
            s_fecha_emi = rset.getString("fecha_emi");
        }
    } catch(Exception e) {
        s_hora = "--"; s_fecha_emi = "--";
    } finally {
        cerrar(rset, pstmt, conn);
    }

    java.util.List<String[]> rows = new java.util.ArrayList<>();
    try {
        COMANDO = "Select " +
                  "punto, " +
                  "concat(nom_punto(punto),' — ',punto) caja, " +
                  "tipo_doc, " +
                  "nom_doc(tipo_doc) nom_doc, " +
                  "nombre(id_personal_user) usuario, " +
                  "format(sum(total),2) ximporte, " +
                  "sum(total) ximporte_num " +
                  "from vent_registro " +
                  "where punto = ? " +
                  "and date_format(fecha,'%Y%m%d') = ? " +
                  "and tipo_doc not in('07','11') " +
                  "and estado = 'V' " +
                  "group by usuario, tipo_doc, punto " +
                  "order by usuario, punto, caja, nom_doc";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, x_fecha_ini);
        rset  = pstmt.executeQuery();
        while(rset.next()) {
            rows.add(new String[]{
                rset.getString("caja"),
                rset.getString("usuario"),
                rset.getString("nom_doc"),
                rset.getString("ximporte"),
                rset.getString("ximporte_num"),
                rset.getString("tipo_doc")
            });
        }
    } catch(Exception e) {
        rows = null;
    } finally {
        cerrar(rset, pstmt, conn);
    }

    java.util.LinkedHashMap<String, Double> subtotales = new java.util.LinkedHashMap<>();
    if(rows != null) {
        for(String[] r : rows) {
            String k = r[0];
            double v = Double.parseDouble(r[4]);
            subtotales.put(k, subtotales.getOrDefault(k, 0.0) + v);
            t_importe += v;
        }
    }
    int totalRegistros = (rows != null) ? rows.size() : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arqueo Diario — <%=s_fecha%></title>

    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/administrador/rep_arqueo_dia/detalle.css">
</head>
<body>
<div class="arqueo-wrapper">
    <div class="results-header">
        <i class="fas fa-cash-register"></i>
        <span class="rh-title">Arqueo de Caja — <span style="font-weight:400; color:#b8cfef;"><%=s_fecha%></span></span>
        <div class="rh-meta">
            <span class="badge-pill-custom"><%=totalRegistros%> movimiento(s)</span>
            <button class="btn-print" onclick="window.print()"><i class="fas fa-print"></i> Imprimir</button>
        </div>
    </div>

    <div class="meta-bar">
        <div class="meta-item"><i class="fas fa-store"></i><strong><%=s_punto%></strong></div>
        <div class="meta-item"><i class="fas fa-calendar-day"></i><strong><%=s_fecha%></strong></div>
        <div class="meta-item"><i class="far fa-clock"></i><strong><%=s_fecha_emi%> <%=s_hora%></strong></div>
        <div class="meta-item"><i class="fas fa-user-circle"></i><strong><%=s_login%></strong></div>
    </div>

    <div class="arqueo-body">
        <%
            int nCajas = subtotales.size();
            String totalFmt = String.format("%,.2f", t_importe);
            String promFmt  = nCajas > 0 ? String.format("%,.2f", t_importe / nCajas) : "0.00";
        %>
        <div class="summary-grid">
            <div class="stat-card accent">
                <div class="sc-label">Total General</div>
                <div class="sc-value"><span class="sc-prefix">S/</span> <%=totalFmt%></div>
            </div>
            <div class="stat-card success-card">
                <div class="sc-label">Puntos de Venta</div>
                <div class="sc-value"><%=nCajas%></div>
            </div>
            <div class="stat-card">
                <div class="sc-label">Movimientos</div>
                <div class="sc-value"><%=totalRegistros%></div>
            </div>
            <div class="stat-card">
                <div class="sc-label">Promedio / Caja</div>
                <div class="sc-value"><span class="sc-prefix">S/</span> <%=promFmt%></div>
            </div>
        </div>

        <% if(rows == null || rows.isEmpty()) { %>
            <div class="section-card"><div class="p-4 text-center text-muted">No se registraron ingresos de caja.</div></div>
        <% } else {
            String cajaActual = "";
            boolean primera   = true;
            int filaIdx       = 0;

            for(int i = 0; i < rows.size(); i++) {
                String[] r      = rows.get(i);
                if(!r[0].equals(cajaActual)) {
                    if(!primera) out.print("</tbody></table></div></div>");
                    cajaActual = r[0]; primera = false; filaIdx = 0;
                    String subFmt = String.format("%,.2f", subtotales.get(cajaActual));
        %>
            <div class="section-card">
                <div class="section-header">
                    <div class="section-icon"><i class="fas fa-store-alt"></i></div>
                    <span class="section-title"><%=cajaActual%></span>
                    <div class="section-subtotal"><span class="pfx">S/</span> <%=subFmt%></div>
                </div>
                <div class="table-responsive">
                    <table class="table table-kares table-hover mb-0">
                        <thead>
                            <tr><th width="40">#</th><th>Cajero</th><th>Documento</th><th class="text-right">Importe</th></tr>
                        </thead>
                        <tbody>
        <%      } filaIdx++; %>
                            <tr>
                                <td class="text-center text-muted"><%=filaIdx%></td>
                                <td><span class="user-badge"><i class="fas fa-user-circle"></i> <%=r[1]%></span></td>
                                <td><span class="doc-badge"><%=r[2]%></span></td>
                                <td class="importe-cell"><span class="pfx">S/</span> <%=r[3]%></td>
                            </tr>
        <%  } out.print("</tbody></table></div></div>"); } %>
    </div>

    <div class="arqueo-footer">
        <div class="footer-meta"><%=totalRegistros%> movimiento(s) &bull; <%=s_fecha_emi%> <%=s_hora%></div>
        <div class="total-general">
            <span class="tg-label">Total General:</span>
            <span class="tg-amount"><span class="tg-prefix">S/</span> <%=totalFmt%></span>
        </div>
    </div>
</div>
</body>
</html>