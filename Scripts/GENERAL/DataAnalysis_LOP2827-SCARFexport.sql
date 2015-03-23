-- create_SCARF_Exports_OOS.sql
-- script zum Erzeugen eines SCARF Vehicle und Scarf-Invoice Exports auf der SIMEX Länderrdatenbank in gescoptem zustand
-- PRECONDITION: SCOPING muss vorhanden sein.
-- V1.0 TK 20140113 - 130530:1

SPOOL  DataAnalysis_LOP2827-SCARFexport.log

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

VARIABLE L_ERROR_OCCURED NUMBER;
EXEC :L_ERROR_OCCURED    := 0;
VARIABLE nachricht       VARCHAR2 ( 100 CHAR );
VARIABLE L_SCRIPTNAME    VARCHAR2 ( 100 CHAR );
EXEC :L_SCRIPTNAME       := 'DataAnalysis_LOP2827-SCARFexport.sql';

PROMPT

WHENEVER SQLERROR EXIT sql.sqlcode

DECLARE
   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   L_SYSDBA_PRIV_NEEDED BOOLEAN := FALSE;                     -- false or true
   L_SYSDBA_PRIV  VARCHAR2 (1 CHAR);

   -- 2) unter welchem user muß das script laufen?
   L_SOLLUSER     VARCHAR2 (30 CHAR) := 'SNT';
   L_ISTUSER      VARCHAR2 (30 CHAR) := USER;

   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -):
   L_MAJOR_MIN    INTEGER := 2;
   L_MINOR_MIN    INTEGER := 8;
   L_REVISION_MIN INTEGER := 1;
   L_BUILD_MIN    INTEGER := 0;

   L_MAJOR_IST    INTEGER
                     := snt.get_tglobal_settings
                        (
                           'DB'
                          ,'RELEASE'
                          ,'MAJOR'
                          ,NULL
                          ,'YES'
                        );
   L_MINOR_IST    INTEGER
                     := snt.get_tglobal_settings
                        (
                           'DB'
                          ,'RELEASE'
                          ,'MINOR'
                          ,NULL
                          ,'YES'
                        );
   L_REVISION_IST INTEGER
                     := snt.get_tglobal_settings
                        (
                           'DB'
                          ,'RELEASE'
                          ,'REVISION'
                          ,NULL
                          ,'YES'
                        );
   L_BUILD_IST    INTEGER
                     := snt.get_tglobal_settings
                        (
                           'DB'
                          ,'RELEASE'
                          ,'BUILD'
                          ,NULL
                          ,'YES'
                        );

   -- 4) falls das script nur gegen ein einziges MPC laufen darf, hier true angeben, bzw. den namen des MPC:
   L_MPC_CHECK    BOOLEAN := TRUE;                            -- false or true
   L_MPC_SOLL     snt.TGLOBAL_SETTINGS.VALUE%TYPE := 'MBBeLux';
   L_MPC_IST      snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName');

   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
   L_REEXEC_FORBIDDEN BOOLEAN := TRUE;                        -- false or true
   L_LAST_EXEC_TIME VARCHAR2 (30 CHAR);

   -- weitere benötigte variable
   L_ABBRUCH      BOOLEAN := FALSE;
