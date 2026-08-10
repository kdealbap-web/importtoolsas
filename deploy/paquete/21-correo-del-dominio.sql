-- ===========================================================================
-- 21 — Correo de la tienda: direcciones del propio dominio · 08/08/2026
-- ---------------------------------------------------------------------------
-- Explicación completa en `20-CORREO-DEL-DOMINIO.md`. En corto:
--
--   La tienda vive en `importtoolsas.com` pero enviaba TODO como
--   `ventas@importtoolslatam.com`, que es otro dominio y no está en este cPanel.
--   Al recibir, Gmail y Outlook comprueban SPF, DKIM y DMARC —que miran si quien
--   envía tiene permiso para usar ese remitente—, no cuadra, y el mensaje acaba
--   en spam o rechazado. Por eso «Olvidé mi contraseña» no llegaba.
--
-- ⚠️ ANTES de ejecutar esto hay que haber creado las cuentas en cPanel:
--      no-reply@importtoolsas.com   (remitente del sistema, nadie la lee)
--      ventas@importtoolsas.com     (buzón real del asesor)
--    Si no existen, los correos saldrán con un remitente inexistente y será peor
--    que antes: los rebotes no llegarán a ninguna parte.
--
-- ⚠️ El METODO de envío (SMTP) NO se toca aquí: se configura en el back office,
--    en Parámetros avanzados → Correo electrónico, porque la contraseña no debe
--    quedar escrita en un fichero del repositorio.
--
-- Prefijo real: psjy_
-- ===========================================================================


SELECT '--- ANTES ---' AS ``;
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_SHOP_EMAIL','PS_MAIL_METHOD','PS_MAIL_DKIM_ENABLE');
SELECT c.id_contact, c.email, cl.name
  FROM psjy_contact c
  LEFT JOIN psjy_contact_lang cl ON cl.id_contact = c.id_contact AND cl.id_lang = 2;


-- --------------------------------------------------------------------------
-- 1. Remitente de todos los correos automáticos
-- --------------------------------------------------------------------------
-- Va en `no-reply@` y no en `info@` a propósito: si lo automático saliera desde
-- una dirección que la gente lee, las respuestas, los avisos de vacaciones y los
-- rebotes se mezclarían con los mensajes de clientes de verdad.
UPDATE psjy_configuration
   SET value = 'no-reply@importtoolsas.com'
 WHERE name = 'PS_SHOP_EMAIL';


-- --------------------------------------------------------------------------
-- 2. Buzones de contacto: a dónde llega lo que escribe el visitante
-- --------------------------------------------------------------------------
-- Este SÍ lo lee una persona. Si se quiere seguir leyendo en el buzón de
-- siempre, se crea un reenviador en cPanel de
--   ventas@importtoolsas.com  ->  ventas@importtoolslatam.com
-- y el asesor no nota el cambio.
UPDATE psjy_contact
   SET email = 'ventas@importtoolsas.com'
 WHERE email = 'ventas@importtoolslatam.com';


-- --------------------------------------------------------------------------
-- 3. Firma de atención al cliente
-- --------------------------------------------------------------------------
-- Estaba vacía: las respuestas desde el back office salían sin firmar.
UPDATE psjy_configuration
   SET value = 'Equipo Importtools S.A.S · +57 314 593 4962 · www.importtoolsas.com'
 WHERE name = 'PS_CUSTOMER_SERVICE_SIGNATURE';


SELECT '--- DESPUES ---' AS ``;
SELECT name, value FROM psjy_configuration
 WHERE name IN ('PS_SHOP_EMAIL','PS_CUSTOMER_SERVICE_SIGNATURE');
SELECT c.id_contact, c.email, cl.name
  FROM psjy_contact c
  LEFT JOIN psjy_contact_lang cl ON cl.id_contact = c.id_contact AND cl.id_lang = 2;

SELECT '--- QUEDA POR HACER EN EL BACK OFFICE ---' AS ``;
SELECT 'Parametros avanzados > Correo electronico > SMTP con no-reply@importtoolsas.com, TLS, puerto 587' AS paso
UNION ALL SELECT 'Enviar correo de prueba A UNA CUENTA DE GMAIL (no del propio dominio)'
UNION ALL SELECT 'En Gmail: Mostrar original -> SPF PASS, DKIM PASS, DMARC PASS'
UNION ALL SELECT 'Probar Olvide mi contrasena de punta a punta';

-- Marcha atrás:
--   UPDATE psjy_configuration SET value='ventas@importtoolslatam.com' WHERE name='PS_SHOP_EMAIL';
--   UPDATE psjy_contact SET email='ventas@importtoolslatam.com' WHERE email='ventas@importtoolsas.com';
