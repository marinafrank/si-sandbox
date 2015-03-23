-- DataAnalysis_Calculate_sum_of_ContractValue.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- 2014-08-13; FraBe;    V1.1; MKS-134289:1; creation
-- 2014-08-27; FraBe;    V1.2; MKS-134289:2; anlegen / droppen table TFZGPREIS_SIMEX und arbeiten mit dieser
--                                           bzw. keine DB links mehr und login ist snt und nicht mehr simex
-- 2014-09-11; FraBe;    V1.3; MKS-134289:3; a) rauslöschen CO MIG_OOS% scope check 
--                                           b) insert distinct rows into snt.TFZGPREIS_SIMEX 
--                                           c) arbeiten mit L_LL_YEAR = 0 wenns keine LL für den CO gibt
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME         = 'DataAnalysis_Calculate_sum_of_ContractValue'
   define GL_LOGFILETYPE        = log           -- logfile name extension. [log|csv|txt]  {csv causes less info in logfile}
   define GL_SCRIPTFILETYPE     = sql           -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN           = 2
   define L_MINOR_MIN           = 8
   define L_REVISION_MIN        = 0
   define L_BUILD_MIN           = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER            = snt
   define L_SYSDBA_PRIV_NEEDED  = false    -- false or true

  -- country specification
   define L_MPC_CHECK           = false    -- false or true
   define L_MPC_SOLL            = ''       -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = ''       -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
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

-- spool &GL_SCRIPTNAME..&GL_LOGFILETYPE          ---> kein logging gefordert / erwünscht

declare
   L_LAST_EXEC_TIME        varchar2 (  30 char );
begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
  dbms_output.put_line ( 'Script executed on: ' || to_char ( sysdate, 'DD.MM.YYYY HH24:MI:SS' )); 
  dbms_output.put_line ( 'Script executed by: &&_USER'); 
  dbms_output.put_line ( 'Script run on DB  : &&_CONNECT_IDENTIFIER'); 
  dbms_output.put_line ( 'Database Country  : ' || snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' )); 
/* obsolete, da nix geloggt wird
  dbms_output.put_line ( 'Database dump date: ' || snt.get_TGLOBAL_SETTINGS ( 'DB', 'DUMP', 'DATE', 'not found' )); 
  begin
              select to_char ( max ( LE_CREATED ), 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
                      from snt.TLOG_EVENT e
                     where GUID_LA = '10'         -- maintenance
                       and exists ( select null
                                      from snt.TLOG_EVENT_PARAM ep
                                     where ep.LEP_VALUE = :L_SCRIPTNAME
                              and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME );
    
    exception 
    when others then 
      NULL;
  end;
*/
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
   /* obsolete, da nix geloggt wird
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
   */
   -------------------------------------------------------------------------------------------------------
   -- raise if at least one check above failed
  if   L_ABBRUCH
  then raise_application_error ( -20000, '==> Script Execution cancelled <==' );
  end  if;
end;
/

WHENEVER SQLERROR CONTINUE

/* -> nicht notwendig, da nur select
prompt Do you want to save the changes to the DB? [Y/N] (Default N):  

SET TERMOUT OFF
Define commit_or_rollback = &1 N;
SET TERMOUT ON

prompt SELECTION CHOSEN: "&commit_or_rollback"
*/

prompt
prompt processing. please wait ...
prompt

-- set termout      off
set sqlprompt    'SQL>'
set pages        9999
set lines        9999
set serveroutput on   size unlimited format wrapped
set heading      off
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >



-- main part for < selecting or checking or correcting code >

-- a) drop old table snt.TFZGPREIS_SIMEX if existing
declare
    TABLE_NOT_EXISTING      exception;
    pragma exception_init ( TABLE_NOT_EXISTING,  -942 );
begin
    execute immediate 'drop table snt.TFZGPREIS_SIMEX cascade constraints purge';
exception when TABLE_NOT_EXISTING then null;
end;
/

