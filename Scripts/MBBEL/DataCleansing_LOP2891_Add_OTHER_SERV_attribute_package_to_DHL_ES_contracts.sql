-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-04-18; MZu; V1.0; MKS-132231:1; Initial Build
-- 2014-04-23; TK ; V1.1; MKS-132231:2; Change Attribute package from INSTALL_SUP to OTHERS_SERV

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_LOP2891_Add_OTHER_SERV_attribute_package_to_DHL_ES_contracts
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
variable nachricht       	varchar2 ( 200 char );
exec :L_SCRIPTNAME := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED :=0
exec :L_DATAERRORS_OCCURED :=0
exec :L_DATAWARNINGS_OCCURED :=0

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

-- Define Contracts that are going to be used. The car contract can be omitted. "ALL" is reported back then.
declare
	cursor c_guid_contract ( p_id_vertrag varchar2
                        	, p_id_fzgvertrag varchar2 default '%'
                          	) is
		select
			TFZGVERTRAG.GUID_CONTRACT,
			TFZGVERTRAG.ID_VERTRAG,
			TFZGVERTRAG.ID_FZGVERTRAG
		from
			snt.TFZGVERTRAG
		where
			TFZGVERTRAG.ID_VERTRAG 	= p_id_vertrag
			and TFZGVERTRAG.ID_FZGVERTRAG like p_id_fzgvertrag
			order by 2, 3;
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Get the GUID of the package we need...
function get_guid_package ( I_ICP_CAPTION   varchar2
                             ) RETURN          varchar2 is

	-- search for package with I_ICP_CAPTION
	-- if found: return guid_package
	-- if not found: show errow message package not existing ...

	L_GUID_PACKAGE varchar2(32);
	L_DATAWARNINGS_OCCURED number(5);
	L_DATAERRORS_OCCURED number(5);
	L_ERROR_OCCURED number(5);

	begin
	-- get guid of package
		select
			GUID_PACKAGE
		into
			L_GUID_PACKAGE
		from
			snt.TIC_PACKAGE
		where
			snt.TIC_PACKAGE.ICP_CAPTION = I_ICP_CAPTION;
		return L_GUID_PACKAGE;

	EXCEPTION
		WHEN no_data_found 
			THEN
				dbms_output.put_line ( 'package ' || I_ICP_CAPTION || ' does not exist' );
				L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
				select L_DATAERRORS_OCCURED into :L_DATAERRORS_OCCURED from dual;
				return null;
		WHEN others
			then
				dbms_output.put_line ( SQLERRM );
				L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
				select L_ERROR_OCCURED into :L_ERROR_OCCURED from dual;
				return null;
end get_guid_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Get the GUID for VEGA now...
function get_vi55a_package ( I_ICP_CAPTION	varchar2
				) RETURN	varchar2 is

	-- search for package with I_ICP_CAPTION
	-- if found: return guid_package
	-- if not found: show errow message package not existing ...

	L_GUID_PACKAGE varchar2(32);
	L_DATAWARNINGS_OCCURED number(5);
	L_DATAERRORS_OCCURED number(5);
	L_ERROR_OCCURED number(5);

	begin
	-- get guid of package
		select
			TVEGA_I55_ATT_VALUE.GUID_VI55A
		into
			L_GUID_PACKAGE
		from
			snt.TIC_PACKAGE
			,snt.TVEGA_I55_ATT_VALUE
		where
			snt.TIC_PACKAGE.ICP_CAPTION = I_ICP_CAPTION
			and TIC_PACKAGE.GUID_VI55AV = TVEGA_I55_ATT_VALUE.GUID_VI55AV
			;

		return L_GUID_PACKAGE;

		EXCEPTION
			WHEN no_data_found 
				THEN
					dbms_output.put_line ( 'package ' || I_ICP_CAPTION || ' has no valid VEGA data!' );
					L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
					select L_DATAERRORS_OCCURED into :L_DATAERRORS_OCCURED from dual;
					return null;
			when others
				then
					dbms_output.put_line ( SQLERRM );
					L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
					select L_ERROR_OCCURED into :L_ERROR_OCCURED from dual;
					return null;
end get_vi55a_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Find the GUID of the lowest package that is associated with the contract given. In recursion mode: Look, if there is a level lower. If not, return Input to caller recursively. 

