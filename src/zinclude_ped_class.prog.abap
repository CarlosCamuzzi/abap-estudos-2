*&---------------------------------------------------------------------*
*& Include          ZINCLUDE_PED_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_alv_handler_pedido DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_pedido) TYPE REF TO lcl_alv_handler_pedido .

    METHODS constructor.

    METHODS:
      init_ui,  " Criar container + ALV
      " init_ui deve checar se mo_grid_ped já existe
      display,  " First display
      refresh.  " Refresh sem recriar

**** Eventos
    METHODS on_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING e_ucomm.

    METHODS on_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid IMPORTING e_ucomm.

  PRIVATE SECTION.
**** Objeto: Instância da classe
    CLASS-DATA mo_instance TYPE REF TO lcl_alv_handler_pedido.

**** Objetos
    DATA mo_container_ped TYPE REF TO cl_gui_custom_container.
    DATA mo_grid_ped      TYPE REF TO cl_gui_alv_grid.

**** Tabelas
    DATA gt_pedido        TYPE ztt_pedido.     " tabela de pedidos
    DATA gt_fieldcat_ped  TYPE lvc_t_fcat.

ENDCLASS.

CLASS lcl_alv_handler_pedido IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.

***** Única instância
  METHOD get_instance.
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.

    ro_pedido = mo_instance.
  ENDMETHOD.

*****  Criar container + ALV
  METHOD init_ui.
    " Se o ALV já existe, não faz nada
    IF mo_grid_ped IS INITIAL.
      RETURN.
    ENDIF.

    " Criar o container (Custom Control da tela 0100)
    CREATE OBJECT mo_container_ped
      EXPORTING
        container_name = 'CONTAINER_ALV_PEDIDO'.

    " Criar o ALV Grid dentro do container
    CREATE OBJECT mo_grid_ped
      EXPORTING
        i_parent = mo_container_ped.

    " Registrar eventos do ALV
    SET HANDLER me->on_data_changed   FOR mo_grid_ped.
    SET HANDLER me->on_data_finished  FOR mo_grid_ped.

  ENDMETHOD.

**** Eventos
  METHOD on_data_changed.

  ENDMETHOD.

  METHOD on_data_changed_finished.

  ENDMETHOD.

ENDCLASS.
