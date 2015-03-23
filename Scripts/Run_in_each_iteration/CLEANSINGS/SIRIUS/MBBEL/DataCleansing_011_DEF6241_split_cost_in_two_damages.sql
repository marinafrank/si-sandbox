/* Formatted on 07.11.2014 15:36:11 (QP5 v5.185.11230.41888) */
-- DataCleansing_DEF6241_split_cost_in_two_damages.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-11-05; TK ; MKS-135299:1

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   DEFINE GL_SCRIPTNAME         = DataCleansing_011_DEF6241_split_cost_in_two_damages
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
   DEFINE L_MPC_CHECK           = TRUE    -- false or true
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
EXEC :L_SCRIPTNAME              := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
EXEC :L_ERROR_OCCURED           := 0
EXEC :L_DATAERRORS_OCCURED      := 0
EXEC :L_DATAWARNINGS_OCCURED    := 0
EXEC :L_DATASUCCESS_OCCURED     := 0

SPOOL &GL_SCRIPTNAME..&GL_LOGFILETYPE

DECLARE
   L_LAST_EXEC_TIME   VARCHAR2(30 CHAR);
BEGIN
   IF UPPER('&&GL_LOGFILETYPE') <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line('Script executed on: ' || TO_CHAR( SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
      DBMS_OUTPUT.put_line('Script executed by: &&_USER');
      DBMS_OUTPUT.put_line('Script run on DB  : &&_CONNECT_IDENTIFIER');
      DBMS_OUTPUT.put_line('Database Country  : ' || snt.get_TGLOBAL_SETTINGS( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found')
                          );
      DBMS_OUTPUT.put_line('Database dump date: ' || snt.get_TGLOBAL_SETTINGS( 'DB', 'DUMP', 'DATE', 'not found'));

      BEGIN
         SELECT TO_CHAR( MAX(LE_CREATED), 'DD.MM.YYYY HH24:MI:SS')
           INTO L_LAST_EXEC_TIME
           FROM snt.TLOG_EVENT e
          WHERE     GUID_LA = '10'                                                                                  -- maintenance
                AND EXISTS
                       (SELECT NULL
                          FROM snt.TLOG_EVENT_PARAM ep
                         WHERE     ep.LEP_VALUE = :L_SCRIPTNAME
                               AND ep.GUID_LE = e.GUID_LE);

         DBMS_OUTPUT.put_line('This script was already executed on ' || L_LAST_EXEC_TIME);
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

   L_SYSDBA_PRIV      VARCHAR2(1 CHAR);

   -- 2) unter welchem user muß das script laufen?

   L_ISTUSER          VARCHAR2(30 CHAR) := USER;

   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -):


   L_MAJOR_IST        INTEGER
                         := snt.get_tglobal_settings('DB'
                                                    ,'RELEASE'
                                                    ,'MAJOR'
                                                    ,NULL
                                                    ,'YES'
                                                    );
   L_MINOR_IST        INTEGER
                         := snt.get_tglobal_settings('DB'
                                                    ,'RELEASE'
                                                    ,'MINOR'
                                                    ,NULL
                                                    ,'YES'
                                                    );
   L_REVISION_IST     INTEGER
                         := snt.get_tglobal_settings('DB'
                                                    ,'RELEASE'
                                                    ,'REVISION'
                                                    ,NULL
                                                    ,'YES'
                                                    );
   L_BUILD_IST        INTEGER
                         := snt.get_tglobal_settings('DB'
                                                    ,'RELEASE'
                                                    ,'BUILD'
                                                    ,NULL
                                                    ,'YES'
                                                    );

   L_MPC_IST          snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found');
   L_VEGA_CODE_IST    snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS( 'SIRIUS', 'SIVECO', 'Country-CD', 'No VegaCode found');
   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben

   L_LAST_EXEC_TIME   VARCHAR2(30 CHAR);

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
            DBMS_OUTPUT.put_line(
                  'Executing user is not &L_SOLLUSER / SYSDABA!'
               || CHR(10)
               || 'For a correct use of this script, executing user must be &L_SOLLUSER  / SYSDABA'
               || CHR(10));
            L_ABBRUCH   := TRUE;
      END;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user
   IF    L_ISTUSER IS NULL
      OR UPPER('&L_SOLLUSER') <> UPPER(L_ISTUSER)
   THEN
      DBMS_OUTPUT.put_line(
            'Executing user is not  &L_SOLLUSER !'
         || CHR(10)
         || 'For a correct use of this script, executing user must be  &L_SOLLUSER '
         || CHR(10));
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   IF    L_MAJOR_IST > &L_MAJOR_MIN
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST > &L_MINOR_MIN)
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST = &L_MINOR_MIN
          AND L_REVISION_IST > &L_REVISION_MIN)
      OR (    L_MAJOR_IST = &L_MAJOR_MIN
          AND L_MINOR_IST = &L_MINOR_MIN
          AND L_REVISION_IST = &L_REVISION_MIN
          AND L_BUILD_IST >= &L_BUILD_MIN)
   THEN
      NULL;
   ELSE
      DBMS_OUTPUT.put_line(
            'DB Version is incorrect! '
         || CHR(10)
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
         || CHR(10));
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   IF     &L_MPC_CHECK
      AND INSTR( '&L_VEGA_CODE_SOLL', L_VEGA_CODE_IST) = 0
   THEN
      DBMS_OUTPUT.put_line(
            'This script can be executed against following DB(s) only: '
         || '&L_MPC_SOLL'
         || CHR(10)
         || 'But you are executing it against a '
         || L_MPC_IST
         || ' DB!'
         || CHR(10));
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   IF &L_REEXEC_FORBIDDEN
   THEN
      BEGIN
         SELECT TO_CHAR( LE_CREATED, 'DD.MM.YYYY HH24:MI:SS')
           INTO L_LAST_EXEC_TIME
           FROM snt.TLOG_EVENT e
          WHERE     GUID_LA = '10'                                                                                  -- maintenance
                AND EXISTS
                       (SELECT NULL
                          FROM snt.TLOG_EVENT_PARAM ep
                         WHERE     ep.LEP_VALUE = :L_SCRIPTNAME
                               AND ep.GUID_LE = e.GUID_LE);

         DBMS_OUTPUT.put_line(
               'This script was already executed on '
            || L_LAST_EXEC_TIME
            || CHR(10)
            || 'It cannot be executed a 2nd time!'
            || CHR(10));
         L_ABBRUCH   := TRUE;
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
      raise_application_error( -20000, '==> Script Execution cancelled <==');
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
SET LINESIZE    500
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================



