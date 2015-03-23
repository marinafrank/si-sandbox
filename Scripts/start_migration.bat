@echo off

ECHO **********************************************************************************
ECHO *                                                                                *
ECHO *       M I G R A T I O N   s c r i p t    l a u n c h e r                       *
ECHO *                                                                                *
ECHO **********************************************************************************
ECHO *
SET /P COUNTRY=* Please enter COUNTRY CODE (e.g.MBBEL)  and press [Enter]:  
ECHO *
ECHO * Please enter number of Extraction Area (1, 2, 3, 4, REF)  (e.g. "1" for db1 and simex1)
SET /P DBID=* and press [Enter]:  
ECHO *
ECHO * Please enter scoping date (all contracts ending before this date will be excluded): 
SET /P DATUM=* and press [Enter]:   
ECHO *
ECHO * Please enter scoping variant (Scope A, B, 0). Defaults to B: 
SET /P SCOPING=* and press [Enter]:   
ECHO *
SET /P EXTRACT=* DO YOU WANT TO START EXTRACTION IMMEDIATELY  (Y/N; Default N) and press [Enter]:  
ECHO *

IF "%EXTRACT%"=="" (
  SET EXTRACT=N
)

IF "%SCOPING%"=="" (
  SET SCOPING=B
)

IF "%DBID%"=="" (
 SET SUCCESSSTATUS=not sucessful - no Extraction Area defined
 GOTO ENDE
)

IF "%COUNTRY%"=="" (
 SET SUCCESSSTATUS=not sucessful - no Country ID defined
 GOTO ENDE
)


echo EXECUTING ... PLEASE WAIT.

REM ###############################################
REM Parameterlist for migration_script_launcher.bat
REM DBLINK_DATABASE_NAME=%1
REM DBLINK_SNT_PASSWORD=%2
REM SCOPING_SCOPEDATE=%3
REM COUNTRY=%4
REM EXTRACT=%5
REM SIMEX_ROOTPATH=%6
REM SIMEX_DB=%7
REM SIMEX_PASSWORD=%8
REM SIMEX_DB_SYS_PASSWORD=%9
REM ###############################################

if "%DBID%"=="REF" (
GOTO REF
)

 migration_script_launcher.bat db%DBID%.s415vm779.tst Tss2007$ %SCOPING%_%DATUM% %COUNTRY% %EXTRACT% c:\simex\simex%DBID% simex%DBID%.s415vm779.tst simex Tss2007$ > MigrationLog_%COUNTRY%_db%DBID%_simex%DBID%.log
SET SUCCESSSTATUS=sucessful

GOTO ENDE

:REF
 migration_script_launcher.bat %DBID%.s415vm779.tst Tss2007$ %SCOPING%_%DATUM% %COUNTRY% %EXTRACT% c:\simex\simex simex.s415vm779.tst simex Tss2007$ > MigrationLog_%COUNTRY%_%DBID%_simex.log
SET SUCCESSSTATUS=sucessful

GOTO ENDE

:ENDE
ECHO ******************************************************************************
ECHO *                                                                            *
ECHO           Script finished %SUCCESSSTATUS%                                    
ECHO *                                                                            *
ECHO ******************************************************************************
SET /P EXIT_PARAMETER=*         * * * * * Press [Enter] to close. * * * * * 
ECHO *DONE*

