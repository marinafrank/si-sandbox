-- DataAnalysis_LOP2145-IdentifyDuplicates.sql
-- FraBe     30.10.2012 MKS-119335:1 creation
-- FraBe     09.09.2013 MKS-128298:1 / LOP2145: überarbeitet: nur InScope objekte
--                                              plus: verwendet jetzt auch das standard template 
-- FraBe     16.10.2013 MKS-128828:1 / LOP2145: logik für duplicates - suche wegen diversen während kundencheck gemeldeten falschen werten
--                                              plus: zt. neue filenamen

spool DataAnalysis_LOP2145-IdentifyDuplicates.log

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
exec :L_SCRIPTNAME       := 'DataAnalysis_LOP2145-IdentifyDuplicates.sql';

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
set pages        50000
set lines        9999
set serveroutput on   size unlimited
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >


col a noprint
col b noprint
col c noprint
col d noprint
col e noprint

col DiffCriteria                    form a16  head "DiffCriteria"
col PARTNERTYP                      form a3   head "D/C"
col ID_PARTNER                      form a11	head "ID CUST/GAR"
col PARTNERTYP_CAPTION              form a40  head "Typ"
col NAME_CAPTION1                   form a50
col NAME_CAPTION2                   form a45
col NAME_CAPTION3                   form a45
col ADR_STREET1                     form a50
col ADR_STREET2                     form a45
col ZIP_ZIP                         form a7
col PARTNER_FINSYS_DEBITOR_NUMBER   form a15  head "CoFiCo Debitor#"
col PARTNER_FINSYS_CREDITOR_NUMBER  form a16  head "CoFiCo Creditor#"
col PARTNER_VAT_ID                  form a15  head "UID"

def LEN_DiffCriteria               = '16'
def LEN_PARTNERTYP                 =  '3'
def LEN_PARTNERTYP_CAPTION         = '40'
def LEN_ID_PARTNER                 = '11'
def LEN_NAME_CAPTION1              = '50'
def LEN_NAME_CAPTION2              = '45'
def LEN_NAME_CAPTION3              = '45'
def LEN_ADR_STREET1                = '50'
def LEN_ADR_STREET2                = '45'
def LEN_ZIP_ZIP                    =  '7'
def LEN_PARTNER_FINSYS_DEBITOR_NO  = '15'
def LEN_PARTNER_FINSYS_CREDITOR_NO = '16'
def LEN_PARTNER_VAT_ID             = '15'
def LEN_ID_SEQ_ADRASSOZ            = '15'
def LEN_ID_SEQ_NAME                = '11'
def LEN_ID_SEQ_ADRESS              = '13'

--------------------------------------------------------------------------------------------------------------------------------
-- 1st: create a well prepared txt output file
--------------------------------------------------------------------------------------------------------------------------------
set feedback off   

spool DataAnalysis_LOP2145-IdentifyDuplicates.txt

prompt 1) possible duplicates per same NAME and ( same STREET or same ZIP_ZIP )
prompt sorted and grouped by NAME_CAPTION1 / ZIP_ZIP / ADR_STREET1 / ID_SEQ_ADRASSOZ
prompt

select upper ( p1.NAME_CAPTION1 ) a
     , p1.ZIP_ZIP                 b
     , p1.ADR_STREET1             c
     , p1.ID_SEQ_ADRASSOZ         d
     , 'NAME'                    as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )       = upper ( p4.NAME_CAPTION1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )       = p2.UPPER_NAME_CAPTION1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select upper ( p1.NAME_CAPTION1 ) a
     , p1.ZIP_ZIP                 b
     , p1.ADR_STREET1             c
     , p1.ID_SEQ_ADRASSOZ         d
     , 'NAME'                    as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ADR_STREET1
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP       =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )  = upper ( p4.NAME_CAPTION1 )
                            and upper ( p3.ADR_STREET1 )    = upper ( p4.ADR_STREET1 ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ADR_STREET1
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ADR_STREET1
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C' -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D' and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP          =         p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )     =         p2.UPPER_NAME_CAPTION1
   and upper ( p1.ADR_STREET1 )       = upper ( p2.ADR_STREET1 )
 union
