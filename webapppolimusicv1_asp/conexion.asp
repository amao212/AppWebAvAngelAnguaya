<%
'===========================================================
' ARCHIVO: conexion.asp   (archivo de inclusión)
' DESCRIPCIÓN: Configuración CENTRALIZADA de la conexión a
'              SQL Server mediante ADODB.Connection.
'
' INSTRUCCIONES:
'   Modifique ÚNICAMENTE las constantes de la sección 1
'   (servidor, puerto, base de datos, usuario y contraseña).
'   Toda la aplicación obtiene la conexión con la función
'   CrearConexion() definida aquí.
'===========================================================

'-----------------------------------------------------------
' SECCIÓN 1: DATOS DE CONEXIÓN
' *** MODIFICAR ESTOS VALORES SEGÚN SU ENTORNO ***
'-----------------------------------------------------------

' Servidor SQL Server. "localhost" si corre en la misma máquina.
Const DB_SERVIDOR = "localhost"

' Puerto de SQL Server (1433 es el puerto por defecto de la instancia).
' Si usa una instancia con nombre dinámico, pruebe con el nombre: "localhost\SQLEXPRESS"
' y puerto 0 (o quite el puerto de la cadena en CrearConexion).
Const DB_PUERTO   = 1433

' Nombre de la base de datos creada con BDD_PoliMusic.sql
Const DB_NOMBRE   = "BDD_PoliMusic"

' Usuario de SQL Server (autenticación de SQL Server).
' El script BDD_PoliMusic.sql crea el login "usr_polimusic".
Const DB_USUARIO  = "usr_polimusic"

' Contraseña del usuario de SQL Server.
Const DB_CLAVE    = "Politecnica1"

'-----------------------------------------------------------
' SECCIÓN 2: RUTA DE LA CARPETA DE RECURSOS
'   Carpeta (dentro de la aplicación) que contiene las
'   imágenes y los archivos mp3. Las rutas guardadas en la
'   base de datos usan el prefijo "~/" (p. ej. ~/songFiles/x.mp3)
'   y la función RutaReal() de funciones.asp se encarga de
'   convertirlas a rutas reales de la aplicación.
'-----------------------------------------------------------
Const RUTA_RECURSOS = "SongFilesAndImages_resources"

'-----------------------------------------------------------
' SECCIÓN 3: FORMATO DE SALIDA
'   Todas las páginas incluyen este archivo en primer lugar,
'   por lo que aquí se define la codificación UTF-8 (necesaria
'   para mostrar correctamente acentos y la letra ñ).
'-----------------------------------------------------------
Response.Charset = "UTF-8"

'-----------------------------------------------------------
' FUNCIÓN: CrearConexion
'   Abre y devuelve un objeto ADODB.Connection listo para usar.
'
'   Uso típico:
'       Set conn = CrearConexion()
'       ...consultas...
'       conn.Close
'-----------------------------------------------------------
Function CrearConexion()
    Dim conn

    On Error Resume Next

    Set conn = Server.CreateObject("ADODB.Connection")

    ' Cursor del lado del cliente: permite cerrar la conexión
    ' y seguir usando los recordsets devueltos por las consultas.
    conn.CursorLocation = 3   ' adUseClient

    ' Cadena de conexión con autenticación de SQL Server.
    ' Proveedor SQLOLEDB = proveedor OLE DB clásico de Microsoft,
    ' disponible en cualquier Windows con IIS.
    conn.ConnectionString = _
        "Provider=SQLOLEDB;" & _
        "Data Source=" & DB_SERVIDOR & "," & DB_PUERTO & ";" & _
        "Initial Catalog=" & DB_NOMBRE & ";" & _
        "User ID=" & DB_USUARIO & ";" & _
        "Password=" & DB_CLAVE & ";" & _
        "Persist Security Info=False;"

    ' ---- ALTERNATIVA: autenticación de Windows (comentada) ----
    ' Para usarla, comente la cadena anterior y descomente esta:
    'conn.ConnectionString = _
    '    "Provider=SQLOLEDB;" & _
    '    "Data Source=" & DB_SERVIDOR & "," & DB_PUERTO & ";" & _
    '    "Initial Catalog=" & DB_NOMBRE & ";" & _
    '    "Integrated Security=SSPI;"

    conn.Open

    If Err.Number <> 0 Then
        ' No se pudo conectar: mensaje claro para poder diagnosticar.
        Response.Clear
        Response.Write "<div style='font-family:Arial,sans-serif;padding:28px;background:#14110F;color:#FFF7ED'>"
        Response.Write "<h2 style='color:#F97316'>Error de conexión a la base de datos</h2>"
        Response.Write "<p>No se pudo conectar a SQL Server. Revise los valores del archivo <b>conexion.asp</b>:</p>"
        Response.Write "<ul>"
        Response.Write "<li>Servidor: <b>" & Server.HTMLEncode(DB_SERVIDOR) & "</b> (puerto " & DB_PUERTO & ")</li>"
        Response.Write "<li>Base de datos: <b>" & Server.HTMLEncode(DB_NOMBRE) & "</b></li>"
        Response.Write "<li>Usuario: <b>" & Server.HTMLEncode(DB_USUARIO) & "</b></li>"
        Response.Write "</ul>"
        Response.Write "<p>Detalle técnico: " & Server.HTMLEncode(Err.Description) & "</p>"
        Response.Write "<p>Verifique que el servicio SQL Server esté activo, que el puerto 1433 acepte conexiones TCP y que el login tenga acceso a la base de datos.</p>"
        Response.Write "</div>"
        Response.End
    End If

    On Error GoTo 0

    Set CrearConexion = conn
End Function
%>
