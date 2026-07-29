{**
 * Copyright  PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License 3.0 (AFL-3.0)
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to https://devdocs.prestashop.com/ for more information.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright   PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 *}

<section class="viewed-products clearfix block {if isset($profile_params.pl_config.class) && $profile_params.pl_config.class != ""}{$profile_params.pl_config.class}{/if}" data-type="viewedproduct">
	<h2 class="products-section-title">
		{l s='Viewed products' d='Shop.Theme.Catalog'}
	</h2>
  <div class="block_content">
    <div class="products">
      <div class="slick-row">
        <div id="viewed-products" class="leoslick slick-slider slick-loading">
          {foreach from=$products item="product" name=mypLoop}
            <div class="slick-slide item{if $smarty.foreach.mypLoop.index == 0} first{/if}">
              {block name='product_miniature'}
                {if isset($profile_params.pl_url) && $profile_params.pl_url}
                    {include file=$profile_params.pl_url product=$product}
                {else}
                  {include file='catalog/_partials/miniatures/product.tpl' product=$product}
                {/if}
              {/block}
            </div>
          {/foreach}
        </div>
      </div>
    </div>
  </div>
</section>
<script type="text/javascript">

  products_list_functions.push(
    function(){
        // https://stackoverflow.com/questions/5339876/how-to-check-jquery-plugin-and-functions-exists
        if($().slick) {
            $('#viewed-products').slick({
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
                        breakpoint: 480,
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