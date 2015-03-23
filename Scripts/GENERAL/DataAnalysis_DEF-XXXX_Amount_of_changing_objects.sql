-- DataAnalysis_DEF-XXXX_Amount_of_changing_objects.sql
-- Please keep in mind if you are accepting more input parameters!
-- 2014-11-25; FraBe;     V1.1; MKS-135551:1; creation
-- 2014-12-03; ZBerger;   V1.3; MKS-135892:1; enhance output

-- ################################################################################################
--===================================================================================================================================
--===================================================================================================================================

   -- file name for script and logfile
   define GL_SCRIPTNAME         = 'DataAnalysis_DEF-XXXX_Amount_of_changing_objects'
   define GL_LOGFILETYPE        = log      -- logfile name extension. [LOG|CSV|TXT]  {CSV causes less info in logfile}
   define GL_SCRIPTFILETYPE     = sql      -- sqlfile name extension. No need to modify.

   -- Sirius Min version
   define L_MAJOR_MIN           = 2
   define L_MINOR_MIN           = 8
   define L_REVISION_MIN        = 0
   define L_BUILD_MIN           = 0

   -- Sirius executing user. Do we need SYSDBA-Privileges?
   define L_SOLLUSER            = SNT
   define L_SYSDBA_PRIV_NEEDED  = false    -- false or true

 -- country specification
   define L_MPC_CHECK           = false    -- false or true
   define L_MPC_SOLL            = 'MBCH'   -- für                   MBBEL | MBCH  | MBCL  | MBCZ  | MBE   | MBF   | MBI   | MBNL  | MBOE  | MBP   | MBPL  | MBR   | MBSA
   define L_VEGA_CODE_SOLL      = '57129'  -- die werte dafür sind: 51331 | 57129 | 81930 | 57630 | 57732 | 53137 | 54339 | 55337 | 55731 | 56130 | 55930 | 52430 | 67530
                                           -- bei beiden können aber auch mehrere angegeben werden
                                           -- die einzelnen werte MÜSSEN aber durch ',' voneinander getrennt werden ...
                                           -- und es darf keine leerstelle enthalten sein ...
                                           -- gültige angaben sind zb: 
                                           -- define L_MPC_SOLL       = 'MBBEL,MBCH'
                                           -- define L_VEGA_CODE_SOLL = '51331,57129'
 
  -- Reexecution
   define  L_REEXEC_FORBIDDEN   = false    -- false or true

  -- Logging (CURRENTLY NOT IMPLEMENTED!)
   define L_DB_LOGGING_ENABLE   = true     -- Are we logging to the DB? -> false or true
   define L_LOGFILE_REQUIRED    = true     -- Logfile required? -> false or true

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

variable L_SCRIPTNAME             varchar2 ( 200 char );
variable L_ERROR_OCCURED          number;
variable L_DATAERRORS_OCCURED     number;
variable L_DATAWARNINGS_OCCURED   number;
variable L_DATASUCCESS_OCCURED    number;
variable nachricht                varchar2 ( 200 char );
variable L_TIME_DELTA             number;


exec :L_SCRIPTNAME           := '&GL_SCRIPTNAME..&GL_SCRIPTFILETYPE'
exec :L_ERROR_OCCURED        :=0
exec :L_DATAERRORS_OCCURED   :=0
exec :L_DATAWARNINGS_OCCURED :=0
exec :L_DATASUCCESS_OCCURED  :=0
exec :L_TIME_DELTA           :=30

spool &GL_SCRIPTNAME..&GL_LOGFILETYPE

declare
   L_LAST_EXEC_TIME        varchar2 ( 30 char );
