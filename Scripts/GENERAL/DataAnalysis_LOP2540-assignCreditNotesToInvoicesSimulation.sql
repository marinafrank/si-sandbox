-- DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.sql

-- FraBe 26.04.2013 MKS-124746:1 creation
-- FraBe 03.03.2014 MKS-131547:1 a) neuer name DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation (-> mit DataAnalysis_LOP2540- präfix )
--                               b) nicht mehr an einen MKS attached (-> das alte script hängte am MKS-124746 ), sondern ins iCON scripts general MKS eingecheckt
--                               c) nur INV mit abgelehnten beträgen werden vorgeschlagen (->  round ( FZGRE_SUM_REJECTED, 2 ) <> 0 )

spool DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.log

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
exec :L_SCRIPTNAME       := 'Template.sql';

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
   L_MINOR_MIN             integer := 7;
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

set feedback     on
set feedback     1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- legend: 
-- this script searches for Workshop CreditNotes (-> CN ) which are not related to a Workshop Invoice ( -> INV ) yet using 2  SEARCH_TYPE routines:
-- '1': the CN and INV have the same ID_VERTRAG / ID_FZGVERTRAG / FZGRE_LAUFSTRECKE (-> mileage ) / FZGRE_REPDATUM (-> RepairDate )
-- '2': the CN and INV have the same ID_VERTRAG / ID_FZGVERTRAG / and the INV - FZGRE_BELEGNR (-> DocumentNumber ) can be found in CN - FZGRE_MEMO (-> memo )
--      but only complete number matches e.g. DocumentNumber 12345 in MemoField 'agfsfqwew 12345' 
--      but no DocumentNumber 123 in the same MemoFiled (-> this DocumentNumber ist only part of the whole number )
--
-- these 2 types are split into 3 subtypes (- the 1st char is the main SEARCH_TYPE, the chars after the 2nd char '-' are the subtypes. e.g: 1-0 or 2-I or 1-III )
-- 0:    Gutfall:          exact 1 INV can be found for the CN
-- I:    Schlechtfall I:   more than 1 INV can be found for the CN
-- II:   Schlechtfall II:  exact 1 INV can be found for more than 1 CN
-- III:  Schlechtfall III: more than 1 INV were found for more than 1 CN
--
-- additional main search SEARCH_TYPE routines without any subtype:
-- '3':  the INV found for the CN using SEARCH_TYPE = '1' differ to those of SEARCH_TYPE = '2'
-- '4':  no INV could be found for the CN
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A) only CN / INV of InScope contracts are considered
-- B) only INV which are not totally accepted are proposed
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2 temporary tables are used:
-- a) TLOP2540_CN_witout_ref_INV: for all CN without any INV reference
-- b) TLOP2540_INV_of_CN:         for all INV found during search types '1' to '4'
--
-- 1st they are dropped (- as script was already executed in the past -)
-- 2nd they are (re)created
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A) create / fill TLOP2540_CN_witout_ref_INV with CN without INV reference
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1st: drop perhaps already existing temporary table (- as script was already executed in the past -)
begin
    execute immediate 'drop table snt.TLOP2540_CN_witout_ref_INV';
exception when others then null;
end;
/

-- 2nd: (re)create temporary table and fill it with the CN without any reference to any INV
-- has to be done for the 2 main SEARCH_TYPE '1' and '2' separately (-> needed within calculating the sub search types later )
create table snt.TLOP2540_CN_witout_ref_INV tablespace snt as
select '1'                    as SEARCH_TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , r.ID_SEQ_FZGRECHNUNG   as ID_SEQ_FZGRECHNUNG_CN                -- SIRIUS internal DocumentNo of the CN
     , r.FZGRE_BELEGNR        as FZGRE_BELEGNR_CN                     -- DocumentNo of the CN
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_REPDATUM
     , r.FZGRE_MEMO
     , '1'                    as CN_COUNT                             -- default value for CN_COUNT / will perhaps be set to 'n' in D) below
  from snt.TDFCONTR_VARIANT    cv
     , snt.TFZGV_CONTRACTS     c
     , snt.TFZGRECHNUNG        r
     , snt.TBELEGARTEN         ba
 where cv.COV_CAPTION          not like 'MIG_OOS%'
   and cv.ID_COV                = c.ID_COV
   and r.ID_SEQ_FZGVC           = c.ID_SEQ_FZGVC
   and r.FZGRE_REFERENZBUCHUNG is null
   and r.ID_BELEGART            = ba.ID_BELEGART
   and 1                        = ba.BELART_INVOICE_OR_CNOTE
 union
