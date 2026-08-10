# Plan de Fase II — catálogo sin precios, cotización por WhatsApp y rediseño

Importtools S.A.S · `www.importtoolsas.com` · actualizado el 01/08/2026

---

## 1. La decisión que ordena todo lo demás

**El catálogo no lleva precios. No es provisional.** La tienda es un catálogo
consultable: el visitante arma una lista, deja sus datos y un asesor le responde por
WhatsApp con precio, disponibilidad y tiempo de entrega.

Consecuencias, todas ya aplicadas en el espejo:

| | |
|---|---|
| `PS_CATALOG_MODE = 1`, `PS_CATALOG_MODE_WITH_PRICES = 0` | 0 precios, 0 filtro de precio, 0 «ordenar por precio» |
| No hay carrito ni pasarela | El botón de comprar se sustituye por «Agregar a mi cotización» |
| Los transportistas dejan de ser urgentes | Solo harían falta si algún día se abre el carrito |
| Los precios reales dejan de bloquear la salida a producción | El mecanismo de carga sigue listo en `06-cargar-precios-reales.sql` por si se necesitan |

⚠️ Los 3.036 productos conservan en base de datos el precio generado, marcado con
`supplier_reference = 'PRECIO-PRUEBA'`. **No se ve en ningún sitio**, pero aparecería
entero si alguien desactivara el modo catálogo. Mientras la decisión siga en pie, no
molesta; si algún día se abre la tienda, hay que cargar los reales antes.

---

## 2. Lo terminado y verificado en el espejo

Todo comprobado ejecutándolo, no deducido del código.

### Flujo de cotización — cerrado

| Prueba | Resultado |
|---|---|
| Recorrido completo en navegador real sobre la página real | ✅ |
| Enviar con la lista vacía | Se queda en la página: *«Aún no has agregado productos.»* |
| Documento inválido (`AB`) | El servidor responde `ok=false`, error señalado en el campo `documento` |
| Datos válidos, 2 productos | `ok=true`, referencia `COT-260801-QYIV`, fila completa en base con los acentos intactos |
| Enlace de WhatsApp | Apunta a `https://wa.me/573145934962`, 638 caracteres, lleva las dos referencias |
| Tras enviar | Lista vaciada, contador de la cabecera a 0, confirmación pintada con la referencia |
| Nombres de producto | El servidor los relee de la base; no se fía de lo que manda el navegador |

**Fallo encontrado y corregido durante la prueba:** el botón estaba en las 38 plantillas
de listado pero **no en la ficha de producto**, donde el tema mete todo el bloque de
compra dentro de `{if !$configuration.is_catalog}` y en modo catálogo dejaba un hueco
vacío. Quien abría un producto no tenía cómo pedirlo. Ahora la ficha lleva selector de
cantidad y botón, en `themes/vt_autosoe_child/templates/catalog/_partials/product-add-to-cart.tpl`,
con `{include file='parent:…'}` de respaldo — probado apagando y encendiendo el modo catálogo.

### Diseño — las dos páginas de la maqueta

**Quiénes somos** y **Quiero ser cliente**, construidas en HTML y CSS, no como imagen:
el texto queda nítido a cualquier zoom (el cliente pidió «puro vector»), es traducible
y lo indexa Google.

- Las **seis fotos salen de la propia maqueta del cliente** (4500 × 6211), recortadas y
  reescaladas: el bodegón del hero, un segundo encuadre para la otra página y las cinco
  de categoría. Están en `deploy/img/it/`.
- Los **iconos son los del propio tema**. AutoSoe empaqueta **Font Awesome 5 Pro Light**
  completo (427 KB) pero **no declara la clase `.fal`** que la usa, así que estaba ahí sin
  poder aprovecharse. Se declaró `.it-ico` en `custom.css` y quedan disponibles los 1.649
  glifos con el trazo fino que pedía la maqueta. Comprobado glifo a glifo.
  Los de marca (WhatsApp, Facebook, Instagram) solo existen en la fuente Brands: llevan
  `.it-ico--marca`.
