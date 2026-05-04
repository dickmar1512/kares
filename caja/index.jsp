<%@ include file="conectadb.jsp"%>
<html>
	<title>..::Setup::..</title>
<% 
	String	s_ip 			= "";
	String	accesos			= "001"; // primer acceso
	String	s_id_session 	= "";
		
	//Inicio para identificar sesion
	HttpSession xsession = request.getSession (true);
	
	s_id_session 				= xsession.getId() ;
	s_ip						= request.getRemoteAddr();
	
	String s_id_jsp				= "";
	String id_area				= "01"; 
	xsession.putValue("id_area",id_area);
	Date DtActual 				= new Date( );
	String tabla				= "areas_usuarios";  
	xsession.putValue("tabla", tabla );
	String s_login				= request.getParameter("f_login");
	String s_passwd				= request.getParameter("f_passwd");

	String s_id_personal		= "";
	String existe				= "";
	String s_id_cont_user 		= "2017";
	String s_id_almacen_user	= "";
	String s_id_nivel_user		= "";
	String s_sucursal_user		= "";
	String lista_ip_user		= "";
	String s_fecha				= "";
	String s_punto		= "";


	if( (s_login==null)||(s_passwd==null) )
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
						"values ( '"+DtActual.getTime( )+"', '"+
						id_area+"', '"+
						request.getRemoteAddr()+"', "+
						"now(), '"+
						s_id_jsp+"', 'X', '0', '0' ) ";
       upd = stmt.executeUpdate(COMANDO);
%>	
		<jsp:forward page="index.html"/>
<%	}

	//comando para verificar que exista en datos personales
	COMANDO = 	"Select "+
					"id_personal "+
				"from datos_personales "+
				"where upper(login) = upper(?) "+
				"and upper(passwd) = upper(?) ";
				//"and passwd = md5hash(upper(?)) ";
		//out.print(COMANDO+"<br>");
	pstmt = conn.prepareStatement(COMANDO);
	pstmt.setString(1,s_login);
	pstmt.setString(2,s_passwd);
	rset = pstmt.executeQuery();
	if(rset.next())
	{
		s_id_personal = rset.getString("id_personal");
		
		//comando que verifica que tenga acceso al menu 
		COMANDO = 	"Select * "+
					"from "+tabla+" "+
					"where id_personal = '"+s_id_personal+"' "+
					"and    id_area = '"+id_area+"' ";
		rset = stmt.executeQuery(COMANDO);
//		out.print("<br>"+COMANDO+"<br>");
		if(rset.next())
		{
			existe = "S";
			
			xsession.putValue("id_session",s_id_session);
			xsession.putValue("login",s_login ); 
			xsession.putValue("ip",s_ip ); 
			xsession.putValue("punto",rset.getString("punto")); 
			
			COMANDO = 	"select "+
							"ip "+
						"from sessiones "+
						"where id_session = '"+s_id_session+"' ";
						//"and id_personal = '"+s_id_personal+"' ";
			rset = stmt.executeQuery( COMANDO );
			if(!rset.next())
			{
				COMANDO =	"Insert into sessiones ( "+
								"id_personal, "+
								"id_session, "+
								"dt_ingreso, "+
								"dt_acceso, "+
								"ip, "+
								"id_jsp ) "+
								"values ( '"+
								s_id_personal+"', '"+
								s_id_session+"', "+
								"now(), "+
								"now(), '"+
								s_ip+"', '"+
								s_id_jsp+"' ) ";
				 upd = stmt.executeUpdate(COMANDO);
				//out.print("<br> 1 "+COMANDO+"<br>");
				
			}
			else
			{

				COMANDO =	"update sessiones set "+
								"dt_acceso = now(), "+
								"id_jsp = '"+s_id_jsp+"' "+
							"where id_personal = '"+s_id_personal+"' "+
							"and  id_session= '"+s_id_session+"' ";
				upd = stmt.executeUpdate( COMANDO );
				//out.print("<br> 2 "+COMANDO+"<br>");	
			}
		
			xsession.putValue("id_personal_user",s_id_personal);
			
		}
		else{ // si no tiene acceso en adm_usuarios 

			COMANDO =	"Insert into intruso ( "+
							"id_intruso, "+
							"id_area, "+
							"ip, "+
							"hora, "+
							"id_jsp, "+
							"id_personal, "+
							"tipo, "+
							"estado ) "+
							"values ( '"+DtActual.getTime( )+"', '"+
							id_area+"', '"+
							request.getRemoteAddr()+"', "+
							"now(), '"+
							s_id_jsp+"', '"+
							s_id_personal+"', '2', '0' ) ";
			upd = stmt.executeUpdate(COMANDO);
			//	out.print("<br> 3 "+COMANDO+"<br>");
%>
			<meta http-equiv="REFRESH" content="4; url=index.jsp"> 
			<font color="#FF3838"><div align="center"><b>Acceso Denegado. aquí</b></div></font>
<%
		}
		
	}
	else
	{ // si no hay ninguno con su login y su password 

		COMANDO =	"Insert into intruso ( "+
						"id_intruso, "+
						"id_area, "+
						"ip, "+
						"hora, "+
						"id_jsp, "+
						"id_personal, "+
						"tipo, "+
						"estado ) "+
						"values ( '"+DtActual.getTime( )+"', '"+
						id_area+"', '"+
						request.getRemoteAddr()+"', "+
						"now(), '"+
						s_id_jsp+"', '"+
						s_id_personal+"', '1', '0' ) ";
		upd = stmt.executeUpdate(COMANDO);
		//out.print("<br> 4 "+COMANDO+"<br>");
%>
		<meta http-equiv="REFRESH" content="4; url=index.jsp"> 
		<font color="#FF3838"><div align="center"><b>Password Incorrecto, Vuelva a intentarlo.</b></div></font>
<%	}

