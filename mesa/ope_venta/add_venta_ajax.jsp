<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    HttpSession xsession 	= request.getSession (true);
    String s_id_periodo		= (String) xsession.getValue("id_cont_user");
    String id_cont_user = (String) xsession.getValue ("id_cont_user");
    String id_personal_user = "";
	if( id_cont_user == null ) id_cont_user = "X";
    org.json.JSONObject jsonResponse = new org.json.JSONObject();
    
    try {
        String s_id_servicio = request.getParameter("f_id_servicio");
        String cantidad = request.getParameter("f_cantidad");
        
        if(s_id_servicio == null || s_id_servicio.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "ID de servicio no proporcionado");
            out.print(jsonResponse.toString());
            return;
        }
        
        if(cantidad == null || cantidad.trim().isEmpty()) {
            cantidad = "1";
        }
        
        Date DtActual = new Date();
        String s_id_movart = DtActual.getTime() + "";
        
        String s_id_personal = (String) xsession.getValue("id_personal");
        if(s_id_personal == null) s_id_personal = "*";
        
        String s_id_mov_vnt = (String) xsession.getValue("id_mov_vnt");
        String s_modo_det = request.getParameter("modo_venta");
        if(s_modo_det == null) s_modo_det = "";
        
        // Obtener datos del servicio
        String s_valor_venta = "0";
        String tipo_precio = "";
        
        COMANDO = "SELECT tarifa, tipo_precio FROM patron WHERE id_servicio = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_servicio);
        rset = pstmt.executeQuery();
        
        if(rset.next()) {
            s_valor_venta = rset.getString("tarifa");
            tipo_precio = rset.getString("tipo_precio");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Servicio no encontrado");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Calcular montos
        double valorUnitario = Double.parseDouble(s_valor_venta);
        double cant = Double.parseDouble(cantidad);
        double valorVenta = valorUnitario * cant;
        double descuento = 0;
        double baseImp = valorVenta;
        
        // Si es tipo precio 2, sin descuento
        if("2".equals(tipo_precio)) {
            descuento = 0;
            baseImp = valorVenta;
        }
        
        // Insertar detalle
        COMANDO = "INSERT INTO vent_regdet (" +
                  "id_venta, id_mov_vnt, id_movart, id_articulo, glosa, " +
                  "cantidad, valor_venta, descuento, base_imp, igv, total, " +
                  "id_personal_user, fecha, estado, modo_det, cambia_precio, " +
                  "dscto_pac, tipo_serv, id_personal_temp, nivel2, nivel1) " +
                  "SELECT ?, ?, ?, id_servicio, nombre, ?, ?, ?, ?, 0, ?, " +
                  "?, sysdate(), 'P', ?, '', '', '', ?, id_nivel, SUBSTRING(id_nivel, 1, 2) " +
                  "FROM patron WHERE id_servicio = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_cont_user);
        pstmt.setString(2, s_id_mov_vnt);
        pstmt.setString(3, s_id_movart);
        pstmt.setDouble(4, cant);
        pstmt.setDouble(5, valorVenta);
        pstmt.setDouble(6, descuento);
        pstmt.setDouble(7, baseImp);
        pstmt.setDouble(8, baseImp);
        pstmt.setString(9, id_personal_user);
        pstmt.setString(10, s_modo_det);
        pstmt.setString(11, s_id_personal);
        pstmt.setString(12, s_id_servicio);
        
        int resultado = pstmt.executeUpdate();
        
        if(resultado > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Producto agregado correctamente");
            jsonResponse.put("id_servicio", s_id_servicio);
            jsonResponse.put("cantidad", cantidad);
            jsonResponse.put("total", String.format("%.2f", baseImp));
            
            // Actualizar el total en sesión si es necesario
            // Puedes agregar aquí la lógica para actualizar el total de la venta
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error al insertar el producto");
        }
        
    } catch(Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if(rset != null) try { rset.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
        
        out.print(jsonResponse.toString());
    }
%>