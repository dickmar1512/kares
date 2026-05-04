<%
	//--------------------------------------------------//
	// Este JSP es usado para teminar sesiones y salir	//
	// Declara una session								//
	//--------------------------------------------------//
	
	HttpSession xsession = request.getSession (true);

	//------------------------------------------------------------------------------//	
	// Todos los campos que se cargan en sesion, aqui son cargados con "" (vacio)	//
	// Luego acaba la sesion y buenve a la pantalla de ingreso						//
	//------------------------------------------------------------------------------//
	
	xsession.putValue("s_id_sesion","");
	xsession.putValue("id_personal_user","");
	xsession.putValue("id_cont_user","");
	xsession.putValue("id_nivel_user","");
	xsession.putValue("contabiliza_user","");
	xsession.putValue("id_almacen_user","");
	xsession.putValue("id_sector_user","");
	xsession.putValue("id_compras_user","");
	xsession.putValue("titulo_art","");
	xsession.putValue("login","") ; 
	xsession.putValue("ip","") ; 
	xsession.putValue("accesos","");
	xsession.putValue("id_area","");	
	xsession.putValue("lista_ip_user","");
	xsession.invalidate();
%>

<html>
<head>
	<link rel="stylesheet" media="screen" href="../css/style01.css" type="text/css">
	<meta http-equiv='REFRESH' content='2; url=../index.jsp'>
</head>
<body bgcolor="#FFFFFF">
<br>
<br><br>
<center><font size="+1" color="#0035BC">Usted Acaba de Salir del Sistema</font></center>
</body>
</html>

