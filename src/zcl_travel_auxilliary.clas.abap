CLASS ZCL_TRAVEL_AUXILLIARY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.


*   Type definition for import parameters --------------------------
    TYPES tt_travel_create      TYPE TABLE FOR CREATE   Z_I_TRAVEL_U.
    TYPES tt_travel_update      TYPE TABLE FOR UPDATE   Z_I_TRAVEL_U.
    TYPES tt_travel_delete      TYPE TABLE FOR DELETE   Z_I_TRAVEL_U.

    TYPES tt_travel_failed      TYPE TABLE FOR FAILED   Z_I_TRAVEL_U.
    TYPES tt_travel_mapped      TYPE TABLE FOR MAPPED   Z_I_TRAVEL_U.
    TYPES tt_travel_reported    TYPE TABLE FOR REPORTED Z_I_TRAVEL_U.

     TYPES tt_booking_create     TYPE TABLE FOR CREATE    Z_i_booking_u.
    TYPES tt_booking_update     TYPE TABLE FOR UPDATE    z_i_booking_u.
    TYPES tt_booking_delete     TYPE TABLE FOR DELETE    z_i_booking_u.

    TYPES tt_booking_failed     TYPE TABLE FOR FAILED    z_i_booking_u.
    TYPES tt_booking_mapped     TYPE TABLE FOR MAPPED    z_i_booking_u.
    TYPES tt_booking_reported   TYPE TABLE FOR REPORTED  z_i_booking_u.



    CLASS-METHODS map_travel_cds_to_db
                            IMPORTING   is_i_travel_u       TYPE Z_I_TRAVEL_U
                            RETURNING VALUE(rs_travel)      TYPE /dmo/if_flight_legacy=>ts_travel_in.
    CLASS-METHODS map_travel_message
                            IMPORTING iv_cid                TYPE string OPTIONAL
                                      iv_travel_id          TYPE /dmo/travel_id OPTIONAL
                                      is_message            TYPE LINE OF /dmo/if_flight_legacy=>tt_message
                            RETURNING VALUE(rs_report)      TYPE LINE OF tt_travel_reported.
     CLASS-METHODS map_booking_cds_to_db
                            IMPORTING is_i_booking          TYPE z_i_booking_u
                            RETURNING VALUE(rs_booking)     TYPE /dmo/if_flight_legacy=>ts_booking_in.
                             CLASS-METHODS map_booking_message
                            IMPORTING iv_cid                TYPE string OPTIONAL
                                      iv_travel_id          TYPE /dmo/travel_id OPTIONAL
                                      iv_booking_id         TYPE /dmo/booking_id OPTIONAL
                                      is_message            TYPE LINE OF /dmo/if_flight_legacy=>tt_message
                            RETURNING VALUE(rs_report)      TYPE LINE OF tt_booking_reported.




PROTECTED SECTION.
PRIVATE SECTION.
CLASS-METHODS new_message IMPORTING id         TYPE symsgid
                                        number     TYPE symsgno
                                        severity   TYPE if_abap_behv_message=>t_severity
                                        v1         TYPE simple OPTIONAL
                                        v2         TYPE simple OPTIONAL
                                        v3         TYPE simple OPTIONAL
                                        v4         TYPE simple OPTIONAL
                              RETURNING VALUE(obj) TYPE REF TO if_abap_behv_message .

ENDCLASS.


CLASS ZCL_TRAVEL_AUXILLIARY IMPLEMENTATION.

  METHOD map_travel_cds_to_db.
    rs_travel = CORRESPONDING #( is_i_travel_u MAPPING  travel_id     = travelid
                                                        agency_id     = agencyid
                                                        customer_id   = customerid
                                                        begin_date    = begindate
                                                        end_date      = enddate
                                                        booking_fee   = bookingfee
                                                        total_price   = totalprice
                                                        currency_code = currencycode
                                                        description   = memo
                                                        status        = status ).
  ENDMETHOD.
   METHOD map_booking_cds_to_db.
    rs_booking = CORRESPONDING #( is_i_booking MAPPING  booking_id    = bookingid
                                                        booking_date  = bookingdate
                                                        customer_id   = customerid
                                                        carrier_id    = airlineid
                                                        connection_id = connectionid
                                                        flight_date   = flightdate
                                                        flight_price  = flightprice
                                                        currency_code = currencycode ).
  ENDMETHOD.

  METHOD map_travel_message.

    DATA(lo) = new_message( id       = is_message-msgid
                            number   = is_message-msgno
                            severity = if_abap_behv_message=>severity-error
                            v1       = is_message-msgv1
                            v2       = is_message-msgv2
                            v3       = is_message-msgv3
                            v4       = is_message-msgv4 ).
    rs_report-%cid     = iv_cid.
    rs_report-travelid = iv_travel_id.
    rs_report-%msg     = lo.
  ENDMETHOD.
 METHOD map_booking_message.
    DATA(lo) = new_message( id       = is_message-msgid
                            number   = is_message-msgno
                            severity = if_abap_behv_message=>severity-error
                            v1       = is_message-msgv1
                            v2       = is_message-msgv2
                            v3       = is_message-msgv3
                            v4       = is_message-msgv4 ).
    rs_report-%cid      = iv_cid.
    rs_report-travelid  = iv_travel_id.
    rs_report-bookingid = iv_booking_id.
    rs_report-%msg      = lo.
  ENDMETHOD.
  METHOD new_message.
    obj = NEW lcl_abap_behv_msg(
      textid = VALUE #(
                 msgid = id
                 msgno = number
                 attr1 = COND #( WHEN v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                 attr2 = COND #( WHEN v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                 attr3 = COND #( WHEN v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                 attr4 = COND #( WHEN v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' )
      )
      msgty = SWITCH #( severity
                WHEN if_abap_behv_message=>severity-error       THEN 'E'
                WHEN if_abap_behv_message=>severity-warning     THEN 'W'
                WHEN if_abap_behv_message=>severity-information THEN 'I'
                WHEN if_abap_behv_message=>severity-success     THEN 'S' )
      msgv1 = |{ v1 }|
      msgv2 = |{ v2 }|
      msgv3 = |{ v3 }|
      msgv4 = |{ v4 }|
    ).
    obj->m_severity = severity.
  ENDMETHOD.

ENDCLASS.



