# Histórico del paquete de despliegue

Aquí están los pasos **ya ejecutados** de rondas anteriores. Se conservan por
trazabilidad —explican por qué la tienda está como está— pero **no forman parte del
entregable**: nada de esta carpeta hay que volver a ejecutar.

Para desplegar, el operativo vigente es **`../23-PASO-A-PASO-20260809.md`**.

| Fichero | Ronda | Qué hizo |
|---|---|---|
| `00-PROGRESO-CLIENTE.md` | 29/07 | Informe de avance para el cliente |
| `00-RESULTADOS-produccion-20260729.txt` | 29/07 | Salida real de las comprobaciones del despliegue nº 1 |
| `01-LEEME-DESPLIEGUE.md` | 29/07 | Primer operativo, sustituido por el 14 y luego por el 23 |
| `03-opcional-precios-prueba.sql` | 28/07 | Generó los precios de prueba (`supplier_reference = 'PRECIO-PRUEBA'`) |
| `04-PLAN-IMPORTACION.md` | 31/07 | Plan de importación del catálogo real (3.036 productos) |
| `08-quitar-latam.php` | 01/08 | Quitó «Latam» del nombre visible de la tienda |
| `09-acceso-cotizacion-cabecera.php` | 01/08 | Añadió el acceso a la cotización en la cabecera |
| `10-corregir-marca-nikato.php` | 01/08 | NIKATTO → Nikato |
| `11-PLAN-FASE-II.md` | 01/08 | Plan de la Fase II |
| `12-imagenes-del-cliente.php` | 03/08 | Medios de pago reales y foto del asesor en el pie |
| `13-PLAN-SUBIDA-20260803.md` | 03/08 | Qué cambió en la ronda del 03/08 |
| `14-PASO-A-PASO-SUBIDA.md` | 03/08 | Operativo del despliegue nº 2 (ejecutado) |
| `18-PASO-A-PASO-20260808.md` | 08/08 | Operativo que **no se ejecutó**: sustituido por el 23 al medir producción. Su §6 sigue siendo la mejor explicación del fallo del slideshow |
| `favicon-paquete.ico` | 31/07 | Favicon anterior. El vigente es `deploy/img/favicon.ico` (comprobado: es el que sirve producción) |
| `traducciones-EXTRAER-EN-*.zip` | 31/07 | Catálogo **es-CO del núcleo** de PrestaShop (170 XLIFF). Ya aplicado. ⚠️ **No se reconstruye desde este repositorio**: viene de una release de PrestaShop, no lo generamos nosotros. Por eso se guardan en vez de borrarlos |

> Lo que sí sigue vigente y vive un nivel arriba: el operativo `23`, el plan `19`, el
> correo (`20` y `21`), los scripts de esta ronda (`15`, `16`, `17`, `22`), los de caché
> (`14a`/`14b`/`14c`) y los de montaje nuevo o pendientes (`00-comprobacion`, `02`, `02b`,
> `02c`, `06` precios, `07` transportistas).
