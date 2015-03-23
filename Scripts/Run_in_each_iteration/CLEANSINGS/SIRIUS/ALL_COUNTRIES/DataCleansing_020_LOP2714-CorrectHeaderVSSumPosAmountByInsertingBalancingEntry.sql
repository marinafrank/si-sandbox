-- DataCleansing_020_LOP2714-CorrectHeaderVSSumPosAmountByInsertingBalancingEntry.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- FraBe   30.07.2013 MKS-127190:1 creation
-- FraBe   02.08.2013 MKS-127190:2 1) trigger EXT_TFZGRECHNUNG nicht deaktivieren wegen EXT_CREATEION_DATE, auch wenn DataMart nicht mehr elevant ist
--                                 2) L_AUSGABEZEILE wird nur dann ausgegeben, wenn mind. 1 korrekturPos angelegt wurde
-- FraBe   28.08.2013 MKS-127743:1 exclude VEGA Invoices (-> I11 / I56 )
-- FraBe   29.08.2013 MKS-127743:2 exclude VEGA Invoices (-> I11 / I56 ) auch im abschließenden check select!
-- FraBe   30.12.3013 MKS-130326:1 do not spool into a csv file anymore - spool everything into the .log - file
--                                 move message 'processing. please wait ...' to the beginning of the script before spool cmd
-- FraBe   30.12.3013 MKS-130326:2 lö hinweis auf csv file auch aus abschließendem SP2- bzw. ORA- check - prompt
-- FraBe   08.01.2014 MKS-130325:1 A) handle INV / CN  without any position:
--                                    a) calculate new L_IP_SALESTAX 
--                                    b) outer join to TINV_POSITION
--                                 B) new tolerance logic 0.01 per position and not 0.01 per whole INV / CN
-- 2014-05-16; MARZUHL; V1.0; MKS-132564:1; Changed to new output format / framework

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_020_LOP2714-CorrectHeaderVSSumPosAmountByInsertingBalancingEntry
   define GL_LOGFILETYPE	= LOG		-- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   define GL_SCRIPTFILETYPE	= SQL		-- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN		= 2
   define L_MINOR_MIN		= 8
   define L_REVISION_MIN	= 1
   define L_BUILD_MIN		= 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER		= SNT
   define L_SYSDBA_PRIV_NEEDED	= false		-- false or true

  -- country specification
   define L_MPC_CHECK		= false		-- false or true
   define L_MPC_SOLL		= 'MBBeLux'
  
  -- Reexecution
   define  L_REEXEC_FORBIDDEN	= false		-- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   define L_DB_LOGGING_ENABLE	= true		-- Are we logging to the DB? -> false or true
   define L_LOGFILE_REQUIRED	= true		-- Logfile required? -> false or true

--
--
-- END SCRIPT PARAMETERIZATION
--
--
-- HINT: To increase local variables use following code:
-- {:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;} in pl/SQL or
-- {exec :L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1} in SQL

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################

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

variable L_SCRIPTNAME 		varchar2 (200 char);
variable L_ERROR_OCCURED 	number;
variable L_DATAERRORS_OCCURED 	number;
variable L_DATAWARNINGS_OCCURED number;
variable L_DATASUCCESS_OCCURED number;
variable nachricht       	varchar2 ( 200 char );
exec :L_SCRIPTNAME := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED :=0
exec :L_DATAERRORS_OCCURED :=0
exec :L_DATAWARNINGS_OCCURED :=0
exec :L_DATASUCCESS_OCCURED :=0

spool &GL_SCRIPTNAME..&GL_LOGFILETYPE

declare
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
  dbms_output.put_line ('Script executed on: ' ||to_char(sysdate,'DD.MM.YYYY HH24:MI:SS')); 
  dbms_output.put_line ('Script executed by: &&_USER'); 
  dbms_output.put_line ('Script run on DB  : &&_CONNECT_IDENTIFIER'); 
  dbms_output.put_line ('Database Country  : ' ||snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' )); 
  dbms_output.put_line ('Database dump date: ' ||snt.get_TGLOBAL_SETTINGS ( 'DB', 'DUMP', 'DATE', 'not found' )); 
  begin
              select to_char (max( LE_CREATED), 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
	              from snt.TLOG_EVENT e
	             where GUID_LA = '10'         -- maintenance
	               and exists ( select null
	                              from snt.TLOG_EVENT_PARAM ep
	                             where ep.LEP_VALUE = :L_SCRIPTNAME
                              and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on ' || L_LAST_EXEC_TIME);
    
    exception 
    when others then 
      NULL;
  end;
 end if;
 
end;
/


prompt

whenever sqlerror exit sql.sqlcode

declare

   ----------------------------------------
   -- einstellungen für div. checks
   ----------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -- 2) unter welchem user muß das script laufen?
  
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -): 


   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' );
   -- 5) falls das script auf keinen fall ein zweites mal nach einem commit = 'Y' laufen darf, hier true angeben
  
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
   
   -- weitere benötigte variable
   L_ABBRUCH               boolean := false;

