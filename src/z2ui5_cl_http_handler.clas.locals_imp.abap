CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        type           TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
        gen_type_kind  TYPE string,
        gen_type       TYPE string,
        gen_kind       TYPE string,
      END OF ty_attri.
    TYPES ty_T_attri TYPE STANDARD TABLE OF ty_attri WITH DEFAULT KEY.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        s_msg  TYPE LINE OF bapirettab,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val      TYPE any OPTIONAL
        previous TYPE REF TO cx_root OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike     DEFAULT `CX_SY_SUBRC`
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_header_val
      IMPORTING
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_name_value-value.

    CLASS-METHODS get_param_val
      IMPORTING
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_name_value-value.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_uuid_session
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS trans_any_2_json
      IMPORTING
        any           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_xml_2_object
      IMPORTING
        xml  TYPE clike
      EXPORTING
        data TYPE data.

    CLASS-METHODS get_t_attri_by_ref
      IMPORTING
        io_app        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE ty_t_attri ##NEEDED.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_abap_2_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_is_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS get_json_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING
        ir_tab_from TYPE REF TO data
      EXPORTING
        t_result    TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _get_t_attri_by_struc
      IMPORTING
        io_app        TYPE REF TO object
        iv_attri      TYPE csequence
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.


  PROTECTED SECTION.

    CLASS-DATA mv_counter TYPE i.


  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_utility IMPLEMENTATION.

  METHOD get_trim_upper.
    DATA temp5 TYPE string.
    temp5 = val.
    result = temp5.
    result = to_upper( shift_left( shift_right( result ) ) ).
  ENDMETHOD.


  METHOD constructor.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root ##CATCH_ALL.
        ms_error-s_msg-message = val.
    ENDTRY.

    TRY.
        ms_error-uuid = get_uuid( ).
      CATCH cx_root ##CATCH_ALL.
    ENDTRY.
  ENDMETHOD.


  METHOD get_abap_2_json.

    IF check_is_boolean( val ) IS NOT INITIAL.
      DATA temp6 TYPE string.
      IF val = abap_true.
        temp6 = `true`.
      ELSE.
        temp6 = `false`.
      ENDIF.
      result = temp6.
    ELSE.
      result = |"{ escape( val = val  format = cl_abap_format=>e_json_string ) }"|.
    ENDIF.

  ENDMETHOD.


  METHOD check_is_boolean.

    TRY.
        DATA temp7 TYPE REF TO cl_abap_elemdescr.
        temp7 ?= cl_abap_elemdescr=>describe_by_data( val ).
        DATA lo_ele LIKE temp7.
        lo_ele = temp7.
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD get_json_boolean.

    IF check_is_boolean( val ) IS NOT INITIAL.
      DATA temp8 TYPE string.
      IF val = abap_true.
        temp8 = `true`.
      ELSE.
        temp8 = `false`.
      ENDIF.
      result = temp8.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_timestampl.

    GET TIME STAMP FIELD result.

  ENDMETHOD.


  METHOD get_user_tech.

    result = sy-uname.

  ENDMETHOD.


  METHOD get_uuid.
    TRY.

        DATA uuid TYPE c LENGTH 32.

        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA lv_fm TYPE string.
            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD get_uuid_session.

    mv_counter = mv_counter + 1.
    result = get_trim_upper( mv_counter ).

  ENDMETHOD.


  METHOD get_header_val.

    DATA temp9 LIKE LINE OF z2ui5_cl_http_handler=>client-t_header.
    DATA temp10 LIKE sy-tabix.
    temp10 = sy-tabix.
    READ TABLE z2ui5_cl_http_handler=>client-t_header WITH KEY name = v INTO temp9.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    result  = to_lower( temp9-value ).

  ENDMETHOD.


  METHOD get_param_val.

    DATA temp11 TYPE z2ui5_if_client=>ty_t_name_value.
    CLEAR temp11.
    DATA tab TYPE z2ui5_if_client=>ty_t_name_value.
    tab = z2ui5_cl_http_handler=>client-t_param.
    DATA row LIKE LINE OF tab.
    LOOP AT tab INTO row.
      DATA temp12 LIKE LINE OF temp11.
      temp12-name = to_upper( row-name ).
      temp12-value = to_upper( row-value ).
      INSERT temp12 INTO TABLE temp11.
    ENDLOOP.
    DATA lt_param LIKE temp11.
    lt_param = temp11.
    TRY.
        DATA temp13 LIKE LINE OF lt_param.
        DATA temp14 LIKE sy-tabix.
        temp14 = sy-tabix.
        READ TABLE lt_param WITH KEY name = get_trim_upper( v ) INTO temp13.
        sy-tabix = temp14.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
        ENDIF.
        result = temp13-value.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD get_t_attri_by_ref.

    DATA temp15 TYPE REF TO cl_abap_classdescr.
    temp15 ?= cl_abap_objectdescr=>describe_by_object_ref( io_app ).
    DATA lt_attri LIKE temp15->attributes.
    lt_attri = temp15->attributes.

    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public.

    DATA ls_attri LIKE LINE OF lt_attri.
    LOOP AT lt_attri INTO ls_attri
      WHERE type_kind = cl_abap_classdescr=>typekind_struct2
         OR type_kind = cl_abap_classdescr=>typekind_struct1.

      DELETE lt_attri INDEX sy-tabix.

      INSERT LINES OF _get_t_attri_by_struc(
        io_app = io_app
        iv_attri = ls_attri-name ) INTO TABLE lt_attri.

    ENDLOOP.

    LOOP AT lt_attri INTO ls_attri.

      DATA temp16 TYPE ty_attri.
      CLEAR temp16.
      DATA ls_attri2 LIKE temp16.
      ls_attri2 = temp16.
      MOVE-CORRESPONDING ls_attri TO ls_attri2.

      FIELD-SYMBOLS <any> TYPE any.
      UNASSIGN <any>.
      DATA lv_assign TYPE string.
      lv_assign = `IO_APP->` && ls_attri-name.
      ASSIGN (lv_assign) TO <any>.
      DATA lo_descr TYPE REF TO cl_abap_typedescr.
      lo_descr = cl_abap_datadescr=>describe_by_data( <any> ).
      CASE lo_descr->kind.
        WHEN lo_descr->kind_elem.
          DATA temp17 TYPE REF TO cl_abap_elemdescr.
          temp17 ?= lo_descr.
          ls_attri2-type =  temp17->get_relative_name( ).
      ENDCASE.

      APPEND ls_attri2 TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD _get_t_attri_by_struc.

    CONSTANTS c_prefix TYPE string VALUE `IO_APP->`.
    FIELD-SYMBOLS <attribute> TYPE any.

    DATA lv_name TYPE string.
    lv_name = c_prefix && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    DATA lo_type TYPE REF TO cl_abap_typedescr.
    lo_type = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA temp2 TYPE REF TO cl_abap_structdescr.
    temp2 ?= lo_type.
    DATA lo_struct LIKE temp2.
    lo_struct = temp2.

    DATA temp3 TYPE abap_component_tab.
    temp3 = lo_struct->get_components( ).
    DATA temp1 LIKE LINE OF temp3.
    DATA lr_comp LIKE REF TO temp1.
    LOOP AT temp3 REFERENCE INTO lr_comp.

      DATA lv_element TYPE string.
      lv_element = iv_attri && `-` && lr_comp->name.

      IF lr_comp->as_include = abap_true.
        INSERT LINES OF _get_t_attri_by_struc( io_app   = io_app
                                      iv_attri = lv_element ) INTO TABLE result.

      ELSE.
        DATA temp4 TYPE abap_attrdescr.
        CLEAR temp4.
        temp4-name = lv_element.
        temp4-type_kind = lr_comp->type->type_kind.
        INSERT temp4 INTO TABLE result.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD trans_any_2_json.

    result = /ui2/cl_json=>serialize( any ).

  ENDMETHOD.


  METHOD trans_object_2_xml.

    FIELD-SYMBOLS <object> TYPE any.
    ASSIGN object->* TO <object>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    CALL TRANSFORMATION id
       SOURCE data = <object>
       RESULT XML result
        OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.

    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.
    ASSIGN ir_tab_from->* TO <lt_from>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    CLEAR t_result.

    DATA temp2 TYPE REF TO cl_abap_tabledescr.
    temp2 ?= cl_abap_datadescr=>describe_by_data( t_result ).
    DATA lo_tab LIKE temp2.
    lo_tab = temp2.
    DATA temp3 TYPE REF TO cl_abap_structdescr.
    temp3 ?= lo_tab->get_table_line_type( ).
    DATA lo_struc LIKE temp3.
    lo_struc = temp3.
    DATA lt_components TYPE abap_component_tab.
    lt_components = lo_struc->get_components( ).

    DATA lr_from LIKE LINE OF <lt_from>.
    LOOP AT <lt_from> INTO lr_from.

      DATA lr_row TYPE REF TO data.
      CREATE DATA lr_row LIKE LINE OF t_result.
      FIELD-SYMBOLS <row> TYPE any.
      ASSIGN lr_row->* TO <row>.

      FIELD-SYMBOLS <row_ui5> TYPE any.
      ASSIGN lr_from->* TO <row_ui5>.
      raise( when = boolc( sy-subrc <> 0 ) ).

      DATA ls_comp LIKE LINE OF lt_components.
      LOOP AT lt_components INTO ls_comp.

        FIELD-SYMBOLS <comp> TYPE data.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <comp>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        FIELD-SYMBOLS <comp_ui5> TYPE data.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row_ui5> TO <comp_ui5>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        FIELD-SYMBOLS <ls_data_ui5> TYPE any.
        ASSIGN <comp_ui5>->* TO <ls_data_ui5>.
        IF sy-subrc = 0.
          <comp> = <ls_data_ui5>.
        ENDIF.
      ENDLOOP.

      INSERT <row> INTO TABLE t_result.
    ENDLOOP.

  ENDMETHOD.

  METHOD trans_xml_2_object.

    CALL TRANSFORMATION id
       SOURCE XML xml
       RESULT data = data.

  ENDMETHOD.

  METHOD get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text( ).
      DATA error LIKE abap_true.
      error = abap_true.
    ELSEIF ms_error-s_msg-message IS NOT INITIAL.
      result = ms_error-s_msg-message.
      error = abap_true.
    ENDIF.

    IF error = abap_true AND result IS INITIAL.
      result = `unknown error`.
    ENDIF.

  ENDMETHOD.

  METHOD raise.

    IF when = abap_false.
      RETURN.
    ENDIF.
    RAISE EXCEPTION TYPE z2ui5_lcl_utility EXPORTING val = v.

  ENDMETHOD.
