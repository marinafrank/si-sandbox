CREATE OR REPLACE PACKAGE BODY SSI.ssi_force_flag
IS

-- FraBe 19.01.2012 MKS-106635 / REQ603 / add ssi_const.xml_object.icc_contract / .icc_custinv differentation within some code
-- FraBe 20.02.2012 MKS-11534:3 / REQ603 / check_transaction_id: populate i_tablename bei einem iCC store_msg - aufruf

  lgc_modul   VARCHAR2 (100) DEFAULT 'SSI_FORCE_FLAG.';

  FUNCTION delete_trans_object (i_id_trans_id IN tssi_transaction_id.id_trans_id%TYPE)
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id: GUID of the TSSI_Transaction_ID object to be deleted
--    Return bei Funktionen
--      db_const.db_success :  Object deleted
--      db_const.db_fail    :  object not deleted
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul   VARCHAR2 (100) DEFAULT 'delete_object';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    DELETE FROM tssi_transaction_id
    WHERE       tssi_transaction_id.id_trans_id = i_id_trans_id;

    COMMIT;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RAISE;
      RETURN db_const.db_fail;
  END delete_trans_object;

--------------------------------------------------------------------------------
  FUNCTION delete_multiple_cust_objects (
    i_id_customer      tssi_transaction_id.id_customer%TYPE
   ,i_transaction_id   tssi_transaction_id.transaction_id%TYPE
  )
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id: GUID of the TSSI_Transaction_ID object to be deleted
--    Return bei Funktionen
--      db_const.db_success :  Object deleted
--      db_const.db_fail    :  object not deleted
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul   VARCHAR2 (100) DEFAULT 'delete_multiple_cust_objects';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    DELETE FROM tssi_transaction_id t
    WHERE       id_customer = i_id_customer
    AND         transaction_id < i_transaction_id
    AND         NOT EXISTS (SELECT id_object
                            FROM   tssi_lock_ert l
                            WHERE  l.id_object = t.id_object);

    COMMIT;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RETURN db_const.db_fail;
  END delete_multiple_cust_objects;

--------------------------------------------------------------------------------
  FUNCTION delete_multiple_cust_invoices (
    i_ci_invoice_ext_id   tssi_transaction_id.ci_invoice_ext_id%TYPE
   ,i_transaction_id      tssi_transaction_id.transaction_id%TYPE
  )
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id: GUID of the TSSI_Transaction_ID object to be deleted
--    Return bei Funktionen
--      db_const.db_success :  Object deleted
--      db_const.db_fail    :  object not deleted
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul   VARCHAR2 (100) DEFAULT 'DELETE_MULTIPLE_CUST_INVOICES';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    DELETE FROM tssi_transaction_id t
    WHERE       ci_invoice_ext_id = i_ci_invoice_ext_id
    AND         transaction_id < i_transaction_id
    AND         NOT EXISTS (SELECT id_object
                            FROM   tssi_lock_ert l
                            WHERE  l.id_object = t.id_object);

    COMMIT;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RETURN db_const.db_fail;
  END delete_multiple_cust_invoices;

-------------------------------------------------------------------------------
  FUNCTION delete_multiple_cont_objects (
    i_id_vertrag       tssi_transaction_id.id_vertrag%TYPE
   ,i_id_fzgvertrag    tssi_transaction_id.id_fzgvertrag%TYPE
   ,i_transaction_id   tssi_transaction_id.transaction_id%TYPE
  )
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id: GUID of the TSSI_Transaction_ID object to be deleted
--    Return bei Funktionen
--      db_const.db_success :  Object deleted
--      db_const.db_fail    :  object not deleted
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul   VARCHAR2 (100) DEFAULT 'delete_multiple_cont_objects';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_vertrag: ' || i_id_vertrag);
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_id_fzgvertrag: ' || i_id_fzgvertrag);
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'i_transaction_id: ' || i_transaction_id);

    DELETE FROM tssi_transaction_id t
    WHERE       id_vertrag = i_id_vertrag
    AND         id_fzgvertrag = i_id_fzgvertrag
    AND         transaction_id < i_transaction_id
    AND         t.object_type = ssi_const.xml_object.contract;

    COMMIT;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RETURN db_const.db_fail;
  END delete_multiple_cont_objects;

