CREATE OR REPLACE PACKAGE BODY SIMEX.PCK_REVENUE
IS
   --
   --
   -- MKSSTART
   --
   -- $CompanyInfo $
   --
   -- $Date: 2015/03/20 16:08:33MEZ $
   --
   -- $Name:  $
   --
   -- $Revision: 1.27 $
   --
   -- $Header: 5100_Code_Base/Database/Source/PCK_REVENUE.plb 1.27 2015/03/20 16:08:33MEZ Frank, Marina (marinf) CI_Changed  $
   --
   -- $Source: 5100_Code_Base/Database/Source/PCK_REVENUE.plb $
   --
   -- $Log: 5100_Code_Base/Database/Source/PCK_REVENUE.plb  $
   -- Revision 1.27 2015/03/20 16:08:33MEZ Frank, Marina (marinf) 
   -- MKS-151824:1 DEF8653 derive "dateTime" from global settings.
   -- Revision 1.26 2015/02/19 17:01:24MEZ Frank, Marina (marinf) 
   -- MKS-136397 Implemented LPAD for formatting iCON Contarct Number. 
   -- Due to potential loopback overhead via database link new function pck_calculation.contract_number_icon
   -- will be included only after optimizing query with restrictive DRIVING_SITE hints.
   -- Revision 1.25 2015/01/26 09:16:36MEZ Zimmerberger, Markus (zimmerb) 
   -- expRevenue/expRevenuePos: do not deliver invoices/positions with amount 0
   -- Revision 1.24 2014/11/27 18:16:57MEZ Kieninger, Tobias (tkienin) 
   -- FinancialDocumentReceiver:
   -- xsi:typ auf DealerAsCustomer erweitert
   -- Prefix D für DealerAsCustomer hinzugefügt
   -- Revision 1.23 2014/11/20 15:12:53MEZ Berger, Franz (fraberg) 
   -- get_revenueJOP_BEGIN: add I_CI_CREATION_DATE
   -- Revision 1.22 2014/10/30 11:31:35MEZ Berger, Franz (fraberg) 
   -- - get_adjmMileageIndicator: implement komplett neue logik / details siehe direkt bei function
   -- - expRevenuePos: add i_adjmMileageIndicator
   -- - expRevenue: add xmlattribute 'xsd:string' as "xsi:type" within the 3 parameter - subnodes
   -- Revision 1.21 2014/10/24 15:08:52MESZ Zimmerberger, Markus (zimmerb) 
   -- expRevenue / get_adjmMileageIndicator: WavePreInt4 changes/creation
   -- Revision 1.20 2014/09/17 14:22:43MESZ Kieninger, Tobias (tkienin) 
   -- merging
   -- Revision 1.19 2014/09/16 10:22:44MESZ Kieninger, Tobias (tkienin)
   -- Merging to Main Branch
   -- Revision 1.18 2014/07/03 09:26:03MESZ Kieninger, Tobias (tkienin)
   -- correct parameter order
   -- Revision 1.17 2014/06/16 11:19:46MESZ Kieninger, Tobias (tkienin)
   -- .
   -- Revision 1.16 2014/05/26 10:34:14MESZ Berger, Franz (fraberg)
   -- expRevenue / expRevenuePos: new financialDocumentReceiver - xsi_type / PeriodFrom/To logic
   -- Revision 1.15 2014/05/05 17:56:42MESZ Kieninger, Tobias (tkienin)
   -- external ID of revenue is now GUID_CI
   -- Revision 1.13 2014/04/30 18:23:49MESZ Berger, Franz (fraberg)
   -- get_revenueOdometer / fix_adjmMileageDecimal / fix_adjmMileageGrouping / fix_adjmMileageGrouping: some wave3.2 FX
   -- Revision 1.12 2014/04/23 11:42:36MESZ Zimmerberger, Markus (zimmerb)
   -- 20140227_CIM_EDF_Revenue_Mig_BEL_Wave3_2_iter1_v1.0 plus changes of 2013-12
   -- Revision 1.10 2013/11/23 18:57:50MEZ Berger, Franz (fraberg)
   -- expRevenue: neue taxation - logik
   -- Revision 1.9 2013/11/19 14:41:22MEZ Berger, Franz (fraberg)
   -- expRevenue: Completion V
   -- Revision 1.8 2013/11/19 12:53:42MEZ Berger, Franz (fraberg)
   -- expRevenue: Completion IV
   -- Revision 1.7 2013/11/19 08:31:53MEZ Berger, Franz (fraberg)
   -- expRevenue: Completion III
   -- Revision 1.6 2013/11/19 07:03:45MEZ Berger, Franz (fraberg)
   -- expRevenue: Completion II
   -- Revision 1.5 2013/11/18 17:55:57MEZ Zimmerberger, Markus (zimmerb)
   -- expRevenue: Completion
   -- Revision 1.4 2013/11/18 15:14:10MEZ Berger, Franz (fraberg)
   -- - add expRevenuePos
   -- - get_revenueJOP_BEGIN: l_costJOP_BEGIN auf dateTime umwandeln
   -- - expRevenue: add expRevenuePos aufruf plus ein paar kleinere korrekturen im code
   -- Revision 1.3 2013/11/16 07:39:45MEZ Berger, Franz (fraberg)
   -- move von PCK_EXPORTS:
   -- - expRevenue
   -- Revision 1.2 2013/11/13 15:28:08MEZ Zimmerberger, Markus (zimmerb)
   -- add get_revenueOdometer
   -- Revision 1.1 2013/11/12 16:04:12MEZ Zimmerberger, Markus (zimmerb)
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj

   -- MKSEND
   --
   -- Purpose: package for all SiMEX-Cost sub-functions/packages of cost-exports
   --
   -- MODIFICATION HISTORY
   -- Person      Date        Comments
   -- ---------   ----------  ------------------------------------------
   -- ZBerger     2013-11-12  MKS-123543:1 creation
   -- FraBe       2013-11-15  MKS-129687:1 add expRevenue
   -- FraBe       2013-11-18  MKS-123544:1 add expRevenuePos
   -- FraBe       2013-11-18  MKS-123544:1 get_revenueJOP_BEGIN: l_costJOP_BEGIN auf dateTime umwandeln
   -- FraBe       2013-11-18  MKS-123544:1 expRevenue: add expRevenuePos aufruf plus ein paar kleinere korrekturen im code
   -- ZBerger     2013-11-18  MKS-123544:1 expRevenue: Completion
   -- FraBe       2013-11-18  MKS-123544:1 expRevenue: Completion II
   -- FraBe       2013-11-18  MKS-123544:1 expRevenue: Completion III
   -- FraBe       2013-11-18  MKS-123544:2 expRevenue: Completion IV
   -- FraBe       2013-11-18  MKS-123544:2 expRevenue: Completion V
   -- FraBe       2013-11-23  MKS-123548:1 expRevenue: neue taxation - logik
   -- FraBe       2014-04-30  MKS-131277:2 get_revenueOdometer / fix_adjmMileageDecimal / fix_adjmMileageGrouping / fix_adjmMileageGrouping: some wave3.2 FX
   -- FraBe       2014-05-23  MKS-132872:1 expRevenue / expRevenuePos: new financialDocumentReceiver - xsi_type / PeriodFrom/To logic
   -- ZBerger     2014-10-24  MKS-134483:1 expRevenue / get_adjmMileageIndicator: WavePreInt4 changes/creation
   -- FraBe       2014-10-27  MKS-134489:1 get_adjmMileageIndicator: implement komplett neue logik / details siehe direkt bei function
   -- FraBe       2014-10-27  MKS-134489:1 expRevenuePos: add i_adjmMileageIndicator
   -- FraBe       2014-10-28  MKS-134489:1 expRevenue: add xmlattribute 'xsd:string' as "xsi:type" within the 3 parameter - subnodes
   -- FraBe       2014-11-20  MKS-135689:1 get_revenueJOP_BEGIN: add I_CI_CREATION_DATE
   -- ZBerger     2015-01-23  MKS-136330:1 expRevenue/expRevenuePos: do not deliver invoices/positions with amount 0
   
