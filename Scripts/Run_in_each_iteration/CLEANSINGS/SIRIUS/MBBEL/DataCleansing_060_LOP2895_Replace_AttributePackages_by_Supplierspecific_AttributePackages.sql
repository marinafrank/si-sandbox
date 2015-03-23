-- DataCleansing_060_LOP2895_Replace_AttributePackages_by_Supplierspecific_AttributePackages.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-06-02; MARZUHL; V1.0; MKS-132667:1; Initial Release
-- 2014-06-02; MARZUHL; V1.0; MKS-133166:2; Initial Release

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_060_LOP2895_Replace_AttributePackages_by_Supplierspecific_AttributePackages
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

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare											-- Define Contracts that are going to be used. The car contract can be omitted. "ALL" is reported back then.
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

function get_guid_package ( I_ICP_CAPTION   varchar2					-- Get the GUID of the package we need...
                             ) RETURN	varchar2 is

	-- search for package with I_ICP_CAPTION
	-- if found: return guid_package
	-- if not found: show errow message package not existing ...

	L_GUID_PACKAGE		varchar2(32);

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

	EXCEPTIOn
		WHEN no_data_found 
			THEN
				dbms_output.put_line ( 'package ' || I_ICP_CAPTION || ' does not exist' );
				:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
				return null;
		WHEN others
			then
				dbms_output.put_line ( SQLERRM );
				:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
				return null;
end get_guid_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Find the GUID of the new package. If no GUID can be found, re-run function with I_CREATE activated.
-- In recursion mode: (or I_CREATE given) copy the package data in tic_package and set new package name. 

function get_guid_ATTR_PACK_NEU (	I_guid_contract		snt.TFZGVERTRAG.GUID_CONTRACT%type
					, I_GUID_PACKAGE	snt.TIC_PACKAGE.GUID_PACKAGE%type
					, I_ATTR_PACK_NEU	snt.TIC_PACKAGE.GUID_PACKAGE%type
					, I_CREATE		boolean default false
                             	) RETURN          		snt.TIC_PACKAGE.GUID_PACKAGE%type
is

	L_GUID_ATTR_PACK_NEU	snt.TIC_PACKAGE.GUID_PACKAGE%type;

	begin
		if I_CREATE = true then
			begin
				insert into
					tic_package (	ID_PACKAGE
							, ICP_CAPTION
							, ICP_PACKAGE_TYPE
							, ICP_I5X_VALUE
							, GUID_VI55AV
							, LAST_OPERATION_DATE
							, GUID_VEHICLE_LINE
							, GUID_CCP
							, ICP_CUSTOMER_CONTRIBUTION
							, ICP_MILEAGE_LIMIT
							, ICP_CLAIM_DIVISION
							, ICP_LABOUR_EVALUAT_CODE
							)
					select
						ID_PACKAGE
						, I_ATTR_PACK_NEU
						, ICP_PACKAGE_TYPE
						, ICP_I5X_VALUE
						, GUID_VI55AV
						, LAST_OPERATION_DATE
						, GUID_VEHICLE_LINE
						, GUID_CCP
						, ICP_CUSTOMER_CONTRIBUTION
						, ICP_MILEAGE_LIMIT
						, ICP_CLAIM_DIVISION
						, ICP_LABOUR_EVALUAT_CODE
					from
						tic_package
					where
						GUID_PACKAGE = I_GUID_PACKAGE
				;
				dbms_output.put_line ( 'INFO: Created/copied package ' || I_ATTR_PACK_NEU);

				exception
					when dup_val_on_index then
						dbms_output.put_line ( 'ERR: Creating package ' || I_ATTR_PACK_NEU || ' failed! Already existing?' );
						dbms_output.put_line ( SQLERRM );
						:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
						return NULL;

					when others then
						dbms_output.put_line ( 'ERR: Creating package ' || I_ATTR_PACK_NEU || ' failed!' );
						dbms_output.put_line ( SQLERRM );
						:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
						return NULL;
			end;
		end if;
		
		begin
			select
				GUID_PACKAGE
			into
				L_GUID_ATTR_PACK_NEU
			from	
				TIC_PACKAGE
			where
				ICP_CAPTION	= I_ATTR_PACK_NEU
			;

			exception
				when no_data_found then
					-- Looks like there is no package till now.
					L_GUID_ATTR_PACK_NEU := get_guid_ATTR_PACK_NEU (	I_guid_contract => I_guid_contract
												, I_guid_package => I_guid_package
												, I_ATTR_PACK_NEU => I_ATTR_PACK_NEU
												, I_CREATE => true
											);

				when others then
					dbms_output.put_line ( 'ERR: Getting package_GUID for ' || I_ATTR_PACK_NEU || ' failed!' );
					dbms_output.put_line ( SQLERRM );
					:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
		end;

	return L_GUID_ATTR_PACK_NEU;

end get_guid_ATTR_PACK_NEU;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- This procedure is called for each of the set of data by EXEC_REPLACE_PACKAGE.
-- Functionality: Get GUID_ATTR_PACK_NEU and replace old GUID_PACKAGE with new one in TIC_CO_PACK_ASS, "main logfile output"

