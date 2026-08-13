<?php
/**
 * ===========================================================================
 * Importtools S.A.S — arreglo 27 SIN phpMyAdmin y SIN el panel.   11/08/2026
 * ===========================================================================
 * Hace, en este orden:
 *
 *   1. Aplica deploy/paquete/27-iconos-svg-remotos.sql (los iconos SVG que la
 *      plantilla pedia a 192.168.1.80, la LAN del autor del tema), con respaldo
 *      dentro de la propia base y verificacion.
 *   2. Invalida el CSS que Elementor guarda en la base.
 *   3. Vacia var/cache/prod y borra var/cache/dev  <-- esto es lo que deberia
 *      levantar el back office, y de paso libera inodos.
 *   4. SE BORRA A SI MISMO.
 *
 * POR QUE ESTE ORDEN: si se vacia la cache ANTES de arreglar los iconos, la
 * primera visita paga los tiempos de espera de los 6 iconos — 51 s medidos en
 * el espejo. Arreglados primero, son ~2 s.
 *
 * POR QUE NO USA PRESTASHOP: lee las credenciales de app/config/parameters.php
 * y habla con MySQL por mysqli. Asi funciona aunque el nucleo de PrestaShop no
 * arranque, que es justo el problema que estamos persiguiendo.
 *
 * COMO SE USA
 *   1. Subir este fichero a  public_html/  (cPanel -> Administrador de archivos
 *      -> Cargar). NO hace falta el editor.
 *   2. Abrir en el navegador:
 *      https://www.importtoolsas.com/it27-9f4b7c2ad8e1.php?t=k3Qm7Zt1Rv8Ns5Yp2Xw
 *   3. Leer el informe. Al final dice si consiguio borrarse.
 *   4. Comprobar que ya no existe: la misma URL debe dar 404.
 *
 * Es idempotente: se puede ejecutar dos veces sin romper nada.
 * ===========================================================================
 */

const TOKEN = 'k3Qm7Zt1Rv8Ns5Yp2Xw';

header('Content-Type: text/plain; charset=utf-8');
header('X-Robots-Tag: noindex, nofollow');

if (!isset($_GET['t']) || !hash_equals(TOKEN, (string) $_GET['t'])) {
    http_response_code(404);
    exit("404\n");
}

