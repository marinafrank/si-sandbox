-- DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.sql
-- Original file-names: corr_wrong_precision.sql/chk_wrong_precision.sql

-- 02.04.2012 FraBe creation due to REQ650 (chk_wrong_precision.sql)
-- 25.05.2012 FraBe MKS-112871:2 script ausweiten auch auf negativ - dort haben wir dasselbe problem!
--                               -> use abs
-- 25.05.2012 FraBe MKS-112871:2 creation (corr_wrong_precision.sql)
-- 06.02.2014 zisco MKS-130162:1 wrap it into our default skript-template
-- 13.02.2014 TK MKS-130162:1 add CI_Amount

SPOOL DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.log

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
VARIABLE L_SCRIPTNAME    VARCHAR2 ( 300 CHAR );
EXEC :L_SCRIPTNAME       := 'DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.sql';

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
   L_REVISION_MIN INTEGER := 0;
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
   L_MPC_CHECK    BOOLEAN := FALSE;                           -- false or true
   L_MPC_SOLL     snt.TGLOBAL_SETTINGS.VALUE%TYPE := 'MBBeLux';
   L_MPC_IST      snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName');

   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
   L_REEXEC_FORBIDDEN BOOLEAN := FALSE;                       -- false or true
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

ACCEPT commit_or_rollback PROMPT "Do you want to save the changes to the DB? Y/N: "

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

-- < 0: pre - actions like deactivating constraint or trigger >
SET FEEDBACK     ON
SET FEEDBACK     1

-- main part for correction of wrong precision

-- 1st:
PROMPT
PROMPT correct records with wrong precision
PROMPT

DECLARE
   PROCEDURE cleanupfield ( ttablename VARCHAR2, tcolumnname VARCHAR2)
   IS
      mysql          VARCHAR2 (3000);
   BEGIN
      DBMS_OUTPUT.put_line
      (
         'Fixing Column ' || ttablename || '.' || tcolumnname || ''
      );
      mysql      :=
            'update '
         || ttablename
         || ' set '
         || tcolumnname
         || ' = 0 where abs ('
         || tcolumnname
         || ')  < 0.00000000000001 and  abs ('
         || tcolumnname
         || ')  > 0.000000000000001 and length (to_char(abs('
         || tcolumnname
         || '))) = 30';

      EXECUTE IMMEDIATE (mysql);
      dbms_output.put_line (sql%rowcount || ' Cells fixed.');
   END;
   
