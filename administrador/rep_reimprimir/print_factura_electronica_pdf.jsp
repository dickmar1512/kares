<%@ page contentType="application/pdf; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.itextpdf.kernel.pdf.PdfWriter" %>
<%@ page import="com.itextpdf.kernel.pdf.PdfDocument" %>
<%@ page import="com.itextpdf.kernel.pdf.xobject.PdfFormXObject" %>
<%@ page import="com.itextpdf.kernel.geom.PageSize" %>
<%@ page import="com.itextpdf.kernel.colors.DeviceRgb" %>
<%@ page import="com.itextpdf.layout.element.Image" %>
<%@ page import="com.itextpdf.io.image.ImageDataFactory" %>
<%@ page import="com.itextpdf.layout.Document" %>
<%@ page import="com.itextpdf.layout.element.Paragraph" %>
<%@ page import="com.itextpdf.layout.element.Table" %>
<%@ page import="com.itextpdf.layout.element.Cell" %>
<%@ page import="com.itextpdf.layout.property.TextAlignment" %>
<%@ page import="com.itextpdf.layout.property.HorizontalAlignment" %>
<%@ page import="com.itextpdf.layout.borders.SolidBorder" %>
<%@ page import="com.itextpdf.layout.borders.Border" %>
<%@ page import="com.itextpdf.barcodes.BarcodeQRCode" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.*" %>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>

