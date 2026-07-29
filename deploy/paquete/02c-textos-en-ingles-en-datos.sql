-- ============================================================================
--  Import Tools Latam S.A.S — textos en ingles que viven en la BASE DE DATOS
--
--  ESTADO: ya aplicado al volcado importtools-FINAL-20260729-2200 y posteriores.
--          Se conserva por trazabilidad.
--
--  Estos textos NO son cadenas traducibles: son DATOS. Por eso no los arregla
--  ningun fichero de traduccion ni el catalogo es-CO, y por eso sobrevivieron a
--  la auditoria de idioma del 28/07, que buscaba cadenas.
--
--  Prefijo de tablas: psjy_   ·   id_lang 2 = es-CO (el activo), 1 = en (inactivo)
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 1) Tratamiento (Sr./Sra.) — psjy_gender_lang
--    Salen como los dos radios del formulario de registro, o sea en la pagina a
--    la que lleva el boton «Quiero ser cliente» del cliente.
--    Comprobado: <input name="id_gender" value="1"> ... Mr.
-- ---------------------------------------------------------------------------
UPDATE psjy_gender_lang SET name = 'Sr.'  WHERE id_gender = 1;
UPDATE psjy_gender_lang SET name = 'Sra.' WHERE id_gender = 2;


-- ---------------------------------------------------------------------------
-- 2) Consentimiento RGPD — psjy_configuration_lang
--
--    Por que estaba en ingles: modules/psgdpr/psgdpr.php elige el texto por
--    codigo ISO **en el momento de instalarse** (array $presetMessageAccountCreation,
--    linea 45). Tiene una entrada 'es' correcta:
--        'es' => 'Acepto las condiciones generales y la politica de confidencialidad'
--    pero tambien:
--        'cb' => 'I agree to the terms and conditions and the privacy policy'
--    y el modulo se instalo cuando el idioma tenia `iso_code = 'cb'` — el ISO
--    invalido que corregimos a 'es' despues (ver §10 de CLAUDE.md). Asi que
--    guardo el ingles en la base y ahi se quedo: cambiar el iso_code luego no
--    reescribe lo ya guardado.
--
--    Se pone el texto de la propia entrada 'es' del modulo, adaptado a la
--    tienda (enlaza con las paginas legales que si existen).
-- ---------------------------------------------------------------------------
UPDATE psjy_configuration_lang cl
   JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
    SET cl.value = 'Acepto los términos y condiciones y la política de privacidad'
  WHERE c.name = 'PSGDPR_CREATION_FORM';

UPDATE psjy_configuration_lang cl
   JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
    SET cl.value = 'Acepto los términos y condiciones y la política de privacidad'
  WHERE c.name = 'PSGDPR_CUSTOMER_FORM';


-- ---------------------------------------------------------------------------
-- 2-bis) Aviso de baja del boletin — psjy_configuration_lang, NW_CONDITIONS
--
--    Mismo caso que el RGPD y misma causa. ps_emailsubscription.php:1414
--    (`getConditionFixtures`) guarda el texto AL INSTALARSE, traducido al idioma
--    de ese momento. Con `iso_code = 'cb'` no encontro catalogo y dejo el ingles.
--
--    Sale en el pie, dentro de <p class="hidden">, asi que **no se ve** — pero si
--    esta en el HTML y lo leen los lectores de pantalla y los buscadores.
--    La traduccion correcta ya existe en el catalogo del tema hijo
--    (ModulesEmailsubscriptionShop.es-CO.xlf) pero no se aplica: al ser un dato
--    guardado, el catalogo ya no interviene.
-- ---------------------------------------------------------------------------
UPDATE psjy_configuration_lang cl
   JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
    SET cl.value = 'Puedes darte de baja en cualquier momento. Encontrarás nuestros datos de contacto en el aviso legal.'
  WHERE c.name = 'NW_CONDITIONS';


-- ---------------------------------------------------------------------------
-- 2-ter) Aviso de privacidad del formulario de registro — CUSTPRIV_MSG_AUTH
--    Se ve en /login?create_account=1, justo debajo de «Privacidad de los datos
--    del cliente». Ademas citaba «the "My Account" page», que en la tienda se
--    llama «Mi cuenta».
-- ---------------------------------------------------------------------------
UPDATE psjy_configuration_lang cl
   JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
    SET cl.value = 'Los datos personales que nos facilitas se usan para atender tus consultas, gestionar tus pedidos y darte acceso a información concreta. Puedes modificarlos o eliminarlos en cualquier momento desde la página «Mi cuenta».'
  WHERE c.name = 'CUSTPRIV_MSG_AUTH';


