CREATE OR REPLACE PACKAGE BODY ssi.SSI_HEALTHCHECK
IS
 --
 -- MKSSTART
 --
 -- $CompanyInfo$
 --
 -- $Date: 2014/01/22 09:38:27MEZ $
 --
 -- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag  $
 --
 -- $Revision: 1.9 $
 --
 -- $Header: 5100_Code_Base/Healthcheck/ssi_healthcheck.plb 1.9 2014/01/22 09:38:27MEZ Berger, Franz (fraberg) CI_Changed  $
 --
 -- $Source: 5100_Code_Base/Healthcheck/ssi_healthcheck.plb $
 --
 -- $Log: 5100_Code_Base/Healthcheck/ssi_healthcheck.plb  $
 -- Revision 1.9 2014/01/22 09:38:27MEZ Berger, Franz (fraberg) 
 -- div. process functions: rename i_scope_only to i_checkoption with value SCOPE -> no VEGA INV/CN / else value ALL
 -- Revision 1.8 2014/01/10 17:33:56MEZ Berger, Franz (fraberg) 
 -- -createxml: no VEGA INV/CN within SCOPE
 -- - div. process functions: add parameter i_scope_only: if YES: no VEGA INV/CN
 -- Revision 1.7 2013/04/08 14:04:50MESZ Berger, Franz (fraberg) 
 -- createxml: add ACTIVE and ACTIVE_SCOPE selection / report checkoption in xmlfile
 -- Revision 1.6 2013/04/04 09:31:53MESZ Berger, Franz (fraberg) 
 -- check_database: add  Active and ActiveSCARF
 -- Revision 1.5 2013/01/15 14:17:08MEZ Berger, Franz (fraberg) 
 -- check_database / cursor OnlyContractCurSCOPE: change where not exists to where exists
 -- Revision 1.4 2012/12/28 17:02:30MEZ Berger, Franz (fraberg) 
 -- einbau neuer parameter SCOPE -> nur solche CO werden gecheckt, die nicht OutOfScope sind
 -- Revision 1.3 2012/11/28 17:00:46MEZ Berger, Franz (fraberg) 
 -- - cre new procedure cre_csv_for_html / ..._addon / ... _contr
 -- - cre new function  open_csv_file 
 -- - add parameter I_FILENAME and http xmlelement to function tblList / ...Addon / ...Contr
 -- - einigen code neu formatiert, damit er besser lesbar ist
 -- Revision 1.1 2012/09/28 15:49:01MESZ Kieninger, Tobias (tkienin)
 -- Initial revision
 -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
 -- Revision 1.15 2010/06/02 11:59:12MESZ Kieninger, Tobias (tkienin)
 -- correct typos
 -- Revision 1.14 2010/05/04 16:26:33CEST Musanovic, Adnana (amusano)
 -- comments
 -- Revision 1.13 2010/05/03 16:11:59CEST Musanovic, Adnana (amusano)
 -- A01
 -- Revision 1.11 2010/04/15 10:56:10CEST Musanovic, Adnana (amusano)
 -- bugfix
 -- Revision 1.9 2010/04/12 12:11:33CEST Musanovic, Adnana (amusano)
 -- format
 -- Revision 1.8 2010/04/09 16:03:19CEST Musanovic, Adnana (amusano)
 -- fertig
 -- Revision 1.7 2010/04/01 13:56:37CEST Musanovic, Adnana (amusano)
 -- fertig
 -- Revision 1.5 2010/03/12 17:24:05CET Musanovic, Adnana (amusano)
 -- XML Generierung
 -- Revision 1.4 2010/03/11 17:20:49CET Musanovic, Adnana (amusano)
 -- Zwischenstand
 -- Revision 1.3 2009/09/24 16:31:04CEST Kieninger, Tobias (tkienin)
 -- actual status
 -- Revision 1.1 2009/08/27 17:02:16CEST Kieninger, Tobias (tkienin)
 -- Initial revision
 -- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
 -- Revision 1.67 2009/06/22 18:08:49CEST Kieninger, Tobias (tkienin)
 -- Anpassung der Fehlermeldung
 -- Revision 1.64 2009/05/18 14:08:16CEST Peters, Jan (petejan)
 -- l_ret wurde überschrieben -> dadurch zusätzchlich db_const.db_success, obwohl vorher schon db_failed
 -- Revision 1.63 2009/04/17 09:44:14CEST Kieninger, Tobias (tkienin)
 -- Martins _NEW Tgas nachgebessert, die gefehlt haben.
 -- Revision 1.62 2009/04/15 10:19:29CEST Kieninger, Tobias (tkienin)
 -- Fehlercodes korrigiert und angepasst ersetzung der "99999" und "999999"
 -- Revision 1.61 2009/03/23 15:38:46CET Humer, Martin (mhumer8)
 -- new fields begin_mileage and end_mileage in tfzgpreis
 -- Revision 1.60 2009/03/18 15:59:09CET Humer, Martin (mhumer8)
 -- add field fzgv_wholesale_date in insert into statments(contract,contractextred,contracttransfer)
 -- Revision 1.59 2009/03/13 11:46:01CET Humer, Martin (mhumer8)
 -- Add Column ci_paid in Insert into tcustomer_invoice Statement
 -- Revision 1.58 2009/01/16 14:02:41CET Drey, Franz (fdrey77)
 -- 67355:1 Aufruf ssi_check_co.process mit Parameter i_process_object_typ
 -- Revision 1.57 2009/01/15 13:35:28CET Kieninger, Tobias (tkienin)
 -- kleinigkeiten
 -- Revision 1.56 2009/01/09 16:53:18CET Drey, Franz (fdrey77)
 -- Prüfung ob ein Mandant updaten darf nach dem Laden in die Stage verlegt
 -- Revision 1.55 2009/01/07 16:00:11CET Drey, Franz (fdrey77)
 -- MKS 66798 richtiges Objekt bei Customer Invoice abspeichern
 -- Revision 1.54 2008/12/19 16:02:11CET Kieninger, Tobias (tkienin)
 -- contract was delicered as customer type
 -- Revision 1.53 2008/12/18 18:51:01CET Drey, Franz (fdrey77)
 -- Für Initial Load geändert
 -- Revision 1.52 2008/12/18 10:35:59CET Drey, Franz (fdrey77)
 -- Test Update allowed für Extention/Reduction, Transfer und Customer Invoices
 -- Revision 1.51 2008/12/17 13:56:59CET Drey, Franz (fdrey77)
 -- ID_Object wird an ssi_customer.process zusätzlich übergeben.
 -- Revision 1.50 2008/12/10 13:13:42CET Kieninger, Tobias (tkienin)
 -- anreicherung adrassoz2 korrigiert
 -- Revision 1.49 2008/12/08 14:49:34CET Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.48 2008/12/08 14:17:39CET Kieninger, Tobias (tkienin)
 -- fehlerhafte Zuweisung des neuen vertrags in die falsche paketspalte
 -- Revision 1.47 2008/12/05 16:48:54CET Drey, Franz (fdrey77)
 -- Nur Debug Meldungen versetzt
 -- Revision 1.46 2008/12/04 11:43:50CET Drey, Franz (fdrey77)
 -- Abfrage, damit beim normalen Modus für Customer Invoics nicht mehr als ein Objekt per File kommt
 -- Revision 1.45 2008/12/03 15:52:51CET Drey, Franz (fdrey77)
 -- Messagenummern ergänzt
 -- Revision 1.44 2008/11/27 17:35:19CET Kieninger, Tobias (tkienin)
 -- Angepasst - Prüfung auf Attributwiedersprüche eingefügt, sysdate beim Liefern von Attributpaketen eingefügt
 -- Revision 1.43 2008/11/26 20:46:22CET Drey, Franz (fdrey77)
 -- process_co mit ssi_lock.clear_lock_and_stage_autonom erweitert
 -- Revision 1.42 2008/11/25 18:52:19CET Drey, Franz (fdrey77)
 -- Wenn Mandant vom XML-File in SIRIUS nicht gültig ist, File aus der Inbox in Rejected verschieben
 -- Revision 1.41 2008/11/25 17:55:21CET Drey, Franz (fdrey77)
 -- NVL(l_c.contract_value_total,0)
 -- und
 -- file_object = ssi_const.file_object.real_object eingefügt beim FOR l_o IN (SELECT id_object FROM  tssi_io_object .. eingefügt
 -- Revision 1.40 2008/11/21 15:16:49CET Kieninger, Tobias (tkienin)
 -- Fehlerhandling DUP_VAL_ON_INDEX eingeführt
 -- Revision 1.39 2008/11/20 16:22:56CET Peters, Jan (petejan)
 -- ssi_healthcheck.process bedient jetzt den process_manager
 -- Revision 1.38 2008/11/19 14:33:50CET Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.37 2008/11/18 20:06:51CET Drey, Franz (fdrey77)
 -- Transfer Vegaattribute berichtigt
 -- ExtRed  Endkilometer
 -- Revision 1.36 2008/11/17 16:46:44CET Kieninger, Tobias (tkienin)
 -- Meta package und Attribute package handling getrennt
 -- Revision 1.35 2008/11/14 09:04:49CET Humer, Martin (mhumer8)
 -- 14.11.2008 MKS 63630
 -- Revision 1.1 2008/11/11 17:33:44CET Kieninger, Tobias (tkienin)
 -- Initial revision
 -- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
 -- Revision 1.1 2008/11/11 15:15:40CET Drey, Franz (fdrey77)
 -- Initial revision
 -- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
 -- Revision 1.32 2008/11/11 15:11:31CET Drey, Franz (fdrey77)
 -- .
 -- Revision 1.31 2008/11/06 13:09:28CET Drey, Franz (fdrey77)
 -- Einträge Filestatus ergänzt
 -- Revision 1.30 2008/11/05 18:21:57CET Drey, Franz (fdrey77)
 -- Beim Aufruf ssi_contract.process für Extention/Transfer den Parameter i_store_data    => FALSE gesetzt
 -- Revision 1.29 2008/11/05 14:35:55CET Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.28 2008/11/03 17:06:10CET Peters, Jan (petejan)
 -- Iimplizites to_number beseitigt
 -- Revision 1.2 2008/11/03 16:04:00CET Peters, Jan (petejan)
 -- Member renamed from 5100 Code Base/Database/_IntegrationPatches/2.5.0/PATCH_250B01_62563_ssi.sql to 5100 Code Base/Database/_IntegrationPatches/2.5.0/6_PATCH_250B01_62563_ssi.sql in project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj.
 -- Revision 1.1 2008/11/03 16:04:00CET Peters, Jan (petejan)
 -- Initial revision
 -- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
 -- Revision 1.27 2008/11/03 15:57:07CET Peters, Jan (petejan)
 -- Fehlerhafte Filenamen werden jetzt abgefangen
 -- Revision 1.26 2008/10/29 18:00:28CET Kieninger, Tobias (tkienin)
 -- show eooros removed
 -- Revision 1.25 2008/10/29 17:33:48CET Drey, Franz (fdrey77)
 -- Meldungen ergänzt und globales Error handling eingeführt.
 -- In Process Parameter i_trace_target Varchar in Varchar2
 -- Revision 1.24 2008/10/28 18:44:13CET Drey, Franz (fdrey77)
 -- .
 -- Revision 1.23 2008/10/28 15:36:40CET Drey, Franz (fdrey77)
 -- Die auskommentierten Spalten fzgv_force_final_invoice und fzgv_contract_value wurden wieder auch für Transfer und Extention/Reduction aktiviert
 -- Revision 1.22 2008/10/28 14:18:12CET Drey, Franz (fdrey77)
 -- Die auskommentierten Spalten fzgv_force_final_invoice und fzgv_contract_value wurden wieder aktiviert
 -- Revision 1.21 2008/10/28 13:24:18CET Kieninger, Tobias (tkienin)
 -- no_clear flag globalisiert
 -- Revision 1.20 2008/10/24 14:49:48CEST Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.18 2008/10/16 15:44:47CEST Kieninger, Tobias (tkienin)
 -- Member moved from 5100 Code Base/Database/_IntegrationCandidates/Release 2.5.0/ssi/Logic/ssi_healthcheck.plb in project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj to 5100 Code Base/Database/Source/SiriusServiceInterface/SSI/Logic/ssi_healthcheck.plb in project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj.
 -- Revision 1.17 2008/10/16 15:44:47CEST Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.16 2008/10/15 15:57:07CEST Kieninger, Tobias (tkienin)
 -- .
 -- Revision 1.14 2008/10/14 19:27:18CEST Drey, Franz (fdrey77)
 -- Kommentare eingebaut
 --
 -- MKSEND
 --
 -- 50799:1  07.10.2008 Franz Drey Übernahme von CONTRACT Transfer in Stage
 -- 50794:1  29.09.2008 Franz Drey Übernahme von CONTRACT Extention/Reduction in Stage
 -- 50922:1  26.09.2008 Franz Drey Übernahme von Customer Invoice in Stage
 -- 130325:1 10.01.2014 FraBe      createxml: no VEGA INV/CN within SCOPE
 --                                div. process functions: add parameter i_scope_only: if YES: no VEGA INV/CN
 -- 130325:1 21.01.2014 FraBe      rename i_scope_only to i_checkoption with value SCOPE -> no VEGA INV/CN / else value ALL
 -------------------------------------------------------------------------------
 lgc_modul       CONSTANT VARCHAR2 ( 100 ) DEFAULT 'ssi_healthcheck.';
 lgc_error_file      CONSTANT VARCHAR2 ( 100 ) DEFAULT 'GLOBAL_ERROR';
 lg_debug        VARCHAR2 ( 3 ) DEFAULT 'NO';

 procedure cre_csv_for_html       ( I_filename  varchar2 );
 procedure cre_csv_for_html_addon ( I_filename  varchar2 );
 procedure cre_csv_for_html_contr ( I_filename  varchar2 );
 function  open_csv_file          ( I_filename  varchar2 ) return          UTL_FILE.file_type;

 highlander       EXCEPTION;
 PRAGMA EXCEPTION_INIT ( highlander, -20999 );
    i_journal_id number;
-- CURSOR c_file
-- IS
--  SELECT ROWID row_id, t.*
--  FROM tssi_dirlist t
--  ORDER BY DECODE ( ssi_object,  'CUSTOMER', 1,  'CONTRACT', 2,  'CONEXT', 3,  'CONTRANS', 4,  'CUSTINV', 5 ), running_date, running_number;



   FUNCTION f_get_create_id_objects (
      i_id_io_file   IN   tssi_io_object.id_io_file%TYPE
     ,i_xml_object   IN   tssi_io_object.xml_object%TYPE
   )
      RETURN PLS_INTEGER
   IS
--  PURPOSE
--    Creates a new ID_object for a new object and
--    stores this id_object in the table tssi_io_object
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeührten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_seq_id_object   PLS_INTEGER;
      lc_sub_modul      VARCHAR2 (100) DEFAULT 'F_GET_CREATE_ID_OBJECTS';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      SELECT seq_ssi_id_object.NEXTVAL
        INTO l_seq_id_object
        FROM DUAL;

      INSERT INTO tssi_io_object
                  (id_object
                  ,id_io_file
                  ,xml_object
                  )
           VALUES (l_seq_id_object
                  ,i_id_io_file
                  ,i_xml_object
                  );

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_seq_id_object;
   END f_get_create_id_objects;

-------------------------------------------------------------------------------
 -------------------------------------------------------------------------------
   FUNCTION delete_stage
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--    Deletes all records in the stage tables
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'DELETE_STAGE';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

           --
      -- Customer tables
      --
      DELETE      tcustomer;

      DELETE      tadrassoz;

      DELETE      tadress;

      DELETE      tzip;

      DELETE      tname;

      DELETE      tcust_banking;

  --
  -- Contract tables
  --
  -- Bei Performance Problem in Collection selectieren
  -- und mit IN TABLE(SELECT * FROM Collection ) die Where Bedingung ergänzen
  --
--  SELECT id_object
--  BULK COLLECT INTO
--  FROM   tssi_lock_ert;
      DELETE      tfzgvertrag v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tfzgv_contracts v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tfzgpreis v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tfzglaufleistung v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tfzgkmstand v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tic_co_pack_ass v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      DELETE      tvega_i55_co v
            WHERE NOT EXISTS (SELECT NULL
                                FROM tssi_lock_ert l
                               WHERE l.id_object = v.id_object);

      --
      -- Customer Invoices
      --
      DELETE      tcustomer_invoice;

      DELETE      tcustomer_invoice_pos;

      COMMIT;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END delete_stage;

-------------------------------------------------------------------------------
   FUNCTION get_filename (
      o_filename     OUT      tssi_io_file.io_file_name%TYPE
     ,o_id_io_file   OUT      tssi_io_file.id_io_file%TYPE
     ,i_id_object    IN       tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--    Search the filename and file_id for a specific id_object
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The file was found
--      db_const.db_fail    : No file was found
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_res          BOOLEAN;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'GET_FILENAME';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      SELECT id_io_file
            ,io_file_name
        INTO o_id_io_file
            ,o_filename
        FROM tssi_io_file f
       WHERE EXISTS (SELECT NULL
                       FROM tssi_io_object o
                      WHERE f.id_io_file = o.id_io_file AND o.id_object = i_id_object);

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
--EXCEPTION
--  -- ToDo
--  WHEN NO_DATA_FOUND THEN
   END get_filename;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
   FUNCTION contracts_to_stage (
      i_id_io_file      IN   tssi_io_object.id_io_file%TYPE
     ,i_guid_contract        tfzgvertrag.guid_contract%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret             db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_res             BOOLEAN;
      l_seq_id_object   PLS_INTEGER;
      lc_sub_modul      VARCHAR2 (100)                     DEFAULT 'CONTRACTS_TO_STAGE';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- reads the data out of the XMLDB into the stage
      --
      FOR l_v IN (SELECT 0 AS id_object
                        ,a.*
                        ,NVL (m.ssim_mandant_id, 'SIRIUS') unique_sender_id
                    FROM snt.tfzgvertrag a, snt.tssi_mandant m
                   WHERE guid_contract = i_guid_contract AND a.guid_ssim = m.guid_ssim(+))
      LOOP
         --
         -- get and create the new id_objects for this object
         --
         l_seq_id_object :=
                  f_get_create_id_objects (i_id_io_file      => i_id_io_file
                                          ,i_xml_object      => ssi_const.xml_object.contract);
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_Object alt: ' || l_v.id_object);
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_Object neu: ' || l_seq_id_object);

         INSERT INTO tfzgvertrag
                     (id_object
                     ,unique_sender_id
                     ,id_vertrag
                     ,id_fzgvertrag
                     ,transaction_id
                     ,id_garage
                     ,id_fzgtyp
                     ,id_cos
                     ,fzgv_aaol_desc
                     ,fzgv_signature_date
                     ,fzgv_kfzkennzeichen
                     ,fzgv_no_customer
                     ,id_manufacture
                     ,fzgv_fgstnr
                     ,fzgv_chassis_validcode
                     ,fzgv_motornr
                     ,fzgv_motortyp
                     ,fzgv_erstzulassung
                     ,fzgv_gebraucht
                     ,fzgv_bearbeiter
                     ,fzgv_bearbeiter_tech
                     ,fzgv_bearbeiter_kauf
                     ,fzgv_memo
                     ,id_garage_serv
                     ,fzgv_checked
                     ,fzgv_checked_by
                     ,fzgv_commission_nr
                     ,id_country
                     ,guid_servicecard
                     ,fzgv_scard_count
                     ,fzgv_cause_of_retire
                     ,fzgv_i55_veh_spec_text
                     ,fzgv_i55_cust_spec_text
                     ,id_vertrag_parent
                     ,id_fzgvertrag_parent
                     ,fzgv_force_final_invoice
                     ,fzgv_contract_value
                     ,fzgv_fixed_labour_rate
                     ,fzgv_handle_nominated_dealer
                     ,fzgv_final_customer
                     ,fzgv_wholesale_date
                     ,fzgv_created
                     ,fzgv_creator
                     )
              VALUES (l_seq_id_object                                                                   -- l_c.id_object
                     ,l_v.unique_sender_id
                     ,l_v.id_vertrag
                     ,l_v.id_fzgvertrag
                     , NVL (l_v.transaction_id, 0) + 1
                     ,l_v.id_garage
                     ,l_v.id_fzgtyp
                     ,l_v.id_cos
                     ,l_v.fzgv_aaol_desc
                     ,l_v.fzgv_signature_date
                     ,l_v.fzgv_kfzkennzeichen
                     ,l_v.fzgv_no_customer
                     ,l_v.id_manufacture
                     ,l_v.fzgv_fgstnr
                     ,l_v.fzgv_chassis_validcode
                     ,l_v.fzgv_motornr
                     ,l_v.fzgv_motortyp
                     ,l_v.fzgv_erstzulassung
                     ,l_v.fzgv_gebraucht
                     ,l_v.fzgv_bearbeiter
                     ,l_v.fzgv_bearbeiter_tech
                     ,l_v.fzgv_bearbeiter_kauf
                     ,l_v.fzgv_memo
                     ,l_v.id_garage_serv
                     ,l_v.fzgv_checked
                     ,l_v.fzgv_checked_by
                     ,l_v.fzgv_commission_nr
                     ,l_v.id_country
                     ,l_v.guid_servicecard
                     ,l_v.fzgv_scard_count
                     ,l_v.fzgv_cause_of_retire
                     ,l_v.fzgv_i55_veh_spec_text
                     ,l_v.fzgv_i55_cust_spec_text
                     ,l_v.id_vertrag_parent
                     ,l_v.id_fzgvertrag_parent
                     ,l_v.fzgv_force_final_invoice
                     ,l_v.fzgv_contract_value
                     ,l_v.fzgv_fixed_labour_rate
                     ,l_v.fzgv_handle_nominated_dealer
                     ,l_v.fzgv_final_customer
                     ,l_v.fzgv_wholesale_date
                     ,l_v.fzgv_created
                     ,l_v.fzgv_creator
                     );

         FOR l_c IN (SELECT tc.*
                           ,tk.fzgkm_km real_end_mileage
                           ,tk.fzgkm_datum real_end_date
                       FROM snt.tfzgv_contracts tc, snt.tfzgkmstand tk
                      WHERE tc.id_vertrag = l_v.id_vertrag
                        AND tc.id_fzgvertrag = l_v.id_fzgvertrag
                        AND tc.id_seq_fzgkmstand_end = tk.id_seq_fzgkmstand(+)
                        AND tc.id_seq_fzgvc = tk.id_seq_fzgvc(+))
         LOOP
            INSERT INTO tfzgv_contracts
                        (contract_duration_ext_id
                        ,id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,id_cov
                        ,id_paym
                        ,id_einsatzart
                        ,ID_SEQ_FZGKMSTAND_BEGIN
                        ,ID_SEQ_FZGKMSTAND_END
                        ,guid_indv
                        ,fzgvc_beginn
                        ,fzgvc_ende
                        ,real_end_date
                        ,real_end_mileage
                        ,fzgvc_extred_confdate
                        ,fzgvc_beginn_km
                        ,fzgvc_ende_km
                        ,fzgvc_central_account
                        ,fzgvc_idx_nextdate
                        ,fzgvc_service_card
                        ,fzgvc_memo
                        ,guid_payment
                        ,guid_payment_mode
                        ,fzgvc_factoring
                        ,fzgvc_creditnote_text
                        ,fzgvc_invoice_text
                        ,fzgvc_invoice_text_once
                        ,id_customer
                        ,fzgvc_runpower_balancing
                        ,fzgvc_invoice_consolidation
                        ,fzgvc_runpower_balancingmethod
                        ,fzgvc_runpower_tolerance_perc
                        ,fzgvc_runpower_tolerance_day
                        ,fzgvc_rpb_max_month
                        ,guid_branch
                        ,id_seq_fzgvc
                        )
                 VALUES (l_c.contract_duration_ext_id
                        ,l_seq_id_object                                                                -- l_v.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.id_cov
                        ,l_c.id_paym
                        ,l_c.id_einsatzart
                        ,l_c.ID_SEQ_FZGKMSTAND_BEGIN
                        ,l_c.ID_SEQ_FZGKMSTAND_END
                        ,l_c.guid_indv
                        ,l_c.fzgvc_beginn
                        ,l_c.fzgvc_ende
                        ,l_c.real_end_date
                        ,l_c.real_end_mileage
                        ,l_c.fzgvc_extred_confdate
                        ,l_c.fzgvc_beginn_km
                        ,l_c.fzgvc_ende_km
                        ,l_c.fzgvc_central_account
                        ,l_c.fzgvc_idx_nextdate
                        ,l_c.fzgvc_service_card
                        ,l_c.fzgvc_memo
                        ,l_c.guid_payment
                        ,l_c.guid_payment_mode
                        ,l_c.fzgvc_factoring
                        ,l_c.fzgvc_creditnote_text
                        ,l_c.fzgvc_invoice_text
                        ,l_c.fzgvc_invoice_text_once
                        ,l_c.id_customer
                        ,l_c.fzgvc_runpower_balancing
                        ,l_c.fzgvc_invoice_consolidation
                        ,l_c.fzgvc_runpower_balancingmethod
                        ,l_c.fzgvc_runpower_tolerance_perc
                        ,l_c.fzgvc_runpower_tolerance_day
                        ,l_c.fzgvc_rpb_max_month
                        ,l_c.guid_branch
                        ,l_c.id_seq_fzgvc
                        );
         END LOOP;

         FOR l_c IN (SELECT *
                       FROM snt.tfzgkmstand tk
                      WHERE tk.id_vertrag = l_v.id_vertrag AND tk.id_fzgvertrag = l_v.id_fzgvertrag)
         LOOP
            INSERT INTO tfzgkmstand
                        (mileage_report_ext_id
                        ,id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,fzgkm_km
                        ,fzgkm_datum
                        ,contract_duration_ext_id
                        ,id_seq_fzgkmstand
                        ,id_seq_fzgvc
                        )
                 VALUES (l_c.mileage_report_ext_id
                        ,l_seq_id_object                                                                -- l_c.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.fzgkm_km
                        ,l_c.fzgkm_datum
                        ,l_c.contract_duration_ext_id
                        ,l_c.id_seq_fzgkmstand
                        ,l_c.id_seq_fzgvc
                        );
         END LOOP;

         FOR l_c IN (SELECT *
                       FROM snt.tfzglaufleistung tl
                      WHERE tl.id_vertrag = l_v.id_vertrag AND tl.id_fzgvertrag = l_v.id_fzgvertrag)
         LOOP
            INSERT INTO tfzglaufleistung
                        (mileage_classification_ext_id
                        ,id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,fzgll_laufleistung
                        ,fzgll_von
                        ,fzgll_bis
                        ,id_lleinheit
                        ,fzgll_dauer_monate
                        ,fzgll_free_mileage
                        ,contract_duration_ext_id
                        ,id_seq_fzglaufleistung
                        ,id_seq_fzgvc
                        )
                 VALUES (l_c.mileage_classification_ext_id
                        ,l_seq_id_object                                                                -- l_c.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.fzgll_laufleistung
                        ,l_c.fzgll_von
                        ,l_c.fzgll_bis
                        ,l_c.id_lleinheit
                        ,l_c.fzgll_dauer_monate
                        ,l_c.fzgll_free_mileage
                        ,l_c.contract_duration_ext_id
                        ,l_c.id_seq_fzglaufleistung
                        ,l_c.id_seq_fzgvc
                        );
         END LOOP;

         FOR l_c IN (SELECT *
                       FROM snt.tfzgpreis tp
                      WHERE tp.id_vertrag = l_v.id_vertrag AND tp.id_fzgvertrag = l_v.id_fzgvertrag)
         LOOP
            INSERT INTO tfzgpreis
                        (price_range_ext_id
                        ,id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,id_prv
                        ,fzgpr_preis_grkm
                        ,fzgpr_von
                        ,fzgpr_bis
                        ,fzgpr_preis_monatp
                        ,fzgpr_preis_fix
                        ,fzgpr_add_mileage
                        ,fzgpr_less_mileage
                        ,fzgpr_surcharge
                        ,fzgpr_adminfee
                        ,fzgpr_admincharge
                        ,fzgpr_mlp
                        ,fzgpr_subbu
                        ,fzgpr_discas
                        ,fzgpr_begin_mileage
                        ,fzgpr_end_mileage
                        ,contract_duration_ext_id
                        ,id_seq_fzgpreis
                        ,id_seq_fzgvc
                        )
                 VALUES (l_c.price_range_ext_id
                        ,l_seq_id_object                                                                -- l_c.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.id_prv
                        ,l_c.fzgpr_preis_grkm
                        ,l_c.fzgpr_von
                        ,l_c.fzgpr_bis
                        ,l_c.fzgpr_preis_monatp
                        ,l_c.fzgpr_preis_fix
                        ,l_c.fzgpr_add_mileage
                        ,l_c.fzgpr_less_mileage
                        ,l_c.fzgpr_surcharge
                        ,l_c.fzgpr_adminfee
                        ,l_c.fzgpr_admincharge
                        ,l_c.fzgpr_mlp
                        ,l_c.fzgpr_subbu
                        ,l_c.fzgpr_discas
                        ,l_c.fzgpr_begin_mileage
                        ,l_c.fzgpr_end_mileage
                        ,l_c.contract_duration_ext_id
                        ,l_c.id_seq_fzgpreis
                        ,l_c.id_seq_fzgvc
                        );
         END LOOP;

         FOR l_c IN (SELECT ti.*
                           ,tv.id_vertrag
                           ,tv.id_fzgvertrag
                       FROM snt.tic_co_pack_ass ti, snt.tfzgvertrag tv
                      WHERE ti.guid_contract = i_guid_contract AND ti.guid_contract = tv.guid_contract)
         LOOP
            INSERT INTO tic_co_pack_ass
                        (id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,guid_contract
                        ,guid_package
                        ,guid_vi55a
                        )
                 VALUES (l_seq_id_object                                                                -- l_c.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.guid_contract
                        ,l_c.guid_package
                        ,l_c.guid_vi55a
                        );
         END LOOP;

         FOR l_c IN (SELECT tve.*
                           ,tv.id_vertrag
                           ,tv.id_fzgvertrag
                       FROM snt.tvega_i55_co tve, snt.tfzgvertrag tv
                      WHERE tve.guid_contract = i_guid_contract AND tve.guid_contract = tv.guid_contract)
         LOOP
            INSERT INTO tvega_i55_co
                        (guid_i55_co
                        ,id_object
                        ,id_vertrag
                        ,id_fzgvertrag
                        ,guid_contract
                        ,guid_vi55a
                        ,guid_vi55av
                        )
                 VALUES (SYS_GUID ()
                        ,l_seq_id_object                                                                -- l_c.id_object
                        ,l_c.id_vertrag
                        ,l_c.id_fzgvertrag
                        ,l_c.guid_contract
                        ,l_c.guid_vi55a
                        ,l_c.guid_vi55av
                        );
         END LOOP;
      END LOOP;                                                                                               -- FOR l_c

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         l_ret := db_const.db_fail;
         RETURN l_ret;
   END contracts_to_stage;

-------------------------------------------------------------------------------
/*   FUNCTION xmldb_to_stage (i_id_io_file IN tssi_io_object.id_io_file%TYPE
                           ,i_ssi_object IN lov_xml_object.xml_object_name%TYPE)
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--    Transfer the data from XMLDB to the stage
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_res          BOOLEAN;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'XMLDB_TO_STAGE';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      --
      -- Transfer the data from XMLDB to the stage
      --
      -- eventuell pro Objekt, das gerade verarbeitet wird noch differenzieren
      --
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'xmldb_to_stage: ' || i_ssi_object);

      CASE i_ssi_object
         WHEN ssi_const.customer_obj
         THEN
            l_ret := customers_to_stage(i_id_io_file => i_id_io_file);
         WHEN ssi_const.contract_obj
         THEN
            l_ret := contracts_to_stage(i_id_io_file => i_id_io_file);
         WHEN ssi_const.contract_extred_obj
         THEN
            l_ret := contracts_er_to_stage;
         WHEN ssi_const.contract_trans_obj
         THEN
            l_ret := contract_transfer_to_stage;
         WHEN ssi_const.customer_iv_obj
         THEN
            l_ret := custinv_to_stage(i_id_io_file => i_id_io_file);
         ELSE
            NULL;
      -- ToDo Error
      END CASE;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END xmldb_to_stage;
*/


function tblListContr ( I_FILENAME varchar2 )
    RETURN XMLTYPE
IS
    l_xml                                 XMLTYPE;
    lc_sub_modul                        VARCHAR2 ( 100 ) DEFAULT 'BuildErrorlistXMLContract';
    l_lasterrortext                    ssi.tdf_errorlist.text%TYPE;
    l_errorcounter                     NUMBER;
    l_val_cat                           varchar2(200);
    l_val_code                          varchar2(200);


CURSOR ERROR_LIST_SUM_CONTR
IS

SELECT MESSAGE_CLASS_NAME, COUNT ( DISTINCT CONTRACT ) SUMME
FROM V_HEALTHCHECK
GROUP BY MESSAGE_CLASS_NAME
ORDER BY MESSAGE_CLASS_NAME ASC;


BEGIN
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

    SELECT XMLELEMENT (
           "TABLE"
           , XMLATTRIBUTES ( 'border-collapse:collapse;' AS "style"
                           , '2'                         AS "border"
                           , '25%'                       AS "width"
                           , '5'                         AS "cellpadding" )
                           , XMLELEMENT ( "TR" , XMLELEMENT ( "TD", XMLATTRIBUTES ( 'width:15%;border-collapse:collapse;font-size:14pt;font-weight:bold;text-align:left;' AS "style", '2' AS "border" ), 'Affected contracts' )
                                               , XMLELEMENT ( "TD", XMLATTRIBUTES ( 'width:*;border-collapse:collapse;font-size:14pt;font-weight:bold;'                   AS "style", '2' AS "border" ), 'Message Class' )
                                        )
                     ).EXTRACT ( '.' )
              AS XML
    INTO L_XML
    FROM DUAL;

    FOR J IN ERROR_LIST_SUM_CONTR
    LOOP

      SELECT APPENDCHILDXML (
              L_XML
              , '/TABLE'
              , XMLELEMENT ( "TR", XMLELEMENT ( "TD", XMLATTRIBUTES ( 'width:15%;border-collapse:collapse;font-size:11pt;font-weight:bold;text-align:right;' AS "style", '2' AS "border" ), J.SUMME )
                                 , XMLELEMENT ( "TD", XMLATTRIBUTES ( 'width:*;border-collapse:collapse;' AS "style", '2' AS "border" )
                                                    , XMLELEMENT ( "a", xmlattributes ( I_FILENAME || '_' || translate ( j.MESSAGE_CLASS_NAME, ' \/:*?"<>|', ' ' ) || '.csv' AS "href" ), J.MESSAGE_CLASS_NAME )
                                              )
                           ))
      INTO L_XML
      FROM DUAL;

    END LOOP;

qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** END of Function *****' );
    RETURN l_xml;

END tblListContr;

FUNCTION tbllistaddon ( I_FILENAME varchar2 )
 RETURN XMLTYPE IS
 l_xml     XMLTYPE;
 lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'BuildErrorlistXML';
 l_lasterrortext ssi.tdf_errorlist.text%TYPE;
 l_errorcounter  NUMBER;
 l_val_cat   VARCHAR2 ( 200 );
 l_val_code   VARCHAR2 ( 200 );

 CURSOR error_list_addon IS
    SELECT COUNT ( MSG_CODE_NAME ) sumcount
     , MESSAGE_CLASS_NAME
     , MSG_CODE_NAME
     --, msg_text
    FROM v_healthcheck
   WHERE SUBSTR ( msg_code, 1, 1 ) = 6
  GROUP BY message_class_name, msg_code_name
  ORDER BY message_class_name, msg_code_name;
BEGIN
 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

 SELECT XMLELEMENT (
         "TABLE"
       , xmlattributes (
             'border-collapse:collapse;' AS "style"
             , '2' AS "border"
             , '50%' AS "width"
             , '5' AS "cellpadding"
              )
       , XMLELEMENT (
            "TR"
            , XMLELEMENT (
                 "TD"
                 , xmlattributes (
                       'width:7%;border-collapse:collapse;font-size:14pt;font-weight:bold;text-align:center;' AS "style"
                     , '2' AS "border" )
                 , 'Error Count' )
            , XMLELEMENT (
                 "TD"
                 , xmlattributes (
                       'width:15%;border-collapse:collapse;font-size:14pt;font-weight:bold;' AS "style"
                     , '2' AS "border"
                      )
                 , 'Message Class' )
            , XMLELEMENT (
                 "TD"
                 , xmlattributes (
                       'width:*%;border-collapse:collapse;font-size:14pt;font-weight:bold;' AS "style"
                     , '2' AS "border"
                      )
                 , 'Error Message' ) ) ).EXTRACT ( '.' )
     AS xml
   INTO l_xml
   FROM DUAL;

 FOR i IN error_list_addon --l_val:= i.msg_categorie_name;
 LOOP
  --if i.msg_categorie_name <> l_val_cat or l_val_cat is null then
  SELECT APPENDCHILDXML (
          l_xml
          , '/TABLE'
          , XMLELEMENT ( "TR", XMLELEMENT ( "TD", xmlattributes ( 'width:7%;border-collapse:collapse;font-size:11pt;font-weight:bold;text-align:right;' AS "style", '2' AS "border" ), i.SUMCOUNT )
                             , XMLELEMENT ( "TD", xmlattributes ( 'width:15%;border-collapse:collapse;' AS "style", '2' AS "border" ), i.MESSAGE_CLASS_NAME )
                             , XMLELEMENT ( "TD", xmlattributes ( 'width:*%;border-collapse:collapse;' AS "style", '2' AS "border" )
                                                , XMLELEMENT ( "a", xmlattributes ( I_FILENAME || '_' || translate ( i.MSG_CODE_NAME, ' \/:*?"<>|', ' ' ) || '.csv' AS "href" ), i.MSG_CODE_NAME )
                                          )
                       ))
    INTO l_xml
    FROM DUAL;
 END LOOP;


 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** END of Function *****' );
 RETURN l_xml;
END tbllistaddon;
FUNCTION tblList ( I_FILENAME varchar2 )
 RETURN XMLTYPE
IS
 l_xml         XMLTYPE;
 lc_sub_modul      VARCHAR2 ( 100 ) DEFAULT 'BuildErrorlistXML';
 l_lasterrortext     ssi.tdf_errorlist.text%TYPE;
 l_errorcounter      NUMBER;
    l_val_cat                           varchar2(200);
    l_val_code                          varchar2(200);




CURSOR ERROR_LIST_SUM_CUR
IS

SELECT COUNT ( MSG_TEXT ) SUMCOUNT
   , MESSAGE_CLASS_NAME
   , MSG_CODE_NAME
   , MSG_TEXT
FROM V_HEALTHCHECK
WHERE SUBSTR(MSG_CODE ,1,1) <> 6
GROUP BY MESSAGE_CLASS_NAME, MSG_CODE_NAME, MSG_TEXT
ORDER BY MESSAGE_CLASS_NAME, MSG_CODE_NAME, MSG_TEXT;



BEGIN
 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

SELECT XMLELEMENT (
        "TABLE" , xmlattributes ( 'border-collapse:collapse;' AS "style", '2' AS "border", '100%' as "width", '5' as "cellpadding" )
      , XMLELEMENT ( "TR", XMLELEMENT ( "TD", xmlattributes ( 'width:7%;border-collapse:collapse;font-size:14pt;font-weight:bold;text-align:center;' AS "style", '2' AS "border" ), 'Error Count' )
                         , XMLELEMENT ( "TD", xmlattributes ( 'width:15%;border-collapse:collapse;font-size:14pt;font-weight:bold;' AS "style", '2' AS "border" ), 'Message Class' )
                         , XMLELEMENT ( "TD", xmlattributes ( 'width:25%;border-collapse:collapse;font-size:14pt;font-weight:bold;' AS "style", '2' AS "border" ), 'Error Message' )
                       --, XMLELEMENT ( "TD", xmlattributes ( 'width:7%;border:1 solid;font-size:14pt;font-weight:bold;color:#5f5f5f;' AS "style", '1' AS "border" ), 'Contract' )
                         , XMLELEMENT ( "TD", xmlattributes ( 'width:*;border-collapse:collapse;font-size:14pt;font-weight:bold;' AS "style", '2' AS "border" ), 'Error description' )
                  )
       ).EXTRACT ( '.' )
    AS xml
INTO l_xml
FROM DUAL;




 FOR i in ERROR_LIST_SUM_CUR
--l_val:= i.msg_categorie_name;
 LOOP

    --if i.msg_categorie_name <> l_val_cat or l_val_cat is null then
    SELECT APPENDCHILDXML (
            l_xml
            , '/TABLE'
            , XMLELEMENT ( "TR", XMLELEMENT ( "TD", xmlattributes ( 'width:7%;border-collapse:collapse;font-size:11pt;font-weight:bold;text-align:right;' AS "style", '2' AS "border" ), i.sumcount )
                               , XMLELEMENT ( "TD", xmlattributes ( 'width:15%;border-collapse:collapse;' AS "style", '2' AS "border" ), i.MESSAGE_CLASS_NAME )
                               , XMLELEMENT ( "TD", xmlattributes ( 'width:25%;border-collapse:collapse;' AS "style", '2' AS "border" ), i.MSG_CODE_NAME )
                             --, XMLELEMENT ( "TD", xmlattributes ( 'width:7%;border:1 solid;' AS "style", '1' AS "border" ), '' )
                               , XMLELEMENT ( "TD", xmlattributes ( 'width:*;border-collapse:collapse;' AS "style", '2' AS "border" )
                                                  , XMLELEMENT ( "a", xmlattributes ( I_FILENAME || '_' || translate ( i.MSG_TEXT, chr(10) || '\/:*?"<>|', ' ' ) || '.csv' AS "href" ), i.MSG_TEXT )
                                            )
                         ))
      INTO l_xml
      FROM DUAL;

 END loop;




 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** END of Function *****' );
 RETURN l_xml;

END tblList;

-- FraBe   05.04.2013   MKS-121951:3 add ACTIVE and ACTIVE_SCOPE selection / report checkoption in xmlfile
-- FraBe   10.01.2014   MKS-130325:1 no VEGA INV/CN within SCOPE
FUNCTION createxml ( i_check_begin   in date
                   , i_addon            varchar2 Default 'YES'
                   , i_checkoption      varchar2 Default 'ALL' )
      RETURN NUMBER
   IS
      l_xml                         XMLTYPE;
      lc_sub_modul                  VARCHAR2 (100) DEFAULT 'CreateXML';
      l_countryname                 varchar2 (100) DEFAULT 'REF';
      l_databasename                database_properties.property_value%TYPE;
      l_contractsum                 number DEFAULT '0';
      l_invoicesum                  number DEFAULT '0';
      l_custinvsum                  number DEFAULT '0';
      l_check_ende                  date;
      l_days                        NUMBER;
      l_hours                       NUMBER;
      l_minutes                     NUMBER;
      l_seconds                     NUMBER;
      v_diff                        NUMBER;
      l_filename                    varchar2 ( 200 char );

   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      L_FILENAME := 'Healthcheck_Summary_' || to_char ( i_check_begin, 'YYYYMMDD_hh24mi' );

      cre_csv_for_html ( i_filename => l_filename );
      if   i_addon = 'YES'
      then cre_csv_for_html_addon ( i_filename => l_filename );
      end  if;
      cre_csv_for_html_contr ( i_filename => l_filename );


      SELECT property_value
        INTO l_databasename
        FROM database_properties
       WHERE property_name = 'GLOBAL_DB_NAME';

       SELECT value
        INTO l_countryname
        FROM snt.tglobal_settings
       WHERE entry = 'MPCName Long';
      -- build global HTML   with summary

     select count ( distinct fzgv.GUID_CONTRACT )
       into l_contractsum
       from snt.TDFCONTR_STATE     cos
          , snt.TDFCONTR_VARIANT   cov
          , snt.TFZGV_CONTRACTS    fzgvc
          , snt.TFZGVERTRAG        fzgv
      where fzgv.ID_COS          = cos.ID_COS
        and fzgv.ID_VERTRAG      = fzgvc.ID_VERTRAG
        and fzgv.ID_FZGVERTRAG   = fzgvc.ID_FZGVERTRAG
        and cov.ID_COV           = fzgvc.ID_COV
        and (  nvl ( i_checkoption, 'ALL' )  = 'ALL'
          or ( nvl ( i_checkoption, 'ALL' )  = 'OPEN'         and fzgvc.ID_SEQ_FZGKMSTAND_END is null )
          or ( nvl ( i_checkoption, 'ALL' )  = 'SCOPE'        and cov.COV_CAPTION not like 'MIG_OOS%' )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE'       and cos.COS_ACTIVE = 1 )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE_SCARF' and cos.COS_ACTIVE = 1 and cos.COS_STAT_CODE in ( '00', '01', '02' )));

     select count ( distinct fzgre.ID_SEQ_FZGRECHNUNG )
       into l_invoicesum
       from snt.TFZGRECHNUNG       fzgre
          , snt.TDFCONTR_STATE     cos
          , snt.TDFCONTR_VARIANT   cov
          , snt.TFZGV_CONTRACTS    fzgvc
          , snt.TFZGVERTRAG        fzgv
      where fzgv.ID_COS          = cos.ID_COS
        and fzgv.ID_VERTRAG      = fzgvc.ID_VERTRAG
        and fzgv.ID_FZGVERTRAG   = fzgvc.ID_FZGVERTRAG
        and cov.ID_COV           = fzgvc.ID_COV
        and fzgre.ID_SEQ_FZGVC   = fzgvc.ID_SEQ_FZGVC
        and fzgre.ID_VERTRAG     = fzgvc.ID_VERTRAG
        and fzgre.ID_FZGVERTRAG  = fzgvc.ID_FZGVERTRAG
        and (  nvl ( i_checkoption, 'ALL' )  = 'ALL'
          or ( nvl ( i_checkoption, 'ALL' )  = 'OPEN'         and fzgvc.ID_SEQ_FZGKMSTAND_END is null )
          or ( nvl ( i_checkoption, 'ALL' )  = 'SCOPE'        and cov.COV_CAPTION not like 'MIG_OOS%' and fzgre.ID_IMP_TYPE not in ( 6, 10 ) /* MKS-130325:1 no VEGA INV/CN within SCOPE */ )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE'       and cos.COS_ACTIVE = 1 )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE_SCARF' and cos.COS_ACTIVE = 1 and cos.COS_STAT_CODE in ( '00', '01', '02' )));

     select count ( distinct ci.GUID_CI )
       into l_custinvsum
       from snt.TCUSTOMER_INVOICE  ci
          , snt.TDFCONTR_STATE     cos
          , snt.TDFCONTR_VARIANT   cov
          , snt.TFZGV_CONTRACTS    fzgvc
          , snt.TFZGVERTRAG        fzgv
      where fzgv.ID_COS          = cos.ID_COS
        and fzgv.ID_VERTRAG      = fzgvc.ID_VERTRAG
        and fzgv.ID_FZGVERTRAG   = fzgvc.ID_FZGVERTRAG
        and cov.ID_COV           = fzgvc.ID_COV
        and ci.ID_SEQ_FZGVC      = fzgvc.ID_SEQ_FZGVC
        and (  nvl ( i_checkoption, 'ALL' )  = 'ALL'
          or ( nvl ( i_checkoption, 'ALL' )  = 'OPEN'         and fzgvc.ID_SEQ_FZGKMSTAND_END is null )
          or ( nvl ( i_checkoption, 'ALL' )  = 'SCOPE'        and cov.COV_CAPTION not like 'MIG_OOS%' )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE'       and cos.COS_ACTIVE = 1 )
          or ( nvl ( i_checkoption, 'ALL' )  = 'ACTIVE_SCARF' and cos.COS_ACTIVE = 1 and cos.COS_STAT_CODE in ( '00', '01', '02' )));

      l_check_ende := sysdate ();

      v_diff := l_check_ende-i_check_begin;
      l_days := (v_diff);
      l_hours := TRUNC(v_diff, 0)*24;
      v_diff := (v_diff - TRUNC(v_diff, 0))*24;
      l_hours := l_hours + TRUNC(v_diff, 0);
      v_diff := (v_diff - TRUNC(v_diff, 0))*60;
      l_minutes := TRUNC(v_diff, 0);
      --l_hours := ((l_check_ende-i_check_begin) * 24) - (l_days *24);
      --l_minutes := ((l_check_ende-i_check_begin) * 24*60) - (l_hours * 60);
      --l_minutes := ((((l_check_ende-i_check_begin)*24*60*60) -(((l_check_ende-i_check_begin)*24*60*60)/3600)*3600)/60);
      --l_seconds := ((l_check_ende-i_check_begin)) * 86400 - (l_minutes * 60);

SELECT XMLELEMENT (
        "HTML"
      , XMLELEMENT (
           "BODY"
           , XMLELEMENT ( "H1", xmlattributes ( 'text-align:center;font-size:24pt;' AS "style" ), 'Sirius Health Check' )
           , XMLELEMENT ( "H2", xmlattributes ( 'text-align:center;font-size:12pt;' AS "style" ), 'Started: ' || to_char(i_check_begin,'YYYY-MM-DD HH24:MI:SS') || '@ Database: ' || l_databasename )
                                         , XMLELEMENT("br")
                                         , XMLELEMENT ( "H2", xmlattributes ( 'text-align:center;font-size:14pt;' AS "style" ), 'MPC: ' || l_countryname)
                                         , XMLELEMENT("br")
                                         , XMLELEMENT ( "H2", xmlattributes ( 'text-align:center;font-size:14pt;' AS "style" ), 'Checkoption: ' || i_checkoption)
                                         , XMLELEMENT("br")
                                         , XMLELEMENT ( "H3", xmlattributes ( 'text-align:left;font-size:16pt;' AS "style" ), 'Summary of occured errors' )
                                         --, XMLELEMENT("br")
           --, XMLELEMENT ( "H3", xmlattributes ( 'text-align:left;font-size:16pt;' AS "style" ), 'List of objects' )
           , XMLELEMENT ( "P", ssi_healthcheck.tblList ( l_filename ))
                                         , XMLELEMENT("br")
                                         , case i_addon when 'YES' then
                                            XMLELEMENT ( "H3", xmlattributes ( 'text-align:left;font-size:16pt;' AS "style" ), 'Summary of occured errors in additional checks' )
                                           end
                                           , case i_addon when 'YES' then
                                            XMLELEMENT ( "P", ssi_healthcheck.tblListAddon ( l_filename ))
                                           end
                                         , case i_addon when 'YES' then
                                            XMLELEMENT("br")
                                           end
                                         , XMLELEMENT ( "H3", xmlattributes ( 'text-align:left;font-size:16pt;' AS "style" ), 'Number of affected contracts per message class' )
                                         --, XMLELEMENT("br")
                                         , XMLELEMENT ( "P", ssi_healthcheck.tblListContr ( l_filename ))
                                         , XMLELEMENT("br")
                                         , XMLELEMENT ( "H2", xmlattributes ( 'text-align:left;font-size:14pt;' AS "style" ), 'Number of checked contracts: '  || l_contractsum )
                                         , case i_addon when 'YES' then
                                            XMLELEMENT ( "H2", xmlattributes ( 'text-align:left;font-size:14pt;' AS "style" ), 'Number of checked invoices: '  || l_invoicesum )
                                           end
                                         , case i_addon when 'YES' then
                                            XMLELEMENT ( "H2", xmlattributes ( 'text-align:left;font-size:14pt;' AS "style" ), 'Number of checked customer invoices: '  || l_custinvsum )
                                           end
                                         , XMLELEMENT("br")
                                         , XMLELEMENT ( "H2", xmlattributes ( 'text-align:left;font-size:12pt;' AS "style" ), 'Finished: ' || TO_CHAR ( l_check_ende, 'YYYY-MM-DD HH24:MI:SS' ))
                                         , XMLELEMENT ( "H2", xmlattributes ( 'text-align:left;font-size:12pt;' AS "style" ), 'Duration: ' || round(l_days,0) || ' days, ' || round(l_hours,0) || ' hours, ' || round(l_minutes,0) || ' minutes')


                                          )
       ).EXTRACT ( '.' )
    AS xml
INTO l_xml
FROM DUAL;
      xdb_utilities.printxmltofile (l_xml, SSI_CONST.HEALTHCHECK_DIR , l_filename ||'.html');--lg_filename_xml);

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN db_const.db_fail;
   END;
