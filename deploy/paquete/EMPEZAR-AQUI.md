# Importtools Latam — puesta en producción

**Único documento que necesitas.** Los demás ficheros de esta carpeta son material de
referencia; aquí está lo que hay que hacer y en qué orden.

Estado: **29/07/2026** · Producción verificada, vía libre para importar.

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

La tienda está **construida y verificada en un entorno espejo local** (copia exacta de
producción: PrestaShop 9.1.4, PHP 8.5, mismo prefijo de tablas). Falta trasladarla al servidor.

En producción hoy hay una instalación de PrestaShop con **19 productos de ejemplo, en inglés**.

### Qué se entrega

Todo lo de esta tabla está **✅ verificado en el espejo**, con el número que lo respalda:

| | | Evidencia |
|---|---|---|
| **Catálogo** | 3.036 productos en 15 categorías, 7 marcas (4 con logotipo) | los 3.036 en la categoría raíz y con stock; `/2-catalogo` dice «Hay 3036 productos» |
| **Filtros** | Marca, Línea, Sublínea, Precio, Disponibilidad | 88 líneas y 128 sublíneas, 6.072 filas en `feature_product` |
| **Idioma** | Español (es-CO) | barrido insensible a mayúsculas sobre 15 páginas → 0 apariciones de inglés; en el tema hijo, 858 llamadas `{l …}` y 0 intraducibles |
| **Fiscal** | Peso colombiano sin decimales, IVA 19 / 5 / 0 % | carrito real: 84.300 sin IVA → 100.317 con el 19 % |
| **Contenido** | Datos reales de la empresa, 7 páginas, mapa | las 7 páginas CMS en español |
| **Diseño** | Tema hijo `vt_autosoe_child`, un solo perfil | 34 contenidos Leo con JSON válido 34/34, 1 perfil, 54 ítems de menú |
| **Panel del cliente** | Permisos acotados | 302 permisos de pestaña + 48 de módulo, validados con sesión HTTP real: 403 en Tema, Módulos, Empleados, Rendimiento, SQL, Transportistas e Impuestos |
| **Volcado** | Restaurado en base limpia | 30 comprobaciones en verde |

### Qué NO está listo, y de quién depende

| Pendiente | Depende de | Impacto |
|---|---|---|
| **Precios reales** | El cliente los enviará | Hoy se muestran precios generados. Mecanismo de carga ya probado (`06`) |
| **Transportistas y fletes** | Definir con el cliente cobertura y tarifas | **Hoy nadie puede completar un pedido**: los transportistas son los de ejemplo y no cubren Colombia. Se resuelve con el modo catálogo hasta tener datos (`07`) |
| **Fotos de producto** | El cliente | Los 3.036 productos salen sin imagen |

### Estado real, frente por frente

| Frente | Estado | Origen del dato |
|---|---|---|
| Construcción de la tienda en el espejo | ✅ terminada | 30 comprobaciones sobre el volcado restaurado |
| Comprobación previa de producción | ✅ hecha | tus resultados: 19 productos, sin actividad posterior al 24/07 |
| Imágenes subidas a producción | 📋 reportado | me lo dijiste; no verificado |
| Tema subido a producción | 📋 reportado | me lo dijiste; no verificado |
| **Tema activado en producción** | ⏳ **es el paso de hoy** | — |
| Traducciones (`es.php`) subidas | ⏳ pendiente | son 2 ficheros pequeños |
| Base de datos importada | ⏳ mañana | — |
| Precios reales | ⏳ los envía el cliente | mecanismo probado (`06`) |
| Transportistas | ⏳ definir con el cliente | **bloquea vender** (§5) |
| Fotos de producto | ⏳ las envía el cliente | `psjy_image` = 0 filas |

### Riesgo del traslado

Uno solo, y está cubierto: el volcado **sustituye la base de datos completa**. Se comprobó que
producción no tiene actividad real (19 productos de ejemplo, ningún pedido ni cliente posterior
al 24/07), y el respaldo de JetBackup es la marcha atrás.

---

## 2. HOY — subir el tema y verlo funcionando

**📋 Reportado por ti:** imágenes subidas y extraídas, y el tema subido. No lo he verificado —
se confirmará solo cuando actives el tema y cargue.

