<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión</title>
    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon"/>
    <link href="../assets/plugins/fontawesome6.7.2/css/all.css" rel="stylesheet">
    <link href="../assets/plugins/fontsgstatic/css/css2.css" rel="stylesheet">
    <link href="../assets/css/login.css" rel="stylesheet">
</head>
<body>
    <div class="bg-mesh"></div>
    <div class="bg-grid"></div>

    <div class="page-wrapper">
        <div class="login-card">

            <!-- LOGO -->
            <div class="logo-section">
                <div class="logo-icon"><a href="../index.jsp">🔐</a></div>
                <h1 class="card-title">Bienvenido</h1>
                <p class="card-subtitle">Ingresa tus credenciales para continuar</p>
            </div>

            <!-- FORM -->
            <form action="index.jsp" method="POST" id="loginForm" name="loginForm" autocomplete="off" novalidate>

                <div class="form-group">
                    <div class="field-label">
                        <label for="username">Usuario</label>
                    </div>
                    <div class="input-wrapper">
                        <input
                            type="text"
                            id="username"
                            name="username"
                            placeholder="Ingresa tu usuario"
                            required
                            autocomplete="username"
                        />
                    </div>
                </div>

                <div class="form-group">
                    <div class="field-label">
                        <label for="password">Contraseña</label>
                        <span class="password-toggle" onclick="togglePassword()" title="Mostrar / ocultar">
                            <i class="fas fa-eye" id="toggleIcon"></i>
                        </span>
                    </div>
                    <div class="input-wrapper">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Ingresa tu contraseña"
                            required
                            autocomplete="current-password"
                        />
                    </div>
                </div>

                <button type="submit" class="submit-button" id="submitBtn">
                    <span id="btnText">Iniciar Sesión</span>
                </button>

                <% if(request.getAttribute("error") != null) { %>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
            </form>

            <div class="footer-links">
                <a href="#">KARES &copy; 2026</a>
            </div>
        </div>
    </div>
    <script src="../assets/js/login.js"></script>
</body>
</html>