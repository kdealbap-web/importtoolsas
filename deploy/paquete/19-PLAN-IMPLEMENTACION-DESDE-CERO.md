# 19 — Plan de implementación desde cero

**Importtools S.A.S** · `www.importtoolsas.com` · PrestaShop 9.1.4 + tema AutoSoe
Versión del plan: **08/08/2026**

Este documento sirve para dos cosas y hay que leerlo entero antes de tocar nada:

- **Levantar la tienda desde cero** en un servidor vacío, en orden, sin depender de
  la memoria de nadie.
- **Poner al día la instalación que ya está en producción**, que es el caso de hoy.
  Cada paso dice si aplica a un montaje nuevo, a una actualización, o a los dos.

> Lo que ya está hecho y verificado está marcado `[x]`. Lo que sigue abierto, `[ ]`.

> 📌 **Actualizado el 09/08/2026 contra la tienda en línea.** El operativo para ejecutar
> la subida pendiente es **`23-PASO-A-PASO-20260809.md`**, no el 18. Al medir producción
> se cayeron tres pendientes que ya estaban resueltos y se corrigió un script que era
> peligroso (§6 y §13 de este plan siguen siendo válidos como diagnóstico).

---

## 0. Antes de nada: los tres bloqueos abiertos

Se ponen aquí arriba, y no enterrados en un anexo, porque **la tienda no puede
abrirse al público sin resolverlos**. Todo lo demás está listo.

| # | Bloqueo | Por qué bloquea | Quién lo resuelve |
|---|---|---|---|
| 1 | **Casi sin fotos de producto** | **13 de 2.929 tienen foto** (77 imágenes, subidas por el cliente — auditado el 10/08, ver `23-…md` §12). **Mitigado el 08/08** (§13): sin foto la tarjeta muestra la referencia en vez de «Imagen no disponible», así que la tienda ya se puede enseñar. Sigue siendo lo que más cambia la percepción. | Cliente (fotos) |
| 2 | **Precios de prueba en la base** | Los 3.036 llevan un precio generado, marcado con `supplier_reference = 'PRECIO-PRUEBA'`. Hoy no se ven porque el modo catálogo los oculta, pero **saldrían enteros si alguien desactiva el modo catálogo**. | Cliente (lista de precios) |
| 3 | **Dos dominios vivos** | `importtoolsas.com` y `www.importtoolsas.com` responden las dos. Es lo que rompía el módulo de banners (§6). | Proveedor (hosting) |

---

## 1. Servidor y dominio

**Montaje nuevo · ya hecho en producción**

- [x] Hosting **Latinoamérica Hosting H2** (cPanel, LiteSpeed, CloudLinux).
- [x] Dominio `importtoolsas.com` con SSL de Let's Encrypt.
- [ ] **Un solo dominio canónico.** En el `.htaccess` de `public_html`, antes del
      bloque de PrestaShop:
      ```apache
      RewriteEngine On
      RewriteCond %{HTTP_HOST} ^importtoolsas\.com$ [NC]
      RewriteRule ^(.*)$ https://www.importtoolsas.com/$1 [R=301,L]
      ```
      Comprobar: `curl -I https://importtoolsas.com/` → 301 hacia `www`.
- [ ] PHP **8.5**, `memory_limit = 512M`, extensiones curl, dom, gd, intl,
      mbstring, zip, json.
- [ ] JetBackup activo y **probado restaurando una vez**. Un respaldo que nunca se
      ha restaurado no es un respaldo.

## 2. Base de datos y ficheros

**Montaje nuevo**

- [ ] Crear base y usuario dedicados desde cPanel.
- [ ] Importar el volcado de entrega (`backups/importtools-FINAL-*.sql.gz`).
      ⛔ **SOLO en servidor vacío.** Sobre la producción de hoy borraría las 77 fotos,
      los 18 productos nuevos y las categorías que ha tocado el cliente. Igual con
      `02b-limpieza-datos-demo.sql`. Ver `23-PASO-A-PASO-20260809.md` §12.
- [ ] Subir `public_html` completo. ⚠️ **Con los dotfiles**: `.env` y `.htaccess`
      viven en la raíz y un FTP configurado sin «mostrar ocultos» los omite. Sin
      `.env` la tienda da **500 en todo el sitio**; sin `.htaccess`, **404 en toda
      URL amigable**.
- [ ] `app/config/parameters.php` con las credenciales reales y
      `database_prefix => 'psjy_'`.
- [ ] Ejecutar `02-ajustes-tras-importar.sql` (dominio, SSL, URLs).

## 3. Configuración de la tienda

**Ya hecho · repetir solo en montaje nuevo**

