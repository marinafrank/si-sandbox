-- DataCleansing_PRODUCTHOUSE_MBBEL_Change_Metapackages_and_Attributepackages.sql
-- M. Zimmerberger 21.01.2014 MKS-130475
-- FraBe           25.02.2014 MKS-130475:2 some verification changes
-- TK              10.04.2014 MKS-132262:1 Splitting in Meta/Attribute Package and SPP - Droppping MEta/Attribute Package here, Renaming

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_050_PRODUCTHOUSE_MBBEL_Change_SPP
   define GL_LOGFILETYPE	= LOG		-- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   define GL_SCRIPTFILETYPE	= SQL		-- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN		= 2
   define L_MINOR_MIN		= 8
   define L_REVISION_MIN	= 1
   define L_BUILD_MIN		= 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER		= SNT
   define L_SYSDBA_PRIV_NEEDED	= false		-- false or true

  -- country specification
   define L_MPC_CHECK		= true -- false or true
   define L_MPC_SOLL		= 'MBBeLux'
  
  -- Reexecution
   define  L_REEXEC_FORBIDDEN	= false		-- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   define L_DB_LOGGING_ENABLE	= true		-- Are we logging to the DB? -> false or true
   define L_LOGFILE_REQUIRED	= true		-- Logfile required? -> false or true

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


set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size unlimited
set lines        999
set pages        0

variable L_SCRIPTNAME 		varchar2 (200 char);
variable L_ERROR_OCCURED 	number;
variable L_DATAERRORS_OCCURED 	number;
variable L_DATAWARNINGS_OCCURED number;
variable L_DATASUCCESS_OCCURED number;
variable nachricht       	varchar2 ( 200 char );
exec :L_SCRIPTNAME := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED :=0
exec :L_DATAERRORS_OCCURED :=0
exec :L_DATAWARNINGS_OCCURED :=0
exec :L_DATASUCCESS_OCCURED :=0

spool &GL_SCRIPTNAME..&GL_LOGFILETYPE

declare
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
  dbms_output.put_line ('Script executed on: ' ||to_char(sysdate,'DD.MM.YYYY HH24:MI:SS')); 
  dbms_output.put_line ('Script executed by: &&_USER'); 
  dbms_output.put_line ('Script run on DB  : &&_CONNECT_IDENTIFIER'); 
  dbms_output.put_line ('Database Country  : ' ||snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' )); 
  dbms_output.put_line ('Database dump date: ' ||snt.get_TGLOBAL_SETTINGS ( 'DB', 'DUMP', 'DATE', 'not found' )); 
  begin
              select to_char (max( LE_CREATED), 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
	              from snt.TLOG_EVENT e
	             where GUID_LA = '10'         -- maintenance
	               and exists ( select null
	                              from snt.TLOG_EVENT_PARAM ep
	                             where ep.LEP_VALUE = :L_SCRIPTNAME
                              and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME);
    
    exception 
    when others then 
      NULL;
  end;
 end if;
 
end;
/


PROMPT

WHENEVER SQLERROR EXIT sql.sqlcode

declare

   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -- 2) unter welchem user muß das script laufen?
  
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -): 


   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' );
   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
  
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
   
   -- weitere benötigte variable
   L_ABBRUCH               boolean := false;