select upper ( p1.NAME_CAPTION1 ) a
     , null                       b
     , null                       c
     , null                       d
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )       = upper ( p4.NAME_CAPTION1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )       = p2.UPPER_NAME_CAPTION1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select upper ( p1.NAME_CAPTION1 ) a
     , null                       b
     , null                       c
     , null                       d
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ADR_STREET1
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP       =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )  = upper ( p4.NAME_CAPTION1 )
                            and upper ( p3.ADR_STREET1 )    = upper ( p4.ADR_STREET1 ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ADR_STREET1
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ADR_STREET1
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C' -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D' and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP          =         p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )     =         p2.UPPER_NAME_CAPTION1
   and upper ( p1.ADR_STREET1 )       = upper ( p2.ADR_STREET1 )
order by 1, 2, 3, 4, 8;

prompt
prompt 2) possible duplicates per same STREET
prompt sorted and grouped by ADR_STREET1 / NAME_CAPTION1 / ZIP_ZIP / ID_SEQ_ADRASSOZ
prompt

select upper ( p1.ADR_STREET1 )   a
     , p1.NAME_CAPTION1           b
     , p1.ZIP_ZIP                 c
     , p1.ID_SEQ_ADRASSOZ         d
     , 'STREET'                   as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 ) as UPPER_ADR_STREET1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.ADR_STREET1 )         = upper ( p4.ADR_STREET1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( ADR_STREET1 ) as UPPER_ADR_STREET1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.ADR_STREET1 )         = p2.UPPER_ADR_STREET1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select upper ( p1.ADR_STREET1 )   a
     , null                       b
     , null                       c
     , null                       d
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 ) as UPPER_ADR_STREET1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.ADR_STREET1 )         = upper ( p4.ADR_STREET1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( ADR_STREET1 ) as UPPER_ADR_STREET1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.ADR_STREET1 )         = p2.UPPER_ADR_STREET1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
order by 1, 2, 3, 4, 8;

prompt
prompt 3) possible duplicates per same CoFiCo Debitor#
prompt sorted and grouped by CoFiCo Debitor# / NAME_CAPTION1 / ADR_STREET1 / ZIP_ZIP / ID_SEQ_ADRASSOZ
prompt

select p1.PARTNER_FINSYS_DEBITOR_NUMBER a
     , p1.NAME_CAPTION1                 b
     , p1.ADR_STREET1                   c
     , p1.ZIP_ZIP                       d
     , p1.ID_SEQ_ADRASSOZ               e
     , 'CoFiCo Debitor#'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_DEBITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_DEBITOR_NUMBER    = p4.PARTNER_FINSYS_DEBITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                    = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_DEBITOR_NUMBER = p2.PARTNER_FINSYS_DEBITOR_NUMBER
 union
select p1.PARTNER_FINSYS_DEBITOR_NUMBER a
     , null                       b
     , null                       c
     , null                       d
     , null                       e
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_DEBITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_DEBITOR_NUMBER    = p4.PARTNER_FINSYS_DEBITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                    = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_DEBITOR_NUMBER = p2.PARTNER_FINSYS_DEBITOR_NUMBER
order by 1, 2, 3, 4, 5, 9;

prompt
prompt 4) possible duplicates per same CoFiCo Creditor#
prompt sorted and grouped by CoFiCo Creditor# / NAME_CAPTION1 / ADR_STREET1 / ZIP_ZIP / ID_SEQ_ADRASSOZ
prompt

select p1.PARTNER_FINSYS_CREDITOR_NUMBER a
     , p1.NAME_CAPTION1                  b
     , p1.ADR_STREET1                    c
     , p1.ZIP_ZIP                        d
     , p1.ID_SEQ_ADRASSOZ                e
     , 'CoFiCo Creditor#'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_CREDITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_CREDITOR_NUMBER   = p4.PARTNER_FINSYS_CREDITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                     = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_CREDITOR_NUMBER = p2.PARTNER_FINSYS_CREDITOR_NUMBER
 union
