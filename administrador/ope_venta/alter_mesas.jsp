<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%
    try {
        conn = getConexion();
        Statement stmtAlter = conn.createStatement();
        stmtAlter.executeUpdate("ALTER TABLE mesas ADD COLUMN cliente VARCHAR(255) NULL");
        out.println("Column 'cliente' added successfully to 'mesas' table!");
        stmtAlter.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        cerrar(conn);
    }
%>