select '2'                    as SEARCH_TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , r.ID_SEQ_FZGRECHNUNG   as ID_SEQ_FZGRECHNUNG_CN
     , r.FZGRE_BELEGNR        as FZGRE_BELEGNR_CN
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_REPDATUM
     , r.FZGRE_MEMO
     , '1'                    as CN_COUNT
  from snt.TDFCONTR_VARIANT    cv
     , snt.TFZGV_CONTRACTS     c
     , snt.TFZGRECHNUNG        r
     , snt.TBELEGARTEN         ba
 where cv.COV_CAPTION          not like 'MIG_OOS%'
   and cv.ID_COV                = c.ID_COV
   and r.ID_SEQ_FZGVC           = c.ID_SEQ_FZGVC
   and r.FZGRE_REFERENZBUCHUNG is null
   and r.ID_BELEGART            = ba.ID_BELEGART
   and 1                        = ba.BELART_INVOICE_OR_CNOTE
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- B) create temporary table for all INV proposals which will be found later to perhaps refer to the CN which were found in prev step
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1st: drop perhaps already existing temporary table (- as script was already executed in the past -)
begin
    execute immediate 'drop table snt.TLOP2540_INV_of_CN';
exception when others then null;
end;
/

-- 2nd: (re)create empty temporary table
create table snt.TLOP2540_INV_of_CN
     ( SEARCH_TYPE                  varchar2 (    1 char )
     , INV_COUNT                    varchar2 (    1 char )  default '1'               -- will perhaps be set to 'n' in step C) below
     , ID_VERTRAG                   varchar2 (  100 char )
     , ID_FZGVERTRAG                varchar2 (  100 char )
     , ID_SEQ_FZGRECHNUNG_CN_REF    integer                                           -- SIRIUS internal DocumentNo of the CN where the INV refers to
     , FZGRE_BELEGNR_CN_REF         varchar2 (  100 char )                            -- DocumentNo of the CN where the INV refers to
     , ID_SEQ_FZGRECHNUNG_INV       integer                                           -- SIRIUS internal DocumentNo of the INV
     , FZGRE_BELEGNR_INV            varchar2 (  100 char )                            -- DocumentNo of the INV
     , FZGRE_LAUFSTRECKE            number
     , FZGRE_REPDATUM               date
     , FZGRE_MEMO                   varchar2 ( 4000 char )                            -- this column indeed isn't needed for an INV, but as we need it within the CN we use it here as well to show it on the reports
     , constraint PK_TLOP2540_INV_of_CN PRIMARY KEY ( ID_SEQ_FZGRECHNUNG_CN_REF, SEARCH_TYPE, ID_SEQ_FZGRECHNUNG_INV ) using index tablespace sntidx
     ) tablespace snt
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- C) search for the INV and store them into table created in prev step
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
def  SEARCH_TYPE  = '1'
begin

     for crec in ( select ID_SEQ_FZGRECHNUNG_CN
                        , FZGRE_BELEGNR_CN
                        , ID_VERTRAG
                        , ID_FZGVERTRAG
                        , FZGRE_LAUFSTRECKE
                        , FZGRE_REPDATUM
                        , FZGRE_MEMO 
                     from snt.TLOP2540_CN_witout_ref_INV
                    where SEARCH_TYPE = '&&SEARCH_TYPE' 
                  order by 1, 3, 4 )
     loop
     
         if   '&&SEARCH_TYPE' = '1'
         then -- '1': search all INV with same ID_VERTRAG / ID_FZGVERTRAG / FZGRE_LAUFSTRECKE / and FZGRE_REPDATUM
              for c1rec in ( select r.ID_SEQ_FZGRECHNUNG
                                  , r.FZGRE_BELEGNR
                                  , r.FZGRE_MEMO
                                  , r.FZGRE_LAUFSTRECKE
                                  , r.FZGRE_REPDATUM
                               from snt.TDFCONTR_VARIANT    cv
                                  , snt.TBELEGARTEN         ba
                                  , snt.TFZGV_CONTRACTS     c
                                  , snt.TFZGRECHNUNG        r
                              where cv.COV_CAPTION         not like 'MIG_OOS%'
                                and cv.ID_COV                = c.ID_COV
                                and r.ID_SEQ_FZGVC           = c.ID_SEQ_FZGVC
                                and r.ID_BELEGART            = ba.ID_BELEGART
                                and 0                        = ba.BELART_INVOICE_OR_CNOTE
                                and r.ID_VERTRAG             = crec.ID_VERTRAG       
                                and r.ID_FZGVERTRAG          = crec.ID_FZGVERTRAG    
                                and r.FZGRE_LAUFSTRECKE      = crec.FZGRE_LAUFSTRECKE
                                and r.FZGRE_REPDATUM         = crec.FZGRE_REPDATUM
                                and round ( r.FZGRE_SUM_REJECTED, 2 ) <> 0 )
              loop
                  insert into snt.TLOP2540_INV_of_CN
                         ( SEARCH_TYPE
                         , ID_VERTRAG
                         , ID_FZGVERTRAG
                         , ID_SEQ_FZGRECHNUNG_CN_REF
                         , FZGRE_BELEGNR_CN_REF
                         , ID_SEQ_FZGRECHNUNG_INV
                         , FZGRE_BELEGNR_INV
                         , FZGRE_LAUFSTRECKE
                         , FZGRE_REPDATUM
                         , FZGRE_MEMO )
                  values ( '1'
                         , crec.ID_VERTRAG
                         , crec.ID_FZGVERTRAG
                         , crec.ID_SEQ_FZGRECHNUNG_CN
                         , crec.FZGRE_BELEGNR_CN
                         , c1rec.ID_SEQ_FZGRECHNUNG
                         , c1rec.FZGRE_BELEGNR
                         , c1rec.FZGRE_LAUFSTRECKE
                         , c1rec.FZGRE_REPDATUM
                         , c1rec.FZGRE_MEMO );
                  
              end loop;
         -----------------------------------------------------------------------------------------------------------------------------------
         elsif  '&&SEARCH_TYPE' = '2'
         then -- '2' search for INV where the document number FZGRE_BELEGNR can be found in the CN memotext FZGRE_MEMO
              for c2rec in ( select r.ID_SEQ_FZGRECHNUNG
                                  , r.FZGRE_BELEGNR
                                  , r.FZGRE_MEMO
                                  , r.FZGRE_LAUFSTRECKE
                                  , r.FZGRE_REPDATUM
                               from snt.TDFCONTR_VARIANT    cv
                                  , snt.TBELEGARTEN         ba
                                  , snt.TFZGV_CONTRACTS     c
                                  , snt.TFZGRECHNUNG        r
                              where cv.COV_CAPTION         not like 'MIG_OOS%'
                                and cv.ID_COV                = c.ID_COV
                                and r.ID_SEQ_FZGVC           = c.ID_SEQ_FZGVC
                                and r.ID_BELEGART            = ba.ID_BELEGART
                                and 0                        = ba.BELART_INVOICE_OR_CNOTE
                                and r.ID_VERTRAG             = crec.ID_VERTRAG       
                                and r.ID_FZGVERTRAG          = crec.ID_FZGVERTRAG
                                and round ( r.FZGRE_SUM_REJECTED, 2 ) <> 0
                                and instr ( ' ' || crec.FZGRE_MEMO || ' ', ' ' || r.FZGRE_BELEGNR || ' ' ) > 0 )   -- lpad and rpad a blank char to get complete DucumentNumber only
              loop
                  insert into snt.TLOP2540_INV_of_CN
                         ( SEARCH_TYPE
                         , ID_VERTRAG
                         , ID_FZGVERTRAG
                         , ID_SEQ_FZGRECHNUNG_CN_REF
                         , FZGRE_BELEGNR_CN_REF
                         , ID_SEQ_FZGRECHNUNG_INV
                         , FZGRE_BELEGNR_INV
                         , FZGRE_LAUFSTRECKE
                         , FZGRE_REPDATUM
                         , FZGRE_MEMO )
                  values ( '2'
                         , crec.ID_VERTRAG
                         , crec.ID_FZGVERTRAG
                         , crec.ID_SEQ_FZGRECHNUNG_CN
                         , crec.FZGRE_BELEGNR_CN
                         , c2rec.ID_SEQ_FZGRECHNUNG
                         , c2rec.FZGRE_BELEGNR
                         , c2rec.FZGRE_LAUFSTRECKE
                         , c2rec.FZGRE_REPDATUM
                         , c2rec.FZGRE_MEMO );

              end loop;
         end  if;
         
         -- store info if more than one (-> 'n' ) INV were found for the CN (-> needed for calculating the sub search types later )
         -- an update to 'only one' (-> '1' ) has not to be done as this is the default value already 
         -- (-> the column INV_COUNT was created with default '1' during creation of temporary table snt.TLOP2540_INV_of_CN above )
         update snt.TLOP2540_INV_of_CN inv
            set INV_COUNT = 'n'
          where inv.SEARCH_TYPE = '&&SEARCH_TYPE' 
            and inv.ID_SEQ_FZGRECHNUNG_CN_REF = crec.ID_SEQ_FZGRECHNUNG_CN
            and exists ( select count(*) from snt.TLOP2540_INV_of_CN inv1
                          where inv1.SEARCH_TYPE = '&&SEARCH_TYPE' 
                            and inv1.ID_SEQ_FZGRECHNUNG_CN_REF = inv.ID_SEQ_FZGRECHNUNG_CN_REF
                         having count(*) <> 1 );

     end loop;