-------------------------------------------------------------------------------
   FUNCTION FINAL (
      i_id_io_file     IN   tssi_io_file.id_io_file%TYPE
     ,i_io_file_name   IN   tssi_io_file.io_file_name%TYPE
     ,i_multi_contract in number default 0
     --,i_check_begin in out date
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret            db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_res            BOOLEAN;
      lc_sub_modul     VARCHAR2 (100)                     DEFAULT 'FINAL';
      l_file_success   BOOLEAN;

   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Generating the acknowledge file for the sent XML-file
      --
      if i_multi_contract !=1 or i_multi_contract is null then
      IF ssi_ack.create_file (o_file_success      => l_file_success, i_id_io_file => i_id_io_file) =
                                                                                                    db_const.db_success
      THEN
         l_ret := ssi_log.update_file_time (i_id_io_file      => i_id_io_file, i_time_type => ssi_const.file_time_ack);
      ELSE
         NULL;                                                                                                  -- ToDo
      END IF;
      else
      null;
            -- der aufruf wurde ins check database verschoben
           -- l_ret:= createxml (i_check_begin => i_check_begin);

      --to do :create report
      end if;

      --
      -- It is only possible to move a real file
      -- a global_error file is not possible to move
      --
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   END FINAL;

-------------------------------------------------------------------------------

FUNCTION is_mandant_ssi_allowed ( i_mandant_id IN tssi_io_file.ssim_mandant_id%TYPE )
 RETURN BOOLEAN
IS
 --  PURPOSE
 --
 --  PARAMETERS
 --  In-Parameter
 --  Return bei Funktionen
 --    db_const.db_success : The message is stored in the table tssi_journal
 --    db_const.db_fail  : There was a error in this function.
 --  DATABASE TRANSACTIONBEHAVIOR
 --  atomic
 --  EXCEPTIONS
 --  In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--   jeweils durchgeführten Plausibilitätsprüfungen
 --  Auswirkungen auf den Bildschirm
 --  durchgeführten Protokollierung
 --  abgelegten Tracinginformationen
 --  ENDPURPOSE
 -------------------------------------------------------------------------------
 lc_sub_modul      VARCHAR2 ( 100 ) DEFAULT 'IS_MANDANT_SSI_ALLOWED';
 l_dummy        VARCHAR2 ( 1 );
BEGIN
 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

 --
 SELECT 'X'
 INTO l_dummy
 FROM snt.tssi_mandant
 WHERE ssim_mandant_id = i_mandant_id;

 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
 RETURN TRUE;
EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION Mandant: ' || i_mandant_id || ' not Allowed' );
  RETURN FALSE;
END is_mandant_ssi_allowed;

-------------------------------------------------------------------------------

FUNCTION is_this_a_ssi_object (
      i_xml_object_name   IN   lov_xml_object.xml_object_name%TYPE
   )
      RETURN BOOLEAN
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'IS_THIS_A_SSI_OBJECT';
      l_dummy        VARCHAR2 (1);
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      SELECT 'X'
        INTO l_dummy
        FROM lov_xml_object
       WHERE xml_object_name = i_xml_object_name;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                     ,'***** End of Function ***** - EXCEPTION Is No SSI Object');
         RETURN FALSE;
   END is_this_a_ssi_object;