-- b) create global temporary table snt.TFZGPREIS_SIMEX and PK / index
create global temporary table snt.TFZGPREIS_SIMEX
     ( ID_SEQ_FZGVC                   number              not null
     , ID_VERTRAG                     varchar2 ( 30 char) not null
     , ID_FZGVERTRAG                  varchar2 ( 30 char) not null
     , FZGPR_VON                      date                not null
     , FZGPR_BIS                      date                not null
     , FZGPR_PREIS_GRKM               number ( 12, 4 )    not null
     , FZGPR_PREIS_MONATP             number ( 12, 4 )    not null
     , FZGPR_ADD_MILEAGE              number ( 38, 4 )
     , FZGPR_LESS_MILEAGE             number ( 38, 4 )
     , FZGPR_BEGIN_MILEAGE            number
     , FZGPR_END_MILEAGE              number
     , ID_LLEINHEIT                   number
     , INDV_TYPE                      number
     , FZGPR_PREIS_FIX                number
     , EXT_CREATION_DATE              date
     , constraint PXTFZGPREIS_SIMEX primary key ( ID_VERTRAG, ID_FZGVERTRAG, FZGPR_VON )
     ) on commit preserve rows
/

create index snt.IE1TFZGPREIS_SIMEX on snt.TFZGPREIS_SIMEX
     ( ID_SEQ_FZGVC, ID_VERTRAG, ID_FZGVERTRAG )
/