ENDCLASS.


CLASS z2ui5_lcl_utility_tree_json DEFINITION.

  PUBLIC SECTION.

    DATA mo_root TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mo_parent TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mv_name   TYPE string.
    DATA mv_value  TYPE string.
    DATA mt_values TYPE STANDARD TABLE OF REF TO z2ui5_lcl_utility_tree_json WITH DEFAULT KEY.
    DATA mv_check_list TYPE abap_bool.
    DATA mr_actual TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.

    CLASS-METHODS new
      IMPORTING
        io_root       TYPE REF TO z2ui5_lcl_utility_tree_json
        iv_name       TYPE simple
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    CLASS-METHODS factory
      IMPORTING
        iv_json       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS constructor.

    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS get_attribute
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS get_val
      RETURNING
        VALUE(result) TYPE string.

    METHODS add_list_val
      IMPORTING
        v             TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute
      IMPORTING
        n             TYPE clike
        v             TYPE clike
        apos_active   TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_object
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_struc
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_list_object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_list_list
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_list
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_instance
      IMPORTING
        val           TYPE REF TO z2ui5_lcl_utility_tree_json
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.


  PROTECTED SECTION.

    METHODS wrap_json
      IMPORTING
        iv_text       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS quote_json
      IMPORTING
        iv_text       TYPE string
        iv_cond       TYPE abap_bool
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_lcl_utility_tree_json IMPLEMENTATION.


  METHOD add_attribute.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = n ).

    IF apos_active = abap_false.
      lo_attri->mv_value = v.
    ELSE.
      lo_attri->mv_value = escape( val = v format = cl_abap_format=>e_json_string ).
    ENDIF.
    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.
    result = me.

  ENDMETHOD.


  METHOD add_attribute_instance.

    val->mo_root = mo_root.
    val->mo_parent = me.
    INSERT val INTO TABLE mt_values.
    result = val.

  ENDMETHOD.


  METHOD add_attribute_list.

    result = add_attribute_object( name ).
    result->mv_check_list = abap_true.

  ENDMETHOD.


  METHOD add_attribute_struc.

    FIELD-SYMBOLS <value> TYPE any.
    DATA temp18 TYPE REF TO cl_abap_structdescr.
    temp18 ?= cl_abap_datadescr=>describe_by_data( val ).
    DATA lo_struc LIKE temp18.
    lo_struc = temp18.
    DATA lt_comp TYPE abap_component_tab.
    lt_comp = lo_struc->get_components( ).

    DATA temp19 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp19.
    LOOP AT lt_comp REFERENCE INTO lr_comp.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE val TO <value>.
      add_attribute( n = lr_comp->name v = <value> ).
    ENDLOOP.

    result = me.

  ENDMETHOD.

  METHOD add_attribute_object.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = name ).
    DATA temp20 LIKE mt_values.
    CLEAR temp20.
    temp20 = mt_values.
    INSERT lo_attri INTO TABLE temp20.
    mt_values = temp20.
    lo_attri->mo_parent = me.
    result = lo_attri.

  ENDMETHOD.


  METHOD add_list_list.

    DATA temp22 TYPE string.
    temp22 = lines( mt_values ).
    result = add_attribute_list( temp22 ).

  ENDMETHOD.


  METHOD add_list_object.

    DATA temp23 TYPE string.
    temp23 = lines( mt_values ).
    result = add_attribute_object( temp23 ).

  ENDMETHOD.


  METHOD add_list_val.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = lines( mt_values ) ).
    lo_attri->mv_value = v.
    lo_attri->mv_apost_active = abap_true.

    DATA temp24 LIKE mt_values.
    CLEAR temp24.
    temp24 = mt_values.
    INSERT lo_attri INTO TABLE temp24.
    mt_values = temp24.
    lo_attri->mo_parent = me.
    result = lo_attri.
    result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    CREATE OBJECT result.
    result->mo_root = result.

    DATA temp26 TYPE string.
    temp26 = iv_json.
    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = temp26
            assoc_arrays = abap_true
        "    conversion_exits = abap_true
        CHANGING
         data            = result->mr_actual
        ).

  ENDMETHOD.

  METHOD new.

    CREATE OBJECT result.
    result->mo_root = io_root.
    DATA temp27 TYPE string.
    temp27 = iv_name.
    result->mv_name = temp27.

  ENDMETHOD.

  METHOD get_attribute.

    CONSTANTS c_prefix TYPE string VALUE `MR_ACTUAL->`.

    z2ui5_lcl_utility=>raise( when = boolc( mr_actual IS INITIAL ) ).

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = name ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA lv_name TYPE string.
    lv_name = c_prefix && replace( val = name sub = `-` with = `_` occ = 0 ).
    " DATA(lv_name) = c_prefix && replace( val = name sub = `-` with = `_` occ = 0 ).
    ASSIGN (lv_name) TO <attribute>.
    z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).

    lo_attri->mr_actual = <attribute>.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    result = lo_attri.

  ENDMETHOD.

  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) v = `Value of Attribute in JSON not found` ).

    result = <attribute>.

  ENDMETHOD.


  METHOD get_root.

    result = mo_root.

  ENDMETHOD.


  METHOD wrap_json.

    DATA temp28 TYPE string.
    CASE mv_check_list.
      WHEN abap_true.
        temp28 = |[ { iv_text }]|.
      WHEN OTHERS.
        temp28 = `{` && iv_text && `}`.
    ENDCASE.
    result = temp28.

  ENDMETHOD.

  METHOD quote_json.

    DATA temp29 TYPE string.
    CASE iv_cond.
      WHEN abap_true.
        temp29 = `"` && iv_text && `"`.
      WHEN OTHERS.
        temp29 = iv_text.
    ENDCASE.
    result = temp29.

  ENDMETHOD.

  METHOD stringify.

    DATA lo_attri LIKE LINE OF mt_values.
    LOOP AT mt_values INTO lo_attri.

      IF sy-tabix > 1.
        result = result && |,|.
      ENDIF.

      IF mv_check_list = abap_false.
        result = |{ result }"{ lo_attri->mv_name }":|.
      ENDIF.


      IF lo_attri->mt_values IS NOT INITIAL.
        result = result && lo_attri->stringify( ).
      ELSE.
        result = result &&
           quote_json( iv_cond = boolc( lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL )
                       iv_text = lo_attri->mv_value ).
      ENDIF.

    ENDLOOP.

    result = wrap_json( result ).
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_handler DEFINITION DEFERRED.

