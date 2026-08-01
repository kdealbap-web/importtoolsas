<?php
/**
 * Import Tools Latam S.A.S — Cotización por WhatsApp
 *
 * La tienda funciona en modo catálogo: no hay precios, ni carrito, ni pagos.
 * El visitante arma una lista de productos, deja sus datos y salta a WhatsApp
 * con el mensaje ya escrito. Los datos quedan guardados para el CRM.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class Itcotizacion extends Module
{
    public function __construct()
    {
        $this->name = 'itcotizacion';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Import Tools Latam S.A.S';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('Cotización por WhatsApp', [], 'Modules.Itcotizacion.Admin');
        $this->description = $this->trans(
            'Lista de cotización sin precios, captura de datos del prospecto y envío a WhatsApp.',
            [],
            'Modules.Itcotizacion.Admin'
        );
    }

    public function install()
    {
        return parent::install()
            && $this->crearTabla()
            && $this->registerHook('displayHeader')
            && $this->registerHook('actionFrontControllerSetMedia')
            && Configuration::updateValue('ITCOT_WHATSAPP', '573145934962')
            && Configuration::updateValue('ITCOT_ACTIVO', 1);
    }

    public function uninstall()
    {
        // La tabla NO se borra: son datos de prospectos del cliente.
        return parent::uninstall()
            && Configuration::deleteByName('ITCOT_WHATSAPP')
            && Configuration::deleteByName('ITCOT_ACTIVO');
    }

    private function crearTabla()
    {
        $sql = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'it_cotizacion` (
            `id_cotizacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `referencia`    VARCHAR(20)  NOT NULL,
            `nombre`        VARCHAR(180) NOT NULL,
            `tipo_doc`      VARCHAR(10)  NOT NULL,
            `documento`     VARCHAR(40)  NOT NULL,
            `telefono`      VARCHAR(40)  NOT NULL,
            `email`         VARCHAR(180) NOT NULL,
            `empresa`       VARCHAR(180) NULL,
            `ciudad`        VARCHAR(120) NULL,
            `nota`          TEXT         NULL,
            `productos`     LONGTEXT     NOT NULL,
            `num_lineas`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
            `id_lang`       INT UNSIGNED NOT NULL DEFAULT 1,
            `ip`            VARCHAR(45)  NULL,
            `user_agent`    VARCHAR(255) NULL,
            `estado`        VARCHAR(20)  NOT NULL DEFAULT "nuevo",
            `date_add`      DATETIME     NOT NULL,
            PRIMARY KEY (`id_cotizacion`),
            UNIQUE KEY `referencia` (`referencia`),
            KEY `date_add` (`date_add`),
            KEY `estado` (`estado`),
            KEY `documento` (`documento`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        return Db::getInstance()->execute($sql);
    }

    /**
     * Número de WhatsApp en formato internacional sin signos, apto para wa.me.
     * Si no está configurado, se deduce del teléfono de la tienda.
     */
    public static function getWhatsapp()
    {
        $n = trim((string) Configuration::get('ITCOT_WHATSAPP'));
        if ($n === '') {
            $n = (string) Configuration::get('PS_SHOP_PHONE');
        }
        $n = preg_replace('/\D+/', '', $n);
        // Un número colombiano de 10 dígitos va con indicativo 57.
        if (strlen($n) === 10) {
            $n = '57' . $n;
        }

        return $n;
    }

    public function hookActionFrontControllerSetMedia()
    {
        $this->context->controller->registerStylesheet(
            'itcotizacion-css',
            'modules/' . $this->name . '/views/css/cotizacion.css',
            ['media' => 'all', 'priority' => 200]
        );
        $this->context->controller->registerJavascript(
            'itcotizacion-js',
            'modules/' . $this->name . '/views/js/cotizacion.js',
            ['position' => 'bottom', 'priority' => 200]
        );
        $this->context->controller->registerJavascript(
            'itcotizacion-pagina',
            'modules/' . $this->name . '/views/js/pagina.js',
            ['position' => 'bottom', 'priority' => 201]
        );

        Media::addJsDef([
            'itcot' => [
                'url'      => $this->context->link->getModuleLink($this->name, 'cotizacion'),
                'urlEnvio' => $this->context->link->getModuleLink($this->name, 'enviar'),
                'textos'   => [
                    'agregado'  => $this->trans('Agregado a tu cotización', [], 'Modules.Itcotizacion.Shop'),
                    'yaEsta'    => $this->trans('Ya está en tu cotización', [], 'Modules.Itcotizacion.Shop'),
                    'vacia'     => $this->trans('Tu cotización está vacía', [], 'Modules.Itcotizacion.Shop'),
                    'quitar'    => $this->trans('Quitar', [], 'Modules.Itcotizacion.Shop'),
                    'verLista'  => $this->trans('Ver mi cotización', [], 'Modules.Itcotizacion.Shop'),
                ],
            ],
        ]);
    }

    public function hookDisplayHeader()
    {
        return '';
    }

    /** Pantalla de configuración: número de WhatsApp y últimas solicitudes. */
    public function getContent()
    {
        $salida = '';

        if (Tools::isSubmit('submitItcot')) {
            $num = preg_replace('/\D+/', '', (string) Tools::getValue('ITCOT_WHATSAPP'));
            if (strlen($num) < 10) {
                $salida .= $this->displayError($this->trans(
                    'El número de WhatsApp debe tener al menos 10 dígitos.', [], 'Modules.Itcotizacion.Admin'
                ));
            } else {
                Configuration::updateValue('ITCOT_WHATSAPP', $num);
                $salida .= $this->displayConfirmation($this->trans(
                    'Número guardado.', [], 'Modules.Itcotizacion.Admin'
                ));
            }
        }

        $filas = Db::getInstance()->executeS(
            'SELECT referencia, nombre, tipo_doc, documento, telefono, email, num_lineas, estado, date_add
               FROM `' . _DB_PREFIX_ . 'it_cotizacion` ORDER BY date_add DESC LIMIT 50'
        );
        $total = (int) Db::getInstance()->getValue(
            'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . 'it_cotizacion`'
        );

        $this->context->smarty->assign([
            'itcot_numero' => Configuration::get('ITCOT_WHATSAPP'),
            'itcot_filas'  => $filas,
            'itcot_total'  => $total,
            'itcot_export' => $this->context->link->getAdminLink('AdminModules', true)
                . '&configure=' . $this->name . '&itcot_export=1',
        ]);

        if (Tools::getValue('itcot_export')) {
            $this->exportarCsv();
        }

        return $salida . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    /** Descarga de los prospectos en CSV, para llevarlos al CRM. */
    private function exportarCsv()
    {
        $filas = Db::getInstance()->executeS(
            'SELECT referencia, date_add, nombre, tipo_doc, documento, telefono, email,
                    empresa, ciudad, num_lineas, estado, productos
               FROM `' . _DB_PREFIX_ . 'it_cotizacion` ORDER BY date_add DESC'
        );

        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename=cotizaciones-' . date('Ymd-Hi') . '.csv');
        $out = fopen('php://output', 'w');
        fwrite($out, "\xEF\xBB\xBF"); // BOM, para que Excel respete los acentos
        fputcsv($out, ['Referencia', 'Fecha', 'Nombre', 'Tipo doc', 'Documento', 'Teléfono',
                       'Correo', 'Empresa', 'Ciudad', 'Líneas', 'Estado', 'Productos'], ';');
        foreach ($filas as $f) {
            $prods = json_decode($f['productos'], true) ?: [];
            $texto = [];
            foreach ($prods as $p) {
                $texto[] = ($p['ref'] ?? '') . ' x' . ($p['qty'] ?? 1) . ' ' . ($p['nombre'] ?? '');
            }
            fputcsv($out, [
                $f['referencia'], $f['date_add'], $f['nombre'], $f['tipo_doc'], $f['documento'],
                $f['telefono'], $f['email'], $f['empresa'], $f['ciudad'], $f['num_lineas'],
                $f['estado'], implode(' | ', $texto),
            ], ';');
        }
        fclose($out);
        exit;
    }
}
