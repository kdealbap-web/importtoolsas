# Importtools S.A.S — puesta en producción

**Punto de entrada.** Aquí está el contexto y el resumen de qué se despliega.

Estado: **09/08/2026** · Despliegue nº 3 (ronda del 08/08) preparado, y el estado de
producción **medido contra la tienda en línea**, no supuesto.

> ### 📌 Para ejecutar el despliegue de HOY, usa `23-PASO-A-PASO-20260809.md`
>
> Es el operativo vigente. Sustituye al `historico/18-PASO-A-PASO-20260808.md`, que se escribió
> mirando el espejo local: al contrastarlo con la tienda real aparecieron **tres pasos
> que ya no hacen falta** (los scripts de depuración del docroot ya no existen, el hero
> ya no usa la imagen de la demo y su primera diapositiva no está vacía) y **uno que
> era peligroso** —desactivaba por id una diapositiva que en producción sí funciona—.
>
> Los despliegues nº 1 y nº 2 (`14-…` y `18-…`) se conservan como historial.

> ### 📎 Historial: el despliegue nº 2 se ejecutó con `historico/14-PASO-A-PASO-SUBIDA.md`
>
> Ese documento es el operativo de esta ronda: los once pasos con los comandos, la
> salida esperada de cada uno, las 29 comprobaciones y la marcha atrás. Incluye dos
> cosas que este documento no tenía:
>
> - **Paso 8 — confirmar que lo nuevo se sirve de verdad.** Con centinelas en el CSS
>   y el JS servidos. Es la única forma de descartar la trampa de `compile_check`,
>   que deja subir el tema entero sin que cambie un píxel y sin ningún error.
> - **Paso 9 — optimización.** Cachés de PrestaShop, LiteSpeed y PHP, separando lo
>   que está probado de lo que no.
>
> Lo de aquí abajo (§3 y §4) sigue siendo correcto y es la versión resumida del mismo
> procedimiento. Si las dos discrepan en algún número, **manda el 14**: es el que se
> revisó contra el paquete actual.
>
> Y el **qué cambió en esta ronda y por qué**, en `historico/13-PLAN-SUBIDA-20260803.md`.

> **Cómo leer los indicadores de este documento.** Cada afirmación lleva su origen, porque no
> todas valen lo mismo:
>
> | | Significa |
> |---|---|
> | **✅ verificado** | Lo comprobé yo ejecutándolo en el entorno espejo, o sobre datos reales de producción que me pasaste |
> | **📋 reportado** | Me lo dijiste tú y no lo he comprobado. Puede estar bien, pero no es evidencia |
> | **⏳ pendiente** | Ni hecho ni verificado |
>
> Y una distinción que importa: **«verificado en el espejo» no es «verificado en producción».**
> El espejo es una copia fiel (misma versión, mismo prefijo, mismos ficheros), pero el hosting
> es LiteSpeed sobre CloudLinux y el espejo es Apache en Docker. Lo que se comporte distinto,
> se verá al hacerlo.

---

## 1. Resumen ejecutivo

### Dónde estamos

El **despliegue nº 1 se hizo el 31/07** y producción tiene el catálogo real, el español y el
tema. Desde entonces el espejo acumula **tres rondas de trabajo sin trasladar**. Este documento
las despliega todas de una vez.

### La decisión que ordena todo

**El catálogo no lleva precios. No es provisional.** La tienda es un catálogo consultable:
el visitante arma una lista, deja sus datos y **un asesor le responde por WhatsApp** con precio,
disponibilidad y tiempo de entrega. Sin carrito y sin pasarela de pago.

Esto cambia dos cosas respecto al plan anterior:

- Los **transportistas dejan de bloquear**. Antes impedían vender; ahora solo harían falta si
  algún día se abre el carrito.
- Los **precios reales dejan de bloquear** la salida a producción.

### Qué se despliega en esta ronda

Todo **✅ verificado en el espejo**, con la evidencia al lado:

