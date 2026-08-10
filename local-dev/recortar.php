<?php
/**
 * Recorta y amplia un trozo de una captura, para mirar un detalle sin tener que
 * abrir la imagen entera (a 1440x3000 el detalle de un icono no se ve).
 *
 * Uso:  php recortar.php <entrada.png> <salida.png> <x> <y> <ancho> <alto> [escala]
 * Se ejecuta dentro del contenedor web, que trae GD compilado.
 */
if ($argc < 7) {
    fwrite(STDERR, "uso: recortar.php entrada salida x y ancho alto [escala]\n");
    exit(1);
}
list(, $ent, $sal, $x, $y, $w, $h) = $argv;
$escala = isset($argv[7]) ? (float) $argv[7] : 2.0;

$src = imagecreatefrompng($ent);
if (!$src) { fwrite(STDERR, "no se pudo leer $ent\n"); exit(1); }

// Recortar a lo que de verdad existe: pedir de mas devolveria negro
$x = max(0, (int) $x); $y = max(0, (int) $y);
$w = min((int) $w, imagesx($src) - $x);
$h = min((int) $h, imagesy($src) - $y);

$dst = imagecreatetruecolor((int) ($w * $escala), (int) ($h * $escala));
imagecopyresampled($dst, $src, 0, 0, $x, $y, (int) ($w * $escala), (int) ($h * $escala), $w, $h);
imagepng($dst, $sal);
echo "recortado {$w}x{$h} desde ($x,$y) x{$escala} -> $sal\n";
