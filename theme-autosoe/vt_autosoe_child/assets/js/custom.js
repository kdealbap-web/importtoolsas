/*
 *  @Website: apollotheme.com - prestashop template provider
 *  @author Apollotheme <apollotheme@gmail.com>
 *  @copyright Apollotheme
 *  @description: ApPageBuilder is module help you can build content for your shop
 */
/*
 * Custom code goes here.
 * A template should always ship with an empty custom.js
 */
/*
 * Custom code goes here.
 * A template should always ship with an empty custom.js
 */


$(function () {
  $(".showbox").click(function (e) {
    e.stopPropagation();
    if ($(".group-box").hasClass("active")) {
      $(".group-box").removeClass("active");
      $(".bg-over-lay").removeClass("show-over-lay");
      $(".showbox").removeClass("active");
    } else {
      $(".group-box").addClass("active");
      $(".bg-over-lay").addClass("show-over-lay");
      $(".showbox").addClass("active");
    }
  });
  $(".closebox").click(function (e) {
    e.stopPropagation();
    console.log(123);
    if (
      $(".group-box").hasClass("active") ||
      $(".bg-over-lay").hasClass("show-over-lay")
    ) {
      $(".group-box").removeClass("active");
      $(".bg-over-lay").removeClass("show-over-lay");
    }
    $("body").find(".showbox").removeClass("active");
    $("body").find(".dropdown").removeClass('active-item');
  });
  //DONGND:: close menu when click out
  $(document).click(function (event) {
    if (!$(event.target).closest(".group-box").length) {
      $("body").find(".group-box").removeClass("active");
      $("body").find(".bg-over-lay").removeClass("show-over-lay");
      $("body").find(".showbox").removeClass("active");
      $("body").find(".dropdown").removeClass('active-item');
    }
  });
});


$('.group-box .dropdown .caret').click(function (e) {
  e.preventDefault();
  $(this).closest('.dropdown').addClass('active-item')
});
$('.group-box .dropdown .back').click(function (e) {
  e.preventDefault();
  $(this).closest('.dropdown').removeClass('active-item')
});

$(document).ajaxComplete(function () {
  $(".p-reference .product-reference").html(
    $("#product-details .product-reference").clone()
  );
  $(".p-reference .product-quantities").html(
    $("#product-details .product-quantities").clone()
  );


});

$(function () {
  // $(".block.exclusive .title_block").click(function (e) {
  //   e.stopPropagation();
  //   if ($(".box__search").hasClass("active")) {
  //     $(".box__search").removeClass("active");
  //     $(".bg-over-lay-2").removeClass("show-over-lay");
  //     $(".icon__search").removeClass("active");
  //   } else {
  //     $(".box__search").addClass("active");
  //     $(".bg-over-lay-2").addClass("show-over-lay");
  //     $(".icon__search").addClass("active");

  //   }
  // });
  $(".search__col--close i").click(function (e) {
    e.stopPropagation();
    if (
      $(".box__search").hasClass("active") ||
      $(".bg-over-lay-2").hasClass("show-over-lay")
    ) {
      $(".box__search").removeClass("active");
      $(".bg-over-lay-2").removeClass("show-over-lay");
    }
    $("body").find(".icon__search").removeClass("active");
  });
  //DONGND:: close menu when click out
  $(document).click(function (event) {
    if (!$(event.target).closest(".box__search").length) {

      $("body").find(".box__search").removeClass("active");
      $("body").find(".bg-over-lay-2").removeClass("show-over-lay");
      $("body").find(".icon__search").removeClass("active");
    }
  });
});


function showSearchBox(element) {
  $(element).click(function (e) {
    e.preventDefault();
    console.log(123);
    if ($(".box__search").hasClass("active")) {
      $(".box__search").removeClass("active");
      $(".bg-over-lay-2").removeClass("show-over-lay");
      $(".icon__search").removeClass("active");
    } else {
      $(".box__search").addClass("active");
      $(".bg-over-lay-2").addClass("show-over-lay");
      $(".icon__search").addClass("active");
    }
  });
}