| | | Evidencia |
|---|---|---|
| **Cotización por WhatsApp** | Módulo propio `itcotizacion`: lista, formulario de prospecto, guardado para el CRM y salto a WhatsApp | Recorrido completo en navegador real: lista vacía → aviso; documento inválido → rechazado; datos válidos → referencia, fila en base, enlace con las 2 referencias, lista vaciada y contador a 0 |
| **Modo catálogo sin precios** | `PS_CATALOG_MODE=1`, `..._WITH_PRICES=0` | 0 marcado de precio en portada, catálogo, categoría y ficha (`class="price"`, `itemprop="price"`, `current-price` → 0) |
| **Botón en la ficha de producto** | Cantidad + «Agregar a mi cotización» | Corregido un hueco vacío: el tema mete todo el bloque de compra en `{if !$configuration.is_catalog}` |
| **Quiénes somos** | Rehecha desde la maqueta del cliente, en HTML/CSS | Capturas a 1440 px y a 390 px reales; `scrollWidth == innerWidth` |
| **Quiero ser cliente** | Rehecha: puerta de entrada al flujo de cotización | Ídem |
| **Iconos** | Font Awesome 5 Pro **Light** que ya venía en el tema y nadie usaba | Los 1.649 glifos comprobados renderizando los cuatro pesos |
| **Fotos** | Seis, recortadas de la propia maqueta del cliente | `deploy/img/it/` |
| **Fichas sin foto** | El marcador ya no ocupa media pantalla | La ficha es 450 px más corta |
| **Volcado limpio** | 0 pedidos, 0 carritos, 0 visitas, 0 prospectos de prueba | Barrido del `.sql`: 0 apariciones de los correos y referencias de prueba |

### Qué NO está listo, y de quién depende

| Pendiente | Depende de | Impacto |
|---|---|---|
| **Fotos de producto** | El cliente | `psjy_image` = 0 filas: los 3.036 salen sin imagen. Mitigado, no resuelto |
| **Requisitos y condiciones comerciales** | El cliente | *Quiero ser cliente* funciona sin ellos; se añade la sección cuando lleguen. **No los invento**: son compromisos legales |
| **Precios reales** | El cliente | Ya **no** bloquean: no se muestran. Mecanismo probado en `06` |
| **Transportistas** | Definir con el cliente | En pausa mientras no haya carrito |

---

## 2. Antes de empezar

### Lo que hay que tener a mano

Actualizado el **03/08/2026**. Los tamaños y recuentos son los del paquete de hoy.

| Fichero | Para qué |
|---|---|
| `backups/importtools-FASE2-20260803-1345.sql.gz` | **El volcado.** 638 KB comprimido, 374 tablas |
| `vt_autosoe_child-EXTRAER-EN-themes.zip` | Tema hijo, 473 ficheros, 8,8 MB |
| `img-importtools.zip` | 346 imágenes: `img/it/` (147), `img/m/` y los logotipos |
| `itcotizacion-EXTRAER-EN-modules.zip` | El módulo de cotización, 17 ficheros |
| `modulos-traducciones-EXTRAER-EN-modules.zip` | Los `es.php` de `leoelements`, `leoproductsearch`, `leoquicklogin` y **`leofeature`** (nuevo) |
| `traducciones-EXTRAER-EN-translations.zip` | Los 169 XLIFF de `es-CO` — **solo si faltan**, ver 3.2 |
| `14a-caches-off-al-empezar.sql` | Cerrar la tienda y apagar las cachés de Smarty |
| `02-ajustes-tras-importar.sql` | Obligatorio justo después del volcado |
| `14b-caches-on-al-terminar.sql` | Devolver las cachés a valores de producción |
| `14c-abrir-la-tienda.sql` | Abrir la tienda. Una línea, en fichero aparte a propósito |

### No necesitas poner tu IP

`PS_MAINTENANCE_ALLOW_ADMINS` está en **1**: mientras tengas sesión abierta en el back office
sigues viendo la tienda normal y los visitantes ven el aviso.

⚠️ Y la fila `PS_MAINTENANCE_IP` **no existe** en esta base — comprobado, 0 filas. Un `UPDATE`
sobre ella no haría nada **y no avisaría**. Si algún día quieres permitir una IP concreta, hay
que **insertarla**; el `INSERT` correcto está comentado en el paso 0 de `02-ajustes`.

---

## 3. El despliegue, paso a paso

> **Ventana con el sitio cerrado:** el respaldo, más unos 3 minutos de trabajo, más la primera
> carga. Los tiempos con «medidos» están cronometrados en el espejo.

### 3.0 Respaldo y mantenimiento

1. **JetBackup**: respaldo de archivos + base. Esperar a que termine.
2. Mantenimiento ON, en `panel-4h5o` → *Configurar → Parámetros de la tienda → General →
   Mantenimiento* → **Activar tienda: NO**. O por SQL:
   ```sql
   UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SHOP_ENABLE';
   ```
3. Comprobar en una **ventana de incógnito** que sale el aviso de mantenimiento.

### 3.1 Apagar la caché de Smarty — **antes de subir nada**

