CLASS lsc_Z_I_Travel_M_MO DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_Z_I_Travel_M_MO IMPLEMENTATION.
  METHOD save_modified.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS copy_travel          FOR MODIFY IMPORTING keys FOR ACTION travel~createTravelByTemplate RESULT result.
    METHODS set_status_completed FOR MODIFY IMPORTING keys FOR ACTION travel~acceptTravel RESULT result.
    METHODS set_status_cancelled FOR MODIFY IMPORTING keys FOR ACTION travel~rejectTravel RESULT result.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

**********************************************************************
*
* Create travel instances with initial values
*
**********************************************************************
  METHOD copy_travel.

    SELECT MAX( travel_id ) FROM ztravel_m_mo INTO @DATA(lv_travel_id).

    READ ENTITY z_i_travel_m_mo
         FIELDS ( travel_id
                  agency_id
                  customer_id
                  booking_fee
                  total_price
                  currency_code )
           WITH VALUE #( FOR travel IN keys (  %key = travel-%key ) )
         RESULT    DATA(lt_read_result)
         FAILED    failed
         REPORTED  reported.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA lt_create TYPE TABLE FOR CREATE Z_I_Travel_M_MO\\travel.

    lt_create = VALUE #( FOR row IN  lt_read_result INDEX INTO idx
                             ( travel_id      = lv_travel_id + idx
                               agency_id      = row-agency_id
                               customer_id    = row-customer_id
                               begin_date     = lv_today
                               end_date       = lv_today + 30
                               booking_fee    = row-booking_fee
                               total_price    = row-total_price
                               currency_code  = row-currency_code
                               description    = 'Enter your comments here'
                               overall_status = 'O' ) ). " Open

    MODIFY ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
        ENTITY travel
           CREATE FIELDS (    travel_id
                              agency_id
                              customer_id
                              begin_date
                              end_date
                              booking_fee
                              total_price
                              currency_code
                              description
                              overall_status )
             WITH lt_create
         MAPPED   mapped
         FAILED   failed
         REPORTED reported.

    result = VALUE #( FOR create IN  lt_create INDEX INTO idx
                             ( %cid_ref = keys[ idx ]-%cid_ref
                               %key     = keys[ idx ]-travel_id
                               %param   = CORRESPONDING #(  create ) ) ) .
  ENDMETHOD.

********************************************************************************
*
* Implements travel action (in our case: for setting travel overall_status to completed)
*
********************************************************************************
  METHOD set_status_completed.

    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
           ENTITY travel
              UPDATE FIELDS ( overall_status )
                WITH VALUE #( FOR key IN keys ( travel_id      = key-travel_id
                                                overall_status = 'A' ) ) " Accepted
           FAILED   failed
           REPORTED reported.

    " read changed data for result
    MODIFY ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
           ENTITY travel
              UPDATE FIELDS ( overall_status )
                 WITH VALUE #( FOR key IN keys ( travel_id      = key-travel_id
                                                 overall_status = 'A' ) ) " Accepted
           FAILED   failed
           REPORTED reported.

    " Read changed data for action result
    READ ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
         ENTITY travel
           FIELDS ( agency_id
                    customer_id
                    begin_date
                    end_date
                    booking_fee
                    total_price
                    currency_code
                    overall_status
                    description
                    created_by
                    created_at
                    last_changed_at
                    last_changed_by )
             WITH VALUE #( FOR key IN keys ( travel_id = key-travel_id ) )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR travel IN lt_travel ( travel_id = travel-travel_id
                                                %param    = travel
                                              ) ).
  ENDMETHOD.

********************************************************************************
*
* Implements travel action(s) (in our case: for setting travel overall_status to cancelled)
*
********************************************************************************
  METHOD set_status_cancelled.

    MODIFY ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
           ENTITY travel
              UPDATE FROM VALUE #( FOR key IN keys ( travel_id = key-travel_id
                                                     overall_status = 'X'   " Canceled
                                                     %control-overall_status = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    " read changed data for result
    READ ENTITIES OF z_i_travel_m_mo IN LOCAL MODE
     ENTITY travel
       FIELDS ( agency_id
                customer_id
                begin_date
                end_date
                booking_fee
                total_price
                currency_code
                overall_status
                description
                created_by
                created_at
                last_changed_at
                last_changed_by )
         WITH VALUE #( FOR key IN keys ( travel_id = key-travel_id ) )
     RESULT DATA(lt_travel).

    result = VALUE #( FOR travel IN lt_travel ( travel_id = travel-travel_id
                                                %param    = travel
                                              ) ).
  ENDMETHOD.

ENDCLASS.
