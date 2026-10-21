<%
'===========================================================
' ARCHIVO: funciones.asp   (archivo de inclusión)
' DESCRIPCIÓN: Funciones auxiliares de la aplicación:
'   - Ejecución de SQL PARAMETRIZADO (ADODB.Command)
'   - Resolución de rutas de recursos (imágenes y mp3)
'   - Validaciones, escape de texto y utilidades JSON
'   - Mensajes de éxito/error
'===========================================================

'-----------------------------------------------------------
' EscaparTexto: escapa comillas simples para SQL.
' (Barrera secundaria; la principal es el uso de parámetros.)
'-----------------------------------------------------------
Function EscaparTexto(ByVal texto)
    If IsNull(texto) Or IsEmpty(texto) Then
        EscaparTexto = ""
    Else
        EscaparTexto = Replace(CStr(texto), "'", "''")
    End If
End Function

'-----------------------------------------------------------
' EsEntero: verdadero si el texto es un número entero válido
'-----------------------------------------------------------
Function EsEntero(ByVal valor)
    Dim s
    s = Trim("" & valor)
    EsEntero = False
    If Len(s) = 0 Then Exit Function
    If Not IsNumeric(s) Then Exit Function
    If InStr(s, ",") > 0 Or InStr(s, ".") > 0 Then Exit Function
    If CDbl(s) <> Int(CDbl(s)) Then Exit Function
    EsEntero = True
End Function



'-----------------------------------------------------------
' RutaReal: convierte una ruta de la BD ("~/songFiles/x.mp3")
' en una ruta web real dentro de la aplicación.
'-----------------------------------------------------------
Function RutaReal(ByVal rutaBD)
    If IsNull(rutaBD) Or Len("" & rutaBD) = 0 Then
        RutaReal = ""
    Else
        RutaReal = Replace("" & rutaBD, "~/", RUTA_RECURSOS & "/", 1, -1, 1)
    End If
End Function


'-----------------------------------------------------------
' ExisteArchivo: verdadero si el archivo físico existe
' Protegido contra llamadas con rutas vacías o inválidas
'-----------------------------------------------------------
Function ExisteArchivo(ByVal rutaFisica)
    Dim fso
    ExisteArchivo = False
    On Error Resume Next
    If Len(Trim("" & rutaFisica)) > 0 Then
        Set fso = Server.CreateObject("Scripting.FileSystemObject")
        ExisteArchivo = fso.FileExists(rutaFisica)
        Set fso = Nothing
    End If
    On Error GoTo 0
End Function

'-----------------------------------------------------------
' RutaImagen: ruta de una imagen con RESPALDO.
'-----------------------------------------------------------
Function RutaImagen(ByVal rutaBD, ByVal alterna)
    Dim ruta, rutaFisica
    ruta = RutaReal(rutaBD)
    RutaImagen = ""
    
    If Len(Trim("" & ruta)) > 0 Then
        On Error Resume Next
        rutaFisica = Server.MapPath(ruta)
        If Err.Number = 0 And ExisteArchivo(rutaFisica) Then
            RutaImagen = ruta
        End If
        On Error GoTo 0
    End If
    
    ' Si no existe o falló, usa el respaldo
    If Len(RutaImagen) = 0 Then
        If alterna > 0 Then
            RutaImagen = RUTA_RECURSOS & "/PlaylistImages/playlist" & alterna & ".png"
        Else
            RutaImagen = RUTA_RECURSOS & "/PlaylistImages/default.jpg"
        End If
    End If
End Function

'-----------------------------------------------------------
' RutaAudio: devuelve la ruta del mp3 SÓLO si existe
'-----------------------------------------------------------
Function RutaAudio(ByVal rutaBD)
    Dim ruta, rutaFisica
    ruta = RutaReal(rutaBD)
    RutaAudio = ""
    
    If Len(Trim("" & ruta)) > 0 Then
        On Error Resume Next
        rutaFisica = Server.MapPath(ruta)
        If Err.Number = 0 And ExisteArchivo(rutaFisica) Then
            RutaAudio = ruta
        End If
        On Error GoTo 0
    End If
End Function

