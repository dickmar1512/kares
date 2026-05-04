<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp" %>
<%@ include file= "id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_id_personal = request.getParameter("f_id_personal");
    String s_id_area = request.getParameter("f_id_area");
    String s_ips = "";
    String s_nom_personal = "";
    String s_login_personal = "";

    try {
        conn = getConexion();
        // Area User Config
        COMANDO = "SELECT IFNULL(ip_acceso,' ') ip, punto FROM areas_usuarios WHERE id_personal = ? AND id_area = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_personal);
        pstmt.setString(2, s_id_area);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_ips = rset.getString("ip").trim();
            s_punto = rset.getString("punto");
        }
        cerrar(rset, pstmt, null);

        // User name
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
    <title>Configuración de Usuario</title>
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
                        <a href="usuarios.jsp?f_id_area=<%=s_id_area%>" class="btn btn-sm btn-outline-primary mr-2"><i class="fas fa-chevron-left"></i></a>
                        Configuración de Acceso
                    </h5>
                </div>
                <div class="card-body">
                    <div class="text-center mb-4">
                        <div class="avatar-circle mx-auto mb-2">
                            <%=s_nom_personal.substring(0, 1)%>
                        </div>
                        <h5 class="font-weight-bold mb-0"><%=s_nom_personal%></h5>
                        <p class="text-muted small">Login: <%=s_login_personal%></p>
                    </div>

                    <form id="editForm">
                        <input type="hidden" name="f_id_personal" value="<%=s_id_personal%>">
                        <input type="hidden" name="f_id_area" value="<%=s_id_area%>">
                        <input type="hidden" name="f_ip" id="f_ip" value="<%=s_ips%>">

                        <div class="form-group">
                            <label class="font-weight-bold">Punto de Emisión</label>
                            <select name="f_punto" class="form-control" required>
                                <option value="">-- Seleccionar Punto --</option>
                                <%
                                    try {
                                        conn = getConexion();
                                        COMANDO = "SELECT punto, nombre, nom_suc(sucursal) suc, nom_alm(id_almacen) alm " +
                                                  "FROM puntos WHERE id_almacen IS NOT NULL ORDER BY CAST(punto AS UNSIGNED)";
                                        pstmt = conn.prepareStatement(COMANDO);
                                        rset = pstmt.executeQuery();
                                        while(rset.next()) {
                                            String p = rset.getString("punto");
                                            String sel = p.equals(s_punto) ? "selected" : "";
                                %>
                                <option value="<%=p%>" <%=sel%>><%=p%> - <%=rset.getString("nombre")%> (ALM: <%=rset.getString("alm")%>)</option>
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
                            <label class="font-weight-bold">Restricción de IP <small class="text-muted">(Opcional, dejar vacío para acceso libre o '*' )</small></label>
                            <div class="input-group mb-2">
                                <input type="text" id="ip_input" class="form-control" placeholder="Ej: 192.168.1.10">
                                <div class="input-group-append">
                                    <button class="btn btn-outline-primary" type="button" onclick="addIp()"><i class="fas fa-plus mr-1"></i> Añadir</button>
                                </div>
                            </div>
                            <select id="ip_list" class="form-control" size="4" multiple>
                                <%
                                    if (s_ips != null && !s_ips.trim().isEmpty()) {
                                        String[] ips = s_ips.split(" ");
                                        for (String ip : ips) {
                                            if (!ip.trim().isEmpty()) {
                                %>
                                <option><%=ip%></option>
                                <%
                                            }
                                        }
                                    }
                                %>
                            </select>
                            <button class="btn btn-sm btn-outline-danger mt-2" type="button" onclick="removeIp()"><i class="fas fa-trash-alt mr-1"></i> Eliminar seleccionado</button>
                        </div>

                        <hr>

                        <div class="text-right">
                            <button type="submit" class="btn btn-primary btn-block shadow py-2" id="submitBtn">
                                <i class="fas fa-save mr-2"></i> Guardar Configuración
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
<script src="../../assets/js/setup/usuarios_modulos/user_edit.js"></script>
</body>
</html>
