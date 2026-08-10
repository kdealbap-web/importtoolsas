# Originales que mandó el cliente

Material de origen, **no se sube al servidor**. De aquí se recortan y optimizan los
ficheros que sí van, que viven en `deploy/img/it/`.

| Original | Peso | De aquí sale |
|---|---|---|
| `Cliente.png` | 1,3 MB | `it/hero-cliente.jpg` |
| `Quienes somos.jpeg` | 2,0 MB | `it/hero-quienes-somos.jpg` |
| `Quienes somos.jpg.jpeg` | 7,3 MB | La maqueta completa (4500×6211) de la que se recortaron las seis fotos de las dos páginas |
| `Call center-01.png` | 28 KB | `it/ico-asesor.png` (reducido de 652×652 a 144×144) |
| `Mail.png` | 19 KB | `it/ico-correo.png` |
| `footer_imagen.png` | 142 KB | `it/pie-asesor.png` |
| `bancos/` | 40 KB | `it/pagos-autorizados.png` (Bancolombia, Banco de Bogotá y Davivienda, 530×282 cada uno) |

## Por qué están fuera de `deploy/img/`

Antes vivían dentro, y `local-dev/empaquetar.py` llevaba una lista de exclusiones para
que no acabaran en el zip de imágenes: 3,6 MB que ninguna página usa. Esa lista había
que **acordarse** de mantenerla cada vez que el cliente mandaba un original nuevo.

Ahora la regla no tiene excepciones: **todo lo que está en `deploy/img/` sube al
servidor, y todo lo que es material de origen está aquí.** La lista de exclusiones se
eliminó del empaquetador.
