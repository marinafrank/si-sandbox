-- DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.sql
-- FraBe       18.07.2013 MKS-124736:1 creation
-- FraBe       25.07.2013 MKS-124736:2 set FZGRE_KURS to 1

spool DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.log

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

variable nachricht        varchar2 ( 100 char );
variable L_ERROR_COUNT    number;
variable L_SCRIPTNAME     varchar2 ( 100 char );
exec :L_SCRIPTNAME        := 'DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.sql';

prompt

whenever sqlerror exit sql.sqlcode

declare

   -------------------------------------------------------------------------------------------------------
   -- einstellungen für div. checks
   -------------------------------------------------------------------------------------------------------
   -- 1) wenn SYSDBA priv benötigt wird, folgende var auf true setzen
   L_SYSDBA_PRIV_NEEDED    boolean                         := false;          -- false or true
   L_SYSDBA_PRIV           VARCHAR2 (  1 char );

   -------------------------------------------------------------------------------------------------------
   -- 2) unter welchem user muß das script laufen?
   L_SOLLUSER              VARCHAR2 ( 30 char ) := 'SNT';
   L_ISTUSER               VARCHAR2 ( 30 char ) := user;
   
   -------------------------------------------------------------------------------------------------------
   -- 3) welche version muß die DB auf jeden fall aufweisen (- oder höher -): 
   L_MAJOR_MIN             integer := 2;
   L_MINOR_MIN             integer := 8;
   L_REVISION_MIN          integer := 0;
   L_BUILD_MIN             integer := 0;

   L_MAJOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MAJOR',    NULL, 'YES' );
   L_MINOR_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'MINOR',    NULL, 'YES' );
   L_REVISION_IST          integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'REVISION', NULL, 'YES' );
   L_BUILD_IST             integer := snt.get_tglobal_settings ( 'DB', 'RELEASE', 'BUILD',    NULL, 'YES' );

   -------------------------------------------------------------------------------------------------------
   -- 4) falls das script nur gegen ein einziges MPC laufen darf, hier true angeben, bzw. den namen des MPC: 
   L_MPC_CHECK             boolean                         := true;           -- false or true
   L_MPC_SOLL              snt.TGLOBAL_SETTINGS.VALUE%TYPE := 'MBBeLux';
   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName' );

   -------------------------------------------------------------------------------------------------------
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

-- main part for < selecting or checking or correcting code >

