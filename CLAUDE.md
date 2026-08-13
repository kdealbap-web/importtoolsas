# CLAUDE.md — Tienda en línea Importtools Latam S.A.S

> Documento de arranque del proyecto para trabajar con **Claude Code**.
> Contiene: aceptación del cliente, arquitectura recomendada, plan de montaje de la
> plantilla AutoSoe sobre PrestaShop, hosting + dominio + gestión CMS, y análisis
> costo-beneficio con recomendaciones vigentes (julio 2026).

---

## 1. Estado del proyecto

- **Estado:** ✅ APROBADO — aval del cliente recibido para iniciar.
- **Fecha de aval:** 23 de julio de 2026.
- **Cotización base:** COT-2026-001 — $2.800.000 COP (todo incluido).
- **Plazo comprometido:** 20 días desde el anticipo + entrega de contenidos.

### Aceptación del cliente
- **Cliente:** Importtools Latam S.A.S — NIT: `______________`
- **Proveedor:** Ing. Kevin De Alba (persona natural) — C.C.: `______________`
- **Alcance aceptado:** diseño + desarrollo + puesta en línea + mantenimiento inicial.
- **Forma de pago aceptada:** 40% anticipo / 30% avance / 30% entrega.
- **Soporte:** 4 h/mes gratis los primeros 6 meses; luego $45.000 COP/hora.

---

## 2. Objetivo del proyecto

Montar una **tienda en línea (e-commerce / catálogo)** para la venta de herramientas,
repuestos y productos de importación, personalizando la plantilla comercial
**AutoSoe – Car & Auto Parts** sobre **PrestaShop**, con panel autogestionable (CMS),
hosting y dominio propios.

---

## 3. Stack y arquitectura recomendada

| Capa | Tecnología recomendada | Notas |
|---|---|---|
| CMS / e-commerce | **PrestaShop 9.1** (o 9.0 estable) | La plantilla AutoSoe es nativa de PrestaShop 8.x–9.1 |
| Constructor visual | **Elementor Page Builder** (incluido en el theme) | Autogestión de páginas por el cliente |
| Plantilla | **AutoSoe – Car & Auto Parts** (apollotheme) | Licencia Regular USD 56 — incluida en la cotización |
| Lenguaje | **PHP 8.5** (recomendado para 9.1) | 8.1–8.5 soportados; evitar 8.6+ |
| Base de datos | **MariaDB 10.6+** o **MySQL 8.0+** | Mínimo MySQL 5.7 / MariaDB 10.2 |
| Servidor web | **Nginx 1.24+** o **Apache 2.4+** | Nginx da mejor rendimiento y menor RAM |
| Sistema operativo | **Ubuntu Server 24.04 LTS** (Linux) | PrestaShop funciona mejor en Unix/Linux |
| Cache / rendimiento | OPcache + Redis (opcional) | Redis mejora sesiones y cache en catálogos grandes |
| TLS | **Let's Encrypt** (SSL gratuito) | Renovación automática con certbot |

> **Fuente oficial de requisitos:** PrestaShop DevDocs 9 — recomienda PHP 8.5, Apache 2.4+
> o Nginx, MySQL 5.7+/MariaDB 10.2+ (versión reciente), y `memory_limit ≥ 512M`.

### Diagrama lógico

```
Usuario ── HTTPS ──> [ Nginx/Apache + PHP-FPM 8.5 ]
                          │
                          ├── PrestaShop 9.1 (AutoSoe + Elementor)
                          ├── MariaDB / MySQL
                          ├── Redis (cache/sesiones, opcional)
                          └── Almacenamiento de imágenes/productos
                     [ Certbot / Let's Encrypt ]  <── SSL
                     [ Backups automáticos ] ──> almacenamiento externo
```

---

## 4. Opciones de hosting — análisis costo-beneficio (Colombia, 2026)

> ⚠️ **Valores de referencia** del mercado colombiano. **Verificar precios exactos al
> momento de la compra**, ya que cambian y pueden estar en USD.

| Opción | Precio ref. anual | Pros | Contras | Recomendado para |
|---|---|---|---|---|
| **Hosting compartido optimizado PrestaShop** (ej. proveedor nacional/Hostinger Business) | ~$300.000–$600.000 COP | Bajo costo, cPanel, fácil, soporte en español | Recursos limitados, PrestaShop pesa; puede ir lento con catálogo grande | Catálogo pequeño / tráfico bajo |
| **VPS gestionado / Cloud pequeño** (DigitalOcean, Vultr, Hostinger VPS, AWS Lightsail) — 2 vCPU / 2–4 GB RAM | ~$500.000–$1.100.000 COP | Cumple `memory_limit 512M` con holgura, más rápido, escalable, control total | Requiere administración (o panel tipo CloudPanel/Plesk) | **★ Recomendado para este proyecto** |
| **Hosting administrado premium PrestaShop** | ~$1.200.000+ COP | Optimizado, respaldos y actualizaciones gestionadas | Mayor costo | Cuando el cliente no quiere administrar nada |

**Recomendación:** un **VPS pequeño (2 vCPU / 4 GB RAM, SSD NVMe)** con panel gratuito
(CloudPanel) ofrece el mejor equilibrio costo/rendimiento para PrestaShop y encaja en el
presupuesto del primer año incluido en la cotización. Si el catálogo y el tráfico inicial
son bajos, un **hosting compartido optimizado** reduce costos y libera margen.

### ✅ CONTRATADO — Latinoamérica Hosting Colombia, plan H2

| Recurso | H2 |
|---|---|
| Estado | **Activo** — registrado 23/07/2026, renueva 23/07/2027 |
| Precio | **$170.000 COP/año** (precio fijo al renovar; hosting excluido de IVA) |
| Disco | 30 GB SSD NVMe |
| Transferencia | 600 GB/mes |
| CPU / RAM | **2 vCPU / 4 GB** garantizados (CloudLinux OS+) |
| Dominios | 2 permitidos · IPv4 + IPv6 |
| Correos / BD | 20 cuentas / 5 bases de datos MySQL |
| Stack | LiteSpeed Enterprise + LSCache, PHP hasta 8.5, cPanel, Softaculous Premium (PrestaShop 1-clic) |
| Extras | SSL gratis, Imunify360, JetBackup (respaldos remotos), MailChannels, MagicSPAM, ~200.000 inodos |

**Dominio:** `www.importtoolsas.com` — registrado en el mismo proveedor, activo.

**Facturación:** $170.000 COP anual · medios de pago: tarjeta, PSE, efectivo.

**Puntos a vigilar durante la operación (hosting compartido):**
- [ ] Fijar `memory_limit` de PHP en **512 MB** desde cPanel (PHP Selector). Confirmar si CloudLinux lo permite en H2; si no, escalar a soporte o considerar H3.
- [ ] Usar **PHP 8.5** (recomendado para PrestaShop 9.1).
- [ ] Vigilar **inodos (~200.000)**: PrestaShop genera varias miniaturas por producto; catálogo grande puede acercarse al límite → si pasa, upgrade a H3 (mismo proveedor, solo se paga la diferencia).
- [ ] No hay Redis en compartido → apoyarse en **LSCache + caché de página de PrestaShop**.
- [ ] Si se usa Cloudflare: SSL en modo **Full (strict)** o dejar Cloudflare solo en DNS al inicio para no chocar con el SSL del hosting.

### Dominio
Precios en Latinoamérica Hosting (mismo proveedor del hosting, cómodo para facturar junto):
- **`.com`** → $52.000 COP/año
- **`.com.co`** → $65.000 COP/año
- **`.co`** → $119.000 COP/año

- Alternativa: Cloudflare Registrar (al costo) para `.com`; **`.com.co` no suele estar en Cloudflare** — comprarlo en el proveedor local.
- **Incluir dominio + hosting del primer año dentro del valor cotizado.**

---

## 5. Plan de montaje (fases y comandos)

> Estas fases están alineadas con los **hitos de pago 40/30/30**.

### Fase 0 — Preparación (tras 40% de anticipo)
- [ ] Confirmar NIT, datos de facturación y contacto del cliente.
- [ ] Recibir del cliente: **logo**, **paleta de marca**, **catálogo (Excel/CSV)** e **imágenes**.
- [x] Comprar dominio (`importtoolsas.com`) y contratar hosting (**LAH H2**).
- [ ] Adquirir licencia AutoSoe (apollotheme / ThemeForest, USD 56).