begin

   -------------------------------------------------------------------------------------------------------
   -- ad 1) check sysdba priv
   if   &L_SYSDBA_PRIV_NEEDED
   then begin
          select 'Y'
             into L_SYSDBA_PRIV 
             from SESSION_PRIVS 
            where PRIVILEGE = 'SYSDBA';
        exception when NO_DATA_FOUND 
                  then dbms_output.put_line ( 'Executing user is not &L_SOLLUSER / SYSDABA!'
                              || chr(10) || 'For a correct use of this script, executing user must be &L_SOLLUSER  / SYSDABA' || chr(10) );
                       L_ABBRUCH := true;
        end;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 2) check user 
   if   L_ISTUSER is null or upper ( '&L_SOLLUSER' ) <> upper ( L_ISTUSER )
   then dbms_output.put_line ( 'Executing user is not  &L_SOLLUSER !'
                             || chr(10) || 'For a correct use of this script, executing user must be  &L_SOLLUSER ' || chr(10) );
        L_ABBRUCH := true;
   end  if;

   -------------------------------------------------------------------------------------------------------
   -- ad 3) check DB version
   if      L_MAJOR_IST > &L_MAJOR_MIN
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST > &L_MINOR_MIN )
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST = &L_MINOR_MIN and L_REVISION_IST > &L_REVISION_MIN )
      or ( L_MAJOR_IST = &L_MAJOR_MIN and L_MINOR_IST = &L_MINOR_MIN and L_REVISION_IST = &L_REVISION_MIN and L_BUILD_IST >= &L_BUILD_MIN )
   then  null;
   else  dbms_output.put_line ( 'DB Version is incorrect! '
                              || chr(10) || 'Current version is '
                              || L_MAJOR_IST || '.' || L_MINOR_IST || '.' || L_REVISION_IST || '.' || L_BUILD_IST
                              || ', but version must be same or higher than '
                              || &L_MAJOR_MIN || '.' || &L_MINOR_MIN || '.' || &L_REVISION_MIN || '.' || &L_BUILD_MIN || chr(10) );
         L_ABBRUCH := true;
   end   if;

   -------------------------------------------------------------------------------------------------------
   -- ad 4) check MPC
   if   &L_MPC_CHECK and L_MPC_IST <> '&L_MPC_SOLL' 
   then dbms_output.put_line ( 'This script can be executed against a ' || '&L_MPC_SOLL' || ' DB only!'
                              || chr(10) || 'You are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
        L_ABBRUCH := true;
   end  if;
   
   -------------------------------------------------------------------------------------------------------
   -- ad 5) check forbidden script re-exec
   if   &L_REEXEC_FORBIDDEN 
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

PROMPT Do you want to save the changes to the DB? [Y/N] (Default N):

SET TERMOUT OFF
Define commit_or_rollback = &1 N;
SET TERMOUT ON

prompt SELECTION CHOSEN: "&commit_or_rollback"

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
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < 0: pre - actions like deactivating constraint or trigger >
set feedback     on
PROMPT Which memotext do you want for the new positions:

SET TERMOUT OFF
Define L_IP_MEMO = &2 MIGRATION;
SET TERMOUT ON

prompt SELECTION CHOSEN: &L_IP_MEMO;

set feedback     off
alter trigger    IP_NO_UPD_DEL       disable;
alter trigger    TRIG_TINV_POS_MAIN  disable;
alter trigger    EXT_TINV_POSITION   disable;
alter trigger    FZGRE_NO_UPD_DEL    disable;

set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

-- 1st: 
prompt 
prompt create adjustment - positions for following invoices:
prompt 

-- spool DataCleansing_LOP2714-CorrectHeaderVSSumPosAmountByInsertingBalancingEntry.csv MKS-130326:1 do not spool into a csv file anymore

