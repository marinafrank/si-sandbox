-- 20121229_showGroupsInVehicleContracts_V1.0.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- FraBe  29.12.2012 MKS-121059:1 creation
-- FraBe  31.12.2012 MKS-121059:2 add ID_FZGVERTRAG_concat2 logik, wenn es mehr ID_FZGVERTRAG gibt, die  nicht mehr in ID_FZGVERTRAG_concat1 platz haben
-- 2014-05-16; MARZUHL; V1.0; MKS-132432:2; Changed to new output format / framework

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= 20121229_showGroupsInVehicleContracts_V1.0
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

-- main part for < selecting or checking or correcting code >

col ID_VERTRAG         form a15
col VEHL_CAPTION       form a20
col FZGA_CAPTION       form a40
col BAL1_SHORT_CAPTION form a25
col BAL2_CAPTION       form a20
col BAL3_CAPTION       form a20
col SCAT_CAPTION       form a20

break on ID_VERTRAG skip 1 duplicates

declare 
     OLD_ID_VERTRAG           snt.TFZGVERTRAG.ID_VERTRAG%type;
     OLD_ID_FZGVERTRAG        snt.TFZGVERTRAG.ID_FZGVERTRAG%type;
     OLD_VEHL_CAPTION         snt.TVEHICLE_LINE.VEHL_CAPTION%type;              --  b) Line des META-Paketes
     OLD_ID_GARAGE            snt.TFZGVERTRAG.ID_GARAGE%type;                   --  c) vertragsgebende Werkstatt
     OLD_NAME_MATCHCODE       snt.VADRASSOZ.NAME_MATCHCODE%type;
     OLD_FZGA_CAPTION         snt.TFAHRZEUGART.FZGA_CAPTION%type;               --  d) Fahrzeugart (TFAHRZEUGART)
     OLD_BAL1_SHORT_CAPTION   snt.TBUSINESS_AREA_L1.BAL1_SHORT_CAPTION%type;    --  e) TBUSINESS_AREA_L1
     OLD_BAL2_CAPTION         snt.TBUSINESS_AREA_L2.BAL2_CAPTION%type;          --  f) TBUSINESS_AREA_L2
     OLD_BAL3_CAPTION         snt.TBUSINESS_AREA_L3.BAL3_CAPTION%type;          --  g) TBUSINESS_AREA_L3
     OLD_SCAT_CAPTION         snt.TSCARF_CATEGORY.SCAT_CAPTION%type;            --  h) TSCARF_CATEGORY
     
     L_ID_FZGVERTRAG_concat1  varchar2 ( 32000 char );        
     L_ID_FZGVERTRAG_concat2  varchar2 ( 32000 char );        -- für all jene ID_FZGVERTRAG, die nicht in der ersten var platz haben
     L_ANZAHL                 integer  := 0;                  -- anzahl per group by values
     
     L_GESAMT_ANZAHL          integer  := 0;                  -- anzahl aller reported CO
     
     procedure print_line is
     begin
          dbms_output.put_line
                    ( rpad (       OLD_ID_VERTRAG,                    16, ' ' )
                   || rpad ( nvl ( OLD_VEHL_CAPTION,           ' ' ), 21, ' ' )
                   || lpad ( nvl ( to_char ( OLD_ID_GARAGE ),  ' ' ),  9, ' ' ) || ' '
                   || rpad ( nvl ( OLD_NAME_MATCHCODE,         ' ' ), 51, ' ' )
                   || rpad ( nvl ( OLD_FZGA_CAPTION,           ' ' ), 41, ' ' )
                   || rpad ( nvl ( OLD_BAL1_SHORT_CAPTION,     ' ' ), 26, ' ' )
                   || rpad ( nvl ( OLD_BAL2_CAPTION,           ' ' ), 21, ' ' )
                   || rpad ( nvl ( OLD_BAL3_CAPTION,           ' ' ), 21, ' ' )
                   || rpad ( nvl ( OLD_SCAT_CAPTION,           ' ' ), 21, ' ' )
                   || lpad (       to_char ( L_ANZAHL ),               6, ' ' ) || ' '
                   ||              L_ID_FZGVERTRAG_concat1 );
                   
          if   L_ID_FZGVERTRAG_concat2 is not null
          then dbms_output.put_line ( lpad ( ' ', 236, ' ' ) || L_ID_FZGVERTRAG_concat2 );
          end  if;
                   
          L_GESAMT_ANZAHL := L_GESAMT_ANZAHL + 1;
          
     end;
     
