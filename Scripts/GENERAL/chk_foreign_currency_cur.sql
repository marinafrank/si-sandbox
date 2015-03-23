-- chk_foreign_currency_cur.sql
-- FraBe   08.04.2013 MKS-118316:3 creation

spool chk_foreign_currency_cur.log

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

variable nachricht    varchar2 ( 100 );

prompt

whenever sqlerror exit sql.sqlcode

declare

   L_SYS_DBA_ABBRUCH       exception;
   L_USER_ABBRUCH          exception;
   L_DB_VERSION_ABBRUCH    exception;

   L_SYSDBA_PRIV           VARCHAR2 (  1 char );
   L_SYSDBA_PRIV_NEEDED    boolean              := false;          -- false or true
   
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   L_SOLLUSER              VARCHAR2 ( 30 char ) := 'SNT';
  
   L_MAJOR_MIN             integer := 2;
   L_MINOR_MIN             integer := 7;
   L_REVISION_MIN          integer := 0;
   L_BUILD_MIN             integer := 0;

   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );
   
begin

   -- check sysdba priv
   if   L_SYSDBA_PRIV_NEEDED
   then begin
     	    select 'Y'
	           into L_SYSDBA_PRIV 
	           from SESSION_PRIVS 
	          where PRIVILEGE = 'SYSDBA';
	      exception when NO_DATA_FOUND then raise L_SYS_DBA_ABBRUCH;
	      end;
	 end  if;
   
   -- check user 
   if    L_ISTUSER is null 
   then  raise L_USER_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_USER_ABBRUCH;
   end   if;
   
   -- check DB version
   if      L_MAJOR_IST > L_MAJOR_MIN
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST > L_REVISION_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST = L_REVISION_MIN and L_BUILD_IST >= L_BUILD_MIN )
   then  null;

   else  raise L_DB_VERSION_ABBRUCH;

   end   if;
   
exception
  when L_SYS_DBA_ABBRUCH 
  then raise_application_error ( -20001
                               , 'Executing user is not ' || upper ( L_SOLLUSER ) || ' / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || ' / SYSDABA' 
                              || chr(10) || '==> Script Execution cancelled <==' );
  when L_USER_ABBRUCH 
  then raise_application_error ( -20002
                               , 'Executing user is not ' || upper ( L_SOLLUSER ) || '!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER )
                              || chr(10) || '==> Script Execution cancelled <==' );
  when L_DB_VERSION_ABBRUCH
  then raise_application_error ( -20003
                               , 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || L_MAJOR_MIN || '.' || L_MINOR_MIN || '.' || L_REVISION_MIN || '.' || L_BUILD_MIN
                              || chr(10) || '==> Script Execution cancelled <==' );
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
set feedback     on
set feedback     1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- main part for < selecting or checking or correcting code >

col   ID_CURRENCY   new_val   ID_CURRENCY
col GUID_CURRENCY   new_val GUID_CURRENCY

select ID_CURRENCY, GUID_CURRENCY
  from snt.TCURRENCY cur
 where cur.CUR_CODE = ( select gs.VALUE
                          from snt.TGLOBAL_SETTINGS gs
                         where upper ( gs.APPLICATION_ID ) = 'SIRIUS'
                           and upper ( gs.SECTION)         = 'SETTING'
                           and upper ( gs.ENTRY)           = 'LOCALE_SCURRENCY');

-- folgende 2 col sind notwendig, damit ID/GUID_CURRENCY, die von den folgenden statements gelesen werden, 
-- nicht in die vorherigen variablen gestellt werden, was zu falschen ergebnissen führen würde!!!
col   ID_CURRENCY   new_val   ID_CURRENCY1   
col GUID_CURRENCY   new_val GUID_CURRENCY1   
                                                            
select CNT_CURR as count, cur.GUID_CURRENCY, TABLE_NAME
  from snt.TCURRENCY  cur
     , ( select count(*) CNT_CURR, 'GUID' TYPE,    GUID_CURRENCY,   'TITEM'       TABLE_NAME   from snt.TITEM                   where GUID_CURRENCY <> '&&GUID_CURRENCY' group by GUID_CURRENCY union
         select count(*),          'GUID',         GUID_CURRENCY,   'TITEM_HIST_PRICE'         from snt.TITEM_HIST_PRICE        where GUID_CURRENCY <> '&&GUID_CURRENCY' group by GUID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TSP_CONTRACT'             from snt.TSP_CONTRACT            where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TSP_COLLECTIVE_INVOICE'   from snt.TSP_COLLECTIVE_INVOICE  where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TGARAGE'                  from snt.TGARAGE                 where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TFZGRECHNUNG'             from snt.TFZGRECHNUNG            where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCUSTOMER_INVOICE'        from snt.TCUSTOMER_INVOICE       where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCUSTOMER'                from snt.TCUSTOMER               where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCO_SUBSTITUTE'           from snt.TCO_SUBSTITUTE          where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCOS_PRICING'             from snt.TCOS_PRICING            where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCONTRACT_SUBSIDIZING'    from snt.TCONTRACT_SUBSIDIZING   where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCONTRACT_CAMPAIGN'       from snt.TCONTRACT_CAMPAIGN      where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY union
         select count(*),            'ID', to_char ( ID_CURRENCY ), 'TCAMPAIGN'                from snt.TCAMPAIGN               where   ID_CURRENCY <>    &&ID_CURRENCY  group by   ID_CURRENCY ) anzahl
 where   anzahl.CNT_CURR <> 0
   and (( anzahl.TYPE = 'GUID' and anzahl.GUID_CURRENCY = cur.GUID_CURRENCY
     or ( anzahl.TYPE =   'ID' and anzahl.GUID_CURRENCY =   cur.ID_CURRENCY )))
order by 3, 2, 1;

prompt
prompt check table TCAMPAIGN:
prompt
select * from snt.TCAMPAIGN              where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCONTRACT_CAMPAIGN:
prompt
select * from snt.TCONTRACT_CAMPAIGN     where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCONTRACT_SUBSIDIZING:
prompt
select * from snt.TCONTRACT_SUBSIDIZING  where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCOS_PRICING:
prompt
select * from snt.TCOS_PRICING           where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCO_SUBSTITUTE:
prompt
select * from snt.TCO_SUBSTITUTE         where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCUSTOMER:
prompt
select * from snt.TCUSTOMER              where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TCUSTOMER_INVOICE:
prompt
select * from snt.TCUSTOMER_INVOICE      where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TFZGRECHNUNG:
prompt
select * from snt.TFZGRECHNUNG           where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TGARAGE:
prompt
select * from snt.TGARAGE                where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TITEM:
prompt
select * from snt.TITEM                  where GUID_CURRENCY <> '&&GUID_CURRENCY'  order by GUID_CURRENCY;

prompt
prompt check table TITEM_HIST_PRICE:
prompt
select * from snt.TITEM_HIST_PRICE       where GUID_CURRENCY <> '&&GUID_CURRENCY' order by GUID_CURRENCY;

prompt
prompt check table TSP_COLLECTIVE_INVOICE:
prompt
select * from snt.TSP_COLLECTIVE_INVOICE where ID_CURRENCY <> &&ID_CURRENCY  order by ID_CURRENCY;

prompt
prompt check table TSP_CONTRACT:
prompt
select * from snt.TSP_CONTRACT           where ID_CURRENCY <> &&ID_CURRENCY   order by ID_CURRENCY;


-- report final / finished message and exit
set echo     off
set feedback off
set termout  on

prompt
prompt finished.
prompt

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile chk_foreign_currency_cur.log
prompt

exit;
