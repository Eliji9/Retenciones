CLASS zcl_fiap_ret_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_filtros,
             pais      TYPE landl,
             sociedad  TYPE RANGE OF bukrs,
             acreedor  TYPE RANGE OF lifnr,
             documento TYPE RANGE OF belnr_d,
             tipo_ret  TYPE RANGE OF witht,
             ind_ret   TYPE RANGE OF wt_withcd,
             ejercicio TYPE gjahr,
             clase_doc TYPE RANGE OF blart,
             r_fcont   TYPE RANGE OF budat,
           END OF ty_filtros.

    TYPES: BEGIN OF ty_retencion,
             companycode             TYPE char4,
             companycodename         TYPE butxt,
             country                 TYPE land1,
             withholdingtaxtype      TYPE witht,
             withholdingtaxtypetext  TYPE text40,
             withholdingtaxcode      TYPE wt_withcd,
             supplier                TYPE lifnr,
             suppliername            TYPE name1_gp,
             taxnumber1              TYPE stcd1,
             taxnumber2              TYPE stcd2,
             taxnumberresponsible    TYPE stenr,
             phonenumber             TYPE telf1,
             emailaddress            TYPE ad_smtpadr,
             accountingdocument      TYPE char10,
             accountingdocumentitem  TYPE buzei,
             fiscalyear              TYPE n LENGTH 4,
             documenttype            TYPE blart,
             supplierinvoice         TYPE xblnr1,
             taxreference            TYPE char36,
             cai                     TYPE c LENGTH 40,
             documentdate            TYPE bldat,
             postingdate             TYPE budat,
             clearingdate            TYPE budat,
             invoicegrossamount      TYPE wrbtr,
             withholdingbaseamount   TYPE wt_bs, "wt_qsshh,
             withholdingtaxamount    TYPE wt_wt, "wt_qbshh,
             withholdingbaseamountfc TYPE wt_bs1, "wt_qsshb,
             withholdingtaxamountfc  TYPE wt_wt1, "wt_qbshb,
             currency                TYPE waers,
             documentseries          TYPE char16,
             concept                 TYPE char1,
             productgroup            TYPE matkl,
             productgrouptext        TYPE wgbez,
           END OF ty_retencion.

    TYPES: BEGIN OF ty_ekbe,
             purchasingdocument     TYPE ebeln,
             purchasingdocumentitem TYPE ebelp,
             purchaseordercategory  TYPE vgabe,
             materialdocument       TYPE mblnr,
             materialdocumentitem   TYPE mblpo,
             materialdocumentyear   TYPE mjahr,
             material               TYPE matnr,
             productgroup           TYPE matkl,
             materialgroupname      TYPE wgbez,
           END OF ty_ekbe.

    TYPES: BEGIN OF ty_bkpf,
             accountingdocument     TYPE belnr_d,
             companycode            TYPE bukrs,
             fiscalyear             TYPE gjahr,
             documentdate           TYPE bldat,
             postingdate            TYPE budat,
             accountingdocumenttype TYPE blart,
             transactioncurrency    TYPE waers,
             documentreferenceid    TYPE fis_xblnr1,
             transactioncode        TYPE tcode,
           END OF ty_bkpf.

    TYPES tt_retenciones TYPE STANDARD TABLE OF ty_retencion
                          WITH EMPTY KEY.
    TYPES tt_ebke        TYPE STANDARD TABLE OF ty_ekbe
                          WITH DEFAULT KEY.
    TYPES tt_bkpf        TYPE STANDARD TABLE OF ty_bkpf
                          WITH DEFAULT KEY.

    METHODS obtiene_datos
      IMPORTING is_filtros       TYPE ty_filtros
      RETURNING VALUE(rt_result) TYPE tt_retenciones.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_with TYPE STANDARD TABLE OF ty_retencion WITH EMPTY KEY.
    TYPES: ra_bukrs TYPE RANGE OF bukrs,
           ra_blart TYPE RANGE OF blart.

    METHODS determinar_sociedades
      IMPORTING is_filtros      TYPE ty_filtros
      RETURNING VALUE(rt_bukrs) TYPE ra_bukrs.

    METHODS determinar_clase_doc_por_pais
      IMPORTING is_filtros      TYPE ty_filtros
      RETURNING VALUE(rt_blart) TYPE ra_blart.

    METHODS leer_retenciones
      IMPORTING is_filtros TYPE ty_filtros
                it_bukrs   TYPE ra_bukrs
      CHANGING  ct_result  TYPE tt_retenciones.

    METHODS leer_documentos
      IMPORTING is_filtros TYPE ty_filtros
                it_blart   TYPE ra_blart
      CHANGING  ct_result  TYPE tt_retenciones.

    METHODS enriquecer_proveedor
      CHANGING ct_result TYPE tt_retenciones.

    METHODS enriquecer_texto_retencion
      CHANGING ct_result TYPE tt_retenciones.

    METHODS enriquecer_texto_sociedad
      CHANGING ct_result TYPE tt_retenciones.

    METHODS enriquecer_datos_z
      IMPORTING is_filtros TYPE ty_filtros
      CHANGING  ct_result  TYPE tt_retenciones.

    METHODS enriquecer_cai
      CHANGING ct_result TYPE tt_retenciones.
    METHODS obtener_material
      IMPORTING it_bkpf        TYPE tt_bkpf
      RETURNING VALUE(rt_ekbe) TYPE tt_ebke.