- [x] Idioma **es-CO** único (inglés instalado pero inactivo), moneda **COP** sin
      decimales, país y zona **Colombia**, zona horaria `America/Bogota`.
- [x] IVA 19 / 5 / 0 %; las 52 reglas de estados de EE. UU. desactivadas.
- [x] **Modo catálogo**: `PS_CATALOG_MODE = 1`, `PS_CATALOG_MODE_WITH_PRICES = 0`.
      Sin precios, sin carrito, sin pasarela. La venta se cierra por WhatsApp.
- [x] Código postal `082001`; datos fiscales y de contacto reales.
- [x] URLs amigables y los 25 títulos/descripciones SEO en español.

## 4. Catálogo

- [x] 3.036 productos en 15 categorías bajo `Catálogo` (id 2).
- [x] Línea y sublínea como **características**; grupo como **marca**.
- [x] Filtros de `ps_facetedsearch` sobre `Catálogo` y las 15 categorías.
- [x] Marcas visibles: Nikato, Dragon Tools, Proweld, Ventum.
      Proto, Irwin y Grainger quitados del menú (08/08).
      ⚠️ Como el fabricante sigue existiendo, **esas tres aún salen en el filtro
      lateral y en la ficha de sus 16 productos**. Si el cliente quiere que
      desaparezcan del todo, hay que desactivar el fabricante.
- [ ] **Fotos de producto** (bloqueo 1).
- [ ] **Precios reales** (bloqueo 2). Mecanismo listo y probado en
      `06-cargar-precios-reales.sql`.
      ⚠️ **Preguntar antes si los precios del cliente llevan IVA**: `psjy_product.price`
      es el precio SIN impuesto y los tres grupos muestran sin IVA. Equivocarse
      deja el catálogo con un 19 % de desvío.

## 5. Tema y contenido

- [x] Tema hijo `vt_autosoe_child` activo. **Todo cambio de CSS va ahí.**
      ⚠️ El hijo necesita una copia de `themes/vt_autosoe/modules/` (352 ficheros):
      33 módulos de Leo resuelven sus plantillas con `_PS_THEME_DIR_` en vez de usar
      la herencia de PrestaShop, y sin esa carpeta **los widgets no pintan nada, sin
      dar ningún error**. Al actualizar el tema padre hay que volver a copiarla.
- [x] Home, cabecera y pie sin rastro de la plantilla demo.
- [x] Páginas *Quiénes somos* y *Quiero ser cliente* en HTML y CSS (no imágenes),
      con las fotos reales del cliente.
- [x] Módulo propio **`itcotizacion`**: lista, formulario de prospecto, guardado
      para el CRM y salto a WhatsApp.
- [x] **Panel de la cuenta** rediseñado (08/08). Ver §7.

## 6. El módulo de banners (LeoSlideshow)

- [x] Corregido el guardado. Detalle completo en `historico/18-PASO-A-PASO-20260808.md` §6.
      Resumen: el módulo escribía la URL de guardado con el dominio configurado
      (`www`) y el cliente entraba sin `www`; el navegador bloqueaba la petición y
      el JS del módulo no comprueba fallos, así que no salía ningún aviso.
- [x] El menú abre ya un grupo que sí se muestra (antes abría «Slide Home 5», que
      no usa ninguna página).
- [ ] Cerrar la causa de raíz con el 301 del §1.

## 7. Panel de la cuenta — 08/08/2026

**Qué se encontró**

- ⚠️ **En escritorio el panel no se abría con clic ni con teclado.** La regla que lo
  abre vive dentro de `@media (max-width:991px)`:
  ```css
  @media (max-width:991px){ .popup-over.leo_block_top.open .popup-content{opacity:1;visibility:visible} }
  ```
  Fuera de móvil solo quedaba una regla de `:hover` que no toca la opacidad. Medido
  con la clase puesta a mano y la transición terminada: `opacity 0`, `visibility hidden`.
  Consecuencia: con ratón abría de casualidad por una regla genérica que empata en
  especificidad; **con teclado nunca**, y **en tablet grande (>991 px, sin hover)
  el menú de la cuenta era inalcanzable**.
- «Pedidos» apuntaba al **carrito**, que en modo catálogo no existe.
- «Mi cuenta» salía también sin haber entrado, junto a «Entrar» y «Registrarse».
- Seis enlaces de texto sin icono ni jerarquía, en un panel de 180 px.

**Qué se hizo**

- Regla de apertura repetida fuera del media query, más `:focus-within` para teclado.
- Panel a 300 px, con cabecera de identidad (inicial en el rojo de marca, nombre y
  correo), acciones con icono, separadores, y «Cerrar sesión» en rojo al final.
