/* Formatted on 16.10.2014 13:13:42 (QP5 v5.185.11230.41888) */
-- DataCleansing_DEF5542_DEF5543_DEF5544_EnlargeContractRuntime.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-10-16; TK; MKS-135211:1

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   DEFINE GL_SCRIPTNAME         = DataCleansing_080_DEF5542_DEF5543_DEF5544_EnlargeContractRuntime
   DEFINE GL_LOGFILETYPE        = LOG           -- logfile name extension. [log|csv|txt]  {csv causes less info in logfile}
   DEFINE GL_SCRIPTFILETYPE     = SQL           -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   DEFINE L_MAJOR_MIN           = 2
   DEFINE L_MINOR_MIN           = 8
   DEFINE L_REVISION_MIN        = 1
   DEFINE L_BUILD_MIN           = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   DEFINE L_SOLLUSER            = SNT
   DEFINE L_SYSDBA_PRIV_NEEDED  = FALSE    -- false or true

  -- country specification
   DEFINE L_MPC_CHECK           = TRUE     -- false or true
   DEFINE L_MPC_SOLL            = 'MBBEL'  -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   DEFINE L_VEGA_CODE_SOLL      = '51331'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb:
                                           -- define L_MPC_SOLL       = 'MBBEL,MBCH'
                                           -- define L_VEGA_CODE_SOLL = '51331,57129'

  -- Reexecution
   DEFINE  L_REEXEC_FORBIDDEN   = FALSE         -- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   DEFINE L_DB_LOGGING_ENABLE   = TRUE          -- Are we logging to the DB? -> false or true
   DEFINE L_LOGFILE_REQUIRED    = TRUE          -- Logfile required? -> false or true

--
--
-- END SCRIPT PARAMETERIZATION
--
--
-- HINT: To increase local variables use following code:
-- {:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;} in pl/SQL or
-- {exec :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1} in SQL

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################

SET ECHO         OFF
SET VERIFY       OFF
SET FEEDBACK     OFF
SET TIMING       OFF
SET HEADING      OFF
SET SQLPROMPT    ''
SET TRIMSPOOL    ON
SET TERMOUT      ON
SET SERVEROUTPUT ON  SIZE UNLIMITED FORMAT WRAPPED
SET LINES        999
SET PAGES        0

VARIABLE L_SCRIPTNAME           VARCHAR2 ( 200 CHAR );
VARIABLE L_ERROR_OCCURED        NUMBER;
VARIABLE L_DATAERRORS_OCCURED   NUMBER;
VARIABLE L_DATAWARNINGS_OCCURED NUMBER;
VARIABLE L_DATASUCCESS_OCCURED  NUMBER;
VARIABLE nachricht              VARCHAR2 ( 200 CHAR );
EXEC :L_SCRIPTNAME              := '&&GL_SCRIPTNAME..&&GL_LOGFILETYPE'
EXEC :L_ERROR_OCCURED           := 0
EXEC :L_DATAERRORS_OCCURED      := 0
EXEC :L_DATAWARNINGS_OCCURED    := 0
EXEC :L_DATASUCCESS_OCCURED     := 0

SPOOL &GL_SCRIPTNAME..&GL_LOGFILETYPE

DECLARE
   L_LAST_EXEC_TIME   VARCHAR2 ( 30 CHAR );
BEGIN
   IF UPPER ( '&&GL_LOGFILETYPE' ) <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line (   'Script executed on: '
                            || TO_CHAR ( SYSDATE, 'DD.MM.YYYY HH24:MI:SS' ) );
      DBMS_OUTPUT.put_line ( 'Script executed by: &&_USER' );
      DBMS_OUTPUT.put_line ( 'Script run on DB  : &&_CONNECT_IDENTIFIER' );
      DBMS_OUTPUT.put_line (   'Database Country  : '
                            || snt.get_TGLOBAL_SETTINGS ( 'SIRIUS',
                                                          'Setting',
                                                          'MPCName',
                                                          'NoMPCName found'
                                                         ) );
      DBMS_OUTPUT.put_line (   'Database dump date: '
                            || snt.get_TGLOBAL_SETTINGS ( 'DB',
                                                          'DUMP',
                                                          'DATE',
                                                          'not found'
                                                         ) );

      BEGIN
         SELECT TO_CHAR ( MAX ( LE_CREATED ), 'DD.MM.YYYY HH24:MI:SS' )
           INTO L_LAST_EXEC_TIME
           FROM snt.TLOG_EVENT e
          WHERE     GUID_LA = '10'                                                                                  -- maintenance
                AND EXISTS
                       (SELECT NULL
                          FROM snt.TLOG_EVENT_PARAM ep
                         WHERE     ep.LEP_VALUE = :L_SCRIPTNAME
                               AND ep.GUID_LE = e.GUID_LE);

         DBMS_OUTPUT.put_line (   'This script was already executed on '
                               || L_LAST_EXEC_TIME );
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END IF;
END;
/