begin
 if upper ( '&&GL_LOGFILETYPE' ) <> 'CSV' then
  dbms_output.put_line ( 'Script executed on: ' || to_char ( sysdate, 'DD.MM.YYYY HH24:MI:SS' )); 
  dbms_output.put_line ( 'Script executed by: &&_USER' ); 
  dbms_output.put_line ( 'Script run on DB  : &&_CONNECT_IDENTIFIER' ); 
  dbms_output.put_line ( 'Database Country  : ' || snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName', 'NoMPCName found' )); 
  dbms_output.put_line ( 'Database dump date: ' || snt.get_TGLOBAL_SETTINGS ( 'DB',     'DUMP',    'DATE',    'not found'       )); 
  begin
              select to_char ( max ( LE_CREATED ), 'DD.MM.YYYY HH24:MI:SS' )
                into L_LAST_EXEC_TIME
                from snt.TLOG_EVENT    e
               where GUID_LA = '10'         -- maintenance
                 and exists ( select null
                                from snt.TLOG_EVENT_PARAM ep
                               where ep.LEP_VALUE    = :L_SCRIPTNAME
                                 and ep.GUID_LE      = e.GUID_LE );
              dbms_output.put_line ( 'This script was already executed on: ' || L_LAST_EXEC_TIME );
    
    exception 
    when others then NULL;
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

   L_MPC_IST               snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'Setting', 'MPCName',    'NoMPCName found'   );
   L_VEGA_CODE_IST         snt.TGLOBAL_SETTINGS.VALUE%TYPE := snt.get_TGLOBAL_SETTINGS ( 'SIRIUS', 'SIVECO',  'Country-CD', 'No VegaCode found' );

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
   if   &L_MPC_CHECK and instr ( '&L_VEGA_CODE_SOLL', L_VEGA_CODE_IST ) = 0 
   then dbms_output.put_line ( 'This script can be executed against following DB(s) only: ' || '&L_MPC_SOLL'
                              || chr(10) || 'But you are executing it against a ' || L_MPC_IST || ' DB!' || chr(10) );
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

exec :L_TIME_DELTA := '&1';

/* NOT NEEDED, see discussion on MKS-135892
set heading    off
set feedback   off
spool arsch.sql
select 'accept L_TIME_DELTA PROMPT "report objects which are created or changed the past xy days: "'
  from dual
 where not '&1' is null;
spool off
@arsch.sql
*/

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
set feedback     off

-- main part for < selecting or checking or correcting code >
declare

   l_new_partner              NUMBER;
   l_changed_partner          NUMBER;
   l_new_vehiclecontracts     NUMBER;
   l_changed_vehiclecontracts NUMBER;
   l_new_cost                 NUMBER;
   l_changed_cost             NUMBER;
   l_new_costcoll_inv_cn      NUMBER;
   l_changed_costcoll_inv_cn  NUMBER;
   l_new_revenue              NUMBER;
   l_changed_revenue          NUMBER;
   l_new_odometer             NUMBER;
   l_changed_odometer         NUMBER;

