*&---------------------------------------------------------------------*
*& Include          ZINCLUDE_PED_FORM
*&---------------------------------------------------------------------*

**** Validação de input antes de SAVE
FORM f_alv_check_input .
  "cl_gui_cfw=>flush( ).
  go_alv_pedido->check_changed_data( ).
  "cl_gui_cfw=>flush( ).

  IF go_alv_pedido->get_error( )  = 'X'.
    MESSAGE: 'Erro' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
ENDFORM.
