/* ============================================================
   PoliMusic — Reproductor de audio (JavaScript puro)
   - Un único elemento <audio> para todo el listado: al
     reproducir una canción se detiene la anterior.
   - Controles: play/pause por canción, anterior, siguiente,
     barra de progreso y volumen.
   -Resalta la canción en reproducción con el color de acento.
   ============================================================ */
(function () {
  "use strict";

  var LISTA = (typeof LISTA_CANCIONES !== "undefined") ? LISTA_CANCIONES : [];

  var audio        = document.getElementById("audio");
  if (!audio) { return; }

  var elTitulo     = document.getElementById("repTitulo");
  var elArtista    = document.getElementById("repArtista");
  var elPortada    = document.getElementById("repPortada");
  var btnPlayPause = document.getElementById("btnPlayPause");
  var btnAnterior  = document.getElementById("btnAnterior");
  var btnSiguiente = document.getElementById("btnSiguiente");
  var barra        = document.getElementById("barraProgreso");
  var tActual      = document.getElementById("tiempoActual");
  var tTotal       = document.getElementById("tiempoTotal");
  var volumen      = document.getElementById("controlVolumen");
  var aviso        = document.getElementById("repAviso");
  var btnTodo      = document.getElementById("btnReproducirTodo");
  var btnMenu      = document.getElementById("btnMenu");
  var sidebar      = document.getElementById("sidebar");
  var capa         = document.getElementById("capaOscura");

  var SVG_PLAY  = "<svg viewBox=\"0 0 24 24\" width=\"22\" height=\"22\" fill=\"currentColor\"><path d=\"M8 5v14l11-7z\"/></svg>";
  var SVG_PAUSE = "<svg viewBox=\"0 0 24 24\" width=\"22\" height=\"22\" fill=\"currentColor\"><path d=\"M6 5h4v14H6zM14 5h4v14h-4z\"/></svg>";

  var indice = -1;          // índice de la canción actual (-1 = ninguna)
  var arrastrando = false;  // el usuario está moviendo la barra de progreso
  var timerAviso = null;

  /* ---------- Utilidades ---------- */
  function formatear(seg) {
    if (!isFinite(seg) || seg < 0) { return "0:00"; }
    var m = Math.floor(seg / 60);
    var s = Math.floor(seg % 60);
    return m + ":" + (s < 10 ? "0" : "") + s;
  }

  function disponible(i) {
    return LISTA[i] && LISTA[i].repro === true && LISTA[i].src;
  }

  function mostrarAviso(texto) {
    if (!aviso) { return; }
    aviso.textContent = texto;
    aviso.classList.add("visible");
    if (timerAviso) { clearTimeout(timerAviso); }
    timerAviso = setTimeout(function () {
      aviso.classList.remove("visible");
    }, 3200);
  }

  function siguienteIndice(dir) {
    var n = LISTA.length;
    if (n === 0) { return -1; }
    var i = indice;
    for (var k = 0; k < n; k++) {
      i = (i + dir + n * 2) % n;
      if (disponible(i)) { return i; }
    }
    return -1;
  }

  /* ---------- Interfaz ---------- */
  function marcarFilas() {
    var filas = document.querySelectorAll(".cancion");
    for (var i = 0; i < filas.length; i++) {
      var idx = parseInt(filas[i].getAttribute("data-idx"), 10);
      var esActual = (idx === indice);
      filas[i].classList.toggle("activa", esActual);
      filas[i].classList.toggle("pausada", esActual && audio.paused);
    }
  }

  function actualizarBotonPlay() {
    if (!btnPlayPause) { return; }
    btnPlayPause.innerHTML = audio.paused ? SVG_PLAY : SVG_PAUSE;
    btnPlayPause.setAttribute("aria-label", audio.paused ? "Reproducir" : "Pausar");
  }

  function actualizarInfo() {
    var c = LISTA[indice];
    if (!c) { return; }
    if (elTitulo)  { elTitulo.textContent = c.titulo; }
    if (elArtista) { elArtista.textContent = c.artista; }
    if (elPortada) { elPortada.setAttribute("src", c.portada); }
    document.title = c.titulo + " — PoliMusic";
  }

  /* ---------- Reproducción ---------- */
  function reproducir(i) {
    if (!disponible(i)) {
      mostrarAviso("El archivo de audio de esta canción no está disponible.");
      return;
    }
    if (i === indice) { alternar(); return; }
    indice = i;
    audio.src = LISTA[i].src;
    audio.load();
    var p = audio.play();
    if (p && p.then) {
      p.then(null, function () {
        mostrarAviso("No se pudo reproducir el archivo.");
      });
    }
    actualizarInfo();
    marcarFilas();
  }

  function alternar() {
    if (indice < 0) { reproducir(siguienteIndice(1)); return; }
    if (audio.paused) {
      var p = audio.play();
      if (p && p.then) {
        p.then(null, function () {
          mostrarAviso("No se pudo reproducir el archivo.");
        });
      }
    } else {
      audio.pause();
    }
  }

  function siguiente() {
    var i = siguienteIndice(1);
    if (i >= 0) { reproducir(i); }
  }

  function anterior() {
    // Como en Spotify: si ya avanzó la canción, la reinicia.
    if (audio.currentTime > 3) { audio.currentTime = 0; return; }
    var i = siguienteIndice(-1);
    if (i >= 0) { reproducir(i); }
  }

  /* ---------- Eventos del audio ---------- */
  audio.addEventListener("timeupdate", function () {
    if (!arrastrando && isFinite(audio.duration) && audio.duration > 0) {
      barra.value = (audio.currentTime / audio.duration) * 100;
    }
    tActual.textContent = formatear(audio.currentTime);
  });

  audio.addEventListener("loadedmetadata", function () {
    if (isFinite(audio.duration) && audio.duration > 0) {
      tTotal.textContent = formatear(audio.duration);
    }
  });

  audio.addEventListener("play", function () {
    actualizarBotonPlay();
    marcarFilas();
  });

  audio.addEventListener("pause", function () {
    actualizarBotonPlay();
    marcarFilas();
  });

  audio.addEventListener("ended", function () {
    siguiente();
  });

  audio.addEventListener("error", function () {
    if (audio.getAttribute("src")) {
      mostrarAviso("No se pudo cargar el archivo de audio.");
    }
  });

  /* ---------- Controles del reproductor ---------- */
  if (btnPlayPause) { btnPlayPause.addEventListener("click", alternar); }
  if (btnSiguiente) { btnSiguiente.addEventListener("click", siguiente); }
  if (btnAnterior)  { btnAnterior.addEventListener("click", anterior); }

  if (barra) {
    barra.addEventListener("input", function () {
      arrastrando = true;
      if (isFinite(audio.duration) && audio.duration > 0) {
        tActual.textContent = formatear((barra.value / 100) * audio.duration);
      }
    });
    barra.addEventListener("change", function () {
      if (isFinite(audio.duration) && audio.duration > 0) {
        audio.currentTime = (barra.value / 100) * audio.duration;
      }
      arrastrando = false;
    });
  }

  if (volumen) {
    audio.volume = 0.8;
    volumen.value = 80;
    volumen.addEventListener("input", function () {
      var v = volumen.value / 100;
      audio.volume = v;
      audio.muted = (v === 0);
    });
  }

  /* ---------- Clic en las filas del listado ---------- */
  var filas = document.querySelectorAll(".cancion");
  for (var i = 0; i < filas.length; i++) {
    (function (fila) {
      fila.addEventListener("click", function () {
        var idx = parseInt(fila.getAttribute("data-idx"), 10);
        reproducir(idx);
      });
    })(filas[i]);
  }

  /* ---------- Duración de cada canción (lee los metadatos del mp3) ---------- */
  var durs = document.querySelectorAll(".duracion");
  for (var j = 0; j < durs.length; j++) {
    (function (span) {
      var src = span.getAttribute("data-src");
      if (!src) { return; }
      var probe = new Audio();
      probe.preload = "metadata";
      probe.addEventListener("loadedmetadata", function () {
        span.textContent = formatear(probe.duration);
        var idx = parseInt(span.getAttribute("data-idx"), 10);
        if (!isNaN(idx) && LISTA[idx]) { LISTA[idx].duracion = probe.duration; }
      });
      probe.addEventListener("error", function () {
        span.textContent = "--:--";
      });
      probe.src = src;
    })(durs[j]);
  }

  /* ---------- Botón "Reproducir" general ---------- */
  if (btnTodo) {
    btnTodo.addEventListener("click", function () {
      var i = siguienteIndice(1);
      if (i >= 0) {
        reproducir(i);
      } else {
        mostrarAviso("No hay canciones disponibles para reproducir.");
      }
    });
  }

  /* ---------- Menú lateral en móvil ---------- */
  if (btnMenu && sidebar) {
    btnMenu.addEventListener("click", function () {
      var abierto = sidebar.classList.toggle("abierto");
      if (capa) { capa.classList.toggle("activa", abierto); }
    });
  }
  if (capa && sidebar) {
    capa.addEventListener("click", function () {
      sidebar.classList.remove("abierto");
      capa.classList.remove("activa");
    });
  }

  /* ---------- Cerrar alertas ---------- */
  var btnCerrarAlerta = document.getElementById("alertaCerrar");
  if (btnCerrarAlerta) {
    btnCerrarAlerta.addEventListener("click", function () {
      var alerta = document.getElementById("alerta");
      if (alerta) { alerta.style.display = "none"; }
    });
  }

  /* ---------- Atajos de teclado ---------- */
  document.addEventListener("keydown", function (e) {
    var t = e.target || e.srcElement;
    var etiqueta = t && t.tagName ? t.tagName.toLowerCase() : "";
    if (etiqueta === "input" || etiqueta === "textarea" || etiqueta === "select") { return; }
    var k = e.key || "";
    if (k === " " || e.keyCode === 32) {
      e.preventDefault();
      alternar();
    } else if (k === "ArrowRight" || e.keyCode === 39) {
      siguiente();
    } else if (k === "ArrowLeft" || e.keyCode === 37) {
      anterior();
    }
  });

  /* ---------- Estado inicial ---------- */
  actualizarBotonPlay();
  marcarFilas();
})();
