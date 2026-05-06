<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Selección de Mesas · Kares</title>
  
  <link rel="shortcut icon" href="../../assets/images/favicon.ico">
  <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
  <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
  <!-- CSS Personalizado -->
  <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/index.css?v=<%=System.currentTimeMillis()%>" type="text/css">
</head>
<body>

<!-- ── Contenedor Flex Fullscreen ────────────────────────────── -->
<div class="mesas-panel">

  <!-- Topbar Corporativa -->
  <div class="mesas-topbar">
      <div class="topbar-icon">
          <i class="fas fa-chair"></i>
      </div>
      <span class="topbar-title">Atención de Mesas</span>
      
      <div class="topbar-right">
          <span>Seleccione una mesa para iniciar o continuar una orden</span>
      </div>
  </div>

  <%
     int estado = 0;
     String xclas = ""; 
     String btn = "";
     String estadoTexto = "";
  %>

  <!-- Contenido desplazable -->
  <div class="mesas-content">
    <div class="mesas-grid">
      <%
      try{
        COMANDO = "CALL sp_kar_listar_mesas()";  
        conn = getConexion();                 
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery(); 
        while(rset.next())
        {      
          estado = rset.getInt("estado");

          if(estado == 0)
          {
              xclas = "disponible";
              btn = "Nueva Orden";
              estadoTexto = "Disponible";
          }  
          if(estado == 1)
          {
              xclas = "reservada";
              btn = "Generar Orden";
              estadoTexto = "Reservada";
          }  
          if(estado == 2)
          {
              xclas = "ocupada";
              btn = "Agregar Orden";
              estadoTexto = "Ocupada";
          }   
        %>      
        <div class="mesa-card <%=xclas%>">
          
          <div class="mesa-header">
            <h3 class="mesa-nombre"><%=rset.getString("descripcion")%></h3>
            <i class="fas fa-utensils mesa-icon"></i>
          </div>
          
          <div class="mesa-body">
            
            <div class="mesa-info">
              <i class="fas fa-users"></i>
              <span><strong>Capacidad:</strong> <%=rset.getString("cap")%> pax</span>
            </div>
            
            <div class="mesa-info">
              <i class="fas fa-tag"></i>
              <span><strong>Condición:</strong> <%=rset.getString("cond")%></span>
            </div>
            
            <% if(estado == 1 && rset.getString("cliente") != null && !rset.getString("cliente").isEmpty()) { %>
            <div class="mesa-info">
              <i class="fas fa-user-clock"></i>
              <span><strong>A nombre de:</strong> <%=rset.getString("cliente")%></span>
            </div>
            <% } %>
            
            <span class="estado-badge <%=xclas%>">
              <i class="fas fa-circle"></i> <%=estadoTexto%>
            </span> 
            
            <div class="mesa-action" style="display:flex; gap:8px;">
              <a href="show_venta.jsp?idm=<%=rset.getString("idm")%>" class="btn-action <%=xclas%>" style="flex:1;">
                <%=btn%>
                <i class="fas fa-chevron-right"></i>
              </a>
              <% if(estado == 0) { %>
              <button class="btn-action" style="flex:1; background:#fff; color:#d97706; border:1px solid #e2e8f0; cursor:pointer;" onclick="reservarMesa('<%=rset.getString("idm")%>', '<%=rset.getString("descripcion").replace("'","\\'")%>')">
                Reservar
              </button>
              <% } %>
            </div>

          </div>
        </div> 
      <% }
       }catch(Exception e){
        out.println("Error: " + e.getMessage());
       }finally{
        cerrar(rset, pstmt, conn);
        rset = null;
        pstmt = null;
        conn = null;
       }%>   
    </div>
  </div>

</div><!-- /mesas-panel -->

<script src="../../assets/plugins/jquery/jquery.min.js"></script>
<script src="../../assets/plugins/sweetalert2/sweetalert2.11.js"></script>
<script>
function reservarMesa(idm, nombreMesa) {
    Swal.fire({
        title: '¿Reservar ' + nombreMesa + '?',
        html: '<p>Ingrese el nombre del cliente para la reserva:</p>' +
              '<input id="swal-input-cliente" class="swal2-input" placeholder="Ej. Juan Pérez" autocomplete="off" style="margin-top:0;">',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#f59e0b',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Sí, reservar',
        cancelButtonText: 'Cancelar',
        customClass: { popup: 'swal2-popup-custom' },
        preConfirm: () => {
            const cliente = document.getElementById('swal-input-cliente').value;
            if (!cliente.trim()) {
                Swal.showValidationMessage('Debe ingresar el nombre del cliente');
            }
            return cliente.trim();
        }
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: 'reservar_mesa_ajax.jsp',
                type: 'POST',
                data: { idm: idm, cliente: result.value },
                dataType: 'json',
                success: function(response) {
                    if(response.success) {
                        Swal.fire({
                            title: '¡Reservada!',
                            text: response.message,
                            icon: 'success',
                            timer: 1500,
                            showConfirmButton: false,
                            customClass: { popup: 'swal2-popup-custom' }
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire({ title: 'Error', text: response.message, icon: 'error', customClass: { popup: 'swal2-popup-custom' }});
                    }
                },
                error: function() {
                    Swal.fire({ title: 'Error', text: 'No se pudo conectar con el servidor.', icon: 'error', customClass: { popup: 'swal2-popup-custom' }});
                }
            });
        }
    });
}
</script>
</body>
</html>