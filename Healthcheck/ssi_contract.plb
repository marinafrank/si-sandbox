CREATE OR REPLACE PACKAGE BODY SSI.ssi_contract
IS
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/01/22 10:18:36MEZ $
--
-- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag  $
--
-- $Revision: 1.2 $
--
-- $Header: 5100_Code_Base/Healthcheck/ssi_contract.plb 1.2 2014/01/22 10:18:36MEZ Berger, Franz (fraberg) CI_Changed  $
--
-- $Source: 5100_Code_Base/Healthcheck/ssi_contract.plb $
--
-- $Log: 5100_Code_Base/Healthcheck/ssi_contract.plb  $
-- Revision 1.2 2014/01/22 10:18:36MEZ Berger, Franz (fraberg) 
-- remove BOM am anfang des files
-- Revision 1.1 2014/01/22 10:07:12MEZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
-- Revision 1.44 2012/01/19 22:51:08MEZ Berger, Franz (fraberg) 
-- add  IN parameter iCC logic to FUNCTION process
-- Revision 1.43 2010/04/30 15:13:49CEST Musanovic, Adnana (amusano) 
-- Healthcheck addon parameter hinzugefügt
-- Revision 1.42 2010/03/03 15:43:36CET Kieninger, Tobias (tkienin)
-- INclude Healthcheck addon
-- Revision 1.41 2010/02/24 16:30:50CET Kieninger, Tobias (tkienin)
-- REQ450
-- Revision 1.40 2010/02/15 11:28:27CET Kieninger, Tobias (tkienin)
-- Fehlermeldung fixed
-- Revision 1.39 2010/02/04 11:53:56CET Kieninger, Tobias (tkienin)
-- Fixed version
-- Revision 1.36 2009/09/28 16:03:17CEST Kieninger, Tobias (tkienin)
-- .
-- Revision 1.35 2009/09/28 15:36:36CEST Kieninger, Tobias (tkienin)
-- Helathcheck rückbau
-- Revision 1.34 2009/09/24 16:29:42CEST Kieninger, Tobias (tkienin)
-- Zwischenstand
-- Revision 1.32 2008/12/08 19:00:14CET Drey, Franz (fdrey77)
-- Ausgabe der Schluessel für die Objekte bei erfolgreicher Speicherung
-- Revision 1.31 2008/11/27 08:44:12CET Humer, Martin (mhumer8)
-- MKS 64736; 27.11.2008
-- Revision 1.30 2008/11/26 20:06:10CET Kieninger, Tobias (tkienin)
-- Neue fehlercodes eingeführt
-- Revision 1.29 2008/11/19 14:52:14CET Humer, Martin (mhumer8)
-- MKS 63401; 19.11.2008
-- Revision 1.1 2008/11/18 20:08:09CET Drey, Franz (fdrey77)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.28 2008/11/18 20:04:59CET Drey, Franz (fdrey77)
-- Transfer Vegaattribute berichtigt
-- ExtRed  Endkilometer
-- Revision 1.27 2008/11/14 09:12:11CET Humer, Martin (mhumer8)
-- 14.11.2008 MKS 63630
-- Revision 1.1 2008/11/11 10:35:15CET Drey, Franz (fdrey77)
-- Initial revision
-- Member added to project /Archiv/mks/develop/b2b/sirius/5000 Construction/product.pj
-- Revision 1.25 2008/11/11 10:33:21CET Drey, Franz (fdrey77)
-- .
--
-- MKSEND
--
   lgc_modul   VARCHAR2 (100) DEFAULT 'SSI_CONTRACT.';

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tfzgv_contracts (
      o_tfzgv_contracts_array   IN OUT NOCOPY   ssi_datatype.typ_tfzgv_contracts
     ,i_id_vertrag              IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag           IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object               IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_data_tfzgv_contracts';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_contracts IN (SELECT   *
                              FROM tfzgv_contracts
                             WHERE id_vertrag = i_id_vertrag
                               AND id_fzgvertrag = i_id_fzgvertrag
                               AND id_object = i_id_object
                          ORDER BY id_seq_fzgvc ASC)
      LOOP
         l_i := l_i + 1;
         o_tfzgv_contracts_array (l_i) := r_contracts;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tfzgv_contracts;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tfzgkmstand (
      o_tfzgkmstand_array   IN OUT NOCOPY   ssi_datatype.typ_tfzgkmstand
     ,i_id_vertrag          IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag       IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object           IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_datatfzgkmstand';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_kmstand IN (SELECT *
                          FROM tfzgkmstand
                         WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         o_tfzgkmstand_array (l_i) := r_kmstand;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tfzgkmstand;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tfzglaufleistung (
      o_tfzglaufleistung_array   IN OUT NOCOPY   ssi_datatype.typ_tfzglaufleistung
     ,i_id_vertrag               IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag            IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object                IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_data_tfzglaufleistung';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_laufleistung IN (SELECT   *
                                 FROM tfzglaufleistung
                                WHERE id_vertrag = i_id_vertrag
                                  AND id_fzgvertrag = i_id_fzgvertrag
                                  AND id_object = i_id_object
                             ORDER BY id_seq_fzglaufleistung ASC)
      LOOP
         l_i := l_i + 1;
         o_tfzglaufleistung_array (l_i) := r_laufleistung;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tfzglaufleistung;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tfzgpreis (
      o_tfzgpreis_array   IN OUT NOCOPY   ssi_datatype.typ_tfzgpreis
     ,i_id_vertrag        IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag     IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object         IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_data_tfzgpreis';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_preis IN (SELECT   *
                          FROM tfzgpreis
                         WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object
                      ORDER BY id_seq_fzgvc
                              ,fzgpr_von)
      LOOP
         l_i := l_i + 1;
         o_tfzgpreis_array (l_i) := r_preis;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tfzgpreis;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tic_co_pack_ass (
      o_tic_co_pack_ass_array   IN OUT NOCOPY   ssi_datatype.typ_tic_co_pack_ass
     ,i_id_vertrag              IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag           IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object               IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_data_tic_co_pack_ass';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_tic_co IN (SELECT *
                         FROM tic_co_pack_ass
                        WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         o_tic_co_pack_ass_array (l_i) := r_tic_co;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tic_co_pack_ass;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION fetch_data_tvega_i55_co (
      o_tvega_i55_co_array   IN OUT NOCOPY   ssi_datatype.typ_tvega_i55_co
     ,i_id_vertrag           IN              tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag        IN              tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object            IN              tssi_io_object.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_i            PLS_INTEGER    DEFAULT 0;
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'fetch_data_tvega_i55_co';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Suche Einträge
      --
      FOR r_tvega IN (SELECT *
                        FROM tvega_i55_co
                       WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object)
      LOOP
         l_i := l_i + 1;
         o_tvega_i55_co_array (l_i) := r_tvega;
      END LOOP;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END fetch_data_tvega_i55_co;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION delete_contract (
      i_id_vertrag      IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzgvertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_id_object       IN   tssi_journal.id_object%TYPE
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      lc_sub_modul   VARCHAR2 (100) DEFAULT 'delete_contract';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Löscht alle Einträge der Tabellen, die zum Objekt Contract gehören
      --
      DELETE FROM tfzgvertrag
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tfzgv_contracts
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tfzgkmstand
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tfzglaufleistung
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tfzgpreis
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tic_co_pack_ass
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      DELETE FROM tvega_i55_co
            WHERE id_vertrag = i_id_vertrag AND id_fzgvertrag = i_id_fzgvertrag AND id_object = i_id_object;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END delete_contract;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION FINAL (
      i_id_vertrag       IN   tfzgvertrag.id_vertrag%TYPE
     ,i_id_fzg_vertrag   IN   tfzgvertrag.id_fzgvertrag%TYPE
     ,i_success          IN   db_datatype.db_returnstatus%TYPE
     ,i_check_rules      IN   BOOLEAN
     ,i_store_data       IN   BOOLEAN
     ,i_init_load        IN   BOOLEAN
     ,i_object_typ       IN   ssi_datatype.ssi_object_name%TYPE DEFAULT NULL
     ,i_id_object        IN   tssi_journal.id_object%TYPE
     ,i_typ_process      IN   VARCHAR2 DEFAULT NULL
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_ret_log      db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'FINAL';
      msg_text       VARCHAR2 (500)                     DEFAULT NULL;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
       -- Aufräumarbeiten
       --
      IF i_success = db_const.db_success
      THEN
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.final: - i_success is TRUE');

         BEGIN
            /*
             Add 28.Okotber.2008
             Globale Variable, definiert in ssi_import.
             lg_no_clear = 'YES' -- Stage wird nicht gelöscht
             lg_no_clear = 'NO'  -- Stage wird gelöscht
            */
            IF ssi_import.lg_no_clear = 'YES'
            THEN
               l_ret := delete_contract (i_id_vertrag
                                        ,i_id_fzg_vertrag
                                        ,i_id_object
                                        );
            END IF;

            IF i_typ_process != ssi_const.typ_import_process.healthcheck
            THEN                                                       -- MKS 76738 - Anderes verhalten beim Healthcheck
               l_ret_log :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => ssi_const.store_success
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => 'ID_VERTRAG'
                                    ,i_message_class      => 'I'
                                    ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                    ,i_msg_text           =>    'Succesfully stored object '
                                                             || i_object_typ
                                                             || ' '
                                                             || i_id_vertrag
                                                             || '/'
                                                             || i_id_fzg_vertrag
                                                             || ' and cleaning Stage'
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );
            ELSE                                                       -- MKS 76738 - Anderes verhalten beim Healthcheck
               l_ret_log :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => ssi_const.store_success
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => 'ID_VERTRAG'
                                    ,i_message_class      => 'I'
                                    ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                    ,i_msg_text           =>    'Succesfully checked object '
                                                             || i_object_typ
                                                             || ' '
                                                             || i_id_vertrag
                                                             || '/'
                                                             || i_id_fzg_vertrag
                                                             || ' and cleaning Stage'
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_ret_log :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => '20199'
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => 'ID_VERTRAG'
                                    ,i_message_class      => 'E'
                                    ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                    ,i_msg_text           =>    'Failed to delete Object '
                                                             || i_object_typ
                                                             || ' '
                                                             || i_id_vertrag
                                                             || '/'
                                                             || i_id_fzg_vertrag
                                                             || ' from Stage'
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );
               l_ret :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => '999999'
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => ''
                                    ,i_message_class      => 'N'
                                    ,i_msg_value          => SQLERRM
                                    ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );
         END;
      ELSE
         --
         -- no success
         --
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.final: - i_success is FALSE');
         ROLLBACK;                                                                                                 --??

         IF i_typ_process != ssi_const.typ_import_process.healthcheck
         THEN                                                         -- MKS 76738 - Anderes verhalten beim Healthcheck
            l_ret_log :=
               ssi_log.store_msg (i_id_object          => i_id_object
                                 ,i_msg_code           => '20199'
                                 ,i_table_name         => 'TFZGVERTRAG'
                                 ,i_column_name        => 'ID_VERTRAG'
                                 ,i_message_class      => 'E'
                                 ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                 ,i_msg_text           =>    'Failed to store object '
                                                          || i_object_typ
                                                          || ' '
                                                          || i_id_vertrag
                                                          || '/'
                                                          || i_id_fzg_vertrag
                                                          || ' rollback all transactions'
                                 ,i_msg_modul          => lgc_modul || lc_sub_modul
                                 );
         ELSE                                                          -- MKS 76738 - Anderes verhalten beim Healthcheck
            l_ret_log :=
               ssi_log.store_msg (i_id_object          => i_id_object
                                 ,i_msg_code           => '20199'
                                 ,i_table_name         => 'TFZGVERTRAG'
                                 ,i_column_name        => 'ID_VERTRAG'
                                 ,i_message_class      => 'E'
                                 ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                 ,i_msg_text           =>    'Object '
                                                          || i_object_typ
                                                          || ' '
                                                          || i_id_vertrag
                                                          || '/'
                                                          || i_id_fzg_vertrag
                                                          || ' checked successful, but Problems were found!'
                                 ,i_msg_modul          => lgc_modul || lc_sub_modul
                                 );
         END IF;

         IF i_init_load = FALSE
         THEN
            BEGIN
               /*
                Add 28.Okotber.2008
                Globale Variable, definiert in ssi_import.
                lg_no_clear = 'YES' -- Stage wird nicht gelöscht
                lg_no_clear = 'NO'  -- Stage wird gelöscht
               */
               IF ssi_import.lg_no_clear = 'YES'
               THEN
                  l_ret := delete_contract (i_id_vertrag
                                           ,i_id_fzg_vertrag
                                           ,i_id_object
                                           );
               END IF;

               l_ret_log :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => '00001'
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => 'ID_VERTRAG'
                                    ,i_message_class      => 'I'
                                    ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                    ,i_msg_text           =>    'Succesfully deleted object '
                                                             || i_object_typ
                                                             || ' '
                                                             || i_id_vertrag
                                                             || '/'
                                                             || i_id_fzg_vertrag
                                                             || ' from stage'
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_ret_log :=
                     ssi_log.store_msg (i_id_object          => i_id_object
                                       ,i_msg_code           => '20199'
                                       ,i_table_name         => 'TFZGVERTRAG'
                                       ,i_column_name        => ''
                                       ,i_message_class      => 'E'
                                       ,i_msg_value          => i_id_vertrag || '/' || i_id_fzg_vertrag
                                       ,i_msg_text           =>    'Failed to delete Object '
                                                                || i_object_typ
                                                                || ' '
                                                                || i_id_vertrag
                                                                || '/'
                                                                || i_id_fzg_vertrag
                                                                || ' from Stage'
                                       ,i_msg_modul          => lgc_modul || lc_sub_modul
                                       );
                  l_ret :=
                     ssi_log.store_msg (i_id_object          => i_id_object
                                       ,i_msg_code           => '999999'
                                       ,i_table_name         => 'TFZGVERTRAG'
                                       ,i_column_name        => ''
                                       ,i_message_class      => 'N'
                                       ,i_msg_value          => SQLERRM
                                       ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                                       ,i_msg_modul          => lgc_modul || lc_sub_modul
                                       );
            END;
         END IF;
      END IF;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_success;
   END FINAL;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION read_stage (
      i_contr                    IN              tfzgvertrag%ROWTYPE
     ,o_tfzgv_contracts_array    OUT NOCOPY      ssi_datatype.typ_tfzgv_contracts
     ,o_tfzgkmstand_array        OUT NOCOPY      ssi_datatype.typ_tfzgkmstand
     ,o_tfzglaufleistung_array   OUT NOCOPY      ssi_datatype.typ_tfzglaufleistung
     ,o_tfzgpreis_array          OUT NOCOPY      ssi_datatype.typ_tfzgpreis
     ,o_tic_co_pack_ass_array    OUT NOCOPY      ssi_datatype.typ_tic_co_pack_ass
     ,o_tvega_i55_co_array       OUT NOCOPY      ssi_datatype.typ_tvega_i55_co
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
      l_ret          db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      lc_sub_modul   VARCHAR2 (100)                     DEFAULT 'READ_STAGE';
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
      --
      -- Vertragsdaten
      --
      l_ret :=
         fetch_data_tfzgv_contracts (o_tfzgv_contracts_array
                                    ,i_contr.id_vertrag
                                    ,i_contr.id_fzgvertrag
                                    ,i_contr.id_object
                                    );
      l_ret :=
              fetch_data_tfzgkmstand (o_tfzgkmstand_array
                                     ,i_contr.id_vertrag
                                     ,i_contr.id_fzgvertrag
                                     ,i_contr.id_object
                                     );
      l_ret :=
         fetch_data_tfzglaufleistung (o_tfzglaufleistung_array
                                     ,i_contr.id_vertrag
                                     ,i_contr.id_fzgvertrag
                                     ,i_contr.id_object
                                     );
      l_ret := fetch_data_tfzgpreis (o_tfzgpreis_array
                                    ,i_contr.id_vertrag
                                    ,i_contr.id_fzgvertrag
                                    ,i_contr.id_object
                                    );
      l_ret :=
         fetch_data_tic_co_pack_ass (o_tic_co_pack_ass_array
                                    ,i_contr.id_vertrag
                                    ,i_contr.id_fzgvertrag
                                    ,i_contr.id_object
                                    );
      l_ret :=
            fetch_data_tvega_i55_co (o_tvega_i55_co_array
                                    ,i_contr.id_vertrag
                                    ,i_contr.id_fzgvertrag
                                    ,i_contr.id_object
                                    );
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      --
      RETURN db_const.db_success;
--
   END read_stage;

--------------------------------------------------------------------------------
   FUNCTION process (
      i_check_rules    IN   BOOLEAN
     ,i_store_data     IN   BOOLEAN
     ,i_init_load      IN   BOOLEAN DEFAULT FALSE
     ,i_errorflag      IN   db_datatype.db_returnstatus%TYPE DEFAULT db_const.db_success
     ,i_id_object      IN   tssi_journal.id_object%TYPE
     ,i_object_typ     IN   ssi_datatype.ssi_object_name%TYPE DEFAULT NULL
     ,i_flag_chk_sav   IN   VARCHAR2 DEFAULT NULL
     ,i_typ_process    IN   VARCHAR2 DEFAULT NULL
     ,i_addon          in   varchar2
     ,i_checkoption    in   varchar2 default 'ALL'
   )
      RETURN db_datatype.db_returnstatus%TYPE
   IS
   
   -- FraBe 19.01.2012 MKS-106635 / REQ603: add iCC logic 
   -- FraBe 10.01.2014 MKS-130325:1 pass new IN parameter i_scope_only logic: default 'NO' to function ssi.ssi_healthcheck_addon.process
   -- FraBe 21.01.2014 MKS-130325:1 rename i_scope_only to i_checkoption with default 'ALL'
   
      la_tfzgvertrag        ssi_datatype.typ_tfzgvertrag;
      la_tfzgv_contracts    ssi_datatype.typ_tfzgv_contracts;
      la_tfzgkmstand        ssi_datatype.typ_tfzgkmstand;
      la_tfzglaufleistung   ssi_datatype.typ_tfzglaufleistung;
      la_tfzgpreis          ssi_datatype.typ_tfzgpreis;
      la_tic_co_pack_ass    ssi_datatype.typ_tic_co_pack_ass;
      la_tvega_i55_co       ssi_datatype.typ_tvega_i55_co;
      l_uid                 BOOLEAN                            DEFAULT TRUE;
      l_ret                 db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_retcheck            db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_rettoprod           db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
      l_ret_total           db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;

      TYPE typ_del IS RECORD (
         id_vertrag      tfzgvertrag.id_vertrag%TYPE
        ,id_fzgvertrag   tfzgvertrag.id_fzgvertrag%TYPE
        ,id_object       tfzgvertrag.id_object%TYPE
      );

      TYPE typ_tab_del IS TABLE OF typ_del
         INDEX BY BINARY_INTEGER;

      ltab_del              typ_tab_del;
      ltab_del_empty        typ_tab_del;
      l_i                   PLS_INTEGER                        DEFAULT 0;
      lc_sub_modul          VARCHAR2 (100)                     DEFAULT 'PROCESS';
      l_stored_in_prod      BOOLEAN                            DEFAULT FALSE;
   BEGIN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

      --
      -- Verarbeite sequentiell die Contracts
      -- in der Stage Tabelle tfzgvertrag
      --
      FOR r_contract IN (SELECT   *
                             FROM tfzgvertrag
                            WHERE id_object = i_id_object
                         ORDER BY DECODE (time_status_ssi
                                         ,'O', 1
                                         ,'N', 2
                                         ))
      LOOP
         FOR r_d IN (SELECT   *
                         FROM tfzgvertrag
                        WHERE id_object = i_id_object
                     ORDER BY DECODE (time_status_ssi
                                     ,'O', 1
                                     ,'N', 2
                                     ))
         LOOP
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'r_d GUID_CONTRACT Alt: ' || r_d.guid_contract);
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'r_d id_vertrag Alt: ' || r_d.id_vertrag);
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'r_d time_status_ssi Alt: ' || r_d.time_status_ssi);
         END LOOP;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                     , 'r_contract GUID_CONTRACT Alt: ' || r_contract.guid_contract);

         IF snt.pb_contract_ext_red.check_for_lock (i_id_vertrag         => r_contract.id_vertrag
                                                   ,i_id_fzgvertrag      => r_contract.id_fzgvertrag
                                                   ,iobjectid            => r_contract.id_object
                                                   ,i_typ_process        => i_typ_process
                                                   ) = db_const.db_fail
         THEN
            l_ret_total := db_const.db_fail;
            EXIT;                                                                 -- Exit loop if contract is blocked!!
         END IF;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                     , 'r_contract GUID_CONTRACT Neu: ' || r_contract.guid_contract);

         -- In case of ExtRed => Reset Final_Invoice_done_flag before reading stage
         -- MKS-84978; TK; 2010-02-24
         -- Des war so explizit von de Italiener bestellt.
         IF (i_object_typ = ssi_const.contract_extred_obj)
         THEN
            UPDATE ssi.tfzgvertrag
               SET fzgv_final_invoice_done = 0
             WHERE id_vertrag = r_contract.id_vertrag AND id_fzgvertrag = r_contract.id_fzgvertrag;
         END IF;

         -- liest Stage pro Contract aus
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - read stage');
         l_ret :=
            read_stage (i_contr                       => r_contract
                       ,o_tfzgv_contracts_array       => la_tfzgv_contracts
                       ,o_tfzgkmstand_array           => la_tfzgkmstand
                       ,o_tfzglaufleistung_array      => la_tfzglaufleistung
                       ,o_tfzgpreis_array             => la_tfzgpreis
                       ,o_tic_co_pack_ass_array       => la_tic_co_pack_ass
                       ,o_tvega_i55_co_array          => la_tvega_i55_co
                       );

         IF l_ret = db_const.db_fail
         THEN
            l_ret_total := db_const.db_fail;
         END IF;



         -- Führt Business Checks durch
         la_tfzgvertrag (1) := r_contract;
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - check rules');
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'GUID_CONTRACT: ' || la_tfzgvertrag (1).guid_contract);

