# Despliegue en producción — Import Tools Latam S.A.S

Paquete generado el **28/07/2026** desde el entorno local espejo.
Destino: hosting **Latinoamérica Hosting H2**, cPanel, dominio `www.importtoolsas.com`.

Prefijo de tablas: **`psjy_`** · Carpeta del back office: **`panel-4h5o`** · Idioma: **es-CO**.

---

## 0. Antes de empezar

- [ ] **Respaldo completo de producción** (JetBackup: archivos + base de datos). Sin esto no
      se continúa.
- [ ] Confirmar que **nadie ha cambiado nada en producción** desde el 24/07/2026, fecha del
      volcado del que partió el entorno local. Si se tocó algo, avísame antes de importar:
      este volcado lo sobrescribe.
- [ ] Poner la tienda en mantenimiento: *Parámetros de la tienda → Mantenimiento*,
      añadiendo tu IP en la lista de permitidas.

## 1. Contenido del paquete

| Fichero | Qué es | Dónde va |
|---|---|---|
| `vt_autosoe_child.zip` | Tema hijo (8,8 MB, 658 ficheros) | Back office → Diseño → Tema y logotipo → *Añadir nuevo tema* |
| `img-importtools.zip` | Imágenes de contenido, logos de marca y logotipos | Descomprimir en `<raíz>/img/` |
| `modules/leoproductsearch/translations/es.php` | Traducción del buscador | `<raíz>/modules/leoproductsearch/translations/` |
| `02-ajustes-tras-importar.sql` | Correcciones obligatorias tras el volcado | phpMyAdmin |
| `03-opcional-precios-prueba.sql` | Qué hacer con los precios generados | phpMyAdmin |
| `backups/importtools-completo-*.sql.gz` | **Volcado de la base de datos** (696 KB comprimido, 8,3 MB) | phpMyAdmin / cPanel |

> El volcado **no viaja dentro del paquete**: contiene hashes de contraseñas de empleados y
> datos de clientes, así que vive en `backups/`, que está fuera del control de versiones.

## 2. Orden de instalación

### 2.1 Base de datos

1. phpMyAdmin → selecciona la base de datos de la tienda.
2. **Importa** `importtools-completo-*.sql.gz`. El volcado trae `DROP TABLE IF EXISTS`, así
   que reemplaza el contenido anterior.
3. Ejecuta **`02-ajustes-tras-importar.sql`**. Es obligatorio: corrige el dominio (el volcado
   viene con `localhost:8080`), activa HTTPS y **vacía la caché de CSS de Elementor**.
4. Decide sobre **`03-opcional-precios-prueba.sql`** (ver §4).

Restauración ya probada: importé este mismo volcado en una base limpia y quedó con
**3.036 productos**, 6.072 filas de `category_product`, 3.036 de stock, 7 marcas,
6.072 características, los 17 contenidos de Leo Elements con `JSON_VALID = 1`, el menú de
7 secciones y es-CO activo.

### 2.2 Ficheros

1. Sube y descomprime **`img-importtools.zip`** en `<raíz>/img/`. Debe quedar:
   - `img/it/` — 135 ficheros (fondos de marca, iconos, tira de medios de pago)
   - `img/m/3.jpg` … `9.jpg` — logotipos de las marcas
   - `img/logo-importtools-white.png`, `logo-importtools-dark.png`
2. Copia `es.php` a `modules/leoproductsearch/translations/`.
3. Instala el tema hijo: Diseño → Tema y logotipo → *Añadir nuevo tema* → subir
   `vt_autosoe_child.zip` → **Usar este tema**.

> ⚠️ El tema padre **`vt_autosoe` debe seguir instalado**. El hijo lo necesita.

### 2.3 Caché

1. Parámetros avanzados → Rendimiento → **Borrar la caché**.
2. Por SSH o Administrador de archivos, vacía `var/cache/`.
3. Borra `modules/leoelements/gencode/LeoGenCode_*.html`.
4. Si el hosting tiene **LiteSpeed Cache**, púrgalo también.

## 3. Comprobaciones después de subir

| # | Qué mirar | Resultado esperado |
|---|---|---|
| 1 | Portada | Carga en < 1 s, sin avisos amarillos |
| 2 | Menú | `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO` |
| 3 | Pasar el ratón por CATEGORIAS | Panel blanco con las 15 categorías en 3 columnas, **solo al pasar el ratón** |
| 4 | `/2-catalogo` | «Hay 3036 productos» |
| 5 | `/17-herramientas-electricas` | Filtros: Disponibilidad · Línea · Marca · Precio · Sublínea |
| 6 | `/brands` | Las 7 marcas, con logo las 4 propias |
| 7 | Engranaje lateral derecho | Abre el panel de personalización de Leo |
| 8 | Diseño → Leo Elements | Los 17 contenidos abren en el editor |
| 9 | `/content/4-quienes-somos` | Datos de la empresa y mapa |
| 10 | Buscar «cdn.shopify.com» en el código fuente | **0 resultados** |

## 4. Precios de prueba — decisión pendiente

Los 3.036 productos se cargaron con **precios generados** para poder ver la tienda
funcionando. Están marcados con `supplier_reference = 'PRECIO-PRUEBA'`.

**No abrir la tienda al público sin resolver esto.** `03-opcional-precios-prueba.sql` trae
las dos salidas: ocultar los productos, o dejarlos como catálogo a precio 0 con
«consultar precio». Y la receta para cargar los precios reales por referencia.

## 5. Lo que este paquete NO trae

- **Fotos de producto.** `psjy_image` tiene 0 filas: los 3.036 productos salen con el
  marcador de «sin imagen». Es el pendiente que más pesa.
- **Fotos de la empresa.** Los fondos de `img/it/` son degradados de marca provisionales:
  quitan el enfoque automotriz del demo, pero no son fotografías.
- **Transportistas y tarifas de envío reales.** Siguen los 4 de ejemplo.
- **Pasarela de pago.** Se cotiza aparte.
- **Datos demo residuales**: 2 clientes, 5 pedidos, 5 carritos, 2 proveedores.

## 6. Ajustes del servidor a confirmar

- [ ] PHP **8.5** en el selector de cPanel, con `curl`, `dom`, `gd`, `intl`, `mbstring`,
      `zip`, `json`.
- [ ] `memory_limit = 512M`, `max_execution_time` ≥ 120, `max_input_vars` ≥ 5000
      (Leo Elements guarda formularios muy grandes).
- [ ] SSL activo y renovación automática.
- [ ] `.env` y `.htaccess` en la raíz. **Ojo:** al comprimir desde cPanel hay que activar
      «mostrar ficheros ocultos»; si falta `.env` el sitio da HTTP 500 y si falta
      `.htaccess` todas las URL amigables dan 404.
- [ ] Rotar la contraseña de la base de datos: ha circulado en copias locales.

## 7. Si algo sale mal

1. Restaura el respaldo de JetBackup.
2. El contenido original del tema está intacto en
   `themes/vt_autosoe/samples/leoelements.xml` (9,3 MB) por si hay que rehacer la portada.
3. En `backups/` hay volcados intermedios con fecha y hora para volver a un punto anterior.
