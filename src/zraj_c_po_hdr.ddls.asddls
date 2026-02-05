@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for PO HDR'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@AbapCatalog.extensibility: {
  extensible: true,
//  elementSuffix: 'ZRX',
//  dataSources: ['ZRAJ_I_PO_HDR'], -- This must match the alias in the SELECT
  quota: {
    maximumFields: 100,
    maximumBytes: 1000
  }
}
define root view entity ZRAJ_C_PO_HDR
  provider contract transactional_query
  as projection on ZRAJ_I_PO_HDR
{
  key EbelnUuid     as POUUID,
      Ebeln         as PONumber,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_POType_VH', element: 'POType' } }]
      //      @ObjectModel.text.element: ['POTypeText']
      Potype        as POType,
      BeginDate     as BeginDate,
      EndDate       as Enddate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice    as TotalAmount,
      CurrencyCode  as CurrencyCode,
      Description   as PODesc,
      OverallStatus as FinalStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Poitem : redirected to composition child ZRAJ_C_PO_ITM
}
