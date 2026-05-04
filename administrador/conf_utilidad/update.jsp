<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String modo          = request.getParameter("modo");           if(modo==null) modo="I";
    String s_id_servicio = request.getParameter("idserv");         if(s_id_servicio==null) s_id_servicio="";
    String s_nom         = request.getParameter("f_nombre");       if(s_nom==null) s_nom="";
    String s_porcen      = request.getParameter("f_porganancia");  if(s_porcen==null) s_porcen="0";
    String s_pvf         = request.getParameter("f_pvf");          if(s_pvf==null||s_pvf.isEmpty()) s_pvf="0";
    String s_cu          = request.getParameter("f_cu");           if(s_cu==null) s_cu="0";

    double d_cu     = 0;
    double d_porcen = 0;
    double d_pvf    = 0;
    double d_uf     = 0;
    double d_precio = 0;

    String status = "error";
    String message = "No se pudo procesar la solicitud.";

    try {
        d_cu     = Double.parseDouble(s_cu.replace(",",""));
        d_porcen = Double.parseDouble(s_porcen.replace(",",""));
        d_pvf    = Double.parseDouble(s_pvf.replace(",",""));
    } catch(NumberFormatException ex) { }

    if(d_pvf > 0) {
        d_uf     = d_pvf - d_cu;
        d_precio = d_pvf;
    } else if(d_porcen > 0) {
        d_uf     = d_cu * (d_porcen / 100.0);
        d_precio = d_cu + d_uf;
    } else {
        d_precio = d_cu;
        d_uf = 0;
    }

    try {
        conn = getConexion();
        conn.setAutoCommit(false);

        if(modo.equals("I")) {
            // 1. Insertar en utilidad
            COMANDO = "INSERT INTO utilidad (idutil, idservicio, porcutil, utilfijo, idpersonaluser, fecha_ing) " +
                      "VALUES (null, ?, ?, ?, ?, sysdate())";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_servicio);
            pstmt.setDouble(2, d_porcen);
            pstmt.setDouble(3, d_uf);
            pstmt.setString(4, id_personal_user);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // 2. Actualizar costo unitario en articulo
            COMANDO = "UPDATE articulo SET cu = ? WHERE idservicio = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setDouble(1, d_cu);
            pstmt.setString(2, s_id_servicio);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // 3. Actualizar tarifa en patron
            COMANDO = "UPDATE patron SET tarifa = ? WHERE id_servicio = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setDouble(1, d_precio);
            pstmt.setString(2, s_id_servicio);
            pstmt.executeUpdate();
            
            message = "Utilidad registrada correctamente.";
        } 
        else {
            // 1. Actualizar utilidad
            COMANDO = "UPDATE utilidad SET porcutil=?, utilfijo=?, updateuser=?, fecha_upd=sysdate() " +
                      "WHERE idservicio=?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setDouble(1, d_porcen);
            pstmt.setDouble(2, d_uf);
            pstmt.setString(3, id_personal_user);
            pstmt.setString(4, s_id_servicio);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // 2. Actualizar tarifa y nombre en patron
            COMANDO = "UPDATE patron SET nombre=?, tarifa=? WHERE id_servicio=?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_nom);
            pstmt.setDouble(2, d_precio);
            pstmt.setString(3, s_id_servicio);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // 3. Actualizar costo unitario en articulo
            COMANDO = "UPDATE articulo SET cu=? WHERE idservicio=?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setDouble(1, d_cu);
            pstmt.setString(2, s_id_servicio);
            pstmt.executeUpdate();
            
            message = "Utilidad actualizada correctamente.";
        }

        conn.commit();
        status = "success";

    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(Exception ex) {}
        status = "error";
        message = "Error: " + e.getMessage();
    } finally {
        cerrar(null, pstmt, conn);
    }
%>
{
    "status": "<%=status%>",
    "message": "<%=message%>"
}
