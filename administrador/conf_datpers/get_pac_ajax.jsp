<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String idp = request.getParameter("id"); if(idp==null) idp="";
    if(idp.isEmpty()){ out.print("{\"error\":\"id requerido\"}"); return; }

    try {
        conn = getConexion();
        pstmt = conn.prepareStatement(
            "SELECT nombre, apepat, apemat, sexo, " +
            " STR_TO_DATE(nacfec,'%d/%m/%Y') AS nacfec_date, nacfec, " +
            " ifnull(naclug,'') naclug, ifnull(estciv,'') estciv, " +
            " ifnull(tipdoc,'') tipdoc, ifnull(numdoc,'') numdoc, " +
            " ifnull(ruc,'') ruc, " +
            " ifnull(direcc,'') direcc, ifnull(domref,'') domref, ifnull(domloc,'') domloc, " +
            " ifnull(fono1,'') fono1, ifnull(fono2,'') fono2, " +
            " ifnull(fono_labor,'') fono_labor, ifnull(anexo_labor,'') anexo_labor, " +
            " ifnull(login,'') login, ifnull(email,'') email, " +
            " ifnull(email2,'') email2, ifnull(email3,'') email3, " +
            " ifnull(observacion,'') observacion, ifnull(foto,'') foto " +
            "FROM datos_personales WHERE id_personal=?");
        pstmt.setString(1, idp);
        rset = pstmt.executeQuery();
        if(!rset.next()){ out.print("{\"error\":\"no encontrado\"}"); return; }

        java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
        String[] cols = {"nombre","apepat","apemat","sexo","naclug","estciv",
                         "tipdoc","numdoc","ruc","direcc","domref","domloc",
                         "fono1","fono2","fono_labor","anexo_labor",
                         "login","email","email2","email3","observacion","foto"};
        for(String c : cols){
            String v = rset.getString(c); if(v==null) v="";
            m.put(c, v.replace("\\","\\\\").replace("\"","\\\"").replace("\r","").replace("\n","\\n"));
        }
        
        // Handle nacfec separately for yyyy-MM-dd format
        String nacfec_date = rset.getString("nacfec_date");
        if(nacfec_date == null || nacfec_date.isEmpty()) {
            m.put("nacfec", "");
        } else {
            m.put("nacfec", nacfec_date);
        }

        cerrar(rset, pstmt, conn);

        // medico data
        String s_ccm="", s_hon="";
        try {
            conn = getConexion();
            pstmt = conn.prepareStatement("SELECT ifnull(nro_cmp,'') nro_cmp, ifnull(honorarios,'') honorarios FROM datos_medico WHERE id_personal=?");
            pstmt.setString(1, idp);
            rset = pstmt.executeQuery();
            if(rset.next()){ s_ccm=rset.getString("nro_cmp"); s_hon=rset.getString("honorarios"); }
        } catch(Exception ex){}  finally { cerrar(rset, pstmt, conn); }

        StringBuilder sb = new StringBuilder("{");
        sb.append("\"id\":\"").append(idp).append("\",");
        for(java.util.Map.Entry<String,String> e : m.entrySet())
            sb.append("\"").append(e.getKey()).append("\":\"").append(e.getValue()).append("\",");
        sb.append("\"nro_cmp\":\"").append(s_ccm.replace("\"","\\\"")).append("\",");
        sb.append("\"honorarios\":\"").append(s_hon.replace("\"","\\\"")).append("\"");
        sb.append("}");
        out.print(sb.toString());
    } catch(Exception e){
        out.print("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
    } finally { cerrar(rset, pstmt, conn); }
%>
