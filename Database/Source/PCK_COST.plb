CREATE OR REPLACE PACKAGE BODY SIMEX.PCK_COST
IS
   --
   --
   -- MKSSTART
   --
   -- $CompanyInfo $
   --
   -- $Date: 2015/03/20 16:11:17MEZ $
   --
   -- $Name:  $
   --
   -- $Revision: 1.37 $
   --
   -- $Header: 5100_Code_Base/Database/Source/PCK_COST.plb 1.37 2015/03/20 16:11:17MEZ Frank, Marina (marinf) CI_Changed  $
   --
   -- $Source: 5100_Code_Base/Database/Source/PCK_COST.plb $
   --
   -- $Log: 5100_Code_Base/Database/Source/PCK_COST.plb  $
   -- Revision 1.37 2015/03/20 16:11:17MEZ Frank, Marina (marinf) 
   -- MKS-151824:1 DEF8653 derive "dateTime" from global settings.
   -- Revision 1.36 2015/03/06 16:32:45MEZ Frank, Marina (marinf) 
   -- MKS-136133:1 Added CostFull, inlined xml-generating functions.
   -- Revision 1.35 2015/02/19 17:01:24MEZ Frank, Marina (marinf) 
   -- MKS-136397 Implemented LPAD for formatting iCON Contarct Number. 
   -- Due to potential loopback overhead via database link new function pck_calculation.contract_number_icon
   -- will be included only after optimizing query with restrictive DRIVING_SITE hints.
   -- Revision 1.34 2015/01/23 14:54:31MEZ Pauzenberger, Christian (cpauzen) 
   -- MKS-136148 - CostCollective - km 0+1 aussschlie�en
   -- Revision 1.33 2014/12/18 09:28:22MEZ Berger, Franz (fraberg) 
   -- expAssignCostToCost: do not extract VEGA and INFO CN!
   -- Revision 1.32 2014/11/13 14:55:04MEZ Berger, Franz (fraberg) 
   -- get_costCovColl: add 'cost_pl:CostType' - "xsi:type"
   -- Revision 1.31 2014/11/10 14:23:09MEZ Berger, Franz (fraberg) 
   -- wavePreInt4 COST Coll-INV changes according ANDE
   -- Revision 1.30 2014/11/07 16:41:38MEZ Berger, Franz (fraberg) 
   -- wavePreInt4 changes according ANDE
   -- Revision 1.29 2014/10/16 16:05:50MESZ Zimmerberger, Markus (zimmerb) 
   -- AssignCostToCost WavePreInt4
   -- Revision 1.28 2014/09/17 14:24:16MESZ Kieninger, Tobias (tkienin) 
   -- Selecting Workshop or Supplier
   -- Revision 1.27 2014/09/11 11:44:00MESZ Zuhl, Marco (marzuhl) 
   -- Replaced all:
   -- to_char ( o_FILE_RUNNING_NO )
   -- with:
   -- to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) )
   -- Revision 1.26 2014/08/13 15:38:21MESZ Kieninger, Tobias (tkienin) 
   -- DEF5014
   -- Revision 1.25 2014/08/08 17:18:26MESZ Kieninger, Tobias (tkienin) 
   -- parameter XSI types added
   -- Revision 1.24 2014/07/17 10:33:55MESZ Kieninger, Tobias (tkienin) 
   -- add xsitypes to parameter
   -- Revision 1.23 2014/07/10 10:00:15MESZ Kieninger, Tobias (tkienin) 
   -- hotfix
   -- Revision 1.22 2014/06/13 17:35:25MESZ Kieninger, Tobias (tkienin) 
   -- assignCosttoCost fixed
   -- Revision 1.21 2014/06/05 09:50:49MESZ Kieninger, Tobias (tkienin) 
   -- externalPartnerCostId => externalPartnerCostID
   -- Revision 1.20 2014/06/02 10:48:01MESZ Berger, Franz (fraberg) 
   -- add function expAssignCostToCost
   -- Revision 1.19 2014/05/20 10:47:38MESZ Berger, Franz (fraberg) 
   -- MKS-131815:1 / 132867:1 / 132654:1: a lot of changes / new functions in folge der Cost CollectiveWorkshopInvoices implementierung
   -- (- details siehe direkt im file -)
   -- Revision 1.18 2014/04/30 14:50:50MESZ Zimmerberger, Markus (zimmerb) 
   -- MKS-131289:2 get_costPosition_*: Fix substr ( nvl ( IP_MEMO, ' ' ), 1, 255 )
   -- Revision 1.17 2014/04/28 16:04:45MESZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice: concatenate financialDocumentIssuer - externalId - ID_GARAGE with leading 'W'
   -- Revision 1.16 2014/04/28 07:56:42MESZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice / get_costDamage_COV: some small fixing
   -- Revision 1.15 2014/04/22 17:22:45MESZ Berger, Franz (fraberg) 
   -- get_costDamage_COV / get_costOdometer / get_costState / get_costDamage_COLL / expWorkshopInvoice /
   -- get_costPosition_Part / get_costPosition_Labour / get_costPosition_Sublet: 
   -- nachtr�gliche wave1 implementierung
   -- Revision 1.14 2014/04/14 14:08:11MESZ Zimmerberger, Markus (zimmerb) 
   -- Wave 3.2: get_Position for each type (Part, Labour, Sublet) and many more
   -- Revision 1.13 2013/11/22 16:01:25MEZ Zimmerberger, Markus (zimmerb) 
   -- Implement missing pck_calculation.substitute-call
   -- Revision 1.12 2013/11/21 15:44:56MEZ Zimmerberger, Markus (zimmerb) 
   -- fix 'cost_pl:CostStateType', get_costDamage_COV
   -- Revision 1.11 2013/11/19 11:18:04MEZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice: remove get_costDocumentissuer as no longer needed
   -- Revision 1.10 2013/11/19 07:07:53MEZ Berger, Franz (fraberg) 
   -- get_costDocumentissuer: dynamische type definition f�r l_ID_Customer / l_ID_Garage statt NUMBER
   -- Revision 1.9 2013/11/16 07:40:23MEZ Berger, Franz (fraberg) 
   -- move von PCK_EXPORTS:
   -- - expWorkshopInvoice
   -- Revision 1.8 2013/11/13 18:53:03MEZ Berger, Franz (fraberg) 
   -- get_costDamage_COLL: neue taxation - logik ( -> pass it as IN parameter )
   -- Revision 1.7 2013/11/05 13:16:31MEZ Zimmerberger, Markus (zimmerb) 
   -- Add get_costJOP_BEGIN
   -- Revision 1.6 2013/11/05 07:18:19MEZ Berger, Franz (fraberg) 
   -- - get_costPosition: IP_AMOUNT = 0 wird ersetzt mit 1 wegen divisor is 0 problem
   -- - get_costState: das XMLELEMENT hei�t activeState und nicht states
   -- - get_costDamage_COLL: get_costPosition f�r berechnen labour / parts / sublets values werden einstweilen nicht aufgerufen, da das iCON schema diese noch nicht unterst�tzt
   -- Revision 1.5 2013/11/04 15:13:24MEZ Berger, Franz (fraberg) 
   -- some small changes during test
   -- Revision 1.4 2013/10/31 16:45:40MEZ Zimmerberger, Markus (zimmerb) 
   -- add get_costDamage_COV, add dynamical parameter-types, aos...
   -- Revision 1.3 2013/10/31 15:43:54MEZ Zimmerberger, Markus (zimmerb) 
   -- remove get_cost
   -- Revision 1.2 2013/10/31 14:20:53MEZ Berger, Franz (fraberg) 
   -- - add get_costDamage
   -- - get_costState: add IN parameter I_ID_CURRENCY and i_BELART_SOLL_HABEN plus neue logik
   -- - get_costPosition: add IN parameter i_BELART_SOLL_HABEN and i_XMLELEMENT_EVALNAME
   -- - add get_costDocumentissuer
   -- Revision 1.1 2013/10/29 13:29:20MEZ Zimmerberger, Markus (zimmerb) 
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
   --
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
   --
   -- MKSEND
   --
   -- Purpose: package for all SiMEX-Cost sub-functions/packages of cost-exports
   --
   -- MODIFICATION HISTORY
   -- Person      Date        Comments
   -- ---------   ----------  ------------------------------------------
   -- ZBerger     2013-10-22  MKS-121600:1 creation
   -- FraBe       2013-10-31  MKS-121601:2 add get_costDamage
   -- FraBe       2013-10-31  MKS-121601:2 get_costState: add IN parameter I_ID_CURRENCY and i_BELART_SOLL_HABEN plus neue logik
   -- FraBe       2013-10-31  MKS-121601:2 get_costPosition: add IN parameter i_BELART_SOLL_HABEN and i_XMLELEMENT_EVALNAME
   -- ZBerger     2013-10-31  MKS-121601:1 add get_costDocumentissuer
   -- ZBerger     2013-10-31  MKS-121601:1 remove get_cost
   -- FraBe       2013-11-05  MKS-121601:2 get_costPosition: IP_AMOUNT = 0 wird ersetzt mit 1 wegen divisor is 0 problem
   -- FraBe       2013-10-31  MKS-121601:2 get_costState: das XMLELEMENT hei�t activeState und nicht states
   -- FraBe       2013-10-31  MKS-121601:2 get_costDamage_COLL: get_costPosition f�r berechnen labour / parts / sublets values werden einstweilen nicht
   --                                      aufgerufen, da das iCON schema diese noch nicht unterst�tzt
   -- ZBerger     2013-11-05  MKS-121601:1 add get_costJOP_BEGIN
   -- FraBe       2013-11-13  MKS-121601:2 get_costDamage_COLL: neue taxation - logik ( -> pass it as IN parameter )
   -- FraBe       2013-11-19  MKS-123544:1 get_costDocumentissuer: dynamische type definition f�r l_ID_Customer / l_ID_Garage statt NUMBER
   -- FraBe       2013-11-19  MKS-123544:2 remove get_costDocumentissuer as no longer needed
   -- ZBerger     2013-11-21  MKS-121604:1 fix 'cost_pl:CostStateType', get_costDamage_COV
   -- ZBerger     2013-11-22  MKS-121604:2 expWorkshopInvoice: Implement missing pck_calculation.substitute-call
   -- ZBerger     2014-04-14  MKS-131285:1 Wave 3.2: get_Position for each type (Part, Labour, Sublet) and many more
   -- FraBe       2014-04-17  MKS-131284:2 get_costDamage_COV / get_costOdometer / get_costState / get_costDamage_COLL / expWorkshopInvoice /
   --                                      get_costPosition_Part / get_costPosition_Labour / get_costPosition_Sublet: 
   --                                      nachtr�gliche wave1 implementierung
   -- FraBe       2014-04-25  MKS-131289:1 expWorkshopInvoice / get_costDamage_COV: some small fixing
   -- FraBe       2014-04-28  MKS-132489:1 expWorkshopInvoice: concatenate financialDocumentIssuer - externalId - ID_GARAGE with leading 'W'
   -- ZBerger     2014-04-30  MKS-131289:2 get_costPosition_*: Fix substr ( nvl ( IP_MEMO, ' ' ), 1, 255 )
   -- FraBe       2014-05-06  MKS-131815:1 / 132867:1 / 132654:1: a lot of changes / new functions infolge der Cost CollectiveWorkshopInvoices implementierung:
   --                                      a) function expWorkshopInvoice: correct crec for loop where
   --                                         plus: jene L_* vars, die global verwendet werden, global definieren (-> G_* vars )
   --                                         plus: fix ID_CURRENCY statt CUR_CODE - umschl�sselungs- bug
   --                                      b) function get_costState: fix ID_CURRENCY statt CUR_CODE - umschl�sselungs- bug
   --                                      c) xmlelement "cost" in function get_cost auslagern
   --                                      d) get_costDamage_COLL: add neue IN parameter i_supplierPaymentInterval / i_supplierMonthlyPeriod. 
   --                                         plus: change customerCharged / add claimingSystemDamageSequence
   --                                      e) function get_costDamage_COV: remove IN parameter i_DEFAULT_COVERAGE - replaced by global var G_DEFAULT_COVERAGE
   --                                      f) function get_costOdometer:   remove IN parameter i_SOURCE_SYSTEM - replaced by global var G_SOURCE_SYSTEM
   --                                      g) function get_costState:      remove IN parameter I_TAS_GUID / I_TIMESTAMP - replaced by global vars G_TAS_GUID / G_TIMESTAMP
   --                                      h) neue functions get_costCovColl / expCollectiveWorkshopInv 
   --                                      i) jene L_* vars, die global verwendet werden, global definieren (-> G_* vars )
   --                                      j) get_costPosition_Part/Labour/Sublet zweite wave3.2 �berarbeitung: change an attributes number and customerCharged
   --                                      k) get_costPosition_Labour: discount gibt es nicht nur bei Parts, sondern auch bei Labour
   --                                      l) function get_costJOP_BEGIN: add 77 = SPP Buchungsanweisung
   --                                      m) some small cosmetic changes
   --  FraBe       2014-05-28 MKS-131308:1 add expAssignCostToCost
   --  MaZi        2014-10-16 MKS-134509:1 cre_AssignCostToCost_xml: WavePreInt4 changes
   --  FraBe       2014-11-05 MKS-134457:1 / 134458:1 wavePreInt4 COST changes according ANDE (- details see below within the code -)
   --  FraBe       2014-11-08 MKS-134470:1 / 134471:1 wavePreInt4 COST Coll-INV changes according ANDE (- details see below within the code -)
   --                                      (- sofern nicht schon beim voran gegangenen wavePreInt4 COST erledigt.
   --                                      denn der meiste code, der von beiden verwendet wird, ist bei beiden gleich -)
   --  FraBe       2014-11-13 MKS-134476:1 get_costCovColl: add 'cost_pl:CostType' - "xsi:type"
   --  FraBe       2014-12-17 MKS-136026:1 expAssignCostToCost: do not extract VEGA and INFO CN!
   --  PBerger     2015-01-21 MKS-136148:1 CollectiveWorkshopInvoice - do not create odometer-node, if fzgre_laufleistung is 0 or 1
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   G_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
   G_COUNTRY_CODE              TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'COUNTRY_CODE',             'COUNTRY_CODE' );
   G_SourceSystem              TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',             'SIRIUS'       );
   G_correlationID             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID',            'SIRIUS'       );
   G_issueThreshold            TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'ISSUETHRESHOLD',           'SIRIUS'       );
   G_causation                 TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',                'migration'    );
   G_masterDataReleaseVersion  TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9'            );  
   G_masterDataVersion         TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MASTERDATA_VERSION',        null          );
   G_DEFAULT_COVERAGE          TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'DEFAULTCOVERAGE',           'D000'        );
   G_DEFAULT_COVERAGE_EXTERNAL TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'DEFAULTCOVERAGE_EXTERNAL',  'D007'        );
   G_FILECOUNT_FILLER          TSETTING.SET_VALUE%type := PCK_CALCULATION.get_setting ( 'SETTING', 'FILECOUNT_FILLER',          5             );
   G_migrationDate             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE',             to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));
   G_TIMESTAMP                 TIMESTAMP (6)           := SYSTIMESTAMP;
   G_TAS_GUID                  TTASK.TAS_GUID%type;
   g_expdatetime               TSETTING.SET_VALUE%TYPE := 
    CASE
      WHEN pck_calculation.g_expdatetime = '0'
        THEN to_char ( G_TIMESTAMP, pck_calculation.c_xmlDTfmt )
      ELSE pck_calculation.g_expdatetime 
    END;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costPosition_Part ( i_ID_SEQ_FZGRECHNUNG  TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                                  , i_ID_REPCODE          TINV_POSITION.ID_REPCODE@SIMEX_DB_LINK%type
                                  , i_ID_SUBREPCODE       TINV_POSITION.ID_SUBREPCODE@SIMEX_DB_LINK%type
                                  , i_GUID_DAMAGE_CODE    TINV_POSITION.GUID_DAMAGE_CODE@SIMEX_DB_LINK%type
                                  , i_ACCEPTED            varchar2
                                  ) RETURN                XMLTYPE
      
   IS
     l_costPosition  XMLTYPE;
     
   BEGIN
     -- code ist gleich zu den beiden anderen get_costPosition_* functions. die abweichungen sind extra angef�hrt: wert bei ...
     -- FraBe     2013-10-31  MKS-121601:2 add IN parameter i_BELART_SOLL_HABEN and i_XMLATT_TYPE
     -- FraBe     2013-11-05  MKS-121601:2 IP_AMOUNT = 0 wird ersetzt mit 1 wegen divisor is 0 problem
     -- zimmerb   2014-04-11  MKS-131258:1 Wave3.2 changes
     -- FraBe     2014-04-15  MKS-131284:2 nachtr�gliche wave1 implementierung
     -- FraBe     2014-05-19  MKS-131815:1 zweite wave3.2 �berarbeitung: change an attribute number / customerCharged
     -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: remove I_BELART_SOLL_HABEN / add i_GUID_DAMAGE_CODE / new quantity calculation
     select XMLAGG ( XMLELEMENT ( "costPosition"
                     , xmlattributes
                       ( 'cost_pl:CostPositionPartsType'                               AS "xsi:type"
                       , substr ( nvl ( IP_PART_NR, IP_MEMO ), 1, 20 )                 AS "number"                        -- wert bei Parts
                    -- , substr (       IP_POSITION_CODE,      1, 20 )                 AS "number"                        -- wert bei Labour
                       , rownum                                                        AS "sequence"
                       , nvl ( round (   IP_DISCOUNT,                         8 ), 0 ) AS "discount"                      -- wert bei Parts und Labour
                       , nvl ( round ((  IP_LISTPRICE 
                                     + ( IP_LISTPRICE * IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
                       , nvl ( round (   IP_LISTPRICE                       , 8 ), 0 ) AS "amountNet"
                       , nvl ( round (   IP_LISTPRICE * IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
                       , 'false'                                                       AS "customerCharged"
                       , 'false'                                                       AS "deletionIndicator"
                       , substr ( nvl ( IP_MEMO, ' ' ), 1, 255 )                       AS "description"
                       , abs ( replace ( nvl ( IP_AMOUNT, 0 ), 0, 1 ))                 AS "quantity"
                    -- , 'tenthOfHours'                                                AS "timeUnit"                      -- wert bei Labour
                       , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
                    )))
       into l_costPosition
       from ( select IP_POSINDEX
                   , IP_PART_NR
                   , IP_POSITION_CODE
                   , IP_DISCOUNT
                   , IP_MEMO
                   , IP_AMOUNT
                   , IP_SALESTAX
                   , decode(i_ACCEPTED,'true',(IP_LISTPRICE - IP_REJECT_SUM),IP_REJECT_SUM) as IP_LISTPRICE
                from TINV_POSITION@SIMEX_DB_LINK
               where ID_SEQ_FZGRECHNUNG = i_ID_SEQ_FZGRECHNUNG
                 and IP_CARDTYPE        = 12
                 and ID_REPCODE         = i_ID_REPCODE
                 and ID_SUBREPCODE      = i_ID_SUBREPCODE
                 and GUID_DAMAGE_CODE   = i_GUID_DAMAGE_CODE
               ORDER BY 1
            ) 
            where IP_LISTPRICE <> 0
            ;
     
     return l_costPosition;
     
   END get_costPosition_Part;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costPosition_Labour ( i_ID_SEQ_FZGRECHNUNG  TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                                    , i_ID_REPCODE          TINV_POSITION.ID_REPCODE@SIMEX_DB_LINK%type
                                    , i_ID_SUBREPCODE       TINV_POSITION.ID_SUBREPCODE@SIMEX_DB_LINK%type
                                    , i_GUID_DAMAGE_CODE    TINV_POSITION.GUID_DAMAGE_CODE@SIMEX_DB_LINK%type
                                    , i_ACCEPTED            varchar2
                                    ) RETURN                XMLTYPE
      
   IS
     l_costPosition  XMLTYPE;
     
   BEGIN
     -- code ist gleich zu den beiden anderen get_costPosition_* functions. die abweichungen sind extra angef�hrt: wert bei ...
     -- FraBe     2013-10-31  MKS-121601:2 add IN parameter i_BELART_SOLL_HABEN and i_XMLATT_TYPE
     -- FraBe     2013-11-05  MKS-121601:2 IP_AMOUNT = 0 wird ersetzt mit 1 wegen divisor is 0 problem
     -- FraBe     2014-04-15  MKS-131284:2 nachtr�gliche wave1 implementierung
     -- FraBe     2014-05-19  MKS-131815:1 zweite wave3.2 �berarbeitung: change an attribute number / customerCharged
     --                                    plus: discount gibt es nicht nur bei Parts, sondern auch bei Labour
     -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: remove I_BELART_SOLL_HABEN / add i_GUID_DAMAGE_CODE / new quantity calculation
     select XMLAGG ( XMLELEMENT ( "costPosition"
                     , xmlattributes
                       ( 'cost_pl:CostPositionLabourType'                              AS "xsi:type"
                    -- , substr ( nvl ( IP_PART_NR, IP_MEMO ), 1, 20 )                 AS "number"                        -- wert bei Parts
                       , substr (       IP_POSITION_CODE,      1, 20 )                 AS "number"                        -- wert bei Labour
                       , rownum                                                        AS "sequence"
                       , nvl ( round (   IP_DISCOUNT,                         8 ), 0 ) AS "discount"                      -- wert bei Parts und Labour
                       , nvl ( round ((  IP_LISTPRICE 
                                     + ( IP_LISTPRICE * IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
                       , nvl ( round (   IP_LISTPRICE                       , 8 ), 0 ) AS "amountNet"
                       , nvl ( round (   IP_LISTPRICE * IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
                       , 'false'                                                       AS "customerCharged"
                       , 'false'                                                       AS "deletionIndicator"
                       , substr ( nvl ( IP_MEMO, ' ' ), 1, 255 )                       AS "description"
                       , abs ( replace ( nvl ( IP_AMOUNT, 0 ), 0, 1 ))                 AS "quantity"
                       , 'tenthOfHours'                                                AS "timeUnit"                      -- wert bei Labour
                    -- , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
                    )))
       into l_costPosition
       from ( select IP_POSINDEX
                   , IP_PART_NR
                   , IP_POSITION_CODE
                   , IP_DISCOUNT
                   , IP_MEMO
                   , IP_AMOUNT
                   , IP_SALESTAX
                   , decode(i_ACCEPTED,'true',(IP_LISTPRICE - IP_REJECT_SUM),IP_REJECT_SUM) as IP_LISTPRICE
                from TINV_POSITION@SIMEX_DB_LINK
               where ID_SEQ_FZGRECHNUNG = i_ID_SEQ_FZGRECHNUNG
                 and IP_CARDTYPE        = 11
                 and ID_REPCODE         = i_ID_REPCODE
                 and ID_SUBREPCODE      = i_ID_SUBREPCODE
                 and GUID_DAMAGE_CODE   = i_GUID_DAMAGE_CODE
               order by 1
                ) 
            where IP_LISTPRICE <> 0
            ;
     
     return l_costPosition;
     
   END get_costPosition_Labour;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costPosition_Sublet ( i_ID_SEQ_FZGRECHNUNG  TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                                    , i_ID_REPCODE          TINV_POSITION.ID_REPCODE@SIMEX_DB_LINK%type
                                    , i_ID_SUBREPCODE       TINV_POSITION.ID_SUBREPCODE@SIMEX_DB_LINK%type
                                    , i_GUID_DAMAGE_CODE    TINV_POSITION.GUID_DAMAGE_CODE@SIMEX_DB_LINK%type
                                    , i_ACCEPTED            varchar2
                                    ) RETURN                XMLTYPE
      
   IS
     l_costPosition  XMLTYPE;
     
   BEGIN
     -- code ist gleich zu den beiden anderen get_costPosition_* functions. die abweichungen sind extra angef�hrt: wert bei ...
     -- FraBe     2013-10-31  MKS-121601:2 add IN parameter i_BELART_SOLL_HABEN and i_XMLATT_TYPE
     -- FraBe     2013-11-05  MKS-121601:2 IP_AMOUNT = 0 wird ersetzt mit 1 wegen divisor is 0 problem
     -- FraBe     2014-04-15  MKS-131284:2 nachtr�gliche wave1 implementierung
     -- FraBe     2014-05-19  MKS-131815:1 zweite wave3.2 �berarbeitung: change an attribute number / customerCharged
     -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: remove I_BELART_SOLL_HABEN / add i_GUID_DAMAGE_CODE / new quantity calculation
     select XMLAGG ( XMLELEMENT ( "costPosition"
                     , xmlattributes
                       ( 'cost_pl:CostPositionSubletsType'                             AS "xsi:type"
                    -- , substr ( nvl ( IP_PART_NR, IP_MEMO ), 1, 20 )                 AS "number"                        -- wert bei Parts
                    -- , substr (       IP_POSITION_CODE,      1, 20 )                 AS "number"                        -- wert bei Labour
                       , rownum                                                        AS "sequence"
                    -- , nvl ( round (   IP_DISCOUNT,                         8 ), 0 ) AS "discount"                      -- wert bei Parts  
                       , nvl ( round ((  IP_LISTPRICE 
                                     + ( IP_LISTPRICE * IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
                       , nvl ( round (   IP_LISTPRICE                       , 8 ), 0 ) AS "amountNet"
                       , nvl ( round (   IP_LISTPRICE * IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
                       , 'false'                                                       AS "customerCharged"
                       , 'false'                                                       AS "deletionIndicator"
                       , substr ( nvl ( IP_MEMO, ' ' ), 1, 255 )                       AS "description"
                       , abs ( replace ( nvl ( IP_AMOUNT, 0 ), 0, 1 ))                 AS "quantity"
                    -- , 'tenthOfHours'                                                AS "timeUnit"                      -- wert bei Labour
                    -- , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
                    )))
       into l_costPosition
       from ( select IP_POSINDEX
                   , IP_PART_NR
                   , IP_POSITION_CODE
                   , IP_DISCOUNT
                   , IP_MEMO
                   , IP_AMOUNT
                   , IP_SALESTAX
                   , decode(i_ACCEPTED,'true',(IP_LISTPRICE - IP_REJECT_SUM),IP_REJECT_SUM) as IP_LISTPRICE
                from TINV_POSITION@SIMEX_DB_LINK
               where ID_SEQ_FZGRECHNUNG = i_ID_SEQ_FZGRECHNUNG
                 and IP_CARDTYPE        = 13
                 and ID_REPCODE         = i_ID_REPCODE
                 and ID_SUBREPCODE      = i_ID_SUBREPCODE
                 and GUID_DAMAGE_CODE   = i_GUID_DAMAGE_CODE
               ORDER BY 1
                 ) 
            where IP_LISTPRICE <> 0;
     
     return l_costPosition;
     
   END get_costPosition_Sublet;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_nineDigitRepairDefinition 
          ( i_ID_SEQ_FZGRECHNUNG     TINV_POSITION.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
          , i_ID_REPCODE             TINV_POSITION.ID_REPCODE@SIMEX_DB_LINK%type
          , i_ID_SUBREPCODE          TINV_POSITION.ID_SUBREPCODE@SIMEX_DB_LINK%type
          , i_GUID_DAMAGE_CODE       TINV_POSITION.GUID_DAMAGE_CODE@SIMEX_DB_LINK%type
          ) return                   varchar2
   is
            L_nineDigitRepairDefinition       varchar2 ( 10 char );                       
   begin
         -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: creation 
            select '7'
              into L_nineDigitRepairDefinition
	      from TINV_POSITION@SIMEX_DB_LINK
	     where ID_SEQ_FZGRECHNUNG = i_ID_SEQ_FZGRECHNUNG
	       and ID_REPCODE         = i_ID_REPCODE
	       and ID_SUBREPCODE      = i_ID_SUBREPCODE
	       and GUID_DAMAGE_CODE   = i_GUID_DAMAGE_CODE
	       and IP_CARDTYPE        = 12
               and rownum             = 1;
               
            return L_nineDigitRepairDefinition;
               
   exception when NO_DATA_FOUND then return '8';
   
   end get_nineDigitRepairDefinition;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costDamage_COV ( i_ID_SEQ_FZGRECHNUNG  TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                               , I_XMLELEMENT_EVALNAME varchar2 
                               ) RETURN XMLTYPE
   IS
   
            l_costDamage_COV  XMLTYPE;
            
   BEGIN
   -- FraBe       2014-04-17 MKS-131284:2 nachtr�gliche wave1 implementierung
   -- FraBe       2014-04-25 MKS-131289:1 some small fixing
   -- FraBe       2014-05-06 MKS-131815:1 / 132654:1: some small cosmetic changes haupts�chlich aufgrund besserer performance
   --                                     plus replace I_DEFAULT_COVERAGE by G_DEFAULT_COVERAGE
   -- FraBe       2014-11-07 MKS-134457/134458: wavePreInt4: add I_XMLELEMENT_EVALNAME / vin
   --                                     plus add claimingSystemDamageSequence bzw. deswegen union select
   --                                     plus neues order by 
   
   -- Knoten hei�t 'costDamageCoverageCollection' bei CostColelctive; bzw. 'parameter' bei Cost
     select XMLELEMENT ( evalname I_XMLELEMENT_EVALNAME
                         -- TK 2014-08-09; MKS-134033:1 adding XSI-Type
                       , xmlattributes ( 'common:CostDamageCoverageCollectionType'                              AS "xsi:type" )
                       , XMLAGG ( XMLELEMENT ( "costDamageCoverage"
                                        , xmlattributes ( 'common:CostDamageCoverageType'                       AS "xsi:type"
                                                        , vin                                                   AS "vin"
                                                        , vehicleContractNumber                                 AS "vehicleContractNumber" )
                                        , XMLELEMENT ( "costDamage"
                                                , xmlattributes ( '0' || damageCode || damageDefinition 
                                                                      || nineDigitRepairDefinition              AS "nineDigitDamageCode"
                                                        --      , accepted                                      as "accepted"               -- lt. Tobi nicht notwendig
                                                                , claimingSystemDamageSequence                  AS "claimingSystemDamageSequence" ))
                                              , XMLELEMENT ( "coverage"
                                                      , xmlattributes ( case when   FZGRE_ANZAHL_AW1 = 1
                                                                             then G_DEFAULT_COVERAGE_EXTERNAL
                                                                             else G_DEFAULT_COVERAGE
                                                                        end                                     AS "code" )))))
         into l_costDamage_COV
         from ( select 'true'                                                             as accepted
                     , lpad ( fzgre.ID_VERTRAG,    8, '0' ) || '/' ||
                       lpad ( fzgre.ID_FZGVERTRAG, 6, '0' )                               as vehicleContractNumber
                     , ip.ID_REPCODE || ip.ID_SUBREPCODE                                  as damageCode
                     , dc.DC_CODE                                                         as damageDefinition
                     , coalesce(MAX(decode(ip.IP_CARDTYPE,12,'7',NULL)), '8')             as nineDigitRepairDefinition
                     , fzgre.FZGRE_ANZAHL_AW1                                             as FZGRE_ANZAHL_AW1
                     , fzgv.ID_MANUFACTURE       || fzgv.FZGV_FGSTNR                      as vin
                     , min ( ip.IP_POSINDEX )                                             as claimingSystemDamageSequence
                  from TDAMAGE_CODE@SIMEX_DB_LINK   dc
                     , TINV_POSITION@SIMEX_DB_LINK  ip
                     , TFZGRECHNUNG@SIMEX_DB_LINK   fzgre
                     , TFZGVERTRAG@SIMEX_DB_LINK    fzgv
                 where dc.GUID_DAMAGE_CODE        = ip.GUID_DAMAGE_CODE
                   and fzgre.ID_SEQ_FZGRECHNUNG   = ip.ID_SEQ_FZGRECHNUNG
                   and fzgre.ID_VERTRAG           = fzgv.ID_VERTRAG
                   and fzgre.ID_FZGVERTRAG        = fzgv.ID_FZGVERTRAG
                   and fzgre.ID_SEQ_FZGRECHNUNG   = I_ID_SEQ_FZGRECHNUNG
                   and nvl ( ip.IP_LISTPRICE, 0 ) - nvl ( ip.IP_REJECT_SUM, 0 ) <> 0   --> accepted value exists
              group by fzgre.ID_VERTRAG
                     , fzgre.ID_FZGVERTRAG
                     , fzgre.FZGRE_ANZAHL_AW1
                     , ip.ID_SEQ_FZGRECHNUNG
                     , ip.ID_REPCODE
                     , ip.ID_SUBREPCODE
                     , ip.GUID_DAMAGE_CODE
                     , dc.DC_CODE
                     , fzgv.ID_MANUFACTURE
                     , fzgv.FZGV_FGSTNR
                 union
                select 'false'                                                            as accepted
         , lpad ( fzgre.ID_VERTRAG,    8, '0' ) || '/' ||
           lpad ( fzgre.ID_FZGVERTRAG, 6, '0' )                                           as vehicleContractNumber
		     , ip.ID_REPCODE || ip.ID_SUBREPCODE                                  as damageCode
		     , dc.DC_CODE                                                         as damageDefinition
		     , coalesce(MAX(decode(ip.IP_CARDTYPE,12,'7',NULL)), '8')             as nineDigitRepairDefinition
		     , fzgre.FZGRE_ANZAHL_AW1                                             as FZGRE_ANZAHL_AW1
		     , fzgv.ID_MANUFACTURE       || fzgv.FZGV_FGSTNR                      as vin
		     , min ( ip.IP_POSINDEX ) + 1000                                      as claimingSystemDamageSequence
		  from TDAMAGE_CODE@SIMEX_DB_LINK   dc
		     , TINV_POSITION@SIMEX_DB_LINK  ip
		     , TFZGRECHNUNG@SIMEX_DB_LINK   fzgre
		     , TFZGVERTRAG@SIMEX_DB_LINK    fzgv
		 where dc.GUID_DAMAGE_CODE        = ip.GUID_DAMAGE_CODE
		   and fzgre.ID_SEQ_FZGRECHNUNG   = ip.ID_SEQ_FZGRECHNUNG
		   and fzgre.ID_VERTRAG           = fzgv.ID_VERTRAG
		   and fzgre.ID_FZGVERTRAG        = fzgv.ID_FZGVERTRAG
		   and fzgre.ID_SEQ_FZGRECHNUNG   = I_ID_SEQ_FZGRECHNUNG
		   and nvl ( ip.IP_REJECT_SUM, 0 ) <> 0                                -->    rejected value exists
              group by fzgre.ID_VERTRAG
                     , fzgre.ID_FZGVERTRAG
                     , fzgre.FZGRE_ANZAHL_AW1
                     , ip.ID_SEQ_FZGRECHNUNG
                     , ip.ID_REPCODE
                     , ip.ID_SUBREPCODE
                     , ip.GUID_DAMAGE_CODE
                     , dc.DC_CODE
                     , fzgv.ID_MANUFACTURE
                     , fzgv.FZGV_FGSTNR
                 order by 2, 3, 4, 5, 6, 7, 1 );
   
       return l_costDamage_COV;
       
   END get_costDamage_COV;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costCovColl ( i_GUID_SPCI           TFZGRECHNUNG.GUID_SPCI@SIMEX_DB_LINK%type
                            , I_externalId_praefix  varchar2
                            ) RETURN XMLTYPE
   IS
   
            l_costCovColl  XMLTYPE;
            
   BEGIN
   -- FraBe     2014-05-12  MKS-131815:1 creation
   -- FraBe     2014-11-07  MKS-134457/134458: wavePreInt4: creation of node "costDamageCoverageCollection" is done by PCK_COST.get_costDamage_COV
   -- FraBe     2014-11-13  MKS-134476:1 add 'cost_pl:CostType' - "xsi:type"

   -- besteht aus 2 teilen: 
   -- A) dem node CostCoverageCollection - parameter
   -- B) dessen subnode costDamageCoverageCollection

      select XMLELEMENT ( "parameter"
                  -- MKS134152:1 - adding parameter type + moving XMLAGG to costCoverage
                  , xmlattributes ( 'common:CostCoverageCollectionType'  AS "xsi:type" )
                  , XMLAGG ( XMLELEMENT ( "costCoverage"
                                 , XMLELEMENT ( "cost"
                                       , xmlattributes ( 'cost_pl:CostType'                                   AS "xsi:type"
                                                       , I_externalId_praefix || ID_SEQ_FZGRECHNUNG           as "externalId"
                                                       , G_SourceSystem                                       as "sourceSystem" ))
                                 , PCK_COST.get_costDamage_COV 
                                           ( i_ID_SEQ_FZGRECHNUNG    => ID_SEQ_FZGRECHNUNG
                                           , I_XMLELEMENT_EVALNAME   => 'costDamageCoverageCollection' )      as "costDamageCoverageCollection"
                          )
             order by ID_VERTRAG, ID_FZGVERTRAG, ID_SEQ_FZGRECHNUNG ))
        into l_costCovColl
        from snt.TFZGRECHNUNG@SIMEX_DB_LINK
       where GUID_SPCI            = i_GUID_SPCI; 
                
     return l_costCovColl;
     
   END get_costCovColl;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costOdometer ( i_ID_SEQ_FZGRECHNUNG TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                             ) RETURN               XMLTYPE
   IS
     l_costOdometer  XMLTYPE;
     
   BEGIN
   -- FraBe       2014-04-17  MKS-131284:2 nachtr�gliche wave1 implementierung
   -- FraBe       2014-05-06  MKS-131815:1 / 132654:1: I_SourceSystem mit G_SourceSystem ersetzen
   -- FraBe       2014-11-07  MKS-134457:1 / 134458:1  replace G_SourceSystem by fixtext 'migration'
   -- PBerger     2015-01-21  MKS-136148:1 bei Sammelrechung darf der Node bei KM-St�nde 0 oder 1 nicht erstellt werden
     select XMLAGG (XMLELEMENT ( "odometer"
                    , xmlattributes
                      ( fzgre.fzgre_laufstrecke                          AS "mileage"  
                      , CASE fzgre.fzgre_laufstrecke
                          WHEN 0 THEN 'false'
                          WHEN 1 THEN 'false'
                          ELSE 'true'
                        END                                              AS "calculationRelevant"
                      , 'reportedMileage'                                AS "mileageState"
                      , to_char(fzgre.fzgre_repdatum, 'YYYYMMDD')        AS "readingDate"
                      , 'workshopInvoice'                                AS "sourceDefinition"
                      , 'migration'   	                                 AS "sourceSystem"
                      , CASE fzgre.fzgre_laufstrecke
                          WHEN 0 THEN 'false'
                          WHEN 1 THEN 'false'
                          ELSE 'true'
                        END                                              AS "valid" )))
       into l_costOdometer
       from TFZGRECHNUNG@SIMEX_DB_LINK fzgre
      where fzgre.id_seq_fzgrechnung = i_ID_SEQ_FZGRECHNUNG
        and (  fzgre.GUID_SPCI is     null                          -- -> keine SPP Sammelrechnung
              or ( fzgre.fzgre_laufstrecke not in (0,1)));
     
     return l_costOdometer;
     
   END get_costOdometer;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION get_costState ( i_ID_SEQ_FZGRECHNUNG TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
                          , I_CUR_CODE           TCURRENCY.CUR_CODE@SIMEX_DB_LINK%type
                          ) RETURN               XMLTYPE
      
   IS
     l_costState    XMLTYPE;
   
   BEGIN
   -- FraBe     2013-10-31  MKS-121601:2 add IN parameter I_ID_CURRENCY and i_BELART_SOLL_HABEN
   -- FraBe     2013-10-31  MKS-121601:2 das XMLELEMENT hei�t activeState und nicht states
   -- FraBe     2014-04-17  MKS-131284:2 nachtr�gliche wave1 implementierung
   -- FraBe     2014-05-06  MKS-131815:1 / 132654:1: change ID_CURRENCY substitute by CUR_CODE
   --                                      plus replace I_TAS_GUID / I_TIMESTAMP with G_TAS_GUID / G_TIMESTAMP
   -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: remove I_BELART_SOLL_HABEN / add nvl ( round ( ...
     select XMLAGG ( XMLELEMENT ( "activeState"
                        , xmlattributes
                          ( 'cost_pl:CostStateType'                          AS "xsi:type" 
                          , 'exported'                                       AS "status"
                          , PCK_CALCULATION.SUBSTITUTE   ( G_TAS_GUID
                                                         , G_TIMESTAMP
                                                         , 'CUR_CODE'
                                                         , I_CUR_CODE )      AS "currency"
                          , PCK_CALCULATION.G_DFLT_TENANT_CURR               AS "defaultTenantCurrency"
                          , nvl ( round ( sum ((                             ip.IP_LISTPRICE 
                                                                         + ( ip.IP_LISTPRICE * ip.IP_SALESTAX / 100 ))), 8 ), 0 ) AS "grossAmount"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE                          ), 8 ), 0 ) AS "netAmount"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 11, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "labourInvoiceAmountNet"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 12, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "partsInvoiceAmountNet"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 13, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "subletsInvoiceAmountNet"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE - ip.IP_REJECT_SUM ),       8 ), 0 ) AS "amountNetAccepted"
                          , nvl ( round ( sum (                                                ip.IP_REJECT_SUM       ), 8 ), 0 ) AS "amountNetDeclined"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE                          ), 8 ), 0 ) AS "netAmountInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 11, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "labourInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 12, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "partsInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 13, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "subletsInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE - ip.IP_REJECT_SUM ),       8 ), 0 ) AS "amountNetAcceptedInTenantCurrency"
                          , nvl ( round ( sum (                                                ip.IP_REJECT_SUM       ), 8 ), 0 ) AS "amountNetDeclinedInTenantCurrency"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE * ip.IP_SALESTAX / 100   ), 8 ), 0 ) AS "taxAmount" )))
       into l_costState
       from TINV_POSITION@SIMEX_DB_LINK ip
      where ip.ID_SEQ_FZGRECHNUNG = i_ID_SEQ_FZGRECHNUNG
   group by PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                       , G_TIMESTAMP
                                       , 'CUR_CODE'
                                       , I_CUR_CODE );

     return l_costState;

   END get_costState;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costDamage_COLL 
          ( i_ID_SEQ_FZGRECHNUNG       TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
          , i_taxation                 varchar2
          , i_supplierPaymentInterval  varchar2       := null
          , i_supplierMonthlyPeriod    varchar2       := null
          ) RETURN                     XMLTYPE
      
   IS
            l_costDamage_COLL          XMLTYPE;
     
   BEGIN
     -- FraBe     2013-10-31 MKS-121601:2 creation
     -- FraBe     2013-10-31 MKS-121601:2 get_costPosition f�r berechnen labour / parts / sublets values werden einstweilen nicht
     --                                   aufgerufen, da das iCON schema diese noch nicht unterst�tzt
     -- FraBe     2013-11-13 MKS-121601:2 neue taxation - logik ( -> pass it as IN parameter )
     -- FraBe     2014-04-17 MKS-131284:2 nachtr�gliche wave1 implementierung
     -- FraBe     2014-05-06 MKS-131815:1 / 132654:1: add neue IN parameter i_supplierPaymentInterval / i_supplierMonthlyPeriod
     --                                   plus: change customerCharged / add claimingSystemDamageSequence
     -- FraBe     2014-11-05  MKS-134457/134458: wavePreInt4: remove I_BELART_SOLL_HABEN / add new IN parameter i_GUID_DAMAGE_CODE when calling PCK_COST.get_costPosition_%
     WITH remote AS (
       SELECT ip.ID_REPCODE
            , ip.ID_SUBREPCODE
            , ip.GUID_DAMAGE_CODE
            , dc.DC_CODE
            , ip.IP_POSINDEX
            , ip.IP_CARDTYPE
            , ip.IP_LISTPRICE
            , ip.IP_REJECT_SUM
            , ip.IP_SALESTAX
            , ip.IP_PART_NR
            , ip.IP_POSITION_CODE
            , ip.IP_DISCOUNT
            , ip.IP_MEMO
            , ip.IP_AMOUNT
         FROM TDAMAGE_CODE@SIMEX_DB_LINK   dc
            , TINV_POSITION@SIMEX_DB_LINK  ip
        where dc.GUID_DAMAGE_CODE   = ip.GUID_DAMAGE_CODE
          and i_ID_SEQ_FZGRECHNUNG  = ip.ID_SEQ_FZGRECHNUNG
     )
     select XMLAGG
     ( XMLELEMENT ( "damage"
       , xmlattributes
         ( accepted                                   as "accepted"
         , damageCode                                 as "damageCode"
         , damageDefinition                           as "damageDefinition"
         , 'series'                                   as "guarantyDefinition"
         , case G_COUNTRY_CODE
                when '51331' then 'false'
                             else 'false' 
           end                                        as "customerCharged"
         , nvl ( round ( amountGross,      8 ), 0 )   as "amountGross"
         , nvl ( round ( amountNet,        8 ), 0 )   as "amountNet"
         , nvl ( round ( labourAmountNet,  8 ), 0 )   as "labourAmountNet"
         , nvl ( round ( partsAmountNet,   8 ), 0 )   as "partsAmountNet"
         , nvl ( round ( subletsAmountNet, 8 ), 0 )   as "subletsAmountNet"
         , nvl ( round ( taxAmount,        8 ), 0 )   as "taxAmount"
         , i_taxation                                 as "taxation"
         , repairDefinition                           as "repairDefinition"
         , nvl ( round ( amountNet,        8 ), 0 )   as "amountNetInTenantCurrency"
         , nvl ( round ( labourAmountNet,  8 ), 0 )   as "labourAmountNetInTenantCurrency"
         , nvl ( round ( partsAmountNet,   8 ), 0 )   as "partsAmountNetInTenantCurrency"
         , nvl ( round ( subletsAmountNet, 8 ), 0 )   as "subletsAmountNetInTenantCurrency"
         , '0'                                        as "claimingSystemDealerHandling"
         , claimingSystemDamageSequence               as "claimingSystemDamageSequence"
         , i_supplierPaymentInterval                  as "supplierPaymentInterval"
         , i_supplierMonthlyPeriod                    as "supplierMonthlyPeriod"
         ,        damageCode  || damageDefinition     as "sevenDigitDamageCode"
         , '0' || damageCode  || damageDefinition 
               || nineDigitRepDef                     as "nineDigitDamageCode" 
         )
       , ( select XMLAGG 
           ( XMLELEMENT ( "costPosition"
             , XMLATTRIBUTES 
             ( 'cost_pl:CostPositionPartsType'                               AS "xsi:type"
             , substr ( nvl ( r1.IP_PART_NR,  r1.IP_MEMO ), 1, 20 )          AS "number"                        -- wert bei Parts
             , rownum                                                        AS "sequence"
             , nvl ( round (    r1.IP_DISCOUNT, 8 ), 0 )                     AS "discount"                      -- wert bei Parts und Labour
             , nvl ( round ((  decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) 
                           + ( decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) *  r1.IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM)                           , 8 ), 0 ) AS "amountNet"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) *  r1.IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
             , 'false'                                                       AS "customerCharged"
             , 'false'                                                       AS "deletionIndicator"
             , substr ( nvl (  r1.IP_MEMO, ' ' ), 1, 255 )                   AS "description"
             , abs ( replace ( nvl (  r1.IP_AMOUNT, 0 ), 0, 1 ))             AS "quantity"
             , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
             )))
            from (SELECT * FROM remote ORDER BY IP_POSINDEX) r1
           where r1.IP_CARDTYPE        = 12
             and r1.ID_REPCODE         = r.ID_REPCODE
             and r1.ID_SUBREPCODE      = r.ID_SUBREPCODE
             and r1.GUID_DAMAGE_CODE   = r.GUID_DAMAGE_CODE
             and decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) <> 0
         )                                                                                                      AS "costPosition"
       , ( select XMLAGG 
           ( XMLELEMENT ( "costPosition"
             , xmlattributes
             ( 'cost_pl:CostPositionLabourType'                              AS "xsi:type"
          -- , substr ( nvl ( IP_PART_NR, IP_MEMO ), 1, 20 )                 AS "number"                        -- wert bei Parts
             , substr (       r1.IP_POSITION_CODE,      1, 20 )              AS "number"                        -- wert bei Labour
             , rownum                                                        AS "sequence"
             , nvl ( round (   r1.IP_DISCOUNT, 8 ), 0 )                      AS "discount"                      -- wert bei Parts und Labour
             , nvl ( round ((  decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) 
                           + ( decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) * r1.IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM)                          , 8 ), 0 ) AS "amountNet"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) * r1.IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
             , 'false'                                                       AS "customerCharged"
             , 'false'                                                       AS "deletionIndicator"
             , substr ( nvl ( r1.IP_MEMO, ' ' ), 1, 255 )                    AS "description"
             , abs ( replace ( nvl ( r1.IP_AMOUNT, 0 ), 0, 1 ))              AS "quantity"
             , 'tenthOfHours'                                                AS "timeUnit"                      -- wert bei Labour
          -- , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
             )))
            from (SELECT * FROM remote ORDER BY IP_POSINDEX) r1
           where r1.IP_CARDTYPE        = 11
             and r1.ID_REPCODE         = r.ID_REPCODE
             and r1.ID_SUBREPCODE      = r.ID_SUBREPCODE
             and r1.GUID_DAMAGE_CODE   = r.GUID_DAMAGE_CODE
             and decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) <> 0
         )                                                                                                     AS "costPosition"
       , ( select XMLAGG 
           ( XMLELEMENT ( "costPosition"
             , xmlattributes
             ( 'cost_pl:CostPositionSubletsType'                             AS "xsi:type"
          -- , substr ( nvl ( IP_PART_NR, IP_MEMO ), 1, 20 )                 AS "number"                        -- wert bei Parts
          -- , substr (       IP_POSITION_CODE,      1, 20 )                 AS "number"                        -- wert bei Labour
             , rownum                                                        AS "sequence"
          -- , nvl ( round (   IP_DISCOUNT,                         8 ), 0 ) AS "discount"                      -- wert bei Parts  
             , nvl ( round ((  decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) 
                           + ( decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) * r1.IP_SALESTAX / 100 )), 8 ), 0 ) AS "amountGross"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM)                          , 8 ), 0 ) AS "amountNet"
             , nvl ( round (   decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) * r1.IP_SALESTAX / 100   , 8 ), 0 ) AS "amountTax"
             , 'false'                                                       AS "customerCharged"
             , 'false'                                                       AS "deletionIndicator"
             , substr ( nvl ( r1.IP_MEMO, ' ' ), 1, 255 )                    AS "description"
             , abs ( replace ( nvl ( r1.IP_AMOUNT, 0 ), 0, 1 ))              AS "quantity"
          -- , 'tenthOfHours'                                                AS "timeUnit"                      -- wert bei Labour
          -- , '0'                                                           AS "claimingSystemDealerHandling"  -- wert bei Parts
             )))
            from (SELECT * FROM remote ORDER BY IP_POSINDEX) r1
           where r1.IP_CARDTYPE        = 13
             and r1.ID_REPCODE         = r.ID_REPCODE
             and r1.ID_SUBREPCODE      = r.ID_SUBREPCODE
             and r1.GUID_DAMAGE_CODE   = r.GUID_DAMAGE_CODE
             and decode(r.ACCEPTED,'true',( r1.IP_LISTPRICE -  r1.IP_REJECT_SUM), r1.IP_REJECT_SUM) <> 0
         )                                                                                                     AS "costPosition"
       )
       order by accepted, damageCode, damageDefinition 
     )
       into l_costDamage_COLL
       from ( -- accepted value
              select 'true'                                                                                    as accepted
                   , ID_REPCODE
                   , ID_SUBREPCODE
                   , ID_REPCODE || ID_SUBREPCODE                                                               as damageCode
                   , GUID_DAMAGE_CODE
                   , DC_CODE                                                                                   as damageDefinition
                   , min ( IP_POSINDEX )                                                                       as claimingSystemDamageSequence
                   , sum (                         ( IP_LISTPRICE - IP_REJECT_SUM ) 
                                                + (( IP_LISTPRICE - IP_REJECT_SUM ) * IP_SALESTAX / 100 ))     as amountGross
                   , sum (                           IP_LISTPRICE - IP_REJECT_SUM     )                        as amountNet
                   , sum ( decode ( IP_CARDTYPE, 11, IP_LISTPRICE - IP_REJECT_SUM, 0 ))                        as labourAmountNet
                   , sum ( decode ( IP_CARDTYPE, 12, IP_LISTPRICE - IP_REJECT_SUM, 0 ))                        as partsAmountNet
                   , sum ( decode ( IP_CARDTYPE, 13, IP_LISTPRICE - IP_REJECT_SUM, 0 ))                        as subletsAmountNet
                   , sum (                         ( IP_LISTPRICE - IP_REJECT_SUM )    
                                                                  * IP_SALESTAX / 100 )                        as taxAmount
                   , coalesce(MAX(decode( IP_CARDTYPE,12,'scaWithParts',NULL)), 'scaWithoutMaterialPositions') as repairDefinition
                   , coalesce(MAX(decode( IP_CARDTYPE,12,'7',NULL)), '8')                                      as nineDigitRepDef                                                                                                    
                from remote
               where 0                    <> nvl ( IP_LISTPRICE, 0 ) - nvl ( IP_REJECT_SUM, 0 )
               group by ID_REPCODE, ID_SUBREPCODE, GUID_DAMAGE_CODE, DC_CODE
               UNION ALL
              -- rejected value
              select 'false'                                                                                   as accepted
                   , ID_REPCODE                    
                   , ID_SUBREPCODE                    
                   , ID_REPCODE || ID_SUBREPCODE                                                               as damageCode
                   , GUID_DAMAGE_CODE                    
                   ,  DC_CODE                                                                                  as damageDefinition
                   , min ( IP_POSINDEX ) + 1000                                                                as claimingSystemDamageSequence
                   , sum (                           IP_REJECT_SUM   
                                                 + ( IP_REJECT_SUM  * IP_SALESTAX / 100 ))                     as amountGross
                   , sum (                           IP_REJECT_SUM     )                                       as amountNet
                   , sum ( decode ( IP_CARDTYPE, 11, IP_REJECT_SUM, 0 ))                                       as labourAmountNet
                   , sum ( decode ( IP_CARDTYPE, 12, IP_REJECT_SUM, 0 ))                                       as partsAmountNet
                   , sum ( decode ( IP_CARDTYPE, 13, IP_REJECT_SUM, 0 ))                                       as subletsAmountNet
                   , sum (                           IP_REJECT_SUM 
                                                   * IP_SALESTAX / 100 )                                       as taxAmount
                   , coalesce(MAX(decode( IP_CARDTYPE,12,'scaWithParts',NULL)), 'scaWithoutMaterialPositions') as repairDefinition
                   , coalesce(MAX(decode( IP_CARDTYPE,12,'7',NULL)), '8')                                      as nineDigitRepDef
                from remote
               where 0                    <> nvl ( IP_REJECT_SUM, 0 )
               group by ID_REPCODE, ID_SUBREPCODE, GUID_DAMAGE_CODE, DC_CODE ) r;
      
      return l_costDamage_COLL;
      
   END get_costDamage_COLL;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_costJOP_BEGIN ( i_JOP_FOREIGN TJOURNAL_POSITION.JOP_FOREIGN@SIMEX_DB_LINK%type )
      RETURN VARCHAR2

   IS   
     l_costJOP_BEGIN  VARCHAR2(8);

   BEGIN
      -- ZBerger     2013-11-05 MKS-121601:1 creation
      -- FraBe       2014-05-13 MKS-131815:1 add 77 = SPP Buchungsanweisung
      select to_char(JO_BEGIN, 'YYYYMMDD')
        into l_costJOP_BEGIN
        from TJOURNAL@SIMEX_DB_LINK jou, TJOURNAL_POSITION@SIMEX_DB_LINK joup
       where joup.GUID_JOT IN ( '9', '12', '77' )        --- 9 = SAP WORKSHOP / 12 = SAP FWD / 77 = SPP Buchungsanweisung
         and jou.GUID_JO = joup.GUID_JO
         and JOP_FOREIGN = i_JOP_FOREIGN;

      return l_costJOP_BEGIN;
   END get_costJOP_BEGIN;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_cost
          ( I_ID_SEQ_FZGRECHNUNG           TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG@SIMEX_DB_LINK%type
          , I_GUID_SPCI                    TFZGRECHNUNG.GUID_SPCI@SIMEX_DB_LINK%type           := null
          , I_Cost_externalId_praefix      varchar2                                            := null
          , i_supplierPaymentInterval      varchar2                                            := null
          , i_supplierMonthlyPeriod        varchar2                                            := NULL
          , i_consistent_datetime          DATE                                                := SYSDATE
          , i_exporttype                   VARCHAR2                                            := pck_calculation.c_exptype_cost
          ) RETURN                         XMLTYPE   IS
            l_cost                         XMLTYPE;
     v_GUID_SPCI                           VARCHAR2(32) := I_GUID_SPCI;
     v_Cost_externalId_praefix             varchar2(200):= I_Cost_externalId_praefix;
     v_supplierPaymentInterval             varchar2(200) := i_supplierPaymentInterval;
     v_count_collinv                       NUMBER(38) := 0;
     v_SPCI_DOCUMENT_NUMBER                varchar2(200);
     v_SPCI_DATE                           DATE;
   BEGIN
     -- FraBe       2014-05-08 MKS-131815:1 creation
     -- FraBe       2014-05-13 MKS-131815:1 einige COST CollINV anpassungen
     -- FraBe       2014-11-05 MKS-134457/134458: wavePreInt4: remove BELART_SOLL_HABEN / add MBBEL workshopInvoiceDefinition l�nderweiche / neues order by
     -- FraBe       2014-11-09 MKS-134470:1 / 134471:1 �nderung beim xmlAttribut workshopInvoiceDefinition aufgrund wavePreInt4 COST CollINV
     
     -- function ist im grunde genommen gleich bei COST ( -> aufruf aus function expWorkshopInvoice ) und COST CollINV ( -> expCollectiveWorkshopInv )
     
     -- bei einigen  xmlattributen gibts aber abweichungen
     -- -> wird �ber die IN parameter I_GUID_SPCI und I_*_externalId_praefix gesteuert

     /* leider kann man direkt bei den IN parametern keine kommentare anbringen -> daher hier deren beschreibung:
          , I_GUID_SPCI                    -- a1) �bergabe wert bei aufruf aus expCollectiveWorkshopInv / leer bei aufruf aus expWorkshopInvoice
          , I_Cost_externalId_praefix      -- a2) -> wird ben�tigt f�r die xmlattribute conversionDate und financialSystemTransferDate / cost - externalID
          , I_FinDoc_externalId_praefix    -- b1) �bergabe wert bei aufruf aus expWorkshopInvoice = 'W' / leer bei aufruf aus expCollectiveWorkshopInv
                                           -- b2) -> wird ben�tigt f�r das xmlattribut financialDocumentIssuer - externalId
          , i_supplierPaymentInterval      -- c1)  �bergabe wert = 0 oder 1 bei aufruf aus expCollectiveWorkshopInv / / leer bei aufruf aus expWorkshopInvoice
                                           -- c2) -> wird ben�tigt f�r das xmlattribut des nodes activeDamageCollection, der �ber PCK_COST.get_costDamage_COLL aufbereitet wird
          , i_supplierMonthlyPeriod        -- c1)  �bergabe wert aus TFZGRECHNUNG.FZGRE_PERIOD bei aufruf aus expCollectiveWorkshopInv / / leer bei aufruf aus expWorkshopInvoice
                                           -- c2) -> wird ben�tigt f�r das xmlattribut supplierMonthlyPeriod des nodes activeDamageCollection, der �ber PCK_COST.get_costDamage_COLL aufbereitet wird
     */
     IF i_exporttype = pck_calculation.c_exptype_costFull THEN
       BEGIN
         SELECT fzgre.GUID_SPCI
              , spci.SPCI_DOCUMENT_NUMBER
              , spci.SPCI_DATE
              , (SELECT COUNT(1) FROM TFZGRECHNUNG@SIMEX_DB_LINK WHERE GUID_SPCI = spci.GUID_SPCI) 
              , (SELECT decode ( spc.SPC_VARIANT, 0, 'oneTime' , 1, 'monthly' )
                   FROM TSP_CONTRACT@SIMEX_DB_LINK spc
                  WHERE spc.GUID_SPC = fzgre.GUID_SPC)
           INTO v_GUID_SPCI
              , v_SPCI_DOCUMENT_NUMBER
              , v_SPCI_DATE
              , v_count_collinv
              , v_supplierPaymentInterval
           FROM TSP_COLLECTIVE_INVOICE@SIMEX_DB_LINK  spci
           JOIN TFZGRECHNUNG@SIMEX_DB_LINK    fzgre ON spci.GUID_SPCI       = fzgre.GUID_SPCI
          WHERE fzgre.ID_SEQ_FZGRECHNUNG    = I_ID_SEQ_FZGRECHNUNG
            AND fzgre.GUID_SPCI IS NOT NULL;
                   
       EXCEPTION WHEN no_data_found THEN NULL;
         
       END;  
     END IF;
     
     -- Knoten muss bei CostCollective <cost> heissen, und bei Cost sowie auch CostFull <parameter>
     select XMLELEMENT ( evalname(decode(i_exporttype, pck_calculation.c_exptype_costcollective, 'cost', 'parameter'))
                  , xmlattributes
                         ( 'cost_pl:CostType'                                 AS "xsi:type"
                         , fzgre.FZGRE_BELEGNR                                AS "externalPartnerCostID"
                         , to_char ( fzgre.FZGRE_BELEGDATUM, 'YYYYMMDD' )     AS "invoiceDate"
                         , to_char ( fzgre.FZGRE_REPDATUM,   'YYYYMMDD' )     AS "repairDate"
                         , substr ( fzgre.FZGRE_DOCUMENT_NUMBER2, 1, 10 )     AS "barcodeNumber"
                         , 'false'                                            AS "changeIndicator"
                         , to_char ( fzgre.FZGRE_CREATED,     'YYYYMMDD')     AS "claimingSystemEntryDate"
                         , ( select to_char(JO_BEGIN, 'YYYYMMDD')
                               from TJOURNAL@SIMEX_DB_LINK jou, TJOURNAL_POSITION@SIMEX_DB_LINK joup
                              where joup.GUID_JOT IN ( '9', '12', '77' )        --- 9 = SAP WORKSHOP / 12 = SAP FWD / 77 = SPP Buchungsanweisung
                                and jou.GUID_JO = joup.GUID_JO
                                and JOP_FOREIGN = nvl ( CASE WHEN v_count_collinv > 1 THEN v_GUID_SPCI ELSE NULL END
                                         , to_char ( fzgre.ID_SEQ_FZGRECHNUNG ))) AS "conversionDate"
                         , 'false'                                            AS "customerPrepaid"
                         , to_char ( i_consistent_datetime, 'YYYYMMDD' )      AS "entryDate"
                         , pck_calculation.SUBSTITUTE
                                          ( G_TAS_GUID
                                          , G_TIMESTAMP
                                          , 'BELART_INVOICE_OR_CNOTE'
                                          , bel.BELART_INVOICE_OR_CNOTE )     AS "financialDocumentDefinition"
                         , pck_calculation.SUBSTITUTE
                                          ( G_TAS_GUID
                                          , G_TIMESTAMP
                                          , 'FZGRE_CREATOR'
                                          , fzgre.FZGRE_CREATOR )             AS "financialDocumentSource"
                         , ( select to_char(JO_BEGIN, 'YYYYMMDD')
                               from TJOURNAL@SIMEX_DB_LINK jou, TJOURNAL_POSITION@SIMEX_DB_LINK joup
                              where joup.GUID_JOT IN ( '9', '12', '77' )        --- 9 = SAP WORKSHOP / 12 = SAP FWD / 77 = SPP Buchungsanweisung
                                and jou.GUID_JO = joup.GUID_JO
                                and JOP_FOREIGN = nvl ( CASE WHEN v_count_collinv > 1 THEN v_GUID_SPCI ELSE NULL END
                                         , to_char ( fzgre.ID_SEQ_FZGRECHNUNG ))) AS "financialSystemTransferDate"
                         ---------------------------------------------------------------------------------------------------------
                         , case when G_COUNTRY_CODE = '51331'                        -- A) l�nderweiche MBBEL
                                then case when v_count_collinv > 1
                                          then 'SPMP'                                   -- I)  bei einem MBBEL expCollectiveWorkshopInv aufruf 
                                          else                                          -- II) bei einem MBBEL expWorkshopInvoice       aufruf
                                               case when gar.GAR_GARNOVEGA = '11924'
                                                    then 'SPIN'                            -- bei MBBEL expWorkshopInvoice GAR_GARNOVEGA  = 11924
                                                    else 'WSIN'                            -- bei MBBEL expWorkshopInvoice GAR_GARNOVEGA <> 11924
                                               end
                                     end
                                else pck_calculation.SUBSTITUTE                      -- B) generell nicht MBBEL (- sowohl expWorkshopInvoice als auch expCollectiveWorkshopInv )
                                                    ( G_TAS_GUID
                                                    , G_TIMESTAMP
                                                    , 'ID_IMP_TYPE'
                                                    , fzgre.ID_IMP_TYPE )
                           end                                                   AS "workshopInvoiceDefinition"
                         ---------------------------------------------------------------------------------------------------------
                         , decode ( repRel.REPR_NUMBER
                                   , null, null
                                         , 'SIRIUS'  || repRel.REPR_NUMBER )     AS "repairAuthorization"
                         , '0'                                                   AS "updateCounter"
                         , coalesce( 
                             I_Cost_externalId_praefix 
                           , CASE
                               WHEN v_count_collinv > 1
                                 THEN v_SPCI_DOCUMENT_NUMBER 
                                      || '_' || gar.GAR_GARNOVEGA
                                      || '_' || to_char ( v_SPCI_DATE, 'YYYY' ) 
                                      || '_' || upper ( substr ( pck_calculation.SUBSTITUTE ( G_TAS_GUID, G_TIMESTAMP
                                                                                            , 'BELART_INVOICE_OR_CNOTE', bel.BELART_INVOICE_OR_CNOTE )
                                                               , 1, 1 )) 
                                      || '_'
                                 ELSE NULL
                             END)|| fzgre.ID_SEQ_FZGRECHNUNG                     AS "externalId"
                         , G_SourceSystem                                        AS "sourceSystem"
                         , G_masterDataReleaseVersion                            as "masterDataReleaseVersion"
                         , G_migrationDate                                       as "migrationDate" 
                         ) -- end of <cost> / <parameter> attributes
                      , XMLELEMENT ( "activeDamageCollection"
                        , PCK_COST.get_costDamage_COLL 
                          ( I_ID_SEQ_FZGRECHNUNG      => fzgre.ID_SEQ_FZGRECHNUNG
                          , i_supplierPaymentInterval => coalesce (i_supplierPaymentInterval,CASE WHEN v_count_collinv > 1 THEN v_supplierPaymentInterval ELSE NULL END)
                          , i_supplierMonthlyPeriod   => coalesce (i_supplierMonthlyPeriod,  CASE WHEN v_count_collinv > 1 THEN  to_char ( fzgre.FZGRE_PERIOD, 'YYYYMMDD' ) ELSE NULL END)
                          , i_taxation                => pck_calculation.substitute
                                                         ( G_TAS_GUID
                                                         , G_TIMESTAMP
                                                         , 'TAXATION_COST'
                                                         , gar.ID_GARAGETYP || '#' || decode ( bel.BELART_INVOICE_OR_CNOTE, 0, 'I', 'C' ))) AS "damage" 
                      )
                      , (select XMLAGG ( XMLELEMENT ( "activeState"
                        , xmlattributes
                          ( 'cost_pl:CostStateType'                          AS "xsi:type" 
                          , 'exported'                                       AS "status"
                          , PCK_CALCULATION.SUBSTITUTE   ( G_TAS_GUID
                                                         , G_TIMESTAMP
                                                         , 'CUR_CODE'
                                                         , cur.CUR_CODE )      AS "currency"
                          , PCK_CALCULATION.G_DFLT_TENANT_CURR               AS "defaultTenantCurrency"
                          , nvl ( round ( sum ((                             ip.IP_LISTPRICE 
                                                                         + ( ip.IP_LISTPRICE * ip.IP_SALESTAX / 100 ))), 8 ), 0 ) AS "grossAmount"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE                          ), 8 ), 0 ) AS "netAmount"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 11, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "labourInvoiceAmountNet"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 12, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "partsInvoiceAmountNet"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 13, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "subletsInvoiceAmountNet"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE - ip.IP_REJECT_SUM ),       8 ), 0 ) AS "amountNetAccepted"
                          , nvl ( round ( sum (                                                ip.IP_REJECT_SUM       ), 8 ), 0 ) AS "amountNetDeclined"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE                          ), 8 ), 0 ) AS "netAmountInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 11, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "labourInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 12, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "partsInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum ( decode ( ip.IP_CARDTYPE, 13, ip.IP_LISTPRICE                     , 0 )), 8 ), 0 ) AS "subletsInvoiceAmountNetInTenantCurrency"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE - ip.IP_REJECT_SUM ),       8 ), 0 ) AS "amountNetAcceptedInTenantCurrency"
                          , nvl ( round ( sum (                                                ip.IP_REJECT_SUM       ), 8 ), 0 ) AS "amountNetDeclinedInTenantCurrency"
                          , nvl ( round ( sum (                              ip.IP_LISTPRICE * ip.IP_SALESTAX / 100   ), 8 ), 0 ) AS "taxAmount" )))
                          from TINV_POSITION@SIMEX_DB_LINK ip
                         where ip.ID_SEQ_FZGRECHNUNG = fzgre.ID_SEQ_FZGRECHNUNG 
                         GROUP BY 1)                                                                                                        AS "activeState"
                      , XMLELEMENT ( "financialDocumentIssuer"
                             , xmlattributes ( 'partner_pl:OrganisationalPersonType'                AS "xsi:type"
                                         -- MKS-534909; TK; Changing Prefix to switch between Workshop and Supplier
                                         -- Function return 'W' for Workshop, which is OK for Referencing, 
                                         -- Function return 'S' for Supplier, which must be replaces by '' to reference to the supplier object correctly
                                         , nvl2(part.ID_GARAGE,CASE WHEN gar.gar_is_service_provider = 1 OR G_COUNTRY_CODE = '51331' and gar.gar_garnovega = '11924' 
                                                                    THEN '' ELSE 'W' 
                                                               END, 'ORA-20000: Workshop does not exist')
                                           || part.ID_GARAGE                                                              AS "externalId"
                                         , G_SourceSystem                                                                 AS "sourceSystem" ))
                      -- MKS-136593 Do not deliver "odometer" if fzgre_laufstrecke in (0,1) regardless of Cost Type.
                      , CASE
                          WHEN fzgre.fzgre_laufstrecke not in (0,1)
                            THEN 
                              XMLELEMENT ( "odometer"
                               , xmlattributes
                                 ( fzgre.fzgre_laufstrecke                          AS "mileage"  
                                 , CASE fzgre.fzgre_laufstrecke
                                     WHEN 0 THEN 'false'
                                     WHEN 1 THEN 'false'
                                     ELSE 'true'
                                   END                                              AS "calculationRelevant"
                                 , 'reportedMileage'                                AS "mileageState"
                                 , to_char(fzgre.fzgre_repdatum, 'YYYYMMDD')        AS "readingDate"
                                 , 'workshopInvoice'                                AS "sourceDefinition"
                                 , 'migration'   	                                 AS "sourceSystem"
                                 , CASE fzgre.fzgre_laufstrecke
                                     WHEN 0 THEN 'false'
                                     WHEN 1 THEN 'false'
                                     ELSE 'true'
                                   END                                              AS "valid" )
                              )
                        END                                                                                                                 AS "odometer"
                      )
       into L_COST
       from TREP_RELEASE@SIMEX_DB_LINK    repRel
          , TCUSTOMER@SIMEX_DB_LINK       cust
          , TGARAGE@SIMEX_DB_LINK         gar
          , TPARTNER@SIMEX_DB_LINK        part
          , TBELEGARTEN@SIMEX_DB_LINK     bel
          , TCURRENCY@SIMEX_DB_LINK       cur
          , TFZGRECHNUNG@SIMEX_DB_LINK    fzgre
      where fzgre.ID_CURRENCY           = cur.ID_CURRENCY
        and fzgre.GUID_REP_RELEASE      = repRel.GUID_REP_RELEASE (+)
        and fzgre.ID_SEQ_FZGRECHNUNG    = I_ID_SEQ_FZGRECHNUNG
        and fzgre.ID_BELEGART           = bel.id_belegart 
        and fzgre.GUID_PARTNER          = part.GUID_PARTNER
        and gar.ID_GARAGE           (+) = part.ID_GARAGE
        and cust.ID_CUSTOMER        (+) = part.ID_CUSTOMER;
       
       return L_COST;
   EXCEPTION WHEN OTHERS THEN
       PCK_EXPORTER.SiMEXlog (G_TAS_GUID, '0005', 'I_ID_SEQ_FZGRECHNUNG='||I_ID_SEQ_FZGRECHNUNG||','
                                                  ||'I_GUID_SPCI='||I_GUID_SPCI||','
                                                  ||'I_Cost_externalId_praefix='|| I_Cost_externalId_praefix    ||','
                                                  ||'i_supplierPaymentInterval='|| i_supplierPaymentInterval    ||','
                                                  ||'i_supplierMonthlyPeriod='|| i_supplierMonthlyPeriod 
                                                  ||'v_GUID_SPCI='||v_GUID_SPCI              	||','
                                                  ||'v_Cost_externalId_praefix='||v_Cost_externalId_praefix||','
                                                  ||'v_supplierPaymentInterval='||v_supplierPaymentInterval||','
                                                  ||'v_count_collinv='||v_count_collinv          ||','
                                                  ||'v_SPCI_DOCUMENT_NUMBER='||v_SPCI_DOCUMENT_NUMBER   ||','
                                                  ||'v_SPCI_DATE='||v_SPCI_DATE
                                                  );     
                             RAISE;
   end get_cost;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   
   
   FUNCTION expWorkshopInvoice ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                               , i_export_path           VARCHAR2
                               , i_export_type           VARCHAR2 := pck_calculation.c_exptype_Cost
                               , i_filename              VARCHAR2
                               , i_TAS_MAX_NODES         INTEGER
                               , o_FILE_RUNNING_NO   OUT INTEGER )
      RETURN NUMBER
   IS
      --  PURPOSE
      --
      --  PARAMETERS
      --    In-Parameter
      --    Return bei Funktionen
      --      0 = success
      --     -1 = fail
      --  DATABASE TRANSACTIONBEHAVIOR
      --    atomic
      --  EXCEPTIONS
      --    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      --  ZBerger     2013-10-17 MKS-121600:1 creation
      --  FraBe       2013-10-31 MKS-121600:2 add neuen code
      --  FraBe       2013-11-05 MKS-121600:2 rename damageCollections to activeDamageCollection
      --                                      rename states to activeState plus neue position gleich nach damage
      --                                      costDamageCoverage mappt auf costDamageCoverage_il - http://common.icon.daimler.com/il
      --                                      und nicht auf costDamageCoverageCollection ...
      --  ZBerger     2013-11-05 MKS-121600:1 Implement missing nodes
      --  FraBe       2013-11-13 MKS-121600:2 new i_taxation logic: pck_calculation.substitute - gar.ID_GARAGETYP
      --  ZBerger     2013-11-22 MKS-121604:2 Implement missing pck_calculation.substitute-call
      --  ZBerger     2014-04-14 MKS-131285:1 Wave 3.2
      --  FraBe       2014-04-17 MKS-131284:2 nachtr�gliche wave1 implementierung (-> alle wave1 sachen, die nicht ge�ndert wurden bei wave3.2 
      --                                      -> diese sind ja schon bei 3.2 umgesetzt )
      --  FraBe       2014-04-25 MKS-131289:1 some small fixing
      --  FraBe       2014-04-28 MKS-132489:1 concatenate financialDocumentIssuer - externalId - ID_GARAGE with leading 'W'
      --  FraBe       2014-05-06 MKS-131815:1 / 132654:1: correct crec for loop where
      --                                      plus: fix ID_CURRENCY statt CUR_CODE - umschl�sselungs- bug
      --                                      plus: xmlelement "cost" in function get_cost auslagern
      --                                      plus: jene L_* vars, die global verwendet werden, global definieren (-> G_* vars )
      --  FraBe       2014-11-05 MKS-134457:1 / 134458:1 add WavePreInt4 according ANDE / new order by
      -------------------------------------------------------------------------------
      l_ret                      INTEGER        DEFAULT 0;
      l_ret_main                 INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT    VARCHAR2 (100) DEFAULT 'expWorkshopInvoice';
      l_xml                      XMLTYPE;
      L_STAT                     VARCHAR2  (1) := NULL;
      L_ROWCOUNT                 INTEGER;
      L_filename                 varchar2 ( 100 char );
      
      CURSOR invoices(a_export_type VARCHAR2) IS
      select fzgre.ID_SEQ_FZGRECHNUNG, fzgre.ID_VERTRAG || '/' || fzgre.ID_FZGVERTRAG||'#'||fzgre.ID_SEQ_FZGRECHNUNG rn
        from TFZGRECHNUNG@SIMEX_DB_LINK     fzgre
           , TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
           , TDFCONTR_VARIANT@SIMEX_DB_LINK cv
           , TBELEGARTEN@SIMEX_DB_LINK      bel
       where cv.COV_CAPTION    not like 'MIG_OOS%'                   -- -> nur von InScope CO
         and cv.ID_COV                = fzgvc.ID_COV
         and fzgre.ID_VERTRAG         = fzgvc.ID_VERTRAG
         and fzgre.ID_FZGVERTRAG      = fzgvc.ID_FZGVERTRAG
         and fzgre.ID_IMP_TYPE   not in ( 9, 10 )                    -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
         and fzgre.ID_BELEGART        = bel.ID_BELEGART
         and 1                        = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
         and (a_export_type = pck_calculation.c_exptype_CostFull
              OR 
              (a_export_type = pck_calculation.c_exptype_Cost 
               AND ( fzgre.GUID_SPCI is     null                          -- -> keine SPP Sammelrechnung
                     or 
                     exists ( select null -- -> oder SPP Sammelrechnung, die aus nur einer Einzelrechnung besteht
                                from TFZGRECHNUNG@SIMEX_DB_LINK fzgre1
                               where fzgre.GUID_SPCI = fzgre1.GUID_SPCI
                              having COUNT(1)        = 1 )
                   )
              )
             )
       order by fzgre.ID_VERTRAG, fzgre.ID_FZGVERTRAG, fzgre.ID_SEQ_FZGRECHNUNG;

      TYPE t_invtab              IS TABLE OF invoices%ROWTYPE INDEX BY PLS_INTEGER;
      v_invtab                   t_invtab;

      FUNCTION cre_workshopinvoice_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, G_FILECOUNT_FILLER, 0 )) || '.xml' );
         G_TAS_GUID          := i_TAS_GUID;                                                                    --- hier handelt es sich um 2 globale vars, 
         G_TIMESTAMP         := SYSTIMESTAMP;                                                                  --- die am anfang der package definiert sind
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         AS "xmlns:partner_pl"
                                           , 'http://cost.icon.daimler.com/pl'            AS "xmlns:cost_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              AS "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20141020_CIM_EDF_Cost_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: ' || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType'       AS "xsi:type"
                                    , g_expdatetime                         AS "dateTime"
                                    , pck_calculation.G_USERID              AS "userId"
                                    , pck_calculation.G_TENANT_ID           AS "tenantId"
                                    , G_causation                           AS "causation"
                                    , o_FILE_RUNNING_NO                     AS "additionalInformation1"
                                    , G_correlationID                       AS "correlationId"
                                    , G_issueThreshold                      AS "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createWorkshopFinancialDocument' AS "operation"  )
                                                       , PCK_COST.get_COST           ( I_ID_SEQ_FZGRECHNUNG        => x.PK_VALUE_NUM
                                                                                     , I_GUID_SPCI                 => null
                                                                                     , I_Cost_externalId_praefix   => null
                                                                                     -- MKS-134909 prefix determination moved to getCost
                                                                                     --, I_FinDoc_externalId_praefix => 'W'
                                                                                     , i_supplierPaymentInterval   => null
                                                                                     , i_supplierMonthlyPeriod     => null 
                                                                                     , i_consistent_datetime       => G_TIMESTAMP
                                                                                     , i_exporttype                => i_export_type)   AS "parameter"
                                                       , PCK_COST.get_costDamage_COV ( I_ID_SEQ_FZGRECHNUNG        => x.PK_VALUE_NUM
                                                                                     , I_XMLELEMENT_EVALNAME       => 'parameter' )    AS "parameter" )
                                order by substr(x.PK_VALUE_CHAR,1,instr(x.PK_VALUE_CHAR,'#')-1), x.PK_VALUE_NUM )
                                 from TXML_SPLIT x
                             )
                           ).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || v_invtab.count || ' workshop-invoices' );

         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (v_invtab.count) || ' workshop-invoice nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_workshopinvoice_xml;
      
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;
      PCK_EXPORTER.SiMEXlog (i_TAS_GUID, '0014','Opening invoices '||i_export_type);
      OPEN invoices(i_export_type);
      
      LOOP
        
        FETCH invoices 
         BULK COLLECT INTO v_invtab
        LIMIT i_TAS_MAX_NODES;
       
        EXIT WHEN v_invtab.count = 0;

        FORALL i IN 1..v_invtab.count
          -- PK_VALUE_CHAR is filled for ordering purposes
          INSERT INTO TXML_SPLIT ( PK_VALUE_NUM , PK_VALUE_CHAR)
              VALUES ( v_invtab(i).ID_SEQ_FZGRECHNUNG, v_invtab(i).rn );

          l_ret      := cre_workshopinvoice_xml;

          DELETE TXML_SPLIT;
          
          IF l_ret        = -1 THEN
            l_ret_main   := -1;
          END IF;
         
      END LOOP;
      
      CLOSE invoices;
      
      RETURN l_ret_main;
   EXCEPTION
      WHEN pck_calculation.AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => dbms_utility.format_error_backtrace|| SQLERRM );
         RETURN -1;                                                    -- fail
   END expWorkshopInvoice;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expCollectiveWorkshopInv ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                                     , i_export_path           VARCHAR2
                                     , i_filename              VARCHAR2
                                     , i_TAS_MAX_NODES         INTEGER
                                     , o_FILE_RUNNING_NO   OUT INTEGER )
      RETURN NUMBER
   IS
      --  PURPOSE
      --
      --  PARAMETERS
      --    In-Parameter
      --    Return bei Funktionen
      --      0 = success
      --     -1 = fail
      --  DATABASE TRANSACTIONBEHAVIOR
      --    atomic
      --  EXCEPTIONS
      --    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      --  FraBe       2014-05-06 MKS-131815:1 creation
      --  FraBe       2014-11-08 MKS-134470:1 / 134471:1 add WavePreInt4 according ANDE
      -------------------------------------------------------------------------------
      l_ret                      INTEGER        DEFAULT 0;
      l_ret_main                 INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT    VARCHAR2 (100) DEFAULT 'expCollectiveWorkshopInv';
      l_xml                      XMLTYPE;
      l_xml_out                  XMLTYPE;
      L_STAT                     VARCHAR2  (1) := NULL;
      L_ROWCOUNT                 INTEGER;
      L_filename                 varchar2 ( 100 char );

      FUNCTION cre_CollectiveWorkshopInv_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, G_FILECOUNT_FILLER, 0 )) || '.xml' );
         G_TAS_GUID          := i_TAS_GUID;                                                                    --- hier handelt es sich um 2 globale vars, 
         G_TIMESTAMP         := SYSTIMESTAMP;                                                                  --- die am anfang der package definiert sind
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         AS "xmlns:partner_pl"
                                           , 'http://cost.icon.daimler.com/pl'            AS "xmlns:cost_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              AS "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20141020_CIM_EDF_CostCollective_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: ' || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                    , g_expdatetime                   AS "dateTime"
                                    , pck_calculation.G_USERID        AS "userId"
                                    , pck_calculation.G_TENANT_ID     AS "tenantId"
                                    , G_causation                     AS "causation"
                                    , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                    , G_correlationID                 AS "correlationId"
                                    , G_issueThreshold                AS "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createCollectiveWorkshopFinancialDocument' AS "operation"  )
                                                  , XMLELEMENT ( "parameter"
                                                       , xmlattributes
                                                              ( 'cost_pl:CostCollectiveType'                       AS "xsi:type"
                                                              , to_char ( spci.SPCI_DATE,        'YYYYMMDD' )      AS "invoiceDate"
                                                              , to_char ( spci.SPCI_REPAIR_DATE, 'YYYYMMDD' )      AS "repairDate"
                                                              , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                                           , G_TIMESTAMP
                                                                                           , 'CUR_CODE'
                                                                                           , cur1.CUR_CODE )       AS "currency"
                                                              , substr ( spci.SPCI_DOCUMENT_NUMBER2, 1, 10 )       AS "externalPartnerCostID"
                                                              , ip_sum.financialDocumentDefinition                 AS "financialDocumentDefinition"
                                                              , ip_sum.netAmount + ip_sum.taxAmount                AS "grossAmount"
                                                              , ip_sum.netAmount                                   AS "netAmount"
                                                              , ip_sum.labourInvoiceAmountNet                      as "labourInvoiceAmountNet"
                                                              , ip_sum.partsInvoiceAmountNet                       as "partsInvoiceAmountNet"
                                                              , ip_sum.subletsInvoiceAmountNet                     as "subletsInvoiceAmountNet"
                                                              , ip_sum.taxAmount                                   as "taxAmount"
                                                              , 'exported'                                         as "status"
                                                              , case G_COUNTRY_CODE
                                                                     when '51331' then 'SPMP'
                                                                     else              'SPMP'
                                                                end                                                as "workshopInvoiceDefinition"
                                                              , spci.SPCI_DOCUMENT_NUMBER 
                                                                   || '_' || gar1.GAR_GARNOVEGA
                                                                   || '_' || to_char ( spci.SPCI_DATE, 'YYYY' )
                                                                   || '_' || upper ( substr ( ip_sum.financialDocumentDefinition, 1, 1 ))
                                                                                                                   as "externalId"
                                                              , G_SourceSystem                                     as "sourceSystem"
                                                              , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                              , G_migrationDate                                    as "migrationDate" )
                                                       , ( select XMLAGG ( PCK_COST.get_COST  ( I_ID_SEQ_FZGRECHNUNG        => fzgre.ID_SEQ_FZGRECHNUNG
                                                                                              , I_GUID_SPCI                 => fzgre.GUID_SPCI
                                                                                              , I_Cost_externalId_praefix   => spci.SPCI_DOCUMENT_NUMBER 
                                                                                                                                  || '_' || gar1.GAR_GARNOVEGA
                                                                                                                                  || '_' || to_char ( spci.SPCI_DATE, 'YYYY' ) 
                                                                                                                                  || '_' || upper ( substr ( financialDocumentDefinition, 1, 1 )) 
                                                                                                                                  || '_' 
                                                                                              -- MKS-134909 prefix determination moved to getCost
                                                                                              --, I_FinDoc_externalId_praefix => null
                                                                                              , i_supplierPaymentInterval   => decode ( spc.SPC_VARIANT
                                                                                                                                      , 0, 'oneTime'
                                                                                                                                      , 1, 'monthly' )
                                                                                              , i_supplierMonthlyPeriod     => to_char ( fzgre.FZGRE_PERIOD, 'YYYYMMDD' )
                                                                                              , i_consistent_datetime       => G_TIMESTAMP
                                                                                              , i_exporttype                => pck_calculation.c_exptype_costcollective
                                                                                              )  -- AS "cost" 
                                                                  order by fzgre.ID_VERTRAG, fzgre.ID_FZGVERTRAG, fzgre.ID_SEQ_FZGRECHNUNG )
                                                             from TSP_CONTRACT@SIMEX_DB_LINK      spc
                                                                , TDFCONTR_VARIANT@SIMEX_DB_LINK  cv
                                                                , TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                                                                , TBELEGARTEN@SIMEX_DB_LINK       bel
                                                                , TFZGRECHNUNG@SIMEX_DB_LINK      fzgre
                                                            where cv.COV_CAPTION         not like 'MIG_OOS%'                   -- -> nur von InScope CO
                                                              and cv.ID_COV                     = fzgvc.ID_COV
                                                              and fzgre.ID_VERTRAG              = fzgvc.ID_VERTRAG
                                                              and fzgre.ID_FZGVERTRAG           = fzgvc.ID_FZGVERTRAG
                                                              and fzgre.GUID_SPC                = spc.GUID_SPC
                                                              and bel.BELART_SUM_INVOICE        = 1                            -- -> keine INFO - INV/CN
                                                              and fzgre.ID_BELEGART             = bel.ID_BELEGART
                                                              and fzgre.GUID_SPCI               = ip_sum.GUID_SPCI
                                                              and bel.BELART_INVOICE_OR_CNOTE   = ip_sum.BELART_INVOICE_OR_CNOTE )
                                                       , XMLELEMENT ( "financialDocumentIssuer"
                                                              , xmlattributes ( 'partner_pl:OrganisationalPersonType'                AS "xsi:type"
                                                                          -- MKS-534909; TK; Changing Prefix to switch between Workshop and Supplier
                                                                          -- Function return 'W' for Workshop, which is OK for Referencing, 
                                                                          -- Function return 'S' for Supplier, which must be replaces by '' to reference to the supplier object correctly
                                                                          , replace ( pck_calculation.getWorkshopOrSupplier ( part1.ID_GARAGE ), 'S', '' )
                                                                                                                           || part1.ID_GARAGE               AS "externalId"
                                                                          , G_SourceSystem                                                                  AS "sourceSystem" )))
                                                  , get_costCovColl ( i_GUID_SPCI            => ip_sum.GUID_SPCI
                                                                    , I_externalId_praefix   => spci.SPCI_DOCUMENT_NUMBER 
                                                                                                   || '_' || gar1.GAR_GARNOVEGA
                                                                                                   || '_' || to_char ( spci.SPCI_DATE, 'YYYY' ) 
                                                                                                   || '_' || upper ( substr( financialDocumentDefinition, 1, 1 )) 
                                                                                                   || '_' ) AS "CostCoverageCollection"  
                                                  )
                                       order by spci.GUID_SPCI )
                                  from TSP_COLLECTIVE_INVOICE@SIMEX_DB_LINK spci
                                     , TCURRENCY@SIMEX_DB_LINK              cur1
                                     , TGARAGE@SIMEX_DB_LINK                gar1
                                     , TPARTNER@SIMEX_DB_LINK               part1
                                     , ( select fzgre1.GUID_SPCI
                                              , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                           , G_TIMESTAMP
                                                                           , 'BELART_INVOICE_OR_CNOTE'
                                                                           , bel1.BELART_INVOICE_OR_CNOTE )                          AS financialDocumentDefinition
                                              , bel1.BELART_INVOICE_OR_CNOTE
                                              , nvl ( round ( sum (                               ip1.IP_LISTPRICE ),      8 ), 0 )  as netAmount
                                              , nvl ( round ( sum ( decode ( ip1.IP_CARDTYPE, 11, ip1.IP_LISTPRICE, 0 )),  8 ), 0 )  as labourInvoiceAmountNet
                                              , nvl ( round ( sum ( decode ( ip1.IP_CARDTYPE, 12, ip1.IP_LISTPRICE, 0 )),  8 ), 0 )  as partsInvoiceAmountNet
                                              , nvl ( round ( sum ( decode ( ip1.IP_CARDTYPE, 13, ip1.IP_LISTPRICE, 0 )),  8 ), 0 )  as subletsInvoiceAmountNet
                                              , nvl ( round ( sum (                               ip1.IP_LISTPRICE 
                                                                                                * ip1.IP_SALESTAX / 100 ), 8 ), 0 )  as taxAmount 
                                           from TDFCONTR_VARIANT@SIMEX_DB_LINK  cv1
                                              , TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc1
                                              , TBELEGARTEN@SIMEX_DB_LINK       bel1
                                              , TINV_POSITION@SIMEX_DB_LINK     ip1
                                              , TFZGRECHNUNG@SIMEX_DB_LINK      fzgre1
                                              , TXML_SPLIT                      x
                                          where cv1.COV_CAPTION    not like 'MIG_OOS%'                   -- -> nur von InScope CO
                                            and cv1.ID_COV                = fzgvc1.ID_COV
                                            and fzgre1.ID_VERTRAG         = fzgvc1.ID_VERTRAG
                                            and fzgre1.ID_FZGVERTRAG      = fzgvc1.ID_FZGVERTRAG
                                            and fzgre1.ID_BELEGART        = bel1.ID_BELEGART
                                            and 1                         = bel1.BELART_SUM_INVOICE      -- -> keine INFO - INV/CN
                                            and fzgre1.GUID_SPCI          = x.PK_VALUE_CHAR
                                            and fzgre1.ID_SEQ_FZGRECHNUNG = ip1.ID_SEQ_FZGRECHNUNG
                                          group by fzgre1.GUID_SPCI
                                                 , bel1.BELART_INVOICE_OR_CNOTE
                                                 , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                              , G_TIMESTAMP
                                                                              , 'BELART_INVOICE_OR_CNOTE'
                                                                              , bel1.BELART_INVOICE_OR_CNOTE )
                                          order by fzgre1.GUID_SPCI ) ip_sum
                                 where gar1.ID_GARAGE             = part1.ID_GARAGE
                                   and spci.GUID_PARTNER          = part1.GUID_PARTNER
                                   and spci.ID_CURRENCY           = cur1.ID_CURRENCY
                                   and spci.GUID_SPCI             = ip_sum.GUID_SPCI
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' collective workshop-invoices' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' collective workshop-invoice nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_CollectiveWorkshopInv_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN (   select distinct spci.GUID_SPCI
                        from TSP_COLLECTIVE_INVOICE@SIMEX_DB_LINK spci
                           , TFZGRECHNUNG@SIMEX_DB_LINK           fzgre
                           , TFZGV_CONTRACTS@SIMEX_DB_LINK        fzgvc
                           , TDFCONTR_VARIANT@SIMEX_DB_LINK       cv
                           , TBELEGARTEN@SIMEX_DB_LINK            bel
                       where cv.COV_CAPTION    not like 'MIG_OOS%'                   -- -> nur von InScope CO
                         and fzgre.ID_VERTRAG         = fzgvc.ID_VERTRAG
                         and fzgre.ID_FZGVERTRAG      = fzgvc.ID_FZGVERTRAG
                         and cv.ID_COV                = fzgvc.ID_COV
                         and fzgre.ID_IMP_TYPE   not in ( 9, 10 )                    -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
                         and fzgre.ID_BELEGART        = bel.ID_BELEGART
                         and 1                        = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
                         and fzgre.GUID_SPCI          = spci.GUID_SPCI
                  --     and fzgre.GUID_SPCI          = '417710B5F0D2471DB07FB115D2ED3C01'
                         and exists ( select null                                    -- -> nur SPP Sammelrechnungen, die aus mehr als einer Einzelrechnung bestehen
                                        from TFZGRECHNUNG@SIMEX_DB_LINK fzgre1
                                       where fzgre.GUID_SPCI = fzgre1.GUID_SPCI
                                      having count(*)        > 1 )
                     order by 1 )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.GUID_SPCI );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_CollectiveWorkshopInv_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_CollectiveWorkshopInv_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN pck_calculation.AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expCollectiveWorkshopInv;

 -----------------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------------------------------------
 
    FUNCTION expAssignCostToCost ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                                 , i_export_path           VARCHAR2
                                 , i_filename              VARCHAR2
                                 , i_TAS_MAX_NODES         INTEGER
                                 , o_FILE_RUNNING_NO   OUT INTEGER )
       RETURN NUMBER
    IS
       --  PURPOSE
       --
       --  PARAMETERS
       --    In-Parameter
       --    Return bei Funktionen
       --      0 = success
       --     -1 = fail
       --  DATABASE TRANSACTIONBEHAVIOR
       --    atomic
       --  EXCEPTIONS
       --    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
       --    jeweils durchgef�hrten Plausibilit�tspr�fungen
       --    Auswirkungen auf den Bildschirm
       --    durchgef�hrten Protokollierung
       --    abgelegten Tracinginformationen
       --  ENDPURPOSE
       --  FraBe       2014-05-28 MKS-131308:1 creation
       --  MaZi        2014-10-16 MKS-134509:1 WavePreInt4 changes
       --  FraBe       2014-12-17 MKS-136026:1 do not extract VEGA and INFO CN!
       -------------------------------------------------------------------------------
       l_ret                      INTEGER        DEFAULT 0;
       l_ret_main                 INTEGER        DEFAULT 0;
       lc_sub_modul   CONSTANT    VARCHAR2 (100) DEFAULT 'expAssignCostToCost';
       l_xml                      XMLTYPE;
       l_xml_out                  XMLTYPE;
       L_STAT                     VARCHAR2  (1) := NULL;
       L_ROWCOUNT                 INTEGER;
       L_filename                 varchar2 ( 100 char );
 
       FUNCTION cre_AssignCostToCost_xml
          RETURN INTEGER
       IS
       BEGIN
          o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
          L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
          G_TAS_GUID          := i_TAS_GUID;                                                                    --- hier handelt es sich um 2 globale vars, 
          G_TIMESTAMP         := SYSTIMESTAMP;                                                                  --- die am anfang der package definiert sind
          --
          select XMLELEMENT ( "common:ServiceInvocationCollection"
                            , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                            , 'http://system.mdsd.ibm.com/sl'              AS "xmlns:mdsd_sl"
                                            , 'http://cost.icon.daimler.com/pl'            AS "xmlns:cost_pl"
                                            , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                            , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                            , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_AssignCostToCost_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                            , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                            , XMLCOMMENT ( 'Source-database: ' || G_DB_NAME_of_DB_LINK )
                            , XMLELEMENT ( "executionSettings"
                                 , xmlattributes
                                     ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                     , g_expdatetime                   AS "dateTime"
                                     , pck_calculation.G_USERID        AS "userId"
                                     , pck_calculation.G_TENANT_ID     AS "tenantId"
                                     , G_causation                     AS "causation"
                                     , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                     , G_correlationID                 AS "correlationId"
                                     , G_issueThreshold                AS "issueThreshold"
                                     ))
                            , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                   , xmlattributes ( 'assignCostToCost' AS "operation"  )
                                                   , XMLELEMENT ( "parameter"
                                                   -- DEF5015: parameter must have COST type
                                                   -- assignedCost
                                                              , xmlattributes ( 'cost_pl:CostType'             AS "xsi:type"
                                                                              , fzgre.FZGRE_REFERENZBUCHUNG    AS "externalId"
                                                                              , G_sourceSystem                 AS "sourceSystem" ))
                                                  , XMLELEMENT ( "parameter"
                                                   -- DEF5015: parameter must have COST type
                                                   --cnst
                                                                , xmlattributes ( 'cost_pl:CostType'           AS "xsi:type"
                                                                                , fzgre.ID_SEQ_FZGRECHNUNG     AS "externalId"
                                                                                , G_sourceSystem               AS "sourceSystem" )))
                                 order by x.PK_VALUE_NUM )
                                    from TFZGRECHNUNG@SIMEX_DB_LINK fzgre  
                                       , TXML_SPLIT                  x
                                   where x.PK_VALUE_NUM = fzgre.ID_SEQ_FZGRECHNUNG
                 )).EXTRACT ('.')
                 AS xml
            into l_xml
            from DUAL;
 
          PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                 , i_LOG_ID    => '0013'                  -- Gathering data finished
                                 , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' workshop-invoices' );
 
 
          pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
          PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID     => '0014'                  -- write xml file finished
                                , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' workshop-invoice nodes successfully written to file ' || L_filename);
 
          RETURN 0;                                                 --> success
       --
 
       END cre_AssignCostToCost_xml;
    BEGIN                                                          -- main part
       L_ROWCOUNT          := 0;
       o_FILE_RUNNING_NO   := 0;
 
       FOR crec IN (   select ID_SEQ_FZGRECHNUNG
                         from TFZGRECHNUNG@SIMEX_DB_LINK     fzgre
                            , TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                            , TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                            , TBELEGARTEN@SIMEX_DB_LINK      bel
                        where cv.COV_CAPTION        not like 'MIG_OOS%'                   -- -> nur von InScope CO
                          and cv.ID_COV                    = fzgvc.ID_COV
                          and fzgre.FZGRE_REFERENZBUCHUNG is not null
                       -- and fzgre.ID_SEQ_FZGRECHNUNG     = 168371
                          and fzgre.ID_VERTRAG             = fzgvc.ID_VERTRAG
                          and fzgre.ID_FZGVERTRAG          = fzgvc.ID_FZGVERTRAG
                          and fzgre.ID_IMP_TYPE       not in ( 9, 10 )                    -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
                          and fzgre.ID_BELEGART            = bel.ID_BELEGART
                          and 1                            = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
                          and 1                            = bel.BELART_INVOICE_OR_CNOTE  -- -> nur CN, keine INV
                          and fzgre.FZGRE_RESUMME         <> 0                            -- -> CN mu� einen betrag <> 0 haben ...
                          and exists ( select null from TFZGRECHNUNG@SIMEX_DB_LINK fzgre1 -- -> ... dieser mu� gleich dem abgelehnten betrag der verlinkten INV sein
                                        where fzgre1.ID_SEQ_FZGRECHNUNG   = fzgre.FZGRE_REFERENZBUCHUNG
                                          and fzgre1.FZGRE_SUM_REJECTED   = fzgre.FZGRE_RESUMME )
                   order by 1 )
       LOOP
          insert into TXML_SPLIT ( PK_VALUE_NUM )
               VALUES ( crec.ID_SEQ_FZGRECHNUNG );
 
          L_ROWCOUNT   := L_ROWCOUNT + 1;
 
          IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
             l_ret      := cre_AssignCostToCost_xml;
             COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
             L_ROWCOUNT   := 0;
 
             IF l_ret         = -1 THEN
                l_ret_main   := -1;
             END IF;
          END IF;
       END LOOP;
 
       IF L_ROWCOUNT > 0 THEN
          l_ret   := cre_AssignCostToCost_xml;
          COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
 
          IF l_ret         = -1 THEN
             l_ret_main   := -1;
          END IF;
       END IF;
 
       RETURN l_ret_main;
    EXCEPTION
       WHEN pck_calculation.AlreadyLogged THEN
          RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
       WHEN OTHERS THEN
          PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                                , i_LOG_TEXT   => SQLERRM );
          RETURN -1;                                                    -- fail
    END expAssignCostToCost;
    
 -----------------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------------------------------------
 
 END;
/
