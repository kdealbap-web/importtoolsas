# Entorno local espejo — Importtools (PrestaShop 9.1.4 + PHP 8.5, Docker)

Réplica local de la tienda de producción para construir/depurar la **Fase 3–4** sin tocar
el sitio en vivo, y luego **desplegar el entregable terminado** a producción.

Stack (Linux, igual que el hosting): **PHP 8.5 + Apache** (contenedor `web`) · **MariaDB 10.11**
(`db`) · **phpMyAdmin** (`pma`).

---

## 0. Prerequisito (una sola vez) — ✅ YA HECHO

| Componente | Estado |
|---|---|
| WSL | 2.7.11 · kernel 6.18.33.2 · versión por defecto 2 |
| Distro | **Ubuntu 24.04.4 LTS** · usuario `kevin` · `systemd` · TZ `America/Bogota` |
| Límites VM | `%USERPROFILE%\.wslconfig` → 10 GB RAM / 8 vCPU / 4 GB swap |
| Docker Desktop | 29.6.2 con **backend WSL2** e integración con `Ubuntu-24.04` activada |

Comprobación rápida: `wsl -l -v` debe listar `Ubuntu-24.04` y `docker-desktop`, y
`wsl -d Ubuntu-24.04 -- docker version` debe mostrar cliente **y** servidor.

## 0.bis Dónde se trabaja (importante)

El repo git vive en `D:\Desarrollo\Gitlab Personal\importtoolsas` y es la **fuente de
verdad** de lo versionado. Pero el entorno que Docker sirve vive en el **filesystem nativo
de WSL**:

```
~/importtools/           →  \\wsl$\Ubuntu-24.04\home\kevin\importtools
```

Motivo: `prestashop/` son ~41.000 archivos. Montado desde `/mnt/d` (9p) el back office
tarda decenas de segundos por página; en ext4 va ~10–20× más rápido. Además, el `umask=22`
del automount de `/mnt` impide que `www-data` escriba en `var/cache/` e `img/`.

**Todos los comandos `docker compose` se corren desde `~/importtools` dentro de WSL.**

Sincronización entre repo y entorno (ambos aceptan `--dry-run`):

```bash
bash /mnt/d/Desarrollo/Gitlab\ Personal/importtoolsas/local-dev/sync-to-wsl.sh    # repo -> WSL
bash /mnt/d/Desarrollo/Gitlab\ Personal/importtoolsas/local-dev/sync-from-wsl.sh  # WSL -> repo
```

`sync-to-wsl.sh` empuja compose, Dockerfile, `config/php.ini`, el tema hijo
`vt_autosoe_child` y los módulos de `modules-custom/`; luego reaplica permisos y vacía la
caché. `sync-from-wsl.sh` solo trae de vuelta el tema hijo y los módulos propios — nunca
`parameters.php`, dumps ni el core.

## 1. Clonar producción
### a) Base de datos
- cPanel → **phpMyAdmin** → selecciona la BD de la tienda (`importto_pres437`) → **Exportar**
  → método *Personalizado* → formato **SQL** → **sin** “CREATE DATABASE / USE” (solo tablas y datos).
- Guarda el archivo como **`local-dev/dump/importtools.sql`**.
  (Alternativa: usar el backup de BD de JetBackup y descomprimirlo aquí.)

### b) Archivos
- cPanel → **Administrador de archivos** → **activa "Mostrar archivos ocultos (dotfiles)"**
  en Configuración → entra a `public_html` → **Comprimir todo** a un `.zip` → descárgalo.
- Extráelo dentro de **`local-dev/prestashop/`** de modo que `local-dev/prestashop/index.php` exista
  (la raíz de PrestaShop, no dentro de una subcarpeta).
- Puedes omitir `var/cache/**` (se regenera).

