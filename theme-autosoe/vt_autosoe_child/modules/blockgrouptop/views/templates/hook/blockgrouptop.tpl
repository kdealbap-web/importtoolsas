{**
 * Panel de la cuenta — Import Tools Latam S.A.S · 08/08/2026
 *
 * Reescrito desde el original de Leo (que se conserva en el tema PADRE) por tres
 * motivos, todos comprobados en el espejo:
 *
 *   1. «Pedidos» apuntaba a `{url entity='cart' params=['action'=>show]}`, o sea
 *      al CARRITO. Esta tienda va en modo catálogo: no hay carrito. Era un enlace
 *      a una página vacía. Ahora lleva al historial de pedidos, que sí existe.
 *   2. «Mi cuenta» salía TAMBIÉN sin haber entrado, junto a «Entrar» y
 *      «Registrarse», y no llevaba a ninguna cuenta: rebotaba al login.
 *   3. Ninguna entrada tenía icono ni jerarquía: seis enlaces de texto seguidos
 *      en un panel de 180 px.
 *
 * Los iconos son `.it-ico` (Font Awesome Light, que el tema ya empaqueta y que se
 * declaró en custom.css §7). Cero ficheros nuevos.
 *
 * ⚠️ La fuente del tema es Font Awesome **5**, no 6. Comprobado midiendo el ancho
 * del glifo renderizado: `fa-location-dot`, `fa-code-compare` y
 * `fa-arrow-right-from-bracket` —nombres de FA6— dan 0 px, o sea que la clase se
 * aplica pero NO SE PINTA NADA, y desde el CSS no hay forma de notarlo. Los
 * equivalentes que sí existen son `fa-map-marker-alt`, `fa-balance-scale` y
 * `fa-sign-out-alt`.
 *
 * El orden dice lo que esta tienda es: la COTIZACIÓN va primero entre las listas,
 * porque es el camino de venta real; los favoritos, después. Y sin sesión se
 * avisa de que para cotizar no hace falta cuenta, que es cierto y evita que
 * alguien se registre sin necesitarlo.
 *}

