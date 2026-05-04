<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_area     = request.getParameter("f_id_area");
    String s_id_personal = request.getParameter("f_id_personal");
    String s_nom_area     = "";
    String s_nom_personal = "";
    String s_login_personal = "";

    try {
        conn = getConexion();
        COMANDO = "SELECT nombre FROM acceso_main WHERE id_area = ?";
        pstmt   = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        rset    = pstmt.executeQuery();
        if (rset.next()) s_nom_area = rset.getString("nombre");
        cerrar(rset, pstmt, null);

        COMANDO = "SELECT CONCAT(apepat,' ',apemat,' ',nombre) as nombre, login FROM datos_personales WHERE id_personal = ?";
        pstmt   = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        rset    = pstmt.executeQuery();
        if (rset.next()) {
            s_nom_personal  = rset.getString("nombre");
            s_login_personal = rset.getString("login");
        }
    } catch (Exception e) {
        System.out.println(e);
    } finally {
        cerrar(rset, pstmt, conn);
    }

    // Initials for avatar
    String initials = "";
    if (s_nom_personal != null && !s_nom_personal.isEmpty()) {
        String[] parts = s_nom_personal.trim().split("\\s+");
        if (parts.length >= 2) initials = "" + parts[0].charAt(0) + parts[1].charAt(0);
        else if (parts.length == 1) initials = "" + parts[0].charAt(0);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accesos: <%=s_nom_personal%></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,300&family=Syne:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            /* AdminLTE3 / Bootstrap 4 color tokens */
            --blue-50:  #cce5ff;
            --blue-100: #b8daff;
            --blue-200: #84c2fe;
            --blue-400: #007bff;   /* Bootstrap primary */
            --blue-600: #0062cc;
            --blue-800: #1f2d3d;   /* AdminLTE dark sidebar */
            --blue-900: #343a40;   /* AdminLTE navbar-dark */
            --gray-50:  #f8f9fa;   /* Bootstrap light */
            --gray-100: #e9ecef;
            --gray-200: #dee2e6;
            --gray-400: #adb5bd;
            --gray-600: #6c757d;   /* Bootstrap secondary */
            --gray-800: #343a40;   /* Bootstrap dark */
            --gray-900: #212529;
            --green-50:  #d4edda;  /* Bootstrap success light */
            --green-100: #c3e6cb;
            --green-600: #155724;
            --accent:   #007bff;
            --text-primary:   var(--gray-900);
            --text-secondary: var(--gray-600);
            --text-muted:     var(--gray-400);
            --surface:        #FFFFFF;
            --surface-alt:    var(--gray-50);
            --border:         var(--gray-200);
            --border-light:   var(--gray-100);
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            --shadow-sm: 0 1px 3px rgba(24,28,42,.06), 0 1px 2px rgba(24,28,42,.04);
            --shadow-md: 0 4px 16px rgba(24,28,42,.08), 0 2px 6px rgba(24,28,42,.04);
            --shadow-lg: 0 12px 40px rgba(24,28,42,.10), 0 4px 12px rgba(24,28,42,.06);
        }

        body {
            font-family: 'DM Sans', system-ui, sans-serif;
            font-size: 15px;
            line-height: 1.6;
            color: var(--text-primary);
            background: var(--gray-50);
            min-height: 100vh;
        }

        /* ── PAGE LAYOUT ── */
        .page-wrapper {
            max-width: 1080px;
            margin: 0 auto;
            padding: 2rem 1.5rem 5rem;
        }

        /* ── HEADER CARD ── */
        .header-card {
            background: var(--blue-900);
            border-radius: var(--radius-xl);
            padding: 2rem 2.5rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 1.5rem;
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-lg);
        }
        .header-card::before {
            content: '';
            position: absolute;
            top: -40px; right: -40px;
            width: 220px; height: 220px;
            border-radius: 50%;
            background: rgba(55,138,221,.18);
            pointer-events: none;
        }
        .header-card::after {
            content: '';
            position: absolute;
            bottom: -60px; left: 30%;
            width: 180px; height: 180px;
            border-radius: 50%;
            background: rgba(55,138,221,.10);
            pointer-events: none;
        }

        .header-back {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px; height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,.12);
            color: #fff;
            text-decoration: none;
            font-size: 13px;
            flex-shrink: 0;
            transition: background .18s;
        }
        .header-back:hover { background: rgba(255,255,255,.22); color: #fff; }

        .avatar {
            width: 56px; height: 56px;
            border-radius: 50%;
            background: var(--blue-400);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-size: 18px; font-weight: 600;
            color: #fff;
            flex-shrink: 0;
            border: 2px solid rgba(255,255,255,.25);
            letter-spacing: .5px;
        }

        .header-info { flex: 1; min-width: 0; }
        .header-label {
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--blue-200);
            margin-bottom: .2rem;
        }
        .header-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.35rem;
            font-weight: 600;
            color: #fff;
            margin-bottom: .2rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .header-meta {
            display: flex; align-items: center; gap: .75rem;
            flex-wrap: wrap;
        }
        .header-login {
            font-size: 13px;
            color: var(--blue-100);
            font-weight: 400;
        }
        .header-badge {
            display: inline-flex; align-items: center; gap: .35rem;
            font-size: 12px;
            font-weight: 500;
            color: var(--blue-900);
            background: var(--blue-100);
            border-radius: 99px;
            padding: 2px 10px;
        }

        /* ── STATS BAR ── */
        .stats-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: .75rem;
            margin-bottom: 1.75rem;
        }
        .stat-card {
            background: var(--surface);
            border: 0.5px solid var(--border);
            border-radius: var(--radius-md);
            padding: .85rem 1.1rem;
            box-shadow: var(--shadow-sm);
        }
        .stat-label {
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: .25rem;
        }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
            line-height: 1;
        }

        /* ── PERMISSION GRID ── */
        .permissions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.1rem;
            margin-bottom: 1.75rem;
        }

        /* ── GROUP CARD ── */
        .group-card {
            background: var(--surface);
            border: 0.5px solid var(--border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            animation: fadeUp .35s ease both;
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .group-card:nth-child(1)  { animation-delay: .04s; }
        .group-card:nth-child(2)  { animation-delay: .08s; }
        .group-card:nth-child(3)  { animation-delay: .12s; }
        .group-card:nth-child(4)  { animation-delay: .16s; }
        .group-card:nth-child(5)  { animation-delay: .20s; }
        .group-card:nth-child(6)  { animation-delay: .24s; }
        .group-card:nth-child(7)  { animation-delay: .28s; }
        .group-card:nth-child(8)  { animation-delay: .32s; }

        .group-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: .85rem 1.1rem;
            background: var(--surface-alt);
            border-bottom: 0.5px solid var(--border-light);
        }
        .group-title {
            display: flex; align-items: center; gap: .5rem;
            font-family: 'Syne', sans-serif;
            font-size: .85rem;
            font-weight: 600;
            color: var(--blue-800);
            letter-spacing: .01em;
        }
        .group-title i {
            font-size: 13px;
            color: var(--blue-400);
        }

        /* Select-all toggle */
        .select-all-wrap {
            display: flex; align-items: center; gap: .45rem;
            cursor: pointer;
        }
        .select-all-wrap input { display: none; }
        .select-all-track {
            width: 32px; height: 18px;
            border-radius: 99px;
            background: var(--gray-200);
            position: relative;
            transition: background .2s;
            flex-shrink: 0;
        }
        .select-all-track::after {
            content: '';
            position: absolute;
            top: 3px; left: 3px;
            width: 12px; height: 12px;
            border-radius: 50%;
            background: #fff;
            transition: transform .2s, box-shadow .2s;
            box-shadow: 0 1px 3px rgba(0,0,0,.2);
        }
        .select-all-wrap input:checked ~ .select-all-track { background: var(--blue-400); }
        .select-all-wrap input:checked ~ .select-all-track::after { transform: translateX(14px); }
        .select-all-label {
            font-size: 11px;
            font-weight: 500;
            color: var(--text-muted);
            user-select: none;
        }

        .group-body { padding: .65rem .85rem .85rem; }

        /* ── PERMISSION ITEM ── */
        .perm-item {
            display: flex;
            align-items: flex-start;
            gap: .75rem;
            padding: .55rem .5rem;
            border-radius: var(--radius-sm);
            transition: background .15s;
            cursor: pointer;
        }
        .perm-item:hover { background: var(--gray-50); }
        .perm-item + .perm-item { border-top: 0.5px solid var(--border-light); }

        .perm-item input[type=checkbox] { display: none; }

        .toggle-track {
            width: 36px; height: 20px;
            border-radius: 99px;
            background: var(--gray-200);
            position: relative;
            flex-shrink: 0;
            margin-top: 2px;
            transition: background .2s;
        }
        .toggle-track::after {
            content: '';
            position: absolute;
            top: 3px; left: 3px;
            width: 14px; height: 14px;
            border-radius: 50%;
            background: #fff;
            transition: transform .2s, box-shadow .2s;
            box-shadow: 0 1px 4px rgba(0,0,0,.22);
        }
        .perm-item input:checked ~ .toggle-track { background: var(--blue-400); }
        .perm-item input:checked ~ .toggle-track::after { transform: translateX(16px); }

        .perm-text { flex: 1; min-width: 0; }
        .perm-name {
            font-size: 13.5px;
            font-weight: 500;
            color: var(--text-primary);
            line-height: 1.35;
        }
        .perm-url {
            font-size: 11px;
            color: var(--text-muted);
            font-family: 'DM Mono', monospace, sans-serif;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 1px;
        }

        /* ── SAVE BAR ── */
        .save-bar {
            position: fixed;
            bottom: 0; left: 0; right: 0;
            background: rgba(255,255,255,.92);
            backdrop-filter: blur(12px);
            border-top: 0.5px solid var(--border);
            padding: 1rem 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            z-index: 100;
        }

        .btn-save {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            font-weight: 500;
            color: #fff;
            background: var(--blue-800);
            border: none;
            border-radius: var(--radius-md);
            padding: .7rem 2rem;
            cursor: pointer;
            transition: background .18s, transform .12s, box-shadow .18s;
            box-shadow: 0 2px 8px rgba(12,68,124,.30);
            letter-spacing: .01em;
        }
        .btn-save:hover {
            background: var(--blue-900);
            box-shadow: 0 4px 16px rgba(12,68,124,.35);
            transform: translateY(-1px);
        }
        .btn-save:active { transform: translateY(0); }
        .btn-save:disabled { opacity: .65; cursor: default; transform: none; }

        .save-hint {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* ── EMPTY STATE ── */
        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 3rem;
            color: var(--text-muted);
        }
        .empty-state i { font-size: 2rem; margin-bottom: .75rem; color: var(--gray-200); }

        /* ── TOAST ── */
        .toast-wrap {
            position: fixed;
            top: 1.25rem; right: 1.25rem;
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: .5rem;
        }
        .toast {
            display: flex; align-items: center; gap: .65rem;
            font-size: 13.5px; font-weight: 500;
            padding: .75rem 1.1rem;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-md);
            animation: slideIn .25s ease;
            min-width: 220px;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateX(20px); }
            to   { opacity: 1; transform: translateX(0); }
        }
        .toast-success { background: var(--green-50); color: var(--green-600); border: 0.5px solid var(--green-100); }
        .toast-error   { background: #FEF2F2; color: #991B1B; border: 0.5px solid #FECACA; }
    </style>
</head>
<body>

<div class="page-wrapper">

    <!-- HEADER -->
    <div class="header-card">
        <a href="usuarios.jsp?f_id_area=<%=s_id_area%>" class="header-back">
            <i class="fas fa-chevron-left"></i>
        </a>
        <div class="avatar"><%=initials.toUpperCase()%></div>
        <div class="header-info">
            <div class="header-label">Gestión de accesos</div>
            <div class="header-name"><%=s_nom_personal%></div>
            <div class="header-meta">
                <span class="header-login"><i class="fas fa-at" style="font-size:11px; margin-right:3px;"></i><%=s_login_personal%></span>
                <span class="header-badge"><i class="fas fa-cubes" style="font-size:10px;"></i><%=s_nom_area%></span>
            </div>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-bar">
        <div class="stat-card">
            <div class="stat-label">Total permisos</div>
            <div class="stat-value" id="statTotal">—</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Activos</div>
            <div class="stat-value" id="statActive" style="color:var(--blue-600);">—</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Inactivos</div>
            <div class="stat-value" id="statInactive" style="color:var(--gray-400);">—</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Grupos</div>
            <div class="stat-value" id="statGroups">—</div>
        </div>
    </div>

    <!-- FORM -->
    <form id="accessForm">
        <input type="hidden" name="f_id_area"    value="<%=s_id_area%>">
        <input type="hidden" name="f_id_personal" value="<%=s_id_personal%>">

        <div class="permissions-grid" id="permGrid">
        <%
            int contador = 0;
            int grupos   = 0;
            String currentGroup = "";
            try {
                conn = getConexion();
                COMANDO = "SELECT c.nombre as grupo, c.id_grupo, a.nombre, a.id_acceso, a.url, 'S' as estado " +
                          "FROM accesos_botones a, accesos_usuarios b, accesos_grupo c " +
                          "WHERE a.id_acceso = b.id_acceso AND a.id_grupo = c.id_grupo " +
                          "AND b.id_personal = ? AND a.id_area = ? " +
                          "UNION " +
                          "SELECT b.nombre as grupo, b.id_grupo, a.nombre, a.id_acceso, a.url, 'N' as estado " +
                          "FROM accesos_botones a, accesos_grupo b " +
                          "WHERE a.id_grupo = b.id_grupo AND a.id_area = ? " +
                          "AND NOT id_acceso IN (SELECT id_acceso FROM accesos_usuarios WHERE id_personal = ?) " +
                          "ORDER BY id_grupo, id_acceso";

                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_id_personal);
                pstmt.setString(2, s_id_area);
                pstmt.setString(3, s_id_area);
                pstmt.setString(4, s_id_personal);
                rset  = pstmt.executeQuery();

                while (rset.next()) {
                    String grupo    = rset.getString("grupo");
                    String idGrupo  = rset.getString("id_grupo");
                    String nombre   = rset.getString("nombre");
                    String idAcceso = rset.getString("id_acceso");
                    String url      = rset.getString("url");
                    String estado   = rset.getString("estado");

                    if (!grupo.equals(currentGroup)) {
                        if (!currentGroup.equals("")) {
                            out.println("</div></div>"); // close group-body + group-card
                        }
                        currentGroup = grupo;
                        grupos++;
        %>
            <div class="group-card">
                <div class="group-header">
                    <div class="group-title">
                        <i class="fas fa-layer-group"></i>
                        <%=grupo%>
                    </div>
                    <label class="select-all-wrap" title="Seleccionar todo el grupo">
                        <input type="checkbox" class="select-all-group" id="all_<%=idGrupo%>" data-group="<%=idGrupo%>">
                        <span class="select-all-track"></span>
                        <span class="select-all-label">Todo</span>
                    </label>
                </div>
                <div class="group-body">
        <%
                    } // end new group
                    contador++;
        %>
                    <label class="perm-item" for="acc_<%=idAcceso%>">
                        <input type="checkbox"
                               name="f_det_act<%=contador%>"
                               value="S"
                               class="group-item"
                               data-group="<%=idGrupo%>"
                               id="acc_<%=idAcceso%>"
                               <%=estado.equals("S") ? "checked" : ""%>>
                        <span class="toggle-track"></span>
                        <input type="hidden" name="f_id_acceso<%=contador%>" value="<%=idAcceso%>">
                        <span class="perm-text">
                            <span class="perm-name"><%=nombre%></span>
                            <span class="perm-url"><%=url%></span>
                        </span>
                    </label>
        <%
                } // end while
                if (!currentGroup.equals("")) {
                    out.println("</div></div>"); // final close
                }
                if (contador == 0) {
                    out.println("<div class='empty-state'><div><i class='fas fa-inbox'></i></div><p>No hay permisos disponibles para este módulo.</p></div>");
                }
            } catch (Exception e) {
                out.println("<div class='empty-state'><i class='fas fa-exclamation-triangle'></i><p>Error al cargar permisos: " + e.getMessage() + "</p></div>");
            } finally {
                cerrar(rset, pstmt, conn);
            }
        %>
        </div>

        <input type="hidden" name="f_total_det" id="f_total_det" value="<%=contador%>">

        <!-- SAVE BAR -->
        <div class="save-bar">
            <span class="save-hint" id="saveHint"><%=contador%> permiso(s) cargados</span>
            <button type="submit" class="btn-save" id="saveBtn">
                <i class="fas fa-save"></i> Guardar cambios
            </button>
        </div>
    </form>
