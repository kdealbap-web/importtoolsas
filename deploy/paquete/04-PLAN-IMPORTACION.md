# Plan de importación a producción

Import Tools Latam S.A.S · `www.importtoolsas.com` · hosting Latinoamérica Hosting H2 (cPanel)
Prefijo de tablas `psjy_` · back office `panel-4h5o` · PrestaShop 9.1.4 · PHP 8.5

Duración estimada: **50–70 minutos**, más 20 de comprobaciones.
Hazlo en horario de baja actividad: el paso 3 sustituye la base de datos.

---

## Fase 0 — Antes de tocar nada (10 min)

| # | Acción | Cómo se comprueba |
|---|---|---|
| 0.1 | **JetBackup: respaldo completo** (archivos + base de datos) y esperar a que termine | El respaldo aparece listado con la fecha de hoy |
| 0.2 | Anotar el nombre exacto de la base de datos y su usuario | cPanel → MySQL Databases |
| 0.3 | Ejecutar **`00-comprobacion-antes-de-importar.sql`** en phpMyAdmin | Todo de solo lectura. Cómo leer el resultado, en el propio script |
| 0.4 | Activar mantenimiento y **añadir tu IP** a las permitidas | La tienda muestra la página de mantenimiento; tú sigues viéndola |
| 0.5 | Comprobar PHP 8.5 y `memory_limit ≥ 512M` | cPanel → MultiPHP INI Editor |

> El paso 0.3 sustituye a mirar las consultas una a una: devuelve en una fila los productos,
> las tres fechas, la versión, el dominio, los idiomas y el prefijo de tablas.
>
> ⚠️ Ojo con el **orden de 0.3 y 0.4** si quieres la página de mantenimiento en español: la
> corrección de `PS_MAINTENANCE_TEXT` viaja **dentro del volcado**, así que llega después de que
> actives el mantenimiento. El `00-comprobacion` trae al final el `UPDATE` de una línea para
> aplicarlo antes, comentado. Si te da igual (son ~60 min de ventana), sáltatelo.

> Si el paso 0.1 falla, **para aquí**. Todo lo demás es reversible solo con ese respaldo.

---

## Fase 1 — Ficheros (15 min)

**1.1 Imágenes.** Subir `img-importtools.zip` a la raíz de la tienda y extraer. Debe quedar:

```
img/it/          135 ficheros   (fondos de marca, iconos, medios de pago)
img/m/3.jpg … 9.jpg              (logotipos de Nikatto, Dragon Tools, Proweld, Ventum…)
img/logo-importtools-white.png
img/logo-importtools-dark.png
```

Comprobación: abrir `https://www.importtoolsas.com/img/it/tornilleria.jpg` → debe mostrar el degradado azul.

**1.2 Traducciones de módulo.** Subir:

```
modules/leoelements/translations/es.php          (564 claves)
modules/leoproductsearch/translations/es.php     (25 claves)
```

⚠️ **Hay que subir los dos. Que ya exista un `es.php` no lo hace innecesario** — lo comprobé
quitándolos y midiendo qué se rompe:

| Fichero | ¿Lo trae el tema? | Si NO subes el nuestro |
|---|---|---|
| `leoproductsearch/translations/es.php` | **Sí**, 17 claves ya en español | El buscador de la cabecera muestra **«Search here...»** en inglés, 2 veces en **todas** las páginas (versión escritorio y móvil) |
| `leoelements/translations/es.php` | **No.** Esa carpeta solo trae `index.php` | Las **151 etiquetas del personalizador del cliente** salen en inglés: *Block Heading Color*, *Button Background*, *Available fonts*… La tienda pública no cambia |

Sobrescribir `leoproductsearch` **es seguro**: comprobado clave por clave que el nuestro
contiene las 17 del fabricante **sin cambiar una sola traducción** y añade 8.

Por qué hacen falta esas 8, aunque el fabricante ya traduzca: `Translate.php:130-137` busca la
clave en dos pasos — primero con el nombre del **tema activo**, y si no la encuentra, con
`prestashop`. Las 2 que importan son del buscador y **el fabricante no las tiene con ningún
prefijo**, así que caían al original inglés:

```
<{leoproductsearch}prestashop>leosearch_top_…073a75f  = 'Buscar aquí...'   <- ESTA es la visible
<{leoproductsearch}prestashop>leosearch_top_…06a943c  = 'buscar'
```

Comprobado A/B en el espejo: con el fichero del fabricante,
`<p class="title_block">Search here...</p>` sale 2 veces en la portada; con el nuestro,
«Buscar aquí...».

El de `leoelements` es de otra naturaleza: sus 564 claves son **del back office**, no del front
(285 del personalizador de perfiles + 279 del panel público, que está apagado). Quitarlo no
cambia ni un byte del HTML de la portada — lo verifiqué comparando el texto renderizado línea a
línea — pero deja al cliente la pantalla de colores y tipografías en inglés. Prueba directa:

```
sin el fichero:  Block Heading Color -> Block Heading Color   (sin traducir)
con el fichero:  Block Heading Color -> Color del título del bloque
```

Comprobado clave por clave: del original de `leoproductsearch` **no se pierde ninguna** y **no
se cambia ninguna traducción existente**. Las 8 que añadimos son las mismas cadenas repetidas
con el prefijo del tema, que es lo que hace falta para que se apliquen:

```
<{leoproductsearch}prestashop>…        17 originales + 2
<{leoproductsearch}vt_autosoe>…         3   ← el tema sobrescribe las plantillas del módulo,
<{leoproductsearch}vt_autosoe_child>…   3      así que PrestaShop busca la cadena bajo el
                                               nombre del tema activo, no bajo «prestashop»
```

Que `leoelements` no traiga traducciones no es un descuido del fabricante: es la razón por la
que la tienda salía en inglés (ver §7 de la bitácora del 28/07).

Además, el tema hijo lleva dentro del zip un tercer fichero,
`themes/vt_autosoe_child/modules/leoquicklogin/translations/es.php` (15 claves). No hay que
subirlo aparte: va en `vt_autosoe_child.zip`. Está ahí y no en la carpeta del módulo a propósito
— el core carga primero el del módulo y después el del tema, y hace `array_merge`, así que el
del tema **añade sin sustituir** las 109 claves del fabricante, y sobrevive a una actualización
del módulo.

**Antes de subir, renombra el que exista en lugar de machacarlo** — cuesta diez segundos y deja
marcha atrás:

```
mv modules/leoproductsearch/translations/es.php modules/leoproductsearch/translations/es.php.bak
```

El original del fabricante está guardado en el repositorio, en
`deploy/translations/FABRICANTE-original-leoproductsearch-es.php`, por si hiciera falta volver.

Y si en `leoelements/translations/` **sí** hubiera un `es.php` en producción, **no lo
sobrescribas todavía**: en el entorno espejo no existe, así que sería algo que no hemos visto.
Guárdalo y compara antes:

```
grep -c '^\$_MODULE\[' modules/leoelements/translations/es.php
```

Si devuelve **564**, es el nuestro (ya subido antes) y no hay nada que hacer. Cualquier otro
número: pásamelo antes de tocarlo.

**1.3 Tema hijo.** Back office → **Diseño → Tema y logotipo → Añadir nuevo tema → subir
`vt_autosoe_child.zip`**. Luego **Usar este tema**.

> ⚠️ El tema padre **`vt_autosoe` debe seguir instalado**. El hijo lo necesita: sin él no
> hay plantillas y la tienda se cae.

Comprobación: la lista de temas muestra `Importtools (AutoSoe child)` como activo.

---

## Fase 2 — Base de datos (20 min)

**2.1** phpMyAdmin → seleccionar la base de datos de la tienda.

**2.2** Importar **`backups/importtools-FINAL-20260729-1726.sql.gz`** — usa este, no uno
anterior: es el único que trae la limpieza de datos de ejemplo y los textos en inglés
corregidos (ver más abajo). El volcado trae `DROP TABLE IF EXISTS`, así que **reemplaza** el
contenido anterior.

