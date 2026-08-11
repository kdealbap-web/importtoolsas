-- ===========================================================================
-- 25 — Los pasos 6 y 7 SIN TERMINAL · 10/08/2026
-- Importtools S.A.S · prefijo psjy_
-- ---------------------------------------------------------------------------
-- Sustituye a estos dos ficheros, que necesitaban PHP por linea de comandos:
--
--     17-contenido-cms-20260808.php   -> bloque A de aqui
--     15-arreglo-slideshow.php        -> bloque B de aqui
--
-- COMO SE USA
--   cPanel -> phpMyAdmin -> elige la base de la tienda -> pestana "SQL"
--   -> pega ESTE FICHERO ENTERO -> Continuar.
--
--   Si prefieres subirlo: pestana "Importar" -> Seleccionar archivo -> este .sql
--   -> juego de caracteres utf-8 -> Continuar.
--
-- Es idempotente: se puede ejecutar dos veces sin romper nada.
-- Al terminar, sigue por el paso 8 del runbook (vaciar cachés). Sin vaciar
-- cachés no se vera ningun cambio.
-- ===========================================================================

SET NAMES utf8mb4;
SET SQL_MODE = '';


-- ===========================================================================
-- BLOQUE A — Contenido de las dos paginas del cliente   (sustituye al 17-*.php)
-- ===========================================================================
--
-- Reescribe psjy_cms_lang de las paginas 4 y 7, en TODOS los idiomas, con el
-- HTML versionado del repositorio. Es el unico paso de la noche que puede pisar
-- trabajo del cliente, asi que lo primero que hace es un respaldo DENTRO de la
-- propia base.

-- A.1  Respaldo. Si la tabla ya existe de una ejecucion anterior, no la pisa.
CREATE TABLE IF NOT EXISTS psjy_cms_lang_bk_20260810 AS
SELECT * FROM psjy_cms_lang WHERE id_cms IN (4, 7);

SELECT '--- A.1 respaldo: deben salir 4 filas (2 paginas x 2 idiomas) ---' AS ``;
SELECT id_cms, id_lang, LENGTH(content) AS bytes_antes
  FROM psjy_cms_lang_bk_20260810 ORDER BY id_cms, id_lang;

-- A.2  Tamanos de AHORA, para compararlos con los de arriba.
--      Si estos NO coinciden con el respaldo, es que ya ejecutaste esto antes.
SELECT '--- A.2 tamano actual en la tienda ---' AS ``;
SELECT id_cms, id_lang, LENGTH(content) AS bytes_ahora
  FROM psjy_cms_lang WHERE id_cms IN (4, 7) ORDER BY id_cms, id_lang;

-- A.3  CMS 4 — Quiénes somos
--      Origen: deploy/paquete/contenido/quienes-somos.html  (11.535 bytes)
UPDATE psjy_cms_lang
   SET content = '<div class="itqs">

<section class="itqs-banda itqs-hero">
  <div class="itqs-rail">
    <div class="itqs-hero__txt">
      <p class="itqs-eyebrow">¿Quiénes somos?</p>
      <h1 class="itqs-display itqs-hero__h1">Importtools, tu aliado en soluciones ferreteras.</h1>
      <p class="itqs-hero__lede">Somos una empresa dedicada a la importación y comercialización de productos ferreteros de alta calidad. Ofrecemos herramientas, equipos y accesorios para la construcción, el mantenimiento, la industria y el hogar.</p>
      <p class="itqs-acciones">
        <a class="itqs-btn itqs-btn--rojo" href="/2-catalogo">Conoce nuestros productos</a>
        <a class="itqs-btn itqs-btn--linea" href="/contact-us">Contáctanos</a>
      </p>
    </div>
    <figure class="itqs-hero__foto">
      <img src="/img/it/hero-quienes-somos.jpg" alt="Taladro, tronzadora, pistola de pintura, pulidora, careta de soldar, guantes y gafas de la marca Nikato sobre un banco de trabajo" width="1600" height="697" fetchpriority="high">
    </figure>
  </div>
</section>