$(document).ready(function () {
  function lastOfType(element) {
    $(element).find('.slick-slide').removeClass('last');
    let items = $(element).find('.slick-active')
    $(items[items.length - 1]).addClass('last');
  }


  $.map($('.ApSlick.products'), function (element, index) {
    lastOfType(element);
    $(element).on('afterChange', function () {
      lastOfType(this)
    });
  });

});






$(document).ready(function () {
  function lastOfType(element) {

    $(element).find('.slick-slide').removeClass('last');
    let items = $(element).find('.slick-slide.slick-active')
    $(items[items.length - 1]).addClass('last');
  }


  $.map($('.ApSlick.products'), function (element, index) {
    lastOfType(element);
    $(element).on('afterChange', function () {
      lastOfType(this)
    });
  });

});


if ($('#horizontal_filters').length) {
  if (('#left-column #search_filters_wrapper').length) {
    search_filters_wrapper = $("#search_filters_wrapper").clone(1);
    $("#search_filters_wrapper").remove();
    $("#horizontal_filters").append(search_filters_wrapper);
  }
}


$(document).ready(function () {

  if (screen.width < 768) {
    if ($('#horizontal_filters').length) {
      if (('#horizontal_filters #search_filters_wrapper').length) {
        search_filters_wrapper = $("#search_filters_wrapper").clone(1);
        $("#search_filters_wrapper").remove();
        $("#left-column").append(search_filters_wrapper);
      }
    }
  }
});



$(window).resize(function () {
  if (screen.width < 768) {
    if ($('#horizontal_filters').length) {
      if (('#horizontal_filters #search_filters_wrapper').length) {
        search_filters_wrapper = $("#search_filters_wrapper").clone(1);
        $("#search_filters_wrapper").remove();
        $("#left-column").append(search_filters_wrapper);
      }
    }
  } else {
    movefacedsearchtotop();
  }
});

function updateSlick() {

  var arrEle = $('.js__slick--custom');

  $.map(arrEle, function (element, index) {
    var newRes = $(element).data('slick-option');
    var check = $(element).find('.slick-initialized');
    if (check && newRes) {
      $(element).find('.slick-slider').slick('slickSetOption', 'responsive', newRes, true);
    }
  });
}




$(document).ajaxComplete(function () {
  updateSlick()
});








$(document).on("scroll", function () {
  if (window.scrollY > 10) {
    $(".header-top").addClass("header-scroll");
    $("#header").addClass("active-scroll");
  } else {
    $(".header-top").removeClass("header-scroll");
    $("#header").removeClass("active-scroll");
  }
});


$(document).ajaxComplete(function () {
  $("#_desktop_cart .blockcart").click(function () {
    $('body').addClass('cart-active');
  });

  $(document).click(function (event) {
    if (
      !$(event.target).closest(".leo-dropdown-cart-content").length && !$(event.target).closest("#_desktop_cart .blockcart").length
    ) {
      $('body').removeClass('cart-active');
    }
  });
});


$(".block.exclusive .title_block").click(function (e) {
  e.stopPropagation();


  if ($(".box__search").hasClass("active")) {
    $('body').removeClass('search-active');

  } else {
    $('body').addClass('search-active');
  }
});
$(".search__col--close i").click(function (e) {
  e.stopPropagation();
  if (
    $(".box__search").hasClass("active") ||
    $(".bg-over-lay-2").hasClass("show-over-lay")
  ) {
    $('body').removeClass('search-active');
  }
});
$(document).click(function (event) {
  if (!$(event.target).closest(".box__search").length) {
    $('body').removeClass('search-active');
  }
});


