<%
'===========================================================
' ARCHIVO: inc/reproductor.asp   (archivo de inclusión)
' Reproductor fijo en la parte inferior (estilo barra de
' Spotify). Debe incluirse DESPUÉS de funciones.asp, ya que
' usa CancionesJSON() para pasarle las canciones al JS.
'===========================================================
%>
<div class="reproductor" id="reproductor">
    <div class="rep-actual">
        <img id="repPortada" src="SongFilesAndImages_resources/PlaylistImages/default.jpg" alt="Portada de la canción actual">
        <div class="rep-info">
            <strong id="repTitulo">PoliMusic</strong>
            <span id="repArtista">Selecciona una canción</span>
        </div>
    </div>
    <div class="rep-centro">
        <div class="rep-controles">
            <button type="button" class="btn-control" id="btnAnterior" title="Anterior" aria-label="Anterior">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M6 6h2v12H6zm3.5 6 8.5 6V6z"/></svg>
            </button>
            <button type="button" class="btn-circular" id="btnPlayPause" title="Reproducir / Pausar" aria-label="Reproducir">
                <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
            </button>
            <button type="button" class="btn-control" id="btnSiguiente" title="Siguiente" aria-label="Siguiente">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M16 6h2v12h-2zM6 18l8.5-6L6 6z"/></svg>
            </button>
        </div>
        <div class="rep-progreso">
            <span class="rep-tiempo" id="tiempoActual">0:00</span>
            <input type="range" id="barraProgreso" min="0" max="100" value="0" step="0.1" aria-label="Barra de progreso">
            <span class="rep-tiempo" id="tiempoTotal">0:00</span>
        </div>
    </div>
    <div class="rep-volumen">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3A4.5 4.5 0 0 0 14 7.97v8.05A4.47 4.47 0 0 0 16.5 12zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4-.91 7-4.49 7-8.77s-3-7.86-7-8.77z"/></svg>
        <input type="range" id="controlVolumen" min="0" max="100" value="80" aria-label="Control de volumen">
    </div>
    <div class="rep-aviso" id="repAviso" role="status"></div>
</div>
<audio id="audio" preload="metadata"></audio>

<script>
    /* Lista de canciones generada desde la base de datos (VBScript) */
    var LISTA_CANCIONES = [<% Response.Write CancionesJSON() %>];
</script>
<script src="js/reproductor.js"></script>
