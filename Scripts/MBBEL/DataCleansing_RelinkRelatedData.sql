-- DataCleansing_RelinkRelatedData.sql
-- FraBe     04.06.2013 MKS-125999:1 /LOP2146: creation
-- TK        22.08.2013 MKS-125999:2 Include 5th: Logging

spool DataCleansing_RelinkRelatedData.log

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
exec :L_ERROR_OCCURED    := 0;
variable nachricht      varchar2 ( 100 char );
variable L_SCRIPTNAME   varchar2 ( 100 char );
exec :L_SCRIPTNAME      := 'DataCleansing_RelinkRelatedData.sql';

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
set feedback     on
set feedback     1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- main part for < selecting or checking or correcting code >

declare
     procedure conv_cust
             ( I_ID_CUSTOMER_OLD      varchar2
             , I_ID_CUSTOMER_NEW      varchar2 ) is
               L_GUID_CUSTOMER_OLD    snt.TCUSTOMER.GUID_CUSTOMER%type;
               L_GUID_CUSTOMER_NEW    snt.TCUSTOMER.GUID_CUSTOMER%type;
               old_ID_not_exists      exception;
               new_ID_not_exists      exception;

     begin

           -- 1st: check if old ID_CUSTOMER exists
           begin 
                select   GUID_CUSTOMER 
                  into L_GUID_CUSTOMER_OLD
                  from snt.TCUSTOMER
                 where ID_CUSTOMER = I_ID_CUSTOMER_OLD;
           exception when NO_DATA_FOUND then raise old_ID_not_exists;
           end;

           -- 2nd: check if new ID_CUSTOMER exists
           begin 
                select   GUID_CUSTOMER 
                  into L_GUID_CUSTOMER_NEW
                  from snt.TCUSTOMER
                 where ID_CUSTOMER = I_ID_CUSTOMER_NEW;
           exception when NO_DATA_FOUND then raise new_ID_not_exists;
           end;

           -- 3rd: a) change old ID_CUSTOMER to new one
           update snt.TCUSTOMER               set CUST_INVOICE_ADRESS    = I_ID_CUSTOMER_NEW   where CUST_INVOICE_ADRESS    = I_ID_CUSTOMER_OLD;
           update snt.TCUSTOMER               set CUST_INV_ADRESS_BALFIN = I_ID_CUSTOMER_NEW   where CUST_INV_ADRESS_BALFIN = I_ID_CUSTOMER_OLD;
           update snt.TFZGV_CONTRACTS         set ID_CUSTOMER            = I_ID_CUSTOMER_NEW   where ID_CUSTOMER            = I_ID_CUSTOMER_OLD;
           update snt.TVERTRAGSTAMM           set ID_CUSTOMER            = I_ID_CUSTOMER_NEW   where ID_CUSTOMER            = I_ID_CUSTOMER_OLD;
           update snt.TVERTRAGSTAMM           set ID_CUSTOMER2           = I_ID_CUSTOMER_NEW   where ID_CUSTOMER2           = I_ID_CUSTOMER_OLD;
           update snt.TCUSTOMER_INVOICE       set GUID_PARTNER           = L_GUID_CUSTOMER_NEW where GUID_PARTNER           = L_GUID_CUSTOMER_OLD;
           update snt.TFZGRECHNUNG            set GUID_PARTNER           = L_GUID_CUSTOMER_NEW where GUID_PARTNER           = L_GUID_CUSTOMER_OLD;
           update snt.TSP_COLLECTIVE_INVOICE  set GUID_PARTNER           = L_GUID_CUSTOMER_NEW where GUID_PARTNER           = L_GUID_CUSTOMER_OLD;
           update snt.TSP_CONTRACT            set GUID_PARTNER           = L_GUID_CUSTOMER_NEW where GUID_PARTNER           = L_GUID_CUSTOMER_OLD;           

           -- b) bei folgenden 2 tabellen ist die umstellung komplizierter:
           -- I) löschen kompletten I55 oder SCARF VEHICLE export, wenn ID_CUSTOMER nicht umgeschlüsselt werden kann, weil der neue kunde schon 
           -- rows von diesem export hat (-> ORA-00001: Unique Constraint (SNT.XAK1TTEMP_I55_OR_SCARF_DATA ))
           begin  
                update snt.TTEMP_I55_OR_SCARF_DATA set ID_CUSTOMER            = I_ID_CUSTOMER_NEW   where ID_CUSTOMER            = I_ID_CUSTOMER_OLD;
                exception when DUP_VAL_ON_INDEX 
                          then delete from snt.TTEMP_I55_OR_SCARF_DATA 
                                where GUID_JO in  ( select GUID_JO from snt.TTEMP_I55_OR_SCARF_DATA
                                                     where ID_CUSTOMER = I_ID_CUSTOMER_OLD );
           end;

           -- II) wenn die domiciliation# der alten ID_CUSTOMER schon beim neuen kunden angelegt sind, kommt beim TCUSTOMER_DOM - upd der DUP_VAL_ON_INDEX fehler 
           -- lösung: umhängen der alten TCUSTOMER_DOM - GUID auf die neuen bei den den CO / CINV wo sie noch existieren
           -- dann löschen der alten:
           begin
                update snt.TCUSTOMER_DOM  set ID_CUSTOMER = I_ID_CUSTOMER_NEW   where ID_CUSTOMER = I_ID_CUSTOMER_OLD;
                exception when DUP_VAL_ON_INDEX 
                          then update snt.TCUSTOMER_INVOICE cinv
                                  set GUID_CUSTOMER_DOM =  ( select neu.GUID_CUSTOMER_DOM from snt.TCUSTOMER_DOM neu
                                                              where neu.ID_CUSTOMER        = I_ID_CUSTOMER_NEW
                                                                and neu.CUSTDOM_DOMNUMBER in ( select alt.CUSTDOM_DOMNUMBER
                                                                                                 from snt.TCUSTOMER_DOM alt
                                                                                                where alt.ID_CUSTOMER       = I_ID_CUSTOMER_OLD 
                                                                                                  and alt.GUID_CUSTOMER_DOM = cinv. GUID_CUSTOMER_DOM ))
                                where GUID_CUSTOMER_DOM in ( select alt1.GUID_CUSTOMER_DOM from snt.TCUSTOMER_DOM alt1
                                                              where alt1.ID_CUSTOMER = I_ID_CUSTOMER_OLD );

                               ---
                               update snt.TFZGV_CONTRACTS fzgvc
                                  set GUID_CUSTOMER_DOM =  ( select neu.GUID_CUSTOMER_DOM from snt.TCUSTOMER_DOM neu
                                                              where neu.ID_CUSTOMER        = I_ID_CUSTOMER_NEW
                                                                and neu.CUSTDOM_DOMNUMBER in ( select alt.CUSTDOM_DOMNUMBER
                                                                                                 from snt.TCUSTOMER_DOM alt
                                                                                                where alt.ID_CUSTOMER       = I_ID_CUSTOMER_OLD 
                                                                                                  and alt.GUID_CUSTOMER_DOM = fzgvc. GUID_CUSTOMER_DOM ))
                                where GUID_CUSTOMER_DOM in ( select alt1.GUID_CUSTOMER_DOM from snt.TCUSTOMER_DOM alt1
                                                              where alt1.ID_CUSTOMER = I_ID_CUSTOMER_OLD );
                               ---
                               delete from snt.TCUSTOMER_DOM 
                                where ID_CUSTOMER  = I_ID_CUSTOMER_OLD;
           end;

           -- 4th: delete old obsolete ID_CUSTOMER
           delete from snt.TPARTNER  where ID_CUSTOMER  = I_ID_CUSTOMER_OLD;
           delete from snt.TCUSTOMER where ID_CUSTOMER  = I_ID_CUSTOMER_OLD;

           --5th: log changing
          dbms_output.put_line ('ID_CUSTOMER ' || rpad ( I_ID_CUSTOMER_OLD, 11, ' ' ) || ' migrated successful to ID_CUSTOMER ' 
                               || rpad ( I_ID_CUSTOMER_NEW, 11, ' ' ) || ' !' );

     exception 
           when old_ID_not_exists 
           then :L_ERROR_OCCURED := 1;
                dbms_output.put_line ( 'ID_CUSTOMER ' || rpad ( I_ID_CUSTOMER_OLD, 11, ' ' ) || ' cannot be migrated to ' 
                                                      || rpad ( I_ID_CUSTOMER_NEW, 11, ' ' ) || ' as not existing!' );
           when new_ID_not_exists 
           then :L_ERROR_OCCURED := 1;
                dbms_output.put_line ( 'ID_CUSTOMER ' || rpad ( I_ID_CUSTOMER_OLD, 11, ' ' ) || ' cannot be migrated to ' 
                                                      || rpad ( I_ID_CUSTOMER_NEW, 11, ' ' ) || ' as the new one is not existing!' );
           when others
           then :L_ERROR_OCCURED := 1;
                dbms_output.put_line ( sqlerrm        || ': ID_CUSTOMER ' 
                                                      || rpad ( I_ID_CUSTOMER_OLD, 11, ' ' ) || ' cannot be migrated to ' 
                                                      || rpad ( I_ID_CUSTOMER_NEW, 11, ' ' ) || ' as the new one is already existing!' );
     end;

