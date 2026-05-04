<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>

<%
	String s_id_personal	= request.getParameter("f_id_personal");
	String s_id_area		= request.getParameter("f_id_area");
	 s_punto		    = request.getParameter("f_punto");
	String s_ip_usuario		= request.getParameter("f_ip");
 
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurrió un error inesperado.";

    try {
        if (s_id_personal == null || s_id_area == null) {
            throw new Exception("Datos incompletos.");
        }

        conn = getConexion();
        COMANDO = "SELECT id_personal FROM areas_usuarios WHERE id_personal = ? AND id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        pstmt.setString(2, s_id_area);
        rset = pstmt.executeQuery();
        
        if (!rset.next()) {
            cerrar(rset, pstmt, null);
            COMANDO = "INSERT INTO areas_usuarios (id_personal, id_area, punto, ip_acceso, fecha_ingreso, estado, id_personal_user) " +
                      "VALUES (?, ?, ?, ?, NOW(), '1', ?)";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_personal);
            pstmt.setString(2, s_id_area);
            pstmt.setString(3, s_punto);
            pstmt.setString(4, s_ip_usuario);
            pstmt.setString(5, id_personal_user);
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                status = "success";
                message = "Usuario vinculado exitosamente.";
            } else {
                message = "No se pudo insertar el registro.";
            }
        } else {
            message = "El usuario ya se encuentra vinculado a este área.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>