BEGIN
   cleanupfield ( 'snt.TADRASSOZ', 'ID_SEQ_NAME');
   cleanupfield ( 'snt.TCAMPAIGN', 'CAMP_PRICE');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_ADMIN_FEE');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_CAUSE_OF_RETIRE');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_END_KM');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_PROFIT_LOSS');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_REFUND');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_AMOUNT_CUST');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_AMOUNT_GAR');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_AMOUNT_MPC');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_PERC_CUST');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_PERC_GAR');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SHARE_PERC_MPC');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SUM_CAMPAIGN');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SUM_CUST_TYPE_0');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SUM_CUST_TYPE_1');
   cleanupfield ( 'snt.TCO_FINAL_CLOSE', 'COFC_SUM_WORKSHOP');
   cleanupfield ( 'snt.TCO_SUBSTITUTE', 'CSUB_PRICE_COMPONENT');
   cleanupfield ( 'snt.TCO_SUBSTITUTE', 'ID_GARAGE');
   cleanupfield ( 'snt.TCOMMUNICATION', 'ID_NAME');
   cleanupfield ( 'snt.TCONTRACT_CAMPAIGN', 'CONCAMP_AMOUNT');
   cleanupfield ( 'snt.TCONTRACT_CAMPAIGN', 'CONCAMP_AMOUNT_SIRIUS');
   cleanupfield ( 'snt.TCONTRACT_SUBSIDIZING', 'CONSUBS_AMOUNT');
   cleanupfield ( 'snt.TCONTRACT_SUBSIDIZING', 'ID_GARAGE');
   cleanupfield ( 'snt.TCOUNTRY', 'COU_USED');
   cleanupfield ( 'snt.TCURRENCY', 'CUR_USED');
   cleanupfield ( 'snt.TCUSTOMER', 'CUST_BEGIN_PRICE_VALIDITY');
   cleanupfield ( 'snt.TCUSTOMER', 'CUST_INVOICE_CONS_METHOD');
   cleanupfield ( 'snt.TCUSTOMER', 'CUST_RPB_MAX_MONTH');
   cleanupfield ( 'snt.TCUSTOMER', 'TRANSACTION_ID');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE', 'CI_AMOUNT');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE', 'CI_FOREIGN_EXCHANGE_RATE');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE', 'CI_ID_SEQ_FZGKMSTAND');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE', 'TRANSACTION_ID');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE_POS', 'CIP_AMOUNT');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE_POS', 'CIP_POSITION');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE_POS', 'CIP_QUANTITY');
   cleanupfield ( 'snt.TCUSTOMER_INVOICE_POS', 'CIP_VAT_RATE');
   cleanupfield ( 'snt.TDCBE_CLOSREOP_CONTRACT', 'DCBE_CRC_AMOUNT');
   cleanupfield ( 'snt.TDD_ID_TABLE_COLUMN', 'SSI_OBJECT');
   cleanupfield ( 'snt.TDF_PAYMENT', 'PAYM_NETTO_DAYS');
   cleanupfield ( 'snt.TDFCONTR_STATE', 'COS_HANDLE_CORRINV');
   cleanupfield ( 'snt.TDFCONTR_STATE', 'COS_HANDLE_FININV');
   cleanupfield ( 'snt.TDFCONTR_STATE', 'COS_HANDLE_LIS');
   cleanupfield ( 'snt.TDFCONTR_STATE', 'COS_HANDLE_MILBAINV');
   cleanupfield ( 'snt.TDFCONTR_STATE', 'ID_COS');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_HANDLE_ADMINFEE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_LEASING_SIVECO');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_GEWINN_CUSTOMER');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_GEWINN_GARAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_GEWINN_MB');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_VERLUST_CUSTOMER');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_VERLUST_GARAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_NORMAL_VERLUST_MB');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_RUNPOWER_BALANCINGMETHOD');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_RUNPOWER_TOLERANCE_DAY');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_RUNPOWER_TOLERANCE_PERC');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_USE_ADD_MILEAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_USE_CONSV_PRIME');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_USE_LESS_MILEAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_GEWINN_CUSTOMER');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_GEWINN_GARAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_GEWINN_MB');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_VERLUST_CUSTOMER');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_VERLUST_GARAGE');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'COV_VORZ_VERLUST_MB');
   cleanupfield ( 'snt.TDFCONTR_VARIANT', 'ID_PRV');
   cleanupfield ( 'snt.TDFEXP_DATABASE', 'ID_TED');
   cleanupfield ( 'snt.TDFEXP_PARAM_TYPE', 'ID_TEPT');
   cleanupfield ( 'snt.TDFEXP_PARAM_TYPE', 'TEPT_DATATYPE');
   cleanupfield ( 'snt.TDFLL_EINHEIT', 'ID_LLEINHEIT');
   cleanupfield ( 'snt.TDFLL_EINHEIT', 'LLEH_KM_RATE');
   cleanupfield ( 'snt.TDFPAYMODE', 'PAYM_DIRECTION');
   cleanupfield ( 'snt.TDFPAYMODE', 'PAYM_SUMMARY_POSITIONS');
   cleanupfield ( 'snt.TDFPAYMODE', 'PAYM_TARGETDATE_CI');
   cleanupfield ( 'snt.TEMP_PATCH_LOG', 'PATCH_ID');
   cleanupfield ( 'snt.TEXP_ENTITY', 'ID_TED');
   cleanupfield ( 'snt.TEXP_ENTITY', 'ID_TEE');
   cleanupfield ( 'snt.TEXP_ENTITY', 'TEE_CONVERT');
   cleanupfield ( 'snt.TEXP_ENTITY', 'TEE_SCHEDULED');
   cleanupfield ( 'snt.TEXP_FORMAT', 'ID_TEE');
   cleanupfield ( 'snt.TEXP_PARAM', 'ID_SEQ');
   cleanupfield ( 'snt.TEXP_PARAM', 'ID_TEE');
   cleanupfield ( 'snt.TEXP_PARAM', 'ID_TEPT');
   cleanupfield ( 'snt.TEXP_PARAM', 'TEP_LENGTH');
   cleanupfield ( 'snt.TEXP_PARAM', 'TEP_ORDER');
   cleanupfield ( 'snt.TEXP_PARAM', 'TEP_PARAM_TYP');
   cleanupfield ( 'snt.TEXP_SCHEDULED_EXPORTS', 'TSE_EXPORTNUMBER');
   cleanupfield ( 'snt.TEXP_SCHEDULED_EXPORTS', 'TSE_FINISH_STATE');
   cleanupfield ( 'snt.TEXP_SCHEDULED_EXPORTS', 'TSE_OVERWRITE');
   cleanupfield ( 'snt.TEXP_SCHEDULED_EXPORTS', 'TSE_SHOW_ENTRY');
   cleanupfield ( 'snt.TEXT_COS_LASTCHANGE', 'ID_COS_NEW');
   cleanupfield ( 'snt.TEXTD_TFZGKMSTAND', 'ID_SEQ_FZGKMSTAND');
   cleanupfield ( 'snt.TEXTD_TFZGLAUFLEISTUNG', 'ID_SEQ_FZGLAUFLEISTUNG');
   cleanupfield ( 'snt.TEXTD_TFZGPREIS', 'ID_SEQ_FZGPREIS');
   cleanupfield ( 'snt.TEXTD_TFZGRECHNUNG', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TEXTD_TFZGV_CONTRACTS', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TEXTD_TGARAGE', 'ID_GARAGE');
   cleanupfield ( 'snt.TEXTD_TIC_IH_CHECK_ITEM', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TEXTD_TNAME', 'ID_SEQ_NAME');
   cleanupfield ( 'snt.TFINANCIAL_SYSTEM', 'FINSYS_ID_BELEGART_FW');
   cleanupfield ( 'snt.TFINANCIAL_SYSTEM', 'FINSYS_ID_BELEGART_FW_CANC');
   cleanupfield ( 'snt.TFINANCIAL_SYSTEM', 'FINSYS_ID_BELEGART_REJECT');
   cleanupfield ( 'snt.TFINANCIAL_SYSTEM', 'FINSYS_ID_BELEGART_REJECT_CANC');
   cleanupfield ( 'snt.TFZGKMSTAND', 'FZGKM_BETRAG');
   cleanupfield ( 'snt.TFZGKMSTAND', 'FZGKM_KM');
   cleanupfield ( 'snt.TFZGKMSTAND', 'ID_SEQ_FZGKMSTAND');
   cleanupfield ( 'snt.TFZGKMSTAND', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'FZGLL_FREE_MILEAGE');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'FZGLL_LAUFLEISTUNG');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'FZGLL_LAUFLEISTUNG_OLD');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'ID_LLEINHEIT');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'ID_RPCAT');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'ID_RPCAT_OLD');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'ID_SEQ_FZGLAUFLEISTUNG');
   cleanupfield ( 'snt.TFZGLAUFLEISTUNG', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_ADMINCHARGE');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_ADMINFEE');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_BEGIN_MILEAGE');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_DISCAS');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_DISCAS_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_END_MILEAGE');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_MLP');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_MLP_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_PREIS_FIX');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_PREIS_GRKM_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_PREIS_MONATP_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_SUBBU');
   cleanupfield ( 'snt.TFZGPREIS', 'FZGPR_SUBBU_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'ID_RPCAT');
   cleanupfield ( 'snt.TFZGPREIS', 'ID_RPCAT_OLD');
   cleanupfield ( 'snt.TFZGPREIS', 'ID_SEQ_FZGPREIS');
   cleanupfield ( 'snt.TFZGPREIS', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_ANZAHL_AW1');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_ANZAHL_AW2');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_AWSUMME');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_ID_ORDER');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_KURS');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_MATBRUTTO');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_MATNETTO');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_REFERENZBUCHUNG');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_RESUMME');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_RL_ID');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_SP_MILEAGE_RATE');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_SUM_OTHER');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'FZGRE_SUM_REJECTED');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TFZGRECHNUNG', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'FZGVC_RPB_MAX_MONTH');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'FZGVC_RUNPOWER_TOLERANCE_DAY');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'FZGVC_RUNPOWER_TOLERANCE_PERC');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'ID_SEQ_FZGKMSTAND_BEGIN');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'ID_SEQ_FZGKMSTAND_END');
   cleanupfield ( 'snt.TFZGV_CONTRACTS', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_ADMIN_FEE');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_CONTRACT_VALUE');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_FIXED_LABOUR_RATE');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_MANUAL_OVERRULE_I55');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_PROV_AMOUNT');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_PROV_ID_GARAGE');
   cleanupfield ( 'snt.TFZGVERTRAG', 'FZGV_SCARD_COUNT');
   cleanupfield ( 'snt.TFZGVERTRAG', 'ID_COS');
   cleanupfield ( 'snt.TFZGVERTRAG', 'ID_GARAGE');
   cleanupfield ( 'snt.TFZGVERTRAG', 'ID_GARAGE_SERV');
   cleanupfield ( 'snt.TFZGVERTRAG', 'ID_PRICELIST');
   cleanupfield ( 'snt.TFZGVERTRAG', 'TRANSACTION_ID');
   cleanupfield ( 'snt.TGAR_ITEM', 'GAI_PRICE');
   cleanupfield ( 'snt.TGAR_ITEM', 'ID_GARAGE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_ANAUFLIEGER');
   cleanupfield ( 'snt.TGARAGE', 'GAR_FREMDHERSTELLER');
   cleanupfield ( 'snt.TGARAGE', 'GAR_GELAENDEWAGEN');
   cleanupfield ( 'snt.TGARAGE', 'GAR_LEICHTEKLASSE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_MA_PRICE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_MITTLEREKLASSE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_OMNIBUSSE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_PKW');
   cleanupfield ( 'snt.TGARAGE', 'GAR_SCHWEREKLASSE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_SONDERFAHRZEUGE');
   cleanupfield ( 'snt.TGARAGE', 'GAR_TRANSPORTER_T1');
   cleanupfield ( 'snt.TGARAGE', 'GAR_TRANSPORTER_T2');
   cleanupfield ( 'snt.TGARAGE', 'GAR_UNIMOG_MBTRAC');
   cleanupfield ( 'snt.TGARAGE', 'ID_GARAGE');
   cleanupfield ( 'snt.TI56_RT20', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TIC_CHECK_ITEM', 'ICI_NUMBER');
   cleanupfield ( 'snt.TIC_CHECK_RESULT', 'ID_CHECK_RESULT');
   cleanupfield ( 'snt.TIC_IH_CHECK_ITEM', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TIC_IH_CHECK_ITEM', 'IHCI_RESULT');
   cleanupfield ( 'snt.TIC_IMPT_CHKITM', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TIC_INTERVAL_UNIT', 'ID_INTERVAL_UNIT');
   cleanupfield ( 'snt.TIC_IP_CHECK_ITEM', 'IPCI_RESULT');
   cleanupfield ( 'snt.TIC_PACKAGE', 'ID_PACKAGE');
   cleanupfield ( 'snt.TIC_PACKAGE_REPCODE', 'ICPR_INTERVAL');
   cleanupfield ( 'snt.TIC_PACKAGE_REPCODE', 'ID_INTERVAL_UNIT');
   cleanupfield ( 'snt.TIC_PACKAGE_SUBREPCODE', 'ICPSR_INTERVAL');
   cleanupfield ( 'snt.TIC_PACKAGE_SUBREPCODE', 'ID_INTERVAL_UNIT');
   cleanupfield ( 'snt.TIIINV_XML_HEADER', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TIIINV_XML_HEADER', 'IIIXH_ID_CHECK_RESULT');
   cleanupfield ( 'snt.TIMPORT_EVENT', 'ID_FOREIGN_SEQ');
   cleanupfield ( 'snt.TIMPORT_EVENT', 'ID_IMET');
   cleanupfield ( 'snt.TIMPORT_EVENT', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TIMPORT_EVENT_TYPE', 'ID_IMPET');
   cleanupfield ( 'snt.TIMPORT_TYPE', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TIMPORT_TYPE', 'ID_IMP_TYPE_PARENT');
   cleanupfield ( 'snt.TIMPT_TO_XML', 'ID_IMP_TYPE');
   cleanupfield ( 'snt.TINDEXATION', 'IND_BASE_PARTS');
   cleanupfield ( 'snt.TINDEXATION', 'IND_BASE_SERVICE');
   cleanupfield ( 'snt.TINV_POSITION', 'I50_POSINDEX');
   cleanupfield ( 'snt.TINV_POSITION', 'ID_CHECK_RESULT');
   cleanupfield ( 'snt.TINV_POSITION', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_I56_DAM_NR');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_I56_DEC_NR');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_I56_POS_NR');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_SUM_OTHER');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_SUM_PART');
   cleanupfield ( 'snt.TINV_POSITION', 'IP_SUM_WORK');
   cleanupfield ( 'snt.TINVHEAD_CHECK_RESULT', 'ID_CHECK_RESULT');
   cleanupfield ( 'snt.TINVHEAD_CHECK_RESULT', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TINVPOS_CHECK_RESULT', 'ID_CHECK_RESULT');
   cleanupfield ( 'snt.TINVPOS_CHECK_RESULT', 'ID_SEQ');
   cleanupfield ( 'snt.TITEM', 'ITM_LISTPRICE');
   cleanupfield ( 'snt.TITEM', 'ITM_SPICS_NETPRICE');
   cleanupfield ( 'snt.TITEM_HIST_PRICE', 'IHP_LISTPRICE');
   cleanupfield ( 'snt.TITEM_HIST_PRICE', 'IHP_NETTOPRICE');
   cleanupfield ( 'snt.TITEM_SSL_CODE', 'SSL_COUNT');
   cleanupfield ( 'snt.TJOURNAL_POSITION', 'JOP_FOREIGN_NUM');
   cleanupfield ( 'snt.TLANGUAGE', 'LANG_CODE_WISASRA');
   cleanupfield ( 'snt.TLANGUAGE', 'LANG_USED');
   cleanupfield ( 'snt.TMESONIC_MBOE', 'AMOUNT');
   cleanupfield ( 'snt.TMESONIC_MBOE', 'PAYM_NETTO_DAYS');
   cleanupfield ( 'snt.TNAME', 'ID_SEQ_NAME');
   cleanupfield ( 'snt.TNUMBERRANGE', 'NUMRANGE_CURRENT');
   cleanupfield ( 'snt.TNUMBERRANGE', 'NUMRANGE_FROM');
   cleanupfield ( 'snt.TNUMBERRANGE', 'NUMRANGE_TO');
   cleanupfield ( 'snt.TPARTNER', 'ID_GARAGE');
   cleanupfield ( 'snt.TREP_RELEASE', 'ID_GARAGE');
   cleanupfield ( 'snt.TREP_RELEASE', 'REPR_MILEAGE');
   cleanupfield ( 'snt.TRP_CATEGORY', 'ID_RPCAT');
   cleanupfield ( 'snt.TRP_PRICELIST', 'ID_PRICELIST');
   cleanupfield ( 'snt.TRPASS_CAT_INDEX', 'ID_RPCAT');
   cleanupfield ( 'snt.TRPASS_CAT_INDEX', 'ID_YEAR');
   cleanupfield ( 'snt.TRPASS_CAT_INDEX', 'RPACI_MILEAGE_RATE');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'ID_PRICELIST');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'ID_RPCAT');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'ID_YEAR');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'RPAP_DISCAS');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'RPAP_FLAT_RATE');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'RPAP_MILEAGE_RATE');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'RPAP_MLP');
   cleanupfield ( 'snt.TRPASS_PRICELIST', 'RPAP_SUBBU');
   cleanupfield ( 'snt.TSAVE_EXW_PK_DATA_DEF', 'EXW_PK');
   cleanupfield ( 'snt.TSAVE_I50_PK_DATA_DEF', 'SOD_PK');
   cleanupfield ( 'snt.TSP_COLLECTIVE_INVOICE', 'SPCI_NET_AMOUNT');
   cleanupfield ( 'snt.TSP_CONTINGENT', 'SPCC_QUANTITY');
   cleanupfield ( 'snt.TSP_CONTINGENT_FLOW', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TSP_CONTINGENT_FLOW', 'SPCCF_MILEAGE');
   cleanupfield ( 'snt.TSP_CONTINGENT_FLOW', 'SPCCF_QUANTITY');
   cleanupfield ( 'snt.TSP_CONTRACT', 'ID_CURRENCY');
   cleanupfield ( 'snt.TSP_CONTRACT', 'SPC_IDX_PERCENT');
   cleanupfield ( 'snt.TSP_CONTRACT', 'SPC_INTERNAL_ID');
   cleanupfield ( 'snt.TSP_CONTRACT', 'SPC_RP_MILEAGE');
   cleanupfield ( 'snt.TSP_CONTRACT', 'SPC_TARGET_DATE_MF');
   cleanupfield ( 'snt.TSP_CONTRACT', 'SPC_VARIANT');
   cleanupfield ( 'snt.TSP_CONTRACT_PRICE', 'SPCP_RP_MILEAGE');
   cleanupfield ( 'snt.TSP_CONTRACT_PRICE', 'SPCP_VALUE');
   cleanupfield ( 'snt.TTEMP_I50_DATA', 'ID_SEQ_FZGRECHNUNG');
   cleanupfield ( 'snt.TTEMP_I55_OR_SCARF_DATA', 'SEQ_NUMBER');
   cleanupfield ( 'snt.TTIRE', 'ID_TIRE');
   cleanupfield ( 'snt.TTIRE', 'ID_TIRMAN');
   cleanupfield ( 'snt.TTIRE_MANUFACTURE', 'ID_TIRMAN');
   cleanupfield ( 'snt.TTMP_SEQ_PROCESS', 'ID_SEQ_FZGVC');
   cleanupfield ( 'snt.TVAT_TYPE', 'VATT_DEBIT_OR_CREDIT');
   cleanupfield ( 'snt.TVAT_TYPE', 'VATT_INVOICE_OR_CNOTE');
   cleanupfield ( 'snt.TVEGA_I55_ATTRIBUTE', 'VI55A_DISPLACEMENT');
   cleanupfield ( 'snt.TVERTRAGSTAMM', 'ID_COS');
   cleanupfield ( 'snt.TVERTRAGSTAMM', 'ID_GARAGE');
   cleanupfield ( 'snt.TVERTRAGSTAMM', 'ID_GARAGE2');
 end;
 /
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
SET ECHO     OFF
SET FEEDBACK OFF

-- < delete following code between begin and end if data is selected only >

BEGIN
   IF     :L_ERROR_OCCURED = 0
      AND UPPER ('&&commit_or_rollback') = 'Y' THEN
      COMMIT;
      snt.SRS_LOG_MAINTENANCE_SCRIPTS (:L_SCRIPTNAME);
      :nachricht   := 'Data saved into the DB';
   ELSE
      ROLLBACK;
      :nachricht   := 'DB Data not changed';
   END IF;
END;
/

-- < enable again all perhaps in step 0 disabled constraints or triggers >

-- report final / finished message and exit
SET TERMOUT  ON

PROMPT
PROMPT finished.
PROMPT

BEGIN
   DBMS_OUTPUT.put_line (:nachricht);
END;
/

PROMPT
PROMPT please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.log
PROMPT

EXIT;