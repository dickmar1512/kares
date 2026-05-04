<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%	int z;
	String id_detalle	= "";
	String x_punto		= "";
	String x_log_caj	= "";
	String x_log_dig	= "";
	String x_fec		= "";
	String x_cta		= "";
	String x_doc 		= "";
	String x_doc2 		= ""; //para el codigo qr
	String x_pac 		= "";
	String s_dni        = "";
	String s_direc      = "";
	String x_nhc 		= "";
	String x_codafi	 	= "";
	String x_paq		= "";
	String id_atencion	= "";
	String atencion		= "";
	String forma_pago	= "";
	String vuelto		= "";
	String s_terminal   = "";
	String codgs        = "";
	String s_medico     = "";
	String s_copa_porc	= "";	

	String 	tipcop		= "";
	String	sumcop		= "";
	String	sumcob		= "";
	String	sumdsc		= "";
	String	sumtot		= "";
	String 	sumvv		= "";
	String 	sumbi		= "";
	String  sumigv      = "";

	String	franquicia	= "0";
	String s_fecha = "";
	
	int x;
	String hash = "";
	String qr   = "";
	
	//	 Datos de la venta.
    try{
		COMANDO	=	"select "+
						"	ip_impresion, "+
						"	nombre(id_personal) pac, "+
						"	dni(id_personal) dni, "+
						"	direccion(id_personal) direc, "+
						"	concat(serie, '-',  lpad(numdoc,7,0)) doc, "+
						"	concat(serie, '|',  lpad(numdoc,7,0)) doc2, "+
						"	id_docimp, 	"+
						"	tipo_doc,		"+
						"	id_vnt_ref,	"+
						"	upper(razon) razon,	"+
						"	concat('Usuario: ',login(id_personal_user),' ',' - Caja: ',nom_punto('"+s_punto+"')) log_caj, "+
						"	concat('Dig: ',ifnull(login(id_personal_dig),login(id_personal_user)),' Importe en Soles')  log_dig, "+
						"	date_format(fecha, '%d/%m/%Y %H:%i')  fec, "+
						"	punto, "+
						"	(case cod_afi when null then null else concat('Cod. GS:', cod_afi) end) cod_afi,	"+
						"	(case nhc(id_personal) when null then 'Sin HC.' else nhc(id_personal) end) nhc, 		"+
						"	ifnull(id_atencion,0) id_atencion, serialTerminal(punto) AS TERMINAL,  "+
						" 	date_format(fecha, '%d/%m/%Y %H:%i') as fecha2, "+
						"   ' ' cod "+
					"from vent_registro "+
					"where id_mov_vnt = '"+s_id_mov_vnt+"' ";
        
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset	= pstmt.executeQuery();	

		if ( rset.next() )
		{
			//s_ip_print	= rset.getString("ip_impresion");	if ( s_ip_print ==null) 	s_ip_print = "";			
			//out.print("ipprintsaco="+ip_print);
			s_id_docimp = rset.getString("id_docimp");		if ( s_id_docimp ==null) 	s_id_docimp = "";
			s_tipo_doc	= rset.getString("tipo_doc");		if ( s_tipo_doc ==null) 	s_tipo_doc = "";
			x_doc		= rset.getString("doc");
			x_doc2      = rset.getString("doc2");			
			x_punto		= rset.getString("punto");			
			x_pac		= rset.getString("pac");
			s_dni       = rset.getString("dni");
			s_direc     = rset.getString("direc");			if ( x_paq==null)			x_paq	= "";
			x_codafi	= rset.getString("cod_afi");		if ( x_codafi==null)		x_codafi = "";
			codgs = rset.getString("cod");if ( codgs==null)		codgs = "";
			x_nhc		= rset.getString("nhc");			if ( x_nhc==null)			x_nhc = "";			
			//x_log_caj	= rset.getString("log_caj");		
			x_log_dig	= rset.getString("log_dig");		if ( x_log_dig==null) 		x_log_dig = "";
			x_fec		= rset.getString("fec");			
			id_detalle= rset.getString("id_vnt_ref");		if ( id_detalle==null) id_detalle="";
			s_razon     = rset.getString("razon"); if(s_razon==null) s_razon = x_pac;
			if ( id_detalle.equals("") ) { id_detalle = s_id_mov_vnt;}				
			//if ( s_ip_print.equals("")) { s_ip_print=s_ip; }
			id_atencion = rset.getString("id_atencion");	
			s_terminal = rset.getString("TERMINAL");
			s_fecha = rset.getString("fecha2");
		}
    }catch (SQLException e) {
        out.println("Error de SQL: " + e.getMessage());
        e.printStackTrace();
    }finally{
        cerrar(rset,pstmt,conn);
    }   	 
    

	if ( !id_atencion.equals("") )
    {
        try {
            COMANDO	=	"select "+
                        " nro_atencion "+
                    "from atencion "+
                    "where id_atencion = '"+id_atencion+"' ";
            conn = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            rset	=	pstmt.executeQuery();
            if ( rset.next() )
            {
                atencion = "Nro.Atenc. " + rset.getString("nro_atencion") + " ";
            }
        }catch (SQLException e) {
            out.println("Error de SQL: " + e.getMessage());
            e.printStackTrace();
        }finally{
            cerrar(rset,pstmt,conn);
        }   	    
    }
		
	 String band1 = "0";
	
	//pinta el medico
    try {
	    COMANDO =   "Select  "+					
				    "ifnull(nombre(id_medico_ser),nombre(id_medico_rec)) med,	"+	
				    " ifnull(copago_orig,0) copa_porc "+
				"from 	vent_regdet   "+
				"where	id_mov_vnt = '"+id_detalle+"' ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery(); 
        while(rset.next())
        {				
            s_medico= rset.getString("med");
            s_copa_porc= rset.getString("copa_porc");
        }
    }catch (SQLException e) {
        out.println("Error de SQL: " + e.getMessage());
        e.printStackTrace();
    }finally{
        cerrar(rset,pstmt,conn);
    }   	 	
	//*************
    try {
	    COMANDO ="Select  "+
			    "ifnull(sum(ifnull(valor_venta,0)*((100+porc_igv)/100)),'0')	vv, 	"+
			    "ifnull(sum(ifnull(base_imp,0)*((100+porc_igv)/100)),'0')	bi, 	"+
			    "ifnull(sum(ifnull(descuento,0)*((100+porc_igv)/100 )),'0') 	descuento, 	"+
			    "ifnull(sum(ifnull(cobertura,0)*((100+porc_igv)/100)),'0') cobertura, 	"+
			    "ifnull(sum(copago),0 ) 	copago, 	"+
			    "ifnull(sum(ifnull(tipo_copago,0)),'0') tipocop, "+
			 "ifnull(sum(ifnull(total,0)),'0') total, "+
			 "round(ifnull(sum(ifnull(igv,0)),'0'),2) igv "+
			 "from 	vent_regdet   "+
			 "where	id_mov_vnt = '"+id_detalle+"' ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery(); 
        while(rset.next())
        {	
            tipcop	= rset.getString("tipocop");
            sumvv	= rset.getString("vv");
            sumcop	= rset.getString("copago");
            sumcob	= rset.getString("cobertura");
            sumdsc	= rset.getString("descuento");
            sumtot	= rset.getString("total");
            sumigv 	= rset.getString("igv");
            band1 	= "1";
        }
    }catch (SQLException e) {
        out.println("Error de SQL: " + e.getMessage());
        e.printStackTrace();
    }finally{
        cerrar(rset,pstmt,conn);
    }   

	band1 = "0";

	if(band1.equals("0")){		
		try {
            COMANDO =	"Select  "+
                            "valor_venta as	vv, 	"+
                            "base_imp as	bi, 	"+
                            "descuento as 	descuento, 	"+
                            "cobertura as 	cobertura, 	"+
                            "copago as 	copago, 	"+
                            "total as 	total 		"+
                        "from 	vent_registro   "+
                        "where	id_mov_vnt = '"+id_detalle+"' ";
                        
            conn = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            rset = pstmt.executeQuery();
            while(rset.next())
            {	
                //tipcop	= rset.getString("tipocop");
                sumvv	= rset.getString("vv");
                sumbi	= rset.getString("bi");
                sumcop	= rset.getString("copago");
                sumcob	= rset.getString("cobertura");
                sumdsc	= rset.getString("descuento");    
                sumtot	= rset.getString("total");
            }
        }catch (SQLException e) {
            out.println("Error de SQL: " + e.getMessage());
            e.printStackTrace();
        }finally{
            cerrar(rset,pstmt,conn);
        }   
    }	

    String numtxt = "";	  
    numtxt = sumtot ;
    String total_letras = "";	

	//pinta total en letras
    try {
		COMANDO = 	"Select "+
						" numtxt('"+numtxt+"') tota_letra "+ 
					"from dual ";
		conn = getConexion();
		pstmt = conn.prepareStatement(COMANDO);
		rset = pstmt.executeQuery();
		if ( rset.next() )
		{
		  total_letras = "Son: "+rset.getString("tota_letra")+" Soles."; 
		}
    }catch (SQLException e) {
        out.println("Error de SQL: " + e.getMessage());
        e.printStackTrace();
    }finally{
        cerrar(rset,pstmt,conn);
    }   

