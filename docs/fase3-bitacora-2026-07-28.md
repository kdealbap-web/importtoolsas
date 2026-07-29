# Bitácora — 28 de julio de 2026

Peticiones del cliente atendidas en esta sesión, con lo que se encontró al abrirlas.
Complementa `docs/fase3-personalizacion.md`.

---

## 1. Menú

| Petición | Resultado |
|---|---|
| Ocultar "All Departments" | Retirado **su widget** del header 03 (`LeoBootstrapmenu` con `source=ce7aeaae…` en `leoelements_contents_lang` id 10). **No se puede** ocultar poniendo `btmegamenu_group.active = 0`: `cacheGroupsByFields()` es una caché estática compartida y al marcar el grupo 2 inactivo se cae **también el menú principal**. Comprobado con prueba A/B: grupo 2 activo → 36 `nav-item`; inactivo → 0, y los dos widgets muestran *"The Group of LeoBoostrapMenu is not active"*. |
| «en categorías me despliega todo en blanco» | El item tenía `sub_with='widget'` y su `params_widget` apuntaba a widgets `wid-1742285…` que ya no existen, así que `menu_1_widget.tpl` pintaba un panel vacío. Ahora `sub_with='submenu'`, `is_group=1`, `colums=3` y **15 items hijos** de tipo `category`. |
| «al seleccionar CATALOGO sale un dropdown toggle en blanco» | Mismo origen. `INICIO` y `QUIENES SOMOS` lo tenían igual; los tres pasaron a `sub_with='none'` → `menu_1_nochild.tpl`, enlace plano sin toggle. |

Lógica del módulo (`modules/leobootstrapmenu/classes/Btmegamenu.php:652-684`):

```
type == 'html'          -> menu_1_html.tpl
sub_with == 'none'      -> menu_1_nochild.tpl        (enlace plano, SIN dropdown-toggle)
tiene hijos y != widget -> menu_1_haschild.tpl       (submenú real)
sub_with == 'widget'    -> genMegaMenuByConfig()     (panel de widgets; vacío si no existen)
```

## 2. Logo

- El widget (`LeoGenCode` id `595db89`) traía `{if $page.page_name == 'index'}` con el logo
  blanco y `{else}` con `{$shop.logo}` (el de letras azules).
- Leo Elements **cachea el HTML compilado por widget** en
  `modules/leoelements/gencode/LeoGenCode_595db89.html`, así que la rama que se compilaba
  primero se servía en **todas** las páginas: de ahí que el logo cambiara sin lógica aparente.
- Se dejó una sola variante (logo blanco) y se redimensionó el PNG de **1600×280 → 457×80**
  (8,4 KB en vez de 24 KB).
- El tamaño se fija en `custom.css` con un selector de **especificidad (0,2,1)** porque
  `themes/vt_autosoe/modules/leoelements/views/css/positions/headerposition*.css` impone
  `.header__logo img{max-width:160px}` **después** del `custom.css` del hijo (offset
  1.522.296 frente a 1.327.822 en la hoja compilada). Sin eso, `height` y `max-width`
  competirían y la imagen saldría deformada.
- Resultado: **cabecera 228×40 px**, **pie 160×28 px**.

## 3. Presencia real de la empresa

| Dato | Valor aplicado |
|---|---|
| Razón social | Import Tools Latam S.A.S |
| NIT | 901.353.663-6 |
| Dirección | Carrera Cordialidad Km 2.5 #66 |
| Ciudad / Depto. | Galapa / Atlántico (`id_country 69`, `id_state 356`) |
| Coordenadas | 10.9268546, −74.8593972 |
| Teléfono / WhatsApp | +57 314 593 4962 |
| Correo | ventas@importtoolslatam.com |
| Horario | Lun–Vie 8:00–17:00 · Sáb 8:00–12:00 |
| Facebook | facebook.com/profile.php?id=61550973331221 |
| Instagram | instagram.com/importtoolslatam |