// Que un fallo nunca se quede mudo. Un error fatal de PHP puede terminar el
// proceso sin imprimir nada si display_errors esta apagado, y entonces parece
// que el script "no hizo nada".
@ini_set('display_errors', '1');
register_shutdown_function(function () {
    $e = error_get_last();
    if ($e && in_array($e['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        echo "\n!! ERROR FATAL: {$e['message']}\n   en {$e['file']}:{$e['line']}\n";
    }
});

$raiz = __DIR__;
function linea($t = '') { echo $t . "\n"; }
function titulo($t) { linea(); linea("=== $t ==="); }

linea('Importtools — arreglo 27 (iconos SVG remotos) + vaciado de caches');
linea('Fecha del servidor: ' . date('Y-m-d H:i:s'));
linea(str_repeat('-', 72));

// ---------------------------------------------------------------------------
// 0) Credenciales
// ---------------------------------------------------------------------------
titulo('0) Conexion a la base');
$rutaPar = $raiz . '/app/config/parameters.php';
if (!is_file($rutaPar)) {
    exit("!! No encuentro app/config/parameters.php. ¿Esta el fichero en public_html/?\n");
}
$cfg = include $rutaPar;
$p   = $cfg['parameters'];
$pre = $p['database_prefix'];
$host = $p['database_host'] . (empty($p['database_port']) ? '' : ':' . $p['database_port']);

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$db = new mysqli($p['database_host'], $p['database_user'], $p['database_password'],
                 $p['database_name'], empty($p['database_port']) ? 3306 : (int) $p['database_port']);
$db->set_charset('utf8mb4');
$db->query("SET SQL_MODE=''");
linea("   servidor  : $host");
linea('   base      : ' . $p['database_name']);
linea('   prefijo   : ' . $pre);
linea('   version   : ' . $db->get_server_info());

$T    = $pre . 'leoelements_contents_lang';
$TBK  = $pre . 'leoelements_contents_lang_bk_20260811';
$TMET = $pre . 'leoelements_meta';

function uno(mysqli $db, $sql) {
    $r = $db->query($sql); $f = $r->fetch_row(); $r->free();
    return $f === null ? null : $f[0];
}

// ---------------------------------------------------------------------------
// 1) Respaldo
// ---------------------------------------------------------------------------
titulo('1) Respaldo dentro de la propia base');
$db->query("CREATE TABLE IF NOT EXISTS `$TBK` AS
            SELECT * FROM `$T` WHERE content LIKE '%192.168.1.80%'");
$nBk = uno($db, "SELECT COUNT(*) FROM `$TBK`");
linea("   tabla `$TBK`: $nBk filas");
linea('   (esperado 14 = 7 contenidos x 2 idiomas. Si sale 0, es que ya se');
linea('    aplico antes y el respaldo se creo vacio: sin problema.)');

// ---------------------------------------------------------------------------
// 2) Antes
// ---------------------------------------------------------------------------
titulo('2) Estado ANTES');
$antesFilas = uno($db, "SELECT COUNT(*) FROM `$T` WHERE content LIKE '%192.168.1.80%'");
$antesUrls  = (int) uno($db, "SELECT IFNULL(SUM((LENGTH(content)-LENGTH(REPLACE(content,'192.168.1.80','')))/12),0)
                              FROM `$T` WHERE content LIKE '%192.168.1.80%'");
$antesSvg   = (int) uno($db, "SELECT IFNULL(SUM((LENGTH(content)-LENGTH(REPLACE(content,'\"library\":\"svg\"','')))/15),0)
                              FROM `$T` WHERE content LIKE '%192.168.1.80%'");
linea("   filas con URL a la LAN : $antesFilas");
linea("   referencias            : $antesUrls");
linea("   iconos con library svg : $antesSvg");

// ---------------------------------------------------------------------------
// 3) El arreglo
// ---------------------------------------------------------------------------
titulo('3) Aplicando el arreglo');
linea('   Se cambia la cadena COMPLETA (url + id + library) de cada icono:');
linea('     - library "svg" -> ""  : Icons_Manager::render_icon() sale en su');
linea('       primera linea con library vacio, asi que ya no sale a la red.');
linea('     - la URL pasa a ruta relativa del tema hijo.');
linea('   Se conserva el objeto {url,id} porque $has_icon de icon-box.php');
linea('   depende de EL, no de library: asi el <div class="elementor-icon-box-icon">');
linea('   se sigue pintando y el CSS del tema hijo sigue funcionando igual.');

$PRE_LAN = '"url":"http:\\/\\/192.168.1.80\\/prestashop\\/custom\\/vt_autosoe\\/themes\\/vt_autosoe\\/assets\\/img\\/modules\\/leoelements\\/images\\/';
$PRE_LOC = '"url":"\\/themes\\/vt_autosoe_child\\/assets\\/img\\/modules\\/leoelements\\/images\\/';
$SUF_ANT = '","id":0},"library":"svg"}';
$SUF_NUE = '","id":0},"library":""}';
$FICHEROS = ['phone.svg', 'clock.svg', 'message-chat-square.svg', 'garage-1.svg', 'mail-01.svg'];

$db->begin_transaction();
try {
    $expr = 'content';
    foreach ($FICHEROS as $fi) {
        $busca = $db->real_escape_string($PRE_LAN . $fi . $SUF_ANT);
        $pone  = $db->real_escape_string($PRE_LOC . $fi . $SUF_NUE);
        $expr  = "REPLACE($expr, '$busca', '$pone')";
    }
    $db->query("UPDATE `$T` SET content = $expr WHERE content LIKE '%192.168.1.80%'");
    $tocadas = $db->affected_rows;
    linea("   filas actualizadas: $tocadas");

    // Invalidar el CSS de Elementor guardado en la base. Vaciar var/cache/ NO
    // basta: el front seguiria sirviendo las URLs viejas.
    $db->query("DELETE FROM `$TMET` WHERE name LIKE '%elementor_css%'");
    linea('   filas de CSS de Elementor borradas: ' . $db->affected_rows);

    $db->commit();
} catch (Throwable $e) {
    $db->rollback();
    exit("\n!! Fallo el UPDATE, transaccion deshecha. Nada cambio.\n   " . $e->getMessage() . "\n");
}

// ---------------------------------------------------------------------------
// 4) Verificacion
// ---------------------------------------------------------------------------
titulo('4) Verificacion — los cuatro deben ser 0');
$q1 = (int) uno($db, "SELECT COUNT(*) FROM `$T` WHERE content LIKE '%192.168.%'");
$q2 = (int) uno($db, "SELECT COUNT(*) FROM `$T` WHERE content LIKE '%\"library\":\"svg\"%'");
try {
    $q3 = (int) uno($db, "SELECT COUNT(*) FROM `$T` WHERE JSON_VALID(content) = 0");
} catch (Throwable $e) {
    $q3 = 'no comprobable (JSON_VALID no disponible)';
}
// Cada icono ahorra EXACTAMENTE 50 bytes: 47 del prefijo de la URL (75 -> 28)
// y 3 de "svg" -> "". Si el descuadre no es 0, algun REPLACE no caso.
$q4 = (int) uno($db, "SELECT COUNT(*) FROM `$T` c JOIN `$TBK` b
        ON b.id_leoelements_contents = c.id_leoelements_contents AND b.id_lang = c.id_lang
      WHERE LENGTH(b.content) - LENGTH(c.content) <> 50 *
            ((LENGTH(b.content) - LENGTH(REPLACE(b.content,'192.168.1.80','')))/12)");
$q5 = (int) uno($db, "SELECT IFNULL(SUM((LENGTH(content)-LENGTH(REPLACE(content,
        '\\\\/themes\\\\/vt_autosoe_child\\\\/assets\\\\/img\\\\/modules\\\\/leoelements\\\\/images\\\\/','')))/71),0) FROM `$T`");
$q6 = (int) uno($db, "SELECT COUNT(*) FROM `$TMET` WHERE name LIKE '%elementor_css%'");

linea("   quedan URLs a la LAN      : $q1");
linea("   quedan iconos library svg : $q2");
linea("   JSON roto                 : $q3");
linea("   descuadre de bytes        : $q4");
linea("   -- y estos dos son informativos --");
linea("   URLs locales del tema hijo: $q5   (esperado 44)");
linea("   CSS de Elementor en base  : $q6   (esperado 0)");

// ⚠️ Aqui habia un fallo: comprobar `$q3 !== 1` daba por bueno el caso de DOS
// o mas filas con el JSON roto. Tiene que ser "cero filas rotas", y si
// JSON_VALID no existe en este MySQL, $q3 es texto y no se puede concluir nada.
$jsonOk = !is_int($q3) || $q3 === 0;
$ok = ($q1 === 0 && $q2 === 0 && $q4 === 0 && $jsonOk);
linea();
linea($ok ? '   >>> ARREGLO CORRECTO.' : '   >>> ALGO NO CUADRA. Ver la marcha atras al final. NO vacio cachés.');

// ---------------------------------------------------------------------------
// 5) Cachés
// ---------------------------------------------------------------------------
if ($ok) {
    titulo('5) Vaciando cachés');

    $borrados = 0;
    $vaciar = function ($dir, $borrarRaiz) use (&$vaciar, &$borrados) {
        if (!is_dir($dir)) { return; }
        foreach (scandir($dir) ?: [] as $e) {
            if ($e === '.' || $e === '..') { continue; }
            $r = $dir . '/' . $e;
            if (is_dir($r) && !is_link($r)) { $vaciar($r, true); }
            else { if (@unlink($r)) { $borrados++; } }
        }
        if ($borrarRaiz) { @rmdir($dir); }
    };

    foreach ([['var/cache/dev', true], ['var/cache/prod', false]] as [$rel, $raizFuera]) {
        $ruta = $raiz . '/' . $rel;
        $existia = is_dir($ruta);
        $antes = $borrados;
        $vaciar($ruta, $raizFuera);
        linea(sprintf('   %-16s %s, %d ficheros borrados%s',
            $rel,
            $existia ? 'existia' : 'no existia',
            $borrados - $antes,
            $raizFuera ? ' (y la carpeta)' : ''));
    }
    linea("   TOTAL de ficheros borrados: $borrados   <- cada uno era un inodo");

    // Cachés propias de Leo Elements (HTML compilado por widget).
    $gen = $raiz . '/modules/leoelements/gencode';
    if (is_dir($gen)) {
        $n = 0;
        foreach (glob($gen . '/*.html') ?: [] as $g) { if (@unlink($g)) { $n++; } }
        linea("   modules/leoelements/gencode: $n ficheros .html borrados");
    }

    titulo('6) Peso de lo que sigue ocupando sitio (informativo)');
    foreach (['error_log', 'admin-api.zip'] as $f) {
        $r = $raiz . '/' . $f;
        linea(sprintf('   %-16s %s', $f,
            is_file($r) ? number_format(filesize($r) / 1048576, 1) . ' MB' : 'no existe'));
    }
    linea('   (los dos se pueden borrar desde el Administrador de archivos:');
    linea('    error_log se regenera solo, y admin-api.zip no deberia estar');
    linea('    en public_html porque cualquiera lo puede descargar.)');
}

// ---------------------------------------------------------------------------
// 7) Marcha atras y autodestruccion
// ---------------------------------------------------------------------------
titulo('7) Marcha atras, si hiciera falta');
linea('   En phpMyAdmin, cuando vuelva a funcionar:');
linea("     UPDATE `$T` c JOIN `$TBK` b");
linea('       ON b.id_leoelements_contents = c.id_leoelements_contents');
linea('      AND b.id_lang = c.id_lang');
linea('      SET c.content = b.content;');
linea("     DELETE FROM `$TMET` WHERE name LIKE '%elementor_css%';");

$db->close();

titulo('8) Borrandome');
$yo = __FILE__;
if (@unlink($yo)) {
    linea('   HECHO: este fichero ya no existe en el servidor.');
    linea('   Comprueba que la misma URL da 404 y no queda nada suelto.');
} else {
    linea('   !! NO he podido borrarme: ' . basename($yo));
    linea('   BORRALO A MANO desde el Administrador de archivos, ahora.');
    linea('   Un script asi en el docroot es una puerta abierta.');
}
linea();
linea('Siguiente paso: abre la tienda y el panel.');
linea('  https://www.importtoolsas.com/          (la 1a visita reconstruye cache)');
linea('  https://www.importtoolsas.com/panel-4h5o/');
