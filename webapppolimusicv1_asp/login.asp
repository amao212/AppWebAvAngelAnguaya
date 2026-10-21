<%@ CodePage=65001 %>
<!--#include file="conexion.asp" -->
<%
'===========================================================
' PÁGINA: login.asp
' Formulario de inicio de sesión (usuario y contraseña).
' La validación se realiza en validar_login.asp contra la
' tabla TBL_USER de la base de datos.
'===========================================================
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic — Iniciar sesión</title>
    <link rel="icon" type="image/svg+xml" href="img/logo.svg">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body class="pagina-login">
    <main class="login-contenedor">
        <div class="login-tarjeta">
            <div class="login-logo">
                <img src="img/logo.svg" alt="Logo PoliMusic">
                <span class="marca">PoliMusic</span>
            </div>
            <h1 class="login-titulo">Iniciar sesión</h1>
            <p class="login-subtitulo">Accede a tu biblioteca musical</p>

            <% If Request.QueryString("error") = "1" Then %>
                <div class="alerta alerta-error">
                    <span class="alerta-icono">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2 1 21h22L12 2zm1 15h-2v-2h2v2zm0-4h-2V8h2v5z"/></svg>
                    </span>
                    <span class="alerta-texto">Usuario o contraseña incorrectos. Verifique sus datos e intente nuevamente.</span>
                </div>
            <% ElseIf Request.QueryString("error") = "vacio" Then %>
                <div class="alerta alerta-error">
                    <span class="alerta-icono">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2 1 21h22L12 2zm1 15h-2v-2h2v2zm0-4h-2V8h2v5z"/></svg>
                    </span>
                    <span class="alerta-texto">Debe ingresar usuario y contraseña.</span>
                </div>
            <% End If %>

            <form id="formLogin" action="validar_login.asp" method="post" class="login-form" novalidate>
                <div class="campo">
                    <label for="usuario">Usuario</label>
                    <input type="text" id="usuario" name="usuario" maxlength="50"
                           autocomplete="username" placeholder="Escriba su usuario" required>
                </div>
                <div class="campo">
                    <label for="clave">Contraseña</label>
                    <input type="password" id="clave" name="clave" maxlength="50"
                           autocomplete="current-password" placeholder="Escriba su contraseña" required>
                </div>
                <div class="login-error-js" id="errorJS"></div>
                <button type="submit" class="btn btn-primario btn-bloque">Entrar</button>
            </form>

            <div class="login-demo">
                <strong>Usuarios de prueba (TBL_USER)</strong>
                <code>userNormal</code> / <code>12345678</code> — rol normal<br>
                <code>userAdmin</code> / <code>12345678</code> — rol administrador<br>
                <code>username1</code> / <code>12345678</code> — rol normal (contraseña guardada como hash SHA1)
            </div>
        </div>
    </main>

    <script>
        // Validación en cliente del formulario de login
        document.getElementById("formLogin").addEventListener("submit", function (e) {
            var usuario = document.getElementById("usuario").value.trim();
            var clave   = document.getElementById("clave").value.trim();
            var error   = document.getElementById("errorJS");
            if (usuario === "" || clave === "") {
                e.preventDefault();
                error.textContent = "Debe ingresar usuario y contraseña.";
                error.style.display = "block";
            } else {
                error.style.display = "none";
            }
        });
    </script>
</body>
</html>