> ⚠️ **Los dotfiles de la RAÍZ se pierden si no activas "mostrar ocultos" antes de comprimir.**
> Pasó en este clonado: llegaron los `.env` de subcarpetas (`modules/ps_checkout/.env`) pero
> **no** los de la raíz. Consecuencias observadas:
>
> | Archivo ausente | Síntoma |
> |---|---|
> | `.env` | **HTTP 500** en todo el sitio: `index.php:25` hace `(new Dotenv(false))->loadEnv()` y lanza `PathException: Unable to read the "/var/www/html/.env"` |
> | `.htaccess` | Home OK pero **404 en toda URL amigable** (`/1-producto.html`), porque `PS_REWRITING_SETTINGS=1` y no hay reglas de rewrite |
>
> Reparación aplicada en el entorno local:
> - `.env` creado a mano con `APP_ENV=prod` / `APP_DEBUG=0` (el core no lee otras variables;
>   Symfony solo exige que el archivo exista y sea legible).
> - `.htaccess` regenerado con la propia API de PrestaShop:
>   ```bash
>   cd ~/importtools
>   cat > prestashop/_gen.php <<'PHP'
>   <?php require_once __DIR__.'/config/config.inc.php'; var_dump(Tools::generateHtaccess());
>   PHP
>   docker compose exec -T web php /var/www/html/_gen.php && rm prestashop/_gen.php
>   ```
>   (equivale a Back office → Parámetros de la tienda → Tráfico y SEO → Guardar)
>
> **Para la Fase 4:** al subir a producción hay que asegurarse de que `.env` y `.htaccess`
> lleguen al servidor; un FTP configurado sin mostrar ocultos los omitiría igual.

## 2. Apuntar PrestaShop a la BD local
En **`~/importtools/prestashop/app/config/parameters.php`**:
```php
'database_host'     => 'db',
'database_port'     => '',
'database_name'     => 'importtools',
'database_user'     => 'ps',
'database_password' => 'ps',
'database_prefix'   => 'psjy_',    // ← prefijo REAL de producción, NO cambiar
'ps_caching'        => 'CacheFs',  // venía 'CacheMemcache' y no hay Memcached en el compose
```
El prefijo debe coincidir con las tablas del dump. El original de producción queda
respaldado como `parameters.php.prod.bak` (contiene credenciales de prod: no versionar).

## 3. Levantar el entorno
Desde `~/importtools` **dentro de WSL**:
```
docker compose up -d --build
```
- El dump `./dump/importtools.sql` se **importa solo** en el primer arranque (volumen `dbdata` vacío).
- Front: <http://localhost:8080> · phpMyAdmin: <http://localhost:8081> (server `db`, user `root`, pass `root`).
- Los puertos son accesibles desde Windows tal cual, gracias a `localhostForwarding`.

> **No cambiar el Dockerfile a la ligera.** Dos cosas rompen el build y están comentadas
> en él: `opcache` **no** debe ir en `docker-php-ext-install` (ya viene compilado en
> `php:8.5-apache`, y si se incluye el build aborta con
> `cp: cannot stat 'modules/*'`), y las extensiones deben compilarse con `-j1`
> (con `-j$(nproc)` libtool colisiona: `mkdir: cannot create directory '.libs'`).

## 4. Ajustar URLs y SSL para localhost
En phpMyAdmin (o SQL), sobre la BD `importtools` — prefijo real **`psjy_`**:
```sql
UPDATE psjy_shop_url
   SET domain = 'localhost:8080', domain_ssl = 'localhost:8080', physical_uri = '/';
UPDATE psjy_configuration SET value = '0'
 WHERE name IN ('PS_SSL_ENABLED','PS_SSL_ENABLED_EVERYWHERE');
```
Luego borra la caché: `rm -rf ~/importtools/prestashop/var/cache/*`.

## 5. Entrar
- Tienda: <http://localhost:8080>
- Back office: <http://localhost:8080/panel-4h5o>  ← carpeta admin real de producción
- phpMyAdmin: <http://localhost:8081>
- (Opcional) activar modo dev: en `config/defines.inc.php` poner `define('_PS_MODE_DEV_', true);`.

---

## Comandos útiles
```
docker compose up -d --build     # levantar (build la primera vez)
docker compose logs -f web       # ver logs de Apache/PHP
docker compose down              # apagar (conserva datos)
docker compose down -v           # apagar y BORRAR la BD (para reimportar el dump)
docker compose exec web bash     # shell dentro del contenedor web
```

## Desplegar el build terminado a producción (Fase 4)
Como prod aún no tiene datos reales, el despliegue es **one-way** (local → prod):
1. Exportar la BD local (`docker compose exec db mariadb-dump ...`) y volver a poner las URLs de prod
   (`www.importtoolsas.com`, `PS_SSL_ENABLED=1`).
2. Subir los archivos (tema child, módulos, `img/`, contenido) a `public_html` por FTP/Administrador.
3. Importar la BD en prod y limpiar caché.
4. Verificar SSL, home, menú y checkout.

> Nota: `local-dev/prestashop/` y `local-dev/dump/` están **gitignored** (pesados y con datos/credenciales de prod).
