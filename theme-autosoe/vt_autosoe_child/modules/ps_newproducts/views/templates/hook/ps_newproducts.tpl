{**
 * Copyright since  PrestaShop SA and Contributors
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
 * @copyright Since  PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 *}

<section class="featured-products block clearfix mt-3" data-type="newproducts">
  <h2 class="h2 products-section-title title_block text-uppercase">
    {l s='New products' d='Shop.Theme.Catalog'}
  </h2>
  <div class="block_content">
    {if isset($profile_params)}
      <div class="products">
        {include file='catalog/_partials/miniatures/leo_col_products.tpl' products=$products}
      </div>
    {else}
       {include file="catalog/_partials/productlist.tpl" products=$products}
     {/if}
     <a class="all-product-link float-xs-left float-md-right h4" href="{$allNewProductsLink}">
      {l s='All new products' d='Shop.Theme.Catalog'}<i class="material-icons">&#xE315;</i>
     </a>
  </div>
</section>

