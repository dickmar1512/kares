<%@page contentType="text/html" pageEncoding="UTF-8"%> 
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>..::KARES::..</title>
    <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon"/>
    <link rel="stylesheet" href="assets/css/panel.css" type="text/css" media="all">
</head>
<body>
    <!-- HEADER: fila única — Título | Bienvenido | Cerrar sesión -->
    <header class="header">
        <div class="container">
            <span class="header-brand">PLATINUM KARAOKE</span>

            <span class="header-welcome">
                Bienvenido: Sistema de gestión y administración KARES
            </span>

            <%-- <a href="<%= request.getContextPath() %>/auth/?action=logout" class="logout-link">
                <!-- Icono "salida / log-out" -->
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                     fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
                Cerrar sesión
            </a> --%>
        </div>
    </header>

    <main class="main-content">
        <div class="container">
            <div class="modules-grid">
                <div class="module-card">
                    <a href="setup/login.jsp" class="module-link" style="background:none; border:none; width:100%;cursor:pointer; text-align:center; padding:0;">
                        <h2 class="module-title">Setup</h2>
                        <img src="assets/images/setup.png" alt="Setup" class="module-icon">
                        <p class="module-description">Módulo de configuración del sistema</p>
                    </a>
                </div>

                <div class="module-card">
                    <a href="administrador/login.jsp" class="module-link" style="background:none; border:none; width:100%;cursor:pointer; text-align:center; padding:0;">
                        <h2 class="module-title">Administrador</h2>
                        <img src="assets/images/conta.png" alt="Administrador" class="module-icon">
                        <p class="module-description">Módulo del administrador</p>
                    </a>
                </div>

                <%-- <div class="module-card">
                    <a href="caja/login.jsp" class="module-link" style="background:none; border:none; width:100%;cursor:pointer; text-align:center; padding:0;">
                        <h2 class="module-title">Caja</h2>
                        <img src="assets/images/pagos.png" alt="Caja" class="module-icon">
                        <p class="module-description">Módulo de cobros y pagos</p>
                    </a>
                </div> --%>

                <div class="module-card">
                    <a href="mesa/login.jsp" class="module-link" style="background:none; border:none; width:100%;cursor:pointer; text-align:center; padding:0;">
                        <h2 class="module-title">Mesas</h2>
                        <img src="assets/images/admisi.png" alt="Mesas" class="module-icon">
                        <p class="module-description">Módulo de atención al cliente</p>
                    </a>
                </div>
            </div>
        </div>
    </main>

    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <p>Información del sistema: <a href="mailto:dick_mar@hotmail.com">dick_mar@hotmail.com</a></p>
                <p><strong>DICK MARLON TAMANI ROMAYNA</strong></p>
            </div>
        </div>
    </footer>
    <script type="text/javascript" src="assets/js/panel.js"></script>
</body>
</html>