procedure replace_package (	I_guid_contract		snt.TFZGVERTRAG.GUID_CONTRACT%type
				,I_id_vertrag		snt.TFZGVERTRAG.ID_VERTRAG%type
				,I_ID_FZGVERTRAG	snt.TFZGVERTRAG.ID_FZGVERTRAG%type
				,I_guid_package		snt.TIC_PACKAGE.GUID_PACKAGE%type
				,I_ATTR_PACK_ALT	varchar2
				,I_ATTR_PACK_NEU	varchar2
				) is

	Lo_GUID_ATTR_PACK_NEU 				snt.TIC_PACKAGE.GUID_PACKAGE%type	:= NULL;

	-- Define exception in case this package GUID exists already as parent GUID.
	gibt_es_schon exception ;
		pragma exception_init(gibt_es_schon,-20112);
  	
	
	begin
		-- First, get the the GUID for ATTR_PACK_NEU
		Lo_GUID_ATTR_PACK_NEU := get_guid_ATTR_PACK_NEU (	I_guid_contract => I_guid_contract
									, I_guid_package => I_guid_package
									, I_ATTR_PACK_NEU => I_ATTR_PACK_NEU
								);

		-- Now we have all required data to do the final insert of the attribute package
		-- dbms_output.put_line ( 'DEBUG: I_guid_contract: ' || I_guid_contract );
		-- dbms_output.put_line ( 'DEBUG: I_guid_package: ' || I_guid_package );
		-- dbms_output.put_line ( 'DEBUG: I_ATTR_PACK_NEU: ' ||I_ATTR_PACK_NEU );
		-- dbms_output.put_line ( 'DEBUG: Lo_GUID_ATTR_PACK_NEU: ' || Lo_GUID_ATTR_PACK_NEU );

		if Lo_GUID_ATTR_PACK_NEU is not NULL then
			update
				snt.tic_co_pack_ass
			set 
				GUID_PACKAGE = Lo_GUID_ATTR_PACK_NEU
			where
				GUID_PACKAGE = I_GUID_PACKAGE
				AND GUID_CONTRACT = I_guid_contract
			;
			if SQL%ROWCOUNT >=1 then
				-- dbms_output.put_line ('DEBUG: Update main package - SQL ROWCOUNT: ' ||SQL%ROWCOUNT);
				update
					snt.tic_co_pack_ass
				set 
					GUID_PACKAGE_PARENT = Lo_GUID_ATTR_PACK_NEU
				where
					GUID_PACKAGE_PARENT = I_GUID_PACKAGE
					AND GUID_CONTRACT = I_guid_contract
				;
				-- dbms_output.put_line ('DEBUG: Update children packages - SQL ROWCOUNT: ' ||SQL%ROWCOUNT);
				dbms_output.put_line ( 'INFO: Contract ' || I_id_vertrag || '/'|| I_ID_FZGVERTRAG || ': Package moved: ' || I_ATTR_PACK_ALT || ' => ' || I_ATTR_PACK_NEU );
				:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
			else
				dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ' could not be modified. (Contract does not have old package?)');
				:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
			end if;
			

		else
			dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ' could not be modified. (New package could not be found?)');
			:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
		end if;

		-- In case we get a message that this GUID_PACKAGE can not be set (because it exists already or is defined as parent to this package)

	EXCEPTIoN
		WHEN dup_val_on_index THEN
			dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ': Attribute Package ' || I_ATTR_PACK_NEU|| ' already active!' );
			:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;

		WHEN gibt_es_schon THEN
			dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ': Attribute Package ' || I_ATTR_PACK_NEU || ' already active!' );
					:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;

		when others THEN
				dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_ID_FZGVERTRAG || ' could not be modified.'); 
				dbms_output.put_line ( SQLERRM );
				:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;

end replace_package;

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

procedure EXEC_REPLACE_PACKAGE ( I_ATTR_PACK_ALT	varchar2
				, I_ATTR_PACK_NEU	varchar2
				, I_ID_VERTRAG		varchar2
				, I_FZGVERTRAG		varchar2		default '%'
				) is

	L_GUID_PACKAGE					snt.TIC_PACKAGE.GUID_PACKAGE%type;
	L_CONTRACT_FOUND				boolean			:= false;

	begin
		-- dbms_output.put_line ( 'DEBUG: I_ATTR_PACK_ALT: '|| I_ATTR_PACK_ALT || ' I_ATTR_PACK_NEU: ' || I_ATTR_PACK_NEU || ', I_ID_VERTRAG: ' || I_ID_VERTRAG || ', I_FZGVERTRAG: ' || I_FZGVERTRAG );
		-- Lets see if the attribute package exists and valid... 
		L_GUID_PACKAGE := get_guid_package ( I_ICP_CAPTION => I_ATTR_PACK_ALT );
	
		-- In case both checks were successfull - then we got no NULL-result back - lets go to work:
		-- (Error-Handling for L_GUID_PACKAGE and L_GUID_VI55A are done in their functions. No need to check for them here further than NULL-esults.)
		if L_GUID_PACKAGE is not null then
			for my_cursor IN c_guid_contract (	P_ID_VERTRAG		=> I_ID_VERTRAG
								, P_ID_FZGVERTRAG	=> I_FZGVERTRAG
								)
				loop
					L_CONTRACT_FOUND := true;
					-- dbms_output.put_line ( 'DEBUG: my_cursor.guid_contract: ' || my_cursor.guid_contract || ', L_GUID_PACKAGE: ' || L_GUID_PACKAGE);
					replace_package (	I_guid_contract		=> my_cursor.guid_contract
								, I_id_vertrag		=> my_cursor.id_vertrag
								, I_ID_FZGVERTRAG 	=> my_cursor.ID_FZGVERTRAG
								, I_guid_package	=> L_GUID_PACKAGE
								, I_ATTR_PACK_ALT	=> I_ATTR_PACK_ALT
								, I_ATTR_PACK_NEU	=> I_ATTR_PACK_NEU
							);
				end loop;
		end if;
		if L_CONTRACT_FOUND = false then
			dbms_output.put_line ( 'ERR: Contract ' || I_ID_VERTRAG || '/'|| I_FZGVERTRAG || ' could not be found.');
			:L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED +1;
		end if;
         