function get_last_guid_package ( I_guid_contract varchar2 default NULL
				,I_GUID_PACKAGE	varchar2 default NULL
                             	) RETURN          varchar2 is

	L_GUID_PACKAGE_PARENT varchar2(32 char);
	L_GUID_PACKAGE	varchar2(32 Char) := NULL;
	L_GUID_PACKAGE_SELECT varchar2(32 char);
	L_DATAWARNINGS_OCCURED number(5);
	L_DATAERRORS_OCCURED number(5);
	L_ERROR_OCCURED number(5);

	begin
		-- In case we get only a GUID_Contract, we run the first iteration. Means, we will first find a random package we will store in L_GUID_PACKAGE
		-- dbms_output.put_line ( 'Call get_last_guid_package');
		if I_GUID_PACKAGE is NULL and I_guid_contract is not NULL
			then
				--dbms_output.put_line ( 'Call get_last_guid_package.I_GUID_CONTRACT: '||I_guid_contract );
				begin
				select 
					GUID_PACKAGE
				into
					L_GUID_PACKAGE
				from	
					TIC_CO_PACK_ASS
				where
					GUID_CONTRACT=I_guid_contract
					and rownum=1;
				exception
					when no_data_found
						then
							-- Looks like there is no package attached to this contract. Then we report that back...
							dbms_output.put_line ( ' Warning: Contract with GUID ' || I_guid_contract || ' has no (Meta-)package attached!' );
							L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED +1;
							select L_DATAWARNINGS_OCCURED into :L_DATAWARNINGS_OCCURED from dual;
							return NULL;
				end;
		end if;
			
		-- Now we have either a L_GUID_PACKAGE from the function above or we will have a delivered I_GUID_PACKAGE. To be able to iterate, we will put the correct one into L_GUID_PACKAGE_SELECT
		if I_GUID_PACKAGE is NULL
			then
				L_GUID_PACKAGE_SELECT	:=	L_GUID_PACKAGE;
			else
				L_GUID_PACKAGE_SELECT 	:=	I_GUID_PACKAGE;
		end if;

		-- Lets see if we have a package that is a children to our L_GUID_PACKAGE_SELECT we think that it is on the lowest level.
		-- dbms_output.put_line ( 'L_GUID_PACKAGE_SELECT: '||L_GUID_PACKAGE_SELECT );
		select
			GUID_PACKAGE
		into
			L_GUID_PACKAGE_PARENT
		from
			snt.TIC_CO_PACK_ASS
		where
			snt.TIC_CO_PACK_ASS.GUID_PACKAGE_PARENT = L_GUID_PACKAGE_SELECT
			and snt.TIC_CO_PACK_ASS.GUID_CONTRACT = I_guid_contract;

		-- We found another children of the package we considered to be the final one. Well, then we go another round!
		-- dbms_output.put_line ( 'L_GUID_PACKAGE_PARENT: '||L_GUID_PACKAGE_PARENT );		
		return get_last_guid_package ( I_guid_contract => I_guid_contract, I_guid_package => L_GUID_PACKAGE_PARENT);

		exception
			when no_data_found
				then 
				-- No more data means: Lools like the package we have in L_GUID_PACKAGE_SELECT is on the lowest level. Tell the caller to finalize the recursion.
				-- dbms_output.put_line ( 'Exception: No Package found with parent: '||L_GUID_PACKAGE_SELECT );
				return L_GUID_PACKAGE_SELECT;
			when others
				then
					dbms_output.put_line ( SQLERRM );
					L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
					select L_ERROR_OCCURED into :L_ERROR_OCCURED from dual;
					return null;
			
end get_last_guid_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- This procedure is called for each of the set of data by exec_add_package.
-- Functionality: Call get_last_guid_package to get the required GUID_PACKAGE_PARENT, insert collected data into the DB, "main logfile output"

