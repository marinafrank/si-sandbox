@echo off  
CLS
ECHO **********************************************************************************
ECHO *                                                                                *
ECHO *       M I G R A T I O N   s c r i p t    l a u n c h e r                       *
ECHO *                                                                                *
ECHO **********************************************************************************

set NLS_LANG=.AL32UTF8
chcp 65001

:AUTOMATION
if [%1]==[] GOTO MANUAL
SET DBLINK_DATABASE_NAME=%1
SET DBLINK_SNT_PASSWORD=%2
SET SCOPING_SCOPEDATE=%3
SET SCOPING=
SET SCOPE_DATE=
if not x%SCOPING_SCOPEDATE:_=%==x%SCOPING_SCOPEDATE% (for /F "tokens=1,2 delims=_" %%a in ("%SCOPING_SCOPEDATE%") do (
SET SCOPING=%%%a
SET SCOPE_DATE=%%%b
SET FORCE_INS=Y
SET FORCE_OOS=Y
)) else SET SCOPE_DATE=%SCOPING_SCOPEDATE%

SET COUNTRY=%4
SET EXTRACT=%5
SET SIMEX_ROOTPATH=%6
SET SIMEX_DB=%7
SET SIMEX_PASSWORD=%8
SET SIMEX_DB_SYS_PASSWORD=%9
ECHO * === Database selected by Paramter: %DBLINK_DATABASE_NAME% ===
ECHO * === SIMEX-DB selected by Paramter: %SIMEX_DB% ===
SET AUTORUN=TRUE

GOTO CHECK


:MANUAL
REM **********************************************************************************
rem Manuelle Eingaben, sofern keine Parameter mitgegeben wurden.
REM **********************************************************************************
ECHO *
ECHO * Please enter name of Country DB 
SET /P DBLINK_DATABASE_NAME=* (e.g.: MB-DB.server.prd)      and press [Enter]:  
ECHO *
SET /P DBLINK_SNT_PASSWORD=* Please enter password of SNT user of Country - DB    and press [Enter]:  
ECHO *
SET /P SCOPE_DATE=* Please enter SCOPINg DATE for Country - DB (01.01.2000)   and press [Enter]:  
ECHO *
ECHO * Please enter scoping variant (Scope A, B, 0) and press [Enter]: 
SET /P SCOPING=* and press [Enter]:   
ECHO *
ECHO * Do you wish explicit InScopeContractList to be loaded? Enter Y or N and press [Enter]: 
SET /P FORCE_INS=* and press [Enter]:   
ECHO *
ECHO * Do you wish explicit OutOfScopeContractList to be loaded? Enter Y or N and press [Enter]: 
SET /P FORCE_OOS=* and press [Enter]:   
ECHO *
SET /P COUNTRY=* Please enter COUNTRY CODE (e.g.MBBEL)  and press [Enter]:  
ECHO *
ECHO * Please enter filesystem root path for the SiMEX xml - outbox
SET /P SIMEX_ROOTPATH=* (e.g.: C:\SiMEX)         and press [Enter]:  
ECHO *
SET /P SIMEX_DB=* == Please enter SIMEX Database and press [Enter]:  
ECHO *
SET /P SIMEX_PASSWORD=* == Please enter SIMEX Password and press [Enter]:  
ECHO *
SET /P SIMEX_DB_SYS_PASSWORD=* == Please enter password of SYS user of SiMEX  - DB and press [Enter]:  
ECHO *
SET /P EXTRACT=* DO YOU WANT TO START EXTRACTION IMMEDIATELY  (Y/N; Default N) and press [Enter]:  
ECHO *


:CHECK
REM **********************************************************************************
rem check der Eingaben
REM **********************************************************************************

IF "%DBLINK_DATABASE_NAME%"=="" (
 SET SUCCESSSTATUS=not sucessful - no Country DB name defined
 GOTO ENDE
)
IF "%DBLINK_SNT_PASSWORD%"=="" (
 SET SUCCESSSTATUS=not sucessful - SNT password of country DB is missing
 GOTO ENDE
)

IF "%SCOPE_DATE%"=="" (
 SET SUCCESSSTATUS=not sucessful - NO SCOPING DATE DELIVERED
 GOTO ENDE
)

IF "%SCOPING%"=="" (
 SET SUCCESSSTATUS=not sucessful - NO SCOPING BASE DELIVERED
 GOTO ENDE
)

IF "%SIMEX_DB_SYS_PASSWORD%"=="" (
 SET SUCCESSSTATUS=not sucessful - SYS password of SiMEX DB is missing
 GOTO ENDE
)

IF "%EXTRACT%"=="" (
  SET EXTRACT=N
)

