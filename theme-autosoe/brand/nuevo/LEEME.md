# Favicon nuevo — base «Icono Import.png» del cliente

Generado el 31/07/2026 desde `Icono Import.png` (355×355), que el cliente dejó como base.
Único cambio sobre el original: **esquinas redondeadas** al 20 % del lado.

| Fichero | Para qué |
|---|---|
| `favicon.ico` | **El que va a producción.** 4 tamaños: 16, 32, 48 y 64 px, 32 bits con alfa |
| `icono-32.png` | Navegadores que prefieren PNG |
| `icono-96.png` | Android / atajos |
| `icono-180.png` | `apple-touch-icon` de iOS |
| `icono-512.png` | PWA y manifiestos |

## Cómo se hizo

A 1024 px y reduciendo desde ahí: el suavizado de las esquinas sale del remuestreo, que promedia
decenas de píxeles por cada uno de salida. Un recorte directo a 16 px habría dejado el borde
dentado.

El rojo de marca se conserva sin tocar: **`#E11F1C`**, muestreado del original.

## Instalación en producción

```
public_html/img/favicon.ico          ← sustituir
```

⚠️ **Después hay que romper la caché del navegador.** El tema pide el icono como
`img/favicon.ico?{$shop.favicon_update_time}`, y ese número sale de `PS_IMG_UPDATE_TIME`
(`FrontController.php:1741`). Si no cambia, los navegadores siguen sirviendo el icono viejo:

```sql
UPDATE psjy_configuration SET value = UNIX_TIMESTAMP() WHERE name = 'PS_IMG_UPDATE_TIME';
```

Subirlo por **Diseño → Tema y logotipo** también actualiza ese valor solo.

## Comprobado

- Estructura del `.ico` releída entrada por entrada: 4 entradas, 32 bits, offsets coherentes,
  32.038 bytes.
- Cada entrada **decodificada de vuelta a PNG** para confirmar que el codificador no la corrompió.
- Esquinas con alfa 127 (transparentes), centro opaco.
- Servido en el espejo: HTTP 200, `image/vnd.microsoft.icon`, byte a byte idéntico al generado.
