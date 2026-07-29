# Traducciones — referencia

Copias legibles de lo que va dentro de `deploy/paquete/`. **El origen de verdad es el
paquete**; esto está aquí para poder comparar y para no perder los originales.

| Fichero | Qué es |
|---|---|
| `FABRICANTE-original-leoproductsearch-es.php` | El `es.php` que **trae el tema** para `leoproductsearch`: 17 claves, todas con prefijo `<{leoproductsearch}prestashop>`. Es el original a conservar antes de sobrescribir |
| `leoproductsearch-es.php` | El nuestro: las 17 del fabricante **sin cambiar ninguna** + 8 con prefijo `vt_autosoe` y `vt_autosoe_child` |
| `leoelements-es.php` | 564 claves. El fabricante **no trae traducciones** de este módulo (su carpeta solo tiene `index.php`), y es la razón por la que la tienda salía en inglés |
| `child-ShopThemeGlobal.es-CO.xlf` | Catálogo del tema hijo. Incluye los 3 textos de la **página 404** |
| `child-ShopThemeActions.es-CO.xlf` | Catálogo del tema hijo. Incluye **«Vista rápida»**, que es lo que piden las 15 plantillas de listado con `d='Shop.Theme.Actions'` |

Comprobación de que sobrescribir `leoproductsearch` no pierde nada:

```
claves del fabricante : 17
claves nuestras       : 25
se perderian          : 0
traducciones cambiadas: 0
```
