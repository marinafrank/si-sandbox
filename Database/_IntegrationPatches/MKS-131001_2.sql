-- MKS-131001_2.sql

-- FraBe 06.02.2014 MKS-131001:2

create or replace PACKAGE PCK_PARTNER is
--
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/02/06 15:29:06MEZ $
--
-- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag  $
--
-- $Revision: 1.1 $
--
-- $Header: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql 1.1 2014/02/06 15:29:06MEZ Berger, Franz (fraberg) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql $
--
-- $Log: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql  $
-- Revision 1.1 2014/02/06 15:29:06MEZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.9 2014/02/06 14:26:22MEZ Berger, Franz (fraberg) 
-- add new function get_dealer_CoPartnerAssignment
-- Revision 1.8 2014/02/04 15:06:28MEZ Berger, Franz (fraberg) 
-- add new function  get_CommunicationData
-- Revision 1.7 2014/01/16 17:21:43MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: add i_filename_cre/upd due to new wave1 customer upd logic
-- Revision 1.6 2013/12/04 15:40:51MEZ Zimmerberger, Markus (zimmerb) 
-- new function expDealer
-- Revision 1.5 2013/12/03 13:43:17MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer: due to  wave1: split i_filename to i_filename_cre/upd
-- Revision 1.4 2013/11/16 07:39:06MEZ Berger, Franz (fraberg) 
-- move von PCK_EXPORTS:
-- - expPrivateCustomer
-- - expCommercialCustomer
-- - expContactPerson
-- - expWorkshop
-- - expSupplier
-- - expSalesman
-- Revision 1.3 2013/06/24 17:57:46MESZ Berger, Franz (fraberg) 
-- add function GET_CUST_xsi_PARTNER_TYPE
-- Revision 1.2 2013/03/25 15:42:44MEZ Berger, Franz (fraberg) 
-- chamge GET_PARTNER_STATE to GET_CUST_PARTNER_STATE / add GET_GAR_PARTNER_STATE
-- Revision 1.1 2012/12/04 14:07:33MEZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.1 2012/10/09 16:25:24MESZ Berger, Franz (fraberg)
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
--
-- MKSEND
--
-- Purpose: package f�r alle SiMEX - Partner berechnungs- und ersetzungs- prozeduren / funktionen
--
   FUNCTION GET_CUST_PARTNER_STATE
          ( i_ID_CUSTOMER       varchar2
          ) RETURN              varchar2;

   FUNCTION GET_GAR_PARTNER_STATE
          ( i_ID_GARAGE         integer
          ) RETURN              varchar2;

   FUNCTION GET_CUST_xsi_PARTNER_TYPE
          ( i_ID_CUSTOMER       varchar2
          ) RETURN              varchar2;

   function get_CommunicationData
          ( i_phoneNumber        varchar2   default null
          , i_mobile             varchar2   default null
          , i_faxNumber          varchar2   default null
          , i_email              varchar2   default null
          ) RETURN               XMLTYPE;

   function get_dealer_CoPartnerAssignment
          ( I_ID_GARAGE          TGARAGE.ID_GARAGE@SIMEX_DB_LINK%type
          , I_SourceSystem       varchar2
          ) return               XMLTYPE;

   FUNCTION expPrivateCustomer
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename_cre          VARCHAR2
          , i_filename_upd          VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

   FUNCTION expCommercialCustomer
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename_cre          VARCHAR2
          , i_filename_upd          VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

   FUNCTION expContactPerson
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

   FUNCTION expWorkshop
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

   FUNCTION expSupplier
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

   FUNCTION expSalesman
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;          

   FUNCTION expDealer
          ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
          , i_export_path           VARCHAR2
          , i_filename              VARCHAR2
          , i_TAS_MAX_NODES         INTEGER
          , o_FILE_RUNNING_NO   OUT INTEGER
          ) RETURN                  NUMBER;

END PCK_PARTNER; -- Package spec
/


