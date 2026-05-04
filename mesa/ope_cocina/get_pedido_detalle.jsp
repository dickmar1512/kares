<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file = "id.jsp" %>
<%
    String id_mov_vnt = request.getParameter("id_mov_vnt");
    StringBuilder json = new StringBuilder();
    
    if (id_mov_vnt != null && !id_mov_vnt.isEmpty()) {
        try {
            conn = getConexion();
            String sql = "SELECT a.glosa, a.cantidad, a.total, ifnull(a.estado_atencion, 0) as estado_atencion, a.id_movart " +
                         "FROM vent_regdet a " +
                         "WHERE a.id_mov_vnt = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id_mov_vnt);
            rset = pstmt.executeQuery();
            
            json.append("{\"success\": true, \"items\": [");
            int currentStatus = 0;
            boolean first = true;
            while (rset.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"glosa\": \"").append(rset.getString("glosa").replace("\"", "\\\"")).append("\",");
                json.append("\"cantidad\": \"").append(rset.getString("cantidad")).append("\",");
                json.append("\"total\": \"").append(rset.getString("total")).append("\",");
                json.append("\"estado_atencion\": \"").append(rset.getString("estado_atencion")).append("\",");
                json.append("\"id_movart\": \"").append(rset.getString("id_movart")).append("\"");
                json.append("}");
                currentStatus = rset.getInt("estado_atencion");
                first = false;
            }
            json.append("], \"currentStatus\": ").append(currentStatus);
            json.append(", \"id_mov_vnt\": \"").append(id_mov_vnt).append("\"}");
            
        } catch (Exception e) {
            json.setLength(0);
            json.append("{\"success\": false, \"message\": \"").append(e.getMessage().replace("\"", "\\\"")).append("\"}");
        } finally {
            cerrar(rset, pstmt, conn);
        }
    } else {
        json.append("{\"success\": false, \"message\": \"ID de movimiento no proporcionado\"}");
    }
    
    out.print(json.toString());
%>
