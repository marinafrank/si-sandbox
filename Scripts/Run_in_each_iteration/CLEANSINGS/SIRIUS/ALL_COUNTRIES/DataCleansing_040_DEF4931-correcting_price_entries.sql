/* Formatted on 24.09.2014 09:53:22 (QP5 v5.185.11230.41888) */
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   DEFINE GL_SCRIPTNAME        = DataCleansing_040_DEF4931-correcting_price_entries

   DEFINE GL_LOGFILETYPE    = LOG        -- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   DEFINE GL_SCRIPTFILETYPE    = SQL        -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   DEFINE L_MAJOR_MIN        = 2
   DEFINE L_MINOR_MIN        = 8
   DEFINE L_REVISION_MIN    = 1
   DEFINE L_BUILD_MIN        = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   DEFINE L_SOLLUSER        = SNT
   DEFINE L_SYSDBA_PRIV_NEEDED    = FALSE        -- false or true

  -- country specification
   DEFINE L_MPC_CHECK        = FALSE        -- false or true
   DEFINE L_MPC_SOLL        = 'MBBeLux'

  -- Reexecution
   DEFINE  L_REEXEC_FORBIDDEN    = FALSE        -- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   DEFINE L_DB_LOGGING_ENABLE    = TRUE        -- Are we logging to the DB? -> false or true
   DEFINE L_LOGFILE_REQUIRED    = TRUE        -- Logfile required? -> false or true

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
SET SERVEROUTPUT ON  SIZE UNLIMITED
SET LINES        999
SET PAGES        0

