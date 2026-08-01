{extends file='page.tpl'}

{block name='page_title'}{l s='Mi cotización' d='Modules.Itcotizacion.Shop'}{/block}

{block name='page_content_container'}
<section class="itcot-pagina">

  <header class="itcot-cabecera">
    <p class="itcot-eyebrow">{l s='Atención mayorista' d='Modules.Itcotizacion.Shop'}</p>
    <h1 class="itcot-titulo">{l s='Solicita tu cotización' d='Modules.Itcotizacion.Shop'}</h1>
    <p class="itcot-bajada">
      {l s='Revisa los productos, déjanos tus datos y continúa por WhatsApp con un asesor comercial.' d='Modules.Itcotizacion.Shop'}
    </p>
  </header>

  <div class="itcot-grid">

    {* ------------------------------------------------ lista de productos *}
    <div class="itcot-col-lista">
      <div class="itcot-panel">
        <div class="itcot-panel__cab">
          <h2>{l s='Productos' d='Modules.Itcotizacion.Shop'}</h2>
          <span class="itcot-chip"><span class="itcot-contador">0</span> {l s='ítems' d='Modules.Itcotizacion.Shop'}</span>
        </div>

        <div id="itcot-lista" class="itcot-lista" data-vacio="{l s='Aún no has agregado productos.' d='Modules.Itcotizacion.Shop'}"></div>

        <div class="itcot-panel__pie">
          <a href="{$itcot_catalogo}" class="itcot-link">
            <i class="material-icons">&#xE5C4;</i> {l s='Seguir agregando productos' d='Modules.Itcotizacion.Shop'}
          </a>
          <button type="button" id="itcot-vaciar" class="itcot-link itcot-link--sutil">
            {l s='Vaciar la lista' d='Modules.Itcotizacion.Shop'}
          </button>
        </div>
      </div>
    </div>

    {* --------------------------------------------------------- formulario *}
    <div class="itcot-col-form">
      <form id="itcot-form" class="itcot-panel itcot-form" action="{$itcot_url_envio}" method="post" novalidate>

        <div class="itcot-panel__cab">
          <h2>{l s='Tus datos' d='Modules.Itcotizacion.Shop'}</h2>
        </div>

        <div class="itcot-campos">

          <div class="itcot-campo itcot-campo--ancho">
            <label for="itcot-nombre">{l s='Nombre completo' d='Modules.Itcotizacion.Shop'} <span>*</span></label>
            <input type="text" id="itcot-nombre" name="nombre" autocomplete="name" required>
            <small class="itcot-error" data-para="nombre"></small>
          </div>

          <div class="itcot-campo">
            <label for="itcot-tipo-doc">{l s='Tipo de documento' d='Modules.Itcotizacion.Shop'} <span>*</span></label>
            <select id="itcot-tipo-doc" name="tipo_doc" required>
              <option value="CC">{l s='Cédula de ciudadanía' d='Modules.Itcotizacion.Shop'}</option>
              <option value="NIT">{l s='NIT' d='Modules.Itcotizacion.Shop'}</option>
              <option value="CE">{l s='Cédula de extranjería' d='Modules.Itcotizacion.Shop'}</option>
              <option value="PP">{l s='Pasaporte' d='Modules.Itcotizacion.Shop'}</option>
              <option value="TI">{l s='Tarjeta de identidad' d='Modules.Itcotizacion.Shop'}</option>
            </select>
            <small class="itcot-error" data-para="tipo_doc"></small>
          </div>

          <div class="itcot-campo">
            <label for="itcot-documento">{l s='Número de documento' d='Modules.Itcotizacion.Shop'} <span>*</span></label>
            <input type="text" id="itcot-documento" name="documento" inputmode="numeric" required>
            <small class="itcot-error" data-para="documento"></small>
          </div>

          <div class="itcot-campo">
            <label for="itcot-telefono">{l s='Teléfono / WhatsApp' d='Modules.Itcotizacion.Shop'} <span>*</span></label>
            <input type="tel" id="itcot-telefono" name="telefono" inputmode="tel" autocomplete="tel" required>
            <small class="itcot-error" data-para="telefono"></small>
          </div>

          <div class="itcot-campo">
            <label for="itcot-email">{l s='Correo electrónico' d='Modules.Itcotizacion.Shop'} <span>*</span></label>
            <input type="email" id="itcot-email" name="email" autocomplete="email" required>
            <small class="itcot-error" data-para="email"></small>
          </div>

          <div class="itcot-campo">
            <label for="itcot-empresa">{l s='Empresa' d='Modules.Itcotizacion.Shop'} <small>{l s='(opcional)' d='Modules.Itcotizacion.Shop'}</small></label>
            <input type="text" id="itcot-empresa" name="empresa" autocomplete="organization">
          </div>

          <div class="itcot-campo">
            <label for="itcot-ciudad">{l s='Ciudad' d='Modules.Itcotizacion.Shop'} <small>{l s='(opcional)' d='Modules.Itcotizacion.Shop'}</small></label>
            <input type="text" id="itcot-ciudad" name="ciudad" autocomplete="address-level2">
          </div>

          <div class="itcot-campo itcot-campo--ancho">
            <label for="itcot-nota">{l s='¿Algo que debamos saber?' d='Modules.Itcotizacion.Shop'} <small>{l s='(opcional)' d='Modules.Itcotizacion.Shop'}</small></label>
            <textarea id="itcot-nota" name="nota" rows="3"></textarea>
          </div>

        </div>

        <div class="itcot-enviar">
          <button type="submit" id="itcot-btn" class="itcot-btn itcot-btn--wa">
            <span class="itcot-btn__icono" aria-hidden="true">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M17.5 14.4c-.3-.2-1.7-.9-2-1-.3-.1-.5-.1-.7.2-.2.3-.7 1-.9 1.2-.2.2-.3.2-.6.1-.3-.2-1.2-.5-2.3-1.4-.9-.8-1.4-1.7-1.6-2-.2-.3 0-.5.1-.6l.5-.5c.1-.2.2-.3.3-.5 0-.2 0-.4 0-.5 0-.2-.7-1.6-.9-2.2-.2-.6-.5-.5-.7-.5h-.6c-.2 0-.5.1-.8.4-.3.3-1 1-1 2.5s1.1 2.9 1.2 3.1c.2.2 2.1 3.2 5.1 4.5.7.3 1.3.5 1.7.6.7.2 1.4.2 1.9.1.6-.1 1.7-.7 2-1.4.2-.7.2-1.3.2-1.4-.1-.1-.3-.2-.6-.3z"/>
                <path d="M12 2A10 10 0 0 0 3.5 17.2L2 22l4.9-1.5A10 10 0 1 0 12 2zm0 18.2c-1.6 0-3.1-.4-4.4-1.2l-.3-.2-3 .9.9-2.9-.2-.3A8.2 8.2 0 1 1 12 20.2z"/>
              </svg>
            </span>
            <span class="itcot-btn__texto">{l s='Enviar cotización por WhatsApp' d='Modules.Itcotizacion.Shop'}</span>
          </button>

          <p class="itcot-legal">
            {l s='Al enviar, tus datos quedan registrados para que un asesor pueda atenderte. No se comparten con terceros.' d='Modules.Itcotizacion.Shop'}
          </p>
          <p class="itcot-error itcot-error--global" data-para="global"></p>
        </div>

      </form>

      <aside class="itcot-ayuda">
        <p>{l s='¿Prefieres hablar directo?' d='Modules.Itcotizacion.Shop'}</p>
        <a href="tel:{$itcot_tel|replace:' ':''}">{$itcot_tel}</a>
        <a href="mailto:{$itcot_email}">{$itcot_email}</a>
      </aside>
    </div>

  </div>
</section>
{/block}