declare

     L_ID_CURRENCY    snt.TCURRENCY.ID_CURRENCY%type;

     procedure convertToEUR 
             ( I_ID_SEQ_FZGRECHNUNG              snt.TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG%type
             , I_ID_VERTRAG                      snt.TFZGRECHNUNG.ID_VERTRAG%type
             , I_ID_FZGVERTRAG                   snt.TFZGRECHNUNG.ID_FZGVERTRAG%type
             , I_ID_BELEGART                     snt.TFZGRECHNUNG.ID_BELEGART%type
             , I_CUR_CODE_ORIG                   snt.TCURRENCY.CUR_CODE%type
             , I_FZGRE_BELEGNR                   snt.TFZGRECHNUNG.FZGRE_BELEGNR%type
             , I_FZGRE_BELEGDATUM                varchar2
             , I_FZGRE_MATBRUTTO                 snt.TFZGRECHNUNG.FZGRE_MATBRUTTO%type
             , I_FZGRE_MATNETTO                  snt.TFZGRECHNUNG.FZGRE_MATNETTO%type
             , I_FZGRE_AWSUMME                   snt.TFZGRECHNUNG.FZGRE_AWSUMME%type
             , I_FZGRE_KURS                      snt.TFZGRECHNUNG.FZGRE_KURS%type
             , I_FZGRE_RESUMME_ORIG              snt.TFZGRECHNUNG.FZGRE_RESUMME%type
             , I_FZGRE_RESUMME_EUR               snt.TFZGRECHNUNG.FZGRE_RESUMME%type
             ) is
             ---

               L_ID_SEQ_FZGRECHNUNG              snt.TFZGRECHNUNG.ID_SEQ_FZGRECHNUNG%type;
               L_CUR_CODE                        snt.TCURRENCY.CUR_CODE%type;
               L_FZGRE_RESUMME_ORIG              snt.TFZGRECHNUNG.FZGRE_RESUMME%type;
               L_FZGRE_RESUMME_EUR               snt.TFZGRECHNUNG.FZGRE_RESUMME%type;
               L_BELART_CAPTION                  snt.TBELEGARTEN.BELART_CAPTION%type;

             ---

               L_TFZGRECHNUNG_ROWID              varchar2 ( 50 char );
               L_calc_CUR_RATE_EUR               number;
               L_ALREADY_CONVERTED_ORIG          number;
               L_ALREADY_CONVERTED_EUR           number;

             ---

               L_FZGRE_MATBRUTTO_ORIG            snt.TFZGRECHNUNG.FZGRE_MATBRUTTO%type;
               L_FZGRE_MATNETTO_ORIG             snt.TFZGRECHNUNG.FZGRE_MATNETTO%type;
               L_FZGRE_AWSUMME_ORIG              snt.TFZGRECHNUNG.FZGRE_AWSUMME%type;
               L_FZGRE_SUM_OTHER_ORIG            snt.TFZGRECHNUNG.FZGRE_SUM_OTHER%type;
               L_FZGRE_SUM_REJECTED_ORIG         snt.TFZGRECHNUNG.FZGRE_SUM_REJECTED%type;

               L_FZGRE_SCCS_AMNT_LABOUR_ORIG     snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_LABOUR%type;
               L_FZGRE_SCCS_AMNT_PARTS_ORIG      snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_PARTS%type;
               L_FZGRE_SCCS_AMNT_SUBLETS_ORIG    snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_SUBLETS%type;
               L_FZGRE_SCCS_AMNT_DLRHND_ORIG     snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_DLRHND%type;
               L_FZGRE_SC_PROVISION_ORIG         snt.TFZGRECHNUNG.FZGRE_SC_PROVISION%type;
               L_FZGRE_SC_BUYUP_ORIG             snt.TFZGRECHNUNG.FZGRE_SC_BUYUP%type;

             ---

               L_FZGRE_MATBRUTTO_EUR             snt.TFZGRECHNUNG.FZGRE_MATBRUTTO%type;
               L_FZGRE_MATNETTO_EUR              snt.TFZGRECHNUNG.FZGRE_MATNETTO%type;
               L_FZGRE_AWSUMME_EUR               snt.TFZGRECHNUNG.FZGRE_AWSUMME%type;
               L_FZGRE_SUM_OTHER_EUR             snt.TFZGRECHNUNG.FZGRE_SUM_OTHER%type;
               L_FZGRE_SUM_REJECTED_EUR          snt.TFZGRECHNUNG.FZGRE_SUM_REJECTED%type;

               L_FZGRE_SCCS_AMNT_LABOUR_EUR      snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_LABOUR%type;
               L_FZGRE_SCCS_AMNT_PARTS_EUR       snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_PARTS%type;
               L_FZGRE_SCCS_AMNT_SUBLETS_EUR     snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_SUBLETS%type;
               L_FZGRE_SCCS_AMNT_DLRHND_EUR      snt.TFZGRECHNUNG.FZGRE_SCCS_AMNT_DLRHND%type;
               L_FZGRE_SC_PROVISION_EUR          snt.TFZGRECHNUNG.FZGRE_SC_PROVISION%type;
               L_FZGRE_SC_BUYUP_EUR              snt.TFZGRECHNUNG.FZGRE_SC_BUYUP%type;
                                                                     
             ---

             procedure reportSuccess is
             begin
                 dbms_output.put_line ( 'successfully converted:  ' || 'SIRIUS Invoice Number: ' || to_char ( I_ID_SEQ_FZGRECHNUNG, '9999999' )
                                     || ' CO: ' || lpad ( I_ID_VERTRAG, 6, ' ' ) || '/' || rpad ( I_ID_FZGVERTRAG, 4, ' ' ) 
                                     || ' InvoiceNumber: '   || rpad ( I_FZGRE_BELEGNR, 10, ' ' )
                                     || ' InvoiceDate: '     || I_FZGRE_BELEGDATUM );
             end;
             ---
             procedure reportError 
                     ( I_REASON      varchar2 
                     ) is
             begin
                 dbms_output.put_line ( I_REASON || 'SIRIUS Invoice Number: ' || to_char ( I_ID_SEQ_FZGRECHNUNG, '9999999' )
                                     || ' CO: ' || lpad ( I_ID_VERTRAG, 6, ' ' ) || '/' || rpad ( I_ID_FZGVERTRAG, 4, ' ' ) 
                                     || ' InvoiceNumber: '   || rpad ( I_FZGRE_BELEGNR, 10, ' ' )
                                     || ' InvoiceDate: '     || I_FZGRE_BELEGDATUM
                                     || ' passed/real CUR: ' || I_CUR_CODE_ORIG || '/' || nvl ( L_CUR_CODE, '   ' )
                                     || ' passed/real local value: ' || to_char ( I_FZGRE_RESUMME_ORIG, '9G999G990D99' ) || '/' || nvl ( to_char ( L_FZGRE_RESUMME_ORIG, '9G999G990D99' ), '             ' )
                                     || ' InvoiceType: ' || L_BELART_CAPTION );
                 :L_ERROR_COUNT := :L_ERROR_COUNT + 1;
             end;
             ---
             procedure reportError_Values is
             begin
                 dbms_output.put_line ( 'These values don''t fit:  SIRIUS Invoice Number: ' || to_char ( I_ID_SEQ_FZGRECHNUNG, '9999999' ) 
                                     || ' CO: ' || lpad ( I_ID_VERTRAG, 6, ' ' ) || '/' || rpad ( I_ID_FZGVERTRAG, 4, ' ' ) 
                                     || ' InvoiceNumber: '   || rpad ( I_FZGRE_BELEGNR, 10, ' ' )
                                     || ' InvoiceDate: '     || I_FZGRE_BELEGDATUM
                                     || ' passed/real CUR: ' || I_CUR_CODE_ORIG || '/' || nvl ( L_CUR_CODE, '   ' )
                                     || ' passed/real EUR value: ' || to_char ( I_FZGRE_RESUMME_EUR, '9G999G990D99' ) || '/' || nvl ( to_char ( L_FZGRE_RESUMME_EUR, '9G999G990D99' ), '             ' )
                                                                   || '/' || to_char ( L_FZGRE_MATBRUTTO_EUR + L_FZGRE_MATNETTO_EUR + L_FZGRE_AWSUMME_EUR + L_FZGRE_SUM_OTHER_EUR, '9G999G990D99' )
                                     || ' InvoiceType: ' || L_BELART_CAPTION );
                 :L_ERROR_COUNT := :L_ERROR_COUNT + 1;
             end;
             
     begin

             -- 1st: clear local values
             L_CUR_CODE              := null;
             L_FZGRE_RESUMME_ORIG    := null;
             L_BELART_CAPTION        := null;
             
             -- 2nd: check übergebene werte auf richtigkeit
             select r.ROWID
                  , r.ID_SEQ_FZGRECHNUNG
                  , c.CUR_CODE
                  , b.BELART_CAPTION
                  , r.FZGRE_RESUMME
                  , r.FZGRE_SCCS_AMNT_LABOUR
                  , r.FZGRE_SCCS_AMNT_PARTS
                  , r.FZGRE_SCCS_AMNT_SUBLETS
                  , r.FZGRE_SCCS_AMNT_DLRHND
                  , r.FZGRE_SUM_REJECTED
                  , r.FZGRE_SC_PROVISION
                  , r.FZGRE_SC_BUYUP
                  , r.FZGRE_MATBRUTTO
                  , r.FZGRE_MATNETTO
                  , r.FZGRE_AWSUMME
                  , r.FZGRE_SUM_OTHER
               into L_TFZGRECHNUNG_ROWID
                  , L_ID_SEQ_FZGRECHNUNG
                  , L_CUR_CODE
                  , L_BELART_CAPTION
                  , L_FZGRE_RESUMME_ORIG
                  , L_FZGRE_SCCS_AMNT_LABOUR_ORIG
                  , L_FZGRE_SCCS_AMNT_PARTS_ORIG
                  , L_FZGRE_SCCS_AMNT_SUBLETS_ORIG
                  , L_FZGRE_SCCS_AMNT_DLRHND_ORIG
                  , L_FZGRE_SC_PROVISION_ORIG
                  , L_FZGRE_SC_BUYUP_ORIG
                  , L_FZGRE_SUM_REJECTED_ORIG
                  , L_FZGRE_MATBRUTTO_ORIG
                  , L_FZGRE_MATNETTO_ORIG
                  , L_FZGRE_AWSUMME_ORIG
                  , L_FZGRE_SUM_OTHER_ORIG
               from snt.TFZGRECHNUNG   r
                  , snt.TCURRENCY      c
                  , snt.TBELEGARTEN    b
              where r.ID_BELEGART        = b.ID_BELEGART
                and r.ID_CURRENCY        = c.ID_CURRENCY
                and r.ID_SEQ_FZGRECHNUNG = I_ID_SEQ_FZGRECHNUNG
                and r.ID_VERTRAG         = I_ID_VERTRAG
                and r.ID_FZGVERTRAG      = I_ID_FZGVERTRAG
                and r.FZGRE_BELEGNR      = I_FZGRE_BELEGNR
                and r.ID_BELEGART        = I_ID_BELEGART
                and r.FZGRE_BELEGDATUM   = to_date ( I_FZGRE_BELEGDATUM, 'DD.MM.YYYY' );

             -- ausgabe fehler wenn die realen DB werte von den übergebenen abweichen
             if   L_CUR_CODE             <> I_CUR_CODE_ORIG
               or L_FZGRE_RESUMME_ORIG   <> I_FZGRE_RESUMME_ORIG
               or L_FZGRE_MATBRUTTO_ORIG <> I_FZGRE_MATBRUTTO
               or L_FZGRE_MATNETTO_ORIG  <> I_FZGRE_MATNETTO
               or L_FZGRE_AWSUMME_ORIG   <> I_FZGRE_AWSUMME
             then reportError ( 'These new values differ: ' );
             else -- 3rd: werte in EUR umwandeln:
                  -- a) zuerst mit allgemeinem umrechnungskurs wie übergeben
                  L_FZGRE_RESUMME_EUR            := round ( L_FZGRE_RESUMME_ORIG           * I_FZGRE_KURS, 2 );
                  L_FZGRE_SCCS_AMNT_LABOUR_EUR   := round ( L_FZGRE_SCCS_AMNT_LABOUR_ORIG  * I_FZGRE_KURS, 2 );
                  L_FZGRE_SCCS_AMNT_PARTS_EUR    := round ( L_FZGRE_SCCS_AMNT_PARTS_ORIG   * I_FZGRE_KURS, 2 );
                  L_FZGRE_SCCS_AMNT_SUBLETS_EUR  := round ( L_FZGRE_SCCS_AMNT_SUBLETS_ORIG * I_FZGRE_KURS, 2 );
                  L_FZGRE_SCCS_AMNT_DLRHND_EUR   := round ( L_FZGRE_SCCS_AMNT_DLRHND_ORIG  * I_FZGRE_KURS, 2 );
                  L_FZGRE_SC_PROVISION_EUR       := round ( L_FZGRE_SC_PROVISION_ORIG      * I_FZGRE_KURS, 2 );
                  L_FZGRE_SC_BUYUP_EUR           := round ( L_FZGRE_SC_BUYUP_ORIG          * I_FZGRE_KURS, 2 );
                  L_FZGRE_SUM_REJECTED_EUR       := round ( L_FZGRE_SUM_REJECTED_ORIG      * I_FZGRE_KURS, 2 );
                  
                  -- b) bei folgenden teilbeträgen gibt es eine besondere berechnungsart: der umrechnungskurs ist da genauer, und es gibt keine rundungsdifferenzen:
                  -- der umrechnungskurs berechnet sich nicht anhand vom übergebenen kurs, sondern jenen beträgen, die noch nicht umgerechnet wurden
                  L_ALREADY_CONVERTED_ORIG         := 0;
                  L_ALREADY_CONVERTED_EUR          := 0;
                  if     I_FZGRE_RESUMME_ORIG 
                       - L_ALREADY_CONVERTED_ORIG   = 0
                  then   L_FZGRE_MATBRUTTO_EUR     := 0;
                  else   L_calc_CUR_RATE_EUR       := ( I_FZGRE_RESUMME_EUR  - L_ALREADY_CONVERTED_EUR ) / ( I_FZGRE_RESUMME_ORIG - L_ALREADY_CONVERTED_ORIG );
                         L_FZGRE_MATBRUTTO_EUR     := round ( L_FZGRE_MATBRUTTO_ORIG * L_calc_CUR_RATE_EUR, 2 );
                  end  if;
                  
                  L_ALREADY_CONVERTED_ORIG         := L_FZGRE_MATBRUTTO_ORIG;
                  L_ALREADY_CONVERTED_EUR          := L_FZGRE_MATBRUTTO_EUR;
                  if     I_FZGRE_RESUMME_ORIG 
                       - L_ALREADY_CONVERTED_ORIG   = 0
                  then   L_FZGRE_MATNETTO_EUR      := 0;
                  else   L_calc_CUR_RATE_EUR       := ( I_FZGRE_RESUMME_EUR  - L_ALREADY_CONVERTED_EUR ) / ( I_FZGRE_RESUMME_ORIG - L_ALREADY_CONVERTED_ORIG );
                         L_FZGRE_MATNETTO_EUR      := round ( L_FZGRE_MATNETTO_ORIG  * L_calc_CUR_RATE_EUR, 2 );
                  end  if;
                  
                  L_ALREADY_CONVERTED_ORIG         := L_ALREADY_CONVERTED_ORIG  + L_FZGRE_MATNETTO_ORIG;
                  L_ALREADY_CONVERTED_EUR          := L_ALREADY_CONVERTED_EUR   + L_FZGRE_MATNETTO_EUR;
                  if     I_FZGRE_RESUMME_ORIG 
                       - L_ALREADY_CONVERTED_ORIG   = 0
                  then   L_FZGRE_AWSUMME_EUR       := 0;
                  else   L_calc_CUR_RATE_EUR       := ( I_FZGRE_RESUMME_EUR  - L_ALREADY_CONVERTED_EUR ) / ( I_FZGRE_RESUMME_ORIG - L_ALREADY_CONVERTED_ORIG );
                         L_FZGRE_AWSUMME_EUR       := round ( L_FZGRE_AWSUMME_ORIG   * L_calc_CUR_RATE_EUR, 2 );
                  end  if;
                  
                  L_ALREADY_CONVERTED_ORIG         := L_ALREADY_CONVERTED_ORIG  + L_FZGRE_AWSUMME_ORIG;
                  L_ALREADY_CONVERTED_EUR          := L_ALREADY_CONVERTED_EUR   + L_FZGRE_AWSUMME_EUR;
                  if     I_FZGRE_RESUMME_ORIG 
                       - L_ALREADY_CONVERTED_ORIG   = 0
                  then   L_FZGRE_SUM_OTHER_EUR     := 0;
                  else   L_calc_CUR_RATE_EUR       := ( I_FZGRE_RESUMME_EUR  - L_ALREADY_CONVERTED_EUR ) / ( I_FZGRE_RESUMME_ORIG - L_ALREADY_CONVERTED_ORIG );
                         L_FZGRE_SUM_OTHER_EUR     := round ( L_FZGRE_SUM_OTHER_ORIG * L_calc_CUR_RATE_EUR, 2 );
                  end  if;
                  
                  -- 4th: check, ob es bei den berechneten EUR beträgen entweder rundungsdifferenzen gibt, oder die real EUR RESUMME von der erwarteten und übergebenen abweicht
                  -- -> report error
                  if   L_FZGRE_RESUMME_EUR <> I_FZGRE_RESUMME_EUR
                    or L_FZGRE_RESUMME_EUR <> L_FZGRE_MATBRUTTO_EUR 
                                            + L_FZGRE_MATNETTO_EUR 
                                            + L_FZGRE_AWSUMME_EUR 
                                            + L_FZGRE_SUM_OTHER_EUR
                  then reportError_Values;
                  else -- 5th: zurückschreiben werte
                       -- a) TFZGRECHNUNG anhand umgerechneter werte wie vorhin beschrieben
                       update snt.TFZGRECHNUNG
                          set ID_CURRENCY               = L_ID_CURRENCY
                            , FZGRE_KURS                = 1                             -- MKS-124736:2
                            , FZGRE_RESUMME             = L_FZGRE_RESUMME_EUR
                            , FZGRE_SCCS_AMNT_LABOUR    = L_FZGRE_SCCS_AMNT_LABOUR_EUR
                            , FZGRE_SCCS_AMNT_PARTS     = L_FZGRE_SCCS_AMNT_PARTS_EUR
                            , FZGRE_SCCS_AMNT_SUBLETS   = L_FZGRE_SCCS_AMNT_SUBLETS_EUR
                            , FZGRE_SCCS_AMNT_DLRHND    = L_FZGRE_SCCS_AMNT_DLRHND_EUR
                            , FZGRE_SUM_REJECTED        = L_FZGRE_SUM_REJECTED_EUR
                            , FZGRE_SC_PROVISION        = L_FZGRE_SC_PROVISION_EUR
                            , FZGRE_SC_BUYUP            = L_FZGRE_SC_BUYUP_EUR
                            , FZGRE_MATBRUTTO           = L_FZGRE_MATBRUTTO_EUR
                            , FZGRE_MATNETTO            = L_FZGRE_MATNETTO_EUR
                            , FZGRE_AWSUMME             = L_FZGRE_AWSUMME_EUR
                            , FZGRE_SUM_OTHER           = L_FZGRE_SUM_OTHER_EUR
                        where ROWID = L_TFZGRECHNUNG_ROWID;
                        
                       -- b) TINV_POSITION / TI56_RT20 wieder anhand allgemeinem übergebenen umrechnungskurs             
                       update snt.TINV_POSITION
                          set IP_LISTPRICE    = round ( IP_LISTPRICE    * I_FZGRE_KURS, 2 )
                            , IP_GROSSPRICE   = round ( IP_GROSSPRICE   * I_FZGRE_KURS, 2 )
                            , IP_SUM_WORK     = round ( IP_SUM_WORK     * I_FZGRE_KURS, 2 )
                            , IP_SUM_PART     = round ( IP_SUM_PART     * I_FZGRE_KURS, 2 )
                            , IP_SUM_OTHER    = round ( IP_SUM_OTHER    * I_FZGRE_KURS, 2 )
                            , IP_REJECT_SUM   = round ( IP_REJECT_SUM   * I_FZGRE_KURS, 2 )
                        where ID_SEQ_FZGRECHNUNG = L_ID_SEQ_FZGRECHNUNG;
						           
                       update snt.TI56_RT20
                          set I56R2_SC_SHARE_LABOUR    = round ( I56R2_SC_SHARE_LABOUR    * I_FZGRE_KURS, 2 )
                            , I56R2_SC_SHARE_PARTS     = round ( I56R2_SC_SHARE_PARTS     * I_FZGRE_KURS, 2 )
                            , I56R2_SC_SHARE_SUBLETS   = round ( I56R2_SC_SHARE_SUBLETS   * I_FZGRE_KURS, 2 )
                            , I56R2_SC_SHARE_HANDLING  = round ( I56R2_SC_SHARE_HANDLING  * I_FZGRE_KURS, 2 )
                            , I56R2_SCCS_AMNT_LABOUR   = round ( I56R2_SCCS_AMNT_LABOUR   * I_FZGRE_KURS, 2 )
                            , I56R2_SCCS_AMNT_PARTS    = round ( I56R2_SCCS_AMNT_PARTS    * I_FZGRE_KURS, 2 )
                            , I56R2_SCCS_AMNT_SUBLETS  = round ( I56R2_SCCS_AMNT_SUBLETS  * I_FZGRE_KURS, 2 )
                            , I56R2_SCCS_AMNT_DLRHND   = round ( I56R2_SCCS_AMNT_DLRHND   * I_FZGRE_KURS, 2 )
                        where ID_SEQ_FZGRECHNUNG = L_ID_SEQ_FZGRECHNUNG;
                        
                       -- 6th: ausgabe protokollzeile
                       reportSuccess;
                  end  if;
             end  if;
              
     -- ausgabe fehler, wenn keine werkstattrechnung anhand der vorgegebenen daten ID_SEQ_FZGRECHNUNG / ID_VERTRAG / 
     -- ID_FZGVERTRAG / ID_BELEGART / FZGRE_BELEGNR / FZGRE_BELEGDATUM / CUR_CODE gefunden werden konnte
     exception when NO_DATA_FOUND then reportError ( 'Invoice not found:       ' );
     end;

