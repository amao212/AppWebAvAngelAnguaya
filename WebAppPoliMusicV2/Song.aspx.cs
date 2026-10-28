using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        /// <summary>Canciones que se pasan al reproductor de JavaScript.</summary>
        private List<Entities.Song> listaCanciones = new List<Entities.Song>();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Petición asíncrona del reproductor: suma una reproducción
            // y no debe renderizar la página.
            if (Request.QueryString["accion"] != null
                && Request.QueryString["accion"].ToLower() == "reproducir")
            {
                accionReproducir();
                return;
            }

            if (!Page.IsPostBack)
            {
                CargarUsuario();
                CargarCanciones();
            }
        }

        /* ============================================================
           USUARIO AUTENTICADO
           ============================================================ */
        private void CargarUsuario()
        {
            Entities.User usuario = Session[Util.Constants.USER] as Entities.User;

            if (usuario == null)
            {
                // No hay usuario en la sesión: se vuelve al login.
                Response.Redirect("Login.aspx", true);
                return;
            }

            lblUsuario.Text = usuario.UserName;
            lblSaludo.Text = usuario.UserName;
            lblRol.Text = RolActual(usuario.UserType);
            lblRolCabecera.Text = "Rol: " + RolActual(usuario.UserType);

            // Foto del usuario con respaldo a la imagen por defecto.
            string foto = ResolverFotoUsuario(usuario.Photo);
            imgUsuario.ImageUrl = foto;
        }

        private string RolActual(int userType)
        {
            if (userType == Util.Constants.ID_USER_ADMIN)
            {
                return "Administrador";
            }
            return "Usuario normal";
        }

        /// <summary>
        /// Convierte la ruta de la base de datos ("~/userImages/x.jpg")
        /// en una ruta web real. Si el archivo no existe devuelve la
        /// imagen por defecto.
        /// </summary>
        private string ResolverFotoUsuario(string rutaBD)
        {
            string ruta = ResolverRutaWeb(rutaBD);
            if (ruta.Length > 0 && ExisteArchivo(ruta))
            {
                return ruta;
            }
            return "~/UserImages/default.jpg";
        }

        /* ============================================================
           LISTADO DE CANCIONES
           ============================================================ */
        private void CargarCanciones()
        {
            BLL.Song bllSong = new BLL.Song(strConnString);
            string busqueda = txtBuscar.Text.Trim();

            DataTable dtCanciones;
            if (busqueda.Length > 0)
            {
                dtCanciones = bllSong.ReadByName(busqueda);
            }
            else
            {
                dtCanciones = bllSong.Read();
            }

            listaCanciones.Clear();
            for (int i = 0; i < dtCanciones.Rows.Count; i++)
            {
                Entities.Song song = bllSong.ToEntity(dtCanciones.Rows[i]);
                if (song != null)
                {
                    listaCanciones.Add(song);
                }
            }

            rptCanciones.DataSource = dtCanciones;
            rptCanciones.DataBind();

            pnlVacio.Visible = (dtCanciones.Rows.Count == 0);

            litResumen.Text = "Listado de canciones disponibles en la plataforma — "
                + dtCanciones.Rows.Count + " cancion(es) registradas";

            if (dtCanciones.Rows.Count == 0 && busqueda.Length > 0)
            {
                litResumen.Text = "No se encontraron canciones con el nombre \"" + busqueda + "\"";
            }
        }

        /* ============================================================
           ACCIONES DE LA PAGINA
           ============================================================ */
        /// <summary>
        /// Busca una canción por nombre (Enter o botón del buscador).
        /// </summary>
        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            CargarCanciones();
        }

        /// <summary>
        /// Suma una reproducción a la canción solicitada por el
        /// reproductor de JavaScript (llamada asíncrona).
        /// </summary>
        protected void accionReproducir()
        {
            string idTexto = Request.QueryString["id"];
            int idSong;

            if (!int.TryParse(idTexto, out idSong))
            {
                return;
            }

            try
            {
                new BLL.Song(strConnString).IncreasePlays(idSong);
            }
            catch (Exception)
            {
                // Si falla el contador no se interrumpe la reproducción.
            }
        }

        /* ============================================================
           HELPERS DE RUTAS
           ============================================================ */
        /// <summary>
        /// Convierte una ruta de la base de datos ("~/songFiles/x.mp3")
        /// en una ruta relativa dentro de la aplicación ("SongFiles/x.mp3").
        /// </summary>
        public static string ResolverRutaWeb(string rutaBD)
        {
            if (rutaBD == null)
            {
                return string.Empty;
            }

            string ruta = rutaBD.Trim();
            if (ruta.Length == 0)
            {
                return string.Empty;
            }

            // Quita el prefijo de aplicación virtual ("~/").
            if (ruta.StartsWith("~/"))
            {
                ruta = ruta.Substring(2);
            }
            ruta = ruta.Replace("\\", "/");
            ruta = ruta.TrimStart('/');

            return ruta;
        }

        /// <summary>
        /// Devuelve la ruta web del audio SOLO si el archivo existe
        /// en disco; en caso contrario devuelve cadena vacía.
        /// </summary>
        public static string ResolverRutaAudio(string rutaBD)
        {
            string ruta = ResolverRutaWeb(rutaBD);
            if (ruta.Length > 0 && ExisteArchivo(ruta))
            {
                return ruta;
            }
            return string.Empty;
        }

        /// <summary>
        /// Devuelve la portada de la canción. No hay una columna de
        /// imagen en TBL_SONG, por eso se usan las carátulas de la
        /// carpeta PlaylistImages de forma rotativa.
        /// </summary>
        public static string ResolverPortada(int idSong)
        {
            int indice = ((idSong - 1) % 5) + 1;
            if (indice < 1)
            {
                indice = 1;
            }

            string ruta = "~/PlaylistImages/playlist" + indice + ".png";
            if (ExisteArchivo(ruta))
            {
                return ruta;
            }
            return "~/PlaylistImages/default.jpg";
        }

        /// <summary>
        /// Devuelve la portada con la ruta web ya resuelta (sin "~")
        /// para usarse en JavaScript / atributos HTML planos.
        /// </summary>
        public static string ResolverPortadaUrl(int idSong)
        {
            string ruta = ResolverPortada(idSong);
            if (ruta.StartsWith("~/"))
            {
                ruta = ruta.Substring(2);
            }
            return ruta;
        }

        /// <summary>
        /// Indica si el archivo existe dentro de la aplicación.
        /// </summary>
        private static bool ExisteArchivo(string ruta)
        {
            if (ruta == null || ruta.Trim().Length == 0)
            {
                return false;
            }

            try
            {
                string rutaFisica = MapPathSeguro(ruta);
                if (rutaFisica == null || rutaFisica.Length == 0)
                {
                    return false;
                }
                return File.Exists(rutaFisica);
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        /// Traduce una ruta web ("~/SongFiles/x.mp3") a su ruta física.
        /// Se declara estática propia para no ocultar Page.MapPath.
        /// </summary>
        private static string MapPathSeguro(string ruta)
        {
            if (ruta.StartsWith("~/"))
            {
                return HttpContext.Current.Server.MapPath(ruta);
            }
            return HttpContext.Current.Server.MapPath("~/" + ruta);
        }

        /* ============================================================
           JSON PARA EL REPRODUCTOR
           ============================================================ */
        /// <summary>
        /// Genera el JSON con todas las canciones para el
        /// reproductor de JavaScript (js/reproductor.js).
        /// </summary>
        public string GetCancionesJson()
        {
            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < listaCanciones.Count; i++)
            {
                Entities.Song song = listaCanciones[i];
                string audio = ResolverRutaAudio(song.Path);

                if (sb.Length > 0)
                {
                    sb.Append(",");
                }

                sb.Append("{\"id\":").Append(song.ID);
                sb.Append(",\"titulo\":\"").Append(EscaparJson(song.Name)).Append("\"");
                sb.Append(",\"artista\":\"PoliMusic\"");
                sb.Append(",\"portada\":\"").Append(EscaparJson(ResolverPortadaUrl(song.ID))).Append("\"");
                sb.Append(",\"src\":\"").Append(EscaparJson(audio)).Append("\"");
                sb.Append(",\"repro\":").Append(audio.Length > 0 ? "true" : "false");
                sb.Append(",\"plays\":").Append(song.Plays);
                sb.Append(",\"duracion\":0}");
            }

            return sb.ToString();
        }

        /// <summary>
        /// Escapa una cadena para incrustarla dentro de un literal
        /// JSON embebido en la página.
        /// </summary>
        private static string EscaparJson(string texto)
        {
            if (texto == null)
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < texto.Length; i++)
            {
                char c = texto[i];
                switch (c)
                {
                    case '\\':
                        sb.Append("\\\\");
                        break;
                    case '"':
                        sb.Append("\\\"");
                        break;
                    case '\'':
                        sb.Append("\\'");
                        break;
                    case '\n':
                        sb.Append("\\n");
                        break;
                    case '\r':
                        sb.Append("\\n");
                        break;
                    case '\t':
                        sb.Append("\\t");
                        break;
                    default:
                        sb.Append(c);
                        break;
                }
            }
            return sb.ToString();
        }
    }
}
