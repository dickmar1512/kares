<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String s_nacfec_raw = request.getParameter("f_nacfec");
    String s_nacfec = "01/01/1901";
    if (s_nacfec_raw != null && !s_nacfec_raw.trim().isEmpty()) {
        try {
            Date fechaTemp = sdf1.parse(s_nacfec_raw);
            s_nacfec = sdf2.format(fechaTemp);
        } catch(Exception ex) {}
    }

    String act         = request.getParameter("act"); if(act==null) act="";
    String s_idp       = request.getParameter("f_id_personal"); if(s_idp==null) s_idp="";
    String s_nombre    = request.getParameter("f_nombre");    if(s_nombre==null)    s_nombre="";
    String s_apepat    = request.getParameter("f_apepat");    if(s_apepat==null)    s_apepat="";
    String s_apemat    = request.getParameter("f_apemat");    if(s_apemat==null)    s_apemat="";
    String s_sexo      = request.getParameter("f_sexo");      if(s_sexo==null)      s_sexo="";

    String s_naclug    = request.getParameter("f_naclug");    if(s_naclug==null)    s_naclug="";
    String s_estciv    = request.getParameter("f_estciv");    if(s_estciv==null)    s_estciv="";
    String s_tipdoc    = request.getParameter("f_tipdoc");    if(s_tipdoc==null)    s_tipdoc="";
    String s_numdoc    = request.getParameter("f_numdoc");    if(s_numdoc==null)    s_numdoc="";
    String s_ruc       = request.getParameter("f_ruc");       if(s_ruc==null)       s_ruc="";
    String s_direcc    = request.getParameter("f_direcc");    if(s_direcc==null)    s_direcc="";
    String s_domref    = request.getParameter("f_domref");    if(s_domref==null)    s_domref="";
    String s_domloc    = request.getParameter("f_domloc");    if(s_domloc==null)    s_domloc="";
    String s_fono1     = request.getParameter("f_fono1");     if(s_fono1==null)     s_fono1="";
    String s_fono2     = request.getParameter("f_fono2");     if(s_fono2==null)     s_fono2="";
    String s_flab      = request.getParameter("f_fono_labor");if(s_flab==null)      s_flab="";
    String s_anex      = request.getParameter("f_anexo_labor");if(s_anex==null)     s_anex="";
    String s_loginn    = request.getParameter("f_login");     if(s_loginn==null)    s_loginn="X";
    String s_passwd    = request.getParameter("f_passwd");    if(s_passwd==null)    s_passwd="";
    String s_email     = request.getParameter("f_email");     if(s_email==null)     s_email="";
    String s_email2    = request.getParameter("f_email2");    if(s_email2==null)    s_email2="";
    String s_email3    = request.getParameter("f_email3");    if(s_email3==null)    s_email3="";
    String s_obs       = request.getParameter("f_observacion");if(s_obs==null)      s_obs="";
    String s_tipo      = request.getParameter("f_tipo_persona");if(s_tipo==null)    s_tipo="N"; // N=Natural, J=Juridica

    if(s_tipo.equals("J")) {
        s_nombre = request.getParameter("f_nombre_j"); if(s_nombre==null) s_nombre="";
        s_ruc    = request.getParameter("f_ruc_j");    if(s_ruc==null)    s_ruc="";
        s_tipdoc = request.getParameter("f_tipdoc_j"); if(s_tipdoc==null) s_tipdoc="E";
        s_apepat = "-";
        s_apemat = "-";
        s_numdoc = s_ruc;
        s_sexo   = "";
        s_nacfec = "01/01/1901";
        s_naclug = "";
        s_estciv = "";
        
        if(s_nombre.trim().isEmpty() || s_ruc.trim().isEmpty()){
            out.print("{\"ok\":false,\"msg\":\"Razón Social y RUC son requeridos para Persona Jurídica\"}"); return;
        }
    } else {
        s_nombre = request.getParameter("f_nombre_n"); if(s_nombre==null) s_nombre="";
        if(s_nombre.trim().isEmpty()||s_apepat.trim().isEmpty()||s_apemat.trim().isEmpty()){
            out.print("{\"ok\":false,\"msg\":\"Apellidos y Nombres son requeridos para Persona Natural\"}"); return;
        }
    }

    try {
        if(act.equals("delete")){
            conn = getConexion();
            pstmt = conn.prepareStatement("update datos_personales SET estado='0' WHERE id_personal=?");
            pstmt.setString(1, s_idp);
            pstmt.executeUpdate();
            out.print("{\"ok\":true,\"msg\":\"Registro eliminado\"}");
            return;
        }

        if(act.equals("update")){
            conn = getConexion();
            pstmt = conn.prepareStatement(
                "UPDATE datos_personales SET " +
                " nombre=upper(?), apepat=upper(?), apemat=upper(?)," +
                " ver_nombre=upper(?), ver_apepat=upper(?), ver_apemat=upper(?)," +
                " sexo=?, nacfec=?, naclug=?, estciv=?, tipdoc=?, numdoc=?," +
                " direcc=?, domref=?, domloc=?, fono1=?, fono2=?," +
                " fono_labor=?, anexo_labor=?, login=?, passwd=?," +
                " email=?, email2=?, email3=?, ruc=?, observacion=?," +
                " estado='1', user_upd_dat=?, IP_UPD=?, fech_upd_dat=now() " +
                "WHERE id_personal=?");
            int p=1;
            pstmt.setString(p++,s_nombre);pstmt.setString(p++,s_apepat);pstmt.setString(p++,s_apemat);
            pstmt.setString(p++,s_nombre);pstmt.setString(p++,s_apepat);pstmt.setString(p++,s_apemat);
            pstmt.setString(p++,s_sexo);pstmt.setString(p++,s_nacfec);pstmt.setString(p++,s_naclug);
            pstmt.setString(p++,s_estciv);pstmt.setString(p++,s_tipdoc);pstmt.setString(p++,s_numdoc);
            pstmt.setString(p++,s_direcc);pstmt.setString(p++,s_domref);pstmt.setString(p++,s_domloc);
            pstmt.setString(p++,s_fono1);pstmt.setString(p++,s_fono2);
            pstmt.setString(p++,s_flab);pstmt.setString(p++,s_anex);
            pstmt.setString(p++,s_loginn);pstmt.setString(p++,s_passwd);
            pstmt.setString(p++,s_email);pstmt.setString(p++,s_email2);pstmt.setString(p++,s_email3);
            pstmt.setString(p++,s_ruc);pstmt.setString(p++,s_obs);
            pstmt.setString(p++,id_personal_user);pstmt.setString(p++,s_ip);
            pstmt.setString(p++,s_idp);
            pstmt.executeUpdate();
            out.print("{\"ok\":true,\"msg\":\"Registro actualizado correctamente\",\"id\":\""+s_idp+"\"}");
            return;
        }

        if(act.equals("insert")){
            // verificar duplicado
            conn = getConexion();
            PreparedStatement chk = conn.prepareStatement(
                "SELECT id_personal FROM datos_personales " +
                "WHERE ver_apepat=convert(?,char) AND ver_apemat=convert(?,char) AND ver_nombre=convert(?,char)");
            chk.setString(1,s_apepat.toUpperCase());chk.setString(2,s_apemat.toUpperCase());chk.setString(3,s_nombre.toUpperCase());
            ResultSet rc = chk.executeQuery();
            if(rc.next()){
                rc.close(); chk.close();
                out.print("{\"ok\":false,\"msg\":\"Ya existe una persona con esos apellidos y nombre\"}"); return;
            }
            rc.close(); chk.close();

            java.util.Date dtNow = new java.util.Date();
            s_idp = dtNow.getTime()+"";
            pstmt = conn.prepareStatement(
                "INSERT INTO datos_personales (id_personal,nombre,apepat,apemat," +
                " ver_nombre,ver_apepat,ver_apemat,sexo,nacfec,naclug,estciv,tipdoc,numdoc," +
                " direcc,domref,domloc,fono1,fono2,fono_labor,anexo_labor," +
                " login,passwd,email,email2,email3,ruc,foto,observacion,estado,fecha_ing,ID_PERSONAL_USER) " +
                "VALUES (?,upper(?),upper(?),upper(?),upper(?),upper(?),upper(?)," +
                " ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'','','1',now(),?)");
            int q=1;
            pstmt.setString(q++,s_idp);
            pstmt.setString(q++,s_nombre);pstmt.setString(q++,s_apepat);pstmt.setString(q++,s_apemat);
            pstmt.setString(q++,s_nombre);pstmt.setString(q++,s_apepat);pstmt.setString(q++,s_apemat);
            pstmt.setString(q++,s_sexo);pstmt.setString(q++,s_nacfec);pstmt.setString(q++,s_naclug);
            pstmt.setString(q++,s_estciv);pstmt.setString(q++,s_tipdoc);pstmt.setString(q++,s_numdoc);
            pstmt.setString(q++,s_direcc);pstmt.setString(q++,s_domref);pstmt.setString(q++,s_domloc);
            pstmt.setString(q++,s_fono1);pstmt.setString(q++,s_fono2);
            pstmt.setString(q++,s_flab);pstmt.setString(q++,s_anex);
            pstmt.setString(q++,s_loginn);pstmt.setString(q++,s_passwd);
            pstmt.setString(q++,s_email);pstmt.setString(q++,s_email2);pstmt.setString(q++,s_email3);
            pstmt.setString(q++,s_ruc);
            pstmt.setString(q++,id_personal_user);
            pstmt.executeUpdate();
            out.print("{\"ok\":true,\"msg\":\"Persona registrada correctamente\",\"id\":\""+s_idp+"\"}");
            return;
        }

        out.print("{\"ok\":false,\"msg\":\"Accion no reconocida\"}");

    } catch(Exception e){
        String em = (e.getMessage()!=null?e.getMessage():"error").replace("\"","'").replace("\n"," ");
        out.print("{\"ok\":false,\"msg\":\""+em+"\"}");
    } finally { cerrar(rset, pstmt, conn); }
%>
