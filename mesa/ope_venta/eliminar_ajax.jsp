<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String s_id_movart	= request.getParameter("f_id_movart");
	
    org.json.JSONObject jsonResponse = new org.json.JSONObject();
    
    try {
        
        if(s_id_movart == null || s_id_movart.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "s_id_movart no puede ser null");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Eliminar000
        COMANDO = "DELETE FROM vent_regdet WHERE id_movart = ? AND estado = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_movart);
        pstmt.setString(2, "P");
        
        int resultado = pstmt.executeUpdate();
        
        if(resultado > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Se elimino el articulo correctamente");
            
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error al eliminar el articulo");
        }
        
    } catch(Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if(rset != null) try { rset.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
    out.print(jsonResponse.toString());
%>