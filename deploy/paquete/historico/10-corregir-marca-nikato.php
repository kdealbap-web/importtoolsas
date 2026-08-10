<?php
/**
 * Corrige la marca: NIKATTO -> NIKATO.
 * El logotipo dice NIKATO® con una T; el error venia del archivo del cliente
 * («GRUPO NIKATTO») y se propago a los 1.381 productos.
 * Se respeta la convencion de la tienda: capitalizacion normal, como
 * «Dragon Tools», «Proweld» o «Ventum».
 */
$db = new mysqli('db','root','root','importtools');
$db->set_charset('utf8mb4');

$pares = [
    'NIKATTO'  => 'NIKATO',
    'Nikatto'  => 'Nikato',
    'nikatto'  => 'nikato',
];

$tablas = [
    ['psjy_manufacturer',              ['name'],                                  ['id_manufacturer']],
    ['psjy_manufacturer_lang',         ['description','short_description','meta_title','meta_description','meta_keywords'], ['id_manufacturer','id_lang']],
    ['psjy_btmegamenu_lang',           ['title'],                                 ['id_btmegamenu','id_lang']],
    ['psjy_btmegamenu',                ['item_parameter','content'],              ['id_btmegamenu']],
    ['psjy_leoelements_contents_lang', ['content','content_autosave'],            ['id_leoelements_contents','id_lang']],
    ['psjy_product_lang',              ['name','description','description_short','meta_title'], ['id_product','id_lang','id_shop']],
    ['psjy_cms_lang',                  ['content'],                               ['id_cms','id_lang']],
    ['psjy_configuration',             ['value'],                                 ['id_configuration']],
];

$total = 0; $saltados = 0; $detalle = [];
foreach ($tablas as [$t, $cols, $claves]) {
    foreach ($cols as $c) {
        $sel = implode(',', array_map(fn($k)=>"`$k`", $claves));
        $r = @$db->query("SELECT $sel, `$c` AS v FROM `$t` WHERE `$c` LIKE '%nikatto%'");
        if (!$r) continue;
        while ($f = $r->fetch_assoc()) {
            $nuevo = str_replace(array_keys($pares), array_values($pares), $f['v']);
            if ($nuevo === $f['v']) continue;
            if ($c === 'content' || $c === 'content_autosave') {
                if ($f['v'] !== '' && json_decode($f['v']) !== null) {
                    json_decode($nuevo);
                    if (json_last_error() !== JSON_ERROR_NONE) { $saltados++; continue; }
                }
            }
            $where = implode(' AND ', array_map(fn($k)=>"`$k`=?", $claves));
            $args = [$nuevo]; foreach ($claves as $k) { $args[] = (int)$f[$k]; }
            $st = $db->prepare("UPDATE `$t` SET `$c`=? WHERE $where");
            $st->bind_param('s'.str_repeat('i',count($claves)), ...$args);
            $st->execute();
            if ($st->affected_rows) { $total += $st->affected_rows; $detalle["$t.$c"] = ($detalle["$t.$c"] ?? 0) + $st->affected_rows; }
        }
    }
}
foreach ($detalle as $k=>$n) printf("  %-42s %d\n", $k, $n);
printf("  TOTAL: %d filas · saltadas por JSON: %d\n\n", $total, $saltados);

// que queda
foreach (['psjy_manufacturer'=>'name','psjy_product_lang'=>'name','psjy_leoelements_contents_lang'=>'content','psjy_btmegamenu_lang'=>'title'] as $t=>$c) {
  $n = $db->query("SELECT COUNT(*) n FROM `$t` WHERE `$c` LIKE '%nikatto%'")->fetch_assoc()['n'];
  printf("  quedan en %-34s %s\n", "$t.$c:", $n);
}
printf("  JSON de Leo roto: %s\n", $db->query("SELECT COUNT(*) n FROM psjy_leoelements_contents_lang WHERE JSON_VALID(content)=0")->fetch_assoc()['n']);
echo "\n  marca ahora:\n";
$r = $db->query("SELECT m.id_manufacturer, m.name, COUNT(p.id_product) n FROM psjy_manufacturer m LEFT JOIN psjy_product p ON p.id_manufacturer=m.id_manufacturer GROUP BY m.id_manufacturer, m.name ORDER BY n DESC LIMIT 3");
while ($f = $r->fetch_assoc()) printf("    id %s  %-14s %s productos\n", $f['id_manufacturer'], $f['name'], $f['n']);

/* ============================================================================
   NOTA — dos sitios que este script NO cubre y hay que tocar aparte:

     psjy_btmegamenu_lang.url         el enlace del submenu MARCAS, que sale en
                                      la cabecera de TODAS las paginas
     psjy_meta_lang.description       la descripcion SEO de /brands

   UPDATE psjy_btmegamenu_lang SET url = REPLACE(url,'nikatto','nikato')
    WHERE url LIKE '%nikatto%';
   UPDATE psjy_meta_lang SET description = REPLACE(description,'Nikatto','Nikato')
    WHERE description LIKE '%nikatto%';

   Y despues, vaciar la cache de bloques de la busqueda por facetas, que guarda
   los nombres de los filtros ya renderizados:

   TRUNCATE psjy_layered_filter_block;

   Sin eso el filtro sigue diciendo «Nikatto» aunque la marca ya este bien.
   ============================================================================ */

/* ============================================================================
   ANADIDO 01/08 — enlace roto en la barra inferior del movil
   El icono «Catálogo» apuntaba a «2-home», que dejo de existir cuando la
   categoria raiz se renombro a «Catálogo» (/2-catalogo).
   Va dentro del JSON de Elementor como objeto de enlace, NO como href:
       "link":{"url":"2-home", ...}
   Reemplazo:  "url":"2-home"  ->  "url":"/2-catalogo"      (8 filas)
   ============================================================================ */
