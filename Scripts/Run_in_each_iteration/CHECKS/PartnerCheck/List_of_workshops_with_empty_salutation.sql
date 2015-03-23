-- List_of_workshops_with_empty_salutation.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- FraBe   15.02.2013 MKS-122287:1 creation: almost copied from List_of_customers_with_empty_salutation.sql
-- 2014-05-16; MARZUHL; V1.0; MKS-132553:1; Changed to new output format / framework

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= List_of_workshops_with_empty_salutation
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
   define L_MPC_CHECK		= false		-- false or true
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

-- main part for < selecting or checking or correcting code >

declare
	l_ID_GARAGE		varchar2 (50 char);
	l_ID_TITLE		varchar2 (50 char);
	l_TITLE			varchar2 (50 char);

	CURSOR cur_SELECT IS
		select
			gar.ID_GARAGE
			, vadr.ID_TITLE		as ID_TITLE
			, vadr.TIT_CAPTION	as TITLE
		from
			snt.TGARAGE		gar
			, snt.VADRASSOZ		vadr
		where
			vadr.ID_SEQ_ADRASSOZ     = gar.ID_SEQ_ADRASSOZ
			and nvl ( vadr.ID_TITLE, 0 ) = 0
		order by
			1;

begin
	SELECT
		count(gar.ID_GARAGE)
	INTO
		:L_DATASUCCESS_OCCURED
	from
		snt.TGARAGE		gar
		, snt.VADRASSOZ		vadr
	where
		vadr.ID_SEQ_ADRASSOZ     = gar.ID_SEQ_ADRASSOZ
	;

	OPEN cur_SELECT;
	LOOP
		fetch cur_SELECT into l_ID_GARAGE, l_ID_TITLE, l_TITLE;
		if cur_SELECT%NOTFOUND
		then
			if  cur_SELECT%ROWCOUNT <1
			then
				dbms_output.put_line ('No data warnings found.');
			end if;
			exit;
		end if;
		if cur_SELECT%ROWCOUNT = 1
		then
			dbms_output.put_line ('WARN: ID_GARAGE; ID_TITLE; TITLE');
			dbms_output.put_line ('WARN: --------------------------');
		end if;
		dbms_output.put_line ('WARN: ' || l_ID_GARAGE || '; ' ||l_ID_TITLE || '; ' ||l_TITLE);
		:L_DATAWARNINGS_OCCURED:=:L_DATAWARNINGS_OCCURED +1;
	END LOOP;
	close cur_SELECT;

	exception
		when others then
			dbms_output.put_line ( 'A unhandled error occured. - Data may be incomplete!' );
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