-------------------------------------------------------------------------------
  FUNCTION load_object (i_id_trans_id IN tssi_transaction_id.id_trans_id%TYPE, i_id_object IN tssi_transaction_id.id_object%TYPE)
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--  moves an File from archve dir to Inbox and starts the import process again
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id:  GUID of the TSSI_Transaction_ID object to be reimported
--    Return bei Funktionen
--      db_const.db_success :
--      db_const.db_fail    :
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    l_filename        tssi_io_file.io_file_name%TYPE;
    l_max_id_object   tssi_io_object.id_object%TYPE;
    l_id_io_file      tssi_io_file.id_io_file%TYPE;
    lc_sub_modul      VARCHAR2 (100)                     DEFAULT 'load_object';
    l_ret             db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    IF ssi_import.get_filename (o_filename       => l_filename
                               ,o_id_io_file     => l_id_io_file
                               ,i_id_object      => i_id_object
                               ) = db_const.db_success
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'l_filename: ' || l_filename || ' l_id_io_file: ' || l_id_io_file);
      l_ret := ssi_file.move_to_inbox (i_id_io_file     => l_id_io_file);
      l_ret := ssi_import.process (i_file_name     => l_filename, i_init_load => FALSE);                                      -- , i_debug => 'YES');

      SELECT MAX (f.id_object)
      INTO   l_max_id_object
      FROM   tssi_io_object f
      WHERE  f.id_io_file = (SELECT MAX (id_io_file)
                             FROM   tssi_io_file
                             WHERE  io_file_name = l_filename);

      IF ssi_ack.test_success (l_max_id_object) = db_const.db_bool_true
      THEN
        l_ret :=
          ssi_log.store_msg (i_id_object         => l_max_id_object
                            ,i_msg_code          => ssi_const.store_success
                            ,i_table_name        => ''
                            ,i_column_name       => ''
                            ,i_message_class     => 'I'
                            ,i_msg_value         => ''
                            ,i_msg_text          => 'Succesfully stored object: ' || i_id_object || ' in a new transaction by force flag with object id: '
                                                    || l_max_id_object
                            ,i_msg_modul         => lgc_modul || lc_sub_modul);
        l_ret :=
          ssi_log.store_msg (i_id_object         => i_id_object
                            ,i_msg_code          => ssi_const.store_success
                            ,i_table_name        => ''
                            ,i_column_name       => ''
                            ,i_message_class     => 'I'
                            ,i_msg_value         => ''
                            ,i_msg_text          => 'Succesfully stored object: ' || i_id_object || ' in a new transaction by force flag with object id: '
                                                    || l_max_id_object
                            ,i_msg_modul         => lgc_modul || lc_sub_modul
                            );
        l_ret := ssi_log.update_file_status (i_id_io_file         => l_id_io_file, i_io_file_status => ssi_const.file_status.ok);
        l_ret := delete_trans_object (i_id_trans_id     => i_id_trans_id);
      ELSE
        l_ret :=
          ssi_log.store_msg (i_id_object         => i_id_object
                            ,i_msg_code          => '00199'
                            ,i_table_name        => ''
                            ,i_column_name       => ''
                            ,i_message_class     => 'E'
                            ,i_msg_value         => SQLERRM
                            ,i_msg_text          => 'Could not force Object : ' || i_id_object|| ' No Force flag found!'
                            ,i_msg_modul         => lgc_modul || lc_sub_modul
                            );
      END IF;
    ELSE
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'get_filename has error');
      l_ret := db_const.db_fail;
    END IF;

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN l_ret;
  EXCEPTION
    WHEN OTHERS
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', SQLERRM);
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RETURN db_const.db_fail;
  END;

--------------------------------------------------------------------------------
  FUNCTION set_force_flag (i_id_trans_id IN tssi_transaction_id.id_trans_id%TYPE)
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_id_trans_id: GGUID of the TSSI_Transaction_ID object to be flagged
--    Return bei Funktionen
--      db_const.db_success :  Flag wurde gesetzt
--      db_const.db_fail    :  Flag wurde nicht gesetzt
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul   VARCHAR2 (100) DEFAULT 'set_force_flag';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    UPDATE tssi_transaction_id
    SET tssi_transaction_id.force_flag = 1
    WHERE  tssi_transaction_id.id_trans_id = i_id_trans_id;

    COMMIT;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE;
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
      RETURN db_const.db_fail;
  END;

