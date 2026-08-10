# Paso a paso de la subida a producción

Importtools S.A.S · `www.importtoolsas.com` · **03/08/2026**

> **Qué es este documento.** El operativo: qué se toca, en qué orden y cómo se
> comprueba. El *qué cambió y por qué* está en `13-PLAN-SUBIDA-20260803.md`; el
> detalle de diagnóstico y los tiempos medidos, en `04-PLAN-IMPORTACION.md`.
> Si solo vas a leer uno antes de empezar, lee este.

| Dato | Valor |
|---|---|
| Hosting | Latinoamérica Hosting, plan **H2**, cPanel |
| Raíz web | `public_html/` |
| Base de datos | `importto_pres437` — **confírmalo en cPanel → MySQL Databases** |
| Prefijo de tablas | `psjy_` |
| Back office | `https://www.importtoolsas.com/panel-4h5o` |
| Idioma | es-CO (`iso_code` = `es`) |

**Tiempo realista:** 45–70 min si nada se atraviesa. La subida de ficheros (≈14 MB)
depende de tu conexión, y **la primera página después de vaciar la caché tarda unos
57 segundos** (medido). No es que se haya colgado.

---

## Lo que necesitas a mano antes de empezar

- [ ] Acceso a **cPanel** (Administrador de archivos y phpMyAdmin) o SSH.
- [ ] Usuario **super-admin** del back office.
- [ ] Los ficheros de esta lista, todos en `deploy/paquete/` salvo el volcado:

| Fichero | Tamaño | Dónde va |
|---|---|---|
| `backups/importtools-FASE2-20260803-1345.sql.gz` | 638 KB | phpMyAdmin |
| `vt_autosoe_child-EXTRAER-EN-themes.zip` | 8,8 MB · 473 fich. | `public_html/themes/` |
| `itcotizacion-EXTRAER-EN-modules.zip` | 21 KB · 17 fich. | `public_html/modules/` |
| `img-importtools.zip` | 5,7 MB · 346 fich. | `public_html/img/` |
| `modulos-traducciones-EXTRAER-EN-modules.zip` | 17 KB · 4 fich. | `public_html/modules/` |
| `traducciones-EXTRAER-EN-translations.zip` | 1,2 MB | `public_html/translations/` — **solo si falta** (paso 3) |
| `14a-caches-off-al-empezar.sql` | | phpMyAdmin, paso 1 |
| `02-ajustes-tras-importar.sql` | | phpMyAdmin, paso 4 |
| `14b-caches-on-al-terminar.sql` | | phpMyAdmin, paso 9 |
| `14c-abrir-la-tienda.sql` | | phpMyAdmin, paso 10 |

> El **volcado no viaja en el paquete**: lleva hashes de contraseñas. Vive en
> `backups/`, fuera del control de versiones.

> `deploy/img/bancos/` y `deploy/img/footer_imagen.png` son los **originales que
> mandó el cliente**. **No** van al servidor y por eso no entran en el zip: de ahí
> se recortaron `it/pagos-autorizados.png` y `it/pie-asesor.png`.

---

## Paso 0 · Respaldo — el punto de retorno

1. cPanel → **JetBackup** → respaldo **completo**: archivos **y** base de datos.
2. Anota la hora. Es el único punto al que puedes volver entero.
3. Confirma que **nadie ha tocado producción** desde el último despliegue
   (31/07/2026). Si alguien cambió algo por el back office, **para y avísame**:
   el volcado del paso 4 lo sobrescribe.

Comprobación rápida de que no hay actividad real que perder:

```sql
SELECT (SELECT COUNT(*) FROM psjy_orders)        AS pedidos,
       (SELECT COUNT(*) FROM psjy_customer)      AS clientes,
       (SELECT COUNT(*) FROM psjy_it_cotizacion) AS solicitudes;
```

Esperado: `0 · 1 · 0`. El cliente que aparece es «Anonymous», del módulo de RGPD, y
**el núcleo lo necesita** para anonimizar. Si sale algún pedido o alguna solicitud
real, **no importes**: hay que fusionar, no sobrescribir.

---

## Paso 1 · Cerrar la tienda y apagar las cachés de Smarty

phpMyAdmin → base de datos → pestaña **SQL** → pega y ejecuta
**`14a-caches-off-al-empezar.sql`**.

Tiene que devolver:

