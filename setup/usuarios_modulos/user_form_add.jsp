<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_area = request.getParameter("f_id_area");
    String s_nom_area = "";
    String s_nom_personal = "";
    String s_login_personal = "";

    try {
        conn = getConexion();
        // Area name
        COMANDO = "SELECT nombre FROM acceso_main WHERE id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_area);
        rset = pstmt.executeQuery();
        if (rset.next()) s_nom_area = rset.getString("nombre");
        cerrar(rset, pstmt, null);

        // User info
        COMANDO = "SELECT CONCAT(apepat,' ',apemat,' ',nombre) as nombre, login FROM datos_personales WHERE id_personal = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_nom_personal = rset.getString("nombre");
            s_login_personal = rset.getString("login");
        }
    } catch(Exception e) {
        System.out.println(e);
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Vincular Usuario</title>
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/css/kares-grid.css">
    <link rel="stylesheet" href="../../assets/css/setup/usuarios_modulos/main.css">
</head>
<body class="hold-transition bg-light">

<div class="module-container">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="card card-modern fade-up">
                <div class="card-header-modern">
                    <h5 class="card-title-modern">
                        <a href="elegir.jsp?f_id_area=<%=s_id_area%>&f_login=<%=s_login_personal%>" class="btn btn-sm btn-outline-primary mr-2"><i class="fas fa-chevron-left"></i></a>
                        Vincular a <%=s_nom_area%>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="text-center mb-4">
                        <div class="icon-circle text-white mx-auto mb-2">
                            <i class="fas fa-user-plus"></i>
                        </div>
                        <h5 class="font-weight-bold mb-0"><%=s_nom_personal%></h5>
                        <p class="text-muted small">Login: <%=s_login_personal%></p>
                    </div>

                    <form id="addForm">
                        <input type="hidden" name="f_id_personal" value="<%=s_id_personal%>">
                        <input type="hidden" name="f_id_area" value="<%=s_id_area%>">

                        <div class="form-group">
                            <label class="font-weight-bold">Punto de Emisión</label>
                            <select name="f_punto" class="form-control" required>
                                <option value="">-- Seleccionar Punto --</option>
                                <%
                                    try {
                                        conn = getConexion();
                                        COMANDO = "SELECT punto, nombre FROM puntos ORDER BY CAST(punto AS UNSIGNED)";
                                        pstmt = conn.prepareStatement(COMANDO);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                %>
                                <option value="<%=rset.getString("punto")%>"><%=rset.getString("punto")%> - <%=rset.getString("nombre")%></option>
                                <%
                                        }
                                    } catch(Exception e) {
                                        System.out.println(e);
                                    } finally {
                                        cerrar(rset, pstmt, conn);
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="font-weight-bold">Restricción de IP <small class="text-muted">(Opcional, '*' para libre)</small></label>
                            <input type="text" name="f_ip" class="form-control" placeholder="Ej: 192.168.1.10 o *" value="*">
                        </div>

                        <div class="alert alert-warning border-0 shadow-sm small py-2 mb-4">
                            <i class="fas fa-info-circle mr-2"></i> Una vez vinculado, podrá configurar los permisos detallados.
                        </div>

                        <div class="text-right">
                            <button type="submit" class="btn btn-success btn-block shadow py-2" id="submitBtn">
                                <i class="fas fa-check-circle mr-2"></i> Confirmar Vinculación
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script src="../../assets/js/setup/usuarios_modulos/user_add.js"></script>
</body>
</html>
