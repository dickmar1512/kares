<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ page import="org.json.JSONObject, org.json.JSONArray"%>
<%
    String term = request.getParameter("term"); if (term == null) term = "";
    String type = request.getParameter("type"); if (type == null) type = "R"; // R=RUC, E=Empresa
    
    JSONObject responseJson = new JSONObject();
    JSONArray results = new JSONArray();
    
    try {
        conn = getConexion();
        String sql = "";
        
        if (type.equals("R")) {
            sql = "SELECT id_personal, ruc, CONCAT(apepat,' ',apemat,' ',nombre) as nombre " +
                  "FROM datos_personales WHERE ruc = ? LIMIT 10";
        } else {
            // Unificamos las búsquedas de formulario_ruc.jsp
            sql = "SELECT id_personal as id, ruc, CONCAT(apepat,' ',apemat,' ',nombre) as nombre FROM datos_personales WHERE UPPER(CONCAT(apepat,apemat,nombre)) LIKE UPPER(?) " +
                  "UNION " +
                  "SELECT id_compania as id, ruc(id_compania) as ruc, nombre(id_compania) as nombre FROM datos_companias WHERE UPPER(nombre(id_compania)) LIKE UPPER(?) " +
                  "UNION " +
                  "SELECT id_empresa as id, ruc(id_empresa) as ruc, nombre(id_empresa) as nombre FROM datos_empresas WHERE UPPER(nombre(id_empresa)) LIKE UPPER(?) " +
                  "ORDER BY nombre LIMIT 20";
        }
        
        pstmt = conn.prepareStatement(sql);
        if (type.equals("R")) {
            pstmt.setString(1, term);
        } else {
            String likeTerm = "%" + term + "%";
            pstmt.setString(1, likeTerm);
            pstmt.setString(2, likeTerm);
            pstmt.setString(3, likeTerm);
        }
        
        rset = pstmt.executeQuery();
        while (rset.next()) {
            JSONObject item = new JSONObject();
            item.put("id", rset.getString(1));
            item.put("ruc", rset.getString(2) != null ? rset.getString(2) : "");
            item.put("nombre", rset.getString(3));
            results.put(item);
        }
        
        responseJson.put("success", true);
        responseJson.put("results", results);
        
    } catch (Exception e) {
        responseJson.put("success", false);
        responseJson.put("message", e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
    
    out.print(responseJson.toString());
%>
