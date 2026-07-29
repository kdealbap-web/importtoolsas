{* 
* @Module Name: Leo Elements
* @Website: leotheme.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright Leotheme
* @description: Leo Elements is module help you can build content for your shop
*}

<section id="main" class="product-detail product_image_no_thumbs_center product-image-thumbs no-thumbs"><div class="row"><div class="col-xl-4 col-lg-4 col-md-12 col-sm-12 col-xs-12 col-sp-12">
{block name='page_header_container'}
	{block name='page_header'}
		<h1 class="h1 product-detail-name">{block name='page_title'}{$product.name}{/block}</h1>
	{/block}
{/block}
{block name='product_description_short'}
  <div id="product-description-short-{$product.id}" class="description-short">{$product.description_short nofilter}</div>
{/block}
{hook h='displayLeoProductReviewExtra' product=$product}<div class="leo-more-cdown in_detail" data-idproduct="{$product.id_product}"></div>
{block name='product_prices'}
	{include file='catalog/_partials/product-prices.tpl'}
{/block}

{if $product.is_customizable && count($product.customizations.fields)}
	{block name='product_customization'}
	 	{include file="catalog/_partials/product-customization.tpl" customizations=$product.customizations}
	{/block}
{/if}<div class="line">

<div class="p-reference">
     <div class="product-quantities"></div>
     <div class="product-reference">				        
    </div>
</div>


{if isset($product_manufacturer->id)}
		<div class="product-manufacturer">   
          	<label class="label">{l s='Brand' d='Shop.Theme.Catalog'}:</label>
          	<span>
            	<a href="{$product_brand_url}">{$product_manufacturer->name}</a>
          	</span>
      	</div>
    {/if}



<div class="productcats">
    <label class="label">{l s='Categories' d='Shop.Theme.Catalog'}: </label>
    <ul>
    
        {foreach from=Product::getProductCategoriesFull(Tools::getValue('id_product')) item=cat}
    
        <li><a href="{$link->getCategoryLink({$cat.id_category})}" title="{$cat.name}">{$cat.name}</a></li>
    
        {/foreach}
    
    </ul>
</div>

</div>


{block name='product_additional_info'}
	{include file='catalog/_partials/product-additional-info.tpl'}
{/block}
                            </div><div class="col-xl-5 col-lg-5 col-md-12 col-sm-12 col-xs-12 col-sp-12">
{block name='page_content_container'}
  <section class="page-content" id="content" data-templateview="none" data-numberimage="5" data-numberimage1200="5" data-numberimage992="4" data-numberimage768="3" data-numberimage576="3" data-numberimage480="2" data-numberimage360="2" data-templatemodal="1" data-templatezoomtype="none" data-zoomposition="right" data-zoomwindowwidth="400" data-zoomwindowheight="400" data-use_leo_gallery="0">
    {block name='page_content'}
      <div class="images-container">
        {block name='product_cover_thumbnails'}
          {block name='product_cover'}
            <div class="product-cover">
              {block name='product_flags'}
                <ul class="product-flags">
                  {foreach from=$product.flags item=flag}
                    <li class="product-flag {$flag.type}">{$flag.label}</li>
                  {/foreach}
                </ul>
              {/block}
              {if $product.default_image}
            		<img id="zoom_product" data-type-zoom="" class="js-qv-product-cover img-fluid" src="{$product.default_image.bySize.large_default.url}" {if !empty($product.default_image.legend)}
            			alt="{$product.default_image.legend}"
            			title="{$product.default_image.legend}"
            		   {else}
            			alt="{$product.name}"
            		    {/if}
            			loading="lazy"
            		>
                <div class="layer hidden-sm-down" data-toggle="modal" data-target="#product-modal">
                  <i class="material-icons zoom-in">&#xE8FF;</i>
                </div>
              {else}
                <img id="zoom_product" data-type-zoom="" class="js-qv-product-cover img-fluid" src="{$urls.no_picture_image.bySize.large_default.url}"  loading="lazy" alt="{$product.name}" title="{$product.name}">
			  {/if}
            </div>
          {/block}

          {block name='product_images'}
            <div id="thumb-gallery" class="product-thumb-images elementor-slick-slider">
              {if $product.default_image}
                {foreach from=$product.images item=image}
                  <div class="thumb-container {if $image.id_image == $product.default_image.id_image} active {/if}">
                    <a href="javascript:void(0)" data-image="{$image.bySize.large_default.url}" data-zoom-image="{$image.bySize.large_default.url}"> 
                      <img
                        class="thumb img-fluid js-thumb {if $image.id_image == $product.default_image.id_image} selected {/if}"
                        data-image-medium-src="{$image.bySize.large_default.url}"
                        data-image-large-src="{$image.bySize.large_default.url}"
                        src="{$image.bySize.small_default.url}"
                        alt="{$image.legend}"
                        title="{$image.legend}"
			                  loading="lazy"
                      >
                    </a>
                  </div>
                {/foreach}
              {else}
                <div class="thumb-container">
                  <a href="javascript:void(0)" data-image="{$urls.no_picture_image.bySize.large_default.url}" data-zoom-image="{$urls.no_picture_image.bySize.large_default.url}"> 
                    <img 
                      class="thumb js-thumb img-fluid" 
                      data-image-medium-src="{$urls.no_picture_image.bySize.large_default.url}"
                      data-image-large-src="{$urls.no_picture_image.bySize.large_default.url}"
                      src="{$urls.no_picture_image.bySize.small_default.url}"
                      alt="{$product.name}"
                      title="{$product.name}"
		                  loading="lazy"
                    >
                  </a>
                </div>
              {/if}
            </div>
            
            {if $product.images|@count > 1}
              <div class="arrows-product-fake slick-arrows">
                <button class="slick-prev slick-arrow" aria-label="Previous" type="button" >{l s='Previous' d='Shop.Theme.Catalog'}</button>
                <button class="slick-next slick-arrow" aria-label="Next" type="button">{l s='Next' d='Shop.Theme.Catalog'}</button>
              </div>
            {/if}
          {/block}
        
        {/block}
        {hook h='displayAfterProductThumbs'}
      </div>
    {/block}
  </section>
{/block}

