-- ============================================================================
--  Importtools S.A.S — abrir la tienda al público
--  UNA sola línea, en un fichero aparte a propósito: es el único paso del
--  despliegue que no se puede deshacer sin que alguien lo haya visto.
--  Ejecutar cuando §7 y §8 del paso a paso estén comprobados.
-- ============================================================================

UPDATE psjy_configuration SET value = '1' WHERE name = 'PS_SHOP_ENABLE';

SELECT name, value FROM psjy_configuration WHERE name = 'PS_SHOP_ENABLE';
-- Tiene que devolver 1. Abre la tienda en una ventana de incógnito para
-- confirmarlo: con tu sesión de administrador la verías bien de todas formas.
