# Carpeta de entrada — deja aquí lo que quieres que revise

Cuatro ficheros. Con el `03` y el `04` ya puedo auditar casi todo.

| Fichero | Cómo se obtiene |
|---|---|
| `01-dump-produccion.sql.gz` | phpMyAdmin → la base de datos → **Exportar** → SQL, compresión **gzip** |
| `02-log-errores.txt` | Administrador de archivos → `var/logs/` → abre `prod-2026-07-XX.log`, copia las últimas ~100 líneas |
| `03-portada.html` | Abre la tienda → **clic derecho → Ver código fuente** → guarda todo aquí |
| `04-notas.txt` | Dos líneas: qué hiciste y qué viste raro |

Si puedes, añade también el código fuente de estas páginas (mismo método):

- `05-catalogo.html` → `/2-catalogo`
- `06-registro.html` → `/login?create_account=1`

**Por qué el HTML es lo más útil:** leer lo que sirve el servidor es la única forma fiable de
detectar problemas reales. Así aparecieron los 140 «Quick view» en inglés que una auditoría de
ficheros de traducción no detectó.

> ⚠️ El `01-dump-produccion.sql.gz` lleva hashes de contraseñas y datos de clientes.
> `.gitignore` ya excluye `*.sql.gz`, así que **no se sube al repositorio**. Se queda en tu disco.
