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
	
	//String s_ini_horario	= "";
	//String s_fin_horario	= "";
	
	String tabla2			= (String) xsession.getValue("tabla");
	
	String id_almacen_user  = (String) xsession.getValue("id_almacen_user");
	String sucursal_user	= (String) xsession.getValue("sucursal_user");

	String s_incremento = "33";
	Date DtActual01			= new Date( );
	id_area2				= (String) xsession.getValue("id_area");
	if( (id_area2==null)||(id_area2.equals("")) ) id_area2 = "88";

	id_personal_user		= (String) xsession.getValue("id_personal_user");
	if( (id_personal_user==null)||(id_personal_user.equals("")) ) id_personal_user = "X";

	s_id_sesion			= (String) xsession.getValue("id_session");
	s_ip				= (String) xsession.getValue("ip");	
	lista_ip_user2		= (String) xsession.getValue("lista_ip_user");
	accesos			    = (String) xsession.getValue("accesos")+" --- GEN"; //PAL PPR
	s_temp_punto		= (String) xsession.getValue("punto"); if(s_temp_punto==null) s_temp_punto="01";
	s_punto             = s_temp_punto;
	
	if(s_ip==null) s_ip	= request.getRemoteAddr();

	if (id_personal_user.equals("X"))
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
						"values ( '"+DtActual01.getTime( )+"', '"+
						id_area2+"', '"+
						request.getRemoteAddr()+"', "+
						"sysdate(), '"+
						id_jsp+"', '"+
						id_personal_user+"', '0', '0' ) ";
		upd = stmt.executeUpdate(COMANDO);
%>
		<jsp:forward page="error.jsp?error=4"/>
<%  }

	id_session 	= xsession.getId();
	if (!id_session.equals(s_id_sesion))
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
						"values ( '"+DtActual01.getTime( )+"', '"+
						id_area2+"', '"+
						request.getRemoteAddr()+"', "+
						"sysdate, '"+
						id_jsp+"', '"+
						id_personal_user+"', '0', '0' ) ";
		upd = stmt.executeUpdate(COMANDO);
%>
		<jsp:forward page="error.jsp?error=3"/>
<%  } %>

<%
	COMANDO =	"select "+
					"date_format(now(),'%d/%m/%Y') fecha, "+
					"date_format(now(),'%H:%i:%s') hora, "+
					"ip, "+
					"date_format(now(),'%Y%m%d%H%i%s') id_doc "+
				"from sessiones "+
				"where id_session = '"+s_id_sesion+"' "+
				"and id_personal = '"+id_personal_user+"' ";
	rset = stmt.executeQuery( COMANDO );
	if (!rset.next())
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
						"values ( '"+DtActual01.getTime( )+"', '"+
						id_area2+"', '"+
						request.getRemoteAddr()+"', "+
						"now(), '"+
						id_jsp+"', '"+
						id_personal_user+"', '0', '0' ) ";
		upd = stmt.executeUpdate(COMANDO);
%>
		<jsp:forward page="error.jsp?error=1"/>
<%  }
		id_doc 	= rset.getString("id_doc");
		fecha 	= rset.getString("fecha");
		hora 	= rset.getString("hora");

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
						"values ( '"+DtActual01.getTime( )+"', '"+
						id_area2+"', '"+
						request.getRemoteAddr()+"', "+
						"now(), '"+
						id_jsp+"', '"+
						id_personal_user+"', '2', '0' ) ";
		upd = stmt.executeUpdate(COMANDO);
%>
	<jsp:forward page="error.jsp?error=2"/>

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
								"values ( '"+DtActual01.getTime( )+"', '"+
								id_area2+"', '"+
								request.getRemoteAddr()+"', "+
								"now(), '"+
								id_jsp+"', '"+
								id_personal_user+"', '3', '0' ) ";
				upd = stmt.executeUpdate(COMANDO);
%>
<jsp:forward page="error.jsp?error=5"/>
<%  		}
		}
%>
 
<%	
	COMANDO =	"update sessiones set "+
					"dt_acceso = now(), "+
					"id_jsp = '"+id_jsp+"' "+
				"where id_session= '"+s_id_sesion+"' "+
				"and id_personal = '"+id_personal_user+"' ";
	upd = stmt.executeUpdate( COMANDO );

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
	rset = stmt.executeQuery(COMANDO);
	rset.next();
	s_igv = rset.getString("valor");
	
	COMANDO =	"select "+
					"valor "+
				"from valores "+
				"where id_valores = '002' ";	// cambio dolar
	rset = stmt.executeQuery(COMANDO);
	rset.next();
	s_tipo_cambio = rset.getString("valor");


	String s_cambio = "";
	COMANDO = "Select valor from valores where id_valores = '002' ";
	rset = stmt.executeQuery(COMANDO);
	if(rset.next())
	{
		s_cambio = rset.getString("valor");
	}
	
	String s_punto_imp = "";
	COMANDO = "Select impresion from puntos where punto = '"+s_punto+"' ";
	rset = stmt.executeQuery(COMANDO);
	if(rset.next())
	{
		s_punto_imp = rset.getString("impresion");	if (s_punto_imp==null) s_punto_imp="";
	}

	//out.print(s_ip);
%>