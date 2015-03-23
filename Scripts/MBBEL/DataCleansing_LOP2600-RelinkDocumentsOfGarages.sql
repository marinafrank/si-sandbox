-- DataCleansing_LOP2600-RelinkDocumentsOfGarages.sql

-- FraBe     11.09.2013 MKS-128302:1 / LOP2600: creation
-- FraBe     17.09.2013 MKS-128302:2 / LOP2600: change 2 workshop IDs

spool DataCleansing_LOP2600-RelinkDocumentsOfGarages.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size unlimited format truncated
set lines        999
set pages        0

variable L_ERROR_OCCURED number;
exec :L_ERROR_OCCURED    := 0;
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 100 char );
exec :L_SCRIPTNAME       := 'DataCleansing_LOP2600-RelinkDocumentsOfGarages.sql';

prompt

whenever sqlerror exit sql.sqlcode

declare

   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   L_SYSDBA_PRIV_NEEDED    boolean                         := false;          -- false or true
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -- 2) unter welchem user muß das script laufen?
   L_SOLLUSER              VARCHAR2 ( 30 char ) := 'SNT';
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -): 
   L_MAJOR_MIN             integer := 2;
   L_MINOR_MIN             integer := 8;
   L_REVISION_MIN          integer := 0;
   L_BUILD_MIN             integer := 0;

   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   -- 4) falls das script nur gegen ein einziges MPC laufen darf, hier true angeben, bzw. den namen des MPC: 
   L_MPC_CHECK             boolean                         := true;           -- false or true
   L_MPC_SOLL              snt.TGLOBAL_SETTINGS.VALUE%TYPE := 'MBBeLux';
   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName' );

   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
   L_REEXEC_FORBIDDEN      boolean                         := true;           -- false or true
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
   
   -- weitere benötigte variable
   L_ABBRUCH               boolean := false;