set Termout off
declare
	L_AUSGABEZEILE               varchar2 ( 2000 );
	L_ID_SEQ_FZGRECHNUNG         snt.TINV_POSITION.ID_SEQ_FZGRECHNUNG%type;
	L_IP_POSINDEX                snt.TINV_POSITION.IP_POSINDEX%type;
	L_GUID_DAMAGE_CODE           snt.TDAMAGE_CODE.GUID_DAMAGE_CODE%type;
	L_SONST_HEADER_CORR          snt.TFZGRECHNUNG.FZGRE_RESUMME%type;
	L_FZGRE_BELEGDATUM           snt.TFZGRECHNUNG.FZGRE_BELEGDATUM%type;
	L_GUID_PARTNER               snt.TFZGRECHNUNG.GUID_PARTNER%type;
	L_BELART_INVOICE_OR_CNOTE    snt.TBELEGARTEN.BELART_INVOICE_OR_CNOTE%type;
    
	-- die korrekturPos werden nach der letzten existierenden IP_POSINDEX - nummer angelegt
	function get_max_IP_POSINDEX return integer is
		begin
			select
				max ( IP_POSINDEX )
			into     
				L_IP_POSINDEX
			from
				snt.TINV_POSITION
			where
				ID_SEQ_FZGRECHNUNG = L_ID_SEQ_FZGRECHNUNG
			;
			return L_IP_POSINDEX;
		end;
    
	procedure ins_TINV_POSITION 
		( I_IP_CARDTYPE     number
		, I_COUNT_POS       number
		, I_IP_LISTPRICE    number
		) is
			L_IP_SALESTAX     snt.TINV_POSITION.IP_SALESTAX%type;
		begin
        
		-- ein wert bis 0.01 pro rechnungsposition wird als rundungsdifferenz akzeptiert -> dafür wird keine korrekturPos angelegt
		if abs ( I_IP_LISTPRICE ) > 0.01 * I_COUNT_POS                
		then
			L_IP_POSINDEX := L_IP_POSINDEX + 1;

			-- zuerst finden VAT rate, die am meisten vorkommt.
			-- wenns deren mehrere sind, jene mit dem höchsten wert (-> lt. vorgabe )
			begin
				select
					IP_SALESTAX
				into
					L_IP_SALESTAX
				from
					( select
						IP_SALESTAX, count(*)
					from
						snt.TINV_POSITION
					where
						ID_SEQ_FZGRECHNUNG   = L_ID_SEQ_FZGRECHNUNG
						and IP_CARDTYPE          = I_IP_CARDTYPE
					group by
						IP_SALESTAX
					order by 
						2 desc, 1 desc
					)
				where
					rownum = 1;
				exception when NO_DATA_FOUND 
					then -- MKS-130325:1 INV / CN hat keine position -> es wird daher die VAT zum rechnungserstellungsdatum genommen
						select
							vatr.VATR_RATE
						into
							L_IP_SALESTAX
						from
							snt.TVAT_RATE   vatr
							, snt.TVAT        vat
							, snt.VPARTNER    part
						where
							( L_FZGRE_BELEGDATUM not between nvl ( part.VALID_FROM1, L_FZGRE_BELEGDATUM + 1 ) --> keine reduzierte VAT
								and nvl ( part.VALID_TO1,   L_FZGRE_BELEGDATUM - 1 )
							or L_FZGRE_BELEGDATUM     between       part.VALID_FROM1                           --> echte reduzierte VAT
								and       part.VALID_TO1                            )
							and L_FZGRE_BELEGDATUM       between       vatr.VATR_VALID_FROM
								and       vatr.VATR_VALID_TO
							and part.GUID_PARTNER            = L_GUID_PARTNER 
							and vat.GUID_VAT                 = vatr.GUID_VAT
							and vat.GUID_VAT                 = decode ( trim ( to_char ( L_BELART_INVOICE_OR_CNOTE )) || part.PARTNERTYP
													, '0C', part.GUID_VAT_CREDIT_INVOICE
													, '0D', part.GUID_VAT_DEBIT_INVOICE
													, '1C', part.GUID_VAT_CREDIT_CNOTE
													, '1D', part.GUID_VAT_DEBIT_CNOTE
													)
						;
			end;
                
			-- dann anlegen neue position:
			insert into snt.TINV_POSITION
				( GUID_IP
				, ID_SEQ_FZGRECHNUNG
				, IP_CARDTYPE
				, IP_POSINDEX
				, IP_MEMO
				, IP_AMOUNT
				, IP_LISTPRICE
				, IP_GROSSPRICE
				, ID_REPCODE
				, ID_SUBREPCODE
				, GUID_DAMAGE_CODE
				, IP_SALESTAX
				, IP_POSITION_CODE
				, IP_WORK_NR
				, IP_CONTROL_STATE
				, IP_REJECT_QUANTITY
				, IP_REJECT_AMOUNT
				, IP_REJECT_PERCENT
				, IP_REJECT_SUM
				, ID_COMPANY
				, ID_ORDER
				, IP_CUST_SHARE
				, IP_DISCOUNT
				, IP_DISCOUNT_GR
				, IP_LASV
				, IP_SUM_WORK
				, IP_SUM_PART
				, IP_SUM_OTHER )
			values
				( sys_guid() 
				, L_ID_SEQ_FZGRECHNUNG
				, I_IP_CARDTYPE
				, L_IP_POSINDEX
				, '&&L_IP_MEMO'
				, 1			-- IP_AMOUNT
				, I_IP_LISTPRICE
				, I_IP_LISTPRICE	-- IP_GROSSPRICE               
				, '00'			-- ID_REPCODE
				, '252'			-- ID_SUBREPCODE
				, L_GUID_DAMAGE_CODE	-- GUID_DAMAGE_CODE
				, L_IP_SALESTAX		-- IP_SALESTAX
				, 'Correction Position'	-- IP_POSITION_CODE
				, 'Corr.Pos.'		-- IP_WORK_NR
				, 1			-- IP_CONTROL_STATE
				, 0			-- IP_REJECT_QUANTITY
				, 0			-- IP_REJECT_AMOUNT
				, 0			-- IP_REJECT_PERCENT
				, 0			-- IP_REJECT_SUM
				, 0			-- ID_COMPANY
				, 0			-- ID_ORDER
				, 0			-- IP_CUST_SHARE
				, 0			-- IP_DISCOUNT
				, 0			-- IP_DISCOUNT_GR
				, 0			-- IP_LASV
				, 0			-- IP_SUM_WORK
				, 0			-- IP_SUM_PART
				, 0			-- IP_SUM_OTHER
				)
			;

			L_AUSGABEZEILE := L_AUSGABEZEILE ||  '; ' || to_char ( I_IP_LISTPRICE, 'FM9999G999G990D00' );
		else
			if
				I_IP_LISTPRICE = 0
			then
				L_AUSGABEZEILE := L_AUSGABEZEILE ||  '; ';
			else
				L_AUSGABEZEILE := L_AUSGABEZEILE ||  '; $' || to_char ( I_IP_LISTPRICE, 'FM9999G999G990D00' );
			end if;
		end if;
		end;

