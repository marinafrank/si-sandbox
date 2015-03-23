-- DataCleansing_LOP2146_DEF8914-CleanCustomerDuplicates4
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2015-03-12; MARZUHL; V1.0; MKS-151940:1; Initial Release

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME         = DataCleansing_LOP2146_DEF8914-CleanCustomerDuplicates4
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

upd_cu(I_ID_CUSTOMER_OLD=>'00000939002', I_ID_CUSTOMER_NEW=>'00000939001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001381001', I_ID_CUSTOMER_NEW=>'00026029001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001652001', I_ID_CUSTOMER_NEW=>'00001048001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001666002', I_ID_CUSTOMER_NEW=>'00001666001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001749001', I_ID_CUSTOMER_NEW=>'00003644001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002428001', I_ID_CUSTOMER_NEW=>'00001928001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002643001', I_ID_CUSTOMER_NEW=>'00014570001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003024001', I_ID_CUSTOMER_NEW=>'00003745001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003652002', I_ID_CUSTOMER_NEW=>'00000933002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004690001', I_ID_CUSTOMER_NEW=>'00016738001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011562002', I_ID_CUSTOMER_NEW=>'00011562001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012075001', I_ID_CUSTOMER_NEW=>'Q0000006035');
upd_cu(I_ID_CUSTOMER_OLD=>'00017635001', I_ID_CUSTOMER_NEW=>'00017365001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018391001', I_ID_CUSTOMER_NEW=>'00001048001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018413001', I_ID_CUSTOMER_NEW=>'00012898001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019190001', I_ID_CUSTOMER_NEW=>'00011358001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019235001', I_ID_CUSTOMER_NEW=>'00011398001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022154001', I_ID_CUSTOMER_NEW=>'00013941001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022902001', I_ID_CUSTOMER_NEW=>'Q0000011975');
upd_cu(I_ID_CUSTOMER_OLD=>'00031902001', I_ID_CUSTOMER_NEW=>'00015446001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034870001', I_ID_CUSTOMER_NEW=>'00000034870');
upd_cu(I_ID_CUSTOMER_OLD=>'00035687001', I_ID_CUSTOMER_NEW=>'00029955001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035881001', I_ID_CUSTOMER_NEW=>'00023808001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036954001', I_ID_CUSTOMER_NEW=>'00030160001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000555', I_ID_CUSTOMER_NEW=>'00025368001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002087', I_ID_CUSTOMER_NEW=>'Q0000012863');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000009262', I_ID_CUSTOMER_NEW=>'00000000013');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010072', I_ID_CUSTOMER_NEW=>'00027729001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010346', I_ID_CUSTOMER_NEW=>'Q0000003223');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010556', I_ID_CUSTOMER_NEW=>'00009123001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010779', I_ID_CUSTOMER_NEW=>'00001340001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000015465', I_ID_CUSTOMER_NEW=>'Q0000016444');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016601', I_ID_CUSTOMER_NEW=>'Q0000016602');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016935', I_ID_CUSTOMER_NEW=>'00030538001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016949', I_ID_CUSTOMER_NEW=>'Q0000007914');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017051', I_ID_CUSTOMER_NEW=>'Q0000002451');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017058', I_ID_CUSTOMER_NEW=>'Q0000003551');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017162', I_ID_CUSTOMER_NEW=>'Q0000017230');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017175', I_ID_CUSTOMER_NEW=>'00034036001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017431', I_ID_CUSTOMER_NEW=>'00036660001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000016993', I_ID_CUSTOMER_NEW=>'Q0000012235');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017435', I_ID_CUSTOMER_NEW=>'00026653001');
upd_cu(I_ID_CUSTOMER_OLD=>'00039409001', I_ID_CUSTOMER_NEW=>'00016542001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000017837', I_ID_CUSTOMER_NEW=>'00029724001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036860001', I_ID_CUSTOMER_NEW=>'00031909001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000012274', I_ID_CUSTOMER_NEW=>'00017717001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015522001', I_ID_CUSTOMER_NEW=>'00035234001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001630', I_ID_CUSTOMER_NEW=>'Q0000016050');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004805', I_ID_CUSTOMER_NEW=>'00039305001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028155001', I_ID_CUSTOMER_NEW=>'00027275001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001200002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00036017001', I_ID_CUSTOMER_NEW=>'Q0000017415');
upd_cu(I_ID_CUSTOMER_OLD=>'00036862001', I_ID_CUSTOMER_NEW=>'00019241001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030756001', I_ID_CUSTOMER_NEW=>'00023076001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028514001', I_ID_CUSTOMER_NEW=>'00001533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003043001', I_ID_CUSTOMER_NEW=>'00001533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015532001', I_ID_CUSTOMER_NEW=>'00035235001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030479001', I_ID_CUSTOMER_NEW=>'00026353001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009481001', I_ID_CUSTOMER_NEW=>'00036268001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022583001', I_ID_CUSTOMER_NEW=>'00014595001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001599001', I_ID_CUSTOMER_NEW=>'00036205001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028361001', I_ID_CUSTOMER_NEW=>'00036205001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022612001', I_ID_CUSTOMER_NEW=>'Q0000000416');
upd_cu(I_ID_CUSTOMER_OLD=>'00027761001', I_ID_CUSTOMER_NEW=>'00036434001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000010562', I_ID_CUSTOMER_NEW=>'00013303001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033875001', I_ID_CUSTOMER_NEW=>'00026607001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034529001', I_ID_CUSTOMER_NEW=>'Q0000002183');
upd_cu(I_ID_CUSTOMER_OLD=>'00026698001', I_ID_CUSTOMER_NEW=>'00028150001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024136001', I_ID_CUSTOMER_NEW=>'00011860001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025061001', I_ID_CUSTOMER_NEW=>'00028143001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026485001', I_ID_CUSTOMER_NEW=>'00033252001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029919001', I_ID_CUSTOMER_NEW=>'00037519001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008007001', I_ID_CUSTOMER_NEW=>'00037285001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023787001', I_ID_CUSTOMER_NEW=>'00021458001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019038001', I_ID_CUSTOMER_NEW=>'00021458001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015588001', I_ID_CUSTOMER_NEW=>'00034685001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015544001', I_ID_CUSTOMER_NEW=>'00034684001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036058001', I_ID_CUSTOMER_NEW=>'00035807001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036145001', I_ID_CUSTOMER_NEW=>'00036496001');

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