-- c) befüllen TFZGPREIS_SIMEX (- wird für die spätere berechnung des ContractValue benötigt -)
begin

         delete snt.TFZGPREIS_SIMEX;
         -----------------------------------------------------------------------------------
         -- 1st: copy TFZGPREIS and LL info 1:1 into GlobalTembporaryTable TFZGPREIS_SIMEX:
         insert into snt.TFZGPREIS_SIMEX
              ( ID_SEQ_FZGVC
              , ID_VERTRAG
              , ID_FZGVERTRAG
              , FZGPR_VON
              , FZGPR_BIS
              , FZGPR_PREIS_GRKM
              , FZGPR_PREIS_MONATP
              , FZGPR_PREIS_FIX
              , FZGPR_ADD_MILEAGE
              , FZGPR_LESS_MILEAGE
              , FZGPR_BEGIN_MILEAGE
              , FZGPR_END_MILEAGE
              , ID_LLEINHEIT
              , INDV_TYPE )
         select distinct
                pr.ID_SEQ_FZGVC
              , pr.ID_VERTRAG
              , pr.ID_FZGVERTRAG
              , pr.FZGPR_VON
              , pr.FZGPR_BIS
              , pr.FZGPR_PREIS_GRKM
              , pr.FZGPR_PREIS_MONATP
              , pr.FZGPR_PREIS_FIX
              , pr.FZGPR_ADD_MILEAGE
              , pr.FZGPR_LESS_MILEAGE
              , pr.FZGPR_BEGIN_MILEAGE
              , pr.FZGPR_END_MILEAGE
              , ll.ID_LLEINHEIT
              , indv.INDV_TYPE
           from snt.TDF_INDEXATION_VARIANT  indv
              , snt.TFZGLAUFLEISTUNG        ll
              , snt.TFZGPREIS               pr
              , snt.TFZGV_CONTRACTS         fzgvc
          where indv.GUID_INDV         = fzgvc.GUID_INDV
            and pr.ID_SEQ_FZGVC        = fzgvc.ID_SEQ_FZGVC
            and pr.ID_SEQ_FZGVC        = ll.ID_SEQ_FZGVC(+)
            and pr.FZGPR_VON          <= ll.FZGLL_VON(+)
            and pr.FZGPR_BIS          >= ll.FZGLL_BIS(+);

         -----------------------------------------------------------------------------------
         -- 2nd: additional: bei aktiven CO (-> COS_ACTIVE = 1 ), die flex - indexable (-> INDV_TYPE = 2 )
         -- sind, wird das letzte preis - FZGPR_BIS auf das PrelEndDate des CO gesetzt:
         update snt.TFZGPREIS_SIMEX pr
            set pr.FZGPR_BIS = ( select max ( fzgvc.FZGVC_ENDE )
                                   from snt.TFZGV_CONTRACTS    fzgvc
                                  where fzgvc.ID_SEQ_FZGVC    = pr.ID_SEQ_FZGVC )
          where exists         ( select null
                                   from snt.TFZGPREIS_SIMEX pr1
                                  where pr1.ID_SEQ_FZGVC      = pr.ID_SEQ_FZGVC
                                 having max ( pr1.FZGPR_BIS ) = pr.FZGPR_BIS )       --- only last price of last duration
            and (      pr.ID_VERTRAG
                     , pr.ID_FZGVERTRAG
                     , pr.ID_SEQ_FZGVC
                     , pr.INDV_TYPE ) in
              ( select fzgv1.ID_VERTRAG
                     , fzgv1.ID_FZGVERTRAG
                     , GET_MAX_CO ( fzgv1.ID_VERTRAG, fzgv1.ID_FZGVERTRAG )          --- only last duration
                     , 2                                                             --- only flex indexable prices
                  from snt.TDFCONTR_STATE    cos1
                     , snt.TFZGVERTRAG       fzgv1
                 where fzgv1.ID_COS   = cos1.ID_COS
                   and 1              = cos1.COS_ACTIVE );                           --- only active contracts

         -----------------------------------------------------------------------------------
         -- 3rd: additional: bei aktiven CO (-> COS_ACTIVE = 1 ), die fixed - indexable (-> INDV_TYPE = 1 ) sind,
         -- und wo keine Preisbestandteile definiert sind ( -> COV_USE_CONSV_PRIME <> 1 ) werden ausgehend vom
         -- letzten preis (- der letzten duration -) neue simulierte preise erstellt - je einer für jedes jahr:

         declare
              L_FZGPR_VON                snt.TFZGPREIS_SIMEX.FZGPR_VON%type;
              L_FZGPR_BIS                snt.TFZGPREIS_SIMEX.FZGPR_BIS%type;
              L_FZGPR_PREIS_GRKM         snt.TFZGPREIS_SIMEX.FZGPR_PREIS_GRKM%type;
              L_FZGPR_PREIS_MONATP       snt.TFZGPREIS_SIMEX.FZGPR_PREIS_MONATP%type;
              L_FZGPR_PREIS_FIX          snt.TFZGPREIS_SIMEX.FZGPR_PREIS_FIX%type;

              L_LL_YEAR                  number;

              L_GS_RoundingMileageAmount TGLOBAL_SETTINGS.VALUE%type := get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting',    'RoundingMileageAmount' );
              L_GS_FixPrice              TGLOBAL_SETTINGS.VALUE%type := get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Indexation', 'FixPrice',  '0'  );

              function ROUND_VALUE
                     ( I_VALUE             number
                     ) return              number is


               begin
                     if   L_GS_RoundingMileageAmount is not null
                     then return ( round ( I_VALUE, L_GS_RoundingMileageAmount ));
                     else return (         I_VALUE                              );
                     end  if;
               end;

         begin
              for crec in ( select /*+ index ( fzgpr PXTFZGPREIS_SIMEX ) ordered */ 
                                   fzgvc.ID_VERTRAG,          fzgvc.ID_FZGVERTRAG,       fzgvc.ID_SEQ_FZGVC,     fzgvc.FZGVC_ENDE, fzgvc.FZGVC_IDX_PERCENT
                                 , fzgpr.FZGPR_VON,           fzgpr.FZGPR_BIS
                                 , fzgpr.FZGPR_PREIS_GRKM,    fzgpr.FZGPR_PREIS_MONATP,  fzgpr.FZGPR_PREIS_FIX
                                 , fzgpr.FZGPR_ADD_MILEAGE,   fzgpr.FZGPR_LESS_MILEAGE
                                 , fzgpr.ID_LLEINHEIT
                              from snt.TDFCONTR_VARIANT   covar
                                 , snt.TDFCONTR_STATE     cos
                                 , snt.TFZGVERTRAG        fzgv
                                 , snt.TFZGV_CONTRACTS    fzgvc
                                 , snt.TFZGPREIS_SIMEX            fzgpr
                             where cos.COS_ACTIVE           = 1                                    --- only active contracts
                               and cos.ID_COS               = fzgv.ID_COS
                               and fzgvc.ID_VERTRAG         = fzgv.ID_VERTRAG
                               and fzgvc.ID_FZGVERTRAG      = fzgv.ID_FZGVERTRAG
                               and 1                       <> covar.COV_USE_CONSV_PRIME            --- only CO ohne Preisbestandteile
                               and fzgvc.ID_COV             = covar.ID_COV
                               and fzgvc.ID_SEQ_FZGVC       = snt.get_MAX_CO ( fzgv.ID_VERTRAG, fzgv.ID_FZGVERTRAG )
                               and fzgvc.ID_VERTRAG         = fzgpr.ID_VERTRAG
                               and fzgvc.ID_FZGVERTRAG      = fzgpr.ID_FZGVERTRAG
                               and 1                        = fzgpr.INDV_TYPE
                               and exists ( select /*+ index ( fzgpr1 PXTFZGPREIS_SIMEX ) */ 
                                                   null
                                              from snt.TFZGPREIS_SIMEX fzgpr1
                                             where fzgpr1.ID_VERTRAG        = fzgpr.ID_VERTRAG
                                               and fzgpr1.ID_FZGVERTRAG     = fzgpr.ID_FZGVERTRAG
                                            having max ( fzgpr1.FZGPR_BIS ) = fzgpr.FZGPR_BIS )    --- only last price (- of last duration -)
                          order by 1, 2, 3, 6 )
              loop
                  -- dbms_output.put_line ( 'IDX: ' || crec.FZGVC_IDX_PERCENT );
                  -- 1) lesen letzte laufleistung per monat
                  begin
                      select ll.FZGLL_LAUFLEISTUNG / ll.FZGLL_DAUER_MONATE
                        into L_LL_YEAR
                        from snt.TFZGLAUFLEISTUNG ll
                       where ll.ID_VERTRAG     = crec.ID_VERTRAG
                         and ll.ID_FZGVERTRAG  = crec.ID_FZGVERTRAG
                         and exists ( select null
                                        from snt.TFZGLAUFLEISTUNG ll1
                                       where ll1.ID_VERTRAG        = ll.ID_VERTRAG
                                         and ll1.ID_FZGVERTRAG     = ll.ID_FZGVERTRAG
                                      having max ( ll1.FZGLL_BIS ) = ll.FZGLL_BIS );                   --- only last existing LL
                  exception when NO_DATA_FOUND then L_LL_YEAR := 0;                                    --- MKS-134289:3 oder value 0 wenn keine LL existiert
                  end;
                  -------------------------------------------------------------------------
                  -- 2) einige crec values in L_ vars stellen, weil sich deren values bei den folgen berechnungen ändern:
                  L_FZGPR_PREIS_GRKM := crec.FZGPR_PREIS_GRKM;
                  L_FZGPR_PREIS_FIX  := crec.FZGPR_PREIS_FIX;
                  L_FZGPR_BIS        := crec.FZGPR_BIS;
                  -------------------------------------------------------------------------
                  -- 3) VON neuer preis = BIS letzter pri letzte duration + 1
                  L_FZGPR_VON        := L_FZGPR_BIS + 1;
                  -------------------------------------------------------------------------
                  -- 4) pri simulation nur wenn VON neuer pri nicht nach CO prel end
                  while L_FZGPR_VON < crec.FZGVC_ENDE
                  loop
                      -- I) VON neuer preis = nächster tag nach vorherigem BIS
                      L_FZGPR_VON  := L_FZGPR_BIS + 1;
                      -------------------------------------------------------------------------
                      -- II) BIS neuer pri = VON neuer pri + 1 jahr - 1 tag
                      L_FZGPR_BIS  := add_months ( L_FZGPR_VON, 12 ) - 1;
                      -------------------------------------------------------------------------
                      -- III) BIS neuer pri = CO prel end, wenn BIS neuer pri nach CO prel end
                      if   L_FZGPR_BIS  > crec.FZGVC_ENDE
                      then L_FZGPR_BIS := crec.FZGVC_ENDE;
                      end  if;
                      -------------------------------------------------------------------------
                      -- IV) ct/KM neu = letzter ct/KM erhöht um indexfaktor ev. gerundet mit faktor aus GS RoundingMileageAmount
                      L_FZGPR_PREIS_GRKM := ROUND_VALUE ( L_FZGPR_PREIS_GRKM * ( 100 + crec.FZGVC_IDX_PERCENT ) / 100 );
                      -------------------------------------------------------------------------
                      -- V)   Fixpreis neu = letzter Fixpreis       erhöht um indexfaktor ev. gerundet mit faktor aus GS RoundingMileageAmount, wenn GS Indexation / FixPrice       gesetzt
                      -- bzw. Fixpreis neu = letzter Fixpreis nicht erhöht um indexfaktor                                                       wenn GS Indexation / FixPrice nicht gesetzt
                      if    L_GS_FixPrice = 0 then L_FZGPR_PREIS_FIX := crec.FZGPR_PREIS_FIX;
                      elsif L_GS_FixPrice = 1 then L_FZGPR_PREIS_FIX := ROUND_VALUE ( crec.FZGPR_PREIS_FIX * ( 100 + crec.FZGVC_IDX_PERCENT ) / 100 );
                      else                         L_FZGPR_PREIS_FIX := 0;
                      end   if;
                      -------------------------------------------------------------------------
                      -- VI) neue MP = ct/KM neu * monatliche LL + Fixpreis neu ev. gerundet mit faktor aus GS RoundingMileageAmount
                      -- dbms_output.put_line ( 'L_FZGPR_PREIS_GRKM: ' || L_FZGPR_PREIS_GRKM || ' L_LL_YEAR: ' || L_LL_YEAR || ' L_FZGPR_PREIS_FIX: ' || L_FZGPR_PREIS_FIX );
                      L_FZGPR_PREIS_MONATP := ROUND_VALUE (( L_FZGPR_PREIS_GRKM * L_LL_YEAR / 100 ) + L_FZGPR_PREIS_FIX );
                      -------------------------------------------------------------------------
                      -- VII) neuen simulierten pri wegschreiben
                      -- dbms_output.put_line ( 'ID_SEQ_FZGVC: ' || crec.ID_SEQ_FZGVC || ' VON: ' || to_char ( L_FZGPR_VON, 'DD.MM.YYYY' ));
                      insert into snt.TFZGPREIS_SIMEX
                             ( ID_SEQ_FZGVC
                             , ID_VERTRAG
                             , ID_FZGVERTRAG
                             , FZGPR_VON
                             , FZGPR_BIS
                             , FZGPR_PREIS_GRKM
                             , FZGPR_PREIS_MONATP
                             , FZGPR_ADD_MILEAGE
                             , FZGPR_LESS_MILEAGE
                             , ID_LLEINHEIT
                             , INDV_TYPE )
                      values ( crec.ID_SEQ_FZGVC
                             , crec.ID_VERTRAG
                             , crec.ID_FZGVERTRAG
                             , L_FZGPR_VON
                             , L_FZGPR_BIS
                             , L_FZGPR_PREIS_GRKM
                             , L_FZGPR_PREIS_MONATP
                             , crec.FZGPR_ADD_MILEAGE
                             , crec.FZGPR_LESS_MILEAGE
                             , crec.ID_LLEINHEIT
                             , 1 );

                  end loop;

              end loop;

         end;

