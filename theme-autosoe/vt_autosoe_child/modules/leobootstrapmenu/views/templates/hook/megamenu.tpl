{* 
* @Module Name: Leo Bootstrap Menu
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  Leotheme
*}
{if isset($error) && $error}
    <div class="alert alert-warning leo-lib-error">{$error}</div>
{else}
    
    {if $group_type && $group_type == 'horizontal'}
            <nav data-megamenu-id="{$megamenu_id}" class="leo-megamenu cavas_menu navbar navbar-default {if $show_cavas && $show_cavas == 1}enable-canvas{else}disable-canvas{/if} {if $group_class && $group_class != ''}{$group_class}{/if}" role="navigation">
                            <!-- Brand and toggle get grouped for better mobile display -->
                            <div class="navbar-header">
                                    <button type="button" class="navbar-toggler hidden-lg-up" data-toggle="collapse" data-target=".megamenu-off-canvas-{$megamenu_id}">
                                            <span class="sr-only">{l s='Toggle navigation' mod='leobootstrapmenu'}</span>
                                            &#9776;
                                            <!--
                                            <span class="icon-bar"></span>
                                            <span class="icon-bar"></span>
                                            <span class="icon-bar"></span>
                                            -->
                                    </button>
                            </div>
                            <!-- Collect the nav links, forms, and other content for toggling -->
                            {*
                            <div id="leo-top-menu" class="collapse navbar-collapse navbar-ex1-collapse">{$boostrapmenu|escape:'html':'UTF-8'}</div>
                            *}
                            <div class="leo-top-menu collapse navbar-toggleable-md megamenu-off-canvas megamenu-off-canvas-{$megamenu_id}">{$boostrapmenu|escape:'html':'UTF-8' nofilter}{* HTML form , no escape necessary *}</div>
            </nav>
<script type="text/javascript">
	list_menu_tmp.id = '{$megamenu_id}';
	list_menu_tmp.type = 'horizontal';
{if $show_cavas && $show_cavas == 1}
	list_menu_tmp.show_cavas =1;
{else}
	list_menu_tmp.show_cavas =0;	
{/if}
	list_menu_tmp.list_tab = list_tab;
	list_menu.push(list_menu_tmp);
	list_menu_tmp = {};	
	list_tab = {};
</script>
    {else}
            <div data-megamenu-id="{$megamenu_id}" class="leo-verticalmenu {if $group_class && $group_class != ''}{$group_class}{/if}">
                    <h4 class="title_block verticalmenu-button">
                    <span class="icon-bar"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M2 6C2 5.44772 2.44772 5 3 5H21C21.5523 5 22 5.44772 22 6C22 6.55228 21.5523 7 21 7H3C2.44772 7 2 6.55228 2 6ZM2 12C2 11.4477 2.44772 11 3 11H21C21.5523 11 22 11.4477 22 12C22 12.5523 21.5523 13 21 13H3C2.44772 13 2 12.5523 2 12ZM2 18C2 17.4477 2.44772 17 3 17H15C15.5523 17 16 17.4477 16 18C16 18.5523 15.5523 19 15 19H3C2.44772 19 2 18.5523 2 18Z" fill="currentColor"/>
                </svg></span>

                    {$group_title}
                    <span class="icon-dropdown"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 15.0006L7.75732 10.758L9.17154 9.34375L12 12.1722L14.8284 9.34375L16.2426 10.758L12 15.0006Z" fill="currentColor"/>
                        </svg>
                        </span>

                    </h4>
                    <div class="box-content block_content">
                            <div class="verticalmenu" role="navigation">{$boostrapmenu|escape:'html':'UTF-8' nofilter}{* HTML form , no escape necessary *}</div>
                    </div>
            </div>
<script type="text/javascript">
	list_menu_tmp.id = '{$megamenu_id}';
	list_menu_tmp.type = 'vertical';
	list_menu_tmp.list_tab = list_tab;
	list_menu.push(list_menu_tmp);
	list_menu_tmp = {};
	list_tab = {};
</script>


    {/if}

{/if}
