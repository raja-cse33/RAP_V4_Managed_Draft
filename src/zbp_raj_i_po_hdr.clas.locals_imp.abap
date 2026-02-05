CLASS lhc_ZRAJ_I_PO_HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF po_status,
        open     TYPE c LENGTH 1 VALUE 'O', "Open
        accepted TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected TYPE c LENGTH 1 VALUE 'X', "Rejected
      END OF po_status.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zraj_i_po_hdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zraj_i_po_hdr RESULT result.
    METHODS setdefaultbegindate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zraj_i_po_hdr~setdefaultbegindate.
    METHODS setponumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zraj_i_po_hdr~setponumber.
    METHODS acceptpo FOR MODIFY
      IMPORTING keys FOR ACTION zraj_i_po_hdr~acceptpo RESULT result.

    METHODS rejectpo FOR MODIFY
      IMPORTING keys FOR ACTION zraj_i_po_hdr~rejectpo RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zraj_i_po_hdr RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zraj_i_po_hdr.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zraj_i_po_hdr.
*    METHODS validate_enddate FOR VALIDATE ON SAVE
*      IMPORTING keys FOR zraj_i_po_hdr~validate_enddate.

ENDCLASS.

CLASS lhc_ZRAJ_I_PO_HDR IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setDefaultBeginDate.

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    FIELDS ( BeginDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    DELETE lt_result WHERE BeginDate IS NOT INITIAL.

    MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    UPDATE FIELDS ( BeginDate OverallStatus )
    WITH VALUE #( FOR ls_res IN lt_result (
                         %tky      = ls_res-%tky
                         BeginDate = cl_abap_context_info=>get_system_date( )
                         OverallStatus = po_status-open
                      ) ).

  ENDMETHOD.

  METHOD setPonumber.

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    FIELDS ( Ebeln )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    DELETE lt_result WHERE ebeln IS NOT INITIAL.

    IF lt_result IS INITIAL. RETURN. ENDIF.

    SELECT MAX( ebeln ) FROM zraj_po_head INTO @DATA(lv_max_po).
    lv_max_po += 1.
    CONDENSE lv_max_po.

    MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    UPDATE FIELDS ( Ebeln )
    WITH VALUE #( FOR ls_res IN lt_result (
                  %tky = ls_res-%tky
                  Ebeln = lv_max_po
    ) ) .

  ENDMETHOD.

  METHOD acceptPO.

    MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                    OverallStatus = po_status-accepted ) ).

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_res).

    result = VALUE #( FOR ls_po IN lt_res ( %tky   = ls_po-%tky
                                            %param = ls_po ) ).

  ENDMETHOD.

  METHOD rejectPO.
    MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
      ENTITY zraj_i_po_hdr
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                      OverallStatus = po_status-rejected ) ).

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_res).

    result = VALUE #( FOR ls_po IN lt_res ( %tky   = ls_po-%tky
                                            %param = ls_po ) ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_pohead).

    result = VALUE #( FOR ls_pohead IN lt_pohead
      ( %tky = ls_pohead-%tky

        " Control 'Accept PO' button
        %action-acceptPO = COND #( WHEN ls_pohead-OverallStatus = po_status-accepted " Already Accepted
                                   THEN if_abap_behv=>fc-o-disabled
                                   ELSE if_abap_behv=>fc-o-enabled )

        " Control 'Reject PO' button (e.g., disable if already rejected 'R')
        %action-rejectPO = COND #( WHEN ls_pohead-OverallStatus = po_status-rejected
                                   THEN if_abap_behv=>fc-o-disabled
                                   ELSE if_abap_behv=>fc-o-enabled )
      ) ).

  ENDMETHOD.

*  METHOD validate_enddate.
*
*    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
*    ENTITY zraj_i_po_hdr
*    FIELDS ( BeginDate EndDate )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_enddate).
*
*    LOOP AT lt_enddate ASSIGNING FIELD-SYMBOL(<lfs_end>).
*
*      APPEND VALUE #(  %tky               = <lfs_end>-%tky
*                         %state_area        = 'VALIDATE_DATES' ) TO reported-zraj_i_po_hdr.
*
*      " Calculate the maximum allowed date
*      DATA(lv_max_date) = <lfs_end>-BeginDate + 10.
*
*      IF <lfs_end>-EndDate IS INITIAL.
*        APPEND VALUE #( %tky = <lfs_end>-%tky ) TO failed-zraj_i_po_hdr.
*
*        APPEND VALUE #( %tky               = <lfs_end>-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                         %msg              = new_message_with_text(
*                                             severity = if_abap_behv_message=>severity-error
*                                              text     = 'Enddate is not initial' )
*                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.
*
*        " 2. Check if EndDate is within BeginDate + 10 days
*      ELSEIF <lfs_end>-EndDate LT <lfs_end>-BeginDate OR ( <lfs_end>-EndDate GT lv_max_date ).
*
*        APPEND VALUE #( %tky = <lfs_end>-%tky ) TO failed-zraj_i_po_hdr.
*
*        APPEND VALUE #( %tky               = <lfs_end>-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                        %msg               = new_message_with_text(
*                                               severity = if_abap_behv_message=>severity-error
*                                               text     = 'End Date must be within 10 days of the Begin Date' )
*                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.
*
*      ENDIF.
*    ENDLOOP.
*
*
*  ENDMETHOD.

  METHOD precheck_create.
    " 1. Read the data being passed in the request
    " For Precheck, we look at the entities passed in the 'entities' importing parameter
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).

      DATA(lv_begindate) = <lfs_entity>-BeginDate.
      DATA(lv_enddate)   = <lfs_entity>-EndDate.

      " If BeginDate isn't in the update packet, you might need to read it from DB
      IF <lfs_entity>-%control-BeginDate = if_abap_behv=>mk-off.
        " Optional: READ ENTITIES to get existing BeginDate from DB if needed
      ENDIF.

      DATA(lv_max_date) = lv_begindate + 10.

      " Logic: EndDate cannot be empty
      IF <lfs_entity>-%control-EndDate = if_abap_behv=>mk-on AND lv_enddate IS INITIAL.

*        APPEND VALUE #( %key = <lfs_entity>-%key
*                        %is_draft = <lfs_entity>-%is_draft ) TO failed-zraj_i_po_hdr.
*        APPEND VALUE #( %key = <lfs_entity>-%key
*                        %is_draft = <lfs_entity>-%is_draft
*                        %msg = new_message_with_text(
*                                  severity = if_abap_behv_message=>severity-error
*                                  text     = 'End Date is required' )
*                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.

        " Logic: Range Validation
      ELSEIF lv_enddate IS NOT INITIAL AND ( lv_enddate LT lv_begindate OR lv_enddate GT lv_max_date ).

*        APPEND VALUE #( %key = <lfs_entity>-%key
*                        %is_draft = <lfs_entity>-%is_draft ) TO failed-zraj_i_po_hdr.
*        APPEND VALUE #( %key = <lfs_entity>-%key
*                        %is_draft = <lfs_entity>-%is_draft
*                        %msg = new_message_with_text(
*                                  severity = if_abap_behv_message=>severity-error
*                                  text     = 'End Date must be within 10 days of the Begin Date' )
*                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fsl_ent>).

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
