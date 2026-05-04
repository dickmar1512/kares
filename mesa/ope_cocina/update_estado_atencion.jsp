<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file = "id.jsp" %>
<%
    String id_movart = request.getParameter("id_movart");
    String id_mov_vnt = request.getParameter("id_mov_vnt");
    String estado = request.getParameter("estado");
    StringBuilder json = new StringBuilder();
    
    if (estado != null && (id_movart != null || id_mov_vnt != null)) {
        try {
            conn = getConexion();
            String sql = "";
            String param = "";
            
            if (id_movart != null) {
                sql = "UPDATE vent_regdet SET estado_atencion = ? WHERE id_movart = ?";
                param = id_movart;
            } else {
                sql = "UPDATE vent_regdet SET estado_atencion = ? WHERE id_mov_vnt = ?";
                param = id_mov_vnt;
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, estado);
            pstmt.setString(2, param);
            int rows = pstmt.executeUpdate();
            
            json.append("{\"success\": true, \"message\": \"Actualización exitosa\", \"rows\": ").append(rows).append("}");
        } catch (Exception e) {
            json.append("{\"success\": false, \"message\": \"").append(e.getMessage().replace("\"", "\\\"")).append("\"}");
        } finally {
            cerrar(null, null, conn);
        }
    } else {
        json.append("{\"success\": false, \"message\": \"Parámetros insuficientes\"}");
    }
    
    out.print(json.toString());
%>