⚠️ **Sin esto, nada de lo que subas se aplica.** Producción tiene
`PS_SMARTY_FORCE_COMPILE = 0`, y el núcleo hace:

```php
$smarty->compile_check = (PS_SMARTY_FORCE_COMPILE >= _PS_SMARTY_CHECK_COMPILE_)
                        ? COMPILECHECK_ON : COMPILECHECK_OFF;
```

Con `compile_check` apagado **Smarty ni mira si la plantilla cambió**. Puedes subir tema,
traducciones y widgets y no cambiar nada en pantalla. Costó un buen rato descubrirlo el 31/07.

```sql
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SMARTY_FORCE_COMPILE';
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SMARTY_CACHE';
```

### 3.2 Subir ficheros

| Zip | Dónde subirlo y extraerlo | Debe quedar |
|---|---|---|
| `vt_autosoe_child-EXTRAER-EN-themes.zip` | `public_html/themes/` | `themes/vt_autosoe_child/config/theme.yml` |
| `img-importtools.zip` | `public_html/` | `img/it/` (142 ficheros) y `img/m/` |
| `itcotizacion-EXTRAER-EN-modules.zip` | `public_html/modules/` | `modules/itcotizacion/itcotizacion.php` |
| `modulos-traducciones-EXTRAER-EN-modules.zip` | `public_html/modules/` | `modules/leoproductsearch/translations/es.php` y `modules/leoelements/translations/es.php` |

⚠️ **En `leoproductsearch` ya existe un `es.php` del fabricante.** Renómbralo a `es.php.bak`
antes de extraer, o el zip lo sobrescribe sin avisar (que es lo que queremos, pero mejor con
copia).

**Comprobar los 169 XLIFF.** Si `public_html/translations/es-CO/` no existe o tiene menos de
169 ficheros, sube y extrae `traducciones-EXTRAER-EN-RAIZ.zip` en la raíz. Sin ellos **todo el
núcleo cae al inglés**: «There are 3036 products», «Sort by», «Back to top»…

> ⚠️ **Borra los zip de `public_html/themes/` en cuanto extraigas.** El `.htaccess` de esa
> carpeta **permite `.zip`**: comprobado, descargué uno de 9,25 MB con HTTP 200. Mientras siga
> ahí, cualquiera se lleva el tema comercial completo. **Del despliegue anterior quedó uno:
> bórralo también.**

### 3.3 Importar el volcado y ajustar — **seguidos**

| # | Qué | Cuánto |
|---|---|---|
| a | Importar `importtools-FASE2-20260801-2315.sql.gz` en phpMyAdmin | **~16 s medidos** |
| b | Ejecutar `02-ajustes-tras-importar.sql` | **< 1 s** |

⚠️ **Entre (a) y (b) la tienda y el back office redirigen a `localhost:8080`** y no podrás
entrar por el panel. **Ten el `02-ajustes` abierto y listo para pegar antes de lanzar la
importación.** phpMyAdmin sigue accesible desde cPanel, que es la salida.

⚠️ **Y el volcado te quita el mantenimiento.** Trae `PS_SHOP_ENABLE = 1` del espejo: al
importar, la tienda queda abierta al público con los ficheros a medio aplicar. Por eso el
**paso 0 de `02-ajustes` vuelve a cerrarla** — es lo primero que hace el script.

### 3.4 Vaciar cachés

Desde el Administrador de archivos de cPanel, **con tu usuario** (no como root):

```
var/cache/prod/smarty/compile/          ← la que de verdad importa
var/cache/                              (todo)
themes/vt_autosoe_child/assets/cache/   (todo, la carpeta se queda)
modules/leoelements/gencode/LeoGenCode_*.html
```

Y purga LiteSpeed si está activo (cPanel → LiteSpeed Web Cache Manager).

> ⏱️ **La primera página después tarda ~57 s** (medido: 57,3 s; las siguientes, 0,3–0,5 s).
> No es un error y ocurre una sola vez. **No vacíes la caché justo antes de enseñarle la tienda
> al cliente** — cárgala tú una vez primero.
>
> Si aparecen HTTP 500 intermitentes, es caché escrita por un usuario distinto al del servidor
> web: borra `var/cache/` otra vez y deja que la reconstruya la primera visita.

### 3.5 Restaurar la caché de Smarty

Cuando ya hayas comprobado (§4). Es lo que hace la tienda rápida:

```sql
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SMARTY_FORCE_COMPILE';
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SMARTY_CACHE';
```

### 3.6 Abrir la tienda

Solo cuando §4 esté en verde:

```sql
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SHOP_ENABLE';
```