begin
	-- a) select SV - Damage_code - GUID
	select
		GUID_DAMAGE_CODE
	into
		L_GUID_DAMAGE_CODE
	from
		snt.TDAMAGE_CODE
	where
		DC_CODE = 'SV'
	; 

	-- b) ausgabe überschrift
	dbms_output.put_line ('INFO: ID_VERTRAG; ID_FZGVERTRAG; ID_SEQ_FZGRECHNUNG; FZGRE_BELEGNR; FZGRE_BELEGDATUM; newPOS_LABOUR; newPOS_PARTS; newPOS_OTHERS; corrHeader_OTHERS');
	dbms_output.put_line ('INFO: ---------------------------------------------------------------------------------------------------------------------------------------------');

	-- c) main select für finden differenzen
	-- eine differenz wird nur als solche 'anerkannt', wenn sie größer als 0,01 ist
	-- ein kleinerer wert wird als rundungsdifferenz akzeptiert
	-- dies gilt für alle checks
	for crec in (
		select
			r.ID_VERTRAG
			, r.ID_FZGVERTRAG
			, r.ID_SEQ_FZGRECHNUNG
			, r.FZGRE_BELEGNR
			, r.FZGRE_BELEGDATUM
			, r.GUID_PARTNER
			, r.FZGRE_AWSUMME
			, p.POS_AWSUMME
			, r.FZGRE_MATNETTO
			, p.POS_MATNETTO
			, r.FZGRE_SUM_OTHER
			, p.POS_SUM_OTHER
			, r.FZGRE_RESUMME
			, belart.BELART_INVOICE_OR_CNOTE
			, nvl ( p.COUNT_AWSUMME,   0 )	as COUNT_AWSUMME
			, nvl ( p.COUNT_MATNETTO,  0 )	as COUNT_MATNETTO
			, nvl ( p.COUNT_SUM_OTHER, 0 )	as COUNT_SUM_OTHER
			, nvl ( p.COUNT_POS_TOTAL, 0 )	as COUNT_POS_TOTAL
		from
			snt.TBELEGARTEN					belart
			, snt.TFZGRECHNUNG				r
			, snt.TDFCONTR_VARIANT				v
			, snt.TFZGV_CONTRACTS				c
			, ( 	select
					ID_SEQ_FZGRECHNUNG
					, sum	( decode ( IP_CARDTYPE, 11, nvl ( IP_LISTPRICE, 0 ), 0 ))	as POS_AWSUMME
					, sum	( decode ( IP_CARDTYPE, 12, nvl ( IP_LISTPRICE, 0 ), 0 ))	as POS_MATNETTO
					, sum   ( decode ( IP_CARDTYPE, 13, nvl ( IP_LISTPRICE, 0 ), 0 ))	as POS_SUM_OTHER
					, count ( decode ( IP_CARDTYPE, 11, IP_POSINDEX, null ))		as COUNT_AWSUMME
					, count ( decode ( IP_CARDTYPE, 12, IP_POSINDEX, null ))		as COUNT_MATNETTO
					, count ( decode ( IP_CARDTYPE, 13, IP_POSINDEX, null ))		as COUNT_SUM_OTHER
					, count (                           IP_POSINDEX        )		as COUNT_POS_TOTAL       
				from
					snt.TINV_POSITION
				group
					by ID_SEQ_FZGRECHNUNG
				)					p
		where
			r.ID_BELEGART           = belart.ID_BELEGART
			and r.ID_IMP_TYPE      not in ( 6, 10 )             -- MKS-127743:1:  6 = VEGA-I11 / 10 = VEGA-I56
			and r.ID_SEQ_FZGRECHNUNG    = p.ID_SEQ_FZGRECHNUNG (+)
			and r.ID_SEQ_FZGVC          = c.ID_SEQ_FZGVC
			and v.ID_COV                = c.ID_COV
			and v.COV_CAPTION    not like 'MIG_OOS%'
			and ( abs ( nvl ( r.FZGRE_AWSUMME,   0 )  - nvl ( p.POS_AWSUMME,   0 )) > 0.01 * nvl ( p.COUNT_AWSUMME,   0 )
				or abs ( nvl ( r.FZGRE_MATNETTO,  0 )  - nvl ( p.POS_MATNETTO,  0 )) > 0.01 * nvl ( p.COUNT_MATNETTO,  0 )
				or abs ( nvl ( r.FZGRE_SUM_OTHER, 0 )  - nvl ( p.POS_SUM_OTHER, 0 )) > 0.01 * nvl ( p.COUNT_SUM_OTHER, 0 )
				or abs ( nvl ( r.FZGRE_AWSUMME, 0 ) + nvl ( r.FZGRE_MATNETTO, 0 ) + nvl ( r.FZGRE_SUM_OTHER, 0 ) - nvl ( r.FZGRE_RESUMME, 0 )) > 0.01 * nvl ( p.COUNT_POS_TOTAL, 0 )
				or abs ( nvl ( p.POS_AWSUMME,   0 ) + nvl ( p.POS_MATNETTO,   0 ) + nvl ( p.POS_SUM_OTHER,   0 ) - nvl ( r.FZGRE_RESUMME, 0 )) > 0.01 * nvl ( p.COUNT_POS_TOTAL, 0 )
				)
		order by
			1, 2, 3
		)

	loop
		begin
			-- 0) zuordnen werte / reinstellen CO / main rechnungsdaten in ausgabezeile
			L_ID_SEQ_FZGRECHNUNG		:= crec.ID_SEQ_FZGRECHNUNG;
			L_FZGRE_BELEGDATUM		:= crec.FZGRE_BELEGDATUM;
			L_IP_POSINDEX			:= nvl ( get_max_IP_POSINDEX, 1 );
			L_BELART_INVOICE_OR_CNOTE	:= crec.BELART_INVOICE_OR_CNOTE;
			L_GUID_PARTNER			:= crec.GUID_PARTNER;
         
			L_AUSGABEZEILE := 'INFO: ' || crec.ID_VERTRAG || '; ' || crec.ID_FZGVERTRAG || '; ' || crec.ID_SEQ_FZGRECHNUNG || '; ' || crec.FZGRE_BELEGNR || '; ' || to_char ( crec.FZGRE_BELEGDATUM, 'DD.MM.YYYY' );

			-- 1) check arbeit:
			ins_TINV_POSITION ( I_IP_CARDTYPE  => 11
					, I_COUNT_POS    => crec.COUNT_AWSUMME
					, I_IP_LISTPRICE => nvl ( crec.FZGRE_AWSUMME, 0 ) - nvl ( crec.POS_AWSUMME, 0 )
					);

			-- 2) check teile:
			ins_TINV_POSITION ( I_IP_CARDTYPE  => 12
					, I_COUNT_POS    => crec.COUNT_MATNETTO
					, I_IP_LISTPRICE => nvl ( crec.FZGRE_MATNETTO, 0 ) - nvl ( crec.POS_MATNETTO, 0 )
					);

			-- 3) check sonstiges:
			-- die sonstiges - korrktur pos besteht aus
			-- A) differenz zwischen sonstiges - header zu pos
			-- B) plus differenz header - AW + Parts + Sonstiges zu header - gesamtbetrag
			ins_TINV_POSITION ( I_IP_CARDTYPE  => 13
					, I_COUNT_POS    => crec.COUNT_SUM_OTHER
					, I_IP_LISTPRICE => ( nvl ( crec.FZGRE_SUM_OTHER, 0 )	- nvl ( crec.POS_SUM_OTHER,   0 ))
												+ ( nvl ( crec.FZGRE_RESUMME,   0 ) - ( nvl ( crec.FZGRE_AWSUMME,   0 ) 
													+ nvl ( crec.FZGRE_MATNETTO,  0 )
													+ nvl ( crec.FZGRE_SUM_OTHER, 0 )
													)
												)
					);

			-- 4a) korrektur header - sonstiges - teilbetrag
			--	= differenz header - AW + Parts + Sonstiges zu header - gesamtbetrag
			--    ( -> 3B) von vorhin )
			L_SONST_HEADER_CORR := nvl ( crec.FZGRE_RESUMME, 0 ) - ( nvl ( crec.FZGRE_AWSUMME,   0 )  + nvl ( crec.FZGRE_MATNETTO,  0 ) + nvl ( crec.FZGRE_SUM_OTHER, 0 ));

			-- 4b) korrigieren OTHERS - headerbetrag
			if L_SONST_HEADER_CORR <> 0
			then
				update
					snt.TFZGRECHNUNG
				set
					FZGRE_SUM_OTHER		= nvl ( crec.FZGRE_SUM_OTHER, 0 ) + L_SONST_HEADER_CORR
				where
					ID_SEQ_FZGRECHNUNG	= crec.ID_SEQ_FZGRECHNUNG
				;

				L_AUSGABEZEILE := L_AUSGABEZEILE ||  '; ' || to_char ( L_SONST_HEADER_CORR, 'FM9999G999G990D00' );
			else
				L_AUSGABEZEILE := L_AUSGABEZEILE ||  '; ; ';
			end  if;
         
			-- schreiben ausgabezeile
			if
				substr ( L_AUSGABEZEILE, -12, 12 ) = '; ; ; ; '	-- für newPOS_LABOUR / newPOS_PARTS / newPOS_OTHERS / corrHeader_OTHERS wurden keine korrekturPos
			then 
				null;					-- eventuell wegen akzepierter rundungsdifferenzen bis 0,01 -> es werden dann auch keine werte protokolliert
			else
				dbms_output.put_line ( L_AUSGABEZEILE );
				:L_DATASUCCESS_OCCURED  := :L_DATASUCCESS_OCCURED + 1;
			end if;
		exception
			when others then
				dbms_output.put_line ( 'A unhandled error occured. - data set may be incomplete!' );
			        dbms_output.put_line (sqlerrm);
				:L_ERROR_OCCURED:= :L_ERROR_OCCURED+1;
		end;
	end loop;
