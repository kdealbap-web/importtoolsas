# Cómo darme el FTP para que yo suba a producción

Plantilla y procedimiento. Lo que hay que rellenar son **cuatro líneas**.

---

## 1. La plantilla

Ya está en el repo como **`.env.example`**. El fichero real se llama `.env`, va en la
**raíz** (`F:\Gitlab Personal\importtoolsas\.env`) y está cubierto por `.gitignore`
(línea 5), así que no puede colarse en un commit.

Lo mínimo que necesito son estas cuatro:

```dotenv
FTP_HOST=ftp.importtoolsas.com
FTP_USER=
FTP_PASSWORD=
FTP_DOCROOT=public_html
```

Las demás del `.env.example` son opcionales (`FTP_PORT` por defecto 21, `SITE_URL` ya
apunta al dominio con `www`).

### `FTP_DOCROOT`, que es la que se equivoca siempre

Es la carpeta que hace de raíz del sitio, **relativa a donde entra el FTP**:

| Si la cuenta FTP es… | Poner |
|---|---|
| la del cPanel principal (entra en `/home/usuario`) | `public_html` |
| una cuenta FTP dedicada anclada al sitio (entra ya dentro) | `.` |

Si se equivoca, el script falla al hacer `cwd` **antes de escribir nada**. No hay riesgo.

---

## 2. Cómo pasármela — no por el chat

**No pegues la contraseña en la conversación.** Todo lo que se escribe aquí queda en el
historial de la sesión. Es innecesario: el script lee el fichero de tu disco, así que
basta con que lo crees tú y me digas «listo».

Dos formas, ambas sin que la clave pase por el chat:

**a) Desde esta misma sesión**, escribiendo un `!` delante (se ejecuta en tu terminal):

```
! copy ".env.example" ".env"
! notepad ".env"
```

**b) A mano**: copia `.env.example` a `.env` con el explorador y ábrelo con el Bloc de
notas.

Cuando esté, dime «ya está el .env» y yo verifico la conexión con `--dry-run`, que **no
escribe nada** en el servidor: solo lista qué ficheros hay ahora y qué tamaño tendrían
después.

---

## 3. Antes de crear la cuenta: dos recomendaciones

1. **Crea una cuenta FTP dedicada** en cPanel → *Cuentas FTP*, con directorio raíz
   `public_html`, en vez de darme la del cPanel principal. Así lo que se puede tocar
   queda acotado al sitio: ni correo, ni copias de seguridad, ni el resto del `/home`.
2. **Cámbiala o bórrala cuando terminemos.** Es una credencial de un despliegue, no
   permanente.

Y una comprobación: el hosting tiene que admitir **FTPS explícito** (puerto 21 con
`AUTH TLS`). El plan H2 lo admite. El script cifra el canal de control **y el de datos**
(`prot_p()`); si el servidor no lo aceptara, falla al conectar y no sube nada — no hay
modo «sin cifrar» al que caerse.

### ⚠️ `FTP_HOST` va con el nombre del SERVIDOR, no con el del dominio

Con `FTP_HOST=ftp.importtoolsas.com` el saludo TLS funciona, pero la verificación del
certificado falla:

```
SSLCertVerificationError: Hostname mismatch, certificate is not valid for 'ftp.importtoolsas.com'
```

No es un problema del hosting ni del script: en compartido, Pure-FTPd presenta el
certificado **del servidor**, no uno por dominio. Aquí es un Let's Encrypt emitido a
**`host303.latinoamericahosting.com`** — leído del propio certificado con
`local-dev/leer-certificado-ftps.py`, que solo hace el saludo TLS y **no envía usuario ni
contraseña**.

La salida correcta es apuntar `FTP_HOST` a ese nombre y **mantener la verificación
completa**. Lo tentador —y peor— es desactivar `check_hostname`: eso deja el tráfico
cifrado pero **sin autenticar**, o sea vulnerable a que alguien se ponga en medio, que es
justo lo que el certificado existe para evitar. Si algún día el proveedor mueve la cuenta
de servidor, el síntoma será el mismo error con otro nombre: se vuelve a leer el
certificado y se actualiza `FTP_HOST`.

---

## 4. Qué haré exactamente con eso

Ejecutaré **`deploy/subir-a-produccion-ftps.py`**. Por cada fichero, en este orden:

