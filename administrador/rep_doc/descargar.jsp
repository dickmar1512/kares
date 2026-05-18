<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.*"%>
<%
    String tipo = request.getParameter("tipo");
    String archivo = request.getParameter("archivo");

    if (tipo == null || archivo == null || archivo.trim().isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parámetros insuficientes.");
        return;
    }

    // Seguridad: Evitar Directory Traversal (solo permitir letras, números, guiones, puntos y guiones bajos)
    if (!archivo.matches("^[a-zA-Z0-9\\-_\\.]+$")) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de archivo no válido.");
        return;
    }

    String basePath = "";
    String contentType = "";

    if ("xml".equalsIgnoreCase(tipo)) {
        basePath = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/FIRMA/";
        contentType = "application/xml";
    } else if ("cdr".equalsIgnoreCase(tipo)) {
        basePath = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/RPTA/";
        contentType = "application/zip";
    } else {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de archivo no soportado.");
        return;
    }

    File file = new File(basePath + archivo);

    if (!file.exists() || !file.isFile()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "El archivo solicitado no existe en la ruta especificada.");
        return;
    }

    // Configurar cabeceras de descarga
    response.setContentType(contentType);
    response.setContentLength((int) file.length());
    response.setHeader("Content-Disposition", "attachment; filename=\"" + archivo + "\"");

    // Limpiar buffers para evitar conflictos con la salida JSP estándar
    out.clear();
    out = pageContext.pushBody();

    // Transmitir el archivo
    try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(file));
         BufferedOutputStream outStream = new BufferedOutputStream(response.getOutputStream())) {
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            outStream.write(buffer, 0, bytesRead);
        }
        outStream.flush();
    } catch (IOException e) {
        System.err.println("Error al transmitir archivo en descargar.jsp: " + e.getMessage());
    }
%>
