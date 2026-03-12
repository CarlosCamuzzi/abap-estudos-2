CLASS zcl_alv_handler_pedido DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
**** Métodos estáticos
    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_pedido) TYPE REF TO zcl_alv_handler_pedido.

**** Métodos
    METHODS constructor.

    METHODS:
      init_ui,  " Criar container e ALV
      display.  " First display e refresh

**** Eventos
    METHODS on_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed e_ucomm.

    METHODS on_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid IMPORTING e_modified.

  PRIVATE SECTION.
**** Objeto: Instância da classe
    CLASS-DATA mo_instance TYPE REF TO zcl_alv_handler_pedido.

**** Métodos
    METHODS: build_fieldcat,
      build_layout,
      exclude_toolbar.

**** Objetos
    DATA mo_container TYPE REF TO cl_gui_custom_container.
    DATA mo_grid      TYPE REF TO cl_gui_alv_grid.

**** Tabelas
    DATA gt_pedido    TYPE TABLE OF zstpedido.
    DATA gt_fieldcat  TYPE lvc_t_fcat.
    DATA gt_exclude   TYPE ui_functions.

**** Estrutura
    DATA gs_layout TYPE lvc_s_layo.
ENDCLASS.



CLASS ZCL_ALV_HANDLER_PEDIDO IMPLEMENTATION.


  METHOD constructor.
  ENDMETHOD.


  METHOD get_instance.
***** Única instância
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.

    ro_pedido = mo_instance.
  ENDMETHOD.


  METHOD init_ui.
*****  Criar container + ALV
    " Se o ALV já existe, não faz nada
    CHECK mo_grid IS INITIAL.

    " Criar o container (Custom Control da tela 0100)
    CREATE OBJECT mo_container
      EXPORTING
        container_name = 'CONTAINER_ALV_PEDIDO'.

    " Criar o ALV Grid dentro do container
    CREATE OBJECT mo_grid
      EXPORTING
        i_parent = mo_container.

    me->build_fieldcat( ).
    me->build_layout( ).
    me->exclude_toolbar( ).

    " Chama uma única vez
    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout       = gs_layout
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_outtab       = gt_pedido
        it_fieldcatalog = gt_fieldcat
    ).

    " Registrar eventos do ALV
    SET HANDLER me->on_data_changed FOR mo_grid.
    SET HANDLER me->on_data_changed_finished  FOR mo_grid.

    " Registrar evento de edição
    mo_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
    mo_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_enter ).

  ENDMETHOD.


  METHOD on_data_changed.
**** Insert Linha
    DATA lv_value TYPE bstyp.
    LOOP AT er_data_changed->mt_inserted_rows ASSIGNING FIELD-SYMBOL(<fs_insert>).
      CLEAR lv_value.