Si phpMyAdmin da tiempo de espera, usar cPanel → Terminal:

```
mysql -u USUARIO -p BASEDEDATOS < importtools-FINAL-20260729-1726.sql
```

**2.3** Ejecutar **`02-ajustes-tras-importar.sql`**. Es obligatorio: cambia el dominio (el
volcado viene con `localhost:8080` en `psjy_shop_url`), activa HTTPS y **vacía la caché de CSS
de Elementor**.

**2.4** **`02b-limpieza-datos-demo.sql` y `02c-textos-en-ingles-en-datos.sql` ya están
aplicados al volcado.** No hay que ejecutarlos. Se incluyen para dejar constancia de qué se
cambió y para poder repetirlo si algún día se importa un volcado anterior.

**2.5** Decidir sobre **`03-opcional-precios-prueba.sql`** (ver Fase 5).

### Textos que estaban en inglés porque son DATOS, no cadenas (corregido el 29/07)

Los encontré leyendo el HTML servido, no los ficheros de traducción — y por eso la auditoría de
idioma del 28/07 los pasó por alto: buscaba cadenas traducibles.

| Dónde se veía | Clave | Por qué estaba en inglés |
|---|---|---|
| Radios *Mr./Mrs.* del formulario de registro | `psjy_gender_lang` | Son datos del catálogo, nunca pasan por traducción |
| Casilla *«I agree to the terms and conditions…»* en el registro | `PSGDPR_CREATION_FORM`, `PSGDPR_CUSTOMER_FORM` | `psgdpr.php:45` elige el texto **por código ISO al instalarse**. Tiene entrada `'es'` correcta, pero también `'cb' => …` en inglés, y el módulo se instaló cuando el idioma tenía `iso_code = 'cb'` (el ISO inválido que corregimos a `es` después) |
| Aviso de privacidad del registro | `CUSTPRIV_MSG_AUTH` | Igual: semilla en inglés |
| Nota de baja del boletín (en `<p class="hidden">`, no visible) | `NW_CONDITIONS` | `ps_emailsubscription.php:1414`, `getConditionFixtures()`: misma semilla al instalar |
| **Página de mantenimiento** | `PS_MAINTENANCE_TEXT` | Texto de fábrica. **Importa para este despliegue**: la Fase 0.4 manda activar mantenimiento, así que sin esto los clientes habrían visto *«We are currently updating our shop…»* durante la importación |

Cambiar el `iso_code` después **no reescribe lo ya guardado**, que es la razón de que
sobrevivieran. Detalle y marcha atrás en `02c-textos-en-ingles-en-datos.sql`.

Queda **a propósito** en inglés `PS_SEARCH_BLACKLIST` (las palabras que el buscador ignora):
cambiarla obliga a reconstruir el índice y es una decisión sobre el buscador, no una
traducción. La alternativa en español está preparada y comentada en ese mismo script.

### «Quick view» salía 140 veces en inglés en la portada

También corregido el 29/07, y es de otra clase: sí era una cadena, pero **pedida de una forma
que PrestaShop 9 no puede traducir**. Las 15 plantillas de listado la pedían con
`{l s='Quick view'}`, sin `d=` ni `mod=`. En ese caso `smartyfront.config.inc.php:285` no
consulta ni el XLIFF del tema ni el fichero del módulo: usa `$_LANG`, que **en PrestaShop 9 no
se rellena nunca** (ningún tema tiene ya carpeta `lang/`), así que devuelve el original inglés.

El arreglo es en el origen: las 15 plantillas del **tema hijo** ahora piden
`{l s='Quick view' d='Shop.Theme.Actions'}`, y la traducción ya estaba en el XLIFF del hijo.
Viene dentro de `vt_autosoe_child.zip`.

> Barrido completo del tema hijo: **858** llamadas `{l …}`, 587 con `d=`, 271 con `mod=`,
> **0 intraducibles**. De las 271 con `mod=`, 56 no tienen clave en el fichero del módulo, pero
> ninguna se renderiza en las páginas del sitio (son ramas inactivas de listados, el popup de
> `leopopupsale` y el formulario de `leoquicklogin`).

