<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("modo");
    String s_punto_form = request.getParameter("f_punto");
    String s_id = request.getParameter("f_id");
    String s_tipo_doc = request.getParameter("f_tipo_doc");
    String s_serie = request.getParameter("f_serie");
    String s_numero = request.getParameter("f_numero");
    String s_ip = request.getParameter("f_ip");
    String s_id_docimp = request.getParameter("f_id_docimp");
    String s_copias = request.getParameter("f_copias");

    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        if ("I".equals(s_modo)) {
            COMANDO = "INSERT INTO puntos_doc (punto, tipo_doc, serie, numero, ip, id_docimp, copias, estado) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, '1')";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_punto_form);
            pstmt.setString(2, s_tipo_doc);
            pstmt.setString(3, s_serie);
            pstmt.setString(4, s_numero);
            pstmt.setString(5, s_ip);
            pstmt.setString(6, s_id_docimp);
            pstmt.setString(7, s_copias);
            pstmt.executeUpdate();
            status = "success";
            message = "Documento asignado correctamente.";
        } else if ("U".equals(s_modo)) {
            COMANDO = "UPDATE puntos_doc SET tipo_doc = ?, serie = ?, numero = ?, ip = ?, id_docimp = ?, copias = ? WHERE id = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_tipo_doc);
            pstmt.setString(2, s_serie);
            pstmt.setString(3, s_numero);
            pstmt.setString(4, s_ip);
            pstmt.setString(5, s_id_docimp);
            pstmt.setString(6, s_copias);
            pstmt.setString(7, s_id);
            pstmt.executeUpdate();
            status = "success";
            message = "Documento actualizado correctamente.";
        }
    } catch (Exception e) {
        status = "error";
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}
