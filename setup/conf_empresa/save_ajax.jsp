<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();
    
    // Recuperar parámetros
    String id_empresa = request.getParameter("id_empresa");
    String ruc = request.getParameter("ruc");
    String razon_social = request.getParameter("razon_social");
    String nombre_comercial = request.getParameter("nombre_comercial");
    String ubigeo = request.getParameter("ubigeo");
    String codigo_local = request.getParameter("codigo_local");
    String direccion = request.getParameter("direccion");
    String departamento = request.getParameter("departamento");
    String provincia = request.getParameter("provincia");
    String distrito = request.getParameter("distrito");
    String email = request.getParameter("email");
    String telefono = request.getParameter("telefono");
    String usuario_sol = request.getParameter("usuario_sol");
    String clave_sol = request.getParameter("clave_sol");
    String cert_ruta = request.getParameter("cert_ruta");
    String cert_clave = request.getParameter("cert_clave");
    String logo = request.getParameter("logo");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rset = null;
    
    try {
        conn = getConexion();
        conn.setAutoCommit(false); // Transacción

        boolean exists = false;
        if (id_empresa != null && !id_empresa.isEmpty()) {
            COMANDO = "SELECT 1 FROM datos_empresas WHERE id_empresa = ?";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, id_empresa);
            rset = pstmt.executeQuery();
            if (rset.next()) exists = true;
            pstmt.close();
        }

        if (!exists) {
            // Si no existe por ID, verificamos por RUC en datos_personales
            COMANDO = "SELECT id_personal FROM datos_personales WHERE ruc = ? AND ruc <> '' LIMIT 1";
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, ruc);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                id_empresa = rset.getString("id_personal");
                exists = true; // Existe la persona, pero tal vez no en datos_empresas
                
                // Verificar si existe en datos_empresas con este ID
                PreparedStatement pstmt2 = conn.prepareStatement("SELECT 1 FROM datos_empresas WHERE id_empresa = ?");
                pstmt2.setString(1, id_empresa);
                ResultSet rset2 = pstmt2.executeQuery();
                boolean existsInEmpresa = rset2.next();
                rset2.close();
                pstmt2.close();
                
                if (!existsInEmpresa) {
                   // Insertar en datos_empresas
                   String insEmp = "INSERT INTO datos_empresas (id_empresa, nombre_comercial, ubigeo, codigo_local, direccion, departamento, provincia, distrito, email, telefono, usuario_sol, clave_sol, cert_ruta, cert_clave, logo, fecha_cre, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), '1')";
                   pstmt2 = conn.prepareStatement(insEmp);
                   pstmt2.setString(1, id_empresa);
                   pstmt2.setString(2, nombre_comercial);
                   pstmt2.setString(3, ubigeo);
                   pstmt2.setString(4, codigo_local);
                   pstmt2.setString(5, direccion);
                   pstmt2.setString(6, departamento);
                   pstmt2.setString(7, provincia);
                   pstmt2.setString(8, distrito);
                   pstmt2.setString(9, email);
                   pstmt2.setString(10, telefono);
                   pstmt2.setString(11, usuario_sol);
                   pstmt2.setString(12, clave_sol);
                   pstmt2.setString(13, cert_ruta);
                   pstmt2.setString(14, cert_clave);
                   pstmt2.setString(15, logo);
                   pstmt2.executeUpdate();
                   pstmt2.close();
                }
            } else {
                // No existe ni persona ni empresa, creamos ambos
                id_empresa = String.valueOf(new java.util.Date().getTime());
                
                // Insertar en datos_personales
                String insPers = "INSERT INTO datos_personales (id_personal, ruc, nombre, direccion, fono, email, fecha_ing, estado, sexo) VALUES (?, ?, ?, ?, ?, ?, NOW(), '1', 'M')";
                pstmt2 = conn.prepareStatement(insPers);
                pstmt2.setString(1, id_empresa);
                pstmt2.setString(2, ruc);
                pstmt2.setString(3, razon_social);
                pstmt2.setString(4, direccion);
                pstmt2.setString(5, telefono);
                pstmt2.setString(6, email);
                pstmt2.executeUpdate();
                pstmt2.close();
                
                // Insertar en datos_empresas
                String insEmp = "INSERT INTO datos_empresas (id_empresa, nombre_comercial, ubigeo, codigo_local, direccion, departamento, provincia, distrito, email, telefono, usuario_sol, clave_sol, cert_ruta, cert_clave, logo, fecha_cre, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), '1')";
                pstmt2 = conn.prepareStatement(insEmp);
                pstmt2.setString(1, id_empresa);
                pstmt2.setString(2, nombre_comercial);
                pstmt2.setString(3, ubigeo);
                pstmt2.setString(4, codigo_local);
                pstmt2.setString(5, direccion);
                pstmt2.setString(6, departamento);
                pstmt2.setString(7, provincia);
                pstmt2.setString(8, distrito);
                pstmt2.setString(9, email);
                pstmt2.setString(10, telefono);
                pstmt2.setString(11, usuario_sol);
                pstmt2.setString(12, clave_sol);
                pstmt2.setString(13, cert_ruta);
                pstmt2.setString(14, cert_clave);
                pstmt2.setString(15, logo);
                pstmt2.executeUpdate();
                pstmt2.close();
            }
            pstmt.close();
        }

        // Si ya existe (o lo acabamos de insertar y queremos asegurar que todo esté al día)
        // Actualizar datos_empresas
        String sqlEmpresa = "UPDATE datos_empresas SET " +
                           "nombre_comercial = ?, ubigeo = ?, codigo_local = ?, " +
                           "direccion = ?, departamento = ?, provincia = ?, distrito = ?, " +
                           "email = ?, telefono = ?, usuario_sol = ?, clave_sol = ?, " +
                           "cert_ruta = ?, cert_clave = ?, logo = ? " +
                           "WHERE id_empresa = ?";
        
        pstmt = conn.prepareStatement(sqlEmpresa);
        pstmt.setString(1, nombre_comercial);
        pstmt.setString(2, ubigeo);
        pstmt.setString(3, codigo_local);
        pstmt.setString(4, direccion);
        pstmt.setString(5, departamento);
        pstmt.setString(6, provincia);
        pstmt.setString(7, distrito);
        pstmt.setString(8, email);
        pstmt.setString(9, telefono);
        pstmt.setString(10, usuario_sol);
        pstmt.setString(11, clave_sol);
        pstmt.setString(12, cert_ruta);
        pstmt.setString(13, cert_clave);
        pstmt.setString(14, logo);
        pstmt.setString(15, id_empresa);
        pstmt.executeUpdate();
        pstmt.close();

        // Actualizar datos_personales
        String sqlPersona = "UPDATE datos_personales SET " +
                           "ruc = ?, nombre = ?, direccion = ?, fono = ?, email = ? " +
                           "WHERE id_personal = ?";
        pstmt = conn.prepareStatement(sqlPersona);
        pstmt.setString(1, ruc);
        pstmt.setString(2, razon_social);
        pstmt.setString(3, direccion);
        pstmt.setString(4, telefono);
        pstmt.setString(5, email);
        pstmt.setString(6, id_empresa);
        pstmt.executeUpdate();

        conn.commit();
        
        jsonResponse.put("success", true);
        jsonResponse.put("message", "Configuración guardada correctamente.");
        jsonResponse.put("id_empresa", id_empresa);

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error de base de datos: " + e.getMessage());
    } finally {
        cerrar(rset, pstmt, conn);
    }

    out.print(jsonResponse.toString());
%>