<section class="itqs-banda itqs-ventajas">
  <div class="itqs-rail">
    <div class="itqs-ventaja">
      <i class="it-ico fa-award" aria-hidden="true"></i>
      <div><h2>Productos de calidad</h2><p>Alta durabilidad y resistencia.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-tags" aria-hidden="true"></i>
      <div><h2>Precios competitivos</h2><p>La mejor relación calidad-precio.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-headset" aria-hidden="true"></i>
      <div><h2>Asesoría experta</h2><p>Te ayudamos a elegir mejor.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-shipping-fast" aria-hidden="true"></i>
      <div><h2>Envíos a toda Colombia</h2><p>Rápidos, seguros y confiables.</p></div>
    </div>
  </div>
</section>

<section class="itqs-soluciones">
  <div class="itqs-soluciones__grid">
    <div class="itqs-soluciones__txt">
      <h2 class="itqs-display">Más que productos, ofrecemos soluciones.</h2>
      <p>En <strong>Importtools</strong> trabajamos cada día para ser la mejor opción en el suministro de productos ferreteros, brindando confianza, respaldo y soluciones efectivas a nuestros clientes.</p>
      <p>Nos enfocamos en entender tus necesidades para ofrecerte productos que impulsan tus proyectos y hacen tu trabajo más fácil.</p>
      <a class="itqs-btn itqs-btn--negro" href="/content/7-quiero-ser-cliente">Quiero ser cliente <i class="it-ico fa-arrow-right" aria-hidden="true"></i></a>
    </div>

    <div class="itqs-pilares">
      <div class="itqs-pilar itqs-pilar--destacado">
        <span class="itqs-pilar__num">01</span>
        <i class="it-ico fa-shield-alt" aria-hidden="true"></i>
        <h3>Productos confiables y de alta calidad</h3>
      </div>
      <div class="itqs-pilar">
        <span class="itqs-pilar__num">02</span>
        <i class="it-ico fa-award" aria-hidden="true"></i>
        <h3>Marcas líderes en el mercado</h3>
      </div>
      <div class="itqs-pilar">
        <span class="itqs-pilar__num">03</span>
        <i class="it-ico fa-handshake" aria-hidden="true"></i>
        <h3>Compromiso y servicio personalizado</h3>
      </div>
      <div class="itqs-pilar">
        <span class="itqs-pilar__num">04</span>
        <i class="it-ico fa-truck" aria-hidden="true"></i>
        <h3>Cobertura nacional y entregas rápidas</h3>
      </div>
    </div>
  </div>
</section>

<section class="itqs-declara">
  <h2 class="itqs-display">Importtools es una empresa especializada en la importación y distribución de productos ferreteros.</h2>
  <p>Contamos con un amplio catálogo de herramientas manuales, eléctricas, accesorios, maquinaria, equipos de seguridad y más, ideales para profesionales, empresas y particulares que buscan calidad, respaldo y buenos precios.</p>
</section>

<section class="itqs-banda itqs-cats">
  <div class="itqs-rail">
    <div class="itqs-cats__grid">
      <a class="itqs-cat" href="/17-herramientas-electricas">
        <span class="itqs-cat__foto"><img src="/img/it/cat-electricas.jpg" alt="Operario perforando un muro de ladrillo con un martillo demoledor" width="640" height="694" loading="lazy"></span>
        <span class="itqs-cat__pie"><strong>Herramientas eléctricas</strong></span>
      </a>
      <a class="itqs-cat" href="/13-herramientas-de-corte">
        <span class="itqs-cat__foto"><img src="/img/it/cat-corte.jpg" alt="Pulidora angular cortando un perfil metálico y levantando chispas" width="640" height="694" loading="lazy"></span>
        <span class="itqs-cat__pie"><strong>Herramientas de corte</strong></span>
      </a>
      <a class="itqs-cat" href="/19-herramientas-manuales">
        <span class="itqs-cat__foto"><img src="/img/it/cat-manuales.jpg" alt="Panel de taller con juegos de llaves, destornilladores y alicates ordenados" width="640" height="694" loading="lazy"></span>
        <span class="itqs-cat__pie"><strong>Herramientas manuales</strong></span>
      </a>
      <a class="itqs-cat" href="/22-seguridad-industrial">
        <span class="itqs-cat__foto"><img src="/img/it/cat-seguridad.jpg" alt="Trabajador con gafas de protección y orejeras durante una labor industrial" width="640" height="694" loading="lazy"></span>
        <span class="itqs-cat__pie"><strong>Seguridad industrial</strong></span>
      </a>
      <a class="itqs-cat" href="/24-ventiladores-industriales">
        <span class="itqs-cat__foto"><img src="/img/it/cat-aire.jpg" alt="Ventilador industrial de piso funcionando dentro de una bodega" width="640" height="694" loading="lazy"></span>
        <span class="itqs-cat__pie"><strong>Ventiladores industriales</strong></span>
      </a>
    </div>
  </div>