$(document).ready(function () {
  $(".icon__search").click(function (e) {
    e.stopPropagation();

    if ($(".box__search").hasClass("active")) {
      $('body').removeClass('search-active');

    } else {
      $('body').addClass('search-active');
    }
  });
  $(".search__col--close i").click(function (e) {
    e.stopPropagation();
    if (
      $(".box__search").hasClass("active") ||
      $(".bg-over-lay-2").hasClass("show-over-lay")
    ) {
      $('body').removeClass('search-active');
    }
  });


  showSearchBox('.block.exclusive .title_block');
  showSearchBox('.icon__search');

  $(document).click(function (event) {
    if (!$(event.target).closest(".box__search").length) {
      $('body').removeClass('search-active');
    }
  });

  //  click button show filter porduct
  let buttonFilter = $('.header__button--filter');
  let parfilterDropdown = $('.parfilter__dropdown ');

  $(buttonFilter).click(function (e) {
    e.preventDefault();
    $(this).toggleClass('active');
    $(parfilterDropdown).toggleClass('active');
  });
  // $(document).click(function (event) {
  //   if (!$(event.target).closest(".header__button--filter").length && !$(event.target).closest(".parfilter__dropdown").length) {
  //     $(buttonFilter).removeClass('active');
  //     $(parfilterDropdown).removeClass('active');
  //     console.log(123);


  //   }
  // });

  //  mega menu
  let listMenuItem = $('.mega__menu .megamenu.vertical > .nav-item')

  listMenuItem.first().addClass('active');
  $.map(listMenuItem, function (element, index) {

    $(element).click(function (e) {
      e.preventDefault();
      if (!$(this).hasClass('active')) {
        $(this).addClass('active');
        for (let i = 0; i < listMenuItem.length; i++) {
          if (i != index) {
            $(listMenuItem[i]).removeClass('active');
          }
        }
      }


    });
  });

  $(document).click(function (event) {
    if (!$(event.target).closest(".leo-verticalmenu").length) {
      $('.leo-verticalmenu').removeClass('active');
    }
  });

});


$(document).ajaxComplete(function () {
  if ($("body").hasClass("lang-rtl")) {
    $('.menu__brands .manu-logo').slick({
      dots: false,
      infinite: false,
      arrows: false,
      speed: 300,
      slidesToShow: 6,
      slidesToScroll: 1,
      autoplay: true,
      rtl: true,
      autoplaySpeed: 3000,
      responsive: [
        {
          breakpoint: 1024,
          settings: {
            slidesToShow: 4,
            slidesToScroll: 4
          }
        },
        {
          breakpoint: 600,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 2
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 1,
            slidesToScroll: 1
          }
        }
      ]
    });
  } else {
    $('.menu__brands .manu-logo').slick({
      dots: false,
      infinite: false,
      arrows: false,
      speed: 300,
      slidesToShow: 6,
      slidesToScroll: 1,
      autoplay: true,
      autoplaySpeed: 3000,
      responsive: [
        {
          breakpoint: 1024,
          settings: {
            slidesToShow: 4,
            slidesToScroll: 4
          }
        },
        {
          breakpoint: 600,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 2
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 1,
            slidesToScroll: 1
          }
        }
      ]
    });
  }

});



$('.footer__button--login').click(function (e) {
  e.preventDefault();
  $('.leo-quicklogin-modal').addClass('in');
  $('.leo-quicklogin-modal').show();
  $('.off-canvas-inactive').addClass('modal-open');
});

$(document).ready(function () {
  if ($(window).width() < 576) {
    $('.header__search #leo_search_block_top').removeAttr('id');
  }
});

$(window).resize(function () {
  if ($(window).width() < 576) {
    $('.header__search #leo_search_block_top').removeAttr('id');
  } else {
    $('.header__search .block.exclusive').attr('id', 'leo_search_block_top');
  }
});

function moveTabs() {
  let productTabs = $('.product__tabs');

  $.map(productTabs, function (element, index) {
    let tabContents = $(element).find('.widget-tabs-wrapper').detach();
    let newTabs = $(element).find('.header__tabs > .elementor-column-wrap > .elementor-widget-wrap');
    $(newTabs).append(tabContents);
  });

}


function productOverlayHeight() {
  let productList = $('.thumbnail-container');
  $.map(productList, function (element, index) {
    let thumbnailContainerHeight = $(element).outerHeight()
    let productBottomHeight = $(element).find('.product__bottom').outerHeight();
    let productOverlayHeight = thumbnailContainerHeight + productBottomHeight - 22;

    let productOverlay = $(element).find('.product__overlay');
    if (productOverlay) {
      $(productOverlay).css('min-height', productOverlayHeight + 'px')
    }
  });
}