```
PS_MAINTENANCE_ALLOW_ADMINS  1
PS_SHOP_ENABLE               0
PS_SMARTY_CACHE              0
PS_SMARTY_FORCE_COMPILE      1
```

> ⚠️ **Este paso no es opcional y es el que más tiempo costó descubrir.**
> Con `PS_SMARTY_FORCE_COMPILE = 0`, `config/smarty.config.inc.php:22` pone
> `compile_check = COMPILECHECK_OFF`: Smarty **ni mira** si la plantilla cambió y
> sirve lo que compiló la instalación anterior. Puedes subir el tema entero y no
> cambiar un solo píxel, **sin ningún error**. En el despliegue del 31/07 costó dos
> rondas de diagnóstico equivocado.

Mientras esté así la tienda va más lenta. Es a propósito y dura solo el despliegue.

---

## Paso 2 · Subir los ficheros

Orden indiferente entre ellos, pero **todos antes** de importar la base.

### 2.1 Tema hijo — se sobrescribe, no se reinstala

`vt_autosoe_child` **ya está instalado y activo** (`psjy_shop.theme_name`). Esto es una
actualización de sus ficheros, no una instalación.

> ⚠️ **No uses *Diseño → Tema y logotipo → Añadir nuevo tema*.** Ese botón *instala*
> un tema: se queja de que «ya hay un tema con ese nombre», y si lo forzaras volvería
> a correr la instalación del tema, que reejecuta hooks y puede reordenar las
> posiciones de los módulos. `vt_autosoe_child-SUBIR-POR-PANEL.zip` existe **solo**
> para una primera instalación en una tienda limpia.
>
> ⚠️ Y **no borres la carpeta antes de extraer.** Si eliminas el tema activo el sitio
> da 500 y recuperarse es incómodo. Se extrae **encima**.

**Es seguro sobrescribir el tema activo:** PrestaShop lee el tema del disco en cada
petición y lo compilado vive en `var/cache/`, que se vacía en el paso 5. Con la tienda
en mantenimiento nadie ve el estado intermedio.

#### a) Respaldo — fuera de `themes/`

```bash
cd ~/public_html/themes
mkdir -p ~/respaldos
tar czf ~/respaldos/vt_autosoe_child-ANTES-$(date +%Y%m%d).tar.gz vt_autosoe_child
```

Por cPanel: clic derecho en `vt_autosoe_child` → **Compress** → y **mueve el zip
fuera de `themes/`** o descárgalo y bórralo del servidor.

> ⚠️ **El respaldo no puede quedarse dentro de `themes/`.** `ThemeRepository` lista
> los temas con `glob(themes/*/config/theme.yml)`: una carpeta `vt_autosoe_child.bak`
> con su `theme.yml` dentro **aparecería como un segundo tema** en el panel.
> Y el `.htaccess` de `themes/` **permite `.zip` explícitamente**, así que un zip
> olvidado ahí queda descargable por cualquiera.

#### b) Extraer encima

```bash
unzip -o ~/vt_autosoe_child-EXTRAER-EN-themes.zip -d ~/public_html/themes/
```

Por cPanel: subir el zip a `public_html/themes/` → **Extract** → sobrescribir todo →
**borrar el zip del servidor**.

El zip trae la carpeta `vt_autosoe_child/` dentro, así que se fusiona con la existente.

> Extraer encima **sobrescribe y añade, pero no borra**. En esta ronda no se eliminó
> ningún fichero del tema, así que el resultado es idéntico a un reemplazo limpio. Si
> alguna versión futura quita ficheros, habrá que borrar la carpeta y extraer entera
> (con la tienda en mantenimiento y el respaldo hecho).

#### c) Permisos

```bash
cd ~/public_html/themes
find vt_autosoe_child -type d -exec chmod 755 {} +
find vt_autosoe_child -type f -exec chmod 644 {} +
```

#### d) Comprobar antes de seguir

```bash
cd ~/public_html

# 475 ficheros, sin contar la caché generada
find themes/vt_autosoe_child -type f -not -path "*/assets/cache/*" | wc -l

# la carpeta modules/ del hijo tiene que seguir ahí
find themes/vt_autosoe_child/modules -type f | wc -l          # 354

# el CSS tiene que traer las reglas nuevas
grep -c 'translateX(100vw)'      themes/vt_autosoe_child/assets/css/custom.css   # 1
grep -c 'header__button--cotizar' themes/vt_autosoe_child/assets/css/custom.css  # 1
```