end;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2nd: abschließender check: es darf keine rechnung mehr geben mit differenzen zwischen header und positionen und header - rechnungsgesamtbetrag
-- achtung: 
-- a) da wir vorhin bei AW / PARTS und OTHERS je 0,01 als rundungsdifferenz akzeptiert, und dafür keine korrekturpos angelegt haben, kann
-- es sein, daß wir jetzt im 'schlimmsten fall' beim check possumme gegen header - rechnungsgesamtbetrag eine max. differenz von 0,03 haben
-- b) bei den restlichen checks sind es nach wie vor je 0,01
--    (- den einzel - AW / PARTS / OTHERS checks header gegen positionen und beim header check AW / PARTS / OTHERS einzelwerte gegen header - rechnungsgesamtbetrag -)

declare
	l_ID_VERTRAG			varchar2 (50 char);
	l_ID_FZGVERTRAG			varchar2 (50 char);
	l_ID_SEQ_FZGRECHNUNG		varchar2 (50 char);
	l_FZGRE_BELEGNR			varchar2 (50 char);
	l_FZGRE_BELEGDATUM		varchar2 (50 char);
	l_GUID_PARTNER			varchar2 (50 char);
	l_FZGRE_AWSUMME			varchar2 (50 char);
	l_POS_AWSUMME			varchar2 (50 char);
	l_FZGRE_MATNETTO		varchar2 (50 char);
	l_POS_MATNETTO			varchar2 (50 char);
	l_FZGRE_SUM_OTHER		varchar2 (50 char);
	l_POS_SUM_OTHER			varchar2 (50 char);
	l_FZGRE_RESUMME			varchar2 (50 char);
	l_BELART_INVOICE_OR_CNOTE	varchar2 (50 char);
	l_COUNT_AWSUMME			varchar2 (50 char);
	l_COUNT_MATNETTO		varchar2 (50 char);
	l_COUNT_SUM_OTHER		varchar2 (50 char);
	l_COUNT_POS_TOTAL		varchar2 (50 char);	

	CURSOR cur_SELECT IS
		select
			r.ID_VERTRAG
			, r.ID_FZGVERTRAG
			, r.ID_SEQ_FZGRECHNUNG
			, r.FZGRE_BELEGNR
			, r.FZGRE_BELEGDATUM
			, r.GUID_PARTNER
			, r.FZGRE_AWSUMME
			, p.POS_AWSUMME
			, r.FZGRE_MATNETTO
			, p.POS_MATNETTO
			, r.FZGRE_SUM_OTHER
			, p.POS_SUM_OTHER
			, r.FZGRE_RESUMME
			, belart.BELART_INVOICE_OR_CNOTE
			, nvl ( p.COUNT_AWSUMME,   0 )	as COUNT_AWSUMME
			, nvl ( p.COUNT_MATNETTO,  0 )	as COUNT_MATNETTO
			, nvl ( p.COUNT_SUM_OTHER, 0 )	as COUNT_SUM_OTHER
			, nvl ( p.COUNT_POS_TOTAL, 0 )	as COUNT_POS_TOTAL
		from
			snt.TBELEGARTEN			belart
			, snt.TFZGRECHNUNG		r
			, snt.TDFCONTR_VARIANT		v
			, snt.TFZGV_CONTRACTS		c
			, ( select
				ID_SEQ_FZGRECHNUNG
				, sum	( decode ( IP_CARDTYPE, 11,	nvl ( IP_LISTPRICE, 0 ), 0 ))  as POS_AWSUMME
				, sum	( decode ( IP_CARDTYPE, 12,	nvl ( IP_LISTPRICE, 0 ), 0 ))  as POS_MATNETTO
				, sum	( decode ( IP_CARDTYPE, 13,	nvl ( IP_LISTPRICE, 0 ), 0 ))  as POS_SUM_OTHER
				, count	( decode ( IP_CARDTYPE, 11,	IP_POSINDEX, null ))  as COUNT_AWSUMME
				, count	( decode ( IP_CARDTYPE, 12,	IP_POSINDEX, null ))  as COUNT_MATNETTO
				, count	( decode ( IP_CARDTYPE, 13,	IP_POSINDEX, null ))  as COUNT_SUM_OTHER
				, count	(				IP_POSINDEX        )  as COUNT_POS_TOTAL       
			from
				snt.TINV_POSITION
			group by
				ID_SEQ_FZGRECHNUNG
			)				p
		where
			r.ID_BELEGART           = belart.ID_BELEGART
			and r.ID_IMP_TYPE      not in ( 6, 10 )             -- MKS-127743:1:  6 = VEGA-I11 / 10 = VEGA-I56
			and r.ID_SEQ_FZGRECHNUNG    = p.ID_SEQ_FZGRECHNUNG (+)
			and r.ID_SEQ_FZGVC          = c.ID_SEQ_FZGVC
			and v.ID_COV                = c.ID_COV
			and v.COV_CAPTION    not like 'MIG_OOS%'
			and ( abs ( nvl ( r.FZGRE_AWSUMME,   0 )  - nvl ( p.POS_AWSUMME,   0 )) > 0.01 * nvl ( p.COUNT_AWSUMME,   0 )
				or abs ( nvl ( r.FZGRE_MATNETTO,  0 )  - nvl ( p.POS_MATNETTO,  0 )) > 0.01 * nvl ( p.COUNT_MATNETTO,  0 )
				or abs ( nvl ( r.FZGRE_SUM_OTHER, 0 )  - nvl ( p.POS_SUM_OTHER, 0 )) > 0.01 * nvl ( p.COUNT_SUM_OTHER, 0 )
				or abs ( nvl ( r.FZGRE_AWSUMME, 0 ) + nvl ( r.FZGRE_MATNETTO, 0 ) + nvl ( r.FZGRE_SUM_OTHER, 0 ) - nvl ( r.FZGRE_RESUMME, 0 )) > 0.01 * nvl ( p.COUNT_POS_TOTAL, 0 )
				or abs ( nvl ( p.POS_AWSUMME,   0 ) + nvl ( p.POS_MATNETTO,   0 ) + nvl ( p.POS_SUM_OTHER,   0 ) - nvl ( r.FZGRE_RESUMME, 0 )) > 0.01 * nvl ( p.COUNT_POS_TOTAL, 0 ) 
				)
		order by
			1, 2, 3
		;

