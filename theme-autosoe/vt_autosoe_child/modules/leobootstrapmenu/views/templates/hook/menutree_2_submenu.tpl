{* 
* @Module Name: Leo Blog
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  Leotheme
* @description: Content Management
*}
{if isset($colums) && $colums > 1}
    <div class="{$class} level{$level}" {$attrw} >
        <div class="dropdown-menu-inner">
            <div class="row">
                <div class="col-sm-12 mega-col" data-colwidth="12" data-type="menu" >
                    <div class="inner">
                        <div class="row">
                            {foreach from=$data item=menu}
                                <ul class="col-md-{$cols}">
                                    {$mod_menu->renderMenuContent($menu, $level + 1, $typesub, $group_type) nofilter}
                                </ul>
                            {/foreach}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
{else}
    <div class="{$class} level{$level}" {$attrw} >
        <div class="dropdown-menu-inner">
            <div class="row">
                <div class="col-sm-12 mega-col" data-colwidth="12" data-type="menu" >
                    <div class="inner">
                        <div class="menu-title back">
                            <span>{$menu.title} </span>
                        </div>
                        <ul>
                            {foreach from=$data item=menu}
                                {$mod_menu->renderMenuContent($menu, $level + 1, $typesub, $group_type) nofilter}{* HTML form , no escape necessary *}
                            {/foreach}
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}