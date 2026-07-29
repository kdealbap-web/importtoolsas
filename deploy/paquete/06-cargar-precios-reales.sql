-- ============================================================================
--  Import Tools Latam S.A.S — CARGA DE PRECIOS REALES
--
--  Para cuando el cliente envie el archivo de precios. Sustituye los precios
--  generados (marcados con supplier_reference = 'PRECIO-PRUEBA') por los suyos,
--  cruzando por el codigo de producto.
--
--  Prefijo de tablas: psjy_
--
--  LEE EL PASO 3 ANTES DE EJECUTAR NADA: hay que saber si los precios del
--  cliente llevan IVA incluido o no. Si se equivoca ahi, toda la tienda queda
--  con un 19 % de diferencia.
--
--  PROBADO DE PRINCIPIO A FIN en el entorno espejo el 29/07/2026, con un CSV
--  hecho a proposito hostil: finales de linea CRLF de Windows, codigos en
--  minuscula, codigos con espacios de relleno, un codigo inexistente y un
--  codigo repetido. Resultado:
--    · 7 filas leidas, normalizadas sin perder ninguna
--    · 6 productos actualizados, el inexistente reportado en el paso 4
--    · precio nuevo visible en la ficha de la tienda (content="51000")
--    · 0 descuadres entre psjy_product y psjy_product_shop
--    · la marcha atras devolvio los 3.036 a su precio anterior
--  Tambien se comprobo el caso «archivo vacio»: el script no toca nada.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- PASO 1 — Tabla de recepcion
--    NO se usa TEMPORARY a proposito: phpMyAdmin abre una conexion por
--    pestaña y una tabla temporal desapareceria entre pasos.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS tmp_precios;
CREATE TABLE tmp_precios (
  codigo  VARCHAR(64)    NOT NULL,
  precio  DECIMAL(20,6)  NOT NULL,
  KEY (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ---------------------------------------------------------------------------
-- PASO 2 — Cargar el archivo del cliente en tmp_precios
--
--    Deja el CSV con DOS columnas y cabecera:   codigo,precio
--    El precio sin separador de miles y con punto decimal si lo lleva:
--        NIK-10402,84300
--        NIK-14010,68400.50
--
--    Opcion a) phpMyAdmin → tabla tmp_precios → Importar → CSV,
--              «Las columnas se separan con: ,» y marcar que la primera fila
--              contiene los nombres de columna.
--
--    Opcion b) cPanel → Terminal:
--        LOAD DATA LOCAL INFILE '/home/USUARIO/precios.csv'
--          INTO TABLE tmp_precios
--          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--          LINES TERMINATED BY '\n'
--          IGNORE 1 LINES
--          (codigo, precio);
--
--    Si el cliente manda Excel, guardar como CSV UTF-8 primero. Si los importes
--    vienen como «$ 84.300», hay que limpiarlos antes: el punto de miles hace
--    que MySQL lea 84.300 como ochenta y cuatro con tres decimas.
-- ---------------------------------------------------------------------------

-- Comprobar lo que entro:
SELECT COUNT(*) AS filas_cargadas, MIN(precio) AS minimo, MAX(precio) AS maximo,
       SUM(precio <= 0) AS precios_cero_o_negativos
  FROM tmp_precios;

-- Aviso de importes sospechosamente pequeños: si salen muchos por debajo de
-- 1.000 COP, es casi seguro que el punto de miles se leyo como decimal.
SELECT COUNT(*) AS sospechosos_menores_de_1000 FROM tmp_precios WHERE precio < 1000;


