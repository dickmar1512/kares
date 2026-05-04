<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../config/database.jsp" %>
<% String id_jsp="---"; %>
<%@ include file="seguro.jsp" %>
<%
    // Metrics variables
    int totalTables = 0;
    int occupiedTables = 0;
    int availableTables = 0;
    int reservedTables = 0;
    double todaySales = 0;
    
    // Fetch Table Stats
    try {
        conn = getConexion();
        COMANDO = "SELECT estado, COUNT(*) as count FROM mesas GROUP BY estado";
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        while (rset.next()) {
            int estado = rset.getInt("estado");
            int count = rset.getInt("count");
            if (estado == 0) availableTables = count;
            else if (estado == 1) reservedTables = count;
            else if (estado == 2) occupiedTables = count;
            totalTables += count;
        }
    } catch (Exception e) {
        System.err.println("Error fetching table stats: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
    
    // Fetch Today's Sales
    String salesLabels = "";
    String salesDataValues = "";
    try {
        conn = getConexion();
        // Sum total from vent_registro for today
        COMANDO = "SELECT SUM(total) as total FROM vent_registro WHERE DATE(fecha) = CURDATE() AND estado = 'V'";
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            todaySales = rset.getDouble("total");
        }
        cerrar(rset, pstmt, conn);

        // Fetch Sales Flow (by hour)
        conn = getConexion();
        COMANDO = "SELECT DATE_FORMAT(fecha, '%H:%i') as hora, SUM(total) as total_hora " +
                  "FROM vent_registro " +
                  "WHERE TIPO_DOC = '11' AND DATE(fecha) = CURDATE() AND estado = 'V' " +
                  "GROUP BY hora ORDER BY hora";
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();
        StringBuilder labels = new StringBuilder();
        StringBuilder values = new StringBuilder();
        while (rset.next()) {
            if (labels.length() > 0) {
                labels.append(",");
                values.append(",");
            }
            labels.append("'").append(rset.getString("hora")).append("'");
            values.append(rset.getString("total_hora"));
        }
        salesLabels = labels.toString();
        salesDataValues = values.toString();
    } catch (Exception e) {
        System.err.println("Error fetching sales data: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard Mesas</title>
    
    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="../assets/plugins/fontsgstatic/css/css.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <!-- AdminLTE 3 -->
    <link rel="stylesheet" href="../assets/plugins/adminlte3/css/adminlte.min.css">
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../assets/css/mesa/main.css">
</head>
<body class="hold-transition">

<div class="dashboard-container">
    <!-- Summary Cards -->
    <div class="row">
        <div class="col-lg-3 col-6 fade-in stagger-1">
            <div class="small-box bg-info">
                <div class="inner">
                    <h3><%=totalTables%></h3>
                    <p>Total Mesas</p>
                </div>
                <div class="icon">
                    <i class="fas fa-table"></i>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-6 fade-in stagger-2">
            <div class="small-box bg-success">
                <div class="inner">
                    <h3><%=availableTables%></h3>
                    <p>Disponibles</p>
                </div>
                <div class="icon">
                    <i class="fas fa-check-circle"></i>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-6 fade-in stagger-3">
            <div class="small-box bg-danger">
                <div class="inner">
                    <h3><%=occupiedTables%></h3>
                    <p>Ocupadas</p>
                </div>
                <div class="icon">
                    <i class="fas fa-utensils"></i>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-6 fade-in stagger-4">
            <div class="small-box bg-warning">
                <div class="inner">
                    <h3 style="font-size: 1.8rem;">S/ <%=String.format("%.2f", todaySales)%></h3>
                    <p>Ventas de Hoy</p>
                </div>
                <div class="icon">
                    <i class="fas fa-cash-register"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="row mt-4">
        <div class="col-md-4 fade-in stagger-2">
            <div class="card card-glass h-100">
                <div class="card-header">
                    <h3 class="card-title"><i class="fas fa-chart-pie mr-1"></i> Ocupación de Mesas</h3>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="occupancyChart" 
                                data-occupied="<%=occupiedTables%>" 
                                data-available="<%=availableTables%>" 
                                data-reserved="<%=reservedTables%>"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-8 fade-in stagger-3">
            <div class="card card-glass h-100">
                <div class="card-header">
                    <h3 class="card-title"><i class="fas fa-chart-line mr-1"></i> Flujo de Ventas (Hoy)</h3>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="salesChart" 
                                data-labels="[<%=salesLabels%>]" 
                                data-values="[<%=salesDataValues%>]"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tables Section -->
    <div class="row mt-4">
        <!-- Recent Orders -->
        <div class="col-md-7 fade-in stagger-3">
            <div class="card card-glass">
                <div class="card-header border-0">
                    <h3 class="card-title"><i class="fas fa-shopping-basket mr-1"></i> Últimas Órdenes</h3>
                </div>
                <div class="card-body p-0">
                    <table class="table table-striped table-valign-middle">
                        <thead>
                            <tr>
                                <th>Nro Orden</th>
                                <th>Total</th>
                                <th>Fecha/Hora</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    conn = getConexion();
                                    COMANDO = "SELECT numdoc, total, DATE_FORMAT(fecha, '%H:%i') as hora FROM vent_registro WHERE estado = 'V' ORDER BY fecha DESC LIMIT 5";
                                    pstmt = conn.prepareStatement(COMANDO);
                                    rset = pstmt.executeQuery();
                                    while (rset.next()) {
                            %>
                            <tr>
                                <td><span class="badge badge-pill badge-primary">#<%=rset.getString("numdoc")%></span></td>
                                <td><strong>S/ <%=String.format("%.2f", rset.getDouble("total"))%></strong></td>
                                <td class="text-muted"><i class="far fa-clock mr-1"></i><%=rset.getString("hora")%></td>
                                <td><a href="#" class="text-muted"><i class="fas fa-search"></i></a></td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                                } finally {
                                    cerrar(rset, pstmt, conn);
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Top Products -->
        <div class="col-md-5 fade-in stagger-4">
            <div class="card card-glass">
                <div class="card-header border-0">
                    <h3 class="card-title"><i class="fas fa-star mr-1"></i> Top 5 Productos</h3>
                </div>
                <div class="card-body p-0">
                    <table class="table table-striped table-valign-middle">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th class="text-center">Cant.</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    conn = getConexion();
                                    COMANDO = "SELECT glosa, SUM(cantidad) as total_cant FROM vent_regdet WHERE DATE(fecha) = CURDATE() AND estado = 'V' GROUP BY glosa ORDER BY total_cant DESC LIMIT 5";
                                    pstmt = conn.prepareStatement(COMANDO);
                                    rset = pstmt.executeQuery();
                                    while (rset.next()) {
                            %>
                            <tr>
                                <td><%=rset.getString("glosa")%></td>
                                <td class="text-center"><span class="badge badge-success"><%=Math.round(rset.getFloat("total_cant"))%></span></td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='2'>Error: " + e.getMessage() + "</td></tr>");
                                } finally {
                                    cerrar(rset, pstmt, conn);
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="../assets/plugins/jquery/jquery.min.js"></script>
<script src="../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../assets/plugins/chart.js/Chart.min.js"></script>
<!-- Dashboard Main JS -->
<script src="../assets/js/mesa/main.js"></script>
</body>
</html>