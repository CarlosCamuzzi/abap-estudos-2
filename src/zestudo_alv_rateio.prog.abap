*&---------------------------------------------------------------------*
*& Report ZESTUDO_ALV_RATEIO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zestudo_alv_rateio.

CLASS lcl_event_handler DEFINITION DEFERRED.

***** Constantes
CONSTANTS: c_icon_all TYPE char4 VALUE '@0U@',
           c_icon_one TYPE char4 VALUE '@CG@'.

***** Tipos
TYPES:
  BEGIN OF ty_header,
    icon_all TYPE char4,    " Exibir todos os itens
    icon_one TYPE char4,    " Exibir apenas o item selecionado
    bnfpo    TYPE bnfpo,    " Nº do item da requisição de compra
    ktext1   TYPE sh_text1, " Texto breve
    menge    TYPE menge_d,     " Quantidade
    netwr    TYPE bwert,       " Valor líquido do pedido em moeda de pedido
    brtwr    TYPE bbwert,    " Valor do pedido bruto em moeda de pedido
    knttp    TYPE knttp,    " Categoria de classificação contábil
  END OF ty_header,

  BEGIN OF ty_item,
    bnfpo TYPE bnfpo,     " Nº do item da requisição de compra
    zexkn TYPE dzekkn,    " Nº sequencial da classificação contábil
    vproz TYPE vproz,     " Porcentagem distribuição p/classificação contábil múltipla
    menge TYPE menge_d,   " Quantidade
    matnr TYPE matnr,     " Nº do Material
    txz01 TYPE txz01,     " Texto breve
    meins TYPE meins,     " Unidade de medida básica
    netwr TYPE bwert,     " Valor líquido do pedido em moeda de pedido
    brtwr TYPE bbwert,    " Valor do pedido bruto em moeda de pedido
    waers TYPE waers,     " Moeda
  END OF ty_item.

***** Tabelas
DATA: lt_header   TYPE TABLE OF ty_header,
      lt_item     TYPE TABLE OF ty_item,
      lt_item_sel TYPE TABLE OF ty_item.

***** ALV
DATA: lo_container_header TYPE REF TO cl_gui_custom_container,
      lo_container_item   TYPE REF TO cl_gui_custom_container,
      lo_grid_header      TYPE REF TO cl_gui_alv_grid,
      lo_grid_item        TYPE REF TO cl_gui_alv_grid,
      lt_fieldcat_header  TYPE lvc_t_fcat,
      lt_fieldcat_item    TYPE lvc_t_fcat,
      lo_event_handler    TYPE REF TO lcl_event_handler.

***** Classe
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS: handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id es_row_no e_column_id.

*    METHODS: handle_double_click
*      FOR EVENT double_click OF cl_gui_alv_grid
*      IMPORTING e_row e_column es_row_no.

ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_user_command.
    DATA: lt_rows  TYPE lvc_t_row,
          lv_row   TYPE lvc_s_row,
          lv_bnfpo TYPE bnfpo.

    CALL METHOD lo_grid_header->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    READ TABLE lt_rows INTO lv_row INDEX 1.
    IF sy-subrc = 0.
      READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX lv_row-index.
      IF sy-subrc = 0.
        lv_bnfpo = <fs_header>-bnfpo.
        CLEAR lt_item_sel.
        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE bnfpo = lv_bnfpo.
          APPEND <fs_item> TO lt_item_sel.
        ENDLOOP.
        CALL METHOD lo_grid_item->refresh_table_display.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    DATA: lv_bnfpo TYPE bnfpo.

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX es_row_no-row_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_bnfpo = <fs_header>-bnfpo.

    CASE e_column_id-fieldname.
      WHEN 'ICON_ONE'.
        CLEAR lt_item_sel.

        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE bnfpo = lv_bnfpo.
          APPEND <fs_item> TO lt_item_sel.
        ENDLOOP.

        CALL METHOD lo_grid_item->refresh_table_display.

      WHEN 'ICON_ALL'.
        CLEAR lt_item_sel.
        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item_all>).
          APPEND <fs_item_all> TO lt_item_sel.
        ENDLOOP.

        CALL METHOD lo_grid_item->refresh_table_display.
    ENDCASE.
  ENDMETHOD.

*  METHOD handle_double_click.
*    DATA: lv_bnfpo TYPE bnfpo.
*
*    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX es_row_no-row_id.
*    IF sy-subrc = 0.
*      lv_bnfpo = <fs_header>-bnfpo.
*      CLEAR lt_item_sel.
*      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE bnfpo = lv_bnfpo.
*        APPEND <fs_item> TO lt_item_sel.
*      ENDLOOP.
*      CALL METHOD lo_grid_item->refresh_table_display.
*    ENDIF.
*  ENDMETHOD.

ENDCLASS.

**********************************************************************
***** Início do Processamento
START-OF-SELECTION.
  PERFORM f_select_data.
  CALL SCREEN 0100.
