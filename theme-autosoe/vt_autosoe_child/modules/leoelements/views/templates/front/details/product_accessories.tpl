{* 
* @Module Name: Leo Elements
* @Website: leotheme.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright Leotheme
* @description: LeoElements is module help you can build content for your shop
*}
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
                dots: false,
                infinite: false,
                vertical: false,
                verticalSwiping : false,
                autoplay: false,
                pauseonhover: false,
                autoplaySpeed: 5000,
                speed: 500,
                arrows: true,
                rows: 1,
                slidesToShow: 5,
                slidesToScroll: 5,
                rtl: {if isset($IS_RTL) && $IS_RTL}true{else}false{/if},
                responsive:
                [
                   {
                        breakpoint: 1200,
                        settings: {
                            slidesToShow: 4,
                            slidesToScroll: 4
                        }
                    },
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