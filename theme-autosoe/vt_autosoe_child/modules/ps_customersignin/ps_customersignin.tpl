{**
 * PrestaShop
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License 3.0 (AFL-3.0)
 * that is bundled with this package in the file LICENSE.txt.
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
 * needs please refer to http://www.prestashop.com for more information.
 *
 * @author    PrestaShop SA <contact@prestashop.com>
 * @copyright PrestaShop SA
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 * International Registered Trademark & Property of PrestaShop SA
 *}
<div class="userinfo-selector links {*dropdown js-dropdown popup-over float-xs-left float-md-right*}">
  {*<a href="javascript:void(0)" data-toggle="dropdown" class="popup-title" title="{l s='Account' d='Shop.Theme.Global'}">
    <i class="fa fa-user hidden-sm-up"></i>
    <span class="hidden-xs-down">{l s='Account' d='Shop.Theme.Global'}</span>
    <i class="material-icons">&#xE5C5;</i>
 </a>*}
  <a href="{$urls.pages.my_account}"><i class="fa-light fa-user"></i> {l s='Account' d='Shop.Theme.Global'}</a>
  <ul class="{*popup-content dropdown-menu*} user-info">
    {if $logged}
      <li>
        <a
          class="account dropdown-item" 
          href="{$urls.pages.my_account}"
          title="{l s='View my customer account' d='Shop.Theme.Customeraccount'}"
          rel="nofollow"
        >
          <span>{*{l s='Hello' d='Shop.Theme.Global'}*} {$customerName}</span>
        </a>
      </li>
      <li>
        <a
          class="logout dropdown-item"
          href="{$urls.actions.logout}"
          rel="nofollow"
        >
          {l s='Sign out' d='Shop.Theme.Actions'}
        </a>
      </li>
    {else}
      {if Configuration::get('LEOQUICKLOGIN_ENABLE')}
			<li>
				<a
				class="signin leo-quicklogin"
				data-enable-sociallogin="enable"
				data-type="popup"
				data-layout="login"
				href="javascript:void(0)"
				title="{l s='Log in to your customer account' d='Shop.Theme.Customeraccount'}"
				rel="nofollow"
				>
					<span>{l s='Sign in' d='Shop.Theme.Actions'}</span>
				</a>
			</li>
			<li>
				<a
				class="register leo-quicklogin"
				data-enable-sociallogin="enable"
				data-type="popup"
				data-layout="register"
				href="javascript:void(0)"
				title="{l s='Log in to your customer account' d='Shop.Theme.Customeraccount'}"
				rel="nofollow"
				>
					<span>{l s='Register' d='Shop.Theme.Actions'}</span>
				</a>
			</li>
			{else}
			<li>
				<a class="signin"
					href="{$urls.pages.authentication}?back={$urls.current_url|urlencode}"
					title="{l s='Log in to your customer account' d='Shop.Theme.Customeraccount'}"
					rel="nofollow"
				  >
					<span>{l s='Sign in' d='Shop.Theme.Actions'}</span>
				</a>
			</li>
			<li>
				<a
				href="{$urls.pages.register}" 
				title="{l s='Register' d='Shop.Theme.Customeraccount'}"
				rel="nofollow"
				>
					<span>{l s='Register' d='Shop.Theme.Actions'}</span>
				</a>
			</li>
		{/if}
    {/if}
    {*<li>
      <a
        class="myacount dropdown-item"
        href="{$urls.pages.authentication}?back={$urls.current_url|urlencode}"
        title="{l s='My account' d='Shop.Theme.Global'}"
        rel="nofollow"
      >
        <span>{l s='My account' d='Shop.Theme.Global'}</span>
      </a>
    </li>
	{if Configuration::get('LEOFEATURE_ENABLE_PRODUCTWISHLIST')}
    <li>
      <a
        class="ap-btn-wishlist dropdown-item"
        href="{url entity='module' name='leofeature' controller='mywishlist'}"
        title="{l s='Wishlist' d='Shop.Theme.Global'}"
        rel="nofollow"
      >
        <span>{l s='Wishlist' d='Shop.Theme.Global'}</span>
		<span class="ap-total-wishlist ap-total"></span>
      </a>
    </li>
	{/if}
	{if Configuration::get('LEOFEATURE_ENABLE_PRODUCTCOMPARE')}
	<li>
      <a
        class="ap-btn-compare dropdown-item"
        href="{url entity='module' name='leofeature' controller='productscompare'}"
        title="{l s='Compare' d='Shop.Theme.Global'}"
        rel="nofollow"
      >
        <span>{l s='Compare' d='Shop.Theme.Global'}</span>
		<span class="ap-total-compare ap-total"></span>
      </a>
    </li>
	{/if}
    <li>
      <a
        class="checkout dropdown-item"
        href="{url entity='cart' params=['action' => show]}"
        title="{l s='Checkout' d='Shop.Theme.Customeraccount'}"
        rel="nofollow"
      >
        <span>{l s='Checkout' d='Shop.Theme.Actions'}</span>
      </a>
    </li>*}
  </ul>
</div>
