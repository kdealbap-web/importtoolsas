# Fase 3 — Personalización de la plantilla AutoSoe

> **Criterio rector:** quitar el contenido genérico del demo y sustituirlo por contenido
> funcional de Importtools, **conservando la estructura** del tema para que un diseñador de
> PrestaShop pueda seguir editando desde el back office (Elementor / módulos Leo) sin tocar
> código.
>
> Se trabaja en el **entorno local espejo** (`~/importtools` en WSL2). Ver `local-dev/README.md`.
> Última actualización: 27/07/2026.

## Leyenda
- ✅ **Hecho y verificado** en el HTML servido
- 🔵 **Puedo hacerlo ya** (no depende de nadie)
- 🟠 **Necesita una decisión** de Kevin o del cliente
- 🔴 **Bloqueado por contenido** del cliente (imágenes, textos, precios)

---

## 0. Estado actual — lo que ya quedó aplicado

| Elemento | Estado |
|---|---|
| Tema hijo `vt_autosoe_child` activo, `custom.css` cargando sobre el padre | ✅ |
| **Home 3** como portada (perfil Leo Elements) → `elementor-9,10,11,12` | ✅ |
| **Shop Layout 01** (`category3410524107`) → `category__style--1` | ✅ |
| **Product style 01** (`plist3413072022`) → `plist-df` en home y categoría | ✅ |
| Idioma es-CO, moneda COP sin decimales, IVA 19/5/0 %, Colombia, `America/Bogota` | ✅ |
| 15 categorías del cliente con URL amigable | ✅ |
| Assets del tema hijo reparados (`img`, `fonts`, `js` del padre) | ✅ |
| Logo real de Importtools en header (Home 3) y footer | ✅ |
| Menú vertical "All Departments": 8 enlaces muertos → 15 categorías reales | ✅ |

### Por qué faltaban el logo y los iconos del menú (para no repetirlo)
Al activar el tema hijo, `_THEME_DIR_` pasó a apuntar a `vt_autosoe_child`, que solo tenía
`assets/css/`. Todo lo que la plantilla pide como `{$tpl_uri}/assets/img/...` devolvía **403**:
el logo del header, los iconos del megamenú y las **fuentes de iconos**. Se resolvió copiando
`assets/img`, `assets/fonts` y `assets/js` del padre al hijo.

> ⚠️ Al actualizar el tema padre hay que **volver a sincronizar esas tres carpetas** al hijo.

---

## 1. Inventario de contenido genérico pendiente

Medido sobre la instalación local el 27/07/2026:

| Rastro del demo | Cantidad | Dónde |
|---|---|---|
| Imágenes en **`cdn.shopify.com`** (CDN del autor del tema) | **145 URLs** en 22 filas | contenido Elementor (43 en la home) |
| Enlaces muertos `href="#"` | 60 | contenido Elementor de la home |
| Textos *Lorem / Ipsum* | 10 | secciones de la home |
| Submenú "Home 1…Home 6" → `home-1.html`…`home-6.html` | 6 items | megamenú grupo 1 |
| "FAQs" del menú apunta al CMS **6, que no existe** | 1 item | megamenú grupo 1 |
| Entradas de blog demo (leoblog) | 6 | `psjy_leoblog_blog` |
| Slides demo (leoslideshow) | 11 | `psjy_leoslideshow_slides` |
| Fabricantes demo (*Studio Design*, *Graphic Corner*) | 2 | catálogo |
| Proveedores demo | 2 | catálogo |
| Páginas CMS en inglés (*Delivery, Legal Notice, Terms, About us, Secure payment*) | 5 | CMS |
| Marcas del filtro Make/Model/Year de autopartes (`leopartsfilter`) | 10 | módulo |
| Clientes / pedidos / carritos demo | 2 / 5 / 5 | datos |
| Productos | **0** | catálogo por cargar |

> **El punto más serio son las 145 URLs de Shopify:** además de ser rastro genérico, son una
> **dependencia externa**. Si el autor del tema borra o bloquea esas imágenes, la portada se
> rompe en producción. Hay que descargarlas y servirlas localmente, o sustituirlas por
> material de Importtools.

---

## 2. Plan por bloques

Cada bloque es independiente y verificable. El orden propuesto va de "invisible pero
necesario" a "cosmético".

### Bloque A — Catálogo con precios de prueba 🟠
El archivo `docs/Productos activos import.xlsx` trae **3.043 productos** con `codigo`,
`descripcio`, `linea`, `sublinea`, `grupo`. **No trae precios, stock ni imágenes.**

- 🔵 A1. Clasificar cada producto en una de las 15 categorías **por su descripción**
  (criterio acordado: dónde se engloba mejor), no por la columna `linea`. Salida revisable:
  `db/import/clasificacion-productos.csv`.
- 🟠 A2. **Precios de prueba**: criterio a definir (ver la pregunta abierta abajo).
- 🔵 A3. Importar con referencia = `codigo`, nombre = `descripcio`, IVA 19 % (grupo 53).
- 🔵 A4. Cargar las 8 marcas que venían como `linea` (PROTO, IRWIN, VITALI, WEILER, VIRUTEX,
  GRAINGER, NORDIC, DALO MARKER) como **Fabricantes**, no como categorías. Logos en
  `docs/brands_logos.rar`.
