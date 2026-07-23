# db/import/ — Importación de catálogo a PrestaShop

Plantilla y guía para cargar el catálogo inicial del cliente.

## Archivo
- `plantilla_catalogo.csv` — plantilla base con 2 filas de ejemplo.
  - **Separador de campos:** `;` (punto y coma — el predeterminado de PrestaShop).
  - **Codificación:** UTF-8.
  - **Precios:** sin IVA (el impuesto lo aplica la regla `IVA 19%`).

## Columnas
| Columna | Descripción | Campo PrestaShop |
|---|---|---|
| `Referencia` | SKU / código interno | Reference |
| `Nombre` | Nombre del producto | Name |
| `Categorias` | Categoría(s), separadas por coma si son varias | Categories |
| `Precio_sin_IVA` | Precio base sin impuestos (COP) | Price tax excluded |
| `Regla_impuesto` | Regla de impuesto a aplicar | Tax rule |
| `Cantidad` | Stock inicial | Quantity |
| `Marca` | Fabricante | Manufacturer |
| `EAN13` | Código de barras (opcional) | EAN13 |
| `Peso_kg` | Peso para cálculo de envío | Weight |
| `Descripcion_corta` | Resumen (listados) | Short description |
| `Descripcion` | Descripción completa | Description |
| `URLs_imagenes` | URL(s) de imagen, separadas por coma | Image URLs |
| `Activo` | 1 = visible, 0 = oculto | Active |

## Cómo importar (Back-office)
1. **Catálogo → Importar**.
2. Tipo de entidad: **Productos**.
3. Subir el CSV, separador de campos `;`, codificación UTF-8.
4. **Mapear** cada columna con su campo PrestaShop (la primera vez).
5. Importar en modo prueba primero; luego importación real.

> ⚠️ Vigilar **inodos (~200.000)** en el plan H2: PrestaShop genera varias miniaturas por
> producto e imagen. Catálogos grandes pueden acercarse al límite → upgrade a H3 si aplica.
