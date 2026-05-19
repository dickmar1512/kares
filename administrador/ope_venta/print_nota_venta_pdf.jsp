<%@ page contentType="application/pdf; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.itextpdf.kernel.pdf.PdfWriter" %>
<%@ page import="com.itextpdf.kernel.pdf.PdfDocument" %>
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
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.*" %>
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
    String id_mov_vnt_value = "";

    // Ruta de la imagen del logo
    String imagePath = application.getRealPath("/assets/images/logo2.png");

    try {

        // Consultar la venta principal
        COMANDO = "select id_mov_vnt, id_personal, " +
                  "nombre(id_personal) nombre, " +
                  "dni(id_personal) docpersona, " +
                  "direccion(id_personal) direc, " +
                  "date_format(fecha,'%d/%m/%Y %H:%i') fecha, " +
                  "concat(serie,'-',lpad(numdoc,7,0)) doc, " +
                  "valor_venta as vv, " +
                  "base_imp as bi, " +
                  "descuento, " +
                  "ifnull(id_mesa,'') as mesa, " +
                  "login(id_personal_user) log_caj, " +
                  "total " +
                  "from vent_registro " +
                  "where id_mov_vnt =?";
        conn=getConexion();
        pstmt=conn.prepareStatement(COMANDO);
        pstmt.setString(1, f_id_mov_vnt);
        rset=pstmt.executeQuery();        

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
            id_mov_vnt_value = rset.getString("id_mov_vnt");

            // Configurar el PDF con tamaño personalizado (80mm x altura dinámica)
            float width = 226.77f; // 80mm en puntos
            
            // Calcular cantidad de items para altura dinámica
            int cantItems = 0;
            PreparedStatement pstmtCant = conn.prepareStatement("SELECT COUNT(*) as cant FROM vent_regdet WHERE id_mov_vnt = ? AND estado <> 'X'");
            pstmtCant.setString(1, f_id_mov_vnt);
            ResultSet rsCant = pstmtCant.executeQuery();
            if(rsCant.next()) cantItems = rsCant.getInt("cant");
            cerrar(rsCant, pstmtCant, null);
            
            float height = 550f + (cantItems * 30f); // Altura dinámica: base + margen por item
            
            PdfWriter writer = new PdfWriter(response.getOutputStream());
            PdfDocument pdfDoc = new PdfDocument(writer);
            pdfDoc.setDefaultPageSize(new PageSize(width, height));
            Document document = new Document(pdfDoc);

            // Parsear la fecha
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            Date fechaParsed = dateFormat.parse(x_fec);

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
                // Si no se encuentra el logo, no agregar espacio
            }

            // Información de la empresa
            document.add(new Paragraph("INVERSIONES MJGL E.I.R.L")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginTop(-2).setMarginBottom(1));
            document.add(new Paragraph("Calle Pevas N° 219")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(1));
            document.add(new Paragraph("Iquitos - Maynas - Loreto")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMarginBottom(9));

            // Tabla con RUC, Tipo de documento y Número (SIN fondo negro para nota de venta)
            float[] columnWidthsDoc = {1};
            Table tableDoc = new Table(columnWidthsDoc);
            tableDoc.setHorizontalAlignment(HorizontalAlignment.CENTER);
            tableDoc.addCell(new Cell().add(new Paragraph("RUC: 20541177281")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(2)));

            // Nota de venta SIN fondo negro (documento interno)
            Cell txtTipoDoc = new Cell().add(new Paragraph("NOTA DE VENTA")
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtTipoDoc.setBackgroundColor(new DeviceRgb(0, 0, 0));        
            txtTipoDoc.setBorder(new SolidBorder(1));
            tableDoc.addCell(txtTipoDoc);

            tableDoc.addCell(new Cell().add(new Paragraph(comprobante)
                    .setBold().setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMultipliedLeading(0.5f).setMargin(2)));
            document.add(tableDoc);

            // Datos del cliente
            // Datos del cliente en tabla para evitar solapamientos y mejorar alineación
            float[] colWidths = {70, 150};
            Table clientTable = new Table(colWidths);
            clientTable.setMarginTop(5);
            
            clientTable.addCell(new Cell().add(new Paragraph("FECHA EMISION:").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph(x_fec).setMultipliedLeading(1.0f)).setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("SEÑOR(ES):").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph(s_nombre).setMultipliedLeading(1.0f)).setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("N.Doc:").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph(s_dni).setMultipliedLeading(1.0f)).setFontSize(8).setBorder(Border.NO_BORDER));
            
            clientTable.addCell(new Cell().add(new Paragraph("DIRECCION:").setMultipliedLeading(1.0f)).setBold().setFontSize(8).setBorder(Border.NO_BORDER));
            clientTable.addCell(new Cell().add(new Paragraph(s_direc).setMultipliedLeading(1.0f)).setFontSize(8).setBorder(Border.NO_BORDER));
            
            document.add(clientTable);
            document.add(new Paragraph(" "));

            // Crear tabla para el detalle de productos
            float[] columnWidthsProd = {30, 120, 30, 30};
            Table tableProd = new Table(columnWidthsProd);

            // Encabezados de la tabla
            Cell txtCantidad = new Cell().add(new Paragraph("Cant.")
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

            Cell txtImporte = new Cell().add(new Paragraph("P.Unit.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtImporte.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtImporte);

            Cell txtSubtotal = new Cell().add(new Paragraph("Impo.")
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.CENTER)
                    .setFontColor(new DeviceRgb(255, 255, 255))
                    .setMultipliedLeading(0.5f).setMargin(2));
            txtSubtotal.setBackgroundColor(new DeviceRgb(0, 0, 0));
            tableProd.addCell(txtSubtotal);

            // Consultar el detalle de la venta
            try{
                COMANDO2 = "Select " +
                        "cantidad, " +
                        "glosa, ifnull(presentacion(id_articulo),'') presen, " +
                        "round(valor_venta*((100+porc_igv)/100),2) as vv, " +
                        "round((valor_venta*((100+porc_igv)/100))/cantidad,2) as vu, " +
                        "round(base_imp*((100+porc_igv)/100),2) as bi, " +
                        "round(ifnull(descuento,0)*((100+porc_igv)/100),2) as dsc, " +
                        "round(total,2) as tota " +
                        "from vent_regdet " +
                        "where id_mov_vnt = ? " +
                        "order by orden ";
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);
                pstmt2.setString(1, id_mov_vnt_value);
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
            }catch(Exception e){
                e.printStackTrace();
            }finally{
                cerrar(rset2,pstmt2,conn2);
            }          

            // Añadir la tabla de productos al documento
            document.add(tableProd);

            // Obtener total en letras
            try{                
                COMANDO2 = "Select numtxt('" + sumtot + "') tota_letra from dual ";
                conn2 = getConexion();
                pstmt2 = conn2.prepareStatement(COMANDO2);
                rset2 = pstmt2.executeQuery();
                if (rset2.next()) {
                        total_letras = "Son: " + rset2.getString("tota_letra") + " Soles.";
                }            
            }catch(Exception e){
                e.printStackTrace();
            }finally{
                cerrar(rset2,pstmt2,conn2);
            }

            // Nota de venta NO lleva código QR (documento interno)
            // Crear tabla con totales simplificados
            float[] columnWidthsTotales = {120, 5, 30};
            Table tableTotales = new Table(columnWidthsTotales);
            tableTotales.setHorizontalAlignment(HorizontalAlignment.RIGHT);
            tableTotales.setFontSize(8);
            tableTotales.setMarginTop(10);

            // Sub Total
            tableTotales.addCell(new Cell().add(new Paragraph("Sub Total").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph("S/").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumbi))
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            // Total Descuento
            tableTotales.addCell(new Cell().add(new Paragraph("Total Descuento").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph("S/").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph("0.00")
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            // Total a Pagar
            tableTotales.addCell(new Cell().add(new Paragraph("Total a Pagar").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph("S/").setBold()));
            tableTotales.addCell(new Cell().add(new Paragraph(String.format("%.2f", sumtot))
                    .setBold().setTextAlignment(TextAlignment.RIGHT)));

            document.add(tableTotales);

            // Total en letras
            document.add(new Paragraph(total_letras)
                    .setBold().setFontSize(9).setTextAlignment(TextAlignment.RIGHT)
                    .setMarginTop(5));

            // Nota: La nota de venta NO lleva mensajes legales de SUNAT
            // porque es un documento interno, no un comprobante electrónico

            // Información adicional
            document.add(new Paragraph(" "));
            document.add(new Paragraph("CAJERO     : " + x_log_caj)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            document.add(new Paragraph("MESA NRO: " + s_mesa)
                    .setBold().setFontSize(8).setMultipliedLeading(0.5f));

            // Cerrar el documento
            document.close();
        }

    } catch (Exception e) {
        out.println("<html><body><h3>Error al generar PDF:</h3><pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre></body></html>");
    }finally{
        cerrar(rset,pstmt,conn);
    }
%>