create or replace PACKAGE BODY PCK_PARTNER
IS
--
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/02/06 15:29:06MEZ $
--
-- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag  $
--
-- $Revision: 1.1 $
--
-- $Header: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql 1.1 2014/02/06 15:29:06MEZ Berger, Franz (fraberg) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql $
--
-- $Log: 5100_Code_Base/Database/_IntegrationPatches/MKS-131001_2.sql  $
-- Revision 1.1 2014/02/06 15:29:06MEZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.34 2014/02/06 15:14:24MEZ Berger, Franz (fraberg) 
-- new function get_dealer_CoPartnerAssignment / plus function expSalesman: kein min ( GUID_CONTRACT ) select mehr im insert into TXML_SPLIT - insert - select
-- Revision 1.33 2014/02/04 16:50:47MEZ Berger, Franz (fraberg) 
-- expDealer: costIssuer is obsolete
-- plus change financialSystemRevenueId to substr ( gar.GAR_FI_DEBITOR, 1, 10 )
-- Revision 1.32 2014/02/04 16:04:04MEZ Berger, Franz (fraberg) 
-- expWorkshop: contactPartnerAssignment und contactPerson sind obsolete
-- plus: change financialSystemCostId to substr ( gar.GAR_FI_CREDITOR, 1, 10 )
-- plus add XML attribute claimingSystemID
-- Revision 1.31 2014/02/04 15:05:45MEZ Berger, Franz (fraberg) 
-- - auslagern von XMLELEMENT "communicationData" in eine neue function get_CommunicationData 
-- - create new function  pck_partner.get_CommunicationData / implement it in expPrivateCustomer / expCommercialCustomer / expWorkshop / expDealer / expSupplier
-- Revision 1.30 2014/02/03 18:44:02MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer:  use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
-- Revision 1.29 2014/02/03 17:26:18MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
-- Revision 1.28 2014/02/03 15:40:40MEZ Berger, Franz (fraberg) 
-- - expPrivateCustomer   / upd_PrivateCustomer_xml:    change <invocation operation> to "updatePhysicalPerson"
-- - expCommercialCustomer/ upd_CommercialCustomer_xml: change <invocation operation> to "updateOrganisationalPerson"
-- Revision 1.27 2014/02/03 14:38:18MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: change order by im cre/upd_CommercialCustomer_xml to cust.ID_CUSTOMER
-- Revision 1.26 2014/02/03 13:42:21MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer:  change order by im cre/upd_PrivateCustomer_xml to cust.ID_CUSTOMER
-- Revision 1.25 2014/01/27 22:01:20MEZ Berger, Franz (fraberg) 
-- all exp* change migrationDate to a TSETTING value
-- Revision 1.24 2014/01/27 06:35:24MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
-- Revision 1.23 2014/01/26 18:49:59MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer: neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
-- Revision 1.22 2014/01/16 17:22:25MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: add wave1 - upd_CommercialCustomer_xml / L_filename_cre/upd logic
-- Revision 1.21 2014/01/10 16:43:56MEZ Berger, Franz (fraberg) 
-- expDealer: new PCK_CALCULATION.SUBSTITUTE - logic for gssnOutletCompanyId / gssnOutletOutletId
-- Revision 1.20 2013/12/13 18:11:07MEZ Berger, Franz (fraberg) 
-- expSalesman: fix problem mit doppelter externalID
-- Revision 1.19 2013/12/13 14:27:01MEZ Zimmerberger, Markus (zimmerb) 
-- revenueReceipt obsolete, costIssuer.vatClassification -> costIssuer.taxClassification
-- Revision 1.18 2013/12/12 14:36:34MEZ Zimmerberger, Markus (zimmerb) 
-- expPrivateCustomer:    add attribute privateCustomer as partnerType
-- Revision 1.17 2013/12/09 15:17:43MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer:    TDF_PAYMENT.GUID_PAYMENT must be OuterJoined -> (+)
-- Revision 1.16 2013/12/05 16:23:36MEZ Berger, Franz (fraberg) 
-- ausbessern 'Salesman_'  in kommentar auf neuen wert 'SM_'
-- Revision 1.15 2013/12/05 12:53:06MEZ Zimmerberger, Markus (zimmerb) 
-- expWorkshop: wave1-changes
-- Revision 1.14 2013/12/05 11:08:38MEZ Zimmerberger, Markus (zimmerb) 
-- minor changes (dealer instead of Dealer, TSETTING Causation default 'migration')
-- Revision 1.13 2013/12/05 10:17:35MEZ Berger, Franz (fraberg) 
-- expContactPerson:  wave1 anpassungen
-- Revision 1.12 2013/12/05 10:16:45MEZ Berger, Franz (fraberg) 
-- expSalesman: wave1 anpassungen
-- Revision 1.11 2013/12/04 16:38:58MEZ Zimmerberger, Markus (zimmerb) 
-- fix to_char of migrationDate
-- Revision 1.10 2013/12/04 15:41:35MEZ Zimmerberger, Markus (zimmerb) 
-- new function expDealer
-- Revision 1.9 2013/12/03 16:28:10MEZ Berger, Franz (fraberg) 
-- expSupplier: wave1 anpassungen
-- Revision 1.8 2013/12/03 13:41:46MEZ Berger, Franz (fraberg) 
-- add wave1 - upd_PrivateCustomer_xml / L_filename_cre/upd logic
-- Revision 1.7 2013/12/02 18:39:32MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: wave1 anpassungen
-- Revision 1.6 2013/12/02 16:34:42MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer: wave1 anpassungen
-- Revision 1.5 2013/11/16 07:39:06MEZ Berger, Franz (fraberg) 
-- move von PCK_EXPORTS:
-- - expPrivateCustomer
-- - expCommercialCustomer
-- - expContactPerson
-- - expWorkshop
-- - expSupplier
-- - expSalesman
-- Revision 1.4 2013/06/24 17:57:46MESZ Berger, Franz (fraberg) 
-- add function GET_CUST_xsi_PARTNER_TYPE
-- Revision 1.3 2013/03/25 15:43:25MEZ Berger, Franz (fraberg) 
-- chamge GET_PARTNER_STATE to GET_CUST_PARTNER_STATE / add GET_GAR_PARTNER_STATE
-- Revision 1.2 2012/12/07 13:47:05MEZ Berger, Franz (fraberg) 
-- do not consider contracts with contract type MIG_OOS% in GET_PARTNER_STATE
-- Revision 1.1 2012/12/04 14:07:30MEZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.1 2012/10/09 16:25:24MESZ Berger, Franz (fraberg)
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
--
-- MKSEND

--
-- Purpose: package f�r alle SiMEX - Partner berechnungs- und ersetzungs- prozeduren / funktionen
--

