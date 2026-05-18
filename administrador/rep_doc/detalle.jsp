<%@page contentType="text/html ; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    int cont            = 0;
    String s_tipo_doc   = request.getParameter("f_tipo_doc");
    String s_fecha_ini  = request.getParameter("f_fecha_ini");
    String s_fecha_fin  = request.getParameter("f_fecha_fin");
    String s_id_user    = request.getParameter("f_id_personal_user");
    String s_id_caja    = "";
    String s_periodo1   = s_fecha_ini.substring(6,10)+s_fecha_ini.substring(3,5)+s_fecha_ini.substring(0,2);
    String s_periodo2   = s_fecha_fin.substring(6,10)+s_fecha_fin.substring(3,5)+s_fecha_fin.substring(0,2);
    String s_modo       = "1";
    String s_fecha      = "";
    String s_fecha_emi  = "";
    String s_hora       = "";
    String s_doc        = "";
    String s_caja       = "";
    int contador        = 0;
    double dblTotal     = 0;

    if(id_nivel_user.equals("0")){
        s_id_caja = request.getParameter("f_id_caja"); if(s_id_caja==null) s_id_caja=s_punto;
    } else {
        try{
        COMANDO = "Select punto from areas_usuarios where id_personal = '"+id_personal_user+"' ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);  
        rset = pstmt.executeQuery();
        if(rset.next()){
            s_punto = rset.getString("punto"); if(s_punto.equals("0")) s_punto="01";
        }
        }catch(Exception ex){
            out.println("Error al obtener el punto: " + ex.getMessage());
        }finally {
            cerrar(rset, pstmt, conn);
        }
    }

    if(s_tipo_doc.equals("00")){
        s_doc  = "TODOS LOS DOCUMENTOS";
        s_modo = "1";
    } else {
        try{
            COMANDO = "Select upper(nombre) nombre, '1' modo from cont_tipo_doc where tipo_doc = '"+s_tipo_doc+"' ";
            conn = getConexion();
            pstmt = conn.prepareStatement(COMANDO);  
            rset = pstmt.executeQuery();
            if(rset.next()){
                s_doc  = rset.getString("nombre");
                s_modo = rset.getString("modo");
            }
            if(s_tipo_doc.equals("39,41")) { s_doc = "FACTURA Y BOLETA ELECTRÓNICA"; s_modo = "1"; }   
        }catch(Exception ex){
            out.println("Error al obtener el documento: " + ex.getMessage());
        }finally {
            cerrar(rset, pstmt, conn);
        }
    }

    try{
        COMANDO = "Select " +
                "concat(substr('"+s_fecha_ini+"',1,2),'.',(case substring('"+s_fecha_ini+"',4,2) " +
                "when '01' then 'Ene' when '02' then 'Feb' when '03' then 'Mar' when '04' then 'Abr' " +
                "when '05' then 'May' when '06' then 'Jun' when '07' then 'Jul' when '08' then 'Ago' " +
                "when '09' then 'Set' when '10' then 'Oct' when '11' then 'Nov' when '12' then 'Dic' end),'.',substr('"+s_fecha_ini+"',7,4)) fecha, " +
                "date_format(sysdate(),'%d/%m/%Y') fecha_emi, " +
                "time_format(sysdate(),'%T') hora, " +
                "upper(nombre) caja " +
                "from puntos ";
        if(id_nivel_user.equals("0")){
            COMANDO += "where punto = '"+s_id_caja+"' ";
        } else {
            COMANDO += "where punto = '"+s_punto+"' ";
        }
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);  
        rset = pstmt.executeQuery();
        if(rset.next()){
            s_fecha     = rset.getString("fecha");
            s_fecha_emi = rset.getString("fecha_emi");
            s_hora      = rset.getString("hora");
            s_caja      = rset.getString("caja");
        }
    }catch(Exception ex){
        out.println("Error al obtener la fecha: " + ex.getMessage());
    }finally {
        cerrar(rset, pstmt, conn);
    }

    /*Datos facturador*/
        // Lista de situaciones
    java.util.List<java.util.Map<String, String>> situaciones = new java.util.ArrayList<>();

    String[][] datos = {
        {"01", "Por Generar XML"},
        {"02", "XML Generado"},
        {"03", "Enviado y Aceptado SUNAT"},
        {"04", "Enviado y Aceptado SUNAT con Obs."},
        {"05", "Rechazado por SUNAT"},
        {"06", "Con Errores"},
        {"07", "Por Validar XML"},
        {"08", "Enviado a SUNAT Por Procesar"},
        {"09", "Enviado a SUNAT Procesando"},
        {"10", "Rechazado por SUNAT"},
        {"11", "Enviado y Aceptado SUNAT"},
        {"12", "Enviado y Aceptado SUNAT con Obs."}
    };

    for (String[] item : datos) {
        java.util.Map<String, String> mapa = new java.util.LinkedHashMap<>();
        mapa.put("id", item[0]);
        mapa.put("nombre", item[1]);
        situaciones.add(mapa);
    }

    java.util.Map<String, java.util.List<java.util.Map<String, String>>> listaSituacion = new java.util.LinkedHashMap<>();
    listaSituacion.put("ListaSituacion", situaciones);
    
    String DB_PATH = "C:\\SFS_v1.3.4.4\\bd\\BDFacturador.db";
    String rutaXML = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/FIRMA";
    String rutaCDR = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/RPTA";

    Connection sqliteDb = conectarSQLite(DB_PATH);
           
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Ventas - Detalle</title>

    <!-- AdminLTE 3 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* ─── BASE ────────────────────────────────────────────────── */
        html, body {
            margin: 0; padding: 0; height: 100%;
            font-family: 'Source Sans Pro', sans-serif;
            font-size: 13px; background: #f4f6f9;
        }

        /* ─── RESULTS CARD ────────────────────────────────────────── */
        .results-card {
            margin: 0;
            border: none;
            border-radius: 0;
            height: 100%;
            display: flex; flex-direction: column;
        }
        .results-header {
            background: #1a3c6e;
            padding: 7px 12px;
            display: flex; align-items: center; gap: 10px;
            flex-shrink: 0;
        }
        .results-header .rh-title {
            font-size: 12.5px; font-weight: 700; color: #fff;
            letter-spacing: 0.2px; margin: 0;
        }
        .results-header .rh-meta {
            margin-left: auto;
            display: flex; align-items: center; gap: 8px;
        }
        .badge-count {
            background: rgba(255,255,255,.18);
            color: #fff; font-size: 10.5px; font-weight: 700;
            padding: 2px 9px; border-radius: 10px; white-space: nowrap;
        }
        .badge-date {
            background: rgba(255,255,255,.12);
            color: #cfe0ff; font-size: 10px; font-weight: 600;
            padding: 2px 8px; border-radius: 10px; white-space: nowrap;
        }
        .btn-print {
            background: rgba(255,255,255,.15);
            border: 1px solid rgba(255,255,255,.3);
            color: #fff; font-size: 11px; font-weight: 600;
            padding: 3px 12px; border-radius: 4px; cursor: pointer;
            display: inline-flex; align-items: center; gap: 5px;
            transition: background .2s;
        }
        .btn-print:hover { background: rgba(255,255,255,.28); }

        /* ─── META BAR ────────────────────────────────────────────── */
        .meta-bar {
            background: #eef1f7;
            border-bottom: 1px solid #d8dfe8;
            padding: 5px 12px;
            display: flex; align-items: center; gap: 14px;
            flex-shrink: 0; flex-wrap: wrap;
        }
        .meta-item {
            display: flex; align-items: center; gap: 5px;
            font-size: 11px; color: #4a5568;
        }
        .meta-item i { color: #7b8ea8; font-size: 10px; }
        .meta-item strong { color: #1a3c6e; font-weight: 700; }

        /* ─── TABLE WRAPPER ───────────────────────────────────────── */
        .table-wrapper {
            flex: 1; overflow-y: auto; overflow-x: auto;
        }

        /* ─── TABLE ────────────────────────────────────────────────── */
        .table-ventas {
            font-size: 12px; margin: 0; width: 100%;
            border-collapse: collapse;
        }
        .table-ventas thead tr th {
            background: #eef1f7;
            color: #3d5170;
            font-size: 10.5px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.5px;
            padding: 6px 10px;
            border-bottom: 2px solid #d0d8e8;
            border-top: none; border-right: none; border-left: none;
            white-space: nowrap; position: sticky; top: 0; z-index: 5;
        }
        .table-ventas tbody tr td {
            padding: 5px 10px;
            vertical-align: middle;
            border-top: 1px solid #edf0f5;
            color: #2d3748;
        }
        .table-ventas tbody tr:hover { background: #f5f8fc; }
        .table-ventas tbody tr.row-anulado td {
            opacity: .58; text-decoration: line-through;
        }
        .table-ventas tbody tr.row-anulado td:first-child { text-decoration: none; }

        /* ─── ROW NUM ─────────────────────────────────────────────── */
        .row-num {
            display: inline-flex; align-items: center; justify-content: center;
            width: 22px; height: 22px;
            background: #1a3c6e; color: #fff;
            border-radius: 4px; font-size: 10px; font-weight: 700;
        }
        .row-num.anulado { background: #c0392b; }

        /* ─── DOC BADGE ───────────────────────────────────────────── */
        .doc-badge {
            display: inline-flex; align-items: center; gap: 4px;
            background: #eef1f7; border: 1px solid #d0d8e8;
            border-radius: 4px; padding: 2px 7px;
            font-size: 11px; font-weight: 700; color: #1a3c6e;
            white-space: nowrap;
        }
        .doc-badge.fac { background: #fff3e0; border-color: #f5b942; color: #9c5f00; }
        .doc-badge.bol { background: #e8f5e9; border-color: #4caf50; color: #1b5e20; }
        .doc-badge.nv  { background: #e3f2fd; border-color: #42a5f5; color: #0d47a1; }
        .doc-badge i   { font-size: 9px; }

        /* ─── ESTADO ──────────────────────────────────────────────── */
        .estado-v {
            display: inline-block; width: 7px; height: 7px;
            background: #27ae60; border-radius: 50%; margin-right: 4px;
        }
        .estado-a {
            display: inline-block; width: 7px; height: 7px;
            background: #e74c3c; border-radius: 50%; margin-right: 4px;
        }

        /* ─── IMPORT CELL ─────────────────────────────────────────── */
        .importe-cell {
            font-weight: 700; color: #1a3c6e;
            text-align: right; white-space: nowrap; font-size: 12px;
        }
        .importe-cell.anulado { color: #e74c3c; }

        /* ─── DOC ID ──────────────────────────────────────────────── */
        .doc-id {
            font-family: 'Courier New', monospace;
            font-size: 11.5px; color: #4a5568; letter-spacing: 0.4px;
        }

        /* ─── CAJERO ──────────────────────────────────────────────── */
        .cajero-cell {
            color: #5a6a7e; font-size: 11.5px;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .cajero-cell i { color: #b0bfd0; font-size: 10px; }

        /* ─── DATE CELL ───────────────────────────────────────────── */
        .date-cell { color: #5a6a7e; white-space: nowrap; font-size: 11.5px; }
        .date-cell i { color: #b0bfd0; margin-right: 3px; font-size: 10px; }

        /* ─── NO RESULTS ──────────────────────────────────────────── */
        .no-results-cell { padding: 40px 20px !important; text-align: center; }
        .no-results-box { color: #8899aa; }
        .nr-icon {
            width: 50px; height: 50px;
            background: #eef1f7; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 10px; font-size: 20px; color: #b0bfd0;
        }
        .no-results-box h6 {
            font-size: 13px; font-weight: 700;
            color: #4a5568; margin: 0 0 4px;
        }
        .no-results-box p { font-size: 12px; margin: 0; color: #8899aa; }

        /* ─── FOOTER TOTAL ────────────────────────────────────────── */
        .footer-total {
            background: #fff;
            border-top: 2px solid #d0d8e8;
            padding: 7px 12px;
            display: flex; align-items: center; justify-content: space-between;
            flex-shrink: 0;
        }
        .footer-info { font-size: 11px; color: #6c757d; }
        .footer-info i { color: #a0aec0; margin-right: 4px; }
        .total-box {
            display: flex; align-items: center; gap: 8px;
        }
        .total-label {
            font-size: 11px; font-weight: 700; color: #3d5170;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .total-amount {
            font-size: 16px; font-weight: 700; color: #1a3c6e;
            font-family: 'Source Sans Pro', sans-serif;
        }
        .total-prefix {
            font-size: 11px; font-weight: 600; color: #7b8ea8;
            vertical-align: super;
        }

        /* ─── PRINT ───────────────────────────────────────────────── */
        @media print {
            html, body {
                height: auto !important;
                overflow: visible !important;
            }
            .results-card {
                height: auto !important;
                display: block !important;
            }
            .table-wrapper {
                height: auto !important;
                overflow: visible !important;
            }
            .table-ventas {
                height: auto !important;
                overflow: visible !important;
            }
            .table-ventas thead tr th { 
                background: #eee !important; 
                position: static !important; 
            }
            .table-ventas tbody tr {
                page-break-inside: avoid !important;
                break-inside: avoid !important;
            }
            .results-header .btn-print { display: none !important; }
            .meta-bar { background: #fff !important; border-bottom: 1px solid #ccc; }
            body { background: #fff; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>
<div class="results-card">

    <!-- ── Results Header ──────────────────────────────────────── -->
    <div class="results-header">
        <i class="fas fa-table" style="font-size:12px; color:rgba(255,255,255,.7);"></i>
        <span class="rh-title">
            Registro de Ventas
            &mdash; <span style="font-weight:400; color:#b8cfef;"><%=s_doc%></span>
        </span>
        <div class="rh-meta">
            <span class="badge-date">
                <i class="far fa-calendar-alt"></i>
                <%=s_fecha_ini%>
                <% if(!s_fecha_fin.equals(s_fecha_ini)){ %> &rarr; <%=s_fecha_fin%> <% } %>
            </span>
            <span class="badge-count" id="badge-count">0 registros</span>
            <button class="btn-print" onclick="window.print()">
                <i class="fas fa-print"></i> Imprimir
            </button>
        </div>
    </div>

    <!-- ── Meta Bar ───────────────────────────────────────────── -->
    <div class="meta-bar">
        <div class="meta-item">
            <i class="fas fa-store"></i>
            <strong><%=s_caja%></strong>
        </div>
        <div class="meta-item">
            <i class="far fa-clock"></i>
            Emisión: <strong><%=s_fecha_emi%> <%=s_hora%></strong>
        </div>
        <div class="meta-item">
            <i class="fas fa-file-invoice"></i>
            Tipo: <strong><%=s_doc%></strong>
        </div>
        <div class="meta-item no-print" style="margin-left:auto;">
            <i class="fas fa-database"></i>
            SQLite: 
            <% if(sqliteDb != null){ %>
                <strong style="color: #27ae60;">Conectado</strong>
            <% } else { %>
                <strong style="color: #e74c3c;">Desconectado</strong>
                <% 
                   String errorMsg = "";
                   try { 
                       Class.forName("org.sqlite.JDBC"); 
                   } catch (ClassNotFoundException e) { 
                       errorMsg = "Falta driver org.sqlite.JDBC"; 
                   }
                   if(errorMsg.isEmpty()){
                       java.io.File f = new java.io.File(DB_PATH);
                       if(!f.exists()) errorMsg = "BD no encontrada en ruta";
                       else if(!f.canRead()) errorMsg = "Sin permisos de lectura";
                       else errorMsg = "Error de Conexión SQLite (revise catalina.out)";
                   }
                %>
                <span style="color:#e74c3c; font-size:10.5px; margin-left:4px; font-weight: 600;">[<%=errorMsg%>]</span>
            <% } %>
        </div>
    </div>

    <!-- ── Table ──────────────────────────────────────────────── -->
    <div class="table-wrapper">
        <table class="table-ventas">
            <thead>
                <tr>
                    <th style="width:36px; text-align:center;">#</th>
                    <th style="width:160px;">Comprobante</th>
                    <th>Cliente</th>
                    <th style="width:115px;">RUC / DNI</th>
                    <th style="width:100px; text-align:right;">Importe</th>
                    <th style="width:100px;">Fecha</th>
                    <th style="width:200px;">Estado Sunat</th>
                    <th style="width:200px;text-align:center;" class="no-print">Descargar</th>
                    <th style="width:120px;" class="no-print">Cajero</th>
                </tr>
            </thead>
            <tbody id="tabla-body">
<%
    COMANDO = "Select " +
              "tipo_doc, b.id_personal, " +
              "nom_doc3(tipo_doc) pref, " +
              "b.serie, " +
              "lpad(b.numdoc,8,'0') numdoc, " +
              "id_mov_vnt, " +
              "b.estado, " +
              "b.tipo_doc, " +
              "(case when b.tipo_doc = '39' then razon  else nombre(b.id_personal) end) nombre, " +
              "(case when b.tipo_doc = '39' then ruc else dni(b.id_personal) end) docpersona, " +
              "(case when b.estado='A' then '0.00' else format(ifnull(b.total,0),2) end) importe, " +
              "date_format(b.fecha,'%d/%m/%Y') fecemi, " +
              "lower(login(b.id_personal_user)) cajero " +
              "from vent_registro b ";

    if(s_fecha_fin.equals(s_fecha_ini)){
        COMANDO += "where date_format(b.fecha,'%d/%m/%Y') = '"+s_fecha_ini+"' ";
    } else {
        COMANDO += "where date_format(b.fecha,'%Y%m%d') >= '"+s_periodo1+"' " +
                   "and date_format(b.fecha,'%Y%m%d') <= '"+s_periodo2+"' ";
    }

    if(id_nivel_user.equals("0")){
        COMANDO += "and b.punto = '"+s_id_caja+"' ";
    } else {
        COMANDO += "and b.punto in('"+s_punto+"') ";
    }

    if(!s_tipo_doc.equals("00")){
        COMANDO += "and b.tipo_doc in(" + s_tipo_doc +") ";
    }
    if(!s_id_user.equals("T")){
        COMANDO += "and id_personal_user='"+s_id_user+"' ";
    }
    COMANDO += "and b.estado in ('A','V') " +
               "and b.tipo_doc in('34','35','26','41','39') " +
               "and b.modo = '"+s_modo+"' " +
               "order by numdoc ";

    conn = getConexion();
    pstmt = conn.prepareStatement(COMANDO);  
    rset = pstmt.executeQuery();
    while(rset.next()){
        contador++;
        String estado    = rset.getString("estado");
        String tipodoc   = rset.getString("tipo_doc");
        String rowClass  = estado.equals("A") ? " row-anulado" : "";
        String numClass  = estado.equals("A") ? " anulado" : "";
        String impClass  = estado.equals("A") ? " anulado" : "";
        String badgeClass = "";
        if(tipodoc.equals("39"))      badgeClass = "fac";
        else if(tipodoc.equals("41")) badgeClass = "bol";
        else if(tipodoc.equals("34")) badgeClass = "nv";
        String importeStr = rset.getString("importe");
        try {
            double d = Double.parseDouble(importeStr.replace(",",""));
            if(!estado.equals("A")) dblTotal += d;
        } catch(Exception ex) {}

        /*Obtener  situación del documento y link de visualización xml y cdr*/
        String situacion = "";
        String serie = rset.getString("serie");
        String numdoc = rset.getString("numdoc");
        String link_xml = "";
        String link_cdr = "";

        // ============================================================
        // CONSULTA A SQLITE
        // ============================================================
        java.util.Map<String, Object> documento = null;

        if (sqliteDb != null) {
            String numDocuClean = numdoc.replaceFirst("^0+", "");
            if (numDocuClean.isEmpty()) numDocuClean = "0";
            String numDocu = serie + "-" + numDocuClean;
            String query   = "SELECT * FROM DOCUMENTO WHERE NUM_DOCU = ?";

            try (PreparedStatement ps = sqliteDb.prepareStatement(query)) {
                ps.setString(1, numDocu);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        documento = new java.util.LinkedHashMap<>();
                        ResultSetMetaData meta = rs.getMetaData();
                        for (int i = 1; i <= meta.getColumnCount(); i++) {
                            documento.put(meta.getColumnName(i), rs.getObject(i));
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("[SQLite] Error al consultar DOCUMENTO: " + e.getMessage());
            }
        }

        // ============================================================
        // VALORES POR DEFECTO si no hay resultado o no hay DB
        // Equivalente a: if ($documento === false)
        // ============================================================
        if (documento == null) {
            documento = new java.util.LinkedHashMap<>();
            documento.put("FEC_GENE",     null);
            documento.put("FEC_ENVI",     null);
            documento.put("FEC_CARG",     null);
            documento.put("TIP_DOCU",     null);
            documento.put("NUM_DOCU",     null);
            documento.put("NUM_RUC",      null);
            documento.put("NOM_ARCH",     null);
            documento.put("TIP_ARCH",     null);
            documento.put("DES_OBSE",     null);
            documento.put("FIRM_DIGITAL", null);
            documento.put("IND_SITU",     null);
        }

        // ============================================================
        // ASIGNAR VALORES
        // Equivalente a: $var = $documento['KEY'] ?? '-'
        // ============================================================
        String fechaEnvio       = documento.get("FEC_ENVI")  != null ? documento.get("FEC_ENVI").toString()  : "-";
        String estadoSituacion  = documento.get("IND_SITU")  != null ? documento.get("IND_SITU").toString()  : "-";
        String nombreArchivo    = documento.get("NOM_ARCH")  != null ? documento.get("NOM_ARCH").toString()  : "-";

        String comprobanteXML   = nombreArchivo + ".xml";
        String comprobanteCDR   = "R" + nombreArchivo + ".zip";

        // ============================================================
        // BUSCAR SITUACIÓN EN LA LISTA
        // Equivalente a: array_filter(...)
        // ============================================================
        String nombreSituacion = tipodoc.equals("34") ? "Documento Interno de Venta" : "Ejecutar Facturador sunat"; // valor por defecto

        for (java.util.Map<String, String> item : listaSituacion.get("ListaSituacion")) {
            if (item.get("id").equals(estadoSituacion)) {
                nombreSituacion = item.get("nombre");
                break;
            }
        }

        // ============================================================
        // FLAGS DE DESCARGA
        // Equivalente a: in_array($estadoSituacion, [...])
        // ============================================================
        java.util.List<String> soloXML  = java.util.Arrays.asList("02", "07", "08", "09");
        java.util.List<String> xmlYCdr  = java.util.Arrays.asList("03", "04", "05", "10", "11", "12");

        boolean descargarXML = false;
        boolean descargarCDR = false;

        if (soloXML.contains(estadoSituacion)) {
            descargarXML = true;
        } else if (xmlYCdr.contains(estadoSituacion)) {
            descargarXML = true;
            descargarCDR = true;
        }

         // ============================================================
        // LINKS DE DESCARGA XML y CDR
        // Equivalente a: $descargarXMLLink = $descargarXML ? '...' : ''
        // ============================================================
        String descargarXMLLink = descargarXML
            ? "<a href=\"descargar.jsp?tipo=xml&archivo=" + comprobanteXML + "\" "
                + "class=\"btn btn-xs btn-outline-primary\" "
                + "download=\"" + comprobanteXML + "\">"
                + "<i class=\"fas fa-file-code\"></i> XML</a>"
            : "";

        String descargarCDRLink = descargarCDR
            ? "<a href=\"descargar.jsp?tipo=cdr&archivo=" + comprobanteCDR + "\" "
                + "class=\"btn btn-xs btn-outline-success\">"
                + "<i class=\"fas fa-file-archive\"></i> CDR</a>"
            : "";
        
%>
                <tr class="<%=rowClass%>">
                    <td style="text-align:center;">
                        <span class="row-num<%=numClass%>"><%=contador%></span>
                    </td>
                    <td>
                        <span class="doc-badge <%=badgeClass%>">
                            <% if(tipodoc.equals("39")){ %><i class="fas fa-file-invoice" title="Factura"></i>
                            <% } else if(tipodoc.equals("41")){ %><i class="fas fa-receipt" title="Boleta"></i>
                            <% } else { %><i class="fas fa-file-alt" title="Nota de Venta"></i>
                            <% } %>
                            <%=rset.getString("pref").trim()%>&nbsp;<%=rset.getString("numdoc").trim()%>
                        </span>
                        <% if(estado.equals("A")){ %>
                        <span style="font-size:9.5px; color:#c0392b; font-weight:700; margin-left:4px;">ANULADO</span>
                        <% } %>
                    </td>
                    <td><%=rset.getString("nombre")%></td>
                    <td>
                        <span class="doc-id"><%=rset.getString("docpersona")%></span>
                    </td>
                    <td class="importe-cell<%=impClass%>">
                        <span class="total-prefix">S/</span> <%=importeStr%>
                    </td>
                    <td class="date-cell">
                        <i class="far fa-calendar-alt"></i><%=rset.getString("fecemi").trim()%>
                    </td>
                    <td style="text-align:center;">
                        <span class="status-badge <%=badgeClass%>" style="min-width: 40px; font-size: 10px;">
                            <%=nombreSituacion%>
                        </span>
                    </td>
                    <td style="text-align:center;" class="no-print">
                        <span class="btn-download"><%=descargarXMLLink%>&nbsp;</span>
                        <span class="btn-download"><%=descargarCDRLink%></span>
                    </td>   
                    <td class="no-print">
                        <span class="cajero-cell">
                            <i class="fas fa-user-circle"></i><%=rset.getString("cajero")%>
                        </span>
                    </td>
                </tr>
<%  } %>
<% if(contador == 0){ %>
                <tr>
                    <td colspan="7" class="no-results-cell">
                        <div class="no-results-box">
                            <div class="nr-icon">
                                <i class="fas fa-inbox"></i>
                            </div>
                            <h6>Sin registros</h6>
                            <p>No se encontraron ventas para el período y filtros seleccionados.</p>
                        </div>
                    </td>
                </tr>
<% } %>
            </tbody>
        </table>
    </div>

    <!-- ── Footer Total ───────────────────────────────────────── -->
<%
    String totalDB = "0";
    // Totales desde BD
    COMANDO = "Select ifnull(sum(b.total),0) total " +
              "from vent_registro b " +
              "where date_format(b.fecha,'%Y%m%d') >= '"+s_periodo1+"' " +
              "and date_format(b.fecha,'%Y%m%d') <= '"+s_periodo2+"' ";
    if(id_nivel_user.equals("0")){
        COMANDO += "and b.punto = '"+s_id_caja+"' ";
    } else {
        COMANDO += "and b.punto in('"+s_punto+"','11','59') ";
    }
    if(!s_tipo_doc.equals("00")){
        COMANDO += "and b.tipo_doc = '"+s_tipo_doc+"' ";
    }
    if(!s_id_user.equals("T")){
        COMANDO += "and b.id_personal_user='"+s_id_user+"' ";
    }
    COMANDO += "and b.modo = '"+s_modo+"' " +
               "and b.estado in ('V') " +
               "and b.tipo_doc in('34','41','39') ";

    conn = getConexion();
    pstmt = conn.prepareStatement(COMANDO);  
    rset = pstmt.executeQuery();
    if(rset.next()){
     totalDB = rset.getString("total");
    }

    try {
        double d = Double.parseDouble(totalDB);
        totalDB = String.format("%,.2f", d);
    } catch(Exception ex){}
%>
    <div class="footer-total">
        <div class="footer-info">
            <i class="fas fa-info-circle"></i>
            <% if(contador > 0){ %>
                <strong><%=contador%></strong> documento(s) mostrado(s)
                &nbsp;&bull;&nbsp; Solo se suman documentos <strong>vigentes</strong>
            <% } else { %>
                No hay documentos para el período seleccionado
            <% } %>
        </div>
        <div class="total-box">
            <span class="total-label"><i class="fas fa-calculator" style="margin-right:5px;"></i>Total:</span>
            <span class="total-amount">
                <span class="total-prefix">S/</span> <%=totalDB%>
            </span>
        </div>
    </div>

</div><!-- /.results-card -->

<!-- jQuery + Bootstrap 4 + AdminLTE -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<%-- <script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script> --%>
<script>
    // Actualizar badge contador
    $(function(){
        var n = <%=contador%>;
        $('#badge-count').text(n + ' registro' + (n !== 1 ? 's' : ''));
    });
</script>
</body>
</html>
