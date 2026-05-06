<%@page language="java" contentType="text/html, charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ include file="../../config/database.jsp" %>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
  String s_idm = request.getParameter("idm");
  String s_id_mov_vnt = "";
	try{		
		COMANDO	=	"select "+
						"round(RAND()*10000000000000000) "+
					"from dual ";
		conn = getConexion();
		pstmt = conn.prepareStatement(COMANDO);		
		rset = pstmt.executeQuery();
		rset.next();
		{ band++;
			s_id_mov_vnt = rset.getString(1);
		}
	} catch(Exception e){ 
        out.println("ERROR: " + e.getMessage()); 
    } finally{ 
        cerrar(rset); cerrar(pstmt); cerrar(conn);
        COMANDO = ""; 
     }

	xsession.putValue("id_mov_vnt", s_id_mov_vnt);
	xsession.putValue("idm",s_idm);	
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Punto de Venta — Mesa <%=s_idm != null ? s_idm : ""%> · Kares</title>
    <link rel="shortcut icon" href="../../assets/images/favicon.ico">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/show_venta.css">
</head>
<body>

    <!-- ── Barra de título ──────────────────────────────────────── -->
    <div class="venta-topbar">
        <div class="topbar-icon">
            <i class="fas fa-cash-register"></i>
        </div>
        <span class="topbar-title">Punto de Venta</span>
        <span class="topbar-badge"><i class="fas fa-chair mr-1"></i>Mesa <%=s_idm != null ? s_idm : "—"%></span>
        <div class="topbar-right">
            <span class="topbar-time" id="clock-display"></span>
        </div>
    </div>

    <!-- ── Split panel ──────────────────────────────────────────── -->
    <div class="split-container">

        <!-- Panel izquierdo: catálogo -->
        <div class="panel-catalogo" id="panel-left">
            <iframe src="show_familia_producto.jsp"
                    name="menu" id="menu"
                    frameborder="0"
                    allowtransparency="true"
                    title="Catálogo de productos"></iframe>
        </div>

        <!-- Divisor visual -->
        <div class="panel-divider" id="panel-divider"></div>

        <!-- Panel derecho: carrito + órdenes -->
        <div class="panel-carrito" id="panel-right">
            <iframe src="form_venta.jsp"
                    name="venta" id="venta"
                    frameborder="0"
                    allowtransparency="true"
                    title="Detalle de venta"></iframe>
        </div>

    </div>

    <script src="../../assets/plugins/jquery/jquery.min.js"></script>
    <script>
        /* ── Reloj en topbar ──────────────────────────────────────── */
        (function clockTick() {
            const el = document.getElementById('clock-display');
            if (!el) return;
            const now = new Date();
            const h = String(now.getHours()).padStart(2,'0');
            const m = String(now.getMinutes()).padStart(2,'0');
            const s = String(now.getSeconds()).padStart(2,'0');
            el.textContent = h + ':' + m + ':' + s;
            setTimeout(clockTick, 1000);
        })();

        /* ── Recargar iframe de venta (llamado desde catálogo) ────── */
        function actualizarTotalVenta() {
            const iframe = document.getElementById('venta');
            if (iframe && iframe.contentWindow) {
                iframe.contentWindow.location.reload();
            }
        }

        /* ── Divisor redimensionable (drag) ───────────────────────── */
        (function initDivider() {
            const divider  = document.getElementById('panel-divider');
            const left     = document.getElementById('panel-left');
            const right    = document.getElementById('panel-right');
            const container = divider.parentElement;
            let dragging = false;

            divider.addEventListener('mousedown', function(e) {
                dragging = true;
                document.body.style.cursor = 'col-resize';
                document.body.style.userSelect = 'none';
                e.preventDefault();
            });

            document.addEventListener('mousemove', function(e) {
                if (!dragging) return;
                const rect = container.getBoundingClientRect();
                const offsetX = e.clientX - rect.left;
                const total = rect.width - divider.offsetWidth;
                const pct = Math.min(Math.max((offsetX / total) * 100, 30), 70);
                left.style.width = pct + '%';
                right.style.flex = 'unset';
                right.style.width = (100 - pct) + '%';
            });

            document.addEventListener('mouseup', function() {
                dragging = false;
                document.body.style.cursor = '';
                document.body.style.userSelect = '';
            });
        })();
    </script>
</body>
</html>