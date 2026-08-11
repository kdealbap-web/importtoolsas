-- ===========================================================================
-- 26 — Correo del dominio: TODO el lado de PrestaShop, por SQL · 11/08/2026
-- Importtools S.A.S · prefijo psjy_
-- ---------------------------------------------------------------------------
-- Amplía el `21-correo-del-dominio.sql`, que solo cambiaba las direcciones y
-- dejaba el SMTP «para el back office». Ya no hace falta: se comprobó leyendo
-- el núcleo que la contraseña se guarda y se lee EN CLARO, así que el método
-- de envío se puede configurar entero desde aquí.
--
--   classes/Mail.php:379  ->  ->setPassword($configuration['PS_MAIL_PASSWD'])
--
-- No hay cifrado ni descifrado por medio (comprobado en src/Core/Email/ y
-- src/Adapter/Mail/). Lo que escribas aquí es lo que se usa.
--
-- ⚠️ ORDEN. Esto va DESPUÉS de crear las cuentas en cPanel. Si `no-reply@`
--    todavía no existe, los correos saldrán con un remitente inexistente y los
--    rebotes no llegarán a ninguna parte: peor que antes.
--
-- ⚠️ NO VERSIONAR LA CONTRASEÑA. Sustituye el texto PON-AQUI-LA-CLAVE al
--    pegarlo en phpMyAdmin y no guardes el fichero con la clave dentro.
-- ===========================================================================

SET NAMES utf8mb4;

SELECT '--- ANTES ---' AS ``;
SELECT name, value FROM psjy_configuration
 WHERE name LIKE 'PS_MAIL_%' OR name = 'PS_SHOP_EMAIL'
 ORDER BY name;


-- ---------------------------------------------------------------------------
-- 1. Direcciones  (esto ya lo hacía el 21; se repite por ser idempotente)
-- ---------------------------------------------------------------------------
UPDATE psjy_configuration SET value = 'no-reply@importtoolsas.com'
 WHERE name = 'PS_SHOP_EMAIL';

UPDATE psjy_contact SET email = 'ventas@importtoolsas.com'
 WHERE email IN ('ventas@importtoolslatam.com', 'ventas@importtoolsas.com');

UPDATE psjy_configuration
   SET value = 'Equipo Importtools S.A.S · +57 314 593 4962 · www.importtoolsas.com'
 WHERE name = 'PS_CUSTOMER_SERVICE_SIGNATURE';


-- ---------------------------------------------------------------------------
-- 2. Método de envío: SMTP autenticado en lugar de mail()
-- ---------------------------------------------------------------------------
-- PS_MAIL_METHOD:  1 = mail() de PHP   ·   2 = SMTP   ·   3 = no enviar nada
-- (classes/Mail.php:92  const METHOD_SMTP = 2;  :97  METHOD_DISABLE = 3)
--
-- ⚠️⚠️ EL PUERTO ES 465, NO 587. Esto corrige al `20-CORREO-DEL-DOMINIO.md`,
--      que decía «TLS, puerto 587» — y esa combinación NO FUNCIONA con este
--      núcleo. Comprobado leyendo el código, no suponiéndolo:
--
--   classes/Mail.php:354   cualquier valor de PS_MAIL_SMTP_ENCRYPTION que no
--                          sea 'off' pone $isTls = TRUE.
--   symfony/mailer  SocketStream.php:138   if ($this->tls) $url = 'ssl://'.$url;
--                          o sea TLS IMPLÍCITO desde el primer byte.
--   symfony/mailer  EsmtpTransport.php:149  el STARTTLS solo se intenta
--                          `if (!$stream->isTLS())`.
--
--   Resultado, las cuatro combinaciones:
--     'tls' + 465  -> ssl://host:465, TLS implícito ............... FUNCIONA  <= la nuestra
--     'off' + 587  -> texto y luego STARTTLS automático ........... funciona (también cifra)
--     'tls' + 587  -> handshake TLS contra un puerto que espera
--                     texto plano ................................ FALLA
--     'off' + 465  -> texto plano contra un puerto SMTPS .......... FALLA
--
--   Se elige 'tls' + 465 porque cifra desde el principio y no depende de que
--   el servidor anuncie STARTTLS.