'-----------------------------------------------------------
' RutaFotoUsuario: foto del usuario con respaldo a la
' imagen por defecto de la carpeta de recursos.
'-----------------------------------------------------------
Function RutaFotoUsuario(ByVal rutaBD)
    Dim ruta
    ruta = RutaReal(rutaBD)
    If Len(ruta) > 0 And ExisteArchivo(Server.MapPath(ruta)) Then
        RutaFotoUsuario = ruta
    Else
        RutaFotoUsuario = RUTA_RECURSOS & "/UserImages/default.jpg"
    End If
End Function

'-----------------------------------------------------------
' TipoParam: determina el tipo de dato de un parámetro SQL.
'   tipos = cadena con un carácter por parámetro:
'           "s" = texto (adVarChar)
'           "i" = entero (adInteger)
'   Si no se especifica, se infiere por IsNumeric (respaldado
'   por el tipo indicado en tipos).
'-----------------------------------------------------------
Function TipoParam(ByVal valor, ByVal tipos, ByVal indice)
    Dim especificado
    especificado = ""
    If Len(tipos) > indice Then especificado = Mid(tipos, indice + 1, 1)
    Select Case especificado
        Case "s": TipoParam = 200   ' adVarChar
        Case "i": TipoParam = 3     ' adInteger
        Case Else
            If IsNumeric(valor) Then TipoParam = 3 Else TipoParam = 200
    End Select
End Function

'-----------------------------------------------------------
' AgregarParametros: agrega al Command los parámetros
' recibidos en un array (en el mismo orden de los "?" del SQL).
'-----------------------------------------------------------
Sub AgregarParametros(ByVal cmd, ByVal params, ByVal tipos)
    Dim i, limite
    If Not IsArray(params) Then Exit Sub
    On Error Resume Next
    limite = UBound(params)
    If Err.Number <> 0 Then
        Err.Clear
        Exit Sub
    End If
    On Error GoTo 0
    For i = 0 To limite
        cmd.Parameters.Append cmd.CreateParameter( _
            "p" & i, TipoParam(params(i), tipos, i), 1, 255, params(i))   ' 1 = adParamInput
    Next
End Sub

'-----------------------------------------------------------
' EjecutarSQL: ejecuta INSERT/UPDATE/DELETE con parámetros.
'   conn, sql, params (array), tipos ("s","i",...)
'-----------------------------------------------------------
Sub EjecutarSQL(ByVal conn, ByVal sql, ByVal params, ByVal tipos)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = sql
    cmd.CommandType = 1          ' adCmdText
    cmd.CommandTimeout = 30
    AgregarParametros cmd, params, tipos
    cmd.Execute
End Sub

'-----------------------------------------------------------
' AbrirRS: ejecuta un SELECT con parámetros y devuelve un
' Recordset con cursor de cliente (sigue utilizable después
' de cerrar la conexión).
'-----------------------------------------------------------
Function AbrirRS(ByVal conn, ByVal sql, ByVal params, ByVal tipos)
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = sql
    cmd.CommandType = 1          ' adCmdText
    cmd.CommandTimeout = 30
    AgregarParametros cmd, params, tipos
    Set rs = cmd.Execute
    Set AbrirRS = rs
End Function

'-----------------------------------------------------------
' Escalar: devuelve el valor del primer campo de la primera
' fila (cadena vacía si no hay filas).
'-----------------------------------------------------------
Function Escalar(ByVal conn, ByVal sql, ByVal params, ByVal tipos)
    Dim rs, v
    v = ""
    Set rs = AbrirRS(conn, sql, params, tipos)
    If Not rs.EOF Then v = rs.Fields(0).Value
    rs.Close
    Set rs = Nothing
    Escalar = v
End Function

