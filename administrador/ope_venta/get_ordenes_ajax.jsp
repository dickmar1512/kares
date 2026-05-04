<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    String s_idm = request.getParameter("idm");
    StringBuilder json = new StringBuilder();

    if (s_idm == null || s_idm.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Mesa no especificada\"}");
        return;
    }

    try {
        conn = getConexion();
        pstmt = conn.prepareStatement("CALL sp_kar_listar_ordenes_mesa(?)");
        pstmt.setString(1, s_idm);
        rset = pstmt.executeQuery();

        json.append("{\"success\":true,\"items\":[");
        boolean first = true;
        while (rset.next()) {
            if (!first) json.append(",");
            json.append("{");
            json.append("\"id_movart\":\"").append(rset.getString("id_movart")).append("\",");
            json.append("\"id_mov_vnt\":\"").append(rset.getString("id_mov_vnt")).append("\",");
            json.append("\"fecha2\":\"").append(rset.getString("fecha2") != null ? rset.getString("fecha2").replace("\"","\\\"") : "").append("\",");
            json.append("\"band\":\"").append(rset.getString("band")).append("\",");
            json.append("\"serie\":\"").append(rset.getString("serie") != null ? rset.getString("serie") : "").append("\",");
            json.append("\"numdoc\":\"").append(rset.getString("numdoc") != null ? rset.getString("numdoc") : "").append("\",");
            json.append("\"cantidad\":\"").append(rset.getString("cantidad")).append("\",");
            json.append("\"glosa\":\"").append(rset.getString("glosa") != null ? rset.getString("glosa").replace("\"","\\\"") : "").append("\",");
            json.append("\"total\":\"").append(rset.getString("total")).append("\"");
            json.append("}");
            first = false;
        }
        json.append("]}");
    } catch (Exception e) {
        json.setLength(0);
        json.append("{\"success\":false,\"message\":\"").append(e.getMessage() != null ? e.getMessage().replace("\"","\\\"") : "Error").append("\"}");
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print(json.toString());
%>
