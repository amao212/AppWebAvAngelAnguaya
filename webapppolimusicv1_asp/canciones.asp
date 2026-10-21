<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<!--#include file="seguridad.asp" -->
<!--#include file="funciones.asp" -->
<%
'===========================================================
' PÁGINA: canciones.asp  (página principal)
' Listado de canciones estilo Spotify.
' - Requiere sesión activa (RequiereSesion).
' - Muestra: bienvenida con el usuario de la sesión, rol,
'   título "Song List" y las canciones con número de pista,
'   portada, título, artista, álbum, reproducciones y duración.
' - Los botones de administración (nueva/editar/eliminar) sólo
'   se muestran si Session("rol") = "admin" (y además se
'   validan en el servidor en las páginas del CRUD).
'===========================================================
RequiereSesion()

'-----------------------------------------------------------
' Consulta del listado (JOINs para mostrar nombres, no IDs)
'-----------------------------------------------------------
Dim conn, rs, filas, total, admin, sqlSongs
Set conn = CrearConexion()

' Si la función SqlListadoCanciones() existe la usamos, si no, aplicamos la consulta directa a BDD_PoliMusic
On Error Resume Next
sqlSongs = SqlListadoCanciones()
If Err.Number <> 0 Or Len(sqlSongs) = 0 Then
    sqlSongs = "SELECT s.ID_SONG, s.NUM_PISTA, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
               "       a.TITLE_ALBUM, a.ALBUM_IMAGE_PATH, ar.NAME AS ARTISTA " & _
               "FROM TBL_SONG s " & _
               "LEFT JOIN TBL_ALBUM a ON s.ID_ALBUM = a.ID_ALBUM " & _
               "LEFT JOIN TBL_ARTIST ar ON s.ID_ARTIST = ar.ID_ARTIST " & _
               "ORDER BY s.NUM_PISTA ASC"
End If
On Error GoTo 0

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sqlSongs, conn, 1, 1   ' Abrir con cursor de lectura

admin = False
If Session("rol") = "admin" Then admin = True
filas = ""
total = 0

Do While Not rs.EOF
    Dim idx, numPista, idCancion, titulo, artista, album, portada, audio, okAttr, plays
    idx       = total
    numPista  = rs.Fields("NUM_PISTA").Value
    idCancion = CLng(rs.Fields("ID_SONG").Value)
    titulo    = "" & rs.Fields("SONG_NAME").Value
    artista   = "" & rs.Fields("ARTISTA").Value
    album     = "" & rs.Fields("TITLE_ALBUM").Value
    portada   = RutaImagen("" & rs.Fields("ALBUM_IMAGE_PATH").Value, ((idCancion - 1) Mod 5) + 1)
    audio     = RutaAudio("" & rs.Fields("SONG_PATH").Value)
    okAttr    = "1"
    If Len(audio) = 0 Then okAttr = "0"
    plays     = 0
    If Not IsNull(rs.Fields("PLAYS").Value) Then plays = CLng(rs.Fields("PLAYS").Value)

    filas = filas & "<div class='cancion' data-idx='" & idx & "'>"

    ' Número de pista -> ícono de play al pasar el mouse (CSS)
    filas = filas & "<div class='col-num'>" & _
        "<span class='num'>" & numPista & "</span>" & _
        "<span class='ico-play'>" & ICONO_PLAY & "</span>" & _
        "<span class='ico-pause'>" & ICONO_PAUSE & "</span>" & _
        "<span class='eq'><span></span><span></span><span></span></span>" & _
        "</div>"

    ' Portada + título + artista
    filas = filas & "<div class='col-titulo'>" & _
        "<img class='portada' src='" & portada & "' alt='Portada de " & Server.HTMLEncode(titulo) & "'>" & _
        "<div class='info'>" & _
        "<span class='titulo'>" & Server.HTMLEncode(titulo) & "</span>" & _
        "<span class='artista'>" & Server.HTMLEncode(artista) & "</span>" & _
        "</div></div>"

    ' Álbum
    filas = filas & "<div class='col-album'>" & Server.HTMLEncode(album) & "</div>"

    ' Reproducciones
    filas = filas & "<div class='col-repro' title='Reproducciones'>" & _
        "<span class='ico-nota'>" & ICONO_NOTA & "</span>" & plays & "</div>"

    ' Duración (se llena con JS leyendo los metadatos del mp3)
    filas = filas & "<div class='col-dur'>" & _
        "<span class='duracion' data-idx='" & idx & "' data-src='" & audio & "' data-ok='" & okAttr & "'>--:--</span>" & _
        "</div>"

    ' Acciones de administración (solo rol admin)
    If admin Then
        filas = filas & "<div class='col-acciones'>" & _
            "<a class='btn-icono' href='cancion_form.asp?id=" & idCancion & "' title='Editar canción'>" & _
            "<svg viewBox='0 0 24 24' width='16' height='16' fill='currentColor'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z'/></svg>" & _
            "</a>" & _
            "<a class='btn-icono peligro' href='cancion_eliminar.asp?id=" & idCancion & "' title='Eliminar canción' " & _
            "onclick='return confirm'(""¿Está seguro de eliminar esta canción? Esta acción no se puede deshacer."")'>" & _
            "<svg viewBox='0 0 24 24' width='16' height='16' fill='currentColor'><path d='M6 19a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z'/></svg>" & _
            "</a></div>"
    End If

    filas = filas & "</div>"
    total = total + 1
    rs.MoveNext
Loop
rs.Close
Set rs = Nothing
conn.Close
Set conn = Nothing
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic — Song List</title>
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
            <h1 class="titulo-seccion">Song List</h1>
            <p class="subtitulo">Listado de canciones disponibles en la plataforma — <%= total %> canción(es) registradas</p>
        </header>

        <% MostrarMensajes() %>

        <div class="barra-acciones">
            <button type="button" class="btn-reproducir-todo" id="btnReproducirTodo" title="Reproducir" aria-label="Reproducir">
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
            </button>
            <% If admin Then %>
            <a class="btn btn-primario" href="cancion_form.asp">
                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6z"/></svg>
                Nueva canción
            </a>
            <% End If %>
        </div>

        <section class="listado<% If admin Then Response.Write " listado-admin" %>">
            <div class="listado-cabecera">
                <span>#</span>
                <span>TÍTULO</span>
                <span class="col-album-cab">ÁLBUM</span>
                <span class="col-repro-cab">REPRODUCCIONES</span>
                <span class="col-dur-cab">DURACIÓN</span>
                <% If admin Then %><span class="col-acc-cab">ACCIONES</span><% End If %>
            </div>

            <% If total = 0 Then %>
                <div class="listado-vacio">
                    <svg viewBox="0 0 24 24" width="46" height="46" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>
                    <p>Todavía no hay canciones registradas en la plataforma.</p>
                    <% If admin Then %>
                    <a class="btn btn-primario" href="cancion_form.asp">Registrar la primera canción</a>
                    <% End If %>
                </div>
            <% Else %>
                <%= filas %>
            <% End If %>
        </section>
    </main>
</div>

<!--#include file="inc/reproductor.asp" -->

</body>
</html>
