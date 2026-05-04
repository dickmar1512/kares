<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String url_back = "form_venta.jsp"; 
    String url_main = "index.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Procesando Orden</title>
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/print_orden.css">
</head> 
<body> 

<% 
    // Recuperar parámetros e información de sesión
    int c_ultimo = Integer.parseInt(request.getParameter("cont_items") != null ? request.getParameter("cont_items") : "0");
    
    String s_id_mov_vnt = request.getParameter("f_id_mov_vnt");
    if (s_id_mov_vnt == null || s_id_mov_vnt.isEmpty()) {
        s_id_mov_vnt = (String) xsession.getValue("id_mov_vnt");
    }
    
    String s_idm = request.getParameter("f_idm");
    if (s_idm == null || s_idm.isEmpty()) {
        s_idm = (String) xsession.getValue("idm");
    }
    
    String s_id_personal = (String) xsession.getValue("id_personal"); 
    if(s_id_personal == null || s_id_personal.isEmpty()) s_id_personal = "*";
    
    String s_tipo_doc = "11"; // Orden de Atención/Venta
    String s_ruc = request.getParameter("f_ruc"); if (s_ruc == null) s_ruc = "";
    String ap = request.getParameter("f_apepat"); if(ap == null) ap = "";
    String am = request.getParameter("f_apemat"); if(am == null) am = "";
    String nom = request.getParameter("f_nombre"); if(nom == null) nom = "";
    String s_razon = (ap + " " + am + " " + nom).trim();
    
    String s_serie = "";
    String s_numdoc = "";
    String s_id_docimp = "";
    String c_igv = "18"; // Default
    
    out.println("<!-- Procesando orden: " + s_id_mov_vnt + " para mesa: " + s_idm + " -->");

    // Obtener valor de IGV configurado
    try {
        COMANDO = "SELECT valor FROM valores WHERE id_valores = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, "001");
        rset = pstmt.executeQuery();
        if (rset.next()) {
            c_igv = rset.getString("valor");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error IGV: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    // 1. Actualizar precios si fueron modificados en el formulario
    for (int c = 1; c <= c_ultimo; c++) {
        String c_cambia_precio = request.getParameter("f_cambia_precio_" + c);
        if ("3".equals(c_cambia_precio)) {
            String c_id_movart = request.getParameter("f_id_movart_" + c);
            String c_nuevo_total = request.getParameter("f_total_nuevo_" + c);
            if (c_nuevo_total != null && !c_nuevo_total.isEmpty()) {
                double total = Double.parseDouble(c_nuevo_total);
                double igv_val = 1 + (Double.parseDouble(c_igv) / 100);
                double base_imp = total / igv_val;
                double igv = total - base_imp;

                try {
                    COMANDO = "UPDATE vent_regdet SET valor_venta = ?, base_imp = ?, igv = ?, total = ? WHERE id_movart = ?";
                    conn = getConexion();
                    pstmt = conn.prepareStatement(COMANDO);
                    pstmt.setDouble(1, base_imp);
                    pstmt.setDouble(2, base_imp);
                    pstmt.setDouble(3, igv);
                    pstmt.setDouble(4, total);
                    pstmt.setString(5, c_id_movart);
                    pstmt.executeUpdate();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error Update Det: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    cerrar(null, pstmt, conn);
                }
            }
        }
    }

    // 2. Incrementar correlativo de la orden
    try {
        COMANDO = "UPDATE puntos_doc SET numero = CAST(numero AS UNSIGNED) + 1 WHERE punto = ? AND tipo_doc = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        pstmt.executeUpdate();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Correlativo: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    // 3. Obtener serie y número actual
    try {
        COMANDO = "SELECT id_docimp, numero, serie FROM puntos_doc WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_numdoc = rset.getString("numero");
            s_serie = rset.getString("serie");
            s_id_docimp = rset.getString("id_docimp");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Get Doc: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    // 4. Lógica de Voucher (Libro '70')
    String s_voucher = "";
    try {
        COMANDO = "SELECT voucher FROM vent_voucher WHERE id_venta = ? AND id_sucursal = ? AND libro = '70' AND DATE_FORMAT(fecha,'%Y%m%d') = DATE_FORMAT(SYSDATE(),'%Y%m%d') AND estado = 'V'";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_cont_user);
        pstmt.setString(2, sucursal_user);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_voucher = rset.getString("voucher");
        } else {
            // Generar nuevo voucher
            cerrar(rset, pstmt, null);
            COMANDO = "SELECT LPAD(IFNULL(MAX(CAST(voucher AS UNSIGNED)),0)+1, 4, '0') as nuevo FROM vent_voucher WHERE id_venta = ? AND id_sucursal = ? AND libro = '70' AND estado = 'V'";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id_cont_user);
            pstmt.setString(2, sucursal_user);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_voucher = rset.getString("nuevo");
            }
            
            // Insertar nuevo voucher
            cerrar(rset, pstmt, null);
            COMANDO = "INSERT INTO vent_voucher (id_venta, id_sucursal, libro, voucher, fecha, estado) VALUES (?, ?, '70', ?, SYSDATE(), 'V')";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id_cont_user);
            pstmt.setString(2, sucursal_user);
            pstmt.setString(3, s_voucher);
            pstmt.executeUpdate();
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Voucher: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }

    // 5. Insertar cabecera de la orden (vent_registro)
    try {
        COMANDO = "INSERT INTO vent_registro (" +
                  "id_cont, id_mov_vnt, id_sucursal, id_ctacte, sub_cta, id_personal, voucher, punto, modo, fecha, id_docimp, tipo_doc, serie, numdoc, " +
                  "valor_venta, base_imp, total, descuento, descuento_esp, cobertura, igv, copago, id_personal_user, ip, estado, tipo_ope, " +
                  "tipo_pac, id_plan, id_tipo_ate, id_vnt_franq, id_paquete, id_personal_dig, id_atencion, id_mesa, ruc, razon" +
                  ") " +
                  "SELECT ?, ?, ?, '', '', ?, ?, ?, '2', SYSDATE(), ?, ?, ?, ?, " +
                  "SUM(IFNULL(valor_venta,0)), SUM(IFNULL(base_imp,0)), SUM(IFNULL(total,0)), SUM(IFNULL(descuento,0)), SUM(IFNULL(descuento_esp,0)), SUM(IFNULL(cobertura,0)), SUM(IFNULL(igv,0)), SUM(IFNULL(copago,0)), ?, ?, 'V', '1', " +
                  "'4', '', '', '*', '', '', '', ?, ?, ? " +
                  "FROM vent_regdet WHERE id_mov_vnt = ? AND estado IN ('P','T')";
        
        conn = getConexion();
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
        pstmt.setString(11, id_personal_user);
        pstmt.setString(12, s_ip);
        pstmt.setString(13, s_idm);
        pstmt.setString(14, s_ruc);
        pstmt.setString(15, s_razon);
        pstmt.setString(16, s_id_mov_vnt);
        int rows = pstmt.executeUpdate();
        if (rows == 0) {
            out.println("<p style='color:orange;'>Aviso: No se insertó nada en vent_registro. Verifique si hay items en estado P o T para id_mov_vnt: " + s_id_mov_vnt + "</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Insert Reg: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    // 6. Actualizar estado del detalle a 'V' (Vendido/Validado)
    try {
        COMANDO = "UPDATE vent_regdet SET estado = 'V' WHERE id_mov_vnt = ?";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_mov_vnt);
        pstmt.executeUpdate();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Update Det V: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    // 7. Actualizar estado de la mesa (si está libre '0', pasar a ocupada '2')
    try {
        COMANDO = "UPDATE mesas SET estado = '2' WHERE idm = ? AND estado = '0'";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_idm);
        pstmt.executeUpdate();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error Update Mesa: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    // Incluir el archivo de impresión
%>
    <%@ include file="print_orden.jsp" %>
<%
    // Limpiar variables de sesión críticas después de procesar la orden
    xsession.putValue("id_mov_vnt", ""); 
    xsession.putValue("id_personal", "");
    // Mantenemos idm para que el usuario sepa en qué mesa estaba
%>
</body>
</html>