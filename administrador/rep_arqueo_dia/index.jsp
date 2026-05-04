<%@ include file= "../../config/database.jsp" %> 
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    String s_fecha = request.getParameter("f_fecha"); if(s_fecha == null) s_fecha = fecha;

    try {
        COMANDO = "Select date_format(sysdate(),'%d/%m/%Y') hoy from dual";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        if(rset.next()) s_fecha = rset.getString("hoy");
    } catch(Exception e) {
        out.println("<!-- Error fecha: " + e.getMessage() + " -->");
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Arqueo Diario de Caja</title>

    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="../../assets/css/administrador/rep_arqueo_dia/index.css">
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

    <div class="page-header-bar">
        <div class="page-icon"><i class="fas fa-cash-register"></i></div>
        <div>
            <h4>Arqueo Diario de Caja</h4>
            <small>Reportes &rsaquo; Ventas &rsaquo; Arqueo</small>
        </div>
    </div>

    <div class="content-area">
        <div class="card-kares">
            <div class="card-header">
                <i class="fas fa-filter" style="font-size:11px; opacity:.85;"></i>
                <span class="card-title">Criterios de Filtrado</span>
            </div>
            <div class="card-body">
                <form name="datos" method="POST" action="detalle.jsp" target="detalle">
                    <div class="filter-form">
                        <div class="filter-group">
                            <label><i class="far fa-calendar-alt"></i> Fecha</label>
                            <div class="input-icon-wrap">
                                <i class="far fa-calendar"></i>
                                <input type="text" id="f_fecha_ini" name="f_fecha_ini"
                                       class="form-control date-input"
                                       value="<%=s_fecha%>"
                                       placeholder="dd/mm/aaaa"
                                       autocomplete="off" style="cursor:pointer; background:#fff;">
                            </div>
                        </div>
                        <div class="filter-group">
                            <label>&nbsp;</label>
                            <button type="submit" class="btn-search">
                                <i class="fas fa-search"></i> Visualizar
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="frame-wrapper">
        <div class="frame-card">
            <iframe name="detalle" id="detalle" class="results-frame"
                    src="vacio.html" style="width:100%; height:100%; border:none;">
            </iframe>
        </div>
    </div>

</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/es.js"></script>
<script src="../../assets/js/administrador/rep_arqueo_dia/index.js"></script>
</body>
</html>
