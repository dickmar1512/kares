<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String tipdoc    = request.getParameter("tipdoc");
    String numdoc    = request.getParameter("numdoc");
    String nombre    = request.getParameter("nombre");
    String apepat    = request.getParameter("apepat");
    String apemat    = request.getParameter("apemat");
    String sexo      = request.getParameter("sexo");
    String direccion = request.getParameter("direccion");
    String telefono  = request.getParameter("telefono");
    String correo    = request.getParameter("correo");

    JSONObject jsonRes = new JSONObject();

    if (tipdoc == null || numdoc == null || nombre == null || direccion == null ||
        tipdoc.isEmpty() || numdoc.isEmpty() || nombre.isEmpty()) {
        jsonRes.put("success", false);
        jsonRes.put("message", "Faltan completar campos obligatorios.");
        out.print(jsonRes.toString());
        return;
    }

    if (direccion.trim().isEmpty()) {
        jsonRes.put("success", false);
        jsonRes.put("message", "La dirección es obligatoria.");
        out.print(jsonRes.toString());
        return;
    }

    if (telefono == null) telefono = "";
    if (correo == null) correo = "";

    if (tipdoc.equals("1")) {
        // DNI
        if (numdoc.length() != 8) {
            jsonRes.put("success", false);
            jsonRes.put("message", "El DNI debe tener 8 dígitos.");
            out.print(jsonRes.toString());
            return;
        }
        if (apepat == null || apepat.isEmpty() || apemat == null || apemat.isEmpty()) {
            jsonRes.put("success", false);
            jsonRes.put("message", "Los apellidos paterno y materno son obligatorios para DNI.");
            out.print(jsonRes.toString());
            return;
        }
        if (sexo == null || sexo.isEmpty()) {
            jsonRes.put("success", false);
            jsonRes.put("message", "El sexo es obligatorio para DNI.");
            out.print(jsonRes.toString());
            return;
        }
    } else if (tipdoc.equals("E")) {
        // RUC
        if (numdoc.length() != 11) {
            jsonRes.put("success", false);
            jsonRes.put("message", "El RUC debe tener 11 dígitos.");
            out.print(jsonRes.toString());
            return;
        }
        apepat = "-";
        apemat = "-";
        sexo = "";
    } else {
        jsonRes.put("success", false);
        jsonRes.put("message", "Tipo de documento no soportado.");
        out.print(jsonRes.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rset = null;

    try {
        conn = getConexion();
        
        // Verificar si ya existe un cliente con este documento y tipo
        String sqlCheck = "SELECT id_personal, CONCAT(UPPER(apepat),' ',UPPER(apemat),' ',UPPER(nombre)) AS nombre_completo FROM datos_personales WHERE numdoc = ? AND tipdoc = ?";
        pstmt = conn.prepareStatement(sqlCheck);
        pstmt.setString(1, numdoc);
        pstmt.setString(2, tipdoc);
        rset = pstmt.executeQuery();
        if (rset.next()) {
            jsonRes.put("success", false);
            jsonRes.put("message", "Ya existe un cliente registrado con este documento (" + rset.getString("nombre_completo") + ").");
            out.print(jsonRes.toString());
            return;
        }
        rset.close();
        pstmt.close();

        // Generar nuevo id_personal único
        String s_id_personal = System.currentTimeMillis() + "";

        // Insertar cliente
        String sqlInsert = "INSERT INTO datos_personales (id_personal, nombre, apepat, apemat, ver_nombre, ver_apepat, ver_apemat, sexo, tipdoc, numdoc, direcc, fono1, email, estado, fecha_ing, ID_PERSONAL_USER) " +
                           "VALUES (?, upper(?), upper(?), upper(?), upper(?), upper(?), upper(?), ?, ?, ?, ?, ?, ?, '1', now(), ?)";
        pstmt = conn.prepareStatement(sqlInsert);
        pstmt.setString(1, s_id_personal);
        pstmt.setString(2, nombre);
        pstmt.setString(3, apepat);
        pstmt.setString(4, apemat);
        pstmt.setString(5, nombre);
        pstmt.setString(6, apepat);
        pstmt.setString(7, apemat);
        pstmt.setString(8, sexo);
        pstmt.setString(9, tipdoc);
        pstmt.setString(10, numdoc);
        pstmt.setString(11, direccion);
        pstmt.setString(12, telefono);
        pstmt.setString(13, correo);
        pstmt.setString(14, id_personal_user);

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            String labelNombre = tipdoc.equals("E") ? nombre.toUpperCase() : (apepat + " " + apemat + " " + nombre).toUpperCase();
            jsonRes.put("success", true);
            jsonRes.put("id_personal", s_id_personal);
            jsonRes.put("nombre", labelNombre);
            jsonRes.put("documento", numdoc);
            jsonRes.put("message", "Cliente registrado exitosamente.");
        } else {
            jsonRes.put("success", false);
            jsonRes.put("message", "No se pudo registrar el cliente.");
        }
        out.print(jsonRes.toString());

    } catch (Exception e) {
        e.printStackTrace();
        jsonRes.put("success", false);
        jsonRes.put("message", "Error en el servidor: " + e.getMessage());
        out.print(jsonRes.toString());
    } finally {
        cerrar(rset, pstmt, conn);
    }
%>