IF "%SIMEX_PASSWORD%"=="" (
  SET EXTRACT=N
)

IF "%EXTRACT%"=="Y" Goto ASKSIMEXROOT
IF "%EXTRACT%"=="y" Goto ASKSIMEXROOT

GOTO RUN

:ASKSIMEXROOT
IF "%SIMEX_ROOTPATH%"=="" (
 SET SUCCESSSTATUS=not sucessful - NO SIMEX PATH DELIVERED
 GOTO ENDE
)

:RUN
ECHO **********************************************************************************
echo *
echo * processing. please wait ...
echo *
ECHO **********************************************************************************
rem 1st: set unicode codepage for sqlplus
set NLS_LANG=.AL32UTF8
REM STORE currentDIR
SET MAINPATH=%CD%
chcp

ECHO *
ECHO **********************************************************************************
echo ***                                                                            ***
echo ***  Configuring LogfileFolder                                                 ***
echo ***                                                                            ***
ECHO **********************************************************************************
ECHO *

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
REM echo hour=%hour%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
REM echo min=%min%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
REM echo secs=%secs%

set year=%date:~-4%
REM echo year=%year%
set month=%date:~3,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
REM echo month=%month%
set day=%date:~0,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%
REM echo day=%day%

set logfilefolder1=%CD%\Migration-Log_%DBLINK_DATABASE_NAME%_%year%-%month%-%day%_%hour%-%min%-%secs%
echo Logfile folder is: %logfilefolder1%

mkdir %logfilefolder1%
mkdir %logfilefolder1%\Objects
mkdir %logfilefolder1%\Checks

set logfilefolder=%logfilefolder1%\Checks

mkdir %logfilefolder%\AdditionalChecks
mkdir %logfilefolder%\CleansingLogs
mkdir %logfilefolder%\SystemLogs
mkdir %logfilefolder%\Healthcheck
mkdir %logfilefolder%\Objectchecks

echo *

:SCOPE
ECHO * Starting in %CD%
cd run_in_each_iteration

ECHO *
ECHO **********************************************************************************
ECHO *** SCOPING DATABASE - EXECUTING SCRIPTS out of SCOPE\%COUNTRY%      
ECHO ***                                                                            ***
ECHO ***                                                                            ***
ECHO *** using Autocommit                                                           ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd SCOPE
cd %COUNTRY%
ECHO * Go to %CD%

SET SCOPE_TYPE=A
SET FORCE_INS=Y
SET FORCE_OOS=Y

sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @Set_Contracts_out_of_scope.sql AUTOCOMMIT %SCOPE_DATE% %SCOPING% %DBLINK_SNT_PASSWORD% %FORCE_INS% %FORCE_OOS%
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @Set_customer_out_of_scope.sql AUTOCOMMIT
xcopy *.log %logfilefolder%\CleansingLogs\*.log
del *.log /Q
cd ..
ECHO * Go to %CD%
cd ..
ECHO * Go to %CD%

:CLEANSING
chcp
ECHO **********************************************************************************
ECHO *** UPDATING DATABASE - EXECUTING PATCHES out of CLEANSING\ALL_COUNTRIES 
ECHO ***                                                                            ***
ECHO ***                                                                            ***
ECHO *** ==> using Autocommit                                                       ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CLEANSINGS
cd SIRIUS
cd ALL_COUNTRIES
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT MIGRATION
)
xcopy *.log %logfilefolder%\CleansingLogs\*.log
del *.log /Q

ECHO *
ECHO **********************************************************************************
ECHO *** UPDATING DATABASE - EXECUTING PATCHES out of CLEANSING\%COUNTRY%
ECHO ***                                                                            ***
ECHO ***                                                                            ***
ECHO *** ==> using Autocommit                                                       ***
ECHO ***                                                                            ***
ECHO **********************************************************************************
ECHO *

cd %MAINPATH%
cd run_in_each_iteration
cd CLEANSINGS
cd SIRIUS
cd %COUNTRY%
ECHO * Go to %CD%
for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT MIGRATION
)
xcopy *.log %logfilefolder%\CleansingLogs\*.log
del *.log /Q
cd ..
ECHO * Go to %CD%
cd ..
ECHO * Go to %CD%
cd ..
ECHO * Go to %CD%


:ADDITIONALCHECKS
ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO *** EXECUTING CHECKS IN .\GENERAl\PartnerCheck ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CHECKS
cd PartnerCheck
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO *** EXECUTING CHECKS IN .\GENERAl\ContractCheck ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CHECKS
cd ContractCheck
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO *** EXECUTING CHECKS IN .\GENERAl\CostCheck ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CHECKS
cd CostCheck
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO *** EXECUTING CHECKS IN .\GENERAl\RevenueCheck ***
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CHECKS
cd RevenueCheck
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q