begin

   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   if   L_SYSDBA_PRIV_NEEDED
   then begin
          select 'Y'
             into L_SYSDBA_PRIV 
             from SESSION_PRIVS 
            where PRIVILEGE = 'SYSDBA';
        exception when NO_DATA_FOUND 
                  then dbms_output.put_line ( 'Executing user is not ' || upper ( L_SOLLUSER ) || ' / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || ' / SYSDABA' || chr(10) );
                       L_ABBRUCH := true;
        end;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user 
   if   L_ISTUSER is null or upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then dbms_output.put_line ( 'Executing user is not ' || upper ( L_SOLLUSER ) || '!'
                             || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || chr(10) );
        L_ABBRUCH := true;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   if      L_MAJOR_IST > L_MAJOR_MIN
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST > L_REVISION_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST = L_REVISION_MIN and L_BUILD_IST >= L_BUILD_MIN )
   then  null;
   else  dbms_output.put_line ( 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || L_MAJOR_MIN || '.' || L_MINOR_MIN || '.' || L_REVISION_MIN || '.' || L_BUILD_MIN || chr(10) );
         L_ABBRUCH := true;
   end   if;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   if   L_MPC_CHECK and L_MPC_IST <> L_MPC_SOLL 
   then dbms_output.put_line ( 'This script can be executed against a ' || L_MPC_SOLL || ' DB only!'
                              || chr(10) || 'You are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
        L_ABBRUCH := true;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   if   L_REEXEC_FORBIDDEN 
   then begin
              select to_char ( LE_CREATED, 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
	              from snt.TLOG_EVENT e
	             where GUID_LA = '10'         -- maintenance
	               and exists ( select null
	                              from snt.TLOG_EVENT_PARAM ep
	                             where ep.LEP_VALUE = :L_SCRIPTNAME
                              and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME
                              || chr(10) || 'It cannot be executed a 2nd time!' || chr(10) );
              L_ABBRUCH := true;
        exception when NO_DATA_FOUND then null;
        end;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- raise if at least one check above failed
  if   L_ABBRUCH
  then raise_application_error ( -20000, '==> Script Execution cancelled <==' );
  end  if;
end;
/

WHENEVER SQLERROR CONTINUE

accept commit_or_rollback prompt "Do you want to save the changes to the DB? Y/N: "

prompt
prompt processing. please wait ...
prompt

set termout      off
set sqlprompt    'SQL>'
set pages        9999
set lines        9999
set serveroutput on   size unlimited
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
alter trigger snt.FK_CHECK_TGARAGE disable;

set feedback     on
set feedback     1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- main part for < selecting or checking or correcting code >

declare
     procedure conv_garage
             ( I_ID_GARAGE_OLD        integer
             , I_ID_GARAGE_NEW        integer ) is
               L_GUID_PARTNER_OLD     snt.TPARTNER.GUID_PARTNER%type;
               L_GUID_PARTNER_NEW     snt.TPARTNER.GUID_PARTNER%type;
               old_ID_not_exists      exception;
               new_ID_not_exists      exception;

     begin

           -- 1st: check if old ID_GARAGE exists
           begin 
                select   GUID_PARTNER 
                  into L_GUID_PARTNER_OLD
                  from snt.TPARTNER
                 where ID_GARAGE = I_ID_GARAGE_OLD;
           exception when NO_DATA_FOUND then raise old_ID_not_exists;
           end;

           -- 2nd: check if new ID_GARAGE exists
           begin 
                select   GUID_PARTNER 
                  into L_GUID_PARTNER_NEW
                  from snt.TPARTNER
                 where ID_GARAGE = I_ID_GARAGE_NEW;
           exception when NO_DATA_FOUND then raise new_ID_not_exists;
           end;

           -- 3rd: change old ID_GARAGE to new one
           
           update snt.TFZGRECHNUNG            set GUID_PARTNER           = L_GUID_PARTNER_NEW where GUID_PARTNER     = L_GUID_PARTNER_OLD;
           update snt.TFZGVERTRAG             set ID_GARAGE              = I_ID_GARAGE_NEW    where ID_GARAGE        = I_ID_GARAGE_OLD;
					 update snt.TFZGVERTRAG             set ID_GARAGE_SERV         = I_ID_GARAGE_NEW    where ID_GARAGE_SERV   = I_ID_GARAGE_OLD;
           update snt.TVERTRAGSTAMM           set ID_GARAGE              = I_ID_GARAGE_NEW    where ID_GARAGE        = I_ID_GARAGE_OLD;
           update snt.TREP_RELEASE            set ID_GARAGE              = I_ID_GARAGE_NEW    where ID_GARAGE        = I_ID_GARAGE_OLD;
           update snt.TGAR_ITEM               set ID_GARAGE              = I_ID_GARAGE_NEW    where ID_GARAGE        = I_ID_GARAGE_OLD;
           
           -- 4th: delete old obsolete ID_GARAGE
           delete from snt.TGARAGE   where ID_GARAGE  = I_ID_GARAGE_OLD;
           delete from snt.TPARTNER  where ID_GARAGE  = I_ID_GARAGE_OLD;
           
           dbms_output.put_line ( 'Workshop ' || to_char ( I_ID_GARAGE_OLD, '99990' )  || ' successfully converted to ' || to_char ( I_ID_GARAGE_NEW, '99990' ) );

     exception 
           when old_ID_not_exists then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                                       dbms_output.put_line ( 'Workshop ' || to_char ( I_ID_GARAGE_OLD, '99990' ) || ' cannot be converted to ' 
                                                                          || to_char ( I_ID_GARAGE_NEW, '99990' ) || ' as not existing!' );
           when new_ID_not_exists then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                                       dbms_output.put_line ( 'Workshop ' || to_char ( I_ID_GARAGE_OLD, '99990' ) || ' cannot be converted to ' 
                                                                          || to_char ( I_ID_GARAGE_NEW, '99990' ) || ' as the new one is not existing!' );
     end;

begin
  -- conv_garage ( ID_GARAGE_OLD, ID_GARAGE_NEW );
     conv_garage (   998,          1047 );
     conv_garage (  1005,          1277 );
     conv_garage (  1010,          1275 );
     conv_garage (  1011,          1363 );
     conv_garage (  1017,          1359 );
     conv_garage (  1024,         90049 );
     conv_garage (  1026,          1370 );
     conv_garage (  1027,         70029 );
     conv_garage (  1029,          1301 );
     conv_garage (  1030,          1301 );
     conv_garage (  1032,         70032 );
     conv_garage (  1035,         70027 );
     conv_garage (  1036,          1283 );
     conv_garage (  1039,          1302 );
     conv_garage (  1045,          1373 );
     conv_garage (  1053,          1303 );
     conv_garage (  1055,          1310 );
     conv_garage (  1060,          1370 );
     conv_garage (  1061,          1372 );
     conv_garage (  1062,          1370 );
     conv_garage (  1063,          1271 );
     conv_garage (  1096,          1309 );
     conv_garage (  1116,          1374 );          -- MKS-128302:2
     conv_garage (  1121,          1028 );
     conv_garage (  1151,          1155 );
     conv_garage (  1184,          1312 );
     conv_garage (  1218,          1301 );
     conv_garage (  1220,          1310 );
     conv_garage (  1222,          1289 );
     conv_garage (  1230,          1274 );
     conv_garage (  1247,          1396 );          -- MKS-128302:2
     conv_garage (  1248,          1047 );
     conv_garage (  1249,          1252 );
     conv_garage (  1258,          1278 );
     conv_garage (  1259,          1286 );
     conv_garage (  1292,          1304 );
     conv_garage (  1300,          1299 );
     conv_garage (  1318,          1340 );
     conv_garage (  1350,          1371 );
     conv_garage (  1351,          1372 );
     conv_garage (  1352,          1371 );
     conv_garage (  1376,          1370 );
     conv_garage (  4032,          5233 );
     conv_garage (  4033,          5177 );
     conv_garage (  5004,          5112 );
     conv_garage (  5008,          1391 );
     conv_garage (  5028,          7001 );
     conv_garage (  5113,          5249 );
     conv_garage (  5128,          5176 );
     conv_garage (  5140,          5172 );
     conv_garage (  5180,          5220 );
     conv_garage (  5190,          5260 );
     conv_garage (  5210,          1313 );
     conv_garage (  5230,          5202 );
     conv_garage (  5231,          5235 );
     conv_garage ( 10000,          1168 );
     conv_garage ( 10237,         10238 );
     conv_garage ( 10344,         10345 );
     conv_garage ( 13000,         12000 );
     conv_garage ( 20002,         20148 );
     conv_garage ( 20003,         20374 );
     conv_garage ( 20007,         20312 );
     conv_garage ( 20008,         20237 );
     conv_garage ( 20011,         20103 );
     conv_garage ( 20032,         20093 );
     conv_garage ( 20048,         20290 );
     conv_garage ( 20049,         20171 );
     conv_garage ( 20052,         20103 );
     conv_garage ( 20079,         20339 );
     conv_garage ( 20082,         20357 );
     conv_garage ( 20084,         20324 );
     conv_garage ( 20096,         20382 );
     conv_garage ( 20101,         20334 );
     conv_garage ( 20180,         20287 );
     conv_garage ( 20214,         20373 );
     conv_garage ( 20239,         20250 );
     conv_garage ( 20267,         20374 );
     conv_garage ( 20273,         20382 );
     conv_garage ( 20289,         20330 );
     conv_garage ( 20298,         20309 );
     conv_garage ( 20306,         20374 );
     conv_garage ( 20315,         20330 );
     conv_garage ( 20319,         20281 );
     conv_garage ( 30002,         30077 );
     conv_garage ( 30005,         30070 );
     conv_garage ( 30018,         30061 );
     conv_garage ( 30021,         30052 );
     conv_garage ( 30029,         30072 );
     conv_garage ( 30031,         30045 );
     conv_garage ( 30054,         30062 );
     conv_garage ( 30056,         30088 );
     conv_garage ( 30059,         30046 );
     conv_garage ( 30063,         30088 );
     conv_garage ( 40035,         40007 );
     conv_garage ( 40053,         40007 );
     conv_garage ( 40054,         40012 );
     conv_garage ( 50020,         50034 );
     conv_garage ( 50024,         50057 );
     conv_garage ( 50030,         50063 );
     conv_garage ( 50032,         50043 );
     conv_garage ( 90001,         90047 );
     conv_garage ( 90007,         90042 );
     conv_garage ( 90008,         90044 );
     conv_garage ( 90025,         90028 );
     conv_garage ( 90032,         90038 );
end;
/

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   :L_ERROR_OCCURED  = 0 and upper ( '&&commit_or_rollback' ) = 'Y'
   then commit;
        snt.SRS_LOG_MAINTENANCE_SCRIPTS ( :L_SCRIPTNAME );
        :nachricht := 'Data saved into the DB';
   else rollback;
        :nachricht := 'DB Data not changed';
   end  if;
end;
/

-- < enable again all perhaps in step 0 disabled constraints or triggers >
alter trigger snt.FK_CHECK_TGARAGE enable;

-- report final / finished message and exit
set termout  on

prompt
prompt finished.
prompt

begin
   dbms_output.put_line ( :nachricht );
end;
/

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2600-RelinkDocumentsOfGarages.log
prompt

exit;
