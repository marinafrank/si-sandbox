-- SiMEX_create_TS_and_USER.sql
-- (re)/create snt / sntidx tablespaces and main user/roles
-- MUST BE EXEUTED as user SYS !!! ( -> SYSDBA )
-- plus variable &&SIMEX_ROOTPATH must be set!

-- FraBe 08.10.2012 creation due to MKS-117502 (-> copy from SIRIUS_create_TS_and_USER.sql )
-- FraBe 20.05.2014 MKS-132655:1 move 'grant execute on simex.PCK_CALCULATION to test' to start_cre_SiMEx_DB.sql
--                               plus add drop user TEST

-- spool SiMEX_create_TS_and_USER.log

set echo         off
set serveroutput on

WHENEVER SQLERROR EXIT SQL.SQLCODE

------------------------------------------------------------------------------
---- Part I -> drop perhaps already existing users / roles / tablespaces  ----
------------------------------------------------------------------------------

declare
    TABLE_NOT_EXISTING      exception;
    TABLESPACE_NOT_EXISTING exception;
    USER_NOT_EXISTING       exception;
    ROLE_NOT_EXISTING       exception;
    DB_LINK_NOT_EXISTING    exception;
    pragma exception_init ( TABLE_NOT_EXISTING,       -942 );
    pragma exception_init ( TABLESPACE_NOT_EXISTING,  -959 );
    pragma exception_init ( USER_NOT_EXISTING,       -1918 );
    pragma exception_init ( ROLE_NOT_EXISTING,       -1919 );
    pragma exception_init ( DB_LINK_NOT_EXISTING,    -2024 );
    --------------------------------------------------------------------------
    procedure drop_OBJECT
      ( I_DROP_SQL     varchar2 ) is
    begin
        dbms_output.put_line ( I_DROP_SQL );
        execute immediate I_DROP_SQL;
    exception 
        when TABLE_NOT_EXISTING      then null;
        when TABLESPACE_NOT_EXISTING then null;
        when USER_NOT_EXISTING       then null;
        when ROLE_NOT_EXISTING       then null;
        when DB_LINK_NOT_EXISTING    then null;
    end;
    --------------------------------------------------------------------------
    procedure drop_GLOBAL_TEMPORARY_TABLE
            ( I_TABLE_NAME   varchar2 ) is
    l_sql VARCHAR2(4000);
    begin
        l_sql := 'truncate table ' || I_TABLE_NAME;
        execute immediate l_sql;
        dbms_output.put_line (l_sql);
        drop_object ( 'drop table ' || I_TABLE_NAME || ' cascade constraints purge' );
    exception
        when TABLE_NOT_EXISTING  then null;
    end;
    --------------------------------------------------------------------------

begin

    drop_GLOBAL_TEMPORARY_TABLE ( 'simex.TXML_SPLIT' );

    drop_OBJECT ( 'drop user SIMEX cascade' );
    
    drop_OBJECT ( 'drop user TEST  cascade' );
        
    drop_OBJECT ( 'drop tablespace SIMEX including contents cascade constraints' );
    
    drop_OBJECT ( 'drop database link SIMEX_DB_LINK' );
        
end;
/
WHENEVER SQLERROR CONTINUE

------------------------------------------------------------------------------
---- Part II -> create users / roles / tablespaces                        ----
------------------------------------------------------------------------------
set serveroutput off

CREATE TABLESPACE SiMEX
LOGGING
ONLINE
PERMANENT
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

-- MKS-87889:1 T.Kieninger; Deactivating feature by default
alter system set sec_case_sensitive_logon = false;

create user SiMEX identified by simex default tablespace SiMEX temporary tablespace TEMP profile DEFAULT account unlock QUOTA UNLIMITED ON SIMEX;

grant CONNECT                  to SiMEX;
grant DBA                      to SiMEX;

grant CREATE     ANY TABLE         to SiMEX;
grant CREATE     ANY VIEW          to SiMEX;
grant DROP       ANY TABLE         to SiMEX;
grant DROP       ANY VIEW          to SiMEX;
grant GRANT      ANY PRIVILEGE     to SiMEX;
grant CREATE     ANY TRIGGER       to SiMEX;
grant DROP       ANY TRIGGER       to SiMEX;
GRANT RESTRICTED SESSION           to SiMEX;
GRANT CREATE     JOB               to SiMEX;
GRANT MANAGE     SCHEDULER         to SiMEX;
GRANT SCHEDULER_ADMIN              to SiMEX;

grant select  on SYS.V_$SESSION     to SiMEX;
grant select  on sys.DBA_ROLE_PRIVS to SiMEX;
grant select  on sys.DBA_USERS      to SiMEX;

grant execute on sys.DBMS_LOCK to public;

create or replace directory SIMEX_DIR as '&&SIMEX_ROOTPATH';

grant READ    ON DIRECTORY SIMEX_DIR to SiMEX;
grant WRITE   ON DIRECTORY SIMEX_DIR to SiMEX;

create user TEST identified by values 'BDA4B7FE7EECF0FB' default tablespace SiMEX temporary tablespace TEMP profile DEFAULT account unlock;
grant connect to TEST;