begin

   -- use 30 as default
   if :L_TIME_DELTA is null
   then :L_TIME_DELTA := 30;
   end if;
   
   select sum ( anzahl ) as "count new partner"
     into l_new_partner
     from ( select count(*)  as anzahl      -- orgPers-CommCust
              from TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where t.ID_CUSTYP            = c.ID_CUSTYP
               and t.CUSTYP_COMPANY      in ( 0, 2 )
               and c.EXT_CREATION_DATE   >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
            union
            select count(*)               -- phyPers-PrivCust
              from TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where t.ID_CUSTYP            = c.ID_CUSTYP
               and t.CUSTYP_COMPANY       = 1
               and c.EXT_CREATION_DATE   >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
             union
            select count(*)               -- orgPers-Workshop / Dealer
              from TGARAGETYP     t
                 , TGARAGE        g
             where t.ID_GARAGETYP          = g.ID_GARAGETYP
               and GAR_IS_SERVICE_PROVIDER = 0
               and g.EXT_CREATION_DATE    >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
             union
            select count(*)               -- orgPers-Supplier
              from TGARAGETYP     t
                 , TGARAGE        g
             where t.ID_GARAGETYP          = g.ID_GARAGETYP
               and GAR_IS_SERVICE_PROVIDER = 0
               and g.EXT_CREATION_DATE    >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
            union
            select count(*)               -- phyPers-ContactPers
              from VADRASSOZ      a
                 , TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where c.ID_CUSTYP           = t.ID_CUSTYP
               and c.ID_SEQ_ADRASSOZ     = a.ID_SEQ_ADRASSOZ
               and a.NAME_TITEL1        is not null
               and c.EXT_CREATION_DATE  >= ( sysdate - :L_TIME_DELTA ));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   select sum ( anzahl ) as "count changed partner"
     into l_changed_partner
     from ( select count(*)  as anzahl    -- orgPers-CommCust
              from TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where t.ID_CUSTYP            = c.ID_CUSTYP
               and t.CUSTYP_COMPANY      in ( 0, 2 )
               and c.EXT_UPDATE_DATE     >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
            union
            select count(*)               -- phyPers-PrivCust
              from TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where t.ID_CUSTYP            = c.ID_CUSTYP
               and t.CUSTYP_COMPANY       = 1
               and c.EXT_UPDATE_DATE     >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
             union
            select count(*)               -- orgPers-Workshop / Dealer
              from TGARAGETYP     t
                 , TGARAGE        g
             where t.ID_GARAGETYP          = g.ID_GARAGETYP
               and GAR_IS_SERVICE_PROVIDER = 0
               and g.EXT_UPDATE_DATE      >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
             union
            select count(*)               -- orgPers-Supplier
              from TGARAGETYP     t
                 , TGARAGE        g
             where t.ID_GARAGETYP          = g.ID_GARAGETYP
               and GAR_IS_SERVICE_PROVIDER = 0
               and g.EXT_UPDATE_DATE      >= ( sysdate - :L_TIME_DELTA )
            ---------------------------------------------------------------------
            union
            select count(*)               -- phyPers-ContactPers
              from VADRASSOZ      a
                 , TCUSTOMERTYP   t
                 , TCUSTOMER      c
             where c.ID_CUSTYP           = t.ID_CUSTYP
               and c.ID_SEQ_ADRASSOZ     = a.ID_SEQ_ADRASSOZ
               and a.NAME_TITEL1        is not null
               and c.EXT_UPDATE_DATE    >= ( sysdate - :L_TIME_DELTA ));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   select count ( distinct fzgv.GUID_CONTRACT ) as "count new VehicleContracts"
     into l_new_vehiclecontracts
     from TFZGVERTRAG       fzgv
        , TFZGV_CONTRACTS   fzgvc
    where fzgv.ID_VERTRAG            = fzgvc.ID_VERTRAG
      and fzgv.ID_FZGVERTRAG         = fzgvc.ID_FZGVERTRAG
      and (  fzgv.EXT_CREATION_DATE >= ( sysdate - :L_TIME_DELTA )
       or   fzgvc.EXT_CREATION_DATE >= ( sysdate - :L_TIME_DELTA ));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   select count ( distinct fzgv.GUID_CONTRACT ) as "count changed VehicleContracts"
     into l_changed_vehiclecontracts
     from TFZGVERTRAG       fzgv
        , TFZGV_CONTRACTS   fzgvc
    where fzgv.ID_VERTRAG           = fzgvc.ID_VERTRAG
      and fzgv.ID_FZGVERTRAG        = fzgvc.ID_FZGVERTRAG
      and (  fzgv.EXT_UPDATE_DATE  >= ( sysdate - :L_TIME_DELTA )
       or   fzgvc.EXT_UPDATE_DATE  >= ( sysdate - :L_TIME_DELTA ));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- COST neuanlage: es wird nur das TFZGRECHNUNG anlagedatum gecheckt
   -- TINV_POSITION braucht nicht extra gecheckt werden
   select count ( distinct fzgre.ID_SEQ_FZGRECHNUNG ) as "count new COST"
     into l_new_cost
     from TFZGRECHNUNG    fzgre
        , TBELEGARTEN     bel
    where fzgre.ID_IMP_TYPE     not in ( 9, 10 )                    -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
      and 1                          = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
      and fzgre.ID_BELEGART          = bel.ID_BELEGART
      and fzgre.EXT_CREATION_DATE   >= ( sysdate - :L_TIME_DELTA )
      and (  fzgre.GUID_SPCI        is     null                     -- -> keine SPP Sammelrechnung
        or ( fzgre.GUID_SPCI        is not null                     -- -> oder SPP Sammelrechnung, die aus nur einer Einzelrechnung besteht 
             and exists ( select null
                            from TFZGRECHNUNG fzgre1
                           where fzgre.GUID_SPCI = fzgre1.GUID_SPCI
                          having count(*)        = 1 )));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- COST änderung: check TFZGRECHNUNG und TINV_POSITION upd datum
   -- denn es kann ja sein, daß sich nur was an einer pos geändert hat, aber nix am rechnungsheader.
   -- plus: eine neue TINV_POSITION row mit einem cre datum im checkzeitraum
   --       aber nur, wenn dessen TFZGRECHNUNG cre datum vor dem checkzeitraum liegt / -> im checkzeitraum wäre es ja eine COST neuanlage
   select count ( distinct fzgre.ID_SEQ_FZGRECHNUNG ) as "count changed COST"
     into l_changed_cost
     from TFZGRECHNUNG    fzgre
        , TINV_POSITION   ip
        , TBELEGARTEN     bel
    where fzgre.ID_SEQ_FZGRECHNUNG   = ip.ID_SEQ_FZGRECHNUNG
      and fzgre.ID_IMP_TYPE     not in ( 9, 10 )                    -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
      and 1                          = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
      and fzgre.ID_BELEGART          = bel.ID_BELEGART
      and ( fzgre.EXT_UPDATE_DATE   >= ( sysdate - :L_TIME_DELTA )
         or    ip.EXT_UPDATE_DATE   >= ( sysdate - :L_TIME_DELTA )
         or (  ip.EXT_CREATION_DATE >= ( sysdate - :L_TIME_DELTA ) and fzgre.EXT_CREATION_DATE < ( sysdate - :L_TIME_DELTA )))
      and (  fzgre.GUID_SPCI        is     null                     -- -> keine SPP Sammelrechnung
        or ( fzgre.GUID_SPCI        is not null                     -- -> oder SPP Sammelrechnung, die aus nur einer Einzelrechnung besteht 
             and exists ( select null
                            from TFZGRECHNUNG fzgre1
                           where fzgre.GUID_SPCI = fzgre1.GUID_SPCI
                          having count(*)        = 1 )));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- COST CollectiveINV/CN anlage: es wird nur das TSP_COLLECTIVE_INVOICE anlagedatum gecheckt
   -- dessen TFZGRECHNUNG bzw. TINV_POSITION datum braucht nicht extra gecheckt werden
   select count ( distinct spci.GUID_SPCI ) as "count new COST-Coll INV/CN"
     into l_new_costcoll_inv_cn
     from TSP_COLLECTIVE_INVOICE      spci
        , TFZGRECHNUNG                fzgre
        , TBELEGARTEN                 bel
    where spci.GUID_SPCI              = fzgre.GUID_SPCI
      and fzgre.ID_BELEGART           = bel.ID_BELEGART
      and fzgre.ID_IMP_TYPE      not in ( 9, 10 )                        -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
      and 1                           = bel.BELART_SUM_INVOICE           -- -> keine INFO - INV/CN
      and spci.EXT_CREATION_DATE     >= ( sysdate - :L_TIME_DELTA )
      and exists ( select null
                     from TFZGRECHNUNG   fzgre1
                    where spci.GUID_SPCI          = fzgre1.GUID_SPCI
                   having count(*)        > 1 );                         -- -> nur SPP Sammelrechnungen, die aus mehr als einer Einzelrechnung bestehen

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- COST CollectiveINV/CN änderung: check TSP_COLLECTIVE_INVOICE und TFZGRECHNUNG und TINV_POSITION upd datum
   -- denn es kann ja sein, daß sich nur was an einem einzelrechnungsheader oder einer pos geändert hat, aber nix am COST CollectiveINV/CN rechnungsheader.
   -- plus: eine neue TFZGRECHNUNG bzw. TINV_POSITION row mit einem cre datum im checkzeitraum
   --       aber nur, wenn dessen TSP_COLLECTIVE_INVOICE cre datum vor dem checkzeitraum liegt / -> im checkzeitraum wäre es ja eine COST CollectiveINV/CN neuanlage
   select count ( distinct spci.GUID_SPCI ) as "count changed COST-Coll INV/CN"
     into l_changed_costcoll_inv_cn
     from TSP_COLLECTIVE_INVOICE      spci
        , TFZGRECHNUNG                fzgre
        , TINV_POSITION               ip
        , TBELEGARTEN                 bel
    where spci.GUID_SPCI              = fzgre.GUID_SPCI
      and ip.ID_SEQ_FZGRECHNUNG       = fzgre.ID_SEQ_FZGRECHNUNG
      and fzgre.ID_BELEGART           = bel.ID_BELEGART
      and fzgre.ID_IMP_TYPE      not in ( 9, 10 )                        -- -> keine InvoiceProcessing (-> 9 ) bzw. VEGA-I11 (-> 10 )
      and 1                           = bel.BELART_SUM_INVOICE           -- -> keine INFO - INV/CN
      and (   spci.EXT_UPDATE_DATE   >= ( sysdate - :L_TIME_DELTA )
        or   fzgre.EXT_UPDATE_DATE   >= ( sysdate - :L_TIME_DELTA )
        or      ip.EXT_UPDATE_DATE   >= ( sysdate - :L_TIME_DELTA )
        or ( fzgre.EXT_CREATION_DATE >= ( sysdate - :L_TIME_DELTA ) and spci.EXT_CREATION_DATE < ( sysdate - :L_TIME_DELTA ))
        or (    ip.EXT_CREATION_DATE >= ( sysdate - :L_TIME_DELTA ) and spci.EXT_CREATION_DATE < ( sysdate - :L_TIME_DELTA )))
      and exists ( select null
                     from TFZGRECHNUNG   fzgre1
                    where spci.GUID_SPCI          = fzgre1.GUID_SPCI
                   having count(*)        > 1 );                         -- -> nur SPP Sammelrechnungen, die aus mehr als einer Einzelrechnung bestehen

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- revenues neuanlage: es wird nur das TCUSTOMER_INVOICE anlagedatum gecheckt
   -- TCUSTOMER_INVOICE_POS braucht nicht extra gecheckt werden
   select count ( distinct ci.GUID_CI ) as "count new revenue"
     into l_new_revenue
     from TCUSTOMER_INVOICE       ci
        , TBELEGARTEN             bel
    where 1                         = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
      and ci.ID_BELEGART            = bel.ID_BELEGART
      and ci.EXT_CREATION_DATE     >= ( sysdate - :L_TIME_DELTA );

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   -- revenues änderung: check TCUSTOMER_INVOICE und TCUSTOMER_INVOICE_POS upd datum
   -- denn es kann ja sein, daß sich nur was an einer pos geändert hat, aber nix am rechnungsheader.
   -- plus: eine neue TCUSTOMER_INVOICE_POS row mit einem cre datum im checkzeitraum
   --       aber nur, wenn dessen TCUSTOMER_INVOICE cre datum vor dem checkzeitraum liegt / -> im checkzeitraum wäre es ja eine COST neuanlage
   select count ( distinct ci.GUID_CI ) as "count changed revenue"
     into l_changed_revenue
     from TCUSTOMER_INVOICE       ci
        , TCUSTOMER_INVOICE_POS   cip
        , TBELEGARTEN             bel
    where cip.GUID_CI                 = ci.GUID_CI
      and 1                           = bel.BELART_SUM_INVOICE       -- -> keine INFO - INV/CN
      and ci.ID_BELEGART              = bel.ID_BELEGART
      and (    ci.EXT_UPDATE_DATE    >= ( sysdate - :L_TIME_DELTA )
         or   cip.EXT_UPDATE_DATE    >= ( sysdate - :L_TIME_DELTA )
         or ( cip.EXT_CREATION_DATE  >= ( sysdate - :L_TIME_DELTA ) and ci.EXT_CREATION_DATE < ( sysdate - :L_TIME_DELTA )));

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   select count ( distinct km.ID_SEQ_FZGKMSTAND ) as "count new Odometer"
     into l_new_odometer
     from TFZGKMSTAND    km
    where km.EXT_CREATION_DATE   >= ( sysdate - :L_TIME_DELTA );

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------

   select count ( distinct km.ID_SEQ_FZGKMSTAND ) as "count changed Odometer"
     into l_changed_odometer
     from TFZGKMSTAND    km
    where km.EXT_UPDATE_DATE     >= ( sysdate - :L_TIME_DELTA );

   -- finally show results
   dbms_output.put_line('count-results for time-delta: ' ||:L_TIME_DELTA);
   dbms_output.put_line('new partner'                    ||';'||
                        'changed partner'                ||';'||
                        'new vehicle-contracts'          ||';'||
                        'changed vehicle-contracts'      ||';'||
                        'new cost'                       ||';'||
                        'changed cost'                   ||';'||
                        'new cost-collective inv/cn'     ||';'||
                        'changed cost-collective inv/cn' ||';'||
                        'new revenue'                    ||';'||
                        'changed revenue'                ||';'||
                        'new odometer'                   ||';'||
                        'changed odometer');
   dbms_output.put_line('========================================================================================================================================================================================================================================================');
   dbms_output.put_line(l_new_partner                    ||';'||
                        l_changed_partner                ||';'||
                        l_new_vehiclecontracts           ||';'||
                        l_changed_vehiclecontracts       ||';'||
                        l_new_cost                       ||';'||
                        l_changed_cost                   ||';'||
                        l_new_costcoll_inv_cn            ||';'||
                        l_changed_costcoll_inv_cn        ||';'||
                        l_new_revenue                    ||';'||
                        l_changed_revenue                ||';'||
                        l_new_odometer                   ||';'||
                        l_changed_odometer               ||';');

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
/*
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
*/

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
  dbms_output.put_line ('Dataset affected: ' || 'please see above' );
  dbms_output.put_line ('Data warnings   : ' || :L_DATAWARNINGS_OCCURED );
  dbms_output.put_line ('Data errors     : ' || :L_DATAERRORS_OCCURED );
  dbms_output.put_line ('System errors   : ' || :L_ERROR_OCCURED );

 end if;
end;
/
exit;
