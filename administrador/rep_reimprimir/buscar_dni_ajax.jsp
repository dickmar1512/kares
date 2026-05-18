<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String s_numdoc  = request.getParameter("doc_num");
    String s_tipdoc  = request.getParameter("doc_tipo"); // '1' para DNI, 'E' para RUC

    if (s_numdoc == null || s_numdoc.trim().isEmpty() || s_tipdoc == null || s_tipdoc.trim().isEmpty()) {
        out.print("{\"existe\":false}");
        return;
    }

    try {
        conn = getConexion();
        String sql = "SELECT nombre, apepat, apemat, sexo, direcc FROM datos_personales WHERE numdoc = ? AND tipdoc = ? LIMIT 1";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, s_numdoc);
        pstmt.setString(2, s_tipdoc);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            out.print("{" +
                "\"existe\":true," +
                "\"nombre\":\"" + rset.getString("nombre").trim() + "\"," +
                "\"apepat\":\"" + rset.getString("apepat").trim() + "\"," +
                "\"apemat\":\"" + rset.getString("apemat").trim() + "\"," +
                "\"sexo\":\"" + rset.getString("sexo").trim() + "\"," +
                "\"direccion\":\"" + (rset.getString("direcc") != null ? rset.getString("direcc").trim() : "") + "\"" +
            "}");
        } else {
            out.print("{\"existe\":false}");
        }
    } catch(Exception e) {
        out.print("{\"existe\":false,\"error\":\"" + e.getMessage() + "\"}");
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