begin

     :L_ERROR_COUNT  := 0;
     
     select   ID_CURRENCY 
       into L_ID_CURRENCY
       from snt.TCURRENCY
      where CUR_CODE = snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'LOCALE_SCURRENCY', 'EUR' );
      
--   convertToEUR (   ID_SEQ_FZGRECHNUNG, ID_VERTRAG, ID_FZGVERTRAG, ID_BELEGART, ID_CURRENCY_ORIG, FZGRE_BELEGNR, FZGRE_BELEGDATUM, FZGRE_MATBRUTTO, FZGRE_MATNETTO, FZGRE_AWSUMME, FZGRE_KURS, FZGRE_RESUMME_ORIG, FZGRE_RESUMME_EURO
     convertToEUR (   972906, '038660', '0001', 0, 'BGL', '1211057905', '09.07.2012',      0.00,       2384.04,        171.50,  0.6135500000,      2555.54,    1567.95 );
     convertToEUR (   978151, '038660', '0001', 0, 'BGL', '0579051',    '09.07.2012',      0.00,       2384.04,        171.50,  0.5112940000,      2555.54,    1306.63 );
     convertToEUR (   978150, '038660', '0001', 1, 'BGL', '0579050',    '09.07.2012',      0.00,       2384.04,        171.50,  0.6135500000,      2555.54,    1567.95 );
     convertToEUR (   303311, '006685', '0002', 0, 'CHF', '422559291',  '09.04.2003',      3.80,          0.00,         94.50,  0.6250000000,       105.75,      66.09 );
     convertToEUR (   330469, '016486', '0001', 0, 'CHF', '18150224',   '04.08.2003',      0.00,        149.52,        163.90,  0.6470000000,       337.25,     218.20 );
     convertToEUR (   318235, '015767', '0001', 0, 'CHF', '18150194',   '16.05.2003',      0.00,         87.33,        365.94,  0.6470000000,       453.27,     293.27 );
     convertToEUR (   313074, '016486', '0001', 0, 'CHF', '18150179',   '27.03.2003',      0.00,        261.28,       1236.70,  0.6250000000,      1611.85,    1007.41 );
     convertToEUR (   318472, '020479', '0001', 0, 'CHF', '1030738',    '12.05.2003',      0.00,         15.10,        377.80,  0.6470000000,       392.90,     254.21 );
     convertToEUR (   347525, '015767', '0001', 0, 'CHF', '1815019400', '16.05.2003',      0.00,         87.33,        365.94,  0.6437000000,       487.70,     313.93 );
     convertToEUR (   318021, '020183', '0001', 0, 'CHF', '342906',     '24.02.2003',      0.00,         96.85,          0.00,  0.6250000000,        96.85,      60.53 );
     convertToEUR (   355092, '013909', '0001', 0, 'CHF', '18150288',   '22.12.2003',      0.00,        958.55,        862.40,  0.6414360000,      1820.95,    1168.02 );
     convertToEUR (   356247, '016486', '0001', 0, 'CHF', '18150291',   '08.01.2004',      0.00,        405.13,        894.00,  0.6414360000,      1397.85,     896.63 );
     convertToEUR (   409350, '012530', '0001', 4, 'CHF', '6306301183', '02.08.2004',      0.00,        635.00,        647.50,  0.6190800000,      1369.50,     847.83 );
     convertToEUR (   409022, '016486', '0001', 0, 'CHF', '359518',     '27.08.2004',      0.00,        221.47,        327.80,  0.6514650000,       591.00,     385.02 );
     convertToEUR (   406837, '013909', '0001', 0, 'CHF', '586742181',  '29.06.2004',      0.00,       1449.80,       1230.80,  0.6461200000,      2680.60,    1731.99 );
     convertToEUR (   385121, '022623', '0001', 0, 'CHF', '308368',     '16.04.2004',      0.00,         36.10,         65.00,  0.6430450000,       108.80,      69.96 );
     convertToEUR (   398598, '007265', '0001', 0, 'CHF', '18150318',   '27.05.2004',      0.00,         16.30,         87.60,  0.6593260000,       103.90,      68.50 );
     convertToEUR (   385106, '015653', '0001', 0, 'CHF', '18150313',   '26.04.2004',      0.00,       1164.85,        620.20,  0.6430450000,      2185.95,    1405.66 );
     convertToEUR (   410019, '008720', '0003', 0, 'CHF', '11033',      '26.11.2003',      0.00,         71.60,        160.40,  0.6514650000,       249.65,     162.64 );
     convertToEUR (   410026, '013903', '0001', 0, 'CHF', '320919',     '17.08.2004',      0.00,         86.50,        247.00,  0.6514650000,       358.85,     233.78 );
     convertToEUR (   414960, '026216', '0001', 0, 'CHF', '309151',     '23.08.2004',      0.00,       1318.80,       1014.00,  0.6514650000,      2510.10,    1635.24 );
     convertToEUR (   404453, '008720', '0011', 0, 'CHF', '470476291',  '15.07.2004',      0.00,      20507.75,       3753.00,  0.6527410000,     27615.70,   18025.90 );
     convertToEUR (   447091, '018746', '0001', 0, 'CHF', '324209191',  '14.12.2004',      0.00,        101.20,        112.30,  0.6486760000,       229.70,     149.00 );
     convertToEUR (   456807, '008720', '0003', 0, 'CHF', '1576200',    '27.12.2004',      0.00,          0.00,        200.00,  0.6464540000,       215.20,     139.12 );
     convertToEUR (   455355, '009171', '0001', 0, 'CHF', '219092',     '22.02.2005',      0.00,        568.20,        609.00,  0.6464540000,      1177.20,     761.01 );
     convertToEUR (   455356, '018888', '0001', 0, 'CHF', '5195',       '02.03.2005',      0.00,        190.10,        351.40,  0.6464540000,       541.50,     350.05 );
     convertToEUR (   459365, '025825', '0001', 0, 'CHF', '229675',     '02.03.2005',      0.00,        811.03,        908.50,  0.6427970000,      2033.15,    1306.90 );
     convertToEUR (   501404, '022623', '0001', 0, 'CHF', '6276110',    '25.08.2005',      0.00,        405.10,        402.90,  0.6443710000,       869.40,     560.22 );
     convertToEUR (   507970, '020211', '0001', 0, 'CHF', '1056240',    '22.09.2005',      0.00,        321.00,        410.00,  0.6444960000,       804.20,     518.30 );
     convertToEUR (   520144, '017133', '0001', 0, 'CHF', '1654',       '03.01.2006',      0.00,        321.00,         71.50,  0.6439560000,       422.35,     271.97 );
     convertToEUR (   521768, '024914', '0001', 0, 'CHF', '327382',     '09.01.2006',      0.00,        467.90,        352.30,  0.6439560000,       882.55,     568.32 );
     convertToEUR (   535063, '017497', '0001', 0, 'CHF', '243265',     '04.01.2006',      0.00,        321.00,          0.00,  0.6419720000,       345.40,     221.74 );
     convertToEUR (   398607, '013909', '0001', 0, 'CHF', '18150319',   '27.05.2004',      0.00,        805.15,        228.90,  0.6593260000,      1034.05,     681.78 );
     convertToEUR (   638910, '037064', '0001', 0, 'CHF', '10525107',   '13.11.2007',      0.00,        643.48,        277.00,  0.6190800000,       920.48,     569.85 );
     convertToEUR (   669698, '018746', '0001', 0, 'CHF', '65022076',   '25.04.2008',      0.00,        742.20,         56.40,  0.6190800000,       798.60,     494.40 );
     convertToEUR (   669701, '034827', '0002', 0, 'CHF', '227857',     '15.02.2008',      0.00,        703.90,        227.50,  0.6190800000,       931.40,     576.61 );
     convertToEUR (   669702, '015407', '0001', 0, 'CHF', '65018926',   '22.02.2008',      0.00,        719.70,       2021.09,  0.6190800000,      2740.79,    1696.77 );
     convertToEUR (   655882, '029124', '0001', 0, 'CHF', '75626',      '24.01.2008',     40.80,         63.00,        159.50,  0.6190800000,       263.30,     163.00 );
     convertToEUR (   686257, '029265', '0001', 0, 'CHF', '10528029',   '11.09.2008',      0.00,       1443.51,        215.84,  0.6275000000,      1659.35,    1041.24 );
     convertToEUR (   688297, '032067', '0001', 0, 'CHF', '10527535',   '16.09.2008',      0.00,       1237.40,        553.80,  0.6275000000,      1791.20,    1123.98 );
     convertToEUR (   679153, '022021', '0003', 0, 'CHF', '65025662',   '09.07.2008',      0.00,       1291.55,         98.15,  0.6190800000,      1389.70,     860.34 );
     convertToEUR (   712534, '029778', '0001', 0, 'CHF', '38680',      '22.10.2008',      0.00,        180.55,        120.80,  0.6275000000,       301.35,     189.10 );
     convertToEUR (   712490, '028268', '0001', 0, 'CHF', '202667',     '24.07.2008',      0.00,          9.86,        108.08,  0.6275000000,       117.94,      74.01 );
     convertToEUR (   712491, '030839', '0001', 0, 'CHF', '489007',     '11.08.2008',      0.00,         76.20,        122.40,  0.6251950000,       198.60,     124.16 );
     convertToEUR (   772737, '034541', '0001', 0, 'CHF', '15028523',   '12.08.2009',      0.00,       1793.85,        412.80,  0.6535520000,      2206.65,    1442.16 );
     convertToEUR (   768884, '034208', '0001', 0, 'CHF', '259911/181', '22.07.2009',      0.00,          0.00,          0.00,  0.6535520000,        74.00,      48.36 );
     convertToEUR (   772928, '032233', '0001', 0, 'CHF', '10520368',   '05.08.2009',      0.00,        573.00,        140.00,  0.6535520000,       713.00,     465.98 );
     convertToEUR (   773641, '036104', '0001', 0, 'CHF', '3165401',    '13.03.2009',      0.00,         27.60,        197.60,  0.6535520000,       225.20,     147.18 );
     convertToEUR (   805560, '042820', '0001', 0, 'CHF', '10532871',   '10.02.2010',      0.00,        321.90,        232.00,  0.6822210000,       553.90,     377.88 );
     convertToEUR (   812205, '033271', '0001', 0, 'CHF', '501629/181', '25.02.2010',     15.30,         16.60,        382.20,  0.6891110000,       414.10,     285.36 );
     convertToEUR (   809802, '038338', '0001', 4, 'CHF', '20532087',   '19.01.2010',      0.00,        795.72,        917.05,  0.6822210000,      1712.77,    1168.49 );
     convertToEUR (   820801, '035980', '0001', 0, 'CHF', '508604',     '23.04.2010',     93.50,          0.00,        604.20,  0.6993070000,       721.85,     504.79 );
     convertToEUR (   938130, '044400', '0001', 4, 'CHF', '690947291',  '21.02.2012',      0.00,       -944.50,          0.00,  0.8099000000,      -944.50,    -764.95 );
     convertToEUR (   924694, '036130', '0001', 0, 'CHF', '10539804',   '07.12.2011',      0.00,         24.31,          0.00,  0.8099000000,        24.31,      19.69 );
     convertToEUR (   871850, '042820', '0001', 0, 'CHF', '10536458',   '25.01.2011',      0.00,        169.25,        214.50,  0.7760000000,       383.75,     297.79 );
     convertToEUR (   868537, '038266', '0001', 0, 'CHF', '16913900',   '29.12.2010',      0.00,       1255.00,        345.25,  0.7760000000,      1600.25,    1241.79 );
     convertToEUR (   885366, '034208', '0001', 0, 'CHF', '333890',     '06.04.2011',      0.00,         80.00,         56.10,  0.7738000000,       136.10,     105.31 );
     convertToEUR (   946568, '040540', '0001', 4, 'CHF', '10541009',   '05.04.2012',      0.00,        441.10,        615.00,  0.8099000000,      1056.10,     855.34 );
     convertToEUR (   935737, '044400', '0001', 4, 'CHF', '684597291',  '27.01.2012',      0.00,       4959.10,       1233.70,  0.8099000000,      6401.85,    5184.86 );
     convertToEUR (   825679, '029778', '0001', 0, 'CHF', '13389',      '13.01.2010',      0.00,        513.40,          0.00,  0.6993070000,       513.40,     359.02 );
     convertToEUR (   847305, '034208', '0001', 0, 'CHF', '309409',     '17.09.2010',      0.00,        481.50,        948.60,  0.7988000000,      1430.10,    1142.36 );
     convertToEUR (   970821, '044678', '0001', 0, 'CHF', '10542580',   '06.09.2012',      0.00,        100.30,         30.00,  0.8250000000,       130.30,     107.50 );
     convertToEUR (   972904, '047990', '0005', 0, 'CHF', '1071223',    '07.08.2012',      0.00,         31.12,         40.50,  0.8275000000,        71.62,      59.27 );
     convertToEUR (   991010, '047990', '0002', 0, 'CHF', '65108187',   '13.12.2012',      0.00,        726.00,        162.00,  0.8278500000,       888.00,     735.13 );
     convertToEUR (  1009803, '060497', '0014', 0, 'CHF', '10532542',   '18.04.2013',      0.00,          0.00,          0.00,  0.8779050000,      2900.93,    2546.74 );
     convertToEUR (   330628, '009053', '0020', 0, 'CZK', '274452',     '26.02.2003',      0.00,       5636.40,          0.00,  0.0308300000,      5636.40,     173.77 );
     convertToEUR (   515632, '006653', '0002', 0, 'CZK', '280937',     '02.09.2005',      0.00,      39161.19,       9801.00,  0.0341990000,     48962.20,    1674.46 );
     convertToEUR (   445831, '020121', '0001', 0, 'DKK', '28276825',   '30.11.2004',      0.00,         67.75,        108.55,  0.1344120000,       232.85,      31.30 );
     convertToEUR (   445833, '015740', '0001', 0, 'DKK', '27223133',   '16.09.2004',      0.00,        199.00,       1736.80,  0.1344120000,      2650.80,     356.30 );
     convertToEUR (   399738, '016365', '0001', 0, 'DKK', '25110008',   '13.02.2004',      0.00,        732.00,        883.50,  0.1345290000,      1701.50,     228.90 );
     convertToEUR (   399744, '016365', '0001', 0, 'DKK', '25110014',   '13.02.2004',      0.00,       2785.00,       1722.60,  0.1345290000,      4674.60,     628.87 );
     convertToEUR (   491692, '020121', '0001', 0, 'DKK', '28280013',   '25.07.2005',      0.00,       2352.75,       2427.35,  0.1340620000,      5975.10,     801.03 );
     convertToEUR (   495673, '029373', '0001', 0, 'DKK', '23378216',   '31.08.2005',      0.00,        442.89,          0.00,  0.1340640000,       442.89,      59.38 );
     convertToEUR (   570058, '023574', '0001', 0, 'DKK', '36239',      '12.06.2006',      0.00,       5245.00,       1432.00,  0.1340390000,      8489.45,    1137.92 );
     convertToEUR (   615066, '015740', '0001', 0, 'DKK', '14215098',   '03.10.2003',   1387.00,          0.00,          0.00,  0.1342420000,      1387.00,     186.19 );
     convertToEUR (   931540, '039264', '0002', 0, 'DKK', '94610766',   '26.08.2011',      0.00,       2161.60,       2223.36,  0.1342420000,      4384.96,     588.65 );
     convertToEUR (   313425, '010539', '0001', 0, 'GBP', '264453',     '12.06.2003',      0.00,         45.03,        117.00,  1.4245000000,       162.03,     230.81 );
     convertToEUR (   318099, '012246', '0001', 0, 'GBP', '473269',     '16.04.2003',      0.00,          0.00,        131.58,  1.4259000000,       131.58,     187.62 );
     convertToEUR (   318401, '010539', '0001', 0, 'GBP', '264807',     '12.06.2003',      0.00,         27.00,          4.25,  1.4259000000,        31.25,      44.56 );
     convertToEUR (   318186, '013630', '0001', 0, 'GBP', '355662',     '15.05.2003',      0.00,         38.15,         93.50,  1.4259000000,       131.65,     187.72 );
     convertToEUR (   334947, '013630', '0001', 0, 'GBP', '30027768',   '19.09.2003',      0.00,         82.30,        135.35,  1.4281000000,       217.65,     310.83 );
     convertToEUR (   355409, '013040', '0001', 0, 'GBP', '36604400',   '08.01.2004',      0.00,          0.00,        142.50,  1.4249070000,       167.44,     238.59 );
     convertToEUR (   355406, '013040', '0001', 0, 'GBP', '36604387',   '07.01.2004',      0.00,        163.55,        283.80,  1.4249070000,       525.64,     748.99 );
     convertToEUR (   334082, '013239', '0001', 0, 'GBP', '320967',     '27.05.2003',      0.00,          0.00,        113.80,  1.4281000000,       113.80,     162.52 );
     convertToEUR (   358977, '010539', '0001', 0, 'GBP', '32402444',   '13.01.2004',      0.00,          0.00,         40.75,  1.4845600000,        40.75,      60.50 );
     convertToEUR (   408665, '009277', '0001', 0, 'GBP', '307926',     '30.01.2004',      0.00,          0.00,         91.20,  1.4817000000,       116.80,     173.06 );
     convertToEUR (   386038, '006438', '0004', 0, 'GBP', '3375',       '09.01.2004',      0.00,         45.08,        461.70,  1.4965570000,       814.10,    1218.35 );
     convertToEUR (   373963, '010539', '0001', 0, 'GBP', '32404087',   '05.03.2004',      0.00,         50.41,        288.00,  1.4845600000,       338.41,     502.39 );
     convertToEUR (   400233, '010539', '0001', 0, 'GBP', '32407363',   '25.06.2004',      0.00,        110.38,        198.00,  1.5035330000,       308.38,     463.66 );
     convertToEUR (   400235, '010539', '0001', 0, 'GBP', '32407293',   '24.06.2004',      0.00,        182.35,        484.50,  1.5035330000,       666.85,    1002.63 );
     convertToEUR (   398623, '010539', '0001', 0, 'GBP', '32406960',   '11.06.2004',      0.00,        194.05,        297.00,  1.5035330000,       491.05,     738.31 );
     convertToEUR (   418299, '017992', '0001', 0, 'GBP', '12603737',   '17.06.2004',      0.00,        289.02,        120.28,  1.4632710000,       409.30,     598.92 );
     convertToEUR (   419470, '011405', '0002', 0, 'GBP', '42207876',   '05.08.2004',      0.00,        903.44,        732.40,  1.4632710000,      1635.84,    2393.68 );
     convertToEUR (   419472, '016248', '0001', 0, 'GBP', '65396513',   '11.05.2004',      0.00,        219.35,        262.80,  1.4632710000,       482.15,     705.52 );
     convertToEUR (   411152, '014264', '0001', 0, 'GBP', '88397906',   '08.06.2004',      0.00,        149.58,        197.42,  1.4817000000,       347.00,     514.15 );
     convertToEUR (   410023, '011214', '0001', 0, 'GBP', '88395762',   '27.04.2004',      0.00,         30.89,        315.70,  1.4817000000,       346.59,     513.54 );
     convertToEUR (   448154, '017992', '0001', 0, 'GBP', '23600131',   '24.09.2004',      0.00,        291.65,        220.80,  1.4355440000,       512.45,     735.64 );
     convertToEUR (   450513, '008720', '0011', 0, 'GBP', '41613678',   '23.08.2004',      0.00,        238.36,        176.00,  1.4463400000,       414.36,     599.31 );
     convertToEUR (   450517, '010539', '0001', 0, 'GBP', '32412573',   '02.12.2004',      0.00,          0.00,         42.10,  1.4463400000,        42.10,      60.89 );
     convertToEUR (   526012, '018488', '0001', 0, 'GBP', '12653158',   '20.12.2005',      0.00,          0.00,        151.20,  1.4727540000,       151.20,     222.68 );
     convertToEUR (   499202, '020295', '0001', 0, 'GBP', '12636096',   '17.06.2005',      0.00,        128.65,        101.60,  1.4812620000,       230.25,     341.06 );
     convertToEUR (   514263, '030540', '0001', 0, 'GBP', '11529923',   '24.11.2005',      0.00,         87.04,        119.00,  1.4705880000,       242.10,     356.03 );
     convertToEUR (   526627, '028729', '0001', 0, 'GBP', '85012911',   '08.02.2006',      0.00,          9.37,        130.00,  1.4727540000,       277.37,     408.50 );
     convertToEUR (   526704, '018615', '0001', 0, 'GBP', '15009986',   '24.10.2005',      0.00,       1515.88,        818.50,  1.4727540000,      2601.88,    3831.93 );
     convertToEUR (   502038, '013630', '0001', 0, 'GBP', '27615130',   '29.09.2005',      0.00,         68.84,         94.50,  1.4812620000,       236.07,     349.68 );
     convertToEUR (   608888, '028729', '0001', 0, 'GBP', '85028547',   '17.01.2007',      0.00,          0.00,        636.50,  1.4729700000,       636.50,     937.55 );
     convertToEUR (   608912, '031377', '0003', 0, 'GBP', '41660402',   '06.03.2007',      0.00,          0.00,        125.80,  1.4729700000,       125.80,     185.30 );
     convertToEUR (   608913, '031377', '0003', 4, 'GBP', '416604020',  '06.03.2007',      0.00,          0.00,         30.00,  1.2625000000,        30.00,      37.88 );
     convertToEUR (   608757, '028729', '0001', 0, 'GBP', '12685847',   '15.01.2007',      0.00,          0.00,        202.25,  1.4729700000,       202.25,     297.91 );
     convertToEUR (   579875, '028729', '0001', 0, 'GBP', '42223218',   '06.10.2006',      0.00,          0.00,        296.25,  1.4856630000,       296.25,     440.13 );
     convertToEUR (   581403, '028729', '0001', 0, 'GBP', '2019737',    '17.05.2006',      0.00,        936.79,       1050.90,  1.4856630000,      2282.69,    3391.31 );
     convertToEUR (   630217, '029641', '0003', 0, 'GBP', '35021123',   '03.04.2007',      0.00,        253.75,          0.00,  1.4729700000,       253.75,     373.77 );
     convertToEUR (   613665, '029641', '0001', 0, 'GBP', '12683722',   '15.12.2006',      0.00,       2045.11,       1613.90,  1.4729700000,      3659.01,    5389.61 );
     convertToEUR (   630486, '018488', '0001', 0, 'GBP', '35011977',   '28.02.2007',    265.00,       1444.70,       1585.79,  1.4729700000,      3295.49,    4854.16 );
     convertToEUR (   617676, '034259', '0001', 1, 'GBP', '376160282',  '16.04.2007',      0.00,         84.65,        115.50,  1.4729700000,       200.15,     294.81 );
     convertToEUR (   617677, '034259', '0001', 0, 'GBP', '376160283',  '16.04.2007',      0.00,         84.65,        115.50,  1.4729700000,       200.15,     294.81 );
     convertToEUR (   660200, '016565', '0001', 0, 'GBP', '12515894',   '03.08.2006',      0.00,        385.34,        610.88,  1.4770000000,       996.22,    1471.42 );
     convertToEUR (   616561, '034259', '0001', 0, 'GBP', '376160281',  '16.04.2007',      0.00,         84.65,        115.50,  1.4729700000,       200.15,     294.81 );
     convertToEUR (   651669, '028729', '0001', 0, 'GBP', '4024121',    '24.09.2007',      0.00,        199.07,        291.00,  1.4770000000,       885.07,    1307.25 );
     convertToEUR (   679519, '025829', '0001', 0, 'GBP', '55026331',   '09.05.2008',      0.00,         67.00,        234.90,  1.2450000000,       301.90,     375.87 );
     convertToEUR (   668569, '028729', '0001', 4, 'GBP', '13627565',   '27.02.2008',      0.00,        447.10,       1156.60,  1.3231900000,      1603.70,    2122.00 );
     convertToEUR (   717992, '033100', '0001', 4, 'GBP', '75001401',   '30.09.2008',      0.00,        182.50,          0.00,  1.2625000000,       182.50,     230.41 );
     convertToEUR (   749176, '036041', '0001', 0, 'GBP', '15068505',   '12.03.2009',      0.00,        175.70,         88.06,  1.0880000000,       263.76,     286.97 );
     convertToEUR (   793425, '036112', '0003', 4, 'GBP', '41607693',   '09.11.2009',      0.00,       2458.94,       1766.20,  1.1160000000,      4863.39,    5427.54 );
     convertToEUR (   797238, '035218', '0004', 0, 'GBP', '23219508',   '07.09.2009',      0.00,        145.45,        416.53,  1.1410000000,       561.98,     641.22 );
     convertToEUR (   816408, '037422', '0001', 0, 'GBP', '15052116',   '20.02.2010',      0.00,          7.15,        184.00,  1.1410000000,       191.15,     218.10 );
     convertToEUR (   953229, '061779', '0004', 0, 'GBP', '54030980',   '30.04.2012',      0.00,         26.80,          0.00,  1.2143000000,        26.80,      32.54 );
     convertToEUR (   947675, '046113', '0001', 0, 'GBP', '37656333',   '05.04.2012',      0.00,        142.32,        204.00,  1.2070010000,       346.32,     418.01 );
     convertToEUR (   999332, '061779', '0002', 0, 'GBP', '45096792',   '04.02.2013',      0.00,          0.00,        205.85,  1.2429500000,       205.85,     255.86 );
     convertToEUR (   586345, '023076', '0001', 0, 'HRK', '20982006',   '09.06.2006',      0.00,       2102.71,       1750.00,  0.1357220000,      4700.31,     637.94 );
     convertToEUR (   631361, '034684', '0001', 0, 'HUF', '1119',       '23.08.2007',      0.00,       1442.00,        625.00,  0.0039550000,      2067.00,       8.17 );
     convertToEUR (   617245, '029774', '0001', 0, 'HUF', '241450',     '20.12.2006',   1409.50,      66314.50,      18634.00,  0.0039550000,     86358.00,     341.55 );
     convertToEUR (   660204, '033603', '0001', 0, 'HUF', '1082006',    '18.08.2006',      0.00,       9272.00,      10062.00,  0.0039550000,     19334.00,      76.47 );
     convertToEUR (   369728, '008702', '0001', 0, 'NOK', '323223352',  '25.02.2004',      0.00,       1318.64,       1846.00,  0.1136550000,      3924.00,     445.98 );
     convertToEUR (   373956, '008702', '0001', 0, 'NOK', '323223527',  '09.03.2004',      0.00,        923.00,       1661.60,  0.1136550000,      3205.00,     364.26 );
     convertToEUR (   454015, '023121', '0001', 4, 'NOK', '313509396',  '05.08.2004',      0.00,       2989.00,       1260.00,  0.1281470000,      5269.00,     675.21 );
     convertToEUR (   504642, '023121', '0001', 0, 'NOK', '753827710',  '03.03.2005',      0.00,       2947.00,       1260.00,  0.1281470000,      5269.00,     675.21 );
     convertToEUR (   504083, '015740', '0001', 0, 'NOK', '333145301',  '09.02.2005',      0.00,       2499.00,      57422.00,  0.1281470000,     75091.00,    9622.69 );
     convertToEUR (   555147, '015740', '0001', 0, 'NOK', '333104427',  '23.03.2006',      0.00,        352.00,       6068.00,  0.1263580000,      8655.00,    1093.63 );
     convertToEUR (   330295, '015007', '0009', 0, 'PLN', '233703',     '02.07.2003',      0.00,       1934.00,        681.98,  0.2286000000,      2615.98,     598.01 );
     convertToEUR (   305030, '015007', '0033', 0, 'PLN', '148403',     '22.04.2003',      0.00,        178.35,         15.86,  0.2246000000,       194.21,      43.62 );
     convertToEUR (   330431, '015007', '0033', 0, 'PLN', '294003',     '28.08.2003',      0.00,       4883.05,       2093.52,  0.2286000000,      6976.57,    1594.84 );
     convertToEUR (   340064, '008272', '0001', 0, 'PLN', '1080403',    '20.10.2003',      0.00,         96.92,         34.16,  0.2165000000,       131.08,      28.38 );
     convertToEUR (   318176, '020594', '0033', 0, 'PLN', '170803',     '12.05.2003',      0.00,          8.02,         79.30,  0.2246000000,        87.32,      19.61 );
     convertToEUR (   318253, '014331', '0001', 0, 'PLN', '50803',      '09.06.2003',      0.00,        785.69,        342.58,  0.2246000000,      1128.27,     253.41 );
     convertToEUR (   318261, '010626', '0001', 0, 'PLN', '46203',      '28.05.2003',      0.00,        605.60,        256.93,  0.2246000000,       862.53,     193.72 );
     convertToEUR (   318321, '010626', '0001', 0, 'PLN', '49603',      '05.06.2003',      0.00,       3903.15,       1080.43,  0.2246000000,      4983.58,    1119.31 );
     convertToEUR (   313030, '020594', '0042', 0, 'PLN', '143003',     '15.04.2003',      0.00,        158.56,        364.78,  0.2368000000,       523.34,     123.93 );
     convertToEUR (   347449, '020594', '0043', 0, 'PLN', '402903',     '19.11.2003',      0.00,       2013.58,       1316.38,  0.2164970000,      3329.96,     720.93 );
     convertToEUR (   347458, '020594', '0042', 0, 'PLN', '403303',     '19.11.2003',      0.00,       1110.20,       1984.41,  0.2164970000,      3094.61,     669.97 );
     convertToEUR (   334339, '015007', '0009', 0, 'PLN', '305503',     '05.09.2003',      0.00,       2993.56,        793.00,  0.2210000000,      3786.56,     836.83 );
     convertToEUR (   333805, '008272', '0001', 0, 'PLN', '1011703',    '27.09.2003',      0.00,        251.80,        145.18,  0.2210000000,       396.98,      87.73 );
     convertToEUR (   347402, '020594', '0033', 0, 'PLN', '390103',     '08.11.2003',      0.00,       1990.88,       1110.20,  0.2164970000,      3101.08,     671.37 );
     convertToEUR (   333916, '008272', '0001', 0, 'PLN', '1018203',    '29.09.2003',      0.00,        299.03,        204.96,  0.2210000000,       503.99,     111.38 );
     convertToEUR (   349071, '020594', '0061', 0, 'PLN', '681003',     '17.11.2003',      0.00,       2399.83,       1200.48,  0.2164970000,      3600.31,     779.46 );
     convertToEUR (   349076, '020594', '0044', 0, 'PLN', '408503',     '24.11.2003',      0.00,        353.93,        586.82,  0.2164970000,       940.75,     203.67 );
     convertToEUR (   365820, '005988', '0391', 0, 'PLN', '258003',     '23.07.2003',      0.00,        296.11,         15.86,  0.2123900000,       311.97,      66.26 );
     convertToEUR (   363915, '020594', '0062', 0, 'PLN', '292042',     '19.01.2004',      0.00,       1591.64,        710.04,  0.2123900000,      2301.68,     488.85 );
     convertToEUR (   356302, '020594', '0041', 0, 'PLN', '448903',     '22.12.2003',      0.00,       2406.88,       1332.24,  0.2141600000,      3739.12,     800.77 );
     convertToEUR (   341627, '020594', '0034', 0, 'PLN', '361603',     '17.10.2003',      0.00,       1914.21,       1411.54,  0.2165000000,      3325.75,     720.02 );
     convertToEUR (   409193, '020594', '0079', 0, 'PLN', '246604',     '23.07.2004',      0.00,        365.88,       1050.00,  0.2252100000,      1415.88,     318.87 );
     convertToEUR (   363904, '020594', '0044', 0, 'PLN', '26904',      '20.01.2004',      0.00,       2438.91,       1116.30,  0.2123900000,      3555.21,     755.09 );
     convertToEUR (   409165, '005988', '0391', 0, 'PLN', '260404',     '06.08.2004',      0.00,       4994.64,       2085.00,  0.2252100000,      7079.64,    1594.41 );
     convertToEUR (   400664, '008272', '0001', 0, 'PLN', '310704',     '06.07.2004',      0.00,         42.17,         27.00,  0.2185360000,        69.17,      15.12 );
     convertToEUR (   385444, '008272', '0001', 0, 'PLN', '328104',     '28.04.2004',      0.00,        133.27,        109.80,  0.2100920000,       243.07,      51.07 );
     convertToEUR (   369199, '008272', '0001', 0, 'PLN', '1499041',    '24.02.2004',      0.00,        760.68,        164.70,  0.2045030000,       925.38,     189.24 );
     convertToEUR (   369189, '015007', '0033', 0, 'PLN', '65304',      '17.02.2004',      0.00,        317.77,        311.10,  0.2045030000,       628.87,     128.61 );
     convertToEUR (   399660, '020594', '0079', 0, 'PLN', '174304',     '19.05.2004',      0.00,       1162.01,        555.00,  0.2185360000,      1717.01,     375.23 );
     convertToEUR (   418300, '008272', '0001', 0, 'PLN', '2369041',    '30.08.2004',      0.00,         80.90,         18.00,  0.2316530000,        98.90,      22.91 );
     convertToEUR (   401950, '020594', '0033', 0, 'PLN', '226804',     '06.07.2004',      0.00,         97.33,        210.00,  0.2185360000,       307.33,      67.16 );
     convertToEUR (   401951, '020594', '0061', 0, 'PLN', '308604',     '12.07.2004',      0.00,       2068.12,        380.00,  0.2233980000,      2448.12,     546.91 );
     convertToEUR (   418305, '020594', '0042', 0, 'PLN', '317704',     '23.09.2004',      0.00,       1716.24,        620.60,  0.2316530000,      2336.84,     541.34 );
     convertToEUR (   420409, '015007', '0033', 1, 'PLN', '9304',       '22.09.2004',      0.00,       7212.49,       2325.00,  0.2316530000,      9537.49,    2209.39 );
     convertToEUR (   420413, '005988', '0391', 0, 'PLN', '329004',     '04.10.2004',      0.00,        121.08,         15.00,  0.2316530000,       136.08,      31.52 );
     convertToEUR (   418838, '020594', '0033', 0, 'PLN', '314904',     '22.09.2004',      0.00,         78.82,        173.09,  0.2316530000,       251.91,      58.36 );
     convertToEUR (   425007, '008272', '0001', 0, 'PLN', '4216041',    '08.11.2004',      0.00,        248.03,        117.00,  0.2327040000,       365.03,      84.94 );
     convertToEUR (   429232, '020594', '0044', 0, 'PLN', '328904',     '04.10.2004',      0.00,         74.40,        105.00,  0.2348680000,       179.40,      42.14 );
     convertToEUR (   429234, '020594', '0041', 0, 'PLN', '357104',     '28.10.2004',      0.00,       1428.32,        615.00,  0.2348680000,      2043.32,     479.91 );
     convertToEUR (   429231, '020594', '0043', 0, 'PLN', '324604',     '30.09.2004',      0.00,       1788.20,       1755.00,  0.2348680000,      3543.20,     832.18 );
     convertToEUR (   414947, '020594', '0033', 0, 'PLN', '289504',     '01.09.2004',      0.00,       1466.98,        330.00,  0.2252100000,      1796.98,     404.70 );
     convertToEUR (   468768, '020594', '0062', 0, 'PLN', '1944052',    '04.04.2005',      0.00,       4418.07,        762.00,  0.2405170000,      6319.69,    1519.99 );
     convertToEUR (   409161, '020594', '0034', 0, 'PLN', '266404',     '11.08.2004',      0.00,       1543.88,        420.11,  0.2252100000,      1963.99,     442.31 );
     convertToEUR (   402333, '008272', '0001', 0, 'PLN', '124304',     '15.07.2004',      0.00,        223.53,         27.00,  0.2185360000,       250.53,      54.75 );
     convertToEUR (   411126, '020594', '0034', 1, 'PLN', '266404',     '16.09.2004',      0.00,       1543.88,        420.11,  0.2252100000,      1963.99,     442.31 );
     convertToEUR (   409795, '020594', '0062', 0, 'PLN', '368404',     '31.07.2004',      0.00,       1496.14,        798.00,  0.2252100000,      2294.14,     516.66 );
     convertToEUR (   409796, '020594', '0072', 0, 'PLN', '368204',     '31.07.2004',      0.00,       1406.90,        826.00,  0.2252100000,      2232.90,     502.87 );
     convertToEUR (   434432, '020594', '0033', 0, 'PLN', '92040',      '29.12.2004',      0.00,         97.33,        210.00,  0.2348680000,       307.33,      72.18 );
     convertToEUR (   425823, '020594', '0034', 0, 'PLN', '26640400',   '11.08.2004',      0.00,       1543.78,        420.11,  0.2327040000,      1963.89,     457.01 );
     convertToEUR (   455576, '020594', '0033', 1, 'PLN', '92040',      '22.03.2005',      0.00,         97.33,        210.00,  0.2496310000,       307.33,      76.72 );
     convertToEUR (   455577, '020594', '0033', 1, 'PLN', '920400',     '22.03.2005',      0.00,         97.33,        210.00,  0.2496310000,       307.33,      76.72 );
     convertToEUR (   547061, '014454', '0006', 0, 'PLN', '32006',      '09.02.2006',      0.00,       4377.43,       1215.00,  0.2649700000,      5592.43,    1481.83 );
     convertToEUR (   526668, '020594', '0062', 0, 'PLN', '7399052',    '28.11.2005',      0.00,       2816.13,       1450.00,  0.2612120000,      5204.68,    1359.52 );
     convertToEUR (   567302, '017813', '0001', 0, 'PLN', '2031061',    '01.08.2006',      0.00,        573.92,        930.00,  0.2441100000,      1503.92,     367.12 );
     convertToEUR (   531039, '020594', '0061', 0, 'PLN', '647062',     '26.01.2006',      0.00,       2108.38,       1637.85,  0.2649700000,      3746.23,     992.64 );
     convertToEUR (   608904, '018058', '0001', 0, 'PLN', '613206',     '13.12.2006',   2453.93,          0.00,          0.00,  0.2581040000,      2453.93,     633.37 );
     convertToEUR (   399053, '015007', '0033', 0, 'PLN', '188704',     '02.06.2004',      0.00,       7212.49,       2325.00,  0.2185360000,      9537.49,    2084.28 );
     convertToEUR (   617093, '032429', '0001', 0, 'PLN', '10373',      '21.08.2006',      0.00,        559.78,        370.56,  0.2581040000,       930.34,     240.12 );
     convertToEUR (   712526, '027657', '0001', 0, 'PLN', '1040',       '28.02.2007',      0.00,        150.80,        387.20,  0.2581040000,       538.00,     138.86 );
     convertToEUR (   980337, '062123', '0001', 0, 'PLN', '4259',       '29.09.2012',      0.00,        402.65,        695.47,  0.2430820000,      1098.12,     266.93 );
     convertToEUR (   330605, '021393', '0001', 0, 'ROL', '40320953',   '05.08.2003',      0.00,    4035902.00,    1712748.00,  0.0000269700,   6840894.00,     184.50 );
     convertToEUR (   725063, '034951', '0001', 0, 'ROL', '1027652',    '27.05.2008',      0.00,       7377.39,          0.00,  0.2724800000,      7377.39,    2010.19 );
     convertToEUR (   675481, '038929', '0001', 0, 'ROL', '9598',       '05.06.2008',      0.00,        343.00,        184.53,  0.2765000000,       527.53,     145.86 );
     convertToEUR (   742385, '038929', '0001', 1, 'ROL', '95980',      '05.06.2008',      0.00,        350.76,        184.53,  0.2724800000,       535.29,     145.86 );
     convertToEUR (   334926, '006661', '0001', 0, 'SEK', '174355',     '07.10.2003',      0.00,       5288.80,       2597.20,  0.1081000000,      7886.00,     852.48 );
     convertToEUR (   386655, '012236', '0001', 0, 'SEK', '425070',     '08.10.2003',      0.00,          0.00,       5001.00,  0.1091880000,      5001.00,     546.05 );
     convertToEUR (   506576, '015740', '0001', 0, 'SEK', '539004',     '13.06.2005',      0.00,       6863.00,          0.00,  0.1056020000,      6863.00,     724.75 );
     convertToEUR (   769019, '034927', '0001', 0, 'SEK', '107661',     '04.08.2009',      0.00,          0.00,      11566.00,  0.0980780000,     11566.00,    1134.37 );
     convertToEUR (   769021, '034927', '0001', 4, 'SEK', '106976',     '24.06.2009',      0.00,       3951.00,       4380.00,  0.0928510000,      8331.00,     773.54 );
     
end;
/

set echo       off
set feedback   on
set feedback   1

prompt check if there are still workshop invoices with a foreign currency:

select r.ID_VERTRAG, r.ID_FZGVERTRAG, r.FZGRE_BELEGNR, to_char ( r.FZGRE_BELEGDATUM, 'DD.MM.YYYY' ) FZGRE_BELEGDATUM, c.CUR_CODE, r.FZGRE_RESUMME
  from snt.TFZGRECHNUNG r
     , snt.TCURRENCY    c
 where c.ID_CURRENCY   = r.ID_CURRENCY
   and c.CUR_CODE     <> 'EUR'
 order by 1, 2, 3, 4, 5;


-- commit or rollback data
set echo     off
set feedback off

-- < delete following code between begin and end if data is selected only >
begin
   if   :L_ERROR_COUNT = 0 and upper ( '&&commit_or_rollback' ) = 'Y'
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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.log
prompt

exit;