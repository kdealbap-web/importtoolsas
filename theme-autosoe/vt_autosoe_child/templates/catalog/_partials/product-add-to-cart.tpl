{**
 * Importtools S.A.S — ficha de producto en modo catálogo.
 *
 * La tienda no muestra precios ni tiene carrito ni pago: se cotiza por WhatsApp.
 * En el tema padre TODO el bloque de compra cuelga de {if !$configuration.is_catalog},
 * así que en la ficha quedaba un <div class="product-add-to-cart"> vacío y el
 * visitante que abría un producto no tenía forma de pedirlo — los listados sí
 * llevan el botón, pero la ficha no. Aquí se pone en su sitio el selector de
 * cantidad y el mismo botón «Agregar a mi cotización».
 *
 * Si algún día se desactiva el modo catálogo, se devuelve el bloque del padre.
 *}
{if $configuration.is_catalog}
  <div class="product-add-to-cart js-product-add-to-cart itcot-ficha">

    <span class="control-label">{l s='Cantidad' d='Modules.Itcotizacion.Shop'}</span>

    <div class="itcot-ficha__fila">
      <div class="itcot-ficha__qty">
        <button type="button" class="itcot-qty" data-itcot-paso="-1"
                aria-label="{l s='Quitar uno' d='Modules.Itcotizacion.Shop'}">&minus;</button>
        <input type="number" id="itcot-qty-ficha" value="1" min="1" max="9999"
               inputmode="numeric" aria-label="{l s='Cantidad' d='Modules.Itcotizacion.Shop'}">
        <button type="button" class="itcot-qty" data-itcot-paso="1"
                aria-label="{l s='Agregar uno' d='Modules.Itcotizacion.Shop'}">+</button>
      </div>

      <button type="button" class="itcot-agregar"
        data-id="{$product.id_product}"
        data-ref="{$product.reference|escape:'html':'UTF-8'}"
        data-nombre="{$product.name|escape:'html':'UTF-8'}"
        data-url="{$product.url}"
        data-img="{if isset($product.cover.bySize.home_default.url)}{$product.cover.bySize.home_default.url}{/if}"
        data-qty-from="#itcot-qty-ficha">
        <i class="material-icons">&#xE8B0;</i>
        <span>{l s='Agregar a mi cotización' d='Modules.Itcotizacion.Shop'}</span>
      </button>
    </div>

    <p class="itcot-ficha__nota">
      {l s='Sin precios en línea: arma tu lista y un asesor te responde por WhatsApp con precio, disponibilidad y tiempo de entrega.' d='Modules.Itcotizacion.Shop'}
    </p>

    {if !empty($product.availability_message)}
      <p class="itcot-ficha__stock">{$product.availability_message}</p>
    {/if}

  </div>
{else}
  {include file='parent:catalog/_partials/product-add-to-cart.tpl'}
{/if}