PROMPT

WHENEVER SQLERROR EXIT sql.sqlcode

DECLARE
   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen

   L_SYSDBA_PRIV      VARCHAR2 ( 1 CHAR );

   -- 2) unter welchem user muß das script laufen?

   L_ISTUSER          VARCHAR2 ( 30 CHAR ) := USER;

   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -):


   L_MAJOR_IST        INTEGER
                         := snt.get_tglobal_settings ( 'DB',
                                                       'RELEASE',
                                                       'MAJOR',
                                                       NULL,
                                                       'YES'
                                                      );
   L_MINOR_IST        INTEGER
                         := snt.get_tglobal_settings ( 'DB',
                                                       'RELEASE',
                                                       'MINOR',
                                                       NULL,
                                                       'YES'
                                                      );
   L_REVISION_IST     INTEGER
                         := snt.get_tglobal_settings ( 'DB',
                                                       'RELEASE',
                                                       'REVISION',
                                                       NULL,
                                                       'YES'
                                                      );
   L_BUILD_IST        INTEGER
                         := snt.get_tglobal_settings ( 'DB',
                                                       'RELEASE',
                                                       'BUILD',
                                                       NULL,
                                                       'YES'
                                                      );

   L_MPC_IST          snt.TGLOBAL_SETTINGS.VALUE%TYPE
                         := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS',
                                                       'Setting',
                                                       'MPCName',
                                                       'NoMPCName found'
                                                      );
   L_VEGA_CODE_IST    snt.TGLOBAL_SETTINGS.VALUE%TYPE
                         := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS',
                                                       'SIVECO',
                                                       'Country-CD',
                                                       'No VegaCode found'
                                                      );
   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben

   L_LAST_EXEC_TIME   VARCHAR2 ( 30 CHAR );

   -- weitere benötigte variable
   L_ABBRUCH          BOOLEAN := FALSE;