VARIABLE L_SCRIPTNAME         VARCHAR2 (200 CHAR);
VARIABLE L_ERROR_OCCURED     NUMBER;
VARIABLE L_DATAERRORS_OCCURED     NUMBER;
VARIABLE L_DATAWARNINGS_OCCURED NUMBER;
VARIABLE L_DATASUCCESS_OCCURED NUMBER;
VARIABLE nachricht           VARCHAR2 ( 200 CHAR );
EXEC :L_SCRIPTNAME := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
EXEC :L_ERROR_OCCURED :=0
EXEC :L_DATAERRORS_OCCURED :=0
EXEC :L_DATAWARNINGS_OCCURED :=0
EXEC :L_DATASUCCESS_OCCURED :=0

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
      AND L_MPC_IST <> '&L_MPC_SOLL'
   THEN
      DBMS_OUTPUT.put_line (   'This script can be executed against a '
                            || '&L_MPC_SOLL'
                            || ' DB only!'
                            || CHR ( 10 )
                            || 'You are executing it against a '
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
SET SERVEROUTPUT ON   SIZE UNLIMITED
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- main part for < selecting or checking or correcting code >
PROMPT
PROMPT Affected Contracts with non-Matching Prices
PROMPT


DECLARE
   l_ID_SEQ_FZGVC         snt.tfzgv_contracts.ID_SEQ_FZGVC%TYPE;
   l_ID_VERTRAG           snt.tfzgv_contracts.ID_VERTRAG%TYPE;
   l_ID_FZGVERTRAG        snt.tfzgv_contracts.ID_FZGVERTRAG%TYPE;
   l_FIRST_PERIOD_BEGIN   snt.tfzgpreis.FZGPR_VON%TYPE;
   l_FZGVC_BEGIN          snt.tfzgv_contracts.FZGVC_BEGINN%TYPE;

   CURSOR aff_contr
   IS
        SELECT *
          FROM (SELECT bla.*,
                       CASE
                          WHEN min_beginn > min_preis THEN 'PRICE BEGIN before Contract Begin'
                          WHEN min_beginn < min_preis THEN 'PRICE BEGIN after Contract  Begin'
                          WHEN MAX_ENDE > MAX_PREIS THEN 'PRICE END before Contract End'
                          WHEN MAX_ENDE < MAX_PREIS THEN 'PRICE END after Contract End'
                       END
                          PROBLEM,
                       CASE
                          WHEN min_beginn > min_preis THEN TO_CHAR ( min_beginn - min_preis )
                          WHEN min_beginn < min_preis THEN TO_CHAR ( min_preis - min_beginn )
                          WHEN MAX_ENDE > MAX_PREIS THEN TO_CHAR ( MAX_ENDE - MAX_PREIS )
                          WHEN MAX_ENDE < MAX_PREIS THEN TO_CHAR ( MAX_PREIS - MAX_ENDE )
                       END
                          DayDIFFinDays,
                       CASE
                          WHEN min_beginn > min_preis THEN 'A'                                    --> Korrektur auf contract start
                          WHEN min_beginn < min_preis THEN 'B'                                           --> Null- Preis am Anfang
                          WHEN MAX_ENDE > MAX_PREIS THEN 'C'                                                 -- Null-Preis am ENDE
                          WHEN MAX_ENDE < MAX_PREIS THEN 'D'                                         --> Korrektur auf planned End
                       END
                          CATEGORY
                  FROM (  SELECT c.id_vertrag,
                                 c.id_fzgvertrag,
                                 -- CONTRACT,
                                 MIN ( c.id_seq_fzgvc ) MIN_SEQ_FZGVC,
                                 MAX ( c.id_seq_fzgvc ) MAX_SEQ_FZGVC,
                                 iv.indv_caption,
                                 MIN ( c.fzgvc_beginn ) MIN_BEGINN,
                                 MIN ( pr.fzgpr_von ) MIN_PREIS,
                                 MAX ( c.fzgvc_ende ) MAX_ENDE,
                                 CASE
                                    WHEN ( iv.indv_type = 2 )                                                       -- indexierbar
                                    THEN
                                       MAX ( c.fzgvc_ende )
                                    WHEN (    iv.indv_type = 1                                                             -- fest
                                          AND COS.COS_ACTIVE = 1 )                                                     -- + ACTIVE
                                    THEN
                                       MAX ( c.fzgvc_ende )
                                    ELSE
                                       MAX ( PR.FZGPR_BIS )
                                 END
                                    MAX_PREIS
                            --  select v.id_vertrag, v.id_fzgvertrag
                            FROM tfzgvertrag ver,
                                 tfzgv_contracts c,
                                 tdfcontr_variant COV,
                                 tfzgpreis pr,
                                 tdf_indexation_variant iv,
                                 tdfcontr_state COS
                           WHERE     ver.id_vertrag = c.id_vertrag
                                 AND ver.id_fzgvertrag = c.id_fzgvertrag
                                 AND c.id_cov = COV.id_coV
                                 AND COV.coV_caption NOT LIKE '%MIG_OOS%'
                                 AND c.guid_indv = iv.guid_indv
                                 AND pr.id_seq_fzgvc(+) = c.id_seq_fzgvc
                                 AND ver.id_cos = COS.id_cos
                        GROUP BY iv.indv_caption,
                                 iv.indv_type,
                                 COS.COS_ACTIVE,
                                 c.id_vertrag,
                                 c.id_fzgvertrag
                          --, c.id_seq_fzgvc
                          HAVING    MIN ( c.fzgvc_beginn ) <> MIN ( pr.fzgpr_von )
                                 OR MAX ( c.fzgvc_ende ) <> MAX ( PR.FZGPR_BIS )) bla) blabla
         WHERE PROBLEM IS NOT NULL
      ORDER BY 7, 8;
BEGIN
   FOR rcur IN aff_contr
   LOOP
      l_ID_VERTRAG := rcur.ID_VERTRAG;
      l_ID_FZGVERTRAG := rcur.ID_FZGVERTRAG;
      l_FZGVC_BEGIN := rcur.MIN_BEGINN;
      l_FIRST_PERIOD_BEGIN := rcur.min_preis;

      CASE rcur.category
         WHEN 'A'
         THEN                                                                                     --> Korrektur auf contract start
            BEGIN
               UPDATE TFZGPREIS
                  SET fzgpr_von = l_FZGVC_BEGIN
                WHERE     id_vertrag = l_ID_VERTRAG
                      AND id_fzgvertrag = l_ID_FZGVERTRAG
                      AND fzgpr_von = l_FIRST_PERIOD_BEGIN;

               DBMS_OUTPUT.put_line (   'INFO: Contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' adapted: First price start date corrected to contract begin from '
                                     || rcur.MIN_PREIS
                                     || ' to '
                                     || rcur.MIN_BEGINN );
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (   'ERR: PROBLEM Contract Type A '
                                        || rcur.id_Vertrag
                                        || '/'
                                        || rcur.id_fzgvertrag
                                        || ' could not be adapted. Tried to shorten first price to beginning of contract '
                                        || rcur.MIN_PREIS
                                        || ' to '
                                        || TO_CHAR ( TO_DATE ( rcur.MIN_BEGINN ) )
                                        || ' ~ Please check manually' );
                  :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            END;
         WHEN 'B'
         THEN
            BEGIN                                                                                        --> Null- Preis am Anfang
               INSERT INTO tfzgpreis ( ID_SEQ_FZGPREIS,
                                       id_vertrag,
                                       id_fzgvertrag,
                                       id_seq_fzgvc,
                                       fzgpr_von,
                                       fzgpr_bis,
                                       id_prv,
                                       fzgpr_preis_grkm,
                                       fzgpr_preis_monatp
                                      )
                    VALUES ( TFZGPREIS_SEQ.NEXTVAL,
                             rcur.id_vertrag,
                             rcur.id_fzgvertrag,
                             rcur.MIN_SEQ_FZGVC,
                             rcur.MIN_BEGINN,
                             TO_DATE ( rcur.MIN_PREIS ) - 1,
                             0,
                             0,
                             0
                            );

               DBMS_OUTPUT.put_line (   'INFO: Contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' adapted: New Price entry created from '
                                     || TO_CHAR ( rcur.MIN_BEGINN )
                                     || ' to '
                                     || TO_CHAR ( TO_DATE ( rcur.MIN_PREIS ) - 1 ) );
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (   'ERR: PROBLEM Contract Type B '
                                        || rcur.id_Vertrag
                                        || '/'
                                        || rcur.id_fzgvertrag
                                        || ' could not be adapted. Tried insert new price at beginning of contract '
                                        || rcur.MIN_BEGINN
                                        || ' to '
                                        || TO_CHAR ( TO_DATE ( rcur.MIN_PREIS ) - 1 )
                                        || ' ~ Please check manually' );
                  :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            END;
         WHEN 'C'
         THEN
            BEGIN                                                                                           --> Null-Preis am ENDE
               INSERT INTO tfzgpreis ( ID_SEQ_FZGPREIS,
                                       id_vertrag,
                                       id_fzgvertrag,
                                       id_seq_fzgvc,
                                       fzgpr_von,
                                       fzgpr_bis,
                                       id_prv,
                                       fzgpr_preis_grkm,
                                       fzgpr_preis_monatp
                                      )
                    VALUES ( TFZGPREIS_SEQ.NEXTVAL,
                             rcur.id_vertrag,
                             rcur.id_fzgvertrag,
                             rcur.MAX_SEQ_FZGVC,
                             TO_DATE ( rcur.MAX_PREIS ) + 1,
                             rcur.MAX_ENDE,
                             0,
                             0,
                             0
                            );

               DBMS_OUTPUT.put_line (   'INFO: Contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' adapted: New Price entry created from '
                                     || TO_CHAR ( TO_DATE ( rcur.MAX_PREIS ) + 1 )
                                     || ' to '
                                     || TO_CHAR ( rcur.MAX_ENDE ) );
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (   'ERR: PROBLEM Contract Type C '
                                        || rcur.id_Vertrag
                                        || '/'
                                        || rcur.id_fzgvertrag
                                        || ' could not be adapted. Tried insert new price at end of contract '
                                        || rcur.MAX_PREIS
                                        || ' to '
                                        || rcur.MAX_ENDE
                                        || ' ~ Please check manually' );
                  :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            END;
         WHEN 'D'
         THEN                                                                                        --> Korrektur auf planned End
            BEGIN
               UPDATE TFZGPREIS
                  SET fzgpr_bis = rcur.MAX_ENDE
                WHERE     id_vertrag = l_ID_VERTRAG
                      AND id_fzgvertrag = l_ID_FZGVERTRAG
                      AND fzgpr_bis = rcur.MAX_PREIS;

               DBMS_OUTPUT.put_line (   'INFO: Contract '
                                     || rcur.id_Vertrag
                                     || '/'
                                     || rcur.id_fzgvertrag
                                     || ' adapted: Last price end date corrected to contract end from '
                                     || rcur.MAX_PREIS
                                     || ' to '
                                     || rcur.MAX_ENDE );
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                                            'ERR: PROBLEM Contract Type D '
                                         || rcur.id_Vertrag
                                         || '/'
                                         || rcur.id_fzgvertrag
                                         || ' could not be adapted. Tried last price end date corrected to contract end date: from '
                                         || rcur.MAX_PREIS
                                         || ' to '
                                         || rcur.MAX_ENDE
                                         || ' ~ Please check manually'
                                         );
                  :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
            END;
      END CASE;

      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + 1;
   END LOOP;

EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (   'ERR-: '
                            || l_ID_VERTRAG
                            || '/'
                            || l_id_fzgvertrag
                            || '; '
                            || l_FZGVC_BEGIN
                            || '; '
                            || l_FIRST_PERIOD_BEGIN
                            || '; '
                            || SQLERRM );
      -- dbms_output.put_line (sqlerrm);
      :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
END;
/
/
-- MZu, 2014-10-29, MKS-135468: 2nd run of script required to collect all contracts that do have a problem at the beginning AND the end. (means: 2x '/')



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