BEGIN
   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   IF L_SYSDBA_PRIV_NEEDED THEN
      BEGIN
         SELECT 'Y'
           INTO L_SYSDBA_PRIV
           FROM SESSION_PRIVS
          WHERE PRIVILEGE = 'SYSDBA';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.put_line
            (
                  'Executing user is not '
               || UPPER (L_SOLLUSER)
               || ' / SYSDABA!'
               || CHR (10)
               || 'For a correct use of this script, executing user must be '
               || UPPER (L_SOLLUSER)
               || ' / SYSDABA'
               || CHR (10)
            );
            L_ABBRUCH   := TRUE;
      END;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user
   IF    L_ISTUSER IS NULL
      OR UPPER (L_SOLLUSER) <> UPPER (L_ISTUSER) THEN
      DBMS_OUTPUT.put_line
      (
            'Executing user is not '
         || UPPER (L_SOLLUSER)
         || '!'
         || CHR (10)
         || 'For a correct use of this script, executing user must be '
         || UPPER (L_SOLLUSER)
         || CHR (10)
      );
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   IF    L_MAJOR_IST > L_MAJOR_MIN
      OR (    L_MAJOR_IST = L_MAJOR_MIN
          AND L_MINOR_IST > L_MINOR_MIN)
      OR (    L_MAJOR_IST = L_MAJOR_MIN
          AND L_MINOR_IST = L_MINOR_MIN
          AND L_REVISION_IST > L_REVISION_MIN)
      OR (    L_MAJOR_IST = L_MAJOR_MIN
          AND L_MINOR_IST = L_MINOR_MIN
          AND L_REVISION_IST = L_REVISION_MIN
          AND L_BUILD_IST >= L_BUILD_MIN) THEN
      NULL;
   ELSE
      DBMS_OUTPUT.put_line
      (
            'DB Version is incorrect! '
         || CHR (10)
         || 'Current version is '
         || L_MAJOR_IST
         || '.'
         || L_MINOR_IST
         || '.'
         || L_REVISION_IST
         || '.'
         || L_BUILD_IST
         || ', but version must be same or higher than '
         || L_MAJOR_MIN
         || '.'
         || L_MINOR_MIN
         || '.'
         || L_REVISION_MIN
         || '.'
         || L_BUILD_MIN
         || CHR (10)
      );
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   IF     L_MPC_CHECK
      AND L_MPC_IST <> L_MPC_SOLL THEN
      DBMS_OUTPUT.put_line
      (
            'This script can be executed against a '
         || L_MPC_SOLL
         || ' DB only!'
         || CHR (10)
         || 'You are executing it against a '
         || L_MPC_IST
         || ' DB!'
         || CHR (10)
      );
      L_ABBRUCH   := TRUE;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   IF L_REEXEC_FORBIDDEN THEN
      BEGIN
         SELECT TO_CHAR ( LE_CREATED, 'DD.MM.YYYY HH24:MI:SS')
           INTO L_LAST_EXEC_TIME
           FROM snt.TLOG_EVENT e
          WHERE     GUID_LA = '10'                              -- maintenance
                AND EXISTS
                       (SELECT NULL
                          FROM snt.TLOG_EVENT_PARAM ep
                         WHERE     ep.LEP_VALUE = :L_SCRIPTNAME
                               AND ep.GUID_LE = e.GUID_LE);

         DBMS_OUTPUT.put_line
         (
               'This script was already executed on '
            || L_LAST_EXEC_TIME
            || CHR (10)
            || 'It cannot be executed a 2nd time!'
            || CHR (10)
         );
         L_ABBRUCH   := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
   END IF;

   -------------------------------------------------------------------------------------------------------
   -- raise if at least one check above failed
   IF L_ABBRUCH THEN
      raise_application_error ( -20000, '==> Script Execution cancelled <==');
   END IF;
END;
/

WHENEVER SQLERROR CONTINUE

PROMPT
PROMPT processing. please wait ...
PROMPT

SET TERMOUT      ON
SET SQLPROMPT    'SQL>'
SET PAGES        9999
SET LINES        9999
SET SERVEROUTPUT ON   SIZE UNLIMITED
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     OFF

-- disable SSE Exporter
   EXEC SNT.P_JOB.DISABLE_JOB_SSE;

SET FEEDBACK     ON
SET FEEDBACK     1

-- main part for < selecting or checking or correcting code >

-- 1st:
PROMPT
PROMPT === Backup Contract type table:
PROMPT

DECLARE
   i              NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO i
     FROM all_tables
    WHERE table_name = 'TDFCONTR_VARIANT_SAVE';

   IF i > 0 THEN
      EXECUTE IMMEDIATE 'drop table tdfcontr_variant_save';

      DBMS_OUTPUT.put_line
      (
         'Backup table exists already ... dropping old backup table!'
      );
   END IF;
END;
/

CREATE TABLE tdfcontr_variant_save
AS
   SELECT * FROM tdfcontr_variant;

PROMPT
PROMPT === Following Contract Variants are SCARF relevant now:
PROMPT

SELECT COV_CAPTION
  FROM tdfcontr_variant
 WHERE COV_SCARF_CONTRACT = 1;

-- Execute SCARF VEHICLE Export directly:
PROMPT
PROMPT === Execute Scarf Vehicle Export excluding OutOfScope Contracts:
PROMPT

--  Creating Exports in TEXP_SCHEDULED_EXPORTS

INSERT INTO SNT.TEXP_SCHEDULED_EXPORTS
            (
               TSE_EXPORTNUMBER
              ,TSE_DELIMITER
              ,TSE_OVERWRITE
              ,TSE_PARAM1
              ,TSE_PARAM2
              ,TSE_CREATED
              ,TSE_JO_PARAMETER
              ,TSE_CREATOR
              ,TSE_FINISH_STATE
              ,TSE_SHOW_ENTRY
              ,TSE_FILENAME
            )
     VALUES
            (
               74
              ,'TXT flat file'
              ,0
              ,'journal'
              ,TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,SYSDATE
              ,'Document Date: ' || TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,'SNT'
              ,0
              ,1
              ,'SCARF_INVOICE_SCOPED.txt'
            );

INSERT INTO SNT.TEXP_SCHEDULED_EXPORTS
            (
               TSE_EXPORTNUMBER
              ,TSE_DELIMITER
              ,TSE_OVERWRITE
              ,TSE_PARAM1
              ,TSE_PARAM2
              ,TSE_CREATED
              ,TSE_JO_PARAMETER
              ,TSE_CREATOR
              ,TSE_FINISH_STATE
              ,TSE_SHOW_ENTRY
              ,TSE_FILENAME
            )
     VALUES
            (
               75
              ,'TXT flat file'
              ,0
              ,'journal'
              ,TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,SYSDATE
              ,'Document Date: ' || TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,'SNT'
              ,0
              ,1
              ,'SCARF_VEHICLE_SCOPED.txt'
            );

-- Triggering Export Process
  EXEC SNT.PCK_EXPORTER.PROCESS;