procedure add_attribute_package (	I_guid_contract		snt.TFZGVERTRAG.GUID_CONTRACT%type
					,I_id_vertrag		snt.TFZGVERTRAG.ID_VERTRAG%type
					,I_ID_FZGVERTRAG	snt.TFZGVERTRAG.ID_FZGVERTRAG%type
					,I_guid_package		snt.TIC_PACKAGE.GUID_PACKAGE%type
					,I_GUID_VI55A		snt.TVEGA_I55_ATT_VALUE.GUID_VI55A%type
					,I_ATTR_PACK varchar2
					) is
	L_GUID_PACKAGE_PARENT varchar2(32 char);
	L_DATAWARNINGS_OCCURED number(5);
	L_DATAERRORS_OCCURED number(5);
	L_ERROR_OCCURED number(5);

	-- Define exception in case this package GUID exists already as parent GUID.
	gibt_es_schon exception ;
		pragma exception_init(gibt_es_schon,-20112);
  	
	
	begin
		-- First, get the the last current used GUID for a package attached to the handed over contract
		L_GUID_PACKAGE_PARENT := get_last_guid_package ( I_guid_contract => I_guid_contract );

		-- Now we have all required data to do the final insert of the attribute package
		INSERT 
			into
				snt.tic_co_pack_ass (	GUID_CONTRACT,		GUID_PACKAGE,	GUID_PACKAGE_PARENT,	GUID_VI55A,	LAST_OPERATION)
			VALUES
				(			I_guid_contract,	I_guid_package	, L_GUID_PACKAGE_PARENT,I_GUID_VI55A,	'I');
		dbms_output.put_line ( 'Contract ' || I_id_vertrag || '/'|| I_ID_FZGVERTRAG || ': Attribute Package ' || I_ATTR_PACK || ' added.' );

		-- In case we get a message that this GUID_PACKAGE can not be set (because it exists already or is defined as parent to this package)
		EXCEPTION
			WHEN dup_val_on_index 
				THEN
					dbms_output.put_line ( 'Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ': Attribute Package ' || I_ATTR_PACK || ' already active!' );
					L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED +1;
					select L_DATAWARNINGS_OCCURED into :L_DATAWARNINGS_OCCURED from dual;

			WHEN gibt_es_schon
				THEN
					dbms_output.put_line ( 'Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ': Attribute Package ' || I_ATTR_PACK || ' already active!' );
					L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED +1;
					select L_DATAWARNINGS_OCCURED into :L_DATAWARNINGS_OCCURED from dual;
			when others
				THEN
					dbms_output.put_line ( SQLERRM );
					L_ERROR_OCCURED := :L_ERROR_OCCURED +1;
					select L_ERROR_OCCURED into :L_ERROR_OCCURED from dual;
end add_attribute_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- This procedure is the entry point. We initialize the array and are then looping through its positions
-- Parameters:
-- exec_add_package ( I_ATTR_PACK => 'MORE_WISHES', I_ID_VERTRAG => '000815' )
-- 	to add the attribute package 'MORE_WISHES' to all car contracts with this base contract
-- or
-- exec_add_package ( I_ATTR_PACK => 'MORE_WISHES', I_ATTR_PACK => '000815', I_FZGVERTRAG = '01??' )
--	for the same result but only for all car contracts with the starting numbers "01" and 2 more letters/digits from this base contract
-- 	(of course its also possible to just name a single contract/car contract such as "000815"/"0123" aswell
--
-- Note: The Attribute package has to be created in Sirius FIRST!

procedure exec_add_package (	I_ATTR_PACK	varchar2
				, I_ID_VERTRAG	varchar2
				, I_FZGVERTRAG	varchar2 default '%'
				) is

	L_GUID_PACKAGE		snt.TIC_PACKAGE.GUID_PACKAGE%type;
	L_GUID_VI55A		TVEGA_I55_ATT_VALUE.GUID_VI55A%type;


	begin
		-- Lets see if the attribute package exists and valid... 
		L_GUID_PACKAGE := get_guid_package ( I_ICP_CAPTION => I_ATTR_PACK );
		L_GUID_VI55A := get_vi55a_package ( I_ICP_CAPTION => I_ATTR_PACK );
	
		-- In case both checks were successfull - then we got no NULL-result back - lets go to work:
		-- (Error-Handling for L_GUID_PACKAGE and L_GUID_VI55A are done in their functions. No need to check for them here further than NULL-esults.)
		if L_GUID_PACKAGE is not null and L_GUID_VI55A is not null
			then
				for my_cursor IN c_guid_contract (	P_ID_VERTRAG => I_ID_VERTRAG
									, P_ID_FZGVERTRAG => I_FZGVERTRAG
									)
					loop
						add_attribute_package ( my_cursor.guid_contract, my_cursor.id_vertrag, my_cursor.ID_FZGVERTRAG, L_GUID_PACKAGE, L_GUID_VI55A , I_ATTR_PACK);
					end loop;
		end if;
         
end exec_add_package;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- The function call to get going...

begin
	exec_add_package	( I_ATTR_PACK	=> 'OTHERS_SERV'
				, I_ID_VERTRAG	=> 'DHL_ES'
				--, I_FZGVERTRAG => '%'
				);
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
  dbms_output.put_line ('Data warnings: ' || :L_DATAWARNINGS_OCCURED);
  dbms_output.put_line ('Data errors  : ' || :L_DATAERRORS_OCCURED);
  dbms_output.put_line ('System errors: ' || :L_ERROR_OCCURED);

 end if;
end;
/
exit;
