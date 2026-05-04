<%@ page import="java.sql.*" %>
<%@ include file="../../config/database.jsp" %>
<%
    try {
        conn = getConexion();
        DatabaseMetaData md = conn.getMetaData();
        ResultSet rs = md.getColumns(null, null, "vent_regdet", "estado_atencion");
        if (!rs.next()) {
            Statement stmt_alt = conn.createStatement();
            stmt_alt.executeUpdate("ALTER TABLE vent_regdet ADD COLUMN estado_atencion INT DEFAULT 0");
            out.println("Columna estado_atencion añadida a vent_regdet.");
        } else {
            out.println("La columna estado_atencion ya existe.");
        }
        rs.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        cerrar(null, null, conn);
    }
%>
