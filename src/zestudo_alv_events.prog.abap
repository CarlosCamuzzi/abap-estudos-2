*&---------------------------------------------------------------------*
*& Report ZESTUDO_ALV_EVENTS
*&---------------------------------------------------------------------*
*& DATA_CHANGED e DATA_CHANGED_FINISHED

* Regras:
*   - Quantidade não pode ser ≤ 0
*   - Ao alterar MENGE → recalcula NETWR
*   - Após finalizar a edição → recalcula TOTAL GERAL

* Obs.:
*   - Nunca tratar regra de negócio final no DATA_CHANGED
*   -  Nunca validar campo no DATA_CHANGED_FINISHED
*   - Nunca mexer direto na tabela dentro do DATA_CHANGED

* Dica:
*   - “Se eu ainda posso impedir a mudança, estou no DATA_CHANGED.”
*   - “Se a mudança já aconteceu, estou no DATA_CHANGED_FINISHED.”

*----------------------
*       FLUXO
*----------------------
* Usuário digita MENGE
*         ↓
* DATA_CHANGED
*   → valida
*   → calcula NETWR
*         ↓
* ALV aplica mudanças
*         ↓
* DATA_CHANGED_FINISHED
*   → soma TOTAL
*   → refresh tela
*----------------------

* O que NÃO fazer
*   - Somar totais no DATA_CHANGED
*   - Fazer refresh_table_display no DATA_CHANGED
*   - Alterar gt_alv no DATA_CHANGED
*   - Recalcular NETWR no DATA_CHANGED_FINISHED

*&---------------------------------------------------------------------*
*ZSESTUDO_EVENTS:
*MENGE
*MEINS
*NETPR
*NETWR
*WAERS
*&---------------------------------------------------------------------*

REPORT zestudo_alv_events NO STANDARD PAGE HEADING.

CLASS lcl_events DEFINITION DEFERRED.

***** Tabelas, variáveis e objetos
DATA: gt_alv         TYPE STANDARD TABLE OF zsestudo_events,
      gv_total_geral TYPE netwr.

DATA: lt_fcat TYPE lvc_t_fcat,
      ls_fcat TYPE lvc_s_fcat.

DATA: go_alv       TYPE REF TO cl_gui_alv_grid,
      go_container TYPE REF TO cl_gui_custom_container,
      go_events    TYPE REF TO lcl_events.

**********************************************************************
***** Classe
CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed e_onf4,

      data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified.

ENDCLASS.

CLASS lcl_events IMPLEMENTATION.
* DATA_CHANGED:
*  Ainda não alterei a tabela do ALV
*  Validei a entrada
*  Calculei valor dependente
*  ALV vai aplicar isso sozinho depois
  METHOD data_changed.

    DATA: lv_netwr TYPE netwr,
          lv_preco TYPE netpr,
          lv_menge TYPE i.

    " percorre as células que o usuário ALTEROU e que foram consideradas válida
    LOOP AT er_data_changed->mt_good_cells INTO DATA(ls_good).

      " Só reage à mudança de quantidade
      CHECK ls_good-fieldname = 'MENGE'.

      " ===== Validação MENGE =====
      " Validação, pois o VALUE do mt_good_cells pode apresentar problema na conversão
      er_data_changed->get_cell_value(
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'MENGE'
        IMPORTING
          e_value     = lv_menge ).

      " ===== Validação =====
      IF lv_menge <= 0.
        er_data_changed->add_protocol_entry(
          i_msgid = '00'
          i_msgty = 'E'
          i_msgno = '001'
          i_msgv1 = 'Quantidade deve ser maior que zero'
          i_fieldname = ls_good-fieldname
          i_row_id    = ls_good-row_id ).
        CONTINUE.
      ENDIF.

      " ===== Buscar preço da linha =====
      er_data_changed->get_cell_value(
        EXPORTING
          i_row_id    = ls_good-row_id
          i_fieldname = 'NETPR'
        IMPORTING
          e_value     = lv_preco ).

      " ===== Cálculo =====
      lv_netwr = lv_menge * lv_preco.

      " ===== Atualizar campo dependente =====
      er_data_changed->modify_cell(
        i_row_id    = ls_good-row_id
        i_fieldname = 'NETWR'
        i_value     = lv_netwr ).

    ENDLOOP.
  ENDMETHOD.

* DATA_CHANGED_FINISHED
*   Aqui é permitido:
*   Trabalhar com gt_alv
*   Somar
*   Atualizar totais
*   Atualizar tela
*   Habilitar botões
*   Disparar regra final
  METHOD data_changed_finished.

    CHECK e_modified = abap_true.

    DATA(lv_total) = 0.

    LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<fs_alv>).
      lv_total += <fs_alv>-netwr.
    ENDLOOP.

    gv_total_geral = lv_total.

    " Atualiza rodapé / total / tela
    go_alv->refresh_table_display(
      is_stable = VALUE lvc_s_stbl( row = 'X' col = 'X' ) ).
  ENDMETHOD.
ENDCLASS.
**********************************************************************

***** Início do Processamento
START-OF-SELECTION.
  PERFORM f_fill_data.
  CALL SCREEN 0100.

***** Forms
FORM f_fill_data.

  gt_alv = VALUE #(
    ( menge = 1 netpr = 10 netwr = 10 waers = 'BRL' )
    ( menge = 2 netpr = 20 netwr = 40 waers = 'BRL' )
    ( menge = 3 netpr = 30 netwr = 90 waers = 'BRL' )
  ).

ENDFORM.

FORM f_display_alv.
  " ===== Container =====
  CHECK go_container IS INITIAL.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'ALV_CONTAINER'.

  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_container.

  " ===== Events =====
  CHECK go_events IS INITIAL.

  CREATE OBJECT go_events.
  SET HANDLER go_events->data_changed FOR go_alv.
  SET HANDLER go_events->data_changed_finished FOR go_alv.

  " ===== Display =====
  go_alv->set_table_for_first_display(
*    EXPORTING
*      is_layout       = VALUE lvc_s_layo( edit = abap_true )
    CHANGING
      it_outtab       = gt_alv
      it_fieldcatalog = lt_fcat ).

  go_alv->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).

ENDFORM.

FORM f_build_fieldcat.
  " ===== Field Catalog =====
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'MENGE'.
  ls_fcat-coltext   = 'Quantidade'.
  ls_fcat-edit      = abap_true.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'NETPR'.
  ls_fcat-coltext   = 'Preço'.
  ls_fcat-edit      = abap_false.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'NETWR'.
  ls_fcat-coltext   = 'Valor'.
  ls_fcat-edit      = abap_false.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'WAERS'.
  ls_fcat-coltext   = 'Moeda'.
  ls_fcat-edit      = abap_false.
  APPEND ls_fcat TO lt_fcat.

ENDFORM.

***** Module
MODULE status_0100 OUTPUT.       " PBO
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  PERFORM f_build_fieldcat.
  PERFORM f_display_alv.
ENDMODULE.

MODULE user_command_0100 INPUT.  " PAI
 " go_alv->check_changed_data( ).

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.

*  go_alv->set_focus(
*    control = CAST cl_gui_control( go_alv )
*  ).
ENDMODULE.
