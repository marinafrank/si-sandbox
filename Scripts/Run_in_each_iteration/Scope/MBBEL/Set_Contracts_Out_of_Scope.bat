@echo off  
CLS
ECHO **********************************************************************************
ECHO *                                                                                *
ECHO *       Set Contract OOS SQL  s c r i p t  l a u n c h e r                       *
ECHO *                                                                                *
ECHO **********************************************************************************

set NLS_LANG=.AL32UTF8
chcp 65001


:AUTOMATION
if [%1]==[] GOTO MANUAL
SET DBLINK_SNT_PASSWORD=%1
SET DBLINK_DATABASE_NAME = %2
SET AUTOCOMMIT=%3
SET SCOPE_DATE=%4
SET SCOPE_TYPE=%5
SET FORCED_OOS=%6
SET AUTORUN=TRUE

GOTO CHECK

:MANUAL
REM **********************************************************************************
rem Manuelle Eingaben, sofern keine Parameter mitgegeben wurden.
REM **********************************************************************************
ECHO *
SET /P DBLINK_SNT_PASSWORD=* Please enter password of SNT user of Country - DB    and press [Enter]:  
ECHO *
SET /P DBLINK_DATABASE_NAME=* Please enter database name (e.g db1.s415vm779.tst)   and press [Enter]:  
ECHO *
SET /P SCOPE_DATE=* Please enter SCOPING DATE for Country - DB (01.01.2011)   and press [Enter]:  
ECHO *
SET /P SCOPE_TYPE=* Please enter SCOPE_TYPE (0, A, B)  and press [Enter]:  
ECHO *
SET /P FORCED_OOS=* Do we have contracts forced OOS?(Y/N)         and press [Enter]:  
ECHO *
ECHO * Please set if we will be using AUTOCOMMIT.
SET /P AUTOCOMMIT=* (AUTCOMMIT)      and press [Enter]:  
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

IF "%SCOPE_TYPE%"=="" (
 SET SUCCESSSTATUS=not sucessful - SCOPE_TYPE is missing
 GOTO ENDE
)

IF "%FORCED_OOS%"=="" (
 SET SUCCESSSTATUS=not sucessful - FORCED_OOS decision is missing
 GOTO ENDE
)


:RUN
ECHO **********************************************************************************
echo *
echo * processing. please wait ...
echo *
ECHO **********************************************************************************

rem echo on
set ERGEBNIS=
IF "%FORCED_OOS%"=="Y" (
	Setlocal EnableDelayedExpansion
	for /f "usebackq tokens=1-2 delims=;" %%a in ("Additional_OutOfScope.csv") do set ERGEBNIS=%%a/%%b+!ERGEBNIS!
	rem echo set ERGEBNIS now...
	set ERGEBNIS=!ERGEBNIS:~0,-1!
	rem echo set ERGEBNIS done...
	rem echo Ergebnis: %ERGEBNIS%
	sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @Set_Contracts_out_of_scope.sql %AUTOCOMMIT% %SCOPE_DATE% %SCOPE_TYPE% !ERGEBNIS!
	) ELSE (
	sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @Set_Contracts_out_of_scope.sql %AUTOCOMMIT% %SCOPE_DATE% %SCOPE_TYPE% 0
	)

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