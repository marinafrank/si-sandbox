CREATE OR REPLACE PACKAGE BODY SIMEX.PCK_MODPROTO
IS
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2015/03/20 16:07:32MEZ $
--
-- $Name:  $
--
-- $Revision: 1.6 $
--
-- $Header: 5100_Code_Base/Database/Source/PCK_MODPROTO.plb 1.6 2015/03/20 16:07:32MEZ Frank, Marina (marinf) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/PCK_MODPROTO.plb $
--
-- $Log: 5100_Code_Base/Database/Source/PCK_MODPROTO.plb  $
-- Revision 1.6 2015/03/20 16:07:32MEZ Frank, Marina (marinf) 
-- MKS-151824:1 DEF8653 derive "dateTime" from global settings.
-- Revision 1.5 2015/02/19 17:01:22MEZ Frank, Marina (marinf) 
-- MKS-136397 Implemented LPAD for formatting iCON Contarct Number. 
-- Due to potential loopback overhead via database link new function pck_calculation.contract_number_icon
-- will be included only after optimizing query with restrictive DRIVING_SITE hints.
-- Revision 1.4 2014/11/04 13:45:25MEZ Berger, Franz (fraberg) 
-- - get_actualValue: creation (-> liefert den aktuellen letzten status des CO -> letzter newValue )
-- - get_oldValue: add desc zu order by -> sonst wird immer der erste eintrag genommen wegen rownum = 1
-- - expModProto: beheben der sonstigen im MKS beschriebenen findings
-- Revision 1.3 2014/10/31 14:53:46MEZ Zimmerberger, Markus (zimmerb) 
-- format EXTCOS_CHANGE_DATE as DateTime
-- Revision 1.2 2014/10/31 14:21:24MEZ Zimmerberger, Markus (zimmerb) 
-- Correct get_OldValue
-- Revision 1.1 2014/10/30 18:42:54MEZ Zimmerberger, Markus (zimmerb) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj

-- MKSEND

--
-- Purpose: package for SiMEX ModificationProtocolEntry
--