-------------------------------------------------------------------------------
FUNCTION get_xml_object (
      o_xml_object        OUT      lov_xml_object.xml_object%TYPE
     ,i_xml_object_name   IN       lov_xml_object.xml_object_name%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : The message is stored in the table tssi_journal
--      db_const.db_fail    : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'GET_XML_OBJECT';
      l_dummy        VARCHAR2 (1);
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      SELECT xml_object
        INTO o_xml_object
        FROM lov_xml_object
       WHERE xml_object_name = i_xml_object_name;

      --
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH'
                     ,'***** End of Function ***** - EXCEPTION Is No SSI Object');
         RETURN db_const.db_fail;
   END get_xml_object;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

FUNCTION file_info
 RETURN db_datatype.db_returnstatus%TYPE
IS
 --  PURPOSE
 --  Tests whether the filenames are in the correct format
 --  PARAMETERS
 --  In-Parameter
 --  Return bei Funktionen
 --    db_const.db_success : The message is stored in the table tssi_journal
 --    db_const.db_fail  : There was a error in this function.
 --  DATABASE TRANSACTIONBEHAVIOR
 --  atomic
 --  EXCEPTIONS
 --  In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitätsprüfungen
 --  Auswirkungen auf den Bildschirm
 --  durchgeführten Protokollierung
 --  abgelegten Tracinginformationen
 --  ENDPURPOSE
 -------------------------------------------------------------------------------
 l_ret         db_datatype.db_returnstatus%TYPE DEFAULT db_const.db_success;
 lc_sub_modul      VARCHAR2 ( 100 ) DEFAULT 'FILE_INFO';
 l_mandant_id      tssi_io_file.ssim_mandant_id%TYPE;
 l_ssi_object      tssi_io_file.ssi_object%TYPE;
 l_timestamp_varchar    VARCHAR2 ( 1000 );
 l_timestamp       tssi_dirlist.running_date%TYPE;
 l_file_running_varchar   VARCHAR2 ( 1000 );
 l_file_running_number   tssi_dirlist.running_number%TYPE;
 l_mandant_valid     tssi_dirlist.mandant_valid%TYPE;
 l_valid_ssi_object    tssi_dirlist.valid_ssi_object%TYPE;
 l_msg_text       tssi_dirlist.msg_text%TYPE;
 l_valid_file_name     tssi_dirlist.valid_file_name%TYPE;

 -------------------------------------------------------------------------------
 FUNCTION is_numeric ( o_number OUT NUMBER, i_char IN VARCHAR2 )
  RETURN BOOLEAN
 IS
 BEGIN
  o_number := TO_NUMBER ( i_char );
  RETURN TRUE;
 EXCEPTION
  WHEN OTHERS
  THEN
   RETURN FALSE;
 END is_numeric;

 -------------------------------------------------------------------------------
 FUNCTION is_date ( o_date OUT DATE, i_char IN VARCHAR2, i_format IN VARCHAR2 DEFAULT 'YYYYMMDD' )
  RETURN BOOLEAN
 IS
 BEGIN
  o_date := TO_DATE ( i_char, i_format );
  RETURN TRUE;
 EXCEPTION
  WHEN OTHERS
  THEN
   RETURN FALSE;
 END is_date;
