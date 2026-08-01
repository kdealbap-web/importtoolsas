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
      qty: 1
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
