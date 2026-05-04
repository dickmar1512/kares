<%@page contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    /* ── Parámetros de entrada ─────────────────────────────── */
    String s_tipo_doc  = request.getParameter("f_tipo_doc");  if(s_tipo_doc  == null) s_tipo_doc  = "00";
    String s_fecha_ini = request.getParameter("f_fecha_ini"); if(s_fecha_ini == null) s_fecha_ini = fecha;
    String s_fecha_fin = request.getParameter("f_fecha_fin"); if(s_fecha_fin == null) s_fecha_fin = s_fecha_ini;
    String s_id_caja   = request.getParameter("f_id_caja");   if(s_id_caja   == null) s_id_caja   = "";
    String s_id_user   = request.getParameter("f_id_personal_user"); if(s_id_user == null) s_id_user = "T";

    /* ── Períodos en formato YYYYMMDD para comparación ─────── */
    String s_periodo1  = s_fecha_ini.substring(6,10) + s_fecha_ini.substring(3,5) + s_fecha_ini.substring(0,2);
    String s_periodo2  = s_fecha_fin.substring(6,10) + s_fecha_fin.substring(3,5) + s_fecha_fin.substring(0,2);

    String s_modo      = "1";
    String s_doc       = "TODOS LOS DOCUMENTOS";
    String s_caja      = "";
    String s_fecha_emi = "";
    String s_hora      = "";
    int    contador    = 0;
    double dblTotal    = 0;
    double dblIgv      = 0;
    double dblBase     = 0;

    /* ── Nombre del archivo de exportación ─────────────────── */
    response.setHeader("Content-Disposition",
        "attachment; filename=\"Ventas_" + s_fecha_ini.replace("/","") + ".xls\"");

    /* ── Determinar punto/caja del usuario ─────────────────── */
    if(!id_nivel_user.equals("0")) {
        try {
            COMANDO = "Select punto from areas_usuarios where id_personal = ?";
            conn  = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id_personal_user);
            rset  = pstmt.executeQuery();
            if(rset.next()) {
                s_punto = rset.getString("punto");
                if(s_punto.equals("0")) s_punto = "01";
            }
        } catch(Exception ex) {
            out.println("<!-- Error punto: " + ex.getMessage() + " -->");
        } finally {
            cerrar(rset, pstmt, conn);
        }
    } else {
        if(s_id_caja == null || s_id_caja.isEmpty()) s_id_caja = s_punto;
    }

    /* ── Nombre del tipo de documento ──────────────────────── */
    if(!s_tipo_doc.equals("00")) {
        try {
            COMANDO = "Select upper(nombre) nombre from cont_tipo_doc where tipo_doc = ?";
            conn  = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_tipo_doc);
            rset  = pstmt.executeQuery();
            if(rset.next()) s_doc = rset.getString("nombre");
        } catch(Exception ex) {
            out.println("<!-- Error tipo_doc: " + ex.getMessage() + " -->");
        } finally {
            cerrar(rset, pstmt, conn);
        }
    }

    /* ── Nombre del punto de venta + fecha emisión ──────────── */
    try {
        COMANDO = "Select upper(nombre) caja, " +
                  "date_format(sysdate(),'%d/%m/%Y') fecha_emi, " +
                  "time_format(sysdate(),'%T') hora " +
                  "from puntos where punto = ?";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_nivel_user.equals("0") ? s_id_caja : s_punto);
        rset  = pstmt.executeQuery();
        if(rset.next()) {
            s_caja      = rset.getString("caja");
            s_fecha_emi = rset.getString("fecha_emi");
            s_hora      = rset.getString("hora");
        }
    } catch(Exception ex) {
        out.println("<!-- Error caja: " + ex.getMessage() + " -->");
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<style>
    body  { font-family: Arial, sans-serif; font-size: 11px; }
    table { border-collapse: collapse; width: 100%; }
    th    { background: #1a3c6e; color: #fff; padding: 5px 8px;
            font-size: 10px; text-align: center; border: 1px solid #ccc; }
    td    { padding: 4px 7px; border: 1px solid #ddd; font-size: 11px; vertical-align: middle; }
    tr:nth-child(even) td { background: #f5f8fc; }
    .title-row td  { background: #1a3c6e; color: #fff; font-weight: bold;
                     font-size: 13px; text-align: center; border: 1px solid #1a3c6e; }
    .sub-row td    { background: #eef1f7; font-size: 11px; text-align: center;
                     border: 1px solid #ccc; }
    .total-row td  { background: #1a3c6e; color: #fff; font-weight: bold;
                     text-align: right; border: 1px solid #1a3c6e; }
    .anulado td    { color: #c0392b; text-decoration: line-through; }
    .right         { text-align: right; }
    .center        { text-align: center; }
    .mono          { font-family: 'Courier New', monospace; font-size: 10.5px; }
</style>
</head>
<body>
<table>
    <!-- ══ Encabezado del reporte ══════════════════════════════ -->
    <tr>
        <td class="title-row" colspan="10">
            <%=s_caja%> &mdash; REPORTE DE VENTAS: <%=s_doc%>
        </td>
    </tr>
    <tr>
        <td class="sub-row" colspan="10">
            Período: <%=s_fecha_ini%>
            <% if(!s_fecha_fin.equals(s_fecha_ini)){ %> al <%=s_fecha_fin%><% } %>
            &nbsp;&nbsp;|&nbsp;&nbsp;
            Emisión: <%=s_fecha_emi%> <%=s_hora%>
            &nbsp;&nbsp;|&nbsp;&nbsp;
            Usuario: <%=s_login%>
        </td>
    </tr>
    <!-- ══ Cabecera de columnas ════════════════════════════════ -->
    <tr>
        <th style="width:35px;">#</th>
        <th style="width:150px;">Comprobante</th>
        <th>Cliente</th>
        <th style="width:110px;">RUC / DNI</th>
        <th style="width:90px;">Fecha</th>
        <th style="width:90px;">Val. Venta</th>
        <th style="width:80px;">Descuento</th>
        <th style="width:80px;">IGV</th>
        <th style="width:90px;">Total</th>
        <th style="width:110px;">Cajero</th>
    </tr>
<%
    /* ── Query principal ──────────────────────────────────────── */
    StringBuilder sb = new StringBuilder();
    sb.append("Select tipo_doc, ")
      .append("nom_doc3(tipo_doc) pref, ")
      .append("lpad(b.numdoc,8,'0') numdoc, ")
      .append("b.estado, ")
      .append("(case when b.tipo_doc='39' then razon else nombre(b.id_personal) end) nombre, ")
      .append("(case when b.tipo_doc='39' then ruc   else dni(b.id_personal)    end) docpersona, ")
      .append("(case when b.estado='A' then 0 else ifnull(b.valor_venta,0) end) valor_venta, ")
      .append("(case when b.estado='A' then 0 else ifnull(b.descuento,0)   end) descuento, ")
      .append("(case when b.estado='A' then 0 else ifnull(b.igv,0)         end) igv_col, ")
      .append("(case when b.estado='A' then 0 else ifnull(b.total,0)       end) total_col, ")
      .append("date_format(b.fecha,'%d/%m/%Y') fecemi, ")
      .append("lower(login(b.id_personal_user)) cajero ")
      .append("from vent_registro b where ");

    if(s_fecha_fin.equals(s_fecha_ini)) {
        sb.append("date_format(b.fecha,'%d/%m/%Y') = ? ");
    } else {
        sb.append("date_format(b.fecha,'%Y%m%d') >= ? ")
          .append("and date_format(b.fecha,'%Y%m%d') <= ? ");
    }

    if(id_nivel_user.equals("0")) {
        sb.append("and b.punto = ? ");
    } else {
        sb.append("and b.punto in(?) ");
    }
    if(!s_tipo_doc.equals("00")) {
        sb.append("and b.tipo_doc = ? ");
    }
    if(!s_id_user.equals("T")) {
        sb.append("and b.id_personal_user = ? ");
    }
    sb.append("and b.estado in('A','V') ")
      .append("and b.tipo_doc in('34','35','26','41','39') ")
      .append("and b.modo = '").append(s_modo).append("' ")
      .append("order by b.numdoc");

    try {
        conn  = getConexion();
        pstmt = conn.prepareStatement(sb.toString());
        int pi = 1;
        if(s_fecha_fin.equals(s_fecha_ini)) {
            pstmt.setString(pi++, s_fecha_ini);
        } else {
            pstmt.setString(pi++, s_periodo1);
            pstmt.setString(pi++, s_periodo2);
        }
        pstmt.setString(pi++, id_nivel_user.equals("0") ? s_id_caja : s_punto);
        if(!s_tipo_doc.equals("00")) pstmt.setString(pi++, s_tipo_doc);
        if(!s_id_user.equals("T"))   pstmt.setString(pi++, s_id_user);

        rset = pstmt.executeQuery();
        while(rset.next()) {
            contador++;
            String estado     = rset.getString("estado");
            String trClass    = estado.equals("A") ? " class=\"anulado\"" : "";
            double vVenta     = rset.getDouble("valor_venta");
            double vDesc      = rset.getDouble("descuento");
            double vIgv       = rset.getDouble("igv_col");
            double vTotal     = rset.getDouble("total_col");
            if(!estado.equals("A")) {
                dblBase  += vVenta;
                dblIgv   += vIgv;
                dblTotal += vTotal;
            }
%>
    <tr<%=trClass%>>
        <td class="center"><%=contador%></td>
        <td class="center mono">
            <%=rset.getString("pref").trim()%>&nbsp;<%=rset.getString("numdoc").trim()%>
            <% if(estado.equals("A")){ %><br><span style="color:#c0392b;font-size:9px;font-weight:bold;">ANULADO</span><% } %>
        </td>
        <td><%=rset.getString("nombre")%></td>
        <td class="center mono"><%=rset.getString("docpersona")%></td>
        <td class="center"><%=rset.getString("fecemi").trim()%></td>
        <td class="right"><%=String.format("%,.2f", vVenta)%></td>
        <td class="right"><%=String.format("%,.2f", vDesc)%></td>
        <td class="right"><%=String.format("%,.2f", vIgv)%></td>
        <td class="right" style="font-weight:bold;"><%=String.format("%,.2f", vTotal)%></td>
        <td class="center"><%=rset.getString("cajero")%></td>
    </tr>
<%
        }
    } catch(Exception ex) {
        out.println("<tr><td colspan='10' style='color:red;padding:10px;'>Error al obtener datos: " + ex.getMessage() + "</td></tr>");
    } finally {
        cerrar(rset, pstmt, conn);
    }

    if(contador == 0) {
%>
    <tr>
        <td colspan="10" style="text-align:center; padding:20px; color:#888; font-style:italic;">
            No se encontraron registros para el período y filtros seleccionados.
        </td>
    </tr>
<%  } %>

    <!-- ══ Fila de totales ═══════════════════════════════════════ -->
    <tr class="total-row">
        <td colspan="5" style="text-align:right;">
            TOTAL VIGENTES &mdash; <%=contador%> documento(s):
        </td>
        <td class="right"><%=String.format("%,.2f", dblBase)%></td>
        <td class="right">&mdash;</td>
        <td class="right"><%=String.format("%,.2f", dblIgv)%></td>
        <td class="right"><%=String.format("%,.2f", dblTotal)%></td>
        <td></td>
    </tr>
</table>
</body>
</html>