-------------------------------------------------------------------------------
BEGIN
 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

 --
 FOR l_file IN ( SELECT ROWID row_id, t.*
      FROM tssi_dirlist t )
 LOOP
  l_msg_text := NULL;
  l_mandant_id := NULL;
  l_mandant_valid := NULL;
  l_timestamp := NULL;
  l_file_running_number := NULL;
  l_ssi_object := NULL;
  l_valid_ssi_object := NULL;
  l_valid_file_name := 'Y';

  BEGIN
   l_mandant_id :=
    SUBSTR (
       l_file.filename
       , 1
       , INSTR (
           l_file.filename
         , '_'
         , 1
         , 1
          )
       - 1
        );
  EXCEPTION
   WHEN OTHERS
   THEN
    l_ret :=
     ssi_log.store_msg (
             i_id_object       => l_file.id_io_file
           , i_msg_code       => '00205'
           , i_message_class      => 'E'
           , i_msg_value       => SQLERRM
           , i_msg_text       => 'Cannot get Mandant name from Filename ' || l_file.filename
           , i_msg_modul       => lgc_modul || lc_sub_modul
            );
    l_mandant_valid := 'N';
    l_mandant_id := -1;
  END;

  IF ssi_healthcheck.is_mandant_ssi_allowed ( i_mandant_id => l_mandant_id )
  THEN
   l_mandant_valid := 'Y';
   l_ssi_object :=
    UPPER ( SUBSTR (
           l_file.filename
         , INSTR (
             l_file.filename
             , '_'
             , 1
             , 1
            )
           + 1
         ,  INSTR (
             l_file.filename
             , '_'
             , 1
             , 2
              )
           - INSTR (
             l_file.filename
             , '_'
             , 1
             , 1
              )
           - 1
          ) );

   -- ToDo Später prüfen, ob der Mandant und das Objekt im Filename mit dem Inhalt des Files übereinstimmen
   IF ssi_healthcheck.is_this_a_ssi_object ( i_xml_object_name => l_ssi_object )
   THEN
    l_valid_ssi_object := 'Y';
   ELSE
    l_valid_ssi_object := 'N';
    l_valid_file_name := 'N';
   END IF;

   --
   -- because SIRIUSTEST don't use the required fileformat
   --
   IF l_mandant_id != ssi_const.siriustest                              --'SIRIUSTEST'
   THEN
    l_timestamp_varchar :=
     SUBSTR (
        l_file.filename
        , INSTR (
            l_file.filename
          , '_'
          , 1
          , 2
           )
        + 1
        ,   INSTR (
            l_file.filename
            , '_'
            , 1
            , 3
           )
        - INSTR (
            l_file.filename
            , '_'
            , 1
            , 2
           )
        - 1
         );

    IF is_date ( o_date => l_timestamp, i_char => l_timestamp_varchar, i_format => 'YYYYMMDD' ) = FALSE
    THEN
     l_valid_file_name := 'N';
     l_timestamp := NULL;
     l_msg_text := 'NOT A VALID RUNNING FILEDATE: ' || l_timestamp_varchar || ' ';
    END IF;

    l_file_running_varchar :=
     SUBSTR (
        l_file.filename
        , INSTR (
            l_file.filename
          , '_'
          , 1
          , 3
           )
        + 1
        ,   INSTR (
            l_file.filename
            , '.xml'
            , 1
            , 1
           )
        - INSTR (
            l_file.filename
            , '_'
            , 1
            , 3
           )
        - 1
         );

    IF is_numeric ( o_number => l_file_running_number, i_char => l_file_running_varchar ) = FALSE
    THEN
     l_valid_file_name := 'N';
     l_file_running_number := NULL;
     l_msg_text := l_msg_text || 'NOT A VALID RUNNING FILENUMBER: ' || l_file_running_varchar || ' ';
    END IF;
   ELSE
    l_timestamp := SYSDATE;
    -- Default, because SIRIUSTEST doesn't send a date
    l_file_running_number := 1;
   END IF;
  ELSE
   l_valid_file_name := 'N';
   l_mandant_valid := 'N';
   l_msg_text := l_msg_text || 'NOT A VALID MANDANT: ' || l_mandant_id || ' ';
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'file_info: Falscher Mandant File: ' || l_file.filename );
   l_ret :=
    ssi_log.store_msg (
            i_id_object       => l_file.id_io_file
          , i_msg_code       => '00205'
          , i_message_class      => 'E'
          , i_msg_value       => l_mandant_id
          , i_msg_text       => 'The mandant: ' || l_mandant_id || ' is not valid!'
          , i_msg_modul       => lgc_modul || lc_sub_modul
           );
  -- ToDo
  -- Abfangen von XML-Files, die nicht gültig sind.
  END IF;

  IF l_mandant_valid = 'Y'
  THEN
   UPDATE tssi_dirlist
   SET ssim_mandant_id = l_mandant_id
     , mandant_valid = l_mandant_valid
     , running_date = l_timestamp
     , running_number = l_file_running_number
     , ssi_object = l_ssi_object
     , valid_ssi_object = l_valid_ssi_object
     , msg_text = l_msg_text
     , valid_file_name = l_valid_file_name
   WHERE ROWID = l_file.row_id;
  ELSE
   l_ret :=
    ssi_log.
    store_msg (
        i_id_object      => l_file.id_io_file
        , i_msg_code      => '00205'
        , i_message_class    => 'E'
        , i_msg_value      => l_file.filename
        , i_msg_text      =>   'Cannot get Mandant id from Filename '
                   || l_file.filename
                   || ' or mandant: '
                   || l_mandant_id
                   || ' is not valid!'
        , i_msg_modul      => lgc_modul || lc_sub_modul );
   l_ret := db_const.db_fail;
  END IF;
 END LOOP;

 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
 RETURN l_ret;
