<?php
/**
 * Importtools S.A.S — fuerza el MODO PRODUCCION.  11/08/2026
 *
 * DONDE VA:  public_html/config/defines_custom.inc.php
 *
 * POR QUE ESTE FICHERO Y NO EDITAR defines.inc.php
 *   config/config.inc.php, lineas 11-12:
 *
 *       if (is_file(__DIR__ . '/defines_custom.inc.php')) {
 *           include_once __DIR__ . '/defines_custom.inc.php';
 *       }
 *
 *   Se incluye ANTES de defines.inc.php, y alli cada constante va envuelta en
 *   `if (!defined(...))`. Asi que lo que se declare aqui GANA, aunque
 *   defines.inc.php siga diciendo `true`. Ventajas:
 *
 *     1. Es una SUBIDA de fichero nuevo, no una edicion. El editor de ficheros
 *        de cPanel no puede guardar en este hosting (el desafio anti-bot de
 *        Imunify360 intercepta el POST y se queda en "verificando"), pero
 *        "Cargar" si funciona.
 *     2. No se pisa nada: si hay que volver atras, se borra este fichero y todo
 *        queda como estaba.
 *     3. El interruptor del back office (Parametros avanzados -> Rendimiento)
 *        sigue funcionando: PrestaShop escribe el valor en ESTE fichero cuando
 *        existe (src/Adapter/Debug/DebugMode.php:173).
 *
 * QUE ARREGLA
 *   Con el modo de depuracion encendido, la tienda devolvia HTTP 500. La causa
 *   de fondo son los iconos SVG que la plantilla pedia a 192.168.1.80 (la red
 *   local del autor del tema): classes/Tools.php solo lanza la excepcion
 *   `if (false === $content && _PS_MODE_DEV_)`. Con el modo produccion el fallo
 *   deja de tumbar la pagina. El arreglo de fondo va aparte, en
 *   deploy/paquete/27-iconos-svg-remotos.sql, y hay que aplicarlo igual.
 *
 *   Ademas devuelve el entorno de Symfony a `prod` (defines.inc.php:95 hace
 *   `define('_PS_ENV_', _PS_MODE_DEV_ ? 'dev' : 'prod')`), asi que var/cache/dev
 *   deja de usarse: se puede borrar y liberar los miles de inodos que ocupa.
 */

if (!defined('_PS_MODE_DEV_')) {
    define('_PS_MODE_DEV_', false);
}
