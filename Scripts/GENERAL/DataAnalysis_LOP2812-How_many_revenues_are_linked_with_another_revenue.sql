-- DataAnalysis_LOP2812-How_many_revenues_are_linked_with_another_revenue.sql
-- FraBe      05.12.2013 MKS-129996:1 / LOP2812

spool DataAnalysis_LOP2812-How_many_revenues_are_linked_with_another_revenue.log

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
exec :L_SCRIPTNAME       := 'DataAnalysis_LOP2812-How_many_revenues_are_linked_with_another_revenue.sql';

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
   L_MPC_CHECK             boolean                         := false;           -- false or true
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

col ID_VERTRAG                  form a10
col ID_FZGVERTRAG               form a13
col ID_PARTNER                  form a12
col NAME_MATCHCODE              form a50
col CI_DATE                     form a10
col CI_AMOUNT                   form a16
col CI_DOCUMENT_NUMBER          form a18
col BELART_SHORTCAP             form a6   head "I Type"
col CUSTINVTYPE_SHORT_CAPTION   form a7   head "CI Type"
col MEMO                        form a90

col ID_VERTRAG_REF                  form a14
col ID_FZGVERTRAG_REF               form a17
col ID_PARTNER_REF                  form a14
col NAME_MATCHCODE_REF              form a50
col CI_AMOUNT_REF                   form a16
col CI_DOCUMENT_NUMBER_REF          form a25
col CI_DATE_REF                     form a11
col BELART_SHORTCAP_REF             form a10  head "I-Type REF"
col CUSTINVTYPE_SHORT_CAPTION_REF   form a11  head "CI-Type REF"
col MEMO_REF                        form a90

select /*+ index ( ci XIFCI_REFERENZBUCHUNG ) index ( fzgvc XPKTFZGV_CONTRACTS ) index ( fzgvc_ref XPKTFZGV_CONTRACTS ) */
           fzgvc.ID_VERTRAG
     ,     fzgvc.ID_FZGVERTRAG
     , fzgvc_ref.ID_VERTRAG               as ID_VERTRAG_REF
     , fzgvc_ref.ID_FZGVERTRAG            as ID_FZGVERTRAG_REF
     ,     vp.ID_PARTNER
     , vp_ref.ID_PARTNER                  as ID_PARTNER_REF
     ,     vp.NAME_MATCHCODE
     , vp_ref.NAME_MATCHCODE              as NAME_MATCHCODE_REF
     ,     ci.CI_DOCUMENT_NUMBER
     , ci_ref.CI_DOCUMENT_NUMBER          as CI_DOCUMENT_NUMBER_REF
     , to_char (     ci.CI_DATE,   'DD.MM.YYYY' )      as CI_DATE
     , to_char ( ci_ref.CI_DATE,   'DD.MM.YYYY' )      as CI_DATE_REF
     , to_char (     ci.CI_AMOUNT, '9999G999G990D00' ) as CI_AMOUNT
     , to_char ( ci_ref.CI_AMOUNT, '9999G999G990D00' ) as CI_AMOUNT_REF
     ,     ba.BELART_SHORTCAP
     , ba_ref.BELART_SHORTCAP                   as BELART_SHORTCAP_REF
     ,     cit.CUSTINVTYPE_SHORT_CAPTION
     , cit_ref.CUSTINVTYPE_SHORT_CAPTION        as CUSTINVTYPE_SHORT_CAPTION_REF
     ,     ci.CI_MEMO                           as MEMO
     , ci_ref.CI_MEMO                           as MEMO_REF
  from snt.TCUSTOMER_INVOICE_TYP   cit_ref
     , snt.TBELEGARTEN             ba_ref
     , snt.VPARTNER                vp_ref
     , snt.TDFCONTR_VARIANT        cvar_ref
     , snt.TFZGV_CONTRACTS         fzgvc_ref
     , snt.TCUSTOMER_INVOICE       ci_ref
     , snt.TCUSTOMER_INVOICE_TYP   cit
     , snt.TBELEGARTEN             ba
     , snt.VPARTNER                vp
     , snt.TDFCONTR_VARIANT        cvar
     , snt.TFZGV_CONTRACTS         fzgvc
     , snt.TCUSTOMER_INVOICE       ci
 where cvar.COV_CAPTION not like 'MIG_OOS%'
   and cvar.ID_COV             = fzgvc.ID_COV
   and ci.ID_SEQ_FZGVC         = fzgvc.ID_SEQ_FZGVC
   and ci.GUID_PARTNER         = vp.GUID_PARTNER
   and ci.ID_BELEGART          = ba.ID_BELEGART 
   and ci.GUID_CUSTINVTYPE     = cit.GUID_CUSTINVTYPE
   and ci.CI_REFERENCE_NUMBER is not null
   and ci.CI_REFERENCE_NUMBER  = ci_ref.GUID_CI (+)
   and cvar_ref.COV_CAPTION (+) not like 'MIG_OOS%'
   and cvar_ref.ID_COV      (+)        = fzgvc_ref.ID_COV
   and ci_ref.ID_SEQ_FZGVC             = fzgvc_ref.ID_SEQ_FZGVC (+)
   and ci_ref.GUID_PARTNER             = vp_ref.GUID_PARTNER (+)
   and ci_ref.ID_BELEGART              = ba_ref.ID_BELEGART (+)
   and ci_ref.GUID_CUSTINVTYPE         = cit_ref.GUID_CUSTINVTYPE (+)
 order by ci.CI_DATE desc, vp.ID_PARTNER;
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >

-- < enable again all perhaps in step 0 disabled constraints or triggers >

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataAnalysis_LOP2812-How_many_revenues_are_linked_with_another_revenue.log
prompt

exit;
