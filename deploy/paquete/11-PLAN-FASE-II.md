# Plan de Fase II — cotización por WhatsApp y rediseño

Importtools S.A.S · `www.importtoolsas.com` · 01/08/2026

---

## 1. Dónde estamos, de verdad

**Producción** tiene la migración del 31/07: catálogo de 3.036 productos, español,
datos reales, filtros y marcas. Y le faltan tres cosas de aquel despliegue:

| Pendiente en producción | Qué pasa si no se hace |
|---|---|
| Subir los dos `es.php` de módulo | Sigue «Search here…» en el buscador |
| Comprobar que `translations/es-CO/` tenga los **169** ficheros | Textos sueltos del núcleo en inglés |
| Decidir el modo catálogo | La tienda aparenta vender y el checkout no cierra |

**El espejo** va dos rondas por delante. Nada de lo de abajo está en producción.

---

## 2. Lo que ya está hecho y verificado en el espejo

Todo comprobado con capturas reales, no deducido del HTML.

| | Evidencia |
|---|---|
| Módulo de cotización `itcotizacion` | Tabla, validación por campo, guardado, enlace de WhatsApp y exportación CSV. Probado con datos válidos e inválidos |
| Modo catálogo sin precios | 0 precios, 0 filtro de precio, 0 «ordenar por precio»; filtros de categoría, marca, línea y disponibilidad intactos |
| Botón «Agregar a mi cotización» | En las 38 plantillas de listado, con referencia de producto |
| Acceso en la cabecera | Junto a la lista de deseos, con contador |
| Nombre «Importtools S.A.S» | 37 filas; quedan solo el correo y el Instagram, que son direcciones reales |
| Marca corregida a **Nikato** | 0 apariciones de «nikatto» en toda la base |
| Menú: iconos + hamburguesa en la esquina | Verificado en captura a 900 px |
| Home: alturas iguales, sin rayas | Verificado en captura |
| Logo 25 % mayor · buscador animado · blog fuera | Verificado en captura |
| Enlace roto `2-home` de la barra móvil | Corregido, 8 filas |

---

## 3. Lo que falta, en orden

### Bloque A — cerrar el flujo de cotización  *(no depende de nadie)*

1. **Probar de punta a punta en el navegador**: agregar producto → lista → formulario →
   enlace de WhatsApp. El endpoint ya está probado por separado; falta el recorrido con
   JavaScript real.
2. **Revisar la página de cotización en pantalla** y ajustar lo que se vea mal.
3. **Traducciones del módulo**: sus cadenas van con dominio `Modules.Itcotizacion.Shop` y
   todavía no hay catálogo, así que salen en el idioma en que están escritas.

### Bloque B — rediseño  *(bloqueado: faltan materiales)*

4. **Quiénes somos.** El cliente entregó una **maqueta completa** de 4500 × 6208 px, no un
   póster. Lo correcto es construirla en HTML/CSS: el texto queda nítido, traducible e
   indexable, y solo las fotos van como imagen.
   **Necesito del diseñador:** el bodegón de herramientas y las cinco fotos de categoría
   por separado, y los iconos en SVG.
5. **Quiero ser cliente.** Hoy es texto plano sobre blanco. Pasa a ser la puerta de
   entrada del flujo de cotización, con el lenguaje visual de AutoSoe.

### Bloque C — desplegar  *(depende de A; B puede ir después)*

6. **Regenerar el paquete**: volcado nuevo, zip del tema, el módulo y las imágenes.
7. **Desplegar en una sola ventana**, con el mismo orden que funcionó el 31/07:
   apagar cachés de Smarty → subir ficheros → importar → ajustes de dominio → vaciar
   `var/cache/prod` → comprobar → restaurar cachés.
8. **Decidir el modo catálogo** antes de quitar el mantenimiento.

---

## 4. Decisiones que dependen del cliente

| Decisión | Por qué importa | Estado |
|---|---|---|
| **Materiales de diseño** (fotos sueltas + iconos SVG) | Bloquea el bloque B entero | ⏳ pedido |
| **Precios reales** | Sin ellos, el modo catálogo se queda | ⏳ los enviará |
| **Transportistas** | Si se abre el carrito, hay que tenerlos | ⏳ sin definir |
| **Fotos de producto** | Los 3.036 salen sin imagen | ⏳ sin fecha |
| ¿El correo pasa a `@importtoolsas.com`? | Hoy es `@importtoolslatam.com` | ⏳ sin decidir |

---

## 5. Riesgos, y qué los contiene

**El espejo acumula dos rondas sin desplegar.** Cuanto más se alargue, mayor la ventana
de un solo despliegue. Contención: el bloque A es corto; desplegar A sin esperar a B es
perfectamente posible y deja producción coherente.

**Editar el JSON de Elementor.** Ya van cinco ediciones y ninguna lo rompió, porque
siempre se hace igual: `str_replace` sobre texto plano, sin recodificar, y validando
`JSON_VALID` antes de escribir. Mantener esa disciplina.

**Lo que no puedo verificar yo.** Safari en iPhone, que es donde el cliente vio el menú
roto. El arreglo ataca las tres causas conocidas, pero el veredicto es del dispositivo.

---

## 6. Qué propongo hacer ahora

Terminar el **bloque A** —es corto y no depende de nadie— y con eso **desplegar**, para
que producción deje de estar dos rondas por detrás y el cliente vea funcionando la
cotización por WhatsApp.

El **bloque B** entra en cuanto lleguen las fotos y los SVG, en un segundo despliegue que
ya será solo de tema y contenido, sin tocar la base de datos.
