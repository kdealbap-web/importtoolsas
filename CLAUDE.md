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
- [ ] Aplicar logo, colores y tipografías de la marca.
- [ ] Configurar cabecera, menú (mega menú), banners y home.
- [ ] Configurar idioma(s), moneda (COP), impuestos y zonas de envío.
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
- [ ] Definir idiomas del sitio (¿solo ES o ES/EN?).
- [ ] ¿Pasarela de pago en línea en esta fase? (se cotiza aparte si aplica).
- [ ] Confirmar cantidad de productos del catálogo inicial.

---

*Recomendaciones técnicas basadas en la documentación oficial de PrestaShop (DevDocs 9)
vigente a julio de 2026. Los costos de hosting y dominio son referenciales del mercado
colombiano y deben verificarse al momento de la contratación.*