### Fase 1 — Configuración del hosting (cPanel)
- [ ] Verificar que el dominio resuelve y emitir/activar **SSL** (Let's Encrypt en cPanel).
- [ ] En **PHP Selector**: seleccionar **PHP 8.5** y activar extensiones (curl, dom, gd, intl, mbstring, zip, json…).
- [ ] Ajustar límites de PHP: `memory_limit = 512M`, `upload_max_filesize`, `max_execution_time`, `max_input_vars`.
- [ ] Crear **base de datos MySQL** y usuario dedicado (desde cPanel → MySQL Databases).
- [ ] Activar **LSCache** y confirmar backups (JetBackup) funcionando.

### Fase 2 — Instalación de PrestaShop + tema
- [ ] Instalar **PrestaShop 9.1** con **Softaculous Premium** (1-clic) o subida manual por Administrador de archivos.
- [ ] Instalar y activar la plantilla **AutoSoe** + módulos (Parts Filter, Elementor, etc.).
- [ ] Importar datos demo del theme como base de estructura.

### Fase 3 — Personalización (contra 30% de avance)

> Se trabaja en el **entorno local espejo** (Docker sobre WSL2). Ver `local-dev/README.md`.

- [x] **Tema hijo `vt_autosoe_child` activo** (padre: `vt_autosoe`), con `custom.css`
      cargando por encima del padre — verificado en el CSS compilado que sirve el servidor.
      Todo cambio de CSS va ahí, nunca en el tema padre.
- [x] **Estilos elegidos por el cliente aplicados** (27/07/2026):

  | Elección | Clave de Leo Elements | Clase que renderiza |
  |---|---|---|
  | **Home 3** | perfil `Home 3` (id 3) | `elementor-9,10,11,12` |
  | **Shop Layout 01** | `category3410524107` ("Category Default") | `category__style--1` |
  | **Product style 01** | `plist3413072022` | `plist-df` |

  > ⚠️ **El estilo de listado se define en TRES sitios y hay que cambiar los tres**, o no
  > surte efecto:
  > 1. `psjy_leoelements_product_list_shop.active` — es lo que muestra el back office, pero
  >    **no** es lo que se renderiza.
  > 2. `psjy_leoelements_profiles.params` del perfil activo → `productlist_layout` (+ `_mobile`,
  >    `_tablet`) y `manufacture_layout`, `search_layout`, `pricedrop_layout`,
  >    `newproduct_layout`, `bestsales_layout`.
  > 3. `psjy_leoelements_category.params.product_list` del layout de categoría → **pisa al
  >    perfil en las páginas de categoría** (`leoelements.php:649`).
  >
  > Cada categoría puede además sobreescribirlo con `psjy_category.leoe_layout`. Editar el JSON
  > de `params` con PHP dentro del contenedor (el batch mode de mariadb corrompe el JSON), luego
  > vaciar `var/cache/` y verificar en el HTML: `plist-*`, `category__style--*`, `elementor-N`.

- [x] **15 categorías del cliente creadas** bajo Home, con URL amigable sin acentos
      (`herramientas-de-medicion`, `tornilleria`, `herramientas-electricas`…).
      La categoría raíz se renombró `Home` → **`Catálogo`** (`/2-catalogo`, sigue siendo `id 2`,
      así que `PS_HOME_CATEGORY` y los módulos que la referencian no se rompen).
- [x] **Los 3.036 productos se asignaron también a la categoría raíz `Catálogo` (id 2)**.
      Sin esto `/2-catalogo` salía vacío y los carruseles del home decían
      *"No products at this time"*.

- [x] ⚠️ **El tema hijo necesita una copia de `themes/vt_autosoe/modules/`.**
      Los módulos de Leo resuelven sus plantillas con la constante `_PS_THEME_DIR_`
      (= carpeta del tema **activo**, o sea el hijo) en lugar de usar la herencia de
      plantillas de PrestaShop — 33 ficheros lo hacen, p. ej.
      `LeoProductCarousel.php` busca
      `_PS_THEME_DIR_ . 'modules/leoelements/views/templates/front/products/{plist_key}.tpl'`.
      Si el hijo no tiene esa carpeta, el `smarty->fetch()` falla y **el widget no pinta nada**
      (sin error visible). Se copiaron los 352 ficheros (2,8 MB) a
      `themes/vt_autosoe_child/modules/`. **Al actualizar el tema padre hay que volver a copiarla.**

- [x] **Menú principal del cliente** (grupo 1 de `btmegamenu`):
      `INICIO · CATEGORIAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO`.
      `CATEGORIAS` es un mega desplegable a 3 columnas con las 15 categorías
      (`sub_with='submenu'`, `is_group=1`, `colums=3` + 15 items hijos de tipo `category`).

- [x] **Menú vertical "All Departments" retirado.** Se quitó **su widget** del header 03
      (`LeoBootstrapmenu` con `source=ce7aeaae…` en `leoelements_contents_lang` id 10).
      ⚠️ **No desactivar `btmegamenu_group.active` para ocultarlo**: `cacheGroupsByFields()`
      es una caché estática compartida y al marcar el grupo 2 como inactivo **desaparece
      también el menú principal** (ambos widgets muestran
      *"The Group of LeoBoostrapMenu is not active"*). Comprobado con prueba A/B.

- [x] **Logo unificado y proporcional.** El widget del logo (`LeoGenCode` id `595db89`)
      traía `{if $page.page_name == 'index'}` → logo blanco / `{else}` → `{$shop.logo}`
      (el de letras azules). Como Leo Elements **cachea el HTML compilado por widget**
      (`modules/leoelements/gencode/LeoGenCode_595db89.html`), la rama que se compilaba
      primero se servía en todas las páginas → el logo cambiaba sin lógica aparente.
      Se dejó una sola variante (logo blanco) y se redimensionó el PNG de 1600×280 a 457×80.
      El tamaño se fija en `custom.css` con un selector de especificidad (0,2,1) porque
      `themes/vt_autosoe/modules/leoelements/views/css/positions/headerposition*.css`
      impone `.header__logo img{max-width:160px}` **después** del `custom.css` del hijo.
      Resultado: cabecera 228×40 px, pie 160×28 px.

- [x] **Datos reales de la empresa aplicados** (28/07/2026): razón social
      `Import Tools Latam S.A.S`, NIT `901.353.663-6`, dirección
      `Carrera Cordialidad Km 2.5 #66`, Galapa (Atlántico), tel/WhatsApp `+57 314 593 4962`,
      correo `ventas@importtoolslatam.com`, horarios Lun-Vie 8:00–17:00 y Sáb 8:00–12:00,
      Facebook e Instagram reales. Se creó la **tienda física** (`psjy_store`) con
      coordenadas `10.9268546, -74.8593972` y horarios.
- [x] **Mapa e icono de ubicación**: iframe de **OpenStreetMap** (sin API key) en
      *Quiénes somos* y *Envíos*, más un icono `fa-location-dot` en la barra de cabecera y
      en el pie que enlaza a `https://maps.app.goo.gl/bYJ6yfUHMxjv3xQ38`.
- [x] **Marcas (columna `grupo` del catálogo) como fabricantes**, con logo y en el orden
      pedido: Nikatto (1.381), Dragon Tools (27), Proweld (6), Ventum (19); además
      Proto (11), Irwin (4) y Grainger (1) sin logo. 1.587 productos quedan sin marca
      (tornillería / importados / varios, que no son marcas). Carrusel "Elige tu marca" en
      el home con los logos locales (`/img/m/{id}.jpg`) enlazando a `/brand/{id}-{slug}`.
- [x] **Filtros del catálogo ajustados a la estructura del cliente**: `línea` y `sublínea`
      como **características** de PrestaShop (88 y 128 valores, 6.072 filas en
      `feature_product`) y `grupo` como **marca**. Plantilla de `ps_facetedsearch`
      "Filtros Importtools" sobre `Catálogo` + las 15 categorías con
      Subcategorías, Marca, Precio, Disponibilidad, Línea y Sublínea.
      Verificado en el front: `/17-herramientas-electricas` muestra
      *Disponibilidad · Línea · Marca · Precio · Sublínea*.
- [x] **Rastro de la plantilla genérica eliminado del home, cabecera y pie**: 0 apariciones
      de `Autosoe`, `demo@demo.com`, `+1(800) 123 456`, `All Departments`, `4.9 Google Reviews`,
      `Shop Now`, `Discover Now`, `Add Your Vehicle`, `192.168.1.80`, `localhost/prestashop`.
      También se quitaron las afirmaciones falsas heredadas del demo
      (*30 Year of Service*, *100% Customer satisfaction rate*, *Up to 20% off*,
      *Save up 50% off*, *fast Free shipping $99*) y la **cuenta atrás caducada**
      (`LeoCountDown`, terminaba el 2025-06-04) de una oferta inexistente.
- [x] **Filtro de vehículos `leopartsfilter` retirado del home**: es específico de repuestos
      de automóvil (Marca/Modelo/Año) y estaba en inglés. El módulo queda instalado.
- [x] **Menú definitivo con desplegables solo al pasar el mouse**:
      `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO`.
      ⚠️ El panel se abre/cierra según la clase que elige `genFrontTree()`:
      `is_group=1` → `dropdown-mega`, que **no tiene ninguna regla CSS en el tema** y por eso
      queda siempre abierto; `is_group=0` → `dropdown-menu`, que el tema oculta con
      `opacity:0;visibility:hidden` y abre con `.leo-megamenu .dropdown:hover`.
      **Usar siempre `is_group=0`.**
- [x] **Sección MARCAS** en el menú con las 7 marcas como hijos, en el orden del cliente.
- [x] **Cero dependencias externas de imagen**: las 214 URLs de `cdn.shopify.com` se
      eliminaron. Los fondos de banner con fotos de coches se sustituyeron por degradados de
      marca y el resto se descargó a **`/img/it/`** (136 ficheros; copia versionada en
      `deploy/img/it/`).
      ⚠️ **Al desplegar hay que subir `deploy/img/it/` a `<docroot>/img/it/`.**
- [x] **Código postal 082001** en configuración y en la tienda física.
- [x] **Colores de la interfaz cerrados con el cliente (10/08/2026): rojo de marca +
      el negro del tema. El azul marino se retira de la interfaz.**
      El botón «Agregar a mi cotización» estaba en producción con
      `background: var(--itc-navy)` = **#1F3864**, y ese azul se usaba además en
      **11 declaraciones** más: los `h2` del panel de cotización y de *Pagos
      autorizados*, las etiquetas y el texto de los campos, los enlaces
      (`.itcot-link`, `.itcot-ayuda a`), el borde de foco del textarea, el aviso
      flotante, la referencia de las tarjetas sin foto (`.itsf__ref`), el panel de
      la cuenta y los `h3` de *Quiénes somos* y *Quiero ser cliente*.
      Todo eso pasa a **`#000`**, que **no es un negro inventado**: es el valor que
      AutoSoe declara en `--headings-color`, `--link-color` y
      `--product-name-color`. Comprobado leyendo el CSS que sirve el servidor, no
      suponiéndolo.
      Se hizo **por variable, no regla por regla**: `--itc-boton`, `--itc-navy`,
      `--itc-tinta`, `--itq-tinta` y un token nuevo `--it-negro` en `:root`.
      El token `--it-navy` se retiró del CSS (no lo usaba nada) para que no vuelva
      a colarse. La banda degradada de la cabecera de cotización se pasó también a
      negros (`#1a1a1a → #000`): era la única superficie azul que quedaba y habría
      cantado más que antes.

> ⚠️ **Caché de CSS de Elementor.** `psjy_leoelements_meta` guarda el CSS generado con
> `name = '_elementor_css_id_lang_N'`. Vaciar `var/cache/`, `assets/cache/` y
> `modules/leoelements/gencode/` **no lo invalida**: el front seguía sirviendo URLs viejas con
> la base de datos ya limpia. Tras cualquier cambio de contenido de Leo Elements hay que hacer
> `DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';`
- [x] **Idioma es-CO** (por defecto, fecha `d/m/Y`), **moneda COP** (sin decimales),
      **país/zona Colombia**, zona horaria `America/Bogota`, **IVA 19 % / 5 % / 0 %**
      (las 52 reglas de estados de EE.UU. quedaron desactivadas).
- [ ] Zonas y tarifas de envío (pendiente de datos del cliente — ver §10).
- [ ] Cargar catálogo inicial desde el archivo del cliente (import CSV de PrestaShop).
- [ ] Configurar formularios de contacto / captación de leads.

### Fase 3-bis — Blindaje de la entrega (29/07/2026)

> Detalle completo en **`docs/fase3-bitacora-2026-07-29-blindaje.md`**.

- [x] **Panel del engranaje del front apagado** (`LEOELEMENTS_PANEL_TOOL = 0`).
      Verificado antes de decidir: `paneltool.js` solo hace `setCookie` (0 ajax, 0 post) y un
      anónimo **no puede escribir** (huella MD5 de los 34 contenidos idéntica antes y después
      de invocar `action_element`). No era una vulnerabilidad, pero exponía el personalizador
      al público y permitía **cargar las portadas de muestra** (automoción, en inglés) con
      pérdida del menú. **No se pierde nada**: los mismos ajustes están en
      `AdminLeoElementsProfiles` con **151 campos**.
- [x] **Un solo diseño.** Borrados los perfiles Leo 1, 2, 4 y 5. Los 12 contenidos de muestra
      **no se borraron**: se sobreescribieron con copia de los limpios equivalentes
      (`c=9→1,5,13` · `c=10→2,6,14` · `c=11→3,7,15,16` · `c=12→4,8`).
      ⚠️ **Dos razones para no borrar**: la prueba empírica mostró que el contenido **9 SÍ
      está en uso** (`elementor-9` se renderiza en la portada), y el perfil guarda catálogos
      JSON (`product_list_data`, `category_list_data`, `product_detail_data`) que quedarían
      colgando. Resultado: 0 contenido genérico, 0 menú vertical, 0 JSON roto.
- [x] **Perfil `Cliente Importtools` (id 5)**: 302 roles de pestaña + 48 de módulo.
      Configurar módulos sí, instalar/desinstalar no.
      ⚠️ PrestaShop 9 usa **1.160 roles** (`ROLE_MOD_TAB_*` y `ROLE_MOD_MODULE_*`), no columnas
      view/add/edit/delete. Y **comprueba la cadena de pestañas padre**: hubo que dar READ a 20
      contenedoras (`IMPROVE`, `SELL`, `AdminParentModulesSf`…) y al listado de módulos, porque
      las páginas de configuración viven bajo *Mejorar → Módulos*.
      ⚠️ `Profile::getProfileAccesses()` y la capa HTTP **no coinciden** para pestañas de
      módulo: validar por HTTP, no solo por el modelo.
- [x] **Validado con sesión HTTP real**: Productos 253 KB, Categorías 172 KB, CMS 135 KB,
      Pedidos 128 KB, menú Leo 90 KB, slideshow 208 KB, dashboard 41 KB.
      403 en Tema, Módulos, Empleados, Rendimiento, SQL, Transportistas, Impuestos.
      **0 errores CRITICAL.**
- [x] **Paquete de importación** en `deploy/paquete/` con volcado probado en base limpia.

#### Tres trampas del entorno, con su síntoma

| Síntoma | Causa | Nota |
|---|---|---|
| El back office pide login una y otra vez tras entrar bien | `prestashop/php.ini` (traído de producción) fija `session.save_path = /var/cpanel/php/sessions/ea-php85`, que no existe en local | **En producción es correcto.** Original guardado en `deploy/paquete/config/php.ini.produccion` |
| 500 al entrar al panel, `Date must be a string` en `HelperCalendar.php:135` | Empleado con `stats_date_from`/`stats_date_to` en `NULL` | Fallo mío al crear el empleado por `INSERT` directo |
| 500 intermitentes, `SmartyException: unable to create directory var/cache/...` | Ejecutar PHP **como root** en el contenedor deja `var/cache/prod` sin escritura para `www-data` | Limpiar la caché **desde el contenedor como www-data** |

Y dos comportamientos del core que **no** son fallos: el bucle a
`/security/compromised?uri=...` (PS 9 exige token por URL en el back office) y la interstitial
«Token no válido» de algunas páginas de módulo.

### Fase 3-ter — Catálogo sin precios, cotización por WhatsApp y las dos páginas de la maqueta (01/08/2026)

> Plan y estado al día en **`deploy/paquete/historico/11-PLAN-FASE-II.md`**.

- [x] **Modo catálogo definitivo** (`PS_CATALOG_MODE=1`, `..._WITH_PRICES=0`) — ver §10.
- [x] **Módulo propio `itcotizacion`**: lista en `localStorage`, formulario de prospecto
      (nombre, tipo de documento, documento, teléfono, correo), guardado en
      `psjy_it_cotizacion` para el CRM, exportación a CSV con BOM y salto a
      `https://wa.me/573145934962` con el mensaje ya escrito.
      **Probado de punta a punta en navegador real** sobre la página real: lista vacía,
      documento inválido, envío correcto, vaciado de la lista, contador a 0 y confirmación.
      El servidor **relee de la base** el nombre y la referencia de cada producto; no se fía
      del navegador.
- [x] ⚠️ **El botón faltaba en la ficha de producto.** Estaba en las 38 plantillas de
      listado, pero el tema mete *todo* el bloque de compra dentro de
      `{if !$configuration.is_catalog}`, así que en modo catálogo la ficha dejaba un
      `<div class="product-add-to-cart">` **vacío**: quien abría un producto no tenía cómo
      pedirlo. Corregido con
      `themes/vt_autosoe_child/templates/catalog/_partials/product-add-to-cart.tpl`
      (cantidad + botón), con `{include file='parent:…'}` de respaldo si algún día se apaga
      el modo catálogo — comprobado apagándolo y encendiéndolo.
- [x] **Quiénes somos y Quiero ser cliente** rehechas desde la maqueta del cliente, en
      **HTML y CSS, no como imagen**: el texto queda nítido a cualquier zoom (pidió «puro
      vector»), es traducible e indexable. Originales en `deploy/paquete/contenido/`.
      Las seis fotos se recortaron de la propia maqueta.
- [x] 💡 **El tema ya traía Font Awesome 5 Pro Light y nadie lo usaba.** AutoSoe empaqueta
      `themes/vt_autosoe/assets/fonts/fa-light-300.woff2` (427 KB, juego Pro completo) y
      declara la familia `"Font Awesome Light"`, **pero no define la clase `.fal`** que la
      usaría: solo hay `.fa`/`.fas` (Free Solid, desde `modules/leoelements/…`) y `.far`.
      Se declaró `.it-ico` en `custom.css` y quedan disponibles los **1.649** glifos con el
      trazo fino que pedía la maqueta, sin añadir ni un fichero.
      ⚠️ Los iconos de **marca** (WhatsApp, Facebook, Instagram) **no existen** en Light ni
      en Regular — solo en Brands: usan `.it-ico--marca`. En Light salen como caja vacía.
      Comprobado renderizando los cuatro pesos en Chromium, no leyendo el CSS.
- [x] **Fichas sin foto**: el marcador del núcleo se limita a 300 px y se oculta la
      miniatura cuando está sola. La ficha es 450 px más corta.
- [x] El contenido 17 de Leo (dos tarjetas de degradado) se colaba al final de *Quiénes
      somos* por `displayWrapperBottom` — el hook de `layout-both-columns.tpl:117`, no por
      `displayHeaderCategory`, que sí está protegido por `{if $page.page_name == 'category'}`.
      Oculto solo en esa página; en las categorías se queda.

> 🔧 **Chromium headless no baja de ~500 px de ventana.** Con `--window-size=390` maqueta a
> 500 y **recorta** el PNG: se ven textos y tarjetas cortados y parece un desbordamiento que
> no existe. Un `<iframe>` sí acepta el ancho real. `local-dev/captura.sh` lo resuelve solo
> por debajo de 520 px, y `local-dev/_medir-desbordamiento.html` mide `scrollWidth` frente a
> `innerWidth` y lista los elementos que se salen, en vez de deducirlo de una captura.
> Medido así: las dos páginas nuevas no se desbordan a 390 px.

### Fase 3-quater — Cabecera, móvil y medios de pago reales (03/08/2026)

> Plan de subida en **`deploy/paquete/13-PLAN-SUBIDA-20260803.md`**.
> Herramienta nueva: **`local-dev/inspeccionar.sh`** + `_inspeccionar.html`, que miden
> cajas y estilos calculados dentro de un iframe del ancho real y ordenan la salida
> poniendo primero los elementos visibles. Casi todo lo de esta ronda salió de medir,
> no de leer CSS: tres de los cinco fallos eran **reglas nuestras que nunca pintaron
> nada** y por eso el cliente seguía viendo lo mismo.

- [x] ⚠️ **Las tarjetas del home no se igualaban porque se igualaba la caja
      equivocada.** El ajuste del 01/08 estiraba la *columna*; la tarjeta que se ve es
      la sección interna, que lleva el fondo y el borde redondeado. Medido a 1440 px:
      columnas de 360 px con secciones de **300 / 360 / 300** (`min-height:300px` es
      solo un mínimo, y la del medio tiene un titular de tres líneas). El tema ya
      resuelve el primer tramo con
      `.full__height>.elementor-column-wrap>.elementor-widget-wrap{height:100%}`;
      faltaba el último salto. Una sola regla arregla las tres filas de tarjetas.
- [x] ⚠️ **El solape sobre el banner venía de una sección VACÍA.** `c7864ac` es una
      sección heredada de la demo con `margin-top:-118px; margin-bottom:90px`: allí
      vivían las tarjetas, que en esta tienda son la sección hermana `9867cfe`. Medido:
      slideshow 280..805 y la fila de tarjetas arrancando en **778**, o sea 27 px por
      encima, justo sobre los puntos del carrusel. `margin-top:0` en todos los anchos
      (antes solo por debajo de 991 px).
- [x] ⚠️ **El menú móvil que estilábamos no era el que se usa.** Había un bloque
      entero sobre `.leo-top-menu.collapse.show` — el panel de Bootstrap. Con
      `show_cavas = 1` la `<nav>` sale con `enable-canvas` y `leobootstrapmenu.js:64`
      **clona** el menú dentro de `<section class="off-canvas-nav-megamenu">` colgada
      de `<body>`; el `.leo-top-menu` original se queda oculto en la cabecera
      (**0 elementos visibles**). El cajón real: 234 px, blanco, `left:-234px` y
      `translateX(234px)` al abrir — de ahí que el botón estuviera a la derecha y el
      menú entrara por la izquierda. Ahora se estila **ese** cajón: entra por la
      derecha, 300 px. El velo, el cierre al tocar fuera y un botón «Cerrar» ya
      traducido los trae el módulo; solo se le añadió el cierre con Escape.
      ⚠️ **Aparcarlo con `right:-300px` fue un error que hubo que deshacer:** lo que
      sobresale por la derecha SÍ cuenta para el ancho desplazable, y toda la tienda
      quedaba con **292 px de scroll horizontal** en móvil incluso con el menú cerrado
      (`scrollWidth` 682 con `innerWidth` 390). Por la izquierda no cuenta. Se
      mantiene `left:-300px` y se lleva al abrir con `translateX(100vw)`.
- [x] **La hamburguesa doble.** El tema apaga el carácter `☰` del HTML con
      `font-size:0` y dibuja el suyo con `::before{content:"\f0c9"}`. Nuestra regla de
      julio le devolvía `font-size:1.35rem` y se pintaban **los dos glifos** encimados.
- [x] **El «fondo blanco random» bajo el icono era nuestro.** El
      `padding-right:62px` que le reservaba sitio a la hamburguesa estrechaba la
      sección de Elementor que pinta el negro, y asomaba el blanco de `#header` en una
      franja de 62×157 px.
- [x] **Cabecera móvil: de 335 px a ~105 px.** Antes: barra superior de 159 px (cuatro
      líneas apiladas) + logo + fila del buscador + franja de contacto repetida. Ahora
      dos filas: utilidades en una línea (teléfono y *Cómo llegar*, con iconos por CSS
      porque los `.elementor-icon-box-icon` del tema vienen vacíos) y logo + lupa +
      corazón + cotización. Horarios, dirección completa y correo se quedan solo en el
      pie, que ya los trae todos.
      ⚠️ Dos trampas de especificidad, las dos comprobadas midiendo:
      **(a)** Elementor pone `width:100%` a las columnas por debajo de 767 px; con las
      dos al 100 % dentro de un flex, la que puede encogerse caía a **w=0** y su texto
      se pintaba ENCIMA de la otra columna, letra a letra. Hace falta `width:auto`.
      **(b)** el CSS de Elementor va en un `<style>` **en línea** en el `<head>` —o
      sea, después de la hoja externa— y usa selectores de (0,4,0), así que
      `body .elementor-N .elementor-element.elementor-element-X` (0,3,1) **pierde**.
      Es la razón por la que la regla del 01/08 que ponía el degradado del pie en la
      banda de suscripción nunca se vio: seguía sirviendo `banner-med-a.jpg`.
- [x] **El buscador móvil se abría en lo alto de la pantalla** porque `.box__search`
      es `position:fixed; top:0`. Se ancla a `.header-top` con `top:100%` y cae justo
      debajo del icono que lo abre. Solo aplica por debajo de **576 px**, que es donde
      `custom.js` del tema quita el id `#leo_search_block_top` y aparece la lupa.
- [x] **Solo se veían 2 de las 4 marcas** en móvil (`slides_to_show_mobile: 2` en un
      carrusel de 4). En móvil pasa a rejilla 2×2 por CSS, sin destruir slick, para no
      depender de cuándo se inicializa. `width` y `transform` de `.slick-track` y
      `.slick-slide` son estilos **en línea**, así que ahí `!important` es la única
      forma. Y con `infinite:1` slick **clona** diapositivas: sin ocultar
      `.slick-cloned` la rejilla mostraba marcas repetidas.
      ⚠️ Con `display:grid` quedaba la primera celda vacía y las cuatro corridas un
      sitio; con flex, lo que está a `display:none` simplemente no existe.
      Los logos del cliente son rectángulos opacos de proporciones distintas y el
      círculo blanco de 120 px que espera el tema no se ve nunca porque el JPG lo tapa:
      se les dio una placa blanca común de 88 px.
- [x] **Acceso a la cotización con la figura del carrito original del tema.** El tema
      define esa figura en `#_desktop_cart` y la repite en `.header__button--wishlist`
      y `#leo_block_top`: caja 24×24, glifo de 22 px en *Font Awesome Light*, blanco
      sobre la cabecera, contador de 20×20 en círculo rojo a `top:-6px/right:-12px`.
      El acceso a la cotización no tenía **ninguna**: heredaba `color:#000` sobre fondo
      oscuro (solo se veía al pasar el ratón, que sí tiene color propio) y quedaba
      **debajo** del corazón, porque los dos son `<div>` de bloque en el mismo widget
      (x=1336 y=75 / y=99). Ahora los tres van en línea, iguales. En móvil se muestra
      quitándole `elementor-hidden-tablet/phone` — la regla del núcleo es (0,3,0) y
      **no** lleva `!important`.
- [x] **Dirección y teléfono de la cabecera eran invisibles**: los `<a>` salían en
      negro sobre fondo oscuro. Solo se leía el bloque de horarios, que es un `<span>`
      y hereda el color claro.
- [x] **«No blog at this time.» en inglés en la portada.** La sección *Consejos de uso
      y mantenimiento* monta un LeoBlog sin entradas y el módulo pinta su estado vacío.
      Se oculta la sección completa mientras esté vacía con `:has()`: vuelve sola el
      día que se publique la primera entrada, sin tener que acordarse de deshacer nada.

#### El corazón, contra base de datos

Decisión del cliente: **la lista de deseos va en base de datos, con sesión iniciada.**
Es justo lo que ya hace `leofeature` (`psjy_leofeature_wishlist` +
`psjy_leofeature_wishlist_product`, atadas a `id_customer`), y el módulo **ya marcaba**
con la clase `added` el corazón de cada producto guardado. Lo que faltaba era el número:

- el marcado es `<span class="ap-total-wishlist"></span>`, **vacío**, y
  `leofeature_wishlist.js` solo lo escribe *después* de añadir o quitar algo: al entrar
  a cualquier página el contador salía en blanco aunque hubiera productos.
- ⚠️ y había un fallo peor: ese script hace
  `parseInt($('.ap-btn-wishlist .ap-total-wishlist').data('wishlist-total'))`. Sin
  `data-wishlist-total` sembrado eso es `parseInt(undefined)` = **NaN**, así que al
  guardar el primer producto el globo mostraba «NaN».

`itcotizacion.php` lo cuenta leyendo la base en cada petición y lo publica con
`Media::addJsDef`; el JS del módulo siembra el texto **y** el atributo.
⚠️ `WishList::getSimpleProductByIdCustomer()` devuelve un array **indexado por
id_wishlist** con los productos dentro: un `count()` a secas contaría listas.
⚠️ Y no vale meter Smarty en el widget del corazón: Leo Elements guarda el HTML ya
compilado de cada `LeoGenCode` en `modules/leoelements/gencode/`, así que el número
quedaría **congelado** en el primero que se compilara.

Probado de punta a punta: cliente de prueba con 3 productos → sesión HTTP real → la
portada trae `itfav = {"logueado":true,"total":3}`. El cliente de prueba y sus filas se
borraron: quedan 1 cliente (el «Anonymous» del RGPD) y 0 listas.

> ⚠️ **Hay que decírselo al cliente:** esa lista **exige cuenta**. A un visitante
> anónimo el módulo le pide entrar, y ese aviso salía en inglés
> (`leofeature.php:1354`, `$this->l('You must be logged in to manage your wishlist')`);
> ahora dice «Entra a tu cuenta para guardar productos en tus favoritos.» en
> `modules/leofeature/translations/es.php`. Como la tienda vende por WhatsApp y no
> empuja a registrarse, el corazón lo usará poca gente. **La cotización, que es el
> camino de venta real, no pide cuenta ninguna.**

#### Medios de pago y foto del pie

- [x] **Solo los tres bancos del cliente.** El pie servía el sprite de la plantilla con
      American Express, Bitcoin, Apple Pay, Discover, Diners, VISA y JCB: ninguno se
      puede usar, la tienda no cobra en línea. Se compuso
      `img/it/pagos-autorizados.png` (482×80) con **Bancolombia, Banco de Bogotá y
      Davivienda** a partir de los PNG que envió el cliente (530×282 los tres), y se
      cambió el fichero del widget `c4b1de6`. Los mismos tres van en la página de
      cotización bajo *Pagos autorizados*, diciendo que el asesor confirma el total y
      se paga por transferencia o consignación.
- [x] **Foto del asesor en la banda del pie**, en vez del degradado provisional
      `banner-med-a.jpg`, con velo oscuro para que el texto se lea.
      ⚠️ El cambio de fichero se acota a los contenidos del pie (4, 8 y 12):
      `banner-med-a.jpg` se usa **además** en el cuerpo del home y en la cabecera de
      las categorías, y la primera prueba en seco encontró **40 coincidencias en 18
      filas**. Cambiarlas todas habría puesto la foto detrás de banners que no tienen
      nada que ver. Script: `deploy/paquete/12-imagenes-del-cliente.php`.

> 🔧 **El círculo del banner no es un fallo.** En las capturas aparece un círculo
> arriba a la derecha del slideshow que parece un spinner atascado. Es
> `div.iview-timer`, el anillo de progreso del propio LeoSlideshow: marca cuánto queda
> para la siguiente diapositiva. Identificado con `document.elementFromPoint()`
> (`local-dev/_punto.html`), no adivinado.

#### Documentos y empaquetado

- **`deploy/paquete/14-PASO-A-PASO-SUBIDA.md`** — el operativo: once pasos con comandos,
  salida esperada, 29 comprobaciones (17 de escritorio, 6 de móvil a 390 px, 4 de back
  office, 2 del corazón), optimización y marcha atrás. Es el que hay que seguir.
  Sus dos pasos nuevos frente a rondas anteriores:
  **§8** confirma con centinelas en el CSS y el JS *servidos* que lo subido se está
  usando de verdad (`translateX(100vw)`, `header__button--cotizar`,
  `off-canvas-button-megamenu`, `itfav`) — la única forma de descartar la trampa de
  `compile_check`; y **§9** separa la optimización probada de la que no lo está.
- **`historico/13-PLAN-SUBIDA-20260803.md`** — qué cambió en esta ronda y por qué.
- **`14a` / `14b` / `14c`** — cachés off al empezar, cachés a producción al terminar y
  abrir la tienda. El último va en fichero aparte a propósito: es el único paso que no
  se deshace sin que alguien lo haya visto.
- `EMPEZAR-AQUI.md` apunta ya al 14 y trae los recuentos del paquete de hoy.

> ⚠️ **`Compress-Archive` de Windows PowerShell 5.1 genera zips inservibles para el
> servidor.** Escribe los nombres de entrada con **barra invertida**
> (`vt_autosoe_child\assets\css\custom.css`), contra la especificación ZIP —apéndice
> 4.4.17.1, exige `/`—. Al extraerlo en Linux o en cPanel no se crean carpetas: sale un
> fichero plano con la barra invertida en el nombre. Pasó al rehacer los cinco zips de
> esta ronda y se detectó **listando las entradas antes de subir nada**.
> Se sustituyó por **`local-dev/empaquetar.py`**, que normaliza a `/` y comprueba que no
> quede ninguna entrada con `\`.
> ⚠️ Y al rehacerlos apareció un segundo fallo: `img-importtools.zip` había pasado de
> **337 a 147 ficheros** porque solo empaquetaba `deploy/img/it/`. Faltaban `img/m/`
> (logotipos de marca) y los logotipos y favicons de la raíz de `img/`, que vivían solo
> en el contenedor. Se trajeron al repo (`deploy/img/m/` y sueltos) y ahora el zip es
> reproducible desde el repo.
> 🧹 **Actualizado el 10/08/2026:** ese zip pasó de **350 a 60 ficheros** (5,9 → 1,7 MB)
> al quitar 110 imágenes de la demo del tema (Home 1, 2, 4 y 5, cuyos perfiles se
> borraron el 29/07) y 179 marcadores «sin imagen» de 40 idiomas que no existen aquí.
> Se midió pidiendo **24 tipos de página** a la tienda en línea y quitando solo lo que
> ninguna referencia; verificado después que no falta nada que producción use.

> 🧹 **Los duplicados del tema se eliminaron (10/08/2026).** Había **tres** sitios con
> ficheros del tema hijo: `theme-autosoe/custom.css` + `custom.js`,
> `theme-autosoe/templates/` y el propio `theme-autosoe/vt_autosoe_child/`. Las copias
> eran idénticas y había que mantenerlas a mano —de ahí los avisos sobre `sync-to-wsl.sh`
> y sobre `publicar-tema.sh`, que publicaba unas y no otras—.
> Ahora **la única fuente del tema es `theme-autosoe/vt_autosoe_child/`**, que es
> exactamente la carpeta de la que `empaquetar.py` construye el zip y la que
> `publicar-tema.sh` empuja al espejo de una sola vez. **No volver a crear copias.**
> `publicar-tema.sh` sigue vaciando las cachés **como `www-data`** (hacerlo como root
> deja `var/cache/prod` sin escritura y el front devuelve 500 con
> `SmartyException: unable to create directory`).


### Fase 3-quinquies — Mejoras pedidas por el cliente (08/08/2026)

> Documento del cliente: `MejorasImportools_docv2.docx`.
> Paso a paso de subida en **`deploy/paquete/18-PASO-A-PASO-20260808.md`**.

- [x] ⚠️ **El módulo de banners no estaba roto: lo rompía el dominio.** El cliente
      reportó que *Leo Slideshow Configuration* «se queda en editing, no actualiza, se
      bloquea». Descartado por medición, en este orden: **no** son permisos (el perfil 5
      tiene `ROLE_MOD_MODULE_LEOSLIDESHOW_UPDATE` en `psjy_module_access`, que es donde
      PS 9 los guarda — **no** en `psjy_access`); **no** es un módulo manipulado (idéntico
      byte a byte al original de ThemeForest, MD5 `3698FC65…`); **no** es la versión free
      (`getPermission()` → `true`). Y el servidor **guarda bien**: probados el grupo, la
      subida de imagen y `slideProcessAjax()`, que responde `{"error":0,…}` y deja el
      título en `psjy_leoslideshow_slides_lang`.
      La causa: `getModuleConfigUrl()` usa `getAdminLink('AdminModules', true)`, que
      devuelve una URL **absoluta** con `PS_SHOP_DOMAIN_SSL` = `www.importtoolsas.com`,
      y **el cliente entra al panel por `importtoolsas.com`, sin `www`**. El `$.ajax` sale
      a otro origen y el navegador lo bloquea.
      ⚠️ **Y es mudo porque `script.js:495` solo define `.done()`, sin `.fail()`**: una
      petición bloqueada no produce ni alerta ni consola, el botón se queda igual. Ese es
      literalmente el síntoma que describió.
      Corregido con `modules-custom/itcotizacion/views/js/arreglo-leoslideshow.js`, que
      pasa el `action` de esos formularios a **ruta relativa** (mismo origen siempre, con
      o sin `www`) y hace visibles los errores. Va por
      `hookActionAdminControllerSetMedia` para **no tocar el módulo de Leo**, que se
      sobrescribe al actualizar el tema. PS 9 sí dispara ese hook en las rutas Symfony
      (`src/PrestaShopBundle/Twig/Component/HeadTag.php:65`).
      **La causa de raíz es tener dos dominios vivos**: hay que redirigir
      `importtoolsas.com` → `www` con un 301 (§7 del paso a paso).
- [x] ⚠️ **El menú del slideshow abría un grupo que no se ve en ninguna página.**
      `LEOSLIDESHOW_GROUP_DE` estaba en 4 («Slide Home 5»). Cruzando el `randkey` de cada
      grupo con el JSON de `leoelements_contents_lang`: solo se usan el **3** (escritorio)
      y el **5** (móvil). Aunque hubiera guardado bien, el cliente no habría visto el
      cambio. Lo corrige y lo comprueba `deploy/paquete/15-arreglo-slideshow.php`.
- [x] **Iconos rojos en la barra de utilidades.** Los cuatro `.elementor-icon` de esa
      barra están **vacíos** (medido: w=0, h=0, 0 visibles), así que se pintan con
      `::before` sobre el texto. La regla de julio vivía dentro de
      `@media (max-width:991px)` y en escritorio no llegaba a aplicarse nunca.
      ⚠️ WhatsApp es icono de **marca**: no existe en Light ni en Regular, solo en Brands.
- [x] **Fuera la franja de contacto bajo el menú** (sección `e23515a`), en todos los
      anchos. Repetía dirección, teléfono y horario que ya están arriba y en el pie.
- [x] **Los círculos rojos del asesor ya llevan icono.** Medido: el círculo es
      `.elementor-icon-box-icon` (48×48, `border-radius:50%`), y el `.elementor-icon` de
      dentro está a 0×0. Los PNG del cliente ya traen el círculo rojo y el glifo blanco,
      así que van de **fondo** cubriéndolo entero y no hay dos rojos peleando.
      Reducidos de 652×652 a 144×144 (24 KB → 8,5 KB).
- [x] **Buscador capitalizado.** Es el **placeholder animado** de `custom.js`, no lo que
      escribe el visitante. Las partículas cortas van en minúscula siguiendo el propio
      ejemplo del cliente, que escribió «Guantes **y** Seguridad Industrial».
- [x] **Botón «Agregar a mi cotización» en negro.** Va por variable
      (`--itc-boton`), no por valor suelto, porque el criterio acordado es de **contraste**:
      hoy cae siempre sobre blanco —comprobado en la ficha, en el listado de categoría y
      en los carruseles del home—, y si algún día se pone sobre fondo oscuro basta
      redefinir la variable en ese contenedor.
- [x] **Proto, Irwin y Grainger fuera del menú MARCAS** (`active = 0` en los items).
      ⚠️ Se desactivan los **items**, nunca `btmegamenu_group.active`: eso tumba el menú
      entero (caché estática compartida). Como el fabricante sigue existiendo —así se
      acordó—, esas tres marcas **siguen saliendo en el filtro lateral y en la ficha** de
      sus 16 productos.
- [x] ⚠️ **La tarjeta «Herramientas de aire» de *Quiénes somos* estaba mal de origen.**
      Usa `cat-aire.jpg`, que **es un ventilador**, pero se rotulaba «Herramientas de
      aire» y enlazaba a `/11-herramientas-de-aire`, que son **compresores, machos NPT y
      pistolas de pintura** (31 productos, ni uno es ventilador). Y ya existía la
      categoría **24 «Ventiladores Industriales»** con 17. Se corrigió el rótulo y el
      enlace; **no se renombró la categoría 11**, que habría dejado los compresores bajo
      un nombre falso y duplicado el de la 24.
- [x] **Fotos reales del cliente en las dos páginas.** Las de antes no le valían. Ahora
      *Quiénes somos* abre con `hero-quienes-somos.jpg` y *Quiero ser cliente* con
      `hero-cliente.jpg`, las dos recortadas de lo que envió el 06/08. Las dos vienen ya
      con degradado a negro por la izquierda, pensadas para llevar texto encima.
- [x] **Banda «Sé nuestro cliente»** en *Quiénes somos*, con el texto nuevo y la misma
      foto del asesor — es lo que pidió al decir «unifícalas».
- [x] **Formulario en el paso 02 de *Quiero ser cliente*.** Botón que lo despliega justo
      debajo, con los **mismos nombres de campo y el mismo destino** que el de la página
      de cotización: una sola vía de entrada que mantener.
      ⚠️ El controlador `enviar` **exige productos**: con la lista vacía responde
      `{ok:false}`. Por eso el formulario cuenta lo que hay, y si está vacía lo dice y
      manda al catálogo en vez de dejar rellenar ocho campos para nada.
- [x] **Flujo de cuenta validado** con sesión HTTP real: registro (deja la sesión
      iniciada), cerrar sesión, volver a entrar, y contraseña equivocada → «Error de
      autenticación.» en español. Las cuentas de prueba se borraron: queda 1 cliente
      (el «Anonymous» del RGPD) y 3 empleados.
- [ ] ⚠️ **«Olvidé mi contraseña» hay que probarlo EN PRODUCCIÓN.** En el espejo el flujo
      encuentra la cuenta y genera el enlace, pero al enviar responde «Se ha producido un
      error al enviar el mensaje»: el contenedor no tiene servidor de correo. La tienda
      usa `PS_MAIL_METHOD = 1` (`mail()` de PHP). **Si el correo no sale en producción,
      nadie puede recuperar su contraseña.**
- [ ] **«Mantener sesión iniciada» no existe en el front de PrestaShop** (solo en el back
      office). La sesión dura `PS_COOKIE_LIFETIME_FO = 480` minutos, 8 h.
      ⚠️ Y `PS_COOKIE_CHECKIP = 1` **invalida la cookie al cambiar la IP**: en móvil, al
      pasar de wifi a datos, la sesión se cae sola. Ponerlo a 0 es lo que de verdad
      resuelve lo que pidió el cliente; es decisión suya, porque es una protección
      (débil) contra el robo de cookie.

#### Panel de la cuenta y auditoría del home (08/08/2026, segunda tanda)

> Plan completo de implementación en **`deploy/paquete/19-PLAN-IMPLEMENTACION-DESDE-CERO.md`**.

- [x] ⚠️ **En escritorio el menú de la cuenta NO se abría con clic ni con teclado.**
      La regla que lo abre vive dentro de un media query de móvil:
      `@media (max-width:991px){ .popup-over.leo_block_top.open .popup-content{opacity:1;visibility:visible} }`.
      Fuera de ahí solo queda `.leo_block_top:hover .popup-content{transform:none}`,
      que no toca la `opacity:0` ni la `visibility:hidden`. Medido poniendo la clase
      `open` a mano y esperando a que acabara la transición de 0,3 s: `op=0 vis=hidden`.
      Con ratón abría **de casualidad**, por la regla genérica `.popup-over:hover`
      que empata en especificidad (0,3,0) y gana por ir después; con teclado nunca,
      y en tablet grande (>991 px, sin hover) el menú era **inalcanzable**.
      Corregido repitiendo la regla fuera del media query y añadiendo `:focus-within`.
- [x] **Panel rediseñado** (`vt_autosoe_child/modules/blockgrouptop/.../blockgrouptop.tpl`,
      ahora propio del hijo): 300 px, cabecera de identidad con la inicial en el rojo
      de marca, acciones con icono, separadores y «Cerrar sesión» en rojo.
      La **cotización va antes que los favoritos** porque es el camino de venta.
      Sin sesión: dos botones y la nota «Para cotizar no hace falta cuenta».
- [x] **Dos enlaces que no llevaban a ninguna parte**: «Pedidos» apuntaba al
      **carrito** (`/cart?action=show`), que en modo catálogo no existe → ahora va a
      `/order-history`; y «Mi cuenta» salía también sin haber entrado.
- [x] ⚠️ **La fuente del tema es Font Awesome 5, no 6.** `fa-location-dot`,
      `fa-code-compare` y `fa-arrow-right-from-bracket` **no existen**: la clase se
      aplica y no se pinta nada, y desde el CSS no hay forma de notarlo. Comprobado
      midiendo el ancho del glifo renderizado (0 px). Se usan `fa-map-marker-alt`,
      `fa-balance-scale` y `fa-sign-out-alt`.
      🔧 Herramienta: `local-dev/_ver-menu.html` mide el ancho de cualquier lista de
      candidatos y dice cuáles existen.
- [x] **Contadores a cero ocultos.** Los tres números del panel los escriben scripts
      distintos: unos dejan el hueco vacío y otros ponen «0», así que con CSS solo se
      podía ocultar la mitad. `custom.js` los marca a todos con `--cero`.
- [x] 🔧 **`local-dev/ver-menu.sh` + `_ver-menu.html`**: abren el panel y pueden
      hacerlo **con la sesión iniciada** (el login va por `fetch` antes de montar el
      iframe; como es el mismo origen, la cookie sirve). Sin esto no había forma de
      ver el menú del cliente logueado en Chromium headless.
      ⚠️ Y abre el `.leo_block_top` **visible**: la página trae varios y
      `querySelector` devolvía uno oculto.
      ⚠️ Abrir y medir no pueden ir en el mismo tick: el panel tiene
      `transition:.3s`, así que medir justo después de poner la clase devuelve
      `opacity:0` y parece que no abre.
- [x] ⚠️ **Tres scripts de depuración sueltos en el docroot** (`_inv.php`, `_q.php`,
      `_sn.php`), que cargaban `config.inc.php` y escribían en
      `leoelements_contents_lang`, accesibles por URL y sin autenticación. Borrados
      del espejo. ✅ **Comprobado en producción el 09/08: los tres devuelven 404.**
      No hay nada que hacer ahí.
- [x] **Auditoría del home**, por orden de peso: las 16 «Imagen no disponible» de una
      sola pantalla; el hero, que monta sus textos por capas con JavaScript y deja
      una banda oscura de ~525 px hasta que termina (el contenido sí está en el HTML,
      comprobado); la etiqueta «Nuevo» en **todos** los productos, que así no informa
      de nada; y los nombres en mayúsculas y muy largos en la rejilla. Detalle y qué
      hacer con cada uno en §10 del plan 19.

#### Catálogo sin fotos: la tarjeta se adapta (08/08/2026, tercera tanda)

- [x] **Estrategia acordada con el cliente**: si el producto **no tiene foto**, no se
      pinta zona de imagen — la tarjeta muestra la **referencia** (el dato con el que
      un ferretero pide) y la marca. Si **sí la tiene**, la rejilla de siempre con la
      imagen entera. Antes salían **16 «Imagen no disponible» en una sola pantalla**.
      **No hay que hacer nada el día que lleguen las fotos**: cada producto pasa al
      modo con imagen en cuanto el cliente le sube una, uno a uno.
- [x] ⚠️ **La plantilla del listado NO es la del núcleo.** Estuve editando
      `catalog/_partials/miniatures/product.tpl` y no surtía ningún efecto: 0
      apariciones de sus clases en el HTML servido. La que pinta categorías, buscador
      y carruseles es la de Leo, **`plist3413072022.tpl`** («Product style 01», la que
      eligió el cliente), en
      `vt_autosoe_child/modules/leoelements/views/templates/front/products/`.
      Se editaron **las dos**, por si algún día se cambia el estilo de listado.
- [x] ⚠️ **`publicar-tema.sh` no publicaba las plantillas del tema hijo.** Solo
      copiaba `theme-autosoe/templates/`, y las plantillas propias viven en **tres**
      sitios distintos del repo. Resultado: se editaban, se ejecutaba el script y el
      espejo seguía sirviendo la versión vieja — la misma trampa de los dos
      `custom.css`. Corregido con `publicar_arbol()` para los tres árboles.
- [x] ⚠️ **Las tarjetas con y sin foto tienen que medir lo mismo.** Medido: con foto
      ~330 px de alto, con referencia 132 → las filas quedaban escalonadas y parecía
      un error de maquetación. La caja de referencia lleva `aspect-ratio: 1/1`, la
      misma que la foto, así la rejilla es uniforme desde el primer día y lo sigue
      siendo cuando todas tengan imagen.
- [x] **Las fotos se muestran con `object-fit: contain`**, no `cover`: en herramienta
      el recorte se come justo las puntas y los mangos, que es por donde se reconoce
      la pieza.

- [x] ⚠️ **La PRIMERA diapositiva de la portada estaba VACÍA.** Auditadas las 11
      contando sus capas de texto: la **6** —la primera del grupo 3, o sea la primera
      que ve el visitante en escritorio— tenía **0 capas**. Sin capas no hay titular,
      ni texto, ni botón: solo el fondo. Uno de cada dos visitantes aterrizaba en una
      banda oscura vacía y esperaba 9 s a que entrara la segunda, que sí comunica.
      Es la única vacía de las 11. Se **desactiva** (reversible) en vez de inventarle
      un mensaje al cliente; él puede diseñarla desde el panel, que ya funciona.
      🔧 Esto explica, junto con lo del lago, las «bandas en blanco» que yo venía
      atribuyendo a que el JavaScript aún no había pintado las capas.
- [x] ⚠️ **`captura.sh` e `inspeccionar.sh` mentían en móvil.** LeoSlideshow elige
      **en el servidor**, por user-agent, si sirve el grupo de escritorio (1920×700)
      o el de móvil (460×460), y solo renderiza **uno**. Como el iframe pedía la
      página con el user-agent de Chromium de escritorio, el servidor devolvía el
      slideshow grande y el iframe lo encogía a 390 px → 142 px de alto con el texto
      al 20 %. Concluí que «el hero móvil está ilegible» y **era falso**: en un
      teléfono real se sirve el grupo móvil. Comprobado pidiendo la misma URL con los
      dos user-agent: `iview-group-…-3` frente a `iview-group-…-5`.
      Las dos herramientas mandan ya user-agent de iPhone por debajo de 520 px.
      **Misma clase de error que el 404 de las fotos: la herramienta, no la tienda.**
- [x] **Hero móvil sin media banda en blanco.** El contenedor móvil es cuadrado
      (390×390) y las imágenes de banner son apaisadas, así que la foto cubría solo
      la franja de arriba y el resto quedaba **en blanco**, con el botón flotando.
      Se le da al `.iview` el mismo tono oscuro y se lee como un único panel.
      👉 Lo definitivo es del cliente: subir las imágenes de «Slide Mobile» en
      **formato cuadrado (460×460)** desde el panel.
- [x] ⚠️ **El hero de la portada seguía usando la foto de la demo.** La diapositiva 1
      del grupo 3 apuntaba a `sample_slider_1.png`: una foto de archivo de **un lago
      con montañas y un muelle**. Y se veía — el carrusel alterna cada 5 s, así que uno
      de cada dos visitantes aterrizaba en un lago con el titular «TORNILLERÍA Y
      HERRAMIENTA MANUAL» encima. La imagen buena (`/img/it/slide-1.jpg`, el degradado
      azul de marca) estaba preparada desde julio y nunca se asignó.
      Lo corrige `deploy/paquete/22-hero-imagen-demo.sql`, que barre además las otras
      diapositivas: había más heredando `sample_slider_2` y `_3`. Verificado: **0**.
      🔧 Lo dejé pasar dos veces antes de verlo: en dos capturas salió cielo azul y
      montañas en el hero y lo atribuí a un artefacto de renderizado. No lo era.

> ⚠️ **CORRECCIÓN DEL 09/08/2026 — las dos entradas de arriba valen SOLO para el
> espejo.** Medidas contra la tienda en línea, **en producción no pasa ninguna de las
> dos**: la portada ya sirve `/img/it/slide-1.jpg` y `slide-2.jpg`, y la primera
> diapositiva **no está vacía** (7 capas, titular «Herramienta profesional para tu
> taller»). El espejo y producción **habían divergido en `psjy_leoslideshow_slides`**.
> Consecuencia práctica: el `UPDATE … WHERE id_leoslideshow_slides = 6` que llevaba el
> script 22 **habría borrado del carrusel una diapositiva que funciona**, sin ruido
> ninguno. Ya está corregido: decide **por datos** (desactiva la que no tenga capas,
> sea cual sea su id) y en producción afecta a 0 filas. Probado de ida y vuelta en el
> espejo. **Lección: antes de ejecutar en producción un script que lleve un id sacado
> del espejo, comprobar ese id contra producción.**

> ⚠️ **`Tools::generateHtaccess()` ESCRIBE EL DOMINIO dentro del `.htaccess`.** Cada
> regla de imagen de producto va precedida de
> `RewriteCond %{HTTP_HOST} ^www.importtoolsas.com$`. Si la petición llega con otro
> host, la reescritura no ocurre y **la foto devuelve 404 aunque el fichero esté
> perfectamente en disco**.
> Lo detecté porque las capturas salían con las imágenes rotas: `captura.sh` cambia
> el dominio a `web` y la condición dejaba de casar. **Pero la consecuencia en
> producción es real y seria: con el `.htaccess` generado para `www`, quien entre por
> `importtoolsas.com` sin www verá TODAS las fotos de producto rotas.** Es un motivo
> más para cerrar el 301 a un solo dominio. Para el espejo:
> `local-dev/htaccess-dos-dominios.sh`.

> ⚠️ **El 302 del front hace creer que lo de los dos dominios ya está resuelto, y no lo
> está** (medido en producción el 09/08). `https://importtoolsas.com/` responde 302 hacia
> `www`, sí — pero ese redirect lo hace **PrestaShop desde PHP**, no el servidor, así que
> **solo cubre el front-office**. Comprobado pidiendo cuatro URL por el dominio sin `www`:
> la portada y una categoría redirigen; **`/img/it/slide-1.jpg` devuelve 200 sin redirigir
> y `/panel-4h5o/` carga el back office entero sin `www`**. Es decir, la condición que
> rompe el AJAX de los módulos Leo **sigue viva justo donde el cliente trabaja**. Sin la
> regla de `.htaccess` (301 en el servidor) no está cerrado. Ver
> `deploy/paquete/23-PASO-A-PASO-20260809.md` §8.

> 🔧 **Constante de PS 9: es `_PS_PRODUCT_IMG_DIR_`, no `_PS_PROD_IMG_DIR_`.** La
> segunda no existe y da «Undefined constant» — un fatal que en PHP CLI puede salir
> como `exit 255` **sin ningún mensaje** si `display_errors` no llega a tiempo. Un
> `register_shutdown_function` con `error_get_last()` lo hace visible siempre.

> 🔧 **El `#` de un selector rompe `interactuar.sh`.** Al pasar `c=#itqs-abrir-datos` el
> `#` abre el fragmento de la URL y el parámetro llega **vacío**, así que el clic nunca
> se hace y la captura sale igual que sin pulsar — parece que el desplegable no funciona.
> Usar un selector por clase, o codificar el `#` como `%23`.

### Fase 3-sexies — Subida a producción por FTPS (11/08/2026)

> Aplicado **directamente en producción** por FTPS explícito, con respaldo en el servidor
> (`*.bak-20260811b`), subida atómica (`STOR` a temporal + `rename`) y marcha atrás
> automática si la verificación fallaba. Runbook: `deploy/paquete/24-RUNBOOK-20260810.html`.

- [x] ⚠️ **El 301 a un solo dominio NO basta ponerlo en el docroot.** Se aplicó en
      `public_html/.htaccess` y la verificación dio 301 en la portada, una categoría y una
      imagen, pero **302 relativo en `/panel-4h5o/`** — la única URL que importaba. El
      script revirtió solo.
      Causa: **mod_rewrite es por directorio y no hereda.** Si un `.htaccess` hijo declara
      `RewriteEngine`, **sustituye entero** el juego de reglas del padre (salvo
      `RewriteOptions Inherit`). `panel-4h5o/.htaccess` es el estándar de Symfony y trae su
      `RewriteEngine On`, así que el back office seguía cargando **sin `www`** — el origen
      exacto que bloquea el AJAX de los módulos Leo.
      Las tres carpetas del docroot con reglas propias: `panel-4h5o` (3.623 B),
      `admin-api` (3.807 B) y `tools` (233 B).
      Solución: el bloque va **en los dos** ficheros, y con **`%{REQUEST_URI}`** en lugar de
      `$1` — en contexto de subcarpeta la ruta que casa es relativa a esa carpeta.
      Reproducido antes en un Apache de usar y tirar con el `.htaccess` real: sin la regla en
      el hijo, 200; con ella, 301 correcto incluso con query string.
      ⚠️ Y el guardián de idempotencia **no puede buscar `R=301`**: el `.htaccess` de Symfony
      ya trae uno (`RewriteRule ^index\.php… [R=301,L]`). Hay que buscar la condición propia.
- [x] **`LEOSLIDESHOW_GROUP_DE` estaba en 1, no en 4.** El grupo 1 («Slide Home 1») es de la
      demo y no se renderiza en ninguna página: el cliente **guardaba bien y no veía cambios**.
      Determinado **midiendo producción**, no el espejo: pidiendo la portada con user-agent de
      escritorio y de iPhone, el HTML devuelve `iview-group-…-3` y `iview-group-…-5`
      respectivamente. Los grupos vivos son el **3** (escritorio) y el **5** (móvil).
      ⚠️ El bloque B de `25-SIN-TERMINAL.sql` **no lo corrigió y no avisó**: su guardián
      `AND value NOT IN (SELECT …)` se evalúa a `NULL` —no a verdadero— si la subconsulta no
      devuelve filas, así que el `UPDATE` afectó a 0 filas. El `INSERT` del hook sí corrió.
      Corregido a mano con `UPDATE … SET value = '3'`.
- [x] **`25-SIN-TERMINAL.sql`**: los pasos que necesitaban PHP CLI (`17-contenido-cms` y
      `15-arreglo-slideshow`) convertidos a SQL, porque el hosting no da Terminal. Probado
      rompiendo el espejo a propósito y comprobando que el HTML queda **idéntico byte a byte**
      (mismo MD5, 11.610 y 11.840 bytes), idempotente y con marcha atrás.
- [x] ⚠️ **El editor de ficheros de cPanel no puede guardar el `.htaccess`**: el desafío
      anti-bot del hosting (Imunify360, `wsidchk`) intercepta el POST del editor y la petición
      se queda en «verificando». No es un problema de permisos ni del fichero. **Por FTP no
      pasa por ese filtro.**
- [x] **Hero de *Quiénes somos* y *Quiero ser cliente* a ancho completo.** El cliente los veía
      «muy pequeños»: las dos fotos traen el **~40 % izquierdo en negro puro** —están
      recortadas para llevar el texto encima— y estaban metidas en una columna del 58 %, así
      que ese negro caía al lado del texto (sobre fondo también negro) y el motivo real
      quedaba en ~465 px de 1440. Pasadas a **fondo de la banda** con velo degradado:

  | | Antes | Después |
  |---|---|---|
  | Foto (Quiénes somos) | 775 × 338 | **1422 × 550** |
  | Foto (Quiero ser cliente) | 775 × **245** | **1422 × 512** |
  | Motivo visible | ~465 px (33 %) | **~853 px (60 %)** |
  | Móvil | tira de 206 px | **296 px**, recortada a 16/10 |

  Solo CSS: **no toca el HTML**, así que no hay que repetir el import de las páginas CMS.
  `.itqs-banda` ya sangra a todo el viewport (`margin-inline: calc(50% - 50vw)`), así que la
  figura **no** se sangra — eso era lo que en julio estiraba la banda a 920 px.
- [ ] ⚠️ **`admin-api.zip`, 186 MB en el docroot y descargable por cualquiera** (responde
      **206** a una petición con Range). Hay que sacarlo de `public_html`.
- [ ] ⚠️ **`error_log` de 28,8 MB** y creciendo. Leído por la cola: **0 errores fatales**, el
      100 % son `PHP Deprecated` de módulos escritos para PHP viejo (`psshipping/vendor/sentry`
      827 veces en 400 KB, `Cart.php`, `Customer.php`, `leoelements`, `leopartsfilter`). Come
      disco e inodos y entierra los errores de verdad. Se calla con
      `error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT` en el MultiPHP INI Editor.
- [x] **`memory_limit` ya está en 1G** (leído del `.htaccess` y del `.user.ini` de producción),
      con `max_input_vars 10000`, `max_execution_time 300` y `upload_max_filesize 1G`. El
      pendiente de §4 sobre fijarlo en 512 MB queda resuelto y con holgura.

### Fase 3-septies — El icono que la tienda pedía a la LAN del autor del tema (11/08/2026)

> Script: **`deploy/paquete/27-iconos-svg-remotos.sql`** (SQL, va por phpMyAdmin).
> Reproducción y medida: **`local-dev/probar-iconos-svg.sh`**.
> Lo destapó el cliente al entrar a gestionar un grupo de diapositivas y encender el modo
> de depuración: la portada devolvió `Uncaught Exception: file_get_contents_curl failed to
> download http://192.168.1.80/…/phone.svg : (error code 28) Connection timed out`.

- [x] ⚠️ **El fallo no era del gestor de imágenes ni del slideshow: era la portada.** El
      rastro sale de `displayNav2` → `get_builder_content(9,0)` → `Widget_Icon_Box->render()`
      → `Svg_Handler::get_inline_svg()`. Los contenidos que venían con la plantilla guardan
      sus iconos como **URL a `192.168.1.80`**, la máquina de la red local del autor del
      tema, y el módulo los **descarga por HTTP en cada render**
      (`svg-handler.php:166`). Desde el hosting esa IP no existe.
      **22 widgets `icon-box` × 2 idiomas = 44 referencias** en 7 contenidos: los 4 de la
      barra de utilidades de la cabecera (contenidos 1, 5, 9, 13 — teléfono, reloj, chat,
      garaje) y los 2 del pie (4, 8, 12 — teléfono y correo). 5 ficheros distintos.
- [x] ⚠️ **Por qué apareció «al activar el modo de depuración», y por qué llevaba semanas
      ahí.** `classes/Tools.php`, en `file_get_contents_curl()`:
      `if (false === $content && _PS_MODE_DEV_) { throw new Exception(...); }`.
      Con el modo dev **apagado** el curl falla, devuelve `false` y **nadie lanza nada**: la
      página se pinta con el icono vacío y el fallo es **mudo**. Con el modo dev
      **encendido** lanza, `Hook.php:1251` lo reenvía como `CoreException` y no lo recoge
      nadie → **500**. El modo de depuración no causó el fallo: lo **destapó**.
- [x] ⚠️ **El coste medido, que sí era real todo este tiempo: 51,5 s la primera visita.**
      3 s de `fopen` + 5 s de `curl` por icono, 6 iconos por página (4 cabecera + 2 pie).
      Solo no se notaba porque el bloque de la cabecera vive en la **caché de Smarty** y el
      hook casi nunca se ejecuta: la 2ª visita tarda 0,22 s. Pero **cada vez que se vacía la
      caché —y Leo la vacía al guardar el slideshow o el menú— el siguiente visitante lo
      paga entero**. Medido en el espejo: 51,5 s → **2,65 s** tras el arreglo.
- [x] **El arreglo: vaciar `library`, no la URL.** En `Icons_Manager::render_icon()` la
      primera línea es `if (empty($icon['library'])) return false;` → con `library` vacío no
      llega a tocar la red. Y `$has_icon` de `icon-box.php` **no depende de `library`** sino
      de que `selected_icon.value` no esté vacío (`"icon":` no existe en estos widgets: 0
      apariciones), así que **se conserva el objeto `{url, id}`** y el
      `<div class="elementor-icon-box-icon">` se sigue pintando. La URL se pasa además a
      ruta relativa del tema hijo, para que no quede rastro de la LAN y para que, si alguien
      volviera a poner `library:"svg"`, falle **sin** salir a la red.
      💡 `"library":""` **no es un estado inventado**: ya existía en 80 widgets de otros
      contenidos (3, 7, 11, 15, 16). Es el valor nativo del módulo para un icon-box sin icono.
- [x] ⚠️ **Lo que NO se debe hacer es «arreglar la descarga».** Si se hace que el SVG se
      resuelva (apuntándolo al propio dominio, o parcheando `svg-handler.php:131`, cuyo
      `str_replace('child_','',_THEME_NAME_)` no casa con nuestro `vt_autosoe_child`), se
      inlinearían los SVG de la demo **encima** de los iconos que ya pinta nuestro
      `custom.css` → **dos iconos superpuestos**, la misma trampa que la hamburguesa doble
      de julio. Y uno de ellos, `garage-1.svg`, es **un garaje** en la caja que hoy dice
      *Cómo llegar*. Los iconos que se ven los pinta el CSS: `::before` sobre el texto en la
      barra de utilidades (§16.2) y los PNG del cliente de fondo en los círculos del pie
      (§16.3).
- [x] **Verificado que el HTML no cambia**: portada antes y después = **476.262 bytes en
      ambos casos**, y mismos recuentos (42 `elementor-icon-box-icon`, 7 `.elementor-icon`,
      53 `<svg>`, 79 `elementor-9`). Las únicas líneas que difieren son el `time`/token de la
      petición y el `uniqid` que LeoSlideshow genera en cada render.
- [x] **Reproducido y verificado de ida y vuelta en el espejo**: con el arreglo deshecho y
      modo dev encendido sale el mensaje exacto del cliente; con el arreglo puesto, 200 en
      2,5 s **incluso con el modo dev encendido**. El script es idempotente (ejecutado dos
      veces, mismas 4 comprobaciones a 0).
- [ ] ⚠️ **El back office está en 500 y hay que confirmar la causa en el servidor.** Medido
      el 11/08: `/panel-4h5o/` devuelve **500 en 4 de 4 intentos, en 0,3 s y con 0 bytes de
      cuerpo** — o sea un fatal **al arrancar**, no al renderizar (el front sigue en 200
      porque reutiliza la cabecera cacheada). Encaja con que el kernel `dev` de Symfony no
      pueda escribir `var/cache/dev`: esa caché crea **miles** de ficheros y el plan H2 trae
      ~200.000 inodos, con `admin-api.zip` (186 MB) y `error_log` (28,8 MB) todavía en el
      docroot. **No está probado**: hay que mirar el `error_log` (cPanel → Métricas →
      Errores) y el uso de disco/inodos.
      El primer paso es el mismo en cualquier caso: apagar el modo dev y borrar
      `var/cache/dev`.

> 🔧 **OPcache al probar el modo de depuración.** Tras editar `config/defines.inc.php` hay
> que esperar `opcache.revalidate_freq` (2 s en el espejo) o reiniciar PHP, o el servidor
> sigue viendo el valor viejo. La primera pasada de la prueba dio 200 en vez de 500 por
> esto, y parecía que el diagnóstico estaba mal.

### Fase 3-octies — Las 16 fotos del cliente, el hero y tres arreglos de móvil (12/08/2026)

> Paso a paso de subida en **`deploy/paquete/31-PASO-A-PASO-20260812.md`**.
> Scripts: **`29-imagenes-cliente.sql`** (repunta 6 huecos) y **`30-slideshow-timer.sql`**
> (diagnóstico del hero, solo lee).
> Herramienta nueva: **`local-dev/medir.sh`**, que hace lo mismo que `inspeccionar.sh` pero
> devuelve **texto** por stdout (`--dump-dom` + extracción del informe) en vez de un PNG.
> Casi todo lo de esta ronda salió de ahí; leer una captura para enterarse de un `w=0` es
> caro y se presta a interpretar mal.
> ✅ **APLICADO EN PRODUCCIÓN el 12/08/2026**, ya con credenciales: 18 ficheros por FTPS
> (16 imágenes + `custom.css` + `custom.js`), con respaldo doble —local en
> `backups/produccion-20260812/` y `*.bak-20260812` en el servidor—, subida atómica y
> verificación HTTP: **18/18 con 200 y el byte exacto**. El SQL 29 lo ejecutó el cliente en
> phpMyAdmin: 12 filas respaldadas, 10+10+10+10+2+2 afectadas, `json_roto` 0.
> Pruebas para recorrer en incógnito: **`deploy/paquete/33-PRUEBAS-20260812.md`**.
> Subidor: **`deploy/subir-a-produccion-ftps.py`** (sustituye a `subir-imagenes-ftps.py`).

- [x] ⚠️ **`FTP_HOST` va con el nombre del SERVIDOR, no con el del dominio.** Con
      `ftp.importtoolsas.com` el saludo TLS funciona y la verificación del certificado
      falla: `Hostname mismatch`. En compartido, Pure-FTPd presenta el certificado **del
      servidor** — aquí un Let's Encrypt emitido a `host303.latinoamericahosting.com`, leído
      del propio certificado con `local-dev/leer-certificado-ftps.py`, que solo hace el
      saludo TLS y **no envía usuario ni contraseña**.
      Se apunta `FTP_HOST` ahí y se **mantiene la verificación completa**. El atajo —
      desactivar `check_hostname`— deja el tráfico cifrado pero **sin autenticar**, que es
      justo lo que el certificado existe para evitar.
- [x] ⚠️ **Subir el fichero no basta: el CSS/JS COMBINADO no se renueva solo.** Con CCC
      activo la portada no carga `custom.css`, carga
      `themes/vt_autosoe_child/assets/cache/theme-<hash>.css`, y **el hash se calcula sobre
      la LISTA de ficheros, no sobre su contenido**. Medido tras subir: los 18 ficheros
      verificaban al byte y el combinado seguía con **0** apariciones de `data-it-hero`, el
      `#1B3560` retirado y el radio viejo de la hamburguesa. O sea: todo subido, nada
      visible.
      Se resuelve vaciando esa carpeta (`--vaciar-cache` del subidor, que además respalda y
      **restaura solo** si PrestaShop no reconstruyera). Verificado después: el combinado
      trae `data-it-hero` y ya **no** trae `0 0 0 6px`.
      ⚠️ Se vacían solo dos cachés **regenerables**: `assets/cache` y
      `modules/leoelements/gencode`. **`var/cache/` no se toca por FTP**: son miles de
      ficheros y un borrado a medias puede dejar PrestaShop sin arrancar; en esta ronda no
      hizo falta, porque el front ya servía el contenido nuevo.
- [x] **El CSS de Elementor se regenera solo al borrar sus filas.** El PASO 6 del SQL 29
      hace `DELETE … WHERE name LIKE '%elementor_css%'` (5 filas), y la portada volvió a
      servir las URLs nuevas **sin vaciar ninguna caché de ficheros**. Comprobado antes de
      tocar `assets/cache`: `bulto`, `nikatto`, `medicion` y `corte` ya salían, y
      `banner-med-` a 0.
- [ ] ⚠️ **Rotar las credenciales usadas hoy.** Llegaron pegadas dentro de `.env.example`,
      que **sí se versiona**, y además pasaron por el chat. Se movieron a `.env` (ignorado) y
      la plantilla se dejó vacía —comprobado: 0 coincidencias en el árbol versionado y nada
      commiteado, así que no hay historial que reescribir—. Pendiente: borrar y recrear la
      cuenta FTP `leotheme@` y cambiar la clave de SSH.
- [ ] **El SSH todavía no es usable desde este equipo.** La clave se generó **en el
      servidor** (`/home/importto/.ssh/id_rsa_cckey`); la privada está allí. Para usarla hay
      que descargarla de cPanel → *Acceso SSH → Administrar claves SSH* y guardarla **fuera
      del repo**.

- [x] ⚠️ **El anillo del hero no está roto: el grupo tiene UNA sola diapositiva.**
      El cliente reportó que el `iview-timer` rojo con play/pause y el autoavance «se dañó».
      No lo rompió ninguno de nuestros cambios: `iview.js` **no monta** el anillo, ni el
      autoavance, ni los puntos, ni las flechas cuando `iv.defs.total == 1`. Son tres
      guardas del módulo original: `:127` (crea el Raphael), `:199` (lo dibuja) y `:492`
      (`if (iv.options.autoAdvance && iv.defs.total > 1)`).
      Probado con un **A/B en el espejo, mismo código en los dos lados**:
      grupo con 1 activa → `.iview-timer` **0×0, 0 `<svg>`, 0 `<path>`**; grupo con 2 →
      **44×44, 1 `<svg>`, 3 `<path>`**. Y activando la 2ª diapositiva del grupo 3 el anillo
      volvió solo, sin tocar una línea.
      En producción, medido pidiendo la portada el 12/08: el home sirve el grupo **6** con
      **una** aparición de `data-leo_image`, con user-agent de escritorio **y** de iPhone.
      👉 Lo que falta es **una segunda imagen**, y eso es del cliente. El script 30 lo
      diagnostica contra la base que sea, sin traer ids del espejo.
- [x] ⚠️ **`iview-timer` = 0 en el HTML no prueba nada.** Mi primera medición fue contra el
      HTML crudo de producción y concluí que el anillo «no se renderiza». El anillo lo
      **inyecta el JS** (`iview.js:95`), así que en el HTML del servidor nunca aparece. Lo
      que sí era dato del HTML era el recuento de diapositivas.
- [x] **El anillo, en el rojo de marca.** Raphael pinta el arco y el sector con **atributos
      de presentación SVG** (`stroke` / `fill`), y una regla CSS gana a un atributo de
      presentación: se resuelve en `custom.css` §21 sin tocar el módulo ni los parámetros
      del grupo, y vale para cualquier grupo que cree el cliente. Los tres `<path>` salen en
      el orden en que los crea `iview.js:194` (aro de fondo, arco, sector), comprobado
      midiendo: `[0]` 30×30, `[1]` 15×30, `[2]` 0×0. Se pintan el 2 y el 3.
      ⚠️ Al arco **no** se le toca el `fill`: Raphael lo deja en `none` y rellenarlo lo
      convertiría en una tarta.
- [x] ⚠️ **El recorte de altura del hero: la caja ahora sigue a la imagen.**
      `iview.js` da al slider el alto **fijo** del grupo y pinta la foto con
      `background-size:100%` (escalada al ancho, alto libre); al arrancar escala todo con
      `transform:scale(anchoCaja/anchoSlider)`. Si la proporción de la foto coincide con la
      del grupo no hay recorte a **ningún** ancho —medido: a 1440 px caja 1425×520, que es
      700·(1425/1920), y la foto de 1920×700 encaja al pixel—. Si no coincide, sobra o falta
      alto: con el grupo móvil (460×460) y una foto de 1920×700 la imagen ocupaba **137 px de
      los 375** y quedaban **238 px vacíos**, que es la «media banda» que §20 tapaba con un
      color.
      Ahora `custom.js` lee la proporción **real** de la imagen y fija los dos altos (§21).
      Medido: 390 px → caja **137** (antes 375) · 768 px → **275** · 1440 px → 520.
      Se usa la proporción **menor** del grupo (la imagen más alta) porque el grupo tiene un
      solo alto: así no se recorta ninguna, que es lo pedido.
      ⚠️ **`aspect-ratio` no sirve aquí.** El primer intento fue `height:auto` +
      `aspect-ratio` y medido **no encogía**: a 1440 salía 700 en vez de 520. El slider va
      dentro en flujo y su alto de **maquetación** es el del grupo (el `transform` cambia lo
      que se ve, no lo que ocupa), y para una caja con `aspect-ratio` el mínimo automático es
      el del contenido. Hay que poner el alto **en píxeles**.
      🔧 Y de paso: el módulo **no escucha el resize de la ventana** (`iview.js:358` engancha
      un evento propio del contenedor que solo se dispara una vez, desde `startSlider()`),
      así que girar el teléfono dejaba el hero con el alto del arranque. El nuestro sí.
- [x] ⚠️ **De las tres declaraciones de §20, dos no pintaban nada.** `background-size` y
      `background-position` estaban sobre `.iview`, y la imagen de fondo la pone
      `iview.js:475` en **`.iviewSlider`**. Medido: `.iview` con `background-image: none` y
      `.iviewSlider` con la URL. Solo hacía algo el color.
- [x] **La hamburguesa ya no sale recortada.** Estaba pegada a la esquina (`top:0; right:0`)
      con una sola esquina redondeada, para leerse como una pestaña de la barra negra.
      Medido a 360/390/480/768/991: caja 46×40 con `x+w` **exactamente igual al
      `scrollWidth`** en los cinco anchos, o sea dos lados y tres esquinas fuera de pantalla.
      No lo tapaba nada ni lo cortaba ningún `overflow` (se midió `overflow:visible` y
      `transform:none` en el botón y en su contenedor): estaba cortado **por el borde**.
      Ahora 44×33 con `top:4px; right:8px` y `border-radius:8px`. Sigue dentro del viewport,
      que es la condición que evita reabrir el scroll horizontal de julio (verificado:
      `scrollWidth` 375 con `innerWidth` 390).
- [x] **Las marcas, sin placa blanca.** Se retira `background:#fff` + `padding:10px` de
      `.box__truck .item-image`. Era visible de verdad: la tarjeta de debajo es
      `rgb(240,238,250)`, así que la placa se leía como un recuadro blanco alrededor de cada
      logo. Se puede quitar sin que se vea peor porque **los cuatro logotipos traen su propio
      fondo opaco**, comprobado descargándolos de producción y leyendo el píxel (0,0):
      Nikato `#030405`, Dragon Tools `#FDC32D`, Proweld `#FDC32D`, Ventum `#E11F1C`. El
      blanco era 100 % nuestro CSS.
      🔧 Y de paso: `img/m/1.jpg` y `2.jpg` son los logotipos **de la demo de PrestaShop**
      («STUDIO DESIGN» y «GRAPHIC CORNER»). No se muestran —el carrusel usa 3, 4, 5 y 6—,
      pero siguen en disco.
- [x] **Las tarjetas apiladas, con aire.** Medido a 390 px: *Compra por bulto* acababa en
      `y=6492` y *Marca Nikato* empezaba en `y=6492`: **cero píxeles**. La separación la
      daban los `padding` laterales de las columnas, y Elementor los anula al pasarlas a
      `width:100%` por debajo de 767 px. Ahora 20 px.
      ⚠️ Solo en la fila de **dos** (`7c65757`). Aplicarlo también a la de tres dejaba 40 px
      allí frente a 20 aquí, porque esa fila ya se separaba sola; se vio midiendo las dos en
      la misma pasada.

#### Las 16 fotos: el emparejamiento, y por qué seis no se podían sobrescribir

El cliente entregó 16 imágenes con el nombre de su destino. **Ninguna se colocó a ojo**: para
cada hueco se cruzaron tres cosas independientes —el **texto** que el bloque muestra en el
HTML de producción, la **dimensión** del fichero que había, y el **nombre** del cliente— y
coinciden en los 16. El par (imagen, título) de las tarjetas se leyó del DOM servido:
`…/img/it/banner-med-a.jpg" alt=""/> Herramientas de Medición`.

| Hueco | Texto que muestra | Fichero |
|---|---|---|
| tarjeta 450×360 | Esta semana / Tornillería | `banner-a.jpg` |
| tarjeta 450×360 | Todo para el taller | `banner-b.jpg` |
| tarjeta 450×360 | lo más pedido / más vendidos | `banner-c.jpg` |
| panel vertical | Líneas destacadas / Herramienta eléctrica | `banner-ancho.jpg` |
| 6 tarjetas 800×800 | Tornillería · Manuales · Eléctricas · Automotriz · Soldadura · Seguridad | mismo nombre |
| tarjeta 800×800 | Herramientas de Medición | **`medicion.jpg`** (nuevo) |
| tarjeta 800×800 | Herramientas de Corte | **`corte.jpg`** (nuevo) |
| banda del home | Mayoristas / Compra por bulto (botón *Ver tornillería*) | **`bulto.jpg`** (nuevo) |
| banda del home | Marca propia / Marca Nikato | **`nikatto.jpg`** (nuevo) |
| banda de categoría | Nuestro catálogo / más de 3.000 referencias | **`cat-referencias.jpg`** (nuevo) |
| banda de categoría | Atención mayorista / precios por volumen | **`cat-volumen.jpg`** (nuevo) |

- [x] ⚠️ **`banner-med-a.jpg` y `banner-med-b.jpg` los comparten TRES bloques cada uno**, con
      significados distintos: una banda del home, una tarjeta del carrusel de categorías y
      una banda del contenido 17 (las páginas de categoría). Contado sobre el JSON: **11 usos
      cada uno**. Sobrescribir el fichero habría puesto la foto de «Compra por bulto» dentro
      de la tarjeta de «Herramientas de Medición». Es la misma trampa del 03/08 con este
      mismo fichero en el pie (40 coincidencias en 18 filas).
      La salida: en el JSON el hueco se distingue por su **clave** —
      `"background_overlay_image"` para la banda, `"item_image"` para la tarjeta—, así que el
      `REPLACE` se acota por clave y, para el contenido 17, además por id. Verificado:
      `quedan_med_a` 0, `quedan_med_b` 0, `json_roto` 0, y **idempotente** (segunda pasada,
      mismos números).
- [x] ⚠️ **El CSS tapaba esas cinco bandas con degradados azules, así que cambiar el fichero
      no se habría visto.** `custom.css` §3 ponía `background-image:none` en el
      `.elementor-background-overlay`, que es **exactamente donde Elementor guarda la foto**
      de esas secciones, y pintaba un degradado marino en la sección. Medido antes de tocar:
      `b9df906` servía `background-color: rgb(27,53,96)` = `#1B3560`, de esta hoja. Los
      degradados eran relleno provisional mío de agosto («en vez de mis degradados
      provisionales» decía el propio comentario); ya hay fotos, así que se retiran y queda
      solo un color de respaldo.
      🔧 Dos de los cinco selectores **nunca pintaron nada**: `dff2c7b` y `ccce7a0` viven en
      el contenido **17**, que se renderiza como `.elementor-17`, y el selector empezaba por
      `body .elementor-11`.
- [x] **Sin velo añadido.** Se midió la luminancia de cada foto **en la zona donde cae el
      texto blanco**: `bulto` 18,8 · `nikatto` 13,1 · `cat-volumen` 23,6 ·
      `cat-referencias` 27,3 · y 6-13 en la franja del titular del panel vertical. El cliente
      las entregó ya rebajadas para llevar texto encima; añadir velo solo las apagaría.
      Verificado en captura: los cuatro titulares se leen.
- [x] **El panel vertical no había que recomponerlo.** `Herramientas electricas.png` es
      720×1045 (proporción 0,689) y el bloque mide **957×1401** (0,683): el cliente la
      dimensionó contra el bloque real. Antes de medirlo iba a recortarla a 1600×760, que es
      lo que decía el nombre del fichero que sustituye.
- [x] **Los originales del cliente salen de `deploy/img/`.** Esa carpeta es exactamente lo
      que sube al servidor y `empaquetar.py` mete todo lo que hay dentro; los 16 originales
      y el respaldo de lo sobrescrito habrían viajado al hosting. Van a
      `deploy/originales-cliente/20260812/` y a `backups/img-antes-20260812/`.
      `img-importtools.zip` queda en **66 ficheros, 2,9 MB**.

### Fase 4 — Pruebas y entrega (contra 30% final)
- [ ] Pruebas responsive (desktop / tablet / móvil).
- [ ] Revisión de checkout y flujo de compra.
- [x] SEO básico: URLs amigables activas y los 25 títulos/descripciones de página en español.
- [x] Copia de seguridad: volcados con fecha en `backups/`. Falta activar JetBackup automático.
- [x] **Paquete de entrega listo** (`deploy/paquete/`, 6 documentos + 2 zip + traducciones).
- [ ] Entrega de accesos + inducción de uso del panel al cliente.

---

## 6. Gestión CMS (autogestión del cliente)

- **Front-office** (tienda) y **Back-office** (panel admin) de PrestaShop.
- **Elementor** permite editar páginas y banners arrastrando y soltando.
- Entregar al cliente: usuario admin, guía rápida de: publicar productos, editar textos,
  cambiar banners, revisar pedidos.
- Recomendado crear un **usuario admin para el cliente** con permisos acotados y mantener
  uno de super-admin para el proveedor.

---

## 7. Seguridad y respaldos

- [ ] HTTPS obligatorio + HSTS.
- [ ] Cambiar la ruta del back-office (carpeta admin) y usar contraseñas fuertes.
- [ ] Mantener PrestaShop, tema y módulos actualizados.
- [ ] **Backups automáticos** diarios (BD + archivos) a almacenamiento externo.
- [ ] Firewall + fail2ban en el VPS.
- [ ] No versionar credenciales: usar `.env` / variables de entorno y `.gitignore`.

---

## 8. Convenciones de repositorio (para Claude Code)

```
importtools-store/
├── CLAUDE.md              # este documento
├── docs/                  # cotización, aval, guía de usuario
├── theme-autosoe/         # personalizaciones del tema (child theme / overrides)
├── modules-custom/        # módulos o ajustes propios
├── db/                    # scripts SQL, seeds, import de catálogo
├── deploy/                # scripts de servidor, nginx.conf, php.ini
├── backups/               # (ignorado en git) respaldos locales
└── .env.example           # plantilla de variables (sin secretos)
```

- **No subir** `.env`, credenciales, ni la licencia del tema al repositorio.
- Trabajar cambios de tema como **overrides / child** para no perderlos al actualizar.
- Documentar cada módulo instalado y su configuración en `docs/`.

### El repo se mudó a un disco externo (12/08/2026)

`D:\Desarrollo\Gitlab Personal\importtoolsas` → **`F:\Gitlab Personal\importtoolsas`**.
`F:` **no es un disco interno**: es un **Kingston de 931 GB con exFAT**. Los scripts de
`local-dev/` se auto-localizan (`REPO="$(cd "$LOCAL_DEV/.." && pwd)"`), así que la mudanza
no rompió ninguno; lo que sí cambió es el entorno alrededor:

| Síntoma | Causa | Arreglo |
|---|---|---|
| `git` aborta con *dubious ownership* | exFAT **no registra propietario** | `git config --global --add safe.directory 'F:/Gitlab Personal/importtoolsas'` |
| WSL no ve el repo (`/mnt/f` no existe) | WSL solo automonta las unidades **presentes al arrancar** la distro | entrada en `/etc/fstab` con **`nofail`** (respaldo en `/etc/fstab.bak-20260812`) |
| `rsync -a` marca **todos** los ficheros como cambiados | exFAT no guarda modo ni grupo → difieren `p` y `g`, no el contenido | ninguno; es ruido. El destino es ext4 y el script reaplica permisos |

Quedó un `node_modules/` huérfano en la ruta vieja de `D:`; el resto se movió entero.

### ⚠️ El espejo y el repo habían divergido en las dos direcciones

Al sincronizar tras la mudanza, `sync-to-wsl.sh` (que lleva **`--delete`**) iba a **borrar
9 traducciones** que solo existían en el espejo y que nunca se habían traído con
`sync-from-wsl.sh`: `In Stock`→**Disponible**, `Out Of Stock`→**Agotado**,
`Register`→**Registrarse**, los tres textos del **404**, `Setting`→Opciones,
`Last product`→Último producto y `By`→Por. Rescatadas al repo antes de empujar: los dos
XLIFF pasan de 17 a **26 `trans-unit`**.

En sentido contrario, el **espejo estaba atrasado**: seguía con el azul marino
(`--it-navy: #1F3864`, `--itc-navy`, `#16202E`) que se retiró el 10/08, porque esa ronda
se subió **directamente a producción por FTPS** el 11/08 y nunca se empujó al espejo.
Confirmado midiendo producción, no suponiéndolo: `cotizacion.css` en línea pesa
**14.443 B, exactamente igual que el repo**, y trae `--itc-boton`. **El repo es la fuente
buena.** También había un **BOM UTF-8** de más en `plist3413072022.tpl` del espejo.

> 🔧 **`rsync` falló a medias con *Permission denied* en 6 ficheros**: 511 ficheros del tema
> en el espejo eran de `www-data` (huella de editar dentro del contenedor). Con `set -e`,
> el script **abortó antes de reaplicar permisos**, dejando el espejo a medio sincronizar.
> Se arregla con el mismo paso 4 del script (`chown -R $(id -un):33`, `2775`/`664`) y se
> repite el sync. Verificado después: **0 divergencias** repo↔espejo.

> 🔧 **Contar en inglés con `grep -i` infla el resultado.** Buscando textos sin traducir en
> una ficha de producción, `Register` salía **8 veces** y parecía inglés vivo. Con mayúscula
> exacta sale **1**, y es la clave `"register":"https://…/register"` del objeto JS de
> PrestaShop — una URL, no texto visible. Y `In Stock`/`Out Of Stock` dan 0 porque el
> **modo catálogo no pinta el bloque de disponibilidad**. No hay inglés visible.

---

## 9. Hitos y facturación

| Hito | Entregable | Pago |
|---|---|---|
| Inicio | Aval + anticipo, compra de hosting/dominio/licencia | 40% — $1.120.000 |
| Avance | Diseño y estructura aprobados, catálogo cargado | 30% — $840.000 |
| Entrega | Tienda publicada y funcional + inducción | 30% — $840.000 |

### Costos internos incurridos (año 1)

| Concepto | Valor |
|---|---|
| Hosting H2 (excluido de IVA) | $170.000 |
| Dominio importtoolsas.com | $52.000 |
| IVA 19% (solo sobre dominio) | $9.880 |
| **Subtotal infraestructura** | **$231.880** |
| Licencia AutoSoe (pendiente, ~USD 56) | ~$230.000 |

> Referencia de margen: sobre los **$2.800.000** cotizados, los costos directos de
> infraestructura + licencia rondan **~$460.000**, dejando el resto para diseño, desarrollo
> y soporte. La renovación de hosting mantiene precio fijo ($170.000/año).

---

## 10. Pendientes / decisiones abiertas

- [x] Dominio definido y comprado: **importtoolsas.com**.
- [x] Hosting contratado: **Latinoamérica Hosting — plan H2** (activo).
- [x] **Idiomas: solo español (es-CO).** El inglés queda instalado pero **inactivo**,
      para poder activarlo más adelante sin reinstalar el paquete. Decidido 27/07/2026.
- [x] **Catálogo demo eliminado** (27/07/2026): los 19 productos y 7 categorías de ejemplo
      de PrestaShop se borraron con la API para dejar limpio el import del catálogo real.
      Se conservan Root y Home.
- [x] **Tienda 100 % en español** — completado el **29/07/2026**. La auditoría del 28/07 decía
      «0 textos en inglés» y **era incorrecta**: buscaba cadenas traducibles, y quedaban dos
      clases que no lo son. Se encontraron leyendo el HTML servido, que es la única forma fiable:

      **a) 140 «Quick view» en la portada** (24 en catálogo y categoría). Las 15 plantillas de
      listado la pedían con `{l s='Quick view'}`, **sin `d=` ni `mod=`**. En ese caso
      `smartyfront.config.inc.php:285` no consulta el XLIFF del tema ni el fichero del módulo:
      usa `$_LANG`, que **en PrestaShop 9 no se rellena nunca** (ningún tema tiene ya carpeta
      `lang/`), así que devuelve el original inglés. **Es intraducible por fichero**: hay que
      añadir el dominio en la plantilla. Corregido en el tema hijo →
      `{l s='Quick view' d='Shop.Theme.Actions'}`, con la traducción ya presente en el XLIFF.
      ⚠️ Mi primer intento fue añadir 45 claves al `es.php` de `leoelements` y **no sirvió de
      nada**, justamente porque sin `mod=` ese fichero no se consulta.

      **b) Cinco textos que son DATOS, no cadenas** — ningún fichero de traducción los toca:

      | Dónde | Clave | Causa |
      |---|---|---|
      | Radios *Mr./Mrs.* del registro | `psjy_gender_lang` | Datos del catálogo |
      | Casilla RGPD del registro | `PSGDPR_CREATION_FORM`, `PSGDPR_CUSTOMER_FORM` | `psgdpr.php:45` elige el texto **por ISO al instalarse**; tiene `'es'` correcto pero también `'cb'` en inglés |
      | Aviso de privacidad del registro | `CUSTPRIV_MSG_AUTH` | Semilla en inglés |
      | Nota de baja del boletín (oculta) | `NW_CONDITIONS` | `ps_emailsubscription.php:1414` `getConditionFixtures()` |
      | **Página de mantenimiento** | `PS_MAINTENANCE_TEXT` | Texto de fábrica |

      La causa común de tres de ellos es el **`iso_code = 'cb'`**: esos módulos se instalaron
      con el ISO inválido y sembraron el inglés. Corregir el `iso_code` después **no reescribe
      lo ya guardado**. Script: `deploy/paquete/02c-textos-en-ingles-en-datos.sql`.
      `PS_MAINTENANCE_TEXT` importaba para el propio despliegue, porque el plan manda activar
      mantenimiento.

      Queda a propósito en inglés **`PS_SEARCH_BLACKLIST`** (palabras que el buscador ignora):
      cambiarla obliga a reconstruir el índice y es una decisión sobre el buscador. La lista en
      español está preparada y comentada en ese script.

      Verificación final: barrido insensible a mayúsculas sobre 15 páginas (portada, catálogo,
      categoría, ficha, marcas, marca, buscador, 7 CMS, login, registro, carrito, 404 y
      mantenimiento) → **0 apariciones**. Y en el tema hijo: 858 llamadas `{l …}`, 587 con `d=`,
      271 con `mod=`, **0 intraducibles**.
      El catálogo **es-CO sí estaba instalado** (169 XLIFF en `translations/es-CO/`);
      `psjy_translation` a 0 filas es lo normal, esa tabla solo guarda ediciones manuales.
      Las causas reales del inglés eran otras cinco — ver §7 de la bitácora del 28/07:
      1. `LEOELEMENTS_PANEL_TOOL = 1` servía el **personalizador de la demo del tema** en la
         tienda pública (33 enlaces `Clear`). Apagado: −28 KB por página.
      2. `{l s='Quick view'}` sin `d=` en los 15 estilos de listado.
      3. El tema pide cadenas a `Shop.Theme.Global` donde el core no las tiene →
         **catálogo propio del tema hijo** en `themes/vt_autosoe_child/translations/es-CO/`.
      4. Contenido demo en `contents` 11/15/16/17 (la cabecera de categoría salía en todas
         las categorías con `Pennzoil…`, `save $20 off`, `up to $100 off`).
      5. Títulos SEO (`psjy_meta_lang`, 25 páginas) y asuntos de contacto
         (`psjy_contact_lang`) son **datos**, no cadenas traducibles.
