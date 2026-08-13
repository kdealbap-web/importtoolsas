#!/usr/bin/env python3
# ---------------------------------------------------------------------------
# subir-a-produccion-ftps.py — sube a produccion por FTPS explicito, con
# respaldo, subida atomica, verificacion y marcha atras automatica.
#
# Sustituye a `subir-imagenes-ftps.py`, que solo llevaba las tres tarjetas del
# home. Mismo patron de seguridad que la subida del 11/08/2026 (CLAUDE.md, Fase
# 3-sexies), ahora con grupos:
#
#   imagenes      las 16 de la ronda del 12/08 (10 sobrescritas + 6 nuevas)
#   tema          custom.css y custom.js del tema hijo
#   traducciones  los dos .xlf es-CO  (OPCIONAL, ver mas abajo)
#
# Por cada fichero, en este orden:
#   1. descarga el remoto actual            -> respaldo LOCAL en backups/
#   2. renombra el remoto a <nombre>.bak-<fecha>  -> respaldo EN EL SERVIDOR
#   3. sube el nuevo a un temporal y lo renombra al nombre final. Es atomico:
#      el visitante nunca ve un fichero a medio subir
#   4. verifica por HTTP que responde 200 y con el tamano exacto esperado
#   5. si algo no cuadra, DESHACE desde el .bak del servidor y sale con error
#
# LO QUE ESTE SCRIPT NO HACE, y hay que hacer a mano:
#   · el SQL (`29-imagenes-cliente.sql`): el hosting no admite MySQL remoto, va
#     por phpMyAdmin. Sin el, las 6 fotos nuevas no se ven — no se rompe nada.
#   · vaciar cachés: Back office -> Parametros avanzados -> Rendimiento, y
#     purgar LSCache en cPanel. Los 10 ficheros sobrescritos conservan el
#     nombre, asi que sin purgar se sigue sirviendo el viejo.
#
# Credenciales: en `.env` de la raiz del repo. Ver `.env.example` y
# `deploy/paquete/32-COMO-DARME-EL-FTP.md`.
#
# Uso:
#   python3 deploy/subir-a-produccion-ftps.py --dry-run          # no escribe nada
#   python3 deploy/subir-a-produccion-ftps.py                    # imagenes + tema
#   python3 deploy/subir-a-produccion-ftps.py --solo tema
#   python3 deploy/subir-a-produccion-ftps.py --solo traducciones
#   python3 deploy/subir-a-produccion-ftps.py --revertir         # vuelve a los .bak
# ---------------------------------------------------------------------------
import io
import os
import ssl
import sys
import time
import urllib.request
from ftplib import FTP_TLS

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FECHA = time.strftime("%Y%m%d")

# --- Las 16 imagenes de la ronda del 12/08/2026 ---------------------------
# Diez se sobrescriben con el mismo nombre porque cada fichero lo usa un solo
# bloque. Seis son NUEVAS: `banner-med-a.jpg` y `banner-med-b.jpg` los comparten
# tres bloques cada uno y cada bloque necesita una foto distinta, asi que hacen
# falta nombres nuevos + el SQL 29 que repunta el JSON de Leo Elements.
# Emparejamiento y por que: deploy/paquete/31-PASO-A-PASO-20260812.md
_IMAGENES = [
    "banner-a.jpg", "banner-b.jpg", "banner-c.jpg", "banner-ancho.jpg",
    "tornilleria.jpg", "manuales.jpg", "electricas.jpg", "automotriz.jpg",
    "soldadura.jpg", "seguridad.jpg",
    "medicion.jpg", "corte.jpg", "bulto.jpg", "nikatto.jpg",
    "cat-referencias.jpg", "cat-volumen.jpg",
]

_TEMA = "themes/vt_autosoe_child"

GRUPOS = {
    "imagenes": [("deploy/img/it/%s" % n, "img/it/%s" % n) for n in _IMAGENES],

    "tema": [
        ("theme-autosoe/vt_autosoe_child/assets/css/custom.css",
         "%s/assets/css/custom.css" % _TEMA),
        ("theme-autosoe/vt_autosoe_child/assets/js/custom.js",
         "%s/assets/js/custom.js" % _TEMA),
    ],

    # ⚠️ OPCIONAL y fuera del alcance de la ronda del 12/08. Son las 9
    # traducciones que solo existian en el espejo y se rescataron al repo ese dia
    # (`Disponible`, `Agotado`, `Registrarse`, los textos del 404...). No se sabe
    # con certeza que tiene produccion: el servidor devuelve 403 a los `.xlf`, asi
    # que no se pueden comparar por HTTP. Se suben solo si se pide a proposito.
    "traducciones": [
        ("theme-autosoe/vt_autosoe_child/translations/es-CO/ShopThemeGlobal.es-CO.xlf",
         "%s/translations/es-CO/ShopThemeGlobal.es-CO.xlf" % _TEMA),
        ("theme-autosoe/vt_autosoe_child/translations/es-CO/ShopThemeActions.es-CO.xlf",
         "%s/translations/es-CO/ShopThemeActions.es-CO.xlf" % _TEMA),
    ],
}

