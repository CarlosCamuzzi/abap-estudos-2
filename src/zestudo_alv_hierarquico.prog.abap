*&---------------------------------------------------------------------*
*& Report ZESTUDO_ALV_HIERARQUICO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zestudo_alv_hierarquico.


TABLES: ekko, ekpo.

CLASS lcl_event_handler DEFINITION DEFERRED.

DATA: lt_ekko             TYPE TABLE OF ekko,
      lt_ekpo             TYPE TABLE OF ekpo,
      lt_ekpo_sel         TYPE TABLE OF ekpo,
      lo_container_header TYPE REF TO cl_gui_custom_container,
      lo_container_detail TYPE REF TO cl_gui_custom_container,
      lo_grid_header      TYPE REF TO cl_gui_alv_grid,
      lo_grid_detail      TYPE REF TO cl_gui_alv_grid,
      lt_fieldcat_header  TYPE lvc_t_fcat,
      lt_fieldcat_detail  TYPE lvc_t_fcat,
      lo_event_handler    TYPE REF TO lcl_event_handler.


CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS: handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column es_row_no.

ENDCLASS.


CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_user_command.
    DATA: lt_rows  TYPE lvc_t_row,
          lv_row   TYPE lvc_s_row,
          lv_ebeln TYPE ekko-ebeln.

    CALL METHOD lo_grid_header->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    READ TABLE lt_rows INTO lv_row INDEX 1.
    IF sy-subrc = 0.
      READ TABLE lt_ekko INTO DATA(ls_ekko) INDEX lv_row-index.
      IF sy-subrc = 0.
        lv_ebeln = ls_ekko-ebeln.
        CLEAR lt_ekpo_sel.
        LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE ebeln = lv_ebeln.
          APPEND ls_ekpo TO lt_ekpo_sel.
        ENDLOOP.
        CALL METHOD lo_grid_detail->refresh_table_display.
*        CALL METHOD lo_grid_detail->refresh_table_display
*          EXPORTING
*            is_stable = VALUE lvc_s_stbl( row = 'X' col = 'X' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD handle_double_click.
    DATA: lv_ebeln TYPE ekko-ebeln.

    READ TABLE lt_ekko INTO DATA(ls_ekko) INDEX es_row_no-row_id.
    IF sy-subrc = 0.
      lv_ebeln = ls_ekko-ebeln.
      CLEAR lt_ekpo_sel.
      LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE ebeln = lv_ebeln.
        APPEND ls_ekpo TO lt_ekpo_sel.
      ENDLOOP.
      CALL METHOD lo_grid_detail->refresh_table_display.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln FOR ekko-ebeln.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM f_select_data.
  CALL SCREEN 0100.

**********************************************************************

FORM f_select_data.
  SELECT * FROM ekko INTO TABLE lt_ekko WHERE ebeln IN s_ebeln.
  IF sy-subrc = 0.
    SELECT * FROM ekpo INTO TABLE lt_ekpo FOR ALL ENTRIES IN lt_ekko WHERE ebeln = lt_ekko-ebeln.
  ENDIF.

  IF NOT lt_ekko IS INITIAL.
**** Carrega toda EKPO (sem considerar a primeira linha apenas)
*    LOOP AT lt_ekpo INTO DATA(ls_ekpo).
*      APPEND ls_ekpo TO lt_ekpo_sel.
*    ENDLOOP.

**** Carrega somente a EKPO relaciona à primeira linha de EKKO
    READ TABLE lt_ekko INTO DATA(ls_ekko) INDEX 1.
    IF sy-subrc = 0.
      LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE ebeln = ls_ekko-ebeln.
        APPEND ls_ekpo TO lt_ekpo_sel.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

FORM build_fieldcatalog_header.
  CLEAR lt_fieldcat_header.
  DEFINE add_field.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-coltext   = &2.
    APPEND ls_fieldcat TO lt_fieldcat_header.
  END-OF-DEFINITION.

  DATA: ls_fieldcat TYPE lvc_s_fcat.
  add_field 'EBELN' 'Pedido'.
  add_field 'BSART' 'Tipo Pedido'.
  add_field 'EKORG' 'Org. Compras'.
  add_field 'EKGRP' 'Grupo Comprador'.
  add_field 'AEDAT' 'Data Alteração'.
ENDFORM.

FORM build_fieldcatalog_detail.
  CLEAR lt_fieldcat_detail.
  DEFINE add_field.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-coltext   = &2.
    APPEND ls_fieldcat TO lt_fieldcat_detail.
  END-OF-DEFINITION.

  DATA: ls_fieldcat TYPE lvc_s_fcat.
  add_field 'EBELN' 'Pedido'.
  add_field 'EBELP' 'Item'.
  add_field 'MATNR' 'Material'.
  add_field 'MENGE' 'Quantidade'.
  add_field 'NETWR' 'Valor Líquido'.
ENDFORM.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_0100'.
  IF lo_container_header IS INITIAL.
    CREATE OBJECT lo_container_header
      EXPORTING
        container_name = 'ALV_HEADER'.

    CREATE OBJECT lo_grid_header
      EXPORTING
        i_parent = lo_container_header.

    PERFORM build_fieldcatalog_header.

    CALL METHOD lo_grid_header->set_table_for_first_display
      EXPORTING
        i_structure_name = 'EKKO'
        is_layout        = VALUE #( sel_mode = 'D' )
        is_variant       = VALUE disvariant( report = sy-repid )
        i_save           = 'A'
      CHANGING
        it_outtab        = lt_ekko
        it_fieldcatalog  = lt_fieldcat_header.


**** Define modo de seleção por linha
    " Seleciona a 1ª linha (exemplo)
*    DATA lt_rows TYPE lvc_t_row.
*    DATA ls_row  TYPE lvc_s_row.
*
*    ls_row-index = 1.          " linha inicial
*    APPEND ls_row TO lt_rows.
*
*    CALL METHOD lo_grid_header->set_selected_rows
*      EXPORTING
*        it_index_rows = lt_rows.
*
*    CALL METHOD lo_grid_header->refresh_table_display.
**** Define modo de seleção por linha


    IF lo_event_handler IS INITIAL.
      CREATE OBJECT lo_event_handler.

      SET HANDLER lo_event_handler->handle_double_click FOR lo_grid_header.
      "SET HANDLER lo_event_handler->handle_user_command FOR lo_grid_header.
    ENDIF.
  ENDIF.

  IF lo_container_detail IS INITIAL.
    CREATE OBJECT lo_container_detail
      EXPORTING
        container_name = 'ALV_DETAIL'.

    CREATE OBJECT lo_grid_detail
      EXPORTING
        i_parent = lo_container_detail.

    PERFORM build_fieldcatalog_detail.

    CALL METHOD lo_grid_detail->set_table_for_first_display
      EXPORTING
        i_structure_name = 'EKPO'
        is_variant       = VALUE disvariant( report = sy-repid )
        i_save           = 'A'
      CHANGING
        it_outtab        = lt_ekpo_sel
        it_fieldcatalog  = lt_fieldcat_detail.
  ENDIF.
ENDMODULE.

MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
