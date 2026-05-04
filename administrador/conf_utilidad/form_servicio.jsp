<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_servicio = request.getParameter("f_id_servicio"); if(s_id_servicio==null) s_id_servicio="";
    String modo          = request.getParameter("modo");           if(modo==null) modo="I";
    String s_idart       = request.getParameter("idart");          if(s_idart==null) s_idart="";
    String s_nombre      = "";
    String s_porc        = "0";
    String s_ut          = "0";
    String s_cu          = "0";
    String s_pvf         = "0";
    String s_pv_calc     = "0";   // precio de venta calculado actual

    /* ── Carga datos para INSERTAR (artículo sin precio) ──────── */
    if(modo.equals("I")) {
        try {
            COMANDO = "Select nombre from patron where id_servicio = ?";
            conn  = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_servicio);
            rset  = pstmt.executeQuery();
            if(rset.next()) s_nombre = rset.getString("nombre"); if(s_nombre==null) s_nombre="";
        } catch(Exception e) {
        } finally { cerrar(rset, pstmt, conn); }
    }

    /* ── Carga datos para EDITAR (artículo con precio) ────────── */
    if(modo.equals("U")) {
        try {
            COMANDO = "select idservicio, servicio(idservicio) nombre, " +
                      "porcutil, ifnull(utilfijo,0) utilfijo " +
                      "from utilidad where idservicio = ?";
            conn  = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_servicio);
            rset  = pstmt.executeQuery();
            if(rset.next()) {
                s_nombre = rset.getString("nombre");
                s_porc   = rset.getString("porcutil");
                s_ut     = rset.getString("utilfijo"); if(s_ut==null) s_ut="0";
            }
        } catch(Exception e) {
        } finally { cerrar(rset, pstmt, conn); }

        if(!s_ut.equals("0")) {
            try {
                COMANDO = "select format(cu+?,2) pvf from articulo where idservicio=?";
                conn  = getConexion();
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_ut);
                pstmt.setString(2, s_id_servicio);
                rset  = pstmt.executeQuery();
                if(rset.next()) s_pvf = rset.getString("pvf");
            } catch(Exception e) {
            } finally { cerrar(rset, pstmt, conn); }
        }
    }

    /* ── Costo unitario actual ────────────────────────────────── */
    try {
        COMANDO = "select format(cu,2) cu from articulo where idservicio=?";
        conn  = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_servicio);
        rset  = pstmt.executeQuery();
        if(rset.next()) s_cu = rset.getString("cu"); if(s_cu==null) s_cu="0";
    } catch(Exception e) {
    } finally { cerrar(rset, pstmt, conn); }
%>