ENDCLASS.



CLASS zcl_fiap_ret_log IMPLEMENTATION.
  METHOD obtiene_datos.

    DATA(lt_bukrs) = determinar_sociedades( is_filtros ).
    DATA(lt_blart) = determinar_clase_doc_por_pais( is_filtros ).

    leer_retenciones(
      EXPORTING is_filtros = is_filtros
                it_bukrs   = lt_bukrs
      CHANGING  ct_result  = mt_with ).

    leer_documentos(
      EXPORTING is_filtros = is_filtros
                it_blart   = lt_blart
      CHANGING  ct_result  = mt_with ).

    enriquecer_texto_retencion( CHANGING ct_result = mt_with ).
    enriquecer_texto_sociedad( CHANGING ct_result = mt_with ).
    enriquecer_proveedor( CHANGING ct_result = mt_with ).
    enriquecer_datos_z( EXPORTING is_filtros = is_filtros
                         CHANGING ct_result  = mt_with ).
    enriquecer_cai( CHANGING ct_result = mt_with ).

    LOOP AT mt_with ASSIGNING FIELD-SYMBOL(<fs_with>).
      <fs_with>-country = is_filtros-pais.
    ENDLOOP.
    SORT mt_with BY companycode accountingdocument fiscalyear
                    accountingdocumentitem withholdingtaxtype.
    rt_result = mt_with.

  ENDMETHOD.


  METHOD determinar_sociedades.
    " Equivalente a: SELECT bukrs butxt FROM t001 ...
    SELECT companycode, companycodename
      FROM i_companycode
      WHERE country      = @is_filtros-pais
        AND companycode  IN @is_filtros-sociedad
      INTO TABLE @DATA(lt_t001).

    rt_bukrs = VALUE #( FOR ls IN lt_t001
                         ( sign = 'I' option = 'EQ' low = ls-companycode ) ).
  ENDMETHOD.


  METHOD determinar_clase_doc_por_pais.
    " *** Aquí se conserva intacta la lógica condicional por país ***
*    CASE is_filtros-pais.
*
*      WHEN 'NI'.
*        rt_blart = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZP' )
*                             ( sign = 'I' option = 'EQ' low = 'KA' )
*                             ( sign = 'I' option = 'EQ' low = 'AB' ) ).
*
*      WHEN 'SV'.
*        " TODO: reemplazo de SELECT SINGLE wt_postm FROM t059p
*        "       -> confirmar vista liberada equivalente en ADT
*        DATA(lv_tipo_ret) = ''.  "placeholder
*        IF lv_tipo_ret = '1'.
*          rt_blart = VALUE #( ( sign = 'I' option = 'EQ' low = 'KR' )
*                               ( sign = 'I' option = 'EQ' low = 'CR' )
*                               ( sign = 'I' option = 'EQ' low = 'RE' ) ).
*        ELSE.
*          rt_blart = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZP' )
*                               ( sign = 'I' option = 'EQ' low = '3G' ) ).
*        ENDIF.
*
*      WHEN 'HN'.
*        IF is_filtros-clase_doc IS NOT INITIAL.
*          rt_blart = is_filtros-clase_doc.
*        ELSE.
*          rt_blart = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZP' )
*                               ( sign = 'I' option = 'EQ' low = 'KZ' )
*                               ( sign = 'I' option = 'EQ' low = 'KA' ) ).
*        ENDIF.
*
*      WHEN OTHERS.
    IF is_filtros-clase_doc IS NOT INITIAL.
      rt_blart = is_filtros-clase_doc.
      "CLEAR rt_blart.  " CR y demás países: sin filtro de blart
    ENDIF.
