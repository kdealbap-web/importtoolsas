# Fase 2 — Instalación de PrestaShop 9.1 + plantilla AutoSoe

> Tutorial paso a paso para el hosting **Latinoamérica Hosting — plan H2**
> (cPanel + LiteSpeed + Softaculous Premium + PHP 8.5). Al terminar esta fase debes tener:
> **PrestaShop 9.1 instalado, con SSL, la plantilla AutoSoe activa y los datos demo importados.**

---

## 0. Prerrequisitos (cierre de Fase 1)

Antes de instalar, confirma en cPanel:

- [ ] El dominio **importtoolsas.com** resuelve al hosting y tiene **SSL activo** (AutoSSL/Let's Encrypt en cPanel → *SSL/TLS Status*).
- [ ] **PHP 8.5** seleccionado (cPanel → *Select PHP Version* / *MultiPHP Manager*) con extensiones: `curl, dom, gd, intl, mbstring, zip, json, mysqli, pdo_mysql, openssl, fileinfo, iconv, simplexml, xml`.
- [ ] Límites PHP (cPanel → *Select PHP Version → Options*, o *MultiPHP INI Editor*):
  - `memory_limit = 512M`  ⚠️ en CloudLinux (H2) puede estar topado por límites LVE → si no deja subir a 512M, abrir ticket a soporte o evaluar upgrade a H3.
  - `max_execution_time = 300`
  - `upload_max_filesize = 64M`
  - `post_max_size = 64M`
  - `max_input_vars = 10000`
  - `allow_url_fopen = On`
- [ ] **Respaldo previo** con JetBackup (punto de restauración por si algo sale mal).

---

## 1. Elegir método de instalación

- **Método A — Softaculous (1 clic):** rápido y recomendado. Úsalo si Softaculous ofrece **PrestaShop 9.1**.
- **Método B — Manual:** si Softaculous aún no tiene la 9.1 o quieres control total.

> Verifica primero la versión: cPanel → **Softaculous Apps Installer** → busca *PrestaShop* → mira la versión disponible. Si es 9.1 → Método A. Si es inferior → Método B (o esperar).

---

## 2. Método A — Instalar con Softaculous

1. cPanel → **Softaculous Apps Installer** → *PrestaShop* → **Install Now**.
2. **Software Setup:**
   - *Choose Protocol:* **`https://www.`** (con SSL ya activo).
   - *Choose Domain:* `importtoolsas.com`.
   - *In Directory:* **dejar VACÍO** (instala en la raíz del dominio).
   - *Version:* la 9.1 disponible.
3. **Store Settings:** nombre de la tienda ("Importtools Latam"), país Colombia, moneda **COP**, idioma Español.
4. **Admin Account:** usuario, correo y **contraseña fuerte** del back-office. Guárdalos en tu gestor (NO en el repo).
5. **Database Settings:** deja que Softaculous cree la BD automáticamente (o define nombre/usuario). El plan H2 permite hasta 5 BD MySQL.
6. **Advanced Options:** activa *Auto Upgrade* desactivado, y **Automated Backups** si quieres respaldos de Softaculous.
7. **Install** → espera a que termine y anota la **URL del back-office** (Softaculous renombra la carpeta admin con un sufijo aleatorio, p. ej. `/adminXXXXX`).

➡️ Sigue en la **sección 4 (post-instalación)**.

---

## 3. Método B — Instalación manual

1. Descarga PrestaShop 9.1 desde **https://www.prestashop.com** (o GitHub oficial).
2. cPanel → **MySQL Databases:** crea una BD (p. ej. `impt_ps`), un usuario y **asigna todos los privilegios**. Anota nombre BD / usuario / contraseña.
3. cPanel → **Administrador de archivos** → carpeta `public_html` del dominio → **sube el ZIP** de PrestaShop y **extráelo** ahí (que quede en la raíz, no en subcarpeta).
4. Navega a `https://www.importtoolsas.com` → arranca el **asistente de instalación**:
   - Idioma Español, aceptar licencia.
   - Datos de la tienda + cuenta admin (contraseña fuerte).
   - **Configuración de BD:** host `localhost`, nombre/usuario/contraseña creados en el paso 2 → *Probar conexión* → siguiente.
5. Al finalizar:
   - **Borra la carpeta `/install`** (Administrador de archivos).
   - **Renombra la carpeta `/admin`** a algo aleatorio (p. ej. `/gestion-9f3a`) y usa esa URL para entrar.

---

## 4. Post-instalación de PrestaShop (seguridad y rendimiento)

- [ ] Entra al back-office con la URL de admin renombrada.
- [ ] **Parámetros de la tienda → General:** activar **"Habilitar SSL"** y **"Habilitar SSL en todas las páginas"**.
- [ ] Verifica que `/install` **no exista** y que la carpeta admin tenga nombre aleatorio.
- [ ] **LiteSpeed Cache:** instala el módulo **"LiteSpeed Cache for PrestaShop" (lscache)** (Módulos → subir/instalar) y actívalo → clave para el rendimiento en H2 (no hay Redis en compartido).
- [ ] **Modo mantenimiento ON** mientras trabajas (Parámetros → General → Mantenimiento), con tu IP en la lista blanca.
- [ ] Confirma un **backup** con JetBackup ya con PrestaShop instalado.

---

## 5. Instalar la plantilla AutoSoe

> AutoSoe (apollotheme) se entrega como paquete con: **tema (.zip)**, **módulos**, **datos demo** y **documentación**. Los nombres/orden exactos de módulos están en el PDF/HTML de documentación del tema — síguelo como fuente de verdad.

1. **Adquirir licencia** AutoSoe (ThemeForest/apollotheme, ~USD 56) y **descargar el paquete**. ⚠️ El `.zip` del tema y la licencia **NO se versionan** (ya excluidos en `.gitignore`).
2. **Confirmar compatibilidad**: AutoSoe soporta PrestaShop 8.x–9.1 (ver `CLAUDE.md`). Verifica en la doc del tema que la versión que bajaste es compatible con **9.1**.
3. **Subir el tema:** Back-office → **Diseño → Tema y logo → Agregar nuevo tema → Importar desde mi ordenador** → sube el `.zip` del tema → **Usar este tema**.
4. **Instalar los módulos del paquete** que pida la documentación: **constructor Elementor**, **mega menú**, **Parts Filter**, wishlist/comparador, búsqueda ajax, etc.
5. **Importar datos demo:** usa la herramienta de importación del tema (módulo de "data install" / import del framework Apollo) para cargar la **estructura demo** (home, categorías, banners de ejemplo). Esto da la base visual que luego personalizamos en **Fase 3**.
6. Revisa el **front-office**: debe verse la home de AutoSoe con el contenido demo.

---

## 6. Checklist de cierre de Fase 2

- [ ] PrestaShop 9.1 accesible en `https://www.importtoolsas.com` con **candado SSL**.
- [ ] Back-office en carpeta admin **renombrada** y con contraseña fuerte.
- [ ] Carpeta `/install` **eliminada**.
- [ ] Módulo **LSCache** instalado y activo.
- [ ] Plantilla **AutoSoe activa** + módulos instalados.
- [ ] **Datos demo** importados (estructura base visible).
- [ ] **Backup** post-instalación hecho (JetBackup).

➡️ Con esto se libera la **Fase 3 — Personalización** (ver [`fase3-personalizacion.md`](fase3-personalizacion.md)).

---

## 7. Problemas comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| Error de memoria / página en blanco al instalar | `memory_limit` < 512M | Subirlo en *Select PHP Version → Options*; si CloudLinux lo topa, ticket a soporte |
| "Se alcanzó el límite de max_input_vars" | `max_input_vars` bajo | Subir a 10000 |
| Falla la subida del tema (zip grande) | `upload_max_filesize`/`post_max_size` bajos | Subir a 64M+; o subir el zip por Administrador de archivos y descomprimir |
| Extensión PHP faltante en el chequeo de PrestaShop | Extensión desactivada | Activar en *Select PHP Version → Extensions* (gd, intl, zip, curl, dom…) |
| Mezcla de contenido / SSL | SSL no forzado | Activar SSL en todas las páginas + revisar Cloudflare en **Full (strict)** si aplica |
| Miniaturas no generan / disco lleno | Límite de **inodos (~200.000)** en H2 | Reducir imágenes o upgrade a H3 |

---

*Requisitos técnicos según documentación oficial de PrestaShop (DevDocs 9). Verificar la
versión de PrestaShop disponible en Softaculous y la compatibilidad exacta de AutoSoe en la
documentación del tema al momento de instalar.*
