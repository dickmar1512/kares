<%@ include file="../conectadb.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<html>
<head>
	<link rel="stylesheet" media="screen" href="../style01.css" type="text/css">
	<link rel="stylesheet" media="print" href="../style02.css" type="text/css">
<script language="JavaScript" >
function validar()
{
if (( document.datos1.f_nombre.value!="")
   )
	{
		document.datos1.submit();
	}
	else
	{
		alert("Ingresar los datos necesarios.")
	}
}
</script>
</head>
<body background="../imagenx/bgfondo.jpg" leftmargin=0 topmargin=0>
<%  
	String s_modo			= request.getParameter("f_modo");
	String s_id_grupo		= "";//request.getParameter("f_id_grupo");
    String s_id_area        =  "";//request.getParameter("f_id_area"); if(s_id_area==null){s_id_grupo.substring(0,2);};
	String s_numero         = "";
	String s_icono			= "";
	String s_nombre			= "";
	String s_nombre_area	= "";
	
	if(s_modo.equals("I"))
	{
		s_id_area = request.getParameter("f_id_area");
		 
	    COMANDO = "select lpad(max(substr(id_grupo, 3,2))+1,2,0) as numero "+
				  "from accesos_grupo "+
				  "where substr(id_grupo,1,2) = '"+s_id_area+"' ";
	    //out.print(COMANDO);
		rset = stmt.executeQuery(COMANDO);
		rset.next();
		s_numero = rset.getString("numero");
		if(s_numero == null )  s_numero = "01";
		s_id_grupo =s_id_area+s_numero;
	}
 	else
	{
		s_nombre	= request.getParameter("f_nombre");
		s_icono		= request.getParameter("f_icono");
		s_id_grupo	= request.getParameter("f_id_grupo");
		s_id_area   = s_id_grupo.substring(0,2);
	}

	COMANDO = 	"Select "+
				"nombre "+
				"from acceso_main "+
				"where id_area = '"+s_id_area+"' ";
				rset = stmt.executeQuery(COMANDO);
				//out.print(COMANDO);
				if(rset.next())
				{				
				 s_nombre_area = rset.getString("nombre");
				}
				
				
%>

<form action="add_grup.jsp" method="post" name="datos1" >
<table border="0" cellspacing="1" cellpadding="1" align="center">
<tr align="center">
	<th class=titulo colspan="2">Añadir Grupos en <%=s_nombre_area%> [<a href="show.jsp?f_id_area=<%=s_id_area%>">Retornar</a>]</th>
</tr>
<tr align="center">
	<td align="left">
		ID Grupo : 
	</td>
	<td align="left">
		<%= s_id_grupo %>
		<input type="hidden" name="f_id_grupo" value="<%=s_id_grupo%>" size="2" maxlength="2">
	</td>
</tr>

<tr align="left">
	<td>
		Nombre Grupo :
	</td>
	<td align="left">
		<input type="text" name="f_nombre" value="<%=s_nombre%>" size="30" maxlength="30">
	</td>
</tr>
<tr align="left">
	<td>
		Icono :
	</td>
	<td align="left">
		<input type="text" name="f_icono" value="<%=s_icono%>" size="40" maxlength="40">
	</td>
</tr>
<tr align="center" >
	<td align="center" colspan="2" >
		<input type="button" name="añadir" value="añadir" onClick="validar()">
		<input type="Hidden" name="f_id_area" value="<%=s_id_area%>">
        <input type="Hidden" name="f_modo" value="<%=s_modo%>">
	</td>
</tr>

</table>
</form>
</body>

</html>

<%@ include file="../cierradb.jsp" %>
