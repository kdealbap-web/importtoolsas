{* 
* @Module Name: Leo Parts Filter
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  2007-2022 Leotheme
*}

<div class="wrapper">
	<div class="container-filter">
		<div class="filter-type">
			<div class="filter-head-title">{$header_text|escape:'htmlall':'UTF-8'}</div>
			<ul>
				<li><a class="{if $s==''}active{/if} filter-type-1">{l s='Make and Module' mod='leopartsfilter'}</a></li>
				<li><a class="filter-type-2 {if $s!=''}active{/if}">{l s='Free search' mod='leopartsfilter'}</a></li>
			</ul>
		</div> 
		
		<div id="filter-type-1" class="filter-type-1-content {if $s==''}active{/if}">
			<div class="block leo-partsfilter" >
			  <h4 class="title_block">{if isset($header_text)}{$header_text|escape:'htmlall':'UTF-8'}{/if}</h4>
			  <div class="block_content">
			    <table id="mmy">
			      <tr class="field-search">
			        <td class="value-search">
				        <div class="row-fluid">
						<select id="carMake" class="selectpicker carMake" data-show-subtext="true" data-live-search="true">
			            	<option value="">{if isset($make_ddl_default_text)}{$make_ddl_default_text|escape:'htmlall':'UTF-8'}{/if}</option>
							{foreach from=$make_data item=foo}
								<option value="{$foo.mid}" {if $id_make == $foo.mid}selected="selected"{/if}>{$foo.name|escape:'htmlall':'UTF-8'}</option>
							{/foreach}
			          	</select>
				        </div>
					</td>
					{if $allow_search_form > 1}
					<td class="value-search">
						<select id="carModel" class="selectpicker carModel" {if $model_data == ''}disabled="disabled"{/if} data-option="{$model_ddl_default_text|escape:'htmlall':'UTF-8'}">
				            <option value="">{if isset($model_ddl_default_text)}{$model_ddl_default_text|escape:'htmlall':'UTF-8'}{/if}</option>
				            {if $model_data}
				            	{foreach from=$model_data item=foo}
									<option value="{$foo.id_leopartsfilter_model}" {if $id_model == $foo.id_leopartsfilter_model}selected="selected"{/if}>{$foo.name|escape:'htmlall':'UTF-8'}</option>
								{/foreach}
				            {/if}
				        </select>
				        <img style="display: none" class="carModel-loading" src="{$base_url_module}views/img/loader.gif" alt="">
			        </td>
			        {/if}
			
					{if $allow_search_form > 2}
			        <td class="value-search">
			        	<select id="carYear" class="selectpicker carYear" {if $year_data == ''}disabled="disabled"{/if} data-option="{$year_ddl_default_text|escape:'htmlall':'UTF-8'}">
			            	<option value="">{if isset($year_ddl_default_text)}{$year_ddl_default_text|escape:'htmlall':'UTF-8'}{/if}</option>
			            	{if $year_data}
				            	{foreach from=$year_data item=foo}
									<option value="{$foo.id_leopartsfilter_year}" {if $id_year == $foo.id_leopartsfilter_year}selected="selected"{/if}>{$foo.name|escape:'htmlall':'UTF-8'}</option>
								{/foreach}
				            {/if}

			        	</select>
			        	<img style="display: none" class="carYear-loading" src="{$base_url_module}views/img/loader.gif" alt="">
			        </td>
					{/if}
					{if $allow_search_form > 3}
			        <td class="value-search">
			        	<select id="carDevice" class="selectpicker carDevice" {if $device_data == ''}disabled="disabled"{/if} data-option="{$device_ddl_default_text|escape:'htmlall':'UTF-8'}">
			            	<option value="">{if isset($device_ddl_default_text)}{$device_ddl_default_text|escape:'htmlall':'UTF-8'}{/if}</option>
			            	{if $device_data}
				            	{foreach from=$device_data item=foo}
									<option value="{$foo.id_leopartsfilter_device}" {if $id_device == $foo.id_leopartsfilter_device}selected="selected"{/if}>{$foo.name|escape:'htmlall':'UTF-8'}</option>
								{/foreach}
				            {/if}
			        	</select>
			        	<img style="display: none" class="carDevice-loading" src="{$base_url_module}views/img/loader.gif" alt="">
			        </td>
			        {/if}

			        {if $allow_search_form > 4}
			        <td class="value-search">
			        	<select id="carlevel5" class="selectpicker carlevel5" {if $level5_data == ''}disabled="disabled"{/if} data-option="{$level5_ddl_default_text|escape:'htmlall':'UTF-8'}">
			            	<option value="">{if isset($level5_ddl_default_text)}{$level5_ddl_default_text|escape:'htmlall':'UTF-8'}{/if}</option>
			            	{if $level5_data}
				            	{foreach from=$level5_data item=foo}
									<option value="{$foo.id_leopartsfilter_level5}" {if $id_level5 == $foo.id_leopartsfilter_level5}selected="selected"{/if}>{$foo.name|escape:'htmlall':'UTF-8'}</option>
								{/foreach}
				            {/if}
			        	</select>
			        	<img style="display: none" class="carlevel5-loading" src="{$base_url_module}views/img/loader.gif" alt="">
			        </td>
			        {/if}
		
			        {if $allow_search_button}
			        <td class="leo-partsfilter-submit leo-partsfilter-submit-1">
			        	<span class="label label-primary" style="cursor:pointer;">
			        		<span class="button-text">
			        			{if isset($filter_button_text)}{$filter_button_text|escape:'htmlall':'UTF-8'}{/if}
			        		</span>
			        		<span class="leo-process"></span>
			        	</span>
			        </td>
			        {/if}

			      </tr>
			    </table>
			  </div>
			</div>
		</div>
		<div id="filter-type-2" class="leo-partsfilter filter-type-2-content {if $s!=''}active{/if}">
			<div class="block_content">
				<input class="w-100 py-10 px-50 free-search-input" type="search" placeholder="{l s='Search for parts by OEM number, make, model, etc (min 3 characters)' mod='leopartsfilter'}" value="{if $s!=''}{$s}{/if}">

				{if $allow_search_button}
			        <div class="leo-partsfilter-submit leo-partsfilter-submit-2">
			        	<span class="label label-primary" style="cursor:pointer;">
			        		<span class="button-text">
			        			{if isset($filter_button_text)}{$filter_button_text|escape:'htmlall':'UTF-8'}{/if}
			        		</span>
			        		<span class="leo-process"></span>
			        	</span>
			        </div>
		        {/if}

			</div>
		</div>
		<div class="leo-filter-display">
			<div class="leo-filter-content">

			</div>
		</div>
		<input type="hidden" class="base_url_module" value="{$base_url_module}">
		<input type="hidden" class="filter_url" value='{$filter_url}'>
		<input type="hidden" class="noneResultsText" value="{l s='No results matched' mod='leopartsfilter'}">
		<input type="hidden" class="noneSelectedText" value="{l s='Please select all content filter' mod='leopartsfilter'}">
		<input type="hidden" class="allow_search_form" value="{$allow_search_form}"> 
		<input type="hidden" class="allow_search_button" value="{$allow_search_button}">
		<input type="hidden" class="ajaxsearch" value="{$ajaxsearch}">
		<input type="hidden" class="filter_ajax_url" value="{$ajax_url}">		
 	</div>
</div>

  
