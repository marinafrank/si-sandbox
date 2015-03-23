/* Formatted on 12.11.2014 09:47:29 (QP5 v5.185.11230.41888) */
-- DataCleansing_Vertragsnummer_aendern.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2015-01-23; MKS-136343:1; MARZUHL; Initial Release 

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   DEFINE GL_SCRIPTNAME         = DataCleansing_091_DEF7019_Contract_Replace_Underscore_By_Zero
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
   DEFINE L_MPC_SOLL            = 'MBBEL'   -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   DEFINE L_VEGA_CODE_SOLL      = '51331'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb:
                                           -- define L_MPC_SOLL       = 'MBBEL,MBCH'
                                           -- define L_VEGA_CODE_SOLL = '51331,57129'

  -- Reexecution
   DEFINE  L_REEXEC_FORBIDDEN   = TRUE         -- false or true

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

         IF L_LAST_EXEC_TIME IS NOT NULL THEN
           DBMS_OUTPUT.put_line('This script was already executed on ' || L_LAST_EXEC_TIME);
         END IF;
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
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================



-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     OFF
-- Create TFZGV_CLEANSING_MAPPING Table if not exists.
DECLARE
  v_exists    smallint;
  begin
  select 1
    into v_exists
    from user_tables
   where table_name='TFZGV_CLEANSING_MAPPING';
   dbms_output.put_line('Table TFZGV_CLEANSING_MAPPING is already created. All existing rows will stay untouched.');
  exception when no_data_found then
     dbms_utility.exec_ddl_statement('CREATE TABLE TFZGV_CLEANSING_MAPPING
      ( cm_guid_contract        VARCHAR2(32 CHAR) NOT NULL
      , cm_old_contract_number  VARCHAR2(30 CHAR) NOT NULL
      , cm_new_contract_number  VARCHAR2(30 CHAR) NOT NULL
      , cm_comment              VARCHAR2 (500 CHAR) NOT NULL
      )');
     dbms_utility.exec_ddl_statement('COMMENT ON TABLE  TFZGV_CLEANSING_MAPPING IS ''Merging-Splitting-Renumbering history for affected Vehicle Contracts.''');   
     dbms_utility.exec_ddl_statement('COMMENT ON COLUMN TFZGV_CLEANSING_MAPPING.cm_comment IS ''Mapping reason (Integrated to new contract DEF5658, renumbered DEF5660, etc.).''');
     dbms_utility.exec_ddl_statement('CREATE INDEX tfzgv_cleansmap_guidcontract_i ON TFZGV_CLEANSING_MAPPING(cm_guid_contract)');
     dbms_utility.exec_ddl_statement('CREATE UNIQUE INDEX tfzgv_cleansmap_old_contrnum_i ON tfzgv_cleansing_mapping(cm_old_contract_number,cm_new_contract_number)');
     dbms_output.put_line('Table TFZGV_CLEANSING_MAPPING created.');
  end;
/
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >


ALTER TABLE snt.TFZGVERTRAG         MODIFY CONSTRAINT VERTR_IDV_FZGV               DISABLE;
ALTER TABLE snt.TFZGVERTRAG         MODIFY CONSTRAINT XFK_FZGV_PARENT              DISABLE;
ALTER TABLE snt.TFZGV_CONTRACTS     MODIFY CONSTRAINT FZGV_ID_FZGVCO               DISABLE;
ALTER TABLE snt.TFZGKMSTAND         MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGKM        DISABLE;
ALTER TABLE snt.TFZGLAUFLEISTUNG    MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGLL        DISABLE;
ALTER TABLE snt.TFZGPREIS           MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGPR        DISABLE;
ALTER TABLE snt.TFZGRECHNUNG        MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGRE        DISABLE;
ALTER TABLE snt.TREP_RELEASE        MODIFY CONSTRAINT TFZGV_ID_REPREL              DISABLE;
ALTER TABLE snt.TSP_CONTRACT        MODIFY CONSTRAINT FKTSP_CONTRACT_TFZGVERTRAG   DISABLE;
ALTER TABLE snt.TCO_SUBSTITUTE      MODIFY CONSTRAINT FZGV_ID_CSUB                 DISABLE;
ALTER TABLE snt.TDOCUMENTS          MODIFY CONSTRAINT TFZGV_ID_TDOC                DISABLE;
ALTER TRIGGER snt.EXT_TFZGVERTRAG     DISABLE;


SET SERVEROUTPUT ON
-- DEBUG set TERMOUT ON
--        :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
--        :L_DATAWARNINGS_OCCURED:= :L_DATAWARNINGS_OCCURED+1;
--        :L_DATAERRORS_OCCURED:= :L_DATAERRORS_OCCURED+1;

DECLARE
   -- Variables and cusrors =====================================================
	l_main_ID_VERTRAG	tfzgvertrag.id_Vertrag%TYPE;
	l_main_ID_fzgvertrag	tfzgvertrag.id_fzgvertrag%TYPE;
	l_main_guid_contract	tfzgvertrag.guid_contract%TYPE;
	l_main_metacaption	tic_package.icp_caption%TYPE;
	l_metapackage_old	tic_package.guid_package%TYPE;
	l_metapackage_new	tic_package.guid_package%TYPE;
	l_main_fzgvc		tfzgv_contracts.id_seq_fzgvc%TYPE;
	l_id_cov		tdfcontr_variant.id_cov%TYPE;
	i			NUMBER;
	CURSOR cur_SELECT is
		select
			tfzgvertrag.ID_VERTRAG
			, tfzgvertrag.ID_FZGVERTRAG
			, tfzgvertrag.guid_contract
		from
			tfzgvertrag
			, tfzgv_contracts
			, TDFCONTR_VARIANT
		where
			tfzgvertrag.ID_VERTRAG like '%\_%' ESCAPE '\'
			and tfzgv_contracts.id_vertrag		= tfzgvertrag.id_vertrag
			and tfzgv_contracts.ID_FZGVERTRAG	= tfzgvertrag.ID_FZGVERTRAG
			and TDFCONTR_VARIANT.ID_COV		= TFZGV_CONTRACTS.ID_COV
			and TDFCONTR_VARIANT.COV_CAPTION	not like 'MIG_OOS%'
		order by
			ID_VERTRAG
			, ID_FZGVERTRAG
		;
	l_TARGET_ID_VERTRAG_OLD 		snt.tfzgvertrag.ID_VERTRAG%type;
	l_TARGET_ID_FZGVERTRAG_OLD 		snt.tfzgvertrag.ID_FZGVERTRAG%type;
	l_TARGET_GUID_CONTRACT			snt.tfzgvertrag.GUID_CONTRACT%type;
	l_TARGET_ID_VERTRAG_NEW 		snt.tfzgvertrag.ID_VERTRAG%type;
   -- change contract number

   PROCEDURE change_SV(I_ID_VERTRAG_OLD       snt.TFZGVERTRAG.ID_VERTRAG%TYPE
                      ,I_ID_FZGVERTRAG_OLD    snt.TFZGVERTRAG.ID_FZGVERTRAG%TYPE
                      ,I_ID_VERTRAG_NEW       snt.TFZGVERTRAG.ID_VERTRAG%TYPE
                      ,I_ID_FZGVERTRAG_NEW    snt.TFZGVERTRAG.ID_FZGVERTRAG%TYPE
                      ,I_CANCEL_3rd           BOOLEAN DEFAULT TRUE
                      )
   IS
      l_id_cov          tdfcontr_variant.id_cov%TYPE;
      l_cov_caption     tdfcontr_variant.cov_caption%TYPE;
      l_exportcount     NUMBER;
      l_contractcount   NUMBER;
      ALREADY_SENT      EXCEPTION;
      PRAGMA EXCEPTION_INIT(ALREADY_SENT, -20001);
   BEGIN

      IF I_ID_VERTRAG_NEW || I_ID_FZGVERTRAG_NEW <> I_ID_VERTRAG_OLD || I_ID_FZGVERTRAG_OLD
      THEN
      SELECT COUNT(*)
        INTO l_exportcount
        FROM tjournal_position jp, tfzgvertrag v
      WHERE     jop_foreign = v.guid_contract
             AND v.id_vertrag = I_ID_VERTRAG_OLD
             AND v.id_fzgvertrag = I_ID_FZGVERTRAG_OLD;

      IF     l_exportcount > 0
         AND I_CANCEL_3rd
      THEN
         RAISE ALREADY_SENT;
      END IF;

         -- DBMS_OUTPUT.PUT_LINE('INFO: updating contract ' || I_ID_VERTRAG_OLD || '/' || I_ID_FZGVERTRAG_OLD || '.');

         BEGIN
            INSERT INTO snt.TEXTD_TFZGVERTRAG
                 VALUES (SYSDATE, I_ID_VERTRAG_NEW, I_ID_FZGVERTRAG_OLD);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;

      -- a) within DataMart table TFZGVERTRAG cannot be updated like the other tables
      -- there has to be a delete of the old key value and insert of the new key value
      -- therefore the actual DataMart trigger EXT_TFZGVERTRAG has to be disabled and the DataMart actions have to be done manually
      -- within the other tables the DataMart trigger EXT_<tablename> does what we want -> no disable and do action manually needed
         UPDATE snt.TFZGVERTRAG
            SET EXT_CREATION_DATE   = SYSDATE
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- b) do the proper update
         UPDATE snt.TDCBE_CLOSREOP_CONTRACT
            SET DCBE_CRC_ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, DCBE_CRC_ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     DCBE_CRC_ID_VERTRAG = I_ID_VERTRAG_OLD
                AND DCBE_CRC_ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TDCBE_CLOSREOP_CONTRACT updated.');

         UPDATE snt.TSP_CONTRACT
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TSP_CONTRACT updated.');

         UPDATE snt.TCO_SUBSTITUTE
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TCO_SUBSTITUTE updated.');

         UPDATE snt.TDOCUMENTS
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TDOCUMENTS updated.');

         UPDATE snt.TREP_RELEASE
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TREP_RELEASE updated.');

         UPDATE snt.TFZGRECHNUNG
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGRECHNUNG updated.');

         UPDATE snt.TFZGPREIS
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGPREIS updated.');

         UPDATE snt.TFZGLAUFLEISTUNG
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGLAUFLEISTUNG updated.');

         UPDATE snt.TFZGKMSTAND
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGKMSTAND updated.');

         UPDATE snt.TFZGV_CONTRACTS
            SET ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW, ID_VERTRAG = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGV_CONTRACTS updated.');

         IF SQL%ROWCOUNT < 1
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         UPDATE snt.TFZGVERTRAG
            SET ID_FZGVERTRAG_PARENT = I_ID_FZGVERTRAG_NEW, ID_VERTRAG_PARENT = I_ID_VERTRAG_NEW
          WHERE     ID_VERTRAG_PARENT = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG_PARENT = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGVERTRAG (parent relationship) updated.');

         UPDATE snt.TFZGVERTRAG
            SET 
		            ID_FZGVERTRAG = I_ID_FZGVERTRAG_NEW
		          , ID_VERTRAG = I_ID_VERTRAG_NEW
		          , LAST_OPERATION = 'U'            
          WHERE     ID_VERTRAG = I_ID_VERTRAG_OLD
                AND ID_FZGVERTRAG = I_ID_FZGVERTRAG_OLD;

         -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' entries in TFZGVERTRAG updated.');

         IF SQL%ROWCOUNT < 1
         THEN
            RAISE NO_DATA_FOUND;
         END IF;


         BEGIN
            SELECT COUNT(*)
              INTO l_contractcount
              FROM tfzgvertrag
             WHERE id_vertrag = I_ID_VERTRAG_OLD;

            IF l_contractcount = 0
            THEN
               UPDATE tvertragstamm
                  SET id_vertrag   = I_ID_VERTRAG_NEW
                WHERE id_vertrag = I_ID_VERTRAG_OLD;
                            -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' customer contracts in TVERTRAGSTAMM changed. (update)');

            ELSE
               INSERT INTO tvertragstamm(ID_VERTRAG
                                        ,ID_CUSTOMER
                                        ,GUID_INDV
                                        ,ID_COS
                                        ,ID_GARAGE
                                        ,ID_GARAGE2
                                        ,ID_PAYM
                                        ,ID_CUSTOMER2
                                        ,ID_COV
                                        ,ID_PRV
                                        ,VERTR_BEARBEITER
                                        ,VERTR_OLD_NUMMER
                                        ,VERTR_BEGINN
                                        ,VERTR_ENDE
                                        ,VERTR_KMAUSGLRECH
                                        ,VERTR_KMAUSGLRECHAB
                                        ,VERTR_ANSPRECHPARTNER
                                        ,VERTR_ANSPRECHPARTNERTEL
                                        ,VERTR_TOLMEHRKMPRO
                                        ,VERTR_TOLMEHRKMKM
                                        ,VERTR_TOLMINDKMPRO
                                        ,VERTR_TOLMINDKMKM
                                        ,VERTR_GRATISKM
                                        ,VERTR_AE_BILL_TO
                                        ,VERTR_AE_SPLIT
                                        ,VERTR_AE_SPLIT_TYPE
                                        ,VERTR_IDX_PERCENT
                                        ,VERTR_IDX_NEXTDATE
                                        ,VERTR_CHECKED
                                        ,VERTR_CHECKED_BY
                                        )
                  SELECT I_ID_VERTRAG_NEW
                        ,ID_CUSTOMER
                        ,GUID_INDV
                        ,ID_COS
                        ,ID_GARAGE
                        ,ID_GARAGE2
                        ,ID_PAYM
                        ,ID_CUSTOMER2
                        ,ID_COV
                        ,ID_PRV
                        ,VERTR_BEARBEITER
                        ,VERTR_OLD_NUMMER
                        ,VERTR_BEGINN
                        ,VERTR_ENDE
                        ,VERTR_KMAUSGLRECH
                        ,VERTR_KMAUSGLRECHAB
                        ,VERTR_ANSPRECHPARTNER
                        ,VERTR_ANSPRECHPARTNERTEL
                        ,VERTR_TOLMEHRKMPRO
                        ,VERTR_TOLMEHRKMKM
                        ,VERTR_TOLMINDKMPRO
                        ,VERTR_TOLMINDKMKM
                        ,VERTR_GRATISKM
                        ,VERTR_AE_BILL_TO
                        ,VERTR_AE_SPLIT
                        ,VERTR_AE_SPLIT_TYPE
                        ,VERTR_IDX_PERCENT
                        ,VERTR_IDX_NEXTDATE
                        ,VERTR_CHECKED
                        ,VERTR_CHECKED_BY
                    FROM tvertragstamm
                   WHERE id_vertrag = i_ID_VERTRAG_OLD;
                   -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' customer contracts in TVERTRAGSTAMM changed. (insert)');
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE;                                                                                      -- vertrag ist nicht da
            WHEN DUP_VAL_ON_INDEX
            THEN
               IF l_contractcount = 0
               THEN
                  -- vertragsstamm existiert schon, --> altes löschen
                  DELETE FROM tvertragstamm
                        WHERE id_vertrag = I_ID_VERTRAG_OLD;

                  -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' customer contracts in TVERTRAGSTAMM dropped.');
               ELSE
                  NULL;                                                                                 --alles bleibt wie es ist.
                 -- DBMS_OUTPUT.PUT_LINE('INFO: +->' || SQL%ROWCOUNT || ' customer contracts in TVERTRAGSTAMM not changed. (not necessary)');
               END IF;
         END;


         -- DBMS_OUTPUT.put_line(
         --      'INFO: ==> Contract '
         --   || I_ID_VERTRAG_OLD
         --   || '/'
         --  || I_ID_FZGVERTRAG_OLD
         --   || ' successfully changed to '
         --   || I_ID_VERTRAG_NEW
         --   || '/'
         --   || I_ID_FZGVERTRAG_NEW);


         :L_DATASUCCESS_OCCURED   := :L_DATASUCCESS_OCCURED + 1;
      ELSE
         DBMS_OUTPUT.put_line(
               'ERR : Contract '
            || I_ID_VERTRAG_OLD
            || '/'
            || I_ID_FZGVERTRAG_OLD
            || ' could not be updated to '
            || I_ID_VERTRAG_NEW
            || '/'
            || I_ID_FZGVERTRAG_NEW
            || ' because old is equal to new contract.');
         :L_DATAWARNINGS_OCCURED   := :L_DATAWARNINGS_OCCURED + 1;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line(
               'ERR : Contract '
            || I_ID_VERTRAG_OLD
            || '/'
            || I_ID_FZGVERTRAG_OLD
            || ' could not be updated to '
            || I_ID_VERTRAG_NEW
            || '/'
            || I_ID_FZGVERTRAG_NEW
            || ' because old contract is not found');
         :L_DATAERRORS_OCCURED   := :L_DATAERRORS_OCCURED + 1;
      WHEN ALREADY_SENT
      THEN
         DBMS_OUTPUT.put_line(
               'ERR : Contract '
            || I_ID_VERTRAG_OLD
            || '/'
            || I_ID_FZGVERTRAG_OLD
            || ' could not be updated to '
            || I_ID_VERTRAG_NEW
            || '/'
            || I_ID_FZGVERTRAG_NEW
            || ' because contract is already SENT TO 3rd system(s).');
         :L_DATAERRORS_OCCURED   := :L_DATAERRORS_OCCURED + 1;
   END change_sv;