-- ---------------------------------------------------------------------------
-- PASO 2-bis — NORMALIZAR LOS CODIGOS. No te lo salt+es.
--
--    Que ignora y que NO ignora el operador `=` en esta base (comprobado en el
--    espejo, colacion utf8mb4_general_ci):
--
--      | En el codigo             | Cruza? | TRIM lo arregla? |
--      |-------------------------|--------|------------------|
--      | espacios AL FINAL       |  SI    | no hace falta    |
--      | mayusculas/minusculas   |  SI    | no hace falta    |
--      | espacios AL PRINCIPIO   |  NO    | si               |
--      | tabulador               |  NO    | **NO**           |
--      | retorno de carro \r     |  NO    | **NO**           |
--
--    El caso peligroso es el ultimo y es el mas probable: un CSV guardado en
--    Windows lleva finales de linea CRLF, y `LINES TERMINATED BY '\n'` deja un
--    `\r` pegado a la ULTIMA columna. Si el archivo llega con las columnas al
--    reves (precio,codigo) o con una sola columna, el `\r` cae en el codigo, el
--    cruce da 0 filas y **el UPDATE no avisa de nada**: se queda tan tranquilo.
--
--    Por eso se normaliza aqui, una vez, en lugar de confiar en el TRIM del JOIN.
--    (En la columna `precio` el `\r` es inofensivo: DECIMAL lo descarta al
--    convertir. Comprobado.)
-- ---------------------------------------------------------------------------
UPDATE tmp_precios
   SET codigo = UPPER(TRIM(REPLACE(REPLACE(REPLACE(codigo, '\r', ''), '\n', ''), '\t', '')));

-- Ninguno debe quedar vacio ni con caracteres raros:
SELECT SUM(codigo = '')                          AS codigos_vacios,
       SUM(codigo <> UPPER(TRIM(codigo)))        AS mal_normalizados,
       MIN(LENGTH(codigo))                       AS largo_minimo,
       MAX(LENGTH(codigo))                       AS largo_maximo
  FROM tmp_precios;


-- ---------------------------------------------------------------------------
-- PASO 3 — ¿Los precios del cliente llevan IVA?
--
--    En PrestaShop psjy_product.price es SIEMPRE el precio SIN impuesto. Los
--    3.036 productos estan en la regla «CO Standard Rate (19%)» (id 53) y la
--    tienda muestra los precios SIN IVA (price_display_method = 1 en los tres
--    grupos de clientes).
--
--    · Si el archivo trae precios SIN IVA  -> no hay que hacer nada.
--    · Si el archivo trae precios CON IVA  -> descomentar esta linea UNA sola vez:
--
-- UPDATE tmp_precios SET precio = ROUND(precio / 1.19, 6);
--
--    Como saberlo sin preguntar: coge 3 codigos, mira el precio que te dieron y
--    comparalo con el de su lista de venta al publico. Si coinciden, llevan IVA.
--    Ante la duda, PREGUNTA al cliente. No lo adivines.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- PASO 4 — Cruce en seco. **Este es el paso que evita el desastre.**
--    Con los codigos ya normalizados en el paso 2-bis, el cruce es directo
--    contra `reference` (la colacion ya ignora mayusculas y espacios finales).
-- ---------------------------------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM tmp_precios)                                    AS filas_archivo,
  (SELECT COUNT(DISTINCT codigo) FROM tmp_precios)                      AS codigos_distintos,
  (SELECT COUNT(*) FROM tmp_precios t
     JOIN psjy_product p ON p.reference = t.codigo)                     AS van_a_cuadrar,
  (SELECT COUNT(*) FROM tmp_precios t
     LEFT JOIN psjy_product p ON p.reference = t.codigo
    WHERE p.id_product IS NULL)                                         AS codigos_sin_producto,
  (SELECT COUNT(*) FROM psjy_product p
    WHERE p.supplier_reference = 'PRECIO-PRUEBA'
      AND p.reference NOT IN (SELECT codigo FROM tmp_precios))          AS productos_sin_precio_en_archivo;

-- Codigos del archivo que no existen como producto (revisar antes de seguir):
SELECT t.codigo, t.precio FROM tmp_precios t
  LEFT JOIN psjy_product p ON p.reference = t.codigo
 WHERE p.id_product IS NULL LIMIT 40;

-- Productos que se quedarian con precio generado porque no vienen en el archivo:
SELECT p.reference, p.price AS precio_generado FROM psjy_product p
 WHERE p.supplier_reference = 'PRECIO-PRUEBA'
   AND p.reference NOT IN (SELECT codigo FROM tmp_precios) LIMIT 40;

-- Codigos repetidos en el archivo. Si hay, MySQL aplicaria uno cualquiera:
SELECT codigo, COUNT(*) AS veces, MIN(precio) AS minimo, MAX(precio) AS maximo
  FROM tmp_precios GROUP BY codigo HAVING COUNT(*) > 1;

