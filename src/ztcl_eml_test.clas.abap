CLASS ztcl_eml_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
      INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ztcl_eml_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_create TYPE TABLE FOR CREATE Z_I_Travel_M_MO\\travel.
    lt_create = VALUE #(     ( travel_id      = '00000001'
                               agency_id      = '070011'
                               customer_id    = '000025'
                               begin_date     = cl_abap_context_info=>get_system_date( )
                               end_date       = cl_abap_context_info=>get_system_date( ) + 30
                               booking_fee    = 20
                               total_price    = 155
                               currency_code  = 'EUR'
                               description    = 'Test'
                               overall_status = 'O' ) ). " Open


    MODIFY entity Z_I_TRAVEL_M_MO CREATE FIELDS (  travel_id
                               agency_id
                               customer_id
                               begin_date
                               end_date
                               booking_fee
                               total_price
                               currency_code
                               description
                               overall_status ) WITH lt_create
          MAPPED   DATA(mapped)
          FAILED   DATA(failed)
          REPORTED DATA(reported).

*    result = VALUE #( FOR create IN  lt_create INDEX INTO idx
*                             ( %cid_ref = keys[ idx ]-%cid_ref
*                               %key     = keys[ idx ]-travel_id
*                               %param   = CORRESPONDING #(  create ) ) ) .
    COMMIT ENTITIES.
    out->write( 'test EML' ).
  ENDMETHOD.

ENDCLASS.