- Verificado a **1440 px y a 390 px reales**, sin desplazamiento horizontal
  (`scrollWidth == innerWidth`).

### Otros arreglos de esta ronda

- Las dos tarjetas de degradado que se colaban al final de *Quiénes somos* (contenido 17
  de Leo, por `displayWrapperBottom`) quedan ocultas solo en esa página. Siguen donde les
  toca, en la cabecera de las categorías.
- Las **fichas sin foto** ya no ocupan media pantalla: el marcador del núcleo se limita a
  300 px y desaparece la miniatura cuando está sola. La ficha es 450 px más corta. En
  cuanto lleguen las fotos reales, la regla deja de aplicar sola.

---

## 3. Lo que falta

### Antes de desplegar *(no depende de nadie)*

1. **Regenerar el volcado** de base de datos y el **zip del tema hijo**.
2. **Subir** `deploy/img/it/` (ahora 142 ficheros, 6 nuevos) a `<docroot>/img/it/`.
3. **Subir el módulo** `itcotizacion` actualizado (JS y CSS cambiados esta ronda).
4. **Borrar el zip del tema** que quedó en `public_html/themes/` del despliegue anterior:
   hoy cualquiera puede descargarlo.

### En el despliegue

5. Mismo orden que funcionó el 31/07: apagar cachés de Smarty → subir ficheros →
   importar → ajustes de dominio → vaciar `var/cache/prod` → comprobar → restaurar cachés.
6. **Subir los dos `es.php` de módulo** y comprobar que `translations/es-CO/` tenga los
   **169** ficheros. Es lo único que quedó pendiente del despliegue anterior.
7. Confirmar el modo catálogo en producción y **quitar el mantenimiento**.

---

## 4. Lo que depende del cliente

| | Por qué importa | Estado |
|---|---|---|
| **Fotos de producto** | `psjy_image` sigue a 0: los 3.036 salen sin foto | ⏳ sin fecha |
| **Requisitos y condiciones comerciales** | Documentos para facturar, cupo, crédito, cobertura. **No los invento**: son compromisos legales. La página *Quiero ser cliente* está publicada y funciona sin ellos; se añaden como sección cuando lleguen | ⏳ pedido |
| Revisar la frase *«Clientes de todo el país confían en Importtools»* | Es copia de su propia maqueta, pero conviene que la confirme | ⏳ |
| ¿El correo pasa a `@importtoolsas.com`? | Hoy es `@importtoolslatam.com` | ⏳ sin decidir |
| Transportistas y tarifas | Solo si algún día se abre el carrito | ⏸ en pausa |

---

## 5. Riesgos, y qué los contiene

**El espejo acumula tres rondas sin desplegar.** Es lo que más pesa. Ya no hay nada
bloqueado: se puede desplegar entero.

**El cliente edita las páginas con TinyMCE.** *Quiénes somos* y *Quiero ser cliente* son
HTML estructurado dentro del editor del back office. Si las abre y guarda, el editor
puede reordenar o limpiar marcado. Los dos ficheros originales quedan en
`deploy/paquete/contenido/`, así que siempre se pueden reinstalar tal cual.

**Editar el JSON de Elementor.** Sigue la misma disciplina que no lo ha roto en seis
ediciones: `str_replace` sobre texto plano, sin recodificar, validando `JSON_VALID` antes
de escribir. Esta ronda no hizo falta tocarlo.

**Lo que no puedo verificar yo.** Safari en iPhone. Las medidas dicen que a 390 px no hay
desplazamiento horizontal, pero el veredicto es del dispositivo.

---

## 6. Nota de herramienta

Chromium headless **no baja de ~500 px de ventana**: con `--window-size=390` maqueta a 500
y recorta el PNG, lo que simula un desbordamiento que no existe. Costó un rato descubrirlo.
`local-dev/captura.sh` ya lo resuelve solo — por debajo de 520 px carga la página dentro de
`local-dev/_movil.html`, que sí acepta el ancho real. Y `local-dev/_medir-desbordamiento.html`
mide `scrollWidth` y lista los elementos que se salen, en vez de deducirlo de una captura.