Faltan dos cosas: poner mantenimiento y activar el tema.

**Tiempo real de esta sesión:** son 4 clics en el panel y mirar la portada. Lo único que puede
tardar es la primera carga tras activar el tema, porque PrestaShop reconstruye la caché
(**57 s medidos** en el espejo — ver el aviso del paso 2.3).

> Tu back office está **en inglés** ahora mismo (`PS_LANG_DEFAULT = 1`, solo `en-US`).
> Los menús de abajo van en inglés por eso. Tras el import quedará en español.

### 2.1 Activar el mantenimiento

**Por el panel** — entra en `https://www.importtoolsas.com/panel-4h5o/` y ve a:

```
Configure  →  Shop Parameters  →  General  →  pestaña "Maintenance"
```

Ahí: **Enable Shop → NO**. Y deja **Enable Shop for Employees → YES** (ya está así).

**No necesitas poner tu IP.** `PS_MAINTENANCE_ALLOW_ADMINS` ya está activado, así que mientras
estés logueado en el panel sigues viendo la tienda normal. Los visitantes ven el aviso.

**Si no encuentras el menú**, en phpMyAdmin (pestaña SQL) esto hace lo mismo:

```sql
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_SHOP_ENABLE';
```

Comprobación: abre la tienda en una **ventana de incógnito** (sin sesión de admin). Debes ver el
aviso de mantenimiento. En tu ventana normal la sigues viendo bien.

### 2.2 Activar el tema hijo

```
Design  →  Theme & Logo
```

Debe aparecer `Importtools (AutoSoe child)` en la lista. Pulsa **"Use this theme"**.

- Si no aparece: el zip no quedó bien extraído. Debe existir el fichero
  `themes/vt_autosoe_child/config/theme.yml`.
- **No borres ni desactives el tema padre `vt_autosoe`.** El hijo lo necesita: sin él no hay
  plantillas y la tienda se cae.

### 2.3 Mirar la tienda

Con mantenimiento puesto y tu sesión de admin abierta, entra a la portada.

> ⏱️ **La primera carga tarda alrededor de un minuto y parece colgada. Es normal, no recargues.**
> Medido en el espejo: **57,3 s** la primera petición tras activar el tema (PrestaShop reconstruye
> el contenedor de Symfony), y **0,3–0,5 s** todas las siguientes. Ocurre **una sola vez**.

Verás **el diseño del tema hijo con el contenido de ejemplo en inglés** (19 productos, textos
demo). **Eso es lo correcto en este punto**: el diseño viene de los ficheros que acabas de
subir, y el contenido en español viene mañana con la base de datos.

Lo que importa hoy es que **cargue sin error 500 y con estilos**. Si se ve así, terminamos.

### 2.4 Si algo se rompe

Deja el mantenimiento puesto y vuelve al tema anterior en `Design → Theme & Logo`. Nada de lo de
hoy es irreversible: son ficheros, y la base de datos no se ha tocado.

---

## 3. MAÑANA — la base de datos

Orden exacto. Los pasos 3.2 y 3.3 van **seguidos, en la misma sesión de phpMyAdmin**.

| # | Qué | Con qué | Cuánto tarda |
|---|---|---|---|
| 3.1 | **Respaldo JetBackup** (archivos + base). Esperar a que termine | cPanel → JetBackup | depende del hosting |
| 3.2 | Importar el volcado | `backups/importtools-FINAL-20260729-1726.sql.gz` | **16 s medidos** (373 tablas, 7,58 MB) |
| 3.3 | Ejecutar los ajustes obligatorios | `02-ajustes-tras-importar.sql` | **< 1 s** (6 sentencias) |
| 3.4 | Vaciar cachés | ver 3.4 abajo | el borrado es inmediato; **la primera página después tarda ~57 s** |
| 3.5 | Comprobar | ver §4 | lo que tardes en mirar 7 páginas |

> Los tiempos con «medidos» son reales, cronometrados en el espejo el 29/07. Los 16 s son por
> línea de comandos; phpMyAdmin añade su propia sobrecarga, pero el volcado es pequeño (7,58 MB)
> y no debería agotar el tiempo de espera.
>
> **Ventana total con el sitio en mantenimiento: el respaldo, más unos 2 minutos.** No es la hora
> que decía este plan antes.

