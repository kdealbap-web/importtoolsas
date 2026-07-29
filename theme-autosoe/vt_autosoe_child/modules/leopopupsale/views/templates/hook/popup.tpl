	{*
* PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author    PrestaShop SA <contact@prestashop.com>
*  @copyright PrestaShop SA
*  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}
<section class="product-notification leo-{if $theme == ''}basic{else}{$theme|escape:'htmlall':'UTF-8'}{/if}{if $position} position{$position|escape:'htmlall':'UTF-8'}{/if}" data-time="{$leotime|escape:'htmlall':'UTF-8'}" data-interval="{$leointerval|escape:'htmlall':'UTF-8'}">
	<a href="javascript:void(0);" title="{l s='Close' mod='leopopupsale'}" class="close-notifi">×</a>

	{if !empty($product)}		
		<div class="product-suggest"{if $box_style} style="{$box_style|escape:'htmlall':'UTF-8'}"{/if}>
			
			<div class="product-suggest-content">
				<a class="product-image" href="{$product.url|escape:'htmlall':'UTF-8'}">
					<img src="{$product.img|escape:'htmlall':'UTF-8'}" alt="{$product.name|escape:'htmlall':'UTF-8'}">
				</a>

			    <div class="column-right">
					<label class="time-ago"{if $lable_style} style="{$lable_style|escape:'htmlall':'UTF-8'}"{/if}>
						{if $showname}
							  {l s='Purchased By' mod='leopopupsale'}
							  {$customer.name|escape:'htmlall':'UTF-8'}
						  {else}
							  {l s='Have a customer purchase product' mod='leopopupsale'}
						{/if}
						  {rand(1,59)|escape:'htmlall':'UTF-8'} {l s='minutes ago' mod='leopopupsale'}
					</label>
			      	<a class="product-name" href="{$product.url|escape:'htmlall':'UTF-8'}"{if $text_style} style="{$text_style|escape:'htmlall':'UTF-8'}"{/if}>{$product.name|escape:'htmlall':'UTF-8'}</a>
			      	{if $showphone}
			      	<p class="leo-phone"{if $text_style} style="{$text_style|escape:'htmlall':'UTF-8'}"{/if}>
			      		{l s='Phone: ' mod='leopopupsale'}{$customer.phone|escape:'htmlall':'UTF-8'}			      		
			      	</p>
			      	{/if}
			      	{if $showaddress}
			      	<p class="leo-address"{if $text_style} style="{$text_style|escape:'htmlall':'UTF-8'}"{/if}>
			      		{l s='Address: ' mod='leopopupsale'}{$customer.address|escape:'htmlall':'UTF-8'}
			      	</p>
			      	{/if}
			    </div>
		    </div>
		</div>
	{/if}
</section>