CLASS lhc_zraj_i_po_hdr DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS zzvalidate_enddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zraj_i_po_hdr~zzvalidate_enddate.

ENDCLASS.

CLASS lhc_zraj_i_po_hdr IMPLEMENTATION.

  METHOD zzvalidate_enddate.

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
    ENTITY zraj_i_po_hdr
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_enddate).

    LOOP AT lt_enddate ASSIGNING FIELD-SYMBOL(<lfs_end>).

      APPEND VALUE #(  %tky               = <lfs_end>-%tky
                         %state_area        = 'VALIDATE_DATES' ) TO reported-zraj_i_po_hdr.

      " Calculate the maximum allowed date
      DATA(lv_max_date) = <lfs_end>-BeginDate + 10.

      IF <lfs_end>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <lfs_end>-%tky ) TO failed-zraj_i_po_hdr.

        APPEND VALUE #( %tky               = <lfs_end>-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = new_message_with_text(
                                             severity = if_abap_behv_message=>severity-error
                                              text     = 'Enddate is not initial' )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.

        " 2. Check if EndDate is within BeginDate + 10 days
      ELSEIF <lfs_end>-EndDate LT <lfs_end>-BeginDate OR ( <lfs_end>-EndDate GT lv_max_date ).

        APPEND VALUE #( %tky = <lfs_end>-%tky ) TO failed-zraj_i_po_hdr.

        APPEND VALUE #( %tky               = <lfs_end>-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'End Date must be within 10 days of the Begin Date' )
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-zraj_i_po_hdr.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