end;
/

-- d) anlegen function CO_REVENUE_AMOUNT (- wird für die spätere berechnung des ContractValue benötigt -)
create or replace function snt.CO_REVENUE_AMOUNT
      ( i_ID_VERTRAG                  varchar2
      , i_ID_FZGVERTRAG               varchar2
      , i_FZGVC_BEGINN                date
      , i_FZGVC_PREL_OR_FINAL_ENDE    date
      , i_PAYM_TARGETDATE_CI          number
      ) return                        number is

     -- purpose: calculates contract value
     --
     -- MODIFICATION HISTORY
     -- Person      Date       Comments
     -- ---------   ------     -------------------------------------------
     -- FraBe       27.08.2014 MKS-134289:2; almost copied from PCK_CONTRACT.CO_REVENUE_AMOUNT
     --                                      aber ersetzen der DB links

     L_dblMPSum                   NUMBER   := 0;
     L_dblSubventionSum           NUMBER   := 0;

     L_MONTH_BEGIN                varchar2 ( 6 char );
     L_MONTH_END                  varchar2 ( 6 char );
     L_MONTH_CURRENT              varchar2 ( 6 char );

     L_FZGPR_VON                  date;
     L_FZGPR_BIS                  date;

     L_DAYS_BEGIN_MONTH           integer;
     L_DAYS_END_MONTH             integer;
     L_MONTHS_BETWEEN             integer;

     L_GS_RoundingMileageAmount       TGLOBAL_SETTINGS.VALUE%type := get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'RoundingMileageAmount' );
     L_GS_TargetDateCustomerInvoice   TGLOBAL_SETTINGS.VALUE%type := get_TGLOBAL_SETTINGS ( 'SIRIUS', 'SETTING', 'TargetDateCustomerInvoice' );

     ----------------------------------------------------------------------------------------------------------------------------------------------------
     -- function zum berechnen der MP, die am 1. eines L_MONTH_CURRENT - vetragsmonats gültig ist
     ----------------------------------------------------------------------------------------------------------------------------------------------------
     function get_FZGPR_PREIS_MONATP
       return            number is

       L_RETURNVALUE     number  := 0;

     begin

          select FZGPR_PREIS_MONATP
            into L_RETURNVALUE
            from snt.TFZGPREIS_SIMEX
           where i_ID_VERTRAG          = ID_VERTRAG
             and i_ID_FZGVERTRAG       = ID_FZGVERTRAG
             and rownum                = 1
             and to_date ( L_MONTH_CURRENT || '01', 'YYYYMMDD' ) between FZGPR_VON and FZGPR_BIS;

          return L_RETURNVALUE;

     exception when NO_DATA_FOUND
               then return 0;
     end;