- Se creó la **tienda física** (`psjy_store` + `_lang` + `_shop`) con coordenadas y horarios,
  visible en `/stores`.
- Las **7 páginas CMS** se reescribieron en español con los datos reales:
  `quienes-somos`, `envios-y-entregas`, `aviso-legal`, `terminos-y-condiciones`,
  `pago-seguro`, `preguntas-frecuentes`, `quiero-ser-cliente`.
  Donde hay condiciones comerciales sin definir (fletes, plazos, medios de pago) queda un
  aviso visible en vez de texto inventado.
- **Mapa**: iframe de **OpenStreetMap** (sin API key, sin CDN de scripts) + enlace a Google
  Maps. El icono `fa-location-dot` de la cabecera y del pie enlaza a la ficha de Maps.
- El widget de cabecera que decía **"4.9 Google Reviews"** (una valoración inventada) se
  sustituyó por una barra de contacto real: ubicación, teléfono y horario.

## 4. Marcas y filtros

`grupo` → **fabricantes** de PrestaShop:

| Marca | Productos | Logo |
|---|---|---|
| Nikatto | 1.381 | sí |
| Dragon Tools | 27 | sí |
| Proweld | 6 | sí |
| Ventum | 19 | sí |
| Proto | 11 | no |
| Irwin | 4 | no |
| Grainger | 1 | no |

1.587 productos quedan **sin marca** porque su `grupo` no es una marca: `TORNILLERIA`,
`OTRA TORNILLERIA`, `GRUPO IMPORTADOS`, `GRUPO OTRAS LINEAS`, `VARIOS`.

- `linea` y `sublinea` → **características** (88 y 128 valores; 6.072 filas en
  `feature_product`, `id_feature` 3 y 4).
- Plantilla de `ps_facetedsearch` **"Filtros Importtools"** sobre `Catálogo` + las 15
  categorías, con Subcategorías, **Marca**, Precio, Disponibilidad, **Línea** y **Sublínea**
  (`filter_show_limit = 10` en línea y sublínea). La plantilla anterior apuntaba a las
  categorías demo 4, 5, 7 y 8, **ya borradas**, así que no se aplicaba a nada.
- Índices reconstruidos: `indexFeatures()`, `fullPricesIndexProcess()` (6,6 s),
  `buildLayeredCategories()` → 126 filas en `layered_category`.
- Verificado en el front: `/17-herramientas-electricas` muestra
  *Disponibilidad · Línea · Marca · Precio · Sublínea*.
- Carrusel **"Elige tu marca"** en el home con los logos locales `/img/m/{id}.jpg`
  enlazando a `/brand/{id}-{slug}`.
- `leopartsfilter` ("Add Your Vehicle", Marca/Modelo/Año de automóvil) retirado del home:
  es específico de repuestos y estaba en inglés. El módulo queda instalado.

## 5. Dos defectos de fondo

### 5.1 El tema hijo necesita `themes/vt_autosoe/modules/` copiada

**33 ficheros** de los módulos Leo resuelven plantillas con la constante `_PS_THEME_DIR_`
(carpeta del tema **activo**, o sea el hijo) en lugar de usar la herencia de plantillas de
PrestaShop. Por ejemplo `modules/leoelements/includes/widgets/LeoProductCarousel.php`:

```php
$theme_template_path = _PS_THEME_DIR_
    . 'modules/leoelements/views/templates/front/products/' . $settings['source_pl'] . '.tpl';
```

Si esa carpeta no está en el hijo, el `smarty->fetch()` falla y **el widget no pinta nada, sin
error visible**. Los tres bloques de producto del home estaban vacíos por esto. Se copiaron los
**352 ficheros (2,8 MB)** a `themes/vt_autosoe_child/modules/`.

> ⚠️ **Al actualizar el tema padre hay que volver a copiar esa carpeta.**

### 5.2 Los productos no estaban en la categoría raíz

