-- ============================================================================
--  Import Tools Latam S.A.S — TRANSPORTISTAS PARA COLOMBIA
--
--  ⚠️ ESTE SCRIPT NO ESTA APLICADO. Resuelve un problema REAL y ACTUAL:
--
--      Hoy NADIE en Colombia puede completar un pedido.
--
--  El carrito funciona, los precios se ven, el checkout como invitado esta
--  activado... y al llegar al paso «Metodo de envio» no hay ninguna opcion, asi
--  que el pedido no se puede terminar.
--
--  Comprobado el 29/07/2026 en el entorno espejo, con la API del core:
--      Carrier::getCarriersForOrder(6)  -> 0 transportistas   (6 = zona de Colombia)
--      Carrier::getCarriersForOrder(1)  -> si encuentra        (1 = Europe)
--      Carrier::getCarriersForOrder(2)  -> si encuentra        (2 = North America)
--
--  Causa: los 4 transportistas son los de ejemplo de PrestaShop y solo cubren
--  Europa y Norteamerica. Colombia esta en la zona 6 («South America»), que no
--  tiene ni un transportista asociado ni una sola tarifa:
--
--      psjy_carrier_zone -> zonas 1 y 2 unicamente
--      psjy_delivery     -> 0 filas para la zona 6
--
--  Prefijo de tablas: psjy_
-- ============================================================================


-- ---------------------------------------------------------------------------
-- DIAGNOSTICO — ejecutar primero, es solo lectura
-- ---------------------------------------------------------------------------
SELECT 'zona de Colombia'      AS dato, CAST(c.id_zone AS CHAR) AS valor, z.name AS detalle
  FROM psjy_country c JOIN psjy_zone z ON z.id_zone = c.id_zone WHERE c.iso_code = 'CO'
UNION ALL
SELECT 'transportistas que la cubren', CAST(COUNT(*) AS CHAR), 'si es 0, nadie puede pedir'
  FROM psjy_carrier ca JOIN psjy_carrier_zone cz ON cz.id_carrier = ca.id_carrier
 WHERE ca.active = 1 AND ca.deleted = 0
   AND cz.id_zone = (SELECT id_zone FROM psjy_country WHERE iso_code = 'CO')
UNION ALL
SELECT 'tarifas para esa zona', CAST(COUNT(*) AS CHAR), 'psjy_delivery'
  FROM psjy_delivery WHERE id_zone = (SELECT id_zone FROM psjy_country WHERE iso_code = 'CO')
UNION ALL
SELECT 'modo catalogo', value, '1 = sin carrito ni checkout'
  FROM psjy_configuration WHERE name = 'PS_CATALOG_MODE';


-- ============================================================================
--  OPCION A — Modo catalogo CON precios  ★ RECOMENDADA
--
--  Dos filas, reversible al instante. Quita el carrito y el checkout, pero
--  **mantiene los precios visibles**, que es lo que se decidio el 29/07.
--
--  ⚠️ Son DOS ajustes, no uno. Con `PS_CATALOG_MODE = 1` a secas, PrestaShop
--     tambien OCULTA los precios: `ProductListingFrontController.php:344` hace
--         if (PS_CATALOG_MODE && !PS_CATALOG_MODE_WITH_PRICES) -> quita el precio
--     Asi que hay que poner el segundo a 1 tambien.
--
--  Comprobado en el espejo con las dos a 1:
--      /2-catalogo            -> «Hay 3036 productos», precios visibles
--      botones add-to-cart    -> 0        · bloque del carrito -> 0
--      ficha de producto      -> precio 84.300, div de añadir al carrito VACIO
--      /17-herramientas-...   -> filtros intactos
--      /login?create_account=1 -> el registro sigue funcionando (captacion de leads)
--
--  Y no es cosmetico, el controlador tambien lo aplica:
--      /cart?add=1&id_product=20&token=...  -> psjy_cart_product se queda en 0 filas
--      /order                               -> redirige a la portada
-- ============================================================================
-- UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE';
-- UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_CATALOG_MODE_WITH_PRICES';
--
-- Para volver atras (cuando haya precios reales y transportista):
-- UPDATE psjy_configuration SET value = '0' WHERE name IN ('PS_CATALOG_MODE','PS_CATALOG_MODE_WITH_PRICES');


