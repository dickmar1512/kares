<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file= "../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file= "../seguro.jsp" %>
<%
    String s_form     = request.getParameter("form"); if(s_form==null) s_form="add";
    String s_idart    = request.getParameter("idart"); if (s_idart==null) s_idart="";
    String s_idserv   = "";
    String s_articulo = "";
    String s_cu       = "0";
    String s_unidad   = "";
    String s_idalmart = "";
    String s_tipserv  = "";
    String s_idnivel  = "";
    String s_presentacion = "";

    if ("edit".equals(s_form) && !s_idart.isEmpty()) {
        try {
            conn = getConexion();
            COMANDO = "SELECT a.idart, a.idservicio, a.idalmart, servicio(a.idservicio) articulo, a.cu, a.unidad, " +
                      "s.tipo_servicio, s.id_nivel, s.art_presentacion " +
                      "FROM articulo a LEFT JOIN patron s ON s.id_servicio = a.idservicio WHERE a.idart=?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_idart);
            rset = pstmt.executeQuery();
            if(rset.next()) {
                s_idart    = rset.getString("idart");
                s_idserv   = rset.getString("idservicio");
                s_idalmart = rset.getString("idalmart");
                s_articulo = rset.getString("articulo");
                s_cu       = rset.getString("cu");
                s_unidad   = rset.getString("unidad");
                s_tipserv  = rset.getString("tipo_servicio");
                s_idnivel  = rset.getString("id_nivel");
                s_presentacion = rset.getString("art_presentacion");
            }
        } catch(Exception e) { out.println(e.getMessage()); } finally { cerrar(rset, pstmt, conn); }
    } else {
        // Generate new IDs for 'add' mode
        try {
            conn = getConexion();
            COMANDO = "SELECT lpad(max(id_servicio)+1,7,'0') idart, " +
                      "concat('A',lpad(round(rand()*100000),5,'0')) idalmart FROM patron ";
            pstmt = conn.prepareStatement(COMANDO);
            rset = pstmt.executeQuery();
            if(rset.next()) {
                s_idserv   = rset.getString("idart");
                s_idalmart = rset.getString("idalmart");
            }
        } catch(Exception e) {} finally { cerrar(rset, pstmt, conn); }
    }
%>

<div class="card card-outline card-primary shadow-sm" style="border-top: 3px solid #1a3c6e;">
    <div class="card-header bg-white">
        <h3 class="card-title text-dark">
            <i class="fas <%= "edit".equals(s_form) ? "fa-edit" : "fa-plus-circle" %> mr-1 text-primary"></i>
            <%= "edit".equals(s_form) ? "Modificar Artículo" : "Registrar Nuevo Artículo" %>
        </h3>
        <div class="card-tools">
            <button type="button" class="btn btn-tool" onclick="cancelForm()"><i class="fas fa-times"></i></button>
        </div>
    </div>
    
    <form id="frmArticulo" action="proses.jsp?act=<%= "edit".equals(s_form) ? "update" : "insert" %>" method="POST">
        <div class="card-body">
            <input type="hidden" name="idart" value="<%=s_idart%>">
            <input type="hidden" name="idserv" value="<%=s_idserv%>">
            
            <div class="row">
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Código de Sistema</label>
                        <input type="text" class="form-control form-control-sm font-weight-bold" name="idalmart" value="<%=s_idalmart%>" readonly style="background:#f8fafc; color:#1a3c6e;">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Nombre del Artículo / Producto</label>
                        <input type="text" class="form-control form-control-sm" name="nombre" value="<%=s_articulo%>" autocomplete="off" required placeholder="Ingrese nombre completo">
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Costo Unitario</label>
                        <div class="input-group input-group-sm">
                            <div class="input-group-prepend"><span class="input-group-text">S/</span></div>
                            <input type="number" step="0.01" class="form-control" name="pcompra" value="<%=s_cu%>" required>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mt-2">
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Unidad de Medida</label>
                        <select class="form-control form-control-sm select2-form" name="unidad" required>
                            <option value="">-- Seleccione --</option>
                            <%
                            try {
                                conn = getConexion();
                                pstmt = conn.prepareStatement("SELECT idpres, nombre FROM presentacion ORDER BY nombre");
                                rset = pstmt.executeQuery();
                                while(rset.next()) {
                                    String sel = rset.getString("idpres").equals(s_unidad) ? "selected" : "";
                                    out.print("<option value='"+rset.getString("idpres")+"' "+sel+">"+rset.getString("nombre")+"</option>");
                                }
                            } catch(Exception e){} finally { cerrar(rset, pstmt, conn); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Categoría / Tipo Serv.</label>
                        <select class="form-control form-control-sm select2-form" name="tipserv" required>
                            <option value="">-- Seleccione --</option>
                            <%
                            try {
                                conn = getConexion();
                                pstmt = conn.prepareStatement("SELECT tipo_servicio, nombre FROM tipo_servicio ORDER BY nombre");
                                rset = pstmt.executeQuery();
                                while(rset.next()) {
                                    String sel = rset.getString("tipo_servicio").equals(s_tipserv) ? "selected" : "";
                                    out.print("<option value='"+rset.getString("tipo_servicio")+"' "+sel+">"+rset.getString("nombre")+"</option>");
                                }
                            } catch(Exception e){} finally { cerrar(rset, pstmt, conn); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Nivel de Almacén</label>
                        <select class="form-control form-control-sm select2-form" name="idnivel" required>
                            <option value="">-- Seleccione --</option>
                            <%
                            try {
                                conn = getConexion();
                                pstmt = conn.prepareStatement("SELECT id_nivel, nombre FROM nivel ORDER BY nombre");
                                rset = pstmt.executeQuery();
                                while(rset.next()) {
                                    String sel = rset.getString("id_nivel").equals(s_idnivel) ? "selected" : "";
                                    out.print("<option value='"+rset.getString("id_nivel")+"' "+sel+">"+rset.getString("nombre")+"</option>");
                                }
                            } catch(Exception e){} finally { cerrar(rset, pstmt, conn); }
                            %>
                        </select>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="font-weight-bold small text-muted text-uppercase">Presentación Detalle</label>
                        <input type="text" class="form-control form-control-sm" name="presentacion" value="<%=s_presentacion%>" placeholder="Ej: Caja x 12">
                    </div>
                </div>
            </div>
        </div>

        <div class="card-footer bg-light text-right">
            <button type="button" class="btn btn-default btn-sm px-4 mr-2" onclick="cancelForm()">
                <i class="fas fa-times mr-1"></i> Cancelar
            </button>
            <button type="submit" class="btn btn-primary btn-sm px-4" style="background:#1a3c6e; border:none;">
                <i class="fas fa-save mr-1"></i> Guardar Artículo
            </button>
        </div>
    </form>
</div>

<script>
$(function(){
    $('.select2-form').select2({ theme: 'bootstrap4', width: '100%' });

    $('#frmArticulo').on('submit', function(e){
        e.preventDefault();
        const $form = $(this);
        const $btn = $form.find('button[type="submit"]');
        const originalHtml = $btn.html();

        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Guardando...');

        $.ajax({
            url: $form.attr('action'),
            type: 'POST',
            data: $form.serialize(),
            dataType: 'json',
            success: function(res) {
                if(res.status === 'success') {
                    Swal.fire({ icon: 'success', title: '¡Logrado!', text: res.message, timer: 1500, showConfirmButton: false });
                    cancelForm();
                    loadList();
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: res.message });
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function() {
                Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo completar la operación.' });
                $btn.prop('disabled', false).html(originalHtml);
            }
        });
    });
});
</script>