CLASS lhc_ZRAJ_I_PO_ITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zraj_i_po_item RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zraj_i_po_item RESULT result.
    METHODS setpoitmno FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zraj_i_po_item~setpoitmno.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zraj_i_po_item~calculatetotalprice.

ENDCLASS.

CLASS lhc_ZRAJ_I_PO_ITEM IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD setPoItmno.

    DATA: lt_poitm_upd TYPE TABLE FOR UPDATE zraj_i_po_hdr\\zraj_i_po_item.

    DATA: lv_max_ebelp TYPE n LENGTH 4.

    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
      ENTITY zraj_i_po_item BY \_Pohdr
      FIELDS ( EbelnUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).
      READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
        ENTITY zraj_i_po_hdr BY \_Poitem
        FIELDS ( POUuid Ebelp EbelpUuid )
             WITH VALUE #( ( %tky = ls_header-%tky ) )
             RESULT DATA(lt_poitem).

      lv_max_ebelp = '0000'.
      LOOP AT lt_poitem INTO DATA(ls_poitem).
        IF ls_poitem-Ebelp > lv_max_ebelp.
          lv_max_ebelp = ls_poitem-Ebelp.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_poitem INTO DATA(ls_poitm) WHERE Ebelp IS INITIAL.
        lv_max_ebelp += 0001.
        APPEND VALUE #( %tky      = ls_poitm-%tky
                        ebelp     = lv_max_ebelp )
               TO lt_poitm_upd.

      ENDLOOP.

      MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
             ENTITY zraj_i_po_item
             UPDATE FIELDS ( Ebelp )
             WITH lt_poitm_upd.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.
    DATA: lv_total_price TYPE /dmo/total_price.
    " 1. Get the Parent UUIDs (Header UUIDs) for the items being modified
    READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
      ENTITY zraj_i_po_item
        FIELDS ( POUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA(lt_header_links) = lt_items.
    SORT lt_header_links BY POUuid.
    DELETE ADJACENT DUPLICATES FROM lt_header_links COMPARING POUuid.

    LOOP AT lt_header_links ASSIGNING FIELD-SYMBOL(<lfs_header>).
      CLEAR lv_total_price.

      " 2. Read ALL items for this specific header to get the full sum
      READ ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
        ENTITY zraj_i_po_hdr BY \_Poitem
          FIELDS ( ItmPrice Qty )
          WITH VALUE #( ( EbelnUuid = <lfs_header>-POUuid
                          %is_draft = <lfs_header>-%is_draft
                          ) ) " Note: Use correct mapping if POUuid differs
        RESULT DATA(lt_all_items).

      " 3. Sum up: Total = Sum( ItemPrice * Quantity )
      LOOP AT lt_all_items ASSIGNING FIELD-SYMBOL(<lfs_all_item>).
        lv_total_price += ( <lfs_all_item>-ItmPrice * <lfs_all_item>-Qty ).
      ENDLOOP.

*      " 4. Update the Header TotalPrice
      MODIFY ENTITIES OF zraj_i_po_hdr IN LOCAL MODE
        ENTITY zraj_i_po_hdr
          UPDATE FIELDS ( TotalPrice )
          WITH VALUE #( ( %data-EbelnUuid       = <lfs_header>-%data-POUuid
                          %is_draft  = <lfs_header>-%is_draft
                          TotalPrice = lv_total_price ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
