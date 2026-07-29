{* 
* @Module Name: Leo Parts Filter
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  2007-2022 Leotheme
*}

{block name='content'}
  <section id="main">


    <section id="products">
      {if isset($listing.products) && $listing.products|count}
        <div id="">
          {block name='product_list'}
            <div id="js-product-list">
              <div class="products">  
                {assign var="products" value=$listing.products}
                {if isset($productProfileDefault) && $productProfileDefault && 0}
                  {include file='catalog/_partials/miniatures/leo_col_products.tpl' products=$products} 
                {else}
 
                    {foreach from=$products item="product"}
                      <div class="ajax_block_product product_block">
                        {block name='product_miniature'}
                        <div class="search__result-row">
                          <div class="col-1">
                            <div class="col-1-1">
                                  {block name='product_thumbnail'}
                                    {if $product.cover}
                                      <a href="{$product.canonical_url}" class="thumbnail product-thumbnail">
                                        <img
                                          src="{$product.cover.bySize.home_default.url}"
                                          alt="{if !empty($product.cover.legend)}{$product.cover.legend}{else}{$product.name|escape:'htmlall':'UTF-8'}{/if}"
                                          data-full-size-image-url="{$product.cover.large.url}"
                                        />
                                      </a>
                                    {else}
                                      <a href="{$product.canonical_url}" class="thumbnail product-thumbnail">
                                        <img src="{$urls.no_picture_image.bySize.home_default.url}" />
                                      </a>
                                    {/if}
                                  {/block}
                              </div>
                              <div class="col-1-2">
                                  <a href="{$product.canonical_url}" class="product-name">
                                      {$product.name|escape:'htmlall':'UTF-8'}
                                  </a>
                                  <div>
                                    {block name='product_price_and_shipping'}
                                      {if $product.show_price}
                                        <div class="product-price-and-shipping">
                                          {if $product.has_discount}
                                            {hook h='displayProductPriceBlock' product=$product type="old_price"}

                                            <span class="sr-only">{l s='Regular price' mod='leopartsfilter'}</span>
                                            <span class="regular-price">{$product.regular_price|escape:'htmlall':'UTF-8'}</span>
                                            {if $product.discount_type === 'percentage'}
                                              <span class="discount-percentage discount-product">{$product.discount_percentage|escape:'htmlall':'UTF-8'}</span>
                                            {elseif $product.discount_type === 'amount'}
                                              <span class="discount-amount discount-product">{$product.discount_amount_to_display|escape:'htmlall':'UTF-8'}</span>
                                            {/if}
                                          {/if}

                                          {hook h='displayProductPriceBlock' product=$product type="before_price"}

                                          <span class="sr-only">{l s='Price' mod='leopartsfilter'}</span>
                                          <span itemprop="price" class="price">{$product.price|escape:'htmlall':'UTF-8'}</span>

                                          {hook h='displayProductPriceBlock' product=$product type='unit_price'}

                                          {hook h='displayProductPriceBlock' product=$product type='weight'}
                                        </div>
                                      {/if}
                                    {/block}
                                  </div>
                                  <div class="product-list__vehicle mb-24">
                                    {$product.description_short|strip_tags:true|escape:'htmlall':'UTF-8'}
                                  </div>
                              </div>
                          </div>
                        </div>
                        {/block}
                      </div>
                    {/foreach}

                {/if}  
              </div>
            </div>
          {/block}
        </div>

      {else}

        {*{include file='errors/not-found.tpl'}*}
        
        <section id="content" class="page-content page-not-found">
          {block name='page_content'}
            <div id="js-product-list">
              <div class="no-product-list">
                <h4>{l s='Sorry for the inconvenience.' mod='leopartsfilter'}</h4>
                <p>{l s='Search again what you are looking for' mod='leopartsfilter'}</p>
              </div>
            </div>

            {block name='hook_not_found'}
              {hook h='displayNotFound'}
            {/block}

          {/block}
        </section>
            

      {/if}
    </section>

  </section>
{/block}