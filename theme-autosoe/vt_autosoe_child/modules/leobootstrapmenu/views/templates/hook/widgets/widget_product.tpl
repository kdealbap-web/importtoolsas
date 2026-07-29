{* 
* @Module Name: Leo Bootstrap Menu
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  Leotheme
*}

<div class="leo-widget" data-id_widget="{$id_widget}">
{if isset($product)}
    <div class="widget-product">
	{if isset($widget_heading)&&!empty($widget_heading)}
	<div class="menu-title">
		{$widget_heading}
	</div>
	{/if}
	<div class="widget-inner">
		<div class="product_block"> 
 			<div class="product-miniature js-product-miniature" data-id-product="{$product.id_product}" data-id-product-attribute="{$product.id_product_attribute}">
			  	<div class="thumbnail-container clearfix">
			    	<div class="product-image">
				      	{block name='product_thumbnail'}
					        <a href="{$product.url}" class="thumbnail product-thumbnail">
					          	<img
						            class="img-fluid{if isset($aplazyload) && $aplazyload} lazy{/if}"
						            {if isset($aplazyload) && $aplazyload}data-src{else}src{/if} = "{$product.cover.bySize.cart_default.url}"
						            alt = "{if !empty($product.cover.legend)}{$product.cover.legend}{else}{$product.name|truncate:30:'...'}{/if}"
						            data-full-size-image-url = "{$product.cover.large.url}"
					          	>
					        </a>
				      	{/block}
			    	</div>
				    <div class="product-meta">
				      	<div class="product-description">
					        {block name='product_name'}
					          	<h4 class="h3 product-title"><a href="{$product.url}">{$product.name|truncate:30:'...'}</a></h4>
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
			  	</div>
			</div>	
		</div>	
	</div>
    </div>
{/if} 
{if $show_widget_bo == 'admin'}
    <div class="w-name">
        <select name="inject_widget" class="inject_widget_name">
            {foreach from=$widgets item=w}
                <option value="{$w['key_widget']}">
                    {$w['name']}
                </option>
            {/foreach}
        </select>
    </div>
{/if}
</div>