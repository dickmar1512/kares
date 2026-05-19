<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String idMovVnt = request.getParameter("id_mov_vnt");
    JSONObject json = new JSONObject();

    if (idMovVnt == null || idMovVnt.trim().isEmpty()) {
        json.put("success", false);
        json.put("message", "ID de venta no proporcionado.");
        out.print(json.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rset = null;

    try {
        conn = getConexion();
        
        // Consultar los datos de contacto del cliente en base al id_personal de la venta
        String sql = "SELECT " +
                     "  (CASE WHEN b.tipo_doc = '39' THEN b.razon ELSE nombre(b.id_personal) END) AS cliente, " +
                     "  p.fono1 AS telefono, " +
                     "  p.email AS email " +
                     "FROM vent_registro b " +
                     "LEFT JOIN datos_personales p ON p.id_personal = b.id_personal " +
                     "WHERE b.id_mov_vnt = ?";
                     
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, idMovVnt);
        rset = pstmt.executeQuery();

        if (rset.next()) {
            String cliente = rset.getString("cliente");
            String telefono = rset.getString("telefono");
            String email = rset.getString("email");

            if (cliente == null) cliente = "CLIENTE PARTICULAR";
            if (telefono == null) telefono = "";
            if (email == null) email = "";

            json.put("success", true);
            json.put("cliente", cliente.toUpperCase());
            json.put("telefono", telefono.trim());
            json.put("email", email.trim());
        } else {
            json.put("success", false);
            json.put("message", "No se encontró el comprobante especificado.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        json.put("success", false);
        json.put("message", "Error en el servidor: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print(json.toString());
%>