-- ChangeHistory:
-- FraBe 30.11.2013 MKS-129430:1 expPrivateCustomer:    wave1 changes
-- FraBe 02.12.2013 MKS-129394:1 expCommercialCustomer: wave1 changes
-- FraBe 03.12.2013 MKS-129743:1 expPrivateCustomer:    add wave1 - upd_PrivateCustomer_xml / L_filename_cre/upd logic
-- FraBe 03.12.2013 MKS-129382:1 expSupplier:           wave1 changes
-- MaZi  04.12.2013 MKS-129347:1 expDealer:             new function (copy of expWorkshop)
-- FraBe 04.12.2013 MKS-129442:1 expSalesman:           wave1 changes
-- FraBe 05.12.2013 MKS-129454:1 expContactPerson:      wave1 changes
-- MaZi  05.12.2013 MKS-129545:1 expWorkshop:           wave1-changes
-- FraBe 09.12.2013 MKS-129434:1 expPrivateCustomer:    TDF_PAYMENT.GUID_PAYMENT must be OuterJoined -> (+)
-- MaZi  12.12.2013 MKS-129437:2 expPrivateCustomer:    add attribute privateCustomer as partnerType
-- FraBe 13.12.2013 MKS-128076:2 expSalesman:           fix problem mit doppelter externalID
-- FraBe 10.01.2014 MKS-129347:3 expDealer:             new PCK_CALCULATION.SUBSTITUTE - logic for gssnOutletCompanyId / gssnOutletOutletId
-- FraBe 16.01.2014 MKS-130369:1 expCommercialCustomer: add wave1 - upd_CommercialCustomer_xml / L_filename_cre/upd logic
-- FraBe 25.01.2014 MKS-130710:1 expPrivateCustomer:    neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
-- FraBe 25.01.2014 MKS-130711:1 expCommercialCustomer: neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
-- FraBe 25.01.2014 MKS-130798:1 all exp*               change migrationDate to a TSETTING value
-- FraBe 03.02.2014 MKS-130917:1 expPrivateCustomer:    change order by im cre/upd_PrivateCustomer_xml    to cust.ID_CUSTOMER, damit bei beiden die rows gleich sortiert sind (-> wegen gleicher Reihenfolge bei diesen )
-- FraBe 03.02.2014 MKS-130916:1 expCommercialCustomer: change order by im cre/upd_CommercialCustomer_xml to cust.ID_CUSTOMER, damit bei beiden die rows gleich sortiert sind (-> wegen gleicher Reihenfolge bei diesen )
-- FraBe 03.02.2014 MKS-130916:1 expPrivateCustomer   / upd_PrivateCustomer_xml:    change <invocation operation> to "updatePhysicalPerson"
--                               expCommercialCustomer/ upd_CommercialCustomer_xml: change <invocation operation> to "updateOrganisationalPerson"
-- FraBe 03.02.2014 MKS-130894:1 expCommercialCustomer: use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
-- FraBe 03.02.2014 MKS-130889:1 expPrivateCustomer:    use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
-- FraBe 04.02.2014 MKS-130877:1 auslagern von XMLELEMENT "communicationData" in eine neue function get_CommunicationData 
--                               so kann leichter sicher gestellt werden, da� der NODE nur dann kommt, wenn mind. eins seiner XML attribute einen wert hat 
-- FraBe 04.02.2014 MKS-130877:1 create new function pck_partner.get_CommunicationData / implement it in expPrivateCustomer / expCommercialCustomer / expWorkshop / expDealer / expSupplier
-- FraBe 04.02.2014 MKS-130879:1 expWorkshop:           contactPartnerAssignment und contactPerson sind obsolete
--                               plus: change financialSystemCostId to substr ( gar.GAR_FI_CREDITOR, 1, 10 )
--                               plus add XML attribute claimingSystemID
-- FraBe 04.02.2014 MKS-130873:1 expDealer:             costIssuer is obsolete
--                               plus change financialSystemRevenueId to substr ( gar.GAR_FI_DEBITOR, 1, 10 )
-- FraBe 06.02.2014 MKS-131001:1 new function get_dealer_CoPartnerAssignment / plus function expSalesman: kein min ( GUID_CONTRACT ) select mehr im insert into TXML_SPLIT - insert - select
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION GET_CUST_PARTNER_STATE
          ( i_ID_CUSTOMER       varchar2
          ) RETURN              varchar2 is

          L_COUNT               integer;

   begin
          select count(*)
            into L_COUNT
            from TDFCONTR_STATE@SIMEX_DB_LINK  cstat
               , TFZGVERTRAG@SIMEX_DB_LINK     fzgv
               , TFZGV_CONTRACTS@SIMEX_DB_LINK fzgvc
           where fzgvc.ID_CUSTOMER    = i_ID_CUSTOMER
             and fzgvc.ID_VERTRAG     = fzgv.ID_VERTRAG
             and fzgvc.ID_FZGVERTRAG  = fzgv.ID_FZGVERTRAG
             and fzgv.ID_COS          = cstat.ID_COS
             and cstat.COS_STAT_CODE in ( '00', '01', '02' )
             and cstat.COS_CAPTION   not like 'MIG_OOS%';

          if L_COUNT = 0
          then return 'inactive';
          else return 'active';
          end  if;

   end GET_CUST_PARTNER_STATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION GET_GAR_PARTNER_STATE
          ( i_ID_GARAGE         integer
          ) RETURN              varchar2 is

          L_COUNT               integer;

   begin
          select count(*)
            into L_COUNT
            from TDFCONTR_STATE@SIMEX_DB_LINK  cstat
               , TFZGVERTRAG@SIMEX_DB_LINK     fzgv
           where fzgv.ID_GARAGE       = i_ID_GARAGE
             and fzgv.ID_COS          = cstat.ID_COS
             and cstat.COS_STAT_CODE in ( '00', '01', '02' )
             and cstat.COS_CAPTION   not like 'MIG_OOS%';

          if L_COUNT = 0
          then return 'inactive';
          else return 'active';
          end  if;

   end GET_GAR_PARTNER_STATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   FUNCTION GET_CUST_xsi_PARTNER_TYPE
          ( i_ID_CUSTOMER       varchar2
          ) RETURN              varchar2 is
          
          L_CUSTYP_COMPANY      number;

   begin
          select   CUSTYP_COMPANY
            into L_CUSTYP_COMPANY
            from TCUSTOMER@SIMEX_DB_LINK      cust
               , TCUSTOMERTYP@SIMEX_DB_LINK   ctyp
           where cust.ID_CUSTOMER    = i_ID_CUSTOMER
             and cust.ID_CUSTYP      = ctyp.ID_CUSTYP;

          if    L_CUSTYP_COMPANY       = 1   then return 'partner_pl:PhysicalPersonType';
          elsif L_CUSTYP_COMPANY in ( 0, 2 ) then return 'partner_pl:OrganisationalPersonType';
          else                                    return null;
          end  if;

   end GET_CUST_xsi_PARTNER_TYPE;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   function get_CommunicationData
          ( i_phoneNumber        varchar2   default null
          , i_mobile             varchar2   default null
          , i_faxNumber          varchar2   default null
          , i_email              varchar2   default null
          ) RETURN               XMLTYPE    as
          l_CommunicationData    XMLTYPE;
      
   begin
     -- FraBe 04.02.2014 MKS-130877:1 auslagern von XMLELEMENT "communicationData" so kann leichter sicher gestellt werden, da� der NODE nur dann kommt, 
     --                               wenn mind. eins seiner XML attribute einen wert hat 
     if   i_phoneNumber is not null
       or i_mobile      is not null
       or i_faxNumber   is not null
       or i_email       is not null
     then select XMLAGG ( XMLELEMENT ( "communicationData"
                                     , xmlattributes
                                           ( substr ( PCK_CALCULATION.remove_alpha ( i_phoneNumber ), 1, 30 )  as "phoneNumber"
                                           , substr ( PCK_CALCULATION.remove_alpha ( i_mobile      ), 1, 30 )  as "mobile"
                                           , substr ( PCK_CALCULATION.remove_alpha ( i_faxNumber   ), 1, 30 )  as "faxNumber"
                                           ,                                         i_email                   as "email" )
                                     ))
            into l_CommunicationData
            from dual;

     end  if;     

     return l_CommunicationData;
       
   end get_CommunicationData;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_dealer_CoPartnerAssignment
          ( I_ID_GARAGE          TGARAGE.ID_GARAGE@SIMEX_DB_LINK%type
          , I_SourceSystem       varchar2
          ) return               XMLTYPE
          as
          
            L_CoPartnerAssignment   xmltype;
   begin
        -- FraBe 06.02.2014 MKS-131001:1 auslagern erstellen node contactPartnerAssignment in eigene function, da das distinct nur �ber 'from ( select distinct ',
        --                               bzw. die where - ID_GARAGE einschr�nkung nur so funktioniert  
        select XMLAGG ( XMLELEMENT ( "contactPartnerAssignment"
                      , xmlattributes ( 'BE_MI'   as "contactRole"
                                      , 'false'   as "internal"
                                      , 'true'    as "salesman" )
                                      , XMLELEMENT ( "contactPerson"
                                                   , xmlattributes ( fzg1.externalId    as "externalId"
                                                                   , I_SourceSystem     as "sourceSystem" 
                                                                   )
                                                   )
                                      )
                      )
          into L_CoPartnerAssignment
          from ( select distinct upper ( pck_calculation.get_part_of_bearbeiter_kauf
                                                       ( fzgv.FZGV_BEARBEITER_KAUF
                                                       , 3
                                                       , fzgv.id_vertrag || '/' || fzgv.id_fzgvertrag )) as externalId
                   from TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                      , TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                      , TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                  where cv.COV_CAPTION      not like 'MIG_OOS%'
                    and cv.id_cov                  = fzgvc.id_cov
                    and fzgv.ID_VERTRAG            = fzgvc.ID_VERTRAG
                    and fzgv.ID_FZGVERTRAG         = fzgvc.ID_FZGVERTRAG
                    and fzgv.ID_GARAGE             = I_ID_GARAGE
                    and fzgv.FZGV_BEARBEITER_KAUF is not null
                     -- MKS-123315:1; TK; GARAGE wird auch ausgegliedert
                    and upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020','GARAGE' )) fzg1;
          
        return L_CoPartnerAssignment;
        
   end get_dealer_CoPartnerAssignment;
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 
   FUNCTION expPrivateCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                               , i_export_path           VARCHAR2
                               , i_filename_cre          VARCHAR2
                               , i_filename_upd          VARCHAR2
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
      -- FraBe 01.12.2012 MKS-119157:1 creation
      -- FraBe 21.03.2013 MKS-123185:1 add some new columns / change some CR#1
      -- FraBe 21.03.2013 MKS-123814:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 25.06.2013 MKS-126715:1 change substitution of TIT_CAPTION to ID_TITLE
      -- FraBe 30.11.2013 MKS-129430:1 wave1 anpassungen
      -- FraBe 03.12.2013 MKS-129743:1 add wave1 - upd_PrivateCustomer_xml / L_filename_cre/upd logic
      -- FraBe 09.12.2013 MKS-129434:1 TDF_PAYMENT.GUID_PAYMENT must be OuterJoined -> (+)
      -- FraBe 25.01.2014 MKS-130710:1 neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
      -- FraBe 25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
      -- FraBe 03.02.2014 MKS-130917:1 change order by im cre/upd_PrivateCustomer_xml to cust.ID_CUSTOMER, damit bei beiden die rows gleich sortiert sind (-> wegen gleicher reihenfolge bei diesen )
      -- FraBe 03.02.2014 MKS-130916:1 upd_PrivateCustomer_xml: change <invocation operation> to "updatePhysicalPerson"
      -- FraBe 03.02.2014 MKS-130889:1 use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
      -- FraBe 04.02.2014 MKS-130877:1 implement call of new pck_partner.get_CommunicationData
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expPrivateCustomer';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT     ( AlreadyLogged, -20000 );
      L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename_cre              varchar2 ( 100 char );
      L_filename_upd              varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'd0tico30'   );
      L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
      L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',     'migration' );
      L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' );  
      L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_PrivateCustomer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename_cre      := replace ( i_filename_cre, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'related to CIM: 20131126_CIM_EDF_PhysicalPerson(privateCustomer)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
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
                                                                , L_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , 'privateCustomer'                                 as "partnerType"
                                                                , L_migrationDate                                   as "migrationDate"
                                                                , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                 ( cust.ID_CUSTOMER )               as "state"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )              as "firstName"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )              as "lastName"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , L_TIMESTAMP
                                                                                             , 'ID_TITLE'
                                                                                             , name.ID_TITLE )      as "salutation"
                                                                , cust.CUST_FISCAL_CODE                             as "personalFiscalCode" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId" )
                                                                                      ))
                                                                 from TCUST_BANKING@SIMEX_DB_LINK    cuBa
                                                                where cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  and ( cuBa.CUBA_IBAN is not null or cuBa.CUBA_BANK_CODE is not null ))
                                                           , pck_partner.get_CommunicationData 
                                                                                   ( I_phoneNumber  => name.NAME_TELEFON
                                                                                   , I_mobile       => name.NAME_TITEL2
                                                                                   , I_faxNumber    => name.NAME_FAX
                                                                                   , I_email        => name.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
                                                           , XMLELEMENT ( "customerGlobal"
                                                                , xmlattributes
                                                                     ( 'false'     as "blackListed"
                                                                     , 'unknown'   as "partnerMarketingAllowance"
                                                                     , 'false'     as "showCustomerInClaimingSystem" )
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
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'PAYM_SHORT_CAPTION'
                                                                                                             , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                )
                                                                        , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                       , XMLELEMENT ( "temporaryTaxSetting"
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
                                order by cust.ID_CUSTOMER )
                                   from TLANGUAGE@SIMEX_DB_LINK      lang
                                      , TCURRENCY@SIMEX_DB_LINK      cur
                                      , TADRESS@SIMEX_DB_LINK        adr
                                      , TCOUNTRY@SIMEX_DB_LINK       cty
                                      , TZIP@SIMEX_DB_LINK           zip
                                      , TPROVINCE@SIMEX_DB_LINK      prov
                                      , TCUSTOMER@SIMEX_DB_LINK      cust
                                      , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                      , TDF_PAYMENT@SIMEX_DB_LINK    paym
                                      , TNAME@SIMEX_DB_LINK          name
                                      , TADRASSOZ@SIMEX_DB_LINK      ass
                                      , TXML_SPLIT                   s
                                  where paym.GUID_PAYMENT  (+)  = cust.GUID_PAYMENT
                                    and lang.ID_LANGUAGE        = cust.ID_LANGUAGE
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
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' PrivateCustomers(CRE)' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename_cre);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' PrivateCustomer(CRE) nodes successfully written to file ' || L_filename_cre );

         RETURN 0;                                                 --> success
      --

      END cre_PrivateCustomer_xml;

      FUNCTION upd_PrivateCustomer_xml
         RETURN INTEGER
      IS
      BEGIN
         L_filename_upd      := replace ( i_filename_upd, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'related to CIM: 20131126_CIM_EDF_PhysicalPerson(privateCustomer)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'updatePhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'              as "xmlns:partner_pl"
                                                                , cust.ID_CUSTOMER                                  as "externalId"
                                                                , L_SourceSystem                                    as "sourceSystem"
                                                                , 'privateCustomer'                                 as "partnerType" )
                                                           , XMLELEMENT ( "revenueReceipt"
                                                                , xmlattributes ( cust.CUST_SAP_NUMBER_DEBITOR      as "financialSystemRevenueId" )
                                                                        )
                                                          ))
                                order by cust.ID_CUSTOMER )
                                   from TCUSTOMER@SIMEX_DB_LINK      cust
                                      , TXML_SPLIT                   s
                                  where s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' PrivateCustomers(UPD)' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename_upd);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' PrivateCustomer(UPD) nodes successfully written to file ' || L_filename_upd );

         RETURN 0;                                                 --> success
      --

      END upd_PrivateCustomer_xml;

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
            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
            ---
            l_ret      := upd_PrivateCustomer_xml;
            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;

            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret      := cre_PrivateCustomer_xml;
         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;
         ---
         l_ret      := upd_PrivateCustomer_xml;
         IF l_ret         = -1 THEN
            l_ret_main   := -1;
         END IF;

         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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
   END expPrivateCustomer;
   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
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
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- FraBe 31.12.2012 MKS-119157:1 creation
      -- FraBe 21.03.2013 MKS-123188:1 add some new columns / change some
      -- FraBe 25.03.2013 MKS-123188:1 also export CUSTYP_COMPANY=2 / change externalID addon from CP-1 to -CP1
      -- FraBe 27.03.2013 MKS-123817:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 05.12.2013 MKS-129454:1 wave1 anpassungen
      -- FraBe 25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expContactPerson';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT     ( AlreadyLogged, -20000 );
      L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'd0tico30'   );
      L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
      L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',     'migration' );
      L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' ); 
      L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_ContactPerson_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_PhysicalPerson(contactPerson)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
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
                                                                , L_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , 'contactPerson'                                   as "partnerType"
                                                                , L_migrationDate                                   as "migrationDate"
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


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
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
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_ContactPerson_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
      FUNCTION expCommercialCustomer ( i_TAS_GUID              TTASK.TAS_GUID%TYPE
                                     , i_export_path           VARCHAR2
                                     , i_filename_cre          VARCHAR2
                                     , i_filename_upd          VARCHAR2
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
         -- FraBe 01.12.2012 MKS-119157:1 creation
         -- FraBe 21.03.2013 MKS-123186:1 add some new columns / change some CR#1
         -- FraBe 25.03.2013 MKS-123186:1 use name.NAME_TITEL1 within contactPartnerAssignment and not cust.ID_CUSTOMER
         -- FraBe 21.03.2013 MKS-123815:1 add some new columns / change some CR#2
         -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
         -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
         -- FraBe 30.11.2013 MKS-129394:1 wave1 anpassungen
         -- FraBe 16.01.2014 MKS-130369:1 add wave1 - upd_CommercialCustomer_xml / L_filename_cre/upd logic
         -- FraBe 25.01.2014 MKS-130711:1 neue bankAccount - attributlogik (-> kein 2.9.1 SEPA mehr, sondern zur�ck zur 2.8.1 CustBanking logik )
         -- FraBe 25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
         -- FraBe 03.02.2014 MKS-130916:1 change order by im cre/upd_CommercialCustomer_xml to cust.ID_CUSTOMER, damit bei beiden die rows gleich sortiert sind (-> wegen gleicher Reihenfolge bei diesen )
         -- FraBe 03.02.2014 MKS-130916:1 upd_CommercialCustomer_xml: change <invocation operation> to "updateOrganisationalPerson"
         -- FraBe 03.02.2014 MKS-130894:1 use substr within CUBA_IBAN and CUBA_BANK_CODE to avoid exporting too long values
         -- FraBe 04.02.2014 MKS-130877:1 implement call of new pck_partner.get_CommunicationData
         -------------------------------------------------------------------------------
         l_ret                       INTEGER        DEFAULT 0;
         l_ret_main                  INTEGER        DEFAULT 0;
         lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expCommercialCustomer';
         l_xml                       XMLTYPE;
         l_xml_out                   XMLTYPE;
         AlreadyLogged               EXCEPTION;
         PRAGMA EXCEPTION_INIT     ( AlreadyLogged, -20000 );
         L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
         L_STAT                      VARCHAR2  (1) := NULL;
         L_ROWCOUNT                  INTEGER;
         L_filename_cre              varchar2 ( 100 char );
         L_filename_upd              varchar2 ( 100 char );
         L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
         L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
         L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
         L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'd0tico30'   );
         L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
         L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',     'migration' );
         L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' );
         L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));
   
         FUNCTION cre_CommercialCustomer_xml
            RETURN INTEGER
         IS
         BEGIN
            o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
            L_filename_cre      := replace ( i_filename_cre, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );
   
            --
            select XMLELEMENT ( "common:ServiceInvocationCollection"
                              , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                              , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                              , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                              , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_OrganisationalPerson(commercialCustomer)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                              , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                              , XMLELEMENT ( "executionSettings"
                                   , xmlattributes
                                       ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                       , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                       , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                       , L_userID                        as "userId"
                                       , L_TENANT_ID                     as "tenantId"
                                       , L_causation                     as "causation"
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
                                                                   , L_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                   , 'commercialCustomer'                               as "partnerType"
                                                                   , L_migrationDate                                    as "migrationDate"
                                                                   , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                    ( cust.ID_CUSTOMER )                as "state"
                                                                   , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                   , substr ( name.NAME_CAPTION1,36, 15 )               as "companyName2"
                                                                   , decode ( custtyp.CUSTYP_COMPANY, 2, 'yes', 'no' )  as "companyInternal"
                                                                   , cust.CUST_VAT_ID                                   as "vatId" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId" )
                                                                                      ))
                                                                 from TCUST_BANKING@SIMEX_DB_LINK    cuBa
                                                                where cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  and ( cuBa.CUBA_IBAN is not null or cuBa.CUBA_BANK_CODE is not null ))
                                                             , pck_partner.get_CommunicationData 
                                                                                     ( I_phoneNumber  => name.NAME_TELEFON
                                                                                     , I_faxNumber    => name.NAME_FAX
                                                                                     , I_email        => name.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
                                                              , XMLELEMENT ( "customerGlobal"
                                                                   , xmlattributes
                                                                        ( 'false'                       as "blackListed" 
                                                                        , 'unknown'                     as "partnerMarketingAllowance" 
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
                                                                                   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                , L_TIMESTAMP
                                                                                                                , 'PAYM_SHORT_CAPTION'
                                                                                                                , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                   )
                                                                           , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                    , XMLELEMENT ( "temporaryTaxSetting"
                                                                                         , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , L_TIMESTAMP
                                                                                                                                      , 'ID_CUSTYP'
                                                                                                                                      , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                          , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )       as "validFrom"
                                                                                                          , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )       as "validTo"
                                                                                                          )
                                                                                                 )
                                                                                    ))
                                                              , XMLELEMENT ( "commercialCustomerGlobals"
                                                                   , xmlattributes
                                                                        ( decode ( cust.CUST_FLEETNUMBER
                                                                             , null, 'false', 'true' )  as "fleetCompany" 
                                                                        , cust.CUST_FLEETNUMBER         as "vehicleFleetNumber" )
                                                                        )
                                                              , decode ( name.NAME_TITEL1, null, null
                                                                       , XMLELEMENT ( "contactPartnerAssignment"
                                                                            , xmlattributes ( 'false'   as "internal"
                                                                                            , 'false'   as "salesman" )
                                                                            , XMLELEMENT ( "contactPerson"
                                                                                 , xmlattributes ( cust.ID_CUSTOMER || '-CP1' as "externalId"
                                                                                                 , L_SourceSystem             as "sourceSystem" 
                                                                                                 )
                                                                                          )
                                                                                    )
                                                                        )
                                                             ))
                                   order by cust.ID_CUSTOMER )
                                      from TLANGUAGE@SIMEX_DB_LINK      lang
                                         , TCURRENCY@SIMEX_DB_LINK      cur
                                         , TADRESS@SIMEX_DB_LINK        adr
                                         , TCOUNTRY@SIMEX_DB_LINK       cty
                                         , TZIP@SIMEX_DB_LINK           zip
                                         , TPROVINCE@SIMEX_DB_LINK      prov
                                         , TCUSTOMER@SIMEX_DB_LINK      cust
                                         , TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                         , TDF_PAYMENT@SIMEX_DB_LINK    paym
                                         , TNAME@SIMEX_DB_LINK          name
                                         , TADRASSOZ@SIMEX_DB_LINK      ass
                                         , TXML_SPLIT                   s
                                     where paym.GUID_PAYMENT       = cust.GUID_PAYMENT
                                       and lang.ID_LANGUAGE        = cust.ID_LANGUAGE
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
                                   , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' CommercialCustomers(CRE)' );
   
   
            pck_exports.printXMLToFile ( l_xml.EXTRACT ('.'), i_export_path, L_filename_cre );
            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                  , i_LOG_ID     => '0014'                  -- write xml file finished
                                  , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' CommercialCustomer(CRE) nodes successfully written to file ' || L_filename_cre);
   
            RETURN 0;                                                 --> success
         --
   
         END cre_CommercialCustomer_xml;
   
         FUNCTION upd_CommercialCustomer_xml
            RETURN INTEGER
         IS
         BEGIN
            L_filename_upd      := replace ( i_filename_upd, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );
   
            --
            select XMLELEMENT ( "common:ServiceInvocationCollection"
                              , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                              , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                              , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                              , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_OrganisationalPerson(commercialCustomer)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                              , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                              , XMLELEMENT ( "executionSettings"
                                   , xmlattributes
                                       ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                       , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                       , to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                       , L_userID                        as "userId"
                                       , L_TENANT_ID                     as "tenantId"
                                       , L_causation                     as "causation"
                                       , o_FILE_RUNNING_NO               as "additionalInformation1"
                                       , L_correlationID                 as "correlationId"
                                       ))
                              , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                     , xmlattributes ( 'updateOrganisationalPerson' AS "operation"  )
                                                         , XMLELEMENT ( "parameter"
                                                              , xmlattributes
                                                                   ( 'partner_pl:OrganisationalPersonType'             as "xsi:type"
                                                                   , 'http://partner.icon.daimler.com/pl'              as "xmlns:partner_pl"
                                                                   , cust.ID_CUSTOMER                                  as "externalId"
                                                                   , L_SourceSystem                                    as "sourceSystem"
                                                                   , 'commercialCustomer'                              as "partnerType" )
                                                              , XMLELEMENT ( "revenueReceipt"
                                                                   , xmlattributes ( cust.CUST_SAP_NUMBER_DEBITOR      as "financialSystemRevenueId" )
                                                                           )
                                                             ))
                                   order by cust.ID_CUSTOMER )
                                      from TCUSTOMER@SIMEX_DB_LINK      cust
                                         , TXML_SPLIT                   s
                                     where s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                   )).EXTRACT ('.')
                   AS xml
              into l_xml
              from DUAL;
   
            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                   , i_LOG_ID    => '0013'                  -- Gathering data finished
                                   , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' CommercialCustomers(UPD)' );
   
   
            pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename_upd);
            PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                  , i_LOG_ID     => '0014'                  -- write xml file finished
                                  , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' CommercialCustomer(UPD) nodes successfully written to file ' || L_filename_upd );
   
            RETURN 0;                                                 --> success
         --
   
         END upd_CommercialCustomer_xml;
   
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
   
            IF   L_ROWCOUNT >= i_TAS_MAX_NODES
            THEN l_ret := cre_CommercialCustomer_xml;
                 IF   l_ret         = -1 
                 THEN l_ret_main   := -1;
                 END  IF;
                 ---
                 l_ret := upd_CommercialCustomer_xml;
                 IF   l_ret         = -1 
                 THEN l_ret_main   := -1;
                 END  IF;
   
                 COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
                 L_ROWCOUNT   := 0;
   
            END  IF;
         END LOOP;
   
         IF L_ROWCOUNT > 0
         THEN l_ret := cre_CommercialCustomer_xml;
              IF   l_ret         = -1 
              THEN l_ret_main   := -1;
              END  IF;
              ---
              l_ret := upd_CommercialCustomer_xml;
              IF   l_ret         = -1 
              THEN l_ret_main   := -1;
              END  IF;
   
              COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
   
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
      END expCommercialCustomer;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
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
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- FraBe 24.03.2013  MKS-122279:1 creation
      -- FraBe 27.03.2013  MKS-123818:1 add some new columns / change some CR#2
      -- FraBe 27.03.2013  MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 27.03.2013  MKS-123818:1 move costIssuer after contactPartnerAssignment
      -- MaZi  27.03.2013  MKS-125543:1 use pck_calculation.get_part_of_bearbeiter_kauf for contactPartnerAssignment.externalId
      -- FraBe 24.06.2013  MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 22.07.2013  MKS-127399:1 export node contactPartnerAssignment only if TFZGVERTRAG.FZGV_BEARBEITER_KAUF is not null
      -- FraBe 22.07.2013  MKS-127399:2 export node contactPartnerAssignment: exclude some TFZGVERTRAG.FZGV_BEARBEITER_KAUF values
      -- MaZi  05.12.2013  MKS-129545:1 Wave1-changes
      -- FraBe 25.01.2014  MKS-130798:1 change migrationDate to a TSETTING value
      -- FraBe 04.02.2014  MKS-130877:1 implement call of new pck_partner.get_CommunicationData
      -- FraBe 04.02.2014  MKS-130879:1 contactPartnerAssignment und contactPerson sind obsolete
      --                                plus: change financialSystemCostId to substr ( gar.GAR_FI_CREDITOR, 1, 10 )
      --                                plus add XML attribute claimingSystemID
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expWorkshop';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT (     AlreadyLogged, -20000 );
      L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',                 'TENANTID' );
      L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',                   'SIRIUS'   );
      L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',             'd0tico30' );
      L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID',            'SIRIUS'   );
      L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',                'migration');
      L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9'        );
      L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_Workshop_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_OrganisationalPerson(workshop)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               as "xmlns:partner_pl"
                                                                , 'W' || gar.ID_GARAGE                               as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , L_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'workshop'                                         as "partnerType"
                                                                , PCK_PARTNER.GET_GAR_PARTNER_STATE 
                                                                                 ( gar.ID_GARAGE )                   as "state"
                                                                , L_migrationDate                                    as "migrationDate"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , substr ( gar.GAR_GARNOVEGA, 1, 5 )                 as "claimingSystemId"
                                                                , gar.GAR_VAT_ID                                     as "vatId" )
                                                           , pck_partner.get_CommunicationData 
                                                                                   ( I_phoneNumber  => name.NAME_TELEFON
                                                                                   , I_faxNumber    => name.NAME_FAX
                                                                                   , I_email        => name.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
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
                                                        /* , ( select XMLAGG ( XMLELEMENT ( "contactPartnerAssignment"
                                                                                  , xmlattributes ( 'BE_MI'   as "contactRole"
                                                                                                  , 'false'   as "internal"
                                                                                                  , 'true'    as "salesman" )
                                                                                  , XMLELEMENT ( "contactPerson"
                                                                                       , xmlattributes ( pck_calculation.get_part_of_bearbeiter_kauf
                                                                                                        (fzgv.FZGV_BEARBEITER_KAUF, 3, fzgv.id_vertrag || '/' || fzgv.id_fzgvertrag )
                                                                                                                                                    as "externalId"
                                                                                                       , L_SourceSystem                             as "sourceSystem" 
                                                                                                       )
                                                                                               )
                                                                                          )
                                                                             )
                                                                 from TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                                                                where fzgv.ID_GARAGE             = gar.ID_GARAGE
                                                                  and fzgv.FZGV_BEARBEITER_KAUF is not null
                                                                  -- MKS-123315:1; TK; GARAGE wird auch ausgegliedert
                                                                  and upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020','GARAGE' )
                                                             ) */   -- ist obsolete lt. MKS-130879:1
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
                                                                                                             , gar.ID_GARAGETYP ) AS "taxClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , substr ( gar.GAR_FI_CREDITOR, 1, 10 ) as "financialSystemCostId"
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


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
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
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Workshop_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
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
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- FraBe 27.03.2013 MKS-123819:1 creation
      -- FraBe 27.03.2013 MKS-123938:1 neue logik aufbereiten L_filename
      -- FraBe 24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe 30.11.2013 MKS-129382:1 wave1 anpassungen
      -- FraBe 25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
      -- FraBe 04.02.2014 MKS-130877:1 "vatClassification" is obsolete
      -- FraBe 04.02.2014 MKS-130877:1 implement call of new pck_partner.get_CommunicationData
      -------------------------------------------------------------------------------
      l_ret                        INTEGER        DEFAULT 0;
      l_ret_main                   INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT      VARCHAR2 (100) DEFAULT 'expSupplier';
      l_xml                        XMLTYPE;
      l_xml_out                    XMLTYPE;
      AlreadyLogged                EXCEPTION;
      PRAGMA EXCEPTION_INIT      ( AlreadyLogged, -20000 );
      L_TIMESTAMP                  TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                       VARCHAR2  (1) := NULL;
      L_ROWCOUNT                   INTEGER;
      L_filename                   varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK         varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID'   );
      L_userID                     TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'     );
      L_SourceSystem               TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'd0tico30'   );
      L_correlationID              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'     );
      L_causation                  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',     'migration'  );
      L_masterDataReleaseVersion   TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION',   '9' );
      L_ThresholdIndividualInvoice TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'THRESHOLDINDIVIDUALINVOICE', '0' );
      L_ThresholdMonthlyInvoice    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'THRESHOLDMONTHLYINVOICE',    '0' );
      L_migrationDate              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_Supplier_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_OrganisationalPerson(supplier)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
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
                                                                , L_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'supplier'                                         as "partnerType"
                                                                , L_migrationDate                                    as "migrationDate"
                                                                , PCK_PARTNER.GET_GAR_PARTNER_STATE 
                                                                                 ( gar.ID_GARAGE )                   as "state"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , substr ( gar.GAR_GARNOVEGA, 1, 5 )                 as "claimingSystemId"
                                                                , 'GS1234567'                                        as "gssnOutletOutletId"
                                                                , gar.GAR_VAT_ID                                     as "vatId" )
                                                           , pck_partner.get_CommunicationData 
                                                                                   ( I_phoneNumber  => name.NAME_TELEFON
                                                                                   , I_faxNumber    => name.NAME_FAX
                                                                                   , I_email        => name.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
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
                                                           , decode ( gar.GAR_FI_DEBITOR, null, null
                                                                    , XMLELEMENT ( "revenueReceipt"
                                                                         , xmlattributes 
                                                                                ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                           /*   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , L_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) as "vatClassification"   */ -- obsolete due to MKS-130877:1
                                                                                , substr ( gar.GAR_FI_DEBITOR, 1, 10 ) as "financialSystemRevenueId"
                                                                                )))
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
                                                                                                             , gar.ID_GARAGETYP ) AS "taxClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , substr ( gar.GAR_FI_CREDITOR, 1, 10 ) as "financialSystemCostId"
                                                                                , 'true'                                as "waitForCreditNote"
                                                                                , L_ThresholdIndividualInvoice          as "collectiveFinancialDocumentThresholdCreditNoteServiceProviderIndividualInvoice"
                                                                                , L_ThresholdMonthlyInvoice             as "collectiveFinancialDocumentThresholdCreditNoteServiceProviderMonthlyPayment"
                                                                                , L_ThresholdIndividualInvoice          as "collectiveFinancialDocumentThresholdInvoiceServiceProviderIndividualInvoice"
                                                                                , L_ThresholdMonthlyInvoice             as "collectiveFinancialDocumentThresholdInvoiceServiceProviderMonthlyPayment"
                                                                                , L_ThresholdIndividualInvoice          as "singleFinancialDocumentThresholdCreditNoteServiceProviderIndividualInvoice"
                                                                                , L_ThresholdMonthlyInvoice             as "singleFinancialDocumentThresholdCreditNoteServiceProviderMonthlyPayment"
                                                                                , L_ThresholdIndividualInvoice          as "singleFinancialDocumentThresholdInvoiceServiceProviderIndividualInvoice"
                                                                                , L_ThresholdMonthlyInvoice             as "singleFinancialDocumentThresholdInvoiceServiceProviderMonthlyPayment"
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


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
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
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Supplier_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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
   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
      --    jeweils durchgef�hrten Plausibilit�tspr�fungen
      --    Auswirkungen auf den Bildschirm
      --    durchgef�hrten Protokollierung
      --    abgelegten Tracinginformationen
      --  ENDPURPOSE
      -- MaZi     27.03.2013 MKS-123816:1 creation
      -- MaZi     23.05.2013 MKS-125778:1 consider case-sensitiv attribute-names and values
      -- TK       11.06.2013 MKS-126380   correction due to productive export
      -- FraBe    24.06.2013 MKS-126498:1 add L_DB_NAME_of_DB_LINK
      -- FraBe    22.07.2013 MKS-127398:1 neue ins into TXML_SPLIT logik: jene mit ID zwischen / nicht zwischen () extra
      -- TK/FraBe 25.07.2013 MKS-123315:1 / 127507:2 exclude GARAGE
      -- MaZi     30.09.2013 MKS-128076:1 Vermeide doppelte ExternalIDs
      -- FraBe    04.12.2013 MKS-129442:1 wave1 anpassungen
      -- FraBe    13.12.2013 MKS-128076:2 fix problem mit doppelter externalID
      -- FraBe    25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
      -- FraBe    06.02.2014 MKS-131001:1 kein min ( GUID_CONTRACT ) select mehr im insert into TXML_SPLIT - insert - select
      -------------------------------------------------------------------------------
      l_ret                   INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expSalesman';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT     ( AlreadyLogged, -20000 );
      L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' );
      L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   );
      L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',  'd0tico30'   );
      L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID', 'SIRIUS'   );
      L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',     'migration' );
      L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9' );
      L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_salesman_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_PhysicalPerson(salesman)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' AS "xmlns:mdsd_sl"
                                    , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) AS "dateTime"
                                    , L_userID                        AS "userId"
                                    , L_TENANT_ID                     AS "tenantId"
                                    , L_causation                     AS "causation"
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
                                                                , L_masterDataReleaseVersion                         AS "masterDataReleaseVersion"
                                                                , 'salesman'                                         AS "partnerType"
                                                                , L_migrationDate                                    as "migrationDate"
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
                                  where fzg.GUID_CONTRACT in ( select min ( fzg1.GUID_CONTRACT )
                                                                 from TFZGVERTRAG@SIMEX_DB_LINK    fzg1
                                                                    , TXML_SPLIT                   x
                                                                where x.PK_VALUE_CHAR = upper ( pck_calculation.GET_PART_OF_BEARBEITER_KAUF
                                                                                                              ( fzg1.FZGV_BEARBEITER_KAUF
                                                                                                              , 3
                                                                                                              , fzg1.ID_VERTRAG || '/' || fzg1.ID_FZGVERTRAG ))
                                                             group by upper ( pck_calculation.GET_PART_OF_BEARBEITER_KAUF
                                                                                            ( fzg1.FZGV_BEARBEITER_KAUF
                                                                                            , 3
                                                                                            , fzg1.ID_VERTRAG || '/' || fzg1.ID_FZGVERTRAG )))
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                , i_LOG_ID    => '0013'                  -- Gathering data finished
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' salesmans' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' salesman nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_salesman_xml;
   BEGIN                                                          -- main part
      L_ROWCOUNT          := 0;
      o_FILE_RUNNING_NO   := 0;

      -- MKS-127398:1 wenn in FZGV_BEARBEITER_KAUF keine ID zwischen () steht, werden alle vertr�ge ausgegeben
      -- -> im gro�en xml select wird da draus der text 'SM_' || ID_VERTRAG || '/' || ID_FZGVERTRAG
      -- MKS-127398:1 wenn in FZGV_BEARBEITER_KAUF eine ID zwischen () steht, wird der name nur 1x ausgegeben
      -- -> im gro�en xml select wird da draus die ID zwischen den () extrahiert
      -- MKS-123315:1 TK; GARAGE wird auch ausgegliedert
      -- MKS-127507:2 FraBe; exclude GARAGE auch im union select
      -- MKS-128076:1 MaZi; Vermeide doppelte ExternalIDs
      -- MKS-131001:1 FraBe; kein min ( GUID_CONTRACT ) select mehr -> damit kommen wieder alle 'SM_' || <ID_VERTRAG> || '/' || <ID_FZGVERTRAG>
      --                     (-> in der vergangenheit wurde das nur von den CO gemacht, deren GUID_CONTRACT den kleinsten wert hatte )
      FOR crec IN ( select distinct upper ( pck_calculation.GET_PART_OF_BEARBEITER_KAUF
                                                   ( fzgv.FZGV_BEARBEITER_KAUF, 3, fzgv.ID_VERTRAG || '/' || fzgv.ID_FZGVERTRAG )) externalId
                      from TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                         , TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                         , TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                     where upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020', 'GARAGE' )
                       and fzgv.FZGV_BEARBEITER_KAUF is not null
                       and cv.COV_CAPTION      not like 'MIG_OOS%'
                       and cv.id_cov                  = fzgvc.id_cov
                       and fzgv.ID_VERTRAG            = fzgvc.ID_VERTRAG
                       and fzgv.ID_FZGVERTRAG         = fzgvc.ID_FZGVERTRAG
                     order by 1 )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.externalId );

         L_ROWCOUNT   := L_ROWCOUNT + 1;

         IF L_ROWCOUNT >= i_TAS_MAX_NODES THEN
            l_ret      := cre_salesman_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_salesman_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION expDealer (   i_TAS_GUID              TTASK.TAS_GUID%TYPE
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
      -- MaZi  04.12.2013 MKS-129347:1 creation (as a copy of expWorkshop)
      -- FraBe 10.01.2014 MKS-129347:3 new PCK_CALCULATION.SUBSTITUTE - logic for gssnOutletCompanyId / gssnOutletOutletId
      -- FraBe 25.01.2014 MKS-130798:1 change migrationDate to a TSETTING value
      -- FraBe 04.02.2014 MKS-130877:1 implement call of new pck_partner.get_CommunicationData
      -- FraBe 04.02.2014 MKS-130873:1 costIssuer is obsolete
      --                               plus change financialSystemRevenueId to substr ( gar.GAR_FI_DEBITOR, 1, 10 )
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expDealer';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      AlreadyLogged               EXCEPTION;
      PRAGMA EXCEPTION_INIT (     AlreadyLogged, -20000 );
      L_TIMESTAMP                 TIMESTAMP (6) := SYSTIMESTAMP;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DB_NAME_of_DB_LINK        varchar2 ( 100 char )   := pck_calculation.get_DB_NAME_of_DB_LINK ( 'SIMEX_DB_LINK' );
      L_TENANT_ID                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'TENANTID',                 'TENANTID' );
      L_userID                    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'USERID',                   'SIRIUS'   );
      L_SourceSystem              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SOURCESYSTEM',             'd0tico30' );
      L_correlationID             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CORRELATIONID',            'SIRIUS'   );
      L_causation                 TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'CAUSATION',                'migration');
      L_masterDataReleaseVersion  TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MASTERDATARELEASEVERSION', '9'        );
      L_migrationDate             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE', to_char ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ));

      FUNCTION cre_Dealer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( o_FILE_RUNNING_NO ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20131126_CIM_EDF_OrganisationalPerson(dealer)_Mig_BEL_Wave1_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Source-database: ' || L_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , 'http://system.mdsd.ibm.com/sl' as "xmlns:mdsd_sl"
                                    , TO_CHAR ( sysdate, 'YYYY-MM-DD' ) || 'T' || to_char ( sysdate, 'HH24:MI:SS' ) as "dateTime"
                                    , L_userID                        as "userId"
                                    , L_TENANT_ID                     as "tenantId"
                                    , L_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , L_correlationID                 as "correlationId"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'               as "xmlns:partner_pl"
                                                                , 'D' || gar.ID_GARAGE                               as "externalId"
                                                                , L_SourceSystem                                     as "sourceSystem"
                                                                , L_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'dealer'                                           as "partnerType"
                                                                , PCK_PARTNER.GET_GAR_PARTNER_STATE 
                                                                                 ( gar.ID_GARAGE )                   as "state"
                                                                , L_migrationDate                                    as "migrationDate"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , gar.GAR_VAT_ID                                     as "vatId"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , L_TIMESTAMP
                                                                                             , 'gssnOutletCompanyId'
                                                                                             , gar.ID_GARAGE )       as "gssnOutletCompanyId"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , L_TIMESTAMP
                                                                                             , 'gssnOutletOutletId'
                                                                                             , gar.ID_GARAGE )       as "gssnOutletOutletId" )
                                                           , pck_partner.get_CommunicationData 
                                                                                   ( I_phoneNumber  => name.NAME_TELEFON
                                                                                   , I_faxNumber    => name.NAME_FAX
                                                                                   , I_email        => name.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
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
                                                                                , substr ( gar.GAR_FI_DEBITOR, 1, 10 )            as "financialSystemRevenueId"
                                                                                ))
                                                           , pck_partner.get_dealer_CoPartnerAssignment ( gar.ID_GARAGE, L_SourceSystem ) as "contactPartnerAssignment"
                                                        /* , XMLELEMENT ( "costIssuer"
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
                                                                                )) */ -- costIssuer is obsolete due to MKS-130873:1
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
                                , i_LOG_TEXT  => 'for ' || i_TAS_MAX_NODES || ' Dealers' );


         pck_exports.printXMLToFile (l_xml.EXTRACT ('.'), i_export_path, L_filename);
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0014'                  -- write xml file finished
                               , i_LOG_TEXT   => TO_CHAR (i_TAS_MAX_NODES) || ' Dealer nodes successfully written to file ' || L_filename);

         RETURN 0;                                                 --> success
      --

      END cre_Dealer_xml;
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
            l_ret      := cre_Dealer_xml;
            COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist
            L_ROWCOUNT   := 0;

            IF l_ret         = -1 THEN
               l_ret_main   := -1;
            END IF;
         END IF;
      END LOOP;

      IF L_ROWCOUNT > 0 THEN
         l_ret   := cre_Dealer_xml;
         COMMIT; -- dadurch wird die global temporary table TXML_SPLIT gel�scht, weil sie mit on commit delete rows definiert ist

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
   END expDealer;

end PCK_PARTNER;
/