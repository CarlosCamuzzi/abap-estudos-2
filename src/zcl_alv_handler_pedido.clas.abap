class ZCL_ALV_HANDLER_PEDIDO definition
  public
  inheriting from CL_GUI_ALV_GRID
  final
  create public .

public section.

**** Métodos estáticos
  class-methods GET_INSTANCE
    returning
      value(RO_PEDIDO) type ref to ZCL_ALV_HANDLER_PEDIDO .
**** Métodos
  methods CONSTRUCTOR .
  methods INIT_UI .
  methods DISPLAY .
**** Eventos
  methods ON_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_UCOMM .
  methods ON_DATA_CHANGED_FINISHED
    for event DATA_CHANGED_FINISHED of CL_GUI_ALV_GRID
    importing
      !E_MODIFIED .
  methods GET_ERROR
    returning
      value(RV_ERROR) type ABAP_BOOL .
protected section.
private section.

**** Objeto: Instância da classe
  class-data MO_INSTANCE type ref to ZCL_ALV_HANDLER_PEDIDO .
**** Objetos
  data MO_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MO_GRID type ref to CL_GUI_ALV_GRID .
  data:
**** Tabelas
    gt_pedido    TYPE TABLE OF zstpedido .
  data GT_FIELDCAT type LVC_T_FCAT .
  data GT_EXCLUDE type UI_FUNCTIONS .
**** Estrutura
  data GS_LAYOUT type LVC_S_LAYO .
  data GV_ERROR type ABAP_BOOL .

  methods SET_ERROR
    importing
      !IV_ERROR type ABAP_BOOL .
**** Métodos
  methods BUILD_FIELDCAT .
  methods BUILD_LAYOUT .
  methods EXCLUDE_TOOLBAR .
ENDCLASS.



CLASS ZCL_ALV_HANDLER_PEDIDO IMPLEMENTATION.


  METHOD constructor.
    super->constructor( i_parent = mo_container ).
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
    mo_grid->set_ready_for_input( 1 ).
    mo_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_enter ).

    " Comentado para desabilitar a validação padrão de bstyp
    " Obs.: Isso desabilita as validações 'automáticas' a cada input
    "mo_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
  ENDMETHOD.


  METHOD on_data_changed.
**** Insert Linha
    LOOP AT er_data_changed->mt_inserted_rows ASSIGNING FIELD-SYMBOL(<fs_row>).

    ENDLOOP.

**** Validar de campos e setar erros
    LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<fs_cell>).
      IF <fs_cell>-fieldname = 'LIFNR' AND <fs_cell>-value IS INITIAL.
        me->set_error( 'X' ).

        er_data_changed->add_protocol_entry(
          EXPORTING
            i_msgid     = 'ZMSG'
            i_msgno     = '001'
            i_msgty     = 'E'
            i_fieldname = 'LIFNR'
            i_row_id    = <fs_cell>-row_id ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD on_data_changed_finished.
    MESSAGE: 'ENTROU FINISHED' TYPE 'S'.
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
          <fs_fieldcat>-no_out     = 'X'.
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


  METHOD get_error.
    rv_error = gv_error.
  ENDMETHOD.


  METHOD set_error.
    gv_error = iv_error.
  ENDMETHOD.
ENDCLASS.