-- ChangeHistory:
-- ZBerger  22.10.2014 MKS-134522:1 expModProto: creation
-- ZBerger  31.10.2014 MKS-134523:1 get_oldValue: Correction, format EXTCOS_CHANGE_DATE as DateTime
-- FraBe    02.11.2014 MKS-134528:2 get_actualValue: creation (-> liefert den aktuellen letzten status des CO -> letzter newValue )
--                                  get_oldValue: add desc zu order by -> sonst wird immer der erste eintrag genommen wegen rownum = 1
--                                  expModProto: beheben der sonstigen im MKS beschriebenen findings
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

   G_DB_NAME_of_DB_LINK       varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
   G_COUNTRY_CODE             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'COUNTRY_CODE',             null );
   G_TENANT_ID                TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'TENANTID',                 'TENANTID' );
   G_userID                   TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'USERID',                   'SIRIUS'   );
   G_SourceSystem             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',             'SIRIUS'   );
   G_correlationID            TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID',            'SIRIUS'   );
   G_causation                TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',                'migration' );
   G_issueThreshold           TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'ISSUETHRESHOLD',           'SIRIUS'   );
   G_masterDataReleaseVersion TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' );
   G_masterDataVersion        TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MASTERDATA_VERSION',        null   );
   G_migrationDate            TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE',             to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));
   G_CODE_COVERAGE            TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'DEFAULTCOVERAGE',          '0000' );

   G_TIMESTAMP                TIMESTAMP (6)           := SYSTIMESTAMP;
   g_expdatetime              TSETTING.SET_VALUE%TYPE := 
    CASE
      WHEN pck_calculation.g_expdatetime = '0'
        THEN to_char ( G_TIMESTAMP, pck_calculation.c_xmlDTfmt )
      ELSE pck_calculation.g_expdatetime 
    END;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_oldValue 
          ( i_GUID_EXTCOS   TEXT_COS_LASTCHANGE.GUID_EXTCOS@simex_db_link%type
          , i_GUID_CONTRACT TEXT_COS_LASTCHANGE.GUID_CONTRACT@simex_db_link%type
          ) RETURN          VARCHAR2
   IS
   -- FraBe 02.11.2014 MKS-134528:2 add desc zu order by -> sonst wird immer der erste eintrag genommen wegen rownum = 1
   --                               wir brauchen aber den vorherigen zum aktuellen übergeben über i_GUID_EXTCOS

      l_RETURNVALUE  varchar2 ( 100 char )  := 'contract creation';

   BEGIN
      BEGIN
         select 'State: ' || COS_CAPTION || ' (set by SIRIUS user: ' || EXTCOS_USER_ID || ')'
           into l_RETURNVALUE
           from ( select COS_CAPTION
                       , EXTCOS_USER_ID
                    from TEXT_COS_LASTCHANGE@simex_db_link extcos
                       , TDFCONTR_STATE@simex_db_link      cos
                   where cos.ID_COS                = extcos.ID_COS_NEW
                     and extcos.GUID_CONTRACT      = i_GUID_CONTRACT
                     and extcos.EXTCOS_CHANGE_DATE < ( select EXTCOS_CHANGE_DATE
                                                         from TEXT_COS_LASTCHANGE@simex_db_link
                                                        where GUID_EXTCOS = i_GUID_EXTCOS )
       order by EXTCOS_CHANGE_DATE desc )
        where rownum = 1;

         exception when no_data_found then NULL;
      END;
      return l_RETURNVALUE;

   END get_oldValue;
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_actualValue 
          ( i_GUID_EXTCOS   TEXT_COS_LASTCHANGE.GUID_EXTCOS@simex_db_link%type
          , i_GUID_CONTRACT TEXT_COS_LASTCHANGE.GUID_CONTRACT@simex_db_link%type
          ) RETURN          VARCHAR2
   IS
   -- FraBe 02.11.2014 MKS-134528:2 creation

      l_RETURNVALUE  varchar2 ( 100 char )  := null;

   BEGIN
      BEGIN
         select 'State: ' || COS_CAPTION || ' (set by SIRIUS user: ' || EXTCOS_USER_ID || ')'
           into l_RETURNVALUE
           from ( select COS_CAPTION
                       , EXTCOS_USER_ID
                    from TEXT_COS_LASTCHANGE@simex_db_link extcos
                       , TDFCONTR_STATE@simex_db_link      cos
                   where cos.ID_COS                = extcos.ID_COS_NEW
                     and extcos.GUID_CONTRACT      = i_GUID_CONTRACT
       order by EXTCOS_CHANGE_DATE desc )
        where rownum = 1;

         exception when no_data_found then NULL;
      END;
      return l_RETURNVALUE;

   END get_actualValue;
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_newValue ( i_GUID_EXTCOS   TEXT_COS_LASTCHANGE.GUID_EXTCOS@simex_db_link%type )
      RETURN VARCHAR2
   IS

      l_COS_CAPTION  TDFCONTR_STATE.COS_CAPTION@simex_db_link%type;

   BEGIN
      select COS_CAPTION
        into l_COS_CAPTION
        from TEXT_COS_LASTCHANGE@simex_db_link extcos,
             TDFCONTR_STATE@simex_db_link      cos
       where cos.ID_COS         = extcos.ID_COS_NEW
         and extcos.GUID_EXTCOS = i_GUID_EXTCOS;
      return l_COS_CAPTION;

   END get_newValue;
   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expModProto ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      --    jeweils durchgef?hrten Plausibilit?pr?fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef?hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- ZBerger  30.10.2014 MKS-134522:1 creation
      -- FraBe    02.11.2014 MKS-134528:2 beheben der im MKS beschriebenen findings
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expModProto';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT     ( AlreadyLogged, -20000 );
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );

      FUNCTION cre_ModProto_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://logging.mdsd.ibm.com/pl'             as "xmlns:logging_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_ModificationProtocolEntry_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , g_expdatetime                   as "dateTime"
                                    , G_userID                        as "userId"
                                    , G_TENANT_ID                     as "tenantId"
                                    , G_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , G_correlationID                 as "correlationId"
                                    , G_issueThreshold                as "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createModificationProtocolEntry' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'logging_pl:ModificationProtocolType'             as "xsi:type"
                                                                , extcos.GUID_EXTCOS                                as "externalId"
                                                                , G_SourceSystem                                    as "sourceSystem"
                                                                , G_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , lpad ( fzgv.ID_VERTRAG,    8, '0' ) || '/' ||
                                                                  lpad ( fzgv.ID_FZGVERTRAG, 6, '0' )               as "objectKey"
                                                                , G_userID                                          as "actorId"
                                                                , 'VehicleContract'                                 as "additionalInformation1"
                                                                , 'contractState'                                   as "attributeName"
                                                                , 'online'                                          as "causation"
                                                                ,  to_char ( extcos.EXTCOS_CHANGE_DATE, 'YYYY-MM-DD' ) 
                                                                || 'T' 
                                                                || to_char ( extcos.EXTCOS_CHANGE_DATE, 'HH24:MI:SS' )
                                                                                                                    as "dateTime"
                                                                , 'false'                                           as "hide"
                                                                , 'State: ' || pck_modproto.get_newValue
                                                                               ( i_GUID_EXTCOS => extcos.GUID_EXTCOS ) 
                                                                            || ' (set by SIRIUS user: ' 
                                                                            || extcos.EXTCOS_USER_ID 
                                                                            || ')'                                  as "newValue"
                                                                , 'EnumVehicleContractState'                        as "objectType"
                                                                , pck_modproto.get_oldValue
                                                                    ( i_GUID_EXTCOS   => extcos.GUID_EXTCOS 
                                                                    , i_GUID_CONTRACT => extcos.GUID_CONTRACT )     as "oldValue"
                                                                , 'VehicleContractVolatileState'                    as "parentObjectIdentifier"
                                                                , case when pck_modproto.get_OldValue
                                                                            ( i_GUID_EXTCOS   => extcos.GUID_EXTCOS 
                                                                            , i_GUID_CONTRACT => extcos.GUID_CONTRACT ) = 'contract creation'
                                                                       then 'add'
                                                                       else 'modify'
                                                                  end                                               as "typeOf" ))
                                                          )
                                        order by fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG, extcos.EXTCOS_CHANGE_DATE )
                                   from snt.TEXT_COS_LASTCHANGE@SIMEX_DB_LINK extcos
                                      , snt.TFZGVERTRAG@SIMEX_DB_LINK         fzgv
                                      , TXML_SPLIT                            x
                                  where extcos.GUID_CONTRACT = fzgv.GUID_CONTRACT
                                    and extcos.GUID_EXTCOS   = x.PK_VALUE_CHAR
                             )
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createModificationProtocolEntry' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'logging_pl:ModificationProtocolType'             as "xsi:type"
                                                                ,  fzgv.ID_VERTRAG    || '/' 
                                                                || fzgv.ID_FZGVERTRAG || '_Modification'            as "externalId"
                                                                , G_SourceSystem                                    as "sourceSystem"
                                                                , G_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , lpad ( fzgv.ID_VERTRAG,    8, '0' ) || '/' ||
                                                                  lpad ( fzgv.ID_FZGVERTRAG, 6, '0' )               as "objectKey"
                                                                , G_userID                                          as "actorId"
                                                                , 'VehicleContract'                                 as "additionalInformation1"
                                                                , 'contractState'                                   as "attributeName"
                                                                , 'backend'                                         as "causation"
                                                                ,  G_migrationDate                                  as "dateTime"
                                                                , 'false'                                           as "hide"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'ID_COS'
                                                                                             , fzgv.ID_COS )        as "newValue"
                                                                , 'EnumVehicleContractState'                        as "objectType"
                                                                , pck_modproto.get_actualValue
                                                                    ( i_GUID_EXTCOS   => extcos.GUID_EXTCOS 
                                                                    , i_GUID_CONTRACT => extcos.GUID_CONTRACT )     as "oldValue"
                                                                , 'VehicleContractVolatileState'                    as "parentObjectIdentifier"
                                                                , 'modify'                                          as "typeOf" ))
                                                          )
                                        order by fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG )
                                   from snt.TEXT_COS_LASTCHANGE@SIMEX_DB_LINK extcos
                                      , snt.TFZGVERTRAG@SIMEX_DB_LINK         fzgv
                                      , TXML_SPLIT                            x
                                      , ( select GUID_CONTRACT
                                               , max ( EXTCOS_CHANGE_DATE )    as max_EXTCOS_CHANGE_DATE
                                            from snt.TEXT_COS_LASTCHANGE@SIMEX_DB_LINK
                                           group by GUID_CONTRACT  ) extcos_max
                                  where extcos.EXTCOS_CHANGE_DATE = extcos_max.max_EXTCOS_CHANGE_DATE
                                    and extcos.GUID_CONTRACT      = extcos_max.GUID_CONTRACT
                                    and extcos.GUID_CONTRACT      = fzgv.GUID_CONTRACT
                                    and extcos.GUID_EXTCOS        = x.PK_VALUE_CHAR
                             )
           ).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID  => i_TAS_GUID
                               , i_LOG_ID    => '0013'                  -- Gathering data finished
                               , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' ModificationProtocolEntry' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' ModificationProtocolEntry nodes successfully written to file ' || L_filename );

         RETURN 0;                                                 --> success
      --

      END cre_ModProto_xml;

   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( select extcos.GUID_EXTCOS
                      from snt.TEXT_COS_LASTCHANGE@SIMEX_DB_LINK  extcos
                     where exists ( select null
                                      from snt.TFZGVERTRAG@SIMEX_DB_LINK       fzgv
                                         , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                                         , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov
                                     where fzgv.GUID_CONTRACT     = extcos.GUID_CONTRACT
                                       and fzgv.ID_VERTRAG        = fzgvc.ID_VERTRAG
                                       and fzgv.ID_FZGVERTRAG     = fzgvc.ID_FZGVERTRAG
                                       and cov.ID_COV             = fzgvc.ID_COV
                                       and cov.COV_CAPTION not like 'MIG_OOS%' ))
      LOOP
         INSERT INTO simex.TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.GUID_EXTCOS );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_ModProto_xml;
            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;

            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel?scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret      := cre_ModProto_xml;
         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;

         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel?scht, weil sie mit on commit delete rows definiert ist

      END IF;

      o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO * 2;  -- gesamt - fileanzahl = 1x weil ja ein cre und upd eingelfile pro 'file' erstellt wurde

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expModProto;


END;
/