select p1.PARTNER_FINSYS_CREDITOR_NUMBER a
     , null                       b
     , null                       c
     , null                       d
     , null                       e
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_CREDITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_CREDITOR_NUMBER   = p4.PARTNER_FINSYS_CREDITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                     = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_CREDITOR_NUMBER = p2.PARTNER_FINSYS_CREDITOR_NUMBER
order by 1, 2, 3, 4, 5, 9;

prompt
prompt 5) possible duplicates per same UID
prompt sorted and grouped by UID / NAME_CAPTION1 / ADR_STREET1 / ZIP_ZIP / ID_SEQ_ADRASSOZ
prompt

select p1.PARTNER_VAT_ID    a
     , p1.NAME_CAPTION1                 b
     , p1.ADR_STREET1                   c
     , p1.ZIP_ZIP                       d
     , p1.ID_SEQ_ADRASSOZ               e
     , 'UID'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_VAT_ID, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP       = p4.PARTNERTYP
                            and p3.PARTNER_VAT_ID   = p4.PARTNER_VAT_ID )
       group by p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_VAT_ID
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP           = p2.PARTNERTYP
   and p1.PARTNER_VAT_ID       = p2.PARTNER_VAT_ID
 union
select p1.PARTNER_VAT_ID          a
     , null                       b
     , null                       c
     , null                       d
     , null                       e
     , rpad ( '-', &&LEN_DiffCriteria,               '-' )  as DiffCriteria
     , rpad ( '-', &&LEN_PARTNERTYP,                 '-' )  as PARTNERTYP
     , rpad ( '-', &&LEN_PARTNERTYP_CAPTION,         '-' )  as PARTNERTYP_CAPTION
     , rpad ( '-', &&LEN_ID_PARTNER,                 '-' )  as ID_PARTNER
     , rpad ( '-', &&LEN_NAME_CAPTION1,              '-' )  as NAME_CAPTION1
     , rpad ( '-', &&LEN_NAME_CAPTION2,              '-' )  as NAME_CAPTION2
     , rpad ( '-', &&LEN_NAME_CAPTION3,              '-' )  as NAME_CAPTION3
     , rpad ( '-', &&LEN_ADR_STREET1,                '-' )  as ADR_STREET1
     , rpad ( '-', &&LEN_ADR_STREET2,                '-' )  as ADR_STREET2
     , rpad ( '-', &&LEN_ZIP_ZIP,                    '-' )  as ZIP_ZIP
     , rpad ( '-', &&LEN_PARTNER_FINSYS_DEBITOR_NO,  '-' )  as PARTNER_FINSYS_DEBITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_FINSYS_CREDITOR_NO, '-' )  as PARTNER_FINSYS_CREDITOR_NUMBER
     , rpad ( '-', &&LEN_PARTNER_VAT_ID,             '-' )  as PARTNER_VAT_ID
     , rpad ( '-', &&LEN_ID_SEQ_ADRASSOZ,            '-' )  as ID_SEQ_ADRASSOZ
     , rpad ( '-', &&LEN_ID_SEQ_NAME,                '-' )  as ID_SEQ_NAME
     , rpad ( '-', &&LEN_ID_SEQ_ADRESS,              '-' )  as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_VAT_ID, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP       = p4.PARTNERTYP
                            and p3.PARTNER_VAT_ID   = p4.PARTNER_VAT_ID )
       group by p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_VAT_ID
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP           = p2.PARTNERTYP
   and p1.PARTNER_VAT_ID       = p2.PARTNER_VAT_ID
order by 1, 2, 3, 4, 5, 9;

--------------------------------------------------------------------------------------------------------------------------------
-- 2nd: create a simle output file which can be loaded eg. into excel
--------------------------------------------------------------------------------------------------------------------------------
spool DataAnalysis_LOP2145-IdentifyDuplicates_csv.txt
set feedback on