UPDATE psjy_configuration SET value = '2'   WHERE name = 'PS_MAIL_METHOD';
UPDATE psjy_configuration SET value = 'mail.importtoolsas.com'
                                            WHERE name = 'PS_MAIL_SERVER';
UPDATE psjy_configuration SET value = 'no-reply@importtoolsas.com'
                                            WHERE name = 'PS_MAIL_USER';
UPDATE psjy_configuration SET value = 'PON-AQUI-LA-CLAVE'
                                            WHERE name = 'PS_MAIL_PASSWD';
UPDATE psjy_configuration SET value = 'tls' WHERE name = 'PS_MAIL_SMTP_ENCRYPTION';
UPDATE psjy_configuration SET value = '465' WHERE name = 'PS_MAIL_SMTP_PORT';


-- ---------------------------------------------------------------------------
-- 3. DKIM de PrestaShop: se queda APAGADO, a propósito
-- ---------------------------------------------------------------------------
-- El que tiene que firmar es el servidor (cPanel → Email Deliverability), que
-- ya tiene la clave en la zona DNS. Si PrestaShop firma además por su cuenta y
-- las claves no coinciden, algunos destinatarios ven una firma que no valida y
-- es peor que no firmar. Una sola firma, la del servidor.
UPDATE psjy_configuration SET value = '0' WHERE name = 'PS_MAIL_DKIM_ENABLE';


-- ---------------------------------------------------------------------------
-- 4. Comprobación
-- ---------------------------------------------------------------------------
SELECT '--- DESPUES (revisa una por una) ---' AS ``;
SELECT name,
       CASE WHEN name = 'PS_MAIL_PASSWD'
            THEN CONCAT('(', CHAR_LENGTH(value), ' caracteres)')
            ELSE value END AS value
  FROM psjy_configuration
 WHERE name IN ('PS_SHOP_EMAIL','PS_MAIL_METHOD','PS_MAIL_SERVER','PS_MAIL_USER',
                'PS_MAIL_PASSWD','PS_MAIL_SMTP_ENCRYPTION','PS_MAIL_SMTP_PORT',
                'PS_MAIL_DKIM_ENABLE','PS_CUSTOMER_SERVICE_SIGNATURE')
 ORDER BY name;

SELECT c.id_contact, c.email, cl.name
  FROM psjy_contact c
  LEFT JOIN psjy_contact_lang cl
    ON cl.id_contact = c.id_contact AND cl.id_lang = 2;

SELECT '--- si PS_MAIL_PASSWD dice (0 caracteres), NO lo sustituiste ---' AS ``;

-- ---------------------------------------------------------------------------
-- 5. Lo que NO se puede hacer por SQL ni por FTP  (tiene que ser en cPanel)
-- ---------------------------------------------------------------------------
SELECT '--- PENDIENTE EN cPANEL ---' AS ``;
SELECT 'Cuentas de correo: crear no-reply@, ventas@ e info@ en importtoolsas.com' AS paso
UNION ALL SELECT 'Reenviadores: info@ -> ventas@   y   ventas@importtoolsas.com -> ventas@importtoolslatam.com'
UNION ALL SELECT 'Email Deliverability -> Repair: SPF y DKIM en verde'
UNION ALL SELECT 'Zone Editor -> TXT en _dmarc: v=DMARC1; p=none; rua=mailto:admin_dev@importtoolsas.com; pct=100'
UNION ALL SELECT 'Prueba: correo A GMAIL (no al propio dominio) -> Mostrar original -> SPF/DKIM/DMARC en PASS'
UNION ALL SELECT 'Y por ultimo: Olvide mi contrasena, de punta a punta';

-- Marcha atrás completa:
--   UPDATE psjy_configuration SET value='1' WHERE name='PS_MAIL_METHOD';
--   UPDATE psjy_configuration SET value='ventas@importtoolslatam.com' WHERE name='PS_SHOP_EMAIL';
--   UPDATE psjy_contact SET email='ventas@importtoolslatam.com' WHERE email='ventas@importtoolsas.com';
--   (con METHOD=1 vuelve a mail() y los demas PS_MAIL_* dejan de usarse)
