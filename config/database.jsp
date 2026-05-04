<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>

<%!
    // ============================================================
    // MÉTODOS DECLARADOS - disponibles en todo el JSP que lo incluya
    // ============================================================

    // Obtiene una conexión del pool
    public Connection getConexion() {
        try {
            Context    ctx = new InitialContext();
            DataSource ds  = (DataSource) ctx.lookup("java:comp/env/jdbc/dbkares");
            return ds.getConnection();
        } catch (Exception e) {
            System.out.println("ERROR getConexion: " + e.getMessage());
            return null;
        }
    }

    // Cierra ResultSet
    public void cerrar(ResultSet rset) {
        if (rset != null) try { rset.close(); } catch (Exception e) {}
    }

    // Cierra Statement o PreparedStatement
    public void cerrar(Statement stmt) {
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
    }

    // Cierra Connection (la devuelve al pool)
    public void cerrar(Connection conn) {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    // Cierra todo junto: ResultSet + Statement + Connection
    public void cerrar(ResultSet rset, PreparedStatement pstmt, Connection conn) {
        if (rset != null) try { rset.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    //Prametros de conexión reutilizables
    Connection  conn  = null;
    Statement   stmt  = null;
    ResultSet   rset  = null;

    Connection  conn2 = null;
    Statement   stmt2 = null;
    ResultSet   rset2 = null;

    Connection  conn3 = null;
    Statement   stmt3 = null;
    ResultSet   rset3 = null;

    Connection  conn4 = null;
    Statement   stmt4 = null;
    ResultSet   rset4 = null;

    PreparedStatement pstmt = null;
    PreparedStatement pstmt2 = null;
    PreparedStatement pstmt3 = null;
    PreparedStatement pstmt4 = null;

    String COMANDO   = "";
    String COMANDO2  = "";
    String COMANDO3  = "";
    String COMANDO4  = "";

    int upd   = 0;
    int band  = 0;
    int band2 = 0;

    // ============================================================
    // FORMATEADORES - disponibles en todo el JSP que lo incluya
    // ============================================================
    DecimalFormat formateador  = new DecimalFormat("##########0.00 ; (-###0.00)");
    DecimalFormat formateador1 = new DecimalFormat("##########0.00");
    DecimalFormat formateador2 = new DecimalFormat("#####,###,##0.00");

    // Variables de fecha
    Date          dt           = new Date();
    SimpleDateFormat sdf1       = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdf2       = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfHora   = new SimpleDateFormat("HH:mm:ss");
%>