begin
  -- conv_cust ( ID_CUSTOMER_OLD, ID_CUSTOMER_NEW );
     conv_cust ( '00000838001',   '00036025001' );
     conv_cust ( '00026070001',   '00036025001' );
     conv_cust ( '00001761014',   '00015553001' );
     conv_cust ( '00001761017',   '00015527001' );
     conv_cust ( '00001793001',   '00004251001' );
     conv_cust ( '00002122001',   '00015553001' );
     conv_cust ( '00006594001',   '00012461001' );
     conv_cust ( '00010143001',   '00012461001' );
     conv_cust ( '00001345001',   '00028864001' );
     conv_cust ( '00005566001',   '00009853001' );
     conv_cust ( '00012235001',   '00009853001' );
     conv_cust ( '00014561001',   '00031888001' );
     conv_cust ( '00019373001',   '00031888001' );
     conv_cust ( '00002154001',   '00013639001' );
     conv_cust ( '00005753001',   '00013639001' );
     conv_cust ( '00001329001',   '00019529001' );
     conv_cust ( '00007668001',   '00019529001' );
     conv_cust ( '00002628001',   '00014067001' );
     conv_cust ( '00003473001',   '00014067001' );
     conv_cust ( '00002041001',   '00007910001' );
     conv_cust ( '00007159001',   '00007910001' );
     conv_cust ( '00002931001',   '00013721001' );
     conv_cust ( '00003605001',   '00013721001' );
     conv_cust ( '00002850001',   '00007711001' );
     conv_cust ( '00015888001',   '00019924001' );
     conv_cust ( '00036026001',   '00019924001' );
     conv_cust ( '00011999002',   '00012520002' );
     conv_cust ( '00012475002',   '00012520002' );
     conv_cust ( '00004720001',   '00016439001' );
     conv_cust ( '00012215001',   '00016439001' );
     conv_cust ( '00011619001',   '00011960001' );
     conv_cust ( '00001280001',   '00015549001' );
     conv_cust ( '00003707002',   '00015549001' );
     conv_cust ( '00013627001',   '00018935001' );
     conv_cust ( '00002721001',   '00013701001' );
     conv_cust ( '00011380001',   '00013701001' );
     conv_cust ( '00006866001',   '00001373001' );
     conv_cust ( '00013108001',   '00001373001' );
     conv_cust ( '00010115001',   '00013364001' );
     conv_cust ( '00013519001',   '00013364001' );
     conv_cust ( '00005500001',   '00026761001' );
     conv_cust ( '00017520001',   '00026761001' );
     conv_cust ( '00001978001',   '00017966001' );
     conv_cust ( '00003826001',   '00017966001' );
     conv_cust ( '00000933002',   '00003652001' );
     conv_cust ( '00000934002',   '00003652001' );
     conv_cust ( '00017361001',   '00029976001' );
     conv_cust ( '00028004001',   '00029976001' );
     conv_cust ( '00007615001',   '00011194001' );
     conv_cust ( '00009672001',   '00011194001' );
     conv_cust ( '00006094001',   '00016647001' );
     conv_cust ( '00016067001',   '00016647001' );
     conv_cust ( '00009363001',   '00019308001' );
     conv_cust ( '00016364001',   '00019308001' );
     conv_cust ( '00008750001',   '00013566001' );
     conv_cust ( '00008923001',   '00013566001' );
     conv_cust ( '00008562001',   '00011893001' );
     conv_cust ( '00011430001',   '00011893001' );
     conv_cust ( '00028181001',   '00029713001' );
     conv_cust ( '00002665001',   '00023601001' );
     conv_cust ( '00017235001',   '00023601001' );
     conv_cust ( '00004201001',   '00007824001' );
     conv_cust ( '00009816001',   '00007824001' );
     conv_cust ( '00013944001',   '00018234001' );
     conv_cust ( '00017228001',   '00018234001' );
     conv_cust ( '00001769001',   '00005366001' );
     conv_cust ( '00007557001',   '00004021001' );
     conv_cust ( '00000855001',   '00001079001' );
     conv_cust ( '00007980001',   '00010731001' );
     conv_cust ( '00014197001',   '00023955001' );
     conv_cust ( '00004347001',   '00035673001' );
     conv_cust ( '00000373002',   '00000373001' );
     conv_cust ( '00000849001',   '00011158001' );
     conv_cust ( '00005675001',   '00006935001' );
     conv_cust ( '00001133001',   '00036030001' );
     conv_cust ( '00002891001',   '99900800000' );
     conv_cust ( '00010957001',   '00002179001' );
     conv_cust ( '00007798001',   '00002912001' );
     conv_cust ( '00011410001',   '00000345001' );
     conv_cust ( '00001104001',   '00004687001' );
     conv_cust ( '00001749001',   '00003644001' );
     conv_cust ( '00001900001',   '00004654001' );
     conv_cust ( '00006973001',   '00019917001' );
     conv_cust ( '00004792001',   '00011078001' );
     conv_cust ( '00012460001',   '00007520001' );
     conv_cust ( '00003036001',   '00003494001' );
     conv_cust ( '00002587001',   '00003654001' );
     conv_cust ( '00009821001',   '00018227001' );
     conv_cust ( '00010258001',   '00003470001' );
     conv_cust ( '00001513001',   '00005884001' );
     conv_cust ( '00005957001',   '00010523001' );
     conv_cust ( '00006064001',   '00034905001' );
     conv_cust ( '00029820001',   '00034938001' );
     conv_cust ( '00024558001',   '00025731001' );
     conv_cust ( '00007141001',   '00006640001' );
     conv_cust ( '00011414001',   '00011423001' );
     conv_cust ( '00003487001',   '00004147001' );
     conv_cust ( '00005179001',   '00025563001' );
     conv_cust ( '00000939001',   '00000939002' );
     conv_cust ( '00001960001',   '00011797001' );
     conv_cust ( '00002195001',   '00007008001' );
     conv_cust ( '00000906001',   '00012220001' );
     conv_cust ( '00007314001',   '00030997001' );
     conv_cust ( '00005000001',   '00013413001' );
     conv_cust ( '00002525001',   '00022452001' );
     conv_cust ( '00002795001',   '00033422001' );
     conv_cust ( '00030046001',   '00029672001' );
     conv_cust ( '00004192001',   '00013052001' );
     conv_cust ( '00005955001',   '00034226001' );
     conv_cust ( '00002428001',   '00001928001' );
     conv_cust ( '00002344001',   '00010365001' );
     conv_cust ( '00006736001',   '00006099001' );
     conv_cust ( '00013981001',   '00011193001' );
     conv_cust ( '00001706001',   '00003768001' );
     conv_cust ( '00001305003',   '00002761001' );
     conv_cust ( '00012659001',   '00018599001' );
     conv_cust ( '00002292001',   '00001754001' );
     conv_cust ( '00019186001',   '00002357001' );
     conv_cust ( '00004267001',   '00010003001' );
     conv_cust ( '00008277001',   '00005104001' );
     conv_cust ( '00000488001',   '00005655001' );
     conv_cust ( '00007416002',   '00007416001' );
     conv_cust ( '00003886001',   '00019956001' );
     conv_cust ( '00003807001',   '00003830001' );
     conv_cust ( '00006255001',   '00013573001' );
     conv_cust ( '00001838001',   '00002427001' );
     conv_cust ( '00010841001',   '00003964001' );
     conv_cust ( '00001511001',   '00002690001' );
     conv_cust ( '00001935001',   '00010046001' );
     conv_cust ( '00002228001',   'Q0000001601' );
     conv_cust ( '00009520001',   '00002722001' );
     conv_cust ( '00004928001',   '00019256001' );
     conv_cust ( '00014930001',   '00028974001' );
     conv_cust ( '00009135001',   '00019968001' );
     conv_cust ( '00006145001',   '00018612001' );
     conv_cust ( 'Q0000000565',   '00033828001' );
     conv_cust ( '00020504001',   '00031841001' );
     conv_cust ( '00010362001',   '00002528001' );
     conv_cust ( '00009040001',   '00010378001' );
     conv_cust ( '00010278001',   '00006621001' );
     conv_cust ( '00004297001',   '00004389001' );
     conv_cust ( '00014209001',   '00007705001' );
     conv_cust ( '00003216001',   '00009251001' );
     conv_cust ( '00005233001',   '00026081001' );
     conv_cust ( '00005785001',   '00015036001' );
     conv_cust ( '00008669001',   '00036048001' );
     conv_cust ( '00003024001',   '00003745001' );
     conv_cust ( '00025959001',   '00014821001' );
     conv_cust ( '00002479001',   '00004258001' );
     conv_cust ( '00006813001',   '00009726001' );
     conv_cust ( '00001592001',   '00003828001' );
     conv_cust ( '00012050001',   '00009764001' );
     conv_cust ( '00025402001',   '00035400001' );
     conv_cust ( '00022635001',   '00008622001' );
     conv_cust ( '00037309001',   '00007436001' );
     conv_cust ( '00019440001',   '00024905001' );
     conv_cust ( '00009289001',   '00016957001' );
     conv_cust ( '00011615001',   '00004484001' );
     conv_cust ( '00013686001',   '00009826001' );
     conv_cust ( '00007088001',   '00017575001' );
     conv_cust ( '00017579001',   '00016333001' );
     conv_cust ( '00006626001',   '00002151001' );
     conv_cust ( '00006698001',   '00001756001' );
     conv_cust ( '00017981001',   '00019925001' );
     conv_cust ( '00006555001',   '00010009001' );
     conv_cust ( '00004557001',   '00017777001' );
     conv_cust ( '00003818001',   '00003094001' );
     conv_cust ( '00037962001',   '00005294001' );
     conv_cust ( '00005909001',   '00007418001' );
     conv_cust ( '00003157001',   '99900800000' );
     conv_cust ( '00004436001',   '00011305001' );
     conv_cust ( '00010057001',   '00011492001' );
     conv_cust ( '00001642001',   '00020051001' );
     conv_cust ( '00006071001',   '00012326001' );
     conv_cust ( '00006406001',   '00018337001' );
     conv_cust ( '00006076001',   '00013457001' );
     conv_cust ( '00009956001',   '00007699001' );
     conv_cust ( '00014521001',   '00031903001' );
     conv_cust ( '00016764001',   '00026763001' );
     conv_cust ( '00002425001',   '00001325001' );
     conv_cust ( '00007867001',   '00031941001' );
     conv_cust ( '00035637001',   '00017395001' );
     conv_cust ( '00026750001',   '00023331001' );
     conv_cust ( '00028543001',   '00021057001' );
     conv_cust ( '00001854001',   '00003656001' );
     conv_cust ( '00005446001',   '00024977001' );
     conv_cust ( '00004694001',   '00015897001' );
     conv_cust ( '00005816001',   '00010223001' );
     conv_cust ( '00029826001',   '00035937001' );
     conv_cust ( '00016649001',   '00009667001' );
     conv_cust ( '00003792001',   '00002114001' );
     conv_cust ( '00001652001',   '00001048001' );
     conv_cust ( '00026855001',   '00028449001' );
     conv_cust ( '00013189001',   '00018823001' );
     conv_cust ( '00010921001',   '00007971001' );
     conv_cust ( '00010113001',   '00002021001' );
     conv_cust ( '00004303001',   '00037604001' );
     conv_cust ( '00016196001',   '00014795001' );
     conv_cust ( '00018578001',   '00003947001' );
     conv_cust ( '00029056001',   '00000444001' );
     conv_cust ( '00027712001',   '00025844001' );
     conv_cust ( '00002667001',   '00003160001' );
     conv_cust ( '00001925001',   '00013176001' );
     conv_cust ( '00006620002',   '00006620001' );
     conv_cust ( '00004883001',   '00030418001' );
     conv_cust ( '00016194001',   '00008395001' );
     conv_cust ( '00002166001',   '00018462001' );
     conv_cust ( '00003034001',   '00006160001' );
     conv_cust ( '00003449001',   '00011915001' );
     conv_cust ( '00004636001',   '00002661001' );
     conv_cust ( '00008171001',   '00021508001' );
     conv_cust ( '00005859001',   '00000542001' );
     conv_cust ( '00028151001',   '00033616001' );
     conv_cust ( '00005910001',   '00008307001' );
     conv_cust ( '00003473002',   '00001887001' );
     conv_cust ( '00010389001',   '00002496001' );
     conv_cust ( '00014154001',   '00019313001' );
     conv_cust ( '00002054001',   '00010973001' );
     conv_cust ( '00010107001',   '00031900001' );
     conv_cust ( '00018522001',   '00014352001' );
     conv_cust ( '00002072001',   '00021493001' );
     conv_cust ( '00024124001',   'Q0000000544' );
     conv_cust ( '00005728001',   '00017840001' );
     conv_cust ( '00024417001',   '00036634001' );
     conv_cust ( '00007111001',   '00019376001' );
     conv_cust ( '00002130001',   '00012870001' );
     conv_cust ( '00010337001',   '00019113001' );
     conv_cust ( '00016214001',   '00034265001' );
     conv_cust ( '00014378001',   '00009356001' );
     conv_cust ( '00001381001',   '00026029001' );
     conv_cust ( '00006783001',   '00025896001' );
     conv_cust ( '00001805001',   '00000803001' );
     conv_cust ( '00017726001',   '00021129001' );
     conv_cust ( '00012320001',   '00005579001' );
     conv_cust ( '00000805001',   '00007837001' );
     conv_cust ( '00013940001',   '00020602001' );
     conv_cust ( '00004061001',   '00005105001' );
     conv_cust ( '00018799001',   '00037829001' );
     conv_cust ( '00003567002',   '00015537001' );
     conv_cust ( '00010220001',   '00027711001' );
     conv_cust ( '00004632001',   '00005760001' );
     conv_cust ( '00013240001',   '00005371001' );
     conv_cust ( '00015978001',   '00014403001' );
     conv_cust ( '00013103001',   '00002896001' );
     conv_cust ( '00011807001',   '00008568001' );
     conv_cust ( '00036888001',   '00012545001' );
     conv_cust ( '00001917001',   '00004268001' );
     conv_cust ( '00001672001',   '00011001001' );
     conv_cust ( '00010694001',   '00002920001' );
     conv_cust ( '00002884001',   '00003038001' );
     conv_cust ( '00011428001',   '00006895001' );
     conv_cust ( '00001323001',   '00004782001' );
     conv_cust ( '00008437001',   '00012260001' );
     conv_cust ( '00001816001',   '00010037001' );
     conv_cust ( '00002649001',   '00007629001' );
     conv_cust ( '00004685001',   '00014146001' );
     conv_cust ( '00009509001',   '00022266001' );
     conv_cust ( '00002449001',   '00012240001' );
     conv_cust ( '00013422001',   '00000780001' );
     conv_cust ( '00022779001',   '00029774001' );
     conv_cust ( '00014814001',   '00030226001' );
     conv_cust ( '00018873001',   '00024170001' );
     conv_cust ( '00008777001',   '00014783001' );
     conv_cust ( '00005433001',   '00010086001' );
     conv_cust ( '00005638001',   '00007720001' );
     conv_cust ( '00018187001',   '00021437001' );
     conv_cust ( '00001949001',   '00013056001' );
     conv_cust ( '00017248001',   '00025845001' );
     conv_cust ( '00012549001',   '00011792001' );
     conv_cust ( '00022867001',   '00027270001' );
     conv_cust ( '00006211001',   '00003443001' );
     conv_cust ( '00019682001',   '00029720001' );
     conv_cust ( '00008941001',   '00011913001' );
     conv_cust ( '00021579001',   '00028070001' );
     conv_cust ( '00008720001',   '00013555001' );
     conv_cust ( '00004810001',   '00002980001' );
     conv_cust ( '00028018001',   '00026588001' );
     conv_cust ( '00004601001',   '00019602001' );
     conv_cust ( '00001666002',   '00001666001' );
     conv_cust ( '00002643001',   '00014570001' );
     conv_cust ( '00002677001',   '00012272001' );
     conv_cust ( '00003246001',   '00019815001' );
     conv_cust ( '00004785001',   '00019831001' );
     conv_cust ( '00017609001',   '00031767001' );
     conv_cust ( '00033249001',   '00001336001' );
     conv_cust ( '00017595001',   '00009253001' );
     conv_cust ( '00006223001',   '00007560001' );
     conv_cust ( '00027884001',   'Q0000001408' );
     conv_cust ( '00034644001',   '00018596001' );
     conv_cust ( '00014731001',   'Q0000000169' );
     conv_cust ( '00016661001',   '00019913001' );
     conv_cust ( '00018962001',   '00014010001' );
     conv_cust ( '00004330001',   '00000889001' );
     conv_cust ( '00004903001',   '00018805001' );
     conv_cust ( '00010411001',   '00003537001' );
     conv_cust ( '00019032001',   '00031308001' );
     conv_cust ( '00004430001',   '00003113001' );
     conv_cust ( '00028556001',   '00014915001' );
     conv_cust ( '00012829001',   '00001747001' );
     conv_cust ( '00009813001',   '00006631001' );
     conv_cust ( '00019649001',   '00028863001' );
     conv_cust ( '00015043001',   '00015992001' );
     conv_cust ( '00018608001',   '00015996001' );
     conv_cust ( '00010866001',   '00013677001' );
     conv_cust ( '00011363001',   '00017499001' );
     conv_cust ( '00018539001',   '00002622001' );
     conv_cust ( '00007769001',   '00008560001' );
     conv_cust ( '00027989001',   '00009415001' );
     conv_cust ( '00005299001',   '00010165001' );
     conv_cust ( '00018051001',   '00017541001' );
     conv_cust ( '00024901001',   '00035935001' );
     conv_cust ( '00018255001',   '00003872001' );
     conv_cust ( '00020768001',   '00016675001' );
     conv_cust ( '00003256001',   '00015963001' );
     conv_cust ( '00004529001',   '00007628001' );
     conv_cust ( '00033532001',   '00031671001' );
     conv_cust ( '00002105001',   '00010717001' );
     conv_cust ( '00004524001',   '00001432001' );
     conv_cust ( '00016256001',   '00035081001' );
     conv_cust ( '00005946001',   '00018418001' );
     conv_cust ( '00003725001',   '00009664001' );
     conv_cust ( '00003701001',   '00025828001' );
     conv_cust ( '00027108001',   '00022685001' );
     conv_cust ( '00002565001',   '00026030001' );
     conv_cust ( '00018656001',   '00028832001' );
     conv_cust ( '00004125001',   '00016193001' );
     conv_cust ( '00034021001',   '00035723001' );
     conv_cust ( '00014270001',   '00004955001' );
     conv_cust ( '00007633001',   '00013040001' );
     conv_cust ( '00005063001',   '00008642001' );
     conv_cust ( '00007020001',   '00023993001' );
     conv_cust ( '00009311001',   '00028881001' );
     conv_cust ( '00018377001',   '00008893001' );
     conv_cust ( '00005829001',   '00021467001' );
     conv_cust ( '00037177001',   '00018724001' );
     conv_cust ( '00005563001',   '00011155001' );
     conv_cust ( '00007515001',   '00001087002' );
     conv_cust ( '00022909001',   '00003073001' );
     conv_cust ( '00028670001',   '00029732001' );
     conv_cust ( '00011474001',   '00012020001' );
     conv_cust ( '00006576001',   '00010273001' );
     conv_cust ( '00001664001',   '00008237001' );
     conv_cust ( '00006979001',   '00007209001' );
     conv_cust ( '00013939001',   '00018548001' );
     conv_cust ( '00004379001',   '00017903001' );
     conv_cust ( '00005111001',   '00006256001' );
     conv_cust ( '00005471001',   '00002861001' );
     conv_cust ( '00006509001',   '00005947001' );
     conv_cust ( '00022295001',   '00037141001' );
     conv_cust ( '00004843001',   '00005874001' );
     conv_cust ( '00009388001',   '00017327001' );
     conv_cust ( '00004754001',   '00005237001' );
     conv_cust ( '00003549001',   '00004425001' );
     conv_cust ( '00009176001',   '00021711001' );
     conv_cust ( '00005379001',   '00007555001' );
     conv_cust ( '00029182001',   '00002663001' );
     conv_cust ( '00006734001',   '00035014001' );
     conv_cust ( '00010366001',   '00006692001' );
     conv_cust ( '00013790001',   '00005297001' );
     conv_cust ( '00002330001',   '00002330002' );
     conv_cust ( '00013979001',   '00014310001' );
     conv_cust ( '00010406001',   '00019101001' );
     conv_cust ( '00009355001',   '00008103001' );
     conv_cust ( '00006034001',   '00007306001' );
     conv_cust ( '00003145001',   '00015749001' );
     conv_cust ( '00003823001',   '00002918001' );
     conv_cust ( '00001320002',   '00007132001' );
     conv_cust ( '00008142001',   '00016783001' );
     conv_cust ( '00008300001',   '00019449001' );
     conv_cust ( '00018153001',   '00004515001' );
     conv_cust ( '00003801001',   '00016736001' );
     conv_cust ( '00003771001',   '00004422001' );
     conv_cust ( '00009461001',   '00009361001' );
     conv_cust ( '00013312001',   '00013570001' );
     conv_cust ( '00006318001',   '00018627001' );
     conv_cust ( '00031436001',   '00036376001' );
     conv_cust ( '00016213001',   '00012896001' );
     conv_cust ( '00009089001',   '00010735001' );
     conv_cust ( '00004553001',   '00004553002' );
     conv_cust ( '00010432001',   '00012917001' );
     conv_cust ( '00005574001',   '00007568001' );
     conv_cust ( '00005358001',   '00034992001' );
     conv_cust ( '00007271001',   '00006351001' );
     conv_cust ( '00021076001',   '00035869001' );
     conv_cust ( '00013764001',   '00025724001' );
     conv_cust ( '00010263001',   '00007367001' );
     conv_cust ( '00007684001',   '00010295001' );
     conv_cust ( '00010150001',   '00013949001' );
     conv_cust ( 'Q0000001148',   '00038003001' );
     conv_cust ( '00006156001',   '00011190001' );
     conv_cust ( '00028955001',   '00032206001' );
     conv_cust ( '00009450001',   '00016060001' );
     conv_cust ( '00010069001',   '00012698001' );
     conv_cust ( '00012541001',   '00009733001' );
     conv_cust ( '00010825001',   '00025504001' );
     conv_cust ( '00031636001',   '00025816001' );
     conv_cust ( '00011034001',   '00021745001' );
     conv_cust ( '00025886001',   '00016031001' );
     conv_cust ( '00019155001',   '00018390001' );
     conv_cust ( '00020671001',   '00036554001' );
     conv_cust ( '00025999001',   '00018243001' );
     conv_cust ( '00036027001',   '00024174001' );
     conv_cust ( '00026772001',   '00027103001' );
     conv_cust ( '00027500001',   '00030470001' );
     conv_cust ( '00025890001',   '00033528001' );
     conv_cust ( '00019572001',   '00011805001' );
     conv_cust ( '00018533001',   '00030742001' );
     conv_cust ( '00020926001',   'Q0000000625' );
     conv_cust ( '00017651001',   '00014530001' );
     conv_cust ( '00017545001',   '00015056001' );
     conv_cust ( '00002426001',   '00006096001' );
     conv_cust ( '00006143001',   '00016513001' );
     conv_cust ( '00003885001',   '00015397001' );
     conv_cust ( '00008423001',   '00011265001' );
     conv_cust ( '00000738002',   '00000738001' );
     conv_cust ( '00002710001',   '00004670001' );
     conv_cust ( '00004502001',   '00004911001' );
     conv_cust ( '00014257001',   '00014622001' );
     conv_cust ( '00006484001',   '00021759001' );
     conv_cust ( '00007317001',   '00011762001' );
     conv_cust ( '00002429001',   '00002491001' );
     conv_cust ( '00001599001',   '00004331001' );
     conv_cust ( '00012321001',   '00003906001' );
     conv_cust ( '00001440001',   '00012558001' );
     conv_cust ( '00033315001',   '00037966001' );
     conv_cust ( '00006661001',   '00021540001' );
     conv_cust ( '00033610001',   '00023367001' );
     conv_cust ( '00009711001',   '00028234001' );
     conv_cust ( '00006504001',   '00005092001' );
     conv_cust ( '00004635001',   '00012680001' );
     conv_cust ( '00013734001',   '00004470001' );
     conv_cust ( '00004901001',   '00004227001' );
     conv_cust ( 'Q0000000402',   '00037182001' );
     conv_cust ( '00012001001',   '00020228001' );
     conv_cust ( '00028954001',   '00026408001' );
     conv_cust ( '00001941001',   '00001408001' );
     conv_cust ( '00015718001',   '00007567001' );
     conv_cust ( '00001874001',   '00003261001' );
     conv_cust ( '00005896001',   '00004624001' );
     conv_cust ( '00016738001',   '00004690001' );
     conv_cust ( '00027572001',   '00016327001' );
     conv_cust ( '00021060001',   '00028315001' );
     conv_cust ( '00017900001',   '00005900001' );
     conv_cust ( '00022862001',   '00012218001' );
     conv_cust ( '00007273001',   '00001391001' );
     conv_cust ( '00009963001',   '00018576001' );
     conv_cust ( '00005315001',   '00018582001' );
     conv_cust ( '00034926001',   '00029793001' );
     conv_cust ( 'Q0000001564',   '00036879001' );
     conv_cust ( '00017165001',   'Q0000000683' );
     conv_cust ( '00016419001',   '00016440001' );
     conv_cust ( '00016208001',   '00035887001' );
     conv_cust ( '00028483001',   '00019878001' );
     conv_cust ( '00027043001',   '00026930001' );
     conv_cust ( '00016424001',   '00011912001' );
     conv_cust ( '00017446001',   '00037340001' );
     conv_cust ( 'Q0000000580',   '00027869001' );
     conv_cust ( '00024428001',   '00035840001' );
     conv_cust ( '00035286001',   '00022868001' );
     conv_cust ( '00023872001',   '00034744001' );
     conv_cust ( '00020802001',   '00023954001' );
     conv_cust ( '00019136001',   '00022761001' );
     conv_cust ( '00023517001',   '00034915001' );
     conv_cust ( '00022428001',   '00034727001' );
     conv_cust ( '00023236001',   '00036492001' );
     conv_cust ( '00027085001',   '00020784001' );
     conv_cust ( '00034606001',   '00034799001' );
     conv_cust ( '00035576001',   '00036028001' );
     conv_cust ( '00022910001',   '00027799001' );
     conv_cust ( 'C0000000858',   '00037608001' );
     conv_cust ( '00034921001',   '00023863001' );
     conv_cust ( '00034471001',   'Q0000000687' );
     conv_cust ( '00027991001',   '00029647001' );
     conv_cust ( '00035177001',   '00024658001' );
     conv_cust ( '00029014001',   '00035143001' );
     conv_cust ( '00035822001',   '00036795001' );
     conv_cust ( '00035636001',   '00030128001' );
     conv_cust ( '00026845001',   '00028432001' );
     conv_cust ( '00026871001',   '00036439001' );
     conv_cust ( '00021008001',   '00010848001' );
     conv_cust ( '00028427001',   '00019709001' );
     conv_cust ( '00001426001',   '00009954001' );
     conv_cust ( '00011961001',   '00021370001' );
     conv_cust ( '00010040001',   '00003164001' );
     conv_cust ( '00027890001',   '00037838001' );
     conv_cust ( '00007098001',   '00011960001' );
     conv_cust ( '00001888002',   '00001888001' );
     conv_cust ( '00027148001',   '00037509001' );
     conv_cust ( '00001335001',   '00022954001' );
     conv_cust ( '00004796001',   '00036025001' );
     conv_cust ( '00020152001',   '00001533001' );
     conv_cust ( '00018876001',   '00021396001' );
     conv_cust ( '00032440001',   'Q0000000670' );
     conv_cust ( '00001958001',   '00000940001' );
     conv_cust ( '00001958002',   '00000940002' );
     conv_cust ( '00004960011',   '00000940002' );
     conv_cust ( '00001958003',   '00000940003' );
     conv_cust ( '00001958005',   '00000940005' );
     conv_cust ( '00001958006',   '00000940006' );
     conv_cust ( '00001958007',   '00000940007' );
     conv_cust ( '00004960008',   '00000940007' );
     conv_cust ( '00001958008',   '00000940008' );
     conv_cust ( '00001958009',   '00000940009' );
     conv_cust ( '00001958010',   '00000940010' );
     conv_cust ( '00001958014',   '00000940014' );
     conv_cust ( '00001958017',   '00000940017' );
     conv_cust ( '00001958018',   '00000940018' );
     conv_cust ( '00004960009',   '00000940018' );
     conv_cust ( '00001958019',   '00000940019' );
     conv_cust ( '00001958020',   '00000940020' );
     conv_cust ( '00001958024',   '00000940024' );
     conv_cust ( '00001958025',   '00000940025' );
     conv_cust ( '00001958026',   '00000940026' );
     conv_cust ( '00001958027',   '00000940027' );
     conv_cust ( '00001958028',   '00000940028' );
     conv_cust ( '0011661 001',   '00011661001' );
     conv_cust ( '00002126001',   '00018650001' );
     conv_cust ( '00011023001',   '00002534001' );
     conv_cust ( '00002822001',   '00014183001' );
     conv_cust ( '00003045001',   '00023179001' );
     conv_cust ( '00011063001',   '00003118001' );
     conv_cust ( '00003526001',   '00016357001' );
     conv_cust ( '00003809001',   '00014976001' );
     conv_cust ( '00004235001',   '00021992001' );
     conv_cust ( '00004433001',   '00006961001' );
     conv_cust ( '00004510001',   '00005160001' );
     conv_cust ( '00004655001',   '00018198001' );
     conv_cust ( '00018399001',   '00004700001' );
     conv_cust ( '00005715001',   '00005925001' );
     conv_cust ( '00019737001',   '00005913001' );
     conv_cust ( '00005988001',   '00012937001' );
     conv_cust ( '00017423001',   '00006909001' );
     conv_cust ( '00002709001',   '00007034001' );
     conv_cust ( '00007498001',   '00036628001' );
     conv_cust ( '00003715001',   '00005901001' );
     conv_cust ( '00018229001',   '00008080001' );
     conv_cust ( '00011242001',   '00002756001' );
     conv_cust ( '00008823001',   '00020627001' );
     conv_cust ( '00009116001',   '00013543001' );
     conv_cust ( '00010119001',   '00009690001' );
     conv_cust ( '00011084001',   '00018849001' );
     conv_cust ( '00018850001',   '00011085001' );
     conv_cust ( '00010989001',   '00024549001' );
     conv_cust ( '00015239001',   '00017303001' );
     conv_cust ( '00028665001',   '00015371001' );
     conv_cust ( '00032841001',   '00016307001' );
     conv_cust ( '00016699001',   '00030064001' );
     conv_cust ( '00017669001',   '00024121001' );
     conv_cust ( '00019040001',   '00019240001' );
     conv_cust ( '00008849001',   '00019114001' );
     conv_cust ( '00016551001',   '00025128001' );
     conv_cust ( '00021026001',   '00035666001' );
     conv_cust ( 'Q0000000190',   '00023411001' );
     conv_cust ( '00036573001',   '00025191001' );
     conv_cust ( 'Q0000001357',   '00025267001' );
     conv_cust ( '00026089001',   '00026917001' );
     conv_cust ( '00026613001',   '00027323001' );
     conv_cust ( '00027204001',   '00029363001' );
     conv_cust ( '00033338001',   '00036290001' );
     conv_cust ( 'Q0000000038',   'Q0000000054' );
     conv_cust ( 'Q0000001500',   'Q0000001561' );
     conv_cust ( 'Q0000001577',   'Q0000001598' );
     conv_cust ( '00011361001',   '00011249001' );
     conv_cust ( '00009372001',   '00011249001' );
     conv_cust ( '00007547001',   '00011191001' );
     conv_cust ( '00003239301',   '00032393001' );
     conv_cust ( '00003510301',   '00035103001' );
     conv_cust ( '00021571001',   '00009263001' );
     conv_cust ( '00022048001',   '00014868001' );
     conv_cust ( '00024383001',   '00032977001' );
     conv_cust ( '00025078001',   '00009996001' );
     conv_cust ( '00023779001',   '00031909001' );
     conv_cust ( '00002513001',   '00022776001' );
     conv_cust ( '00014803002',   '00026428001' );
     conv_cust ( '00010959001',   '00022238001' );
     conv_cust ( '00003490001',   '00002095001' );
     conv_cust ( '00025878001',   '00011870001' );
     conv_cust ( '00020871001',   'Q0000001378' );
     conv_cust ( '00001019001',   '00000908001' );
     conv_cust ( '91220053001',   '00000908001' );
     conv_cust ( '00016739001',   '00033522001' );
     conv_cust ( '00019169001',   '00010296001' );
     conv_cust ( '00010713001',   '00001659001' );
     conv_cust ( '00006572001',   '00010369001' );
     conv_cust ( '00001232001',   '00010369001' );
     conv_cust ( '00002975001',   '00010369001' );
     conv_cust ( '00015608001',   '00017483001' );
     conv_cust ( '00015141001',   '00026098001' );
     conv_cust ( '00001927001',   '00000422001' );
     conv_cust ( '00009916001',   '00002442001' );
     conv_cust ( '00016231001',   '00026841001' );
     conv_cust ( '00020476001',   '00029861001' );
     conv_cust ( '00017522001',   '00035144001' );
     conv_cust ( '00021478001',   '00036677001' );
     conv_cust ( '00018082001',   '00034462001' );
     conv_cust ( '00022612001',   'Q0000000416' );
     conv_cust ( '00023390001',   '00037945001' );
     conv_cust ( '00023704001',   '00035876001' );
     conv_cust ( '00022695001',   'Q0000001097' );
     conv_cust ( '00009934001',   '00018306001' );
     conv_cust ( '00006109001',   '00015471001' );
     conv_cust ( '00007214001',   '00025806001' );
     conv_cust ( '00006391001',   '00027798001' );
     conv_cust ( '00018889001',   'Q0000001765' );
     conv_cust ( '00010994001',   '00029855001' );
     conv_cust ( '00012102001',   '00022760001' );
     conv_cust ( '00011235001',   '00026577001' );
     conv_cust ( '00003440001',   '00016339001' );
     conv_cust ( '00016833001',   '00033444001' );
     conv_cust ( '00014315001',   '00026447001' );
     conv_cust ( '00016767001',   '00026737001' );
     conv_cust ( '00023571001',   'Q0000000459' );
     conv_cust ( '00008935001',   'Q0000000562' );
     conv_cust ( '00009420001',   'Q0000000473' );
     conv_cust ( '00034784001',   '00033781001' );
     conv_cust ( '00022650001',   '00023490001' );
     conv_cust ( '00017108001',   '00026747001' );
     conv_cust ( '00020350001',   '00028132001' );
     conv_cust ( '00004626001',   '00010730001' );
     conv_cust ( '00005597001',   '00000438001' );
     conv_cust ( '00010509001',   '00001396001' );
     conv_cust ( '00018844001',   '00009147001' );
     conv_cust ( '00018263001',   '00029980001' );
     conv_cust ( '00028621001',   '00019159001' );
     conv_cust ( '00019338001',   '00024303001' );
     conv_cust ( '00021492001',   '00037217001' );
     conv_cust ( '00025132001',   '00034943001' );
     conv_cust ( 'Q0000000177',   '00032425001' );
     conv_cust ( '00034858001',   '00033719001' );
     conv_cust ( '00030230001',   '00034617001' );
     conv_cust ( '00031790001',   '00024505001' );
     conv_cust ( '00003460001',   '00010149001' );
     conv_cust ( '00016952001',   '00028825001' );
     conv_cust ( '00014878001',   '00033193001' );
     conv_cust ( '00000014470',   '00014478001' );
     conv_cust ( '00020230001',   '00026353001' );
     conv_cust ( '00019551001',   '00028615001' );
     conv_cust ( '00016495001',   '00032169001' );
     conv_cust ( '00025756001',   '00033336001' );
     conv_cust ( '00024816001',   '00028789001' );
     conv_cust ( '00015701001',   '00023318001' );
     conv_cust ( '00020123001',   '00031890001' );
     conv_cust ( '00026740001',   'Q0000000270' );
     conv_cust ( '00015725001',   '00023486001' );
     conv_cust ( '00032650001',   '00034919001' );
     conv_cust ( '00024654001',   '00034919001' );
     conv_cust ( '00013777001',   '00027372001' );
     conv_cust ( '00025414001',   '00023767001' );
     conv_cust ( '00009162001',   '00021523001' );
     conv_cust ( '00016423001',   '00027810001' );
     conv_cust ( '00026412001',   '00029055001' );
     conv_cust ( '00002074001',   '00013076001' );
     conv_cust ( '00011911001',   '00028987001' );
     conv_cust ( '00009752001',   '00010453001' );
     conv_cust ( '00023897001',   '00034873001' );
     conv_cust ( '00017026001',   '00030636001' );
     conv_cust ( '00019972001',   '00035956001' );
     conv_cust ( '00027151001',   '00030614001' );
     conv_cust ( '00020234001',   '00022174001' );
     conv_cust ( '00016909001',   '00027742001' );
     conv_cust ( '00017693001',   '00036459001' );
     conv_cust ( '00022971001',   '00035370001' );
     conv_cust ( '00019053001',   'Q0000000462' );
     conv_cust ( '00008089001',   '00030772001' );
     conv_cust ( '00036083001',   '00037111001' );
     conv_cust ( '00021044001',   'Q0000000534' );
     conv_cust ( '00004205001',   '00034047001' );
     conv_cust ( '00003934001',   '00004993001' );
     conv_cust ( '00001276001',   '00026542001' );
     conv_cust ( '00007903001',   '00024507001' );
     conv_cust ( '50000000448',   '00037353001' );
     conv_cust ( '00019260001',   '00026662001' );
     conv_cust ( '00016168001',   '00027562001' );
     conv_cust ( '00004212001',   '00027602001' );
     conv_cust ( '00016557001',   'Q0000001409' );
     conv_cust ( '00028812001',   '00029187001' );
     conv_cust ( '00023935001',   'Q0000001390' );
     conv_cust ( '00019798001',   '00030339001' );
     conv_cust ( '00020641001',   '00025193001' );
     conv_cust ( '00034390001',   'Q0000001274' );
     conv_cust ( '00020105001',   '00031545001' );
     conv_cust ( '00020282001',   '00037011001' );
     conv_cust ( '00007082001',   '00037011001' );
     conv_cust ( '00035032001',   '00037011001' );
     conv_cust ( '00019553001',   'Q0000000185' );
     conv_cust ( '00001465001',   '00027048001' );
     conv_cust ( '00028461001',   '00034931001' );
     conv_cust ( '00016144001',   '00028341001' );
     conv_cust ( '00018518001',   '00032200001' );
     conv_cust ( '00020397001',   '00022819001' );
     conv_cust ( '00017192001',   '00024596001' );
     conv_cust ( '00025664001',   '00029071001' );
     conv_cust ( '00005738001',   '00029879001' );
     conv_cust ( '00012323001',   '00028161001' );
     conv_cust ( '00026868001',   'Q0000001741' );
     conv_cust ( '00005600001',   '00028149001' );
     conv_cust ( '00017293001',   '00034856001' );
     conv_cust ( '00016919001',   'Q0000002183' );
     conv_cust ( '00001505001',   'Q0000001098' );
     conv_cust ( '00010313001',   'Q0000001175' );
     conv_cust ( '00008096001',   'Q0000001175' );
     conv_cust ( '00037284001',   '00035888001' );
     conv_cust ( '00018330001',   '00033522001' );
     conv_cust ( '00014935001',   '00031333001' );
     conv_cust ( '00005767001',   '00025820001' );
     conv_cust ( '00034927001',   '00015097001' );
     conv_cust ( '00005478001',   '00035846001' );
     conv_cust ( 'Q0000000319',   '00037170001' );
     conv_cust ( '00013902001',   '00030076001' );
     conv_cust ( '00013905001',   '00035051001' );
     conv_cust ( '00005845001',   '00028488001' );
     conv_cust ( '00009481001',   '00036268001' );
     conv_cust ( '00004483002',   '00015520001' );
     conv_cust ( '00017024001',   '00034613001' );
     conv_cust ( '00021703001',   '00032197001' );
     conv_cust ( '00004452001',   '00035785001' );
     conv_cust ( '00015195001',   '00036606001' );
     conv_cust ( '00007877001',   '00028620001' );
     conv_cust ( '00021822001',   '00025479001' );
     conv_cust ( '00010214001',   '00030004001' );
     conv_cust ( '00007841001',   '00011502001' );
     conv_cust ( '00027511001',   'Q0000001025' );
     conv_cust ( '00005560001',   '00023237001' );
     conv_cust ( '00018469001',   '00023237001' );
     conv_cust ( '00023228001',   '00028005001' );
     conv_cust ( '00010071001',   '00000332001' );
     conv_cust ( '00020529001',   '00035644001' );
     conv_cust ( '00028262001',   '00008629001' );
     conv_cust ( '00036375001',   '00022231001' );
     conv_cust ( '00016505001',   '00032208001' );
     conv_cust ( '00034080001',   '00028624001' );
     conv_cust ( '00018529001',   '00022955001' );
     conv_cust ( '00008758001',   '00028867001' );
     conv_cust ( '00020233001',   '00035848001' );
     conv_cust ( '00021116001',   '00036143001' );
     conv_cust ( '00007694001',   '00005897001' );
     conv_cust ( '00017443001',   '00021663001' );
     conv_cust ( '00006387001',   '00007279001' );
     conv_cust ( '00013783001',   '00035686001' );
     conv_cust ( '00013870001',   '00035533001' );
     conv_cust ( '00002162001',   '00035533001' );
     conv_cust ( '00004249001',   '00017707001' );
     conv_cust ( '00011117001',   '00019566001' );
     conv_cust ( '00001967001',   'Q0000001407' );
     conv_cust ( '00003453001',   'Q0000001407' );
     conv_cust ( '00007411001',   '00023035001' );
     conv_cust ( '00003692001',   '00015615001' );
     conv_cust ( '00000999002',   '00025998001' );
     conv_cust ( '00003932001',   '00025998001' );
     conv_cust ( '00024423001',   '00035844001' );
     conv_cust ( '00003420001',   '00015296001' );
     conv_cust ( '00001105001',   '00020756001' );
     conv_cust ( '00008541001',   '00022859001' );
     conv_cust ( '00007355001',   '00025879001' );
     conv_cust ( '00018953001',   '00029365001' );
     conv_cust ( '00003667001',   '00021744001' );
     conv_cust ( '00005569001',   '00006160001' );
     conv_cust ( '00003822001',   '00012008001' );
     conv_cust ( '00021126001',   '00017548001' );
     conv_cust ( '00012850001',   '00003226001' );
     conv_cust ( '00019532001',   '00006419001' );
     conv_cust ( '00000979002',   '00000979001' );
     conv_cust ( '00014237001',   '00008571001' );
     conv_cust ( '00002329001',   '00013710001' );
     conv_cust ( '00009948001',   '00002633001' );
     conv_cust ( '00013126001',   '00011129001' );
     conv_cust ( '00009270001',   '00004475001' );
     conv_cust ( '00008881001',   '00015173001' );
     conv_cust ( '00003132001',   '00013711001' );
     conv_cust ( '00007477001',   '00009072001' );
     conv_cust ( '00020280001',   '00019061001' );
     conv_cust ( '00009662001',   '00017036001' );
     conv_cust ( '00004485001',   '00005679001' );
     conv_cust ( '00002371001',   '00010018001' );
     conv_cust ( '00019858001',   '00009145001' );
     conv_cust ( '00017798001',   '00015115001' );
     conv_cust ( '00013327001',   '00014976001' );
     conv_cust ( '00023692001',   '00024579001' );
     conv_cust ( '00003144001',   '00015869001' );
     conv_cust ( '00018058001',   '00022713001' );
     conv_cust ( '00005796001',   '00017657001' );
     conv_cust ( '00002838001',   '00014253001' );
     conv_cust ( '00008506001',   '00010096001' );
     conv_cust ( '00006741001',   '00009130001' );
     conv_cust ( '00033408001',   '00034865001' );
     conv_cust ( '00015849001',   '00034865001' );
     conv_cust ( '00010471001',   '00034865001' );
     conv_cust ( '00027462001',   '00030232001' );
     conv_cust ( '00010508001',   '00013921001' );
     conv_cust ( '00003532001',   '00005643001' );
     conv_cust ( '00004774001',   '00006556001' );
     conv_cust ( '00024487001',   '00035642001' );
     conv_cust ( '00003988001',   '00002800001' );
     conv_cust ( '00021177001',   'Q0000001110' );
     conv_cust ( '00019166001',   'Q0000001110' );
     conv_cust ( '00007618001',   '00009263001' );
     conv_cust ( '00010284001',   '00010666001' );
     conv_cust ( '00018569001',   '00001223001' );
     conv_cust ( '00009560001',   '00010532001' );
     conv_cust ( '00003436001',   '00006215001' );
     conv_cust ( '00005941001',   '00006011001' );
     conv_cust ( '00010154001',   '00015740001' );
     conv_cust ( '00008979002',   '00015520001' );
     conv_cust ( '00001068002',   '00009191002' );
     conv_cust ( '00004311002',   '00009191002' );
     conv_cust ( '00004322002',   '00009191002' );
     conv_cust ( '00004601002',   '00009191002' );
     conv_cust ( '00004874002',   '00009191002' );
     conv_cust ( '00004875002',   '00009191002' );
     conv_cust ( '00004975002',   '00009191002' );
     conv_cust ( '00005120002',   '00009191002' );
     conv_cust ( '00005246002',   '00009191002' );
     conv_cust ( '00005343002',   '00009191002' );
     conv_cust ( '00007299002',   '00009191002' );
     conv_cust ( '00008939002',   '00009191002' );
     conv_cust ( '00009532002',   '00009191002' );
     conv_cust ( '00004064002',   '00015504001' );
     conv_cust ( '00013121002',   '00015504001' );
     conv_cust ( '00013122002',   '00015504001' );
     conv_cust ( '00002313003',   '00015506001' );
     conv_cust ( '00012204002',   '00015520001' );
     conv_cust ( '00009676002',   '00015511001' );
     conv_cust ( '00008394002',   '00015512001' );
     conv_cust ( '00004029002',   '00015514001' );
     conv_cust ( '00005369001',   '00015514001' );
     conv_cust ( '00003512002',   '00015518001' );
     conv_cust ( '00004673002',   '00015518001' );
     conv_cust ( '00004821001',   '00015518001' );
     conv_cust ( '00006408002',   '00015518001' );
     conv_cust ( '00013080002',   '00015518001' );
     conv_cust ( '00013311002',   '00015518001' );
     conv_cust ( '00001761023',   '99900700000' );
     conv_cust ( '00006169001',   '99900700000' );
     conv_cust ( '00008158002',   '99900700000' );
     conv_cust ( '00011477002',   '99900700000' );
     conv_cust ( '00014109002',   '99900700000' );
     conv_cust ( '00008551002',   '00015600001' );
     conv_cust ( '00003083002',   '00015600001' );
     conv_cust ( '00012466002',   '00015501001' );
     conv_cust ( '00013400001',   '00019146001' );
     conv_cust ( '00007328002',   '00015529001' );
     conv_cust ( '00009426002',   '00015529001' );
     conv_cust ( '00009427002',   '00015529001' );
     conv_cust ( '00009428002',   '00015529001' );
     conv_cust ( '00009429002',   '00015529001' );
     conv_cust ( '00009430002',   '00015529001' );
     conv_cust ( '00009431002',   '00015529001' );
     conv_cust ( '00009432002',   '00015529001' );
     conv_cust ( '00009695002',   '00015529001' );
     conv_cust ( '00009696002',   '00015529001' );
     conv_cust ( '00009697002',   '00015529001' );
     conv_cust ( '00012167002',   '00015529001' );
     conv_cust ( '00011056001',   '00015538001' );
     conv_cust ( '00021494001',   '00015542001' );
     conv_cust ( '00035677001',   '00015543001' );
     conv_cust ( '00004926002',   '00015548001' );
     conv_cust ( '00005016002',   '00015548001' );
     conv_cust ( '00013758001',   '00015553001' );
     conv_cust ( '00014333001',   '00015507001' );
     conv_cust ( '00005033002',   '00015557001' );
     conv_cust ( '00007845002',   '00015557001' );
     conv_cust ( '00009599002',   '00015557001' );
     conv_cust ( '00011820002',   '00015557001' );
     conv_cust ( '00004610002',   '00015561001' );
     conv_cust ( '00003595001',   '00015563001' );
     conv_cust ( '00003596002',   '00015563001' );
     conv_cust ( '00002288001',   '00015564001' );
     conv_cust ( '00004686001',   '00015568001' );
     conv_cust ( '00001156001',   '00015570001' );
     conv_cust ( '00004984002',   '00015576001' );
     conv_cust ( '00005524002',   '00015576001' );
     conv_cust ( '00005918002',   '00015576001' );
     conv_cust ( '00005919002',   '00015576001' );
     conv_cust ( '00006181002',   '00015576001' );
     conv_cust ( '00006487002',   '00015576001' );
     conv_cust ( '00008289002',   '00015576001' );
     conv_cust ( '00009264002',   '00015576001' );
     conv_cust ( '00009637002',   '00015576001' );
     conv_cust ( '00009638002',   '00015576001' );
     conv_cust ( '00009639002',   '00015576001' );
     conv_cust ( '00009640002',   '00015576001' );
     conv_cust ( '00009641002',   '00015576001' );
     conv_cust ( '00011387002',   '00015576001' );
     conv_cust ( '00012883002',   '00015576001' );
     conv_cust ( '00013200002',   '00015576001' );
     conv_cust ( '00014131002',   '00015576001' );
     conv_cust ( '00014469002',   '00015501001' );
     conv_cust ( '00012410002',   '00015578001' );
     conv_cust ( '00013406002',   '00015581001' );
     conv_cust ( '00013407002',   '00015581001' );
     conv_cust ( '00010828002',   '00015583001' );
     conv_cust ( '00012765002',   '00015586001' );
     conv_cust ( '00002370002',   '00015590001' );
     conv_cust ( '00010614002',   '00015591001' );
     conv_cust ( '00012284002',   '00015591001' );
     conv_cust ( '00012699002',   '00015591001' );
     conv_cust ( '00013493002',   '00015591001' );
     conv_cust ( '00012287002',   '00015592001' );
     conv_cust ( '00012809001',   '00009103001' );
     conv_cust ( '00013520001',   '00000013001' );
     conv_cust ( '00000987002',   '00000013001' );
     conv_cust ( '00000989002',   '00000013001' );
     conv_cust ( '00000998002',   '00000013001' );
     conv_cust ( '00001001002',   '00000013001' );
     conv_cust ( '00001003002',   '00000013001' );
     conv_cust ( '00001007002',   '00000013001' );
     conv_cust ( '00001008002',   '00000013001' );
     conv_cust ( '00001010002',   '00000013001' );
     conv_cust ( '00001012002',   '00000013001' );
     conv_cust ( '00001014002',   '00000013001' );
     conv_cust ( '00001015002',   '00000013001' );
     conv_cust ( '00001016002',   '00000013001' );
     conv_cust ( '00001019002',   '00000013001' );
     conv_cust ( '00001025002',   '00000013001' );
     conv_cust ( '00001027002',   '00000013001' );
     conv_cust ( '00001050002',   '00000013001' );
     conv_cust ( '00001116002',   '00000013001' );
     conv_cust ( '00001117002',   '00000013001' );
     conv_cust ( '00001118002',   '00000013001' );
     conv_cust ( '00001137002',   '00000013001' );
     conv_cust ( '00001145002',   '00000013001' );
     conv_cust ( '00001146002',   '00000013001' );
     conv_cust ( '00001156002',   '00000013001' );
     conv_cust ( '00001196002',   '00000013001' );
     conv_cust ( '00001197002',   '00000013001' );
     conv_cust ( '00001200002',   '00000013001' );
     conv_cust ( '00001201002',   '00000013001' );
     conv_cust ( '00001204002',   '00000013001' );
     conv_cust ( '00001233002',   '00000013001' );
     conv_cust ( '00001234002',   '00000013001' );
     conv_cust ( '00001235003',   '00000013001' );
     conv_cust ( '00001238002',   '00000013001' );
     conv_cust ( '00001241002',   '00000013001' );
     conv_cust ( '00001243002',   '00000013001' );
     conv_cust ( '00001244002',   '00000013001' );
     conv_cust ( '00001246002',   '00000013001' );
     conv_cust ( '00001249002',   '00000013001' );
     conv_cust ( '00001251002',   '00000013001' );
     conv_cust ( '00001252002',   '00000013001' );
     conv_cust ( '00001255002',   '00000013001' );
     conv_cust ( '00001256002',   '00000013001' );
     conv_cust ( '00001272002',   '00000013001' );
     conv_cust ( '00001287002',   '00000013001' );
     conv_cust ( '00001301002',   '00000013001' );
     conv_cust ( '00001305002',   '00000013001' );
     conv_cust ( '00001326002',   '00000013001' );
     conv_cust ( '00001327002',   '00000013001' );
     conv_cust ( '00001357002',   '00000013001' );
     conv_cust ( '00001359002',   '00000013001' );
     conv_cust ( '00001492002',   '00000013001' );
     conv_cust ( '00001495002',   '00000013001' );
     conv_cust ( '00001496002',   '00000013001' );
     conv_cust ( '00001497002',   '00000013001' );
     conv_cust ( '00001564002',   '00000013001' );
     conv_cust ( '00001565002',   '00000013001' );
     conv_cust ( '00001567002',   '00000013001' );
     conv_cust ( '00001568002',   '00000013001' );
     conv_cust ( '00001571002',   '00000013001' );
     conv_cust ( '00001630002',   '00000013001' );
     conv_cust ( '00001632002',   '00000013001' );
     conv_cust ( '00001635002',   '00000013001' );
     conv_cust ( '00001636002',   '00000013001' );
     conv_cust ( '00001638002',   '00000013001' );
     conv_cust ( '00001640002',   '00000013001' );
     conv_cust ( '00001662002',   '00000013001' );
     conv_cust ( '00001687002',   '00000013001' );
     conv_cust ( '00001688002',   '00000013001' );
     conv_cust ( '00001699002',   '00000013001' );
     conv_cust ( '00001704002',   '00000013001' );
     conv_cust ( '00001706002',   '00000013001' );
     conv_cust ( '00001708002',   '00000013001' );
     conv_cust ( '00001715002',   '00000013001' );
     conv_cust ( '00001727002',   '00000013001' );
     conv_cust ( '00001729002',   '00000013001' );
     conv_cust ( '00001731002',   '00000013001' );
     conv_cust ( '00001842002',   '00000013001' );
     conv_cust ( '00001843002',   '00000013001' );
     conv_cust ( '00001844002',   '00000013001' );
     conv_cust ( '00001845002',   '00000013001' );
     conv_cust ( '00001846002',   '00000013001' );
     conv_cust ( '00001847002',   '00000013001' );
     conv_cust ( '00001848002',   '00000013001' );
     conv_cust ( '00001849002',   '00000013001' );
     conv_cust ( '00001877002',   '00000013001' );
     conv_cust ( '00001883002',   '00000013001' );
     conv_cust ( '00001938002',   '00000013001' );
     conv_cust ( '00001950002',   '00000013001' );
     conv_cust ( '00001952002',   '00000013001' );
     conv_cust ( '00002007002',   '00000013001' );
     conv_cust ( '00002010002',   '00000013001' );
     conv_cust ( '00002027002',   '00000013001' );
     conv_cust ( '00002033002',   '00000013001' );
     conv_cust ( '00002034002',   '00000013001' );
     conv_cust ( '00002036002',   '00000013001' );
     conv_cust ( '00002037002',   '00000013001' );
     conv_cust ( '00002038002',   '00000013001' );
     conv_cust ( '00002039002',   '00000013001' );
     conv_cust ( '00002053002',   '00000013001' );
     conv_cust ( '00002102002',   '00000013001' );
     conv_cust ( '00002103002',   '00000013001' );
     conv_cust ( '00002121002',   '00000013001' );
     conv_cust ( '00002122002',   '00000013001' );
     conv_cust ( '00002143002',   '00000013001' );
     conv_cust ( '00002158002',   '00000013001' );
     conv_cust ( '00002186002',   '00000013001' );
     conv_cust ( '00002218002',   '00000013001' );
     conv_cust ( '00002220002',   '00000013001' );
     conv_cust ( '00002221002',   '00000013001' );
     conv_cust ( '00002267002',   '00000013001' );
     conv_cust ( '00002268002',   '00000013001' );
     conv_cust ( '00002269002',   '00000013001' );
     conv_cust ( '00002315002',   '00000013001' );
     conv_cust ( '00002316002',   '00000013001' );
     conv_cust ( '00002317002',   '00000013001' );
     conv_cust ( '00002419002',   '00000013001' );
     conv_cust ( '00002433002',   '00000013001' );
     conv_cust ( '00002456002',   '00000013001' );
     conv_cust ( '00002470002',   '00000013001' );
     conv_cust ( '00002472002',   '00000013001' );
     conv_cust ( '00002473002',   '00000013001' );
     conv_cust ( '00002541002',   '00000013001' );
     conv_cust ( '00002543002',   '00000013001' );
     conv_cust ( '00002544002',   '00000013001' );
     conv_cust ( '00002545002',   '00000013001' );
     conv_cust ( '00002546002',   '00000013001' );
     conv_cust ( '00002548002',   '00000013001' );
     conv_cust ( '00002550002',   '00000013001' );
     conv_cust ( '00002551002',   '00000013001' );
     conv_cust ( '00002552002',   '00000013001' );
     conv_cust ( '00002582002',   '00000013001' );
     conv_cust ( '00002583002',   '00000013001' );
     conv_cust ( '00002611002',   '00000013001' );
     conv_cust ( '00002612002',   '00000013001' );
     conv_cust ( '00002613002',   '00000013001' );
     conv_cust ( '00002614002',   '00000013001' );
     conv_cust ( '00002668002',   '00000013001' );
     conv_cust ( '00002669002',   '00000013001' );
     conv_cust ( '00002700002',   '00000013001' );
     conv_cust ( '00002732002',   '00000013001' );
     conv_cust ( '00002738002',   '00000013001' );
     conv_cust ( '00002739002',   '00000013001' );
     conv_cust ( '00002740002',   '00000013001' );
     conv_cust ( '00002741002',   '00000013001' );
     conv_cust ( '00002758002',   '00000013001' );
     conv_cust ( '00002759002',   '00000013001' );
     conv_cust ( '00002760002',   '00000013001' );
     conv_cust ( '00002825002',   '00000013001' );
     conv_cust ( '00002826002',   '00000013001' );
     conv_cust ( '00002827002',   '00000013001' );
     conv_cust ( '00002829002',   '00000013001' );
     conv_cust ( '00002830002',   '00000013001' );
     conv_cust ( '00002831002',   '00000013001' );
     conv_cust ( '00002832002',   '00000013001' );
     conv_cust ( '00002833002',   '00000013001' );
     conv_cust ( '00002834002',   '00000013001' );
     conv_cust ( '00002842002',   '00000013001' );
     conv_cust ( '00002843002',   '00000013001' );
     conv_cust ( '00002864002',   '00000013001' );
     conv_cust ( '00002885002',   '00000013001' );
     conv_cust ( '00002899002',   '00000013001' );
     conv_cust ( '00002900002',   '00000013001' );
     conv_cust ( '00002967002',   '00000013001' );
     conv_cust ( '00002969002',   '00000013001' );
     conv_cust ( '00002970002',   '00000013001' );
     conv_cust ( '00002971002',   '00000013001' );
     conv_cust ( '00002972002',   '00000013001' );
     conv_cust ( '00002973002',   '00000013001' );
     conv_cust ( '00002974002',   '00000013001' );
     conv_cust ( '00002975002',   '00000013001' );
     conv_cust ( '00002993002',   '00000013001' );
     conv_cust ( '00003021002',   '00000013001' );
     conv_cust ( '00003027002',   '00000013001' );
     conv_cust ( '00003043002',   '00000013001' );
     conv_cust ( '00003058002',   '00000013001' );
     conv_cust ( '00003060002',   '00000013001' );
     conv_cust ( '00003061002',   '00000013001' );
     conv_cust ( '00003062002',   '00000013001' );
     conv_cust ( '00003081002',   '00000013001' );
     conv_cust ( '00003183002',   '00000013001' );
     conv_cust ( '00003184002',   '00000013001' );
     conv_cust ( '00003185002',   '00000013001' );
     conv_cust ( '00003200002',   '00000013001' );
     conv_cust ( '00003201002',   '00000013001' );
     conv_cust ( '00003202002',   '00000013001' );
     conv_cust ( '00003203002',   '00000013001' );
     conv_cust ( '00003204002',   '00000013001' );
     conv_cust ( '00003229002',   '00000013001' );
     conv_cust ( '00003231002',   '00000013001' );
     conv_cust ( '00003236002',   '00000013001' );
     conv_cust ( '00003273002',   '00000013001' );
     conv_cust ( '00003274002',   '00000013001' );
     conv_cust ( '00003275002',   '00000013001' );
     conv_cust ( '00003317002',   '00000013001' );
     conv_cust ( '00003322002',   '00000013001' );
     conv_cust ( '00003334002',   '00000013001' );
     conv_cust ( '00003337002',   '00000013001' );
     conv_cust ( '00003338002',   '00000013001' );
     conv_cust ( '00003340002',   '00000013001' );
     conv_cust ( '00003342002',   '00000013001' );
     conv_cust ( '00003389002',   '00000013001' );
     conv_cust ( '00003400002',   '00000013001' );
     conv_cust ( '00003411002',   '00000013001' );
     conv_cust ( '00003412002',   '00000013001' );
     conv_cust ( '00003471002',   '00000013001' );
     conv_cust ( '00003472002',   '00000013001' );
     conv_cust ( '00003530002',   '00000013001' );
     conv_cust ( '00003532002',   '00000013001' );
     conv_cust ( '00003535002',   '00000013001' );
     conv_cust ( '00003594002',   '00000013001' );
     conv_cust ( '00003620002',   '00000013001' );
     conv_cust ( '00003621002',   '00000013001' );
     conv_cust ( '00003622002',   '00000013001' );
     conv_cust ( '00003692002',   '00000013001' );
     conv_cust ( '00003720002',   '00000013001' );
     conv_cust ( '00003721002',   '00000013001' );
     conv_cust ( '00003722002',   '00000013001' );
     conv_cust ( '00003747002',   '00000013001' );
     conv_cust ( '00003748002',   '00000013001' );
     conv_cust ( '00003797002',   '00000013001' );
     conv_cust ( '00003923002',   '00000013001' );
     conv_cust ( '00003924002',   '00000013001' );
     conv_cust ( '00003925002',   '00000013001' );
     conv_cust ( '00003926002',   '00000013001' );
     conv_cust ( '00003927002',   '00000013001' );
     conv_cust ( '00004023002',   '00000013001' );
     conv_cust ( '00004122002',   '00000013001' );
     conv_cust ( '00004259002',   '00000013001' );
     conv_cust ( '00004260002',   '00000013001' );
     conv_cust ( '00004262002',   '00000013001' );
     conv_cust ( '00004263002',   '00000013001' );
     conv_cust ( '00004265002',   '00000013001' );
     conv_cust ( '00004266002',   '00000013001' );
     conv_cust ( '00004325002',   '00000013001' );
     conv_cust ( '00004326002',   '00000013001' );
     conv_cust ( '00004327002',   '00000013001' );
     conv_cust ( '00004328002',   '00000013001' );
     conv_cust ( '00004413002',   '00000013001' );
     conv_cust ( '00004414002',   '00000013001' );
     conv_cust ( '00004415002',   '00000013001' );
     conv_cust ( '00004453002',   '00000013001' );
     conv_cust ( '00004531002',   '00000013001' );
     conv_cust ( '00004532002',   '00000013001' );
     conv_cust ( '00004558002',   '00000013001' );
     conv_cust ( '00004559002',   '00000013001' );
     conv_cust ( '00004583002',   '00000013001' );
     conv_cust ( '00004584002',   '00000013001' );
     conv_cust ( '00004585002',   '00000013001' );
     conv_cust ( '00004629002',   '00000013001' );
     conv_cust ( '00004658002',   '00000013001' );
     conv_cust ( '00004659002',   '00000013001' );
     conv_cust ( '00004660002',   '00000013001' );
     conv_cust ( '00004691002',   '00000013001' );
     conv_cust ( '00004956002',   '00000013001' );
     conv_cust ( '00004957002',   '00000013001' );
     conv_cust ( '00004958002',   '00000013001' );
     conv_cust ( '00004959002',   '00000013001' );
     conv_cust ( '00005090002',   '00000013001' );
     conv_cust ( '00005240002',   '00000013001' );
     conv_cust ( '00005241002',   '00000013001' );
     conv_cust ( '00005277002',   '00000013001' );
     conv_cust ( '00005278002',   '00000013001' );
     conv_cust ( '00005528002',   '00000013001' );
     conv_cust ( '00005614002',   '00000013001' );
     conv_cust ( '00005615002',   '00000013001' );
     conv_cust ( '00005644002',   '00000013001' );
     conv_cust ( '00005711002',   '00000013001' );
     conv_cust ( '00005887002',   '00000013001' );
     conv_cust ( '00006163002',   '00000013001' );
     conv_cust ( '00006168002',   '00000013001' );
     conv_cust ( '00006169002',   '00000013001' );
     conv_cust ( '00006252002',   '00000013001' );
     conv_cust ( '00006353002',   '00000013001' );
     conv_cust ( '00006412002',   '00000013001' );
     conv_cust ( '00006518002',   '00000013001' );
     conv_cust ( '00006675002',   '00000013001' );
     conv_cust ( '00006676002',   '00000013001' );
     conv_cust ( '00006867002',   '00000013001' );
     conv_cust ( '00006868002',   '00000013001' );
     conv_cust ( '00006869002',   '00000013001' );
     conv_cust ( '00006870002',   '00000013001' );
     conv_cust ( '00006974002',   '00000013001' );
     conv_cust ( '00007038002',   '00000013001' );
     conv_cust ( '00007460002',   '00000013001' );
     conv_cust ( '00007517002',   '00000013001' );
     conv_cust ( '00007527002',   '00000013001' );
     conv_cust ( '00007528002',   '00000013001' );
     conv_cust ( '00007529002',   '00000013001' );
     conv_cust ( '00007701002',   '00000013001' );
     conv_cust ( '00007702002',   '00000013001' );
     conv_cust ( '00007703002',   '00000013001' );
     conv_cust ( '00007736002',   '00000013001' );
     conv_cust ( '00007773002',   '00000013001' );
     conv_cust ( '00007970002',   '00000013001' );
     conv_cust ( '00008069002',   '00000013001' );
     conv_cust ( '00008070002',   '00000013001' );
     conv_cust ( '00008151002',   '00000013001' );
     conv_cust ( '00008223002',   '00000013001' );
     conv_cust ( '00008224002',   '00000013001' );
     conv_cust ( '00008412002',   '00000013001' );
     conv_cust ( '00008598002',   '00000013001' );
     conv_cust ( '00008600002',   '00000013001' );
     conv_cust ( '00008827002',   '00000013001' );
     conv_cust ( '00008990002',   '00000013001' );
     conv_cust ( '00009396002',   '00000013001' );
     conv_cust ( '00009721002',   '00000013001' );
     conv_cust ( '00010199002',   '00000013001' );
     conv_cust ( '00010201002',   '00000013001' );
     conv_cust ( '00010902002',   '00000013001' );
     conv_cust ( '00011347002',   '00000013001' );
     conv_cust ( '00011678002',   '00000013001' );
     conv_cust ( '00012135002',   '00000013001' );
     conv_cust ( '00012138002',   '00000013001' );
     conv_cust ( '00012209002',   '00000013001' );
     conv_cust ( '00013401002',   '00000013001' );
     conv_cust ( '00014077002',   '00000013001' );
     conv_cust ( '00014079002',   '00000013001' );
     conv_cust ( '00014284002',   '00000013001' );
     conv_cust ( '00014800001',   '00000013001' );
     conv_cust ( '00020269002',   '00000013001' );
     conv_cust ( '01246161002',   '00000013001' );
     conv_cust ( '91220050002',   '00000013001' );
     conv_cust ( '91220052002',   '00000013001' );
     conv_cust ( '0014285 002',   '00000013001' );
     conv_cust ( '00001853001',   '00001659001' );
     conv_cust ( '00004996001',   '00017483001' );
     conv_cust ( '00011506001',   '00016237001' );
     conv_cust ( '00027509001',   '00028825001' );
     conv_cust ( '00003854001',   '00032811001' );
     conv_cust ( '00012431001',   '00022283001' );
     conv_cust ( '00017619001',   '00033336001' );
     conv_cust ( '00010051001',   '00016922001' );
     conv_cust ( '00006810001',   '00006805001' );
     conv_cust ( '00006907001',   '00016305001' );
     conv_cust ( '00009698001',   '00011933001' );
     conv_cust ( '00019006001',   '00010837001' );
     conv_cust ( '00023000001',   '00010507001' );
     conv_cust ( '00002340001',   '00013411001' );
     conv_cust ( '00000541001',   '00015427001' );
     conv_cust ( '00001674001',   '00006765001' );
     conv_cust ( '00007035001',   '00021833001' );
     conv_cust ( '00012751001',   '00025802001' );
     conv_cust ( '00013382001',   '00014364001' );
     conv_cust ( '00003065001',   '00005372001' );
     conv_cust ( '00015607001',   '00005372001' );
     conv_cust ( '00009381001',   '00013073001' );
     conv_cust ( '00014203001',   '00016005001' );
     conv_cust ( '00013060001',   '00018061001' );
     conv_cust ( '00016254001',   '00018061001' );
     conv_cust ( '00001046001',   '00017850001' );
     conv_cust ( '00002118001',   '00015165001' );
     conv_cust ( '00003662001',   '00035590001' );
     conv_cust ( '00027689001',   '00035025001' );
     conv_cust ( '00001643001',   '00020145001' );
     conv_cust ( '00007428001',   '00029522001' );
     conv_cust ( '00019905001',   '00008177001' );
     conv_cust ( '00008565001',   '00027400001' );
     conv_cust ( '00010396001',   '00005450001' );
     conv_cust ( '00000269001',   '00035944001' );
     conv_cust ( '00013617001',   '00029961001' );
     conv_cust ( '00019881001',   'Q0000000526' );
     conv_cust ( '00001995001',   '00036304001' );
     conv_cust ( '00009922001',   '00034089001' );
     conv_cust ( '00006370001',   '00034105001' );
     conv_cust ( '00031141001',   '00021696001' );
     conv_cust ( '00002208001',   '00025747001' );
     conv_cust ( '00005512001',   '00033696001' );
     conv_cust ( '00016370001',   '00011854001' );
     conv_cust ( '00019767001',   '00012911001' );
     conv_cust ( '00001517001',   '00027713001' );
     conv_cust ( '00004594001',   '00021006001' );
     conv_cust ( '00012389001',   '00025197001' );
     conv_cust ( '00027426001',   '00030724001' );
     conv_cust ( '00008957001',   '00036645001' );
     conv_cust ( '00026257001',   '00036645001' );
     conv_cust ( '00016084001',   '00022571001' );
     conv_cust ( '00018542001',   '00035265001' );
     conv_cust ( '00036132001',   'Q0000001273' );
     conv_cust ( '00007552001',   '00017546001' );
     conv_cust ( '00022396001',   '00027851001' );
     conv_cust ( '00032150001',   '00003961001' );
     conv_cust ( '00024586001',   '00036830001' );
     conv_cust ( '00002559001',   '00036830001' );
     conv_cust ( '00005210001',   '00036308001' );
     conv_cust ( '00005853001',   '00004765001' );
     conv_cust ( '00005112001',   '00007323001' );
     conv_cust ( '00021187001',   '00007424001' );
     conv_cust ( '00028253001',   '00014845001' );
     conv_cust ( '00025359001',   'Q0000001831' );
     conv_cust ( '00034939001',   '00005170001' );
     conv_cust ( '00007747002',   '00015504001' );
     conv_cust ( '00003665001',   '00007388001' );
     conv_cust ( '00000591001',   '00016431001' );
     conv_cust ( '00029937001',   '00016431001' );
     conv_cust ( '00019054001',   '00037286001' );
     conv_cust ( '00004381001',   '00016215001' );
     conv_cust ( '00001598012',   '00001598015' );
     conv_cust ( '00001718001',   '00001598015' );
     conv_cust ( '00001598009',   '00017386001' );
     conv_cust ( '00006439002',   '00017386001' );
     conv_cust ( '00006440002',   '00017386001' );
     conv_cust ( '00015999001',   '99900300000' );
     conv_cust ( '00015994001',   '99900400000' );
     conv_cust ( '00000911001',   '00007443001' );
     conv_cust ( '00002624002',   '00007443001' );
     conv_cust ( '00002508001',   '00010954001' );
     conv_cust ( '00003032001',   '00017980001' );
     conv_cust ( '00004048001',   '00017980001' );
     conv_cust ( '00006587001',   '00012811001' );
     conv_cust ( '00009582001',   '00013941001' );
     conv_cust ( '00011198001',   '00013941001' );
     conv_cust ( '00015389001',   '00031942001' );
     conv_cust ( '00016839001',   '00019176001' );
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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_RelinkRelatedData.log
prompt

exit;
