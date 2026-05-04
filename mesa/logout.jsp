<%@ page contentType="application/json; charset=UTF-8" %>
<%
    //--------------------------------------------------//
    // Este JSP es usado para terminar sesiones y salir //
    //--------------------------------------------------//
    
    HttpSession xsession = request.getSession(false);
    
    if (xsession != null) {
        // Limpiar todos los atributos de sesión
        xsession.setAttribute("s_id_sesion", "");
        xsession.setAttribute("id_personal_user", "");
        xsession.setAttribute("id_cont_user", "");
        xsession.setAttribute("id_nivel_user", "");
        xsession.setAttribute("contabiliza_user", "");
        xsession.setAttribute("id_almacen_user", "");
        xsession.setAttribute("id_sector_user", "");
        xsession.setAttribute("id_compras_user", "");
        xsession.setAttribute("titulo_art", "");
        xsession.setAttribute("login", "");
        xsession.setAttribute("ip", "");
        xsession.setAttribute("accesos", "");
        xsession.setAttribute("id_area", "");
        xsession.setAttribute("lista_ip_user", "");
        
        // Invalidar la sesión
        xsession.invalidate();
    }
    
    // Respuesta JSON
    response.setContentType("application/json");
    out.print("{\"success\": true, \"message\": \"Sesión cerrada correctamente\"}");
%>