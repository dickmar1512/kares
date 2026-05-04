<%@ include file="../conectadb.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
	String s_id_area = request.getParameter("f_id_area");
	String s_id_grupo = "";
	int contador = 0;
	String s_nombre_area = "";
%>

<html>
<head>
	<link rel="stylesheet" media="screen" href="../css/style01.css" type="text/css">
	<link rel="stylesheet" media="print" href="../css/style02.css" type="text/css">
	<script>
	function validar()
	{
		if(!confirm("¿Está seguro de borrar?"))
		{ history.go(-2);
		}else{
			return true;
		}
	}
	</script>
</head>
<body leftmargin=0 topmargin=0><br><br><br>
<%
	COMANDO = "Select "+
					"upper(nombre) as nombre "+
					"from acceso_main "+
					"where id_area = '"+s_id_area+"' ";
					rset = stmt.executeQuery(COMANDO);
					rset.next();
					s_nombre_area = rset.getString("nombre");
%>

<body background="../imagenx/bgfondo.jpg" leftmargin=0 topmargin=0>
<table align="center">
	<tr>
		<th class=titulo colspan="4">GRUPOS DE <%= s_nombre_area %> [<a href="show_accesos.jsp?f_id_area=<%=s_id_area%>">Retornar</a>]</th>
	</tr>
	<tr align="center">
		<td colspan="4" align="center">
			<a href="form_grup_add.jsp?f_id_area=<%=s_id_area%>&f_modo=I">[Añadir]</a>
		</td>
	</tr>
	<tr align="center">
		<th align="center">#</th>
		<th align="center">Nombre</th>
		<th align="center" colspan="2">Icono</th>
	</tr>
<%
		COMANDO = 	"select "+
						"icono, "+
						"nombre, "+
						"id_grupo "+
					"from accesos_grupo "+
					"where substr(id_grupo,1,2) = '"+s_id_area+"' "+
					"order by id_grupo ";
		rset	=	stmt.executeQuery(COMANDO) ;
	//out.print(COMANDO);
		while(rset.next())	
		{
		contador++;
%>
		<tr>
			<td align="center">
				<%=contador%>
			</td>
			<td>
				<%=rset.getString("nombre")%>
			</td>
			<td>
				<%=rset.getString("icono")%>
			</td>
            <td align="center">
				[<a href="form_grup_add.jsp?f_id_grupo=<%=rset.getString("id_grupo")%>&&f_nombre=<%=rset.getString("nombre")%>&&f_icono=<%=rset.getString("icono")%>&&f_modo=U">Editar</a>]
			</td>	

<!--		<td align="center">
				[<a href="del.jsp?f_id_area=<%=rset.getString("id_grupo")%>">eliminar</a>]
			</td>				
		</tr>
-->
<% }%>
	<tr>
		<td colspan="4"><hr></td>
	</tr>

</table>
</body>
</html>

<%@ include file="../cierradb.jsp" %>
