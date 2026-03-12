*&---------------------------------------------------------------------*
*& Report ZESTUDO_CURRENCY
*&---------------------------------------------------------------------*
*& Formatação MOEDA com template string e append para tabela
*&---------------------------------------------------------------------*
REPORT zestudo_currency.

DATA lv_amount   TYPE wrbtr.   " valor
DATA lv_valor_c TYPE c LENGTH 50.
DATA p_text     TYPE bcsy_text.

lv_amount = '12345.00'.

**** Write já converte automático e aceita template de string
"WRITE:/ lv_amount.
"WRITE:/ |{ lv_amount CURRENCY = 'USD'}|.

**** Para append, o template não aceita o CURRENCY = 'USD'
**** Usar com write da forma abaixo:

WRITE lv_amount CURRENCY 'BRL' TO lv_valor_c.
CONDENSE lv_valor_c.

APPEND |Valor: R$ { lv_valor_c }</br>| TO p_text.

BREAK-POINT.