- [x] **`iso_code` del idioma corregido: `cb` → `es`.** `cb` no es un ISO válido y rompía la
      búsqueda de traducciones heredadas (`modules/{módulo}/translations/{iso}.php`).
- [x] **Código postal: `082001`** (confirmado 28/07/2026).
- [x] **La ficha de Google Maps a nombre de "HERRAMIENTAS Y SEGURIDAD S.A." es correcta**:
      así se conoce también a la empresa. No se cambia.
- [x] **El correo `@importtoolslatam.com` se mantiene** aunque la tienda sea
      `importtoolsas.com`: es una recomendación del cliente.
- [ ] **Fotos reales de producto.** Sigue siendo el pendiente que más pesa, pero **ya no
      está a cero**: auditoría del 10/08/2026 sobre producción → **13 productos con 77
      imágenes** subidas por el cliente (`id_image` 24–106), 100 ficheros en disco, 23
      huérfanos y **0 rotos**. También creó **18 productos** (`id` 3038–3055).
      ⚠️ **Mi afirmación anterior de «`psjy_image` = 0 filas» era falsa desde que el
      cliente empezó a subir fotos, y además la medí mal**: buscaba rutas `/img/p/…` en
      el HTML, y el tema escribe la **URL amigable de imagen** (`/67-home_default/{slug}.jpg`).
      El detector fiable es la clase `leo-noimage` de la plantilla. Detalle y qué no se
      puede pisar en `deploy/paquete/23-PASO-A-PASO-20260809.md` §12.
      ⚠️ Y **107 productos existen, son públicos y NO están en la categoría `Catálogo`**:
      no salen en `/2-catalogo` ni en los carruseles de la portada. Hay que decirle al
      cliente que marque también `Catálogo` al crear un producto.
      Mitigado en la ficha (01/08): el marcador
      del núcleo se limita a 300 px y se oculta la miniatura cuando está sola, así la ficha
      no se ve medio vacía; al cargar fotos, las reglas dejan de aplicar solas.
      Instagram no sirve como origen: sus URLs van firmadas y caducan.