### ⚠️ Lo único que puede dejarte fuera

El volcado trae el dominio del entorno local. **Entre el 3.2 y el 3.3 la tienda y el back office
redirigen a `localhost:8080`** y no podrás entrar por el panel a arreglarlo.

**Ten el `02-ajustes-tras-importar.sql` abierto y listo para pegar antes de lanzar la
importación.** Si te pasa, se sale ejecutando ese mismo fichero desde phpMyAdmin, que sigue
siendo accesible desde cPanel.

### 3.4 Cachés (después del 3.3)

Desde el Administrador de archivos de cPanel, **con tu usuario** (no como root), borra el
contenido de:

```
var/cache/                                  (todo)
modules/leoelements/gencode/LeoGenCode_*.html
themes/vt_autosoe_child/assets/cache/       (todo, la carpeta se queda)
```

Y si el hosting tiene LiteSpeed Cache, púrgalo (cPanel → LiteSpeed Web Cache Manager).

> ⏱️ **Tras vaciar la caché, la primera página tarda ~57 s** (medido). No es un error: espera.
> Y **no vacíes la caché justo antes de mostrarle la tienda al cliente** — cárgala tú una vez.

> Si aparecen HTTP 500 intermitentes después, es esto: caché escrita por un usuario distinto al
> del servidor web. Se arregla borrando `var/cache/` otra vez y dejando que la reconstruya la
> primera visita. Me pasó a mí en el espejo hoy mismo por ejecutar scripts como root.

### Scripts: cuáles se ejecutan y cuáles NO

| Fichero | ¿Ejecutar? |
|---|---|
| `02-ajustes-tras-importar.sql` | **SÍ, obligatorio**, justo después del volcado |
| `02b-limpieza-datos-demo.sql` | **No.** Ya viene aplicado dentro del volcado |
| `02c-textos-en-ingles-en-datos.sql` | **No.** Ya viene aplicado dentro del volcado |
| `03-opcional-precios-prueba.sql` | **No.** Se decidió dejar los precios generados visibles |
| `06-cargar-precios-reales.sql` | Más adelante, cuando el cliente envíe los precios |
| `07-transportistas-colombia.sql` | Antes de quitar el mantenimiento — ver §5 |

---

## 4. Comprobar (mañana, tras el 3.4)

Con esto basta para saber si salió bien:

| # | Dónde | Qué debes ver |
|---|---|---|
| 1 | Portada | Carga con estilos, menú `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO` |
| 2 | `/2-catalogo` | «Hay 3036 productos» |
| 3 | `/17-herramientas-electricas` | Filtros: Disponibilidad · Línea · Marca · Precio · Sublínea |
| 4 | Pasar el ratón por una ficha | **«Vista rápida»**, no «Quick view» |
| 5 | `/login?create_account=1` | **«Sr.»/«Sra.»** y «Acepto los términos…» en español |
| 6 | `/esto-no-existe` | Página 404 en español |
| 7 | Panel, con `cliente@importtoolslatam.com` | Entra y ve Productos, Categorías, Páginas, Pedidos |

Si algo de esto falla, no toques nada más: pásame lo de §6 y lo miro.

---

## 5. Antes de quitar el mantenimiento — una decisión

**Hoy nadie en Colombia puede completar un pedido.** El carrito funciona, pero el paso «Método de
envío» sale vacío: los transportistas son los de ejemplo y solo cubren Europa y Norteamérica.

Mi recomendación mientras los precios sean los generados: **modo catálogo con precios**, que son
dos filas y se revierte igual de rápido.

```sql
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE';
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE_WITH_PRICES';
```

Deja los 3.036 productos navegables **con sus precios**, los filtros y el registro de clientes
intactos, y quita el carrito. Así la tienda no promete algo que no puede cumplir.

⚠️ Son **las dos** filas: solo con la primera, PrestaShop **también oculta los precios**.

Para volver a tienda completa, cuando haya precios reales **y** transportista:

```sql
UPDATE psjy_configuration SET value = '0'
 WHERE name IN ('PS_CATALOG_MODE', 'PS_CATALOG_MODE_WITH_PRICES');
```

Detalle y la alternativa (crear un transportista real) en `07-transportistas-colombia.sql`.

---

## 6. Qué dejarme para que yo lo revise

