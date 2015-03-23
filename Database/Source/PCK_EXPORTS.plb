CREATE OR REPLACE PACKAGE BODY PCK_EXPORTS
IS
   --
   --
   -- MKSSTART
   --
   -- $CompanyInfo $
   --
   -- $Date: 2015/03/12 14:40:30MEZ $
   --
   -- $Name:  $
   --
   -- $Revision: 1.89 $
   --
   -- $Header: 5100_Code_Base/Database/Source/PCK_EXPORTS.plb 1.89 2015/03/12 14:40:30MEZ Zimmerberger, Markus (zimark) CI_Changed  $
   --
   -- $Source: 5100_Code_Base/Database/Source/PCK_EXPORTS.plb $
   --
   -- $Log: 5100_Code_Base/Database/Source/PCK_EXPORTS.plb  $
   -- Revision 1.89 2015/03/12 14:40:30MEZ Zimmerberger, Markus (zimark) 
   -- expInventoryList: Show SPP Collective Invoices as well
   -- Revision 1.88 2015/03/06 16:10:09MEZ Frank, Marina (marinf) 
   -- MKS-136487:1 VEGA Mappinglist: Fixed excessive messaging for integrated contracts.
   -- Revision 1.87 2015/02/19 20:12:19MEZ Frank, Marina (marinf) 
   -- MKS-136487 Reimplemented Vega Mapping List export.
   -- Revision 1.86 2015/02/02 16:26:28MEZ Zimmerberger, Markus (zimmerb) 
   -- enhanced logging for CSV-exports
   -- Revision 1.85 2015/01/08 09:49:46MEZ Zimmerberger, Markus (zimmerb) 
   -- Add expVEGAMappingList
   -- Revision 1.84 2014/09/16 10:27:48MESZ Kieninger, Tobias (tkienin) 
   -- merging Branch
   -- Revision 1.83.1.1 2014/07/23 14:13:22MESZ Zuhl, Marco (marzuhl) 
   -- Änderung Export Licensed in: B anstatt BE
   -- Revision 1.83.1.1 2014/07/23 14:30:00MESZ Zuhl, Marco (marzuhl)
   -- Änderung Export Licensed in: B anstatt BE 
   -- Revision 1.83 2014/06/18 13:30:51MESZ Kieninger, Tobias (tkienin) 
   -- .
   -- Revision 1.82 2014/06/04 13:31:46MESZ Berger, Franz (fraberg) 
   -- expFIN: ein and exists löst PCK_CALCULATION.get_last_lic ab
   -- plus: diese logik erstreckt sich jetzt generell auf alle columns, und nicht nur auf get last kennzeichen wie vorher
   -- Revision 1.81 2014/03/04 15:44:34MEZ Berger, Franz (fraberg) 
   -- implement CR#10 within ExpFIN
   -- Revision 1.80 2013/11/27 07:19:48MEZ Berger, Franz (fraberg) 
   -- expFIN: rename some columns and add some new columns
   -- Revision 1.79 2013/11/18 10:31:59MEZ Berger, Franz (fraberg) 
   -- move to PCK_CONTRACT:
   -- - expALL_ODOMETER
   -- Revision 1.78 2013/11/16 07:35:50MEZ Berger, Franz (fraberg) 
   -- move ... to PCK_PARTNER:
   -- - expPrivateCustomer
   -- - expCommercialCustomer
   -- - expContactPerson
   -- - expWorkshop
   -- - expSupplier
   -- - expSalesman
   -- 
   -- move ... to PCK_CONTRACT:
   -- - expServiceContract
   -- - expALL_CONTRACTS
   -- 
   -- move ... to PCK_COST:
   -- - expWorkshopInvoice
   -- 
   -- move ... to PCK_REVENUE:
   -- - expRevenue
   -- Revision 1.77 2013/11/15 14:35:59MEZ Berger, Franz (fraberg) 
   -- expALL_ODOMETER: korrektur falsche auswahl
   -- Revision 1.76 2013/11/14 10:56:11MEZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice: new i_taxation logic
   -- Revision 1.75 2013/11/13 15:18:26MEZ Zimmerberger, Markus (zimmerb) 
   -- add attributes
   -- Revision 1.74 2013/11/12 16:47:04MEZ Zimmerberger, Markus (zimmerb) 
   -- Add expRevenue (initial)
   -- Revision 1.73 2013/11/06 12:10:19MEZ Zimmerberger, Markus (zimmerb) 
   -- consider odometers in tfzgrechnung
   -- Revision 1.72 2013/11/05 14:55:46MEZ Zimmerberger, Markus (zimmerb) 
   -- scope exported odometers especially
   -- Revision 1.71 2013/11/05 13:17:35MEZ Zimmerberger, Markus (zimmerb) 
   -- Implement missing nodes
   -- Revision 1.70 2013/11/05 07:27:43MEZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice: 
   -- - rename damageCollections to activeDamageCollection
   -- - rename states to activeState plus neue position gleich nach damage
   -- - costDamageCoverage mappt auf costDamageCoverage_il - http://common.icon.daimler.com/il und nicht auf costDamageCoverageCollection ...
   -- Revision 1.69 2013/11/04 15:13:34MEZ Berger, Franz (fraberg) 
   -- some small changes during test
   -- Revision 1.68 2013/10/31 16:48:13MEZ Zimmerberger, Markus (zimmerb) 
   -- add get_costDamage_COV, add dynamical parameter-types, aos...
   -- Revision 1.67 2013/10/31 16:18:37MEZ Zimmerberger, Markus (zimmerb) 
   -- make it more scheme-conform
   -- Revision 1.66 2013/10/31 14:27:27MEZ Berger, Franz (fraberg) 
   -- expWorkshopInvoice: add neuen code
   -- Revision 1.65 2013/10/29 16:57:02MEZ Zimmerberger, Markus (zimmerb) 
   -- Fix preparation-select
   -- Revision 1.64 2013/10/24 07:42:35MESZ Pauzenberger, Christian (cpauzen) 
   -- MKS-124191:1  Pauzi 24.10.2013 new: addOdometer
   -- Revision 1.63 2013/10/22 18:10:12MESZ Zimmerberger, Markus (zimmerb) 
   -- add expWorkshopInvoice (draft)
   -- Revision 1.62 2013/10/22 15:24:45MESZ Berger, Franz (fraberg) 
   -- expServiceContract: add XMLCOMMENT ( 'ORA-20700 ...' )
   -- Revision 1.61 2013/10/17 13:49:40MESZ Berger, Franz (fraberg) 
   -- - expALL_ODOMETER: some small changes (-> change l_filename logic / add xmlns:xsd definition )
   -- - all: do not use L_COUNTRY_CODE as "tenantId" anymore / use instead  all times: L_TENANT_ID as "tenantId"
   -- Revision 1.60 2013/10/11 12:15:16MESZ Pauzenberger, Christian (cpauzen) 
   -- Odometer - Korrekturen
   -- Revision 1.59 2013/10/10 20:04:57MESZ Berger, Franz (fraberg) 
   -- expServiceContract: fix bug - do not join ID_COV = ID_COS
   -- Revision 1.58 2013/10/10 15:57:29MESZ Berger, Franz (fraberg) 
   -- expServiceContract: add IN parameter paym.PAYM_TARGETDATE_CI within calling of PCK_CONTRACT.CO_REVENUE_AMOUNT
   -- Revision 1.57 2013/10/09 16:05:15MESZ Pauzenberger, Christian (cpauzen) 
   -- Odometer: modification based on AnDe
   -- Revision 1.56 2013/09/30 17:06:33MESZ Zimmerberger, Markus (zimmerb) 
   -- expSalesman: Vermeide doppelte ExternalIDs
   -- Revision 1.55 2013/07/25 16:30:03MESZ Berger, Franz (fraberg) 
   -- expSalesman: exclude GARAGE
   -- Revision 1.54 2013/07/25 15:06:11MESZ Kieninger, Tobias (tkienin) 
   -- Always fill in most actual License Plate in LISTOFFIN
   -- Revision 1.52 2013/07/23 06:32:52MESZ Berger, Franz (fraberg) 
   -- expWorkshop: export node contactPartnerAssignment: exclude some TFZGVERTRAG.FZGV_BEARBEITER_KAUF values
   -- Revision 1.51 2013/07/22 18:25:19MESZ Berger, Franz (fraberg) 
   -- expSalesman: neue ins into TXML_SPLIT logik: jene mit ID zwischen / nicht zwischen () extra
   -- Revision 1.50 2013/07/22 15:43:46MESZ Berger, Franz (fraberg) 
   -- expWorkshop: export node contactPartnerAssignment only if TFZGVERTRAG.FZGV_BEARBEITER_KAUF is not null
   -- Revision 1.49 2013/06/29 10:21:44MESZ Berger, Franz (fraberg) 
   -- - use CO beginndate in case of missing erstzulassung
   -- - extract odometerAtRealEnd only if the CO has a final end date
   -- - use ll - outerJoin to extract CO with missing ll data as well
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
   -- FraBe       22.07.2013  MKS-127399:1 / expWorkshop: export node contactPartnerAssignment only if TFZGVERTRAG.FZGV_BEARBEITER_KAUF is not null
   -- FraBe       22.07.2013  MKS-127398:1 / expSalesman: neue ins into TXML_SPLIT logik: jene mit ID zwischen / nicht zwischen () extra
   -- FraBe       22.07.2013  MKS-127399:2 / expWorkshop: export node contactPartnerAssignment: exclude some TFZGVERTRAG.FZGV_BEARBEITER_KAUF values
   -- TK/FraBe    25.07.2013  MKS-123315:1 / 127507:2 / expSalesman: exclude GARAGE
   -- ZBerger     30.09.2013  MKS-128076:1 / expSalesman: Vermeide doppelte ExternalIDs
   -- CP          09.10.2013  MKS-124188:1 / expALL_ODOMETER: modification based on AnDe
   -- FraBe       10.10.2013  MKS-126869:1 / expServiceContract: add IN parameter paym.PAYM_TARGETDATE_CI within calling of PCK_CONTRACT.CO_REVENUE_AMOUNT
   -- FraBe       10.10.2013  MKS-128875:1 / expServiceContract: fix bug - do not join ID_COV = ID_COS
   -- CP          11.10.2013  MKS-124188:1 / expALL_ODOMETER: modification based on AnDe
   -- FraBe       14.10.2013  MKS-124191:1 / expALL_ODOMETER: some small changes (-> change l_filename logic / add xmlns:xsd definition )
   -- FraBe       14.10.2013  MKS-124191:1 / all: do not use L_COUNTRY_CODE as "tenantId" anymore / use instead  all times: L_TENANT_ID as "tenantId"
   -- FraBe       22.10.2013  MKS-126869:1 / expServiceContract: add XMLCOMMENT ( 'ORA-20700 ...' )
   -- ZBerger     22.10.2013  MKS-121600:1 / expWorkshopInvoice: Creation
   -- CP          24.10.2013  MKS-124191:1 / Pauzi 24.10.2013 new: addOdometer
   -- ZBerger     17.10.2013  MKS-121600:1 add expWorkshopInvoice
   -- FraBe       31.10.2013  MKS-121600:2 / expWorkshopInvoice: add neuen code
   -- FraBe       05.11.2013  MKS-121600:2 / expWorkshopInvoice: 
   --                                      - rename damageCollections to activeDamageCollection
   --                                      - rename states to activeState plus neue position gleich nach damage
   --                                      - costDamageCoverage mappt auf costDamageCoverage_il - http://common.icon.daimler.com/il
   --                                        und nicht auf costDamageCoverageCollection ...
   -- FraBe       13.11.2013  MKS-121600:2 / expWorkshopInvoice: new i_taxation logic
   -- FraBe       15.11.2013  MKS-124188:5 / expALL_ODOMETER: korrektur falsche auswahl
   -- FraBe       26.11.2013  MKS-128845:1 / expFIN: rename some columns and add some new columns
   -- FraBe       04.03.2014  MKS-131048:1 / expFIN: implement CR#10 lt ANDE
   -- FraBe       04.06.2014  MKS-132838:1 / expFIN: ein and exists löst PCK_CALCULATION.get_last_lic ab
   -- ZBerger     22.12.2014  MKS-135606:2 add expVEGAMappingList
   -- ZBerger     02.02.2015  MKS-136002:2 enhanced logging for CSV-exports
   -- ZBerger     12.03.2015  MKS-151934:1 / expInventoryList: Show SPP Collective Invoices as well
   G_TAS_GUID         simex.TTASK.TAS_GUID%type;
   v_filehandle       UTL_FILE.file_type;
   v_filename         varchar2 ( 100 char );
   l_ret              NUMBER;
   
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

   FUNCTION chk_and_open_file
     ( o_filehandle   out UTL_FILE.file_type
     , i_export_path  VARCHAR2
     , i_filename     VARCHAR2 )
   RETURN NUMBER IS
      l_ret            integer := 0;
      l_fexist         BOOLEAN;
      l_file_length    NUMBER;
      l_block_size     NUMBER;
    begin
        -- folgender code wird nur bei csv ausgabe benötigt
        -- da wir nur xml haben, ist dieser code höchstwahrscheinlich obsolete - kann eventuell gelöscht werden
        -- check if file exists -> overwrite

        UTL_FILE.fgetattr ( i_export_path
                          , i_filename
                          , l_fexist
                          , l_file_length
                          , l_block_size
                          );
                          
        IF   l_fexist
        THEN
          UTL_FILE.FREMOVE ( i_export_path, i_filename );
        END IF;
        -- Open File
        o_filehandle := UTL_FILE.fopen ( i_export_path
                                       , i_filename
                                       , 'W'
                                       , 32740
                                       );
        return 0;   ---> success

    exception when others then pck_exporter.SiMEXlog ( i_TAS_GUID   => G_TAS_GUID
                                        , i_LOG_ID     => '0006'     -- cre / open of file failed
                                        , i_LOG_TEXT   => SQLERRM );
                               return -1;        ---> fail
    end;

   FUNCTION expALL_CUSTOMERS ( i_TAS_GUID            TTASK.TAS_GUID%TYPE
                             , i_export_path         VARCHAR2
                             , i_filename            VARCHAR2
                             , i_TAS_MAX_NODES       INTEGER
                             , o_FILE_RUNNING_NO OUT INTEGER
                             )
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

      l_count   NUMBER:=0;

   BEGIN
      G_TAS_GUID := i_TAS_GUID;
      o_FILE_RUNNING_NO := 0;
      v_filename:= replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO + 1, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
      
      l_ret := chk_and_open_file ( v_filehandle, i_export_path, v_filename);

      IF l_ret  = 0 THEN
        
        spoolline ( v_filehandle, '<ALL_CUSTOMER>' );

        FOR rcur IN curALL_CUSTOMERS
        LOOP
           if l_count = 0 THEN
             o_FILE_RUNNING_NO := o_FILE_RUNNING_NO + 1;
             PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                   , i_LOG_ID     => '0013'
                                   , i_LOG_TEXT   => 'for unknown number of customer(s)');
           end if;
           
           spoolline ( v_filehandle, '<RECORD>' );

           spoolline ( v_filehandle,' <Field1>' || rcur.SUB_GUID          || '</Field1>' );
           spoolline ( v_filehandle,' <Field2>' || rcur.SUB_SRS_ATT_NAME  || '</Field2>' );
           spoolline ( v_filehandle,' <Field3>' || rcur.SUB_SRS_ATT_VALUE || '</Field3>' );
           spoolline ( v_filehandle,' <Field4>' || rcur.SUB_ICO_ATT_VALUE || '</Field4>' );
           spoolline ( v_filehandle,' <Field5>' || rcur.SUB_DEFAULT       || '</Field5>' );

           spoolline ( v_filehandle, '</RECORD>');

           l_count   := l_count + 1;
        END LOOP;

        spoolline ( v_filehandle, '</ALL_CUSTOMER>' );
        
        UTL_FILE.FCLOSE ( v_filehandle );
            

        PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                              , i_LOG_ID     => '0014'            -- write file finished
                              , i_LOG_TEXT   => TO_CHAR(l_count)||' Contract nodes successfully written to file '||v_filename );

        RETURN 0;                                                     -- success
      ELSE
        RETURN l_ret;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );

         RETURN -1;                                                    -- fail
   END;

  --------------------------------------------------------------------------------------------------------------------------------
   
   function expMigScopeCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                                , i_filehandle            UTL_FILE.file_type
                                , o_FILE_RUNNING_NO   OUT INTEGER
                                , i_filename              VARCHAR2 )
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

            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                  , i_LOG_ID     => '0013'
                                  , i_LOG_TEXT   => 'for unknown number of customer(s)');

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

      PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                            , i_LOG_ID     => '0014'            -- write file finished
                            , i_LOG_TEXT   => TO_CHAR(l_count)||' entries written to file '||i_filename );

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
   -- FraBe 2013-11-26 MKS-128845:1 rename some columns and add some new columns
   -- FraBe 2014-03-04 MKS-131048:1 implement CR#10 lt ANDE
   -- FraBe 2014-06-04 MKS-132838:1 ein and exists löst PCK_CALCULATION.get_last_lic ab
   --                               plus: diese logik erstreckt sich jetzt generell auf alle columns, und nicht nur auf get last kennzeichen wie vorher

   function expFIN ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                   , i_filehandle            UTL_FILE.file_type
                   , o_FILE_RUNNING_NO   OUT INTEGER
                   , i_filename              VARCHAR2 )
      return number
   is

      l_count            number;
      L_COUNTRY_CODE     TGLOBAL_SETTINGS.VALUE@SIMEX_DB_LINK%type := get_TGLOBAL_SETTINGS@SIMEX_DB_LINK ( 'SIRIUS', 'Setting', 'MPCName' );

   begin
   
      l_count   := 0;

      for crec in ( select distinct 
                           fzgv.ID_MANUFACTURE
                         , fzgv.FZGV_FGSTNR
                         , fzgv.ID_MANUFACTURE || fzgv.FZGV_FGSTNR         as VIN
                         , fzgv.FZGV_KFZKENNZEICHEN
                         , to_char ( fzgv.FZGV_ERSTZULASSUNG, 'YYYYMMDD' ) as FZGV_ERSTZULASSUNG
                         , fzgv.ID_FZGTYP
                         , manu.MANU_CAPTION
                         ,REPLACE (
                            REPLACE (
                               REPLACE (
                                  REPLACE (
                                     REPLACE (
                                        REPLACE (
                                           REPLACE (
                                              REPLACE (
                                                 REPLACE (
                                                    REPLACE (
                                                       NVL (
                                                          (SELECT VI55AV_VALUE
                                                             FROM TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK av,
                                                                  TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK a,
                                                                  TVEGA_I55_CO@SIMEX_DB_LINK vco
                                                            WHERE     vco.GUID_CONTRACT =
                                                                         fzgv.GUID_CONTRACT
                                                                  AND vco.GUID_VI55AV =
                                                                         av.GUID_VI55AV
                                                                  AND vco.GUID_VI55A =
                                                                         av.GUID_VI55A
                                                                  AND vco.GUID_VI55A =
                                                                         a.GUID_VI55A
                                                                  AND 157 =
                                                                         a.VI55A_DISPLACEMENT),
                                                          '*'),
                                                       '1',
                                                       'upTo_3_5'),
                                                    'A',
                                                    'upTo_3_5'),
                                                 '2',
                                                 'upTo_7_5'),
                                              'B',
                                              'upTo_7_5'),
                                           '3',
                                           ' upTo_10'),
                                        'C',
                                        ' upTo_10'),
                                     '4',
                                     'upTo_12'),
                                  'D',
                                  'upTo_12'),
                               '5',
                               'largerThan_12'),
                            'E',
                            'largerThan_12')
                            AS manualTonnage                    -- Anhaenger-/Aufliegergewicht
                         ,REPLACE (
                            REPLACE (
                               REPLACE (
                                  REPLACE (
                                     REPLACE (
                                        REPLACE (
                                           REPLACE (
                                              REPLACE (
                                                 REPLACE (
                                                    REPLACE (
                                                       NVL (
                                                          (SELECT VI55AV_VALUE
                                                             FROM TVEGA_I55_ATT_VALUE@SIMEX_DB_LINK av,
                                                                  TVEGA_I55_ATTRIBUTE@SIMEX_DB_LINK a,
                                                                  TVEGA_I55_CO@SIMEX_DB_LINK vco
                                                            WHERE     vco.GUID_CONTRACT =
                                                                         fzgv.GUID_CONTRACT
                                                                  AND vco.GUID_VI55AV =
                                                                         av.GUID_VI55AV
                                                                  AND vco.GUID_VI55A =
                                                                         av.GUID_VI55A
                                                                  AND vco.GUID_VI55A =
                                                                         a.GUID_VI55A
                                                                  AND 127 =
                                                                         a.VI55A_DISPLACEMENT),
                                                          '*'),
                                                       '1',
                                                       'semiTrailerEinAchser'),
                                                    'A',
                                                    'trailerEinAchser'),
                                                 '2',
                                                 'semiTrailerZweiAchser'),
                                              'B',
                                              'trailerZweiAchser'),
                                           '3',
                                           'semiTrailerDreiAchser'),
                                        'C',
                                        'trailerDreiAchser'),
                                     '4',
                                     'semiTrailerVierAchser'),
                                  'D',
                                  'trailerVierAchser'),
                               '5',
                               'semiTrailerVielAchser'),
                            'E',
                            'trailerVielAchser')
                            AS manualNumberOfAxles        -- Anzahl Anhaenger-/Aufliegerachsen
                         , decode ( L_COUNTRY_CODE, 'MBBeLux', 'B',         null ) as licensedIn 
                         , decode ( L_COUNTRY_CODE, 'MBBeLux', 'kilometres', null ) as mileageUnit  
                      from TFZGVERTRAG@SIMEX_DB_LINK         fzgv
                         , TFZGV_CONTRACTS@SIMEX_DB_LINK     fzgvc
                         , TDFCONTR_VARIANT@SIMEX_DB_LINK    cvar
                         , TMANUFACTURE@SIMEX_DB_LINK        manu
                     where fzgv.ID_MANUFACTURE      = manu.ID_MANUFACTURE
                       and fzgv.ID_VERTRAG          = fzgvc.ID_VERTRAG
                       and fzgv.ID_FZGVERTRAG       = fzgvc.ID_FZGVERTRAG
                       and cvar.ID_COV              = fzgvc.ID_COV
                       and cvar.COV_CAPTION  not like 'MIG_OOS%'
                       and exists ( select null                                         -- -> MKS-132838: das löst die function PCK_CALCULATION.get_last_lic ab
                                      from TFZGVERTRAG@simex_db_link         fzgv1
                                         , TFZGV_CONTRACTS@simex_db_link     fzgvc1
                                         , TDFCONTR_VARIANT@simex_db_link    cvar1
                                     where fzgv1.ID_MANUFACTURE      = fzgv.ID_MANUFACTURE
                                       and fzgv1.FZGV_FGSTNR         = fzgv.FZGV_FGSTNR
                                       and fzgv1.ID_VERTRAG          = fzgvc1.ID_VERTRAG
                                       and fzgv1.ID_FZGVERTRAG       = fzgvc1.ID_FZGVERTRAG
                                       and cvar1.ID_COV              = fzgvc1.ID_COV
                                       and cvar1.COV_CAPTION  not like 'MIG_OOS%'
                                    having max ( to_number  ( to_char ( fzgvc1.FZGVC_BEGINN, 'YYYYMMDD' ) || trim ( to_char ( fzgvc1.ID_SEQ_FZGVC, '00000000000000000000' ))))
                                           =     to_number  ( to_char ( fzgvc.FZGVC_BEGINN,  'YYYYMMDD' ) || trim ( to_char ( fzgvc.ID_SEQ_FZGVC,  '00000000000000000000' )))) 
                      order by 1, 2, 3 )
       loop
      
         if   l_count = 0  -- ausgabe Überschrift
         then spoolline ( i_filehandle,  '"worldManufactureCode"'
                                     || ';"Chassis Nr"'
                                     || ';"VIN"'
                                     || ';"licensePlate"'
                                     || ';"firstRegistrationDate"'
                                     || ';"AutomotiveObjectForeign.manualSalesDescription"'
                                     || ';"AutomotiveObject.manualBrandCode"'
                                     || ';"AutomotiveObject.manualTonnage"'
                                     || ';"AutomotiveObject.manualNumberOfAxles"'
                                     || ';"licensedIn"'
                                     || ';"mileageUnit"'
                        );

            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                  , i_LOG_ID     => '0013'
                                  , i_LOG_TEXT   => 'for unknown number of FIN(s)');

         end  if;

         spoolline ( i_filehandle,   '"' || crec.ID_MANUFACTURE
                                || '";"' || crec.FZGV_FGSTNR
                                || '";"' || crec.VIN
                                || '";"' || crec.FZGV_KFZKENNZEICHEN
                                || '";"' || crec.FZGV_ERSTZULASSUNG
                                || '";"' || crec.ID_FZGTYP
                                || '";"' || crec.MANU_CAPTION
                                || '";"' || crec.manualTonnage
                                || '";"' || crec.manualNumberOfAxles
                                || '";"' || crec.licensedIn
                                || '";"' || crec.mileageUnit
                                || '"'
                   );

         l_count   := l_count + 1;
      
      end loop;

      PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                            , i_LOG_ID     => '0014'            -- write file finished
                            , i_LOG_TEXT   => TO_CHAR(l_count)||' entries written to file '||i_filename );

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
   
   -- FraBe       18.03.2013  MKS-121684:1 add expInventoryList
   -- FraBe       20.03.2013  MKS-121685:1 add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden
   -- ZBerger     12.03.2015  MKS-151934:1 show SPP Collective Invoices as well
   function expInventoryList ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                             , i_filehandle            UTL_FILE.file_type
                             , o_FILE_RUNNING_NO   OUT INTEGER 
                             , i_filename              VARCHAR2 )
      return number
   is

      l_count                        number;

   begin
   
      l_count   := 0;

      for crec in ( select
                      /* TID-400: Inventory list
                              author: markus zimmerberger, pauzenberger zimmerberger gesbr
                    
                              23.04.2003 11:47                 creation
                              28.04.2003 BergerF:              make some adaptions
                              05.05.2003 BergerF:              include SAP DEBIT check
                                                               plus do not sumarize workshop invoice values where BELART_SHORTCAP = 'INF'
                                                               plus considerate SAP FWD, GUID_JOT = '12', as well
                              06.05.2003 BergerF:              remove yesterdays change according BELART_SHORTCAP = 'INF'
                                                               plus remove the SAP WORKSHOP / DEBIT / FWD check
                                                               plus nvl of different amount values
                              12.01.2004 BergerF: MKS-007922   add date parameter 1 plus change value of "Status"
                              30.01.2003 BergerF: MKS-007922:  compare the parameter date without time
                              07.03.2006 FraBe    MKS-025662:  use TCUSTOMER_DOM.CUSTDOM_DOMNUMBER according TFZGV_CONTRACTS.GUID_CUSTOMER_DOM
                                                               instead of TFZGV_CONTRACTS.FZGVC_DOMICILIATION
                              11.04.2007 FraBe    MKS-038057:1 TID-1233 / 1243 neue Logik wegen I56
                              11.06.2008 FraBe    MKS-055743   REQ316 WOP1425 TID-1331: MKS 23094 nachziehen (- 18.11.2005 PBerger: MKS 23094: Fix Inventory-List-Exports (56) 2.1.0_h6 -)
                              24.07.2008 FraBe    MKS-056648:1 REQ320 WOP1504: do not show SPP Collective Invoices (-> fzgre.GUID_SPCI is null )
                              20.03.2013 FraBe    MKS-121685:1 add comment, daß vor 2 tagen bei der MKS-121684:1 implementierung nur InScope exportiert wurden
                              06.03.2015 MaZi     MKS-151934:1 Show SPP Collective Invoices as well */
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
                              where fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
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
                              where fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
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
                              where fzgvc.ID_SEQ_FZGVC              = fzgre.ID_SEQ_FZGVC
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

            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                  , i_LOG_ID     => '0013'
                                  , i_LOG_TEXT   => 'for unknown number of inventories');

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

      PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                            , i_LOG_ID     => '0014'            -- write file finished
                            , i_LOG_TEXT   => TO_CHAR(l_count)||' entries written to file '||i_filename );

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
--------------------------------------------------------------------------------------------------------------------------------
   FUNCTION expVEGAMappingList
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER

   is
    l_count                        PLS_INTEGER:=0;
    l_recsrc                       VARCHAR2(50);
    l_na                           NUMBER(1);
    l_fin                          VARCHAR2(50);
    l_cov                          VARCHAR2(50);
    l_ctype                        VARCHAR2(50);
    l_migrated_num                 VARCHAR2(30);
    l_migrated_contr_type          VARCHAR2(50);
    l_migrated_coverage            VARCHAR2(50);
    l_add_info                     VARCHAR2(500);
    
    PROCEDURE fill_sirius_info(
        i_cn         VARCHAR2
      , o_fin    OUT VARCHAR2
      , o_cov    OUT VARCHAR2
      , o_ctype  OUT VARCHAR2
      , o_na     OUT VARCHAR2
      ) IS

    BEGIN
      SELECT DISTINCT
               fv.id_manufacture||fv.fzgv_fgstnr fin
             , last_value (cov.COV_CAPTION) OVER (PARTITION BY fc.ID_VERTRAG, fc.ID_FZGVERTRAG 
                                                     ORDER BY fc.FZGVC_BEGINN, fc.ID_SEQ_FZGVC
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) end_COV_CAPTION
             , (SELECT listagg(p.icp_i5x_value,'+') WITHIN GROUP (ORDER BY p.icp_i5x_value) 
                  FROM snt.tic_co_pack_ass@SIMEX_DB_LINK fp 
                  JOIN snt.tic_package@SIMEX_DB_LINK p ON fp.guid_package = p.guid_package 
                 WHERE fp.guid_contract=fv.guid_contract AND p.icp_package_type=2
               ) i5x_caption
             , 0
             INTO o_fin, o_cov, o_ctype, o_na
          FROM SNT.tfzgvertrag@SIMEX_DB_LINK       fv
          JOIN snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fc  ON fv.ID_VERTRAG = fc.ID_VERTRAG AND fv.id_fzgvertrag = fc.id_fzgvertrag
          JOIN snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov ON cov.ID_COV    = fc.ID_COV  
         WHERE fv.ID_VERTRAG = substr( i_cn,1
                                     , instr( i_cn, '/') - 1
                                     ) 
           AND fc.id_fzgvertrag = substr( i_cn
                                        , instr(i_cn, '/') + 1
                                        );  
         EXCEPTION WHEN no_data_found THEN
           o_na := 1;
         WHEN OTHERS THEN RAISE;
    END ;
   BEGIN
     -- Check if Vehicle/Service Contract Full Export generated mapping data, on which Vega-iCON Mapping List Extraction depends
     G_TAS_GUID := i_TAS_GUID;
     o_FILE_RUNNING_NO := 0;
     v_filename:= replace ( i_filename, '.csv', to_char ( lpad ( o_FILE_RUNNING_NO + 1, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.csv' );
      
      l_ret := chk_and_open_file ( v_filehandle, i_export_path, v_filename);

      IF l_ret  = 0 THEN
     
       SELECT 0
         INTO l_ret
         FROM tfzgv_migration_mapping
        WHERE mm_mapping_made_by = pck_calculation.c_mappsrc_extraction
          AND rownum = 1;
       
       -- Reload mapping info from source database
       DELETE tfzgv_migration_mapping
        WHERE mm_mapping_made_by = pck_calculation.c_mappsrc_Cleansing;
        
       PCK_EXPORTER.SiMEXlog ( i_TAS_GUID, '0013', SQL%ROWCOUNT|| ' mapping rows from previous load deleted.');
       
       INSERT INTO tfzgv_migration_mapping
         (mm_guid_contract, mm_old_contract_number, mm_new_contract_number, mm_mapping_made_by, mm_comment)
       SELECT cm_guid_contract, cm_old_contract_number, cm_new_contract_number, pck_calculation.c_mappsrc_Cleansing, cm_comment 
         FROM snt.tfzgv_cleansing_mapping@simex_db_link;
         
       PCK_EXPORTER.SiMEXlog ( i_TAS_GUID, '0013', SQL%ROWCOUNT|| ' new mapping rows inserted.');
           
       FOR i_vm IN (
      WITH mh (src, dest, msg, ct, c, mb, lvl,root) as
  ( select/*+ DRIVING_SITE(m) */mm_old_contract_number src
              , mm_new_contract_number dest
              , mm_comment             msg
              , mm_icon_contract_type  ct
              , mm_icon_coverage       c
              , mm_mapping_made_by     mb
              , 1 lvl
              , mm_old_contract_number root
    from   tfzgv_migration_mapping m
    WHERE mm_old_contract_number <> mm_new_contract_number AND m.mm_old_contract_number IN (SELECT vm_source_contract FROM TVEGA_MAPPINGLIST@SIMEX_DB_LINK WHERE vm_source_contract IS NOT NULL )
    union all
    SELECT mm_old_contract_number src
              , mm_new_contract_number dest
              , mm_comment             msg
              , mm_icon_contract_type  ct
              , mm_icon_coverage       c
              , mm_mapping_made_by     mb
              , mh.lvl + 1
              , mh.root
       from   tfzgv_migration_mapping mm
       JOIN  mh on (mh.dest =  mm.mm_old_contract_number)       
      WHERE mm.mm_old_contract_number <> mm.mm_new_contract_number AND mm.mm_mapping_made_by <> pck_calculation.c_mappsrc_extraction
  )
     , mapp AS 
      (
      SELECT DISTINCT 
            first_value(src) OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) orig_sirius_num
          , last_value(src)  OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) final_old_num
          , last_value(dest) OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) final_new_num
          , last_value(ct)   OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) final_icon_contract_type
          , last_value(c)    OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) final_icon_coverage
          , last_value(mb)   OVER (PARTITION BY root ORDER BY lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) final_made_by
          , LISTAGG(msg, '+') WITHIN GROUP (ORDER BY lvl) OVER (PARTITION BY root ) aggmsg
        FROM mh
      )
      , na_mapp AS    
      (
      SELECT vm_source_contract notexists FROM TVEGA_MAPPINGLIST@SIMEX_DB_LINK tm
       MINUS 
      SELECT orig_sirius_num FROM mapp
      )
      SELECT vm_vega_market
           , vm_source_contract
           , vm_fin
           , vm_found_contract_type
           , vm_vega_damage_exists
           , vm_vega_archiv_damage_exists
           , vm_old_vega_sc_exists
           , DECODE( m.final_made_by, pck_calculation.c_mappsrc_extraction,'','X')                                        "NOT migrated"
           , DECODE( m.final_made_by, pck_calculation.c_mappsrc_extraction,pck_calculation.g_tenant_id)                   "iCON Market"
           , DECODE( m.final_made_by, pck_calculation.c_mappsrc_extraction,m.final_new_num)                               "iCON service contract number"
           , DECODE( m.final_made_by, pck_calculation.c_mappsrc_extraction,m.final_icon_contract_type)                    "iCON contract type"
           , DECODE( m.final_made_by, pck_calculation.c_mappsrc_extraction,m.final_icon_coverage)                         "iCON Coverage"
           , m.final_old_num
           , m.aggmsg
           , na_mapp.notexists
        FROM TVEGA_MAPPINGLIST@SIMEX_DB_LINK vm
        LEFT JOIN na_mapp   ON vm.vm_source_contract = na_mapp.notexists
        LEFT JOIN mapp m ON vm.vm_source_contract = m.orig_sirius_num
        ORDER BY vm.vm_source_contract NULLS FIRST,vm.vm_fin , vm.vm_found_contract_type
        ) 
       LOOP
  
         l_na     := 1;
         l_fin    := NULL;
         l_cov    := NULL;
         l_ctype  := NULL;
         BEGIN
           l_recsrc := 'Orig';
           fill_sirius_info(i_vm.vm_source_contract, l_fin, l_cov, l_ctype, l_na);
           IF l_na = 1 THEN
             l_recsrc := 'Remap';
             fill_sirius_info(i_vm.final_old_num, l_fin, l_cov, l_ctype, l_na);
           END IF;
         EXCEPTION  
         WHEN OTHERS THEN pck_exporter.simexlog(i_TAS_GUID, '0010',dbms_utility.format_error_backtrace||SQLERRM||' for ');
         END;
         
         IF i_vm.notexists IS NULL AND coalesce(i_vm.final_old_num,i_vm.vm_source_contract) IS NOT NULL THEN
           l_na := 0;
         END IF ;

         SELECT LISTAGG(m, '+') WITHIN GROUP (ORDER BY seq   )  
           INTO i_vm.aggmsg
           FROM (SELECT i_vm.aggmsg m                                    ,2 seq    FROM dual UNION ALL
                 SELECT CASE WHEN l_cov LIKE 'MIG_OOS%' AND i_vm.final_old_num IS NULL
                               THEN pck_calculation.c_errmsg_notscope 
                        END                                              ,1        FROM dual UNION ALL
                 SELECT CASE WHEN l_na = 1 
                               THEN pck_calculation.c_errmsg_notfound
                        END                                              ,1        FROM dual UNION ALL
                 SELECT CASE WHEN l_na = 0 AND l_fin IS NULL
                               THEN pck_calculation.c_errmsg_FIN||' (null FIN in Sirius)'
                             WHEN l_recsrc = 'Orig' AND i_vm.vm_fin <> l_fin
                               THEN pck_calculation.c_errmsg_FIN
                        END                                              , 3       FROM dual UNION ALL
                 -- Check Type only for existing Contracts
                 SELECT CASE WHEN l_na = 0 AND l_recsrc = 'Orig' AND l_ctype IS NULL
                               THEN pck_calculation.c_errmsg_COV||' (null Contract Type in Sirius)'
                             WHEN l_recsrc = 'Orig' AND i_vm.vm_found_contract_type <> l_ctype
                               THEN pck_calculation.c_errmsg_COV
                        END                                              , 4       FROM dual
                );

         IF l_count = 0 THEN
           -- ausgabe Überschrift
           spoolline ( v_filehandle,  '"VEGA market"'
                                      || ';"Sirius contract number"'
                                      || ';"FIN"'
                                      || ';"found contract type"'
                                      || ';"VEGA DAMAGE EXISTS"'
                                      || ';"VEGA ARCHIV DAMAGE EXISTS"'
                                      || ';"OLD VEGA SC EXISTS"'
                                      || ';"NOT migrated"'
                                      || ';"iCON Market"'
                                      || ';"iCON service contract number"'
                                      || ';"iCON contract type"'
                                      || ';"iCON Coverage"'
                                      || ';"ADD INFO"'
                         );

           PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                 , i_LOG_ID     => '0013'
                                 , i_LOG_TEXT   => 'for unknown number of entries');
           o_FILE_RUNNING_NO := o_FILE_RUNNING_NO + 1;

         END IF;

         spoolline ( v_filehandle, 
                     '"' || i_vm.vm_vega_market
                         || '";"' || i_vm.vm_source_contract
                         || '";"' || i_vm.vm_fin
                         || '";"' || i_vm.vm_found_contract_type
                         || '";"' || i_vm.vm_vega_damage_exists
                         || '";"' || i_vm.vm_vega_archiv_damage_exists
                         || '";"' || i_vm.vm_old_vega_sc_exists
                         || '";"' || i_vm."NOT migrated"
                         || '";"' || i_vm."iCON Market"
                         || '";"' || i_vm."iCON service contract number"
                         || '";"' || i_vm."iCON contract type"
                         || '";"' || i_vm."iCON Coverage"
                         || '";"' || i_vm.aggmsg
                         || '"'
                  );
          l_count   := l_count + 1;      
       END LOOP;
       
       UTL_FILE.FCLOSE ( v_filehandle );
    
       PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                             , i_LOG_ID     => '0014'            -- write file finished
                             , i_LOG_TEXT   => TO_CHAR(l_count)||' entries written to file '||v_filename );

       return 0;                                                     -- SUCCESS
     ELSE
       return l_ret; 
     END IF;  

   EXCEPTION
     WHEN no_data_found THEN
       PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                             , i_LOG_ID     => '0005' -- Export failed
                             , i_LOG_TEXT   => 'No export data for Vega Mappinglist available.' );
       RETURN -1;
     WHEN OTHERS THEN
       PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                             , i_LOG_ID     => '0012' -- something wrong within creation exportfile
                             , i_LOG_TEXT   => dbms_utility.format_error_backtrace || SQLERRM );
       RETURN -1;

   END expVEGAMappingList;

END PCK_EXPORTS;
/