---

## 4. Comprobar

| # | Dónde | Qué debes ver |
|---|---|---|
| 1 | Portada | Carga con estilos y el menú `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO`, **cada uno con su icono** |
| 2 | `/2-catalogo` | «Hay 3036 productos» y **ningún precio** |
| 3 | `/17-herramientas-electricas` | Filtros: Disponibilidad · Línea · Marca · Sublínea. **Sin filtro de precio ni «ordenar por precio»** |
| 4 | Abrir un producto | **«Cantidad» + botón «Agregar a mi cotización»**. Ningún precio |
| 5 | Pulsar el botón y luego el icono de cotización de la cabecera | La lista muestra el producto; el contador sube |
| 6 | Enviar el formulario con un documento inválido | Se queda en la página y marca el campo |
| 7 | Enviarlo bien | Abre WhatsApp con el mensaje escrito y aparece la referencia `COT-…` |
| 8 | `/content/4-quienes-somos` | Diseño nuevo: hero negro, 4 ventajas, 01-04, 5 categorías con foto, valores, datos y mapa |
| 9 | `/content/7-quiero-ser-cliente` | Diseño nuevo, con los 3 pasos y «Por qué el catálogo no muestra precios» |
| 10 | Buscador de la cabecera | El texto de ayuda en **español**, no «Search here…» |
| 11 | Pasar el ratón por una ficha | **«Vista rápida»**, no «Quick view» |
| 12 | Móvil (o ventana estrecha) | Hamburguesa **en la esquina**, no debajo del header |
| 13 | Panel, con la cuenta del cliente | Entra y ve Productos, Categorías, Páginas, Pedidos |

Si algo falla, no toques nada más: pásame lo de §6.

---

## 5. Scripts: cuáles se ejecutan y cuáles NO

| Fichero | ¿Ejecutar? |
|---|---|
| `14a-caches-off-al-empezar.sql` | **SÍ**, antes de subir nada |
| `02-ajustes-tras-importar.sql` | **SÍ, obligatorio**, justo después del volcado |
| `14b-caches-on-al-terminar.sql` | **SÍ**, cuando las comprobaciones hayan pasado |
| `14c-abrir-la-tienda.sql` | **SÍ**, al final y a conciencia |
| `02b-limpieza-datos-demo.sql` | **No.** Ya viene aplicado dentro del volcado |
| `02c-textos-en-ingles-en-datos.sql` | **No.** Ya viene aplicado dentro del volcado |
| `03-opcional-precios-prueba.sql` | **No.** El catálogo no muestra precios |
| `06-cargar-precios-reales.sql` | Solo si algún día se abre la tienda con precios. **Preguntar antes al cliente si sus precios llevan IVA** |
| `07-transportistas-colombia.sql` | En pausa: sin carrito no hacen falta |
| `08`, `09`, `10` (PHP) | **No.** Ya aplicados y dentro del volcado |
| `12-imagenes-del-cliente.php` | **No**, si importas el volcado: ya viene aplicado. **Sí**, solo si decides *no* reimportar la base — ver §4.2 del `historico/14-PASO-A-PASO-SUBIDA.md` |

---

## 6. Qué dejarme para que yo lo revise

Deja estos ficheros en **`deploy/entrada/`**:

| Fichero | Cómo se obtiene |
|---|---|
| `01-dump-produccion.sql.gz` | phpMyAdmin → Exportar → SQL, compresión gzip |
| `02-log-errores.txt` | `var/logs/` → últimas ~100 líneas de `prod-2026-08-XX.log` |
| `03-portada.html` | Abre la tienda → clic derecho → **Ver código fuente** → guardar |
| `04-ficha.html` | Lo mismo, pero abriendo un producto cualquiera |
| `05-notas.txt` | Dos líneas: qué hiciste y qué viste raro |

El más útil sigue siendo el **HTML servido**: es la única forma fiable de detectar problemas
reales — así encontré los 140 «Quick view» en inglés que una auditoría de ficheros de
traducción no vio.

---

## 7. Estructura de la carpeta