Los 3.036 productos se importaron solo en su categoría específica, no en `Catálogo` (id 2).
Consecuencia: `/2-catalogo` salía vacío y los carruseles del home mostraban
*"No products at this time"* (9 avisos `leo-lib-error`). Se añadió la relación en
`category_product`; `/2-catalogo` lista ahora **"Hay 3036 productos"** y el home pinta
**140 miniaturas** en 0,2 s.

## 6. Afirmaciones falsas del demo eliminadas

`30 Year of Service`, `100% Customer satisfaction rate`, `4.9 Google Reviews`,
`Up to 20% off`, `Save up 50% off`, `save $20 off`, `fast Free shipping $99`,
`We provide same day and next day delivery`, y una **cuenta atrás (`LeoCountDown`) caducada
el 2025-06-04** de una oferta que no existe.

Verificado a 0 apariciones en la portada: `Autosoe`, `demo@demo.com`, `+1(800) 123 456`,
`All Departments`, `Shop Now`, `Discover Now`, `Add Your Vehicle`, `Lorem`, `ipsum`,
`192.168.1.80`, `localhost/prestashop`.

## 7. Lo que quedaba en inglés — resuelto (y corrección de un diagnóstico mío)

> ⚠️ **Corrijo lo que dije primero.** Afirmé que el catálogo de traducciones «nunca se
> importó» porque `psjy_translation` tenía 0 filas. **Era una conclusión equivocada**: en
> PrestaShop 1.7+ las traducciones Symfony viven en **ficheros XLIFF en disco**
> (`translations/es-CO/`, 169 ficheros) y esa tabla solo guarda las ediciones manuales hechas
> desde el back office. Cero filas es lo normal. El paquete **es-CO estaba instalado y
> completo** (p. ej. `Clear all` → `Limpiar todo`), y Symfony ya tenía su catálogo compilado
> en `var/cache/prod/translations/`.

Las causas reales del inglés que quedaba eran cinco, y ninguna era el paquete de idioma:

**7.1 El personalizador de la demo del tema se estaba sirviendo en la tienda pública.**
`LEOELEMENTS_PANEL_TOOL = 1` renderiza
`modules/leoelements/views/templates/front/info/paneltool.tpl`: selectores de fuente y de
color con 33 enlaces `Clear`. Es una función de escaparate del autor del tema. Apagado
(`= 0`): **−28.459 bytes por página**, `Clear` 33 → 0 y `href="#"` 48 → 15.

**7.2 `{l s='Quick view'}` sin dominio** en 30 sitios (los 15 estilos de listado de
producto). La traducción existía (`Vista rápida` en `Shop.Theme.Actions`), pero sin `d=` el
traductor no la encuentra. Añadido el dominio en el tema hijo.

**7.3 El tema pide cadenas a dominios donde el core no las tiene.**
`Wishlist`, `My account`, `Compare`… se piden con `d='Shop.Theme.Global'`, pero ahí no están
(`My account`, por ejemplo, vive en `ShopNavigation`). Se creó el **catálogo propio del tema
hijo**, que es el mecanismo soportado para esto:

```
themes/vt_autosoe_child/translations/es-CO/
    ShopThemeGlobal.es-CO.xlf                (14 cadenas)
    ShopThemeActions.es-CO.xlf               (3)
    ModulesEmailsubscriptionShop.es-CO.xlf   (4)
```

**7.4 Contenido demo en portadas y cabeceras que sí se renderizan.**
`contents=17` (cabecera de categoría, visible en **todas** las categorías) traía
`Pennzoil full synthetic oil change with coupon`, `save $20 off`, `up to $100 off`,
`Select brake service packages…`. Y en `contents` 11/15/16 quedaba
`Sale 15% Off bridgestone tires` y `Exclusive Offers and Coupons` (×15 cada una).
Todo reescrito en español y **sin descuentos inventados**.

