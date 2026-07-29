{* 
* @Module Name: Leo Bootstrap Menu
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  Leotheme
*}

<div class="leo-widget" data-id_widget="{$id_widget}">
{if isset($subcategories)}
    <div class="widget-subcategories">
        {if isset($widget_heading)&&!empty($widget_heading)}
        <div class="widget-heading">
                {$widget_heading}
        </div>
        {/if}
        <div class="widget-inner">
            {if $cat->id_category != ''}


                <div class="row desktopmenu d-sm-none d-md-block">
                    <div class="col-md-3">
                        <ul class="nav nav-pills flex-column" id="menutab{$id_widget}{$cat->id_category}" role="tablist">
                        {foreach from=$subcategories item=subcategory}
                        <li class="nav-item">
                            <a class="nav-link{if $subcategory@iteration == 1} active{/if}" id="navmenu-tab{$id_widget}{$cat->id_category}{$subcategory.id_category}" data-toggle="tab" href="#navmenu{$id_widget}{$cat->id_category}{$subcategory.id_category}" role="tab" aria-controls="{$subcategory.name|escape:'htmlall':'UTF-8'}" aria-selected="false">{$subcategory.name|escape:'htmlall':'UTF-8'}</a>
                        </li>
                        {/foreach}
                        </ul>
                    </div>
                    <div class="col-md-8">
                         <div class="tab-content" id="myTabContent{$id_widget}{$cat->id_category}">
                            {foreach from=$subcategories item=subcategory}
                            <div class="tab-pane {if $subcategory@iteration == 1} show active{/if}" id="navmenu{$id_widget}{$cat->id_category}{$subcategory.id_category}" role="tabpanel" role="tabpanel" aria-labelledby="home-tab">
                                {if isset($subcategory.subsubcategories) && $subcategory.subsubcategories}
                                <ul class="tab-menu3">
                                    {foreach from=$subcategory.subsubcategories item=subsubcategory}
                                        <li class="clearfix level3">
                                            <a href="{$link->getCategoryLink($subsubcategory.id_category, $subsubcategory.link_rewrite)|escape:'htmlall':'UTF-8'}" title="{$subsubcategory.name|escape:'htmlall':'UTF-8'}" class="img">
                                                {$subsubcategory.name|escape:'htmlall':'UTF-8'} 
                                            </a>
                                        </li>
                                    {/foreach}
                                </ul>
                                {/if}
                            </div>
                            {/foreach}
                         </div>
                    </div>
                </div>
                <div class="row menu-accordion">
                    <div id="menu-accordion{$id_widget}{$cat->id_category}">
                        {foreach from=$subcategories item=subcategory}
                        <div class="card">
                            <div class="card-header" id="mheading{$id_widget}{$cat->id_category}{$subcategory.id_category}">
                                <h5 class="mb-0">
                                    <button class="btn btn-link" data-toggle="collapse" data-target="#mcollapse{$id_widget}{$cat->id_category}{$subcategory.id_category}" aria-expanded="true" aria-controls="mcollapse{$id_widget}{$cat->id_category}{$subcategory.id_category}">
                                      {$subcategory.name|escape:'htmlall':'UTF-8'}
                                    </button>
                                </h5>
                            </div>
                            <div id="mcollapse{$id_widget}{$cat->id_category}{$subcategory.id_category}" class="collapse{if $subcategory@iteration == 1} show{/if}" aria-labelledby="mheading{$id_widget}{$cat->id_category}{$subcategory.id_category}" data-parent="#menu-accordion{$id_widget}{$cat->id_category}">
                                <div class="card-body">
                                    <ul class="tab-menu3">
                                        {foreach from=$subcategory.subsubcategories item=subsubcategory}
                                            <li class="clearfix level3">
                                                <a href="{$link->getCategoryLink($subsubcategory.id_category, $subsubcategory.link_rewrite)|escape:'htmlall':'UTF-8'}" title="{$subsubcategory.name|escape:'htmlall':'UTF-8'}" class="img">
                                                    {$subsubcategory.name|escape:'htmlall':'UTF-8'} 
                                                </a>
                                            </li>
                                        {/foreach}
                                    </ul>
                                </div>
                            </div>    
                        </div>
                        {/foreach}
                    </div>
                </div>
            {else}
                <div class="alert alert-warning">
                    {l s='The ID category does not exist' mod='leobootstrapmenu'}
                </div>
            {/if}
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