- [x] **Fotos de empresa: resueltas con la maqueta del cliente** (01/08/2026). Las seis
      imágenes de *Quiénes somos* y *Quiero ser cliente* se recortaron de la propia maqueta
      (`deploy/paquete/img/Quienes somos.jpg.jpeg`, 4500×6211) y viven en `deploy/img/it/`.
      Los degradados de marca siguen para los banners que no tienen foto propia.
- [ ] Confirmar la escritura de la dirección: el cliente escribió
      `CARRERA CORDIALIDAD KM 2 5 66`; se publicó como **`Carrera Cordialidad Km 2.5 #66`**.
- [x] **Sin pasarela de pago.** El cliente no quiere medio de pago en línea: la venta se
      cierra por WhatsApp con un asesor.
- [ ] Confirmar cantidad de productos del catálogo inicial.
- [x] **EL CATÁLOGO NO LLEVA PRECIOS. No es provisional** (decidido 01/08/2026, revoca lo
      acordado el 29/07). `PS_CATALOG_MODE = 1` y `PS_CATALOG_MODE_WITH_PRICES = 0`: 0 precios,
      0 filtro de precio, 0 «ordenar por precio», sin carrito ni pago. El visitante arma una
      lista con «Agregar a mi cotización» y un asesor le responde por WhatsApp con precio,
      disponibilidad y tiempo de entrega. Los transportistas dejan de ser urgentes: solo
      harían falta si algún día se abre el carrito.
      ⚠️ Los 3.036 conservan en base el **precio generado**, marcado con
      `supplier_reference = 'PRECIO-PRUEBA'`. **No se ve en ningún sitio**, pero saldría
      entero si alguien desactivara el modo catálogo. Antes de abrir la tienda, cargar los
      reales.
