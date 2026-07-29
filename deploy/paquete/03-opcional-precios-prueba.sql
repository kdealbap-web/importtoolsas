-- ============================================================================
--  OPCIONAL — precios de prueba
--  Los 3.036 productos se cargaron con precios GENERADOS para poder ver la
--  tienda funcionando. Estan marcados con supplier_reference = 'PRECIO-PRUEBA'.
--  Ejecuta UNA de las dos opciones antes de abrir la tienda al publico.
-- ============================================================================

-- OPCION A — ocultar los productos hasta tener precios reales
UPDATE psjy_product      SET active = 0 WHERE supplier_reference = 'PRECIO-PRUEBA';
UPDATE psjy_product_shop SET active = 0
 WHERE id_product IN (SELECT id_product FROM psjy_product WHERE supplier_reference = 'PRECIO-PRUEBA');

-- OPCION B — dejarlos visibles como catalogo, a precio 0 y "consultar precio"
-- UPDATE psjy_product      SET price = 0 WHERE supplier_reference = 'PRECIO-PRUEBA';
-- UPDATE psjy_product_shop SET price = 0
--  WHERE id_product IN (SELECT id_product FROM psjy_product WHERE supplier_reference = 'PRECIO-PRUEBA');
-- UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE';

-- Cuando lleguen los precios reales, se cargan por referencia:
-- UPDATE psjy_product p JOIN psjy_product_shop ps ON ps.id_product = p.id_product
--    SET p.price = 12345, ps.price = 12345, p.supplier_reference = ''
--  WHERE p.reference = 'NIK-10402';