<!-- ── Form card (se inyecta en #formZone del index) ────────── -->
<div class="card" id="formCard" style="border-top: 3px solid #1a3c6e;">
    <div class="card-header">
        <i class="fas fa-<%= modo.equals("I") ? "plus-circle" : "edit" %>" style="font-size:11px; opacity:.85;"></i>
        <span class="card-title">
            <%= modo.equals("I") ? "Configurar Precio — " : "Editar Margen — " %>
            <span style="font-weight:400; color:#b8cfef;"><%=s_nombre%></span>
        </span>
        <button type="button" onclick="cancelForm()"
                style="margin-left:auto; background:transparent; border:none; color:#fff; cursor:pointer; font-size:16px;" title="Cerrar">
            <i class="fas fa-times"></i>
        </button>
    </div>
    <div class="card-body">
        <form action="update.jsp" method="post" name="datos1" id="frmUtilidad">
            <input type="hidden" name="idserv" value="<%=s_id_servicio%>">
            <input type="hidden" name="modo"   value="<%=modo%>">
            <input type="hidden" name="f_cu"   value="<%=s_cu%>">

            <div class="row">
                <!-- Nombre (solo lectura) -->
                <div class="col-md-12 mb-2">
                    <label class="field-label">Artículo / Servicio</label>
                    <input type="text" name="f_nombre" class="form-control form-control-sm"
                           value="<%=s_nombre%>" readonly style="background:#f8fafc; color:#3d5170; font-weight:600;">
                </div>

                <!-- Costo Unitario -->
                <div class="col-md-3">
                    <label class="field-label"><i class="fas fa-dollar-sign mr-1" style="color:#7b8ea8;"></i>Costo Unit. (CU)</label>
                    <div class="input-group input-group-sm">
                        <div class="input-group-prepend">
                            <span class="input-group-text" style="font-size:11px; padding:3px 8px;">S/</span>
                        </div>
                        <input type="number" name="f_cu_editable" id="f_cu" step="0.01" min="0"
                               class="form-control form-control-sm" value="<%=s_cu%>"
                               oninput="recalcular()" style="font-weight:600; color:#1a3c6e;">
                    </div>
                    <small class="text-muted" style="font-size:10.5px;">Costo de compra del artículo</small>
                </div>

                <!-- Ganancia % -->
                <div class="col-md-2">
                    <label class="field-label"><i class="fas fa-percentage mr-1" style="color:#27ae60;"></i>Ganancia %</label>
                    <div class="input-group input-group-sm">
                        <input type="number" name="f_porganancia" id="f_porgananc" step="0.01" min="0"
                               class="form-control form-control-sm" value="<%=s_porc%>"
                               oninput="recalcular()" placeholder="0">
                        <div class="input-group-append">
                            <span class="input-group-text" style="font-size:11px; padding:3px 8px;">%</span>
                        </div>
                    </div>
                    <small class="text-muted" style="font-size:10.5px;">Margen porcentual</small>
                </div>

                <!-- Precio Venta Fijo -->
                <div class="col-md-3">
                    <label class="field-label"><i class="fas fa-tag mr-1" style="color:#e67e22;"></i>Precio Venta Fijo</label>
                    <div class="input-group input-group-sm">
                        <div class="input-group-prepend">
                            <span class="input-group-text" style="font-size:11px; padding:3px 8px;">S/</span>
                        </div>
                        <input type="number" name="f_pvf" id="f_pvf" step="0.01" min="0"
                               class="form-control form-control-sm" value="<%=s_pvf.equals("0") ? "" : s_pvf%>"
                               oninput="recalcular()" placeholder="Opcional">
                    </div>
                    <small class="text-muted" style="font-size:10.5px;">Precio directo (opcional)</small>
                </div>

                <!-- Preview Precio Venta (calculado) -->
                <div class="col-md-4">
                    <label class="field-label"><i class="fas fa-calculator mr-1" style="color:#1a3c6e;"></i>Precio de Venta Estimado</label>
                    <div id="pvPreview" style="background:#eef1f7; border:1px solid #d0d8e8; border-radius:4px;
                                               padding:5px 10px; font-size:16px; font-weight:700; color:#1a3c6e; min-height:32px;">
                        S/ <%=s_pvf.equals("0") ? s_cu : s_pvf%>
                    </div>
                    <small class="text-muted" style="font-size:10.5px;">Se recalcula automáticamente</small>
                </div>
            </div>

            <!-- Divider -->
            <hr style="margin: 10px 0; border-color:#e4e8ef;">

            <div class="d-flex gap-2 align-items-center">
                <button type="submit" class="btn-save">
                    <i class="fas fa-save"></i>
                    <%= modo.equals("I") ? " Registrar Utilidad" : " Actualizar Utilidad" %>
                </button>
                <button type="button" onclick="cancelForm()" class="btn-cancel">
                    <i class="fas fa-times"></i> Cancelar
                </button>
                <div class="ml-auto" style="font-size:11px; color:#a0aec0;">
                    <i class="fas fa-info-circle mr-1"></i>
                    Si se ingresa % y Precio Fijo, prevalece el <strong>Precio Fijo</strong>.
                </div>
            </div>
        </form>
    </div>
</div>

<style>
    .field-label {
        font-size: 10.5px; font-weight: 700; color: #3d5170;
        text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 3px; display: block;
    }
    .form-control-sm { height: 30px; font-size: 12px; border-color: #cdd4de; }
    .form-control-sm:focus { border-color: #1a3c6e; box-shadow: 0 0 0 2px rgba(26,60,110,.12); }
    .input-group-text { background: #eef1f7; border-color: #cdd4de; color: #3d5170; }
    .btn-save {
        background: #1a3c6e; border: none; color: #fff; font-size: 12px; font-weight: 600;
        padding: 6px 18px; border-radius: 4px; cursor: pointer;
        display: inline-flex; align-items: center; gap: 5px; transition: background .2s;
    }
    .btn-save:hover { background: #132d54; }
    .btn-cancel {
        background: #fff; border: 1px solid #cdd4de; color: #4a5568; font-size: 12px;
        padding: 5px 14px; border-radius: 4px; cursor: pointer;
        display: inline-flex; align-items: center; gap: 5px; transition: border-color .2s;
    }
    .btn-cancel:hover { border-color: #c0392b; color: #c0392b; }
</style>

<script>
function recalcular() {
    var cu    = parseFloat($('#f_cu').val())    || 0;
    var pct   = parseFloat($('#f_porgananc').val()) || 0;
    var pvf   = parseFloat($('#f_pvf').val())   || 0;
    var pv    = 0;

    if(pvf > 0) {
        pv = pvf;
    } else if(pct > 0) {
        pv = cu + (cu * pct / 100);
    } else {
        pv = cu;
    }
    $('#pvPreview').text('S/ ' + pv.toFixed(2));
}

// Actualizar f_cu hidden cuando cambia el editable
$('#f_cu').on('input', function(){
    $('input[name="f_cu"]').val($(this).val());
});

$(function(){
    $('html,body').animate({ scrollTop: $('#formCard').offset().top - 70 }, 300);

    $('#frmUtilidad').on('submit', function(e){
        e.preventDefault();
        var $btn = $(this).find('button[type="submit"]');
        var originalHtml = $btn.html();
        
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Procesando...');

        $.ajax({
            url: 'update.jsp',
            type: 'POST',
            data: $(this).serialize(),
            dataType: 'json',
            success: function(res) {
                if(res.status === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: '¡Éxito!',
                        text: res.message,
                        timer: 2000,
                        showConfirmButton: false
                    }).then(() => {
                        cancelForm();
                        loadList();
                    });
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: res.message });
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function() {
                Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo procesar la solicitud.' });
                $btn.prop('disabled', false).html(originalHtml);
            }
        });
    });
});
</script>
