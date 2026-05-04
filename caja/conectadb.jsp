<%@ page import="java.sql.*" %>
<%@ page import="java.io.*"  %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.sql.*,javax.naming.*" %>

<%

Connection  conn  = null;
Statement   stmt  = null;
ResultSet   rset  = null;
Connection  conn2 = null;
Statement   stmt2 = null;
ResultSet   rset2 = null;
int upd           = 0;
PreparedStatement pstmt = null;
Date dt		= new Date();
	
Class.forName("com.mysql.jdbc.Driver");

conn = DriverManager.getConnection("jdbc:mysql://localhost/dbkares","milenio","armagedon");
stmt = conn.createStatement();

conn2 = DriverManager.getConnection("jdbc:mysql://localhost/dbkares","milenio","armagedon");
stmt2 = conn2.createStatement();
	
String COMANDO  = "";
String COMANDO2  = "";
DecimalFormat formateador  = new DecimalFormat("##########0.00 ; (-###0.00)");
DecimalFormat formateador1 = new DecimalFormat("##########0.00"); 
DecimalFormat formateador2 = new DecimalFormat("#####,###,##0.00"); 

int band = 0;
%>


