<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file= "../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Configuración de Utilidad</title>

    <!-- Local Assets -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .alert-compact {
            padding: 7px 12px; font-size: 12px; border-radius: 4px;
            display: flex; align-items: center; gap: 8px; margin-bottom: 10px;
        }
        .alert-success-compact { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .no-price-badge {
            display: inline-block; background: #fff3e0; border: 1px solid #f5c96e;
            color: #9c5f00; font-size: 10px; font-weight: 700;
            padding: 1px 7px; border-radius: 10px;
        }
        .pct { text-align: right; color: #27ae60; font-weight: 600; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<!-- ── Page Header ──────────────────────────────────────────── -->
<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-percentage"></i></div>
    <div>
        <h4>Configuración de Utilidad / Margen de Ganancia</h4>
        <small>Configuración &rsaquo; Artículos &rsaquo; Precios y Márgenes</small>
    </div>
</div>

<div class="container-fluid px-3">
    <div id="alertZone"></div>
    <div id="formZone"></div>
    <div id="listZone">
        <div class="text-center py-4 text-muted">
            <i class="fas fa-spinner fa-spin fa-2x mb-2"></i><br>
            <small>Cargando datos...</small>
        </div>
    </div>
</div>

<!-- Local Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/datatables-bs4/js/dataTables.bootstrap4.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
var dtES = {
    "sProcessing": "Procesando...", "sLengthMenu": "Mostrar _MENU_ registros",
    "sZeroRecords": "No se encontraron resultados", "sEmptyTable": "Sin datos disponibles",
    "sInfo": "Registros del _START_ al _END_ de _TOTAL_", "sInfoEmpty": "0 registros",
    "sInfoFiltered": "(filtrado de _MAX_)", "sSearch": "Buscar:",
    "sLoadingRecords": "Cargando...",
    "oPaginate": { "sFirst":"Primero","sLast":"Último","sNext":"Sig.","sPrevious":"Ant." }
};

function loadList(alertCode) {
    var url = 'lista_art_utilidad.jsp';
    if(alertCode) url += '?alert=' + alertCode;
    $('#listZone').load(url, function(){
        initDataTables();
    });
}

function initDataTables() {
    if($.fn.DataTable.isDataTable('#tblSinPrecio')) $('#tblSinPrecio').DataTable().destroy();
    if($.fn.DataTable.isDataTable('#tblConPrecio')) $('#tblConPrecio').DataTable().destroy();
    $('#tblSinPrecio').DataTable({ language: dtES, pageLength: 10, order:[[2,'asc']] });
    $('#tblConPrecio').DataTable({ language: dtES, pageLength: 15, order:[[2,'asc']] });
}

function loadForm(idServicio, modo, idart) {
    var url = 'form_servicio.jsp?f_id_servicio=' + idServicio + '&modo=' + modo;
    if(idart) url += '&idart=' + idart;
    $('#formZone').load(url, function(){
        $('#formZone').show();
        $('html,body').animate({scrollTop: $('#formZone').offset().top - 60}, 300);
    });
}

function cancelForm() {
    $('#formZone').html('').hide();
}

$(function() {
    loadList();
});
</script>
</body>
</html>