- La **cotización va antes que los favoritos**: es el camino de venta real.
- Sin sesión: dos botones claros y una nota que dice la verdad —para cotizar no
  hace falta cuenta—, en vez de empujar a un registro que nadie necesita.
- En móvil el panel ocupa el ancho con márgenes y las filas crecen para el dedo.
- ⚠️ **La fuente del tema es Font Awesome 5, no 6.** `fa-location-dot`,
  `fa-code-compare` y `fa-arrow-right-from-bracket` **no existen** y se aplican sin
  pintar nada. Comprobado midiendo el ancho del glifo. Se usan `fa-map-marker-alt`,
  `fa-balance-scale` y `fa-sign-out-alt`.

Verificado con sesión real en escritorio (1440), sin sesión y en móvil (390).

## 8. Cuentas de cliente

- [x] Registro, cierre de sesión y reingreso: **funcionan**. El registro deja la
      sesión iniciada; con la contraseña equivocada avisa «Error de autenticación.»
      en español.
- [ ] ⚠️ **«Olvidé mi contraseña»: comprobar en producción.** El flujo encuentra la
      cuenta y genera el enlace, pero al enviar responde «Se ha producido un error
      al enviar el mensaje» (el entorno de pruebas no tiene servidor de correo).
      `PS_MAIL_METHOD = 1`, la función `mail()` de PHP. **Enviar un correo de prueba
      desde el panel.** Si no sale, nadie puede recuperar su contraseña.
- [ ] **«Mantener sesión iniciada» no existe en el front de PrestaShop**, solo en el
      back office. La sesión dura `PS_COOKIE_LIFETIME_FO = 480` minutos.
      ⚠️ Y `PS_COOKIE_CHECKIP = 1` **invalida la cookie al cambiar de IP**: en móvil,
      al pasar de wifi a datos, la sesión se cae sola. Ponerlo a 0 es lo que de verdad
      resuelve lo que pidió el cliente. Es decisión suya: es una protección (débil)
      contra el robo de cookie.

## 9. Seguridad

- [x] Back office en carpeta propia (`panel-4h5o`), no en `/admin`.
- [x] Perfil **Cliente Importtools** acotado: configura módulos, no instala ni
      desinstala. 403 en Tema, Módulos, Empleados, Rendimiento, SQL, Transportistas
      e Impuestos.
- [x] Panel del engranaje del front apagado (`LEOELEMENTS_PANEL_TOOL = 0`).
- [x] ⚠️ **Barrer el docroot de ficheros sueltos.** En el entorno de pruebas había
      tres scripts de depuración (`_inv.php`, `_q.php`, `_sn.php`) que cargaban
      `config.inc.php` y escribían en la base, accesibles por URL y sin ninguna
      autenticación. Se borraron.
      ✅ **Comprobado en producción el 09/08: los tres devuelven 404.** En un montaje
      nuevo, o si vuelve a subirse alguno, la comprobación es:
      ```
      ls -la public_html/_*.php public_html/_*.html 2>/dev/null
      curl -s -o /dev/null -w '%{http_code}\n' https://www.importtoolsas.com/_inv.php
      ```
- [ ] HSTS y revisión de cabeceras de seguridad.

## 10. Auditoría del home (08/08/2026)

Lo que se ve hoy, por orden de importancia:

| # | Qué pasa | Peso | Qué hacer |
|---|---|---|---|
| 1 | **«Imagen no disponible» 16 veces** en una sola pantalla del home | Alto | Bloqueo 1: fotos |
| 2 | **El hero tarda en pintar.** El slideshow monta sus textos con JavaScript por capas; hasta que termina se ve una banda oscura de ~525 px. El contenido sí está en el HTML (comprobado), pero el visitante ve el hueco primero | Medio | Poner la primera diapositiva como imagen de fondo real, no como capas animadas, para que aparezca con el HTML |
| 3 | **Todos los productos llevan la etiqueta verde «Nuevo».** Si todo es nuevo, la etiqueta no informa de nada y solo mete ruido | Medio | Acotar «Nuevo» a los últimos N días, o quitarla |
| 4 | Los nombres de producto van **en mayúsculas y muy largos** («JGO DE LLAVES HEXAGONALES MÉTRICAS 10 PZAS 1.5MM A 10MM»), difíciles de leer en rejilla | Medio | Recortar en el listado y dejar el nombre completo en la ficha |
| 5 | «Novedades del catálogo» queda estrecha y desequilibrada frente al banner grande de al lado | Bajo | Revisar cuando haya fotos: con imagen el bloque se sostiene solo |

> 🔧 **El círculo del banner no es un fallo.** Es `div.iview-timer`, el anillo de
> progreso del propio slideshow. Identificado con `document.elementFromPoint()`.

## 11. Orden de trabajo recomendado

