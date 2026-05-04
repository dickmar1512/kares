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
<%@ page import="com.itextpdf.barcodes.BarcodeQRCode" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.util.Date" %>
<%-- <%@ page import="jakarta.servlet.ServletException" %> --%>
<%@ include file="../../config/database.jsp"%>
<%@ include file="id.jsp"%>
<%@ include file="../seguro.jsp" %>

<%
    // Obtener el parámetro id_venta desde la URL
    String f_id_mov_vnt = request.getParameter("f_id_mov_vnt");

    // Variables para almacenar datos de la venta
    String x_fec = "";
    String comprobante = "";
    String s_mesa = "";
    Double sumbi = 0.0;
    Double sumtot = 0.0;
    String total_letras = "";
    String x_log_caj = "";
    String s_nombre = "";
    String s_dni = "";
    String s_direc = "";

    // Ruta de la imagen del logo
    String imagePath = application.getRealPath("/assets/images/logo2.png");

    try {
        // Consultar la venta principal
        COMANDO = "select id_mov_vnt, id_personal, " +
                  "(case when tipo_doc = '39' then razon else nombre(id_personal) end) nombre, " +
                  "(case when tipo_doc = '39' then ruc else dni(id_personal) end) docpersona, " +
                  "direccion(id_personal) direc, " +
                  "date_format(fecha,'%d/%m/%Y %H:%i') fecha, " +
                  "concat(serie,'-',lpad(numdoc,7,0)) doc, " +
                  "valor_venta as vv, " +
                  "base_imp as bi, " +
                  "descuento, " +
                  "id_mesa as mesa, " +
                  "login(id_personal_user) log_caj, " +
                  "total " +
                  "from vent_registro " +
                  "where id_mov_vnt ='" + f_id_mov_vnt + "'";
        conn = getConexion();
        pstmt = conn.prepareStatement(COMANDO);
        rset = pstmt.executeQuery();

        if (rset.next()) {
            sumbi = rset.getDouble("bi");
            sumtot = rset.getDouble("total");
            comprobante = rset.getString("doc");
            x_fec = rset.getString("fecha");
            s_mesa = rset.getString("mesa");
            x_log_caj = rset.getString("log_caj");
            s_nombre = rset.getString("nombre");
            s_dni = rset.getString("docpersona");
            s_direc = rset.getString("direc");

            // Configurar el PDF con tamaño personalizado (80mm x altura dinámica)
            float width = 226.77f; // 80mm en puntos
            float height = 842f; // Altura inicial
            
            PdfWriter writer = new PdfWriter(response.getOutputStream());
            PdfDocument pdfDoc = new PdfDocument(writer);
            pdfDoc.setDefaultPageSize(new PageSize(width, height));
            Document document = new Document(pdfDoc);

            // Obtener y parsear la fecha
            //String fechaStr = rset2.getString("fecha");
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            Date fechaFormateada = dateFormat.parse(x_fec);

            // Configurar márgenes del documento
            document.setMargins(5, 5, 5, 5);

            // Agregar logo
            try {
                Image img = new Image(ImageDataFactory.create(imagePath));
                img.setWidth(150);
                img.setHorizontalAlignment(HorizontalAlignment.CENTER);
                document.add(img);
            } catch (Exception e) {
                // Si no se encuentra el logo, continuar sin él
                document.add(new Paragraph(" "));
            }

            // Información de la empresa
            document.add(new Paragraph("INVERSIONES MJGL E.I.R.L")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("Calle Pevas N° 219")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("Cel.: 995089676")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("Iquitos - Maynas - Loreto")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph(" "));

            // Tabla con RUC, Tipo de documento y Número
            float[] columnWidthsDoc = {1};
            Table tableDoc = new Table(columnWidthsDoc);
            tableDoc.setHorizontalAlignment(HorizontalAlignment.CENTER);
            tableDoc.addCell(new Cell().add(new Paragraph("RUC: 20541177281")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(3)));

            Cell txtTipoDoc = new Cell().add(new Paragraph("BOLETA ELECTRONICA")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(3));
            txtTipoDoc.setBackgroundColor(new DeviceRgb(0, 0, 0));
            txtTipoDoc.setBorder(new SolidBorder(1));
            tableDoc.addCell(txtTipoDoc);

            tableDoc.addCell(new Cell().add(new Paragraph(comprobante)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(3)));
            document.add(tableDoc);

            // Datos del cliente
            document.add(new Paragraph(" "));
            document.add(new Paragraph("FECHA EMISION: " + dateFormat.format(fechaFormateada))
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.LEFT)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("SEÑOR(ES)        : " + s_nombre)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.LEFT)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("DNI N°                 : " + s_dni)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.LEFT)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph("DIRECCION        : " + s_direc)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.LEFT)
                    .setMultipliedLeading(0.5f).setMarginBottom(3));
            document.add(new Paragraph(" "));

            // Crear tabla para el detalle de productos
            float[] columnWidthsProd = {30, 120, 30, 30};
            Table tableProd = new Table(columnWidthsProd);

            // Encabezados de la tabla
            Cell txtCantidad = new Cell().add(new Paragraph("Cant.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(3));
            txtCantidad.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtCantidad);

            Cell txtDescripcion = new Cell().add(new Paragraph("Descripcion")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.LEFT)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(3));
            txtDescripcion.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtDescripcion);

            Cell txtImporte = new Cell().add(new Paragraph("Importe")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(3));
            txtImporte.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtImporte);

            Cell txtSubtotal = new Cell().add(new Paragraph("SubTot.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(3));
            txtSubtotal.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtSubtotal);

            // Consultar el detalle de la venta
            try {
                COMANDO2 = "Select " +
                        "sum(cantidad) as cantidad, " +
                        "glosa, ifnull(presentacion(id_articulo),'') presen, " +
                        "round(valor_venta*((100+porc_igv)/100),2) as vv, " +
                        "round((valor_venta*((100+porc_igv)/100))/cantidad,2) as vu, " +
                        "round(base_imp*((100+porc_igv)/100),2) as bi, " +
                        "sum(round(ifnull(descuento,0)*((100+porc_igv)/100),2)) as dsc, " +
                        "sum(round(total,2)) as tota " +
                        "from vent_regdet " +
                        "where id_mov_vnt = '" + rset.getString("id_mov_vnt") + "' " +
                        "GROUP BY glosa, presen, vv, vu, bi ";
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);
                rset2 = pstmt2.executeQuery();
                while (rset2.next()) {
                        int cantidad = rset2.getInt("cantidad");
                        String producto = rset2.getString("glosa");
                        double precio = rset2.getDouble("vu");
                        double subtotal = rset2.getDouble("tota");

                        tableProd.addCell(new Cell().add(new Paragraph(String.valueOf(cantidad))
                                .setFontSize(8).setTextAlignment(TextAlignment.CENTER)));
                        tableProd.addCell(new Cell().add(new Paragraph(producto)
                                .setFontSize(8)));
                        tableProd.addCell(new Cell().add(new Paragraph(String.format("%.2f", precio))
                                .setFontSize(8).setTextAlignment(TextAlignment.RIGHT)));
                        tableProd.addCell(new Cell().add(new Paragraph(String.format("%.2f", subtotal))
                                .setFontSize(8).setTextAlignment(TextAlignment.RIGHT)));
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                cerrar(rset2, pstmt2, conn2); 
            }

            // Añadir la tabla de productos al documento
            document.add(tableProd);

            // Obtener total en letras
            try {
                COMANDO2 = "Select numtxt('" + sumtot + "') tota_letra from dual ";
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);   
                rset2 = pstmt2.executeQuery();
                if (rset2.next()) {
                    total_letras = "Son: " + rset2.getString("tota_letra") + " Soles.";
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                cerrar(rset2, pstmt2, conn2); 
            }

            // Generar código QR
            String qrText = "20541177281|03|" + comprobante + "|0.00|" + sumtot + "|" + x_fec + "|";
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
            nestedTable.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumbi))
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
            nestedTable.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumtot))
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            Cell nestedTableCell = new Cell().add(nestedTable);
            tableMain.addCell(nestedTableCell);

            document.add(tableMain);

            // Total en letras
            document.add(new Paragraph(total_letras)
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.RIGHT));

            // Mensajes legales
            document.add(new Paragraph("Consulte y/o descargue su comprobante electrónico en www.sunat.gob.pe, utilizando su clave SOL")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER));

            document.add(new Paragraph("Autorizado para ser emisor electrónico mediante la Resolución de Superintendencia N° 155-2017")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER));

            // Información adicional
            document.add(new Paragraph("CAJERO     : " + x_log_caj)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            document.add(new Paragraph("MESA NRO: " + s_mesa)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            // Cerrar el documento
            document.close();
        }     

    } catch (Exception e) {
        throw new ServletException("Error al generar PDF: " + e.getMessage(), e);
    }finally {
        cerrar(rset, pstmt, conn); 
    }
%>