end;
/          

def SEARCH_TYPE = '2'
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- D) if more than one INV was found for a CN the INV_COUNT was set to 'n' in update of prev step
-- this has to be done vice versa as well if more than one CN was found for an INV: set CN_COUNT to 'n'
-- (-> needed for calculating the sub search types later )
-- it has to be done separately for SEARCH_TYPE = '1' / '2' due to different logic:
-- '1': same FZGRE_LAUFSTRECKE and FZGRE_REPDATUM
-- '2': the INV - FZGRE_BELEGNR must be found in the CN MemoField
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
update snt.TLOP2540_CN_witout_ref_INV cn
   set cn.CN_COUNT = 'n'
 where cn.SEARCH_TYPE  = '1'
   and exists ( select null 
                  from snt.TLOP2540_INV_of_CN inv
                 where cn.SEARCH_TYPE        = inv.SEARCH_TYPE
                   and cn.ID_VERTRAG         = inv.ID_VERTRAG
                   and cn.ID_FZGVERTRAG      = inv.ID_FZGVERTRAG
                   and cn.FZGRE_LAUFSTRECKE  = inv.FZGRE_LAUFSTRECKE
                   and cn.FZGRE_REPDATUM     = inv.FZGRE_REPDATUM
                   and cn.FZGRE_BELEGNR_CN   = inv.FZGRE_BELEGNR_CN_REF
                   and exists ( select null 
                                  from snt.TLOP2540_INV_of_CN inv1
                                 where inv1.SEARCH_TYPE           = inv.SEARCH_TYPE
                                   and inv1.ID_VERTRAG            = inv.ID_VERTRAG
                                   and inv1.ID_FZGVERTRAG         = inv.ID_FZGVERTRAG
                                   and inv1.FZGRE_LAUFSTRECKE     = inv.FZGRE_LAUFSTRECKE
                                   and inv1.FZGRE_REPDATUM        = inv.FZGRE_REPDATUM
                                   and inv1.FZGRE_BELEGNR_INV     = inv.FZGRE_BELEGNR_INV
                                   and inv1.FZGRE_BELEGNR_CN_REF <> cn.FZGRE_BELEGNR_CN
                                   ))