</section>

<!-- Banda «Sé nuestro cliente», maquetada el 08/08/2026 a partir del documento del
     cliente. La foto es la misma que abre «Quiero ser cliente» (el asesor con el
     cliente en el mostrador), que es lo que pidió al decir «unifícalas»: las dos
     páginas comparten la misma imagen real, no una generada. Va de fondo por CSS
     y no como <img> porque es decorativa: el texto encima es el contenido. -->
<section class="itqs-banda itqs-sernuestro">
  <div class="itqs-rail">
    <div class="itqs-sernuestro__txt">
      <p class="itqs-eyebrow">Haz crecer tu ferretería</p>
      <h2 class="itqs-display">Sé nuestro cliente</h2>
      <p>Únete a nuestra red de clientes y lleva tu ferretería a productos de alta calidad, marcas reconocidas y el respaldo de un equipo comprometido con tu crecimiento.</p>
      <p class="itqs-sernuestro__botones">
        <a class="itqs-btn itqs-btn--rojo" href="/2-catalogo">Conoce nuestros productos</a>
        <a class="itqs-btn itqs-btn--blanco" href="/content/7-quiero-ser-cliente">Contáctanos</a>
      </p>
    </div>
  </div>
</section>

<section class="itqs-banda itqs-cta">
  <div class="itqs-rail">
    <a class="itqs-btn itqs-btn--blanco" href="/2-catalogo">Ver catálogo completo</a>
    <p>Clientes de todo el país confían en Importtools para llevar sus proyectos al siguiente nivel.</p>
    <a class="itqs-cta__wa" href="https://wa.me/573145934962" target="_blank" rel="noopener">
      <i class="it-ico it-ico--marca fa-whatsapp" aria-hidden="true"></i>
      <span><small>Llámanos o escríbenos por WhatsApp</small><strong>+57 314 593 4962</strong></span>
    </a>
  </div>
</section>

<section class="itqs-banda itqs-valores">
  <div class="itqs-rail">
    <div>
      <p class="itqs-eyebrow">Nuestros valores</p>
      <h2 class="itqs-display">Comprometidos con la calidad, el servicio y el crecimiento conjunto.</h2>
    </div>
    <div class="itqs-valores__grid">
      <div class="itqs-valor">
        <i class="it-ico fa-shield-alt" aria-hidden="true"></i>
        <h3>Integridad</h3>
        <p>Actuamos con honestidad y transparencia en cada proceso y relación.</p>
      </div>
      <div class="itqs-valor">
        <i class="it-ico fa-award" aria-hidden="true"></i>
        <h3>Calidad</h3>
        <p>Trabajamos con los mejores estándares para garantizar productos superiores.</p>
      </div>
      <div class="itqs-valor">
        <i class="it-ico fa-user-tie" aria-hidden="true"></i>
        <h3>Compromiso</h3>
        <p>Nos involucramos contigo para ofrecerte soluciones que generen resultados.</p>
      </div>
      <div class="itqs-valor">
        <i class="it-ico fa-lightbulb" aria-hidden="true"></i>
        <h3>Innovación</h3>
        <p>Buscamos nuevas formas de mejorar y adaptarnos a tus necesidades.</p>
      </div>
      <div class="itqs-valor">
        <i class="it-ico fa-handshake" aria-hidden="true"></i>
        <h3>Trabajo en equipo</h3>
        <p>Creemos en el poder de las alianzas duraderas y en crecer juntos.</p>
      </div>
    </div>
  </div>
</section>