**7.5 Títulos SEO y asuntos de contacto son datos, no cadenas traducibles.**
`psjy_meta_lang` tenía los títulos de pestaña en inglés (`Contact us`, `Best sellers`,
`Brands`…): 25 páginas reescritas. `psjy_contact_lang` tenía `Webmaster` /
`Customer service`: ahora `Soporte del sitio web` / `Atención al cliente`, y ambos apuntan a
`ventas@importtoolslatam.com` en vez de al correo de desarrollo.

**7.6 `iso_code` del idioma: `cb` → `es`.**
`cb` no es un ISO válido. Los buscadores de traducción heredados (`{l s='X' mod='Y'}`) usan
`iso_code` para localizar `modules/{módulo}/translations/{iso}.php`, así que con `cb` nunca
encontraban nada. Con `es` ya resuelven, y se completó
`modules/leoproductsearch/translations/es.php` (copia en `deploy/translations/`).

### Resultado

Auditoría sobre 10 páginas (texto entre etiquetas + `title`/`alt`/`placeholder`/`aria-label`,
descartando lo marcado como `hidden`): **0 textos en inglés**.

La única aparición de la palabra `search` que queda es
`<i class="material-icons search">search</i>`: **no es texto**, es la ligadura de Material
Icons — la palabra *es* el nombre del icono y la fuente la dibuja como una lupa. Traducirla
rompería el icono. El `placeholder` del buscador sí dice «Buscar».

## 8. Respaldo

`backups/contenido-AAAAMMDD-HHMM.sql.gz` (carpeta ignorada en git) con las tablas de
contenido: Leo Elements, slideshow, megamenú, CMS, fabricantes, características, filtros y
tiendas.

El contenido original del demo se puede recuperar siempre desde
`themes/vt_autosoe/samples/*.xml` (`leoelements.xml` son 9,3 MB con toda la portada original).

> Nota: los respaldos JSON que estos scripts intentaron escribir en `/var/www/backups` **no
> se crearon** — esa ruta no existe dentro del contenedor y `file_put_contents()` devuelve
> `false` sin lanzar error. Los volcados SQL de arriba los sustituyen.

## 9. Segunda ronda del 28/07 (correcciones pedidas por el cliente)

### 9.1 Datos cerrados por el cliente

- **Código postal: `082001`** → `PS_SHOP_CODE` y `psjy_store.postcode`.
- **La ficha de Google Maps a nombre de "HERRAMIENTAS Y SEGURIDAD S.A." es correcta**: así se
  conoce también a la empresa. No se cambia.
- **El correo `@importtoolslatam.com` con dominio distinto al de la tienda se mantiene**: es
  una recomendación del cliente. No se unifica.

### 9.2 Los desplegables salían abiertos

`genFrontTree()` elige la clase del panel según `is_group`:

```php
$class = $parent['is_group'] ? 'dropdown-mega' : 'dropdown-menu';
```

`.dropdown-mega` **no tiene ninguna regla en el tema**, así que el panel quedaba visible
permanentemente y descolocaba la portada. `.dropdown-menu` sí la tiene:

```css
.leo-megamenu .dropdown-menu            { display:block; opacity:0; visibility:hidden;
                                          transform:translateY(20px); transition:.25s }
.leo-megamenu .dropdown:hover > .dropdown-menu { opacity:1; visibility:visible; transform:none }
```

→ **`is_group = 0`** en CATEGORIAS. Ahora abre solo al pasar el mouse, con transición de 0,25 s.

Además `leobootstrapmenu.js:449` hace
`$('.dropdown-menu.level1').parent().removeClass('aligned-fullwidth')`, así que el panel no
puede ir a todo el ancho y el tema lo deja en `width:max-content`. Como dentro llevamos
columnas Bootstrap (`ul.col-md-4`), sin un ancho concreto la rejilla se colapsa: se fija en
`custom.css` (740 px para las 3 columnas de CATEGORIAS, 440 px para las 2 de MARCAS).

### 9.3 Sección MARCAS en el menú

