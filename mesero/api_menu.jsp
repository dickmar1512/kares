<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../config/database.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    JSONObject jsonResponse = new JSONObject();
    JSONArray items = new JSONArray();
    
    try {
        conn = getConexion();
        
        // Obtener artículos con precio configurado y estado activo
        COMANDO = "SELECT a.idart, a.idalmart, a.idservicio, " +
                  "servicio(a.idservicio) articulo, " +
                  "(case when b.utilfijo=0 " +
                  "  then round(a.cu+(a.cu*(b.porcutil/100)),2) " +
                  "  else round(a.cu+b.utilfijo,2) end) pv " +
                  "FROM articulo a " +
                  "INNER JOIN utilidad b ON a.idservicio=b.idservicio " +
                  "WHERE a.estado = '1' " +
                  "ORDER BY articulo ASC";
                  
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        
        while (rset.next()) {
            JSONObject item = new JSONObject();
            item.put("idart", rset.getString("idart"));
            item.put("codigo", rset.getString("idalmart"));
            item.put("idservicio", rset.getString("idservicio"));
            item.put("nombre", rset.getString("articulo"));
            item.put("precio", rset.getDouble("pv"));
            items.put(item);
        }
        
        jsonResponse.put("success", true);
        jsonResponse.put("items", items);
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error al cargar el menú: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
    
    out.print(jsonResponse.toString());
%>
