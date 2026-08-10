# Bitácora — 29 de julio de 2026: blindaje de la entrega

Sesión nocturna. Objetivo: dejar la tienda en un estado que el cliente pueda administrar sin
poder romper el trabajo hecho, y producir el paquete de importación a producción.

Complementa `fase3-bitacora-2026-07-28.md`.

---

## 1. El panel del engranaje: qué es y qué no

Antes de decidir nada verifiqué **si ese panel escribe en la base de datos**, porque de eso
dependía si era un problema de seguridad o de presentación.

```
paneltool.js →  7 setCookie   ·   0 ajax   ·   0 post   ·   0 Configuration
```

Solo escribe **cookies en el navegador del visitante**. Y por el lado del servidor, intentando
escribir como anónimo:

```
action=save / update / saveElement / save_content  →  HTTP 200, respuesta "exit" (4 bytes)
huella MD5 de los 34 contenidos antes:   300b5614839848a4f4baa51db00a934e
huella MD5 después:                      300b5614839848a4f4baa51db00a934e
```

Idéntica. **No es una vulnerabilidad**: un anónimo no puede modificar la tienda. Lo que sí
hacía era (a) exponer un personalizador al público y (b) permitir **cargar las portadas de
muestra**, que son de automoción y en inglés, con pérdida del menú.

### El dato que resolvió el conflicto

Apagarlo **no quita ninguna capacidad**. `AdminLeoElementsProfiles` («Profiles: Home or
LandingPage») tiene **151 campos**: colores de fondo, botones, titulares, miga de pan,
etiquetas de producto y tipografías. Son los mismos ajustes, detrás del login. Hay 41 pestañas
de Leo en el back office.

En la primera pasada apagué el panel sin explicar esto y el usuario lo revirtió con razón. Con
el dato encima de la mesa, la decisión fue suya.

---

## 2. Dejar un solo diseño, sin borrar lo que rompe el editor

El plan inicial era borrar los 4 perfiles de muestra y sus 13 contenidos. **Dos hallazgos lo
cambiaron:**

**a) La prueba empírica contradijo mi inventario.** La portada renderiza
`elementor-9, 10, 11, 12, 17`: el contenido **9** (`displayNav2 of header 03`) **sí está en
uso**, y estaba en mi lista de borrado. Habría tumbado media cabecera.

**b) El perfil guarda catálogos JSON de diseños.** `product_list_data`, `category_list_data` y
`product_detail_data` listan los 12 estilos de listado, 4 diseños de categoría y 7 de ficha.
Borrar esas filas habría dejado referencias colgantes en el editor.

### Enfoque final: sobreescribir en vez de borrar

- **Borrados** los perfiles 1, 2, 4 y 5 (nada los referenciaba).
- Los **12 contenidos de muestra se sobreescribieron con copia de los limpios equivalentes**:

```
c=9  (nav2 header 03)   ->  c=1, c=5, c=13
c=10 (top header 03)    ->  c=2, c=6, c=14     (y con ello desaparece el menú vertical)
c=11 (portada 03)       ->  c=3, c=7, c=15, c=16
c=12 (pie 03)           ->  c=4, c=8
```

Ventajas: mismas filas, mismo `content_key`, mismo nombre → **cero referencias colgantes**, el
editor de perfiles intacto, y si el cliente cambia de cabecera o de portada obtiene **nuestro**
diseño, no el de la plantilla.

Resultado verificado: **0 contenido genérico, 0 menú vertical, 0 JSON roto**, y los catálogos
de diseño (13/5/8 opciones) intactos.

---

## 3. Permisos: el modelo de roles de PrestaShop 9

PS 9 no usa una tabla de permisos por pestaña con columnas `view/add/edit/delete`, sino
**1.160 roles** en `psjy_authorization_role` con el patrón:

```
ROLE_MOD_TAB_{CLASE}_{CREATE|READ|UPDATE|DELETE}      804 roles
ROLE_MOD_MODULE_{MODULO}_{CREATE|READ|UPDATE|DELETE}  356 roles
```

concedidos en `psjy_access` y `psjy_module_access`.

Perfil creado: **`Cliente Importtools` (id 5)** — 302 roles de pestaña + 48 de módulo.

### Tres cosas que no eran obvias

**3.1 PrestaShop comprueba la cadena de pestañas padre.**
`AdminLeoBootstrapMenuModule` tenía `view=1`, pero devolvía 403. Su padre
`AdminParentModulesSf` y su abuelo `IMPROVE` tenían `view=0`. Hubo que conceder **solo READ**
en **20 pestañas contenedoras** (`IMPROVE`, `SELL`, `CONFIGURE`, `AdminParentOrders`,
`AdminCatalog`, `ShopParameters`…). Son cabeceras de menú: no dan acceso a nada por sí mismas.

**3.2 Las páginas de configuración de módulo exigen ver el listado de módulos.**
Aun con los ancestros abiertos, el editor del menú seguía en 403. Hubo que conceder READ en
`AdminModulesSf` / `AdminModulesManage`. Ver el listado es inocuo; instalar, desinstalar y
resetear requieren CREATE/UPDATE/DELETE.

**3.3 `Profile::getProfileAccesses()` y la capa HTTP no coinciden para pestañas de módulo.**
El modelo devolvía `VAEB` para `AdminLeoBootstrapMenuModule` mientras HTTP daba 403 — el
modelo cae en `module_access` y la capa HTTP comprueba además la cadena de padres. **Conclusión
práctica: validar permisos por HTTP, no solo por el modelo.**

### Estado final

```
módulos:  ver = sí     configurar = sí (UPDATE)     desinstalar = NO (DELETE revocado)
```

---

## 4. Tres fallos que aparecieron al validar, con su causa

