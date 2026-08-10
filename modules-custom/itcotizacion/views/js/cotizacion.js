/**
 * Lista de cotización — Import Tools Latam
 *
 * La tienda va en modo catálogo: no hay carrito de PrestaShop. La lista vive en
 * el navegador (localStorage) y solo viaja al servidor cuando el visitante
 * envía sus datos.
 */
(function () {
  "use strict";

  var CLAVE = "itcot.lista.v1";
  var T = (window.itcot && window.itcot.textos) || {};

  /* ---------------------------------------------------------- almacenamiento */

  function leer() {
    try {
      var v = JSON.parse(localStorage.getItem(CLAVE));
      return Array.isArray(v) ? v : [];
    } catch (e) {
      return [];
    }
  }

  function guardar(lista) {
    try {
      localStorage.setItem(CLAVE, JSON.stringify(lista));
    } catch (e) {
      /* modo privado o cuota llena: la lista dura lo que la página */
    }
    pintarContador();
    document.dispatchEvent(new CustomEvent("itcot:cambio", { detail: lista }));
  }

  var API = {
    lista: leer,
    contar: function () {
      return leer().reduce(function (n, p) { return n + (parseInt(p.qty, 10) || 1); }, 0);
    },
    tiene: function (id) {
      return leer().some(function (p) { return String(p.id) === String(id); });
    },
    agregar: function (prod) {
      var lista = leer();
      var yaEsta = false;
      lista.forEach(function (p) {
        if (String(p.id) === String(prod.id)) {
          p.qty = (parseInt(p.qty, 10) || 1) + (parseInt(prod.qty, 10) || 1);
          yaEsta = true;
        }
      });
      if (!yaEsta) {
        lista.push({
          id: String(prod.id),
          ref: prod.ref || "",
          nombre: prod.nombre || "",
          url: prod.url || "",
          img: prod.img || "",
          qty: parseInt(prod.qty, 10) || 1
        });
      }
      guardar(lista);
      return yaEsta;
    },
    cantidad: function (id, qty) {
      var lista = leer();
      lista.forEach(function (p) {
        if (String(p.id) === String(id)) {
          p.qty = Math.max(1, Math.min(9999, parseInt(qty, 10) || 1));
        }
      });
      guardar(lista);
    },
    quitar: function (id) {
      guardar(leer().filter(function (p) { return String(p.id) !== String(id); }));
    },
    vaciar: function () { guardar([]); }
  };

  window.ITCotizacion = API;

  /* ------------------------------------------------------------- contador UI */

  function pintarContador() {
    var n = API.contar();
    document.querySelectorAll(".itcot-contador").forEach(function (el) {
      el.textContent = n;
      el.classList.toggle("itcot-contador--vacio", n === 0);
    });
    document.querySelectorAll(".itcot-acceso").forEach(function (el) {
      el.classList.toggle("itcot-acceso--con-items", n > 0);
    });
  }

  /* ------------------------------------------------------------------ aviso */

  var avisoTimer = null;

  function aviso(texto, tipo) {
    var el = document.querySelector(".itcot-aviso");
    if (!el) {
      el = document.createElement("div");
      el.className = "itcot-aviso";
      el.setAttribute("role", "status");
      document.body.appendChild(el);
    }
    el.textContent = texto;
    el.classList.remove("itcot-aviso--error");
    if (tipo === "error") { el.classList.add("itcot-aviso--error"); }
    el.classList.add("itcot-aviso--visible");
    clearTimeout(avisoTimer);
    avisoTimer = setTimeout(function () {
      el.classList.remove("itcot-aviso--visible");
    }, 2600);
  }

  /* ------------------------------------------- botón «agregar a cotización» */

  /* En los listados se agrega de uno en uno. La ficha de producto sí trae
     selector de cantidad y lo indica con data-qty-from="#id-del-input". */
  function cantidadPedida(btn) {
    var sel = btn.dataset.qtyFrom;
    if (!sel) { return 1; }
    var input = document.querySelector(sel);
    if (!input) { return 1; }
    return Math.max(1, Math.min(9999, parseInt(input.value, 10) || 1));
  }

  /* Los +/- del selector de la ficha. Los de la página de cotización los lleva
     pagina.js, que trabaja sobre la lista ya guardada. */
  document.addEventListener("click", function (ev) {
    var paso = ev.target.closest("[data-itcot-paso]");
    if (!paso) { return; }
    var caja = paso.closest(".itcot-ficha__qty");
    var input = caja && caja.querySelector('input[type="number"]');
    if (!input) { return; }
    ev.preventDefault();
    var v = (parseInt(input.value, 10) || 1) + parseInt(paso.dataset.itcotPaso, 10);
    input.value = Math.max(1, Math.min(9999, v));
  });

  document.addEventListener("click", function (ev) {
    var btn = ev.target.closest(".itcot-agregar");
    if (!btn) { return; }
    ev.preventDefault();

    var yaEsta = API.agregar({
      id: btn.dataset.id,
      ref: btn.dataset.ref,
      nombre: btn.dataset.nombre,
      url: btn.dataset.url,
      img: btn.dataset.img,
      qty: cantidadPedida(btn)
    });

    btn.classList.add("itcot-agregar--hecho");
    setTimeout(function () { btn.classList.remove("itcot-agregar--hecho"); }, 1200);
    aviso(yaEsta ? (T.yaEsta || "Ya está en tu cotización") : (T.agregado || "Agregado a tu cotización"));
  });

  document.addEventListener("DOMContentLoaded", function () {
    pintarContador();
    marcarAgregados();
    document.addEventListener("itcot:cambio", marcarAgregados);
  });

  function marcarAgregados() {
    document.querySelectorAll(".itcot-agregar").forEach(function (b) {
      b.classList.toggle("itcot-agregar--en-lista", API.tiene(b.dataset.id));
    });
  }
})();