%>
    <div class="ticket-container">
        <center class="no-print">
            <button class="btn-print" onclick="window.print()">
                <i class="fas fa-print"></i> Imprimir Orden
            </button>
        </center>

        <div class="header">
            <img src="../../assets/images/logo.jpg" class="logo" />
            <h1 class="company-name">INVERSIONES MJGL E.I.R.L</h1>
            <p class="company-info">Calle Pevas N° 219</p>
            <p class="company-info">Iquitos - Maynas - Loreto</p>
        </div>

        <div class="order-title-box">
            <span class="ruc">RUC: 20541177281</span>
            <span class="order-type">ORDEN DE VENTA</span>
            <span class="order-number"><%=x_doc%></span>
        </div>

        <div class="info-section">
            <div class="info-row">
                <span class="info-label">FECHA EMISIÓN:</span>
                <span><%=x_fec%></span>
            </div>
            <div class="info-row">
                <span class="info-label">SEÑOR(ES):</span>
                <span><%=x_pac%></span>
            </div>
            <div class="info-row">
                <span class="info-label">NRO. DOC:</span>
                <span><%=s_dni%></span>
            </div>
            <div class="info-row">
                <span class="info-label">DIRECCIÓN:</span>
                <span><%=s_direc%></span>
            </div>
        </div>

        <table class="items-table">
            <thead>
                <tr>
                    <th class="col-desc">Descripción</th>
                    <th class="col-qty">Cant.</th>
                    <th class="col-price">P.U.</th>
                    <th class="col-total">Total</th>
                </tr>
            </thead>
            <tbody>
                <%
                   int itm = 0;
                   try {
                   COMANDO ="Select "+
                            "cantidad,	"+	
                            "glosa, ifnull(presentacion(id_articulo),'') presen, "+						
                            "round(valor_venta*((100+porc_igv)/100),2)	vv,		"+
                            "round((valor_venta*((100+porc_igv)/100))/cantidad,2) vu,		"+
                            "round(base_imp*((100+porc_igv)/100),2)	bi,		"+
                            "round(ifnull(descuento,0)*((100+porc_igv )/100),2) dsc,	"+
                            "round(ifnull(cobertura,0)*((100+porc_igv)/ 100),2)	cob,	"+
                            "round(ifnull(copago,0),2)	cop, "+
                            "round(total,	2) tota,	"+
                            "'' nomcop	"+
                        "from vent_regdet "+
                        "where id_mov_vnt = '"+id_detalle+"' "+
                        "order by orden ";

                   conn = getConexion();
                   pstmt = conn.prepareStatement(COMANDO);
                   rset = pstmt.executeQuery();
                   while(rset.next()) { 
                       itm++;
                %>
                <tr>
                    <td class="col-desc"><%=rset.getString("glosa")%></td>
                    <td class="col-qty"><%=rset.getString("cantidad")%></td>
                    <td class="col-price"><%=rset.getString("vu")%></td>
                    <td class="col-total"><%=rset.getString("tota")%></td>
                </tr>
                <% } 
                }catch (SQLException e) {
                    out.println("Error de SQL: " + e.getMessage());
                    e.printStackTrace();
                }finally{
                    cerrar(rset,pstmt,conn);
                }  %>
            </tbody>
        </table>

        <div class="totals-section">
            <div class="total-row">
                <span class="total-label">Sub Total:</span>
                <span class="total-value">S/ <%=sumbi%></span>
            </div>
            <div class="total-row">
                <span class="total-label">Descuento:</span>
                <span class="total-value">S/ 0.00</span>
            </div>
            <div class="total-row grand-total">
                <span class="total-label">TOTAL A PAGAR:</span>
                <span class="total-value">S/ <%=sumtot%></span>
            </div>
        </div>

        <div class="letras">
            <%=total_letras%>
        </div>

        <div class="footer-note">
            SERVICIOS PRESTADOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA
        </div>

        <div class="user-info">
            <%=x_log_caj%>
        </div>
    </div>