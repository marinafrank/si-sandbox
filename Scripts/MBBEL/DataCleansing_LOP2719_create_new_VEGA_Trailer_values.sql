-- create_new_Vega_Trailer_values.sql
-- FraBe 31.10.2012 MKS-119007 creation

spool DataCleansing_LOP2719_create_new_Vega_Trailer_values.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size 1000000
set lines        999
set pages        0

variable nachricht    varchar2 ( 100 );

prompt

whenever sqlerror exit sql.sqlcode

declare
    
    L_ISTUSER         VARCHAR2 ( 30 char ) := user;
    L_SOLLUSER        VARCHAR2 ( 30 char ) := 'SNT';
    L_SYSDBA_PRIV     VARCHAR2 (  1 char );
    L_ABBRUCH         exception;
  
begin
   
   if    L_ISTUSER is null 
   then  raise L_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_ABBRUCH;
   end   if;

exception
  when L_ABBRUCH then
    raise_application_error ( -20001, 'Executing user is not ' || upper ( L_SOLLUSER )
                             || '! for a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ));
end;
/

WHENEVER SQLERROR CONTINUE

prompt
prompt processing. please wait ...
prompt

set termout      off

set sqlprompt    'SQL>'
set pages        999
set lines        999
set serveroutput on   size 1000000
set heading      on
set feedback     on
set feedback     1

set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1st: disable constraint
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter table snt.TVEGA_I55_CO modify constraint FK_VI55CO_VI55AV disable;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2nd: delete old values
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
delete from snt.TVEGA_I55_ATT_VALUE where GUID_VI55A = '766DC53249F940B8B431E3128379AD4B';
delete from snt.TVEGA_I55_ATT_VALUE where GUID_VI55A = '63C2855874334FA1942873BE3CDB00FB';

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3rd: insert new values
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into snt.TVEGA_I55_ATT_VALUE 
     ( GUID_VI55AV,                        GUID_VI55A,                         VI55AV_VALUE, VI55AV_CAPTION,                        VI55AV_IS_DEFAULT_VALUE )
select '36F21E749E8A42FB9BDEFCBE5A61452E', '766DC53249F940B8B431E3128379AD4B', '*',          'nicht definiert',                     1              from dual union
select '70A887B66D024935B6FD489B13DB6466', '766DC53249F940B8B431E3128379AD4B', '0',          'keine Achsen',                        0              from dual union
select '65BB6712A2364EAE8691CD7F65EC63F4', '766DC53249F940B8B431E3128379AD4B', '1',          '1 Achse (Auflieger)',                 0              from dual union
select '51CC3EBC74074B8DBBEA5AA8F42D64FC', '766DC53249F940B8B431E3128379AD4B', '2',          '2 Achsen (Auflieger)',                0              from dual union
select 'D95F5EAA4B4046828DB4821D48819F60', '766DC53249F940B8B431E3128379AD4B', '3',          '3 Achsen (Auflieger)',                0              from dual union
select '5802B87FAA2844C682345FA7730C84DC', '766DC53249F940B8B431E3128379AD4B', '4',          '4 Achsen (Auflieger)',                0              from dual union
select '389F4E98B7BF4F82A8A3A57DB5F88560', '766DC53249F940B8B431E3128379AD4B', '5',          'mehrere Achsen (Auflieger)',          0              from dual union
select 'CBBFDBB96DAE457FA42756BCB54CCBB1', '766DC53249F940B8B431E3128379AD4B', 'A',          '1 Achse (Anhaenger)',                  0              from dual union
select 'F5199A693CCD47B8906775BFA602847E', '766DC53249F940B8B431E3128379AD4B', 'B',          '2 Achsen (Anhaenger/Nicht-MB)',       0              from dual union
select '6813FE7366314F5DBA67FD381B622ED3', '766DC53249F940B8B431E3128379AD4B', 'C',          '3 Achsen (Anhaenger/Nicht-MB)',        0              from dual union
select 'CE4B9E499994475BAB55688F0C2158C2', '766DC53249F940B8B431E3128379AD4B', 'D',          '4 Achsen (Anhaenger/Nicht-MB)',        0              from dual union
select 'C00C77B63AEB48A8BB84D2F124BE693A', '766DC53249F940B8B431E3128379AD4B', 'E',          'mehrere Achsen (Anhaenger/Nicht-MB)',  0              from dual;


insert into snt.TVEGA_I55_ATT_VALUE 
     ( GUID_VI55AV,                        GUID_VI55A,                         VI55AV_VALUE, VI55AV_CAPTION,                       VI55AV_IS_DEFAULT_VALUE )
select '0F4C801638E04E45A2A79F48C98ECF12', '63C2855874334FA1942873BE3CDB00FB', '*',          'nicht definiert',                     1              from dual union
select 'AEA0505C041D4BCDB1912B99283C1F2C', '63C2855874334FA1942873BE3CDB00FB', '0',          'kein Anhaenger/Auflieger',            0              from dual union
select 'EAD14A0287764370BCC18FCF07945CC3', '63C2855874334FA1942873BE3CDB00FB', '1',          '0 - 3,5t (Anhaenger/Auflieger)',      0              from dual union
select '99E0AA5147314D68B513A27487955AD3', '63C2855874334FA1942873BE3CDB00FB', '2',          '3,5 - 7,49t (Anhaenger/Auflieger)',  0              from dual union
select '38145F49129B4C5EBC87FBA358366FFF', '63C2855874334FA1942873BE3CDB00FB', '3',          '7,5 -10t (Anhaenger/Auflieger)',      0              from dual union
select 'E913C99DDF6A4A198A652140340027A5', '63C2855874334FA1942873BE3CDB00FB', '4',          '10 - 11,9t (Anhaenger/Auflieger)', 0              from dual union
select '63E904219AC94E408198BB36A07689D3', '63C2855874334FA1942873BE3CDB00FB', '5',          '>12t (Anhaenger/Auflieger)',          0              from dual union
select 'AA5EAB3DD3754CF6AB470D43AD2BA667', '63C2855874334FA1942873BE3CDB00FB', 'A',          '0 - 3,5t (Nicht-MB)',                 0              from dual union
select 'B147645007E545118E4EE3D308AAB4BC', '63C2855874334FA1942873BE3CDB00FB', 'B',          '3,5 - 7,49t (Nicht-MB)',              0              from dual union
select '637C63C3CE2646BBA3202BEF31FF59BF', '63C2855874334FA1942873BE3CDB00FB', 'C',          '7,5 -10t (Nicht-MB)',                 0              from dual union
select 'A19F2B97D1284271A5EF81A9E9BAF45B', '63C2855874334FA1942873BE3CDB00FB', 'D',          '10 - 11,9t (Nicht-MB)',              0              from dual union
select '2C22176350B54554BD43054D8B37E11F', '63C2855874334FA1942873BE3CDB00FB', 'E',          '>12t (Nicht-MB)',                     0              from dual;

insert into snt.TTRANSLATE_BASE 
     ( GUID_TRANSLATE_BASE,                TTB_NAME )
select 'E833BE490E4B429AB6288816CAAD126C', '1 Achse (Auflieger)'                  from dual union
select 'B44B58D2DBFB4D4DAB11A18669BAB989', '2 Achsen (Auflieger)'                 from dual union
select '78FBED17E12C4BF89490B517E95C0079', '3 Achsen (Auflieger)'                 from dual union
select '51CE06493EAE44219ABEA1651432A149', '4 Achsen (Auflieger)'                 from dual union
select '710B53E1B8C0491AA0D5433D580892C2', 'mehrere Achsen (Auflieger)'           from dual union
select 'D18145FD135D4DD6A3FB12A78DAE3494', '1 Achse (Anhaenger)'                  from dual union
select '9D11ADDEC6194BC1A0B95F8C1C2188A8', '2 Achsen (Anhaenger/Nicht-MB)'        from dual union
select '5427F94678EB4D0ABC4BC529FED1395B', '3 Achsen (Anhaenger/Nicht-MB)'         from dual union
select '589D070CD15F492388F6D14B4B8B7643', '4 Achsen (Anhaenger/Nicht-MB)'         from dual union
select '307D26494DC4491BA3532E59F4AE40CD', 'mehrere Achsen (Anhaenger/Nicht-MB)'   from dual union
select 'E0ECE7757A0B456383D275C8F03E8071', '0 - 3,5t (Anhaenger/Auflieger)'       from dual union
select '9B388A681ABA45FEBD5D2926B3B18A2A', '3,5 - 7,49t (Anhaenger/Auflieger)'   from dual union
select 'BE007733D05E484C8A7D0BA8C9D535DF', '7,5 -10t (Anhaenger/Auflieger)'       from dual union
select 'E7627C05113D484A8933E720EE98C518', '10 - 11,9t (Anhaenger/Auflieger)'  from dual union
select '804E087295EA4B298927B568074AE916', '>12t (Anhaenger/Auflieger)'           from dual union
select '500F99445D7D4FDBA462BBD3A587FD61', '0 - 3,5t (Nicht-MB)'                  from dual union
select '4D854B55197E42BCA9D611526481A26A', '3,5 - 7,49t (Nicht-MB)'               from dual union
select '2E26F97A783442C5A7669632C128B2C0', '7,5 -10t (Nicht-MB)'                  from dual union
select '0E6EA836928F4D85B342E896CB11E419', '10 - 11,9t (Nicht-MB)'               from dual union
select '8A73C63690B344E9BEBEBEA6561C4B7E', '>12t (Nicht-MB)'                      from dual;

insert into snt.TTRANSLATE_CAPTIONS
     ( GUID_TRANSLATE_BASE,                ID_LANGUAGE, TTC_CAPTION )
select '70F8842535544837813C4D33401DDDA0', 3,           'not defined'                         from dual union
select '912EDA81BB28446DAF0A586E8B828280', 3,           'no axes'                             from dual union
select 'E833BE490E4B429AB6288816CAAD126C', 3,           '1 axe (semi-trailer)'                from dual union
select 'B44B58D2DBFB4D4DAB11A18669BAB989', 3,           '2 axes (semi-trailer)'               from dual union
select '78FBED17E12C4BF89490B517E95C0079', 3,           '3 axes (semi-trailer)'               from dual union
select '51CE06493EAE44219ABEA1651432A149', 3,           '4 axes (semi-trailer)'               from dual union
select '710B53E1B8C0491AA0D5433D580892C2', 3,           'multiple axes (semi-trailer)'        from dual union
select 'D18145FD135D4DD6A3FB12A78DAE3494', 3,           '1 axe (trailer)'                     from dual union
select '9D11ADDEC6194BC1A0B95F8C1C2188A8', 3,           '2 axes (trailer/Non-MB)'             from dual union
select '5427F94678EB4D0ABC4BC529FED1395B', 3,           '3 axes (trailer/Non-MB)'             from dual union
select '589D070CD15F492388F6D14B4B8B7643', 3,           '4 axes (trailer/Non-MB)'             from dual union
select '307D26494DC4491BA3532E59F4AE40CD', 3,           'multiple axes (trailer/Non-MB)'      from dual union
select 'AECD70F0D31A4B49834BE93A8B9429ED', 3,           'no trailer/semi-trailer'             from dual union
select 'E0ECE7757A0B456383D275C8F03E8071', 3,           '0 - 3,5t (trailer/semi-trailer)'     from dual union
select '9B388A681ABA45FEBD5D2926B3B18A2A', 3,           '3,5 - 7,49t (trailer/semi-trailer)' from dual union
select 'BE007733D05E484C8A7D0BA8C9D535DF', 3,           '7,5 -10t (trailer/semi-trailer)'     from dual union
select 'E7627C05113D484A8933E720EE98C518', 3,           '10 - 11,9t (trailer/semi-trailer)'  from dual union
select '804E087295EA4B298927B568074AE916', 3,           '>12t (trailer/semi-trailer)'         from dual union
select '500F99445D7D4FDBA462BBD3A587FD61', 3,           '0 - 3,5t (Non-MB)'                   from dual union
select '4D854B55197E42BCA9D611526481A26A', 3,           '3,5 - 7,49t (Non-MB)'               from dual union
select '2E26F97A783442C5A7669632C128B2C0', 3,           '7,5 -10t (Non-MB)'                   from dual union
select '0E6EA836928F4D85B342E896CB11E419', 3,           '10 - 11,9t (Non-MB)'                from dual union
select '8A73C63690B344E9BEBEBEA6561C4B7E', 3,           '>12t (Non-MB)'                       from dual;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4th: enable constraint again
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter table snt.TVEGA_I55_CO modify constraint FK_VI55CO_VI55AV enable validate;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- commit data
set echo     off
set feedback off

declare

   L_MAJOR_MIN     number := 2;
   L_MINOR_MIN     number := 6;
   L_REVISION_MIN  number := 3;

   L_MAJOR_IST     number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST     number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST  number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );

begin
   commit;
   if    L_MAJOR_IST > L_MAJOR_MIN
    or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
    or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST >= L_REVISION_MIN )
   then  execute immediate ( 'begin snt.SRS_LOG_MAINTENANCE_SCRIPTS ( ''DataCleansing_LOP2719_create_new_Vega_Trailer_values.sql'' ); end;' );
   end  if;
   :nachricht := 'Data saved into the DB';
end;
/

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2719_create_new_Vega_Trailer_values.log
prompt

exit;
