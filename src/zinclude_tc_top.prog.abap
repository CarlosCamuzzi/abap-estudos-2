*&---------------------------------------------------------------------*
*& Include ZINCLUDE_TC_TOP                          - PoolMóds.        ZESTUDO_TC
*&---------------------------------------------------------------------*
PROGRAM ZESTUDO_TC.

**** Types
TYPES: BEGIN OF ty_dados,
         codigo   TYPE i,
         nome(20) TYPE c,
       END OF ty_dados.

**** Tabela
DATA: lt_dados TYPE STANDARD TABLE OF ty_dados WITH HEADER LINE.

**** Table Control
CONTROLS: tc_0100 TYPE TABLEVIEW USING SCREEN 0100.
