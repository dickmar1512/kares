<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String status = "error";
    String message = "Ocurrió un error inesperado.";
    int updatesCount = 0;

    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_area = request.getParameter("f_id_area");
    String f_cuenta = request.getParameter("f_total_det");
    int cuenta_int = (f_cuenta != null) ? Integer.parseInt(f_cuenta) : 0;
    s_ip = (request.getRemoteAddr().equals("0:0:0:0:0:0:0:1") ||
            request.getRemoteAddr().equals("::1"))
            ? "127.0.0.1"
            : request.getRemoteAddr();

    try {
        if (s_id_personal == null || s_id_area == null) {
            throw new Exception("Datos de usuario o área incompletos.");
        }

        conn = getConexion();
        
        for (int i = 1; i <= cuenta_int; i++) {
            String dar_acceso = request.getParameter("f_det_act" + i);
            if (dar_acceso == null) dar_acceso = "N";
            String s_id_acceso = request.getParameter("f_id_acceso" + i);

            // Check existing access
            COMANDO = "SELECT id_acceso FROM accesos_usuarios WHERE id_acceso = ? AND id_personal = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_acceso);
            pstmt.setString(2, s_id_personal);
            rset = pstmt.executeQuery();
            boolean exists = rset.next();
            cerrar(rset, pstmt, null);

            if (exists && dar_acceso.equals("N")) {
                // DELETE access
                COMANDO = "DELETE FROM accesos_usuarios WHERE id_personal = ? AND id_acceso = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_id_personal);
                pstmt.setString(2, s_id_acceso);
                pstmt.executeUpdate();
                updatesCount++;
                cerrar(null, pstmt, null);
            } else if (!exists && dar_acceso.equals("S")) {
                // INSERT access
                COMANDO = "INSERT INTO accesos_usuarios (id_personal, id_acceso, id_personal_user, fecha_cre, ip, nom) " +
                          "VALUES (?, ?, ?, NOW(), ?, NOMBRE(?))";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_id_personal);
                pstmt.setString(2, s_id_acceso);
                pstmt.setString(3, id_personal_user);
                pstmt.setString(4, s_ip);
                pstmt.setString(5, s_id_personal);
                pstmt.executeUpdate();
                updatesCount++;
                cerrar(null, pstmt, null);
            }
        }
        
        status = "success";
        message = "Se actualizaron " + updatesCount + " permisos correctamente.";
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        cerrar(null, null, conn);
    }

    out.print("{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}");
%>
