*&---------------------------------------------------------------------*
*& Include          ZINCLUDE_PED_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR  'TITLE_0100'.  " Criar Pedido

  IF go_alv_pedido IS INITIAL.
    go_alv_pedido = zcl_alv_handler_pedido=>get_instance( ).
    go_alv_pedido->init_ui( ).
  ENDIF.

  go_alv_pedido->display( ).
ENDMODULE.