- 🔵 A5. **Script de reversión para producción**: dejar preparado un script que desactive los
  productos o ponga los precios a 0 antes de publicar, para que los precios de prueba no
  salgan a la calle.

### Bloque B — Imágenes propias y fin de la dependencia externa 🔴
- 🔵 B1. Descargar las 145 imágenes del CDN de Shopify y servirlas desde `/img/cms/` local,
  reescribiendo las URLs en el contenido Elementor. **Deja la portada idéntica pero sin
  depender de terceros** — se puede hacer ya, sin esperar al cliente.
- 🔴 B2. Sustituir banners y slides por material de Importtools (el cliente debe enviarlo).
- 🔵 B3. Los 11 slides demo del slider: quitarlos o reemplazarlos.

### Bloque C — Textos y páginas 🔴
- 🔵 C1. Eliminar los 10 *Lorem/Ipsum* de la home.
- 🟠 C2. Traducir/reescribir las 5 páginas CMS al español con datos reales de la empresa
  (NIT, dirección, política de envíos, términos, pagos).
- 🔵 C3. Arreglar el menú: quitar "Home 1…Home 6", corregir "FAQs" (CMS inexistente),
  decidir si "Blog" y "Our stores" se quedan.
- 🔵 C4. `PS_SHOP_EMAIL` está en `admin_dev@importtoolsas.com` → poner el correo real.

### Bloque D — Marca visual 🔴
- ✅ D1. Logo en header y footer.
- 🔵 D2. Favicon (ya hay variantes en `theme-autosoe/brand/`).
- 🟠 D3. Colores de marca: `custom.css` ya define `--it-red: #E2211C` y `--it-navy: #1F3864`.
  Falta aplicarlos a header, botones, precios y badges (se hace en `custom.css`, no en el padre).
- 🔴 D4. Tipografías, si el cliente tiene manual de marca.
- 🔵 D5. Quitar la regla temporal de prueba (`body { border-top: 4px solid var(--it-red) }`).

### Bloque E — Módulos que no aplican al negocio 🟠
- 🟠 E1. **`leopartsfilter`** (filtro Marca/Modelo/Año de autopartes) con 10 marcas de coche.
  Para una ferretería industrial probablemente no aplica → decidir si se desinstala o se
  reutiliza (p. ej. filtro por marca de herramienta).
- 🟠 E2. `leoblog` con 6 entradas demo: ¿el cliente va a publicar blog? Si no, ocultar.
- 🔵 E3. Borrar fabricantes/proveedores/clientes/pedidos demo antes de producción.

### Bloque F — Cierre 🔵
- 🔵 F1. Pruebas responsive y de checkout.
- 🔵 F2. SEO básico: metadatos de las 15 categorías, sitemap, URLs amigables (ya activas).
- 🔵 F3. Sincronizar el tema hijo al repo con `local-dev/sync-from-wsl.sh` y commitear.

---

## 3. Preguntas abiertas

1. **Precios de prueba (Bloque A2):** ¿cómo los genero? Opciones: valor fijo para todos,
   rango aleatorio por categoría, o un rango que Kevin indique. Debe ser reproducible y
   fácil de revertir.
2. **Filtro de autopartes (E1):** ¿se desinstala o se reutiliza?
3. **Blog (E2):** ¿el cliente lo va a usar?
4. **Páginas CMS (C2):** ¿quién redacta los textos legales y de envíos?

## 4. Cómo se preserva el trabajo del diseñador

- Todo el CSS propio va en `themes/vt_autosoe_child/assets/css/custom.css` (prioridad 1000,
  cargado por convención del core en `FrontController.php:976`). Nunca se edita el tema padre.
- Los cambios de portada se hacen sobre los **contenidos de Leo Elements** (Elementor), que
  siguen siendo editables desde *Diseño → Leo Elements*.
- Los estilos de listado y layout se cambian desde el perfil de Leo Elements, no en plantillas.
  **Ojo:** ver la advertencia de los tres sitios que definen el estilo de listado en `CLAUDE.md` §5.
- El menú se administra desde el módulo **Leo Bootstrap Menu** (grupo 1 horizontal, grupo 2
  vertical "All Departments"); los items de categoría se actualizan solos al añadir categorías.
- ⚠️ El tema hijo **también** necesita una copia de `themes/vt_autosoe/modules/`: los módulos
  Leo resuelven plantillas con `_PS_THEME_DIR_`, no con la herencia de PrestaShop. Hay que
  volver a copiarla cada vez que se actualice el tema padre. Detalle en la bitácora del 28/07.

---

## 5. Bitácora de sesiones

- **28/07/2026** — menú del cliente, logo, datos reales de la empresa, mapa, marcas como
  fabricantes y filtros por línea/sublínea/grupo, y limpieza del rastro de la plantilla
  genérica: ver **[`fase3-bitacora-2026-07-28.md`](fase3-bitacora-2026-07-28.md)**.
  Cierra los bloques **C** (textos y menú) y **E1** (`leopartsfilter` retirado del home),
  y resuelve las preguntas abiertas 2 y 4.
