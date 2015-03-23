CREATE OR REPLACE PACKAGE BODY PCK_CONTRACT
IS
-- MKSSTART
-- $CompanyInfo $
--
-- $Date: 2015/03/23 10:14:49MEZ $
--
-- $Name:  $
--
-- $Revision: 1.70 $
--
-- $Header: 5100_Code_Base/Database/Source/PCK_CONTRACT.plb 1.70 2015/03/23 10:14:49MEZ Frank, Marina (marinf) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/PCK_CONTRACT.plb $
--
-- $Log: 5100_Code_Base/Database/Source/PCK_CONTRACT.plb  $
-- Revision 1.70 2015/03/23 10:14:49MEZ Frank, Marina (marinf) 
-- MKS-152067:1 DEF8450 MBBEL: do not deliver the whole element fixedLabour.
-- Revision 1.69 2015/03/20 16:09:16MEZ Frank, Marina (marinf) 
-- MKS-151824:1 DEF8653 derive "dateTime" from global settings.
-- Revision 1.68 2015/03/13 16:41:36MEZ Frank, Marina (marinf) 
-- MKS-151961 Temporary solution to avoid -1 when Erst_zulassung = plan_start_date = 31 day of month. the Function "PCK_CONTRACT.days_between" must be rebuilt.
-- Revision 1.67 2015/03/13 09:54:25MEZ Frank, Marina (marinf) 
-- 152061:2 Eliminate duplicates resulting from different customers having the same Domiciliation Number. Duplicates resulting from the same customer having multiple bank accounts are still existing.
-- Revision 1.66 2015/03/10 16:15:06MEZ Frank, Marina (marinf) 
-- MKS-136520 BankAccount should be delivered only if paymm_caption_short = 'D' and contract has a Domiciliation Number
-- Revision 1.65 2015/03/06 16:03:00MEZ Frank, Marina (marinf) 
-- MKS-151798:2 Fixed lost sort order for Service Contract Full
-- Revision 1.64 2015/02/18 20:49:48MEZ Frank, Marina (marinf) 
-- MKS-151797 contractInformationInternal: Added Concatenation with tfzgvertrag.FZGV_MEMO
-- Revision 1.63 2015/02/18 20:26:32MEZ Frank, Marina (marinf) 
-- MKS-136487 Moved Vega Product Calculation to cursor, to fill Vega Migration Mapping table. Added call to pck_calculation.contract_number_icon.
-- The functions though should be used in distributed queries with caution.
-- Revision 1.62 2015/02/12 15:01:12MEZ Frank, Marina (marinf) 
-- Fixed bug for with hierarchical query (too early filtering), bug for contractingCustomer node.
-- Revision 1.61 2015/02/10 14:41:35MEZ Frank, Marina (marinf) 
-- MKS-138692:1 Added XSL Transformation, optimized Vehicle Contracts Cursor for "Full mode" extraction.
-- Revision 1.60 2015/02/09 13:37:18MEZ Frank, Marina (marinf) 
-- Reimplemented expServiceContract,expCustomerContract,expVehicleContract to become wrappers to one common function prv_exp_contract.
-- Moved to global section: Exception declaration. Created writelog private function. ins_TFZGPREIS_SIMEX: deleted optimizer hints as they lead to sub-optimal execution plan.
-- Todo: aviod redundant xmlns:xsi declaration.
-- Revision 1.59 2015/01/27 12:14:14MEZ Zuhl, Marco (marzuhl) 
-- Merge Teil 2
-- Revision 1.57.1.4 2015/01/27 11:03:57MEZ Frank, Marina (marinf) 
-- Reimplemented expVehicleContract function, optimized get_ProductOPTION function, merged changes from Revision 1.58 regarding TVEGA_MAPPINGLIST..
-- Revision 1.58 2015/01/14 14:10:14MEZ Zimmerberger, Markus (zimmerb) 
-- expServiceContract/expVehicleContract: Add insert into snt.tvega_mappinglist
-- Revision 1.57.1.3 2015/01/26 15:54:01MEZ Frank, Marina (marinf) 
-- Implemented changes from Revision 1.58 regarding TVEGA_MAPPINGLIST, added cursor closing statement, added comments
-- Revision 1.57.1.2 2015/01/15 13:34:47MEZ Frank, Marina (marinf) 
-- Added ActiveConditionState section for expVehicleContract, extended temporary table definition, fixed sorting (parent sorting is a ToDo), Added COMMIT before exiting procedure block.
-- Revision 1.57.1.1 2015/01/14 13:13:17MEZ Frank, Marina (marinf) 
-- dev
-- Revision 1.57 2014/12/19 16:22:49MEZ Berger, Franz (fraberg) 
-- get_VehicleContract / expVehicleContract / expServiceContract: add level sort / start with / connent by prior damit die CO in der richtigen reihenfolge exportiert werden
-- Revision 1.56 2014/12/05 14:15:04MEZ Berger, Franz (fraberg) 
-- - get_VehicleContract / expServiceContract: table TFZGLAUFLEISTUNG kann bei vehicleContract weggelassen werden, da keine daten von ihr gelesen werden
-- - plus reaktivieren von expServiceContractOLD für die Full-ServiceContract extraktion, da die am 22.11 erstellte neue version sehr langsam ist (-> get_vehicleContract aufruf )
-- - plus: das am 22.11 erstellte neue version expServiceContract ist dadurch obsolete, und wird daher umbenannt auf expServiceContractNEWobsolete
-- Revision 1.55 2014/11/26 10:28:16MEZ Berger, Franz (fraberg) 
-- ne menge neuer functions - und änderungen in bestehendem code aufgrund von den 2 neuen extraktionen expCustomerContract und expVehicleContract aus code vom bestehenden expServiceContract
-- Revision 1.54 2014/11/20 12:13:17MEZ Berger, Franz (fraberg) 
-- expServiceContract: merge code von MKS version 1.44 und 1.45 bei "contractingCustomer" - "xsi:type" und "externalId"
-- Revision 1.53 2014/11/18 08:19:42MEZ Berger, Franz (fraberg) 
-- get_SPP_product_COVERAGE ersetzen decode ( nvl ( main_sel.SPCP_VALUE, 0 ) mit case
-- Revision 1.52 2014/11/07 11:27:21MEZ Kieninger, Tobias (tkienin) 
-- get_defaultCoverage kuckt jetzt nach, ob es tatsächlich eine defaultCoverage gibt.
-- Revision 1.51 2014/11/03 17:25:53MEZ Kieninger, Tobias (tkienin) 
-- Balancing Invoice Receiver and alternative invoice receiver zogen ihren xsi_typ vom Vertragskundentyp, und nicht ihren eigenen --> umbau auf Funktionsaufruf
-- Revision 1.50 2014/11/03 13:37:44MEZ Kieninger, Tobias (tkienin) 
-- extend prices for ALL indexed contracts, not only for active ones
-- Revision 1.48 2014/11/03 11:24:44MEZ Kieninger, Tobias (tkienin) 
-- .
-- Revision 1.47 2014/10/30 14:45:16MEZ Berger, Franz (fraberg) 
-- expALL_ODOMETER: add WavePreInt4 changes
-- Revision 1.46 2014/10/22 10:52:19MESZ Berger, Franz (fraberg) 
-- ins_TFZGPREIS_SIMEX: select distinct within 1st step inserting
-- Revision 1.45 2014/10/14 18:01:29MESZ Kieninger, Tobias (tkienin) 
-- DEF4463 wurde nciht gemerged...
-- Revision 1.44 2014/10/13 15:28:37MESZ Zimmerberger, Markus (zimmerb) 
-- cre_ServiceContract_xml: ownedByOrganisation change (remove SUBSTR)
-- Revision 1.43 2014/10/13 14:23:32MESZ Kieninger, Tobias (tkienin) 
-- FIX or FRealEndMileage for active contracts
-- Revision 1.42 2014/10/10 13:20:21MESZ Zimmerberger, Markus (zimmerb) 
-- cre_ServiceContract_xml: bankAccount fixing
-- Revision 1.41 2014/10/09 17:38:06MESZ Zimmerberger, Markus (zimmerb) 
-- cre_ServiceContract_xml: bankAccount changes
-- Revision 1.40 2014/10/07 18:51:42MESZ Zimmerberger, Markus (zimmerb) 
-- expServiceContract: WavePreInt4
-- Revision 1.39 2014/10/06 11:19:32MESZ Kieninger, Tobias (tkienin) 
-- Hotfix Iter10
-- Revision 1.38 2014/09/16 12:34:14MESZ Kieninger, Tobias (tkienin) 
-- merging Branch
-- Revision 1.37 2014/09/15 07:09:40MESZ Berger, Franz (fraberg) 
-- some small FX
-- Revision 1.36 2014/09/04 15:08:42MESZ Berger, Franz (fraberg) 
-- get_SPP_product_COVERAGE: extract PH_PARAM_OUT1 and not PH_PARAM_OUT2 within xmlAttribute "code"
-- Revision 1.35 2014/09/04 09:58:24MESZ Berger, Franz (fraberg) 
-- korrektur zu vorhin: chk_FinEndCOstate / get_lastCO_statChgDat / get_odometerAtRealEnd: creation / and expServiceContract: some changes 
-- due to CO might be terminated, but without real end date and mileage
-- Revision 1.34 2014/09/04 09:53:43MESZ Berger, Franz (fraberg) 
-- chk_FinEndCOstate / get_lastCO_statChgDat: creation / and expServiceContract: some changes 
-- due to CO might be terminated, but without real end date and mileage
-- Revision 1.33 2014/09/02 11:43:34MESZ Berger, Franz (fraberg) 
-- get_SPP_product_COVERAGE: check auf upper ( ph.PH_PARAM_OUT7 ) in ( 'YES', 'TRUE' )
-- Revision 1.32 2014/09/01 17:16:47MESZ Berger, Franz (fraberg) 
-- - expServiceContract: auch ID_FZGVERTRAG_PARENT muß bei derivedFromVehicleContract geckeckt werden!
-- - chk_SCOPE: beheben bug: die returnwerte sind genau umgekehrt!
-- Revision 1.31 2014/09/01 15:19:54MESZ Berger, Franz (fraberg) 
-- get_SPP_product_COVERAGE: code umschreiben, daß bei TPRODUCT_HOUSE ein (+) möglich ist
-- Revision 1.30 2014/09/01 14:12:35MESZ Berger, Franz (fraberg) 
-- add waveFinal
-- Revision 1.29 2014/08/18 15:32:10MESZ Berger, Franz (fraberg) 
-- function get_Product_House: add I_PH_PARAM_IN4
-- Revision 1.28 2014/06/10 17:31:33MESZ Kieninger, Tobias (tkienin) 
-- minor fixes
-- Revision 1.27 2014/06/02 18:21:07MESZ Kieninger, Tobias (tkienin) 
-- getproduct_option corrected
-- Revision 1.26 2014/05/14 15:47:39MESZ Zimmerberger, Markus (zimmerb) 
-- expALL_ODOMETER: Wave 3.2 iter 1
-- Revision 1.25 2014/05/05 17:49:31MESZ Kieninger, Tobias (tkienin) 
-- DEF4436
-- Revision 1.24 2014/04/28 15:26:30MESZ Kieninger, Tobias (tkienin) 
-- .
-- Revision 1.22 2014/04/16 14:01:31MESZ Kieninger, Tobias (tkienin)
-- Revert von 1.18
-- Revision 1.18 2014/04/09 11:07:24MESZ Kieninger, Tobias (tkienin)
-- Loggin Vertrag
-- Revision 1.17 2014/04/07 06:58:22MESZ Berger, Franz (fraberg)
-- get_PriceCalcPart_Campaign / expServiceContract: some FX
-- Revision 1.16 2014/04/04 09:24:45MESZ Berger, Franz (fraberg)
-- get_PriceCalcPart / get_PriceCalcPart_Campaign: substr ( 1, 10 ) within xmlattribute costCenterReference and costCenter
-- Revision 1.15 2014/04/04 09:08:25MESZ Berger, Franz (fraberg)
-- expServiceContract / get_PriceCalcPart_Campaign.some small wave 3.2 FX
-- Revision 1.14 2014/04/01 17:07:17MESZ Berger, Franz (fraberg)
-- a lot of changes / new functions due to wave 3.2 CO
-- Revision 1.13 2014/02/26 11:24:27MEZ Berger, Franz (fraberg)
-- expServiceContract: SPP coverage: change ActiveCoverageRealCost to coverageRealCost plus make it ant its xml attribute period optional
-- Revision 1.12 2014/02/24 08:55:47MEZ Berger, Franz (fraberg)
-- expServiceContract: default - coverage nur, wenn CO beginn date kleiner oder gleich dem Setting-MigrationDate
-- Revision 1.11 2014/02/20 18:51:11MEZ Berger, Franz (fraberg)
-- expServiceContract: fix some bugs in get_product_house - aufrufen
-- Revision 1.10 2014/02/18 22:16:28MEZ Berger, Franz (fraberg)
-- letzte wave1 CO änderungen
-- Revision 1.9 2014/02/18 09:58:28MEZ Berger, Franz (fraberg)
-- wave1 zwischenstand
-- Revision 1.8 2014/02/11 11:36:18MEZ Zimmerberger, Markus (zimmerb)
-- [DRAFT]: get_Used, get_Product_House, get_Product_House_Default
-- Revision 1.7 2014/02/11 10:54:49MEZ Berger, Franz (fraberg)
-- expServiceContract: wave1 änderungen einarbeiten - teil I
-- plus new function chk_SCOPE / delete obsolete function CO_GET_PRODUCT
-- Revision 1.6 2013/11/18 10:30:53MEZ Berger, Franz (fraberg)
-- move von PCK_EXPORTS:
-- - expALL_ODOMETER
-- Revision 1.5 2013/11/16 07:40:44MEZ Berger, Franz (fraberg)
-- move von PCK_EXPORTS:
-- - expServiceContract
-- - expALL_CONTRACTS
-- Revision 1.4 2013/10/22 15:29:48MESZ Berger, Franz (fraberg)
-- - CO_REVENUE_AMOUNT:
--   - new IN parameter i_PAYM_TARGETDATE_CI within
--   - neuerliche komplette logikänderung in berechnung value
-- - new function chk_overlapping_prices
-- Revision 1.3 2013/06/25 14:04:20MESZ Berger, Franz (fraberg)
-- add  procedure ins_TFZGPREIS_SIMEX
-- Revision 1.2 2013/06/24 17:48:53MESZ Berger, Franz (fraberg)
-- add some new Contract functions
-- Revision 1.1 2013/06/11 14:46:00MESZ Zimmerberger, Markus (zimmerb)
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- MKSEND

-- Purpose: package for all SiMEx - contract procedures / functions

-- ChangeHistory (- since 11.02.2014 -):
-- FraBe 11.02.2014 MKS-129519:1 / expServiceContract: wave1 änderungen einarbeiten - teil I
--                                 plus new function chk_SCOPE / delete obsolete function CO_GET_PRODUCT
-- FraBe 20.02.2014 MKS-129519:1 / expServiceContract: fix bugs in get_product_house - aufrufen
-- FraBe 24.02.2014 MKS-129519:2 / expServiceContract: default - coverage nur, wenn CO beginn date kleiner oder gleich dem Setting-MigrationDate
-- FraBe 26.02.2014 MKS-131497:1 / expServiceContract: SPP coverage: change ActiveCoverageRealCost to coverageRealCost plus make it and its xml attribute period optional
-- FraBe 20.03.2014 MKS-131260:1 / 131261:1 a lot of changes / new functions due to wave 3.2
-- FraBe 03.04.2014 MKS-131265:1 / expServiceContract / get_PriceCalcPart_Campaign: some small wave 3.2 FX
-- FraBe 04.04.2014 MKS-132055:1 / get_PriceCalcPart / get_PriceCalcPart_Campaign: substr ( 1, 10 ) within xmlattribute costCenterReference and costCenter
-- FraBe 04.04.2014 MKS-131265:1 / get_PriceCalcPart_Campaign / expServiceContract: some FX
-- TK    09.04.2014                Add logging for each contract
-- FraBe 14.08.2014 MKS-133123:1 / get_Product_House: add I_PH_PARAM_IN4
-- FraBe 18.08.2014 MKS-132150:1/132151/1 expServiceContract: implement waveFinal / replace L_TIMESTAMP by G_TIMESTAMP
-- FraBe 18.08.2014 MKS-130002:1 / ins_TFZGPREIS_SIMEX: add crec  - hint index / ordered (-> damit sich dieses statement nicht mehr aufhängt )
-- FraBe 19.08.2014 MKS-132150:1/132151/1 ins_TFZGPREIS_SIMEX: add EXT_CREATION_DATE / waveFinal änderungen
-- FraBe 01.09.2014 MKS-132387:1 / get_SPP_product_COVERAGE: code umschreiben, daß bei TPRODUCT_HOUSE ein (+) möglich ist
-- FraBe 01.09.2014 MKS-132385:1 / expServiceContract: auch ID_FZGVERTRAG_PARENT muß bei derivedFromVehicleContract geckeckt werden!
--                                 chk_SCOPE: beheben bug: die returnwerte sind genau umgekehrt!
-- FraBe 02.09.2014 MKS-132387:2 / get_SPP_product_COVERAGE: check auf upper ( ph.PH_PARAM_OUT7 ) in ( 'YES', 'TRUE' )
-- FraBe 03.09.2014 MKS-132150:2 / 132151:2 chk_FinEndCOstate / get_lastCO_statChgDat / get_odometerAtRealEnd: creation / and expServiceContract: some changes 
--                                 due to CO might be terminated, but without real end date and mileage
-- FraBe 04.09.2014 MKS-134257:1 / get_SPP_product_COVERAGE: extract PH_PARAM_OUT1 and not PH_PARAM_OUT2 within xmlAttribute "code"
-- FraBe 13.09.2014 MKS-132155:1 some small FX
-- MaZi  07.10.2014 MKS-134444:1 / 134445:1 expServiceContract: WavePreInt4
-- MaZi  09.10.2014 MKS-134450:1 cre_ServiceContract_xml: bankAccount changes
-- MaZi  10.10.2014 MKS-134450:2 cre_ServiceContract_xml: bankAccount fixing
-- MaZi  13.10.2014 MKS-135200:1 cre_ServiceContract_xml: ownedByOrganisation change (remove SUBSTR)
-- FraBe 21.10.2014 MKS-134450:3 ins_TFZGPREIS_SIMEX: select distinct within 1st step inserting
-- FraBe 29.10.2014 MKS-134496:1 expALL_ODOMETER: WavePreInt4
-- FraBe 17.11.2014 MKS-135673:1 get_SPP_product_COVERAGE ersetzen decode ( nvl ( main_sel.SPCP_VALUE, 0 ) mit case
-- FraBe 20.11.2014 MKS-135656:1 / expServiceContract: merge code von MKS version 1.44 und 1.45 bei "contractingCustomer" - "xsi:type" und "externalId"
-- FraBe 22.11.2014 MKS-135622/135623/135636/135637: ne menge neuer functions - und änderungen in bestehendem code aufgrund von den 2 neuen extraktionen expCustomerContract 
--                               und expVehicleContract aus code vom bestehenden expServiceContract
--                               bzw. alten expServiceContract code auf expServiceContractOLD renamen (-> es kann ja sein, daß er später noch einmal gebraucht wird )
-- FraBe 05.12.2014 MKS-135643:  get_VehicleContract / expServiceContract: table TFZGLAUFLEISTUNG kann bei vehicleContract weggelassen werden, da keine daten von ihr gelesen werden
--                               plus reaktivieren von expServiceContractOLD für die Full-ServiceContract extraktion, da die am 22.11 erstellte neue version sehr langsam ist (-> get_vehicleContract aufruf )
--                               plus: das am 22.11 erstellte neue version expServiceContract ist dadurch obsolete, und wird daher umbenannt auf expServiceContractNEWobsolete
--                               rest siehe direkt bei den einzelnen functions (-> suche nach MKS-135643 )
-- FraBe 19.12.2014 MKS-135849:1 get_VehicleContract / expVehicleContract / expServiceContract: add level sort / start with / connent by prior damit die CO in der richtigen reihenfolge exportiert werden
-- MaZi  13.01.2015 MKS-135609:1 expServiceContract/expVehicleContract: Add insert into snt.tvega_mappinglist
-- MaFr  26.01.2015 MKS-136294:1 expVehicleContract: Reimplemented Vehicle Contract extraction logic
-- MaFr  09.02.2015 MKS-138692:1 expCustomerContract / expVehicleContract / expServiceContract are now wrappers to a common prv_exp_contract function.
--                               Old implementations are deleted.
-- MaFr  10.02.2015 MKS-138692:1 xmlel_VehiContract: moved <invocation> node to XSL Transformation step to avoid redundant namespace declaration.
--                               prv_exp_contract: added UNION ALL switcher to optimize ServiceContractFull extraction
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
   c_exptype_CustContract     CONSTANT SMALLINT := 1;
   c_exptype_VehiContract     CONSTANT SMALLINT := 2;
   c_exptype_ServContract     CONSTANT SMALLINT := 3;
   g_xmlobj_dict              dbms_sql.varchar2_table;
   G_DB_NAME_of_DB_LINK       varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
   G_COUNTRY_CODE             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'COUNTRY_CODE',             null );
   G_userID                   TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',                   'SIRIUS'    );
   G_SourceSystem             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',             'SIRIUS'    );
   G_correlationID            TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID',            'SIRIUS'    );
   G_causation                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',                'migration' );
   G_issueThreshold           TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'ISSUETHRESHOLD',           'SIRIUS'    );
   G_masterDataReleaseVersion TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9'  );
   G_masterDataVersion        TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATA_VERSION',       null );
   G_TermsAndConditionsCode   TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TERMSANDCONDITIONS',       null );
   G_FILECOUNT_FILLER         TSETTING.SET_VALUE%type := PCK_CALCULATION.get_setting ( 'SETTING', 'FILECOUNT_FILLER',          5   );
   G_migrationDate            TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));
   
   G_TargetDateCI             snt.TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%TYPE := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'Sirius', 'Setting', 'TargetDateCustomerInvoice' );
   
   G_TIMESTAMP                TIMESTAMP (6)           := SYSTIMESTAMP;
   G_TAS_GUID                 simex.TTASK.TAS_GUID%type;
   
   g_expdatetime              TSETTING.SET_VALUE%TYPE := 
    CASE
      WHEN pck_calculation.g_expdatetime = '0'
        THEN to_char ( G_TIMESTAMP, pck_calculation.c_xmlDTfmt )
      ELSE pck_calculation.g_expdatetime 
    END;
      
   PROCEDURE writelog(p_log_id VARCHAR2, p_log_text VARCHAR2, p_force BOOLEAN DEFAULT FALSE) IS
   BEGIN
      IF PCK_CALCULATION.GET_SETTING('SETTING', 'DEBUG', 'FALSE') = 'TRUE' OR p_force THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => G_TAS_GUID
                               , i_LOG_ID     => p_log_id
                               , i_LOG_TEXT   => substr(p_log_text,1,500) );
      END IF;
   END writelog;
      
   function CO_REVENUE_AMOUNT
          ( i_ID_VERTRAG                  varchar2
          , i_ID_FZGVERTRAG               varchar2
          , i_FZGVC_BEGINN                date
          , i_FZGVC_PREL_OR_FINAL_ENDE    date
          , i_PAYM_TARGETDATE_CI          number
          ) return                        number is

         -- purpose: calculates contract value
         --
         -- MODIFICATION HISTORY
         -- Person      Date       Comments
         -- ---------   ------     -------------------------------------------
         -- Pauzi                  Creation
         -- FraBe       13.06.2013 logikänderung
         -- FraBe       09.10.2013 MKS-126869: neuerliche komplette logikänderung in berechnung value

         L_dblMPSum                   NUMBER   := 0;
         L_dblSubventionSum           NUMBER   := 0;

         L_MONTH_BEGIN                varchar2 ( 6 char );
         L_MONTH_END                  varchar2 ( 6 char );
         L_MONTH_CURRENT              varchar2 ( 6 char );

         L_FZGPR_VON                  date;
         L_FZGPR_BIS                  date;

         L_DAYS_BEGIN_MONTH           integer;
         L_DAYS_END_MONTH             integer;
         L_MONTHS_BETWEEN             integer;

         L_GS_RoundingMileageAmount       TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%type := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'Setting',    'RoundingMileageAmount' );
         L_GS_TargetDateCustomerInvoice   TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%type := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'SETTING', 'TargetDateCustomerInvoice' );

         ----------------------------------------------------------------------------------------------------------------------------------------------------
         -- function zum berechnen der MP, die am 1. eines L_MONTH_CURRENT - vetragsmonats gültig ist
         ----------------------------------------------------------------------------------------------------------------------------------------------------
         function get_FZGPR_PREIS_MONATP
           return            number is

           L_RETURNVALUE     number  := 0;

         begin

              select FZGPR_PREIS_MONATP
                into L_RETURNVALUE
                from simex.TFZGPREIS_SIMEX
               where i_ID_VERTRAG          = ID_VERTRAG
                 and i_ID_FZGVERTRAG       = ID_FZGVERTRAG
                 and rownum                = 1
                 and to_date ( L_MONTH_CURRENT || '01', 'YYYYMMDD' ) between FZGPR_VON and FZGPR_BIS;

              return L_RETURNVALUE;

         exception when NO_DATA_FOUND
                   then return 0;
         end;

    begin

      ----------------------------------------------------------------------------------------------------------------------------------------------------
      -- i_PAYM_TARGETDATE_CI = 0: keine tagesgenaue abrechnung:
      ----------------------------------------------------------------------------------------------------------------------------------------------------
      --      MP vom ersten  vertragsmonat, falls der vertrag vor  dem GS TargetDateCustomerInvoice - tag liegt oder gleich ist
      -- plus MP vom letzten vertragsmonat, falls der vertrag nach dem GS TargetDateCustomerInvoice - tag liegt
      -- plus MP von allen   vertragsmonaten dazwischen
      -- (-> MP immer nur jene, die am 1. des entsprechenden vertragsmonats gültig ist )
      ----------------------------------------------------------------------------------------------------------------------------------------------------
      if   i_PAYM_TARGETDATE_CI = 0
      then L_MONTH_BEGIN   := to_char ( i_FZGVC_BEGINN,             'YYYYMM' );
           L_MONTH_END     := to_char ( i_FZGVC_PREL_OR_FINAL_ENDE, 'YYYYMM' );
           L_MONTH_CURRENT := L_MONTH_BEGIN;

           while to_number ( L_MONTH_CURRENT ) <= to_number ( L_MONTH_END )
           loop

                -- das erste monat wird nur dann verrechnet, wenn der tag, an dem der CO beginnt, vorm TargetDateCustomerInvoice - GS liegt oder gleich ist:
                if    L_MONTH_CURRENT = L_MONTH_BEGIN
                then  if    to_number ( to_char ( i_FZGVC_BEGINN, 'DD' )) <= L_GS_TargetDateCustomerInvoice
                      then  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
                      end   if;
                -- das letzte monat wird nur dann verrechnet, wenn der tag, an dem der CO endet, nach dem TargetDateCustomerInvoice - GS liegt:
                elsif L_MONTH_CURRENT = L_MONTH_END
                then  if    to_number ( to_char ( i_FZGVC_BEGINN, 'DD' )) >  L_GS_TargetDateCustomerInvoice
                      then  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
                      end   if;
                -- monate dazwischen einfach aufsummieren
                else  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
                end   if;

                -- erhöhen current month um 1 monat
                L_MONTH_CURRENT := to_char ( add_months ( to_date ( L_MONTH_CURRENT, 'YYYYMM' ), 1 ), 'YYYYMM' );

           end loop;

      ----------------------------------------------------------------------------------------------------------------------------------------------------
      -- wenn i_PAYM_TARGETDATE_CI = 1: tagesgenaue abrechnung:
      ----------------------------------------------------------------------------------------------------------------------------------------------------
      -- jedes monat wird mit 30 tagen gerechnet - egal ob FEB, MAR oder APR usw.
      -- beginnt zb. ein CO an einem 31. eines Monats wird KEINE MP verrechnet.
      -- beginnt er an einem 30. eines Monats -> 1 Tag / an einem 29. -> 2 Tage - auch beim FEB
      -- beginnt er an einem 28. -> 3 Tage - auch beim FEB

      -- beispiel:
      -- CO beginnt am 4.2. und endet am 3.3. wobei für FEB eine MP von 100 EUR gilt, für MAR: 150
      -- FEB:   100.00 EUR / 30 tage * 27 tage ( 4.2. - 30.2.) =  90.00 EUR
      -- MAR:   150.00 EUR / 30 tage *  3 tage ( 1.3. -  3.3.) =  15.00 EUR
      -- summe:                                                = 105.00 EUR
      ----------------------------------------------------------------------------------------------------------------------------------------------------
      elsif i_PAYM_TARGETDATE_CI = 1
      then for crec in ( select FZGPR_VON, FZGPR_BIS, FZGPR_PREIS_MONATP / 30 as FZGPR_PREIS_DAYP
                           from simex.TFZGPREIS_SIMEX
                          where i_ID_VERTRAG          = ID_VERTRAG
                            and i_ID_FZGVERTRAG       = ID_FZGVERTRAG
                       order by 1 )
           loop
               --- wenn preis VON vor CO BEGINN liegt: preis VON = CO BEGINN
               if   crec.FZGPR_VON < i_FZGVC_BEGINN
               then L_FZGPR_VON   := i_FZGVC_BEGINN;
               else L_FZGPR_VON   := crec.FZGPR_VON;
               end  if;

               --- wenn preis BIS nach CO ENDE liegt: preis BIS = CO ENDE
               if   crec.FZGPR_BIS > i_FZGVC_PREL_OR_FINAL_ENDE
               then L_FZGPR_BIS   := i_FZGVC_PREL_OR_FINAL_ENDE;
               else L_FZGPR_BIS   := crec.FZGPR_BIS;
               end  if;

               -- wenn preis VON der 31. eines monats ist, wird das ganze monat nicht verrechnet -> 1 tag vor
               if   to_char ( L_FZGPR_VON, 'DD' ) = '31'
               then L_FZGPR_VON := L_FZGPR_VON + 1;
               end  if;

               -- wenn preis BIS der 31. eines monats ist, wird nur bis zum 30. verrechnet -> 1 tag zurück
               if   to_char ( L_FZGPR_BIS, 'DD' ) = '31'
               then L_FZGPR_BIS := L_FZGPR_BIS - 1;
               end  if;

               --- feststellen wieviele vorschreibpflichtige tage im ersten und letzten preis - gültigkeitsmonat:
               L_DAYS_BEGIN_MONTH  := 30 - to_number ( to_char ( L_FZGPR_VON, 'DD' )) + 1;
               L_DAYS_END_MONTH    :=      to_number ( to_char ( L_FZGPR_BIS, 'DD' ));

               --- feststellen wieviele ganze monate dazwischen:
               L_MONTHS_BETWEEN := months_between ( last_day ( add_months ( L_FZGPR_BIS, -1 )) + 1
                                                  , last_day (              L_FZGPR_VON      ) + 1 );

               --- betrag =  vorheriger betrag plus ...
               L_dblMPSum := L_dblMPSum + ( crec.FZGPR_PREIS_DAYP * L_DAYS_BEGIN_MONTH )          --- ... plus tages - rate * vorschreibpflichtiger tage im beginnmonat
                                        + ( crec.FZGPR_PREIS_DAYP * L_DAYS_END_MONTH   )          --- ... plus tages - rate * vorschreibpflichtiger tage im endemonat
                                        + ( crec.FZGPR_PREIS_DAYP * L_MONTHS_BETWEEN * 30 );      --- ... plus tages - rate * vorschreibpflichtiger tage in den monaten dazwischen
           end loop;
      end  if;

      -- SUBVENTION
      select nvl ( sum ( ci.CI_AMOUNT ), 0 )
        into L_dblSubventionSum
        from snt.TFZGV_CONTRACTS@SIMEX_DB_LINK       co
           , snt.TCUSTOMER_INVOICE@SIMEX_DB_LINK     ci
           , snt.TCUSTOMER_INVOICE_TYP@SIMEX_DB_LINK custT
       where co.ID_VERTRAG               = i_ID_VERTRAG
         and co.ID_FZGVERTRAG            = i_ID_FZGVERTRAG
         and co.ID_SEQ_FZGVC             = ci.ID_SEQ_FZGVC
         and custT.GUID_CUSTINVTYPE      = ci.GUID_CUSTINVTYPE
         and custT.CUSTINVTYPE_STAT_CODE = '04';

      if   L_GS_RoundingMileageAmount is not null
      then return ( round ( L_dblMPSum + L_dblSubventionSum, L_GS_RoundingMileageAmount ));
      else return (         L_dblMPSum + L_dblSubventionSum                              );
      end  if;

    end CO_REVENUE_AMOUNT;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function chk_overlapping_prices
          ( i_ID_VERTRAG                  varchar2
          , i_ID_FZGVERTRAG               varchar2
          ) return                        integer is
          L_RETURNVALUE                   integer := 0;
   begin
        select 1                                    -- -> there are overlapping prices
          into L_RETURNVALUE
          from simex.TFZGPREIS_SIMEX ps1
         where rownum                = 1
           and i_ID_VERTRAG          = ps1.ID_VERTRAG
           and i_ID_FZGVERTRAG       = ps1.ID_FZGVERTRAG
           and exists ( select null
                          from simex.TFZGPREIS_SIMEX ps2
                         where i_ID_VERTRAG          = ps2.ID_VERTRAG
                           and i_ID_FZGVERTRAG       = ps2.ID_FZGVERTRAG
                           and ps1.ROWID            <> ps2.ROWID
                           and ( ps1.FZGPR_VON between ps2.FZGPR_VON and ps2.FZGPR_BIS
                              or ps1.FZGPR_BIS between ps2.FZGPR_VON and ps2.FZGPR_BIS ));
        return ( 1 );

   exception when NO_DATA_FOUND
             then return ( 0 );     -- -> no overlapping prices

   end chk_overlapping_prices;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

 /*  function currentNoOfVehicleContracts
          ( i_ID_VERTRAG                 varchar2
          ) return                       number is

            L_count                      number;
   begin
      -- FraBe MKS-129520:1 nur InScope CO dürfen gezählt werden!
          select count(*)
            into L_count
            from TFZGVERTRAG@SIMEX_DB_LINK fzgv
           where (  fzgv.ID_VERTRAG,  fzgv.ID_FZGVERTRAG ) in
          ( select fzgvc.ID_VERTRAG, fzgvc.ID_FZGVERTRAG
              from TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                 , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov
             where fzgvc.ID_VERTRAG       = i_ID_VERTRAG
               and fzgvc.ID_COV           = cov.ID_COV
               and cov.COV_CAPTION not like 'MIG_OOS%' );

         return L_count;

   end currentNoOfVehicleContracts;*/

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

 /*  function IDcustLastDuration
          ( i_ID_VERTRAG                  varchar2
          ) return                        varchar2 is

            L_ID_CUSTOMER                 varchar2 ( 15 char );
   begin

          select   ID_CUSTOMER
            into L_ID_CUSTOMER
            from TFZGV_CONTRACTS@SIMEX_DB_LINK   cust
           where rownum              = 1
             and ( cust.ID_VERTRAG, cust.FZGVC_BEGINN ) in ( select cust1.ID_VERTRAG, max ( cust1.FZGVC_BEGINN )
                                                               from TFZGV_CONTRACTS@SIMEX_DB_LINK cust1
                                                              where cust1.ID_VERTRAG    = i_ID_VERTRAG
                                                           group by cust1.ID_VERTRAG );

         return L_ID_CUSTOMER;

   end IDcustLastDuration;*/

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function ServcieCardLastPrintDate
          ( i_GUID_CONTRACT              varchar2
          ) return                       varchar2 is

            L_max_JO_END_DATE            varchar2 ( 8 char );
   begin

         select to_char ( max ( JO_END ), 'YYYYMMDD' )
           into L_max_JO_END_DATE
           from TJOURNAL@SIMEX_DB_LINK          j
              , TJOURNAL_POSITION@SIMEX_DB_LINK jp
          where jp.GUID_JO          = j.GUID_JO
            and jp.GUID_JOT         = '17'
            and jp.JOP_FOREIGN      = i_GUID_CONTRACT;

         return L_max_JO_END_DATE;

   exception when NO_DATA_FOUND then return null;
   end ServcieCardLastPrintDate;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function customerFDIssuedUntil
          ( i_ID_SEQ_FZGVC               number
          , i_FZGVC_BEGINN               date
          , i_FZGVC_PREL_OR_FINAL_END    date
          , i_ID_PAYM                    number
          ) return                       varchar2 is

            L_LAST_DAY_of_LAST_CI_DATE   date;
            L_RETURN_DATE                date;
   begin
         -- FraBe MKS-132150 / 132151: das höchstmögliche datum ist der 31.12.2099
         
         -- 1st select the last day of the month of the last MP customer invoice date
         select last_day ( max ( cip.CIP_DATE )) as LAST_DAY_of_LAST_CI_DATE
           into L_LAST_DAY_of_LAST_CI_DATE
           from snt.TCUSTOMER_INVOICE@SIMEX_DB_LINK ci
              , snt.TCUSTOMER_INVOICE_POS@SIMEX_DB_LINK cip
          where ci.GUID_CI          = cip.GUID_CI
            and ci.GUID_CUSTINVTYPE = get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'Setting', 'GUID_CUSTINVTYPE_Monthly_FlatRate' )
            and ci.ID_SEQ_FZGVC     = i_ID_SEQ_FZGVC;


         -- 2nd: calculate customerFDIssuedUntil date depending on mayment mode
         if    i_ID_PAYM =  0  -- nicht belegt
         then  L_RETURN_DATE := to_date ( '20991231', 'YYYYMMDD' );
         ----------------
         elsif i_ID_PAYM = -1  -- once / single payment
         then  if   L_LAST_DAY_of_LAST_CI_DATE is null
               then L_RETURN_DATE := i_FZGVC_BEGINN;              -- if no last CI date could be found: take CO BeginDate
               else L_RETURN_DATE := i_FZGVC_PREL_OR_FINAL_END;   -- else take CO FinalEndDate if already existing / if no CO FinalEndDate existing: take CO PrelEndDate
               end  if;
         ----------------
         else  -- else periodically (-> -2 or 1 to 12 )
               if   L_LAST_DAY_of_LAST_CI_DATE is null
               then L_RETURN_DATE := i_FZGVC_BEGINN;              -- if no last CI date could be found: take CO BeginDate
               else L_RETURN_DATE := L_LAST_DAY_of_LAST_CI_DATE;  -- else take last day of month of last CI
               end  if;
         end   if;
         
         --  das höchstmögliche datum ist der 31.12.2099
         if   L_RETURN_DATE > to_date ( '20991231', 'YYYYMMDD' )
         then return '20991231';
         else return to_char ( L_RETURN_DATE, 'YYYYMMDD' );
         end  if;

   exception when NO_DATA_FOUND then return null;
   end customerFDIssuedUntil;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function nextCOindexDate
          ( i_COS_ACTIVE                  number
          , i_INDV_TYPE                   number
          , i_FZGVC_IDX_NEXTDATE          date
          ) return                        varchar2 is

   begin

         -- the next CO PriceIndexDate is ...
         -- für alle länder:
         if   i_COS_ACTIVE = 0   --- ... the actual FZGVC_IDX_NEXTDATE, wenn CO nicht mehr aktiv -> CO wird daher auch nicht mehr indiziert
         then return to_char ( i_FZGVC_IDX_NEXTDATE, 'YYYYMMDD' );
         ------------------------------------------------------------------------
         else if   G_COUNTRY_CODE  = '51331'                                  --- ... länderweiche MBBEL
              then if   i_INDV_TYPE = 0
                   then return null;                                          --- ... CO wird nicht indexiert
                   else return to_char ( add_months ( sysdate, 12 ), 'YYYY' ) || '0301';   --- ... sonst (-> fix und flexibel ): 01.03 des nächsten jahres
                   end  if;
         ------------------------------------------------------------------------
              else                                                            --- ... default für andere länder
                   if    nvl ( i_FZGVC_IDX_NEXTDATE, sysdate + 1 ) > sysdate  --- ... the actual FZGVC_IDX_NEXTDATE if it is in the future or not existing
                   then  return to_char ( i_FZGVC_IDX_NEXTDATE, 'YYYYMMDD' );
                   else if    to_char ( i_FZGVC_IDX_NEXTDATE, 'DDMM' ) <> '2902'
                        then  return to_char ( add_months ( sysdate, 12 ), 'YYYY' ) || to_char ( i_FZGVC_IDX_NEXTDATE,     'MMDD' ); -- ... same day of next year of actual FZGVC_IDX_NEXTDATE
                        else  return to_char ( add_months ( sysdate, 12 ), 'YYYY' ) || to_char ( i_FZGVC_IDX_NEXTDATE + 1, 'MMDD' ); -- ... plus add 1 day within a leap year
                        end   if;
                   end  if;
              end  if;
         end  if;

   end nextCOindexDate;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function MileagesDiff
          ( i_FZGVC_PREL_OR_FINAL_ENDE_KM number
          , i_FZGVC_ENDE_KM               number
          , i_TYPE                        varchar2
          ) return                        number is

          L_MILEAGES_DIFF                 number;
   begin

         L_MILEAGES_DIFF := i_FZGVC_PREL_OR_FINAL_ENDE_KM - i_FZGVC_ENDE_KM;

         if    i_TYPE = 'exceededMileage'  -- final mehr KM gefahren, als geplant
         then  if   L_MILEAGES_DIFF > 0
               then return L_MILEAGES_DIFF;
               else return null;
               end  if;
         elsif i_TYPE = 'unusedMileage'    -- final weniger KM gefahren, als geplant
         then  if   L_MILEAGES_DIFF < 0
               then return L_MILEAGES_DIFF * -1;
               else return null;
               end  if;
         end   if;

   end MileagesDiff;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function days_between
          ( i_BEGINN                      date
          , i_ENDE                        date
          ) return                        number is

          L_days_diff                     number;
   begin

         -- jedes ganze monat wird mit 30 tagen gerechnet, egal wieviele tage es hat (-> 30 oder 31 oder 28 (-> FEB ), bzw. 29 (-> FEB Schaltjahr )
         -- die berechnung ist:
         -- A) ( Anzahl Monate vom 2. Monat bis vorletzten Monat ) * 30 tage
         -- B) plus anzahl tage erster monat: 30 - beginntag erster monat plus 1 day
         -- C) plus anzahl tage letzter monat:
         --    a) wenn das planned contractEndDate der letzte tag des monats ist: add 30 tage für ein weiteres volles monat
         --    b) sonst: plus anzahl tage im planned contractEndDate - monat

         -- zb. vertragsbeginn = 11.06.2010 / planned end = 10.06.2013:
         -- A) 35 monate x zu je 30 tage  = 1050 tage
         -- B) plus 20 tage (-> 30 - 11 + 1 tage )
         -- C) b) plus 10 days
         -- -> gesamt: 1080 tage (-> sind zufällig auch exact 36 monate zu je 30 tagen )

         -- A)
         L_days_diff := months_between ( add_months ( last_day ( i_ENDE ), - 1 ) + 1
                                       ,              last_day ( i_BEGINN )      + 1 )  -- (-> für die berechnung wird jeweils der erste tag des nächsten monats genommen )
                        * 30;
         -- B)
         L_days_diff := L_days_diff + ( 30
                                      - to_number ( to_char ( i_BEGINN, 'DD' ))
                                      + 1
                                      );
         -- C)
         if   i_ENDE = last_day ( i_ENDE )
         then L_days_diff := L_days_diff + 30;                                     -- a) last month is a complete month
         else L_days_diff := L_days_diff + to_number ( to_char ( i_ENDE, 'DD' ));  -- b) nur anzahl tage des vertragsende - monats, in dem der vertrag (- noch -) gültig ist
         end  if;

         return L_days_diff;

   end days_between;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function PlanndCOmileage
          ( i_FZGVC_BEGINN_KM             number
          , i_FZGVC_ENDE_KM               number
          ) return                        number is

   begin

         return i_FZGVC_ENDE_KM  - i_FZGVC_BEGINN_KM;

   end PlanndCOmileage;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function ChildCOtransferDate
          ( I_ID_VERTRAG                   varchar2
          , I_ID_FZGVERTRAG                varchar2
          ) return                         varchar2 is

          L_EXT_CREATION_DATE              date;

   begin

         select   min ( EXT_CREATION_DATE )
           into       L_EXT_CREATION_DATE
           from TFZGVERTRAG@SIMEX_DB_LINK
          where ID_VERTRAG_PARENT    = I_ID_VERTRAG
            and ID_FZGVERTRAG_PARENT = I_ID_FZGVERTRAG;

         return to_char ( L_EXT_CREATION_DATE, 'YYYYMMDD' );

   exception when NO_DATA_FOUND then return null;
   end ChildCOtransferDate;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function chk_SCOPE
          ( I_ID_VERTRAG                   varchar2
          , I_ID_FZGVERTRAG                varchar2
          , I_ID_COV                       number   := null
          ) return                         varchar2 is

          L_ID_COV                         TDFCONTR_VARIANT.ID_COV@SIMEX_DB_LINK%type;
          L_COV_CAPTION_substr             TDFCONTR_VARIANT.COV_CAPTION@SIMEX_DB_LINK%type;

   begin
   -- FraBe 11.02.2014 MKS-129519:1 creation
   -- FraBe 27.03.2014 MKS-131261:1 Logik umschreiben - es wird nur mehr MIG_OOS abgefragt
   -- FraBe 01.09.2014 MKS-132385:1 beheben bug: die returnwerte sind genau umgekehrt!
         if   I_ID_COV is null
         then select distinct substr ( cov.COV_CAPTION, 1, 7 )
                into                     L_COV_CAPTION_substr
                from TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                   , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov
               where fzgvc.ID_VERTRAG    = I_ID_VERTRAG
                 and fzgvc.ID_FZGVERTRAG = I_ID_FZGVERTRAG
                 and fzgvc.ID_COV        = cov.ID_COV
                 and 'MIG_OOS'           = substr ( cov.COV_CAPTION, 1, 7 );
         else select distinct substr ( cov.COV_CAPTION, 1, 7 )
                into                     L_COV_CAPTION_substr
                from TDFCONTR_VARIANT@SIMEX_DB_LINK  cov
               where I_ID_COV            = cov.ID_COV
                 and 'MIG_OOS'           = substr ( cov.COV_CAPTION, 1, 7 );
         end  if;

         return 'OUT';                                  ---> contract is InScope

   exception when NO_DATA_FOUND then return 'IN';       ---> contract is OutOfScope
   end chk_SCOPE;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   procedure ins_TFZGPREIS_SIMEX is

   -- purpose: calculates contract value
   --
   -- MODIFICATION HISTORY
   -- Person      Date       Comments
   -- ---------   ---------- -------------------------------------------
   -- FraBe       09.10.2013 MKS-126869: add 3rd step
   -- FraBe       18.08.2014 MKS-130002:1 add crec  - hint index / ordered (-> damit sich dieses statement nicht mehr aufhängt )
   -- FraBe       19.08.2014 MKS-132150:1/132151/1: add EXT_CREATION_DATE
   -- FraBe       21.10.2014 MKS-134450:3 select distinct within 1st step inserting
   begin
         delete simex.TFZGPREIS_SIMEX;
         -----------------------------------------------------------------------------------
         -- 1st: copy TFZGPREIS and LL info 1:1 into GlobalTembporaryTable TFZGPREIS_SIMEX:
         insert into simex.TFZGPREIS_SIMEX
              ( ID_SEQ_FZGVC
              , ID_VERTRAG
              , ID_FZGVERTRAG
              , FZGPR_VON
              , FZGPR_BIS
              , FZGPR_PREIS_GRKM
              , FZGPR_PREIS_MONATP
              , FZGPR_PREIS_FIX
              , FZGPR_ADD_MILEAGE
              , FZGPR_LESS_MILEAGE
              , FZGPR_BEGIN_MILEAGE
              , FZGPR_END_MILEAGE
              , EXT_CREATION_DATE
              , ID_LLEINHEIT
              , INDV_TYPE )
         select distinct
                pr.ID_SEQ_FZGVC
              , pr.ID_VERTRAG
              , pr.ID_FZGVERTRAG
              , pr.FZGPR_VON
              , pr.FZGPR_BIS
              , pr.FZGPR_PREIS_GRKM
              , pr.FZGPR_PREIS_MONATP
              , pr.FZGPR_PREIS_FIX
              , pr.FZGPR_ADD_MILEAGE
              , pr.FZGPR_LESS_MILEAGE
              , pr.FZGPR_BEGIN_MILEAGE
              , pr.FZGPR_END_MILEAGE
              , pr.EXT_CREATION_DATE
              , ll.ID_LLEINHEIT
              , indv.INDV_TYPE
           from TDF_INDEXATION_VARIANT@SIMEX_DB_LINK  indv
              , TFZGLAUFLEISTUNG@SIMEX_DB_LINK        ll
              , TFZGPREIS@SIMEX_DB_LINK               pr
              , TDFCONTR_VARIANT@SIMEX_DB_LINK        cov
              , TFZGV_CONTRACTS@SIMEX_DB_LINK         fzgvc
          where fzgvc.ID_COV           = cov.ID_COV
            and cov.COV_CAPTION      not like 'MIG_OOS%'
            and indv.GUID_INDV         = fzgvc.GUID_INDV
            and pr.ID_SEQ_FZGVC        = fzgvc.ID_SEQ_FZGVC
            and pr.ID_SEQ_FZGVC        = ll.ID_SEQ_FZGVC(+)
            and pr.FZGPR_VON          <= ll.FZGLL_VON(+)
            and pr.FZGPR_BIS          >= ll.FZGLL_BIS(+);

         -----------------------------------------------------------------------------------
         -- 2nd: additional: bei aktiven CO (-> COS_ACTIVE = 1 ), die flex - indexable (-> INDV_TYPE = 2 )
         -- sind, wird das letzte preis - FZGPR_BIS auf das PrelEndDate des CO gesetzt:
         update simex.TFZGPREIS_SIMEX pr
            set pr.FZGPR_BIS = ( select max ( fzgvc.FZGVC_ENDE )
                                   from TFZGV_CONTRACTS@SIMEX_DB_LINK    fzgvc
                                  where fzgvc.ID_SEQ_FZGVC    = pr.ID_SEQ_FZGVC )
          where exists         ( select null
                                   from simex.TFZGPREIS_SIMEX pr1
                                  where pr1.ID_SEQ_FZGVC      = pr.ID_SEQ_FZGVC
                                 having max ( pr1.FZGPR_BIS ) = pr.FZGPR_BIS )              --- only last price of last duration
            and (      pr.ID_VERTRAG
                     , pr.ID_FZGVERTRAG
                     , pr.ID_SEQ_FZGVC
                     , pr.INDV_TYPE ) in
              ( select fzgv1.ID_VERTRAG
                     , fzgv1.ID_FZGVERTRAG
                     , GET_MAX_CO@SIMEX_DB_LINK ( fzgv1.ID_VERTRAG, fzgv1.ID_FZGVERTRAG )   --- only last duration
                     , 2                                                                    --- only flex indexable prices
                  from TDFCONTR_STATE@SIMEX_DB_LINK    cos1
                     , TFZGVERTRAG@SIMEX_DB_LINK       fzgv1
                 where fzgv1.ID_COS   = cos1.ID_COS
-- TK; 03.11.2014; MKS-135471:1 - extend price for ALL indexed contracts, not only for active ones
--                   and 1              = cos1.COS_ACTIVE                                  --- only active contracts
                       );
         -----------------------------------------------------------------------------------
         -- 3rd: additional: bei aktiven CO (-> COS_ACTIVE = 1 ), die fixed - indexable (-> INDV_TYPE = 1 ) sind,
         -- und wo keine Preisbestandteile definiert sind ( -> COV_USE_CONSV_PRIME <> 1 ) werden ausgehend vom
         -- letzten preis (- der letzten duration -) neue simulierte preise erstellt - je einer für jedes jahr:

         declare
              L_FZGPR_VON                simex.TFZGPREIS_SIMEX.FZGPR_VON%type;
              L_FZGPR_BIS                simex.TFZGPREIS_SIMEX.FZGPR_BIS%type;
              L_FZGPR_PREIS_GRKM         simex.TFZGPREIS_SIMEX.FZGPR_PREIS_GRKM%type;
              L_FZGPR_PREIS_MONATP       simex.TFZGPREIS_SIMEX.FZGPR_PREIS_MONATP%type;
              L_FZGPR_PREIS_FIX          simex.TFZGPREIS_SIMEX.FZGPR_PREIS_FIX%type;

              L_LL_YEAR                  number;

              L_GS_RoundingMileageAmount TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%type := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'Setting',    'RoundingMileageAmount' );
              L_GS_FixPrice              TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%type := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'Indexation', 'FixPrice',  '0'  );

              function ROUND_VALUE
                     ( I_VALUE             number
                     ) return              number is


               begin
                     if   L_GS_RoundingMileageAmount is not null
                     then return ( round ( I_VALUE, L_GS_RoundingMileageAmount ));
                     else return (         I_VALUE                              );
                     end  if;
               end;

         begin
              for crec in ( SELECT
                                   fzgvc.ID_VERTRAG,          fzgvc.ID_FZGVERTRAG,       fzgvc.ID_SEQ_FZGVC,     fzgvc.FZGVC_ENDE, fzgvc.FZGVC_IDX_PERCENT
                                 , fzgpr.FZGPR_VON,           fzgpr.FZGPR_BIS
                                 , fzgpr.FZGPR_PREIS_GRKM,    fzgpr.FZGPR_PREIS_MONATP,  fzgpr.FZGPR_PREIS_FIX
                                 , fzgpr.FZGPR_ADD_MILEAGE,   fzgpr.FZGPR_LESS_MILEAGE
                                 , fzgpr.ID_LLEINHEIT
                              from TDFCONTR_VARIANT@SIMEX_DB_LINK   covar
                                 , TDFCONTR_STATE@SIMEX_DB_LINK     cos
                                 , TFZGVERTRAG@SIMEX_DB_LINK        fzgv
                                 , TFZGV_CONTRACTS@SIMEX_DB_LINK    fzgvc
                                 , simex.TFZGPREIS_SIMEX            fzgpr
                             where 1=1
                               -- TK; 03.11.2014; MKS-135471:1 - extend price for ALL indexed contracts, not only for active ones
                               -- AND cos.COS_ACTIVE           = 1                                    --- only active contracts
                               and cos.ID_COS               = fzgv.ID_COS
                               and fzgvc.ID_VERTRAG         = fzgv.ID_VERTRAG
                               and fzgvc.ID_FZGVERTRAG      = fzgv.ID_FZGVERTRAG
                               and 1                       <> covar.COV_USE_CONSV_PRIME            --- only CO ohne Preisbestandteile
                               and fzgvc.ID_COV             = covar.ID_COV
                               and fzgvc.ID_SEQ_FZGVC       = get_MAX_CO@SIMEX_DB_LINK ( fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG )
                               and fzgvc.ID_VERTRAG         = fzgpr.ID_VERTRAG
                               and fzgvc.ID_FZGVERTRAG      = fzgpr.ID_FZGVERTRAG
                               and 1                        = fzgpr.INDV_TYPE
                               and exists ( SELECT 
                                                   null
                                              from simex.TFZGPREIS_SIMEX fzgpr1
                                             where fzgpr1.ID_VERTRAG        = fzgpr.ID_VERTRAG
                                               and fzgpr1.ID_FZGVERTRAG     = fzgpr.ID_FZGVERTRAG
                                            having max ( fzgpr1.FZGPR_BIS ) = fzgpr.FZGPR_BIS )    --- only last price (- of last duration -)
                          order by 1, 2, 3, 6 )
              loop
                  -- dbms_output.put_line ( 'IDX: ' || crec.FZGVC_IDX_PERCENT );
                  -- 1) lesen letzte laufleistung per monat
                  select ll.FZGLL_LAUFLEISTUNG / ll.FZGLL_DAUER_MONATE
                    into L_LL_YEAR
                    from TFZGLAUFLEISTUNG@SIMEX_DB_LINK ll
                   where ll.ID_VERTRAG     = crec.ID_VERTRAG
                     and ll.ID_FZGVERTRAG  = crec.ID_FZGVERTRAG
                     and exists ( select null
                                    from TFZGLAUFLEISTUNG@SIMEX_DB_LINK ll1
                                   where ll1.ID_VERTRAG        = ll.ID_VERTRAG
                                     and ll1.ID_FZGVERTRAG     = ll.ID_FZGVERTRAG
                                  having max ( ll1.FZGLL_BIS ) = ll.FZGLL_BIS );                   --- only last LL (- of last duration -)
                  -------------------------------------------------------------------------
                  -- 2) einige crec values in L_ vars stellen, weil sich deren values bei den folgen berechnungen ändern:
                  L_FZGPR_PREIS_GRKM := crec.FZGPR_PREIS_GRKM;
                  L_FZGPR_PREIS_FIX  := crec.FZGPR_PREIS_FIX;
                  L_FZGPR_BIS        := crec.FZGPR_BIS;
                  -------------------------------------------------------------------------
                  -- 3) VON neuer preis = BIS letzter pri letzte duration + 1
                  L_FZGPR_VON        := L_FZGPR_BIS + 1;
                  -------------------------------------------------------------------------
                  -- 4) pri simulation nur wenn VON neuer pri nicht nach CO prel end
                  while L_FZGPR_VON < crec.FZGVC_ENDE
                  loop
                      -- I) VON neuer preis = nächster tag nach vorherigem BIS
                      L_FZGPR_VON  := L_FZGPR_BIS + 1;
                      -------------------------------------------------------------------------
                      -- II) BIS neuer pri = VON neuer pri + 1 jahr - 1 tag
                      L_FZGPR_BIS  := add_months ( L_FZGPR_VON, 12 ) - 1;
                      -------------------------------------------------------------------------
                      -- III) BIS neuer pri = CO prel end, wenn BIS neuer pri nach CO prel end
                      if   L_FZGPR_BIS  > crec.FZGVC_ENDE
                      then L_FZGPR_BIS := crec.FZGVC_ENDE;
                      end  if;
                      -------------------------------------------------------------------------
                      -- IV) ct/KM neu = letzter ct/KM erhöht um indexfaktor ev. gerundet mit faktor aus GS RoundingMileageAmount
                      L_FZGPR_PREIS_GRKM := ROUND_VALUE ( L_FZGPR_PREIS_GRKM * ( 100 + crec.FZGVC_IDX_PERCENT ) / 100 );
                      -------------------------------------------------------------------------
                      -- V)   Fixpreis neu = letzter Fixpreis       erhöht um indexfaktor ev. gerundet mit faktor aus GS RoundingMileageAmount, wenn GS Indexation / FixPrice       gesetzt
                      -- bzw. Fixpreis neu = letzter Fixpreis nicht erhöht um indexfaktor                                                       wenn GS Indexation / FixPrice nicht gesetzt
                      if    L_GS_FixPrice = 0 then L_FZGPR_PREIS_FIX := crec.FZGPR_PREIS_FIX;
                      elsif L_GS_FixPrice = 1 then L_FZGPR_PREIS_FIX := ROUND_VALUE ( crec.FZGPR_PREIS_FIX * ( 100 + crec.FZGVC_IDX_PERCENT ) / 100 );
                      else                         L_FZGPR_PREIS_FIX := 0;
                      end   if;
                      -------------------------------------------------------------------------
                      -- VI) neue MP = ct/KM neu * monatliche LL + Fixpreis neu ev. gerundet mit faktor aus GS RoundingMileageAmount
                      -- dbms_output.put_line ( 'L_FZGPR_PREIS_GRKM: ' || L_FZGPR_PREIS_GRKM || ' L_LL_YEAR: ' || L_LL_YEAR || ' L_FZGPR_PREIS_FIX: ' || L_FZGPR_PREIS_FIX );
                      L_FZGPR_PREIS_MONATP := ROUND_VALUE (( L_FZGPR_PREIS_GRKM * L_LL_YEAR / 100 ) + L_FZGPR_PREIS_FIX );
                      -------------------------------------------------------------------------
                      -- VII) neuen simulierten pri wegschreiben
                      -- dbms_output.put_line ( 'ID_SEQ_FZGVC: ' || crec.ID_SEQ_FZGVC || ' VON: ' || to_char ( L_FZGPR_VON, 'DD.MM.YYYY' ));
                      insert into simex.TFZGPREIS_SIMEX
                             ( ID_SEQ_FZGVC
                             , ID_VERTRAG
                             , ID_FZGVERTRAG
                             , FZGPR_VON
                             , FZGPR_BIS
                             , FZGPR_PREIS_GRKM
                             , FZGPR_PREIS_MONATP
                             , FZGPR_ADD_MILEAGE
                             , FZGPR_LESS_MILEAGE
                             , EXT_CREATION_DATE
                             , ID_LLEINHEIT
                             , INDV_TYPE )
                      values ( crec.ID_SEQ_FZGVC
                             , crec.ID_VERTRAG
                             , crec.ID_FZGVERTRAG
                             , L_FZGPR_VON
                             , L_FZGPR_BIS
                             , L_FZGPR_PREIS_GRKM
                             , L_FZGPR_PREIS_MONATP
                             , crec.FZGPR_ADD_MILEAGE
                             , crec.FZGPR_LESS_MILEAGE
                             , null                             -- EXT_CREATION_DATE bleibt leer, weil es nur simulierte, keine echten preise sind
                             , crec.ID_LLEINHEIT
                             , 1 );

                  end loop;

              end loop;

         end;

   end ins_TFZGPREIS_SIMEX;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_Product_House_Default
          ( I_PH_TYPE      tproduct_house.ph_type%type
          , I_RETURN_WHAT  varchar2 default 'PH_PARAM_OUT1'
          ) return         varchar2 is

         L_PH_PARAM_OUT1 TPRODUCT_HOUSE.PH_PARAM_OUT1%type;
         L_PH_PARAM_OUT2 TPRODUCT_HOUSE.PH_PARAM_OUT2%type;
         L_PH_PARAM_OUT3 TPRODUCT_HOUSE.PH_PARAM_OUT3%type;
         L_PH_PARAM_OUT4 TPRODUCT_HOUSE.PH_PARAM_OUT4%type;
         L_PH_PARAM_OUT5 TPRODUCT_HOUSE.PH_PARAM_OUT5%type;
         L_PH_PARAM_OUT6 TPRODUCT_HOUSE.PH_PARAM_OUT6%type;
         L_PH_PARAM_OUT7 TPRODUCT_HOUSE.PH_PARAM_OUT7%type;
         L_PH_PARAM_OUT8 TPRODUCT_HOUSE.PH_PARAM_OUT8%type;

