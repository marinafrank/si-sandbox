-- Set_dedicated_Contracts_In_Scope.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-12-16; FraBe; V1.1; MKS-136074:1; creation

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME        = Set_dedicated_Contracts_In_Scope
   define GL_LOGFILETYPE       = log        -- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   define GL_SCRIPTFILETYPE    = sql        -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN        = 2
   define L_MINOR_MIN        = 8
   define L_REVISION_MIN     = 0
   define L_BUILD_MIN        = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER            = SIMEX
   define L_SYSDBA_PRIV_NEEDED  = false        -- false or true

 -- country specification
   define L_MPC_CHECK           = false    -- false or true
   define L_MPC_SOLL            = 'MBCH'  -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = '57129'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb: 
                                           -- define L_MPC_SOLL       = 'MBBEL,MBCH'
                                           -- define L_VEGA_CODE_SOLL = '51331,57129'
 
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

variable L_SCRIPTNAME             varchar2 (200 char);
variable L_ERROR_OCCURED          number;
variable L_DATAERRORS_OCCURED     number;
variable L_DATAWARNINGS_OCCURED   number;
variable L_DATASUCCESS_OCCURED    number;
variable nachricht                varchar2 ( 200 char );

exec :L_SCRIPTNAME            := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED         :=0
exec :L_DATAERRORS_OCCURED    :=0
exec :L_DATAWARNINGS_OCCURED  :=0
exec :L_DATASUCCESS_OCCURED   :=0

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
   L_VEGA_CODE_IST         snt.TGLOBAL_SETTINGS.VALUE@simex_db_link%TYPE := snt.get_TGLOBAL_SETTINGS@simex_db_link ( 'SIRIUS', 'SIVECO',  'Country-CD', 'No VegaCode found' );
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
set feedback     on

declare
   L_COUNT_TCONTRACTS_IN_SCOPE   number := 0;
   L_ID_COV_MAX                  number := 0;
   