{block name='product_images_modal'}
  {include file='catalog/_partials/product-images-modal.tpl'}
{/block}

                            </div><div class="col-xl-3 col-lg-3 col-md-12 col-sm-12 col-xs-12 col-sp-12">
<div class="product-actions">
  {block name='product_buy'}
    <form action="{$urls.pages.cart}" method="post" id="add-to-cart-or-refresh">
      <input type="hidden" name="token" value="{$static_token}">
      <input type="hidden" name="id_product" value="{$product.id}" id="product_page_product_id">
      <input type="hidden" name="id_customization" value="{$product.id_customization}" id="product_customization_id">

      {block name='product_variants'}
        {include file='catalog/_partials/product-variants.tpl'}
      {/block}

      {block name='product_pack'}
        {if $packItems}
          <section class="product-pack">
            <h3 class="h4">{l s='This pack contains' d='Shop.Theme.Catalog'}</h3>
            {foreach from=$packItems item="product_pack"}
              {block name='product_miniature'}
                {include file='catalog/_partials/miniatures/pack-product.tpl' product=$product_pack showPackProductsPrice=$product.show_price}
              {/block}
            {/foreach}
        </section>
        {/if}
      {/block}

      {block name='product_discounts'}
        {include file='catalog/_partials/product-discounts.tpl'}
      {/block}

      {block name='product_add_to_cart'}
        {include file='catalog/_partials/product-add-to-cart.tpl'}
      {/block}

      {block name='product_refresh'}
        <input class="product-refresh ps-hidden-by-js" name="refresh" type="submit" value="{l s='Refresh' d='Shop.Theme.Actions'}">
      {/block}
    </form>
  {/block}
</div>
{block name='hook_display_reassurance'}
  {hook h='displayReassurance'}
{/block}<img src="https://cdn.shopify.com/s/files/1/0489/1171/2423/files/vt_fashion_elements_detail_payment.png?v=1723814477" alt=""/>
                            </div><div class="col-md-12 col-lg-12 col-xl-12 col-sm-12 col-xs-12 col-sp-12">
{include file="sub/product_info/tab.tpl"}
{block name='product_accessories'}
    {if $accessories}
      <section class="product-accessories clearfix">
        <p class="h5 products-section-title text-uppercase">{l s='You might also like' d='Shop.Theme.Catalog'}</p>
        <div class="products">
          <div class="slick-row {if isset($profile_params.pl_config.class) && $profile_params.pl_config.class != ""}{$profile_params.pl_config.class}{/if}">
            <div id="category-products2" class="elementor-slick-slider leoslick slick-slider slick-loading">
              {foreach from=$accessories item="product_accessory" key="position"}
                <div class="slick-slide item{if $smarty.foreach.mypLoop.index == 0} first{/if}">
                  {block name='product_miniature'}
                    {if isset($profile_params.pl_url) && $profile_params.pl_url}
                        {include file=$profile_params.pl_url product=$product_accessory position=$position}
                    {else}
                      {include file='catalog/_partials/miniatures/product.tpl' product=$product}
                    {/if}
                  {/block}
                </div>
              {/foreach}
            </div>
          </div>
        </div>
      </section>
    {/if}
{/block}
<script type="text/javascript">

  products_list_functions.push(
    function(){
        // https://stackoverflow.com/questions/5339876/how-to-check-jquery-plugin-and-functions-exists
        if($().slick) {
            $('#category-products2').slick({
                centerMode: false,
                centerPadding: '0px',
                dots: true,
                infinite: false,
                vertical: false,
                verticalSwiping : false,
                autoplay: false,
                pauseonhover: false,
                autoplaySpeed: 5000,
                speed: 500,
                arrows: true,
                rows: 1,
                slidesToShow: 4,
                slidesToScroll: 4,
                rtl: {if isset($IS_RTL) && $IS_RTL}true{else}false{/if},
                responsive:
                [
                    {
                        breakpoint: 992,
                        settings: {
                            slidesToShow: 3,
                            slidesToScroll: 3
                        }
                    },
					{
                        breakpoint: 768,
                        settings: {
                            slidesToShow: 2,
                            slidesToScroll: 2
                        }
                    },
                    {
                        breakpoint: 400,
                        settings: {
                            slidesToShow: 1,
                            slidesToScroll: 1
                        }
                    }
                ]
            });
        }
    }
  ); 

</script>
{block name='product_footer'}
	{hook h='displayFooterProduct' product=$product category=$category}
{/block}
                            </div></div>
{block name='page_footer_container'}
	  <footer class="page-footer">
	    {block name='page_footer'}
	    	<!-- Footer content -->
	    {/block}
	  </footer>
	{/block}
</section>

