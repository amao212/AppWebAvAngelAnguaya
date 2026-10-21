<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<!--#include file="seguridad.asp" -->
<!--#include file="funciones.asp" -->
<%
'===========================================================
' PÁGINA: cancion_form.asp  (CRUD - crear / editar canción)
' Acceso permitido SÓLO al rol "admin" (validado en el
' servidor con RequiereAdmin, más allá de ocultar los
' botones en la interfaz).
'
' El formulario se envía a esta misma página (POST) y:
'   - Valida los datos en el servidor (VBScript).
'   - Inserta o actualiza TBL_SONG.
'   - Relaciona la canción con su álbum (TBL_TRACKLIST)
'     y su artista (TBL_PLAYER), elegidos en listas
'     desplegables.
'===========================================================
RequiereAdmin()

Dim id, esEdicion, nombre, ruta, plays, idAlbum, idArtista
Dim errNombre, errRuta, errPlays, errAlbum, errArtista
Dim hayError, avisoRuta, msgOperacion
Dim idAlbumNum, idArtistaNum, playsNum

id        = 0
esEdicion = False
nombre    = ""
ruta      = ""
plays     = "0"
idAlbum   = ""
idArtista = ""
hayError  = False
avisoRuta = ""
errNombre = ""
errRuta   = ""
errPlays  = ""
errAlbum  = ""
errArtista = ""

Dim conn, rs, rsAlbumes, rsArtistas, sql
Dim esPost
esPost = (Request.ServerVariables("REQUEST_METHOD") = "POST")

'-----------------------------------------------------------
' 1) RECEPCIÓN Y VALIDACIÓN DEL FORMULARIO (POST)
'-----------------------------------------------------------
If esPost Then
    nombre  = Trim("" & Request.Form("nombre"))
    ruta    = Trim("" & Request.Form("ruta"))
    plays   = Trim("" & Request.Form("plays"))
    idAlbum = Trim("" & Request.Form("album"))
    idArtista = Trim("" & Request.Form("artista"))

    Dim idForm
    ' El campo oculto "id" sólo indica edición cuando es mayor que 0
    ' (en modo creación se envía id=0).
    If EsEntero("" & Request.Form("id")) Then
        idForm = CLng(Request.Form("id"))
        If idForm > 0 Then
            id = idForm
            esEdicion = True
        End If
    End If

    ' --- Validaciones en servidor ---
    If Len(nombre) = 0 Or Len(nombre) > 50 Then
        errNombre = "El nombre es obligatorio (máximo 50 caracteres)."
        hayError = True
    End If
    If Len(ruta) = 0 Or Len(ruta) > 255 Then
        errRuta = "La ruta del archivo mp3 es obligatoria (máximo 255 caracteres)."
        hayError = True
    End If
    ' (VBScript no evalúa en corto circuito: se comprueba EsEntero antes de convertir)
    If Not EsEntero(plays) Then
        errPlays = "Las reproducciones deben ser un número entero mayor o igual a 0."
        hayError = True
    ElseIf CLng(plays) < 0 Then
        errPlays = "Las reproducciones deben ser un número entero mayor o igual a 0."
        hayError = True
    End If
    If Not EsEntero(idAlbum) Then
        errAlbum = "Debe seleccionar un álbum."
        hayError = True
    End If
    If Not EsEntero(idArtista) Then
        errArtista = "Debe seleccionar un artista."
        hayError = True
    End If

    ' --- Si todo está bien, se guarda ---
    If Not hayError Then
        idAlbumNum = CLng(idAlbum)
        idArtistaNum = CLng(idArtista)
        playsNum = CLng(plays)

        Set conn = CrearConexion()

        Dim errorGrabado
        errorGrabado = False

        ' Si es edición, verificar que la canción exista
        If esEdicion Then
            If CLng(Escalar(conn, "SELECT COUNT(*) FROM TBL_SONG WHERE ID_SONG = ?", Array(id), "i")) = 0 Then
                conn.Close
                Response.Redirect "canciones.asp?msg=error_datos"
            End If
        End If

        ' --- Transacción: canción + relaciones ---
        On Error Resume Next
        conn.BeginTrans

        If esEdicion Then
            EjecutarSQL conn, _
                "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?", _
                Array(nombre, ruta, playsNum, id), "ssii"
            If Err.Number <> 0 Then errorGrabado = True
            If Not errorGrabado Then
                ' Se eliminan las relaciones anteriores y se recrean con la selección actual
                EjecutarSQL conn, "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id), "i"
                If Err.Number <> 0 Then errorGrabado = True
            End If
            If Not errorGrabado Then
                EjecutarSQL conn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id), "i"
                If Err.Number <> 0 Then errorGrabado = True
            End If
        Else
            ' INSERT con devolución del ID generado (SCOPE_IDENTITY)
            Set rs = AbrirRS(conn, _
                "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?); " & _
                "SELECT SCOPE_IDENTITY() AS NUEVO_ID;", _
                Array(nombre, ruta, playsNum), "ssi")
            If Err.Number <> 0 Then
                errorGrabado = True
            Else
                id = CLng(rs.Fields(0).Value)
                rs.Close
            End If
        End If

        ' Relación canción-álbum (TBL_TRACKLIST)
        If Not errorGrabado Then
            EjecutarSQL conn, _
                "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", _
                Array(idAlbumNum, id), "ii"
            If Err.Number <> 0 Then errorGrabado = True
        End If

        ' Relación artista-canción (TBL_PLAYER)
        If Not errorGrabado Then
            EjecutarSQL conn, _
                "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", _
                Array(id, idArtistaNum), "ii"
            If Err.Number <> 0 Then errorGrabado = True
        End If

        If errorGrabado Then
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
            If esEdicion Then
                Response.Redirect "canciones.asp?msg=guardado"
            Else
                Response.Redirect "canciones.asp?msg=creado"
            End If
        End If
    End If