begin
     dbms_output.put_line ( 'ID_VERTRAG      VEHL_CAPTION         ID_GARAGE NAME_MATCHCODE                                     FZGA_CAPTION                             BAL1_SHORT_CAPTION        BAL2_CAPTION         BAL3_CAPTION         SCAT_CAPTION          COUNT ID_FZGVERTRAG' );
     dbms_output.put_line ( '--------------- -------------------- --------- -------------------------------------------------- ---------------------------------------- ------------------------- -------------------- -------------------- -------------------- ------ -------------------------------------------------------------------------------------------------------------------------------------------------' );
     
     for crec in ( select fzgv.ID_VERTRAG
                        , fzgv.ID_FZGVERTRAG
                        , vl.VEHL_CAPTION
                        , fzgv.ID_GARAGE
                        , vadr.NAME_MATCHCODE
                        , fart.FZGA_CAPTION
                        , bal1.BAL1_SHORT_CAPTION
                        , bal2.BAL2_CAPTION
                        , bal3.BAL3_CAPTION
                        , scarf.SCAT_CAPTION
                     from snt.VADRASSOZ              vadr
                        , snt.TGARAGE                gar
                        , snt.TVEHICLE_LINE          vl
                        , snt.TIC_PACKAGE            pack
                        , snt.TIC_CO_PACK_ASS        pass
                        , snt.TSCARF_CATEGORY        scarf
                        , snt.TBUSINESS_AREA_L3      bal3     
                        , snt.TBUSINESS_AREA_L2      bal2     
                        , snt.TBUSINESS_AREA_L1      bal1     
                        , snt.TFAHRZEUGART           fart     
                        , snt.TTYPGRUPPE             tg     
                        , snt.TFAHRZEUGTYP           ftyp     
                        , snt.TFZGVERTRAG            fzgv
                    where not exists ( select null 
                                         from snt.TDFCONTR_VARIANT cvar
                                            , snt.TFZGV_CONTRACTS  fzgvc
                                        where fzgv.ID_VERTRAG      = fzgvc.ID_VERTRAG
                                          and fzgv.ID_FZGVERTRAG   = fzgvc.ID_FZGVERTRAG
                                          and cvar.ID_COV          = fzgvc.ID_COV
                                          and cvar.COV_CAPTION  like 'MIG_OOS%' )
                      and vadr.ID_SEQ_ADRASSOZ       = gar.ID_SEQ_ADRASSOZ
                      and fzgv.ID_GARAGE             = gar.ID_GARAGE
                      and fzgv.ID_FZGTYP             = ftyp.ID_FZGTYP
                      and fzgv.GUID_CONTRACT         = pass.GUID_CONTRACT
                      and pack.GUID_PACKAGE          = pass.GUID_PACKAGE
                      and pack.ICP_PACKAGE_TYPE      = 2
                      and pack.GUID_VEHICLE_LINE     = vl.GUID_VEHICLE_LINE
                      and fart.GUID_BUSINESS_AREA_L1 = bal1.GUID_BUSINESS_AREA_L1
                      and fart.GUID_BUSINESS_AREA_L2 = bal2.GUID_BUSINESS_AREA_L2
                      and fart.GUID_BUSINESS_AREA_L3 = bal3.GUID_BUSINESS_AREA_L3
                      and fart.GUID_SCARF_CATEGORY   = scarf.GUID_SCARF_CATEGORY
                      and fart.ID_FAHRZEUGART        = tg.ID_FAHRZEUGART
                      and ftyp.ID_TYPGRUPPE          = tg.ID_TYPGRUPPE
                      order by 1, 3, 4, 5, 6, 7, 8, 9, 10, 2 )
        loop

            if             OLD_ID_VERTRAG               is null                           -- OLD_ID_VERTRAG ist leer ganz am anfang
              or (         OLD_ID_VERTRAG                = crec.ID_VERTRAG                -- kein group by wert hat sich geändert
                 and nvl ( OLD_VEHL_CAPTION,       ' ' ) = nvl ( crec.VEHL_CAPTION,       ' ' ) 
                 and nvl ( OLD_ID_GARAGE,           -1 ) = nvl ( crec.ID_GARAGE,           -1 ) 
                 and nvl ( OLD_FZGA_CAPTION,       ' ' ) = nvl ( crec.FZGA_CAPTION,       ' ' ) 
                 and nvl ( OLD_BAL1_SHORT_CAPTION, ' ' ) = nvl ( crec.BAL1_SHORT_CAPTION, ' ' ) 
                 and nvl ( OLD_BAL2_CAPTION,       ' ' ) = nvl ( crec.BAL2_CAPTION,       ' ' ) 
                 and nvl ( OLD_BAL3_CAPTION,       ' ' ) = nvl ( crec.BAL3_CAPTION,       ' ' ) 
                 and nvl ( OLD_SCAT_CAPTION,       ' ' ) = nvl ( crec.SCAT_CAPTION,       ' ' )) 
            then -- noch kein print_line, da sich die group by werte nicht geändert haben / bzw. OLD_ID_VERTRAG leer ist, weil erste loop - durchführung
                 -- stattdessen wert für anzahl erhöhen, und die ID_FZGVERTRAG zu den vorherigen (- mit selben group by werten -) dazustellen
                 L_ANZAHL := L_ANZAHL + 1;                                                
            
                 -- die ersten 32000 zeichen werden in concat1 gestellt, die restlichen in concat2
                 if   length ( L_ID_FZGVERTRAG_concat1 ) + length ( crec.ID_FZGVERTRAG ) + 1 > 31998
                   or length ( L_ID_FZGVERTRAG_concat2 ) > 0
                 then if   length ( L_ID_FZGVERTRAG_concat2 ) > 0
                      then L_ID_FZGVERTRAG_concat2 := L_ID_FZGVERTRAG_concat2 || '/';
                      else L_ID_FZGVERTRAG_concat1 := L_ID_FZGVERTRAG_concat1 || '/';
                      end  if;
                      
                      L_ID_FZGVERTRAG_concat2 := L_ID_FZGVERTRAG_concat2 || crec.ID_FZGVERTRAG;
                      
                 else if   length ( L_ID_FZGVERTRAG_concat1 ) > 0
                      then L_ID_FZGVERTRAG_concat1 := L_ID_FZGVERTRAG_concat1 || '/';
                      end  if;
                      
                      L_ID_FZGVERTRAG_concat1 := L_ID_FZGVERTRAG_concat1 || crec.ID_FZGVERTRAG;
                 end  if;
                 
                 OLD_ID_VERTRAG := crec.ID_VERTRAG;
                    
                 
            else if   L_ANZAHL > 1   -- eins von den group by werten hat sich geändert -> daher ausgabe zeile. 
                                     -- aber nur dann, wenn vorher mehr als 1 CO mit den vorherigen group by werten gefunden wurde
                 then print_line;
                      
                      if   OLD_ID_VERTRAG <> crec.ID_VERTRAG  -- simuliert ein sqlplus break on ID_VERTRAG skip 2 
                      then dbms_output.put_line ( chr(10) );  -- (-> wird aber nur dann gemacht, wenn die neue ID_VERTRAG einen anderen wert hat, als die alte )
                      end  if;

                 end  if;
                 
                 -- neue werte rüberstellen in alte group by variablen
                 OLD_ID_VERTRAG          := crec.ID_VERTRAG;
                 OLD_VEHL_CAPTION        := crec.VEHL_CAPTION;
                 OLD_ID_GARAGE           := crec.ID_GARAGE;
                 OLD_NAME_MATCHCODE      := crec.NAME_MATCHCODE;
                 OLD_FZGA_CAPTION        := crec.FZGA_CAPTION;
                 OLD_BAL1_SHORT_CAPTION  := crec.BAL1_SHORT_CAPTION;
                 OLD_BAL2_CAPTION        := crec.BAL2_CAPTION;
                 OLD_BAL3_CAPTION        := crec.BAL3_CAPTION;
                 OLD_SCAT_CAPTION        := crec.SCAT_CAPTION;
                 
                 L_ANZAHL                := 1;
                 L_ID_FZGVERTRAG_concat1 := crec.ID_FZGVERTRAG;
                 L_ID_FZGVERTRAG_concat2 := '';
                 
            end  if;
        end loop;
        
        -- nach der loop schlaufe kann es sein, daß noch eine zeile auszugeben ist
        if   L_ANZAHL > 1
        then print_line;
        end  if;
     
	-- report wieviele zeilen geschrieben wurden
	dbms_output.put_line ( chr(10) );
	:L_DATAWARNINGS_OCCURED := :L_DATAWARNINGS_OCCURED + to_number( L_GESAMT_ANZAHL );
	if L_GESAMT_ANZAHL < 1 then
		dbms_output.put_line ('No data warnings found.');
	end if;

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
-- < alter table snt.TFZGVERTRAG modify constraint FZGT_ID_FZGV enable validate; )

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
