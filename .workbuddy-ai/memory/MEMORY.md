# PoliMusic V2 — Project Memory

## Architecture
- **WebAppPoliMusicV2**: ASP.NET WebForms (.NET Framework 2.0, C# 3.0+ compiler)
- Layers: Entities → DAL → BLL → ASPX pages
- DB: SQL Server, connection string key `BDD_PoliMusicConnectionString` in Web.config
- Session key for auth: `Util.Constants.USER` ("USER"), stores `Entities.User`

## TBL_SONG Schema
- Columns: `ID_SONG` (int IDENTITY PK), `SONG_NAME` (varchar 50), `SONG_PATH` (varchar 255), `PLAYS` (int NULL)
- NO `NUM_PISTA`, `ID_ALBUM`, `ID_ARTIST` columns — track number derived via `ROW_NUMBER() OVER (ORDER BY ID_SONG)`

## Song Page Design (Spotify-style dark theme)
- CSS palette in `:root`: `--bg:#14110F`, `--card:#221C18`, `--accent:#F97316`, `--accent2:#FACC15`, `--text:#FFF7ED`, `--muted:#B8A99A`, `--danger:#EF4444`, `--success:#22C55E`
- Layout: fixed sidebar (logo + nav + user card + logout), central content (welcome header + song list), fixed bottom player
- Fonts: Inter + Poppins from Google Fonts
- Player: JS pure (`js/reproductor.js`), single `<audio>` element, play/pause/prev/next, progress bar, volume, equalizer animation on active track
- User name shown in sidebar; logout link to `Logout.aspx`

## Files Created/Modified
- `Entities/Song.cs` — Song entity matching TBL_SONG
- `DAL/Song.cs` — CRUD: Save, Read, ReadByName, ReadById, Update, Delete, IncreasePlays, CheckExistSong
- `BLL/Song.cs` — delegates to DAL, includes ToEntity(DataRow)
- `css/estilos.css` — full Spotify-style dark theme
- `img/logo.svg` — PoliMusic logo
- `js/reproductor.js` — audio player logic
- `Song.aspx` — page markup with sidebar/player/listado
- `Song.aspx.cs` — code-behind: auth check, song loading, search, play tracking, JSON for player
- `Song.aspx.designer.cs` — control declarations
- `WebAppPoliMusicV2.csproj` — registered all new files

## Build Notes
- Compiler (csc.exe) is blocked by sandbox security policy; verified correctness via static review
- Project targets v2.0 but uses C# 3.0 features (auto-properties) — compiles with VS or .NET 4.x MSBuild+csc
- `MapPath` method renamed to `MapPathSeguro` to avoid hiding `Page.MapPath` (CS0108 warning)
