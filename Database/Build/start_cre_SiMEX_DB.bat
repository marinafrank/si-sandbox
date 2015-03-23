@echo off
ECHO ******************************************************************************
ECHO *                                                                            *
ECHO *                  S i M E X      I N S T A L L A T I O N                    *
ECHO *                                                                            *
ECHO ******************************************************************************
ECHO *                                                                            *
ECHO *      Welcome upgrader - Please choose:                                     *
ECHO *                                                                            *
ECHO *       [1]= Install SiMEX DB                                                *
ECHO *                                                                            *
ECHO *       [0]= Cancel                                                          *
ECHO *                                                                            *
ECHO *            Choose and press [Enter]:                                       *
ECHO *                                                                            *
ECHO ******************************************************************************

:SIMEXAUTOMATION
if [%1]==[] GOTO SIMEXMANUAL
SET SIMEX_ROOTPATH=%1
SET SIMEX_DATABASE_NAME=%2
SET DBLINK_DATABASE_NAME=%3
SET SIMEX_DB_SYS_PASSWORD=%4
SET DBLINK_SNT_PASSWORD=%5
SET INSTALL_TYPE=1

ECHO * === Database selected by Paramter: %DBLINK_DATABASE_NAME% ===
ECHO * === SIMEX-DB selected by Paramter: %SIMEX_DATABASE_NAME% ===
SET AUTORUN=TRUE

GOTO SIMEXCHECK


:SIMEXMANUAL
REM **********************************************************************************
rem Manuelle Eingaben, sofern keine Parameter mitgegeben wurden.
REM **********************************************************************************
SET /P INSTALL_TYPE= Selection: 

IF "%INSTALL_TYPE%"=="0" (
SET SUCCESSSTATUS=not sucessful - Execution was cancelled!
GOTO ENDE
)

ECHO * Please enter filesystem root path for the SiMEX xml - outbox
SET /P SIMEX_ROOTPATH=* (e.g.: C:\SiMEX)         and press [Enter]:  
ECHO *
ECHO * Please enter SiMEX DB name
SET /P SIMEX_DATABASE_NAME=* (e.g.: SiMEX.server.prd) and press [Enter]:  
ECHO *
ECHO * Please enter name of DB link 
SET /P DBLINK_DATABASE_NAME=* (e.g.: MB-DB.server.prd) and press [Enter]:  
ECHO *
SET /P SIMEX_DB_SYS_PASSWORD=* Please enter password of SYS user of SiMEX  - DB and press [Enter]:  
ECHO *
SET /P DBLINK_SNT_PASSWORD=* Please enter password of SNT user of DBlink - DB and press [Enter]:  
ECHO *
ECHO *
ECHO *

:SIMEXCHECK
REM **********************************************************************************
REM Checking Values
REM **********************************************************************************

IF "%SIMEX_ROOTPATH%"=="" (
 SET SUCCESSSTATUS=not sucessful - Root path is missing
 GOTO SIMEXENDE
)
IF "%SIMEX_DATABASE_NAME%"=="" (
 SET SUCCESSSTATUS=not sucessful - no SiMEX DB name defined
 GOTO SIMEXENDE
)
IF "%DBLINK_DATABASE_NAME%"=="" (
 SET SUCCESSSTATUS=not sucessful - no DB-Link name defined
 GOTO SIMEXENDE
)
IF "%SIMEX_DB_SYS_PASSWORD%"=="" (
 SET SUCCESSSTATUS=not sucessful - SYS password of SiMEX DB is missing
 GOTO SIMEXENDE
)
IF "%DBLINK_SNT_PASSWORD%"=="" (
 SET SUCCESSSTATUS=not sucessful - SNT password of DB-Link DB is missing
 GOTO SIMEXENDE
)

:SIMEXRUN
REM **********************************************************************************
REM DOING THINGS
REM **********************************************************************************

IF "%INSTALL_TYPE%"=="1" (
     ECHO * ATTENTION: The script is going to shut down the database immediately. 
     ECHO *            Please ensure that no other users are connected to the database.
     IF "%AUTORUN%"=="" (
       SET /P shutdown_check=*            Press [ENTER] to proceed or [Strg]+[C] to abort
     )
     echo *


 REM Creating Direcories
 Echo * Creating Directories in folder %SIMEX_ROOTPATH%
 mkdir %SIMEX_ROOTPATH%
 ECHO * Direcories sucessfully created...
 echo *
 
 REM set unicode codepage for sqlplus
 set NLS_LANG=.AL32UTF8
 sqlplus /nolog @bin\start_cre_SiMEX_DB.sql %SIMEX_DB_SYS_PASSWORD% %SIMEX_DATABASE_NAME% %DBLINK_SNT_PASSWORD% %DBLINK_DATABASE_NAME% %SIMEX_ROOTPATH%

 ECHO * Upgradescript successfully executed...
 SET SUCCESSSTATUS=sucessful
 echo *
 GOTO SIMEXENDE
)

:SIMEXENDE
ECHO ******************************************************************************
ECHO *                                                                            *
ECHO           Script finished %SUCCESSSTATUS%                                    
ECHO *                                                                            *
ECHO ******************************************************************************

if "%AUTORUN%"=="" (
SET /P EXIT_PARAMETER=*         * * * * * Press [Enter] to close. * * * * * 
)

ECHO *DONE*
exit
