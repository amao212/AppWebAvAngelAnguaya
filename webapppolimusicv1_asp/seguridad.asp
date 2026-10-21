<%
'===========================================================
' ARCHIVO: seguridad.asp   (archivo de inclusión)
' DESCRIPCIÓN: Control de acceso por sesión y por rol.
'
' ROLES (campo USER_TYPE de TBL_USER, validado contra
' TBL_CATALOG donde COD_CATALOG_PARENT = '1'):
'   USER_TYPE = 1  ->  rol "admin"   (ADMIN)
'   USER_TYPE = 0  ->  rol "normal"  (USER)
'
' Las páginas protegidas llaman a RequiereSesion() y las
' páginas del CRUD además a RequiereAdmin().
'===========================================================

'-----------------------------------------------------------
' RequiereSesion: si no hay sesión activa, redirige a login.asp
'-----------------------------------------------------------
Sub RequiereSesion()
    If Len(Session("usuario")) = 0 Then
        Response.Redirect "login.asp"
    End If
End Sub

'-----------------------------------------------------------
' RequiereAdmin: sólo permite el paso al rol "admin".
' Un usuario "normal" que intente acceder directamente a
' una página restringida es redirigido al listado con un
' mensaje de acceso denegado.
'-----------------------------------------------------------
Sub RequiereAdmin()
    If Len(Session("usuario")) = 0 Then
        Response.Redirect "login.asp"
    ElseIf Session("rol") <> "admin" Then
        Response.Redirect "canciones.asp?msg=denegado"
    End If
End Sub

'-----------------------------------------------------------
' RolActual: devuelve el nombre legible del rol de la sesión
'-----------------------------------------------------------
Function RolActual()
    If Session("rol") = "admin" Then
        RolActual = "Administrador"
    Else
        RolActual = "Usuario normal"
    End If
End Function

'-----------------------------------------------------------
' EsAdmin: verdadero si el usuario de la sesión es admin
'-----------------------------------------------------------
Function EsAdmin()
    EsAdmin = (Session("rol") = "admin")
End Function
%>
