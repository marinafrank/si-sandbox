/* Formatted on 29.10.2014 15:52:44 (QP5 v5.185.11230.41888) */
-- DataCleansing_051_DEF5890_Add_attributepackages_to_Metapackages.sql.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-11-05; MKS-135213:1; TOKIENI; Initial Release
-- 2014-11-05; MKS-136569:1: MARZUHL; DEF7592 - Entfernung Complete LKW_BUNDLE/Complete Trapo_BUNDLE/Excellent Anhänger

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   DEFINE GL_SCRIPTNAME         = DataCleansing_051_DEF5890_Add_attributepackages_to_Metapackages
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
SET HEADING      ON
SET ECHO         OFF

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================



-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     OFF

ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_AFT DISABLE;


SET SERVEROUTPUT ON
-- DEBUG  set termout on
--        :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
--        :L_DATAWARNINGS_OCCURED:= :L_DATAWARNINGS_OCCURED+1;
--        :L_DATAERRORS_OCCURED:= :L_DATAERRORS_OCCURED+1;

DECLARE
   -- Variables and cusrors =====================================================
   l_main_ID_VERTRAG      tfzgvertrag.id_Vertrag%TYPE;
   l_main_ID_fzgvertrag   tfzgvertrag.id_fzgvertrag%TYPE;
   l_main_guid_contract   tfzgvertrag.guid_contract%TYPE;
   l_main_metacaption     tic_package.icp_caption%TYPE;
   l_metapackage_old      tic_package.guid_package%TYPE;
   l_metapackage_new      tic_package.guid_package%TYPE;
   l_main_fzgvc           tfzgv_contracts.id_seq_fzgvc%TYPE;
   l_id_cov               tdfcontr_variant.id_cov%TYPE;


   -- internal functions and code snippets ==========================================

   FUNCTION get_package(in_GUID_PACKAGE snt.TIC_PACKAGE.GUID_PACKAGE%TYPE)
      RETURN VARCHAR2
   IS
      L_RETURNVALUE   snt.TIC_PACKAGE.ICP_CAPTION%TYPE;
   BEGIN
      SELECT ICP_CAPTION
        INTO L_RETURNVALUE
        FROM snt.TIC_PACKAGE
       WHERE GUID_PACKAGE = in_GUID_PACKAGE;

      RETURN L_RETURNVALUE;
   END get_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_guid_package(I_ICP_CAPTION VARCHAR2)
      RETURN VARCHAR2
   IS
      -- search for "classic"-package with I_ICP_CAPTION
      -- if found: return guid_package
      -- if not found: show errow message package not existing ...

      L_GUID_PACKAGE   VARCHAR2(32);
   BEGIN
      -- get guid of package
      SELECT GUID_PACKAGE
        INTO L_GUID_PACKAGE
        FROM snt.TIC_PACKAGE tic
       WHERE tic.ICP_CAPTION = I_ICP_CAPTION;

      RETURN L_GUID_PACKAGE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line('ERR: package ' || I_ICP_CAPTION || ' does not exist');
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         DBMS_OUTPUT.put_line('ERR: package ' || I_ICP_CAPTION || ' exists multiple times');
         RETURN NULL;
   END get_guid_package;

   FUNCTION get_GUID_PACKAGE_LAST(I_GUID_CONTRACT snt.TFZGVERTRAG.GUID_CONTRACT%TYPE)
      RETURN VARCHAR2
   IS
      L_GUID_PACKAGE_LAST   snt.TIC_PACKAGE.GUID_PACKAGE%TYPE;
   BEGIN
      -- zuerst check, ob ein attributpaket topParent ist -> change METApaket to topParent, da METApaket unbedingt topParent sein muß!
      UPDATE snt.TIC_CO_PACK_ASS pac
         SET pac.GUID_PACKAGE_PARENT      =
                (SELECT p_meta.GUID_PACKAGE                                                            -- -> get GUID of METApaket
                   FROM snt.TIC_CO_PACK_ASS pac_meta, snt.TIC_PACKAGE p_meta
                  WHERE     pac_meta.GUID_CONTRACT = pac.GUID_CONTRACT
                        AND pac_meta.GUID_PACKAGE = p_meta.GUID_PACKAGE
                        AND 2 = p_meta.ICP_PACKAGE_TYPE)
       WHERE     pac.GUID_CONTRACT = I_GUID_CONTRACT
             AND pac.GUID_PACKAGE_PARENT IS NULL                                        -- -> wenn das attributpaket topParent ist
             AND EXISTS
                    (SELECT NULL
                       FROM snt.TIC_PACKAGE p
                      WHERE     p.GUID_PACKAGE = pac.GUID_PACKAGE
                            AND p.ICP_PACKAGE_TYPE <> 2);


      -- metapaket wird topParent, falls es noch nicht TopParent ist (-> GUID_PACKAGE_PARENT ist dann not null )
      UPDATE snt.TIC_CO_PACK_ASS pac
         SET pac.GUID_PACKAGE_PARENT   = NULL
       WHERE     pac.GUID_CONTRACT = I_GUID_CONTRACT
             AND pac.GUID_PACKAGE_PARENT IS NOT NULL
             AND EXISTS
                    (SELECT NULL
                       FROM snt.TIC_PACKAGE p
                      WHERE     p.GUID_PACKAGE = pac.GUID_PACKAGE
                            AND p.ICP_PACKAGE_TYPE = 2);

      BEGIN
         -- determine "last" package (-> jene mit höchstem level ) ausgehend von der row ohne GUID_PACKAGE_PARENT (-> das ist die oberste row )
         SELECT GUID_PACKAGE
           INTO L_GUID_PACKAGE_LAST
           FROM (  SELECT *
                     FROM (    SELECT GUID_PACKAGE, LEVEL lv
                                 FROM (SELECT GUID_PACKAGE, GUID_PACKAGE_PARENT
                                         FROM snt.TIC_CO_PACK_ASS
                                        WHERE GUID_CONTRACT = I_GUID_CONTRACT)
                           START WITH GUID_PACKAGE_PARENT IS NULL
                           CONNECT BY PRIOR GUID_PACKAGE = GUID_PACKAGE_PARENT)
                 ORDER BY lv DESC)
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN                                                                -- a) löschen alle package parent zuordnungen beim CO
            UPDATE snt.TIC_CO_PACK_ASS pac
               SET pac.GUID_PACKAGE_PARENT   = NULL
             WHERE pac.GUID_CONTRACT = I_GUID_CONTRACT;

            -- b) returnwert L_GUID_PACKAGE_LAST ist GUID von erster gefundenen package
            -- (-> eine pakethierarchie gibt es ja nicht mehr, da diese ja in b) komplett gelöscht wurde )
            SELECT GUID_PACKAGE
              INTO L_GUID_PACKAGE_LAST
              FROM snt.TIC_CO_PACK_ASS pac
             WHERE     pac.GUID_CONTRACT = I_GUID_CONTRACT
                   AND ROWNUM = 1;

            DBMS_OUTPUT.put_line('exact fetch CO / bad package assignment - fixed');
      END;

      RETURN L_GUID_PACKAGE_LAST;
   END get_GUID_PACKAGE_LAST;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION get_contract(in_GUID_CONTRACT snt.TFZGVERTRAG.GUID_CONTRACT%TYPE)
      RETURN VARCHAR2
   IS
      L_RETURNVALUE   VARCHAR2(20 CHAR);
   BEGIN
      SELECT ID_VERTRAG || '/' || ID_FZGVERTRAG
        INTO L_RETURNVALUE
        FROM snt.TFZGVERTRAG
       WHERE GUID_CONTRACT = in_GUID_CONTRACT;

      RETURN L_RETURNVALUE;
   END get_contract;

   PROCEDURE set_meta_package_top_level( IN_GUID_CONTRACT VARCHAR2, IN_GUID_PACKAGE VARCHAR2)
   IS
   -- correct position of META-package, set it on top-level

   BEGIN
      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent   = IN_GUID_PACKAGE
          WHERE     guid_package_parent IS NULL
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line('ERR: Set metapackage top level Step 1: ' || get_contract(IN_GUID_CONTRACT));
	    :L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
      END;

      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent   = NULL
          WHERE     guid_package = IN_GUID_PACKAGE
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line('ERR: Set metapackage top level Step 2: ' || get_contract(IN_GUID_CONTRACT));
	    :L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
      END;

      DBMS_OUTPUT.put_line('Set meta package top level for  contract: ' || get_contract(IN_GUID_CONTRACT));
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line('ERR: set_meta_package_top_level: ' || get_contract(IN_GUID_CONTRACT));
	 :L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
   END set_meta_package_top_level;

   -- check if METAPackage exists
   FUNCTION chk_if_MetaPackage_exists(I_ICP_CAPTION snt.TIC_PACKAGE.ICP_CAPTION%TYPE)
      RETURN VARCHAR2
   IS
      L_GUID_PACKAGE   snt.TIC_PACKAGE.GUID_PACKAGE%TYPE;
   BEGIN
      SELECT GUID_PACKAGE
        INTO L_GUID_PACKAGE
        FROM snt.TIC_PACKAGE
       WHERE     ICP_CAPTION = I_ICP_CAPTION
             AND ICP_PACKAGE_TYPE = 2;

      RETURN L_GUID_PACKAGE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         :L_DATAWARNINGS_OCCURED   := :L_DATAWARNINGS_OCCURED + 1;
         DBMS_OUTPUT.put_line('WARN: MetaPackage ' || I_ICP_CAPTION || ' does not exist!');
         RETURN NULL;
   END chk_if_MetaPackage_exists;



   PROCEDURE correct_or_add_package( I_GUID_CONTRACT snt.TFZGVERTRAG.GUID_CONTRACT%TYPE, I_GUID_PACKAGE_LAST snt.TIC_PACKAGE.GUID_PACKAGE%TYPE, I_ICP_CAPTION_ATTRIB_NEW snt.TIC_PACKAGE.ICP_CAPTION%TYPE, I_GUID_PACKAGE_ATTRIB_NEW snt.TIC_PACKAGE.GUID_PACKAGE%TYPE DEFAULT NULL)
   IS
      I_GUID_VEGA_I55A            snt.tvega_i55_attribute.guid_vi55A%TYPE;
      L_GUID_PACKAGE_SAME_VEGA    snt.TIC_PACKAGE.GUID_PACKAGE%TYPE; -- guid of existing package that drives the same vega-attribute as the new attribute package
      L_ICP_CAPTION_SAME_VEGA     snt.TIC_PACKAGE.ICP_CAPTION%TYPE; -- its caption (-> only needed for dbms_output.putline (-> ne caption sagt mehr als eine GUID ))
      L_GUID_PACKAGE_ATTRIB_NEW   snt.TIC_PACKAGE.guid_package%TYPE;
      l_icp_package_type          snt.tic_package.icp_package_type%TYPE;
   BEGIN
      IF I_GUID_PACKAGE_ATTRIB_NEW IS NULL
      THEN
         L_GUID_PACKAGE_ATTRIB_NEW   := get_guid_package(I_ICP_CAPTION_ATTRIB_NEW);
      ELSE
         L_GUID_PACKAGE_ATTRIB_NEW   := I_GUID_PACKAGE_ATTRIB_NEW;
      END IF;

      -- ermittle guid_vi55A des Pakets
      BEGIN
         SELECT av.guid_vi55A, p.icp_package_type
           INTO I_GUID_VEGA_I55A, l_icp_package_Type
           FROM tvega_i55_att_value av, tic_package p
          WHERE     p.guid_vi55av = av.guid_vi55av
                AND icp_caption = I_ICP_CAPTION_ATTRIB_NEW;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line('ERR : New Attribute Package ' || I_ICP_CAPTION_ATTRIB_NEW || ' not found - could not be assigned');
            RAISE;
      END;

      -- zuerst check, ob beim CO schon ein paket angelegt ist, für das dasselbe vega-attribute definiert ist, wie beim neuen attributpaket
      -- (-> ein VEGA attribut darf ja nur ein einziges mal bei einem CO angelegt sein )
      BEGIN
         SELECT copa.GUID_PACKAGE, icp.ICP_CAPTION
           INTO L_GUID_PACKAGE_SAME_VEGA, L_ICP_CAPTION_SAME_VEGA
           FROM snt.TIC_PACKAGE icp, snt.TIC_CO_PACK_ASS copa
          WHERE     copa.GUID_CONTRACT = I_GUID_CONTRACT
                AND copa.GUID_VI55A = I_GUID_VEGA_I55A
                AND copa.GUID_PACKAGE = icp.GUID_PACKAGE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF L_GUID_PACKAGE_SAME_VEGA IS NOT NULL              -- -> wenn ja (-> GUID PACKAGE des CO mit derselben VEGAattribut-GUID )
      THEN
         BEGIN                                              -- -> dieses package bekommt die GUID package des neuen attributpakets
            UPDATE snt.TIC_CO_PACK_ASS
               SET GUID_PACKAGE   = L_GUID_PACKAGE_ATTRIB_NEW
             WHERE     GUID_CONTRACT = I_GUID_CONTRACT
                   AND GUID_PACKAGE = L_GUID_PACKAGE_SAME_VEGA;

            UPDATE snt.TIC_CO_PACK_ASS -- -> dasselbe muß auch mit dem parent paket geschehen, sonst bleibt die alte GUID_PACKAGE_PARENT als leiche stehen
               SET GUID_PACKAGE_PARENT   = L_GUID_PACKAGE_ATTRIB_NEW
             WHERE     GUID_CONTRACT = I_GUID_CONTRACT
                   AND GUID_PACKAGE_PARENT = L_GUID_PACKAGE_SAME_VEGA;
         EXCEPTION
            WHEN OTHERS
            THEN
               :L_ERROR_OCCURED   := :L_ERROR_OCCURED + 1;
               DBMS_OUTPUT.put_line(SQLERRM);
               DBMS_OUTPUT.put_line('Set ' || I_ICP_CAPTION_ATTRIB_NEW || ' not possible - OLD: ' || L_ICP_CAPTION_SAME_VEGA);
         END;
      ELSE                                  -- -> L_GUID_PACKAGE_SAME_VEGA is null (-> add attribute-packages after last package )
         /*         DBMS_OUTPUT.put_line (   'I_GUID_CONTRACT:           '
                                        || I_GUID_CONTRACT );
                  DBMS_OUTPUT.put_line (   'I_ICP_CAPTION_ATTRIB_NEW:  '
                                        || I_ICP_CAPTION_ATTRIB_NEW );
                  DBMS_OUTPUT.put_line (   'L_GUID_PACKAGE_ATTRIB_NEW: '
                                        || L_GUID_PACKAGE_ATTRIB_NEW );
                  DBMS_OUTPUT.put_line (   'L_GUID_PACKAGE_SAME_VEGA:  '
                                        || L_GUID_PACKAGE_SAME_VEGA );
                  DBMS_OUTPUT.put_line (   'I_GUID_VEGA_I55A:  '
                                        || I_GUID_VEGA_I55A );
                  DBMS_OUTPUT.put_line (   'L_icp_package_type:  '
                                        || L_icp_package_type );
         */
         BEGIN
            INSERT INTO snt.TIC_CO_PACK_ASS( GUID_CONTRACT, GUID_PACKAGE, GUID_PACKAGE_PARENT, GUID_VI55A)
                 VALUES (I_GUID_CONTRACT, L_GUID_PACKAGE_ATTRIB_NEW, I_GUID_PACKAGE_LAST, I_GUID_VEGA_I55A);
         -- dbms_output.put_line ( 'insert GUID_PACKAGE.' || I_ICP_CAPTION_NEW );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
               :L_DATAWARNINGS_OCCURED   := :L_DATAWARNINGS_OCCURED + 1;
               DBMS_OUTPUT.put_line('WARN: PACKAGE: ' || I_ICP_CAPTION_ATTRIB_NEW || ' is already assigned to CO'); -- package is already assigned
            WHEN OTHERS
            THEN
               :L_ERROR_OCCURED   := :L_ERROR_OCCURED + 1;
               DBMS_OUTPUT.put_line(
                  'ERR :PACKAGE: ' || I_ICP_CAPTION_ATTRIB_NEW || ' could not be assigned to CO due to ' || SQLERRM);
         END;
      END IF;
   END correct_or_add_package;

   -- assign attribute package to ALL Contracts having the meta_package
   PROCEDURE assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META snt.TIC_PACKAGE.ICP_CAPTION%TYPE, I_ICP_CAPTION_ATTRIB_NEW snt.TIC_PACKAGE.ICP_CAPTION%TYPE)
   IS
      L_GUID_PACKAGE_LAST         snt.TIC_PACKAGE.GUID_PACKAGE%TYPE;
      L_GUID_PACKAGE_META         snt.TIC_PACKAGE.GUID_PACKAGE%TYPE;
      L_GUID_PACKAGE_ATTRIB_NEW   snt.TIC_PACKAGE.GUID_PACKAGE%TYPE;
      L_GUID_VI55A_ATTRIB_NEW     snt.TVEGA_I55_ATT_VALUE.GUID_VI55A%TYPE; -- guid of i55 attribute       driven by new AttributePackage
   BEGIN
      DBMS_OUTPUT.put_line(
            CHR(10)
         || 'INFO: adding AttributePackage '''
         || I_ICP_CAPTION_ATTRIB_NEW
         || ''' to following contracts with MetaPackage '''
         || I_ICP_CAPTION_META
         || ''':');
      L_GUID_PACKAGE_ATTRIB_NEW   := get_guid_package(I_ICP_CAPTION_ATTRIB_NEW);
      L_GUID_PACKAGE_META         := chk_if_MetaPackage_exists(I_ICP_CAPTION_META);

      IF     L_GUID_PACKAGE_META IS NOT NULL
         AND L_GUID_PACKAGE_ATTRIB_NEW IS NOT NULL                --- sowohl das Meta- als auch Attributpaket müssen angelegt sein
      THEN                                                       --- sonst wird das Attributpaket nicht an die verträge angehängt!
         FOR co_packass_meta_rec IN (  SELECT cpa.GUID_CONTRACT, fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG
                                         FROM snt.TFZGVERTRAG fzgv, snt.TIC_CO_PACK_ASS cpa
                                        WHERE     cpa.GUID_PACKAGE = L_GUID_PACKAGE_META
                                              AND cpa.GUID_CONTRACT = fzgv.GUID_CONTRACT
                                              AND NOT EXISTS
                                                     (SELECT NULL
                                                        FROM snt.TIC_CO_PACK_ASS cpa1
                                                       WHERE     cpa1.GUID_CONTRACT = cpa.GUID_CONTRACT
                                                             AND cpa1.GUID_PACKAGE = L_GUID_PACKAGE_ATTRIB_NEW)
                                     ORDER BY 2, 3, 1)
         LOOP
            DBMS_OUTPUT.put_line('INFO: +-> '||co_packass_meta_rec.ID_VERTRAG || '/' || co_packass_meta_rec.ID_FZGVERTRAG);

            L_GUID_PACKAGE_LAST   := get_GUID_PACKAGE_LAST(I_GUID_CONTRACT => co_packass_meta_rec.GUID_CONTRACT);

            correct_or_add_package( I_GUID_CONTRACT => co_packass_meta_rec.GUID_CONTRACT, I_GUID_PACKAGE_LAST => L_GUID_PACKAGE_LAST, I_ICP_CAPTION_ATTRIB_NEW => I_ICP_CAPTION_ATTRIB_NEW, I_GUID_PACKAGE_ATTRIB_NEW => L_GUID_PACKAGE_ATTRIB_NEW);
            :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED+1;
            
         END LOOP;
      END IF;
   END assign_AttribPack_to_MetaPack;

   -- get last duration of an contract
   FUNCTION get_IdSeqFzgvc_ofLastDuration( i_ID_VERTRAG VARCHAR2, i_id_fzgvertrag VARCHAR2)
      RETURN VARCHAR2
   IS
      L_id_seq_fzgvc   TFZGV_CONTRACTS.ID_SEQ_FZGVC%TYPE;
   BEGIN
      SELECT id_seq_fzgvc
        INTO L_id_seq_fzgvc
        FROM TFZGV_CONTRACTS vc
       WHERE     ROWNUM = 1
             AND (vc.ID_VERTRAG, vc.id_fzgvertrag, vc.FZGVC_BEGINN) IN (  SELECT cust1.ID_VERTRAG, cust1.id_fzgvertrag, MAX(cust1.FZGVC_BEGINN)
                                                                            FROM TFZGV_CONTRACTS cust1
                                                                           WHERE     cust1.ID_VERTRAG = i_ID_VERTRAG
                                                                                 AND cust1.id_fzgvertrag = i_id_fzgvertrag
                                                                        GROUP BY cust1.ID_VERTRAG, cust1.id_fzgvertrag);

      RETURN L_id_seq_fzgvc;
   END get_IdSeqFzgvc_ofLastDuration;


-- MAIN part ==================================================================
BEGIN
    -- Attributpaket anlegen
    begin  
       insert into tic_package ( id_package, icp_caption, icp_package_type, guid_vi55av) values (SNT.TIC_PACKAGE_SEQ.nextval,'Safety_Inspection', 1,'EBBF0CE3B28448598232BB5B1891DE2F');
    exception
      when dup_val_on_index then
        NULL; -- paket gibts schon
    end;
    
    -- Attributpaket zuweisen
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete LKW', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    -- disabled by MKS-136569:1 -> assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete LKW_BUNDLE', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete LKW+PowerPack', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete LKW+PowerPack_BUNDLE', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete Trapo', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    -- disabled by MKS-136569:1 -> assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete Trapo_BUNDLE', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete Trapo+PowerPack', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Complete Trapo+PowerPack_BUNDLE', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    -- disabled by MKS-136569:1 -> assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Excellent Anhänger', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Excellent Busse', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Excellent Fleet', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');
    assign_AttribPack_to_MetaPack( I_ICP_CAPTION_META=>'Excellent PKW', I_ICP_CAPTION_ATTRIB_NEW=>'Safety_Inspection');

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
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_AFT ENABLE;
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
      DBMS_OUTPUT.put_line('Dataset affected: ' || :L_DATASUCCESS_OCCURED);
      DBMS_OUTPUT.put_line('Data warnings   : ' || :L_DATAWARNINGS_OCCURED);
      DBMS_OUTPUT.put_line('Data errors     : ' || :L_DATAERRORS_OCCURED);
      DBMS_OUTPUT.put_line('System errors   : ' || :L_ERROR_OCCURED);
   END IF;
END;
/
EXIT;