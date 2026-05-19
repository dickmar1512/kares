<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%
    try {
        conn = getConexion();
        PreparedStatement ps = conn.prepareStatement("SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_STATEMENT FROM information_schema.triggers WHERE TRIGGER_SCHEMA = DATABASE()");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            out.println("Trigger: " + rs.getString("TRIGGER_NAME"));
            out.println("Table: " + rs.getString("EVENT_OBJECT_TABLE"));
            out.println("Event: " + rs.getString("EVENT_MANIPULATION"));
            out.println("Statement: " + rs.getString("ACTION_STATEMENT"));
            out.println("--------------------------------------------------");
        }
        cerrar(rs, ps, conn);
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
