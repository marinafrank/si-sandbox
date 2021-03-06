create or replace PACKAGE BODY PCK_PARTNER
IS
--
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2015/03/20 16:10:43MEZ $
--
-- $Name:  $
--
-- $Revision: 1.75 $
--
-- $Header: 5100_Code_Base/Database/Source/PCK_PARTNER.plb 1.75 2015/03/20 16:10:43MEZ Frank, Marina (marinf) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/PCK_PARTNER.plb $
--
-- $Log: 5100_Code_Base/Database/Source/PCK_PARTNER.plb  $
-- Revision 1.75 2015/03/20 16:10:43MEZ Frank, Marina (marinf) 
-- MKS-151824:1 DEF8653 derive "dateTime" from global settings.
-- Revision 1.74 2015/03/11 13:36:54MEZ Frank, Marina (marinf) 
-- MKS-136525:1 Added "financeSystemId" "directDebit" "directDebitCode" for Private and Commercial Costomers, Dealers. Optimized Dealers extraction.
-- Revision 1.73 2015/01/26 14:40:57MEZ Zimmerberger, Markus (zimmerb) 
-- cre_PrivateCustomer_xml/upd_PrivateCustomer_xml: do not deliver mailAddress for MBBEL
-- Revision 1.72 2015/01/26 10:54:11MEZ Zimmerberger, Markus (zimmerb) 
-- cre_CommercialCustomer_xml/upd_CommercialCustomer_xml/cre_Dealer_xml: do not deliver mailAddress for MBBEL
-- Revision 1.71 2014/12/17 08:58:25MEZ Berger, Franz (fraberg) 
-- get_dealer_CoPartnerAssignment: remove externalId - upper
-- Revision 1.70 2014/11/10 10:34:39MEZ Berger, Franz (fraberg) 
-- expWorkshop: WavePreInt4 - get workshop state value from GS 'WORKSHOPSTATUS'
-- Revision 1.69 2014/10/10 11:24:38MESZ Berger, Franz (fraberg) 
-- expSalesman: add L_DEFAULTSALESPERSON - defaultvalue
-- Revision 1.68 2014/10/10 09:17:44MESZ Berger, Franz (fraberg) 
-- get_dealer_CoPartnerAssignment keine GARAGE / SU0% einschr�nkung mehr
-- Revision 1.67 2014/10/07 18:36:50MESZ Zimmerberger, Markus (zimmerb) 
-- upd_CommercialCustomer_xml: add "xsi:type" for contactPerson, mainContactPerson
-- Revision 1.66 2014/10/07 14:36:45MESZ Berger, Franz (fraberg) 
-- expSalesman: einbau wavePreInt4
-- Revision 1.65 2014/10/03 08:37:12MESZ Berger, Franz (fraberg) 
-- expContactPerson / expCommercialCustomer / expWorkshop / expSupplier / expDealer:
-- fix executionSettings - xmlns:mdsd_sl namespace problem
-- Revision 1.64 2014/10/01 16:02:20MESZ Zimmerberger, Markus (zimmerb) 
-- expPrivateCustomer: WavePreInt4 changes
-- Revision 1.63 2014/09/30 13:18:01MESZ Zimmerberger, Markus (zimmerb) 
-- expContactPerson: WavePreInt4 changes
-- Revision 1.62 2014/09/30 09:36:24MESZ Zimmerberger, Markus (zimmerb) 
-- expWorkshop: WavePreInt4 changes
-- Revision 1.61 2014/09/29 15:57:26MESZ Zimmerberger, Markus (zimmerb) 
-- expSupplier: WavePreInt4 changes
-- Revision 1.60 2014/09/26 14:23:06MESZ Zimmerberger, Markus (zimmerb) 
-- expCommercialCustomer: WavePreInt4 changes
-- Revision 1.59 2014/09/26 12:48:50MESZ Berger, Franz (fraberg) 
-- expDealer: add WavePreInt4
-- Revision 1.58 2014/09/22 16:11:52MESZ Kieninger, Tobias (tkienin) 
-- Customers out of Scope must create anyway Contact Persons, if the customer is referenced by a dealer as "WorkshopCustomer"
-- Revision 1.57 2014/09/16 10:25:41MESZ Kieninger, Tobias (tkienin) 
-- merging branch
-- Revision 1.56.1.3 2014/09/11 18:56:17MESZ Zuhl, Marco (marzuhl) 
-- Fehlerbehandlung...
-- Revision 1.56.1.2 2014/09/11 11:44:00MESZ Zuhl, Marco (marzuhl) 
-- Replaced all:
-- to_char ( o_FILE_RUNNING_NO )
-- with:
-- to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) )
-- Revision 1.56.1.1 2014/09/02 17:08:49MESZ Zuhl, Marco (marzuhl) 
-- Revision
-- Revision 1.56 2014/08/10 13:18:36MESZ Berger, Franz (fraberg) 
-- expWorkshop: bei CountryCode = MBBEL = '51331': exportiere auch workshops mit GAR_GARNOVEGA is null
-- Revision 1.55 2014/07/31 18:42:15MESZ Berger, Franz (fraberg) 
-- expDealer: Entfernung der Einschr�nkung GAR_GANOVEGA = 11924
-- Revision 1.54 2014/07/31 17:56:48MESZ Berger, Franz (fraberg) 
-- expCommercialCustomer: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
-- plus: �berall den tableowner dazustellen wie zb. snt.TCUSTOMER@SIMEX_DB_LINK
-- Revision 1.53 2014/07/21 07:28:13MESZ Berger, Franz (fraberg) 
-- expWorkshop: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- Revision 1.52 2014/07/15 10:58:55MESZ Berger, Franz (fraberg) 
-- expContactPerson: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- Revision 1.51 2014/07/09 13:41:59MESZ Berger, Franz (fraberg) 
-- expDealer: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- Revision 1.50 2014/07/01 11:41:41MESZ Berger, Franz (fraberg) 
-- - expSupplier:           einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- - plus korrektur lesen COUNTRY_CODE into G_COUNTRY_CODE statt TENANTID
-- Revision 1.49 2014/06/28 15:10:47MESZ Berger, Franz (fraberg) 
-- expSalesman: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- Revision 1.48 2014/06/25 13:03:18MESZ Berger, Franz (fraberg) 
-- - get_CommunicationData: no PCK_CALCULATION.remove_alpha anymore
-- - expPrivateCustomer:    einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- Revision 1.47 2014/06/16 10:30:24MESZ Zuhl, Marco (marzuhl) 
-- Fix financialSystemRevenueId nicht �berall als substring 1,10 implementiert
-- Revision 1.46 2014/06/02 14:31:25MESZ Berger, Franz (fraberg) 
-- upd_PrivateCustomer_xml / upd_CommercialCustomer_xml: substr ( ..., 1, 10 ) as "financialSystemRevenueId"
-- Revision 1.45 2014/04/02 11:18:27MESZ Berger, Franz (fraberg) 
-- expSupplier: do not deliver gssnOutletOutletId anymore
-- Revision 1.44 2014/03/15 09:07:16MEZ Berger, Franz (fraberg) 
-- get_dealer_CoPartnerAssignment: neue  - IN parameter
-- Revision 1.43 2014/03/06 15:05:36MEZ Berger, Franz (fraberg) 
-- all exp*: change xmlcomment related to CIM
-- Revision 1.42 2014/03/05 22:26:15MEZ Berger, Franz (fraberg) 
-- expSalesman: wave3.2 �nderungen
-- Revision 1.41 2014/03/05 22:14:54MEZ Berger, Franz (fraberg) 
-- expContactPerson: wave3.2 �nderungen
-- Revision 1.40 2014/03/05 22:02:23MEZ Berger, Franz (fraberg) 
-- expPrivateCustomer:    wave3.2 �nderungen
-- Revision 1.39 2014/03/05 17:40:55MEZ Berger, Franz (fraberg) 
-- expSupplier: wave3.2 �nderungen
-- Revision 1.38 2014/03/05 17:15:37MEZ Berger, Franz (fraberg) 
-- expWorkshop:  wave3.2 �nderungen
-- Revision 1.37 2014/03/05 17:02:53MEZ Berger, Franz (fraberg) 
-- expDealer: wave3.2 �nderungen
-- Revision 1.36 2014/03/05 16:53:04MEZ Berger, Franz (fraberg) 
-- expCommercialCustomer: wave3.2 �nderungen
-- Revision 1.35 2014/02/27 16:05:20MEZ Zimmerberger, Markus (zimmerb) 
-- add substr(cust.CUST_FLEETNUMBER,1,20) (vehicleFleetNumber)
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
-- FraBe 05.03.2014 MKS-131171:1 expCommercialCustomer: wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131183:1 expDealer:             wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131207:1 expWorkshop:           wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131195:1 expSupplier:           wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131231:1 expPrivateCustomer:    wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131219:1 expContactPerson:      wave3.2 �nderungen
-- FraBe 05.03.2014 MKS-131243:1 expSalesman:           wave3.2 �nderungen
-- FraBe 06.03.2014 MKS-131176:1 all exp*               change xmlcomment related to CIM
-- FraBe 06.03.2014 MKS-131188:1 get_dealer_CoPartnerAssignment: neue  - IN parameter
-- FraBe 06.03.2014 MKS-131200:1 expSupplier: do not deliver gssnOutletOutletId anymore
-- FraBe 02.06.2014 MKS-133073:1 upd_PrivateCustomer_xml / upd_CommercialCustomer_xml: substr ( ..., 1, 10 ) as "financialSystemRevenueId"
-- FraBe 23.06.2014 MKS-132102:1 / 132103:1 - get_CommunicationData: no PCK_CALCULATION.remove_alpha anymore
--                                          - expPrivateCustomer:    einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- FraBe 25.06.2014 MKS-132115:1 / 132116:1   expSalesman:           einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- FraBe 30.06.2014 MKS-132063:1 / 132064:1   expSupplier:           einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- FraBe 01.07.2014 MKS-132046:1 / 132047:1   expDealer:             einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
-- FraBe 15.07.2014 MKS-132089:1 / 132090:1   expContactPerson:      einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
-- FraBe 18.07.2014 MKS-132076:1 / 132077:1   expWorkshop:           einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
-- FraBe 21.07.2014 MKS-132033:1 / 132034:1   expCommercialCustomer: einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
--                                            plus: �berall den tableowner dazustellen wie zb. snt.TCUSTOMER@SIMEX_DB_LINK
-- FraBe 31.07.2014 MKS-134047:1 / expDealer: Entfernung der Einschr�nkung GAR_GANOVEGA = 11924
-- FraBe 10.08.2014 MKS-132081:1 / expWorkshop: bei CountryCode = MBBEL = '51331': exportiere auch workshops mit GAR_GARNOVEGA is null
-- FraBe 25.09.2014 MKS-134358:1 / 134359:1 expDealer: add WavePreInt4
-- MaZi  26.09.2014 MKS-134345:1 / 134346:1 expCommercialCustomer: WavePreInt4 changes
-- MaZi  29.09.2014 MKS-134371:1 / 134372:1 expSupplier: WavePreInt4 changes
-- MaZi  30.09.2014 MKS-134384:1 / 134385:1 expWorkshop: WavePreInt4 changes
-- MaZi  30.09.2014 MKS-134397:1 / 134398:1 expContactPerson: WavePreInt4 changes
-- MaZi  01.10.2014 MKS-134410:1 / 134411:1 expPrivateCustomer: WavePreInt4 changes
-- FraBe 01.10.2014 MKS-135081:1 expContactPerson / expCommercialCustomer / expWorkshop / expSupplier / expDealer:
--                               fix executionSettings - xmlns:mdsd_sl namespace problem
-- FraBe 03.10.2014 MKS-134423:1 / 134424:1 expSalesman: einbau wavePreInt4
-- MaZi  07.10.2014 MKS-134351:1 upd_CommercialCustomer_xml: add "xsi:type" for contactPerson, mainContactPerson
-- FraBe 09.10.2014 MKS-134426:1 get_dealer_CoPartnerAssignment keine GARAGE / SU0% einschr�nkung mehr
-- FraBe 10.10.2014 MKS-134429:2 expSalesman: add L_DEFAULTSALESPERSON - defaultvalue
-- FraBe 10.11.2014 MKS-135538:1 expWorkshop: WavePreInt4 - get workshop state value from GS 'WORKSHOPSTATUS'
-- FraBe 16.12.2014 MKS-136092:1 get_dealer_CoPartnerAssignment: remove externalId - upper
-- MaZi  26.01.2015 MKS-136183:1 cre_CommercialCustomer_xml/upd_CommercialCustomer_xml/cre_Dealer_xml: do not deliver mailAddress for MBBEL
-- MaZi  26.01.2015 MKS-136189:1 cre_PrivateCustomer_xml/upd_PrivateCustomer_xml: do not deliver mailAddress for MBBEL
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
   G_migrationDate            TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'MIGRATIONDATE',             to_char ( sysdate, 'YYYY-MM-DD"T"HH24:MI:SS' ));
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

   FUNCTION GET_CUST_PARTNER_STATE
          ( i_ID_CUSTOMER       varchar2
          ) RETURN              varchar2 is

          L_COUNT               integer;

   begin
          select count(*)
            into L_COUNT
            from snt.TDFCONTR_STATE@SIMEX_DB_LINK  cstat
               , snt.TFZGVERTRAG@SIMEX_DB_LINK     fzgv
               , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK fzgvc
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
            from snt.TDFCONTR_STATE@SIMEX_DB_LINK  cstat
               , snt.TFZGVERTRAG@SIMEX_DB_LINK     fzgv
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
            from snt.TCUSTOMER@SIMEX_DB_LINK      cust
               , snt.TCUSTOMERTYP@SIMEX_DB_LINK   ctyp
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
     -- FraBe 23.06.2014 MKS-132103:1 no PCK_CALCULATION.remove_alpha anymore
     if   i_phoneNumber is not null
       or i_mobile      is not null
       or i_faxNumber   is not null
       or i_email       is not null
     then select XMLAGG ( XMLELEMENT ( "communicationData"
                                     , xmlattributes
                                           ( substr ( i_phoneNumber, 1, 30 )  as "phoneNumber"
                                           , substr ( i_mobile,      1, 30 )  as "mobile"
                                           , substr ( i_faxNumber,   1, 30 )  as "faxNumber"
                                           ,          i_email                 as "email" )
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
          , i_TAS_GUID           varchar2
          , i_TIMESTAMP          TIMESTAMP
          ) return               XMLTYPE
          as
          
            L_CoPartnerAssignment   xmltype;
   begin
        -- FraBe 06.02.2014 MKS-131001:1 auslagern erstellen node contactPartnerAssignment in eigene function, da das distinct nur �ber 'from ( select distinct ',
        --                               bzw. die where - ID_GARAGE einschr�nkung nur so funktioniert
        -- FraBe 06.03.2014 MKS-131188:1 neue get_dealer_CoPartnerAssignment - IN parameter
        -- FraBe 25.09.2014 MKS-134358:1 / 134359:1 add WavePreInt4
        -- FraBe 09.10.2014 MKS-134426:1 keine GARAGE / SU0% einschr�nkung mehr - details siehe beim code
        -- FraBe 16.12.2014 MKS-136092:1 remove externalId - upper
        select XMLAGG ( XMLELEMENT ( "contactPartnerAssignment"
                      , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                   , i_TIMESTAMP
                                                                   , 'contactRole'
                                                                   , 'salesman' )   as "contactRole"
                                      , 'false'   as "internal"
                                      , 'true'    as "salesman" )
                                      , XMLELEMENT ( "contactPerson"
                                                   , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                   , fzg1.externalId    as "externalId"
                                                                   , I_SourceSystem     as "sourceSystem" 
                                                                   )
                                                   )
                                      )
                      )
          into L_CoPartnerAssignment
          from ( select distinct pck_calculation.get_part_of_bearbeiter_kauf
                                                ( fzgv.FZGV_BEARBEITER_KAUF
                                                , 3
                                                , fzgv.id_vertrag || '/' || fzgv.id_fzgvertrag ) as externalId
                   from snt.TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                      , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                      , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                  where cv.COV_CAPTION      not like 'MIG_OOS%'
                    and cv.id_cov                  = fzgvc.id_cov
                    and fzgv.ID_VERTRAG            = fzgvc.ID_VERTRAG
                    and fzgv.ID_FZGVERTRAG         = fzgvc.ID_FZGVERTRAG
                    and fzgv.ID_GARAGE             = I_ID_GARAGE
                    and fzgv.FZGV_BEARBEITER_KAUF is not null
                     -- MKS-123315:1; TK; GARAGE wird auch ausgegliedert
                     -- MKS-134426:1; FraBe; 09.10.2014: keine einschr�nkung mehr - get_part_of_bearbeiter_kauf liefert dann den TSETTING - DEFAULTSALESPERSON zur�ck
                     -- and upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020','GARAGE' )
               order by 1 ) fzg1;
          
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
      -- FraBe 05.03.2014 MKS-131231:1 wave3.2 �nderungen
      -- FraBe 06.03.2014 MKS-131176:1 change xmlcomment related to CIM
      -- FraBe 02.06.2014 MKS-133073:1 upd_PrivateCustomer_xml: substr ( ..., 1, 10 ) as "financialSystemRevenueId"
      -- FraBe 23.06.2014 MKS-132102:1 / 132103:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
      -- MaZi  01.10.2014 MKS-134410:1 / 134411:1 WavePreInt4 changes
      -- MaZi  26.01.2015 MKS-136189:1 cre_PrivateCustomer_xml/upd_PrivateCustomer_xml: do not deliver mailAddress for MBBEL
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expPrivateCustomer';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename_cre              varchar2 ( 100 char );
      L_filename_upd              varchar2 ( 100 char );
      
      FUNCTION cre_PrivateCustomer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename_cre      := replace ( i_filename_cre, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );

         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_PhysicalPerson(privateCustomer)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
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
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , cust.ID_CUSTOMER                                  as "externalId"
                                                                , G_SourceSystem                                    as "sourceSystem"
                                                                , G_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , 'privateCustomer'                                 as "partnerType"
                                                                , G_migrationDate                                   as "migrationDate"
                                                                , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                 ( cust.ID_CUSTOMER )               as "state"
                                                                , case when nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) = '111111111' 
                                                                       then substr ( name.NAME_CAPTION2, 1,35 )
                                                                       else case when name.NAME_CAPTION2 is null 
                                                                                 then null
                                                                                 else 'TBU_' || substr ( name.NAME_CAPTION2, 1,31 )
                                                                            end
                                                                  end                                               as "firstName"
                                                                , case when nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) = '111111111' 
                                                                       then substr ( name.NAME_CAPTION1, 1,35 )
                                                                       else case when name.NAME_CAPTION1 is null 
                                                                                 then null
                                                                                 else 'TBU_' || substr ( name.NAME_CAPTION1, 1,31 )
                                                                            end
                                                                  end                                               as "lastName"
                                                                , 'false'                                           as "isUserLastLogin"
                                                                /*   MKS-132102 waveFinal: do not send salutation anymore within cre_PrivateCustomer_xml / 
                                                                                           but still extracted within upd_PrivateCustomer_xml !
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'ID_TITLE'
                                                                                             , name.ID_TITLE )      as "salutation"            */
                                                                , case G_COUNTRY_CODE
                                                                  when '51331' then null
                                                                               else cust.CUST_FISCAL_CODE
                                                                  end                                               as "personalFiscalCode" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId"
                                                                                       , decode(cuDom.custdom_locked,0,'0001',   NULL)        AS "financeSystemId"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , decode(cuDom.custdom_locked,0,'true','false')        AS "directDebit"
                                                                                       , decode(cuDom.custdom_locked,0
                                                                                               ,substr(cuDom.CUSTDOM_DOMNUMBER,1,35),NULL)    AS "directDebitCode")
                                                                                      ))
                                                                 from snt.TCUST_BANKING@SIMEX_DB_LINK           cuBa
                                                                    , ( SELECT cd.id_customer
                                                                             , cd.custdom_domnumber
                                                                             , cd.custdom_locked
                                                                          FROM snt.TCUSTOMER_DOM@SIMEX_DB_LINK cd  
                                                                         WHERE cd.custdom_locked = 0 )    cuDom  -- MKS-136525:1
                                                                WHERE cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  AND (   cuBa.CUBA_IBAN       IS NOT NULL 
                                                                       OR cuBa.CUBA_BANK_CODE  IS NOT NULL )
                                                                  AND G_COUNTRY_CODE = '51331'   
                                                                  AND cuDom.CUSTDOM_DOMNUMBER(+) = cuBa.CUBA_BANK_NAME
                                                                  AND cuDom.id_customer(+) = cust.ID_CUSTOMER )                  -- MBBEL L�nderweiche / f�r andere MPC ist noch nix definiert
                                                           , decode ( nvl ( CUST_SAP_NUMBER_DEBITOR, '111111111' )
                                                                                                   , '111111111', pck_partner.get_CommunicationData 
                                                                                                                             ( I_phoneNumber  => name.NAME_TELEFON
                                                                                                                             , I_mobile       => name.NAME_TITEL2
                                                                                                                             , I_faxNumber    => name.NAME_FAX
                                                                                                                             , I_email        => name.NAME_EMAIL )) as "communicationData"   -- MKS-130877:1
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty1.COU_CODE )  as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov1.PROV_CODE )  as "province"
                                                                                , adr1.ADR_STREET1                      as "street"
                                                                                , zip1.ZIP_ZIP                          as "zipCode"
                                                                                , substr ( name1.NAME_CAPTION2, 1, 35 ) as "differingName1"
                                                                                , substr ( name1.NAME_CAPTION1, 1, 35 ) as "differingName2"
                                                                                )))
                                                                      from snt.TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                         , snt.TNAME@SIMEX_DB_LINK          name1
                                                                         , snt.TADRESS@SIMEX_DB_LINK        adr1
                                                                         , snt.TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                         , snt.TZIP@SIMEX_DB_LINK           zip1
                                                                         , snt.TPROVINCE@SIMEX_DB_LINK      prov1
                                                                     where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                       and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                       and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                       and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                       and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                       and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                       and adr1.ADR_STREET1       is not null
                                                                       and G_COUNTRY_CODE         <> '51331' )
                                                           , case when cust.CUST_SAP_NUMBER_DEBITOR is null
                                                                  then null
                                                                  else XMLELEMENT ( "revenueReceipt"
                                                                          , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'CUR_CODE'
                                                                                                                       , cur.CUR_CODE )    as "currency"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'LANG_CODE'
                                                                                                                       , lang.LANG_CODE )  as "language"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'ID_CUSTYP'
                                                                                                                       , cust.ID_CUSTYP )  as "vatClassification"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'PAYM_SHORT_CAPTION'
                                                                                                                       , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                          )
                                                                                  , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                                 , XMLELEMENT ( "temporaryTaxSetting"
                                                                                                      , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                                   , G_TIMESTAMP
                                                                                                                                                   , 'ID_CUSTYP'
                                                                                                                                                   , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                                      , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )        as "validFrom"
                                                                                                                      , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )        as "validTo"
                                                                                                                      )
                                                                                                              )
                                                                                           )
                                                                                  )
                                                             end
                                                          ))
                                order by cust.ID_CUSTOMER )
                                   from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                      , snt.TADRESS@SIMEX_DB_LINK        adr
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                      , snt.TZIP@SIMEX_DB_LINK           zip
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                      , snt.TDF_PAYMENT@SIMEX_DB_LINK    paym
                                      , snt.TNAME@SIMEX_DB_LINK          name
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                      , snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                      , simex.TXML_SPLIT                 s
                                  where paym.GUID_PAYMENT  (+)  = cust.GUID_PAYMENT
                                    and lang.ID_LANGUAGE        = cust.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = cust.ID_CURRENCY
                                    and s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                                    and ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID  => i_TAS_GUID
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
         L_filename_upd      := replace ( i_filename_upd, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );

         --
         -- das select ist im gro�en und ganzen ident zu cre PrivCust - es gibt aber ein paar abweichungen:
         -- operation / firstName / lastName / salutation / communicationData / financialSystemRevenueId / where code im main select
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_PhysicalPerson(privateCustomer)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' as "xsi:type"
                                    , to_char(to_date(g_expdatetime ,pck_calculation.c_xmlDTfmt)
                                              + 1/1440
                                             ,pck_calculation.c_xmlDTfmt
                                             )                        as "dateTime"
                                    , G_userID                        as "userId"
                                    , G_TENANT_ID                     as "tenantId"
                                    , G_causation                     as "causation"
                                    , o_FILE_RUNNING_NO               as "additionalInformation1"
                                    , G_correlationID                 as "correlationId"
                                    , G_issueThreshold                as "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'updatePhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , 'http://partner.icon.daimler.com/pl'              as "xmlns:partner_pl"
                                                                , cust.ID_CUSTOMER                                  as "externalId"
                                                                , G_SourceSystem                                    as "sourceSystem"
                                                                , G_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , 'privateCustomer'                                 as "partnerType"
                                                                , G_migrationDate                                   as "migrationDate"
                                                                , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                 ( cust.ID_CUSTOMER )               as "state"
                                                                , substr ( name.NAME_CAPTION2, 1,35 )               as "firstName"
                                                                , substr ( name.NAME_CAPTION1, 1,35 )               as "lastName"
                                                                , 'false'                                           as "isUserLastLogin"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'ID_TITLE'
                                                                                             , name.ID_TITLE )      as "salutation"
                                                                , case G_COUNTRY_CODE
                                                                  when '51331' then null
                                                                               else cust.CUST_FISCAL_CODE
                                                                  end                                               as "personalFiscalCode" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId"
                                                                                       , decode(cuDom.custdom_locked,0,'0001',   NULL)        AS "financeSystemId"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , decode(cuDom.custdom_locked,0,'true','false')        AS "directDebit"
                                                                                       , decode(cuDom.custdom_locked,0
                                                                                               ,substr(cuDom.CUSTDOM_DOMNUMBER,1,35),NULL)    AS "directDebitCode")
                                                                                      ))
                                                                 from snt.TCUST_BANKING@SIMEX_DB_LINK           cuBa
                                                                   , ( SELECT cd.id_customer
                                                                             , cd.custdom_domnumber
                                                                             , cd.custdom_locked
                                                                          FROM snt.TCUSTOMER_DOM@SIMEX_DB_LINK cd  
                                                                         WHERE cd.custdom_locked = 0 )    cuDom  -- MKS-136525:1
                                                                WHERE cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  AND (   cuBa.CUBA_IBAN       IS NOT NULL 
                                                                       OR cuBa.CUBA_BANK_CODE  IS NOT NULL )
                                                                  AND G_COUNTRY_CODE = '51331'   
                                                                  AND cuDom.CUSTDOM_DOMNUMBER(+) = cuBa.CUBA_BANK_NAME
                                                                  AND cuDom.id_customer(+) = cust.ID_CUSTOMER )  -- MBBEL L�nderweiche / f�r andere MPC ist noch nix definiert
                                                           , pck_partner.get_CommunicationData 
                                                                        ( I_phoneNumber  => name.NAME_TELEFON
                                                                        , I_mobile       => name.NAME_TITEL2
                                                                        , I_faxNumber    => name.NAME_FAX
                                                                        , I_email        => name.NAME_EMAIL )    as "communicationData"   -- MKS-130877:1
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty1.COU_CODE )  as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov1.PROV_CODE )  as "province"
                                                                                , adr1.ADR_STREET1                      as "street"
                                                                                , zip1.ZIP_ZIP                          as "zipCode"
                                                                                , substr ( name1.NAME_CAPTION2, 1, 35 ) as "differingName1"
                                                                                , substr ( name1.NAME_CAPTION1, 1, 35 ) as "differingName2"
                                                                                )))
                                                                      from snt.TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                         , snt.TNAME@SIMEX_DB_LINK          name1
                                                                         , snt.TADRESS@SIMEX_DB_LINK        adr1
                                                                         , snt.TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                         , snt.TZIP@SIMEX_DB_LINK           zip1
                                                                         , snt.TPROVINCE@SIMEX_DB_LINK      prov1
                                                                     where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                       and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                       and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                       and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                       and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                       and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                       and adr1.ADR_STREET1       is not null 
                                                                       and G_COUNTRY_CODE         <> '51331')
                                                           , case when cust.CUST_SAP_NUMBER_DEBITOR is null               --- diese abfrage w�re nich notwendig, da diese schon im where des main selects exkludiert sind
                                                                  then null                                               --- aber so ist das case ident zu cre PrivCust ...
                                                                  else XMLELEMENT ( "revenueReceipt"
                                                                          , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'CUR_CODE'
                                                                                                                       , cur.CUR_CODE )    as "currency"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'LANG_CODE'
                                                                                                                       , lang.LANG_CODE )  as "language"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'ID_CUSTYP'
                                                                                                                       , cust.ID_CUSTYP )  as "vatClassification"
                                                                                          , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                       , G_TIMESTAMP
                                                                                                                       , 'PAYM_SHORT_CAPTION'
                                                                                                                       , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                          , substr ( cust.CUST_SAP_NUMBER_DEBITOR, 1, 10 )         as "financialSystemRevenueId"
                                                                                          )
                                                                                  , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                                 , XMLELEMENT ( "temporaryTaxSetting"
                                                                                                      , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                                   , G_TIMESTAMP
                                                                                                                                                   , 'ID_CUSTYP'
                                                                                                                                                   , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                                      , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )        as "validFrom"
                                                                                                                      , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )        as "validTo"
                                                                                                                      )
                                                                                                              )
                                                                                           )
                                                                                  )
                                                             end
                                                          ))
                                order by cust.ID_CUSTOMER )
                                   from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                      , snt.TADRESS@SIMEX_DB_LINK        adr
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                      , snt.TZIP@SIMEX_DB_LINK           zip
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                      , snt.TDF_PAYMENT@SIMEX_DB_LINK    paym
                                      , snt.TNAME@SIMEX_DB_LINK          name
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                      , snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                      , simex.TXML_SPLIT                 s
                                  where paym.GUID_PAYMENT  (+)  = cust.GUID_PAYMENT
                                    and lang.ID_LANGUAGE        = cust.ID_LANGUAGE
                                    and cur.ID_CURRENCY         = cust.ID_CURRENCY
                                    and s.PK_VALUE_CHAR         = cust.ID_CUSTOMER
                                    and ass.ID_SEQ_ADRASSOZ     = cust.ID_SEQ_ADRASSOZ
                                    and ass.ID_SEQ_NAME         = name.ID_SEQ_NAME (+)
                                    and ass.ID_SEQ_ADRESS       = adr.ID_SEQ_ADRESS (+)
                                    and prov.GUID_PROVINCE (+)  = adr.GUID_PROVINCE
                                    and zip.ID_SEQ_ZIP     (+)  = adr.ID_SEQ_ZIP
                                    and zip.ID_COUNTRY          = cty.ID_COUNTRY (+)
                                    and nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) <> '111111111'
                )).EXTRACT ('.')
                AS xml
           into l_xml
           from DUAL;

         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID  => i_TAS_GUID
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

      FOR crec IN ( SELECT cust.ID_CUSTOMER
                      FROM snt.TCUSTOMER@SIMEX_DB_LINK      cust
                         , snt.TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                     where custtyp.ID_CUSTYP        = cust.ID_CUSTYP
                       and custtyp.CUSTYP_COMPANY   = 1
                       and custtyp.CUSTYP_CAPTION NOT LIKE 'MIG_OOS%'
                       and PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                      , G_TIMESTAMP
                                                      , 'WorkshopAsCustomer'
                                                      , cust.ID_CUSTOMER ) is null
                     order by cust.ID_CUSTOMER )
      LOOP
         INSERT INTO simex.TXML_SPLIT ( PK_VALUE_CHAR )
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
      WHEN pck_calculation.AlreadyLogged THEN
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
      -- FraBe 05.03.2014 MKS-131219:1 wave3.2 �nderungen
      -- FraBe 06.03.2014 MKS-131176:1 change xmlcomment related to CIM
      -- FraBe 15.07.2014 MKS-132089:1 / 132090:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
      -- MaZi  30.09.2014 MKS-134397:1 / 134398:1 expContactPerson: WavePreInt4 changes
      -- FraBe 01.10.2014 MKS-135081:1 fix executionSettings - xmlns:mdsd_sl namespace problem
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expContactPerson';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );

      FUNCTION cre_ContactPerson_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_PhysicalPerson(contactPerson)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
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
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                   as "xsi:type"
                                                                , cust.ID_CUSTOMER || '-CP1'                        as "externalId"
                                                                , G_SourceSystem                                    as "sourceSystem"
                                                                , G_masterDataReleaseVersion                        as "masterDataReleaseVersion"
                                                                , 'contactPerson'                                   as "partnerType"
                                                                , G_migrationDate                                   as "migrationDate"
                                                                , substr ( name.NAME_TITEL1, 1, 35 )                as "lastName"
                                                                , 'false'                                           as "isUserLastLogin"
                                                                )))
                                order by cust.ID_CUSTOMER )
                                   from snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                      , snt.TNAME@SIMEX_DB_LINK          name
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                      , simex.TXML_SPLIT                 s
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

      FOR crec IN ( 
           SELECT DISTINCT ID_CUSTOMER
    FROM (SELECT cust.id_customer
            FROM snt.TCUSTOMER@SIMEX_DB_LINK cust,
                 snt.TCUSTOMERTYP@SIMEX_DB_LINK custtyp,
                 snt.TNAME@SIMEX_DB_LINK name,
                 snt.TADRASSOZ@SIMEX_DB_LINK ass
           WHERE     ass.ID_SEQ_ADRASSOZ = cust.ID_SEQ_ADRASSOZ
                 AND ass.ID_SEQ_NAME = name.ID_SEQ_NAME(+)
                 AND custtyp.ID_CUSTYP = cust.ID_CUSTYP
                 AND custtyp.CUSTYP_COMPANY IN (0, 2)                          -- TK    07.01.2013 MKS-120795:2 change from 1 to 0
                 -- FraBe 25.03.2013 MKS-123188:1 add 2
                 AND custtyp.CUSTYP_CAPTION NOT LIKE 'MIG_OOS%'
                 AND name.NAME_TITEL1 IS NOT NULL
          UNION  -- MKS-134889:1 TK; 2014-09-22 ; Customers referenced by Deales as Customers must always create Contact Persons
          SELECT cust.id_customer
            FROM snt.TCUSTOMER@SIMEX_DB_LINK cust,
                 snt.TNAME@SIMEX_DB_LINK name,
                 snt.TADRASSOZ@SIMEX_DB_LINK ass,
                 SIMEX.TSUBSTITUTE sub
           WHERE     ass.ID_SEQ_ADRASSOZ = cust.ID_SEQ_ADRASSOZ
                 AND ass.ID_SEQ_NAME = name.ID_SEQ_NAME(+)
                 AND name.NAME_TITEL1 IS NOT NULL
                 AND SUB.SUB_SRS_ATT_NAME = 'WorkshopAsCustomer'
                 AND SUB.SUB_SRS_ATT_VALUE = cust.id_customer)
            ORDER BY ID_CUSTOMER
       )
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
      WHEN pck_calculation.AlreadyLogged THEN
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
         -- MaZi  27.02.2014 MKS-131055:1 add substr(cust.CUST_FLEETNUMBER,1,20) (vehicleFleetNumber)
         -- FraBe 05.03.2014 MKS-131171:1 wave3.2 �nderungen
         -- FraBe 06.03.2014 MKS-131176:1 change xmlcomment related to CIM
         -- FraBe 02.06.2014 MKS-133073:1 upd_CommercialCustomer_xml: substr ( ..., 1, 10 ) as "financialSystemRevenueId"
         -- FraBe 21.07.2014 MKS-132033:1 / 132034:1 : einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package      
         -- MaZi  25.09.2014 MKS-134345:1 WavePreInt4 changes
         -- FraBe 01.10.2014 MKS-135081:1 fix executionSettings - xmlns:mdsd_sl namespace problem
         -- MaZi  07.10.2014 MKS-134351:1 upd_CommercialCustomer_xml: add "xsi:type" for contactPerson, mainContactPerson
         -- MaZi  26.01.2015 MKS-136183:1 cre_CommercialCustomer_xml/upd_CommercialCustomer_xml: do not deliver mailAddress for MBBEL
         -------------------------------------------------------------------------------
         l_ret                       INTEGER        DEFAULT 0;
         l_ret_main                  INTEGER        DEFAULT 0;
         lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expCommercialCustomer';
         l_xml                       XMLTYPE;
         l_xml_out                   XMLTYPE;
         L_STAT                      VARCHAR2  (1) := NULL;
         L_ROWCOUNT                  INTEGER;
         L_filename_cre              varchar2 ( 100 char );
         L_filename_upd              varchar2 ( 100 char );
   
         FUNCTION cre_CommercialCustomer_xml
            RETURN INTEGER
         IS
         BEGIN
            o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
            L_filename_cre      := replace ( i_filename_cre, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
            --
            select XMLELEMENT ( "common:ServiceInvocationCollection"
                              , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                              , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                              , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                              , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                              , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                              , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_OrganisationalPerson(commercialCustomer)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                              , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                              , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                              , XMLELEMENT ( "executionSettings"
                                   , xmlattributes
                                       ( 'mdsd_sl:ExecutionSettingsType'      as "xsi:type"
                                       , g_expdatetime                        as "dateTime"
                                       , G_userID                             as "userId"
                                       , G_TENANT_ID                          as "tenantId"
                                       , G_causation                          as "causation"
                                       , o_FILE_RUNNING_NO                    as "additionalInformation1"
                                       , G_correlationID                      as "correlationId"
                                       , G_issueThreshold                     as "issueThreshold"  
                                       ))
                              , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                     , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                         , XMLELEMENT ( "parameter"
                                                              , xmlattributes
                                                                   ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                   , cust.ID_CUSTOMER                                   as "externalId"
                                                                   , G_SourceSystem                                     as "sourceSystem"
                                                                   , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                   , 'commercialCustomer'                               as "partnerType"
                                                                   , G_migrationDate                                    as "migrationDate"
                                                                   , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                    ( cust.ID_CUSTOMER )                as "state"
                                                                   , case when nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) = '111111111'
                                                                               then                     substr ( name.NAME_CAPTION1,  1, 35 )
                                                                               else case when           substr ( name.NAME_CAPTION1,  1, 31 ) is not null
                                                                                         then 'TBU_' || substr ( name.NAME_CAPTION1,  1, 31 )
                                                                                    end
                                                                     end                                                as "companyName"
                                                                   , case when nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) = '111111111'
                                                                               then                     substr ( name.NAME_CAPTION1, 36, 35 )
                                                                               else case when           substr ( name.NAME_CAPTION1, 32, 31 ) is not null
                                                                                         then 'TBU_' || substr ( name.NAME_CAPTION1, 32, 31 )
                                                                                    end
                                                                     end                                                as "companyName2"
                                                                   , decode ( custtyp.CUSTYP_COMPANY, 2, 'yes', 'no' )  as "companyInternal"
                                                                   , cust.CUST_VAT_ID                                   as "vatId" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId"
                                                                                       , decode(cuDom.custdom_locked,0,'0001',   NULL)        AS "financeSystemId"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , decode(cuDom.custdom_locked,0,'true','false')        AS "directDebit"
                                                                                       , decode(cuDom.custdom_locked,0
                                                                                               ,substr(cuDom.CUSTDOM_DOMNUMBER,1,35),NULL)    AS "directDebitCode")
                                                                                      ))
                                                                 from snt.TCUST_BANKING@SIMEX_DB_LINK           cuBa
                                                                    , ( SELECT cd.id_customer
                                                                             , cd.custdom_domnumber
                                                                             , cd.custdom_locked
                                                                          FROM snt.TCUSTOMER_DOM@SIMEX_DB_LINK cd  
                                                                         WHERE cd.custdom_locked = 0 )    cuDom  -- MKS-136525:1
                                                                WHERE cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  AND (   cuBa.CUBA_IBAN       IS NOT NULL 
                                                                       OR cuBa.CUBA_BANK_CODE  IS NOT NULL )
                                                                  AND G_COUNTRY_CODE = '51331'   
                                                                  AND cuDom.CUSTDOM_DOMNUMBER(+) = cuBa.CUBA_BANK_NAME
                                                                  AND cuDom.id_customer(+) = cust.ID_CUSTOMER )
                                                             , pck_partner.get_CommunicationData 
                                                                                     ( I_phoneNumber  => name.NAME_TELEFON
                                                                                     , I_mobile       => name.NAME_TITEL2
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
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'COU_CODE'
                                                                                                                , cty.COU_CODE )    as "country"
                                                                                   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                , G_TIMESTAMP
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
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'COU_CODE'
                                                                                                                , cty1.COU_CODE )  as "country"
                                                                                   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'PROV_CODE'
                                                                                                                , prov1.PROV_CODE )  as "province"
                                                                                   , adr1.ADR_STREET1                       as "street"
                                                                                   , zip1.ZIP_ZIP                           as "zipCode"
                                                                                   , substr ( name1.NAME_CAPTION1,  1, 35 ) as "differingName1"
                                                                                   , substr ( name1.NAME_CAPTION1, 36, 15 ) as "differingName2"
                                                                                   )))
                                                                         from snt.TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                            , snt.TNAME@SIMEX_DB_LINK          name1
                                                                            , snt.TADRESS@SIMEX_DB_LINK        adr1
                                                                            , snt.TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                            , snt.TZIP@SIMEX_DB_LINK           zip1
                                                                            , snt.TPROVINCE@SIMEX_DB_LINK      prov1
                                                                        where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                          and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                          and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                          and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                          and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                          and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                          and adr1.ADR_STREET1       is not null
                                                                          and G_COUNTRY_CODE         <> '51331' )
                                                              , case cust.CUST_SAP_NUMBER_DEBITOR
                                                                     when null then null
                                                                               else XMLELEMENT ( "revenueReceipt"
                                                                                         , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'CUR_CODE'
                                                                                                                                      , cur.CUR_CODE )    as "currency"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'LANG_CODE'
                                                                                                                                      , lang.LANG_CODE )  as "language"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'ID_CUSTYP'
                                                                                                                                      , cust.ID_CUSTYP )  as "vatClassification"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'PAYM_SHORT_CAPTION'
                                                                                                                                      , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                                         )
                                                                                                 , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                                          , XMLELEMENT ( "temporaryTaxSetting"
                                                                                                               , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                                            , G_TIMESTAMP
                                                                                                                                                            , 'ID_CUSTYP'
                                                                                                                                                            , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                                                , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )       as "validFrom"
                                                                                                                                , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )       as "validTo"
                                                                                                                                )
                                                                                                                       )
                                                                                                          ))
                                                                end
                                                              , XMLELEMENT ( "commercialCustomerGlobals"
                                                                   , xmlattributes
                                                                        ( decode ( cust.CUST_FLEETNUMBER
                                                                             , null, 'false', 'true' )            as "fleetCompany" 
                                                                        , substr ( cust.CUST_FLEETNUMBER, 1, 20 ) as "vehicleFleetNumber" )
                                                                        )
                                                              , decode ( name.NAME_TITEL1, null, null
                                                                       , XMLELEMENT ( "contactPartnerAssignment"
                                                                            , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                         , G_TIMESTAMP
                                                                                                                         , 'contactRole'
                                                                                                                         , 'owner' )         as "contactRole"
                                                                                            , 'false'   as "internal"
                                                                                            , 'false'   as "salesman" )
                                                                            , XMLELEMENT ( "contactPerson"
                                                                                 , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                                 , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                                 , G_SourceSystem                  as "sourceSystem"
                                                                                                 )
                                                                                          )
                                                                                    )
                                                                        )
                                                              , decode ( name.NAME_TITEL1, null, null
                                                                       , XMLELEMENT ( "mainContactPerson"
                                                                            , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                            , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                            , G_SourceSystem                  as "sourceSystem"
                                                                                            )
                                                                                    )
                                                                       )
                                                             ))
                                   order by cust.ID_CUSTOMER )
                                      from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                         , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                         , snt.TADRESS@SIMEX_DB_LINK        adr
                                         , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                         , snt.TZIP@SIMEX_DB_LINK           zip
                                         , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                         , snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                         , snt.TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                         , snt.TDF_PAYMENT@SIMEX_DB_LINK    paym
                                         , snt.TNAME@SIMEX_DB_LINK          name
                                         , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                         , simex.TXML_SPLIT                 s
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
            L_filename_upd      := replace ( i_filename_upd, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
   
            --
            select XMLELEMENT ( "common:ServiceInvocationCollection"
                              , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                              , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                              , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                              , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                              , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                              , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_OrganisationalPerson(commercialCustomer)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                              , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                              , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                              , XMLELEMENT ( "executionSettings"
                                   , xmlattributes
                                     ( 'mdsd_sl:ExecutionSettingsType'      as "xsi:type"
                                     , to_char(to_date(g_expdatetime ,pck_calculation.c_xmlDTfmt)
                                               + 1/1440
                                             ,pck_calculation.c_xmlDTfmt
                                              )                             as "dateTime"
                                     , G_userID                             as "userId"
                                     , G_TENANT_ID                          as "tenantId"
                                     , G_causation                          as "causation"
                                     , o_FILE_RUNNING_NO                    as "additionalInformation1"
                                     , G_correlationID                      as "correlationId"
                                     , G_issueThreshold                     as "issueThreshold"
                                     ))
                              , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                     , xmlattributes ( 'updateOrganisationalPerson' AS "operation"  )
                                                         , XMLELEMENT ( "parameter"
                                                              , xmlattributes
                                                                   ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                   , cust.ID_CUSTOMER                                   as "externalId"
                                                                   , G_SourceSystem                                     as "sourceSystem"
                                                                   , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                   , 'commercialCustomer'                               as "partnerType"
                                                                   , G_migrationDate                                    as "migrationDate"
                                                                   , PCK_PARTNER.GET_CUST_PARTNER_STATE 
                                                                                    ( cust.ID_CUSTOMER )                as "state"
                                                                   , substr ( name.NAME_CAPTION1,  1, 35 )              as "companyName"
                                                                   , substr ( name.NAME_CAPTION1, 36, 35 )              as "companyName2"
                                                                   , decode ( custtyp.CUSTYP_COMPANY, 2, 'yes', 'no' )  as "companyInternal"
                                                                   , cust.CUST_VAT_ID                                   as "vatId" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId"
                                                                                       , decode(cuDom.custdom_locked,0,'0001',   NULL)        AS "financeSystemId"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , decode(cuDom.custdom_locked,0,'true','false')        AS "directDebit"
                                                                                       , decode(cuDom.custdom_locked,0
                                                                                               ,substr(cuDom.CUSTDOM_DOMNUMBER,1,35),NULL)    AS "directDebitCode")
                                                                                      ))
                                                                 from snt.TCUST_BANKING@SIMEX_DB_LINK           cuBa
                                                                    , ( SELECT cd.id_customer
                                                                             , cd.custdom_domnumber
                                                                             , cd.custdom_locked
                                                                          FROM snt.TCUSTOMER_DOM@SIMEX_DB_LINK cd  
                                                                         WHERE cd.custdom_locked = 0 )    cuDom  -- MKS-136525:1
                                                                WHERE cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  AND (   cuBa.CUBA_IBAN       IS NOT NULL 
                                                                       OR cuBa.CUBA_BANK_CODE  IS NOT NULL )
                                                                  AND G_COUNTRY_CODE = '51331'   
                                                                  AND cuDom.CUSTDOM_DOMNUMBER(+) = cuBa.CUBA_BANK_NAME
                                                                  AND cuDom.id_customer(+) = cust.ID_CUSTOMER )
                                                             , pck_partner.get_CommunicationData 
                                                                                     ( I_phoneNumber  => name.NAME_TELEFON
                                                                                     , I_mobile       => name.NAME_TITEL2
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
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'COU_CODE'
                                                                                                                , cty.COU_CODE )    as "country"
                                                                                   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                , G_TIMESTAMP
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
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'COU_CODE'
                                                                                                                , cty1.COU_CODE )  as "country"
                                                                                   , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                , G_TIMESTAMP
                                                                                                                , 'PROV_CODE'
                                                                                                                , prov1.PROV_CODE )  as "province"
                                                                                   , adr1.ADR_STREET1                       as "street"
                                                                                   , zip1.ZIP_ZIP                           as "zipCode"
                                                                                   , substr ( name1.NAME_CAPTION1,  1, 35 ) as "differingName1"
                                                                                   , substr ( name1.NAME_CAPTION1, 36, 15 ) as "differingName2"
                                                                                   )))
                                                                         from snt.TADRASSOZ@SIMEX_DB_LINK      ass1
                                                                            , snt.TNAME@SIMEX_DB_LINK          name1
                                                                            , snt.TADRESS@SIMEX_DB_LINK        adr1
                                                                            , snt.TCOUNTRY@SIMEX_DB_LINK       cty1
                                                                            , snt.TZIP@SIMEX_DB_LINK           zip1
                                                                            , snt.TPROVINCE@SIMEX_DB_LINK      prov1
                                                                        where ass1.ID_SEQ_ADRASSOZ    = cust.ID_SEQ_ADRASSOZ2
                                                                          and ass1.ID_SEQ_NAME        = name1.ID_SEQ_NAME (+)
                                                                          and ass1.ID_SEQ_ADRESS      = adr1.ID_SEQ_ADRESS (+)
                                                                          and prov1.GUID_PROVINCE (+) = adr1.GUID_PROVINCE
                                                                          and zip1.ID_SEQ_ZIP     (+) = adr1.ID_SEQ_ZIP
                                                                          and zip1.ID_COUNTRY         = cty1.ID_COUNTRY (+)
                                                                          and adr1.ADR_STREET1       is not null 
                                                                          and G_COUNTRY_CODE         <> '51331' )
                                                              , case cust.CUST_SAP_NUMBER_DEBITOR
                                                                     when null then null
                                                                               else XMLELEMENT ( "revenueReceipt"
                                                                                         , xmlattributes ( substr ( cust.CUST_SAP_NUMBER_DEBITOR, 1, 10 ) as "financialSystemRevenueId"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'CUR_CODE'
                                                                                                                                      , cur.CUR_CODE )    as "currency"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'LANG_CODE'
                                                                                                                                      , lang.LANG_CODE )  as "language"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'ID_CUSTYP'
                                                                                                                                      , cust.ID_CUSTYP )  as "vatClassification"
                                                                                                         , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                      , G_TIMESTAMP
                                                                                                                                      , 'PAYM_SHORT_CAPTION'
                                                                                                                                      , paym.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                                         )
                                                                                                 , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                                          , XMLELEMENT ( "temporaryTaxSetting"
                                                                                                               , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                                            , G_TIMESTAMP
                                                                                                                                                            , 'ID_CUSTYP'
                                                                                                                                                            , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                                                , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )       as "validFrom"
                                                                                                                                , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )       as "validTo"
                                                                                                                                )
                                                                                                                       )
                                                                                                          ))
                                                                end
                                                              , XMLELEMENT ( "commercialCustomerGlobals"
                                                                   , xmlattributes
                                                                        ( decode ( cust.CUST_FLEETNUMBER
                                                                             , null, 'false', 'true' )            as "fleetCompany" 
                                                                        , substr ( cust.CUST_FLEETNUMBER, 1, 20 ) as "vehicleFleetNumber" )
                                                                        )
                                                              , decode ( name.NAME_TITEL1, null, null
                                                                       , XMLELEMENT ( "contactPartnerAssignment"
                                                                            , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                         , G_TIMESTAMP
                                                                                                                         , 'contactRole'
                                                                                                                         , 'owner' )         as "contactRole"
                                                                                            , 'false'   as "internal"
                                                                                            , 'false'   as "salesman" )
                                                                            , XMLELEMENT ( "contactPerson"
                                                                                 , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                                 , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                                 , G_SourceSystem                  as "sourceSystem"
                                                                                                 )
                                                                                          )
                                                                                    )
                                                                        )
                                                              , decode ( name.NAME_TITEL1, null, null
                                                                       , XMLELEMENT ( "mainContactPerson"
                                                                            , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                            , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                            , G_SourceSystem                  as "sourceSystem"
                                                                                            )
                                                                                    )
                                                                       )
                                                             ))
                                   order by cust.ID_CUSTOMER )
                                      from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                         , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                         , snt.TADRESS@SIMEX_DB_LINK        adr
                                         , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                         , snt.TZIP@SIMEX_DB_LINK           zip
                                         , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                         , snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                         , snt.TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                                         , snt.TDF_PAYMENT@SIMEX_DB_LINK    paym
                                         , snt.TNAME@SIMEX_DB_LINK          name
                                         , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                         , simex.TXML_SPLIT                 s
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
                                       and nvl ( cust.CUST_SAP_NUMBER_DEBITOR, '111111111' ) <> '111111111'
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
                         FROM snt.TCUSTOMER@SIMEX_DB_LINK      cust
                            , snt.TCUSTOMERTYP@SIMEX_DB_LINK   custtyp
                        where custtyp.ID_CUSTYP        = cust.ID_CUSTYP
                          and custtyp.CUSTYP_COMPANY  in ( 0, 2 )
                          and custtyp.CUSTYP_CAPTION NOT LIKE 'MIG_OOS%'
                          and PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                         , G_TIMESTAMP
                                                         , 'WorkshopAsCustomer'
                                                         , ID_CUSTOMER ) is null
                        order by ID_CUSTOMER )
         LOOP
            INSERT INTO simex.TXML_SPLIT ( PK_VALUE_CHAR )
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
         WHEN pck_calculation.AlreadyLogged THEN
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
      -- FraBe 05.03.2014  MKS-131207:1 wave3.2 �nderungen
      -- FraBe 06.03.2014  MKS-131176:1 change xmlcomment related to CIM
      -- FraBe 18.07.2014  MKS-132076:1 / 132077:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
      -- FraBe 10.08.2014  MKS-132081:1 bei CountryCode = MBBEL = '51331': exportiere auch workshops mit GAR_GARNOVEGA is null
      -- MaZi  30.09.2014  MKS-134384:1 WavePreInt4 changes
      -- FraBe 01.10.2014  MKS-135081:1 fix executionSettings - xmlns:mdsd_sl namespace problem
      -- FraBe 10.11.2014  MKS-135538:1 wavePreInt4 - get workshop state value from GS 'WORKSHOPSTATUS'
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expWorkshop';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_WorkshopStatus            TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'WORKSHOPSTATUS', null );
      
      FUNCTION cre_Workshop_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_OrganisationalPerson(workshop)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType'      as "xsi:type"
                                    , g_expdatetime                        as "dateTime"
                                    , G_userID                             as "userId"
                                    , G_TENANT_ID                          as "tenantId"
                                    , G_causation                          as "causation"
                                    , o_FILE_RUNNING_NO                    as "additionalInformation1"
                                    , G_correlationID                      as "correlationId"
                                    , G_issueThreshold                     as "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'W' || gar.ID_GARAGE                               as "externalId"
                                                                , G_SourceSystem                                     as "sourceSystem"
                                                                , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'workshop'                                         as "partnerType"
                                                                , L_WorkshopStatus                                   as "state"                   -- MKS-135538:1
                                                                , G_migrationDate                                    as "migrationDate"
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
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
                                                                 from snt.TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                                                                where fzgv.ID_GARAGE             = gar.ID_GARAGE
                                                                  and fzgv.FZGV_BEARBEITER_KAUF is not null
                                                                  -- MKS-123315:1; TK; GARAGE wird auch ausgegliedert
                                                                  and upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020','GARAGE' )
                                                             ) */   -- ist obsolete lt. MKS-130879:1
                                                           , XMLELEMENT ( "costIssuer"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) AS "taxClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , substr ( gar.GAR_FI_CREDITOR, 1, 10 ) as "financialSystemCostId"
                                                                                , 'true'                                as "waitForCreditNote"
                                                                                ))
                                                          ))
                                order by gar.ID_GARAGE )
                                   from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                      , snt.TADRESS@SIMEX_DB_LINK        adr
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                      , snt.TZIP@SIMEX_DB_LINK           zip
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                      , snt.TGARAGE@SIMEX_DB_LINK        gar
                                      , snt.TGARAGETYP@SIMEX_DB_LINK     gartyp
                                      , snt.TNAME@SIMEX_DB_LINK          name
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                      , simex.TXML_SPLIT                 s
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
                      FROM snt.TGARAGE@SIMEX_DB_LINK
                     where (( G_COUNTRY_CODE  = '51331' and ( GAR_IS_SERVICE_PROVIDER  = 0 and nvl ( GAR_GARNOVEGA, ' ' ) <> '11924' ))
                         or ( G_COUNTRY_CODE <> '51331' and   GAR_IS_SERVICE_PROVIDER  = 0 ))
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
      WHEN pck_calculation.AlreadyLogged THEN
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
      -- FraBe 05.03.2014 MKS-131195:1 wave3.2 �nderungen
      -- FraBe 06.03.2014 MKS-131176:1 change xmlcomment related to CIM
      -- FraBe 06.03.2014 MKS-131200:1 do not deliver gssnOutletOutletId anymore
      -- FraBe 30.06.2014 MKS-132063:1 / 132064:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
      -- MaZi  29.09.2014 MKS-134371:1 / 134372:2 WavePreInt4 changes
      -- FraBe 01.10.2014 MKS-135081:1 fix executionSettings - xmlns:mdsd_sl namespace problem
      -------------------------------------------------------------------------------
      l_ret                        INTEGER        DEFAULT 0;
      l_ret_main                   INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT      VARCHAR2 (100) DEFAULT 'expSupplier';
      l_xml                        XMLTYPE;
      l_xml_out                    XMLTYPE;
      L_STAT                       VARCHAR2  (1) := NULL;
      L_ROWCOUNT                   INTEGER;
      L_filename                   varchar2 ( 100 char );
      L_SupplierStatus             TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'SUPPLIERSTATUS',             null );
      L_ThresholdIndividualInvoice TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'THRESHOLDINDIVIDUALINVOICE', '0' );
      L_ThresholdMonthlyInvoice    TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'THRESHOLDMONTHLYINVOICE',    '0' );

      FUNCTION cre_Supplier_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_OrganisationalPerson(supplier)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
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
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , gar.ID_GARAGE                                      as "externalId"
                                                                , G_SourceSystem                                     as "sourceSystem"
                                                                , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'supplier'                                         as "partnerType"
                                                                , G_migrationDate                                    as "migrationDate"
                                                                , L_SupplierStatus                                   as "state"
                                                                , substr ( name.NAME_CAPTION1, 1, 35 )               as "companyName"
                                                                , substr ( name.NAME_CAPTION2, 1, 35 )               as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , substr ( gar.GAR_GARNOVEGA, 1, 5 )                 as "claimingSystemId"
                                                             -- , 'GS1234567'                                        as "gssnOutletOutletId"  -- MKS-131200:1 do not deliver gssnOutletOutletId anymore
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
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
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) as "vatClassification"
                                                                                , substr ( gar.GAR_FI_DEBITOR, 1, 10 ) as "financialSystemRevenueId"
                                                                                )))
                                                           , XMLELEMENT ( "costIssuer"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
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
                                order by gar.ID_GARAGE )
                                   from snt.TLANGUAGE@SIMEX_DB_LINK      lang
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur
                                      , snt.TADRESS@SIMEX_DB_LINK        adr
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty
                                      , snt.TZIP@SIMEX_DB_LINK           zip
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov
                                      , snt.TGARAGE@SIMEX_DB_LINK        gar
                                      , snt.TGARAGETYP@SIMEX_DB_LINK     gartyp
                                      , snt.TNAME@SIMEX_DB_LINK          name
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass
                                      , simex.TXML_SPLIT                 s
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
                      FROM snt.TGARAGE@SIMEX_DB_LINK
                     where (( G_COUNTRY_CODE  = '51331' and ( GAR_IS_SERVICE_PROVIDER  = 1 or GAR_GARNOVEGA = '11924' ))
                         or ( G_COUNTRY_CODE <> '51331' and   GAR_IS_SERVICE_PROVIDER  = 1 ))
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
      WHEN pck_calculation.AlreadyLogged THEN
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
      -- FraBe    05.03.2014 MKS-131243:1 wave3.2 �nderungen
      -- FraBe    06.03.2014 MKS-131176:1 change xmlcomment related to CIM
      -- FraBe    25.06.2014 MKS-132115:1 / 132116:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
      -- FraBe    03.10.2014 MKS-134423:1 / 134424:1 einbau wavePreInt4
      -- FraBe    10.10.2014 MKS-134429:2 add L_DEFAULTSALESPERSON - defaultvalue
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expSalesman';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DEFAULTSALESPERSON        TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'DEFAULTSALESPERSON', 'DDEFAULT' );
      
      FUNCTION cre_salesman_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );
      
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          AS "xmlns:common"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  AS "xmlns:xsi"
                                           , 'http://partner.icon.daimler.com/pl'         AS "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              AS "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_PhysicalPerson(salesman)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
                           , XMLCOMMENT ( 'Related to Masterdata:' || G_masterDataVersion )
                           , XMLCOMMENT ( 'Source-database: '      || G_DB_NAME_of_DB_LINK )
                           , XMLELEMENT ( "executionSettings"
                                , xmlattributes
                                    ( 'mdsd_sl:ExecutionSettingsType' AS "xsi:type"
                                    , g_expdatetime                   AS "dateTime"
                                    , G_userID                        AS "userId"
                                    , G_TENANT_ID                     AS "tenantId"
                                    , G_causation                     AS "causation"
                                    , o_FILE_RUNNING_NO               AS "additionalInformation1"
                                    , G_correlationID                 AS "correlationId"
                                    , G_issueThreshold                as "issueThreshold"
                                    ))
                           , ( select XMLAGG ( XMLELEMENT ( "invocation"
                                                  , xmlattributes ( 'createPhysicalPerson' AS "operation"  )
                                                  , XMLELEMENT ( "parameter"
                                                        , xmlattributes
                                                                ( 'partner_pl:PhysicalPersonType'                    AS "xsi:type"
                                                                , main_sel.externalId                                AS "externalId"
                                                                , G_SourceSystem                                     AS "sourceSystem"
                                                                , G_masterDataReleaseVersion                         AS "masterDataReleaseVersion"
                                                                , 'salesman'                                         AS "partnerType"
                                                                , G_migrationDate                                    as "migrationDate"
                                                                , main_sel.firstName                                 AS "firstName"
                                                                , main_sel.lastName                                  AS "lastName"
                                                                , 'false'                                            AS "isUserLastLogin"
                                                                , main_sel.externalId                                AS "dealerDirectoryUid"  
                                                                ))))
                                   from ( select 0                                                as sort
                                               , pck_calculation.get_part_of_bearbeiter_kauf
                                                                ( fzg.FZGV_BEARBEITER_KAUF, 1 )   AS lastName
                                               , pck_calculation.get_part_of_bearbeiter_kauf
                                                                ( fzg.FZGV_BEARBEITER_KAUF, 2 )   AS firstName
                                               , pck_calculation.get_part_of_bearbeiter_kauf
                                                                ( fzg.FZGV_BEARBEITER_KAUF, 3
                                                                , fzg.ID_VERTRAG || '/' ||
                                                                  fzg.ID_FZGVERTRAG )             AS externalId  
                                            from snt.TFZGVERTRAG@SIMEX_DB_LINK    fzg
                                               , simex.TXML_SPLIT                 x
                                           where x.PK_VALUE_CHAR = fzg.GUID_CONTRACT
                                           union
                                          select 99                                               as sort
                                               , 'DUMMY'                                          as lastName
                                               , 'DUMMY'                                          as firstName
                                               , L_DEFAULTSALESPERSON                             as externalId
                                            from dual
                                        order by 1, 4, 2, 3 ) main_sel
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
      -- MKS-132116:1 FraBe: neue waveFinal Logik
      FOR crec IN ( select min ( GUID_CONTRACT )  as GUID_CONTRACT
                         , lastName
                         , firstName
                         , externalId
                      from ( select GUID_CONTRACT
                                  , pck_calculation.GET_PART_OF_BEARBEITER_KAUF ( fzgv.FZGV_BEARBEITER_KAUF, 1 )  as lastName
                                  , pck_calculation.GET_PART_OF_BEARBEITER_KAUF ( fzgv.FZGV_BEARBEITER_KAUF, 2 )  as firstName
                                  , pck_calculation.GET_PART_OF_BEARBEITER_KAUF ( fzgv.FZGV_BEARBEITER_KAUF, 3
                                                                                , fzgv.ID_VERTRAG || '/' || fzgv.ID_FZGVERTRAG ) as externalId
                               from snt.TFZGVERTRAG@SIMEX_DB_LINK      fzgv
                                  , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK cv
                                  , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK  fzgvc
                              where upper ( fzgv.FZGV_BEARBEITER_KAUF ) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020', 'GARAGE' )
                                and fzgv.FZGV_BEARBEITER_KAUF is not null
                                and cv.COV_CAPTION      not like 'MIG_OOS%'
                                and cv.id_cov                  = fzgvc.id_cov
                                and fzgv.ID_VERTRAG            = fzgvc.ID_VERTRAG
                                and fzgv.ID_FZGVERTRAG         = fzgvc.ID_FZGVERTRAG )
                     group by externalId, lastName, firstName
                     order by externalId, lastName, firstName )
      LOOP
         insert into TXML_SPLIT ( PK_VALUE_CHAR )
              VALUES ( crec.GUID_CONTRACT );

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
      WHEN pck_calculation.AlreadyLogged THEN
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
      -- FraBe 05.03.2014 MKS-131183:1 wave3.2 �nderungen
      -- FraBe 06.03.2014 MKS-131176:1 change xmlcomment related to CIM
      -- FraBe 06.03.2014 MKS-131188:1 neue get_dealer_CoPartnerAssignment - IN parameter
      -- FraBe 01.07.2014 MKS-132046:1 / 132047:1 einbau waveFinal plus move all global used L_ vars as G_ (-> global ) vars to the beginning of package
      -- FraBe 31.07.2014 MKS-134047:1 Entfernung der Einschr�nkung GAR_GANOVEGA = 11924
      -- FraBe 25.09.2014 MKS-134358:1 / 134359:1 add WavePreInt4
      -- FraBe 01.10.2014 MKS-135081:1 fix executionSettings - xmlns:mdsd_sl namespace problem
      -- MaZi  26.01.2015 MKS-136183:1 cre_Dealer_xml: do not deliver mailAddress for MBBEL
      -------------------------------------------------------------------------------
      l_ret                       INTEGER        DEFAULT 0;
      l_ret_main                  INTEGER        DEFAULT 0;
      lc_sub_modul   CONSTANT     VARCHAR2 (100) DEFAULT 'expDealer';
      l_xml                       XMLTYPE;
      l_xml_out                   XMLTYPE;
      L_STAT                      VARCHAR2  (1) := NULL;
      L_ROWCOUNT                  INTEGER;
      L_filename                  varchar2 ( 100 char );
      L_DealerStatus              TSETTING.SET_VALUE%TYPE := pck_calculation.get_setting ( 'SETTING', 'DEALERSTATUS',             null );

      FUNCTION cre_Dealer_xml
         RETURN INTEGER
      IS
      BEGIN
         o_FILE_RUNNING_NO   := o_FILE_RUNNING_NO + 1;
         L_filename          := replace ( i_filename, '.xml', to_char ( lpad ( o_FILE_RUNNING_NO, PCK_CALCULATION.get_setting('SETTING', 'FILECOUNT_FILLER', 5), 0 ) ) || '.xml' );   -- FraBe 27.03.2013 MKS-123938:1
         --
         select XMLELEMENT ( "common:ServiceInvocationCollection"
                           , xmlattributes ( 'http://common.icon.daimler.com/il'          as "xmlns:common"
                                           , 'http://partner.icon.daimler.com/pl'         as "xmlns:partner_pl"
                                           , 'http://system.mdsd.ibm.com/sl'              as "xmlns:mdsd_sl"
                                           , 'http://www.w3.org/2001/XMLSchema-instance'  as "xmlns:xsi"
                                           , 'http://www.w3.org/2001/XMLSchema'           as "xmlns:xsd" )
                           , XMLCOMMENT ( 'Related to CIM: 20140811_CIM_EDF_OrganisationalPerson(dealer)_Mig_BEL_WavePreInt4_iter1_v1.0.xlsx' )
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
                                                  , xmlattributes ( 'createOrganisationalPerson' as "operation"  )
                                                      , XMLELEMENT ( "parameter"
                                                           , xmlattributes
                                                                ( 'partner_pl:OrganisationalPersonType'              as "xsi:type"
                                                                , 'D' || gar.ID_GARAGE                               as "externalId"
                                                                , G_SourceSystem                                     as "sourceSystem"
                                                                , G_masterDataReleaseVersion                         as "masterDataReleaseVersion"
                                                                , 'dealer'                                           as "partnerType"
                                                                , L_DealerStatus                                     as "state"
                                                                , G_migrationDate                                    as "migrationDate"
                                                                , substr ( name_gar.NAME_CAPTION1, 1, 35 )           as "companyName"
                                                                , substr ( name_gar.NAME_CAPTION2, 1, 35 )           as "companyName2"
                                                                , decode ( gartyp.GARTYP_COMPANY, 2, 'yes', 'no' )   as "companyInternal"
                                                                , gar.GAR_VAT_ID                                     as "vatId"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'gssnOutletCompanyId'
                                                                                             , gar.ID_GARAGE )       as "gssnOutletCompanyId"
                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                             , G_TIMESTAMP
                                                                                             , 'gssnOutletOutletId'
                                                                                             , gar.ID_GARAGE )       as "gssnOutletOutletId" )
                                                           , ( select XMLAGG ( XMLELEMENT ( "bankAccount"
                                                                                  , xmlattributes
                                                                                       ( lpad ( nvl ( substr ( cuBa.CUBA_IBAN,      1, 34 ), '0' ), 34, '0' )
                                                                                      || lpad ( nvl ( substr ( cuBa.CUBA_BANK_CODE, 1, 15 ), '0' ), 15, '0' )   as "code"
                                                                                       , substr ( cuBa.CUBA_BANK_CODE, 1, 15 )                as "bankId"
                                                                                       , decode(cuDom.custdom_locked,0,'0001',   NULL)        AS "financeSystemId"
                                                                                       , substr ( cuBa.CUBA_IBAN,      1, 34 )                as "ibanCode"
                                                                                       , decode(cuDom.custdom_locked,0,'true','false')        AS "directDebit"
                                                                                       , decode(cuDom.custdom_locked,0
                                                                                               ,substr(cuDom.CUSTDOM_DOMNUMBER,1,35),NULL)    AS "directDebitCode")
                                                                                      ))
                                                                 from snt.TCUST_BANKING@SIMEX_DB_LINK           cuBa
                                                                    , ( SELECT cd.id_customer
                                                                             , cd.custdom_domnumber
                                                                             , cd.custdom_locked
                                                                          FROM snt.TCUSTOMER_DOM@SIMEX_DB_LINK cd  
                                                                         WHERE cd.custdom_locked = 0 )    cuDom  -- MKS-136525:1
                                                                WHERE cuBa.GUID_CUSTOMER = cust.GUID_CUSTOMER
                                                                  AND (   cuBa.CUBA_IBAN       IS NOT NULL 
                                                                       OR cuBa.CUBA_BANK_CODE  IS NOT NULL )
                                                                  AND G_COUNTRY_CODE = '51331'   
                                                                  AND cuDom.CUSTDOM_DOMNUMBER(+) = cuBa.CUBA_BANK_NAME
                                                                  AND cuDom.id_customer(+) = cust.ID_CUSTOMER )                 -- MBBEL L�nderweiche / f�r andere MPC ist noch nix definiert
                                                           , pck_partner.get_CommunicationData 
                                                                                   ( I_phoneNumber  => name_gar.NAME_TELEFON
                                                                                   , I_faxNumber    => name_gar.NAME_FAX
                                                                                   , I_email        => name_gar.NAME_EMAIL ) as "communicationData"   -- MKS-130877:1
                                                                                   
                                                           , case when cust.ID_CUSTOMER is not null
                                                                  then XMLELEMENT ( "customerGlobal"
                                                                           , xmlattributes
                                                                                  ( 'false'     as "blackListed"
                                                                                  , 'unknown'   as "partnerMarketingAllowance"
                                                                                  , 'false'     as "showCustomerInClaimingSystem" ))
                                                                   else null
                                                             end
                                                           , decode ( adr_gar.ADR_STREET1, null, null
                                                                    , XMLELEMENT ( "legalAddress"
                                                                         , xmlattributes ( adr_gar.ADR_STREET2       as "additionalAddressInfo"
                                                                                , substr ( zip_gar.ZIP_CITY, 1, 40 ) as "city"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'COU_CODE'
                                                                                                             , cty_gar.COU_CODE )    as "country"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'PROV_CODE'
                                                                                                             , prov_gar.PROV_CODE )  as "province"
                                                                                , adr_gar.ADR_STREET1                as "street"
                                                                                , zip_gar.ZIP_ZIP                    as "zipCode"
                                                                                         )
                                                                        ))
                                                           , case when G_COUNTRY_CODE         <> '51331'
                                                                  then decode ( adr_cust.ADR_STREET1, null, null
                                                                              , XMLELEMENT ( "mailAddress"
                                                                                 , xmlattributes ( adr_cust.ADR_STREET2       as "additionalAddressInfo"
                                                                                        , substr ( zip_cust.ZIP_CITY, 1, 40 ) as "city"
                                                                                        , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                     , G_TIMESTAMP
                                                                                                                     , 'COU_CODE'
                                                                                                                     , cty_cust.COU_CODE )    as "country"
                                                                                        , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                     , G_TIMESTAMP
                                                                                                                     , 'PROV_CODE'
                                                                                                                     , prov_cust.PROV_CODE )  as "province"
                                                                                        , adr_cust.ADR_STREET1                       as "street"
                                                                                        , zip_cust.ZIP_ZIP                           as "zipCode"
                                                                                        , substr ( name_cust.NAME_CAPTION1,  1, 35 ) as "differingName1"
                                                                                        , substr ( name_cust.NAME_CAPTION1, 36, 15 ) as "differingName2"
                                                                                            )
                                                                                ))
                                                                  else null
                                                             end
                                                           , case when     cust.ID_CUSTOMER    is null 
                                                                       and gar.GAR_FI_DEBITOR  is not null
                                                                  then XMLELEMENT ( "revenueReceipt"
                                                                           , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'CUR_CODE'
                                                                                                                        , cur_gar.CUR_CODE )   as "currency"
                                                                                           , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'LANG_CODE'
                                                                                                                        , lang_gar.LANG_CODE ) as "language"
                                                                                           , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'ID_GARAGETYP'
                                                                                                                        , gar.ID_GARAGETYP ) as "vatClassification"
                                                                                           , substr ( gar.GAR_FI_DEBITOR, 1, 10 )            as "financialSystemRevenueId"
                                                                                           ))
                                                                  else null
                                                             end
                                                           , case when     cust.ID_CUSTOMER              is not null 
                                                                       and cust.CUST_SAP_NUMBER_DEBITOR  is not null
                                                                  then XMLELEMENT ( "revenueReceipt"
                                                                           , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'CUR_CODE'
                                                                                                                        , cur_cust.CUR_CODE )   as "currency"
                                                                                           , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'LANG_CODE'
                                                                                                                        , lang_cust.LANG_CODE ) as "language"
                                                                                           , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'ID_CUSTYP'
                                                                                                                        , cust.ID_CUSTYP )      as "vatClassification"
                                                                                           , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                        , G_TIMESTAMP
                                                                                                                        , 'PAYM_SHORT_CAPTION'
                                                                                                                        , paym_cust.PAYM_SHORT_CAPTION ) as "paymentTerm"
                                                                                           , substr ( cust.CUST_SAP_NUMBER_DEBITOR, 1, 10 )  as "financialSystemRevenueId"
                                                                                           )
                                                                                  , decode ( cust.CUST_REDVAT_FROM, null, null
                                                                                                 , XMLELEMENT ( "temporaryTaxSetting"
                                                                                                      , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                                                   , G_TIMESTAMP
                                                                                                                                                   , 'ID_CUSTYP'
                                                                                                                                                   , cust.ID_CUSTYP_REDVAT )  as "temporaryTaxClassification"
                                                                                                                      , to_char ( cust.CUST_REDVAT_FROM,  'YYYYMMDD' )        as "validFrom"
                                                                                                                      , to_char ( cust.CUST_REDVAT_UNTIL, 'YYYYMMDD' )        as "validTo"
                                                                                                                      )
                                                                                                              )
                                                                                           ))
                                                                  else null
                                                             end
                                                           , case when cust.ID_CUSTOMER              is not null 
                                                                  then XMLELEMENT ( "commercialCustomerGlobals"
                                                                          , xmlattributes
                                                                               ( decode ( cust.CUST_FLEETNUMBER
                                                                                    , null, 'false', 'true' )            as "fleetCompany" 
                                                                               , substr ( cust.CUST_FLEETNUMBER, 1, 20 ) as "vehicleFleetNumber" ))
                                                             end
                                                           , pck_partner.get_dealer_CoPartnerAssignment ( gar.ID_GARAGE
                                                                                                        , G_SourceSystem
                                                                                                        , i_TAS_GUID
                                                                                                        , G_TIMESTAMP )    as "contactPartnerAssignment"
                                                           , decode ( name_cust.NAME_TITEL1, null, null
                                                                    , XMLELEMENT ( "contactPartnerAssignment"
                                                                         , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                                      , G_TIMESTAMP
                                                                                                                      , 'contactRole'
                                                                                                                      , 'owner' ) as "contactRole"
                                                                                         , 'false'   as "internal"
                                                                                         , 'false'   as "salesman" )
                                                                         , XMLELEMENT ( "contactPerson"
                                                                              , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                              , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                              , G_SourceSystem             as "sourceSystem" 
                                                                                              )
                                                                                       )
                                                                                 )
                                                                     )
                                                        /* , XMLELEMENT ( "costIssuer"
                                                                , xmlattributes ( PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'CUR_CODE'
                                                                                                             , cur.CUR_CODE )     as "currency"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'LANG_CODE'
                                                                                                             , lang.LANG_CODE )   as "language"
                                                                                , PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                                                                             , G_TIMESTAMP
                                                                                                             , 'ID_GARAGETYP'
                                                                                                             , gar.ID_GARAGETYP ) AS "vatClassification"
                                                                                , 'false'                               as "commissionCollectiveInvoice"
                                                                                , 'false'                               as "externalNumberResetEveryYear"
                                                                                , lpad ( gar.GAR_FI_CREDITOR, 16, '0' ) as "financialSystemCostId"
                                                                                , 'true'                                as "waitForCreditNote"
                                                                                )) */ -- costIssuer is obsolete due to MKS-130873:1
                                                           , decode ( name_cust.NAME_TITEL1, null, null
                                                                    , XMLELEMENT ( "mainContactPerson"
                                                                              , xmlattributes ( 'partner_pl:PhysicalPersonType' as "xsi:type"
                                                                                              , cust.ID_CUSTOMER || '-CP1'      as "externalId"
                                                                                              , G_SourceSystem             as "sourceSystem" 
                                                                                              )
                                                                                 )
                                                                     )
                                                          ))
                                order by gar.ID_GARAGE )
                                   from snt.TDF_PAYMENT@SIMEX_DB_LINK    paym_cust
                                      , snt.TLANGUAGE@SIMEX_DB_LINK      lang_cust
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur_cust
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty_cust
                                      , snt.TZIP@SIMEX_DB_LINK           zip_cust
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov_cust
                                      , snt.TADRESS@SIMEX_DB_LINK        adr_cust
                                      , snt.TNAME@SIMEX_DB_LINK          name_cust
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass_cust
                                      , snt.TCUSTOMER@SIMEX_DB_LINK      cust
                                      , snt.TLANGUAGE@SIMEX_DB_LINK      lang_gar
                                      , snt.TCURRENCY@SIMEX_DB_LINK      cur_gar
                                      , snt.TCOUNTRY@SIMEX_DB_LINK       cty_gar
                                      , snt.TZIP@SIMEX_DB_LINK           zip_gar
                                      , snt.TPROVINCE@SIMEX_DB_LINK      prov_gar
                                      , snt.TADRESS@SIMEX_DB_LINK        adr_gar
                                      , snt.TNAME@SIMEX_DB_LINK          name_gar
                                      , snt.TADRASSOZ@SIMEX_DB_LINK      ass_gar
                                      , snt.TGARAGE@SIMEX_DB_LINK        gar
                                      , snt.TGARAGETYP@SIMEX_DB_LINK     gartyp
                                      , simex.TXML_SPLIT                 s
                                      , (SELECT SUB_SRS_ATT_VALUE,SUB_ICO_ATT_VALUE FROM simex.TSUBSTITUTE  where SUB_SRS_ATT_NAME  = 'WorkshopAsCustomer') calc
                                  where to_char( gar.ID_GARAGE)  =     calc.SUB_ICO_ATT_VALUE(+)
                                    AND cust.ID_CUSTOMER         (+) = calc.SUB_SRS_ATT_VALUE
                                    and paym_cust.GUID_PAYMENT   (+) = cust.GUID_PAYMENT
                                    and lang_cust.ID_LANGUAGE    (+) = cust.ID_LANGUAGE
                                    and cur_cust.ID_CURRENCY     (+) = cust.ID_CURRENCY
                                    and ass_cust.ID_SEQ_ADRASSOZ (+) = cust.ID_SEQ_ADRASSOZ
                                    and ass_cust.ID_SEQ_NAME         = name_cust.ID_SEQ_NAME (+)
                                    and ass_cust.ID_SEQ_ADRESS       = adr_cust.ID_SEQ_ADRESS (+)
                                    and prov_cust.GUID_PROVINCE  (+) = adr_cust.GUID_PROVINCE
                                    and zip_cust.ID_SEQ_ZIP      (+) = adr_cust.ID_SEQ_ZIP
                                    and zip_cust.ID_COUNTRY          = cty_cust.ID_COUNTRY (+)
                                    and lang_gar.ID_LANGUAGE         = gar.ID_LANGUAGE
                                    and cur_gar.ID_CURRENCY          = gar.ID_CURRENCY
                                    and s.PK_VALUE_NUM               = gar.ID_GARAGE
                                    and ass_gar.ID_SEQ_ADRASSOZ      = gar.ID_SEQ_ADRASSOZ
                                    and ass_gar.ID_SEQ_NAME          = name_gar.ID_SEQ_NAME (+)
                                    and gartyp.ID_GARAGETYP          = gar.ID_GARAGETYP
                                    and ass_gar.ID_SEQ_ADRESS        = adr_gar.ID_SEQ_ADRESS (+)
                                    and prov_gar.GUID_PROVINCE  (+)  = adr_gar.GUID_PROVINCE
                                    and zip_gar.ID_SEQ_ZIP      (+)  = adr_gar.ID_SEQ_ZIP
                                    and zip_gar.ID_COUNTRY           = cty_gar.ID_COUNTRY (+)
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
                      FROM snt.TGARAGE@SIMEX_DB_LINK
                     where GAR_IS_SERVICE_PROVIDER  = 0
                       and PCK_CALCULATION.SUBSTITUTE ( i_TAS_GUID
                                                      , G_TIMESTAMP
                                                      , 'gssnOutletOutletId'
                                                      , ID_GARAGE ) is not null
                   /* MKS-134047:1 Entfernung der Einschr�nkung GAR_GANOVEGA = 11924
                       and (  G_COUNTRY_CODE  <> '51331'
                         or ( G_COUNTRY_CODE   = '51331' and GAR_GARNOVEGA <> '11924' ))    -- bei MBBEL eine weitere einschr�mkung auf GAR_GARNOVEGA <> '11924'
                   */
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
      WHEN pck_calculation.AlreadyLogged THEN
         RETURN -1;         -- meldung braucht kein zweites mal geloggt werden
      WHEN OTHERS THEN
         PCK_EXPORTER.SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                               , i_LOG_ID     => '0005' -- something wrong within creation exportfile
                               , i_LOG_TEXT   => SQLERRM );
         RETURN -1;                                                    -- fail
   END expDealer;

end PCK_PARTNER;
/