--3rd:
PROMPT
PROMPT === Customize Contract Variants to export ONLY Scarf relevant OutOfScope Data
PROMPT

DECLARE
   CURSOR cur
   IS
      SELECT cov_caption, ID_COV, COV_SCARF_CONTRACT
        FROM TDFCONTR_VARIANT_SAVE;

   CURSOR cur2
   IS
      SELECT cov_caption, ID_COV, COV_SCARF_CONTRACT FROM TDFCONTR_VARIANT;
      
    flag integer;
BEGIN
   FOR rcur IN cur
   LOOP
      IF rcur.cov_caption LIKE 'MIG_OOS_%' THEN
         flag := 0;
         select cov_scarf_contract into flag 
         from tdfcontr_variant_save
         where cov_caption like substr(rcur.cov_caption,9,1000);
      
         UPDATE tdfcontr_variant
            SET cov_scarf_contract   = flag
          WHERE id_cov = rcur.id_cov;
      ELSE
         UPDATE tdfcontr_variant
            SET COV_SCARF_CONTRACT   = 0
          WHERE id_cov = rcur.id_cov;
      END IF;
   END LOOP;

   COMMIT;

   FOR rcur IN cur2
   LOOP
      DBMS_OUTPUT.put_line
      (
            'Contract Variant '
         || rcur.cov_caption
         || '('
         || rcur.id_cov
         || ')'
         || ' is SCARF Relevant :'
         || REPLACE ( REPLACE ( rcur.cov_scarf_contract, 0, 'FALSE'), 1, 'TRUE')
      );
   END LOOP;
END;
/

COMMIT;

PROMPT
PROMPT === Following Contract Variants are SCARF relevant now:
PROMPT

SELECT COV_CAPTION
  FROM tdfcontr_variant
 WHERE COV_SCARF_CONTRACT = 1;

-- Execute SCARF VEHICLE Export directly:

PROMPT
PROMPT === Execute Scarf Vehicle Export ONLY OutOfScope Contracts:
PROMPT

--  Creating Exports in TEXP_SCHEDULED_EXPORTS

INSERT INTO SNT.TEXP_SCHEDULED_EXPORTS
            (
               TSE_EXPORTNUMBER
              ,TSE_DELIMITER
              ,TSE_OVERWRITE
              ,TSE_PARAM1
              ,TSE_PARAM2
              ,TSE_CREATED
              ,TSE_JO_PARAMETER
              ,TSE_CREATOR
              ,TSE_FINISH_STATE
              ,TSE_SHOW_ENTRY
              ,TSE_FILENAME
            )
     VALUES
            (
               74
              ,'TXT flat file'
              ,0
              ,'journal'
              ,TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,SYSDATE
              ,'Document Date: ' || TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,'SNT'
              ,0
              ,1
              ,'SCARF_INVOICE_OOS.txt'
            );

INSERT INTO SNT.TEXP_SCHEDULED_EXPORTS
            (
               TSE_EXPORTNUMBER
              ,TSE_DELIMITER
              ,TSE_OVERWRITE
              ,TSE_PARAM1
              ,TSE_PARAM2
              ,TSE_CREATED
              ,TSE_JO_PARAMETER
              ,TSE_CREATOR
              ,TSE_FINISH_STATE
              ,TSE_SHOW_ENTRY
              ,TSE_FILENAME
            )
     VALUES
            (
               75
              ,'TXT flat file'
              ,0
              ,'journal'
              ,TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,SYSDATE
              ,'Document Date: ' || TO_CHAR ( SYSDATE, 'DD/MM/YYYY')
              ,'SNT'
              ,0
              ,1
              ,'SCARF_VEHICLE_OOS.txt'
            );

-- Triggering Export Process
  EXEC SNT.PCK_EXPORTER.PROCESS;

   -- Restore TDFCONTR_VARIANT:
PROMPT
PROMPT === Restoring Contract Variants for SCARF relevance
PROMPT

DECLARE
   CURSOR cur
   IS
      SELECT ID_COV, COV_SCARF_CONTRACT FROM TDFCONTR_VARIANT_SAVE;
BEGIN
   FOR rcur IN cur
   LOOP
      UPDATE tdfcontr_variant
         SET COV_SCARF_CONTRACT   = rcur.cov_scarf_contract
       WHERE id_cov = rcur.id_cov;
   END LOOP;
END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

COMMIT;

PROMPT
PROMPT === Following Contract Variants are SCARF relevant now:
PROMPT

SELECT COV_CAPTION
  FROM tdfcontr_variant
 WHERE COV_SCARF_CONTRACT = 1;

SET ECHO     OFF
SET FEEDBACK OFF

-- < enable again all perhaps in step 0 disabled constraints or triggers >
EXEC P_JOB.ENABLE_JOB_SSE;

-- report final / finished message and exit
SET TERMOUT  ON

PROMPT
PROMPT === finished.
PROMPT

BEGIN
   DBMS_OUTPUT.put_line (:nachricht);
END;
/

PROMPT
PROMPT please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile Template.log
PROMPT

EXIT;