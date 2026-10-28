using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Entidad que hace match con la tabla TBL_SONG de la base de datos BDD_PoliMusic.
    /// COLUMNAS:
    ///   ID_SONG    int IDENTITY(1,1) NOT NULL  -> ID
    ///   SONG_NAME  varchar(50)  NOT NULL       -> Name
    ///   SONG_PATH  varchar(255) NOT NULL       -> Path
    ///   PLAYS      int          NULL           -> Plays
    /// </summary>
    public class Song
    {
        public Song()
        {
        }

        public Song(int id, string name, string path, int plays)
        {
            ID = id;
            Name = name;
            Path = path;
            Plays = plays;
        }

        /// <summary>ID_SONG</summary>
        public int ID { get; set; }

        /// <summary>SONG_NAME</summary>
        public string Name { get; set; }

        /// <summary>SONG_PATH</summary>
        public string Path { get; set; }

        /// <summary>PLAYS</summary>
        public int Plays { get; set; }
    }

}
