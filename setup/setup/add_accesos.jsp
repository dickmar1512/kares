<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_id_area = request.getParameter("f_id_area");
    String s_modo = request.getParameter("modo");
    String s_id_acceso = request.getParameter("f_id_acceso");
    String s_nombre = request.getParameter("f_nombre");
    String s_url = request.getParameter("f_url");
    String s_icono = request.getParameter("f_icono");
    String s_orden = request.getParameter("f_orden");
    String s_id_grupo = request.getParameter("f_id_grupo"); if (s_id_grupo == null) s_id_grupo = "0";

    String status = "error";
    String message = "";

    try {
        conn = getConexion();
        if ("I".equals(s_modo)) {
            // Insertar en accesos_botones y acceso_areas
            COMANDO = "INSERT INTO accesos_botones (id_acceso, id_grupo, icono, nombre, url, orden) " +
                      "VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_acceso);
            pstmt.setString(2, s_id_grupo);
            pstmt.setString(3, s_icono);
            pstmt.setString(4, s_nombre);
            pstmt.setString(5, s_url);
            pstmt.setString(6, s_orden);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // COMANDO = "INSERT INTO acceso_areas (id_area, id_acceso, id_grupo, icono, nombre, url, orden) " +
            //           "VALUES (?, ?, ?, ?, ?, ?, ?)";
            // pstmt = conn.prepareStatement(COMANDO);
            // pstmt.setString(1, s_id_area);
            // pstmt.setString(2, s_id_acceso);
            // pstmt.setString(3, s_id_grupo);
            // pstmt.setString(4, s_icono);
            // pstmt.setString(5, s_nombre);
            // pstmt.setString(6, s_url);
            // pstmt.setString(7, s_orden);
            // pstmt.executeUpdate();
            
            status = "success";
            message = "Acceso registrado correctamente.";
        } else if ("U".equals(s_modo)) {
            // Actualizar ambos
            COMANDO = "UPDATE accesos_botones SET id_grupo = ?, icono = ?, nombre = ?, url = ?, orden = ? WHERE id_acceso = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_grupo);
            pstmt.setString(2, s_icono);
            pstmt.setString(3, s_nombre);
            pstmt.setString(4, s_url);
            pstmt.setString(5, s_orden);
            pstmt.setString(6, s_id_acceso);
            pstmt.executeUpdate();
            cerrar(null, pstmt, null);

            // COMANDO = "UPDATE acceso_areas SET id_area = ?, id_grupo = ?, icono = ?, nombre = ?, url = ?, orden = ? WHERE id_acceso = ?";
            // pstmt = conn.prepareStatement(COMANDO);
            // pstmt.setString(1, s_id_area);
            // pstmt.setString(2, s_id_grupo);
            // pstmt.setString(3, s_icono);
            // pstmt.setString(4, s_nombre);
            // pstmt.setString(5, s_url);
            // pstmt.setString(6, s_orden);
            // pstmt.setString(7, s_id_acceso);
            // pstmt.executeUpdate();
            
            status = "success";
            message = "Acceso actualizado correctamente.";
        }
    } catch (Exception e) {
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
