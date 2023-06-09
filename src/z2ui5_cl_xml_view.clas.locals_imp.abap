CLASS lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.
    CLASS-METHODS get_json_boolean
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS check_is_boolean
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS get_classname_by_ref
      IMPORTING in            TYPE REF TO object
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS get_replace
      IMPORTING iv_val        TYPE clike
                iv_begin      TYPE clike
                iv_end        TYPE clike
                iv_replace    TYPE clike DEFAULT ''
      RETURNING VALUE(result) TYPE string.

  CLASS-METHODS get_trim_lower
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

ENDCLASS.


CLASS lcl_utility IMPLEMENTATION.
  METHOD get_replace.
    DATA lv_1 TYPE string.
    DATA lv_2 TYPE string.
    DATA lv_dummy TYPE string.
    DATA lv_4 TYPE string.
    result = iv_val.
    
    
    SPLIT result AT iv_begin INTO lv_1 lv_2.
    
    
    SPLIT lv_2 AT iv_end INTO lv_dummy lv_4.
    IF lv_4 IS NOT INITIAL.
      result = lv_1 && iv_replace && lv_4.
    ENDIF.
  ENDMETHOD.

  METHOD get_classname_by_ref.
    DATA lv_classname TYPE abap_abstypename.
    lv_classname = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).
  ENDMETHOD.

  METHOD get_json_boolean.
      DATA temp236 TYPE string.
    IF check_is_boolean( val ) IS NOT INITIAL.
      
      IF val = abap_true.
        temp236 = `true`.
      ELSE.
        temp236 = `false`.
      ENDIF.
      result = temp236.
    ELSE.
      result = val.
    ENDIF.
  ENDMETHOD.

  METHOD check_is_boolean.
        DATA temp237 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp237.
    TRY.
        
        temp237 ?= cl_abap_elemdescr=>describe_by_data( val ).
        
        lo_ele = temp237.
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD get_trim_lower.

    DATA temp238 TYPE string.
    temp238 = val.
    result = temp238.
    result = to_lower( shift_left( shift_right( result ) ) ).

  ENDMETHOD.

ENDCLASS.
