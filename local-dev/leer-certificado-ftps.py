#!/usr/bin/env python3
"""Lee el certificado que presenta el FTPS para saber a que nombre esta emitido.

Solo hace el saludo TLS (`AUTH TLS`): NO envia usuario ni contraseña. Sirve para
decidir si se puede seguir verificando el certificado —apuntando FTP_HOST al
nombre correcto— en vez de desactivar la verificacion.
"""
import socket
import ssl
import sys
from ftplib import FTP_TLS

host = sys.argv[1] if len(sys.argv) > 1 else "ftp.importtoolsas.com"
port = int(sys.argv[2]) if len(sys.argv) > 2 else 21

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

ftp = FTP_TLS(context=ctx)
print("conectando a %s:%d (sin verificar, solo para leer el certificado)" % (host, port))
ftp.connect(host, port, timeout=45)
print("  banner: %s" % ftp.getwelcome())
ftp.auth()

cert = ftp.sock.getpeercert()
if not cert:
    # Con CERT_NONE OpenSSL no rellena el dict; se pide en binario y se parsea.
    der = ftp.sock.getpeercert(binary_form=True)
    print("  el servidor no expone el certificado parseado; %d bytes en DER" % len(der))
    try:
        pem = ssl.DER_cert_to_PEM_cert(der)
        # Sin dependencias externas no se puede parsear el DER; se muestra el PEM
        # para inspeccionarlo con openssl si hiciera falta.
        print("  --- PEM (para: openssl x509 -noout -text) ---")
        print(pem)
    except Exception as e:
        print("  no se pudo convertir a PEM: %s" % e)
else:
    print("  subject: %s" % (cert.get("subject"),))
    print("  issuer : %s" % (cert.get("issuer"),))
    print("  SAN    : %s" % (cert.get("subjectAltName"),))

print("  IP     : %s" % (ftp.sock.getpeername(),))
try:
    print("  PTR    : %s" % socket.gethostbyaddr(ftp.sock.getpeername()[0])[0])
except Exception as e:
    print("  PTR    : no resoluble (%s)" % e)

ftp.close()
