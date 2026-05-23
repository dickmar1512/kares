<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String s_id_mov_vnt = request.getParameter("id_mov_vnt");

    if (s_id_mov_vnt == null || s_id_mov_vnt.trim().isEmpty()) {
        out.print("{\"ok\":false,\"msg\":\"Falta el parámetro id_mov_vnt.\"}");
        return;
    }

    StringBuilder sb = new StringBuilder();
    sb.append("{\"ok\":true,\"items\":[");

    int totalItems = 0;
    int canjeados = 0;
    int pendientes = 0;

    try {
        conn = getConexion();

        String sql = "SELECT d.id_movart, d.glosa, d.cantidad, " +
                     "ROUND(d.valor_venta, 2) AS valor_venta, " +
                     "ROUND(d.base_imp, 2) AS base_imp, " +
                     "ROUND(d.igv, 2) AS igv, " +
                     "ROUND(d.total, 2) AS total, " +
                     "ROUND(IFNULL(d.descuento, 0), 2) AS descuento, " +
                     "ROUND(IFNULL(d.descuento_esp, 0), 2) AS descuento_esp, " +
                     "ROUND(IFNULL(d.cobertura, 0), 2) AS cobertura, " +
                     "ROUND(IFNULL(d.copago, 0), 2) AS copago, " +
                     "IFNULL(d.det_transf, '') AS det_transf, " +
                     "d.orden, d.precio_unitario, d.porc_igv " +
                     "FROM vent_regdet d " +
                     "WHERE d.id_mov_vnt = ? AND d.estado <> 'X' " +
                     "ORDER BY d.orden";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, s_id_mov_vnt);
        rset = pstmt.executeQuery();

        boolean first = true;
        while (rset.next()) {
            totalItems++;
            String detTransf = rset.getString("det_transf");
            boolean esCanjeado = (detTransf != null && !detTransf.trim().isEmpty());

            if (esCanjeado) {
                canjeados++;
            } else {
                pendientes++;
            }

            if (!first) sb.append(",");
            first = false;

            String glosa = rset.getString("glosa");
            if (glosa == null) glosa = "";
            glosa = glosa.replace("\\", "\\\\").replace("\"", "\\\"");

            sb.append("{");
            sb.append("\"id_movart\":\"").append(rset.getString("id_movart")).append("\",");
            sb.append("\"glosa\":\"").append(glosa).append("\",");
            sb.append("\"cantidad\":\"").append(rset.getString("cantidad")).append("\",");
            sb.append("\"valor_venta\":").append(rset.getDouble("valor_venta")).append(",");
            sb.append("\"base_imp\":").append(rset.getDouble("base_imp")).append(",");
            sb.append("\"igv\":").append(rset.getDouble("igv")).append(",");
            sb.append("\"total\":").append(rset.getDouble("total")).append(",");
            sb.append("\"descuento\":").append(rset.getDouble("descuento")).append(",");
            sb.append("\"descuento_esp\":").append(rset.getDouble("descuento_esp")).append(",");
            sb.append("\"cobertura\":").append(rset.getDouble("cobertura")).append(",");
            sb.append("\"copago\":").append(rset.getDouble("copago")).append(",");
            sb.append("\"canjeado\":").append(esCanjeado).append(",");
            sb.append("\"precio_unitario\":").append(rset.getDouble("precio_unitario")).append(",");
            sb.append("\"porc_igv\":").append(rset.getDouble("porc_igv"));
            sb.append("}");
        }

    } catch (Exception e) {
        out.print("{\"ok\":false,\"msg\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        return;
    } finally {
        cerrar(rset, pstmt, conn);
    }

    sb.append("],");
    sb.append("\"total_items\":").append(totalItems).append(",");
    sb.append("\"canjeados\":").append(canjeados).append(",");
    sb.append("\"pendientes\":").append(pendientes);
    sb.append("}");

    out.print(sb.toString());
%>
