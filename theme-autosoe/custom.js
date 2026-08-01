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
   Placeholder animado del buscador — Importtools, 01/08/2026
   Recupera el efecto de escritura que traia la demo de AutoSoe, con textos en
   español y sacados del catalogo real, no genericos.
   Se detiene en cuanto el usuario toca el campo y respeta prefers-reduced-motion.
   ========================================================================== */
(function () {
  "use strict";

  var FRASES = [
    "Busca por referencia: NIK-10402",
    "tornillería grado 8",
    "discos de corte para metal",
    "herramienta eléctrica",
    "guantes y seguridad industrial",
    "llaves y dados milimétricos"
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
