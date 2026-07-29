{* 

* @Module Name: Leo Parts Filter

* @Website: leotheme.com.com - prestashop template provider

* @author Leotheme <leotheme@gmail.com>

* @copyright  2007-2022 Leotheme

*}

{extends file='catalog/listing/product-list.tpl'}



{block name='content'}

  <section id="main">



    {block name='product_list_header'}

      <div>

        {hook h='displayFilter'}

      </div>

    {/block}



    <section id="products" class="{if isset($profile_params.pl_config.class) && $profile_params.pl_config.class != ""}{$profile_params.pl_config.class}{/if}">

      {if isset($listing.products) && $listing.total}

        <div id="js-product-list-top" class="row products-selection">

          <div class="leo-filter-total-product col-md-6 hidden-sm-down total-products">

            {l s='Total products:' d='leopartsfilter'} {$listing.total}

          </div>

          <div class="col-md-6">

            <span class="col-sm-3 col-md-3 hidden-sm-down sort-by">{l s='Sort by:' d='Shop.Theme.Catalog'}</span>

            <div class="col-md-9 products-sort-order dropdown">
              <div class="btn-group bootstrap-select leo-filter-order dropup">
                <button type="button" class="btn dropdown-toggle btn-default" data-toggle="dropdown" aria-expanded="false">
                  <span class="filter-option pull-left">
                    {if $order == 'product.position.asc' || !$order}
                      {l s='Relevance' d='Shop.Theme.Catalog'}
                    {/if}
                    {if $order == 'product.name.asc'}
                      {l s='Name, A to Z' d='Shop.Theme.Catalog'}
                    {/if}
                    {if $order == 'product.name.desc'}
                      {l s='Name, Z to A' d='Shop.Theme.Catalog'}
                    {/if}
                    {if $order == 'product.price.asc'}
                      {l s='Price, low to high' d='Shop.Theme.Catalog'}
                    {/if}
                    {if $order == 'product.price.desc'}
                      {l s='Price, high to low' d='Shop.Theme.Catalog'}
                    {/if}
                  </span>&nbsp; <span class="caret" aria-hidden="true"></span>
                </button>
                <div class="dropdown-menu open" style="max-height: 286.167px; overflow: hidden; min-height: 73px;">
                  <ul class="dropdown-menu inner" role="menu" style="max-height: 270.167px; overflow-y: auto; min-height: 57px;">
                    <li data-original-index="0" class="selected">
                      <a tabindex="0" href="index.php?fc=module&module=leopartsfilter&controller=search&make={$id_make}&model={$id_model}&year={$id_year}&device={$id_device}&order=product.position.asc">
                        <span class="text">{l s='Relevance' d='Shop.Theme.Catalog'}</span>
                      </a>
                    </li>
                    <li data-original-index="1">
                      <a tabindex="1" href="index.php?fc=module&module=leopartsfilter&controller=search&make={$id_make}&model={$id_model}&year={$id_year}&device={$id_device}&order=product.name.asc">
                        <span class="text">{l s='Name, A to Z' d='Shop.Theme.Catalog'}</span>
                      </a>
                    </li>
                    <li data-original-index="2">
                      <a tabindex="2" href="index.php?fc=module&module=leopartsfilter&controller=search&make={$id_make}&model={$id_model}&year={$id_year}&device={$id_device}&order=product.name.desc">
                        <span class="text">{l s='Name, Z to A' d='Shop.Theme.Catalog'}</span>
                      </a>
                    </li>
                    <li data-original-index="3">
                      <a tabindex="3" href="index.php?fc=module&module=leopartsfilter&controller=search&make={$id_make}&model={$id_model}&year={$id_year}&device={$id_device}&order=product.price.asc">
                        <span class="text">{l s='Price, low to high' d='Shop.Theme.Catalog'}</span>
                      </a>
                    </li>
                    <li data-original-index="4">
                      <a tabindex="4" href="index.php?fc=module&module=leopartsfilter&controller=search&make={$id_make}&model={$id_model}&year={$id_year}&device={$id_device}&order=product.price.desc">
                        <span class="text">{l s='Price, high to low' d='Shop.Theme.Catalog'}</span>
                      </a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>

          </div>

        </div>

        <div>

          {block name='product_list'}

          {* catalog/listing/product-list.tpl *}

            {* include file='catalog/_partials/products.tpl' listing=$listing *}

            <div id="js-product-list">

              <div class="products products-partfilter">  

                {assign var="products" value=$listing.products}

                {if isset($productProfileDefault) && $productProfileDefault}

                  {include file='catalog/_partials/miniatures/leo_col_products.tpl' products=$products} 

                {else}

                  <div class="row ">

                    {foreach from=$products item="product"}

                      <div class="ajax_block_product product_block col-sp-12 col-xs-6 col-sm-6 col-md-6 col-lg-3 col-xl-3">

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

                {/if}  

              </div>

              <div class="hidden-md-up text-xs-right up">

                <a href="#header" class="btn btn-secondary">

                  {l s='Back to top' mod='leopartsfilter'}

                  <i class="material-icons">&#xE316;</i>

                </a>

              </div>

            </div>

          {/block}

        </div>

        <div>

          {block name='pagination_page_list'}

           {if $listing.pagination.should_be_displayed}

              <ul class="page-list clearfix text-sm-center">

                {foreach from=$listing.pagination.pages item="page"}

                  <li {if $page.current} class="current" {/if}>

                    {if $page.type === 'spacer'}

                      <span class="spacer">&hellip;</span>

                    {else}

                      <a rel="{if $page.type === 'previous'}prev{elseif $page.type === 'next'}next{else}nofollow{/if}"

                        href="{$page.url}"

                        class="{if $page.type === 'previous'}previous {elseif $page.type === 'next'}next {/if}{['disabled' => !$page.clickable]|classnames}"

                      >

                        {if $page.type === 'previous'}

                          <i class="material-icons">&#xE314;</i>{l s='Previous' d='Shop.Theme.Actions'}

                        {elseif $page.type === 'next'}

                          {l s='Next' d='Shop.Theme.Actions'}<i class="material-icons">&#xE315;</i>

                        {else}

                          {$page.page}

                        {/if}

                      </a>

                    {/if}

                  </li>

                {/foreach}

              </ul>

            {/if}

          {/block}

        </div>

      {else}

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