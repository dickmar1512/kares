<%@ include file="../../config/database.jsp" %>
<%
    String s_q = request.getParameter("q"); if(s_q==null) s_q="";
    try {
        COMANDO = "SELECT CONCAT(nombre,'(',clinica,')') nombre, id_servicio " +
                  "FROM patron " +
                  "WHERE tipo IN ('F') " +
                  "AND nombre LIKE ? " +
                  "ORDER BY nombre";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, "%" + s_q.toUpperCase() + "%");
        rset  = pstmt.executeQuery();
        while(rset.next()) {
            out.print(rset.getString("nombre") + "|" + rset.getString("id_servicio") + "\n");
        }
    } catch(Exception e) {
        // silencioso — es un endpoint AJAX
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>