```
deploy/paquete/
├── EMPEZAR-AQUI.md                              ← este fichero
├── 11-PLAN-FASE-II.md                           estado y pendientes al día
├── 02-ajustes-tras-importar.sql             ★   el único obligatorio
├── 02b / 02c                                    ya aplicados al volcado
├── 03 / 06 / 07                                 no se ejecutan (ver §5)
├── 08 / 09 / 10 (php)                           ya aplicados al volcado
├── 04-PLAN-IMPORTACION.md                       detalle largo del despliegue nº 1
├── 05-CREDENCIALES.md                           accesos (no se versiona)
├── 00-PROGRESO-CLIENTE.md                       documento para el cliente
├── contenido/                                   los HTML de las 2 páginas rehechas
│   ├── quienes-somos.html
│   └── quiero-ser-cliente.html
├── vt_autosoe_child-EXTRAER-EN-themes.zip       tema, 475 ficheros
├── vt_autosoe_child-SUBIR-POR-PANEL.zip         el mismo, para el importador del panel
├── img-importtools.zip                          337 imágenes
├── itcotizacion-EXTRAER-EN-modules.zip      ★   el módulo de cotización
├── modulos-traducciones-EXTRAER-EN-modules.zip ★ los dos es.php
└── traducciones-EXTRAER-EN-RAIZ.zip             169 XLIFF, solo si faltan

backups/importtools-FASE2-20260801-2315.sql.gz   ← el volcado a importar
deploy/entrada/                                  ← lo que me dejas para revisar (§6)
```

Los dos zip del tema tienen el mismo contenido, cambia solo la estructura:

| Fichero | Estructura | Para qué |
|---|---|---|
| `…-EXTRAER-EN-themes.zip` | `vt_autosoe_child/…` | **Este.** Extraer en `themes/` |
| `…-SUBIR-POR-PANEL.zip` | `config/…` en la raíz | Solo si prefieres el importador del panel |

> El importador del panel exige `config/theme.yml` en la **raíz** del zip
> (`ThemeManager.php:413`); extraer a mano no lo necesita, porque `ThemeRepository` lista los
> temas con `glob(themes/*/config/theme.yml)`.

---

## Resumen en seis líneas

1. **JetBackup** y mantenimiento ON.
2. **Apagar la caché de Smarty** (3.1) — sin esto no se aplica nada de lo que subas.
3. **Subir** los 4 zip; comprobar los 169 XLIFF; **borrar los zip de `themes/`**.
4. **Importar** el volcado y **seguido** el `02-ajustes` (vuelve a cerrar la tienda).
5. **Vaciar cachés** y aguantar los ~57 s de la primera página.
6. **Comprobar** las 13 cosas de §4 → restaurar Smarty → abrir la tienda.

---

## Registro de correcciones a este documento

| Fecha | Corrección |
|---|---|
| 29/07 | **Los tiempos del plan estaban inventados** («50–70 minutos»). Sustituidos por los medidos: 16 s el volcado, 57,3 s la primera página tras vaciar caché, 0,3–0,5 s el resto |
| 29/07 | El paso «añadir tu IP» sobraba entonces: `PS_MAINTENANCE_ALLOW_ADMINS` estaba en 1 y `PS_MAINTENANCE_IP` no existía |
| 29/07 | Indicadores separados por origen: **✅ verificado** / **📋 reportado** / **⏳ pendiente** |
| 31/07 | Añadidas las dos trampas del despliegue real: los XLIFF son **ficheros en disco**, y `compile_check` congela las plantillas |
| 31/07 | **Culpé por error a `modules/leoelements/gencode/`.** No era: `LeoGenCode.php` hace `if (!Leo_Helper::is_admin()) return $html;`, así que en la tienda no se lee. La causa real era `compile_check` |
| 01/08 | **§5 recomendaba «modo catálogo CON precios». Revocado**: el catálogo no lleva precios, y no es provisional |
| 01/08 | **El volcado quita el mantenimiento** (`PS_SHOP_ENABLE = 1`). No estaba dicho en ningún sitio. Ahora lo vuelve a cerrar el paso 0 de `02-ajustes` |
| 01/08 | Escribí un paso «pon tu IP en `PS_MAINTENANCE_IP`» y **habría sido un `UPDATE` sobre una fila que no existe**: 0 filas, sin aviso. Retirado; basta la sesión de admin |
| 01/08 | El script traía un `UPDATE` de `PS_SSL_ENABLED_EVERYWHERE`: **esa opción no existe en PrestaShop 9**, ni la fila ni la constante. Otro no-op silencioso, retirado |
| 01/08 | Probé el camino completo —volcado + `02-ajustes`— **en una base limpia** antes de darlo por bueno: 374 tablas, 3.036 productos, tienda cerrada, dominio corregido |
| 01/08 | Los dos `es.php` iban sueltos como «copia manual» y **se olvidaron en el despliegue nº 1**. Ahora van en su propio zip |
| 01/08 | Reescrito para el despliegue nº 2: las sesiones 1 y 2 ya ocurrieron el 31/07 |