Si `modules/` diera 0, el tema quedó incompleto y **los widgets de Leo no pintarán
nada, sin ningún error**: resuelven sus plantillas con `_PS_THEME_DIR_`, que apunta al
tema activo.

#### e) El tema padre

**`vt_autosoe` debe seguir instalado.** El hijo lo necesita. Y si algún día lo
actualizas, hay que volver a copiar `themes/vt_autosoe/modules/` dentro del hijo.

> ⚠️ Si algún día actualizas el tema padre, hay que **volver a copiar
> `themes/vt_autosoe/modules/` dentro del hijo**. 33 ficheros de los módulos de Leo
> resuelven sus plantillas con `_PS_THEME_DIR_`, que apunta al tema **activo**; sin
> esa carpeta el `fetch()` de Smarty falla y los widgets **no pintan nada, sin
> ningún error visible**. El zip de este paquete ya la trae.

### 2.2 Módulo de cotización

`public_html/modules/` → subir `itcotizacion-EXTRAER-EN-modules.zip` → **Extraer** →
borrar el zip. Trae la carpeta `itcotizacion/` dentro.

Cambia `itcotizacion.php` (ahora cuenta la lista de deseos leyendo la base),
`views/js/cotizacion.js`, `views/css/cotizacion.css` y
`views/templates/front/cotizacion.tpl`.

**No** hay que reinstalar el módulo: no cambian ni hooks ni tablas.

### 2.3 Imágenes

`public_html/img/` → subir `img-importtools.zip` → **Extraer** → borrar el zip.

Después tiene que existir:

```
img/it/                            147 ficheros
img/it/pagos-autorizados.png       ← nueva, la tira de los tres bancos
img/it/pie-asesor.png              ← nueva, la foto del pie
img/it/banco-bancolombia.png       ← nueva
img/it/banco-bogota.png            ← nueva
img/it/banco-davivienda.png        ← nueva
img/m/3.jpg … 9.jpg                logotipos de las marcas
img/logo-importtools-white.png
img/logo-importtools-dark.png
img/favicon.ico
img/logo-1784922108.jpg            ← el número es PS_IMG_UPDATE_TIME; no lo renombres
```

### 2.4 Traducciones de módulo

`public_html/modules/` → subir `modulos-traducciones-EXTRAER-EN-modules.zip` →
**Extraer**. Son cuatro ficheros, cada uno en la carpeta de su módulo:

```
modules/leoelements/translations/es.php        564 claves
modules/leoproductsearch/translations/es.php
modules/leoquicklogin/translations/es.php
modules/leofeature/translations/es.php         ← nuevo esta ronda
```

> ⚠️ En **`leoproductsearch` ya existe un `es.php` del fabricante**: renómbralo a
> `es.php.bak` antes de extraer. Es seguro — está comprobado clave por clave que el
> nuestro conserva las 17 originales sin cambiar ninguna y añade 8.
> En `leoelements` **no existe ninguno**: ese módulo no trae traducciones del
> fabricante, y es la razón por la que la tienda salía en inglés.

---

## Paso 3 · Comprobar que los ficheros llegaron bien

Antes de tocar la base. Cuatro cosas, y las cuatro han fallado alguna vez.

### 3.1 Los dotfiles de la raíz

```bash
ls -la public_html/.env public_html/.htaccess
```

Tienen que existir los dos.

| Si falta | Síntoma |
|---|---|
| `.env` | **HTTP 500 en todo el sitio.** `index.php:25` hace `(new Dotenv(false))->loadEnv()` y lanza `PathException` |
| `.htaccess` | La portada carga pero **toda URL amigable da 404** |

> ⚠️ Al comprimir desde cPanel hay que activar **«Mostrar archivos ocultos
> (dotfiles)»** en Configuración, o no entran. Un cliente FTP mal configurado los
> omite igual.

### 3.2 Los 169 catálogos de traducción

```bash
ls public_html/translations/es-CO/*.xlf | wc -l
```

Tiene que decir **169**. Si dice menos, sube y extrae **uno** de estos dos —traen lo
mismo, cambia solo dónde se descomprimen, y el nombre lo dice:

| Zip | Extraer en | Dentro trae |
|---|---|---|
| `traducciones-EXTRAER-EN-translations.zip` | `public_html/translations/` | `es-CO/…` |
| `traducciones-EXTRAER-EN-RAIZ.zip` | `public_html/` | `translations/es-CO/…` |

