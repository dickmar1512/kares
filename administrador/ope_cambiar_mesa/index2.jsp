<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%@ include file="bajar_datos.jsp"%>
<%
    String s_idm = request.getParameter("idm");
    if (s_idm == null) s_idm = "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cambio de Mesa | Kares ERP</title>

    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <style>
        body { font-family: 'Source Sans Pro', sans-serif; background: #f4f6f9; font-size: 13px; }
        .info-box-custom { min-height: 80px; margin-bottom: 1.5rem; }
    </style>
</head>
<body class="hold-transition sidebar-mini">

<div class="page-header-bar">
    <div class="page-icon"><i class="fas fa-exchange-alt"></i></div>
    <div>
        <h4>Cambio de Mesa</h4>
        <small>Operaciones &rsaquo; Ventas &rsaquo; Mesas</small>
    </div>
</div>

<div class="container-fluid px-3">
    <div class="row">
        <!-- Columna Izquierda: Formulario de Cambio -->
        <div class="col-md-4">
            <div class="card-kares mb-3">
                <div class="card-header">
                    <i class="fas fa-edit" style="font-size:11px; opacity:.85;"></i>
                    <span class="card-title">Acción de Cambio</span>
                </div>
                <div class="card-body">
                    <div class="info-box info-box-custom bg-light border shadow-sm mb-4">
                        <span class="info-box-icon bg-info"><i class="fas fa-chair"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text text-muted uppercase" style="font-size:10px; font-weight:700;">Mesa Actual</span>
                            <span class="info-box-number h4 mb-0"><%=s_idm%></span>
                        </div>
                    </div>

                    <form id="formCambioMesa">
                        <input type="hidden" name="f_idmp" value="<%=s_idm%>">
                        <div class="form-group mb-3">
                            <label style="font-size:11px; font-weight:700; color:#4a5568; text-transform:uppercase;">Mesa Destino <small class="text-muted">(Solo disponibles)</small></label>
                            <select name="f_idmc" id="f_idmc" class="form-control form-control-sm" required>
                                <option value="">Seleccione mesa...</option>
                                <% 
                                    try {
                                        conn = getConexion();
                                        String sqlMesas = "SELECT idm, descripcion FROM mesas WHERE estado ='0' ORDER BY CAST(idm AS UNSIGNED)";
                                        pstmt = conn.prepareStatement(sqlMesas);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) { %>
                                            <option value="<%=rset.getString("idm")%>">Mesa <%=rset.getString("descripcion")%></option>
                                        <% }
                                    } catch(Exception e) { e.printStackTrace(); }
                                    finally { cerrar(rset, pstmt, null); }
                                %>
                            </select>
                        </div>
                        <button type="submit" class="btn-kares w-100" style="padding:10px; font-weight:700;">
                            <i class="fas fa-check-circle mr-2"></i>Confirmar Cambio
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Columna Derecha: Detalle de Consumo -->
        <div class="col-md-8">
            <div class="card-kares">
                <div class="card-header">
                    <i class="fas fa-list" style="font-size:11px; opacity:.85;"></i>
                    <span class="card-title">Detalle de Consumo en Mesa <%=s_idm%></span>
                    <span class="badge badge-warning ml-auto" id="itemCount">0 items</span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-kares table-hover mb-0">
                                    <thead class="bg-light">
                                        <tr>
                                            <th style="width: 40px">#</th>
                                            <th>Fecha/Hora</th>
                                            <th class="text-center">Cant.</th>
                                            <th>Descripción del Producto</th>
                                            <th class="text-right">Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <% 
                                        float sumtot = 0;
                                        int c = 0;
                                        try {
                                            String sqlDetalle = "SELECT b.id_mov_vnt, a.id_movart, b.numdoc, a.total, b.fecha, " +
                                                               "a.glosa, a.cantidad, a.id_articulo, " +
                                                               "DATE_FORMAT(a.fecha,'%d/%m/%Y %H:%i') as fecha2 " +
                                                               "FROM vent_regdet a " +
                                                               "INNER JOIN vent_registro b ON a.id_mov_vnt = b.id_mov_vnt " +
                                                               "WHERE b.id_mesa = ? " +
                                                               "AND b.estado = 'V' " +
                                                               "AND a.estado = 'V' " +
                                                               "AND a.id_movart_relacion IS NULL " +
                                                               "AND a.estado_atencion IN ('0','1','2','3') " +
                                                               "AND b.tipo_doc = '11' " +
                                                               "ORDER BY a.fecha DESC";
                                            pstmt = conn.prepareStatement(sqlDetalle);
                                            pstmt.setString(1, s_idm);
                                            rset = pstmt.executeQuery();
                                            while(rset.next()) { 
                                                c++;
                                                float itemTotal = rset.getFloat("total");
                                                sumtot += itemTotal;
                                    %>
                                        <tr>
                                            <td class="text-muted small"><%=c%></td>
                                            <td class="small"><%=rset.getString("fecha2")%></td>
                                            <td class="text-center font-weight-bold"><%=rset.getString("cantidad")%></td>
                                            <td><%=rset.getString("glosa")%></td>
                                            <td class="text-right font-weight-bold">S/ <%=String.format("%.2f", itemTotal)%></td>
                                        </tr>
                                    <% 
                                            }
                                        } catch(Exception e) { e.printStackTrace(); }
                                        finally { cerrar(rset, pstmt, conn); }
                                    %>
                                    <% if(c == 0) { %>
                                        <tr>
                                            <td colspan="5" class="text-center p-4">
                                                <i class="fas fa-info-circle fa-2x text-muted mb-2"></i>
                                                <p class="text-muted">No se encontraron órdenes activas en esta mesa.</p>
                                            </td>
                                        </tr>
                                    <% } %>
                                    </tbody>
                                    <tfoot>
                                        <tr class="bg-light">
                                            <th colspan="4" class="text-right h5 py-3">Monto Total Acumulado:</th>
                                            <th class="text-right h5 py-3 text-primary font-weight-bold">S/ <%=String.format("%.2f", sumtot)%></th>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/adminlte3/js/adminlte.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>

<script>
    $(function() {
        $('#itemCount').text('<%=c%> items');

        $('#formCambioMesa').on('submit', function(e) {
            e.preventDefault();
            
            const mesaDestino = $('#f_idmc').val();
            if (!mesaDestino) {
                Swal.fire('Atención', 'Por favor seleccione una mesa de destino.', 'warning');
                return;
            }

            Swal.fire({
                title: '¿Confirmar Cambio?',
                text: "Se trasladarán todos los pedidos de la Mesa <%=s_idm%> a la Mesa " + mesaDestino,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#007bff',
                cancelButtonColor: '#6c757d',
                confirmButtonText: '<i class="fas fa-check"></i> Sí, cambiar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Procesando...',
                        didOpen: () => Swal.showLoading(),
                        allowOutsideClick: false
                    });

                    $.ajax({
                        url: 'update_nro_mesa_ajax.jsp',
                        type: 'POST',
                        data: $(this).serialize(),
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: '¡Cambio Exitoso!',
                                    text: 'La mesa ha sido trasladada correctamente.',
                                    timer: 2000,
                                    showConfirmButton: false
                                }).then(() => {
                                    window.location.href = 'index.jsp';
                                });
                            } else {
                                Swal.fire('Error', response.message, 'error');
                            }
                        },
                        error: function() {
                            Swal.fire('Error', 'Hubo un problema al conectar con el servidor.', 'error');
                        }
                    });
                }
            });
        });
    });
</script>
</body>
</html>