CLASS z2ui5_lcl_fw_handler DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF cs_bind_type.

    TYPES:
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,

        t_attri           TYPE z2ui5_lcl_utility=>ty_t_attri,
        o_app             TYPE REF TO z2ui5_if_app,
      END OF ty_s_db.
    DATA ms_db TYPE ty_s_db.

    TYPES:
      BEGIN OF ty_s_next,
        check_app_leave TYPE abap_bool,
        o_call_app      TYPE REF TO z2ui5_if_app,
        s_set           TYPE z2ui5_if_client=>ty_S_next,
        BEGIN OF s_msg,
          control TYPE string,
          type    TYPE string,
          text    TYPE string,
        END OF s_msg,
      END OF ty_s_next.

    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-DATA mo_body TYPE REF TO z2ui5_lcl_utility_tree_json.

    CLASS-METHODS request_begin
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS request_end
      RETURNING
        VALUE(result) TYPE string.

    METHODS _create_binding
      IMPORTING
        value          TYPE data
        type           TYPE string DEFAULT cs_bind_type-two_way
        check_gen_data TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result)  TYPE string.

    CLASS-METHODS set_app_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    CLASS-METHODS set_app_client
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_system
      IMPORTING
        VALUE(ix)     TYPE REF TO cx_root OPTIONAL
        error_text    TYPE string OPTIONAL
          PREFERRED PARAMETER ix
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS request_end_model
      RETURNING
        VALUE(r_view_model) TYPE REF TO z2ui5_lcl_utility_tree_json.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_lcl_fw_db DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        id TYPE string
        db TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.

CLASS z2ui5_lcl_fw_app DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF ms_error,
        x_error   TYPE REF TO cx_root,
        app       TYPE REF TO z2ui5_if_app,
        classname TYPE string,
        kind      TYPE string,
      END OF ms_error.

    DATA:
      BEGIN OF ms_home,
        is_initialized         TYPE abap_bool,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

    CLASS-METHODS factory_error
      IMPORTING
        error         TYPE REF TO cx_root
        app           TYPE REF TO object OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_app.

    DATA mv_is_initialized TYPE abap_bool.
    DATA mv_view_name TYPE string.

    METHODS z2ui5_on_init.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

ENDCLASS.

