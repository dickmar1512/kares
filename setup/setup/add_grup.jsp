<%@ include file="../conectadb.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 

<%
	String s_modo 		= request.getParameter("f_modo");
	String s_nombre		= request.getParameter("f_nombre");
	String s_icono		= request.getParameter("f_icono");
	String s_id_grupo	= request.getParameter("f_id_grupo");
	int result = 0;	
	String s_id_area	= request.getParameter("f_id_area");
	
	if (s_modo.equals("I"))
	{			
		COMANDO = 	"Select * "+
					"from accesos_grupo "+
					"where id_grupo = '"+s_id_grupo+"' "; 
					//"where id_grupo = '"+s_id_area+"' || '"+s_id_grupo+"' "; 
					rset = stmt.executeQuery(COMANDO);
				    //out.print(COMANDO);
					if(rset.next())
					{%>
							<div align='center'>YA EXISTE ESE NUMERO EN LA LISTA</div>
							<meta http-equiv='Refresh' content='5; url=show.jsp?f_id_area=<%=s_id_area%>'>
					<%}
					else
					{
							COMANDO = 	"insert into accesos_grupo values ('"+s_id_grupo+"', '"+
										s_nombre+"', '"+
										s_icono+"') ";
										result	= 	stmt.executeUpdate(COMANDO); %>
                                        <br><br><br>
										<div align='center'>
                                        <font color="#FF0000" size="+3">.::SE HA INGRESADO EL GRUPO EXITOSAMENTE::..</font></div>
										<meta http-equiv='Refresh' content='2; url=show.jsp?f_id_area=<%=s_id_area%>'>
					<%}
	   }
	   else
	  {
			COMANDO="update accesos_grupo set "+
			        "nombre='"+s_nombre+"', "+
					"icono = '"+s_icono+"' "+
					"where id_grupo='"+s_id_grupo+"' ";
			result=stmt.executeUpdate(COMANDO);	
		%>	
            <br><br><br>
			<div align='center'><font color="#FF0000" size="+3">..::SE HA ACTUALIZADO EL GRUPO EXITOSAMENTE::..</font></div>
			<meta http-equiv='Refresh' content='2; url=show.jsp?f_id_area=<%=s_id_area%>'>
<%	   }
%>

<html>
<head>
	<link rel="stylesheet" media="screen" href="../style01.css" type="text/css">
	<link rel="stylesheet" media="print" href="../style02.css" type="text/css">
</head>

<body background="../imagenx/bgfondo.jpg" leftmargin=0 topmargin=0>
</body>
</html>
<%@ include file="../cierradb.jsp" %>