Nuevo item de primer nivel (`id 61`, `type='url'` → `/brands`) con las 7 marcas como hijos,
en el orden pedido: Nikatto, Dragon Tools, Proweld, Ventum, Proto, Irwin, Grainger.
Misma mecánica que CATEGORIAS (`sub_with='submenu'`, `is_group=0`, `colums=2`), así que
también abre solo al pasar el mouse.

Orden final: `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO`.

### 9.4 Rejilla de las tarjetas

El diseño reserva un espacio fijo por rótulo y mis textos de la primera pasada eran más
largos que los originales en inglés, así que se solapaban. Se recortaron al presupuesto del
original (p. ej. `454590f`: "Tornillería al por mayor" 24 car. → "Tornillería" 11, frente a
"Up to 20% off" 13).

Las dos tarjetas de media anchura (`b9df906` y `0712bb7`) traen ambas `min-height:320px`,
pero **la segunda tiene un widget menos** (le falta el subtítulo de 22 px), así que con
contenido desigual quedaban de distinto alto. Se igualaron por dos vías: textos de longitud
equivalente y una regla en `custom.css` con `min-height:340px` + `align-content:center`.

> La regla del tema (`.elementor-11 .elementor-element.elementor-element-XXX > .elementor-container`,
> especificidad 0,3,1) viaja en un `<style>` **en línea**, es decir después del `custom.css`.
> Se gana anteponiendo `body` (0,3,2), sin `!important`.

### 9.5 Barra superior en inglés

Estaba en `leoelements_contents_lang` id **13** (el nombre de la fila dice "header 04", pero
es la que se renderiza). Traducido y además **corregido el horario**, que anunciaba
`Opening hour: 8am - 10pm` cuando el real es 8:00–17:00 / sábados 8:00–12:00.

### 9.6 Imágenes: fuera el enfoque automotriz y fuera la dependencia externa

- **214 → 0 referencias a `cdn.shopify.com`** en todo el sitio.
- Los **fondos de banner** (fotos de coches, frenos, llantas) se sustituyeron por degradados
  de marca generados con GD: `banner-a/b/c`, `banner-med-a/b`, `banner-ancho`, `fondo-cat`,
  `slide-1/2`, más 6 tarjetas de categoría.
- Los **iconos, la tira de medios de pago y el resto** se descargaron y ahora se sirven desde
  **`/img/it/`** (136 ficheros, 4,2 MB). Copia versionada en **`deploy/img/it/`**.
- Las fotos de piezas de coche de las diapositivas se anularon con un GIF transparente de
  1 px, para no mover las capas que están posicionadas en absoluto.

> ⚠️ **Al desplegar a producción hay que subir `deploy/img/it/` a `<docroot>/img/it/`.**
> `img/` no forma parte del tema y no viaja con él.

### 9.7 Dos cosas que me costaron encontrar

**a) El CSS de Elementor se cachea en la base de datos.**
`psjy_leoelements_meta` guarda el CSS generado con `name = '_elementor_css_id_lang_N'`.
Vaciar `var/cache/`, `assets/cache/` y `modules/leoelements/gencode/` **no lo invalida**:
las páginas seguían sirviendo las URLs viejas del CDN aunque la base de datos ya estaba
limpia. Hay que borrar esas filas:

```sql
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
```

**b) Me equivoqué al localizar las imágenes y corrompí 36 filas.**
Usé la expresión `#https?:(?:\\/|/)+cdn\.shopify\.com[^"'\\\s)]*#`, que **excluye la barra
invertida** — y las URLs dentro del JSON de Elementor usan `\/` como separador. El patrón
cortaba en el primer `\/` y generaba rutas como
`/img/it/https___cdn.shopify.com/s/files/...`. Afectó solo a contenidos **inactivos** (1, 2,
3…), así que no se vio nada roto en el front, pero quedó corrupto en base de datos.
Revertido (36 filas) y rehecho con un patrón que sí admite `\/`, más una comprobación de que
el JSON sigue siendo válido antes de guardar: **0 filas corruptas, 0 JSON roto**.