select 'NAME'                    as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER   p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )       = upper ( p4.NAME_CAPTION1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )       = p2.UPPER_NAME_CAPTION1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select 'NAME'                     as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER  p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ADR_STREET1
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP       =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )  = upper ( p4.NAME_CAPTION1 )
                            and upper ( p3.ADR_STREET1 )    = upper ( p4.ADR_STREET1 ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ADR_STREET1
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ADR_STREET1
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C' -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D' and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP          =         p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )     =         p2.UPPER_NAME_CAPTION1
   and upper ( p1.ADR_STREET1 )       = upper ( p2.ADR_STREET1 )
 union
select 'STREET'                   as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER  p1
     , ( select p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 ) as UPPER_ADR_STREET1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.ADR_STREET1 )         = upper ( p4.ADR_STREET1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( ADR_STREET1 ) as UPPER_ADR_STREET1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.ADR_STREET1 )         = p2.UPPER_ADR_STREET1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select 'CoFiCo Debitor#'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_DEBITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_DEBITOR_NUMBER    = p4.PARTNER_FINSYS_DEBITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                    = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_DEBITOR_NUMBER = p2.PARTNER_FINSYS_DEBITOR_NUMBER
 union
select 'CoFiCo Creditor#'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_CREDITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_CREDITOR_NUMBER   = p4.PARTNER_FINSYS_CREDITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'    -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'    and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                     = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_CREDITOR_NUMBER = p2.PARTNER_FINSYS_CREDITOR_NUMBER
 union
select 'UID'                as DiffCriteria
     , p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_VAT_ID, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP       = p4.PARTNERTYP
                            and p3.PARTNER_VAT_ID   = p4.PARTNER_VAT_ID )
       group by p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_VAT_ID
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP           = p2.PARTNERTYP
   and p1.PARTNER_VAT_ID       = p2.PARTNER_VAT_ID
order by 1, 5, 8, 14;

--------------------------------------------------------------------------------------------------------------------------------
-- 3rd: create a simle output file with distinct data which can be loaded eg. into excel
--------------------------------------------------------------------------------------------------------------------------------
spool DataAnalysis_LOP2145-IdentifyDuplicates_distinct_csv.txt
set feedback on

select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER  p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )       = upper ( p4.NAME_CAPTION1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )       = p2.UPPER_NAME_CAPTION1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER  p1
     , ( select p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , p3.ADR_STREET1
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP       =         p4.PARTNERTYP
                            and upper ( p3.NAME_CAPTION1 )  = upper ( p4.NAME_CAPTION1 )
                            and upper ( p3.ADR_STREET1 )    = upper ( p4.ADR_STREET1 ))
       group by p3.PARTNERTYP
              , upper ( p3.NAME_CAPTION1 )
              , p3.ADR_STREET1
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( NAME_CAPTION1 ) as UPPER_NAME_CAPTION1
              , ADR_STREET1
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C' -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D' and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP          =         p2.PARTNERTYP
   and upper ( p1.NAME_CAPTION1 )     =         p2.UPPER_NAME_CAPTION1
   and upper ( p1.ADR_STREET1 )       = upper ( p2.ADR_STREET1 )
 union
select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER  p1
     , ( select p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 ) as UPPER_ADR_STREET1
              , p3.ZIP_ZIP
           from snt.VPARTNER p3
          where exists ( select null 
                           from snt.VPARTNER p4
                          where         p3.ID_SEQ_ADRASSOZ      <>         p4.ID_SEQ_ADRASSOZ
                            and         p3.PARTNERTYP            =         p4.PARTNERTYP
                            and upper ( p3.ADR_STREET1 )         = upper ( p4.ADR_STREET1 )
                            and nvl (   p3.ZIP_ZIP, p4.ZIP_ZIP ) = nvl   ( p4.ZIP_ZIP, p3.ZIP_ZIP ))
       group by p3.PARTNERTYP
              , upper ( p3.ADR_STREET1 )
              , p3.ZIP_ZIP
         having count(*) > 1
      intersect
         select PARTNERTYP
              , upper ( ADR_STREET1 ) as UPPER_ADR_STREET1
              , ZIP_ZIP
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where         p1.PARTNERTYP            = p2.PARTNERTYP
   and upper ( p1.ADR_STREET1 )         = p2.UPPER_ADR_STREET1
   and nvl (   p1.ZIP_ZIP, p2.ZIP_ZIP ) = nvl ( p2.ZIP_ZIP, p1.ZIP_ZIP )
 union
