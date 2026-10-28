using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Capa de lógica de negocio de las canciones (TBL_SONG).
    /// Delega la persistencia en la capa DAL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>Crea una canción nueva.</summary>
        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        /// <summary>Lista todas las canciones.</summary>
        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        /// <summary>Lista las canciones que coinciden con el nombre buscado.</summary>
        public DataTable ReadByName(string name)
        {
            return new DAL.Song(strConnectionString).ReadByName(name);
        }

        /// <summary>Obtiene una canción por su ID.</summary>
        public DataTable ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        /// <summary>Actualiza una canción existente.</summary>
        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        /// <summary>Suma una reproducción a la canción.</summary>
        public int IncreasePlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncreasePlays(idSong);
        }

        /// <summary>Elimina una canción.</summary>
        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        /// <summary>Indica si la canción existe en la base de datos.</summary>
        public int CheckExistSong(int idSong)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(idSong);
        }

        /// <summary>
        /// Construye la entidad Song a partir de una fila del DataTable
        /// devuelto por el DAL. Si la fila no es válida devuelve null.
        /// </summary>
        public Entities.Song ToEntity(DataRow row)
        {
            if (row == null)
            {
                return null;
            }
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(row["ID_SONG"]);
            song.Name = row["SONG_NAME"] == DBNull.Value ? string.Empty : row["SONG_NAME"].ToString();
            song.Path = row["SONG_PATH"] == DBNull.Value ? string.Empty : row["SONG_PATH"].ToString();
            song.Plays = (row["PLAYS"] == DBNull.Value) ? 0 : Convert.ToInt32(row["PLAYS"]);
            return song;
        }
    }

}