<section class="itqs-info">
  <div class="itqs-info__grid">
    <div>
      <h2>Datos de la empresa</h2>
      <table class="itqs-datos">
        <tbody>
          <tr><th scope="row">Razón social</th><td>Importtools S.A.S</td></tr>
          <tr><th scope="row">NIT</th><td>901.353.663-6</td></tr>
          <tr><th scope="row">Forma jurídica</th><td>Sociedad por Acciones Simplificada</td></tr>
          <tr><th scope="row">Actividad económica</th><td>Comercio al por mayor y al por menor de productos ferreteros, herramientas manuales y eléctricas, equipos para construcción, artículos de seguridad industrial, maquinaria, accesorios y demás productos relacionados con el sector ferretero, mediante canales de distribución físicos y digitales, atendiendo clientes mayoristas, distribuidores, ferreterías y consumidores finales.</td></tr>
          <tr><th scope="row">Dirección</th><td>Carrera Cordialidad Km 2.5 #66</td></tr>
          <tr><th scope="row">Ciudad</th><td>Galapa (Atlántico), Colombia</td></tr>
        </tbody>
      </table>

      <h2 style="margin-top:2.2rem">Contacto</h2>
      <ul class="itqs-contacto">
        <li><i class="it-ico fa-map-marker-alt" aria-hidden="true"></i><span><small>Dirección</small>Carrera Cordialidad Km 2.5 #66, Galapa (Atlántico)</span></li>
        <li><i class="it-ico fa-phone-alt" aria-hidden="true"></i><span><small>Teléfono y WhatsApp</small><a href="https://wa.me/573145934962" target="_blank" rel="noopener">+57 314 593 4962</a></span></li>
        <li><i class="it-ico fa-envelope" aria-hidden="true"></i><span><small>Correo</small><a href="mailto:ventas@importtoolslatam.com">ventas@importtoolslatam.com</a></span></li>
        <li><i class="it-ico fa-clock" aria-hidden="true"></i><span><small>Horario</small>Lunes a viernes 8:00 a. m. – 5:00 p. m. · Sábados 8:00 a. m. – 12:00 m.</span></li>
        <li><i class="it-ico fa-share-alt" aria-hidden="true"></i><span><small>Síguenos</small><a href="https://www.facebook.com/profile.php?id=61550973331221" target="_blank" rel="noopener">Facebook</a> · <a href="https://www.instagram.com/importtoolslatam/" target="_blank" rel="noopener">Instagram</a></span></li>
      </ul>
    </div>

    <div>
      <h2>Dónde estamos</h2>
      <div class="itqs-mapa">
        <iframe title="Ubicación de Importtools S.A.S en Galapa, Atlántico" loading="lazy" src="https://www.openstreetmap.org/export/embed.html?bbox=-74.8634%2C10.9249%2C-74.8554%2C10.9289&amp;layer=mapnik&amp;marker=10.9268546%2C-74.8593972"></iframe>
      </div>
      <p><a href="https://maps.app.goo.gl/bYJ6yfUHMxjv3xQ38" target="_blank" rel="noopener">Abrir la ubicación en Google Maps</a></p>
    </div>
  </div>
</section>

</div>
'
 WHERE id_cms = 4;

-- A.3  CMS 7 — Quiero ser cliente
--      Origen: deploy/paquete/contenido/quiero-ser-cliente.html  (11.776 bytes)
UPDATE psjy_cms_lang
   SET content = '<div class="itqs">

<section class="itqs-banda itqs-hero">
  <div class="itqs-rail">
    <div class="itqs-hero__txt">
      <p class="itqs-eyebrow">Ventas al por mayor</p>
      <h1 class="itqs-display itqs-hero__h1">Compra para tu ferretería, taller u obra.</h1>
      <p class="itqs-hero__lede">Arma tu lista en el catálogo, déjanos tus datos y un asesor te responde por WhatsApp con precios, disponibilidad y tiempo de entrega. Sin registro y sin compromiso.</p>
      <p class="itqs-acciones">
        <a class="itqs-btn itqs-btn--rojo" href="/2-catalogo">Armar mi cotización</a>
        <a class="itqs-btn itqs-btn--linea" href="https://wa.me/573145934962" target="_blank" rel="noopener">Escribir por WhatsApp</a>
      </p>
    </div>
    <figure class="itqs-hero__foto">
      <img src="/img/it/hero-cliente.jpg" alt="Un asesor de Importtools atiende con una tableta a un cliente en el mostrador de la ferretería" width="1600" height="506" fetchpriority="high">
    </figure>
  </div>
