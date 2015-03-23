-- DataCleansing_040_LOP2803-ImportSalesAftersalesInformations.sql
-- This script ACCEPTS as Input Parameter 1 'Y' or 'N' or 'AUTOCOMMIT' to automate the Simulation Mode.
-- Please keep in mind if you are accepting more input parameters!
-- FraBe     18.12.2013 MKS-130075:1 / LOP2803 
-- 2014-05-16; MARZUHL; V1.0; MKS-132567:1; Changed to new output format / framework
-- 2014-05-20; MARZUHL; V1.1; MKS-132567:1; "alter trigger SNT.IP_NO_UPD_DEL disable/enable;" as discussed with TK.

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

-- SCRIPT PARAMETERIZATION TO BE MAINTAINED FOR EACH SCRIPT
--
--

   -- file name for script and logfile
   define GL_SCRIPTNAME		= DataCleansing_040_LOP2803-ImportSalesAftersalesInformations
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
alter trigger SNT.IP_NO_UPD_DEL disable;
set feedback     on
set feedback     1

-- main part for < selecting or checking or correcting code >

declare

	L_FZGV_BEARBEITER_KAUF   snt.TFZGVERTRAG.FZGV_BEARBEITER_KAUF%type;

	procedure change_data 
		( I_FZGV_BEARBEITER_KAUF	snt.TFZGVERTRAG.FZGV_BEARBEITER_KAUF%type
		, I_TYPE			varchar2
		) is
            
		L_ANZAHL                 number := 0;

		begin

			L_ANZAHL := 0;

			dbms_output.put_line ( chr(13) );
                  
			for crec in (
				select
					ID_VERTRAG
					, ID_FZGVERTRAG
					, FZGV_BEARBEITER_KAUF
					, FZGV_BEARBEITER_TECH
					, ROWID					as ROW_ID
				from
					snt.TFZGVERTRAG				fzgv
				where
					upper ( FZGV_BEARBEITER_KAUF )	= upper ( I_FZGV_BEARBEITER_KAUF )
					and exists ( 
						select 
							null 
						from 
							snt.TFZGV_CONTRACTS	fzgvc
							, snt.TDFCONTR_VARIANT	cvar
						where
							fzgv.ID_VERTRAG		= fzgvc.ID_VERTRAG
							and fzgv.ID_FZGVERTRAG      = fzgvc.ID_FZGVERTRAG
							and cvar.ID_COV             = fzgvc.ID_COV
							and cvar.COV_CAPTION not like 'MIG_OOS%' 
						)
				order by
					3, 4
				)
			loop
				begin
					update
						snt.TFZGVERTRAG		fzgv
					set
						FZGV_BEARBEITER_TECH	= I_TYPE
					where
						ROWID			= crec.ROW_ID
					;

					dbms_output.put_line ( 'InScope contract ' || lpad ( crec.ID_VERTRAG, 6, ' ' ) || '/' || rpad ( crec.ID_FZGVERTRAG, 4, ' ' )
								|| ' with salesman ' || rpad ( crec.FZGV_BEARBEITER_KAUF, 37, ' ' ) || ' changed from ' 
								|| rpad ( nvl ( crec.FZGV_BEARBEITER_TECH, 'NULL' ), 6, ' ' ) || ' to sales' );
					:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;
					L_ANZAHL := L_ANZAHL + 1;

				exception
					when others then
						:L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
						dbms_output.put_line ( 'ERR: Problems while processing ' || crec.ID_VERTRAG || '/' || crec.ID_FZGVERTRAG);
						dbms_output.put_line ( SQLERRM );
				end;
			end loop;
			if L_ANZAHL = 0 then
				dbms_output.put_line ( 'No InScope contract(s) found for following in excel file defined salesman: ' || I_FZGV_BEARBEITER_KAUF );
			end if;
         
		end;

