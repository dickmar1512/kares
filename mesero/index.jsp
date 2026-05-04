<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String s_idm = request.getParameter("idm");
    String s_id_personal = request.getParameter("id_personal");
    
    if (s_idm == null || s_idm.isEmpty()) {
        out.println("<h2>Error: Mesa no especificada. Por favor escanee el código QR de su mesa.</h2>");
        return;
    }
    if (s_id_personal == null || s_id_personal.isEmpty()) {
        s_id_personal = "*";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Menú Virtual - Mesa <%=s_idm%></title>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="../assets/plugins/fontawesome6.7.2/css/all.min.css">
    
    <style>
        :root {
            --bg-dark: #121212;
            --bg-card: #1e1e1e;
            --primary: #f39c12; /* Naranja apetitoso */
            --primary-dark: #d68910;
            --text-main: #fdfefe;
            --text-muted: #bdc3c7;
            --border: #2c3e50;
            --success: #27ae60;
            --danger: #e74c3c;
            --radius: 16px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            -webkit-tap-highlight-color: transparent;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            padding-bottom: 80px; /* Space for bottom nav */
        }

        /* HEADER */
        .header {
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(18, 18, 18, 0.85);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
        }

        .header h1 {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .mesa-badge {
            background: rgba(243, 156, 18, 0.2);
            color: var(--primary);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        /* HERO SECTION */
        .hero {
            padding: 20px;
            text-align: center;
            background: linear-gradient(to bottom, rgba(243, 156, 18, 0.1), transparent);
        }
        
        .hero h2 {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .hero p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        /* SEARCH BAR */
        .search-container {
            padding: 0 20px 20px;
        }
        
        .search-bar {
            background: var(--bg-card);
            border-radius: 30px;
            padding: 10px 15px;
            display: flex;
            align-items: center;
            border: 1px solid var(--border);
        }
        
        .search-bar i {
            color: var(--text-muted);
            margin-right: 10px;
        }
        
        .search-bar input {
            background: transparent;
            border: none;
            color: var(--text-main);
            width: 100%;
            font-size: 1rem;
            outline: none;
        }

        /* MENU LIST */
        .menu-container {
            padding: 0 20px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .menu-item {
            background: var(--bg-card);
            border-radius: var(--radius);
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid var(--border);
            transition: transform 0.2s;
        }
        
        .menu-item:active {
            transform: scale(0.98);
        }

        .item-info {
            flex: 1;
            padding-right: 15px;
        }

        .item-name {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .item-price {
            color: var(--primary);
            font-weight: 700;
            font-size: 1.1rem;
        }

        /* QUANTITY CONTROLS */
        .qty-controls {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(255, 255, 255, 0.05);
            padding: 6px;
            border-radius: 30px;
        }

        .btn-qty {
            background: var(--primary);
            color: #fff;
            border: none;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(243, 156, 18, 0.3);
        }
        
        .btn-qty.minus {
            background: var(--bg-dark);
            color: var(--text-main);
            box-shadow: none;
            border: 1px solid var(--border);
        }

        .qty-value {
            font-weight: 700;
            font-size: 1.1rem;
            min-width: 20px;
            text-align: center;
        }

        /* BOTTOM CART BAR */
        .cart-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            background: var(--bg-card);
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid var(--border);
            box-shadow: 0 -4px 20px rgba(0,0,0,0.5);
            transform: translateY(100%);
            transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            z-index: 1000;
        }

        .cart-bar.visible {
            transform: translateY(0);
        }

        .cart-info {
            display: flex;
            flex-direction: column;
        }

        .cart-total {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary);
        }
        
        .cart-items-count {
            font-size: 0.85rem;
            color: var(--text-muted);
        }

        .btn-checkout {
            background: var(--primary);
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 30px;
            font-size: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(243, 156, 18, 0.4);
        }

        /* LOADING SPINNER */
        .loader-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(243, 156, 18, 0.3);
            border-radius: 50%;
            border-top-color: var(--primary);
            animation: spin 1s ease-in-out infinite;
            margin-bottom: 15px;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* MODAL (SWEETALERT CUSTOM) */
        .swal2-popup.dark-theme {
            background: var(--bg-card) !important;
            color: var(--text-main) !important;
            border-radius: var(--radius) !important;
        }
        .swal2-title {
            color: var(--text-main) !important;
        }

        /* STATUS TRACKING STYLES */
        .btn-status-float {
            position: fixed;
            right: 20px;
            bottom: 90px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            z-index: 99;
            border: none;
            cursor: pointer;
            transition: transform 0.3s;
        }
        
        .btn-status-float:active {
            transform: scale(0.9);
        }

        .status-badge-count {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger);
            color: white;
            font-size: 0.7rem;
            padding: 2px 6px;
            border-radius: 10px;
            font-weight: 700;
        }

        .order-status-list {
            text-align: left;
            max-height: 400px;
            overflow-y: auto;
            padding-right: 5px;
        }

        .status-item {
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 10px;
            border-left: 4px solid var(--border);
        }

        .status-item.state-0 { border-left-color: #95a5a6; } /* Generado */
        .status-item.state-1 { border-left-color: #f39c12; } /* Pendiente */
        .status-item.state-2 { border-left-color: #3498db; } /* Procesando */
        .status-item.state-3 { border-left-color: #2ecc71; } /* Terminado */
        .status-item.state-4 { border-left-color: #1abc9c; } /* Entregado */

        .status-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }

        .status-name {
            font-weight: 600;
            font-size: 0.95rem;
        }

        .status-label-text {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 2px 8px;
            border-radius: 10px;
        }

        .label-0 { background: rgba(149, 165, 166, 0.2); color: #95a5a6; }
        .label-1 { background: rgba(243, 156, 18, 0.2); color: #f39c12; }
        .label-2 { background: rgba(52, 152, 219, 0.2); color: #3498db; }
        .label-3 { background: rgba(46, 204, 113, 0.2); color: #2ecc71; }
        .label-4 { background: rgba(26, 188, 156, 0.2); color: #1abc9c; }

        .status-progress-mini {
            height: 6px;
            background: rgba(255,255,255,0.1);
            border-radius: 3px;
            overflow: hidden;
        }

        .progress-bar-fill {
            height: 100%;
            transition: width 0.5s ease;
        }

        .fill-0 { width: 10%; background: #95a5a6; }
        .fill-1 { width: 25%; background: #f39c12; }
        .fill-2 { width: 60%; background: #3498db; }
        .fill-3 { width: 100%; background: #2ecc71; }
        .fill-4 { width: 100%; background: #1abc9c; }

        .status-footer {
            margin-top: 20px;
            padding-top: 15px;
            border-top: 2px dashed var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .total-label {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-muted);
        }

        .total-amount {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
        }

        .item-subtotal {
            font-weight: 700;
            color: var(--primary);
            font-size: 0.85rem;
        }
    </style>
</head>
<body>

    <header class="header">
        <h1><i class="fas fa-utensils"></i> Menú</h1>
        <div style="display: flex; gap: 10px; align-items: center;">
            <button class="mesa-badge" onclick="verEstadoPedido()" style="border:none; cursor:pointer; background: rgba(39, 174, 96, 0.2); color: #2ecc71;">
                <i class="fas fa-clock-rotate-left"></i> Mi Pedido
            </button>
            <div class="mesa-badge">Mesa <%=s_idm%></div>
        </div>
    </header>

    <div class="hero">
        <h2>¿Qué te apetece hoy?</h2>
        <p>Ordena directamente a la cocina</p>
    </div>

    <div class="search-container">
        <div class="search-bar">
            <i class="fas fa-search"></i>
            <input type="text" id="searchInput" placeholder="Buscar platillos, bebidas...">
        </div>
    </div>

    <div id="menuContainer" class="menu-container">
        <div class="loader-container">
            <div class="spinner"></div>
            <p>Cargando los platillos más deliciosos...</p>
        </div>
    </div>

    <div id="cartBar" class="cart-bar">
        <div class="cart-info">
            <span id="cartCount" class="cart-items-count">0 items</span>
            <span id="cartTotal" class="cart-total">S/ 0.00</span>
        </div>
        <button id="btnPedir" class="btn-checkout" onclick="enviarPedido()">
            Pedir Ahora <i class="fas fa-paper-plane"></i>
        </button>
    </div>

    <script src="../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
    <script>
        const idm = '<%=s_idm%>';
        const id_personal = '<%=s_id_personal%>';
        let menuData = [];
        let cart = {};

        document.addEventListener('DOMContentLoaded', loadMenu);

        // Búsqueda en tiempo real
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const term = e.target.value.toLowerCase();
            renderMenu(menuData.filter(item => item.nombre.toLowerCase().includes(term)));
        });

        async function loadMenu() {
            try {
                const response = await fetch('api_menu.jsp');
                const data = await response.json();
                
                if (data.success) {
                    menuData = data.items;
                    renderMenu(menuData);
                } else {
                    showError(data.message);
                }
            } catch (err) {
                showError('Error de conexión al cargar el menú.');
            }
        }

        function renderMenu(items) {
            const container = document.getElementById('menuContainer');
            if (items.length === 0) {
                container.innerHTML = '<div class="loader-container"><i class="fas fa-search fa-2x mb-2" style="color:var(--text-muted)"></i><p>No se encontraron platillos</p></div>';
                return;
            }

            container.innerHTML = items.map(item => {
                const qty = cart[item.idservicio] ? cart[item.idservicio].cantidad : 0;
                
                return `
                <div class="menu-item">
                    <div class="item-info">
                        <div class="item-name">\${item.nombre}</div>
                        <div class="item-price">S/ \${item.precio.toFixed(2)}</div>
                    </div>
                    <div class="qty-controls">
                        <button class="btn-qty minus" onclick="updateCart('\${item.idservicio}', '\${item.nombre}', \${item.precio}, -1)">
                            <i class="fas fa-minus"></i>
                        </button>
                        <span class="qty-value" id="qty-\${item.idservicio}">\${qty}</span>
                        <button class="btn-qty" onclick="updateCart('\${item.idservicio}', '\${item.nombre}', \${item.precio}, 1)">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                </div>
                `;
            }).join('');
        }

        function updateCart(idservicio, nombre, precio, change) {
            if (!cart[idservicio]) {
                if (change < 0) return; // No se puede bajar de 0
                cart[idservicio] = { nombre, precio, cantidad: 0 };
            }

            const newVal = cart[idservicio].cantidad + change;
            
            if (newVal <= 0) {
                delete cart[idservicio];
                document.getElementById(`qty-\${idservicio}`).textContent = '0';
            } else {
                cart[idservicio].cantidad = newVal;
                document.getElementById(`qty-\${idservicio}`).textContent = newVal;
            }

            updateCartUI();
        }

        function updateCartUI() {
            let total = 0;
            let itemsCount = 0;

            for (let id in cart) {
                total += cart[id].precio * cart[id].cantidad;
                itemsCount += cart[id].cantidad;
            }

            document.getElementById('cartTotal').textContent = `S/ \${total.toFixed(2)}`;
            document.getElementById('cartCount').textContent = `\${itemsCount} item\${itemsCount !== 1 ? 's' : ''}`;

            const cartBar = document.getElementById('cartBar');
            if (itemsCount > 0) {
                cartBar.classList.add('visible');
            } else {
                cartBar.classList.remove('visible');
            }
        }

        async function enviarPedido() {
            const items = Object.keys(cart).map(id => ({
                idservicio: id,
                nombre: cart[id].nombre,
                precio: cart[id].precio,
                cantidad: cart[id].cantidad
            }));

            if (items.length === 0) return;

            const confirm = await Swal.fire({
                title: '¿Confirmar pedido?',
                text: 'Su orden será enviada a la cocina.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#f39c12',
                cancelButtonColor: '#2c3e50',
                confirmButtonText: 'Sí, enviar',
                cancelButtonText: 'Revisar',
                customClass: { popup: 'dark-theme' }
            });

            if (!confirm.isConfirmed) return;

            Swal.fire({
                title: 'Enviando orden...',
                allowOutsideClick: false,
                didOpen: () => Swal.showLoading(),
                customClass: { popup: 'dark-theme' }
            });

            try {
                const response = await fetch('api_pedido.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        idm: idm,
                        id_personal: id_personal,
                        items: items
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    cart = {}; // Limpiar carrito
                    updateCartUI();
                    renderMenu(menuData); // Resetear contadores en UI
                    
                    Swal.fire({
                        icon: 'success',
                        title: '¡Pedido Enviado!',
                        html: `Tu orden <strong>\${data.orden}</strong> ya está en cocina.<br><br>En breve te atenderemos.`,
                        confirmButtonColor: '#27ae60',
                        customClass: { popup: 'dark-theme' }
                    });
                } else {
                    showError(data.message);
                }
            } catch (err) {
                showError('Hubo un problema al enviar el pedido. Intente nuevamente.');
            }
        }

        function showError(msg) {
            Swal.fire({
                icon: 'error',
                title: 'Ups...',
                text: msg,
                confirmButtonColor: '#e74c3c',
                customClass: { popup: 'dark-theme' }
            });
        }

        // --- FUNCIONALIDAD DE ESTADO DE PEDIDO ---
        let statusInterval = null;

        async function verEstadoPedido() {
            Swal.fire({
                title: 'Mi Pedido en Tiempo Real',
                html: `<div id="statusListContainer" class="order-status-list">
                        <div class="loader-container"><div class="spinner"></div><p>Consultando estado...</p></div>
                       </div>`,
                showConfirmButton: true,
                confirmButtonText: 'Cerrar',
                confirmButtonColor: '#2c3e50',
                customClass: { popup: 'dark-theme' },
                didOpen: () => {
                    updateStatusList();
                    // Auto-actualizar cada 10 segundos mientras el modal está abierto
                    statusInterval = setInterval(updateStatusList, 10000);
                },
                willClose: () => {
                    if (statusInterval) clearInterval(statusInterval);
                }
            });
        }

        async function updateStatusList() {
            try {
                const response = await fetch(`api_status.jsp?idm=\${idm}`);
                const data = await response.json();
                const container = document.getElementById('statusListContainer');
                
                if (!container) return;

                if (data.success) {
                    if (data.items.length === 0) {
                        container.innerHTML = '<div style="text-align:center; padding:20px; color:var(--text-muted)"><i class="fas fa-receipt fa-2x mb-2"></i><p>Aún no has realizado pedidos hoy.</p></div>';
                        return;
                    }

                    const labels = ["Recibido", "En Cola", "Preparando", "Listo", "Servido"];
                    let granTotal = 0;
                    
                    const itemsHtml = data.items.map(item => {
                        granTotal += item.total;
                        return `
                        <div class="status-item state-\${item.estado}">
                            <div class="status-header">
                                <span class="status-name">\${item.cantidad}x \${item.nombre}</span>
                                <span class="status-label-text label-\${item.estado}">\${labels[item.estado]}</span>
                            </div>
                            <div class="status-progress-mini">
                                <div class="progress-bar-fill fill-\${item.estado}"></div>
                            </div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 8px;">
                                <span style="font-size: 0.7rem; color: var(--text-muted);">Pedido a las \${item.hora}</span>
                                <span class="item-subtotal">S/ \${item.total.toFixed(2)}</span>
                            </div>
                        </div>
                        `;
                    }).join('');

                    container.innerHTML = `
                        \${itemsHtml}
                        <div class="status-footer">
                            <span class="total-label">Total Consumo</span>
                            <span class="total-amount">S/ \${granTotal.toFixed(2)}</span>
                        </div>
                    `;
                } else {
                    container.innerHTML = `<p style="color:var(--danger)">\${data.message}</p>`;
                }
            } catch (err) {
                const container = document.getElementById('statusListContainer');
                if (container) container.innerHTML = '<p style="color:var(--danger)">Error al conectar con el servidor</p>';
            }
        }
    </script>
</body>
</html>