-- ============================================================================
--  OPCION B — Un transportista real para Colombia
--
--  Lo correcto, pero necesita los datos del cliente: cobertura (¿todo el pais o
--  solo Atlantico?), tarifas y plazos. Es el pendiente abierto de §10.
--
--  Lo mas practico en venta al por mayor: un transportista a coste 0 llamado
--  «Coordinar con un asesor», y el flete se cotiza aparte. Asi el pedido se
--  puede cerrar y el equipo comercial llama.
--
--  ⚠️ Cuatro trampas, todas comprobadas en el espejo — si fallas una, el
--     transportista NO aparece y PrestaShop no da ningun error:
--
--   1. Hay que insertar en psjy_carrier_zone Y en psjy_delivery. Solo la zona
--      no basta.
--   2. En psjy_delivery, `id_shop` e `id_shop_group` van a NULL. Las filas que
--      funcionan (las de Europa) los tienen a NULL; poniendolos a 1 el
--      transportista se descarta.
--   3. El rango tiene que ser DEL PROPIO transportista. Cada uno tiene sus
--      psjy_range_weight / psjy_range_price; usar el de otro no sirve.
--   4. **El rango debe coincidir con como factura el transportista.** Si factura
--      por peso hay que rellenar `id_range_weight` (y dejar id_range_price = 0);
--      si factura por precio, al contrario. `psjy_carrier.shipping_method = 0`
--      significa «usar el valor global», que aqui es `PS_SHIPPING_METHOD = 1`,
--      o sea **por peso**. Esto me costo tres intentos: con el rango de precio
--      `getMaxDeliveryPriceByWeight()` devolvia false y el transportista
--      desaparecia sin mas.
--
--  Como comprobar cual es el metodo, antes de insertar:
--      SELECT id_carrier, name, shipping_method FROM psjy_carrier WHERE deleted = 0;
--      SELECT value FROM psjy_configuration WHERE name = 'PS_SHIPPING_METHOD';
-- ============================================================================

-- -- B.1 Crear el transportista
-- INSERT INTO psjy_carrier
--   (id_reference, id_tax_rules_group, name, url, active, deleted, shipping_handling,
--    range_behavior, is_module, is_free, shipping_external, need_range, external_module_name,
--    shipping_method, position, max_width, max_height, max_depth, max_weight, grade)
--   VALUES (0, 0, 'Coordinar con un asesor', '', 1, 0, 0, 0, 0, 1, 0, 0, '', 0, 0, 0, 0, 0, 0, 0);
-- SET @c := LAST_INSERT_ID();
-- UPDATE psjy_carrier SET id_reference = @c WHERE id_carrier = @c;
--
-- -- B.2 Nombre y plazo visibles en el checkout
-- INSERT INTO psjy_carrier_lang (id_carrier, id_shop, id_lang, delay)
--   SELECT @c, 1, id_lang, 'Nuestro equipo coordina el envío y le confirma el flete' FROM psjy_lang;
--
-- -- B.3 Asociar a la tienda y a los 3 grupos de clientes
-- INSERT INTO psjy_carrier_shop (id_carrier, id_shop) VALUES (@c, 1);
-- INSERT INTO psjy_carrier_group (id_carrier, id_group) SELECT @c, id_group FROM psjy_group;
--
-- -- B.4 Rango de PESO propio (0 a 10.000 kg = todo)
-- INSERT INTO psjy_range_weight (id_carrier, delimiter1, delimiter2) VALUES (@c, 0, 10000);
-- SET @rw := LAST_INSERT_ID();
--
-- -- B.5 Zona de Colombia + tarifa a 0. OJO al NULL de id_shop (trampa 2).
-- INSERT INTO psjy_carrier_zone (id_carrier, id_zone)
--   SELECT @c, id_zone FROM psjy_country WHERE iso_code = 'CO';
-- INSERT INTO psjy_delivery (id_carrier, id_shop, id_shop_group, id_zone, id_range_price, id_range_weight, price)
--   SELECT @c, NULL, NULL, (SELECT id_zone FROM psjy_country WHERE iso_code = 'CO'), 0, @rw, 0;
--
-- -- B.6 Dejarlo como transportista por defecto
-- UPDATE psjy_configuration SET value = @c WHERE name = 'PS_CARRIER_DEFAULT';
--
-- -- B.7 Desactivar los 4 de ejemplo, que prometen cosas falsas en ingles
-- --     («Delivery next day!», «Pick up in-store»)
-- UPDATE psjy_carrier SET active = 0 WHERE id_carrier IN (1, 2, 3, 4);


-- ---------------------------------------------------------------------------
-- COMPROBACION despues de aplicar la opcion B
-- ---------------------------------------------------------------------------
-- SELECT ca.id_carrier, ca.name, ca.active, cl.delay,
--        (SELECT COUNT(*) FROM psjy_carrier_zone z WHERE z.id_carrier = ca.id_carrier
--           AND z.id_zone = (SELECT id_zone FROM psjy_country WHERE iso_code='CO')) AS cubre_colombia,
--        (SELECT COUNT(*) FROM psjy_delivery d WHERE d.id_carrier = ca.id_carrier
--           AND d.id_zone = (SELECT id_zone FROM psjy_country WHERE iso_code='CO')) AS tarifas
--   FROM psjy_carrier ca LEFT JOIN psjy_carrier_lang cl ON cl.id_carrier = ca.id_carrier AND cl.id_lang = 2
--  WHERE ca.deleted = 0;
--
-- Y en la tienda: añadir un producto al carrito y llegar al paso «Método de
-- envío». Debe aparecer al menos una opcion. Vaciar var/cache/ antes.