*   ENDCASE.
  ENDMETHOD.


  METHOD leer_retenciones.
    " Equivalente a: WITH_ITEM INNER JOIN BKPF -> I_WITHHOLDINGTAXITEM
    SELECT companycode, fiscalyear, withholdingtaxtype, withholdingtaxcode,
           accountingdocument, accountingdocumentitem, clearingdate,
           whldgtaxbaseamtincocodecrcy, whldgtaxamtincocodecrcy,
           whldgtaxbaseamtintransaccrcy, whldgtaxamtintransaccrcy
      FROM i_withholdingtaxitem
      WHERE companycode           IN @it_bukrs
        AND withholdingtaxtype    IN @is_filtros-tipo_ret
        AND withholdingtaxcode    IN @is_filtros-ind_ret
        AND accountingdocument    IN @is_filtros-documento
        AND fiscalyear             = @is_filtros-ejercicio
      INTO TABLE @DATA(lt_wt).

    ct_result = VALUE #( FOR ls IN lt_wt
      ( companycode                = ls-companycode
        fiscalyear                 = ls-fiscalyear
        withholdingtaxtype         = ls-withholdingtaxtype
        withholdingtaxcode         = ls-withholdingtaxcode
        accountingdocument         = ls-accountingdocument
        accountingdocumentitem     = ls-accountingdocumentitem
        clearingdate               = ls-clearingdate
        withholdingbaseamount      = ls-whldgtaxbaseamtincocodecrcy
        withholdingtaxamount       = ls-whldgtaxamtincocodecrcy
        withholdingbaseamountfc    = ls-whldgtaxbaseamtintransaccrcy
        withholdingtaxamountfc     = ls-whldgtaxamtintransaccrcy ) ).

    DELETE ct_result WHERE withholdingbaseamount = 0.
  ENDMETHOD.


  METHOD leer_documentos.
    DATA lt_bkpf TYPE tt_bkpf.
    CHECK ct_result IS NOT INITIAL.

    " Equivalente a: SELECT * FROM bsak/bsik/bseg/bkpf ...
    SELECT accountingdocument, companycode, fiscalyear, documentdate,
           postingdate, accountingdocumenttype, transactioncurrency,
           documentreferenceid, transactioncode
      FROM i_journalentry
      FOR ALL ENTRIES IN @ct_result
      WHERE companycode          = @ct_result-companycode
        AND accountingdocument   = @ct_result-accountingdocument
        AND fiscalyear           = @ct_result-fiscalyear
        AND accountingdocumenttype IN @it_blart
        AND postingdate            IN @is_filtros-r_fcont
      INTO TABLE @lt_bkpf.
    CHECK ct_result IS NOT INITIAL.

    "obtener datos para material, grupo de artículo
    DATA(lt_ekbe) = obtener_material( it_bkpf = lt_bkpf ).

    SELECT accountingdocument, companycode, fiscalyear,
           supplier
           FROM i_journalentryitem
           FOR ALL ENTRIES IN @ct_result
           WHERE companycode          = @ct_result-companycode
             AND accountingdocument   = @ct_result-accountingdocument
             AND fiscalyear           = @ct_result-fiscalyear
             AND supplier             <> ''
           INTO TABLE @DATA(lt_bseg_prov).
    IF is_filtros-acreedor IS NOT INITIAL.
       DELETE lt_bseg_prov WHERE Supplier NOT IN is_filtros-acreedor.
    ENDIF.

    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs>).
      DATA(lv_pos) = sy-tabix.
      READ TABLE lt_bkpf INTO DATA(ls_bkpf)
        WITH KEY companycode        = <fs>-companycode
                 accountingdocument = <fs>-accountingdocument
                 fiscalyear         = <fs>-fiscalyear.
      IF sy-subrc = 0.
        <fs>-documentdate     = ls_bkpf-documentdate.
        <fs>-postingdate      = ls_bkpf-postingdate.
        <fs>-currency         = ls_bkpf-transactioncurrency.
        <fs>-supplierinvoice  = ls_bkpf-documentreferenceid.
        <fs>-documenttype     = ls_bkpf-accountingdocumenttype.
        READ TABLE lt_ekbe INTO DATA(ls_ekbe) WITH KEY materialdocument     = <fs>-accountingdocument
                                                       materialdocumentyear = <fs>-fiscalyear.
        IF sy-subrc EQ 0.
          <fs>-productgroup     = ls_ekbe-productgroup.
          <fs>-productgrouptext = ls_ekbe-materialgroupname.
        ENDIF.

        READ TABLE lt_bseg_prov INTO DATA(ls_bseg_prov)
        WITH KEY companycode        = <fs>-companycode
                 accountingdocument = <fs>-accountingdocument
                 fiscalyear         = <fs>-fiscalyear.
        IF sy-subrc = 0.
           <fs>-supplier = ls_bseg_prov-supplier.
        ELSE.
           DELETE ct_result INDEX lv_pos.
        ENDIF.
      ELSE.
        DELETE ct_result INDEX lv_pos.
      ENDIF.

    ENDLOOP.

    DELETE ct_result WHERE documentdate IS INITIAL.
    CHECK ct_result IS NOT INITIAL.

    SELECT accountingdocument, companycode, fiscalyear,
           debitcreditcode, amountintransactioncurrency
      FROM i_journalentryitem
      FOR ALL ENTRIES IN @ct_result
      WHERE companycode        = @ct_result-companycode
        AND accountingdocument = @ct_result-accountingdocument
        AND fiscalyear         = @ct_result-fiscalyear
        AND debitcreditcode    = 'H'
      INTO TABLE @DATA(lt_bseg).

    LOOP AT ct_result ASSIGNING <fs>.
      LOOP AT lt_bseg INTO DATA(ls_bseg)
        WHERE companycode        = <fs>-companycode
          AND accountingdocument = <fs>-accountingdocument
          AND fiscalyear         = <fs>-fiscalyear.
        <fs>-invoicegrossamount = <fs>-invoicegrossamount + ls_bseg-amountintransactioncurrency.
      ENDLOOP..
    ENDLOOP.
  ENDMETHOD.


  METHOD enriquecer_texto_retencion.
    CHECK ct_result IS NOT INITIAL.

    SELECT withholdingtaxtype, withholdingtaxcode, whldgtaxcodename
      FROM i_extendedwhldgtaxcodetext
      FOR ALL ENTRIES IN @ct_result
      WHERE withholdingtaxtype = @ct_result-withholdingtaxtype
        AND language           = @sy-langu
      INTO TABLE @DATA(lt_t059zt).

    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs>).
      READ TABLE lt_t059zt INTO DATA(ls_txt)
        WITH KEY withholdingtaxtype = <fs>-withholdingtaxtype.
      IF sy-subrc = 0.
        <fs>-withholdingtaxtypetext = ls_txt-whldgtaxcodename.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD enriquecer_proveedor.
    CHECK ct_result IS NOT INITIAL.
    SELECT supplier, addressid, organizationbpname1, taxnumber1, taxnumber2, phonenumber1,
           taxnumberresponsible
      FROM i_supplier
      FOR ALL ENTRIES IN @ct_result
      WHERE supplier = @ct_result-supplier
      INTO TABLE @DATA(lt_supplier).               "#EC CI_NO_TRANSFORM
    "email
    IF lt_supplier IS NOT INITIAL.
      SELECT addressid, emailaddress               "#EC CI_NO_TRANSFORM
        FROM i_addressemailaddress_2 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_supplier
        WHERE addressid EQ @lt_supplier-addressid
        INTO TABLE @DATA(lt_addr6).
    ENDIF.
    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs_res>).
      READ TABLE lt_supplier INTO DATA(ls_sup) WITH KEY supplier = <fs_res>-supplier.
      IF sy-subrc EQ 0.
        <fs_res>-suppliername = ls_sup-organizationbpname1.
        <fs_res>-taxnumber1   = ls_sup-taxnumber1.
        <fs_res>-taxnumber2   = ls_sup-taxnumber2.
        <fs_res>-phonenumber  = ls_sup-phonenumber1.

        "email_address
        READ TABLE lt_addr6 INTO DATA(ls_add) WITH KEY addressid = ls_sup-addressid.
        IF sy-subrc EQ 0.
          <fs_res>-emailaddress = ls_add-emailaddress.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD enriquecer_datos_z.
    CHECK ct_result IS NOT INITIAL.

    "ZPFA_DATA (antes ZBAC_FI_SCANFACT)
    SELECT consec, belnr, gjahr, fkdat, bukrs, n_fact, nserie, land1
    INTO TABLE @DATA(lt_cab)
    FROM zpfa_data  AS sc
    FOR ALL ENTRIES IN @ct_result
      WHERE bukrs EQ @ct_result-companycode
        AND belnr EQ @ct_result-accountingdocument
        AND gjahr EQ @ct_result-fiscalyear.


    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs_res>).
      READ TABLE lt_cab INTO DATA(ls_cab) WITH KEY bukrs = <fs_res>-companycode
                                                   belnr = <fs_res>-accountingdocument
                                                   gjahr = <fs_res>-fiscalyear.
      IF sy-subrc EQ 0.
        IF ls_cab-n_fact IS NOT INITIAL.
          <fs_res>-supplierinvoice = ls_cab-n_fact.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "       - ZPRE_PFA_H       (antes ZRE_SCAN_H)
    "       - ZPFA_CRED_FISC   (antes ZSCAN_CRED_FISC)
    "       - pendientes: reemplazo de ZRE_CRED_FISC y ZBAC_FI_CAI
  ENDMETHOD.

  METHOD enriquecer_texto_sociedad.
    CHECK ct_result IS NOT INITIAL.
    DATA(lt_result) = ct_result.
    SORT lt_result BY companycode.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING companycode.
    IF lt_result IS NOT INITIAL.
      SELECT companycode, companycodename
        FROM i_companycode
        FOR ALL ENTRIES IN @lt_result
        WHERE companycode EQ @lt_result-companycode
        INTO TABLE @DATA(lt_t001).

      LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs_res>).
        READ TABLE lt_t001 INTO DATA(ls_t001) WITH KEY companycode = <fs_res>-companycode.
        IF sy-subrc EQ 0.
          <fs_res>-companycodename = ls_t001-companycodename.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD enriquecer_cai.
    " CAI por factura (HN): ZPFA_FACT_CAI se lee por CONSEC.
    " El CONSEC se obtiene con Sociedad + Documento FI + Ejercicio desde:
    "   1) ZI_COM_PFA_BASE (COMPANYCODE / BELNR / MIROGJAHR -> CONSEC)
    "   2) ZI_RE_PFA_H     (Sociedad / Nº doc. / Ejercicio  -> UUID) si no está en 1)
    TYPES: BEGIN OF ty_doc_consec,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             consec             TYPE sysuuid_x16,
           END OF ty_doc_consec.
    DATA lt_doc_consec TYPE SORTED TABLE OF ty_doc_consec
                       WITH NON-UNIQUE KEY companycode accountingdocument fiscalyear.

    CHECK ct_result IS NOT INITIAL.

    " Llaves únicas de documentos del resultado
    DATA(lt_docs) = ct_result.
    SORT lt_docs BY companycode accountingdocument fiscalyear.
    DELETE ADJACENT DUPLICATES FROM lt_docs
      COMPARING companycode accountingdocument fiscalyear.

    " --- 1. ZI_COM_PFA_BASE ---
    SELECT companycode, belnr, mirogjahr, consec
      FROM zi_com_pfa_base
      FOR ALL ENTRIES IN @lt_docs
      WHERE companycode = @lt_docs-companycode
        AND belnr       = @lt_docs-accountingdocument
        AND mirogjahr   = @lt_docs-fiscalyear
      INTO TABLE @DATA(lt_base).

    LOOP AT lt_base INTO DATA(ls_base) WHERE consec IS NOT INITIAL.
      INSERT VALUE #( companycode        = ls_base-companycode
                      accountingdocument = ls_base-belnr
                      fiscalyear         = ls_base-mirogjahr
                      consec             = ls_base-consec ) INTO TABLE lt_doc_consec.
    ENDLOOP.

    " --- 2. ZI_RE_PFA_H (solo documentos que no se encontraron en 1) ---
    " CONFIRMAR nombres de campos de ZI_RE_PFA_H en ADT (en SE16 se ven
    " como UUID / Sociedad / Nº doc. / Ej.)
    SELECT uuid, companycode, accountingdocument, fiscalyear
      FROM zi_re_pfa_h
      FOR ALL ENTRIES IN @lt_docs
      WHERE companycode        = @lt_docs-companycode
        AND accountingdocument = @lt_docs-accountingdocument
        AND fiscalyear         = @lt_docs-fiscalyear
      INTO TABLE @DATA(lt_reh).

    LOOP AT lt_reh INTO DATA(ls_reh) WHERE uuid IS NOT INITIAL.
      IF NOT line_exists( lt_doc_consec[ companycode        = ls_reh-companycode
                                         accountingdocument = ls_reh-accountingdocument
                                         fiscalyear         = ls_reh-fiscalyear ] ).
        INSERT VALUE #( companycode        = ls_reh-companycode
                        accountingdocument = ls_reh-accountingdocument
                        fiscalyear         = ls_reh-fiscalyear
                        consec             = ls_reh-uuid ) INTO TABLE lt_doc_consec.
      ENDIF.
    ENDLOOP.

    CHECK lt_doc_consec IS NOT INITIAL.

    " --- 3. ZPFA_FACT_CAI ---
    SELECT consec, cai
      FROM zpfa_fact_cai
      FOR ALL ENTRIES IN @lt_doc_consec
      WHERE consec = @lt_doc_consec-consec
      INTO TABLE @DATA(lt_cai).
    SORT lt_cai BY consec.

    " --- 4. Asignar CAI al resultado ---
    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<fs_res>).
      LOOP AT lt_doc_consec INTO DATA(ls_dc)
        WHERE companycode        = <fs_res>-companycode
          AND accountingdocument = <fs_res>-accountingdocument
          AND fiscalyear         = <fs_res>-fiscalyear.
        READ TABLE lt_cai INTO DATA(ls_cai)
          WITH KEY consec = ls_dc-consec BINARY SEARCH.
        IF sy-subrc = 0 AND ls_cai-cai IS NOT INITIAL.
          <fs_res>-cai = ls_cai-cai.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD obtener_material.
    DATA(lt_bkpf) = it_bkpf.
    SORT lt_bkpf BY transactioncode.
    DELETE lt_bkpf WHERE transactioncode NE 'MIRO'.
    IF lt_bkpf IS NOT INITIAL.
      SELECT ebke~purchasingdocument, ebke~purchasingdocumentitem, ebke~purchaseordercategory,
             ebke~materialdocument, ebke~materialdocumentitem, ebke~materialdocumentyear, ekpo~material,
             mara~productgroup, text~materialgroupname
             FROM i_purdochistory AS ebke
             INNER JOIN i_purchaseorderitem AS ekpo ON ebke~purchasingdocument EQ ekpo~purchaseorder
                                                   AND ebke~purchasingdocumentitem EQ ekpo~purchaseorderitem
             INNER JOIN i_product AS mara ON ekpo~material EQ mara~product
             INNER JOIN i_materialgrouptext AS text ON mara~productgroup EQ text~materialgroup
             FOR ALL ENTRIES IN @lt_bkpf
             WHERE ebke~materialdocument EQ @lt_bkpf-accountingdocument
               AND ebke~materialdocumentyear EQ @lt_bkpf-fiscalyear
               AND text~language EQ @syst-langu
             INTO TABLE @rt_ekbe.

    ENDIF.
  ENDMETHOD.

ENDCLASS.