1. Descarga el que hay ahora en el servidor → respaldo en `backups/produccion-<fecha>/`.
2. Renombra el remoto a `<nombre>.bak-<fecha>` → segundo respaldo, **en el servidor**.
3. Sube el nuevo a un temporal y lo renombra al nombre final. Es **atómico**: ningún
   visitante ve un fichero a medio subir.
4. Verifica por HTTP que responde **200 y con el tamaño exacto**.
5. Si algo no cuadra, **deshace todo lo de esa pasada** desde los `.bak` y sale con
   error. El sitio queda como estaba.

Es el mismo patrón de la subida del 11/08, con una mejora: entonces se revertía fichero a
fichero; ahora, si falla la verificación de uno, se revierten **todos** los de la pasada,
para que no quede un estado a medias.

### Los 18 ficheros que toca

| Grupo | Ficheros | Destino |
|---|---|---|
| `imagenes` | las 16 de la ronda (10 sobrescritas + 6 nuevas) | `img/it/` |
| `tema` | `custom.css`, `custom.js` | `themes/vt_autosoe_child/assets/` |

Opcional y **no** incluido por defecto: `--solo traducciones` sube los dos `.xlf` es-CO
con las 9 cadenas que se rescataron del espejo el 12/08 (`Disponible`, `Agotado`,
`Registrarse`, los textos del 404…). No va por defecto porque **no puedo comprobar qué
tiene producción**: el servidor devuelve **403** a los `.xlf`, así que no hay forma de
compararlos por HTTP antes de pisarlos. Se sube aparte y a propósito, o no se sube.

### Lo que **no** voy a tocar

`.htaccess`, `parameters.php`, `config/`, los módulos, el núcleo de PrestaShop, `img/p/`
(las fotos de producto que sube el cliente), `img/m/`, ni nada fuera de las dos rutas de
la tabla. El script lleva la lista de ficheros escrita dentro; no hace barridos ni
recursión.

---

## 5. Lo que seguirá siendo manual, aunque tenga el FTP

| Qué | Por qué |
|---|---|
| **El SQL** (`29-imagenes-cliente.sql`) | El hosting no admite MySQL remoto. Va por phpMyAdmin. Sin él, las 6 fotos nuevas no se ven — no se rompe nada, simplemente no se notan. |
| **Vaciar cachés** | Back office → *Parámetros avanzados → Rendimiento*, y purgar **LSCache** en cPanel. Los 10 ficheros sobrescritos conservan el nombre, así que sin purgar se sigue sirviendo el viejo. |
| **La segunda imagen del hero** | Se sube desde *Diseño → Leo Slideshow Configuration*. Sin ella no hay anillo rojo ni autoavance: es el módulo el que los apaga con una sola diapositiva. |

> Podría automatizar el SQL subiendo un PHP con token que lo ejecute y se autoborre —es lo
> que se hizo el 11/08 con `it27-9f4b7c2ad8e1.php`—, pero eso deja un script ejecutable en
> el docroot durante unos minutos y **no lo hago sin que me lo pidas expresamente**.

---

## 6. Comprobación de que lo que subí se está usando de verdad

Después de subir y vaciar cachés, esto es lo que confirma que el servidor sirve **lo
nuevo** y no una copia compilada de antes (la trampa de `compile_check`). Son centinelas
que solo existen en la versión de hoy:

| Fichero servido | Tiene que aparecer |
|---|---|
| `themes/vt_autosoe_child/assets/css/custom.css` | `data-it-hero`, `--it-hero-caja`, `nth-of-type(2)` |
| `themes/vt_autosoe_child/assets/js/custom.js` | `it-hero-alto`, `naturalWidth` |
| la portada | `/img/it/bulto.jpg`, `/img/it/nikatto.jpg`, y **0** apariciones de `banner-med-a.jpg` |
| una categoría | `/img/it/cat-referencias.jpg`, `/img/it/cat-volumen.jpg` |

Las cuatro las compruebo yo automáticamente al terminar.

---

## 7. Marcha atrás, si hiciera falta

| Alcance | Cómo |
|---|---|
| Solo los ficheros de esta subida | `python3 deploy/subir-a-produccion-ftps.py --revertir` (usa los `.bak-<fecha>` del servidor) |
| Los ficheros, desde el respaldo local | `backups/produccion-<fecha>/` |
| El SQL | el propio `29-imagenes-cliente.sql`, §8 |
| Todo | JetBackup en cPanel |
