<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_punto = request.getParameter("f_punto"); if (s_punto == null) s_punto = "";
    String s_estado = request.getParameter("f_estado");
    String s_tipo_doc = request.getParameter("f_tipo_doc");
    String s_color = "0".equals(s_estado) ? "red" : "";

    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        COMANDO = "UPDATE puntos_doc SET estado = ?, color = ?, userupd = ?, fecupd = NOW() " +
                  "WHERE punto = ? AND tipo_doc = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_estado);
        pstmt.setString(2, s_color);
        pstmt.setString(3, id_personal_user);
        pstmt.setString(4, s_punto);
        pstmt.setString(5, s_tipo_doc);
        pstmt.executeUpdate();
        status = "success";
        message = "Estado actualizado correctamente.";
    } catch (Exception e) {
        status = "error";
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}
