<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_area = request.getParameter("f_id_area");
    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        
        // 1. Eliminar accesos asociados primero? 
        // En el sistema original parece que solo borra el área o maneja integridad
        COMANDO = "DELETE FROM acceso_main WHERE id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        COMANDO = "DELETE FROM acceso_areas WHERE id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        pstmt.executeUpdate();
        
        status = "success";
        message = "Área y sus accesos asociados eliminados correctamente.";
    } catch (Exception e) {
        status = "error";
        message = "Error: " + e.getMessage();
    } finally {
        cerrar(null, pstmt, conn);
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}
