@echo off
ECHO * Echo THIS SCRIPT UPDATES HEALTHCHECK FILES IN SIRIUS DB
:AUTO
if [%1]==[] GOTO MANUAL 
Set Database=%1
Set Password=%2
Set AUTORUN=TRUE
GOTO CHECK

:MANUAL
SET /P Database=Please enter Sirius DB to be patched and press [Enter]: 
SET /P Password=Please enter SNT password and press [Enter]: 

:CHECK
if "%Database%"=="" (
  Set SuccessStatus=not successful - missing DB Name
GOTO ENDE
)

if "%Password%"=="" (
  Set SuccessStatus=not successful - missing Password
GOTO ENDE
)


:RUN
SQLPLUS snt/%Password%@%Database% @upd_SiMEx_healthcheck.sql


Set SuccessStatus=successfully executed, please check Log file

:ENDE
ECHO %SuccessStatus%

IF "%AUTORUN%"=="" (
SET /P EXIT_PARAMETER=*         * * * * * Press [Enter] to close. * * * * * 
)
exit