-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     OFF
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >

SET TERMOUT OFF

-- main part for < selecting or checking or correcting code >

DECLARE
   CURSOR cur
   IS
      SELECT i.id_seq_fzgrechnung, gar_is_service_provider, gar_garnovega
        FROM tfzgrechnung i
            ,tfzgv_contracts vc
            ,tdfcontr_variant cov
            ,tgarage g
            ,tpartner p
       WHERE     i.id_seq_fzgvc = vc.id_seq_fzgvc
             AND vc.id_cov = cov.id_cov
             AND cov.cov_caption NOT LIKE 'MIG_OOS%'
             AND i.guid_partner = p.guid_partner
             AND p.id_garage = g.id_garage
             AND (   g.gar_is_service_provider = 1
                  OR gar_garnovega = '11924')
             AND I.ID_IMP_TYPE NOT IN (6, 9, 10);
BEGIN
   -- primary: make all COST related to internal coverage:
   UPDATE tfzgrechnung
      SET fzgre_anzahl_aw1   = 0;

   -- secondary, mark all external cost as external (fzgre_aw1 = 1);
   FOR rcur IN cur
   LOOP
      BEGIN
         UPDATE tfzgrechnung
            SET fzgre_anzahl_aw1   = 1
          WHERE id_seq_fzgrechnung = rcur.id_seq_fzgrechnung;

         IF SQL%ROWCOUNT > 0
         THEN
            DBMS_OUTPUT.put_line('INFO: Invoice ' || rcur.id_seq_fzgrechnung || ' is set to external risk');

            :L_DATASUCCESS_OCCURED   := :L_DATASUCCESS_OCCURED + 1;
         ELSE
            DBMS_OUTPUT.put_line('ERR : could not set invoice ' || ' to damage external risk');
            :L_DATAERRORS_OCCURED   := :L_DATAERRORS_OCCURED + 1;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line('ERR : could not set invoice ' || ' to damage external risk - ' || SQLERRM);
            :L_DATAERRORS_OCCURED   := :L_DATAERRORS_OCCURED + 1;
      END;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line('A unhandled Data error occured. - Change made not successful!');
      DBMS_OUTPUT.put_line(SQLERRM);
      :L_ERROR_OCCURED   := :L_ERROR_OCCURED + 1;
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
      AND (   UPPER('&&commit_or_rollback') = 'Y'
           OR UPPER('&&commit_or_rollback') = 'AUTOCOMMIT')
   THEN
      COMMIT;
      snt.SRS_LOG_MAINTENANCE_SCRIPTS(:L_SCRIPTNAME);
      :nachricht   := 'Data saved into the DB';
   ELSE
      ROLLBACK;
      :nachricht   := 'DB Data not changed';
   END IF;
END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < enable again all perhaps in step 0 disabled constraints or triggers >
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )
ALTER TRIGGER SNT.IP_NO_UPD_DEL ENABLE;
--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- report final / finished message and exit
SET TERMOUT  ON

BEGIN
   IF UPPER('&&GL_LOGFILETYPE') <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line(CHR(10) || 'finished.' || CHR(10));
   END IF;

   DBMS_OUTPUT.put_line(:nachricht);

   IF UPPER('&&GL_LOGFILETYPE') <> 'CSV'
   THEN
      DBMS_OUTPUT.put_line(CHR(10));
      DBMS_OUTPUT.put_line(
         'Please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile &&GL_SCRIPTNAME..&&GL_LOGFILETYPE');
      DBMS_OUTPUT.put_line(CHR(10));
      DBMS_OUTPUT.put_line('MANAGEMENT SUMMARY');
      DBMS_OUTPUT.put_line('==================');
      DBMS_OUTPUT.put_line('Dataset affected: ' || :L_DATASUCCESS_OCCURED);
      DBMS_OUTPUT.put_line('Data warnings   : ' || :L_DATAWARNINGS_OCCURED);
      DBMS_OUTPUT.put_line('Data errors     : ' || :L_DATAERRORS_OCCURED);
      DBMS_OUTPUT.put_line('System errors   : ' || :L_ERROR_OCCURED);
   END IF;
END;
/

EXIT;