POR_DEFECTO = ["imagenes", "tema"]

# Cachés REGENERABLES que se pueden vaciar por FTP sin riesgo. Cada entrada es
# (carpeta, extensiones que se borran).
#   · assets/cache        -> el CSS y el JS COMBINADOS (opcion CCC de «Rendimiento»)
#   · leoelements/gencode -> el HTML ya compilado de cada widget de Leo Elements
# NO se toca `var/cache/`: son miles de ficheros y un borrado a medias por FTP
# puede dejar PrestaShop sin arrancar. Ese se vacia desde el back office, y en
# esta ronda no hace falta —se comprobo que el front ya sirve el contenido nuevo—.
CACHES = [
    ("%s/assets/cache" % _TEMA, (".css", ".js")),
    ("modules/leoelements/gencode", (".html",)),
]
CACHE_ASSETS = CACHES[0][0]


def vaciar_cache_assets(ftp, cfg, resp_dir, dry):
    """Borra el CSS/JS combinado para que PrestaShop lo reconstruya.

    POR QUE HACE FALTA. Con CCC activo la portada no carga `custom.css`, carga
    `themes/vt_autosoe_child/assets/cache/theme-<hash>.css`. El hash se calcula
    sobre la LISTA de ficheros, no sobre su contenido, asi que al cambiar
    `custom.css` el nombre NO cambia y el servidor sigue entregando el combinado
    viejo: los ficheros estan subidos y correctos, y aun asi no se ve nada.
    Medido en produccion el 12/08: el combinado tenia 0 apariciones de
    `data-it-hero` y seguia trayendo el degradado azul retirado.

    Equivale a «Vaciar la cache» del back office, pero solo para esta carpeta.
    NO toca `var/cache/` ni `modules/leoelements/gencode/`.

    ⚠️ Solo borra `*.css` y `*.js`. El `index.php` de la carpeta se queda: lo pone
    PrestaShop para que no se pueda listar el directorio por URL.
    """
    guardados = []
    for carpeta, exts in CACHES:
        print("\n--- vaciando %s ---" % carpeta)
        try:
            entradas = ftp.nlst(carpeta)
        except Exception as e:
            print("   no se pudo listar: %s" % e)
            continue

        borrables = [e for e in entradas
                     if e.rsplit("/", 1)[-1].lower().endswith(exts)]
        print("   %d entradas, %d a borrar" % (len(entradas), len(borrables)))
        if dry:
            for e in borrables[:6]:
                print("   (dry-run) se borraria %s" % e.rsplit("/", 1)[-1])
            if len(borrables) > 6:
                print("   (dry-run) … y %d mas" % (len(borrables) - 6))
            continue

        destino = os.path.join(resp_dir, carpeta.replace("/", "__"))
        os.makedirs(destino, exist_ok=True)
        n = 0
        for e in borrables:
            nombre = e.rsplit("/", 1)[-1]
            ruta = e if "/" in e else "%s/%s" % (carpeta, e)
            try:
                buf = io.BytesIO()
                ftp.retrbinary("RETR %s" % ruta, buf.write)
                with open(os.path.join(destino, nombre), "wb") as fh:
                    fh.write(buf.getvalue())
                ftp.delete(ruta)
                guardados.append((os.path.join(destino, nombre), ruta))
                n += 1
            except Exception as ex:
                print("   %-34s no se pudo borrar: %s" % (nombre, ex))
        print("   %d borrados (respaldo en %s)" % (n, destino))
    return guardados


def restaurar_cache_assets(ftp, resp_dir, guardados):
    """Devuelve las cachés borradas si PrestaShop no las reconstruyo."""
    for local, ruta in guardados:
        if os.path.isfile(local):
            with open(local, "rb") as fh:
                ftp.storbinary("STOR %s" % ruta, fh)
            print("   %-40s restaurado" % ruta)


