-- DataCleansing_LOP2259-MapCampaigns_II.sql

-- CPauzen 05.02.2014 MKS-130861:1 / LOP2259: creation	
-- based on: DataCleansing_LOP2259-MapCampaigns.sql MKS-128301:1

spool DataCleansing_LOP2259-MapCampaigns_II.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size unlimited FORMAT TRUNCATED
set lines        999
set pages        0

variable L_ERROR_OCCURED number;
exec :L_ERROR_OCCURED    := 0;
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 100 char );
exec :L_SCRIPTNAME       := 'DataCleansing_LOP2259-MapCampaigns_II.sql';

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
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

declare

     L_GUID_CUSTOMER_0        snt.TCUSTOMER.GUID_CUSTOMER%type;
     
     procedure change_CI_CUST
             ( I_CAMP_CAPTION       varchar2
             , I_CAMP_DEPARTEMENT   varchar2
             , I_ID_CUSTOMER_NEW    varchar2 ) is
               L_GUID_PARTNER       snt.TCUSTOMER_INVOICE.GUID_PARTNER%type;

     begin
          :L_ERROR_OCCURED := 0;
          ---
          select   GUID_PARTNER
            into L_GUID_PARTNER
            from snt.TPARTNER
           where ID_CUSTOMER = I_ID_CUSTOMER_NEW;
          ---
          update snt.TCUSTOMER_INVOICE
             set GUID_PARTNER  = L_GUID_PARTNER
           where (   GUID_PARTNER,          ID_SEQ_FZGVC,         GUID_CI ) in
          ( select L_GUID_CUSTOMER_0, fzgvc.ID_SEQ_FZGVC, concamp.GUID_CI
              from snt.TCONTRACT_CAMPAIGN concamp
                 , snt.TCAMPAIGN          camp
                 , snt.TFZGV_CONTRACTS    fzgvc
                 , snt.TFZGVERTRAG        fzgv
             where camp.CAMP_CAPTION     = I_CAMP_CAPTION
               and camp.CAMP_DEPARTEMENT = I_CAMP_DEPARTEMENT
               and camp.GUID_CAMPAIGN    = concamp.GUID_CAMPAIGN
               and fzgv.GUID_CONTRACT    = concamp.GUID_CONTRACT
               and fzgv.ID_VERTRAG       = fzgvc.ID_VERTRAG
               and fzgv.ID_FZGVERTRAG    = fzgvc.ID_FZGVERTRAG );
          ---
          dbms_output.put_line ( to_char ( sql%rowcount, '9990' ) || ' CustomerInvoices of Campaign ' 
                             || rpad ( I_CAMP_CAPTION, 5, ' ' ) || ' / ' || rpad ( I_CAMP_DEPARTEMENT, 34, ' ' )
                             || ' changed from Customer = 0 to ' || I_ID_CUSTOMER_NEW );
     
     exception when NO_DATA_FOUND 
               then dbms_output.put_line ( 'The CustomerInvoices of Campaign ' 
                             || rpad ( I_CAMP_CAPTION, 5, ' ' ) || ' / ' || rpad ( I_CAMP_DEPARTEMENT, 34, ' ' ) 
                             || ' cannot be converted to ' || I_ID_CUSTOMER_NEW || ' as this Customer does not exist!' );
               :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
     end;
     
begin
     select   GUID_CUSTOMER 
       into L_GUID_CUSTOMER_0
       from snt.TCUSTOMER
      where ID_CUSTOMER = '0'; 
     ---
     change_CI_CUST ( '3XAA',  'After Sales',                        '99900500000' );
     change_CI_CUST ( '3XAS',  'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( '3XBA',  'After Sales',                        '99900500000' );
     change_CI_CUST ( '3XBS',  'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( '3YAA',  'After Sales',                        '99900500000' );
     change_CI_CUST ( '3YAS',  'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( '3YBA',  'After Sales',                        '99900500000' );
     change_CI_CUST ( '3YBS',  'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( '3YMA',  'After Sales',                        '99900500000' );
     change_CI_CUST ( '3YMS',  'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( 'A1000', 'After Sales Provisie',               '99900600000' );
     change_CI_CUST ( 'AJE',   'After Sales',                        '99900600000' );
     change_CI_CUST ( 'AMB',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'AMBrt', 'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B4400', 'Salon Actie A-klasse 2000',          '99900100000' );
     change_CI_CUST ( 'B4401', 'Salon Actie C-klasse 2000',          '99900100000' );
     change_CI_CUST ( 'B50',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B51',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B52',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B60',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B61',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B62',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B62AS', 'After Sales',                        '99900400000' );
     change_CI_CUST ( 'B62S',  'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'B63AS', 'After Sales',                        '99900400000' );
     change_CI_CUST ( 'B63S',  'Sales MBC',                          '99900100000' );
     change_CI_CUST ( 'B8200', 'ACTION STOCK 2002',                  '99900100000' );
     change_CI_CUST ( 'D60',   'Action Classe E - 2005',             '99900100000' );
     change_CI_CUST ( 'D83',   'Action Classe E - 2006',             '99900100000' );
     change_CI_CUST ( 'Europ', 'Succursale Europa',                  '99900700000' );
     change_CI_CUST ( 'EXT',   'Sales PKW of NFZ',                   '99900100000' );
     change_CI_CUST ( 'FSC',   'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'GDW',   'After Sales Service',                '99900400000' );
     change_CI_CUST ( 'S0200', 'ACTROS RENTING CAR',                 '99900300000' );
     change_CI_CUST ( 'S0300', 'ACTROS SALON 1997',                  '99900300000' );
     change_CI_CUST ( 'S0400', 'SPRINTER SALON 1999',                '99900200000' );
     change_CI_CUST ( 'S0500', 'SERVICE VENTE PKW - NNCC',           '99901000000' );
     change_CI_CUST ( 'S1000', 'Commerciële ondersteuning Iglo-Ola', '99900300000' );
     change_CI_CUST ( 'S1100', 'INTERVENTION VENTE NFZ / DIV',       '99900300000' );
     change_CI_CUST ( 'S1200', 'ACTION VITO / SPRINTER 2002',        '99900200000' );
     change_CI_CUST ( 'S13',   'LKW New Pricing - Sales NFZ',        '99900300000' );
     change_CI_CUST ( 'S13B',  'Sales NFZ',                          '99900300000' );
     change_CI_CUST ( 'S14',   'Sales TR',                           '99900200000' );
     change_CI_CUST ( 'S15',   'Sales TR',                           '99900200000' );
     change_CI_CUST ( 'S20',   'Federale Politie',                   '99900100000' );
     change_CI_CUST ( 'S2000', 'SERVICE VENTE PKW / DIV',            '99900100000' );
     change_CI_CUST ( 'SPL',   'SintPietersLeeuw',                   '99900800000' );
     change_CI_CUST ( 'X3AA7', 'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( 'X9ABA', 'After Sales',                        '99900500000' );
     change_CI_CUST ( 'X9ABS', 'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( 'X9ADS', 'Sales NFZ',                          '99900200000' );
     change_CI_CUST ( 'XB2AS', 'After Sales',                        '99900600000' );
     change_CI_CUST ( 'XB2S',  'Sales LKW',                          '99900300000' );
     change_CI_CUST ( 'XD2S',  'Sales LKW',                          '99900300000' );
     change_CI_CUST ( 'AD1S',  'Sales PKW',                          '99900100000' );
     change_CI_CUST ( 'AD1AS', 'After Sales PKW',                    '99900400000' );

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2259-MapCampaigns_II.log
prompt

exit;