</section>

<section class="itqs-banda itqs-ventajas">
  <div class="itqs-rail">
    <div class="itqs-ventaja">
      <i class="it-ico fa-box-open" aria-hidden="true"></i>
      <div><h2>Más de 3.000 referencias</h2><p>Quince líneas y siete marcas en un solo proveedor.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-headset" aria-hidden="true"></i>
      <div><h2>Un asesor asignado</h2><p>Te acompaña en la selección y en el pedido.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-tags" aria-hidden="true"></i>
      <div><h2>Precio según tu volumen</h2><p>Cotizamos sobre la cantidad que necesitas.</p></div>
    </div>
    <div class="itqs-ventaja">
      <i class="it-ico fa-shipping-fast" aria-hidden="true"></i>
      <div><h2>Despachos a toda Colombia</h2><p>Desde Galapa, Atlántico.</p></div>
    </div>
  </div>
</section>

<section class="itqs-publico">
  <h2 class="itqs-display">A quién atendemos</h2>
  <p>Importtools S.A.S es un proveedor mayorista de herramienta y seguridad industrial. Trabajamos con quien compra para revender y con quien compra para trabajar.</p>
  <div class="itqs-publico__grid">
    <div class="itqs-publico__item">
      <i class="it-ico fa-store" aria-hidden="true"></i>
      <h3>Ferreterías</h3>
      <p>Surtido de mostrador y reposición de inventario.</p>
    </div>
    <div class="itqs-publico__item">
      <i class="it-ico fa-truck-loading" aria-hidden="true"></i>
      <h3>Distribuidores</h3>
      <p>Volumen y continuidad de referencias.</p>
    </div>
    <div class="itqs-publico__item">
      <i class="it-ico fa-tools" aria-hidden="true"></i>
      <h3>Talleres</h3>
      <p>Herramienta mecánica, de corte y neumática.</p>
    </div>
    <div class="itqs-publico__item">
      <i class="it-ico fa-hard-hat" aria-hidden="true"></i>
      <h3>Constructoras</h3>
      <p>Dotación de obra y seguridad industrial.</p>
    </div>
    <div class="itqs-publico__item">
      <i class="it-ico fa-industry" aria-hidden="true"></i>
      <h3>Mantenimiento</h3>
      <p>Consumo recurrente para planta e industria.</p>
    </div>
  </div>
</section>

