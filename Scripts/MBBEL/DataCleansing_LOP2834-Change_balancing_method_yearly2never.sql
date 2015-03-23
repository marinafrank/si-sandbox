-- DataCleansing_LOP2834-Change_balancing_method_yearly2never.sql
-- CPauzen     17.12.2013 MKS-130135:1 /LOP2834

spool DataCleansing_LOP2834-Change_balancing_method_yearly2never.log

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

variable L_ERROR_OCCURED number;
exec :L_ERROR_OCCURED    := 0;
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 100 char );
exec :L_SCRIPTNAME       := 'DataCleansing_LOP2834-Change_balancing_method_yearly2never.sql';

prompt

whenever sqlerror exit sql.sqlcode

declare

   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   L_SYSDBA_PRIV_NEEDED    boolean                         := false;          -- false or true
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -- 2) unter welchem user muß das script laufen?
   L_SOLLUSER              VARCHAR2 ( 30 char ) := 'SNT';
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -): 
   L_MAJOR_MIN             integer := 2;
   L_MINOR_MIN             integer := 8;
   L_REVISION_MIN          integer := 0;
   L_BUILD_MIN             integer := 0;

   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   -- 4) falls das script nur gegen ein einziges MPC laufen darf, hier true angeben, bzw. den namen des MPC: 
   L_MPC_CHECK             boolean                         := true;           -- false or true
   L_MPC_SOLL              snt.TGLOBAL_SETTINGS.VALUE%TYPE := 'MBBeLux';
   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName' );

   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
   L_REEXEC_FORBIDDEN      boolean                         := false;           -- false or true
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
   
   -- weitere benötigte variable
   L_ABBRUCH               boolean := false;

begin

   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   if   L_SYSDBA_PRIV_NEEDED
   then begin
          select 'Y'
             into L_SYSDBA_PRIV 
             from SESSION_PRIVS 
            where PRIVILEGE = 'SYSDBA';
        exception when NO_DATA_FOUND 
                  then dbms_output.put_line ( 'Executing user is not ' || upper ( L_SOLLUSER ) || ' / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || ' / SYSDABA' || chr(10) );
                       L_ABBRUCH := true;
        end;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user 
   if   L_ISTUSER is null or upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then dbms_output.put_line ( 'Executing user is not ' || upper ( L_SOLLUSER ) || '!'
                             || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || chr(10) );
        L_ABBRUCH := true;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   if      L_MAJOR_IST > L_MAJOR_MIN
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST > L_REVISION_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST = L_REVISION_MIN and L_BUILD_IST >= L_BUILD_MIN )
   then  null;
   else  dbms_output.put_line ( 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || L_MAJOR_MIN || '.' || L_MINOR_MIN || '.' || L_REVISION_MIN || '.' || L_BUILD_MIN || chr(10) );
         L_ABBRUCH := true;
   end   if;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   if   L_MPC_CHECK and L_MPC_IST <> L_MPC_SOLL 
   then dbms_output.put_line ( 'This script can be executed against a ' || L_MPC_SOLL || ' DB only!'
                              || chr(10) || 'You are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
        L_ABBRUCH := true;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   if   L_REEXEC_FORBIDDEN 
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

accept commit_or_rollback prompt "Do you want to save the changes to the DB? Y/N: "

prompt
prompt processing. please wait ...
prompt

set termout      off
set sqlprompt    'SQL>'
set pages        9999
set lines        9999
set serveroutput on   size unlimited
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

-- 1st: 
prompt 
prompt 

UPDATE   tfzgv_contracts fzgvc
   SET   fzgvc.fzgvc_runpower_balancing = 0
 WHERE   fzgvc.id_seq_fzgvc IN
                 (SELECT   fzgvc.id_seq_fzgvc
                    FROM   tfzgv_contracts fzgvc, tdfcontr_variant cov
                   WHERE       cov.id_cov = fzgvc.id_cov
                           AND fzgvc.fzgvc_runpower_balancing = 12
                           AND cov.cov_caption NOT LIKE 'MIG_OOS%');


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   :L_ERROR_OCCURED  = 0 and upper ( '&&commit_or_rollback' ) = 'Y'
   then commit;
        snt.SRS_LOG_MAINTENANCE_SCRIPTS ( :L_SCRIPTNAME );
        :nachricht := 'Data saved into the DB';
   else rollback;
        :nachricht := 'DB Data not changed';
   end  if;
end;
/

-- < enable again all perhaps in step 0 disabled constraints or triggers >
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )

-- report final / finished message and exit
set termout  on

prompt
prompt finished.
prompt

begin
   dbms_output.put_line ( :nachricht );
end;
/

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2834-Change_balancing_method_yearly2never.log
prompt

exit;
