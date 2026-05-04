<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();
    
    String s_idmc = request.getParameter("f_idmc");
    String s_idmp = request.getParameter("f_idmp");

    if (s_idmc == null || s_idmp == null || s_idmc.isEmpty() || s_idmp.isEmpty()) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Parámetros insuficientes.");
        out.print(jsonResponse.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rset = null;
    
    try {
        conn = getConexion();
        conn.setAutoCommit(false); // Iniciar transacción

        // 1. Obtener id_mov_vnt de los pedidos activos en la mesa de origen
        String sqlSearch = "SELECT DISTINCT b.id_mov_vnt " +
                          "FROM vent_regdet a " +
                          "INNER JOIN vent_registro b ON a.id_mov_vnt = b.id_mov_vnt " +
                          "WHERE b.id_mesa = ? AND b.estado = 'V' " +
                          "AND a.estado = 'V' AND a.id_movart_relacion IS NULL " +
                          "AND a.estado_atencion IN ('0','1','2','3') AND b.tipo_doc = '11'";
        
        pstmt = conn.prepareStatement(sqlSearch);
        pstmt.setString(1, s_idmp);
        rset = pstmt.executeQuery();
        
        // 2. Actualizar id_mesa en vent_registro para cada pedido encontrado
        String sqlUpdateReg = "UPDATE vent_registro SET id_mesa = ? WHERE id_mov_vnt = ?";
        PreparedStatement pstmtUpd = conn.prepareStatement(sqlUpdateReg);
        
        boolean found = false;
        while(rset.next()) {
            found = true;
            pstmtUpd.setString(1, s_idmc);
            pstmtUpd.setString(2, rset.getString("id_mov_vnt"));
            pstmtUpd.executeUpdate();
        }
        pstmtUpd.close();

        // 3. Actualizar estados de las mesas
        // Mesa origen -> Libre ('0')
        String sqlMesaOrig = "UPDATE mesas SET estado = '0' WHERE idm = ?";
        pstmt = conn.prepareStatement(sqlMesaOrig);
        pstmt.setString(1, s_idmp);
        pstmt.executeUpdate();

        // Mesa destino -> Ocupada ('2')
        String sqlMesaDest = "UPDATE mesas SET estado = '2' WHERE idm = ?";
        pstmt = conn.prepareStatement(sqlMesaDest);
        pstmt.setString(1, s_idmc);
        pstmt.executeUpdate();

        conn.commit(); // Confirmar transacción
        
        jsonResponse.put("success", true);
        jsonResponse.put("message", "Cambio de mesa realizado correctamente.");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error al procesar el cambio: " + e.getMessage());
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print(jsonResponse.toString());
%>