**********************************************************************

FORM f_select_data.
  PERFORM f_build_mock.

  IF NOT lt_header IS INITIAL.
**** Carrega todos ITEM (sem considerar a primeira linha apenas)
    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      APPEND <fs_item> TO lt_item_sel.
    ENDLOOP.

**** Carrega somente a ITEM relaciona à primeira linha de HEADER
*    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
*    IF sy-subrc = 0.
*      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE bnfpo = <fs_header>-bnfpo.
*        APPEND <fs_item> TO lt_item_sel.
*      ENDLOOP.
*    ENDIF.
  ENDIF.
ENDFORM.

FORM f_build_mock .
**** Header
  lt_header = VALUE #(
    ( icon_all = c_icon_all icon_one = c_icon_one
      bnfpo    = '00010'
      ktext1   = 'Notebook 14" i7, 16GB'
      menge    = '12.00'
      netwr    = '2000.00'
      brtwr    = '24000.00'
      knttp    = 'K' )

    ( icon_all = c_icon_all icon_one = c_icon_one
      bnfpo    = '00020'
      ktext1   = 'Aço carbono A36, chapa 3mm'
      menge    = '1500.00'
      netwr    = '13.00'
      brtwr    = '19500.00'
      knttp    = 'F' )

    ( icon_all = c_icon_all icon_one = c_icon_one
      bnfpo    = '00030'
      ktext1   = 'Serviço manutenção preventiva – Linha 1'
      menge    = '1.00'
      netwr    = '12000.00'
      brtwr    = '12000.00'
      knttp    = 'S' )
  ).

**** Item
  lt_item = VALUE #(
    ( bnfpo = '00010' zexkn = 1 vproz = '42'
      menge = '5.00'
      matnr = '000000000000012345' txz01 = 'Notebook 14" i7, 16GB' meins = 'PC'
      netwr = '10000.00'
      brtwr = '10000.00'
      waers = 'BRL' )

    ( bnfpo = '00010' zexkn = 2 vproz = '33'
      menge = '4.00'
      matnr = '000000000000012346' txz01 = 'Notebook 14" i7, 16GB (variante)' meins = 'PC'
      netwr = '8000.00'
      brtwr = '8000.00'
      waers = 'BRL' )

    ( bnfpo = '00010' zexkn = 3 vproz = '25'
      menge = '3.00'
      matnr = '000000000000012347' txz01 = 'Notebook 14" i7, 16GB (backup)' meins = 'PC'
      netwr = '6000.00'
      brtwr = '6000.00'
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 1 vproz = '27'
      menge = '400.00'
      matnr = '000000000000098765' txz01 = 'Chapa A36 3mm – Lote A' meins = 'KG'
      netwr = '5200.00'
      brtwr = '5200.00'
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 2 vproz = '23'
      menge = '350.00'
      matnr = '000000000000098766' txz01 = 'Chapa A36 3mm – Lote B' meins = 'KG'
      netwr = '4550.00'
      brtwr = '4550.00'   " 4550 * 1.05
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 3 vproz = '20'
      menge = '300.00'
      matnr = '000000000000098767' txz01 = 'Chapa A36 3mm – Lote C' meins = 'KG'
      netwr = '3900.00'
      brtwr = '3900.00'
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 4 vproz = '17'
      menge = '250.00'
      matnr = '000000000000098768' txz01 = 'Chapa A36 3mm – Lote D' meins = 'KG'
      netwr = '3250.00'
      brtwr = '3250.00'
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 5 vproz = '10'
      menge = '150.00'
      matnr = '000000000000098769' txz01 = 'Chapa A36 3mm – Lote E' meins = 'KG'
      netwr = '1950.00'
      brtwr = '1950.00'
      waers = 'BRL' )

    ( bnfpo = '00020' zexkn = 6 vproz = '3'
      menge = '50.00'
      matnr = '000000000000098770' txz01 = 'Chapa A36 3mm – Lote F' meins = 'KG'
      netwr = '650.00'
      brtwr = '650.00'
      waers = 'BRL' )

    ( bnfpo = '00030' zexkn = 1 vproz = '40'
      menge = '0.40'
      matnr = '000000000000000321' txz01 = 'Serviço – Mecânica' meins = 'PC'
      netwr = '4800.00'
      brtwr = '4800.00'
      waers = 'BRL' )

    ( bnfpo = '00030' zexkn = 2 vproz = '25'
      menge = '0.25'
      matnr = '000000000000000322' txz01 = 'Serviço – Elétrica' meins = 'PC'
      netwr = '3000.00'
      brtwr = '3000.00'
      waers = 'BRL' )

    ( bnfpo = '00030' zexkn = 3 vproz = '20'
      menge = '0.20'
      matnr = '000000000000000323' txz01 = 'Serviço – Calibração' meins = 'PC'
      netwr = '2400.00'
      brtwr = '2400.00'
      waers = 'BRL' )

    ( bnfpo = '00030' zexkn = 4 vproz = '15'
      menge = '0.15'
      matnr = '000000000000000324' txz01 = 'Serviço – Inspeção' meins = 'PC'
      netwr = '1800.00'
      brtwr = '1800.00'
      waers = 'BRL' )
   ).
