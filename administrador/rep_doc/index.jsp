<%@ page contentType="text/html ; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>

<%
    int num = 0;
    String s_fecha      = request.getParameter("f_fecha"); if(s_fecha==null) s_fecha = fecha;
    String s_day        = s_fecha.substring(0,2);
    String s_month      = s_fecha.substring(3,5);
    String s_year       = s_fecha.substring(6,10);
    String s_ver_punto  = "";

    try{
        COMANDO = "Select date_format(sysdate(),'%d/%m/%Y') hoy from dual ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);  
        rset = pstmt.executeQuery();
        rset.next();
        s_fecha = rset.getString("hoy");
    }catch(Exception ex){
        out.println("Error al obtener la fecha: " + ex.getMessage());
    }finally {
        cerrar(rset, pstmt, conn);
    }

    try{
        COMANDO = "Select a.punto from areas_usuarios a, puntos b " +
                "where a.punto = b.punto " +
                "and a.id_personal = '"+id_personal_user+"' " +
                "and a.punto <> '11' ";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);  
        rset = pstmt.executeQuery();
        if(rset.next()){
            s_ver_punto = rset.getString("punto");
        }else{
            s_ver_punto = "X";
        }
    }catch(Exception ex){
        out.println("Error al obtener el punto: " + ex.getMessage());
    }finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Registro de Ventas</title>

    <!-- AdminLTE 3 CSS + Icons + Fonts -->
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css" />
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/source-sans-pro.css" />

    <!-- Flatpickr date picker (reemplaza calendario legacy 404) -->
    <link rel="stylesheet" href="../../assets/plugins/flatpickr/css/flatpickr.min.css">
    <link rel="stylesheet" href="../../assets/plugins/flatpickr/css/airbnb.css">

    <style>
        /* ─── BASE ────────────────────────────────────────────────── */
        html, body {
            height: 100%;
            margin: 0; padding: 0;
            font-family: 'Source Sans Pro', sans-serif;
            background-color: #f4f6f9;
            font-size: 13px;
        }
        .wrapper { display: flex; flex-direction: column; height: 100%; }

        /* ─── PAGE HEADER BAR ─────────────────────────────────────── */
        .page-header-bar {
            background: #fff;
            border-bottom: 2px solid #e2e8f0;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-shrink: 0;
        }
        .page-icon {
            width: 32px; height: 32px;
            background: #1a3c6e;
            border-radius: 6px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 13px; flex-shrink: 0;
        }
        .page-header-bar h4 {
            margin: 0; font-size: 14px; font-weight: 700;
            color: #1a3c6e; letter-spacing: 0.3px;
        }
        .page-header-bar small {
            display: block; color: #6c757d; font-size: 11px; font-weight: 400;
        }

        /* ─── CONTENT AREA ────────────────────────────────────────── */
        .content-area {
            padding: 12px 14px 0;
            flex-shrink: 0;
        }

        /* ─── CARD ────────────────────────────────────────────────── */
        .card {
            box-shadow: 0 1px 4px rgba(0,0,0,.08);
            border: 1px solid #e4e8ef;
            border-radius: 6px;
            margin-bottom: 10px;
        }
        .card-header {
            background: #1a3c6e;
            color: #fff;
            padding: 7px 12px;
            border-radius: 5px 5px 0 0 !important;
            border-bottom: none;
            display: flex; align-items: center; gap: 8px;
            min-height: unset;
        }
        .card-title {
            font-size: 12.5px; font-weight: 600; margin: 0;
            letter-spacing: 0.2px; color: #fff;
        }
        .card-body { padding: 10px 12px; }

        /* ─── FORM INLINE ─────────────────────────────────────────── */
        .filter-form {
            display: flex; flex-wrap: wrap;
            align-items: flex-end; gap: 8px;
        }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label {
            font-size: 10.5px; font-weight: 700; color: #3d5170;
            margin-bottom: 3px; text-transform: uppercase; letter-spacing: 0.4px;
        }
        .form-control, .custom-select {
            height: 30px; font-size: 12px;
            border: 1px solid #cdd4de; border-radius: 4px;
            color: #2d3748; padding: 3px 8px;
            transition: border-color .2s, box-shadow .2s;
        }
        .form-control:focus, .custom-select:focus {
            border-color: #1a3c6e;
            box-shadow: 0 0 0 2px rgba(26,60,110,.12);
        }
        .date-input { width: 105px; }
        .select-doc { width: 150px; }
        .select-user { width: 180px; }

        /* ─── ICON INPUT ──────────────────────────────────────────── */
        .input-icon-wrap { position: relative; }
        .input-icon-wrap i {
            position: absolute; left: 8px; top: 50%;
            transform: translateY(-50%);
            color: #a0aec0; font-size: 10px; pointer-events: none;
        }
        .input-icon-wrap .form-control { padding-left: 24px; }

        /* ─── BUTTONS ─────────────────────────────────────────────── */
        .btn-search {
            background: #1a3c6e; border: none; color: #fff;
            font-size: 11.5px; font-weight: 600;
            padding: 5px 16px; border-radius: 4px; height: 30px;
            letter-spacing: 0.3px; cursor: pointer;
            transition: background .2s, box-shadow .2s;
            display: inline-flex; align-items: center; gap: 5px;
        }
        .btn-search:hover { background: #132d54; box-shadow: 0 3px 8px rgba(26,60,110,.3); }

        .btn-export {
            background: #155724; border: none; color: #fff;
            font-size: 11.5px; font-weight: 600;
            padding: 5px 14px; border-radius: 4px; height: 30px;
            letter-spacing: 0.3px; cursor: pointer;
            transition: background .2s; display: inline-flex; align-items: center; gap: 5px;
        }
        .btn-export:hover { background: #0d3c1a; box-shadow: 0 3px 8px rgba(21,87,36,.3); }

        /* ─── IFRAME RESULTS ──────────────────────────────────────── */
        .results-frame {
            flex: 1;
            width: 100%; border: none;
            margin: 0; padding: 0;
            display: block;
            min-height: 0;
        }
        .frame-wrapper {
            flex: 1;
            overflow: hidden;
            padding: 0 14px 10px;
        }
        .frame-card {
            border: 1px solid #e4e8ef;
            border-radius: 6px;
            overflow: hidden;
            height: 100%;
            box-shadow: 0 1px 4px rgba(0,0,0,.07);
        }
    </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper" style="height:100vh; display:flex; flex-direction:column;">

    <!-- ── Page Header ─────────────────────────────────────────── -->
    <div class="page-header-bar">
        <div class="page-icon">
            <i class="fas fa-file-invoice-dollar"></i>
        </div>
        <div>
            <h4>Registro de Ventas</h4>
            <small>Reportes &rsaquo; Documentos &rsaquo; Registro Diario</small>
        </div>
    </div>

    <!-- ── Filter Card ────────────────────────────────────────── -->
    <div class="content-area">
        <div class="card">
            <div class="card-header">
                <i class="fas fa-filter" style="font-size:11px; opacity:.85;"></i>
                <span class="card-title">Filtros de Búsqueda</span>
            </div>
            <div class="card-body">
                <form name="datos" method="POST" action="detalle.jsp" target="detalle">
                    <input type="hidden" name="f_id_caja" value="<%=s_ver_punto%>">
                    <div class="filter-form">

                        <!-- Desde -->
                        <div class="filter-group">
                            <label><i class="far fa-calendar-alt mr-1"></i>Desde</label>
                            <div class="input-icon-wrap">
                                <i class="far fa-calendar"></i>
                                <input type="text" name="f_fecha_ini" id="f_fecha_ini"
                                       class="form-control date-input"
                                       value="<%=s_fecha%>"
                                       placeholder="dd/mm/aaaa"
                                       autocomplete="off" style="cursor:pointer; background:#fff;">
                            </div>
                        </div>

                        <!-- Hasta -->
                        <div class="filter-group">
                            <label><i class="far fa-calendar-alt mr-1"></i>Hasta</label>
                            <div class="input-icon-wrap">
                                <i class="far fa-calendar"></i>
                                <input type="text" name="f_fecha_fin" id="f_fecha_fin"
                                       class="form-control date-input"
                                       value="<%=s_fecha%>"
                                       placeholder="dd/mm/aaaa"
                                       autocomplete="off" style="cursor:pointer; background:#fff;">
                            </div>
                        </div>

                        <!-- Tipo Documento -->
                        <div class="filter-group">
                            <label><i class="fas fa-file-alt mr-1"></i>Tipo Doc.</label>
                            <select name="f_tipo_doc" class="custom-select select-doc" style="width: 200px;">
                                <option value="00">Todos</option>
                                <option value="39,41" selected>FACTURA Y BOLETA ELECTRÓNICA</option>
<%
                                COMANDO = "Select tipo_doc, nombre from cont_tipo_doc " +
                                          "where detdoc = '1' " +
                                          "and tipo_doc in('39','34','41') " +
                                          "order by nombre ";
                                conn = getConexion();
                                pstmt = conn.prepareStatement(COMANDO);  
                                rset = pstmt.executeQuery();
                                while(rset.next()){ %>
                                    <option value="<%=rset.getString("tipo_doc")%>"><%=rset.getString("nombre")%></option>
<%                              } 
                                cerrar(rset, pstmt, conn);%>
                            </select>
                        </div>

                        <!-- Cajero / Usuario -->
                        <div class="filter-group">
                            <label><i class="fas fa-user mr-1"></i>Cajero</label>
                            <select name="f_id_personal_user" class="custom-select select-user" style="width: 250px;">
                                <option value="T">Todos</option>
<%
                                COMANDO = "Select a.id_personal, " +
                                          "concat(b.apepat,' ',b.apemat,', ',b.nombre) as nombre " +
                                          "from areas_usuarios a, datos_personales b " +
                                          "where a.id_personal = b.id_personal " +
                                          "GROUP BY a.id_personal, CONCAT(b.apepat,' ',b.apemat,', ',b.nombre) " +
                                          "order by nombre ";
                                conn     = getConexion();
                                pstmt = conn.prepareStatement(COMANDO);  
                                rset = pstmt.executeQuery();
                                while(rset.next()){ %>
                                <option value="<%=rset.getString("id_personal")%>"><%=rset.getString("nombre")%></option>
<%                              } 
                                cerrar(rset, pstmt, conn);%>
                            </select>
                        </div>

                        <!-- Acciones -->
                        <div class="filter-group">
                            <label>&nbsp;</label>
                            <div style="display:flex; gap:6px;">
                                <button type="submit" class="btn-search">
                                    <i class="fas fa-search"></i> Visualizar
                                </button>
                                <button type="button" class="btn-export" onclick="exportar()">
                                    <i class="fas fa-file-excel"></i> Exportar
                                </button>
                            </div>
                        </div>

                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ── Results IFrame ─────────────────────────────────────── -->
    <div class="frame-wrapper" style="flex:1; display:flex; flex-direction:column; overflow:hidden;">
        <div class="frame-card" style="flex:1;">
            <iframe name="detalle" id="detalle" class="results-frame"
                    src="vacio.jsp"
                    style="width:100%; height:100%; border:none; display:block;">
            </iframe>
        </div>
    </div>

</div><!-- /.wrapper -->

<!-- jQuery + Bootstrap 4 (sin adminlte.min.js — evita IFrame.js TypeError en páginas standalone) -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- Flatpickr -->
<script src="../../assets/plugins/flatpickr/js/flatpickr.js"></script>
<script src="../../assets/plugins/flatpickr/js/dist/l10n/es.js"></script>

<script>
    /* ── Flatpickr date pickers ────────────────────────────── */
    var fpIni = flatpickr('#f_fecha_ini', {
        locale: 'es',
        dateFormat: 'd/m/Y',
        allowInput: false
    });
    var fpFin = flatpickr('#f_fecha_fin', {
        locale: 'es',
        dateFormat: 'd/m/Y',
        allowInput: false
    });

    function exportar() {
        var fecha_ini  = document.datos.f_fecha_ini.value;
        var fecha_fin  = document.datos.f_fecha_fin.value;
        var tipo_doc   = document.datos.f_tipo_doc.value;
        var caja       = document.datos.f_id_caja.value;
        var id_user    = document.datos.f_id_personal_user.value;
        window.open(
            "detalle_exportar.jsp?f_fecha_ini=" + fecha_ini +
            "&f_fecha_fin="         + fecha_fin  +
            "&f_id_caja="           + caja       +
            "&f_tipo_doc="          + tipo_doc   +
            "&f_id_personal_user="  + id_user,
            "ExportarVentas",
            "toolbar=no,status=no,menubar=no,resizable=yes,scrollbars=yes,width=900,height=400,top=200,left=200"
        );
    }

    // Ajuste dinámico del iframe según ventana
    function resizeIframe() {
        var header = document.querySelector('.page-header-bar');
        var filterCard = document.querySelector('.content-area');
        var frameWrapper = document.querySelector('.frame-wrapper');
        if(header && filterCard && frameWrapper) {
            var used = header.offsetHeight + filterCard.offsetHeight + 22;
            frameWrapper.style.height = (window.innerHeight - used) + 'px';
        }
    }
    window.addEventListener('resize', resizeIframe);
    window.addEventListener('load', resizeIframe);
</script>
</body>
</html>
