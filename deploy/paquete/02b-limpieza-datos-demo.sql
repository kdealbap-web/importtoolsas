-- ============================================================================
--  Import Tools Latam S.A.S — limpieza de datos de ejemplo y de ruido del
--  entorno espejo.
--
--  ESTADO: ya aplicado al volcado importtools-FINAL-20260729-*.sql.gz
--          Se conserva por trazabilidad y para poder repetirlo si algun dia se
--          importa un volcado anterior. Si importas el FINAL del 29/07 o
--          posterior, NO hace falta ejecutarlo.
--
--  Prefijo de tablas: psjy_
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) OBLIGATORIO — enlaces absolutos al entorno local dentro de paginas CMS
--    La pagina «Quiero ser cliente» (id_cms 7) tenia dos botones apuntando a
--    http://localhost:8080/... En produccion no habrian llevado a ninguna parte.
--    Se dejan relativos al dominio, asi valen en local y en produccion.
--    Afecta: /login?create_account=1  y  /contact-us  (ambos son las URL
--    amigables reales en es-CO, comprobado en psjy_meta_lang).
-- ---------------------------------------------------------------------------
UPDATE psjy_cms_lang
   SET content = REPLACE(content, 'http://localhost:8080/', '/')
 WHERE content LIKE '%localhost:8080%';

-- ---------------------------------------------------------------------------
-- 2) Ruido de navegacion del entorno espejo
--    1.822 visitas / 1.902 invitados / 1.855 origenes generados por mis propias
--    pruebas en local. Sin esto el cuadro de mando del cliente arranca con
--    estadisticas falsas de julio de 2026.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_connections_page;
DELETE FROM psjy_connections_source;
DELETE FROM psjy_connections;
DELETE FROM psjy_pagenotfound;
DELETE FROM psjy_statssearch;
DELETE FROM psjy_log;

-- ---------------------------------------------------------------------------
-- 2-bis) Configuracion muerta de modulos que ya no existen en PrestaShop 9
--    Restos de la epoca 1.6 que venian arrastrados en la base: guardaban
--    pub@prestashop.com como correo de contacto y un enlace a prestashop.com.
--    Comprobado que NO se muestran en la tienda (los modulos blockcontact y
--    blockcontactinfos no estan instalados; el correo lo sirve ps_contactinfo
--    desde PS_SHOP_EMAIL = ventas@importtoolslatam.com). Se borran para que la
--    base no contenga correos ajenos.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_configuration
 WHERE name IN ('BLOCKCONTACTINFOS_EMAIL', 'BLOCKCONTACT_EMAIL', 'BLOCKADVERT_LINK');
DELETE FROM psjy_configuration_lang
 WHERE id_configuration NOT IN (SELECT id_configuration FROM psjy_configuration);

-- ---------------------------------------------------------------------------
-- 2-ter) GBLEOELEMENTS — atajos del back office del AUTOR del tema
--    Venia en themes/vt_autosoe/samples/leoelements.xml y guardaba enlaces a
--    http://192.168.1.80/prestashop/custom/vt_autosoe/admincp/... con los tokens
--    de esa instalacion, mas la ruta D:\xampp\htdocs\... de su equipo.
--    Solo se usa DENTRO del editor de Elementor, en el aviso «Click to the link
--    to manage slideshow». El cliente los habria visto muertos.
--    Es seguro borrarlo, comprobado en el codigo:
--      · LeoSlideshow.php:188  inicializa a '' y lo lee bajo isset() -> no falla
--      · AdminLeoElementsCreator.php:53  lo REESCRIBE con getAdminLink() la
--        primera vez que se abre el editor -> se regenera con la URL correcta
--        del dominio de produccion.
--    Probado: portada y /2-catalogo a 200, modulos de slideshow (209 KB) y menu
--    (87 KB) cargan sin la fila, 0 errores CRITICAL en el log.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_configuration WHERE name = 'GBLEOELEMENTS';

-- ---------------------------------------------------------------------------
-- 3) Pedidos de ejemplo de PrestaShop
--    Los 5 pedidos son los de la instalacion de muestra (24/07/2026 11:07:54) y
--    sus lineas apuntan a los 19 productos demo ya borrados (camisetas, tazas,
--    posters). En el panel del cliente se veian como 5 ventas inexistentes.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_order_detail;
DELETE FROM psjy_order_detail_tax;
DELETE FROM psjy_order_history;
DELETE FROM psjy_order_carrier;
DELETE FROM psjy_order_invoice;
DELETE FROM psjy_order_invoice_tax;
DELETE FROM psjy_order_invoice_payment;
DELETE FROM psjy_order_payment;
DELETE FROM psjy_order_slip;
DELETE FROM psjy_order_slip_detail;
DELETE FROM psjy_order_cart_rule;
DELETE FROM psjy_orders;

-- ---------------------------------------------------------------------------
-- 4) Carritos
--    5 del cliente demo John DOE + 1 mio de pruebas en local (28/07 20:09).
-- ---------------------------------------------------------------------------
DELETE FROM psjy_cart_product;
DELETE FROM psjy_cart_rule;
DELETE FROM psjy_cart;

-- ---------------------------------------------------------------------------
-- 5) Cliente de ejemplo John DOE (id_customer 2, pub@prestashop.com)
--    OJO: el id_customer 1 «Anonymous» (anonymous@psgdpr.com) NO se borra.
--    Lo crea el modulo de RGPD y el core lo necesita para anonimizar.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_customer_group WHERE id_customer = 2;
DELETE FROM psjy_customer       WHERE id_customer = 2;