--------------------------------------------------------------------------------
  FUNCTION check_transaction_id (
    i_id_object         IN   tssi_transaction_id.id_object%TYPE
   ,i_transaction_id    IN   tssi_transaction_id.transaction_id%TYPE
   ,i_time_status_ssi   IN   tfzgvertrag.time_status_ssi%TYPE DEFAULT NULL
  )
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--       i_id_object : Object id of loaded object
--    Return bei Funktionen
--      db_const.db_success : TSSI_Transaction_ID ist abgearbeitet
--      db_const.db_fail    : Es trat ein Fehler auf
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-- FraBe 20.02.2012 MKS-11534:3 / REQ603: populate i_tablename bei einem iCC store_msg - aufruf
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_object_type         tssi_io_object.xml_object%TYPE;
    v_id_vertrag          tfzgvertrag.id_vertrag%TYPE                DEFAULT NULL;
    v_id_fzgvertrag       tfzgvertrag.id_fzgvertrag%TYPE             DEFAULT NULL;
    v_id_customer         tcustomer.id_customer%TYPE                 DEFAULT NULL;
    v_ci_invoice_ext_id   tcustomer_invoice.ci_invoice_ext_id%TYPE   DEFAULT NULL;
    l_ret                 db_datatype.db_returnstatus%TYPE           DEFAULT db_const.db_success;
    l_retlog              db_datatype.db_returnstatus%TYPE           DEFAULT db_const.db_success;
    lc_sub_modul          VARCHAR2 (100)                             DEFAULT 'check_transaction_id';
    v_forced              tssi_transaction_id.force_flag%TYPE;
    v_exist_trans_id      tssi_transaction_id.transaction_id%TYPE;
    v_id_trans_id         tssi_transaction_id.id_trans_id%TYPE;
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    -- get object type
    SELECT xml_object
    INTO   v_object_type
    FROM   tssi_io_object
    WHERE  id_object = i_id_object;

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Object type is ' || TO_CHAR (v_object_type));

    -- get object Keys
    IF v_object_type = ssi_const.xml_object.customer
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Check Transaction_id of Customer');

      SELECT id_customer
      INTO   v_id_customer
      FROM   tcustomer
      WHERE  id_object = i_id_object;

      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'ID_Customer:' || TO_CHAR (v_id_customer));

      -- get old transaction id
      BEGIN
        SELECT transaction_id
        INTO   v_exist_trans_id
        FROM   snt.tcustomer
        WHERE  id_customer = v_id_customer;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          v_exist_trans_id := 0;
      END;


    ELSIF    (v_object_type = ssi_const.xml_object.contract)
          OR (v_object_type = ssi_const.xml_object.conext)
          OR (v_object_type = ssi_const.xml_object.contrans)
          OR (v_object_type = ssi_const.xml_object.icc_contract)
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Check Transaction_id of Contract');

      SELECT id_vertrag, id_fzgvertrag
      INTO   v_id_vertrag, v_id_fzgvertrag
      FROM   tfzgvertrag
      WHERE  id_object = i_id_object
      AND    (   time_status_ssi IS NULL
              OR time_status_ssi = i_time_status_ssi);

      -- get old transaction id
      BEGIN
        SELECT transaction_id
        INTO   v_exist_trans_id
        FROM   snt.tfzgvertrag
        WHERE  id_vertrag = v_id_vertrag
        AND    id_fzgvertrag = v_id_fzgvertrag;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          v_exist_trans_id := 0;
      END;
    ELSIF v_object_type = ssi_const.xml_object.custinv
       or v_object_type = ssi_const.xml_object.icc_custinv
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Check Transaction_id of Customer Invoice');

      SELECT ci_invoice_ext_id
      INTO   v_ci_invoice_ext_id
      FROM   tcustomer_invoice
      WHERE  id_object = i_id_object;

      -- get old transaction id
      BEGIN
        SELECT transaction_id
        INTO   v_exist_trans_id
        FROM   snt.tcustomer_invoice
        WHERE  ci_invoice_ext_id = v_ci_invoice_ext_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          v_exist_trans_id := 0;
      END;
    ELSE
      l_ret := db_const.db_fail;
    END IF;

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'New Transaction_id:' || i_transaction_id);
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Existing Transaction_id:' || REPLACE (TO_CHAR (v_exist_trans_id)
                                                                                                ,'0'
                                                                                                ,' not found'
                                                                                                ));
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Excpected Transaction_id:' || TO_CHAR (v_exist_trans_id + 1));

    IF i_transaction_id <> v_exist_trans_id + 1                                       -- new transaction ID is not old transaction id increased by one
    THEN
      BEGIN
        qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Transaction ID problem detected - looking for force flag...');

        -- check for forcing
        SELECT force_flag, id_trans_id
        INTO   v_forced, v_id_trans_id
        FROM   tssi_transaction_id
        WHERE  (   (    id_vertrag = v_id_vertrag
                    AND id_fzgvertrag = v_id_fzgvertrag)
                OR (id_customer = v_id_customer)
                OR (ci_invoice_ext_id = v_ci_invoice_ext_id)
               )
        AND    transaction_id = i_transaction_id
        AND ROWNUM <2
        ORDER by id_object;  -- Prevent too_many_rows!

        qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'Force Flag is: ' || TO_CHAR (v_forced));

        IF i_transaction_id < v_exist_trans_id + 1
        THEN
          l_retlog :=
            ssi.ssi_log.store_msg (i_id_object         => i_id_object
                                  ,i_msg_code          => '00101'
                                  ,i_table_name        => case v_object_type
                                                                  when ssi_const.xml_object.icc_contract then 'TFZGVERTRAG'
                                                                  when ssi_const.xml_object.icc_custinv  then 'TCUSTOMER_INVOICE'
                                                                  else ''
                                                             end
                                  ,i_column_name       => 'TRANSACTION_ID'
                                  ,i_message_class     => 'N'
                                  ,i_msg_value         => i_transaction_id
                                  ,i_msg_text          =>    'Transaction_ID is lower than expected. Delivered: '
                                                          || i_transaction_id
                                                          || ' - Expected: '
                                                          || TO_CHAR ( v_exist_trans_id + 1 )
                                                          || case v_object_type
                                                                  when ssi_const.xml_object.icc_contract then null
                                                                  when ssi_const.xml_object.icc_custinv  then null
                                                                  else ' Object must not be forced!'
                                                             end
                                  ,i_msg_modul         => lgc_modul || lc_sub_modul
                                  );
          qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'FAILED - Object is not forced');

          l_ret := db_const.db_fail;
        ELSE


          IF v_forced = 0                                                                                                     -- object is NOT forced
          THEN
            l_retlog :=
              ssi.ssi_log.store_msg (i_id_object         => i_id_object
                                    ,i_msg_code          => '00101'
                                    ,i_table_name        => case v_object_type
                                                                  when ssi_const.xml_object.icc_contract then 'TFZGVERTRAG'
                                                                  when ssi_const.xml_object.icc_custinv  then 'TCUSTOMER_INVOICE'
                                                                  else ''
                                                             end
                                    ,i_column_name       => 'TRANSACTION_ID'
                                    ,i_message_class     => 'N'
                                    ,i_msg_value         => i_transaction_id
                                    ,i_msg_text          =>    'Transaction_ID is not matching. Delivered: '
                                                            || i_transaction_id
                                                            || ' - Expected: '
                                                            || TO_CHAR ( v_exist_trans_id + 1 )
                                                          || case v_object_type
                                                                  when ssi_const.xml_object.icc_contract then null
                                                                  when ssi_const.xml_object.icc_custinv  then null
                                                                  else ' No Force flag is set -> No Forcing!'
                                                             end
                                    ,i_msg_modul         => lgc_modul || lc_sub_modul
                                    );

            UPDATE TSSI_TRANSACTION_ID
            Set id_object = i_id_object
            where id_trans_id = v_id_trans_id;
            commit;

            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'FAILED - Object is not forced');
            l_ret := db_const.db_fail;
          ELSE
            -- Object should be forced - Check will be ok
            qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'SUCCESS - Object is forced sucessfully.');

            DELETE FROM tssi_transaction_id t
            WHERE       id_trans_id = v_id_trans_id
            AND         object_type NOT IN ( ssi_const.xml_object.conext
                                           , ssi_const.xml_object.contrans
                                           , ssi_const.xml_object.icc_contract
                                           , ssi_const.xml_object.icc_custinv );

            COMMIT;
          END IF;
        END IF;




      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'FAILED - No Force flag found');
          l_retlog :=
            ssi.ssi_log.store_msg (i_id_object         => i_id_object
                                  ,i_msg_code          => '00101'
                                  ,i_table_name        => case v_object_type
                                                               when ssi_const.xml_object.icc_contract then 'TFZGVERTRAG'
                                                               when ssi_const.xml_object.icc_custinv  then 'TCUSTOMER_INVOICE'
                                                               else ''
                                                          end
                                  ,i_column_name       => 'TRANSACTION_ID'
                                  ,i_message_class     => 'N'
                                  ,i_msg_value         => i_transaction_id
                                  ,i_msg_text          =>    'Transaction_ID is not matching. Delivered: '
                                                          || i_transaction_id
                                                          || ' - Expected: '
                                                          || TO_CHAR (v_exist_trans_id + 1)
                                                          || case v_object_type
                                                                  when ssi_const.xml_object.icc_contract then null
                                                                  when ssi_const.xml_object.icc_custinv  then null
                                                                  else ' File can be possibly forced.'
                                                             end
                                  ,i_msg_modul         => lgc_modul || lc_sub_modul
                                  );

          INSERT INTO tssi_transaction_id
                      (id_trans_id
                      ,id_customer
                      ,id_vertrag
                      ,id_fzgvertrag
                      ,ci_invoice_ext_id
                      ,object_type
                      ,transaction_id
                      ,id_object
                      )
          VALUES      (SYS_GUID ()
                      ,v_id_customer
                      ,v_id_vertrag
                      ,v_id_fzgvertrag
                      ,v_ci_invoice_ext_id
                      ,v_object_type
                      ,i_transaction_id
                      ,i_id_object
                      );

          COMMIT;
          qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'FAILED - Entry in TSSI_TRANSACTION_ID created');
          l_ret := db_const.db_fail;
      END;
    ELSE
      -- Transaction_id is was expected
      NULL;
    END IF;

    --
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN l_ret;
    
    EXCEPTION
     WHEN NO_DATA_FOUND
        THEN
          qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'FAILED - No Force flag found');
          NULL;  -- no forcing required
        WHEN OTHERS
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RAISE;
      RETURN db_const.db_fail;
  END;

