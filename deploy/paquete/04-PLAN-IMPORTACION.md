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
| 0.3 | Confirmar que nadie ha cambiado nada en producción desde el **24/07/2026** | Ver §«Si producción cambió» al final |
| 0.4 | Activar mantenimiento y **añadir tu IP** a las permitidas | La tienda muestra la página de mantenimiento; tú sigues viéndola |
| 0.5 | Comprobar PHP 8.5 y `memory_limit ≥ 512M` | cPanel → MultiPHP INI Editor |

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

**1.2 Traducciones de módulo.** Subir sobrescribiendo:

```
modules/leoelements/translations/es.php          (564 claves)
modules/leoproductsearch/translations/es.php     (25 claves)
```

**1.3 Tema hijo.** Back office → **Diseño → Tema y logotipo → Añadir nuevo tema → subir
`vt_autosoe_child.zip`**. Luego **Usar este tema**.

> ⚠️ El tema padre **`vt_autosoe` debe seguir instalado**. El hijo lo necesita: sin él no
> hay plantillas y la tienda se cae.

Comprobación: la lista de temas muestra `Importtools (AutoSoe child)` como activo.

---

## Fase 2 — Base de datos (20 min)

**2.1** phpMyAdmin → seleccionar la base de datos de la tienda.

**2.2** Importar `backups/importtools-FINAL-*.sql.gz`. El volcado trae
`DROP TABLE IF EXISTS`, así que **reemplaza** el contenido anterior.

Si phpMyAdmin da tiempo de espera, usar cPanel → Terminal:

```
mysql -u USUARIO -p BASEDEDATOS < importtools-FINAL-*.sql
```

**2.3** Ejecutar **`02-ajustes-tras-importar.sql`**. Es obligatorio: cambia el dominio (el
volcado viene con `localhost:8080`), activa HTTPS y **vacía la caché de CSS de Elementor**.

**2.4** Decidir sobre **`03-opcional-precios-prueba.sql`** (ver Fase 5).

### Ya probado

Restauré este mismo volcado en una base limpia antes de entregarlo:

```
productos 3036 · en catálogo 3036 · stock 3036 · marcas 7 · características 6072
contenidos Leo 34 (JSON válido 34/34) · perfiles Leo 1 · menú 54 items · CMS 14
empleados 3 · perfiles admin 5 · permisos del cliente 302 + 48 de módulo
LEOELEMENTS_PANEL_TOOL = 0 · contenidos con rastro demo = 0
```

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

### 4.2 Back office como administrador

Entrar en `https://www.importtoolsas.com/panel-4h5o/` con el súper-admin.

| # | Ruta | Esperado |
|---|---|---|
| 1 | Catálogo → Productos | Lista con 3.036 productos |
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

## Fase 5 — Precios de prueba: **decidir antes de abrir al público**

Los 3.036 productos tienen **precios generados** para poder ver la tienda funcionando. Están
marcados con `supplier_reference = 'PRECIO-PRUEBA'`.

`03-opcional-precios-prueba.sql` trae las dos salidas:

- **Opción A** — ocultar los productos hasta tener precios reales.
- **Opción B** — dejarlos visibles como catálogo, a precio 0, con «consultar precio».

Y la receta para cargar los precios reales por referencia.

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

## Si producción cambió después del 24/07/2026

Este volcado **sobrescribe** la base de datos entera. Si en producción se añadieron pedidos,
clientes o productos después de esa fecha, **avísame antes de importar**: hay que hacer una
importación selectiva por tablas en lugar de la completa, y eso se prepara aparte.

Para saberlo:

```sql
SELECT MAX(date_add) FROM psjy_orders;
SELECT MAX(date_add) FROM psjy_customer;
SELECT MAX(date_upd) FROM psjy_product;
```

Si alguna fecha es posterior al 24/07/2026, para y consúltalo.
