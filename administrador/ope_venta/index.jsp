<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp" %>
<%@ include file="../seguro.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Cobrar de Mesas · Kares</title>
  
  <link rel="shortcut icon" href="../../assets/images/favicon.ico">
  <link rel="stylesheet" href="../../assets/plugins/fontsgstatic/css/css.css">
  <link rel="stylesheet" href="../../assets/plugins/fontawesome6.7.2/css/all.min.css">
  
  <!-- Usamos el mismo CSS corporativo de mesas que creamos previamente -->
  <link rel="stylesheet" href="../../assets/css/mesa/ope_venta/index.css?v=<%=System.currentTimeMillis()%>" type="text/css">
</head>
<body>

<!-- ── Contenedor Flex Fullscreen ────────────────────────────── -->
<div class="mesas-panel">

  <!-- Topbar Corporativa -->
  <div class="mesas-topbar">
      <div class="topbar-icon">
          <i class="fas fa-hand-holding-usd"></i>
      </div>
      <span class="topbar-title">Cobrar de Mesas</span>
      
      <div class="topbar-right">
          <span>Seleccione una mesa ocupada para procesar el pago</span>
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
                btn = "ATENDER";
                estadoTexto = "Disponible";
            }  
            if(estado == 1)
            {
                xclas = "reservada";
                btn = "AGREGAR";
                estadoTexto = "Reservada";
            }  
            if(estado == 2)
            {
                xclas = "ocupada";
                btn = "Procesar Pago";
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
              
              <% if(estado == 2) { %>
              <div class="mesa-action">
                <a href="index2.jsp?idm=<%=rset.getString("idm")%>" class="btn-action <%=xclas%>">
                  <%=btn%>
                  <i class="fas fa-chevron-right"></i>
                </a>
              </div>
              <% } else if(estado == 0) { %>
              <div class="mesa-action">
                <button class="btn-action" style="background:#fef3c7; color:#d97706; border:1px solid #fcd34d; width:100%; cursor:pointer;" onclick="reservarMesa('<%=rset.getString("idm")%>', '<%=rset.getString("descripcion").replace("'","\\'")%>')">
                  Reservar Mesa
                </button>
              </div>
              <% } %>

            </div>
          </div>          
          <% }  
      }catch(Exception e){ 
        out.println("ERROR: " + e.getMessage()); 
      }finally{ 
        cerrar(rset); cerrar(pstmt); cerrar(conn);
        COMANDO = ""; 
      }
      %> 
    </div>
  </div>

</div><!-- Scripts -->
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