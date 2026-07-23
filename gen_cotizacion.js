const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
  Table, TableRow, TableCell, WidthType, BorderStyle, ShadingType, PageBreak
} = require('docx');

const NAVY = "1F3864";
const ACCENT = "C00000";
const GREY = "F2F2F2";
const DARKGREY = "808080";

const money = n => "$" + n.toLocaleString('es-CO') + " COP";

function h(text, opts={}) {
  return new Paragraph({
    spacing: { before: opts.before ?? 240, after: opts.after ?? 120 },
    children: [ new TextRun({ text, bold: true, size: opts.size ?? 24, color: opts.color ?? NAVY, font: "Calibri" }) ],
    border: opts.rule ? { bottom: { color: NAVY, space: 4, style: BorderStyle.SINGLE, size: 6 } } : undefined,
  });
}
function p(text, opts={}) {
  const runs = Array.isArray(text) ? text : [{ text }];
  return new Paragraph({
    spacing: { after: opts.after ?? 120, line: 276 },
    alignment: opts.align ?? AlignmentType.JUSTIFIED,
    children: runs.map(r => new TextRun({ text: r.text, bold: r.bold, italics: r.i, color: r.color ?? "222222", size: opts.size ?? 21, font: "Calibri" })),
  });
}
function bullet(text) {
  const runs = Array.isArray(text) ? text : [{ text }];
  return new Paragraph({
    bullet: { level: 0 },
    spacing: { after: 60, line: 264 },
    children: runs.map(r => new TextRun({ text: r.text, bold: r.bold, color: "222222", size: 21, font: "Calibri" })),
  });
}
function cell(content, { w, bg, bold, color, align, size } = {}) {
  const paras = (Array.isArray(content) ? content : [content]).map(t =>
    new Paragraph({
      alignment: align ?? AlignmentType.LEFT,
      spacing: { before: 40, after: 40 },
      children: [ new TextRun({ text: t, bold, color: color ?? "222222", size: size ?? 20, font: "Calibri" }) ],
    })
  );
  return new TableCell({
    width: { size: w, type: WidthType.DXA },
    shading: bg ? { type: ShadingType.CLEAR, fill: bg, color: "auto" } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: paras,
  });
}