/

update snt.TLOP2540_CN_witout_ref_INV cn
   set cn.CN_COUNT = 'n'
 where cn.SEARCH_TYPE  = '2'
   and exists ( select null 
                  from snt.TLOP2540_INV_of_CN inv
                 where cn.SEARCH_TYPE       = inv.SEARCH_TYPE
                   and cn.ID_VERTRAG        = inv.ID_VERTRAG
                   and cn.ID_FZGVERTRAG     = inv.ID_FZGVERTRAG
                   and instr ( ' ' || cn.FZGRE_MEMO || ' ', ' ' || inv.FZGRE_BELEGNR_INV || ' ' ) > 0
                   and cn.FZGRE_BELEGNR_CN  = inv.FZGRE_BELEGNR_CN_REF
                   and exists ( select null 
                                  from snt.TLOP2540_INV_of_CN inv1
                                 where inv1.SEARCH_TYPE            = inv.SEARCH_TYPE
                                   and inv1.ID_VERTRAG             = inv.ID_VERTRAG
                                   and inv1.ID_FZGVERTRAG          = inv.ID_FZGVERTRAG
                                   and instr ( ' ' || cn.FZGRE_MEMO || ' ', ' ' || inv1.FZGRE_BELEGNR_INV || ' ' ) > 0   -- lpad and rpad a blank char to get complete DucumentNumber only
                                   and inv1.FZGRE_BELEGNR_INV      = inv.FZGRE_BELEGNR_INV
                                   and inv1.FZGRE_BELEGNR_CN_REF  <> cn.FZGRE_BELEGNR_CN ))
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- the following CN is a special MBBEL - case which cannot be handeled using code above
-- therefore it has to be done manually
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
update  snt.TLOP2540_INV_of_CN 
   set INV_COUNT                 = 'n'
 where ID_VERTRAG                = '011673'
   and ID_FZGVERTRAG             = '0001'
   and SEARCH_TYPE               = '2'
   and ID_SEQ_FZGRECHNUNG_CN_REF = 338914
   and ID_SEQ_FZGRECHNUNG_INV    = 338908
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E) some pre - report actions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

