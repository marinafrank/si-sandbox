-- DataCleansing_LOP2146_DEF7571-CleanCustomerDuplicates3
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2015-01-22; MARZUHL; V1.0; MKS-136431:1; Initial Release
-- 2015-01-22; MARZUHL; V1.1; MKS-136431:1; Typo fixed.

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME         = DataCleansing_LOP2146_DEF7571-CleanCustomerDuplicates3
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
   define L_MPC_CHECK           = true     -- false or true
   define L_MPC_SOLL            = 'MBBEL'  -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = '51331'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb: 
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

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName',    'NoMPCName found'   );
   L_VEGA_CODE_IST         snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'SIVECO',  'Country-CD', 'No VegaCode found' );
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

   procedure upd_cu(i_id_customer_old  snt.tcustomer.id_customer%type,
                    i_id_customer_new  snt.tcustomer.id_customer%type) is
                    
      L_COUNT_CUSTDOM_UPD    integer := 0;
      L_COUNT_CUSTDOM_DEL    integer := 0;
      L_COUNT_CUSTDOM_CO_UPD integer := 0;
      L_COUNT_CUSTDOM_CI_UPD integer := 0;
      L_ERROR                boolean := false;
      L_CUSTOMERCOUNT        integer := 0;

   begin

       DBMS_OUTPUT.PUT_LINE ( chr(10) || '------------------------------------------------------------------------------------------------------------------------------');
       DBMS_OUTPUT.PUT_LINE('convert          old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ': ' );
       DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------');
       begin
           select NVL(count(ID_CUSTOMER),0) into L_CUSTOMERCOUNT from tcustomer where ID_CUSTOMER = i_id_customer_old;
           if L_CUSTOMERCOUNT > 0 then

      -------------------------------------
      -- snt.TTEMP_I55_OR_SCARF_DATA
      -------------------------------------
      -- wenn row mit neuem cust existiert schon -> alter cust wird gelöscht
      -- sonst: upd
      begin
          delete from snt.TTEMP_I55_OR_SCARF_DATA t
           where ID_CUSTOMER         = i_id_customer_old
             and RECORD_TYPE         = '20'
             and exists ( select null 
                            from snt.TTEMP_I55_OR_SCARF_DATA t1
                           where       t1.ID_CUSTOMER          =       i_id_customer_new
                             and       t1.GUID_JO              =       t.GUID_JO
                             and       t1.RECORD_TYPE          =       t.RECORD_TYPE );
--                           and nvl ( t1.SEQ_NUMBER,    -1 )  = nvl ( t.SEQ_NUMBER,    -1 )
--                           and nvl ( t1.GUID_CONTRACT, ' ' ) = nvl ( t.GUID_CONTRACT, ' ' )); 
                             
      if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || '                                            - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) deleted');
          end if;
      exception when OTHERS then
         L_ERROR := true;
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;

      -------------------------------------
      
      begin
          UPDATE snt.TTEMP_I55_OR_SCARF_DATA
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
         L_ERROR := true;          
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      --tcustomer_invoice
      -------------------------------------
      begin
          UPDATE snt.tcustomer_invoice
             SET guid_partner =
                    (SELECT guid_partner
                       FROM snt.tpartner
                      WHERE id_customer = i_id_customer_new)
           WHERE guid_partner = (SELECT guid_partner
                                   FROM snt.tpartner
                                  WHERE id_customer = i_id_customer_old);
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_invoice: old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer_invoice: old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
         L_ERROR := true;          
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.tfzgv_contracts
      -------------------------------------
      begin
          UPDATE snt.tfzgv_contracts
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('fzgv_contracts  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('fzgv_contracts  : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
         L_ERROR := true;          
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.TVERTRAGSTAMM
      -------------------------------------
      begin
          UPDATE snt.TVERTRAGSTAMM
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
         L_ERROR := true;          
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;

      -------------------------------------

      begin
          UPDATE snt.TVERTRAGSTAMM
             SET ID_CUSTOMER2        = i_id_customer_new
           WHERE ID_CUSTOMER2        = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER2: ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER2: ' || i_id_customer_old || ' to new           ID_CUSTOMER2: ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
         L_ERROR := true;          
         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
         dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.TCUSTOMER_DOM
      -------------------------------------
      -- wenn der upd wegen DUP_VAL_ON_INDEX fehlschlägt, existiert die neue domiciliation schon
      -- -> dann werden stattdessen alle CO mit der alten domiciliation auf die neue umgestellt, und dann die alte gelöscht:
      L_COUNT_CUSTDOM_UPD    := 0;
      L_COUNT_CUSTDOM_CO_UPD := 0;
      L_COUNT_CUSTDOM_CI_UPD := 0;
      L_COUNT_CUSTDOM_DEL    := 0;
      
      for crec in ( select GUID_CUSTOMER_DOM, CUSTDOM_DOMNUMBER
                      from snt.TCUSTOMER_DOM
                     where ID_CUSTOMER  = i_id_customer_old )
      loop
           begin
              UPDATE snt.TCUSTOMER_DOM
                 SET ID_CUSTOMER         = i_id_customer_new
               WHERE GUID_CUSTOMER_DOM   = crec.GUID_CUSTOMER_DOM;
              
              L_COUNT_CUSTDOM_UPD := L_COUNT_CUSTDOM_UPD +  sql%rowcount;
              
           exception when DUP_VAL_ON_INDEX -- wenns die neue ID_CUSTOMER schon gibt: a) CO und CI umstellen auf neue custdom b) lö alte
                     then begin 
                              update snt.TFZGV_CONTRACTS co
                                 set co.GUID_CUSTOMER_DOM  = ( select numNEU.GUID_CUSTOMER_DOM 
                                                                 from snt.TCUSTOMER_DOM numNEU
                                                                where numNEU.ID_CUSTOMER       = i_id_customer_new
                                                                  and numNEU.CUSTDOM_DOMNUMBER = crec.CUSTDOM_DOMNUMBER )
                               where co.GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;
     
                              L_COUNT_CUSTDOM_CO_UPD := L_COUNT_CUSTDOM_CO_UPD +  sql%rowcount;
                                
                          exception when OTHERS then
                             L_ERROR := true;          
                             :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                             dbms_output.put_line ( sqlerrm );
                          end;
                          
                          begin 
                              update snt.TCUSTOMER_INVOICE ci
                                 set ci.GUID_CUSTOMER_DOM  = ( select numNEU.GUID_CUSTOMER_DOM 
                                                                 from snt.TCUSTOMER_DOM numNEU
                                                                where numNEU.ID_CUSTOMER       = i_id_customer_new
                                                                  and numNEU.CUSTDOM_DOMNUMBER = crec.CUSTDOM_DOMNUMBER )
                               where ci.GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;
     
                              L_COUNT_CUSTDOM_CI_UPD := L_COUNT_CUSTDOM_CI_UPD +  sql%rowcount;
                              
                          exception when OTHERS then
                             L_ERROR := true;          
                             :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                             dbms_output.put_line ( sqlerrm );
                          end;
                          
                          begin
                                delete from snt.TCUSTOMER_DOM 
                                 where GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;

                                L_COUNT_CUSTDOM_DEL := L_COUNT_CUSTDOM_DEL + 1;
                                
                          exception when OTHERS then
                             L_ERROR := true;          
                             :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                             dbms_output.put_line ( sqlerrm );
                          end;
                     when OTHERS then
                         L_ERROR := true;          
                         :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                         dbms_output.put_line ( sqlerrm );
                     end;
      end loop;
        
      
      if   L_COUNT_CUSTDOM_CO_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom/CO : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom/CO : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_CO_UPD, '9990' ) || ' record(s) updated');
      end  if;
          
      if   L_COUNT_CUSTDOM_CI_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom/CI : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom/CI : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_CI_UPD, '9990' ) || ' record(s) updated');
      end  if;

      if   L_COUNT_CUSTDOM_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_UPD, '9990' ) || ' record(s) updated');
      end  if;

      if   L_COUNT_CUSTDOM_DEL = 0 then null;
      else DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || '                                            - ' || to_char (L_COUNT_CUSTDOM_DEL, '9990' ) || ' record(s) deleted');
      end  if;
      
      -------------------------------------
      --tcustomer: alternate inv address
      -------------------------------------
      begin
          UPDATE snt.TCUSTOMER
             SET CUST_INVOICE_ADRESS = i_id_customer_new
           WHERE CUST_INVOICE_ADRESS = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old alternate ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer        : old alternate ID_CUSTOMER : ' || i_id_customer_old || ' to new alternate ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
          L_ERROR := true;          
          :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
          dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      --tcustomer: alternate balfin address
      -------------------------------------
      begin
          UPDATE snt.tcustomer
             SET CUST_INV_ADRESS_BALFIN = i_id_customer_new
           WHERE CUST_INV_ADRESS_BALFIN = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old balfin    ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer        : old balfin    ID_CUSTOMER : ' || i_id_customer_old || ' to new balfin    ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS then
          L_ERROR := true;          
          :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
          dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- tcustomer: del old customer
      -- hier wird kein upd gemacht, sondern nur der alte cust gelöscht
      ------------------------------------
      begin
          delete from snt.TCUSTOMER 
           where ID_CUSTOMER = i_id_customer_old;

          if   sql%rowcount = 0 
          then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else DBMS_OUTPUT.PUT_LINE('customer        : old           ID_CUSTOMER : ' || i_id_customer_old || '                                                  1 record(s) deleted');
          end if;
      exception when OTHERS then
          L_ERROR := true;          
          :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
          dbms_output.put_line ( sqlerrm );
      end;

      if L_ERROR = false then
          :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + 1;
      end if;

           else
               DBMS_OUTPUT.PUT_LINE('ERR : Customer not found! Doing nothing for this one. (Continuing with other customers...)');
               :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
           end if;
       exception
           when others then
               :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
               dbms_output.put_line ( sqlerrm );
       end;

   end;

