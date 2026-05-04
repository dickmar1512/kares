<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
    // Obtener el parámetro de búsqueda
    String query = request.getParameter("q");
    String pageParam = request.getParameter("pagina");
    int pagina = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    try { 
        // Construir el comando SQL con PreparedStatement (SEGURO contra SQL Injection)        
        // Búsqueda por nombre
        COMANDO = "SELECT " +
                    "id_personal, " +
                    "CONCAT(UPPER(apepat),' ',UPPER(apemat),' ',UPPER(nombre)) AS nombre, " +
                    "numdoc AS documento, " +
                    "edad(id_personal) AS edad " +
                    "FROM datos_personales " +
                    "WHERE CONCAT(numdoc, '-',UPPER(apepat),' ',UPPER(apemat),' ',UPPER(nombre))  LIKE (?) " +
                    "AND IFNULL(fallecido,'N') <> 'S' " +
                    "ORDER BY apepat, apemat, nombre " +
                    "LIMIT 20";
        conn = getConexion();       
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, "%" + query + "%");        
        // Ejecutar consulta
        rset = pstmt.executeQuery();
    
        // Crear JSON de respuesta
        JSONObject jsonResponse = new JSONObject();
        JSONArray items = new JSONArray();
    
        while (rset.next()) {
            JSONObject item = new JSONObject();
            
            long idPersonal = rset.getLong("id_personal");
            String nombre = rset.getString("nombre");
            String documento = rset.getString("documento");
            String edad = rset.getString("edad");
            
            // ID para el select
            item.put("id", idPersonal);
            
            // Texto completo para mostrar (nombre + HC + edad)
            String textoCompleto = nombre;
            if (documento != null && !documento.trim().isEmpty()) {
                textoCompleto += " - DNI: " + documento;
            }
            if (edad != null && !edad.trim().isEmpty()) {
                textoCompleto += " (" + edad + " años)";
            }
            
            item.put("text", textoCompleto);
            
            // Datos adicionales opcionales (pueden ser útiles en el frontend)
            item.put("nombre_completo", nombre);
            item.put("documento", documento != null ? documento : "");
            item.put("edad", edad != null ? edad : "");
            
            items.put(item);
        }
        
        jsonResponse.put("items", items);
        jsonResponse.put("total_count", items.length());
        
        out.print(jsonResponse.toString());        
    } catch (Exception e) {
        // Manejo de errores
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("items", new JSONArray());
        errorResponse.put("total_count", 0);
        errorResponse.put("error", e.getMessage());
        out.print(errorResponse.toString());
        
        // Log del error
        e.printStackTrace();
        
    } finally {
        cerrar(rset, pstmt, conn);
        COMANDO = "";
    }
%>