Crea la carpeta **`deploy/entrada/`** en el repositorio y deja ahí estos cuatro ficheros. Con eso
puedo auditar el resultado sin tocar producción:

| Fichero | Cómo se obtiene |
|---|---|
| `01-dump-produccion.sql.gz` | phpMyAdmin → base de datos → **Exportar** → SQL, compresión gzip |
| `02-log-errores.txt` | Administrador de archivos → `var/logs/` → abre `prod-2026-07-XX.log` y copia las últimas ~100 líneas |
| `03-portada.html` | Abre la tienda, **clic derecho → Ver código fuente**, y guarda todo en este fichero |
| `04-notas.txt` | Dos líneas: qué hiciste y qué viste raro |

El más útil es el **`03-portada.html`**: leer el HTML que sirve el servidor es la única forma
fiable de detectar problemas reales — así encontré los 140 «Quick view» en inglés que una
auditoría de ficheros de traducción no vio.

Si prefieres no exportar la base entera, el `03` y el `04` ya me sirven para casi todo.

---

## 7. Estructura de la carpeta

```
deploy/paquete/
├── EMPEZAR-AQUI.md                     ← este fichero, lo único que hay que leer
├── 00-comprobacion-antes-de-importar.sql   ✅ ejecutado (19 productos, vía libre)
├── 00-RESULTADOS-produccion-20260729.txt   ✅ tus resultados, guardados como evidencia
├── 02-ajustes-tras-importar.sql        ★ el único obligatorio tras el volcado
├── 02b-limpieza-datos-demo.sql             ya aplicado al volcado
├── 02c-textos-en-ingles-en-datos.sql       ya aplicado al volcado
├── 03-opcional-precios-prueba.sql          no se ejecuta (decidido)
├── 06-cargar-precios-reales.sql            para cuando lleguen los precios
├── 07-transportistas-colombia.sql      ★ decisión antes de abrir al público
├── 04-PLAN-IMPORTACION.md                  detalle largo y diagnóstico de fallos
├── 05-CREDENCIALES.md                      accesos (no se versiona)
├── 00-PROGRESO-CLIENTE.md                  documento para el cliente
├── vt_autosoe_child.zip                📋 subido según tu reporte, sin verificar
├── img-importtools.zip                 📋 subido y extraído según tu reporte, sin verificar
└── modules/                            los dos es.php + el de leoquicklogin (⏳ pendientes de subir)

backups/importtools-FINAL-20260729-1726.sql.gz   ← el volcado a importar
deploy/entrada/                                  ← lo que me dejas para revisar (§6)
```

---

## Resumen en cinco líneas

1. **Hoy:** mantenimiento ON → activar el tema hijo → confirmar que carga. 4 clics, nada
   irreversible. Aguanta el minuto de la primera carga.
2. **Mañana:** JetBackup → importar volcado (16 s) → `02-ajustes` **seguido** (< 1 s) → vaciar
   cachés (+57 s la primera página).
3. **Comprobar** las 7 cosas de §4.
4. **Decidir** el modo catálogo antes de quitar el mantenimiento (§5).
5. **Dejarme** los ficheros de §6 y lo reviso.

---

## Registro de correcciones a este documento

Para que se sepa qué cambió y por qué:

| Fecha | Corrección |
|---|---|
| 29/07 | **Los tiempos del plan estaban inventados** («50–70 minutos», «Fase 1 — 15 min»). Sustituidos por los medidos: 16 s el volcado, 57,3 s la primera página tras vaciar caché, 0,3–0,5 s el resto. Lo que no se puede medir (subida, JetBackup) se declara como tal |
| 29/07 | **El paso «añadir tu IP a las permitidas» sobraba.** `PS_MAINTENANCE_ALLOW_ADMINS` ya está en 1 y la fila `PS_MAINTENANCE_IP` no existe: basta estar logueado |
| 29/07 | Los menús del panel se dieron **en inglés**, porque producción tiene `PS_LANG_DEFAULT = 1` y solo `en-US`. Antes se daban en español, que es lo que se verá **después** del import |
| 29/07 | Indicadores separados por origen: **✅ verificado** por mí / **📋 reportado** por ti / **⏳ pendiente**. Antes había «✓ ya subido» sobre cosas que no comprobé |
