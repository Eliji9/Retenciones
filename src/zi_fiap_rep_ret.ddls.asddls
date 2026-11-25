@EndUserText.label: 'Reporte de Retenciones'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FIAP_RETENCIONES_DPC'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Search.searchable: true
@UI.headerInfo: { typeName: 'Retención',
                  typeNamePlural: 'Retenciones',
                  title:       { type: #STANDARD, value: 'AccountingDocument' },
                  description: { type: #STANDARD, value: 'SupplierName' } }
define root custom entity ZI_FIAP_REP_RET
{
      @UI.facet: [ { id: 'Documento', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE,
                     label: 'Documento',  targetQualifier: 'Documento', position: 10 },
                   { id: 'Proveedor', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE,
                     label: 'Proveedor',  targetQualifier: 'Proveedor', position: 20 },
                   { id: 'Retencion', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE,
                     label: 'Retención',  targetQualifier: 'Retencion', position: 30 } ]
      @UI.selectionField: [{ position: 2 }]
      @EndUserText.label: 'Sociedad'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode'} }]
      @UI.lineItem: [{ position: 2 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 20 }]
  key CompanyCode         : abap.char(4);
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [{ position: 4 }]
      @EndUserText.label: 'Documento Contable'
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 40 }]
  key AccountingDocument   : abap.char(10);
      @EndUserText.label: 'Ejercicio'
      @Consumption.filter: { mandatory: true, defaultValue: '2026' }
      @UI.selectionField: [{ position: 15 }]
      @UI.lineItem: [{ position: 3 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 60 }]
  key FiscalYear           : abap.numc(4);
      @EndUserText.label: 'Posición'
      @UI.lineItem: [{ position: 4.5 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 50 }]
  key AccountingDocumentItem : abap.numc(3);
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Tipo Retención'
      @UI.lineItem: [{ position: 8 }]
      //@Consumption.filter: { mandatory: true }
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_ExtendedWhldgTaxCodeText', element: 'WithholdingTaxType'} }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 10 }]
  key WithholdingTaxType   : abap.char(2);
      @EndUserText.label: 'País' 
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CountrySrchHelp', element: 'Country'} }]
      @UI.selectionField: [{ position: 1  }]
      @UI.lineItem: [{ position: 1 }]
      @Consumption.filter: { mandatory: true }
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 10 }]
  Country                  : abap.char(3);
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier'} }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Acreedor'
      @UI.lineItem: [{ position: 7, importance: #HIGH }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 10 }]
  Supplier                 : lifnr;
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Indicador Retención'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ExtendedWhldgTaxCodeText', element: 'WithholdingTaxCode'} }]
      @UI.lineItem: [{ position: 9 }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 30 }]
  WithholdingTaxCode         : abap.char(2);
      @UI.selectionField: [{ position: 60 }]
      @EndUserText.label: 'Fe. Contabilización'
      @UI.lineItem: [{ position: 6 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 80 }]
  PostingDate               : abap.dats(8);
      @UI.selectionField: [{ position: 70 }]
      @EndUserText.label: 'Clase de documento'
      @UI.lineItem: [{ position: 5 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 70 }]
  DocumentType               : abap.char(2);

  @EndUserText.label: 'Nombre Sociedad'
  @UI.lineItem: [{ position: 10 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 30 }]
  CompanyCodeName            : abap.char(25);
  @EndUserText.label: 'Descripción Retención'
  @UI.lineItem: [{ position: 20 }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 20 }]
  WithholdingTaxTypeText      : abap.char(40);
  @EndUserText.label: 'Nombre Proveedor'
  @Search.defaultSearchElement: true
  @UI.lineItem: [{ position: 30 }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 20 }]
  SupplierName                : abap.char(40);
  @EndUserText.label: 'Núm. Identif. Tributaria'
  @UI.lineItem: [{ position: 40 }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 30 }]
  TaxNumber1                  : abap.char(16);
  @EndUserText.label: 'Núm. Identif. Tributaria 2'
  @UI.lineItem: [{ position: 41 }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 40 }]
  TaxNumber2                  : abap.char(11);
  @EndUserText.label: 'Núm Teléfono'
  @UI.lineItem: [{ position: 42 }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 50 }]
  PhoneNumber                 : abap.char(30);
  @EndUserText.label: 'Correo Electrónico'
  @UI.lineItem: [{ position: 43 }]
      @UI.fieldGroup: [{ qualifier: 'Proveedor', position: 60 }]
  EmailAddress                : abap.char(241);
  @EndUserText.label: 'Núm. Doc. Factura'
  @UI.lineItem: [{ position: 50 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 110 }]
  SupplierInvoice              : abap.char(20);
  @EndUserText.label: 'Referencia Fiscal'
  @UI.lineItem: [{ position: 51 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 130 }]
  TaxReference                 : abap.char(36);
  @EndUserText.label: 'CAI'
  @UI.lineItem: [{ position: 52 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 120 }]
  Cai                          : abap.char(40);
  @EndUserText.label: 'Fecha Documento'
  @UI.lineItem: [{ position: 60 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 90 }]
  DocumentDate                  : abap.dats(8);
  @EndUserText.label: 'Fecha Compensación'
  @UI.lineItem: [{ position: 61 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 100 }]
  ClearingDate                   : abap.dats(8);
  @EndUserText.label: 'Total Factura'
  @UI.lineItem: [{ position: 70 }]
  @Semantics.amount.currencyCode: 'Currency'
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 40 }]
  InvoiceGrossAmount             : abap.curr(23,2);
  @EndUserText.label: 'Monto Sujeto Ret. ML'
  @UI.lineItem: [{ position: 71 }]
  @Semantics.amount.currencyCode: 'Currency'
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 50 }]
  WithholdingBaseAmount           : abap.curr(23,2);
  @EndUserText.label: 'Monto Ret. ML'
  @UI.lineItem: [{ position: 72 }]
  @Semantics.amount.currencyCode: 'Currency'
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 60 }]
  WithholdingTaxAmount            : abap.curr(23,2);
  @EndUserText.label: 'Monto Sujeto Ret. ME'
  @UI.lineItem: [{ position: 73 }]
  @Semantics.amount.currencyCode: 'Currency' 
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 70 }]
  WithholdingBaseAmountFC           : abap.curr(23,2);
  @EndUserText.label: 'Monto Ret. ME'
  @UI.lineItem: [{ position: 74 }]
  @Semantics.amount.currencyCode: 'Currency'
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 80 }]
  WithholdingTaxAmountFC             : abap.curr(23,2);
  @EndUserText.label: 'Moneda'
  @Semantics.currencyCode: true
  Currency                          : abap.cuky(5);
  @EndUserText.label: 'Serie'
  @UI.lineItem: [{ position: 80 }]
      @UI.fieldGroup: [{ qualifier: 'Documento', position: 140 }]
  DocumentSeries                     : abap.char(16);
  @EndUserText.label: 'Concepto'
  @UI.lineItem: [{ position: 81 }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 90 }]
  Concept                             : abap.char(1);
  @EndUserText.label: 'Grupo Artículo'
  @UI.lineItem: [{ position: 82 }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 100 }]
  ProductGroup                        : abap.char(9);
  @EndUserText.label: 'Denom. Gr-Artículo'
  @UI.lineItem: [{ position: 83 }]
      @UI.fieldGroup: [{ qualifier: 'Retencion', position: 110 }]
  ProductGroupText                     : abap.char(40);
}