## 9-bis. Respeto a la plantilla original — y un error mío que hubo que revertir

### 9-bis.1 Apagué el panel de personalización de Leo. Estaba mal.

Interpreté `LEOELEMENTS_PANEL_TOOL` como andamiaje de la demo (los 33 enlaces `Clear` en
inglés venían de ahí) y lo puse a `0` **por criterio propio, sin preguntar**. Es la
herramienta con la que el cliente personaliza el tema: el engranaje lateral derecho
(`<div id="leo-paneltool">`). **Restaurado a `1`** y verificado: el contenedor vuelve a
salir en todas las páginas y su `paneltool.css` / `paneltool.js` responden 200.

Queda dicho, para que sea una decisión consciente y no un descubrimiento en producción: ese
panel expone selectores de color y de tipografía **a cualquier visitante**. Si algún día se
quiere quitar de la tienda pública sin perder la capacidad de personalizar, la vía es
dejarlo activo solo para empleados con sesión abierta, no desactivarlo.

### 9-bis.2 Estado real del tema

| | |
|---|---|
| Ficheros del tema **padre** modificados | **0** |
| Plantillas del **hijo** que difieren del padre | 15, y el único cambio es añadir `d='Shop.Theme.Actions'` a `{l s='Quick view'}` |
| Ficheros propios del hijo | `assets/css/custom.css`, `translations/es-CO/` (3 XLIFF), `assets/img/logo-white.png` (+ el original guardado como `.THEME-ORIGINAL.png`) |

Perfil, cabecera, pie y estilos siguen siendo los que eligió el cliente: **perfil 3 (Home 3)**
activo, **Product style 01** (`plist3413072022`) y **`category__style--1`**.

### 9-bis.3 `dropdown-mega` vs `dropdown-menu`: por qué el desplegable usa `is_group = 0`

`genFrontTree()` elige la clase del panel según `is_group`:

```php
$class = $parent['is_group'] ? 'dropdown-mega' : 'dropdown-menu';
```

Probé `is_group = 1` para conservar el panel «mega» del tema y **el resultado habría sido
peor**: en este tema `.dropdown-mega` **no tiene ni una regla de CSS**. Todo el aspecto y el
comportamiento los recibe `.dropdown-menu`:

```css
.leo-megamenu .dropdown-menu { background-color:#fff; padding:20px 30px;
                               box-shadow:0 6px 15px rgb(0 0 0 / .12);
                               opacity:0; visibility:hidden; display:block;
                               transition:opacity .25s, visibility .25s, transform .25s }
.leo-megamenu .dropdown:hover > .dropdown-menu { opacity:1; visibility:visible; transform:none }
```

Con `dropdown-mega` el panel saldría **transparente, sin padding y sin sombra**. Así que
`is_group = 0` no es apartarse de la plantilla: es usar la clase que la plantilla estiliza,
con su propia animación de 0,25 s.

Lo único que hay que compensar es que **el propio JS del tema** le quita la variante a todo
el ancho: `leobootstrapmenu.js:449` ejecuta
`$('.dropdown-menu.level1').parent().removeClass('aligned-fullwidth')`, con lo que el panel
queda en `width:max-content` y las columnas Bootstrap de dentro pierden su ancho de
referencia. De ahí las dos únicas reglas de ancho en `custom.css`.

### 9-bis.4 Todo mi CSS, con su motivo

`custom.css` tiene 4 bloques y ninguno global:

1. **Logo** — obligado: el del cliente mide 1600×280 px y el de AutoSoe 204×44.
2. **Ancho de los dos paneles** (740 px / 440 px) — por el `removeClass` del punto anterior.
3. **Reset de viñetas** del `ul` dentro del panel.
4. **Igualar las dos tarjetas de media anchura** (`min-height:340px`) — la única desviación
   deliberada, y está marcada como tal en el fichero: se borra el bloque y vuelve el
   comportamiento original.

