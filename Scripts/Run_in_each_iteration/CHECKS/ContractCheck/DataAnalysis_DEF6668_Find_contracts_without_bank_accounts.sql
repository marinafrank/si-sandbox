-- DataAnalysis_DEF6668_Find_contracts_without_bank_accounts.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-12-17; ZBerger; V1.2; MKS-136090:1; Find_contracts_without_bank_accounts
-- 2014-12-18; ZBerger; V1.3; MKS-136090:2; add duplicate check on cuba_bank_name
-- 2015-02-10; ZBerger; V1.4; MKS-136090:3; do not consider contract-state 'CANCELLED' (COS_STAT_CODE 10) if L_IGNORE_STAT_CODE is set to 0
-- 2015-03-15; MARZUHL; V1.5; MKS-152058:1; Check only for contracts with StatCode 01, 02, 03


-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

   -- file name for script and logfile
   define GL_SCRIPTNAME         = DataAnalysis_DEF6668_Find_contracts_without_bank_accounts
   define GL_LOGFILETYPE        = log           -- logfile name extension. [log|csv|txt]  {csv causes less info in logfile}
   define GL_SCRIPTFILETYPE     = sql           -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN           = 2
   define L_MINOR_MIN           = 8
   define L_REVISION_MIN        = 1
   define L_BUILD_MIN           = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER            = SNT
   define L_SYSDBA_PRIV_NEEDED  = false    -- false or true

  -- country specification
   define L_MPC_CHECK           = true     -- false or true
   define L_MPC_SOLL            = 'MBBEL'  -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = '51331'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb: 
                                           -- define L_MPC_SOLL       = 'MBBEL,MBCH'
                                           -- define L_VEGA_CODE_SOLL = '51331,57129'
  
  -- Reexecution
   define  L_REEXEC_FORBIDDEN   = false         -- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   define L_DB_LOGGING_ENABLE   = true          -- Are we logging to the DB? -> false or true
   define L_LOGFILE_REQUIRED    = true          -- Logfile required? -> false or true

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
set serveroutput on  size unlimited format wrapped 
set lines        999
set pages        0

variable L_SCRIPTNAME           varchar2 ( 200 char );
variable L_ERROR_OCCURED        number;
variable L_DATAERRORS_OCCURED   number;
variable L_DATAWARNINGS_OCCURED number;
variable L_DATASUCCESS_OCCURED  number;
variable nachricht              varchar2 ( 200 char );
exec :L_SCRIPTNAME              := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED           := 0
exec :L_DATAERRORS_OCCURED      := 0
exec :L_DATAWARNINGS_OCCURED    := 0
exec :L_DATASUCCESS_OCCURED     := 0

spool &GL_SCRIPTNAME..&GL_LOGFILETYPE

declare
   L_LAST_EXEC_TIME        varchar2 (  30 char );
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


prompt

