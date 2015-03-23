-- 20130321_Set-customer-out-of-scope-V2.0.sql
-- FraBe  30.11.2012 MKS-120410: creation
-- FraBe  20.03.2013 MKS-121517:1 add TCUSTOMER_INVOICE check / change filename

-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= Set_Customer_out_of_scope
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



declare
   L_ID_CUSTYP_MAX     number := 0;   
   L_COUNT_CUST        number := 0;
begin

   select max ( ID_CUSTYP )
     into     L_ID_CUSTYP_MAX
     from snt.TCUSTOMERTYP;
         
   for crec in ( select                                                             -- select alle kundentypen, die ...
                        ctyp.ID_CUSTYP,                    ctyp.CUSTYP_CAPTION                
                      , ctyp.CUSTYP_COMPANY,               ctyp.CUSTYP_SCOPE,               ctyp.GUID_VAT_GROUP
                      , ctyp.CUSTYP_INVOICE_TEXT,          ctyp.CUSTYP_CREDITNOTE_TEXT
                      , ctyp.GUID_NUMRANGE_DEBIT_INVOICE,  ctyp.GUID_NUMRANGE_DEBIT_CNOTE
                      , ctyp.GUID_NUMRANGE_CREDIT_INVOICE, ctyp.GUID_NUMRANGE_CREDIT_CNOTE
                      , ctyp.GUID_VAT_DEBIT_INVOICE,       ctyp.GUID_VAT_CREDIT_INVOICE
                      , ctyp.GUID_VAT_DEBIT_CNOTE,         ctyp.GUID_VAT_CREDIT_CNOTE
                   from snt.TCUSTOMERTYP ctyp
                  where ctyp.CUSTYP_CAPTION not like 'MIG_OOS%'
                  order by 1 )       -- do not convert a contract variant a 2nd time
   loop

       L_ID_CUSTYP_MAX := L_ID_CUSTYP_MAX + 1;

       insert into snt.TCUSTOMERTYP 
              ( ID_CUSTYP
              , CUSTYP_CAPTION
              , CUSTYP_COMPANY,               CUSTYP_SCOPE,               GUID_VAT_GROUP
              , CUSTYP_INVOICE_TEXT,          CUSTYP_CREDITNOTE_TEXT
              , GUID_NUMRANGE_DEBIT_INVOICE,  GUID_NUMRANGE_DEBIT_CNOTE
              , GUID_NUMRANGE_CREDIT_INVOICE, GUID_NUMRANGE_CREDIT_CNOTE
              , GUID_VAT_DEBIT_INVOICE,       GUID_VAT_CREDIT_INVOICE
              , GUID_VAT_DEBIT_CNOTE,         GUID_VAT_CREDIT_CNOTE )
       values ( L_ID_CUSTYP_MAX
              , 'MIG_OOS_'  || substr ( crec.CUSTYP_CAPTION, 1, 42 )
              , crec.CUSTYP_COMPANY,               crec.CUSTYP_SCOPE,               crec.GUID_VAT_GROUP
              , crec.CUSTYP_INVOICE_TEXT,          crec.CUSTYP_CREDITNOTE_TEXT
              , crec.GUID_NUMRANGE_DEBIT_INVOICE,  crec.GUID_NUMRANGE_DEBIT_CNOTE
              , crec.GUID_NUMRANGE_CREDIT_INVOICE, crec.GUID_NUMRANGE_CREDIT_CNOTE
              , crec.GUID_VAT_DEBIT_INVOICE,       crec.GUID_VAT_CREDIT_INVOICE
              , crec.GUID_VAT_DEBIT_CNOTE,         crec.GUID_VAT_CREDIT_CNOTE );
   
       update snt.TCUSTOMER cust                                                               -- set custtyp von kunde auf neuen MIG_OOS typ nur, wenn ...
          set ID_CUSTYP       = L_ID_CUSTYP_MAX
        where ID_CUSTYP       = crec.ID_CUSTYP 
          and not exists ( select null                                                         -- 1st: check TCUSTOMER -> TFZGV_CONTRACTS
                             from snt.TDFCONTR_VARIANT   cvar
                                , snt.TFZGV_CONTRACTS    fzgvc
                            where fzgvc.ID_CUSTOMER      in ( cust.ID_CUSTOMER                 -- ... er keinen nicht MIG_OOS vertrag hat,
                                                            , cust.CUST_INVOICE_ADRESS         -- und sein alternativer rechnungsepmf�nger auch nicht
                                                            , cust.CUST_INV_ADRESS_BALFIN )    -- bzw. der BALFIN rechnungsepmf�nger ...
                              and fzgvc.ID_COV            = cvar.ID_COV
                              and cvar.COV_CAPTION not like 'MIG_OOS%' )
          and not exists ( select null                                                         -- 2nd: MKS-121517:1 add TCUSTOMER -> TCUSTOMER_INVOICE -> TFZGV_CONTRACTS check
                             from snt.TPARTNER           part
                                , snt.TCUSTOMER_INVOICE  ci
                                , snt.TDFCONTR_VARIANT   cvar
                                , snt.TFZGV_CONTRACTS    fzgvc
                            where part.ID_CUSTOMER       in ( cust.ID_CUSTOMER                 -- ... er keine kundenrechnung hat, dessen vertrag nicht MIG_OOS ist
                                                            , cust.CUST_INVOICE_ADRESS
                                                            , cust.CUST_INV_ADRESS_BALFIN )
                              and part.GUID_PARTNER       = ci.GUID_PARTNER
                              and fzgvc.ID_SEQ_FZGVC      = ci.ID_SEQ_FZGVC
                              and fzgvc.ID_COV            = cvar.ID_COV
                              and cvar.COV_CAPTION not like 'MIG_OOS%' );

       L_COUNT_CUST := sql%rowcount;
       :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + L_COUNT_CUST;

       if   L_COUNT_CUST = 0
       then delete from snt.TCUSTOMERTYP 
             where ID_CUSTYP = L_ID_CUSTYP_MAX;
            ---
            L_ID_CUSTYP_MAX := L_ID_CUSTYP_MAX - 1;
            ---
       else dbms_output.put_line ( 'new customer type ' || to_char ( L_ID_CUSTYP_MAX ) || ' / ''MIG_OOS_' || substr ( crec.CUSTYP_CAPTION, 1, 42 )
                           || ''' created for ' || to_char ( L_COUNT_CUST ) || ' customer(s).' );

       end  if;

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