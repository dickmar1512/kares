<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    // Pre-cargar opciones para el modal
    StringBuilder sbUbigeo = new StringBuilder();
    StringBuilder sbEstCiv = new StringBuilder();
    StringBuilder sbTipDoc = new StringBuilder();

    // Cargar ubigeo (distritos)
    try {
        conn = getConexion();
        pstmt = conn.prepareStatement("SELECT codigo, nombre FROM ubigeo WHERE codigo LIKE 'PE%' AND nivel = '3' ORDER BY nombre");
        rset = pstmt.executeQuery();
        while (rset.next()) {
            sbUbigeo.append("<option value=\"").append(rset.getString("codigo")).append("\">")
                    .append(rset.getString("nombre")).append(" (").append(rset.getString("codigo")).append(")</option>");
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally { 
        cerrar(rset, pstmt, conn); 
    }

    // Cargar estados civiles
    try {
        conn = getConexion();
        pstmt = conn.prepareStatement("SELECT abreviatura, nombre FROM estado_civil ORDER BY abreviatura");
        rset = pstmt.executeQuery();
        while (rset.next()) {
            sbEstCiv.append("<option value=\"").append(rset.getString("abreviatura")).append("\">")
                    .append(rset.getString("nombre")).append("</option>");
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally { 
        cerrar(rset, pstmt, conn); 
    }

    // Cargar tipos de documento
    try {
        conn = getConexion();
        pstmt = conn.prepareStatement("SELECT tipo_doc, nombre FROM doc_identidad ORDER BY orden");
        rset = pstmt.executeQuery();
        while (rset.next()) {
            sbTipDoc.append("<option value=\"").append(rset.getString("tipo_doc")).append("\">")
                    .append(rset.getString("nombre")).append("</option>");
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally { 
        cerrar(rset, pstmt, conn); 
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Directorio de Personas</title>
  <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
  <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
  <link rel="stylesheet" href="../../assets/plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
  <link rel="stylesheet" href="../../assets/plugins/select2/css/select2.min.css">
  <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
  <link rel="stylesheet" href="../../assets/css/kares-grid.css">
  <style>
    body { background: #f4f6f9 !important; font-size:13px; color:#1c2b45; font-family:'Source Sans Pro', sans-serif; }
    .pg-hdr { position: sticky; top: 0; z-index: 100; }
    .f-src { display:flex; gap:10px; padding:15px; background:#fff; border-bottom:1px solid #e2e8f0; }
    .f-src input { border:1.5px solid #cdd4de; border-radius:6px; padding:5px 10px; font-size:12px; outline:none; }
    .f-src input:focus { border-color:#1a3c6e; }
    .f-src button { background:#1a3c6e; color:#fff; border:none; border-radius:6px; padding:5px 15px; font-weight:600; cursor:pointer; font-size:12px; }
    .f-src button:hover { opacity:.9; }

    /* Modal Styles */
    .mf { font-family:'Source Sans Pro', sans-serif; text-align:left; }
    .mf-hdr { display:flex; align-items:center; gap:9px; padding-bottom:12px; border-bottom:1px solid #e2e8f0; margin-bottom:14px; }
    .mf-ico { width:34px; height:34px; border-radius:7px; display:grid; place-items:center; font-size:14px; flex-shrink:0; }
    .mf-ico.add { background:#e8f0fb; color:#1a3c6e; }
    .mf-ico.edt { background:#fff3e0; color:#b45309; }
    .mf-ttl { font-size:15px; font-weight:700; color:#1a3c6e; margin:0; line-height:1.2; }
    .mf-sub { font-size:11px; color:#6c757d; margin:0; }
    .mf-grid { display:grid; grid-template-columns:90px 1fr 90px 1fr; gap:7px 10px; align-items:center; }
    .mf-col-3 { grid-column: span 3; }
    .mf-lbl { font-size:11px; font-weight:700; color:#6c757d; text-transform:uppercase; letter-spacing:.05em; text-align:right; }
    .mf-inp, .mf-sel { width:100%; padding:5px 8px; border:1.5px solid #cdd4de; border-radius:6px; font-size:12px; color:#1c2b45; outline:none; background:#fff; box-sizing:border-box; }
    .mf-inp:focus, .mf-sel:focus { border-color:#1a3c6e; box-shadow:0 0 0 3px rgba(26,60,110,.1); }
    .mf-hr { grid-column: 1 / -1; width: 100%; border: 0; border-top: 1px solid #e2e8f0; margin: 8px 0; }
    .mf-ftr { display:flex; justify-content:flex-end; gap:7px; padding-top:13px; border-top:1px solid #e2e8f0; margin-top:13px; }
    .mf-btn { padding:6px 15px; border:none; border-radius:6px; font-size:12px; font-weight:700; cursor:pointer; transition:all .2s; display:inline-flex; align-items:center; gap:5px; }
    .mf-btn.cancel { background:#f4f6f9; color:#6c757d; border:1.5px solid #cdd4de; }
    .mf-btn.save { background:#1a3c6e; color:#fff; }

    .swal2-popup { width:700px !important; max-width:90vw !important; border-radius:10px !important; padding: 20px !important; }
    .swal2-html-container { margin:0 !important; padding:0 !important; overflow:visible !important; }
    .c-name { font-weight:600; color:#1c2b45; }
    
    .swal2-popup .select2-container { width:100% !important; }
    .swal2-popup .select2-selection--single { height:30px !important; border:1.5px solid #cdd4de !important; border-radius:6px !important; }
    .swal2-popup .select2-selection__rendered { line-height:28px !important; font-size:12px !important; }
    .swal2-popup .select2-results__option { font-size:12px !important; }
    .swal2-popup .select2-search__field { font-size:12px !important; }

    @media (max-width: 768px) {
        .f-src { flex-direction: column; }
        .mf-grid { grid-template-columns: 1fr; gap: 5px; }
        .mf-lbl { text-align: left; }
        .mf-grid .mf-lbl { grid-column: 1; }
        .mf-grid input, .mf-grid select, .mf-col-3 { grid-column: 1; }
    }
  </style>
</head>
<body class="hold-transition">

<div id="tplOpts" style="display:none">
  <select id="tpl_ubi"><option value=""> SELECCIONE </option><%=sbUbigeo.toString()%></select>
  <select id="tpl_est"><option value=""> SELECCIONE </option><%=sbEstCiv.toString()%></select>
  <select id="tpl_doc"><option value=""> SELECCIONE </option><%=sbTipDoc.toString()%></select>
  <select id="tpl_sex"><option value=""> SELECCIONE </option><option value="M">Masculino</option><option value="F">Femenino</option></select>
</div>

<div class="page-header-bar pg-hdr">
  <div class="page-icon"><i class="fas fa-users"></i></div>
  <div>
    <h4>Directorio de Personas</h4>
    <small>Configuración &rsaquo; Personal &rsaquo; Directorio</small>
  </div>
  <button class="btn-kares ml-auto" type="button" onclick="abrirAdd();" style="padding: 6px 15px; font-weight:700;">
    <i class="fas fa-plus"></i> Nueva Persona
  </button>
</div>

<div class="container-fluid py-3 px-3">
  <div class="card-kares mb-3">
    <form id="frmBuscar" class="f-src" onsubmit="buscar(event)">
      <div style="display:flex; flex-direction:column; gap:4px; flex:1;">
        <label style="font-size:0.7rem; color:var(--cm); margin:0;">Búsqueda por Documento</label>
        <div style="display:flex; gap:10px;">
          <input type="text" id="s_dni" placeholder="DNI / RUC" style="flex:1; min-width:120px;">
          <button type="button" onclick="buscarPorDocumento()"><i class="fas fa-search"></i> Buscar</button>
        </div>
      </div>
      <div style="border-left:1px solid var(--cb); margin:0 10px;"></div>
      <div style="display:flex; flex-direction:column; gap:4px; flex:2;">
        <label style="font-size:0.7rem; color:var(--cm); margin:0;">Búsqueda por Nombres</label>
        <div style="display:flex; gap:10px; flex-wrap:wrap;">
          <input type="text" id="s_pat" placeholder="Ap. Paterno" style="flex:1; min-width:100px;">
          <input type="text" id="s_mat" placeholder="Ap. Materno" style="flex:1; min-width:100px;">
          <input type="text" id="s_nom" placeholder="Nombres" style="flex:1; min-width:100px;">
          <button type="button" onclick="buscarPorNombres()"><i class="fas fa-search"></i> Buscar</button>
        </div>
      </div>
    </form>
  </div>

  <div class="card-kares">
    <div class="card-header">
      <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
      <span class="card-title">Resultados de Búsqueda</span>
    </div>
    <div class="card-body p-0">
      <table id="dtPac" class="table table-kares table-sm w-60">
        <thead>
          <tr>
            <th class="text-center" width="5%">#</th>
            <th width="30%">Apellidos y Nombres</th>
            <th class="text-center" width="8%">Edad</th>
            <th class="text-center" width="15%">Doc. Identidad</th>
            <th class="text-center" width="15%">Fec. Nac.</th>
            <th class="text-center" width="12%">Acciones</th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/select2/js/select2.full.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
// Definir funciones en el ámbito global
let tablaPac = null;

// Función de escape HTML global
window.escapeHtml = function(text) {
  if (!text) return '';
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
};

// Funciones de búsqueda globales
window.buscarPorDocumento = function() {
  const dni = $('#s_dni').val().trim();
  if (dni === '') {
    Swal.fire('Atención', 'Ingrese el número de documento', 'warning');
    return;
  }
  realizarBusqueda({ tipo: 'dni', dni: dni });
};

window.buscarPorNombres = function() {
  const pat = $('#s_pat').val().trim();
  const mat = $('#s_mat').val().trim();
  const nom = $('#s_nom').val().trim();
  
  if (pat === '' && mat === '' && nom === '') {
    Swal.fire('Atención', 'Ingrese al menos un nombre o apellido', 'warning');
    return;
  }
  realizarBusqueda({ tipo: 'nom', pat: pat, mat: mat, nom: nom });
};

function realizarBusqueda(params) {
  if (!tablaPac) {
    Swal.fire('Error', 'La tabla no está disponible. Recargue la página.', 'error');
    return;
  }

  Swal.fire({ title: 'Buscando...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });

  $.ajax({
    url: 'buscar_ajax.jsp',
    data: params,
    type: 'GET',
    dataType: 'text',           // recibir como texto puro
    success: function(txt) {
      Swal.close();

      let data;
      try {
        data = JSON.parse(txt);  // parsear manualmente
      } catch(ex) {
        console.error('JSON inválido recibido:', txt);
        Swal.fire('Error', 'Respuesta inválida del servidor', 'error');
        return;
      }

      if (!Array.isArray(data)) {
        if (data.error) { Swal.fire('Error', data.error, 'error'); return; }
        data = [data]; // si viene objeto suelto, envolverlo
      }

      tablaPac.clear();

      if (data.length === 0) {
        Swal.fire('Información', 'No se encontraron resultados', 'info');
      } else {
        $.each(data, function(i, row) {
          console.log('fila', i, '→ id:', row.id, '| cliente:', row.cliente); // ← debug
          let id  = row.id       || '';
          let nom = window.escapeHtml(row.cliente)  || '(sin nombre)';
          console.log('nom:', nom); // ← debug
          const btnE = '<button type="button" class="btn-kares mr-1" title="Editar"'+
                          'onclick="abrirEdit(\'' + id + '\')">'+
                          '<i class="fas fa-pen"></i></button>';
          const btnD = '<button type="button" class="btn btn-xs btn-outline-danger" title="Eliminar"'+
                          'style="border-radius:4px; padding:3px 8px;" '+
                          'onclick="eliminar(\'' + id + '\',\'' + nom + '\')">'+
                          '<i class="fas fa-trash"></i></button>';
          tablaPac.row.add([
            i + 1,
            '<span class="c-name">' + nom + '</span>',
            row.edad   || '-',
            row.doc    || '-',
            row.fecnac || '-',
            btnE + btnD
          ]);
        });
      }
      tablaPac.draw();
    },
    error: function(jqXHR, status, err) {
      Swal.close();
      console.error('Error AJAX:', status, err, jqXHR.responseText);
      Swal.fire('Error', 'Error en la comunicación con el servidor', 'error');
    }
  });
}

// Inicialización cuando el DOM esté listo
$(document).ready(function() {
  // Inicializar DataTable
  try {
    if ($.fn.DataTable.isDataTable('#dtPac')) {
      $('#dtPac').DataTable().destroy();
    }
    tablaPac = $('#dtPac').DataTable({
      paging: true,
      pageLength: 15,
      lengthMenu: [[10, 15, 25, 50, -1], [10, 15, 25, 50, 'Todos']],
      searching: false,
      ordering: true,
      info: true,
      autoWidth: false,
      columnDefs: [{ orderable: false, targets: [0, 5] }],
      dom: 'ltp',
      language: {
        sProcessing:   'Procesando...',
        sLengthMenu:   'Mostrar _MENU_ registros',
        sZeroRecords:  'Sin resultados',
        sEmptyTable:   'Ingrese criterios de b\u00fasqueda',
        sInfo:         '_START_\u2013_END_ de _TOTAL_',
        sInfoEmpty:    '0\u20130 de 0',
        sInfoFiltered: '(de _MAX_ totales)',
        oPaginate: { sFirst: '\u00ab', sLast: '\u00bb', sNext: '\u203a', sPrevious: '\u2039' }
      }
    });
    console.log('DataTable inicializada correctamente');
  } catch(err) {
    console.error('Error al inicializar DataTable:', err);
    tablaPac = null;
  }
});

window.getOpts = function(id) { 
  const tpl = document.getElementById(id);
  return tpl ? tpl.innerHTML : '';
};

window.buildForm = function(mode, d) {
  d = d || {};
  var isE      = mode === 'edit';
  var titulo   = isE ? 'Modificar Persona' : 'Nueva Persona';
  var btnTexto = isE ? 'Guardar cambios'   : 'Registrar';
  var btnIcono = isE ? 'fa-save'           : 'fa-plus';
  var actVal   = isE ? 'update'            : 'insert';
  var icoMode  = isE ? 'fa-pen'            : 'fa-plus';
  var clsMode  = isE ? 'edt'               : 'add';
  var clsBtn   = isE ? 'save edt'          : 'save';
  var id       = d.id || '';
  
  // Detectar si es jurídica
  var tipo_per = (d.tipdoc === 'E' || (d.apepat === '-' && d.apemat === '-')) ? 'J' : 'N';

  return '<div class="mf">' +
    '<div class="mf-hdr">' +
      '<div class="mf-ico ' + clsMode + '">' +
        '<i class="fas ' + icoMode + '"></i>' +
      '</div>' +
      '<div>' +
        '<p class="mf-ttl">' + titulo + '</p>' +
        '<p class="mf-sub">Complete los datos de la persona</p>' +
      '</div>' +
    '</div>' +
    '<form id="mfFrm" onsubmit="window.guardar(event)">' +
      '<input type="hidden" name="act" value="' + actVal + '">' +
      '<input type="hidden" name="f_id_personal" value="' + id + '">' +
      '<div class="mf-grid" style="grid-column: 1/-1; display:flex; gap:20px; margin-bottom:10px; justify-content:center;">' +
        '<label style="cursor:pointer;"><input type="radio" name="f_tipo_persona" value="N" onchange="window.toggleTipoPersona()" ' + (tipo_per === 'N' ? 'checked' : '') + ' ' + (isE ? 'disabled' : '') + '> <i class="fas fa-user"></i> Persona Natural</label>' +
        '<label style="cursor:pointer;"><input type="radio" name="f_tipo_persona" value="J" onchange="window.toggleTipoPersona()" ' + (tipo_per === 'J' ? 'checked' : '') + ' ' + (isE ? 'disabled' : '') + '> <i class="fas fa-building"></i> Persona Jurídica</label>' +
        (isE ? '<input type="hidden" name="f_tipo_persona" value="' + tipo_per + '">' : '') +
      '</div>' +
      '<hr class="mf-hr" style="grid-column: 1/-1; margin-bottom:10px;">' +
      
      '<div class="mf-grid">' +

        '<span class="mf-lbl t-nat">Nombres*</span>' +
        '<input class="mf-inp t-nat mf-col-3" name="f_nombre_n" value="' + (tipo_per === 'N' ? window.escapeHtml(d.nombre || '') : '') + '">' +

        '<span class="mf-lbl t-jur" style="display:none;">Razón Social*</span>' +
        '<input class="mf-inp t-jur mf-col-3" name="f_nombre_j" style="display:none;" value="' + (tipo_per === 'J' ? window.escapeHtml(d.nombre || '') : '') + '">' +

        '<span class="mf-lbl t-nat">Ap. Paterno*</span>' +
        '<input class="mf-inp t-nat mf-col-3" name="f_apepat" value="' + (tipo_per === 'N' ? window.escapeHtml(d.apepat || '') : '') + '">' +

        '<span class="mf-lbl t-nat">Ap. Materno*</span>' +
        '<input class="mf-inp t-nat mf-col-3" name="f_apemat" value="' + (tipo_per === 'N' ? window.escapeHtml(d.apemat || '') : '') + '">' +

        '<span class="mf-lbl t-nat">Sexo</span>' +
        '<select class="mf-sel t-nat" name="f_sexo" id="f_sexo">' + window.getOpts('tpl_sex') + '</select>' +

        '<span class="mf-lbl t-nat">Fec. Nac.</span>' +
        '<input type="date" id="f_nacfec" class="mf-inp t-nat" name="f_nacfec" value="' + (tipo_per === 'N' ? (d.nacfec || '') : '') + '" placeholder="DD/MM/YYYY">' +

        '<span class="mf-lbl t-nat">Lugar Nac.</span>' +
        '<input class="mf-inp t-nat mf-col-3" name="f_naclug" value="' + (tipo_per === 'N' ? window.escapeHtml(d.naclug || '') : '') + '">' +

        '<hr class="mf-hr t-nat">' +

        '<span class="mf-lbl t-nat">Tipo Doc.</span>' +
        '<select class="mf-sel mf-s2 t-nat" name="f_tipdoc" id="f_tipdoc">' + window.getOpts('tpl_doc') + '</select>' +

        '<span class="mf-lbl t-nat">Num. Doc.</span>' +
        '<input class="mf-inp t-nat" name="f_numdoc" value="' + (tipo_per === 'N' ? window.escapeHtml(d.numdoc || '') : '') + '" maxlength="15">' +

        '<span class="mf-lbl t-jur" style="display:none;">Tipo Doc.</span>' +
        '<select class="mf-sel mf-s2 t-jur" name="f_tipdoc_j" id="f_tipdoc_j" style="display:none;">' +
           '<option value="E">RUC</option>' +
           '<option value="0">NO DOMICILIADO</option>' +
        '</select>' +

        '<span class="mf-lbl t-jur" style="display:none;">Número*</span>' +
        '<input class="mf-inp t-jur" name="f_ruc_j" style="display:none;" value="' + (tipo_per === 'J' ? window.escapeHtml(d.ruc || d.numdoc || '') : '') + '" maxlength="15">' +

        '<span class="mf-lbl t-nat">Est. Civil</span>' +
        '<select class="mf-sel mf-s2 t-nat mf-col-3" name="f_estciv" id="f_estciv">' + window.getOpts('tpl_est') + '</select>' +

        '<hr class="mf-hr">' +

        '<span class="mf-lbl">Dirección</span>' +
        '<input class="mf-inp mf-col-3" name="f_direcc" value="' + window.escapeHtml(d.direcc || '') + '">' +

        '<span class="mf-lbl">Referencia</span>' +
        '<input class="mf-inp mf-col-3" name="f_domref" value="' + window.escapeHtml(d.domref || '') + '">' +

        '<span class="mf-lbl">Distrito</span>' +
        '<select class="mf-sel mf-s2 mf-col-3" name="f_domloc" id="f_domloc">' + window.getOpts('tpl_ubi') + '</select>' +

        '<hr class="mf-hr">' +

        '<span class="mf-lbl">Celular</span>' +
        '<input class="mf-inp" name="f_fono2" value="' + window.escapeHtml(d.fono2 || '') + '">' +

        '<span class="mf-lbl">Tel. Fijo</span>' +
        '<input class="mf-inp" name="f_fono1" value="' + window.escapeHtml(d.fono1 || '') + '">' +

        '<span class="mf-lbl">Email</span>' +
        '<input class="mf-inp mf-col-3" name="f_email" type="email" value="' + window.escapeHtml(d.email || '') + '">' +

        '<span class="mf-lbl">Observación</span>' +
        '<input class="mf-inp mf-col-3" name="f_observacion" value="' + window.escapeHtml(d.observacion || '') + '">' +

      '</div>' +
      '<div class="mf-ftr">' +
        '<button type="button" class="mf-btn cancel" onclick="Swal.close()">' +
          '<i class="fas fa-times"></i> Cancelar' +
        '</button>' +
        '<button type="submit" class="mf-btn ' + clsBtn + '">' +
          '<i class="fas ' + btnIcono + '"></i> ' + btnTexto +
        '</button>' +
      '</div>' +
    '</form>' +
  '</div>';
};

window.toggleTipoPersona = function() {
    var tipo = $('input[name="f_tipo_persona"]:checked').val() || $('input[type="hidden"][name="f_tipo_persona"]').val();
    if(tipo === 'N') {
        $('.t-nat').show();
        $('.t-nat.mf-s2').next('.select2-container').show();
        $('.t-jur').hide();
        $('.t-jur.mf-s2').next('.select2-container').hide();
        $('input[name="f_nombre_n"]').prop('required', true);
        $('input[name="f_apepat"]').prop('required', true);
        $('input[name="f_apemat"]').prop('required', true);
        $('input[name="f_nombre_j"]').prop('required', false);
        $('input[name="f_ruc_j"]').prop('required', false);
    } else {
        $('.t-nat').hide();
        $('.t-nat.mf-s2').next('.select2-container').hide();
        $('.t-jur').show();
        $('.t-jur.mf-s2').next('.select2-container').show();
        $('input[name="f_nombre_n"]').prop('required', false);
        $('input[name="f_apepat"]').prop('required', false);
        $('input[name="f_apemat"]').prop('required', false);
        $('input[name="f_nombre_j"]').prop('required', true);
        $('input[name="f_ruc_j"]').prop('required', true);
    }
};

window.initS2 = function(d) {
  setTimeout(function() {
    const container = Swal.getHtmlContainer();
    if (!container) return;
    
    $(container).find('.mf-s2').each(function() {
      if ($(this).data('select2')) {
        $(this).select2('destroy');
      }
      $(this).select2({ 
        dropdownParent: $(container), 
        width: '100%', 
        minimumResultsForSearch: 6 
      });
    });
    
    if (d) {
      if (d.tipdoc) {
          $('#f_tipdoc').val(d.tipdoc).trigger('change');
          $('#f_tipdoc_j').val(d.tipdoc).trigger('change');
      }
      if (d.estciv) $('#f_estciv').val(d.estciv).trigger('change');
      if (d.domloc) $('#f_domloc').val(d.domloc).trigger('change');
      if (d.sexo) $('#f_sexo').val(d.sexo);
    }
    window.toggleTipoPersona(); // Call to initialize fields properly
  }, 100);
};

window.abrirAdd = function() {
  Swal.fire({
    html: window.buildForm('add', {}),
    showConfirmButton: false,
    allowOutsideClick: false,
    didOpen: function() { 
      window.initS2(null); 
    }
  });
};

window.abrirEdit = function(id) {
  Swal.fire({
    title: 'Cargando...',
    allowOutsideClick: false,
    didOpen: () => { Swal.showLoading(); }
  });
  
  $.getJSON('get_pac_ajax.jsp', { id: id })
    .done(function(data) {
      if (data.error) {
        Swal.fire('Error', data.error, 'error');
        return;
      }
      Swal.fire({
        html: window.buildForm('edit', data),
        showConfirmButton: false,
        allowOutsideClick: false,
        didOpen: function() { 
          window.initS2(data); 
        }
      });
    })
    .fail(function() { 
      Swal.fire('Error', 'No se pudo cargar los datos', 'error'); 
    });
};

window.guardar = function(e) {
  e.preventDefault();
  const form = $(e.target);
  
  // Validaciones adicionales
  const email = form.find('[name="f_email"]').val();
  if (email && !window.isValidEmail(email)) {
    Swal.fire('Error', 'El formato del email no es válido', 'error');
    return;
  }
  
  Swal.fire({
    title: 'Guardando...',
    allowOutsideClick: false,
    didOpen: () => { Swal.showLoading(); }
  });
  
  $.post('proses.jsp', form.serialize())
    .done(function(res) {
      if (res && res.ok) {
        Swal.fire('Éxito', res.msg, 'success')
          .then(() => {
            // Recargar la búsqueda actual
            if ($('#s_dni').val() || $('#s_pat').val() || $('#s_mat').val() || $('#s_nom').val()) {
              if ($('#s_dni').val()) {
                window.buscarPorDocumento();
              } else {
                window.buscarPorNombres();
              }
            }
          });
      } else {
        Swal.fire('Error', res ? res.msg : 'Error desconocido', 'error');
      }
    })
    .fail(function(jqXHR) {
      console.error('Error en guardado:', jqXHR);
      Swal.fire('Error', 'Error de conexión con el servidor', 'error');
    });
};

window.eliminar = function(id, nombre) {
  Swal.fire({
    title: '¿Eliminar persona?',
    html: `Persona: <strong>${window.escapeHtml(nombre)}</strong><br><span class="text-danger">Esta acción no se puede deshacer.</span>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#c0392b',
    confirmButtonText: '<i class="fas fa-trash"></i> Eliminar',
    cancelButtonText: 'Cancelar'
  }).then((result) => {
    if (result.isConfirmed) {
      Swal.fire({
        title: 'Eliminando...',
        allowOutsideClick: false,
        didOpen: () => { Swal.showLoading(); }
      });
      
      $.post('proses.jsp', { act: 'delete', f_id_personal: id })
        .done(function(res) {
          if (res && res.ok) {
            Swal.fire('Eliminado', res.msg, 'success')
              .then(() => {
                if ($('#s_dni').val() || $('#s_pat').val() || $('#s_mat').val() || $('#s_nom').val()) {
                  if ($('#s_dni').val()) {
                    window.buscarPorDocumento();
                  } else {
                    window.buscarPorNombres();
                  }
                }
              });
          } else {
            Swal.fire('Error', res ? res.msg : 'No se pudo eliminar', 'error');
          }
        })
        .fail(function() { 
          Swal.fire('Error', 'Error de conexión con el servidor', 'error'); 
        });
    }
  });
};

window.isValidEmail = function(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
};
</script>
</body>
</html>