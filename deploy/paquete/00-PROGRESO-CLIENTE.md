# Import Tools Latam S.A.S — estado de la tienda y cómo personalizarla

Documento para el cliente · 28 de julio de 2026

---

## 1. Qué está listo

### Catálogo
- **3.036 productos** cargados y clasificados en las **15 categorías** que nos indicaron.
- **7 marcas** creadas: Nikatto (1.381 productos), Dragon Tools (27), Ventum (19),
  Proweld (6), Proto (11), Irwin (4) y Grainger (1). Las cuatro propias con su logotipo.
- **Filtros del catálogo adaptados a su estructura**: se puede filtrar por
  **Marca** (la columna «grupo» de su archivo), **Línea**, **Sublínea**, **Precio** y
  **Disponibilidad**. Son 88 líneas y 128 sublíneas distintas.

### Contenido
- Toda la tienda en **español**, con moneda **peso colombiano** e **IVA colombiano**
  (19 %, 5 % y 0 %).
- **Datos reales de la empresa** en cabecera, pie, contacto y páginas legales: razón social,
  NIT, dirección de Galapa, teléfono/WhatsApp, correo, horarios, Facebook e Instagram.
- **Mapa de la ubicación** en *Quiénes somos* y en *Envíos*, y el icono de ubicación de la
  cabecera y del pie lleva a la ficha de Google Maps.
- **7 páginas** redactadas: Quiénes somos, Envíos y entregas, Aviso legal, Términos y
  condiciones, Pago seguro, Preguntas frecuentes y Quiero ser cliente.
- **Menú** con las secciones pedidas:
  `INICIO · CATEGORIAS · MARCAS · CATALOGO · QUIERO SER CLIENTE · QUIENES SOMOS · CONTACTO`.
  Categorías y Marcas se despliegan al pasar el ratón.

### Limpieza de la plantilla
Se retiró todo el contenido de ejemplo de la plantilla, incluidas afirmaciones que no
corresponden a la empresa y que venían en la demo: *«30 años de servicio»*,
*«100 % de satisfacción»*, *«4.9 en Google Reviews»*, descuentos inventados
(*«20 % off»*, *«ahorra $20»*, *«envío gratis desde $99»*) y una cuenta atrás de una oferta
caducada en 2025. También se quitó el filtro de repuestos de automóvil, que no aplica.

Las imágenes que la plantilla cargaba **desde un servidor ajeno** (el del autor del tema) se
descargaron y ahora se sirven desde su propio hosting: si ese servidor se cayera, la tienda
no se vería afectada.

---

## 2. Cómo personalizar todo

Se conservan **íntegras** las herramientas de LeoTheme. No se modificó ningún archivo de la
plantilla original: los ajustes propios viven en un **tema hijo**, de modo que la plantilla
se puede actualizar sin perder el trabajo.

Todo se administra desde el **panel de administración**, con usuario y contraseña. Cada cosa
se edita en un sitio distinto y no se pisan entre sí:

| Qué quieren cambiar | Dónde |
|---|---|
| Productos, precios, stock, categorías, marcas, línea y sublínea | **Catálogo** |
| Textos de Quiénes somos, legales, preguntas frecuentes | **Diseño → Páginas** |
| Portada, cabecera y pie: mover y editar bloques | **Diseño → Leo Elements** |
| **Colores y tipografías** | **Diseño → Leo Elements → Profiles** (151 opciones) |
| Menú y sus secciones | **Módulos → Leo Megamenu** |
| Carrusel principal | **Módulos → LeoSlideShow** |
| Fotos de producto y miniaturas | **Catálogo → Productos** e **Imágenes** |

### 2.1 Sobre el engranaje que salía en la tienda

Antes aparecía un engranaje en el lateral derecho **de la tienda pública** que abría un
personalizador de colores. Lo hemos retirado por dos razones:

1. **Lo veía cualquier visitante**, no solo ustedes. Comprobamos que no podía modificar la
   tienda —solo guardaba preferencias en el navegador de quien lo abría— pero no es algo que
   deba estar a la vista del público.
