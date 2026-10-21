<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<!--#include file="seguridad.asp" -->
<!--#include file="funciones.asp" -->
<%
'===========================================================
' PÁGINA: cancion_eliminar.asp  (CRUD - eliminar canción)
' Acceso permitido SÓLO al rol "admin" (validado en el
' servidor). La confirmación al usuario se hace en JavaScript
' (confirm) desde canciones.asp antes de llegar aquí.
'
' Al eliminar una canción se borran primero sus relaciones
' (TBL_TRACKLIST, TBL_PLAYER, TBL_PLAYLIST_SONG) para no
' violar las llaves foráneas, todo dentro de una transacción.
'===========================================================
RequiereAdmin()

Dim idTxt, id, conn, existe
idTxt = "" & Request.QueryString("id")

' --- Validación en servidor del identificador ---
If Not EsEntero(idTxt) Then
    Response.Redirect "canciones.asp?msg=error_datos"
End If
id = CLng(idTxt)

Set conn = CrearConexion()

' --- Verificar que la canción exista ---
existe = Escalar(conn, "SELECT COUNT(*) FROM TBL_SONG WHERE ID_SONG = ?", Array(id), "i")
If CLng(existe) = 0 Then
    conn.Close
    Response.Redirect "canciones.asp?msg=error_datos"
End If

' --- Eliminación dentro de una transacción ---
Dim errorBorrado
errorBorrado = False

On Error Resume Next
conn.BeginTrans

' Relaciones de la canción (llaves foráneas)
EjecutarSQL conn, "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id), "i"
If Err.Number <> 0 Then errorBorrado = True
If Not errorBorrado Then
    EjecutarSQL conn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id), "i"
    If Err.Number <> 0 Then errorBorrado = True
End If
If Not errorBorrado Then
    EjecutarSQL conn, "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(id), "i"
    If Err.Number <> 0 Then errorBorrado = True
End If
' Finalmente la canción
If Not errorBorrado Then
    EjecutarSQL conn, "DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(id), "i"
    If Err.Number <> 0 Then errorBorrado = True
End If

If errorBorrado Then
    Err.Clear
    On Error Resume Next
    conn.RollbackTrans
    conn.Close
    On Error GoTo 0
    Response.Redirect "canciones.asp?msg=error_bd"
Else
    conn.CommitTrans
    conn.Close
    On Error GoTo 0
    Response.Redirect "canciones.asp?msg=eliminado"
End If
%>
