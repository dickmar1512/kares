<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("f_modo");
    String s_id_area = request.getParameter("f_id_area");
    String s_nombre = request.getParameter("f_nombre");

    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        if ("I".equals(s_modo)) {
            COMANDO = "INSERT INTO acceso_main (id_area, nombre) VALUES (?, ?)";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_area);
            pstmt.setString(2, s_nombre);
            pstmt.executeUpdate();
            status = "success";
            message = "Área registrada correctamente.";
        } else if ("U".equals(s_modo)) {
            COMANDO = "UPDATE acceso_main SET nombre = ? WHERE id_area = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_nombre);
            pstmt.setString(2, s_id_area);
            pstmt.executeUpdate();
            status = "success";
            message = "Área actualizada correctamente.";
        }
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