'-----------------------------------------------------------
' SqlListadoCanciones: consulta ÚNICA del listado.
' Se usan OUTER APPLY para tomar UN álbum y UN artista por
' canción (las tablas TBL_TRACKLIST y TBL_PLAYER permiten
' varios), y así mostrar NOMBRES en lugar de IDs.
'-----------------------------------------------------------
Function SqlListadoCanciones()
    SqlListadoCanciones = _
        "SELECT ROW_NUMBER() OVER (ORDER BY s.ID_SONG) AS NUM_PISTA, " & _
        "       s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "       al.ID_ALBUM, al.TITLE_ALBUM, al.ALBUM_IMAGE_PATH, " & _
        "       ar.ID_ARTIST, (ar.ARTIST_NAME + ' ' + ISNULL(ar.ARTIST_LASTNAME, '')) AS ARTISTA " & _
        "FROM TBL_SONG s " & _
        "OUTER APPLY ( " & _
        "    SELECT TOP 1 a.ID_ALBUM, a.TITLE_ALBUM, a.ALBUM_IMAGE_PATH " & _
        "    FROM TBL_TRACKLIST tl INNER JOIN TBL_ALBUM a ON a.ID_ALBUM = tl.ID_ALBUM " & _
        "    WHERE tl.ID_SONG = s.ID_SONG ORDER BY a.ID_ALBUM " & _
        ") al " & _
        "OUTER APPLY ( " & _
        "    SELECT TOP 1 p.ID_ARTIST, r.ARTIST_NAME, r.ARTIST_LASTNAME " & _
        "    FROM TBL_PLAYER p INNER JOIN TBL_ARTIST r ON r.ID_ARTIST = p.ID_ARTIST " & _
        "    WHERE p.ID_SONG = s.ID_SONG ORDER BY p.ID_ARTIST " & _
        ") ar " & _
        "ORDER BY s.ID_SONG"
End Function