function moveImageProductInTestimonial() {
  let testimonialList = $('.box__testimonial--1 .block-carousel-image-container');

  $.map(testimonialList, function (element, index) {
    let image = $(element).find('.img-fluid').detach();
    $(element).find('.image').append(image)
  });
}

$(document).ready(function () {
  moveTabs();
  moveImageProductInTestimonial();
});


$(document).ajaxComplete(function () {
  productOverlayHeight();
});

$(document).ready(function () {
  if ($("body").hasClass("lang-rtl")) {
    $(".rtl .video__slick >.elementor-column-wrap >.elementor-widget-wrap").slick({
      infinite: true,
      slidesToShow: 4,
      slidesToScroll: 1,
      dots: false,
      arrows: true,
      rtl: true,
      autoplay: true,
      autoplaySpeed: 5000,
      responsive: [
        {
          breakpoint: 1025,
          settings: {
            slidesToShow: 3,
            slidesToScroll: 1,
          }
        },
        {
          breakpoint: 768,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 1
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 1,
            slidesToScroll: 1
          }
        }
      ]
    })
  } else {
    $(".video__slick  >.elementor-column-wrap >.elementor-widget-wrap").slick({
      infinite: true,
      slidesToShow: 4,
      slidesToScroll: 1,
      dots: false,
      arrows: true,
      autoplay: true,
      autoplaySpeed: 5000,
      responsive: [
        {
          breakpoint: 1025,
          settings: {
            slidesToShow: 3,
            slidesToScroll: 1,
          }
        },
        {
          breakpoint: 768,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 1
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 1,
            slidesToScroll: 1
          }
        }
      ]

    })
  }
});



/* ==========================================================================
   Panel de la cuenta: los contadores a cero no se enseñan — 08/08/2026
   Los tres números del panel (cotización, favoritos, comparar) los escriben tres
   scripts distintos: `cotizacion.js` los dos primeros y `leofeature` el tercero.
   Unos dejan el hueco vacío y otros escriben «0», así que con CSS solo se podía
   ocultar la mitad (`:empty`). Aquí se marcan todos con la misma clase y el CSS
   los esconde de una vez: un «0» repetido en cada línea es ruido, y la línea sin
   número ya dice lo mismo.
   ========================================================================== */
(function () {
  "use strict";

  function ajustar() {
    var nums = document.querySelectorAll(".itcuenta__num");
    for (var i = 0; i < nums.length; i++) {
      var t = (nums[i].textContent || "").trim();
      nums[i].classList.toggle("itcuenta__num--cero", t === "" || t === "0");
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    ajustar();
    // Los contadores se escriben después de cargar (ajax de favoritos, cambios
    // en la lista de cotización), así que hay que volver a mirar cuando cambien.
    document.addEventListener("itcot:cambio", ajustar);
    var panel = document.querySelector(".itcuenta");
    if (panel && window.MutationObserver) {
      new MutationObserver(ajustar).observe(panel, {
        childList: true, subtree: true, characterData: true
      });
    }
  });
})();


/* ==========================================================================
   Placeholder animado del buscador — Importtools, 01/08/2026
   Recupera el efecto de escritura que traia la demo de AutoSoe, con textos en
   español y sacados del catalogo real, no genericos.
   Se detiene en cuanto el usuario toca el campo y respeta prefers-reduced-motion.
   ========================================================================== */
