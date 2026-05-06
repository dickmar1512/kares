<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    // Obtener datos actuales de la empresa
    // Asumimos que hay una sola empresa configurada
    String id_empresa = "";
    String ruc = "";
    String razon_social = "";
    String nombre_comercial = "";
    String ubigeo = "";
    String codigo_local = "";
    String direccion = "";
    String departamento = "";
    String provincia = "";
    String distrito = "";
    String email = "";
    String telefono = "";
    String usuario_sol = "";
    String clave_sol = "";
    String cert_ruta = "";
    String cert_clave = "";
    String logo = "";

    try {
        conn = getConexion();
        // Intentamos obtener la primera empresa
        COMANDO = "SELECT e.*, p.ruc as p_ruc, p.nombre as p_nombre, p.direccion as p_direccion, p.fono as p_fono, p.email as p_email " +
                  "FROM datos_empresas e " +
                  "INNER JOIN datos_personales p ON e.id_empresa = p.id_personal " +
                  "LIMIT 1";
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            id_empresa = rset.getString("id_empresa");
            ruc = rset.getString("p_ruc");
            razon_social = rset.getString("p_nombre");
            nombre_comercial = rset.getString("nombre_comercial") != null ? rset.getString("nombre_comercial") : "";
            ubigeo = rset.getString("ubigeo") != null ? rset.getString("ubigeo") : "";
            codigo_local = rset.getString("codigo_local") != null ? rset.getString("codigo_local") : "";
            direccion = rset.getString("DIRECCION") != null ? rset.getString("DIRECCION") : rset.getString("p_direccion");
            departamento = rset.getString("departamento") != null ? rset.getString("departamento") : "";
            provincia = rset.getString("provincia") != null ? rset.getString("provincia") : "";
            distrito = rset.getString("distrito") != null ? rset.getString("distrito") : "";
            email = rset.getString("email") != null ? rset.getString("email") : rset.getString("p_email");
            telefono = rset.getString("TELEFONO") != null ? rset.getString("TELEFONO") : rset.getString("p_fono");
            usuario_sol = rset.getString("usuario_sol") != null ? rset.getString("usuario_sol") : "";
            clave_sol = rset.getString("clave_sol") != null ? rset.getString("clave_sol") : "";
            cert_ruta = rset.getString("cert_ruta") != null ? rset.getString("cert_ruta") : "";
            cert_clave = rset.getString("cert_clave") != null ? rset.getString("cert_clave") : "";
            logo = rset.getString("logo") != null ? rset.getString("logo") : "";
        }
    } catch (Exception e) {
        // Manejar error
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Configuración de Empresa</title>
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        :root {
            --primary-color: #1a3c6e;
            --accent-color: #2563eb;
        }
        body { background-color: #f4f6f9; font-size: 0.9rem; }
        .card-kares { border-radius: 8px; border: none; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); margin-bottom: 1.5rem; }
        .card-kares .card-header { background-color: #fff; border-bottom: 1px solid #edf2f7; padding: 1rem 1.25rem; }
        .card-kares .card-title { color: var(--primary-color); font-weight: 700; font-size: 1.1rem; }
        .form-group label { font-weight: 600; color: #4a5568; margin-bottom: 0.3rem; }
        .form-control:focus { border-color: var(--accent-color); box-shadow: 0 0 0 2px rgba(37,99,235,0.1); }
        .btn-save { background-color: var(--primary-color); color: #fff; font-weight: 600; padding: 0.6rem 2rem; border-radius: 6px; transition: all 0.2s; }
        .btn-save:hover { background-color: #112a50; color: #fff; transform: translateY(-1px); }
        .section-icon { width: 32px; height: 32px; background-color: #eff6ff; color: var(--accent-color); border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; margin-right: 0.75rem; }
        .logo-preview { width: 120px; height: 120px; border: 2px dashed #cbd5e0; border-radius: 8px; display: flex; align-items: center; justify-content: center; overflow: hidden; margin-bottom: 1rem; background-color: #fff; }
        .logo-preview img { max-width: 100%; max-height: 100%; object-fit: contain; }
    </style>
</head>
<body class="p-3">

<div class="container-fluid">
    <div class="row mb-3">
        <div class="col-12">
            <h4 class="font-weight-bold text-dark"><i class="fas fa-cog mr-2 text-muted"></i>Configuración General de la Empresa</h4>
            <p class="text-muted small">Administre la información fiscal, credenciales SUNAT y certificado digital.</p>
        </div>
    </div>

    <form id="form-config" autocomplete="off">
        <input type="hidden" name="id_empresa" value="<%=id_empresa%>">
        
        <div class="row">
            <!-- Columna Izquierda: Datos de la Empresa -->
            <div class="col-lg-8">
                <div class="card card-kares">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <div class="section-icon"><i class="fas fa-building"></i></div>
                            <h3 class="card-title m-0">Datos de la Empresa Emisora</h3>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4 form-group">
                                <label>RUC</label>
                                <input type="text" name="ruc" class="form-control" value="<%=ruc%>" maxlength="11" >
                            </div>
                            <div class="col-md-8 form-group">
                                <label>Razón Social</label>
                                <input type="text" name="razon_social" class="form-control" value="<%=razon_social%>">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <label>Nombre Comercial</label>
                                <input type="text" name="nombre_comercial" class="form-control" value="<%=nombre_comercial%>" placeholder="Nombre de fantasía">
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Ubigeo</label>
                                <input type="text" name="ubigeo" class="form-control" value="<%=ubigeo%>" maxlength="6">
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Cód. Local / Anexo</label>
                                <input type="text" name="codigo_local" class="form-control" value="<%=codigo_local%>" placeholder="0000">
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Dirección Fiscal</label>
                            <input type="text" name="direccion" class="form-control" value="<%=direccion%>">
                        </div>
                        <div class="row">
                            <div class="col-md-4 form-group">
                                <label>Departamento</label>
                                <input type="text" name="departamento" class="form-control" value="<%=departamento%>">
                            </div>
                            <div class="col-md-4 form-group">
                                <label>Provincia</label>
                                <input type="text" name="provincia" class="form-control" value="<%=provincia%>">
                            </div>
                            <div class="col-md-4 form-group">
                                <label>Distrito</label>
                                <input type="text" name="distrito" class="form-control" value="<%=distrito%>">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <label>Email Electrónico</label>
                                <input type="email" name="email" class="form-control" value="<%=email%>">
                            </div>
                            <div class="col-md-6 form-group">
                                <label>Teléfono</label>
                                <input type="text" name="telefono" class="form-control" value="<%=telefono%>">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Columna Derecha: Credenciales y Logo -->
            <div class="col-lg-4">
                <!-- Credenciales SOL -->
                <div class="card card-kares">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <div class="section-icon text-warning"><i class="fas fa-key"></i></div>
                            <h3 class="card-title m-0">Credenciales SOL (SUNAT)</h3>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="form-group">
                            <label>Usuario SOL</label>
                            <input type="text" name="usuario_sol" class="form-control" value="<%=usuario_sol%>" placeholder="MODDATOS">
                        </div>
                        <div class="form-group">
                            <label>Clave SOL</label>
                            <div class="input-group">
                                <input type="password" name="clave_sol" id="clave_sol" class="form-control" value="<%=clave_sol%>">
                                <div class="input-group-append">
                                    <button class="btn btn-outline-secondary" type="button" onclick="togglePass('clave_sol')">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Certificado y Logo -->
                <div class="card card-kares">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <div class="section-icon text-success"><i class="fas fa-certificate"></i></div>
                            <h3 class="card-title m-0">Certificado y Logo</h3>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="form-group">
                            <label>Ruta Certificado (.p12)</label>
                            <input type="text" name="cert_ruta" class="form-control" value="<%=cert_ruta%>" placeholder="C:/sunat/cert.p12">
                        </div>
                        <div class="form-group">
                            <label>Contraseña Certificado</label>
                            <div class="input-group">
                                <input type="password" name="cert_clave" id="cert_clave" class="form-control" value="<%=cert_clave%>">
                                <div class="input-group-append">
                                    <button class="btn btn-outline-secondary" type="button" onclick="togglePass('cert_clave')">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <hr>
                        <div class="form-group text-center">
                            <label class="d-block text-left">Logo Corporativo</label>
                            <div class="d-flex flex-column align-items-center">
                                <div class="logo-preview">
                                    <% if(!logo.isEmpty()){ %>
                                        <img src="../../assets/images/<%=logo%>" id="img-preview">
                                    <% } else { %>
                                        <i class="fas fa-image fa-3x text-light" id="img-placeholder"></i>
                                        <img src="" id="img-preview" style="display:none;">
                                    <% } %>
                                </div>
                                <input type="text" name="logo" class="form-control form-control-sm" value="<%=logo%>" placeholder="nombre_logo.png">
                                <small class="text-muted">Nombre del archivo en assets/images/</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-2 mb-5">
            <div class="col-12 text-center">
                <button type="button" class="btn btn-save shadow" onclick="guardarConfig()">
                    <i class="fas fa-save mr-2"></i>Guardar Cambios
                </button>
            </div>
        </div>
    </form>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
    function togglePass(id) {
        const input = document.getElementById(id);
        const icon = event.currentTarget.querySelector('i');
        if (input.type === "password") {
            input.type = "text";
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = "password";
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    function guardarConfig() {
        const formData = $('#form-config').serialize();
        
        Swal.fire({
            title: '¿Guardar cambios?',
            text: "Se actualizará la configuración de la empresa.",
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#1a3c6e',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Sí, guardar',
            cancelButtonText: 'Cancelar'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'save_ajax.jsp',
                    type: 'POST',
                    data: formData,
                    dataType: 'json',
                    beforeSend: function() {
                        Swal.fire({
                            title: 'Guardando...',
                            allowOutsideClick: false,
                            didOpen: () => { Swal.showLoading(); }
                        });
                    },
                    success: function(response) {
                        if (response.success) {
                            if(response.id_empresa) {
                                $('input[name="id_empresa"]').val(response.id_empresa);
                            }
                            Swal.fire({
                                icon: 'success',
                                title: '¡Guardado!',
                                text: response.message,
                                timer: 2000,
                                showConfirmButton: false
                            });
                        } else {
                            Swal.fire('Error', response.message, 'error');
                        }
                    },
                    error: function() {
                        Swal.fire('Error', 'No se pudo conectar con el servidor.', 'error');
                    }
                });
            }
        });
    }
</script>

</body>
</html>
