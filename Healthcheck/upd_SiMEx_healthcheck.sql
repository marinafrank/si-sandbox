-- upd_SiMEx_healthcheck.sql
-- Migrationscript for Sirius - SiMEx Healthcheck update 
-- 
-- TK    2013-01-10; Creation with calling subroutine files.
-- FraBe 2013-01-15 MKS-121734 add calling of additional_ssi_LOV_MESSAGE_CODE.sql
-- FraBe 2014-01-22 MKS-130325:1 add ssi_contract

set echo         off
set define       on
set serveroutput on size 1000000
set lines        9999
set pages        9999

spool upd_SiMEx_healthcheck.&&_CONNECT_IDENTIFIER..log


prompt ################################################################################
prompt ##
prompt # check executing user - must be snt
prompt # and database version - must be 2.8.1.0 or higher
prompt ##
prompt ################################################################################

whenever sqlerror exit sql.sqlcode

declare

   L_ISTUSER         VARCHAR2 ( 30 char ) := user;
   L_SOLLUSER        VARCHAR2 ( 30 char ) := 'SNT';
   L_ABBRUCH         exception;

begin
   if    L_ISTUSER is null
   then  raise L_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_ABBRUCH;
   end   if;

exception when L_ABBRUCH then raise_application_error ( -20001, 'Executing user is not ' || upper ( L_SOLLUSER )
                                || '! for a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ));
end;
/

declare

   L_GUID_LE         varchar2 ( 32 char );
   
   L_MAJOR_MIN       integer := 2;
   L_MINOR_MIN       integer := 8;
   L_REVISION_MIN    integer := 1;
   L_BUILD_MIN       integer := 0;

   L_MAJOR_IST       integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST       integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST    integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST       integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );
   
begin

   if      L_MAJOR_IST > L_MAJOR_MIN
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST > L_REVISION_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST = L_REVISION_MIN and L_BUILD_IST >= L_BUILD_MIN )
   then  null;

   else  raise_application_error ( -20002
                                 , 'DB Version is incorrect! Current version is '
                                   || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                                   || ', but version must be same or higher than '
                                   || L_MAJOR_MIN || '.' || L_MINOR_MIN || '.' || L_REVISION_MIN || '.' || L_BUILD_MIN
                                   || chr(10) || '   ==> Script Execution canchelled <==      ');

   end   if;
   
   dbms_output.put_line ( 'Pre-checks completed. Update SiMEx Healthcheck from Version ' || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST );

end;
/


whenever sqlerror continue
prompt ################################################################################
prompt ##
prompt # calling subroutines to patch Healthcheck
prompt ##
prompt ################################################################################

@@additional_grants_snt.sql
@@additional_ssi_LOV_MESSAGE_CODE.sql   -- FraBe 2013-01-15 MKS-121734 add calling of additional_ssi_LOV_MESSAGE_CODE.sql
@@ssi_healthcheck_addon.plh
@@ssi_healthcheck_addon.plb
@@ssi_contract.plh
@@ssi_contract.plb
@@ssi_healthcheck.plh
@@ssi_healthcheck.plb
@@PB_Contract.plb
@@ssi_force_flag.plb -- TK 2014-09-22 MKS-133877:1


prompt ################################################################################
prompt ##
prompt # log script execution
prompt ##
prompt ################################################################################
execute snt.SRS_LOG_MAINTENANCE_SCRIPTS ( 'upd_SiMEx_healthcheck.sql' );

prompt ################################################################################
prompt ##
prompt # exec snt.after_DDL_STATEMENT / recompile snt.ON_LOGON / snt.ON_LOGOFF
prompt ##
prompt ################################################################################

execute snt.after_DDL_STATEMENT;

alter trigger snt.ON_LOGON  compile;
alter trigger snt.ON_LOGOFF compile;

prompt ################################################################################
prompt ##
prompt # release restriction of database
prompt ##
prompt ################################################################################

alter system disable restricted session;

prompt ################################################################################
prompt ##
prompt # end of setup
prompt ##
prompt ################################################################################

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile upd_SiMEx_healthcheck.&&_CONNECT_IDENTIFIER..log
prompt

exit;