> ⚠️ Los catálogos de traducción son **ficheros, no filas de la base**. El volcado
> trae la fila del idioma pero nada que traducir: si esa carpeta no está, **todo el
> núcleo cae al inglés** y parece un problema de configuración del idioma.
> Este era el único punto que quedó pendiente del despliegue anterior.

### 3.3 Los ficheros nuevos están donde toca

```bash
ls -la public_html/themes/vt_autosoe_child/assets/css/custom.css   # ~44 KB
ls -la public_html/themes/vt_autosoe_child/assets/js/custom.js     # ~18 KB
ls -la public_html/themes/vt_autosoe_child/templates/catalog/_partials/product-add-to-cart.tpl
ls -la public_html/img/it/pagos-autorizados.png public_html/img/it/pie-asesor.png
ls -la public_html/modules/leofeature/translations/es.php
```

### 3.4 Permisos y propietario

```bash
find public_html/themes/vt_autosoe_child -type d -exec chmod 755 {} +
find public_html/themes/vt_autosoe_child -type f -exec chmod 644 {} +
find public_html/modules/itcotizacion    -type d -exec chmod 755 {} +
find public_html/modules/itcotizacion    -type f -exec chmod 644 {} +
```

Si extrajiste por el Administrador de archivos de cPanel el propietario ya es el
correcto. Si subiste por SSH como otro usuario, revísalo.

---

## Paso 4 · Base de datos

Los dos sub-pasos **en la misma sesión, sin pausa entre ellos**.

### 4.1 Importar el volcado

1. phpMyAdmin → **selecciona la base de datos** (`importto_pres437`).
   ⚠️ Mira dos veces que es la correcta: el volcado trae `DROP TABLE IF EXISTS`.
2. Pestaña **Importar** → `importtools-FASE2-20260803-1345.sql.gz` → **Continuar**.
   Tarda unos 16 s.

### 4.2 Ajustes obligatorios

Pestaña **SQL** → pega y ejecuta **`02-ajustes-tras-importar.sql`**.

> ⚠️ **Entre 4.1 y 4.2 la tienda está apuntando a `localhost:8080`** — el dominio
> del espejo, que viaja dentro del volcado — así que **la tienda y el back office
> redirigen a localhost**. Es normal y se arregla con 4.2. Si te distraes aquí,
> parecerá que rompiste el sitio.
>
> ⚠️ Y el volcado **te quita el mantenimiento**: trae `PS_SHOP_ENABLE = 1` del
> espejo. Por eso 4.2 vuelve a cerrar la tienda en su primera línea.

Lo que hace 4.2, por orden: cierra la tienda, pone el dominio real, activa HTTPS,
**vacía la caché de CSS de Elementor** y reafirma el modo catálogo.

Al final imprime seis comprobaciones. Tienen que dar:

| Comprobación | Esperado |
|---|---|
| productos · en_catalogo · marcas · características | `3036 · 3036 · 7 · 6072` |
| idioma | `es-CO`, iso `es`, activo |
| menú | `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO` |
| módulo de cotización | activo `1`, prospectos `0`, WhatsApp `573145934962` |
| CMS 4 y 7 | `trae_diseno_nuevo = 1` en las dos |
| estado | `PS_SHOP_ENABLE 0` · `PS_CATALOG_MODE 1` · `PS_CATALOG_MODE_WITH_PRICES 0` |

