<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_acceso = request.getParameter("f_id_acceso");
    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        
        COMANDO = "DELETE FROM accesos_botones WHERE id_acceso = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_acceso);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        COMANDO = "DELETE FROM acceso_areas WHERE id_acceso = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_acceso);
        pstmt.executeUpdate();
        
        status = "success";
        message = "Acceso eliminado correctamente.";
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
