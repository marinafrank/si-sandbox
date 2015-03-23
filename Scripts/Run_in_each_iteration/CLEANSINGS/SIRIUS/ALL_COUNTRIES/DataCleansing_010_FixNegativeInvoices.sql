-- DataCleansing_010_FixNegativeInvoices.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- CPauzen     23.07.2103 MKS-124275:1
-- FraBe       24.07.2013 MKS-124275:2 add L_ERROR_OCCURED plus some small changes 
-- CPauzen     26.07.2013 MKS-124275:1 kleinere Änderungen nach Dev-Tests
-- FraBe       29.07.2013 MKS-124275:2 disable trigger IP_NO_UPD_DEL
-- FraBe       30.07.2013 MKS-124275:2 add ins of Info Gutschrift
-- CPauzen     29.08.2013 MKS-127744:1 This Script can be executed several times
-- 2014-05-16; MARZUHL; V1.0; MKS-132563:1; Changed to new output format / framework
-- 2014-05-20; MARZUHL; V1.1; MKS-132563:1; "alter trigger SNT.IP_NO_UPD_DEL disable/enable;" as discussed with TK.

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_010_FixNegativeInvoices
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
alter trigger SNT.IP_NO_UPD_DEL disable;

-- main part for < selecting or checking or correcting code >

prompt
prompt 1st create new InvoiceType Info Gutschrift
prompt

begin
	insert into
		snt.TBELEGARTEN
			( ID_BELEGART
			, BELART_CAPTION
			, BELART_SOLL_HABEN
			, BELART_REFERENZ_BUCHUNG
			, BELART_SHORTCAP
			, BELART_IGNORE_DOUBLE_INVOICE
			, BELART_SUM_INVOICE
			, BELART_SAP_INVOICE_TYPE
			, BELART_INVOICE_OR_CNOTE
			, BELART_TRANSFER_TO_FINSYS
			, ID_BELEGART_DAVIS
			, BELART_I5X_RELEVANT
			, BELART_SHOW_VEGA_FIELDS
			, BELART_INTERNAL_SUBVENTION )
			select
				6				--> neue InfoGutschrift - ID_BELEGART
				, 'Info Gutschrift'		--> neue InfoGutschrift - BELART_CAPTION
				, -1				--> BELART_SOLL_HABEN für Gutschrift
				, BELART_REFERENZ_BUCHUNG
				, 'INFGU'			--> neue InfoGutschrift - BELART_SHORTCAP
				, BELART_IGNORE_DOUBLE_INVOICE
				, BELART_SUM_INVOICE
				, BELART_SAP_INVOICE_TYPE
				, 1				--> BELART_INVOICE_OR_CNOTE für Gutschrift
				, BELART_TRANSFER_TO_FINSYS
				, ID_BELEGART_DAVIS
				, BELART_I5X_RELEVANT
				, BELART_SHOW_VEGA_FIELDS
				, BELART_INTERNAL_SUBVENTION
			from
				snt.TBELEGARTEN
			where
				ID_BELEGART    = 4		--> copy main data fom Info Rechnung - Belegart
     	;

	exception
		when DUP_VAL_ON_INDEX then
			dbms_output.put_line ('WARN: InvoiceType "Info Gutschrift" could not be created. (In case this script is not executed the first time, this warning can be ignored.)');
			:L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED +1;
		when others then
			:L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
			dbms_output.put_line ( SQLERRM );
end;
/

prompt
prompt 2nd: convert negative values
prompt
declare
       l_id_belegart_new    snt.TFZGRECHNUNG.id_belegart%type;
       l_fzgre_matbrutto    snt.TFZGRECHNUNG.fzgre_matbrutto%type;
       l_fzgre_matnetto     snt.TFZGRECHNUNG.fzgre_matnetto%type;
       l_fzgre_resumme      snt.TFZGRECHNUNG.fzgre_resumme%type;
       l_fzgre_sum_other    snt.TFZGRECHNUNG.fzgre_sum_other%type;
       l_fzgre_awsumme      snt.TFZGRECHNUNG.fzgre_awsumme%type;
       l_fzgre_sum_rejected snt.TFZGRECHNUNG.fzgre_sum_rejected%type;  
    