const doc = new Document({
  numbering: { config: [] },
  styles: { default: { document: { run: { font: "Calibri", size: 21 } } } },
  sections: [{
    properties: { page: { margin: { top: 1000, bottom: 1000, left: 1100, right: 1100 } } },
    children: [

      // ===== ENCABEZADO =====
      new Paragraph({
        alignment: AlignmentType.LEFT,
        spacing: { after: 0 },
        children: [ new TextRun({ text: "COTIZACIÓN", bold: true, size: 44, color: NAVY, font: "Calibri" }) ],
      }),
      new Paragraph({
        spacing: { after: 200 },
        border: { bottom: { color: ACCENT, space: 6, style: BorderStyle.SINGLE, size: 18 } },
        children: [ new TextRun({ text: "Diseño y desarrollo de tienda en línea (e-commerce)", size: 22, color: DARKGREY, font: "Calibri" }) ],
      }),

      // Meta: número y fecha
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [4680, 4680],
        borders: { top:{style:BorderStyle.NONE}, bottom:{style:BorderStyle.NONE}, left:{style:BorderStyle.NONE}, right:{style:BorderStyle.NONE}, insideHorizontal:{style:BorderStyle.NONE}, insideVertical:{style:BorderStyle.NONE} },
        rows: [
          new TableRow({ children: [
            cell([ "N.° de cotización:  COT-2026-001" ], { w:4680 }),
            cell([ "Fecha de emisión:  21 de julio de 2026" ], { w:4680, align: AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell([ "Validez de la oferta:  15 días calendario" ], { w:4680 }),
            cell([ "Ciudad:  ______________________" ], { w:4680, align: AlignmentType.RIGHT }),
          ]}),
        ],
      }),

      // ===== PARTES =====
      new Paragraph({ spacing:{before:200} }),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [4680, 4680],
        borders: { top:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4}, bottom:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4}, left:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4}, right:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4}, insideHorizontal:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4}, insideVertical:{style:BorderStyle.SINGLE,color:"D9D9D9",size:4} },
        rows: [
          new TableRow({ children: [
            cell("PRESENTADO POR", { w:4680, bg:NAVY, bold:true, color:"FFFFFF", size:19 }),
            cell("DIRIGIDO A", { w:4680, bg:NAVY, bold:true, color:"FFFFFF", size:19 }),
          ]}),
          new TableRow({ children: [
            cell([ "Ing. Kevin De Alba", "Persona natural", "C.C.: ____________________", "Tel.: ____________________", "kevin.dealba@supergirosatlantico.co" ], { w:4680 }),
            cell([ "Importtools Latam S.A.S", "NIT: ____________________", "Contacto: ________________", "Tel.: ____________________", "Ciudad: __________________" ], { w:4680 }),
          ]}),
        ],
      }),

      // ===== OBJETO =====
      h("1.  Objeto de la cotización", { rule:true }),
      p("La presente cotización tiene por objeto el diseño, desarrollo y puesta en línea de una tienda virtual (e-commerce / catálogo) para Importtools Latam S.A.S, orientada a la comercialización de herramientas, repuestos y productos de importación. El sitio se construirá tomando como base la plantilla comercial AutoSoe — Car & Auto Parts, seleccionada por el cliente, adaptando su diseño, colores, contenidos y estructura a la identidad de la marca."),

      // ===== PLATAFORMA =====
      h("2.  Plataforma recomendada"),
      p([ {text:"Se recomienda desarrollar el proyecto sobre "}, {text:"PrestaShop 8.x/9.x", bold:true}, {text:", plataforma de comercio electrónico de código abierto sobre la cual la plantilla AutoSoe está construida de forma nativa. Esto garantiza compatibilidad total con el diseño elegido, un panel de administración autogestionable y menores costos de licenciamiento frente a alternativas comerciales."} ]),

      // ===== ALCANCE =====
      h("3.  Alcance y funcionalidades incluidas"),
      bullet([ {text:"Instalación y configuración ", bold:true}, {text:"de PrestaShop y de la plantilla AutoSoe (licencia Regular incluida)."} ]),
      bullet([ {text:"Personalización del diseño ", bold:true}, {text:"a la identidad de marca: logo, paleta de colores, tipografías, banners e imágenes de portada."} ]),
      bullet([ {text:"CMS autogestionable ", bold:true}, {text:"con constructor visual Elementor (arrastrar y soltar) para que el cliente edite contenidos, páginas y banners."} ]),
      bullet([ {text:"Catálogo de productos ", bold:true}, {text:"con filtro de partes (Parts Filter), zoom de imagen, guía de tallas/medidas, pestañas extra, lista de deseos, comparador y búsqueda ajax."} ]),
      bullet([ {text:"Carrito de compras y estructura de checkout ", bold:true}, {text:"nativos de PrestaShop."} ]),
      bullet([ {text:"Formularios de contacto y captación de clientes (leads)", bold:true}, {text:"."} ]),
      bullet([ {text:"Diseño responsive ", bold:true}, {text:"optimizado para computador, tableta y móvil."} ]),
      bullet([ {text:"Configuración multi-idioma ", bold:true}, {text:"disponible en la plantilla (según requerimiento)."} ]),
      bullet([ {text:"Hosting y dominio ", bold:true}, {text:"por el primer año, incluidos en el valor del proyecto."} ]),
      bullet([ {text:"Carga inicial del catálogo ", bold:true}, {text:"a partir del archivo (Excel/CSV) e imágenes que entregue el cliente."} ]),

      // ===== ENTREGABLES =====
      h("4.  Entregables"),
      bullet("Tienda en línea publicada y funcional en el dominio del cliente."),
      bullet("Accesos al panel de administración (back-office)."),
      bullet("Catálogo cargado según la información entregada por el cliente."),
      bullet("Breve inducción de uso del panel para autogestión de contenidos."),

      // ===== INVERSIÓN =====
      h("5.  Inversión", { rule:true }),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [6560, 2800],
        borders: { top:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, bottom:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, left:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, right:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, insideHorizontal:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, insideVertical:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4} },
        rows: [
          new TableRow({ children: [
            cell("DESCRIPCIÓN", { w:6560, bg:NAVY, bold:true, color:"FFFFFF", size:19 }),
            cell("VALOR", { w:2800, bg:NAVY, bold:true, color:"FFFFFF", size:19, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell([ "Diseño y desarrollo de la tienda en línea sobre PrestaShop con plantilla AutoSoe, incluyendo: licencia de la plantilla, personalización de diseño, configuración de catálogo y funcionalidades, hosting y dominio del primer año, y carga inicial del catálogo entregado por el cliente." ], { w:6560 }),
            cell(money(2800000), { w:2800, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell("TOTAL DEL PROYECTO", { w:6560, bg:GREY, bold:true, size:21 }),
            cell(money(2800000), { w:2800, bg:GREY, bold:true, color:ACCENT, size:22, align:AlignmentType.RIGHT }),
          ]}),
        ],
      }),
      new Paragraph({ spacing:{before:80, after:0}, children:[ new TextRun({ text:"Valor total todo incluido. No se cobran ítems adicionales por licencia, hosting ni dominio durante el primer año.", italics:true, size:18, color:DARKGREY, font:"Calibri" }) ] }),

      // ===== FORMA DE PAGO =====
      h("6.  Forma de pago"),
      p("El valor del proyecto se cancela en tres (3) pagos, así:"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [1400, 5160, 2800],
        borders: { top:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, bottom:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, left:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, right:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, insideHorizontal:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4}, insideVertical:{style:BorderStyle.SINGLE,color:"BFBFBF",size:4} },
        rows: [
          new TableRow({ children: [
            cell("%", { w:1400, bg:NAVY, bold:true, color:"FFFFFF", size:19, align:AlignmentType.CENTER }),
            cell("MOMENTO", { w:5160, bg:NAVY, bold:true, color:"FFFFFF", size:19 }),
            cell("VALOR", { w:2800, bg:NAVY, bold:true, color:"FFFFFF", size:19, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell("40%", { w:1400, align:AlignmentType.CENTER, bold:true }),
            cell("Anticipo, al aceptar la cotización e iniciar el proyecto.", { w:5160 }),
            cell(money(1120000), { w:2800, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell("30%", { w:1400, align:AlignmentType.CENTER, bold:true }),
            cell("Contra avance, con el diseño y la estructura de la tienda aprobados.", { w:5160 }),
            cell(money(840000), { w:2800, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell("30%", { w:1400, align:AlignmentType.CENTER, bold:true }),
            cell("Contra entrega, con la tienda publicada y en funcionamiento.", { w:5160 }),
            cell(money(840000), { w:2800, align:AlignmentType.RIGHT }),
          ]}),
          new TableRow({ children: [
            cell("100%", { w:1400, bg:GREY, align:AlignmentType.CENTER, bold:true }),
            cell("TOTAL", { w:5160, bg:GREY, bold:true }),
            cell(money(2800000), { w:2800, bg:GREY, bold:true, color:ACCENT, align:AlignmentType.RIGHT, size:22 }),
          ]}),
        ],
      }),

      // ===== PLAZO =====
      h("7.  Plazo de entrega"),
      p([ {text:"El plazo estimado de entrega es de "}, {text:"veinte (20) días", bold:true}, {text:" contados a partir de la recepción del anticipo y de la información y contenidos necesarios (logo, catálogo de productos, imágenes y textos) por parte del cliente. La demora en la entrega de dicha información podrá ampliar el plazo en igual proporción."} ]),

      // ===== MANTENIMIENTO =====
      h("8.  Mantenimiento y soporte"),
      bullet([ {text:"Primeros 6 meses: ", bold:true}, {text:"soporte incluido con cuatro (4) horas mensuales gratuitas para ajustes, correcciones y acompañamiento."} ]),
      bullet([ {text:"A partir del mes 7: ", bold:true}, {text:"el soporte y mantenimiento se cobrará por hora a un valor de "}, {text:money(45000)+" por hora", bold:true}, {text:", según requerimiento del cliente."} ]),

      // ===== NO INCLUYE =====
      h("9.  Condiciones y aclaraciones"),
      bullet("Los contenidos (textos, logo, imágenes y catálogo de productos) serán suministrados por el cliente. La redacción o producción de contenidos y la fotografía de productos no están incluidas."),
      bullet("A partir del segundo año, la renovación de hosting y dominio corre por cuenta del cliente."),
      bullet("Pasarela de pago en línea, integraciones con terceros o módulos adicionales no listados en el alcance se cotizarán por separado."),
      bullet("Los precios están expresados en pesos colombianos (COP)."),

      // ===== FIRMAS =====
      new Paragraph({ spacing:{before:500} }),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [4680, 4680],
        borders: { top:{style:BorderStyle.NONE}, bottom:{style:BorderStyle.NONE}, left:{style:BorderStyle.NONE}, right:{style:BorderStyle.NONE}, insideHorizontal:{style:BorderStyle.NONE}, insideVertical:{style:BorderStyle.NONE} },
        rows: [
          new TableRow({ children: [
            new TableCell({ width:{size:4680,type:WidthType.DXA}, margins:{right:300}, children:[
              new Paragraph({ spacing:{before:200}, border:{ top:{color:"222222",space:2,style:BorderStyle.SINGLE,size:6} }, children:[ new TextRun({ text:"Ing. Kevin De Alba", bold:true, size:20, font:"Calibri" }) ] }),
              new Paragraph({ children:[ new TextRun({ text:"Proveedor del servicio", size:18, color:DARKGREY, font:"Calibri" }) ] }),
            ]}),
            new TableCell({ width:{size:4680,type:WidthType.DXA}, margins:{left:300}, children:[
              new Paragraph({ spacing:{before:200}, border:{ top:{color:"222222",space:2,style:BorderStyle.SINGLE,size:6} }, children:[ new TextRun({ text:"Importtools Latam S.A.S", bold:true, size:20, font:"Calibri" }) ] }),
              new Paragraph({ children:[ new TextRun({ text:"Aceptación del cliente", size:18, color:DARKGREY, font:"Calibri" }) ] }),
            ]}),
          ]}),
        ],
      }),

      new Paragraph({ spacing:{before:400}, alignment:AlignmentType.CENTER, children:[ new TextRun({ text:"Gracias por la oportunidad. Quedo atento a sus comentarios.", italics:true, size:19, color:DARKGREY, font:"Calibri" }) ] }),
    ],
  }],
});

const outPath = path.join(__dirname, 'Cotizacion_Importtools_Latam.docx');
Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync(outPath, buf);
  console.log('OK ->', outPath, '(' + buf.length + ' bytes)');
});
