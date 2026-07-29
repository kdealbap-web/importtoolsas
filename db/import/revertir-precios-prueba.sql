-- ============================================================================
-- REVERTIR LOS PRECIOS DE PRUEBA — ejecutar ANTES de publicar en producción
-- ============================================================================
-- Contexto: el catálogo se cargó desde `docs/Productos activos import.xlsx`, que
-- NO trae precios. Para poder validar el diseño con datos reales se generaron
-- precios de PRUEBA deterministas por rango de categoría (ver
-- `db/import/clasificacion-productos.csv`, columna `precio_prueba_cop`).
--
-- Todos esos productos quedaron marcados con:
--     supplier_reference = 'PRECIO-PRUEBA'
-- para poder revertirlos con precisión sin tocar productos con precio real.
--
-- Prefijo de tablas: psjy_
--
-- USO
--   1. Ejecuta el bloque 0 para ver cuántos productos están afectados.
--   2. Elige UNA de las dos opciones (A o B) y descomenta su bloque.
--   3. Vacía la caché de PrestaShop después (`var/cache/`).
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 0. DIAGNÓSTICO (solo lectura) — ejecutar siempre primero
-- ---------------------------------------------------------------------------
SELECT
    COUNT(*)                                                   AS productos_totales,
    SUM(supplier_reference = 'PRECIO-PRUEBA')                   AS con_precio_de_prueba,
    SUM(supplier_reference <> 'PRECIO-PRUEBA' OR supplier_reference IS NULL) AS con_precio_real,
    SUM(active = 1)                                             AS activos,
    MIN(price)                                                  AS precio_min,
    MAX(price)                                                  AS precio_max
FROM psjy_product;


-- ---------------------------------------------------------------------------
-- OPCIÓN A — DESACTIVAR los productos de prueba (recomendada)
-- ---------------------------------------------------------------------------
-- Los productos dejan de verse en la tienda pero conservan su categoría,
-- referencia y stock. Cuando lleguen los precios reales se actualiza el precio
-- por `reference` y se reactivan por lotes. Es la opción reversible.
--
-- UPDATE psjy_product      SET active = 0 WHERE supplier_reference = 'PRECIO-PRUEBA';
-- UPDATE psjy_product_shop SET active = 0
--   WHERE id_product IN (SELECT id_product FROM psjy_product WHERE supplier_reference = 'PRECIO-PRUEBA');


-- ---------------------------------------------------------------------------
-- OPCIÓN B — PONER LOS PRECIOS A 0 y dejarlos visibles sin precio
-- ---------------------------------------------------------------------------
-- Útil si el cliente quiere un catálogo navegable en modo "solicitar cotización"
-- mientras define precios. Requiere además desactivar la compra:
--
-- UPDATE psjy_product      SET price = 0, available_for_order = 0, show_price = 0
--   WHERE supplier_reference = 'PRECIO-PRUEBA';
-- UPDATE psjy_product_shop SET price = 0, available_for_order = 0, show_price = 0
--   WHERE id_product IN (SELECT id_product FROM psjy_product WHERE supplier_reference = 'PRECIO-PRUEBA');


-- ---------------------------------------------------------------------------
-- LIMPIAR LA MARCA (solo cuando ya tengan precio real)
-- ---------------------------------------------------------------------------
-- Deja de identificarlos como productos de prueba. Hacerlo únicamente después
-- de haber cargado los precios definitivos, o se pierde la trazabilidad.
--
-- UPDATE psjy_product SET supplier_reference = '' WHERE supplier_reference = 'PRECIO-PRUEBA';


-- ---------------------------------------------------------------------------
-- CARGAR PRECIOS REALES cuando llegue el archivo del cliente
-- ---------------------------------------------------------------------------
-- Los productos se identifican por `reference`, que es el `codigo` del Excel.
-- Ejemplo con una tabla temporal:
--
-- CREATE TEMPORARY TABLE tmp_precios (codigo VARCHAR(64), precio DECIMAL(20,6));
-- -- ... cargar el archivo del cliente en tmp_precios ...
-- UPDATE psjy_product p
--   JOIN tmp_precios t ON t.codigo = p.reference
--    SET p.price = t.precio, p.supplier_reference = '';
-- UPDATE psjy_product_shop ps
--   JOIN psjy_product p ON p.id_product = ps.id_product
--   JOIN tmp_precios t  ON t.codigo = p.reference
--    SET ps.price = t.precio;
--
-- Después: vaciar `var/cache/` y reconstruir el índice de búsqueda desde
-- Back office → Parámetros de la tienda → Buscar → Reconstruir el índice.
