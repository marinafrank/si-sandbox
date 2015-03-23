-- DataCleansing_CleanContractStateZero.sql 
-- zisco    02.07.2013 MKS-126591:1 / LOP2589 - Cleansing of contract state
-- zisco    04.07.2013 MKS-126591:2 / LOP2589 - add deletion of ID_COS if no referencing contracts where detected
-- FraBe    18.07.2013 MKS-126591:3 / LOP2589 - add deletion of ID_COS_NEW = 0 from TEXT_COS_LASTCHANGE
-- FraBe    18.07.2013 MKS-126591:4 / LOP2589 - also delete ID_COS = 0 from TEXT_STATCODE_LASTCHANGE

spool DataCleansing_MBBEL_LOP2589_CleanContractStateZero.log

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

variable nachricht    varchar2 ( 100 );

prompt

whenever sqlerror exit sql.sqlcode

declare

   L_SYS_DBA_ABBRUCH       exception;
   L_USER_ABBRUCH          exception;
   L_DB_VERSION_ABBRUCH    exception;

   L_SYSDBA_PRIV           VARCHAR2 (  1 char );
   L_SYSDBA_PRIV_NEEDED    boolean              := false;          -- false or true
   
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   L_SOLLUSER              VARCHAR2 ( 30 char ) := 'SNT';
  
   L_MAJOR_MIN             integer := 2;
   L_MINOR_MIN             integer := 8;
   L_REVISION_MIN          integer := 0;
   L_BUILD_MIN             integer := 0;

   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );
   
begin

   -- check sysdba priv
   if   L_SYSDBA_PRIV_NEEDED
   then begin
          select 'Y'
            into L_SYSDBA_PRIV 
            from SESSION_PRIVS 
           where PRIVILEGE = 'SYSDBA';
       exception when NO_DATA_FOUND then raise L_SYS_DBA_ABBRUCH;
       end;
  end  if;
   
   -- check user 
   if    L_ISTUSER is null 
   then  raise L_USER_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_USER_ABBRUCH;
   end   if;
   
   -- check DB version
   if      L_MAJOR_IST > L_MAJOR_MIN
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST > L_REVISION_MIN )
      or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST = L_REVISION_MIN and L_BUILD_IST >= L_BUILD_MIN )
   then  null;

   else  raise L_DB_VERSION_ABBRUCH;

   end   if;
   
exception
  when L_SYS_DBA_ABBRUCH 
  then raise_application_error ( -20001
                               , 'Executing user is not ' || upper ( L_SOLLUSER ) || ' / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ) || ' / SYSDABA' 
                              || chr(10) || '==> Script Execution cancelled <==' );
  when L_USER_ABBRUCH 
  then raise_application_error ( -20002
                               , 'Executing user is not ' || upper ( L_SOLLUSER ) || '!'
                              || chr(10) || 'For a correct use of this script, executing user must be ' || upper ( L_SOLLUSER )
                              || chr(10) || '==> Script Execution cancelled <==' );
  when L_DB_VERSION_ABBRUCH
  then raise_application_error ( -20003
                               , 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || L_MAJOR_MIN || '.' || L_MINOR_MIN || '.' || L_REVISION_MIN || '.' || L_BUILD_MIN
                              || chr(10) || '==> Script Execution cancelled <==' );
end;
/

WHENEVER SQLERROR CONTINUE

accept commit_or_rollback prompt "Do you want to save the changes? Y/N: "

prompt
prompt Operation in progress. Please wait...
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
--set feedback     off

--set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

-- 1st: 
prompt 
prompt Check contracts where ID_COS=0
prompt 

DECLARE
   l_cnt_id_cos_zero INTEGER;
   
BEGIN

   SELECT count(*)
     INTO l_cnt_id_cos_zero
     FROM tfzgvertrag
    WHERE id_cos = 0;

   IF l_cnt_id_cos_zero > 0 THEN
      dbms_output.put_line ('id_vertrag/id_fzgvertrag of contracts where id_cos=0');
      FOR crec IN (SELECT id_vertrag, id_fzgvertrag
                     FROM tfzgvertrag
                    WHERE id_cos = 0)
      LOOP
         dbms_output.put_line (crec.id_vertrag || '/' || crec.id_fzgvertrag);
      END LOOP;
   ELSE

      delete from snt.TEXT_STATCODE_LASTCHANGE where COS_STAT_CODE_NEW  = 0; -- MKS-126591:4   
      delete from snt.TEXT_COS_LASTCHANGE      where ID_COS_NEW         = 0; -- MKS-126591:3
      DELETE FROM snt.tdfcontr_state      WHERE id_cos     = 0;
      if   sql%rowcount > 0
      then dbms_output.put_line ( 'id_cos=0 deleted!' );
      else dbms_output.put_line ( 'id_cos=0 could not be deleted as not existing at all!' );
      end  if;
   END IF;

END;
/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   upper ( '&&commit_or_rollback' ) = 'Y'
   then commit;
        snt.SRS_LOG_MAINTENANCE_SCRIPTS ( 'DataCleansing_CleanContractStateZero.sql' );
        :nachricht := 'Data changed';
   else rollback;
        :nachricht := 'No data changed';
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
prompt Please contact the SIRIUS Support Team@Ulm if an ORA- or SP2-error can be found in DataCleansing_CleanContractStateZero.log.
prompt

exit;
