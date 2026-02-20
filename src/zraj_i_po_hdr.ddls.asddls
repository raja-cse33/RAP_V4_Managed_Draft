@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Po Header Details'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AbapCatalog.extensibility: {
  extensible: true,
  elementSuffix: 'ZRX',
//  allowNewDatasources: false,
//  allowNewCompositions: true,
//  dataSources: [ '_Poitem' ],
  quota: { maximumBytes: 1000, maximumFields: 100 }
}
define root view entity ZRAJ_I_PO_HDR
  as select from zraj_po_head
  composition [1..*] of ZRAJ_I_PO_ITEM                as _Poitem
  association [0..*] to /DMO/I_Overall_Status_VH_Text as _StatusText on $projection.OverallStatus = _StatusText.OverallStatus


{
  key ebeln_uuid            as EbelnUuid,
      ebeln                 as Ebeln,
      potype                as Potype,
      begin_date            as BeginDate,
      end_date              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      @Consumption: {
        valueHelpDefinition: [ {
          entity.element: 'Currency',
          entity.name: 'I_CurrencyStdVH',
          useForValidation: true
        } ]
      }
      currency_code         as CurrencyCode,
      description           as Description,
      overall_status        as OverallStatus,
      // Logic for Criticality (Integer 0-3)
      case overall_status
        when 'X' then 1 -- Red (Aborted/Rejected)
        when 'O' then 2 -- Orange (Open/Pending)
        when 'A' then 3 -- Green (Accepted/Approved)
        else 0          -- Neutral (Grey)
      end                   as OverallStatusCriticality,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      //    _association_name // Make association public
      _Poitem,
      _StatusText
}
