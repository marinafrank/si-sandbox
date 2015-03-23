-- DataCleansing_LOP2855-Belgacom.sql
-- MZimmerberger	27.02.2014 MKS-130986:1 / LOP-2855
-- FraBe          27.02-2014 MKS-130986:2: changed L_ERROR_OCCURED logic: setzen var am anfang auf -1, und erst am ende, wenn alles ok auf 0
--                                         dadurch wird vermieden, daß beim Auftreten eines ORA- ein commit am ende gemacht wird

spool DataCleansing_LOP2855-Belgacom.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size unlimited
set lines        999
set pages        0

variable L_ERROR_OCCURED number;
exec :L_ERROR_OCCURED    := -1;
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 100 char );
exec :L_SCRIPTNAME       := 'DataCleansing_LOP2855-Belgacom.sql';

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
   L_REEXEC_FORBIDDEN      boolean                         := false;           -- false or true
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
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >
/*
Skript Spezifikation:
Belgacom has 2 customer contracts: 048519 (25 vehicle contracts) and 044177 (590 vehicle contracts).

Please create a script to perform these 2 actions:
- replace customer 00000013001 by customer 00002670001 in all
- add attribute package INSTALL_SUP to all
*/
declare

   l_id_customer              snt.tcustomer.id_customer%type;
   l_guid_package_install_sup snt.tic_package.guid_package%type;

   procedure UPD_CUSTOMER (i_id_customer_new snt.tcustomer.id_customer%type,
                           i_id_vertrag      snt.tfzgv_contracts.id_vertrag%type) is
   begin

      update snt.tfzgv_contracts
         set id_customer = i_id_customer_new
       where id_vertrag  = i_id_vertrag;

      -- log number of contracts
      dbms_output.put_line('Updated ' || sql%rowcount || ' entries in snt.tfzgv_contracts for contract ' || i_id_vertrag);
         
   end UPD_CUSTOMER;

   procedure ADD_PACKAGE (i_guid_package  snt.tic_package.guid_package%type,
                          i_guid_contract snt.tfzgvertrag.guid_contract%type) is

   l_guid_package    snt.tic_package.guid_package%type;
   l_id_vertrag      snt.tfzgvertrag.id_vertrag%type;
   l_id_fzgvertrag   snt.tfzgvertrag.id_fzgvertrag%type;

   begin

      begin
         -- 1st: determine "last" package
         select GUID_PACKAGE
           into l_guid_package
           from (select level L1
                      , GUID_PACKAGE
                   from (select GUID_PACKAGE
                              , GUID_PACKAGE_PARENT
                          from snt.tic_co_pack_ass
                         where GUID_CONTRACT = i_guid_contract)
                 start with GUID_PACKAGE_PARENT IS NULL
                 connect by prior GUID_PACKAGE=GUID_PACKAGE_PARENT
                 order by level desc)
         where rownum = 1;

         -- 2nd: insert the new row
         begin
            insert into snt.tic_co_pack_ass (guid_contract, guid_package, guid_package_parent)
            values (i_guid_contract, i_guid_package, l_guid_package);
         exception
            when others then
               dbms_output.put_line('guid_contract ' || i_guid_contract);
         end;
      
      exception
         when no_data_found then
            --dbms_output.put_line('No packages?');
            null;
      end;
      
      -- 3rd: log result
      select id_vertrag, id_fzgvertrag
        into l_id_vertrag, l_id_fzgvertrag
        from snt.tfzgvertrag
       where guid_contract = i_guid_contract;
      dbms_output.put_line('Added package INSTALL_SUP to ' || l_id_vertrag || '/' || l_id_fzgvertrag);

   end ADD_PACKAGE;

-- MAIN ----------------------------------------------------------------------------------------------------------------------------------------------------
begin

   -- 1st: Check if target id_customer exists
   begin
      select id_customer
        into l_id_customer
        from snt.tcustomer
       where id_customer = '00002670001';

   exception
      when no_data_found then
      raise_application_error (-20000, 'Customer 00002670001 doesn''t exist. Script terminates!');
   end;

   -- 2nd: check existence of package
   begin
      select guid_package
        into l_guid_package_install_sup
        from snt.tic_package
       where upper(icp_caption) = 'INSTALL_SUP';

   exception
      when no_data_found then
      raise_application_error (-20000, 'Package INSTALL_SUP doesn''t exist. Script terminates!');
   end;

   -- 3rd: update contracts with new id_customer
   dbms_output.put_line ('1st step: UPDATE contracts, set new_id_customer');
   
   UPD_CUSTOMER(I_ID_CUSTOMER_NEW=>'00002670001', I_ID_VERTRAG=>'048519');
   UPD_CUSTOMER(I_ID_CUSTOMER_NEW=>'00002670001', I_ID_VERTRAG=>'044177');

   -- 4th: add package
   dbms_output.new_line;
   dbms_output.put_line ('2nd step: ADD package INSTALL_SUP');
   for o_add_package in (select distinct guid_contract
                           from snt.tic_co_pack_ass
                          where guid_contract in (select guid_contract 
                                                    from snt.tfzgvertrag
                                                   where id_vertrag in ('048519', '044177')))
   loop
      ADD_PACKAGE(i_guid_package=>l_guid_package_install_sup, i_guid_contract=>o_add_package.guid_contract);
      --dbms_output.put_line(l_guid_package_install_sup || o_add_package.guid_contract);
   end loop;

   if   :L_ERROR_OCCURED  = -1  --> variable bekommt am anfang diesen wert
   then :L_ERROR_OCCURED :=  0; --> dadurch daß script bis hierher success: ganzes script ist success
   end  if;
   
end;
/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2855-Belgacom.log
prompt

exit;
