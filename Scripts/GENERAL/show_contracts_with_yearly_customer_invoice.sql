-- show_contracts_with_yearly_customer_invoice.sql

-- M.Zimmerberger	29.10.2012 creation due to MKS-119332:1

spool show_contracts_with_yearly_customer_invoice.log

set echo         off
set verify       off
set feedback     off
set timing       off
set heading      off
set sqlprompt    ''
set trimspool    on
set termout      on
set serveroutput on  size 1000000
set lines        999
set pages        0

variable nachricht varchar2 ( 100 );

prompt

whenever sqlerror exit sql.sqlcode

declare
    
    L_ISTUSER         VARCHAR2 ( 30 char ) := user;
    L_SOLLUSER        VARCHAR2 ( 30 char ) := 'SNT';
    L_SYSDBA_PRIV     VARCHAR2 (  1 char );
    L_ABBRUCH         exception;

begin
   
   if    L_ISTUSER is null 
   then  raise L_ABBRUCH;
   elsif upper ( L_SOLLUSER ) <> upper ( L_ISTUSER )
   then  raise L_ABBRUCH;
   end   if;

exception when L_ABBRUCH then raise_application_error ( -20001, 'Executing user is not ' || upper ( L_SOLLUSER )
                                || '! for a correct use of this script, executing user must be ' || upper ( L_SOLLUSER ));
end;
/

WHENEVER SQLERROR CONTINUE

prompt
prompt processing. please wait ...
prompt

set termout      off

set sqlprompt    'SQL>'
set pages        999
set lines        999
set serveroutput on   size 1000000
set heading      on
set feedback     on
set feedback     1

set echo         off

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
COL "contract"								FORMAT A8
COL "vehicle-contract"				FORMAT A10
COL "CI-frequency"						FORMAT A12
COL "pre-/afterpaid"					FORMAT A14
COL "day exact/target-date"	  FORMAT A22
COL "balancing-method" 				FORMAT A16
COL "balancing" 							FORMAT A9
COL "yearly deferment month"	FORMAT 999

SELECT DISTINCT fzg.id_vertrag       "contract",
                fzg.id_fzgvertrag    "vehicle-co",
    DECODE(paym_months, -1, 'one-time',
                         0, 'never',
                         1, 'monthly',
                         3, 'quarterly',
                         6, 'half-yearly',
                        12, 'yearly',
                            paym_months) "CI-frequency",
    DECODE(paym_direction, 0, 'prepaid',
                           1, 'after-paid',
                              paym_direction) "pre-/afterpaid",
    DECODE(paym_targetdate_ci, 0, 'GS: ' || (SELECT value
                                               FROM snt.tglobal_settings
                                              WHERE upper(application_id) = 'SIRIUS'
                                                AND upper(section) = 'SETTING'
                                                AND upper(entry) = 'TARGETDATECUSTOMERINVOICE'),
                               1, 'dailyexact',
                                  'GS override: ' || paym_targetdate_ci) "day exact/target-date" ,
    DECODE(fzgvc_runpower_balancingmethod, 0, 'ct/km',
                                           1, 'expense minus proceeds',
                                           2, 'contract value minus paid',
                                              fzgvc_runpower_balancingmethod) "balancing-method" ,
    DECODE(fzgvc_runpower_balancing, 0, 'never',
                                    -1, 'end-of-contract',
                                    12, 'yearly',
                                        fzgvc_runpower_balancing)   "balancing",
    fzgvc.fzgvc_rpb_max_month  "yearly deferment month" 
 FROM snt.tfzgv_contracts fzgvc, snt.tdfpaymode paym, snt.tfzgvertrag fzg
WHERE fzgvc.id_paym = paym.id_paym
  AND fzgvc_runpower_balancing = 12 
  AND (    fzg.id_vertrag = fzgvc.id_vertrag
           AND fzg.id_fzgvertrag = fzgvc.id_fzgvertrag)
  AND fzg.id_cos IN (SELECT id_cos
                       FROM snt.tdfcontr_state COS
                      WHERE COS.cos_active = 1)
 ORDER BY 1, 2 DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

declare

   L_MAJOR_MIN     number := 2;
   L_MINOR_MIN     number := 8;
   L_REVISION_MIN  number := 0;

   L_MAJOR_IST     number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST     number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST  number := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );

begin
	if    L_MAJOR_IST > L_MAJOR_MIN
		 or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST > L_MINOR_MIN )
		 or ( L_MAJOR_IST = L_MAJOR_MIN and L_MINOR_IST = L_MINOR_MIN and L_REVISION_IST >= L_REVISION_MIN )
	then  execute immediate ( 'begin snt.SRS_LOG_MAINTENANCE_SCRIPTS ( ''show_contracts_with_yearly_customer_invoice.sql'' ); end;' );
  end   if;
	:nachricht := 'Data selected from DB';

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile show_contracts_with_yearly_customer_invoice.log
prompt

exit;