-----------------------------------------------------------------------------------------------------------------------------------------------------

   L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
   L_causation             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION', 'migration');
   L_migrationDate         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', TO_CHAR ( SYSDATE, 'YYYY-MM-DD') || 'T' || TO_CHAR ( SYSDATE, 'HH24:MI:SS'));
   L_odometerMileageState  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'ODOMETERMILEAGESTATE', null );
   L_issueThreshold        TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'ISSUETHRESHOLD', 'SIRIUS'    );
   G_TIMESTAMP             TIMESTAMP (6)           := SYSTIMESTAMP;
   g_expdatetime           TSETTING.SET_VALUE%TYPE := 
    CASE
      WHEN pck_calculation.g_expdatetime = '0'
        THEN to_char ( G_TIMESTAMP, pck_calculation.c_xmlDTfmt )
      ELSE pck_calculation.g_expdatetime 
    END;
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_revenueJOP_BEGIN 
          ( I_JOP_FOREIGN        TJOURNAL_POSITION.JOP_FOREIGN@SIMEX_DB_LINK%type
          , I_CI_CREATION_DATE   TCUSTOMER_INVOICE.CI_CREATED@SIMEX_DB_LINK%type
          ) RETURN               VARCHAR2

   IS
     l_costJOP_BEGIN  VARCHAR2(20 char);

   BEGIN
      -- ZBerger     2013-11-12  MKS-123543:1 creation
      -- FraBe       2013-11-18  MKS-123544:1 l_costJOP_BEGIN auf dateTime umwandeln
      -- FraBe       2014-11-20  MKS-135689:1 add I_CI_CREATION_DATE
      select to_char ( JO_BEGIN, 'YYYY-MM-DD' ) || 'T' || to_char ( JO_BEGIN, 'HH24:MI:SS' )
        into l_costJOP_BEGIN
        from TJOURNAL@SIMEX_DB_LINK jou, TJOURNAL_POSITION@SIMEX_DB_LINK joup
       where joup.GUID_JOT IN ( '10' )
         and jou.GUID_JO = joup.GUID_JO
         and JOP_FOREIGN = i_JOP_FOREIGN;

      return l_costJOP_BEGIN;
      
   exception when NO_DATA_FOUND then return to_char ( I_CI_CREATION_DATE, 'YYYY-MM-DD' ) || 'T' || to_char ( I_CI_CREATION_DATE, 'HH24:MI:SS' );
   
   END get_revenueJOP_BEGIN;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_revenueOdometer
          ( i_GUID_CI      TCUSTOMER_INVOICE.GUID_CI@SIMEX_DB_LINK%type
          ) RETURN         XMLTYPE
   IS
      l_revenueOdometer  XMLTYPE;

   BEGIN
     --  FraBe       2014-04-30 MKS-131277:2 add L_odometerMileageState
     -- TK           2014-11-27 MKS-135781:1 Sourcesystem ist hier FIX migration
     select XMLAGG (XMLELEMENT ( "odometer"
                    , xmlattributes
                      ( km.fzgkm_km                                      AS "mileage"
                      , 'true'                                           AS "calculationRelevant"
                      , L_odometerMileageState                           AS "mileageState"
                      , to_char(km.fzgkm_datum, 'YYYYMMDD')              AS "readingDate"
                      , 'customerInvoice'                                AS "sourceDefinition"
                      , 'migration'                                      AS "sourceSystem"
                      , 'true'                                           AS "valid" )))
       into l_revenueOdometer
       from TCUSTOMER_INVOICE@SIMEX_DB_LINK cinv
          , TFZGKMSTAND@SIMEX_DB_LINK       km
      where cinv.GUID_CI              = i_GUID_CI
        and cinv.CI_ID_SEQ_FZGKMSTAND = km.ID_SEQ_FZGKMSTAND;

     return l_revenueOdometer;

   END get_revenueOdometer;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function fix_adjmMileageDecimal
          ( i_CI_TYPE_IS_LL_COMPENSATION   TCUSTOMER_INVOICE_TYP.CUSTINVTYPE_IS_LL_COMPENSATION@SIMEX_DB_LINK%type
          , i_num_value                    varchar2
          ) return                         varchar2 is
   begin
       --  FraBe       2014-04-30 MKS-131277:2 creation
       if   i_CI_TYPE_IS_LL_COMPENSATION = 1
       then return trim ( replace ( i_num_value, ',', '.' ));
       else return null;
       end  if;

   end fix_adjmMileageDecimal;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function fix_adjmMileageGrouping
          ( i_CI_TYPE_IS_LL_COMPENSATION   TCUSTOMER_INVOICE_TYP.CUSTINVTYPE_IS_LL_COMPENSATION@SIMEX_DB_LINK%type
          , i_num_value                    varchar2
          ) return                         varchar2 is
   begin
       --  FraBe       2014-04-30 MKS-131277:2 creation
       if   i_CI_TYPE_IS_LL_COMPENSATION = 1
       then return trim ( replace ( i_num_value, '.', '' ));
       else return null;
       end  if;

   end fix_adjmMileageGrouping;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
   -- ZBerger     2014-10-24  MKS-134484:1 WavePreInt4 creation
   -- FraBe       2014-10-27  MKS-134489:1 komplett neue logik, nachdem wir da jetzt eine iCon - umschlüsselung haben
   --                                      ID_LLEINHEIT wird schon im main select umgeschlüsselt - hier erfolgt daher nur mehr die CI_TYPE_IS_LL_COMPENSATION abfrage 
   function get_adjmMileageIndicator
          ( i_CI_TYPE_IS_LL_COMPENSATION   TCUSTOMER_INVOICE_TYP.CUSTINVTYPE_IS_LL_COMPENSATION@SIMEX_DB_LINK%type
          , i_adjmMileageIndicator         varchar2
          ) return                         varchar2 is

   L_adjmMileageIndicator varchar2 ( 100 char );
   
   begin
       if   i_CI_TYPE_IS_LL_COMPENSATION = 1
       then return i_adjmMileageIndicator;
       else return null;
       end  if;

   end get_adjmMileageIndicator;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expRevenuePos
          ( i_GUID_CI                    TCUSTOMER_INVOICE.GUID_CI@SIMEX_DB_LINK%type
          , i_CI_TYPE_IS_LL_COMPENSATION TCUSTOMER_INVOICE_TYP.CUSTINVTYPE_IS_LL_COMPENSATION@SIMEX_DB_LINK%type
          , i_CI_CREATION_DATE           TCUSTOMER_INVOICE.CI_DATE@SIMEX_DB_LINK%type
          , i_BELART_SOLL_HABEN          TBELEGARTEN.BELART_SOLL_HABEN@SIMEX_DB_LINK%type
          , i_taxation                   varchar2
          , i_adjmMileageIndicator       varchar2
          ) RETURN                       XMLTYPE
   IS
     l_revenuePos  XMLTYPE;

   BEGIN
     -- FraBe       2014-04-30  MKS-131277:2 use fix_adjmMileageDecimal/Grouping
     -- FraBe       2014-05-23  MKS-132872:1 new PeriodFrom/To logic
     -- FraBe       2014-10-27  MKS-134489:1 add i_adjmMileageIndicator
     -- ZBerger     2015-01-23  MKS-136330:1 do not deliver positions with CIP_AMOUNT 0
     select XMLAGG ( XMLELEMENT ( "position"
                     , xmlattributes
                       ( CIP_POSITION                                             AS "positionNumber"
                       , to_char ( i_CI_CREATION_DATE, 'YYYYMMDD' )               AS "creationDate"
                       , nvl ( substr ( CIP_MEMO, 1, 240 ), ' ' )                 AS "invoicePositionText"
                       , nvl ( replace ( CIP_QUANTITY, 0, 1 ), 1 )                AS "quantity"
                       , round ( CIP_AMOUNT, 8 )                                  AS "invoicePositionNetAmount"
                       , round ( CIP_VAT_RATE * CIP_AMOUNT / 100, 8 )             AS "invoicePositionVATAmount"  -- MKS-134483:1
                       , i_taxation                                               AS "taxation"
                       , decode ( i_CI_TYPE_IS_LL_COMPENSATION
                                , 1, trim ( substr ( CIP_MEMO,  1,  8 ))
                                   , to_char ( CIP_DATE, 'YYYYMMDD' ))            AS "periodFrom"
                       , decode ( i_CI_TYPE_IS_LL_COMPENSATION
                                , 1, trim ( substr ( CIP_MEMO,  9,  8 )))         AS "periodUntil"
                       , decode ( i_CI_TYPE_IS_LL_COMPENSATION, 1,        trim ( substr ( CIP_MEMO,  1,  8 ))) AS "adjmFromDate"
                       , decode ( i_CI_TYPE_IS_LL_COMPENSATION, 1,        trim ( substr ( CIP_MEMO,  9,  8 ))) AS "adjmUntilDate"
                       , fix_adjmMileageGrouping ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 17,  8 ))  AS "adjmMileageStart"
                       , fix_adjmMileageGrouping ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 25,  8 ))  AS "adjmMileageActual"
                       , fix_adjmMileageGrouping ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 41,  8 ))  AS "adjmMileageDifference"
                       , fix_adjmMileageGrouping ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 33,  8 ))  AS "adjmMileageExpected"
                       , fix_adjmMileageDecimal  ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 64, 12 ))  AS "adjmMileageIncomeNeeded"
                       , fix_adjmMileageDecimal  ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 57,  7 ))  AS "adjmMileagePricePerMile"
                       , fix_adjmMileageDecimal  ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 76, 12 ))  AS "adjmMileageIncomePaid"
                       , get_adjmMileageIndicator( i_CI_TYPE_IS_LL_COMPENSATION, i_adjmMileageIndicator  )     AS "adjmMileageIndicator"  -- MKS-134483:1
                       , fix_adjmMileageDecimal  ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO, 95,  7 ))  AS "adjmMileagePriceLessMiles"
                       , fix_adjmMileageDecimal  ( i_CI_TYPE_IS_LL_COMPENSATION, substr ( CIP_MEMO,102,  7 ))  AS "adjmMileagePriceAdditionalMiles" ))
            order by CIP_POSITION )
       into l_revenuePos
       from TCUSTOMER_INVOICE_POS@SIMEX_DB_LINK
      where GUID_CI              = i_GUID_CI
        and CIP_AMOUNT          <> 0;

     return l_revenuePos;

   END expRevenuePos;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expRevenue
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      --    jeweils durchgeführten Plausibilitäprüfungen
      --    Auswirkungen auf den Bildschirm
      --    durchgeführten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      --  ZBerger     2013-11-12 MKS-123543:1 creation
      --  FraBe       2013-11-18 MKS-123544:1 add expRevenuePos aufruf plus ein paar kleinere korrekturen im code
      --  ZBerger     2013-11-18 MKS-123544:1 Completion
      --  FraBe       2013-11-18 MKS-123544:1 Completion II
      --  FraBe       2013-11-18 MKS-123544:1 Completion III
      --  FraBe       2013-11-18 MKS-123544:2 Completion IV
      --  FraBe       2013-11-18 MKS-123544:2 Completion V
      --  FraBe       2013-11-23 MKS-123548:1 neue taxation - logik
      --  FraBe       2014-05-23 MKS-132872:1 new financialDocumentReceiver - xsi_type
      --  ZBerger     2014-10-24 MKS-134483:1 some WavePreInt4 changes
      --  FraBe       2014-10-28 MKS-134489:1 add xmlattribute 'xsd:string' as "xsi:type" within the 3 parameter - subnodes
      --  ZBerger     2015-01-23 MKS-136330:1 do not deliver invoices with netAmount 0
      -------------------------------------------------------------------------------
      l_ret                      INTEGER        DEFAULT 0;
      l_ret_main                 INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT    VARCHAR2 (100) DEFAULT 'expRevenue';
      l_xml                      XMLTYPE;
      l_xml_out                  XMLTYPE;
      L_STAT                     VARCHAR2  (1) := NULL;
      L_ROWCOUNT                 INTEGER;
      L_filename                 varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK       varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'COUNTRY_CODE',  'COUNTRY_CODE' );
      L_tenant_Id                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                   TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_correlationID            TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
      L_masterDataReleaseVersion TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' );
      L_masterDataVersion        TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATA_VERSION',   null );

      FUNCTION cre_Revenue_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         AS "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              AS "xmlns:mdsd_sl"
                                           , 'http://revenue.icon.daimler.com/pl'         AS "xmlns:revenue_pl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_Revenue_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || L_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                    , g_expdatetime                   AS "dateTime"
                                    , L_userID                        AS "userId"
                                    , L_tenant_Id                     AS "tenantId"
                                    , L_causation                     AS "causation"
                                    , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                    , L_correlationID                 AS "correlationId"
                                    , L_issueThreshold                AS "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createCustomerFinancialDocument' AS "operation"  )
                                                  , XMLELEMENT ( "parameter"
                                                         , xmlattributes
                                                                ( 'revenue_pl:RevenueType'                           AS "xsi:type"
                                                                --TK; 2014-05-05  MKS-32604:1 change of external ID to GUID
                                                                , cinv.GUID_CI                                       AS "externalId"
                                                                , L_SourceSystem                                     AS "sourceSystem"
                                                                , '9'                                                AS "masterDataReleaseVersion"
                                                                , L_migrationDate                                    AS "migrationDate"
                                                                , to_char ( nvl ( cinv.CI_FI_DATE, cinv.CI_DATE ), 'YYYYMMDD' )
                                                                                                                     AS "invoiceDate"
                                                                , cinv.CI_DOCUMENT_NUMBER2                           AS "invoiceNumberFinance"
                                                                , to_char ( cinv.CI_DATE, 'YYYYMMDD' )               AS "calculationReferenceDate"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'CUR_CODE'
                                                                                             , cur.CUR_CODE )        AS "currency"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'CUSTINVTYPE_SHORT_CAPTION'
                                                                                             , cit.CUSTINVTYPE_SHORT_CAPTION )
                                                                                                                     AS "customerInvoiceDefinition"
                                                                , to_char ( nvl ( cinv.CI_FI_DATE, cinv.CI_DATE ), 'YYYYMMDD' )
                                                                                                                     AS "documentDate"
                                                                , CASE fzgvc.FZGVC_FACTORING
                                                                    WHEN 0 THEN 'false'
                                                                    WHEN 1 THEN 'true'
                                                                  END                                                AS "factoringIndicator"
                                                                , pck_revenue.get_revenueJOP_BEGIN 
                                                                                 ( I_JOP_FOREIGN      => cinv.GUID_CI
                                                                                 , I_CI_CREATION_DATE => cinv.CI_CREATED )  AS "financeSystemTransferDate"
                                                                , pck_calculation.substitute ( I_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'BELART_INVOICE_OR_CNOTE'
                                                                                             , belart.BELART_INVOICE_OR_CNOTE )
                                                                                                                     AS "financialDocumentDefinition"
                                                                , 'imported'                                         AS "financialDocumentSource"
                                                                , round (pck_calculation.get_REVENUE_AMOUNT
                                                                                       ( I_GUID_CI => cinv.GUID_CI
                                                                                       , I_VAT     => 2 ), 8)        AS "grossAmount"  -- MKS-134483:1
                                                                , substr(cinv.CI_MEMO, 1, 1000)                      AS "internalMemo" -- MKS-134483:1
                                                                , substr(cinv.CI_INVOICE_TEXT,1,240)                 AS "invoiceText"
                                                                , round (pck_calculation.get_REVENUE_AMOUNT
                                                                                       ( I_GUID_CI => cinv.GUID_CI
                                                                                       , I_VAT     => 1 ), 8)        AS "netAmount"    -- MKS-134483:1
                                                                , pck_calculation.get_setting ( 'SETTING', 
                                                                                                'CUSTOMERINVOICESTATUS',  
                                                                                                'exported' )         AS "status"       -- MKS-134483:1
                                                                , round (pck_calculation.get_REVENUE_AMOUNT
                                                                                       ( I_GUID_CI => cinv.GUID_CI
                                                                                       , I_VAT     => 0 ), 8)        AS "vatAmount" )  -- MKS-134483:1
                                                         , XMLELEMENT ( "financialDocumentReceiver"
                                                            , xmlattributes
                                                                -- TK 2014-11-27; MKS-135781:1 xsi:type for DealerasCustomer added
                                                               ( case when PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID  -- MKS-134483:1
                                                                                                       , G_TIMESTAMP
                                                                                                       , 'WorkshopAsCustomer'
                                                                                                       , part.ID_CUSTOMER ) is null
                                                                  then pck_partner.GET_CUST_xsi_PARTNER_TYPE ( part.ID_CUSTOMER )
                                                                  else 'partner_pl:OrganisationalPersonType'
                                                                  end                                               AS "xsi:type"
                                                                , case when PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID  -- MKS-134483:1
                                                                                                       , G_TIMESTAMP
                                                                                                       , 'WorkshopAsCustomer'
                                                                                                       , part.ID_CUSTOMER ) is null
                                                                  then part.ID_CUSTOMER
                                                                  -- TK 2014-11-27; MKS-135781:1 Prefix "D" added
                                                                  else 'D'||PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                  , G_TIMESTAMP
                                                                                                  , 'WorkshopAsCustomer'
                                                                                                  , part.ID_CUSTOMER )
                                                                   end                                               AS "externalId"
                                                                , L_SourceSystem                                     AS "sourceSystem" ))
                                                         , pck_revenue.get_revenueOdometer
                                                                      ( I_GUID_CI => cinv.GUID_CI )                  AS "odometer"
                                                         , pck_revenue.expRevenuePos
                                                               ( I_GUID_CI                    => cinv.GUID_CI
                                                               , i_CI_TYPE_IS_LL_COMPENSATION => cit.CUSTINVTYPE_IS_LL_COMPENSATION
                                                               , i_CI_CREATION_DATE           => nvl ( cinv.CI_FI_DATE, cinv.CI_DATE )
                                                               , i_BELART_SOLL_HABEN          => belart.BELART_SOLL_HABEN
                                                               , i_taxation                   => pck_calculation.substitute        -- nur CUSTYP, da bei MBBEL revenues nur an kunden geschickt werden, und nicht auch an werkstätten
                                                                                                            ( I_TAS_GUID
                                                                                                            , G_TIMESTAMP
                                                                                                            , 'TAXATION_REVENUE'
                                                                                                            , case
                                                                                                              when                 CUST_REDVAT_FROM is null  then cust.ID_CUSTYP
                                                                                                              when sysdate between CUST_REDVAT_FROM
                                                                                                                               and CUST_REDVAT_UNTIL         then cust.ID_CUSTYP_REDVAT
                                                                                                                                                             else cust.ID_CUSTYP
                                                                                                              end || decode ( belart.BELART_INVOICE_or_CNOTE, 0, '#I', '#C' ))
                                                               , i_adjmMileageIndicator       => PCK_CALCULATION.SUBSTITUTE 
                                                                                                            ( i_TAS_GUID
                                                                                                            , G_TIMESTAMP
                                                                                                            , 'ID_LLEINHEIT'
                                                                                                            , ll.ID_LLEINHEIT )
                                                               ) AS "position" )
                                                      -- MKS-133672:1
                                                    , XMLELEMENT ( "parameter"
                                                       , xmlattributes ( 'xsd:string'                    as "xsi:type" )
                                                       , fzgvc.ID_VERTRAG || '/' || fzgvc.ID_FZGVERTRAG )
                                                    , XMLELEMENT ( "parameter"
                                                       , xmlattributes ( 'xsd:string'                    as "xsi:type" )
                                                       , L_SourceSystem)
                                                    , XMLELEMENT ( "parameter"
                                                       , xmlattributes ( 'xsd:string'                    as "xsi:type" )
                                                       , lpad ( fzgvc.ID_VERTRAG,    8, '0' ) || '/' || lpad ( fzgvc.ID_FZGVERTRAG, 6, '0' ))
                                                              )
                                order by rownum )
                                   from TGARAGE@SIMEX_DB_LINK               gar
                                      , TCUSTOMER@SIMEX_DB_LINK             cust
                                      , TPARTNER@SIMEX_DB_LINK              part
                                      , TFZGV_CONTRACTS@SIMEX_DB_LINK       fzgvc
                                      , TBELEGARTEN@SIMEX_DB_LINK           belart
                                      , TCURRENCY@SIMEX_DB_LINK             cur
                                      , TFZGLAUFLEISTUNG@SIMEX_DB_LINK      ll
                                      , TCUSTOMER_INVOICE_TYP@SIMEX_DB_LINK cit
                                      , TCUSTOMER_INVOICE@SIMEX_DB_LINK     cinv
                                      , TXML_SPLIT                          x
                                  where cinv.GUID_CI                      = x.PK_VALUE_CHAR
                                    and cinv.ID_SEQ_FZGVC                 = ll.ID_SEQ_FZGVC (+)
                                    and cinv.ID_CURRENCY                  = cur.ID_CURRENCY
                                    and cinv.GUID_CUSTINVTYPE             = cit.GUID_CUSTINVTYPE
                                    and cinv.ID_BELEGART                  = belart.ID_BELEGART
                                    and cinv.ID_SEQ_FZGVC                 = fzgvc.ID_SEQ_FZGVC
                                    and cinv.GUID_PARTNER                 = part.GUID_PARTNER
                                    and cust.ID_CUSTOMER   (+)            = part.ID_CUSTOMER
                                    and gar.ID_GARAGE      (+)            = part.ID_GARAGE
                                    and pck_calculation.get_REVENUE_AMOUNT( I_GUID_CI => cinv.GUID_CI
                                                                          , I_VAT     => 1 ) <> 0
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' revenues' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' revenue nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_Revenue_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN (   select GUID_CI
                        from TCUSTOMER_INVOICE@SIMEX_DB_LINK cinv
                           , TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                           , TDFCONTR_VARIANT@SIMEX_DB_LINK  cv
                       where cv.COV_CAPTION    not like 'MIG_OOS%'
                         and cv.ID_COV                = fzgvc.ID_COV
                         and cinv.ID_SEQ_FZGVC        = fzgvc.ID_SEQ_FZGVC
                     order by 1 )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.GUID_CI );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_Revenue_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Revenue_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

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

   END expRevenue;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

END;
/