select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_DEBITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_DEBITOR_NUMBER    = p4.PARTNER_FINSYS_DEBITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_DEBITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_DEBITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                    = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_DEBITOR_NUMBER = p2.PARTNER_FINSYS_DEBITOR_NUMBER
 union
select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_FINSYS_CREDITOR_NUMBER, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ                 <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP                       = p4.PARTNERTYP
                            and p3.PARTNER_FINSYS_CREDITOR_NUMBER   = p4.PARTNER_FINSYS_CREDITOR_NUMBER )
       group by p3.PARTNERTYP
              , p3.PARTNER_FINSYS_CREDITOR_NUMBER
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_FINSYS_CREDITOR_NUMBER
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP                     = p2.PARTNERTYP
   and p1.PARTNER_FINSYS_CREDITOR_NUMBER = p2.PARTNER_FINSYS_CREDITOR_NUMBER
 union
select p1.PARTNERTYP
     , replace ( '        ' ||  p1.PARTNERTYP_CAPTION, '        MIG_OOS_', 'MIG_OOS_' ) as PARTNERTYP_CAPTION
     , p1.ID_PARTNER
     , p1.NAME_CAPTION1
     , p1.NAME_CAPTION2
     , p1.NAME_CAPTION3
     , p1.ADR_STREET1
     , p1.ADR_STREET2
     , p1.ZIP_ZIP
     , p1.PARTNER_FINSYS_DEBITOR_NUMBER
     , p1.PARTNER_FINSYS_CREDITOR_NUMBER
     , p1.PARTNER_VAT_ID
     , to_char ( p1.ID_SEQ_ADRASSOZ, '99999999999990' ) as ID_SEQ_ADRASSOZ
     , to_char ( p1.ID_SEQ_NAME,         '9999999990' ) as ID_SEQ_NAME 
     , to_char ( p1.ID_SEQ_ADRESS,     '999999999990' ) as ID_SEQ_ADRESS
  from snt.VPARTNER p1
     , ( select p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
           from snt.VPARTNER p3
          where nvl ( p3.PARTNER_VAT_ID, '0' ) <> '0'  
            and exists ( select null 
                           from snt.VPARTNER p4
                          where p3.ID_SEQ_ADRASSOZ <> p4.ID_SEQ_ADRASSOZ
                            and p3.PARTNERTYP       = p4.PARTNERTYP
                            and p3.PARTNER_VAT_ID   = p4.PARTNER_VAT_ID )
       group by p3.PARTNERTYP
              , p3.PARTNER_VAT_ID
         having count(*) > 1
      intersect
         select PARTNERTYP
              , PARTNER_VAT_ID
           from snt.VPARTNER
          where (  PARTNERTYP  = 'C'   -- bei TGARAGE keine weitere scoping abfrage. denn jede ist entweder inScope workshop oder inScope supplier
             or  ( PARTNERTYP  = 'D'   and PARTNERTYP_CAPTION not like 'MIG_OOS%' ))) p2
 where p1.PARTNERTYP     = p2.PARTNERTYP
   and p1.PARTNER_VAT_ID = p2.PARTNER_VAT_ID
order by 4, 7, 3, 13;

-- report final / finished message and exit
set termout  on

prompt
prompt finished.
prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataAnalysis_LOP2145-IdentifyDuplicates.log
prompt

exit;