<%@ include file="../conectadb.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
   String s_tipo_doc = request.getParameter("f_tipo_doc");
   String s_numdoc   = request.getParameter("f_numdoc");
   int cont = 0;
   String url = "";
   
   if(s_tipo_doc.equals("11"))
   {
    url="print_orden.jsp";
   }   
   if(s_tipo_doc.equals("35"))
   {
    url="print_ticket_servicio2.jsp";
   }
  if(s_tipo_doc.equals("34"))
   {
     url="print_nota_venta.jsp";
   }
   if(s_tipo_doc.equals("26"))
   {
     url="print_ticket_factura.jsp";
   }
    if(s_tipo_doc.equals("39"))
   {
     url="print_factura_electronica.jsp";
   }
    if(s_tipo_doc.equals("41"))
   {
     url="print_boleta_electronica.jsp";
   }
%>
<!DOCTYPE html>
<html>
  <head>
    <title>..::Buscar Doc::..</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="apple-mobile-web-app-capable" content="yes"/>
    <!--<link href="css/jquery-ui-themes.css" type="text/css" rel="stylesheet"/>-->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.css">
    <link href="css/axure_rp_page.css" type="text/css" rel="stylesheet"/>
    <link href="css/styles2.css" type="text/css" rel="stylesheet"/>
    <link href="css/styles1.css" type="text/css" rel="stylesheet"/>
    <script src="js/jquery-1.7.1.min.js"></script>
    <script src="js/jquery-ui-1.8.10.custom.min.js"></script>
    <script src="js/prototypePre.js"></script>
    <script src="js/document.js"></script>
    <script src="js/prototypePost.js"></script>
    <script src="js/data.js"></script>
    <script type="text/javascript">
      $axure.utils.getTransparentGifPath = function() { return 'images/transparent.gif'; };
    </script>
  </head>
  <body>
    <div id="base" class="">
      <!-- Unnamed (Rectangle) -->
      <div id="u7" class="ax_default box_1">
        <div id="u7_div" class=""></div>
      </div>
      <!-- Unnamed (Rectangle) -->
      <div id="u8" class="ax_default heading_1">
        <div id="u8_div" class=""></div>
        <div id="u8_text" class="text ">
          <p><span>Documentos encontrados(<%=s_tipo_doc%>)</span></p>
        </div>
      </div>
      <!-- Unnamed (Table) -->
      <div id="u9" class="ax_default">  
        <table width="100%" border="1" cellspacing="0" cellpadding="1">
          <tbody>
          <tr class="active">
            <th>#</th>
            <th>Cliente</th>
            <th>RUC/DNI</th>
            <th>Comprobante</th>
            <th>Fecha</th>
            <th>Total</th>
          </tr>
        <%
          COMANDO ="select id_mov_vnt,id_personal, "+
                   "(case when tipo_doc = '39' then razon  else nombre(id_personal) end)  nombre, "+
                   "(case when tipo_doc = '39' then ruc else dni(id_personal) end) docpersona,"+
                   "date_format(fecha,'%d/%m/%Y %H:%i') fecha,  "+
                   "concat(nom_doc3(tipo_doc),' ',serie,'-',lpad(numdoc,7,0)) doc, total "+
                   "from vent_registro "+
                   "where tipo_doc = '"+s_tipo_doc+"' "+
                   "and numdoc = '"+s_numdoc+"' ";
          //out.print(COMANDO);         
          rset = stmt.executeQuery(COMANDO);  
          while(rset.next())
          {cont++;%>
            <tr class="success">
              <td><%=cont%></td>
              <td><a href="<%=url%>?f_id_mov_vnt=<%=rset.getString("id_mov_vnt")%>">
                <%=rset.getString("nombre")%></a>
              </td>
              <td><%=rset.getString("docpersona")%></td>
              <td><%=rset.getString("doc")%></td>
              <td><%=rset.getString("fecha")%></td>
              <td><%=rset.getString("total")%></td>
            </tr>
        <%  }       
        %>
        </tbody>
        </table>
      </div>    
    </div>
  </body>
</html>