begin
    -- 1st: check ob in der tabelle simex.TCONTRACTS_IN_SCOPE verträge stehen
    -- wenn nicht: report DATAERROR und abbruch script
    -- wenn ja:    do In/OutScope CO conversion
    
    select count(*) 
      into L_COUNT_TCONTRACTS_IN_SCOPE
      from simex.TCONTRACTS_IN_SCOPE;
      
      
    if   L_COUNT_TCONTRACTS_IN_SCOPE = 0
    then dbms_output.put_line ( 'ERR : the In/OutScope contract conversion cannot be done as table TCONTRACTS_IN_SCOPE does not contain any contract' );
         :L_DATAERRORS_OCCURED  := :L_DATAERRORS_OCCURED  +1;
    else -- 2nd: anlegen OutScope vertragsVariante für alle InScope vertragsVariante wenn noch nicht angelegt
         select max ( ID_COV )
           into L_ID_COV_MAX
           from snt.TDFCONTR_VARIANT@SIMEX_DB_LINK;
      
         for crec in ( select ID_COV,                      COV_CAPTION,                COV_MEMO,                    COV_SCARF_CONTRACT,          COV_SCARF_REVENUE
                            , COV_NORMAL_GEWINN_MB,        COV_VORZ_GEWINN_MB,         COV_NORMAL_VERLUST_MB,       COV_VORZ_VERLUST_MB
                            , COV_NORMAL_GEWINN_GARAGE,    COV_VORZ_GEWINN_GARAGE,     COV_NORMAL_VERLUST_GARAGE,   COV_VORZ_VERLUST_GARAGE
                            , COV_NORMAL_GEWINN_CUSTOMER,  COV_VORZ_GEWINN_CUSTOMER,   COV_NORMAL_VERLUST_CUSTOMER, COV_VORZ_VERLUST_CUSTOMER
                            , COV_RUNPOWER_TOLERANCE_PERC, COV_RUNPOWER_TOLERANCE_DAY, COV_RUNPOWER_BALANCING,      COV_RUNPOWER_BALANCINGMETHOD
                            , GUID_FINANCIAL_SYSTEM,       COV_TRANSFER_TO_FINSYS,     COV_IC_IGNORE_MILEAGE,       COV_CLOSE_CHECK
                            , COV_USE_ADD_MILEAGE,         COV_USE_LESS_MILEAGE,       COV_USE_CONSV_PRIME,         COV_HANDLE_ADMINFEE
                            , COV_SERVICE_CARD,            GUID_SERVICECARD,           COV_STAT_CODE,               COV_FI_COSTING
                            , GUID_INDV,                   ID_PRV,                     COV_LEASING_SIVECO,          COV_PROFIT_VARIANT
                         from snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov1
                        where cov1.COV_CAPTION not like 'MIG_OOS%'                          -- do not convert a contract variant a 2nd time
                          and not exists ( select null from snt.TDFCONTR_VARIANT@SIMEX_DB_LINK cov2
                                            where cov2.COV_CAPTION   = 'MIG_OOS_' || substr ( cov1.COV_CAPTION, 1, 42 ))
                        order by 1 )
         loop
      
             L_ID_COV_MAX := L_ID_COV_MAX + 1;
      
             insert into snt.TDFCONTR_VARIANT@SIMEX_DB_LINK 
                    ( ID_COV
                    , COV_CAPTION
                    , COV_MEMO
                    , COV_SCARF_CONTRACT
                    , COV_SCARF_REVENUE
                    , COV_NORMAL_GEWINN_MB,        COV_VORZ_GEWINN_MB,         COV_NORMAL_VERLUST_MB,       COV_VORZ_VERLUST_MB
                    , COV_NORMAL_GEWINN_GARAGE,    COV_VORZ_GEWINN_GARAGE,     COV_NORMAL_VERLUST_GARAGE,   COV_VORZ_VERLUST_GARAGE
                    , COV_NORMAL_GEWINN_CUSTOMER,  COV_VORZ_GEWINN_CUSTOMER,   COV_NORMAL_VERLUST_CUSTOMER, COV_VORZ_VERLUST_CUSTOMER
                    , COV_RUNPOWER_TOLERANCE_PERC, COV_RUNPOWER_TOLERANCE_DAY, COV_RUNPOWER_BALANCING,      COV_RUNPOWER_BALANCINGMETHOD
                    , GUID_FINANCIAL_SYSTEM,       COV_TRANSFER_TO_FINSYS,     COV_IC_IGNORE_MILEAGE,       COV_CLOSE_CHECK
                    , COV_USE_ADD_MILEAGE,         COV_USE_LESS_MILEAGE,       COV_USE_CONSV_PRIME,         COV_HANDLE_ADMINFEE
                    , COV_SERVICE_CARD,            GUID_SERVICECARD,           COV_STAT_CODE,               COV_FI_COSTING
                    , GUID_INDV,                   ID_PRV,                     COV_LEASING_SIVECO,          COV_PROFIT_VARIANT )
             values ( L_ID_COV_MAX
                    , 'MIG_OOS_'                 || substr ( crec.COV_CAPTION, 1,   42 )
                    , 'MIGRATION_OUT_OF_SCOPE: ' || substr ( crec.COV_MEMO,    1, 1976 )
                    , 0                          --  -> 0 means: do not send to SCARF
                    , crec.COV_SCARF_REVENUE
                    , crec.COV_NORMAL_GEWINN_MB,        crec.COV_VORZ_GEWINN_MB,         crec.COV_NORMAL_VERLUST_MB,       crec.COV_VORZ_VERLUST_MB
                    , crec.COV_NORMAL_GEWINN_GARAGE,    crec.COV_VORZ_GEWINN_GARAGE,     crec.COV_NORMAL_VERLUST_GARAGE,   crec.COV_VORZ_VERLUST_GARAGE
                    , crec.COV_NORMAL_GEWINN_CUSTOMER,  crec.COV_VORZ_GEWINN_CUSTOMER,   crec.COV_NORMAL_VERLUST_CUSTOMER, crec.COV_VORZ_VERLUST_CUSTOMER
                    , crec.COV_RUNPOWER_TOLERANCE_PERC, crec.COV_RUNPOWER_TOLERANCE_DAY, crec.COV_RUNPOWER_BALANCING,      crec.COV_RUNPOWER_BALANCINGMETHOD
                    , crec.GUID_FINANCIAL_SYSTEM,       crec.COV_TRANSFER_TO_FINSYS,     crec.COV_IC_IGNORE_MILEAGE,       crec.COV_CLOSE_CHECK
                    , crec.COV_USE_ADD_MILEAGE,         crec.COV_USE_LESS_MILEAGE,       crec.COV_USE_CONSV_PRIME,         crec.COV_HANDLE_ADMINFEE
                    , crec.COV_SERVICE_CARD,            crec.GUID_SERVICECARD,           crec.COV_STAT_CODE,               crec.COV_FI_COSTING
                    , crec.GUID_INDV,                   crec.ID_PRV,                     crec.COV_LEASING_SIVECO,          crec.COV_PROFIT_VARIANT );
              dbms_output.put_line ( 'INFO: OutScope contract variant created: ' || rpad ( L_ID_COV_MAX, 3, ' ' ) || 'MIG_OOS_' || substr ( crec.COV_CAPTION, 1, 42 ));
      
         end loop;
      
         dbms_output.put_line ( chr(10) );
         
         -- 3rd: alle InScope CO, die nicht (- mehr -) in der in tabelle TCONTRACTS_IN_SCOPE stehen, werden auf OutScope geändert
         for crec in ( select fzgvc.ID_VERTRAG
                            , fzgvc.ID_FZGVERTRAG
                            , fzgvc.ROWID              as ROW_ID
                            , cov_InScope.ID_COV       as cov_InScope_ID_COV
                            , cov_OutScope.ID_COV      as cov_OutScope_ID_COV
                            , cov_InScope.COV_CAPTION  as cov_InScope_COV_CAPTION
                            , cov_OutScope.COV_CAPTION as cov_OutScope_COV_CAPTION
                         from snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                            , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_InScope
                            , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_OutScope
                        where cov_InScope.ID_COV                  = fzgvc.ID_COV
                          and cov_InScope.COV_CAPTION      not like 'MIG_OOS_%'
                          and cov_OutScope.COV_CAPTION            = 'MIG_OOS_' || substr ( cov_InScope.COV_CAPTION, 1, 42 )
                          and not exists ( select null from simex.TCONTRACTS_IN_SCOPE cis
                                            where fzgvc.ID_VERTRAG    = cis.ID_VERTRAG
                                              and fzgvc.ID_FZGVERTRAG = cis.ID_FZGVERTRAG )
                        order by 1, 2 )
         loop
         
             update snt.TFZGV_CONTRACTS@SIMEX_DB_LINK
                set ID_COV = crec.cov_OutScope_ID_COV
              where ROWID  = crec.ROW_ID;
              
             if   sql%rowcount = 0
             then dbms_output.put_line ( 'ERR : Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                      || 'not successfully changed to OutScope contract variant ' 
                                      || rpad ( crec.cov_OutScope_ID_COV, 3, ' ' ) || crec.cov_OutScope_COV_CAPTION );
                  :L_DATAERRORS_OCCURED  := :L_DATAERRORS_OCCURED  + sql%rowcount;
             else dbms_output.put_line ( 'INFO: Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                      || '    successfully changed to OutScope contract variant ' 
                                      || rpad ( crec.cov_OutScope_ID_COV, 3, ' ' ) || crec.cov_OutScope_COV_CAPTION );
                  :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + sql%rowcount;
             end  if;
             
         end loop;
      
         dbms_output.put_line ( chr(10) );
         
         -- 4th: ändern aller OutScope CO auf InScope, die in der tabelle TCONTRACTS_IN_SCOPE stehen
         -- mit ein paar einschränkungen -> dazu siehe a) bis c) unten beim code
         for crec in ( select cis.ID_VERTRAG
                            , cis.ID_FZGVERTRAG
                            , fzgvc.ROWID              as ROW_ID
                            , cov_InScope.ID_COV       as cov_InScope_ID_COV
                            , cov_OutScope.ID_COV      as cov_OutScope_ID_COV
                            , cov_InScope.COV_CAPTION  as cov_InScope_COV_CAPTION
                            , cov_OutScope.COV_CAPTION as cov_OutScope_COV_CAPTION
                         from simex.TCONTRACTS_IN_SCOPE           cis
                            , snt.TFZGV_CONTRACTS@SIMEX_DB_LINK   fzgvc
                            , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_InScope
                            , snt.TDFCONTR_VARIANT@SIMEX_DB_LINK  cov_OutScope
                        where cis.ID_VERTRAG                      = fzgvc.ID_VERTRAG    (+)
                          and cis.ID_FZGVERTRAG                   = fzgvc.ID_FZGVERTRAG (+)
                          and cov_OutScope.ID_COV       (+)       = fzgvc.ID_COV
                          and cov_OutScope.COV_CAPTION  (+)    like 'MIG_OOS_%'
                          and cov_InScope.COV_CAPTION   (+)       = substr ( cov_OutScope.COV_CAPTION, 9, 42 )
                        order by 1, 2 )
         loop
         
             if   crec.ROW_ID  is null                                        -- -> a) CO steht zwar in simex.TCONTRACTS_IN_SCOPE, aber nicht in snt.TFZGV_CONTRACTS@SIMEX_DB_LINK
             then dbms_output.put_line ( 'WARN: Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                      || 'cannot be changed to an InScope contract variant as not existing in SIRIUS!' );
                  :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + 1;
             else if   crec.cov_OutScope_COV_CAPTION like 'MIG_OOS_BYINT%'    -- -> b) MIG_OOS_BYINT CO werden nicht umgeschlüsselt
                  then dbms_output.put_line ( 'WARN: Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                            || 'has a MIG_OOS_BYINT contract variant which will not be changed to an InScope contract variant even if defined in table TCONTRACTS_IN_SCOPE' );
                       :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + 1;
                  else if   crec.cov_InScope_ID_COV is not null
                       then update snt.TFZGV_CONTRACTS@SIMEX_DB_LINK          -- -> c) normale CO umschlüsselung von OutScope auf InScope
                               set ID_COV = crec.cov_InScope_ID_COV
                             where ROWID  = crec.ROW_ID;
              
                            if   sql%rowcount = 0
                            then dbms_output.put_line ( 'ERR : Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                                     || 'not successfully changed to  InScope contract variant ' 
                                                     || rpad ( crec.cov_InScope_ID_COV, 3, ' ' ) || crec.cov_InScope_COV_CAPTION );
                                 :L_DATAERRORS_OCCURED  := :L_DATAERRORS_OCCURED  + sql%rowcount;
                            else dbms_output.put_line ( 'INFO: Contract ' || rpad ( crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG, 13, ' ' ) 
                                                     || '    successfully changed to  InScope contract variant ' 
                                                     || rpad ( crec.cov_InScope_ID_COV, 3, ' ' ) || crec.cov_InScope_COV_CAPTION );
                                 :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + sql%rowcount;
                            end  if;
                       end  if;
                  end  if;
             end  if;
         end loop;

    end  if;
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
