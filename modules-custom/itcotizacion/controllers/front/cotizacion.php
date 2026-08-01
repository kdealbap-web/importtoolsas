<?php
/** La página de la cotización: lista de productos + datos de contacto. */

class ItcotizacionCotizacionModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function initContent()
    {
        parent::initContent();

        $this->context->smarty->assign([
            'itcot_url_envio' => $this->context->link->getModuleLink($this->module->name, 'enviar'),
            'itcot_tel'       => Configuration::get('PS_SHOP_PHONE'),
            'itcot_email'     => Configuration::get('PS_SHOP_EMAIL'),
            'itcot_catalogo'  => $this->context->link->getCategoryLink(
                (int) Configuration::get('PS_HOME_CATEGORY')
            ),
        ]);

        $this->setTemplate('module:itcotizacion/views/templates/front/cotizacion.tpl');
    }

    public function getBreadcrumbLinks()
    {
        $b = parent::getBreadcrumbLinks();
        $b['links'][] = [
            'title' => $this->trans('Mi cotización', [], 'Modules.Itcotizacion.Shop'),
            'url'   => $this->context->link->getModuleLink($this->module->name, 'cotizacion'),
        ];

        return $b;
    }
}
