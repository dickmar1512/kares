<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_alert = request.getParameter("alert"); 
    if(s_alert==null) s_alert="X";
    
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    java.util.Date fechaActual = new java.util.Date();
    String fechaHoy = sdf.format(fechaActual);
    
    String fechaInicio = request.getParameter("fecha_inicio");
    String fechaFin    = request.getParameter("fecha_fin");
    
    if(fechaInicio == null || fechaInicio.equals("")) fechaInicio = fechaHoy;
    if(fechaFin    == null || fechaFin.equals(""))    fechaFin    = fechaHoy;

    /* ── Resumen general ─────────────────────────────────────────── */
    int totalPedidos   = 0;
    int pedidosActivos = 0;
    int pedidosAnulados = 0;
    
    try {
        String sqlResumen =
            "SELECT COUNT(*) as total, " +
            "SUM(CASE WHEN estado='V' THEN 1 ELSE 0 END) as activos, " +
            "SUM(CASE WHEN estado='A' THEN 1 ELSE 0 END) as anulados " +
            "FROM vent_registro " +
            "WHERE estado IN ('A','V') AND modo='2' AND TIPO_DOC='11' " +
            "AND fecha >= ? AND fecha < DATE_ADD(?, INTERVAL 1 DAY)";
        conn = getConexion();
        pstmt = conn.prepareStatement(sqlResumen);
        pstmt.setString(1, fechaInicio);
        pstmt.setString(2, fechaFin);
        rset = pstmt.executeQuery();
        if(rset.next()){
            totalPedidos    = rset.getInt("total");
            pedidosActivos  = rset.getInt("activos");
            pedidosAnulados = rset.getInt("anulados");
        }
    } catch(Exception e){ e.printStackTrace(); }
    finally { cerrar(rset, pstmt, conn); }

    /* ── Ítems por estado_atencion (solo pedidos activos V) ──────── */
    int est0=0, est1=0, est2=0, est3=0, est4=0;
    try {
        String sqlEstados =
            "SELECT " +
            "SUM(CASE WHEN d.estado_atencion=0 THEN 1 ELSE 0 END) AS c0, " +
            "SUM(CASE WHEN d.estado_atencion=1 THEN 1 ELSE 0 END) AS c1, " +
            "SUM(CASE WHEN d.estado_atencion=2 THEN 1 ELSE 0 END) AS c2, " +
            "SUM(CASE WHEN d.estado_atencion=3 THEN 1 ELSE 0 END) AS c3, " +
            "SUM(CASE WHEN d.estado_atencion=4 THEN 1 ELSE 0 END) AS c4 " +
            "FROM vent_regdet d " +
            "INNER JOIN vent_registro b ON b.id_mov_vnt = d.id_mov_vnt " +
            "WHERE b.estado='V' AND b.modo='2' AND b.TIPO_DOC='11' " +
            "AND b.fecha >= ? AND b.fecha < DATE_ADD(?, INTERVAL 1 DAY)";
        conn = getConexion();
        pstmt = conn.prepareStatement(sqlEstados);
        pstmt.setString(1, fechaInicio);
        pstmt.setString(2, fechaFin);
        rset = pstmt.executeQuery();
        if(rset.next()){
            est0 = rset.getInt("c0");
            est1 = rset.getInt("c1");
            est2 = rset.getInt("c2");
            est3 = rset.getInt("c3");
            est4 = rset.getInt("c4");
        }
    } catch(Exception e){ e.printStackTrace(); }
    finally { cerrar(rset, pstmt, conn); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Panel de Cocina · Kares</title>
    <link rel="shortcut icon" href="../../assets/images/favicon.ico">
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <!-- AdminLTE y Bootstrap requeridos por el DataTables / Modals subyacentes -->
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/mesa/ope_cocina/index.css?v=<%=System.currentTimeMillis()%>">
</head>
<body>

<!-- ── Contenedor Flex Fullscreen ────────────────────────────── -->
<div class="cocina-panel">

    <!-- 1. Topbar Corporativa -->
    <div class="cocina-topbar">
        <div class="topbar-icon">
            <i class="fas fa-utensils"></i>
        </div>
        <span class="topbar-title">Panel de Cocina</span>
        
        <div class="topbar-right">
            <div class="refresh-toggle">
                <span class="countdown-text" id="refresh-label">Actualización:</span>
                <label class="switch">
                    <input type="checkbox" id="auto-refresh-check" checked>
                    <span class="slider"></span>
                </label>
                <span class="timer-badge" id="timer-badge">30s</span>
            </div>
        </div>
    </div>

    <!-- 2. Toolbar (Filtros y Métricas) -->
    <div class="cocina-toolbar">
        
        <!-- Fila A: Filtros de fecha -->
        <form method="GET" action="index.jsp" id="filterForm" class="filters-row">
            <span class="form-label"><i class="far fa-calendar-alt"></i> Periodo</span>
            <input type="date" class="form-control" id="fecha_inicio" name="fecha_inicio" value="<%=fechaInicio%>">
            <span class="form-label" style="margin:0;">al</span>
            <input type="date" class="form-control" id="fecha_fin" name="fecha_fin" value="<%=fechaFin%>">
            
            <button type="submit" class="btn-filter primary">
                <i class="fas fa-search"></i> Buscar
            </button>
            <button type="button" class="btn-filter secondary" onclick="limpiarFiltros()">
                <i class="fas fa-history"></i> Hoy
            </button>
        </form>

        <!-- Fila B: Métricas Compactas (Chips) -->
        <div class="metrics-row">
            <!-- Totales -->
            <div class="metric-chip mc-total">
                <div class="mc-data">
                    <span class="mc-val" id="totalPedidos"><%=totalPedidos%></span>
                    <span class="mc-lbl">Pedidos</span>
                </div>
                <i class="fas fa-clipboard-list mc-icon"></i>
            </div>
            <div class="metric-chip mc-anulados">
                <div class="mc-data">
                    <span class="mc-val"><%=pedidosAnulados%></span>
                    <span class="mc-lbl">Anulados</span>
                </div>
                <i class="fas fa-ban mc-icon"></i>
            </div>
            
            <div class="metric-divider"></div>

            <!-- Estados -->
            <div class="metric-chip mc-est-0">
                <div class="mc-data"><span class="mc-val" id="countEst0"><%=est0%></span><span class="mc-lbl">Recibido</span></div>
                <i class="fas fa-file-alt mc-icon"></i>
            </div>
            <div class="metric-chip mc-est-1">
                <div class="mc-data"><span class="mc-val" id="countEst1"><%=est1%></span><span class="mc-lbl">En Cola</span></div>
                <i class="fas fa-hourglass-start mc-icon"></i>
            </div>
            <div class="metric-chip mc-est-2">
                <div class="mc-data"><span class="mc-val" id="countEst2"><%=est2%></span><span class="mc-lbl">Preparando</span></div>
                <i class="fas fa-blender mc-icon"></i>
            </div>
            <div class="metric-chip mc-est-3">
                <div class="mc-data"><span class="mc-val" id="countEst3"><%=est3%></span><span class="mc-lbl">Listo</span></div>
                <i class="fas fa-check mc-icon"></i>
            </div>
            <div class="metric-chip mc-est-4">
                <div class="mc-data"><span class="mc-val" id="countEst4"><%=est4%></span><span class="mc-lbl">Servido</span></div>
                <i class="fas fa-hand-holding mc-icon"></i>
            </div>
        </div>
    </div>

    <!-- 3. Contenido Principal (Tabla) -->
    <div class="cocina-content">

        <% if (!s_alert.equals("X")) { %>
        <div id="floating-alert" class="alert <%= (s_alert.equals("1")||s_alert.equals("2")||s_alert.equals("3")) ? "alert-success" : "alert-info" %> alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle mr-1"></i>
            <%= s_alert.equals("1") ? "Proceso actualizado." : s_alert.equals("2") ? "Se marcó como listo." : "Se marcó como servido." %>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close" style="padding: 0.5rem 1rem;">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
        <% } %>

        <div class="card-kares">
            <div class="card-header">
                <i class="fas fa-list-alt"></i> Registro de Atenciones
                <span class="badge-kares ml-auto" id="badge-total-filas" style="background:#e4e8ef;color:#3d5170;font-weight:700;">0</span>
            </div>
            <div class="card-body">    
                <table id="dataTables1" class="table-kares table-hover" style="width:100%">      
                    <thead>
                        <tr>
                            <th style="width:30px">#</th>
                            <th style="width:110px">Fecha</th>
                            <th style="width:80px">Documento</th>
                            <th>Cliente</th>
                            <th style="width:70px">Mesa</th>
                            <th style="width:40px">Detalle</th>
                            <th style="width:160px">Progreso de Atención</th>
                            <th style="width:60px" class="text-center">Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%            
                        int orden = 0; 
                        try {
                            String COMANDO =
                                "SELECT " +
                                "DATE_FORMAT(b.fecha,'%Y-%m-%d') AS fecha_reg, " +
                                "DATE_FORMAT(b.fecha,'%d/%m/%Y %H:%i') AS fecha_mostrar, " +
                                "b.tipo_doc, b.id_personal, nom_doc3(b.tipo_doc) pref, " +
                                "b.numdoc, b.id_mov_vnt, b.estado, " +
                                "nombre('*') nombre, " +
                                "id_mesa, " +
                                "IFNULL(agg.min_est, 0) as min_est, " +
                                "IFNULL(agg.total_items, 0) as total_items, " +
                                "IFNULL(agg.c0, 0) as c0, " +
                                "IFNULL(agg.c1, 0) as c1, " +
                                "IFNULL(agg.c2, 0) as c2, " +
                                "IFNULL(agg.c3, 0) as c3, " +
                                "IFNULL(agg.c4, 0) as c4 " +
                                "FROM vent_registro b " +
                                "LEFT JOIN (" +
                                "  SELECT id_mov_vnt, " +
                                "  MIN(IFNULL(estado_atencion,0)) as min_est, " +
                                "  COUNT(*) as total_items, " +
                                "  SUM(CASE WHEN estado_atencion=0 THEN 1 ELSE 0 END) as c0, " +
                                "  SUM(CASE WHEN estado_atencion=1 THEN 1 ELSE 0 END) as c1, " +
                                "  SUM(CASE WHEN estado_atencion=2 THEN 1 ELSE 0 END) as c2, " +
                                "  SUM(CASE WHEN estado_atencion=3 THEN 1 ELSE 0 END) as c3, " +
                                "  SUM(CASE WHEN estado_atencion=4 THEN 1 ELSE 0 END) as c4 " +
                                "  FROM vent_regdet GROUP BY id_mov_vnt " +
                                ") agg ON b.id_mov_vnt = agg.id_mov_vnt " +
                                "WHERE b.estado IN ('A','V') AND b.modo='2' " +
                                "AND b.fecha >= ? AND b.fecha < DATE_ADD(?, INTERVAL 1 DAY) AND b.TIPO_DOC IN ('11') " +
                                "ORDER BY b.fecha DESC, numdoc DESC";
                            
                            conn  = getConexion();
                            pstmt = conn.prepareStatement(COMANDO);
                            pstmt.setString(1, fechaInicio);
                            pstmt.setString(2, fechaFin);               
                            rset  = pstmt.executeQuery();

                            while(rset.next()) {  
                                orden++;
                                String estadoVnt  = rset.getString("estado");
                                String badgeClass = estadoVnt.equals("V") ? "badge-v" : "badge-a";
                                String estadoText = estadoVnt.equals("V") ? "ACTIVO"  : "ANULADO";
                                
                                int minEst  = rset.getInt("min_est");
                                int total   = rset.getInt("total_items");
                                if(total == 0) total = 1;
                                
                                double p0 = (rset.getDouble("c0") / total) * 100;
                                double p1 = (rset.getDouble("c1") / total) * 100;
                                double p2 = (rset.getDouble("c2") / total) * 100;
                                double p3 = (rset.getDouble("c3") / total) * 100;
                                double p4 = (rset.getDouble("c4") / total) * 100;

                                String[] n_est = {"RECIBIDO","EN COLA","PREPARANDO","LISTO","SERVIDO"};
                                if(minEst < 0 || minEst > 4) minEst = 0;
                    %> 
                    <tr>
                        <td style="font-weight:700;color:#64748b;"><%=orden%></td>
                        <td style="font-size:11px;color:#64748b;"><%=rset.getString("fecha_mostrar")%></td>
                        <td><span style="font-size:11px;font-weight:700;color:#1e40af;"><%=rset.getString("pref").trim()%>-<%=rset.getString("numdoc").trim()%></span></td>
                        <td style="font-weight:600;"><%=rset.getString("nombre")%></td>
                        <td><span class="badge-kares" style="background:#dbeafe;color:#1e40af;">Mesa <%=rset.getString("id_mesa")%></span></td>
                        <td>
                            <button type="button" data-toggle="tooltip" title="Ver Detalle"
                                    class="btn-kares btn-action"
                                    onclick="verDetalle('<%=rset.getString("id_mov_vnt")%>', this, '<%=estadoVnt%>')">
                                <i class="fas fa-receipt"></i>
                            </button>
                        </td>
                        <td>
                            <div class="progress-container">
                                <div class="order-progress">
                                    <% if(p0>0){%><div class="progress-segment seg-0" style="width:<%=p0%>%"></div><%}%>
                                    <% if(p1>0){%><div class="progress-segment seg-1" style="width:<%=p1%>%"></div><%}%>
                                    <% if(p2>0){%><div class="progress-segment seg-2" style="width:<%=p2%>%"></div><%}%>
                                    <% if(p3>0){%><div class="progress-segment seg-3" style="width:<%=p3%>%"></div><%}%>
                                    <% if(p4>0){%><div class="progress-segment seg-4" style="width:<%=p4%>%"></div><%}%>
                                </div>
                                <span class="status-label"><%=n_est[minEst]%></span>
                            </div>
                        </td>
                        <td class="text-center">
                            <span class="badge-status <%=badgeClass%>"><%=estadoText%></span>
                        </td>
                    </tr>
                    <%  }
                        } catch(Exception e){ e.printStackTrace(); }
                        finally { cerrar(rset, pstmt, conn); }  
                    %>
                    </tbody>
                </table>
                <% if(orden == 0) { %>
                <div style="padding: 40px; text-align: center; color: #94a3b8;">
                    <i class="fas fa-box-open fa-3x" style="opacity:0.3; margin-bottom:10px;"></i>
                    <p style="margin:0;font-size:14px;">No se encontraron registros para este periodo.</p>
                </div> 
                <% } %>
            </div>
        </div>

    </div><!-- /cocina-content -->

</div><!-- /cocina-panel -->

<!-- Audio de notificación -->
<audio id="order-sound" src="https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3" preload="auto"></audio>

<!-- Datos para JS -->
<script>
  window._dashData = {
    totalPedidos:   <%=totalPedidos%>,
    recibidos:      <%=est0%>
  };
</script>

<!-- Scripts -->
<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/datatables/jquery.dataTables.min.js"></script>
<script src="../../assets/plugins/datatables-responsive/js/dataTables.responsive.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script src="../../assets/js/mesa/ope_cocina/index.js?v=<%=System.currentTimeMillis()%>"></script>
<script>
    // Auto-hide alert flotante si existe
    $(function(){
        setTimeout(function(){
            $('#floating-alert').fadeOut('slow');
        }, 3500);
    });
</script>
</body>
</html>