col SV_SORT                 noprint 

col TYPE                    form a5           head "TYPE"
col ID_SEQ_FZGRECHNUNG_CN                     head "SIRIUS DocumentNo CN"
col ID_SEQ_FZGRECHNUNG_INV                    head "SIRIUS DocumentNo INV"

col ID_VERTRAG              form a6           head "SC"
col ID_FZGVERTRAG           form a4           head "Pos"
col ID_SEQ_FZGRECHNUNG                        head "SIRIUS DocumentNo"
col BELART_INVOICE_OR_CNOTE form a4           head "Type" 
col FZGRE_BELEGNR           form a10          head "DocumentNo"
col FZGRE_DOCUMENT_NUMBER2  form a11          head "DocumentNo2"
col ID_GARAGE               form 999999999
col FZGRE_BELEGDATUM        form a10          head "InvDate"
col FZGRE_REPDATUM          form a10          head "RepairDate"
col FZGRE_LAUFSTRECKE       form 9,999,990    head "Mileage"
col FZGRE_RESUMME           form   999,990.99 head "ValueTotal"
col FZGRE_SUM_REJECTED      form     9,990.99 head "Rejected"
                                                                                    -- col FZGRE_REFERENZBUCHUNG shows the (- almost -) INV where the CN / INV refers to
col FZGRE_REFERENZBUCHUNG   form 999999999    head "DocumentNoREF"
                                                                                    -- col AlreadyReferenced shows all CN / INV where the CN / INV is refered from
col AlreadyReferenced       form a21          head "AlreadyReferencedFrom"
col FZGRE_CREATOR           form a10          head "Creator"
col FZGRE_CREATED           form a10          head "Created"
col ID_IMP_TYPE             form 99           head "ID_imp"
col FZGRE_CONTROL_STATE     form 9            head "ControlState"
col FZGRE_FORWARD_ACC       form 9            head "Forwarded"
col ANZAHL                  form 999          head "count"
col FZGRE_MEMO              form a362         head "MEMO"

set termout off

spool DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.lst

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F) create the reports for the different main and sub search types
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

prompt
prompt 1-0: For following one CN exact one INV was found with same Mileage and RepairDate
prompt
def TYPE          = '1-0'
def SEARCH_TYPE   = '1'
def CN_COUNT      = '1'
def INV_COUNT     = '1'