BEGIN
   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   IF &L_SYSDBA_PRIV_NEEDED
   THEN
      BEGIN
         SELECT 'Y'
           INTO L_SYSDBA_PRIV
           FROM SESSION_PRIVS
          WHERE PRIVILEGE = 'SYSDBA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line (   'Executing user is not &L_SOLLUSER / SYSDABA!'
                                  || CHR ( 10 )
                                  || 'For a correct use of this script, executing user must be &L_SOLLUSER  / SYSDABA'
                                  || CHR ( 10 ) );
            L_ABBRUCH := TRUE;
      END;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user
   IF    L_ISTUSER IS NULL
      OR UPPER ( '&L_SOLLUSER' ) <> UPPER ( L_ISTUSER )
   THEN
      DBMS_OUTPUT.put_line (   'Executing user is not  &L_SOLLUSER !'
                            || CHR ( 10 )
                            || 'For a correct use of this script, executing user must be  &L_SOLLUSER '
                            || CHR ( 10 ) );
      L_ABBRUCH := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   IF    L_MAJOR_IST > &L_MAJOR_MIN
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST > &L_MINOR_MIN )
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST = &L_MINOR_MIN
          AND L_REVISION_IST > &L_REVISION_MIN )
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST = &L_MINOR_MIN
          AND L_REVISION_IST = &L_REVISION_MIN
          AND L_BUILD_IST >= &L_BUILD_MIN )
   THEN
      NULL;
   ELSE
      DBMS_OUTPUT.put_line (   'DB Version is incorrect! '
                            || CHR ( 10 )
                            || 'Current version is '
                            || L_MAJOR_IST
                            || '.'
                            || L_MINOR_IST
                            || '.'
                            || L_REVISION_IST
                            || '.'
                            || L_BUILD_IST
                            || ', but version must be same or higher than '
                            || &L_MAJOR_MIN
                            || '.'
                            || &L_MINOR_MIN
                            || '.'
                            || &L_REVISION_MIN
                            || '.'
                            || &L_BUILD_MIN
                            || CHR ( 10 ) );
      L_ABBRUCH := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   IF     &L_MPC_CHECK
      AND INSTR ( '&L_VEGA_CODE_SOLL', L_VEGA_CODE_IST ) = 0
   THEN
      DBMS_OUTPUT.put_line (   'This script can be executed against following DB(s) only: '
                            || '&L_MPC_SOLL'
                            || CHR ( 10 )
                            || 'But you are executing it against a '
                            || L_MPC_IST
                            || ' DB!'
                            || CHR ( 10 ) );
      L_ABBRUCH := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   IF &L_REEXEC_FORBIDDEN
   THEN
      BEGIN
         SELECT TO_CHAR ( LE_CREATED, 'DD.MM.YYYY HH24:MI:SS' )
           INTO L_LAST_EXEC_TIME
           FROM snt.TLOG_EVENT e
          WHERE     GUID_LA = '10'                                                                                  -- maintenance
                AND EXISTS
                       (SELECT NULL
                          FROM snt.TLOG_EVENT_PARAM ep
                         WHERE     ep.LEP_VALUE = :L_SCRIPTNAME
                               AND ep.GUID_LE = e.GUID_LE);

         DBMS_OUTPUT.put_line (   'This script was already executed on '
                               || L_LAST_EXEC_TIME
                               || CHR ( 10 )
                               || 'It cannot be executed a 2nd time!'
                               || CHR ( 10 ) );
         L_ABBRUCH := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- raise if at least one check above failed
   IF L_ABBRUCH
   THEN
      raise_application_error ( -20000, '==> Script Execution cancelled <==' );
   END IF;
END;
/

WHENEVER SQLERROR CONTINUE

PROMPT Do you want to save the changes to the DB? [Y/N] (Default N):

SET TERMOUT OFF
DEFINE commit_or_rollback = &1 N;
SET TERMOUT ON

PROMPT SELECTION CHOSEN: "&commit_or_rollback"

PROMPT
PROMPT processing. please wait ...
PROMPT

SET TERMOUT      OFF
SET SQLPROMPT    'SQL>'
SET PAGES        9999
SET LINES        9999
SET SERVEROUTPUT ON   SIZE UNLIMITED FORMAT WRAPPED
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================



-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     OFF
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >



-- main part for < selecting or checking or correcting code >
-- enlarging COntract duration... moving contract start date to earliest customer invoice CI_Date

DECLARE
   curr_contract varchar2(20);
   diff integer;
   OVERLAP EXCEPTION;
   REVERSE Exception;
   Pragma exception_init (OVERLAP, -20123);
   pragma exception_init (REVERSE,-20121); 
   CURSOR mycur
   IS
      SELECT c.id_vertrag,
             c.id_fzgvertrag,
             c.id_seq_fzgvc,
             c.fzgvc_beginn,
             C.CONTRACT_DURATION_EXT_ID,
             C.ID_SEQ_FZGKMSTAND_BEGIN,
             min(ci.ci_date) CI_DATE,
             min(P.FZGPR_VON)-1 PREIS,
             min(LL.FZGLL_VON)-1 LL
             
        FROM tfzgv_contracts c, tcustomer_invoice ci, tdfcontr_variant cov, tfzgpreis p, tfzglaufleistung ll
       WHERE     CI.ID_SEQ_FZGVC = c.id_seq_fzgvc
             AND C.ID_COV = cov.id_cov
             and P.ID_SEQ_FZGVC = c.id_Seq_fzgvc
             and ll.id_seq_fzgvc = c.id_seq_fzgvc
             -- scoping
             AND cov_caption NOT LIKE 'MIG_OOS%'
             -- finding problematic invoices
             AND CI.CI_DATE < C.FZGVC_BEGINN
         GROUP by c.id_vertrag,
             c.id_fzgvertrag,
             c.id_seq_fzgvc,
             c.fzgvc_beginn,
             C.CONTRACT_DURATION_EXT_ID,
             C.ID_SEQ_FZGKMSTAND_BEGIN
         ORDER BY c.ID_VERTRAG, c.ID_FZGVERTRAG;
