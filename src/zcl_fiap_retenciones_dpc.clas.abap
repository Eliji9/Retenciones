CLASS zcl_fiap_retenciones_dpc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
  DATA mo_logica TYPE REF TO zcl_fiap_ret_log.
ENDCLASS.



CLASS zcl_fiap_retenciones_dpc IMPLEMENTATION.
METHOD if_rap_query_provider~select.

    DATA: ls_filtros TYPE zcl_fiap_ret_log=>ty_filtros,
          lt_result  TYPE zcl_fiap_ret_log=>tt_retenciones,
          lv_total   TYPE int8.

    " --- 1. Leer filtros que vienen del selection screen Fiori ---
    DATA(lo_filter) = io_request->get_filter( ).
    DATA lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    TRY.
        lt_ranges = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    IF line_exists( lt_ranges[ name = 'COUNTRY' ] ).
       ls_filtros-pais = lt_ranges[ name = 'COUNTRY' ]-range[ 1 ]-low.
    ENDIF.
    IF line_exists( lt_ranges[ name = 'COMPANYCODE' ] ).
       ls_filtros-sociedad = CORRESPONDING #( lt_ranges[ name = 'COMPANYCODE' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'ACCOUNTINGDOCUMENT' ] ).
       ls_filtros-documento = CORRESPONDING #( lt_ranges[ name = 'ACCOUNTINGDOCUMENT' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'SUPPLIER' ] ).
       ls_filtros-acreedor = CORRESPONDING #( lt_ranges[ name = 'SUPPLIER' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'WITHHOLDINGTAXTYPE' ] ).
       ls_filtros-tipo_ret = CORRESPONDING #( lt_ranges[ name = 'WITHHOLDINGTAXTYPE' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'WITHHOLDINGTAXCODE' ] ).
       ls_filtros-ind_ret = CORRESPONDING #( lt_ranges[ name = 'WITHHOLDINGTAXCODE' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'FISCALYEAR' ] ).
       ls_filtros-ejercicio = lt_ranges[ name = 'FISCALYEAR' ]-range[ 1 ]-low.
    ENDIF.
    IF line_exists( lt_ranges[ name = 'POSTINGDATE' ] ).
       ls_filtros-r_fcont = CORRESPONDING #( lt_ranges[ name = 'POSTINGDATE' ]-range ).
    ENDIF.
    IF line_exists( lt_ranges[ name = 'DOCUMENTTYPE' ] ).
       ls_filtros-clase_doc = CORRESPONDING #( lt_ranges[ name = 'DOCUMENTTYPE' ]-range ).
    ENDIF.
    " --- 2. Delegar en la clase motor---
    CREATE OBJECT mo_logica.
    lt_result = mo_logica->obtiene_datos( ls_filtros ).

    " --- 3. Búsqueda libre (campo "Buscar") ---
    DATA(lv_search) = io_request->get_search_expression( ).
    IF lv_search IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '"' IN lv_search WITH ``.
      REPLACE ALL OCCURRENCES OF '*' IN lv_search WITH ``.
      CONDENSE lv_search.
      IF lv_search IS NOT INITIAL.
        DELETE lt_result WHERE NOT (    suppliername       CS lv_search
                                     OR supplier           CS lv_search
                                     OR accountingdocument CS lv_search
                                     OR supplierinvoice    CS lv_search ).
      ENDIF.
    ENDIF.

    " --- 4. Ordenamiento ($orderby) ---
    DATA(lt_sort) = io_request->get_sort_elements( ).
    IF lt_sort IS NOT INITIAL.
      DATA(lt_orden) = VALUE abap_sortorder_tab(
                         FOR ls_sort IN lt_sort
                         ( name       = ls_sort-element_name
                           descending = ls_sort-descending ) ).
      SORT lt_result BY (lt_orden).
    ENDIF.

    " --- 5. Paginación ---
    DATA(lo_paging) = io_request->get_paging(  ).
    DATA(lv_offset) = lo_paging->get_offset(  ).
    DATA(lv_page_size) = lo_paging->get_page_size(  ).
    lv_total = lines( lt_result ).

    IF lv_page_size <> if_rap_query_paging=>page_size_unlimited.
       DATA(lt_pag) = VALUE zcl_fiap_ret_log=>tt_retenciones(
                        FOR ls IN lt_result FROM lv_offset + 1
                                              TO lv_offset + lv_page_size ( ls ) ).
       lt_result = lt_pag.
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lv_total ).
    ENDIF.
    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
