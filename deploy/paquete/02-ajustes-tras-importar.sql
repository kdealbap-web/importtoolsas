-- ============================================================================
--  Import Tools Latam S.A.S — ajustes OBLIGATORIOS despues de importar el
--  volcado importtools-completo-*.sql en el servidor de produccion.
--  Ejecutar en phpMyAdmin sobre la base de datos de la tienda.
--  Prefijo de tablas: psjy_
-- ============================================================================

-- 1) Dominio de la tienda. El volcado viene del entorno local (localhost:8080).
--    Sustituye www.importtoolsas.com si el dominio definitivo fuera otro.
UPDATE psjy_shop_url
   SET domain     = 'www.importtoolsas.com',
       domain_ssl = 'www.importtoolsas.com',
       physical_uri = '/',
       virtual_uri  = ''
 WHERE id_shop = 1;

UPDATE psjy_configuration SET value = 'www.importtoolsas.com' WHERE name = 'PS_SHOP_DOMAIN';
UPDATE psjy_configuration SET value = 'www.importtoolsas.com' WHERE name = 'PS_SHOP_DOMAIN_SSL';

-- 2) HTTPS. En local estaba desactivado; en produccion hay certificado.
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SSL_ENABLED';
UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SSL_ENABLED_EVERYWHERE';

-- 3) Vaciar la cache de CSS de Elementor. IMPRESCINDIBLE: si no se hace, el sitio
--    sirve el CSS generado en local (con rutas y colores antiguos).
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';

-- 4) Comprobaciones rapidas (deben devolver lo indicado)
--    a) 3036 productos, todos en la categoria raiz Catalogo
SELECT (SELECT COUNT(*) FROM psjy_product)                             AS productos,
       (SELECT COUNT(*) FROM psjy_category_product WHERE id_category=2) AS en_catalogo,
       (SELECT COUNT(*) FROM psjy_manufacturer)                        AS marcas,
       (SELECT COUNT(*) FROM psjy_feature_product)                     AS caracteristicas;
--    b) el idioma debe ser es-CO con iso 'es'
SELECT id_lang, iso_code, locale, active FROM psjy_lang;
--    c) el menu principal
SELECT m.position, l.title FROM psjy_btmegamenu m
  JOIN psjy_btmegamenu_lang l ON l.id_btmegamenu = m.id_btmegamenu AND l.id_lang = 2
 WHERE m.id_group = 1 AND m.id_parent = 0 AND m.active = 1 ORDER BY m.position;