begin
	OPEN cur_SELECT;
	LOOP
		fetch cur_SELECT into 
			l_ID_VERTRAG
			, l_ID_FZGVERTRAG
			, l_ID_SEQ_FZGRECHNUNG
			, l_FZGRE_BELEGNR
			, l_FZGRE_BELEGDATUM
			, l_GUID_PARTNER
			, l_FZGRE_AWSUMME
			, l_POS_AWSUMME
			, l_FZGRE_MATNETTO
			, l_POS_MATNETTO
			, l_FZGRE_SUM_OTHER
			, l_POS_SUM_OTHER
			, l_FZGRE_RESUMME
			, l_BELART_INVOICE_OR_CNOTE
			, l_COUNT_AWSUMME
			, l_COUNT_MATNETTO
			, l_COUNT_SUM_OTHER
			, l_COUNT_POS_TOTAL
			;
		if cur_SELECT%NOTFOUND
		then
			if  cur_SELECT%ROWCOUNT <1
			then
				dbms_output.put_line ('All data cleansed. No more errors found.');
			end if;
			exit;
		end if;
		if cur_SELECT%ROWCOUNT = 1
		then
			dbms_output.put_line ('ERR: ID_VERTRAG/ID_FZGVERTRAG; ID_SEQ_FZGRECHNUNG; FZGRE_BELEGNR; FZGRE_BELEGDATUM; GUID_PARTNER; FZGRE_AWSUMME; POS_AWSUMME; FZGRE_MATNETTO; POS_MATNETTO; FZGRE_SUM_OTHER; POS_SUM_OTHER ; FZGRE_RESUMME; BELART_INVOICE_OR_CNOTE; COUNT_AWSUMME; COUNT_MATNETTO; COUNT_SUM_OTHER; COUNT_POS_TOTAL');
			dbms_output.put_line ('ERR: -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
		end if;
		dbms_output.put_line ('ERR: ' || l_ID_VERTRAG || '/' || l_ID_FZGVERTRAG || '; ' || l_ID_SEQ_FZGRECHNUNG || '; ' || l_FZGRE_BELEGNR || '; ' || l_FZGRE_BELEGDATUM || '; ' || l_GUID_PARTNER || '; ' || l_FZGRE_AWSUMME || '; ' ||  l_POS_AWSUMME || '; ' || l_FZGRE_MATNETTO || '; ' || l_POS_MATNETTO || '; ' || l_FZGRE_SUM_OTHER || '; ' || l_POS_SUM_OTHER || '; ' || l_FZGRE_RESUMME || '; ' || l_BELART_INVOICE_OR_CNOTE || '; ' || l_COUNT_AWSUMME || '; ' || l_COUNT_MATNETTO || '; ' || l_COUNT_SUM_OTHER || '; ' || l_COUNT_POS_TOTAL );
		:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED + 1;
	END LOOP;
	close cur_SELECT;

	exception
		when others then
			dbms_output.put_line ( 'A unhandled error occured. - displayed data may be incomplete!' );
		        dbms_output.put_line (sqlerrm);
			:L_ERROR_OCCURED:= :L_ERROR_OCCURED+1;

end;
/


--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   :L_ERROR_OCCURED  = 0 and (upper ( '&&commit_or_rollback' ) = 'Y' OR upper ( '&&commit_or_rollback' ) = 'AUTOCOMMIT')
   then commit;
        snt.SRS_LOG_MAINTENANCE_SCRIPTS ( :L_SCRIPTNAME );
        :nachricht := 'Data saved into the DB';
   else rollback;
        :nachricht := 'DB Data not changed';
   end  if;
end;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- < enable again all perhaps in step 0 disabled constraints or triggers >
alter trigger    IP_NO_UPD_DEL       enable;
alter trigger    TRIG_TINV_POS_MAIN  enable;
alter trigger    EXT_TINV_POSITION   enable;
alter trigger    FZGRE_NO_UPD_DEL    enable;

--===================================================================================================================================
--===================================================================================================================================
-- ################################################################################################
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- report final / finished message and exit
set termout  on

begin
 if upper('&&GL_LOGFILETYPE')<>'CSV' then
   dbms_output.put_line ( chr(10)||'finished.'||chr(10) );
 end if;
 
 dbms_output.put_line ( :nachricht );
 
 if upper('&&GL_LOGFILETYPE')<>'CSV' then

  dbms_output.put_line (chr(10));
  dbms_output.put_line ('Please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile &&GL_SCRIPTNAME..&&GL_LOGFILETYPE');
  dbms_output.put_line (chr(10));
  dbms_output.put_line ('MANAGEMENT SUMMARY');
  dbms_output.put_line ('==================');
  dbms_output.put_line ('Dataset affected: ' || :L_DATASUCCESS_OCCURED);
  dbms_output.put_line ('Data warnings   : ' || :L_DATAWARNINGS_OCCURED);
  dbms_output.put_line ('Data errors     : ' || :L_DATAERRORS_OCCURED);
  dbms_output.put_line ('System errors   : ' || :L_ERROR_OCCURED);

 end if;
end;
/
exit;
