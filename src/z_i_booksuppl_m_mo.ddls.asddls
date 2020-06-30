@AbapCatalog.sqlViewName: 'ZIBOOKSUPPLMMO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Booking Supplement View - CDS data model'

define view Z_I_BookSuppl_M_MO
  as select from zbooksuppl_m_mo as BookingSupplement

  association        to parent Z_I_Booking_M_MO as _Booking        on  $projection.travel_id  = _Booking.travel_id
                                                                   and $projection.booking_id = _Booking.booking_id

  association [1..1] to Z_I_Travel_M_MO         as _Travel         on  $projection.travel_id = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement       as _Product        on  $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SupplementText on  $projection.supplement_id = _SupplementText.SupplementID
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      @Semantics.currencyCode: true
      currency_code,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at, -- used as etag field

      /* Associations */
      _Travel,
      _Booking,
      _Product,
      _SupplementText
}
