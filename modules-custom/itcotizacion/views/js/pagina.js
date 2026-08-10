/** Página de cotización: pinta la lista, valida y salta a WhatsApp. */
(function () {
  "use strict";

  var cont = null;
  var API = null;

  document.addEventListener("DOMContentLoaded", function () {
    cont = document.getElementById("itcot-lista");
    API = window.ITCotizacion;
    if (!cont || !API) { return; }          // no estamos en la página de cotización

    pintar();
    document.addEventListener("itcot:cambio", pintar);

    var vaciar = document.getElementById("itcot-vaciar");
    if (vaciar) {
      vaciar.addEventListener("click", function () { API.vaciar(); });
    }

    var form = document.getElementById("itcot-form");
    if (form) { form.addEventListener("submit", enviar); }
  });

  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function pintar() {
    var lista = API.lista();

    if (!lista.length) {
      cont.innerHTML = '<p class="itcot-vacio">' + esc(cont.dataset.vacio) + "</p>";
      return;
    }

    cont.innerHTML = lista.map(function (p) {
      return '' +
        '<article class="itcot-linea" data-id="' + esc(p.id) + '">' +
          '<div class="itcot-linea__img">' +
            (p.img ? '<img src="' + esc(p.img) + '" alt="" loading="lazy">' : '<span class="itcot-sinimg"></span>') +
          "</div>" +
          '<div class="itcot-linea__txt">' +
            '<h3><a href="' + esc(p.url) + '">' + esc(p.nombre) + "</a></h3>" +
            (p.ref ? '<p class="itcot-ref">' + esc(p.ref) + "</p>" : "") +
          "</div>" +
          '<div class="itcot-linea__qty">' +
            '<button type="button" class="itcot-qty" data-accion="menos" aria-label="Quitar uno">−</button>' +
            '<input type="number" min="1" max="9999" value="' + (parseInt(p.qty, 10) || 1) + '" aria-label="Cantidad">' +
            '<button type="button" class="itcot-qty" data-accion="mas" aria-label="Agregar uno">+</button>' +
          "</div>" +
          '<button type="button" class="itcot-quitar" data-accion="quitar" aria-label="Quitar de la cotización">×</button>' +
        "</article>";
    }).join("");
  }

  // Delegación: los botones se repintan en cada cambio.
  document.addEventListener("click", function (ev) {
    if (!cont) { return; }
    var b = ev.target.closest("[data-accion]");
    if (!b || !cont.contains(b)) { return; }

    var linea = b.closest(".itcot-linea");
    var id = linea.dataset.id;
    var input = linea.querySelector('input[type="number"]');
    var qty = parseInt(input.value, 10) || 1;

    if (b.dataset.accion === "quitar") { API.quitar(id); }
    if (b.dataset.accion === "mas")    { API.cantidad(id, qty + 1); }
    if (b.dataset.accion === "menos")  { qty > 1 ? API.cantidad(id, qty - 1) : API.quitar(id); }
  });

  document.addEventListener("change", function (ev) {
    if (!cont || !cont.contains(ev.target)) { return; }
    if (ev.target.type !== "number") { return; }
    var linea = ev.target.closest(".itcot-linea");
    API.cantidad(linea.dataset.id, ev.target.value);
  });

  function limpiarErrores(form) {
    form.querySelectorAll(".itcot-error").forEach(function (e) { e.textContent = ""; });
    form.querySelectorAll(".itcot-campo--mal").forEach(function (e) {
      e.classList.remove("itcot-campo--mal");
    });
  }

  function pintarErrores(form, errores) {
    Object.keys(errores).forEach(function (campo) {
      var el = form.querySelector('.itcot-error[data-para="' + campo + '"]');
      if (el) {
        el.textContent = errores[campo];
        var c = el.closest(".itcot-campo");
        if (c) { c.classList.add("itcot-campo--mal"); }
      } else {
        var g = form.querySelector('.itcot-error[data-para="global"]');
        if (g) { g.textContent = errores[campo]; }
      }
    });
    var primero = form.querySelector(".itcot-campo--mal, .itcot-error--global");
    if (primero) { primero.scrollIntoView({ behavior: "smooth", block: "center" }); }
  }

  function enviar(ev) {
    ev.preventDefault();
    var form = ev.currentTarget;
    var btn = document.getElementById("itcot-btn");

    limpiarErrores(form);

    var lista = API.lista();
    if (!lista.length) {
      pintarErrores(form, { global: cont.dataset.vacio });
      return;
    }

    var datos = new FormData(form);
    datos.append("productos", JSON.stringify(lista.map(function (p) {
      return { id: p.id, qty: p.qty };
    })));

    btn.disabled = true;
    btn.classList.add("itcot-btn--cargando");

    // La pestaña se abre YA, antes del fetch: si se abre en la respuesta,
    // el navegador la bloquea por no venir de un gesto del usuario.
    var pestana = window.open("", "_blank");

    fetch(form.action, { method: "POST", body: datos, credentials: "same-origin" })
      .then(function (r) { return r.json(); })
      .then(function (res) {
        if (!res.ok) {
          if (pestana) { pestana.close(); }
          pintarErrores(form, res.errores || { global: "No se pudo enviar. Inténtalo de nuevo." });
          return;
        }
        API.vaciar();
        if (pestana) {
          pestana.location = res.whatsapp;
        } else {
          window.location = res.whatsapp;
        }
        form.innerHTML =
          '<div class="itcot-listo">' +
            "<h2>¡Listo! Tu solicitud quedó registrada</h2>" +
            "<p>Referencia <strong>" + esc(res.referencia) + "</strong>. " +
            "Si WhatsApp no se abrió, <a href=\"" + esc(res.whatsapp) + "\" target=\"_blank\" rel=\"noopener\">ábrelo aquí</a>.</p>" +
          "</div>";
      })
      .catch(function () {
        if (pestana) { pestana.close(); }
        pintarErrores(form, { global: "No pudimos conectar. Revisa tu conexión e inténtalo de nuevo." });
      })
      .finally(function () {
        btn.disabled = false;
        btn.classList.remove("itcot-btn--cargando");
      });
  }
})();


