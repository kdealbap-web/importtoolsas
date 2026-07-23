# Fase 3 — Personalización (contra 30% de avance)

> Alineada con el `CLAUDE.md` (sección 5, Fase 3). Esta fase se **ejecuta sobre la
> instalación viva de PrestaShop** (hosting H2 / cPanel). Aquí dejamos preparado todo lo
> que se puede adelantar desde el repo y marcamos lo que depende del servidor o de
> contenidos del cliente.

## Leyenda
- 🟢 **Preparable en el repo** (hecho o listo para llenar aquí)
- 🟡 **Requiere servidor** (PrestaShop instalado en el hosting — Fase 2)
- 🔴 **Bloqueado por el cliente** (falta logo / paleta / catálogo / imágenes)

---

## 3.1 Identidad de marca — logo, colores y tipografías
- 🔴 Recibir del cliente: **logo** (SVG/PNG fondo transparente), **paleta** y **tipografías**.
- 🟢 Tokens de marca centralizados en [`theme-autosoe/brand/brand-tokens.css`](../theme-autosoe/brand/brand-tokens.css) — llenar cuando llegue la paleta.
- 🟡 Aplicar logo y favicon en el back-office (Diseño → Tema y logo).
- 🟡 Cargar los tokens como CSS personalizado del tema (child theme / override, ver [`theme-autosoe/README.md`](../theme-autosoe/README.md)).

## 3.2 Cabecera, menú, banners y home
- 🟡 Configurar cabecera y **mega menú** (módulo del tema AutoSoe).
- 🔴 Banners de portada (imágenes del cliente) → home slider.
- 🟡 Home con Elementor: secciones destacadas, categorías, productos nuevos.

## 3.3 Localización — idioma, moneda, impuestos, envíos
- 🟠 **Decisión abierta:** idiomas del sitio (¿solo ES o ES/EN?). Ver `CLAUDE.md` §10.
- 🟡 Moneda **COP** como predeterminada (Internacional → Localización → Monedas).
- 🟡 **Impuestos:** crear regla **IVA 19%** y asignarla por defecto a productos gravados.
- 🟡 **Zonas y gastos de envío** (transportistas, tarifas, cobertura nacional).

## 3.4 Carga del catálogo inicial
- 🔴 Recibir catálogo del cliente (Excel/CSV) + imágenes de producto.
- 🟢 Plantilla de importación lista: [`db/import/plantilla_catalogo.csv`](../db/import/plantilla_catalogo.csv) (ver su `README.md`).
- 🟡 Importar en Back-office → Catálogo → Importar (separador `;`, mapear columnas).
- 🟠 **Decisión abierta:** cantidad de productos del catálogo inicial (vigilar inodos ~200.000 del plan H2).

## 3.5 Formularios de contacto / captación de leads
- 🟡 Configurar formulario de contacto nativo + página "Contacto".
- 🟡 (Opcional) Módulo de suscripción / captación de leads.

---

## Bloqueos actuales (para desbloquear Fase 3)
1. **Fase 2 pendiente**: PrestaShop 9.1 + AutoSoe instalados en el hosting.
2. **Contenidos del cliente**: logo, paleta, tipografías, banners, catálogo e imágenes.
3. **Licencia AutoSoe** (~USD 56) aún por adquirir.
4. **Decisiones**: idiomas (ES / ES-EN) y tamaño del catálogo inicial.
