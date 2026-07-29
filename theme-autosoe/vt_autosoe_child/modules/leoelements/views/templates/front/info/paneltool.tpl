{* 
* @Module Name: Leo Elements
* @Website: leotheme.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright Leotheme
* @description: LeoElements is module help you can build content for your shop
*}
{if class_exists("LeoFrameworkHelper")}
{$skins=LeoFrameworkHelper::getSkins($LEO_THEMENAME)}
{$theme_customizations=LeoFrameworkHelper::getLayoutSettingByTheme($LEO_THEMENAME)}
<div id="leo-paneltool" class="hidden-md-down">
	{if isset($leo_panel.positions) &&  count($leo_panel.positions) > 1}
	<div class="paneltool multiproductdetailtool">
		<div class="panelbutton">
			<i class="fa fa-cog"></i>
		</div>
		<div class="panelcontent block-panelcontent block-multiproductdetailtool">
		    <div class="panelinner">
				<h4>Personalizar el tema</h4>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Product Multi Layout' mod='leoelements'}</label>
					<div class="col-sm-12">
						{if isset($leo_panel.positions.header)}
						{foreach $leo_panel.positions.header as $header}
						<a class="product-detail-demo" href="{if isset($header.demo_url)&& $header.demo_url}{$header.demo_url}{/if}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}
						{/if}
					</div>
				</div>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Content' mod='leoelements'}</label>
					<div class="col-sm-12">
						{if isset($leo_panel.positions.content)}
						{foreach $leo_panel.positions.content as $header}     
						<a class="product-detail-demo" href="{if isset($header.demo_url)&& $header.demo_url}{$header.demo_url}{else}#{/if}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}
						{/if}
					</div>
				</div>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Footer' mod='leoelements'}</label>
					<div class="col-sm-12">
						{if isset($leo_panel.positions.footer)}
						{foreach $leo_panel.positions.footer as $header}      
						<a class="product-detail-demo" href="{if isset($header.demo_url)&& $header.demo_url}{$header.demo_url}{/if}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}
						{/if}
					</div>
				</div>
			</div>
		</div>
	</div>
	{/if}
	
	<div class="paneltool themetool">
		<div class="panelbutton">
			<span>OPCIONES DEL TEMA</span>
		</div>
		<div class="block-panelcontent">
			<div class="panelcontent">
				<div class="panelinner">
					<h4>{l s='Panel Tool' mod='leoelements'}</h4>
					<!-- Theme layout mod section -->
					{if $theme_customizations && isset($theme_customizations.layout) && isset($theme_customizations.layout.layout_mode) && isset($theme_customizations.layout.layout_mode.option)}
						<div class="group-input clearfix layout">
							<label class="col-sm-12 control-label paneltool-tab"><span class="fa fa-desktop"></span>{l s='Layout Mod' mod='leoelements'}</label>
							<div class="col-sm-12 paneltool-content">
								{foreach $theme_customizations.layout.layout_mode.option as $layout}
									<span class="leo-dynamic-update-layout {if $profile_params.layout_mode == $layout.id}current-layout-mod{/if}" data-layout-mod="{$layout.id}">
										{$layout.name}
									</span>
								{/foreach}
							</div>
						</div>
					{/if}
					<!-- Float Header -->
					<div class="group-input clearfix">
						<label class="col-sm-12 control-label paneltool-tab"><span class="fa fa-credit-card"></span>{l s='Float Header' mod='leoelements'}</label>
						<div class="col-sm-12 paneltool-content">
							<div class="btn_enable_fheader">
								<span class="enable_fheader btn_yes {if $profile_params.header_sticky}current{/if}" data-value="1">
									<span>{l s='Yes' mod='leoelements'}</span>
								</span>
								<span class="enable_fheader btn_no {if !$profile_params.header_sticky}current{/if}" data-value="0">
									<span>{l s='No' mod='leoelements'}</span>
								</span>
							</div>
						</div>
					</div>
					<!-- Font Config -->
					<div class="group-input clearfix">
						<label class="col-sm-12 control-label paneltool-tab"><span class="fa fa-credit-card"></span>{l s='Font option' mod='leoelements'}</label>
						<div class="col-sm-12 paneltool-content">
							<input type="hidden" value="{$leo_panel.font_url}" id="font_url">

							{foreach from=$leo_panel.font_configs item=$fontc key=$fontk}
							<div class="col-sm-12">
								{$fontc}
							</div>

							<div class="col-sm-12">
							<select class="panel-font" name="{$fontk}" id="{$fontk}">
								{foreach from=$leo_panel.fonts item=$fonts}
								<optgroup label="{$fonts.label}">
									{foreach from=$fonts.options item=$font}
									<option value="{$font.id}"{if isset($font.file)} data-file="{$font.file}"{/if}{if isset($font.font_family)} data-family="{$font.font_family}" data-style="{$font.font_style}" data-weight="{$font.font_weight}" {/if}{if isset($font.type)} data-type="{$font.type}"{/if}{if $profile_params.$fontk==$font.id} selected="selected" data-load="1"{/if}>{$font.name}</option>
									{/foreach}
								</optgroup>	
								{/foreach}
							</select>
							</div>
							{/foreach}
						</div>
					</div>
					<!-- Color Config -->
					<div class="group-input clearfix" id="lecolor" data-url="{$urls.base_url}">
						<label class="col-sm-12 control-label paneltool-tab"><span class="fa fa-edit"></span>{l s='Color Config' mod='leoelements'}</label>
						<div class="col-sm-12 paneltool-content">
							{foreach from=$leo_panel.color_configs item=group}
							<div class="group-input clearfix" data-url="{$urls.base_url}">
								<label class="col-sm-12 control-label paneltool-subtab"><span class="fa fa-credit-card"></span>{$group.label}</label>
								<div class="col-sm-12 paneltool-subcontent">
								{foreach from=$group.config item=$color key=$colork}
								
									<div class="col-sm-12 title-subcontent">
										{$color}
									</div>
									<div class="col-sm-12 input-group">
										<input id="{$colork}" value="{$profile_params[$colork]|escape:'html':'UTF-8'}" size="10" name="{$colork}" type="text" class="leocolor"><a href="#" class="clear-bg label label-success">{l s='Clear' mod='leoelements'}</a>
									</div>
								
								{/foreach}
								</div>
							</div>
							{/foreach}
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<!-- Live Theme Editor -->
	<div class="paneltool editortool">
		<div class="panelbutton">
			<i class="fa fa-adjust"></i>
		</div>
		<div class="panelcontent editortool">
			<div class="panelinner">
				<h4>{l s='Builder Page Demo' mod='leoelements'}</h4>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Category' mod='leoelements'}{if $leo_panel.category_link == '#'} {l s='(Must add categories, products)' mod='leoelements'}{/if}</label>
					<div class="col-sm-12">
						{foreach $leo_panel.category as $header}
						<a class="product-detail-demo" href="{$leo_panel.category_link}?layout={$header['clist_key']}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}
					</div>
				</div>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Product List' mod='leoelements'}{if $leo_panel.category_link == '#'} {l s='(Must add categories, products)' mod='leoelements'}{/if}</label>
					<div class="col-sm-12">
						{foreach $leo_panel.plist as $header}
						<a class="product-detail-demo" href="{$leo_panel.category_link}?plist_key={$header['plist_key']}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}

					</div>
				</div>
				<div class="group-input row layout">
					<label class="col-sm-12 control-label"><span class="fa fa-desktop"></span>{l s='Product Detail' mod='leoelements'}{if $leo_panel.product_link == '#'} {l s='(Must add products)' mod='leoelements'}{/if}</label>
					<div class="col-sm-12">
						{foreach $leo_panel.pdetail as $header}
						<a class="product-detail-demo" href="{$leo_panel.product_link}?layout={$header['plist_key']}">
							<span>{$header['name']}</span>
						</a>
						{/foreach}
					</div>
				</div>
			</div>
		</div>
		
	</div>
</div>
{/if}