/* ============================================================================
   Formulario del paso 02 de «Quiero ser cliente» — 08/08/2026
   ----------------------------------------------------------------------------
   El cliente pidio un boton en el paso 2 que despliegue ahi mismo el formulario
   de datos, sin salir de la pagina.

   Se apoya en lo que ya existe: mismos nombres de campo y mismo destino
   (`itcot.urlEnvio`) que el formulario de la pagina de cotizacion. Asi el
   servidor valida y guarda por un unico camino.

   ⚠️ El controlador `enviar` EXIGE que haya productos: con la lista vacia
   responde `{ok:false, errores:{productos:...}}`. Por eso, antes de dejar
   enviar, el formulario dice cuantos productos hay y, si no hay ninguno, lleva
   al catalogo en vez de dejar que el visitante rellene ocho campos para nada.
   ============================================================================ */
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    var boton = document.getElementById("itqs-abrir-datos");
    var caja  = document.getElementById("itqs-datos");
    var form  = document.getElementById("itqs-datos-form");
    if (!boton || !caja || !form) { return; }   // no estamos en esa pagina

    var API = window.ITCotizacion;
    var estado = document.getElementById("itqs-datos-estado");
    var btn = document.getElementById("itqs-datos-btn");

    form.action = (window.itcot && window.itcot.urlEnvio) || form.action;

    function esc(s) {
      return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
        return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
      });
    }

    function lista() {
      return (API && API.lista) ? API.lista() : [];
    }

    /* Cuenta lo que hay en la lista y decide si se puede enviar. */
    function refrescarEstado() {
      var n = lista().length;
      if (n === 0) {
        estado.className = "itqs-datos__estado itqs-datos__estado--vacia";
        estado.innerHTML = 'Tu lista está vacía. Primero elige los productos que quieres cotizar: ' +
                           '<a href="/2-catalogo">ir al catálogo</a>.';
        btn.disabled = true;
      } else {
        estado.className = "itqs-datos__estado";
        estado.textContent = n === 1
          ? "Vas a cotizar 1 producto."
          : "Vas a cotizar " + n + " productos.";
        btn.disabled = false;
      }
    }

    boton.addEventListener("click", function () {
      var abierto = caja.hasAttribute("hidden") === false;
      if (abierto) {
        caja.setAttribute("hidden", "");
        boton.setAttribute("aria-expanded", "false");
        return;
      }
      caja.removeAttribute("hidden");
      boton.setAttribute("aria-expanded", "true");
      refrescarEstado();
      caja.scrollIntoView({ behavior: "smooth", block: "start" });
      var primero = form.querySelector("input, select");
      if (primero) { primero.focus({ preventScroll: true }); }
    });

    // Si el visitante agrega o quita productos en otra pestaña, el aviso se pone al dia.
    document.addEventListener("itcot:cambio", function () {
      if (!caja.hasAttribute("hidden")) { refrescarEstado(); }
    });

    function limpiarErrores() {
      form.querySelectorAll(".itcot-error").forEach(function (e) { e.textContent = ""; });
      form.querySelectorAll(".itcot-campo--mal").forEach(function (e) {
        e.classList.remove("itcot-campo--mal");
      });
    }

    function pintarErrores(errores) {
      Object.keys(errores).forEach(function (campo) {
        var el = form.querySelector('.itcot-error[data-para="' + campo + '"]');
        if (!el) { el = form.querySelector('.itcot-error[data-para="global"]'); }
        if (!el) { return; }
        el.textContent = errores[campo];
        var c = el.closest(".itcot-campo");
        if (c) { c.classList.add("itcot-campo--mal"); }
      });
      var primero = form.querySelector(".itcot-campo--mal, .itcot-error--global");
      if (primero) { primero.scrollIntoView({ behavior: "smooth", block: "center" }); }
    }

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      limpiarErrores();

      var productos = lista();
      if (!productos.length) {
        refrescarEstado();
        return;
      }

      var datos = new FormData(form);
      datos.append("productos", JSON.stringify(productos.map(function (p) {
        return { id: p.id, qty: p.qty };
      })));

      btn.disabled = true;
      btn.classList.add("itcot-btn--cargando");

      // La pestaña se abre antes del fetch: abrirla en la respuesta la bloquea
      // el navegador, por no venir de un gesto del usuario.
      var pestana = window.open("", "_blank");

      fetch(form.action, { method: "POST", body: datos, credentials: "same-origin" })
        .then(function (r) { return r.json(); })
        .then(function (res) {
          if (!res.ok) {
            if (pestana) { pestana.close(); }
            pintarErrores(res.errores || { global: "No se pudo enviar. Inténtalo de nuevo." });
            return;
          }
          if (API && API.vaciar) { API.vaciar(); }
          if (pestana) { pestana.location = res.whatsapp; } else { window.location = res.whatsapp; }
          caja.innerHTML =
            '<div class="itcot-listo">' +
              "<h2>¡Listo! Tu solicitud quedó registrada</h2>" +
              "<p>Referencia <strong>" + esc(res.referencia) + "</strong>. " +
              'Si WhatsApp no se abrió, <a href="' + esc(res.whatsapp) + '" target="_blank" rel="noopener">ábrelo aquí</a>.</p>' +
            "</div>";
        })
        .catch(function () {
          if (pestana) { pestana.close(); }
          pintarErrores({ global: "No pudimos conectar. Revisa tu conexión e inténtalo de nuevo." });
        })
        .finally(function () {
          btn.disabled = false;
          btn.classList.remove("itcot-btn--cargando");
        });
    });
  });
})();
