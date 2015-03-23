-- Migrationscript for creation of SiMEX on a 11g database
-- 
-- FraBe, 03.10.2012 initial creation
-- FraBe  04.12.2012 MKS-119157:  add execution of PCK_PARTNER
-- FraBe  25.12.2012 MKS-120849:8 add execution of PCK_CONTRACT
-- FraBe  30.11.2013 MKS-127620:1 add execution of PCK_COST and PCK_REVENUE
-- FraBe  20.05.2014 MKS-132655:1 add grant execute on simex.PCK_CALCULATION to test
-- FraBe  31.10.2014 MKS-134523:1 add PCK_MODPROTO

SPOOL start_cre_SiMEX_DB.log

SET echo         off
SET verify       off
SET define       on
SET serveroutput on size 1000000

def SIMEX_DB_SYS_PASSWORD = '&&1'
def SIMEX_DATABASE_NAME   = '&&2'
def DBLINK_SNT_PASSWORD   = '&&3'
def DBLINK_DATABASE_NAME  = '&&4'
def SIMEX_ROOTPATH        = '&&5'

WHENEVER SQLERROR CONTINUE

PROMPT ################################################################################
PROMPT ##
PROMPT ## change DB to restrict mode
PROMPT ##
PROMPT ################################################################################
CONNECT sys/&&SIMEX_DB_SYS_PASSWORD@&&SIMEX_DATABASE_NAME as SYSDBA

shutdown immediate;
startup restrict;

-- ensure that all users of script may connect as restricted
-- alter system enable restricted session;

PROMPT ################################################################################
PROMPT ##
PROMPT ## Disable Jobs
PROMPT ##
PROMPT ################################################################################
@@bin\misc\disable_scheduler.sql

PROMPT ################################################################################
PROMPT ##
PROMPT ## drop perhaps existing tablespace and user SiMEX / and recreate them
PROMPT ##
PROMPT ################################################################################
@@bin\misc\SiMEX_create_TS_and_USER.sql &&SIMEX_ROOTPATH

PROMPT ################################################################################
PROMPT ##
PROMPT ## create directory for output - xml
PROMPT ##
PROMPT ################################################################################

PROMPT ################################################################################
PROMPT ##
PROMPT ## connect to user SiMEX (- needed for further steps -)
PROMPT ##
PROMPT ################################################################################
CONNECT SiMEX/simex@&&SIMEX_DATABASE_NAME

PROMPT ################################################################################
PROMPT ##
PROMPT ## DB link between SiMEX and SIRIUS DB
PROMPT ##
PROMPT ################################################################################
@@bin\DBL_SIMEX_DB_LINK.sql &&DBLINK_SNT_PASSWORD &&DBLINK_DATABASE_NAME

PROMPT ################################################################################
PROMPT ##
PROMPT ## cre SiMEX tables / indexes / constraints / views / ...
PROMPT ##
PROMPT ################################################################################
@@bin\setup_structure_SiMEX.sql

PROMPT ################################################################################
PROMPT ##
PROMPT ## SiMEX packages 
PROMPT ##
PROMPT ################################################################################
@@bin\P_JOB.plh
@@bin\P_JOB.plb

@@bin\PCK_CALCULATION.plh
@@bin\PCK_CALCULATION.plb
grant execute on simex.PCK_CALCULATION to test;

@@bin\PCK_EXPORTS.plh
@@bin\PCK_EXPORTS.plb

@@bin\PCK_EXPORTER.plh
@@bin\PCK_EXPORTER.plb

@@bin\PCK_PARTNER.plh
@@bin\PCK_PARTNER.plb

@@bin\PCK_CONTRACT.plh
@@bin\PCK_CONTRACT.plb

@@bin\PCK_COST.plh
@@bin\PCK_COST.plb

@@bin\PCK_REVENUE.plh
@@bin\PCK_REVENUE.plb

@@bin\PCK_MODPROTO.plh
@@bin\PCK_MODPROTO.plb

PROMPT ################################################################################
PROMPT ##
PROMPT ## SiMEX Triggers
PROMPT ##
PROMPT ################################################################################
@@bin\TRG_TTASK_INITENV.sql

PROMPT ################################################################################
PROMPT ##
PROMPT ## INIT Scheduler Jobs
PROMPT ##
PROMPT ################################################################################
@@bin\misc\create_scheduler_jobs.sql

PROMPT ################################################################################
PROMPT ##
PROMPT ## Enable Jobs
PROMPT ##
PROMPT ################################################################################
@@bin\misc\enable_scheduler.sql

PROMPT ################################################################################
PROMPT ##
PROMPT ## exec AFTER_DDL_STATEMENT to recompile invalid objects
PROMPT ##
PROMPT ################################################################################
set serveroutput on
@@bin\misc\AFTER_DDL_STATEMENT.sql
exec AFTER_DDL_STATEMENT;

PROMPT ################################################################################
PROMPT ##
PROMPT ## Release restriction of database
PROMPT ##
PROMPT ################################################################################

ALTER SYSTEM DISABLE RESTRICTED SESSION;

PROMPT ################################################################################
PROMPT ##
PROMPT ## load SiMEX DAG basedata
PROMPT ##
PROMPT ################################################################################
@@bin\Basedata\DAG\load_SiMEX_basedata.sql

grant execute on simex.pck_calculation to test;
PROMPT ################################################################################
PROMPT ##
PROMPT ## END OF SETUP
PROMPT ##
PROMPT ################################################################################
PROMPT #
EXIT;