---------------------------------- fnc_check_rules ----------------------------------------------------------------
         IF i_check_rules
         THEN
         --qerrm.trace_on (include_timestamp_in      => FALSE);
            l_ret :=
               snt.po_co.fnc_check_rules (v_tfzgvertrag_ssi           => la_tfzgvertrag
                                         ,v_tfzgv_contracts_ssi       => la_tfzgv_contracts
                                         ,v_tfzgkmstand_ssi           => la_tfzgkmstand
                                         ,v_tfzglaufleistung_ssi      => la_tfzglaufleistung
                                         ,v_tfzgpreis_ssi             => la_tfzgpreis
                                         ,v_tic_co_pack_ass_ssi       => la_tic_co_pack_ass
                                         ,v_tvega_i55_co_ssi          => la_tvega_i55_co
                                         ,ierrorflag                  => i_errorflag
                                         ,iobjectid                   => r_contract.id_object
                                         ,iobject_typ                 => i_object_typ
                                         ,iflag_chk_sav               => i_flag_chk_sav
                                         ,i_uid                       => FALSE
                                         ,ityp_process                => i_typ_process
                                         );

            IF l_ret = db_const.db_fail
            THEN
               l_ret_total := db_const.db_fail;
            END IF;
         -- MKS 76738 - Erweiteres Verhalten beim Healthcheck - Mehr checks:
          IF i_typ_process = ssi_const.typ_import_process.healthcheck and upper(i_addon) = 'YES'
          THEN
            IF ssi.ssi_healthcheck_addon.process (i_id_vertrag         => r_contract.id_vertrag
                                                 ,i_id_fzgvertrag      => r_contract.id_fzgvertrag
                                                 ,i_id_object          => r_contract.id_object
                                                 ,i_checkoption        => i_checkoption ) =
                                                                                                    db_const.db_fail
            THEN
                l_ret_total := db_const.db_fail;
            END IF;
         END IF;
         END IF;

         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                     , '##### ssi_contract.process: - check for storing data - l_ret_total: ' || l_ret_total);