Ninguno se veía sin iniciar sesión de verdad. Los tres están en el plan de importación con su
síntoma y su arreglo.

### 4.1 `session.save_path` de cPanel — por esto el back office no mantenía la sesión

```
SessionHandler::read(): open(/var/cpanel/php/sessions/ea-php85/sess_...) failed
session_write_close(): Failed to write session data
```

`prestashop/php.ini` (el de la raíz, traído de producción) fija en su línea 13:

```ini
session.save_path = "/var/cpanel/php/sessions/ea-php85"
```

Y PHP lo carga como *Loaded Configuration File*. En el contenedor esa ruta no existe → el login
creaba la fila en `psjy_employee_session` pero la petición siguiente volvía al login.

**En producción esa ruta es la correcta.** Es un artefacto del espejo local: parcheé la línea
localmente y guardé el original en `deploy/paquete/config/php.ini.produccion`.

### 4.2 `Date must be a string` — fallo mío

```
PrestaShopException: "Date must be a string" at HelperCalendar.php line 135
```

Al crear el empleado por `INSERT` directo dejé `stats_date_from` y `stats_date_to` en `NULL`.
PrestaShop espera cadenas de fecha y el selector de rangos del dashboard lanza excepción.
**Habría reventado al cliente en su primer acceso.** Corregido copiando los valores del
empleado 1.

### 4.3 Caché escrita por el usuario equivocado

```
SmartyException: unable to create directory var/cache/prod/smarty/compile/ee/96/cf
```

Mis scripts ejecutaban PHP **como root** dentro del contenedor, así que `var/cache/prod` quedó
`root:www-data` con `g=r-x`. Apache corre como `www-data` y no podía regenerar la caché → 500
intermitentes. Ahora la caché se limpia **desde el contenedor como www-data**.

---

## 5. Dos comportamientos del core que parecen fallos y no lo son

**5.1 Bucle a `/security/compromised?uri=...` y error 414.**
`TokenizedUrlsListener.php:56` redirige ahí cuando falta el token de URL. PrestaShop 9 exige un
token por URL en el back office; escribir `index.php?controller=AdminProducts` a mano lo
dispara, y con `-L` la URL se acumula hasta agotar la pila. **Comportamiento correcto del core.**

**5.2 «Token no válido» en algunas páginas de módulo.**
`Tools::getAdminTokenLite()` no coincide con el token que usa el controlador para páginas de
módulo. Dan la interstitial de «¿Deseas mostrar esta página?», no una denegación: desde el menú
del navegador abren bien.

Las dos invalidaron mis primeros intentos de auditoría por HTTP. Anotadas para no volver a
perder tiempo con ellas.

---

## 6. Validación final, con sesión real

```
login                        200
dashboard                     41 KB
AdminProducts                253 KB
AdminCategories              172 KB
AdminManufacturers           145 KB
AdminCmsContent              135 KB
AdminOrders                  128 KB
AdminImages                  135 KB
AdminMeta                    249 KB
AdminStockManagement          68 KB
AdminLeoBootstrapMenuModule   90 KB
AdminLeoSlideshowMenuModule  208 KB

DENEGADO (403): AdminThemes · AdminModulesManage · AdminEmployees ·
                AdminPerformance · AdminRequestSql · AdminCarriers · AdminTaxes

errores CRITICAL en el log: 0
front: / · /2-catalogo · /23-tornilleria · /brands · /contact-us  →  todas 200
```

### Prueba de restauración del volcado en base limpia

```
productos 3036 · en catálogo 3036 · stock 3036 · marcas 7 · características 6072
contenidos Leo 34 (JSON válido 34/34) · perfiles Leo 1 · menú 54 items · CMS 14
empleados 3 · perfiles admin 5 · permisos del cliente 302 + 48 de módulo
LEOELEMENTS_PANEL_TOOL = 0 · contenidos con rastro demo = 0
```

---

## 7. Paquete entregado

`deploy/paquete/`

| Fichero | Qué es |
|---|---|
| `00-PROGRESO-CLIENTE.md` | Para el cliente: qué está listo, dónde edita cada cosa, qué falta |
| `historico/01-LEEME-DESPLIEGUE.md` | Instalación paso a paso |
| `02-ajustes-tras-importar.sql` | Obligatorio: dominio, HTTPS, caché de CSS de Elementor |
| `03-opcional-precios-prueba.sql` | Las dos salidas para los precios generados |
| `historico/04-PLAN-IMPORTACION.md` | Plan por fases + **diagnóstico de los 5 fallos con su causa** |
| `05-CREDENCIALES.md` | Cuentas, alcance del perfil del cliente, recordatorios de seguridad |
| `vt_autosoe_child.zip` | Tema hijo, 8,8 MB, 659 ficheros |
| `img-importtools.zip` | Imágenes de contenido y logotipos, 3,6 MB |
| `config/php.ini.produccion` | El php.ini original de cPanel, sin parchear |
| `modules/*/translations/es.php` | 564 + 25 claves |

El volcado (`backups/importtools-FINAL-*.sql.gz`, 704 KB) queda **fuera** del paquete y del
control de versiones: lleva hashes de contraseñas de empleados y datos de clientes.

---

## 8. Lo que sigue bloqueando la apertura al público

1. **Fotos de producto.** `psjy_image` = 0 filas: los 3.036 productos salen con el marcador de
   «sin imagen». Es el pendiente que más pesa.
2. **Precios reales.** Los actuales son generados (`supplier_reference = 'PRECIO-PRUEBA'`).
3. **Transportistas y tarifas.** Siguen los 4 de ejemplo.
4. **Medios de pago.** Por decidir si se habilita pasarela.

Y dos recordatorios de seguridad: rotar la contraseña de la base de datos y la
`api_private_key` de `parameters.php`, que han circulado en copias locales.
