SET SCOPE_DATE=01.01.2011
SET SCOPE_TYPE=A
rem SET DBLINK_SNT_PASSWORD=Tss2007$
SET DBLINK_SNT_PASSWORD=snt
SET DBLINK_DATABASE_NAME=ref.s415mt217.tst

sqlplus -s snt/%DBLINK_SNT_PASSWORD%@%DBLINK_DATABASE_NAME% @set_oos_POC.sql AUTOCOMMIT %SCOPE_DATE% %SCOPE_TYPE% %DBLINK_SNT_PASSWORD%