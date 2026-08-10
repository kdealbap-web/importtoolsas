<?php
/**
 * 17 — Contenido de las páginas CMS · 08/08/2026
 * ---------------------------------------------------------------------------
 * Carga en `psjy_cms_lang` el HTML versionado de las dos páginas que el cliente
 * pidió cambiar. La fuente de verdad son los ficheros del repositorio:
 *
 *     deploy/paquete/contenido/quienes-somos.html      -> id_cms 4
 *     deploy/paquete/contenido/quiero-ser-cliente.html -> id_cms 7
 *
 * Cambios de esta ronda:
 *   · Quiénes somos    — actividad económica nueva; la tarjeta que muestra un
 *                        ventilador pasa a llamarse «Ventiladores industriales»
 *                        y enlaza a la categoría 24 (antes decía «Herramientas
 *                        de aire» y llevaba a la 11, que son compresores);
 *                        foto real del cliente en el hero; banda nueva «Sé
 *                        nuestro cliente».
 *   · Quiero ser cliente — foto real del cliente en el hero y formulario
 *                        desplegable en el paso 02.
 *
 * Uso:
 *     php deploy/paquete/17-contenido-cms-20260808.php            (aplica)
 *     php deploy/paquete/17-contenido-cms-20260808.php --simular  (no escribe)
 *
 * Antes de escribir guarda una copia de lo que había en
 * `deploy/paquete/contenido/respaldo-AAAAMMDD-HHMM/`, por si hay que volver.
 */

$simular = in_array('--simular', $argv, true);

$raiz = null;
for ($dir = __DIR__, $i = 0; $i < 6; $i++, $dir = dirname($dir)) {
    if (file_exists($dir . '/config/config.inc.php')) {
        $raiz = $dir;
        break;
    }
}
if ($raiz === null) {
    fwrite(STDERR, "No encuentro config/config.inc.php.\n");
    exit(1);
}
require_once $raiz . '/config/config.inc.php';

$paginas = [
    4 => __DIR__ . '/contenido/quienes-somos.html',
    7 => __DIR__ . '/contenido/quiero-ser-cliente.html',
];

echo "=== 17 — Contenido de las páginas CMS ===\n";
echo $simular ? "MODO SIMULACIÓN: no se escribe nada.\n\n" : "\n";

$carpeta_respaldo = __DIR__ . '/contenido/respaldo-' . date('Ymd-Hi');
if (!$simular && !is_dir($carpeta_respaldo)) {
    mkdir($carpeta_respaldo, 0755, true);
}

$idiomas = Language::getLanguages(false);

foreach ($paginas as $id_cms => $fichero) {
    if (!file_exists($fichero)) {
        echo "  [!] Falta el fichero " . basename($fichero) . ". Se omite.\n";
        continue;
    }
    $html = file_get_contents($fichero);
    echo "  CMS $id_cms  <- " . basename($fichero) . " (" . number_format(strlen($html)) . " bytes)\n";

    foreach ($idiomas as $lang) {
        $id_lang = (int) $lang['id_lang'];

        $antes = Db::getInstance()->getValue(
            'SELECT content FROM ' . _DB_PREFIX_ . 'cms_lang
              WHERE id_cms = ' . (int) $id_cms . ' AND id_lang = ' . $id_lang
        );
        if ($antes === false || $antes === null) {
            echo "      lang $id_lang: no existe la fila. Se omite.\n";
            continue;
        }

        if (!$simular) {
            file_put_contents(
                $carpeta_respaldo . "/cms{$id_cms}-lang{$id_lang}.html",
                $antes
            );
        }

        if ($antes === $html) {
            echo "      lang $id_lang: ya estaba al día (" . number_format(strlen($antes)) . " bytes).\n";
            continue;
        }

        if ($simular) {
            echo "      lang $id_lang: cambiaría de " . number_format(strlen($antes))
               . " a " . number_format(strlen($html)) . " bytes.\n";
            continue;
        }

        Db::getInstance()->update(
            'cms_lang',
            ['content' => pSQL($html, true)],
            'id_cms = ' . (int) $id_cms . ' AND id_lang = ' . $id_lang
        );
        echo "      lang $id_lang: actualizado ("
           . number_format(strlen($antes)) . " -> " . number_format(strlen($html)) . " bytes).\n";
    }
}

if (!$simular) {
    echo "\n  Copia de lo anterior en: " . basename($carpeta_respaldo) . "/\n";
}

echo "\n=== Comprobaciones ===\n";
echo "  /content/4-quienes-somos      -> «Ventiladores industriales» y la banda «Sé nuestro cliente»\n";
echo "  /content/7-quiero-ser-cliente -> botón «Dejar mis datos» en el paso 02\n";
echo "  Vacía la caché después: var/cache/, y el CSS de Elementor si tocaste widgets.\n";
