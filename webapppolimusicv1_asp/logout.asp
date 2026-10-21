<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<%
'===========================================================
' PÁGINA: logout.asp
' Destruye la sesión actual (Session.Abandon) y regresa al
' formulario de inicio de sesión.
'===========================================================
Session.Abandon
Response.Redirect "login.asp"
%>
