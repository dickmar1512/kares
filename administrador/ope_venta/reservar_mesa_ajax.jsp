<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();
    
    String idm = request.getParameter("idm");
    String cliente = request.getParameter("cliente");

    if (idm == null || idm.trim().isEmpty()) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "ID de mesa no proporcionado.");
        out.print(jsonResponse.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        conn = getConexion();
        
        // Nota: en el sistema 1=Reservada y 2=Ocupada (confirmado por update_nro_mesa_ajax).
        // Actualizamos solo si la mesa está libre (estado 0).
        String sql = "UPDATE mesas SET estado = '1', cliente = ? WHERE idm = ? AND estado = '0'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, cliente == null ? "" : cliente.trim());
        pstmt.setString(2, idm);
        
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Mesa reservada correctamente.");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "La mesa ya no está libre o no existe.");
        }

    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error de servidor: " + e.getMessage());
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }

    out.print(jsonResponse.toString());
%>
