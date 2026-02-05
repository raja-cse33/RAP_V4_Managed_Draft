@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Value Help for PO Type'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity Z_I_POType_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZPOTYPE' )
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @UI.hidden: true
  key language,

      @EndUserText.label: 'PO Type'
      @Search.defaultSearchElement: true
      value_low as POType,

      @EndUserText.label: 'Description'
      @Semantics.text: true
      @Search.defaultSearchElement: true
      text      as Description
}
where
  language = $session.system_language