<section class="itqs-soluciones">
  <div class="itqs-soluciones__grid">
    <div class="itqs-soluciones__txt">
      <h2 class="itqs-display">Cómo se pide.</h2>
      <p>Son tres pasos y no hace falta crear una cuenta. Tu lista se guarda en este navegador mientras la armas.</p>
      <a class="itqs-btn itqs-btn--negro" href="/2-catalogo">Ir al catálogo <i class="it-ico fa-arrow-right" aria-hidden="true"></i></a>
      <p class="itqs-secundario">¿Ya armaste tu lista? <a href="/module/itcotizacion/cotizacion">Ver mi cotización</a></p>
    </div>

    <div class="itqs-pilares">
      <div class="itqs-pilar itqs-pilar--destacado">
        <span class="itqs-pilar__num">01</span>
        <i class="it-ico fa-clipboard-list" aria-hidden="true"></i>
        <h3>Arma tu lista</h3>
        <p>En cada producto pulsa «Agregar a mi cotización» e indica la cantidad.</p>
      </div>
      <div class="itqs-pilar">
        <span class="itqs-pilar__num">02</span>
        <i class="it-ico fa-user-edit" aria-hidden="true"></i>
        <h3>Déjanos tus datos</h3>
        <p>Nombre, documento, teléfono y correo. Nada más.</p>
        <button type="button" class="itqs-btn itqs-btn--negro itqs-btn--paso" id="itqs-abrir-datos"
                aria-expanded="false" aria-controls="itqs-datos">
          Dejar mis datos <i class="it-ico fa-chevron-down" aria-hidden="true"></i>
        </button>
      </div>
      <div class="itqs-pilar">
        <span class="itqs-pilar__num">03</span>
        <i class="it-ico it-ico--marca fa-whatsapp" aria-hidden="true"></i>
        <h3>Te respondemos por WhatsApp</h3>
        <p>Con precio, disponibilidad y tiempo de entrega.</p>
      </div>
    </div>
  </div>

  <!-- Formulario del paso 02. Se despliega justo debajo de los tres pasos, sin
       salir de la pagina. Usa los MISMOS nombres de campo y el MISMO destino que
       el formulario de /module/itcotizacion/cotizacion, asi que el servidor lo
       valida y lo guarda igual: no hay una segunda via de entrada que mantener.
       Empieza con `hidden`; el JS lo abre y lo cierra. -->
  <div class="itqs-datos" id="itqs-datos" hidden>
    <form class="itqs-datos__form" id="itqs-datos-form" method="post" novalidate>
      <p class="itqs-datos__estado" id="itqs-datos-estado" role="status"></p>

      <div class="itcot-campos">
        <div class="itcot-campo itcot-campo--ancho">
          <label for="itqs-nombre">Nombre completo</label>
          <input type="text" id="itqs-nombre" name="nombre" autocomplete="name" required>
          <span class="itcot-error" data-para="nombre"></span>
        </div>
        <div class="itcot-campo">
          <label for="itqs-tipo-doc">Tipo de documento</label>
          <select id="itqs-tipo-doc" name="tipo_doc" required>
            <option value="CC">Cédula de ciudadanía</option>
            <option value="NIT">NIT</option>
            <option value="CE">Cédula de extranjería</option>
            <option value="PP">Pasaporte</option>
            <option value="TI">Tarjeta de identidad</option>
          </select>
          <span class="itcot-error" data-para="tipo_doc"></span>
        </div>
        <div class="itcot-campo">
          <label for="itqs-documento">Número de documento</label>
          <input type="text" id="itqs-documento" name="documento" inputmode="numeric" required>
          <span class="itcot-error" data-para="documento"></span>
        </div>
        <div class="itcot-campo">
          <label for="itqs-telefono">Teléfono / WhatsApp</label>
          <input type="tel" id="itqs-telefono" name="telefono" inputmode="tel" autocomplete="tel" required>
          <span class="itcot-error" data-para="telefono"></span>
        </div>
        <div class="itcot-campo">
          <label for="itqs-email">Correo electrónico</label>
          <input type="email" id="itqs-email" name="email" autocomplete="email" required>
          <span class="itcot-error" data-para="email"></span>
        </div>
        <div class="itcot-campo">
          <label for="itqs-empresa">Empresa <small>(opcional)</small></label>
          <input type="text" id="itqs-empresa" name="empresa" autocomplete="organization">
        </div>
        <div class="itcot-campo">
          <label for="itqs-ciudad">Ciudad <small>(opcional)</small></label>
          <input type="text" id="itqs-ciudad" name="ciudad" autocomplete="address-level2">
        </div>
        <div class="itcot-campo itcot-campo--ancho">
          <label for="itqs-nota">¿Algo que debamos saber? <small>(opcional)</small></label>
          <textarea id="itqs-nota" name="nota" rows="3"></textarea>
        </div>
      </div>

      <span class="itcot-error itcot-error--global" data-para="global"></span>

      <div class="itqs-datos__pie">
        <button type="submit" class="itqs-btn itqs-btn--rojo" id="itqs-datos-btn">
          Enviar y hablar por WhatsApp <i class="it-ico it-ico--marca fa-whatsapp" aria-hidden="true"></i>
        </button>
        <p class="itqs-secundario">Un asesor te responde con precio, disponibilidad y tiempo de entrega.</p>
      </div>
    </form>
  </div>
</section>

<section class="itqs-banda itqs-sinprecio">
  <div class="itqs-rail">
    <h2 class="itqs-display">Por qué el catálogo no muestra precios</h2>
    <p>El catálogo está para que consultes referencias, marcas y fichas. El precio te lo damos por WhatsApp, y no es por ocultarlo:</p>
    <div class="itqs-razones">
      <div class="itqs-razon">
        <h3>Depende de la cantidad</h3>
        <p>No cuesta lo mismo una unidad que una caja. Cotizamos sobre lo que realmente vas a pedir.</p>
      </div>
      <div class="itqs-razon">
        <h3>Somos importadores</h3>
        <p>Un precio publicado se queda viejo. Te damos el que está vigente el día que compras.</p>
      </div>
      <div class="itqs-razon">
        <h3>Cada cliente es distinto</h3>
        <p>Una ferretería que repone cada mes y una obra puntual no tienen las mismas condiciones.</p>
      </div>
    </div>
  </div>