//comando para pintar los accesos
	COMANDO = 	"Select "+
					"a.id_acceso "+
				"from accesos_usuarios a, accesos_botones b "+
				"where a.id_acceso = b.id_acceso "+
				"and b.id_area = '"+id_area+"' "+
				"and a.id_personal = '"+s_id_personal+"' ";
	rset = stmt.executeQuery(COMANDO);
	//out.print(COMANDO);
	while(rset.next())
	{
		accesos += rset.getString("id_acceso")+" "; 
	}
	xsession.putValue("accesos",accesos);


	COMANDO = 	"Select "+
					"punto, "+
					"nivel, "+
					"ip_acceso ip "+
				"from "+tabla+" "+  //adm_usuarios 
				"where id_personal = '"+s_id_personal+"' "+
				"and id_area = '"+id_area+"' ";
	//out.print(COMANDO);			
	rset = stmt.executeQuery(COMANDO);
	if(rset.next())
	{
		s_id_nivel_user		=	rset.getString("nivel");

		lista_ip_user		=	rset.getString("ip");
		s_punto			=   rset.getString("punto");
		
		COMANDO	= 	"select sucursal, id_almacen from puntos where punto = '"+s_punto+"' ";
		rset = stmt.executeQuery(COMANDO);
		if (rset.next())
		{
			s_sucursal_user	=   rset.getString("sucursal");
			s_id_almacen_user	=	rset.getString("id_almacen");		if ( s_id_almacen_user==null) s_id_almacen_user="";
		}
		
		if( ! lista_ip_user.trim().equals("*") )
		{	
				if(lista_ip_user.indexOf(s_ip)==-1)
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
									"values ( '"+DtActual.getTime( )+"', '"+
									id_area+"', '"+
									request.getRemoteAddr()+"', "+	
									"now(), '"+
									s_id_jsp+"', '"+
									s_id_personal+"', '3', '0' ) ";
					upd = stmt.executeUpdate(COMANDO); %>
					
					<meta http-equiv="REFRESH" content="0; url=index.html"> 
					<font color="#FF3838"><div align="center"><b>Pc con acceso restinguido.</b></div></font>
					
<%  			}
			}

		xsession.putValue("id_cont_user",s_id_cont_user);
		xsession.putValue("id_almacen_user",s_id_almacen_user);
		xsession.putValue("nivel",s_id_nivel_user);
		xsession.putValue("id_nivel_user",s_id_nivel_user);
		xsession.putValue("sucursal_user",s_sucursal_user);
		xsession.putValue("lista_ip_user",lista_ip_user);
		xsession.putValue("punto",s_punto);
		xsession.putValue("password",s_passwd);

	}

%>
<%if(existe.equals("S"))
  {%>
<%@ include file="menu.jsp" %>
<%}%>
<%@ include file="cierradb.jsp" %>
