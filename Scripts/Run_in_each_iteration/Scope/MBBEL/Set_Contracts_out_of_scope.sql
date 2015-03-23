-- 20131219_Set-Contracts-out-of-scope_V6.0.sql
-- FraBe            15.11.2012 MKS-119330: creation
-- FraBe            22.11.2012 MKS-120182:1 add COS_ACTIVE = 0 condition
-- FraBe            10.12.2012 MKS-120182:3 use s.COS_STAT_CODE not in ( '00', '01', '02' ) instead of s.COS_ACTIVE = 0
-- TK               10.12.2012 MKS-120182:4 Spool Filename adapted
-- FraBe            10.12.2012 MKS-120182:5 use the new name everywhere
-- FraBe            11.03.2013 MKS-122243:1 change filename from 20121210_Set-Contracts-out-of-scope_V2 to 20130312_Set-Contracts-out-of-scope_V3
--                                          plus add code that cancelled contracts (-> StatisticCode = 10 ) are always OutOfScope
-- FraBe            24.07.2013 MKS-126518:1 add check SP-Supplier-Sammelrechnung
-- FraBe            05.09.2013 MKS-128141:1 IMOs ( Industriemotoren (-> ID fahrzeugart = 20 )) sind immer OutOfScope
-- FraBe            19.12.2013 MKS-130160:1 / LOP2833: change filename from 20130905_Set-Contracts-out-of-scope_V5.0 to 20131219_Set-Contracts-out-of-scope_V6.0.sql
--                                          plus Busse (-> Businessarealevel2: 'Buses' ) sind immer OutOfScope
-- MARZUHL	        19.02.2015 MKS-151839:1 Implementierung "Explizit-out-of-scope-Parameter" plus Einbau in OOS-Logik
-- Marinf	          04.03.2015 MKS-151912:1 Implemented variable scoping: currently A, B and 0. Implemented explicit IN- and OUT-of-scope lists.

-- This script ACCEPTS the following positional parameters in the given order:
-- Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Input Parameter 2 a date in Format "DD.MM.YYYY" to automate the script Mode.
-- Input Parameter 3 Scope: A (default) - see \\MKS\ICON\3000_Requirements_Engineering\3200_Customer_Requirements_Definition\Scope\MBBEL\Scope iCON Migration MBBEL 2.26.docx
--                          B - Same as A, but excludes check for membership in Supplier Invoice
--                          0 - Set ALL contracts out of scope. Usecase: "Nachlieferung" (in conjunction with Parameter 5)
-- Input Parameter 4 SNT password to propagate into dependent scripts
-- Input Parameter 5 Apply explicit INSCOPE      list: 'Y' or 'N' (default)
-- Input Parameter 6 Apply explicit OUT-OF-SCOPE list: 'Y' or 'N' (default) 
-- Please keep in mind if you are accepting more input parameters!

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= Set_Contracts_out_of_scope
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
              if L_LAST_EXEC_TIME is not null then
                dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME);
              end if;
    
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
                  then dbms_output.put_line ( 'Executing user is not &L_SOLLUSER / SYSDBA!'
                              || chr(10) || 'For a correct use of this script, executing user must be &L_SOLLUSER  / SYSDBA' || chr(10) );
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


PROMPT "Do you want to save the changes to the DB? [Y/N] (Default N):"

SET TERMOUT OFF
Define commit_or_rollback = &1 N;
SET TERMOUT ON

prompt SELECTION CHOSEN: &commit_or_rollback;

PROMPT All inactive Contracts which ended earlier than this date will be set to OutOfScope DD.MM.YYYY:

SET TERMOUT OFF
Define Out_Of_Scope_Date = &2 01.01.2011;
SET TERMOUT ON

prompt SELECTION CHOSEN: &Out_Of_Scope_Date 

prompt
PROMPT What scope will be applied? Defaulting to "A":

