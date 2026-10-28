using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Capa de acceso a datos de la tabla TBL_SONG (BDD_PoliMusic).
    /// Todas las consultas usan parámetros SQL (SqlParameter) para
    /// evitar inyección de código.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Inserta una canción nueva en TBL_SONG.
        /// PLAYS es NULL en la base de datos, por eso se envía DBNull
        /// cuando la entidad tiene 0 reproducciones.
        /// </summary>
        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG] " +
                        "([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    if (song.Plays > 0)
                    {
                        cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@PLAYS", DBNull.Value);
                    }
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Devuelve todas las canciones ordenadas por ID.
        /// La columna NUM_PISTA no existe en TBL_SONG, por eso el
        /// número de pista se calcula con ROW_NUMBER() sobre el ID.
        /// </summary>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ROW_NUMBER() OVER (ORDER BY [ID_SONG]) AS [NUM_PISTA], " +
                    "       [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                    "FROM [TBL_SONG] ORDER BY [ID_SONG]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Devuelve las canciones cuyo nombre coincide con el filtro.
        /// </summary>
        public DataTable ReadByName(string name)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ROW_NUMBER() OVER (ORDER BY [ID_SONG]) AS [NUM_PISTA], " +
                    "       [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                    "FROM [TBL_SONG] WHERE [SONG_NAME] LIKE @SONG_NAME ORDER BY [ID_SONG]", con))
                {
                    cmd.Parameters.AddWithValue("@SONG_NAME", "%" + name + "%");
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Devuelve una canción por su ID (ID_SONG).
        /// </summary>
        public DataTable ReadById(int idSong)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                    "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Actualiza nombre, ruta y reproducciones de una canción.
        /// </summary>
        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME " +
                        ", [SONG_PATH] = @SONG_PATH " +
                        ", [PLAYS] = @PLAYS " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    if (song.Plays > 0)
                    {
                        cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@PLAYS", DBNull.Value);
                    }
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Incrementa en uno el contador PLAYS de la canción indicada.
        /// </summary>
        public int IncreasePlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[PLAYS] = ISNULL([PLAYS], 0) + 1 " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina la canción con el ID indicado.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Verifica si existe una canción con ese ID.
        /// </summary>
        public int CheckExistSong(int idSong)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG] FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : (int)returnValue;
                }
            }
        }
    }

}
