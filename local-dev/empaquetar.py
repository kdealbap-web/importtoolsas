#!/usr/bin/env python3
"""Rehace los .zip del paquete de despliegue.

⚠️ NO usar `Compress-Archive` de Windows PowerShell 5.1 para esto: escribe los
nombres de entrada con BARRA INVERTIDA (`vt_autosoe_child\\assets\\css\\custom.css`),
que va contra la especificacion ZIP —el apendice 4.4.17.1 exige `/`—. Al
descomprimirlo en el servidor (Linux, cPanel o `unzip`) no se crean carpetas:
sale un fichero plano llamado literalmente `vt_autosoe_child\\assets\\css\\custom.css`.
Comprobado sobre los zips generados asi el 03/08/2026.

`zipfile` de Python siempre normaliza a `/`.

Uso:
    python local-dev/empaquetar.py            # rehace los cinco
    python local-dev/empaquetar.py tema       # solo uno
"""
import os
import sys
import zipfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PAQ = os.path.join(RAIZ, 'deploy', 'paquete')

# nombre -> (carpeta de origen, prefijo dentro del zip)
#   prefijo '' = el contenido va a la raiz del zip
PAQUETES = {
    'tema': (
        'vt_autosoe_child-EXTRAER-EN-themes.zip',
        os.path.join(RAIZ, 'theme-autosoe', 'vt_autosoe_child'),
        'vt_autosoe_child',
    ),
    'tema-panel': (
        'vt_autosoe_child-SUBIR-POR-PANEL.zip',
        os.path.join(RAIZ, 'theme-autosoe', 'vt_autosoe_child'),
        '',
    ),
    'modulo': (
        'itcotizacion-EXTRAER-EN-modules.zip',
        os.path.join(RAIZ, 'modules-custom', 'itcotizacion'),
        'itcotizacion',
    ),
    # `deploy/img/` es EXACTAMENTE lo que sube al servidor: todo lo que hay ahí
    # entra en el zip, sin excepciones que haya que recordar. Los originales que
    # manda el cliente (de 1 a 2 MB cada uno, la fuente de la que se recortan los
    # ficheros de `it/`) viven aparte, en `deploy/originales-cliente/`.
    'imagenes': (
        'img-importtools.zip',
        os.path.join(RAIZ, 'deploy', 'img'),
        '',
    ),
    'traducciones': (
        'modulos-traducciones-EXTRAER-EN-modules.zip',
        os.path.join(PAQ, 'modules'),
        '',
    ),
}


def empaquetar(clave):
    nombre, origen, prefijo = PAQUETES[clave]
    destino = os.path.join(PAQ, nombre)
    if not os.path.isdir(origen):
        print('  FALTA el origen: %s' % origen)
        return
    n = 0
    with zipfile.ZipFile(destino, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for base, _dirs, ficheros in os.walk(origen):
            for f in sorted(ficheros):
                completo = os.path.join(base, f)
                rel = os.path.relpath(completo, origen).replace(os.sep, '/')
                z.write(completo, ('%s/%s' % (prefijo, rel)) if prefijo else rel)
                n += 1
    print('  %-45s %5d ficheros  %7.1f MB' % (nombre, n, os.path.getsize(destino) / 1048576))


def comprobar(clave):
    """Que ninguna entrada lleve `\\`, que es el fallo que se quiere evitar."""
    nombre = PAQUETES[clave][0]
    with zipfile.ZipFile(os.path.join(PAQ, nombre)) as z:
        malas = [e for e in z.namelist() if '\\' in e]
    print('  %-45s %s' % (nombre, 'OK' if not malas else 'MAL: %d entradas con \\' % len(malas)))


if __name__ == '__main__':
    claves = sys.argv[1:] or list(PAQUETES)
    print('Empaquetando:')
    for c in claves:
        empaquetar(c)
    print('Comprobando separadores:')
    for c in claves:
        comprobar(c)
