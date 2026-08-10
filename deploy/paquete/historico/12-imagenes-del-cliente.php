<?php
/**
 * 12-imagenes-del-cliente.php — Importtools Latam, 03/08/2026
 * ---------------------------------------------------------------------------
 * Cambia dos imagenes dentro del contenido de Leo Elements:
 *
 *   1. Medios de pago del pie. El widget `c4b1de6` (image de Elementor) servia
 *      el sprite de la plantilla, /img/it/vt_autosoe_home1_payment.png, con
 *      American Express, Bitcoin, Apple Pay, Discover, Diners, VISA y JCB.
 *      Esta tienda no cobra en linea con ninguno de ellos. Se sustituye por
 *      /img/it/pagos-autorizados.png: Bancolombia, Banco de Bogota y Davivienda.
 *
 *   2. Banda de suscripcion del pie (`a0df6a6`). Tenia de fondo
 *      /img/it/banner-med-a.jpg, uno de los degradados provisionales. Pasa a
 *      /img/it/pie-asesor.png, la foto del asesor en el local del cliente.
 *
 * ⚠️ Se cambian SOLO las rutas de fichero, con una sustitucion de texto plano
 *    dentro del JSON. Dentro del JSON las barras van escapadas como \/ : buscar
 *    con la barra sin escapar no encuentra nada y el script fallaria en silencio.
 *    Encajar y posicion se ajustan por CSS (custom.css §14), no aqui: tocar mas
 *    claves del JSON es justo lo que corrompe los contenidos de Leo.
 *
 * Uso (dentro del contenedor / en el servidor, junto a la BD):
 *     php 12-imagenes-del-cliente.php seco     # solo informa
 *     php 12-imagenes-del-cliente.php
 *
 * Despues es OBLIGATORIO invalidar el CSS que Leo guarda en cache:
 *     DELETE FROM psjy_leoelements_meta WHERE name LIKE '%elementor_css%';
 *     rm -rf var/cache/*  assets/cache/*  modules/leoelements/gencode/*
 */

$HOST = getenv('IT_DB_HOST') ?: 'db';
$USER = getenv('IT_DB_USER') ?: 'root';
$PASS = getenv('IT_DB_PASS') ?: 'root';
$NAME = getenv('IT_DB_NAME') ?: 'importtools';
$PREF = getenv('IT_DB_PREFIX') ?: 'psjy_';

$db = new mysqli($HOST, $USER, $PASS, $NAME);
if ($db->connect_error) { fwrite(STDERR, "no conecta: {$db->connect_error}\n"); exit(1); }
$db->set_charset('utf8mb4');

/**
 * ⚠️ El alcance importa. `vt_autosoe_home1_payment.png` solo aparece en el pie,
 * asi que se puede cambiar en cualquier contenido. Pero `banner-med-a.jpg` se usa
 * ademas en el cuerpo del home y en la cabecera de las categorias: la primera
 * prueba en seco encontro 40 coincidencias en 18 filas (contenidos 3, 4, 7, 8, 11,
 * 12, 15, 16 y 17). Cambiarlas todas habria puesto la foto del asesor detras de
 * banners que no tienen nada que ver.
 * Los contenidos del pie son el 12 y sus dos copias (4 y 8), y ahi las dos
 * apariciones son las del fondo y el velo de la banda `a0df6a6`.
 */
$CAMBIOS = [
    ['de' => '\\/img\\/it\\/vt_autosoe_home1_payment.png', 'a' => '\\/img\\/it\\/pagos-autorizados.png', 'solo' => null],
    ['de' => '\\/img\\/it\\/banner-med-a.jpg',             'a' => '\\/img\\/it\\/pie-asesor.png',        'solo' => [4, 8, 12]],
];

$seco = isset($argv[1]) && $argv[1] === 'seco';
$tabla = $PREF . 'leoelements_contents_lang';

$r = $db->query("SELECT id_leoelements_contents id, id_lang l, content FROM $tabla");
$tocadas = 0; $saltadas = 0; $sust = 0;

while ($f = $r->fetch_assoc()) {
    $antes = $f['content'];
    $ahora = $antes;
    $n = 0;
    foreach ($CAMBIOS as $cambio) {
        if ($cambio['solo'] !== null && !in_array((int) $f['id'], $cambio['solo'], true)) { continue; }
        $c = 0;
        $ahora = str_replace($cambio['de'], $cambio['a'], $ahora, $c);
        $n += $c;
    }
    if ($n === 0) { continue; }

    // El JSON tiene que seguir siendo valido: si no, el contenido de Leo queda
    // inservible y el editor del back office no lo abre.
    json_decode($ahora);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo "  JSON invalido tras sustituir en {$f['id']}/{$f['l']}: se salta\n";
        $saltadas++;
        continue;
    }

    echo "  contenido {$f['id']} / idioma {$f['l']}: $n sustitucion(es)\n";
    $sust += $n;
    $tocadas++;

    if ($seco) { continue; }

    $st = $db->prepare("UPDATE $tabla SET content=? WHERE id_leoelements_contents=? AND id_lang=?");
    $st->bind_param('sii', $ahora, $f['id'], $f['l']);
    $st->execute();
}

echo $seco
    ? "  SECO: $tocadas filas cambiarian, $sust sustituciones\n"
    : "  $tocadas filas actualizadas, $sust sustituciones\n";
if ($saltadas) { echo "  ATENCION: $saltadas filas saltadas por JSON invalido\n"; }

$mal = $db->query("SELECT COUNT(*) n FROM $tabla WHERE JSON_VALID(content)=0")->fetch_assoc()['n'];
echo "  filas con JSON invalido en la tabla: $mal\n";

if (!$seco) {
    $db->query("DELETE FROM {$PREF}leoelements_meta WHERE name LIKE '%elementor_css%'");
    echo "  cache de CSS de Leo invalidada ({$db->affected_rows} filas)\n";
}