END file_info;

-------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

FUNCTION process
       ( i_id_vertrag         IN VARCHAR2 DEFAULT NULL
       , i_id_fzgvertrag      IN VARCHAR2 DEFAULT NULL
       , i_debug              IN VARCHAR2 DEFAULT 'NO'
       , i_no_clear           IN VARCHAR2 DEFAULT 'NO'
       , i_trace_context      IN VARCHAR2 DEFAULT NULL
       , i_trace_target       IN VARCHAR2 DEFAULT 'TABLE'                                                   -- may be also 'SCREEN'
       , i_trace_clear        IN VARCHAR2 DEFAULT 'YES'                                        -- cleans up tracing table when run.
       , i_multi_contract     IN NUMBER   DEFAULT 0
       , i_addon              in varchar2 default 'YES'
       , i_checkoption        in varchar2 default 'ALL'
 )
  RETURN db_datatype.db_returnstatus%TYPE
 IS
--  PURPOSE
--
--  PARAMETERS
--  In-Parameter
--    i_file_name : Searches for this Filename in the Inbox.
--        It's also possible to search only parts of a filename
--        example: Sender or Objectname
--        If empty all files are searched.
--    i_init_load : Is this a initial load?
--
--    The following parameters are only for maintenance:
--    i_debug   : If YES debug messages are sent to Quest error manager Tracing log
--    i_no_clear  : If YES the data in the stage and in the XMLDB are not deleted
--        This data have to be deleted manually
--    i_trace_context:
--        NULL means: Trace all,
--        DEBUG traces only debug information,
--        WALKTHROUGH traces Function start AND End,
--        Function name or Package name traces all info of a dedicated package or function
--    i_trace_target: defines direction of tracing : 'TABLE' => snt.Q$log  'SCREEN' => dbms_output
--    i_trace_clear: If YES the table q$log will be cleaned
--
--
--  Return bei Funktionen
--    db_const.db_success : The message is stored in the table tssi_journal
--    db_const.db_fail  : There was a error in this function.
--  DATABASE TRANSACTIONBEHAVIOR
--  atomic
--  EXCEPTIONS
--  In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--  jeweils durchgeführten Plausibilitätsprüfungen
--  Auswirkungen auf den Bildschirm
--  durchgeführten Protokollierung
--  abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
l_ret                db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
l_ret_cu             db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
l_ret_co             db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
l_ret_pm             db_datatype.db_returnstatus%TYPE    DEFAULT db_const.db_success;
lc_sub_modul         varchar2 (100)                      DEFAULT 'PROCESS';
l_id_io_file         tssi_io_file.id_io_file%TYPE;
l_filename           tssi_io_file.io_file_name%TYPE;
l_answer             VARCHAR2 (500);
l_contract_creation  tfzgvertrag.fzgv_created%TYPE;
l_mandant_id         snt.tssi_mandant.ssim_mandant_id%TYPE;
l_guid_contract      tfzgvertrag.guid_contract%TYPE;
i_init_load          BOOLEAN             DEFAULT FALSE;