> ### Alternativa: no reimportar la base
>
> Si ya hay **solicitudes de cotización reales** que no quieres perder, no importes:
> los únicos cambios de base de esta ronda son dos rutas de imagen dentro del JSON
> de Leo, y hay un script para eso.
>
> 1. Sube `12-imagenes-del-cliente.php` a un sitio **fuera** de la raíz web si el
>    hosting lo permite (p. ej. `/home/usuario/tmp/`); si no, a `public_html/` y lo
>    borras en cuanto acabes.
> 2. Ejecútalo por SSH, o por *Terminal* de cPanel, pasándole las credenciales
>    reales por entorno (los valores por defecto son los del espejo):
>
> ```bash
> export IT_DB_HOST=localhost IT_DB_USER=USUARIO IT_DB_PASS='CLAVE' \
>        IT_DB_NAME=importto_pres437 IT_DB_PREFIX=psjy_
> php 12-imagenes-del-cliente.php seco   # informa: 6 filas, 18 sustituciones
> php 12-imagenes-del-cliente.php        # aplica
> rm 12-imagenes-del-cliente.php         # ⚠️ no dejarlo en la raíz web
> ```
>
> Cambia **solo rutas de fichero**, valida `JSON_VALID` antes de escribir de cada
> fila e invalida la caché de CSS de Leo al terminar. Si alguna fila no valida, la
> salta y lo dice; no escribe JSON roto.
>
> Con esta vía **te saltas también** el resto de lo acumulado en el volcado desde el
> 01/08: si producción viene del despliegue del 31/07, te faltarían cosas. Solo tiene
> sentido si en producción ya hay datos reales.
>
> ⚠️ Acota el cambio del fondo a los contenidos del pie (4, 8 y 12) **a propósito**:
> `banner-med-a.jpg` se usa además en el cuerpo del home y en la cabecera de las
> categorías, y la prueba en seco encontró **40 coincidencias en 18 filas**.
> Cambiarlas todas habría puesto la foto del asesor detrás de banners que no tienen
> nada que ver.

---

---

## Si ya importaste antes de subir los ficheros

Pasó el 03/08/2026. No es grave, pero el orden cambia y hay dos cosas que **no** se
pueden saltar. Reordena así:

1. **Recuperar el acceso.** El volcado trae `localhost:8080` dentro, así que la tienda
   **y el back office** redirigen ahí. phpMyAdmin no pasa por PrestaShop, así que sigues
   teniendo acceso: ejecuta el paso **4.2** (`02-ajustes-tras-importar.sql`) ya mismo.
2. ⚠️ **Prueba en una ventana de incógnito.** El redirect a localhost es un **301, y los
   navegadores los cachean de forma permanente**: aunque la base ya esté bien, tu
   navegador seguirá yendo a `localhost:8080` porque se lo aprendió. Es el motivo por el
   que este paso parece no funcionar.
3. **Ejecuta ahora el paso 1** (`14a-caches-off-al-empezar.sql`). Va después de lo
   normal, pero tiene que estar **antes** de que se reconstruyan las cachés, o los
   ficheros que subas a continuación no surtirán efecto.
4. Sigue con el paso **2** (subir ficheros) y **3** (comprobar que llegaron).
5. Retoma en el paso **5** (vaciar cachés) y continúa normal.

Lo único que se pierde por el desorden es tiempo: la caché se reconstruye dos veces.

---

## Paso 5 · Vaciar cachés — en este orden

El orden importa: si purgas LiteSpeed antes de vaciar `var/cache/`, vuelve a
guardar la página vieja.

1. Back office → **Parámetros avanzados → Rendimiento → Borrar la caché**.
2. Por SSH o Administrador de archivos:

```bash
cd public_html
rm -rf var/cache/*
rm -f  themes/vt_autosoe_child/assets/cache/*
rm -f  modules/leoelements/gencode/LeoGenCode_*.html
```

3. Si el hosting tiene **LiteSpeed Cache**: cPanel → *LiteSpeed Web Cache Manager*
   → **Flush All**. En este plan (H2) está activo, así que no te lo salte.

> `themes/vt_autosoe_child/assets/cache/` es donde vive el CSS y el JS
> concatenados (`theme-<hash>.css`, `bottom-<hash>.js`). El hash se calcula del
> contenido, así que al cambiar `custom.css` el nombre cambia solo — pero conviene
> borrar los viejos para no dejar basura acumulada.

---

## Paso 6 · Calentar

Abre `https://www.importtoolsas.com/` **con tu sesión de administrador**.

**La primera carga tarda ~57 segundos** (medido): Smarty está recompilando las
plantillas y, además, `PS_SMARTY_FORCE_COMPILE` sigue en 1 del paso 1. No recargues
nervioso ni des el sitio por muerto. La segunda ya va normal.

Repite con estas cinco, para que se compile todo lo que vas a comprobar:

```
/2-catalogo
/17-herramientas-electricas
/content/4-quienes-somos
/content/7-quiero-ser-cliente
/module/itcotizacion/cotizacion
```

---

## Paso 7 · Comprobaciones

### 7.1 Escritorio (ventana ancha, ≥ 1280 px)