### Qué se limpió antes de generar el volcado (29/07, tras auditar el paquete)

| Hallazgo | Por qué importaba |
|---|---|
| **2 botones de la página «Quiero ser cliente» apuntaban a `http://localhost:8080/`** (*Crear mi cuenta* y el enlace a contacto) | Era el único fallo que habría llegado roto a producción. Ahora son relativos: `/login?create_account=1` y `/contact-us`, que son las URL amigables reales en es-CO |
| 1.822 visitas · 1.902 invitados · 1.855 orígenes de tráfico, generados por mis pruebas en local | El cuadro de mando del cliente habría arrancado con estadísticas falsas de julio de 2026 |
| 5 pedidos de ejemplo de PrestaShop (John DOE) con líneas de camisetas y tazas ya borradas | Se veían como 5 ventas inexistentes en el panel |
| Cliente demo John DOE, 6 carritos, 5 direcciones (París, Miami, New York, Bayonne) y 2 proveedores demo | Datos ajenos en la base del cliente. Se conserva el cliente 1 «Anonymous», que lo necesita el módulo de RGPD |
| Un correo comercial no solicitado en atención al cliente | Entró por el formulario cuando el sitio servía la demo del tema |
| `pub@prestashop.com` en 2 filas de configuración de módulos que ya no existen | No se mostraba en la tienda (comprobado), pero dejaba correos ajenos en la base |
| `GBLEOELEMENTS`: atajos del back office del autor del tema (`192.168.1.80` + sus tokens + `D:\xampp\...`) | El cliente los habría visto muertos dentro del editor. Leo lo regenera solo con la URL correcta al abrir el editor |

Lo que **no** se tocó, a propósito: 14 filas de contenidos de Leo llevan URLs a
`192.168.1.80` dentro del JSON de Elementor, heredadas del `leoelements.xml` del tema.
**No se renderizan** — el HTML de portada, catálogo, categoría, marcas y *Quiénes somos*
tiene 0 apariciones de `192.168` — y editar ese JSON por SQL es justo lo que corrompe los
contenidos de Leo.

### Ya probado

Restauré este volcado en una base limpia (`prueba_final`) y pasan las 25 comprobaciones:

```
productos 3036 · en catálogo 3036 · stock 3036 · categorías activas 17
marcas 7 · características 6072 · contenidos Leo 34 (JSON válido 34/34)
perfiles Leo 1 · menú 54 items · CMS 14 filas · idioma es / es-CO
empleados 3 (0 sin fecha de estadísticas) · perfiles admin 5
permisos del cliente 302 + 48 de módulo · LEOELEMENTS_PANEL_TOOL = 0
pedidos 0 · clientes 1 (solo Anonymous) · proveedores 0 · visitas 0
rastro demo en Leo 0 · CMS con localhost 0
```

Y sobre el espejo, después de la limpieza: portada 200 con 70 productos,
`/2-catalogo` «Hay 3036 productos», `/17-herramientas-electricas` 118 productos,
las 8 listas del back office que ahora quedan vacías (Pedidos, Clientes, Proveedores,
Carritos, Direcciones…) cargan sin error, cuadro de mando del perfil del cliente 73 KB,
0 errores CRITICAL.

---

## Fase 3 — Caché y permisos (10 min)

El orden importa. La caché la tiene que escribir **el usuario del servidor web**, no root.

**3.1** Back office → Parámetros avanzados → Rendimiento → **Borrar la caché**.

**3.2** Por SSH o Administrador de archivos, borrar el contenido de:

```
var/cache/          (todo)
modules/leoelements/gencode/LeoGenCode_*.html
themes/vt_autosoe_child/assets/cache/    (todo)
```

**3.3** Permisos de escritura. En cPanel el usuario suele ser tu propia cuenta, así que
normalmente ya está bien. Si aparecen errores de caché, aplicar:

```
find var img upload download -type d -exec chmod 755 {} +
find var img upload download -type f -exec chmod 644 {} +
```