begin

   -- TODO: EXCEPTION WHEN NO DATA FOUND!
    select   PH_PARAM_OUT1,   PH_PARAM_OUT2,   PH_PARAM_OUT3,   PH_PARAM_OUT4,   PH_PARAM_OUT5,   PH_PARAM_OUT6,   PH_PARAM_OUT7,   PH_PARAM_OUT8
      into L_PH_PARAM_OUT1, L_PH_PARAM_OUT2, L_PH_PARAM_OUT3, L_PH_PARAM_OUT4, L_PH_PARAM_OUT5, L_PH_PARAM_OUT6, L_PH_PARAM_OUT7, L_PH_PARAM_OUT8
      from TPRODUCT_HOUSE
     where PH_TYPE      = I_PH_TYPE
       and PH_DEFAULT   = 1;

       case I_RETURN_WHAT
          when 'PH_PARAM_OUT1' then return L_PH_PARAM_OUT1;
          when 'PH_PARAM_OUT2' then return L_PH_PARAM_OUT2;
          when 'PH_PARAM_OUT3' then return L_PH_PARAM_OUT3;
          when 'PH_PARAM_OUT4' then return L_PH_PARAM_OUT4;
          when 'PH_PARAM_OUT5' then return L_PH_PARAM_OUT5;
          when 'PH_PARAM_OUT6' then return L_PH_PARAM_OUT6;
          when 'PH_PARAM_OUT7' then return L_PH_PARAM_OUT7;
          when 'PH_PARAM_OUT8' then return L_PH_PARAM_OUT8;
       end case;
   end get_Product_House_Default;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_Product_House
          ( I_PH_TYPE      tproduct_house.ph_type%type
          , I_PH_PARAM_IN1 tproduct_house.ph_param_in1%type default null
          , I_PH_PARAM_IN2 tproduct_house.ph_param_in2%type default null
          , I_PH_PARAM_IN3 tproduct_house.ph_param_in3%type default null
          , I_PH_PARAM_IN4 tproduct_house.ph_param_in3%type default null
          , I_RETURN_WHAT  varchar2 default 'PH_PARAM_OUT1'
          ) return         varchar2 is

      L_PH_PARAM_OUT1 TPRODUCT_HOUSE.PH_PARAM_OUT1%type := null;
      L_PH_PARAM_OUT2 TPRODUCT_HOUSE.PH_PARAM_OUT2%type := null;
      L_PH_PARAM_OUT3 TPRODUCT_HOUSE.PH_PARAM_OUT3%type := null;
      L_PH_PARAM_OUT4 TPRODUCT_HOUSE.PH_PARAM_OUT4%type := null;
      L_PH_PARAM_OUT5 TPRODUCT_HOUSE.PH_PARAM_OUT5%type := null;
      L_PH_PARAM_OUT6 TPRODUCT_HOUSE.PH_PARAM_OUT6%type := null;
      L_PH_PARAM_OUT7 TPRODUCT_HOUSE.PH_PARAM_OUT7%type := null;
      L_PH_PARAM_OUT8 TPRODUCT_HOUSE.PH_PARAM_OUT8%type := null;

   begin
      -- FraBe 14.08.2014 MKS-133123:1   get_Product_House: add I_PH_PARAM_IN4
      if     I_PH_PARAM_IN1 is not null                                                                                                       -- -> I_PH_PARAM_IN1 muß hier generell einen wert haben / bei rows mit nem defaultwert ist die column leer
      and (( I_PH_TYPE in ( 'PRODUCT', 'PRODUCTOPTION', 'TECHNICALOPTION' ) and I_PH_PARAM_IN2 is not null and I_PH_PARAM_IN3 is not null )   -- -> diesen 3 types müssen alle IN parameter gesetztsein
        or ( I_PH_TYPE in ( 'SPP_PRODUCTS', 'SUPPLIER' )                    and I_PH_PARAM_IN2 is not null                                )   -- -> diesen 2 -> nur IN param1 und 2
        or ( I_PH_TYPE  =   'PRODUCTCOVERAGE'                                                                                             ))  -- -> diesem einen: nur param1
      then select   PH_PARAM_OUT1,   PH_PARAM_OUT2,   PH_PARAM_OUT3,   PH_PARAM_OUT4,   PH_PARAM_OUT5,   PH_PARAM_OUT6,   PH_PARAM_OUT7,   PH_PARAM_OUT8
             into L_PH_PARAM_OUT1, L_PH_PARAM_OUT2, L_PH_PARAM_OUT3, L_PH_PARAM_OUT4, L_PH_PARAM_OUT5, L_PH_PARAM_OUT6, L_PH_PARAM_OUT7, L_PH_PARAM_OUT8
             from TPRODUCT_HOUSE
          where PH_TYPE      = I_PH_TYPE
            and PH_DEFAULT   = 0
            and (                                                            PH_PARAM_IN1 = I_PH_PARAM_IN1 )
            and ( I_PH_PARAM_IN2 is null or ( I_PH_PARAM_IN2 is not null and PH_PARAM_IN2 = I_PH_PARAM_IN2 ))
            and ( I_PH_PARAM_IN3 is null or ( I_PH_PARAM_IN3 is not null and PH_PARAM_IN3 = I_PH_PARAM_IN3 ))
            and ( I_PH_PARAM_IN4 is null or ( I_PH_PARAM_IN4 is not null and PH_PARAM_IN4 = I_PH_PARAM_IN4 ));
      -- TK 03.11.14; MKS-135291:1 - Delivering Default values, if no data found
      else
         return get_product_house_default(I_PH_TYPE,I_RETURN_WHAT);
      end if;
      
      case I_RETURN_WHAT
          when 'PH_PARAM_OUT1' then return L_PH_PARAM_OUT1;
          when 'PH_PARAM_OUT2' then return L_PH_PARAM_OUT2;
          when 'PH_PARAM_OUT3' then return L_PH_PARAM_OUT3;
          when 'PH_PARAM_OUT4' then return L_PH_PARAM_OUT4;
          when 'PH_PARAM_OUT5' then return L_PH_PARAM_OUT5;
          when 'PH_PARAM_OUT6' then return L_PH_PARAM_OUT6;
          when 'PH_PARAM_OUT7' then return L_PH_PARAM_OUT7;
          when 'PH_PARAM_OUT8' then return L_PH_PARAM_OUT8;
      end case;
      
      EXCEPTION
      -- TK 03.11.14; MKS-135291:1 - Delivering Default values, if no data found
        when no_data_found then
        return get_product_house_default(I_PH_TYPE,I_RETURN_WHAT);

   end get_Product_House;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_Used
          ( I_FZGV_ERSTZULASSUNG TFZGVERTRAG.FZGV_ERSTZULASSUNG@SIMEX_DB_LINK%type
          , I_FZGVC_BEGINN       TFZGV_CONTRACTS.FZGVC_BEGINN@SIMEX_DB_LINK%type
          ) return               number is

   l_DAYS_BETWEEN number;
   l_RET_VAL      number;
   l_NCC_LIMIT    number;
   l_USED_LIMIT   number;

   begin
