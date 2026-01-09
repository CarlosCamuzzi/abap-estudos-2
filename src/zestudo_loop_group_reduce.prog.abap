*&---------------------------------------------------------------------*
*& Report ZESTUDO_LOOP_GROUP_REDUCE
*&---------------------------------------------------------------------*
*& EBAN: banfn bnfpo bsart matkl matnr txz01 menge meins preis peinh
*&---------------------------------------------------------------------*
REPORT zestudo_loop_group_reduce NO STANDARD PAGE HEADING.

TABLES: eban.   " Requisição de compra

**** Tipos
TYPES: BEGIN OF ty_eban,
         banfn TYPE eban-banfn,   " Nº requisição de compra
         bnfpo TYPE eban-bnfpo,   " Nº do item da requisição de compra
         bsart TYPE eban-bsart,   " Tipo de documento da requisição de compra
         matkl TYPE eban-matkl,   " Grupo de mercadorias
         matnr TYPE eban-matnr,   " Nº do material
         txz01 TYPE eban-txz01,   " Texto breve
         menge TYPE eban-menge,   " Quantidade da requisição de compra
         meins TYPE eban-meins,   " Unidade medida da requisição compra
         preis TYPE eban-preis,   " Preço na requisição de compra
         peinh TYPE eban-peinh,   " Unidade preço
       END OF ty_eban.

**** Tabelas, variáveis, estruturas
DATA: gt_eban   TYPE TABLE OF ty_eban.  " Tabela principal
DATA: gt_result TYPE string_table.      " Tabela de string - saída de dados
DATA: gv_sum TYPE eban-preis.           " Acumulador REDUCE

**** Tela de Seleção
*** Selecionar requisição de compras
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_banfn FOR eban-banfn.
SELECTION-SCREEN END OF BLOCK b01.

**** Início do processamento
START-OF-SELECTION.
  PERFORM f_select_data.
  PERFORM f_format_data.
  PERFORM f_display_data.

**** Forms
*** Selecionar dados na EBAN
FORM f_select_data .
  SELECT banfn, bnfpo, bsart, matkl,
         matnr, txz01, menge, meins,
         preis, peinh
    INTO TABLE @gt_eban
    FROM eban
    WHERE banfn IN @s_banfn.

  IF sy-subrc <> 0.
    MESSAGE: |Nenhum dado encontrado.| TYPE 'E'.
  ENDIF.

ENDFORM.

**** Loops e formatações
FORM f_format_data .
  IF gt_eban[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_sum.

  " Loop agrupando pelos campos bsart e matnr
  LOOP AT gt_eban ASSIGNING FIELD-SYMBOL(<fs>)
    GROUP BY ( bsart = <fs>-bsart
               matnr = <fs>-matnr )
    INTO DATA(ls_group).

    " Reduce sempre retorna o mesmo tipo do acumulador
    gv_sum = REDUCE eban-preis(
              INIT sum = CONV #( 0 )
              FOR idx IN GROUP ls_group
              NEXT sum = sum + idx-preis ).

    " Value + Base para inserir um item, como um append
    gt_result = VALUE #(
     BASE gt_result (
          | BSART..: { ls_group-bsart } |
       && | MATNR..: { ls_group-matnr } |
       && | SUM....: { gv_sum } | ) ).
  ENDLOOP.
ENDFORM.

**** Exibir dados
FORM f_display_data .
  data(out) = cl_demo_output=>new( ).

  out->write( : data = sy-uname ),
                data = sy-datum ),
                data = sy-uzeit )->display( ).

  cl_demo_output=>new( 'TEXT' )->display( gt_result ).
 " cl_demo_output=>display( gt_result ).

*  DATA(html) = cl_demo_output=>get( gt_eban ).
*  cl_abap_browser=>show_html( html_string = html ).
ENDFORM.
