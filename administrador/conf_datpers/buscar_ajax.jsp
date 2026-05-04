<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<%
    String tipo = request.getParameter("tipo"); if(tipo==null) tipo="dni";
    String s_dni = request.getParameter("dni"); if(s_dni==null) s_dni="";
    String s_pat = request.getParameter("pat"); if(s_pat==null) s_pat="";
    String s_mat = request.getParameter("mat"); if(s_mat==null) s_mat="";
    String s_nom = request.getParameter("nom"); if(s_nom==null) s_nom="";
    s_dni = s_dni.trim(); s_pat = s_pat.trim(); s_mat = s_mat.trim(); s_nom = s_nom.trim();

    StringBuilder json = new StringBuilder("[");
    int cnt = 0;
    try {
        conn = getConexion();
        String sql = "SELECT id_personal, " +
                     " concat_ws(' ',apepat,apemat,nombre) AS cliente, " +
                     " EDAD(id_personal) AS edad, " +
                     " concat(ifnull(doc_ident(tipdoc),''),' ',ifnull(numdoc,'')) AS doc, " +
                     " nacfec AS fecnac " +
                     "FROM datos_personales WHERE ifnull(fallecido,'N')<>'S' ";
        if(tipo.equals("dni") && !s_dni.isEmpty()){
            sql += " AND concat(ifnull(numdoc,''),ifnull(ruc,'')) LIKE ? ";
        } else if(!s_pat.isEmpty() || !s_mat.isEmpty() || !s_nom.isEmpty()){
            sql += " AND convert(apepat,char) LIKE ? AND convert(apemat,char) LIKE ? AND convert(nombre,char) LIKE ? ";
        } else {
            out.print("[]"); return;
        }
        sql += " ORDER BY apepat, apemat, nombre LIMIT 200";
       
        pstmt = conn.prepareStatement(sql);
        if(tipo.equals("dni") && !s_dni.isEmpty()){
            pstmt.setString(1, "%" + s_dni + "%");
        } else {
            pstmt.setString(1, s_pat + "%");
            pstmt.setString(2, s_mat + "%");
            pstmt.setString(3, "%" + s_nom + "%");
        }
        
        rset = pstmt.executeQuery();
        while(rset.next()){
            if(cnt>0) json.append(",");
            String idp    = rset.getString("id_personal"); if(idp==null) idp="";
            String cliente    = rset.getString("cliente"); if(cliente==null) cliente="";
            String edad   = rset.getString("edad"); if(edad==null) edad="";
            String doc    = rset.getString("doc"); if(doc==null) doc="";
            String fecnac = rset.getString("fecnac"); if(fecnac==null) fecnac="";
            cliente    = cliente.replace("\\","\\\\").replace("\"","\\\"");
            edad   = edad.replace("\"","\\\"");
            doc    = doc.trim().replace("\"","\\\"");
            
            fecnac = fecnac.replace("\"","\\\"");
            json.append("{")
                .append("\"id\":\"").append(idp).append("\",")
                .append("\"cliente\":\"").append(cliente).append("\",")
                .append("\"edad\":\"").append(edad).append("\",")
                .append("\"doc\":\"").append(doc).append("\",")
                .append("\"fecnac\":\"").append(fecnac).append("\"")
                .append("}");
            cnt++;
        }
    } catch(Exception e){
        out.print("{\"error\":\"" + e.getMessage() + "\"}");
        return;
    } finally { cerrar(rset, pstmt, conn); }
    json.append("]");
    out.print(json.toString());
%>
