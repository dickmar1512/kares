<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_area = request.getParameter("f_id_area");
    
    if (s_id_area == null) { s_id_area = ""; }
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurrió un error inesperado.";

    try {
        if (s_id_personal == null || s_id_area == null) {
            throw new Exception("Datos incompletos.");
        }

        conn = getConexion();
        
        // 1. Delete accesses
        COMANDO = "DELETE FROM accesos_usuarios WHERE id_acceso IN (SELECT id_acceso FROM accesos_botones WHERE id_area = ?) AND id_personal = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        pstmt.setString(2, s_id_personal);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        // 2. Delete from area
        COMANDO = "DELETE FROM areas_usuarios WHERE id_personal = ? AND id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        pstmt.setString(2, s_id_area);
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            status = "success";
            message = "Usuario removido del área correctamente.";
        } else {
            message = "No se encontró el registro para eliminar.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>