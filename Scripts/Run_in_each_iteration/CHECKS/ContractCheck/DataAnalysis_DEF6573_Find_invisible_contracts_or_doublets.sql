-- DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-11-26; ZBerger; V1.1; MKS-135753:1; creation
-- 2014-12-01; ZBerger; V1.2; MKS-135753:2; enhance output
-- 2014-12-04; FraBe;   V1.3; MKS-135753:3; some verification changes
-- 2014-12-04; FraBe;   V1.4; MKS-135753:4; comment nach einem exec befehl vor den befehl stellen, da nachher (- in derselben zeile -) keiner stehen darf 
--                                          plus rename L_SCOPING zu L_only_InScope_CO weil letzteres sprechender
-- 2014-12-17; FraBe;   V1.5; MKS-135753:5; add L_ID_FZGVERTRAGs / 2.1 - c1_list
-- 2014-12-18; ZBerger; V1.6; MKS-135753:6; use exists instead of minus in 2.1/2.2
-- 2014-01-24; PBerger; V1.7; MKS-135753:7: do not consider canceled contract
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT

   -- file name for script and logfile
   define GL_SCRIPTNAME         = DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets
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
   define L_MPC_CHECK           = false    -- false or true
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
variable L_only_InScope_CO      number;

exec :L_SCRIPTNAME              := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED           := 0
exec :L_DATAERRORS_OCCURED      := 0
exec :L_DATAWARNINGS_OCCURED    := 0
exec :L_DATASUCCESS_OCCURED     := 0
-- Only scoped contracts? (0=true/1=false)
exec :L_only_InScope_CO         := 1

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

/*
PROMPT Do you want to save the changes to the DB? [Y/N] (Default N):

SET TERMOUT OFF
Define commit_or_rollback = &1 N;
SET TERMOUT ON

prompt SELECTION CHOSEN: "&commit_or_rollback"
*/

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
set feedback     off

declare
   L_USING_CO               tdatadictionary.dd_using%type;
   L_USING_COV              tdatadictionary.dd_using%type;
   L_ID_FZGVERTRAG          tfzgv_contracts.id_fzgvertrag%type;
   L_ID_FZGVERTRAGs         varchar2 ( 4000 char );
   L_lastChanged_or_created varchar2 (  100 char );
   
   function get_lastChanged_or_created
          ( I_ID_VERTRAG             tfzgv_contracts.ID_VERTRAG%type
          , I_ID_FZGVERTRAG          tfzgv_contracts.ID_FZGVERTRAG%type
          ) return                   varchar2 is
            L_lastChanged_or_created varchar2 ( 100 char );
          
   begin
        select to_char ( nvl ( fzgvc.EXT_UPDATE_DATE, fzgvc.FZGVC_CREATED ), 'DD-MM-YYYY HH24:MI' )
            || '            ' || cov.COV_CAPTION
          into L_lastChanged_or_created
          from tfzgv_contracts  fzgvc,
               tdfcontr_variant cov
         where fzgvc.ID_VERTRAG     = I_ID_VERTRAG
           and fzgvc.ID_FZGVERTRAG  = I_ID_FZGVERTRAG
           and fzgvc.ID_COV         = cov.ID_COV;
           
        return L_lastChanged_or_created;
        
   end;