CLASS z2ui5_lcl_fw_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF mv_is_initialized = abap_false.
      mv_is_initialized = abap_true.
      z2ui5_on_init(  ).
    ENDIF.

    z2ui5_on_event( client ).
    z2ui5_on_rendering( client ).

  ENDMETHOD.

  METHOD factory_error.

    CREATE OBJECT result.
    result->ms_error-x_error = error.
    DATA temp30 TYPE REF TO z2ui5_if_app.
    temp30 ?= app.
    result->ms_error-app     = temp30.

  ENDMETHOD.


  METHOD z2ui5_on_init.
    IF ms_error-x_error IS NOT BOUND.
      mv_view_name = 'HOME'.
      ms_home-is_initialized = abap_true.
      ms_home-btn_text = `check`.
      ms_home-btn_event_id = `BUTTON_CHECK`.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = `sap-icon://validate`.
      ms_home-classname = `z2ui5_cl_app_hello_world`.
    ELSE.
      mv_view_name = 'ERROR'.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE mv_view_name.

      WHEN `HOME`.
        CASE client->get( )-event.

          WHEN `BUTTON_CHANGE`.
            ms_home-btn_text = `check`.
            ms_home-btn_event_id = `BUTTON_CHECK`.
            ms_home-btn_icon = `sap-icon://validate`.
            ms_home-class_editable = abap_true.

          WHEN `BUTTON_CHECK`.
            TRY.
                DATA li_app_test TYPE REF TO z2ui5_if_app.
                ms_home-classname = z2ui5_lcl_utility=>get_trim_upper( ms_home-classname ).
                CREATE OBJECT li_app_test TYPE (ms_home-classname).

                client->popup_message_toast( `App is ready to start!` ).
                ms_home-btn_text = `edit`.
                ms_home-btn_event_id = `BUTTON_CHANGE`.
                ms_home-btn_icon = `sap-icon://edit`.
                ms_home-class_value_state = `Success`.
                ms_home-class_editable = abap_false.

                DATA lx TYPE REF TO cx_root.
              CATCH cx_root INTO lx.
                ms_home-class_value_state_text = lx->get_text( ).
                ms_home-class_value_state = `Warning`.
                client->popup_message_box( text = ms_home-class_value_state_text type = `error` ).
            ENDTRY.

          WHEN `DEMOS`.
            DATA li_app TYPE REF TO z2ui5_if_app.
            TRY.
                CREATE OBJECT li_app TYPE (`Z2UI5_CL_APP_DEMO_00`).
                client->nav_app_call( li_app ).
              CATCH cx_root.
                client->popup_message_box( `Demos not available. Check the demo folder or you release is lower v750` ).
            ENDTRY.
        ENDCASE.

      WHEN `ERROR`.
        CASE client->get( )-event.

          WHEN `BUTTON_HOME`.
            client->nav_app_home( ).

          WHEN `BUTTON_BACK`.
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app ) ).

        ENDCASE.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    IF ms_error-x_error IS BOUND.

      DATA lv_prog TYPE syrepid.
      DATA lv_incl TYPE syrepid.
      DATA lv_line TYPE i.
      ms_error-x_error->get_source_position(
        IMPORTING
          program_name = lv_prog
          include_name = lv_incl
          source_line  = lv_line
      ).

      IF  client->get_app( client->get( )-id_prev_app ) IS BOUND.
        DATA lv_check_back TYPE string.
        lv_check_back = `true`.
      ELSE.
        lv_check_back = `false`.
      ENDIF.

      DATA lv_descr TYPE string.
      lv_descr = ms_error-x_error->get_text( ) &&
            ` -------------------------------------------------------------------------------------------- Source Code Position: ` &&
            lv_prog && ` / ` && lv_incl && ` / ` && lv_line && ` `.

      DATA lv_xml_error TYPE string.
      lv_xml_error = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mv` &&
  `c" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <MessagePage ` && |\n|
  &&
                           `  description="` &&  lv_descr && `" ` && |\n|  &&
                           `  icon="sap-icon://message-error" ` && |\n|  &&
                           `  text="500 Internal Server Error" ` && |\n|  &&
                           `  enableFormattedText="true" ` && |\n|  &&
                           ` > <buttons ` && |\n|  &&
                           ` > <Button ` && |\n|  &&
                           `  press="` &&  client->_event( `BUTTON_HOME` ) && `" ` && |\n|  &&
                           `  text="HOME" ` && |\n|  &&
                           ` /> <Button ` && |\n|  &&
                           `  press="` &&  client->_event( `BUTTON_BACK` ) && `" ` && |\n|  &&
                           `  text="BACK" ` && |\n|  &&
                           `  type="Emphasized" enabled="` && lv_check_back && `"` && |\n|  &&
                           ` /></buttons></MessagePage></Shell></mvc:View>`.

      DATA temp5 TYPE z2ui5_if_client=>ty_s_next.
      CLEAR temp5.
      temp5-xml_main = lv_xml_error.
      client->set_next( temp5 ).
      RETURN.
    ENDIF.

    TRY.
        DATA lv_url TYPE string.
        DATA temp4 LIKE LINE OF z2ui5_cl_http_handler=>client-t_header.
        DATA temp8 LIKE sy-tabix.
        temp8 = sy-tabix.
        READ TABLE z2ui5_cl_http_handler=>client-t_header WITH KEY name = `referer` INTO temp4.
        sy-tabix = temp8.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
        ENDIF.
        lv_url = to_lower( temp4-value ).
        DATA lv_path_info TYPE string.
        DATA temp9 LIKE LINE OF z2ui5_cl_http_handler=>client-t_header.
        DATA temp10 LIKE sy-tabix.
        temp10 = sy-tabix.
        READ TABLE z2ui5_cl_http_handler=>client-t_header WITH KEY name = `~path_info` INTO temp9.
        sy-tabix = temp10.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
        ENDIF.
        lv_path_info = to_lower( temp9-value ).
        REPLACE lv_path_info IN lv_url WITH ``.
        DATA lv_params TYPE string.
        SPLIT lv_url AT '?' INTO lv_url lv_params.

        SHIFT lv_url RIGHT DELETING TRAILING `/`.
        DATA lv_link TYPE string.
        lv_link = lv_url && `/` && to_lower( ms_home-classname ).
        IF lv_params IS NOT INITIAL.
          lv_link = lv_link  && `?` && lv_params.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

    DATA lv_xml_main TYPE string.
    lv_xml_main = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mvc` &&
`" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|  &&
                        `  showNavButton="false" ` && |\n|  &&
                        `  class="sapUiContentPadding sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" ` && |\n|  &&
                        ` > <headerContent ` && |\n|  &&
                        ` > <Title ` && |\n|  &&
                        ` /> <Title ` && |\n|  &&
                        `  text="abap2UI5 - Development of UI5 Apps in pure ABAP" ` && |\n|  &&
                        ` /> <ToolbarSpacer ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="SCN" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://blogs.sap.com/tag/abap2ui5/" ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="Twitter" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://twitter.com/OblomovDev" ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="GitHub" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://github.com/oblomov-dev/abap2ui5" ` && |\n|  &&
                        ` /></headerContent>`.



    lv_xml_main = lv_xml_main && ` <l:Grid ` && |\n|  &&
    `  defaultSpan="XL7 L7 M12 S12" ` && |\n|  &&
    ` > <l:content ` && |\n|  &&
    ` > <f:SimpleForm ` && |\n|  &&
    `  title="Quick Start" ` && |\n|  &&
    `  layout="ResponsiveGridLayout" ` && |\n|  &&
    `  editable="true" ` && |\n|  &&
    ` > <f:content ` && |\n|  &&
    ` > <Label ` && |\n|  &&
    `  text="Step 1" ` && |\n|  &&
    ` /> <Text ` && |\n|  &&
    `  text="Create a global class in your abap system" ` && |\n|  &&
    ` /> <Label ` && |\n|  &&
    `  text="Step 2" ` && |\n|  &&
    ` /> <Text ` && |\n|  &&
    `  text="Add the interface: Z2UI5_IF_APP" ` && |\n|  &&
    ` /> <Label ` && |\n|  &&
    `  text="Step 3" ` && |\n|  &&
    ` /> <Text ` && |\n|  &&
    `  text="Define view, implement behaviour" ` && |\n|  &&
    ` /> <Link ` && |\n|  &&
    `  text="(Example)" ` && |\n|  &&
    `  target="_blank" ` && |\n|  &&
    `  href="https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/z2ui5_cl_app_hello_world.clas.abap" ` && |\n|  &&
    ` /> <Label ` && |\n|  &&
    `  text="Step 4" ` && |\n|  &&
    ` /> `.

    IF ms_home-class_editable = abap_true.
      lv_xml_main = lv_xml_main &&   `<Input ` && |\n|  &&
     `  placeholder="` && `fill in the class name and press 'check' ` && `" ` && |\n|  &&
     `  editable="` && z2ui5_lcl_utility=>get_json_boolean( ms_home-class_editable ) && `" ` && |\n|  &&
     `  value="` && client->_bind( ms_home-classname ) && `" ` && |\n|  &&
     ` /> `.
    ELSE.
      lv_xml_main = lv_xml_main &&   `<Text ` && |\n|  &&
      `  text=" ` && ms_home-classname && `" /> `.

    ENDIF.


    lv_xml_main = lv_xml_main &&  `<Button ` && |\n|  &&
       `  press="`  && client->_event( ms_home-btn_event_id ) && `" ` && |\n|  &&
       `  text="` && ms_home-btn_text && `" ` && |\n|  &&
       `  icon="` &&  ms_home-btn_icon && `" ` && |\n|  &&
       ` /> <Label ` && |\n|  &&
       `  text="Step 5" ` && |\n|  &&
       ` /> <Link ` && |\n|  &&
       `  text="Link to the Application" ` && |\n|  &&
       `  target="_blank" ` && |\n|  &&
       `  href="` && escape( val = lv_link format = cl_abap_format=>e_xml_attr ) && `" ` && |\n|  &&
       `  enabled="` && z2ui5_lcl_utility=>get_json_boolean( boolc( ms_home-class_editable = abap_false ) ) && `" ` && |\n|  &&
       ` /></f:content></f:SimpleForm>`.



    lv_xml_main = lv_xml_main && `<f:SimpleForm ` && |\n|  &&
   `  title="Demo Section" ` && |\n|  &&
   `  layout="ResponsiveGridLayout" ` && |\n|  &&
   ` >`.

    DATA li_app TYPE REF TO z2ui5_if_app.
    TRY.
        CREATE OBJECT li_app TYPE (`Z2UI5_CL_APP_DEMO_00`).
        DATA lv_check_demo LIKE abap_true.
        lv_check_demo = abap_true.
      CATCH cx_root.
        lv_check_demo = abap_false.
    ENDTRY.
    IF lv_check_demo = abap_false.
      lv_xml_main = lv_xml_main && `<MessageStrip text="The abap2UI5 demos aren't ready! Make sure to install this additional demo repository." type="Warning" > <link> ` &&
         `   <Link text="(LINK)"  target="_blank" href="https://github.com/oblomov-dev/abap2UI5-demos" /> ` &&
      `  </link> </MessageStrip>`.
    ENDIF.

    DATA temp6 TYPE string.
    IF lv_check_demo = abap_true.
      temp6 = `true`.
    ELSE.
      temp6 = `false`.
    ENDIF.
    lv_xml_main = lv_xml_main && ` <f:content ` && |\n|  &&
    ` > <Label/><Button ` && |\n|  &&
    `  press="` && client->_event( `DEMOS` ) && `" ` && |\n|  &&
    `  text="Continue..." enabled="` && temp6 && |" \n|  &&
    ` /></f:content></f:SimpleForm></l:content></l:Grid></Page></Shell></mvc:View>`.

    DATA temp7 TYPE z2ui5_if_client=>ty_s_next.
    CLEAR temp7.
    temp7-xml_main = lv_xml_main.
    client->set_next( temp7 ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_db IMPLEMENTATION.

  METHOD load_app.

    DATA ls_db TYPE z2ui5_t_draft.
    ls_db = read( id ).

    z2ui5_lcl_utility=>trans_xml_2_object(
      EXPORTING
        xml    = ls_db-data
      IMPORTING
        data   = result ).

  ENDMETHOD.

  METHOD create.

    DATA temp8 TYPE REF TO object.
    temp8 ?= db-o_app.
    DATA lo_app LIKE temp8.
    lo_app = temp8.

    DATA temp9 LIKE LINE OF db-t_attri.
    DATA lr_attri LIKE REF TO temp9.
    LOOP AT db-t_attri REFERENCE INTO lr_attri WHERE gen_type IS NOT INITIAL.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = 'LO_APP->' && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      CLEAR <attribute>.

    ENDLOOP.

    DATA temp10 LIKE REF TO db.
    GET REFERENCE OF db INTO temp10.
DATA temp11 TYPE z2ui5_t_draft.
CLEAR temp11.
temp11-uuid = id.
temp11-uuid_prev = db-id_prev.
temp11-uuid_prev_app = db-id_prev_app.
temp11-uuid_prev_app_stack = db-id_prev_app_stack.
temp11-uname = z2ui5_lcl_utility=>get_user_tech( ).
temp11-timestampl = z2ui5_lcl_utility=>get_timestampl( ).
temp11-data = z2ui5_lcl_utility=>trans_object_2_xml( temp10 ).
DATA ls_db LIKE temp11.
ls_db = temp11.

    MODIFY z2ui5_t_draft FROM ls_db.
    z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    IF check_load_app = abap_true.

      SELECT SINGLE *
        FROM z2ui5_t_draft
      INTO result
      WHERE uuid = id.
      z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).

    ELSE.

      SELECT SINGLE uuid uuid_prev uuid_prev_app uuid_prev_app_stack
        FROM z2ui5_t_draft
        INTO CORRESPONDING FIELDS OF result
        WHERE uuid = id.
      z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).

    ENDIF.

  ENDMETHOD.

  METHOD cleanup.

    DATA lv_timestampl TYPE timestampl.

    DATA lv_time LIKE sy-uzeit.
    lv_time = sy-uzeit.
    lv_time = lv_time - ( 60 * 60 * 4 ).

    CONVERT DATE sy-datum TIME lv_time
       INTO TIME STAMP lv_timestampl TIME ZONE sy-zonlo.

    DELETE FROM z2ui5_t_draft WHERE timestampl < lv_timestampl.
    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_handler TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS constructor
      IMPORTING
        handler TYPE REF TO z2ui5_lcl_fw_handler.