:HEALTHCHECK

cd %MAINPATH%
cd ..
cd Healthcheck
ECHO * Go to %CD%

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Executing Healthcheck JOB
ECHO ***                                                                            ***
ECHO **********************************************************************************

sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @create_healthcheck_job.sql

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Updating Healthcheck source
ECHO ***                                                                            ***
ECHO **********************************************************************************


start /WAIT Update_healthcheck.bat %DBLINK_DATABASE_NAME% %DBLINK_SNT_PASSWORD%

xcopy *.log %logfilefolder%\SystemLogs\*.log
del *.log /Q

cd ..
ECHO * Go to %CD%
cd Scripts
ECHO * Go to %CD%

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Updating Simex
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd ..
cd simex
ECHO * Go to %CD%

start /WAIT start_cre_simex_db.bat %SIMEX_ROOTPATH% %SIMEX_DB% %DBLINK_DATABASE_NAME% %SIMEX_DB_SYS_PASSWORD% %DBLINK_SNT_PASSWORD%

xcopy *.log %logfilefolder%\SystemLogs\*.log
del *.log /Q

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Updating Simex Masterdata
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd %MAINPATH%
cd ..
cd simex
cd Masterdata
ECHO * Go to %CD%

chcp

sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @TSETTING_%COUNTRY%.sql AUTOCOMMIT
sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @TSUBSTITUTE_%COUNTRY%.sql AUTOCOMMIT 
sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @TProducthouse_%COUNTRY%.sql AUTOCOMMIT

xcopy *.log %logfilefolder%\SystemLogs\*.log
del *.log /Q

cd ..
ECHO * Go to %CD%

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Executing Simex CLEANSING scripts - ALL COUNTRIES
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CLEANSINGS
cd SIMEX
cd ALL_COUNTRIES
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Executing Simex CLEANSING scripts - %COUNTRY%
ECHO ***                                                                            ***
ECHO **********************************************************************************


cd %MAINPATH%
cd run_in_each_iteration
cd CLEANSINGS
cd SIMEX
cd %COUNTRY%
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\CleansingLogs\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\CleansingLogs\*.lst
del *.lst /Q


ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Executing Simex Analysis scripts
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
cd run_in_each_iteration
cd CHECKS
cd SimexCheck
ECHO * Go to %CD%

for /R %%F in (*.sql) do ( 
echo *** EXECUTING %%~NxF
sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @%%~NxF AUTOCOMMIT
)
xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q


xcopy *.log %logfilefolder%\AdditionalChecks\*.log
del *.log /Q
xcopy *.lst %logfilefolder%\AdditionalChecks\*.lst
del *.lst /Q



ECho * Execute_Extraktion chosen: "%EXTRACT%"

if "%EXTRACT%"=="y" GOTO DOTHESIMEX
if "%EXTRACT%"=="Y" GOTO DOTHESIMEX

SET SUCCESSSTATUS=sucessful without extraction
GOTO ENDE

:DOTHESIMEX

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Set extraction tasks
ECHO ***                                                                            ***
ECHO **********************************************************************************
ECHO * Running SIMEX VT

SET OLDDIR = %CD%
cd %SIMEX_ROOTPATH%\SIMEx-VT\

@ECHO ON

C:
ECHO * Go to %CD%
SiMExVT_64.exe

O:
ECHO * Copy SIMEX VT Logfiles and results
xcopy %SIMEX_ROOTPATH%\LOGS\*.csv %logfilefolder%\Objectchecks\ 
xcopy %SIMEX_ROOTPATH%\LOGS\Extraktion_Validierung.log %logfilefolder%\Objectchecks\ 
xcopy %SIMEX_ROOTPATH%\LOGS\*.log %logfilefolder%\SystemLogs\ 

ECHO * Copy Object Export files
xcopy %SIMEX_ROOTPATH%\*.csv %logfilefolder1%\Objects\*.csv 
xcopy %SIMEX_ROOTPATH%\*.xml %logfilefolder1%\Objects\*.xml 

@ECHO OFF
ECHO ***                                                                            ***
ECHO * Script successfully executed...
SET SUCCESSSTATUS=sucessful with extraction
echo *
GOTO ENDE


:ENDE
ECHO ******************************************************************************
ECHO *                                                                            *
ECHO           Script finished %SUCCESSSTATUS%                                    
ECHO *                                                                            *
ECHO ******************************************************************************
IF "%AUTORUN%"=="" (
SET /P EXIT_PARAMETER=*         * * * * * Press [Enter] to close. * * * * * 
)
ECHO *DONE*