BEGIN
   FOR rcur IN mycur
   LOOP
      curr_contract := rcur.id_vertrag||'/'||rcur.id_Fzgvertrag;
      diff := rcur.fzgvc_beginn-rcur.ci_date ;
      -- enlarging duration
      UPDATE tfzgv_contracts
         SET fzgvc_BEGINN = rcur.ci_date
         ,fzgvc_memo = substr('### EXTENDED BY SCRIPT DURING MIGRATION DUE TO &&GL_SCRIPTNAME from initially '||rcur.fzgvc_beginn||' to '||rcur.CI_DATE||'###' ||fzgvc_memo,1,2000)
       WHERE id_Seq_fzgvc = rcur.id_Seq_fzgvc;

      IF SQL%ROWCOUNT < 1
      THEN
         :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
         DBMS_OUTPUT.put_line (   'ERR : Contract '
                               || rcur.id_Vertrag
                               || '/'
                               || rcur.id_fzgvertrag
                               || ' could not be extended by '
                               || DIFF
                               || ' days (from '
                               || TO_CHAR ( rcur.fzgvc_beginn )
                               || ' to '
                               || TO_CHAR ( rcur.ci_date )
                               || '): '
                               || SQLERRM );
      ELSE
             -- correcting Date of initial Begin mileage
            BEGIN
            Update tfzgkmstand set fzgkm_datum = rcur.ci_date where id_seq_fzgkmstand = rcur.id_seq_fzgkmstand_begin;
            if sql%rowcount < 1 then
            :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
         DBMS_OUTPUT.put_line (   'ERR : Contract '
                               || rcur.id_Vertrag
                               || '/'
                               || rcur.id_fzgvertrag
                               || ' could not be extended by '
                               || DIFF
                               || ' days (from '
                               || TO_CHAR ( rcur.fzgvc_beginn )
                               || ' to '
                               || TO_CHAR ( rcur.ci_date )
                               || '): KMSTAND not set correct'
                               || SQLERRM );
                               end if;
         EXCEPTION
           
            WHEN OTHERS
            THEN
               RAISE;
         END;
      
      
      
         BEGIN
            -- creating price entry
            INSERT INTO tfzgpreis ( ID_SEQ_FZGPREIS,
                                    ID_PRV,
                                    ID_SEQ_FZGVC,
                                    ID_VERTRAG,
                                    ID_FZGVERTRAG,
                                    FZGPR_PREIS_GRKM,
                                    FZGPR_VON,
                                    FZGPR_BIS,
                                    FZGPR_PREIS_MONATP,
                                    PRICE_RANGE_EXT_ID,
                                    CONTRACT_DURATION_EXT_ID
                                   )
                 VALUES ( tfzgpreis_seq.NEXTVAL,
                          0,
                          rcur.id_Seq_fzgvc,
                          rcur.id_vertrag,
                          rcur.id_fzgvertrag,
                          0,
                          rcur.ci_date,
                          rcur.PREIS ,
                          0,
                             rcur.contract_duration_ext_id
                          || 'MIG-0',
                          rcur.contract_duration_ext_id
                         );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               DBMS_OUTPUT.put_line (   'ERR : Could not create Price entry for extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' - please check manually' );
               :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            WHEN OVERLAP THEN
               DBMS_OUTPUT.put_line (   'ERR : Could not create Price entry for extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' - try inserting price:'
                                     || rcur.CI_DATE 
                                     ||' - '
                                     ||rcur.PREIS
                                     );
                                      :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            WHEN REVERSE THEN
               DBMS_OUTPUT.put_line (   'WARN: Could not create Price entry for extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' period already exists - try inserting price:'
                                     || rcur.CI_DATE 
                                     ||' - '
                                     ||rcur.PREIS
                                     );
                                      :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + 1;
            
            WHEN OTHERS
            THEN
               RAISE;
         END;

         BEGIN
            -- creating mileage entry
            INSERT INTO tfzglaufleistung ( ID_SEQ_FZGLAUFLEISTUNG,
                                           ID_VERTRAG,
                                           ID_FZGVERTRAG,
                                           FZGLL_LAUFLEISTUNG,
                                           FZGLL_VON,
                                           FZGLL_BIS,
                                           ID_SEQ_FZGVC,
                                           ID_LLEINHEIT,
                                           FZGLL_DAUER_MONATE,
                                           MILEAGE_CLASSIFICATION_EXT_ID,
                                           CONTRACT_DURATION_EXT_ID
                                          )
                 VALUES ( tfzglaufleistung_seq.NEXTVAL,
                          rcur.id_Vertrag,
                          rcur.id_fzgvertrag,
                          0,
                          rcur.ci_date,
                          rcur.LL ,
                          rcur.id_seq_fzgvc,
                          1,
                          1,
                             rcur.contract_duration_ext_id
                          || 'MIG_LL-1',
                          rcur.contract_duration_ext_id
                         );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               DBMS_OUTPUT.put_line (   'ERR : Could not create RunPerformance entry of extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' - please check manually' );
               :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            WHEN OVERLAP THEN
               DBMS_OUTPUT.put_line (   'ERR : Could not create RunPerformance entry for extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' - try inserting price:'
                                     || rcur.CI_DATE 
                                     ||' - '
                                     ||rcur.LL
                                     );
                                      :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            WHEN REVERSE THEN
               DBMS_OUTPUT.put_line (   'WARN: Could not create RunPerformance entry for extended contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' - Period already exists:  try inserting price:'
                                     || rcur.CI_DATE 
                                     ||' - '
                                     ||rcur.LL
                                     );
                                      :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + 1;
            WHEN OTHERS
            THEN
               RAISE;
         END;

         DBMS_OUTPUT.put_line (   'INFO: Contract '
                               || rcur.id_Vertrag
                               || '/'
                               || rcur.id_fzgvertrag
                               || ' ('||rcur.id_Seq_fzgvc||') '
                               || ' successfully extended by '
                               || DIFF
                               || ' days (from '
                               || TO_CHAR ( rcur.fzgvc_beginn )
                               || ' to '
                               || TO_CHAR ( rcur.ci_date )
                               || ')' );
         :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + 1;
      END IF;
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ( 'A Data error occured. - Change made not successful!' );
      :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ( 'A unhandled Data error occured in contract '||curr_contract||'. - Script is cancelled' );
      DBMS_OUTPUT.put_line ( SQLERRM );
      :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
END;
/



--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
SET ECHO     OFF
SET FEEDBACK OFF

-- < delete following code between begin and end if data is selected only >

BEGIN
   IF     :L_ERROR_OCCURED = 0
      AND (   UPPER ( '&&commit_or_rollback' ) = 'Y'
           OR UPPER ( '&&commit_or_rollback' ) = 'AUTOCOMMIT' )
   THEN
      COMMIT;
      snt.SRS_LOG_MAINTENANCE_SCRIPTS ( :L_SCRIPTNAME );
      :nachricht := 'Data saved into the DB';
   ELSE
      ROLLBACK;
      :nachricht := 'DB Data not changed';
   END IF;
END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < enable again all perhaps in step 0 disabled constraints or triggers >
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- report final / finished message and exit
SET TERMOUT  ON

BEGIN
   IF UPPER ( '&&GL_LOGFILETYPE' ) <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line (   CHR ( 10 )
                            || 'finished.'
                            || CHR ( 10 ) );
   END IF;

   DBMS_OUTPUT.put_line ( :nachricht );

   IF UPPER ( '&&GL_LOGFILETYPE' ) <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line ( CHR ( 10 ) );
      DBMS_OUTPUT.put_line (
                             'Please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile &&GL_SCRIPTNAME..&&GL_LOGFILETYPE' );
      DBMS_OUTPUT.put_line ( CHR ( 10 ) );
      DBMS_OUTPUT.put_line ( 'MANAGEMENT SUMMARY' );
      DBMS_OUTPUT.put_line ( '==================' );
      DBMS_OUTPUT.put_line (   'Dataset affected: '
                            || :L_DATASUCCESS_OCCURED );
      DBMS_OUTPUT.put_line (   'Data warnings   : '
                            || :L_DATAWARNINGS_OCCURED );
      DBMS_OUTPUT.put_line (   'Data errors     : '
                            || :L_DATAERRORS_OCCURED );
      DBMS_OUTPUT.put_line (   'System errors   : '
                            || :L_ERROR_OCCURED );
   END IF;
END;
/

EXIT;