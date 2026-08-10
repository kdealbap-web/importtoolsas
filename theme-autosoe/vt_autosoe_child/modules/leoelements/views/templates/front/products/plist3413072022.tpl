{*
* @Module Name: Leo Elements
* @Website: leotheme.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright Leotheme
* @description: Leo Elements is module help you can build content for your shop
*}
{**
 * ────────────────────────────────────────────────────────────────────────────
 * MODIFICADO — Import Tools Latam · 08/08/2026
 *
 * ESTA es la plantilla que pinta el listado de categoría, el buscador y los
 * carruseles del home: «Product style 01» = `plist3413072022`, elegida por el
 * cliente. No es `catalog/_partials/miniatures/product.tpl` del núcleo, que en
 * esta tienda **no se usa** (comprobado: 0 apariciones de sus clases en el HTML).
 *
 * Cambio: cuando el producto NO tiene foto, en vez del marcador «Imagen no
 * disponible» —que hoy sale en casi todas las tarjetas y llegó a repetirse
 * DIECISÉIS veces en una sola pantalla del home— se muestra la REFERENCIA, que
 * es el dato con el que un ferretero pide («mándame 10 NIK-AC2540»), y la marca.
 *
 * Y no hay que hacer NADA el día que lleguen las fotos: cada producto pasa al
 * modo con imagen en cuanto el cliente le sube una desde el panel, uno a uno.
 *
 * ⚠️ Al actualizar el tema padre se recopia `themes/vt_autosoe/modules/` sobre el
 *    hijo (ver CLAUDE.md, Fase 3). Hay que volver a aplicar este cambio.
 * ────────────────────────────────────────────────────────────────────────────
 *}
<article class="product-miniature js-product-miniature{if !$product.cover} product-miniature--sin-foto{/if}" data-id-product="{$product.id_product}" data-id-product-attribute="{$product.id_product_attribute}">
  <div class="thumbnail-container">
    <div class="product-image">
{block name='product_thumbnail'}
	{if isset($profile_params.pl_config.plist_load_multi_product_img) && $profile_params.pl_config.plist_load_multi_product_img}
		<div class="leo-more-info" data-idproduct="{$product.id_product}"></div>
	{/if}
	{if $product.cover}
		{if $profile_params.pl_config.lmobile_swipe == 1 && $isMobile}
		    <div class="product-list-images-mobile">
		    	<div>
		{/if}
			    	<a href="{$product.url}" class="thumbnail product-thumbnail">
					  <img
						class="img-fluid"
						src = "{$product.cover.bySize.home_default.url}"
						alt = "{$product.cover.legend}"
						data-full-size-image-url = "{$product.cover.large.url}"
					  >
					  {if isset($profile_params.pl_config.plist_load_more_product_img) && $profile_params.pl_config.plist_load_more_product_img && $profile_params.pl_config.plist_load_more_product_img_option == 1}
							<span class="second-image-style product-additional" data-idproduct="{if $profile_params.pl_config.lmobile_swipe && $isMobile}0{else}{$product.id_product}{/if}"></span>
						{elseif isset($profile_params.pl_config.plist_load_more_product_img) && $profile_params.pl_config.plist_load_more_product_img && $profile_params.pl_config.plist_load_more_product_img_option == 2}
							<span class="second-image-style product-attribute-additional" data-idproduct="{if $profile_params.pl_config.lmobile_swipe && $isMobile}0{else}{$product.id_product}{/if}" data-id-product-attribute="{$product.id_product_attribute}" data-id-image="{$product.cover.id_image}"></span>
						{elseif isset($profile_params.pl_config.plist_load_more_product_img) && $profile_params.pl_config.plist_load_more_product_img && $profile_params.pl_config.plist_load_more_product_img_option == 3}
							<span class="second-image-style product-all-additional" data-idproduct="{if $profile_params.pl_config.lmobile_swipe && $isMobile}0{else}{$product.id_product}{/if}" data-id-product-attribute="{$product.id_product_attribute}" data-id-image="{$product.cover.id_image}"></span>
					  {/if}
					</a>
		{if $profile_params.pl_config.lmobile_swipe == 1 && $isMobile}
				</div>
		    	{foreach from=$product.images item=image}
			    	{if $product.cover.bySize.home_default.url != $image.bySize.home_default.url}
			            <div>
					    	<a href="{$product.url}" class="thumbnail product-thumbnail">
			                    <img
			                      class="thumb js-thumb img-fluid {if $image.id_image == $product.cover.id_image} selected {/if}"
			                      src="{$image.bySize.home_default.url}"
			                      alt="{$image.legend}"
			                      title="{$image.legend}"
								  loading="lazy"
			                    >
			                </a>
						</div>	
					{/if}
				{/foreach}
			</div>
		{/if}
	{else}
	  {* Sin foto: ficha de referencia en lugar del marcador del núcleo. Sigue
	     siendo un enlace, así que toda la zona superior de la tarjeta es pulsable. *}
	  <a href="{$product.url}" class="thumbnail product-thumbnail leo-noimage itsf">
	    <span class="itsf__ref">{if $product.reference}{$product.reference}{else}{l s='Ver ficha'}{/if}</span>
	    {if !empty($product.manufacturer_name)}<span class="itsf__marca">{$product.manufacturer_name}</span>{/if}
	  </a>
	{/if}
{/block}
{block name='product_flags'}
<ul class="product-flags">
  {foreach from=$product.flags item=flag}
	<li class="product-flag {$flag.type}">{$flag.label}</li>
  {/foreach}
