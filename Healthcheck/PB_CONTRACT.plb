CREATE OR REPLACE PACKAGE BODY SNT.pb_contract
AS
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/09/25 13:22:25MESZ $
--
-- $Name: CBL_PreInt4  $
--
-- $Revision: 1.7 $
--
-- $Header: 5100_Code_Base/Healthcheck/PB_CONTRACT.plb 1.7 2014/09/25 13:22:25MESZ Kieninger, Tobias (tkienin) CI_Changed  $
--
-- $Source: 5100_Code_Base/Healthcheck/PB_CONTRACT.plb $
--
-- $Log: 5100_Code_Base/Healthcheck/PB_CONTRACT.plb  $
-- Revision 1.7 2014/09/25 13:22:25MESZ Kieninger, Tobias (tkienin) 
-- There is at least one invoice - Text shortened
-- Revision 1.5 2014/09/22 15:09:41MESZ Kieninger, Tobias (tkienin) 
-- last fixing in case of no end mileage available
-- Revision 1.3 2014/09/18 16:28:30MESZ Kieninger, Tobias (tkienin) 
-- Zwischen Checkin...   damit nix verlorengeht...
-- Validierung steht noch aus
-- Revision 1.2 2013/01/15 10:25:32MEZ Berger, Franz (fraberg)
-- within FUNCTION chk_paym_stepped_rates / check_price_calculation_comp / check_technical_tarif / check_mlp:
-- do i_V_TFZGPREIS_SSI check only if i_V_TFZGPREIS_SSI is not empty
-- Revision 1.1 2013/01/10 08:56:25MEZ Kieninger, Tobias (tkienin)
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.132 2012/03/01 10:52:16MEZ Berger, Franz (fraberg)
-- MKS-112190   / REQ603 / check_fzgv_kfzkennzeichen: der richtige wert von ssi.ssi_log.store_msg - i_column_name ist FZGV_KFZKENNZEICHEN
-- Revision 1.131 2012/02/20 10:00:54MEZ Berger, Franz (fraberg)
-- MKS-111534:3 / REQ603 / check_guidssim_exists: correct i_column_name von mandant in store_msg von ID_VERTRAG auf UNIQUE_SENDER_ID
-- Revision 1.130 2011/07/26 11:59:55MESZ Kieninger, Tobias (tkienin)
-- existing invoice Warning was not raised, if no invocie exists
-- Revision 1.129 2011/05/03 14:33:46CEST Kieninger, Tobias (tkienin)
-- Checks Contract begin vs real end oder prelim end versch?t.
-- Vertragsbeginn muss VOR! ende liegen. Gleichstand wird verboten
-- Revision 1.128 2010/06/25 10:02:57CEST Kieninger, Tobias (tkienin)
-- changed erroro messages price calculation parts
-- Revision 1.127 2010/06/23 14:25:57CEST Kieninger, Tobias (tkienin)
-- PricecalculationPart checks entsch?t
-- Revision 1.126 2010/06/22 11:18:29CEST Kieninger, Tobias (tkienin)
-- 2nd fix
-- Revision 1.125 2010/06/21 13:09:13CEST Kieninger, Tobias (tkienin)
-- Diff-Meldung l?st imemr aus
-- Revision 1.124 2010/06/15 13:45:48CEST Kieninger, Tobias (tkienin)
-- GS adapted
-- Revision 1.123 2010/06/10 13:43:00CEST Kieninger, Tobias (tkienin)
-- preiskalkulationsbestandteile d?rfen auch komplett NICHT geliefert werden.
-- Revision 1.122 2010/05/25 16:15:20CEST Kieninger, Tobias (tkienin)
-- .
-- Revision 1.120 2010/04/30 14:36:19CEST Musanovic, Adnana (amusano)
-- funktion check_end_mil_gt_inv_mil gefixt
-- Revision 1.119 2010/03/17 11:35:58CET Kieninger, Tobias (tkienin)
-- Text korrigiert
-- Revision 1.118 2010/03/10 12:44:57CET Kieninger, Tobias (tkienin)
-- Return without value behoben
-- Revision 1.117 2010/02/24 16:30:08CET Kieninger, Tobias (tkienin)
-- Req450
-- Revision 1.116 2010/01/18 14:34:42CET Kieninger, Tobias (tkienin)
-- fixed
-- Revision 1.115 2010/01/15 16:56:02CET Kieninger, Tobias (tkienin)
-- Einschr?ung auf Duration, nicht af Fahrzeugvertrag
-- Revision 1.113 2010/01/15 15:51:31CET Kieninger, Tobias (tkienin)
-- fixing stepped rates checks
-- - Check zu hart.. einschr?ung auf Fahrzeugvertrag, nicht nur Stammvertrag
-- Revision 1.112 2009/10/02 16:34:47CEST Kieninger, Tobias (tkienin)
-- exception when no_data_found in check_stepped_rates eingef?hrt
-- Revision 1.111 2009/06/24 16:09:24CEST Berger, Franz (fraberg)
-- MKS-74680:3 chk_paym_stepped_rates instead of chk_cov_stepped_rates: replace TDFCONTR_VARIANT.COV_STEPPED_RATES by TDFPAYMODE.PAYM_STEPPED_RATES
-- MKS-74769:1 do not check steppes rates flag = 0 anymore
-- Revision 1.110 2009/06/19 14:26:05CEST Kieninger, Tobias (tkienin)
-- Fehlermeldungen angepasst -
-- Revision 1.109 2009/06/18 15:53:39CEST Humer, Martin (mhumer8)
-- 74329
-- Revision 1.108 2009/05/15 12:52:45CEST Kieninger, Tobias (tkienin)
-- prozedur ck_insupdel_tic_co_pack_ass Ende korrekt benamst...
-- Revision 1.107 2009/05/15 12:42:57CEST Kieninger, Tobias (tkienin)
-- check_guid_ssim Fzgvertragsebene eingef?hrt
-- Revision 1.106 2009/05/15 09:45:20CEST Peters, Jan (petejan)
-- Fehlermeldung bei stepped rates pr?siert
-- Revision 1.105 2009/05/14 10:34:31CEST Peters, Jan (petejan)
-- es fehlten in allen Fehlerhandlings in chk_allPriceValues_tfzgpreis jeweils  ein l_ret := db_const.db_fail
-- Revision 1.104 2009/05/13 15:31:32CEST Humer, Martin (mhumer8)
-- delete tic_co_pack_ass before inserting ssi data
-- Revision 1.102 2009/04/07 13:44:43CEST Humer, Martin (mhumer8)
-- MKS 70154 7.April.2009
-- Revision 1.101 2009/03/12 11:33:07CET Kieninger, Tobias (tkienin)
-- branch
-- Revision 1.100.1.1 2009/03/05 15:52:13CET Peters, Jan (petejan)
-- Business Rule check_mileage_dates entsch?t
-- Revision 1.100 2009/03/02 13:50:44CET Humer, Martin (mhumer8)
-- function check_prevent_unvalid_prices: only check if price = 0
-- Revision 1.99 2009/02/25 13:49:36CET Humer, Martin (mhumer8)
-- REQ347: Coorporate Audit switchable check in zero prices -
-- Revision 1.98 2009/02/18 11:31:45CET Kieninger, Tobias (tkienin)
-- parameter im Get_global_setting spezifizerit
-- Revision 1.97 2009/01/16 15:41:36CET Peters, Jan (petejan)
-- Meldungen bei mult. chass. number found verbessert
-- Revision 1.96 2009/01/15 16:37:22CET Peters, Jan (petejan)
-- ContrState-Abgleich bei Pr?fung des Vorhandensein eines RealEndMileages korrigiert
-- Revision 1.1 2009/01/15 14:33:24CET Peters, Jan (petejan)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.94 2009/01/14 16:54:09CET Peters, Jan (petejan)
-- ^-Warnings sind jetzt wirklich Warnings
-- Revision 1.93 2009/01/14 15:55:18CET Drey, Franz (fdrey77)
-- ssi.ssi_log.store_msg korrigiertt in FUNCTION check_mileage_class_dat_in_dur
-- Revision 1.92 2009/01/13 13:22:44CET Peters, Jan (petejan)
-- Formulierung in Fehlermeldung korrigiert.
-- Revision 1.91 2008/12/18 14:34:58CET Peters, Jan (petejan)
-- Price-/MileageClassification-End-Date-Checks entsch?t (bei ?erschreitung des real end dates wird nicht mehr gemeckert)
-- Revision 1.90 2008/12/17 16:14:39CET Kieninger, Tobias (tkienin)
-- behoben
-- Revision 1.89 2008/12/17 14:18:24CET Peters, Jan (petejan)
-- pb_contract.check_end_mil_gt_inv_mil auf Warning umgestellt.
-- Revision 1.88 2008/12/16 15:54:38CET Peters, Jan (petejan)
-- Deklaration von l_char in pb_contract.ck_stati_real_end_milage auf
-- l_char            snt.TGLOBAL_SETTINGS.value%type;
-- ge?ert
-- Revision 1.87 2008/12/15 16:47:41CET Peters, Jan (petejan)
-- added: check_overlapping_contr_trans (und Aufruf in po_co)
-- Revision 1.86 2008/12/15 13:14:07CET Peters, Jan (petejan)
-- check_for_existing_fin: falls GS=2, erfolgt jetzt nur noch warning
-- Revision 1.84 2008/12/12 14:38:39CET Peters, Jan (petejan)
-- pb_contract.check_start_end_mil auf Pr?fung real_end_mileage erg?t und po_co entsprechend angepasst
-- Revision 1.83 2008/12/11 17:53:06CET Peters, Jan (petejan)
-- Implizites to_number wird jetzt verhindert
-- Revision 1.82 2008/12/11 17:34:17CET Peters, Jan (petejan)
-- pb_contract.check_mileage_with_scarf komplett ?berarbeitet (und Aufruf angepasst)
-- Revision 1.77 2008/12/11 14:11:38CET Kieninger, Tobias (tkienin)
-- check for unique mileagedates included
-- Revision 1.76 2008/12/10 17:07:45CET Peters, Jan (petejan)
-- added: PB_CONTRACT.check_kmstand_durations (und aufruf in po_co)
-- Revision 1.75 2008/12/10 15:43:44CET Peters, Jan (petejan)
-- in pb_contract.chk_price_range_gaps war Sortierung des Preisarrays falsch - und der Schleifenz?er wurde nicht hochgesetzt.
-- Revision 1.74 2008/12/10 14:36:26CET Peters, Jan (petejan)
-- Falls Scarf-Max-Mileage nicht gesetzt, wird 0 angenommen, zus?lich wird auch planned end mileage gepr?ft
-- Revision 1.73 2008/12/09 16:49:40CET Peters, Jan (petejan)
-- Priceranges au?rhalb Duration werden jetzt erkannt
-- Revision 1.72 2008/12/09 14:04:54CET Peters, Jan (petejan)
-- Korrekte Zuordnung von Duration/MileageClassification erfolgt jetzt
-- Revision 1.71 2008/12/09 00:23:10CET Kieninger, Tobias (tkienin)
-- .
-- Revision 1.70 2008/12/09 00:09:31CET Kieninger, Tobias (tkienin)
-- Fehlermeldungen
-- Revision 1.69 2008/12/05 15:54:15CET Peters, Jan (petejan)
-- Zus?liche Business Rule pb_contract.check_mileage_class_dat_in_dur implementiert
-- Revision 1.66 2008/12/04 17:21:25CET Kieninger, Tobias (tkienin)
-- check begin mileagevalue  = mileage report entry
-- Revision 1.65 2008/12/04 14:28:59CET Peters, Jan (petejan)
-- Fin-Pr?fung korrigiert. Globalsettings=
-- 0 -> warning bei existenz in aktiven vertr?n,
-- 1 -> fehler bei existenz in aktiven vertr?n,
-- 2 -> fehler bei existenz in allen vertr?n
-- Revision 1.64 2008/12/03 16:42:32CET Peters, Jan (petejan)
-- FIN-Pr?fung erweitert, noch ungetestet, noch kein patch ausgeliefert
-- Revision 1.63 2008/12/03 13:47:24CET Peters, Jan (petejan)
-- Fehlemeldung korrigiert
-- Revision 1.62 2008/12/03 13:31:11CET Peters, Jan (petejan)
-- Abfrage Beginn-KM-Stand = 0 entfernt
-- Revision 1.61 2008/12/02 16:04:09CET Peters, Jan (petejan)
-- If-Abfrage erneut korrigiert
-- Revision 1.60 2008/12/02 14:51:11CET Peters, Jan (petejan)
-- Real end mileage is before begin mileage!
-- Revision 1.58 2008/11/28 13:52:34CET Peters, Jan (petejan)
-- R?ckgabewert in chk_price_ranges korrigiert
-- Revision 1.57 2008/11/27 17:45:35CET Peters, Jan (petejan)
-- neue Funktion: pb_contract.check_price_dates samt Aufruf in po_co
-- Revision 1.1 2008/11/27 15:11:01CET Kieninger, Tobias (tkienin)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.53 2008/11/27 08:45:29CET Humer, Martin (mhumer8)
-- MKS 64736; 27.11.2008
-- Revision 1.52 2008/11/26 15:39:46CET Peters, Jan (petejan)
-- Warnings zu ung?ltigen Preisen erfolgen jetzt
-- Revision 1.1 2008/11/26 15:02:29CET Peters, Jan (petejan)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.50 2008/11/25 16:35:24CET Humer, Martin (mhumer8)
-- MKS 64601; 25.11.2008
-- Revision 1.49 2008/11/20 16:31:52CET Humer, Martin (mhumer8)
-- MKS 62653
-- Revision 1.1 2008/11/20 15:34:32CET Humer, Martin (mhumer8)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.48 2008/11/19 14:40:16CET Peters, Jan (petejan)
-- added: check_for_mileage_report, pr?ft, ob es f?r ein gegebenes REAL_END_DATE im XML auch einen Mileage-Report gibt
-- Revision 1.47 2008/11/18 19:58:51CET Drey, Franz (fdrey77)
-- Transfer Vegaattribute berichtigt
-- ExtRed  Endkilometer
-- Revision 1.46 2008/11/17 14:41:12CET Peters, Jan (petejan)
-- R?ckgabewert korrigiert
-- Revision 1.45 2008/11/14 14:29:37CET Peters, Jan (petejan)
-- - durch + ersetzt
-- Revision 1.44 2008/11/13 14:54:36CET Peters, Jan (petejan)
-- pb_contract.check_cntrendlaufgtcntrbeglau nach check_kmstand umbenannt und Aufruf in po_co angepasst
-- Revision 1.1 2008/11/12 17:41:16CET Peters, Jan (petejan)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.42 2008/11/12 15:25:26CET Peters, Jan (petejan)
-- GUID_SSIM wird nur noch in den Datens?en in TFZGVERTRAG auf mehrfaches auftrtene gepr?ft, in denen es ein GUID_SSIM gibt.
-- Revision 1.1 2008/11/11 17:22:08CET Peters, Jan (petejan)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.1 2008/11/10 17:00:14CET Peters, Jan (petejan)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.40 2008/11/10 16:03:08CET Peters, Jan (petejan)
-- added: check_overlappingprices
-- added: check_overlappinglaufleistung
-- Revision 1.39 2008/11/06 15:47:11CET Peters, Jan (petejan)
-- overlapping contracts werden jetzt erkannt
-- Revision 1.2 2008/11/05 16:50:40CET Humer, Martin (mhumer8)
-- Member renamed from 5100 Code Base/Database/_IntegrationPatches/2.5.0/26_Patch_250B01_62898_ssi.sql to 5100 Code Base/Database/_IntegrationPatches/2.5.0/26_PATCH_250B01_62898_snt.sql in project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj.
-- Revision 1.1 2008/11/05 16:50:40CET Humer, Martin (mhumer8)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.37 2008/11/05 11:55:58CET Drey, Franz (fdrey77)
-- function ck_stati_real_end_milage angepasst
--
-- MKSEND
--
-- FraBe 20.02.2012 MKS-111534:3 / REQ603 / check_guidssim_exists: correct i_column_name von mandant in store_msg von ID_VERTRAG auf UNIQUE_SENDER_ID
-- FraBe 29.02.2012 MKS-112190   / REQ603 / check_fzgv_kfzkennzeichen: der richtige wert von ssi.ssi_log.store_msg - i_column_name ist FZGV_KFZKENNZEICHEN
   lgc_modul   VARCHAR2 (100) DEFAULT 'PB_CONTRACT.';

   -- ermittle zur gegebenen id_seq_fzgkmstand das passende datum
   -- (Hilfsdfunktion f?r check_overlappingcontracts, check_mileage_class_dat_in_dur
   FUNCTION get_kmstand_date (
      i_id_seq_fzgkmstand   IN   ssi.tfzgkmstand.id_seq_fzgkmstand%TYPE
     ,i_v_tfzgkmstand       IN   ssi_datatype.typ_tfzgkmstand
   )
      RETURN ssi.tfzgkmstand.fzgkm_datum%TYPE
   IS
      l_ret           ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_tfzgkmstand   ssi.tfzgkmstand%ROWTYPE;
      l_row           NUMBER;
      lc_sub_modul    VARCHAR2 (100 CHAR)                DEFAULT 'get_kmstand_date';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of SubFunction *****');
      l_row := i_v_tfzgkmstand.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         l_tfzgkmstand := i_v_tfzgkmstand (l_row);

         IF i_v_tfzgkmstand (l_row).id_seq_fzgkmstand = i_id_seq_fzgkmstand
         THEN
            l_ret := i_v_tfzgkmstand (l_row).fzgkm_datum;
         END IF;

         IF l_ret IS NULL
         THEN
            l_row := i_v_tfzgkmstand.NEXT (l_row);
         ELSE
            -- wir haben den gesuchten Wert, Array muss nicht weiter durchsucht werden!
            l_row := NULL;                                                                  -- aus Schleife ausbrechen!
         END IF;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of SubFunction *****');
      RETURN l_ret;
   END get_kmstand_date;

   FUNCTION get_kmstand (
      i_id_seq_fzgkmstand   IN   ssi.tfzgkmstand.id_seq_fzgkmstand%TYPE
     ,i_v_tfzgkmstand       IN   ssi_datatype.typ_tfzgkmstand
   )
      RETURN ssi.tfzgkmstand.fzgkm_km%TYPE
   IS
      l_ret           ssi.tfzgkmstand.fzgkm_km%TYPE;
      l_tfzgkmstand   ssi.tfzgkmstand%ROWTYPE;
      l_row           NUMBER;
      lc_sub_modul    VARCHAR2 (100 CHAR)             DEFAULT 'get_kmstand';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of SubFunction *****');
      l_row := i_v_tfzgkmstand.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         l_tfzgkmstand := i_v_tfzgkmstand (l_row);

         IF i_v_tfzgkmstand (l_row).id_seq_fzgkmstand = i_id_seq_fzgkmstand
         THEN
            l_ret := i_v_tfzgkmstand (l_row).fzgkm_km;
         END IF;

         IF l_ret IS NULL
         THEN
            l_row := i_v_tfzgkmstand.NEXT (l_row);
         ELSE
            -- wir haben den gesuchten Wert, Array muss nicht weiter durchsucht werden!
            l_row := NULL;                                                                  -- aus Schleife ausbrechen!
         END IF;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of SubFunction *****');
      RETURN l_ret;
   END get_kmstand;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_fzgv_kfzkennzeichen (
      i_fzgv_kfzkennzeichen   IN   tfzgvertrag.fzgv_kfzkennzeichen%TYPE
     ,i_id_object             IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58644) Pr?fung auf Kennzeichen nicht erfasst
-- FraBe    29.02.2012 REQ603 / MKS-112190: der richtige wert von ssi.ssi_log.store_msg - i_column_name ist FZGV_KFZKENNZEICHEN
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'check_fzgv_kfzkennzeichen';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'Setting'
                                         ,'IsMandatory_LicensePlate'
                                         ,1
                                         );

      IF i_fzgv_kfzkennzeichen IS NULL AND l_char = 1
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'FZGV_KFZKENNZEICHEN'   -- MKS-112190 / REQ603: korrektur von FZGV_KENNZEICHEN
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgv_kfzkennzeichen
                                  ,i_msg_text           => 'License plate not set'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'FZGV_KENNZEICHEN'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgv_kfzkennzeichen || SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_FZGV_KFZKENNZEICHEN'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_fzgv_kfzkennzeichen;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_id_garage (
      i_id_garage   IN   tfzgvertrag.id_garage%TYPE
     ,i_id_object   IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2 (MKS58631) Pr?fung auf Werkstatt
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_id_garage';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_id_garage IS NULL
      THEN
         l_ret := db_const.db_fail;
      ELSIF i_id_garage = 0
      THEN
         l_char := snt.get_tglobal_settings ('Sirius'
                                            ,'Setting'
                                            ,'IsMandatory_Garage'
                                            ,1
                                            );

         IF l_char = 1
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGVERTRAG'
                                     ,i_column_name        => 'ID_GARAGE'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => i_id_garage
                                     ,i_msg_text           => 'Workshop number ist not set'
                                     -- workshop number
               ,                      i_msg_modul          => 'PB_CONTRACT.CHECK_ID_GARAGE'
                                     );
         END IF;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'ID_GARAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_id_garage || SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_ID_GARAGE'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_id_garage;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_for_existing_fin (
      i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_fzgv_fgstnr     IN   tfzgvertrag.fzgv_fgstnr%TYPE
     ,i_id_object       IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 03.09.2008, MKS58647 Pr?fung auf schon existierende FZGV_FGSTNR (FIN)
      -- PetersJ, 16.09.2008, MKS59536 Falls Update darf diese fin im upzudatenden Vertrag nat?rlich existieren
      l_char            VARCHAR2 (1);
      l_ret             db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret            db_datatype.db_returnstatus%TYPE;
      l_fzgv_fgstnr     tfzgvertrag.fzgv_fgstnr%TYPE;
      l_id_vertrag      tfzgvertrag.id_vertrag%TYPE;
      l_id_fzgvertrag   tfzgvertrag.id_fzgvertrag%TYPE;
      l_count           INTEGER;
      lc_sub_modul      VARCHAR2 (100 CHAR)                DEFAULT 'check_for_existing_fin';

      CURSOR l_cur_existing_act_contr (
         l_c_fzgv_fgstnr   IN   tfzgvertrag.fzgv_fgstnr%TYPE
      )
      IS
         SELECT id_vertrag
               ,id_fzgvertrag
               ,cos_caption
           FROM tfzgvertrag v
               ,tdfcontr_state s
          WHERE v.id_cos = s.id_cos AND s.cos_active = 1 AND v.fzgv_fgstnr = l_c_fzgv_fgstnr;

      CURSOR l_cur_existing_contr (
         l_c_fzgv_fgstnr   IN   tfzgvertrag.fzgv_fgstnr%TYPE
      )
      IS
         SELECT id_vertrag
               ,id_fzgvertrag
               ,cos_caption
           FROM tfzgvertrag v
               ,tdfcontr_state s
          WHERE v.id_cos = s.id_cos AND v.fzgv_fgstnr = l_c_fzgv_fgstnr;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      BEGIN
         -- pr?fe auf Update -- bei Update ist alles erlaubt!
         SELECT fzgv_fgstnr
           INTO l_fzgv_fgstnr
           FROM tfzgvertrag t
          WHERE t.id_vertrag = i_id_vertrag AND t.id_fzgvertrag = i_id_fzgvertrag;
      -- Data Found -> Import is an Update - no more checks
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_char := snt.get_tglobal_settings ('Sirius'
                                               ,'frmFZGVertrag'
                                               ,'AlertMethod_MultipleChassisNumber'
                                               ,0
                                               );

            IF l_char = '0'
            THEN                                                                                  -- active Contracts...
               FOR rec_exist_contracts IN l_cur_existing_act_contr (i_fzgv_fgstnr)
               LOOP
                  -- l_ret bleibt! Warning only!
                  l_jret :=
                     ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                           ,i_msg_code           => '20700'
                                           ,i_table_name         => 'TFZGVERTRAG'
                                           ,i_column_name        => 'FZGV_FGSTNR'
                                           ,i_message_class      => 'W'
                                           ,i_msg_value          => 'WARNING!'
                                           ,i_msg_text           =>    'Chassis number '
                                                                    || i_fzgv_fgstnr
                                                                    || ' of importet contract (ID_VERTRAG='
                                                                    || i_id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || i_id_fzgvertrag
                                                                    || ')'
                                                                    || ' already existing in existing contract (ID_VERTRAG='
                                                                    || rec_exist_contracts.id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || rec_exist_contracts.id_fzgvertrag
                                                                    || ' ('
                                                                    || rec_exist_contracts.cos_caption
                                                                    || ')'
                                                                    || ')'
                                           ,i_msg_modul          => 'PB_CONTRACT.CHECK_FOR_EXISTING_FIN'
                                           );
               END LOOP;
            ELSIF l_char = '1'
            THEN                                                                           -- nur aktive Vertr? pr?fen
               FOR rec_exist_contracts IN l_cur_existing_act_contr (i_fzgv_fgstnr)
               LOOP
                  -- fin gibt es schon in aktiven Vertr?n
                  l_ret := db_const.db_fail;
                  l_jret :=
                     ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                           ,i_msg_code           => '20700'
                                           ,i_table_name         => 'TFZGVERTRAG'
                                           ,i_column_name        => 'FZGV_FGSTNR'
                                           ,i_message_class      => 'N'
                                           ,i_msg_value          => i_fzgv_fgstnr
                                           ,i_msg_text           =>    'Chassis number '
                                                                    || i_fzgv_fgstnr
                                                                    || ' of importet contract (ID_VERTRAG='
                                                                    || i_id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || i_id_fzgvertrag
                                                                    || ')'
                                                                    || ' already existing in existing contract (ID_VERTRAG='
                                                                    || rec_exist_contracts.id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || rec_exist_contracts.id_fzgvertrag
                                                                    || ' ('
                                                                    || rec_exist_contracts.cos_caption
                                                                    || ')'
                                                                    || ')'
                                           ,i_msg_modul          => 'PB_CONTRACT.CHECK_FOR_EXISTING_FIN'
                                           );
               END LOOP;
            ELSIF l_char = '2'
            THEN
               -- alle Vertr? pr?fen
               FOR rec_exist_contracts IN l_cur_existing_contr (i_fzgv_fgstnr)
               LOOP
                  l_jret :=
                     ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                           ,i_msg_code           => '20700'
                                           ,i_table_name         => 'TFZGVERTRAG'
                                           ,i_column_name        => 'FZGV_FGSTNR'
                                           ,i_message_class      => 'W'
                                           ,i_msg_value          => 'WARNING!'
                                           ,i_msg_text           =>    'Chassis number '
                                                                    || i_fzgv_fgstnr
                                                                    || ' of importet contract (ID_VERTRAG='
                                                                    || i_id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || i_id_fzgvertrag
                                                                    || ')'
                                                                    || ' already existing in existing contract (ID_VERTRAG='
                                                                    || rec_exist_contracts.id_vertrag
                                                                    || ', ID_FZGVERTRAG='
                                                                    || rec_exist_contracts.id_fzgvertrag
                                                                    || ' ('
                                                                    || rec_exist_contracts.cos_caption
                                                                    || ')'
                                                                    || ')'
                                           ,i_msg_modul          => 'PB_CONTRACT.CHECK_FOR_EXISTING_FIN'
                                           );
               END LOOP;
            ELSE                                                                                               -- ??!??!
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                          (i_id_object          => i_id_object
                          ,i_msg_code           => '20700'
                          ,i_table_name         => 'TFZGVERTRAG'
                          ,i_column_name        => ''
                          ,i_message_class      => 'N'
                          ,i_msg_value          => NULL
                          ,i_msg_text           =>    'Setting '''
                                                   || l_char
                                                   || ''' for Global Setting ''AlertMethod_MultipleChassisNumber'' is not defined!'
                          ,i_msg_modul          => 'PB_CONTRACT.CHECK_FOR_EXISTING_FIN'
                          );
            END IF;
      END;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'FZGV_FGSTNR'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgv_fgstnr || SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_FOR_EXISTING_FIN'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_for_existing_fin;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_contbeginbeforeinregistr (
      i_fzgvc_beginn         IN   tfzgv_contracts.fzgvc_beginn%TYPE
     ,i_fzgv_erstzulassung   IN   tfzgvertrag.fzgv_erstzulassung%TYPE
     ,i_id_object            IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, REQREQ287.2.2, (MKS58632) Pr?fung auf Vertragsbeginn vor Datum Erstzulassung
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_contbeginbeforeinregistr';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_fzgvc_beginn < i_fzgv_erstzulassung
      THEN
         l_char :=
            snt.get_tglobal_settings (i_application_id      => 'Sirius'
                                     ,i_section             => 'Setting'
                                     ,i_entry               => 'ContractBeginBeforeInitialRegistration'
                                     ,i_default             => 0
                                     );

         IF l_char = '0'
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGVC_CONTRACTS'
                                     ,i_column_name        => 'FZGVC_VERTRAG'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => i_fzgvc_beginn
                                     ,i_msg_text           => 'Contract begin before initial registration date'
                                     ,i_msg_modul          => 'PB_CONTRACT.CHECK_ContBeginBeforeInRegistr'
                                     );
            l_ret := db_const.db_fail;
         END IF;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVC_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_VERTRAG'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgvc_beginn || SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_ContBeginBeforeInRegistr'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
         RETURN l_ret;
   END check_contbeginbeforeinregistr;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_admincharglpreismonat (
      i_fzgpr_admincharge    IN   tfzgpreis.fzgpr_admincharge%TYPE
     ,i_fzgpr_preis_monatp   IN   tfzgpreis.fzgpr_preis_monatp%TYPE
     ,i_id_object            IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58653) Pr?fung auf Verwaltungsgeb?hr > Monatspauschale
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_admincharglpreismonat';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_fzgpr_admincharge > i_fzgpr_preis_monatp
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_ADMINCHARGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgpr_admincharge
                                  ,i_msg_text           => 'Administration charge > monthly price'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_AdmincharglPreismonat'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_ADMINCHARGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgpr_admincharge || SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_AdmincharglPreismonat'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_admincharglpreismonat;

------------------------------------------------------------------------------------------------------------------------
--   FUNCTION check_mlpminprmplsubmindisc (
--      i_fzgpr_mlp            IN   tfzgpreis.fzgpr_mlp%TYPE
--     ,i_fzgpr_preis_monatp   IN   tfzgpreis.fzgpr_preis_monatp%TYPE
--     ,i_fzgpr_subbu          IN   tfzgpreis.fzgpr_subbu%TYPE
--     ,i_fzgpr_discas         IN   tfzgpreis.fzgpr_discas%TYPE
--     ,i_id_object            IN   tssi_journal.id_object%TYPE
--   )
--      RETURN db_datatype.db_returnstatus%TYPE
--   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58654) Pr?fung auf Verwaltungsgeb?hr > Monatspauschale
--      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
--      l_jret         db_datatype.db_returnstatus%TYPE;
--      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_mlpminprmplsubmindisc';
--   BEGIN
--      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

   --      IF i_fzgpr_mlp - i_fzgpr_preis_monatp <> i_fzgpr_subbu + i_fzgpr_discas
--      THEN
--         l_ret := db_const.db_success;                                                    Due no error. Only Warning.
--         l_jret :=
--            ssi.ssi_log.store_msg (i_id_object          => i_id_object
--                                  ,i_msg_code           => '20700'
--                                  ,i_table_name         => 'TFZGPREIS'
--                                  ,i_column_name        => ''
--                                  ,i_message_class      => 'W'
--                                  ,i_msg_value          => 'WARNING'
--                                  ,i_msg_text           => 'FZGPR_MLP - FZGPR_PREIS_MONATP <> FZGPR_SUBBU + FZGPR_DISCAS'
--                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_MlpMinPrMPlSUBminDisc'
--                                  );
--      END IF;

   --      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
--      RETURN l_ret;
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         l_ret := db_const.db_fail;
--         l_jret :=
--            ssi.ssi_log.store_msg (i_id_object          => i_id_object
--                                  ,i_msg_code           => '20900'
--                                  ,i_table_name         => 'TFZGPREIS'
--                                  ,i_column_name        => ''
--                                  ,i_message_class      => 'N'
--                                  ,i_msg_value          => SQLERRM
--                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
--                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_MlpMinPrMPlSUBminDisc'
--                                  );
--         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
--         RETURN l_ret;
--   END check_mlpminprmplsubmindisc;

   ------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_price_dates (
      i_fzgpr_von   IN   tfzgpreis.fzgpr_von%TYPE
     ,i_fzgpr_bis   IN   tfzgpreis.fzgpr_bis%TYPE
     ,i_id_object   IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 26.11.2008, REQ 287.3, Preisdatum_von muss vor preisdatum_bis liegen
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_price_dates';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_fzgpr_bis < i_fzgpr_von
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_VON'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => ''
                                  ,i_msg_text           => 'price range dates: from must be before to!'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_price_dates'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => 'PB_CONTRACT.check_price_dates'
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_price_dates;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_id_contr_garagenotzero (
      i_id_contr_garage   IN   tfzgvertrag.id_garage%TYPE
     ,i_id_object         IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--Sirius / Settings / IsMandatory_Garage = 1
      l_char         VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_id_contr_garagenotzero';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_CONTR_GARAGE_CHECK 1!');
      l_char :=
         snt.get_tglobal_settings (i_section             => 'Setting'
                                  ,i_application_id      => 'Sirius'
                                  ,i_entry               => 'IsMandatory_Garage'
                                  ,i_default             => 0
                                  );
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_CONTR_GARAGE_CHECK 2!');

      IF l_char = 1 AND i_id_contr_garage IS NULL
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => ''
                                  ,i_column_name        => 'ID_GARAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => NULL
                                  ,i_msg_text           => 'ID_GARAGE must not be 0'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_id_contr_garageNotZero'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_CONTR_GARAGE_CHECK 3!');
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => ''
                                  ,i_column_name        => 'ID_GARAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_id_contr_garagenotzero;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_for_mileage_report (
      i_v_tfzgv_contracts_ssi   IN   ssi_datatype.typ_tfzgv_contracts
     ,i_v_tfzgkmstand_ssi       IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object               IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 19.11.2008 REQREQ287.2, (MKS563471) Pr?fe auf Existenz MILEAGE_REPORT f?r REAL_END_DATE im XML
      l_ret               db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret              db_datatype.db_returnstatus%TYPE;
      lc_sub_modul        VARCHAR2 (100 CHAR)                DEFAULT 'check_for_real_end_date';
      l_tfzgv_contract    ssi.tfzgv_contracts%ROWTYPE;
      l_tfzgkmstand       ssi.tfzgkmstand%ROWTYPE;
      l_rownum_contract   NUMBER;
      l_rownum_kmstand    NUMBER;
      l_reportfound       BOOLEAN                            DEFAULT FALSE;
   BEGIN
      l_rownum_contract := i_v_tfzgv_contracts_ssi.FIRST;

      WHILE (l_rownum_contract IS NOT NULL)
      LOOP
         l_tfzgv_contract := i_v_tfzgv_contracts_ssi (l_rownum_contract);

         IF l_tfzgv_contract.real_end_date IS NOT NULL AND l_tfzgv_contract.real_end_mileage IS NULL
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGV_CONTRACTS'
                                     ,i_column_name        => 'REAL_END_MILEAGE'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => NULL
                                     ,i_msg_text           => 'REAL_END_MILEAGE is missing! (REAL_END_DATE is SET)'
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
         END IF;

         IF l_tfzgv_contract.real_end_date IS NULL AND l_tfzgv_contract.real_end_mileage IS NOT NULL
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGV_CONTRACTS'
                                     ,i_column_name        => 'REAL_END_MILEAGE'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => NULL
                                     ,i_msg_text           => 'REAL_END_DATE is missing! (REAL_END_MILEAGE is SET)'
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
         END IF;

         IF l_tfzgv_contract.real_end_date IS NOT NULL
         THEN
            l_rownum_kmstand := i_v_tfzgkmstand_ssi.FIRST;

            WHILE (l_rownum_kmstand IS NOT NULL)
            LOOP
               l_tfzgkmstand := i_v_tfzgkmstand_ssi (l_rownum_kmstand);

               -- Gibt einen Real-End-Date-KMStand-Record?
               IF l_tfzgkmstand.id_seq_fzgkmstand = l_tfzgv_contract.id_seq_fzgkmstand_end
               THEN
                  l_reportfound := TRUE;                                                         -- Datensatz gefunden!
               END IF;

               l_rownum_kmstand := i_v_tfzgkmstand_ssi.NEXT (l_rownum_kmstand);
            END LOOP;

            --jetzt muss ein real_end-Date-Datensatz in tfzgjmstand gefunden sein,
            -- sonst fehlt ein mileage-report im XML-File
            IF NOT l_reportfound
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                               (i_id_object          => i_id_object
                               ,i_msg_code           => '20700'
                               ,i_table_name         => 'TFZGV_CONTRACTS'
                               ,i_column_name        => 'REAL_END_MILEAGE'
                               ,i_message_class      => 'N'
                               ,i_msg_value          => NULL
                               ,i_msg_text           => 'REAL_END_DATE is set, but Mileage Report for REAL_END_DATE is missing!'
                               ,i_msg_modul          => lgc_modul || lc_sub_modul
                               );
            END IF;
         END IF;

         l_rownum_contract := i_v_tfzgv_contracts_ssi.NEXT (l_rownum_contract);
      END LOOP;

      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg
                               (i_id_object          => i_id_object
                               ,i_msg_code           => '20900'
                               ,i_table_name         => 'TFZGV_CONTRACTS'
                               ,i_column_name        => 'REAL_END_MILEAGE'
                               ,i_message_class      => 'N'
                               ,i_msg_value          => SQLERRM
                               ,i_msg_text           => 'REAL_END_DATE is set, but Mileage Report for REAL_END_DATE is missing!'
                               ,i_msg_modul          => lgc_modul || lc_sub_modul
                               );
         RETURN l_ret;
   END check_for_mileage_report;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_realenddateendmileage (
      i_real_end_date      IN   tfzgkmstand.fzgkm_datum%TYPE
     ,i_real_end_mileage   IN   tfzgkmstand.fzgkm_km%TYPE
     ,i_id_object          IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58814) wenn REAL_END_DATE geliefert wird muss REAL_END_MILEAGE auch geliefert werden
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_realenddateendmileage';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_real_end_date IS NOT NULL AND i_real_end_mileage IS NULL
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => ''
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => 'REAL_END_DATE is set, but REAL_END_MILEAGE is not set'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'REAL_END_DATE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_realenddateendmileage;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_kmstand_durations (
      i_v_tfzgv_contracts_ssi   IN   ssi_datatype.typ_tfzgv_contracts
     ,i_v_tfzgkmstand_ssi       IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object               IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 10.12.2008 REQREQ287.3.1, MKS65661 , begin_kmstand einer duration muss um 1 gr??r sein als real_end_kmstand der vorg?er-duration
      l_ret                  db_datatype.db_returnstatus%TYPE       DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE;
      lc_sub_modul           VARCHAR2 (100 CHAR)                    DEFAULT 'check_kmstand_durations';
      l_tfzgv_contract_ssi   ssi.tfzgv_contracts%ROWTYPE;
      l_kmstand_begin        tfzgv_contracts.fzgvc_beginn_km%TYPE;
      l_kmstand_end          tfzgkmstand.fzgkm_km%TYPE;
      l_row                  NUMBER;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_row := i_v_tfzgv_contracts_ssi.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         l_tfzgv_contract_ssi := i_v_tfzgv_contracts_ssi (l_row);

         IF l_kmstand_end IS NOT NULL
         THEN
            -- erst wenn wir den zweiten duration-record haben, haben wir auch ein ende des vorherigen und k?nnen pr?fen
            l_kmstand_begin := l_tfzgv_contract_ssi.fzgvc_beginn_km;

            IF l_kmstand_end > l_kmstand_begin                                                                    --+ 1
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                     (i_id_object          => i_id_object
                     ,i_msg_code           => '20700'
                     ,i_table_name         => 'TFZGV_CONTRACTS'
                     ,i_column_name        => ''
                     ,i_message_class      => 'N'
                     ,i_msg_value          => NULL
                     ,i_msg_text           => 'There is a gap between begin mileage of a duration and the real end mileage of its predecessor.'
                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                     );
            END IF;
         END IF;

         l_kmstand_end := get_kmstand (l_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand_ssi);
         l_row := i_v_tfzgv_contracts_ssi.NEXT (l_row);
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_kmstand_durations;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_kmstand (
      i_km_begin    IN   tfzgv_contracts.fzgvc_beginn_km%TYPE
     ,i_km_end      IN   tfzgkmstand.fzgkm_km%TYPE
     ,i_id_object   IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58640) Check tats?liche Vertragsende-KM-Stand liegt vor Vertragsbeginn-KM-Stand
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_kmstand';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_km_end < i_km_begin
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_km_end
                                  ,i_msg_text           => 'Real end mileage value is lower than begin mileage!'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_kmstand;

----------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_beginkmstand (
      i_km_begin_fzgvc   IN   tfzgv_contracts.fzgvc_beginn_km%TYPE
     ,i_km_begin_km      IN   tfzgkmstand.fzgkm_km%TYPE
     ,i_id_object        IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- TK, MKS 65484
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_BEGINkmstand';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                  , 'i_km_begin_fzgvc: ' || i_km_begin_fzgvc || ' -  i_km_begin_km: ' || i_km_begin_km);

      IF i_km_begin_fzgvc <> i_km_begin_km
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg
                  (i_id_object          => i_id_object
                  ,i_msg_code           => '20700'
                  ,i_table_name         => 'TFZGKMSTAND'
                  ,i_column_name        => 'FZGKM_KM'
                  ,i_message_class      => 'N'
                  ,i_msg_value          => i_km_begin_km || ' not equal to ' || i_km_begin_fzgvc
                  ,i_msg_text           => 'Difference between delivered mileage report and begin mileage in contract duration!'
                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_beginkmstand;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_forhighermileages_in_inv (
      i_tfzgv_contract_ssi   IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_v_tfzgkmstand_ssi    IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object            IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 11.12.2008 REQREQ287.3.1, MKS65925, es darf keine Werkstattrechnung mit einer h?heren Mileage geben, als real_end_mileage (Warning only)
      l_ret           db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret          db_datatype.db_returnstatus%TYPE;
      lc_sub_modul    VARCHAR2 (100 CHAR)                DEFAULT 'check_forhighermileages_in_inv';
      l_kmstand_end   tfzgkmstand.fzgkm_km%TYPE;
      l_dummy         Varchar2(1000 CHAR);
      l_select        Varchar2 (2000 CHAR);
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_kmstand_end := get_kmstand (i_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand_ssi);
      
      if l_kmstand_end is not null then
      BEGIN
         l_select := 'SELECT belart_caption||'' (''|| count(belart_caption)||'')''
                     FROM tfzgrechnung r, tbelegarten bel
                     WHERE r.id_belegart = bel.id_belegart
                     AND r.id_vertrag = '''||i_tfzgv_contract_ssi.id_vertrag||'''
                     AND r.id_fzgvertrag = '''||i_tfzgv_contract_ssi.id_fzgvertrag||'''
                     AND r.fzgre_laufstrecke > '||l_kmstand_end||'
                     GROUP BY belart_caption';
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', l_Select);                     
         l_dummy := concat_values(l_select,4000,'*');
         if length(l_dummy)>0 then
         l_jret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg
               (i_id_object          => i_id_object
               ,i_msg_code           => '20700'
               ,i_table_name         => 'TFZGKMSTAND'
               ,i_column_name        => 'FZGKM_KM'
               ,i_message_class      => 'W'
               ,i_msg_value          => 'WARNING: ' ||l_dummy
               ,i_msg_text           => 'There is at least one workshop invoice with a higher mileage'
               ,i_msg_modul          => lgc_modul || lc_sub_modul
               );
         else
            NULL;                                                              -- Yes! We DO NOT want to find anything!
         end if;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                              -- Yes! We DO NOT want to find anything!
      END ;
      end if;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_forhighermileages_in_inv;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_unique_mileage_dates (
      i_id_object   IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- TK 2008-12-11 unique check implementation for tfzgkmstand.fzgkm_datum
      l_ret           db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret          db_datatype.db_returnstatus%TYPE;
      lc_sub_modul    VARCHAR2 (100 CHAR)                DEFAULT 'check_unique_mileage_dates';
      l_fzgkm_datum   tfzgkmstand.fzgkm_datum%TYPE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      SELECT   fzgkm_datum
          INTO l_fzgkm_datum
          FROM ssi.tfzgkmstand
         WHERE id_object = i_id_object
      GROUP BY fzgkm_datum
        HAVING COUNT (fzgkm_datum) > 1;

      l_ret := db_const.db_fail;
      l_jret :=
         ssi.ssi_log.store_msg (i_id_object          => i_id_object
                               ,i_msg_code           => '20700'
                               ,i_table_name         => 'TFZGKMSTAND'
                               ,i_column_name        => 'FZGKM_DATUM'
                               ,i_message_class      => 'N'
                               ,i_msg_value          => l_fzgkm_datum
                               ,i_msg_text           =>    'Multiple Mileages for one single date found ('
                                                        || l_fzgkm_datum
                                                        || ')'
                               ,i_msg_modul          => lgc_modul || lc_sub_modul
                               );
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** ');
      RETURN l_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** NO DATA FOUND');
         RETURN l_ret;
      -- Alles gut.  keine Duplikate
      WHEN TOO_MANY_ROWS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_DATUM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => 'Unique Mileage error'
                                  ,i_msg_text           => 'Multiple Mileages for some dates found.'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** ');
         RETURN l_ret;
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_DATUM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End  of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_unique_mileage_dates;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_mileage_dates (
      i_v_tfzglaufleistung_ssi   IN   ssi_datatype.typ_tfzglaufleistung
     ,i_id_object                IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS62951) Check tats?liche Vertragsende-Laufleistung (Datum) liegt vor Vertragsbeginn-Laufleistung
      l_ret                db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret               db_datatype.db_returnstatus%TYPE;
      lc_sub_modul         VARCHAR2 (100 CHAR)                DEFAULT 'check_mileage_dates';
      l_tfzglaufleistung   ssi.tfzglaufleistung%ROWTYPE;
      l_row                NUMBER                             DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_row := i_v_tfzglaufleistung_ssi.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         BEGIN
            l_tfzglaufleistung := i_v_tfzglaufleistung_ssi (l_row);

            IF l_tfzglaufleistung.fzgll_von > l_tfzglaufleistung.fzgll_bis
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                        ,i_msg_code           => '20700'
                                        ,i_table_name         => 'TFZGLAUFLEISTUNG'
                                        ,i_column_name        => 'FZGLL_VON'
                                        ,i_message_class      => 'N'
                                        ,i_msg_value          =>    l_tfzglaufleistung.fzgll_von
                                                                 || ' > '
                                                                 || l_tfzglaufleistung.fzgll_bis
                                        ,i_msg_text           => 'Mileage Begin Date greater than Mileage End Date'
                                        ,i_msg_modul          => lgc_modul || lc_sub_modul
                                        );
            END IF;

            l_row := i_v_tfzglaufleistung_ssi.NEXT (l_row);
         END;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END check_mileage_dates;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_contrbeginltcontrend (
      i_fzgvc_beginn   IN   tfzgv_contracts.fzgvc_beginn%TYPE
     ,i_fzgvc_ende     IN   tfzgkmstand.fzgkm_datum%TYPE
     ,i_id_object      IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008,  REQREQ287.2.2 (MKS58637) Check tats?liches Vertragsende-Datum liegt vor Vertragsbeginn-Datum
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_contrbeginltcontrend';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_fzgvc_ende <= i_fzgvc_beginn
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgvc_ende || ' < ' || i_fzgvc_beginn
                                  ,i_msg_text           => 'Contract ends before contract begins'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_ContrBeginLtContrEnd'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '00700'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_contrbeginltcontrend;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_contrbeginltvorlend (
      i_fzgvc_beginn   IN   tfzgv_contracts.fzgvc_beginn%TYPE
     ,i_fzgvc_ende     IN   tfzgv_contracts.fzgvc_ende%TYPE
     ,i_id_object      IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MKS58636) Check Vertragsende-Datum liegt vor Vertragsbeginn-Datu
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_contrbeginltvorlend';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_fzgvc_ende <= i_fzgvc_beginn
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgvc_ende || ' < ' || i_fzgvc_beginn
                                  ,i_msg_text           => 'Contract planned end is before contract begin'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_ContrBeginLtVorlEnd'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '00700'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_contrbeginltvorlend;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_guidssim_exists (
      i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_guid_ssim       IN   tfzgvertrag.guid_ssim%TYPE
     ,i_id_object       IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 03.09.2008, REQREQ287.2.2, (MK58628) Checkt ob es die Vertragsnummer evtl. schon unter einem anderen Mandanten gibt
-- TK, 2008-12-17 MKS-66388
-- TK, 2009-05-15 MKS-73200
-- FraBe 2012-02-20 MKS-111534:3 / REQ603: correct i_column_name von mandant in store_msg von ID_VERTRAG auf UNIQUE_SENDER_ID
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE;
      l_guid_ssim    tfzgvertrag.guid_ssim%TYPE;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_guidssim_exists';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_guid_ssim IS NULL
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'UNIQUE_SENDER_ID'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_id_vertrag
                                  ,i_msg_text           => 'No Mandant delivered!'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_guidSSIM_exists'
                                  );
      END IF;

      BEGIN
         SELECT DISTINCT g.guid_ssim
                    INTO l_guid_ssim
                    FROM tfzgvertrag g
                   WHERE g.id_vertrag = i_id_vertrag AND g.id_fzgvertrag = i_id_fzgvertrag;

--      AND             g.guid_ssim IS NOT NULL;

         -- there is a contract with guid_ssim is NULL
         IF l_guid_ssim IS NULL
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg
                  (i_id_object          => i_id_object
                  ,i_msg_code           => '20700'
                  ,i_table_name         => 'TFZGVERTRAG'
                  ,i_column_name        => 'ID_VERTRAG'
                  ,i_message_class      => 'N'
                  ,i_msg_value          => i_id_vertrag
                  ,i_msg_text           => 'There is a existing contract created by Sirius Client. You may not alter this contract.'
                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_guidSSIM_exists'
                  );
         ELSIF l_guid_ssim <> i_guid_ssim
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg
                  (i_id_object          => i_id_object
                  ,i_msg_code           => '20700'
                  ,i_table_name         => 'TFZGVERTRAG'
                  ,i_column_name        => 'ID_VERTRAG'
                  ,i_message_class      => 'N'
                  ,i_msg_value          => i_id_vertrag
                  ,i_msg_text           => 'There is a existing contract created by another mandant. You may not alter this contract.'
                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_guidSSIM_exists'
                  );
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                                                         -- ALLES GUT;
         WHEN TOO_MANY_ROWS
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg
                  (i_id_object          => i_id_object
                  ,i_msg_code           => '20700'
                  ,i_table_name         => 'TFZGVERTRAG'
                  ,i_column_name        => 'ID_VERTRAG'
                  ,i_message_class      => 'N'
                  ,i_msg_value          => i_id_vertrag
                  ,i_msg_text           => 'There are several mandants for this contract. There must be a problem. Contact Sirius support.'
                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_guidSSIM_exists'
                  );
         WHEN OTHERS
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20900'
                                     ,i_table_name         => 'TFZGVERTRAG'
                                     ,i_column_name        => 'ID_VERTRAG'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
      END;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGVERTRAG'
                                  ,i_column_name        => 'ID_VERTRAG'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_guidssim_exists;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_gapsinprices (
      i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_tfzgv_contracts   IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_id_object         IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 03.09.2008, MKS58722, L?ckenlosigkeit des Preis pr?fen
      -- PetersJ, 09.09.2008, MKS59207, Business Rule wird (indirekt) auch vom Sirius-Client aufgerufen,
      --                                SSI-Logging darf dann nicht erfolgen (falls i_id_objeckt is NULL)
      l_ret                  db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE;
      lc_sub_modul           VARCHAR2 (100 CHAR)                DEFAULT 'check_gapsinprices';
      l_tfzgpreis_current    ssi.tfzgpreis%ROWTYPE;
      l_tfzgpreis_previous   ssi.tfzgpreis%ROWTYPE;
      l_row                  PLS_INTEGER;
      l_char                 VARCHAR (1);
      l_firstchecked         BOOLEAN                            := FALSE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'frmFZGVertrag'
                                         ,'PriceRangesWithoutGap'
                                         ,0
                                         );

      -- nur wenn L?ckenlosigkeit der Preislaufzeiten  innerhalb der Vertragslaufzeit als Pflicht gesetzt ist, m?ssen wir weiter pr?fen!
      -- L?ckenlosigkeit hei?: L?cken zwischen Preislaufzeiten
      --                        L?cke zwischen Vertragsbeginn und erster Preislaufzeit
      IF l_char = '1'
      THEN
         l_row := i_v_tfzgpreis_ssi.FIRST;

         WHILE (l_row IS NOT NULL)
         LOOP
            l_tfzgpreis_current := i_v_tfzgpreis_ssi (l_row);

            -- Das Preis-Array enth? die Preise aller Laufzeitvertr?
            -- die Vergleichsoperationen d?rfen nur f?r die Preise des aktuellen Laufzeitvertrags erfolgen
            IF l_tfzgpreis_current.id_seq_fzgvc = i_tfzgv_contracts.id_seq_fzgvc
            THEN
               IF NOT l_firstchecked
               THEN
-- Behandlung des ersten passenden Preises (Preis-Array ist nach Laufzeitvertrag+Preisbeginn aufsteigend sortiert)
              -- Erster Preis muss zeitgleich mit Beginn des Laufzeitvertrags starten
                  IF l_tfzgpreis_current.fzgpr_von <> i_tfzgv_contracts.fzgvc_beginn
                  THEN
                     l_ret := db_const.db_fail;

                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                 ,i_msg_code           => '20700'
                                                 ,i_table_name         => 'TFZGPREIS'
                                                 ,i_column_name        => 'FZGPR_VON'
                                                 ,i_message_class      => 'N'
                                                 ,i_msg_value          => l_tfzgpreis_current.fzgpr_von
                                                 ,i_msg_text           => 'First price begins different to contract begin date'
                                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_gapsInPrices'
                                                 );
                     END IF;
                  END IF;

                  l_firstchecked := TRUE;
               ELSE
                  -- Erster Preis ist bereits erledigt, nachfolgende Preise wird gepr?ft
                  IF l_tfzgpreis_current.fzgpr_von - l_tfzgpreis_previous.fzgpr_bis > 1
                  THEN
                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                 ,i_msg_code           => '20700'
                                                 ,i_table_name         => 'TFZGPREIS'
                                                 ,i_column_name        => 'FZGPR_VON'
                                                 ,i_message_class      => 'N'
                                                 ,i_msg_value          => l_tfzgpreis_current.fzgpr_von
                                                 ,i_msg_text           => 'There is a gap between prices'
                                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_gapsInPrices'
                                                 );
                     END IF;

                     l_ret := db_const.db_fail;
                  END IF;
               END IF;
            END IF;                                                                   -- Ende Behandlung aktueller Preis

            l_tfzgpreis_previous := l_tfzgpreis_current;
            -- schiebe aktuellen Preis in Vorg?erpreis
            l_row := i_v_tfzgpreis_ssi.NEXT (l_row);
         -- Hole Index n?ster Preis
         END LOOP;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;

         -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
         IF i_id_object IS NOT NULL
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20900'
                                     ,i_table_name         => 'TFZGPREIS'
                                     ,i_column_name        => ''
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                        ,'***** End of Function ***** - EXCEPTION OTHERS');
         END IF;

         RETURN l_ret;
   END check_gapsinprices;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_overlappingprices (
      i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_tfzgv_contracts   IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_id_object         IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 10.11.2008, ?erschneidungen der Preise pr?fen
      l_ret                  db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE;
      lc_sub_modul           VARCHAR2 (100 CHAR)                DEFAULT 'check_gapsinprices';
      l_tfzgpreis_current    ssi.tfzgpreis%ROWTYPE;
      l_tfzgpreis_previous   ssi.tfzgpreis%ROWTYPE;
      l_row                  PLS_INTEGER;
      l_char                 VARCHAR (1);
      l_firstchecked         BOOLEAN                            := FALSE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'Setting'
                                         ,'ENABLE TRIGGER FROM/TO CHECK TFZGPREIS'
                                         ,1
                                         );

      -- nur wenn L?ckenlosigkeit der Preislaufzeiten  innerhalb der Vertragslaufzeit als Pflicht gesetzt ist, m?ssen wir weiter pr?fen!
      -- L?ckenlosigkeit hei?: L?cken zwischen Preislaufzeiten
      --                        L?cke zwischen Vertragsbeginn und erster Preislaufzeit
      IF l_char = '1'
      THEN
         l_row := i_v_tfzgpreis_ssi.FIRST;

         WHILE (l_row IS NOT NULL)
         LOOP
            l_tfzgpreis_current := i_v_tfzgpreis_ssi (l_row);

            -- Das Preis-Array enth? die Preise aller Laufzeitvertr?
            -- die Vergleichsoperationen d?rfen nur f?r die Preise des aktuellen Laufzeitvertrags erfolgen
            IF l_tfzgpreis_current.id_seq_fzgvc = i_tfzgv_contracts.id_seq_fzgvc
            THEN
               IF NOT l_firstchecked
               THEN
-- Behandlung des ersten passenden Preises (Preis-Array ist nach Laufzeitvertrag+Preisbeginn aufsteigend sortiert)
              -- Erster Preis muss zeitgleich mit Beginn des Laufzeitvertrags starten
                  l_firstchecked := TRUE;
               ELSE
                  -- Erster Preis ist bereits erledigt, nachfolgende Preise wird gepr?ft
                  IF l_tfzgpreis_current.fzgpr_von <= l_tfzgpreis_previous.fzgpr_bis
                  THEN
                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                 ,i_msg_code           => '20700'
                                                 ,i_table_name         => 'TFZGPREIS'
                                                 ,i_column_name        => 'FZGPR_VON'
                                                 ,i_message_class      => 'N'
                                                 ,i_msg_value          =>    l_tfzgpreis_current.fzgpr_von
                                                                          || ' <= '
                                                                          || l_tfzgpreis_previous.fzgpr_bis
                                                 ,i_msg_text           => 'There are overlapping prices'
                                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_overlappingPrices'
                                                 );
                     END IF;

                     l_ret := db_const.db_fail;
                  END IF;
               END IF;
            END IF;                                                                   -- Ende Behandlung aktueller Preis

            l_tfzgpreis_previous := l_tfzgpreis_current;
            -- schiebe aktuellen Preis in Vorg?erpreis
            l_row := i_v_tfzgpreis_ssi.NEXT (l_row);
         -- Hole Index n?ster Preis
         END LOOP;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;

         -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
         IF i_id_object IS NOT NULL
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGPREIS'
                                     ,i_column_name        => ''
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                        ,'***** End of Function ***** - EXCEPTION OTHERS');
         END IF;

         RETURN l_ret;
   END check_overlappingprices;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION chk_price_range_gaps (
      i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
   )
      RETURN NUMBER
   IS
      -- PetersJ, 09.09.2008, MKS59207, Wrapper zum Aufruf von CHECK_gapsInPrice vom Sirus-Client aus
      l_tfzgv_contract    ssi.tfzgv_contracts%ROWTYPE;
      l_v_tfzgpreis_ssi   ssi_datatype.typ_tfzgpreis;
      l_i                 NUMBER                        DEFAULT 1;
      l_ret               NUMBER                        DEFAULT db_const.db_success;
      lc_sub_modul        VARCHAR2 (100)                DEFAULT 'chk_price_range_gaps';

      CURSOR cur_tfzgpreis
      IS
         SELECT   *
             FROM tfzgpreis p
            WHERE p.id_vertrag = i_id_vertrag AND p.id_fzgvertrag = i_id_fzgvertrag
         ORDER BY p.fzgpr_von
                 ,p.fzgpr_bis;

      CURSOR cur_tfzgv_contracts
      IS
         SELECT   *
             FROM tfzgv_contracts c
            WHERE c.id_vertrag = i_id_vertrag AND c.id_fzgvertrag = i_id_fzgvertrag
         ORDER BY c.id_seq_fzgvc;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      -- Preis-Array zusammensetzen
      FOR l_rec_preis IN cur_tfzgpreis
      LOOP
         l_v_tfzgpreis_ssi (l_i).fzgpr_von := l_rec_preis.fzgpr_von;
         l_v_tfzgpreis_ssi (l_i).fzgpr_bis := l_rec_preis.fzgpr_bis;
         l_v_tfzgpreis_ssi (l_i).id_seq_fzgvc := l_rec_preis.id_seq_fzgvc;
         l_v_tfzgpreis_ssi (l_i).id_seq_fzgpreis := l_rec_preis.id_seq_fzgpreis;
         l_i := l_i + 1;
      END LOOP;

      -- F?r jeden Laufzeitvertrag des aktuellen Fahrzeugvertrags m?ssen gepr?ft werden
      FOR l_rec_tfzgv_contract IN cur_tfzgv_contracts
      LOOP
         l_tfzgv_contract.id_seq_fzgvc := l_rec_tfzgv_contract.id_seq_fzgvc;
         l_tfzgv_contract.id_vertrag := l_rec_tfzgv_contract.id_vertrag;
         l_tfzgv_contract.id_fzgvertrag := l_rec_tfzgv_contract.id_fzgvertrag;
         l_tfzgv_contract.fzgvc_beginn := l_rec_tfzgv_contract.fzgvc_beginn;
         l_tfzgv_contract.fzgvc_ende := l_rec_tfzgv_contract.fzgvc_ende;

         IF check_gapsinprices (l_v_tfzgpreis_ssi, l_tfzgv_contract) = db_const.db_fail
         THEN
            l_ret := db_const.db_fail;
         END IF;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END chk_price_range_gaps;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_gapsinlaufleistung (
      i_v_tfzglaufleistung_ssi   IN   ssi_datatype.typ_tfzglaufleistung
     ,i_tfzgv_contracts          IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_id_object                IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 03.09.2008, L?ckenlosigkeit der Laufleistung pr?fen
      l_ret                         db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                        db_datatype.db_returnstatus%TYPE;
      l_tfzglaufleistung_current    ssi.tfzglaufleistung%ROWTYPE;
      l_tfzglaufleistung_previous   ssi.tfzglaufleistung%ROWTYPE;
      l_row                         PLS_INTEGER;
      l_char                        VARCHAR (1)                        DEFAULT 1;
      l_firstchecked                BOOLEAN                            := FALSE;
      lc_sub_modul                  VARCHAR2 (100 CHAR)                DEFAULT 'check_gapsinlaufleistung';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      -- l_char := SNT.GET_TGLOBAL_SETTINGS('Sirius','frmFZGVertrag','PriceRangesWithoutGap',0);
      -- nur wenn L?ckenlosigkeit der Laufleistungen innerhalb der Vertragslaufzeit als Pflicht gesetzt ist, m?ssen wir weiter pr?fen!
      -- L?ckenlosigkeit hei?: L?cken zwischen Laufleistungen
      --                        L?cke zwischen Vertragsbeginn und erster Laufleistungslaufzeit
      IF l_char = '1'
      THEN
         l_row := i_v_tfzglaufleistung_ssi.FIRST;

         WHILE (l_row IS NOT NULL)
         LOOP
            l_tfzglaufleistung_current := i_v_tfzglaufleistung_ssi (l_row);

            -- Das Laufleistungs-Array enth? die Laufleistungen aller Laufzeitvertr?
            -- die Vergleichsoperationen d?rfen nur f?r die Laufleistungen des aktuellen Laufzeitvertrags erfolgen
            IF l_tfzglaufleistung_current.id_seq_fzgvc = i_tfzgv_contracts.id_seq_fzgvc
            THEN
               IF NOT l_firstchecked
               THEN
-- Behandlung der ersten passenden Laufleistung (Laufleistungs-Array ist nach Laufzeitvertrag+Laufleistungsbeginn aufsteigend sortiert)
              -- Erste Laufleistung muss zeitgleich mit Beginn des Laufzeitvertrags starten
                  IF l_tfzglaufleistung_current.fzgll_von <> i_tfzgv_contracts.fzgvc_beginn
                  THEN
                     l_ret := db_const.db_fail;

                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg
                                 (i_id_object          => i_id_object
                                 ,i_msg_code           => '20700'
                                 ,i_table_name         => 'tfzglaufleistung'
                                 ,i_column_name        => 'FZGPR_VON'
                                 ,i_message_class      => 'N'
                                 ,i_msg_value          =>    l_tfzglaufleistung_current.fzgll_von
                                                          || ' <> '
                                                          || i_tfzgv_contracts.fzgvc_beginn
                                 ,i_msg_text           => 'First mileage classification begins different to contract begin date'
                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_gapsInLaufleistung'
                                 );
                     END IF;
                  END IF;

                  l_firstchecked := TRUE;
               ELSE
-- Erste Laufleistung ist bereits erledigt, nachfolgende Laufleistungen werden gepr?ft
                  IF l_tfzglaufleistung_current.fzgll_von <> l_tfzglaufleistung_previous.fzgll_bis + 1
                  THEN
                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                 ,i_msg_code           => '20700'
                                                 ,i_table_name         => 'tfzglaufleistung'
                                                 ,i_column_name        => 'FZGPR_VON'
                                                 ,i_message_class      => 'N'
                                                 ,i_msg_value          =>    l_tfzglaufleistung_current.fzgll_von
                                                                          || ' <> '
                                                                          || l_tfzglaufleistung_previous.fzgll_bis
                                                                          +  1
                                                 ,i_msg_text           => 'There is a gap between mileage classifications'
                                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_gapsInLaufleistung'
                                                 );
                     END IF;

                     l_ret := db_const.db_fail;
                  END IF;
               END IF;
            END IF;                                                             -- Ende Behandlung aktuelle Laufleistung

            l_tfzglaufleistung_previous := l_tfzglaufleistung_current;
            -- schiebe aktuelle Laufleistung in Vorg?erlaufleistung
            l_row := i_v_tfzglaufleistung_ssi.NEXT (l_row);
         -- Hole Index n?ste Laufleistung
         END LOOP;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;

         -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
         IF i_id_object IS NOT NULL
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20900'
                                     ,i_table_name         => 'tfzglaufleistung'
                                     ,i_column_name        => ''
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
         END IF;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_gapsinlaufleistung;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_overlappinglaufleistung (
      i_v_tfzglaufleistung_ssi   IN   ssi_datatype.typ_tfzglaufleistung
     ,i_tfzgv_contracts          IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_id_object                IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 10.11.2008, ?erschneidungen der Laufleistung pr?fen
      l_ret                         db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                        db_datatype.db_returnstatus%TYPE;
      l_tfzglaufleistung_current    ssi.tfzglaufleistung%ROWTYPE;
      l_tfzglaufleistung_previous   ssi.tfzglaufleistung%ROWTYPE;
      l_row                         PLS_INTEGER;
      l_char                        VARCHAR (1)                        DEFAULT 1;
      l_firstchecked                BOOLEAN                            := FALSE;
      lc_sub_modul                  VARCHAR2 (100 CHAR)                DEFAULT 'check_gapsinlaufleistung';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'Setting'
                                         ,'ENABLE TRIGGER FROM/TO CHECK TFZGLAUFLEISTUNG'
                                         ,1
                                         );

      -- nur wenn L?ckenlosigkeit der Laufleistungen innerhalb der Vertragslaufzeit als Pflicht gesetzt ist, m?ssen wir weiter pr?fen!
      -- L?ckenlosigkeit hei?: L?cken zwischen Laufleistungen
      --                        L?cke zwischen Vertragsbeginn und erster Laufleistungslaufzeit
      IF l_char = '1'
      THEN
         l_row := i_v_tfzglaufleistung_ssi.FIRST;

         WHILE (l_row IS NOT NULL)
         LOOP
            l_tfzglaufleistung_current := i_v_tfzglaufleistung_ssi (l_row);

            -- Das Laufleistungs-Array enth? die Laufleistungen aller Laufzeitvertr?
            -- die Vergleichsoperationen d?rfen nur f?r die Laufleistungen des aktuellen Laufzeitvertrags erfolgen
            IF l_tfzglaufleistung_current.id_seq_fzgvc = i_tfzgv_contracts.id_seq_fzgvc
            THEN
               IF NOT l_firstchecked
               THEN
-- Behandlung der ersten passenden Laufleistung (Laufleistungs-Array ist nach Laufzeitvertrag+Laufleistungsbeginn aufsteigend sortiert)
                  l_firstchecked := TRUE;
               ELSE
-- Erste Laufleistung ist bereits erledigt, nachfolgende Laufleistungen werden gepr?ft
                  IF l_tfzglaufleistung_current.fzgll_von < l_tfzglaufleistung_previous.fzgll_bis + 1
                  THEN
                     -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
                     IF i_id_object IS NOT NULL
                     THEN
                        l_jret :=
                           ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                 ,i_msg_code           => '20700'
                                                 ,i_table_name         => 'tfzglaufleistung'
                                                 ,i_column_name        => 'FZGPR_VON'
                                                 ,i_message_class      => 'N'
                                                 ,i_msg_value          =>    l_tfzglaufleistung_current.fzgll_von
                                                                          || ' < '
                                                                          || (l_tfzglaufleistung_previous.fzgll_bis + 1
                                                                             )
                                                 ,i_msg_text           => 'There are overlapping mileage classifications'
                                                 ,i_msg_modul          => 'PB_CONTRACT.CHECK_overlappingLaufleistung'
                                                 );
                     END IF;

                     l_ret := db_const.db_fail;
                  END IF;
               END IF;
            END IF;                                                             -- Ende Behandlung aktuelle Laufleistung

            l_tfzglaufleistung_previous := l_tfzglaufleistung_current;
            -- schiebe aktuelle Laufleistung in Vorg?erlaufleistung
            l_row := i_v_tfzglaufleistung_ssi.NEXT (l_row);
         -- Hole Index n?ste Laufleistung
         END LOOP;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;

         -- falls Funktion vom Client aufgerufen wird, darf kein Loggin erfolgen!
         IF i_id_object IS NOT NULL
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20900'
                                     ,i_table_name         => 'tfzglaufleistung'
                                     ,i_column_name        => ''
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
         END IF;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_overlappinglaufleistung;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_overlappingcontracts (
      i_v_tfzgv_contracts   IN   ssi_datatype.typ_tfzgv_contracts
     ,i_v_tfzgkmstand       IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object           IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PTR_AVOID_MUTATING_TABLE.MT_TFZGV_CONTRACTS_FROM_TO_AFT
      l_ret                       db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                      db_datatype.db_returnstatus%TYPE;
      lc_sub_modul                VARCHAR2 (100 CHAR)                DEFAULT 'check_overlappingcontracts';
      l_tfzgv_contract_current    ssi.tfzgv_contracts%ROWTYPE;
      l_tfzgv_contract_previous   ssi.tfzgv_contracts%ROWTYPE;
      l_begin_date_current        ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_begin_date_previous       ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_end_date_current          ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_end_date_previous         ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_row                       PLS_INTEGER;
      l_char                      VARCHAR (1);
      l_firstchecked              BOOLEAN                            := FALSE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'Setting'
                                         ,'ENABLE TRIGGER FROM/TO CHECK TFZGV_CONTRACTS'
                                         ,1
                                         );

      IF l_char = 1
      THEN
         l_row := i_v_tfzgv_contracts.FIRST;

         WHILE (l_row IS NOT NULL)
         LOOP
            l_tfzgv_contract_current := i_v_tfzgv_contracts (l_row);

            IF NOT l_firstchecked
            THEN
               l_firstchecked := TRUE;
               l_end_date_current :=
                  NVL (get_kmstand_date (l_tfzgv_contract_current.id_seq_fzgkmstand_end, i_v_tfzgkmstand)
                      ,l_tfzgv_contract_current.fzgvc_ende);
            ELSE
               l_end_date_current :=
                  NVL (get_kmstand_date (l_tfzgv_contract_current.id_seq_fzgkmstand_end, i_v_tfzgkmstand)
                      ,l_tfzgv_contract_current.fzgvc_ende);

               -- wenn tats?liches enddatum noch nicht existiert, muss das tats?liche genommen werden
               IF l_end_date_current IS NULL
               THEN
                  l_end_date_current := l_tfzgv_contract_current.fzgvc_ende;
               END IF;

               -- jetzt k?nnen wir auf ?berlappung pr?fen
               IF l_end_date_previous > l_tfzgv_contract_current.fzgvc_beginn
               THEN
                  l_ret := db_const.db_fail;
                  l_jret :=
                     ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                           ,i_msg_code           => '20700'
                                           ,i_table_name         => 'TFZGV_CONTRACTS'
                                           ,i_column_name        => ''
                                           ,i_message_class      => 'N'
                                           ,i_msg_value          =>    l_end_date_previous
                                                                    || ' > '
                                                                    || l_tfzgv_contract_current.fzgvc_beginn
                                           ,i_msg_text           => 'There are overlapping contracts: '
                                           ,i_msg_modul          => 'PB_CONTRACT.CHECK_OverlappingContracts'
                                           );
               END IF;
            END IF;

            l_tfzgv_contract_previous := l_tfzgv_contract_current;
            l_end_date_previous := l_end_date_current;
            l_row := i_v_tfzgv_contracts.NEXT (l_row);
         END LOOP;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZCONTRACT'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_overlappingcontracts;

   FUNCTION check_overlapping_contr_trans (
      i_id_object   IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 15.12.2008, MKS65057, Overlapping-Pr?fung im Transfer-Fall, Transferierte erste Duration darf nicht vor Ende des Originals enden
      l_ret               db_datatype.db_returnstatus%TYPE        DEFAULT db_const.db_success;
      l_jret              db_datatype.db_returnstatus%TYPE;
      l_fzgkm_datum_old   ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_fzgkm_datum_new   ssi.tfzgv_contracts.fzgvc_beginn%TYPE;
      lc_sub_modul        VARCHAR2 (100 CHAR)                     DEFAULT 'check_overlapping_contr_trans';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      BEGIN
         SELECT MAX (k.fzgkm_datum)
           INTO l_fzgkm_datum_old
           FROM ssi.tfzgv_contracts c
               ,ssi.tfzgkmstand k
          WHERE 1 = 1
            AND c.id_seq_fzgkmstand_end = k.id_seq_fzgkmstand
            AND c.time_status_ssi = ssi_const.flag_trans_new_old.transold
            AND c.id_object = i_id_object;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg
                             (i_id_object          => i_id_object
                             ,i_msg_code           => '20700'
                             ,i_table_name         => 'TFZGV_CONTRACTS'
                             ,i_column_name        => ''
                             ,i_message_class      => 'N'
                             ,i_msg_value          => ''
                             ,i_msg_text           => 'Latest duration of original contract in a transfer has no real end date.'
                             ,i_msg_modul          => 'PB_CONTRACT.check_overlapping_contracts_trans'
                             );
      END;

      SELECT MIN (c.fzgvc_beginn)
        INTO l_fzgkm_datum_new
        FROM ssi.tfzgv_contracts c
       WHERE 1 = 1 AND c.time_status_ssi = ssi_const.flag_trans_new_old.transnew AND c.id_object = i_id_object;

      IF l_fzgkm_datum_new <= l_fzgkm_datum_old
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          =>    'Real End Date old contract: '
                                                           || l_fzgkm_datum_old
                                                           || ', Begin date new contract: '
                                                           || l_fzgkm_datum_new
                                  ,i_msg_text           => 'The transfered contract overlaps with the original one.'
                                  ,i_msg_modul          => 'PB_CONTRACT.check_overlapping_contracts_trans'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZCONTRACT'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_overlapping_contr_trans;

   -- check Mileage Cassification date ovelappping with duration
   FUNCTION check_mileage_class_dat_in_dur (
      i_v_tfzglaufleistung_ssi   IN   ssi_datatype.typ_tfzglaufleistung
     ,i_v_tfzgv_contracts_ssi    IN   ssi_datatype.typ_tfzgv_contracts
     ,i_v_tfzgkmstand_ssi        IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object                IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 05.12.2008, MKS65554, REQ287.2.1, Zeitraum der Laufleistung darf nicht aus Duration des Vertrags "herausragen"
      -- PetersJ, 18.12.2008, MKS66395, Preise d?rfen nach einem gesetzten Real-Ende-Date enden
      l_ret                    db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                   db_datatype.db_returnstatus%TYPE;
      l_tfzgv_contract_ssi     ssi.tfzgv_contracts%ROWTYPE;
      l_tfzglaufleistung_ssi   ssi.tfzglaufleistung%ROWTYPE;
      l_contr_von              ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_contr_bis              ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_real_end_date_set      BOOLEAN                            DEFAULT FALSE;
      l_row_contr              NUMBER;
      l_row_ll                 NUMBER;
      lc_sub_modul             VARCHAR2 (100 CHAR)                DEFAULT 'check_mileage_class_dat_in_dur';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_row_contr := i_v_tfzgv_contracts_ssi.FIRST;

      WHILE (l_row_contr IS NOT NULL)
      LOOP
         l_tfzgv_contract_ssi := i_v_tfzgv_contracts_ssi (l_row_contr);
         l_contr_von := get_kmstand_date (l_tfzgv_contract_ssi.id_seq_fzgkmstand_begin, i_v_tfzgkmstand_ssi);
         l_contr_bis := get_kmstand_date (l_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand_ssi);

         IF l_contr_bis IS NOT NULL
         THEN
            l_real_end_date_set := TRUE;
         ELSE
            l_contr_bis := l_tfzgv_contract_ssi.fzgvc_ende;
         END IF;

         l_row_ll := i_v_tfzglaufleistung_ssi.FIRST;

         WHILE (l_row_ll IS NOT NULL)
         LOOP
            l_tfzglaufleistung_ssi := i_v_tfzglaufleistung_ssi (l_row_ll);

            IF     l_tfzglaufleistung_ssi.id_seq_fzgvc = l_tfzgv_contract_ssi.id_seq_fzgvc
               AND l_tfzglaufleistung_ssi.fzgll_von < l_contr_von
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                     (i_id_object          => i_id_object
                     ,i_msg_code           => '20700'
                     ,i_table_name         => 'TFZGLAUFLEISTUNG'
                     ,i_column_name        => 'FZGLL_VON'
                     ,i_message_class      => 'N'
                     ,i_msg_value          => l_tfzglaufleistung_ssi.fzgll_von || ' < ' || l_contr_von
                     ,i_msg_text           => 'Mileage classification begin date must not be before begin date of contract duration! The xml-file was probably built by humanoid beings!'
                     ,i_msg_modul          => 'PB_CONTRACT.CHECK_OverlappingContracts'
                     );
            END IF;

            IF     l_tfzglaufleistung_ssi.id_seq_fzgvc = l_tfzgv_contract_ssi.id_seq_fzgvc
               AND l_tfzglaufleistung_ssi.fzgll_bis > l_contr_bis
               AND NOT l_real_end_date_set
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                     (i_id_object          => i_id_object
                     ,i_msg_code           => '20700'
                     ,i_table_name         => 'TFZGLAUFLEISTUNG'
                     ,i_column_name        => 'FZGLL_BIS'
                     ,i_message_class      => 'N'
                     ,i_msg_value          => l_tfzglaufleistung_ssi.fzgll_bis || ' > ' || l_contr_bis
                     ,i_msg_text           => 'Mileage classification end date must not be after end date of contract duration! XML files should never be built by humanoid beings!'
                     ,i_msg_modul          => 'PB_CONTRACT.CHECK_OverlappingContracts'
                     );
            END IF;

            l_row_ll := i_v_tfzglaufleistung_ssi.NEXT (l_row_ll);
         END LOOP;

         l_row_contr := i_v_tfzgv_contracts_ssi.NEXT (l_row_contr);
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGLAUFLEISTUNG'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_mileage_class_dat_in_dur;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_price_dates_in_dur (
      i_v_tfzgpreis_ssi         IN   ssi_datatype.typ_tfzgpreis
     ,i_v_tfzgv_contracts_ssi   IN   ssi_datatype.typ_tfzgv_contracts
     ,i_v_tfzgkmstand_ssi       IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object               IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 09.12.2008, MKS65573, REQ287.2.1, Zeitraum der Price Range darf nicht aus Duration des Vertrags "herausragen"
      l_ret                  db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE;
      l_tfzgv_contract_ssi   ssi.tfzgv_contracts%ROWTYPE;
      l_tfzgpreis_ssi        ssi.tfzgpreis%ROWTYPE;
      l_contr_von            ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_contr_bis            ssi.tfzgkmstand.fzgkm_datum%TYPE;
      l_real_end_date_set    BOOLEAN                            DEFAULT FALSE;
      l_row_contr            NUMBER;
      l_row_price            NUMBER;
      lc_sub_modul           VARCHAR2 (100 CHAR)                DEFAULT 'check_price_dates_in_dur';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_row_contr := i_v_tfzgv_contracts_ssi.FIRST;

      WHILE (l_row_contr IS NOT NULL)
      LOOP
         l_tfzgv_contract_ssi := i_v_tfzgv_contracts_ssi (l_row_contr);
         l_contr_von := get_kmstand_date (l_tfzgv_contract_ssi.id_seq_fzgkmstand_begin, i_v_tfzgkmstand_ssi);
         l_contr_bis :=
            NVL (get_kmstand_date (l_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand_ssi)
                ,l_tfzgv_contract_ssi.fzgvc_ende);

         IF l_contr_bis IS NOT NULL
         THEN
            l_real_end_date_set := TRUE;
         ELSE
            l_contr_bis := l_tfzgv_contract_ssi.fzgvc_ende;
         END IF;

         l_row_price := i_v_tfzgpreis_ssi.FIRST;

         WHILE (l_row_price IS NOT NULL)
         LOOP
            l_tfzgpreis_ssi := i_v_tfzgpreis_ssi (l_row_price);

            IF     l_tfzgpreis_ssi.id_seq_fzgvc = l_tfzgv_contract_ssi.id_seq_fzgvc
               AND l_tfzgpreis_ssi.fzgpr_von < l_contr_von
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                     (i_id_object          => i_id_object
                     ,i_msg_code           => '20700'
                     ,i_table_name         => 'TFZGPREIS'
                     ,i_column_name        => 'FZGR_VON'
                     ,i_message_class      => 'N'
                     ,i_msg_value          => l_tfzgpreis_ssi.fzgpr_von || ' < ' || l_contr_von
                     ,i_msg_text           => 'Price range begin date must not be before begin date of contract duration! This xml-file was probably not built by a computer!'
                     ,i_msg_modul          => 'PB_CONTRACT.check_price_dates_in_dur'
                     );
            END IF;

            IF     l_tfzgpreis_ssi.id_seq_fzgvc = l_tfzgv_contract_ssi.id_seq_fzgvc
               AND l_tfzgpreis_ssi.fzgpr_bis > l_contr_bis
               AND NOT l_real_end_date_set
            THEN
               l_ret := db_const.db_fail;
               l_jret :=
                  ssi.ssi_log.store_msg
                                (i_id_object          => i_id_object
                                ,i_msg_code           => '20700'
                                ,i_table_name         => 'TFZGPREIS'
                                ,i_column_name        => 'FZGPR_BIS'
                                ,i_message_class      => 'N'
                                ,i_msg_value          => l_tfzgpreis_ssi.fzgpr_bis || ' > ' || l_contr_bis
                                ,i_msg_text           => 'Price range end date must not be after end date of contract duration!'
                                ,i_msg_modul          => 'PB_CONTRACT.CHECK_price_date_in_dur'
                                );
            END IF;

            l_row_price := i_v_tfzgpreis_ssi.NEXT (l_row_price);
         END LOOP;

         l_row_contr := i_v_tfzgv_contracts_ssi.NEXT (l_row_contr);
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN l_ret;
   END check_price_dates_in_dur;

------------------------------------------------------------------------------------------------------------------------
  -- Warning checks (MKS 58753)
   FUNCTION check_prevent_unvalid_prices (
      i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_id_object         IN   tssi_journal.id_object%TYPE DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 14.10.2008, MKS 58753, REQ261.2,
      --     Prevention (Warning only!!!) of input of a negative value or zero value or greater than max for field 'price'
      l_ret                      db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                     db_datatype.db_returnstatus%TYPE;
      l_row                      NUMBER;
      lc_sub_modul               VARCHAR2 (100 CHAR)                DEFAULT 'check_prevent_unvalid_prices';
      l_tfzgpreis                ssi.tfzgpreis%ROWTYPE;
      l_fzgpr_preis_grkm_max     NUMBER;
      l_fzgpr_preis_monatp_max   NUMBER;
      l_fzgpr_zero_price         NUMBER;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_fzgpr_preis_grkm_max := snt.get_tglobal_settings ('Sirius'
                                                         ,'CORPORATE_AUDIT'
                                                         ,'UPPER_LIMIT_FZGPR_GRKM'
                                                         ,1
                                                         );
      l_fzgpr_preis_monatp_max := snt.get_tglobal_settings ('Sirius'
                                                           ,'CORPORATE_AUDIT'
                                                           ,'UPPER_LIMIT_FZGPR_PREIS'
                                                           ,1
                                                           );
      l_fzgpr_zero_price := snt.get_tglobal_settings ('Sirius'
                                                     ,'CORPORATE_AUDIT'
                                                     ,'CHECK_ZERO_PRICE'
                                                     ,1
                                                     );
      l_row := i_v_tfzgpreis_ssi.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         --
         -- negative prices
         --
          /*
         HuMa 24.02.2009
         MKS 68888:
         REQ347: Coorporate Audit switchable check in zero prices -
         Der CAC check der schreit wenn ein Preis mit 0 hinterlegt ist,
         soll ?ber ein GS schaltbar sein (aktiv, nicht aktiv). Das gilt f?r Client und SSI
         */
         IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_grkm < 0
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGPREIS'
                                     ,i_column_name        => 'FZGPR_PREIS_GRKM'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => ''
                                     ,i_msg_text           => 'FZGPR_PREIS_GRKM must not be below zero!'
                                     ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                     );
         END IF;

         IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_monatp < 0
         THEN
            l_ret := db_const.db_fail;
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGPREIS'
                                     ,i_column_name        => 'FZGPR_PREIS_MONATP'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => ''
                                     ,i_msg_text           => 'FZGPR_PREIS_MONATP must not be below zero!'
                                     ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                     );
         END IF;

         --
         -- prices = 0
         --

         --l_fzgpr_zero_price = 1: loaded with warning
         --l_fzgpr_zero_price = 1: loaded without warning
         IF l_fzgpr_zero_price = 1
         THEN
            IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_grkm = 0
            THEN
               l_jret :=
                  ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                        ,i_msg_code           => '20700'
                                        ,i_table_name         => 'TFZGPREIS'
                                        ,i_column_name        => 'FZGPR_PREIS_GRKM'
                                        ,i_message_class      => 'W'
                                        ,i_msg_value          => 'Warning!'
                                        ,i_msg_text           => 'FZGPR_PREIS_GRKM must not be 0!'
                                        ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                        );
            END IF;

            IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_monatp = 0
            THEN
               l_jret :=
                  ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                        ,i_msg_code           => '20700'
                                        ,i_table_name         => 'TFZGPREIS'
                                        ,i_column_name        => 'FZGPR_PREIS_MONATP'
                                        ,i_message_class      => 'W'
                                        ,i_msg_value          => 'Warning'
                                        ,i_msg_text           => 'FZGPR_PREIS_MONATP must not be 0!'
                                        ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                        );
            END IF;

            --
            -- prices below max
            --
            IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_grkm > l_fzgpr_preis_grkm_max
            THEN
               l_jret :=
                  ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                        ,i_msg_code           => '20700'
                                        ,i_table_name         => 'TFZGPREIS'
                                        ,i_column_name        => 'FZGPR_PREIS_GRKM'
                                        ,i_message_class      => 'W'
                                        ,i_msg_value          => 'Warning'
                                        ,i_msg_text           =>    'FZGPR_PREIS_GRKM must not be higher than '
                                                                 || l_fzgpr_preis_grkm_max
                                                                 || ' (Global settings!)'
                                        ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                        );
            END IF;

            IF i_v_tfzgpreis_ssi (l_row).fzgpr_preis_monatp > l_fzgpr_preis_monatp_max
            THEN
               l_jret :=
                  ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                        ,i_msg_code           => '20700'
                                        ,i_table_name         => 'TFZGPREIS'
                                        ,i_column_name        => 'FZGPR_PREIS_MONATP'
                                        ,i_message_class      => 'W'
                                        ,i_msg_value          => 'Warning!'
                                        ,i_msg_text           =>    'FZGPR_PREIS_MONATP must not be higher than '
                                                                 || l_fzgpr_preis_monatp_max
                                                                 || ' (Global settings!)'
                                        ,i_msg_modul          => 'PB_CONTRACT.CHECK_PREVENT_UNVALID_PRICES'
                                        );
            END IF;
         END IF;

         l_row := i_v_tfzgpreis_ssi.NEXT (l_row);
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END check_prevent_unvalid_prices;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_start_end_mil (
      i_tfzgv_contract_ssi   IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_v_tfzgkmstand_ssi    IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object            IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
-- PetersJ, 14.10.2008, MKS 58753, REQ261.2,
-- Warning begin_km > end_km
-- Warning if begin_km = 0
-- Warnin if end_km = 0
-- PetersJ
-- Warning if real_end = 0 (MKS65967, 12.12.2008)
      l_ret                db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret               db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_numb               NUMBER;
      lc_sub_modul         VARCHAR2 (100 CHAR)                DEFAULT 'check_start_end_mil';
      l_real_end_kmstand   tfzgkmstand.fzgkm_km%TYPE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      IF i_tfzgv_contract_ssi.fzgvc_beginn_km >= i_tfzgv_contract_ssi.fzgvc_ende_km
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE_KM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          =>    i_tfzgv_contract_ssi.fzgvc_beginn_km
                                                           || ' >= '
                                                           || i_tfzgv_contract_ssi.fzgvc_ende_km
                                  ,i_msg_text           => 'FZGVC_ENDE_KM must be greater than FZGVC_BEGINN_KM'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_START_END_MIL'
                                  );
      END IF;

      IF i_tfzgv_contract_ssi.fzgvc_ende_km = 0
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE_KM'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => 0
                                  ,i_msg_text           => 'FZGVC_ENDE_KM must not be 0!'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_START_END_MIL'
                                  );
      END IF;

      l_real_end_kmstand := get_kmstand (i_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand_ssi);

      IF l_real_end_kmstand = 0
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZV_CONTRACTS'
                                  ,i_column_name        => 'FZGVC_ENDE_KM'
                                  ,i_message_class      => 'W'
                                  ,i_msg_value          => 'WARNING!'
                                  ,i_msg_text           => 'Real and mileage must not be 0!'
                                  ,i_msg_modul          => 'PB_CONTRACT.CHECK_START_END_MIL'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END check_start_end_mil;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_end_mil_gt_inv_mil (
      i_id_seq_fzgvc       IN   tfzgkmstand.id_seq_fzgvc%TYPE
     ,i_real_end_mileage   IN   tfzgkmstand.fzgkm_km%TYPE
     ,i_id_object          IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 15.10.2008, MKS 58753, REQ261.2,
      -- check for invoices with higher km than real end km

      -- Changed to warning only ==> always return SUCCESS

      -- TKIENINGER; MKS-104069:1; 2011-07-26
      -- Prevent Warning, if l_dummy is 0, because then there is no invoice found and the excetption no_data_found is not raised.
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_dummy        NUMBER;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'check_end_mil_gt_inv_mil';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      BEGIN
         SELECT COUNT (*)
           INTO l_dummy
           FROM tcustomer_invoice i
               ,tfzgkmstand k
          WHERE i.id_seq_fzgvc = i_id_seq_fzgvc
            AND i.ci_id_seq_fzgkmstand = k.id_seq_fzgkmstand
            AND i.id_seq_fzgvc = k.id_seq_fzgvc
            AND k.fzgkm_km > i_real_end_mileage;

        qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'NUM_OF_INVOICES: '||l_dummy);

        if l_dummy > 0 then

         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'W'
                                  ,i_msg_value          => 'WARNING!'
                                  ,i_msg_text           => 'Invoice with higher mileage than real end mileage found!'
                                  ,i_msg_modul          => 'PB_CONTRACT.check_end_mil_gt_inv_mil'
                                  );
      end if;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20700'
                                     ,i_table_name         => 'TFZGKMSTAND'
                                     ,i_column_name        => 'FZGKM_KM'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => 'PB_CONTRACT.check_end_mil_gt_inv_mil'
                                     );                                                     -- wir wollen nichts finden.
      END;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END check_end_mil_gt_inv_mil;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_mileage_with_scarf (
      i_tfzgvertrag_ssi      IN   ssi.tfzgvertrag%ROWTYPE
     ,i_tfzgv_contract_ssi   IN   ssi.tfzgv_contracts%ROWTYPE
     ,i_v_tfzgkmstand        IN   ssi_datatype.typ_tfzgkmstand
     ,i_id_object            IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      -- PetersJ, 15-16.10.2008, MKS 58753, REQ261.2,
      -- warning if km > set scarf-limit
      l_ret                db_datatype.db_returnstatus%TYPE        DEFAULT db_const.db_success;
      l_jret               db_datatype.db_returnstatus%TYPE        DEFAULT db_const.db_success;
      l_scat_max_mileage   tscarf_category.scat_max_mileage%TYPE;
      l_start_mileage      tfzgkmstand.fzgkm_km%TYPE;
      l_real_end_mileage   tfzgkmstand.fzgkm_km%TYPE;
      l_dummy              NUMBER;
      lc_sub_modul         VARCHAR2 (100 CHAR)                     DEFAULT 'check_mileage_with_scarf';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      BEGIN
         SELECT NVL (s.scat_max_mileage, 0)
           INTO l_scat_max_mileage
           FROM tfahrzeugtyp p
               ,ttypgruppe g
               ,tfahrzeugart a
               ,tscarf_category s
          WHERE 1 = 1
            AND i_tfzgvertrag_ssi.id_fzgtyp = p.id_fzgtyp
            AND p.id_typgruppe = g.id_typgruppe
            AND g.id_fahrzeugart = a.id_fahrzeugart
            AND a.guid_scarf_category = s.guid_scarf_category;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- that should not be happen... no scarf category found...
            NULL;
      END;

      l_start_mileage := get_kmstand (i_tfzgv_contract_ssi.id_seq_fzgkmstand_begin, i_v_tfzgkmstand);

      IF l_start_mileage > l_scat_max_mileage
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'W'
                                  ,i_msg_value          => 'WARNING!'
                                  ,i_msg_text           => 'Start Mileage exceeds allowed (SCARF) maximum!'
                                  ,i_msg_modul          => 'PB_CONTRACT.check_mileage_with_scarf'
                                  );
      END IF;

      l_real_end_mileage := get_kmstand (i_tfzgv_contract_ssi.id_seq_fzgkmstand_end, i_v_tfzgkmstand);

      IF l_real_end_mileage > l_scat_max_mileage
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'W'
                                  ,i_msg_value          => 'WARNING!'
                                  ,i_msg_text           => 'Real End Mileage exceeds allowed (SCARF) maximum!'
                                  ,i_msg_modul          => 'PB_CONTRACT.check_mileage_with_scarf'
                                  );
      END IF;

      IF i_tfzgv_contract_ssi.fzgvc_ende_km > l_scat_max_mileage
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGKMSTAND'
                                  ,i_column_name        => 'FZGKM_KM'
                                  ,i_message_class      => 'W'
                                  ,i_msg_value          => 'WARNING!'
                                  ,i_msg_text           => 'Planned End Mileage exceeds allowed (SCARF) maximum!'
                                  ,i_msg_modul          => 'PB_CONTRACT.check_mileage_with_scarf'
                                  );
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END check_mileage_with_scarf;

-- End of Warning checks (MKS 58753)
  ------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_stati_real_end_milage (
      i_id_seq_fzgkmstand_end   IN   tfzgv_contracts.id_seq_fzgkmstand_end%TYPE
     ,i_id_vertrag              IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag           IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,iobjectid                 IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_char            snt.tglobal_settings.VALUE%TYPE;
      lc_sub_modul      VARCHAR2 (100 CHAR)                 DEFAULT 'CK_STATI_REAL_END_MILAGE';
      l_ret             db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
      log_ret           db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
      i_cos_stat_code   tdfcontr_state.cos_stat_code%TYPE;
   BEGIN
      /*
      MKS 60408; REQ287.2.2 - WOP1521:
      Implement Check State finished requires real end date and real end mileage (--> REQ275.3)
      MKS-61140; Vertragsstatus wird noch nicht gepr?ft - Muss eingebaut werden.
      MKS-65533: Status wird jetzt gepr?ft (JaP)
      */
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_char := snt.get_tglobal_settings ('Sirius'
                                         ,'Setting'
                                         ,'EndMileageRequiredForSC'
                                         ,0
                                         );
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                  ,    'ck_stati_real_end_milage: ID_VERTRAG:'
                    || i_id_vertrag
                    || ' - ID_FZGVERTRAG:'
                    || i_id_fzgvertrag
                    || ' - ID_OBJECT:'
                    || iobjectid
                    || ' - Setting: '
                    || l_char);

      SELECT tdf.cos_stat_code
        INTO i_cos_stat_code
        FROM snt.tdfcontr_state tdf
            ,ssi.tfzgvertrag tfzg
       WHERE tfzg.id_vertrag = i_id_vertrag
         AND tfzg.id_fzgvertrag = i_id_fzgvertrag
         AND tfzg.id_cos = tdf.id_cos
         AND tfzg.id_object = iobjectid;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'After Select: i_cos_stat_code: ' || i_cos_stat_code);

      IF l_char LIKE '%' || i_cos_stat_code || '%'
      THEN
         IF i_id_seq_fzgkmstand_end IS NULL
         THEN
            l_ret := db_const.db_fail;
            log_ret :=
               ssi.ssi_log.store_msg
                  (i_id_object          => iobjectid
                  ,i_msg_code           => '20700'
                  ,i_table_name         => 'TFZGV_CONTRACTS'
                  ,i_column_name        => 'ID_SEQ_FZGKMSTAND_END'
                  ,i_message_class      => 'N'
                  ,i_msg_value          => i_id_seq_fzgkmstand_end
                  ,i_msg_text           =>    'ID_SEQ_FZGKMSTAND_END is not set, but required because auf GS Sirius/Setting/EndMileageRequiredForSC = '
                                           || l_char
                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                  );
         END IF;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         l_ret := db_const.db_fail;
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                     , '***** End of Function ***** - EXCEPTION OTHERS ' || 'No Master Data Found');
         log_ret :=
            ssi.ssi_log.store_msg (i_id_object          => iobjectid
                                  ,i_msg_code           => '20300'
                                  ,i_table_name         => 'TDFCONTR_STATE'
                                  ,i_column_name        => 'COS_ACTIVE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           =>    'No Master Data Found in Global Settings - '
                                                           || DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         RETURN l_ret;
      WHEN OTHERS
      THEN
         l_ret := db_const.db_fail;
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                     ,    '***** End of Function ***** - EXCEPTION OTHERS '
                       || SQLERRM
                       || '-'
                       || DBMS_UTILITY.format_error_backtrace);
         log_ret :=
            ssi.ssi_log.store_msg (i_id_object          => iobjectid
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'ID_SEQ_FZGKMSTAND_END'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         RETURN l_ret;
   END ck_stati_real_end_milage;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION chk_begin_lower_as_end_mileage (
      i_fzgpr_begin_mileage   IN   tfzgpreis.fzgpr_begin_mileage%TYPE
     ,i_fzgpr_end_mileage     IN   tfzgpreis.fzgpr_end_mileage%TYPE
     ,i_id_object             IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'chk_begin_lower_as_end_mileage';
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret         db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
   BEGIN
      /*
      MKS 70154: 2.6.0
      REQ331: Handling of contracts with stepped rates - WOP1634: Implement SSI
      ?Check: FZGPR_BEGIN_MILEAGE muss kleiner FZGPR_END_MILEAGE sein
      */
      IF NOT i_fzgpr_begin_mileage < i_fzgpr_end_mileage
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_fzgpr_begin_mileage
                                  ,i_msg_text           =>    'FZGPR_END_MILEAGE('
                                                           || i_fzgpr_end_mileage
                                                           || ')'
                                                           || ' may not be lower as FZGPR_BEGIN_MILEAGE('
                                                           || i_fzgpr_begin_mileage
                                                           || ')'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         l_ret := db_const.db_fail;
      END IF;

      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         l_ret := db_const.db_fail;
         RETURN l_ret;
   END chk_begin_lower_as_end_mileage;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION chk_fzgpr_mileage_overlapping (
      i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_id_object         IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      lc_sub_modul           VARCHAR2 (100 CHAR)                DEFAULT 'chk_fzgpr_mileage_overlapping';
      l_ret                  db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_tfzgpreis_current    ssi.tfzgpreis%ROWTYPE;
      l_tfzgpreis_previous   ssi.tfzgpreis%ROWTYPE;
      l_row                  NUMBER;
      l_firstchecked         BOOLEAN                            := FALSE;
   BEGIN
      /*
      MKS 70154: 2.6.0
      REQ331: Handling of contracts with stepped rates - WOP1634: Implement SSI
      ?Check: Auf ?berlappende KM-Standsangaben pr?fen
      */
      l_row := i_v_tfzgpreis_ssi.FIRST;

      WHILE (l_row IS NOT NULL)
      LOOP
         l_tfzgpreis_current := i_v_tfzgpreis_ssi (l_row);

         -- MKS-83721:1; TK; Add reference Key with id_fzgvertrag
         IF l_tfzgpreis_current.id_seq_fzgvc = i_id_seq_fzgvc
         THEN
            IF NOT l_firstchecked
            THEN
               l_firstchecked := TRUE;
            ELSE
               IF l_tfzgpreis_current.fzgpr_begin_mileage < l_tfzgpreis_previous.fzgpr_end_mileage + 1
               THEN
                  IF i_id_object IS NOT NULL
                  THEN
                     l_jret :=
                        ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                              ,i_msg_code           => '20700'
                                              ,i_table_name         => 'TFZGPREIS'
                                              ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                              ,i_message_class      => 'N'
                                              ,i_msg_value          =>    l_tfzgpreis_current.fzgpr_begin_mileage
                                                                       || ' < '
                                                                       || (l_tfzgpreis_previous.fzgpr_end_mileage + 1)
                                              ,i_msg_text           => 'There are overlapping mileages in stepped rates'
                                              ,i_msg_modul          => 'PB_CONTRACT.chk_fzgpr_mileage_overlapping'
                                              );
                  END IF;

                  l_ret := db_const.db_fail;
               END IF;
            END IF;
         END IF;

         l_tfzgpreis_previous := l_tfzgpreis_current;
         l_row := i_v_tfzgpreis_ssi.NEXT (l_row);
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         RETURN db_const.db_fail;
   END chk_fzgpr_mileage_overlapping;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION chk_allpricevalues_tfzgpreis (
      i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_id_object         IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      lc_sub_modul          VARCHAR2 (100 CHAR)                DEFAULT 'chk_allPriceValues_tfzgpreis';
      l_ret                 db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_jret                db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      intbeginendmileage    NUMBER;
      intcountnull          NUMBER;
      intcountgreaternull   NUMBER;
   BEGIN
      /*
        MKS 70154: 2.6.0
        REQ331:   Handling of contracts with stepped rates - WOP1634: Implement SSI
        ?Check: - Beide neuen Felder haben entweder bei ALLEN Preisen eines Vertrags einen Wert, oder kein einziger.
      */-- MKS-83721:1; TK; Add reference Key with id_fzgvertrag
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      BEGIN
         SELECT COUNT (*)
           INTO intbeginendmileage
           FROM ssi.tfzgpreis
          WHERE id_seq_fzgvc = i_id_seq_fzgvc;

         SELECT COUNT (*)
           INTO intcountnull
           FROM ssi.tfzgpreis
          WHERE id_seq_fzgvc = i_id_seq_fzgvc
            AND tfzgpreis.fzgpr_begin_mileage IS NULL
            AND tfzgpreis.fzgpr_end_mileage IS NULL;

         IF NOT intbeginendmileage = intcountnull
         THEN
            SELECT COUNT (*)
              INTO intcountgreaternull
              FROM ssi.tfzgpreis
             WHERE id_seq_fzgvc = i_id_seq_fzgvc
               AND tfzgpreis.fzgpr_begin_mileage IS NOT NULL
               AND tfzgpreis.fzgpr_end_mileage IS NOT NULL;

            IF NOT intbeginendmileage = intcountgreaternull
            THEN
               l_jret :=
                  ssi.ssi_log.store_msg
                                  (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => NULL
                                  ,i_msg_text           => 'Not all or not one Prices of contract have mileage values in prices'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
               l_ret := db_const.db_fail;
            END IF;
         END IF;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
         RETURN l_ret;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20900'
                                     ,i_table_name         => 'TFZGPREIS'
                                     ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                     ,i_message_class      => 'N'
                                     ,i_msg_value          => SQLERRM
                                     ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                     );
            l_ret := db_const.db_fail;
            RETURN l_ret;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         l_ret := db_const.db_fail;
         RETURN l_ret;
   END chk_allpricevalues_tfzgpreis;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION chk_paym_stepped_rates (
      i_id_paym           IN   tfzgv_contracts.id_paym%TYPE
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
     ,i_id_object         IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      lc_sub_modul           VARCHAR2 (100 CHAR)                      DEFAULT 'chk_PAYM_STEPPED_RATES';
      l_ret                  db_datatype.db_returnstatus%TYPE         DEFAULT db_const.db_success;
      l_jret                 db_datatype.db_returnstatus%TYPE         DEFAULT db_const.db_success;
      i_paym_stepped_rates   snt.tdfpaymode.paym_stepped_rates%TYPE;
      l_tfzgpr               NUMBER;
   BEGIN
      /*
        MKS 72630: 2.6.0
        MKS 74329: 2.6.1
      */
      -- FraBe 23.06.2009 MKS-74680:3 replace TDFCONTR_VARIANT.COV_STEPPED_RATES by TDFPAYMODE.PAYM_STEPPED_RATES
      -- FraBe 23.06.2009 MKS-74769:1 do not check steppes rates flag = 0 anymore
      SELECT paym_stepped_rates
        INTO i_paym_stepped_rates
        FROM tdfpaymode
       WHERE id_paym = i_id_paym;

      -- FraBe 23.06.2009 MKS-74769:1 do not check steppes rates flag = 0 anymore
      IF i_paym_stepped_rates = 0
      THEN
         NULL;
      /*
      --Preis darf nicht vorhanden sein
      FOR l_tfzgpr IN i_v_tfzgpreis_ssi.FIRST .. i_v_tfzgpreis_ssi.LAST LOOP
        IF i_v_tfzgpreis_ssi(l_tfzgpr).fzgpr_begin_mileage > 0
        OR i_v_tfzgpreis_ssi(l_tfzgpr).fzgpr_end_mileage > 0
        THEN
          l_ret := db_const.db_fail;
        END IF;
      END LOOP;
      */
      ELSIF i_paym_stepped_rates = 1
      THEN
          --Preis muss vorhanden sein

          -- FraBe 2013-01-14 MKS-118830 do check only if i_V_TFZGPREIS_SSI is not empty
          if   i_V_TFZGPREIS_SSI.FIRST <> NULL
          then FOR l_tfzgpr IN i_V_TFZGPREIS_SSI.FIRST .. i_V_TFZGPREIS_SSI.LAST
               LOOP
                   -- MKS-83721:2 TK - Check for related id_seq_fzgvc
                   IF   i_v_tfzgpreis_ssi (l_tfzgpr).id_seq_fzgvc = i_id_seq_fzgvc
                   THEN
                       IF    (   i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_begin_mileage < 0
                              OR i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_end_mileage < 0
                             )
                          OR (   i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_begin_mileage IS NULL
                              OR i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_end_mileage IS NULL
                             )
                       THEN
                           l_ret := db_const.db_fail;
                       END IF;
                   END IF;
               END LOOP;
          END  IF;
      END IF;

      RETURN l_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- MKS-79339:2; TK 2009-10-02;
         -- this causes, if delivered payment mode does not exist in database
         -- then we give here a success, knowing that another check fails due to missing id_payment
         -- this prevents multiple error messages caused by one single error.
         RETURN db_const.db_success;
      WHEN OTHERS
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZGPREIS'
                                  ,i_column_name        => 'FZGPR_BEGIN_MILEAGE'
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         l_ret := db_const.db_fail;
         RETURN l_ret;
   END chk_paym_stepped_rates;

----------------------------------------------------------------------------------------------------------------------
   FUNCTION check_manual_processing (
      i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object       IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_lock         NUMBER;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'check_manual_processing';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      SELECT fzgv_manual_processing
        INTO l_lock
        FROM snt.tfzgvertrag
       WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag;

      IF l_lock = 1                                                                                             --locked
      THEN
         l_ret := db_const.db_fail;
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20700'
                                  ,i_table_name         => 'TFZVERTRAG'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => i_id_vertrag || '/' || i_id_fzgvertrag
                                  ,i_msg_text           => 'Contract is blocked for manual processing. No update is allowed'
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
      ELSE
         l_ret := db_const.db_success;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;                                 -- contract does not exist and therefore it is not blocked!  INSERT MODE
         RETURN db_const.db_success;
      WHEN OTHERS
      THEN
         l_jret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20900'
                                  ,i_table_name         => 'TFZVERTRAG'
                                  ,i_column_name        => ''
                                  ,i_message_class      => 'N'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN db_const.db_fail;
   END check_manual_processing;

------------------------------------------------------
-- 2.7.0
-- MKS-88207
   FUNCTION check_price_calculation_comp (
      i_id_object         IN   tssi_journal.id_object%TYPE
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_lock         NUMBER;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'Check_PRICE_CALCULATION_COMP';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      -- FraBe 2013-01-14 MKS-118830 do check only if i_V_TFZGPREIS_SSI is not empty
      if   i_V_TFZGPREIS_SSI.FIRST <> NULL
      then FOR l_tfzgpr IN i_V_TFZGPREIS_SSI.FIRST .. i_V_TFZGPREIS_SSI.LAST
           LOOP
               -- If price calculation parts are delivered, ALL price calculation parts must be delivered
               IF   i_v_tfzgpreis_ssi (l_tfzgpr).id_seq_fzgvc = i_id_seq_fzgvc
               THEN
                    IF (    i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_admin_fee_mlp IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_admin_fee_tt IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha IS NULL
                        AND i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original IS NULL
                       )
                    THEN NULL;                                                 -- no price calculation parts delivered - is valid
                    ELSE
                         -- price calculation aprts are delivered but maybe not all
                         IF (  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_admin_fee_mlp
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_admin_fee_tt
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha
                             + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original
                            ) IS NULL
                         THEN
                            -- addition of numbers with NULL delivers NULL otherwise a number
                            l_ret := db_const.db_fail;
                            l_jret :=
                               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                     ,i_msg_code           => '20700'
                                                     ,i_table_name         => 'TFZGPREIS'
                                                     ,i_column_name        => ''
                                                     ,i_message_class      => 'N'
                                                     ,i_msg_value          => i_v_tfzgpreis_ssi (l_tfzgpr).price_range_ext_id
                                                     ,i_msg_text           => 'Not all price calculation parts are delivered'
                                                     ,i_msg_modul          => lgc_modul || lc_sub_modul
                                                     );
                         END  IF;
                    END  IF;
               END  IF;
           END LOOP;
      END  IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      RETURN l_ret;
   END check_price_calculation_comp;

-- MKS88216
   FUNCTION check_technical_tarif (
      i_id_object         IN   tssi_journal.id_object%TYPE
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_lock         NUMBER;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'CHECK_TECHNICAL_TARIF';
      l_threshhold   NUMBER;
      l_diff         NUMBER;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_threshhold :=
              snt.get_tglobal_settings ('SIRIUS'
                                       ,'Setting'
                                       ,'PriceCalculationParts.AllowedRoundingDifference'
                                       ,0
                                       ) / 100;

      -- FraBe 2013-01-14 MKS-118830 do check only if i_V_TFZGPREIS_SSI is not empty
      if   i_V_TFZGPREIS_SSI.FIRST <> NULL
      then FOR l_tfzgpr IN i_V_TFZGPREIS_SSI.FIRST .. i_V_TFZGPREIS_SSI.LAST
           LOOP
               IF  i_v_tfzgpreis_ssi (l_tfzgpr).id_seq_fzgvc = i_id_seq_fzgvc
               THEN
                   l_diff :=
                        i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt
                      - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                      - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas
                      - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa;

                   IF (   ((  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                            + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas
                            + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa
                           ) > i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt + l_threshhold
                          )
                       OR ((  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                            + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas
                            + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa
                           ) < i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt - l_threshhold
                          )
                      )
                   THEN
                      -- TT = MLP+SUBBU+SUBSA
                      -- l_ret := db_const.db_fail;  -- Check zu hart - nur Warning
                      l_jret :=
                         ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                               ,i_msg_code           => '20700'
                                               ,i_table_name         => 'TFZGPREIS'
                                               ,i_column_name        => ''
                                               ,i_message_class      => 'W'
                                               ,i_msg_value          => l_diff
                                               ,i_msg_text           =>    'Price calculation parts check 1: '
                                                                        || l_diff
                                                                        || ' = '
                                                                        || TO_CHAR (  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_tt
                                                                                    - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp)
                                                                        || ' (TT - MLP) -  '
                                                                        || TO_CHAR (  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subas
                                                                                    + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subsa)
                                                                        || ' (sum discounts)'
                                               ,i_msg_modul          => lgc_modul || lc_sub_modul
                                               );
                   END IF;
               END IF;
           END LOOP;
      END  IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      RETURN l_ret;
   END check_technical_tarif;

   FUNCTION check_mlp (
      i_id_object         IN   tssi_journal.id_object%TYPE
     ,i_id_seq_fzgvc      IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_v_tfzgpreis_ssi   IN   ssi_datatype.typ_tfzgpreis
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_lock         NUMBER;
      l_jret         db_datatype.db_returnstatus%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'CHECK_MLP';
      l_threshhold   NUMBER;
      l_diff         NUMBER;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      l_threshhold :=
              snt.get_tglobal_settings ('SIRIUS'
                                       ,'Setting'
                                       ,'PriceCalculationParts.AllowedRoundingDifference'
                                       ,0
                                       ) / 100;

      -- FraBe 2013-01-14 MKS-118830 do check only if i_V_TFZGPREIS_SSI is not empty
      if   i_V_TFZGPREIS_SSI.FIRST <> NULL
      then FOR l_tfzgpr IN i_V_TFZGPREIS_SSI.FIRST .. i_V_TFZGPREIS_SSI.LAST
           LOOP
               IF   i_v_tfzgpreis_ssi (l_tfzgpr).id_seq_fzgvc = i_id_seq_fzgvc
               THEN
                    l_diff :=
                         i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha
                       - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original;

                    IF     (   ((  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original
                                 + l_threshhold
                                ) > i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                               )
                            OR ((  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha
                                 + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original
                                 - l_threshhold
                                ) < i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                               )
                           )
                       AND l_diff <> 0                                                                -- mks-89585;TK;2010-06-21
                    THEN
                       --MLP = MF_ORIGINAL+SUBBU+DISCAS+DISSAl+DISCHA+DISCAS
                       --l_ret := db_const.db_fail;  -- Check zu hart - nur Warning
                       l_jret :=
                          ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                                ,i_msg_code           => '20700'
                                                ,i_table_name         => 'TFZGPREIS'
                                                ,i_column_name        => ''
                                                ,i_message_class      => 'W'
                                                ,i_msg_value          => l_diff
                                                ,i_msg_text           =>    'Price calculation parts check 2: '
                                                                         || l_diff
                                                                         || ' = '
                                                                         || TO_CHAR
                                                                                  (  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mlp
                                                                                   - i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_mf_original)
                                                                         || ' (MLP - MF ORIGINAL) -  '
                                                                         || TO_CHAR (  i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_subbu
                                                                                     + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discas
                                                                                     + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_disde
                                                                                     + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_dissal
                                                                                     + i_v_tfzgpreis_ssi (l_tfzgpr).fzgpr_discha)
                                                                         || ' (sum subsidies)'
                                                ,i_msg_modul          => lgc_modul || lc_sub_modul
                                                );
                    END  IF;
               END  IF;
           END LOOP;
      END  IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      RETURN l_ret;
   END check_mlp;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tfzgvertrag (
      i_id_vertrag      IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object       IN              tssi_journal.id_object%TYPE
     ,vi_tfzgvertrag    IN OUT NOCOPY   ssi_datatype.typ_tfzgvertrag
   )
      RETURN VARCHAR2
   IS
      c_idv          NUMBER;
      lc_sub_modul   VARCHAR2 (100 CHAR) DEFAULT 'CK_INSUPDEL_TFZGVERTRAG';
      l_i            PLS_INTEGER         DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tfzgvertrag.DELETE;

      FOR r_idv IN (SELECT *
                      FROM ssi.tfzgvertrag
                     WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tfzgvertrag (l_i) := r_idv;
      END LOOP;

      SELECT COUNT (*)
        INTO c_idv
        FROM tfzgvertrag
       WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag;

      IF c_idv > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END ck_insupdel_tfzgvertrag;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tfzgv_contracts (
      i_id_seq_fzgvc               IN              tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_id_vertrag                 IN              tfzgv_contracts.id_vertrag%TYPE
     ,i_id_fzgvertrag              IN              tfzgv_contracts.id_fzgvertrag%TYPE
     ,i_contract_duration_ext_id   IN              tfzgv_contracts.contract_duration_ext_id%TYPE
     ,i_id_object                  IN              tssi_journal.id_object%TYPE
     ,vi_tfzgv_contracts           IN OUT NOCOPY   ssi_datatype.typ_tfzgv_contracts
   )
      RETURN VARCHAR2
   IS
      c_idv          NUMBER;
      lc_sub_modul   VARCHAR2 (100 CHAR) DEFAULT 'ck_insupdel_tfzgv_contracts';
      l_i            PLS_INTEGER         DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tfzgv_contracts.DELETE;

      FOR r_idv IN (SELECT *
                      FROM ssi.tfzgv_contracts
                     WHERE id_seq_fzgvc = i_id_seq_fzgvc
                       AND id_vertrag = i_id_vertrag
                       AND id_fzgvertrag = i_id_fzgvertrag
                       AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tfzgv_contracts (l_i) := r_idv;
      END LOOP;

      /*
        humermar => 25.11.2008
        MKS 64601
      */
      SELECT COUNT (*)
        INTO c_idv
        FROM tfzgv_contracts
       WHERE id_seq_fzgvc = i_id_seq_fzgvc;

      IF c_idv > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END ck_insupdel_tfzgv_contracts;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tfzgkmstand (
      i_id_seq_fzgkmstand   IN              tfzgkmstand.id_seq_fzgkmstand%TYPE
     ,i_id_vertrag          IN              tfzgkmstand.id_vertrag%TYPE
     ,i_id_fzgvertrag       IN              tfzgkmstand.id_fzgvertrag%TYPE
     ,i_id_object           IN              tssi_journal.id_object%TYPE
     ,vi_tfzgkmstand        IN OUT NOCOPY   ssi_datatype.typ_tfzgkmstand
   )
      RETURN VARCHAR2
   IS
      c_tkm          NUMBER;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'ck_insupdel_tfzgkmstand';
      l_i            PLS_INTEGER    DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tfzgkmstand.DELETE;

      FOR r_tkm IN (SELECT *
                      FROM ssi.tfzgkmstand
                     WHERE id_seq_fzgkmstand = i_id_seq_fzgkmstand
                       AND id_vertrag = i_id_vertrag
                       AND id_fzgvertrag = i_id_fzgvertrag
                       AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tfzgkmstand (l_i) := r_tkm;
      END LOOP;

      SELECT COUNT (*)
        INTO c_tkm
        FROM tfzgkmstand
       WHERE id_seq_fzgkmstand = i_id_seq_fzgkmstand AND id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag;

      IF c_tkm > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tfzglaufleistung (
      i_id_seq_fzglaufleistung   IN              tfzglaufleistung.id_seq_fzglaufleistung%TYPE
     ,i_id_vertrag               IN              tfzglaufleistung.id_vertrag%TYPE
     ,i_id_fzgvertrag            IN              tfzglaufleistung.id_fzgvertrag%TYPE
     ,i_id_object                IN              tssi_journal.id_object%TYPE
     ,vi_tfzglaufleistung        IN OUT NOCOPY   ssi_datatype.typ_tfzglaufleistung
   )
      RETURN VARCHAR2
   IS
      c_ll           NUMBER;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'ck_insupdel_tfzglaufleistung';
      l_i            PLS_INTEGER    DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tfzglaufleistung.DELETE;

      FOR r_ll IN (SELECT *
                     FROM ssi.tfzglaufleistung
                    WHERE id_seq_fzglaufleistung = i_id_seq_fzglaufleistung
                      AND id_vertrag = i_id_vertrag
                      AND id_fzgvertrag = i_id_fzgvertrag
                      AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tfzglaufleistung (l_i) := r_ll;
      END LOOP;

      SELECT COUNT (*)
        INTO c_ll
        FROM tfzglaufleistung
       WHERE id_seq_fzglaufleistung = i_id_seq_fzglaufleistung
         AND id_vertrag = i_id_vertrag
         AND id_fzgvertrag = i_id_fzgvertrag;

      IF c_ll > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tfzgpreis (
      i_id_seq_fzgpreis   IN              tfzgpreis.id_seq_fzgpreis%TYPE
     ,i_id_vertrag        IN              tfzgpreis.id_vertrag%TYPE
     ,i_id_fzgvertrag     IN              tfzgpreis.id_fzgvertrag%TYPE
     ,i_id_object         IN              tssi_journal.id_object%TYPE
     ,vi_tfzgpreis        IN OUT NOCOPY   ssi_datatype.typ_tfzgpreis
   )
      RETURN VARCHAR2
   IS
      c_tpre         NUMBER;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'ck_insupdel_tfzgpreis';
      l_i            PLS_INTEGER    DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tfzgpreis.DELETE;

      FOR r_pre IN (SELECT *
                      FROM ssi.tfzgpreis
                     WHERE id_seq_fzgpreis = i_id_seq_fzgpreis
                       AND id_vertrag = i_id_vertrag
                       AND id_fzgvertrag = i_id_fzgvertrag
                       AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tfzgpreis (l_i) := r_pre;
      END LOOP;

      SELECT COUNT (*)
        INTO c_tpre
        FROM tfzgpreis
       WHERE id_seq_fzgpreis = i_id_seq_fzgpreis AND id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag;

      IF c_tpre > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tic_co_pack_ass (
      i_guid_contract      IN              tic_co_pack_ass.guid_contract%TYPE
     ,i_id_vertrag         IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag      IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object          IN              tssi_journal.id_object%TYPE
     ,vi_tic_co_pack_ass   IN OUT NOCOPY   ssi_datatype.typ_tic_co_pack_ass
   )
      RETURN VARCHAR2
   IS
      c_tic          NUMBER;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'ck_insupdel_tic_co_pack_ass';
      l_jret         db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_i            PLS_INTEGER                        DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      vi_tic_co_pack_ass.DELETE;

      -- Delete tic_co_pack_ass --------------------------------------------------------------------------
      BEGIN
         DELETE      snt.tic_co_pack_ass
               WHERE guid_contract = i_guid_contract;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_jret :=
               ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                     ,i_msg_code           => '20400'
                                     ,i_table_name         => 'TIC_CO_PACK_ASS'
                                     ,i_column_name        => 'GUID_CONTRACT'
                                     ,i_message_class      => 'R'
                                     ,i_msg_value          => 'Could not delete Table TIC_CO_PACK_ASS'
                                     ,i_msg_text           => SQLERRM
                                     ,i_msg_modul          => 'pb_contract.ck_insupdel_tic_co_pack_ass'
                                     );
      END;

----------------------------------------------------------------------------------------------------
      FOR r_tic IN (SELECT *
                      FROM ssi.tic_co_pack_ass
                     WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         vi_tic_co_pack_ass (l_i) := r_tic;
      END LOOP;

      --SELECT COUNT (*)
      --INTO   c_tic
      --FROM   tic_co_pack_ass
      --WHERE  guid_contract = i_guid_contract;

      --IF c_tic > 0
      --THEN
      --  qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
      --  RETURN pu_userfunc.tableapi.UPDATING;
      --ELSE
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
      RETURN pu_userfunc.tableapi.INSERTING;
   --END IF;
   END ck_insupdel_tic_co_pack_ass;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION ck_insupdel_tvega_i55_co (
      i_guid_contract   IN   tvega_i55_co.guid_contract%TYPE
     ,i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object       IN   tssi_journal.id_object%TYPE
   )
      RETURN VARCHAR2
   IS
      c_tveg         NUMBER;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'ck_insupdel_tvega_i55_co';
      l_i            PLS_INTEGER    DEFAULT 0;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      SELECT COUNT (*)
        INTO c_tveg
        FROM tvega_i55_co
       WHERE guid_contract = i_guid_contract;

      IF c_tveg > 0
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - UPDATING');
         RETURN pu_userfunc.tableapi.UPDATING;
      ELSE
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - INSERTING');
         RETURN pu_userfunc.tableapi.INSERTING;
      END IF;
   END ck_insupdel_tvega_i55_co;

   FUNCTION ins_tvertragstamm (
      v_tfzgv_contracts   IN   ssi_datatype.typ_tfzgv_contracts
     ,v_tfzgvertrag       IN   ssi_datatype.typ_tfzgvertrag
     ,v_tfzgpreis_ssi     IN   ssi_datatype.typ_tfzgpreis
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      c_tvst         PLS_INTEGER                        DEFAULT 0;
      i_id_cov       tfzgv_contracts.id_cov%TYPE;
      i_id_paym      tfzgv_contracts.id_paym%TYPE;
      i_id_prv       tfzgpreis.id_prv%TYPE;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'ins_tvertragstamm';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      SELECT COUNT (*)
        INTO c_tvst
        FROM tvertragstamm
       WHERE id_vertrag = v_tfzgvertrag (1).id_vertrag;

      IF NOT c_tvst > 0
      THEN
         BEGIN
            SELECT DISTINCT (id_cov)
                           ,id_paym
                       INTO i_id_cov
                           ,i_id_paym
                       FROM ssi.tfzgv_contracts
                      WHERE id_vertrag = v_tfzgvertrag (1).id_vertrag
                            AND id_fzgvertrag = v_tfzgvertrag (1).id_fzgvertrag;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_ret :=
                  ssi.ssi_log.store_msg (i_id_object          => v_tfzgvertrag (1).id_object
                                        ,i_msg_code           => '20400'
                                        ,i_table_name         => 'TFZGV_CONTRACTS'
                                        ,i_column_name        => 'id_cov'
                                        ,i_message_class      => 'R'
                                        ,i_msg_value          => 'No_Data_Found'
                                        ,i_msg_text           => 'No id_prv or id_paym found in Stage ssi_tfzgv_contracts'
                                        ,i_msg_modul          => 'pb_contract.ins_tvertragstamm'
                                        );
               RETURN db_const.db_fail;
         END;

         BEGIN
            SELECT DISTINCT (id_prv)
                       INTO i_id_prv
                       FROM ssi.tfzgpreis
                      WHERE id_vertrag = v_tfzgvertrag (1).id_vertrag
                            AND id_fzgvertrag = v_tfzgvertrag (1).id_fzgvertrag;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_ret :=
                  ssi.ssi_log.store_msg (i_id_object          => v_tfzgvertrag (1).id_object
                                        ,i_msg_code           => '20400'
                                        ,i_table_name         => 'TFZGPREIS'
                                        ,i_column_name        => 'id_prv'
                                        ,i_message_class      => 'R'
                                        ,i_msg_value          => 'No_Data_Found'
                                        ,i_msg_text           => 'No id_prv found in Stage ssi_tfzgpreis'
                                        ,i_msg_modul          => 'pb_contract.ins_tvertragstamm'
                                        );
               RETURN db_const.db_fail;
         END;

         /*
           MKS 61096: HumerMar, 13.Oktober.2008
           n?tige Felder in TVERTRAGSTAMM
         */
         BEGIN
            INSERT INTO tvertragstamm
                        (id_vertrag
                        ,id_customer
                        ,guid_indv
                        ,id_cos
                        ,id_garage
                        ,id_paym
                        ,id_cov
                        ,id_prv
                        ,vertr_beginn
                        ,vertr_ende
                        )
                 VALUES (v_tfzgvertrag (1).id_vertrag
                        ,v_tfzgv_contracts (1).id_customer
                        ,v_tfzgv_contracts (1).guid_indv
                        ,v_tfzgvertrag (1).id_cos
                        ,v_tfzgvertrag (1).id_garage
                        ,i_id_paym
                        ,i_id_cov
                        ,i_id_prv
                        ,v_tfzgv_contracts (1).fzgvc_beginn
                        ,v_tfzgv_contracts (1).fzgvc_ende
                        );

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN db_const.db_fail;
         END;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END ins_tvertragstamm;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION upd_tfzgv_contracts (
      i_id_seq_fzgvc              IN   tfzgv_contracts.id_seq_fzgvc%TYPE
     ,i_id_vertrag                IN   tfzgv_contracts.id_vertrag%TYPE
     ,i_id_fzgvertrag             IN   tfzgv_contracts.id_fzgvertrag%TYPE
     ,i_id_object                 IN   tssi_journal.id_object%TYPE
     ,i_id_seq_fzgkmstand_begin   IN   tfzgv_contracts.id_seq_fzgkmstand_begin%TYPE
     ,i_id_seq_fzgkmstand_end     IN   tfzgv_contracts.id_seq_fzgkmstand_end%TYPE
   --,v_tfzgv_contracts   IN   ssi_datatype.typ_tfzgv_contracts
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ind          PLS_INTEGER                        DEFAULT NULL;
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      lc_sub_modul   VARCHAR2 (100 CHAR)                DEFAULT 'upd_tfzgv_contracts';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
--  l_ind := v_tfzgv_contracts.FIRST;
    --  WHILE (l_ind IS NOT NULL)
--  LOOP
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'l_ind: ' || l_ind);
--                                            ||' id_seq_fzgkmstand_begin: '||v_tfzgv_contracts (l_ind).id_seq_fzgkmstand_begin
--                                            ||' id_seq_fzgkmstand_end: '||v_tfzgv_contracts (l_ind).id_seq_fzgkmstand_end);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_seq_fzgkmstand_begin ' || i_id_seq_fzgkmstand_begin);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_seq_fzgkmstand_end ' || i_id_seq_fzgkmstand_end);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_vertrag ' || i_id_vertrag);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_fzgvertrag ' || i_id_fzgvertrag);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_seq_fzgvc ' || i_id_seq_fzgvc);

      UPDATE tfzgv_contracts
         SET id_seq_fzgkmstand_begin = i_id_seq_fzgkmstand_begin    -- v_tfzgv_contracts (l_ind).id_seq_fzgkmstand_begin
            ,id_seq_fzgkmstand_end = i_id_seq_fzgkmstand_end          -- v_tfzgv_contracts (l_ind).id_seq_fzgkmstand_end
       WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_seq_fzgvc = i_id_seq_fzgvc;

--     l_ind := v_tfzgv_contracts.NEXT (l_ind);
    --  END LOOP;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret :=
            ssi.ssi_log.store_msg (i_id_object          => i_id_object
                                  ,i_msg_code           => '20400'
                                  ,i_table_name         => 'TFZGV_CONTRACTS'
                                  ,i_column_name        => 'ID_SEQ_FZGKMSTAND_BEGIN'
                                  ,i_message_class      => 'R'
                                  ,i_msg_value          => SQLERRM
                                  ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                  ,i_msg_modul          => lgc_modul || lc_sub_modul
                                  );
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                     , '***** End of Function ***** - EXCEPTION OTHERS - ' || SQLERRM);
         RETURN db_const.db_fail;
   END upd_tfzgv_contracts;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION del_nonused_rec (
      i_id_vertrag             IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag          IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,v_tfzgv_contracts_ssi    IN   ssi_datatype.typ_tfzgv_contracts
     ,v_tfzgpreis_ssi          IN   ssi_datatype.typ_tfzgpreis
     ,v_tfzglaufleistung_ssi   IN   ssi_datatype.typ_tfzglaufleistung
     ,v_tfzgkmstand_ssi        IN   ssi_datatype.typ_tfzgkmstand
     ,v_tic_co_pack_ass_ssi    IN   ssi_datatype.typ_tic_co_pack_ass
     ,v_tvega_i55_co_ssi       IN   ssi_datatype.typ_tvega_i55_co
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_id           PLS_INTEGER                        DEFAULT NULL;
      bfound         BOOLEAN                            DEFAULT TRUE;
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'del_nonused_rec';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Deleting Entry of TFZGLAUFLEISTUNG');

-- tfzglaufleistung ----------------------------------------------------------------------------------------------------
      FOR r_tfzgll IN (SELECT *
                         FROM tfzglaufleistung
                        WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag)
      LOOP
         l_id := v_tfzglaufleistung_ssi.FIRST;

         WHILE (l_id IS NOT NULL)
         LOOP
            IF     r_tfzgll.id_vertrag = v_tfzglaufleistung_ssi (l_id).id_vertrag
               AND r_tfzgll.id_fzgvertrag = v_tfzglaufleistung_ssi (l_id).id_fzgvertrag
               AND r_tfzgll.mileage_classification_ext_id = v_tfzglaufleistung_ssi (l_id).mileage_classification_ext_id
               AND r_tfzgll.contract_duration_ext_id = v_tfzglaufleistung_ssi (l_id).contract_duration_ext_id
            THEN
               -- Record founded for update
               bfound := TRUE;
            ELSE
               bfound := FALSE;
            END IF;

            IF NOT bfound = TRUE
            -- Record not found in array. We must delete it.
            THEN
               BEGIN
                  DELETE FROM tfzglaufleistung
                        WHERE id_vertrag = r_tfzgll.id_vertrag
                          AND id_fzgvertrag = r_tfzgll.id_fzgvertrag
                          AND mileage_classification_ext_id = r_tfzgll.mileage_classification_ext_id;

                  bfound := TRUE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_ret := db_const.db_fail;
               END;
            END IF;

            l_id := v_tfzglaufleistung_ssi.NEXT (l_id);
         END LOOP;
      END LOOP;

------------------------------------------------------------------------------------------------------------------------
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Deleting Entry of TFZGKMSTAND');

-- tfzgkmstand ---------------------------------------------------------------------------------------------------------
      FOR r_tfzgkmstand IN (SELECT *
                              FROM tfzgkmstand
                             WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag)
      LOOP
         l_id := v_tfzgkmstand_ssi.FIRST;

         WHILE (l_id IS NOT NULL)
         LOOP
            IF     r_tfzgkmstand.id_vertrag = v_tfzgkmstand_ssi (l_id).id_vertrag
               AND r_tfzgkmstand.id_fzgvertrag = v_tfzgkmstand_ssi (l_id).id_fzgvertrag
               AND r_tfzgkmstand.mileage_report_ext_id = v_tfzgkmstand_ssi (l_id).mileage_report_ext_id
               AND r_tfzgkmstand.contract_duration_ext_id = v_tfzgkmstand_ssi (l_id).contract_duration_ext_id
            THEN
               -- Record founded for update
               bfound := TRUE;
            ELSE
               bfound := FALSE;
            END IF;

            IF NOT bfound = TRUE
            -- Record not found in array. We must delete it.
            THEN
               BEGIN
                  DELETE FROM tfzgkmstand
                        WHERE id_vertrag = r_tfzgkmstand.id_vertrag
                          AND id_fzgvertrag = r_tfzgkmstand.id_fzgvertrag
                          AND mileage_report_ext_id = r_tfzgkmstand.mileage_report_ext_id;

                  bfound := TRUE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_ret := db_const.db_fail;
               END;
            END IF;

            l_id := v_tfzgkmstand_ssi.NEXT (l_id);
         END LOOP;
      END LOOP;

------------------------------------------------------------------------------------------------------------------------
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Deleting Entry of TFZGPREIS');

-- tfzgpreis -----------------------------------------------------------------------------------------------------------
      FOR r_tfzgpreis IN (SELECT *
                            FROM tfzgpreis
                           WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag)
      LOOP
         l_id := v_tfzgpreis_ssi.FIRST;

         WHILE (l_id IS NOT NULL)
         LOOP
            IF     r_tfzgpreis.id_vertrag = v_tfzgpreis_ssi (l_id).id_vertrag
               AND r_tfzgpreis.id_fzgvertrag = v_tfzgpreis_ssi (l_id).id_fzgvertrag
               AND r_tfzgpreis.price_range_ext_id = v_tfzgpreis_ssi (l_id).price_range_ext_id
               AND r_tfzgpreis.contract_duration_ext_id = v_tfzgpreis_ssi (l_id).contract_duration_ext_id
            THEN
               -- Record founded for update
               bfound := TRUE;
            ELSE
               bfound := FALSE;
            END IF;

            IF NOT bfound = TRUE
            -- Record not found in array. We must delete it.
            THEN
               BEGIN
                  DELETE FROM tfzgpreis
                        WHERE id_vertrag = r_tfzgpreis.id_vertrag
                          AND id_fzgvertrag = r_tfzgpreis.id_fzgvertrag
                          AND price_range_ext_id = r_tfzgpreis.price_range_ext_id;

                  bfound := TRUE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_ret := db_const.db_fail;
               END;
            END IF;

            l_id := v_tfzgpreis_ssi.NEXT (l_id);
         END LOOP;
      END LOOP;

------------------------------------------------------------------------------------------------------------------------
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Deleting Entry of TFZGV_CONTRACTS');

-- tfzgv_contracts- ----------------------------------------------------------------------------------------------------
      FOR r_tfzgv_ctr IN (SELECT *
                            FROM tfzgv_contracts
                           WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag)
      LOOP
         l_id := v_tfzgv_contracts_ssi.FIRST;

         WHILE (l_id IS NOT NULL)
         LOOP
            IF     r_tfzgv_ctr.id_vertrag = v_tfzgv_contracts_ssi (l_id).id_vertrag
               AND r_tfzgv_ctr.id_fzgvertrag = v_tfzgv_contracts_ssi (l_id).id_fzgvertrag
               AND r_tfzgv_ctr.contract_duration_ext_id = v_tfzgv_contracts_ssi (l_id).contract_duration_ext_id
            THEN
               -- Record founded for update
               bfound := TRUE;
            ELSE
               bfound := FALSE;
            END IF;

            IF NOT bfound = TRUE
            -- Record not found in array. We must delete it.
            THEN
               BEGIN
                  DELETE FROM tfzgv_contracts
                        WHERE id_vertrag = r_tfzgv_ctr.id_vertrag
                          AND id_fzgvertrag = r_tfzgv_ctr.id_fzgvertrag
                          AND contract_duration_ext_id = r_tfzgv_ctr.contract_duration_ext_id;

                  bfound := TRUE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_ret := db_const.db_fail;
               END;
            END IF;

            l_id := v_tfzgv_contracts_ssi.NEXT (l_id);
         END LOOP;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
------------------------------------------------------------------------------------------------------------------------
      RETURN db_const.db_success;
------------------------------------------------------------------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
         RETURN db_const.db_fail;
   END del_nonused_rec;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION whoami
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision: 1.7 $';
   END whoami;
------------------------------------------------------------------------------------------------------------------------
END pb_contract;
/