<!--#include file="conexion.asp" -->
<%
Dim testConn
Set testConn = CrearConexion()
Response.Write "<h2 style='color:green'>¡Conexión a SQL Server exitosa!</h2>"
testConn.Close
Set testConn = Nothing
%>