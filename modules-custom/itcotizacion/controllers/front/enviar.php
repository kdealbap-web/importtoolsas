<?php
/**
 * Recibe la solicitud de cotización, la valida, la guarda para el CRM y
 * devuelve la URL de WhatsApp con el mensaje ya armado.
 *
 * Responde siempre JSON. El salto a WhatsApp lo hace el navegador.
 */

class ItcotizacionEnviarModuleFrontController extends ModuleFrontController
{
    public $ajax = true;
    public $ssl = true;

    /** Tipos de documento aceptados en Colombia. */
    private const TIPOS_DOC = ['CC', 'NIT', 'CE', 'PP', 'TI'];

    public function postProcess()
    {
        // Sin sesión de por medio: es un formulario público de contacto.
        $datos = [
            'nombre'    => trim((string) Tools::getValue('nombre')),
            'tipo_doc'  => strtoupper(trim((string) Tools::getValue('tipo_doc'))),
            'documento' => trim((string) Tools::getValue('documento')),
            'telefono'  => trim((string) Tools::getValue('telefono')),
            'email'     => trim((string) Tools::getValue('email')),
            'empresa'   => trim((string) Tools::getValue('empresa')),
            'ciudad'    => trim((string) Tools::getValue('ciudad')),
            'nota'      => trim((string) Tools::getValue('nota')),
        ];

        $productos = json_decode((string) Tools::getValue('productos'), true);
        $errores = $this->validar($datos, $productos);

        if ($errores) {
            $this->responder(['ok' => false, 'errores' => $errores]);
        }

        $productos = $this->limpiarProductos($productos);
        if (!$productos) {
            $this->responder(['ok' => false, 'errores' => [
                'productos' => $this->trans('Tu cotización está vacía.', [], 'Modules.Itcotizacion.Shop'),
            ]]);
        }

        $referencia = $this->generarReferencia();

        Db::getInstance()->insert('it_cotizacion', [
            'referencia' => pSQL($referencia),
            'nombre'     => pSQL($datos['nombre']),
            'tipo_doc'   => pSQL($datos['tipo_doc']),
            'documento'  => pSQL($datos['documento']),
            'telefono'   => pSQL($datos['telefono']),
            'email'      => pSQL($datos['email']),
            'empresa'    => pSQL($datos['empresa']),
            'ciudad'     => pSQL($datos['ciudad']),
            'nota'       => pSQL($datos['nota']),
            'productos'  => pSQL(json_encode($productos, JSON_UNESCAPED_UNICODE)),
            'num_lineas' => count($productos),
            'id_lang'    => (int) $this->context->language->id,
            'ip'         => pSQL(substr((string) Tools::getRemoteAddr(), 0, 45)),
            'user_agent' => pSQL(substr((string) $_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255)),
            'estado'     => 'nuevo',
            'date_add'   => date('Y-m-d H:i:s'),
        ]);

        $this->responder([
            'ok'         => true,
            'referencia' => $referencia,
            'whatsapp'   => $this->urlWhatsapp($referencia, $datos, $productos),
        ]);
    }

    private function validar(array $d, $productos)
    {
        $e = [];

        if (mb_strlen($d['nombre']) < 3 || !Validate::isName(str_replace(['.', ',' ], '', $d['nombre']))) {
            $e['nombre'] = $this->trans('Escribe tu nombre completo.', [], 'Modules.Itcotizacion.Shop');
        }
        if (!in_array($d['tipo_doc'], self::TIPOS_DOC, true)) {
            $e['tipo_doc'] = $this->trans('Elige el tipo de documento.', [], 'Modules.Itcotizacion.Shop');
        }
        // Documento: dígitos, y en el NIT se admite el guion del dígito de verificación.
        if (!preg_match('/^[0-9]{5,15}(-[0-9kK])?$/', $d['documento'])) {
            $e['documento'] = $this->trans('El número de documento no parece válido.', [], 'Modules.Itcotizacion.Shop');
        }
        $tel = preg_replace('/\D+/', '', $d['telefono']);
        if (strlen($tel) < 7 || strlen($tel) > 15) {
            $e['telefono'] = $this->trans('El teléfono debe tener entre 7 y 15 dígitos.', [], 'Modules.Itcotizacion.Shop');
        }
        if (!Validate::isEmail($d['email'])) {
            $e['email'] = $this->trans('El correo no parece válido.', [], 'Modules.Itcotizacion.Shop');
        }
        if (!is_array($productos) || !$productos) {
            $e['productos'] = $this->trans('Tu cotización está vacía.', [], 'Modules.Itcotizacion.Shop');
        }

        return $e;
    }

    /**
     * Nunca se confía en lo que manda el navegador: los nombres y referencias
     * se releen de la base a partir del id, y la cantidad se acota.
     */
    private function limpiarProductos($productos)
    {
        $limpio = [];
        $vistos = [];

        foreach ((array) $productos as $p) {
            $id = (int) ($p['id'] ?? 0);
            if ($id <= 0 || isset($vistos[$id]) || count($limpio) >= 60) {
                continue;
            }
            $producto = new Product($id, false, (int) $this->context->language->id);
            if (!Validate::isLoadedObject($producto) || !$producto->active) {
                continue;
            }
            $qty = (int) ($p['qty'] ?? 1);
            $qty = max(1, min(9999, $qty));

            $vistos[$id] = true;
            $limpio[] = [
                'id'     => $id,
                'ref'    => (string) $producto->reference,
                'nombre' => (string) $producto->name,
                'qty'    => $qty,
            ];
        }

        return $limpio;
    }

    private function generarReferencia()
    {
        do {
            $ref = 'COT-' . date('ymd') . '-' . strtoupper(Tools::passwdGen(4, 'NO_NUMERIC'));
            $existe = (int) Db::getInstance()->getValue(
                'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . 'it_cotizacion` WHERE referencia = "' . pSQL($ref) . '"'
            );
        } while ($existe);

        return $ref;
    }

    private function urlWhatsapp($referencia, array $d, array $productos)
    {
        $l = [];
        $l[] = 'Hola, quiero cotizar estos productos:';
        $l[] = '';
        foreach ($productos as $i => $p) {
            $l[] = sprintf('%d. %s — ref. %s — cantidad: %d', $i + 1, $p['nombre'], $p['ref'], $p['qty']);
        }
        $l[] = '';
        $l[] = '── Mis datos ──';
        $l[] = 'Nombre: ' . $d['nombre'];
        $l[] = $d['tipo_doc'] . ': ' . $d['documento'];
        $l[] = 'Teléfono: ' . $d['telefono'];
        $l[] = 'Correo: ' . $d['email'];
        if ($d['empresa'] !== '') {
            $l[] = 'Empresa: ' . $d['empresa'];
        }
        if ($d['ciudad'] !== '') {
            $l[] = 'Ciudad: ' . $d['ciudad'];
        }
        if ($d['nota'] !== '') {
            $l[] = '';
            $l[] = 'Nota: ' . $d['nota'];
        }
        $l[] = '';
        $l[] = 'Referencia: ' . $referencia;

        return 'https://wa.me/' . Itcotizacion::getWhatsapp()
             . '?text=' . rawurlencode(implode("\n", $l));
    }

    private function responder(array $datos)
    {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($datos, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