-- Direcciones: se conserva solo la del Anonymous (id_address 1).
--   2 y 5 -> John DOE (Paris, Miami)
--   3 y 6 -> proveedores demo (New York, Bayonne)
--   4     -> huerfana, apuntaba al fabricante demo 1 que ya no existe
DELETE FROM psjy_address WHERE id_address IN (2, 3, 4, 5, 6);

-- Invitados (tabla de analitica, se repuebla sola con las visitas reales)
DELETE FROM psjy_guest;

-- ---------------------------------------------------------------------------
-- 6) Hilo de atencion al cliente
--    Es un correo comercial no solicitado que entro por el formulario cuando el
--    sitio servia la demo del tema («Your auto parts business has a strong
--    foundation with 30 years of service...»). No es un cliente.
-- ---------------------------------------------------------------------------
DELETE FROM psjy_customer_message;
DELETE FROM psjy_customer_thread;
DELETE FROM psjy_message;

-- ---------------------------------------------------------------------------
-- 7) Proveedores de ejemplo («Fashion supplier», «Accessories supplier»)
--    Ninguno de los 3.036 productos los usa (psjy_product_supplier = 0 filas).
-- ---------------------------------------------------------------------------
DELETE FROM psjy_product_supplier;
DELETE FROM psjy_supplier_lang;
DELETE FROM psjy_supplier_shop;
DELETE FROM psjy_supplier;

-- ---------------------------------------------------------------------------
-- 8) Contadores. Para que el primer pedido real del cliente sea el numero 1.
-- ---------------------------------------------------------------------------
ALTER TABLE psjy_orders           AUTO_INCREMENT = 1;
ALTER TABLE psjy_order_detail     AUTO_INCREMENT = 1;
ALTER TABLE psjy_order_history    AUTO_INCREMENT = 1;
ALTER TABLE psjy_order_carrier    AUTO_INCREMENT = 1;
ALTER TABLE psjy_order_invoice    AUTO_INCREMENT = 1;
ALTER TABLE psjy_cart             AUTO_INCREMENT = 1;
ALTER TABLE psjy_connections      AUTO_INCREMENT = 1;
ALTER TABLE psjy_guest            AUTO_INCREMENT = 1;
ALTER TABLE psjy_customer         AUTO_INCREMENT = 2;  -- el 1 es Anonymous (RGPD)
ALTER TABLE psjy_address          AUTO_INCREMENT = 2;  -- la 1 es la de Anonymous
ALTER TABLE psjy_supplier         AUTO_INCREMENT = 1;
ALTER TABLE psjy_customer_thread  AUTO_INCREMENT = 1;

-- ---------------------------------------------------------------------------
-- 9) Comprobaciones. Lo esperado esta en la columna de la derecha.
-- ---------------------------------------------------------------------------
SELECT 'productos'          AS concepto, COUNT(*) AS valor, '3036' AS esperado FROM psjy_product
UNION ALL SELECT 'en catalogo (id 2)', COUNT(*), '3036' FROM psjy_category_product WHERE id_category = 2
UNION ALL SELECT 'stock',              COUNT(*), '3036' FROM psjy_stock_available
UNION ALL SELECT 'marcas',             COUNT(*), '7'    FROM psjy_manufacturer
UNION ALL SELECT 'caracteristicas',    COUNT(*), '6072' FROM psjy_feature_product
UNION ALL SELECT 'paginas CMS',        COUNT(*), '7'    FROM psjy_cms
UNION ALL SELECT 'empleados',          COUNT(*), '3'    FROM psjy_employee
UNION ALL SELECT 'pedidos',            COUNT(*), '0'    FROM psjy_orders
UNION ALL SELECT 'clientes',           COUNT(*), '1 (solo Anonymous)' FROM psjy_customer
UNION ALL SELECT 'carritos',           COUNT(*), '0'    FROM psjy_cart
UNION ALL SELECT 'proveedores',        COUNT(*), '0'    FROM psjy_supplier
UNION ALL SELECT 'direcciones',        COUNT(*), '1'    FROM psjy_address
UNION ALL SELECT 'visitas',            COUNT(*), '0'    FROM psjy_connections
UNION ALL SELECT 'CMS con localhost',  COUNT(*), '0'    FROM psjy_cms_lang WHERE content LIKE '%localhost%'
UNION ALL SELECT 'config con prestashop.com', COUNT(*), '0' FROM psjy_configuration WHERE value LIKE '%pub@prestashop%'
UNION ALL SELECT 'config con IP del autor',   COUNT(*), '0' FROM psjy_configuration WHERE value LIKE '%192.168%';

-- Lo que NO limpia este script, a proposito:
--   psjy_leoelements_contents_lang tiene 14 filas (contenidos 1,4,5,8,9,12,13 en
--   los dos idiomas) con URLs a http://192.168.1.80/... dentro del JSON de
--   Elementor, tambien heredadas del leoelements.xml del tema. Comprobado que NO
--   se renderizan: el HTML de portada, catalogo, categoria, marcas y quienes
--   somos tiene 0 apariciones de 192.168. Editar ese JSON por SQL es justo lo que
--   corrompe los contenidos de Leo (ver CLAUDE.md), asi que se dejan como estan.

-- NOTA: las tablas de visitas se repueblan con cada visita a la tienda. Si
-- vuelves a navegar por el front despues de ejecutar esto y luego generas un
-- volcado, apareceran de nuevo. Ejecuta la limpieza justo antes de volcar.
