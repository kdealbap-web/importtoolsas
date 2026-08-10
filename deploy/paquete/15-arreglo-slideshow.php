<?php
/**
 * 15 — Arreglo del guardado de banners (LeoSlideshow) · 08/08/2026
 * ---------------------------------------------------------------------------
 * Ejecutar UNA vez tras subir los ficheros de esta ronda:
 *     php deploy/paquete/15-arreglo-slideshow.php
 * (en cPanel: Terminal, o programador de tareas «una vez»)
 *
 * Hace dos cosas, las dos comprobadas contra el espejo:
 *
 *  1. Registra el hook `actionAdminControllerSetMedia` en el modulo propio
 *     `itcotizacion`. El modulo ya estaba instalado, asi que su `install()` no
 *     se vuelve a ejecutar y el hook nuevo hay que darlo de alta a mano.
 *     Ese hook carga `arreglo-leoslideshow.js`, que es lo que evita que el
 *     guardado de banners salga a otro dominio y que los errores sean mudos.
 *
 *  2. Deja `LEOSLIDESHOW_GROUP_DE` apuntando al grupo que SI se ve en la
 *     portada. Estaba en 4 («Slide Home 5»), un grupo que no usa ninguna
 *     pagina: el cliente editaba banners que no salian en ningun sitio.
 *     Comprobado cruzando el `randkey` de cada grupo con el JSON de
 *     `leoelements_contents_lang`: solo aparecen el 3 (escritorio) y el 5 (movil).
 *
 * Es idempotente: se puede volver a ejecutar sin efectos secundarios.
 */

// Busca la raiz de PrestaShop subiendo desde donde este el fichero. Asi da igual
// que se ejecute desde deploy/paquete/ o suelto en el docroot.
$raiz = null;
for ($dir = __DIR__, $i = 0; $i < 6; $i++, $dir = dirname($dir)) {
    if (file_exists($dir . '/config/config.inc.php')) {
        $raiz = $dir;
        break;
    }
}
if ($raiz === null) {
    fwrite(STDERR, "No encuentro config/config.inc.php. Ejecutalo dentro de la carpeta de la tienda.\n");
    exit(1);
}
require_once $raiz . '/config/config.inc.php';

echo "=== 15 — Arreglo del guardado de banners ===\n\n";

/* ---------------------------------------------------------------- 1. hook -- */
$modulo = Module::getInstanceByName('itcotizacion');
if (!$modulo || !Validate::isLoadedObject($modulo)) {
    echo "  [!] El modulo itcotizacion no esta instalado. Se omite el paso 1.\n";
} else {
    $id_hook = (int) Hook::getIdByName('actionAdminControllerSetMedia');
    if (!$id_hook) {
        echo "  [!] El hook actionAdminControllerSetMedia no existe en esta tienda.\n";
    } else {
        $ya = (int) Db::getInstance()->getValue(
            'SELECT COUNT(*) FROM ' . _DB_PREFIX_ . 'hook_module
              WHERE id_module = ' . (int) $modulo->id . ' AND id_hook = ' . $id_hook
        );
        if ($ya) {
            echo "  [=] El hook ya estaba registrado.\n";
        } elseif ($modulo->registerHook('actionAdminControllerSetMedia')) {
            echo "  [OK] Hook actionAdminControllerSetMedia registrado en itcotizacion.\n";
        } else {
            echo "  [!] No se pudo registrar el hook.\n";
        }
    }
}

/* ------------------------------------------------- 2. grupo por defecto ---- */
$actual = (int) Configuration::get('LEOSLIDESHOW_GROUP_DE');
echo "\n  Grupo que abre el menu del slideshow: $actual\n";

$grupos = Db::getInstance()->executeS(
    'SELECT id_leoslideshow_groups AS id, title, randkey FROM ' . _DB_PREFIX_ . 'leoslideshow_groups'
);

$en_uso = [];
foreach ($grupos as $g) {
    if (empty($g['randkey'])) {
        continue;
    }
    $n = (int) Db::getInstance()->getValue(
        'SELECT COUNT(*) FROM ' . _DB_PREFIX_ . 'leoelements_contents_lang
          WHERE content LIKE "%' . pSQL($g['randkey']) . '%"'
    );
    echo sprintf("    grupo %d  %-16s  usado en %d contenido(s)\n", $g['id'], $g['title'], $n);
    if ($n > 0) {
        $en_uso[] = (int) $g['id'];
    }
}

if (!$en_uso) {
    echo "\n  [!] Ningun grupo aparece en los contenidos. No se toca nada.\n";
} elseif (in_array($actual, $en_uso, true)) {
    echo "\n  [=] El grupo $actual si se usa. No hace falta cambiarlo.\n";
} else {
    $nuevo = min($en_uso);
    Configuration::updateValue('LEOSLIDESHOW_GROUP_DE', $nuevo);
    echo "\n  [OK] Cambiado de $actual a $nuevo (el $actual no se muestra en ninguna pagina).\n";
}

echo "\n=== Terminado ===\n";
echo "Comprueba: entra al panel, Diseño → Leo Slideshow Configuration, edita un\n";
echo "banner y guarda. Debe recargar y conservar el cambio. Si algo falla, ahora\n";
echo "SI sale un aviso rojo en pantalla en vez de quedarse bloqueado.\n";
