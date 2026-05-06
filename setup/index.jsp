<%@ include file="../config/database.jsp"%>
<html>
<title>..::Setup KARES::..</title>
<%
    /* ═══════════════════════════════════════════════════════
       VARIABLES INICIALES
    ═══════════════════════════════════════════════════════ */
    String s_ip             = "";
    StringBuilder sbAccesos = new StringBuilder("001 "); // primer acceso
    String s_id_session     = "";

    HttpSession xsession    = request.getSession(true);
    s_id_session            = xsession.getId();

    s_ip = (request.getRemoteAddr().equals("0:0:0:0:0:0:0:1") ||
            request.getRemoteAddr().equals("::1"))
            ? "127.0.0.1"
            : request.getRemoteAddr();

    final String s_id_jsp = "1";
    final String id_area  = "00";
    xsession.putValue("id_area", id_area);

    // ✅ FIX: Evita ambigüedad entre java.util.Date y java.sql.Date
    Date DtActual = new Date();

    String s_login  = request.getParameter("username");
    String s_passwd = request.getParameter("password");

    String s_id_personal      = "";
    String existe             = "";
    String s_id_cont_user     = "2017";
    String s_id_almacen_user  = "";
    String s_id_nivel_user    = "";
    String s_sucursal_user    = "";
    String lista_ip_user      = "";
    String s_punto            = "";

    /* ═══════════════════════════════════════════════════════
       HELPER: Decodificar mensajes UTF-8
    ═══════════════════════════════════════════════════════ */
    // Reutilizamos lógica inline para no duplicar código
    // new String(str.getBytes("ISO-8859-1"), "UTF-8")

    /* ═══════════════════════════════════════════════════════
       BLOQUE 1: Validar que lleguen login y password
    ═══════════════════════════════════════════════════════ */
    if (s_login == null || s_passwd == null) {
        try {
            conn  = getConexion();
            COMANDO = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, String.valueOf(DtActual.getTime()));
            pstmt.setString(2, id_area);
            pstmt.setString(3, s_ip);
            pstmt.setString(4, s_id_jsp);
            pstmt.setString(5, "X");
            pstmt.setString(6, "0");
            pstmt.setString(7, "0");
            rset = pstmt.executeQuery();
            if (rset.next()) {
                String mensaje = new String(
                    "Usuario o contraseña sin datos.".getBytes("ISO-8859-1"), "UTF-8");
                request.setAttribute("error", mensaje);
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }
        } catch (Exception e) {
            String mensaje = new String(
                "Error de conexión a la base de datos 1.".getBytes("ISO-8859-1"), "UTF-8");
            request.setAttribute("error", mensaje + " - " + e.getMessage());
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
            rd.forward(request, response);
        } finally {
            cerrar(rset, pstmt, null);
            COMANDO = "";
        }
    }

    /* ═══════════════════════════════════════════════════════
       BLOQUE 2: Verificar usuario y contraseña
    ═══════════════════════════════════════════════════════ */
    try {
        COMANDO = "SELECT id_personal " +
                  "FROM   datos_personales " +
                  "WHERE  UPPER(login)  = UPPER(?) " +
                  "AND    UPPER(passwd) = UPPER(?) ";                  
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_login);
        pstmt.setString(2, s_passwd);
        rset = pstmt.executeQuery();

        if (rset.next()) {
            s_id_personal = rset.getString("id_personal");

            /* ── BLOQUE 2.1: Verificar acceso al área ── */
            try {
                COMANDO2 = "SELECT * " +
                           "FROM   areas_usuarios " +
                           "WHERE  id_personal = ? " +
                           "AND    id_area     = ? ";                           
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);
                pstmt2.setString(1, s_id_personal);
                pstmt2.setString(2, id_area);
                rset2 = pstmt2.executeQuery();

                if (rset2.next()) {
                    existe = "S";
                    xsession.putValue("id_session",  s_id_session);
                    xsession.putValue("login",        s_login);
                    xsession.putValue("ip",           s_ip);
                    xsession.putValue("punto",        rset2.getString("punto"));

                    /* ── BLOQUE 2.2: Gestionar sesión en BD ── */
                    try {
                        COMANDO3 = "SELECT ip " +
                                   "FROM   sessiones " +
                                   "WHERE  id_session  = ? " +
                                   "AND    id_personal = ? ";
                        conn3 = getConexion();
                        pstmt3 = conn3.prepareStatement(COMANDO3);
                        pstmt3.setString(1, s_id_session);
                        pstmt3.setString(2, s_id_personal);
                        rset3 = pstmt3.executeQuery();

                        if (!rset3.next()) {
                            // INSERT nueva sesión
                            COMANDO4 = "INSERT INTO sessiones " +
                                       "  (id_personal, id_session, dt_ingreso, dt_acceso, ip, id_jsp) " +
                                       "VALUES (?, ?, NOW(), NOW(), ?, ?)";                                      
                            conn4 = getConexion(); 
                            pstmt4 = conn4.prepareStatement(COMANDO4);
                            pstmt4.setString(1, s_id_personal);
                            pstmt4.setString(2, s_id_session);
                            pstmt4.setString(3, s_ip);
                            pstmt4.setString(4, s_id_jsp);
                            upd = pstmt4.executeUpdate();
                        } else {
                            // UPDATE sesión existente
                            COMANDO4 = "UPDATE sessiones " +
                                       "SET    dt_acceso  = NOW(), " +
                                       "       id_jsp     = ? " +
                                       "WHERE  id_personal = ? " +
                                       "AND    id_session  = ? ";                                       
                            conn4 = getConexion();
                            pstmt4 = conn4.prepareStatement(COMANDO4);
                            pstmt4.setString(1, s_id_jsp);
                            pstmt4.setString(2, s_id_personal);
                            pstmt4.setString(3, s_id_session);
                            upd = pstmt4.executeUpdate();
                        }
                        xsession.putValue("id_personal_user", s_id_personal);

                    } catch (Exception e) {
                        // Sesión no crítica: se ignora el error
                    } finally {
                        cerrar(rset3, pstmt3, conn3);
                        cerrar(rset4, pstmt4, conn4);
                        COMANDO3 = "";
                        COMANDO4 = "";
                    }

                } else {
                    /* ── Sin acceso al módulo ── */
                    COMANDO2 = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
                    pstmt2 = conn.prepareStatement(COMANDO2);
                    pstmt2.setString(1, String.valueOf(DtActual.getTime()));
                    pstmt2.setString(2, id_area);
                    pstmt2.setString(3, s_ip);
                    pstmt2.setString(4, s_id_jsp);
                    pstmt2.setString(5, s_id_personal);
                    pstmt2.setString(6, "2");
                    pstmt2.setString(7, "0");
                    rset2 = pstmt2.executeQuery();
                    if (rset2.next()) {
                        String mensaje = new String(
                            "Usuario sin acceso al modulo de administración.".getBytes("ISO-8859-1"), "UTF-8");
                        request.setAttribute("error", mensaje);
                        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                        rd.forward(request, response);
                    }
                }

            } catch (Exception e) {
                String mensaje = new String(
                    "Error de conexión a la base de datos 2.".getBytes("ISO-8859-1"), "UTF-8");
                request.setAttribute("error", mensaje + " - " + e.getMessage());
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            } finally {
                cerrar(rset2, pstmt2, null);
                COMANDO2 = "";
            }

        } else {
            /* ── Login / password incorrectos ── */
            conn2 = getConexion();
            COMANDO2 = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
            pstmt2 = conn2.prepareStatement(COMANDO2);
            pstmt2.setString(1, String.valueOf(DtActual.getTime()));
            pstmt2.setString(2, id_area);
            pstmt2.setString(3, s_ip);
            pstmt2.setString(4, s_id_jsp);
            pstmt2.setString(5, s_id_personal);
            pstmt2.setString(6, "1");
            pstmt2.setString(7, "0");
            rset2 = pstmt2.executeQuery();
            if (rset2.next()) {
                String mensaje = new String(
                    "Usuario o contraseña incorrectos.".getBytes("ISO-8859-1"), "UTF-8");
                request.setAttribute("error", mensaje);
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }
        }

    } catch (Exception e) {
        String mensaje = new String(
            "Error de conexión a la base de datos 3.".getBytes("ISO-8859-1"), "UTF-8");
        request.setAttribute("error", mensaje + " - " + e.getMessage());
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
    } finally {
        cerrar(rset,  pstmt,  null);
        cerrar(rset2, pstmt2, null);
        COMANDO  = "";
        COMANDO2 = "";
    }

    /* ═══════════════════════════════════════════════════════
       BLOQUE 3: Cargar accesos del usuario
    ═══════════════════════════════════════════════════════ */
    try {
        // ✅ FIX: INNER JOIN explícito (estándar ANSI) en lugar de JOIN implícito
        COMANDO = "SELECT a.id_acceso " +
                  "FROM   accesos_usuarios a " +
                  "INNER JOIN accesos_botones b ON a.id_acceso = b.id_acceso " +
                  "WHERE  b.id_area     = ? " +
                  "AND    a.id_personal = ? ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, id_area);
        pstmt.setString(2, s_id_personal);
        rset = pstmt.executeQuery();

        // ✅ FIX: StringBuilder en lugar de concatenación String en bucle
        while (rset.next()) {
            sbAccesos.append(rset.getString("id_acceso")).append(" ");
        }
        xsession.putValue("accesos", sbAccesos.toString().trim());

    } catch (Exception e) {
        String mensaje = new String(
            "Error de conexión a la base de datos 4.".getBytes("ISO-8859-1"), "UTF-8");
        request.setAttribute("error", mensaje + " - " + e.getMessage());
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
    } finally {
        cerrar(rset, pstmt, null);
        COMANDO = "";
    }

    /* ═══════════════════════════════════════════════════════
       BLOQUE 4: Cargar nivel, IP permitida y punto del usuario
    ═══════════════════════════════════════════════════════ */
    try {
        COMANDO = "SELECT punto, nivel, ip_acceso AS ip " +
                  "FROM   areas_usuarios " +
                  "WHERE  id_personal = ? " +
                  "AND    id_area     = ? ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        pstmt.setString(2, id_area);
        rset = pstmt.executeQuery();

        if (rset.next()) {
            s_id_nivel_user = rset.getString("nivel");
            lista_ip_user   = rset.getString("ip");
            s_punto         = rset.getString("punto");

            /* ── BLOQUE 4.1: Obtener sucursal y almacén del punto ── */
            // ✅ FIX: Parámetro preparado en lugar de concatenación directa (SQL injection)
            COMANDO = "SELECT sucursal, id_almacen " +
                      "FROM   puntos " +
                      "WHERE  punto = ? ";
            conn  = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_punto);
            rset  = pstmt.executeQuery();
            if (rset.next()) {
                s_sucursal_user   = rset.getString("sucursal");
                s_id_almacen_user = rset.getString("id_almacen");
                if (s_id_almacen_user == null) s_id_almacen_user = "";
            }

            /* ── BLOQUE 4.2: Validar IP del cliente ── */
            if (!lista_ip_user.trim().equals("*")) {
                if (lista_ip_user.indexOf(s_ip) == -1) {
                    COMANDO = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
                    conn  = getConexion();
                    pstmt = conn.prepareStatement(COMANDO);
                    pstmt.setString(1, String.valueOf(DtActual.getTime()));
                    pstmt.setString(2, id_area);
                    pstmt.setString(3, s_ip);
                    pstmt.setString(4, s_id_jsp);
                    pstmt.setString(5, s_id_personal);
                    pstmt.setString(6, "3");
                    pstmt.setString(7, "0");
                    rset = pstmt.executeQuery();
                    if (rset.next()) {
                        String mensaje = new String(
                            "Pc con acceso restringido.".getBytes("ISO-8859-1"), "UTF-8");
                        request.setAttribute("error", mensaje);
                        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                        rd.forward(request, response);
                    }
                }
            }

            /* ── Guardar datos de usuario en sesión ── */
            xsession.putValue("id_cont_user",    s_id_cont_user);
            xsession.putValue("id_almacen_user", s_id_almacen_user);
            xsession.putValue("nivel",           s_id_nivel_user);
            xsession.putValue("id_nivel_user",   s_id_nivel_user);
            xsession.putValue("sucursal_user",   s_sucursal_user);
            xsession.putValue("lista_ip_user",   lista_ip_user);
            xsession.putValue("punto",           s_punto);
            xsession.putValue("password",        s_passwd);
        }

    } catch (Exception e) {
        String mensaje = new String(
            "Error de conexión a la base de datos 5.".getBytes("ISO-8859-1"), "UTF-8");
        request.setAttribute("error", mensaje + " - " + e.getMessage());
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
    } finally {
        cerrar(rset, pstmt, conn);
        COMANDO = "";
    }
%>

<%-- ═══════════════════════════════════════════════
     RENDER: Mostrar dashboard si el acceso fue válido
════════════════════════════════════════════════ --%>
<% if (existe.equals("S")) { %>
    <%@ include file="dashboard.jsp" %>
<% } %>

