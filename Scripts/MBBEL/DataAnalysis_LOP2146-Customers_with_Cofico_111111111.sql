-- DataAnalysis_LOP2146-Customers_with_Cofico_111111111.sql
-- FraBe     13.11.2013 MKS-129328:1 / LOP2146: creation
-- FraBe     22.11.2013 MKS-129328:2 / LOP2146: change ID_PARTNERTYP not like 'MIG_OOS%' to PARTNERTYP_CAPTION ...
-- FraBe     25.11.2013 MKS-129328:2 / LOP2146: add col SV/POS - CO-type

spool DataAnalysis_LOP2146-Customers_with_Cofico_111111111.log

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
exec :L_SCRIPTNAME       := 'DataAnalysis_LOP2146-Customers_with_Cofico_111111111.sql';

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
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

col ID_VERTRAG                form a10
col ID_FZGVERTRAG             form a13
col ID_COV                    form 99990
col COV_CAPTION               form a50
col ID_CUSTOMER               form a11
col PARTNERTYP_CAPTION        form a50  head "CUSTOMERTYP_CAPTION"
col ZIP_ZIP                   form a7
col ZIP_CITY                  form a35
col CUST_SAP_NUMBER_DEBITOR   form a25
col CUST_SAP_NUMBER_CREDITOR  form a25
col ID_CUSTOMER_alt           form a26  head "ID_CUSTOMER altInvReceiver"
col PARTNERTYP_CAPTION_alt    form a50  head "CUSTOMERTYP_CAPTION altInvReceiver"

select cust.ID_CUSTOMER
     , vpc.PARTNERTYP_CAPTION
     , vpc.NAME_MATCHCODE
     , vpc.ADR_STREET1
     , vpc.ZIP_ZIP
     , vpc.ZIP_CITY
     , cust.CUST_SAP_NUMBER_DEBITOR
     , cust.CUST_SAP_NUMBER_CREDITOR
     , fzgvc.ID_VERTRAG
     , fzgvc.ID_FZGVERTRAG
     , cov.ID_COV
     , cov.COV_CAPTION
     , decode ( cust.ID_CUSTOMER, cust.CUST_INVOICE_ADRESS, null, cust.CUST_INVOICE_ADRESS ) as ID_CUSTOMER_alt
     , decode ( cust.ID_CUSTOMER, cust.CUST_INVOICE_ADRESS, null, vpa.PARTNERTYP_CAPTION )    as PARTNERTYP_CAPTION_alt
  from snt.TDFCONTR_VARIANT cov
     , snt.TFZGV_CONTRACTS  fzgvc
     , snt.VPARTNER         vpc
     , snt.TCUSTOMER        cust
     , snt.VPARTNER         vpa
 where ( cust.CUST_SAP_NUMBER_DEBITOR  like '%111111%' 
      or cust.CUST_SAP_NUMBER_CREDITOR like '%111111%' )
   and fzgvc.ID_COV             = cov.ID_COV  (+)
   and fzgvc.ID_CUSTOMER (+)    = cust.ID_CUSTOMER
   and vpc.ID_PARTNER           = cust.ID_CUSTOMER
   and vpc.PARTNERTYP           = 'D'
   and vpc.PARTNERTYP_CAPTION not like 'MIG_OOS%'
   and vpa.ID_PARTNER           = cust.CUST_INVOICE_ADRESS
   and vpa.PARTNERTYP           = 'D'
order by 1, 9, 10, 11;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataAnalysis_LOP2146-Customers_with_Cofico_111111111.log
prompt

exit;