/*
      l_DAYS_BETWEEN := trunc(I_FZGV_ERSTZULASSUNG - I_FZGVC_BEGINN);

      if l_DAYS_BETWEEN <= 180 then
         l_RET_VAL := 0;
      elsif l_DAYS_BETWEEN <= 730 then
         l_RET_VAL := 1;
      else
         l_RET_VAL := 2;
      end if;
      return l_RET_VAL;
*/

  --mks 135398:1; KT; 2014-10-31
  l_NCC_LIMIT := PCK_CALCULATION.GET_SETTING('SETTING','NCC_LIMIT', 180);
  l_USED_LIMIT := PCK_CALCULATION.GET_SETTING('SETTING','USED_LIMIT', 720);
  
  if I_FZGVC_BEGINN <= I_FZGV_ERSTZULASSUNG + l_NCC_LIMIT 
   then return 0; -- (which means new)
  end if;
      
  if  (I_FZGVC_BEGINN > I_FZGV_ERSTZULASSUNG + l_NCC_LIMIT) 
  AND (I_FZGVC_BEGINN < I_FZGV_ERSTZULASSUNG + l_USED_LIMIT) 
  then return 1; --(which means NNC)
  else return 2;-- (wich means used)
  end if;
            
  end get_Used;

----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_default_coverage
          ( I_FZGVC_BEGINN       date
          , I_FZGVC_BEGINN_KM    number
          , I_FZGVC_ENDE         date
          , I_FZGVC_ENDE_KM      number
          , I_finEnd_FZGKM_DATUM date
          , I_finEnd_FZGKM_KM    number
          ) return               xmltype is

            L_RETURNVALUE        xmltype;
            l_DEFaultCoverageExists               varchar2(50 char);

   begin
       -- TK; 2014-11-07; MKS-135279:1 / check if a default coverage exists, if NO then skip
       select PCK_CONTRACT.get_Product_House_Default(  I_PH_TYPE => 'PRODUCTCOVERAGE' , I_RETURN_WHAT  => 'PH_PARAM_OUT2' ) into l_DEFaultCoverageExists from dual;
       
       -- FraBe 20.03.2014 MKS-131260:1 / 131261:1 creation due to wave 3.2 changes
       if   (sign ( I_FZGVC_BEGINN - to_date ( replace ( G_migrationDate, 'T', ' ' ), 'YYYY-MM-DD HH24:MI:SS' )) = 1 )
          OR (l_DEFaultCoverageExists is NULL)
       then L_RETURNVALUE := null;    -->  das CO start date liegt nach dem G_migrationDate
       else select xmlagg ( XMLELEMENT ( "coverage", xmlattributes ( PCK_CONTRACT.get_Product_House_Default
                                                                                 ( I_PH_TYPE      => 'PRODUCTCOVERAGE'
                                                                                 , I_RETURN_WHAT  => 'PH_PARAM_OUT2' )        as "code"
                                                                   , PCK_CONTRACT.get_Product_House_Default
                                                                                 ( I_PH_TYPE      => 'PRODUCTCOVERAGE'
                                                                                 , I_RETURN_WHAT  => 'PH_PARAM_OUT4' )        as "coverageDefinition"
                                                                   , PCK_CONTRACT.get_Product_House_Default
                                                                                 ( I_PH_TYPE      => 'PRODUCTCOVERAGE'
                                                                                 , I_RETURN_WHAT  => 'PH_PARAM_OUT1' )        as "productCoverage" )
                                                   , XMLELEMENT ( "period", xmlattributes ( to_char ( I_FZGVC_ENDE,         'YYYYMMDD' )    as "plannedEndDate"
                                                                                          ,           I_FZGVC_ENDE_KM                       as "plannedVehicleMileageAtCoverageEnd"
                                                                                          , to_char ( I_finEnd_FZGKM_DATUM, 'YYYYMMDD' )    as "realEndDate"
                                                                                          ,           I_finEnd_FZGKM_KM                     as "realVehicleMileageCoverageEnd"
                                                                                          , to_char ( I_FZGVC_BEGINN,       'YYYYMMDD' )    as "startFrom"
                                                                                          ,           I_FZGVC_BEGINN_KM                     as "vehicleMileageCoverageStart" ))))
              into L_RETURNVALUE
              from dual;
       end  if;

       return L_RETURNVALUE;

    end get_default_coverage;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_ProductCOVERAGE
          ( I_GUID_BUSINESS_AREA_L2   varchar2
          , I_FZGVC_BEGINN            date
          , I_FZGVC_BEGINN_KM         number
          , I_FZGVC_ENDE              date
          , I_FZGVC_ENDE_KM           number
          , I_finEnd_FZGKM_DATUM      date
          , I_finEnd_FZGKM_KM         number
          , I_product                 varchar2
          ) return                    xmltype   is
            L_RETURNVALUE             xmltype;
            L_PH_PARAM_IN1            simex.TPRODUCT_HOUSE.PH_PARAM_IN1%type;

   begin
          -- FraBe 20.03.2014 MKS-131260:1 / 131261:1 creation due to wave 3.2 changes
          L_PH_PARAM_IN1 := I_product;

          select xmlagg ( XMLELEMENT ( "coverage", xmlattributes ( ph.PH_PARAM_OUT2              as "code"
                                                                 , ph.PH_PARAM_OUT4              as "coverageDefinition"
                                                                 , decode ( ph.PH_PARAM_OUT5
                                                                          , null, null, 'true' ) as "externalRiskCarrier"
                                                                 , ph.PH_PARAM_OUT1              as "productCoverage"
                                                                 , decode ( ph.PH_PARAM_OUT5                                   -- wenn PH_PARAM_OUT5 is null: braucht nicht nach SUPPLIER umgeschlüsselt werden
                                                                          , null, null, PCK_CONTRACT.get_Product_House
                                                                                        ( I_PH_TYPE      => 'SUPPLIER'
                                                                                        , I_PH_PARAM_IN1 => ph.PH_PARAM_OUT5
                                                                                        , I_PH_PARAM_IN2 => I_GUID_BUSINESS_AREA_L2
                                                                                        , I_RETURN_WHAT  => 'PH_PARAM_OUT1' ))    as "serviceOfferingComponentToSupplier"  )
                                                                 , XMLELEMENT ( "period", xmlattributes ( to_char ( I_FZGVC_ENDE,         'YYYYMMDD' ) as "plannedEndDate"
                                                                                                        ,           I_FZGVC_ENDE_KM                    as "plannedVehicleMileageAtCoverageEnd"
                                                                                                        , to_char ( I_finEnd_FZGKM_DATUM, 'YYYYMMDD' ) as "realEndDate"
                                                                                                        ,           I_finEnd_FZGKM_KM                  as "realVehicleMileageCoverageEnd"
                                                                                                        , to_char ( I_FZGVC_BEGINN,       'YYYYMMDD' ) as "startFrom"
                                                                                                        , I_FZGVC_BEGINN_KM                            as "vehicleMileageCoverageStart" ))
                                     ) order by ph.PH_PARAM_OUT2 )
            into L_RETURNVALUE
            from simex.TPRODUCT_HOUSE                 ph
           where ph.PH_TYPE      = 'PRODUCTCOVERAGE'
             and ph.PH_PARAM_IN1 = L_PH_PARAM_IN1;

       return L_RETURNVALUE;

    end get_ProductCOVERAGE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_ProductOPTION
          ( I_GUID_CONTRACT           varchar2
          , I_GUID_BUSINESS_AREA_L2   varchar2
          , I_FZGVC_BEGINN            date
          , I_FZGVC_BEGINN_KM         number
          , I_FZGVC_ENDE              date
          , I_FZGVC_ENDE_KM           number
          , I_finEnd_FZGKM_DATUM      date
          , I_finEnd_FZGKM_KM         number
          , I_product                 varchar2
          ) return                    xmltype   is
            L_RETURNVALUE             xmltype;
            L_PH_PARAM_IN1            simex.TPRODUCT_HOUSE.PH_PARAM_IN1%type;

   begin
          -- FraBe 20.03.2014 MKS-131260:1 / 131261:1 creation due to wave 3.2 changes
          L_PH_PARAM_IN1 := I_product;

          select xmlagg ( XMLELEMENT ( "coverage", xmlattributes ( ph.PH_PARAM_OUT2               as "code"
                                                                 , ph.PH_PARAM_OUT4               as "coverageDefinition"
                                                                 , decode ( ph.PH_PARAM_OUT5
                                                                           , null, null, 'true' ) as "externalRiskCarrier"
                                                                 , ph.PH_PARAM_OUT6               as "manufacturer"
                                                                 , ph.PH_PARAM_OUT1               as "productOption"
                                                                 , decode ( ph.PH_PARAM_OUT5                                   -- wenn PH_PARAM_OUT5 is null: braucht nicht nach SUPPLIER umgeschlüsselt werden
                                                                          , null, null, PCK_CONTRACT.get_Product_House
                                                                                                    ( I_PH_TYPE      => 'SUPPLIER'
                                                                                                    , I_PH_PARAM_IN1 => ph.PH_PARAM_OUT5
                                                                                                    , I_PH_PARAM_IN2 => I_GUID_BUSINESS_AREA_L2
                                                                                                    , I_RETURN_WHAT  => 'PH_PARAM_OUT1' )) as "serviceOfferingComponentToSupplier"  )
                                                 , XMLELEMENT ( "period", xmlattributes ( to_char ( I_FZGVC_ENDE,             'YYYYMMDD' ) as "plannedEndDate"
                                                                                        ,           I_FZGVC_ENDE_KM                        as "plannedVehicleMileageAtCoverageEnd"
                                                                                        , to_char ( I_finEnd_FZGKM_DATUM,     'YYYYMMDD' ) as "realEndDate"
                                                                                        ,           I_finEnd_FZGKM_KM                      as "realVehicleMileageCoverageEnd"
                                                                                        , to_char ( I_FZGVC_BEGINN,           'YYYYMMDD' ) as "startFrom"
                                                                                        ,           I_FZGVC_BEGINN_KM                      as "vehicleMileageCoverageStart" ))
                                     ) order by ph.PH_PARAM_OUT2 )
             into L_RETURNVALUE
             from ( /*-- zuerst paketgetriebene attribute:
                    select ph1.PH_TYPE, ph1.PH_PARAM_IN1, ph1.PH_PARAM_IN2, ph1.PH_PARAM_IN3, ph1.PH_PARAM_OUT1, ph1.PH_PARAM_OUT2, ph1.PH_PARAM_OUT4, ph1.PH_PARAM_OUT5, ph1.PH_PARAM_OUT6
                      from simex.TPRODUCT_HOUSE                 ph1
                         , TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK    vval1
                         , TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK    vatt1
                         , TVEGA_I55_CO@SIMEX_DB_LINK           vco
                     where vco.GUID_CONTRACT        = I_GUID_CONTRACT
                       and vco.GUID_VI55A           = vatt1.GUID_VI55A
                       and vco.GUID_VI55AV          = vval1.GUID_VI55AV
                       and vatt1.GUID_VI55A         = vval1.GUID_VI55A
                       and ph1.PH_PARAM_IN1         = L_PH_PARAM_IN1
                       and ph1.PH_PARAM_IN2         = vatt1.VI55A_CAPTION
                       and ph1.PH_PARAM_IN3         = vval1.VI55AV_VALUE
                       and ph1.PH_TYPE              = 'PRODUCTOPTION'
                     */
                     -- corrected assignment via Package Caption and NOT VEGA ID TK 2014-06-02
                     select ph1.PH_TYPE, ph1.PH_PARAM_IN1, ph1.PH_PARAM_IN2, ph1.PH_PARAM_IN3, ph1.PH_PARAM_OUT1, ph1.PH_PARAM_OUT2, ph1.PH_PARAM_OUT4, ph1.PH_PARAM_OUT5, ph1.PH_PARAM_OUT6
                      from simex.TPRODUCT_HOUSE  ph1
                           ,tic_package@SIMEX_DB_LINK p
                           ,tic_co_pack_ass@SIMEX_DB_LINK pa
                     where 1=1 
                       and ph1.PH_PARAM_IN1         = L_PH_PARAM_IN1
                       and ph1.PH_TYPE              = 'PRODUCTOPTION'
                       and ph1.ph_param_in2 = p.icp_caption
                       and p.guid_package = pa.guid_package
                       and pa.guid_contract =  I_GUID_CONTRACT
                     -- end of correction
                     union -- dann vertragsgetriebene attribute
                    SELECT /*+ DRIVING_SITE(copa) */
                           ph1.PH_TYPE
                         , ph1.PH_PARAM_IN1
                         , ph1.PH_PARAM_IN2
                         , ph1.PH_PARAM_IN3
                         , ph1.PH_PARAM_OUT1
                         , ph1.PH_PARAM_OUT2
                         , ph1.PH_PARAM_OUT4
                         , ph1.PH_PARAM_OUT5
                         , ph1.PH_PARAM_OUT6
                      FROM tic_co_pack_ass@SIMEX_DB_LINK      copa
                      JOIN tic_package@SIMEX_DB_LINK          icp1     ON icp1.GUID_PACKAGE = copa.GUID_PACKAGE
                      JOIN tvega_i55_att_value@SIMEX_DB_LINK  vval1    ON vval1.GUID_VI55AV = icp1.GUID_VI55AV
                      JOIN tvega_i55_attribute@SIMEX_DB_LINK  vatt1    ON vatt1.GUID_VI55A  = COPA.GUID_VI55A
                                                                      AND vatt1.GUID_VI55A  = VVAL1.GUID_VI55A
                      JOIN simex.tproduct_house               ph1      ON ph1.PH_PARAM_IN2  = 'VEGA' || vatt1.VI55A_DISPLACEMENT
                                                                      AND ph1.PH_PARAM_IN3  =           vval1.VI55AV_VALUE
                     WHERE copa.GUID_CONTRACT = I_GUID_CONTRACT
                       AND ph1.PH_TYPE = 'PRODUCTOPTION'
                       AND ph1.PH_PARAM_IN1   = L_PH_PARAM_IN1             
                  ) ph;

       return L_RETURNVALUE;

    end get_ProductOPTION;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_SPP_product_COVERAGE
          ( I_GUID_CONTRACT           varchar2
          , I_ID_VERTRAG              varchar2
          , I_ID_FZGVERTRAG           varchar2
          , I_GUID_BUSINESS_AREA_L2   varchar2
          , I_FZGVC_BEGINN            date
          , I_FZGVC_BEGINN_KM         number
          , I_FZGVC_ENDE              date
          , I_FZGVC_ENDE_KM           number
          , I_finEnd_FZGKM_DATUM      date
          , I_finEnd_FZGKM_KM         number
          , I_product                 varchar2
          , I_einsArt_GUID_VI55AV     varchar2
          ) return                    xmltype   is
            L_RETURNVALUE             xmltype;
            L_PH_PARAM_IN3            simex.TPRODUCT_HOUSE.PH_PARAM_IN3%type;

   begin
          -- FraBe 20.03.2014 MKS-131260:1 / 131261:1 creation due to wave 3.2 changes
          -- FraBe 01.09.2014 MKS-132150:1 / 132151:1 sPCoPri.SPCP_VALUE ist in cent nicht EURO (-> divide by 100 )
          -- FraBe 01.09.2014 MKS-132387:1 code umschreiben, daß bei TPRODUCT_HOUSE ein (+) möglich ist
          --                               normalerweise kann ja von mehr als einer tabelle nicht auf eine andere gejoint werden ...
          -- FraBe 02.09.2014 MKS-132387:2 check auf upper ( ph.PH_PARAM_OUT7 ) in ( 'YES', 'TRUE' )
          -- FraBe 04.09.2014 MKS-134257:1 extract PH_PARAM_OUT1 and not PH_PARAM_OUT2 within xmlAttribute "code"
          --                               (- anmerkung: hier ist es der wert 1, bei allen anderen ist es 2 ! -)
          -- FraBe 17.11.2014 MKS-135673:1 ersetzen decode ( nvl ( main_sel.SPCP_VALUE, 0 ) mit case

          -- achtung: hier haben wir PH_PARAM_IN3 und nicht PH_PARAM_IN1 wie bei get_ProductCOVERAGE und get_ProductOPTION!
          L_PH_PARAM_IN3 := I_product;

          select xmlagg ( XMLELEMENT ( "coverage", xmlattributes ( ph.PH_PARAM_OUT1                                   as "code"
                                                                 , ph.PH_PARAM_OUT8                                   as "contingentDefinition"
                                                                 , case when upper ( ph.PH_PARAM_OUT7 ) in ( 'YES', 'TRUE' )
                                                                        then get_ATTRIBUTE_TEXT@SIMEX_DB_LINK
                                                                                       ( I_GUID_CONTRACT
                                                                                       , I_einsArt_GUID_VI55AV
                                                                                       , I_ID_VERTRAG
                                                                                       , I_ID_FZGVERTRAG, 158, 159 )
                                                                        else null 
                                                                   end                                                as "contingentInitial"
                                                                 , substr ( main_sel.SPC_EXTERNAL_ID, 20 )            as "contractNumberExternal"
                                                                 , ph.PH_PARAM_OUT4                                   as "coverageDefinition"
                                                                 , decode ( ph.PH_PARAM_OUT5
                                                                           , null, null, 'true' )                     as "externalRiskCarrier"
                                                                 , PCK_CONTRACT.get_Product_House
                                                                       ( I_PH_TYPE      => 'SUPPLIER'
                                                                       , I_PH_PARAM_IN1 => ph.PH_PARAM_OUT5
                                                                       , I_PH_PARAM_IN2 => I_GUID_BUSINESS_AREA_L2
                                                                       , I_RETURN_WHAT  => 'PH_PARAM_OUT1' )          as "serviceOfferingComponentToSupplier"
                                                                 , ph.PH_PARAM_OUT3                                   as "tyreProfile"
                                                                 , ph.PH_PARAM_OUT6                                   as "tyreService" )
                                                 -- MKS-135673: ersetzen decode ( nvl ( main_sel.SPCP_VALUE, 0 ) mit case, da die neue abfrage nur auf null / not null
                                                 , case when main_sel.SPCP_VALUE is not null
                                                        then XMLELEMENT ( "coverageRealCost"
                                                                  , xmlattributes ( decode ( main_sel.SPC_VARIANT
                                                                                            , 1, main_sel.SPCP_VALUE
                                                                                                , null )              as "flatSupplierInvoiceAmount"
                                                                                  , decode ( main_sel.SPC_VARIANT
                                                                                            , 2, main_sel.SPCP_VALUE / 100  
                                                                                                , null )              as "centPerMile" ))
                                                   end
                                                 -- MKS-135673: ersetzen decode ( nvl ( main_sel.SPCP_VALUE, 0 ) mit case, da die neue abfrage nur auf null / not null
                                                 , case when main_sel.SPCP_VALUE is not null
                                                        then XMLELEMENT ( "period"
                                                                  , xmlattributes ( to_char ( main_sel.SPC_VALID_TO,   'YYYYMMDD' ) as "plannedEndDate"
                                                                                  , to_char ( I_finEnd_FZGKM_DATUM,    'YYYYMMDD' ) as "realEndDate"
                                                                                  , to_char ( main_sel.SPC_VALID_FROM, 'YYYYMMDD' ) as "startFrom" ))
                                                   end
                                     ) order by main_sel.VI55A_DISPLACEMENT, ph.PH_PARAM_OUT1 )
            into L_RETURNVALUE
            from simex.TPRODUCT_HOUSE                 ph
               , ( select spCo.ID_VERTRAG
                        , spCo.ID_FZGVERTRAG
                        , spCo.SPC_EXTERNAL_ID
                        , sPCoPri.SPCP_VALUE
                        , spCo.SPC_VARIANT
                        , spCo.SPC_VALID_FROM
                        , spCo.SPC_VALID_TO
                        , vatt.VI55A_DISPLACEMENT
                        , icp.ICP_CAPTION
                     from snt.TIC_PACKAGE@SIMEX_DB_LINK            icp
                        , snt.TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK    vval
                        , snt.TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK    vatt
                        , snt.TIC_SPC_PACK_ASS@SIMEX_DB_LINK       copa
                        , snt.TSP_CONTRACT@SIMEX_DB_LINK           spCo
                        , snt.TSP_CONTRACT_PRICE@SIMEX_DB_LINK     spCoPri
                    where spCoPri.GUID_SPC      = spCo.GUID_SPC
                      and copa.GUID_SPC         = spCo.GUID_SPC
                      and copa.GUID_VI55A       = vatt.GUID_VI55A
                      and copa.GUID_PACKAGE     = icp.GUID_PACKAGE
                      and vval.GUID_VI55AV      = icp.GUID_VI55AV
                      and vval.GUID_VI55A       = vatt.GUID_VI55A ) main_sel
           where I_ID_VERTRAG          = main_sel.ID_VERTRAG
             and I_ID_FZGVERTRAG       = main_sel.ID_FZGVERTRAG
             and ph.PH_PARAM_IN1 (+)   = main_sel.VI55A_DISPLACEMENT
             and ph.PH_PARAM_IN2 (+)   = main_sel.ICP_CAPTION
             and ph.PH_PARAM_IN3 (+)   = L_PH_PARAM_IN3
             and ph.PH_TYPE      (+)   = 'SPP_PRODUCTS';

       return L_RETURNVALUE;

    end get_SPP_product_COVERAGE;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function get_PriceCalcPart
           ( I_XMLELEMENT_EVALNAME     varchar2
           , I_CUSTINV_TYPE            varchar2
           , I_PRICE_CALC_PART_AMOUNT  number
           , I_ID_SEQ_FZGVC            TFZGPREIS.ID_SEQ_FZGVC@SIMEX_DB_LINK%type
           , I_CUST_COST_CENTER        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%type
           , I_CUST_SAP_NUMBER_DEBITOR TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%type
           ) return                    xmltype  is

             L_RETURNVALUE             xmltype;
             L_STAT                    boolean;
             L_CI_AMOUNT               TCUSTOMER_INVOICE.CI_AMOUNT@SIMEX_DB_LINK%type;
             L_CUST_COST_CENTER        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%type;
             L_CUST_SAP_NUMBER_DEBITOR TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%type;

    begin
        -- FraBe 26.03.2014 MKS-131261    creation (- due to wave 3.2 CO -)
        -- FraBe 04.04.2014 MKS-132055:1  substr ( 1, 10 ) within xmlattribute costCenterReference
        if   nvl ( I_PRICE_CALC_PART_AMOUNT, 0 ) <= 0
        then L_RETURNVALUE := null;
        else begin
                select   CI_AMOUNT
                  into L_CI_AMOUNT
                  from TCUSTOMER_INVOICE@SIMEX_DB_LINK      ci
                     , TCUSTOMER_INVOICE_TYP@SIMEX_DB_LINK  ci_typ
                 where ci.CI_AMOUNT              = I_PRICE_CALC_PART_AMOUNT
                   and ci.ID_SEQ_FZGVC           = I_ID_SEQ_FZGVC
                   and ci.GUID_CUSTINVTYPE       = ci_typ.GUID_CUSTINVTYPE
                   and I_CUSTINV_TYPE            = ci_typ.CUSTINVTYPE_SHORT_CAPTION
                   and rownum                    = 1;

                L_STAT := true;

             exception when NO_DATA_FOUND then L_STAT := false;
             end;

             if  L_STAT = true
             then L_CUST_COST_CENTER         := I_CUST_COST_CENTER;
                  L_CUST_SAP_NUMBER_DEBITOR  := I_CUST_SAP_NUMBER_DEBITOR;
             else L_CUST_COST_CENTER         := null;
                  L_CUST_SAP_NUMBER_DEBITOR  := 'migration';
             end  if;

             select XMLELEMENT ( EVALNAME I_XMLELEMENT_EVALNAME
                               , xmlattributes ( 'migration'              as "indiviudalText"
                                               , 'amount'                 as "inputType"
                                               , I_PRICE_CALC_PART_AMOUNT as "totalAmount" )
                               , XMLELEMENT ( "plannedDiscountDistribution"
                                            , xmlattributes ( substr ( L_CUST_COST_CENTER,        1, 10 ) as "costCenterReference"
                                                            , substr ( L_CUST_SAP_NUMBER_DEBITOR, 1, 10 ) as "financialSystemDebitorNumber" )))
              into L_RETURNVALUE
              from dual;
        end   if;

        return L_RETURNVALUE;

    end get_PriceCalcPart;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function get_PriceCalcPart_Campaign
           ( I_XMLELEMENT_EVALNAME     varchar2
           , I_CUSTINV_TYPE            varchar2
           , I_PRICE_CALC_PART_AMOUNT  number
           , I_ID_SEQ_FZGVC            TFZGPREIS.ID_SEQ_FZGVC@SIMEX_DB_LINK%type
           , I_CUST_COST_CENTER        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%type
           , I_CUST_SAP_NUMBER_DEBITOR TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%type
           , I_campaignCode            varchar2
           ) return                    xmltype  is

             L_RETURNVALUE             xmltype;
             L_STAT                    boolean;
             L_CI_AMOUNT               TCUSTOMER_INVOICE.CI_AMOUNT@SIMEX_DB_LINK%type;
             L_CUST_COST_CENTER        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%type;
             L_CUST_SAP_NUMBER_DEBITOR TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%type;

    begin
        -- FraBe 26.03.2014 MKS-131261    creation (- due to wave 3.2 CO -)

        -- description:
        -- almost the same than previous function get_PriceCalcPart
        -- but the logic within / the name of the sub - XMLELEMENT and 3 XMLATTRIBUTES differ:
        -- XMLELEMENT:    plannedSalesCampaignDistribution instead of plannedDiscountDistribution
        -- XMLATTRIBUTE1: campaignCode                     instead of indiviudalText
        -- XMLATTRIBUTE2: costCenter                       instead of costCenterReference
        -- XMLATTRIBUTE3: no inputType like in previous function get_PriceCalcPart

        if   nvl ( I_PRICE_CALC_PART_AMOUNT, 0 ) <= 0
        then L_RETURNVALUE := null;
        else begin
                select   CI_AMOUNT
                  into L_CI_AMOUNT
                  from TCUSTOMER_INVOICE@SIMEX_DB_LINK      ci
                     , TCUSTOMER_INVOICE_TYP@SIMEX_DB_LINK  ci_typ
                 where ci.CI_AMOUNT              = I_PRICE_CALC_PART_AMOUNT
                   and ci.ID_SEQ_FZGVC           = I_ID_SEQ_FZGVC
                   and ci.GUID_CUSTINVTYPE       = ci_typ.GUID_CUSTINVTYPE
                   and I_CUSTINV_TYPE            = ci_typ.CUSTINVTYPE_SHORT_CAPTION
                   and rownum                    = 1;

                L_STAT := true;

             exception when NO_DATA_FOUND then L_STAT := false;
             end;

             if  L_STAT = true
             then L_CUST_COST_CENTER         := I_CUST_COST_CENTER;
                  L_CUST_SAP_NUMBER_DEBITOR  := I_CUST_SAP_NUMBER_DEBITOR;
             else L_CUST_COST_CENTER         := null;
                  L_CUST_SAP_NUMBER_DEBITOR  := 'migration';
             end  if;

             select XMLELEMENT ( EVALNAME I_XMLELEMENT_EVALNAME
                         , xmlattributes ( I_campaignCode            as "campaignCode"
                                         , I_PRICE_CALC_PART_AMOUNT  as "discountTotalAmount" )
                         , XMLELEMENT ( "plannedSalesCampaignDistribution"
                                 , xmlattributes ( I_PRICE_CALC_PART_AMOUNT                    as "amount"
                                                 , substr ( L_CUST_COST_CENTER,        1, 10 ) as "costCenter"
                                                 , substr ( L_CUST_SAP_NUMBER_DEBITOR, 1, 10 ) as "financialSystemDebitorNumber" )))
               into L_RETURNVALUE
               from dual;
        end  if;

        return L_RETURNVALUE;

    end get_PriceCalcPart_Campaign;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function lastIndexDate
           ( I_ID_VERTRAG     varchar2
           , I_ID_FZGVERTRAG  varchar2
           ) return           varchar2 is
           
           L_ANZAHL_PREISE    integer;
           L_lastIndexDate    varchar2 ( 8 char );
    begin
        -- FraBe 18.08.2014 MKS-132151:1 creation
        select count(*),         to_char ( max ( EXT_CREATION_DATE ), 'YYYYMMDD' )
          into L_ANZAHL_PREISE,  L_lastIndexDate
          from simex.TFZGPREIS_SIMEX
         where ID_VERTRAG         = I_ID_VERTRAG
           and ID_FZGVERTRAG      = I_ID_FZGVERTRAG
           and EXT_CREATION_DATE is not null            -- nur echte preise, keine simulierten
           and INDV_TYPE         in ( 1, 2 );           -- nur fix ( -> value 1 ) und flex ( -> 2 ) indexierbar
           
           
        if   L_ANZAHL_PREISE > 1                        -- der CO muß mehrere preise haben
        then return L_lastIndexDate;
        else return null;
        end  if;

    end lastIndexDate;
    
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function chk_FinEndCOstate 
           ( I_ID_COS                  number
           ) return                    varchar2 is
    begin
    -- FraBe 03.09.2014 MKS-132150:2 / 132151:2: creation due to CO might be terminated, but without real end date and mileage
         if PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                       , G_TIMESTAMP
                                       , 'ID_COS'
                                       , I_ID_COS ) in 
                            ( 'contractEarlyTerminated',           'contractTerminatedContingent', 'contractTerminatedDate'
                            , 'contractTerminatedFinallyInvoiced', 'contractTerminatedMileage' )
         then return 'true';
         else return 'false';
         end  if;
    end chk_FinEndCOstate;
    
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function get_lastCO_statChgDat
           ( I_GUID_CONTRACT           varchar2
           , I_FZGV_CREATED            date
           ) return                    date is
           
           L_lastCO_statChgDat         date;
    begin
    -- FraBe 03.09.2014 MKS-132150:2 / 132151:2: creation due to CO might be terminated, but without real end date and mileage
           select max ( EXTSTAT_CHANGE_DATE )
             into L_lastCO_statChgDat  
             from snt.TEXT_STATCODE_LASTCHANGE@SIMEX_DB_LINK
            where EXTSTAT_CHANGE_DATE > I_FZGV_CREATED 
              and GUID_CONTRACT       = I_GUID_CONTRACT;
           -------
           return L_lastCO_statChgDat;
    exception when NO_DATA_FOUND then return null;
    end get_lastCO_statChgDat;
    
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

    function get_odometerAtRealEnd 
           ( I_ID_VERTRAG              varchar2
           , I_ID_FZGVERTRAG           varchar2
           , I_ID_COS                  number
           , I_finEnd_KM               number
           , I_finEnd_DATE             date
           , I_prelEnd_KM              number
           , I_lastValidOdometer       number
           , I_lastCO_statChgDat       date
           ) return                    xmltype   is
                                   
           L_RETURNVALUE               xmltype;
           L_KM                        number;
           L_DATE                      date;
                                   
    begin
    -- FraBe 03.09.2014 MKS-132150:2 / 132151:2: creation due to CO might be terminated, but without real end date and mileage
        if   I_finEnd_KM is not null
        then  L_KM   := I_finEnd_KM;
              L_DATE := I_FinEnd_DATE;
        elsif PCK_CONTRACT.chk_FinEndCOstate ( I_ID_COS ) = 'true'
        then L_DATE := I_lastCO_statChgDat;
             if   I_lastValidOdometer is not null
             then L_KM   := I_lastValidOdometer;
             else L_KM   := I_prelEnd_KM;
             end  if;
        else L_KM   := I_finEnd_KM;
             L_DATE := I_FinEnd_DATE;
        end  if;
        ------------------------------------------------------------------------------
        if L_KM is not null then
        -- MKS 135205:1 TK; 2014-10-13;  IF L_KM is NULL anyway, then a real end mileage does not exist and is not necessary. therefore the NODE must not be delivered
        select xmlagg ( XMLELEMENT ( "odometerAtRealEnd"
                             , xmlattributes ( L_KM                                          as "mileage"
                                             , 'true'                                        as "calculationRelevant"
                                             , 'realMileageContractEnd'                      as "mileageState"
                                             , to_char ( L_DATE, 'YYYYMMDD' )                as "readingDate"
                                             , pck_calculation.contract_number_migrate
                                               (I_ID_VERTRAG, I_ID_FZGVERTRAG )              as "relatedObjectInternalId"
                                             , 'vehicleContract'                             as "sourceDefinition"
                                             , 'migration'                                   as "sourceSystem"
                                             , 'true'                                        as "valid"                   ))
                     )
          into L_RETURNVALUE
          from dual;
        else
          L_RETURNVALUE:=NULL;
        end if;
        return L_RETURNVALUE;

    end get_odometerAtRealEnd;
    
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION xmlel_PriceCalcPart
   ( i_xmlelement_evalname     varchar2
   , i_price_calc_part_amount  NUMBER
   , i_stat_flag               INTEGER
   , i_cust_cost_center        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%type
   , i_cust_sap_number_debitor TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%TYPE
   )
   RETURN xmltype IS
     v_xml xmltype;
     v_cust_cost_center        VARCHAR2(10 CHAR);
     v_cust_sap_number_debitor VARCHAR2(10 CHAR);
   BEGIN
     IF i_stat_flag > 0 THEN
       v_cust_cost_center         := substr ( i_cust_cost_center,        1, 10 );
       v_cust_sap_number_debitor  := substr ( i_cust_sap_number_debitor, 1, 10 );
     ELSE
       v_cust_cost_center         := null;
       v_cust_sap_number_debitor  := 'migration';
     END  IF;

     SELECT XMLELEMENT ( EVALNAME i_xmlelement_evalname
              , xmlattributes ( 'migration'              as "indiviudalText"
                              , 'amount'                 as "inputType"
                              , i_price_calc_part_amount as "totalAmount" )
              , XMLELEMENT ( "plannedDiscountDistribution"
                , xmlattributes ( v_cust_cost_center        as "costCenterReference"
                                , v_cust_sap_number_debitor as "financialSystemDebitorNumber" )) 
              ) INTO v_xml FROM dual;
   
     RETURN v_xml;
   END xmlel_PriceCalcPart;
   
    FUNCTION xmlel_PriceCalcPart_Campaign
   ( i_xmlelement_evalname     VARCHAR2
   , i_price_calc_part_amount  NUMBER
   , i_stat_flag               INTEGER
   , i_cust_cost_center        TCUSTOMER.CUST_COST_CENTER@SIMEX_DB_LINK%TYPE
   , i_cust_sap_number_debitor TCUSTOMER.CUST_SAP_NUMBER_DEBITOR@SIMEX_DB_LINK%TYPE
   , I_campaignCode            VARCHAR2
   )
   RETURN xmltype IS
     v_xml xmltype;
     v_CUST_COST_CENTER        VARCHAR2(10 CHAR);
     v_CUST_SAP_NUMBER_DEBITOR VARCHAR2(10 CHAR);
   BEGIN
     IF I_STAT_FLAG > 0 THEN
       v_CUST_COST_CENTER         := substr ( I_CUST_COST_CENTER,        1, 10 );
       v_CUST_SAP_NUMBER_DEBITOR  := substr ( I_CUST_SAP_NUMBER_DEBITOR, 1, 10 );
     ELSE
       v_CUST_COST_CENTER         := null;
       v_CUST_SAP_NUMBER_DEBITOR  := 'migration';
     END  IF;

     SELECT XMLELEMENT ( EVALNAME I_XMLELEMENT_EVALNAME
              , xmlattributes ( I_campaignCode            as "campaignCode"
                              , I_PRICE_CALC_PART_AMOUNT  as "discountTotalAmount" )
              , XMLELEMENT ( "plannedSalesCampaignDistribution"
                , xmlattributes ( I_PRICE_CALC_PART_AMOUNT        as "amount"
                                , v_CUST_COST_CENTER              as "costCenter"
                                , v_CUST_SAP_NUMBER_DEBITOR       as "financialSystemDebitorNumber" ))
              ) INTO v_xml FROM dual;
   
     RETURN v_xml;
   END xmlel_PriceCalcPart_Campaign;
   
    FUNCTION xmlel_VehiContract(o_FILE_RUNNING_NO VARCHAR2, p_id_vertrag VARCHAR2 DEFAULT null) RETURN xmltype IS
        l_xml xmltype;
        l_eval VARCHAR2(100):= CASE WHEN p_id_vertrag IS NULL THEN 'parameter' ELSE 'vehicleContract' END;
        l_vc_xsl                    XMLTYPE:= XMLTYPE(
          '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' ||
            '<xsl:output indent="no" method="xml" encoding="utf-8" />' ||
            '<xsl:template match="node()|@*">' ||
              '<xsl:copy>' ||
                '<xsl:apply-templates select="node()|@*"/>' ||
              '</xsl:copy>' ||
            '</xsl:template>' ||
            '<xsl:template match="//parameter">' ||
              '<invocation operation="createVehicleContract">' ||
                '<xsl:copy>' ||
                  '<xsl:apply-templates select="@*|node()" />' ||
                '</xsl:copy>' ||
              '</invocation>' ||
            '</xsl:template>' ||
          '</xsl:stylesheet>'
         );
      BEGIN

        SELECT XMLAGG 
            (XMLELEMENT(evalname l_eval
               , XMLATTRIBUTES
                 ( case when l_eval = 'parameter' THEN 'contract_pl:VehicleContractType' END   as "xsi:type"
                 , pck_calculation.contract_number_migrate( t.id_vertrag, t.id_fzgvertrag )    as "number"
                 , to_char ( t.FZGV_CREATED, 'YYYYMMDD' )                                      as "activationDate"
                 , t.FZGV_I55_VEH_SPEC_TEXT                                                    as "contractInformationExternal"
                 , t.END_FZGVC_MEMO                                                            as "contractInformationInternal"
                 -- MKS-132385:1 auch ID_FZGVERTRAG_PARENT muß bei derivedFromVehicleContract geckeckt werden!
                 , CASE t.ID_VERTRAG_PARENT || '/' || t.ID_FZGVERTRAG_PARENT
                   WHEN t.ID_VERTRAG        || '/' || t.ID_FZGVERTRAG  THEN NULL
                   WHEN                        '/'                     THEN NULL
                   ELSE
                     CASE PCK_CONTRACT.chk_SCOPE ( t.ID_VERTRAG_PARENT
                                                 , t.ID_FZGVERTRAG_PARENT
                                                 , t.end_ID_COV)
                     WHEN 'IN' THEN
                       pck_calculation.contract_number_migrate( t.ID_VERTRAG_PARENT, t.ID_FZGVERTRAG_PARENT )
                     ELSE NULL
                     END
                   END                                                                         as "derivedFromVehicleContract"
                 , decode (t.FZGV_CAUSE_OF_RETIRE, 1,'completed', NULL)                        as "earlyTerminationStatus"
                 , t.FZGV_NO_CUSTOMER                                                          as "fleetNumberExternal"
                 , t.LASTPRINTDATESERVICECARD                                                  as "lastPrintDateServiceCard"
                 , t.MILEAGEBALANCINGREMINDERDATE                                              as "mileageBalancingReminderDate"
                 , 'false'                                                                     as "recalculationNecessary"
                 , t.SALESCHANNEL                                                              as "salesChannel"
                 , 'false'                                                                     as "terminationInProgress"
                 , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                              , G_TIMESTAMP
                                              , 'ID_TYPGRUPPE'
                                              , t.ID_TYPGRUPPE)                                as "brand"
                 , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                              , G_TIMESTAMP
                                              , 'ID_FAHRZEUGART'
                                              , t.ID_FAHRZEUGART)                              as "division"
                 , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                              , G_TIMESTAMP
                                              , 'gssnOutletCompanyId'
                                              , t.ID_GARAGE)                                   as "ownedByOrganisation"
                 , t.ID_VERTRAG || '/' || t.ID_FZGVERTRAG                                      as "externalId"
                 , G_SourceSystem                                                              as "sourceSystem"
                 ) -- end of xml attributes of <parameter>
               , CASE G_COUNTRY_CODE
                 WHEN '51331' THEN
                   NULL
                 ELSE
                   XMLELEMENT ( "activeConditionState"
                   , XMLATTRIBUTES ( PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                , G_TIMESTAMP
                                                                , 'CUR_CODE'
                                                                , t.CUR_CODE  )   as "currency"
                                   , t.FZGPR_SUBAS                                as "totalAfterSalesSubsidy"
                                   , t.FZGPR_MLP                                  as "totalMarketListPrice"
                                   , t.FZGPR_SUBSA                                as "totalSalesSubsidy" )
                   , CASE WHEN t.FZGPR_DISCAS > 0 THEN
                       xmlel_PriceCalcPart
                       ( I_XMLELEMENT_EVALNAME      => 'plannedAfterSalesDiscount'
                       , I_PRICE_CALC_PART_AMOUNT   =>  t.FZGPR_DISCAS
                       , I_STAT_FLAG                =>  t.PR_DISCAS_EXIST
                       , I_CUST_COST_CENTER         =>  t.CUST_COST_CENTER
                       , I_CUST_SAP_NUMBER_DEBITOR  =>  t.CUST_SAP_NUMBER_DEBITOR )
                     END                                                          as "plannedAfterSalesDiscount"
                   , CASE WHEN t.FZGPR_DISCHA > 0 THEN                          
                       xmlel_PriceCalcPart
                       ( I_XMLELEMENT_EVALNAME      => 'plannedCharterWayDiscount'
                       , I_PRICE_CALC_PART_AMOUNT   =>  t.FZGPR_DISCHA
                       , I_STAT_FLAG                =>  t.PR_DISCHA_EXIST
                       , I_CUST_COST_CENTER         =>  t.CUST_COST_CENTER
                       , I_CUST_SAP_NUMBER_DEBITOR  =>  t.CUST_SAP_NUMBER_DEBITOR ) 
                     END                                                          as "plannedCharterWayDiscount"
                   , XMLELEMENT ( "plannedCommission"
                     , XMLATTRIBUTES ( t.FZGV_PROV_AMOUNT                         as "commission"
                                     , t.FZGV_PROV_MEMO                           as "commissionAdditionalInfo"
                                     , 'false'                                    as "commissionAsDealerDiscount" )
                     )
                   , CASE WHEN t.FZGPR_DISDE > 0 THEN
                       xmlel_PriceCalcPart
                       ( I_XMLELEMENT_EVALNAME      => 'plannedDealerDiscount'
                       , I_PRICE_CALC_PART_AMOUNT   =>  t.FZGPR_DISDE
                       , I_STAT_FLAG                =>  t.PR_DISDE_EXIST
                       , I_CUST_COST_CENTER         =>  t.CUST_COST_CENTER
                       , I_CUST_SAP_NUMBER_DEBITOR  =>  t.CUST_SAP_NUMBER_DEBITOR )
                     END                                                          as "plannedDealerDiscount"
                   , ( select XMLAGG 
                       ( XMLELEMENT ( "plannedSalesCampaignDiscount"
                         , xmlattributes ( PCK_CALCULATION.SUBSTITUTE
                                                  ( G_TAS_GUID
                                                  , G_TIMESTAMP
                                                  , 'CAMP_CAPTION'
                                                  , camp.CAMP_CAPTION )           as "campaignCode"
                                         , coCamp.CONCAMP_AMOUNT_SIRIUS           as "discountTotalAmount" )
                          , XMLELEMENT ( "plannedSalesCampaignDistribution"
                            , xmlattributes ( coCamp.CONCAMP_AMOUNT_SIRIUS                               as "amount"
                                            , substr ( PCK_CALCULATION.SUBSTITUTE
                                                       ( G_TAS_GUID
                                                       , G_TIMESTAMP
                                                       , 'CampaignCostCenter'
                                                       , camp.CAMP_DEPARTEMENT ),  1, 10 )               as "costCenter"
                                            , substr ( PCK_CALCULATION.SUBSTITUTE
                                                       ( G_TAS_GUID
                                                       , G_TIMESTAMP
                                                       , 'CampaignDebitorNumber'
                                                       , camp.CAMP_DEPARTEMENT ) , 1, 10 )               as "financialSystemDebitorNumber" )
                            )) ORDER BY camp.CAMP_CAPTION )
                           from snt.TCONTRACT_CAMPAIGN@SIMEX_DB_LINK coCamp
                              , snt.TCAMPAIGN@SIMEX_DB_LINK          camp
                          where cocamp.GUID_CAMPAIGN           = camp.GUID_CAMPAIGN
                            and coCamp.GUID_CONTRACT           = t.GUID_CONTRACT
                            and coCamp.CONCAMP_AMOUNT_SIRIUS  is not null 
                     )
                    , CASE WHEN t.FZGPR_SUBBU > 0 THEN
                        xmlel_PriceCalcPart_Campaign
                       ( I_XMLELEMENT_EVALNAME      => 'plannedSalesCampaignDiscount'
                       , I_PRICE_CALC_PART_AMOUNT   =>  t.FZGPR_SUBBU
                       , I_STAT_FLAG                =>  t.PR_SUBBU_EXIST
                       , I_CUST_COST_CENTER         =>  t.CUST_COST_CENTER
                       , I_CUST_SAP_NUMBER_DEBITOR  =>  t.CUST_SAP_NUMBER_DEBITOR
                       , I_campaignCode             =>  PCK_CALCULATION.SUBSTITUTE
                                                                       ( G_TAS_GUID
                                                                       , G_TIMESTAMP
                                                                       , 'CAMP_CAPTION'
                                                                       , 'iQuoteCampaign' )) 
                      END                                                                                AS "plannedSalesCampaignDiscount"
                     , CASE WHEN t.FZGPR_DISSAL > 0 THEN
                         xmlel_PriceCalcPart
                         ( I_XMLELEMENT_EVALNAME      => 'plannedSalesDiscount'
                         , I_PRICE_CALC_PART_AMOUNT   =>  t.FZGPR_DISSAL
                         , I_STAT_FLAG                =>  t.PR_DISSAL_EXIST
                         , I_CUST_COST_CENTER         =>  t.CUST_COST_CENTER
                         , I_CUST_SAP_NUMBER_DEBITOR  =>  t.CUST_SAP_NUMBER_DEBITOR ) 
                       END                                                                 as "plannedSalesDiscount" 
                   )
                end -- end of <activeConditionState>
               , XMLELEMENT ("activeCustomerContract"
                 , XMLATTRIBUTES (pck_calculation.contract_number_migrate(t.ID_VERTRAG)      as "number" ))
               , XMLELEMENT ( "activeStableState"
                 , XMLATTRIBUTES 
                   ( to_char (t.end_FZGVC_ENDE,     'YYYYMMDD' )                             as "plannedContractEnd"
                   , to_char (t.start_FZGVC_BEGINN, 'YYYYMMDD' )                             as "start"
                   , 'false'                                                                 as "collectLastPayment"
                   , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                , G_TIMESTAMP
                                                , 'CONTRACT_VARIANT_DEFINITION'
                                                , ' '         )                              as "contractVariantDefinition"
                   , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                , G_TIMESTAMP
                                                , 'ID_COS_BLOCKPAYM'
                                                , t.ID_COS )                                 as "blockPeriodicalAndMileagePayment"
                   , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                , G_TIMESTAMP
                                                , 'CUR_CODE'
                                                , t.CUR_CODE )                             as "currency"
                   , G_TargetDateCI                                                          as "customerFDDueDay"
                   , PCK_CONTRACT.customerFDIssuedUntil ( t.end_ID_SEQ_FZGVC
                                                         , t.start_FZGVC_BEGINN
                                                         , coalesce(t.KMSTAND_END_KM_DATE, t.END_FZGVC_ENDE)
                                                         , t.PAYM_MONTHS )                                                 as "customerFDIssuedUntil"
                   , to_char ( t.FZGV_SIGNATURE_DATE, 'YYYYMMDD' )                           as "customerSignatureDate"
                   ,t.driver                                                                 as "driver"
                    ----------------------------------------------------------------------------------------------------------------------
                   , case when t.FZGV_CAUSE_OF_RETIRE = 1
                       then COALESCE( t.KMSTAND_END_KM, t.last_odometer, t.END_FZGVC_ENDE_KM )
                     end                                                                     as "earlyTerminationMileage"
                   ----------------------------------------------------------------------------------------------------------------------
                   , case when t.FZGV_CAUSE_OF_RETIRE = 1
                       then to_char( nvl (t.KMSTAND_END_KM_DATE, get_lastCO_statChgDat (t.GUID_CONTRACT, t.FZGV_CREATED))
                                   , 'YYYYMMDD' )
                     end                                                                     as "earlyTerminationRealDate"
                   ----------------------------------------------------------------------------------------------------------------------
                   , case when t.kmstand_end_km is not null
                          then case when t.kmstand_end_km - t.END_FZGVC_ENDE_KM > 0
                                    then t.kmstand_end_km - t.END_FZGVC_ENDE_KM
                               end
                          else case when PCK_CONTRACT.chk_FinEndCOstate ( t.ID_COS ) = 'true'
                                    then case when t.last_odometer is not null
                                              then case when t.last_odometer - t.END_FZGVC_ENDE_KM > 0
                                                        then t.last_odometer - t.END_FZGVC_ENDE_KM
                                                   end
                                         end
                               end
                     end                                                                     as "exceededMileage"
                   ----------------------------------------------------------------------------------------------------------------------
                   , PCK_CONTRACT.nextCOindexDate ( t.COS_ACTIVE
                                                  , t.INDV_TYPE
                                                  , t.END_FZGVC_IDX_NEXTDATE )               as "indexDate"
                   , case when t.FZGV_FIXED_LABOUR_RATE > 0
                          then 'true'
                          else 'false'
                     end                                                                     as "isIndividualTariff"
                   , PCK_CONTRACT.lastIndexDate ( t.ID_VERTRAG
                                                , t.ID_FZGVERTRAG )                       as "lastIndexDate"
                   , 'false'                                                                 as "newCustomer"
                   , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                , G_TIMESTAMP
                                                , 'ID_PAYM'
                                                , t.ID_PAYM )                                as "paymentInterval"
                   , round (( (t.END_FZGVC_ENDE_KM - t.START_FZGVC_BEGINN_KM)
                            / PCK_CONTRACT.days_between ( t.START_FZGVC_BEGINN, t.END_FZGVC_ENDE ))
                            * 360, 0 )                                                       as "plannedContractAnnualMileage"
                   , PCK_CONTRACT.days_between ( t.START_FZGVC_BEGINN, t.END_FZGVC_ENDE )    as "plannedContractDuration"
                   , to_char ( t.START_FZGVC_BEGINN, 'YYYYMMDD' )                            as "plannedContractStart"
                   , t.END_FZGVC_ENDE_KM - t.START_FZGVC_BEGINN_KM                           as "plannedContractTotalMileage"
                   , t.END_FZGVC_ENDE_KM                                                     as "plannedVehicleMileageContractEnd"
                   , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                , G_TIMESTAMP
                                                , 'INDV_CAPTION'
                                                , t.INDV_CAPTION )                        as "priceModel"
                    -- , PCK_CALCULATION.calc_boolean ( fzgvc_ende.FZGVC_SERVICE_CARD, 1, 0 )  as "printServiceCard"
                    , case G_COUNTRY_CODE                                                   -- send einstweilen immer false mit Länderweiche
                           when '51331' then 'false'
                                        else 'false'
                      end                                                                   as "printServiceCard"
                    , t.product                                                             as "product"
                    , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                 , G_TIMESTAMP
                                                 , 'VI55AV_VALUE'
                                                 , t.VI55AV_VALUE )                         as "productUsage"
                    , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                 , G_TIMESTAMP
                                                 , 'ID_BRANCH_SSI'
                                                 , t.ID_BRANCH_SSI )                        as "productIndustry"
                    --   , to_char ( fzgvc_start.FZGVC_BEGINN, 'YYYYMMDD' )                      as "quotationValidEnd"  -- waveFinal: do not send anymore
                    ----------------------------------------------------------------------------------------------------------------------
                    , coalesce ( to_char ( t.kmstand_end_km_date, 'YYYYMMDD' )
                               , case when PCK_CONTRACT.chk_FinEndCOstate ( t.ID_COS ) = 'true'
                                     then to_char ( get_lastCO_statChgDat ( t.GUID_CONTRACT, t.FZGV_CREATED ), 'YYYYMMDD' )
                                     else to_char ( t.kmstand_end_km_date,                                     'YYYYMMDD' ) --???
                                 end
                      )                                                                  as "realContractEnd"
                    ----------------------------------------------------------------------------------------------------------------------
                    , coalesce ( t.kmstand_end_km - t.kmstand_begin_km          
                               , case when PCK_CONTRACT.chk_FinEndCOstate ( t.ID_COS ) = 'true'
                                      then coalesce(t.last_odometer, t.END_FZGVC_ENDE_KM) - t.START_FZGVC_BEGINN_KM
                                 end
                      )                                                                  as "realContractTotalMileage"
                    ----------------------------------------------------------------------------------------------------------------------
                    , 'migration'                                                           as "contractSourceSystem"
                    , PCK_CALCULATION.calc_boolean ( t.END_FZGVC_SPECIAL_CASE, 1, 0 )       as "specialCase"
                    , PCK_CONTRACT.ChildCOtransferDate ( t.ID_VERTRAG
                                                       , t.ID_FZGVERTRAG )                  as "transferDate"
                    ----------------------------------------------------------------------------------------------------------------------
                    , case when t.kmstand_end_km is not null
                           then case when t.END_FZGVC_ENDE_KM - t.kmstand_end_km > 0
                                     then t.END_FZGVC_ENDE_KM - t.kmstand_end_km
                                end
                           else case when PCK_CONTRACT.chk_FinEndCOstate ( t.ID_COS ) = 'true'
                                     then case when t.last_odometer is not null
                                               then case when t.END_FZGVC_ENDE_KM - t.last_odometer > 0
                                                         then t.END_FZGVC_ENDE_KM - t.last_odometer
                                                    end
                                          end
                                end
                      end                                                                   as "unusedMileage"
                    ----------------------------------------------------------------------------------------------------------------------
                    , PCK_CONTRACT.CO_revenue_amount ( t.ID_VERTRAG
                                                    , t.ID_FZGVERTRAG
                                                    , t.START_FZGVC_BEGINN
                                                    , coalesce(t.KMSTAND_END_KM_DATE, t.END_FZGVC_ENDE)
                                                    , t.PAYM_TARGETDATE_CI )                                                   as "value"
                    , CASE WHEN nvl ( t.FZGV_ERSTZULASSUNG, t.START_FZGVC_BEGINN ) = t.START_FZGVC_BEGINN
                           THEN 0 
                           ELSE PCK_CONTRACT.days_between ( nvl ( t.FZGV_ERSTZULASSUNG, t.START_FZGVC_BEGINN )
                                                            , t.START_FZGVC_BEGINN 
                                                            )
                                                            - 1
                      END                                                                                                      as "vehicleAgeContractStart"  )
                 , decode (PCK_CONTRACT.chk_overlapping_prices ( t.ID_VERTRAG
                                                               , t.ID_FZGVERTRAG )
                          , 1, XMLCOMMENT ( 'ORA-20700 There are overlapping prices within attribute <value> above' ))
                 , XMLELEMENT ( "automotiveObject"
                   , XMLATTRIBUTES ( t.id_manufacture || t.FZGV_FGSTNR                         as "vin" ))
                 , PCK_CONTRACT.get_default_coverage ( I_FZGVC_BEGINN            => t.START_FZGVC_BEGINN
                                                     , I_FZGVC_BEGINN_KM         => t.START_FZGVC_BEGINN_KM
                                                     , I_FZGVC_ENDE              => t.END_FZGVC_ENDE
                                                     , I_FZGVC_ENDE_KM           => t.END_FZGVC_ENDE_KM
                                                     , I_finEnd_FZGKM_DATUM      => t.kmstand_end_km_date
                                                     , I_finEnd_FZGKM_KM         => t.kmstand_end_km )              as "coverage"
                 , PCK_CONTRACT.get_ProductCOVERAGE  ( I_GUID_BUSINESS_AREA_L2   => t.GUID_BUSINESS_AREA_L2
                                                     , I_FZGVC_BEGINN            => t.START_FZGVC_BEGINN
                                                     , I_FZGVC_BEGINN_KM         => t.START_FZGVC_BEGINN_KM
                                                     , I_FZGVC_ENDE              => t.END_FZGVC_ENDE
                                                     , I_FZGVC_ENDE_KM           => t.END_FZGVC_ENDE_KM
                                                     , I_finEnd_FZGKM_DATUM      => t.kmstand_end_km_date
                                                     , I_finEnd_FZGKM_KM         => t.kmstand_end_km
                                                     , I_product                 => t.product )                     as "coverage"
                 , PCK_CONTRACT.get_ProductOPTION    ( I_GUID_CONTRACT           => t.GUID_CONTRACT
                                                     , I_GUID_BUSINESS_AREA_L2   => t.GUID_BUSINESS_AREA_L2
                                                     , I_FZGVC_BEGINN            => t.START_FZGVC_BEGINN
                                                     , I_FZGVC_BEGINN_KM         => t.START_FZGVC_BEGINN_KM
                                                     , I_FZGVC_ENDE              => t.END_FZGVC_ENDE
                                                     , I_FZGVC_ENDE_KM           => t.END_FZGVC_ENDE_KM
                                                     , I_finEnd_FZGKM_DATUM      => t.kmstand_end_km_date
                                                     , I_finEnd_FZGKM_KM         => t.kmstand_end_km
                                                     , I_product                 => t.product )                     as "coverage"
                 , PCK_CONTRACT.get_SPP_product_COVERAGE ( I_GUID_CONTRACT           => t.GUID_CONTRACT
                                                         , I_ID_VERTRAG              => t.ID_VERTRAG
                                                         , I_ID_FZGVERTRAG           => t.ID_FZGVERTRAG
                                                         , I_GUID_BUSINESS_AREA_L2   => t.GUID_BUSINESS_AREA_L2
                                                         , I_FZGVC_BEGINN            => t.START_FZGVC_BEGINN
                                                         , I_FZGVC_BEGINN_KM         => t.START_FZGVC_BEGINN_KM
                                                         , I_FZGVC_ENDE              => t.END_FZGVC_ENDE
                                                         , I_FZGVC_ENDE_KM           => t.END_FZGVC_ENDE_KM
                                                         , I_finEnd_FZGKM_DATUM      => t.kmstand_end_km_date
                                                         , I_finEnd_FZGKM_KM         => t.kmstand_end_km
                                                         , I_product                 => t.product
                                                         , I_einsArt_GUID_VI55AV     => t.GUID_VI55AV )             as "coverage"

                 , XMLELEMENT ( "dealerAssignment"
                   , XMLATTRIBUTES ( t.GAR_GARNOVEGA                                                                    as "contractingWorkshopClaimingSystemId"
                                   , decode (G_COUNTRY_CODE, '51331', null, t.GARSERV_GARNOVEGA)                            as "servicingWorkshopClaimingSystemId" 
                                   )
                   , XMLELEMENT ( "contractingWorkshop"
                   -- TK 2014-04-23 MKS-132480 Contracting Workshiop must have a leading 'D'
                     , XMLATTRIBUTES ( 'D' || t.ID_GARAGE                                                                 as "externalId"
                                     , G_SourceSystem                                                                     as "sourceSystem" ))
                   -- TK; 29.09.2014; MKS-134997:1
                   -- from now on each contract must have a salesmen (if not existing, then use default) 
                   , XMLELEMENT ( "salesPerson"
                     , XMLATTRIBUTES ( PCK_CALCULATION.get_part_of_bearbeiter_kauf
                                       ( t.FZGV_BEARBEITER_KAUF, 3, t.ID_VERTRAG || '/' || t.ID_FZGVERTRAG )              as "externalId"
                                     , G_SourceSystem                                                                     as "sourceSystem" ))
                               -- Tk 2014-04-28; MKS-132480 ServicingWorkshop not needed in MBBEL
                 , case G_COUNTRY_CODE
                       when '51331' then null
                   else XMLELEMENT ( "servicingWorkshop"
                                                           , xmlattributes ( 'W' || t.ID_GARAGE_SERV  as "externalId"
                                                                           , G_SourceSystem              as "sourceSystem" ))   
                   end)
                   
                 , XMLELEMENT ( "individualVehicleContractSetting"
                   , XMLATTRIBUTES ( -- MBBEL Länderweiche / für andere MPC ist noch nix definiert
                                     decode( G_COUNTRY_CODE
                                           , '51331', t.bankAccount)                                                     as "bankAccount"
                                   , PCK_CALCULATION.SUBSTITUTE
                                              ( G_TAS_GUID
                                              , G_TIMESTAMP
                                              , 'CollectiveInvoiceLevel'
                                              , t.END_INV_CONSOLID || t.CUST_INVOICE_CONS_METHOD )                       as "collectiveInvoicing"
                                   , PCK_CALCULATION.SUBSTITUTE
                                              ( G_TAS_GUID
                                              , G_TIMESTAMP
                                              , 'GroupedCollectiveInvocing'
                                              , ' ' )                                                                    as "groupedCollectiveInvoicing"
                                   , PCK_CALCULATION.calc_boolean (t.FZGV_MANUAL_OVERRULE_I55, 1, 0)                     as "manualVegaReview" 
                                   )
                   , case when t.ID_CUSTOMER = t.CUST_INV_ADRESS_BALFIN then null
                     else XMLELEMENT ( "alternativeBalancingReceiver"
                          , XMLATTRIBUTES ( CASE WHEN PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INV_ADRESS_BALFIN ) is null
                                            -- TK ; 2014-11-03; MKS-135482:1 - Correct XSI Type (not gathering from contracting customer, but from alternative balancing customer)    
                                            then PCK_PARTNER.GET_CUST_XSI_PARTNER_TYPE (t.CUST_INVOICE_ADRESS)
                                            else 'partner_pl:OrganisationalPersonType'
                                            end                                                                  as "xsi:type"
                                          , case when PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INV_ADRESS_BALFIN ) is null
                                            then t.CUST_INV_ADRESS_BALFIN
                                            else 'D' || PCK_CALCULATION.SUBSTITUTE
                                                                                 ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INV_ADRESS_BALFIN )
                                            end                                                                  as "externalId"
                                          , G_SourceSystem                                                       as "sourceSystem" 
                                          ))
                     end
                   , case when t.ID_CUSTOMER = t.CUST_INVOICE_ADRESS then null
                     else XMLELEMENT ( "alternativeFDReceiver"
                          , XMLATTRIBUTES ( case when PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INVOICE_ADRESS ) is null
                                                 -- TK ; 2014-11-03; MKS-135482:1 - Correct XSI Type (not gathering from contracting customer, but from alternative balancing customer)    
                                                 then PCK_PARTNER.GET_CUST_XSI_PARTNER_TYPE (t.CUST_INVOICE_ADRESS)
                                                 else 'partner_pl:OrganisationalPersonType'
                                            end                                                                  as "xsi:type"
                                          , case when PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INVOICE_ADRESS ) is null
                                                 then t.CUST_INV_ADRESS_BALFIN
                                                 else 'D' || PCK_CALCULATION.SUBSTITUTE
                                                                                 ( G_TAS_GUID
                                                                                 , G_TIMESTAMP
                                                                                 , 'WorkshopAsCustomer'
                                                                                 , t.CUST_INVOICE_ADRESS )
                                            end                                                                  as "externalId"
                                          , G_SourceSystem                                                       as "sourceSystem" 
                                          )
                          )
                     end   
                   , case when t.FZGV_HANDLE_NOMINATED_DEALER < 2
                           AND g_country_code <> '51331'
                     then XMLELEMENT ( "fixedLabour"
                          , XMLATTRIBUTES ( t.FZGV_FIXED_LABOUR_RATE                                              as "amount"
                                          , PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                                       , G_TIMESTAMP
                                                                       , 'cur_code'
                                                                       , t.cur_code )                             as "amountCurrency"
                                          , to_char ( t.start_fzgvc_beginn, 'yyyymmdd' )                          as "validFrom"
                                          , to_char ( t.end_fzgvc_ende,     'yyyymmdd' )                          as "validTo"   
                                          )
                          , case when t.fzgv_handle_nominated_dealer = 1
                                 then XMLELEMENT ( "fixedLabourDealer"
                                      , XMLATTRIBUTES ( 'W' || t.id_garage_serv       as "externalId"
                                                      , g_sourcesystem                as "sourceSystem" 
                                                      )
                                                 )
                            end
                          )
                     else null
                     end
                   ) 
                 , PCK_CONTRACT.get_odometerAtRealEnd ( I_ID_VERTRAG        => t.ID_VERTRAG
                                                      , I_ID_FZGVERTRAG     => t.ID_FZGVERTRAG
                                                      , I_ID_COS            => t.ID_COS
                                                      , I_finEnd_KM         => t.kmstand_end_km
                                                      , I_FinEnd_DATE       => t.kmstand_end_km_date
                                                      , I_prelEnd_KM        => t.END_FZGVC_ENDE_KM
                                                      , I_lastValidOdometer => t.last_odometer 
                                                      , I_lastCO_statChgDat => get_lastCO_statChgDat ( t.GUID_CONTRACT, t.FZGV_CREATED )
                                                      )                                                              as "odometerAtRealEnd"
                 , XMLELEMENT ( "odometerAtRealStart"
                   , XMLATTRIBUTES ( t.start_km                                                                          as "mileage"
                                   , 'true'                                                                              as "calculationRelevant"
                                   , 'mileageContractStart'                                                              as "mileageState"
                                   , to_char (t.start_km_date     , 'YYYYMMDD')                                          as "readingDate"
                                   , pck_calculation.contract_number_migrate ( t.ID_VERTRAG,t.ID_FZGVERTRAG)             as "relatedObjectInternalId"
                                   , 'vehicleContract'                                                                   as "sourceDefinition"
                                   , 'migration'                                                                         as "sourceSystem"
                                   , 'true'                                                                              as "valid"                   
                                   )
                   )
                 , ( SELECT XMLAGG 
                            ( XMLELEMENT ( "technicalOption"
                              , XMLATTRIBUTES ( PCK_CONTRACT.get_Product_House (I_PH_TYPE      => 'TECHNICALOPTION'
                                                                              , I_PH_PARAM_IN1 => ph.PH_PARAM_IN1
                                                                              , I_PH_PARAM_IN2 => ph.PH_PARAM_IN2
                                                                              , I_PH_PARAM_IN3 => ph.PH_PARAM_IN2
                                                                              , I_RETURN_WHAT  => 'PH_PARAM_OUT1' )      as "technicalOption" 
                                              )
                              ) ORDER BY ph.PH_PARAM_OUT2
                            )
                       FROM simex.TPRODUCT_HOUSE                     ph
                          , snt.TIC_PACKAGE@SIMEX_DB_LINK            icp
                          , snt.TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK    vval
                          , snt.TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK    vatt
                          , snt.TIC_CO_PACK_ASS@SIMEX_DB_LINK        copa
                      WHERE copa.GUID_CONTRACT       = t.GUID_CONTRACT
                        AND copa.GUID_VI55A          = vatt.GUID_VI55A
                        AND copa.GUID_PACKAGE        = icp.GUID_PACKAGE
                        AND vval.GUID_VI55AV         = icp.GUID_VI55AV
                        AND vval.GUID_VI55A          = vatt.GUID_VI55A
                        AND ph.PH_PARAM_IN1          = vatt.VI55A_DISPLACEMENT
                        AND ph.PH_PARAM_IN2          = icp.ICP_CAPTION
                        AND ph.PH_PARAM_IN3          = vval.VI55AV_VALUE
                        AND ph.PH_TYPE               = 'TECHNICALOPTION' 
                   )
                 , ( SELECT XMLAGG 
                            ( XMLELEMENT ( "vehicleContractProperty"
                              , XMLATTRIBUTES ( case when vval.VI55AV_CAPTION  = 'Nein'
                                                       or vval.VI55AV_CAPTION <> 'Biodiesel' and vval.VI55AV_IS_DEFAULT_VALUE = 1
                                                then 'false'
                                                else 'true'
                                                END                                                                      as "active"
                                              , PCK_CALCULATION.SUBSTITUTE( G_TAS_GUID
                                                                          , G_TIMESTAMP
                                                                          , 'VI55A_DISPLACEMENT'
                                                                          , vatt.VI55A_DISPLACEMENT )                    as "contractProperty"
                                              )
                              ) ORDER BY vatt.VI55A_DISPLACEMENT 
                            )
                       FROM snt.TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK    vval
                          , snt.TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK    vatt
                          , snt.TVEGA_I55_CO@SIMEX_DB_LINK           vco
                      WHERE vco.GUID_CONTRACT        = t.GUID_CONTRACT
                        AND vatt.GUID_VI55A          = vco.GUID_VI55A
                        AND vatt.VI55A_DISPLACEMENT in ( 116, 117, 118, 119, 120, 125 )
                        AND vatt.GUID_VI55A          = vval.GUID_VI55A
                        AND vco.GUID_VI55AV          = vval.GUID_VI55AV 
                   )
                 , ( SELECT XMLAGG
                            ( XMLELEMENT ( "vehicleContractRealPrice"
                              , XMLATTRIBUTES (decode ( G_COUNTRY_CODE
                                                      , '51331', null                         -- MBBEL
                                                      , '67530', fzgpr.FZGPR_BEGIN_MILEAGE    -- MBSA
                                                      , null)                                                            as "mileageFrom"
                                                      , decode ( G_COUNTRY_CODE
                                                      , '51331', null                         -- MBBEL
                                                      , '67530', fzgpr.FZGPR_END_MILEAGE      -- MBSA
                                                      , null)                                                            as "mileageTo"
                                                      , to_char ( fzgpr.FZGPR_VON, 'YYYYMMDD' )                          as "periodFrom"
                                                      , to_char ( fzgpr.FZGPR_BIS, 'YYYYMMDD' )                          as "periodUntil"
                                                      , ( fzgpr.FZGPR_PREIS_GRKM / 100 )                                 as "realPriceCentPerMile"
                                                      , fzgpr.FZGPR_PREIS_MONATP                                         as "realPriceMonthly"
                                                      , fzgpr.FZGPR_ADD_MILEAGE                                          as "exceededAmountPerMileage"
                                                      , fzgpr.FZGPR_LESS_MILEAGE                                         as "unusedAmountPerMileage"
                                )
                              ) ORDER BY fzgpr.FZGPR_VON 
                            )
                      FROM simex.TFZGPREIS_SIMEX fzgpr
                     WHERE fzgpr.ID_VERTRAG        = t.ID_VERTRAG
                       AND fzgpr.ID_FZGVERTRAG     = t.ID_FZGVERTRAG 
                   )
                 ) -- end of <activeStableState>
               , XMLELEMENT ("activeVolatileState"
                 , XMLATTRIBUTES
                   ( PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID, G_TIMESTAMP, 'ID_COS', t.ID_COS ) as "contractState" )
                 , decode (PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID
                                                      , G_TIMESTAMP
                                                      , 'ID_COS_ADDON'
                                                      , t.ID_COS)
                          , null, null
                          , XMLELEMENT ("reason"
                            , XMLATTRIBUTES
                              ( t.COS_CAPTION                                                       as "manualReason"
                              , PCK_CALCULATION.SUBSTITUTE( G_TAS_GUID
                                                          , G_TIMESTAMP
                                                          , 'ID_COS_ADDON'
                                                          , t.ID_COS )                             as "reasonType" )
                            ))
                 ) -- end of <activeVolatileState>
               )      
              ORDER BY t.lvl, t.id_vertrag, t.id_fzgvertrag      
             )
         INTO l_xml
         FROM TTEMP_TFZGVERTRAG t
        WHERE t.id_vertrag = p_id_vertrag OR p_id_vertrag IS NULL
        ORDER BY t.lvl, t.id_vertrag, t.id_fzgvertrag;
         
         /* 1st approach: in favour of ServiceContract full: additional XML transformation takes place for Vehicle Contracts:
            When generating exporting as Vehicle Contracts, each of them  should be wrapped in parent <invocation> node
         */
         IF p_id_vertrag IS NULL THEN
           SELECT
         XMLELEMENT ( "common:ServiceInvocationCollection"
          , XMLATTRIBUTES ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                          , 'http://contract.icon.daimler.com/pl'        as "xmlns:contract_pl"
                          , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                          , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                          , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                          , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" 
                          )
          , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_ServiceContract_Mig_BEL_WavePreInt4_v1.0.xlsx' )
          , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
          , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
          , XMLELEMENT ( "executionSettings"
            , XMLATTRIBUTES( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                           , g_expdatetime                   as "dateTime"
                           , G_userID                        as "userId"
                           , pck_calculation.G_TENANT_ID     as "tenantId"
                           , G_causation                     as "causation"
                           , o_FILE_RUNNING_NO               as "additionalInformation1"
                           , G_correlationID                 as "correlationId"
                           , G_IssueThreshold                as "issueThreshold"
                           )
          )
          , l_xml
          )
            INTO l_xml
            FROM dual;
            
            SELECT xmltransform(l_xml, l_vc_xsl )
              INTO l_xml
              FROM dual;
            
         END IF;
         RETURN l_xml;    
      END xmlel_VehiContract;
   
   FUNCTION prv_exp_contract
          ( i_TAS_GUID                  TTASK.TAS_GUID%TYPE
          , i_export_path               VARCHAR2
          , i_filename                  VARCHAR2
          , i_TAS_MAX_NODES             INTEGER
          , o_FILE_RUNNING_NO       OUT INTEGER
          , i_export_type               SMALLINT
          ) RETURN NUMBER
   IS
     TYPE typtab_CustContract IS TABLE OF TTEMP_TVERTRAGSTAMM%ROWTYPE INDEX BY PLS_INTEGER;
     TYPE typtab_VehiContract IS TABLE OF TTEMP_TFZGVERTRAG%ROWTYPE INDEX BY PLS_INTEGER;
     v_CustContract_tab          typtab_CustContract;
     v_VehiContract_tab          typtab_VehiContract;
     l_ret                       INTEGER DEFAULT 0;
   /* Main cursir for retrieving Customer Contracts. Takes into account Parent-Child Relationship of corresponding Vehicle Contracts.
    * Loops are not handled, e.g. 0022222/0001 >>> 0011111/0001 >>> 0022222/0002 will cause error.
    */
   CURSOR cust_contract_cur IS
   WITH vc AS
   ( SELECT /*+ DRIVING_SITE(fv) */
       fv.ID_VERTRAG
     , fv.ID_VERTRAG_PARENT
     , row_number()                     OVER (PARTITION BY fc.ID_VERTRAG,fc.ID_FZGVERTRAG ORDER BY fc.ID_FZGVERTRAG) id_fzgvertrag_rn
     , last_value (fc.ID_CUSTOMER)      OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                  ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC
                                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_CUSTOMER
     , last_value (cov.COV_CAPTION)     OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                  ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC
                                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_caption
       FROM SNT.tfzgvertrag@SIMEX_DB_LINK       fv
       JOIN snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fc  ON fv.ID_VERTRAG = fc.ID_VERTRAG AND fv.id_fzgvertrag = fc.id_fzgvertrag
       JOIN snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov ON cov.ID_COV    = fc.ID_COV   --  AND cov.COV_CAPTION not like 'MIG_OOS%'
   )
   , fv AS (SELECT vc.ID_VERTRAG
                 , vc.ID_VERTRAG_PARENT
                 , vc.end_ID_CUSTOMER
                 , row_number()            OVER (PARTITION BY vc.ID_VERTRAG ORDER BY NULL)  id_vertrag_rn  
                 , COUNT(1)                OVER (PARTITION BY vc.ID_VERTRAG)                count_fzvg_inscope
              FROM vc
             WHERE vc.id_fzgvertrag_rn = 1 AND end_caption not like 'MIG_OOS%'
           )
   , h AS (SELECT LEVEL lvl,v,vp
             FROM (SELECT DISTINCT vc.id_vertrag v, vc.id_vertrag_parent vp 
                     FROM vc 
                    WHERE vc.id_fzgvertrag_rn = 1
                      AND (vc.id_vertrag_parent IS NULL OR vc.id_vertrag_parent <> vc.id_vertrag)
                  ) 
                    START WITH vp IS NULL
                  CONNECT BY PRIOR v = vp
          )
   SELECT max_h.lvl
        , id_vertrag
        , end_ID_CUSTOMER
        , count_fzvg_inscope
     FROM fv
     JOIN (SELECT v,max(lvl) lvl FROM h GROUP BY v) max_h ON fv.id_vertrag = max_h.v
    WHERE fv.id_vertrag_rn = 1
    ORDER BY max_h.lvl, fv.id_vertrag;
   
    /* Sortierung nach dem älteren der beiden Einträge je Fahrzeugvertrag:
    TFZGV_CONTRACTS.FZGVC_BEGINN of  "First Duration! MIN(ID_SEQ_FZGVC)",
    TFZGV_CONTRACTS.FZGVC_CREATED of "First Duration! MIN(ID_SEQ_FZGVC)"
    MariF: Note for Parent-Child sorting: now correct unlimited-depth sorting occurs only for standalone VehicleContract export.
    If Vehicle contracts are exported within ServiceContractFull Export, then unlimited-depth sorting will take place only if the whole Contract tree 
    is within one parent bulk set (cust_contract_cur bulk set). If the Vehicle Contract tree is spread across several bulks, then we rely on the fact 
    that child contracts always have ascending id_vertrag number e.g. 0011111/0001 is papa of 0022222/0001. 
    If vice versa (0022222/0001 is papa of 0011111/0001)
    than child Contract will be loaded first and will potentially cause defect DEF5965.
   */
   CURSOR vehi_contract_cur(a_export_type INTEGER) IS
     WITH
       fzvertr_details AS
    (SELECT /*+ DRIVING_SITE(@fv fc) */
       fv.*
     , row_number() OVER (PARTITION BY fc.ID_VERTRAG,fc.ID_FZGVERTRAG ORDER BY fc.ID_FZGVERTRAG) rn
     , min ( fc.FZGVC_BEGINN)                         OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG)                                                 start_FZGVC_BEGINN
     , first_value (fc.FZGVC_BEGINN_KM)               OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS UNBOUNDED PRECEDING)                                 start_FZGVC_BEGINN_KM
     , first_value (fc.ID_SEQ_FZGKMSTAND_BEGIN)       OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS UNBOUNDED PRECEDING)                                 start_ID_KMSTAND_BEGIN
     , first_value (fc.FZGVC_CREATED )                OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS UNBOUNDED PRECEDING)                                 start_FZGVC_CREATED                                                
     , max ( fc.FZGVC_BEGINN )                        OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG)                                                 end_FZGVC_BEGINN
     , last_value (fc.FZGVC_INVOICE_CONSOLIDATION)    OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_INV_CONSOLID
     , last_value (fc.ID_EINSATZART)                  OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_EINSATZART
     , last_value (fc.GUID_BRANCH)                    OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_GUID_BRANCH
     , last_value (fc.ID_SEQ_FZGVC)                   OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_SEQ_FZGVC
     , last_value (fc.ID_PAYM)                        OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_PAYM
     , last_value (fc.GUID_PAYMENT_MODE)              OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_GUID_PAYMENT_MODE
     , last_value (fc.GUID_INDV)                      OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_GUID_INDV
     , last_value (fc.FZGVC_MEMO)                     OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_FZGVC_MEMO
     , last_value (fc.ID_SEQ_FZGKMSTAND_BEGIN)        OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_KMSTAND_BEGIN
     , last_value (fc.ID_SEQ_FZGKMSTAND_END)          OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_KMSTAND_END
     , last_value (fc.FZGVC_RUNPOWER_BALANCING)       OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_RUNPOWER_BAL
     , last_value (fc.ID_COV)                         OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_COV
     , last_value (fc.FZGVC_ENDE)                     OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_FZGVC_ENDE
     , last_value (fc.FZGVC_ENDE_KM)                  OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_FZGVC_ENDE_KM
     , last_value (fc.FZGVC_IDX_NEXTDATE)             OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_FZGVC_IDX_NEXTDATE
     , last_value (fc.FZGVC_SPECIAL_CASE)             OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_FZGVC_SPECIAL_CASE
     , last_value (fc.ID_CUSTOMER)                    OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_ID_CUSTOMER   
     , last_value (fc.GUID_CUSTOMER_DOM)              OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_GUID_CUSTOMER_DOM
     , last_value (cov.COV_SCARF_CONTRACT)            OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                      ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_COV_SCARF_CONTRACT                                                      
         from (SELECT /*+ DRIVING_SITE(f) */LEVEL lvl, f.id_vertrag, f.id_fzgvertrag, f.id_vertrag_parent, f.id_fzgvertrag_parent, f.fzgv_created
                    , f.GUID_CONTRACT
                    , f.FZGV_CAUSE_OF_RETIRE
                    , substr (f.FZGV_I55_VEH_SPEC_TEXT, 1, 2500)       FZGV_I55_VEH_SPEC_TEXT
                    , substr (f.FZGV_NO_CUSTOMER, 1, 20)               FZGV_NO_CUSTOMER
                    , nvl ( f.FZGV_BEARBEITER_TECH, 'afterSales' )     salesChannel
                    , substr ( f.FZGV_FINAL_CUSTOMER, 1, 100 )         driver     
                    , f.ID_GARAGE, f.ID_GARAGE_SERV
                    , f.ID_FZGTYP
                    , f.ID_COS
                    , f.FZGV_SIGNATURE_DATE
                    , f.FZGV_FIXED_LABOUR_RATE
                    , f.FZGV_ERSTZULASSUNG
                    , f.FZGV_BEARBEITER_KAUF
                    , f.FZGV_MANUAL_OVERRULE_I55
                    , f.FZGV_HANDLE_NOMINATED_DEALER
                    , f.GUID_SSIM
                    , f.FZGV_PROV_AMOUNT
                    , substr ( f.FZGV_PROV_MEMO, 1, 50 )               FZGV_PROV_MEMO
                    , f.ID_MANUFACTURE
                    , f.FZGV_FGSTNR
                    , f.FZGV_MEMO
                 FROM SNT.tfzgvertrag@SIMEX_DB_LINK f
                WHERE a_export_type = c_exptype_VehiContract
                START WITH f.id_vertrag_parent IS NULL AND f.id_fzgvertrag_parent IS NULL
              CONNECT BY PRIOR f.id_vertrag    = f.id_vertrag_parent
                     AND PRIOR f.id_fzgvertrag = f.id_fzgvertrag_parent
                UNION ALL
                SELECT q1.* FROM (
               SELECT /*+ DRIVING_SITE(f) */LEVEL lvl, f.id_vertrag, f.id_fzgvertrag, f.id_vertrag_parent, f.id_fzgvertrag_parent, f.fzgv_created
                    , f.GUID_CONTRACT
                    , f.FZGV_CAUSE_OF_RETIRE
                    , substr (f.FZGV_I55_VEH_SPEC_TEXT, 1, 2500)       FZGV_I55_VEH_SPEC_TEXT
                    , substr (f.FZGV_NO_CUSTOMER, 1, 20)               FZGV_NO_CUSTOMER
                    , nvl ( f.FZGV_BEARBEITER_TECH, 'afterSales' )     salesChannel
                    , substr ( f.FZGV_FINAL_CUSTOMER, 1, 100 )         driver     
                    , f.ID_GARAGE, f.ID_GARAGE_SERV
                    , f.ID_FZGTYP
                    , f.ID_COS
                    , f.FZGV_SIGNATURE_DATE
                    , f.FZGV_FIXED_LABOUR_RATE
                    , f.FZGV_ERSTZULASSUNG
                    , f.FZGV_BEARBEITER_KAUF
                    , f.FZGV_MANUAL_OVERRULE_I55
                    , f.FZGV_HANDLE_NOMINATED_DEALER
                    , f.GUID_SSIM
                    , f.FZGV_PROV_AMOUNT
                    , substr ( f.FZGV_PROV_MEMO, 1, 50 )               FZGV_PROV_MEMO
                    , f.ID_MANUFACTURE
                    , f.FZGV_FGSTNR
                    , f.FZGV_MEMO
                 FROM SNT.tfzgvertrag@SIMEX_DB_LINK f
                WHERE a_export_type = c_exptype_ServContract
                START WITH f.id_vertrag_parent IS NULL AND f.id_fzgvertrag_parent IS NULL
              CONNECT BY PRIOR f.id_vertrag    = f.id_vertrag_parent
                     AND PRIOR f.id_fzgvertrag = f.id_fzgvertrag_parent 
              ) q1 JOIN TTEMP_TVERTRAGSTAMM lim
                   ON q1.id_vertrag = lim.id_vertrag
              ) fv
         JOIN snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fc  ON fv.ID_VERTRAG = fc.ID_VERTRAG AND fv.id_fzgvertrag = fc.id_fzgvertrag
         JOIN snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov ON cov.ID_COV    = fc.ID_COV     AND cov.COV_CAPTION not like 'MIG_OOS%'
  )
  , fzvg_main AS (SELECT * FROM fzvertr_details WHERE rn=1)
  , kmAll AS 
     (SELECT fzgv.*
           , row_number() OVER (PARTITION BY k.id_seq_fzgvc ORDER BY NULL) km_rn
           , MAX(CASE WHEN fzgv.end_ID_KMSTAND_BEGIN = k.id_seq_fzgkmstand
                          THEN k.fzgkm_km ELSE NULL 
                 END) OVER (PARTITION BY k.id_seq_fzgvc)                                 kmstand_begin_km
           , MAX(CASE WHEN fzgv.end_ID_KMSTAND_BEGIN = k.id_seq_fzgkmstand
                          THEN k.fzgkm_datum ELSE NULL 
                 END) OVER (PARTITION BY k.id_seq_fzgvc)                                 kmstand_begin_km_date
           , MAX(CASE WHEN fzgv.end_ID_KMSTAND_END = k.id_seq_fzgkmstand
                          THEN k.fzgkm_km ELSE NULL 
                 END) OVER (PARTITION BY k.id_seq_fzgvc)                                 kmstand_end_km
           , MAX(CASE WHEN fzgv.end_ID_KMSTAND_END = k.id_seq_fzgkmstand
                          THEN k.fzgkm_datum ELSE NULL 
                 END) OVER (PARTITION BY k.id_seq_fzgvc)                                 kmstand_end_km_date
           , last_value(DECODE( k.id_seq_fzgkmstand, fzgv.end_ID_KMSTAND_BEGIN, NULL
                              , fzgv.end_ID_KMSTAND_END, NULL
                              , k.fzgkm_km)
                       ) IGNORE NULLS OVER 
                       (PARTITION BY k.id_seq_fzgvc ORDER BY k.fzgkm_datum
                        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)        last_odometer
            FROM snt.TFZGKMSTAND@SIMEX_DB_LINK k
            JOIN fzvg_main fzgv ON k.id_seq_fzgvc = fzgv.end_ID_SEQ_FZGVC
     )
  , fzgv_km AS (SELECT * FROM kmAll WHERE km_rn=1)
  , fzgv_pr_all AS 
    (SELECT fzgv_km.*
        , p.ID_SEQ_FZGVC            preis_ID_SEQ_FZGVC
        , p.FZGPR_SUBAS             FZGPR_SUBAS
        , p.FZGPR_MLP               FZGPR_MLP
        , p.FZGPR_SUBSA             FZGPR_SUBSA
        , nvl ( p.FZGPR_SUBBU,  0 ) FZGPR_SUBBU
        , nvl ( p.FZGPR_DISCAS, 0 ) FZGPR_DISCAS
        , nvl ( p.FZGPR_DISSAL, 0 ) FZGPR_DISSAL
        , nvl ( p.FZGPR_DISCHA, 0 ) FZGPR_DISCHA
        , nvl ( p.FZGPR_DISDE,  0 ) FZGPR_DISDE
        , min ( p.FZGPR_VON ) OVER (PARTITION BY fzgv_km.ID_VERTRAG, fzgv_km.ID_FZGVERTRAG) min_FZGPR_VON
        , p.FZGPR_VON
        from snt.TFZGPREIS@SIMEX_DB_LINK p
        RIGHT JOIN fzgv_km 
                ON p.ID_VERTRAG    = fzgv_km.ID_VERTRAG
               AND p.ID_FZGVERTRAG = fzgv_km.ID_FZGVERTRAG
               AND fzgv_km.GUID_SSIM is not null
               and (nvl ( p.FZGPR_SUBAS,  0 ) <> 0
                 or nvl ( p.FZGPR_MLP,    0 ) <> 0
                 or nvl ( p.FZGPR_SUBSA,  0 ) <> 0
                 or nvl ( p.FZGPR_SUBBU,  0 ) <> 0
                 or nvl ( p.FZGPR_DISCAS, 0 ) <> 0
                 or nvl ( p.FZGPR_DISSAL, 0 ) <> 0
                 or nvl ( p.FZGPR_DISCHA, 0 ) <> 0
                 or nvl ( p.FZGPR_DISDE,  0 ) <> 0 ))
   , fzgv_pr AS (SELECT * FROM fzgv_pr_all pr WHERE COALESCE( pr.min_FZGPR_VON, DATE '1970-01-01') = COALESCE(pr.FZGPR_VON, DATE '1970-01-01'))
   , pr_pivot AS (
SELECT /*+ DRIVING_SITE(ci) */fzgv_pr.*
     , SUM(DECODE(ci_ty.CUSTINVTYPE_SHORT_CAPTION,'SDAS',1,0)) OVER (PARTITION BY fzgv_pr.preis_ID_SEQ_FZGVC) PR_DISCAS_EXIST
     , SUM(DECODE(ci_ty.CUSTINVTYPE_SHORT_CAPTION,'SDCW',1,0)) OVER (PARTITION BY fzgv_pr.preis_ID_SEQ_FZGVC) PR_DISCHA_EXIST
     , SUM(DECODE(ci_ty.CUSTINVTYPE_SHORT_CAPTION,'EDD' ,1,0)) OVER (PARTITION BY fzgv_pr.preis_ID_SEQ_FZGVC) PR_DISDE_EXIST
     , SUM(DECODE(ci_ty.CUSTINVTYPE_SHORT_CAPTION,'SCAM',1,0)) OVER (PARTITION BY fzgv_pr.preis_ID_SEQ_FZGVC) PR_SUBBU_EXIST
     , SUM(DECODE(ci_ty.CUSTINVTYPE_SHORT_CAPTION,'SDS' ,1,0)) OVER (PARTITION BY fzgv_pr.preis_ID_SEQ_FZGVC) PR_DISSAL_EXIST
     , row_number() OVER (PARTITION BY fzgv_pr.ID_VERTRAG, fzgv_pr.ID_FZGVERTRAG ORDER BY NULL) pr_rn
  FROM fzgv_pr
  LEFT JOIN TCUSTOMER_INVOICE@SIMEX_DB_LINK      ci 
         ON ci.ID_SEQ_FZGVC      = fzgv_pr.preis_ID_SEQ_FZGVC
  LEFT JOIN TCUSTOMER_INVOICE_TYP@SIMEX_DB_LINK  ci_ty    --- !!! ci.GUID_CUSTINVTYPE nullable
         ON ci.GUID_CUSTINVTYPE  = ci_ty.GUID_CUSTINVTYPE
        AND ci_ty.CUSTINVTYPE_SHORT_CAPTION IN ('SDAS', 'SDCW', 'EDD', 'SCAM', 'SDS')
        AND ci.CI_AMOUNT = DECODE( ci_ty.CUSTINVTYPE_SHORT_CAPTION
                                 , 'SDAS', fzgv_pr.FZGPR_DISCAS
                                 , 'SDCW', fzgv_pr.FZGPR_DISCHA
                                 , 'EDD' , fzgv_pr.FZGPR_DISDE
                                 , 'SCAM', fzgv_pr.FZGPR_SUBBU
                                 , 'SDS' , fzgv_pr.FZGPR_DISSAL) 
     )
   , fzgv AS (SELECT * FROM pr_pivot WHERE pr_pivot.pr_rn = 1)
 SELECT /*+ DRIVING_SITE(cos) */fzgv.lvl, fzgv.ID_VERTRAG
      , fzgv.ID_FZGVERTRAG
      , fzgv.end_ID_CUSTOMER
      , fzgv.GUID_CONTRACT
      , fzgv.FZGV_CREATED
      , fzgv.FZGV_I55_VEH_SPEC_TEXT
      , fzgv.ID_VERTRAG_PARENT
      , fzgv.ID_FZGVERTRAG_PARENT
      , fzgv.ID_COS
      , fzgv.ID_GARAGE
      , fzgv.ID_GARAGE_SERV
      , fzgv.FZGV_CAUSE_OF_RETIRE
      , fzgv.FZGV_NO_CUSTOMER    -- as "fleetNumberExternal"
      , fzgv.salesChannel
      , fzgv.driver
      , fzgv.FZGV_SIGNATURE_DATE
      , fzgv.FZGV_FIXED_LABOUR_RATE
      , fzgv.FZGV_ERSTZULASSUNG
      , fzgv.FZGV_BEARBEITER_KAUF
      , fzgv.FZGV_MANUAL_OVERRULE_I55
      , fzgv.FZGV_HANDLE_NOMINATED_DEALER
      , fzgv.FZGV_PROV_AMOUNT
      , fzgv.FZGV_PROV_MEMO
      , fzgv.ID_MANUFACTURE
      , fzgv.FZGV_FGSTNR
      , (select to_char ( max ( JO_END ), 'YYYYMMDD' )
          from snt.TJOURNAL@SIMEX_DB_LINK          j
             , snt.TJOURNAL_POSITION@SIMEX_DB_LINK jp
        where jp.GUID_JO          = j.GUID_JO
          and jp.GUID_JOT         = '17'
          and jp.JOP_FOREIGN      = fzgv.GUID_CONTRACT)             lastPrintDateServiceCard -- AS "lastPrintDateServiceCard"
      , decode ( fzgv.end_RUNPOWER_BAL
               , -1, to_char (fzgv.end_FZGVC_ENDE, 'YYYYMMDD')
               , null )                                             mileageBalancingReminderDate --as "mileageBalancingReminderDate"
      , fzgv.start_FZGVC_BEGINN
      , fzgv.start_FZGVC_BEGINN_KM                              
      , fzgv.end_FZGVC_BEGINN                  
      , fzgv.end_FZGVC_ENDE
      , fzgv.end_FZGVC_ENDE_KM
      , fzgv.end_ID_KMSTAND_END
      , substr(fzgv.FZGV_MEMO || fzgv.end_FZGVC_MEMO,1,2500)                  end_FZGVC_MEMO
      , fzgv.end_FZGVC_IDX_NEXTDATE
      , fzgv.end_FZGVC_SPECIAL_CASE
      , fzgv.end_ID_COV
      , fzgv.end_INV_CONSOLID
      , fa.ID_FAHRZEUGART
      , cur.CUR_CODE
      , paym.ID_PAYM
      , paym.PAYM_MONTHS
      , paym.PAYM_TARGETDATE_CI
      , fzgv.end_ID_SEQ_FZGVC
      , cos.COS_CAPTION
      , cos.COS_ACTIVE
      , indv.INDV_TYPE
      , indv.INDV_CAPTION
      , einsArt.GUID_VI55AV
      , einsArtVal.VI55AV_VALUE
      , fzgTyp.ID_TYPGRUPPE
      , bal2.GUID_BUSINESS_AREA_L2
      , CASE WHEN cuBa.CUBA_IBAN || cuBa.CUBA_BANK_CODE IS NOT NULL AND
                  paymm.paymm_caption_short = 'D' AND -- MKS-136520
                  cuDom.CUSTDOM_DOMNUMBER IS NOT NULL
        THEN 
             lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0'), 34, '0')
          || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0'), 15, '0')
        END                                                                   BankAccount
      , cust.CUST_COST_CENTER
      , cust.CUST_SAP_NUMBER_DEBITOR
      , cust.CUST_INVOICE_CONS_METHOD
      , cust.CUST_INV_ADRESS_BALFIN
      , cust.CUST_INVOICE_ADRESS
      , substr (trim (garCO.GAR_GARNOVEGA), 1, 5)                             gar_garnovega
      , substr (trim (garServ.GAR_GARNOVEGA), 1, 5)                           garserv_garnovega
      , kmStart.FZGKM_KM                                                      start_km
      , kmStart.FZGKM_DATUM                                                   start_km_date
      , fzgv.kmstand_begin_km
      , fzgv.kmstand_begin_km_date
      , fzgv.kmstand_end_km
      , fzgv.kmstand_end_km_date
      , fzgv.last_odometer
      , fzgv.FZGPR_SUBAS
      , fzgv.FZGPR_MLP
      , fzgv.FZGPR_SUBSA
      , fzgv.FZGPR_DISCAS
      , fzgv.FZGPR_DISCHA
      , fzgv.FZGPR_DISDE
      , fzgv.FZGPR_SUBBU
      , fzgv.FZGPR_DISSAL
      , fzgv.PR_DISCAS_EXIST
      , fzgv.PR_DISCHA_EXIST
      , fzgv.PR_DISDE_EXIST
      , fzgv.PR_SUBBU_EXIST
      , fzgv.PR_DISSAL_EXIST
      , (SELECT icp.ICP_CAPTION
           FROM snt.TIC_PACKAGE@SIMEX_DB_LINK      icp
           JOIN snt.TIC_CO_PACK_ASS@SIMEX_DB_LINK  COpack 
             ON COpack.GUID_PACKAGE  = icp.GUID_PACKAGE 
            AND icp.ICP_PACKAGE_TYPE = 2
          WHERE COpack.GUID_CONTRACT = fzgv.GUID_CONTRACT
            AND ROWNUM = 1
        )                                                                     icp_caption
      , CASE WHEN fzgv.end_GUID_BRANCH IS NOT NULL THEN
         (SELECT b.ID_BRANCH_SSI
            FROM snt.TDF_BRANCH@SIMEX_DB_LINK b
           WHERE b.GUID_BRANCH = fzgv.end_GUID_BRANCH
             AND ROWNUM = 1
         ) 
        ELSE NULL
        END                                                                   id_branch_ssi
      , NULL                                                                    product -- Calculate later when temptable is filled, due to performance considerations
      , fzgv.end_COV_SCARF_CONTRACT
    FROM fzgv
    JOIN snt.TDFCONTR_STATE@SIMEX_DB_LINK          cos         ON cos.ID_COS                          = fzgv.ID_COS
    JOIN snt.TGARAGE@SIMEX_DB_LINK                 garCO       ON garCO.ID_GARAGE                     = fzgv.ID_GARAGE
    JOIN snt.TGARAGE@SIMEX_DB_LINK                 garServ     ON garServ.ID_GARAGE                   = fzgv.ID_GARAGE_SERV
    JOIN snt.TFAHRZEUGTYP@SIMEX_DB_LINK            fzgTyp      ON fzgTyp.ID_FZGTYP                    = fzgv.ID_FZGTYP
    JOIN snt.TTYPGRUPPE@SIMEX_DB_LINK              typG        ON fzgTyp.ID_TYPGRUPPE                 = typG.ID_TYPGRUPPE
    JOIN snt.TFAHRZEUGART@SIMEX_DB_LINK            fa          ON fa.ID_FAHRZEUGART                   = typG.ID_FAHRZEUGART
    JOIN snt.TBUSINESS_AREA_L2@SIMEX_DB_LINK       bal2        ON fa.GUID_BUSINESS_AREA_L2            = bal2.GUID_BUSINESS_AREA_L2
    JOIN snt.TFZGKMSTAND@SIMEX_DB_LINK             km_start    ON fzgv.start_ID_KMSTAND_BEGIN         = km_start.ID_SEQ_FZGKMSTAND                                        
    JOIN snt.TEINSATZART@SIMEX_DB_LINK             einsArt     ON fzgv.end_ID_EINSATZART              = einsArt.ID_EINSATZART
    JOIN snt.TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK     einsArtVal  ON einsArtVal.GUID_VI55AV              = einsArt.GUID_VI55AV
    JOIN snt.TDFPAYMODE@SIMEX_DB_LINK              paym        ON fzgv.end_ID_PAYM                    = paym.ID_PAYM
    JOIN snt.TDF_PAYMENT_MODE@SIMEX_DB_LINK        paymm       on fzgv.end_GUID_PAYMENT_MODE          = paymm.GUID_PAYMENT_MODE
    JOIN snt.TDF_INDEXATION_VARIANT@SIMEX_DB_LINK  indv        ON fzgv.end_GUID_INDV                  = indv.GUID_INDV
    JOIN snt.TCUSTOMER@SIMEX_DB_LINK               cust        ON fzgv.end_ID_CUSTOMER                = cust.ID_CUSTOMER   
    JOIN snt.TCURRENCY@SIMEX_DB_LINK               cur         ON cur.ID_CURRENCY                     = cust.ID_CURRENCY
    JOIN snt.TCUSTOMERTYP@SIMEX_DB_LINK            custt       ON custt.ID_CUSTYP                     = cust.ID_CUSTYP
    JOIN snt.TFZGKMSTAND@SIMEX_DB_LINK             kmStart     ON fzgv.start_ID_KMSTAND_BEGIN         = kmStart.ID_SEQ_FZGKMSTAND
    LEFT JOIN snt.TCUSTOMER_DOM@SIMEX_DB_LINK      cuDom       ON cuDom.GUID_CUSTOMER_DOM             =	fzgv.end_GUID_CUSTOMER_DOM
    LEFT JOIN snt.TCUST_BANKING@SIMEX_DB_LINK      cuBa        ON cuDom.CUSTDOM_DOMNUMBER             = cuBa.CUBA_BANK_NAME
                                                              AND cuBa.guid_customer                  = cust.guid_customer
   -- WHERE rownum <1001
   ORDER BY LVL, ID_VERTRAG, start_FZGVC_BEGINN, start_FZGVC_CREATED
  ;
      
      PROCEDURE array_to_TTEMP_TFZGVERTRAG IS
      BEGIN
        FORALL i IN 1..v_VehiContract_tab.COUNT
           INSERT INTO TTEMP_TFZGVERTRAG
             (lvl,
              id_vertrag,    
              id_fzgvertrag,
              id_customer,
              guid_contract,
              fzgv_created,
              fzgv_i55_veh_spec_text,
              id_vertrag_parent,
              id_fzgvertrag_parent,
              id_cos,
              id_garage,
              id_garage_serv,
              fzgv_cause_of_retire,
              fzgv_no_customer,
              saleschannel,
              driver,
              fzgv_signature_date,
              fzgv_fixed_labour_rate,
              fzgv_erstzulassung,
              fzgv_bearbeiter_kauf,
              fzgv_manual_overrule_i55,
              fzgv_handle_nominated_dealer,
              fzgv_prov_amount,
              fzgv_prov_memo,
              id_manufacture,
              fzgv_fgstnr,
              lastprintdateservicecard,
              mileagebalancingreminderdate,
              start_fzgvc_beginn,
              start_fzgvc_beginn_km,
              end_fzgvc_beginn,
              end_fzgvc_ende,
              end_fzgvc_ende_km,
              end_id_kmstand_end,
              end_fzgvc_memo,
              end_fzgvc_idx_nextdate,
              end_fzgvc_special_case,
              end_id_cov,
              end_inv_consolid,
              id_fahrzeugart,
              cur_code,
              id_paym,
              paym_months,
              paym_targetdate_ci,
              end_id_seq_fzgvc,
              cos_caption,
              cos_active,
              indv_type,
              indv_caption,
              guid_vi55av,
              vi55av_value,
              id_typgruppe,
              guid_business_area_l2,
              bankaccount,
              cust_cost_center,
              cust_sap_number_debitor,
              cust_invoice_cons_method,
              cust_inv_adress_balfin,
              cust_invoice_adress,
              gar_garnovega,
              garserv_garnovega,
              start_km,
              start_km_date,
              kmstand_begin_km,
              kmstand_begin_km_date,
              kmstand_end_km,
              kmstand_end_km_date,
              last_odometer,
              FZGPR_SUBAS,
              FZGPR_MLP,
              FZGPR_SUBSA,
              FZGPR_DISCAS,
              FZGPR_DISCHA,
              FZGPR_DISDE,
              FZGPR_SUBBU,
              FZGPR_DISSAL,
              PR_DISCAS_EXIST,
              PR_DISCHA_EXIST,
              PR_DISDE_EXIST,
              PR_SUBBU_EXIST,
              PR_DISSAL_EXIST,
              icp_caption,
              id_branch_ssi,
              product,
              end_COV_SCARF_CONTRACT)
           VALUES
            ( v_VehiContract_tab(i).lvl,
              v_VehiContract_tab(i).id_vertrag,
              v_VehiContract_tab(i).id_fzgvertrag,
              v_VehiContract_tab(i).id_customer,
              v_VehiContract_tab(i).guid_contract,
              v_VehiContract_tab(i).fzgv_created,
              v_VehiContract_tab(i).fzgv_i55_veh_spec_text,
              v_VehiContract_tab(i).id_vertrag_parent,
              v_VehiContract_tab(i).id_fzgvertrag_parent,
              v_VehiContract_tab(i).id_cos,
              v_VehiContract_tab(i).id_garage,
              v_VehiContract_tab(i).id_garage_serv,
              v_VehiContract_tab(i).fzgv_cause_of_retire,
              v_VehiContract_tab(i).fzgv_no_customer,
              v_VehiContract_tab(i).saleschannel,
              v_VehiContract_tab(i).driver,
              v_VehiContract_tab(i).fzgv_signature_date,
              v_VehiContract_tab(i).fzgv_fixed_labour_rate,
              v_VehiContract_tab(i).fzgv_erstzulassung,
              v_VehiContract_tab(i).fzgv_bearbeiter_kauf,
              v_VehiContract_tab(i).fzgv_manual_overrule_i55,
              v_VehiContract_tab(i).fzgv_handle_nominated_dealer,
              v_VehiContract_tab(i).fzgv_prov_amount,
              v_VehiContract_tab(i).fzgv_prov_memo,
              v_VehiContract_tab(i).id_manufacture,
              v_VehiContract_tab(i).fzgv_fgstnr,
              v_VehiContract_tab(i).lastprintdateservicecard,
              v_VehiContract_tab(i).mileagebalancingreminderdate,
              v_VehiContract_tab(i).start_fzgvc_beginn,
              v_VehiContract_tab(i).start_fzgvc_beginn_km,
              v_VehiContract_tab(i).end_fzgvc_beginn,
              v_VehiContract_tab(i).end_fzgvc_ende,
              v_VehiContract_tab(i).end_fzgvc_ende_km,
              v_VehiContract_tab(i).end_id_kmstand_end,
              v_VehiContract_tab(i).end_fzgvc_memo,
              v_VehiContract_tab(i).end_fzgvc_idx_nextdate,
              v_VehiContract_tab(i).end_fzgvc_special_case,
              v_VehiContract_tab(i).end_id_cov,
              v_VehiContract_tab(i).end_inv_consolid,
              v_VehiContract_tab(i).id_fahrzeugart,
              v_VehiContract_tab(i).cur_code,
              v_VehiContract_tab(i).id_paym,
              v_VehiContract_tab(i).paym_months,
              v_VehiContract_tab(i).paym_targetdate_ci,
              v_VehiContract_tab(i).end_id_seq_fzgvc,
              v_VehiContract_tab(i).cos_caption,
              v_VehiContract_tab(i).cos_active,
              v_VehiContract_tab(i).indv_type,
              v_VehiContract_tab(i).indv_caption,
              v_VehiContract_tab(i).guid_vi55av,
              v_VehiContract_tab(i).vi55av_value,
              v_VehiContract_tab(i).id_typgruppe,
              v_VehiContract_tab(i).guid_business_area_l2,
              v_VehiContract_tab(i).bankaccount,
              v_VehiContract_tab(i).cust_cost_center,
              v_VehiContract_tab(i).cust_sap_number_debitor,
              v_VehiContract_tab(i).cust_invoice_cons_method,
              v_VehiContract_tab(i).cust_inv_adress_balfin,
              v_VehiContract_tab(i).cust_invoice_adress,
              v_VehiContract_tab(i).gar_garnovega,
              v_VehiContract_tab(i).garserv_garnovega,
              v_VehiContract_tab(i).start_km,
              v_VehiContract_tab(i).start_km_date,
              v_VehiContract_tab(i).kmstand_begin_km,
              v_VehiContract_tab(i).kmstand_begin_km_date,
              v_VehiContract_tab(i).kmstand_end_km,
              v_VehiContract_tab(i).kmstand_end_km_date,
              v_VehiContract_tab(i).last_odometer,
              v_VehiContract_tab(i).FZGPR_SUBAS,
              v_VehiContract_tab(i).FZGPR_MLP,
              v_VehiContract_tab(i).FZGPR_SUBSA,
              v_VehiContract_tab(i).FZGPR_DISCAS,
              v_VehiContract_tab(i).FZGPR_DISCHA,
              v_VehiContract_tab(i).FZGPR_DISDE,
              v_VehiContract_tab(i).FZGPR_SUBBU,
              v_VehiContract_tab(i).FZGPR_DISSAL,
              v_VehiContract_tab(i).PR_DISCAS_EXIST,
              v_VehiContract_tab(i).PR_DISCHA_EXIST,
              v_VehiContract_tab(i).PR_DISDE_EXIST,
              v_VehiContract_tab(i).PR_SUBBU_EXIST,
              v_VehiContract_tab(i).PR_DISSAL_EXIST,
              v_VehiContract_tab(i).icp_caption,
              v_VehiContract_tab(i).id_branch_ssi,
              PCK_CONTRACT.get_Product_House
             ( I_PH_TYPE      => 'PRODUCT'
             , I_PH_PARAM_IN1 => v_VehiContract_tab(i).ICP_CAPTION
             , I_PH_PARAM_IN2 => v_VehiContract_tab(i).END_ID_COV
             , I_PH_PARAM_IN3 => PCK_CONTRACT.get_Used( I_FZGV_ERSTZULASSUNG => v_VehiContract_tab(i).FZGV_ERSTZULASSUNG
                                                      , I_FZGVC_BEGINN => v_VehiContract_tab(i).start_FZGVC_BEGINN )
             , I_RETURN_WHAT  => 'PH_PARAM_OUT1' 
             ),
              v_VehiContract_tab(i).end_COV_SCARF_CONTRACT);
      
      END array_to_TTEMP_TFZGVERTRAG;
      
      PROCEDURE fill_TTEMP_TFZGVERTRAG IS
      BEGIN
        IF NOT vehi_contract_cur%ISOPEN THEN
           OPEN vehi_contract_cur(i_export_type);
           LOOP
             FETCH vehi_contract_cur
              BULK COLLECT INTO v_VehiContract_tab 
             LIMIT 1000;
             EXIT WHEN v_VehiContract_tab.COUNT = 0;
             
             array_to_TTEMP_TFZGVERTRAG;
             
           END LOOP;
           
           CLOSE vehi_contract_cur;
           
        ELSE
          array_to_TTEMP_TFZGVERTRAG;
        END IF;
        
       -- MariF MKS-136487:1 Append tfzgv_migration_mapping@simex_db_link with iCON-specific data
       INSERT INTO tfzgv_migration_mapping
       ( mm_guid_contract
       , mm_old_contract_number
       , mm_new_contract_number
       , mm_icon_contract_type
       , mm_icon_coverage
       , mm_mapping_made_by
       , mm_comment)
       SELECT t.guid_contract
            , pck_calculation.contract_number_sirius(  t.id_vertrag, t.id_fzgvertrag )
            , pck_calculation.contract_number_migrate( t.id_vertrag, t.id_fzgvertrag )
            , t.product
            , decode(t.end_COV_SCARF_CONTRACT,0,'D007','D000' )
            , pck_calculation.c_mappsrc_extraction -- 'Extraction'
            , pck_calculation.c_msg_normal         -- 'Normal icon renumbering'
         FROM simex.TTEMP_TFZGVERTRAG t;
        
      END fill_TTEMP_TFZGVERTRAG;
      
      PROCEDURE genXML(p_bulk_size INTEGER) IS
        l_rootxml                   XMLTYPE;
        l_invocationsxml            XMLTYPE;
        L_filename                  VARCHAR2 (100 CHAR);
      BEGIN
      
        o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
        L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, G_FILECOUNT_FILLER, 0 )) || '.xml' );
        writelog('0000', 'Start extracting File ' || o_FILE_RUNNING_NO);
        
        IF i_export_type <> c_exptype_VehiContract THEN
          SELECT
          XMLELEMENT ( "common:ServiceInvocationCollection"
          , XMLATTRIBUTES ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                          , 'http://contract.icon.daimler.com/pl'        as "xmlns:contract_pl"
                          , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                          , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                          , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                          , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" 
                          )
          , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_ServiceContract_Mig_BEL_WavePreInt4_v1.0.xlsx' )
          , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
          , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
          , XMLELEMENT ( "executionSettings"
            , XMLATTRIBUTES( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                           , g_expdatetime                   as "dateTime"
                           , G_userID                        as "userId"
                           , pck_calculation.G_TENANT_ID     as "tenantId"
                           , G_causation                     as "causation"
                           , o_FILE_RUNNING_NO               as "additionalInformation1"
                           , G_correlationID                 as "correlationId"
                           , G_IssueThreshold                as "issueThreshold"
                           )
          ),
          xmlagg 
          ( XMLELEMENT ("invocation"
            , XMLATTRIBUTES ( 'createCustomerContract' as "operation")
            , XMLELEMENT("parameter"
              , XMLATTRIBUTES
                ( 'contract_pl:CustomerContractType'                    as "xsi:type"
                , pck_calculation.contract_number_migrate(c.ID_VERTRAG) as "number"
                , c.ID_VERTRAG                                          as "externalId"
                , G_SourceSystem                                        as "sourceSystem"
                , G_masterDataReleaseVersion                            as "masterDataReleaseVersion"
                , G_migrationDate                                       as "migrationDate" )
              , XMLELEMENT ("activeState"
                , XMLATTRIBUTES
                  ( PCK_CALCULATION.SUBSTITUTE (G_TAS_GUID, G_TIMESTAMP
                                               , 'CUSTOMER_CONTRACT_STATE', ' ') as "contractState"
                  , case G_COUNTRY_CODE
                      when '51331' then 'false'
                      else null
                    end                                                          as "chargeOverMileage"
                  , case G_COUNTRY_CODE
                      when '51331' then 'false'
                      else null
                    end                                                          as "creditUnderMileage"
                  , c.COUNT_FZVG_INSCOPE                                         as "currentNumberOfVehicleContracts"
                  , '0'                                                          as "plannedNumberOfVehicleContracts"
                  , G_TermsAndConditionsCode                                     as "termsAndConditionsCode"
                  , 'false'                                                      as "volumeBusiness" )
                  -- the Node Below is an array of Vehicle Contracts if export type is Service Contracts, otherwise nothing generated
                  , decode (i_export_type, c_exptype_ServContract, xmlel_VehiContract(null,c.ID_VERTRAG))
                ) -- </activeState>
              , XMLELEMENT ("contractingCustomer"
                , XMLATTRIBUTES
                  -- FraBe 20.11.2014 MKS-135656:1 merge code von MKS version 1.44 und 1.45 bei "xsi:type" und "externalId": wenn CU der letzten CO duration
                  --       bei "xsi:type"   agiert als dealer oder ist eine OrgPers: 'partner_pl:OrganisationalPersonType' / sonst: 'partner_pl:PhysicalPersonType'
                  --           "externalId" agiert als dealer : 'D' || dealer - ID_GARAGE / sonst: ID_CUSTOMER der letzten CO duration
                  -- FraBe 22.10.2014: Korrektur letzten TK comment: TFZGVERTRAG hat keine ID_CUSTOMER 
                  -- stattdessen ID_CUSTOMER von letzter TFZGV_CONTRACTS duration 
                  -- wurde von Tobi auch so umgesetzt - siehe PCK_PARTNER.GET_CUST_XSI_PARTNER_TYPE ( PCK_CONTRACT.IDcustLastDuration code )
                  -- TK DEF4436: PartnerTyp muss aus der TFZGVERTRAG kommen, NICHT aus dem Vertragsstamm
                  -- MZu, DEF4436: Minor fix (copy/paste error)
                  -- TK DEF5768: MergingFehler, DEF4436 wurde nicht übernommen
                  ( nvl2( PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID, G_TIMESTAMP,'WorkshopAsCustomer', c.ID_CUSTOMER )
                         -- customer agiert auch als OrgPers - Dealer
                        , 'partner_pl:OrganisationalPersonType'   
                         -- check, ob ID_CUSTOMER of last CO duration is of type PhysPers or OrgPers
                        , PCK_PARTNER.GET_CUST_XSI_PARTNER_TYPE( c.ID_CUSTOMER ))                                    as "xsi:type"
                  , nvl2( PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID, G_TIMESTAMP,'WorkshopAsCustomer', c.ID_CUSTOMER )
                         -- customer agiert auch als OrgPers - Dealer
                        ,'D' || PCK_CALCULATION.SUBSTITUTE ( G_TAS_GUID, G_TIMESTAMP,'WorkshopAsCustomer', c.ID_CUSTOMER )
                         -- ID_CUSTOMER of last CO duration:
                        , c.ID_CUSTOMER)                                                                             as "externalId"
                  , G_SourceSystem                                                                                   as "sourceSystem"  
                  )
                ) -- </contractingCustomer>
              ) -- </parameter>
            ) -- </invocation>
            ORDER BY c.lvl, c.id_vertrag
          ) 
          )  
            INTO l_rootxml
            FROM ttemp_tvertragstamm c
        ORDER BY c.lvl, c.id_vertrag;
        ELSE
          l_rootxml := xmlel_VehiContract(o_FILE_RUNNING_NO);
        END IF;

        -- INFO: 0013 Gathering data finished
        writelog('0013', 'for ' || p_bulk_size || ' ' ||  g_xmlobj_dict(i_export_type) ||'(s).', p_force => TRUE);
        -- Write xml file. The trick .extract('.') is needed to generate output with newlines and avoid thus maxlinesize exceeded error
        pck_exports.printXMLToFile (l_rootxml.extract('.'), i_export_path, L_filename);

        -- INFO: 0014 xml file creation finished
        writelog('0014', p_bulk_size || ' '|| g_xmlobj_dict(i_export_type) ||' nodes successfully written to file ' || L_filename, p_force => TRUE);
        
      END genXML;
   
   BEGIN

      G_TAS_GUID    := i_TAS_GUID;
      o_FILE_RUNNING_NO   := 0;

      -- Precalculate prices For VehicleContract, which is also in ServiceContract present
      IF i_export_type IN (c_exptype_VehiContract, c_exptype_ServContract) THEN
      
        writelog('0000', 'Price build logic started.', TRUE);
        pck_contract.ins_TFZGPREIS_SIMEX;
        writelog('0000', 'Price build logic finished.', TRUE);
        
        writelog('0000', 'Deleting previous extraction data from tfzgv_migration_mapping started.', TRUE);
        DELETE tfzgv_migration_mapping
         WHERE mm_mapping_made_by = pck_calculation.c_mappsrc_extraction;
        writelog('0000', 'Deleting previous extraction data from tfzgv_migration_mapping finished. '|| SQL%ROWCOUNT ||' row(s) deleted.', TRUE);
      END IF;
      
      IF i_export_type = c_exptype_VehiContract THEN
        OPEN vehi_contract_cur(i_export_type);
        LOOP
        /* 
          Every iteration fetches n Vehicle Contracts (n=i_TAS_MAX_NODES) into PLSQL in-memory collection
          Iteration before the last one will contain <= n rows, and the last one will fetch 0 rows and exit
          So, we do not need to check cursor again after the loop finishes
        */
          FETCH vehi_contract_cur
           BULK COLLECT INTO v_VehiContract_tab
          LIMIT i_TAS_MAX_NODES;
        
          EXIT WHEN v_VehiContract_tab.COUNT = 0;
          
          fill_TTEMP_TFZGVERTRAG;
         
          IF PCK_CALCULATION.GET_SETTING('SETTING', 'DEBUG', 'FALSE') = 'TRUE' THEN
          
            FOR i IN 1..v_VehiContract_tab.COUNT LOOP
              writelog('0000', v_VehiContract_tab(i).ID_VERTRAG || '/' || v_VehiContract_tab(i).ID_FZGVERTRAG || ' staged to export.' );
            END LOOP;
                 
          END IF;
        
          -- Generate XML from temporary table contents
          genXML(v_VehiContract_tab.COUNT);
 
          -- Purge temporary table for the next iteration
          DELETE TTEMP_TFZGVERTRAG;
        END LOOP;
      
        IF vehi_contract_cur%ISOPEN THEN
          CLOSE vehi_contract_cur;
        END IF;
              
      ELSE
        OPEN cust_contract_cur;
      
        LOOP
           /* 
            Customer Contracts are fetched in a similar manner in bulks by n rows.
           */
          FETCH cust_contract_cur
           BULK COLLECT INTO v_CustContract_tab
          LIMIT i_TAS_MAX_NODES;
           EXIT WHEN v_CustContract_tab.COUNT = 0;
           
           FORALL i IN 1..v_CustContract_tab.count
             INSERT INTO ttemp_tvertragstamm
               ( lvl
               , id_vertrag
               , id_customer
               , count_fzvg_inscope)
             VALUES
               ( v_CustContract_tab(i).lvl
               , v_CustContract_tab(i).id_vertrag
               , v_CustContract_tab(i).id_customer
               , v_CustContract_tab(i).count_fzvg_inscope);
             
           
          IF PCK_CALCULATION.GET_SETTING('SETTING', 'DEBUG', 'FALSE') = 'TRUE' THEN
          
            FOR i IN 1..v_CustContract_tab.COUNT LOOP
              writelog('0000', v_CustContract_tab(i).ID_VERTRAG || ' staged to export.' );        
            END LOOP;
              
          END IF;
          /*
            For Service Contracts (i.e. Customer Contracts with nested corresponding Vehicle Contracts)
            Vehicle Contracts are also fetched
          */
          IF i_export_type = c_exptype_ServContract THEN 
             fill_TTEMP_TFZGVERTRAG;
          END IF;
 
          -- Generate XML Object from temporary table contents
          genXML(v_CustContract_tab.COUNT);
          
          -- Purge temporary table for the next iteration
          IF i_export_type = c_exptype_ServContract THEN 
            DELETE TTEMP_TFZGVERTRAG;
          END IF;
          
          DELETE ttemp_tvertragstamm;
        END LOOP;
      
        IF cust_contract_cur%ISOPEN THEN
          CLOSE cust_contract_cur;
        END IF;
      
      END IF;
      
      -- Final purging of temporary tables (ON COMMIT DELETE ROWS)
      COMMIT; 
       
      RETURN l_ret;
   EXCEPTION
      WHEN pck_calculation.AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
        -- something wrong within creation exportfile
        writelog('0005',Dbms_utility.format_error_backtrace || SQLERRM, p_force => TRUE);
        RETURN -1;                                                 -- fail
   
   END prv_exp_contract;
   
   FUNCTION expALL_CONTRACTS ( i_TAS_GUID          IN     TTASK.TAS_GUID%TYPE
                             , i_export_path       IN     VARCHAR2
                             , i_filename          IN     VARCHAR2
                             , i_TAS_MAX_NODES     IN     INTEGER
                             , o_FILE_RUNNING_NO   OUT    INTEGER )
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
      --    jeweils durchgeführten Plausibilitäsprüfungen
      --    Auswirkungen auf den Bildschirm
      --    durchgeführten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- MKS-117502:1; FraBe 18.09.2012 creation
      -- MKS-118722:1; FraBe 12.10.2012 add out parameter o_FILE_RUNNING_NO to function expALL_CONTRACTS
      --                                plus replace L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
      --                                plus fix bug: add TMESSAGE.LOG_CLASS = 'E' in the exists check within printxmltofile
      -- MKS-126498:1  FraBe 24.06.2013 add G_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expALL_CONTRACTS';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2 (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE;

      FUNCTION cre_CONTRACTS_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', '(' || to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || ')' || '.xml' );

         --
         select XMLELEMENT
              ( "AllContracts"
                  , xmlattributes ( 'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi"
                                  , 'SiMEX_contracts.xsd'                       AS "xsi:noNamespaceSchemaLocation" )
                  , XMLCOMMENT ( 'Source-database: ' || G_DB_NAME_of_DB_LINK )
                  , XMLELEMENT ( "FILENAME",        L_filename )
                  , XMLELEMENT ( "FILE_RUNNING_NO", o_FILE_RUNNING_NO )
                  , XMLELEMENT ( "COUNTRY_ID",      L_COUNTRY_CODE )
                  --- jetzt folgen die fzgv - TFZGVERTRAG - werte im node CONTRACT
                               , ( select XMLAGG ( XMLELEMENT ( "CONTRACT"
                                                      , XMLELEMENT ( "ID_VERTRAG",                       fzgv.ID_VERTRAG )
                                                      , XMLELEMENT ( "ID_FZGVERTRAG",                    fzgv.ID_FZGVERTRAG )
                                                      , XMLELEMENT ( "ID_GARAGE",                        fzgv.ID_GARAGE )
                                                      , XMLELEMENT ( "ID_GARAGE_SERV",                   fzgv.ID_GARAGE_SERV )
                                                      , XMLELEMENT ( "ID_COUNTRY",                       fzgv.ID_COUNTRY )
                                                      , XMLELEMENT ( "ID_FZGTYP",                        fzgv.ID_FZGTYP )
                                                      , XMLELEMENT ( "ID_COS",                           PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                    , L_TIMESTAMP
                                                                                                                                    , 'ID_COS'
                                                                                                                                    , fzgv.ID_COS ))
                                                      , XMLELEMENT ( "ID_MANUFACTURE",                   fzgv.ID_MANUFACTURE )
                                                      , XMLELEMENT ( "FZGV_FGSTNR",                      fzgv.FZGV_FGSTNR )
                                                      , XMLELEMENT ( "FZGV_CHASSIS_VALIDCODE",           fzgv.FZGV_CHASSIS_VALIDCODE )
                                                      , XMLELEMENT ( "FZGV_KFZKENNZEICHEN",              fzgv.FZGV_KFZKENNZEICHEN )
                                                      , XMLELEMENT ( "FZGV_AE_SPLIT",                    fzgv.FZGV_AE_SPLIT )
                                                      , XMLELEMENT ( "FZGV_NO_CUSTOMER",                 fzgv.FZGV_NO_CUSTOMER )
                                                      , XMLELEMENT ( "FZGV_MOTORNR",                     fzgv.FZGV_MOTORNR )
                                                      , XMLELEMENT ( "FZGV_MOTORTYP",                    fzgv.FZGV_MOTORTYP )
                                                      , XMLELEMENT ( "CREATED",                          XMLFOREST ( fzgv.FZGV_CREATED
                                                                                                                   , fzgv.FZGV_CREATOR
                                                                                                                   , fzgv.EXT_CREATION_DATE
                                                                                                                   , fzgv.EXT_UPDATE_DATE ))
                                                      , XMLELEMENT ( "FZGV_ERSTZULASSUNG",               fzgv.FZGV_ERSTZULASSUNG )
                                                      , XMLELEMENT ( "FZGV_GEBRAUCHT",                   fzgv.FZGV_GEBRAUCHT )
                                                      , XMLELEMENT ( "BEARBEITER",                       XMLFOREST ( fzgv.FZGV_BEARBEITER
                                                                                                                   , fzgv.FZGV_BEARBEITER_TECH
                                                                                                                   , fzgv.FZGV_BEARBEITER_KAUF ))
                                                      , XMLELEMENT ( "FZGV_MEMO",                        dbms_xmlgen.convert ( fzgv.FZGV_MEMO ))
                                                      , XMLELEMENT ( "FZGV_AE_SPLIT_TYPE",               fzgv.FZGV_AE_SPLIT_TYPE )
                                                      , XMLELEMENT ( "FZGV_AE_BILL_TO",                  fzgv.FZGV_AE_BILL_TO )
                                                      , XMLELEMENT ( "CHECKED",                          XMLFOREST ( fzgv.FZGV_CHECKED
                                                                                                                   , fzgv.FZGV_CHECKED_BY ))
                                                      , XMLELEMENT ( "FZGV_COMMISSION_NR",               fzgv.FZGV_COMMISSION_NR )
                                                      , XMLELEMENT ( "ID_PRICELIST",                     fzgv.ID_PRICELIST )
                                                      , XMLELEMENT ( "SERVICECARD",                      XMLFOREST ( fzgv.GUID_SERVICECARD
                                                                                                                   , fzgv.FZGV_SCARD_COUNT
                                                                                                                   , scard.SCARD_CAPTION ))
                                                      , XMLELEMENT ( "PROVISION",                        XMLFOREST ( fzgv.FZGV_PROV_ID_GARAGE
                                                                                                                   , fzgv.FZGV_PROV_DATE
                                                                                                                   , fzgv.FZGV_PROV_AMOUNT
                                                                                                                   , dbms_xmlgen.convert ( fzgv.FZGV_PROV_MEMO ) as "FZGV_PROV_MEMO" ))
                                                      , XMLELEMENT ( "GUID_DISCOUNT_TYPE",               fzgv.GUID_DISCOUNT_TYPE )
                                                      , XMLELEMENT ( "FZGV_CAUSE_OF_RETIRE",             fzgv.FZGV_CAUSE_OF_RETIRE )
                                                      , XMLELEMENT ( "FZGV_I55_VEH_SPEC_TEXT",           fzgv.FZGV_I55_VEH_SPEC_TEXT )
                                                      , XMLELEMENT ( "FZGV_I55_CUST_SPEC_TEXT",          fzgv.FZGV_I55_CUST_SPEC_TEXT )
                                                      , XMLELEMENT ( "ID_VERTRAG_PARENT",                fzgv.ID_VERTRAG_PARENT )
                                                      , XMLELEMENT ( "ID_FZGVERTRAG_PARENT",             fzgv.ID_FZGVERTRAG_PARENT )
                                                      , XMLELEMENT ( "FZGV_FIXED_LABOUR_RATE",           fzgv.FZGV_FIXED_LABOUR_RATE )
                                                      , XMLELEMENT ( "FZGV_HANDLE_NOMINATED_DEALER",     fzgv.FZGV_HANDLE_NOMINATED_DEALER )
                                                      , XMLELEMENT ( "GUID_SSIM",                        fzgv.GUID_SSIM )
                                                      , XMLELEMENT ( "TRANSACTION_ID",                   fzgv.TRANSACTION_ID )
                                                      , XMLELEMENT ( "FZGV_AAOL_CODE",                   fzgv.FZGV_AAOL_CODE )
                                                      , XMLELEMENT ( "FZGV_AAOL_DESC",                   fzgv.FZGV_AAOL_DESC )
                                                      , XMLELEMENT ( "FZGV_SIGNATURE_DATE",              fzgv.FZGV_SIGNATURE_DATE )
                                                      , XMLELEMENT ( "FZGV_FORCE_FINAL_INVOICE",         fzgv.FZGV_FORCE_FINAL_INVOICE )
                                                      , XMLELEMENT ( "FZGV_FINAL_CUSTOMER",              fzgv.FZGV_FINAL_CUSTOMER )
                                                      , XMLELEMENT ( "FZGV_CONTRACT_VALUE",              fzgv.FZGV_CONTRACT_VALUE )
                                                      , XMLELEMENT ( "FZGV_WHOLESALE_DATE",              fzgv.FZGV_WHOLESALE_DATE )
                                                      , XMLELEMENT ( "FZGV_ADMIN_FEE",                   fzgv.FZGV_ADMIN_FEE )
                                                      , XMLELEMENT ( "FZGV_MANUAL_OVERRULE_I55",         fzgv.FZGV_MANUAL_OVERRULE_I55 )
                                                      , XMLELEMENT ( "FZGV_FINAL_INVOICE_DONE",          fzgv.FZGV_FINAL_INVOICE_DONE )
                                                      , XMLELEMENT ( "FZGV_MANUAL_PROCESSING",           fzgv.FZGV_MANUAL_PROCESSING )
                                                      , XMLELEMENT ( "SUM_COSTS",                        PCK_CALCULATION.SUM_COSTS    ( i_TAS_GUID
                                                                                                                                      , fzgv.ID_VERTRAG
                                                                                                                                      , fzgv.ID_FZGVERTRAG ))
                                                      , XMLELEMENT ( "SUM_REVENUES",                     PCK_CALCULATION.SUM_REVENUES ( i_TAS_GUID
                                                                                                                                       , fzgv.ID_VERTRAG
                                                                                                                                       , fzgv.ID_FZGVERTRAG ))
                                                      , XMLELEMENT ( "META_PACKAGE",                     pMeta.ICP_CAPTION )
                                                      --- jetzt folgen die pack  - TIC_CO_PACK_ASS / TIC_PACKAGE werte im node PACKAGE
                                                      , XMLELEMENT ( "PACKAGES"
                                                            , ( select XMLAGG ( XMLELEMENT ( "PACKAGE"
                                                                                   , XMLELEMENT ( "PACKAGE_TYPE",             case pack.ICP_PACKAGE_TYPE
                                                                                                                              when 0 then 'RANGE'
                                                                                                                              when 1 then 'ATTRIBUTE'
                                                                                                                              when 3 then 'SERVICE PROVIDER'
                                                                                                                              end  )
                                                                                   , XMLELEMENT ( "ID_PACKAGE",                pack.ID_PACKAGE )
                                                                                   , XMLELEMENT ( "ICP_CAPTION",               pack.ICP_CAPTION )
                                                                                   ) order by pack.ICP_PACKAGE_TYPE, pack.ID_PACKAGE )
                                                                      from TIC_PACKAGE@SIMEX_DB_LINK     pack
                                                                         , TIC_CO_PACK_ASS@SIMEX_DB_LINK cAss
                                                                     where cAss.GUID_CONTRACT    = fzgv.GUID_CONTRACT
                                                                       and cAss.GUID_PACKAGE     = pack.GUID_PACKAGE
                                                                       and 2                    <> pack.ICP_PACKAGE_TYPE ))
                                                      --- jetzt folgen die I55  - TIC_VEGA_I55_CO werte im node VEGA_I55
                                                      , XMLELEMENT ( "VEGAS_I55"
                                                            , ( select XMLAGG ( XMLELEMENT ( "VEGA_I55"
                                                                                   , XMLELEMENT ( "VI55A_CAPTION",            aAtt.VI55A_CAPTION )
                                                                                   , XMLELEMENT ( "VI55AV_CAPTION",           aval.VI55AV_CAPTION )
                                                                                   , XMLELEMENT ( "VI55AV_VALUE",             aval.VI55AV_VALUE )
                                                                                   , XMLELEMENT ( "VI55AV_IS_DEFAULT_VALUE",  aval.VI55AV_IS_DEFAULT_VALUE )
                                                                                   ) order by aAtt.VI55A_DISPLACEMENT )
                                                                  from TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK     aVal
                                                                     , TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK     aAtt
                                                                     , TVEGA_I55_CO@SIMEX_DB_LINK            I55
                                                                 where I55.GUID_CONTRACT    = fzgv.GUID_CONTRACT
                                                                   and I55.GUID_VI55A       = aAtt.GUID_VI55A
                                                                   and I55.GUID_VI55A       = aVal.GUID_VI55A
                                                                   and I55.GUID_VI55AV      = aVal.GUID_VI55AV ))
                                                      --- jetzt folgen die fzgvc - TFZGV_CONTRACTS werte im node CONTRACT_DURATION
                                                      , XMLELEMENT ( "CONTRACT_DURATIONS"
                                                           , ( select XMLAGG ( XMLELEMENT ( "CONTRACT_DURATION"
                                                                                  , XMLELEMENT ( "ID_VERTRAG",                      fzgvc.ID_VERTRAG )
                                                                                  , XMLELEMENT ( "ID_FZGVERTRAG",                   fzgvc.ID_FZGVERTRAG )
                                                                                  , XMLELEMENT ( "ID_SEQ_FZGVC",                    fzgvc.ID_SEQ_FZGVC )
                                                                                  , XMLELEMENT ( "ID_COV",                          PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID, L_TIMESTAMP, 'ID_COV', fzgvc.ID_COV ))
                                                                                  , XMLELEMENT ( "ID_PAYM",                         fzgvc.ID_PAYM )
                                                                                  , XMLELEMENT ( "ID_EINSATZART",                   fzgvc.ID_EINSATZART )
                                                                                  , XMLELEMENT ( "ID_SEQ_FZGKMSTAND_BEGIN",         fzgvc.ID_SEQ_FZGKMSTAND_BEGIN )
                                                                                  , XMLELEMENT ( "ID_SEQ_FZGKMSTAND_END",           fzgvc.ID_SEQ_FZGKMSTAND_END )
                                                                                  , XMLELEMENT ( "GUID_INDV",                       fzgvc.GUID_INDV )
                                                                                  , XMLELEMENT ( "FZGVC_CAPTION",                   fzgvc.FZGVC_CAPTION )
                                                                                  , XMLELEMENT ( "FZGVC_BEGINN",                    fzgvc.FZGVC_BEGINN )
                                                                                  , XMLELEMENT ( "FZGVC_ENDE",                      fzgvc.FZGVC_ENDE )
                                                                                  , XMLELEMENT ( "FZGVC_BEGINN_KM",                 fzgvc.FZGVC_BEGINN_KM )
                                                                                  , XMLELEMENT ( "FZGVC_ENDE_KM",                   fzgvc.FZGVC_ENDE_KM )
                                                                                  , XMLELEMENT ( "FZGVC_TOL_MEHRKM",                fzgvc.FZGVC_TOL_MEHRKM )
                                                                                  , XMLELEMENT ( "FZGVC_TOL_MEHRKMPROZ",            fzgvc.FZGVC_TOL_MEHRKMPROZ )
                                                                                  , XMLELEMENT ( "FZGVC_TOL_MINKM",                 fzgvc.FZGVC_TOL_MINKM )
                                                                                  , XMLELEMENT ( "FZGVC_TOL_MINKMPROZ",             fzgvc.FZGVC_TOL_MINKMPROZ )
                                                                                  , XMLELEMENT ( "FZGVC_CENTRAL_ACCOUNT",           fzgvc.FZGVC_CENTRAL_ACCOUNT )
                                                                                  , XMLELEMENT ( "FZGVC_IDX_PERCENT",               fzgvc.FZGVC_IDX_PERCENT )
                                                                                  , XMLELEMENT ( "FZGVC_IDX_NEXTDATE",              fzgvc.FZGVC_IDX_NEXTDATE )
                                                                                  , XMLELEMENT ( "FZGVC_SERVICE_CARD",              fzgvc.FZGVC_SERVICE_CARD )
                                                                                  , XMLELEMENT ( "FZGVC_MEMO",                      dbms_xmlgen.convert ( fzgvc.FZGVC_MEMO ))
                                                                                  , XMLELEMENT ( "FZGVC_CREATED",                   fzgvc.FZGVC_CREATED )
                                                                                  , XMLELEMENT ( "FZGVC_CREATOR",                   fzgvc.FZGVC_CREATOR )
                                                                                  , XMLELEMENT ( "GUID_PAYMENT",                    fzgvc.GUID_PAYMENT )
                                                                                  , XMLELEMENT ( "GUID_PAYMENT_MODE",               fzgvc.GUID_PAYMENT_MODE )
                                                                                  , XMLELEMENT ( "FZGVC_FACTORING",                 fzgvc.FZGVC_FACTORING )
                                                                                  , XMLELEMENT ( "FZGVC_CREDITNOTE_TEXT",           fzgvc.FZGVC_CREDITNOTE_TEXT )
                                                                                  , XMLELEMENT ( "FZGVC_INVOICE_TEXT",              fzgvc.FZGVC_INVOICE_TEXT )
                                                                                  , XMLELEMENT ( "FZGVC_INVOICE_TEXT_ONCE",         fzgvc.FZGVC_INVOICE_TEXT_ONCE )
                                                                                  , XMLELEMENT ( "ID_CUSTOMER",                     fzgvc.ID_CUSTOMER )
                                                                                  , XMLELEMENT ( "FZGVC_RUNPOWER_BALANCING",        fzgvc.FZGVC_RUNPOWER_BALANCING )
                                                                                  , XMLELEMENT ( "FZGVC_INVOICE_CONSOLIDATION",     fzgvc.FZGVC_INVOICE_CONSOLIDATION )
                                                                                  , XMLELEMENT ( "FZGVC_RUNPOWER_BALANCINGMETHOD",  fzgvc.FZGVC_RUNPOWER_BALANCINGMETHOD )
                                                                                  , XMLELEMENT ( "FZGVC_RUNPOWER_TOLERANCE_PERC",   fzgvc.FZGVC_RUNPOWER_TOLERANCE_PERC )
                                                                                  , XMLELEMENT ( "FZGVC_RUNPOWER_TOLERANCE_DAY",    fzgvc.FZGVC_RUNPOWER_TOLERANCE_DAY )
                                                                                  , XMLELEMENT ( "LAST_OPERATION",                  fzgvc.LAST_OPERATION )
                                                                                  , XMLELEMENT ( "LAST_OPERATION_DATE",             fzgvc.LAST_OPERATION_DATE )
                                                                                  , XMLELEMENT ( "FZGVC_RPB_MAX_MONTH",             fzgvc.FZGVC_RPB_MAX_MONTH )
                                                                                  , XMLELEMENT ( "EXT_CREATION_DATE",               fzgvc.EXT_CREATION_DATE )
                                                                                  , XMLELEMENT ( "EXT_UPDATE_DATE",                 fzgvc.EXT_UPDATE_DATE )
                                                                                  , XMLELEMENT ( "GUID_CUSTOMER_DOM",               fzgvc.GUID_CUSTOMER_DOM )
                                                                                  , XMLELEMENT ( "GUID_BRANCH",                     fzgvc.GUID_BRANCH )
                                                                                  , XMLELEMENT ( "CONTRACT_DURATION_EXT_ID",        fzgvc.CONTRACT_DURATION_EXT_ID )
                                                                                  , XMLELEMENT ( "FZGVC_EXTRED_CONFDATE",           fzgvc.FZGVC_EXTRED_CONFDATE )
                                                                                  , XMLELEMENT ( "FZGVC_SPECIAL_CASE",              fzgvc.FZGVC_SPECIAL_CASE )
                                                                                  , XMLELEMENT ( "FZGVC_HQ_COSTING",                fzgvc.FZGVC_HQ_COSTING )
                                                                                  , XMLELEMENT ( "FZGVC_TIRE_INFORMATION",          fzgvc.FZGVC_TIRE_INFORMATION )
                                                                                  --- jetzt folgen die pri - TFZGPREIS werte im node PRICE_RANGE
                                                                                  , XMLELEMENT ( "PRICE_RANGES"
                                                                                       , ( select XMLAGG ( XMLELEMENT ( "PRICE_RANGE"
                                                                                                              , XMLELEMENT ( "ID_VERTRAG"                , pri.ID_VERTRAG )
                                                                                                              , XMLELEMENT ( "ID_FZGVERTRAG"             , pri.ID_FZGVERTRAG )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGVC"              , pri.ID_SEQ_FZGVC )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGPREIS"           , pri.ID_SEQ_FZGPREIS )
                                                                                                              , XMLELEMENT ( "ID_PRV"                    , pri.ID_PRV )
                                                                                                              , XMLELEMENT ( "FZGPR_PREIS_GRKM"          , pri.FZGPR_PREIS_GRKM )
                                                                                                              , XMLELEMENT ( "FZGPR_VON"                 , pri.FZGPR_VON )
                                                                                                              , XMLELEMENT ( "FZGPR_BIS"                 , pri.FZGPR_BIS )
                                                                                                              , XMLELEMENT ( "FZGPR_PREIS_MONATP"        , pri.FZGPR_PREIS_MONATP )
                                                                                                              , XMLELEMENT ( "FZGPR_PREIS_GRKM_OLD"      , pri.FZGPR_PREIS_GRKM_OLD )
                                                                                                              , XMLELEMENT ( "FZGPR_PREIS_MONATP_OLD"    , pri.FZGPR_PREIS_MONATP_OLD )
                                                                                                              , XMLELEMENT ( "FZGPR_PREIS_FIX"           , pri.FZGPR_PREIS_FIX )
                                                                                                              , XMLELEMENT ( "FZGPR_ADD_MILEAGE"         , pri.FZGPR_ADD_MILEAGE )
                                                                                                              , XMLELEMENT ( "FZGPR_LESS_MILEAGE"        , pri.FZGPR_LESS_MILEAGE )
                                                                                                              , XMLELEMENT ( "FZGPR_SURCHARGE"           , pri.FZGPR_SURCHARGE )
                                                                                                              , XMLELEMENT ( "FZGPR_ADMINFEE"            , pri.FZGPR_ADMINFEE )
                                                                                                              , XMLELEMENT ( "FZGPR_ADMINCHARGE"         , pri.FZGPR_ADMINCHARGE )
                                                                                                              , XMLELEMENT ( "ID_RPCAT"                  , pri.ID_RPCAT )
                                                                                                              , XMLELEMENT ( "ID_RPCAT_OLD"              , pri.ID_RPCAT_OLD )
                                                                                                              , XMLELEMENT ( "EXT_CREATION_DATE"         , pri.EXT_CREATION_DATE )
                                                                                                              , XMLELEMENT ( "EXT_UPDATE_DATE"           , pri.EXT_UPDATE_DATE )
                                                                                                              , XMLELEMENT ( "FZGPR_MLP"                 , pri.FZGPR_MLP )
                                                                                                              , XMLELEMENT ( "FZGPR_SUBBU"               , pri.FZGPR_SUBBU )
                                                                                                              , XMLELEMENT ( "FZGPR_DISCAS"              , pri.FZGPR_DISCAS )
                                                                                                              , XMLELEMENT ( "FZGPR_MLP_OLD"             , pri.FZGPR_MLP_OLD )
                                                                                                              , XMLELEMENT ( "FZGPR_SUBBU_OLD"           , pri.FZGPR_SUBBU_OLD )
                                                                                                              , XMLELEMENT ( "FZGPR_DISCAS_OLD"          , pri.FZGPR_DISCAS_OLD )
                                                                                                              , XMLELEMENT ( "PRICE_RANGE_EXT_ID"        , pri.PRICE_RANGE_EXT_ID )
                                                                                                              , XMLELEMENT ( "FZGPR_BEGIN_MILEAGE"       , pri.FZGPR_BEGIN_MILEAGE )
                                                                                                              , XMLELEMENT ( "FZGPR_END_MILEAGE"         , pri.FZGPR_END_MILEAGE )
                                                                                                              , XMLELEMENT ( "FZGPR_TT"                  , pri.FZGPR_TT )
                                                                                                              , XMLELEMENT ( "FZGPR_ADMIN_FEE_TT"        , pri.FZGPR_ADMIN_FEE_TT )
                                                                                                              , XMLELEMENT ( "FZGPR_SUBAS"               , pri.FZGPR_SUBAS )
                                                                                                              , XMLELEMENT ( "FZGPR_SUBSA"               , pri.FZGPR_SUBSA )
                                                                                                              , XMLELEMENT ( "FZGPR_ADMIN_FEE_MLP"       , pri.FZGPR_ADMIN_FEE_MLP )
                                                                                                              , XMLELEMENT ( "FZGPR_DISDE"               , pri.FZGPR_DISDE )
                                                                                                              , XMLELEMENT ( "FZGPR_DISSAL"              , pri.FZGPR_DISSAL )
                                                                                                              , XMLELEMENT ( "FZGPR_DISCHA"              , pri.FZGPR_DISCHA )
                                                                                                              , XMLELEMENT ( "FZGPR_MF_ORIGINAL"         , pri.FZGPR_MF_ORIGINAL )
                                                                                                              , XMLELEMENT ( "CONTRACT_DURATION_EXT_ID"  , pri.CONTRACT_DURATION_EXT_ID )
                                                                                                              ) order by pri.ID_SEQ_FZGPREIS )
                                                                                             from TFZGPREIS@SIMEX_DB_LINK pri
                                                                                            where fzgvc.ID_VERTRAG      = pri.ID_VERTRAG
                                                                                              and fzgvc.ID_FZGVERTRAG   = pri.ID_FZGVERTRAG
                                                                                              and fzgvc.ID_SEQ_FZGVC    = pri.ID_SEQ_FZGVC ))
                                                                                  --- jetzt folgen die km - TFZGKMSTAND werte im node MILEAGE_REPORT
                                                                                  , XMLELEMENT ( "MILEAGE_REPORTS"
                                                                                       , ( select XMLAGG ( XMLELEMENT ( "MILEAGE_REPORT"
                                                                                                              , XMLELEMENT ( "ID_VERTRAG",               km.ID_VERTRAG )
                                                                                                              , XMLELEMENT ( "ID_FZGVERTRAG",            km.ID_FZGVERTRAG )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGVC",             km.ID_SEQ_FZGVC )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGKMSTAND",        km.ID_SEQ_FZGKMSTAND )
                                                                                                              , XMLELEMENT ( "FZGKM_KM",                 km.FZGKM_KM )
                                                                                                              , XMLELEMENT ( "FZGKM_DATUM",              km.FZGKM_DATUM )
                                                                                                              , XMLELEMENT ( "FZGKM_BETRAG",             km.FZGKM_BETRAG )
                                                                                                              , XMLELEMENT ( "LAST_OPERATION",           km.LAST_OPERATION )
                                                                                                              , XMLELEMENT ( "LAST_OPERATION_DATE",      km.LAST_OPERATION_DATE )
                                                                                                              , XMLELEMENT ( "EXT_CREATION_DATE",        km.EXT_CREATION_DATE )
                                                                                                              , XMLELEMENT ( "EXT_UPDATE_DATE",          km.EXT_UPDATE_DATE )
                                                                                                              , XMLELEMENT ( "MILEAGE_REPORT_EXT_ID",    km.MILEAGE_REPORT_EXT_ID )
                                                                                                              , XMLELEMENT ( "CONTRACT_DURATION_EXT_ID", km.CONTRACT_DURATION_EXT_ID )
                                                                                                              , XMLELEMENT ( "REMARK",                   case km.ID_SEQ_FZGKMSTAND
                                                                                                                                                         when fzgvc.ID_SEQ_FZGKMSTAND_BEGIN then 'CONTRACT BEGIN'
                                                                                                                                                         when fzgvc.ID_SEQ_FZGKMSTAND_END   then 'CONTRACT END'
                                                                                                                                                         else null
                                                                                                                                                         end )
                                                                                                              ) order by km.ID_SEQ_FZGKMSTAND )
                                                                                             from TFZGKMSTAND@SIMEX_DB_LINK km
                                                                                            where fzgvc.ID_VERTRAG      = km.ID_VERTRAG
                                                                                              and fzgvc.ID_FZGVERTRAG   = km.ID_FZGVERTRAG
                                                                                              and fzgvc.ID_SEQ_FZGVC    = km.ID_SEQ_FZGVC ))
                                                                                  --- jetzt folgen die ll - TFZGLAUFLEISTUNG werte im node MILEAGE_CLASSIFICATION
                                                                                  , XMLELEMENT ( "MILEAGE_CLASSIFICATIONS"
                                                                                       , ( select XMLAGG ( XMLELEMENT ( "MILEAGE_CLASSIFICATION"
                                                                                                              , XMLELEMENT ( "ID_VERTRAG"                    , ll.ID_VERTRAG )
                                                                                                              , XMLELEMENT ( "ID_FZGVERTRAG"                 , ll.ID_FZGVERTRAG )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGVC"                  , ll.ID_SEQ_FZGVC )
                                                                                                              , XMLELEMENT ( "ID_SEQ_FZGLAUFLEISTUNG"        , ll.ID_SEQ_FZGLAUFLEISTUNG )
                                                                                                              , XMLELEMENT ( "FZGLL_LAUFLEISTUNG"            , ll.FZGLL_LAUFLEISTUNG )
                                                                                                              , XMLELEMENT ( "FZGLL_VON"                     , ll.FZGLL_VON )
                                                                                                              , XMLELEMENT ( "FZGLL_BIS"                     , ll.FZGLL_BIS )
                                                                                                              , XMLELEMENT ( "ID_LLEINHEIT"                  , ll.ID_LLEINHEIT )
                                                                                                              , XMLELEMENT ( "FZGLL_DAUER_MONATE"            , ll.FZGLL_DAUER_MONATE )
                                                                                                              , XMLELEMENT ( "ID_RPCAT"                      , ll.ID_RPCAT )
                                                                                                              , XMLELEMENT ( "ID_RPCAT_OLD"                  , ll.ID_RPCAT_OLD )
                                                                                                              , XMLELEMENT ( "FZGLL_LAUFLEISTUNG_OLD"        , ll.FZGLL_LAUFLEISTUNG_OLD )
                                                                                                              , XMLELEMENT ( "FZGLL_FREE_MILEAGE"            , ll.FZGLL_FREE_MILEAGE )
                                                                                                              , XMLELEMENT ( "EXT_CREATION_DATE"             , ll.EXT_CREATION_DATE )
                                                                                                              , XMLELEMENT ( "EXT_UPDATE_DATE"               , ll.EXT_UPDATE_DATE )
                                                                                                              , XMLELEMENT ( "MILEAGE_CLASSIFICATION_EXT_ID" , ll.MILEAGE_CLASSIFICATION_EXT_ID )
                                                                                                              , XMLELEMENT ( "CONTRACT_DURATION_EXT_ID"      , ll.CONTRACT_DURATION_EXT_ID )
                                                                                                              ) order by ll.ID_SEQ_FZGLAUFLEISTUNG )
                                                                                             from TFZGLAUFLEISTUNG@SIMEX_DB_LINK ll
                                                                                            where fzgvc.ID_VERTRAG      = ll.ID_VERTRAG
                                                                                              and fzgvc.ID_FZGVERTRAG   = ll.ID_FZGVERTRAG
                                                                                              and fzgvc.ID_SEQ_FZGVC    = ll.ID_SEQ_FZGVC ))
                                                                                  ) order by fzgvc.ID_SEQ_FZGVC )
                                                            from TFZGV_CONTRACTS@SIMEX_DB_LINK fzgvc
                                                           where fzgvc.ID_VERTRAG      = fzgv.ID_VERTRAG
                                                             and fzgvc.ID_FZGVERTRAG   = fzgv.ID_FZGVERTRAG ))
                                        ) order by fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG )
                                     from TIC_PACKAGE@SIMEX_DB_LINK      pMeta
                                        , TIC_CO_PACK_ASS@SIMEX_DB_LINK  cMeta
                                        , TDF_SERVICECARD@SIMEX_DB_LINK  scard
                                        , TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                                        , TXML_SPLIT                     s
                                    where s.PK_VALUE_CHAR              = fzgv.GUID_CONTRACT
                                      and scard.GUID_SERVICECARD(+)    = fzgv.GUID_SERVICECARD
                                      and cMeta.GUID_CONTRACT   (+)    = fzgv.GUID_CONTRACT
                                      and cMeta.GUID_PACKAGE           = pMeta.GUID_PACKAGE
                                      and 2                            = pMeta.ICP_PACKAGE_TYPE
                                 )
                       ).EXTRACT ('.') AS xml
              into l_xml
              from dual;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0013' -- Gathering data finished
                               , i_LOG_TEXT   => 'for ' || i_TAS_MAX_NODES || ' Contracts' );

         -- abbruch wenn vorhin fehler geloggt wurden. wenn nicht: schreiben xml to file
         --
         BEGIN
            SELECT NULL
              INTO L_STAT
              FROM TMESSAGE m, TLOG l
             WHERE     l.LOG_TIMESTAMP = L_TIMESTAMP
                   AND l.LOG_ID = m.LOG_ID
                   AND 'E' = m.LOG_CLASS
                   AND ROWNUM = 1;

            RETURN -1;                                                 -- fail
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pck_exports.printXMLToFile ( l_xml.EXTRACT ('.')
                                          , i_export_path
                                          , L_filename);
               PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                     , i_LOG_ID     => '0014'            -- write xml file finished
                                     , i_LOG_TEXT   => TO_CHAR ( i_TAS_MAX_NODES ) || ' Contract nodes successfully written to file ' || L_filename );

               RETURN 0;                                           --> success
         END;
      --

      END cre_CONTRACTS_xml;


   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      SELECT SET_VALUE
        INTO L_COUNTRY_CODE
        FROM TSETTING
       WHERE SET_SECTION = 'SETTING'
         AND SET_ENTRY   = 'COUNTRY_CODE';

      FOR crec IN (SELECT GUID_CONTRACT FROM TFZGVERTRAG@SIMEX_DB_LINK)
      LOOP
         INSERT INTO TXML_SPLIT (PK_VALUE_CHAR)
              VALUES (crec.GUID_CONTRACT);

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_CONTRACTS_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_CONTRACTS_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN pck_calculation.AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expALL_CONTRACTS;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION expServiceContract
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER
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
      --    jeweils durchgeführten Plausibilitätsprüfungen
      --    Auswirkungen auf den Bildschirm
      --    durchgeführten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- FraBe 10.06.2013 MKS-120788:1 creation
      -- FraBe 24.06.2013 MKS-126498:1 add G_DB_NAME_of_DB_LINK
      -- FraBe 24.06.2013 MKS-120789:2 add call of pck_contract.ins_TFZGPREIS_SIMEX
      -- FraBe 28.06.2013 MKS-121510:2 - use CO beginndate in case of missing erstzulassung
      --                               - extract odometerAtRealEnd only if the CO has a final end date
      --                               - use ll - outerJoin to extract CO with missing ll data as well
      -- FraBe 10.10.2013 MKS-126869:1 add IN parameter paym.PAYM_TARGETDATE_CI within calling of PCK_CONTRACT.CO_REVENUE_AMOUNT
      -- FraBe 10.10.2013 MKS-128875:1 fix bug - do not join ID_COV = ID_COS
      -- FraBe 22.10.2013 MKS-126869:1 add XMLCOMMENT ( 'ORA-20700 ...' )
      -- FraBe 11.02.2014 MKS-129519:1 wave1 änderungen einarbeiten - teil I
      -- FraBe 20.02.2014 MKS-129519:1 fix bugs in get_product_house - aufrufen
      -- FraBe 24.02.2014 MKS-129519:2 default - coverage nur, wenn CO beginn date kleiner oder gleich dem Setting-MigrationDate
      -- FraBe 26.02.2014 MKS-131497:1 SPP coverage: change ActiveCoverageRealCost to coverageRealCost plus make it and its xml attribute period optional
      -- FraBe 20.03.2014 MKS-131260:1 / 131261:1 wave 3.2 änderungen einarbeiten
      -- FraBe 04.04.2014 MKS-131265:1 some FX
      -- FraBe 18.08.2014 MKS-132150:1/132151/1 implement waveFinal / replace L_TIMESTAMP by G_TIMESTAMP
      -- FraBe 01.09.2014 MKS-132385:1 auch ID_FZGVERTRAG_PARENT muß bei derivedFromVehicleContract geckeckt werden!
      -- FraBe 03.09.2014 MKS-132150:2 / 132151:2 some changes due to CO might be terminated, but without real end date and mileage
      -- MaZi  07.10.2014 MKS-134444:1 / 134445:1 WavePreInt4
      -- MaZi  09.10.2014 MKS-134450:1 cre_ServiceContract_xml: bankAccount changes
      -- MaZi  10.10.2014 MKS-134450:2 cre_ServiceContract_xml: bankAccount fixing
      -- MaZi  13.10.2014 MKS-135200:1 cre_ServiceContract_xml: ownedByOrganisation change (remove SUBSTR)
      -- FraBe 20.11.2014 MKS-135656:1 merge code von MKS version 1.44 und 1.45 bei "contractingCustomer" - "xsi:type" und "externalId"
      -- FraBe 20.11.2014 MKS-135622/135623/135636/135637: rename to OLD da obsolete (- nach aufsplittung in Customer- und VehicleContract -)
      -- FraBe 05.12.2014 MKS-135643:  table TFZGLAUFLEISTUNG kann weggelassen werden, da keine daten von ihr gelesen werden
      -- FraBe 05.12.2014 MKS-135643:  rename back to expServiceContract, da code aus performance problemen wieder für Full-ServiceContract reaktiviert wird
      -- FraBe 19.12.2014 MKS-135849:1 add level sort / start with / connent by prior damit die CO in der richtigen reihenfolge exportiert werden
      -- MaZi  13.01.2015 MKS-135609:1 add insert into snt.tvega_mappinglist
      -- MF    05.02.2015 MKS-138692:1 Reimplemented as a wrapper for prv_exp_contract.
      -------------------------------------------------------------------------------
   BEGIN

     RETURN
     prv_exp_contract
       ( i_tas_guid
       , i_export_path     
       , i_filename        
       , i_tas_max_nodes   
       , o_file_running_no
       , c_exptype_ServContract);
       
   END expServiceContract;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION expVehicleContract
          ( i_tas_guid                  TTASK.TAS_GUID%TYPE
          , i_export_path               VARCHAR2
          , i_filename                  VARCHAR2
          , i_tas_max_nodes             INTEGER
          , o_file_running_no       OUT INTEGER
          ) RETURN NUMBER
   IS
     l_ret                       INTEGER        DEFAULT 0;
   BEGIN
   
     RETURN
     prv_exp_contract
       ( i_tas_guid
       , i_export_path     
       , i_filename        
       , i_tas_max_nodes   
       , o_file_running_no
       , c_exptype_VehiContract);
      
   END expVehicleContract;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION expCustomerContract
          ( i_tas_guid                  TTASK.TAS_GUID%TYPE
          , i_export_path               VARCHAR2
          , i_filename                  VARCHAR2
          , i_tas_max_nodes             INTEGER
          , o_file_running_no       OUT INTEGER
          ) RETURN NUMBER
   IS
     l_ret                       INTEGER        DEFAULT 0;
   BEGIN
     
     RETURN
     prv_exp_contract
       ( i_tas_guid
       , i_export_path     
       , i_filename        
       , i_tas_max_nodes   
       , o_file_running_no
       , c_exptype_custcontract);

   END expCustomerContract;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expALL_ODOMETER ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      --    jeweils durchgeführten Plausibilitätsprüfungen
      --    Auswirkungen auf den Bildschirm
      --    durchgeführten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- MKS-118741:1; TK    12.10.2012 creation
      -- MKS-118722:2; FraBe 12.10.2012 L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
      --                                plus TFZGKMSTAND is now the driving table and not TFZGVERTRAG anymore
      -- MKS-126498:1  FraBe 24.06.2013 add G_DB_NAME_of_DB_LINK
      -- MKS-124188:1  Pauzi 09.10.2013 modification based on AnDe
      -- MKS-124191:1  FraBe 14.10.2013 some small changes (-> change l_filename logic / add xmlns:xsd definition )
      -- MKS-124191:1  Pauzi 24.10.2013 new: addOdometer
      -- MKS-124188:2  zisco 05.11.2013 scope exported odometers especially
      -- MKS-124188:5  FraBe 15.11.2013 korrektur falsche auswahl -> details siehe unten direkt bei MKS-124188:5 remark
      -- MKS-131296:1  zisco 14.05.2014 Wave 3.2 iter 1
      -- MKS-134496:1  FraBe 29.10.2014 WavePreInt4
      -- MKS-134496:1  FraBe 29.10.2014 expALL_ODOMETER: WavePreInt4
      -----------------------------------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expALL_ODOMETER';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2 (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              VARCHAR2 (100 CHAR);

      FUNCTION cre_ODOMETER_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, G_FILECOUNT_FILLER, 0 )) || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'         as "xmlns:common"
                                           , 'http://vehicle.icon.daimler.com/pl'        as "xmlns:vehicle_pl"
                                           , 'http://system.mdsd.ibm.com/sl'             as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance' as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'          as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_MileageData_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata: ' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: ' || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , g_expdatetime                   as "dateTime"
                                    , G_userID                        as "userId"
                                    , pck_calculation.G_TENANT_ID     as "tenantId"
                                    , G_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , G_correlationID                 as "correlationId"
                                    , G_issueThreshold                AS "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'addOdometer' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes ( 'vehicle_pl:OdometerType'              AS "xsi:type"
                                                                           , km.FZGKM_KM                            AS "mileage"
                                                                           , 'true'                                 AS "calculationRelevant"
                                                                           , 'reportedMileage'                      AS "mileageState"
                                                                           , to_char ( km.FZGKM_DATUM, 'YYYYMMDD' ) AS "readingDate"
                                                                           -- TK 2014-06-10; MKS-131301:1
                                                                           , '00'||fzgv.ID_VERTRAG||'/'||'00'||fzgv.ID_FZGVERTRAG AS "relatedObjectInternalId"              
                                                                           , 'vehicleContract'                      AS "sourceDefinition"
                                                                           -- end MKS-131301:1
                                                                           , 'migration'                            AS "sourceSystem"
                                                                           , 'true'                                 AS "valid"
                                                                           )
                                                                   )
                                                      -- MKS-133535:1 changed parameters to "values", deliver empty parameter
                                                      , XMLELEMENT ( "parameter"
                                                            , xmlattributes ( 'xsd:string'                    as "xsi:type" )
                                                            , fzgv.ID_MANUFACTURE || fzgv.FZGV_FGSTNR )
                                                      , XMLELEMENT ( "parameter"
                                                            , xmlattributes ( 'xsd:string'                    as "xsi:type" )
                                                            , NULL )
                                                     
                                                          )                          -- END OF INVOCATION
                                order by km.ID_VERTRAG, km.ID_FZGVERTRAG, km.FZGKM_KM )
                                 from TFZGVERTRAG@SIMEX_DB_LINK fzgv,
                                      TFZGKMSTAND@SIMEX_DB_LINK km,
                                      TXML_SPLIT s
                                where s.PK_VALUE_NUM      = km.ID_SEQ_FZGKMSTAND
                                  and km.ID_VERTRAG       = fzgv.ID_VERTRAG
                                  and km.ID_FZGVERTRAG    = fzgv.ID_FZGVERTRAG
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID  => i_TAS_GUID
                               , i_LOG_ID    => '0013'                  -- Gathering data finished
                               , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' odometers' );


         pck_exports.printxmltofile ( l_xml.EXTRACT ('.'), i_export_path, L_filename );
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR ( i_TAS_MAX_NODES ) || ' Odometer nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_ODOMETER_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( SELECT ID_SEQ_FZGKMSTAND
                      FROM TFZGKMSTAND@SIMEX_DB_LINK km,
                           TDFCONTR_VARIANT@SIMEX_DB_LINK  cvar,
                           TFZGV_CONTRACTS@SIMEX_DB_LINK fzgvc
                      WHERE fzgvc.ID_SEQ_FZGVC  = km.ID_SEQ_FZGVC
                        AND fzgvc.ID_COV        = cvar.ID_COV
                        AND substr ( cvar.COV_CAPTION, 1, 7 ) <> 'MIG_OOS'
                        AND ID_SEQ_FZGKMSTAND
                            IN (SELECT id_seq_fzgkmstand FROM (
                                SELECT km.id_seq_fzgkmstand, km.id_vertrag, km.id_fzgvertrag
                                  FROM snt.tfzgkmstand@SIMEX_DB_LINK km
                                 MINUS
                                (SELECT fzg1.id_seq_fzgkmstand_begin, fzg1.id_vertrag, fzg1.id_fzgvertrag
                                   FROM tfzgv_contracts@SIMEX_DB_LINK fzg1
                                  UNION
                                 SELECT fzg2.id_seq_fzgkmstand_end, fzg2.id_vertrag, fzg2.id_fzgvertrag
                                   FROM tfzgv_contracts@SIMEX_DB_LINK fzg2
                                  WHERE fzg2.id_seq_fzgkmstand_end =                                               -- MKS-124188:5 must be = and not <>
                                           get_id_seq_fzgkmstand_end@simex_db_link(
                                              get_max_co@simex_db_link(fzg2.id_vertrag, fzg2.id_fzgvertrag))
                                  UNION
                                 SELECT km2.id_seq_fzgkmstand, km2.id_vertrag, km2.id_fzgvertrag
                                   FROM snt.tfzgkmstand@simex_db_link km2,
                                        snt.tfzgrechnung@simex_db_link re
                                  WHERE km2.fzgkm_km      = re.fzgre_laufstrecke
                                    AND km2.fzgkm_datum   = re.fzgre_repdatum
                                    AND km2.id_seq_fzgvc  = re.id_seq_fzgvc)))
                     order by km.ID_VERTRAG, km.ID_FZGVERTRAG, km.FZGKM_KM )
      LOOP
         INSERT INTO TXML_SPLIT (PK_VALUE_NUM)
              VALUES (crec.ID_SEQ_FZGKMSTAND);

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_ODOMETER_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_ODOMETER_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret = -1 THEN
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
   END expALL_ODOMETER;
BEGIN
  /* Package state initialization */  
  g_xmlobj_dict(c_exptype_CustContract) := 'CustomerContract';
  g_xmlobj_dict(c_exptype_VehiContract) := 'VehicleContract';
  g_xmlobj_dict(c_exptype_ServContract) := 'ServiceContract';
  
end PCK_CONTRACT;
/
