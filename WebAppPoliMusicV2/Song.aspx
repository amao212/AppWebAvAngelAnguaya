<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>
<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>PoliMusic — Song List</title>
    <link rel="icon" type="image/svg+xml" href="img/logo.svg"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&amp;display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="css/estilos.css"/>
</head>
<body>
    <form id="form1" runat="server">
    <div class="app">

        <!-- ============ BARRA LATERAL ============ -->
        <button type="button" class="btn-menu-movil" id="btnMenu" aria-label="Abrir menu">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor"><path d="M3 6h18v2H3zM3 11h18v2H3zM3 16h18v2H3z"/></svg>
        </button>
        <div class="capa-oscura" id="capaOscura"></div>
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-logo">
                <img src="img/logo.svg" alt="Logo PoliMusic"/>
                <span class="marca">PoliMusic</span>
            </div>
            <nav class="sidebar-nav">
                <a href="Default.aspx" class="activo">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                    Inicio
                </a>
                <a href="Song.aspx">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>
                    Canciones
                </a>
            </nav>
            <div class="sidebar-pie">
                <div class="usuario-tarjeta">
                    <asp:Image runat="server" ID="imgUsuario" CssClass="foto-usuario" alt="Foto del usuario"/>
                    <div class="usuario-datos">
                        <strong><asp:Label runat="server" ID="lblUsuario"></asp:Label></strong>
                        <span><asp:Label runat="server" ID="lblRol"></asp:Label></span>
                    </div>
                </div>
                <a class="btn-salir" href="Logout.aspx">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4z"/></svg>
                    Cerrar sesion
                </a>
            </div>
        </aside>

        <!-- ============ CONTENIDO CENTRAL ============ -->
        <main class="contenido">
            <header class="bienvenida">
                <p class="saludo">Welcome <strong><asp:Label runat="server" ID="lblSaludo"></asp:Label></strong></p>
                <span class="badge-rol"><asp:Label runat="server" ID="lblRolCabecera"></asp:Label></span>
                <h1 class="titulo-seccion">Song list:</h1>
                <p class="subtitulo"><asp:Literal runat="server" ID="litResumen"></asp:Literal></p>
            </header>

            <asp:Panel runat="server" ID="pnlAlerta" Visible="false" CssClass="alerta">
                <span class="alerta-icono">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
                </span>
                <span class="alerta-texto"><asp:Literal runat="server" ID="litAlerta"></asp:Literal></span>
            </asp:Panel>

            <div class="barra-acciones">
                <button type="button" class="btn-reproducir-todo" id="btnReproducirTodo" title="Reproducir" aria-label="Reproducir">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
                </button>
                <div class="buscador">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0A4.5 4.5 0 1 1 14 9.5 4.49 4.49 0 0 1 9.5 14z"/></svg>
                    <asp:TextBox runat="server" ID="txtBuscar" placeholder="Buscar cancion..." />
                    <asp:Button runat="server" ID="btnBuscar" Text="Buscar" CssClass="btn-buscar" OnClick="btnBuscar_Click" CausesValidation="false" />
                </div>
            </div>

            <section class="listado">
                <div class="listado-cabecera">
                    <span>ID</span>
                    <span>NOMBRE</span>
                    <span class="col-ruta-cab">RUTA</span>
                    <span class="col-repro-cab">REPRODUCCIONES</span>
                    <span class="col-dur-cab">DURACION</span>
                </div>

                <asp:Repeater runat="server" ID="rptCanciones">
                    <ItemTemplate>
                        <div class="cancion" data-idx='<%# Container.ItemIndex %>' data-id='<%# Eval("ID_SONG") %>'>
                            <div class="col-num">
                                <span class="num"><%# Eval("ID_SONG") %></span>
                                <span class="ico-play">
                                    <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
                                </span>
                                <span class="ico-pause">
                                    <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M6 5h4v14H6zM14 5h4v14h-4z"/></svg>
                                </span>
                                <span class="eq"><span></span><span></span><span></span></span>
                            </div>
                            <div class="col-titulo">
                                <img class="portada" src='<%# ResolveUrl(ResolverPortada(Convert.ToInt32(Eval("ID_SONG")))) %>' alt='Portada de <%# Server.HtmlEncode(Eval("SONG_NAME").ToString()) %>'/>
                                <div class="info">
                                    <span class="titulo"><%# Server.HtmlEncode(Eval("SONG_NAME").ToString()) %></span>
                                    <span class="artista">PoliMusic</span>
                                </div>
                            </div>
                            <div class="col-ruta" title='<%# Server.HtmlEncode(Eval("SONG_PATH").ToString()) %>'><%# Server.HtmlEncode(Eval("SONG_PATH").ToString()) %></div>
                            <div class="col-repro" title="Reproducciones">
                                <span class="ico-nota">
                                    <svg viewBox="0 0 24 24" width="13" height="13" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>
                                </span>
                                <%# Eval("PLAYS") %>
                            </div>
                            <div class="col-dur">
                                <span class="duracion" data-idx='<%# Container.ItemIndex %>' data-src='<%# ResolverRutaAudio(Eval("SONG_PATH").ToString()) %>'>--:--</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel runat="server" ID="pnlVacio" Visible="false" CssClass="listado-vacio">
                    <svg viewBox="0 0 24 24" width="46" height="46" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>
                    <p>Todavia no hay canciones registradas en la plataforma.</p>
                </asp:Panel>
            </section>
        </main>
    </div>

    <!-- ============ REPRODUCTOR FIJO ============ -->
    <div class="reproductor" id="reproductor">
        <div class="rep-actual">
            <img id="repPortada" src="PlaylistImages/default.jpg" alt="Portada de la cancion actual"/>
            <div class="rep-info">
                <strong id="repTitulo">PoliMusic</strong>
                <span id="repArtista">Selecciona una cancion</span>
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
                <input type="range" id="barraProgreso" min="0" max="100" value="0" step="0.1" aria-label="Barra de progreso"/>
                <span class="rep-tiempo" id="tiempoTotal">0:00</span>
            </div>
        </div>
        <div class="rep-volumen">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3A4.5 4.5 0 0 0 14 7.97v8.05A4.47 4.47 0 0 0 16.5 12zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4-.91 7-4.49 7-8.77s-3-7.86-7-8.77z"/></svg>
            <input type="range" id="controlVolumen" min="0" max="100" value="80" aria-label="Control de volumen"/>
        </div>
        <div class="rep-aviso" id="repAviso" role="status"></div>
    </div>
    <audio id="audio" preload="metadata"></audio>

    <script type="text/javascript">
        /* Lista de canciones generada desde la base de datos */
        var LISTA_CANCIONES = [<%= GetCancionesJson() %>];
    </script>
    <script type="text/javascript" src="js/reproductor.js"></script>
    </form>
</body>
</html>
