<%-- <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> --%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp"%> 
<%
    // Par\u00e1metros de entrada
    String s_id_mov_vnt = request.getParameter("f_id_mov_vnt");
    String s_id_personal = request.getParameter("f_id_personal");
    String s_idm = request.getParameter("f_idm"); if(s_idm==null) s_idm="";
    String s_tipo_doc = request.getParameter("f_tipo_doc"); if (s_tipo_doc == null) s_tipo_doc = "35";
    String s_tipo_ing = request.getParameter("f_tipo_ing"); if (s_tipo_ing == null) s_tipo_ing = "1";
    String s_id_empresa = request.getParameter("f_id_empresa"); if (s_id_empresa == null) s_id_empresa = "";
    
    // Datos recuperados de DB
    String s_serie = "";
    String s_numdoc = "";
    String s_id_docimp = "";
    
    boolean success = false;
    String errorMsg = "";

    try {
        conn = getConexion();
        conn.setAutoCommit(false); // Transaccional

        // 1. Incrementar y obtener n\u00famero de documento
        COMANDO = "UPDATE puntos_doc SET numero = CAST(numero AS UNSIGNED) + 1 " +
                 "WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        pstmt.executeUpdate();
        pstmt.close();

        COMANDO = "SELECT serie, numero, id_docimp FROM puntos_doc " +
                 "WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_doc);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_serie = rset.getString("serie");
            s_numdoc = rset.getString("numero");
            s_id_docimp = rset.getString("id_docimp");
        }
        cerrar(rset, pstmt, null);

        // 2. Verificar y/o crear registro de venta
        boolean exists = false;
        COMANDO = "SELECT id_mov_vnt FROM vent_registro WHERE id_mov_vnt = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_mov_vnt);
        rset = pstmt.executeQuery();
        if (rset.next()) exists = true;
        cerrar(rset, pstmt, null);

        if (!exists) {
            COMANDO = "INSERT INTO vent_registro (id_cont, id_mov_vnt, id_sucursal, id_personal, punto, modo, fecha, " +
                     "estado, tipo_ope, tipo_doc, serie, numdoc, id_docimp, valor_venta, base_imp, total, descuento, descuento_esp, cobertura, igv, copago, id_personal_user, ip, " +
                     "id_ctacte, voucher, tipo_pac, id_plan, id_tipo_ate, id_paquete, ruc, razon) " +
                     "SELECT IFNULL(?, DATE_FORMAT(SYSDATE(),'%Y')), ?, ?, ?, ?, '1', SYSDATE(), " +
                     "'V', ?, ?, ?, ?, ?, " +
                     "IFNULL(SUM(IFNULL(valor_venta,0)),0), IFNULL(SUM(IFNULL(base_imp,0)),0), " +
                     "IFNULL(SUM(IFNULL(base_imp,0)) + SUM(IFNULL(igv,0)),0), " +
                     "IFNULL(SUM(IFNULL(descuento,0)),0), IFNULL(SUM(IFNULL(descuento_esp,0)),0), " +
                     "IFNULL(SUM(IFNULL(cobertura,0)),0), IFNULL(SUM(IFNULL(igv,0)),0), " +
                     "IFNULL(SUM(IFNULL(copago,0)),0), ?, ?, " +
                     "'', '', '4', '', '', '', '', '' " +
                     "FROM vent_regdet WHERE id_mov_vnt = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id_cont_user);
            pstmt.setString(2, s_id_mov_vnt);
            pstmt.setString(3, sucursal_user);
            pstmt.setString(4, s_id_personal);
            pstmt.setString(5, s_punto);
            pstmt.setString(6, s_tipo_ing);
            pstmt.setString(7, s_tipo_doc);
            pstmt.setString(8, s_serie);
            pstmt.setString(9, s_numdoc);
            pstmt.setString(10, s_id_docimp);
            pstmt.setString(11, id_personal_user);
            pstmt.setString(12, s_ip);
            pstmt.setString(13, s_id_mov_vnt);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 3. Obtener RUC y Razón si hay f_id_empresa
        String finalRuc = "";
        String finalRazon = "";
        if (!s_id_empresa.isEmpty()) {
            COMANDO = "SELECT ruc, CONCAT(IFNULL(apepat,''),' ',IFNULL(apemat,''),' ',IFNULL(nombre,'')) as razon " +
                     "FROM datos_personales WHERE id_personal = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_empresa);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                finalRuc = rset.getString("ruc");
                finalRazon = rset.getString("razon").trim();
            } else {
                cerrar(rset, pstmt, null);
                COMANDO = "SELECT ruc, razon FROM datos_companias WHERE id_compania = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_id_empresa);
                rset = pstmt.executeQuery();
                if (rset.next()) {
                    finalRuc = rset.getString("ruc");
                    finalRazon = rset.getString("razon").trim();
                } else {
                    cerrar(rset, pstmt, null);
                    COMANDO = "SELECT ruc, razon FROM datos_empresas WHERE id_empresa = ?";
                    pstmt = conn.prepareStatement(COMANDO);
                    pstmt.setString(1, s_id_empresa);
                    rset = pstmt.executeQuery();
                    if (rset.next()) {
                        finalRuc = rset.getString("ruc");
                        finalRazon = rset.getString("razon").trim();
                    } else {
                        cerrar(rset, pstmt, null);
                        COMANDO = "SELECT ruc, razon FROM datos_proveedor WHERE id_proveedor = ?";
                        pstmt = conn.prepareStatement(COMANDO);
                        pstmt.setString(1, s_id_empresa);
                        rset = pstmt.executeQuery();
                        if (rset.next()) {
                            finalRuc = rset.getString("ruc");
                            finalRazon = rset.getString("razon").trim();
                        }
                    }
                }
            }
            cerrar(rset, pstmt, null);
        }

        // 4. Actualizar registro de venta con todos los datos finales
        COMANDO = "UPDATE vent_registro SET " +
                 "estado = 'V', punto = ?, fecha = SYSDATE(), id_sucursal = ?, " +
                 "serie = ?, tipo_doc = ?, numdoc = ?, tipo_ope = ?, id_docimp = ?, " +
                 "id_personal_user = ?, id_mesa = ?";
                 
        if (!s_id_empresa.isEmpty()) {
            COMANDO += ", id_personal = ?, ruc = ?, razon = ? ";
        }
        COMANDO += "WHERE id_mov_vnt = ?";
        
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, sucursal_user);
        pstmt.setString(3, s_serie);
        pstmt.setString(4, s_tipo_doc);
        pstmt.setString(5, s_numdoc);
        pstmt.setString(6, s_tipo_ing);
        pstmt.setString(7, s_id_docimp);
        pstmt.setString(8, id_personal_user);
        pstmt.setString(9, s_idm);
        if (!s_id_empresa.isEmpty()) {
            pstmt.setString(10, s_id_empresa);
            pstmt.setString(11, finalRuc);
            pstmt.setString(12, finalRazon);
            pstmt.setString(13, s_id_mov_vnt);
        } else {
            pstmt.setString(10, s_id_mov_vnt);
        }
        pstmt.executeUpdate();
        pstmt.close();


        // 3. Actualizar detalle de venta
        COMANDO = "UPDATE vent_regdet SET estado = 'V', estado_atencion = '2' WHERE id_mov_vnt = ?";
        pstmt = conn.prepareStatement(COMANDO);
        pstmt.setString(1, s_id_mov_vnt);
        pstmt.executeUpdate();
        pstmt.close();

        // 4. Verificar si la mesa debe liberarse (estado = '0')
        // Contar items SIN atender de OTROS registros de la misma mesa que aún NO estén pagados
        if (!s_idm.isEmpty()) {
            COMANDO = "SELECT COUNT(*) as cant " +
                     "FROM vent_regdet a " +
                     "INNER JOIN vent_registro b ON a.id_mov_vnt = b.id_mov_vnt " +
                     "WHERE b.id_mesa = ? " +
                     "AND b.estado = 'V' " +
                     "AND a.estado = 'V' " +
                     "AND a.id_movart_relacion IS NULL "+ 
                     "AND a.estado_atencion IN ('0','1','2','3') " +
                     "AND b.tipo_doc = '11' ";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_idm);
            rset = pstmt.executeQuery();
            int pend = 0;
            if (rset.next()) pend = rset.getInt("cant");
            cerrar(rset, pstmt, null);

            if (pend == 0) {
                COMANDO = "UPDATE mesas SET estado = '0' WHERE idm = ?";
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_idm);
                int updatedRows = pstmt.executeUpdate();
                pstmt.close();
            }
        }

        conn.commit();
        success = true;
    } catch (Exception e) {
        if (conn != null) conn.rollback();
        success = false;
        errorMsg = e.getMessage();
    } finally {
        cerrar(rset, pstmt, null); // Solo cerrar rset y pstmt
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Finalizando Venta</title>
    <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
    <link rel="stylesheet" href="../../assets/plugins/adminlte3/css/adminlte.min.css">
</head>
<body class="hold-transition bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8 text-center">
            <% if (success) { %>
                <div id="loading-area">
                    <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                        <span class="sr-only">Procesando...</span>
                    </div>
                    <h4 class="mt-3">Generando comprobante...</h4>
                </div>
                
                <div id="report-area" style="display:none;">
                    <%
                        if (s_tipo_doc.equals("34")) { %> <%@ include file="show_nota_venta.jsp" %> <% }
                        else if (s_tipo_doc.equals("39")) { %> <%@ include file="show_factura_electronica.jsp" %> <% }
                        else if (s_tipo_doc.equals("41")) { %> <%@ include file="show_boleta_electronica.jsp" %> <% }
                        else { %> <%@ include file="show_boleta_electronica.jsp" %> <% } // Default
                    %>
                </div>
            <% } else { %>
                <div class="alert alert-danger shadow-sm">
                    <i class="fas fa-exclamation-triangle fa-2x mb-3"></i>
                    <h4>Error al procesar la venta</h4>
                    <p><%=errorMsg%></p>
                    <a href="showVenta.jsp?f_id_mov_vnt=<%=s_id_mov_vnt%>&f_idm=<%=s_idm%>&f_id_personal=<%=s_id_personal%>" class="btn btn-outline-danger mt-3">Regresar</a>
                </div>
            <% } %>
        </div>
    </div>
</div>

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
<% if (success) { %>
    Swal.fire({
        icon: 'success',
        title: '\u00a1Venta Realizada!',
        text: 'El comprobante <%=s_serie%>-<%=s_numdoc%> ha sido generado.',
        timer: 2000,
        showConfirmButton: false,
        didClose: () => {
            $('#loading-area').hide();
            $('#report-area').fadeIn();
        }
    });
<% } %>
</script>
<% cerrar(conn); %>
</body>
</html>
