-- ===========================================================================
-- 16 — Mejoras pedidas por el cliente · 08/08/2026
-- Documento «MejorasImportools_docv2.docx»
-- ---------------------------------------------------------------------------
-- Ejecutar en phpMyAdmin sobre la base de producción, DESPUÉS de subir los
-- ficheros de esta ronda. Prefijo real: psjy_
--
-- Todo lo de aquí es reversible; al final de cada bloque está la marcha atrás.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- 16.1  MARCAS: fuera Proto, Irwin y Grainger del menú
-- ---------------------------------------------------------------------------
-- El cliente: «Quitar de esas marcas: Proto, Grainger, Irwin».
-- Se DESACTIVAN los items del menú (active = 0); NO se borra el fabricante ni
-- se toca ningún producto, que es lo acordado. Reversible con un UPDATE.
--
-- ⚠️ Se desactivan los ITEMS, nunca `psjy_btmegamenu_group.active`: marcar el
--    grupo como inactivo tumba el menú entero, porque `cacheGroupsByFields()`
--    es una caché estática compartida (comprobado en su día con prueba A/B).
--
-- Consecuencia que el cliente ya conoce y aceptó: como el fabricante sigue
-- existiendo, esas tres marcas siguen saliendo en el filtro lateral del
-- catálogo y en la ficha de sus 16 productos («Marca: Proto»). Si algún día se
-- quiere que desaparezcan del todo, hay que desactivar el fabricante.

SELECT '--- ANTES ---' AS ``;
SELECT m.id_btmegamenu, ml.title, m.active
  FROM psjy_btmegamenu m
  JOIN psjy_btmegamenu_lang ml ON ml.id_btmegamenu = m.id_btmegamenu AND ml.id_lang = 2
 WHERE m.id_parent = 61 ORDER BY m.position;

UPDATE psjy_btmegamenu
   SET active = 0
 WHERE id_btmegamenu IN (
   SELECT id_btmegamenu FROM (
     SELECT m.id_btmegamenu
       FROM psjy_btmegamenu m
       JOIN psjy_btmegamenu_lang ml ON ml.id_btmegamenu = m.id_btmegamenu AND ml.id_lang = 2
      WHERE m.id_parent = 61 AND ml.title IN ('Proto', 'Irwin', 'Grainger')
   ) AS t
 );

SELECT '--- DESPUES (Proto, Irwin y Grainger deben salir con active = 0) ---' AS ``;
SELECT m.id_btmegamenu, ml.title, m.active
  FROM psjy_btmegamenu m
  JOIN psjy_btmegamenu_lang ml ON ml.id_btmegamenu = m.id_btmegamenu AND ml.id_lang = 2
 WHERE m.id_parent = 61 ORDER BY m.position;

-- Marcha atrás:
--   UPDATE psjy_btmegamenu SET active = 1 WHERE id_parent = 61;