-----------------------------------end fnc_check_rules-------------------------------------------------------------
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'GUID_CONTRACT: ' || la_tfzgvertrag (1).guid_contract);

---------------------------------- fnc_to_production --------------------------------------------------------------
         IF i_store_data
         THEN
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - store data :');

            IF l_ret = db_const.db_success AND i_errorflag = db_const.db_success
            THEN
               qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - go to production');
               l_ret :=
                  snt.po_co.fnc_to_production (v_tfzgvertrag_ssi           => la_tfzgvertrag
                                              ,v_tfzgv_contracts_ssi       => la_tfzgv_contracts
                                              ,v_tfzgkmstand_ssi           => la_tfzgkmstand
                                              ,v_tfzglaufleistung_ssi      => la_tfzglaufleistung
                                              ,v_tfzgpreis_ssi             => la_tfzgpreis
                                              ,v_tic_co_pack_ass_ssi       => la_tic_co_pack_ass
                                              ,v_tvega_i55_co_ssi          => la_tvega_i55_co
                                              ,iobjectid                   => r_contract.id_object
                                              ,iobject_typ                 => i_object_typ
                                              ,iflag_chk_sav               => i_flag_chk_sav
                                              );

               IF l_ret = db_const.db_fail
               THEN
                  l_ret_total := db_const.db_fail;
                  l_stored_in_prod := FALSE;
               ELSE
                  l_stored_in_prod := TRUE;
               END IF;
            END IF;
         END IF;

         ---------------------------------- end fnc_to_production ----------------------------------------------------------
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                     ,'##### ssi_contract.process: - Collect data for cleaning stage');
         l_i := l_i + 1;
         ltab_del (l_i).id_vertrag := r_contract.id_vertrag;
         ltab_del (l_i).id_fzgvertrag := r_contract.id_fzgvertrag;
         ltab_del (l_i).id_object := r_contract.id_object;
         qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - end of LOOP');
      END LOOP;

      ----------------------------------- Start cleaning the stage ---------------------------------------------------------
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', '##### ssi_contract.process: - start cleaning stage');

      IF ltab_del.COUNT > 0
      THEN
         FOR l_c IN ltab_del.FIRST .. ltab_del.LAST
         LOOP
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                        ,    'id_vertrag: '
                          || ltab_del (l_c).id_vertrag
                          || ' id_fzgvertrag: '
                          || ltab_del (l_c).id_fzgvertrag);
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG'
                        ,    'i_object_typ: '
                          || i_object_typ
                          || ' l_stored_in_prod: '
                          || CASE l_stored_in_prod
                                WHEN TRUE
                                   THEN 'WAHR'
                                WHEN FALSE
                                   THEN 'FALSCH'
                             END);

            IF    i_object_typ = ssi_const.contract_obj
               OR (i_object_typ = ssi_const.contract_trans_obj AND l_stored_in_prod = TRUE)
               OR (i_object_typ = ssi_const.contract_extred_obj AND l_stored_in_prod = TRUE)
               OR (i_object_typ = ssi_const.iCC_contract_obj AND l_stored_in_prod = TRUE)
            THEN
               l_ret :=
                  FINAL (i_id_vertrag          => ltab_del (l_c).id_vertrag
                        ,i_id_fzg_vertrag      => ltab_del (l_c).id_fzgvertrag
                        ,i_success             => l_ret
                        ,i_check_rules         => i_check_rules
                        ,i_store_data          => i_store_data
                        ,i_init_load           => i_init_load
                        ,i_object_typ          => i_object_typ
                        ,i_id_object           => ltab_del (l_c).id_object
                        ,i_typ_process         => i_typ_process
                        );

               IF l_ret = db_const.db_fail
               THEN
                  l_ret_total := db_const.db_fail;
               END IF;
            ELSIF    (    i_object_typ = ssi_const.contract_trans_obj
                      AND l_stored_in_prod = FALSE
                      AND i_flag_chk_sav = ssi_const.flag_extred_trans_chk_sav.tosave
                     )
                  OR (    i_object_typ = ssi_const.contract_extred_obj
                      AND l_stored_in_prod = FALSE
                      AND i_flag_chk_sav = ssi_const.flag_extred_trans_chk_sav.tosave
                     )
                  OR (    i_object_typ = ssi_const.iCC_contract_obj
                      AND l_stored_in_prod = FALSE
                      AND i_flag_chk_sav = ssi_const.flag_icc_trans_chk_sav.tosave
                     )
            THEN
               -- MKS-84740; TK ; 2010-02-15 NUR WENN NICHT GELOCK IST:
               -- MKS-82500; TK ; 2009-01-20 Fehlende Meldung für Abgelehnte EtxRed und Transfer eintragen.
               l_ret :=
                  ssi_log.store_msg (i_id_object          => i_id_object
                                    ,i_msg_code           => CASE i_object_typ
                                        WHEN ssi_const.contract_trans_obj
                                           THEN '40199'
                                        WHEN ssi_const.contract_extred_obj
                                           THEN '30199'
                                        WHEN ssi_const.iCC_contract_obj
                                           THEN '70199'
                                     END
                                    ,i_table_name         => 'TFZGVERTRAG'
                                    ,i_column_name        => 'ID_VERTRAG'
                                    ,i_message_class      => 'E'
                                    ,i_msg_value          =>    ltab_del (l_c).id_vertrag
                                                             || '/'
                                                             || ltab_del (l_c).id_fzgvertrag
                                    ,i_msg_text           =>    'Failed to '
                                                             || i_flag_chk_sav
                                                             || ' store object '
                                                             || i_object_typ
                                                             || ' '
                                                             || ltab_del (l_c).id_vertrag
                                                             || '/'
                                                             || ltab_del (l_c).id_fzgvertrag
                                                             || ' rollback all transactions.'
                                    ,i_msg_modul          => lgc_modul || lc_sub_modul
                                    );

               /*
                 humermar -> MKS: 63085
                 Stage für das entsprechende Object(id_object) leeren da i_errorflag Fehler liefert
               */
               BEGIN
                  l_ret :=
                     delete_contract (ltab_del (l_c).id_vertrag
                                     ,ltab_del (l_c).id_fzgvertrag
                                     ,ltab_del (l_c).id_object
                                     );

                  IF l_ret = db_const.db_fail
                  THEN
                     l_ret_total := db_const.db_fail;
                  END IF;
               END;
            END IF;
         END LOOP;

         ltab_del := ltab_del_empty;
         l_i := 0;
      END IF;

      ------------------------------------ End of cleaning Stage -----------------------------------------------------------
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN l_ret_total;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret :=
            ssi_log.store_msg (i_id_object          => i_id_object
                              ,i_msg_code           => '99999'
                              ,i_table_name         => 'TFZGVERTRAG'
                              ,i_column_name        => ''
                              ,i_message_class      => 'N'
                              ,i_msg_value          => SQLERRM
                              ,i_msg_text           => DBMS_UTILITY.format_error_backtrace
                              ,i_msg_modul          => lgc_modul || lc_sub_modul
                              );
         RETURN db_const.db_fail;
   END process;

------------------------------------------------------------------------------------------------------------------------
   FUNCTION whoami
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision: 1.2 $';
   END whoami;
------------------------------------------------------------------------------------------------------------------------
END ssi_contract;
/