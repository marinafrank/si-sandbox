-- DataAnalysis_DEF7813_Contracts_with_product_MIGRATION.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2015-02-25; MARZUHL; V1.0; MKS-136345:1; Initial Release

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataAnalysis_DEF7274_Partners_with_ZIP_not_4_chars_length
   define GL_LOGFILETYPE	= LOG        -- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   define GL_SCRIPTFILETYPE	= SQL        -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN        = 2
   define L_MINOR_MIN        = 8
   define L_REVISION_MIN    = 1
   define L_BUILD_MIN        = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER        = SIMEX
   define L_SYSDBA_PRIV_NEEDED    = false        -- false or true

  -- country specification
   define L_MPC_CHECK        = true        -- false or true
   define L_MPC_SOLL        = 'MBBeLux'
  
  -- Reexecution
   define  L_REEXEC_FORBIDDEN    = false        -- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   define L_DB_LOGGING_ENABLE    = true        -- Are we logging to the DB? -> false or true
   define L_LOGFILE_REQUIRED    = true        -- Logfile required? -> false or true

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

variable L_SCRIPTNAME         varchar2 (200 char);
variable L_ERROR_OCCURED     number;
variable L_DATAERRORS_OCCURED     number;
variable L_DATAWARNINGS_OCCURED number;
variable L_DATASUCCESS_OCCURED number;
variable nachricht           varchar2 ( 200 char );
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
  dbms_output.put_line ('Database Country (via Link) : ' ||snt.get_TGLOBAL_SETTINGS@simex_db_link ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' )); 
  dbms_output.put_line ('Database dump date (via Link): ' ||snt.get_TGLOBAL_SETTINGS@simex_db_link ( 'DB', 'DUMP', 'DATE', 'not found' )); 
  begin
              select to_char (max( LE_CREATED), 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
                  from snt.TLOG_EVENT@simex_db_link e
                 where GUID_LA = '10'         -- maintenance
                   and exists ( select null
                                  from snt.TLOG_EVENT_PARAM@simex_db_link ep
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


   L_MAJOR_IST             integer := snt.get_tglobal_settings@simex_db_link ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings@simex_db_link ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings@simex_db_link ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings@simex_db_link ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE@simex_db_link%TYPE := snt.get_TGLOBAL_SETTINGS@simex_db_link ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' );
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
                  from snt.TLOG_EVENT@simex_db_link e
                 where GUID_LA = '10'         -- maintenance
                   and exists ( select null
                                  from snt.TLOG_EVENT_PARAM@simex_db_link ep
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
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >



-- main part for < selecting or checking or correcting code >
declare
	l_ID_CUSTOMER			TCUSTOMER.ID_CUSTOMER@simex_db_link%type;
	l_cust_sap_number_debitor	TCUSTOMER.cust_sap_number_debitor@simex_db_link%type;
	l_NAME_CAPTION1			TNAME.NAME_CAPTION1@simex_db_link%type;
	l_COU_CODE			TCOUNTRY.COU_CODE@simex_db_link%type;
	l_ZIP_ZIP			TZIP.ZIP_ZIP@simex_db_link%type;
	cursor cur_SELECT is
		select
			id_customer
			, CoFiCoID
			, NAME_CAPTION1
			, COU_CODE
			, ZIP_ZIP
		from
			( select distinct		-- das SubSelect ist noetig, da ansonsten die Laufzeit von Oracle ins unendliche steigt)
			id_customer			as id_customer
			, cust_sap_number_debitor	as CoFiCoID
			, ID_SEQ_ADRASSOZ		as ID_SEQ_ADRASSOZ
			, TCOUNTRY.COU_CODE		as COU_CODE
			, TZIP.ZIP_ZIP			as ZIP_ZIP
		from
			snt.tfzgv_contracts@simex_db_link	tfzgv_contracts
			join snt.tdfcontr_variant@simex_db_link	tdfcontr_variant	using (id_cov)
			join snt.TVERTRAGSTAMM@simex_db_link	TVERTRAGSTAMM		using (id_vertrag)
			join snt.TCUSTOMER@simex_db_link	TCUSTOMER		on TVERTRAGSTAMM.id_customer=TCUSTOMER.id_customer
			join snt.TADRASSOZ@simex_db_link	TADRASSOZ		using (ID_SEQ_ADRASSOZ)
			-- join snt.TNAME@SIMEX_DB_LINK		TNAME			using (ID_SEQ_NAME)
			join snt.TADRESS@simex_db_link		TADRESS			using (ID_SEQ_ADRESS)
			join snt.TZIP@simex_db_link		TZIP			using (ID_SEQ_ZIP)
			join snt.TCOUNTRY@SIMEX_DB_LINK		TCOUNTRY		using (ID_COUNTRY)
		where
			tdfcontr_variant.cov_caption not like 'MIG_OOS%'
			and PCK_CALCULATION.SUBSTITUTE('0',to_timestamp(sysdate),to_char('COU_CODE'),TCOUNTRY.COU_CODE) = 'BE'
			and length(TZIP.ZIP_ZIP) <> 4
		order by
			1)
			join snt.TADRASSOZ@simex_db_link	TADRASSOZ2		using (ID_SEQ_ADRASSOZ)
			join snt.TNAME@SIMEX_DB_LINK		TNAME2			using (ID_SEQ_NAME)
		;

begin
	select 
		count (ZIP_ZIP)
	INTO
		:L_DATASUCCESS_OCCURED
	from
		snt.tfzgv_contracts@simex_db_link	tfzgv_contracts
		join snt.tdfcontr_variant@simex_db_link	tdfcontr_variant	using (id_cov)
		join snt.TVERTRAGSTAMM@simex_db_link	TVERTRAGSTAMM		using (id_vertrag)
		join snt.TCUSTOMER@simex_db_link	TCUSTOMER		on TVERTRAGSTAMM.id_customer=TCUSTOMER.id_customer
		join snt.TADRASSOZ@simex_db_link	TADRASSOZ		using (ID_SEQ_ADRASSOZ)
		join snt.TADRESS@simex_db_link		TADRESS			using (ID_SEQ_ADRESS)
		join snt.TZIP@simex_db_link		TZIP			using (ID_SEQ_ZIP)
		join snt.TCOUNTRY@SIMEX_DB_LINK		TCOUNTRY		using (ID_COUNTRY)
	where
		tdfcontr_variant.cov_caption not like 'MIG_OOS%'
	;

	OPEN cur_SELECT;
	LOOP
		fetch cur_SELECT into l_ID_CUSTOMER, l_cust_sap_number_debitor, l_NAME_CAPTION1, l_COU_CODE, l_ZIP_ZIP;
		if cur_SELECT%NOTFOUND
		then
			if  cur_SELECT%ROWCOUNT <1
			then
				dbms_output.put_line ('INFO : No malformed ZIPs found.');
			end if;
			exit;
		end if;

		if cur_SELECT%ROWCOUNT = 1
		then
			dbms_output.put_line ('WARN: ID_CUSTOMER; CoFiCo-ID; NAME_CAPTION1; COU_CODE; ZIP_ZIP');
			dbms_output.put_line ('WARN: --------------------------------------------------------');
		end if;
		dbms_output.put_line ('WARN: ' || l_ID_CUSTOMER || '; ' || l_cust_sap_number_debitor || '; ' || l_NAME_CAPTION1  || '; ' || l_COU_CODE || '; ' || l_ZIP_ZIP);
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
        snt.SRS_LOG_MAINTENANCE_SCRIPTS@simex_db_link ( :L_SCRIPTNAME );
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