SET TERMOUT OFF
Define Scope = &3 A;
SET TERMOUT ON

prompt SELECTION CHOSEN: &Scope


prompt
prompt SNT password:

SET TERMOUT OFF
Define pwd = &4
SET TERMOUT ON

prompt
prompt Apply explicit IN-SCOPE List? Defaulting to N:
SET TERMOUT OFF
Define APPLY_INSCOPE = &5 N;
SET TERMOUT ON
prompt SELECTION CHOSEN: &APPLY_INSCOPE

prompt
prompt Apply explicit OUT-OF-SCOPE List? Defaulting to N:
SET TERMOUT OFF
Define APPLY_OOSCOPE = &6 N;
SET TERMOUT ON
prompt SELECTION CHOSEN: &APPLY_OOSCOPE

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
-- SQL*Plus has no conditional operators, therefore we will create and load explicit list tables regardless of APPLY_*SCOPE settings.
-- Actual conditioning will happen in the main PL/SQL-block.
CREATE TABLE out_of_scope_contracts
(ID_VERTRAG    varchar2(30) not null
,ID_FZGVERTRAG varchar2(30) default '*' not null
)
/
CREATE TABLE in_scope_contracts
(ID_VERTRAG    varchar2(30) not null
,ID_FZGVERTRAG varchar2(30) default '*' not null
)
/

prompt
prompt Loading Additional_OutOfScope.csv...
host sqlldr silent=(HEADER,FEEDBACK) userid=snt/&&pwd@&&_connect_identifier control=exclude_list.ctl data=Additional_OutOfScope.csv

prompt
prompt Loading Additional_InScope.csv...
host sqlldr silent=(HEADER,FEEDBACK) userid=snt/&&pwd@&&_connect_identifier control=include_list.ctl data=Additional_InScope.csv

