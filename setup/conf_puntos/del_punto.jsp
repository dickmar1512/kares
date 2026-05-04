<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurri\u00f3 un error inesperado.";

    String s_punto_del = request.getParameter("f_punto");

    try {
        if (s_punto_del == null || s_punto_del.trim().isEmpty()) {
            throw new Exception("ID de punto no especificado.");
        }

        conn = getConexion();
        
        // 1. Optional: Delete associated documents? 
        // For now, just the point as requested.
        COMANDO = "DELETE FROM puntos WHERE punto = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto_del);
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            status = "success";
            message = "El punto fue eliminado correctamente.";
        } else {
            message = "No se encontr\u00f3 el punto para eliminar.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, pstmt, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>
