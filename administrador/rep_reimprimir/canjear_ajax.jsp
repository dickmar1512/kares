<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String s_id_mov_vnt     = request.getParameter("id_mov_vnt");
    String s_tipo_compro    = request.getParameter("tipo_comprobante"); // '41' (Boleta) o '39' (Factura)
    String s_doc_num        = request.getParameter("doc_num"); // DNI o RUC
    String s_direccion      = request.getParameter("direccion");

    if (s_id_mov_vnt == null || s_id_mov_vnt.isEmpty() ||
        s_tipo_compro == null || s_tipo_compro.isEmpty() ||
        s_doc_num == null || s_doc_num.isEmpty()) {
        
        out.print("{\"ok\":false,\"msg\":\"Faltan completar parámetros obligatorios.\"}");
        return;
    }

    if (s_direccion == null) s_direccion = "";

    String s_id_personal = "";
    String s_razon = "";
    String s_ruc = "";
    boolean ok = false;
    String error = "";
    String next_serie = "";
    String next_numero = "";
    String s_new_id_mov_vnt = "";

    try {
        conn = getConexion();
        conn.setAutoCommit(false);

        if (s_tipo_compro.equals("41")) {
            // ── BOLETA ELECTRÓNICA (DNI) ──
            String s_nombre = request.getParameter("nombre");
            String s_apepat = request.getParameter("apepat");
            String s_apemat = request.getParameter("apemat");
            String s_sexo   = request.getParameter("sexo");

            if (s_nombre == null || s_nombre.isEmpty() ||
                s_apepat == null || s_apepat.isEmpty() ||
                s_apemat == null || s_apemat.isEmpty() ||
                s_sexo == null || s_sexo.isEmpty()) {
                throw new Exception("Faltan ingresar datos requeridos para la Boleta (Nombres, Apellidos y Sexo).");
            }

            s_razon = (s_apepat + " " + s_apemat + " " + s_nombre).toUpperCase().trim();
            s_ruc = "";

            // 1. Buscar o registrar cliente Persona Natural (tipdoc = '1')
            String sqlCheck = "SELECT id_personal FROM datos_personales WHERE numdoc = ? AND tipdoc = '1'";
            pstmt = conn.prepareStatement(sqlCheck);
            pstmt.setString(1, s_doc_num);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_id_personal = rset.getString("id_personal");
                cerrar(rset, pstmt, null);

                // Actualizar sus datos
                String sqlUpdatePers = "UPDATE datos_personales SET nombre = upper(?), apepat = upper(?), apemat = upper(?), sexo = ?, direcc = ?, user_upd_dat = ?, IP_UPD = ?, fech_upd_dat = now() WHERE id_personal = ?";
                pstmt = conn.prepareStatement(sqlUpdatePers);
                pstmt.setString(1, s_nombre);
                pstmt.setString(2, s_apepat);
                pstmt.setString(3, s_apemat);
                pstmt.setString(4, s_sexo);
                pstmt.setString(5, s_direccion);
                pstmt.setString(6, id_personal_user);
                pstmt.setString(7, s_ip);
                pstmt.setString(8, s_id_personal);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                cerrar(rset, pstmt, null);

                // Registrar nuevo cliente
                s_id_personal = System.currentTimeMillis() + "";
                String sqlInsertPers = "INSERT INTO datos_personales (id_personal, nombre, apepat, apemat, ver_nombre, ver_apepat, ver_apemat, sexo, tipdoc, numdoc, direcc, estado, fecha_ing, ID_PERSONAL_USER) " +
                                       "VALUES (?, upper(?), upper(?), upper(?), upper(?), upper(?), upper(?), ?, '1', ?, ?, '1', now(), ?)";
                pstmt = conn.prepareStatement(sqlInsertPers);
                pstmt.setString(1, s_id_personal);
                pstmt.setString(2, s_nombre);
                pstmt.setString(3, s_apepat);
                pstmt.setString(4, s_apemat);
                pstmt.setString(5, s_nombre);
                pstmt.setString(6, s_apepat);
                pstmt.setString(7, s_apemat);
                pstmt.setString(8, s_sexo);
                pstmt.setString(9, s_doc_num);
                pstmt.setString(10, s_direccion);
                pstmt.setString(11, id_personal_user);
                pstmt.executeUpdate();
                pstmt.close();
            }

        } else if (s_tipo_compro.equals("39")) {
            // ── FACTURA ELECTRÓNICA (RUC) ──
            String s_razon_social = request.getParameter("razon_social");
            if (s_razon_social == null || s_razon_social.isEmpty()) {
                throw new Exception("La Razón Social es requerida para la Factura Electrónica.");
            }
            if (s_direccion == null || s_direccion.trim().isEmpty()) {
                throw new Exception("La dirección es obligatoria para emitir una Factura Electrónica.");
            }

            s_razon = s_razon_social.toUpperCase().trim();
            s_ruc = s_doc_num;

            // 1. Buscar o registrar cliente Persona Jurídica (tipdoc = 'E')
            String sqlCheck = "SELECT id_personal FROM datos_personales WHERE numdoc = ? AND tipdoc = 'E'";
            pstmt = conn.prepareStatement(sqlCheck);
            pstmt.setString(1, s_doc_num);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                s_id_personal = rset.getString("id_personal");
                cerrar(rset, pstmt, null);

                // Actualizar sus datos
                String sqlUpdatePers = "UPDATE datos_personales SET nombre = upper(?), direcc = ?, user_upd_dat = ?, IP_UPD = ?, fech_upd_dat = now() WHERE id_personal = ?";
                pstmt = conn.prepareStatement(sqlUpdatePers);
                pstmt.setString(1, s_razon_social);
                pstmt.setString(2, s_direccion);
                pstmt.setString(3, id_personal_user);
                pstmt.setString(4, s_ip);
                pstmt.setString(5, s_id_personal);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                cerrar(rset, pstmt, null);

                // Registrar nuevo cliente jurídico
                s_id_personal = System.currentTimeMillis() + "";
                String sqlInsertPers = "INSERT INTO datos_personales (id_personal, nombre, apepat, apemat, ver_nombre, ver_apepat, ver_apemat, sexo, tipdoc, numdoc, direcc, estado, fecha_ing, ID_PERSONAL_USER) " +
                                       "VALUES (?, upper(?), '-', '-', upper(?), '-', '-', '', 'E', ?, ?, '1', now(), ?)";
                pstmt = conn.prepareStatement(sqlInsertPers);
                pstmt.setString(1, s_id_personal);
                pstmt.setString(2, s_razon_social);
                pstmt.setString(3, s_razon_social);
                pstmt.setString(4, s_doc_num);
                pstmt.setString(5, s_direccion);
                pstmt.setString(6, id_personal_user);
                pstmt.executeUpdate();
                pstmt.close();
            }

        } else {
            throw new Exception("Tipo de comprobante no soportado.");
        }

        // 2. Incrementar y obtener número de documento de la serie activa para el punto activo y tipo de comprobante seleccionado
        String sqlInc = "UPDATE puntos_doc SET numero = CAST(numero AS UNSIGNED) + 1 WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        pstmt = conn.prepareStatement(sqlInc);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_compro);
        int rowsInc = pstmt.executeUpdate();
        pstmt.close();

        if (rowsInc == 0) {
            String nomDoc = s_tipo_compro.equals("39") ? "Factura Electrónica" : "Boleta Electrónica";
            throw new Exception("No se encontró una correlativa activa para " + nomDoc + " en este punto de venta (" + s_punto + ").");
        }

        String s_id_docimp = "";
        String sqlGetDoc = "SELECT serie, numero, id_docimp FROM puntos_doc WHERE punto = ? AND tipo_doc = ? AND estado = '1'";
        pstmt = conn.prepareStatement(sqlGetDoc);
        pstmt.setString(1, s_punto);
        pstmt.setString(2, s_tipo_compro);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            next_serie = rset.getString("serie");
            next_numero = rset.getString("numero");
            s_id_docimp = rset.getString("id_docimp");
        } else {
            throw new Exception("Error al recuperar la serie y número correlativo.");
        }
        cerrar(rset, pstmt, null);

        // 3. Obtener los campos del registro de la Nota de Venta original (34)
        String s_id_cont = "";
        String s_id_sucursal = "";
        String s_modo = "";
        double d_valor_venta = 0;
        double d_base_imp = 0;
        double d_total = 0;
        double d_descuento = 0;
        double d_descuento_esp = 0;
        double d_cobertura = 0;
        double d_igv = 0;
        double d_copago = 0;
        String s_id_mesa = "";
        String nv_serie = "";
        String nv_numdoc = "";
        String s_tipo_pac = "";
        String s_id_plan = "";
        String s_id_tipo_ate = "";
        String s_id_paquete = "";
        String s_id_ctacte = "";
        String s_voucher = "";

        String sqlGetNV = "SELECT id_cont, id_sucursal, modo, valor_venta, base_imp, total, descuento, descuento_esp, cobertura, igv, copago, id_mesa, serie, numdoc, " +
                          "tipo_pac, id_plan, id_tipo_ate, id_paquete, id_ctacte, voucher " +
                          "FROM vent_registro WHERE id_mov_vnt = ? AND tipo_doc = '34'";
        pstmt = conn.prepareStatement(sqlGetNV);
        pstmt.setString(1, s_id_mov_vnt);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            s_id_cont = rset.getString("id_cont");
            s_id_sucursal = rset.getString("id_sucursal");
            s_modo = rset.getString("modo");
            d_valor_venta = rset.getDouble("valor_venta");
            d_base_imp = rset.getDouble("base_imp");
            d_total = rset.getDouble("total");
            d_descuento = rset.getDouble("descuento");
            d_descuento_esp = rset.getDouble("descuento_esp");
            d_cobertura = rset.getDouble("cobertura");
            d_igv = rset.getDouble("igv");
            d_copago = rset.getDouble("copago");
            s_id_mesa = rset.getString("id_mesa");
            nv_serie = rset.getString("serie");
            nv_numdoc = rset.getString("numdoc");
            s_tipo_pac = rset.getString("tipo_pac");
            s_id_plan = rset.getString("id_plan");
            s_id_tipo_ate = rset.getString("id_tipo_ate");
            s_id_paquete = rset.getString("id_paquete");
            s_id_ctacte = rset.getString("id_ctacte");
            s_voucher = rset.getString("voucher");
        } else {
            throw new Exception("No se encontró la Nota de Venta original o ya no está disponible.");
        }
        cerrar(rset, pstmt, null);

        if (s_id_cont == null || s_id_cont.isEmpty()) {
            s_id_cont = new java.text.SimpleDateFormat("yyyy").format(new java.util.Date());
        }
        if (s_tipo_pac == null || s_tipo_pac.isEmpty()) s_tipo_pac = "4"; // '4' Particular por defecto
        if (s_id_plan == null) s_id_plan = "";
        if (s_id_tipo_ate == null) s_id_tipo_ate = "";
        if (s_id_paquete == null) s_id_paquete = "";
        if (s_id_ctacte == null) s_id_ctacte = "";
        if (s_voucher == null) s_voucher = "";

        // Generar un nuevo id_mov_vnt único para el Comprobante Electrónico (Boleta/Factura)
        s_new_id_mov_vnt = System.currentTimeMillis() + "";

        // 4. Insertar el nuevo Comprobante Electrónico (Boleta o Factura) en vent_registro
        String sqlInsertReg = "INSERT INTO vent_registro (id_cont, id_mov_vnt, id_sucursal, id_personal, punto, modo, fecha, " +
                              "estado, tipo_ope, tipo_doc, serie, numdoc, id_docimp, valor_venta, base_imp, total, descuento, " +
                              "descuento_esp, cobertura, igv, copago, id_personal_user, ip, id_mesa, ruc, razon, id_vnt_ref, ref_doc, ref_obs, " +
                              "tipo_pac, id_plan, id_tipo_ate, id_paquete, id_ctacte, voucher) " +
                              "VALUES (?, ?, ?, ?, ?, ?, SYSDATE(), 'V', 'V', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'CANJE', " +
                              "?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlInsertReg);
        pstmt.setString(1, s_id_cont);
        pstmt.setString(2, s_new_id_mov_vnt);
        pstmt.setString(3, s_id_sucursal);
        pstmt.setString(4, s_id_personal);
        pstmt.setString(5, s_punto);
        pstmt.setString(6, s_modo);
        pstmt.setString(7, s_tipo_compro);
        pstmt.setString(8, next_serie);
        pstmt.setString(9, next_numero);
        pstmt.setString(10, s_id_docimp);
        pstmt.setDouble(11, d_valor_venta);
        pstmt.setDouble(12, d_base_imp);
        pstmt.setDouble(13, d_total);
        pstmt.setDouble(14, d_descuento);
        pstmt.setDouble(15, d_descuento_esp);
        pstmt.setDouble(16, d_cobertura);
        pstmt.setDouble(17, d_igv);
        pstmt.setDouble(18, d_copago);
        pstmt.setString(19, id_personal_user);
        pstmt.setString(20, s_ip);
        pstmt.setString(21, s_id_mesa);
        pstmt.setString(22, s_ruc);
        pstmt.setString(23, s_razon);
        pstmt.setString(24, s_id_mov_vnt); // id_vnt_ref apunta al id_mov_vnt de la Nota de Venta de origen
        
        String nvDocFormatted = "";
        try {
            nvDocFormatted = nv_serie + "-" + String.format("%07d", Integer.parseInt(nv_numdoc.trim()));
        } catch(Exception e) {
            nvDocFormatted = nv_serie + "-" + nv_numdoc;
        }
        pstmt.setString(25, nvDocFormatted); // ref_doc de la Boleta/Factura apunta al número de Nota de Venta
        
        // Parámetros adicionales para evitar errores de default value
        pstmt.setString(26, s_tipo_pac);
        pstmt.setString(27, s_id_plan);
        pstmt.setString(28, s_id_tipo_ate);
        pstmt.setString(29, s_id_paquete);
        pstmt.setString(30, s_id_ctacte);
        pstmt.setString(31, s_voucher);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. Clonar las filas de detalle en vent_regdet asociándolas al nuevo id_mov_vnt del Comprobante
        String sqlInsertDet = "INSERT INTO vent_regdet (id_venta, id_mov_vnt, id_movart, id_articulo, glosa, cantidad, valor_af, valor_inaf, valor_venta, descuento, descuento_esp, cobertura, base_imp, igv, total, copago, copago_fact, tipo_copago, copago_orig, fecha, id_medico_ser, id_cita, estado, estado_atencion, id_sol_det, pago_hono, coberturado, id_personal_user, user_upd, id_cuenta_alm, id_cuenta_cv, impo_liq, centro_costo, id_mov_hon, agregar_igv, id_paquete, modo_det, id_presupuesto, cambia_precio, id_autoriza_desc, id_medico_rec, consultorio, ret_hono, id_user_anul, fecanu, prioridad, muestra, equipo, dscto_pac, id_examen, tipo_serv, motivo_modif, respuesta, id_personal_temp, id_plan_temp, id_tipo_ate_temp, id_serv_fij_temp, motivo_anul, id_personal_dig, fecha_desc, det_transf, id_liq, id_pendiente, id_vnt_pendiente, nivel2, nivel1, nivel_impresion, precio_unitario, porc_igv, id_pol_copago, id_pol_cob, id_almart, porc_dsc, porc_cob, tipo_precio, porc_utilidad, utilidad, cu, x, id_personal_cambio, motivo_cambio, id_medico_ant, orden, traspaso, user_traspaso, fecha_traspaso, cortesia, devuelto_hosp, sf, p_cirugia, importe_asistencia, fecha_upd, fecha_activ, user_activ, motivo_activ, porc_polcob, porc_param, id_param, inafecto, vv2, sist_recep, det_transf2, copago_con_igv, activa_serv_user, activa_serv_fecha, id_movart_relacion, id_mov_det, gen_labo, hora_examen, examen_pend, receta, oculto, ip_anul, chkmedso, chk_id_user, copago_corregido) " +
                              "SELECT id_venta, ?, substring(md5(concat(?, id_movart)), 1, 20), id_articulo, glosa, cantidad, valor_af, valor_inaf, valor_venta, descuento, descuento_esp, cobertura, base_imp, igv, total, copago, copago_fact, tipo_copago, copago_orig, now(), id_medico_ser, id_cita, estado, estado_atencion, id_sol_det, pago_hono, coberturado, ?, user_upd, id_cuenta_alm, id_cuenta_cv, impo_liq, centro_costo, id_mov_hon, agregar_igv, id_paquete, modo_det, id_presupuesto, cambia_precio, id_autoriza_desc, id_medico_rec, consultorio, ret_hono, id_user_anul, fecanu, prioridad, muestra, equipo, dscto_pac, id_examen, tipo_serv, motivo_modif, respuesta, id_personal_temp, id_plan_temp, id_tipo_ate_temp, id_serv_fij_temp, motivo_anul, id_personal_dig, fecha_desc, det_transf, id_liq, id_pendiente, id_vnt_pendiente, nivel2, nivel1, nivel_impresion, precio_unitario, porc_igv, id_pol_copago, id_pol_cob, id_almart, porc_dsc, porc_cob, tipo_precio, porc_utilidad, utilidad, cu, x, id_personal_cambio, motivo_cambio, id_medico_ant, orden, traspaso, user_traspaso, fecha_traspaso, cortesia, devuelto_hosp, sf, p_cirugia, importe_asistencia, fecha_upd, fecha_activ, user_activ, motivo_activ, porc_polcob, porc_param, id_param, inafecto, vv2, sist_recep, det_transf2, copago_con_igv, activa_serv_user, activa_serv_fecha, id_movart, id_mov_det, gen_labo, hora_examen, examen_pend, receta, oculto, ip_anul, chkmedso, chk_id_user, copago_corregido " +
                              "FROM vent_regdet WHERE id_mov_vnt = ?";
        pstmt = conn.prepareStatement(sqlInsertDet);
        pstmt.setString(1, s_new_id_mov_vnt);
        pstmt.setString(2, s_new_id_mov_vnt);
        pstmt.setString(3, id_personal_user);
        pstmt.setString(4, s_id_mov_vnt);
        pstmt.executeUpdate();
        pstmt.close();

        // 6. Actualizar la Nota de Venta original en vent_registro con la referencia de canje
        String sqlUpdateReg = "UPDATE vent_registro SET id_vnt_ref = ?, ref_doc = ?, ref_obs = 'CANJEADO', ref_motivo = ? WHERE id_mov_vnt = ? AND tipo_doc = '34'";
        pstmt = conn.prepareStatement(sqlUpdateReg);
        pstmt.setString(1, s_new_id_mov_vnt); // id_vnt_ref apunta al nuevo Comprobante
        
        String comproDocFormatted = "";
        try {
            comproDocFormatted = next_serie + "-" + String.format("%07d", Integer.parseInt(next_numero.trim()));
        } catch(Exception e) {
            comproDocFormatted = next_serie + "-" + next_numero;
        }
        pstmt.setString(2, comproDocFormatted); // ref_doc apunta al número de Boleta/Factura generada
        pstmt.setString(3, s_tipo_compro); // Guardamos si es Boleta (41) o Factura (39) en ref_motivo para saber el tipo de destino
        pstmt.setString(4, s_id_mov_vnt);
        int rowsUpdated = pstmt.executeUpdate();
        pstmt.close();

        if (rowsUpdated == 0) {
            throw new Exception("No se pudo actualizar la referencia en la Nota de Venta original.");
        }

        // ── GENERACIÓN DE ARCHIVOS PLANOS PARA SFS FACTURADOR SUNAT ──
        try {
            // 1. Obtener total en letras usando la función almacenada numtxt
            String total_letras = "";
            String sqlLetras = "SELECT numtxt(?) AS tota_letra FROM DUAL";
            PreparedStatement pstmtLetras = conn.prepareStatement(sqlLetras);
            pstmtLetras.setString(1, String.valueOf(d_total));
            ResultSet rsetLetras = pstmtLetras.executeQuery();
            if (rsetLetras.next()) {
                total_letras = "Son: " + rsetLetras.getString("tota_letra") + " Soles.";
            }
            rsetLetras.close();
            pstmtLetras.close();

            // 2. Definir parámetros de fecha, hora y nombres de archivos
            String p_fecha = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            String p_hora = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date());
            
            String sfsDocType = s_tipo_compro.equals("39") ? "01" : "03"; // 01 Factura, 03 Boleta
            String docSerie = next_serie.trim();
            String docNumero = String.format("%07d", Integer.parseInt(next_numero.trim()));
            String filenamePrefix = "C:\\SFS_v1.3.4.4\\sunat_archivos\\sfs\\DATA\\20541177281-" + sfsDocType + "-" + docSerie + "-" + docNumero;

            java.io.File dir = new java.io.File("C:\\SFS_v1.3.4.4\\sunat_archivos\\sfs\\DATA\\");
            dir.mkdirs();

            String strTotal = String.format(java.util.Locale.US, "%.2f", d_total);
            String docIdentidadTipo = s_tipo_compro.equals("39") ? "6" : "1"; // 6 RUC, 1 DNI

            // 3. Generar archivo .CAB
            java.io.File fCab = new java.io.File(filenamePrefix + ".cab");
            java.io.PrintWriter wrCab = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fCab)));
            wrCab.print("0101|" + p_fecha + "|" + p_hora + "|-|0000|" + docIdentidadTipo + "|" + s_doc_num + "|" + s_razon + "|PEN|0|" + strTotal + "|" + strTotal + "|0|0|0|" + strTotal + "|2.1|2.0|");
            wrCab.close();

            // 4. Generar archivo .PAG
            java.io.File fPag = new java.io.File(filenamePrefix + ".pag");
            java.io.PrintWriter wrPag = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fPag)));
            wrPag.print("CONTADO|0|-|");
            wrPag.close();

            // 5. Generar archivo .ACA
            java.io.File fAca = new java.io.File(filenamePrefix + ".aca");
            java.io.PrintWriter wrAca = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fAca)));
            wrAca.print("-|-|-|-|-|PE|160101|" + (s_direccion.trim().isEmpty() ? "-" : s_direccion.trim()) + "|-|-|-|");
            wrAca.close();

            // 6. Generar archivo .LEY
            java.io.File fLey = new java.io.File(filenamePrefix + ".ley");
            java.io.PrintWriter wrLey = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fLey)));
            wrLey.print("1000|" + total_letras + "|");
            wrLey.close();

            // 7. Generar archivo .TRI
            java.io.File fTri = new java.io.File(filenamePrefix + ".tri");
            java.io.PrintWriter wrTri = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fTri)));
            wrTri.print("9997|EXO|VAT|" + strTotal + "|0|");
            wrTri.close();

            // 8. Generar archivo .DET
            java.io.File fDet = new java.io.File(filenamePrefix + ".det");
            java.io.PrintWriter wrDet = new java.io.PrintWriter(new java.io.BufferedWriter(new java.io.FileWriter(fDet)));

            String sqlGetDetItems = "SELECT cantidad, glosa, " +
                                    "ROUND(valor_venta * ((100 + porc_igv) / 100), 2) AS vv, " +
                                    "ROUND((valor_venta * ((100 + porc_igv) / 100)) / cantidad, 2) AS vu, " +
                                    "ROUND(base_imp * ((100 + porc_igv) / 100), 2) AS bi, " +
                                    "ROUND(IFNULL(descuento, 0) * ((100 + porc_igv) / 100), 2) AS dsc, " +
                                    "ROUND(IFNULL(cobertura, 0) * ((100 + porc_igv) / 100), 2) AS cob, " +
                                    "ROUND(IFNULL(copago, 0), 2) AS cop, " +
                                    "ROUND(total, 2) AS tota " +
                                    "FROM vent_regdet WHERE id_mov_vnt = ? ORDER BY orden";
            PreparedStatement pstmtItems = conn.prepareStatement(sqlGetDetItems);
            pstmtItems.setString(1, s_new_id_mov_vnt);
            ResultSet rsetItems = pstmtItems.executeQuery();
            while (rsetItems.next()) {
                String itemCant = rsetItems.getString("cantidad");
                String itemGlosa = rsetItems.getString("glosa");
                String itemVu = rsetItems.getString("vu");
                String itemTota = rsetItems.getString("tota");
                
                wrDet.print("NIU|" + itemCant + "|0|-|" + itemGlosa + "|" + itemVu + "|0|9997|0|" + itemTota + "|EXO|VAT|20|0|-||0||-|||-||||||-||||||" + itemVu + "|" + itemTota + "|0|\r\n");
            }
            rsetItems.close();
            pstmtItems.close();
            wrDet.close();

        } catch (Exception eSfs) {
            eSfs.printStackTrace();
        }

        conn.commit();
        ok = true;
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(Exception ex) {}
        }
        ok = false;
        error = e.getMessage() != null ? e.getMessage() : "Error desconocido al procesar el canje.";
    } finally {
        cerrar(rset, pstmt, conn);
    }

    String docNombre = s_tipo_compro.equals("39") ? "Factura" : "Boleta";
    if (ok) {
        out.print("{\"ok\":true,\"msg\":\"" + docNombre + " Electrónica generada con éxito.\",\"serie\":\"" + next_serie + "\",\"numero\":\"" + next_numero + "\",\"id_mov_vnt\":\"" + s_new_id_mov_vnt + "\"}");
    } else {
        out.print("{\"ok\":false,\"msg\":\"" + error.replace("\"", "\\\"") + "\"}");
    }
%>
