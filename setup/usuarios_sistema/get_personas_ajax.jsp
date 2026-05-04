<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String q = request.getParameter("q");
    if(q == null) q = "";
    q = q.toUpperCase();
    
    StringBuilder sb = new StringBuilder("[");
    try {
        COMANDO = "SELECT id_personal, ifnull(numdoc,'') numdoc, CONCAT(apepat, ' ', apemat, ', ', nombre) as nombre_completo " +
                  "FROM datos_personales " +
                  "WHERE (nombre LIKE ? OR numdoc LIKE ? OR apepat LIKE ? OR apemat LIKE ?) " +
                  "AND (login IS NULL OR login = '') " +
                  "AND estado = '1' " +
                  "LIMIT 20";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        String param = "%" + q + "%";
        pstmt.setString(1, param);
        pstmt.setString(2, param);
        pstmt.setString(3, param);
        pstmt.setString(4, param);
        rset = pstmt.executeQuery();
        
        boolean first = true;
        while(rset.next()) {
            if(!first) sb.append(",");
            first = false;
            
            String idVal = rset.getString("id_personal");
            String nomVal = rset.getString("nombre_completo");
            String docVal = rset.getString("numdoc");

            sb.append("{");
            sb.append("\"id\":\"").append(idVal).append("\",");
            sb.append("\"text\":\"").append(nomVal.replace("\"", "\\\"")).append(" (").append(docVal).append(")\"");
            sb.append("}");
        }
    } catch(Exception e) {
    } finally {
        cerrar(rset, pstmt, conn);
    }
    sb.append("]");
    out.print(sb.toString());
%>
