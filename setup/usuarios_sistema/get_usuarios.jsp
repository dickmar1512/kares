<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    StringBuilder sb = new StringBuilder("[");
    try {
        COMANDO = "SELECT id_personal, ifnull(login,'') login, ifnull(estado,'1') estado, " +
                  "CONCAT(apepat, ' ', apemat, ', ', nombre) as nombre_completo " +
                  "FROM datos_personales " +
                  "WHERE login IS NOT NULL AND login != '' " +
                  "ORDER BY nombre_completo ASC";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        
        boolean first = true;
        while(rset.next()) {
            if(!first) sb.append(",");
            first = false;
            
            String idVal = rset.getString("id_personal");
            String nomVal = rset.getString("nombre_completo");
            String logVal = rset.getString("login");
            String estVal = rset.getString("estado");

            sb.append("{");
            sb.append("\"id\":\"").append(idVal).append("\",");
            sb.append("\"nombre\":\"").append(nomVal.replace("\"", "\\\"")).append("\",");
            sb.append("\"login\":\"").append(logVal.replace("\"", "\\\"")).append("\",");
            sb.append("\"estado\":\"").append(estVal).append("\"");
            sb.append("}");
        }
    } catch(Exception e) {
        // En caso de error, el JSON quedará incompleto o vacío, pero al menos no lanzará excepción de clase no encontrada
    } finally {
        cerrar(rset, pstmt, conn);
    }
    sb.append("]");
    out.print(sb.toString());
%>
