<div class="panel">
  <h3><i class="icon icon-whatsapp"></i> Cotización por WhatsApp</h3>
  <form method="post" class="form-horizontal">
    <div class="form-group">
      <label class="control-label col-lg-3">Número de WhatsApp</label>
      <div class="col-lg-4">
        <input type="text" name="ITCOT_WHATSAPP" value="{$itcot_numero|escape:'html':'UTF-8'}" class="form-control">
        <p class="help-block">Formato internacional sin signos. Ej.: <code>573145934962</code></p>
      </div>
    </div>
    <div class="panel-footer">
      <button type="submit" name="submitItcot" class="btn btn-default pull-right">
        <i class="process-icon-save"></i> Guardar
      </button>
    </div>
  </form>
</div>

<div class="panel">
  <h3>Solicitudes recibidas <span class="badge">{$itcot_total}</span></h3>
  <p><a href="{$itcot_export|escape:'html':'UTF-8'}" class="btn btn-default"><i class="icon-download"></i> Descargar todo en CSV</a></p>
  {if $itcot_filas}
  <table class="table">
    <thead><tr><th>Referencia</th><th>Fecha</th><th>Nombre</th><th>Documento</th><th>Teléfono</th><th>Correo</th><th>Líneas</th><th>Estado</th></tr></thead>
    <tbody>
      {foreach from=$itcot_filas item=f}
      <tr>
        <td><strong>{$f.referencia|escape:'html':'UTF-8'}</strong></td>
        <td>{$f.date_add|escape:'html':'UTF-8'}</td>
        <td>{$f.nombre|escape:'html':'UTF-8'}</td>
        <td>{$f.tipo_doc|escape:'html':'UTF-8'} {$f.documento|escape:'html':'UTF-8'}</td>
        <td>{$f.telefono|escape:'html':'UTF-8'}</td>
        <td>{$f.email|escape:'html':'UTF-8'}</td>
        <td>{$f.num_lineas|intval}</td>
        <td>{$f.estado|escape:'html':'UTF-8'}</td>
      </tr>
      {/foreach}
    </tbody>
  </table>
  {else}<p class="alert alert-info">Todavía no hay solicitudes.</p>{/if}
</div>