Se retiraron dos reglas de una versión anterior que sí eran demasiado amplias: un
`overflow-wrap` global a todos los titulares y un `min-height:300px` que repetía el valor
que ya pone el tema.

### 9-bis.5 Cómo edita el cliente (verificado)

- **Panel lateral del front** (engranaje derecho): colores, tipografías y opciones del tema.
- **Back office → Diseño → Leo Elements**: los **17 contenidos** conservan su JSON válido y
  sus widgets intactos (la portada activa, `contents=11`, tiene 116 elementos y 60 widgets).
  Comprobado uno a uno: **0 contenidos con JSON roto**.
- **Leo Bootstrap Menu**: el menú, incluidas las secciones CATEGORIAS y MARCAS con sus hijos.
- **Leo Slideshow**: las diapositivas y sus capas.

### 9-bis.6 Widgets de la plantilla que dejé de usar — y cómo volver a ponerlos

| Widget | Era | Motivo |
|---|---|---|
| `54678dd` | `star-rating` «4.9 Google Reviews» | Valoración inventada. Sustituido por un bloque HTML con ubicación, teléfono y horario reales. |
| `c6edd1e` | `LeoBootstrapmenu` vertical «All Departments» | Lo pediste tú. |
| `7c29c7b` | `LeoCountDown` | Cuenta atrás caducada el 2025-06-04 de una oferta inexistente. |
| `26ca440` | `LeoModule` `leopartsfilter` | Filtro Marca/Modelo/Año de automóvil, no aplica a ferretería. |

Los cuatro se vuelven a añadir desde Leo Elements arrastrando el widget. Y el contenido
original completo del demo está en `themes/vt_autosoe/samples/leoelements.xml` (9,3 MB) y en
los volcados de `backups/`.

## 10. Lo que no pude hacer

**Las imágenes del Instagram oficial.** No se pueden traer desde aquí:

1. `WebFetch` a `instagram.com/importtoolslatam` falla con *"unable to verify the first
   certificate"*.
2. Aun funcionando, el listado de publicaciones de Instagram exige sesión.
3. Y sobre todo: las URLs del CDN de Instagram van **firmadas y caducan**, así que enlazarlas
   dejaría la tienda con imágenes rotas en pocos días — sería volver al problema del CDN
   ajeno que acabamos de quitar.

Los degradados de marca que puse son **provisionales**: quitan el enfoque automotriz y no
inventan fotos de producto. Para cerrarlo necesito los archivos: una carpeta con las fotos
(bodega, herramienta en uso, producto sobre fondo claro) y, si es posible, **fotos de
producto**, porque ahora mismo **los 3.036 productos no tienen ninguna imagen**
(`psjy_image` = 0 filas) y el listado sale con el marcador de "sin imagen".

## 11. Pendientes que quedan

- **Fotos reales de la empresa y de producto.** Es el bloqueo principal: 3.036 productos sin
  imagen y los degradados de marca son provisionales. Ver §10.
- Colores y tipografías de marca (`--it-red #E2211C`, `--it-navy #1F3864`) en cabecera,
  botones, precios y etiquetas.
- Confirmar la escritura de la dirección: el cliente escribió `CARRERA CORDIALIDAD KM 2 5 66`
  y se publicó como `Carrera Cordialidad Km 2.5 #66`. Código postal ya cerrado: `082001`.
- Datos demo restantes: 2 clientes, 5 pedidos, 5 carritos, 2 proveedores, 4 transportistas.
- Al desplegar: subir `deploy/img/it/` a `<docroot>/img/it/` y borrar la caché de CSS de
  Elementor (§9.7a).
- Precios de prueba activos (`supplier_reference = 'PRECIO-PRUEBA'`); revertir con
  `db/import/revertir-precios-prueba.sql` antes de producción.