whenever sqlerror exit sql.sqlcode

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

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName',    'NoMPCName found'   );
   L_VEGA_CODE_IST         snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'SIVECO',  'Country-CD', 'No VegaCode found' );
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
   if   &L_MPC_CHECK and instr ( '&L_VEGA_CODE_SOLL', L_VEGA_CODE_IST ) = 0 
   then dbms_output.put_line ( 'This script can be executed against following DB(s) only: ' || '&L_MPC_SOLL'
                              || chr(10) || 'But you are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
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
Define commit_or_rollback = &1 N;
SET TERMOUT ON

prompt SELECTION CHOSEN: "&commit_or_rollback"

prompt
prompt processing. please wait ...
prompt

set termout      off
set sqlprompt    'SQL>'
set pages        9999
set lines        9999
set serveroutput on   size unlimited format wrapped
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >

declare
   L_IGNORE_STAT_CODE      number := 1;   -- ignore stat-code where-clause (0=false, 1=true)

begin

   -- select missing domiciliations
   dbms_output.put_line('1. detecting missing domiciliations');
   dbms_output.put_line('===================================');
   for cDom in (select custdom_domnumber, fzgvc.id_vertrag, fzgvc.id_fzgvertrag, cust.cust_invoice_adress
                  from snt.tfzgv_contracts  fzgvc,
                       snt.tcustomer_dom    dom,
                       snt.tdfcontr_variant cov,
                       snt.tcustomer        cust,
                       snt.tdfcontr_state   cos,
                       snt.tfzgvertrag      fzgv
                 where fzgvc.guid_customer_dom = dom.guid_customer_dom
                   and cos.id_cos              = fzgv.id_cos
                   and fzgv.id_vertrag         = fzgvc.id_vertrag
                   and fzgv.id_fzgvertrag      = fzgvc.id_fzgvertrag
                   and cust.id_customer        = fzgvc.id_customer
                   and fzgvc.id_cov            = cov.id_cov
                   and cov.cov_caption NOT LIKE '%MIG_OOS%'
                   and (L_IGNORE_STAT_CODE     = 1
                        or cos.cos_stat_code   <> '10')
                   and custdom_domnumber not in (select cuba_bank_name -- cuba_iban
                                                   from snt.tcust_banking cuba)
		   -- additional/new (MKS-152058:1):
		   and cos.COS_STAT_CODE in ( '00', '01', '02' )
		) loop

      dbms_output.put_line ( 'WARN: ' || cDom.id_vertrag ||'/'|| cDom.id_fzgvertrag ||' Dom: '|| cDom.custdom_domnumber ||' CIA: '|| cDom.cust_invoice_adress);
      :L_DATAWARNINGS_OCCURED:= :L_DATAWARNINGS_OCCURED+1;
   end loop;

   -- select duplicate entries of cuba_bank_name
   dbms_output.put_line('');
   dbms_output.put_line('2. detecting duplicates on cuba_bank_name');
   dbms_output.put_line('=========================================');
   dbms_output.put_line ( chr(9) || 'id_customer' ||chr(9)|| 'cuba_iban' ||chr(9)||chr(9)|| 'cuba_bank_code' ||chr(9)|| 'cuba_bank_name');
   for cDup in (select cust.id_customer,
                       cuba.cuba_iban,
                       cuba.cuba_bank_code,
                       cuba.cuba_bank_name
                  from TCUST_BANKING cuba,
                       tcustomer     cust
                 where CUBA_BANK_NAME in (  select CUBA_BANK_NAME
                                              from TCUST_BANKING
                                          group by CUBA_BANK_NAME
                                            having COUNT (CUBA_BANK_NAME) > 1)
                   and cuba.guid_customer = cust.guid_customer)
   loop
      dbms_output.put_line ( 'WARN:' ||chr(9)|| cDup.id_customer ||chr(9)|| cDup.cuba_iban ||chr(9)|| cDup.cuba_bank_code ||chr(9)|| cDup.cuba_bank_name);
   end loop;

exception
   when no_data_found then 
    dbms_output.put_line ( 'A Data error occured. - Change made not successful!' );
    :L_DATAERRORS_OCCURED:= :L_DATAERRORS_OCCURED+1;

   when others then
    dbms_output.put_line ( 'A unhandled Data error occured. - Change made not successful!' );
        dbms_output.put_line (sqlerrm);
    :L_ERROR_OCCURED:= :L_ERROR_OCCURED+1;

end;
/



--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   :L_ERROR_OCCURED  = 0 and ( upper ( '&&commit_or_rollback' ) = 'Y' OR upper ( '&&commit_or_rollback' ) = 'AUTOCOMMIT' )
   then commit;
        snt.SRS_LOG_MAINTENANCE_SCRIPTS ( :L_SCRIPTNAME );
        :nachricht := 'Data saved into the DB';
   else rollback;
        :nachricht := 'DB Data not changed';
   end  if;
end;
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
set termout  on

begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
   dbms_output.put_line ( chr(10) || 'finished.' || chr(10) );
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