'-----------------------------------------------------------
' CancionAJson: convierte la fila actual del Recordset (del
' listado) en un objeto JSON para el reproductor de JS.
'-----------------------------------------------------------
Function CancionAJson(ByVal rs)
    Dim idCancion, audio, disponible, plays
    idCancion = CLng(rs.Fields("ID_SONG").Value)
    audio = RutaAudio("" & rs.Fields("SONG_PATH").Value)
    disponible = (Len(audio) > 0)
    If IsNull(rs.Fields("PLAYS").Value) Then plays = 0 Else plays = CLng(rs.Fields("PLAYS").Value)
    CancionAJson = "{""id"":" & idCancion & _
        ",""titulo"":""" & JsEscapar("" & rs.Fields("SONG_NAME").Value) & """" & _
        ",""artista"":""" & JsEscapar("" & rs.Fields("ARTISTA").Value) & """" & _
        ",""album"":""" & JsEscapar("" & rs.Fields("TITLE_ALBUM").Value) & """" & _
        ",""portada"":""" & JsEscapar(RutaImagen("" & rs.Fields("ALBUM_IMAGE_PATH").Value, ((idCancion - 1) Mod 5) + 1)) & """" & _
        ",""src"":""" & JsEscapar(audio) & """" & _
        ",""repro"":" & SiBool(disponible) & _
        ",""plays"":" & plays & _
        ",""duracion"":0}"
End Function

'-----------------------------------------------------------
' CancionesJSON: JSON con TODAS las canciones (lo consume
' js/reproductor.js). Abre su propia conexión.
'-----------------------------------------------------------
Function CancionesJSON()
    Dim conn, rs, json
    Set conn = CrearConexion()
    Set rs = AbrirRS(conn, SqlListadoCanciones())
    conn.Close
    json = ""
    Do While Not rs.EOF
        If Len(json) > 0 Then json = json & ","
        json = json & CancionAJson(rs)
        rs.MoveNext
    Loop
    rs.Close
    CancionesJSON = json
End Function

'-----------------------------------------------------------
' JsEscapar: escapa una cadena para incrustarla de forma
' segura dentro de un literal de JavaScript (JSON).
'-----------------------------------------------------------
Function JsEscapar(ByVal texto)
    Dim s
    If IsNull(texto) Then
        JsEscapar = ""
        Exit Function
    End If
    s = "" & texto
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, "'", "\'")
    s = Replace(s, vbCrLf, "\n")
    s = Replace(s, vbCr, "\n")
    s = Replace(s, vbLf, "\n")
    s = Replace(s, vbTab, "\t")
    JsEscapar = s
End Function

'-----------------------------------------------------------
' SiBool: convierte un booleano VBScript en literal JS
'-----------------------------------------------------------
Function SiBool(ByVal valor)
    If valor Then
        SiBool = "true"
    Else
        SiBool = "false"
    End If
End Function

'-----------------------------------------------------------
' SHA1Hex / TextoABytes: hash SHA1 hexadecimal de un texto.
' TBL_USER guarda algunas contraseñas en texto claro y otras
' hasheadas (p. ej. el usuario "username1"); el login acepta
' ambos formatos. Si .NET no está disponible, devuelve "".
'-----------------------------------------------------------
Function SHA1Hex(ByVal texto)
    Dim sha1, bytes, i, hexStr
    SHA1Hex = ""
    On Error Resume Next
    Set sha1 = Server.CreateObject("System.Security.Cryptography.SHA1CryptoServiceProvider")
    If Err.Number <> 0 Then Exit Function
    bytes = sha1.ComputeHash_2(TextoABytes(texto))
    If Err.Number <> 0 Then Exit Function
    hexStr = ""
    For i = LBound(bytes) To UBound(bytes)
        hexStr = hexStr & Right("0" & Hex(bytes(i)), 2)
    Next
    SHA1Hex = LCase(hexStr)
    On Error GoTo 0
End Function

Function TextoABytes(ByVal texto)
    Dim utf8
    Set utf8 = Server.CreateObject("System.Text.UTF8Encoding")
    TextoABytes = utf8.GetBytes_4(texto)
End Function

'-----------------------------------------------------------
' Iconos SVG reutilizables (se incrustan en el HTML)
'-----------------------------------------------------------
Const ICONO_PLAY     = "<svg viewBox=""0 0 24 24"" width=""14"" height=""14"" fill=""currentColor"" aria-hidden=""true""><path d=""M8 5v14l11-7z""/></svg>"
Const ICONO_PAUSE    = "<svg viewBox=""0 0 24 24"" width=""14"" height=""14"" fill=""currentColor"" aria-hidden=""true""><path d=""M6 5h4v14H6zM14 5h4v14h-4z""/></svg>"
Const ICONO_NOTA     = "<svg viewBox=""0 0 24 24"" width=""13"" height=""13"" fill=""currentColor"" aria-hidden=""true""><path d=""M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z""/></svg>"
Const ICONO_CHECK    = "<svg viewBox=""0 0 24 24"" width=""18"" height=""18"" fill=""currentColor"" aria-hidden=""true""><path d=""M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z""/></svg>"
Const ICONO_ALERTA   = "<svg viewBox=""0 0 24 24"" width=""18"" height=""18"" fill=""currentColor"" aria-hidden=""true""><path d=""M12 2 1 21h22L12 2zm1 15h-2v-2h2v2zm0-4h-2V8h2v5z""/></svg>"

'-----------------------------------------------------------
' MostrarMensajes: muestra una alerta según el parámetro
' "msg" de la URL (mensajes de éxito/error tras cada
' operación del CRUD o accesos denegados).
'-----------------------------------------------------------
Sub MostrarMensajes()
    Dim msg, clase, texto
    msg = LCase(Trim("" & Request.QueryString("msg")))
    If Len(msg) = 0 Then Exit Sub

    Select Case msg
        Case "creado"
            clase = "exito": texto = "La canción se creó correctamente."
        Case "guardado"
            clase = "exito": texto = "La canción se actualizó correctamente."
        Case "eliminado"
            clase = "exito": texto = "La canción se eliminó correctamente."
        Case "denegado"
            clase = "error": texto = "Acceso denegado: su rol no tiene permisos para realizar esa acción."
        Case "error_datos"
            clase = "error": texto = "Datos inválidos o registro no encontrado."
        Case "error_bd"
            clase = "error": texto = "Ocurrió un error al procesar la operación en la base de datos."
        Case Else
            Exit Sub
    End Select

    Response.Write "<div class='alerta alerta-" & clase & "' id='alerta'>" & _
        "<span class='alerta-icono'>" & IIf(clase = "exito", ICONO_CHECK, ICONO_ALERTA) & "</span>" & _
        "<span class='alerta-texto'>" & texto & "</span>" & _
        "<button type='button' class='alerta-cerrar' id='alertaCerrar' aria-label='Cerrar'>&times;</button>" & _
        "</div>"
End Sub
%>