-- MAIN part ==================================================================

BEGIN

	begin
		open cur_SELECT;
		LOOP
			fetch cur_SELECT into l_TARGET_ID_VERTRAG_OLD, l_TARGET_ID_FZGVERTRAG_OLD, l_TARGET_GUID_CONTRACT;
			if cur_SELECT%NOTFOUND
			then
				if  cur_SELECT%ROWCOUNT <1
				then
					dbms_output.put_line ('INFO: No contracts with underscores found.');
				end if;
				exit;
			end if;

			if cur_SELECT%ROWCOUNT = 1
			then
				dbms_output.put_line ('INFO: Contract old; Contract corrected');
				dbms_output.put_line ('INFO: --------------------------------');
			end if;

			l_TARGET_ID_VERTRAG_NEW := replace(l_TARGET_ID_VERTRAG_OLD, '_', '0');
			change_sv(I_ID_VERTRAG_OLD      => l_TARGET_ID_VERTRAG_OLD
				,I_ID_FZGVERTRAG_OLD   => l_TARGET_ID_FZGVERTRAG_OLD
				,I_ID_VERTRAG_NEW      => l_TARGET_ID_VERTRAG_NEW
				,I_ID_FZGVERTRAG_NEW   => l_TARGET_ID_FZGVERTRAG_OLD
				,I_CANCEL_3rd        => FALSE
				);

			UPDATE
				tfzgvertrag
			SET
				fzgv_memo      =
					'Contract renamed from '
					|| l_TARGET_ID_VERTRAG_OLD
					|| '/'
					|| l_TARGET_ID_FZGVERTRAG_OLD
					|| ' by DEF7019 ~#~ '
					|| SUBSTR( fzgv_memo, 1, 1900)
			WHERE
				guid_contract = l_TARGET_GUID_CONTRACT
			;
      BEGIN
       INSERT INTO tfzgv_cleansing_mapping
          ( cm_guid_contract
          , cm_old_contract_number
          , cm_new_contract_number
          , cm_comment)
        VALUES
          ( l_TARGET_GUID_CONTRACT
          , l_TARGET_ID_VERTRAG_OLD || '/' || l_TARGET_ID_FZGVERTRAG_OLD
          , l_TARGET_ID_VERTRAG_NEW || '/' || l_TARGET_ID_FZGVERTRAG_OLD
          , 'integration in destination contract due to DEF7019'); 
      EXCEPTION WHEN dup_val_on_index THEN NULL;
      END;
			dbms_output.put_line ('INFO: ' || l_TARGET_ID_VERTRAG_OLD || '/' || l_TARGET_ID_FZGVERTRAG_OLD || '; ' || l_TARGET_ID_VERTRAG_NEW || '/' || l_TARGET_ID_FZGVERTRAG_OLD );
			:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + 1;
	
		END LOOP;
		close cur_SELECT;

	exception
		when others then
			dbms_output.put_line ( 'ERR-: ' || l_TARGET_ID_VERTRAG_OLD || '/' || l_TARGET_ID_FZGVERTRAG_OLD || ' COULD NOT BE MODIFIED:' || sqlerrm );
			:L_DATAERRORS_OCCURED:= :L_DATAERRORS_OCCURED+1;
	end;
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