--------------------------------------------------------------------------------
  FUNCTION process
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      db_const.db_success : TSSI_Transaction_ID ist abgearbeitet
--      db_const.db_fail    : Es trat ein Fehler auf
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    l_ret                      db_datatype.db_returnstatus%TYPE             DEFAULT db_const.db_success;
    l_last_customer_id         tssi_transaction_id.id_customer%TYPE;
    l_last_vertrag_id          tssi_transaction_id.id_vertrag%TYPE;
    l_last_fzgvertrag_id       tssi_transaction_id.id_fzgvertrag%TYPE;
    l_last_ci_invoice_ext_id   tssi_transaction_id.ci_invoice_ext_id%TYPE;
    l_actual_transaction_id    tssi_transaction_id.transaction_id%TYPE;
    lc_sub_modul               VARCHAR2 (100)                               DEFAULT 'PROCESS';
  BEGIN
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'proceed customers');

    --
    -- Proceeding Customers
    --
    FOR r_cust IN (SELECT   id_trans_id, id_customer, transaction_id, force_flag, id_object
                   FROM     tssi_transaction_id a
                   WHERE    object_type = ssi_const.xml_object.customer
                   --  and      id_trans_id = i_id_trans_id
                   ORDER BY id_customer
                           ,transaction_id)
    LOOP
      IF r_cust.force_flag = 1
      THEN
        IF load_object (i_id_trans_id     => r_cust.id_trans_id, i_id_object => r_cust.id_object) = db_const.db_success
        THEN
          -- store last processed customer_id
          l_last_customer_id := r_cust.id_customer;
          -- remove all objects with lower transaction ID of same customer
          l_ret := delete_multiple_cust_objects (i_id_customer        => l_last_customer_id, i_transaction_id => r_cust.transaction_id);
        END IF;
      ELSE
        IF r_cust.id_customer = l_last_customer_id
        THEN                                                                              -- customer is already forced and was processed just before
          -- get curretn transaction_id out of snt.tcustomer
          SELECT transaction_id
          INTO   l_actual_transaction_id
          FROM   snt.tcustomer
          WHERE  id_customer = r_cust.id_customer;

          IF r_cust.transaction_id = l_actual_transaction_id + 1
          THEN
            IF load_object (i_id_trans_id     => r_cust.id_trans_id, i_id_object => r_cust.id_object) = db_const.db_success
            THEN
              -- store last processed customer_id
              l_last_customer_id := r_cust.id_customer;
              -- remove all objects with lower transaction ID of the same customer
              l_ret := delete_multiple_cust_objects (i_id_customer        => l_last_customer_id, i_transaction_id => r_cust.transaction_id);
            END IF;
          ELSE
            NULL;                                                                               -- NOTE: skip customer entry in TSSI_TRANSACTION_ID =
          END IF;                                                                                        -- No force flag but increased Transaction ID
        ELSE
          NULL;                                                                                   -- NOTE: skip customer entry in TSSI_TRANSACTION_ID
        END IF;
      END IF;                                                                                                                            -- Force Flag
    END LOOP;                                                                                                               -- end of customer process

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'proceed contracts');

    --
    -- Proceeding Contracts
    --
    FOR r_cont IN (SELECT   id_trans_id, id_vertrag, id_fzgvertrag, transaction_id, force_flag, id_object
                   FROM     tssi_transaction_id a
                   WHERE    object_type IN (ssi_const.xml_object.contract, ssi_const.xml_object.conext, ssi_const.xml_object.contrans)
                   --     and      id_trans_id = i_id_trans_id
                   ORDER BY id_vertrag
                           ,id_fzgvertrag
                           ,transaction_id)
    LOOP
      IF r_cont.force_flag = 1
      THEN
        IF load_object (i_id_trans_id     => r_cont.id_trans_id, i_id_object => r_cont.id_object) = db_const.db_success
        THEN
          -- store last processed Contract_id
          l_last_vertrag_id := r_cont.id_vertrag;
          l_last_fzgvertrag_id := r_cont.id_fzgvertrag;
          -- remove all objects with lower transaction ID of same Contract
          l_ret :=
            delete_multiple_cont_objects (i_id_vertrag         => l_last_vertrag_id
                                         ,i_id_fzgvertrag      => l_last_fzgvertrag_id
                                         ,i_transaction_id     => r_cont.transaction_id
                                         );
        END IF;
      ELSE
        IF     r_cont.id_vertrag = l_last_vertrag_id
           AND r_cont.id_fzgvertrag = l_last_fzgvertrag_id
        THEN                                                                               -- Contract is already forced and was processed just before
          -- get curretn transaction_id out of snt.tContract
          SELECT transaction_id
          INTO   l_actual_transaction_id
          FROM   snt.tfzgvertrag
          WHERE  id_vertrag = r_cont.id_vertrag
          AND    id_fzgvertrag = r_cont.id_fzgvertrag;

          IF r_cont.transaction_id = l_actual_transaction_id + 1
          THEN
            IF load_object (i_id_trans_id     => r_cont.id_trans_id, i_id_object => r_cont.id_object) = db_const.db_success
            THEN
              -- store last processed Contract_id
              l_last_vertrag_id := r_cont.id_vertrag;
              l_last_fzgvertrag_id := r_cont.id_fzgvertrag;
              -- remove all objects with lower transaction ID of same Contract
              l_ret :=
                delete_multiple_cont_objects (i_id_vertrag         => l_last_vertrag_id
                                             ,i_id_fzgvertrag      => l_last_fzgvertrag_id
                                             ,i_transaction_id     => r_cont.transaction_id
                                             );
            END IF;
          ELSE
            NULL;                                                                               -- NOTE: skip Contract entry in TSSI_TRANSACTION_ID =
          END IF;                                                                                        -- No force flag but increased Transaction ID
        ELSE
          NULL;                                                                                   -- NOTE: skip Contract entry in TSSI_TRANSACTION_ID
        END IF;
      END IF;                                                                                                                            -- Force Flag
    END LOOP;                                                                                                               -- end of Contract process

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'proceed customer invoices');

    --
    -- Proceeding Customer Invoices
    --
    FOR r_cust IN (SELECT   id_trans_id, ci_invoice_ext_id, transaction_id, force_flag, id_object
                   FROM     tssi_transaction_id a
                   WHERE    object_type = ssi_const.xml_object.custinv
                   --  and      id_trans_id = i_id_trans_id
                   ORDER BY ci_invoice_ext_id
                           ,transaction_id)
    LOOP
      IF r_cust.force_flag = 1
      THEN
        IF load_object (i_id_trans_id     => r_cust.id_trans_id, i_id_object => r_cust.id_object) = db_const.db_success
        THEN
          -- store last processed customer_id
          l_last_ci_invoice_ext_id := r_cust.ci_invoice_ext_id;
          -- remove all objects with lower transaction ID of same customer
          l_ret := delete_multiple_cust_invoices (i_ci_invoice_ext_id     => l_last_ci_invoice_ext_id, i_transaction_id => r_cust.transaction_id);
        END IF;
      ELSE
        IF r_cust.ci_invoice_ext_id = l_last_ci_invoice_ext_id
        THEN                                                                              -- customer is already forced and was processed just before
          -- get curretn transaction_id out of snt.tcustomer
          SELECT transaction_id
          INTO   l_actual_transaction_id
          FROM   snt.tcustomer_invoice
          WHERE  ci_invoice_ext_id = r_cust.ci_invoice_ext_id;

          IF r_cust.transaction_id = l_actual_transaction_id + 1
          THEN
            IF load_object (i_id_trans_id     => r_cust.id_trans_id, i_id_object => r_cust.id_object) = db_const.db_success
            THEN
              -- store last processed customer_id
              l_last_ci_invoice_ext_id := r_cust.ci_invoice_ext_id;
              -- remove all objects with lower transaction ID of the same customer
              l_ret := delete_multiple_cust_invoices (i_ci_invoice_ext_id     => l_last_ci_invoice_ext_id, i_transaction_id => r_cust.transaction_id);
            END IF;
          ELSE
            NULL;                                                                               -- NOTE: skip customer entry in TSSI_TRANSACTION_ID =
          END IF;                                                                                        -- No force flag but increased Transaction ID
        ELSE
          NULL;                                                                                   -- NOTE: skip customer entry in TSSI_TRANSACTION_ID
        END IF;
      END IF;                                                                                                                            -- Force Flag
    END LOOP;                                                                                                               -- end of customer process

    -- TODO
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****');
    RETURN db_const.db_success;
  END process;