| # | Dónde | Qué tiene que pasar |
|---|---|---|
| 1 | Portada | Carga sin avisos amarillos |
| 2 | Menú | Las 7 secciones, y el panel de CATEGORIAS se abre **solo al pasar el ratón** |
| 3 | Cabecera | **Corazón, cotización y cuenta en la misma línea**, mismo tamaño, los tres en blanco con globo rojo. La cotización se ve **sin** pasar el ratón |
| 4 | Franja bajo el menú | Se leen dirección, teléfono y horario, con el pin de ubicación en rojo |
| 5 | Portada, bajo el banner | Las **tres tarjetas** miden lo mismo y empiezan **por debajo** del banner, sin tapar los puntos del carrusel |
| 6 | Portada | **No** aparece «No blog at this time.» ni la sección *Consejos de uso y mantenimiento* |
| 7 | Pie, banda de suscripción | Foto del asesor de fondo, oscurecida, texto legible encima |
| 8 | Pie, barra inferior | Solo **Bancolombia, Banco de Bogotá y Davivienda**. Ni Bitcoin, ni Apple Pay, ni Discover, ni VISA |
| 9 | `/2-catalogo` | «Hay 3036 productos», sin precios ni «ordenar por precio» |
| 10 | `/17-herramientas-electricas` | Filtros: Disponibilidad · Línea · Marca · Precio · Sublínea |
| 11 | `/brands` | Las 7 marcas, con logotipo las 4 propias |
| 12 | Una ficha de producto | Selector de cantidad + botón **«Agregar a mi cotización»** |
| 13 | `/module/itcotizacion/cotizacion` | Bloque **Pagos autorizados** con los tres bancos |
| 14 | Engranaje lateral en la tienda | **No debe aparecer** (`LEOELEMENTS_PANEL_TOOL = 0`) |
| 15 | Código fuente, buscar `cdn.shopify.com` | **0 resultados** |
| 16 | Pasar el ratón por una ficha | **«Vista rápida»**, no *«Quick view»* |
| 17 | `/esto-no-existe` | 404 en español |

### 7.2 Móvil — con el navegador a **390 px de ancho real**

No con el zoom del escritorio: en las herramientas de desarrollo, modo dispositivo,
390 × 844.

| # | Qué tiene que pasar |
|---|---|
| 18 | Barra negra de **una línea** (teléfono · Cómo llegar) y debajo logo + lupa + corazón + cotización. **Sin franjas blancas sueltas** |
| 19 | **Un solo** icono de hamburguesa. Al pulsarlo el cajón entra **por la derecha**, con X arriba y el resto de la página oscurecida. Se cierra con la X, tocando fuera y con **Escape** |
| 20 | La lupa abre el campo de búsqueda **justo debajo de la cabecera**, no en lo alto de la pantalla |
| 21 | «Elige tu marca»: las **cuatro** marcas en 2×2, logos a la misma altura, ninguna repetida |
| 22 | **Sin desplazamiento horizontal** en portada, catálogo, categoría, cotización y *Quiénes somos* |
| 23 | La barra fija de abajo (Catálogo · Cuenta · Lista de deseos) no tapa el contenido al final de la página |

Para el 22, en la consola del navegador:

```js
document.documentElement.scrollWidth <= window.innerWidth
```

Tiene que devolver `true` en las cinco.

### 7.3 Back office

| # | Dónde | Qué tiene que pasar |
|---|---|---|
| 24 | Diseño → Leo Elements | Los 17 contenidos abren en el editor |
| 25 | Catálogo → Productos | Lista 3.036, sin error |
| 26 | Sesión con el perfil **Cliente Importtools** | Ve Productos, Categorías, CMS, Pedidos y el menú de Leo; **403** en Tema, Módulos, Empleados, Rendimiento, SQL, Transportistas e Impuestos |
| 27 | Módulos → itcotizacion → Configurar | Abre y muestra el número de WhatsApp |

### 7.4 El corazón

| # | Qué hacer | Qué tiene que pasar |
|---|---|---|
| 28 | Pulsar el corazón de un producto **sin** haber entrado con cuenta | Aviso **en español**: «Entra a tu cuenta para guardar productos en tus favoritos.» |
| 29 | Entrar con una cuenta, guardar un producto y **recargar la página** | El globo del corazón **mantiene el número**. Antes salía vacío al recargar y **NaN** al guardar el primero |

---

## Paso 8 · Confirmar que lo nuevo se está sirviendo de verdad