-- >>> NO PASES DEL PASO 5 hasta que:
--       · `van_a_cuadrar` sea el numero que esperas,
--       · `codigos_repetidos` no devuelva filas,
--       · y sepas explicar cada codigo de `codigos_sin_producto`.


-- ---------------------------------------------------------------------------
-- PASO 5 — Respaldo de los precios actuales. Barato y salva la vida.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS bak_precios_antes;
CREATE TABLE bak_precios_antes AS
  SELECT id_product, reference, price, supplier_reference FROM psjy_product;

SELECT COUNT(*) AS filas_respaldadas FROM bak_precios_antes;


-- ---------------------------------------------------------------------------
-- PASO 6 — Aplicar. Las dos tablas tienen que quedar iguales: PrestaShop lee
--    psjy_product_shop en la tienda y psjy_product en el back office.
-- ---------------------------------------------------------------------------
START TRANSACTION;

UPDATE psjy_product p
  JOIN tmp_precios t ON t.codigo = p.reference
   SET p.price              = t.precio,
       p.supplier_reference = '',            -- deja de estar marcado como prueba
       p.date_upd           = NOW();

UPDATE psjy_product_shop ps
  JOIN psjy_product p ON p.id_product = ps.id_product
  JOIN tmp_precios t  ON t.codigo = p.reference
   SET ps.price    = t.precio,
       ps.date_upd = NOW();

-- Antes de confirmar, comprobar que no quedaron descuadradas:
SELECT SUM(p.price <> ps.price) AS descuadres_precio
  FROM psjy_product p JOIN psjy_product_shop ps ON ps.id_product = p.id_product;

COMMIT;
-- Si `descuadres_precio` no es 0, ejecutar ROLLBACK en lugar de COMMIT.


-- ---------------------------------------------------------------------------
-- PASO 7 — Verificar
-- ---------------------------------------------------------------------------
SELECT 'productos totales'            AS concepto, COUNT(*) AS valor FROM psjy_product
UNION ALL SELECT 'con precio real',          COUNT(*) FROM psjy_product WHERE supplier_reference <> 'PRECIO-PRUEBA'
UNION ALL SELECT 'siguen con precio prueba', COUNT(*) FROM psjy_product WHERE supplier_reference  = 'PRECIO-PRUEBA'
UNION ALL SELECT 'con precio 0',             COUNT(*) FROM psjy_product WHERE price = 0
UNION ALL SELECT 'descuadres product/shop',  SUM(p.price <> ps.price)
     FROM psjy_product p JOIN psjy_product_shop ps ON ps.id_product = p.id_product;

-- Muestra para comparar a ojo con el archivo del cliente:
SELECT p.reference, p.price AS sin_iva, ROUND(p.price * 1.19) AS con_iva_19, LEFT(pl.name, 40) AS nombre
  FROM psjy_product p JOIN psjy_product_lang pl ON pl.id_product = p.id_product AND pl.id_lang = 2
 WHERE p.supplier_reference = '' ORDER BY p.id_product LIMIT 15;


-- ---------------------------------------------------------------------------
-- PASO 8 — Despues de aplicar, en el servidor
--    1. Back office → Parametros avanzados → Rendimiento → Borrar la cache.
--    2. Vaciar `var/cache/` (como el usuario del servidor web, no como root).
--    3. Back office → Parametros de la tienda → Buscar → **Reconstruir el
--       indice completo**: el buscador guarda el precio en su indice.
--    4. Si hay LiteSpeed Cache, purgarlo.
--    5. Comprobar en la tienda 3 productos del archivo con la calculadora.
--       Sin vaciar la cache la ficha sigue mostrando el precio viejo aunque la
--       base ya este bien: comprobado en el espejo.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- MARCHA ATRAS
-- ---------------------------------------------------------------------------
-- UPDATE psjy_product p JOIN bak_precios_antes b ON b.id_product = p.id_product
--    SET p.price = b.price, p.supplier_reference = b.supplier_reference;
-- UPDATE psjy_product_shop ps JOIN bak_precios_antes b ON b.id_product = ps.id_product
--    SET ps.price = b.price;


-- ---------------------------------------------------------------------------
-- LIMPIEZA — solo cuando todo este verificado
-- ---------------------------------------------------------------------------
-- DROP TABLE tmp_precios;
-- DROP TABLE bak_precios_antes;   -- conservar unos dias