<%
    // Limpiar el buffer y configurar la respuesta ANTES de cualquier salida
    response.reset();
    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "inline; filename=factura.pdf");

    try {
        // Obtener el parámetro id_venta desde la URL
        String f_id_mov_vnt = request.getParameter("f_id_mov_vnt");
        
        // Validar que el parámetro no sea nulo
        if (f_id_mov_vnt == null || f_id_mov_vnt.trim().isEmpty()) {
            throw new IllegalArgumentException("ID de venta no proporcionado");
        }

        // Variables para almacenar datos de la venta
        String x_fec = "";
        String comprobante = "";
        String s_mesa = "";
        Double sumbi = 0.0;
        Double sumtot = 0.0;
        String total_letras = "";
        String x_log_caj = "";
        String s_razon = "";
        String p_ruc = "";
        String p_dirruc = "";
        String id_mov_vnt_value = "";
        String p_formaPago = "CONTADO";

        // Ruta de la imagen del logo
        String imagePath = application.getRealPath("/assets/images/logo2.png");

        // Consultar la venta principal
        String COMANDO = "select id_mov_vnt, " +
                "upper(razon) razon, " +
                "ruc, " +
                "direcruc(ruc) dirruc, " +
                "date_format(fecha,'%d/%m/%Y %H:%i') fecha, " +
                "concat(serie,'-',lpad(numdoc,7,0)) doc, " +
                "valor_venta as vv, " +
                "base_imp as bi, " +
                "descuento, " +
                "ifnull(id_mesa,'') as mesa, " +
                "login(id_personal_user) log_caj, " +
                "total " +
                "from vent_registro " +
                "where id_mov_vnt ='" + f_id_mov_vnt + "'";
        
        Connection conn = getConexion();
        PreparedStatement pstmt = conn.prepareStatement(COMANDO);
        ResultSet rset = pstmt.executeQuery();

        if (rset.next()) {
            sumbi = rset.getDouble("bi");
            sumtot = rset.getDouble("total");
            comprobante = rset.getString("doc");
            x_fec = rset.getString("fecha");
            s_mesa = rset.getString("mesa");
            x_log_caj = rset.getString("log_caj");
            s_razon = rset.getString("razon");
            p_ruc = rset.getString("ruc");
            p_dirruc = rset.getString("dirruc");
            id_mov_vnt_value = rset.getString("id_mov_vnt");

            // Validar valores null y asignar valores por defecto
            if (comprobante == null) comprobante = "";
            if (x_fec == null) x_fec = "";
            if (s_mesa == null) s_mesa = "";
            if (x_log_caj == null) x_log_caj = "";
            if (s_razon == null) s_razon = "";
            if (p_ruc == null) p_ruc = "";
            if (p_dirruc == null) p_dirruc = "";
            if (id_mov_vnt_value == null) id_mov_vnt_value = "";

            // Calcular cantidad de items para altura dinámica
            int cantItems = 0;
            PreparedStatement pstmtCant = conn.prepareStatement("SELECT COUNT(*) as cant FROM vent_regdet WHERE id_mov_vnt = ? AND estado <> 'X'");
            pstmtCant.setString(1, f_id_mov_vnt);
            ResultSet rsCant = pstmtCant.executeQuery();
            if(rsCant.next()) cantItems = rsCant.getInt("cant");
            rsCant.close();
            pstmtCant.close();
            
            float width = 226.77f; // 80mm en puntos
            float height = 550f + (cantItems * 30f);

            // CREAR EL PDF
            PdfWriter writer = new PdfWriter(response.getOutputStream());
            PdfDocument pdfDoc = new PdfDocument(writer);
            pdfDoc.setDefaultPageSize(new PageSize(width, height));
            Document document = new Document(pdfDoc);

            // Parsear la fecha
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            Date fechaParsed = null;
            try {
                fechaParsed = dateFormat.parse(x_fec);
            } catch (Exception e) {
                // Si hay error al parsear, usar fecha actual
                fechaParsed = new Date();
            }

            // Configurar márgenes del documento
            document.setMargins(5, 5, 5, 5);

            // Agregar logo
            try {
                Image img = new Image(ImageDataFactory.create(imagePath));
                img.setWidth(100);
                img.setHorizontalAlignment(HorizontalAlignment.CENTER);
                img.setMarginBottom(9);
                document.add(img);
            } catch (Exception imgEx) {
                // Si no se encuentra el logo, continuar sin él
            }

            // Información de la empresa - Validar que no sean null
            document.add(new Paragraph("INVERSIONES MJGL E.I.R.L")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginTop(-2).setMarginBottom(1));
            document.add(new Paragraph("Calle Pevas N° 219")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(1));
            document.add(new Paragraph("Iquitos - Maynas - Loreto")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(1));
            document.add(new Paragraph("Cel.: 995089676")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(7));

            // Tabla con RUC, Tipo de documento y Número
            float[] columnWidthsDoc = {1};
            Table tableDoc = new Table(columnWidthsDoc);
            tableDoc.setHorizontalAlignment(HorizontalAlignment.CENTER);
            tableDoc.addCell(new Cell().add(new Paragraph("RUC: 20541177281")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(2)));

            Cell txtTipoDoc = new Cell().add(new Paragraph("FACTURA ELECTRONICA")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtTipoDoc.setBackgroundColor(new DeviceRgb(0, 0, 0));
            txtTipoDoc.setBorder(new SolidBorder(1));
            tableDoc.addCell(txtTipoDoc);

            // Asegurar que comprobante no sea null
            String docText = (comprobante != null && !comprobante.isEmpty()) ? comprobante : "N/A";
            tableDoc.addCell(new Cell().add(new Paragraph(docText)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(2)));
            document.add(tableDoc);

            // Datos del cliente
            document.add(new Paragraph(" "));
            float[] colWidths = {75, 145};
            Table clientTable = new Table(colWidths);
            clientTable.setMarginTop(5);
            
            // Agregar cada celda con validación de null
            clientTable.addCell(new Cell().add(new Paragraph("FECHA EMISION :").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph((x_fec != null && !x_fec.isEmpty()) ? x_fec : "N/A").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("RAZON SOCIAL  :").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph((s_razon != null && !s_razon.isEmpty()) ? s_razon : "N/A").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("RUC                     :").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph((p_ruc != null && !p_ruc.isEmpty()) ? p_ruc : "N/A").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("DIRECCION         :").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph((p_dirruc != null && !p_dirruc.isEmpty()) ? p_dirruc : "N/A").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("FORMA PAGO     :").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph(p_formaPago).setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            
            document.add(clientTable);
            document.add(new Paragraph(" "));
            document.add(new Paragraph(" "));

            // Crear tabla para el detalle de productos
            float[] columnWidthsProd = {25, 145, 25, 25};
            Table tableProd = new Table(columnWidthsProd);

            // Encabezados de la tabla
            Cell txtCantidad = new Cell().add(new Paragraph("Cnt.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtCantidad.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtCantidad);

            Cell txtDescripcion = new Cell().add(new Paragraph("Descripcion")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.LEFT)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtDescripcion.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtDescripcion);

            Cell txtImporte = new Cell().add(new Paragraph("P.U.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtImporte.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtImporte);

            Cell txtSubtotal = new Cell().add(new Paragraph("Imp.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtSubtotal.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtSubtotal);

            // Consultar el detalle de la venta
            String COMANDO2 = "Select " +
                    "cantidad, " +
                    "glosa, ifnull(presentacion(id_articulo),'') presen, " +
                    "round(valor_venta*((100+porc_igv)/100),2) as vv, " +
                    "round((valor_venta*((100+porc_igv)/100))/cantidad,2) as vu, " +
                    "round(base_imp*((100+porc_igv)/100),2) as bi, " +
                    "round(ifnull(descuento,0)*((100+porc_igv)/100),2) as dsc, " +
                    "round(total,2) as tota " +
                    "from vent_regdet " +
                    "where id_mov_vnt = '" + id_mov_vnt_value + "' " +
                    "order by orden ";
            
            Connection conn2 = getConexion();
            PreparedStatement pstmt2 = conn2.prepareStatement(COMANDO2);
            ResultSet rset2 = pstmt2.executeQuery();
            
            while (rset2.next()) {
                int cantidad = rset2.getInt("cantidad");
                String producto = rset2.getString("glosa");
                double precio = rset2.getDouble("vu");
                double subtotal = rset2.getDouble("tota");

                // Validar que producto no sea null
                if (producto == null) producto = "Sin descripción";

                tableProd.addCell(new Cell().add(new Paragraph(String.valueOf(cantidad))
                        .setFontSize(8).setBold().setTextAlignment(TextAlignment.CENTER)));
                tableProd.addCell(new Cell().add(new Paragraph(producto)
                        .setFontSize(8).setBold()));
                tableProd.addCell(new Cell().add(new Paragraph(String.format("%.2f", precio))
                        .setFontSize(8).setBold().setTextAlignment(TextAlignment.RIGHT)));
                tableProd.addCell(new Cell().add(new Paragraph(String.format("%.2f", subtotal))
                        .setFontSize(8).setBold().setTextAlignment(TextAlignment.RIGHT)));
            }
            rset2.close();
            pstmt2.close();
            conn2.close();

            // Añadir la tabla de productos al documento
            document.add(tableProd);

            // Obtener total en letras
            String COMANDO3 = "Select numtxt('" + sumtot + "') tota_letra from dual ";
            Connection conn3 = getConexion();
            PreparedStatement pstmt3 = conn3.prepareStatement(COMANDO3);
            ResultSet rset3 = pstmt3.executeQuery();
            if (rset3.next()) {
                String letras = rset3.getString("tota_letra");
                if (letras != null && !letras.isEmpty()) {
                    total_letras = "Son: " + letras + " Soles.";
                } else {
                    total_letras = "Son: " + String.format("%.2f", sumtot) + " Soles.";
                }
            } else {
                total_letras = "Son: " + String.format("%.2f", sumtot) + " Soles.";
            }
            rset3.close();
            pstmt3.close();
            conn3.close();

            // Generar código QR
            String qrText = "20541177281|01|" + (comprobante != null ? comprobante : "") + "|0.00|" + sumtot + "|" + (x_fec != null ? x_fec : "") + "|";
            BarcodeQRCode qrCode = new BarcodeQRCode(qrText);
            PdfFormXObject qrCodeForm = qrCode.createFormXObject(null, pdfDoc);
            Image qrImage = new Image(qrCodeForm);
            qrImage.scale(2, 2);

            // Crear tabla principal con QR y totales
            float[] columnWidthsMain = {70, 150};
            Table tableMain = new Table(columnWidthsMain);

            // Celda con QR
            Cell qrCell = new Cell();
            qrCell.add(qrImage);
            tableMain.addCell(qrCell);

            // Tabla anidada con totales
            float[] columnWidthsNested = {120, 5, 30};
            Table nestedTable = new Table(columnWidthsNested);
            nestedTable.setFontSize(8);

            nestedTable.addCell(new Cell().add(new Paragraph("OPE. EXONERADA").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("S/").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumbi != null ? sumbi : 0.0))
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            nestedTable.addCell(new Cell().add(new Paragraph("OPE. INAFECTA").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("S/").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("0.00")
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            nestedTable.addCell(new Cell().add(new Paragraph("OPE. GRAVADA").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("S/").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("0.00")
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            nestedTable.addCell(new Cell().add(new Paragraph("IGV").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("S/").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("0.00")
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            nestedTable.addCell(new Cell().add(new Paragraph("TOTAL").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph("S/").setBold()));
            nestedTable.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumtot != null ? sumtot : 0.0))
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            Cell nestedTableCell = new Cell().add(nestedTable);
            tableMain.addCell(nestedTableCell);

            document.add(tableMain);

            // Total en letras
            document.add(new Paragraph(total_letras != null ? total_letras : "")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.RIGHT));

            // Mensajes legales
            document.add(new Paragraph("Consulte y/o descargue su comprobante electrónico en www.sunat.gob.pe, utilizando su clave SOL")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER));

            document.add(new Paragraph("Autorizado para ser emisor electrónico mediante la Resolución de Superintendencia N° 155-2017")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER));

            // Información adicional
            String cajeroText = (x_log_caj != null && !x_log_caj.isEmpty()) ? x_log_caj : "N/A";
            document.add(new Paragraph("CAJERO     : " + cajeroText)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            String mesaText = (s_mesa != null && !s_mesa.isEmpty()) ? s_mesa : "N/A";
            document.add(new Paragraph("MESA NRO: " + mesaText)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            // Cerrar el documento
            document.close();
            pdfDoc.close();
            writer.close();
        } else {
            // No se encontró la venta
            response.reset();
            response.setContentType("text/html");
            out.println("<html><body><h3>Error: No se encontró la venta con ID: " + f_id_mov_vnt + "</h3></body></html>");
        }

        // Cerrar conexiones
        if (rset != null) rset.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();

    } catch (Exception e) {
        // En caso de error, limpiar respuesta y mostrar error en HTML
        try {
            response.reset();
            response.setContentType("text/html");
            out.println("<html><body>");
            out.println("<h3>Error al generar PDF:</h3>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
            out.println("<p><strong>Mensaje:</strong> " + e.getMessage() + "</p>");
            out.println("</body></html>");
        } catch (Exception ex) {
            // Si no se puede mostrar HTML, imprimir en consola
            ex.printStackTrace();
        }
    }
%>