(function () {
  "use strict";

  /* Cada palabra empieza en mayuscula, como pidio el cliente el 08/08/2026. Las
     particulas cortas van en minuscula siguiendo su propio ejemplo, que escribio
     «Guantes y Seguridad Industrial» — la conjuncion en minuscula. */
  var FRASES = [
    "Busca por Referencia: NIK-10402",
    "Tornillería Grado 8",
    "Discos de Corte para Metal",
    "Herramienta Eléctrica",
    "Guantes y Seguridad Industrial",
    "Llaves y Dados Milimétricos"
  ];

  var ESCRIBIR = 55;      // ms por letra al escribir
  var BORRAR   = 28;      // ms por letra al borrar
  var PAUSA    = 1700;    // ms con la frase completa
  var ARRANQUE = 700;

  function iniciar(input) {
    if (!input || input.dataset.itTyped === "1") { return; }
    input.dataset.itTyped = "1";

    var reducido = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var original = input.getAttribute("placeholder") || "Buscar";

    // Sin animacion: al menos que el texto sea util y en español
    if (reducido) {
      input.setAttribute("placeholder", "Buscar en el catálogo");
      return;
    }

    var i = 0, pos = 0, borrando = false, timer = null, parado = false;

    function parar() {
      if (parado) { return; }
      parado = true;
      clearTimeout(timer);
      input.setAttribute("placeholder", original);
    }

    // El usuario manda: al enfocar o escribir, se detiene y no vuelve.
    input.addEventListener("focus", parar);
    input.addEventListener("input", parar);

    function paso() {
      if (parado) { return; }
      var frase = FRASES[i];

      if (!borrando) {
        pos++;
        input.setAttribute("placeholder", frase.slice(0, pos) + "\u2502");
        if (pos === frase.length) {
          borrando = true;
          timer = setTimeout(paso, PAUSA);
          return;
        }
        timer = setTimeout(paso, ESCRIBIR);
      } else {
        pos--;
        input.setAttribute("placeholder", frase.slice(0, pos) + "\u2502");
        if (pos === 0) {
          borrando = false;
          i = (i + 1) % FRASES.length;
        }
        timer = setTimeout(paso, BORRAR);
      }
    }

    timer = setTimeout(paso, ARRANQUE);
  }

  function arrancar() {
    // Los dos buscadores del tema: el de cabecera y el desplegable del movil
    ["#leo_search_query_top", "#leo_search_query_block"].forEach(function (sel) {
      document.querySelectorAll(sel).forEach(iniciar);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", arrancar);
  } else {
    arrancar();
  }
})();



/* ==========================================================================
   Menú móvil — cerrar con Escape, Importtools 03/08/2026
   --------------------------------------------------------------------------
   El cajón lateral lo construye `leobootstrapmenu.js`, que ya trae velo
   (`.megamenu-overlay`), cierre al tocar fuera y un botón «Cerrar» traducido.
   Lo único que le falta es el teclado, que es lo que usa quien navega sin ratón.
   Se dispara el propio botón del módulo en vez de quitar clases a mano, para
   que su contabilidad interna (`off-canvas-active` / `off-canvas-inactive`)
   quede consistente.
   ========================================================================== */
document.addEventListener("keydown", function (ev) {
  if (ev.key !== "Escape") { return; }
  if (!document.body.classList.contains("off-canvas-active")) { return; }
  var cerrar = document.querySelector(".off-canvas-nav-megamenu.active .off-canvas-button-megamenu")
            || document.querySelector(".off-canvas-nav-megamenu .off-canvas-button-megamenu");
  if (cerrar) { cerrar.click(); }
});


/* ==========================================================================
   Hero — la caja se adapta a la imagen, Importtools 12/08/2026
   --------------------------------------------------------------------------
   PROBLEMA. LeoSlideshow dimensiona el hero con el alto FIJO del grupo y pinta
   la foto como fondo con `background-size:100%` (escalada al ancho, alto libre).
   Si la proporcion de la foto no es la del grupo, o se recorta por abajo o sobra
   hueco. Medido en el espejo: grupo cuadrado de 460x460 con una foto de 1920x700
   -> la foto ocupa 137 px de los 375 y quedan 238 px vacios.

   ARREGLO. Se lee la proporcion REAL de la imagen —hay que cargarla, porque en
   el HTML solo viene la URL, en `data-leo_image`— y se recalculan los dos altos
   que el modulo fija EN LINEA:
     · `.iview`       -> `aspect-ratio`   (la regla esta en §21 del custom.css)
     · `.iviewSlider` -> `ancho / proporcion`
   Con eso la foto encaja al pixel a cualquier ancho, y suba el cliente la imagen
   que suba. No se toca el modulo.

   ⚠️ Se usa la proporcion MENOR de las diapositivas del grupo, o sea la imagen
   mas ALTA. El grupo tiene un solo alto para todas, asi que hay que elegir: con
   la menor no se recorta ninguna —que es exactamente lo pedido— y a lo sumo
   sobra un poco de fondo en las mas apaisadas. Con imagenes del mismo tamaño,
   que es lo normal, da igual cual se elija.

   ⚠️ Se reaplica en `resize`. El modulo NO escucha el resize de la ventana
   (`iview.js:358` engancha un evento propio del contenedor y solo se dispara una
   vez, desde `startSlider()`), asi que hasta ahora girar el telefono dejaba el
   hero con el alto del arranque. Esto tambien lo corrige.
   ========================================================================== */
(function () {
  "use strict";

  var CAJAS = ".LeoSlideshow .iview, .ApSlideShow .iview";

  /* Proporcion natural de una imagen. Se cachea para no recargarla en cada resize. */
  var cache = {};
  function proporcion(url, listo) {
    if (cache[url] !== undefined) { listo(cache[url]); return; }
    var img = new Image();
    img.onload = function () {
      cache[url] = (img.naturalWidth && img.naturalHeight)
        ? img.naturalWidth / img.naturalHeight
        : 0;
      listo(cache[url]);
    };
    img.onerror = function () { cache[url] = 0; listo(0); };
    img.src = url;
  }

  function ajustar(caja) {
    var slides = caja.querySelectorAll(".slide_config[data-leo_image]");
    if (!slides.length) { return; }

    var urls = [], i, u;
    for (i = 0; i < slides.length; i++) {
      u = slides[i].getAttribute("data-leo_image");
      if (u && urls.indexOf(u) === -1) { urls.push(u); }
    }

    var pendientes = urls.length, menor = 0;
    urls.forEach(function (url) {
      proporcion(url, function (ar) {
        if (ar > 0 && (menor === 0 || ar < menor)) { menor = ar; }
        if (--pendientes > 0) { return; }
        if (menor <= 0) { return; }        // ninguna imagen medible: no se toca nada

        var slider = caja.querySelector(".iviewSlider");
        // Dos anchos distintos, y hay que no confundirlos:
        //   · `slider.offsetWidth` es el ancho de MAQUETACION del slider (el del
        //     grupo, p.ej. 1920 o 460): `offsetWidth` no se ve afectado por el
        //     `transform:scale()` que le pone el modulo.
        //   · `caja.clientWidth` es el ancho real en pantalla (p.ej. 1425 o 375).
        // El slider se dimensiona con el suyo y la caja con el suyo; asi el
        // escalado del modulo (caja/slider) los deja coincidiendo al pixel.
        var anchoCaja = caja.clientWidth;
        var anchoSlider = slider ? slider.offsetWidth : anchoCaja;
        if (!anchoCaja || !anchoSlider) { return; }

        caja.setAttribute("data-it-hero", "1");
        caja.style.setProperty("--it-hero-caja", Math.round(anchoCaja / menor) + "px");
        caja.style.setProperty("--it-hero-alto", Math.round(anchoSlider / menor) + "px");
      });
    });
  }

  function ajustarTodos() {
    document.querySelectorAll(CAJAS).forEach(ajustar);
  }

  /* En las paginas sin carrusel no hay nada que hacer y no merece la pena dejar
     un temporizador dando vueltas: el contenedor `.LeoSlideshow` SI viene en el
     HTML del servidor (lo que crea el JS por dentro es `.iview`), asi que se
     puede descartar de entrada. */
  if (!document.querySelector(".LeoSlideshow, .ApSlideShow")) { return; }

  /* El modulo monta el hero en `document.ready` y ademas espera a que precarguen
     las imagenes, asi que `.iviewSlider` puede no existir todavia cuando esto
     corre. Se comprueba unas cuantas veces y se para en cuanto aparece: mas
     barato y mas facil de seguir que un MutationObserver sobre el documento. */
  var intentos = 0;
  var reloj = setInterval(function () {
    intentos++;
    if (document.querySelector(".iviewSlider") || intentos > 40) {   // hasta 10 s
      clearInterval(reloj);
      ajustarTodos();
    }
  }, 250);

  var esperando;
  window.addEventListener("resize", function () {
    clearTimeout(esperando);
    esperando = setTimeout(ajustarTodos, 150);
  });
})();
