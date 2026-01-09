*&---------------------------------------------------------------------*
*& Report ZESTUDO_RATEIO
*&---------------------------------------------------------------------*
*& RATEIO POR QUANTIDADE
*&---------------------------------------------------------------------*
REPORT zestudo_rateio.

TYPES: BEGIN OF ty_item,
         menge        TYPE menge_d,
         valor_rateio TYPE decfloat34,
         percentual   TYPE decfloat34,
       END OF ty_item.

DATA: lv_valor_total TYPE wrbtr VALUE '10000',
      lv_total_menge TYPE menge_d,
      lt_items       TYPE STANDARD TABLE OF ty_item,
      ls_item        TYPE ty_item.

lt_items = VALUE #(
  ( menge = '10' valor_rateio = '150.75' percentual = '20' )
  ( menge = '5'  valor_rateio = '80.25'  percentual = '30' )
  ( menge = '3'  valor_rateio = '45.00'  percentual = '50' )
).

**********************************************************************
**** QUANTIDADE
" Calcula quantidade total
WRITE:/ 'QUANTIDADE'.
lv_total_menge = 0.
LOOP AT lt_items INTO ls_item.
  lv_total_menge = lv_total_menge + ls_item-menge.
ENDLOOP.

" Distribui proporcionalmente
LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<fs>).
  IF lv_total_menge > 0.
    <fs>-valor_rateio = lv_valor_total * ( <fs>-menge / lv_total_menge ).
    WRITE:/ <fs>-valor_rateio.
  ELSE.
    <fs>-valor_rateio = 0.
    WRITE:/ <fs>-valor_rateio.
  ENDIF.
ENDLOOP.

**********************************************************************
**** PERCENTUAL
WRITE:/ 'PERCENTUAL'.
DATA(lv_total_perc) = 0.

" Valida soma dos percentuais
LOOP AT lt_items INTO ls_item.
  lv_total_perc = lv_total_perc + ls_item-percentual.
ENDLOOP.

IF lv_total_perc <> 100.
  MESSAGE e001(zm00) WITH 'Percentuais devem somar 100%'.
  EXIT.
ENDIF.

" Calcula rateio por percentual
LOOP AT lt_items ASSIGNING <fs>.
  <fs>-valor_rateio = lv_valor_total * ( <fs>-percentual / 100 ).
  WRITE:/ <fs>-valor_rateio.
ENDLOOP.