<div id="leo_block_top" class="leo_block_top popup-over dropdown js-dropdown float-xs-left float-md-right">
	<a href="javascript:void(0)" data-toggle="dropdown" class="popup-title" title="{l s='Mi cuenta' d='Shop.Theme.Global'}"
	   aria-haspopup="true" aria-expanded="false">
		<i class="fa-light fa-user"></i>
		<span class="hidden">{l s='Mi cuenta' d='Shop.Theme.Global'}</span>
		<i class="material-icons hidden">&#xE5C5;</i>
	</a>
	<div class="popup-content dropdown-menu itcuenta">

		{if $enable_userinfo == 1}

			{if $logged}
				{* Cabecera de identidad. La inicial en el cuadro rojo es la pieza que
				   identifica el panel de un vistazo; el nombre y el correo confirman
				   con QUÉ cuenta se está trabajando, que es la duda real cuando
				   alguien tiene varias. *}
				<div class="itcuenta__cab">
					<span class="itcuenta__inicial" aria-hidden="true">{$customerName|truncate:1:'':true|upper}</span>
					<span class="itcuenta__quien">
						<strong class="itcuenta__nombre">{$customerName}</strong>
						{if isset($customer.email) && $customer.email}
							<span class="itcuenta__correo">{$customer.email}</span>
						{/if}
					</span>
				</div>

				<ul class="user-info itcuenta__lista">
					<li>
						<a class="account itcuenta__item" href="{$my_account_url}" rel="nofollow"
						   title="{l s='View my customer account' d='Shop.Theme.Customeraccount'}">
							<i class="it-ico fa-user" aria-hidden="true"></i>
							<span>{l s='Mi cuenta' d='Shop.Theme.Global'}</span>
						</a>
					</li>
					<li>
						<a class="itcuenta__item" href="{$urls.pages.history}" rel="nofollow"
						   title="{l s='Mis pedidos' d='Shop.Theme.Customeraccount'}">
							<i class="it-ico fa-receipt" aria-hidden="true"></i>
							<span>{l s='Mis pedidos' d='Shop.Theme.Customeraccount'}</span>
						</a>
					</li>
					<li>
						<a class="itcuenta__item" href="{$urls.pages.addresses}" rel="nofollow"
						   title="{l s='Mis direcciones' d='Shop.Theme.Customeraccount'}">
							<i class="it-ico fa-map-marker-alt" aria-hidden="true"></i>
							<span>{l s='Mis direcciones' d='Shop.Theme.Customeraccount'}</span>
						</a>
					</li>

					<li class="itcuenta__sep" role="separator"></li>

					{* La cotización va antes que los favoritos: es el camino de venta. *}
					<li>
						<a class="itcuenta__item" href="{url entity='module' name='itcotizacion' controller='cotizacion'}"
						   rel="nofollow" title="{l s='Mi cotización' d='Shop.Theme.Global'}">
							<i class="it-ico fa-clipboard-list" aria-hidden="true"></i>
							<span>{l s='Mi cotización' d='Shop.Theme.Global'}</span>
							<span class="itcuenta__num itcot-contador"></span>
						</a>
					</li>
					{if Configuration::get('LEOFEATURE_ENABLE_PRODUCTWISHLIST')}
						<li>
							<a class="ap-btn-wishlist itcuenta__item"
							   href="{url entity='module' name='leofeature' controller='mywishlist'}"
							   rel="nofollow" title="{l s='Wishlist' d='Shop.Theme.Global'}">
								<i class="it-ico fa-heart" aria-hidden="true"></i>
								<span>{l s='Mis favoritos' d='Shop.Theme.Global'}</span>
								<span class="itcuenta__num ap-total-wishlist ap-total"></span>
							</a>
						</li>
					{/if}
					{if Configuration::get('LEOFEATURE_ENABLE_PRODUCTCOMPARE')}
						<li>
							<a class="ap-btn-compare itcuenta__item"
							   href="{url entity='module' name='leofeature' controller='productscompare'}"
							   rel="nofollow" title="{l s='Compare' d='Shop.Theme.Global'}">
								<i class="it-ico fa-balance-scale" aria-hidden="true"></i>
								<span>{l s='Comparar' d='Shop.Theme.Global'}</span>
								<span class="itcuenta__num ap-total-compare ap-total"></span>
							</a>
						</li>
					{/if}

					<li class="itcuenta__sep" role="separator"></li>

					<li>
						<a class="logout itcuenta__item itcuenta__item--salir" href="{$logout_url}" rel="nofollow">
							<i class="it-ico fa-sign-out-alt" aria-hidden="true"></i>
							<span>{l s='Cerrar sesión' d='Shop.Theme.Actions'}</span>
						</a>
					</li>
				</ul>

			{else}

				<div class="itcuenta__cab itcuenta__cab--anonimo">
					<span class="itcuenta__inicial" aria-hidden="true"><i class="it-ico fa-user"></i></span>
					<span class="itcuenta__quien">
						<strong class="itcuenta__nombre">{l s='Entra a tu cuenta' d='Shop.Theme.Customeraccount'}</strong>
						<span class="itcuenta__correo">{l s='Guarda tus favoritos y consulta tus pedidos.' d='Shop.Theme.Customeraccount'}</span>
					</span>
				</div>

				<div class="itcuenta__acciones">
					{if Configuration::get('LEOQUICKLOGIN_ENABLE')}
						<a class="signin leo-quicklogin itcuenta__btn itcuenta__btn--rojo"
						   data-enable-sociallogin="enable" data-type="popup" data-layout="login"
						   href="javascript:void(0)" rel="nofollow"
						   title="{l s='Log in to your customer account' d='Shop.Theme.Customeraccount'}">
							{l s='Entrar' d='Shop.Theme.Actions'}
						</a>
						<a class="register leo-quicklogin itcuenta__btn itcuenta__btn--linea"
						   data-enable-sociallogin="enable" data-type="popup" data-layout="register"
						   href="javascript:void(0)" rel="nofollow"
						   title="{l s='Log in to your customer account' d='Shop.Theme.Customeraccount'}">
							{l s='Crear cuenta' d='Shop.Theme.Actions'}
						</a>
					{else}
						<a class="signin itcuenta__btn itcuenta__btn--rojo"
						   href="{$urls.pages.authentication}?back={$urls.current_url|urlencode}" rel="nofollow">
							{l s='Entrar' d='Shop.Theme.Actions'}
						</a>
						<a class="itcuenta__btn itcuenta__btn--linea" href="{$urls.pages.register}" rel="nofollow">
							{l s='Crear cuenta' d='Shop.Theme.Actions'}
						</a>
					{/if}
				</div>

				<ul class="user-info itcuenta__lista">
					<li class="itcuenta__sep" role="separator"></li>
					<li>
						<a class="itcuenta__item" href="{url entity='module' name='itcotizacion' controller='cotizacion'}" rel="nofollow">
							<i class="it-ico fa-clipboard-list" aria-hidden="true"></i>
							<span>{l s='Mi cotización' d='Shop.Theme.Global'}</span>
							<span class="itcuenta__num itcot-contador"></span>
						</a>
					</li>
				</ul>

				{* Se dice claro, porque es verdad y ahorra un registro que nadie necesita. *}
				<p class="itcuenta__nota">{l s='Para cotizar no hace falta cuenta.' d='Shop.Theme.Customeraccount'}</p>

			{/if}

		{/if}

	</div>
</div>
