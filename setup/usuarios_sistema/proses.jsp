<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String act = request.getParameter("act");
    String id = request.getParameter("id");
    String login = request.getParameter("login");
    String pass = request.getParameter("pass");
    
    boolean ok = false;
    String msg = "";
    
    if(act == null || id == null) {
        out.print("{\"ok\":false,\"msg\":\"Parámetros insuficientes\"}");
        return;
    }

    try {
        conn = getConexion();
        
        if(act.equals("add") || act.equals("update")) {
            // Validar login duplicado (excepto para el mismo ID si es update)
            COMANDO = "SELECT id_personal FROM datos_personales WHERE login = ? AND id_personal != ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, login);
            pstmt.setString(2, id);
            rset = pstmt.executeQuery();
            if(rset.next()) {
                out.print("{\"ok\":false,\"msg\":\"El nombre de usuario '" + login.replace("'","\\'") + "' ya está en uso.\"}");
                return;
            }
            cerrar(rset, pstmt, null);
            
            if(act.equals("add")) {
                COMANDO = "UPDATE datos_personales SET login = ?, passwd = ?, estado = '1' WHERE id_personal = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, login);
                pstmt.setString(2, pass);
                pstmt.setString(3, id);
                pstmt.executeUpdate();
                ok = true;
                msg = "Usuario creado exitosamente";
            } else {
                // Update
                if(pass != null && !pass.trim().isEmpty()) {
                    COMANDO = "UPDATE datos_personales SET login = ?, passwd = ? WHERE id_personal = ?";
                    pstmt = conn.prepareStatement(COMANDO);
                    pstmt.setString(1, login);
                    pstmt.setString(2, pass);
                    pstmt.setString(3, id);
                } else {
                    COMANDO = "UPDATE datos_personales SET login = ? WHERE id_personal = ?";
                    pstmt = conn.prepareStatement(COMANDO);
                    pstmt.setString(1, login);
                    pstmt.setString(2, id);
                }
                pstmt.executeUpdate();
                ok = true;
                msg = "Usuario actualizado correctamente";
            }
        } else if(act.equals("delete")) {
            COMANDO = "UPDATE datos_personales SET login = '', passwd = '' WHERE id_personal = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id);
            pstmt.executeUpdate();
            ok = true;
            msg = "Acceso de usuario eliminado";
        }
        
    } catch(Exception e) {
        msg = "Error DB: " + e.getMessage().replace("\"","'");
    } finally {
        cerrar(rset, pstmt, conn);
    }
    
    out.print("{\"ok\":" + ok + ",\"msg\":\"" + msg.replace("\"","\\\"") + "\"}");
%>