- [ ] **Precios reales (ya no bloquean la salida a producción).** El cliente los enviará.
      El mecanismo de carga ya está listo y probado: **`deploy/paquete/06-cargar-precios-reales.sql`**
      (cruce en seco, respaldo, transacción, verificación y marcha atrás).
      ⚠️ **Antes de ejecutarlo hay que preguntar al cliente si sus precios llevan IVA.**
      `psjy_product.price` es el precio **sin** impuesto y los tres grupos tienen
      `price_display_method = 1` (mostrar sin IVA), con los 3.036 productos en la regla
      `CO Standard Rate (19%)` (id 53). Equivocarse deja el catálogo con un 19 % de desvío.
      ⚠️ Sobre el cruce por código, comprobado en el espejo (colación `utf8mb4_general_ci`):
      el `=` **ignora** espacios finales y mayúsculas, pero **no** ignora espacios iniciales,
      tabuladores ni `\r` — y `TRIM()` tampoco quita `\r`. Un CSV guardado en Windows (CRLF)
      deja `\r` en la última columna; si cae en el código, el cruce da 0 filas **sin avisar**.
      Por eso el script normaliza los códigos en un paso propio antes de cruzar.
- [ ] **Transportistas y costos de envío**: siguen los 4 demo (`Click and collect`,
      `My carrier`, …). Requiere definir con el cliente cobertura y tarifas reales.
      ⚠️ **Y hoy esto impide vender: nadie en Colombia puede completar un pedido.** El carrito
      funciona y el checkout de invitado está activo, pero el paso «Método de envío» sale sin
      ninguna opción. Los 4 demo solo cubren Europa y Norteamérica; Colombia está en la zona 6
      (*South America*), con 0 filas en `psjy_carrier_zone` y 0 en `psjy_delivery`.
      Verificado con el core: `Carrier::getCarriersForOrder(6)` → **0**, mientras que para las
      zonas 1 y 2 sí encuentra. Salidas en `deploy/paquete/07-transportistas-colombia.sql`
      (A: modo catálogo con una fila — lo recomendado mientras los precios sean los generados;
      B: transportista real para Colombia).
      ⚠️ Cuatro trampas al crear el transportista, comprobadas en el espejo: hay que insertar en
      `carrier_zone` **y** en `delivery`; `id_shop`/`id_shop_group` a **NULL** (con 1 se
      descarta); el rango debe ser **del propio** transportista; y debe coincidir con **cómo
      factura** — `shipping_method = 0` significa «usar `PS_SHIPPING_METHOD`», que aquí es `1`
      = **por peso**, así que va en `id_range_weight` y no en `id_range_price`. Con el rango
      equivocado `getMaxDeliveryPriceByWeight()` devuelve `false` y el transportista
      **desaparece sin ningún error**.
