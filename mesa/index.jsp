<%@ include file="../config/database.jsp"%>
<html>
	<title>..::Mesa::..</title>
<% 
	String	s_ip 			= "";
	String	accesos			= "001"; // primer acceso
	String	s_id_session 	= "";
		
	//Inicio para identificar sesion
	HttpSession xsession = request.getSession(true);
	
	s_id_session = xsession.getId();
	s_ip = (request.getRemoteAddr().equals("0:0:0:0:0:0:0:1") || request.getRemoteAddr().equals("::1")) ? "127.0.0.1" : request.getRemoteAddr();
	
	String s_id_jsp		= "3";
	String id_area		= "03"; 
	xsession.putValue("id_area", id_area);
	
	Date DtActual 		= new Date(); 
	String paramUser   = request.getParameter("username");
	String paramPasswd = request.getParameter("password");

	String s_login  = paramUser   != null ? paramUser   : 
					xsession.getValue("username") != null ? (String) xsession.getValue("username") : "";

	String s_passwd = paramPasswd != null ? paramPasswd : 
					xsession.getValue("password") != null ? (String) xsession.getValue("password") : "";
	String s_id_personal		= "";
	String existe				= "";
	String s_id_cont_user 		= "2017";
	String s_id_almacen_user	= "";
	String s_id_nivel_user		= "";
	String s_sucursal_user		= "";
	String lista_ip_user		= "";
	String s_fecha				= "";
	String s_punto				= "";

	try {
		// Validación inicial de login/password
		if ((s_login == null) || (s_passwd == null)) {
			COMANDO = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
			conn = getConexion();
			if (conn == null) {
				throw new Exception("Error de conexión a la base de datos");
			}
			
			try {
				pstmt = conn.prepareStatement(COMANDO);
				pstmt.setString(1, DtActual.getTime() + "");
				pstmt.setString(2, id_area);
				pstmt.setString(3, s_ip);
				pstmt.setString(4, s_id_jsp);
				pstmt.setString(5, "X");
				pstmt.setString(6, "0");
				pstmt.setString(7, "0");
				
				rset = pstmt.executeQuery();
				if (rset.next()) {
					String mensaje = new String("Usuario o contraseña sin datos.".getBytes("ISO-8859-1"), "UTF-8");
					request.setAttribute("error", mensaje);
					RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
					rd.forward(request, response);
					return;
				}
			} finally {
				cerrar(rset, pstmt, conn);
				rset = null;
				pstmt = null;
				conn = null;
			}
		}

		// Verificar que exista en datos personales
		COMANDO = "SELECT id_personal FROM datos_personales WHERE upper(login) = upper(?) AND upper(passwd) = upper(?)";
		conn = getConexion();
		if (conn == null) {
			throw new Exception("Error de conexión a la base de datos");
		}
		
		try {
			pstmt = conn.prepareStatement(COMANDO);
			pstmt.setString(1, s_login);
			pstmt.setString(2, s_passwd);
			rset = pstmt.executeQuery();
			
			if (rset.next()) {
				s_id_personal = rset.getString("id_personal");
			}
		} finally {
			cerrar(rset, pstmt, conn);
			rset = null;
			pstmt = null;
			conn = null;
		}

		// Si se encontró el usuario, verificar acceso al menú
		if (!s_id_personal.equals("")) {
			COMANDO2 = "SELECT * FROM areas_usuarios WHERE id_personal = ? AND id_area = ?";
			conn2 = getConexion();
			if (conn2 == null) {
				throw new Exception("Error de conexión a la base de datos");
			}
			
			try {
				pstmt2 = conn2.prepareStatement(COMANDO2);
				pstmt2.setString(1, s_id_personal);
				pstmt2.setString(2, id_area);
				rset2 = pstmt2.executeQuery();
				
				if (rset2.next()) {
					existe = "S";
					
					xsession.putValue("id_session", s_id_session);
					xsession.putValue("login", s_login);
					xsession.putValue("ip", s_ip);
					xsession.putValue("punto", rset2.getString("punto"));
					
					// Verificar/actualizar sesión
					COMANDO3 = "SELECT ip FROM sessiones WHERE id_session = ? AND id_personal = ?";
					conn3 = getConexion();
					if (conn3 == null) {
						throw new Exception("Error de conexión a la base de datos");
					}
					
					try {
						pstmt3 = conn3.prepareStatement(COMANDO3);
						pstmt3.setString(1, s_id_session);
						pstmt3.setString(2, s_id_personal);
						rset3 = pstmt3.executeQuery();
						
						conn4 = getConexion();
						if (conn4 == null) {
							throw new Exception("Error de conexión a la base de datos");
						}
						
						try {
							if (!rset3.next()) {
								COMANDO4 = "INSERT INTO sessiones (id_personal, id_session, dt_ingreso, dt_acceso, ip, id_jsp) VALUES (?, ?, now(), now(), ?, ?)";
								pstmt4 = conn4.prepareStatement(COMANDO4);
								pstmt4.setString(1, s_id_personal);
								pstmt4.setString(2, s_id_session);
								pstmt4.setString(3, s_ip);
								pstmt4.setString(4, s_id_jsp);
								upd = pstmt4.executeUpdate();
							} else {
								COMANDO4 = "UPDATE sessiones SET dt_acceso = now(), id_jsp = ? WHERE id_personal = ? AND id_session = ?";
								pstmt4 = conn4.prepareStatement(COMANDO4);
								pstmt4.setString(1, s_id_jsp);
								pstmt4.setString(2, s_id_personal);
								pstmt4.setString(3, s_id_session);
								upd = pstmt4.executeUpdate();
							}
						} finally {
							cerrar(null, pstmt4, conn4);
							pstmt4 = null;
							conn4 = null;
						}
						
						xsession.putValue("id_personal_user", s_id_personal);
						
					} finally {
						cerrar(rset3, pstmt3, conn3);
						rset3 = null;
						pstmt3 = null;
						conn3 = null;
					}
					
				} else {
					// No tiene acceso al área
					COMANDO2 = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
					conn2 = getConexion();
					if (conn2 == null) {
						throw new Exception("Error de conexión a la base de datos");
					}
					
					try {
						pstmt2 = conn2.prepareStatement(COMANDO2);
						pstmt2.setString(1, DtActual.getTime() + "");
						pstmt2.setString(2, id_area);
						pstmt2.setString(3, s_ip);
						pstmt2.setString(4, s_id_jsp);
						pstmt2.setString(5, s_id_personal);
						pstmt2.setString(6, "2");
						pstmt2.setString(7, "0");
						rset2 = pstmt2.executeQuery();
						
						if (rset2.next()) {
							String mensaje = new String("Usuario sin acceso al modulo de administración.".getBytes("ISO-8859-1"), "UTF-8");
							request.setAttribute("error", mensaje);
							RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
							rd.forward(request, response);
							return;
						}
					} finally {
						cerrar(rset2, pstmt2, conn2);
						rset2 = null;
						pstmt2 = null;
						conn2 = null;
					}
				}
			} finally {
				if (rset2 != null) try { rset2.close(); } catch (Exception e) {}
				if (pstmt2 != null) try { pstmt2.close(); } catch (Exception e) {}
				if (conn2 != null) try { conn2.close(); } catch (Exception e) {}
			}
		} else {
			// Usuario no encontrado
			COMANDO2 = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
			conn2 = getConexion();
			if (conn2 == null) {
				throw new Exception("Error de conexión a la base de datos");
			}
			
			try {
				pstmt2 = conn2.prepareStatement(COMANDO2);
				pstmt2.setString(1, DtActual.getTime() + "");
				pstmt2.setString(2, id_area);
				pstmt2.setString(3, s_ip);
				pstmt2.setString(4, s_id_jsp);
				pstmt2.setString(5, s_id_personal);
				pstmt2.setString(6, "1");
				pstmt2.setString(7, "0");
				rset2 = pstmt2.executeQuery();
				
				if (rset2.next()) {
					String mensaje = new String("Usuario o contraseña incorrectos.".getBytes("ISO-8859-1"), "UTF-8");
					request.setAttribute("error", mensaje);
					RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
					rd.forward(request, response);
					return;
				}
			} finally {
				cerrar(rset2, pstmt2, conn2);
				rset2 = null;
				pstmt2 = null;
				conn2 = null;
			}
		}

		// Si el usuario tiene acceso, continuar con la configuración
		if (existe.equals("S")) {
			// Obtener accesos
			COMANDO = "SELECT a.id_acceso FROM accesos_usuarios a, accesos_botones b WHERE a.id_acceso = b.id_acceso AND b.id_area = ? AND a.id_personal = ?";
			conn = getConexion();
			if (conn == null) {
				throw new Exception("Error de conexión a la base de datos");
			}
			
			try {
				pstmt = conn.prepareStatement(COMANDO);
				pstmt.setString(1, id_area);
				pstmt.setString(2, s_id_personal);
				rset = pstmt.executeQuery();
				
				while (rset.next()) {
					accesos += rset.getString("id_acceso") + " ";
				}
				xsession.putValue("accesos", accesos);
			} finally {
				cerrar(rset, pstmt, conn);
				rset = null;
				pstmt = null;
				conn = null;
			}

			// Obtener datos adicionales del usuario
			COMANDO = "SELECT punto, nivel, ip_acceso ip FROM areas_usuarios WHERE id_personal = ? AND id_area = ?";
			conn = getConexion();
			if (conn == null) {
				throw new Exception("Error de conexión a la base de datos");
			}
			
			try {
				pstmt = conn.prepareStatement(COMANDO);
				pstmt.setString(1, s_id_personal);
				pstmt.setString(2, id_area);
				rset = pstmt.executeQuery();
				
				if (rset.next()) {
					s_id_nivel_user = rset.getString("nivel");
					lista_ip_user = rset.getString("ip");
					s_punto = rset.getString("punto");
				}
			} finally {
				cerrar(rset, pstmt, conn);
				rset = null;
				pstmt = null;
				conn = null;
			}

			// Obtener sucursal y almacén
			if (!s_punto.equals("")) {
				COMANDO = "SELECT sucursal, id_almacen FROM puntos WHERE punto = ?";
				conn = getConexion();
				if (conn == null) {
					throw new Exception("Error de conexión a la base de datos");
				}
				
				try {
					pstmt = conn.prepareStatement(COMANDO);
					pstmt.setString(1, s_punto);
					rset = pstmt.executeQuery();
					
					if (rset.next()) {
						s_sucursal_user = rset.getString("sucursal");
						s_id_almacen_user = rset.getString("id_almacen");
						if (s_id_almacen_user == null) s_id_almacen_user = "";
					}
				} finally {
					cerrar(rset, pstmt, conn);
					rset = null;
					pstmt = null;
					conn = null;
				}
			}

			// Validar IP
			if (!lista_ip_user.trim().equals("*")) {
				if (lista_ip_user.indexOf(s_ip) == -1) {
					COMANDO = "CALL sp_kar_registrar_intruso(?, ?, ?, ?, ?, ?, ?)";
					conn = getConexion();
					if (conn == null) {
						throw new Exception("Error de conexión a la base de datos");
					}
					
					try {
						pstmt = conn.prepareStatement(COMANDO);
						pstmt.setString(1, DtActual.getTime() + "");
						pstmt.setString(2, id_area);
						pstmt.setString(3, s_ip);
						pstmt.setString(4, s_id_jsp);
						pstmt.setString(5, s_id_personal);
						pstmt.setString(6, "3");
						pstmt.setString(7, "0");
						rset = pstmt.executeQuery();
						
						if (rset.next()) {
							String mensaje = new String("Pc con acceso restringido.".getBytes("ISO-8859-1"), "UTF-8");
							request.setAttribute("error", mensaje);
							RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
							rd.forward(request, response);
							return;
						}
					} finally {
						cerrar(rset, pstmt, conn);
						rset = null;
						pstmt = null;
						conn = null;
					}
				}
			}

			// Guardar datos en sesión
			xsession.putValue("id_cont_user", s_id_cont_user);
			xsession.putValue("id_almacen_user", s_id_almacen_user);
			xsession.putValue("nivel", s_id_nivel_user);
			xsession.putValue("id_nivel_user", s_id_nivel_user);
			xsession.putValue("sucursal_user", s_sucursal_user);
			xsession.putValue("lista_ip_user", lista_ip_user);
			xsession.putValue("punto", s_punto);
			xsession.putValue("username", s_login);
			xsession.putValue("password", s_passwd);
		}
		
	} catch (Exception e) {
		// Log del error
		System.err.println("Error en index.jsp: " + e.getMessage());
		e.printStackTrace();
		
		// Redirigir a página de error
		String mensaje = new String("Error en el sistema. Por favor contacte al administrador.".getBytes("ISO-8859-1"), "UTF-8");
		request.setAttribute("error", mensaje);
		RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
		rd.forward(request, response);
		return;
	} finally {
		// Asegurar que todos los recursos estén cerrados
		try { if (rset != null) rset.close(); } catch (Exception e) {}
		try { if (rset2 != null) rset2.close(); } catch (Exception e) {}
		try { if (rset3 != null) rset3.close(); } catch (Exception e) {}
		try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
		try { if (pstmt2 != null) pstmt2.close(); } catch (Exception e) {}
		try { if (pstmt3 != null) pstmt3.close(); } catch (Exception e) {}
		try { if (pstmt4 != null) pstmt4.close(); } catch (Exception e) {}
		try { if (conn != null) conn.close(); } catch (Exception e) {}
		try { if (conn2 != null) conn2.close(); } catch (Exception e) {}
		try { if (conn3 != null) conn3.close(); } catch (Exception e) {}
		try { if (conn4 != null) conn4.close(); } catch (Exception e) {}
	}
%>
<% if (existe.equals("S")) { %>
<%@ include file="dashboard.jsp" %>
<% } %>