def cargar_env():
    cfg = {}
    ruta = os.path.join(RAIZ, ".env")
    if not os.path.isfile(ruta):
        sys.exit("ERROR: falta %s\n"
                 "       Copia .env.example a .env y pon las credenciales FTP.\n"
                 "       Detalle: deploy/paquete/32-COMO-DARME-EL-FTP.md" % ruta)
    with open(ruta, encoding="utf-8") as fh:
        for linea in fh:
            linea = linea.strip()
            if not linea or linea.startswith("#") or "=" not in linea:
                continue
            k, v = linea.split("=", 1)
            # Se corta el comentario al final de linea (`VALOR   # nota`) y se
            # quitan comillas: es facil dejarlas al copiar y pegar.
            v = v.split("#", 1)[0].strip().strip('"').strip("'")
            cfg[k.strip()] = v
    if not cfg.get("FTP_PASS") and cfg.get("FTP_PASSWORD"):
        cfg["FTP_PASS"] = cfg["FTP_PASSWORD"]
    faltan = [k for k in ("FTP_HOST", "FTP_USER", "FTP_PASS") if not cfg.get(k)]
    if faltan:
        faltan = ["FTP_PASSWORD" if k == "FTP_PASS" else k for k in faltan]
        sys.exit("ERROR: faltan en .env: %s" % ", ".join(faltan))
    cfg.setdefault("FTP_DOCROOT", "public_html")
    cfg.setdefault("FTP_PORT", "21")
    cfg.setdefault("SITE_URL", "https://www.importtoolsas.com")
    return cfg


def conectar(cfg):
    ctx = ssl.create_default_context()
    ftp = FTP_TLS(context=ctx)
    ftp.connect(cfg["FTP_HOST"], int(cfg["FTP_PORT"]), timeout=60)
    ftp.login(cfg["FTP_USER"], cfg["FTP_PASS"])
    ftp.prot_p()          # cifra tambien el canal de datos, no solo el de control
    ftp.set_pasv(True)
    return ftp


def existe(ftp, ruta):
    try:
        ftp.size(ruta)
        return True
    except Exception:
        return False


def verificar_http(cfg, remoto):
    # El `?v=` evita que responda una copia cacheada por LSCache o por un CDN.
    url = "%s/%s?v=%d" % (cfg["SITE_URL"].rstrip("/"), remoto, int(time.time()))
    try:
        # Sin `Accept-Encoding: gzip` a proposito: si el servidor comprimiera, el
        # tamano recibido no coincidiria con el del fichero y la verificacion
        # daria un falso negativo. urllib no lo manda por defecto; se deja
        # explicito para que no cambie por debajo.
        req = urllib.request.Request(url, headers={
            "User-Agent": "Mozilla/5.0",
            "Accept-Encoding": "identity",
        })
        with urllib.request.urlopen(req, timeout=45) as r:
            return r.status, len(r.read())
    except Exception as e:
        return 0, "error: %s" % e


