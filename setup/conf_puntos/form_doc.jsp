<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    String s_modo = request.getParameter("modo"); if (s_modo == null) s_modo = "I";
    s_punto = request.getParameter("f_punto"); if (s_punto == null) s_punto = "";
    String s_id = request.getParameter("f_id"); if (s_id == null) s_id = "";
    
    String s_nom_punto = "", s_serie = "", s_numero = "", s_ip_doc = "", s_nom_doc = "", s_tipo_doc = "", s_id_docimp = "", s_copias = "1";

    try {
        conn = getConexion();
        if ("U".equals(s_modo)) {
            COMANDO = "SELECT * FROM puntos_doc WHERE id = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_serie = rset.getString("serie"); if (s_serie == null) s_serie = "";
                s_numero = rset.getString("numero"); if (s_numero == null) s_numero = "";
                s_ip_doc = rset.getString("ip"); if (s_ip_doc == null) s_ip_doc = "";
                s_tipo_doc = rset.getString("tipo_doc"); if (s_tipo_doc == null) s_tipo_doc = "";
                s_id_docimp = rset.getString("id_docimp"); if (s_id_docimp == null) s_id_docimp = "";
                s_copias = rset.getString("copias"); if (s_copias == null) s_copias = "1";
            }
            cerrar(rset, pstmt, null);
        }
        
        COMANDO = "SELECT nombre FROM puntos WHERE punto = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_punto = rset.getString("nombre");
        cerrar(rset, pstmt, null);
    } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=s_modo.equals("I") ? "Asignar" : "Editar"%> Documento</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        .form-card { border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); border: none; }
        .form-control { border-radius: 8px; padding: 0.6rem 1rem; border: 1px solid #dee2e6; }
        .form-control:focus { box-shadow: 0 0 0 3px rgba(40,167,69,0.15); }
        .btn-modern { border-radius: 8px; padding: 0.6rem 2rem; font-weight: 600; transition: all 0.2s; }
        .btn-modern:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    </style>
</head>
<body class="hold-transition bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-xl-6">
            <div class="card form-card">
                <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
                    <div class="d-flex align-items-center">
                        <a href="documentos.jsp?f_punto=<%=s_punto%>" class="btn btn-sm btn-outline-secondary rounded-circle mr-3" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <div>
                            <h4 class="mb-0 font-weight-bold"><%=s_modo.equals("I") ? "Asignar" : "Editar"%> Documento</h4>
                            <small class="text-muted">Punto: <strong><%=s_nom_punto%></strong></small>
                        </div>
                    </div>
                </div>
                <div class="card-body p-4">
                    <form id="docForm" action="update_form_doc.jsp" method="post">
                        <input type="hidden" name="modo" value="<%=s_modo%>">
                        <input type="hidden" name="f_punto" value="<%=s_punto%>">
                        <input type="hidden" name="f_id" value="<%=s_id%>">

                        <div class="form-group mb-3">
                            <label class="text-muted small font-weight-bold mb-1">Tipo de Comprobante</label>
                            <select name="f_tipo_doc" class="form-control custom-select" required>
                                <option value="">Seleccione Documento...</option>
                                <%
                                    try {
                                        conn = getConexion();
                                        COMANDO = "SELECT tipo_doc, nombre FROM cont_tipo_doc ORDER BY nombre";
                                        pstmt = conn.prepareStatement(COMANDO);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            String tid = rset.getString("tipo_doc");
                                            String tnom = rset.getString("nombre");
                                %>
                                <option value="<%=tid%>" <%=tid.equals(s_tipo_doc) ? "selected" : ""%>><%=tnom%></option>
                                <%
                                        }
                                    } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
                                %>
                            </select>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Serie</label>
                                <input type="text" name="f_serie" class="form-control" value="<%=s_serie%>" placeholder="Ej: F001" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Siguiente Número</label>
                                <input type="number" name="f_numero" class="form-control" value="<%=s_numero%>" placeholder="Ej: 1" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Nro Copias</label>
                                <input type="number" name="f_copias" class="form-control" value="<%=s_copias%>" min="1" max="5">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="text-muted small font-weight-bold mb-1">Formato Impresi\u00f3n</label>
                                <select name="f_id_docimp" class="form-control custom-select">
                                    <option value="">Seleccione Formato...</option>
                                    <%
                                        try {
                                            conn = getConexion();
                                            COMANDO = "SELECT id_docimp, nombre FROM ventas_impdoc ORDER BY nombre";
                                            pstmt = conn.prepareStatement(COMANDO);
                                            rset = pstmt.executeQuery();
                                            while(rset.next()) {
                                                String fid = rset.getString("id_docimp");
                                                String fnom = rset.getString("nombre");
                                    %>
                                    <option value="<%=fid%>" <%=fid.equals(s_id_docimp) ? "selected" : ""%>><%=fnom%></option>
                                    <%
                                            }
                                        } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
                                    %>
                                </select>
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="text-muted small font-weight-bold mb-1">IP de Impresora / Terminal</label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text"><i class="fas fa-network-wired"></i></span>
                                </div>
                                <input type="text" name="f_ip" class="form-control" value="<%=s_ip_doc%>" placeholder="Ej: 192.168.1.100">
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-end">
                            <a href="documentos.jsp?f_punto=<%=s_punto%>" class="btn btn-light btn-modern mr-2">Cancelar</a>
                            <button type="submit" class="btn btn-success btn-modern" id="saveBtn">
                                <i class="fas fa-save mr-2"></i><%=s_modo.equals("I") ? "Asignar" : "Guardar"%>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
    $(function() {
        $('#docForm').on('submit', function(e) {
            e.preventDefault();
            const $btn = $('#saveBtn');
            const originalHtml = $btn.html();
            
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-2"></i> Procesando...');

            $.ajax({
                url: 'update_form_doc.jsp',
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: '\u00a1Guardado!',
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        }).then(() => {
                            window.location.href = 'documentos.jsp?f_punto=<%=s_punto%>';
                        });
                    } else {
                        Swal.fire({ icon: 'error', title: 'Error', text: response.message });
                        $btn.prop('disabled', false).html(originalHtml);
                    }
                },
                error: function() {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operaci\u00f3n.' });
                    $btn.prop('disabled', false).html(originalHtml);
                }
            });
        });
    });
</script>
</body>
</html>
