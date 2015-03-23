@echo off  
CLS
ECHO **********************************************************************************
ECHO *                                                                                *
ECHO *       M I G R A T I O N   SIMEX Rebuilder                                      *
ECHO *                                                                                *
ECHO **********************************************************************************

set NLS_LANG=.AL32UTF8
chcp 65001

:AUTOMATION
if [%1]==[] GOTO MANUAL
SET DBLINK_DATABASE_NAME=%1
SET DBLINK_SNT_PASSWORD=%2
SET COUNTRY=%3
SET EXTRACT=%4
SET SIMEX_ROOTPATH=%5
SET SIMEX_DB=%6
SET SIMEX_PASSWORD=%7
SET SIMEX_DB_SYS_PASSWORD=%8
ECHO * === Database selected by Paramter: %DBLINK_DATABASE_NAME% ===
ECHO * === SIMEX-DB selected by Paramter: %SIMEX_DB% ===
SET AUTORUN=TRUE

GOTO CHECK


:MANUAL
REM **********************************************************************************
rem Manuelle Eingaben, sofern keine Parameter mitgegeben wurden.
REM **********************************************************************************
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
ECHO * Please enter name of Country DB 
SET /P DBLINK_DATABASE_NAME=* (e.g.: MB-DB.server.prd)      and press [Enter]:  
ECHO *
SET /P COUNTRY=* Please enter COUNTRY CODE (e.g.MBBEL)  and press [Enter]:  
ECHO *
SET /P DBLINK_SNT_PASSWORD=* Please enter password of SNT user of Country - DB    and press [Enter]:  
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
SET DATUM=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
SET ZEIT=%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%

set logfilefolder=%CD%\SimexRebuild-Log_%SIMEX_DB%_%DATUM%_%ZEIT%

mkdir %logfilefolder%
mkdir %logfilefolder%\SystemLogs
echo *

ECHO *
ECHO **********************************************************************************
ECHO ***                                                                            ***
ECHO ***  Updating Simex
ECHO ***                                                                            ***
ECHO **********************************************************************************

cd %MAINPATH%
ECHO * Go to %CD%

cd ..
ECHO * Go to %CD%
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

cd extraction
ECHO * Go to %CD%

sqlplus -s simex/%SIMEX_PASSWORD%@%SIMEX_DB% @set_extraction_jobs_%COUNTRY%.sql AUTOCOMMIT

xcopy *.log %logfilefolder%\SystemLogs\*.log
del *.log /Q

REM ==> Wieder zurück auf Pfad Scripts!
cd ..
ECHO * Go to %CD%
cd ..
ECHO * Go to %CD%
cd Scripts
ECHO * Go to %CD%


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