2. Desde ahí se podían **cargar las portadas de muestra** que trae la plantilla, que son de
   una tienda de repuestos de automóvil y están en inglés. Al hacerlo se perdía el menú y el
   diseño quedaba descolocado.

**No se pierde ninguna capacidad de personalizar.** Los mismos colores y tipografías están en
el panel de administración, en *Diseño → Leo Elements → Profiles*, con 151 opciones: colores
de fondo, botones, titulares, precios, etiquetas de producto y tipografías. La diferencia es
que ahora hace falta iniciar sesión, como debe ser.

Además dejamos **un solo diseño**: el que ustedes eligieron. Ya no hay portadas de muestra que
se puedan cargar por error.

### 2.2 Editor visual — Diseño → Leo Elements
Es donde se edita el contenido arrastrando y soltando. Hay **17 bloques** disponibles;
los que están en uso ahora mismo:

| Bloque | Qué controla |
|---|---|
| `displayTop of header 03` | Cabecera: logotipo, buscador, carrito, barra de contacto |
| `displayHome of content 03` | **Toda la portada** |
| `displayFooter of footer 03` | Pie: boletín, enlaces, redes, medios de pago |
| `displayHeaderCategory of Home 1` | Banda superior de las páginas de categoría |

### 2.3 Menú — Módulos → Leo Bootstrap Menu
Se añaden, quitan y reordenan secciones. «CATEGORIAS» y «MARCAS» tienen sus subelementos
dentro; al crear una categoría nueva basta con añadirla ahí.

### 2.4 Carrusel principal — Módulos → Leo Slideshow
Diapositivas, textos y botones.

### 2.5 Productos, categorías y precios — Catálogo
Lo habitual de PrestaShop. Las **características** (Línea y Sublínea) y la **marca** de cada
producto se editan en la ficha del producto, y los filtros se actualizan solos.

---

## 3. Qué falta para abrir al público

1. **Fotografías.** Es lo más importante que falta:
   - **Los 3.036 productos no tienen foto**: salen con el marcador de «sin imagen».
   - Los fondos de la portada son **degradados con los colores de la marca**, provisionales.
     Quitan el aspecto de tienda de repuestos de coche del demo, pero no son fotos.

   Necesitamos los archivos de imagen. Las fotos de Instagram no sirven: sus direcciones
   caducan a los pocos días y la tienda quedaría con imágenes rotas.

2. **Precios.** Los productos tienen **precios generados** para poder ver la tienda
   funcionando. Hay que cargar los reales, o dejar el catálogo en modo «consultar precio»,
   antes de abrir.

3. **Envíos.** Falta definir cobertura y tarifas con las transportadoras.

4. **Medios de pago.** Por decidir si se habilita pasarela en línea.

5. Detalles menores: confirmar cómo se escribe la dirección
   (*«Carrera Cordialidad Km 2.5 #66»*) y borrar 2 clientes y 5 pedidos de ejemplo.

---

## 4. Su usuario y qué alcance tiene

Se creó una cuenta para ustedes con permisos ajustados: pueden editar todo el contenido y el
catálogo, pero no cambiar el tema, desinstalar módulos ni tocar la configuración técnica del
servidor. Así se evita que un clic accidental deje la tienda inservible.

Los datos de acceso van aparte, en el documento de credenciales. **Cambien la contraseña en su
primer ingreso.**

Si en algún momento necesitan hacer algo que el sistema no les permite, escríbannos: está
dentro de las 4 horas mensuales de soporte incluidas los primeros 6 meses.

## 5. Un par de cosas que conviene saber

**La ficha de Google Maps** está a nombre de «HERRAMIENTAS Y SEGURIDAD S.A.». Nos confirmaron
que la empresa también se conoce así, y se dejó tal cual.

**Dos dominios.** La tienda es `importtoolsas.com` y el correo `@importtoolslatam.com`. Se
mantiene así por indicación suya.

**Si se equivocan editando un bloque**, Leo Elements guarda un historial de revisiones para
deshacer, y nosotros conservamos respaldos con fecha y hora.