-- Suche alle Werkstattrechnung mit negativen Vorzeichen 
begin
	for crec in (
	select
		id_seq_fzgrechnung
		, fzgre_matbrutto
		, fzgre_matnetto
		, fzgre_resumme
		, fzgre_awsumme
		, fzgre_sum_other
		, fzgre_sum_rejected
		, id_belegart
	from
		snt.TFZGRECHNUNG
	where
		fzgre_resumme    < 0 
	) loop
		begin
				-- Vorzeichen umdrehen
				l_fzgre_matbrutto    := crec.fzgre_matbrutto    * (-1);
				l_fzgre_matnetto     := crec.fzgre_matnetto     * (-1);
				l_fzgre_resumme      := crec.fzgre_resumme      * (-1);
				l_fzgre_awsumme      := crec.fzgre_awsumme      * (-1);
				l_fzgre_sum_other    := crec.fzgre_sum_other    * (-1);
				l_fzgre_sum_rejected := crec.fzgre_sum_rejected * (-1);
           
				 -- Belegart tauschen
				case crec.id_belegart
					when  0 then
						l_id_belegart_new := 1;            --> normale  rechnung   wird   zur normalen gutschrift
					when  1 then 
						l_id_belegart_new := 0;            --> normale  gutschrift wird   zur normalen rechnung
					when  4 then
						l_id_belegart_new := 6;            --> info     rechnung           -> info     gutschrift   
					when  6 then
						l_id_belegart_new := 4;            --> info     gutschrift         -> info     rechnung
					when 89 then
						l_id_belegart_new := 88;           --> VEGA     claim              -> VEGA     claim gutschrift
					when 88 then
						l_id_belegart_new := 89;           --> VEGA     claim gutschrift   -> VEGA     claim 
					when 77 then
						l_id_belegart_new := 78;           --> internal subsidy            ->internal subsidy gutschrift
					when 78 then
						l_id_belegart_new := 77;           --> internal subsidy gutschrift ->internal subsidy 
					else
						dbms_output.put_line ( 'This invoice cannot be fixed due to unknown InvoiceType ' || crec.id_belegart || ' in SIRIUS Invoice Number: ' || to_char ( crec.id_seq_fzgrechnung, '9999999' ));
						:L_DATAERRORS_OCCURED  := :L_DATAERRORS_OCCURED + 1;
				end case;
           
				-- Update
				update
					snt.TFZGRECHNUNG
				set
					fzgre_matbrutto		= l_fzgre_matbrutto
					, fzgre_matnetto	= l_fzgre_matnetto
					, fzgre_resumme		= l_fzgre_resumme
					, fzgre_awsumme		= l_fzgre_awsumme
					, fzgre_sum_other	= l_fzgre_sum_other
					, fzgre_sum_rejected	= l_fzgre_sum_rejected
					, id_belegart		= l_id_belegart_new
				where
					id_seq_fzgrechnung	= crec.id_seq_fzgrechnung
				;

				update
					snt.TINV_POSITION
				set
					ip_listprice		= ip_listprice      * (-1)
					, ip_grossprice		= ip_grossprice     * (-1)   
					, ip_sum_work		= ip_sum_work       * (-1)
					, ip_sum_part		= ip_sum_part       * (-1)
					, ip_sum_other		= ip_sum_other      * (-1)
					, ip_reject_amount	= ip_reject_amount  * (-1)
				where
					id_seq_fzgrechnung	= crec.id_seq_fzgrechnung
				;

				dbms_output.put_line ( 'Negative invoice fixed:  ' || 'SIRIUS Invoice Number: ' || to_char ( crec.id_seq_fzgrechnung, '9999999' ));
				:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;

			exception
				when others then
					:L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
					dbms_output.put_line ( 'ERR: Problems while processing ' || to_char ( crec.id_seq_fzgrechnung, '9999999' ));
					dbms_output.put_line ( SQLERRM );

			end;
		end loop;
       
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
alter trigger SNT.IP_NO_UPD_DEL enable;

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