Este paso existe por la trampa del paso 1: **los ficheros pueden estar subidos y el
sitio seguir sirviendo los viejos, sin ningún error**. Aquí se comprueba con
centinelas — cadenas que solo existen en la versión de esta ronda.

```bash
# 1) qué CSS y JS está sirviendo la portada
curl -s https://www.importtoolsas.com/ \
  | grep -oE 'themes/vt_autosoe_child/assets/cache/(theme|bottom)-[a-f0-9]+\.(css|js)'
```

Apunta los dos nombres y compruébalos:

```bash
# 2) el CSS tiene que traer la regla nueva del cajón del menú
curl -s https://www.importtoolsas.com/themes/vt_autosoe_child/assets/cache/theme-XXXXXX.css \
  | grep -c 'translateX(100vw)'          # esperado: 1

# 3) y la figura del acceso a la cotización
curl -s https://www.importtoolsas.com/themes/vt_autosoe_child/assets/cache/theme-XXXXXX.css \
  | grep -c 'header__button--cotizar'    # esperado: 1

# 4) el JS tiene que traer el cierre con Escape y el contador del corazón
curl -s https://www.importtoolsas.com/themes/vt_autosoe_child/assets/cache/bottom-XXXXXX.js \
  | grep -c 'off-canvas-button-megamenu' # esperado: 3

# 5) y el módulo tiene que estar publicando el total desde la base
curl -s https://www.importtoolsas.com/ | grep -o 'itfav = {[^}]*}'
#   esperado, como visitante anónimo:  itfav = {"logueado":false,"total":0}
```

**Si el punto 2 devuelve 0**, el CSS que se sirve es el viejo. En ese caso:
vuelve al paso 5, vacía `var/cache/` y `themes/vt_autosoe_child/assets/cache/`,
purga LiteSpeed y confirma que `PS_SMARTY_FORCE_COMPILE` sigue en **1**.

---

## Paso 9 · Optimización

### 9.1 Devolver las cachés de PrestaShop

phpMyAdmin → **`14b-caches-on-al-terminar.sql`**. Deja:

| Ajuste | Valor | Por qué |
|---|---|---|
| `PS_SMARTY_CACHE` | 1 | vuelve a cachear las plantillas |
| `PS_SMARTY_FORCE_COMPILE` | 0 | deja de recompilar en cada visita |
| `PS_CSS_THEME_CACHE` | 1 | un solo `theme-<hash>.css` en vez de decenas de peticiones |
| `PS_JS_THEME_CACHE` | 1 | un solo `bottom-<hash>.js` |

Y **vacía `var/cache/` una vez más**: al volver `PS_SMARTY_FORCE_COMPILE` a 0, lo
primero que se compile queda congelado.

```bash
rm -rf public_html/var/cache/*
```

> Los otros tres interruptores del panel de Rendimiento —comprimir HTML, comprimir
> JS en línea y aplazar la carga de JS— **no se tocan**. No existen como fila en
> esta base, corren con el valor por defecto del núcleo y **no están probados en
> este montaje**. Activarlos a ciegas el día del despliegue es la forma más rápida
> de romper algo que ya funciona. Si algún día se quieren, se prueban antes en el
> espejo, uno por uno.

### 9.2 LiteSpeed

cPanel → *LiteSpeed Web Cache Manager*:

- **Flush All** una última vez, después de vaciar `var/cache/`.
- Deja la caché de páginas **activa**: es la mayor ganancia de este hosting y no hay
  Redis en el plan compartido.
- Si usas **Cloudflare** delante: SSL en modo **Full (strict)**, o deja Cloudflare
  solo en DNS al principio para no chocar con el certificado del hosting.

### 9.3 PHP

cPanel → *Select PHP Version*:

- [ ] **PHP 8.5**
- [ ] Extensiones: `curl`, `dom`, `gd`, `intl`, `mbstring`, `zip`, `json`
- [ ] `memory_limit` = **512M**
- [ ] `max_execution_time` ≥ **120**
- [ ] `max_input_vars` ≥ **5000** — Leo Elements manda formularios enormes; por
      debajo de eso el editor guarda los contenidos **truncados sin avisar**
- [ ] OPcache activo

### 9.4 Vigilar los inodos

El plan H2 da ~200.000. PrestaShop genera varias miniaturas por producto y hoy hay
3.036 sin foto: cuando lleguen las fotos reales, esto sube deprisa.