**3.4** Si el hosting tiene **LiteSpeed Cache**, purgarlo (cPanel → LiteSpeed Web Cache Manager).

---

## Fase 4 — Comprobaciones (20 min)

### 4.1 Tienda pública

| # | Qué | Esperado |
|---|---|---|
| 1 | Portada | Carga en < 2 s, sin franjas amarillas de aviso |
| 2 | Menú | `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO` |
| 3 | Pasar el ratón por **CATEGORIAS** | Panel blanco, 15 categorías en 3 columnas, **solo al pasar el ratón** |
| 4 | Pasar el ratón por **MARCAS** | Las 7 marcas en 2 columnas |
| 5 | `/2-catalogo` | «Hay 3036 productos» |
| 6 | `/17-herramientas-electricas` | Filtros: Disponibilidad · Línea · Marca · Precio · Sublínea |
| 7 | `/brands` | 7 marcas, con logotipo las 4 propias |
| 8 | `/content/4-quienes-somos` | Datos de la empresa y mapa de la ubicación |
| 9 | Ver código fuente y buscar `cdn.shopify.com` | **0 resultados** |
| 10 | Buscar en el código `leo-paneltool` | **0 resultados** (el panel público quedó apagado) |
| 11 | `/content/7-quiero-ser-cliente` → botón **Crear mi cuenta** | Lleva a `https://www.importtoolsas.com/login?create_account=1`. **Si lleva a `localhost:8080` importaste un volcado anterior al 29/07** |
| 12 | Buscar en el código `192.168` y `localhost` | **0 resultados** |
| 13 | Portada, pasar el ratón por una ficha de producto | **«Vista rápida»**, no *«Quick view»*. Si sale en inglés, el zip del tema es anterior al 29/07 |
| 14 | `/login?create_account=1` | **«Sr.»/«Sra.»** en los radios y **«Acepto los términos…»** en la casilla. Si salen en inglés, el volcado es anterior al 29/07 |
| 15 | Una dirección inventada, p. ej. `/esto-no-existe` | Página 404 **en español** («Vaya, no encontramos esa página») |
| 16 | Con el mantenimiento aún activo, verlo desde otro navegador | **«Estamos actualizando la tienda…»**, no *«We are currently updating our shop»* |

### 4.2 Back office como administrador

Entrar en `https://www.importtoolsas.com/panel-4h5o/` con el súper-admin.

| # | Ruta | Esperado |
|---|---|---|
| 1 | Catálogo → Productos | Lista con 3.036 productos |
| 1b | Pedidos, Clientes, Carritos, Proveedores | **Vacíos** (los datos de ejemplo se limpiaron). Clientes muestra solo «Anonymous», que es del módulo de RGPD y no se borra |
| 2 | Catálogo → Marcas | Las 7, con logotipo |
| 3 | Catálogo → Características | Línea (88 valores) y Sublínea (128) |
| 4 | Diseño → Páginas | 7 páginas en español |
| 5 | Diseño → **Leo Elements → Profiles** | 1 perfil, activo. Aquí están los **151 campos** de color y tipografía |
| 6 | Diseño → Leo Elements → Hook And Content | 17 contenidos, todos abren en el editor |
| 7 | Módulos → Leo Megamenu Configuration | El menú con sus 7 secciones |
| 8 | Módulos → LeoSlideShow | Las diapositivas |

### 4.3 Back office como cliente

Entrar con `cliente@importtoolslatam.com` (clave en `05-CREDENCIALES.md`).

**Debe poder:** Productos, Categorías, Marcas, Características, Páginas, Pedidos, Clientes,
Imágenes, Leo Elements, menú, slideshow.

**No debe poder** — al entrar sale *«No tienes permiso para hacer esto»*: Tema, Módulos
(instalar/desinstalar), Empleados, Rendimiento, SQL, Transportistas, Impuestos.

Ya validado en el entorno espejo con sesión real:

```
Productos 253 KB · Categorías 172 KB · CMS 135 KB · Pedidos 128 KB · Imágenes 135 KB
menú Leo 90 KB · slideshow 208 KB · dashboard 41 KB
DENEGADO (403): Tema · Módulos · Empleados · Rendimiento · SQL · Transportistas · Impuestos
módulos: ver=sí  configurar=sí  desinstalar=NO
0 errores CRITICAL en el log
```

---

## Fase 5 — Precios de prueba: **DECIDIDO el 29/07/2026**

Los 3.036 productos tienen **precios generados** para poder ver la tienda funcionando. Están
marcados con `supplier_reference = 'PRECIO-PRUEBA'`.

**Decisión: se dejan visibles tal cual. `03-opcional-precios-prueba.sql` NO se ejecuta.**

Lo que hay que tener presente mientras siga así:

- La tienda muestra al público precios que no son los reales.
- Con el modo catálogo apagado, **el carrito funciona**: alguien podría hacer un pedido a un
  precio inventado, y los transportistas siguen siendo los 4 de ejemplo. Si eso preocupa, la
  vía más rápida es no quitar el mantenimiento hasta tener los precios reales, o activar
  `PS_CATALOG_MODE = 1` (una sola fila), que deja navegar el catálogo y quita el carrito.
- **Cuando el cliente envíe los precios**, usar **`06-cargar-precios-reales.sql`**. Está
  probado de principio a fin en el espejo y trae: cruce en seco antes de tocar nada, respaldo
  de los precios actuales, transacción, verificación y marcha atrás. Lo único que hay que
  aclarar con el cliente antes de ejecutarlo es **si sus precios llevan IVA o no** — la tienda
  guarda el precio sin impuesto y muestra sin IVA (`price_display_method = 1`), así que
  equivocarse ahí deja todo el catálogo con un 19 % de diferencia.

```sql
-- cuántos siguen con precio generado
SELECT COUNT(*) FROM psjy_product WHERE supplier_reference = 'PRECIO-PRUEBA';
```

---

## Diagnóstico: qué hacer si algo sale mal

### Dónde están los logs

| Log | Ruta | Para qué |
|---|---|---|
| PrestaShop | `var/logs/prod-AAAA-MM-DD.log` | El más útil: excepciones con fichero y línea |
| Apache/LiteSpeed | cPanel → Métricas → Errores | Errores 500 del servidor |
| Módulos | `var/logs/ps_*-AAAA-MM-DD` | Fallos de módulos concretos |

Para ver el error real de PrestaShop:

```
tail -80 var/logs/prod-$(date +%Y-%m-%d).log | grep -i critical
```

### Los cinco fallos que ya me encontré, con su síntoma y su causa

Los cinco los provoqué o los sufrí montando el entorno espejo. Si aparecen, esto es lo que son:

**1. HTTP 500 en toda la tienda, o en el back office, de forma intermitente**
Caché escrita por un usuario distinto al del servidor web. Síntoma en el log:
`SmartyException: unable to create directory var/cache/prod/smarty/compile/...`
Solución: borrar `var/cache/` completo y dejar que la reconstruya la primera visita web.
**No** borrar la caché con un usuario distinto (root/SSH) y luego esperar que Apache escriba.

**2. El back office pide el login una y otra vez tras entrar bien**
`session.save_path` apunta a una ruta que no existe. En el log:
`SessionHandler::read(): open(/var/cpanel/php/sessions/...) failed`
En producción esa ruta **es la correcta** (la crea cPanel), así que **no la cambies**. El
`php.ini` de producción está guardado tal cual en `config/php.ini.produccion` por si alguien
lo sobrescribe. Solo hay que tocarlo si se cambia de hosting.

**3. HTTP 500 al entrar al panel, con `Date must be a string`**
En el log: `PrestaShopException: "Date must be a string" at HelperCalendar.php line 135`.
Un empleado con `stats_date_from` o `stats_date_to` en `NULL`. Arreglo:

```sql
UPDATE psjy_employee SET stats_date_from = '2026-06-01', stats_date_to = CURDATE()
 WHERE stats_date_from IS NULL OR stats_date_to IS NULL;
```

