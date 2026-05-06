<%@ page contentType="application/json; charset=UTF-8" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>
<%@ include file="bajar_datos.jsp"%>
<%
   String s_idm = request.getParameter("f_idm");
   String s_id_mov_vnt = request.getParameter("f_id_mov_vnt");
   String s_id_movart = request.getParameter("f_id_movart");
   
   boolean success = false;
   int datos = 0;
   String mensaje = "";
   int nump = 0;
   
   try {
       // Actualizar el item a anulado
       try{
            COMANDO = "update vent_regdet set estado ='A' where id_movart=?";
            conn = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_movart);
            upd = pstmt.executeUpdate();
       }catch(Exception e){
            success = false;
            mensaje = "Error al anular: " + e.getMessage();
       }finally{
           cerrar(rset); cerrar(pstmt); cerrar(conn);
           COMANDO = "";upd = 0;
       }

       // Verificar si quedan items en el movimiento    
       try{
            COMANDO = "select count(id_movart) movart "+
                "from vent_regdet "+
                "where id_mov_vnt=? and estado ='V' and id_movart_relacion is null";
            conn = getConexion();
            pstmt = conn.prepareStatement(COMANDO);
            pstmt.setString(1, s_id_mov_vnt);
            rset = pstmt.executeQuery();
            rset.next();
            nump = rset.getInt("movart");
       }catch(Exception e){
            success = false;
            mensaje = "Error al verificar items: " + e.getMessage();
       }finally{
           cerrar(rset); cerrar(pstmt); cerrar(conn);
           COMANDO = "";
       }
       
       // Si no quedan items, anular el movimiento completo
       if(nump == 0) {
           try{
                COMANDO = "update vent_registro set estado ='A' where id_mov_vnt=?";
                conn = getConexion();
                pstmt = conn.prepareStatement(COMANDO);
                pstmt.setString(1, s_id_mov_vnt);
                upd = pstmt.executeUpdate();
           }catch(Exception e){
                success = false;
                mensaje = "Error al anular movimiento: " + e.getMessage();
           }finally{
               cerrar(rset); cerrar(pstmt); cerrar(conn);
               COMANDO = "";upd = 0;
           }
                    
           try{
                COMANDO2 = "update mesas set estado ='0', cliente = NULL where idm=?";
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);
                pstmt2.setString(1, s_idm);
                upd = pstmt2.executeUpdate();
           }catch(Exception e){
                success = false;
                mensaje = "Error al liberar mesa: " + e.getMessage();
           }finally{
               cerrar(rset2); cerrar(pstmt2); cerrar(conn2);
               COMANDO2 = "";upd = 0;
           }
       }    
       
       success = true;
       mensaje = "Item anulado exitosamente";
       
   } catch(Exception e) {
       success = false;
       mensaje = "Error al anular: " + e.getMessage();
   }
%>
{
    "success": <%= success %>,
    "datos": <%= nump %>,
    "mensaje": "<%= mensaje %>",
    "id_mov_vnt": "<%= s_id_mov_vnt %>",
    "idm": "<%= s_idm %>"
}