- [x] **Checkout revisado** (29/07/2026, pendiente de la Fase 4). Está **íntegro en español** y
      el IVA se calcula bien: producto 84.300 sin impuesto → total **100.317** con el 19 %.
      El checkout de invitado funciona (crea el cliente con `is_guest = 1`).
      ⚠️ Conviene avisar al cliente de que el catálogo muestra **sin IVA** (84.300) y el
      checkout cobra **con IVA** (100.317). Es lo correcto para venta al por mayor
      (`price_display_method = 1`), pero un comprador desprevenido ve un 19 % de diferencia.
- [x] **Datos demo eliminados del volcado de entrega** (29/07/2026). Script y justificación en
      `deploy/paquete/02b-limpieza-datos-demo.sql`; volcado bueno
      `backups/importtools-FINAL-20260729-1726.sql.gz`. Quedan 0 pedidos, 0 carritos,
      0 proveedores, 0 direcciones ajenas y 0 visitas. **Se conserva a propósito el cliente
      `id 1` «Anonymous» (`anonymous@psgdpr.com`)**: lo crea el módulo de RGPD y el core lo
      necesita para anonimizar.
      También se limpiaron 1.822 visitas / 1.902 invitados generados por mis pruebas en local
      (habrían salido como estadísticas falsas en el cuadro de mando del cliente),
      `pub@prestashop.com` en 2 filas de configuración de módulos que ya no existen, y
      `GBLEOELEMENTS`, que guardaba atajos del back office del **autor del tema**
      (`192.168.1.80` con sus tokens y `D:\xampp\htdocs\…`, heredados de
      `themes/vt_autosoe/samples/leoelements.xml`). Es seguro borrarlo:
      `LeoSlideshow.php:188` lo lee bajo `isset()` con defecto `''` y
      `AdminLeoElementsCreator.php:53` lo reescribe con `getAdminLink()` al abrir el editor.
      ⚠️ Quedan **14 filas de `leoelements_contents_lang` con URLs a `192.168.1.80`** dentro
      del JSON de Elementor (contenidos 1, 4, 5, 8, 9, 12, 13 × 2 idiomas).
      > ⚠️ **CORREGIDO EL 11/08/2026 — la conclusión de arriba («no se renderizan, así que
      > se dejan») ERA FALSA y costó un 500 en producción.** No aparecen en el HTML
      > justamente porque **la descarga FALLA**, pero el servidor sí la intenta: son los
      > iconos SVG de 22 widgets `icon-box` y el módulo los pide por HTTP en cada render.
      > Coste medido: **51,5 s la primera visita con la caché vacía**, y HTTP 500 en cuanto
      > se enciende el modo de depuración. Arreglado con
      > `deploy/paquete/27-iconos-svg-remotos.sql` — ver Fase 3-septies.
      > **La lección: «no sale en el HTML» no es lo mismo que «no se ejecuta».**
