<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<script src="../../plugins/jquery/jquery.min.js"></script>
<%	
    int z;
    //String s_id_mov_vnt = request.getParameter("f_id_mov_vnt");
	String id_detalle	= "";
	String x_punto		= "";
	String x_log_caj	= "";
	String x_log_dig	= "";
	String x_fec		= "";
	String x_cta		= "";
	String x_doc 		= "";
	String x_doc2 		= "";
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
	//String s_ip_print   = "";
	//String s_id_docimp  = "";
	//String s_tipo_doc   = "";
	String s_razon      = "";

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
	String s_mesa = "";
	
	int x;
	int hora2 = 0;

    try{
        COMANDO = "select date_format(sysdate(),'%H%i') hora from dual";
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        if(rset.next())
        {
            hora2 = Integer.parseInt(rset.getString("hora"));
        }
    }catch(Exception e){
        e.printStackTrace();
    }finally{
        cerrar(rset, pstmt, null); // Cerrar para evitar fuga de cursores
    }

	// Datos de la venta
	COMANDO	=	"select "+
					"	ip_impresion, "+
					"	nombre(id_personal) pac, "+
					"	dni(id_personal) dni, "+
					"	direccion(id_personal) direc, "+
					"	concat(serie, '-',  lpad(numdoc,7,0)) doc, "+
					"	id_docimp, 	"+
					"	tipo_doc,		"+
					"	id_vnt_ref,	"+
					"	upper(razon) razon,	"+
					"	'' cta, "+
					"	'' paq, "+
					"	login(id_personal_user) log_caj, "+
					"	concat('Dig: ',ifnull(login(id_personal_dig),login(id_personal_user)),' Importe en Soles')  log_dig, "+
					"	date_format(fecha, '%d/%m/%Y %H:%i')  fec, "+
					"	punto, "+
					"	(case cod_afi when null then null else concat('Cod. GS:', cod_afi) end) cod_afi,	"+
					"	(case nhc(id_personal) when null then 'Sin HC.' else nhc(id_personal) end) nhc, 		"+
					"	ifnull(id_atencion,0) id_atencion, serialTerminal(punto) AS TERMINAL,  "+
					" 	date_format(fecha, '%d/%m/%Y %H:%i') as fecha2, "+
					"   ' ' cod, id_mesa mesa "+
				"from vent_registro "+
				"where id_mov_vnt = '"+s_id_mov_vnt+"' ";
	pstmt = conn.prepareStatement(COMANDO);
	rset = pstmt.executeQuery();		
	if ( rset.next() )
	{
		//s_ip_print	= rset.getString("ip_impresion");	if ( s_ip_print ==null) 	s_ip_print = "";			
		s_id_docimp = rset.getString("id_docimp");		if ( s_id_docimp ==null) 	s_id_docimp = "";
		s_tipo_doc	= rset.getString("tipo_doc");		if ( s_tipo_doc ==null) 	s_tipo_doc = "";
		x_doc		= rset.getString("doc");			
		x_punto		= rset.getString("punto");			
		x_pac		= rset.getString("pac");
		s_dni       = rset.getString("dni");
		s_direc     = rset.getString("direc");
		x_paq		= rset.getString("paq");			if ( x_paq==null)			x_paq	= "";
		x_codafi	= rset.getString("cod_afi");		if ( x_codafi==null)		x_codafi = "";
		codgs = rset.getString("cod");if ( codgs==null)		codgs = "";
		x_nhc		= rset.getString("nhc");			if ( x_nhc==null)			x_nhc = "";			
		x_log_caj	= rset.getString("log_caj");		
		x_log_dig	= rset.getString("log_dig");		if ( x_log_dig==null) 		x_log_dig = "";
		x_fec		= rset.getString("fec");			
		id_detalle= rset.getString("id_vnt_ref");		if ( id_detalle==null) id_detalle="";
		x_cta		= rset.getString("cta");			if ( x_cta==null) x_cta="";
		s_razon     = rset.getString("razon"); if(s_razon==null) s_razon = x_pac;
		if ( id_detalle.equals("") ) { id_detalle = s_id_mov_vnt;}				
		//if ( s_ip_print.equals("")) { s_ip_print=s_ip; }
		id_atencion = rset.getString("id_atencion");	
		s_terminal = rset.getString("TERMINAL");
		s_fecha = rset.getString("fecha2");
		s_mesa  = rset.getString("mesa");
	}

	String bandera3 = "0";
	
	// Pinta el médico
	COMANDO =	"Select  "+					
				"ifnull(nombre(id_medico_ser),nombre(id_medico_rec)) med,	"+	
				" ifnull(copago_orig,0) copa_porc "+
				"from 	vent_regdet   "+
				"where	id_mov_vnt = '"+id_detalle+"' ";
	pstmt = conn.prepareStatement(COMANDO);
	rset = pstmt.executeQuery(); 
	while(rset.next())
	{			
		s_medico= rset.getString("med");
		s_copa_porc= rset.getString("copa_porc");
	}
	
	COMANDO =	"Select  "+
				"ifnull(sum(ifnull(valor_venta,0) *	( ( 100 + porc_igv ) / 100 )),'0')	vv, 	"+
				"ifnull(sum(ifnull(base_imp,0) *	( ( 100 + porc_igv ) / 100 )),'0')	bi, 	"+
				"ifnull(sum(ifnull(descuento,0)	 *	( ( 100 + porc_igv ) / 100 )),'0') 	descuento, 	"+
				"ifnull(sum(ifnull(cobertura,0)	 *	( ( 100 + porc_igv ) / 100 )),'0') 	cobertura, 	"+
				"ifnull(sum(copago),0 ) 	copago, 	"+
				"ifnull(sum(ifnull(tipo_copago,0)),'0') 	tipocop, 	"+
				"ifnull(sum(ifnull(total,0)),'0')		 	total, 		"+
				"ifnull(sum(ifnull(igv,0)),'0')		 	igv 		"+
				"from 	vent_regdet   "+
				"where	id_mov_vnt = '"+id_detalle+"' ";
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
		bandera3 	= "1";
	}
	
	bandera3 = "0";
	if(bandera3.equals("0")){		
		COMANDO =	"Select  "+
					"valor_venta as	vv, 	"+
					"base_imp as	bi, 	"+
					"descuento as 	descuento, 	"+
					"cobertura as 	cobertura, 	"+
					"copago as 	copago, 	"+
					"total as 	total 		"+
					"from 	vent_registro   "+
					"where	id_mov_vnt = '"+id_detalle+"' ";
					
		pstmt = conn.prepareStatement(COMANDO);
	     rset = pstmt.executeQuery();
		while(rset.next())
		{	
			sumvv	= rset.getString("vv");
			sumbi	= rset.getString("bi");
			sumcop	= rset.getString("copago");
			sumcob	= rset.getString("cobertura");
			sumdsc	= rset.getString("descuento");
			sumtot	= rset.getString("total");
		}
	}	

	String numtxt = "";	  
	numtxt = sumtot ;
	String total_letras = "";		
	
	// Pinta total en letras
	COMANDO = 	"Select "+
				" numtxt('"+numtxt+"') tota_letra "+ 
				"from dual ";
	pstmt = conn.prepareStatement(COMANDO);
	rset = pstmt.executeQuery();
	if ( rset.next() )
	{
		total_letras = "Son: "+rset.getString("tota_letra")+" Soles."; 
	}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nota de Venta - <%=x_doc%></title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            /* background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); */
            min-height: 100vh;
            padding: 2rem 0;
        }
        
        .receipt-container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .receipt-header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .receipt-logo {
            max-width: 200px;
            margin-bottom: 1rem;
            background: white;
            padding: 0.5rem;
            border-radius: 10px;
        }
        
        .company-info {
            font-size: 0.9rem;
            line-height: 1.6;
            margin-top: 1rem;
        }
        
        .company-info strong {
            font-weight: 600;
        }
        
        .receipt-body {
            padding: 2rem;
        }
        
        .doc-type-badge {
            background: linear-gradient(135deg, #f093fb15 0%, #f5576c15 100%);
            color: #f5576c;
            border: 2px solid #f5576c;
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            margin-bottom: 1.5rem;
        }
        
        .doc-type-badge .doc-label {
            font-size: 0.75rem;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.25rem;
            color: #212529;
        }
        
        .doc-type-badge .doc-type {
            margin: 0.5rem 0;
            font-size: 1rem;
            font-weight: 700;
            color: #f5576c;
        }
        
        .doc-type-badge .doc-number {
            font-size: 1.25rem;
            font-weight: 700;
            color: #212529;
        }
        
        .internal-doc-note {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.85rem;
            color: #856404;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .internal-doc-note i {
            color: #ffc107;
        }
        
        .info-section {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 0.75rem;
            font-size: 0.9rem;
        }
        
        .info-row:last-child {
            margin-bottom: 0;
        }
        
        .info-label {
            font-weight: 600;
            color: #495057;
            min-width: 120px;
        }
        
        .info-value {
            color: #212529;
            text-align: right;
            flex: 1;
        }
        
        .items-table {
            width: 100%;
            margin-bottom: 1.5rem;
            border-collapse: separate;
            border-spacing: 0;
        }
        
        .items-table thead {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        
        .items-table thead th {
            padding: 0.75rem 0.5rem;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .items-table thead th:first-child {
            border-radius: 8px 0 0 0;
        }
        
        .items-table thead th:last-child {
            border-radius: 0 8px 0 0;
        }
        
        .items-table tbody td {
            padding: 0.75rem 0.5rem;
            font-size: 0.85rem;
            border-bottom: 1px solid #e9ecef;
        }
        
        .items-table tbody tr:last-child td {
            border-bottom: none;
        }
        
        .items-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .text-end {
            text-align: right;
        }
        
        .text-center {
            text-align: center;
        }
        
        .totals-table {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0;
            font-size: 0.9rem;
        }
        
        .total-row.main {
            border-top: 2px solid #dee2e6;
            margin-top: 0.5rem;
            padding-top: 0.75rem;
            font-weight: 700;
            font-size: 1.1rem;
            color: #f5576c;
        }
        
        .total-label {
            font-weight: 600;
        }
        
        .total-value {
            font-weight: 700;
        }
        
        .text-in-words {
            background: linear-gradient(135deg, #f093fb15 0%, #f5576c15 100%);
            border-left: 4px solid #f5576c;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            font-style: italic;
            color: #495057;
        }
        
        .footer-info {
            display: flex;
            justify-content: space-between;
            padding-top: 1rem;
            border-top: 2px dashed #dee2e6;
            font-size: 0.85rem;
            color: #6c757d;
        }
        
        .footer-info div {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .footer-info i {
            color: #f5576c;
        }
        
        .action-buttons {
            padding: 1.5rem 2rem 2rem;
            background: #f8f9fa;
            display: flex;
            gap: 1rem;
        }
        
        .btn-action {
            flex: 1;
            padding: 0.75rem;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        
        .btn-print {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        
        .btn-print:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(245, 87, 108, 0.4);
        }
        
        .btn-download {
            background: white;
            color: #f5576c;
            border: 2px solid #f5576c;
        }
        
        .btn-download:hover {
            background: #f5576c;
            color: white;
        }
        
        @media print {
            body {
                background: white;
                padding: 0;
            }
            
            .receipt-container {
                max-width: 100%;
                box-shadow: none;
                border-radius: 0;
            }
            
            .action-buttons {
                display: none;
            }
            
            .receipt-header {
                background: none;
                color: black;
            }
            
            .doc-type-badge {
                background: none;
                color: black;
                border: 2px solid black;
            }
            
            .internal-doc-note {
                display: none;
            }
            
            .items-table thead {
                background: black;
                color: white;
            }
        }
        
        @media (max-width: 576px) {
            .receipt-container {
                margin: 0;
                border-radius: 0;
                min-height: 100vh;
            }
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <!-- Header -->
        <div class="receipt-header">
            <%if(hora2<1600) {%>
                <img src="../../plugins/images/logo.jpg" alt="Logo" class="receipt-logo">
            <%} else {%>
                <img src="../../plugins/images/logo2.jpg" alt="Logo" class="receipt-logo">
            <%}%>
            <div class="company-info">
                <strong>INVERSIONES MJGL E.I.R.L</strong><br>
                Calle Pevas N° 219<br>
                Iquitos - Maynas - Loreto
            </div>
        </div>
        
        <!-- Body -->
        <div class="receipt-body">
            <!-- Document Type Badge (SIN fondo negro - documento interno) -->
            <div class="doc-type-badge">
                <div class="doc-label">RUC: 20541177281</div>
                <div class="doc-type">NOTA DE VENTA</div>
                <div class="doc-number"><%=x_doc%></div>
            </div>
            
            <!-- Internal Document Note -->
            <div class="internal-doc-note">
                <i class="fas fa-info-circle"></i>
                <span><strong>Documento Interno:</strong> No válido como comprobante de pago</span>
            </div>
            
            <!-- Client Information -->
            <div class="info-section">
                <div class="info-row">
                    <span class="info-label"><i class="far fa-calendar-alt"></i> Fecha Emisión:</span>
                    <span class="info-value"><%=x_fec%></span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="far fa-user"></i> Señor(es):</span>
                    <span class="info-value"><%=x_pac%></span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="far fa-id-card"></i> N.Doc:</span>
                    <span class="info-value"><%=s_dni%></span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-map-marker-alt"></i> Dirección:</span>
                    <span class="info-value"><%=s_direc%></span>
                </div>
            </div>
            
            <!-- Items Table -->
            <table class="items-table">
                <thead>
                    <tr>
                        <th style="width: 50%;">Descripción</th>
                        <th class="text-center" style="width: 15%;">Cant.</th>
                        <th class="text-end" style="width: 17.5%;">P.Unit.</th>
                        <th class="text-end" style="width: 17.5%;">Imp. S/</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    int itm = 0;
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
                    pstmt = conn.prepareStatement(COMANDO);
                    rset = pstmt.executeQuery();
                    while(rset.next())
                    { 
                        itm++;
                %>
                    <tr>
                        <td><strong><%=rset.getString("glosa")%></strong></td>
                        <td class="text-center"><%=rset.getString("cantidad")%></td>
                        <td class="text-end"><%=rset.getString("vu")%></td>
                        <td class="text-end"><%=rset.getString("tota")%></td>
                    </tr>
                <%  
                    }
                %>
                </tbody>
            </table>
            
            <!-- Totals Table (Simplificado - sin QR para notas de venta) -->
            <div class="totals-table">
                <div class="total-row">
                    <span class="total-label">Sub Total</span>
                    <span class="total-value">S/ <%=sumbi%></span>
                </div>
                <div class="total-row">
                    <span class="total-label">Total Descuento</span>
                    <span class="total-value">S/ 0.00</span>
                </div>
                <div class="total-row main">
                    <span class="total-label">Total a Pagar</span>
                    <span class="total-value">S/ <%=sumtot%></span>
                </div>
            </div>
            
            <!-- Total in Words -->
            <div class="text-in-words">
                <i class="fas fa-quote-left"></i> <%=total_letras%>
            </div>
            
            <!-- Footer Information -->
            <div class="footer-info">
                <div>
                    <i class="fas fa-user-tie"></i>
                    <span>Cajero: <%=x_log_caj%></span>
                </div>
                <div>
                    <i class="fas fa-chair"></i>
                    <span>Mesa: <%=s_mesa%></span>
                </div>
            </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
            <button class="btn-action btn-print" onclick="openPDFModal('<%=id_detalle%>')">
                <i class="fas fa-print"></i>
                Imprimir
            </button>
            <button class="btn-action btn-download" onclick="window.close()">
                <i class="fas fa-times"></i>
                Cerrar
            </button>
        </div>
    </div>

    <!-- Modal para PDF -->
    <div class="modal fade" id="pdfModal" tabindex="-1" aria-labelledby="pdfModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                    <h5 class="modal-title" id="pdfModalLabel">
                        <i class="fas fa-file-pdf me-2"></i>
                        Vista Previa de NOTA DE VENTA
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0" style="height: 80vh;">
                    <iframe id="pdfViewer" style="width: 100%; height: 100%; border: none;"></iframe>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Cerrar
                    </button>
                    <button type="button" class="btn btn-primary" onclick="downloadPDF()">
                        <i class="fas fa-download me-2"></i>Descargar PDF
                    </button>
                    <button type="button" class="btn btn-success" onclick="printPDF()">
                        <i class="fas fa-print me-2"></i>Imprimir
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentPdfUrl = '';

         function openPDFModal(idMovVnt) {
            // Construir la URL del PDF
            currentPdfUrl = 'print_nota_venta_pdf.jsp?f_id_mov_vnt=' + idMovVnt;
            
            // Cargar el PDF en el iframe
            document.getElementById('pdfViewer').src = currentPdfUrl;
            
            // Mostrar el modal
            const pdfModal = new bootstrap.Modal(document.getElementById('pdfModal'));
            pdfModal.show();
        }
        
        function downloadPDF() {
            // Crear un enlace temporal para descargar el PDF
            const link = document.createElement('a');
            link.href = currentPdfUrl;
            link.download = 'comprobante.pdf';
            link.click();
        }
        
        function printPDF() {
            // Obtener el iframe
            const iframe = document.getElementById('pdfViewer');
            
            // Intentar imprimir el contenido del iframe
            try {
                iframe.contentWindow.print();
            } catch (e) {
                // Si falla, abrir en nueva ventana para imprimir
                window.open(currentPdfUrl, '_blank');
            }
        }
    </script>
</body>
</html>