/* ==========================================================================
   Contador del corazón (lista de deseos) — Importtools, 03/08/2026
   --------------------------------------------------------------------------
   La lista de deseos de `leofeature` está EN BASE DE DATOS, atada a
   `id_customer` (`leofeature_wishlist` + `leofeature_wishlist_product`), y el
   propio módulo ya marca con la clase `added` el corazón de cada producto que el
   cliente tiene guardado. Lo único que faltaba era el número de la cabecera:

     · el marcado del widget es `<span class="ap-total-wishlist"></span>`, vacío,
       y `leofeature_wishlist.js` solo lo escribe DESPUÉS de añadir o quitar. Al
       entrar a cualquier página el contador salía en blanco aunque hubiera
       productos guardados.

     · ⚠️ y hay un fallo peor: ese script hace
           parseInt($('.ap-btn-wishlist .ap-total-wishlist').data('wishlist-total'))
       Sin `data-wishlist-total` sembrado eso es `parseInt(undefined)` = NaN, así
       que al guardar el primer producto el globo mostraba «NaN». Se siembra aquí
       el dato además del texto.

   `itfav` lo inyecta `itcotizacion.php` con `Media::addJsDef`, leyendo la BD en
   cada petición. No se guarda nada en el navegador.
   ========================================================================== */
(function () {
  "use strict";

  var fav = window.itfav || { logueado: false, total: 0 };

  function pintar(n) {
    document.querySelectorAll(".ap-total-wishlist").forEach(function (el) {
      el.textContent = n;
      // jQuery lee el valor con .data(); el atributo es la forma de sembrarlo
      // sin depender de que jQuery esté cargado en este punto.
      el.setAttribute("data-wishlist-total", n);
      if (window.jQuery) { jQuery(el).data("wishlist-total", n); }
    });
  }

  function arrancar() {
    pintar(fav.total || 0);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", arrancar);
  } else {
    arrancar();
  }
})();
