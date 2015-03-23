-- DataCleansing_LOP2146-CleanCustomerDuplicates2.sql
-- CPauzen     19.03.2014 MKS-131644:1 und :2 / LOP 2146
-- FraBe       23.03.2014 MKS-131644:3 / LOP 2146: lt. entscheidung von Tobi werden alle ID_CUSTOMER umgestellt.
--                                                 dh: auch TVERTRAGSTAMM.ID_CUSTOMER und CUST_INV_ADRESS_BALFIN bzw. ID_CUSTOMER der table TCUSTOMER
--                                                 und falls die neue TCUSTOMER.ID_CUSTOMER schon angelegt ist, wird die alte gelöscht. 
--                                                 weiters: die daten werden in der hierarchischen FK reihenfolge geändert.
-- FraBe       15.04.2014 MKS-131644:4 / LOP 2146 v1.4: neue custdom logik
 
spool DataCleansing_LOP2146-CleanCustomerDuplicates2.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size unlimited format wrapped
set lines        999
set pages        0

variable L_ERROR_OCCURED number;
exec :L_ERROR_OCCURED    := 0;
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 100 char );
exec :L_SCRIPTNAME       := 'DataCleansing_LOP2146-CleanCustomerDuplicates2.sql';

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
set serveroutput on  size unlimited format wrapped
set heading      on
set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     off
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV disable; >
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

-- 1st: 

declare

   procedure upd_cu(i_id_customer_old  snt.tcustomer.id_customer%type,
                    i_id_customer_new  snt.tcustomer.id_customer%type) is
                    
      L_COUNT_CUSTDOM_UPD    integer := 0;
      L_COUNT_CUSTDOM_DEL    integer := 0;
      L_COUNT_CUSTDOM_CO_UPD integer := 0;
      L_COUNT_CUSTDOM_CI_UPD integer := 0;

   begin

       DBMS_OUTPUT.PUT_LINE ( chr(10) || '------------------------------------------------------------------------------------------------------------------------------');
       DBMS_OUTPUT.PUT_LINE('cconvert          old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ': ' );
       DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------');

      -------------------------------------
      -- snt.TTEMP_I55_OR_SCARF_DATA
      -------------------------------------
      -- wenn row mit neuem cust existiert schon -> alter cust wird gelöscht
      -- sonst: upd
      begin
          delete from snt.TTEMP_I55_OR_SCARF_DATA t
           where ID_CUSTOMER         = i_id_customer_old
             and RECORD_TYPE         = '20'
             and exists ( select null 
                            from snt.TTEMP_I55_OR_SCARF_DATA t1
                           where       t1.ID_CUSTOMER          =       i_id_customer_new
                             and       t1.GUID_JO              =       t.GUID_JO
                             and       t1.RECORD_TYPE          =       t.RECORD_TYPE );
--                           and nvl ( t1.SEQ_NUMBER,    -1 )  = nvl ( t.SEQ_NUMBER,    -1 )
--                           and nvl ( t1.GUID_CONTRACT, ' ' ) = nvl ( t.GUID_CONTRACT, ' ' )); 
                             
      if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || '                                            - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) deleted');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;

      -------------------------------------
      
      begin
          UPDATE snt.TTEMP_I55_OR_SCARF_DATA
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('temp SCARF/I55  : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      --tcustomer_invoice
      -------------------------------------
      begin
          UPDATE snt.tcustomer_invoice
             SET guid_partner =
                    (SELECT guid_partner
                       FROM snt.tpartner
                      WHERE id_customer = i_id_customer_new)
           WHERE guid_partner = (SELECT guid_partner
                                   FROM snt.tpartner
                                  WHERE id_customer = i_id_customer_old);
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_invoice: old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer_invoice: old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.tfzgv_contracts
      -------------------------------------
      begin
          UPDATE snt.tfzgv_contracts
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('fzgv_contracts  : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('fzgv_contracts  : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.TVERTRAGSTAMM
      -------------------------------------
      begin
          UPDATE snt.TVERTRAGSTAMM
             SET ID_CUSTOMER         = i_id_customer_new
           WHERE ID_CUSTOMER         = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;

      -------------------------------------

      begin
          UPDATE snt.TVERTRAGSTAMM
             SET ID_CUSTOMER2        = i_id_customer_new
           WHERE ID_CUSTOMER2        = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER2: ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('vertragstamm    : old           ID_CUSTOMER2: ' || i_id_customer_old || ' to new           ID_CUSTOMER2: ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- snt.TCUSTOMER_DOM
      -------------------------------------
      -- wenn der upd wegen DUP_VAL_ON_INDEX fehlschlägt, existiert die neue domiciliation schon
      -- -> dann werden stattdessen alle CO mit der alten domiciliation auf die neue umgestellt, und dann die alte gelöscht:
      L_COUNT_CUSTDOM_UPD    := 0;
      L_COUNT_CUSTDOM_CO_UPD := 0;
      L_COUNT_CUSTDOM_CI_UPD := 0;
      L_COUNT_CUSTDOM_DEL    := 0;
      
      for crec in ( select GUID_CUSTOMER_DOM, CUSTDOM_DOMNUMBER
                      from snt.TCUSTOMER_DOM
                     where ID_CUSTOMER  = i_id_customer_old )
      loop
           begin
              UPDATE snt.TCUSTOMER_DOM
                 SET ID_CUSTOMER         = i_id_customer_new
               WHERE GUID_CUSTOMER_DOM   = crec.GUID_CUSTOMER_DOM;
              
              L_COUNT_CUSTDOM_UPD := L_COUNT_CUSTDOM_UPD +  sql%rowcount;
              
           exception when DUP_VAL_ON_INDEX -- wenns die neue ID_CUSTOMER schon gibt: a) CO und CI umstellen auf neue custdom b) lö alte
                     then begin 
                              update snt.TFZGV_CONTRACTS co
                                 set co.GUID_CUSTOMER_DOM  = ( select numNEU.GUID_CUSTOMER_DOM 
                                                                 from snt.TCUSTOMER_DOM numNEU
                                                                where numNEU.ID_CUSTOMER       = i_id_customer_new
                                                                  and numNEU.CUSTDOM_DOMNUMBER = crec.CUSTDOM_DOMNUMBER )
                               where co.GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;
     
                              L_COUNT_CUSTDOM_CO_UPD := L_COUNT_CUSTDOM_CO_UPD +  sql%rowcount;
                                
                          exception when OTHERS 
                                    then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                                         dbms_output.put_line ( sqlerrm );
                          end;
                          
                          begin 
                              update snt.TCUSTOMER_INVOICE ci
                                 set ci.GUID_CUSTOMER_DOM  = ( select numNEU.GUID_CUSTOMER_DOM 
                                                                 from snt.TCUSTOMER_DOM numNEU
                                                                where numNEU.ID_CUSTOMER       = i_id_customer_new
                                                                  and numNEU.CUSTDOM_DOMNUMBER = crec.CUSTDOM_DOMNUMBER )
                               where ci.GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;
     
                              L_COUNT_CUSTDOM_CI_UPD := L_COUNT_CUSTDOM_CI_UPD +  sql%rowcount;
                              
                          exception when OTHERS 
                                    then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                                         dbms_output.put_line ( sqlerrm );
                          end;
                          
                          begin
                                delete from snt.TCUSTOMER_DOM 
                                 where GUID_CUSTOMER_DOM  = crec.GUID_CUSTOMER_DOM;

                                L_COUNT_CUSTDOM_DEL := L_COUNT_CUSTDOM_DEL + 1;
                                
                          exception when OTHERS 
                                    then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                                         dbms_output.put_line ( sqlerrm );
                          end;
                     when OTHERS 
                     then dbms_output.put_line ( sqlerrm );
           end;
      end loop;  
      
      if   L_COUNT_CUSTDOM_CO_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom/CO : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom/CO : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_CO_UPD, '9990' ) || ' record(s) updated');
      end  if;
          
      if   L_COUNT_CUSTDOM_CI_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom/CI : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom/CI : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_CI_UPD, '9990' ) || ' record(s) updated');
      end  if;

      if   L_COUNT_CUSTDOM_UPD = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
      else DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || ' to new           ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( L_COUNT_CUSTDOM_UPD, '9990' ) || ' record(s) updated');
      end  if;

      if   L_COUNT_CUSTDOM_DEL = 0 then null;
      else DBMS_OUTPUT.PUT_LINE('customer_dom    : old           ID_CUSTOMER : ' || i_id_customer_old || '                                            - ' || to_char (L_COUNT_CUSTDOM_DEL, '9990' ) || ' record(s) deleted');
      end  if;
      
      -------------------------------------
      --tcustomer: alternate inv address
      -------------------------------------
      begin
          UPDATE snt.TCUSTOMER
             SET CUST_INVOICE_ADRESS = i_id_customer_new
           WHERE CUST_INVOICE_ADRESS = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old alternate ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer        : old alternate ID_CUSTOMER : ' || i_id_customer_old || ' to new alternate ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      --tcustomer: alternate balfin address
      -------------------------------------
      begin
          UPDATE snt.tcustomer
             SET CUST_INV_ADRESS_BALFIN = i_id_customer_new
           WHERE CUST_INV_ADRESS_BALFIN = i_id_customer_old;
     
          
          if sql%rowcount = 0 then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old balfin    ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else
           DBMS_OUTPUT.PUT_LINE('customer        : old balfin    ID_CUSTOMER : ' || i_id_customer_old || ' to new balfin    ID_CUSTOMER : ' || i_id_customer_new || ' - ' || to_char ( sql%rowcount, '9990' ) || ' record(s) updated');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
     
      -------------------------------------
      -- tcustomer: del old customer
      -- hier wird kein upd gemacht, sondern nur der alte cust gelöscht
      ------------------------------------
      begin
          delete from snt.TCUSTOMER 
           where ID_CUSTOMER = i_id_customer_old;

          if   sql%rowcount = 0 
          then null; -- DBMS_OUTPUT.PUT_LINE('customer        : old           ID_CUSTOMER : ' || i_id_customer_old || ' not found');
          else DBMS_OUTPUT.PUT_LINE('customer        : old           ID_CUSTOMER : ' || i_id_customer_old || '                                                  1 record(s) deleted');
          end if;
      exception when OTHERS
                then :L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
                     dbms_output.put_line ( sqlerrm );
      end;
      
   end;

begin


