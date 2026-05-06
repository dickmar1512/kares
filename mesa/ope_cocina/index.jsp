<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp"%>
<%@ include file = "id.jsp" %>
<%@ include file = "../seguro.jsp" %>
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
    <title>Dashboard Cocina - Kares</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="shortcut icon" href="../../assets/images/favicon.ico" />
    <link href="../../assets/plugins/fontsgstatic/css/css2.css" rel="stylesheet">
    <link href="../../assets/plugins/bootstrap/css/bootstrap4.6.2.min.css" rel="stylesheet" />    
    <link href="../../assets/plugins/fontawesome-free/css/all.min.css" rel="stylesheet" />  
    <link href="../../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css" rel="stylesheet" />
    <link href="../../assets/plugins/adminlte3/css/adminlte.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/mesa/ope_cocina/index.css">
</head>
<body class="hold-transition layout-top-nav">
<div class="wrapper">
  <div class="content-wrapper">

    <!-- ── Header ────────────────────────────────────────────────── -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-4 align-items-center">
          <div class="col-sm-6">
            <h1><i class="fas fa-utensils mr-2 text-primary"></i> Panel de Cocina</h1>
          </div>
          <div class="col-sm-6 d-flex justify-content-end">
            <div class="refresh-toggle">
              <span class="countdown-text" id="refresh-label">Actualización automática</span>
              <label class="switch">
                <input type="checkbox" id="auto-refresh-check" checked>
                <span class="slider"></span>
              </label>
              <span class="badge badge-pill badge-light border" id="timer-badge">30s</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Contenido ─────────────────────────────────────────────── -->
    <section class="content">
      <div class="container-fluid">
        <div id="dashboard-container">

          <!-- Fila 1: Totales generales -->
          <div class="row mb-3">
            <div class="col-lg-3 col-6 mb-3">
              <div class="summary-card bg-custom-total">
                <div class="inner">
                  <h3 id="totalPedidos"><%=totalPedidos%></h3>
                  <p>Total Pedidos</p>
                </div>
                <div class="icon"><i class="fas fa-clipboard-list"></i></div>
              </div>
            </div>
            <div class="col-lg-3 col-6 mb-3">
              <div class="summary-card bg-custom-canceled">
                <div class="inner">
                  <h3><%=pedidosAnulados%></h3>
                  <p>Pedidos Anulados</p>
                </div>
                <div class="icon"><i class="fas fa-ban"></i></div>
              </div>
            </div>
          </div>

          <!-- Fila 2: Estados de atención -->
          <div class="row mb-4">
            <div class="col-12 mb-2">
              <small class="text-uppercase text-muted font-weight-bold">
                <i class="fas fa-fire mr-1"></i> Atenciones Activas — Ítems por estado
              </small>
            </div>

            <div class="col mb-2">
              <div class="summary-card bg-estado-0">
                <div class="inner">
                  <h3 id="countEst0"><%=est0%></h3>
                  <p>RECIBIDO</p>
                </div>
                <div class="icon"><i class="fas fa-file-alt"></i></div>
              </div>
            </div>
            <div class="col mb-2">
              <div class="summary-card bg-estado-1">
                <div class="inner">
                  <h3 id="countEst1"><%=est1%></h3>
                  <p>EN COLA</p>
                </div>
                <div class="icon"><i class="fas fa-hourglass-start"></i></div>
              </div>
            </div>
            <div class="col mb-2">
              <div class="summary-card bg-estado-2">
                <div class="inner">
                  <h3 id="countEst2"><%=est2%></h3>
                  <p>PREPARANDO</p>
                </div>
                <div class="icon"><i class="fas fa-blender"></i></div>
              </div>
            </div>
            <div class="col mb-2">
              <div class="summary-card bg-estado-3">
                <div class="inner">
                  <h3 id="countEst3"><%=est3%></h3>
                  <p>LISTO</p>
                </div>
                <div class="icon"><i class="fas fa-check"></i></div>
              </div>
            </div>
            <div class="col mb-2">
              <div class="summary-card bg-estado-4">
                <div class="inner">
                  <h3 id="countEst4"><%=est4%></h3>
                  <p>SERVIDO</p>
                </div>
                <div class="icon"><i class="fas fa-hand-holding"></i></div>
              </div>
            </div>
          </div>

          <!-- Alerta de acción -->
          <% if (!s_alert.equals("X")) { %>
            <div class="alert alert-<%= (s_alert.equals("1")||s_alert.equals("2")||s_alert.equals("3")) ? "success" : "info" %> alert-dismissible fade show" role="alert">
              <i class="icon fas fa-check-circle mr-2"></i>
              <%= s_alert.equals("1") ? "Proceso actualizado satisfactoriamente." : s_alert.equals("2") ? "Se marcó como listo." : "Se marcó como servido." %>
              <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
          <% } %>

          <!-- Filtros -->
          <div class="filter-section">
            <form method="GET" action="index.jsp" id="filterForm" class="row align-items-end">
              <div class="col-md-3">
                <label class="form-label font-weight-bold small text-uppercase text-muted">Fecha Inicio</label>
                <input type="date" class="form-control border-0 bg-light" id="fecha_inicio" name="fecha_inicio" value="<%=fechaInicio%>">
              </div>
              <div class="col-md-3">
                <label class="form-label font-weight-bold small text-uppercase text-muted">Fecha Fin</label>
                <input type="date" class="form-control border-0 bg-light" id="fecha_fin" name="fecha_fin" value="<%=fechaFin%>">
              </div>
              <div class="col-md-4">
                <button type="submit" class="btn btn-primary px-4 shadow-sm">
                  <i class="fas fa-search mr-2"></i> Buscar
                </button>
                <button type="button" class="btn btn-outline-secondary ml-2 border-0 shadow-sm" onclick="limpiarFiltros()">
                  <i class="fas fa-history mr-2"></i> Hoy
                </button>
              </div>
            </form>
          </div>

          <!-- Tabla de pedidos -->
          <div class="card card-kares">
            <div class="card-header">
              <i class="fas fa-list-alt"></i>
              <span class="card-title">Registro de Pedidos</span>
              <span class="badge-count" id="badge-total-filas">0</span>
            </div>
            <div class="card-body p-0">    
              <table id="dataTables1" class="table table-kares table-hover mb-0">      
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Fecha</th>
                    <th>Documento</th>
                    <th>Cliente</th>
                    <th>Mesa</th>
                    <th>Detalle</th>
                    <th>Atención</th>
                    <th class="text-center">Estado</th>
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
                  <td class="code"><%=orden%></td>
                  <td><span class="text-dark"><%=rset.getString("fecha_mostrar")%></span></td>
                  <td><span class="badge-kares" style="background:#eef1f7;color:var(--kares-secondary);"><%=rset.getString("pref").trim()%>-<%=rset.getString("numdoc").trim()%></span></td>
                  <td><span class="font-weight-600"><%=rset.getString("nombre")%></span></td>
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
                    <div class="d-flex align-items-center justify-content-center">
                      <span class="badge-status <%=badgeClass%>"><%=estadoText%></span>
                    </div>
                  </td>
                </tr>
                <%  }
                    } catch(Exception e){ e.printStackTrace(); }
                    finally { cerrar(rset, pstmt, conn); }  
                %>
                </tbody>
              </table>
              <% if(orden == 0) { %>
              <div class="p-5 text-center text-muted">
                <i class="fas fa-box-open fa-3x mb-3 opacity-25"></i>
                <p class="h5">No se encontraron registros para este periodo.</p>
              </div> 
              <% } %>
            </div>
          </div>

        </div><!-- /dashboard-container -->
      </div>
    </section>
  </div>
</div>

<!-- Audio de notificación -->
<audio id="order-sound" src="https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3" preload="auto"></audio>

<!-- Datos para JS (evita leer el DOM antes de que esté listo) -->
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
<script src="../../assets/js/mesa/ope_cocina/index.js"></script>
</body>
</html>