begin

upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010730', I_ID_CUSTOMER_NEW=>'00014699001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013252', I_ID_CUSTOMER_NEW=>'00020321001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012888', I_ID_CUSTOMER_NEW=>'00020675001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013467', I_ID_CUSTOMER_NEW=>'00022675001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014699', I_ID_CUSTOMER_NEW=>'00023343001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037460001', I_ID_CUSTOMER_NEW=>'00023434001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015417', I_ID_CUSTOMER_NEW=>'00026298001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013578', I_ID_CUSTOMER_NEW=>'00036328001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002488', I_ID_CUSTOMER_NEW=>'00038345001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013200', I_ID_CUSTOMER_NEW=>'00036994001');
upd_cu(I_ID_CUSTOMER_OLD=>'00038955001', I_ID_CUSTOMER_NEW=>'00016059001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012371', I_ID_CUSTOMER_NEW=>'00021247001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015177', I_ID_CUSTOMER_NEW=>'00025129001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017248001', I_ID_CUSTOMER_NEW=>'00025845001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012895', I_ID_CUSTOMER_NEW=>'00027275001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013984', I_ID_CUSTOMER_NEW=>'00028963001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015043', I_ID_CUSTOMER_NEW=>'00029982001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014008', I_ID_CUSTOMER_NEW=>'00035664001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013809', I_ID_CUSTOMER_NEW=>'00036280001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014057', I_ID_CUSTOMER_NEW=>'Q0000001539');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012927', I_ID_CUSTOMER_NEW=>'Q0000002636');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014534', I_ID_CUSTOMER_NEW=>'Q0000009832');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010708', I_ID_CUSTOMER_NEW=>'Q0000010707');
upd_cu(I_ID_CUSTOMER_OLD=>'00013358001', I_ID_CUSTOMER_NEW=>'Q0000012904');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013779', I_ID_CUSTOMER_NEW=>'Q0000013559');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013740', I_ID_CUSTOMER_NEW=>'Q0000013739');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014262', I_ID_CUSTOMER_NEW=>'Q0000014246');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014373', I_ID_CUSTOMER_NEW=>'Q0000015445');
upd_cu(I_ID_CUSTOMER_OLD=>'00032494001', I_ID_CUSTOMER_NEW=>'Q0000015515');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016081', I_ID_CUSTOMER_NEW=>'Q0000016132');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012866', I_ID_CUSTOMER_NEW=>'00022274001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000029', I_ID_CUSTOMER_NEW=>'00021157001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001453', I_ID_CUSTOMER_NEW=>'Q0000000230');
upd_cu(I_ID_CUSTOMER_OLD=>'00000038725', I_ID_CUSTOMER_NEW=>'00038725001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002831001', I_ID_CUSTOMER_NEW=>'00015555001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001761016', I_ID_CUSTOMER_NEW=>'00015555001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011677001', I_ID_CUSTOMER_NEW=>'00000734001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019972001', I_ID_CUSTOMER_NEW=>'00035956001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023390001', I_ID_CUSTOMER_NEW=>'00016102001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035662001', I_ID_CUSTOMER_NEW=>'Q0000000563');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016062', I_ID_CUSTOMER_NEW=>'Q0000016021');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016034', I_ID_CUSTOMER_NEW=>'00023517001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015196', I_ID_CUSTOMER_NEW=>'00011558001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015474', I_ID_CUSTOMER_NEW=>'Q0000006039');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015610', I_ID_CUSTOMER_NEW=>'00018110001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022817001', I_ID_CUSTOMER_NEW=>'00013249001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000862', I_ID_CUSTOMER_NEW=>'Q0000000861');
upd_cu(I_ID_CUSTOMER_OLD=>'00029970001', I_ID_CUSTOMER_NEW=>'00016290001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014230', I_ID_CUSTOMER_NEW=>'00018975001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014442', I_ID_CUSTOMER_NEW=>'00026556001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003798002', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012680002', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002081002', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001879002', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012219002', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003707002', I_ID_CUSTOMER_NEW=>'00015549001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037856001', I_ID_CUSTOMER_NEW=>'00015549001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001280001', I_ID_CUSTOMER_NEW=>'00015549001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001570', I_ID_CUSTOMER_NEW=>'00038302001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000003306', I_ID_CUSTOMER_NEW=>'Q0000012867');
upd_cu(I_ID_CUSTOMER_OLD=>'00011649001', I_ID_CUSTOMER_NEW=>'Q0000005377');
upd_cu(I_ID_CUSTOMER_OLD=>'00024164001', I_ID_CUSTOMER_NEW=>'Q0000005479');
upd_cu(I_ID_CUSTOMER_OLD=>'00024204001', I_ID_CUSTOMER_NEW=>'Q0000005722');
upd_cu(I_ID_CUSTOMER_OLD=>'00033864001', I_ID_CUSTOMER_NEW=>'Q0000005942');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000006110', I_ID_CUSTOMER_NEW=>'00011218001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030170001', I_ID_CUSTOMER_NEW=>'Q0000006115');
upd_cu(I_ID_CUSTOMER_OLD=>'00030662001', I_ID_CUSTOMER_NEW=>'Q0000006542');
upd_cu(I_ID_CUSTOMER_OLD=>'00024440001', I_ID_CUSTOMER_NEW=>'Q0000007488');
upd_cu(I_ID_CUSTOMER_OLD=>'00015961001', I_ID_CUSTOMER_NEW=>'Q0000009633');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000195', I_ID_CUSTOMER_NEW=>'00036356001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000244', I_ID_CUSTOMER_NEW=>'00036356001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000008775', I_ID_CUSTOMER_NEW=>'00036356001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026307001', I_ID_CUSTOMER_NEW=>'Q0000008585');
upd_cu(I_ID_CUSTOMER_OLD=>'00027322001', I_ID_CUSTOMER_NEW=>'Q0000007859');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000013347', I_ID_CUSTOMER_NEW=>'00039213001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002435', I_ID_CUSTOMER_NEW=>'Q0000014178');
upd_cu(I_ID_CUSTOMER_OLD=>'00030185001', I_ID_CUSTOMER_NEW=>'Q0000009578');
upd_cu(I_ID_CUSTOMER_OLD=>'00032810001', I_ID_CUSTOMER_NEW=>'Q0000008875');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000008538', I_ID_CUSTOMER_NEW=>'00027207001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026773001', I_ID_CUSTOMER_NEW=>'Q0000008425');
upd_cu(I_ID_CUSTOMER_OLD=>'00024181001', I_ID_CUSTOMER_NEW=>'Q0000007695');
upd_cu(I_ID_CUSTOMER_OLD=>'00011084001', I_ID_CUSTOMER_NEW=>'00018849001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011610001', I_ID_CUSTOMER_NEW=>'00019533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024581001', I_ID_CUSTOMER_NEW=>'Q0000013570');
upd_cu(I_ID_CUSTOMER_OLD=>'00013479001', I_ID_CUSTOMER_NEW=>'Q0000013016');
upd_cu(I_ID_CUSTOMER_OLD=>'00002822001', I_ID_CUSTOMER_NEW=>'00014183001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002115001', I_ID_CUSTOMER_NEW=>'Q0000006752');
upd_cu(I_ID_CUSTOMER_OLD=>'00002661001', I_ID_CUSTOMER_NEW=>'00004636001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002041001', I_ID_CUSTOMER_NEW=>'00007910001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003453001', I_ID_CUSTOMER_NEW=>'Q0000001407');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000038', I_ID_CUSTOMER_NEW=>'Q0000000054');
upd_cu(I_ID_CUSTOMER_OLD=>'00003487001', I_ID_CUSTOMER_NEW=>'00004147001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003662001', I_ID_CUSTOMER_NEW=>'00035590001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002649001', I_ID_CUSTOMER_NEW=>'00007629001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004249001', I_ID_CUSTOMER_NEW=>'00017707001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000444001', I_ID_CUSTOMER_NEW=>'00029056001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000444002', I_ID_CUSTOMER_NEW=>'00029056001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001440001', I_ID_CUSTOMER_NEW=>'00012558001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005414001', I_ID_CUSTOMER_NEW=>'00005251001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003771001', I_ID_CUSTOMER_NEW=>'00004422001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001105001', I_ID_CUSTOMER_NEW=>'00020756001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001513001', I_ID_CUSTOMER_NEW=>'00005884001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016159', I_ID_CUSTOMER_NEW=>'00014931001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015945', I_ID_CUSTOMER_NEW=>'Q0000016014');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014984', I_ID_CUSTOMER_NEW=>'00036213001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016388', I_ID_CUSTOMER_NEW=>'00027014001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000014697', I_ID_CUSTOMER_NEW=>'00032302001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016447', I_ID_CUSTOMER_NEW=>'Q0000016446');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016020', I_ID_CUSTOMER_NEW=>'Q0000016019');
upd_cu(I_ID_CUSTOMER_OLD=>'00025819001', I_ID_CUSTOMER_NEW=>'Q0000007083');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001969', I_ID_CUSTOMER_NEW=>'Q0000005730');
upd_cu(I_ID_CUSTOMER_OLD=>'00016166001', I_ID_CUSTOMER_NEW=>'Q0000008092');
upd_cu(I_ID_CUSTOMER_OLD=>'00000500001', I_ID_CUSTOMER_NEW=>'00000500002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004293001', I_ID_CUSTOMER_NEW=>'00004523001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001769001', I_ID_CUSTOMER_NEW=>'00005366001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015808001', I_ID_CUSTOMER_NEW=>'Q0000012985');
upd_cu(I_ID_CUSTOMER_OLD=>'00031883001', I_ID_CUSTOMER_NEW=>'Q0000013000');
upd_cu(I_ID_CUSTOMER_OLD=>'00034017001', I_ID_CUSTOMER_NEW=>'Q0000006047');
upd_cu(I_ID_CUSTOMER_OLD=>'00035025001', I_ID_CUSTOMER_NEW=>'Q0000012938');
upd_cu(I_ID_CUSTOMER_OLD=>'00007406001', I_ID_CUSTOMER_NEW=>'00037850001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004561', I_ID_CUSTOMER_NEW=>'00037853001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000011047', I_ID_CUSTOMER_NEW=>'00038709001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000007846', I_ID_CUSTOMER_NEW=>'00039005001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034046001', I_ID_CUSTOMER_NEW=>'Q0000009664');
upd_cu(I_ID_CUSTOMER_OLD=>'00010007002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001156001', I_ID_CUSTOMER_NEW=>'00015570001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037870001', I_ID_CUSTOMER_NEW=>'Q0000010376');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633002', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633003', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633004', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633006', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633007', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001346001', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633001', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000633005', I_ID_CUSTOMER_NEW=>'00010838002');
upd_cu(I_ID_CUSTOMER_OLD=>'00018536001', I_ID_CUSTOMER_NEW=>'00010838001');

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