declare
	L_ID_COV_MAX     number := 0;
  l_id_cov_oos     number := 0;
  l_id_cov_ins     number := 0;
	L_COUNT_CO       number := 0;

  begin
    -- If either of APPLY_*SCOPE parameters is set no N, then the corresponding table will be emptied.
    -- All subsequent SQL is safe to run on these tables being empty.
    if '&&APPLY_INSCOPE' = 'N' then
      delete in_scope_contracts;
    end if;
    
    if '&&APPLY_OOSCOPE' = 'N' then
      delete out_of_scope_contracts;
    end if;
  
    select count(1)
      into L_COUNT_CO
      from (SELECT v.id_vertrag, v.id_fzgvertrag
              FROM in_scope_contracts ins
              JOIN snt.TFZGVERTRAG v ON v.id_vertrag = ins.id_vertrag AND (v.id_fzgvertrag = ins.id_fzgvertrag OR ins.id_fzgvertrag = '*')
             MINUS
            SELECT v.id_vertrag, v.id_fzgvertrag
              FROM out_of_scope_contracts oos
              JOIN snt.TFZGVERTRAG v ON v.id_vertrag = oos.id_vertrag AND (v.id_fzgvertrag = oos.id_fzgvertrag OR oos.id_fzgvertrag = '*')
            )
     where rownum = 1;
    
    if L_COUNT_CO = 0 then
      dbms_output.put_line( chr(10)||'INFO: No additional contracts to be set to IN-SCOPE explicitly (either IN-SCOPE List is empty or is overriden by OUT-OF-SCOPE List.');
    end if;
  
    select count(1)
      into L_COUNT_CO
      from out_of_scope_contracts;
    
    if L_COUNT_CO = 0 then
      dbms_output.put_line( chr(10)||'INFO: No additional contracts to be set to MIG_OOS explicitly.');
    end if;
  
    L_COUNT_CO := 0;
  
    for i in (
              SELECT v.id_vertrag, v.id_fzgvertrag
                FROM in_scope_contracts ins
                JOIN snt.TFZGVERTRAG v ON v.id_vertrag = ins.id_vertrag AND (v.id_fzgvertrag = ins.id_fzgvertrag OR ins.id_fzgvertrag = '*')
           INTERSECT
              SELECT v.id_vertrag, v.id_fzgvertrag
                FROM out_of_scope_contracts oos
                JOIN snt.TFZGVERTRAG v ON v.id_vertrag = oos.id_vertrag AND (v.id_fzgvertrag = oos.id_fzgvertrag OR oos.id_fzgvertrag = '*')
             )
    loop
    
      L_COUNT_CO := L_COUNT_CO + 1;     
      if L_COUNT_CO = 1 then
        dbms_output.put_line( chr(10)||'WARN: The following contracts overlap in Explicit IN- and OUT-OF-SCOPE Lists. OUT-OF-SCOPE List will take precedence.');
      end if;
    
      dbms_output.put_line( i.id_vertrag||'/'||i.id_fzgvertrag);
      
    end loop;
    
    :L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + L_COUNT_CO;
    
    select max ( ID_COV )
      into L_ID_COV_MAX
      from snt.TDFCONTR_VARIANT;

   for crec in ( select ID_COV,                      COV_CAPTION,                COV_MEMO,                    COV_SCARF_CONTRACT,          COV_SCARF_REVENUE
                      , COV_NORMAL_GEWINN_MB,        COV_VORZ_GEWINN_MB,         COV_NORMAL_VERLUST_MB,       COV_VORZ_VERLUST_MB
                      , COV_NORMAL_GEWINN_GARAGE,    COV_VORZ_GEWINN_GARAGE,     COV_NORMAL_VERLUST_GARAGE,   COV_VORZ_VERLUST_GARAGE
                      , COV_NORMAL_GEWINN_CUSTOMER,  COV_VORZ_GEWINN_CUSTOMER,   COV_NORMAL_VERLUST_CUSTOMER, COV_VORZ_VERLUST_CUSTOMER
                      , COV_RUNPOWER_TOLERANCE_PERC, COV_RUNPOWER_TOLERANCE_DAY, COV_RUNPOWER_BALANCING,      COV_RUNPOWER_BALANCINGMETHOD
                      , GUID_FINANCIAL_SYSTEM,       COV_TRANSFER_TO_FINSYS,     COV_IC_IGNORE_MILEAGE,       COV_CLOSE_CHECK
                      , COV_USE_ADD_MILEAGE,         COV_USE_LESS_MILEAGE,       COV_USE_CONSV_PRIME,         COV_HANDLE_ADMINFEE
                      , COV_SERVICE_CARD,            GUID_SERVICECARD,           COV_STAT_CODE,               COV_FI_COSTING
                      , GUID_INDV,                   ID_PRV,                     COV_LEASING_SIVECO,          COV_PROFIT_VARIANT
                   from snt.TDFCONTR_VARIANT
                  where ID_COV in ( select c.ID_COV 
                                      from snt.TDFCONTR_STATE  s
                                         , snt.TFZGVERTRAG     v
                                         , snt.TFZGV_CONTRACTS c
                                     where c.ID_VERTRAG      = v.ID_VERTRAG
                                       and c.ID_FZGVERTRAG   = v.ID_FZGVERTRAG
                                       and s.ID_COS          = v.ID_COS
                                       and (((
                                             ( ('&&Scope' = 'A'
                                                and not exists ( select null                         -- es darf keinen InScope Supplier in den SP sammelrechnungen geben
                                                              from snt.TFZGRECHNUNG             fzgre
                                                                 , snt.TSP_COLLECTIVE_INVOICE   collInv
                                                                 , snt.TPARTNER                 part
                                                                 , snt.TGARAGE                  gar
                                                             where fzgre.ID_SEQ_FZGVC    = c.ID_SEQ_FZGVC
                                                               and fzgre.GUID_SPCI       = collInv.GUID_SPCI
                                                               and part.GUID_PARTNER     = collInv.GUID_PARTNER
                                                               and part.ID_GARAGE        = gar.ID_GARAGE
                                                               and ( '11924'             = gar.GAR_GARNOVEGA
                                                                  or 1                   = gar.GAR_IS_SERVICE_PROVIDER ))
                                                 or '&&Scope' = 'B'
                                               )
                                                               -- MKS-133612:1 FZGVC_BEGINN wird zu FZGVC_ENDE
                                               and ( s.COS_STAT_CODE not in ( '00', '01', '02' ) and c.FZGVC_ENDE  < to_date ( '&&Out_Of_Scope_Date', 'DD.MM.YYYY' )
                                                     or 
                                                     s.COS_STAT_CODE =   '10' 
                                                   )
                                             )
                                             or exists 
                                               (select 1 
                                                  from out_of_scope_contracts oos 
                                                 where oos.ID_VERTRAG = v.ID_VERTRAG 
                                                  and (oos.ID_FZGVERTRAG = v.ID_FZGVERTRAG or oos.ID_FZGVERTRAG = '*')
                                               ))
                                             and not exists
                                               -- If Contract is both in out_of_scope_contracts and in_scope_contracts, then the former takes precedence
                                               (select 1
                                                  from in_scope_contracts ins
                                                 where ins.ID_VERTRAG = v.ID_VERTRAG and (ins.ID_FZGVERTRAG = v.ID_FZGVERTRAG  or ins.ID_FZGVERTRAG = '*')
                                                 minus
                                                select 1 
                                                  from out_of_scope_contracts oos 
                                                 where oos.ID_VERTRAG = v.ID_VERTRAG and (oos.ID_FZGVERTRAG = v.ID_FZGVERTRAG  or oos.ID_FZGVERTRAG = '*')
                                               )
                                            )
                                            or '&&Scope' = '0'
                                            )
                                  )
                  order by 1 )
   loop
    
    if crec.COV_CAPTION not like 'MIG_OOS%' then
    
      l_id_cov_ins := crec.ID_COV;
      -- Find or create corresponding MIG_OOS% Variant 
      begin
      
        select id_cov
          into l_id_cov_oos
          from snt.TDFCONTR_VARIANT
         where COV_CAPTION = 'MIG_OOS_' || substr ( crec.COV_CAPTION, 1,   42 );
      
      exception when no_data_found then
       
        L_ID_COV_MAX := L_ID_COV_MAX + 1;
        
        insert into snt.TDFCONTR_VARIANT 
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
        values
        ( L_ID_COV_MAX
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
        , crec.GUID_INDV,                   crec.ID_PRV,                     crec.COV_LEASING_SIVECO,          crec.COV_PROFIT_VARIANT )
        returning ID_COV into L_ID_COV_OOS;
     
      end;
   
    else
    
      l_id_cov_oos := crec.ID_COV;
      -- Find Corresponding Sirius Variant
      begin
      
        select id_cov
          into l_id_cov_ins
          from snt.TDFCONTR_VARIANT
         where COV_CAPTION like substr(crec.COV_CAPTION, 9)||'%'
           and rownum = 1;

      exception when no_data_found then
        :L_DATAERRORS_OCCURED := :L_DATAERRORS_OCCURED + 1;
        dbms_output.put_line( chr(10)||'ERR: Sirius contarct type '||substr(crec.COV_CAPTION, 9)||'% not found for: '||crec.COV_CAPTION);
        raise;
      end;
      
    end if;
      
    if '&&Scope' <> '0' then
        
       -- old: if COS_STAT_CODE   not in ( '00', '01', '02' ) are OutOfScope only if contract begin date < '&&Out_Of_Scope_Date' (-> inactive contracts )
       -- new in LOP2796 if COS_STAT_CODE   not in ( '00', '01', '02' ) are OutOfScope only if contract end date < '&&Out_Of_Scope_Date' (-> inactive contracts )
      update snt.TFZGV_CONTRACTS c
         set ID_COV = l_id_cov_oos
       where ID_COV = l_id_cov_ins
          -- LOP 2796, MKS-133612:1  change from beginn date < scope Date to end_date<ScopeDate
          and FZGVC_ENDE < to_date ( '&&Out_Of_Scope_Date', 'DD.MM.YYYY' )
          and ('&&Scope' = 'A' and
               not exists ( select null                         -- es darf keinen InScope Supplier in den SP sammelrechnungen geben
                             from snt.TFZGRECHNUNG             fzgre
                                , snt.TSP_COLLECTIVE_INVOICE   collInv
                                , snt.TPARTNER                 part
                                , snt.TGARAGE                  gar
                            where fzgre.ID_SEQ_FZGVC    = c.ID_SEQ_FZGVC
                              and fzgre.GUID_SPCI       = collInv.GUID_SPCI
                              and part.GUID_PARTNER     = collInv.GUID_PARTNER
                              and part.ID_GARAGE        = gar.ID_GARAGE
                              and ( '11924'             = gar.GAR_GARNOVEGA
                                 or 1                   = gar.GAR_IS_SERVICE_PROVIDER ))
                or '&&Scope' = 'B'
              )
          and not exists ( select null                         -- der vartragsstatus - code darf kein aktiver sein
                             from snt.TDFCONTR_STATE  s
                                , snt.TFZGVERTRAG     v
                            where c.ID_VERTRAG        = v.ID_VERTRAG
                              and c.ID_FZGVERTRAG     = v.ID_FZGVERTRAG
                              and s.ID_COS            = v.ID_COS
                              and s.COS_STAT_CODE    in ( '00', '01', '02' ));
       L_COUNT_CO := sql%rowcount;
       
       -- COS_STAT_CODE = '10' (-> cancelled contracts ) sind immer OutOfScope
       update snt.TFZGV_CONTRACTS c
          set ID_COV   = l_id_cov_oos
        where c.ID_COV = l_id_cov_ins
          and (c.ID_VERTRAG, c.ID_FZGVERTRAG ) in
            ( select v.ID_VERTRAG, v.ID_FZGVERTRAG
                from snt.TDFCONTR_STATE  s
                   , snt.TFZGVERTRAG     v
               where s.ID_COS            = v.ID_COS
                 and s.COS_STAT_CODE     = '10' );
       L_COUNT_CO := L_COUNT_CO + sql%rowcount;
       
       -- IMOs ( Industriemotoren (-> ID fahrzeugart = 20 )) sind immer OutOfScope
       update snt.TFZGV_CONTRACTS c
          set ID_COV   = l_id_cov_oos
        where c.ID_COV = l_id_cov_ins
          and (c.ID_VERTRAG, c.ID_FZGVERTRAG ) in
            ( select v.ID_VERTRAG, v.ID_FZGVERTRAG
                from snt.TTYPGRUPPE      tg
                   , snt.TFAHRZEUGTYP    ft
                   , snt.TFZGVERTRAG     v
               where v.ID_FZGTYP       = ft.ID_FZGTYP
                 and tg.ID_TYPGRUPPE   = ft.ID_TYPGRUPPE
                 and tg.ID_FAHRZEUGART = 20 );
       L_COUNT_CO := L_COUNT_CO + sql%rowcount;
       
       -- Busse (-> Businessarealevel2: 'Buses' ) sind immer OutOfScope
       update snt.TFZGV_CONTRACTS c
          set ID_COV   = l_id_cov_oos
        where c.ID_COV = l_id_cov_ins
          and( c.ID_VERTRAG, c.ID_FZGVERTRAG ) in
            ( select ID_VERTRAG, v.ID_FZGVERTRAG
                from snt.TBUSINESS_AREA_L2 bal2
                   , snt.TFAHRZEUGART      fa
                   , snt.TTYPGRUPPE        tg
                   , snt.TFAHRZEUGTYP      ft
                   , snt.TFZGVERTRAG       v
               where v.ID_FZGTYP                = ft.ID_FZGTYP
                 and tg.ID_TYPGRUPPE            = ft.ID_TYPGRUPPE
                 and tg.ID_FAHRZEUGART          = fa.ID_FAHRZEUGART 
                 and bal2.GUID_BUSINESS_AREA_L2 = fa.GUID_BUSINESS_AREA_L2
                 and bal2.BAL2_CAPTION          = 'Buses' );
       L_COUNT_CO := L_COUNT_CO + sql%rowcount;
        
    else
      -- We are in Scope 0, therefore all Contracts will be set out of scope
      update snt.TFZGV_CONTRACTS v
         set ID_COV  = l_id_cov_oos
       where v.ID_COV = l_id_cov_ins;
      
      L_COUNT_CO := sql%rowcount;
      
    end if;
    
    -- Set in_scope_contracts to In Scope explicitly
    update snt.TFZGV_CONTRACTS v
       set ID_COV   = l_id_cov_ins
     where v.ID_COV = l_id_cov_oos
       and exists ( select 1 
                      from in_scope_contracts ins
                     where ins.ID_VERTRAG = v.ID_VERTRAG and (ins.ID_FZGVERTRAG = v.ID_FZGVERTRAG  or ins.ID_FZGVERTRAG = '*')
                     minus
                    select 1
                      from out_of_scope_contracts oos 
                     where oos.ID_VERTRAG = v.ID_VERTRAG and (oos.ID_FZGVERTRAG = v.ID_FZGVERTRAG  or oos.ID_FZGVERTRAG = '*'));
    
    L_COUNT_CO := L_COUNT_CO - sql%rowcount;
    
    -- Set out_of_scope_contracts to Out of Scope explicitly
    update snt.TFZGV_CONTRACTS v
       set ID_COV  = l_id_cov_oos
     where v.ID_COV = l_id_cov_ins
       and exists (  select 1 
                      from out_of_scope_contracts oos 
                     where oos.ID_VERTRAG = v.ID_VERTRAG and (oos.ID_FZGVERTRAG = v.ID_FZGVERTRAG  or oos.ID_FZGVERTRAG = '*'));
 
    L_COUNT_CO := L_COUNT_CO + sql%rowcount;
    
    :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + L_COUNT_CO;
       
    if l_id_cov_oos = L_ID_COV_MAX then
      
      if   L_COUNT_CO > 0 then
        -- mind 1 CO wurde die neue variante zugeteilt
        dbms_output.put_line ( 'new contract variant ' || to_char ( l_id_cov_oos ) || ' / ''MIG_OOS_' || substr ( crec.COV_CAPTION, 1, 42 )
                               || ''' created for ' || to_char ( L_COUNT_CO ) || ' contracts.' );
  	  else
        -- keinem einzigen CO wurde die neue variante zugeteilt -> daten müssen daher zurück geladen werden ...
        delete snt.TDFCONTR_VARIANT 
         where ID_COV = l_id_cov_oos;
        L_ID_COV_MAX := L_ID_COV_MAX - 1;
      
      end if;
      
    end  if;
         
   end loop;
   
   -- Cleanup MIG_OOS types that have no corresponding Contracts
  /*delete snt.TDFCONTR_VARIANT v
    where v.COV_CAPTION like 'MIG_OOS%' and not exists (select 1 from snt.TFZGV_CONTRACTS c where c.ID_COV = v.ID_COV);*/
exception when others then
  :L_ERROR_OCCURED:= :L_ERROR_OCCURED + 1;
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
-- Tables can be restored from the Database Recyclebin if DBA_RECYCLEBIN = on
drop table out_of_scope_contracts;
drop table in_scope_contracts;
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