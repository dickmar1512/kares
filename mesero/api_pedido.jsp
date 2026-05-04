<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.io.*" %>
<%@ include file="../config/database.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    JSONObject jsonResponse = new JSONObject();

    // Leer el body JSON
    StringBuilder sb = new StringBuilder();
    BufferedReader br = request.getReader();
    String str;
    while( (str = br.readLine()) != null ){
        sb.append(str);
    }
    
    try {
        JSONObject payload = new JSONObject(sb.toString());
        String s_idm = payload.optString("idm", "");
        String s_id_personal = payload.optString("id_personal", "*");
        JSONArray items = payload.optJSONArray("items");
        
        if (s_idm.isEmpty() || items == null || items.length() == 0) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Datos incompletos");
            out.print(jsonResponse.toString());
            return;
        }

        conn = getConexion();
        
        // 1. Generar nuevo id_mov_vnt
        String s_id_mov_vnt = String.valueOf(new java.util.Date().getTime());
        String id_cont_user = "1"; // Valor por defecto o el que use su sistema
        String sucursal_user = "01";
        String s_punto = "03"; // Default
        String s_tipo_doc = "11"; // Orden
        String s_ip = request.getRemoteAddr();
        
        // 2. Insertar en vent_regdet
        COMANDO = "INSERT INTO vent_regdet (" +
                  "id_venta, id_mov_vnt, id_movart, id_articulo, glosa, " +
                  "cantidad, valor_venta, descuento, base_imp, igv, total, " +
                  "id_personal_user, fecha, estado, modo_det, " +
                  "tipo_serv, id_personal_temp, nivel2, nivel1, estado_atencion) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, 0, ?, ?, SYSDATE(), 'P', '1', ?, '', ?, ?, '0')";
                  
        pstmt = conn.prepareStatement(COMANDO);
        
        for (int i = 0; i < items.length(); i++) {
            JSONObject item = items.getJSONObject(i);
            String id_servicio = item.getString("idservicio");
            String nombre = item.getString("nombre");
            double cantidad = item.getDouble("cantidad");
            double precio = item.getDouble("precio");
            double total = precio * cantidad;
            
            String s_id_movart = s_id_mov_vnt + "_" + i;
            
            // Buscar si es tipo 1 o nivel
            // Por simplicidad, nivel 2 puede ser vacio si no hay
            pstmt.setString(1, id_cont_user);
            pstmt.setString(2, s_id_mov_vnt);
            pstmt.setString(3, s_id_movart);
            pstmt.setString(4, id_servicio);
            pstmt.setString(5, nombre);
            pstmt.setDouble(6, cantidad);
            pstmt.setDouble(7, total); // valor_venta
            pstmt.setDouble(8, total); // base_imp
            pstmt.setDouble(9, total); // total
            pstmt.setString(10, s_id_personal); // user
            pstmt.setString(11, ""); // tipo_serv
            pstmt.setString(12, ""); // nivel2
            pstmt.setString(13, ""); // nivel1
            
            pstmt.executeUpdate();
        }
        cerrar(null, pstmt, null);

        // 3. Incrementar correlativo
        String s_numdoc = "", s_serie = "", s_id_docimp = "";
        COMANDO = "UPDATE puntos_doc SET numero = CAST(numero AS UNSIGNED) + 1 WHERE punto = ? AND tipo_doc = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        COMANDO = "SELECT id_docimp, numero, serie FROM puntos_doc WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_numdoc = rset.getString("numero");
            s_serie = rset.getString("serie");
            s_id_docimp = rset.getString("id_docimp");
        }
        cerrar(rset, pstmt, null);

        // 4. Crear voucher
        String s_voucher = "";
        COMANDO = "SELECT LPAD(IFNULL(MAX(CAST(voucher AS UNSIGNED)),0)+1, 4, '0') as nuevo FROM vent_voucher WHERE id_venta = ? AND id_sucursal = ? AND libro = '70' AND estado = 'V'";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_cont_user);
        pstmt.setString(2, sucursal_user);
        rset = pstmt.executeQuery();
        if (rset.next()) s_voucher = rset.getString("nuevo");
        cerrar(rset, pstmt, null);
        
        COMANDO = "INSERT INTO vent_voucher (id_venta, id_sucursal, libro, voucher, fecha, estado) VALUES (?, ?, '70', ?, SYSDATE(), 'V')";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_cont_user);
        pstmt.setString(2, sucursal_user);
        pstmt.setString(3, s_voucher);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        // 5. Insertar vent_registro
        COMANDO = "INSERT INTO vent_registro (" +
                  "id_cont, id_mov_vnt, id_sucursal, id_ctacte, sub_cta, id_personal, voucher, punto, modo, fecha, id_docimp, tipo_doc, serie, numdoc, " +
                  "valor_venta, base_imp, total, descuento, descuento_esp, cobertura, igv, copago, id_personal_user, ip, estado, tipo_ope, " +
                  "tipo_pac, id_plan, id_tipo_ate, id_vnt_franq, id_paquete, id_personal_dig, id_atencion, id_mesa, ruc, razon" +
                  ") " +
                  "SELECT ?, ?, ?, '', '', ?, ?, ?, '2', SYSDATE(), ?, ?, ?, ?, " +
                  "SUM(IFNULL(valor_venta,0)), SUM(IFNULL(base_imp,0)), SUM(IFNULL(total,0)), SUM(IFNULL(descuento,0)), SUM(IFNULL(descuento_esp,0)), SUM(IFNULL(cobertura,0)), SUM(IFNULL(igv,0)), SUM(IFNULL(copago,0)), ?, ?, 'V', '1', " +
                  "'4', '', '', '*', '', '', '', ?, '', '' " +
                  "FROM vent_regdet WHERE id_mov_vnt = ? AND estado IN ('P','T')";
                  
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_cont_user);
        pstmt.setString(2, s_id_mov_vnt);
        pstmt.setString(3, sucursal_user);
        pstmt.setString(4, s_id_personal);
        pstmt.setString(5, s_voucher);
        pstmt.setString(6, s_punto);
        pstmt.setString(7, s_id_docimp);
        pstmt.setString(8, s_tipo_doc);
        pstmt.setString(9, s_serie);
        pstmt.setString(10, s_numdoc);
        pstmt.setString(11, s_id_personal);
        pstmt.setString(12, s_ip);
        pstmt.setString(13, s_idm);
        pstmt.setString(14, s_id_mov_vnt);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        // 6. Actualizar vent_regdet y mesa
        COMANDO = "UPDATE vent_regdet SET estado = 'V' WHERE id_mov_vnt = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_mov_vnt);
        pstmt.executeUpdate();
        cerrar(null, pstmt, null);

        COMANDO = "UPDATE mesas SET estado = '2' WHERE idm = ? AND estado = '0'";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_idm);
        pstmt.executeUpdate();

        jsonResponse.put("success", true);
        jsonResponse.put("message", "Pedido enviado a cocina correctamente");
        jsonResponse.put("orden", s_serie + "-" + s_numdoc);
        
    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error al procesar el pedido: " + e.getMessage());
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print(jsonResponse.toString());
%>
