<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_act     = request.getParameter("act"); if(s_act==null) s_act="";
    String s_idart   = request.getParameter("idart"); if(s_idart==null) s_idart="";
    String s_idalmart= request.getParameter("idalmart");
    String s_idserv   = request.getParameter("idserv");
    String s_nombre  = request.getParameter("nombre");
    String s_pcompra = request.getParameter("pcompra"); if(s_pcompra==null||s_pcompra.isEmpty()) s_pcompra="0";
    String s_unidad  = request.getParameter("unidad");
    String s_tipserv  = request.getParameter("tipserv");
    String s_idnivel  = request.getParameter("idnivel");
    String s_presentacion = request.getParameter("presentacion");

    String status = "error";
    String message = "Operación no reconocida.";

    if (s_login == null || s_passwd_user == null) {
        status = "error";
        message = "Sesión expirada.";
    } else {
        try {
            conn = getConexion();
            conn.setAutoCommit(false);

            if ("insert".equals(s_act)) {
                // 1. Insertar en articulo
                COMANDO = "INSERT INTO articulo(idart, idalmart, idservicio, idalmacen, cu, unidad, stock, stock_min, estado, id_personal_user, fecha_ing) " +
                          "VALUES(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, sysdate())";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_idalmart);
                pstmt.setString(2, s_idserv);
                pstmt.setString(3, "1"); // idalmacen default
                pstmt.setString(4, s_pcompra);
                pstmt.setString(5, s_unidad);
                pstmt.setString(6, "0"); // stock initial
                pstmt.setString(7, "0"); // stock_min initial
                pstmt.setString(8, "1"); // estado activo
                pstmt.setString(9, id_personal_user);
                pstmt.executeUpdate();
                cerrar(null, pstmt, null);

                // 2. Insertar en patron
                COMANDO = "INSERT INTO patron (id_servicio, nombre, tarifa, art_presentacion, tipo_servicio, id_nivel, clasif, tipo_precio, estado, tipo, id_personal_user, fecha_dig) " +
                          "VALUES (?, upper(?), 0, ?, ?, ?, '1', '2', '1', 'A', ?, sysdate())";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_idserv);
                pstmt.setString(2, s_nombre);
                pstmt.setString(3, s_presentacion);
                pstmt.setString(4, s_tipserv);
                pstmt.setString(5, s_idnivel);
                pstmt.setString(6, id_personal_user);
                pstmt.executeUpdate();

                message = "Artículo registrado correctamente.";
                status = "success";
            } 
            else if ("update".equals(s_act)) {
                // 1. Actualizar articulo
                COMANDO = "UPDATE articulo SET cu = ?, unidad = ?, update_user = ?, fecha_upd = sysdate() WHERE idart = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_pcompra);
                pstmt.setString(2, s_unidad);
                pstmt.setString(3, id_personal_user);
                pstmt.setString(4, s_idart);
                pstmt.executeUpdate();
                cerrar(null, pstmt, null);

                // 2. Actualizar patron
                COMANDO = "UPDATE patron SET nombre = upper(?), id_nivel = ?, tipo_servicio = ?, art_presentacion = ? WHERE id_servicio = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_nombre);
                pstmt.setString(2, s_idnivel);
                pstmt.setString(3, s_tipserv);
                pstmt.setString(4, s_presentacion);
                pstmt.setString(5, s_idserv);
                pstmt.executeUpdate();

                message = "Artículo actualizado correctamente.";
                status = "success";
            }
            else if ("delete".equals(s_act)) {
                COMANDO = "UPDATE articulo SET estado = (CASE WHEN estado='1' THEN '0' ELSE '1' END) WHERE idart = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_idart);
                pstmt.executeUpdate();
                
                message = "Estado del artículo actualizado.";
                status = "success";
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
            status = "error";
            message = "Error: " + e.getMessage();
        } finally {
            cerrar(null, pstmt, conn);
        }
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}