End If

'-----------------------------------------------------------
' 2) MODO VISUALIZACIÓN (GET): carga los datos de la canción
'-----------------------------------------------------------
If Not esPost Then
    If EsEntero("" & Request.QueryString("id")) Then
        id = CLng(Request.QueryString("id"))
        esEdicion = True
    End If
End If

Set conn = CrearConexion()

If esEdicion And Not hayError And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Set rs = AbrirRS(conn, _
        "SELECT SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG WHERE ID_SONG = ?", _
        Array(id), "i")
    If rs.EOF Then
        rs.Close
        conn.Close
        Response.Redirect "canciones.asp?msg=error_datos"
    End If
    nombre = "" & rs.Fields("SONG_NAME").Value
    ruta   = "" & rs.Fields("SONG_PATH").Value
    If IsNull(rs.Fields("PLAYS").Value) Then plays = "0" Else plays = "" & rs.Fields("PLAYS").Value
    rs.Close

    Dim albumActual, artistaActual
    albumActual = Escalar(conn, "SELECT TOP 1 ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id), "i")
    If EsEntero(albumActual) Then idAlbum = "" & CLng(albumActual)
    artistaActual = Escalar(conn, "SELECT TOP 1 ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id), "i")
    If EsEntero(artistaActual) Then idArtista = "" & CLng(artistaActual)
End If

'-----------------------------------------------------------
' 3) LISTAS DESPLEGABLES de entidades relacionadas
'-----------------------------------------------------------
Dim opcAlbum, opcArtista, sel
opcAlbum = "<option value=''>— Seleccione un álbum —</option>"
Set rsAlbumes = AbrirRS(conn, "SELECT ID_ALBUM, TITLE_ALBUM FROM TBL_ALBUM ORDER BY TITLE_ALBUM")
Do While Not rsAlbumes.EOF
    sel = ""
    If EsEntero(idAlbum) And CLng(rsAlbumes.Fields("ID_ALBUM").Value) = CLng(idAlbum) Then sel = " selected"
    opcAlbum = opcAlbum & "<option value='" & rsAlbumes.Fields("ID_ALBUM").Value & "'" & sel & ">" & _
        Server.HTMLEncode("" & rsAlbumes.Fields("TITLE_ALBUM").Value) & " (" & _
        "" & rsAlbumes.Fields("ID_ALBUM").Value & ")</option>"
    rsAlbumes.MoveNext
Loop
rsAlbumes.Close

opcArtista = "<option value=''>— Seleccione un artista —</option>"
Set rsArtistas = AbrirRS(conn, "SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME")
Do While Not rsArtistas.EOF
    sel = ""
    If EsEntero(idArtista) And CLng(rsArtistas.Fields("ID_ARTIST").Value) = CLng(idArtista) Then sel = " selected"
    opcArtista = opcArtista & "<option value='" & rsArtistas.Fields("ID_ARTIST").Value & "'" & sel & ">" & _
        Server.HTMLEncode("" & rsArtistas.Fields("ARTIST_NAME").Value & " " & rsArtistas.Fields("ARTIST_LASTNAME").Value) & "</option>"
    rsArtistas.MoveNext
Loop
rsArtistas.Close
conn.Close

'-----------------------------------------------------------
' 4) ARCHIVOS MP3 REALMENTE DISPONIBLES (ayuda para el usuario)
'-----------------------------------------------------------
Dim fso, carpetaMp3, archivo, listaMp3
listaMp3 = ""
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If fso.FolderExists(Server.MapPath(RUTA_RECURSOS & "/SongFiles")) Then
    Set carpetaMp3 = fso.GetFolder(Server.MapPath(RUTA_RECURSOS & "/SongFiles"))
    For Each archivo In carpetaMp3.Files
        If LCase(fso.GetExtensionName(archivo.Name)) = "mp3" Then
            listaMp3 = listaMp3 & "<li><code>~/songFiles/" & Server.HTMLEncode(archivo.Name) & "</code></li>"
        End If
    Next
End If

' Aviso (no bloqueante) si la ruta indicada no existe en la carpeta de recursos
If Len(ruta) > 0 And RutaAudio(ruta) = "" Then
    avisoRuta = "El archivo indicado no existe actualmente en la carpeta de recursos: la canción no se podrá reproducir hasta que el mp3 esté disponible."
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic — <%= IIf(esEdicion, "Editar canción", "Nueva canción") %></title>
    <link rel="icon" type="image/svg+xml" href="img/logo.svg">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
<div class="app">

    <!--#include file="inc/sidebar.asp" -->

    <main class="contenido">
        <header class="bienvenida">
            <p class="saludo">Bienvenido, <strong><%= Server.HTMLEncode(Session("usuario")) %></strong></p>
            <span class="badge-rol">Rol: <%= RolActual() %></span>
            <h1 class="titulo-seccion"><%= IIf(esEdicion, "Editar canción", "Nueva canción") %></h1>
            <p class="subtitulo">Complete los datos de la canción. Los campos marcados son obligatorios.</p>
        </header>

        <% If hayError Then %>
        <div class="alerta alerta-error">
            <span class="alerta-icono">
                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2 1 21h22L12 2zm1 15h-2v-2h2v2zm0-4h-2V8h2v5z"/></svg>
            </span>
            <span class="alerta-texto">Corrija los datos marcados antes de guardar.</span>
        </div>
        <% End If %>

        <section class="formulario-tarjeta">
            <h2><%= IIf(esEdicion, "Editar canción", "Registrar canción") %></h2>
            <p class="ayuda">La canción se relaciona con un álbum (TBL_TRACKLIST) y un artista (TBL_PLAYER).</p>

            <form id="formCancion" action="cancion_form.asp" method="post" novalidate>
                <input type="hidden" name="id" value="<%= id %>">

                <div class="campo<%= IIf(errNombre <> "", " con-error", "") %>">
                    <label for="nombre">Nombre de la canción *</label>
                    <input type="text" id="nombre" name="nombre" maxlength="50"
                           value="<%= Server.HTMLEncode(nombre) %>" placeholder="Ej: Adventure" required>
                    <% If errNombre <> "" Then %><span class="campo-error"><%= errNombre %></span><% End If %>
                </div>

                <div class="campo<%= IIf(errRuta <> "", " con-error", "") %>">
                    <label for="ruta">Ruta del archivo mp3 *</label>
                    <input type="text" id="ruta" name="ruta" maxlength="255"
                           value="<%= Server.HTMLEncode(ruta) %>" placeholder="~/songFiles/bensound-adventure.mp3" required>
                    <% If errRuta <> "" Then %><span class="campo-error"><%= errRuta %></span><% End If %>
                    <% If avisoRuta <> "" Then %><span class="advertencia-campo"><%= avisoRuta %></span><% End If %>
                    <% If listaMp3 <> "" Then %>
                    <span class="nota-campo">Archivos mp3 disponibles en la carpeta de recursos:</span>
                    <ul class="lista-ayuda"><%= listaMp3 %></ul>
                    <% End If %>
                </div>

                <div class="campo<%= IIf(errPlays <> "", " con-error", "") %>">
                    <label for="plays">Reproducciones</label>
                    <input type="text" id="plays" name="plays" maxlength="9"
                           value="<%= Server.HTMLEncode(plays) %>" placeholder="0">
                    <% If errPlays <> "" Then %><span class="campo-error"><%= errPlays %></span><% End If %>
                    <span class="nota-campo">Número entero mayor o igual a 0.</span>
                </div>

                <div class="campo<%= IIf(errAlbum <> "", " con-error", "") %>">
                    <label for="album">Álbum *</label>
                    <select id="album" name="album">
                        <%= opcAlbum %>
                    </select>
                    <% If errAlbum <> "" Then %><span class="campo-error"><%= errAlbum %></span><% End If %>
                </div>

                <div class="campo<%= IIf(errArtista <> "", " con-error", "") %>">
                    <label for="artista">Artista *</label>
                    <select id="artista" name="artista">
                        <%= opcArtista %>
                    </select>
                    <% If errArtista <> "" Then %><span class="campo-error"><%= errArtista %></span><% End If %>
                </div>

                <div class="form-acciones">
                    <button type="submit" class="btn btn-primario">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
                        Guardar
                    </button>
                    <a class="btn btn-secundario" href="canciones.asp">Cancelar</a>
                </div>
            </form>
        </section>
    </main>
</div>

<!--#include file="inc/reproductor.asp" -->

<script>
    // ---- Validación en cliente del formulario de canciones ----
    document.getElementById("formCancion").addEventListener("submit", function (e) {
        var ok = true;
        var nombre  = document.getElementById("nombre").value.trim();
        var ruta    = document.getElementById("ruta").value.trim();
        var plays   = document.getElementById("plays").value.trim();
        var album   = document.getElementById("album").value;
        var artista = document.getElementById("artista").value;

        limpiar();

        if (nombre.length === 0 || nombre.length > 50) {
            marcar("nombre", "Ingrese un nombre de 1 a 50 caracteres."); ok = false;
        }
        if (ruta.length === 0 || ruta.length > 255) {
            marcar("ruta", "Ingrese la ruta del archivo mp3 (1 a 255 caracteres)."); ok = false;
        }
        if (!/^\d+$/.test(plays)) {
            marcar("plays", "Las reproducciones deben ser un número entero mayor o igual a 0."); ok = false;
        }
        if (album === "") {
            marcar("album", "Seleccione un álbum."); ok = false;
        }
        if (artista === "") {
            marcar("artista", "Seleccione un artista."); ok = false;
        }
        if (!ok) { e.preventDefault(); }
    });

    // Muestra el error bajo el campo indicado
    function marcar(idInput, mensaje) {
        var input = document.getElementById(idInput);
        if (!input) { return; }
        var contenedor = input.closest(".campo");
        if (!contenedor) { return; }
        contenedor.classList.add("con-error");
        var span = document.createElement("span");
        span.className = "campo-error";
        span.textContent = mensaje;
        contenedor.appendChild(span);
    }

    function limpiar() {
        var errores = document.querySelectorAll(".campo-error");
        for (var i = 0; i < errores.length; i++) { errores[i].remove(); }
        var campos = document.querySelectorAll(".campo.con-error");
        for (var j = 0; j < campos.length; j++) { campos[j].classList.remove("con-error"); }
    }
</script>
</body>
</html>
