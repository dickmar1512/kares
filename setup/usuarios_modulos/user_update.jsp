<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurrió un error inesperado.";

    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_area = request.getParameter("f_id_area");
    String s_ip_usuario = request.getParameter("f_ip");
    String s_punto_emi = request.getParameter("f_punto");

    try {
        if (s_id_personal == null || s_id_area == null) {
            throw new Exception("Datos incompletos.");
        }

        conn = getConexion();
        COMANDO = "UPDATE areas_usuarios SET " +
                  "punto = ?, " +
                  "ip_acceso = ? " +
                  "WHERE id_personal = ? AND id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto_emi);
        pstmt.setString(2, s_ip_usuario);
        pstmt.setString(3, s_id_personal);
        pstmt.setString(4, s_id_area);
        
        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            status = "success";
            message = "Configuración actualizada correctamente.";
        } else {
            message = "No se realizaron cambios o el registro no existe.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>