</section>

<section class="itqs-banda itqs-cta">
  <div class="itqs-rail">
    <a class="itqs-btn itqs-btn--blanco" href="/2-catalogo">Ver catálogo completo</a>
    <p>¿Prefieres que te llamemos? Escríbenos y te asignamos un asesor comercial.</p>
    <a class="itqs-cta__wa" href="https://wa.me/573145934962" target="_blank" rel="noopener">
      <i class="it-ico it-ico--marca fa-whatsapp" aria-hidden="true"></i>
      <span><small>Llámanos o escríbenos por WhatsApp</small><strong>+57 314 593 4962</strong></span>
    </a>
  </div>
</section>

<section class="itqs-info">
  <div class="itqs-info__grid">
    <div>
      <h2>Otras formas de contactarnos</h2>
      <ul class="itqs-contacto">
        <li><i class="it-ico fa-phone-alt" aria-hidden="true"></i><span><small>Teléfono y WhatsApp</small><a href="https://wa.me/573145934962" target="_blank" rel="noopener">+57 314 593 4962</a></span></li>
        <li><i class="it-ico fa-envelope" aria-hidden="true"></i><span><small>Correo</small><a href="mailto:ventas@importtoolslatam.com">ventas@importtoolslatam.com</a></span></li>
        <li><i class="it-ico fa-comments" aria-hidden="true"></i><span><small>Formulario</small><a href="/contact-us">Página de contacto</a></span></li>
        <li><i class="it-ico fa-map-marker-alt" aria-hidden="true"></i><span><small>Dirección</small>Carrera Cordialidad Km 2.5 #66, Galapa (Atlántico)</span></li>
        <li><i class="it-ico fa-clock" aria-hidden="true"></i><span><small>Horario</small>Lunes a viernes 8:00 a. m. – 5:00 p. m. · Sábados 8:00 a. m. – 12:00 m.</span></li>
      </ul>
      <p class="itqs-secundario">Si prefieres tener tu historial en la tienda, puedes <a href="/login?create_account=1">crear una cuenta</a>. No es necesario para cotizar.</p>
    </div>

    <div>
      <h2>Antes de escribirnos</h2>
      <ul class="itqs-contacto">
        <li><i class="it-ico fa-search" aria-hidden="true"></i><span><small>Busca por código</small>El buscador acepta el código de la referencia, no solo el nombre.</span></li>
        <li><i class="it-ico fa-filter" aria-hidden="true"></i><span><small>Filtra por línea</small>En cada categoría puedes acotar por marca, línea y sublínea.</span></li>
        <li><i class="it-ico fa-question-circle" aria-hidden="true"></i><span><small>Dudas frecuentes</small><a href="/content/6-preguntas-frecuentes">Preguntas frecuentes</a></span></li>
        <li><i class="it-ico fa-building" aria-hidden="true"></i><span><small>Quiénes somos</small><a href="/content/4-quienes-somos">Conoce la empresa</a></span></li>
      </ul>
    </div>
  </div>
</section>

</div>
'
 WHERE id_cms = 7;

SELECT '--- A.4 DESPUES: deben ser 11.610 (cms 4) y 11.840 (cms 7) ---' AS ``;
SELECT id_cms, id_lang, LENGTH(content) AS bytes_ahora
  FROM psjy_cms_lang WHERE id_cms IN (4, 7) ORDER BY id_cms, id_lang;

-- MARCHA ATRAS del bloque A:
--   UPDATE psjy_cms_lang c
--     JOIN psjy_cms_lang_bk_20260810 b
--       ON b.id_cms = c.id_cms AND b.id_lang = c.id_lang
--      SET c.content = b.content
--    WHERE c.id_cms IN (4, 7);


-- ===========================================================================
-- BLOQUE B — El guardado de banners                     (sustituye al 15-*.php)
-- ===========================================================================

-- B.1  Registrar el hook `actionAdminControllerSetMedia` en `itcotizacion`.
--      Es lo que carga arreglo-leoslideshow.js, que evita que el AJAX del
--      modulo de banners salga a otro dominio y hace visibles sus errores.
--
--      INSERT IGNORE es seguro: la PRIMARY KEY de psjy_hook_module es
--      (id_module, id_hook, id_shop), asi que si ya estaba, no hace nada.