</ul>
{/block}
<div class="functional-buttons clearfix">
{hook h='displayLeoWishlistButton' product=$product}

{hook h='displayLeoCompareButton' product=$product}
</div><div class="button__group">
{hook h='displayLeoCartButton' product=$product}

<div class="quickview{if !$product.main_variants} no-variants{/if} hidden-sm-down">
<a
  href="#"
  class="quick-view"
  data-link-action="quickview" title="{l s='Quick view'}"
>
	<span class="leo-quickview-bt-loading cssload-speeding-wheel"></span>
	<span class="leo-quickview-bt-content">
		<i class="material-icons search">&#xE8B6;</i>
		<span>{l s='Quick view'}</span>
	</span>
</a>
</div>
</div></div>
    <div class="product-meta">
{block name='product_name'}
  <h3 class="h3 product-title"><a href="{$product.url}">{$product.name|truncate:70:'...'}</a></h3>
{/block}

{block name='product_price_and_shipping'}
  {if $product.show_price}
    <div class="product-price-and-shipping">
      {if $product.has_discount}
        {hook h='displayProductPriceBlock' product=$product type="old_price"}

        <span class="regular-price" aria-label="{l s='Regular price' d='Shop.Theme.Catalog'}">{$product.regular_price}</span>
        {if $product.discount_type === 'percentage'}
          <span class="discount-percentage discount-product">{$product.discount_percentage}</span>
        {elseif $product.discount_type === 'amount'}
          <span class="discount-amount discount-product">{$product.discount_amount_to_display}</span>
        {/if}
      {/if}

      {hook h='displayProductPriceBlock' product=$product type="before_price"}

      <span class="price" aria-label="{l s='Price' d='Shop.Theme.Catalog'}">
        {capture name='custom_price'}{hook h='displayProductPriceBlock' product=$product type='custom_price' hook_origin='products_list'}{/capture}
        {if '' !== $smarty.capture.custom_price}
          {$smarty.capture.custom_price nofilter}
        {else}
          {$product.price}
        {/if}
      </span>

      {hook h='displayProductPriceBlock' product=$product type='unit_price'}

      {hook h='displayProductPriceBlock' product=$product type='weight'}
    </div>
  {/if}
{/block}
</div>
  </div>
</article>
