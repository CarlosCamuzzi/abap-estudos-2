*&---------------------------------------------------------------------*
*& Report ZESTUDO_TESTES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zestudo_testes.

*DATA LV_BOOL TYPE ABAP_BOOL.
*LV_BOOL = xsdbool( 2 > 1 ).
*WRITE: LV_BOOL.
*
**********************************************************************
*TYPES: BEGIN OF ty_check,
*         invalid TYPE abap_bool,
*         text    TYPE string,
*       END OF ty_check.
*
*DATA: lv_txt1  TYPE string,
*      lv_txt2  TYPE string,
*      lv_txt3  TYPE string,
*      lv_txt4  TYPE string,
*      lv_index TYPE i VALUE 0.
*
*
*DATA lt_check TYPE STANDARD TABLE OF ty_check.
*DATA lv_has_error TYPE abap_bool.
*"DATA lv_message   TYPE string VALUE 'Distribuição inconsistente:'.
*DATA lv_title  TYPE string VALUE 'Distribuição inconsistente:'.
*
*
*APPEND VALUE #( invalid = xsdbool( 2 < 1 )
*                text    = 'Quantidade distribuída menor que o total.' ) TO lt_check.
*
*APPEND VALUE #( invalid = xsdbool( 7 < 4 )
*                text    = 'Valor distribuído menor que o valor do item.' ) TO lt_check.
*
*APPEND VALUE #( invalid = xsdbool( 4 < 1 )
*                text    = 'Percentual distribuído inferior a 100%.' ) TO lt_check.
*
*
*
*LOOP AT lt_check ASSIGNING FIELD-SYMBOL(<fs_check>) WHERE invalid = abap_false.
*  "lv_message &&= | { <fs_check>-text }|.
*  lv_has_error = abap_true.
*  lv_index += 1.
*
*  CASE lv_index.
*    WHEN 1.
*      lv_txt1 = <fs_check>-text.
*    WHEN 2.
*      lv_txt2 = <fs_check>-text.
*    WHEN 3.
*      lv_txt3 = <fs_check>-text.
*    WHEN 4.
*      lv_txt4 = <fs_check>-text.
*  ENDCASE.
*ENDLOOP.
*
*
*IF lv_has_error = abap_true.
*  CALL FUNCTION 'POPUP_TO_INFORM'
*    EXPORTING
*      titel = lv_title
*      txt1  = lv_txt1
*      txt2  = lv_txt2
*      txt3  = lv_txt3
*      txt4  = lv_txt4.
*
*  "EXIT. " ou RETURN
*ENDIF.
**********************************************************************

**** Concatenação
DATA(LV_NUM) = 2.
DATA(LV_TEXT) = 'O número' && | { lv_num } | && 'é o correto'.

write:/ lv_text.