--------------------------------------------------------------------------------
  FUNCTION delete_object (i_id_io_file IN tssi_io_file.id_io_file%TYPE)
    RETURN db_datatype.db_returnstatus%TYPE
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--      i_file_name: Filename to "delete"
--    Return bei Funktionen
--      db_const.db_success :  Object deleted
--      db_const.db_fail    :  object not deleted
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgef?hrten Plausibilit?pr?fungen
--    Auswirkungen auf den Bildschirm
--    durchgef?hrten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
  IS
    lc_sub_modul             VARCHAR2 (100)                     DEFAULT 'delete_object';
    invalid_file_operation   EXCEPTION;
    v_id_object              tssi_io_object.id_object%TYPE;
    l_ret                    db_datatype.db_returnstatus%TYPE   DEFAULT db_const.db_success;
    error_trace_status       BOOLEAN;
    PRAGMA AUTONOMOUS_TRANSACTION;
    PRAGMA EXCEPTION_INIT (invalid_file_operation, -29283);
  BEGIN
    error_trace_status := qerrm.error_trace_enabled;
    qerrm.trace_on;
    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****');

    BEGIN
      l_ret := ssi_file.move_to_deleted (i_id_io_file);
    EXCEPTION
      WHEN invalid_file_operation
      THEN
        qerrm.TRACE (lgc_modul || lc_sub_modul || ' - DEBUG', 'INVALID_FILE_OPERATION - ' || i_id_io_file);                     -- File was not found
    END;

    BEGIN

    DELETE FROM tssi_transaction_id a
    WHERE       a.id_object IN (
                  SELECT id_object
                  FROM   tssi_io_file f
                        ,tssi_io_object o
                  WHERE  f.id_io_file = o.id_io_file
                  AND    f.id_io_file = i_id_io_file
                  AND    xml_object <> 7
                  AND    o.file_object = ssi_const.file_object.real_object);

      UPDATE tssi_io_file
      SET io_file_status = 'D'
      WHERE  io_file_name = (SELECT io_file_name
                             FROM   tssi_io_file
                             WHERE  id_io_file = i_id_io_file)
      AND    io_file_status = 'E';

      COMMIT;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;                                                                                                                            -- alles ok.
    END;

    qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****  l_ret:' || l_ret);

    IF error_trace_status = FALSE
    THEN
      qerrm.trace_off;
    END IF;

    RETURN l_ret;
  EXCEPTION
    WHEN OTHERS
    THEN
      qerrm.TRACE (lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION OTHERS');
      RAISE;
      RETURN db_const.db_fail;
  END delete_object;

--------------------------------------------------------------------------------
  FUNCTION whoami
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN '$Revision: 1.2 $';
  END whoami;
--------------------------------------------------------------------------------
END ssi_force_flag;
/