end EXEC_REPLACE_PACKAGE;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- The function call to get going...

begin
	--exec_replace_package	( I_ATTR_PACK_ALT	=> 'OTHERS_SERV_ALT'
	--			, I_ATTR_PACK_NEU	=> 'OTHERS_SERV_NEU'
	--			, I_ID_VERTRAG	=> 'DHL_ES'
	--			--, I_FZGVERTRAG => '%'
	--			);
	exec_replace_package	( '06.D', '06.D_5005', '004351', '0001' );
	exec_replace_package	( '04.D', '04.D_5009', '004894', '0001' );
	exec_replace_package	( '04.D', '04.D_5040', '004895', '0001' );
	exec_replace_package	( '04.D', '04.D_5058', '005117', '0004' );
	exec_replace_package	( '04.D', '04.D_5058', '005135', '0001' );
	exec_replace_package	( '04.D', '04.D_5058', '005135', '0003' );
	exec_replace_package	( '04.D', '04.D_5129', '005810', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '005870', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '006120', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '006220', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '006645', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '006645', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '006895', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '006926', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '007047', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '007166', '0001' );
	exec_replace_package	( '04.D', '04.D_5058', '007458', '0001' );
	exec_replace_package	( '04.D', '04.D_5058', '007458', '0002' );
	exec_replace_package	( '04.D', '04.D_5086', '007573', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '007707', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '007779', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '007779', '0002' );
	exec_replace_package	( '04.D', '04.D_5001', '007809', '0001' );
	exec_replace_package	( '04.D', '04.D_5063', '008120', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '008280', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '008480', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '008535', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '008537', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '008537', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '008537', '0003' );
	exec_replace_package	( '04.D', '04.D_5129', '008665', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '008665', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '008665', '0003' );
	exec_replace_package	( '04.D', '04.D_5129', '009027', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '009027', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0003' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0004' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0005' );
	exec_replace_package	( '04.D', '04.D_5172', '009295', '0006' );
	exec_replace_package	( '04.D', '04.D_5032', '009486', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '009738', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '009738', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '009837', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '009837', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '009837', '0003' );
	exec_replace_package	( '04.D', '04.D_5172', '012072', '0001' );
	exec_replace_package	( '06.D', '06.D_5005', '012263', '0001' );
	exec_replace_package	( '06.D', '06.D_5005', '012263', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '012380', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '012380', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '013373', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '014194', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '014430', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '015151', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '016249', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '016792', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '016792', '0002' );
	exec_replace_package	( '04.D', '04.D_5129', '018126', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '020186', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '020815', '0001' );
	exec_replace_package	( '04.D', '04.D_5129', '021298', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '021448', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '021470', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '021625', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '023046', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '023324', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '025057', '0001' );
	exec_replace_package	( '06.D', '06.D_5005', '026603', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '026647', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '026647', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '026647', '0003' );
	exec_replace_package	( '04.D', '04.D_5172', '026862', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '027014', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '028415', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '029142', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '030631', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '030631', '0002' );
	exec_replace_package	( '04.D', '04.D_5032', '031863', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '032907', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '034925', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '035154', '0001' );
	exec_replace_package	( '04.D', '04.D_5280', '036001', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '037955', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '039925', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '040859', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '040859', '0002' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0002' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0003' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0004' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0005' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0006' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0007' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0008' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0009' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0010' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0011' );
	exec_replace_package	( '04.D', '04.D_5032', '041593', '0012' );
	exec_replace_package	( '04.D', '04.D_5172', '043199', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '044072', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '046795', '0001' );
	exec_replace_package	( '04.D', '04.D_5172', '046795', '0002' );
	exec_replace_package	( '04.D', '04.D_5172', '046795', '0006' );
	exec_replace_package	( '04.D', '04.D_5032', '047746', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '047874', '0001' );
	exec_replace_package	( '04.D', '04.D_5032', '047874', '0002' );
	exec_replace_package	( '04.D', '04.D_5032', '047882', '0001' );

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
