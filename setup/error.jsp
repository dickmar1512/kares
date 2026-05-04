<html>
	<head>
		<meta http-equiv="refresh" content="10; url=index.html">
	</head>
<body bgcolor="#FDFDFD">
<% String error = request.getParameter("error"); %>
<% if( error.equals("1") )
 	{  %>
	<font color="#FF3838"><div align="center">Terminó la Sesión.</div></font>
<%	}
if( error.equals("2") )
	{ %>
	<font color="#FF3838"><div align="center"> error 2 Usted No Tiene Acceso.</div></font>
<%	}
if( error.equals("3") )
	{ %>
	<font color="#FF3838"><div align="center">Acceso No Autorizado.</div></font>
<%	}
if( error.equals("4") )
	{ %>
	<font color="#FF3838"><div align="center">ALERTA!!!! Acceso No Autorizado.</div></font>
<%	}
if( error.equals("5") )
	{ %>
	<font color="#FF3838"><div align="center">ALERTA!!!! Esta Maquina No Tiene Acceso.</div></font>
<%	} 
if( error.equals("6") )
	{ %>
	<font color="#FF3838"><div align="center">El Voucher No Existe.</div></font>
<%	} %>
</body>
</html>