BEGIN
 lg_debug := i_debug;
 lg_no_clear := i_no_clear;

 -- There can be only one...
 BEGIN
  IF snt.process_manager.start_process ( 'SSI', 'SSI_HEALTCHCKECK'      /*, l_answer*/
                         ) = db_const.db_fail
  THEN
   l_ret :=
    ssi_log.store_msg (
            i_id_object       => l_id_io_file
          , i_msg_code        => '00111'
          , i_message_class   => 'E'
          , i_msg_value       => ''
          , i_msg_text        => ''
          , i_msg_modul       => lgc_modul || lc_sub_modul
           );
   raise_application_error ( -20999, 'SSI Healthcheck not possible! ' || l_answer );
  END IF;
 EXCEPTION
  WHEN OTHERS
  THEN
   l_ret :=
    ssi_log.store_msg (
            i_id_object       => l_id_io_file
          , i_msg_code        => '00111'
          , i_message_class   => 'E'
          , i_msg_value       => ''
          , i_msg_text        => SQLERRM
          , i_msg_modul       => lgc_modul || lc_sub_modul
           );
   raise_application_error ( -20999, SQLERRM );
 END;

 --  Define DEBUG LEVEL
 IF lg_debug = 'YES'
 THEN
  -- define output target
  IF i_trace_target = 'SCREEN'
  THEN
   qerrm.toscreen;
  ELSE
   qerrm.totable;

   IF i_trace_clear = 'YES'
   THEN
    qerrm.clear_trace;
   END IF;
  END IF;

  -- activate trace
  qerrm.trace_on ( include_timestamp_in => FALSE, context_like_in => i_trace_context );
 ELSE
  qerrm.trace_off ( include_timestamp_in => FALSE, context_like_in => i_trace_context );
 END IF;

 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );

 --
 -- delete the stage but not locked objects
 -- Attention: The last data are deleted because the notfound exit is comming later
 --
 IF ( lg_no_clear != 'YES' )
  OR ( lg_no_clear IS NULL )
 THEN
  l_ret := delete_stage;
 END IF;

 SELECT NVL ( tm.ssim_mandant_id, 'SIRIUS' ), tv.guid_contract, tv.fzgv_created
 INTO l_mandant_id, l_guid_contract, l_contract_creation
 FROM snt.tfzgvertrag tv, snt.tssi_mandant tm
 WHERE   tv.guid_ssim = tm.guid_ssim(+)
   AND tv.id_vertrag = i_id_vertrag
   AND tv.id_fzgvertrag = i_id_fzgvertrag;

 BEGIN
  --
  -- generate HELATHCHECK entry in IO table
  --
  l_id_io_file := NULL;
  l_filename := i_id_vertrag || '-' || i_id_fzgvertrag;
  l_ret :=
   ssi_log.store_io_file (
           o_id_io_file                => l_id_io_file
           , i_issim_mandant_id        => l_mandant_id
           , i_ssi_object              => ssi_const.healthcheck_obj
           , i_io_timestamp            => TO_CHAR ( l_contract_creation, 'YYYYMMDD' )
           , i_io_file_running_number  => TO_CHAR ( 1 )
           , i_io_file_name            => i_id_vertrag || '-' || i_id_fzgvertrag
           , i_io_file_date_create     => l_contract_creation
           , i_io_file_size            => 0
           , i_io_read_from_inbox_date => SYSTIMESTAMP
           , i_file_type               => ssi_const.file_type_hck
           , i_file_location           => ssi_const.healthcheck_dir
           , i_object_type             => ssi_const.xml_object.healthcheck
            );

  --
  -- Transfer the contract data from Production to the stage
  --
  IF contracts_to_stage ( i_id_io_file => l_id_io_file, i_guid_contract => l_guid_contract ) = db_const.db_success
  THEN
   --
   -- ToDo Commit wird hier gemacht, weil es sonst zu einem Deadlock kommen kann.
   -- Aktuell nur im Contract
   --
   COMMIT;

    <<loop_object>>
    FOR l_o IN ( SELECT id_object
        FROM tssi_io_object
        WHERE   id_io_file = l_id_io_file
          AND xml_object = ssi_const.xml_object.contract
          AND file_object = ssi_const.file_object.real_object           -- We ar only searching real objects
                            )
    LOOP
     qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'process: loop_object: ssi_object' || l_o.id_object );
     --
     -- For every object in a file the SSI checks and further processing are done
     --
     l_ret :=
      ssi_contract.process 
             ( i_check_rules      => TRUE
             , i_store_data       => FALSE
             , i_init_load        => FALSE
             , i_errorflag        => db_const.db_success
             , i_object_typ       => ssi_const.contract_obj
             , i_id_object        => l_o.id_object
             , i_typ_process      => ssi_const.typ_import_process.healthcheck
             , i_addon            => i_addon
             , i_checkoption      => i_checkoption
             );
     qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'ssi_contract l_ret: ' || l_ret );
     qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'loop_object next object' );
    END LOOP loop_object;
   END IF;                                       -- test_update_allowed
                                                 -- xmldb_to_stage

  --
  -- Calling the acknowledge routine for the actual file
  --
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'calling Acknowledge routine and clean up' );
  l_ret := final ( i_id_io_file => l_id_io_file, i_io_file_name => l_filename, i_multi_contract => i_multi_contract);
  --
  COMMIT;
 EXCEPTION
  WHEN DUP_VAL_ON_INDEX
  THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'Object exists in Stage already: ' || SQLERRM );
   l_ret :=
    ssi_log.
    store_msg (
        i_id_object      => l_id_io_file
        , i_msg_code      => '00900'
        , i_message_class    => 'E'
        , i_msg_value      => SQLERRM
        , i_msg_text      => 'Object already exists in stage! - Contract extension or transfer may be waiting for confirmation!'
        , i_msg_modul      => lgc_modul || lc_sub_modul );
   ROLLBACK;
   l_ret := final ( i_id_io_file => l_id_io_file, i_io_file_name => l_filename, i_multi_contract => i_multi_contract);
   COMMIT;
  WHEN OTHERS
  THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'process1: ' || SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'process1: ' || DBMS_UTILITY.format_error_backtrace );
   l_ret :=
    ssi_log.store_msg (
            i_id_object       => l_id_io_file
          , i_msg_code       => '00900'
          , i_message_class      => 'E'
          , i_msg_value       => SQLERRM
          , i_msg_text       => DBMS_UTILITY.format_error_backtrace
          , i_msg_modul       => lgc_modul || lc_sub_modul
           );
   ROLLBACK;
   l_ret := final ( i_id_io_file => l_id_io_file, i_io_file_name => l_filename, i_multi_contract => i_multi_contract);
   COMMIT;
 END;

 l_ret_pm := snt.process_manager.end_process ( 'SSI', 'SSI' );

    --
    -- delete the stage but not locked objects
    --
    IF ( lg_no_clear != 'YES' )
        OR ( lg_no_clear IS NULL )
    THEN
        l_ret := delete_stage;
    END IF;

 qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
 RETURN l_ret;
