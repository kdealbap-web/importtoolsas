# 20 — Correo de la tienda: qué crear en cPanel y por qué

Importtools S.A.S · `www.importtoolsas.com` · 08/08/2026

---

## 1. El problema, antes de crear nada

Hoy la tienda está así:

| Ajuste | Valor actual |
|---|---|
| `PS_SHOP_EMAIL` (remitente de todo) | `ventas@importtoolslatam.com` |
| Buzón «Soporte del sitio web» | `ventas@importtoolslatam.com` |
| Buzón «Atención al cliente» | `ventas@importtoolslatam.com` |
| `PS_MAIL_METHOD` | `1` = función `mail()` de PHP |
| `PS_MAIL_DKIM_ENABLE` | `0` |

**La tienda vive en `importtoolsas.com` y manda los correos como si fuera
`importtoolslatam.com`.** Son dos dominios distintos, y el segundo ni siquiera está
en este cPanel.

Por qué importa: cuando el servidor de `importtoolsas.com` entrega un mensaje cuyo
remitente es `@importtoolslatam.com`, el servidor que lo recibe comprueba tres cosas
—SPF, DKIM y DMARC— y las tres miran si **quien envía tiene permiso para usar ese
remitente**. Aquí no lo tiene. El resultado, según lo estricto que sea el destinatario:

- Gmail y Outlook lo mandan a **spam**, o
- lo **rechazan** directamente.

Esto explica el pendiente que quedó abierto: si «Olvidé mi contraseña» no llega,
no es que PrestaShop no lo envíe — es que el correo sale mal firmado y el
destinatario no lo acepta. Y lo mismo le pasa a **todo**: confirmación de registro,
aviso de pedido, respuesta del formulario de contacto.

> **Sí: hay que usar cuentas del propio dominio.** Es justo lo que hay que corregir.

---

## 2. Qué cuentas crear en cPanel

Quedan 19 huecos libres. Con **dos** basta, y una tercera es cómoda:

| Cuenta | Para qué sirve | ¿Alguien la lee? |
|---|---|---|
| `no-reply@importtoolsas.com` | **Remitente** de todo lo automático: registro, recuperación de contraseña, avisos de pedido | No |
| `ventas@importtoolsas.com` | **Buzón real**: formulario de contacto y cotizaciones. Es el que abre el asesor | Sí, a diario |
| `info@importtoolsas.com` | Dirección general, la que la gente escribe de memoria. Se redirige a `ventas@` | Por redirección |

Contraseñas largas y distintas, guardadas donde se guarden las del proyecto.

**Sobre `info@`:** como buzón de cara al público está muy bien y da imagen seria —es lo
que preguntabas—, pero **no debe ser el remitente del sistema**. Si los correos
automáticos salen desde `info@`, las respuestas automáticas, las vacaciones y los
rebotes acaban mezclados con los mensajes de clientes reales. Por eso el remitente va
en `no-reply@` y `info@` se queda para que la gente escriba.

**Sobre `admin_dev@importtoolsas.com`:** déjala como está. Es la cuenta técnica del
proveedor y no debe usarse para nada de cara al cliente.

---

## 3. Qué hacer en el DNS (esto es lo que decide si llega o no)

En cPanel → **Zone Editor** del dominio `importtoolsas.com`:

1. **SPF** — normalmente cPanel lo crea solo. Comprobar que existe un registro TXT así:
   ```
   v=spf1 +mx +a +ip4:<IP del servidor> ~all
   ```
2. **DKIM** — cPanel → *Email Deliverability* → **Repair**. Deja el registro puesto y
   firmando. Es lo que más peso tiene hoy.
3. **DMARC** — añadir un TXT en `_dmarc.importtoolsas.com`. Empezar suave y endurecer
   cuando se vea que todo llega:
   ```
   v=DMARC1; p=none; rua=mailto:admin_dev@importtoolsas.com; pct=100
   ```
   Cuando lleve unas semanas sin incidencias, subir a `p=quarantine`.

