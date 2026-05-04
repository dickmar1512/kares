<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurri\u00f3 un error inesperado.";

    String s_id = request.getParameter("f_id");

    try {
        if (s_id == null || s_id.trim().isEmpty()) {
            throw new Exception("ID de documento no especificado.");
        }

        conn = getConexion();
        COMANDO = "DELETE FROM puntos_doc WHERE id = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id);
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            status = "success";
            message = "El documento fue removido del punto correctamente.";
        } else {
            message = "No se encontr\u00f3 el registro para eliminar.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>
