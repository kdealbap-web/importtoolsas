#!/usr/bin/env python3
# ---------------------------------------------------------------------------
# preparar-imagenes-cliente.py — 12/08/2026
#
# Convierte las 16 fotos que entrego el cliente a los ficheros que la tienda
# pide, con el nombre y el formato que corresponde a cada hueco del home.
#
# El emparejamiento NO se adivino: para cada hueco se midio (a) el texto que
# lleva el bloque en el HTML de produccion, (b) la dimension del fichero que hay
# hoy y (c) el nombre que el cliente le puso a su foto. Los tres coinciden en
# los 16 casos. El detalle esta en deploy/paquete/29-PASO-A-PASO-20260812.md.
#
# ⚠️ Diez ficheros se sobrescriben con el MISMO nombre porque cada uno lo usa un
# solo bloque. Seis NO se pueden sobrescribir: `banner-med-a.jpg` y
# `banner-med-b.jpg` los comparten TRES bloques distintos cada uno (una banda del
# home, una tarjeta del carrusel de categorias y una banda de las paginas de
# categoria), y cada bloque lleva una foto diferente. Para esos seis se crean
# ficheros nuevos y hay que repuntar el JSON de Leo Elements con
# deploy/paquete/29-imagenes-cliente.sql.
#
# Uso:  python3 local-dev/preparar-imagenes-cliente.py [--dry-run]
# ---------------------------------------------------------------------------
import os
import shutil
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("ERROR: falta Pillow.  pip install Pillow")

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMG = os.path.join(RAIZ, "deploy", "img", "it")
RESP = os.path.join(IMG, "_respaldo-20260812")

CALIDAD = 88

#   origen (lo que envio el cliente)      destino            que hueco ocupa
TAREAS = [
    # --- se sobrescriben: el fichero lo usa un solo bloque -----------------
    ("Tornilleria (1).png",              "tornilleria.jpg",  "tarjeta «Tornilleria»"),
    ("H Manuales.jpg.jpeg",              "manuales.jpg",     "tarjeta «Herramientas Manuales»"),
    ("H Electricas.jpg.jpeg",            "electricas.jpg",   "tarjeta «Herramientas Electricas»"),
    ("Automotriz.jpg.jpeg",              "automotriz.jpg",   "tarjeta «Herramienta Automotriz»"),
    ("Soldadura.jpg.jpeg",               "soldadura.jpg",    "tarjeta «Herramientas de Soldadura»"),
    ("Seguridad Industrial.jpg.jpeg",    "seguridad.jpg",    "tarjeta «Seguridad Industrial»"),
    ("Herramientas electricas.png",      "banner-ancho.jpg", "panel vertical «Herramienta electrica»"),

    # --- nuevos: hay que repuntar el JSON ---------------------------------
    ("H medicion.jpg.jpeg",              "medicion.jpg",        "tarjeta «Herramientas de Medicion»"),
    ("Herramienta de corte.jpg.jpeg",    "corte.jpg",           "tarjeta «Herramientas de Corte»"),
    ("Tornilleria_2_variar.png",         "bulto.jpg",           "banda «Mayoristas / Compra por bulto»"),
    ("Marca Nikatto.jpg.jpeg",           "nikatto.jpg",         "banda «Marca propia / Marca Nikato»"),
    ("Mas de 3.000 referencias.jpg.jpeg","cat-referencias.jpg", "banda de categoria «mas de 3.000 referencias»"),
    ("precios por volumen.jpg.jpeg",     "cat-volumen.jpg",     "banda de categoria «precios por volumen»"),
]

# Las tres tarjetas de 450x360 las hizo la ronda anterior del 12/08; se listan
# aqui para que quede constancia de los 16 y para poder comprobarlas.
YA_HECHAS = [
    ("Tornilleria.png",              "banner-a.jpg", "tarjeta «Esta semana / Tornilleria»"),
    ("Todo para taller.jpg.jpeg",    "banner-b.jpg", "tarjeta «Todo para el taller»"),
    ("Lo que mas se vende.jpg.jpeg", "banner-c.jpg", "tarjeta «lo mas pedido / mas vendidos»"),
]


def luminancia(ruta):
    """Luminancia media, para comprobar que un destino contiene su origen."""
    im = Image.open(ruta).convert("L").resize((32, 32))
    px = list(im.getdata())
    return round(sum(px) / len(px), 1)


def main():
    seco = "--dry-run" in sys.argv
    if not seco:
        os.makedirs(RESP, exist_ok=True)

    print("Comprobando las tres que ya se hicieron (luminancia origen vs destino)")
    for origen, destino, hueco in YA_HECHAS:
        po, pd = os.path.join(IMG, origen), os.path.join(IMG, destino)
        if not (os.path.isfile(po) and os.path.isfile(pd)):
            print("  %-16s FALTA alguno de los dos ficheros" % destino)
            continue
        lo, ld = luminancia(po), luminancia(pd)
        # Un JPEG de calidad 88 no mueve la luminancia media ni un 5 %.
        ok = abs(lo - ld) <= max(2.0, lo * 0.05)
        print("  %-16s <- %-32s lum %5.1f / %5.1f  %s" %
              (destino, origen, lo, ld, "COINCIDE" if ok else "⚠️ NO COINCIDE"))

    print("\nConvirtiendo (%s)" % ("dry-run" if seco else "escribiendo"))
    for origen, destino, hueco in TAREAS:
        po = os.path.join(IMG, origen)
        pd = os.path.join(IMG, destino)
        if not os.path.isfile(po):
            sys.exit("ERROR: no existe el origen %s" % po)

        im = Image.open(po)
        w, h = im.size
        antes = ""
        if os.path.isfile(pd):
            vieja = Image.open(pd)
            antes = "  (habia %dx%d, %d KB)" % (vieja.size[0], vieja.size[1],
                                                os.path.getsize(pd) // 1024)
            vieja.close()

        print("  %-22s <- %-34s %4dx%-4d  %s%s" %
              (destino, origen, w, h, hueco, antes))
        if seco:
            im.close()
            continue

        # Respaldo del que se pisa, una sola vez: si ya hay respaldo es que este
        # script ya corrio y el original de verdad es el del respaldo.
        if os.path.isfile(pd):
            guardado = os.path.join(RESP, destino)
            if not os.path.isfile(guardado):
                shutil.copy2(pd, guardado)

        # Fondo blanco al aplanar: los PNG del cliente traen canal alfa y sin
        # esto el transparente sale NEGRO en el JPEG.
        if im.mode in ("RGBA", "LA", "P"):
            im = im.convert("RGBA")
            plano = Image.new("RGB", im.size, (255, 255, 255))
            plano.paste(im, mask=im.split()[-1])
            im = plano
        else:
            im = im.convert("RGB")

        im.save(pd, "JPEG", quality=CALIDAD, optimize=True, progressive=True)
        im.close()
        print("      -> %d KB" % (os.path.getsize(pd) // 1024))

    if not seco:
        print("\nRespaldo de lo sobrescrito en: %s" % RESP)


if __name__ == "__main__":
    main()