-- most of the following reports are ordered by ID_VERTRAG / ID_FZGVERTRAG / ID_SEQ_FZGRECHNUNG_CN / BELART_INVOICE_OR_CNOTE / ID_BELEGART / ID_SEQ_FZGRECHNUNG
-- and if the SIRIUS DocumentNumber of the CN changes a new header is created due to better readability
break on ID_SEQ_FZGRECHNUNG_CN skip page duplicates

-- 1st CN
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where r.GUID_PARTNER                = p.GUID_PARTNER
   and r.ID_SEQ_FZGRECHNUNG          = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
-- 2nd INV
 union   
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
order by 2, 3, 4, 7, 6, 5
/

prompt
prompt 2-0: For following one CN exact one INV was found acording invoicenumber in the CN memofield:
prompt
def TYPE          = '2-0'
def SEARCH_TYPE   = '2'
def CN_COUNT      = '1'
def INV_COUNT     = '1'
/

prompt
prompt 1-I: For following one CN more than one INV was found with same Mileage and RepairDate:
prompt
def TYPE          = '1-I'
def SEARCH_TYPE   = '1'
def CN_COUNT      = '1'
def INV_COUNT     = 'n'
/

prompt
prompt 2-I: For following one CN more than one INV was found acording invoicenumber in the CN memofield:
prompt
def TYPE          = '2-I'
def SEARCH_TYPE   = '2'
def CN_COUNT      = '1'
def INV_COUNT     = 'n'
/


-- the 1-II and 2-II (-> for CNs exact one INV was found  ) reports are ordered a little bit different to the other reports due to better readability
-- by ID_VERTRAG / ID_FZGVERTRAG / ID_SEQ_FZGRECHNUNG_INV / BELART_INVOICE_OR_CNOTE / ID_BELEGART / ID_SEQ_FZGRECHNUNG
-- and if the SIRIUS DocumentNumber of the INV changes a new header is created
break on ID_SEQ_FZGRECHNUNG_INV skip page duplicates

prompt
prompt 1-II: for following CNs exact one INV was found with same Mileage and RepairDate:
prompt
def TYPE          = '1-II'
def SEARCH_TYPE   = '1'
def CN_COUNT      = 'n'
def INV_COUNT     = '1'
-- 1st CN
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , inv.ID_SEQ_FZGRECHNUNG_INV
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where r.GUID_PARTNER                = p.GUID_PARTNER
   and r.ID_SEQ_FZGRECHNUNG          = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
-- 2nd INV
 union   
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , inv.ID_SEQ_FZGRECHNUNG_INV
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
order by 2, 3, 4, 7, 6, 5
/

prompt
prompt 2-II: for following CNs exact one INV was found acording invoicenumber in the CN memofield:
prompt
def TYPE          = '2-II'
def SEARCH_TYPE   = '2'
def CN_COUNT      = 'n'
def INV_COUNT     = '1'
/

-- the 1-III report is ordered a little bit different to the other reports due to better readability
-- by ID_VERTRAG / ID_FZGVERTRAG / FZGRE_REPDATUM / FZGRE_LAUFSTRECKE / ID_SEQ_FZGRECHNUNG_CN / BELART_INVOICE_OR_CNOTE / ID_BELEGART / ID_SEQ_FZGRECHNUNG
-- and if at least one ID_VERTRAG / ID_FZGVERTRAG / FZGRE_REPDATUM / or FZGRE_LAUFSTRECKE of the CN / INV changes a new header is created
break on SV_SORT skip page duplicates

prompt
prompt 1-III: For following CNs more than one INV was found with same Mileage and RepairDate:
prompt
def TYPE          = '1-III'
def SEARCH_TYPE   = '1'
def CN_COUNT      = 'n'
def INV_COUNT     = 'n'
-- 1st CN
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG  || '/' || r.ID_FZGVERTRAG || '/' || to_char ( r.FZGRE_REPDATUM, 'YYYY.MM.DD' ) || '/' || to_char ( r.FZGRE_LAUFSTRECKE, '9999999999' ) as  SV_SORT
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where r.GUID_PARTNER                = p.GUID_PARTNER
   and r.ID_SEQ_FZGRECHNUNG          = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
