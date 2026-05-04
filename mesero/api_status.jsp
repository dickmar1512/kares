<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../config/database.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    JSONObject jsonResponse = new JSONObject();
    
    String s_idm = request.getParameter("idm");
    
    if (s_idm == null || s_idm.isEmpty()) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Mesa no especificada");
        out.print(jsonResponse.toString());
        return;
    }

    try {
        conn = getConexion();
        
        // Consultar items de la mesa que estén activos (estado 'V' en registro)
        // y que correspondan al día de hoy para evitar pedidos antiguos
        String COMANDO = 
            "SELECT d.id_movart, d.glosa, d.cantidad, d.total, d.estado_atencion, " +
            "DATE_FORMAT(d.fecha, '%H:%i') as hora " +
            "FROM vent_regdet d " +
            "INNER JOIN vent_registro r ON d.id_mov_vnt = r.id_mov_vnt " +
            "WHERE r.id_mesa = ? AND d.estado = 'V' AND r.estado = 'V' " +
            "AND d.id_movart_relacion IS NULL "+             
            "AND d.estado_atencion IN ('0','1','2','3') " +             
            "AND r.tipo_doc = '11' "+
            "ORDER BY d.fecha DESC ";
            
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_idm);
        rset = pstmt.executeQuery();
        
        JSONArray items = new JSONArray();
        while (rset.next()) {
            JSONObject item = new JSONObject();
            item.put("id", rset.getString("id_movart"));
            item.put("nombre", rset.getString("glosa"));
            item.put("cantidad", rset.getDouble("cantidad"));
            item.put("total", rset.getDouble("total"));
            item.put("estado", rset.getInt("estado_atencion"));
            item.put("hora", rset.getString("hora"));
            items.put(item);
        }
        
        jsonResponse.put("success", true);
        jsonResponse.put("items", items);
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
    
    out.print(jsonResponse.toString());
%>