> cPanel tiene una pantalla que lo resume: **Email Deliverability**. Si los tres
> aparecen en verde para `importtoolsas.com`, esta parte está lista.

---

## 4. Qué cambiar en PrestaShop

### 4.1 Método de envío: SMTP, no `mail()`

Back office → **Parámetros avanzados → Correo electrónico**:

| Campo | Valor |
|---|---|
| Método | **Configurar mi propio servidor SMTP** |
| Servidor SMTP | `mail.importtoolsas.com` |
| Usuario | `no-reply@importtoolsas.com` |
| Contraseña | la de esa cuenta |
| Cifrado | **TLS** |
| Puerto | **587** |

Por qué SMTP y no `mail()`: la función `mail()` entrega el mensaje y se desentiende
—si algo falla, PrestaShop solo sabe decir «Se ha producido un error al enviar el
mensaje», que es exactamente el aviso que salió en las pruebas—. Con SMTP autenticado
el correo sale con las credenciales de una cuenta real del dominio, queda alineado con
SPF y DKIM, y los fallos vienen con motivo.

> ⚠️ Si `mail.importtoolsas.com` diera problemas de certificado, usar el nombre del
> servidor que aparece en cPanel → *Cuentas de correo → Conectar dispositivos*.

### 4.2 Direcciones

- `PS_SHOP_EMAIL` → `no-reply@importtoolsas.com`
- Los dos buzones de contacto → `ventas@importtoolsas.com`

Lo deja hecho **`21-correo-del-dominio.sql`**, que imprime el antes y el después.

### 4.3 Prueba

En la misma pantalla, «Enviar un correo de prueba» a una dirección **de Gmail**
(no a una del propio dominio: entre cuentas del mismo servidor llega aunque el DNS
esté mal, y no prueba nada).

Comprobar en Gmail → abrir el mensaje → *Mostrar original*:

```
SPF:   PASS
DKIM:  PASS
DMARC: PASS
```

Las tres en PASS es la señal de que está bien. Con eso, probar «Olvidé mi
contraseña» de punta a punta.

---

## 5. Y el correo del cliente, `@importtoolslatam.com`

Se decidió mantenerlo, y **puede mantenerse**: es la dirección que el cliente publica
y por la que le escriben. Pero conviene separar dos cosas que no son lo mismo:

- **Lo que la web ENVÍA** → tiene que salir de `@importtoolsas.com`. No es negociable
  si queremos que llegue.
- **Lo que el cliente PUBLICA y donde RECIBE** → puede seguir siendo
  `ventas@importtoolslatam.com`.

La forma limpia de tener las dos: crear `ventas@importtoolsas.com` y **redirigirla**
a `ventas@importtoolslatam.com` (cPanel → *Reenviadores*). Así la web envía y recibe
por su propio dominio, y el asesor sigue leyendo en el buzón de siempre.

> Merece la pena preguntarle al cliente si prefiere unificar todo en
> `@importtoolsas.com`. Tener la tienda en un dominio y el correo en otro obliga a
> explicarlo cada vez, y a un comprador nuevo le resulta raro.

---

## 6. Resumen de lo que hay que hacer

- [ ] Crear `no-reply@`, `ventas@` e `info@` en `importtoolsas.com`
- [ ] `info@` → reenvía a `ventas@`
- [ ] `ventas@importtoolsas.com` → reenvía a `ventas@importtoolslatam.com` (si se mantiene)
- [ ] cPanel → *Email Deliverability* → SPF y DKIM en verde
- [ ] Añadir el TXT de DMARC
- [ ] PrestaShop → SMTP con `no-reply@`
- [ ] Ejecutar `21-correo-del-dominio.sql`
- [ ] Correo de prueba **a Gmail** y comprobar SPF/DKIM/DMARC en *Mostrar original*
- [ ] Probar «Olvidé mi contraseña» de punta a punta
