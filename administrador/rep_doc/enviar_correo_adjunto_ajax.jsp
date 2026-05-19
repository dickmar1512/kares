<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>


<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp"%>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();

    String idMovVnt = request.getParameter("id_mov_vnt");
    String email = request.getParameter("email");
    String xmlFile = request.getParameter("xmlFile");
    String cdrFile = request.getParameter("cdrFile");
    String comprobante = request.getParameter("comprobante");
    String cliente = request.getParameter("cliente");
    String tipoDoc = request.getParameter("tipo_doc");

    if (idMovVnt == null || email == null || xmlFile == null || cdrFile == null || comprobante == null) {
        json.put("success", false);
        json.put("message", "Parámetros insuficientes para el envío.");
        out.print(json.toString());
        return;
    }

    // 1. Cargar la configuración SMTP desde email_config.json
    String configPath = application.getRealPath("/administrador/rep_doc/email_config.json");
    File fConfig = new File(configPath);
    if (!fConfig.exists()) {
        json.put("success", false);
        json.put("message", "Archivo de configuración SMTP no encontrado (email_config.json). Por favor, configure el archivo.");
        out.print(json.toString());
        return;
    }

    StringBuilder configContent = new StringBuilder();
    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(fConfig), "UTF-8"))) {
        String line;
        while ((line = br.readLine()) != null) {
            configContent.append(line);
        }
    } catch (Exception ex) {
        json.put("success", false);
        json.put("message", "Error al leer email_config.json: " + ex.getMessage());
        out.print(json.toString());
        return;
    }

    JSONObject configJson = new JSONObject(configContent.toString());
    final String smtpHost = configJson.optString("smtp_host", "").trim();
    final int smtpPort = configJson.optInt("smtp_port", 587);
    final String smtpUser = configJson.optString("smtp_user", "").trim();
    final String smtpPass = configJson.optString("smtp_pass", "").trim();
    final boolean useTls = configJson.optBoolean("use_tls", true);
    final boolean useSsl = configJson.optBoolean("use_ssl", false);
    final String fromAddress = configJson.optString("from_address", smtpUser).trim();
    final String fromName = configJson.optString("from_name", "Kares Facturación").trim();
    final String sslTrust = configJson.optString("ssl_trust", "").trim();


    if (smtpHost.isEmpty() || smtpUser.isEmpty() || smtpPass.isEmpty()) {
        json.put("success", false);
        json.put("message", "Configuración de SMTP incompleta en email_config.json (Host, Usuario o Clave vacíos).");
        out.print(json.toString());
        return;
    }

    String nombreArchivo = xmlFile.replace(".xml", "");
    File tempPdf = new File(System.getProperty("java.io.tmpdir"), nombreArchivo + ".pdf");

    try {
        // 2. Descargar el PDF dinámico generado por la JSP en una ubicación temporal
        String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
        String pdfPath = "39".equals(tipoDoc) ? "/administrador/rep_reimprimir/print_factura_electronica_pdf.jsp" : "/administrador/rep_reimprimir/print_boleta_electronica_pdf.jsp";
        String pdfUrl = baseUrl + pdfPath + "?f_id_mov_vnt=" + idMovVnt;

        URL url = new URL(pdfUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        
        // Traspasar las cookies de la sesión activa para evitar redirecciones al login
        String cookie = request.getHeader("Cookie");
        if (cookie != null) {
            conn.setRequestProperty("Cookie", cookie);
        }

        try (InputStream in = conn.getInputStream();
             FileOutputStream fos = new FileOutputStream(tempPdf)) {
            byte[] buffer = new byte[4096];
            int read;
            while ((read = in.read(buffer)) != -1) {
                fos.write(buffer, 0, read);
            }
        }

        // 3. Configurar JavaMail y propiedades del servidor SMTP
        Properties prop = new Properties();
        prop.put("mail.smtp.host", smtpHost);
        prop.put("mail.smtp.port", String.valueOf(smtpPort));
        prop.put("mail.smtp.auth", "true");
        prop.put("mail.smtp.starttls.enable", useTls ? "true" : "false");
        prop.put("mail.smtp.connectiontimeout", "15000"); // 15s timeout
        prop.put("mail.smtp.timeout", "15000");           // 15s read timeout

        // Configuración de Confianza SSL/TLS para evitar errores PKIX en producción
        if (!sslTrust.isEmpty()) {
            prop.put("mail.smtp.ssl.trust", sslTrust);
        } else {
            prop.put("mail.smtp.ssl.trust", "*"); // Confianza total por defecto para evitar errores PKIX
        }

        if (useSsl) {
            prop.put("mail.smtp.socketFactory.port", String.valueOf(smtpPort));
            prop.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            prop.put("mail.smtp.socketFactory.fallback", "false");
            if (!sslTrust.isEmpty()) {
                prop.put("mail.smtp.ssl.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            }
        }

        Session mailSession = Session.getInstance(prop, new javax.mail.Authenticator() {
            @Override
            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                return new javax.mail.PasswordAuthentication(smtpUser, smtpPass);
            }
        });

        // 4. Crear el mensaje MIME
        MimeMessage message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(fromAddress, fromName, "UTF-8"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(email));
        message.setSubject("Comprobante Electrónico " + comprobante, "UTF-8");

        // Crear contenedor Multipart para el cuerpo del mensaje y los archivos adjuntos
        Multipart multipart = new MimeMultipart();

        // Parte 1: Cuerpo del correo (Texto plano)
        MimeBodyPart messageBodyPart = new MimeBodyPart();
        String body = "Estimado(a) Cliente,\n\n" +
                      "Adjunto a este correo encontrará su comprobante electrónico " + comprobante + 
                      " en formatos PDF (Representación Impresa), XML y CDR (Constancia de Aceptación).\n\n" +
                      "Agradecemos su preferencia.";
        messageBodyPart.setText(body, "UTF-8");
        multipart.addBodyPart(messageBodyPart);

        // Parte 2: Adjuntar PDF
        if (tempPdf.exists() && tempPdf.isFile()) {
            MimeBodyPart attachPart = new MimeBodyPart();
            javax.activation.DataSource source = new javax.activation.FileDataSource(tempPdf);
            attachPart.setDataHandler(new javax.activation.DataHandler(source));
            attachPart.setFileName(MimeUtility.encodeText(comprobante + ".pdf", "UTF-8", null));
            multipart.addBodyPart(attachPart);
        }

        // Parte 3: Adjuntar XML
        String xmlPath = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/FIRMA/" + xmlFile;
        File fXml = new File(xmlPath);
        if (fXml.exists() && fXml.isFile()) {
            MimeBodyPart attachPart = new MimeBodyPart();
            javax.activation.DataSource source = new javax.activation.FileDataSource(fXml);
            attachPart.setDataHandler(new javax.activation.DataHandler(source));
            attachPart.setFileName(MimeUtility.encodeText(xmlFile, "UTF-8", null));
            multipart.addBodyPart(attachPart);
        }

        // Parte 4: Adjuntar CDR
        String cdrPath = "C:/SFS_v1.3.4.4/sunat_archivos/sfs/RPTA/" + cdrFile;
        File fCdr = new File(cdrPath);
        if (fCdr.exists() && fCdr.isFile()) {
            MimeBodyPart attachPart = new MimeBodyPart();
            javax.activation.DataSource source = new javax.activation.FileDataSource(fCdr);
            attachPart.setDataHandler(new javax.activation.DataHandler(source));
            attachPart.setFileName(MimeUtility.encodeText(cdrFile, "UTF-8", null));
            multipart.addBodyPart(attachPart);
        }

        // Integrar todas las partes al mensaje
        message.setContent(multipart);

        // 5. Enviar el correo de forma síncrona
        Transport.send(message);

        json.put("success", true);
        json.put("message", "Correo electrónico enviado exitosamente con sus adjuntos reales.");

    } catch (Throwable e) {
        e.printStackTrace();
        json.put("success", false);
        json.put("message", "Error de conexión SMTP o en el servidor: " + e.toString());
    } finally {
        // Eliminar el PDF temporal para mantener el servidor limpio
        if (tempPdf.exists()) {
            tempPdf.delete();
        }
    }

    out.print(json.toString());
%>