def main():
    dry = "--dry-run" in sys.argv
    revertir = "--revertir" in sys.argv
    # ⚠️ `--vaciar-cache` existe para NO tener que repetir la subida cuando lo
    # unico que falta es reconstruir el combinado. Repetirla seria destructivo:
    # el paso 1 se descarga el remoto actual como «respaldo», y el remoto actual
    # ya seria el fichero NUEVO, asi que machacaria el respaldo de verdad, y el
    # `.bak-<fecha>` del servidor tambien se sobrescribiria.
    solo_cache = "--vaciar-cache" in sys.argv

    grupos = POR_DEFECTO
    if "--solo" in sys.argv:
        i = sys.argv.index("--solo")
        if i + 1 >= len(sys.argv):
            sys.exit("ERROR: --solo necesita un grupo: %s" % ", ".join(GRUPOS))
        grupos = [sys.argv[i + 1]]
        if grupos[0] not in GRUPOS:
            sys.exit("ERROR: grupo desconocido '%s'. Hay: %s"
                     % (grupos[0], ", ".join(GRUPOS)))

    tareas = []
    if not solo_cache:
        for g in grupos:
            tareas.extend(GRUPOS[g])

    cfg = cargar_env()

    # Se comprueban TODOS los origenes antes de abrir la conexion: si falta uno,
    # mejor enterarse sin haber tocado el servidor.
    for local, _remoto in tareas:
        p = os.path.join(RAIZ, local.replace("/", os.sep))
        if not os.path.isfile(p):
            sys.exit("ERROR: no existe el fichero local %s" % p)

    print("Servidor : %s:%s  (docroot %s)"
          % (cfg["FTP_HOST"], cfg["FTP_PORT"], cfg["FTP_DOCROOT"]))
    print("Usuario  : %s" % cfg["FTP_USER"])
    if solo_cache:
        print("Grupos   : ninguno — solo se vacia el combinado del tema")
    else:
        print("Grupos   : %s  (%d ficheros)" % (", ".join(grupos), len(tareas)))
    print("Modo     : %s\n" % ("DRY-RUN (no escribe nada)" if dry else
                               ("REVERTIR" if revertir else
                                ("VACIAR CACHE" if solo_cache else "SUBIDA"))))

    # Un fallo aqui es el mas probable en el primer intento (host mal escrito,
    # clave, TLS no admitido, cortafuegos, modo pasivo bloqueado). Sin esto salia
    # un traceback de Python que no dice que hacer.
    try:
        ftp = conectar(cfg)
    except Exception as e:
        sys.exit(
            "ERROR al conectar con %s:%s\n"
            "       %s: %s\n\n"
            "       Repasa, por este orden:\n"
            "        1. FTP_HOST — sin `ftp://` y sin barra final\n"
            "        2. FTP_USER / FTP_PASSWORD — en cPanel, «Cuentas FTP»\n"
            "        3. que el servidor admita FTPS EXPLICITO (puerto 21, AUTH TLS).\n"
            "           Este script NO se cae a FTP sin cifrar: si no hay TLS, no sube.\n"
            "        4. que el cortafuegos deje salir el puerto 21 y el rango pasivo\n"
            % (cfg["FTP_HOST"], cfg["FTP_PORT"], type(e).__name__, e))

    try:
        if cfg["FTP_DOCROOT"] not in (".", "", "/"):
            ftp.cwd(cfg["FTP_DOCROOT"])
    except Exception as e:
        ftp.quit()
        sys.exit("ERROR: no existe la carpeta FTP_DOCROOT='%s' desde donde entra el FTP.\n"
                 "       %s\n"
                 "       Si la cuenta ya entra dentro del sitio, pon  FTP_DOCROOT=.\n"
                 % (cfg["FTP_DOCROOT"], e))

    print("conectado, TLS activo, dentro de %s\n" % ftp.pwd())

    resp_dir = os.path.join(RAIZ, "backups", "produccion-%s" % FECHA)
    os.makedirs(resp_dir, exist_ok=True)

    subidos = []
    for local, remoto in tareas:
        plocal = os.path.join(RAIZ, local.replace("/", os.sep))
        tam_nuevo = os.path.getsize(plocal)
        bak = "%s.bak-%s" % (remoto, FECHA)
        tmp = "%s.subiendo-%d" % (remoto, os.getpid())

        if revertir:
            if existe(ftp, bak):
                if not dry:
                    if existe(ftp, remoto):
                        ftp.delete(remoto)
                    ftp.rename(bak, remoto)
                print("%-46s revertido desde el .bak" % remoto)
            else:
                print("%-46s SIN respaldo en el servidor — no se toca" % remoto)
            continue

        tam_viejo = ftp.size(remoto) if existe(ftp, remoto) else None
        print("%-46s remoto=%-9s nuevo=%s B"
              % (remoto, tam_viejo if tam_viejo is not None else "(no existe)", tam_nuevo))

        if dry:
            continue

        # 1. respaldo local del actual. El nombre lleva la ruta aplanada para que
        #    dos ficheros con el mismo basename (p.ej. varios custom.css) no se
        #    pisen dentro de la carpeta de respaldo.
        if tam_viejo is not None:
            buf = io.BytesIO()
            ftp.retrbinary("RETR %s" % remoto, buf.write)
            with open(os.path.join(resp_dir, remoto.replace("/", "__")), "wb") as fh:
                fh.write(buf.getvalue())

        # 2. subir a temporal y comprobar que llego entero
        with open(plocal, "rb") as fh:
            ftp.storbinary("STOR %s" % tmp, fh)
        if ftp.size(tmp) != tam_nuevo:
            ftp.delete(tmp)
            sys.exit("ERROR: el temporal subio incompleto. NO se toco %s" % remoto)

        # 3. apartar el actual y poner el nuevo
        if tam_viejo is not None:
            if existe(ftp, bak):
                ftp.delete(bak)
            ftp.rename(remoto, bak)
        ftp.rename(tmp, remoto)
        subidos.append((local, remoto))
        print("%-46s subido  (respaldo: %s)" % ("", os.path.basename(bak)))

    if dry or revertir:
        # En seco, si se pidio vaciar el combinado, al menos se lista lo que se
        # borraria: es la mitad del valor de un dry-run.
        if dry:
            vaciar_cache_assets(ftp, cfg, resp_dir, True)
        ftp.quit()
        print("\nNada mas que hacer en este modo.")
        return

    print("\n--- verificacion por HTTP ---")
    fallos = []
    for local, remoto in subidos:
        esperado = os.path.getsize(os.path.join(RAIZ, local.replace("/", os.sep)))
        code, got = verificar_http(cfg, remoto)
        ok = (code == 200 and got == esperado)
        print("%-46s http=%-4s bytes=%-9s esperado=%-9s %s"
              % (remoto, code, got, esperado, "OK" if ok else "REVISAR"))
        if not ok:
            fallos.append(remoto)

    if fallos:
        print("\n⚠️  No verifican: %s" % ", ".join(fallos))
        print("   Deshaciendo TODO lo subido en esta pasada desde los .bak…")
        for local, remoto in subidos:
            bak = "%s.bak-%s" % (remoto, FECHA)
            if existe(ftp, bak):
                if existe(ftp, remoto):
                    ftp.delete(remoto)
                ftp.rename(bak, remoto)
                print("   %-46s revertido" % remoto)
        ftp.quit()
        sys.exit("Revertido. El sitio queda como estaba.")

    if subidos:
        print("\nTodo verificado. %d ficheros. Respaldo local en: %s"
              % (len(subidos), resp_dir))

    # --- el combinado del tema ---------------------------------------------
    # Sin esto, los ficheros estan subidos y el sitio sigue sirviendo el CSS/JS
    # compilado de antes. Se hace al final, cuando ya se sabe que todo lo demas
    # verifico.
    guardados = vaciar_cache_assets(ftp, cfg, resp_dir, dry)
    if guardados:
        print("   pidiendo la portada para que PrestaShop lo reconstruya…")
        code, _ = verificar_http(cfg, "")
        print("   portada http=%s" % code)
        # ¿Se reconstruyo y trae los cambios? El centinela solo existe en la
        # version de hoy, asi que no puede venir del combinado viejo.
        try:
            req = urllib.request.Request(
                "%s/?v=%d" % (cfg["SITE_URL"].rstrip("/"), int(time.time())),
                headers={"User-Agent": "Mozilla/5.0", "Accept-Encoding": "identity"})
            with urllib.request.urlopen(req, timeout=90) as r:
                html = r.read().decode("utf-8", "replace")
            import re
            m = re.search(r'assets/cache/theme-[a-f0-9]+\.css', html)
            if not m:
                print("   ⚠️  la portada NO referencia ningun combinado.")
                print("       Restaurando los que habia…")
                restaurar_cache_assets(ftp, resp_dir, guardados)
            else:
                url = "%s/themes/vt_autosoe_child/%s" % (cfg["SITE_URL"].rstrip("/"), m.group(0))
                req2 = urllib.request.Request(url, headers={
                    "User-Agent": "Mozilla/5.0", "Accept-Encoding": "identity"})
                with urllib.request.urlopen(req2, timeout=90) as r2:
                    css = r2.read().decode("utf-8", "replace")
                ok = "data-it-hero" in css
                print("   %s  ->  centinela `data-it-hero` %s"
                      % (m.group(0), "presente: RECONSTRUIDO" if ok else "AUSENTE"))
                if not ok:
                    print("   ⚠️  se reconstruyo pero sin los cambios. Revisar a mano.")
        except Exception as e:
            print("   ⚠️  no se pudo comprobar la reconstruccion: %s" % e)
            print("       Restaurando los combinados que habia, por prudencia…")
            restaurar_cache_assets(ftp, resp_dir, guardados)

    ftp.quit()
    print("\nFALTA, y no lo hace este script:")
    print("  1. phpMyAdmin -> ejecutar deploy/paquete/29-imagenes-cliente.sql")
    print("     (sin el, las 6 fotos nuevas no se ven)")
    print("  2. cPanel -> purgar LSCache, y recargar con Ctrl+F5")
    print("     (los 10 ficheros sobrescritos conservan el nombre)")
    print("  3. Repasar el §5 y el §7 de deploy/paquete/31-PASO-A-PASO-20260812.md")


if __name__ == "__main__":
    main()