SELECT '--- B.1 antes: 0 = falta el hook, 1 = ya estaba ---' AS ``;
SELECT COUNT(*) AS ya_esta
  FROM psjy_hook_module hm
  JOIN psjy_module m ON m.id_module = hm.id_module
  JOIN psjy_hook   h ON h.id_hook   = hm.id_hook
 WHERE m.name = 'itcotizacion' AND h.name = 'actionAdminControllerSetMedia';

INSERT IGNORE INTO psjy_hook_module (id_module, id_shop, id_hook, position)
SELECT m.id_module, s.id_shop, h.id_hook, 1
  FROM psjy_module m
  JOIN psjy_hook   h ON h.name = 'actionAdminControllerSetMedia'
  JOIN psjy_shop   s
 WHERE m.name = 'itcotizacion';

SELECT '--- B.1 despues: tiene que ser 1 ---' AS ``;
SELECT COUNT(*) AS ahora
  FROM psjy_hook_module hm
  JOIN psjy_module m ON m.id_module = hm.id_module
  JOIN psjy_hook   h ON h.id_hook   = hm.id_hook
 WHERE m.name = 'itcotizacion' AND h.name = 'actionAdminControllerSetMedia';


-- B.2  El grupo que abre el menu del slideshow.
--      Estaba en 4 («Slide Home 5»), un grupo que no sale en ninguna pagina:
--      el cliente editaba banners invisibles. NO se pone un numero a mano: se
--      decide POR DATOS, cruzando el randkey de cada grupo con los contenidos
--      de Leo Elements. Deben salir usados el 3 (escritorio) y el 5 (movil).

SELECT '--- B.2 que grupos se usan de verdad ---' AS ``;
SELECT g.id_leoslideshow_groups AS grupo, g.title,
       (SELECT COUNT(*) FROM psjy_leoelements_contents_lang c
         WHERE c.content LIKE CONCAT('%', g.randkey, '%')) AS usado_en
  FROM psjy_leoslideshow_groups g
 ORDER BY grupo;

SELECT '--- B.2 valor actual ---' AS ``;
SELECT name, value FROM psjy_configuration WHERE name = 'LEOSLIDESHOW_GROUP_DE';

-- Solo cambia si el valor actual NO es uno de los grupos en uso.
UPDATE psjy_configuration
   SET value = (
     SELECT MIN(id) FROM (
       SELECT g.id_leoslideshow_groups AS id
         FROM psjy_leoslideshow_groups g
        WHERE g.randkey <> '' AND EXISTS (
          SELECT 1 FROM psjy_leoelements_contents_lang c
           WHERE c.content LIKE CONCAT('%', g.randkey, '%'))
     ) AS usados
   )
 WHERE name = 'LEOSLIDESHOW_GROUP_DE'
   AND value NOT IN (
     SELECT id FROM (
       SELECT g.id_leoslideshow_groups AS id
         FROM psjy_leoslideshow_groups g
        WHERE g.randkey <> '' AND EXISTS (
          SELECT 1 FROM psjy_leoelements_contents_lang c
           WHERE c.content LIKE CONCAT('%', g.randkey, '%'))
     ) AS usados2
   );

SELECT '--- B.2 despues: tiene que ser un grupo con usado_en > 0 (el 3) ---' AS ``;
SELECT name, value FROM psjy_configuration WHERE name = 'LEOSLIDESHOW_GROUP_DE';

-- MARCHA ATRAS del bloque B:
--   DELETE hm FROM psjy_hook_module hm
--     JOIN psjy_module m ON m.id_module = hm.id_module
--     JOIN psjy_hook   h ON h.id_hook   = hm.id_hook
--    WHERE m.name = 'itcotizacion'
--      AND h.name = 'actionAdminControllerSetMedia';


-- ===========================================================================
-- AHORA VE AL PASO 8 DEL RUNBOOK: vaciar cachés.
-- PrestaShop guarda la configuracion y la lista de hooks en cache; hasta que no
-- vacies var/cache/ estos dos bloques no surten efecto en pantalla.
-- ===========================================================================
