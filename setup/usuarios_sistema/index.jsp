<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Usuarios del Sistema - KARES</title>
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/plugins/select2/css/select2.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .badge-status { border-radius: 20px; padding: 4px 10px; font-size: 10px; font-weight: 700; }
        
        /* Modal Styles */
        .mf-grid { display: grid; grid-template-columns: 100px 1fr; gap: 10px; align-items: center; text-align: left; }
        .mf-lbl { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; text-align: right; }
        .mf-inp { width: 100%; padding: 6px 10px; border: 1.5px solid #cdd4de; border-radius: 6px; font-size: 12px; }
        .mf-inp:focus { border-color: #1a3c6e; outline: none; }
        
        .select2-container--default .select2-selection--single { height: 34px !important; border: 1.5px solid #cdd4de !important; border-radius: 6px !important; }
        .select2-selection__rendered { line-height: 32px !important; font-size: 12px !important; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-user-shield"></i></div>
    <div>
        <h4>Usuarios del Sistema</h4>
        <small>Sistema &rsaquo; Seguridad &rsaquo; Usuarios</small>
    </div>
    <button class="btn-kares ml-auto" onclick="abrirAdd()" style="padding: 6px 15px; font-weight:700;">
        <i class="fas fa-plus mr-2"></i> Nuevo Usuario
    </button>
</div>

<div class="container-fluid px-3">
    <div class="card-kares">
        <div class="card-header">
            <i class="fas fa-users" style="font-size:11px; opacity:.85;"></i>
            <span class="card-title">Listado de Usuarios</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive p-3">
                <table id="tblUsers" class="table table-kares table-hover w-100">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nombre / Razón Social</th>
                        <th>Usuario (Login)</th>
                        <th>Estado</th>
                        <th class="text-center">Acciones</th>
                    </tr>
                </thead>
            </table>
            </div>
        </div>
    </div>
</div>

<!-- SCRIPTS -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/datatables-bs4/js/dataTables.bootstrap4.min.js"></script>
<script src="../../assets/plugins/select2/js/select2.full.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
    let table;
    $(document).ready(function() {
        table = $('#tblUsers').DataTable({
            ajax: { url: 'get_usuarios.jsp', dataSrc: '' },
            columns: [
                { data: 'id' },
                { data: 'nombre' },
                { data: 'login' },
                { 
                    data: 'estado',
                    render: function(data) {
                        return data == '1' 
                            ? '<span class="badge badge-success badge-status">ACTIVO</span>'
                            : '<span class="badge badge-danger badge-status">INACTIVO</span>';
                    }
                },
                {
                    data: null,
                    className: 'text-center',
                    render: function(data) {
                        return `
                            <button class="btn btn-sm btn-outline-primary mr-1" onclick='abrirEdit(${JSON.stringify(data)})' title="Editar">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="eliminar('${data.id}')" title="Quitar Acceso">
                                <i class="fas fa-user-slash"></i>
                            </button>
                        `;
                    }
                }
            ],
            language: {
                sProcessing:   'Procesando...',
                sLengthMenu:   'Mostrar _MENU_ registros',
                sZeroRecords:  'Sin resultados',
                sEmptyTable:   'Ingrese criterios de b\u00fasqueda',
                sInfo:         '_START_\u2013_END_ de _TOTAL_',
                sInfoEmpty:    '0\u20130 de 0',
                sInfoFiltered: '(de _MAX_ totales)',
                oPaginate: { sFirst: '\u00ab', sLast: '\u00bb', sNext: '\u203a', sPrevious: '\u2039' }
            },
            order: [[1, 'asc']]
        });
    });

    window.abrirAdd = function() {
        Swal.fire({
            title: 'Registrar Nuevo Usuario',
            html: `
                <div class="mf-grid mt-3">
                    <span class="mf-lbl">Persona:</span>
                    <select id="f_persona" class="mf-inp select2-ajax" style="width:100%"></select>
                    
                    <span class="mf-lbl">Usuario:</span>
                    <input id="f_login" class="mf-inp" placeholder="Nombre de usuario">
                    
                    <span class="mf-lbl">Clave:</span>
                    <input id="f_pass" type="password" class="mf-inp" placeholder="Contraseña">
                    
                    <span class="mf-lbl">Repetir:</span>
                    <input id="f_pass2" type="password" class="mf-inp" placeholder="Repetir contraseña">
                </div>
            `,
            showCancelButton: true,
            confirmButtonText: 'Guardar',
            cancelButtonText: 'Cancelar',
            didOpen: () => {
                $('.select2-ajax').select2({
                    dropdownParent: Swal.getHtmlContainer(),
                    placeholder: 'Buscar persona por nombre o DNI...',
                    minimumInputLength: 3,
                    ajax: {
                        url: 'get_personas_ajax.jsp',
                        dataType: 'json',
                        delay: 250,
                        data: (params) => ({ q: params.term }),
                        processResults: (data) => ({ results: data })
                    }
                });
            },
            preConfirm: () => {
                const id_pers = $('#f_persona').val();
                const login = $('#f_login').val();
                const pass = $('#f_pass').val();
                const pass2 = $('#f_pass2').val();
                
                if(!id_pers) return Swal.showValidationMessage('Debe seleccionar una persona');
                if(!login) return Swal.showValidationMessage('Debe ingresar un login');
                if(!pass) return Swal.showValidationMessage('Debe ingresar una clave');
                if(pass !== pass2) return Swal.showValidationMessage('Las claves no coinciden');
                
                return { act: 'add', id: id_pers, login, pass };
            }
        }).then((result) => {
            if(result.isConfirmed) guardar(result.value);
        });
    };

    window.abrirEdit = function(d) {
        Swal.fire({
            title: 'Modificar Usuario',
            html: `
                <div class="mf-grid mt-3">
                    <span class="mf-lbl">Persona:</span>
                    <input class="mf-inp" value="${d.nombre}" readonly style="background:#f1f5f9">
                    
                    <span class="mf-lbl">Usuario:</span>
                    <input id="f_login" class="mf-inp" value="${d.login}" placeholder="Nombre de usuario">
                    
                    <span class="mf-lbl">Nueva Clave:</span>
                    <input id="f_pass" type="password" class="mf-inp" placeholder="Opcional: Dejar en blanco para no cambiar">
                </div>
            `,
            showCancelButton: true,
            confirmButtonText: 'Actualizar',
            cancelButtonText: 'Cancelar',
            preConfirm: () => {
                const login = $('#f_login').val();
                const pass = $('#f_pass').val();
                if(!login) return Swal.showValidationMessage('Debe ingresar un login');
                return { act: 'update', id: d.id, login, pass };
            }
        }).then((result) => {
            if(result.isConfirmed) guardar(result.value);
        });
    };

    function guardar(data) {
        $.ajax({
            url: 'proses.jsp',
            method: 'POST',
            data: data,
            dataType: 'json',
            success: function(res) {
                if(res.ok) {
                    Swal.fire('¡Éxito!', res.msg, 'success');
                    table.ajax.reload();
                } else {
                    Swal.fire('Error', res.msg, 'error');
                }
            }
        });
    }

    window.eliminar = function(id) {
        Swal.fire({
            title: '¿Quitar acceso?',
            text: 'Se eliminarán las credenciales de este usuario. La persona seguirá existiendo pero no podrá entrar al sistema.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            confirmButtonText: 'Sí, quitar acceso'
        }).then((result) => {
            if(result.isConfirmed) {
                guardar({ act: 'delete', id: id });
            }
        });
    }
</script>
</body>
</html>
