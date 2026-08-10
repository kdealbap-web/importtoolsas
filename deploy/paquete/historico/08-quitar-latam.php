<?php
/**
 * Unifica el nombre a «Importtools S.A.S». Reemplazo de texto plano; en el JSON
 * de Elementor no se recodifica nada y se valida antes de guardar.
 */
$db = new mysqli('db','root','root','importtools');
$db->set_charset('utf8mb4');

$cambios = [
    // la linea legal vuelve a quedar con un solo nombre
    'Importtools S.A.S<\/span> &mdash; Import Tools Latam S.A.S, NIT' => 'Importtools S.A.S<\/span> &mdash; NIT',
    'Importtools S.A.S</span> &mdash; Import Tools Latam S.A.S, NIT'   => 'Importtools S.A.S</span> &mdash; NIT',
    // variantes del nombre
    'Import Tools Latam S.A.S' => 'Importtools S.A.S',
    'Importtools Latam S.A.S'  => 'Importtools S.A.S',
    'ImportTools Latam SAS'    => 'Importtools S.A.S',
    'Import Tools Latam SAS'   => 'Importtools S.A.S',
    'Importtools Latam SAS'    => 'Importtools S.A.S',
];

$tablas = [
    ['psjy_cms_lang',                   ['content','meta_title','meta_description'], ['id_cms','id_lang']],
    ['psjy_leoelements_contents_lang',  ['content','content_autosave'],              ['id_leoelements_contents','id_lang']],
    ['psjy_configuration',              ['value'],                                   ['id_configuration']],
    ['psjy_configuration_lang',         ['value'],                                   ['id_configuration','id_lang']],
    ['psjy_meta_lang',                  ['title','description'],                     ['id_meta','id_lang']],
];

$total = 0; $saltados = 0;
foreach ($tablas as [$t, $cols, $claves]) {
    foreach ($cols as $c) {
        $sel = implode(',', array_map(fn($k) => "`$k`", $claves));
        $r = $db->query("SELECT $sel, `$c` AS v FROM `$t` WHERE `$c` LIKE '%Latam%'");
        if (!$r) { continue; }
        while ($f = $r->fetch_assoc()) {
            $nuevo = $f['v'];
            foreach ($cambios as $de => $a) { $nuevo = str_replace($de, $a, $nuevo); }
            if ($nuevo === $f['v']) { continue; }

            // si la columna guarda JSON, no se toca si quedaria invalido
            if ($c === 'content' || $c === 'content_autosave') {
                if ($f['v'] !== '' && json_decode($f['v']) !== null) {
                    json_decode($nuevo);
                    if (json_last_error() !== JSON_ERROR_NONE) { $saltados++; continue; }
                }
            }

            $where = implode(' AND ', array_map(fn($k) => "`$k`=?", $claves));
            $tipos = 's' . str_repeat('i', count($claves));
            $args  = [$nuevo];
            foreach ($claves as $k) { $args[] = (int) $f[$k]; }
            $st = $db->prepare("UPDATE `$t` SET `$c`=? WHERE $where");
            $st->bind_param($tipos, ...$args);
            $st->execute();
            $total += $st->affected_rows;
        }
    }
}
printf("  filas actualizadas: %d · saltadas por JSON: %d\n", $total, $saltados);

foreach (['psjy_cms_lang'=>'content','psjy_leoelements_contents_lang'=>'content','psjy_configuration'=>'value'] as $t=>$c) {
    $n = $db->query("SELECT COUNT(*) n FROM `$t` WHERE `$c` LIKE '%Latam%'")->fetch_assoc()['n'];
    printf("  %-32s quedan con Latam: %s\n", $t, $n);
}
printf("  contenidos Leo con JSON roto: %s\n",
    $db->query("SELECT COUNT(*) n FROM psjy_leoelements_contents_lang WHERE JSON_VALID(content)=0")->fetch_assoc()['n']);