- [x] **Fallo corregido antes de desplegar**: la página *Quiero ser cliente* (`id_cms 7`)
      tenía dos enlaces absolutos a `http://localhost:8080/` — el botón *Crear mi cuenta* y el
      enlace a contacto. En producción no habrían llevado a ninguna parte. Ahora son relativos
      (`/login?create_account=1`, `/contact-us`, que son las URL amigables reales en es-CO).
      Era el único hallazgo de la auditoría del paquete que habría llegado roto al cliente.
- [x] **Las 7 páginas CMS están en español** (Envíos y entregas, Aviso legal, Términos y
      condiciones, Quiénes somos, Pago seguro, Preguntas frecuentes, Quiero ser cliente).
      El pendiente anterior de «5 páginas CMS en inglés» estaba desactualizado.
- [x] **Medios de pago: solo Bancolombia, Banco de Bogotá y Davivienda** (decidido
      03/08/2026). Fuera el sprite de la plantilla con American Express, Bitcoin, Apple
      Pay, Discover, Diners, VISA y JCB: la tienda no cobra en línea, el asesor confirma
      el total y se paga por transferencia o consignación. Van en el pie
      (`img/it/pagos-autorizados.png`) y en la página de cotización.
- [x] **La lista de deseos va en base de datos, con sesión iniciada** (decidido
      03/08/2026, descartado guardarla en el navegador). Es la de `leofeature`, atada a
      `id_customer`.
      ⚠️ **Consecuencia que el cliente debe conocer:** un visitante anónimo no puede
      usarla — el módulo le pide entrar (aviso ya en español). Como la tienda vende por
      WhatsApp y no empuja a registrarse, el corazón lo usará poca gente. La cotización,
      que es el camino de venta real, **no pide cuenta**.
- [ ] **Entradas de blog para «Consejos de uso y mantenimiento».** La sección existe en
      la portada y hoy se **oculta sola** porque no hay ninguna entrada publicada (antes
      mostraba «No blog at this time.» en inglés). Vuelve a aparecer sin tocar nada en
      cuanto se publique la primera.

---

*Recomendaciones técnicas basadas en la documentación oficial de PrestaShop (DevDocs 9)
vigente a julio de 2026. Los costos de hosting y dominio son referenciales del mercado
colombiano y deben verificarse al momento de la contratación.*
