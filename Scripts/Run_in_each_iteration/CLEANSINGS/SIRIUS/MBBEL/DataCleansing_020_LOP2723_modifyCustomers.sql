-- DataCleansing_LOP2723_modifyCustomers.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-05-06; ZBerger; V1.2; MKS-132524:1; Script zur Umschl�sselung von Kundendaten
-- 2014-05-06; MZu; V1.3; MKS-132524:2; removed unneccessary "select sysdate..."
-- 2015-01-19; MZu; V1.4; MKS-136385:1; replace '00111111111' by proper '111111111' according to initial request.
-- 2015-01-19; MZu; V1.4; MKS-152063:1; DEF8436: Remove no longer existing customers

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_020_LOP2723_modifyCustomers
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
   define L_MPC_CHECK = true		-- false or true
   define L_MPC_SOLL  = 'MBBeLux'
  
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


prompt

whenever sqlerror exit sql.sqlcode

declare

   ----------------------------------------
   -- einstellungen f�r div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv ben�tigt wird, folgende var auf true setzen
   
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -- 2) unter welchem user mu� das script laufen?
  
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -- 3) welche version mu� die DB auf jeden fall aufweisen (- oder h�her -): 


   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' );
   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
  
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
   
   -- weitere ben�tigte variable
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
set serveroutput on   size unlimited
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off

-- main part for < selecting or checking or correcting code >

-- 1st: 
prompt 
prompt Update customer:
prompt 

declare

procedure upd_tcustomer(i_cust_invoice_adress     snt.tcustomer.cust_invoice_adress%type,
                        i_cust_inv_adress_balfin  snt.tcustomer.cust_inv_adress_balfin%type,
                        i_cust_sap_number_debitor snt.tcustomer.cust_sap_number_debitor%type,
                        i_id_customer             snt.tcustomer.id_customer%type)
is

begin

   update snt.tcustomer
      set cust_invoice_adress       = i_cust_invoice_adress
        , cust_inv_adress_balfin    = i_cust_inv_adress_balfin
        , cust_sap_number_debitor   = i_cust_sap_number_debitor
    where id_customer               = i_id_customer;

   if sql%rowcount > 0 then
     dbms_output.put_line ( 'Customer ' || i_id_customer || ' updated successful!' );
      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
   else
     dbms_output.put_line ( 'Customer ' || i_id_customer || ' not found!' );
      :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED +1;
   end if;

   exception
      when others then
      dbms_output.put_line ( 'A unhandled Data error occured. - Change made not successful!' );
           dbms_output.put_line (sqlerrm);
      :L_ERROR_OCCURED:= :L_ERROR_OCCURED+1;

end upd_tcustomer;

begin
   -- deactivate old commands and replace them by the new ones (MKS-152063)
   -- upd_tcustomer(i_cust_invoice_adress=>'00015504001', i_cust_inv_adress_balfin=>'00015504001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015505001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015539001', i_cust_inv_adress_balfin=>'00015539001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015559001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015539001', i_cust_inv_adress_balfin=>'00015539001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015524001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00034685001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015581001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00034684001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015583001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015507001', i_cust_inv_adress_balfin=>'00015507001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00029400001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015507001', i_cust_inv_adress_balfin=>'00015507001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015551001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015529001', i_cust_inv_adress_balfin=>'00015529001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015575001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015576001', i_cust_inv_adress_balfin=>'00015576001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015555001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015564001', i_cust_inv_adress_balfin=>'00015564001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015599001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015584001', i_cust_inv_adress_balfin=>'00015584001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00015572001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838001', i_cust_inv_adress_balfin=>'00010838001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00018536001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633002');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633003');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633004');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633005');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00001346001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633007');
   -- upd_tcustomer(i_cust_invoice_adress=>'00010838002', i_cust_inv_adress_balfin=>'00010838002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000633006');
   -- upd_tcustomer(i_cust_invoice_adress=>'00000211001', i_cust_inv_adress_balfin=>'00000211001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000211002');
   -- upd_tcustomer(i_cust_invoice_adress=>'00000500002', i_cust_inv_adress_balfin=>'00000500002', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000500001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00025998001', i_cust_inv_adress_balfin=>'00025998001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000999001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00025998001', i_cust_inv_adress_balfin=>'00025998001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00007745001');
   -- upd_tcustomer(i_cust_invoice_adress=>'00000734001', i_cust_inv_adress_balfin=>'00000734001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00000734002');
   -- upd_tcustomer(i_cust_invoice_adress=>'00001223001', i_cust_inv_adress_balfin=>'00001223001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00001223002');
   -- upd_tcustomer(i_cust_invoice_adress=>'00015520001', i_cust_inv_adress_balfin=>'00015520001', i_cust_sap_number_debitor=>'111111111', i_id_customer=>'00034945001');
	upd_tcustomer(i_id_customer =>'00015505001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015504001', i_cust_inv_adress_balfin=>'00015504001');
	upd_tcustomer(i_id_customer =>'00015559001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015539001', i_cust_inv_adress_balfin=>'00015539001');
	upd_tcustomer(i_id_customer =>'00015524001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015539001', i_cust_inv_adress_balfin=>'00015539001');
	upd_tcustomer(i_id_customer =>'00034685001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001');
	upd_tcustomer(i_id_customer =>'00015581001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001');
	upd_tcustomer(i_id_customer =>'00034684001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001');
	upd_tcustomer(i_id_customer =>'00015583001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015570001', i_cust_inv_adress_balfin=>'00015570001');
	upd_tcustomer(i_id_customer =>'00029400001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015507001', i_cust_inv_adress_balfin=>'00015507001');
	upd_tcustomer(i_id_customer =>'00015551001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015507001', i_cust_inv_adress_balfin=>'00015507001');
	upd_tcustomer(i_id_customer =>'00015575001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015529001', i_cust_inv_adress_balfin=>'00015529001');
	upd_tcustomer(i_id_customer =>'00015555001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015576001', i_cust_inv_adress_balfin=>'00015576001');
	upd_tcustomer(i_id_customer =>'00015599001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015564001', i_cust_inv_adress_balfin=>'00015564001');
	upd_tcustomer(i_id_customer =>'00000211002', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00000211001', i_cust_inv_adress_balfin=>'00000211001');
	upd_tcustomer(i_id_customer =>'00000999001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00025998001', i_cust_inv_adress_balfin=>'00025998001');
	upd_tcustomer(i_id_customer =>'00007745001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00025998001', i_cust_inv_adress_balfin=>'00025998001');
	upd_tcustomer(i_id_customer =>'00000734002', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00000734001', i_cust_inv_adress_balfin=>'00000734001');
	upd_tcustomer(i_id_customer =>'00034945001', i_cust_sap_number_debitor=>'111111111', i_cust_invoice_adress=>'00015520001', i_cust_inv_adress_balfin=>'00015520001');

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
   if   :L_ERROR_OCCURED  = 0 and (upper ( '&&commit_or_rollback' ) = 'Y' OR upper ( '&&commit_or_rollback' ) = 'AUTOCOMMIT')
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
   dbms_output.put_line ( chr(10)||'finished.'||chr(10) );
 end if;
 
 dbms_output.put_line ( :nachricht );
 
 if upper('&&GL_LOGFILETYPE')<>'CSV' then

  dbms_output.put_line (chr(10));
  dbms_output.put_line ('please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile &&GL_SCRIPTNAME..&&GL_LOGFILETYPE');
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
