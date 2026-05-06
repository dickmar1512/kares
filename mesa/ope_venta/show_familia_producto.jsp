<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catálogo · Kares</title>
    <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/show_familia_producto.css">
</head>
<body>

<!-- ── Toast container ──────────────────────────────────────── -->
<div id="catalog-toast"></div>

<!-- ── Wrapper principal (flex column) ──────────────────────── -->
<div style="display:flex; flex-direction:column; height:100vh; overflow:hidden;">

    <!-- Header: búsqueda + tabs -->
    <div class="catalog-header">
        <!-- Buscador -->
        <div class="catalog-search">
            <i class="fas fa-search search-icon"></i>
            <input type="text" id="product-search"
                   placeholder="Buscar producto..."
                   autocomplete="off">
            <span class="search-count" id="search-count"></span>
        </div>

        <!-- Tabs de categorías -->
        <ul class="nav nav-tabs-compact" id="custom-tabs-menu" role="tablist">
            <%
                int tabIndex = 0;
                Connection connTabs = null;
                PreparedStatement pstmtTabs = null;
                ResultSet rsetTabs = null;

                try {
                    connTabs = getConexion();
                    COMANDO = "SELECT ID_NIVEL, NOMBRE FROM NIVEL WHERE estado = 1 ORDER BY nombre ASC";
                    pstmtTabs = connTabs.prepareStatement(COMANDO);
                    rsetTabs = pstmtTabs.executeQuery();

                    while(rsetTabs.next()) {
                        tabIndex++;
                        String idNivel = rsetTabs.getString("ID_NIVEL");
                        String nombre  = rsetTabs.getString("NOMBRE");

                        /* Contar productos del nivel */
                        Connection connCount = null;
                        PreparedStatement pstmtCount = null;
                        ResultSet rsetCount = null;
                        int prodCount = 0;
                        try {
                            connCount = getConexion();
                            pstmtCount = connCount.prepareStatement(
                                "SELECT COUNT(*) FROM patron WHERE id_nivel = ? AND estado = '1'"
                            );
                            pstmtCount.setString(1, idNivel);
                            rsetCount = pstmtCount.executeQuery();
                            if (rsetCount.next()) prodCount = rsetCount.getInt(1);
                        } finally {
                            cerrar(rsetCount); cerrar(pstmtCount); cerrar(connCount);
                        }

                        if (prodCount == 0) continue;
                        String isActive = (tabIndex == 1) ? "active" : "";
            %>
                <li class="nav-item">
                    <a class="nav-link <%=isActive%>"
                       id="tab-<%=idNivel%>"
                       data-toggle="pill"
                       href="#nivel-<%=idNivel%>"
                       role="tab"
                       aria-controls="nivel-<%=idNivel%>"
                       aria-selected="<%=tabIndex == 1%>">
                        <%=nombre%>
                        <span class="tab-count"><%=prodCount%></span>
                    </a>
                </li>
            <%
                    }
                } finally {
                    cerrar(rsetTabs); cerrar(pstmtTabs); cerrar(connTabs);
                }
            %>
        </ul>
    </div><!-- /catalog-header -->

    <!-- Body: contenido de tabs con productos -->
    <div class="catalog-body">
        <div class="tab-content" id="custom-tabs-menuContent">
        <%
            tabIndex = 0;
            Connection connContent = null;
            PreparedStatement pstmtContent = null;
            ResultSet rsetContent = null;

            try {
                connContent = getConexion();
                COMANDO = "SELECT ID_NIVEL, NOMBRE FROM NIVEL WHERE estado = 1 ORDER BY nombre ASC";
                pstmtContent = connContent.prepareStatement(COMANDO);
                rsetContent  = pstmtContent.executeQuery();

                while(rsetContent.next()) {
                    tabIndex++;
                    String idNivel = rsetContent.getString("ID_NIVEL");
                    String nombre  = rsetContent.getString("NOMBRE");

                    /* Verificar si tiene productos */
                    Connection connCheck = null;
                    PreparedStatement pstmtCheck = null;
                    ResultSet rsetCheck = null;
                    boolean hasProducts = false;
                    try {
                        connCheck = getConexion();
                        pstmtCheck = connCheck.prepareStatement(
                            "SELECT COUNT(*) FROM patron WHERE id_nivel = ? AND estado = '1'"
                        );
                        pstmtCheck.setString(1, idNivel);
                        rsetCheck = pstmtCheck.executeQuery();
                        if (rsetCheck.next() && rsetCheck.getInt(1) > 0) hasProducts = true;
                    } finally {
                        cerrar(rsetCheck); cerrar(pstmtCheck); cerrar(connCheck);
                    }

                    if (!hasProducts) continue;
                    String showActive = (tabIndex == 1) ? "show active" : "";
        %>
            <div class="tab-pane fade <%=showActive%>"
                 id="nivel-<%=idNivel%>"
                 role="tabpanel"
                 aria-labelledby="tab-<%=idNivel%>">

                <div class="products-grid">
                <%
                    Connection connProducts = null;
                    PreparedStatement pstmtProducts = null;
                    ResultSet rsetProducts = null;
                    int prodRendered = 0;
                    try {
                        connProducts = getConexion();
                        COMANDO2 = "SELECT id_servicio, nombre, tarifa FROM patron " +
                                   "WHERE id_nivel = ? AND estado = '1' ORDER BY nombre ASC";
                        pstmtProducts = connProducts.prepareStatement(COMANDO2);
                        pstmtProducts.setString(1, idNivel);
                        rsetProducts = pstmtProducts.executeQuery();

                        while(rsetProducts.next()) {
                            prodRendered++;
                            String idServicio  = rsetProducts.getString("id_servicio");
                            String nombreProd  = rsetProducts.getString("nombre");
                            String tarifa      = rsetProducts.getString("tarifa");
                            String titleAttr   = nombreProd.replace("\"","&quot;");
                %>
                    <div class="product-box" title="<%=titleAttr%>">
                        <h5><%=nombreProd%></h5>
                        <div class="product-price">
                            <span>S/</span><%=tarifa%>
                        </div>
                        <div class="product-controls">
                            <div class="qty-wrapper">
                                <button type="button" class="qty-btn qty-minus" tabindex="-1">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <input type="number"
                                       class="qty-input cantidad-input"
                                       value="1" min="1" max="99">
                                <button type="button" class="qty-btn qty-plus" tabindex="-1">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                            <button type="button"
                                    data-id-servicio="<%=idServicio%>"
                                    class="btn-add-producto">
                                <i class="fas fa-cart-plus"></i> Agregar
                            </button>
                        </div>
                    </div>
                <%
                        }
                    } finally {
                        cerrar(rsetProducts); cerrar(pstmtProducts); cerrar(connProducts);
                    }
                    if (prodRendered == 0) {
                %>
                    <div class="no-products">
                        <i class="fas fa-box-open"></i>
                        <p>Sin productos disponibles</p>
                    </div>
                <%  } %>
                </div><!-- /products-grid -->

            </div><!-- /tab-pane -->
        <%
                }
            } finally {
                cerrar(rsetContent); cerrar(pstmtContent); cerrar(connContent);
            }
        %>
        </div><!-- /tab-content -->
    </div><!-- /catalog-body -->
</div><!-- /flex wrapper -->

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/js/mesa/ope_venta/show_familia_producto.js?v=<%=System.currentTimeMillis()%>"></script>
</body>
</html>