@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Po Header Cds view'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility.extensible: true
define view entity ZRAJ_I_PO_ITEM
  as select from zraj_po_item
  association to parent ZRAJ_I_PO_HDR as _Pohdr on $projection.POUuid = _Pohdr.EbelnUuid
{
  key ebelp_uuid            as EbelpUuid,
      parent_uuid           as POUuid,
      ebelp                 as Ebelp,
      matnr                 as Matnr,
      maktx                 as Maktx,
      @Semantics.quantity.unitOfMeasure : 'Meins'
      qty                   as Qty,
      meins                 as Meins,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      itm_price             as ItmPrice,
      currency_code         as CurrencyCode,
      local_last_changed_at as LocalLastChangedAt,

      _Pohdr


}
