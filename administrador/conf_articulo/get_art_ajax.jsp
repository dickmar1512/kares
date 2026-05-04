<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    response.setHeader("Cache-Control","no-cache");
    response.setHeader("Access-Control-Allow-Origin","*");

    String s_idart = request.getParameter("idart");

    /* ── Salida de error por defecto ── */
    if (s_idart == null || s_idart.trim().isEmpty()) {
        out.print("{\"error\":\"idart requerido\"}");
        return;
    }

    String j_idart     = "";
    String j_idserv    = "";
    String j_idalmart  = "";
    String j_articulo  = "";
    String j_cu        = "";
    String j_unidad    = "";
    String j_tipserv   = "";
    String j_idnivel   = "";
    boolean found      = false;

    try {
        conn = getConexion();

        /* ── Datos base del artículo ── */
        COMANDO = "SELECT a.idart, a.idservicio, a.idalmart, " +
                  "servicio(a.idservicio) articulo, a.cu, a.unidad, " +
                  "s.tipo_servicio tipserv, s.id_nivel idnivel " +
                  "FROM articulo a " +
                  "LEFT JOIN patron s ON s.id_servicio = a.idservicio " +
                  "WHERE a.idart = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_idart);
        rset  = pstmt.executeQuery();

        if (rset.next()) {
            found      = true;
            j_idart    = rset.getString("idart");     if(j_idart   ==null) j_idart   ="";
            j_idserv   = rset.getString("idservicio");if(j_idserv  ==null) j_idserv  ="";
            j_idalmart = rset.getString("idalmart");  if(j_idalmart==null) j_idalmart="";
            j_cu       = rset.getString("cu");        if(j_cu      ==null) j_cu      ="";
            j_unidad   = rset.getString("unidad");    if(j_unidad  ==null) j_unidad  ="";
            j_tipserv  = rset.getString("tipserv");   if(j_tipserv ==null) j_tipserv ="";
            j_idnivel  = rset.getString("idnivel");   if(j_idnivel ==null) j_idnivel ="";

            /* nombre del artículo — escapar para JSON */
            String raw = rset.getString("articulo");
            if (raw == null) raw = "";
            j_articulo = raw
                .replace("\\","\\\\")
                .replace("\"","\\\"")
                .replace("\n","\\n")
                .replace("\r","\\r")
                .replace("\t","\\t");
        }

    } catch(Exception e) {
        out.print("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
        return;
    } finally {
        cerrar(rset, pstmt, conn);
    }

    if (!found) {
        out.print("{\"error\":\"Artículo no encontrado\"}");
        return;
    }

    /* ── Serializar JSON manualmente (sin librería externa) ── */
    StringBuilder sb = new StringBuilder();
    sb.append("{");
    sb.append("\"idart\":")    .append("\"").append(j_idart)   .append("\",");
    sb.append("\"idservicio\":").append("\"").append(j_idserv) .append("\",");
    sb.append("\"idalmart\":") .append("\"").append(j_idalmart).append("\",");
    sb.append("\"articulo\":") .append("\"").append(j_articulo).append("\",");
    sb.append("\"cu\":")       .append("\"").append(j_cu)      .append("\",");
    sb.append("\"unidad\":")   .append("\"").append(j_unidad)  .append("\",");
    sb.append("\"tipserv\":")  .append("\"").append(j_tipserv) .append("\",");
    sb.append("\"idnivel\":")  .append("\"").append(j_idnivel) .append("\"");
    sb.append("}");

    out.print(sb.toString());
%>
