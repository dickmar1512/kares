<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<% 	
    String s_idmovart = request.getParameter("s_id_movart");
    String s_id_personal = request.getParameter("f_id_personal");
    String s_idm = request.getParameter("f_idm");
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    JSONObject jsonResponse = new JSONObject();
    CallableStatement cstmt = null;
    
    try {
        if (s_idmovart == null || s_idmovart.trim().isEmpty()) {
            throw new Exception("No se seleccionaron items para la venta.");
        }

        conn = getConexion();
        // Llamar al procedimiento almacenado
        // Nota: Si el procedimiento requiere el cliente, debería añadirse aquí. 
        // Por ahora mantenemos la firma actual de 4 parámetros.
        cstmt = conn.prepareCall("{CALL sp_kar_generar_registroDetalleVenta(?, ?, ?, ?)}");
        
        cstmt.setString(1, s_idmovart);
        cstmt.registerOutParameter(2, Types.VARCHAR);
        cstmt.registerOutParameter(3, Types.INTEGER);
        cstmt.registerOutParameter(4, Types.VARCHAR);
        
        cstmt.execute();
        
        String idMovVnt = cstmt.getString(2);
        int resultado = cstmt.getInt(3);
        String mensaje = cstmt.getString(4);
        
        if (resultado == 1) {
            jsonResponse.put("success", true);
            jsonResponse.put("id_mov_vnt", idMovVnt);
            jsonResponse.put("message", mensaje);
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", mensaje != null ? mensaje : "El procedimiento no devolvi\u00f3 un mensaje de error.");
        }
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error del servidor: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (cstmt != null) try { cstmt.close(); } catch (Exception e) {}
        cerrar(conn);
    }
    
    out.print(jsonResponse.toString());
%>