ALTER TABLE snt.TCO_SUBSTITUTE    MODIFY CONSTRAINT FZGV_ID_CSUB               ENABLE VALIDATE;
ALTER TABLE snt.TDOCUMENTS        MODIFY CONSTRAINT TFZGV_ID_TDOC              ENABLE VALIDATE;
ALTER TABLE snt.TFZGKMSTAND       MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGKM      ENABLE VALIDATE;
ALTER TABLE snt.TFZGLAUFLEISTUNG  MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGLL      ENABLE VALIDATE;
ALTER TABLE snt.TFZGPREIS         MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGPR      ENABLE VALIDATE;
ALTER TABLE snt.TFZGRECHNUNG      MODIFY CONSTRAINT FZGV_IDV_IDFZGV_FZGRE      ENABLE VALIDATE;
ALTER TABLE snt.TFZGV_CONTRACTS   MODIFY CONSTRAINT FZGV_ID_FZGVCO             ENABLE VALIDATE;
ALTER TABLE snt.TFZGVERTRAG       MODIFY CONSTRAINT VERTR_IDV_FZGV             ENABLE VALIDATE;
ALTER TABLE snt.TFZGVERTRAG       MODIFY CONSTRAINT XFK_FZGV_PARENT            ENABLE VALIDATE;
ALTER TABLE snt.TREP_RELEASE      MODIFY CONSTRAINT TFZGV_ID_REPREL            ENABLE VALIDATE;
ALTER TABLE snt.TSP_CONTRACT      MODIFY CONSTRAINT FKTSP_CONTRACT_TFZGVERTRAG ENABLE VALIDATE;

ALTER TRIGGER snt.EXT_TFZGVERTRAG     ENABLE;

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
      DBMS_OUTPUT.put_line('===================');
      DBMS_OUTPUT.put_line(CHR(10));
      DBMS_OUTPUT.put_line('Dataset affected: ' || :L_DATASUCCESS_OCCURED);
      DBMS_OUTPUT.put_line('Data warnings   : ' || :L_DATAWARNINGS_OCCURED);
      DBMS_OUTPUT.put_line('Data errors     : ' || :L_DATAERRORS_OCCURED);
      DBMS_OUTPUT.put_line('System errors   : ' || :L_ERROR_OCCURED);
   END IF;
END;
/
EXIT;
