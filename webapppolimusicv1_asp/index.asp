<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<!--#include file="seguridad.asp" -->
<%
'===========================================================
' PÁGINA: index.asp
' Punto de entrada: redirige al listado si hay sesión
' activa, o al login en caso contrario.
'===========================================================
If Len(Session("usuario")) > 0 Then
    Response.Redirect "canciones.asp"
Else
    Response.Redirect "login.asp"
End If
%>
