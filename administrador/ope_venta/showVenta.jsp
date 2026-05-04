<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import=" java.*, java.util.*, java.text.*, java.sql.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_mov_vnt = request.getParameter("f_id_mov_vnt");
    String s_idm = request.getParameter("f_idm");
    String s_id_ctacte = request.getParameter("f_id_ctacte"); if (s_id_ctacte == null) s_id_ctacte = "";
    
    String s_nom_pac = "";
    String url_del = "padre_eliminar.jsp";
    String s_tc = "3.75";

    String s_id_ultimo_ruc = "";
    String s_nom_ultimo_ruc = "";
    String s_ultimo_ruc = "";
    
    try {
        conn = getConexion();
        COMANDO = "SELECT nombre(?) as nom_pac FROM DUAL";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_pac = rset.getString("nom_pac");
        cerrar(rset, pstmt, null);

        COMANDO = "SELECT id_ultimo_ruc FROM datos_personales WHERE id_personal = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_id_ultimo_ruc = rset.getString("id_ultimo_ruc");
            if (s_id_ultimo_ruc == null) s_id_ultimo_ruc = "";
            if (!s_id_ultimo_ruc.isEmpty()) {
                COMANDO = "SELECT ruc, CONCAT(apepat,' ',apemat,' ',nombre) as nom FROM datos_personales WHERE id_personal = ?";
                PreparedStatement pstmt2 = conn.prepareStatement(COMANDO);
                pstmt2.setString(1, s_id_ultimo_ruc);
                ResultSet rset2 = pstmt2.executeQuery();
                if (rset2.next()) {
                    s_nom_ultimo_ruc = rset2.getString("nom");
                    s_ultimo_ruc = rset2.getString("ruc");
                }
                cerrar(rset2, pstmt2, null);
            }
        }
    } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Caja · Mesa <%=s_idm%></title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <style>
        :root {
            --corp-primary:   #1a56a0;
            --corp-secondary: #0d3d73;
            --corp-accent:    #e8f0fb;
            --corp-success:   #1a7a4a;
            --corp-success-bg:#e6f4ee;
            --corp-danger:    #c0392b;
            --corp-border:    #dde3ec;
            --corp-text:      #1c2b45;
            --corp-muted:     #6b7a90;
            --corp-bg:        #f0f4f9;
            --corp-white:     #ffffff;
            --corp-radius:    8px;
            --corp-shadow:    0 2px 12px rgba(26,86,160,.10);
        }

        * { box-sizing: border-box; }

        body { background: var(--corp-bg) !important; font-family: 'Segoe UI', system-ui, sans-serif; color: var(--corp-text); }

        /* ─── CARD ─────────────────────────────────── */
        .caja-card {
            border-radius: var(--corp-radius);
            border: 1px solid var(--corp-border);
            box-shadow: var(--corp-shadow);
            overflow: hidden;
            background: var(--corp-white);
        }
        .caja-header {
            background: var(--corp-white);
            border-bottom: 1px solid var(--corp-border);
            padding: 10px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .caja-header-title {
            font-size: .85rem;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: var(--corp-primary);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .mesa-badge {
            background: var(--corp-primary);
            color: #fff;
            font-size: .7rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
            letter-spacing: .05em;
        }

        /* ─── CLIENT STRIP ──────────────────────────── */
        .client-strip {
            background: var(--corp-accent);
            border-bottom: 1px solid var(--corp-border);
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .client-avatar {
            width: 30px; height: 30px;
            background: var(--corp-primary);
            border-radius: 50%;
            display: grid; place-items: center;
            color: #fff; font-size: .7rem; flex-shrink: 0;
        }
        .client-name { font-size: .82rem; font-weight: 700; color: var(--corp-text); }
        .client-label { font-size: .65rem; color: var(--corp-muted); text-transform: uppercase; letter-spacing: .05em; }

        /* ─── LAYOUT GRID ───────────────────────────── */
        .caja-body { display: grid; grid-template-columns: 1fr 340px; }
        @media (max-width:900px) { .caja-body { grid-template-columns: 1fr; } }

        /* ─── TABLE ─────────────────────────────────── */
        .items-pane { padding: 14px 16px; border-right: 1px solid var(--corp-border); }
        .tbl-items { width: 100%; font-size: .78rem; border-collapse: collapse; }
        .tbl-items thead th {
            background: var(--corp-bg);
            color: var(--corp-muted);
            font-size: .65rem;
            font-weight: 700;
            letter-spacing: .07em;
            text-transform: uppercase;
            padding: 6px 8px;
            border-bottom: 2px solid var(--corp-border);
            white-space: nowrap;
        }
        .tbl-items tbody tr { border-bottom: 1px solid #f0f2f5; transition: background .12s; }
        .tbl-items tbody tr:hover { background: var(--corp-accent); }
        .tbl-items td { padding: 6px 8px; vertical-align: middle; }
        .tbl-items .td-qty { text-align: center; font-weight: 700; width: 42px; }
        .tbl-items .td-sub { text-align: right; font-weight: 700; white-space: nowrap; color: var(--corp-text); width: 90px; }
        .tbl-items .td-act { text-align: center; width: 30px; }
        .btn-del {
            background: none; border: none; cursor: pointer;
            color: #c9ced7; padding: 2px 5px; border-radius: 4px; transition: color .15s, background .15s;
        }
        .btn-del:hover { color: var(--corp-danger); background: #fdecea; }

        .items-scroll { max-height: 340px; overflow-y: auto; }
        .items-scroll::-webkit-scrollbar { width: 4px; }
        .items-scroll::-webkit-scrollbar-thumb { background: var(--corp-border); border-radius: 4px; }

        /* ─── TOTAL ROW ─────────────────────────────── */
        .total-row {
            display: flex; align-items: center; justify-content: space-between;
            padding: 10px 8px 0;
            border-top: 2px solid var(--corp-border);
            margin-top: 6px;
        }
        .total-label { font-size: .7rem; font-weight: 700; color: var(--corp-muted); text-transform: uppercase; letter-spacing: .06em; }
        .total-amount { font-size: 1.6rem; font-weight: 900; color: var(--corp-success); letter-spacing: -.01em; }

        /* ─── PAYMENT PANE ──────────────────────────── */
        .pay-pane {
            padding: 14px 16px;
            background: #fafbfd;
            display: flex; flex-direction: column; gap: 10px;
        }
        .pay-section-title {
            font-size: .68rem; font-weight: 700; letter-spacing: .07em;
            text-transform: uppercase; color: var(--corp-primary);
            border-bottom: 1px solid var(--corp-border); padding-bottom: 6px; margin-bottom: 2px;
        }

        /* compact inputs */
        .pay-field label {
            font-size: .65rem; font-weight: 700; color: var(--corp-muted);
            text-transform: uppercase; letter-spacing: .05em; display: block; margin-bottom: 3px;
        }
        .pay-input {
            width: 100%; padding: 7px 10px;
            font-size: 1.05rem; font-weight: 700; text-align: right;
            border: 1.5px solid var(--corp-border); border-radius: var(--corp-radius);
            background: var(--corp-white); color: var(--corp-text);
            transition: border-color .15s, box-shadow .15s; outline: none;
        }
        .pay-input:focus { border-color: var(--corp-primary); box-shadow: 0 0 0 3px rgba(26,86,160,.12); }
        .tc-note { font-size: .65rem; color: var(--corp-muted); text-align: right; margin-top: 2px; }

        /* vuelto box */
        .vuelto-box {
            background: var(--corp-white);
            border: 1.5px solid var(--corp-border);
            border-radius: var(--corp-radius);
            padding: 8px 12px;
        }
        .vuelto-row { display: flex; justify-content: space-between; align-items: center; }
        .vuelto-label { font-size: .65rem; font-weight: 700; color: var(--corp-muted); text-transform: uppercase; letter-spacing: .05em; }
        .vuelto-amount { font-size: 1.15rem; font-weight: 900; color: var(--corp-success); }
        .vuelto-amount.faltante { color: var(--corp-danger) !important; }
        .recibido-row { display: flex; justify-content: space-between; font-size: .7rem; margin-top: 5px; padding-top: 5px; border-top: 1px dashed var(--corp-border); }
        .recibido-val { font-weight: 700; color: var(--corp-primary); }

        /* action buttons */
        .btn-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
        .btn-grid-full { grid-column: 1 / -1; }
        .btn-caja {
            padding: 9px 6px; border: none; border-radius: var(--corp-radius);
            font-size: .72rem; font-weight: 700; letter-spacing: .04em; text-transform: uppercase;
            cursor: pointer; transition: filter .15s, transform .1s, box-shadow .15s;
            display: flex; align-items: center; justify-content: center; gap: 5px;
        }
        .btn-caja:hover { filter: brightness(1.08); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.12); }
        .btn-caja:active { transform: translateY(0); filter: brightness(.97); }
        .btn-boleta   { background: #1a7a4a; color: #fff; }
        .btn-factura  { background: var(--corp-primary); color: #fff; }
        .btn-ticket   { background: #0e6e8c; color: #fff; }

        /* ─── MODAL OVERRIDES ───────────────────────── */
        .modal-content { border-radius: var(--corp-radius); border: 1px solid var(--corp-border); overflow: hidden; box-shadow: 0 8px 32px rgba(26,86,160,.18); }
        .modal-header { background: var(--corp-secondary); padding: 10px 16px; border: none; }
        .modal-title  { font-size: .82rem; font-weight: 700; letter-spacing: .05em; text-transform: uppercase; color: #fff; }
        .modal-header .close { color: rgba(255,255,255,.7); text-shadow: none; font-size: 1.1rem; padding: 8px 12px; }
        .modal-header .close:hover { color: #fff; }
        .modal-body   { padding: 16px; }
        .modal-footer { background: var(--corp-bg); border-top: 1px solid var(--corp-border); padding: 8px 16px; }

        .ruc-section-label {
            font-size: .63rem; font-weight: 700; letter-spacing: .07em;
            text-transform: uppercase; color: var(--corp-muted); margin-bottom: 6px; display: block;
        }
        .btn-quick-ruc {
            border: 1.5px solid var(--corp-border); background: var(--corp-white);
            border-radius: 20px; padding: 4px 12px; font-size: .72rem; font-weight: 600;
            color: var(--corp-text); cursor: pointer; transition: all .15s; white-space: nowrap;
        }
        .btn-quick-ruc:hover { border-color: var(--corp-primary); color: var(--corp-primary); background: var(--corp-accent); }

        .ruc-search-group { display: flex; gap: 6px; }
        .ruc-search-input {
            flex: 1; padding: 7px 10px; border: 1.5px solid var(--corp-border); border-radius: var(--corp-radius);
            font-size: .8rem; outline: none; transition: border-color .15s;
        }
        .ruc-search-input:focus { border-color: var(--corp-primary); box-shadow: 0 0 0 3px rgba(26,86,160,.10); }
        .btn-search-ruc {
            background: var(--corp-primary); color: #fff; border: none;
            border-radius: var(--corp-radius); padding: 0 14px; font-size: .8rem; cursor: pointer; transition: filter .15s;
        }
        .btn-search-ruc:hover { filter: brightness(1.1); }

        .ruc-results { margin-top: 8px; max-height: 240px; overflow-y: auto; }
        .ruc-results::-webkit-scrollbar { width: 4px; }
        .ruc-results::-webkit-scrollbar-thumb { background: var(--corp-border); }
        .ruc-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 8px 12px; border: 1px solid var(--corp-border); border-radius: var(--corp-radius);
            background: var(--corp-white); cursor: pointer; transition: all .12s; margin-bottom: 4px;
        }
        .ruc-item:hover { border-color: var(--corp-primary); background: var(--corp-accent); }
        .ruc-item-name { font-size: .78rem; font-weight: 600; color: var(--corp-text); }
        .ruc-item-num  { font-size: .72rem; font-weight: 700; color: var(--corp-primary); }

        .no-results { text-align: center; padding: 20px 0; color: var(--corp-muted); font-size: .78rem; }
        .no-results i { font-size: 1.4rem; display: block; margin-bottom: 6px; opacity: .4; }
        .link-crear { color: var(--corp-primary); font-weight: 600; font-size: .75rem; }

        /* back btn */
        .btn-back {
            background: none; border: 1.5px solid var(--corp-border); color: var(--corp-muted);
            border-radius: 50%; width: 28px; height: 28px; display: inline-flex;
            align-items: center; justify-content: center; font-size: .72rem; transition: all .15s;
        }
        .btn-back:hover { border-color: var(--corp-primary); color: var(--corp-primary); background: var(--corp-accent); text-decoration: none; }

        /* ─── SWAl overrides ────────────────────────── */
        .swal2-popup { font-family: 'Segoe UI', system-ui, sans-serif !important; border-radius: var(--corp-radius) !important; padding: 20px !important; }
        .swal2-title { font-size: 1rem !important; font-weight: 700 !important; color: var(--corp-text) !important; }
        .swal2-html-container { font-size: .82rem !important; color: var(--corp-muted) !important; }
        .swal2-confirm, .swal2-cancel { font-size: .78rem !important; font-weight: 700 !important; padding: 7px 18px !important; border-radius: 6px !important; }
        .swal2-icon { width: 48px !important; height: 48px !important; margin: 0 auto 10px !important; }
        .swal2-icon .swal2-icon-content { font-size: 1.4rem !important; }
    </style>
</head>
<body class="hold-transition">

<div class="container-fluid py-3">
<div class="row justify-content-center">
<div class="col-xl-10 col-lg-12">

    <div class="caja-card">

        <!-- HEADER -->
        <div class="caja-header">
            <h6 class="caja-header-title">
                <a href="index2.jsp?idm=<%=s_idm%>" class="btn-back"><i class="fas fa-arrow-left"></i></a>
                <i class="fas fa-cash-register" style="color:var(--corp-primary);font-size:.9rem;"></i>
                Detalle de Venta
            </h6>
            <span class="mesa-badge"><i class="fas fa-utensils mr-1"></i> MESA <%=s_idm%></span>
        </div>

        <!-- CLIENT STRIP -->
        <div class="client-strip">
            <div class="client-avatar"><i class="fas fa-user"></i></div>
            <div>
                <div class="client-label">Cliente</div>
                <div class="client-name"><%=s_nom_pac%></div>
            </div>
        </div>

        <!-- BODY -->
        <div class="caja-body">

            <!-- LEFT: ITEMS -->
            <div class="items-pane">
                <div class="items-scroll">
                    <table class="tbl-items">
                        <thead>
                            <tr>
                                <th class="td-qty">Cant.</th>
                                <th>Descripción</th>
                                <th class="td-sub">Subtotal</th>
                                <th class="td-act"></th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            double totalGeneral = 0;
                            int hono = 0;
                            try {
                                conn = getConexion();
                                COMANDO = "SELECT id_movart, glosa, cantidad, total, cast(pago_hono as unsigned) as hono_val FROM vent_regdet WHERE id_mov_vnt = ? AND estado <> 'X' ORDER BY id_movart";
                                pstmt = conn.prepareStatement(COMANDO);
                                pstmt.setString(1, s_id_mov_vnt);
                                rset = pstmt.executeQuery();
                                while(rset.next()) {
                                    String id_movart = rset.getString("id_movart");
                                    String glosa = rset.getString("glosa");
                                    double cant = rset.getDouble("cantidad");
                                    double sub = rset.getDouble("total");
                                    if (rset.getInt("hono_val") > 0) hono = 1;
                                    totalGeneral += sub;
                        %>
                            <tr>
                                <td class="td-qty"><%=(int)cant%></td>
                                <td style="font-size:.79rem;"><%=glosa%></td>
                                <td class="td-sub">S/ <%=String.format("%.2f", sub)%></td>
                                <td class="td-act">
                                    <button class="btn-del" onclick="eliminarItem('<%=id_movart%>', '<%=glosa%>')"><i class="fas fa-times"></i></button>
                                </td>
                            </tr>
                        <%
                                }
                            } catch(Exception e) { } finally { cerrar(rset, pstmt, conn); }
                        %>
                        </tbody>
                    </table>
                </div>

                <div class="total-row">
                    <span class="total-label">Total General</span>
                    <span class="total-amount">S/ <%=String.format("%.2f", totalGeneral)%></span>
                </div>
            </div>

            <!-- RIGHT: PAYMENT -->
            <div class="pay-pane">
                <form action="terminar_contado.jsp" method="post" id="formFinalVenta">
                    <input type="hidden" name="f_id_mov_vnt"  value="<%=s_id_mov_vnt%>">
                    <input type="hidden" name="f_id_personal" value="<%=s_id_personal%>">
                    <input type="hidden" name="f_idm"         value="<%=s_idm%>">
                    <input type="hidden" name="f_monto"       id="f_monto" value="<%=totalGeneral%>">
                    <input type="hidden" name="f_tipo_doc"    id="f_tipo_doc" value="41">
                    <input type="hidden" name="resto"         value="<%=hono > 0 ? "1" : "0"%>">
                    <input type="hidden" name="f_tipo_ing"    value="1">
                    <input type="hidden" id="tipo_cambio"     value="<%=s_tc%>">

                    <div class="pay-section-title"><i class="fas fa-coins mr-1"></i> Procesar Pago</div>

                    <div class="pay-field">
                        <label>Soles (S/)</label>
                        <input type="number" step="0.01" id="pago_soles" name="soles" class="pay-input" placeholder="0.00" autofocus>
                    </div>

                    <div class="pay-field">
                        <label>Dólares ($)</label>
                        <input type="number" step="0.01" id="pago_dolares" name="dolares" class="pay-input" placeholder="0.00">
                        <div class="tc-note">T.C. S/ <%=s_tc%></div>
                    </div>

                    <div class="vuelto-box">
                        <div class="vuelto-row">
                            <span class="vuelto-label" id="vuelto_label">Vuelto</span>
                            <span class="vuelto-amount" id="vuelto_text">S/ 0.00</span>
                        </div>
                        <div class="recibido-row">
                            <span class="vuelto-label">Recibido</span>
                            <span class="recibido-val" id="total_recibido_text">S/ 0.00</span>
                        </div>
                    </div>

                    <div class="btn-grid">
                        <button type="button" class="btn-caja btn-boleta" onclick="finalizar('41','BOLETA')">
                            <i class="fas fa-receipt"></i> Boleta
                        </button>
                        <button type="button" class="btn-caja btn-factura" onclick="finalizar('39','FACTURA')">
                            <i class="fas fa-file-invoice-dollar"></i> Factura
                        </button>
                        <button type="button" class="btn-caja btn-ticket btn-grid-full" onclick="finalizar('34','NOTA DE VENTA')">
                            <i class="fas fa-ticket-alt"></i> Nota de Venta
                        </button>
                    </div>

                </form>
            </div>
        </div><!-- /caja-body -->
    </div><!-- /caja-card -->

</div></div></div>

<!-- ═══════════════ MODAL RUC ═══════════════ -->
<div class="modal fade" id="modalRuc" tabindex="-1" role="dialog" aria-labelledby="modalRucLabel" aria-hidden="true">
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="modal-title" id="modalRucLabel"><i class="fas fa-file-invoice-dollar mr-2"></i> Datos de Facturación</h6>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">

                <!-- Quick picks -->
                <span class="ruc-section-label">Accesos rápidos</span>
                <div class="d-flex flex-wrap gap-1 mb-3" style="gap:6px;">
                    <button class="btn-quick-ruc" onclick="seleccionarRuc('<%=s_id_personal%>', '<%=s_nom_pac%>', '')">
                        <i class="fas fa-user-check mr-1" style="color:var(--corp-primary);"></i> Mismo cliente
                    </button>
                    <% if (!s_id_ultimo_ruc.isEmpty() && !s_id_ultimo_ruc.equals(s_id_personal)) { %>
                    <button class="btn-quick-ruc" onclick="seleccionarRuc('<%=s_id_ultimo_ruc%>', '<%=s_nom_ultimo_ruc%>', '<%=s_ultimo_ruc%>')">
                        <i class="fas fa-history mr-1" style="color:var(--corp-muted);"></i> Último RUC: <strong><%=s_ultimo_ruc%></strong>
                    </button>
                    <% } %>
                </div>

                <!-- Search -->
                <span class="ruc-section-label">Buscar empresa o RUC</span>
                <div class="ruc-search-group">
                    <input type="text" id="inputSearchRuc" class="ruc-search-input" placeholder="Ingrese RUC o nombre...">
                    <button class="btn-search-ruc" onclick="buscarRuc()"><i class="fas fa-search"></i></button>
                </div>

                <div id="resultsRuc" class="ruc-results"></div>
                <div id="noResultsRuc" class="no-results" style="display:none;">
                    <i class="fas fa-search-minus"></i>
                    Sin resultados.
                    <br><a href="crear_emp.jsp?f_id_paciente_ruc=<%=s_id_personal%>" class="link-crear">+ Crear nueva empresa</a>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary px-3 font-weight-bold" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
// ── VUELTO CALC ─────────────────────────────────────────────────────────────
$(function(){
    function calcVuelto(){
        var total     = parseFloat($('#f_monto').val())      || 0;
        var soles     = parseFloat($('#pago_soles').val())   || 0;
        var dolares   = parseFloat($('#pago_dolares').val()) || 0;
        var tc        = parseFloat($('#tipo_cambio').val())  || 0;
        var recibido  = soles + (dolares * tc);
        var vuelto    = recibido - total;
        $('#total_recibido_text').text('S/ ' + recibido.toFixed(2));
        var $v = $('#vuelto_text'), $l = $('#vuelto_label');
        if (vuelto < 0) {
            $v.text('S/ ' + Math.abs(vuelto).toFixed(2)).addClass('faltante');
            $l.text('Faltante');
        } else {
            $v.text('S/ ' + vuelto.toFixed(2)).removeClass('faltante');
            $l.text('Vuelto');
        }
    }
    $('#pago_soles, #pago_dolares').on('input', calcVuelto);
    $('#inputSearchRuc').on('keypress', function(e){ if(e.which===13){ buscarRuc(); e.preventDefault(); } });
});

// ── SWEET ALERT CONFIG ───────────────────────────────────────────────────────
const SwalCompact = Swal.mixin({
    customClass:{ popup:'swal2-popup', confirmButton:'swal2-confirm', cancelButton:'swal2-cancel' },
    buttonsStyling: true
});

// ── RUC SEARCH ───────────────────────────────────────────────────────────────
function buscarRuc(){
    var term = $('#inputSearchRuc').val().trim();
    if(term.length < 3){
        SwalCompact.fire({ icon:'info', title:'Búsqueda corta', text:'Ingrese al menos 3 caracteres.', timer:2000, showConfirmButton:false });
        return;
    }
    var isRuc = /^\d+$/.test(term);
    $('#resultsRuc').empty();
    $('#noResultsRuc').hide();

    $.ajax({
        url: 'search_ruc_ajax.jsp',
        data: { term: term, type: isRuc ? 'R' : 'E' },
        dataType: 'json',
        success: function(data){
            if(data.success && data.results.length > 0){
                data.results.forEach(function(item){
                    var el = $('<div class="ruc-item"></div>').on('click', function(){
                        seleccionarRuc(item.id, item.nombre, item.ruc);
                    });
                    el.append('<span class="ruc-item-name">'+ item.nombre +'</span>');
                    el.append('<span class="ruc-item-num">'+ item.ruc +'</span>');
                    $('#resultsRuc').append(el);
                });
            } else {
                $('#noResultsRuc').fadeIn(150);
            }
        },
        error: function(){
            SwalCompact.fire({ icon:'error', title:'Error de red', text:'No se pudo realizar la búsqueda.' });
        }
    });
}

function seleccionarRuc(id, nombre, ruc){
    if(!$('#f_id_empresa').length){
        $('#formFinalVenta').append('<input type="hidden" name="f_id_empresa" id="f_id_empresa">');
        $('#formFinalVenta').append('<input type="hidden" name="f_tipo_ruc" id="f_tipo_ruc" value="E">');
    }
    $('#f_id_empresa').val(id);
    $('#modalRuc').modal('hide');

    SwalCompact.fire({
        title: 'Factura',
        html: '<span style="font-size:.82rem;">Se emitirá a nombre de:<br><strong>'+ nombre +'</strong></span>',
        icon: 'success',
        showCancelButton: true,
        confirmButtonColor: '#1a7a4a',
        cancelButtonColor:  '#6b7a90',
        confirmButtonText: '<i class="fas fa-check mr-1"></i> Finalizar',
        cancelButtonText: 'Cambiar RUC'
    }).then(function(r){
        if(r.isConfirmed) enviarFormFinal('39','FACTURA');
        else $('#modalRuc').modal('show');
    });
}

// ── ELIMINAR ITEM ────────────────────────────────────────────────────────────
function eliminarItem(id_movart, glosa){
    SwalCompact.fire({
        title: '¿Anular ítem?',
        html: '<span style="font-size:.82rem;">¿Quitar <strong>'+ glosa +'</strong>?</span>',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#c0392b',
        cancelButtonColor:  '#6b7a90',
        confirmButtonText: 'Eliminar',
        cancelButtonText: 'No'
    }).then(function(r){
        if(r.isConfirmed)
            window.location.href = '<%=url_del%>?f_id_mov_vnt=<%=s_id_mov_vnt%>&f_id_movart='+ id_movart +'&f_id_personal=<%=s_id_personal%>&f_idm=<%=s_idm%>&f_estado_det=B';
    });
}

// ── FINALIZAR ────────────────────────────────────────────────────────────────
function finalizar(tipoDoc, nombreDoc){
    var total    = parseFloat($('#f_monto').val())      || 0;
    var soles    = parseFloat($('#pago_soles').val())   || 0;
    var dolares  = parseFloat($('#pago_dolares').val()) || 0;
    var tc       = parseFloat($('#tipo_cambio').val())  || 0;
    var recibido = soles + (dolares * tc);

    if(recibido < total - 0.01){
        SwalCompact.fire({ icon:'error', title:'Monto insuficiente', text:'El pago recibido es menor al total a cobrar.' });
        return;
    }
    if(tipoDoc === '39'){
        $('#modalRuc').modal('show');
        return;
    }
    enviarFormFinal(tipoDoc, nombreDoc);
}

function enviarFormFinal(tipoDoc, nombreDoc){
    var monto = (parseFloat($('#f_monto').val()) || 0).toFixed(2);
    SwalCompact.fire({
        title: '¿Confirmar pago?',
        html: '<span style="font-size:.82rem;"><strong>'+ nombreDoc +'</strong> · S/ '+ monto +'</span>',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#1a56a0',
        cancelButtonColor:  '#6b7a90',
        confirmButtonText: '<i class="fas fa-check mr-1"></i> Pagar',
        cancelButtonText: 'Cancelar'
    }).then(function(r){
        if(r.isConfirmed){
            $('#f_tipo_doc').val(tipoDoc);
            SwalCompact.fire({ title:'Procesando...', allowOutsideClick:false, didOpen: function(){ Swal.showLoading(); } });
            $('#formFinalVenta').submit();
        }
    });
}
</script>
</body>
</html>