<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<!--#include file="seguridad.asp" -->
<!--#include file="funciones.asp" -->
<%
Response.Charset = "UTF-8"

Dim usuario, clave, conn, rs, sql
Dim loginOK, storedPass, idUsuario, nombreUsuario, fotoUsuario, tipoUsuario, rolLabel

usuario = Trim("" & Request.Form("usuario"))
clave   = Trim("" & Request.Form("clave"))

If Len(usuario) = 0 Or Len(clave) = 0 Then
    Response.Redirect "login.asp?error=vacio"
End If

If Len(usuario) > 50 Or Len(clave) > 50 Then
    Response.Redirect "login.asp?error=1"
End If

Set conn = CrearConexion()

sql = "SELECT u.ID_USER, u.USERNAME, u.PASSWORD, u.USER_PHOTO, u.USER_TYPE, " & _
      "       c.VALUE AS ROL " & _
      "FROM TBL_USER u " & _
      "LEFT JOIN TBL_CATALOG c " & _
      "       ON c.COD_CATALOG_PARENT = '1' " & _
      "      AND c.COD_CATALOG = CAST(u.USER_TYPE AS varchar(8)) " & _
      "WHERE u.USERNAME = ?"

Set rs = AbrirRS(conn, sql, Array(usuario), "s")

loginOK = False

If Not rs.EOF Then
    storedPass    = "" & rs.Fields("PASSWORD").Value
    idUsuario     = CLng(rs.Fields("ID_USER").Value)
    nombreUsuario = "" & rs.Fields("USERNAME").Value
    fotoUsuario   = "" & rs.Fields("USER_PHOTO").Value
    tipoUsuario   = CLng(rs.Fields("USER_TYPE").Value)
    rolLabel      = "" & rs.Fields("ROL").Value

    ' Comparación de texto plano o SHA1
    If StrComp(storedPass, clave, vbBinaryCompare) = 0 Then
        loginOK = True
    ElseIf Len(SHA1Hex(clave)) > 0 And LCase(storedPass) = SHA1Hex(clave) Then
        loginOK = True
    End If
End If

If loginOK Then
    Session("usuario")    = nombreUsuario
    Session("id_usuario") = idUsuario
    Session("foto")       = fotoUsuario
    
    If tipoUsuario = 1 Then
        Session("rol") = "admin"
    Else
        Session("rol") = "normal"
    End If
    Session("rol_label") = rolLabel
    Session.Timeout = 60

    rs.Close
    Set rs = Nothing
    conn.Close
    Set conn = Nothing

    Response.Redirect "canciones.asp"
Else
    rs.Close
    Set rs = Nothing
    conn.Close
    Set conn = Nothing

    Response.Redirect "login.asp?error=1"
End If
%>