ENDCLASS.

CLASS z2ui5_lcl_fw_handler IMPLEMENTATION.

  METHOD request_begin.

    mo_body = z2ui5_lcl_utility_tree_json=>factory( z2ui5_cl_http_handler=>client-body ).

    TRY.
        DATA lv_id_prev TYPE string.
        lv_id_prev = mo_body->get_attribute( `ID` )->get_val( ).
      CATCH cx_root.
        result = set_app_start( ).
        RETURN.
    ENDTRY.

    result = set_app_client( lv_id_prev ).

  ENDMETHOD.


  METHOD request_end.

    IF ms_next-s_set-path IS NOT INITIAL.
      DATA lv_path TYPE z2ui5_if_client=>ty_s_name_value-value.
      lv_path = z2ui5_lcl_utility=>get_header_val( '~path' ).
      DATA lv_path_info TYPE z2ui5_if_client=>ty_s_name_value-value.
      lv_path_info = z2ui5_lcl_utility=>get_header_val( '~path_info' ).
      REPLACE lv_path_info IN lv_path WITH ``.
      SHIFT lv_path RIGHT DELETING TRAILING `/`.
      SHIFT lv_path LEFT DELETING LEADING ` `.
      ms_next-s_set-path = lv_path && ms_next-s_set-path.
    ENDIF.

    DATA lo_resp TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_resp = z2ui5_lcl_utility_tree_json=>factory( ).
    lo_resp->add_attribute( n = `PARAMS` v = z2ui5_lcl_utility=>trans_any_2_json( ms_next-s_set ) apos_active = abap_false ).
    lo_resp->add_attribute( n = `S_MSG`  v = z2ui5_lcl_utility=>trans_any_2_json( ms_next-s_msg ) apos_active = abap_false ).
    lo_resp->add_attribute( n = `ID`   v = ms_db-id ).
    lo_resp->add_attribute_object( `OVIEWMODEL` )->add_attribute_instance( request_end_model( ) ).
    result = lo_resp->get_root( )->stringify( ).
    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.


  METHOD set_app_client.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    CREATE OBJECT result.
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).
    DATA lv_id LIKE result->ms_db-id.
    lv_id = result->ms_db-id.
    result->ms_db = z2ui5_lcl_fw_db=>load_app( id_prev ).
    result->ms_db-id = lv_id.
    result->ms_db-id_prev = id_prev.

    DATA temp11 TYPE REF TO object.
    temp11 ?= result->ms_db-o_app.
    DATA lo_app LIKE temp11.
    lo_app = temp11.

    TRY.

        DATA lo_model TYPE REF TO z2ui5_lcl_utility_tree_json.
        lo_model = mo_body->get_attribute( `OUPDATE` ).

        DATA temp12 LIKE LINE OF result->ms_db-t_attri.
        DATA lr_attri LIKE REF TO temp12.
        LOOP AT result->ms_db-t_attri REFERENCE INTO lr_attri
            WHERE bind_type = cs_bind_type-two_way.

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA lv_name TYPE string.
          lv_name = c_prefix && to_upper( lr_attri->name ).
          ASSIGN (lv_name) TO <attribute>.
          z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).

          IF lr_attri->gen_kind IS NOT INITIAL.

            CASE lr_attri->gen_kind.
              WHEN cl_abap_datadescr=>kind_elem.
                CREATE DATA <attribute> TYPE (lr_attri->gen_type).
                ASSIGN <attribute>->* TO <attribute>.
              WHEN cl_abap_datadescr=>kind_table.
                DATA lr_data TYPE REF TO data.
                CREATE DATA lr_data TYPE (lr_attri->gen_type).
                FIELD-SYMBOLS <field> TYPE any.
                ASSIGN lr_data->* TO <field>.
                CREATE DATA <attribute> LIKE STANDARD TABLE OF <field>.
                ASSIGN <attribute>->* TO <attribute>.
            ENDCASE.
          ENDIF.

          CASE lr_attri->type_kind.

            WHEN `h`.
              z2ui5_lcl_utility=>trans_ref_tab_2_tab(
                   EXPORTING ir_tab_from = lo_model->get_attribute( lr_attri->name )->mr_actual
                   IMPORTING t_result    = <attribute> ).

            WHEN OTHERS.

              DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
              lo_attri = lo_model->get_attribute( lr_attri->name ).
              FIELD-SYMBOLS <val> TYPE any.
              ASSIGN lo_attri->mr_actual->* TO <val>.

              CASE lr_attri->type_kind.
                WHEN 'D' OR 'T'.
                  /ui2/cl_json=>deserialize(
                      EXPORTING
                        json             = `"` && <val> && `"`
                      CHANGING
                        data             = <attribute>  ).
                  " WHEN 'C'.
                  "  CASE lr_attri->type.
                  "   WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
                  "     <attribute> = xsdbool( <val> = `true` ).
                  "    WHEN OTHERS.
                  "      <attribute> = <val>.
                  "°  ENDCASE.
                WHEN OTHERS.
                  <attribute> = <val>.
              ENDCASE.
          ENDCASE.
        ENDLOOP.

      CATCH cx_root.
    ENDTRY.

    TRY.
        result->ms_actual-event = mo_body->get_attribute( `OEVENT` )->get_attribute( `EVENT` )->get_val( ).
        result->ms_actual-event_data = mo_body->get_attribute( `OEVENT` )->get_attribute( `vData` )->get_val( ).
        result->ms_actual-event_data2 = mo_body->get_attribute( `OEVENT` )->get_attribute( `vData2` )->get_val( ).
        result->ms_actual-event_data3 = mo_body->get_attribute( `OEVENT` )->get_attribute( `vData3` )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA lo_scroll TYPE REF TO z2ui5_lcl_utility_tree_json.
        lo_scroll = mo_body->get_attribute( `OSCROLL` ).
        z2ui5_lcl_utility=>trans_ref_tab_2_tab(
            EXPORTING ir_tab_from = lo_scroll->mr_actual
            IMPORTING t_result    = result->ms_actual-t_scroll_pos ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_start.

    CREATE OBJECT result.
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).

    TRY.
        DATA lv_path_info TYPE z2ui5_if_client=>ty_s_name_value-value.
        lv_path_info = z2ui5_lcl_utility=>get_header_val( '~path_info' ).
      CATCH cx_root.
    ENDTRY.

    DATA lv_dummy TYPE string.
    SPLIT lv_path_info AT `?` INTO lv_path_info lv_dummy.
    DATA lv_classname TYPE string.
    lv_classname = z2ui5_lcl_utility=>get_trim_upper( lv_path_info ).
    SHIFT lv_classname LEFT DELETING LEADING `/`.

    IF lv_classname IS INITIAL.
      result = result->set_app_system( ).
      RETURN.
    ENDIF.

    TRY.

        TRY.
            CREATE OBJECT result->ms_db-o_app TYPE (lv_classname).
          CATCH cx_root.
            SPLIT lv_classname AT `/` INTO lv_classname lv_dummy.
            CREATE OBJECT result->ms_db-o_app TYPE (lv_classname).
        ENDTRY.
        result->ms_db-o_app->id = result->ms_db-id.
        result->ms_db-t_attri   = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
        RETURN.

      CATCH cx_root.
        result = result->set_app_system( error_text = `class with name ` && lv_classname && ` not found` ).
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD set_app_leave.

    CREATE OBJECT result.

    result->ms_db-o_app = ms_next-o_call_app.

    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

    DATA ls_draft TYPE z2ui5_t_draft.
    ls_draft = z2ui5_lcl_fw_db=>read( id = result->ms_db-o_app->id check_load_app = abap_false ).
    result->ms_db-id_prev_app_stack = ls_draft-uuid_prev_app_stack.

    result->ms_db-t_attri     = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_db-id          = z2ui5_lcl_utility=>get_uuid( ).
    result->ms_db-o_app->id   = result->ms_db-id.
    result->ms_db-id_prev_app = ms_db-id.
    result->ms_db-id_prev     = ms_db-id.

    "    result->ms_next-s_set-path = `test`. "ms_next-s_set-path.
    CLEAR ms_next.

  ENDMETHOD.

  METHOD set_app_call.

    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

    CREATE OBJECT result.
    result->ms_db-id        = z2ui5_lcl_utility=>get_uuid( ).
    result->ms_db-o_app     = ms_next-o_call_app.
    result->ms_db-o_app->id = result->ms_db-id.

    result->ms_db-id_prev_app       = ms_db-id.
    result->ms_db-id_prev_app_stack = ms_db-id.

    result->ms_next-s_msg = ms_next-s_msg.

    result->ms_db-t_attri = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    CLEAR ms_next.

  ENDMETHOD.

  METHOD _create_binding.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    DATA temp13 TYPE REF TO object.
    temp13 ?= ms_db-o_app.
    DATA lo_app LIKE temp13.
    lo_app = temp13.

    IF type = cs_bind_type-one_time.
      DATA lv_id TYPE string.
      lv_id = z2ui5_lcl_utility=>get_uuid_session( ).
      DATA temp14 TYPE z2ui5_lcl_utility=>ty_attri.
      CLEAR temp14.
      temp14-name = lv_id.
      temp14-data_stringify = z2ui5_lcl_utility=>trans_any_2_json( value ).
      temp14-bind_type = type.
      INSERT temp14 INTO TABLE ms_db-t_attri.
      result = |/{ lv_id }|.
      RETURN.
    ENDIF.

    DATA lr_in type REF TO data.
    GET REFERENCE OF value INTO lr_in.

    DATA temp15 LIKE LINE OF ms_db-t_attri.
    DATA lr_attri LIKE REF TO temp15.
    LOOP AT ms_db-t_attri REFERENCE INTO lr_attri
        WHERE bind_type <> cs_bind_type-one_time.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).
      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF  <attribute> INTO lr_ref.

      IF check_gen_data = abap_true.
        TRY.
            FIELD-SYMBOLS <field> TYPE any.
            ASSIGN lr_ref->* TO <field>.
            DATA temp16 TYPE REF TO data.
            temp16 ?= <field>.
            lr_ref = temp16.
            IF lr_attri->gen_type IS INITIAL.
              FIELD-SYMBOLS <field2> TYPE any.
              ASSIGN lr_ref->* TO <field2>.
              DATA lo_datadescr TYPE REF TO cl_abap_typedescr.
              lo_datadescr = cl_abap_datadescr=>describe_by_data( <field2> ).
              lr_attri->gen_type_kind = lo_datadescr->type_kind.
              lr_attri->gen_kind = lo_datadescr->kind.
              CASE lo_datadescr->kind.
                WHEN lo_datadescr->kind_elem.
                  DATA lv_dummy TYPE string.
                  SPLIT lo_datadescr->absolute_name AT '=' INTO lv_dummy  lr_attri->gen_type.
                WHEN lo_datadescr->kind_table.
                  DATA temp17 TYPE REF TO cl_abap_tabledescr.
                  temp17 ?= lo_datadescr.
                  DATA lo_tab LIKE temp17.
                  lo_tab = temp17.
                  DATA lo_struc TYPE REF TO cl_abap_datadescr.
                  lo_struc = lo_tab->get_table_line_type( ).
                  SPLIT lo_struc->absolute_name AT '=' INTO lv_dummy lr_attri->gen_type.
              ENDCASE.
            ENDIF.
          CATCH cx_root.
            CONTINUE.
        ENDTRY.
      ENDIF.

      IF lr_in = lr_ref.
        IF lr_attri->bind_type IS NOT INITIAL AND lr_attri->bind_type <> type.
          z2ui5_lcl_utility=>raise( `Binding Error - two diffferent binding types for same attribute (` && lr_attri->name && `) used` ).
        ENDIF.
        lr_attri->bind_type = type.
        DATA temp18 TYPE string.
        IF type = cs_bind_type-two_way.
          temp18 = `/oUpdate/`.
        ELSE.
          temp18 = `/`.
        ENDIF.
        result = temp18 && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    IF type = cs_bind_type-two_way.
      z2ui5_lcl_utility=>raise( `Binding Error - two way binding used but no attribute found` ).
    ENDIF.

    "one time when not global class attribute
    lv_id = z2ui5_lcl_utility=>get_uuid_session( ).
    DATA temp19 TYPE z2ui5_lcl_utility=>ty_attri.
    CLEAR temp19.
    temp19-name = lv_id.
    temp19-data_stringify = z2ui5_lcl_utility=>trans_any_2_json( value ).
    temp19-bind_type = cs_bind_type-one_time.
    INSERT temp19 INTO TABLE ms_db-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.


  METHOD set_app_system.

    IF ms_db-o_app  IS BOUND.
      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

    CREATE OBJECT result.
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      CREATE OBJECT ix TYPE z2ui5_lcl_utility EXPORTING val = error_text.
    ENDIF.

    IF ix IS BOUND.

      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
      result->ms_db-o_app = z2ui5_lcl_fw_app=>factory_error( error = ix app = ms_db-o_app ).

      result->ms_db-id_prev_app = ms_db-id.
      result->ms_db-id_prev_app_stack = ms_db-id.
      result->ms_next-s_msg = ms_next-s_msg.
      result->ms_db-id_prev_app = ms_db-id.

    ELSE.
      CREATE OBJECT result->ms_db-o_app TYPE z2ui5_lcl_fw_app.
    ENDIF.

    result->ms_db-t_attri = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_db-o_app->id = result->ms_db-id.

  ENDMETHOD.


  METHOD request_end_model.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    DATA temp20 TYPE REF TO object.
    temp20 ?= ms_db-o_app.
    DATA lo_app LIKE temp20.
    lo_app = temp20.
    r_view_model  = z2ui5_lcl_utility_tree_json=>factory( ).
    r_view_model->mv_name = `oViewModel`.
    DATA lo_update TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_update = r_view_model->add_attribute_object( `oUpdate` ).

    DATA temp21 LIKE LINE OF ms_db-t_attri.
    DATA lr_attri LIKE REF TO temp21.
    LOOP AT ms_db-t_attri REFERENCE INTO lr_attri WHERE bind_type <> ``.

      IF lr_attri->bind_type = cs_bind_type-one_time.
        r_view_model->add_attribute( n = lr_attri->name v = lr_attri->data_stringify apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA temp22 TYPE REF TO z2ui5_lcl_utility_tree_json.
      IF lr_attri->bind_type = cs_bind_type-one_way.
        temp22 = r_view_model.
      ELSE.
        temp22 = lo_update.
      ENDIF.
      DATA lo_actual LIKE temp22.
      lo_actual = temp22.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_lcl_utility=>raise( when = boolc( sy-subrc <> 0 ) ).

      IF lr_attri->gen_kind IS NOT INITIAL.
        lv_name = '<ATTRIBUTE>->*'.
        ASSIGN (lv_name) TO <attribute>.
        lr_attri->type_kind = lr_attri->gen_type_kind.
      ENDIF.

      CASE lr_attri->type_kind.

        WHEN `h`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = z2ui5_lcl_utility=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN OTHERS.

          CASE lr_attri->type.

            WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.

              DATA temp23 TYPE string.
              CASE <attribute>.
                WHEN abap_true.
                  temp23 = `true`.
                WHEN OTHERS.
                  temp23 = `false`.
              ENDCASE.
              lo_actual->add_attribute(
                 n = lr_attri->name
                 v = temp23
                 apos_active = abap_false ).

            WHEN OTHERS.

              lo_actual->add_attribute(
                    n = lr_attri->name
                    v = /ui2/cl_json=>serialize( <attribute> )
                    apos_active = abap_false ).
          ENDCASE.
      ENDCASE.
    ENDLOOP.

    DELETE ms_db-t_attri WHERE bind_type = cs_bind_type-one_time.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_client IMPLEMENTATION.

  METHOD constructor.

    mo_handler = handler.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_message_toast.

    CLEAR mo_handler->ms_next-s_msg.
    mo_handler->ms_next-s_msg-control = `MessageToast`.
    mo_handler->ms_next-s_msg-type = `show`.
    mo_handler->ms_next-s_msg-text = text.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_message_box.

    CLEAR mo_handler->ms_next-s_msg.
    mo_handler->ms_next-s_msg-control = `MessageBox`.
    mo_handler->ms_next-s_msg-type = type.
    mo_handler->ms_next-s_msg-text = text.

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_home.

    DATA temp31 TYPE REF TO z2ui5_lcl_fw_app.
    CREATE OBJECT temp31 TYPE z2ui5_lcl_fw_app.
    z2ui5_if_client~nav_app_call( temp31 ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    DATA temp32 TYPE z2ui5_if_client=>ty_s_get.
    CLEAR temp32.
    MOVE-CORRESPONDING mo_handler->ms_db TO temp32.
    temp32-event = mo_handler->ms_actual-event.
    temp32-event_data = mo_handler->ms_actual-event_data.
    temp32-event_data2 = mo_handler->ms_actual-event_data2.
    temp32-event_data3 = mo_handler->ms_actual-event_data3.
    temp32-t_scroll_pos = mo_handler->ms_actual-t_scroll_pos.
    temp32-t_req_header = z2ui5_cl_http_handler=>client-t_header.
    temp32-t_req_param = z2ui5_cl_http_handler=>client-t_param.
    result = temp32.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    mo_handler->ms_next-o_call_app =  app.

  ENDMETHOD.

  METHOD z2ui5_if_client~set_next.

    mo_handler->ms_next-s_set = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    result =  mo_handler->_create_binding(
        value = val
        type  = z2ui5_lcl_fw_handler=>cs_bind_type-two_way
        check_gen_data = check_gen_data
         ).
    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_one.

    result = mo_handler->_create_binding( value = val type = z2ui5_lcl_fw_handler=>cs_bind_type-one_way ).
    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    IF data IS INITIAL.
      DATA lv_data TYPE string.
      lv_data = `''`.
    ELSE.
      lv_data = data.
    ENDIF.

       IF data2 IS INITIAL.
      DATA lv_data2 TYPE string.
      lv_data2 = `''`.
    ELSE.
      lv_data2 = data2.
    ENDIF.

       IF data3 IS INITIAL.
      DATA lv_data3 TYPE string.
      lv_data3 = `''`.
    ELSE.
      lv_data3 = data3.
    ENDIF.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } , ` && z2ui5_lcl_utility=>get_json_boolean( hold_view )
      &&  ` , ` && lv_data &&  ` , ` && lv_data2 && ` , ` && lv_data3 && ` )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_close_popup.

    result = `onEventFrontend( 'POPUP_CLOSE' )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    z2ui5_if_client~nav_app_call( app ).
    mo_handler->ms_next-check_app_leave = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app.

    DATA temp33 TYPE REF TO z2ui5_if_app.
    temp33 ?= z2ui5_lcl_fw_db=>load_app( id )-o_app.
    result = temp33.

  ENDMETHOD.

ENDCLASS.