begin

	--- 1) zuerst werden die zeilen aus dem MKS-130075 attachment LOP2803 Users iQUOTE with sales channel.xlsx verarbeitet.
	--- da afterSales lt. Description im MKS sowieso der defaultwert ist, brauchen nur die sales geladen zu werden, die afterSales nicht:
	dbms_output.put_line ( '1st: set sales:' );
	---               I_FZGV_BEARBEITER_KAUF                  I_TYPE
   --- change_data ( 'Gryseels, Minne (MGRYSEE)',            'afterSales' );
   --- change_data ( 'Frooninckx, Andrea (ACLOETE)',         'afterSales' );
   --- change_data ( 'Coose, Dirk (DCOOSE)',                 'afterSales' );
   --- change_data ( 'El Houch, Sidi Mohamed (MELHOUC)',     'afterSales' );
   --- change_data ( 'Joye, Monique (MGODART)',              'afterSales' );
   --- change_data ( 'Selleslagh, Nadine (NSELLES)',         'afterSales' );
   --- change_data ( 'Verdickt, Nancy (NVERDIC)',            'afterSales' );
   --- change_data ( 'Geerts, Walter (WGEERTS)',             'afterSales' );
       change_data ( 'Desmet, Anthony (d5adesme)',           'sales'      );
   --- change_data ( 'De Vos, Arnaud (D5ADEVOS)',            'afterSales' );
   --- change_data ( 'Bonamie, Cedric (d5bonamc)',           'afterSales' );
       change_data ( 'Haces Corces, Daniel (d5dhaces)',      'sales'      );
       change_data ( 'Sebastien, Delo (D5DSEBAS)',           'sales'      );
       change_data ( 'Verbaanderd, Gunther (d5gverba)',      'sales'      );
       change_data ( 'Gauche, Hubert (d5hgauch)',            'sales'      );
   --- change_data ( 'Van Leeuw, Harry (d5hvanle)',          'afterSales' );
       change_data ( 'Vander Stappen, Ivan (d5ivvand)',      'sales'      );
       change_data ( 'Dero, Jean-Francois (d5jeader)',       'sales'      );
       change_data ( 'Martinelle, Jean-Louis (d5jeanlm)',    'sales'      );
   --- change_data ( 'Müllender, Jean-Francois (d5jeanmu)',  'afterSales' );
   --- change_data ( 'Vanden Eynde, Johannes (d5johava)',    'afterSales' );
       change_data ( 'Muir, Johan (D5JOMUIR)',               'sales'      );
   --- change_data ( 'Tanésy, Joris (d5jtanes)',             'afterSales' );
   --- change_data ( 'Eeckeleers, Karel (d5keecke)',         'afterSales' );
       change_data ( 'Peeters, Kris (d5kpeete)',             'sales'      );
       change_data ( 'Somers, Marc (d5masome)',              'sales'      );
   --- change_data ( 'Hammadi, Mehdi (d5mehamm)',            'afterSales' );
   --- change_data ( 'Goemans, Matthias (d5mgoema)',         'afterSales' );
       change_data ( 'Gaye, Michel (d5migaye)',              'sales'      );
   --- change_data ( 'Bodson, Olga (d5obodso)',              'afterSales' );
       change_data ( 'Cattrysse, Olivier (d5ocattr)',        'sales'      );
   --- change_data ( 'Herion, Pierre-Yves (d5pherio)',       'afterSales' );
       change_data ( 'Neuhuys, Patrick (d5pneuhu)',          'sales'      );
   --- change_data ( 'De Plaen, Romain (d5rdepla)',          'afterSales' );
   --- change_data ( 'De Maere, Sabrina (D5SDEMAE)',         'afterSales' );
       change_data ( 'Evenepoel, Sebastien (d5sevene)',      'sales'      );
       change_data ( 'Vaes, Steven (d5svaes)',               'sales'      );
   --- change_data ( 'Van den Broeck, Johan (d5vajoha)',     'afterSales' );
       change_data ( 'De Keyser, Vanessa (d5vdekey)',        'sales'      );
       change_data ( 'Nerincx, Vincent (d5vnerin)',          'sales'      );
   --- change_data ( 'Borghgraef, Yves (d5yborgh)',          'afterSales' );
       change_data ( 'Comper, Yves Pierre (d5ycompe)',       'sales'      );
       change_data ( 'Weytjens, Wouter (WWEYTJE)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Regnier, Denis (d5dregni)',            'afterSales' );
   --- change_data ( 'De Fresart, Etienne (d5edefre)',       'afterSales' );
   --- change_data ( 'De Brauwere, Guy (d5gdebra)',          'afterSales' );
   --- change_data ( 'Humblet, Guy (d5ghumbl)',              'afterSales' );
   --- change_data ( 'Kirschfink, Jacqueline (d5jkirsc)',    'afterSales' );
       change_data ( 'Adam, Patrick (d5paadam)',             'sales'      );
       change_data ( 'Pierlot, Pierre (d5ppierl)',           'sales'      );
   --- change_data ( 'Kever, Rudi (d5rkever)',               'afterSales' );
       change_data ( 'Asrihi, Amal (d5aasrih)',              'sales'      );
   --- change_data ( 'Lauwrensens, Daniel (d5dlauwr)',       'afterSales' );
   --- change_data ( 'Bartolomucci, Elio (d5elbart)',        'afterSales' );
       change_data ( 'Hermans, William (D5HERMAW)',          'sales'      );
   --- change_data ( 'Ghiouar, Jaffar (D5JGHIOU)',           'afterSales' );
   --- change_data ( 'Haddad, Mariana (d5mhadda)',           'afterSales' );
       change_data ( 'D''hoe, Sam (d5sadhoe)',               'sales'      );
       change_data ( 'Lecointre, Steve (D5SLECOI)',          'sales'      );
   --- change_data ( 'Soudan, Stephanie (d5ssouda)',         'afterSales' );
   --- change_data ( 'Van Driessche, Bart (d5bvandr)',       'afterSales' );
   --- change_data ( 'Vansteenkiste, Bjorn (d5bvanst)',      'afterSales' );
   --- change_data ( 'Desmedt, Christophe (d5cdesme)',       'afterSales' );
   --- change_data ( 'Vanderbeke, Chris (d5chvand)',         'afterSales' );
       change_data ( 'Baes, Dominique (d5dbaes)',            'sales'      );
       change_data ( 'Dugardyn, Dominique (d5ddugar)',       'sales'      );
       change_data ( 'De Paepe, Sabine (D5DEPAES)',          'sales'      );
       change_data ( 'Van Hoorebeke, Dirk (D5DIVANH)',       'sales'      );
   --- change_data ( 'Haezaert, Fabian (d5fhaeza)',          'afterSales' );
   --- change_data ( 'Derycker, Frank (d5frankd)',           'afterSales' );
       change_data ( 'Van Lierde, Frederic (d5freder)',      'sales'      );
       change_data ( 'Bracke, Kris (D5KBRACK)',              'sales'      );
   --- change_data ( 'Craeye, Kurt (d5kcraey)',              'afterSales' );
       change_data ( 'Claeys, Ludovic (d5lclaey)',           'sales'      );
       change_data ( 'Joye, Matthias (d5mjoye)',             'sales'      );
   --- change_data ( 'Rabaey, Pascal (d5paraba)',            'afterSales' );
   --- change_data ( 'De Baecke, Peter (d5pdebae)',          'afterSales' );
       change_data ( 'Haelman, Peter (d5phaelm)',            'sales'      );
       change_data ( 'Dekeyzer, Thomas (D5TDEKEY)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Carlier, Luc (D5CARLIL)',              'sales'      );
   --- change_data ( 'Eeckhout, Hans (d5heeckh)',            'afterSales' );
   --- change_data ( 'Houck, Jos (d5jhouck)',                'afterSales' );
   --- change_data ( 'Balduyck, Sabine (d5sbaldu)',          'afterSales' );
       change_data ( 'Descamps, Stefanie (d5sdesca)',        'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Wijnants, Dave (d5dwijna)',            'sales'      );
       change_data ( 'Schulpen, Filip (d5fischu)',           'sales'      );
       change_data ( 'Van Santvoort, Frederik (D5FVANSA)',   'sales'      );
       change_data ( 'Smets, Jan (d5jsmets)',                'sales'      );
       change_data ( 'Lenaerts, Jurgen (D5LENAEJ)',          'sales'      );
       change_data ( 'Sollie, Michel (d5msolli)',            'sales'      );
   --- change_data ( 'Stulemeijer, Alain (d5astuel)',        'afterSales' );
       change_data ( 'Gigeys, David (d5dgigey)',             'sales'      );
       change_data ( 'Melkenbeek, Dirk (d5dmelke)',          'sales'      );
   --- change_data ( 'Standaert, Didier (d5dstand)',         'afterSales' );
       change_data ( 'Sandro, Gonzalez (d5gonsan)',          'sales'      );
       change_data ( 'Van Eycken, Guy (d5gvaney)',           'sales'      );
       change_data ( 'Museur, Ignace (d5imuseu)',            'sales'      );
   --- change_data ( 'Perez, Ismaël (d5iperez)',             'afterSales' );
   --- change_data ( 'Durel, Jean-François (d5jdurel)',      'afterSales' );
   --- change_data ( 'Huysmans, Jean-Pierre (d5jehuys)',     'afterSales' );
   --- change_data ( 'Oostermeyer, Jozef (d5jooste)',        'afterSales' );
   --- change_data ( 'Luca, Giuseppe (d5lguise)',            'afterSales' );
   --- change_data ( 'Ginion, Mario (d5mginio)',             'afterSales' );
   --- change_data ( 'Michaux, Marc (d5mmicha)',             'afterSales' );
   --- change_data ( 'Zwaab, Michèle (d5mzwaab)',            'afterSales' );
       change_data ( 'Bon, Olivier (d5olibon)',              'sales'      );
   --- change_data ( 'Segers, Olivier (d5olsege)',           'afterSales' );
       change_data ( 'Baert, Patrick (d5pbaert)',            'sales'      );
       change_data ( 'Forgeur, Philippe (d5pforge)',         'sales'      );
   --- change_data ( 'Hardat, Patrick (d5pharda)',           'afterSales' );
   --- change_data ( 'Michiels, Patrick (d5pmichi)',         'afterSales' );
       change_data ( 'Schot, Patrick (d5pschot)',            'sales'      );
       change_data ( 'Thielemans, Raf (d5rthiel)',           'sales'      );
       change_data ( 'Duterme, Sebastien (d5sduter)',        'sales'      );
   --- change_data ( 'Hendrickx, Steve (d5shendr)',          'afterSales' );
   --- change_data ( 'Mahy, Sebastien (d5smahy)',            'afterSales' );
       change_data ( 'Parewyck, Stéphane (D5SPAREW)',        'sales'      );
       change_data ( 'Magits, Ugo (d5umagit)',               'sales'      );
       change_data ( 'Turkoz, Vahdettia (D5VTURKO)',         'sales'      );
       change_data ( 'Decuyper, Yvo (d5ydecuy)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Dederix, Benoit (d5bdeder)',           'afterSales' );
   --- change_data ( 'Henry, Emmanuel (d5emhenr)',           'afterSales' );
   --- change_data ( 'Piccart, Fabian (d5fpicca)',           'afterSales' );
       change_data ( 'Gramme, Jean-François (d5jgramm)',     'sales'      );
       change_data ( 'Uyttebrock, Laurent (d5luytte)',       'sales'      );
   --- change_data ( 'Gerkens, Marc (d5mgerke)',             'afterSales' );
   --- change_data ( 'Henry, Murielle (d5mhenry)',           'afterSales' );
   --- change_data ( 'Klejniak, Maxime (d5mklejn)',          'afterSales' );
   --- change_data ( 'Vaz, Marie-Louise (d5mvaz)',           'afterSales' );
   --- change_data ( 'Decelle, Renaud (d5rdecel)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Suys, Denis (d5desuys)',               'sales'      );
       change_data ( 'Castellana, Fabrice (d5facast)',       'sales'      );
   --- change_data ( 'Jurion, Isabelle (d5ijurio)',          'afterSales' );
   --- change_data ( 'Laurent, Joris (d5jlaure)',            'afterSales' );
       change_data ( 'Thirion, Jean-Pascal (d5jthiri)',      'sales'      );
   --- change_data ( 'La Barbera, Massimo (d5malaba)',       'afterSales' );
   --- change_data ( 'Piret, Olivier (d5opiret)',            'afterSales' );
   --- change_data ( 'Bouchez, Pascal (d5pabouc)',           'afterSales' );
   --- change_data ( 'Vanderbeck, Roger (d5rogvan)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Lenssen, Andi (d5alenss)',             'sales'      );
   --- change_data ( 'Seys, Carl (d5cseys)',                 'afterSales' );
       change_data ( 'De Meyer, Dirk (d5ddemey)',            'sales'      );
   --- change_data ( 'Mertens, Frans (d5fmerte)',            'afterSales' );
       change_data ( 'Wiels, Frederic (d5fwiels)',           'sales'      );
   --- change_data ( 'Vermeulen, Gunter (d5guverm)',         'afterSales' );
       change_data ( 'Devriendt, Ivan (d5idevri)',           'sales'      );
       change_data ( 'Temmerman, Jonas (d5jtemme)',          'sales'      );
       change_data ( 'thyssen, jens (d5jthyss)',             'sales'      );
   --- change_data ( 'Vos, Juan-Pablo (d5jvos)',             'afterSales' );
   --- change_data ( 'Tondeurs, Louis (d5ltonde)',           'afterSales' );
   --- change_data ( 'Gowie, Michel (d5mgowie)',             'afterSales' );
   --- change_data ( 'Van Moorleghem, Olivier (d5ovanmo)',   'afterSales' );
   --- change_data ( 'Van Eeckhoven, Rudi (d5ruvane)',       'afterSales' );
   --- change_data ( 'vandersypt, saskia (d5sasvan)',        'afterSales' );
       change_data ( 'Somerlinck, Thomas (D5SOMERT)',        'sales'      );
       change_data ( 'Van Hoorebeke, Jessica (D5VANHJE)',    'sales'      );
       change_data ( 'Van der Borght, Jan (d5vanjan)',       'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Kesseler, David (d5dkesse)',           'sales'      );
       change_data ( 'Jost, Karl-Heinz (d5kajost)',          'sales'      );
   --- change_data ( 'Roehl, Ludwig (d5lroehl)',             'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Kalscheuer, Andreas (d5akalsc)',       'afterSales' );
   --- change_data ( 'Rutte, Berti (d5brutte)',              'afterSales' );
   --- change_data ( 'Hursel, Frank (d5fhurse)',             'afterSales' );
   --- change_data ( 'Pankert, Georg (d5gpanke)',            'afterSales' );
   --- change_data ( 'Schmetz, Jean-marie (d5jeschm)',       'afterSales' );
   --- change_data ( 'Schumacher, Melanie (d5mschum)',       'afterSales' );
       change_data ( 'Dejalle, Philippe (d5pdejal)',         'sales'      );
   --- change_data ( 'Kever, Rudi (d5rkever)',               'afterSales' );
   --- change_data ( 'Cormann, Veronique (d5vcorma)',        'afterSales' );
       change_data ( 'Pinckaers, Willy (d5wpinck)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Swaab, Bénédicte (d5bswaab)',          'afterSales' );
       change_data ( 'Moineau, Christophe (d5cmoine)',       'sales'      );
       change_data ( 'Stassen, Eric (d5estass)',             'sales'      );
       change_data ( 'Dheur, François (d5fdheur)',           'sales'      );
       change_data ( 'Ancion, Jean-Jacques (d5jancio)',      'sales'      );
       change_data ( 'Jerusalem, Laurent (d5ljerus)',        'sales'      );
   --- change_data ( 'Gerkens, Marc (d5mgerke)',             'afterSales' );
   --- change_data ( 'Henry, Murielle (d5mhenry)',           'afterSales' );
   --- change_data ( 'Klejniak, Maxime (d5mklejn)',          'afterSales' );
   --- change_data ( 'Molhan, Martine (d5mmolha)',           'afterSales' );
   --- change_data ( 'Decelle, Renaud (d5rdecel)',           'afterSales' );
       change_data ( 'Swerts, Rudy (d5rswert)',              'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Huyghebaert, Bert (d5bhuygh)',         'afterSales' );
   --- change_data ( 'Hodin, Danny (d5dhodin)',              'afterSales' );
   --- change_data ( 'Claes, Els (d5eclaes)',                'afterSales' );
   --- change_data ( 'Nellis, Greet (d5gnelli)',             'afterSales' );
       change_data ( 'Liesenborghs, Johan (d5jliese)',       'sales'      );
   --- change_data ( 'Vanlessen, Kristiaan (d5kvanle)',      'afterSales' );
   --- change_data ( 'Lanckriet, Patrick (d5planck)',        'afterSales' );
       change_data ( 'Langley, Peter (d5plangl)',            'sales'      );
   --- change_data ( 'Van Haelst, Pascal (d5pvanha)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Colpaert, Bart (d5bcolpa)',            'sales'      );
       change_data ( 'Peirsman, Eric (d5epeirs)',            'sales'      );
       change_data ( 'Derde, Geert (d5gderde)',              'sales'      );
   --- change_data ( 'De Cock, Ingrid (d5idecoc)',           'afterSales' );
       change_data ( 'Mathieu, Jonathan (D5JMATHI)',         'sales'      );
       change_data ( 'Boeykens, Kenny (d5kboeyk)',           'sales'      );
       change_data ( 'Van Asch, Kurt (d5kuvana)',            'sales'      );
       change_data ( 'Duwijn, Lode (D5LDUWIJ)',              'sales'      );
   --- change_data ( 'De Backer, Martine (d5mdebac)',        'afterSales' );
       change_data ( 'Kesteleyn, Mario (d5mkeste)',          'sales'      );
       change_data ( 'Redant, Nick (d5nredan)',              'sales'      );
   --- change_data ( 'Baestroey, Patrick (d5pabaes)',        'afterSales' );
   --- change_data ( 'Bastroey, Patrick (d5pbaest)',         'afterSales' );
   --- change_data ( 'De Jong, Peter (d5pdejon)',            'afterSales' );
       change_data ( 'Geens, Philippe (d5pgeens)',           'sales'      );
       change_data ( 'Geens, Philip (d5phgeen)',             'sales'      );
   --- change_data ( 'Claes, Robin (d5rclaes)',              'afterSales' );
   --- change_data ( 'Cool, Stany (d5scool)',                'afterSales' );
       change_data ( 'Vanhove, Maarten (D5VANHOM)',          'sales'      );
   --- change_data ( 'Van Mossevelde, Yves (d5yvanmo)',      'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Groof, Frank (d5fdegro)',           'afterSales' );
       change_data ( 'Van Roey, Laurens (d5lvanro)',         'sales'      );
       change_data ( 'Geivers, Philippe (d5pgeive)',         'sales'      );
   --- change_data ( 'Rohart, Rudi (d5rrohar)',              'afterSales' );
   --- change_data ( 'Swinnen, Stefan (d5sswinn)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Wouters, Jef (d5jewout)',              'sales'      );
       change_data ( 'Ketels, Bram (d5bketel)',              'sales'      );
       change_data ( 'Bottelberge, Carlos (d5cbotte)',       'sales'      );
       change_data ( 'Debeurme, Chris (d5cdebeu)',           'sales'      );
       change_data ( 'Ampe, Cederic (D5CEAMPE)',             'sales'      );
       change_data ( 'Vercaempt, Carl (d5cverca)',           'sales'      );
   --- change_data ( 'Eeckhout, Hans (d5heeckh)',            'afterSales' );
   --- change_data ( 'Rosseel, Jeroen (d5jrosse)',           'afterSales' );
   --- change_data ( 'Debo, Nick (D5NIDEBO)',                'afterSales' );
       change_data ( 'Loeys, Peter (d5ploeys)',              'sales'      );
   --- change_data ( 'Balduyck, Sabine (d5sbaldu)',          'afterSales' );
   --- change_data ( 'Soete, Jil (D5SOETEJ)',                'afterSales' );
       change_data ( 'Verhage, Thijs (d5thverh)',            'sales'      );
   --- change_data ( 'Loosvelt, Tommy (d5tloosv)',           'afterSales' );
       change_data ( 'Vandenbroucke, Tom (d5vantom)',        'sales'      );
       change_data ( 'Vermeulen, Francky (D5VERMEF)',        'sales'      );
       change_data ( 'Alliet,  Xavier (d5xallie)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Grieten, Lou (d5lgriet)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Winkler, Arnaud (D5AWINKL)',           NULL         );   --- kein type definiert -> bekommt im step 2) After-Sales
   --- change_data ( 'Bernard, Jean-Luc (d5jberna)',         'afterSales' );
   --- change_data ( 'Bernard, Sabine (d5sabern)',           'afterSales' );
       change_data ( 'Faure, Xavier (d5xfaure)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Gallo, Guido (d5gugall)',              'sales'      );
   --- change_data ( 'Steils, Patrick (d5psteil)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Roo, Carl (d5cderoo)',              'afterSales' );
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
   --- change_data ( 'Neujens, Annemie (d5aneuje)',          'afterSales' );
   --- change_data ( 'Van Nisselrooy, Ida (d5ivanni)',       'afterSales' );
   --- change_data ( 'Verhoeven, Kim (d5kiverh)',            'afterSales' );
       change_data ( 'Van Scharen, Karel (D5KVANSC)',        'sales'      );
   --- change_data ( 'Deckx, Marc (d5mdeckx)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Defays, Bernard (d5bdefay)',           'afterSales' );
   --- change_data ( 'Sprumont, Didier (d5dsprum)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Ghyselinck, Dominique (d5dghyse)',     'afterSales' );
   --- change_data ( 'Ghyselinck, Jacques (d5jghyse)',       'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Godefroy, Bart (d5bgodef)',            'afterSales' );
       change_data ( 'Janssens, Kris (D5JANSSK)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Pans, Steven (d5spans)',               'afterSales' );
   --- change_data ( 'Pans, Werner (d5wpans)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Clappaert, Ann (d5aclapp)',            'afterSales' );
   --- change_data ( 'Mignon, Benny (d5bmigno)',             'afterSales' );
       change_data ( 'Heyde, Danny (d5dheyde)',              'sales'      );
       change_data ( 'Coppens, Erik (d5ecoppe)',             'sales'      );
       change_data ( 'Van Den Meersche, Filip (d5fivand)',   'sales'      );
   --- change_data ( 'Boeykens, Kenny (d5kboeyk)',           'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Ghys, Koen (d5kghys)',                 'afterSales' );
   --- change_data ( 'Van Asch, Kurt (d5kuvana)',            'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Schiettekat, Luc (d5lschie)',          'afterSales' );
   --- change_data ( 'De Jong, Peter (d5pdejon)',            'afterSales' );
       change_data ( 'Van Looy, Rik (d5rvanlo)',             'sales'      );
       change_data ( 'Heynderickx, Yves (d5yheynd)',         'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Lanckmans, Chris (d5clanck)',          'sales'      );
   --- change_data ( 'De Middeleir, Kathleen (d5kdemid)',    'afterSales' );
   --- change_data ( 'Vanderzypen, Kenneth (D5VANDKE)',      'afterSales' );
   --- change_data ( 'Van Laere, Jan (D5VANLAJ)',            'afterSales' );
   --- change_data ( 'Rogiers, Wouter (d5wrogie)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Caudenberg, Frank (d5fvanca)',     'afterSales' );
   --- change_data ( 'Van Hoof, Joachim (d5jvanho)',         'afterSales' );
   --- change_data ( 'Moons, Kurt (d5kmoons)',               'afterSales' );
       change_data ( 'Deville, Timothy (d5tdevil)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Schepers, Dirk (d5dschep)',            'afterSales' );
       change_data ( 'Tanghe, Jonas (d5jtangh)',             'sales'      );
   --- change_data ( 'Verboven, Jack (d5jverbo)',            'afterSales' );
   --- change_data ( 'Peeters, Luc (d5lpeete)',              'afterSales' );
   --- change_data ( 'Bartholomeeusen, Nic (d5nbarth)',      'afterSales' );
   --- change_data ( 'Verbist, Robert (d5rverbi)',           'afterSales' );
   --- change_data ( 'De Nys, Stefan (d5sdenys)',            'afterSales' );
       change_data ( 'Gogne, Stijn (D5SGOGNE)',              'sales'      );
   --- change_data ( 'Pieters, Tom (d5tpiete)',              'afterSales' );
   --- change_data ( 'Eilers, Wilfried (d5weiler)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Lust, Arnaud (d5arlust)',              'sales'      );
   --- change_data ( 'Mosselmans, Bruno (D5BMOSSE)',         'afterSales' );
   --- change_data ( 'Dellieu, Claude (d5cdelli)',           'afterSales' );
   --- change_data ( 'Graux, Christophe (d5cgraux)',         'afterSales' );
       change_data ( 'Goossens, Didier (d5dgooss)',          'sales'      );
       change_data ( 'Talent, Didier (d5dtalen)',            'sales'      );
   --- change_data ( 'Van Calck, Didier (d5dvanca)',         'afterSales' );
   --- change_data ( 'Bartolomucci, Elio (d5elbart)',        'afterSales' );
   --- change_data ( 'Politis, Kristos (D5KPOLIT)',          'afterSales' );
   --- change_data ( 'Preudhomme, Louis (d5lpreud)',         'afterSales' );
   --- change_data ( 'Ateca, Michel (d5mateca)',             'afterSales' );
   --- change_data ( 'Dhyne, Marc (d5mdhyne)',               'afterSales' );
       change_data ( 'De Blocq, Serge (d5sdeblo)',           'sales'      );
   --- change_data ( 'Gets, Vincent (d5vgets)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van de Putte, Christine (d5chrvan)',   'afterSales' );
   --- change_data ( 'De Brabandt, Ingrid (d5idebra)',       'afterSales' );
   --- change_data ( 'Van Lancker, Niels (D5NVANLA)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Clette, Bernard (d5bclett)',           'afterSales' );
   --- change_data ( 'Clette, Chantal (d5cclett)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Culot, Laurent (d5lculot)',            'afterSales' );
   --- change_data ( 'Piefort, Valérie (d5vpiefo)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Hanssens, Alain (d5alhans)',           'sales'      );
       change_data ( 'Van Win, Danny (d5dvanwi)',            'sales'      );
       change_data ( 'Walravens, jan (D5JWALRA)',            'sales'      );
       change_data ( 'Plaquet, Marc (d5mplaqu)',             'sales'      );
       change_data ( 'Gossiaux, Sebastien (d5sgossi)',       'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Swerts, Sonja (SSWERTS)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Jacob, Andre (AJACOB)',                'sales'      );
       change_data ( 'Verhasselt, Benoit (BVERHAS)',         'sales'      );
   --- change_data ( 'Dewez, Rika (d5rdewez)',               'afterSales' );
       change_data ( 'Rarou, Hicham (HIRAROU)',              'sales'      );
   --- change_data ( 'Wens, Chantal (JWENS33)',              'afterSales' );
       change_data ( 'Fabry, Pierre (PFABRY2)',              'sales'      );
   --- change_data ( 'Dewez, Rika (RDEWEZ)',                 'afterSales' );
       change_data ( 'Vander Veken, Sam (SAMVAND)',          'sales'      );
       change_data ( 'Van Den Broeck, Stephan (VANDENS)',    'sales'      );
       change_data ( 'Willems, Jo (WILLEJO)',                'sales'      );
       change_data ( 'Weytjens, Wouter (WWEYTJE)',           'sales'      );
       change_data ( 'Depoorter, Yannick (YDEPOOR)',         'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Charlier, Bernard (d5bechar)',         'sales'      );
       change_data ( 'Becquart, Dimitri (D5DBECQU)',         'sales'      );
       change_data ( 'Dethier, Michael (D5MDETHI)',          'sales'      );
   --- change_data ( 'Vanderbeck, Roger (d5rogvan)',         'afterSales' );
       change_data ( 'Russo, Sebastien (D5RUSSOS)',          'sales'      );
       change_data ( 'Hinant, Steve (d5shinan)',             'sales'      );
   --- change_data ( 'Huvelle, Sigrid (d5shuvel)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Schelkens, Danny (d5dschel)',          'afterSales' );
   --- change_data ( 'Goovaerts, Nadine (d5ngoova)',         'afterSales' );
   --- change_data ( 'Verlinden, Ronny (d5ronver)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Lysebetten, Bernard (d5bvanly)',   'afterSales' );
   --- change_data ( 'Nollevaux, Catherine (d5cnolle)',      'afterSales' );
   --- change_data ( 'Dubois Daniel (d5dadubo)',             'afterSales' );
   --- change_data ( 'Valencon, Jean-Marc (d5jevale)',       'afterSales' );
   --- change_data ( 'Hastir, Kevin (d5khasti)',             'afterSales' );
       change_data ( 'Lepere, Guillaume (D5LEGUIL)',         'sales'      );
   --- change_data ( 'Marinho, Alexandre (D5MARALE)',        'afterSales' );
       change_data ( 'Ahn, Th. (D5THAHN1)',                  'sales'      );
   --- change_data ( 'Didriche, Valentin (d5vdidri)',        'afterSales' );
   --- change_data ( 'Chavee, Yves (d5ychave)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Dethier, Arnaud (d5adethi)',           'sales'      );
   --- change_data ( 'Thiry, Alain (d5athiry)',              'afterSales' );
   --- change_data ( 'Dewert, Bernard (d5bdewer)',           'afterSales' );
   --- change_data ( 'Vanderest, Jean-Pierre (d5jeanpv)',    'afterSales' );
       change_data ( 'Barvaux, Laurent (d5lbarva)',          'sales'      );
   --- change_data ( 'Vicenzi, Marie-Paule (d5mavice)',      'afterSales' );
   --- change_data ( 'Benali, Nawale (d5nabena)',            'afterSales' );
   --- change_data ( 'Cremer, Pierre (d5pcreme)',            'afterSales' );
   --- change_data ( 'Servais, Patrick (d5pserva)',          'afterSales' );
       change_data ( 'Kerstenne, Thierry (d5tkerst)',        'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Cerullo, Anthony (d5acerul)',          'afterSales' );
   --- change_data ( 'Geurts, Alain (d5ageurt)',             'afterSales' );
   --- change_data ( 'Roegiers, Bernard (d5broegi)',         'afterSales' );
   --- change_data ( 'Darcis, Claude (d5cdarci)',            'afterSales' );
   --- change_data ( 'Roemers, Carine (d5croeme)',           'afterSales' );
       change_data ( 'Thomas, Daniel (d5dantho)',            'sales'      );
   --- change_data ( 'Regnier, Denis (d5dregni)',            'afterSales' );
       change_data ( 'De Fresart, Etienne (d5edefre)',       'sales'      );
   --- change_data ( 'De Brauwere, Guy (d5gdebra)',          'afterSales' );
   --- change_data ( 'Brucculeri, Julie (d5jbrucc)',         'afterSales' );
       change_data ( 'Lange, Eric (D5LANGEE)',               'sales'      );
       change_data ( 'Olivier, Luc (d5lolivi)',              'sales'      );
       change_data ( 'Copette, Marie-Louise (d5mcopet)',     'sales'      );
   --- change_data ( 'Leduc, Michel (d5mleduc)',             'afterSales' );
   --- change_data ( 'Brevers, Nicolas (d5nbreve)',          'afterSales' );
   --- change_data ( 'Parent, Rudi (d5rparen)',              'afterSales' );
   --- change_data ( 'Strauven, Robert (d5rstrau)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Decrock, Dimitri (d5ddecro)',          'afterSales' );
       change_data ( 'Dumoulin, Gaetan (d5gdumou)',          'sales'      );
   --- change_data ( 'Eeckhout, Hans (d5heeckh)',            'afterSales' );
       change_data ( 'Clabau, Marc (d5mclaba)',              'sales'      );
   --- change_data ( 'Balduyck, Sabine (d5sbaldu)',          'afterSales' );
       change_data ( 'De Groote, Sam (d5sdegro)',            'sales'      );
       change_data ( 'Deneckere, Tony (d5tdenec)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Thooft, Jurgen (d5jhooft)',            'afterSales' );
   --- change_data ( 'Desplinter, Rik (d5rdespl)',           'afterSales' );
   --- change_data ( 'Vlaeminck, Wouter (d5wvlaem)',         'afterSales' );
   --- change_data ( 'Ghysels, Yannick (d5yghyse)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Claude, Arnaud (D5ACLAUD)',            'sales'      );
   --- change_data ( 'Decelle, Constant (d5cdecel)',         'afterSales' );
       change_data ( 'Fosseprez, Clément (d5cfosse)',        'sales'      );
       change_data ( 'Huet, Pascal (d5phuet)',               'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Scius, Alain (d5ascius)',              'afterSales' );
   --- change_data ( 'Van Lysebetten, Bernard (d5bvanly)',   'afterSales' );
   --- change_data ( 'Bay, Fabian (d5fbay)',                 'afterSales' );
   --- change_data ( 'Hardy, Marc (d5mhardy)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Nihant, François (D5FNIHAN)',          'sales'      );
       change_data ( 'Roskam, Maxime (d5mroska)',            'sales'      );
   --- change_data ( 'Genotte, Nadine (d5ngenot)',           'afterSales' );
       change_data ( 'Miceli, Raphaël (d5rmicel)',           'sales'      );
       change_data ( 'Fonze, Vincent (d5vfonze)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Ekelenburg, Andre (d5avanek)',     'afterSales' );
   --- change_data ( 'Van Olmen, Bart (d5bvanol)',           'afterSales' );
       change_data ( 'Van Beersel, Danny (d5dvanbe)',        'sales'      );
       change_data ( 'Van Buynder, Dominique (d5dvanbu)',    'sales'      );
   --- change_data ( 'Moons, Guy (d5gmoons)',                'afterSales' );
   --- change_data ( 'Rynders, Nico (d5nrynde)',             'afterSales' );
       change_data ( 'Peeters, Peter (d5pepeet)',            'sales'      );
       change_data ( 'Schoeters, Tom (d5toscho)',            'sales'      );
       change_data ( 'Verschueren, Wim (d5wversc)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Destuynder, Antoine (d5adestu)',       'sales'      );
       change_data ( 'Bouchelil, Michael (D5BOUCHM)',        'sales'      );
   --- change_data ( 'Becquart, Dimitri (D5DBECQU)',         'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Liebin, Fabian (d5fliebi)',            'afterSales' );
   --- change_data ( 'Vanderbeck, Roger (d5rogvan)',         'afterSales' );
       change_data ( 'Berré, Sebastien (d5sberre)',          'sales'      );
   --- change_data ( 'Hinant, Steve (d5shinan)',             'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Vico, Sylvie (d5svico)',               'afterSales' );
   --- change_data ( 'Englebert, Yves (d5yengle)',           'afterSales' );
       change_data ( 'Rosoux, Yannick (D5YROSOU)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Delvax, Bart (d5bdelva)',              'afterSales' );
   --- change_data ( 'Hodin, Danny (d5dhodin)',              'afterSales' );
       change_data ( 'Strauven, Dirk (d5dstrau)',            'sales'      );
   --- change_data ( 'Claes, Els (d5eclaes)',                'afterSales' );
       change_data ( 'Gouverneur, Frédérique (d5fgouve)',    'sales'      );
       change_data ( 'Tulleners, Frank (d5ftulle)',          'sales'      );
   --- change_data ( 'Nellis, Greet (d5gnelli)',             'afterSales' );
       change_data ( 'Geboors, Mario (d5mgeboo)',            'sales'      );
       change_data ( 'Molenbruck, Nils (D5NMOLEN)',          'sales'      );
   --- change_data ( 'Bosmans, Peter (d5pbosma)',            'afterSales' );
       change_data ( 'Degreef, Steven (d5sdegre)',           'sales'      );
   --- change_data ( 'Mathijs, Tommy (d5tmathi)',            'afterSales' );
       change_data ( 'Vandendijck, Niki (D5VANDEN)',         'sales'      );
       change_data ( 'Vandenwauver, Geert (d5vandge)',       'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Daenen, Danny (d5ddaene)',             'sales'      );
       change_data ( 'Bruffaerts, Jeroen (d5jbruff)',        'sales'      );
   --- change_data ( 'Claes, Ludo (d5ludcla)',               'afterSales' );
       change_data ( 'Dirix, Peter (d5pdirix)',              'sales'      );
       change_data ( 'Desmedt, Roger (d5rdesme)',            'sales'      );
       change_data ( 'Schouteden, Ronny (D5SCHOUR)',         'sales'      );
   --- change_data ( 'Dodion, Wilfried (d5wdodio)',          'afterSales' );
   --- change_data ( 'Daenen, Danny (d5ddaene)',             'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Hodin, Danny (d5dhodin)',              'afterSales' );
   --- change_data ( 'Claes, Els (d5eclaes)',                'afterSales' );
   --- change_data ( 'Gouverneur, Frédérique (d5fgouve)',    'sales'      );	  --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Nellis, Greet (d5gnelli)',             'afterSales' );
   --- change_data ( 'Leenaers, Karolien (d5kleena)',        'afterSales' );
   --- change_data ( 'Van Goidsenhoven, Liesje (d5lvango)',  'afterSales' );
   --- change_data ( 'Bosmans, Peter (d5pbosma)',            'afterSales' );
       change_data ( 'Philtjens, Stephan (d5sphilt)',        'sales'      );
   --- change_data ( 'Rennen, Sandy (d5srenne)',             'afterSales' );
   --- change_data ( 'Vanstraelen, Sarah (d5svanst)',        NULL         );   --- kein type definiert -> bekommt im step 2) After-Sales
   --- change_data ( 'Daerden, Tim (d5tdaerd)',              NULL         );   --- kein type definiert -> bekommt im step 2) After-Sales
   --- change_data ( 'D''Hondt, Chris (d5cdhond)',           NULL         );   --- kein type definiert -> bekommt im step 2) After-Sales
   --- change_data ( 'Delanote, Dieter (d5ddelan)',          NULL         );   --- kein type definiert -> bekommt im step 2) After-Sales
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Delanote, Dieter (d5ddelan)',          'afterSales' );
   --- change_data ( 'Eeckhout, Hans (d5heeckh)',            'afterSales' );
   --- change_data ( 'Balduyck, Sabine (d5sbaldu)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Meulemeester, Anthony (d5ademeu)',  'afterSales' );
       change_data ( 'De Brauwer, Bruno (d5bdebra)',         'sales'      );
       change_data ( 'Verhavert, Kris (d5kverha)',           'sales'      );
       change_data ( 'Danneels, Lieven (d5ldanne)',          'sales'      );
       change_data ( 'Tondeleir, Lieven (d5litond)',         'sales'      );
       change_data ( 'Vereecken, Ludwig (d5lveree)',         'sales'      );
   --- change_data ( 'Battal, Marc (d5mbatta)',              'afterSales' );
       change_data ( 'Depreitere, Marc (d5mdepre)',          'sales'      );
   --- change_data ( 'De Kimpe, Nathalie (d5ndekim)',        'afterSales' );
       change_data ( 'Hublau, Nick (d5nhubla)',              'sales'      );
   --- change_data ( 'De Croock, Peter (d5pdecro)',          'afterSales' );
   --- change_data ( 'Smeets, Stany (d5ssmeet)',             'afterSales' );
       change_data ( 'Taildeman, Stefaan (d5staild)',        'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Vanvlierberghe, Glenn (d5gvanvl)',     'afterSales' );
   --- change_data ( 'De Ridder, Hugo (d5hderid)',           'afterSales' );
       change_data ( 'Helsen, Johan (D5JHELSE)',             'sales'      );
       change_data ( 'Flamand, Marc (d5mflama)',             'sales'      );
       change_data ( 'Verougstraete, Nico (d5nverou)',       'sales'      );
       change_data ( 'De Block, Patrick (d5pdeblo)',         'sales'      );
       change_data ( 'Provoost, Stefan (D5PROVOS)',          'sales'      );
       change_data ( 'Van Droogenbroeck, Robin (d5robiva)',  'sales'      );
       change_data ( 'Theunissen, Tom (D5THEUNT)',           'sales'      );
       change_data ( 'Verheyen, Serge (D5VERHES)',           'sales'      );
   --- change_data ( 'Van den Avijle, Jan (d5vjan)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Anzalone, Angelo (d5aanzal)',          'afterSales' );
   --- change_data ( 'Sylvère, Alexandre (D5ASYLVE)',        'afterSales' );
   --- change_data ( 'Deman, Bernard (d5bdeman)',            'afterSales' );
       change_data ( 'Deman, Cédric (d5cddema)',             'sales'      );
       change_data ( 'Hoskens, Charles (d5choske)',          'sales'      );
       change_data ( 'Ghossoub, Elie (d5eghoss)',            'sales'      );
       change_data ( 'Kuhn, Eric (D5ERKUHN)',                'sales'      );
   --- change_data ( 'Deman, Frédéric (d5fdeman)',           'afterSales' );
   --- change_data ( 'Godefroi, Frédéric (d5fgodef)',        'afterSales' );
   --- change_data ( 'Moons, Jean-Paul (d5jmoons)',          'afterSales' );
       change_data ( 'Ahmadloo, Nima (d5nahmad)',            'sales'      );
       change_data ( 'Janssens, Philippe (d5phjans)',        'sales'      );
   --- change_data ( 'Poels, Pascal (d5ppoels)',             'afterSales' );
       change_data ( 'Rutten, Stéphane (d5strutt)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Thijs, Frank (d5fthijs)',              'afterSales' );
   --- change_data ( 'Vanvlierberghe, Glenn (d5gvanvl)',     'afterSales' );
   --- change_data ( 'De Ridder, Hugo (d5hderid)',           'afterSales' );
   --- change_data ( 'Beeckmans, Johan (d5jbeeck)',          'afterSales' );
   --- change_data ( 'Mul, Katja (d5kmul)',                  'afterSales' );
   --- change_data ( 'Bauwens, Marc (d5mabauw)',             'afterSales' );
   --- change_data ( 'Buelens, Marcel (d5mabuel)',           'afterSales' );
   --- change_data ( 'Buelens, Marcel (d5mbuele)',           'afterSales' );
       change_data ( 'Chantrain, Manu (d5mchant)',           'sales'      );
       change_data ( 'De Clippel, Maxence (D5MDECLI)',       'sales'      );
   --- change_data ( 'Geens, Mark (d5mgeens)',               'afterSales' );
   --- change_data ( 'Van Ballaert, Peter (d5pvanba)',       'afterSales' );
   --- change_data ( 'Van Boven, Pieter (d5pvanbo)',         'afterSales' );
       change_data ( 'Van Ingh, Stefaan (d5svanin)',         'sales'      );
   --- change_data ( 'Van den hoek, Patrick (d5vanpat)',     'afterSales' );
   --- change_data ( 'Van den Avijle, Jan (d5vjan)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Adesione, Bruno (D5BADESI)',           'afterSales' );
   --- change_data ( 'Van Lysebetten, Bernard (d5bvanly)',   'afterSales' );
   --- change_data ( 'Richard, Chantal (d5cricha)',          'afterSales' );
   --- change_data ( 'Pollenus, Jean-François (d5jepoll)',   'afterSales' );
       change_data ( 'Pirotte, Maxime (d5mapiro)',           'sales'      );
   --- change_data ( 'Hasard, Nathalie (d5nhasar)',          'afterSales' );
   --- change_data ( 'Rigaux, Philippe (d5phriga)',          'afterSales' );
   --- change_data ( 'Rassart, Pierre-Yves (d5pirass)',      'afterSales' );
   --- change_data ( 'Rassart, Patrick (d5prassa)',          'afterSales' );
   --- change_data ( 'Tourneur, Séverine (D5TOURSE)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Lagaly, Arnaud (D5ALAGAL)',            'sales'      );
   --- change_data ( 'Mormont, Anthony (d5amormo)',          'afterSales' );
       change_data ( 'Henrion, Benoit (d5bhenri)',           'sales'      );
   --- change_data ( 'Houbart, Bruno (d5bhouba)',            'afterSales' );
       change_data ( 'Cieza Martin, Damian (d5dcieza)',      'sales'      );
   --- change_data ( 'Lazzara, Dario (d5dlazza)',            'afterSales' );
       change_data ( 'Volkaert, Damien (d5dvolka)',          'sales'      );
       change_data ( 'Colin, Guillaume (d5gcolin)',          'sales'      );
   --- change_data ( 'Vandeloise, Geoffrey (d5geovan)',      'afterSales' );
   --- change_data ( 'Devillet, Hubert (d5hdevil)',          'afterSales' );
   --- change_data ( 'Duchateau, Jean-Charles (d5jeduch)',   'afterSales' );
   --- change_data ( 'Pirotte, Jean luc (d5jpirot)',         'afterSales' );
   --- change_data ( 'Dallons, Julien (d5judall)',           'afterSales' );
   --- change_data ( 'Noyon, Luc (d5lnoyon)',                'afterSales' );
   --- change_data ( 'Mazyn, Michel (d5mmazyn)',             'afterSales' );
       change_data ( 'Sabba, Nordin (D5NSABBA)',             'sales'      );
   --- change_data ( 'Baguet, Sébastien (d5sbague)',         'afterSales' );
   --- change_data ( 'Lardinois, Sébastien (d5slardi)',      'afterSales' );
   --- change_data ( 'Huygens, Thierry (d5thuyge)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van den Neucker, Annie (d5annvan)',    'afterSales' );
   --- change_data ( 'Delabelle, Gregory (d5gdelab)',        'afterSales' );
   --- change_data ( 'Ghys, Koen (d5kghys)',                 'afterSales' );
       change_data ( 'Jacobs, Kris (d5kjacob)',              'sales'      );
   --- change_data ( 'De Jong, Peter (d5pdejon)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Huet, Pascal (d5phuet)',               'afterSales' );
       change_data ( 'Bertinchamps, Vincent (d5vibert)',     'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Fiers, Alex (d5afiers)',               'sales'      );
   --- change_data ( 'Desmet, Bart (d5bdesme)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Godart, Alexandre (d5agodar)',         'afterSales' );
   --- change_data ( 'Vandewerve, Alain (d5alaiva)',         'afterSales' );
       change_data ( 'Delsippé, David (d5ddelsi)',           'sales'      );
       change_data ( 'Fagneray, Eric (d5efagne)',            'sales'      );
   --- change_data ( 'Piret, Marcel (d5mpiret)',             'afterSales' );
   --- change_data ( 'Focant, Nathalie (d5nfocan)',          'afterSales' );
       change_data ( 'André, Pascal (d5pasand)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Snauwaert, Candice (d5csnauw)',        'afterSales' );
   --- change_data ( 'Dubois, Daniel (d5dduboi)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Eeckhout, Hans (d5heeckh)',            'afterSales' );
   --- change_data ( 'Balduyck, Sabine (d5sbaldu)',          'afterSales' );
   --- change_data ( 'De Pauw, Thomas (d5tdepau)',           'afterSales' );
   --- change_data ( 'Loosvelt, Tommy (d5tloosv)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Jurgens, Sven (d5sjurge)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Goossens, Anton (d5agooss)',           'sales'      );
   --- change_data ( 'Mariën, Anja (d5amarie)',              'afterSales' );
   --- change_data ( 'Smits, Franky (D5FSMITS)',             'afterSales' );
   --- change_data ( 'Wouters, Jef (d5jewout)',              'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Frans, Kurt (d5kfrans)',               'afterSales' );
       change_data ( 'Serge, Schaevers (d5scserg)',          'sales'      );
   --- change_data ( 'De Nys, Stefan (d5sdenys)',            'afterSales' );
       change_data ( 'Van den Bulck, Stef (D5VANSTE)',       'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Bolle, Aurelie (d5auboll)',            'afterSales' );
   --- change_data ( 'wynants, Jean-Marc (d5jewyna)',        'afterSales' );
   --- change_data ( 'Romano, Kristel (D5KRROMA)',           'afterSales' );
   --- change_data ( 'Poznanski, Leslie (d5lpozna)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Vermeulen, Andre (d5anverm)',          'afterSales' );
   --- change_data ( 'Vancauwenberghe, Alain (d5avanca)',    'afterSales' );
   --- change_data ( 'Verpoorten, Angelo (D5AVERPO)',        'afterSales' );
       change_data ( 'Brems, Bart (d5bbrems)',               'sales'      );
   --- change_data ( 'Thysbaert, Charis (d5cthysb)',         'afterSales' );
       change_data ( 'Naya, David (d5danaya)',               'sales'      );
   --- change_data ( 'De Vroe, David (d5ddevro)',            'afterSales' );
       change_data ( 'Van Mooter, Didier (D5DVANMO)',        'sales'      );
   --- change_data ( 'Verhoeven, Dirk (d5dverho)',           'afterSales' );
   --- change_data ( 'Stremersch, Franky (d5fstrem)',        'afterSales' );
       change_data ( 'Jacobs, Gert (d5gjacob)',              'sales'      );
       change_data ( 'Van Bockel, Hendrik (D5HVANBO)',       'sales'      );
   --- change_data ( 'Nauwelaerts, Ilse (d5inauwe)',         'afterSales' );
   --- change_data ( 'Van Humbeeck, Ingrid (d5invanh)',      'afterSales' );
   --- change_data ( 'Daman, Jan (d5jdaman)',                'afterSales' );
   --- change_data ( 'De Winter, Jan (d5jdewin)',            'afterSales' );
       change_data ( 'Jansen, Jill (d5jijans)',              'sales'      );
       change_data ( 'Remans, Joren (d5jreman)',             'sales'      );
   --- change_data ( 'Nauwerlaerts, Koen (d5knauwe)',        'afterSales' );
   --- change_data ( 'Creffier, Laurent (D5LCREFF)',         'afterSales' );
       change_data ( 'Dehertog, Luc (D5LDEHER)',             'sales'      );
   --- change_data ( 'Van Campenhout, Marina (d5mvanca)',    'afterSales' );
   --- change_data ( 'Coppens, Rudy (d5rucopp)',             'afterSales' );
   --- change_data ( 'Scheidtweiler, Jelle (D5SJELLE)',      'afterSales' );
   --- change_data ( 'Torfs, Sabina (d5storfs)',             'afterSales' );
   --- change_data ( 'Van den Eynde, Bart (d5vbart)',        'afterSales' );
   --- change_data ( 'Verheyden, Robbie (D5VERHER)',         'afterSales' );
   --- change_data ( 'Keppens, Yannick (D5YKEPPE)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Soete, Ben (d5bsoete)',                'afterSales' );
       change_data ( 'Van Steen, Carl (d5cavans)',           'sales'      );
       change_data ( 'Detruyer, Glenn (D5GDETRU)',           'sales'      );
       change_data ( 'Vreven, Guy (d5gvreve)',               'sales'      );
       change_data ( 'vreyen, guy (d5gvreye)',               'sales'      );
       change_data ( 'De Vriendt, Herwig (d5hdevri)',        'sales'      );
       change_data ( 'Dekoninck, Leo (d5ldekon)',            'sales'      );
       change_data ( 'De Meûter, Michel (d5mdemeu)',         'sales'      );
       change_data ( 'Uyttebroek, Nicolas (d5nuytte)',       'sales'      );
   --- change_data ( 'Chabert, Tom (d5tchabe)',              'afterSales' );
       change_data ( 'Steens, Tom (D5TSTEEN)',               'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Vanvlierberghe, Glenn (d5gvanvl)',     'afterSales' );
   --- change_data ( 'De Ridder, Hugo (d5hderid)',           'afterSales' );
       change_data ( 'Happaerts, Hans (d5hhappa)',           'sales'      );
   --- change_data ( 'Van den Borne, Paul (d5pavand)',       'afterSales' );
   --- change_data ( 'Van den Avijle, Jan (d5vjan)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Derau, Christel (d5cderau)',           'afterSales' );
       change_data ( 'Pollet, Carine (d5cpolle)',            'sales'      );
       change_data ( 'Denayer, Jeremy (D5DENAYJ)',           'sales'      );
   --- change_data ( 'Uccedu, Gianny (d5gucced)',            'afterSales' );
       change_data ( 'Lerycke, Jean-Sébastien (d5jleryc)',   'sales'      );
   --- change_data ( 'Vanderbeck, Roger (d5rogvan)',         'afterSales' );
   --- change_data ( 'Vico, Sylvie (d5svico)',               'afterSales' );
   --- change_data ( 'Vanneste, Valentin (d5vvanne)',        'afterSales' );
   --- change_data ( 'Englebert, Yves (d5yengle)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Brassart, Aline (D5ABRASS)',           'sales'      );
   --- change_data ( 'Broekmans, Bjorn (d5bbroek)',          'afterSales' );
   --- change_data ( 'Jaeken, Bernard (d5bjaeke)',           'afterSales' );
       change_data ( 'Broekmans, Björn (d5bjbroe)',          'sales'      );
   --- change_data ( 'Degreef, Christof (d5cdegre)',         'afterSales' );
   --- change_data ( 'Vandenborne, Chris (d5chriva)',        'afterSales' );
       change_data ( 'Mulders, Dirk (d5dimuld)',             'sales'      );
       change_data ( 'Vanhauter, David (D5DVANHA)',          'sales'      );
   --- change_data ( 'Delforge, Elie (d5edelfo)',            'afterSales' );
   --- change_data ( 'Hermans, Evelien (d5evherm)',          'afterSales' );
   --- change_data ( 'Schoenaers, Frank (d5fschoe)',         'afterSales' );
   --- change_data ( 'Joosten, Hannelore (d5hanjoo)',        'afterSales' );
   --- change_data ( 'Brauns, Inge (d5ibraun)',              'afterSales' );
   --- change_data ( 'Bellen, Inge (d5inbell)',              'afterSales' );
   --- change_data ( 'Raedschelders, Julie (d5jraeds)',      'afterSales' );
   --- change_data ( 'Vaassen, Lizzy (d5lvaass)',            'afterSales' );
   --- change_data ( 'Bertotto, Marco (d5mabert)',           'afterSales' );
       change_data ( 'Simons, Patrick (d5pasimo)',           'sales'      );
   --- change_data ( 'Ceuleers, Philip (d5pceule)',          'afterSales' );
   --- change_data ( 'Deville, Pierre (d5pdevil)',           'afterSales' );
   --- change_data ( 'Peyls, Pim (d5ppeyls)',                'afterSales' );
       change_data ( 'Wijgaerts, Paul (d5pwijga)',           'sales'      );
       change_data ( 'eerdekens, Robin (d5reerde)',          'sales'      );
   --- change_data ( 'Leen, Raf (d5rleen)',                  'afterSales' );
       change_data ( 'Rutten, Sebastiaan (d5serutt)',        'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Millen, Bjorn (d5bmille)',             'afterSales' );
   --- change_data ( 'Joosten, Hannelore (d5hanjoo)',        'afterSales' );
       change_data ( 'Slangen, Inge (d5islang)',             'sales'      );
       change_data ( 'Jehoul, Jos (d5jjehou)',               'sales'      );
   --- change_data ( 'Raedschelders, Julie (d5jraeds)',      'afterSales' );
   --- change_data ( 'Vaassen, Lizzy (d5lvaass)',            'afterSales' );
       change_data ( 'Van Dijck, Maarten (d5maarva)',        'sales'      );
   --- change_data ( 'Ceuleers, Philip (d5pceule)',          'afterSales' );
   --- change_data ( 'Coenen, Pascal (d5pcoene)',            'afterSales' );
       change_data ( 'Cooreman, Paul (d5pcoore)',            'sales'      );
   --- change_data ( 'De Ryck, Peter (d5pderyc)',            'afterSales' );
       change_data ( 'Jacobs, Robby (d5robjac)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Raymaekers, Davy (d5drayma)',          'afterSales' );
       change_data ( 'De Rijck, Els (d5ederij)',             'sales'      );
   --- change_data ( 'Van Dijck, Geert (d5gvandi)',          'afterSales' );
   --- change_data ( 'Heylen, Kelly (d5kelhey)',             'afterSales' );
       change_data ( 'Van Look, Piet (d5pivanl)',            'sales'      );
   --- change_data ( 'Van den Putte, Ronny (d5ronvan)',      'afterSales' );
       change_data ( 'Jacobien, Stef (d5stjaco)',            'sales'      );
       change_data ( 'Van Aert, Steven (d5svanae)',          'sales'      );
       change_data ( 'Vanrintel, Tom (d5tovanr)',            'sales'      );
       change_data ( 'Van Rintel, Tom (d5tvanri)',           'sales'      );
       change_data ( 'Vanberghen, Steven (d5vastev)',        'sales'      );
   --- change_data ( 'Hellemans, Walter (d5whelle)',         'afterSales' );
       change_data ( 'Windey, Kris (D5WINDEK)',              'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Raymaekers, Davy (d5drayma)',          'afterSales' );
   --- change_data ( 'Heylen, Kelly (d5kelhey)',             'afterSales' );
       change_data ( 'Van Buitenen, Kurt (d5kuvanb)',        'sales'      );
       change_data ( 'Manette, Michel (d5mmanet)',           'sales'      );
   --- change_data ( 'Jannes, Peter (d5pjanne)',             'afterSales' );
   --- change_data ( 'Severi, Pieter (d5psever)',            'afterSales' );
   --- change_data ( 'Hellemans, Walter (d5whelle)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Raymaekers, Davy (d5drayma)',          'afterSales' );
       change_data ( 'Adriaensen, Guy (d5gadria)',           'sales'      );
   --- change_data ( 'Heylen, Kelly (d5kelhey)',             'afterSales' );
   --- change_data ( 'Klockaerts, Kristof (d5kklock)',       'afterSales' );
       change_data ( 'Janssens, Michel (d5mjanss)',          'sales'      );
       change_data ( 'Mertens, Rudi (d5rmerte)',             'sales'      );
   --- change_data ( 'Jacobien, Stef (d5stjaco)',            'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
       change_data ( 'Hellemans, Walter (d5whelle)',         'sales'      );
       change_data ( 'Ben Youssef, Kerim (KBENYOU)',         'sales'      );
       change_data ( 'Verriest, Mark (MVERRIE)',             'sales'      );
       change_data ( 'Addamo, Salvatore (SADDAMO)',          'sales'      );
       change_data ( 'Van De Voorde, Veronique (VVANDEV)',   'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'De Le Vingne, Benoit (d5blelev)',      'sales'      );
   --- change_data ( 'De Potter, Jérémie (d5djerem)',        'afterSales' );
   --- change_data ( 'Desert, Joel (d5jdeser)',              'afterSales' );
       change_data ( 'Dewitte, Laurent (d5ladewi)',          'sales'      );
       change_data ( 'Gallo, Michel (d5migall)',             'sales'      );
   --- change_data ( 'Morjau, Olivier (d5omorja)',           'afterSales' );
       change_data ( 'Peel, Olivier (d5opeel)',              'sales'      );
   --- change_data ( 'Simons, Valérie (d5vasimo)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Hoorick, Koen (d5kvanho)',         'afterSales' );
   --- change_data ( 'Schoevaerts, Sven (d5svscho)',         'afterSales' );
   --- change_data ( 'Bogemans, Tim (d5tbogem)',             'afterSales' );
   --- change_data ( 'De Hauwere, Wim (d5wdehau)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Teunen, Annick (d5ateune)',            'afterSales' );
   --- change_data ( 'Proot, John (d5jproot)',               'afterSales' );
       change_data ( 'Boone, Kjell (D5KBOORN)',              'sales'      );
   --- change_data ( 'Claeys, Nathalie (d5nclaey)',          'afterSales' );
   --- change_data ( 'Proot, Nathalie (d5nproot)',           'afterSales' );
   --- change_data ( 'Vercruysse, Vicky (d5vvercr)',         'afterSales' );
   --- change_data ( 'Claeys, Alexander (D5ACLAEY)',         'afterSales' );
   --- change_data ( 'Vansteenkiste, Bjorn (d5bvanst)',      'afterSales' );
   --- change_data ( 'Desmedt, Christophe (d5cdesme)',       'afterSales' );
   --- change_data ( 'Vanderbeke, Chris (d5chvand)',         'afterSales' );
   --- change_data ( 'Dugardyn, Dominique (d5ddugar)',       'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
       change_data ( 'De Paepe, Sabine (D5DEPAES)',          'sales'      );
       change_data ( 'Dhondt, Bob (D5DHONDB)',               'sales'      );
       change_data ( 'Herman, Emmanuel (d5eherma)',          'sales'      );
       change_data ( 'Degryse, Frederic (d5fdegry)',         'sales'      );
   --- change_data ( 'Haezaert, Fabian (d5fhaeza)',          'afterSales' );
   --- change_data ( 'Derycker, Frank (d5frankd)',           'afterSales' );
       change_data ( 'Mezières, Gregory (D5GMEZIE)',         'sales'      );
   --- change_data ( 'Paeye, Gino (d5gpaeye)',               'afterSales' );
   --- change_data ( 'Beselaere, Isabelle (d5ibesel)',       'afterSales' );
   --- change_data ( 'Boone, Kjell (D5KBOORN)',              'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
       change_data ( 'Bracke, Kris (D5KBRACK)',              'sales'      );
   --- change_data ( 'Craeye, Kurt (d5kcraey)',              'afterSales' );
       change_data ( 'Vertriest, Klaas (D5KVERTR)',          'sales'      );
       change_data ( 'Claeys, Ludovic (d5lclaey)',           'sales'      );
   --- change_data ( 'Seys, Olivier (D5OLSEYS)',             'afterSales' );
   --- change_data ( 'Rabaey, Pascal (d5paraba)',            'afterSales' );
   --- change_data ( 'De Baecke, Peter (d5pdebae)',          'afterSales' );
       change_data ( 'Holsteens, Robrecht (D5RHOLST)',       'sales'      );
       change_data ( 'Seys, Alex (D5SEYSAL)',                'sales'      );
       change_data ( 'Rommel, Steven (D5SROMME)',            'sales'      );
       change_data ( 'Verhelst, Frederik (D5VERHEF)',        'sales'      );
       change_data ( 'Grijseels, Yves (D5YGRIJS)',           'sales'      );
   --- change_data ( 'Neels, Yves (d5yneels)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Mertens, Alwin (ALWMERT)',             'sales'      );
       change_data ( 'De Schutter, Dirk (DDESCHU)',          'sales'      );
   --- change_data ( 'Vanpaeschen, Danny (DVANPAE)',         'afterSales' );
       change_data ( 'Roeykens, Herwig (HROEYKE)',           'sales'      );
       change_data ( 'De Rademaeker, Jan (JDERADE)',         'sales'      );
       change_data ( 'Wuyts, Julie (JUWUYTS)',               'sales'      );
       change_data ( 'Miri, Karim (KARMIRI)',                'sales'      );
       change_data ( 'Simonis, René (RSIMONI)',              'sales'      );
       change_data ( 'Pauwels, Sigrid (SIPAUWE)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Sels, Ellen (d5esels)',                'afterSales' );
   --- change_data ( 'Wispenninck, Joeri (d5joewis)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Cools, Annelies (d5acools)',           'afterSales' );
   --- change_data ( 'Van Driessche, Greet (d5gvandr)',      'afterSales' );
   --- change_data ( 'Van der Steen, Kurt (d5vkurt)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Meulemeester, Anthony (d5ademeu)',  'afterSales' );
       change_data ( 'Lecompte, Amaury (d5amleco)',          'sales'      );
       change_data ( 'Liebens, Bram (D5BLIEBE)',             'sales'      );
   --- change_data ( 'Eggermont, Dimitri (d5diegge)',        'afterSales' );
       change_data ( 'Van den Abbeele, Erwin (d5erwiva)',    'sales'      );
   --- change_data ( 'De Conynck, Kristof (d5kdecon)',       'afterSales' );
       change_data ( 'Rammeloo, Kersten (d5keramm)',         'sales'      );
   --- change_data ( 'De Kimpe, Nathalie (d5ndekim)',        'afterSales' );
   --- change_data ( 'Roelant, Patrick (d5proela)',          'afterSales' );
   --- change_data ( 'Smeets, Stany (d5ssmeet)',             'afterSales' );
       change_data ( 'Thuet, Stephen (d5stthue)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Lysebetten, Bernard (d5bvanly)',   'afterSales' );
   --- change_data ( 'Nollevaux, Catherine (d5cnolle)',      'afterSales' );
   --- change_data ( 'Valencon, Jean-Marc (d5jevale)',       'afterSales' );
       change_data ( 'Lerusse, Jean (d5jlerus)',             'sales'      );
   --- change_data ( 'Balfroid, Ludovic (d5lbalfr)',         'afterSales' );
   --- change_data ( 'Dufays, Olivier (d5odufay)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Leirs, Ivan (d5ileirs)',               'afterSales' );
       change_data ( 'Van De Velde, Joeri (d5joerva)',       'sales'      );
   --- change_data ( 'Van Styvendaele, Maxime (D5VANSTM)',   'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Cousin, Dimitri (d5dcousi)',           'afterSales' );
   --- change_data ( 'Louis, Didier (d5dlouis)',             'afterSales' );
   --- change_data ( 'Duquesne, Nicolas (D5DUQUEN)',         'afterSales' );
       change_data ( 'Demol, Lionel (d5ldemol)',             'sales'      );
       change_data ( 'Joly, Philippe (d5phjoly)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Vandervelde, Bart (d5barvan)',         'afterSales' );
       change_data ( 'Neyrinck, Christian (D5CNEIRI)',       'sales'      );
   --- change_data ( 'kygnee, els (D5EKYGNE)',               'afterSales' );
   --- change_data ( 'Volders, Jeroen (D5JVOLDE)',           'afterSales' );
   --- change_data ( 'Meeus, Ludo (d5lmeeus)',               'afterSales' );
       change_data ( 'Op De Beeck, Raf (D5OPDEBR)',          'sales'      );
       change_data ( 'Op De Beek, Raf (d5ropdeb)',           'sales'      );
       change_data ( 'Vertommen, Rudi (d5rverto)',           'sales'      );
   --- change_data ( 'Vanheusden, Tim (d5tvanhe)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Wouwe, Anne-Caroline (d5avanwo)',  'afterSales' );
   --- change_data ( 'Werbrouck, Bram (d5bwerbr)',           'afterSales' );
   --- change_data ( 'Decock, Wim (d5wdecoc)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Chastreux, Arnaud (D5ACHAST)',         'afterSales' );
   --- change_data ( 'Zune, Samuel (d5szune)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Hamerlinck, Catherine (CHAMERL)',      'sales'      );
       change_data ( 'De Keyser, Floris (FDEKEYS)',          'sales'      );
       change_data ( 'Temmerman, Joost (JTEMMER)',           'sales'      );
       change_data ( 'Vanderbauwhede, Karen (KAVANDE)',      'sales'      );
       change_data ( 'Maes, Piet (MAESPIE)',                 'sales'      );
   --- change_data ( 'Homans, Arnaud (d5ahoman)',            'afterSales' );
   --- change_data ( 'Bourgaux, Christophe (d5cbourg)',      'afterSales' );
       change_data ( 'Kumps, Christophe (d5ckumps)',         'sales'      );
       change_data ( 'Breyne, Didier (D5DBREYN)',            'sales'      );
   --- change_data ( 'Van Gelder, Ellen (d5evange)',         'afterSales' );
   --- change_data ( 'Kinnet, Georges (d5gekinn)',           'afterSales' );
       change_data ( 'Cappellen, Jonas (D5JCAPPE)',          'sales'      );
       change_data ( 'Holsbeek, Tamara (D5THOLSB)',          'sales'      );
   --- change_data ( 'Smets, Tom (d5tsmets)',                'afterSales' );
       change_data ( 'Verhaegen, Wim (d5wverha)',            'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Van Paeschen, Danny (d5dvanpa)',       'afterSales' );
   --- change_data ( 'Pauwels, Sigrid (d5spauwe)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Depraetere, Alex (d5adepra)',          'sales'      );
   --- change_data ( 'Gaspard, Bertrand (d5bgaspa)',         'afterSales' );
       change_data ( 'Goutier, Jonathan (d5jgouti)',         'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'D''Hondt, Bert (d5bdhond)',            'afterSales' );
   --- change_data ( 'Cauberghe, Christine (d5ccaube)',      'afterSales' );
   --- change_data ( 'Rotthier, Tonny (d5trotth)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Neirinck, Linda (d5lneiri)',           'afterSales' );
   --- change_data ( 'vos, Sigfrid (D5VSIGFR)',              'afterSales' );
   --- change_data ( 'De Ryck, Yves (d5yderyc)',             'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Jans, Bart (d5bjans)',                 'afterSales' );
   --- change_data ( 'Joosten, Hannelore (d5hanjoo)',        'afterSales' );
   --- change_data ( 'Goyens, Joel (d5jgoyen)',              'afterSales' );
   --- change_data ( 'Raedschelders, Julie (d5jraeds)',      'afterSales' );
   --- change_data ( 'Vreys, Kim (d5kvreys)',                'afterSales' );
   --- change_data ( 'Vaassen, Lizzy (d5lvaass)',            'afterSales' );
   --- change_data ( 'Ceuleers, Philip (d5pceule)',          'afterSales' );
   --- change_data ( 'Jacobs, Robby (d5robjac)',             'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
   --- change_data ( 'Pribylla, Sven (d5spriby)',            'afterSales' );
       change_data ( 'Vanderhulst, Nick (D5VANNIC)',         'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Teunen, Annick (d5ateune)',            'afterSales' );
   --- change_data ( 'Proot, John (d5jproot)',               'afterSales' );
   --- change_data ( 'Boone, Kjell (D5KBOORN)',              'sales'      );   --- steht auch in einer vorangegangenen zeile -> wird kein weiteres mal verarbeitet
       change_data ( 'Claeys, Ludovic (d5lclaey)',           'sales'      );
   --- change_data ( 'Proot, Nathalie (d5nproot)',           'afterSales' );
   --- change_data ( 'Vercruysse, Vicky (d5vvercr)',         'afterSales' );
   --- change_data ( 'Baglione, Adriano (d5abagli)',         'afterSales' );
   --- change_data ( 'Ateca, Christophe (d5cateca)',         'afterSales' );
   --- change_data ( 'Van Boxstael, Eric (d5evanbo)',        'afterSales' );
       change_data ( 'Moons, Jean-Pierre (d5jemoon)',        'sales'      );
   --- change_data ( 'Beullens, Kris (d5kbeull)',            'afterSales' );
   --- change_data ( 'Michaux, Marc (d5mmicha)',             'afterSales' );
   --- change_data ( 'Bouillon, Patrick (d5pbouil)',         'afterSales' );
   --- change_data ( 'Rozzi, Riccardo (d5rrozzi)',           'afterSales' );
   --- change_data ( 'Hendrickx, Steve (d5shendr)',          'afterSales' );
   --- change_data ( 'Lowagie, Sophie (d5slowag)',           'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Piret, Marcel (d5mpiret)',             'afterSales' );
   --- change_data ( 'Pirmez, Thomas (d5tpirme)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Lemaire, Chantal (d5clemai)',          'afterSales' );
   --- change_data ( 'Delhez, Marc (d5mdelhe)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Auman, Bart (d5bauman)',               'afterSales' );
       change_data ( 'Beyens, Jos (D5BEYJOS)',               'sales'      );
   --- change_data ( 'Elst, Gert (d5geelst)',                'afterSales' );
       change_data ( 'Meiremans, Marc (D5MMEIRE)',           'sales'      );
       change_data ( 'Schreurs, Renaat (D5SCHRER)',          'sales'      );
   --- change_data ( 'Van Dingenen, Wesley (d5wvandi)',      'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Demyttenaere, Bart (d5bdemyt)',        'afterSales' );
   --- change_data ( 'Vandekerckhove, Christof (d5chrisv)',  'afterSales' );
   --- change_data ( 'Renard, Christophe (d5crenar)',        'afterSales' );
       change_data ( 'Despriet, Bart (D5DESPRB)',            'sales'      );
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
   --- change_data ( 'De Beule, Filip (d5fdebeu)',           'afterSales' );
       change_data ( 'De Guffroy, Frederik (D5FDEGUF)',      'sales'      );
       change_data ( 'Scheire, Filip (d5fschei)',            'sales'      );
   --- change_data ( 'Vanhoorelbeke, Fabine (d5fvanho)',     'afterSales' );
       change_data ( 'Lippens, Giovanni (d5glippe)',         'sales'      );
       change_data ( 'Loncke, Gino (d5glonck)',              'sales'      );
       change_data ( 'Rekoms, Gunther (d5grekom)',           'sales'      );
       change_data ( 'De Moor, Hendrik (d5hdemoo)',          'sales'      );
   --- change_data ( 'Lampaert, Jan (d5jalamp)',             'afterSales' );
   --- change_data ( 'Boutens, Jochen (D5JBOUTE)',           'afterSales' );
       change_data ( 'De Cloedt, Janne (D5JDECLO)',          'sales'      );
   --- change_data ( 'Thooft, Jurgen (d5jhooft)',            'afterSales' );
       change_data ( 'Louckx, Jean (d5jlouck)',              'sales'      );
       change_data ( 'Callens, Jochen (d5joccal)',           'sales'      );
       change_data ( 'Windels, John (d5jowind)',             'sales'      );
   --- change_data ( 'Ketels, Kris (d5kketel)',              'afterSales' );
   --- change_data ( 'Laroy, Mathieu (D5MATHIL)',            'afterSales' );
   --- change_data ( 'Van Bockstael, Nicolas (D5NVANBO)',    'afterSales' );
   --- change_data ( 'Devos, Patrick (d5pdevos)',            'afterSales' );
   --- change_data ( 'Desplinter, Rik (d5rdespl)',           'afterSales' );
       change_data ( 'Jacobs, Roeland (d5roejac)',           'sales'      );
   --- change_data ( 'Balcaen, Steven (d5sbalca)',           'afterSales' );
   --- change_data ( 'De Abreu, Simon (d5sdeabr)',           'afterSales' );
       change_data ( 'Warlop, Simon (D5SWARLO)',             'sales'      );
   --- change_data ( 'Guyonnaud, Tim (d5tguyon)',            'afterSales' );
   --- change_data ( 'Vandaele, Mathieu (D5VANDAM)',         'afterSales' );
       change_data ( 'Vandecasteele, Christ (D5VANDEC)',     'sales'      );
   --- change_data ( 'Hubau, Wouter (D5WHUBAU)',             'afterSales' );
   --- change_data ( 'Vlaeminck, Wouter (d5wvlaem)',         'afterSales' );
   --- change_data ( 'Ghysels, Yannick (d5yghyse)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Mahau, Arthus (d5amahau)',             'sales'      );
       change_data ( 'Catteeuw, Christof (D5CCATTE)',        'sales'      );
   --- change_data ( 'Vandekerckhove, Christof (d5chrisv)',  'afterSales' );
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
       change_data ( 'Commeyne, Gino (d5gcomme)',            'sales'      );
       change_data ( 'Simoens, Geert (d5gsimoe)',            'sales'      );
   --- change_data ( 'Oosterlinck, Hans (d5hooste)',         'afterSales' );
   --- change_data ( 'Lampaert, Jan (d5jalamp)',             'afterSales' );
   --- change_data ( 'Ketels, Kris (d5kketel)',              'afterSales' );
       change_data ( 'Christiaens, Lorenz (d5lochri)',       'sales'      );
   --- change_data ( 'Laroy, Mathieu (D5MATHIL)',            'afterSales' );
       change_data ( 'Oplinus, Piet (d5poplin)',             'sales'      );
       change_data ( 'De Jonghe, Rik (d5rdejon)',            'sales'      );
   --- change_data ( 'Desplinter, Rik (d5rdespl)',           'afterSales' );
   --- change_data ( 'Guyonnaud, Tim (d5tguyon)',            'afterSales' );
   --- change_data ( 'Vlaeminck, Wouter (d5wvlaem)',         'afterSales' );
   --- change_data ( 'Ghysels, Yannick (d5yghyse)',          'afterSales' );
   --- change_data ( 'Demyttenaere, Bart (d5bdemyt)',        'afterSales' );
   --- change_data ( 'Castelein, Francoise (d5castef)',      'afterSales' );
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
       change_data ( 'Rekoms, Gunther (d5grekom)',           'sales'      );
   --- change_data ( 'Lampaert, Jan (d5jalamp)',             'afterSales' );
       change_data ( 'Arthus, Mahau (d5marthu)',             'sales'      );
       change_data ( 'Berghe, Nicolas (D5NBERGH)',           'sales'      );
   --- change_data ( 'Devos, Patrick (d5pdevos)',            'afterSales' );
   --- change_data ( 'De Abreu, Simon (d5sdeabr)',           'afterSales' );
   --- change_data ( 'Vlaeminck, Wouter (d5wvlaem)',         'afterSales' );
   --- change_data ( 'Naert, Yves (d5ynaert)',               'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Renard, Christophe (d5crenar)',        'afterSales' );
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
   --- change_data ( 'Vanhoorelbeke, Fabine (d5fvanho)',     'afterSales' );
       change_data ( 'Rekoms, Gunther (d5grekom)',           'sales'      );
   --- change_data ( 'Lampaert, Jan (d5jalamp)',             'afterSales' );
       change_data ( 'De Clercq, Koen (d5kodecl)',           'sales'      );
   --- change_data ( 'Balcaen, Steven (d5sbalca)',           'afterSales' );
   --- change_data ( 'Guyonnaud, Tim (d5tguyon)',            'afterSales' );
   --- change_data ( 'Vandaele, Mathieu (D5VANDAM)',         'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Vercruysse, Els (D5EVERCR)',           'afterSales' );
   --- change_data ( 'Vanhoorelbeke, Fabine (d5fvanho)',     'afterSales' );
       change_data ( 'Rekoms, Gunther (d5grekom)',           'sales'      );
   --- change_data ( 'Lampaert, Jan (d5jalamp)',             'afterSales' );
   --- change_data ( 'Balcaen, Steven (d5sbalca)',           'afterSales' );
   --- change_data ( 'Guyonnaud, Tim (d5tguyon)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Boone, Marc (d5maboon)',               'afterSales' );
   --- change_data ( 'Debue, Michel (d5mdebue)',             'afterSales' );
   --- change_data ( 'Bosch, Steve (d5sbosch)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Noël, Arnaud (d5arnoel)',              'afterSales' );
       change_data ( 'Cuomo, Benjamin (d5bcuomo)',           'sales'      );
       change_data ( 'Castel, Steve (D5CASTES)',             'sales'      );
   --- change_data ( 'Monnier, Fabrice (d5fmonni)',          'afterSales' );
       change_data ( 'Quishout, Gregory (d5gquish)',         'sales'      );
   --- change_data ( 'Michel, Maximilien (D5MICHEM)',        'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Santangelo, Filippo (d5fsanta)',       'afterSales' );
   --- change_data ( 'Camassi, Gregory (d5gcamas)',          'afterSales' );
       change_data ( 'Roba, Michael (D5MIROBA)',             'sales'      );
   --- change_data ( 'Piret, Marcel (d5mpiret)',             'afterSales' );
   --- change_data ( 'Schuijts, Sylvie (d5sschui)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Cornelissen, Benny (d5bcorne)',        'afterSales' );
   --- change_data ( 'Willems, Eddy (d5ewille)',             'afterSales' );
   --- change_data ( 'Cornelissen, Rudy (d5rucorn)',         'afterSales' );
   --- change_data ( 'Cornelissen, Steven (d5stcorn)',       'afterSales' );
       change_data ( 'Vansweevelt, Stefan (d5svansw)',       'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Noël, Arnaud (d5arnoel)',              'afterSales' );
       change_data ( 'Amoruso, Gaetan (d5gamoru)',           'sales'      );
   --- change_data ( 'Vinx, Jacques (d5jvinx)',              'afterSales' );
       change_data ( 'Chaaban, Maxime (d5mchaab)',           'sales'      );
   --- change_data ( 'Wiame, Olivier (d5owiame)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Miers, Anja (d5amiers)',               'afterSales' );
   --- change_data ( 'Van Haute, Elsie (d5evanha)',          'afterSales' );
   --- change_data ( 'Maelschaelck, David (d5jvansi)',       'afterSales' );
   --- change_data ( 'Descotte, Monique (d5mdesco)',         'afterSales' );
   --- change_data ( 'Vrijdag, Sam (d5svrijd)',              'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Aslanyan, Artem (d5aaslan)',           'afterSales' );
   --- change_data ( 'Marliere, Mireille (d5mmarli)',        'afterSales' );
   --- change_data ( 'Brancart, Pascal (d5pabran)',          'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'Wouters, Angie (d5anwout)',            'afterSales' );
       change_data ( 'Wouters, Ivo (d5iwoute)',              'sales'      );
   --- change_data ( 'Wouters, Kevin (d5kwoute)',            'afterSales' );
                                                                               --- diese zeile ist im Excel leer ...
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Waeckens, Jürgen (D5JWAECK)',          'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Wilde, Alain (d5adewil)',           'afterSales' );
       change_data ( 'Van Raemdonck, Chris (d5cvanra)',      'sales'      );
   --- change_data ( 'Mertens, Frans (d5fmerte)',            'afterSales' );
       change_data ( 'Daninck, Geert (D5GDANIN)',            'sales'      );
   --- change_data ( 'Vermeulen, Gunter (d5guverm)',         'afterSales' );
   --- change_data ( 'De Sadelaere, John (d5jdesad)',        'afterSales' );
       change_data ( 'Wuytack, Jan (D5JWUYTA)',              'sales'      );
   --- change_data ( 'Wuytack, Kjell (d5kwuyta)',            'afterSales' );
       change_data ( 'Bullaert, Marc (d5mbulla)',            'sales'      );
       change_data ( 'Paelinck, Mark (d5mpaeli)',            'sales'      );
   --- change_data ( 'Bogaerts, Pieter (d5pbogae)',          'afterSales' );
   --- change_data ( 'Mariman, Philippe (d5pmarim)',         'afterSales' );
       change_data ( 'Van der Schueren, Patrick (D5PVAND1)', 'sales'      );
       change_data ( 'Buyens, Robby (d5rbuyen)',             'sales'      );
   --- change_data ( 'Van Eeckhoven, Rudi (d5ruvane)',       'afterSales' );
       change_data ( 'De Schoenmaeker, Stefan (D5SDESCH)',   'sales'      );
       change_data ( 'Willems, Wouter (d5wwille)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Grenson, Davy (D5DGRENS)',             'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
       change_data ( 'Claeys, Ludovic (d5lclaey)',           'sales'      );
                                                                               --- diese zeile ist im Excel leer ...
   --- change_data ( 'De Roo, Carl (d5cderoo)',              'afterSales' );
   --- change_data ( 'Thooft, Jurgen (d5jhooft)',            'afterSales' );


	-- 2) dann bekommen alle anderen InScope verträge den wert After-Sales
	dbms_output.put_line ( chr(10) );
	dbms_output.put_line ( '2nd: set afterSales:' );   

	for crec in (
		select
			ID_VERTRAG
			, ID_FZGVERTRAG
			, FZGV_BEARBEITER_KAUF
			, FZGV_BEARBEITER_TECH
			, ROWID					as ROW_ID
		from
			snt.TFZGVERTRAG				fzgv
		where
			nvl ( FZGV_BEARBEITER_TECH, ' ' )	<> 'sales'
			and exists (
				select
					null 
				from
					snt.TFZGV_CONTRACTS	fzgvc
					, snt.TDFCONTR_VARIANT	cvar
				where
					fzgv.ID_VERTRAG		= fzgvc.ID_VERTRAG
					and fzgv.ID_FZGVERTRAG	= fzgvc.ID_FZGVERTRAG
					and cvar.ID_COV		= fzgvc.ID_COV
					and cvar.COV_CAPTION	not like 'MIG_OOS%'
				)
		order by
			3, 4
		)

	loop
		begin
			update
				snt.TFZGVERTRAG				fzgv
			set
				FZGV_BEARBEITER_TECH			= 'afterSales'
			where
				ROWID					= crec.ROW_ID
			;

			if 		L_FZGV_BEARBEITER_KAUF = crec.FZGV_BEARBEITER_KAUF
				or (	L_FZGV_BEARBEITER_KAUF is null
						and crec.FZGV_BEARBEITER_KAUF is null
					)
			then
				null;
			else
				dbms_output.put_line ( chr(13) );
				L_FZGV_BEARBEITER_KAUF := crec.FZGV_BEARBEITER_KAUF;
			end if;

			dbms_output.put_line ( 'InScope contract ' || lpad ( crec.ID_VERTRAG, 6, ' ' ) || '/' || rpad ( crec.ID_FZGVERTRAG, 4, ' ' )
						|| ' with salesman ' || rpad ( nvl ( crec.FZGV_BEARBEITER_KAUF, 'NULL' ), 37, ' ' ) || ' changed from ' 
						|| rpad ( nvl ( crec.FZGV_BEARBEITER_TECH, 'NULL' ), 6, ' ' ) || ' to afterSales' );
			:L_DATASUCCESS_OCCURED := :L_DATASUCCESS_OCCURED +1;

		exception
			when others then
				:L_ERROR_OCCURED := :L_ERROR_OCCURED + 1;
				dbms_output.put_line ( 'ERR: Problems while processing contract ' || crec.ID_VERTRAG ||  '/' || crec.ID_FZGVERTRAG);
				dbms_output.put_line ( SQLERRM );
		end;
	end loop;
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
alter trigger SNT.IP_NO_UPD_DEL enable;

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