**4. Bucle de redirecciones a `/panel-4h5o/security/compromised?uri=...` o error 414**
Es **normal**: PrestaShop 9 exige un token por URL en el back office. Ocurre al escribir a
mano una dirección tipo `index.php?controller=AdminProducts`. Solución: navegar por el menú,
no pegar direcciones.

**5. La portada sirve imágenes o colores viejos aunque la base de datos ya esté bien**
La caché de CSS de Elementor vive **en la base de datos**. Vaciar `var/cache/` no la invalida:

```sql
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
```

Después, borrar `var/cache/` y recargar. Esto hay que hacerlo **siempre** que se toque
contenido de Leo Elements por SQL.

### Otros síntomas

| Síntoma | Causa probable | Solución |
|---|---|---|
| HTTP 500 en todas las páginas, log vacío | Falta el `.env` de la raíz | Restaurarlo del respaldo. Al comprimir desde cPanel hay que activar «mostrar ficheros ocultos» |
| Todas las URL amigables dan 404, la portada va | Falta el `.htaccess` | Back office → Parámetros de tráfico y SEO → guardar (lo regenera) |
| El menú sale sin estilo, todo en una columna | Falta el CSS del tema hijo | Comprobar que `themes/vt_autosoe_child/assets/css/custom.css` subió, y borrar `assets/cache/` |
| Los bloques de producto de la portada salen vacíos | Falta `themes/vt_autosoe_child/modules/` | Viene en el zip. Los módulos Leo buscan sus plantillas en la carpeta del tema **activo** |
| El desplegable del menú se queda abierto siempre | Alguien puso `is_group = 1` | `UPDATE psjy_btmegamenu SET is_group = 0 WHERE id_btmegamenu IN (8, 61);` |
| Vuelve a aparecer «All Departments» | Se cambió de cabecera a una variante | Las 4 variantes son copia de la nuestra; si pasa, revisar `leoelements_contents_lang` |

### Marcha atrás

1. **JetBackup**: restaurar el respaldo de la Fase 0. Es la vía rápida y completa.
2. Solo la base de datos: importar el respaldo de `backups/`.
3. Solo el contenido del tema: `themes/vt_autosoe/samples/leoelements.xml` tiene la portada
   original de la plantilla (9,3 MB).

---

## Comprobación de que producción no cambió — HECHA el 29/07/2026

Este volcado **sobrescribe la base de datos entera**, así que antes de importar hay que
confirmar que producción no tiene actividad posterior a la copia del 24/07/2026.

```sql
SELECT MAX(date_add) AS ultimo_pedido   FROM psjy_orders;
SELECT MAX(date_add) AS ultimo_cliente  FROM psjy_customer;
SELECT MAX(date_upd) AS ultimo_producto FROM psjy_product;
```

**Resultado obtenido: las tres devuelven `2026-07-24 11:07:54`.**

Las tres idénticas al segundo es la firma del momento en que se instalaron los **datos de
ejemplo** de PrestaShop: pedidos, clientes y productos se crearon de golpe en la instalación.
Coincide con lo que ya sabíamos de producción (19 productos demo, 2 clientes, 5 pedidos) y
significa que **no ha habido ventas ni cambios de catálogo reales**. Vía libre para la
importación completa.

### Antes de importar: confirma que estás en la base correcta

Diez segundos, y evita el único error irreversible de todo el proceso:

```sql
SELECT COUNT(*) FROM psjy_product;
```

| Resultado | Qué es | Qué hacer |
|---|---|---|
| **~19** | Producción (datos de ejemplo) | Adelante con la importación |
| **3036** | La base del entorno espejo | **Para.** Repite las consultas de fechas en producción |

### Si en el futuro hubiera actividad real

Si al repetir las consultas alguna fecha fuera posterior al 24/07/2026, **no importes el
volcado completo**: habría pedidos o clientes reales que se perderían. En ese caso hay que
preparar una importación selectiva por tablas (contenido y catálogo sí, pedidos y clientes no),
que es un trabajo distinto y se monta aparte.
