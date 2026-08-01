<?php
/**
 * Añade el acceso a la cotización en la cabecera, justo detrás del icono de la
 * lista de deseos. Insercion de texto plano en el JSON: no se recodifica nada.
 * Ojo con el escapado: dentro del JSON las comillas van como \" y las barras
 * como \/ — buscar sin escapar no encuentra nada y falla en silencio.
 */
$db = new mysqli('db','root','root','importtools');
$db->set_charset('utf8mb4');

$ancla = '<span class=\"ap-total-wishlist ap-total\"><\/span>\r\n    <\/a>    \r\n<\/div>';

$nuevo = $ancla
  . '\r\n<div class=\"header__button--cotizar\">\r\n'
  . '<a class=\"itcot-acceso\" href=\"{url entity=\'module\' name=\'itcotizacion\' controller=\'cotizacion\'}\" '
  . 'title=\"{l s=\'Mi cotización\' d=\'Modules.Itcotizacion.Shop\'}\" rel=\"nofollow\">\r\n'
  . '<i class=\"fa-light fa-file-invoice\"><\/i>\r\n'
  . '<span class=\"itcot-contador itcot-contador--vacio\">0<\/span>\r\n'
  . '<\/a>\r\n<\/div>';

$seco = isset($argv[1]) && $argv[1] === 'seco';

$r = $db->query("SELECT id_leoelements_contents id, id_lang l, content FROM psjy_leoelements_contents_lang WHERE content LIKE '%ap-total-wishlist%'");
$hay = 0; $hecho = 0;
while ($f = $r->fetch_assoc()) {
    if (strpos($f['content'], 'header__button--cotizar') !== false) { continue; }   // ya puesto
    if (strpos($f['content'], $ancla) === false) { continue; }
    $hay++;
    if ($seco) { echo "  coincide: contenido {$f['id']} / idioma {$f['l']}\n"; continue; }

    $mod = str_replace($ancla, $nuevo, $f['content']);
    json_decode($mod);
    if (json_last_error() !== JSON_ERROR_NONE) { echo "  JSON roto en {$f['id']}/{$f['l']}, se salta\n"; continue; }
    $st = $db->prepare('UPDATE psjy_leoelements_contents_lang SET content=? WHERE id_leoelements_contents=? AND id_lang=?');
    $st->bind_param('sii', $mod, $f['id'], $f['l']);
    $st->execute();
    $hecho++;
}
echo $seco ? "  filas que coincidirian: $hay\n" : "  filas modificadas: $hecho de $hay\n";
echo "  JSON roto en total: " . $db->query("SELECT COUNT(*) n FROM psjy_leoelements_contents_lang WHERE JSON_VALID(content)=0")->fetch_assoc()['n'] . "\n";