begin

   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   if   &L_SYSDBA_PRIV_NEEDED
   then begin
          select 'Y'
             into L_SYSDBA_PRIV 
             from SESSION_PRIVS 
            where PRIVILEGE = 'SYSDBA';
        exception when NO_DATA_FOUND 
                  then dbms_output.put_line ( 'Executing user is not &L_SOLLUSER / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be &L_SOLLUSER  / SYSDABA' || chr(10) );
                       L_ABBRUCH := true;
        end;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user 
   if   L_ISTUSER is null or upper ( '&L_SOLLUSER' ) <> upper ( L_ISTUSER )
   then dbms_output.put_line ( 'Executing user is not  &L_SOLLUSER !'
                             || chr(10) || 'For a correct use of this script, executing user must be  &L_SOLLUSER ' || chr(10) );
        L_ABBRUCH := true;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   if      L_MAJOR_IST > &L_MAJOR_MIN
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST > &L_MINOR_MIN )
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST = &L_MINOR_MIN and L_REVISION_IST > &L_REVISION_MIN )
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST = &L_MINOR_MIN and L_REVISION_IST = &L_REVISION_MIN and L_BUILD_IST >= &L_BUILD_MIN )
   then  null;
   else  dbms_output.put_line ( 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || &L_MAJOR_MIN || '.' || &L_MINOR_MIN || '.' || &L_REVISION_MIN || '.' || &L_BUILD_MIN || chr(10) );
         L_ABBRUCH := true;
   end   if;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   if   &L_MPC_CHECK and L_MPC_IST <> '&L_MPC_SOLL' 
   then dbms_output.put_line ( 'This script can be executed against a ' || '&L_MPC_SOLL' || ' DB only!'
                              || chr(10) || 'You are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
        L_ABBRUCH := true;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   if   &L_REEXEC_FORBIDDEN 
   then begin
              select to_char ( LE_CREATED, 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
	              from snt.TLOG_EVENT e
	             where GUID_LA = '10'         -- maintenance
	               and exists ( select null
	                              from snt.TLOG_EVENT_PARAM ep
	                             where ep.LEP_VALUE = :L_SCRIPTNAME
                              and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME
                              || chr(10) || 'It cannot be executed a 2nd time!' || chr(10) );
              L_ABBRUCH := true;
        exception when NO_DATA_FOUND then null;
        end;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- raise if at least one check above failed
  if   L_ABBRUCH
  then raise_application_error ( -20000, '==> Script Execution cancelled <==' );
  end  if;
end;
/

WHENEVER SQLERROR CONTINUE


PROMPT Do you want to save the changes to the DB? [Y/N] (Default N):

SET TERMOUT OFF
DEFINE commit_or_rollback = &1 N;
SET TERMOUT ON

PROMPT SELECTION CHOSEN: &commit_or_rollback;

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
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_AFT DISABLE;
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_BEF DISABLE;
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_ROW DISABLE;

ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_AFT DISABLE;
ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_BEF DISABLE;
ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_ROW DISABLE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- main part for < selecting or checking or correcting code >

PROMPT
PROMPT Product-house change in progress...
PROMPT

DECLARE
   l_guid_package snt.tic_package.guid_package%TYPE;
   l_guid_spc     snt.tsp_contract.guid_spc%TYPE;
   l_guid_partner snt.tpartner.guid_partner%TYPE;
   l_guid_partner_conti snt.tpartner.guid_partner%TYPE;

   TYPE TYPE_PPR IS TABLE OF VARCHAR2 (32)
                       INDEX BY BINARY_INTEGER;    -- package_parent_reference

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_contract
   (
      in_GUID_CONTRACT snt.TFZGVERTRAG.GUID_CONTRACT%TYPE
   )
      RETURN VARCHAR2
   IS
      L_RETURNVALUE  VARCHAR2 (20 CHAR);
   BEGIN
      SELECT ID_VERTRAG || '/' || ID_FZGVERTRAG
        INTO L_RETURNVALUE
        FROM snt.TFZGVERTRAG
       WHERE GUID_CONTRACT = in_GUID_CONTRACT;

      RETURN L_RETURNVALUE;
   END get_contract;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_SPP_contract (in_GUID_SPC snt.TSP_CONTRACT.GUID_SPC%TYPE)
      RETURN VARCHAR2
   IS
      L_RETURNVALUE  VARCHAR2 (20 CHAR);
   BEGIN
      SELECT ID_VERTRAG || '/' || ID_FZGVERTRAG
        INTO L_RETURNVALUE
        FROM snt.TSP_CONTRACT
       WHERE GUID_SPC = in_GUID_SPC;

      RETURN L_RETURNVALUE;
   END get_SPP_contract;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_package (in_GUID_PACKAGE snt.TIC_PACKAGE.GUID_PACKAGE%TYPE)
      RETURN VARCHAR2
   IS
      L_RETURNVALUE  snt.TIC_PACKAGE.ICP_CAPTION%TYPE;
   BEGIN
      SELECT ICP_CAPTION
        INTO L_RETURNVALUE
        FROM snt.TIC_PACKAGE
       WHERE GUID_PACKAGE = in_GUID_PACKAGE;

      RETURN L_RETURNVALUE;
   END get_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE create_spc_pack_ass ( IN_GUID_SPC VARCHAR2, IN_GUID_PACKAGE VARCHAR2)
   IS
   -- create supplier-contract package

   BEGIN
      INSERT INTO snt.tic_spc_pack_ass ( guid_spc, guid_package, guid_package_parent, guid_vi55a)
           VALUES
                  (
                     IN_GUID_SPC, IN_GUID_PACKAGE, NULL, '9FACEC61A1CD424BA4252BED48AE0238'
                  );
   END create_spc_pack_ass;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_guid_package (I_ICP_CAPTION VARCHAR2)
      RETURN VARCHAR2
   IS
      -- search for "classic"-package with I_ICP_CAPTION
      -- if found: return guid_package
      -- if not found: create new package and return guid_package

      L_GUID_PACKAGE VARCHAR2 (32);
   BEGIN
      -- get guid of package
      SELECT GUID_PACKAGE
        INTO L_GUID_PACKAGE
        FROM snt.TIC_PACKAGE tic
       WHERE tic.ICP_CAPTION = I_ICP_CAPTION;

      RETURN L_GUID_PACKAGE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- create package
         l_guid_package   := SYS_GUID ();

         INSERT INTO snt.tic_package
                     (
                        guid_package
                       ,id_package
                       ,icp_caption
                       ,icp_package_type
                       ,icp_i5x_value
                     )
              VALUES
                     (
                        l_guid_package
                       ,tic_package_seq.NEXTVAL
                       ,I_ICP_CAPTION
                       ,2
                       ,I_ICP_CAPTION
                     );

         RETURN L_GUID_PACKAGE;
   END get_guid_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_guid_sp_package (I_ICP_CAPTION VARCHAR2)
      RETURN VARCHAR2
   IS
      -- search for supplier-package with I_ICP_CAPTION
      -- if found: return guid_package
      -- if not found: create new package and return guid_package

      L_GUID_PACKAGE VARCHAR2 (32);
   BEGIN
      -- get guid of package
      SELECT GUID_PACKAGE
        INTO L_GUID_PACKAGE
        FROM snt.TIC_PACKAGE tic
       WHERE tic.ICP_CAPTION = I_ICP_CAPTION;

      RETURN L_GUID_PACKAGE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- create package
         l_guid_package   := SYS_GUID ();

         INSERT INTO snt.tic_package
                     (
                        guid_package
                       ,id_package
                       ,icp_caption
                       ,icp_package_type
                       ,icp_i5x_value
                       ,guid_vi55av
                     )
            SELECT l_guid_package
                  ,tic_package_seq.NEXTVAL
                  ,I_ICP_CAPTION
                  ,icp_package_type
                  ,icp_i5x_value
                  ,guid_vi55av
              FROM snt.tic_package
             WHERE UPPER (icp_caption) = 'REIFEN CONTI';

         RETURN L_GUID_PACKAGE;
   END get_guid_sp_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
  FUNCTION drop_attribute ( i_guid_contract VARCHAR2, i_icp_caption VARCHAR2)
      RETURN VARCHAR2
   IS
   myguidpackage varchar2(32);
   BEGIN
      myguidpackage := get_guid_package (I_ICP_CAPTION);
      DELETE FROM tic_co_pack_ass
            WHERE     guid_package = myguidpackage
                  AND guid_contract = i_guid_contract;

      IF SQL%ROWCOUNT > 0 THEN
         RETURN    'Package Assignment '
                || i_icp_caption
                || 'removed successful.';
      ELSE
         RETURN    'Package Assignment '
                || i_icp_caption
                || 'not removed successful.';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'Package Assignment ERROR: ' || i_icp_caption || SQLERRM;
   END drop_attribute;


   PROCEDURE set_meta_package_top_level ( IN_GUID_CONTRACT VARCHAR2, IN_OLD_GUID_PACKAGE VARCHAR2, IN_NEW_GUID_PACKAGE VARCHAR2)
   IS
   -- correct position of META-package, set it on top-level

   BEGIN
      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent   = IN_OLD_GUID_PACKAGE
          WHERE     guid_package_parent IS NULL
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line
            (
               'smptl err 1: ' || get_contract (IN_GUID_CONTRACT)
            );
      END;

      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent   = NULL
          WHERE     guid_package = IN_OLD_GUID_PACKAGE
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line
            (
               'smptl err 2: ' || get_contract (IN_GUID_CONTRACT)
            );
      END;

      DBMS_OUTPUT.put_line
      (
            ' set meta package top level for  contract: '
         || get_contract (IN_GUID_CONTRACT)
      );
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line
         (
               'set_meta_package_top_level err: '
            || get_contract (IN_GUID_CONTRACT)
         );
   END set_meta_package_top_level;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE set_spc_package_top_level ( IN_GUID_SPC VARCHAR2, IN_OLD_GUID_PACKAGE VARCHAR2, IN_NEW_GUID_PACKAGE VARCHAR2)
   IS
   -- correct position of supplier-package, set it on top-level

   BEGIN
      BEGIN
         UPDATE snt.tic_spc_pack_ass
            SET guid_package_parent   = IN_OLD_GUID_PACKAGE
          WHERE     guid_package_parent IS NULL
                AND GUID_SPC = IN_GUID_SPC;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line
            (
               'ssptl err 1: ' || get_SPP_contract (IN_GUID_SPC)
            );
      END;

      BEGIN
         UPDATE snt.tic_spc_pack_ass
            SET guid_package_parent   = NULL
          WHERE     guid_package = IN_OLD_GUID_PACKAGE
                AND GUID_SPC = IN_GUID_SPC;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line
            (
               'ssptl err 2: ' || get_SPP_contract (IN_GUID_SPC)
            );
      END;

      DBMS_OUTPUT.put_line
      (
            'set SPC package top level for  contract: '
         || get_SPP_contract (IN_GUID_SPC)
      );
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line
         (
               'set_spc_package_top_level err: '
            || get_SPP_contract (IN_GUID_SPC)
         );
   END set_spc_package_top_level;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE set_new_meta_package ( IN_OLD_GUID_PACKAGE VARCHAR2, IN_GUID_CONTRACT VARCHAR2, IN_NEW_GUID_PACKAGE VARCHAR2)
   IS
      l_guid_package_parent VARCHAR2 (32);
   BEGIN
      -- 1st make sure, META-Package is on top-level
      SELECT guid_package_parent
        INTO L_GUID_PACKAGE_PARENT
        FROM snt.tic_co_pack_ass
       WHERE     guid_package = IN_OLD_GUID_PACKAGE
             AND guid_contract = IN_GUID_CONTRACT;

      IF NOT L_GUID_PACKAGE_PARENT IS NULL THEN
         -- correct package-hierarchy
         set_meta_package_top_level ( IN_GUID_CONTRACT => IN_GUID_CONTRACT, IN_OLD_GUID_PACKAGE => IN_OLD_GUID_PACKAGE, IN_NEW_GUID_PACKAGE => IN_NEW_GUID_PACKAGE);
         DBMS_OUTPUT.put_line
         (
               'Repaired package hierarchy for  contract: '
            || get_contract (IN_GUID_CONTRACT)
         );
      END IF;

      -- 2nd replace "old" META-Package by new one
      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package   = l_guid_package
          WHERE     guid_package = IN_OLD_GUID_PACKAGE
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
      /* when others           then dbms_output.put_line ( 'replace old by new, contract: ' || get_contract ( IN_GUID_CONTRACT )
                                              || ' / old package: ' || get_package  ( IN_OLD_GUID_PACKAGE )
                                              || ' / new package: ' || get_package  ( l_guid_package ));
      */
      END;

      -- set the new parent
      BEGIN
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent   = l_guid_package
          WHERE     guid_package_parent = IN_OLD_GUID_PACKAGE
                AND guid_contract = IN_GUID_CONTRACT;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
      /* when others           then dbms_output.put_line ( 'set package parent to new, contract: ' || get_contract ( IN_GUID_CONTRACT )
                                                     || ' / old package: ' || get_package  ( IN_OLD_GUID_PACKAGE )
                                                     || ' / new package: ' || get_package  ( l_guid_package ));
      */
      END;

      DBMS_OUTPUT.put_line
      (
            'replace old package by new one, contract: '
         || get_contract (IN_GUID_CONTRACT)
         || ' / old package: '
         || get_package (IN_OLD_GUID_PACKAGE)
         || ' / new package: '
         || get_package (l_guid_package)
      );
   END set_new_meta_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------


   PROCEDURE set_new_sp_package ( IN_OLD_GUID_PACKAGE VARCHAR2, IN_GUID_SPC VARCHAR2, IN_NEW_GUID_PACKAGE VARCHAR2, IN_ATTRIB_PACKAGE VARCHAR2)
   IS
      l_guid_package_parent VARCHAR2 (32);
   BEGIN
      -- replace "old" SPP-Package by new one
      BEGIN
         UPDATE snt.tic_spc_pack_ass
            SET guid_package   = l_guid_package
          WHERE     guid_package = IN_OLD_GUID_PACKAGE
                AND GUID_SPC = IN_GUID_SPC;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
      /* when others           then dbms_output.put_line ( 'replace old SPC by new, contract: ' || get_SPP_contract ( IN_GUID_SPC )
                                                  || ' / old package: ' || get_package      ( IN_OLD_GUID_PACKAGE )
                                                  || ' / new package: ' || get_package      ( l_guid_package ));
      */
      END;

      -- set the new parent
      BEGIN
         UPDATE snt.tic_spc_pack_ass
            SET guid_package_parent   = l_guid_package
          WHERE     guid_package_parent = IN_OLD_GUID_PACKAGE
                AND GUID_SPC = IN_GUID_SPC;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
      /* when others           then dbms_output.put_line ( 'set SPC package parent to new, contract' || get_SPP_contract ( IN_GUID_SPC )
                                                       || ' / old package: ' || get_package      ( IN_OLD_GUID_PACKAGE )
                                                       || ' / new package: ' || get_package      ( l_guid_package ));
      */
      END;

      DBMS_OUTPUT.put_line
      (
            'replace old SPC package by new one, attribute package: '
         || IN_ATTRIB_PACKAGE
         || ' / contract: '
         || get_SPP_contract (IN_GUID_SPC)
         || ' / old package: '
         || get_package (IN_OLD_GUID_PACKAGE)
         || ' / new package: '
         || get_package (l_guid_package)
      );
   END set_new_sp_package;

   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_cust_invoice_adress (in_id_customer VARCHAR2)
      RETURN VARCHAR2
   IS
      l_id_customer_parent VARCHAR2 (32);
      l_cust_invoice_adress VARCHAR2 (32);
   BEGIN
      -- parent?
      SELECT id_customer_parent, cust_invoice_adress
        INTO l_id_customer_parent, l_cust_invoice_adress
        FROM snt.tcustomer
       WHERE id_customer = in_id_customer;

      IF NOT l_id_customer_parent IS NULL THEN
         l_cust_invoice_adress      :=
            get_cust_invoice_adress (in_id_customer => l_id_customer_parent);
      END IF;

      RETURN l_cust_invoice_adress;
   END get_cust_invoice_adress;
-- main begin

BEGIN
   DBMS_OUTPUT.put_line
   (
         CHR (10)
      || 'Begin step E - Anlegen Neue Supplierpakete Reifen / Vorabkonfiguration'
   );

   --=========================================================================================
   --E) Neue Supplierpakete Reifen / Vorabkonfiguration
   --
   --1) folgende neuen Supplierpakete (grün) anlegen.
   --==> Parameter analog zu Supplierpaket "Reifen Conti"
   --Supplierpaket: CONTI_UNLIMITED_SUMMER_40.1
   --Supplierpaket: TYRE_SPECIAL_AGREEMENT_40.2
   --Supplierpaket: TYRE_SPECIAL_AGREEMENT_40.3
   --Supplierpaket: MICHELIN_LIMITED_SUMMER_40.4
   --Supplierpaket: MICHELIN_UNLIMITED_SUMMER_40.5
   --Supplierpaket: CONTI_LIMITED_SUMMER_40.6
   --Supplierpaket: CONTI_UNLIMITED_SW_CHANGE_TYRE_40.7
   --Supplierpaket: CONTI_UNLIMITED_ALLSEASON_40.8
   --Supplierpaket: BRIDGESTONE_UNLIMITED_40.9
   --Supplierpaket: MICHELIN_GOV_SPECIAL_40.10
   --Supplierpaket: CONTI_UNLIMITED_SW_CHANGE_TYRE_40.1old

   --2) Setze bei Werkstatt 99999 das Flag "Supplier" 
   UPDATE snt.tgarage gar
      SET gar.gar_is_service_provider   = 1
    WHERE id_garage = 99999;

    :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +sql%rowcount;

   --remember guid_partner INTERNAL
   SELECT guid_partner
     INTO l_guid_partner
     FROM snt.tpartner par
    WHERE par.id_garage = 99999;


   --remember guid_partner CONTI
   SELECT guid_partner
     INTO l_guid_partner_conti
     FROM snt.tpartner par
    WHERE par.id_garage = 4001;

   DBMS_OUTPUT.put_line (CHR (10) || 'Begin step F - Umschlüsselung Reifen');

   --=========================================================================================
   --F) Umschlüsselung Reifen
   -- 
   --1) Umschlüsselung vorhandener Supplierpakete
   -- Vertrag mit Supplierpaket -- UND vertrag mit Attributpaket
   -- Reifen Conti:
   -- Attributpaket: 40.1     ==> Supplierpaket: CONTI_UNLIMITED_SUMMER_40.1
   -- Attributpaket: 40.2     ==> Supplierpaket: TYRE_SPECIAL_AGREEMENT_40.2
   -- Attributpaket: 40.3     ==> Supplierpaket: TYRE_SPECIAL_AGREEMENT_40.3
   -- Attributpaket: 40.4     ==> Supplierpaket: MICHELIN_LIMITED_SUMMER_40.4
   -- Attributpaket: 40.5     ==> Supplierpaket: MICHELIN_UNLIMITED_SUMMER_40.5
   -- Attributpaket: 40.6     ==> Supplierpaket: CONTI_LIMITED_SUMMER_40.6
   -- Attributpaket: 40.7     ==> Supplierpaket: CONTI_UNLIMITED_SW_CHANGE_TYRE_40.7
   -- Attributpaket: 40.8     ==> Supplierpaket: CONTI_UNLIMITED_ALLSEASON_40.8
   -- Attributpaket: 40.9     ==> Supplierpaket: BRIDGESTONE_UNLIMITED_40.9
   -- Attributpaket: 40.10    ==> Supplierpaket: MICHELIN_GOV_SPECIAL_40.10
   -- Attributpaket: 40.1old  ==> Supplierpaket: CONTI_UNLIMITED_SW_CHANGE_TYRE_40.1old

   -- OHNE Attributpaket      ==> Supplierpaket: CONTI_UNLIMITED_SW_CHANGE_TYRE

   -- check contracts with attriubte-package 40.x and supplier-package REIFEN CONTI
   FOR o_change_spp
      IN (  SELECT fzg.id_vertrag
                  ,fzg.id_fzgvertrag
                  ,pac.icp_caption
                  ,spc.guid_spc
                  ,spa.guid_package
                  ,fzg.guid_contract
              FROM snt.tic_co_pack_ass cpa
                  ,snt.tic_package pac
                  ,snt.tfzgv_contracts fzgv
                  ,snt.tfzgvertrag fzg
                  ,snt.tdfcontr_variant cov
                  ,snt.tsp_contract spc
                  ,snt.tic_spc_pack_ass spa
             WHERE     cpa.guid_contract = fzg.guid_contract
                   AND cpa.guid_package = pac.guid_package
                   AND spc.id_vertrag = fzg.id_vertrag
                   AND spc.id_fzgvertrag = fzg.id_fzgvertrag
                   AND spc.guid_spc = spa.guid_spc
                   AND fzg.id_vertrag = fzgv.id_vertrag
                   AND fzg.id_fzgvertrag = fzgv.id_fzgvertrag
                   AND fzgv.id_cov = cov.id_cov
                   AND cov.cov_caption NOT LIKE '%MIG_OOS%'
                   AND cpa.guid_package IN
                          (SELECT guid_package
                             FROM tic_package pac
                            WHERE     icp_caption LIKE '%40.%'
                                  AND pac.icp_package_type = 1)
                   AND spa.guid_package =
                          (SELECT guid_package
                             FROM tic_package pac
                            WHERE     UPPER (icp_caption) = 'REIFEN CONTI'
                                  AND pac.icp_package_type = 3)
          ORDER BY 3, 1, 2)
   LOOP
      CASE
         WHEN o_change_spp.icp_caption = '40.1' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SUMMER_40.1'
               );

            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.2' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'TYRE_SPECIAL_AGREEMENT_40.2'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.3' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'TYRE_SPECIAL_AGREEMENT_40.3'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.4' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_LIMITED_SUMMER_40.4'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.5' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_UNLIMITED_SUMMER_40.5'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.6' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_LIMITED_SUMMER_40.6'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.7' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.7'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.8' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_ALLSEASON_40.8'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.9' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'BRIDGESTONE_UNLIMITED_40.9'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.10' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_GOV_SPECIAL_40.10'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         WHEN o_change_spp.icp_caption = '40.1old' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.1old'
               );
            set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => o_change_spp.icp_caption);
            DBMS_OUTPUT.PUT_LINE
            (
               drop_attribute ( o_change_spp.guid_contract, o_change_spp.icp_caption)
            );
         ELSE
            DBMS_OUTPUT.put_line
            (
                  'Package '
               || o_change_spp.icp_caption
               || ' is not handled by o_change_spp'
            );
      END CASE;

      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +sql%rowcount;

   END LOOP;

   -- check contracts with no attriubte-package and supplier-package REIFEN CONTI
   FOR o_change_spp
      IN (SELECT fzg.id_vertrag
                ,fzg.id_fzgvertrag
                ,pac.icp_caption
                ,spc.guid_spc
                ,spa.guid_package
            FROM snt.tic_co_pack_ass cpa
                ,snt.tic_package pac
                ,snt.tfzgv_contracts fzgv
                ,snt.tfzgvertrag fzg
                ,snt.tdfcontr_variant cov
                ,snt.tsp_contract spc
                ,snt.tic_spc_pack_ass spa
           WHERE     cpa.guid_contract = fzg.guid_contract
                 AND cpa.guid_package = pac.guid_package
                 AND spc.id_vertrag = fzg.id_vertrag
                 AND spc.id_fzgvertrag = fzg.id_fzgvertrag
                 AND spc.guid_spc = spa.guid_spc
                 AND fzg.id_vertrag = fzgv.id_vertrag
                 AND fzg.id_fzgvertrag = fzgv.id_fzgvertrag
                 AND fzgv.id_cov = cov.id_cov
                 AND cov.cov_caption NOT LIKE '%MIG_OOS%'
                 AND pac.icp_package_type <> 1
                 AND spa.guid_package = (SELECT guid_package
                                           FROM tic_package pac
                                          WHERE     UPPER
                                                    (
                                                       icp_caption
                                                    ) = 'REIFEN CONTI'
                                                AND pac.icp_package_type = 3))
   LOOP
      l_guid_package      :=
         get_guid_sp_package
         (
            I_ICP_CAPTION => 'CONTI_UNLIMITED_SW_CHANGE_TYRE'
         );
      set_new_sp_package ( IN_OLD_GUID_PACKAGE => o_change_spp.guid_package, IN_GUID_SPC => o_change_spp.guid_spc, IN_NEW_GUID_PACKAGE => l_guid_package, IN_ATTRIB_PACKAGE => '<no>');
      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +sql%rowcount;
   END LOOP;


   DBMS_OUTPUT.put_line
   (
      CHR (10) || CHR (10) || 'Begin step F2 - Create supplier-packages'
   );

   --2) Neuanlage von Supplierpaketen:
   --Für einen Vertrag, der ein o.g. 40.X Attributpaket hat, aber keinen Suppliervertrag zugeordnet ist ein
   --neuer Suppliervertrag anzulegen und das passende Supplierpaket zuzuordnen (siehe F.1)
   --
   --Für den neuen Suppliervertrag gelten folgende Parameter:
   --Vertragsbeginn/ende: analog Duration
   --Vertragsart: SI
   --Preis: 0ct
   --ExternalID: concat(ID_VERTRAG;ID_FZGVERTRAG)
   --ausführende Werkstatt: 99999
   --interne ID: aufsteigend
   --restliche Werte: Default.

   -- check contracts with attriubte-package 40.X but without supplier-contract
   FOR o_create_spc
      IN (  SELECT fzg.id_vertrag, fzg.id_fzgvertrag, fzg.id_garage, pac.icp_caption
              FROM snt.tic_co_pack_ass cpa
                  ,snt.tic_package pac
                  ,snt.tfzgv_contracts fzgv
                  ,snt.tfzgvertrag fzg
                  ,snt.tdfcontr_variant cov
             WHERE     cpa.guid_contract = fzg.guid_contract
                   AND cpa.guid_package = pac.guid_package
                   AND fzg.id_vertrag = fzgv.id_vertrag
                   AND fzg.id_fzgvertrag = fzgv.id_fzgvertrag
                   AND fzgv.id_cov = cov.id_cov
                   AND cov.cov_caption NOT LIKE '%MIG_OOS%'
                   AND cpa.guid_package IN
                          (SELECT guid_package
                             FROM tic_package pac
                            WHERE     icp_caption LIKE '%40.%'
                                  AND pac.icp_package_type = 1)
                   AND NOT EXISTS
                          (SELECT guid_spc
                             FROM tsp_contract spc
                            WHERE     spc.id_vertrag = fzg.id_vertrag
                                  AND spc.id_fzgvertrag = fzg.id_fzgvertrag)
          ORDER BY 4, 1, 2)
   LOOP
      l_guid_spc   := SYS_GUID ();

      -- create new supplier-contract header (tsp_contract)
      INSERT INTO snt.tsp_contract
                  (
                     guid_spc
                    ,id_vertrag
                    ,id_fzgvertrag
                    ,guid_partner
                    ,spc_external_id
                    ,spc_internal_id
                    ,id_currency
                    ,spc_state
                    ,spc_valid_from
                    ,spc_valid_to
                    ,spc_memo
                    ,spc_variant
                    ,guid_indv
                  )
           --                                       spc_rp_mileage,
           --                                       spc_idx_percent,
           --                                       spc_idx_nextdate,
           --                                       spc_target_date_mf)
           VALUES
                  (
                     l_guid_spc
                    ,o_create_spc.id_vertrag
                    ,o_create_spc.id_fzgvertrag
                    ,l_guid_partner
                    ,o_create_spc.id_vertrag || o_create_spc.id_fzgvertrag
                    ,snt.get_next_number ( I_GUID_NUMRANGE => '22015284B21C4964853382B191DE9469', I_GROUP_BY_VALUE => NULL)
                    , (SELECT dd.dd_default
                         FROM snt.tdatadictionary dd
                        WHERE UPPER (dd.id_datadictionary) = 'ID_CURRENCY')
                    , (SELECT dd.dd_default
                         FROM snt.tdatadictionary dd
                        WHERE UPPER (dd.id_datadictionary) = 'SPC_STATE')
                    ,snt.get_begin_date ( STRIDVERTRAG => o_create_spc.id_vertrag, STRIDFZGVERTRAG => o_create_spc.id_fzgvertrag)
                    ,snt.get_end_date ( STRIDVERTRAG => o_create_spc.id_vertrag, STRIDFZGVERTRAG => o_create_spc.id_fzgvertrag)
                    ,'Autocreated by LOP2837'
                    ,1
                    ,'742352F7BE4111D5B4D000508B6A796E'
                  );


      -- create new supplier-contract price (tsp_contract_price)
      INSERT INTO tsp_contract_price
                  (
                     guid_spc_price
                    ,guid_spc
                    ,spcp_valid_from
                    ,spcp_valid_to
                    ,spcp_value
                    ,spcp_rp_mileage
                  )
           VALUES
                  (
                     SYS_GUID ()
                    ,l_guid_spc
                    ,snt.get_begin_date ( strIDVERTRAG => o_create_spc.id_vertrag, strIDFZGVERTRAG => o_create_spc.id_fzgvertrag)
                    ,snt.get_end_date ( strIDVERTRAG => o_create_spc.id_vertrag, strIDFZGVERTRAG => o_create_spc.id_fzgvertrag)
                    ,0
                    ,0
                  );


      -- create new entry in tic_spc_pack_ass
      CASE
         WHEN o_create_spc.icp_caption = '40.1' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SUMMER_40.1'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CONTI_UNLIMITED_SUMMER_40.1'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.2' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'TYRE_SPECIAL_AGREEMENT_40.2'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'TYRE_SPECIAL_AGREEMENT_40.2'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.3' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'TYRE_SPECIAL_AGREEMENT_40.3'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'TYRE_SPECIAL_AGREEMENT_40.3'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.4' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_LIMITED_SUMMER_40.4'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'MICHELIN_LIMITED_SUMMER_40.4'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.5' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_UNLIMITED_SUMMER_40.5'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CMICHELIN_UNLIMITED_SUMMER_40.5'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.6' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_LIMITED_SUMMER_40.6'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CONTI_LIMITED_SUMMER_40.6'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.7' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.7'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.7'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.8' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_ALLSEASON_40.8'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CONTI_UNLIMITED_ALLSEASON_40.8'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.9' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'BRIDGESTONE_UNLIMITED_40.9'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'BRIDGESTONE_UNLIMITED_40.9'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.10' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'MICHELIN_GOV_SPECIAL_40.10'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'MICHELIN_GOV_SPECIAL_40.10'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         WHEN o_create_spc.icp_caption = '40.1old' THEN
            l_guid_package      :=
               get_guid_sp_package
               (
                  I_ICP_CAPTION => 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.1old'
               );
            create_spc_pack_ass ( IN_GUID_SPC => l_guid_spc, IN_GUID_PACKAGE => l_guid_package);
            DBMS_OUTPUT.put_line
            (
                  'SPC package: '
               || 'CONTI_UNLIMITED_SW_CHANGE_TYRE_40.1old'
               || ' created for contract: '
               || o_create_spc.id_vertrag
               || '/'
               || o_create_spc.id_fzgvertrag
            );
         ELSE
            DBMS_OUTPUT.put_line
            (
                  'Package '
               || o_create_spc.icp_caption
               || ' is not handled by o_create_spc'
            );
      END CASE;
      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +sql%rowcount;
   END LOOP;