EXCEPTION
 WHEN highlander
 THEN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'HIGHLANDER: ' || SQLERRM );
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'HIGHLANDER: ' || DBMS_UTILITY.format_error_backtrace );

--  IF c_file%ISOPEN
--  THEN
--   CLOSE c_file;
--  END IF;

  --
  -- If there is no filename we use a dummy name: global_error
  --
  IF l_filename IS NULL
  THEN
   l_filename := ssi_healthcheck.lgc_error_file;
  END IF;

  l_ret :=
   ssi_log.store_io_file (
           o_id_io_file                => l_id_io_file
           , i_issim_mandant_id        => 'SIRIUS HEALTHCHECK'
           , i_ssi_object              => ssi_const.xml_object.healthcheck
           , i_io_timestamp            => TO_CHAR ( SYSTIMESTAMP, 'YYYYMMDD' )
           , i_io_file_running_number  => TO_CHAR ( 0 )
           , i_io_file_name            => l_filename
           , i_io_file_date_create     => SYSTIMESTAMP
           , i_io_file_size            => 0
           , i_io_read_from_inbox_date => SYSTIMESTAMP
           , i_file_type               => ssi_const.file_type_ssi
           , i_file_location           => ssi_const.inbox_dir
            );
  l_ret :=
   ssi_log.store_msg (
           i_id_object       => l_id_io_file
         , i_msg_code        => '00100'
         , i_message_class   => 'E'
         , i_msg_value       => SQLERRM
         , i_msg_text        => 'Another Process is blocking'
         , i_msg_modul       => lgc_modul || lc_sub_modul
          );
  ROLLBACK;
  -- ToDo was machen wenn ein globaler final gemacht wird?
  l_ret := final ( i_id_io_file => l_id_io_file, i_io_file_name => l_filename, i_multi_contract => i_multi_contract);
  l_ret_pm := snt.process_manager.end_process ( 'SSI', 'SSI' );
  COMMIT;
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
  RETURN l_ret;
 WHEN OTHERS
 THEN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'process2: ' || SQLERRM );
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - DEBUG', 'process2: ' || DBMS_UTILITY.format_error_backtrace );

--  IF c_file%ISOPEN
--  THEN
--   CLOSE c_file;
--  END IF;

  --
  -- If there is no filename we use a dummy name: global_error
  --
  IF l_filename IS NULL
  THEN
   l_filename := ssi_healthcheck.lgc_error_file;
  END IF;

  l_ret :=
   ssi_log.store_io_file (
           o_id_io_file                => l_id_io_file
           , i_issim_mandant_id        => 'SIRIUS HEALTHCHECK'
           , i_ssi_object              => ssi_const.xml_object.healthcheck
           , i_io_timestamp            => TO_CHAR ( SYSTIMESTAMP, 'YYYYMMDD' )
           , i_io_file_running_number  => TO_CHAR ( 0 )
           , i_io_file_name            => l_filename
           , i_io_file_date_create     => SYSTIMESTAMP
           , i_io_file_size            => 0
           , i_io_read_from_inbox_date => SYSTIMESTAMP
           , i_file_type               => ssi_const.file_type_ssi
           , i_file_location           => ssi_const.inbox_dir
            );
  l_ret :=
   ssi_log.store_msg (
           i_id_object       => l_id_io_file
         , i_msg_code        => '00900'
         , i_message_class   => 'E'
         , i_msg_value       => SQLERRM
         , i_msg_text        => DBMS_UTILITY.format_error_backtrace
         , i_msg_modul       => lgc_modul || lc_sub_modul
          );
  ROLLBACK;
  -- ToDo was machen wenn ein globaler final gemacht wird?
  l_ret := final ( i_id_io_file => l_id_io_file, i_io_file_name => l_filename, i_multi_contract => i_multi_contract);
  l_ret_pm := snt.process_manager.end_process ( 'SSI', 'SSI' );
  COMMIT;
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
  RETURN l_ret;
END process;

-------------------------------------------------------------------------------

-- FraBe 04.04.2013 MKS-121951:1 add  Active and ActiveSCARF
PROCEDURE check_database ( i_checkoption VARCHAR2 DEFAULT NULL, i_addon varchar2 Default 'YES' )
IS
 ---
 cursor OnlyContractCurSCOPE
 is
  select ID_VERTRAG, ID_FZGVERTRAG
    from snt.TFZGVERTRAG fzgv
   where exists ( select null                                   -- FraBe MKS-121256:2 change where not exists to where exists
                    from snt.TFZGV_CONTRACTS     fzgvc
                       , snt.TDFCONTR_VARIANT    var
                   where var.COV_CAPTION     not like '%MIG_OOS%'
                     and var.ID_COV          = fzgvc.ID_COV
                     and fzgv.ID_VERTRAG     = fzgvc.ID_VERTRAG
                     and fzgv.ID_FZGVERTRAG  = fzgvc.ID_FZGVERTRAG );
 ---
 CURSOR allContractCur
 IS
  select ID_VERTRAG, ID_FZGVERTRAG
    from snt.TFZGVERTRAG
  -- where rownum < 1000                                      -- auskommentieren
  ;
 ---
 CURSOR ActiveContractCur
 IS
  select fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG
    from snt.TFZGVERTRAG     fzgv
       , snt.TDFCONTR_STATE  cos
   where cos.ID_COS          = fzgv.ID_COS
     and cos.COS_ACTIVE      = 1                            -- nur aktive verträge
  -- and rownum < 1000                                      -- auskommentieren
  ;
 ---
 CURSOR ActiveSCARFContractCur
 IS
  select fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG
    from snt.TFZGVERTRAG     fzgv
       , snt.TDFCONTR_STATE  cos
   where cos.ID_COS          = fzgv.ID_COS
     and cos.COS_ACTIVE      = 1                            -- nur aktive verträge
     and cos.COS_STAT_CODE  in ( '00', '01', '02' )
  -- and rownum < 1000                                      -- auskommentieren
  ;
 ---
 CURSOR openContractCur
 IS
  select ID_VERTRAG, ID_FZGVERTRAG, max ( tc.ID_SEQ_FZGVC )
  from snt.TFZGV_CONTRACTS tc
  where tc.ID_SEQ_FZGKMSTAND_END is null
  group by ID_VERTRAG, ID_FZGVERTRAG;
 ---
 
 i            NUMBER;
 i_checkbegin date;
 l_ret        db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;


BEGIN


--l_checkbegin:= TO_CHAR ( SYSDATE ( ), 'YYYY-MM-DD HH24:MI:SS' );
i_checkbegin:=sysdate ();
SELECT SEQ_SSI_ID_JOURNAL.nextval INTO i_journal_id FROM dual;

