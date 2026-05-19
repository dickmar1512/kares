<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<!DOCTYPE html>
<html>
<head>
    <title>Actualizador de Base de Datos - Kares</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f6f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); text-align: center; max-width: 500px; }
        .success { color: #28a745; font-size: 18px; font-weight: bold; }
        .error { color: #dc3545; font-size: 16px; }
        .btn { display: inline-block; margin-top: 20px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
        .btn:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="card">
        <h2>Actualización de Base de Datos</h2>
        <hr>
<%
    boolean success = false;
    String mensaje = "";
    try {
        conn = getConexion();
        Statement stmtAlter = conn.createStatement();
        
        // Intentar agregar la columna. Si ya existe, lanzará un error que ignoraremos o mostraremos amigablemente.
        stmtAlter.executeUpdate("ALTER TABLE mesas ADD COLUMN cliente VARCHAR(255) NULL");
        
        success = true;
        mensaje = "La columna 'cliente' se agregó correctamente a la tabla 'mesas'.";
        stmtAlter.close();
    } catch (java.sql.SQLException e) {
        if (e.getMessage().contains("Duplicate column name")) {
            success = true;
            mensaje = "La columna 'cliente' YA EXISTE en la tabla 'mesas'. El sistema está listo.";
        } else {
            mensaje = "Error SQL: " + e.getMessage();
        }
    } catch (Exception e) {
        mensaje = "Error: " + e.getMessage();
    } finally {
        cerrar(conn);
    }
%>
        <% if(success) { %>
            <p class="success">✅ <%=mensaje%></p>
            <p>Ya puedes procesar ventas y liberar mesas sin errores.</p>
        <% } else { %>
            <p class="error">❌ <%=mensaje%></p>
        <% } %>
        
        <a href="../../index.jsp" class="btn">Volver al Inicio</a>
    </div>
</body>
</html>
