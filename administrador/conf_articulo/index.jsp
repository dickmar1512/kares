<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    String s_next_idserv   = "";
    String s_next_idalmart = "";
    try {
        conn  = getConexion();
        COMANDO = "SELECT lpad(max(id_servicio)+1,7,'0') idart, " +
                  "concat('A',lpad(round(rand()*100000),5,'0')) idalmart FROM patron";
        pstmt = conn.prepareStatement(COMANDO);
        rset  = pstmt.executeQuery();
        if (rset.next()) {
            s_next_idserv   = rset.getString("idart");
            s_next_idalmart = rset.getString("idalmart");
        }
    } catch(Exception e) {} finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Inventario de Artículos</title>

    <!-- Local Assets -->
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/plugins/select2/css/select2.min.css">
    <link rel="stylesheet" href="../../assets/plugins/select2/css/select2-bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .no-price-badge {
            display: inline-block; background: #eef1f7; border: 1px solid #d0d8e8;
            color: #3d5170; font-size: 10px; font-weight: 700;
            padding: 1px 7px; border-radius: 4px;
        }
        .btn-add-main {
            background: #27ae60; color: #fff; border: none; border-radius: 6px;
            padding: 6px 15px; font-size: 12px; font-weight: 700;
            cursor: pointer; transition: all .2s; margin-left: auto;
        }
        .btn-add-main:hover { background: #219150; transform: translateY(-1px); box-shadow: 0 3px 8px rgba(39,174,96,0.2); }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-boxes"></i></div>
    <div>
        <h4>Gestión de Inventario de Artículos</h4>
        <small>Configuración &rsaquo; Artículos &rsaquo; Catálogo</small>
    </div>
    <button class="btn-add-main" onclick="loadForm(null, 'add')">
        <i class="fas fa-plus mr-1"></i> Nuevo Artículo
    </button>
</div>

<div class="container-fluid px-3">
    <div id="formZone" style="display:none;"></div>
    <div id="listZone">
        <div class="text-center py-5 text-muted">
            <i class="fas fa-spinner fa-spin fa-2x mb-2"></i><br>
            <small>Cargando catálogo...</small>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/datatables-bs4/js/dataTables.bootstrap4.min.js"></script>
<script src="../../assets/plugins/select2/js/select2.full.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
var dtES = {
    "sProcessing": "Procesando...", "sLengthMenu": "Mostrar _MENU_ registros",
    "sZeroRecords": "Sin resultados", "sEmptyTable": "Sin datos",
    "sInfo": "Registros _START_–_END_ de _TOTAL_", "sInfoEmpty": "0 registros",
    "sSearch": "Buscar:", "sLoadingRecords": "Cargando...",
    "oPaginate": { "sFirst":"Primero","sLast":"Último","sNext":"Sig.","sPrevious":"Ant." }
};

function loadList() {
    $('#listZone').load('lista_articulos.jsp', function(){
        // DataTable initialization handled in lista_articulos.jsp
    });
}

function loadForm(idart, mode, nombre) {
    var url = 'form.jsp?form=' + mode;
    if(idart) url += '&idart=' + idart;
    
    $('#formZone').load(url, function(){
        $('#formZone').slideDown();
        $('html,body').animate({scrollTop: 0}, 300);
    });
}

function cancelForm() {
    $('#formZone').slideUp(function(){ $(this).html(''); });
}

function cambioEstado(idart, nombre, accion) {
    Swal.fire({
        title: '¿'+accion.charAt(0).toUpperCase()+accion.slice(1)+' artículo?',
        html: '<small>Artículo: <strong>'+nombre+'</strong></small>',
        icon: accion === 'desactivar' ? 'warning' : 'question',
        showCancelButton: true,
        confirmButtonColor: accion === 'desactivar' ? '#d33' : '#27ae60',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, ' + accion,
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.getJSON('proses.jsp', {act: 'delete', idart: idart}, function(res){
                if(res.status === 'success') {
                    Swal.fire({ icon: 'success', title: '¡Actualizado!', text: res.message, timer: 1500, showConfirmButton: false });
                    loadList();
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: res.message });
                }
            });
        }
    });
}

$(function() {
    loadList();
});
</script>
</body>
</html>