-- 2nd INV
 union   
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG  || '/' || r.ID_FZGVERTRAG || '/' || to_char ( r.FZGRE_REPDATUM, 'YYYY.MM.DD' ) || '/' || to_char ( r.FZGRE_LAUFSTRECKE, '9999999999' ) as  SV_SORT
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
order by 2, 5, 8, 7, 6
/

-- the 2-III report is ordered a little bit different to the other reports due to better readability
-- by ID_VERTRAG / ID_FZGVERTRAG / ID_SEQ_FZGRECHNUNG_CN / BELART_INVOICE_OR_CNOTE / ID_BELEGART / ID_SEQ_FZGRECHNUNG
-- and if at least one ID_VERTRAG or ID_FZGVERTRAG of the CN / INV changes a new header is created
prompt
prompt 2-III: For following CNs more than one INV was found acording invoicenumber in the CN memofield:
prompt
def TYPE          = '2-III'
def SEARCH_TYPE   = '2'
def CN_COUNT      = 'n'
def INV_COUNT     = 'n'
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG  || '/' || r.ID_FZGVERTRAG      as SV_SORT
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where r.GUID_PARTNER                = p.GUID_PARTNER
   and r.ID_SEQ_FZGRECHNUNG          = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
-- 2nd INV
 union   
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG  || '/' || r.ID_FZGVERTRAG      as SV_SORT 
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = cn.ID_SEQ_FZGRECHNUNG_CN
   and inv.SEARCH_TYPE               = '&&SEARCH_TYPE'
   and cn.SEARCH_TYPE                = '&&SEARCH_TYPE'
   and inv.INV_COUNT                 = '&&INV_COUNT'
   and cn.CN_COUNT                   = '&&CN_COUNT'
order by 2, 5, 8, 7, 6
/

-- the '3' report is ordered a little bit different to the other reports due to better readability
-- by ID_VERTRAG / ID_FZGVERTRAG / ID_SEQ_FZGRECHNUNG_CN / BELART_INVOICE_OR_CNOTE / ID_BELEGART / ID_SEQ_FZGRECHNUNG
-- and if the SIRIUS DocumentNumber of the CN changes a new header is created due to better readability
break on ID_SEQ_FZGRECHNUNG_CN skip page duplicates

prompt
prompt 3: Following INV are proposed different in 1 and 2:
prompt
def TYPE          = '3'
-- 1st: CN
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
 where r.GUID_PARTNER                = p.GUID_PARTNER
   and r.ID_SEQ_FZGRECHNUNG          = cn.ID_SEQ_FZGRECHNUNG_CN
   and '1'                           = cn.SEARCH_TYPE                            -- also '2' could be used - it doesn't mind which one is used
   and exists ( select null                                                      -- an INV with same FZGRE_LAUFSTRECKE and FZGRE_REPDATUM has to be found for the CN using SEARCH_TYPE routine '1'
                  from snt.TLOP2540_INV_of_CN  inv1
                 where '1'                      = inv1.SEARCH_TYPE
                   and cn.ID_SEQ_FZGRECHNUNG_CN = inv1.ID_SEQ_FZGRECHNUNG_CN_REF
                   and cn.FZGRE_LAUFSTRECKE     = inv1.FZGRE_LAUFSTRECKE
                   and cn.FZGRE_REPDATUM        = inv1.FZGRE_REPDATUM )
   and exists ( select null
                  from snt.TLOP2540_INV_of_CN  inv2
                 where '2'                      = inv2.SEARCH_TYPE               -- an INV with different FZGRE_LAUFSTRECKE or FZGRE_REPDATUM has to be found for the CN using SEARCH_TYPE routine '2'
                   and cn.ID_SEQ_FZGRECHNUNG_CN = inv2.ID_SEQ_FZGRECHNUNG_CN_REF
                   and ( cn.FZGRE_LAUFSTRECKE  <> inv2.FZGRE_LAUFSTRECKE
                      or cn.FZGRE_REPDATUM     <> inv2.FZGRE_REPDATUM ))
