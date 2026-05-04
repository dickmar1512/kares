<% //Codigo de seguridad a sesiones debe iniciar todo JSP
	
	HttpSession xsession 	= request.getSession (true);
	
	String id_area2 		= "";
	String id_personal_user = "";
	String s_ip    			= "";
	String lista_ip_user2	= "";
	String s_id_sesion 		= "";
	String id_doc 			= "";
	String accesos			= "";
	String hora 			= "";
	String fecha 			= "";
	String id_session 		= "";
	String s_igv			= "";
	String s_tipo_cambio	= "";
	String s_id_periodo		= (String) xsession.getValue("id_cont_user");
	String s_temp_punto     = "";  
	String s_punto			= "";
	
	String id_almacen_user  = (String) xsession.getValue("id_almacen_user");
	String sucursal_user	= (String) xsession.getValue("sucursal_user");

	Date DtActual01			= new Date( );
	id_area2				= (String) xsession.getValue("id_area");
	if( (id_area2==null)||(id_area2.equals("")) ) id_area2 = "88";

	id_personal_user		= (String) xsession.getValue("id_personal_user");
	if( (id_personal_user==null)||(id_personal_user.equals("")) ) id_personal_user = "X";

	s_id_sesion			= (String) xsession.getValue("id_session");
	s_ip				= s_ip = (request.getRemoteAddr().equals("0:0:0:0:0:0:0:1") ||   request.getRemoteAddr().equals("::1")) ?  "127.0.0.1" : request.getRemoteAddr();;	
	lista_ip_user2		= (String) xsession.getValue("lista_ip_user");
	accesos			    = (String) xsession.getValue("accesos")+" --- GEN"; //PAL PPR
	s_temp_punto		= (String) xsession.getValue("punto"); if(s_temp_punto==null) s_temp_punto="01";
	s_punto             = s_temp_punto;
	
	if(s_ip==null) s_ip	= request.getRemoteAddr();

	if (id_personal_user.equals("X"))
	{
		try{
			COMANDO =	"Insert into intruso ( "+
						"id_intruso, "+
						"id_area, "+
						"ip, "+
						"hora, "+
						"id_jsp, "+
						"id_personal, "+
						"tipo, "+
						"estado ) "+
						"values ( ?, ?, ?, sysdate(), ?, ?, '0', '0' ) ";
			conn = getConexion();				
			pstmt = conn.prepareStatement(COMANDO);
			pstmt.setLong(1, DtActual01.getTime());
			pstmt.setString(2, id_area2);
			pstmt.setString(3, s_ip);
			pstmt.setString(4, id_jsp);
			pstmt.setString(5, id_personal_user);
			upd = pstmt.executeUpdate();
			%>
			<jsp:forward page="../error.jsp?error=4"/>
			<%
		}catch(Exception e){
			out.println("ERROR: " + e.getMessage());
		}finally{ 
			cerrar(rset); cerrar(pstmt); cerrar(conn); 
			COMANDO = "";upd = 0;
		}
	}

	id_session 	= xsession.getId();

	if (!id_session.equals(s_id_sesion))
	{
		try{
			COMANDO =	"Insert into intruso ( "+
							"id_intruso, "+
							"id_area, "+
							"ip, "+
							"hora, "+
							"id_jsp, "+
							"id_personal, "+
							"tipo, "+
							"estado ) "+
							"values ( ?, ?, ?, sysdate(), ?, ?, '0', '0' ) ";
			conn = getConexion();
			pstmt = conn.prepareStatement(COMANDO);
			pstmt.setLong(1, DtActual01.getTime());
			pstmt.setString(2, id_area2);
			pstmt.setString(3, s_ip);
			pstmt.setString(4, id_jsp);
			pstmt.setString(5, id_personal_user);
			upd = pstmt.executeUpdate();
		%>
			<jsp:forward page="../error.jsp?error=3"/>
		<%  
		}catch(Exception e){
			out.println("ERROR: " + e.getMessage());
		}finally{ 
			cerrar(rset); cerrar(pstmt); cerrar(conn); 
			COMANDO = "";upd = 0;
		}
	}	

	try{
		COMANDO =	"select "+
						"date_format(sysdate(),'%d/%m/%Y') fecha, "+
						"date_format(sysdate(),'%H:%i:%s') hora, "+
						"ip, "+
						"date_format(sysdate(),'%Y%m%d%H%i%s') id_doc "+
					"from sessiones "+
					"where id_session = ? "+
					"and id_personal = ? ";
		conn = getConexion();			
		pstmt = conn.prepareStatement(COMANDO);
		pstmt.setString(1, s_id_sesion);
		pstmt.setString(2, id_personal_user);
		rset = pstmt.executeQuery();
		if (!rset.next())
		{
			try{				
				COMANDO2 =	"Insert into intruso ( "+
								"id_intruso, "+
								"id_area, "+
								"ip, "+
								"hora, "+
								"id_jsp, "+
								"id_personal, "+
								"tipo, "+
								"estado ) "+
								"values ( ?, ?, ?, sysdate(), ?, ?, '0', '0' ) ";
				conn2 = getConexion();				
				pstmt2 = conn2.prepareStatement(COMANDO2);
				pstmt2.setLong(1, DtActual01.getTime());
				pstmt2.setString(2, id_area2);
				pstmt2.setString(3, s_ip);
				pstmt2.setString(4, id_jsp);
				pstmt2.setString(5, id_personal_user);
				upd = pstmt2.executeUpdate();				
				%>
				<jsp:forward page="../error.jsp?error=1"/>
			    <%	
			}catch(Exception e){
				out.println("ERROR: " + e.getMessage());
			}finally{ 
				cerrar(rset2); cerrar(pstmt2); cerrar(conn2); 
				COMANDO2 = "";upd = 0;
			}	
		 }

		id_doc 	= rset.getString("id_doc");
		fecha 	= rset.getString("fecha");
		hora 	= rset.getString("hora");	
	}catch(Exception e){ 
		out.println("ERROR: " + e.getMessage());
	}finally{
		cerrar(rset); cerrar(pstmt); cerrar(conn);
		COMANDO = "";upd = 0;
	}

	if(accesos.indexOf(id_jsp)==-1)
	{
		COMANDO =	"Insert into intruso ( "+
						"id_intruso, "+
						"id_area, "+
						"ip, "+
						"hora, "+
						"id_jsp, "+
						"id_personal, "+
						"tipo, "+
						"estado ) "+
						"values ( ?, ?, ?, now(), ?, ?, '2', '0' ) ";
		conn = getConexion();
		pstmt = conn.prepareStatement(COMANDO);
		pstmt.setLong(1, DtActual01.getTime());
		pstmt.setString(2, id_area2);
		pstmt.setString(3, s_ip);
		pstmt.setString(4, id_jsp);
		pstmt.setString(5, id_personal_user);
		upd = pstmt.executeUpdate();
		cerrar(rset); cerrar(pstmt); cerrar(conn);
		COMANDO = "";upd = 0;
%>
	<jsp:forward page="../error.jsp?error=2"/>

<%  }

		if(!lista_ip_user2.trim().equals("*"))
		{
			if(lista_ip_user2.indexOf(s_ip)==-1)
			{
				COMANDO =	"Insert into intruso ( "+
								"id_intruso, "+
								"id_area, "+
								"ip, "+
								"hora, "+
								"id_jsp, "+
								"id_personal, "+
								"tipo, "+
								"estado ) "+
								"values ( ?, ?, ?, sysdate(), ?, ?, '3', '0' ) ";
				conn = getConexion();				
				pstmt = conn.prepareStatement(COMANDO);
				pstmt.setLong(1, DtActual01.getTime());
				pstmt.setString(2, id_area2);
				pstmt.setString(3, s_ip);
				pstmt.setString(4, id_jsp);
				pstmt.setString(5, id_personal_user);
				upd = pstmt.executeUpdate();
				cerrar(rset); cerrar(pstmt); cerrar(conn);
				COMANDO = "";upd = 0;
%>
             <jsp:forward page="../error.jsp?error=5"/>
<%  		}
		}

	COMANDO =	"update sessiones set "+
					"dt_acceso = now(), "+
					"id_jsp = ? "+
				"where id_session= ? "+
				"and id_personal = ? ";
    conn = getConexion();				
	pstmt = conn.prepareStatement(COMANDO);
	pstmt.setString(1, id_jsp);
	pstmt.setString(2, s_id_sesion);
	pstmt.setString(3, id_personal_user);
	upd = pstmt.executeUpdate();
	cerrar(rset); cerrar(pstmt); cerrar(conn);
	COMANDO = "";upd = 0;

	String	s_login		 = (String) xsession.getValue ("login");
	String s_passwd_user = (String) xsession.getValue ("password");
	
	String id_cont_user = (String) xsession.getValue ("id_cont_user");
	if( id_cont_user == null ) id_cont_user = "X";
	
	String id_nivel_user = (String) xsession.getValue ("id_nivel_user");
	if( id_nivel_user == null ) id_nivel_user = "X";
	
	//IGV
	COMANDO =	"select "+
					"valor "+
				"from valores "+
				"where id_valores = '001' ";
	conn = getConexion();				
	pstmt = conn.prepareStatement(COMANDO);			
	rset = pstmt.executeQuery();
	rset.next();
	s_igv = rset.getString("valor");
	cerrar(rset); cerrar(pstmt); cerrar(conn);
	COMANDO = "";
	
	COMANDO =	"select "+
					"valor "+
				"from valores "+
				"where id_valores = '002' ";	// cambio dolar
	conn = getConexion();				
	pstmt = conn.prepareStatement(COMANDO);			
	rset = pstmt.executeQuery();
	rset.next();
	s_tipo_cambio = rset.getString("valor");
	cerrar(rset); cerrar(pstmt); cerrar(conn);
	COMANDO = "";

	String s_cambio = "";
	COMANDO = "Select valor from valores where id_valores = '002' ";
	conn = getConexion();
	pstmt = conn.prepareStatement(COMANDO);
	rset = pstmt.executeQuery();
	if(rset.next())
	{
		s_cambio = rset.getString("valor");
	}
	cerrar(rset); cerrar(pstmt); cerrar(conn);
	COMANDO = "";
	
	String s_punto_imp = "";
	COMANDO = "Select impresion from puntos where punto = ? ";
	conn = getConexion();
	pstmt = conn.prepareStatement(COMANDO);
	pstmt.setString(1, s_punto);
	rset = pstmt.executeQuery();
	if(rset.next())
	{
		s_punto_imp = rset.getString("impresion");	if (s_punto_imp==null) s_punto_imp="";
	}
	cerrar(rset); cerrar(pstmt); cerrar(conn);
	COMANDO = "";
%>