1. **301 a un solo dominio** (§1) — desbloquea el módulo de banners de raíz.
2. **Correo de prueba** (§8) — sin esto no hay recuperación de contraseña.
3. **Barrer el docroot** (§9) — es el único punto con riesgo de seguridad.
4. **Fotos de producto** (§4) — es lo que más cambia la percepción de la tienda.
5. **Precios reales** (§4), preguntando antes lo del IVA.
6. Los ajustes del home (§10, puntos 2 a 5).

## 12. Cómo se despliega cada ronda

Siempre igual, y en este orden:

1. Respaldo JetBackup (base + ficheros) y anotar la hora.
2. Subir los zips generados **con `local-dev/empaquetar.py`**.
   ⚠️ Nunca con `Compress-Archive` de PowerShell: escribe los nombres con barra
   invertida, contra la especificación ZIP, y al extraer en Linux no se crean
   carpetas — sale un fichero plano con la barra en el nombre.
3. Ejecutar los `.sql` y `.php` de la ronda, **primero en seco** cuando lo permitan.
4. Vaciar cachés **como el usuario del hosting**, nunca como root: si
   `var/cache/prod` queda sin escritura, el front devuelve 500 con
   `SmartyException: unable to create directory`.
   Y `DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';`, porque
   esa caché no se invalida vaciando carpetas.
5. **Comprobar con centinelas sobre el CSS y el JS servidos**, no sobre los del
   repositorio: es la única forma de descartar que se esté sirviendo una versión
   anterior.
6. Recorrer la lista de comprobaciones del paso a paso de la ronda.

---

## 13. Catálogo sin fotos: cómo se resolvió (08/08/2026)

**El problema.** `psjy_image` está a 0 filas, así que los 3.036 productos usaban el
marcador del núcleo. En una sola pantalla del home salían **dieciséis** «Imagen no
disponible». Repetir esa frase no informa de nada y es lo primero que ve un mayorista.

**La estrategia.** La tarjeta se adapta a lo que el producto tiene:

- **Sin foto** → no se pinta zona de imagen. Se muestra la **referencia**
  (`NIK-AC2540`) bajo el rótulo «Referencia», y debajo la marca. Es el dato con el que
  un ferretero pide de verdad, así que la carencia se convierte en el dato más útil.
- **Con foto** → la rejilla de siempre, con la imagen completa.

**Lo importante: no hay que hacer nada cuando lleguen las fotos.** La plantilla mira
si el producto tiene imagen y elige el modo. Cada producto pasa al modo con imagen en
cuanto el cliente le sube una desde el panel, **uno a uno**, sin desplegar nada y sin
tocar ninguna configuración. Es tarea del cliente como editor de contenidos, y el
sitio se va viendo mejor solo según avanza.

**Detalles que costaron encontrarse:**

- ⚠️ **La plantilla del listado no es la del núcleo.** Editar
  `catalog/_partials/miniatures/product.tpl` no surtía ningún efecto. La que pinta
  categorías, buscador y carruseles es la de Leo: **`plist3413072022.tpl`**
  («Product style 01»), en
  `themes/vt_autosoe_child/modules/leoelements/views/templates/front/products/`.
  Se editaron las dos, por si algún día se cambia el estilo de listado.
- ⚠️ **Las dos clases de tarjeta tienen que medir lo mismo.** Con foto ocupaba
  ~330 px de alto y con referencia 132: las filas quedaban escalonadas y parecía roto.
  La caja de referencia lleva la misma proporción 1:1 que la foto.
- Las fotos se muestran con `object-fit: contain`, no `cover`: en herramienta el
  recorte se come las puntas y los mangos, que es por donde se reconoce la pieza.

> ⚠️ **Y un aviso que afecta a producción.** `Tools::generateHtaccess()` **escribe el
> dominio dentro del `.htaccess`**: cada regla de imagen va precedida de
> `RewriteCond %{HTTP_HOST} ^www.importtoolsas.com$`. Si la petición llega con otro
> host, la reescritura no ocurre y **la foto da 404 aunque el fichero esté en disco**.
> O sea: **quien entre por `importtoolsas.com` sin www verá todas las fotos de
> producto rotas.** Un motivo más para el 301 del §1. Y si alguna vez se cambia el
> dominio, hay que **regenerar el `.htaccess`** (Back office → Parámetros de la tienda
> → Tráfico y SEO → Guardar).

---

*Documentos relacionados: `historico/18-PASO-A-PASO-20260808.md` (la ronda del 08/08),
`20-CORREO-DEL-DOMINIO.md` (correo), `historico/14-PASO-A-PASO-SUBIDA.md` (la del 03/08),
`historico/11-PLAN-FASE-II.md` y `CLAUDE.md`.*