```bash
find public_html -type f | wc -l
```

Si se acerca a 150.000, toca hablar de subir a H3 (mismo proveedor, se paga solo la
diferencia).

---

## Paso 10 · Abrir la tienda

Solo cuando **§7 y §8** hayan pasado.

phpMyAdmin → **`14c-abrir-la-tienda.sql`**.

Después ábrela en una **ventana de incógnito**: con tu sesión de administrador la
verías bien de todas formas (`PS_MAINTENANCE_ALLOW_ADMINS = 1`).

---

## Paso 11 · Limpieza y seguridad

- [ ] **Borra los .zip del servidor**: `themes/`, `modules/`, `img/`,
      `translations/`. El `.htaccess` de `themes/` permite `.zip`, así que uno
      olvidado ahí queda descargable por cualquiera.
- [ ] Comprueba que **no hay ficheros auxiliares del espejo** en la raíz. Nunca se
      suben, pero si alguna vez se sincroniza la raíz completa entrarían:

```bash
ls -la public_html/_movil.html public_html/_inspeccionar.html \
       public_html/_interactuar.html public_html/_medir-desbordamiento.html \
       public_html/_punto.html 2>/dev/null
```

  No debe existir ninguno. Si aparecen, bórralos.
- [ ] **Rota la contraseña de la base de datos**: ha circulado en copias locales.
      cPanel → MySQL Databases → cambiar contraseña, y actualizarla en
      `app/config/parameters.php`.
- [ ] Confirma que **JetBackup** hace copias automáticas diarias.
- [ ] Deja anotada la fecha del despliegue en `11-PLAN-FASE-II.md`.

---

## Si algo sale mal

### Los cinco tropiezos conocidos, con su síntoma

| Síntoma | Causa | Solución |
|---|---|---|
| Subes el tema y **no cambia nada** | `PS_SMARTY_FORCE_COMPILE = 0`: Smarty ni mira si la plantilla cambió | Paso 1, y vaciar `var/cache/` |
| **HTTP 500 en todo el sitio** | Falta `.env` en la raíz | Crearlo con `APP_ENV=prod` y `APP_DEBUG=0` |
| La portada carga pero **toda URL amigable da 404** | Falta `.htaccess` | Back office → Parámetros de la tienda → Tráfico y SEO → Guardar (lo regenera) |
| **Todo el núcleo en inglés** | Falta `translations/es-CO/` (169 XLIFF) | Paso 3.2 |
| Los **widgets de Leo no pintan nada**, sin error | Falta `themes/vt_autosoe_child/modules/` | Copiar `themes/vt_autosoe/modules/` dentro del hijo |

Y dos comportamientos del núcleo que **no** son fallos: el bucle a
`/security/compromised?uri=…` (PrestaShop 9 exige token por URL en el back office) y
la interstitial «Token no válido» de algunas páginas de módulo.

### Dónde mirar

```bash
tail -50 public_html/var/logs/prod-$(date +%Y-%m).log
tail -50 ~/logs/importtoolsas.com.error.log      # ruta según cPanel
```

### Marcha atrás

1. **JetBackup**, respaldo del paso 0. Es lo primero y lo más limpio.
2. Si solo hay que volver la base: en `backups/` están los volcados intermedios con
   fecha y hora.
3. Si hay que rehacer la portada desde cero: el contenido original del tema sigue
   intacto en `themes/vt_autosoe/samples/leoelements.xml` (9,3 MB).

---

## Anexo · Rehacer los zips del paquete

Si tocas el tema, el módulo o las imágenes y hay que regenerar los zips:

```bash
python local-dev/empaquetar.py            # los cinco
python local-dev/empaquetar.py tema       # solo uno
```

> ⚠️ **No uses `Compress-Archive` de Windows PowerShell 5.1.** Escribe los nombres
> de entrada con **barra invertida** (`vt_autosoe_child\assets\css\custom.css`), que
> va contra la especificación ZIP —el apéndice 4.4.17.1 exige `/`—. Al extraerlo en
> el servidor no se crean carpetas: sale un fichero plano llamado literalmente
> `vt_autosoe_child\assets\css\custom.css`. Pasó el 03/08/2026 y se detectó
> listando las entradas antes de subir nada. `empaquetar.py` normaliza a `/` y
> además comprueba que no quede ninguna entrada con `\`.
