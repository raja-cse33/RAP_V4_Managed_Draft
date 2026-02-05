@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for PO Itm'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@AbapCatalog.extensibility.extensible: true
define view entity ZRAJ_C_PO_ITM
  //  provider contract transactional_query
  as projection on ZRAJ_I_PO_ITEM
{
  key EbelpUuid          as PoitmUUID,
      POUuid             as poUUID,
      Ebelp              as Poitem,
      Matnr              as matnr,
      Maktx              as Maktx,
      @Semantics.quantity.unitOfMeasure: 'meins'
      Qty                as Qty,
      Meins              as meins,
      @Semantics.amount.currencyCode: 'Currencycode'
      ItmPrice           as itemprice,
      CurrencyCode       as Currencycode,
      LocalLastChangedAt as Lastchangedat,
      /* Associations */
      _Pohdr : redirected to parent ZRAJ_C_PO_HDR
}
