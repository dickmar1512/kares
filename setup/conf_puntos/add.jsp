<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("modo");
    String s_nombre = request.getParameter("f_nombre");
    String s_punto_form = request.getParameter("f_punto");
    String s_modulo = request.getParameter("f_modulo"); if (s_modulo == null) s_modulo = "";
    String s_sucursal = "";
    String s_tipo = request.getParameter("f_tipo"); if (s_tipo == null) s_tipo = "";
    
    String s_carga_paquete = request.getParameter("f_carga_paquete"); if (s_carga_paquete == null) s_carga_paquete = "0";
    String s_carga_presup = request.getParameter("f_carga_presup"); if (s_carga_presup == null) s_carga_presup = "0";
    String s_crea_cuenta = request.getParameter("f_crea_cuenta"); if (s_crea_cuenta == null) s_crea_cuenta = "0";
    String s_carga_cuenta = request.getParameter("f_carga_cuenta"); if (s_carga_cuenta == null) s_carga_cuenta = "0";
    String s_ult_consultas = request.getParameter("f_ult_consultas"); if (s_ult_consultas == null) s_ult_consultas = "0";
    String s_id_almacen = request.getParameter("f_id_almacen"); if (s_id_almacen == null) s_id_almacen = "";

    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        
        // 1. Get sucursal from modulos
        COMANDO = "SELECT sucursal FROM modulos WHERE modulo = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_modulo);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_sucursal = rset.getString("sucursal");
        }
        cerrar(rset, pstmt, null);

        if ("I".equals(s_modo)) {
            COMANDO = "INSERT INTO puntos (punto, nombre, modulo, sucursal, tipo, " +
                      "carga_paquete, carga_presup, crea_cuenta, carga_cuenta, " +
                      "ult_consultas, id_almacen, cobra, ip_acceso_modulo) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '0', '*')";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_punto_form.trim());
            pstmt.setString(2, s_nombre);
            pstmt.setString(3, s_modulo);
            pstmt.setString(4, s_sucursal);
            pstmt.setString(5, s_tipo);
            pstmt.setString(6, s_carga_paquete);
            pstmt.setString(7, s_carga_presup);
            pstmt.setString(8, s_crea_cuenta);
            pstmt.setString(9, s_carga_cuenta);
            pstmt.setString(10, s_ult_consultas);
            pstmt.setString(11, s_id_almacen);
            pstmt.executeUpdate();
            status = "success";
            message = "Punto registrado correctamente.";
        } else if ("U".equals(s_modo)) {
            COMANDO = "UPDATE puntos SET nombre = ?, modulo = ?, sucursal = ?, tipo = ?, " +
                      "carga_paquete = ?, carga_presup = ?, crea_cuenta = ?, carga_cuenta = ?, " +
                      "ult_consultas = ?, id_almacen = ? WHERE punto = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_nombre);
            pstmt.setString(2, s_modulo);
            pstmt.setString(3, s_sucursal);
            pstmt.setString(4, s_tipo);
            pstmt.setString(5, s_carga_paquete);
            pstmt.setString(6, s_carga_presup);
            pstmt.setString(7, s_crea_cuenta);
            pstmt.setString(8, s_carga_cuenta);
            pstmt.setString(9, s_ult_consultas);
            pstmt.setString(10, s_id_almacen);
            pstmt.setString(11, s_punto_form);
            pstmt.executeUpdate();
            status = "success";
            message = "Punto actualizado correctamente.";
        }
    } catch (Exception e) {
        status = "error";
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}