-- ---------------------------------------------------------------------------
-- 2-quater) Texto de la pagina de MANTENIMIENTO — PS_MAINTENANCE_TEXT
--
--    ⚠️ Este importa para el propio despliegue: la Fase 0.4 del plan manda
--    activar el mantenimiento. Con el texto de fabrica, cualquier cliente que
--    entrara durante la importacion habria visto:
--        «We are currently updating our shop and will be back really soon.
--         Thanks for your patience.»
-- ---------------------------------------------------------------------------
UPDATE psjy_configuration_lang cl
   JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
    SET cl.value = 'Estamos actualizando la tienda y volvemos en unos minutos.\nGracias por tu paciencia.'
  WHERE c.name = 'PS_MAINTENANCE_TEXT';


-- ---------------------------------------------------------------------------
-- 3) Comprobaciones
-- ---------------------------------------------------------------------------
SELECT 'generos'         AS concepto, GROUP_CONCAT(DISTINCT name ORDER BY id_gender) AS valor, 'Sr.,Sra.' AS esperado
  FROM psjy_gender_lang
UNION ALL
SELECT 'RGPD en ingles', COUNT(*), '0'
  FROM psjy_configuration_lang WHERE value LIKE '%I agree to the terms%'
UNION ALL
SELECT 'RGPD en español', COUNT(*), '4 (2 ajustes x 2 idiomas)'
  FROM psjy_configuration_lang WHERE value LIKE '%Acepto los términos%'
UNION ALL
SELECT 'boletin en español', COUNT(*), '2'
  FROM psjy_configuration_lang WHERE value LIKE '%darte de baja%'
UNION ALL
SELECT 'privacidad en español', COUNT(*), '2'
  FROM psjy_configuration_lang WHERE value LIKE '%datos personales que nos facilitas%'
UNION ALL
SELECT 'mantenimiento en español', COUNT(*), '2'
  FROM psjy_configuration_lang WHERE value LIKE '%Estamos actualizando la tienda%'
UNION ALL
SELECT 'ingles suelto en configuration_lang', COUNT(*), '2 (solo PS_SEARCH_BLACKLIST, ver nota)'
  FROM psjy_configuration_lang
 WHERE value REGEXP '[[:<:]](the|you|your|is used|please|thank you|we are|we will)[[:>:]]'
   AND CHAR_LENGTH(value) > 25;

-- ---------------------------------------------------------------------------
-- 4) NO se cambia, pero conviene saberlo: PS_SEARCH_BLACKLIST
--
--    Guarda la lista de palabras que el buscador ignora, y esta en INGLES
--    («a|about|above|after|again|against|all|am|an|and|any|are|aren|as|at|be…»).
--    En una tienda en español no filtra nada util: «de», «la», «el», «para»,
--    «con» si se indexan, y en cambio se descartan palabras inglesas que no
--    aparecen en el catalogo.
--
--    No lo toco aqui porque **cambiarlo obliga a reconstruir el indice de
--    busqueda** (Parametros de la tienda → Buscar → Reconstruir el indice) y es
--    una decision sobre el comportamiento del buscador, no una traduccion.
--    Si se quiere hacer, con el indice reconstruido despues:
--
-- UPDATE psjy_configuration_lang cl
--    JOIN psjy_configuration c ON c.id_configuration = cl.id_configuration
--     SET cl.value = 'a|al|algo|alguna|algunas|alguno|algunos|ante|antes|como|con|contra|cual|cuando|de|del|desde|donde|durante|e|el|ella|ellas|ellos|en|entre|era|eran|es|esa|esas|ese|eso|esos|esta|estas|este|esto|estos|ha|han|hasta|la|las|le|les|lo|los|mas|me|mi|mis|mucho|muy|nada|ni|no|nos|nuestra|nuestro|o|os|otra|otras|otro|otros|para|pero|poco|por|porque|que|quien|se|sea|segun|ser|si|sin|sobre|solo|son|su|sus|tambien|tanto|te|tiene|todo|todos|tu|tus|un|una|uno|unos|y|ya|yo'
--   WHERE c.name = 'PS_SEARCH_BLACKLIST';

-- Despues: vaciar var/cache/ y recargar /login?create_account=1 y la portada.
--
-- Por que la auditoria de idioma del 28/07 no vio nada de esto: buscaba cadenas
-- traducibles, y estos cuatro textos son DATOS guardados en la base. Ningun
-- fichero de traduccion los toca. La forma de encontrarlos es al contrario:
-- leer el HTML servido y buscar ingles, que es como salieron.
