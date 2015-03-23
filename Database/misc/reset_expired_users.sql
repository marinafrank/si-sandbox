-- reset_expired_users.sql

-- Frabe 06.09.2011 created due to MKS-105219 / logic almost copied from set_feb_prices_to_29_within_leap_years.sql
-- FraBe 14.09.2011 MKS-105219: some changes within some messages / error messages --> better text

set echo         off
set termout      on
set lines        999
set pages        999
set feedback     off
set timing       off
set verify       off
set heading      off
set trimspool    on
set sqlprompt    ''
set serveroutput on  size 1000000

variable part    number;

prompt

col start_datum new_value start_datum noprint
select to_char ( sysdate, 'YYYYMMDD_HH24MI' ) start_datum from dual;

def SpoolFileName = 'reset_expired_users_&&start_datum'

spool &&SpoolFileName..log

whenever sqlerror exit sql.sqlcode

declare
    
    L_ISTUSER         VARCHAR2 ( 30 char ) := user;
    L_SOLLUSER        VARCHAR2 ( 30 char ) := 'SYS';
    L_ABBRUCH         exception;

begin
   
   if    L_ISTUSER is null 
   then  raise L_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_ABBRUCH;
   end   if;

exception when L_ABBRUCH then raise_application_error ( -20001, 'Executing user is ' || upper ( L_ISTUSER ) 
                                || '. For a correct use of this script the executing user must be ' || upper ( L_SOLLUSER ) || '. Script aborted!' );
end;
/

declare
    
    L_VERSION         VARCHAR2 ( 30 char );
    L_ABBRUCH         exception;
    
begin

   select PROPERTY_VALUE
     into L_VERSION
     from DATABASE_PROPERTIES 
    where PROPERTY_NAME = 'NLS_RDBMS_VERSION';   
    
   if   to_number ( substr ( L_VERSION, 1, 2 )) < 11 
   then  raise L_ABBRUCH;
   end   if;

exception when L_ABBRUCH then raise_application_error ( -20001, 'Your DB version is ' || L_VERSION
                                || '. For a correct use of this script the DB version must be 11g or higher. Script aborted!' );
end;
/

whenever sqlerror continue rollback

prompt
prompt 1: List all SIRIUS DB users and their lock / expire date if there is already one existing
prompt
prompt 2: Unlock the SiMEX system users SIMEX
prompt

accept which_action char prompt 'Your choice: [1] [2]: ' 

prompt

declare
    
    L_error_message     varchar2 ( 200 char );

    L_StrSql            varchar2 ( 1000 char );

begin

    if             '&&which_action'         = '1'  then goto Part1;
    elsif          '&&which_action'         = '2'  then goto Part2;
                                                   else L_error_message := 'Valid values are 1 to 2!';
                                                        goto show_error_message;
    end   if;
    
    <<Part1>>
       :Part := 1;
       -- list existing users
       dbms_output.put_line ( 'Username                      Profile                       Status                        Expired             Locked              Default Tablespace' );
       dbms_output.put_line ( '----------------------------- ----------------------------- ----------------------------- ------------------- ------------------- ------------------' );
       for c1rec in ( select USERNAME
                           , PROFILE
                           , ACCOUNT_STATUS
                           , LOCK_DATE
                           , EXPIRY_DATE
                           , DEFAULT_TABLESPACE
                        from DBA_USERS d
                       where USERNAME = 'SIMEX' )
       loop
            dbms_output.put_line ( rpad (                 c1rec.USERNAME,                                      30, ' ' )
                                || rpad (                 c1rec.PROFILE,                                       30, ' ' )
                                || rpad (                 c1rec.ACCOUNT_STATUS,                                30, ' ' )
                                || rpad ( nvl ( to_char ( c1rec.EXPIRY_DATE, 'DD-MM-YYYY HH24:MI:SS' ), ' ' ), 20, ' ' )
                                || rpad ( nvl ( to_char ( c1rec.LOCK_DATE,   'DD-MM-YYYY HH24:MI:SS' ), ' ' ), 20, ' ' )
                                ||                        c1rec.DEFAULT_TABLESPACE );
       end  loop;
       goto ende;
      
    <<Part2>>
       :Part := 2;
       -- set profile default / account unlock for user SIMEX

       for c2rec in ( select d.USERNAME
                           , s.PASSWORD
                           , d.PROFILE
                           , d.ACCOUNT_STATUS
                           , d.LOCK_DATE
                           , d.EXPIRY_DATE
                           , d.DEFAULT_TABLESPACE
                        from sys.DBA_USERS d
                           , sys.user$     s
                       where d.USERNAME  = s.NAME
                         and d.USERNAME  = 'SIMEX' )
                    
       loop
            
            L_StrSql := 'alter user SIMEX '
                     || ' identified by values ''' || rpad ( c2rec.PASSWORD, 16, ' ' )
                     || ''' profile DEFAULT account unlock '
                     || ' QUOTA UNLIMITED ON SIMEX';

            dbms_output.put_line ( L_StrSql );

            execute immediate L_StrSql;

       end  loop;

       goto ende;
  
       <<show_error_message>>
       raise_application_error ( -20000, L_error_message || chr(10) || 'Script aborted!' );

       <<ende>>
end;
/

set termout on

prompt
prompt finished.
prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the protocolfile &&SpoolFileName..log
prompt

exit;