END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
SET ECHO     OFF
SET FEEDBACK OFF

-- < delete following code between begin and end if data is selected only >

BEGIN
   IF     :L_ERROR_OCCURED = 0
      AND (   UPPER ('&&commit_or_rollback') = 'Y'
           OR UPPER ('&&commit_or_rollback') = 'AUTOCOMMIT') THEN
      COMMIT;
      snt.SRS_LOG_MAINTENANCE_SCRIPTS (:L_SCRIPTNAME);
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
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_AFT ENABLE;
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_BEF ENABLE;
ALTER TRIGGER snt.TIC_CO_PACK_ASS_CHECK_ROW ENABLE;

ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_AFT ENABLE;
ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_BEF ENABLE;
ALTER TRIGGER snt.TIC_SPC_PACK_ASS_CHK_ROW ENABLE;
--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- report final / finished message and exit
set termout  on

begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
   dbms_output.put_line ( chr(10)||'finished.'||chr(10) );
 end if;
 
 dbms_output.put_line ( :nachricht );
 
 if upper('&&GL_LOGFILETYPE')<>'CSV' then

  dbms_output.put_line (chr(10));
  dbms_output.put_line ('Please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile &&GL_SCRIPTNAME..&&GL_LOGFILETYPE');
  dbms_output.put_line (chr(10));
  dbms_output.put_line ('MANAGEMENT SUMMARY');
  dbms_output.put_line ('==================');
  dbms_output.put_line ('Dataset affected: ' || :L_DATASUCCESS_OCCURED);
  dbms_output.put_line ('Data warnings   : ' || :L_DATAWARNINGS_OCCURED);
  dbms_output.put_line ('Data errors     : ' || :L_DATAERRORS_OCCURED);
  dbms_output.put_line ('System errors   : ' || :L_ERROR_OCCURED);

 end if;
end;
/
exit;
