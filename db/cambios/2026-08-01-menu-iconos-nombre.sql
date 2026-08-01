-- ============================================================================
--  Cambios pedidos por el cliente el 01/08/2026
--  Aplicados y verificados en el entorno espejo.
-- ============================================================================

-- 1) Iconos del menu principal. psjy_btmegamenu ya trae columna icon_class y la
--    plantilla la pinta: no hay que tocar plantillas. Font Awesome light es el
--    que el tema ya carga.
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-house'               WHERE id_btmegamenu=1;   -- INICIO
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-grid-2'              WHERE id_btmegamenu=8;   -- CATEGORIAS
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-tags'                WHERE id_btmegamenu=61;  -- MARCAS
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-screwdriver-wrench'  WHERE id_btmegamenu=44;  -- CATALOGO
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-handshake'           WHERE id_btmegamenu=45;  -- QUIERO SER CLIENTE
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-building'            WHERE id_btmegamenu=10;  -- QUIENES SOMOS
UPDATE psjy_btmegamenu SET icon_class='fa-light fa-headset'             WHERE id_btmegamenu=20;  -- CONTACTO

-- 2) Nombre comercial: fuera «Latam»
UPDATE psjy_configuration SET value='Importtools S.A.S' WHERE name='PS_SHOP_NAME';
UPDATE psjy_shop          SET name ='Importtools S.A.S' WHERE id_shop=1;

--    NO se cambian, a proposito:
--      PS_SHOP_EMAIL         ventas@importtoolslatam.com  (decision del cliente)
--      BLOCKSOCIAL_INSTAGRAM importtoolslatam             (cuenta real)

-- 3) Fuera el enlace de Blog del header (el lapicito). Se desengancha el modulo
--    del hook en vez de editar su plantilla, que se perderia al actualizarlo.
DELETE hm FROM psjy_hook_module hm
  JOIN psjy_hook h   ON h.id_hook   = hm.id_hook
  JOIN psjy_module m ON m.id_module = hm.id_module
 WHERE m.name = 'leoblog' AND h.name = 'displayTop';

-- 4) Tras cualquier cambio de contenido de Leo, la cache de CSS vive en la base
DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';

-- 5) Comprobaciones
SELECT m.position AS pos, l.title, m.icon_class
  FROM psjy_btmegamenu m
  JOIN psjy_btmegamenu_lang l ON l.id_btmegamenu = m.id_btmegamenu AND l.id_lang = 2
 WHERE m.id_group = 1 AND m.id_parent = 0 AND m.active = 1 ORDER BY m.position;

SELECT 'nombre' AS que, value AS valor FROM psjy_configuration WHERE name='PS_SHOP_NAME'
UNION ALL SELECT 'blog en displayTop (debe ser 0)', CAST(COUNT(*) AS CHAR)
  FROM psjy_hook_module hm JOIN psjy_hook h ON h.id_hook=hm.id_hook
  JOIN psjy_module m ON m.id_module=hm.id_module
 WHERE m.name='leoblog' AND h.name='displayTop'
UNION ALL SELECT 'contenidos Leo con JSON roto (debe ser 0)', CAST(COUNT(*) AS CHAR)
  FROM psjy_leoelements_contents_lang WHERE JSON_VALID(content)=0;

-- ============================================================================
--  El texto del pie se cambio con str_replace sobre el JSON de Elementor, sin
--  recodificarlo. Ojo: en el JSON las barras van escapadas, asi que </span> se
--  guarda como <\/span> — buscar sin escapar no encuentra nada y falla en
--  silencio. La linea legal quedo:
--    «Importtools S.A.S — Import Tools Latam S.A.S, NIT 901.353.663-6»
--  con la razon social junto al NIT, que es a quien esta registrado.
-- ============================================================================