DELETE FROM TSSI_JOURNAL
WHERE TSSI_JOURNAL.ID_OBJECT IN (SELECT TSSI_IO_OBJECT.ID_OBJECT
                                            FROM TSSI_IO_FILE, TSSI_IO_OBJECT
                                            WHERE ( TSSI_IO_OBJECT.ID_IO_FILE = TSSI_IO_FILE.ID_IO_FILE )
                                                    AND ( TSSI_IO_FILE.SSI_OBJECT = 'HEALTHCHECK' ));

 IF ( i_checkoption IS NULL )
  OR ( UPPER ( i_checkoption ) = 'ALL' )
 THEN
  DBMS_OUTPUT.put_line ( 'START PROCESSING' );

  FOR rcur IN allContractCur
  LOOP
   i := process ( i_id_vertrag      => rcur.id_vertrag
                , i_id_fzgvertrag   => rcur.id_fzgvertrag
                , i_debug           => 'NO'
                , i_multi_contract  => 1
                , i_addon           => i_addon
              --, i_check_begin     => i_checkbegin
              --, i_journal_id      => i_journal_id
                , i_checkoption     => i_checkoption
                );
   DBMS_OUTPUT.put_line ( 'PROCESSING RESULT for ' || rcur.id_vertrag || '/' || rcur.id_fzgvertrag || ': ' || i );
  END LOOP;
 END IF;

 IF UPPER ( i_checkoption ) = 'ACTIVE'
 THEN
  DBMS_OUTPUT.put_line ( 'START PROCESSING' );

  FOR rcur IN activeContractCur
  LOOP
   i := process ( i_id_vertrag      => rcur.id_vertrag
                , i_id_fzgvertrag   => rcur.id_fzgvertrag
                , i_debug           => 'NO'
                , i_multi_contract  => 1
                , i_addon           => i_addon
              --, i_check_begin     => i_checkbegin
              --, i_journal_id      => i_journal_id
                , i_checkoption     => i_checkoption
                );
   DBMS_OUTPUT.put_line ( 'PROCESSING RESULT for ' || rcur.id_vertrag || '/' || rcur.id_fzgvertrag || ': ' || i );
  END LOOP;
 END IF;

 IF UPPER ( i_checkoption ) = 'ACTIVE_SCARF'
 THEN
  DBMS_OUTPUT.put_line ( 'START PROCESSING' );

  FOR rcur IN activeSCARFContractCur
  LOOP
   i := process ( i_id_vertrag      => rcur.id_vertrag
                , i_id_fzgvertrag   => rcur.id_fzgvertrag
                , i_debug           => 'NO'
                , i_multi_contract  => 1
                , i_addon           => i_addon
              --, i_check_begin     => i_checkbegin
              --, i_journal_id      => i_journal_id
                , i_checkoption     => i_checkoption
                );
   DBMS_OUTPUT.put_line ( 'PROCESSING RESULT for ' || rcur.id_vertrag || '/' || rcur.id_fzgvertrag || ': ' || i );
  END LOOP;
 END IF;

 IF UPPER ( i_checkoption ) = 'OPEN'
 THEN
  FOR rcur IN openContractCur
  LOOP
   i := process ( i_id_vertrag      => rcur.id_vertrag
                , i_id_fzgvertrag   => rcur.id_fzgvertrag
                , i_debug           => 'NO'
                , i_multi_contract  => 1
                , i_addon           => i_addon
              --, i_check_begin     => i_checkbegin
              --, i_journal_id      => i_journal_id
                , i_checkoption     => i_checkoption
                );
   DBMS_OUTPUT.put_line ( 'PROCESSING RESULT for ' || rcur.id_vertrag || '/' || rcur.id_fzgvertrag || ': ' || i );
  END LOOP;
 END IF;

 IF UPPER ( i_checkoption ) = 'SCOPE'
 THEN
  DBMS_OUTPUT.put_line ( 'START PROCESSING' );

  FOR rcur IN OnlyContractCurSCOPE
  LOOP
   i := process ( i_id_vertrag        => rcur.id_vertrag
                , i_id_fzgvertrag   => rcur.id_fzgvertrag
                , i_debug           => 'NO'
                , i_multi_contract  => 1
                , i_addon           => i_addon
              --, i_check_begin     => i_checkbegin
              --, i_journal_id      => i_journal_id
                , i_checkoption     => i_checkoption
                );
   DBMS_OUTPUT.put_line ( 'PROCESSING RESULT for ' || rcur.id_vertrag || '/' || rcur.id_fzgvertrag || ': ' || i );
  END LOOP;
 END IF;

    l_ret:= createxml ( i_check_begin => i_checkbegin
                      , i_addon       => i_addon
                      , i_checkoption => i_checkoption );

 DBMS_OUTPUT.put_line ( 'END PROCESSING' );

END check_database;

function open_csv_file
       ( I_filename      varchar2 )
         return          UTL_FILE.file_type  is
         l_filehandle    UTL_FILE.file_type;
         l_filename      VARCHAR2 ( 4000 char );
         l_export_path   VARCHAR2 ( 1000 char )     DEFAULT SSI_CONST.HEALTHCHECK_DIR;
         l_fexist        BOOLEAN;
         l_file_length   NUMBER;
         l_block_size    NUMBER;
         l_message       varchar2( 4000 char );

begin
      BEGIN
         --check if file exists, if overwrite =0
         UTL_FILE.fgetattr (l_export_path
                           ,i_filename
                           ,l_fexist
                           ,l_file_length
                           ,l_block_size
                           );

         IF l_fexist = TRUE
         THEN
            UTL_FILE.fremove ( LOCATION  => l_export_path, filename => i_filename );
         END IF;

         -- Open File
         l_filehandle := UTL_FILE.fopen (l_export_path
                                        ,i_filename
                                        ,'W'
                                        ,32740
                                        );
      EXCEPTION
         WHEN OTHERS
              THEN
                 l_message := SQLERRM;
                 DBMS_OUTPUT.put_line ( l_export_path );
                 DBMS_OUTPUT.put_line ( l_filename );
                 DBMS_OUTPUT.put_line ( SQLERRM );
                 raise_application_error ( -20000, SQLERRM );
      END;

      return l_filehandle;

end open_csv_file;


procedure cre_csv_for_html
        ( I_filename varchar2 ) is
          L_ROWCOUNT      integer  := 0;
          l_filehandle    UTL_FILE.file_type;
          l_text          varchar2 ( 4000 char );
begin
    for crec in ( select distinct
                         translate ( MSG_TEXT, chr(10) || '\/:*?"<>|', ' ' ) as MSG_TEXT_transl
                       , MSG_TEXT
                    from V_HEALTHCHECK
                   where substr ( MSG_CODE, 1, 1 ) <> 6
                   order by 1 )
    loop
         -- vorm open vom neuen csv file muß der csv file von der vorherigen schleifendurchführung
         -- -> rowcount ist dann <> 0, abgeschlossen werden,

         l_filehandle := open_csv_file ( I_filename => I_filename || '_' || crec.MSG_TEXT_transl || '.csv' );

         l_text :=      '"Message Class'
                   || '";"Error Message'
                   || '";"Error Description'
                   || '";"Contract'
                   || '";"Modul'
                   || '";"Table Name'
                   || '";"Column Name'
                   || '";"Value'
                   || '";"Message Code'
                   || '";"Error Categorie'
                   || '";"SSI Object'
                   || '"';

         UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
         L_ROWCOUNT := L_ROWCOUNT + 1;

         for c1_rec in ( select *
                           from V_HEALTHCHECK
                          where MSG_TEXT = crec.MSG_TEXT
                            and substr ( MSG_CODE, 1, 1 ) <> 6
                          order by CONTRACT, MSG_MODUL, TABLE_NAME, COLUMN_NAME )
         loop

              l_text :=      '"' || c1_rec.MESSAGE_CLASS_NAME
                        || '";"' || c1_rec.MSG_CODE_NAME
                        || '";"' || translate ( c1_rec.MSG_TEXT, chr(10), ' ' )
                        || '";"' || c1_rec.CONTRACT
                        || '";"' || c1_rec.MSG_MODUL
                        || '";"' || c1_rec.TABLE_NAME
                        || '";"' || c1_rec.COLUMN_NAME
                        || '";"' || c1_rec.MSG_VALUE
                        || '";"' || c1_rec.MSG_CODE
                        || '";"' || c1_rec.MSG_CATEGORIE_NAME
                        || '";"' || c1_rec.SSI_OBJECT
                        || '"';

              UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
              L_ROWCOUNT := L_ROWCOUNT + 1;

         end loop;   -- c1_rec

         UTL_FILE.fflush ( l_filehandle );
         UTL_FILE.fclose ( l_filehandle );

    end  loop;        -- crec

end cre_csv_for_html;

procedure cre_csv_for_html_addon
        ( I_filename varchar2 ) is
          L_ROWCOUNT      integer  := 0;
          l_filehandle    UTL_FILE.file_type;
          l_text          varchar2 ( 4000 char );
begin
    for crec in ( select distinct MSG_CODE_NAME
                    from V_HEALTHCHECK
                   where substr ( MSG_CODE, 1, 1 ) = 6
                   order by 1 )
    loop
         -- vorm open vom neuen csv file muß der csv file von der vorherigen schleifendurchführung
         -- -> rowcount ist dann <> 0, abgeschlossen werden,

         l_filehandle := open_csv_file ( I_filename => I_filename || '_' || translate ( crec.MSG_CODE_NAME, ' \/:*?"<>|', ' ' ) || '.csv' );

         l_text :=      '"Message Class'
                   || '";"Error Message'
                   || '";"Error Description'
                   || '";"Contract'
                   || '";"Modul'
                   || '";"Table Name'
                   || '";"Column Name'
                   || '";"Value'
                   || '";"Message Code'
                   || '";"Error Categorie'
                   || '";"SSI Object'
                   || '"';

         UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
         L_ROWCOUNT := L_ROWCOUNT + 1;

         for c1_rec in ( select *
                           from V_HEALTHCHECK
                          where MSG_CODE_NAME = crec.MSG_CODE_NAME
                            and substr ( MSG_CODE, 1, 1 ) = 6
                          order by CONTRACT, MSG_MODUL, TABLE_NAME, COLUMN_NAME )
         loop

              l_text :=      '"' || c1_rec.MESSAGE_CLASS_NAME
                        || '";"' || c1_rec.MSG_CODE_NAME
                        || '";"' || translate ( c1_rec.MSG_TEXT, chr(10), ' ' )
                        || '";"' || c1_rec.CONTRACT
                        || '";"' || c1_rec.MSG_MODUL
                        || '";"' || c1_rec.TABLE_NAME
                        || '";"' || c1_rec.COLUMN_NAME
                        || '";"' || c1_rec.MSG_VALUE
                        || '";"' || c1_rec.MSG_CODE
                        || '";"' || c1_rec.MSG_CATEGORIE_NAME
                        || '";"' || c1_rec.SSI_OBJECT
                        || '"';

              UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
              L_ROWCOUNT := L_ROWCOUNT + 1;

         end loop;   -- c1_rec

         UTL_FILE.fflush ( l_filehandle );
         UTL_FILE.fclose ( l_filehandle );

    end  loop;        -- crec

end cre_csv_for_html_addon;

procedure cre_csv_for_html_contr
        ( I_filename varchar2 ) is
          L_ROWCOUNT      integer  := 0;
          l_filehandle    UTL_FILE.file_type;
          l_text          varchar2 ( 4000 char );
begin
    for crec in ( select distinct MESSAGE_CLASS_NAME
                    from V_HEALTHCHECK
                   order by 1 )
    loop
         -- vorm open vom neuen csv file muß der csv file von der vorherigen schleifendurchführung
         -- -> rowcount ist dann <> 0, abgeschlossen werden,

         l_filehandle := open_csv_file ( I_filename => I_filename || '_' || translate ( crec.MESSAGE_CLASS_NAME, ' \/:*?"<>|', ' ' ) || '.csv' );

         l_text :=      '"Message Class'
                   || '";"Error Message'
                   || '";"Error Description'
                   || '";"Contract'
                   || '";"Modul'
                   || '";"Table Name'
                   || '";"Column Name'
                   || '";"Value'
                   || '";"Message Code'
                   || '";"Error Categorie'
                   || '";"SSI Object'
                   || '"';

         UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
         L_ROWCOUNT := L_ROWCOUNT + 1;

         for c1_rec in ( select *
                           from V_HEALTHCHECK
                          where MESSAGE_CLASS_NAME = crec.MESSAGE_CLASS_NAME
                          order by CONTRACT, MSG_MODUL, TABLE_NAME, COLUMN_NAME )
         loop

              l_text :=      '"' || c1_rec.MESSAGE_CLASS_NAME
                        || '";"' || c1_rec.MSG_CODE_NAME
                        || '";"' || translate ( c1_rec.MSG_TEXT, chr(10), ' ' )
                        || '";"' || c1_rec.CONTRACT
                        || '";"' || c1_rec.MSG_MODUL
                        || '";"' || c1_rec.TABLE_NAME
                        || '";"' || c1_rec.COLUMN_NAME
                        || '";"' || c1_rec.MSG_VALUE
                        || '";"' || c1_rec.MSG_CODE
                        || '";"' || c1_rec.MSG_CATEGORIE_NAME
                        || '";"' || c1_rec.SSI_OBJECT
                        || '"';

              UTL_FILE.put_line ( l_filehandle, l_text, TRUE );
              L_ROWCOUNT := L_ROWCOUNT + 1;

         end loop;   -- c1_rec

         UTL_FILE.fflush ( l_filehandle );
         UTL_FILE.fclose ( l_filehandle );

    end  loop;        -- crec

end cre_csv_for_html_contr;

FUNCTION whoami
 RETURN VARCHAR2
IS
BEGIN
 RETURN '$Revision: 1.9 $';
END whoami;

END ssi_healthcheck;
/