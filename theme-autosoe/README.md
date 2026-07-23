# theme-autosoe/ — Personalizaciones del tema AutoSoe

Personalizaciones de la plantilla **AutoSoe – Car & Auto Parts** para la tienda de
Importtools Latam S.A.S sobre PrestaShop 9.1.

## Regla de oro
> **Nunca editar los archivos del tema original.** Todo cambio va como **child theme**
> u **override**, para no perder la personalización al actualizar el tema.

## Qué versionamos aquí
- `brand/` — tokens de marca (colores, tipografías, logo) → `brand-tokens.css`.
- Overrides de plantillas (`.tpl`), CSS/JS propios y snippets de configuración del tema.

## Qué NO versionamos
- El paquete comprado del tema (`.zip`) ni su licencia → ignorados en `.gitignore`.
- `node_modules`, credenciales, ni archivos generados.

## Flujo de trabajo
1. Instalar AutoSoe en el hosting (Fase 2).
2. Crear child theme (o carpeta de override) en PrestaShop.
3. Copiar aquí los archivos personalizados y aplicar los `brand/brand-tokens.css`.
4. Documentar cada override no trivial (qué archivo, por qué).

Detalle de la personalización en [`../docs/fase3-personalizacion.md`](../docs/fase3-personalizacion.md).