</div>

<!-- TOAST CONTAINER -->
<div class="toast-wrap" id="toastWrap"></div>

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
$(function () {

    /* ── Stats counter ── */
    function updateStats() {
        var all    = $('.group-item');
        var active = $('.group-item:checked');
        $('#statTotal').text(all.length);
        $('#statActive').text(active.length);
        $('#statInactive').text(all.length - active.length);
        $('#statGroups').text($('.group-card').length);
        $('#saveHint').text(active.length + ' de ' + all.length + ' permisos activos');
    }
    updateStats();

    /* ── Toggle individual ── */
    $(document).on('change', '.group-item', function () {
        var group   = $(this).data('group');
        var items   = $('.group-item[data-group="' + group + '"]');
        var allChk  = items.filter(':checked').length === items.length;
        $('#all_' + group).prop('checked', allChk);
        updateStats();
    });

    /* ── Select-all per group ── */
    $(document).on('change', '.select-all-group', function () {
        var group = $(this).data('group');
        var chk   = $(this).is(':checked');
        $('.group-item[data-group="' + group + '"]').prop('checked', chk);
        updateStats();
    });

    /* ── Toast helper ── */
    function showToast(msg, type) {
        var icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-xmark';
        var el   = $('<div class="toast toast-' + type + '"><i class="fas ' + icon + '"></i>' + msg + '</div>');
        $('#toastWrap').append(el);
        setTimeout(function () { el.fadeOut(300, function() { el.remove(); }); }, 3200);
    }

    /* ── Form submit ── */
    $('#accessForm').on('submit', function (e) {
        e.preventDefault();

        var $btn = $('#saveBtn');
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Guardando...');

        $.ajax({
            url:      'accesos_add.jsp',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (r) {
                if (r.status === 'success') {
                    showToast(r.message || '\u00a1Cambios guardados correctamente!', 'success');
                } else {
                    showToast(r.message || 'Error al guardar.', 'error');
                }
            },
            error: function () {
                showToast('No se pudo conectar con el servidor.', 'error');
            },
            complete: function () {
                $btn.prop('disabled', false).html('<i class="fas fa-save"></i> Guardar cambios');
            }
        });
    });
});
</script>
</body>
</html>