*      er_data_changed->get_cell_value(
*        EXPORTING
*          i_row_id    = <fs_insert>-row_id
*          i_fieldname = 'BSTYP'
*        IMPORTING
*          e_value     = lv_value
*      ).
*
*      " Se estiver vazio, define um default no PRÓPRIO buffer de mudanças
*      IF lv_value IS INITIAL.
*        er_data_changed->modify_cell(
*          EXPORTING
*            i_row_id    = <fs_insert>-row_id
*            i_fieldname = 'BSTYP'
*            i_value     = 'F'
*        ).
*      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD on_data_changed_finished.

  ENDMETHOD.


  METHOD build_fieldcat.
    REFRESH gt_fieldcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'ZTPEDIDO'
      CHANGING
        ct_fieldcat      = gt_fieldcat
      EXCEPTIONS
        OTHERS           = 1.

    LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
      <fs_fieldcat>-just      = 'C'.
      <fs_fieldcat>-col_opt   = ''.

      CASE <fs_fieldcat>-fieldname.
        WHEN 'EBELN'.
          <fs_fieldcat>-edit      = ''.
          <fs_fieldcat>-scrtext_l = 'Número do Pedido'.
          <fs_fieldcat>-scrtext_m = 'Número Pedido'.
          <fs_fieldcat>-scrtext_s = 'Núm Ped'.
          <fs_fieldcat>-reptext   = 'Número Pedido'.

        WHEN 'BSTYP'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Categoria Documento'.
          <fs_fieldcat>-scrtext_m = 'Categ Documento'.
          <fs_fieldcat>-scrtext_s = 'Cat Doc'.

        WHEN 'BSART'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Tipo do Documento'.
          <fs_fieldcat>-scrtext_m = 'Tipo Documento'.
          <fs_fieldcat>-scrtext_s = 'Tp Doc'.

        WHEN 'LIFNR'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Código do Fornecedor'.
          <fs_fieldcat>-scrtext_m = 'Código Fornecedor'.
          <fs_fieldcat>-scrtext_s = 'Cód Forn'.

        WHEN 'RAZAO'.
          <fs_fieldcat>-edit = ''.
          <fs_fieldcat>-scrtext_l = 'Razão Social'.
          <fs_fieldcat>-scrtext_m = 'Razão Social'.
          <fs_fieldcat>-scrtext_s = 'Razão Soc'.

        WHEN 'AEDAT'.
          <fs_fieldcat>-edit = ''.
          <fs_fieldcat>-scrtext_l = 'Data da Criação'.
          <fs_fieldcat>-scrtext_m = 'Data Criação'.
          <fs_fieldcat>-scrtext_s = 'Dt Cri'.

        WHEN 'ERNAM'.
          <fs_fieldcat>-edit = ''.
          <fs_fieldcat>-scrtext_m = 'Usuário'.
          <fs_fieldcat>-scrtext_s = 'Usuário'.
          <fs_fieldcat>-scrtext_l = 'Usuário'.

        WHEN 'NETWR'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Valor Líquido'.
          <fs_fieldcat>-scrtext_m = 'Valor Líq'.
          <fs_fieldcat>-scrtext_s = 'Vlr Líq'.

        WHEN 'BRTWR'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Valor Bruto'.
          <fs_fieldcat>-scrtext_m = 'Valor Brut'.
          <fs_fieldcat>-scrtext_s = 'Vlr Brut'.

        WHEN 'IMPOSTO'.
          <fs_fieldcat>-edit      = 'X'.
          <fs_fieldcat>-scrtext_l = 'Imposto'.
          <fs_fieldcat>-scrtext_m = 'Imposto'.
          <fs_fieldcat>-scrtext_s = 'Imp'.

        WHEN 'WAERS'.
          <fs_fieldcat>-edit      = ''.
          <fs_fieldcat>-scrtext_l = 'Moeda'.
          <fs_fieldcat>-scrtext_m = 'Moeda'.
          <fs_fieldcat>-scrtext_s = 'Moeda'.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_layout.
    CLEAR gs_layout.

    gs_layout = VALUE #( edit       = abap_false
                         zebra      = abap_true
                         cwidth_opt = abap_true
                         sel_mode   = 'A' ).  " seleção de linhas
  ENDMETHOD.


  METHOD display.
    DATA: ls_stable TYPE lvc_s_stbl.

    " Garante que o ALV já foi criado
    IF mo_grid IS INITIAL.
      RETURN.
    ENDIF.

    " Mantém scroll e seleção
    ls_stable-row = abap_true.
    ls_stable-col = abap_true.

    " Permite edição, normalmente valida antes
    mo_grid->check_changed_data( ).

    " Atualiza o conteúdo visual do ALV
    mo_grid->refresh_table_display( is_stable = ls_stable i_soft_refresh = abap_true ).
  ENDMETHOD.


  METHOD exclude_toolbar.
    REFRESH gt_exclude.

    gt_exclude = VALUE #(
   "( cl_gui_alv_grid=>mc_fc_loc_insert_row )
   ( cl_gui_alv_grid=>mc_fc_loc_append_row )
   "( cl_gui_alv_grid=>mc_fc_loc_delete_row )
   ( cl_gui_alv_grid=>mc_fc_loc_move_row )
   ( cl_gui_alv_grid=>mc_fc_loc_paste )
   ( cl_gui_alv_grid=>mc_fc_loc_cut )
   ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
   ( cl_gui_alv_grid=>mc_fc_info )
   ( cl_gui_alv_grid=>mc_fc_check )
   ( cl_gui_alv_grid=>mc_fc_loc_copy_row )
   ( cl_gui_alv_grid=>mc_fc_refresh )
   ( cl_gui_alv_grid=>mc_fc_check )
   ( cl_gui_alv_grid=>mc_fc_loc_move_row )
   ( cl_gui_alv_grid=>mc_fc_graph )
   ( cl_gui_alv_grid=>mc_fc_views )
   ( cl_gui_alv_grid=>mc_fc_variant_admin )
   ( cl_gui_alv_grid=>mc_fc_current_variant )
   ( cl_gui_alv_grid=>mc_fc_filter )
   ( cl_gui_alv_grid=>mc_fc_sort )
   ( cl_gui_alv_grid=>mc_fc_sort_asc )
   ( cl_gui_alv_grid=>mc_fc_sort_dsc )
   ( cl_gui_alv_grid=>mc_fc_info ) ).

  ENDMETHOD.
ENDCLASS.
