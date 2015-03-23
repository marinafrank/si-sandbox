-- MKS-121510_2.sql

-- FraBe 29.06.2013 MKS-126779:2

CREATE OR REPLACE PACKAGE BODY PCK_EXPORTS
IS
   --
   --
   -- MKSSTART
   --
   -- $CompanyInfo $
   --
   -- $Date: 2013/06/29 10:25:28MESZ $
   --
   -- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag PBL_INC3.2 PBL_INCREMENT3 PBL_Iteration1  $
   --
   -- $Revision: 1.1 $
   --
   -- $Header: 5100_Code_Base/Database/_IntegrationPatches/MKS-121510_2.sql 1.1 2013/06/29 10:25:28MESZ Berger, Franz (fraberg) CI_Baselined  $
   --
   -- $Source: 5100_Code_Base/Database/_IntegrationPatches/MKS-121510_2.sql $
   --
   -- $Log: 5100_Code_Base/Database/_IntegrationPatches/MKS-121510_2.sql  $
   -- Revision 1.1 2013/06/29 10:25:28MESZ Berger, Franz (fraberg) 
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
   -- Revision 1.48 2013/06/25 16:39:46MESZ Berger, Franz (fraberg) 
   -- FUNCTION expPrivateCustomer: change substitution of TIT_CAPTION to ID_TITLE
   -- Revision 1.47 2013/06/25 14:07:09MESZ Berger, Franz (fraberg) 
   -- add  call of procedure pck_contract.ins_TFZGPREIS_SIMEX in function expServiceContract
   -- Revision 1.46 2013/06/24 18:26:24MESZ Berger, Franz (fraberg) 
   -- add L_DB_NAME_of_DB_LINK within functions expALL_CONTRACTS / expALL_ODOMETER / expPrivateCustomer / expContactPerson / expCommercialCustomer / expWorkshop / expSupplier / expSalesman / expServiceContract
   -- Revision 1.45 2013/06/24 17:57:00MESZ Berger, Franz (fraberg) 
   -- - function expSalesman: add "correlationId" and "masterDataReleaseVersion" due to MKS-126380
   -- - add function expServiceContract
   -- Revision 1.44 2013/05/23 11:38:43MESZ Zimmerberger, Markus (zimmerb) 
   -- Use pck_calculation.get_part_of_bearbeiter_kauf for contactPartnerAssignment.externalId
   -- Revision 1.43 2013/05/23 09:46:10MESZ Zimmerberger, Markus (zimmerb) 
   -- MKS-125778:1 consider case-sensitiv attribute-names and values
   -- Revision 1.42 2013/04/03 15:08:31MESZ Zimmerberger, Markus (zimmerb) 
   -- Performance tuning (now 3 times faster!)
   -- Revision 1.41 2013/04/03 14:16:34MESZ Zimmerberger, Markus (zimmerb) 
   -- Adapt expSalesman
   -- Revision 1.40 2013/04/02 16:30:01MESZ Zimmerberger, Markus (zimmerb) 
   -- Add expSalesman
   -- Revision 1.39 2013/03/28 11:21:30MEZ Berger, Franz (fraberg) 
   -- expWorkshop: move costIssuer after contactPartnerAssignment
   -- Revision 1.38 2013/03/28 10:55:21MEZ Berger, Franz (fraberg) 
   -- expPrivateCustomer / expCommercialCustomer / expContactPerson / expWorkshop / expSupplier: neue logik aufbereiten L_filename
   -- Revision 1.37 2013/03/27 15:40:52MEZ Berger, Franz (fraberg) 
   -- add expSupplier
   -- Revision 1.36 2013/03/27 14:14:02MEZ Berger, Franz (fraberg) 
   -- expWorkshop:           add some new columns / change some CR#2
   -- Revision 1.35 2013/03/27 11:00:01MEZ Berger, Franz (fraberg) 
   -- expContactPerson:      add some new columns / change some CR#2
   -- Revision 1.34 2013/03/27 10:32:23MEZ Berger, Franz (fraberg) 
   -- expCommercialCustomer: add some new columns / change some CR#2
   -- Revision 1.33 2013/03/27 09:23:34MEZ Berger, Franz (fraberg) 
   -- add some new columns / change some CR#2
   -- Revision 1.32 2013/03/25 16:57:03MEZ Berger, Franz (fraberg) 
   -- expCommercialCustomer: use name.NAME_TITEL1 within contactPartnerAssignment and not cust.ID_CUSTOMER
   -- Revision 1.31 2013/03/25 16:35:49MEZ Berger, Franz (fraberg) 
   -- expContactPerson: also export CUSTYP_COMPANY=2 / change externalID addon from CP-1 to -CP1
   -- Revision 1.30 2013/03/25 15:40:35MEZ Berger, Franz (fraberg) 
   -- add function expWorkshop
   -- Revision 1.29 2013/03/22 13:35:46MEZ Berger, Franz (fraberg) 
   -- expCommercialCustomer: add some new columns / change some
   -- Revision 1.28 2013/03/21 15:57:45MEZ Berger, Franz (fraberg) 
   -- expContactPerson:   add some new columns / change some
   -- Revision 1.27 2013/03/21 15:12:23MEZ Berger, Franz (fraberg) 
   -- expPrivateCustomer: add some new columns / change some
   -- Revision 1.26 2013/03/20 15:58:30MEZ Berger, Franz (fraberg) 
   -- expInventoryList: add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden
   -- Revision 1.25 2013/03/19 12:52:10MEZ Berger, Franz (fraberg) 
   -- add expInventoryList
   -- Revision 1.24 2013/03/18 14:11:00MEZ Berger, Franz (fraberg) 
   -- expFIN: add new column ID_FZGTYP
   -- Revision 1.23 2013/03/12 10:15:22MEZ Berger, Franz (fraberg) 
   -- expFIN: add new columns FZGV_KFZKENNZEICHEN and FZGV_ERSTZULASSUNG
   -- Revision 1.22 2013/01/15 18:17:31MEZ Berger, Franz (fraberg) 
   -- function expContactPerson: change custtyp.CUSTYP_COMPANY where condition = 1 to 0
   -- Revision 1.21 2013/01/14 16:15:21MEZ Berger, Franz (fraberg) 
   -- MKS-121478 add expFIN
   -- Revision 1.20 2013/01/07 08:14:27MEZ Kieninger, Tobias (tkienin) 
   -- ContactPerson für Custyp_company=0 anstatt =1
   -- Revision 1.19 2013/01/05 16:31:49MEZ Berger, Franz (fraberg) 
   -- add MigrationScopeList Customer
   -- Revision 1.18 2012/12/31 21:12:45MEZ Berger, Franz (fraberg) 
   -- add function expContactPerson
   -- Revision 1.17 2012/12/18 16:12:20MEZ Berger, Franz (fraberg) 
   -- change function expCommercialCustomer and expPrivateCustomer:
   -- - substr ( 1, 30 ) within PhoneNumber and FaxNumber
   -- - YYYYMMDD without '.' separator within reducedVatGroupValidFrom/To
   -- Revision 1.16 2012/12/07 14:26:57MEZ Berger, Franz (fraberg) 
   -- within expCommercialCustomer and expPrivateCustomer:
   -- lpad an existing "financialSystemRevenueId" value with 16 zero / do not send it at all, if no value exist
   -- Revision 1.15 2012/12/07 13:26:03MEZ Berger, Franz (fraberg) 
   -- add XLMCOMMENT within expCommercialCustomer and expPrivateCustomer
   -- Revision 1.14 2012/12/07 10:08:10MEZ Berger, Franz (fraberg) 
   -- implement new "number" - logic within expCommercialCustomer and expPrivateCustomer
   -- Revision 1.13 2012/12/06 18:51:39MEZ Berger, Franz (fraberg) 
   -- die mailAddress und legalAddress in expCommercialCustomer und expPrivateCustomer werden nur dann exportiert, wenn bei ihnen eine straße angelegt ist
   -- Revision 1.7 2012/11/28 11:05:28MEZ Kieninger, Tobias (tkienin)
   -- odometer executino settings
   -- Revision 1.6 2012/10/17 16:21:18MESZ Berger, Franz (fraberg)
   -- change wrong comment
   -- Revision 1.5 2012/10/12 18:31:52MESZ Berger, Franz (fraberg)
   -- L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
   -- plus TFZGKMSTAND is now the driving table and not TFZGVERTRAG anymore
   -- Revision 1.4 2012/10/12 15:40:47MESZ Kieninger, Tobias (tkienin)
   -- odometer added
   -- Revision 1.3 2012/10/12 15:28:03MESZ Berger, Franz (fraberg)
   -- add out parameter o_FILE_RUNNING_NO to function expALL_CONTRACTS
   -- plus replace L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
   -- plus fix bug: add TMESSAGE.LOG_CLASS = 'E' in the exists check within printxmltofile
   -- Revision 1.2 2012/10/12 15:20:07MESZ Berger, Franz (fraberg)
   -- add out parameter o_FILE_RUNNING_NO to function expALL_CONTRACTS
   -- plus replace L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
   -- plus fix bug: add TMESSAGE.LOG_CLASS = 'E' in the exists check within printxmltofile
   -- Revision 1.1 2012/10/09 16:25:25MESZ Berger, Franz (fraberg)
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
   --
   -- MKSEND

   --
   -- Purpose: Package für die einzelnen untergeordneten SiMEX procedures / functions
   --
   -- MODIFICATION HISTORY
   -- Person      Date        Comments
   -- ---------   ----------  ------------------------------------------
   -- FraBe       01.10.2012  MKS-117502:1 creation
   -- FraBe       2013-03-11  MKS-122725:1 / expFIN: add new columns FZGV_KFZKENNZEICHEN and FZGV_ERSTZULASSUNG
   -- FraBe       2013-03-11  MKS-123558:1 / expFIN: add new column ID_FZGTYP
   -- FraBe       18.03.2013  MKS-121684:1 add expInventoryList
   -- FraBe       20.03.2013  MKS-121685:1 / expInventoryList: add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden
   -- FraBe       21.03.2013  MKS-123185:1 / expPrivateCustomer:    add some new columns / change some CR#1
   -- FraBe       21.03.2013  MKS-123188:1 / expContactPerson:      add some new columns / change some CR#1
   -- FraBe       21.03.2013  MKS-123186:1 / expCommercialCustomer: add some new columns / change some CR#1
   -- FraBe       24.03.2013  MKS-122279:1 add expWorkshop
   -- FraBe       25.03.2013  MKS-123188:1 / expContactPerson: also export CUSTYP_COMPANY=2 / change externalID addon from CP-1 to -CP1
   -- FraBe       25.03.2013  MKS-123186:1 / expCommercialCustomer: use name.NAME_TITEL1 within contactPartnerAssignment and not cust.ID_CUSTOMER
   -- FraBe       26.03.2013  MKS-123814:1 / expPrivateCustomer:    add some new columns / change some CR#2
   -- FraBe       27.03.2013  MKS-123815:1 / expCommercialCustomer: add some new columns / change some CR#2
   -- FraBe       27.03.2013  MKS-123817:1 / expContactPerson:      add some new columns / change some CR#2
   -- FraBe       27.03.2013  MKS-123818:1 / expWorkshop:           add some new columns / change some CR#2
   -- FraBe       27.03.2013  MKS-123819:1 add expSupplier
   -- FraBe       27.03.2013  MKS-123938:1 / expPrivateCustomer / expCommercialCustomer / expContactPerson / expWorkshop / expSupplier: neue logik aufbereiten L_filename
   -- FraBe       27.03.2013  MKS-123818:1 / expWorkshop: move costIssuer after contactPartnerAssignment   
   PROCEDURE printXMLToFile (xmlContent         XMLTYPE
                            ,targetDirectory    VARCHAR2
                            ,Filename           VARCHAR2)
   IS
      fHandle       UTL_FILE.File_Type;

      xmlText       CLOB := xmlContent.getClobVal ();
      xmlTextCopy   CLOB;
      xmlTextSize   BINARY_INTEGER := DBMS_LOB.getLength (xmlText) + 1;

      offset        BINARY_INTEGER := 1;
      buffer        VARCHAR2 (32767 CHAR);
      linesize      BINARY_INTEGER := 30000;                          -- 6400;
      byteCount     BINARY_INTEGER;
      lob1          CLOB;
   BEGIN
      DBMS_LOB.createtemporary (xmlTextCopy, TRUE);
      DBMS_LOB.COPY (xmlTextCopy, xmlText, xmlTextSize);
      -- dbms_output.put_line('Text Size = ' ||  xmlTextSize);
      fhandle      :=
         UTL_FILE.fopen (targetDirectory
                        ,Filename
                        ,'w'
                        ,linesize);
      UTL_FILE.PUT (fHandle, '<?xml version="1.0" encoding="UTF-8"?>');
      UTL_FILE.NEW_LINE (fHandle);

      WHILE (offset < xmlTextSize)
      LOOP
         IF (xmlTextSize - offset > linesize) THEN
            byteCount   := linesize;
         ELSE
            byteCount   := xmlTextSize - offset;
         END IF;

         -- dbms_output.put_line('Offset = ' || Offset || ' ByteCount = '|| byteCount);
         DBMS_LOB.read (xmlTextCopy
                       ,byteCount
                       ,offset
                       ,buffer);
         -- dbms_output.put_line('After Read : ByteCount = '|| byteCount);
         offset   := offset + byteCount;
         UTL_FILE.put (fHandle, buffer);
         UTL_FILE.fflush (fHandle);
      END LOOP;

      UTL_FILE.new_line (fhandle);
      UTL_FILE.fclose (fhandle);
      DBMS_LOB.freeTemporary (xmlTextCopy);
   END;

   PROCEDURE spoolline (i_filehandle UTL_FILE.file_type, i_text VARCHAR2)
   IS
      l_text   VARCHAR2 (32000 CHAR);
   BEGIN
      l_text   := i_text;
      UTL_FILE.put_line ( i_filehandle, l_text, TRUE );
   END;



   ----

   FUNCTION expALL_CUSTOMERS ( i_TAS_GUID      TTASK.TAS_GUID%TYPE
                             , i_filehandle    UTL_FILE.file_type)
      RETURN NUMBER
   IS
      CURSOR curALL_CUSTOMERS
      IS
         SELECT sub_guid          AS "SUB_GUID"
               ,sub_srs_att_name  AS "SUB_SRS_ATT_NAME"
               ,sub_srs_att_value AS "SUB_SRS_ATT_VALUE"
               ,sub_ico_att_value AS "SUB_ICO_ATT_VALUE"
               ,sub_default       AS "SUB_DEFAULT"
           FROM tsubstitute;

      l_count   NUMBER;
   BEGIN
      l_count   := 0;

      spoolline ( i_filehandle, '<ALL_CUSTOMER>' );

      FOR rcur IN curALL_CUSTOMERS
      LOOP
         spoolline ( i_filehandle, '<RECORD>' );

         spoolline ( i_filehandle,' <Field1>' || rcur.SUB_GUID          || '</Field1>' );
         spoolline ( i_filehandle,' <Field2>' || rcur.SUB_SRS_ATT_NAME  || '</Field2>' );
         spoolline ( i_filehandle,' <Field3>' || rcur.SUB_SRS_ATT_VALUE || '</Field3>' );
         spoolline ( i_filehandle,' <Field4>' || rcur.SUB_ICO_ATT_VALUE || '</Field4>' );
         spoolline ( i_filehandle,' <Field5>' || rcur.SUB_DEFAULT       || '</Field5>' );

         spoolline ( i_filehandle, '</RECORD>');

         l_count   := l_count + 1;
      END LOOP;

      spoolline ( i_filehandle, '</ALL_CUSTOMER>' );

      RETURN 0;                                                     -- success
   EXCEPTION
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );

         RETURN -1;                                                    -- fail
   END;

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
      --    jeweils durchgeführten Plausibilitäprüfungen
      --    Auswirkungen auf den Bildschirm
      --    durchgeführten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- MKS-117502:1; FraBe 18.09.2012 creation
      -- MKS-118722:1; FraBe 12.10.2012 add out parameter o_FILE_RUNNING_NO to function expALL_CONTRACTS
      --                                plus replace L_FILE_RUNNING_NO by this new o_FILE_RUNNING_NO
      --                                plus fix bug: add TMESSAGE.LOG_CLASS = 'E' in the exists check within printxmltofile
      -- MKS-126498:1  FraBe 24.06.2013 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expALL_CONTRACTS';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2 (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE;
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );

      FUNCTION cre_CONTRACTS_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename, '.xml', '(' || TO_CHAR (o_FILE_RUNNING_NO) || ')' || '.xml' );

         --
         select XMLELEMENT
              ( "AllContracts"
                  , xmlattributes ( 'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi"
                                  , 'SiMEX_contracts.xsd'                       AS "xsi:noNamespaceSchemaLocation" )
                  , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
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
               printxmltofile ( l_xml.EXTRACT ('.')
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
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expALL_CONTRACTS;


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
      -- MKS-126498:1  FraBe 24.06.2013 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expALL_ODOMETER';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2 (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              VARCHAR2 (100 CHAR);
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE;
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );

      FUNCTION cre_ODOMETER_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '(' || TO_CHAR ( o_FILE_RUNNING_NO ) || ')' || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi"
                                           , 'http://common.icon.daimler.com/il'         AS "xmlns:common" )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings", xmlattributes ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                                                             , 'http://system.mdsd.ibm.com/sl' AS "xmlns:mdsd_sl"
                                                                             , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate,' HH24:MI:SS' ) AS "dateTime"
                                                                             , 'SIRIUS'                        AS "userId"
                                                                             , '53730UK'                       AS "tenantId"
                                                                             , 'MIGRATION'                     AS "causation"
                                                                             , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                                                             )
                                        )
                           , ( select XMLAGG ( XMLELEMENT ( "invocation", xmlattributes ( 'addOdometer' AS "operation"  )
                                                                                        , XMLELEMENT ( "parameter", xmlattributes ( 'vehicle_pl:OdometerType'              AS "xsi:type"
                                                                                                                                  , 'http://vehicle.icon.daimler.com/pl'   AS "xmlns:vehicle_pl"
                                                                                                                                  , km.FZGKM_KM                            AS "mileage"
                                                                                                                                  , to_char ( km.FZGKM_DATUM, 'YYYYMMDD' ) AS "readingDate"
                                                                                                                                  , 'SIRIUS'                               AS "sourceSystem"
                                                                                                                                  )
                                                                                                     )
                                                                                        , XMLELEMENT ( "parameter", xmlattributes ( 'xsd:string' AS "xsi:type"), fzgv.ID_MANUFACTURE || fzgv.FZGV_FGSTNR )
                                                                                        , XMLELEMENT ( "parameter", xmlattributes ( 'xsd:string' AS "xsi:type"), fzgv.FZGV_KFZKENNZEICHEN )
                                                          )                          -- END OF INVOCATION
                                order by km.ID_VERTRAG, km.ID_FZGVERTRAG, km.FZGKM_KM )
                                 from TFZGVERTRAG@SIMEX_DB_LINK fzgv, TFZGKMSTAND@SIMEX_DB_LINK km, TXML_SPLIT s
                                where s.PK_VALUE_NUM    = km.ID_SEQ_FZGKMSTAND
                                  and km.ID_VERTRAG     = fzgv.ID_VERTRAG
                                  and km.ID_FZGVERTRAG  = fzgv.ID_FZGVERTRAG
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID  => i_TAS_GUID
                               , i_LOG_ID    => '0013'                  -- Gathering data finished
                               , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' odometers' );


         printxmltofile ( l_xml.EXTRACT ('.'), i_export_path, L_filename );
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR ( i_TAS_MAX_NODES ) || ' Odometer nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_ODOMETER_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      SELECT SET_VALUE
        INTO L_COUNTRY_CODE
        FROM TSETTING
       WHERE SET_SECTION = 'SETTING'
         AND SET_ENTRY = 'COUNTRY_CODE';

      FOR crec IN ( SELECT ID_SEQ_FZGKMSTAND
                      FROM TFZGKMSTAND@SIMEX_DB_LINK km
                     order by km.ID_VERTRAG, km.ID_FZGVERTRAG, km.FZGKM_KM )
      LOOP
         INSERT INTO TXML_SPLIT (PK_VALUE_NUM)
              VALUES (crec.ID_SEQ_FZGKMSTAND);

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_ODOMETER_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel?scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_ODOMETER_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel?scht, weil sie mit on commit delete rows definiert ist

         IF l_ret = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expALL_ODOMETER;

   FUNCTION expPrivateCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 01.12.2012 MKS-119157:1 creation
      -- FraBe 21.03.2013 MKS-123185:1 add some new columns / change some CR#1
      -- FraBe 21.03.2013 MKS-123814:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 25.06.2013 MKS-126715:1 change substitution of TIT_CAPTION to ID_TITLE
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expPrivateCustomer';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );

      FUNCTION cre_PrivateCustomer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'related to CIM: 20130322_CIM_EDF_PhysicalPerson(privateCustomer)_Mig_BEL_inc3_iter1.3_v9.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'              as "xmlns:partner_pl"
                                                                , cust.ID_CUSTOMER                                  as "externalId"
                                                                , L_SourceSystem                                    as "sourceSystem"
                                                                , '9'                                               as "masterDataReleaseVersion"
                                                                , 'privateCustomer'                                 as "partnerType"
                                                                , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                 ( cust.ID_CUSTOMER )               as "state"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )              as "firstName"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )              as "lastName"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , L_TIMESTAMP
                                                                                             , 'ID_TITLE'
                                                                                             , name.ID_TITLE )      as "salutation"
                                                                , cust.CUST_FISCAL_CODE                             as "personalFiscalCode" )
                                                           , XMLELEMENT ( "communicationData"
                                                                , xmlattributes
                                                                     ( substr ( PCK_CALCULATION.remove_alpha ( name.NAME_TELEFON ), 1, 30 )  as "phoneNumber"
                                                                     , substr ( PCK_CALCULATION.remove_alpha ( name.NAME_TITEL2 ),  1, 30 )  as "mobile"
                                                                     , substr ( PCK_CALCULATION.remove_alpha ( name.NAME_FAX ),     1, 30 )  as "faxNumber"
                                                                     , name.NAME_EMAIL                              as "email" )
                                                                        )
                                                           , XMLELEMENT ( "customerGlobal"
                                                                , xmlattributes
                                                                     ( PCK_CALCULATION.calc_boolean
                                                                          ( I_BOOL_COLUMN => cust.CUST_INVOICE_CONSOLIDATION
                                                                          , I_TRUE        => 1
                                                                          , I_FALSE       => 0 )     as "collectiveCustomerInvoice" )
                                                                          )
                                                           , decode ( adr.ADR_STREET1, null, null
                                                                    , XMLELEMENT ( "legalAddress"
                                                                         , xmlattributes ( adr.ADR_STREET2       as "additionalAddressInfo"
                                                                                , substr ( zip.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov.PROV_CODE )  as "province"
                                                                                , adr.ADR_STREET1                as "street"
                                                                                , zip.ZIP_ZIP                    as "zipCode"
                                                                                         )
                                                                        ))
                                                           , ( select XMLAGG ( XMLELEMENT ( "mailAddress"
                                                                , xmlattributes ( adr1.ADR_STREET2                as "additionalAddressInfo"
                                                                                , substr ( zip1.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty1.COU_CODE )  as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov1.PROV_CODE )  as "province"
                                                                                , adr1.ADR_STREET1                      as "street"
                                                                                , zip1.ZIP_ZIP                          as "zipCode"
                                                                                , substr ( name1.NAME_CAPTION2, 1, 35 ) as "differingName1"
                                                                                , substr ( name1.NAME_CAPTION1, 1, 35 ) as "differingName2"
                                                                                )))
                                                                      from TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                         , TNAME@SIMEX_DB_LINK          name1
                                                                         , TADRESS@SIMEX_DB_LINK        adr1
                                                                         , TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                         , TZIP@SIMEX_DB_LINK           zip1
                                                                         , TPROVINCE@SIMEX_DB_LINK      prov1
                                                                     where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                       and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                       and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                       and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                       and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                       and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                       and adr1.ADR_STREET1       is not null )
                                                           , XMLELEMENT ( "revenueReceipt"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )    as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )  as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_CUSTYP'
                                                                                                             , cust.ID_CUSTYP )  as "vatClassification"
                                                                                , cust.CUST_SAP_NUMBER_DEBITOR                   as "financialSystemRevenueId"
                                                                                )
                                                                        , decode ( cust.CUST_REDVAT_FROM
                                                                                 , null, null
                                                                                       , XMLELEMENT ( "TemporaryTaxSetting"
                                                                                            , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                         , L_TIMESTAMP
                                                                                                                                         , 'ID_CUSTYP'
                                                                                                                                         , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                            , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )        as "validFrom"
                                                                                                            , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )        as "validTo"
                                                                                                            )
                                                                                                    )
                                                                                 )
                                                                        )
                                                          ))
                                order by rownum )
                                   from TLANGUAGE@SIMEX_DB_LINK      lang
                                      , TCURRENCY@SIMEX_DB_LINK      cur
                                      , TADRESS@SIMEX_DB_LINK        adr
                                      , TCOUNTRY@SIMEX_DB_LINK       cty
                                      , TZIP@SIMEX_DB_LINK           zip
                                      , TPROVINCE@SIMEX_DB_LINK      prov
                                      , TCUSTOMER@SIMEX_DB_LINK      cust
                                      , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where lang.ID_LANGUAGE        = cust.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = cust.ID_CURRENCY
                                    and s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                                    and ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and custtyp.ID_CUSTYP       = cust.ID_CUSTYP
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' PrivateCustomers' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' PrivateCustomer nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_PrivateCustomer_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( SELECT ID_CUSTOMER
                      FROM TCUSTOMER@SIMEX_DB_LINK cust
                         , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                     where custtyp.ID_CUSTYP        = cust.ID_CUSTYP
                       and custtyp.CUSTYP_COMPANY   = 1
                       and custtyp.CUSTYP_CAPTION NOT LIKE 'MIG_OOS%'
                     order by ID_CUSTOMER )
      LOOP
         INSERT INTO TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.ID_CUSTOMER );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_PrivateCustomer_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_PrivateCustomer_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expPrivateCustomer;
   
   --------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION expContactPerson ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 31.12.2012 MKS-119157:1 creation
      -- FraBe 21.03.2013 MKS-123188:1 add some new columns / change some
      -- FraBe 25.03.2013 MKS-123188:1 also export CUSTYP_COMPANY=2 / change externalID addon from CP-1 to -CP1
      -- FraBe 27.03.2013 MKS-123817:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expContactPerson';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );

      FUNCTION cre_ContactPerson_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130322_CIM_EDF_PhysicalPerson(contactPerson)_Mig_BEL_inc3_iter1.3_v5.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'              as "xmlns:partner_pl"
                                                                , cust.ID_CUSTOMER || '-CP1'                        as "externalId"
                                                                , L_SourceSystem                                    as "sourceSystem"
                                                                , '9'                                               as "masterDataReleaseVersion"
                                                                , 'contactPerson'                                   as "partnerType"
                                                                , substr ( name.NAME_TITEL1, 1, 35 )                as "lastName"
                                                                )))
                                order by rownum )
                                   from TCUSTOMER@SIMEX_DB_LINK      cust
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                                    and ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and name.NAME_TITEL1    is not null 
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' ContactPersons' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' ContactPerson nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_ContactPerson_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( select cust.ID_CUSTOMER
                      from TCUSTOMER@SIMEX_DB_LINK      cust
                         , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                         , TNAME@SIMEX_DB_LINK          name
                         , TADRASSOZ@SIMEX_DB_LINK      ass
                     where ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                       and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                       and custtyp.ID_CUSTYP       = cust.ID_CUSTYP
                       and custtyp.CUSTYP_COMPANY in ( 0, 2 )         -- TK    07.01.2013 MKS-120795:2 change from 1 to 0
                                                                      -- FraBe 25.03.2013 MKS-123188:1 add 2
                       and custtyp.CUSTYP_CAPTION not like 'MIG_OOS%'
                       and name.NAME_TITEL1    is not null 
                     order by ID_CUSTOMER )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.ID_CUSTOMER );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_ContactPerson_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_ContactPerson_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expContactPerson;

   --------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION expCommercialCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 01.12.2012 MKS-119157:1 creation
      -- FraBe 21.03.2013 MKS-123186:1 add some new columns / change some CR#1
      -- FraBe 25.03.2013 MKS-123186:1 use name.NAME_TITEL1 within contactPartnerAssignment and not cust.ID_CUSTOMER
      -- FraBe 21.03.2013 MKS-123815:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expCommercialCustomer';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );

      FUNCTION cre_CommercialCustomer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130322_CIM_EDF_OrganisationalPerson(commercialCustomer)_Mig_BEL_inc3_iter1.3_v9.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               as "xmlns:partner_pl"
                                                                , cust.ID_CUSTOMER                                   as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , '9'                                                as "masterDataReleaseVersion"
                                                                , 'commercialCustomer'                               as "partnerType"
                                                                , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                 ( cust.ID_CUSTOMER )                as "state"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION1,36, 15 )               as "companyName2"
                                                                , decode ( custtyp.CUSTYP_COMPANY, 2, 'yes', 'no' )  as "companyInternal"
                                                                , cust.CUST_VAT_ID                                   as "vatId" )
                                                           , XMLELEMENT ( "communicationData"
                                                                , xmlattributes
                                                                     ( substr ( PCK_CALCULATION.remove_alpha ( name.NAME_TELEFON ), 1, 30 )  as "phoneNumber"
                                                                     , substr ( PCK_CALCULATION.remove_alpha ( name.NAME_FAX ),     1, 30 )  as "faxNumber"
                                                                     , name.NAME_EMAIL                                     as "email" )
                                                                     )
                                                           , XMLELEMENT ( "customerGlobal"
                                                                , xmlattributes
                                                                     ( PCK_CALCULATION.calc_boolean
                                                                          ( I_BOOL_COLUMN => cust.CUST_INVOICE_CONSOLIDATION
                                                                          , I_TRUE        => 1
                                                                          , I_FALSE       => 0 )     as "collectiveCustomerInvoice" 
                                                                     , 'false'                       as "showCustomerInClaimingSystem" )
                                                                     )
                                                           , decode ( adr.ADR_STREET1, null, null
                                                                    , XMLELEMENT ( "legalAddress"
                                                                         , xmlattributes ( adr.ADR_STREET2       as "additionalAddressInfo"
                                                                                , substr ( zip.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov.PROV_CODE )  as "province"
                                                                                , adr.ADR_STREET1                as "street"
                                                                                , zip.ZIP_ZIP                    as "zipCode"
                                                                                         )
                                                                        ))
                                                           , ( select XMLAGG ( XMLELEMENT ( "mailAddress"
                                                                , xmlattributes ( adr1.ADR_STREET2                as "additionalAddressInfo"
                                                                                , substr ( zip1.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty1.COU_CODE )  as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov1.PROV_CODE )  as "province"
                                                                                , adr1.ADR_STREET1                       as "street"
                                                                                , zip1.ZIP_ZIP                           as "zipCode"
                                                                                , substr ( name1.NAME_CAPTION1,  1, 35 ) as "differingName1"
                                                                                , substr ( name1.NAME_CAPTION1, 36, 15 ) as "differingName2"
                                                                                )))
                                                                      from TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                         , TNAME@SIMEX_DB_LINK          name1
                                                                         , TADRESS@SIMEX_DB_LINK        adr1
                                                                         , TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                         , TZIP@SIMEX_DB_LINK           zip1
                                                                         , TPROVINCE@SIMEX_DB_LINK      prov1
                                                                     where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                       and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                       and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                       and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                       and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                       and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                       and adr1.ADR_STREET1       is not null )
                                                           , XMLELEMENT ( "revenueReceipt"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )    as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )  as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_CUSTYP'
                                                                                                             , cust.ID_CUSTYP )  as "vatClassification"
                                                                                , lpad ( cust.CUST_SAP_NUMBER_DEBITOR, 16, '0' ) as "financialSystemRevenueId"
                                                                                )
                                                                        , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                 , XMLELEMENT ( "TemporaryTaxSetting"
                                                                                      , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                   , L_TIMESTAMP
                                                                                                                                   , 'ID_CUSTYP'
                                                                                                                                   , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                       , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )       as "validFrom"
                                                                                                       , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )       as "validTo"
                                                                                                       )
                                                                                              )
                                                                                 ))
                                                           , decode ( name.NAME_TITEL1, null, null
                                                                    , XMLELEMENT ( "contactPartnerAssignment"
                                                                         , xmlattributes ( 'BE_MI'   as "contactRole"
                                                                                         , 'false'   as "internal"
                                                                                         , 'false'   as "salesman" )
                                                                         , XMLELEMENT ( "contactPerson"
                                                                              , xmlattributes ( cust.ID_CUSTOMER || '-CP1' as "externalId"
                                                                                              , L_SourceSystem             as "sourceSystem" 
                                                                                              )
                                                                                       )
                                                                                 )
                                                                     )
                                                          ))
                                order by rownum )
                                   from TLANGUAGE@SIMEX_DB_LINK      lang
                                      , TCURRENCY@SIMEX_DB_LINK      cur
                                      , TADRESS@SIMEX_DB_LINK        adr
                                      , TCOUNTRY@SIMEX_DB_LINK       cty
                                      , TZIP@SIMEX_DB_LINK           zip
                                      , TPROVINCE@SIMEX_DB_LINK      prov
                                      , TCUSTOMER@SIMEX_DB_LINK      cust
                                      , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where lang.ID_LANGUAGE        = cust.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = cust.ID_CURRENCY
                                    and s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                                    and ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and custtyp.ID_CUSTYP       = cust.ID_CUSTYP
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' CommercialCustomers' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' CommercialCustomer nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_CommercialCustomer_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( SELECT ID_CUSTOMER
                      FROM TCUSTOMER@SIMEX_DB_LINK cust
                         , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                     where custtyp.ID_CUSTYP        = cust.ID_CUSTYP
                       and custtyp.CUSTYP_COMPANY  in ( 0, 2 )
                       and custtyp.CUSTYP_CAPTION NOT LIKE 'MIG_OOS%'
                     order by ID_CUSTOMER )

      LOOP
         INSERT INTO TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.ID_CUSTOMER );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_CommercialCustomer_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_CommercialCustomer_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expCommercialCustomer;

   --------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION expWorkshop ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 24.03.2013  MKS-122279:1 creation
      -- FraBe 27.03.2013  MKS-123818:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013  MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 27.03.2013  MKS-123818:1 move costIssuer after contactPartnerAssignment
      -- MaZi  27.03.2013  MKS-125543:1 use pck_calculation.get_part_of_bearbeiter_kauf for contactPartnerAssignment.externalId
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expWorkshop';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',     'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',       'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM', 'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );

      FUNCTION cre_Workshop_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130322_CIM_EDF_OrganisationalPerson(workshop)_Mig_BEL_inc3_iter1.3_v6.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               as "xmlns:partner_pl"
                                                                , gar.ID_GARAGE                                      as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , '9'                                                as "masterDataReleaseVersion"
                                                                , 'workshop'                                         as "partnerType"
                                                                , PCK_PARTNER.GET_GAR_PARTNER_STATE 
                                                                                 ( gar.ID_GARAGE )                   as "state"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , gar.GAR_VAT_ID                                     as "vatId" )
                                                           , XMLELEMENT ( "communicationData"
                                                                , xmlattributes
                                                                     ( substr ( PCK_CALCULATION.remove_alpha ( name.NAME_TELEFON ), 1, 30 )  as "phoneNumber"
                                                                     , substr ( PCK_CALCULATION.remove_alpha ( name.NAME_FAX ),     1, 30 )  as "faxNumber"
                                                                     , name.NAME_EMAIL                               as "email" )
                                                                     )
                                                           , decode ( adr.ADR_STREET1, null, null
                                                                    , XMLELEMENT ( "legalAddress"
                                                                         , xmlattributes ( adr.ADR_STREET2       as "additionalAddressInfo"
                                                                                , substr ( zip.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov.PROV_CODE )  as "province"
                                                                                , adr.ADR_STREET1                as "street"
                                                                                , zip.ZIP_ZIP                    as "zipCode"
                                                                                         )
                                                                        ))
                                                           , XMLELEMENT ( "revenueReceipt"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) as "vatClassification"
                                                                                , lpad ( gar.GAR_FI_DEBITOR, 16, '0' ) as "financialSystemRevenueId"
                                                                                ))
                                                           , ( select XMLAGG ( XMLELEMENT ( "contactPartnerAssignment"
                                                                                  , xmlattributes ( 'BE_MI'   as "contactRole"
                                                                                                  , 'false'   as "internal"
                                                                                                  , 'true'    as "salesman" )
                                                                                  , XMLELEMENT ( "contactPerson"
                                                                                       , xmlattributes ( pck_calculation.get_part_of_bearbeiter_kauf
                                                                                                        (fzgv.FZGV_BEARBEITER_KAUF, 3, fzgv.id_vertrag || '/' || fzgv.id_fzgvertrag)
                                                                                                                                                    as "externalId"
                                                                                                       , L_SourceSystem                             as "sourceSystem" 
                                                                                                       )
                                                                                               )
                                                                                          )
                                                                             )
                                                                 from TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                                                                where fzgv.ID_GARAGE      = gar.ID_GARAGE
                                                             )
                                                           , XMLELEMENT ( "costIssuer"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) AS "vatClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , lpad ( gar.GAR_FI_CREDITOR, 16, '0' ) as "financialSystemCostId"
                                                                                , 'true'                                as "waitForCreditNote"
                                                                                ))
                                                          ))
                                order by rownum )
                                   from TLANGUAGE@SIMEX_DB_LINK      lang
                                      , TCURRENCY@SIMEX_DB_LINK      cur
                                      , TADRESS@SIMEX_DB_LINK        adr
                                      , TCOUNTRY@SIMEX_DB_LINK       cty
                                      , TZIP@SIMEX_DB_LINK           zip
                                      , TPROVINCE@SIMEX_DB_LINK      prov
                                      , TGARAGE@SIMEX_DB_LINK        gar
                                      , TGARAGETYP@SIMEX_DB_LINK     gartyp
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where lang.ID_LANGUAGE        = gar.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = gar.ID_CURRENCY
                                    and s.PK_VALUE_NUM          = gar.ID_GARAGE
                                    and ass.ID_SEQ_ADRASSOZ     = gar.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and gartyp.ID_GARAGETYP     = gar.ID_GARAGETYP
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' Workshops' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' Workshop nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_Workshop_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( SELECT ID_GARAGE
                      FROM TGARAGE@SIMEX_DB_LINK
                     where GAR_GARNOVEGA           <> '11924'
                       and GAR_IS_SERVICE_PROVIDER  = 0
                     order by ID_GARAGE )

      LOOP
         INSERT INTO TXML_SPLIT ( PK_VALUE_NUM )
              VALUES ( crec.ID_GARAGE );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_Workshop_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Workshop_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expWorkshop;

   --------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION expSupplier ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 27.03.2013 MKS-123819:1 creation
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expSupplier';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',     'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',       'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM', 'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );

      FUNCTION cre_Supplier_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130322_CIM_EDF_OrganisationalPerson(supplier)_Mig_BEL_inc3_iter1.3_v3.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               as "xmlns:partner_pl"
                                                                , gar.ID_GARAGE                                      as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , '9'                                                as "masterDataReleaseVersion"
                                                                , 'supplier'                                         as "partnerType"
                                                                , PCK_PARTNER.GET_GAR_PARTNER_STATE 
                                                                                 ( gar.ID_GARAGE )                   as "state"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , substr ( gar.GAR_GARNOVEGA, 1, 5 )                 as "claimingSystemId"
                                                                , 'GS1234567'                                        as "gssnOutletOutletId"
                                                                , gar.GAR_VAT_ID                                     as "vatId" )
                                                           , XMLELEMENT ( "communicationData"
                                                                , xmlattributes
                                                                     ( substr ( PCK_CALCULATION.remove_alpha ( name.NAME_TELEFON ), 1, 30 )  as "phoneNumber"
                                                                     , substr ( PCK_CALCULATION.remove_alpha ( name.NAME_FAX ),     1, 30 )  as "faxNumber"
                                                                     , name.NAME_EMAIL                               as "email" )
                                                                     )
                                                           , decode ( adr.ADR_STREET1, null, null
                                                                    , XMLELEMENT ( "legalAddress"
                                                                         , xmlattributes ( adr.ADR_STREET2       as "additionalAddressInfo"
                                                                                , substr ( zip.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov.PROV_CODE )  as "province"
                                                                                , adr.ADR_STREET1                as "street"
                                                                                , zip.ZIP_ZIP                    as "zipCode"
                                                                                         )
                                                                        ))
                                                           , XMLELEMENT ( "revenueReceipt"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) as "vatClassification"
                                                                                , lpad ( gar.GAR_FI_DEBITOR, 16, '0' ) as "financialSystemRevenueId"
                                                                                ))
                                                           , XMLELEMENT ( "costIssuer"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) AS "vatClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , lpad ( gar.GAR_FI_CREDITOR, 16, '0' ) as "financialSystemCostId"
                                                                                , 'true'                                as "waitForCreditNote"
                                                                                , '0'                                   as "collectiveFinancialDocumentThresholdCreditNoteServiceProviderIndividualInvoice"
                                                                                , '0'                                   as "collectiveFinancialDocumentThresholdCreditNoteServiceProviderMonthlyPayment"
                                                                                , '0'                                   as "collectiveFinancialDocumentThresholdInvoiceServiceProviderIndividualInvoice"
                                                                                , '0'                                   as "collectiveFinancialDocumentThresholdInvoiceServiceProviderMonthlyPayment"
                                                                                , '0'                                   as "singleFinancialDocumentThresholdCreditNoteServiceProviderIndividualInvoice"
                                                                                , '0'                                   as "singleFinancialDocumentThresholdCreditNoteServiceProviderMonthlyPayment"
                                                                                , '0'                                   as "singleFinancialDocumentThresholdInvoiceServiceProviderIndividualInvoice"
                                                                                , '0'                                   as "singleFinancialDocumentThresholdInvoiceServiceProviderMonthlyPayment"
                                                                                ))
                                                          ))
                                order by rownum )
                                   from TLANGUAGE@SIMEX_DB_LINK      lang
                                      , TCURRENCY@SIMEX_DB_LINK      cur
                                      , TADRESS@SIMEX_DB_LINK        adr
                                      , TCOUNTRY@SIMEX_DB_LINK       cty
                                      , TZIP@SIMEX_DB_LINK           zip
                                      , TPROVINCE@SIMEX_DB_LINK      prov
                                      , TGARAGE@SIMEX_DB_LINK        gar
                                      , TGARAGETYP@SIMEX_DB_LINK     gartyp
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where lang.ID_LANGUAGE        = gar.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = gar.ID_CURRENCY
                                    and s.PK_VALUE_NUM          = gar.ID_GARAGE
                                    and ass.ID_SEQ_ADRASSOZ     = gar.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and gartyp.ID_GARAGETYP     = gar.ID_GARAGETYP
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' Suppliers' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' Supplier nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_Supplier_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( SELECT ID_GARAGE
                      FROM TGARAGE@SIMEX_DB_LINK
                     where GAR_GARNOVEGA            = '11924'
                        or GAR_IS_SERVICE_PROVIDER  = 1
                     order by ID_GARAGE )

      LOOP
         INSERT INTO TXML_SPLIT ( PK_VALUE_NUM )
              VALUES ( crec.ID_GARAGE );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_Supplier_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Supplier_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expSupplier;

  --------------------------------------------------------------------------------------------------------------------------------
   
   function expMigScopeCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                                , i_filehandle            UTL_FILE.file_type
                                , o_FILE_RUNNING_NO   OUT INTEGER )
      return number
   is

      l_count                        number;
      l_inScope_Inv_Recipient        varchar2 ( 32000 char );
      l_outScope_Inv_Recipient       varchar2 ( 32000 char );
      l_inScope_Alt_Inv_Recipient    varchar2 ( 32000 char );
      l_outScope_Alt_Inv_Recipient   varchar2 ( 32000 char );
      
      procedure clear_l_vars is
      begin
         l_inScope_Inv_Recipient      := '';
         l_outScope_Inv_Recipient     := '';
         l_inScope_Alt_Inv_Recipient  := '';
         l_outScope_Alt_Inv_Recipient := '';
      end;
      
      procedure chk_spoolline 
              ( L_STR            varchar2 ) is
      begin
           if   length ( L_STR ) > 31980
           then spoolline ( i_filehandle, L_STR );
                clear_l_vars;
                l_count := l_count + 1;
           end  if;
      end;

   begin
   
      l_count   := 0;

      for crec in ( select cust.ID_CUSTOMER
                         , decode ( substr ( custyp.CUSTYP_CAPTION, 1, 7 )
                                  , 'MIG_OOS', 'outScope', 'inScope' ) as STATUS
                      from snt.TCUSTOMERTYP@SIMEX_DB_LINK custyp 
                         , snt.TCUSTOMER@SIMEX_DB_LINK    cust
                     where cust.ID_CUSTYP   =  custyp.ID_CUSTYP
                     order by 2, 1 )
      loop
      
         if   l_count = 0  -- ausgabe Überschrift
         then spoolline ( i_filehandle,  '"ID CUSTOMER"'
                                     || ';"Scope"'
                                     || ';"inScope Invoice Recipient"'
                                     || ';"outScope Invoice Recipient"'
                                     || ';"inScope Alternative Invoice Recipient"'
                                     || ';"outScope Alternative Invoice Recipient"'
                        );
         end  if;

         clear_l_vars;

         for c2rec in ( select distinct
                               fzgvc.ID_VERTRAG || '/' || fzgvc.ID_FZGVERTRAG  as SVpos
                             , fzgvc.ID_CUSTOMER
                             , cvar.COV_CAPTION
                          from snt.TFZGV_CONTRACTS@SIMEX_DB_LINK     fzgvc
                             , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK    cvar
                             , snt.TPARTNER@SIMEX_DB_LINK            part
                             , snt.TCUSTOMER_INVOICE@SIMEX_DB_LINK   cinv
                         where part.ID_CUSTOMER        = crec.ID_CUSTOMER
                           and part.GUID_PARTNER       = cinv.GUID_PARTNER
                           and fzgvc.ID_SEQ_FZGVC      = cinv.ID_SEQ_FZGVC
                           and fzgvc.ID_COV            = cvar.ID_COV 
                      order by 1, 2 )
         loop
         
             if   substr ( c2rec.COV_CAPTION, 1, 7 ) = 'MIG_OOS'                   -- outScope
             then if   crec.ID_CUSTOMER = c2rec.ID_CUSTOMER                        -- normal inv receipient
                  then if   length ( l_outScope_Inv_Recipient ) > 0
                       then l_outScope_Inv_Recipient := l_outScope_Inv_Recipient || ',';
                       end  if;
                       l_outScope_Inv_Recipient := l_outScope_Inv_Recipient || c2rec.SVpos;
                  else if   length ( l_outScope_Alt_Inv_Recipient ) > 0            -- alternative inv receipient
                       then l_outScope_Alt_Inv_Recipient := l_outScope_Alt_Inv_Recipient || ',';
                       end  if;
                       l_outScope_Alt_Inv_Recipient := l_outScope_Alt_Inv_Recipient || c2rec.SVpos;
                  end  if;  
             else                                                                  -- inScope 
                  if   crec.ID_CUSTOMER = c2rec.ID_CUSTOMER                        -- normal inv receipient
                  then if   length ( l_inScope_Inv_Recipient ) > 0
                       then l_inScope_Inv_Recipient := l_inScope_Inv_Recipient || ',';
                       end  if;
                       l_inScope_Inv_Recipient := l_inScope_Inv_Recipient || c2rec.SVpos;
                  else if   length ( l_inScope_Alt_Inv_Recipient ) > 0             -- alternative inv receipient
                       then l_inScope_Alt_Inv_Recipient := l_inScope_Alt_Inv_Recipient || ',';
                       end  if;
                       l_inScope_Alt_Inv_Recipient := l_inScope_Alt_Inv_Recipient || c2rec.SVpos;
                  end  if;  
             end  if;
                  
             chk_spoolline (    '"' || crec.ID_CUSTOMER
                           || '";"' || crec.STATUS
                           || '";"' || l_inScope_Inv_Recipient
                           || '";"' || l_outScope_Inv_Recipient
                           || '";"' || l_inScope_Alt_Inv_Recipient
                           || '";"' || l_outScope_Alt_Inv_Recipient
                           || '"' );
         end loop;

         spoolline ( i_filehandle,   '"' || crec.ID_CUSTOMER
                                || '";"' || crec.STATUS
                                || '";"' || l_inScope_Inv_Recipient
                                || '";"' || l_outScope_Inv_Recipient
                                || '";"' || l_inScope_Alt_Inv_Recipient
                                || '";"' || l_outScope_Alt_Inv_Recipient
                                || '"'
                   );

         l_count   := l_count + 1;
      
      end loop;

      if   l_count = 0
      then o_FILE_RUNNING_NO := 0;
      else o_FILE_RUNNING_NO := 1;
      end  if;
      
      return 0;                                                     -- SUCCESS
   exception
      when others then
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );

         return -1;                                                    -- fail
   end expMigScopeCustomer;

   --------------------------------------------------------------------------------------------------------------------------------

   -- FraBe 2013-01-14 MKS-121478   add expFIN
   -- FraBe 2013-03-11 MKS-122725:1 add new columns FZGV_KFZKENNZEICHEN and FZGV_ERSTZULASSUNG
   -- FraBe 2013-03-11 MKS-123558:1 add new column ID_FZGTYP
   function expFIN ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                   , i_filehandle            UTL_FILE.file_type
                   , o_FILE_RUNNING_NO   OUT INTEGER )
      return number
   is

      l_count                        number;

   begin
   
      l_count   := 0;

      for crec in ( select distinct 
                           fzgv.ID_MANUFACTURE
                         , fzgv.FZGV_FGSTNR
                         , fzgv.FZGV_CHASSIS_VALIDCODE
                         , fzgv.FZGV_KFZKENNZEICHEN                       -- MKS-122725:1 add new columns FZGV_KFZKENNZEICHEN and FZGV_ERSTZULASSUNG
                         , to_char ( fzgv.FZGV_ERSTZULASSUNG, 'YYYYMMDD' ) as FZGV_ERSTZULASSUNG
                         , fzgv.ID_FZGTYP
                      from snt.TFZGVERTRAG@SIMEX_DB_LINK         fzgv
                         , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK     fzgvc
                         , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK    cvar
                     where fzgv.ID_VERTRAG          = fzgvc.ID_VERTRAG
                       and fzgv.ID_FZGVERTRAG       = fzgvc.ID_FZGVERTRAG
                       and cvar.ID_COV              = fzgvc.ID_COV
                       and cvar.COV_CAPTION  not like 'MIG_OOS%'
                     order by 1, 2, 3 )
      loop
      
         if   l_count = 0  -- ausgabe Überschrift
         then spoolline ( i_filehandle,  '"ID MANUFACTURE"'
                                     || ';"FIN"'
                                     || ';"FIN Control Digit"'
                                     || ';"License PLate"'
                                     || ';"First Registration Date"'
                                     || ';"Vehicle Type Code"'
                        );
         end  if;

         spoolline ( i_filehandle,   '"' || crec.ID_MANUFACTURE
                                || '";"' || crec.FZGV_FGSTNR
                                || '";"' || crec.FZGV_CHASSIS_VALIDCODE
                                || '";"' || crec.FZGV_KFZKENNZEICHEN
                                || '";"' || crec.FZGV_ERSTZULASSUNG
                                || '";"' || crec.ID_FZGTYP
                                || '"'
                   );

         l_count   := l_count + 1;
      
      end loop;

      if   l_count = 0
      then o_FILE_RUNNING_NO := 0;
      else o_FILE_RUNNING_NO := 1;
      end  if;
      
      return 0;                                                     -- SUCCESS
   exception
      when others then
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );

         return -1;                                                    -- fail
   end expFIN;

   --------------------------------------------------------------------------------------------------------------------------------
   
   -- FraBe 18.03.2013  MKS-121684:1 add expInventoryList
   -- FraBe 20.03.2013  MKS-121685:1 add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden
   function expInventoryList ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                             , i_filehandle            UTL_FILE.file_type
                             , o_FILE_RUNNING_NO   OUT INTEGER )
      return number
   is

      l_count                        number;

   begin
   
      l_count   := 0;

      for crec in ( select
                      /* TID-400: Inventory list
                              author: markus zimmerberger, pauzenberger zimmerberger gesbr
                    
                              23.04.2003 11:47 creation
                              28.04.2003 BergerF: make some adaptions
                              05.05.2003 BergerF: include SAP DEBIT check
                                                  plus do not sumarize workshop invoice values where BELART_SHORTCAP = 'INF'
                                                  plus considerate SAP FWD, GUID_JOT = '12', as well
                              06.05.2003 BergerF: remove yesterdays change according BELART_SHORTCAP = 'INF'
                                                  plus remove the SAP WORKSHOP / DEBIT / FWD check
                                                  plus nvl of different amount values
                              12.01.2004 BergerF: MKS 7922 add date parameter 1 plus change value of "Status"
                              30.01.2003 BergerF: MKS 7922: compare the parameter date without time
                              07.03.2006 FraBe    MKS-25662: use TCUSTOMER_DOM.CUSTDOM_DOMNUMBER according TFZGV_CONTRACTS.GUID_CUSTOMER_DOM
                                                             instead of TFZGV_CONTRACTS.FZGVC_DOMICILIATION
                              11.04.2007 FraBe    MKS-38057:1 TID-1233 / 1243 neue Logik wegen I56
                              11.06.2008 FraBe    MKS-55743 REQ316 WOP1425 TID-1331: MKS 23094 nachziehen (- 18.11.2005 PBerger: MKS 23094: Fix Inventory-List-Exports (56) 2.1.0_h6 -)
                              24.07.2008 FraBe    MKS-56648:1 REQ320 WOP1504: do not show SPP Collective Invoices (-> fzgre.GUID_SPCI is null )
                              20.03.2013 FraBe    MKS-121685:1 add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden */
                           fzgv.ID_VERTRAG || '-' || fzgv.ID_FZGVERTRAG as Contract_Nr
                         , fzgv.ID_MANUFACTURE
                         , fzgv.FZGV_FGSTNR
                         , to_char ( get_BEGIN_DATE@SIMEX_DB_LINK ( fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG ), 'yyyymmdd' ) as Start_Date
                         , to_char ( get_END_DATE@SIMEX_DB_LINK   ( fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG ), 'yyyymmdd' ) as End_Date
                         , ( select to_char ( max ( dcc.DCBE_CRC_DATE ), 'yyyymmdd' )
                               from TDCBE_CLOSREOP_CONTRACT@SIMEX_DB_LINK dcc
                              where dcc.DCBE_CRC_ID_VERTRAG    = fzgv.ID_VERTRAG
                                and dcc.DCBE_CRC_ID_FZGVERTRAG = fzgv.ID_FZGVERTRAG
                                and dcc.DCBE_CRC_TYPE          = 'C'
                                and sysdate                   >= trunc ( dcc.DCBE_CRC_DATE ))  as Closing_SAP_Date
                         , DCBE_CLOSREOP_CONTRACT_STAT@SIMEX_DB_LINK ( fzgv.ID_VERTRAG , fzgv.ID_FZGVERTRAG, sysdate, substr ( cs.COS_CAPTION, 1, 3 )) as Status
                         , cust.ID_CUSTOMER
                         , cust.CUST_INVOICE_ADRESS
                         , cust.CUST_SAP_NUMBER_DEBITOR
                         , custdom.CUSTDOM_DOMNUMBER
                         , decode ( cs.COS_HANDLE_CUST_INV, 0, 'Y', 1, 'N' ) as Invoice_Y_N
                         , ( select nvl ( sum ( cinv.CI_AMOUNT * cur.CUR_RATE / cur.CUR_RATEFACTOR ), 0 )
                               from TCURRENCY@SIMEX_DB_LINK         cur
                                  , TBELEGARTEN@SIMEX_DB_LINK       belart
                                  , TCUSTOMER_INVOICE@SIMEX_DB_LINK cinv
                              where cur.ID_CURRENCY                = cinv.ID_CURRENCY
                                and fzgvc.ID_SEQ_FZGVC             = cinv.ID_SEQ_FZGVC
                                and belart.ID_BELEGART             = cinv.ID_BELEGART
                                and belart.BELART_INVOICE_OR_CNOTE = 0
                                and belart.BELART_SUM_INVOICE      = 1
                                and sysdate                       >= trunc ( cinv.CI_CREATED )
                                and exists
                                  ( select ''
                                      from TJOURNAL@SIMEX_DB_LINK j, TJOURNAL_POSITION@SIMEX_DB_LINK jp
                                     where jp.GUID_JOT     = '10'
                                       and jp.JOP_FOREIGN  = cinv.GUID_CI
                                       and jp.GUID_JO      = j.GUID_JO
                                       and jp.GUID_JOT     = j.GUID_JOT
                                       and sysdate        >= trunc ( j.JO_END )))     as SI_Customer_Invoices
                         , ( select nvl ( sum ( cinv.CI_AMOUNT * cur.CUR_RATE / cur.CUR_RATEFACTOR ), 0 )
                               from TCURRENCY@SIMEX_DB_LINK         cur
                                  , TBELEGARTEN@SIMEX_DB_LINK       belart
                                  , TCUSTOMER_INVOICE@SIMEX_DB_LINK cinv
                              where cur.ID_CURRENCY                = cinv.ID_CURRENCY
                                and fzgvc.ID_SEQ_FZGVC             = cinv.ID_SEQ_FZGVC
                                and belart.ID_BELEGART             = cinv.ID_BELEGART
                                and belart.BELART_INVOICE_OR_CNOTE = 1
                                and belart.BELART_SUM_INVOICE      = 1
                                and sysdate                       >= trunc ( cinv.CI_CREATED )
                                and exists
                                  ( select ''
                                      from TJOURNAL@SIMEX_DB_LINK j, TJOURNAL_POSITION@SIMEX_DB_LINK jp
                                     where jp.GUID_JOT     = '10'
                                       and jp.JOP_FOREIGN  = cinv.GUID_CI
                                       and jp.GUID_JO      = j.GUID_JO
                                       and jp.GUID_JOT     = j.GUID_JOT
                                       and sysdate        >= trunc ( j.JO_END )))     as SI_Credit_Notes
                         , ( select nvl ( sum ( cinv.CI_AMOUNT * cur.CUR_RATE / cur.CUR_RATEFACTOR * belart.BELART_SOLL_HABEN ), 0 )
                               from TCURRENCY@SIMEX_DB_LINK             cur
                                  , TBELEGARTEN@SIMEX_DB_LINK           belart
                                  , TCUSTOMER_INVOICE@SIMEX_DB_LINK     cinv
                                  , TCONTRACT_CAMPAIGN@SIMEX_DB_LINK    coc
                              where cur.ID_CURRENCY                  = cinv.ID_CURRENCY
                                and belart.BELART_SUM_INVOICE        = 1
                                and belart.ID_BELEGART               = cinv.ID_BELEGART
                                and fzgvc.ID_SEQ_FZGVC               = nvl ( cinv.ID_SEQ_FZGVC, null )
                                and nvl ( coc.GUID_CI, null )        = cinv.GUID_CI
                                and coc.CONCAMP_FLAG                 = 'Y'
                                and trunc ( coc.CONCAMP_DATE_SENT ) <= sysdate
                                and trunc ( coc.CONCAMP_CRE_DATE )  <= sysdate
                                and coc.GUID_CONTRACT                = fzgv.GUID_CONTRACT   )   as SI_Campaigns
                         , ( select nvl ( sum ( fzgre.FZGRE_RESUMME * fzgre.FZGRE_KURS ), 0 )
                               from TBELEGARTEN@SIMEX_DB_LINK  belart
                                  , TFZGRECHNUNG@SIMEX_DB_LINK fzgre
                              where fzgre.GUID_SPCI                is null
                                and fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
                                and belart.ID_BELEGART              = fzgre.ID_BELEGART
                                and belart.BELART_INVOICE_OR_CNOTE  = 0
                                and belart.BELART_SUM_INVOICE       = 1
                                and belart.BELART_SAP_INVOICE_TYPE in ( 0, 1, 3 )
                                and sysdate                        >= trunc ( fzgre.FZGRE_CREATED )
                                and (( belart.ID_BELEGART          in ( 88, 89 ))
                                  or ( belart.ID_BELEGART      not in ( 88, 89 ) and     exists
                                            ( select ''
                                                from TJOURNAL@SIMEX_DB_LINK j, TJOURNAL_POSITION@SIMEX_DB_LINK jp
                                               where jp.GUID_JOT    in ( '9', '12' )
                                                 and jp.JOP_FOREIGN  = to_char ( fzgre.ID_SEQ_FZGRECHNUNG )
                                                 and jp.GUID_JO      = j.GUID_JO
                                                 and jp.GUID_JOT     = j.GUID_JOT
                                                 and sysdate        >= trunc ( j.JO_END ))))) as CSI_Invoices
                         , ( select nvl ( sum ( fzgre.FZGRE_RESUMME * fzgre.FZGRE_KURS ), 0 )
                               from TBELEGARTEN@SIMEX_DB_LINK  belart
                                  , TFZGRECHNUNG@SIMEX_DB_LINK fzgre
                              where fzgre.GUID_SPCI                is null
                                and fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
                                and belart.ID_BELEGART              = fzgre.ID_BELEGART
                                and belart.BELART_INVOICE_OR_CNOTE  = 1
                                and belart.BELART_SUM_INVOICE       = 1
                                and belart.BELART_SAP_INVOICE_TYPE in ( 0, 1, 3 )
                                and sysdate                        >= trunc ( fzgre.FZGRE_CREATED )
                                and (( belart.ID_BELEGART          in ( 88, 89 ))
                                  or ( belart.ID_BELEGART      not in ( 88, 89 ) and     exists
                                            ( select ''
                                                from TJOURNAL@SIMEX_DB_LINK j, TJOURNAL_POSITION@SIMEX_DB_LINK jp
                                               where jp.GUID_JOT    in ( '9', '12' )
                                                 and jp.JOP_FOREIGN  = to_char ( fzgre.ID_SEQ_FZGRECHNUNG )
                                                 and jp.GUID_JO      = j.GUID_JO
                                                 and jp.GUID_JOT     = j.GUID_JOT
                                                 and sysdate        >= trunc ( j.JO_END )))))     as CSI_Credit_Notes
                         , ( select nvl ( sum ( fzgre.FZGRE_RESUMME * fzgre.FZGRE_KURS ), 0 )
                               from TBELEGARTEN@SIMEX_DB_LINK  belart
                                  , TFZGRECHNUNG@SIMEX_DB_LINK fzgre
                              where fzgre.GUID_SPCI                is null
                                and fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
                                and belart.ID_BELEGART              = fzgre.ID_BELEGART
                                and belart.BELART_INVOICE_OR_CNOTE  = 0
                                and belart.BELART_SUM_INVOICE       = 1
                                and belart.BELART_SAP_INVOICE_TYPE in ( 2, 4 )
                                and sysdate                        >= trunc ( fzgre.FZGRE_CREATED )
                                and (( belart.ID_BELEGART          in ( 88, 89 ))
                                  or ( belart.ID_BELEGART      not in ( 88, 89 ) and     exists
                                            ( select ''
                                                from TJOURNAL@SIMEX_DB_LINK j, TJOURNAL_POSITION@SIMEX_DB_LINK jp
                                               where jp.GUID_JOT    in ( '9', '12' )
                                                 and jp.JOP_FOREIGN  = to_char ( fzgre.ID_SEQ_FZGRECHNUNG )
                                                 and jp.GUID_JO      = j.GUID_JO
                                                 and jp.GUID_JOT     = j.GUID_JOT
                                                 and sysdate        >= trunc ( j.JO_END )))))  as CSI_Re_Invoicing
                      from TCUSTOMER_DOM@SIMEX_DB_LINK     custdom
                         , TCUSTOMER@SIMEX_DB_LINK         cust
                         , TDFCONTR_STATE@SIMEX_DB_LINK    cs
                         , TDFCONTR_VARIANT@SIMEX_DB_LINK  cvar
                         , TVERTRAGSTAMM@SIMEX_DB_LINK     vertr
                         , TFZGVERTRAG@SIMEX_DB_LINK       fzgv
                         , TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                     where fzgv.ID_COS                   = cs.ID_COS
                       and fzgv.ID_VERTRAG               = vertr.ID_VERTRAG
                       and fzgv.ID_VERTRAG               = fzgvc.ID_VERTRAG
                       and fzgv.ID_FZGVERTRAG            = fzgvc.ID_FZGVERTRAG
                       and cust.ID_CUSTOMER              = fzgvc.ID_CUSTOMER
                       and custdom.GUID_CUSTOMER_DOM (+) = fzgvc.GUID_CUSTOMER_DOM
                       and cvar.ID_COV                   = fzgvc.ID_COV
                       and cvar.COV_CAPTION       not like 'MIG_OOS%'
              order by fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG )
      loop
      
         if   l_count = 0  -- ausgabe Überschrift
         then spoolline ( i_filehandle,  '"Contract Nr"'
                                     || ';"Manufacture"'
                                     || ';"Chassis Nr"'
                                     || ';"Start date"'
                                     || ';"End date"'
                                     || ';"Closing SAP date"'
                                     || ';"Status"'
                                     || ';"Sirius Nr"'
                                     || ';"Sirius Nr (invoed to)"'
                                     || ';"SAP Nr"'
                                     || ';"DOM Nr"'
                                     || ';"Invoice Y/N"'
                                     || ';"SI Customer Invoices"'
                                     || ';"SI Credit Notes"'
                                     || ';"SI Campaigns"'
                                     || ';"CSI Invoices"'
                                     || ';"CSI Credit Notes"'
                                     || ';"CSI ReInvoicing"'
                        );
         end  if;

         spoolline ( i_filehandle,   '"' || crec.Contract_Nr
                                || '";"' || crec.ID_MANUFACTURE
                                || '";"' || crec.FZGV_FGSTNR
                                || '";"' || crec.Start_Date
                                || '";"' || crec.End_Date
                                || '";"' || crec.Closing_SAP_Date
                                || '";"' || crec.Status
                                || '";"' || crec.ID_CUSTOMER
                                || '";"' || crec.CUST_INVOICE_ADRESS
                                || '";"' || crec.CUST_SAP_NUMBER_DEBITOR
                                || '";"' || crec.CUSTDOM_DOMNUMBER
                                || '";"' || crec.Invoice_Y_N
                                || '";"' || crec.SI_Customer_Invoices
                                || '";"' || crec.SI_Credit_Notes
                                || '";"' || crec.SI_Campaigns
                                || '";"' || crec.CSI_Invoices
                                || '";"' || crec.CSI_Credit_Notes
                                || '";"' || crec.CSI_Re_Invoicing
                                || '"'
                   );

         l_count   := l_count + 1;
      
      end loop;

      if   l_count = 0
      then o_FILE_RUNNING_NO := 0;
      else o_FILE_RUNNING_NO := 1;
      end  if;
      
      return 0;                                                     -- SUCCESS
   exception
      when others then
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );

         return -1;                                                    -- fail
   end expInventoryList;

   --------------------------------------------------------------------------------------------------------------------------------

   FUNCTION expSalesman ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- MaZi  27.03.2013 MKS-123816:1 creation
      -- MaZi  23.05.2013 MKS-125778:1 consider case-sensitiv attribute-names and values
      -- TK    11.06.2013 MKS-126380 correction due to productive export
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expSalesman';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS' );    -- TK 11.06.2013 MKS-126380

      FUNCTION cre_salesman_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130228_CIM_EDF_PhysicalPerson(salesman)_Mig_BEL_inc3_iter1.2_v4.0(approved1stIter).xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' AS "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) AS "dateTime"
                                    , L_userID                        AS "userId"
                                    , L_COUNTRY_CODE                  AS "tenantId"
                                    , 'migration'                     AS "causation"
                                    , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                    , L_correlationID                 AS "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                  , XMLELEMENT ( "parameter"
                                                        , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                    AS "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               AS "xmlns:partner_pl"
                                                                , pck_calculation.get_part_of_bearbeiter_kauf
                                                                  (fzg.FZGV_BEARBEITER_KAUF, 3, fzg.id_vertrag || '/' || fzg.id_fzgvertrag)
                                                                                                                     AS "externalId"
                                                                , L_SourceSystem                                     AS "sourceSystem"
                                                                , '9'                                                AS "masterDataReleaseVersion"
                                                                , 'salesman'                                         AS "partnerType"
                                                                , pck_calculation.get_part_of_bearbeiter_kauf
                                                                  (fzg.FZGV_BEARBEITER_KAUF, 2)                      AS "firstName"
                                                                , pck_calculation.get_part_of_bearbeiter_kauf
                                                                  (fzg.FZGV_BEARBEITER_KAUF, 1)                      AS "lastName"
                                                                , pck_calculation.get_part_of_bearbeiter_kauf
                                                                  (fzg.FZGV_BEARBEITER_KAUF, 3, fzg.id_vertrag || '/' || fzg.id_fzgvertrag)
                                                                                                                     AS "dealerDirectoryUid"  
                                                                )))
                                order by rownum )
                                   from TFZGVERTRAG@SIMEX_DB_LINK    fzg
                                      , TXML_SPLIT                   x
                                  where fzg.GUID_CONTRACT = x.PK_VALUE_CHAR
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' salesmans' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' salesman nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_salesman_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      FOR crec IN ( select min(fzg.GUID_CONTRACT) GUID_CONTRACT, nvl(fzg.FZGV_BEARBEITER_KAUF, 'Salesman_' || fzg.ID_VERTRAG || '/' || fzg.ID_FZGVERTRAG)
                      from TFZGVERTRAG@SIMEX_DB_LINK      fzg
                         , TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                         , TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                     where cv.id_cov = fzgvc.id_cov
                       and cv.COV_CAPTION not like 'MIG_OOS%'
                       and upper(nvl(fzg.FZGV_BEARBEITER_KAUF, 'Salesman_' || fzg.ID_VERTRAG || '/' || fzg.ID_FZGVERTRAG)) not in ('SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020')
                       and fzg.ID_VERTRAG = fzgvc.ID_VERTRAG
                       and fzg.ID_FZGVERTRAG = fzgvc.ID_FZGVERTRAG
                     group by nvl(fzg.FZGV_BEARBEITER_KAUF, 'Salesman_' || fzg.ID_VERTRAG || '/' || fzg.ID_FZGVERTRAG)
                     order by 1 )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.GUID_CONTRACT );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_salesman_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_salesman_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expSalesman;
   
   --------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION expServiceContract ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- FraBe 10.06.2013 MKS-120788:1 creation
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 24.06.2013 MKS-120789:2 add call of pck_contract.ins_TFZGPREIS_SIMEX
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main              INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT VARCHAR2 (100) DEFAULT 'expServiceContract';
      l_xml                   XMLTYPE;
      l_xml_out               XMLTYPE;
      AlreadyLogged           EXCEPTION;
      PRAGMA EXCEPTION_INIT ( AlreadyLogged, -20000 );
      L_TIMESTAMP             TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                  VARCHAR2  (1) := NULL;
      L_ROWCOUNT              INTEGER;
      L_filename              VARCHAR2 (100 CHAR);
      L_DB_NAME_of_DB_LINK    varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_COUNTRY_CODE          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_TENANT_ID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem          TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'SIRIUS'   );
      L_correlationID         TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
      L_TargetDateCI          TSETTING.SET_VALUE%TYPE;
      L_LOCALE_SCURRENCY      TSETTING.SET_VALUE%TYPE;

      FUNCTION cre_ServiceContract_xml
         RETURN INTEGER
      IS
      BEGIN
         L_TargetDateCI      := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'Sirius', 'Setting', 'TargetDateCustomerInvoice' );
         L_LOCALE_SCURRENCY  := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'Sirius', 'Setting', 'LOCALE_SCURRENCY' );
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := REPLACE ( i_filename
                                        , '.xml', '' || TO_CHAR ( o_FILE_RUNNING_NO ) || '.xml' );
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20130522_CIM_EDF_ServiceContract_Mig_BEL_inc3_iter1.3_v6.2.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( SYSDATE , 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_COUNTRY_CODE                  as "tenantId"
                                    , 'migration'                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createServiceContract' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'contract_pl:CustomerContractType'                 as "xsi:type"
                                                                , 'http://contract.icon.daimler.com/pl'              as "xmlns:contract_pl"
                                                                , lpad ( vs.ID_VERTRAG, 8, '0' )                     as "number"
                                                                , vs.ID_VERTRAG                                      as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , '9'                                                as "masterDataReleaseVersion" )
                                                           , XMLELEMENT ( "contractingCustomer"
                                                                , xmlattributes
                                                                     ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                     , PCK_CONTRACT.IDcustLastDuration ( vs.ID_VERTRAG ) as "externalId"
                                                                     , L_SourceSystem                                    as "sourceSystem" ))
                                                           , XMLELEMENT ( "states"
                                                                , xmlattributes
                                                                     ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                  , L_TIMESTAMP
                                                                                                  , 'CUSTOMER_CONTRACT_STATE'
                                                                                                  , ' ' )            as "contractState"
                                                                     , PCK_CONTRACT.currentNoOfVehicleContracts ( vs.ID_VERTRAG ) as "currentNumberOfVehicleContracts" 
                                                                     , '00000000000000000000'                        as "termsAndConditionsCode" 
                                                                     , 'false'                                       as "volumeBusiness" )
                                                                , ( select XMLAGG ( XMLELEMENT ( "vehicleContract"
                                                                     , xmlattributes ( lpad ( fzgv.ID_VERTRAG,    8, '0' ) || '/' || 
                                                                                       lpad ( fzgv.ID_FZGVERTRAG, 6, '0' )                as "number"
                                                                                     , to_char ( fzgv.FZGV_CREATED, 'YYYYMMDD' )          as "activationDate"
                                                                                     , substr ( fzgv.FZGV_I55_VEH_SPEC_TEXT, 1, 255 )     as "contractInformationExternal"
                                                                                     , substr ( fzgvc_ende.FZGVC_MEMO,       1, 255 )     as "contractInformationInternal"
                                                                                     , fzgv.FZGV_NO_CUSTOMER                              as "fleetNumberExternal"
                                                                                     , PCK_CONTRACT.ServcieCardLastPrintDate ( fzgv.GUID_CONTRACT ) as "lastPrintDateServiceCard"
                                                                                     , fzgv.FZGV_SCARD_COUNT                              as "numberOfServiceCards"
                                                                                     , decode ( lpad ( fzgv.ID_VERTRAG_PARENT,    8, '0' ) 
                                                                                              , null, null  
                                                                                                    , lpad ( fzgv.ID_VERTRAG_PARENT,    8, '0' ) || '/' || 
                                                                                                      lpad ( fzgv.ID_FZGVERTRAG_PARENT, 6, '0' ))  as "previousVehicleContractNumber"
                                                                                     , 'false'                                            as "recalculationNecessary"
                                                                                     , 'false'                                            as "terminationInProgress"
                                                                                     , fzgv.ID_VERTRAG || '/' || fzgv.ID_FZGVERTRAG       as "externalId"
                                                                                     , L_SourceSystem                                     as "sourceSystem"
                                                                                     )
                                                                           , XMLELEMENT ( "activeStableState"
                                                                                     , xmlattributes ( to_char ( fzgvc_ende.FZGVC_ENDE,    'YYYYMMDD' )     as "plannedContractEnd"
                                                                                                     , to_char ( fzgvc_start.FZGVC_BEGINN, 'YYYYMMDD' )     as "start"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'CONTRACT_VARIANT_DEFINITION'
                                                                                                                                  , ' '        )                             as "contractVariantDefinition"
                                                                                                     , L_TargetDateCI                                                        as "customerFDDueDay"
                                                                                                     , PCK_CONTRACT.customerFDIssuedUntil ( fzgvc_ende.ID_SEQ_FZGVC
                                                                                                                                          , fzgvc_start.FZGVC_BEGINN
                                                                                                                                          , fzgvc_ende1.FZGVC_PREL_OR_FINAL_ENDE
                                                                                                                                          , paym.PAYM_MONTHS )               as "customerFDIssuedUntil"
                                                                                                     , to_char ( fzgv.FZGV_SIGNATURE_DATE, 'YYYYMMDD' )                      as "customerSignatureDate"
                                                                                                     , substr ( fzgv.FZGV_FINAL_CUSTOMER, 1, 100 )                           as "driver"
                                                                                                     , decode ( km_finEnd.FZGKM_KM
                                                                                                              , null, null
                                                                                                                    , PCK_CONTRACT.MileagesDiff ( km_finEnd.FZGKM_KM
                                                                                                                                                , fzgvc_ende.FZGVC_ENDE_KM
                                                                                                                                                , 'exceededMileage' ))       as "exceededMileage"
                                                                                                     , PCK_CONTRACT.nextCOindexDate ( L_TENANT_ID
                                                                                                                                    , cos.COS_ACTIVE
                                                                                                                                    , indv.INDV_TYPE
                                                                                                                                    , fzgvc_ende.FZGVC_IDX_NEXTDATE )        as "indexDate"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'INDV_TYPE'
                                                                                                                                  , indv.INDV_TYPE )                         as "indexDefinition"
                                                                                                     , decode ( indv.INDV_TYPE
                                                                                                              , 1, fzgvc_ende.FZGVC_IDX_PERCENT
                                                                                                                 , null )                                                    as "indexFactor"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'ID_PAYM'
                                                                                                                                  , paym.ID_PAYM )                           as "paymentInterval"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'PAYMM_CAPTION_SHORT'
                                                                                                                                  , paymm.PAYMM_CAPTION_SHORT )              as "paymentMethod"
                                                                                                     , round ( PCK_CONTRACT.PlanndCOmileage  ( fzgvc_start.FZGVC_BEGINN_KM
                                                                                                                                             , fzgvc_ende.FZGVC_ENDE_KM )
                                                                                                             / PCK_CONTRACT.days_between ( fzgvc_start.FZGVC_BEGINN
                                                                                                                                         , fzgvc_ende.FZGVC_ENDE )
                                                                                                             * 360, 0 )                                                      as "plannedContractAnnualMileage"
                                                                                                     , PCK_CONTRACT.days_between ( fzgvc_start.FZGVC_BEGINN
                                                                                                                                 , fzgvc_ende.FZGVC_ENDE )                   as "plannedContractDuration"
                                                                                                     , PCK_CONTRACT.PlanndCOmileage  ( fzgvc_start.FZGVC_BEGINN_KM
                                                                                                                                     , fzgvc_ende.FZGVC_ENDE_KM )            as "plannedContractTotalMileage"
                                                                                                     , fzgvc_ende.FZGVC_ENDE_KM                                              as "plannedVehicleMileageContractEnd"
                                                                                                     , PCK_CALCULATION.calc_boolean ( fzgvc_ende.FZGVC_SERVICE_CARD, 1, 0 )  as "printServiceCard"
                                                                                                     , PCK_CONTRACT.CO_GET_PRODUCT ( L_TENANT_ID )                           as "product"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'VI55AV_VALUE'
                                                                                                                                  , einsArtVal.VI55AV_VALUE )                as "productUsage"
                                                                                                     , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'ID_BRANCH_SSI'
                                                                                                                                  , branch.ID_BRANCH_SSI )                   as "productIndustry"
                                                                                                     , to_char ( km_finEnd.FZGKM_DATUM, 'YYYYMMDD' )                         as "realContractEnd"
                                                                                                     , km_finEnd.FZGKM_KM                                                    as "realContractTotalMileage"
                                                                                                     , 'migration'                                                           as "sourceSystem"
                                                                                                     , PCK_CALCULATION.calc_boolean ( fzgvc_ende.FZGVC_SPECIAL_CASE, 1, 0 )  as "specialCase"
                                                                                                     , fzgvc_ende.FZGVC_TOL_MEHRKM                                           as "toleranceExceededMileage"
                                                                                                     , fzgvc_ende.FZGVC_TOL_MEHRKMPROZ                                       as "toleranceExceededMileagePercentage"
                                                                                                     , fzgvc_ende.FZGVC_TOL_MINKM                                            as "toleranceUnusedMileage"
                                                                                                     , fzgvc_ende.FZGVC_TOL_MINKMPROZ                                        as "toleranceUnusedMileagePercentage"
                                                                                                     , PCK_CONTRACT.ChildCOtransferDate ( fzgv.ID_VERTRAG
                                                                                                                                        , fzgv.ID_FZGVERTRAG )               as "transferDate"
                                                                                                     , PCK_CONTRACT.MileagesDiff ( fzgvc_ende1.FZGVC_PREL_OR_FINAL_ENDE_KM
                                                                                                                                 , fzgvc_ende.FZGVC_ENDE_KM
                                                                                                                                 , 'unusedMileage' )                         as "unusedMileage"
                                                                                                     , PCK_CONTRACT.CO_revenue_amount ( fzgv.ID_VERTRAG
                                                                                                                                      , fzgv.ID_FZGVERTRAG
                                                                                                                                      , fzgvc_start.FZGVC_BEGINN
                                                                                                                                      , fzgvc_ende1.FZGVC_PREL_OR_FINAL_ENDE ) as "value"
                                                                                                     , PCK_CONTRACT.days_between ( nvl ( fzgv.FZGV_ERSTZULASSUNG, fzgvc_start.FZGVC_BEGINN )
                                                                                                                                 , fzgvc_start.FZGVC_BEGINN ) -1             as "vehicleAgeContractStart" )
                                                                                                     , XMLELEMENT ( "automotiveObject"
                                                                                                               , xmlattributes ( fzgv.ID_MANUFACTURE || fzgv.FZGV_FGSTNR     as "vin" ))
                                                                                                     , XMLELEMENT ( "coverage"
                                                                                                               , xmlattributes ( '0000'                                   as "code"
                                                                                                                               , 'true'                                   as "claimingViaClaimingSystem" 
                                                                                                                               , 'false'                                  as "commission"
                                                                                                                               , 'contractCoverage'                       as "coverageDefinition"
                                                                                                                               , 'false'                                  as "externalRisk"
                                                                                                                               , PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                               ( i_TAS_GUID
                                                                                                                                               , L_TIMESTAMP
                                                                                                                                               , 'ID_LLEINHEIT'
                                                                                                                                               , ll_start.ID_LLEINHEIT )  as "mileageUnit"
                                                                                                                               , 'MIGRATION'                              as "productCoverage"
                                                                                                                               , 'false'                                  as "specialCase" )
                                                                                                               , XMLELEMENT ( "period"
                                                                                                                         , xmlattributes ( PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                                         ( i_TAS_GUID
                                                                                                                                                         , L_TIMESTAMP
                                                                                                                                                         , 'ID_LLEINHEIT'
                                                                                                                                                         , ll_start.ID_LLEINHEIT )          as "mileageUnit"
                                                                                                                                         , to_char ( fzgvc_ende.FZGVC_ENDE, 'YYYYMMDD' )    as "plannedEndDate"
                                                                                                                                         , to_char ( km_finEnd.FZGKM_DATUM, 'YYYYMMDD' )    as "realEndDate" 
                                                                                                                                         , km_finEnd.FZGKM_KM                               as "realVehicleMileageCoverageEnd"
                                                                                                                                         , to_char ( fzgvc_start.FZGVC_BEGINN, 'YYYYMMDD' ) as "startFrom"
                                                                                                                                         , fzgvc_start.FZGVC_BEGINN_KM                      as "vehicleMileageCoverageStart" )))
                                                                                                     , XMLELEMENT ( "dealerAssignment"
                                                                                                               , xmlattributes ( garCO.GAR_GARNOVEGA         as "contractingWorkshopClaimingSystemId"
                                                                                                                               , garServ.GAR_GARNOVEGA       as "servicingWorkshopClaimingSystemId" )
                                                                                                               , XMLELEMENT ( "contractingWorkshop"
                                                                                                                         , xmlattributes ( fzgv.ID_GARAGE              as "externalId"
                                                                                                                                         , L_SourceSystem              as "sourceSystem" ))
                                                                                                               , XMLELEMENT ( "salesPerson"
                                                                                                                         , xmlattributes ( PCK_CALCULATION.get_part_of_bearbeiter_kauf
                                                                                                                                              ( fzgv.FZGV_BEARBEITER_KAUF, 3, fzgv.ID_VERTRAG || '/' || fzgv.ID_FZGVERTRAG )
                                                                                                                                                                       as "externalId"
                                                                                                                                         , L_SourceSystem              as "sourceSystem" ))
                                                                                                               , XMLELEMENT ( "servicingWorkshop"
                                                                                                                         , xmlattributes ( fzgv.ID_GARAGE_SERV         as "externalId"
                                                                                                                                         , L_SourceSystem              as "sourceSystem" )))
                                                                                                     , XMLELEMENT ( "individualVehicleContractSetting"
                                                                                                               , xmlattributes ( PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                           ( i_TAS_GUID
                                                                                                                                           , L_TIMESTAMP
                                                                                                                                           , 'CollectiveInvoiceLevel'
                                                                                                                                           , fzgvc_ende.FZGVC_INVOICE_CONSOLIDATION 
                                                                                                                                             || cust.CUST_INVOICE_CONS_METHOD )       as "collectiveInvoicing"
                                                                                                                                , PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                           ( i_TAS_GUID
                                                                                                                                           , L_TIMESTAMP
                                                                                                                                           , 'GroupedCollectiveInvocing'
                                                                                                                                           , ' ' )                                    as "groupedCollectiveInvoicing" )
                                                                                                                                , decode ( cust.ID_CUSTOMER, cust.CUST_INV_ADRESS_BALFIN
                                                                                                                                         , null, XMLELEMENT ( "alternativeBalancingReceiver"
                                                                                                                                                       , xmlattributes ( PCK_PARTNER.GET_CUST_xsi_PARTNER_TYPE
                                                                                                                                                                                   ( cust.CUST_INV_ADRESS_BALFIN ) as "xsi:type"
                                                                                                                                                                       , cust.CUST_INV_ADRESS_BALFIN     as "externalId"
                                                                                                                                                                       , L_SourceSystem                  as "sourceSystem" )))
                                                                                                                                , decode ( cust.ID_CUSTOMER, cust.CUST_INVOICE_ADRESS
                                                                                                                                         , null, XMLELEMENT ( "alternativeFDReceiver"
                                                                                                                                                       , xmlattributes ( PCK_PARTNER.GET_CUST_xsi_PARTNER_TYPE
                                                                                                                                                                                   ( cust.CUST_INVOICE_ADRESS )    as "xsi:type"
                                                                                                                                                                       , cust.CUST_INVOICE_ADRESS        as "externalId"
                                                                                                                                                                       , L_SourceSystem                  as "sourceSystem" ))))
                                                                                                     , decode ( km_FinEnd.FZGKM_KM
                                                                                                              , null, null
                                                                                                                     , XMLELEMENT ( "odometerAtRealEnd"
                                                                                                                               , xmlattributes ( km_FinEnd.FZGKM_KM                            as "mileage"
                                                                                                                                               , 'true'                                        as "calculationRelevant"
                                                                                                                                               , 'realMileageContractEnd'                      as "mileageState"
                                                                                                                                               , to_char ( km_FinEnd.FZGKM_DATUM, 'YYYYMMDD' ) as "readingDate"
                                                                                                                                               , 'external'                                    as "sourceDefinition"
                                                                                                                                               , 'migration'                                   as "sourceSystem"
                                                                                                                                               , 'true'                                        as "valid"                   )))
                                                                                                     , XMLELEMENT ( "odometerAtRealStart"
                                                                                                               , xmlattributes ( km_start.FZGKM_KM                             as "mileage"
                                                                                                                               , 'true'                                        as "calculationRelevant"
                                                                                                                               , 'mileageContractStart'                        as "mileageState"
                                                                                                                               , to_char ( km_start.FZGKM_DATUM, 'YYYYMMDD' )  as "readingDate"
                                                                                                                               , 'external'                                    as "sourceDefinition"
                                                                                                                               , 'migration'                                   as "sourceSystem"
                                                                                                                               , 'true'                                        as "valid"                   ))
                                                                                                     , ( select XMLAGG ( XMLELEMENT ( "vehicleContractProperty"
                                                                                                                                 , xmlattributes (( case when      vval.VI55AV_CAPTION  = 'Nein' 
                                                                                                                                                              or ( vval.VI55AV_CAPTION <> 'Biodiesel' and vval.VI55AV_IS_DEFAULT_VALUE = 1 ) 
                                                                                                                                                              then 'false'
                                                                                                                                                         else 'true'
                                                                                                                                                         end )                              as "active"
                                                                                                                                                 ,  PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                                                ( i_TAS_GUID
                                                                                                                                                                , L_TIMESTAMP
                                                                                                                                                                , 'VI55A_DISPLACEMENT'
                                                                                                                                                                , vatt.VI55A_DISPLACEMENT ) as "contractProperty"
                                                                                                                            )) order by vatt.VI55A_DISPLACEMENT )
                                                                                                               from TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK    vval
                                                                                                                  , TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK    vatt
                                                                                                                  , TVEGA_I55_CO@SIMEX_DB_LINK           vco
                                                                                                              where fzgv.GUID_CONTRACT       = vco.GUID_CONTRACT
                                                                                                                and vatt.GUID_VI55A          = vco.GUID_VI55A
                                                                                                                and vatt.VI55A_DISPLACEMENT in ( 116, 117, 118, 119, 120, 125, 126 )
                                                                                                                and vatt.GUID_VI55A          = vval.GUID_VI55A
                                                                                                                and vco.GUID_VI55AV          = vval.GUID_VI55AV )
                                                                                                     , ( select XMLAGG ( XMLELEMENT ( "vehicleContractRealPrice"
                                                                                                                                 , xmlattributes ( PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                                                ( i_TAS_GUID
                                                                                                                                                                , L_TIMESTAMP
                                                                                                                                                                , 'CUR_CODE'
                                                                                                                                                                , L_LOCALE_SCURRENCY )     as "countryCurrency"
                                                                                                                                                 , PCK_CALCULATION.SUBSTITUTE 
                                                                                                                                                                ( i_TAS_GUID
                                                                                                                                                                , L_TIMESTAMP
                                                                                                                                                                , 'ID_LLEINHEIT'
                                                                                                                                                                , fzgpr.ID_LLEINHEIT )     as "mileageUnit"
                                                                                                                                                 , to_char ( fzgpr.FZGPR_VON, 'YYYYMMDD' ) as "periodFrom"
                                                                                                                                                 , to_char ( fzgpr.FZGPR_BIS, 'YYYYMMDD' ) as "periodUntil"
                                                                                                                                                 , fzgpr.FZGPR_PREIS_GRKM                  as "realPriceCentPerMile"
                                                                                                                                                 , fzgpr.FZGPR_PREIS_MONATP                as "realPriceMonthly"
                                                                                                                                                 , fzgpr.FZGPR_ADD_MILEAGE                 as "exceededAmountPerMileage"
                                                                                                                                                 , fzgpr.FZGPR_LESS_MILEAGE                as "unusedAmountPerMileage"
                                                                                                                            )) order by fzgpr.FZGPR_VON )
                                                                                                               from TFZGPREIS_SIMEX          fzgpr
                                                                                                              where fzgv.ID_VERTRAG        = fzgpr.ID_VERTRAG
                                                                                                                and fzgv.ID_FZGVERTRAG     = fzgpr.ID_FZGVERTRAG )
                                                                                       )
                                                                           , XMLELEMENT ( "activeVolatileState"
                                                                                     , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                  , L_TIMESTAMP
                                                                                                                                  , 'ID_COS'
                                                                                                                                  , fzgv.ID_COS ) as "contractState" ))
                                                                                       )
                                                                          order by fzgv.ID_FZGVERTRAG )
                                                                           from TGARAGE@SIMEX_DB_LINK                 garCO
                                                                              , TGARAGE@SIMEX_DB_LINK                 garServ
                                                                              , TFZGKMSTAND@SIMEX_DB_LINK             km_FinEnd
                                                                              , TFZGKMSTAND@SIMEX_DB_LINK             km_start
                                                                              , TFZGLAUFLEISTUNG@SIMEX_DB_LINK        ll_start
                                                                              , TCUSTOMER@SIMEX_DB_LINK               cust
                                                                              , TDF_BRANCH@SIMEX_DB_LINK              branch
                                                                              , TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK     einsArtVal
                                                                              , TEINSATZART@SIMEX_DB_LINK             einsArt
                                                                              , TDFPAYMODE@SIMEX_DB_LINK              paym
                                                                              , TDF_PAYMENT_MODE@SIMEX_DB_LINK        paymm
                                                                              , TDF_INDEXATION_VARIANT@SIMEX_DB_LINK  indv
                                                                              , TDFCONTR_VARIANT@SIMEX_DB_LINK        cov
                                                                              , TDFCONTR_STATE@SIMEX_DB_LINK          cos
                                                                              , TFZGV_CONTRACTS@SIMEX_DB_LINK         fzgvc_start
                                                                              , TFZGV_CONTRACTS@SIMEX_DB_LINK         fzgvc_ende
                                                                              , TFZGVERTRAG@SIMEX_DB_LINK             fzgv
                                                                              ------------------------------------------------------------------------------------------------------------
                                                                              , ( select ende1.ID_VERTRAG
                                                                                       , ende1.ID_FZGVERTRAG
                                                                                       , ende1.ID_SEQ_FZGVC
                                                                                       , get_FINAL_END_DATE@SIMEX_DB_LINK ( ende1.ID_SEQ_FZGKMSTAND_END, ende1.FZGVC_ENDE )     as FZGVC_PREL_OR_FINAL_ENDE
                                                                                       , get_FINAL_KM@SIMEX_DB_LINK       ( ende1.ID_SEQ_FZGKMSTAND_END, ende1.FZGVC_ENDE_KM )  as FZGVC_PREL_OR_FINAL_ENDE_KM
                                                                                    from TFZGV_CONTRACTS@SIMEX_DB_LINK   ende1
                                                                                       , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_ende1
                                                                                   where cov_ende1.COV_CAPTION  not like 'MIG_OOS%' 
                                                                                     and cov_ende1.ID_COV              = ende1.ID_COV
                                                                                     and ende1.FZGVC_BEGINN           in ( select max ( ende2.FZGVC_BEGINN )
                                                                                                                             from TFZGV_CONTRACTS@SIMEX_DB_LINK   ende2
                                                                                                                                , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_ende2
                                                                                                                            where cov_ende2.COV_CAPTION  not like 'MIG_OOS%' 
                                                                                                                              and cov_ende2.ID_COV              = ende2.ID_COV
                                                                                                                              and ende1.ID_VERTRAG              = ende2.ID_VERTRAG
                                                                                                                              and ende1.ID_FZGVERTRAG           = ende2.ID_FZGVERTRAG )) fzgvc_ende1
                                                                              ------------------------------------------------------------------------------------------------------------
                                                                          where einsArtVal.GUID_VI55AV              = einsArt.GUID_VI55AV
                                                                            and fzgvc_ende.ID_EINSATZART            = einsArt.ID_EINSATZART
                                                                            and cov.COV_CAPTION              not like 'MIG_OOS%' 
                                                                            and fzgvc_ende.ID_COV                   = cov.ID_COV
                                                                            and fzgvc_ende.ID_COV                   = cos.ID_COs
                                                                            and fzgvc_ende.GUID_BRANCH              = branch.GUID_BRANCH (+)
                                                                            and fzgvc_ende.ID_CUSTOMER              = cust.ID_CUSTOMER
                                                                            and fzgvc_ende.ID_PAYM                  = paym.ID_PAYM
                                                                            and fzgvc_ende.GUID_PAYMENT_MODE        = paymm.GUID_PAYMENT_MODE
                                                                            and fzgvc_ende.GUID_INDV                = indv.GUID_INDV
                                                                            and fzgvc_ende.ID_SEQ_FZGKMSTAND_END    = km_FinEnd.ID_SEQ_FZGKMSTAND (+)
                                                                            and fzgvc_ende1.ID_VERTRAG              = fzgvc_ende.ID_VERTRAG
                                                                            and fzgvc_ende1.ID_FZGVERTRAG           = fzgvc_ende.ID_FZGVERTRAG
                                                                            and fzgvc_ende1.ID_SEQ_FZGVC            = fzgvc_ende.ID_SEQ_FZGVC
                                                                            and fzgvc_ende1.ID_VERTRAG              = fzgv.ID_VERTRAG
                                                                            and fzgvc_ende1.ID_FZGVERTRAG           = fzgv.ID_FZGVERTRAG
                                                                            and fzgvc_start.ID_SEQ_FZGKMSTAND_BEGIN = km_start.ID_SEQ_FZGKMSTAND
                                                                            and fzgvc_start.ID_SEQ_FZGVC            = ll_start.ID_SEQ_FZGVC (+)
                                                                            and fzgvc_start.ID_VERTRAG              = fzgv.ID_VERTRAG
                                                                            and fzgvc_start.ID_FZGVERTRAG           = fzgv.ID_FZGVERTRAG
                                                                            and fzgvc_start.FZGVC_BEGINN           in ( select min ( start2.FZGVC_BEGINN )
                                                                                                                          from TFZGV_CONTRACTS@SIMEX_DB_LINK   start2
                                                                                                                             , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_start2
                                                                                                                         where cov_start2.COV_CAPTION   not like 'MIG_OOS%' 
                                                                                                                           and cov_start2.ID_COV               = start2.ID_COV
                                                                                                                           and fzgvc_start.ID_VERTRAG          = start2.ID_VERTRAG
                                                                                                                           and fzgvc_start.ID_FZGVERTRAG       = start2.ID_FZGVERTRAG )
                                                                            and vs.ID_VERTRAG                       = fzgv.ID_VERTRAG
                                                                            and garCO.ID_GARAGE                     = fzgv.ID_GARAGE
                                                                            and garServ.ID_GARAGE                   = fzgv.ID_GARAGE_SERV )
                                                                )))
                                  order by rownum )
                                   from TVERTRAGSTAMM@SIMEX_DB_LINK      vs
                                      , TXML_SPLIT                       s
                                  where vs.ID_VERTRAG           = s.PK_VALUE_CHAR
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;
           
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' ServiceContracts' );


         printxmltofile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' ServiceContract nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_ServiceContract_xml;
   BEGIN                                                          -- main part

      pck_contract.ins_TFZGPREIS_SIMEX;

      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      for crec in ( select vs.ID_VERTRAG
                      from TVERTRAGSTAMM@SIMEX_DB_LINK vs
                     where exists ( select null 
                                      from TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                                         , TDFCONTR_VARIANT@SIMEX_DB_LINK  cov
                                     where vs.ID_VERTRAG          = fzgvc.ID_VERTRAG
                                       and cov.ID_COV             = fzgvc.ID_COV
                                       and cov.COV_CAPTION not like 'MIG_OOS%' )
                    -- and rownum < 2000
                  order by ID_VERTRAG )

      loop
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              values ( crec.ID_VERTRAG );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_ServiceContract_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_ServiceContract_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gelöscht, weil sie mit on commit delete rows definiert ist

         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
      END IF;

      RETURN l_ret_main;
   EXCEPTION
      WHEN AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expServiceContract;

      
END PCK_EXPORTS;
/

update TSUBSTITUTE
   set SUB_ICO_ATT_VALUE = 'alternativeFuelType'
 where SUB_SRS_ATT_NAME  = 'VI55A_DISPLACEMENT'
   and SUB_SRS_ATT_VALUE = '116';