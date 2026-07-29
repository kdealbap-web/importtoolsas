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
- [ ] Aplicar colores y tipografías de la marca (`--it-red #E2211C`, `--it-navy #1F3864`)
      a cabecera, botones, precios y etiquetas.

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

### Fase 4 — Pruebas y entrega (contra 30% final)
- [ ] Pruebas responsive (desktop / tablet / móvil).
- [ ] Revisión de checkout y flujo de compra.
- [ ] SEO básico (URLs amigables, metadatos, sitemap) y velocidad.
- [ ] Copia de seguridad inicial y activación de backups automáticos.
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
- [x] **Tienda 100 % en español** (28/07/2026). Auditoría sobre 10 páginas: 0 textos en inglés.
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
- [ ] **Fotos reales de la empresa y de producto.** Es el pendiente que más pesa:
      `psjy_image` = 0 filas, o sea **los 3.036 productos no tienen imagen**. Los degradados
      de marca de `/img/it/` son provisionales; quitan el enfoque automotriz pero no
      sustituyen fotos. Instagram no sirve como origen: sus URLs van firmadas y caducan.
- [ ] Confirmar la escritura de la dirección: el cliente escribió
      `CARRERA CORDIALIDAD KM 2 5 66`; se publicó como **`Carrera Cordialidad Km 2.5 #66`**.
- [ ] ¿Pasarela de pago en línea en esta fase? (se cotiza aparte si aplica).
- [ ] Confirmar cantidad de productos del catálogo inicial.
- [ ] **Transportistas y costos de envío**: siguen los 4 demo (`Click and collect`,
      `My carrier`, …). Requiere definir con el cliente cobertura y tarifas reales.
- [ ] **Datos demo restantes** (no bloquean, pero no deben llegar a producción):
      2 clientes, 5 pedidos, 5 carritos, 2 fabricantes, 2 proveedores de ejemplo,
      y 5 páginas CMS en inglés (Delivery, Legal Notice, Terms, About us, Secure payment)
      pendientes de reescribir en español.

---

*Recomendaciones técnicas basadas en la documentación oficial de PrestaShop (DevDocs 9)
vigente a julio de 2026. Los costos de hosting y dominio son referenciales del mercado
colombiano y deben verificarse al momento de la contratación.*