upd_cu(I_ID_CUSTOMER_OLD=>'0011661 001', I_ID_CUSTOMER_NEW=>'00011661001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011738001', I_ID_CUSTOMER_NEW=>'00016606001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001761023', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00006169001', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00011346001', I_ID_CUSTOMER_NEW=>'99900800000');
upd_cu(I_ID_CUSTOMER_OLD=>'00015577001', I_ID_CUSTOMER_NEW=>'99900800000');
upd_cu(I_ID_CUSTOMER_OLD=>'00031998001', I_ID_CUSTOMER_NEW=>'00003285001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035461001', I_ID_CUSTOMER_NEW=>'00005142001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032540001', I_ID_CUSTOMER_NEW=>'00006245001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031223001', I_ID_CUSTOMER_NEW=>'00006773001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029920001', I_ID_CUSTOMER_NEW=>'00008237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033953001', I_ID_CUSTOMER_NEW=>'00008845001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008983001', I_ID_CUSTOMER_NEW=>'00008984001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031016001', I_ID_CUSTOMER_NEW=>'00009307001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009089001', I_ID_CUSTOMER_NEW=>'00010735001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029572001', I_ID_CUSTOMER_NEW=>'00011885001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031363001', I_ID_CUSTOMER_NEW=>'00013375001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010508001', I_ID_CUSTOMER_NEW=>'00013921001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000014470', I_ID_CUSTOMER_NEW=>'00014478001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014589001', I_ID_CUSTOMER_NEW=>'00014664001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010051001', I_ID_CUSTOMER_NEW=>'00016922001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033389001', I_ID_CUSTOMER_NEW=>'00017700001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032533001', I_ID_CUSTOMER_NEW=>'00018468001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033010001', I_ID_CUSTOMER_NEW=>'00020140001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031618001', I_ID_CUSTOMER_NEW=>'00020940001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033461001', I_ID_CUSTOMER_NEW=>'00021373001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037641001', I_ID_CUSTOMER_NEW=>'00021567001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030969001', I_ID_CUSTOMER_NEW=>'00021626001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012431001', I_ID_CUSTOMER_NEW=>'00022283001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029483001', I_ID_CUSTOMER_NEW=>'00023621001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035892001', I_ID_CUSTOMER_NEW=>'00024384001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002999', I_ID_CUSTOMER_NEW=>'00025818001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033390001', I_ID_CUSTOMER_NEW=>'00026186001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037894001', I_ID_CUSTOMER_NEW=>'00027371001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013152001', I_ID_CUSTOMER_NEW=>'00027403001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031686001', I_ID_CUSTOMER_NEW=>'00027668001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033170001', I_ID_CUSTOMER_NEW=>'00027668001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037449001', I_ID_CUSTOMER_NEW=>'00027703001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009415001', I_ID_CUSTOMER_NEW=>'00027989001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011823001', I_ID_CUSTOMER_NEW=>'00028184001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032571001', I_ID_CUSTOMER_NEW=>'00028533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029130001', I_ID_CUSTOMER_NEW=>'00029179001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029595001', I_ID_CUSTOMER_NEW=>'00029596001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010553001', I_ID_CUSTOMER_NEW=>'00029924001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030012001', I_ID_CUSTOMER_NEW=>'00030514001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030031001', I_ID_CUSTOMER_NEW=>'00030962001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033505001', I_ID_CUSTOMER_NEW=>'00031862001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010107001', I_ID_CUSTOMER_NEW=>'00031900001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033373001', I_ID_CUSTOMER_NEW=>'00033117001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033017001', I_ID_CUSTOMER_NEW=>'00033920001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029156001', I_ID_CUSTOMER_NEW=>'00034668001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032686001', I_ID_CUSTOMER_NEW=>'00034668001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006873001', I_ID_CUSTOMER_NEW=>'00036970001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036966001', I_ID_CUSTOMER_NEW=>'00037053001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000400000', I_ID_CUSTOMER_NEW=>'99900400000');
upd_cu(I_ID_CUSTOMER_OLD=>'00015516001', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00000900000', I_ID_CUSTOMER_NEW=>'99900900000');
upd_cu(I_ID_CUSTOMER_OLD=>'00000100000', I_ID_CUSTOMER_NEW=>'99901100000');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004459', I_ID_CUSTOMER_NEW=>'Q0000000878');
upd_cu(I_ID_CUSTOMER_OLD=>'00035904001', I_ID_CUSTOMER_NEW=>'Q0000000946');
upd_cu(I_ID_CUSTOMER_OLD=>'00037814001', I_ID_CUSTOMER_NEW=>'Q0000001061');
upd_cu(I_ID_CUSTOMER_OLD=>'00037254001', I_ID_CUSTOMER_NEW=>'Q0000001379');
upd_cu(I_ID_CUSTOMER_OLD=>'00031574001', I_ID_CUSTOMER_NEW=>'Q0000001451');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002170', I_ID_CUSTOMER_NEW=>'Q0000002027');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002167', I_ID_CUSTOMER_NEW=>'Q0000002028');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002295', I_ID_CUSTOMER_NEW=>'Q0000002140');
upd_cu(I_ID_CUSTOMER_OLD=>'00013279001', I_ID_CUSTOMER_NEW=>'Q0000003062');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000003074', I_ID_CUSTOMER_NEW=>'Q0000003071');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004181', I_ID_CUSTOMER_NEW=>'Q0000004182');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004227', I_ID_CUSTOMER_NEW=>'Q0000004191');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000003082', I_ID_CUSTOMER_NEW=>'Q0000004233');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004360', I_ID_CUSTOMER_NEW=>'Q0000004490');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004653', I_ID_CUSTOMER_NEW=>'Q0000004659');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004733', I_ID_CUSTOMER_NEW=>'Q0000004727');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004783', I_ID_CUSTOMER_NEW=>'Q0000004832');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004677', I_ID_CUSTOMER_NEW=>'Q0000004900');
upd_cu(I_ID_CUSTOMER_OLD=>'00000013002', I_ID_CUSTOMER_NEW=>'00000013001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013520001', I_ID_CUSTOMER_NEW=>'00000013001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000987002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00000989002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001001002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001003002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001007002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001008002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001010002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001012002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001015002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001025002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001027002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001050002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001116002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001117002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001156002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001244002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001255002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001287001', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001287002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001565002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001635002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001636002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001688002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001708002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001715002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001731002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001850002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001938002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00001950002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002007002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002027002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002037002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002039002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002122002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002158002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002218002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002220002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002267002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002315002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002433002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002550002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002613002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002738002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002739002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002760002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002825002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002831002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002841002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002842002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002885002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002899002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00002973002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003021002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003043002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003058002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003060002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003062002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003200002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003202002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003203002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003204002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003389002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003472002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003692002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003693002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003722002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003747002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003748002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003797002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003923002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003925002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003927002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004122002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004260002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004263002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004264002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004266002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004453002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004532002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004585002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004628002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004658002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004659002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004660002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004800002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004822002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004956002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004957002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004958002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00004959002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005003002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005090002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005240002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005241002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005243002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005277002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005278002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005481002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005528002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005614002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005615002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005644002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005710002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005711002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00005887002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006163002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006164002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006165002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006166002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006167002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006168002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006169002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006252002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006253002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006254002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006353002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006412002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006413002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006505002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006518002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006675002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006676002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006677002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006867002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006868002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006869002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006870002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006974002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007036002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007037002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007038002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007039002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007040002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007460002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007516002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007517002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007518002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007519002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007520002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007521002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007522002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007523002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007524002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007525002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007526002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007527002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007528002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007529002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007701002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007702002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007703002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007736002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007737002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007773002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007967002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007968002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007969002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007970002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008021002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008040002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008069002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008070002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008150002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008151002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008221002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008222002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008223002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008224002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008226002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008411002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008412002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008581002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008597002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008598002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008599002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008600002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008639002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008660002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008719002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008826002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008827002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008872002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008873002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008990002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008991002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008992002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008993002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008994002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009099002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009101002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009102002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009209002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009575002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009724002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00009737002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010198002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010201002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010371002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010742002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010903002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00010999002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011346002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011347002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011348002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011349002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011419002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011527002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011674002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011675002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011676002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011677002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011678002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00011684002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012135002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012136002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012137002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012138002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012139002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012140002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012141002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012142002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012209002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012210002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012211002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012212002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012337002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012338002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012339002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012578002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012579002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012580002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012581002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012582002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012583002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012584002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012787002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012788002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012789002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012983002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012984002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013033002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013034002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013168002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013401002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013402002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013438002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013439002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00013927002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014035002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014036002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014037002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014076002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014077002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014078002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014079002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014281002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014282002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014283002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014284002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014286002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014297002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014460002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014461002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014462002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00014800001', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00016071001', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00020269002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'0014285 002', I_ID_CUSTOMER_NEW=>'01246161002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007970001', I_ID_CUSTOMER_NEW=>'00036614001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005033002', I_ID_CUSTOMER_NEW=>'00015557001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007845002', I_ID_CUSTOMER_NEW=>'00015557001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009599002', I_ID_CUSTOMER_NEW=>'00015557001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011820002', I_ID_CUSTOMER_NEW=>'00015557001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012400002', I_ID_CUSTOMER_NEW=>'00015557001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012284002', I_ID_CUSTOMER_NEW=>'00015591001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012699002', I_ID_CUSTOMER_NEW=>'00015591001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013493002', I_ID_CUSTOMER_NEW=>'00015591001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012466002', I_ID_CUSTOMER_NEW=>'00015500001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014469002', I_ID_CUSTOMER_NEW=>'00015500001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015501001', I_ID_CUSTOMER_NEW=>'00015500001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012287002', I_ID_CUSTOMER_NEW=>'00015592001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007328002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009426002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009427002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009428002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009429002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009430002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009431002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009432002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009695002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009696002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009697002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012167002', I_ID_CUSTOMER_NEW=>'00015529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001068002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004064002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004975002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005120002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005246002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007299002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008939002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009191002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009532002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013121002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013122002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010614002', I_ID_CUSTOMER_NEW=>'00015591001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002288001', I_ID_CUSTOMER_NEW=>'00015564001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011056001', I_ID_CUSTOMER_NEW=>'00015538001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001761017', I_ID_CUSTOMER_NEW=>'00015527001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008394002', I_ID_CUSTOMER_NEW=>'00015512001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002308002', I_ID_CUSTOMER_NEW=>'00015503001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004984002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005524002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005918002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005919002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006181002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006487002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008289002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009264002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009637002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009638002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009639002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009640002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009641002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010978002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011387002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012883002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013200002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014131002', I_ID_CUSTOMER_NEW=>'00015576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001761004', I_ID_CUSTOMER_NEW=>'00015514001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005369001', I_ID_CUSTOMER_NEW=>'00015514001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006408002', I_ID_CUSTOMER_NEW=>'00015518001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013080002', I_ID_CUSTOMER_NEW=>'00015518001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013311002', I_ID_CUSTOMER_NEW=>'00015518001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012765002', I_ID_CUSTOMER_NEW=>'00015586001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014333001', I_ID_CUSTOMER_NEW=>'00015507001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001761014', I_ID_CUSTOMER_NEW=>'00015553001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002122001', I_ID_CUSTOMER_NEW=>'00015553001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013758001', I_ID_CUSTOMER_NEW=>'00015553001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009676002', I_ID_CUSTOMER_NEW=>'00015511001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006341001', I_ID_CUSTOMER_NEW=>'00015544001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011999002', I_ID_CUSTOMER_NEW=>'00012520002');
upd_cu(I_ID_CUSTOMER_OLD=>'00012475002', I_ID_CUSTOMER_NEW=>'00012520002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003567002', I_ID_CUSTOMER_NEW=>'00015537001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009827002', I_ID_CUSTOMER_NEW=>'00015537001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015589001', I_ID_CUSTOMER_NEW=>'00015590001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035677001', I_ID_CUSTOMER_NEW=>'00015543001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015535001', I_ID_CUSTOMER_NEW=>'00018404001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015572001', I_ID_CUSTOMER_NEW=>'00015584001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009202002', I_ID_CUSTOMER_NEW=>'00015570001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013406002', I_ID_CUSTOMER_NEW=>'00015581001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013407002', I_ID_CUSTOMER_NEW=>'00015581001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010828002', I_ID_CUSTOMER_NEW=>'00015583001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008979002', I_ID_CUSTOMER_NEW=>'00015520001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012204002', I_ID_CUSTOMER_NEW=>'00015520001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013513002', I_ID_CUSTOMER_NEW=>'00015520001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012410002', I_ID_CUSTOMER_NEW=>'00015578001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035233001', I_ID_CUSTOMER_NEW=>'00015602001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003595001', I_ID_CUSTOMER_NEW=>'00015563001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003801002', I_ID_CUSTOMER_NEW=>'00015563001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026035001', I_ID_CUSTOMER_NEW=>'00015563001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004048001', I_ID_CUSTOMER_NEW=>'00017980001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008881001', I_ID_CUSTOMER_NEW=>'00015173001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001995001', I_ID_CUSTOMER_NEW=>'00036304001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024586001', I_ID_CUSTOMER_NEW=>'00002559001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011242001', I_ID_CUSTOMER_NEW=>'00002756001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003045001', I_ID_CUSTOMER_NEW=>'00023179001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011063001', I_ID_CUSTOMER_NEW=>'00003118001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010040001', I_ID_CUSTOMER_NEW=>'00003164001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003809001', I_ID_CUSTOMER_NEW=>'00014976001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013327001', I_ID_CUSTOMER_NEW=>'00014976001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018399001', I_ID_CUSTOMER_NEW=>'00004700001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005210001', I_ID_CUSTOMER_NEW=>'00036308001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005662001', I_ID_CUSTOMER_NEW=>'00014554001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005715001', I_ID_CUSTOMER_NEW=>'00005925001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019737001', I_ID_CUSTOMER_NEW=>'00005913001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005986001', I_ID_CUSTOMER_NEW=>'00019318001');
upd_cu(I_ID_CUSTOMER_OLD=>'0006003 001', I_ID_CUSTOMER_NEW=>'00019612001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005988001', I_ID_CUSTOMER_NEW=>'00012937001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006308001', I_ID_CUSTOMER_NEW=>'00011255001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006410001', I_ID_CUSTOMER_NEW=>'00020884001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006387001', I_ID_CUSTOMER_NEW=>'00007279001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006907001', I_ID_CUSTOMER_NEW=>'00016305001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017423001', I_ID_CUSTOMER_NEW=>'00006909001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006929001', I_ID_CUSTOMER_NEW=>'00016290001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007355001', I_ID_CUSTOMER_NEW=>'00025879001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007477001', I_ID_CUSTOMER_NEW=>'00009072001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007411001', I_ID_CUSTOMER_NEW=>'00023035001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007498001', I_ID_CUSTOMER_NEW=>'00036628001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003715001', I_ID_CUSTOMER_NEW=>'00005901001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018229001', I_ID_CUSTOMER_NEW=>'00008080001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008541001', I_ID_CUSTOMER_NEW=>'00022859001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008823001', I_ID_CUSTOMER_NEW=>'00020627001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008889001', I_ID_CUSTOMER_NEW=>'00029725001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009372001', I_ID_CUSTOMER_NEW=>'00011249001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011361001', I_ID_CUSTOMER_NEW=>'00011249001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009662001', I_ID_CUSTOMER_NEW=>'00017036001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009698001', I_ID_CUSTOMER_NEW=>'00011933001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009752001', I_ID_CUSTOMER_NEW=>'00010453001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010119001', I_ID_CUSTOMER_NEW=>'00009690001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010154001', I_ID_CUSTOMER_NEW=>'00015740001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019169001', I_ID_CUSTOMER_NEW=>'00010296001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010822001', I_ID_CUSTOMER_NEW=>'00034723001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012842001', I_ID_CUSTOMER_NEW=>'00034723001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019006001', I_ID_CUSTOMER_NEW=>'00010837001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021008001', I_ID_CUSTOMER_NEW=>'00010848001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018850001', I_ID_CUSTOMER_NEW=>'00011085001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011117001', I_ID_CUSTOMER_NEW=>'00019566001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013126001', I_ID_CUSTOMER_NEW=>'00011129001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011911001', I_ID_CUSTOMER_NEW=>'00028987001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011961001', I_ID_CUSTOMER_NEW=>'00021370001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008041001', I_ID_CUSTOMER_NEW=>'00011526001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017616001', I_ID_CUSTOMER_NEW=>'00012865001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013902001', I_ID_CUSTOMER_NEW=>'00030076001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014197001', I_ID_CUSTOMER_NEW=>'00023955001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007557001', I_ID_CUSTOMER_NEW=>'00004021001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007980001', I_ID_CUSTOMER_NEW=>'00010731001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002624002', I_ID_CUSTOMER_NEW=>'00007443001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006594001', I_ID_CUSTOMER_NEW=>'00012461001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010143001', I_ID_CUSTOMER_NEW=>'00012461001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000849001', I_ID_CUSTOMER_NEW=>'00011158001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005675001', I_ID_CUSTOMER_NEW=>'00006935001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020152001', I_ID_CUSTOMER_NEW=>'00001533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001133001', I_ID_CUSTOMER_NEW=>'00036030001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001223002', I_ID_CUSTOMER_NEW=>'00001223001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018569001', I_ID_CUSTOMER_NEW=>'00001223001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001345001', I_ID_CUSTOMER_NEW=>'00028864001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004775001', I_ID_CUSTOMER_NEW=>'00028864001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010957001', I_ID_CUSTOMER_NEW=>'00002179001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009194001', I_ID_CUSTOMER_NEW=>'00029228001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011800001', I_ID_CUSTOMER_NEW=>'00001598015');
upd_cu(I_ID_CUSTOMER_OLD=>'00013366002', I_ID_CUSTOMER_NEW=>'00001598015');
upd_cu(I_ID_CUSTOMER_OLD=>'00013367002', I_ID_CUSTOMER_NEW=>'00001598015');
upd_cu(I_ID_CUSTOMER_OLD=>'00007798001', I_ID_CUSTOMER_NEW=>'00002912001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005566001', I_ID_CUSTOMER_NEW=>'00009853001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012235001', I_ID_CUSTOMER_NEW=>'00009853001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007082001', I_ID_CUSTOMER_NEW=>'00020282001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011410001', I_ID_CUSTOMER_NEW=>'00000345001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001104001', I_ID_CUSTOMER_NEW=>'00004687001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006973001', I_ID_CUSTOMER_NEW=>'00019917001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002154001', I_ID_CUSTOMER_NEW=>'00013639001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005753001', I_ID_CUSTOMER_NEW=>'00013639001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001236003', I_ID_CUSTOMER_NEW=>'00009295003');
upd_cu(I_ID_CUSTOMER_OLD=>'00010713001', I_ID_CUSTOMER_NEW=>'00001659001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016221001', I_ID_CUSTOMER_NEW=>'Q0000004762');
upd_cu(I_ID_CUSTOMER_OLD=>'0001135 001', I_ID_CUSTOMER_NEW=>'Q0000004762');
upd_cu(I_ID_CUSTOMER_OLD=>'00027933001', I_ID_CUSTOMER_NEW=>'00021876001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036069001', I_ID_CUSTOMER_NEW=>'00021876001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012460001', I_ID_CUSTOMER_NEW=>'00007520001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003036001', I_ID_CUSTOMER_NEW=>'00003494001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001329001', I_ID_CUSTOMER_NEW=>'00019529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007668001', I_ID_CUSTOMER_NEW=>'00019529001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010258001', I_ID_CUSTOMER_NEW=>'00003470001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003473001', I_ID_CUSTOMER_NEW=>'00014067001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005897001', I_ID_CUSTOMER_NEW=>'Q0000003860');
upd_cu(I_ID_CUSTOMER_OLD=>'00007694001', I_ID_CUSTOMER_NEW=>'Q0000003860');
upd_cu(I_ID_CUSTOMER_OLD=>'00007428001', I_ID_CUSTOMER_NEW=>'00029522001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010117001', I_ID_CUSTOMER_NEW=>'Q0000003171');
upd_cu(I_ID_CUSTOMER_OLD=>'00005957001', I_ID_CUSTOMER_NEW=>'00010523001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008177001', I_ID_CUSTOMER_NEW=>'00019905001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006064001', I_ID_CUSTOMER_NEW=>'00034905001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008565001', I_ID_CUSTOMER_NEW=>'00027400001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005112001', I_ID_CUSTOMER_NEW=>'00007323001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007141001', I_ID_CUSTOMER_NEW=>'00006640001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011414001', I_ID_CUSTOMER_NEW=>'00011423001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005179001', I_ID_CUSTOMER_NEW=>'00025563001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004796001', I_ID_CUSTOMER_NEW=>'00000838001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026070001', I_ID_CUSTOMER_NEW=>'00000838001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036025001', I_ID_CUSTOMER_NEW=>'00000838001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023000001', I_ID_CUSTOMER_NEW=>'00010507001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002195001', I_ID_CUSTOMER_NEW=>'00007008001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012516001', I_ID_CUSTOMER_NEW=>'00018709001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006172001', I_ID_CUSTOMER_NEW=>'00006172002');
upd_cu(I_ID_CUSTOMER_OLD=>'00006172003', I_ID_CUSTOMER_NEW=>'00006172002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007314001', I_ID_CUSTOMER_NEW=>'00030997001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005000001', I_ID_CUSTOMER_NEW=>'00013413001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019532001', I_ID_CUSTOMER_NEW=>'00006419001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004996001', I_ID_CUSTOMER_NEW=>'00017483001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015608001', I_ID_CUSTOMER_NEW=>'00017483001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007618001', I_ID_CUSTOMER_NEW=>'00009263001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019054001', I_ID_CUSTOMER_NEW=>'00004381001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002340001', I_ID_CUSTOMER_NEW=>'00013411001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011794001', I_ID_CUSTOMER_NEW=>'00016926001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002336001', I_ID_CUSTOMER_NEW=>'00033367001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004192001', I_ID_CUSTOMER_NEW=>'00013052001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011506001', I_ID_CUSTOMER_NEW=>'00016237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005955001', I_ID_CUSTOMER_NEW=>'00034226001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006171002', I_ID_CUSTOMER_NEW=>'00001188001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006171003', I_ID_CUSTOMER_NEW=>'00001188001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006171008', I_ID_CUSTOMER_NEW=>'00001188001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012850001', I_ID_CUSTOMER_NEW=>'00003226001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002344001', I_ID_CUSTOMER_NEW=>'00010365001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006736001', I_ID_CUSTOMER_NEW=>'00006099001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013981001', I_ID_CUSTOMER_NEW=>'00011193001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001706001', I_ID_CUSTOMER_NEW=>'00003768001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012563001', I_ID_CUSTOMER_NEW=>'00001409001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012659001', I_ID_CUSTOMER_NEW=>'00018599001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007547001', I_ID_CUSTOMER_NEW=>'00035686001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011191001', I_ID_CUSTOMER_NEW=>'00035686001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013783001', I_ID_CUSTOMER_NEW=>'00035686001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002292001', I_ID_CUSTOMER_NEW=>'00001754001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019186001', I_ID_CUSTOMER_NEW=>'00002357001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031831001', I_ID_CUSTOMER_NEW=>'00002357001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008277001', I_ID_CUSTOMER_NEW=>'00005104001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000488001', I_ID_CUSTOMER_NEW=>'00005655001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007955001', I_ID_CUSTOMER_NEW=>'00019824001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003932001', I_ID_CUSTOMER_NEW=>'00025998001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006255001', I_ID_CUSTOMER_NEW=>'00013573001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007608001', I_ID_CUSTOMER_NEW=>'00005903001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001511001', I_ID_CUSTOMER_NEW=>'00002690001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001935001', I_ID_CUSTOMER_NEW=>'00010046001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001601', I_ID_CUSTOMER_NEW=>'00002228001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009520001', I_ID_CUSTOMER_NEW=>'00002722001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004928001', I_ID_CUSTOMER_NEW=>'00019256001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012329001', I_ID_CUSTOMER_NEW=>'00015123001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007325001', I_ID_CUSTOMER_NEW=>'00019203001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009135001', I_ID_CUSTOMER_NEW=>'00019968001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006145001', I_ID_CUSTOMER_NEW=>'00018612001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007159001', I_ID_CUSTOMER_NEW=>'00007910001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009040001', I_ID_CUSTOMER_NEW=>'00010378001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010278001', I_ID_CUSTOMER_NEW=>'00006621001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005170001', I_ID_CUSTOMER_NEW=>'00034939001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008392001', I_ID_CUSTOMER_NEW=>'00014443001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000541001', I_ID_CUSTOMER_NEW=>'00015427001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003605001', I_ID_CUSTOMER_NEW=>'00013721001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014209001', I_ID_CUSTOMER_NEW=>'00007705001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003216001', I_ID_CUSTOMER_NEW=>'00009251001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005233001', I_ID_CUSTOMER_NEW=>'00026081001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005785001', I_ID_CUSTOMER_NEW=>'00015036001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008669001', I_ID_CUSTOMER_NEW=>'00036048001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010071001', I_ID_CUSTOMER_NEW=>'00000332001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009582001', I_ID_CUSTOMER_NEW=>'00013941001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011198001', I_ID_CUSTOMER_NEW=>'00013941001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006813001', I_ID_CUSTOMER_NEW=>'00009726001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004626001', I_ID_CUSTOMER_NEW=>'00010730001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012050001', I_ID_CUSTOMER_NEW=>'00009764001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022635001', I_ID_CUSTOMER_NEW=>'00008622001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003961001', I_ID_CUSTOMER_NEW=>'00038293001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009289001', I_ID_CUSTOMER_NEW=>'00016957001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010267001', I_ID_CUSTOMER_NEW=>'00000635001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011615001', I_ID_CUSTOMER_NEW=>'00004484001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013686001', I_ID_CUSTOMER_NEW=>'00009826001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007088001', I_ID_CUSTOMER_NEW=>'00017575001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017579001', I_ID_CUSTOMER_NEW=>'00016333001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006626001', I_ID_CUSTOMER_NEW=>'00002151001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006555001', I_ID_CUSTOMER_NEW=>'00010009001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006052001', I_ID_CUSTOMER_NEW=>'00015876001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018471001', I_ID_CUSTOMER_NEW=>'00005681001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037962001', I_ID_CUSTOMER_NEW=>'00005294001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005909001', I_ID_CUSTOMER_NEW=>'00007418001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004436001', I_ID_CUSTOMER_NEW=>'00011305001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010057001', I_ID_CUSTOMER_NEW=>'00011492001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001642001', I_ID_CUSTOMER_NEW=>'00020051001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006071001', I_ID_CUSTOMER_NEW=>'00012326001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006406001', I_ID_CUSTOMER_NEW=>'00018337001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006076001', I_ID_CUSTOMER_NEW=>'00013457001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009956001', I_ID_CUSTOMER_NEW=>'00007699001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002425001', I_ID_CUSTOMER_NEW=>'00001325001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001465001', I_ID_CUSTOMER_NEW=>'00027048001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005597001', I_ID_CUSTOMER_NEW=>'00000438001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007867001', I_ID_CUSTOMER_NEW=>'00031941001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002891001', I_ID_CUSTOMER_NEW=>'00003157001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005446001', I_ID_CUSTOMER_NEW=>'00024977001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005816001', I_ID_CUSTOMER_NEW=>'00010223001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001232001', I_ID_CUSTOMER_NEW=>'00010369001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002975001', I_ID_CUSTOMER_NEW=>'00010369001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006572001', I_ID_CUSTOMER_NEW=>'00010369001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025878001', I_ID_CUSTOMER_NEW=>'00011870001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016649001', I_ID_CUSTOMER_NEW=>'00009667001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013189001', I_ID_CUSTOMER_NEW=>'00018823001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010921001', I_ID_CUSTOMER_NEW=>'00007971001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002021001', I_ID_CUSTOMER_NEW=>'00010113001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004303001', I_ID_CUSTOMER_NEW=>'00037604001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004452001', I_ID_CUSTOMER_NEW=>'00035785001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014122001', I_ID_CUSTOMER_NEW=>'00019269001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017919001', I_ID_CUSTOMER_NEW=>'00019269001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018578001', I_ID_CUSTOMER_NEW=>'00003947001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001925001', I_ID_CUSTOMER_NEW=>'00013176001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007416002', I_ID_CUSTOMER_NEW=>'00007416001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006620002', I_ID_CUSTOMER_NEW=>'00006620001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004883001', I_ID_CUSTOMER_NEW=>'00030418001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016194001', I_ID_CUSTOMER_NEW=>'00008395001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002166001', I_ID_CUSTOMER_NEW=>'00018462001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003034001', I_ID_CUSTOMER_NEW=>'00006160001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034863001', I_ID_CUSTOMER_NEW=>'00007607001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003449001', I_ID_CUSTOMER_NEW=>'00011915001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008171001', I_ID_CUSTOMER_NEW=>'00021508001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005767001', I_ID_CUSTOMER_NEW=>'00025820001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005859001', I_ID_CUSTOMER_NEW=>'00000542001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005910001', I_ID_CUSTOMER_NEW=>'00008307001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008386001', I_ID_CUSTOMER_NEW=>'00028997001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011286001', I_ID_CUSTOMER_NEW=>'00019313001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014154001', I_ID_CUSTOMER_NEW=>'00019313001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002054001', I_ID_CUSTOMER_NEW=>'00010973001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002208001', I_ID_CUSTOMER_NEW=>'00025747001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004720001', I_ID_CUSTOMER_NEW=>'00016439001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012215001', I_ID_CUSTOMER_NEW=>'00016439001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018522001', I_ID_CUSTOMER_NEW=>'00014352001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002072001', I_ID_CUSTOMER_NEW=>'00021493001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010163001', I_ID_CUSTOMER_NEW=>'00013700001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005728001', I_ID_CUSTOMER_NEW=>'00017840001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006176001', I_ID_CUSTOMER_NEW=>'00006176002');
upd_cu(I_ID_CUSTOMER_OLD=>'00007111001', I_ID_CUSTOMER_NEW=>'00019376001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010337001', I_ID_CUSTOMER_NEW=>'00019113001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014378001', I_ID_CUSTOMER_NEW=>'00009356001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006783001', I_ID_CUSTOMER_NEW=>'00025896001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005512001', I_ID_CUSTOMER_NEW=>'00033696001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012320001', I_ID_CUSTOMER_NEW=>'00005579001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013940001', I_ID_CUSTOMER_NEW=>'00020602001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010313001', I_ID_CUSTOMER_NEW=>'00008096001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014116001', I_ID_CUSTOMER_NEW=>'00008098001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001335001', I_ID_CUSTOMER_NEW=>'00022954001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010220001', I_ID_CUSTOMER_NEW=>'00027711001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004632001', I_ID_CUSTOMER_NEW=>'00005760001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013240001', I_ID_CUSTOMER_NEW=>'00005371001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011807001', I_ID_CUSTOMER_NEW=>'00008568001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013103001', I_ID_CUSTOMER_NEW=>'00002896001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001949001', I_ID_CUSTOMER_NEW=>'00013056001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036888001', I_ID_CUSTOMER_NEW=>'00012545001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003822001', I_ID_CUSTOMER_NEW=>'00012008001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001672001', I_ID_CUSTOMER_NEW=>'00011001001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010694001', I_ID_CUSTOMER_NEW=>'00002920001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011428001', I_ID_CUSTOMER_NEW=>'00006895001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008437001', I_ID_CUSTOMER_NEW=>'00012260001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009630001', I_ID_CUSTOMER_NEW=>'00032783001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004685001', I_ID_CUSTOMER_NEW=>'00014146001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009948001', I_ID_CUSTOMER_NEW=>'00002633001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009509001', I_ID_CUSTOMER_NEW=>'00022266001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002449001', I_ID_CUSTOMER_NEW=>'00012240001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013422001', I_ID_CUSTOMER_NEW=>'00000780001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005796001', I_ID_CUSTOMER_NEW=>'00017657001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010471001', I_ID_CUSTOMER_NEW=>'00034865001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015849001', I_ID_CUSTOMER_NEW=>'00034865001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008777001', I_ID_CUSTOMER_NEW=>'00014783001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005433001', I_ID_CUSTOMER_NEW=>'00010086001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005638001', I_ID_CUSTOMER_NEW=>'00007720001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018187001', I_ID_CUSTOMER_NEW=>'00021437001');
upd_cu(I_ID_CUSTOMER_OLD=>'0009955 001', I_ID_CUSTOMER_NEW=>'00021437001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007098001', I_ID_CUSTOMER_NEW=>'00011960001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011619001', I_ID_CUSTOMER_NEW=>'00011960001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018245001', I_ID_CUSTOMER_NEW=>'00012016001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008941001', I_ID_CUSTOMER_NEW=>'00011913001');
upd_cu(I_ID_CUSTOMER_OLD=>'0005722 001', I_ID_CUSTOMER_NEW=>'00020140001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008720001', I_ID_CUSTOMER_NEW=>'00013555001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006587001', I_ID_CUSTOMER_NEW=>'00012811001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018469001', I_ID_CUSTOMER_NEW=>'00005560001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023237001', I_ID_CUSTOMER_NEW=>'00005560001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008105001', I_ID_CUSTOMER_NEW=>'00011772001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002677001', I_ID_CUSTOMER_NEW=>'00012272001');
upd_cu(I_ID_CUSTOMER_OLD=>'0006346 001', I_ID_CUSTOMER_NEW=>'00017214001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013617001', I_ID_CUSTOMER_NEW=>'00029961001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012911001', I_ID_CUSTOMER_NEW=>'00019767001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003246001', I_ID_CUSTOMER_NEW=>'00019815001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013627001', I_ID_CUSTOMER_NEW=>'00017232001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018935001', I_ID_CUSTOMER_NEW=>'00017232001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004785001', I_ID_CUSTOMER_NEW=>'00019831001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001336001', I_ID_CUSTOMER_NEW=>'00033249001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017595001', I_ID_CUSTOMER_NEW=>'00009253001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006223001', I_ID_CUSTOMER_NEW=>'00007560001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004619001', I_ID_CUSTOMER_NEW=>'00027655001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018962001', I_ID_CUSTOMER_NEW=>'00014010001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007903001', I_ID_CUSTOMER_NEW=>'00024507001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011380001', I_ID_CUSTOMER_NEW=>'00013701001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004903001', I_ID_CUSTOMER_NEW=>'00018805001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012829001', I_ID_CUSTOMER_NEW=>'00001747001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009813001', I_ID_CUSTOMER_NEW=>'00006631001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007035001', I_ID_CUSTOMER_NEW=>'00021833001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012751001', I_ID_CUSTOMER_NEW=>'00025802001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011363001', I_ID_CUSTOMER_NEW=>'00017499001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018539001', I_ID_CUSTOMER_NEW=>'00002622001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007769001', I_ID_CUSTOMER_NEW=>'00008560001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006600001', I_ID_CUSTOMER_NEW=>'00018333001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005299001', I_ID_CUSTOMER_NEW=>'00010165001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001967001', I_ID_CUSTOMER_NEW=>'Q0000001407');
upd_cu(I_ID_CUSTOMER_OLD=>'00024061001', I_ID_CUSTOMER_NEW=>'Q0000001407');
upd_cu(I_ID_CUSTOMER_OLD=>'00002105001', I_ID_CUSTOMER_NEW=>'00010717001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005946001', I_ID_CUSTOMER_NEW=>'00018418001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006866001', I_ID_CUSTOMER_NEW=>'00001373001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013108001', I_ID_CUSTOMER_NEW=>'00001373001');
upd_cu(I_ID_CUSTOMER_OLD=>'0001373 001', I_ID_CUSTOMER_NEW=>'00001373001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006011001', I_ID_CUSTOMER_NEW=>'00005941001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013364001', I_ID_CUSTOMER_NEW=>'00010115001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013519001', I_ID_CUSTOMER_NEW=>'00010115001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006757001', I_ID_CUSTOMER_NEW=>'00035520001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010509001', I_ID_CUSTOMER_NEW=>'00001396001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001888002', I_ID_CUSTOMER_NEW=>'00001888001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013382001', I_ID_CUSTOMER_NEW=>'00014364001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005500001', I_ID_CUSTOMER_NEW=>'00026761001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005600001', I_ID_CUSTOMER_NEW=>'00028149001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015607001', I_ID_CUSTOMER_NEW=>'00005372001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005738001', I_ID_CUSTOMER_NEW=>'00029879001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014270001', I_ID_CUSTOMER_NEW=>'00004955001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007633001', I_ID_CUSTOMER_NEW=>'00013040001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004594001', I_ID_CUSTOMER_NEW=>'00021006001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005063001', I_ID_CUSTOMER_NEW=>'00008642001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018786001', I_ID_CUSTOMER_NEW=>'00030553001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007020001', I_ID_CUSTOMER_NEW=>'00023993001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009311001', I_ID_CUSTOMER_NEW=>'00028881001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018377001', I_ID_CUSTOMER_NEW=>'00008893001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012389001', I_ID_CUSTOMER_NEW=>'00025197001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005829001', I_ID_CUSTOMER_NEW=>'00021467001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005563001', I_ID_CUSTOMER_NEW=>'00011155001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026782001', I_ID_CUSTOMER_NEW=>'00003123001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007515001', I_ID_CUSTOMER_NEW=>'00001087002');
upd_cu(I_ID_CUSTOMER_OLD=>'00022909001', I_ID_CUSTOMER_NEW=>'00003073001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011474001', I_ID_CUSTOMER_NEW=>'00012020001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006576001', I_ID_CUSTOMER_NEW=>'00010273001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001664001', I_ID_CUSTOMER_NEW=>'00008237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006979001', I_ID_CUSTOMER_NEW=>'00007209001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013939001', I_ID_CUSTOMER_NEW=>'00018548001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010989001', I_ID_CUSTOMER_NEW=>'00024549001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028262001', I_ID_CUSTOMER_NEW=>'00008629001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004379001', I_ID_CUSTOMER_NEW=>'00017903001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005111001', I_ID_CUSTOMER_NEW=>'00006256001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006176011', I_ID_CUSTOMER_NEW=>'00018736001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008218001', I_ID_CUSTOMER_NEW=>'00018736001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011104001', I_ID_CUSTOMER_NEW=>'00018736001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005471001', I_ID_CUSTOMER_NEW=>'00002861001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006509001', I_ID_CUSTOMER_NEW=>'00005947001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011235001', I_ID_CUSTOMER_NEW=>'00026577001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013571001', I_ID_CUSTOMER_NEW=>'00008818001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009388001', I_ID_CUSTOMER_NEW=>'00017327001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009176001', I_ID_CUSTOMER_NEW=>'00021711001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005379001', I_ID_CUSTOMER_NEW=>'00007555001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029182001', I_ID_CUSTOMER_NEW=>'00002663001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011764001', I_ID_CUSTOMER_NEW=>'00028910001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006734001', I_ID_CUSTOMER_NEW=>'00035014001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010366001', I_ID_CUSTOMER_NEW=>'00006692001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013790001', I_ID_CUSTOMER_NEW=>'00005297001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009574001', I_ID_CUSTOMER_NEW=>'00006556001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013979001', I_ID_CUSTOMER_NEW=>'00014310001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010406001', I_ID_CUSTOMER_NEW=>'00019101001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009355001', I_ID_CUSTOMER_NEW=>'00008103001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006034001', I_ID_CUSTOMER_NEW=>'00007306001');
upd_cu(I_ID_CUSTOMER_OLD=>'00000934002', I_ID_CUSTOMER_NEW=>'00000933002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003652001', I_ID_CUSTOMER_NEW=>'00000933002');
upd_cu(I_ID_CUSTOMER_OLD=>'00008142001', I_ID_CUSTOMER_NEW=>'00016783001');
upd_cu(I_ID_CUSTOMER_OLD=>'0005289 001', I_ID_CUSTOMER_NEW=>'00015868001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008300001', I_ID_CUSTOMER_NEW=>'00019449001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018153001', I_ID_CUSTOMER_NEW=>'00004515001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007429001', I_ID_CUSTOMER_NEW=>'00017671001');
upd_cu(I_ID_CUSTOMER_OLD=>'00003801001', I_ID_CUSTOMER_NEW=>'00016736001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004800', I_ID_CUSTOMER_NEW=>'00008944001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009461001', I_ID_CUSTOMER_NEW=>'00009361001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013312001', I_ID_CUSTOMER_NEW=>'00013570001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006318001', I_ID_CUSTOMER_NEW=>'00018627001');
upd_cu(I_ID_CUSTOMER_OLD=>'001423  001', I_ID_CUSTOMER_NEW=>'00014223001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016213001', I_ID_CUSTOMER_NEW=>'00012896001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007615001', I_ID_CUSTOMER_NEW=>'00011194001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009672001', I_ID_CUSTOMER_NEW=>'00011194001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008571001', I_ID_CUSTOMER_NEW=>'00014237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013787001', I_ID_CUSTOMER_NEW=>'00014237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017994001', I_ID_CUSTOMER_NEW=>'00014237001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014088001', I_ID_CUSTOMER_NEW=>'00005378001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006094001', I_ID_CUSTOMER_NEW=>'00016647001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016067001', I_ID_CUSTOMER_NEW=>'00016647001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010432001', I_ID_CUSTOMER_NEW=>'00012917001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005574001', I_ID_CUSTOMER_NEW=>'00007568001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005358001', I_ID_CUSTOMER_NEW=>'00034992001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008957001', I_ID_CUSTOMER_NEW=>'00036645001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018844001', I_ID_CUSTOMER_NEW=>'00009147001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009363001', I_ID_CUSTOMER_NEW=>'00019308001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016364001', I_ID_CUSTOMER_NEW=>'00019308001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010263001', I_ID_CUSTOMER_NEW=>'00007367001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007684001', I_ID_CUSTOMER_NEW=>'00010295001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010150001', I_ID_CUSTOMER_NEW=>'00013949001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009450001', I_ID_CUSTOMER_NEW=>'00016060001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010069001', I_ID_CUSTOMER_NEW=>'00012698001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012541001', I_ID_CUSTOMER_NEW=>'00009733001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008292001', I_ID_CUSTOMER_NEW=>'00009386001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010825001', I_ID_CUSTOMER_NEW=>'00025504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008750001', I_ID_CUSTOMER_NEW=>'00013566001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008923001', I_ID_CUSTOMER_NEW=>'00013566001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008562001', I_ID_CUSTOMER_NEW=>'00011893001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011430001', I_ID_CUSTOMER_NEW=>'00011893001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011034001', I_ID_CUSTOMER_NEW=>'00021745001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010284001', I_ID_CUSTOMER_NEW=>'00010666001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021889001', I_ID_CUSTOMER_NEW=>'00011472001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019572001', I_ID_CUSTOMER_NEW=>'00011805001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002426001', I_ID_CUSTOMER_NEW=>'00006096001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006143001', I_ID_CUSTOMER_NEW=>'00016513001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008423001', I_ID_CUSTOMER_NEW=>'00011265001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006893001', I_ID_CUSTOMER_NEW=>'00016787001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004196', I_ID_CUSTOMER_NEW=>'00009523001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002403001', I_ID_CUSTOMER_NEW=>'00016336001');
upd_cu(I_ID_CUSTOMER_OLD=>'00002665001', I_ID_CUSTOMER_NEW=>'00023601001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017235001', I_ID_CUSTOMER_NEW=>'00023601001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013400001', I_ID_CUSTOMER_NEW=>'00019146001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006484001', I_ID_CUSTOMER_NEW=>'00021759001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013777001', I_ID_CUSTOMER_NEW=>'00027372001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012309001', I_ID_CUSTOMER_NEW=>'00006507001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004331001', I_ID_CUSTOMER_NEW=>'00028361001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006156001', I_ID_CUSTOMER_NEW=>'00011190001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006661001', I_ID_CUSTOMER_NEW=>'00021540001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009711001', I_ID_CUSTOMER_NEW=>'00028234001');
upd_cu(I_ID_CUSTOMER_OLD=>'00011352001', I_ID_CUSTOMER_NEW=>'Q0000002336');
upd_cu(I_ID_CUSTOMER_OLD=>'00012819001', I_ID_CUSTOMER_NEW=>'Q0000002336');
upd_cu(I_ID_CUSTOMER_OLD=>'00006504001', I_ID_CUSTOMER_NEW=>'00005092001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004635001', I_ID_CUSTOMER_NEW=>'00012680001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007666001', I_ID_CUSTOMER_NEW=>'00004288001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013734001', I_ID_CUSTOMER_NEW=>'00004470001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004901001', I_ID_CUSTOMER_NEW=>'00004227001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021187001', I_ID_CUSTOMER_NEW=>'00007424001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006810001', I_ID_CUSTOMER_NEW=>'00006805001');
upd_cu(I_ID_CUSTOMER_OLD=>'00012001001', I_ID_CUSTOMER_NEW=>'00020228001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009381001', I_ID_CUSTOMER_NEW=>'00013073001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015718001', I_ID_CUSTOMER_NEW=>'00007567001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007824001', I_ID_CUSTOMER_NEW=>'00009816001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017900001', I_ID_CUSTOMER_NEW=>'00005900001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022862001', I_ID_CUSTOMER_NEW=>'00012218001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001505001', I_ID_CUSTOMER_NEW=>'Q0000001098');
upd_cu(I_ID_CUSTOMER_OLD=>'00009963001', I_ID_CUSTOMER_NEW=>'00018576001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005315001', I_ID_CUSTOMER_NEW=>'00018582001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016370001', I_ID_CUSTOMER_NEW=>'00011854001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014579001', I_ID_CUSTOMER_NEW=>'00025912001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014521001', I_ID_CUSTOMER_NEW=>'00031903001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015978001', I_ID_CUSTOMER_NEW=>'00014403001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013764001', I_ID_CUSTOMER_NEW=>'00025724001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014563001', I_ID_CUSTOMER_NEW=>'00017435001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014672001', I_ID_CUSTOMER_NEW=>'00026028001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014930001', I_ID_CUSTOMER_NEW=>'00028974001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014731001', I_ID_CUSTOMER_NEW=>'Q0000000169');
upd_cu(I_ID_CUSTOMER_OLD=>'00014814001', I_ID_CUSTOMER_NEW=>'00030226001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025959001', I_ID_CUSTOMER_NEW=>'00014821001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028556001', I_ID_CUSTOMER_NEW=>'00014915001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028253001', I_ID_CUSTOMER_NEW=>'00014845001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016196001', I_ID_CUSTOMER_NEW=>'00014795001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014958001', I_ID_CUSTOMER_NEW=>'00027658001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015033001', I_ID_CUSTOMER_NEW=>'00036971001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017545001', I_ID_CUSTOMER_NEW=>'00015056001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015043001', I_ID_CUSTOMER_NEW=>'00015992001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015097001', I_ID_CUSTOMER_NEW=>'00034927001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015141001', I_ID_CUSTOMER_NEW=>'00026098001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015195001', I_ID_CUSTOMER_NEW=>'00036606001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014561001', I_ID_CUSTOMER_NEW=>'00031888001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019373001', I_ID_CUSTOMER_NEW=>'00031888001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017651001', I_ID_CUSTOMER_NEW=>'00014530001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004694', I_ID_CUSTOMER_NEW=>'00014569001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015239001', I_ID_CUSTOMER_NEW=>'00017303001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015281001', I_ID_CUSTOMER_NEW=>'00035521001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028665001', I_ID_CUSTOMER_NEW=>'00015371001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015486001', I_ID_CUSTOMER_NEW=>'00023953001');
upd_cu(I_ID_CUSTOMER_OLD=>'00006440002', I_ID_CUSTOMER_NEW=>'00006439002');
upd_cu(I_ID_CUSTOMER_OLD=>'00003692001', I_ID_CUSTOMER_NEW=>'00015615001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015704001', I_ID_CUSTOMER_NEW=>'00004987001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015725001', I_ID_CUSTOMER_NEW=>'00023486001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005730001', I_ID_CUSTOMER_NEW=>'00014097001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015873001', I_ID_CUSTOMER_NEW=>'00024657001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015888001', I_ID_CUSTOMER_NEW=>'00019924001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036026001', I_ID_CUSTOMER_NEW=>'00019924001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018608001', I_ID_CUSTOMER_NEW=>'00015996001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014203001', I_ID_CUSTOMER_NEW=>'00016005001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025886001', I_ID_CUSTOMER_NEW=>'00016031001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016084001', I_ID_CUSTOMER_NEW=>'00022571001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016144001', I_ID_CUSTOMER_NEW=>'00028341001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014257001', I_ID_CUSTOMER_NEW=>'00014622001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009560001', I_ID_CUSTOMER_NEW=>'00010532001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016168001', I_ID_CUSTOMER_NEW=>'00027562001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016205001', I_ID_CUSTOMER_NEW=>'00026002001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016208001', I_ID_CUSTOMER_NEW=>'00035887001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017920001', I_ID_CUSTOMER_NEW=>'00016209001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016254001', I_ID_CUSTOMER_NEW=>'00018061001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016214001', I_ID_CUSTOMER_NEW=>'00034265001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016256001', I_ID_CUSTOMER_NEW=>'00035081001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032841001', I_ID_CUSTOMER_NEW=>'00016307001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016219001', I_ID_CUSTOMER_NEW=>'00031671001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033532001', I_ID_CUSTOMER_NEW=>'00031671001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013513001', I_ID_CUSTOMER_NEW=>'00015915001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005478001', I_ID_CUSTOMER_NEW=>'00035846001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027572001', I_ID_CUSTOMER_NEW=>'00016327001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016419001', I_ID_CUSTOMER_NEW=>'00016440001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016423001', I_ID_CUSTOMER_NEW=>'00027810001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007917001', I_ID_CUSTOMER_NEW=>'00016487001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016495001', I_ID_CUSTOMER_NEW=>'00032169001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016505001', I_ID_CUSTOMER_NEW=>'00032208001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016424001', I_ID_CUSTOMER_NEW=>'00011912001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016661001', I_ID_CUSTOMER_NEW=>'00019913001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016699001', I_ID_CUSTOMER_NEW=>'00030064001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020768001', I_ID_CUSTOMER_NEW=>'00016675001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016764001', I_ID_CUSTOMER_NEW=>'00026763001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016739001', I_ID_CUSTOMER_NEW=>'00033522001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018330001', I_ID_CUSTOMER_NEW=>'00033522001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007761008', I_ID_CUSTOMER_NEW=>'00007761007');
upd_cu(I_ID_CUSTOMER_OLD=>'00016839001', I_ID_CUSTOMER_NEW=>'00019176001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016974001', I_ID_CUSTOMER_NEW=>'Q0000000985');
upd_cu(I_ID_CUSTOMER_OLD=>'00016909001', I_ID_CUSTOMER_NEW=>'00027742001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026772001', I_ID_CUSTOMER_NEW=>'00016911001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027103001', I_ID_CUSTOMER_NEW=>'00016911001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016952001', I_ID_CUSTOMER_NEW=>'00028825001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017000001', I_ID_CUSTOMER_NEW=>'00021639001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017024001', I_ID_CUSTOMER_NEW=>'00034613001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017165001', I_ID_CUSTOMER_NEW=>'Q0000000683');
upd_cu(I_ID_CUSTOMER_OLD=>'00017168001', I_ID_CUSTOMER_NEW=>'00036296001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017192001', I_ID_CUSTOMER_NEW=>'00024596001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017361001', I_ID_CUSTOMER_NEW=>'00029976001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028004001', I_ID_CUSTOMER_NEW=>'00029976001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035637001', I_ID_CUSTOMER_NEW=>'00017395001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017443001', I_ID_CUSTOMER_NEW=>'00021663001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017446001', I_ID_CUSTOMER_NEW=>'00037340001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017305001', I_ID_CUSTOMER_NEW=>'00024750001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017520001', I_ID_CUSTOMER_NEW=>'00026761001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021126001', I_ID_CUSTOMER_NEW=>'00017548001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018051001', I_ID_CUSTOMER_NEW=>'00017541001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017609001', I_ID_CUSTOMER_NEW=>'00031767001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017619001', I_ID_CUSTOMER_NEW=>'00033336001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017669001', I_ID_CUSTOMER_NEW=>'00024121001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017693001', I_ID_CUSTOMER_NEW=>'00036459001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017726001', I_ID_CUSTOMER_NEW=>'00021129001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017848001', I_ID_CUSTOMER_NEW=>'00032803001');
upd_cu(I_ID_CUSTOMER_OLD=>'00001046001', I_ID_CUSTOMER_NEW=>'00017850001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018295001', I_ID_CUSTOMER_NEW=>'00017916001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021440001', I_ID_CUSTOMER_NEW=>'00017580001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017959001', I_ID_CUSTOMER_NEW=>'00038043001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017981001', I_ID_CUSTOMER_NEW=>'00019925001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018058001', I_ID_CUSTOMER_NEW=>'00022713001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014803002', I_ID_CUSTOMER_NEW=>'00026428001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018224001', I_ID_CUSTOMER_NEW=>'00018420001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018263001', I_ID_CUSTOMER_NEW=>'00029980001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013944001', I_ID_CUSTOMER_NEW=>'00018234001');
upd_cu(I_ID_CUSTOMER_OLD=>'00017228001', I_ID_CUSTOMER_NEW=>'00018234001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018243001', I_ID_CUSTOMER_NEW=>'00025999001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018332001', I_ID_CUSTOMER_NEW=>'00032980001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018529001', I_ID_CUSTOMER_NEW=>'00022955001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018533001', I_ID_CUSTOMER_NEW=>'00030742001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018518001', I_ID_CUSTOMER_NEW=>'00032200001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018542001', I_ID_CUSTOMER_NEW=>'00035265001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018596001', I_ID_CUSTOMER_NEW=>'00034644001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018644001', I_ID_CUSTOMER_NEW=>'00019068001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018656001', I_ID_CUSTOMER_NEW=>'00028832001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037177001', I_ID_CUSTOMER_NEW=>'00018724001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018799001', I_ID_CUSTOMER_NEW=>'00037829001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018743001', I_ID_CUSTOMER_NEW=>'00025848001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022779001', I_ID_CUSTOMER_NEW=>'00029774001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018873001', I_ID_CUSTOMER_NEW=>'00024170001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018876001', I_ID_CUSTOMER_NEW=>'00021396001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018913001', I_ID_CUSTOMER_NEW=>'Q0000002265');
upd_cu(I_ID_CUSTOMER_OLD=>'00026596001', I_ID_CUSTOMER_NEW=>'00018936001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018968001', I_ID_CUSTOMER_NEW=>'00018969001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029365001', I_ID_CUSTOMER_NEW=>'00018953001');
upd_cu(I_ID_CUSTOMER_OLD=>'00013870001', I_ID_CUSTOMER_NEW=>'00035533001');
upd_cu(I_ID_CUSTOMER_OLD=>'00018808001', I_ID_CUSTOMER_NEW=>'00031663001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019032001', I_ID_CUSTOMER_NEW=>'00031308001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019040001', I_ID_CUSTOMER_NEW=>'00019240001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019053001', I_ID_CUSTOMER_NEW=>'Q0000000462');
upd_cu(I_ID_CUSTOMER_OLD=>'00019061001', I_ID_CUSTOMER_NEW=>'00020280001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008849001', I_ID_CUSTOMER_NEW=>'00019114001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019136001', I_ID_CUSTOMER_NEW=>'00022761001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028621001', I_ID_CUSTOMER_NEW=>'00019159001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021177001', I_ID_CUSTOMER_NEW=>'00019166001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019260001', I_ID_CUSTOMER_NEW=>'00026662001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019242001', I_ID_CUSTOMER_NEW=>'00026734001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019200001', I_ID_CUSTOMER_NEW=>'00024101001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024303001', I_ID_CUSTOMER_NEW=>'00019338001');
upd_cu(I_ID_CUSTOMER_OLD=>'00016551001', I_ID_CUSTOMER_NEW=>'00025128001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019649001', I_ID_CUSTOMER_NEW=>'00028863001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019682001', I_ID_CUSTOMER_NEW=>'00029720001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028427001', I_ID_CUSTOMER_NEW=>'00019709001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028483001', I_ID_CUSTOMER_NEW=>'00019878001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019798001', I_ID_CUSTOMER_NEW=>'00030339001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019579001', I_ID_CUSTOMER_NEW=>'00018736001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004601001', I_ID_CUSTOMER_NEW=>'00019602001');
upd_cu(I_ID_CUSTOMER_OLD=>'00019440001', I_ID_CUSTOMER_NEW=>'00024905001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020106001', I_ID_CUSTOMER_NEW=>'00026577001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020105001', I_ID_CUSTOMER_NEW=>'00031545001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020123001', I_ID_CUSTOMER_NEW=>'00031890001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020226001', I_ID_CUSTOMER_NEW=>'00029282001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027086001', I_ID_CUSTOMER_NEW=>'00029282001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020230001', I_ID_CUSTOMER_NEW=>'00026353001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020233001', I_ID_CUSTOMER_NEW=>'00035848001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020234001', I_ID_CUSTOMER_NEW=>'00022174001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020504001', I_ID_CUSTOMER_NEW=>'00031841001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020529001', I_ID_CUSTOMER_NEW=>'00035644001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020618001', I_ID_CUSTOMER_NEW=>'00026304001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020641001', I_ID_CUSTOMER_NEW=>'00025193001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002272', I_ID_CUSTOMER_NEW=>'00020650001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020671001', I_ID_CUSTOMER_NEW=>'00036554001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020721001', I_ID_CUSTOMER_NEW=>'00023834001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020802001', I_ID_CUSTOMER_NEW=>'00023954001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020871001', I_ID_CUSTOMER_NEW=>'Q0000001378');
upd_cu(I_ID_CUSTOMER_OLD=>'00025909001', I_ID_CUSTOMER_NEW=>'00020907001');
upd_cu(I_ID_CUSTOMER_OLD=>'00020926001', I_ID_CUSTOMER_NEW=>'Q0000000625');
upd_cu(I_ID_CUSTOMER_OLD=>'00037309001', I_ID_CUSTOMER_NEW=>'00007436001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021026001', I_ID_CUSTOMER_NEW=>'00035666001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021116001', I_ID_CUSTOMER_NEW=>'00036143001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027085001', I_ID_CUSTOMER_NEW=>'00020784001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028543001', I_ID_CUSTOMER_NEW=>'00021057001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021060001', I_ID_CUSTOMER_NEW=>'00028315001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021076001', I_ID_CUSTOMER_NEW=>'00035869001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028525001', I_ID_CUSTOMER_NEW=>'00035869001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034981001', I_ID_CUSTOMER_NEW=>'00021283001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021399001', I_ID_CUSTOMER_NEW=>'00010644001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021492001', I_ID_CUSTOMER_NEW=>'00037217001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021523001', I_ID_CUSTOMER_NEW=>'00009162001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021537001', I_ID_CUSTOMER_NEW=>'00026842001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021604001', I_ID_CUSTOMER_NEW=>'Q0000000237');
upd_cu(I_ID_CUSTOMER_OLD=>'00021579001', I_ID_CUSTOMER_NEW=>'00028070001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021822001', I_ID_CUSTOMER_NEW=>'00025479001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021696001', I_ID_CUSTOMER_NEW=>'00031141001');
upd_cu(I_ID_CUSTOMER_OLD=>'00021954001', I_ID_CUSTOMER_NEW=>'00034100001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036375001', I_ID_CUSTOMER_NEW=>'00022231001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022295001', I_ID_CUSTOMER_NEW=>'00037141001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022298001', I_ID_CUSTOMER_NEW=>'00032359001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022396001', I_ID_CUSTOMER_NEW=>'00027851001');
upd_cu(I_ID_CUSTOMER_OLD=>'00009420001', I_ID_CUSTOMER_NEW=>'Q0000000473');
upd_cu(I_ID_CUSTOMER_OLD=>'00022440001', I_ID_CUSTOMER_NEW=>'00022914001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022472001', I_ID_CUSTOMER_NEW=>'00024589001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025734001', I_ID_CUSTOMER_NEW=>'00022631001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022681001', I_ID_CUSTOMER_NEW=>'00027546001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027108001', I_ID_CUSTOMER_NEW=>'00022685001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022806001', I_ID_CUSTOMER_NEW=>'00030902001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022843001', I_ID_CUSTOMER_NEW=>'00032946001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022867001', I_ID_CUSTOMER_NEW=>'00027270001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035286001', I_ID_CUSTOMER_NEW=>'00022868001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022938001', I_ID_CUSTOMER_NEW=>'00036642001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022910001', I_ID_CUSTOMER_NEW=>'00027799001');
upd_cu(I_ID_CUSTOMER_OLD=>'00022971001', I_ID_CUSTOMER_NEW=>'00035370001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000003934', I_ID_CUSTOMER_NEW=>'00022972001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023228001', I_ID_CUSTOMER_NEW=>'00028005001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023236001', I_ID_CUSTOMER_NEW=>'00036492001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026750001', I_ID_CUSTOMER_NEW=>'00023331001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033610001', I_ID_CUSTOMER_NEW=>'00023367001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000190', I_ID_CUSTOMER_NEW=>'00023411001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023692001', I_ID_CUSTOMER_NEW=>'00024579001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023906001', I_ID_CUSTOMER_NEW=>'00032206001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023897001', I_ID_CUSTOMER_NEW=>'00034873001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023872001', I_ID_CUSTOMER_NEW=>'00034744001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034921001', I_ID_CUSTOMER_NEW=>'00023863001');
upd_cu(I_ID_CUSTOMER_OLD=>'00023935001', I_ID_CUSTOMER_NEW=>'Q0000001390');
upd_cu(I_ID_CUSTOMER_OLD=>'00024034001', I_ID_CUSTOMER_NEW=>'00024301001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024124001', I_ID_CUSTOMER_NEW=>'Q0000000544');
upd_cu(I_ID_CUSTOMER_OLD=>'00036027001', I_ID_CUSTOMER_NEW=>'00024174001');
upd_cu(I_ID_CUSTOMER_OLD=>'00015994001', I_ID_CUSTOMER_NEW=>'99900400000');
upd_cu(I_ID_CUSTOMER_OLD=>'00015999001', I_ID_CUSTOMER_NEW=>'99900600000');
upd_cu(I_ID_CUSTOMER_OLD=>'00024428001', I_ID_CUSTOMER_NEW=>'00035840001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024417001', I_ID_CUSTOMER_NEW=>'00036634001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024423001', I_ID_CUSTOMER_NEW=>'00035844001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024455001', I_ID_CUSTOMER_NEW=>'00032878001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031790001', I_ID_CUSTOMER_NEW=>'00024505001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035528001', I_ID_CUSTOMER_NEW=>'00024500001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024558001', I_ID_CUSTOMER_NEW=>'00025731001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024613001', I_ID_CUSTOMER_NEW=>'00035702001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035177001', I_ID_CUSTOMER_NEW=>'00024658001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024816001', I_ID_CUSTOMER_NEW=>'00028789001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024901001', I_ID_CUSTOMER_NEW=>'00035935001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024908001', I_ID_CUSTOMER_NEW=>'00036751001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024956001', I_ID_CUSTOMER_NEW=>'00036643001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025124001', I_ID_CUSTOMER_NEW=>'00007990001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025132001', I_ID_CUSTOMER_NEW=>'00034943001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025096001', I_ID_CUSTOMER_NEW=>'00006187001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024937001', I_ID_CUSTOMER_NEW=>'00025141001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025149001', I_ID_CUSTOMER_NEW=>'00024350001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036573001', I_ID_CUSTOMER_NEW=>'00025191001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001357', I_ID_CUSTOMER_NEW=>'00025267001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025251001', I_ID_CUSTOMER_NEW=>'Q0000001400');
upd_cu(I_ID_CUSTOMER_OLD=>'00025414001', I_ID_CUSTOMER_NEW=>'00023767001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025402001', I_ID_CUSTOMER_NEW=>'00035400001');
upd_cu(I_ID_CUSTOMER_OLD=>'00014878001', I_ID_CUSTOMER_NEW=>'00033193001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026540001', I_ID_CUSTOMER_NEW=>'00025311001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025756001', I_ID_CUSTOMER_NEW=>'00033336001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031636001', I_ID_CUSTOMER_NEW=>'00025816001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027712001', I_ID_CUSTOMER_NEW=>'00025844001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025890001', I_ID_CUSTOMER_NEW=>'00033528001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025992001', I_ID_CUSTOMER_NEW=>'Q0000004794');
upd_cu(I_ID_CUSTOMER_OLD=>'00026056001', I_ID_CUSTOMER_NEW=>'00028816001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026089001', I_ID_CUSTOMER_NEW=>'00026917001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025679001', I_ID_CUSTOMER_NEW=>'Q0000004807');
upd_cu(I_ID_CUSTOMER_OLD=>'00026215001', I_ID_CUSTOMER_NEW=>'00032127001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026397001', I_ID_CUSTOMER_NEW=>'00022717001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028954001', I_ID_CUSTOMER_NEW=>'00026408001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026412001', I_ID_CUSTOMER_NEW=>'00029055001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026257001', I_ID_CUSTOMER_NEW=>'00036645001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026524001', I_ID_CUSTOMER_NEW=>'00036595001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026613001', I_ID_CUSTOMER_NEW=>'00027323001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026740001', I_ID_CUSTOMER_NEW=>'Q0000000270');
upd_cu(I_ID_CUSTOMER_OLD=>'00026841001', I_ID_CUSTOMER_NEW=>'00027060001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026901001', I_ID_CUSTOMER_NEW=>'00032615001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026845001', I_ID_CUSTOMER_NEW=>'00028432001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026855001', I_ID_CUSTOMER_NEW=>'00028449001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027043001', I_ID_CUSTOMER_NEW=>'00026930001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028018001', I_ID_CUSTOMER_NEW=>'00026588001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027083001', I_ID_CUSTOMER_NEW=>'00007388001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027148001', I_ID_CUSTOMER_NEW=>'00037509001');
upd_cu(I_ID_CUSTOMER_OLD=>'00026868001', I_ID_CUSTOMER_NEW=>'Q0000001741');
upd_cu(I_ID_CUSTOMER_OLD=>'00026871001', I_ID_CUSTOMER_NEW=>'00036439001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027426001', I_ID_CUSTOMER_NEW=>'00030724001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000004732', I_ID_CUSTOMER_NEW=>'00027386001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027477001', I_ID_CUSTOMER_NEW=>'00006811001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034877001', I_ID_CUSTOMER_NEW=>'00027381001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027500001', I_ID_CUSTOMER_NEW=>'00030470001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027509001', I_ID_CUSTOMER_NEW=>'00028825001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027648001', I_ID_CUSTOMER_NEW=>'00028150001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027689001', I_ID_CUSTOMER_NEW=>'00035025001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027204001', I_ID_CUSTOMER_NEW=>'00029363001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027730001', I_ID_CUSTOMER_NEW=>'00019534001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027812001', I_ID_CUSTOMER_NEW=>'00027821001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002707', I_ID_CUSTOMER_NEW=>'00027901001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000580', I_ID_CUSTOMER_NEW=>'00027869001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027890001', I_ID_CUSTOMER_NEW=>'00037838001');
upd_cu(I_ID_CUSTOMER_OLD=>'00027991001', I_ID_CUSTOMER_NEW=>'00029647001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028040001', I_ID_CUSTOMER_NEW=>'00036598001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028181001', I_ID_CUSTOMER_NEW=>'00029713001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029186001', I_ID_CUSTOMER_NEW=>'00028279001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028414001', I_ID_CUSTOMER_NEW=>'00033742001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031693001', I_ID_CUSTOMER_NEW=>'00033742001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002479', I_ID_CUSTOMER_NEW=>'00027505001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028456001', I_ID_CUSTOMER_NEW=>'00031425001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028461001', I_ID_CUSTOMER_NEW=>'00034931001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028494001', I_ID_CUSTOMER_NEW=>'00032429001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028151001', I_ID_CUSTOMER_NEW=>'00033616001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034080001', I_ID_CUSTOMER_NEW=>'00028624001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028670001', I_ID_CUSTOMER_NEW=>'00029732001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000003731', I_ID_CUSTOMER_NEW=>'00028700001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028812001', I_ID_CUSTOMER_NEW=>'00029187001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008758001', I_ID_CUSTOMER_NEW=>'00028867001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028908001', I_ID_CUSTOMER_NEW=>'Q0000000285');
upd_cu(I_ID_CUSTOMER_OLD=>'00028898001', I_ID_CUSTOMER_NEW=>'Q0000000895');
upd_cu(I_ID_CUSTOMER_OLD=>'00028955001', I_ID_CUSTOMER_NEW=>'00032206001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028161001', I_ID_CUSTOMER_NEW=>'00012323001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029014001', I_ID_CUSTOMER_NEW=>'00035143001');
upd_cu(I_ID_CUSTOMER_OLD=>'00028994001', I_ID_CUSTOMER_NEW=>'00036368001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034926001', I_ID_CUSTOMER_NEW=>'00029793001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029820001', I_ID_CUSTOMER_NEW=>'00034938001');
upd_cu(I_ID_CUSTOMER_OLD=>'00029826001', I_ID_CUSTOMER_NEW=>'00035937001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030046001', I_ID_CUSTOMER_NEW=>'00029672001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035636001', I_ID_CUSTOMER_NEW=>'00030128001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030230001', I_ID_CUSTOMER_NEW=>'00034617001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030319001', I_ID_CUSTOMER_NEW=>'00031342001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030474001', I_ID_CUSTOMER_NEW=>'00034099001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030669001', I_ID_CUSTOMER_NEW=>'00015737001');
upd_cu(I_ID_CUSTOMER_OLD=>'00030772001', I_ID_CUSTOMER_NEW=>'00008089001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031436001', I_ID_CUSTOMER_NEW=>'00036376001');
upd_cu(I_ID_CUSTOMER_OLD=>'00031926001', I_ID_CUSTOMER_NEW=>'00023725001');
upd_cu(I_ID_CUSTOMER_OLD=>'00025359001', I_ID_CUSTOMER_NEW=>'Q0000001831');
upd_cu(I_ID_CUSTOMER_OLD=>'00032150001', I_ID_CUSTOMER_NEW=>'00038293001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032194001', I_ID_CUSTOMER_NEW=>'00034648001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032440001', I_ID_CUSTOMER_NEW=>'Q0000000670');
upd_cu(I_ID_CUSTOMER_OLD=>'00032442001', I_ID_CUSTOMER_NEW=>'00003123001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032444001', I_ID_CUSTOMER_NEW=>'00038222001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000177', I_ID_CUSTOMER_NEW=>'00032425001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032786001', I_ID_CUSTOMER_NEW=>'00036592001');
upd_cu(I_ID_CUSTOMER_OLD=>'00032979001', I_ID_CUSTOMER_NEW=>'00027253001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033256001', I_ID_CUSTOMER_NEW=>'00022505001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033315001', I_ID_CUSTOMER_NEW=>'00037966001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033338001', I_ID_CUSTOMER_NEW=>'00036290001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033408001', I_ID_CUSTOMER_NEW=>'00034865001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033450001', I_ID_CUSTOMER_NEW=>'00032052001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033618001', I_ID_CUSTOMER_NEW=>'00024362001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034858001', I_ID_CUSTOMER_NEW=>'00033719001');
upd_cu(I_ID_CUSTOMER_OLD=>'00033781001', I_ID_CUSTOMER_NEW=>'00034784001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000000565', I_ID_CUSTOMER_NEW=>'00033828001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034021001', I_ID_CUSTOMER_NEW=>'00035723001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034105001', I_ID_CUSTOMER_NEW=>'00006370001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034221001', I_ID_CUSTOMER_NEW=>'00036307001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034155001', I_ID_CUSTOMER_NEW=>'00034836001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034380001', I_ID_CUSTOMER_NEW=>'00036630001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034390001', I_ID_CUSTOMER_NEW=>'Q0000001274');
upd_cu(I_ID_CUSTOMER_OLD=>'00034471001', I_ID_CUSTOMER_NEW=>'Q0000000687');
upd_cu(I_ID_CUSTOMER_OLD=>'00034606001', I_ID_CUSTOMER_NEW=>'00034799001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034915001', I_ID_CUSTOMER_NEW=>'00023517001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034933001', I_ID_CUSTOMER_NEW=>'00036597001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034856001', I_ID_CUSTOMER_NEW=>'00017293001');
upd_cu(I_ID_CUSTOMER_OLD=>'00024654001', I_ID_CUSTOMER_NEW=>'00032650001');
upd_cu(I_ID_CUSTOMER_OLD=>'00034919001', I_ID_CUSTOMER_NEW=>'00032650001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035032001', I_ID_CUSTOMER_NEW=>'00020282001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035576001', I_ID_CUSTOMER_NEW=>'00036028001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035822001', I_ID_CUSTOMER_NEW=>'00036795001');
upd_cu(I_ID_CUSTOMER_OLD=>'00035862001', I_ID_CUSTOMER_NEW=>'Q0000003119');
upd_cu(I_ID_CUSTOMER_OLD=>'00035871001', I_ID_CUSTOMER_NEW=>'Q0000002456');
upd_cu(I_ID_CUSTOMER_OLD=>'00035944001', I_ID_CUSTOMER_NEW=>'00000269001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036022001', I_ID_CUSTOMER_NEW=>'Q0000000995');
upd_cu(I_ID_CUSTOMER_OLD=>'00036132001', I_ID_CUSTOMER_NEW=>'Q0000001273');
upd_cu(I_ID_CUSTOMER_OLD=>'00036203001', I_ID_CUSTOMER_NEW=>'00037160001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036286001', I_ID_CUSTOMER_NEW=>'Q0000000536');
upd_cu(I_ID_CUSTOMER_OLD=>'00036431001', I_ID_CUSTOMER_NEW=>'Q0000000536');
upd_cu(I_ID_CUSTOMER_OLD=>'00036309001', I_ID_CUSTOMER_NEW=>'00036205001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036596001', I_ID_CUSTOMER_NEW=>'00025953001');
upd_cu(I_ID_CUSTOMER_OLD=>'00036696001', I_ID_CUSTOMER_NEW=>'Q0000003820');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001564', I_ID_CUSTOMER_NEW=>'00036879001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037050001', I_ID_CUSTOMER_NEW=>'00027942001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037042001', I_ID_CUSTOMER_NEW=>'00030125001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037011001', I_ID_CUSTOMER_NEW=>'00020282001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037283001', I_ID_CUSTOMER_NEW=>'Q0000000286');
upd_cu(I_ID_CUSTOMER_OLD=>'00037467001', I_ID_CUSTOMER_NEW=>'Q0000003253');
upd_cu(I_ID_CUSTOMER_OLD=>'C0000000858', I_ID_CUSTOMER_NEW=>'00037608001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037816001', I_ID_CUSTOMER_NEW=>'00034213001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001148', I_ID_CUSTOMER_NEW=>'00038003001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001500', I_ID_CUSTOMER_NEW=>'Q0000001561');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001408', I_ID_CUSTOMER_NEW=>'00027884001');
upd_cu(I_ID_CUSTOMER_OLD=>'00037906001', I_ID_CUSTOMER_NEW=>'00003123001');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000001577', I_ID_CUSTOMER_NEW=>'Q0000001598');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002814', I_ID_CUSTOMER_NEW=>'Q0000002818');
upd_cu(I_ID_CUSTOMER_OLD=>'Q0000002670', I_ID_CUSTOMER_NEW=>'Q0000002684');
upd_cu(I_ID_CUSTOMER_OLD=>'00008551002', I_ID_CUSTOMER_NEW=>'00015600001');
upd_cu(I_ID_CUSTOMER_OLD=>'00008158002', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00008594002', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00011477002', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00013995002', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00014109002', I_ID_CUSTOMER_NEW=>'99900700000');
upd_cu(I_ID_CUSTOMER_OLD=>'00004226002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004601002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004874002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00004875002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00005343002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00007747002', I_ID_CUSTOMER_NEW=>'00015504001');
upd_cu(I_ID_CUSTOMER_OLD=>'00010866001', I_ID_CUSTOMER_NEW=>'00013677001');

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
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_LOP2146-CleanCustomerDuplicates.log
prompt

exit;
