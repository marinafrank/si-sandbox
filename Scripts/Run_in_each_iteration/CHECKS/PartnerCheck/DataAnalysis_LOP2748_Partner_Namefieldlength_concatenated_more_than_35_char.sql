-- DataAnalysis_LOP2748_Partner_Namefieldlength_concatenated_more_than_35_char.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-09-02; MARZUHL; V1.0; MKS-134744:1; Initial Setup
-- 2014-09-09; MARZUHL; V1.0; MKS-134836:2; NOT countryspecific!

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME         = DataAnalysis_LOP2748_Partner_Namefieldlength_concatenated_more_than_35_char
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
   define L_MPC_CHECK           = false     -- false or true
   define L_MPC_SOLL            = 'MBBEL'  -- f�r                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = '51331'  -- die werte daf�r sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden k�nnen aber auch mehrere angegeben werden
                                           -- die einzelnen werte M�SSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- g�ltige angaben sind zb: 
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

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName',    'NoMPCName found'   );
   L_VEGA_CODE_IST         snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'SIVECO',  'Country-CD', 'No VegaCode found' );
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



-- main part for < selecting or checking or correcting code >

declare
	cursor c_partner_data is
		select
			TCUSTOMER.ID_CUSTOMER as ID_CUSTOMER
			, nvl(TCUSTOMER.CUST_SAP_NUMBER_DEBITOR, '!EMPTY!')			as "CoFiCo"
			, TNAME.NAME_CAPTION1
				|| nvl2(TNAME.NAME_CAPTION2, '; ', '') || TNAME.NAME_CAPTION2
				|| nvl2(TNAME.NAME_CAPTION3, '; ', '') || TNAME.NAME_CAPTION3	as "Combined_Name"
		from 
			TNAME
			, TADRASSOZ
			, TCUSTOMER
			, TCUSTOMERTYP
	where
		length(TNAME.NAME_CAPTION1||TNAME.NAME_CAPTION2||TNAME.NAME_CAPTION3)>35
		and (TNAME.ID_SEQ_NAME=TADRASSOZ.ID_SEQ_NAME
		and TADRASSOZ.ID_SEQ_ADRASSOZ=TCUSTOMER.ID_SEQ_ADRASSOZ
		and TCUSTOMER.ID_CUSTYP=TCUSTOMERTYP.ID_CUSTYP
		and TCUSTOMERTYP.CUSTYP_CAPTION not like 'MIG_OOS%')
	order by
		ID_CUSTOMER
	;
	ID_CUSTOMER varchar2(50 char);
	CUST_SAP_NUMBER_DEBITOR varchar2(50 char);
	NAME_CAPTION1 varchar2(102 char);


begin
	open c_partner_data;
	loop
		fetch c_partner_data into ID_CUSTOMER, CUST_SAP_NUMBER_DEBITOR, NAME_CAPTION1;
		if c_partner_data%NOTFOUND
		then
			if  c_partner_data%ROWCOUNT <1
			then
				dbms_output.put_line ( 'INFO: No partners with more than 35 characters in combined NAME_CAPTION1 / NAME_CAPTION2  / NAME_CAPTION3 found.');
			end if;
			exit;									-- Exit of loop
		end if;
		if c_partner_data%ROWCOUNT = 1
		then
			dbms_output.put_line ('WARN: ID_CUSTOMER; CoFiCo; NAME_CAPTION1; NAME_CAPTION2(optional); NAME_CAPTION3(optional)');
			dbms_output.put_line ('WARN: ====================================================================================');
		end if;
		dbms_output.put_line ('WARN: ' || ID_CUSTOMER ||'; ' || CUST_SAP_NUMBER_DEBITOR || '; ' || NAME_CAPTION1 );
		:L_DATAWARNINGS_OCCURED:= :L_DATAWARNINGS_OCCURED+1;
		:L_DATASUCCESS_OCCURED:= :L_DATASUCCESS_OCCURED+1;
	end loop;
	close c_partner_data;
	select
		count(TCUSTOMER.ID_CUSTOMER)
	into
		:L_DATASUCCESS_OCCURED
	from
		TNAME, TADRASSOZ, TCUSTOMER, TCUSTOMERTYP
	where
		TNAME.ID_SEQ_NAME=TADRASSOZ.ID_SEQ_NAME
		and TADRASSOZ.ID_SEQ_ADRASSOZ=TCUSTOMER.ID_SEQ_ADRASSOZ
		and TCUSTOMER.ID_CUSTYP=TCUSTOMERTYP.ID_CUSTYP
		and TCUSTOMERTYP.CUSTYP_CAPTION not like 'MIG_OOS%'
	;
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