begin
   -- get current used using-format
   select dd_using
     into L_USING_CO
     from snt.tdatadictionary
    where upper(id_datadictionary) = 'ID_VERTRAG';
    
   select dd_using
     into L_USING_COV
     from snt.tdatadictionary
    where upper(id_datadictionary) = 'ID_FZGVERTRAG';

   -- step 1: list non-conform contracts
   dbms_output.put_line ('');
   dbms_output.put_line ( '1. List non-conform formatted contracts:' );
   dbms_output.put_line ( 'id_vertrag: stored => formatted	id_fzgvertrag: stored => formatted  lastChanged or created   contract state');
   dbms_output.put_line ( rpad ( '=', 143, '=' ));
   for c_list in (select distinct
                         fzgvc.id_vertrag, 
                         case when LENGTH(TRIM(TRANSLATE(fzgvc.id_vertrag, ' +-.0123456789', ' '))) is null
                              then trim(to_char( fzgvc.id_vertrag, L_USING_CO ))
                              else fzgvc.id_vertrag
                         end as using_id_vertrag,
                         fzgvc.id_fzgvertrag,
                         case when LENGTH(TRIM(TRANSLATE(fzgvc.id_fzgvertrag, ' +-.0123456789', ' '))) is null
                              then trim(to_char( fzgvc.id_fzgvertrag, L_USING_COV ))
                              else fzgvc.id_fzgvertrag
                         end as using_id_fzgvertrag,
                         to_char ( nvl ( fzgvc.EXT_UPDATE_DATE, fzgvc.FZGVC_CREATED ), 'DD-MM-YYYY HH24:MI' ) as lastChanged_or_created,
                         cov.cov_caption
                    from tfzgv_contracts  fzgvc,
                         tdfcontr_variant cov,
                         tfzgvertrag fzgv,
                         tdfcontr_state cos
                   where ((fzgvc.id_vertrag <> case when LENGTH(TRIM(TRANSLATE(fzgvc.id_vertrag, ' +-.0123456789', ' '))) is null
                                             then trim(to_char( fzgvc.id_vertrag, L_USING_CO ))
                                             else fzgvc.id_vertrag
                                        end)
                      or (fzgvc.id_fzgvertrag <> case when LENGTH(TRIM(TRANSLATE(fzgvc.id_fzgvertrag, ' +-.0123456789', ' '))) is null
                                                then trim(to_char( fzgvc.id_fzgvertrag, L_USING_COV ))
                                                else fzgvc.id_fzgvertrag
                                           end))
                     and fzgvc.id_cov = cov.id_cov
                     and (:L_only_InScope_CO=1 or cov.cov_caption NOT LIKE '%MIG_OOS%')
                     and (fzgvc.id_vertrag = fzgv.id_vertrag AND fzgvc.id_fzgvertrag = fzgv.id_fzgvertrag)
                     and fzgv.id_cos = cos.id_cos
                     and cos.cos_stat_code <> 10
                     order by 1, 2 ) loop
      dbms_output.put_line ( rpad ( 'id_vertrag: '       || c_list.id_vertrag    || '=>' || c_list.using_id_vertrag,    32, ' ' )
                          || rpad ( 'id_fzgvertrag: '    || c_list.id_fzgvertrag || '=>' || c_list.using_id_fzgvertrag, 36, ' ' )
                          || c_list.lastChanged_or_created || '         ' || c_list.cov_caption  );
      :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
   end loop;

   -- step 2.1: search for doublettes id_vertrag
   dbms_output.put_line ('');
   dbms_output.put_line ( '2.1 List double contracts (id_vertrag)' );
   dbms_output.put_line ( 'id_vertrag: stored => 2nd stored');
   dbms_output.put_line ( '======================================' );
   for c_list in (select fzgvc.id_vertrag
                    from tfzgv_contracts  fzgvc,
                         tdfcontr_variant cov,
                         tfzgvertrag fzgv,
                         tdfcontr_state cos
                   where fzgvc.id_cov = cov.id_cov
                     and (fzgvc.id_vertrag = fzgv.id_vertrag AND fzgvc.id_fzgvertrag = fzgv.id_fzgvertrag)
                     and fzgv.id_cos = cos.id_cos
                     and cos.cos_stat_code <> 10
                     and (:L_only_InScope_CO=1 or cov.cov_caption NOT LIKE '%MIG_OOS%')
                     and exists(select null
                                  from tfzgvertrag      fzgv,
                                       tdfcontr_variant cov,
                                       tdfcontr_state cos
                                 where fzgv.id_vertrag = case when LENGTH(TRIM(TRANSLATE(fzgvc.id_vertrag, ' +-.0123456789', ' ' ))) is null
                                                              then trim(to_char( fzgvc.id_vertrag, L_USING_CO ))
                                                              else lpad(fzgvc.id_vertrag, 6, '0')
                                                         end
                                   and fzgv.id_vertrag <> fzgvc.id_vertrag
                                   and fzgvc.id_cov = cov.id_cov
                                   and fzgv.id_cos = cos.id_cos
                                   and cos.cos_stat_code <> 10
                                   and (:L_only_InScope_CO=1 or cov.cov_caption NOT LIKE '%MIG_OOS%')))
   loop
     L_ID_FZGVERTRAGs := null;
     for c1_list in ( select ID_FZGVERTRAG
                        from TFZGVERTRAG 
                       where ID_VERTRAG   =  c_list.id_vertrag
                       order by 1 )
     loop
         if   L_ID_FZGVERTRAGs   is not null
         then L_ID_FZGVERTRAGs := L_ID_FZGVERTRAGs || ',';
         end  if;
         L_ID_FZGVERTRAGs := L_ID_FZGVERTRAGs || c1_list.ID_FZGVERTRAG;
     
     end loop;
     
     dbms_output.put_line ('id_vertrag: ' || c_list.id_vertrag || '=>' || case when LENGTH(TRIM(TRANSLATE(c_list.id_vertrag, ' +-.0123456789', ' '))) is null
                                                                               then trim(to_char(c_list.id_vertrag, L_USING_CO ))
                                                                               else lpad(c_list.id_vertrag, 6, '0')
                                                                          end
                                          || ' (' || L_ID_FZGVERTRAGs || ')' );
     :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
   end loop;

   -- step 2.2: search for doublettes id_fzgvertrag
   dbms_output.put_line ('');
   dbms_output.put_line ( '2.2 List double contracts (id_fzgvertrag)' );
   dbms_output.put_line ( 'id_vertrag: stored              id_fzgvertrag: stored => 2nd stored     1st: lastChanged or created contract state                                     2nd: lastChanged or created contract state');
   dbms_output.put_line ( rpad ( '=', 228, '=' ));
   for c_list in (select fzgvc.id_vertrag, fzgvc.id_fzgvertrag
                    from tfzgv_contracts  fzgvc,
                         tdfcontr_variant cov,
                         tfzgvertrag fzgv,
                         tdfcontr_state cos
                   where fzgvc.id_cov = cov.id_cov
                     and (fzgvc.id_vertrag = fzgv.id_vertrag AND fzgvc.id_fzgvertrag = fzgv.id_fzgvertrag)
                     and fzgv.id_cos = cos.id_cos
                     and cos.cos_stat_code <> 10
                     and (:L_only_InScope_CO=1 or cov.cov_caption NOT LIKE '%MIG_OOS%')
                     and exists(select null
                                  from tfzgvertrag      fzgv,
                                       tdfcontr_variant cov,
                                       tdfcontr_state   cos
                                 where fzgv.id_fzgvertrag = case when LENGTH(TRIM(TRANSLATE(fzgvc.id_fzgvertrag, ' +-.0123456789', ' ' ))) is null
                                                                 then trim(to_char( fzgvc.id_fzgvertrag, L_USING_COV ))
                                                                 else lpad(fzgvc.id_fzgvertrag, 4, '0')
                                                            end
                                   and fzgv.id_fzgvertrag <> fzgvc.id_fzgvertrag
                                   and fzgvc.id_cov = cov.id_cov
                                   and fzgv.id_cos   = cos.id_cos
                                   and cos.cos_stat_code <> 10
                                   and (:L_only_InScope_CO=1 or cov.cov_caption NOT LIKE '%MIG_OOS%')))
   loop
     l_id_fzgvertrag := case when LENGTH(TRIM(TRANSLATE(c_list.id_fzgvertrag, ' +-.0123456789', ' '))) is null
                             then trim(to_char(c_list.id_fzgvertrag, L_USING_COV ))
                             else lpad(c_list.id_fzgvertrag, 4, '0')
                        end;
     if substr(l_id_fzgvertrag, 1, 4) <> '####' then
        L_lastChanged_or_created := get_lastChanged_or_created ( c_list.id_vertrag, L_ID_FZGVERTRAG );
     -- dbms_output.put_line ('id_vertrag: ' || c_list.id_vertrag || chr(9) || 'id_fzgvertrag: ' || c_list.id_fzgvertrag || '=>' || l_id_fzgvertrag);
        dbms_output.put_line ( rpad ( 'id_vertrag: '       || c_list.id_vertrag    || '=>' || c_list.id_vertrag,    32, ' ' )
	                    || rpad ( 'id_fzgvertrag: '    || c_list.id_fzgvertrag || '=>' || l_id_fzgvertrag,      40, ' ' )
	                    || rpad ( get_lastChanged_or_created ( c_list.id_vertrag, c_list.id_fzgvertrag ),       79, ' ' )
	                    || get_lastChanged_or_created ( c_list.id_vertrag, l_id_fzgvertrag )
	                    );

        :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
     end if;
   end loop;

exception
   when dup_val_on_index then
        dbms_output.put_line ( 'Change was already done. - Change made not successful!' );
        :L_DATAWARNINGS_OCCURED:= :L_DATAWARNINGS_OCCURED+1;
   
   when no_data_found then 
        dbms_output.put_line ( 'A Data error occured. - Change made not successful!' );
        :L_DATAERRORS_OCCURED:= :L_DATAERRORS_OCCURED+1;

   when others then
        dbms_output.put_line ( 'A unhandled Data error occured. - Change made not successful!' );
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

/*
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
*/
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
