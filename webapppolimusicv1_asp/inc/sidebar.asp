<%
'===========================================================
' ARCHIVO: inc/sidebar.asp   (archivo de inclusión)
' Barra lateral estilo Spotify: logo, navegación, tarjeta del
' usuario logueado (nombre, rol y foto) y botón de cerrar
' sesión. Debe incluirse DESPUÉS de seguridad.asp.
'===========================================================
%>
<button class="btn-menu-movil" id="btnMenu" aria-label="Abrir menú">
    <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor"><path d="M3 6h18v2H3zM3 11h18v2H3zM3 16h18v2H3z"/></svg>
</button>
<div class="capa-oscura" id="capaOscura"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <img src="img/logo.svg" alt="Logo PoliMusic">
        <span class="marca">PoliMusic</span>
    </div>
    <nav class="sidebar-nav">
        <a href="canciones.asp" class="activo">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
            Inicio
        </a>
        <a href="canciones.asp">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>
            Canciones
        </a>
        <% If EsAdmin() Then %>
        <a href="cancion_form.asp">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6z"/></svg>
            Nueva canción
        </a>
        <% End If %>
    </nav>
    <div class="sidebar-pie">
        <div class="usuario-tarjeta">
            <img src="<%= Server.HTMLEncode(RutaFotoUsuario(Session("foto"))) %>" alt="Foto del usuario">
            <div class="usuario-datos">
                <strong><%= Server.HTMLEncode(Session("usuario")) %></strong>
                <span><%= RolActual() %></span>
            </div>
        </div>
        <a class="btn-salir" href="logout.asp">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4z"/></svg>
            Cerrar sesión
        </a>
    </div>
</aside>