begin

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  -- i_PAYM_TARGETDATE_CI = 0: keine tagesgenaue abrechnung:
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  --      MP vom ersten  vertragsmonat, falls der vertrag vor  dem GS TargetDateCustomerInvoice - tag liegt oder gleich ist
  -- plus MP vom letzten vertragsmonat, falls der vertrag nach dem GS TargetDateCustomerInvoice - tag liegt
  -- plus MP von allen   vertragsmonaten dazwischen
  -- (-> MP immer nur jene, die am 1. des entsprechenden vertragsmonats gültig ist )
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  if   i_PAYM_TARGETDATE_CI = 0
  then L_MONTH_BEGIN   := to_char ( i_FZGVC_BEGINN,             'YYYYMM' );
       L_MONTH_END     := to_char ( i_FZGVC_PREL_OR_FINAL_ENDE, 'YYYYMM' );
       L_MONTH_CURRENT := L_MONTH_BEGIN;

       while to_number ( L_MONTH_CURRENT ) <= to_number ( L_MONTH_END )
       loop

            -- das erste monat wird nur dann verrechnet, wenn der tag, an dem der CO beginnt, vorm TargetDateCustomerInvoice - GS liegt oder gleich ist:
            if    L_MONTH_CURRENT = L_MONTH_BEGIN
            then  if    to_number ( to_char ( i_FZGVC_BEGINN, 'DD' )) <= L_GS_TargetDateCustomerInvoice
                  then  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
                  end   if;
            -- das letzte monat wird nur dann verrechnet, wenn der tag, an dem der CO endet, nach dem TargetDateCustomerInvoice - GS liegt:
            elsif L_MONTH_CURRENT = L_MONTH_END
            then  if    to_number ( to_char ( i_FZGVC_BEGINN, 'DD' )) >  L_GS_TargetDateCustomerInvoice
                  then  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
                  end   if;
            -- monate dazwischen einfach aufsummieren
            else  L_dblMPSum := L_dblMPSum + get_FZGPR_PREIS_MONATP;
            end   if;

            -- erhöhen current month um 1 monat
            L_MONTH_CURRENT := to_char ( add_months ( to_date ( L_MONTH_CURRENT, 'YYYYMM' ), 1 ), 'YYYYMM' );

       end loop;

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  -- wenn i_PAYM_TARGETDATE_CI = 1: tagesgenaue abrechnung:
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  -- jedes monat wird mit 30 tagen gerechnet - egal ob FEB, MAR oder APR usw.
  -- beginnt zb. ein CO an einem 31. eines Monats wird KEINE MP verrechnet.
  -- beginnt er an einem 30. eines Monats -> 1 Tag / an einem 29. -> 2 Tage - auch beim FEB
  -- beginnt er an einem 28. -> 3 Tage - auch beim FEB

  -- beispiel:
  -- CO beginnt am 4.2. und endet am 3.3. wobei für FEB eine MP von 100 EUR gilt, für MAR: 150
  -- FEB:   100.00 EUR / 30 tage * 27 tage ( 4.2. - 30.2.) =  90.00 EUR
  -- MAR:   150.00 EUR / 30 tage *  3 tage ( 1.3. -  3.3.) =  15.00 EUR
  -- summe:                                                = 105.00 EUR
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  elsif i_PAYM_TARGETDATE_CI = 1
  then for crec in ( select FZGPR_VON, FZGPR_BIS, FZGPR_PREIS_MONATP / 30 as FZGPR_PREIS_DAYP
                       from snt.TFZGPREIS_SIMEX
                      where i_ID_VERTRAG          = ID_VERTRAG
                        and i_ID_FZGVERTRAG       = ID_FZGVERTRAG
                   order by 1 )
       loop
           --- wenn preis VON vor CO BEGINN liegt: preis VON = CO BEGINN
           if   crec.FZGPR_VON < i_FZGVC_BEGINN
           then L_FZGPR_VON   := i_FZGVC_BEGINN;
           else L_FZGPR_VON   := crec.FZGPR_VON;
           end  if;

           --- wenn preis BIS nach CO ENDE liegt: preis BIS = CO ENDE
           if   crec.FZGPR_BIS > i_FZGVC_PREL_OR_FINAL_ENDE
           then L_FZGPR_BIS   := i_FZGVC_PREL_OR_FINAL_ENDE;
           else L_FZGPR_BIS   := crec.FZGPR_BIS;
           end  if;

           -- wenn preis VON der 31. eines monats ist, wird das ganze monat nicht verrechnet -> 1 tag vor
           if   to_char ( L_FZGPR_VON, 'DD' ) = '31'
           then L_FZGPR_VON := L_FZGPR_VON + 1;
           end  if;

           -- wenn preis BIS der 31. eines monats ist, wird nur bis zum 30. verrechnet -> 1 tag zurück
           if   to_char ( L_FZGPR_BIS, 'DD' ) = '31'
           then L_FZGPR_BIS := L_FZGPR_BIS - 1;
           end  if;

           --- feststellen wieviele vorschreibpflichtige tage im ersten und letzten preis - gültigkeitsmonat:
           L_DAYS_BEGIN_MONTH  := 30 - to_number ( to_char ( L_FZGPR_VON, 'DD' )) + 1;
           L_DAYS_END_MONTH    :=      to_number ( to_char ( L_FZGPR_BIS, 'DD' ));

           --- feststellen wieviele ganze monate dazwischen:
           L_MONTHS_BETWEEN := months_between ( last_day ( add_months ( L_FZGPR_BIS, -1 )) + 1
                                              , last_day (              L_FZGPR_VON      ) + 1 );

           --- betrag =  vorheriger betrag plus ...
           L_dblMPSum := L_dblMPSum + ( crec.FZGPR_PREIS_DAYP * L_DAYS_BEGIN_MONTH )          --- ... plus tages - rate * vorschreibpflichtiger tage im beginnmonat
                                    + ( crec.FZGPR_PREIS_DAYP * L_DAYS_END_MONTH   )          --- ... plus tages - rate * vorschreibpflichtiger tage im endemonat
                                    + ( crec.FZGPR_PREIS_DAYP * L_MONTHS_BETWEEN * 30 );      --- ... plus tages - rate * vorschreibpflichtiger tage in den monaten dazwischen
       end loop;
  end  if;

  -- SUBVENTION
  select nvl ( sum ( ci.CI_AMOUNT ), 0 )
    into L_dblSubventionSum
    from snt.TFZGV_CONTRACTS       co
       , snt.TCUSTOMER_INVOICE     ci
       , snt.TCUSTOMER_INVOICE_TYP custT
   where co.ID_VERTRAG               = i_ID_VERTRAG
     and co.ID_FZGVERTRAG            = i_ID_FZGVERTRAG
     and co.ID_SEQ_FZGVC             = ci.ID_SEQ_FZGVC
     and custT.GUID_CUSTINVTYPE      = ci.GUID_CUSTINVTYPE
     and custT.CUSTINVTYPE_STAT_CODE = '04';

  if   L_GS_RoundingMileageAmount is not null
  then return ( round ( L_dblMPSum + L_dblSubventionSum, L_GS_RoundingMileageAmount ));
  else return (         L_dblMPSum + L_dblSubventionSum                              );
  end  if;

