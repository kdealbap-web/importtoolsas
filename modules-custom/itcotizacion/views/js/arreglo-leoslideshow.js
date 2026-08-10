/* ============================================================================
   Arreglo del guardado de LeoSlideshow en el back office — 08/08/2026
   ----------------------------------------------------------------------------
   SINTOMA (reportado por el cliente): abre «Leo Slideshow Configuration», edita
   un banner, pulsa guardar y no pasa NADA. Se queda «en editing», no avisa de
   ningun error y no actualiza.

   CAUSA, comprobada de punta a punta contra el espejo:

   1) El modulo construye el `action` de sus formularios con
      `getAdminLink('AdminModules', true)`, que devuelve una URL ABSOLUTA con el
      dominio de `PS_SHOP_DOMAIN_SSL`. En produccion eso es
      `https://www.importtoolsas.com/...`, CON www.
   2) El cliente entra al panel por `https://importtoolsas.com/...`, SIN www.
   3) `script.js` del modulo (linea 495) guarda la diapositiva asi:
          $.ajax({ url: $(".slider-form").attr('action'),
                   dataType: "JSON", type: "POST", data: params }).done(...)
      Como el `action` apunta a OTRO host, el navegador lo trata como peticion
      entre origenes distintos y la bloquea: nunca sale del navegador.
   4) Y ese `$.ajax` **solo tiene `.done()`, no tiene `.fail()`**. Cuando la
      peticion se bloquea no hay alerta, no hay consola, no hay nada: el boton
      se queda como estaba. De ahi el «se bloquea y no hace nada».

   Comprobado ademas que el servidor NO tiene ningun fallo: enviando la misma
   peticion al mismo origen, `slideProcessAjax()` responde
   `{"error":0,"text":"..."}` y el titulo queda guardado en
   `psjy_leoslideshow_slides_lang`. El backend esta bien; lo que falla es a
   donde apunta el formulario.

   QUE HACE ESTE FICHERO

   a) Pasa el `action` de los formularios del modulo a ruta RELATIVA. Una ruta
      relativa siempre viaja al mismo origen desde el que se esta navegando, asi
      que da igual si el cliente entro con www o sin www: deja de haber peticion
      entre origenes. De paso evita el «contenido mixto» si alguna vez el enlace
      saliera en http estando la pagina en https.
   b) Deja de esconder los errores: cualquier AJAX del panel que falle escribe el
      motivo en la consola y, si el fallo es de un guardado del slideshow, lo
      dice en pantalla. Es preferible un aviso feo a un boton que no responde.

   No se toca ni un fichero del modulo: si algun dia se actualiza el tema, esto
   se sigue aplicando encima.
   ============================================================================ */
(function () {
  "use strict";

  if (typeof window.jQuery === "undefined") { return; }
  var $ = window.jQuery;

  /* Pasa una URL absoluta del mismo sitio a ruta relativa. Si apunta de verdad a
     otro sitio (no deberia), se deja como esta: no es asunto nuestro. */
  function aRelativa(url) {
    if (!url) { return url; }
    if (url.charAt(0) === "/" || url.indexOf("?") === 0) { return url; }   // ya es relativa
    var a;
    try {
      a = new URL(url, window.location.href);
    } catch (e) {
      return url;
    }
    // mismo host o el mismo host cambiando solo el www: se puede relativizar
    var propio = window.location.hostname.replace(/^www\./, "");
    var suyo = a.hostname.replace(/^www\./, "");
    if (suyo !== propio) { return url; }
    return a.pathname + a.search + a.hash;
  }

  function sanear() {
    var tocados = 0;
    $("#module_form, .slider-form, form.defaultForm").each(function () {
      var antes = $(this).attr("action");
      if (!antes) { return; }
      var despues = aRelativa(antes);
      if (despues !== antes) {
        $(this).attr("action", despues);
        tocados++;
      }
    });
    if (tocados) {
      window.console && console.info(
        "[itcotizacion] LeoSlideshow: " + tocados +
        " formulario(s) pasados a ruta relativa para que el guardado no salga a otro dominio."
      );
    }
  }

  $(function () {
    // Solo en la configuracion de leoslideshow; no tocamos el resto del panel.
    if (window.location.href.indexOf("leoslideshow") === -1) { return; }

    sanear();

    /* El modulo reconstruye trozos del formulario al cambiar de pestaña o de
       idioma, asi que se vuelve a sanear cuando aparezca marcado nuevo. */
    if (window.MutationObserver) {
      var obs = new MutationObserver(function () { sanear(); });
      obs.observe(document.body, { childList: true, subtree: true });
    }

    /* Los errores dejan de ser mudos. `script.js` del modulo no define `.fail()`,
       asi que sin esto un guardado que falla es indistinguible de uno que nunca
       se pulso. */
    $(document).ajaxError(function (evento, xhr, ajustes) {
      var url = (ajustes && ajustes.url) || "";
      window.console && console.error(
        "[itcotizacion] Ha fallado una peticion del panel:",
        { url: url, estado: xhr.status, respuesta: (xhr.responseText || "").slice(0, 300) }
      );

      if (url.indexOf("leoslideshow") === -1 && url.indexOf("AdminModules") === -1) { return; }

      var motivo = xhr.status === 0
        ? "el navegador bloqueo la peticion (suele ser por entrar al panel con un dominio distinto al configurado en la tienda)"
        : "el servidor respondio " + xhr.status;

      var aviso = $(
        '<div class="alert alert-danger" style="margin:12px 0">' +
        '<strong>No se pudo guardar.</strong> ' + motivo + '. ' +
        'El banner NO se ha modificado.' +
        '</div>'
      );
      var $destino = $("#content").first();
      if ($destino.length) {
        $destino.find(".itcot-aviso-slideshow").remove();
        aviso.addClass("itcot-aviso-slideshow").prependTo($destino);
        $("html, body").animate({ scrollTop: 0 }, 200);
      } else {
        alert("No se pudo guardar: " + motivo + ". El banner NO se ha modificado.");
      }
    });
  });
})();