-- 2nd: INV of SEARCH_TYPE = '1'
 union
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , inv.ID_SEQ_FZGRECHNUNG_CN_REF                as ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and '1'                           = inv.SEARCH_TYPE
   and exists ( select null                                                             -- also an INV with different FZGRE_LAUFSTRECKE or FZGRE_REPDATUM has to be found for the CN using SEARCH_TYPE routine '2'
                  from snt.TLOP2540_INV_of_CN  inv2
                 where '2'                           = inv2.SEARCH_TYPE
                   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = inv2.ID_SEQ_FZGRECHNUNG_CN_REF
                   and ( inv.FZGRE_LAUFSTRECKE      <> inv2.FZGRE_LAUFSTRECKE
                      or inv.FZGRE_REPDATUM         <> inv2.FZGRE_REPDATUM ))
-- 3rd: INV of SEARCH_TYPE = '2'
 union
select '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , inv.ID_SEQ_FZGRECHNUNG_CN_REF                as ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'INV'                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_INV_of_CN          inv
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and inv.ID_SEQ_FZGRECHNUNG_INV    = r.ID_SEQ_FZGRECHNUNG
   and '2'                           = inv.SEARCH_TYPE
   and exists ( select null                                                             -- also an INV with different FZGRE_LAUFSTRECKE or FZGRE_REPDATUM has to be found for the CN using SEARCH_TYPE routine '1'
                  from snt.TLOP2540_INV_of_CN  inv1
                 where '1'                           = inv1.SEARCH_TYPE
                   and inv.ID_SEQ_FZGRECHNUNG_CN_REF = inv1.ID_SEQ_FZGRECHNUNG_CN_REF
                   and ( inv.FZGRE_LAUFSTRECKE      <> inv1.FZGRE_LAUFSTRECKE
                      or inv.FZGRE_REPDATUM         <> inv1.FZGRE_REPDATUM ))
order by 2, 3, 4, 7, 6, 5
/

prompt
prompt 4: For following CN no matching INV could be found:
prompt

def TYPE = '4'

select distinct
       '&&TYPE'   as TYPE
     , r.ID_VERTRAG
     , r.ID_FZGVERTRAG
     , cn.ID_SEQ_FZGRECHNUNG_CN
     , r.ID_SEQ_FZGRECHNUNG
     , r.ID_BELEGART
     , 'CN '                                        as BELART_INVOICE_OR_CNOTE
     , r.FZGRE_BELEGNR
     , r.FZGRE_DOCUMENT_NUMBER2
     , p.ID_GARAGE
     , to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) as FZGRE_BELEGDATUM
     , to_char ( r.FZGRE_REPDATUM,   'DD.MM.YYYY' ) as FZGRE_REPDATUM
     , r.FZGRE_LAUFSTRECKE
     , r.FZGRE_RESUMME
     , r.FZGRE_SUM_REJECTED
     , r.FZGRE_REFERENZBUCHUNG
     , snt.concat_values ( 'select to_char ( ID_SEQ_FZGRECHNUNG ) from snt.TFZGRECHNUNG where FZGRE_REFERENZBUCHUNG = ' || r.ID_SEQ_FZGRECHNUNG, 4000, '/' ) AlreadyReferenced
     , r.FZGRE_CREATOR
     , to_char ( r.FZGRE_CREATED,    'DD.MM.YYYY' ) as FZGRE_CREATED
     , r.ID_IMP_TYPE
     , r.FZGRE_CONTROL_STATE
     , r.FZGRE_FORWARD_ACC
     , replace ( replace ( r.FZGRE_MEMO, chr(10), ' ' ), chr(13), ' ' ) FZGRE_MEMO
  from snt.TPARTNER                    p
     , snt.TFZGRECHNUNG                r
     , snt.TLOP2540_CN_witout_ref_INV  cn
 where p.GUID_PARTNER                = r.GUID_PARTNER
   and cn.ID_SEQ_FZGRECHNUNG_CN      = r.ID_SEQ_FZGRECHNUNG
   and not exists ( select null from TLOP2540_INV_of_CN inv                              -- where no INV was found for the CN
                     where cn.ID_SEQ_FZGRECHNUNG_CN = inv.ID_SEQ_FZGRECHNUNG_CN_REF )
order by 2, 3, 4, 7, 6, 5
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- report final / finished message and exit
set echo     off
set feedback off

set termout  on

prompt
prompt finished.
prompt

prompt
prompt please check if any ORA- or SP2- error is listed in the logfile DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.log / listfile DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.lst 
prompt

exit;