ENDFORM.

FORM f_build_fieldcatalog_header.
  CLEAR lt_fieldcat_item.
  DEFINE add_field.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-coltext   = &2.
    ls_fieldcat-just      = &3.
    ls_fieldcat-col_opt   = &4.
    ls_fieldcat-hotspot   = &5.
    ls_fieldcat-icon      = &6.
    APPEND ls_fieldcat TO lt_fieldcat_header.
  END-OF-DEFINITION.

  DATA: ls_fieldcat TYPE lvc_s_fcat.
  add_field 'ICON_ALL' '....'           '' ''  'X' 'X'.
  add_field 'ICON_ONE' '....'           '' ''  'X' 'X'.
  add_field 'BNFPO'    'Nº do item'     'X' 'X' ''  ''.
  add_field 'KTEXT1'   'Texto breve'    'X' 'X' ''  ''.
  add_field 'MENGE'    'Quantidade'     'X' 'X' ''  ''.
  add_field 'NETWR'    'Valor Líquido'  'X' 'X' ''  ''.
  add_field 'BRTWR'    'Valor Bruto'    'X' 'X' ''  ''.
  add_field 'KNTTP'    'Cat Class Cont' 'X' 'X' ''  ''.
ENDFORM.

FORM f_build_fieldcatalog_item.
  CLEAR lt_fieldcat_header.
  DEFINE add_field.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-coltext   = &2.
    ls_fieldcat-edit      = &3.
    ls_fieldcat-just      = &4.
    ls_fieldcat-do_sum    = &5.
    ls_fieldcat-col_opt   = &6.
    APPEND ls_fieldcat TO lt_fieldcat_item.
  END-OF-DEFINITION.

  DATA: ls_fieldcat TYPE lvc_s_fcat.
  add_field 'BNFPO' 'Nº do item'        ''  'X' ''  'X'.
  add_field 'ZEXKN' 'Nº seq class cont' ''  'X' ''  'X'.
  add_field 'MENGE' 'Quantidade'        'X' 'X' 'X' 'X'.
  add_field 'VPROZ' 'Porcentagem'       'X' 'X' 'X' 'X'.
  add_field 'MATNR' 'Nº do Material'    ''  'X' ''  'X' .
  add_field 'TXZ01' 'Texto breve'       ''  'X' ''  'X'.
  add_field 'MEINS' 'Unid Med Básica'   ''  'X' ''  'X'.
  add_field 'NETWR' 'Valor Líquido'     ''  'X' 'X' 'X'.
  add_field 'BRTWR' 'Valor Bruto'       ''  'X' 'X' 'X'.
  add_field 'WAERS' 'Moeda'             ''  'X' ''  'X'.
ENDFORM.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_0100'.

**** ALV HEADER
  IF lo_container_header IS INITIAL.
    CREATE OBJECT lo_container_header
      EXPORTING
        container_name = 'ALV_HEADER'.

    CREATE OBJECT lo_grid_header
      EXPORTING
        i_parent = lo_container_header.

    PERFORM f_build_fieldcatalog_header.

    CALL METHOD lo_grid_header->set_table_for_first_display
      EXPORTING
        i_structure_name = 'TY_HEADER'
        is_layout        = VALUE #( sel_mode = 'D' )
        is_variant       = VALUE disvariant( report = sy-repid )
        i_save           = 'A'
      CHANGING
        it_outtab        = lt_header
        it_fieldcatalog  = lt_fieldcat_header.

    IF lo_event_handler IS INITIAL.
      CREATE OBJECT lo_event_handler.

      SET HANDLER lo_event_handler->handle_hotspot_click FOR lo_grid_header.
      "SET HANDLER lo_event_handler->handle_double_click FOR lo_grid_header.
      "SET HANDLER lo_event_handler->handle_user_command FOR lo_grid_header.
    ENDIF.
  ENDIF.

***** ALV ITEM
  IF lo_container_item IS INITIAL.
    CREATE OBJECT lo_container_ITEM
      EXPORTING
        container_name = 'ALV_ITEM'.

    CREATE OBJECT lo_grid_item
      EXPORTING
        i_parent = lo_container_item.

    PERFORM f_build_fieldcatalog_item.

    CALL METHOD lo_grid_item->set_table_for_first_display
      EXPORTING
        i_structure_name = 'TY_ITEM'
        is_variant       = VALUE disvariant( report = sy-repid )
        i_save           = 'A'
      CHANGING
        it_outtab        = lt_item_sel
        it_fieldcatalog  = lt_fieldcat_item.
  ENDIF.
ENDMODULE.

MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