end CO_REVENUE_AMOUNT;
/


-- e) berechnen und ausgeben ContractValue
select 'ContractValue of DB &&_CONNECT_IDENTIFIER.: ' 
    || to_char ( sum ( snt.CO_REVENUE_AMOUNT 
                            ( I_ID_VERTRAG               => fzgv.ID_VERTRAG
                            , I_ID_FZGVERTRAG            => fzgv.ID_FZGVERTRAG
                            , I_FZGVC_BEGINN             => fzgvc_start.FZGVC_BEGINN
                            , I_FZGVC_PREL_OR_FINAL_ENDE => fzgvc_ende1.FZGVC_PREL_OR_FINAL_ENDE
                            , I_PAYM_TARGETDATE_CI       => paym.PAYM_TARGETDATE_CI )), '999G999G999G990D00' ) 
  from snt.TDFPAYMODE          paym
     , snt.TFZGVERTRAG         fzgv
     , snt.TFZGV_CONTRACTS     fzgvc_start
     , ( select ende1.ID_VERTRAG
              , ende1.ID_FZGVERTRAG
              , ende1.ID_SEQ_FZGVC
              , ende1.ID_PAYM
              , get_FINAL_END_DATE ( ende1.ID_SEQ_FZGKMSTAND_END, ende1.FZGVC_ENDE )     as FZGVC_PREL_OR_FINAL_ENDE
              , get_FINAL_KM       ( ende1.ID_SEQ_FZGKMSTAND_END, ende1.FZGVC_ENDE_KM )  as FZGVC_PREL_OR_FINAL_ENDE_KM
           from snt.TFZGV_CONTRACTS   ende1
          where ende1.FZGVC_BEGINN           in ( select max ( ende2.FZGVC_BEGINN )
                                                    from snt.TFZGV_CONTRACTS   ende2
                                                   where ende1.ID_VERTRAG              = ende2.ID_VERTRAG
                                                     and ende1.ID_FZGVERTRAG           = ende2.ID_FZGVERTRAG )) fzgvc_ende1
 where fzgvc_ende1.ID_PAYM                 = paym.ID_PAYM
   and fzgvc_ende1.ID_VERTRAG              = fzgv.ID_VERTRAG
   and fzgvc_ende1.ID_FZGVERTRAG           = fzgv.ID_FZGVERTRAG
   and fzgvc_start.ID_VERTRAG              = fzgv.ID_VERTRAG
   and fzgvc_start.ID_FZGVERTRAG           = fzgv.ID_FZGVERTRAG
   and fzgvc_start.FZGVC_BEGINN           in ( select min ( start2.FZGVC_BEGINN )
                                                 from snt.TFZGV_CONTRACTS   start2
                                                where fzgvc_start.ID_VERTRAG          = start2.ID_VERTRAG
                                                  and fzgvc_start.ID_FZGVERTRAG       = start2.ID_FZGVERTRAG )
/

prompt

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off
rollback;
-- < delete following code between begin and end if data is selected only >

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < enable again all perhaps in step 0 disabled constraints or triggers >
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )
truncate table snt.TFZGPREIS_SIMEX;
drop table snt.TFZGPREIS_SIMEX cascade constraints purge;
drop function snt.CO_REVENUE_AMOUNT;

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- report final / finished message and exit
set termout  on

/*
begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
   dbms_output.put_line ( chr(10) || 'finished.' || chr(10) );
 end if;
 
 dbms_output.put_line ( :nachricht );
 
 if upper('&&GL_LOGFILETYPE')<>'CSV' then

  dbms_output.put_line (chr(10));
  dbms_output.put_line ('Please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed' );  
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
*/

exit;