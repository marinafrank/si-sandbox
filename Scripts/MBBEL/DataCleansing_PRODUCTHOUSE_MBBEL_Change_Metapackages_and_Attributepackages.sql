-- DataCleansing_PRODUCTHOUSE_MBBEL_Change_Metapackages_and_Attributepackages.sql
-- M. Zimmerberger 21.01.2014 MKS-130475
-- FraBe           25.02.2014 MKS-130475:2 some verification changes
-- TK              10.04.2014 MKS-132262:1 Splitting in Meta/Attribute Package and SPP - Droppping SPP here

spool DataCleansing_PRODUCTHOUSE_MBBEL_Change_Metapackages_and_Attributepackages.log

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
variable nachricht       varchar2 ( 100 char );
variable L_SCRIPTNAME    varchar2 ( 200 char );
exec :L_SCRIPTNAME       := 'DataCleansing_PRODUCTHOUSE_MBBEL_Change_Metapackages_and_Attributepackages.sql';

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
   L_REVISION_MIN          integer := 1;
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

alter trigger snt.TIC_CO_PACK_ASS_CHECK_AFT disable;
alter trigger snt.TIC_CO_PACK_ASS_CHECK_BEF disable;
alter trigger snt.TIC_CO_PACK_ASS_CHECK_ROW disable;

alter trigger snt.TIC_SPC_PACK_ASS_CHK_AFT disable;
alter trigger snt.TIC_SPC_PACK_ASS_CHK_BEF disable;
alter trigger snt.TIC_SPC_PACK_ASS_CHK_ROW disable;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- main part for < selecting or checking or correcting code >

prompt 
prompt Product-house change in progress...
prompt 

declare

   cursor c_guid_contract (p_icp_caption1 varchar2, 
                           p_icp_caption2 varchar2,
                           p_bal2_caption varchar2) is
      select distinct fzgv.id_vertrag, fzgv.id_fzgvertrag, cpa.guid_contract, cpa.guid_package, fzgv.id_customer
        from snt.tic_co_pack_ass    cpa
           , snt.tfzgv_contracts    fzgv
           , snt.tfzgvertrag        fzg
           , snt.tdfcontr_variant   cov
           , snt.tic_package        pac
           , snt.tfahrzeugart       fza
           , snt.ttypgruppe         typ
           , snt.tfahrzeugtyp       fzt
           , snt.tbusiness_area_l2  l2
       where upper(pac.icp_caption)    IN ( upper ( p_icp_caption1 )
                                          , upper ( p_icp_caption2 ))
         and upper(l2.bal2_caption)    = upper ( p_bal2_caption )
         and pac.icp_package_type      = 2
         and fzg.guid_contract         = cpa.guid_contract
         and pac.guid_package          = cpa.guid_package
         and fza.id_fahrzeugart        = typ.id_fahrzeugart
         and typ.id_typgruppe          = fzt.id_typgruppe
         and fzt.id_fzgtyp             = fzg.id_fzgtyp
         and l2.guid_business_area_l2  = fza.guid_business_area_l2
         and fzg.id_vertrag            = fzgv.id_vertrag
         and fzg.id_fzgvertrag         = fzgv.id_fzgvertrag
         and fzgv.id_cov               = cov.id_cov
         and cov.cov_caption           not like '%MIG_OOS%'
       order by 1, 2;
--         and cpa.guid_contract         = '1045B5E19DFB4ECAA437F49BE1B51A10';

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   cursor c_powerpack ( p_icp_caption1 varchar2, 
                        p_icp_caption2 varchar2,
                        p_bal2_caption varchar2 ) is
      select distinct fzgv.id_vertrag, fzgv.id_fzgvertrag, cpa.guid_contract, cpa.guid_package, fzgv.id_customer
        from snt.tic_co_pack_ass    cpa
           , snt.tfzgv_contracts    fzgv
           , snt.tfzgvertrag        fzg
           , snt.tdfcontr_variant   cov
           , snt.tic_package        pac
           , snt.tfahrzeugart       fza
           , snt.ttypgruppe         typ
           , snt.tfahrzeugtyp       fzt
           , snt.tbusiness_area_l2  l2
       where upper(pac.icp_caption)    = upper ( p_icp_caption1 )     -- -> das ist das metapaket
         and upper(l2.bal2_caption)    = upper ( p_bal2_caption )
         and pac.icp_package_type      = 2
         and fzg.guid_contract         = cpa.guid_contract
         and pac.guid_package          = cpa.guid_package
         and fza.id_fahrzeugart        = typ.id_fahrzeugart
         and typ.id_typgruppe          = fzt.id_typgruppe
         and fzt.id_fzgtyp             = fzg.id_fzgtyp
         and l2.guid_business_area_l2  = fza.guid_business_area_l2
         and fzg.id_vertrag            = fzgv.id_vertrag
         and fzg.id_fzgvertrag         = fzgv.id_fzgvertrag
         and fzgv.id_cov               = cov.id_cov
         and cov.cov_caption           not like '%MIG_OOS%'
         and exists ( select null 
                        from snt.tic_co_pack_ass    cpa1
                           , snt.tic_package        pac1
                       where upper( pac1.icp_caption )  = upper ( p_icp_caption2 )     -- -> das ist das attributpaket
                         and pac1.icp_package_type      = 1
                         and pac1.guid_package          = cpa1.guid_package
                         and fzg.guid_contract          = cpa1.guid_contract )
       order by 1, 2;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------       
       
   cursor c_powerpack_BUNDLE (p_icp_caption varchar2) is
      select distinct fzgv.id_vertrag, fzgv.id_fzgvertrag, cpa.guid_contract, cpa.guid_package, fzgv.id_customer
        from snt.tic_co_pack_ass    cpa
           , snt.tfzgv_contracts    fzgv
           , snt.tfzgvertrag        fzg
           , snt.tdfcontr_variant   cov
           , snt.tic_package        pac
           , snt.tfahrzeugart       fza
           , snt.ttypgruppe         typ
           , snt.tfahrzeugtyp       fzt
--           snt.tbusiness_area_l2  l2
       where upper(pac.icp_caption)    = upper ( p_icp_caption )
         and pac.icp_package_type      = 2
         and fzg.guid_contract         = cpa.guid_contract
         and pac.guid_package          = cpa.guid_package
         and fza.id_fahrzeugart        = typ.id_fahrzeugart
         and typ.id_typgruppe          = fzt.id_typgruppe
         and fzt.id_fzgtyp             = fzg.id_fzgtyp
--       and l2.guid_business_area_l2  = fza.guid_business_area_l2
         and fzg.id_vertrag            = fzgv.id_vertrag
         and fzg.id_fzgvertrag         = fzgv.id_fzgvertrag
         and fzgv.id_cov               = cov.id_cov
         and cov.cov_caption           not like '%MIG_OOS%'
       order by 1, 2;
--         and cpa.guid_contract         = '1045B5E19DFB4ECAA437F49BE1B51A10';

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   l_guid_package snt.tic_package.guid_package%type;
   l_guid_spc     snt.tsp_contract.guid_spc%type;
   l_guid_partner snt.tpartner.guid_partner%type;

   type TYPE_PPR is table of varchar2(32) index by binary_integer;   -- package_parent_reference

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_contract ( in_GUID_CONTRACT   snt.TFZGVERTRAG.GUID_CONTRACT%type
                         ) return varchar2 is
                           L_RETURNVALUE     varchar2 ( 20 char );
   begin
       select ID_VERTRAG || '/' || ID_FZGVERTRAG
         into L_RETURNVALUE
         from snt.TFZGVERTRAG
        where GUID_CONTRACT = in_GUID_CONTRACT;
        
        return L_RETURNVALUE;
   
   end get_contract;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_SPP_contract ( in_GUID_SPC   snt.TSP_CONTRACT.GUID_SPC%type
                             ) return varchar2 is
                               L_RETURNVALUE     varchar2 ( 20 char );
   begin
       select ID_VERTRAG || '/' || ID_FZGVERTRAG
         into L_RETURNVALUE
         from snt.TSP_CONTRACT
        where GUID_SPC = in_GUID_SPC;
        
        return L_RETURNVALUE;
   
   end get_SPP_contract;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_package ( in_GUID_PACKAGE     snt.TIC_PACKAGE.GUID_PACKAGE%type
                        ) return varchar2 is
                          L_RETURNVALUE       snt.TIC_PACKAGE.ICP_CAPTION%type;
   begin
       select   ICP_CAPTION
         into L_RETURNVALUE
         from snt.TIC_PACKAGE
        where GUID_PACKAGE = in_GUID_PACKAGE;
        
       return L_RETURNVALUE;
   
   end get_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   procedure create_spc_pack_ass(IN_GUID_SPC     varchar2,
                                 IN_GUID_PACKAGE varchar2) is

   -- create supplier-contract package

   begin

      insert into snt.tic_spc_pack_ass (guid_spc, guid_package, guid_package_parent, guid_vi55a)
           values (IN_GUID_SPC, IN_GUID_PACKAGE, null, '9FACEC61A1CD424BA4252BED48AE0238');

   end create_spc_pack_ass;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   function get_guid_package(I_ICP_CAPTION   varchar2
                             ,i_ICP_REFERENCEPACKAGE Varchar2 DEFAULT NULL) 
             RETURN varchar2 is

   -- search for "classic"-package with I_ICP_CAPTION
   -- if found: return guid_package
   -- if not found: create new package according ICP_REFERENCEPACKAGE (copy of) and return guid_package.
   -- if I_ICP_REFERENCEPACKAGE is NULL AND I_ICP_CAPTION is not found,new Package is created with a stub and m ust be maintained afterwards

   L_GUID_PACKAGE           varchar2(32);
   L_GUID_REF               Varchar2(32);
   l_guid_vehicle_line      varchar2(32);
   l_icp_i5x_value          TIC_PACKAGE.icp_i5x_value%TYPE;
   
   begin
       -- defining Defaults
                           l_guid_vehicle_line := null;
                           L_icp_i5x_value := I_ICP_CAPTION;
       
      -- get guid of package
      select GUID_PACKAGE
        into L_GUID_PACKAGE
        from snt.TIC_PACKAGE tic
       where tic.ICP_CAPTION = I_ICP_CAPTION;

      return L_GUID_PACKAGE;

      EXCEPTION
         WHEN no_data_found THEN
            if i_ICP_REFERENCEPACKAGE is not null then
               begin
                   l_guid_ref:= get_guid_package(i_ICP_REFERENCEPACKAGE);
                   
                   select guid_vehicle_line, icp_i5x_value
                   into l_guid_vehicle_line, l_icp_i5x_value
                   from tic_package
                   where guid_package = L_guid_ref;
                   
                   DBMS_Output.put_line('Reference GUID PACKAGE: '||l_guid_vehicle_line||'; Reference VEGA-Line: '||L_icp_i5x_value);
                   EXCEPTION when no_data_found then
                           l_guid_vehicle_line := null;
                           L_icp_i5x_value := I_ICP_CAPTION;
                           
                   WHEN OTHERS then
                         DBMS_output.Put_Line('ERROR during Script execution '||sqlerrm);
                   
               end;            
            end if;
            
             -- create package
            l_guid_package := sys_guid();
            INSERT INTO snt.tic_package (guid_package, id_package, icp_caption, icp_package_type, icp_i5x_value, guid_vehicle_line)
              values (l_guid_package, tic_package_seq.nextval, I_ICP_CAPTION, 2, l_icp_i5x_value, l_guid_vehicle_line);
            
            if L_guid_vehicle_line is null then
              DBMS_Output.put_line('SP2-0000 ==> New Metapackage '||I_ICP_CAPTION||' created in SIRIUS, please check correct configuration in Mask 06.02!');
            else
              DBMS_Output.put_line('New Metapackage '||I_ICP_CAPTION||' created in SIRIUS as copy of '||i_ICP_REFERENCEPACKAGE);
              end if;
            return L_GUID_PACKAGE;

   end get_guid_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   procedure set_meta_package_top_level (IN_GUID_CONTRACT    varchar2,
                                         IN_OLD_GUID_PACKAGE varchar2,
                                         IN_NEW_GUID_PACKAGE varchar2) is

   -- correct position of META-package, set it on top-level

   begin

      begin
         update snt.tic_co_pack_ass
            set guid_package_parent = IN_OLD_GUID_PACKAGE
          where guid_package_parent IS NULL
            and guid_contract = IN_GUID_CONTRACT;

         exception
            when others then
               dbms_output.put_line('smptl err 1: ' || get_contract ( IN_GUID_CONTRACT ));
      end;

      begin
         update snt.tic_co_pack_ass
            set guid_package_parent = NULL
          where guid_package  = IN_OLD_GUID_PACKAGE
            and guid_contract = IN_GUID_CONTRACT;

         exception
            when others then
               dbms_output.put_line('smptl err 2: ' || get_contract ( IN_GUID_CONTRACT ));
      end;
      dbms_output.put_line ( ' set meta package top level for  contract: ' || get_contract ( IN_GUID_CONTRACT ));

      exception
         when others then
            dbms_output.put_line('set_meta_package_top_level err: ' || get_contract ( IN_GUID_CONTRACT ));

   end set_meta_package_top_level;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

 
   procedure set_new_meta_package (IN_OLD_GUID_PACKAGE varchar2,
                                   IN_GUID_CONTRACT    varchar2,
                                   IN_NEW_GUID_PACKAGE varchar2) is

   l_guid_package_parent   varchar2(32);

   begin

      -- 1st make sure, META-Package is on top-level
      select guid_package_parent
        into L_GUID_PACKAGE_PARENT
        from snt.tic_co_pack_ass
       where guid_package  = IN_OLD_GUID_PACKAGE
         and guid_contract = IN_GUID_CONTRACT;

      if not L_GUID_PACKAGE_PARENT is null then
         -- correct package-hierarchy
         set_meta_package_top_level(IN_GUID_CONTRACT=>IN_GUID_CONTRACT,
                                    IN_OLD_GUID_PACKAGE=>IN_OLD_GUID_PACKAGE,
                                    IN_NEW_GUID_PACKAGE=>IN_NEW_GUID_PACKAGE);
         dbms_output.put_line('Repaired package hierarchy for  contract: ' || get_contract ( IN_GUID_CONTRACT ));
      end if;

      -- 2nd replace "old" META-Package by new one
      begin
         UPDATE snt.tic_co_pack_ass
            SET guid_package        = l_guid_package
          WHERE guid_package        = IN_OLD_GUID_PACKAGE
            AND guid_contract       = IN_GUID_CONTRACT;

         exception
            when DUP_VAL_ON_INDEX then null;  -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
         /* when others           then dbms_output.put_line ( 'replace old by new, contract: ' || get_contract ( IN_GUID_CONTRACT ) 
                                                 || ' / old package: ' || get_package  ( IN_OLD_GUID_PACKAGE ) 
                                                 || ' / new package: ' || get_package  ( l_guid_package )); 
         */
      end;
      
      -- set the new parent
      begin
         UPDATE snt.tic_co_pack_ass
            SET guid_package_parent = l_guid_package
          WHERE guid_package_parent = IN_OLD_GUID_PACKAGE
            AND guid_contract       = IN_GUID_CONTRACT;
            if sql%rowcount > 0 then
              dbms_output.put_line(sql%rowcount||'x: Repaired package hierarchy for  contract: ' || get_contract ( IN_GUID_CONTRACT ) || ' - Package: '||IN_OLD_GUID_PACKAGE|| ' - Contract: '||IN_GUID_CONTRACT );
            end if;
         exception
            when DUP_VAL_ON_INDEX then null;  -- keine weitere aktion norwendig, da diese komnbination schon vorhanden
         /* when others           then dbms_output.put_line ( 'set package parent to new, contract: ' || get_contract ( IN_GUID_CONTRACT ) 
                                                        || ' / old package: ' || get_package  ( IN_OLD_GUID_PACKAGE )
                                                        || ' / new package: ' || get_package  ( l_guid_package ));
         */
      end;
      dbms_output.put_line ( 'replace old package by new one, contract: ' || get_contract ( IN_GUID_CONTRACT ) 
                                                    || ' / old package: ' || get_package  ( IN_OLD_GUID_PACKAGE ) 
                                                    || ' / new package: ' || get_package  ( l_guid_package ));

   end set_new_meta_package;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------


   function get_cust_invoice_adress (in_id_customer varchar2) return varchar2 is

      l_id_customer_parent    varchar2(32);
      l_cust_invoice_adress   varchar2(32);

   begin
      -- parent?
      select id_customer_parent, cust_invoice_adress
        into l_id_customer_parent, l_cust_invoice_adress
        from snt.tcustomer
       where id_customer = in_id_customer;
      
      if not l_id_customer_parent is null then
         l_cust_invoice_adress := get_cust_invoice_adress(in_id_customer => l_id_customer_parent);
      end if;
      
      return l_cust_invoice_adress;
      
   end get_cust_invoice_adress;
   
--MAIN====================================================================================================================

   begin

      begin

         --===============================================================================================================
         --A) - Extend
         --1) Prüfe, ob Metapakete "Extend Trapo" und "Extend LKW" existiert. falls nein, erzeuge das METAPAKET neu.
         --2) Für alle Verträge in Scope die (als Metapaket "Extend" oder "Extend LKW") haben UND die Division des Vertrags ist "VANs":
         --a) Metapaketreferenz löschen
         --b) Neue Metapaketreferenz zu "Extend Trapo"
         --3) Für alle Verträge in Scope die (als Metapaket "Extend" oder "Extend Trapo") haben UND die Division des Vertrags ist "DCTrucks":
         --a) Metapaketreferenz löschen
         --b) Neue Metapaketreferenz zu "Extend LKW"
         --==================================================================================================================================

	dbms_output.put_line ( chr(10) || 'Begin step A1 - Extend: Division VANs and ( META package Extend or Extend LKW ) get new META package Extend Trapo:' );
				 
         l_guid_package := get_guid_package ( I_ICP_CAPTION => 'Extend Trapo' );
         FOR c_cpa_guid_contract IN c_guid_contract ( 'Extend', 'Extend LKW', 'VANs' )
         LOOP
            begin
               set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                                    IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                                    IN_NEW_GUID_PACKAGE => l_guid_package);
               -- dbms_output.put_line('Extend Trapo set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));

               exception
               when others then
                  dbms_output.put_line('ERROR A1-EXTEND_TRAPO: ' || get_contract ( c_cpa_guid_contract.guid_contract )||' - '||sqlerrm);
            end;
         END LOOP;

				 dbms_output.put_line ( chr(10) || 'Begin step A2 - Extend: Division DCTrucks and ( META package Extend or Extend Trapo ) get new META package Extend LKW:' );
				 
         l_guid_package := get_guid_package ( I_ICP_CAPTION => 'Extend LKW' );
         FOR c_cpa_guid_contract IN c_guid_contract('Extend', 'Extend Trapo', 'DCTrucks')
         LOOP
            begin
               set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                                    IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                                    IN_NEW_GUID_PACKAGE => l_guid_package);
               -- dbms_output.put_line('Extend LKW set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
               
               exception
               when others then
                  dbms_output.put_line('A2-Extend LKW: ' || get_contract ( c_cpa_guid_contract.guid_contract )||' - '||sqlerrm);
            end;
         END LOOP;
         
      end;
      
      --==================================================================================================================================
      --B) Power Pack
      --1) Prüfe, ob Metapakete "Complete LKW+PowerPack" und "Complete Trapo+PowerPack" existiert. falls nein, erzeuge das METAPAKET neu.
      --2) Für alle Verträge in Scope, die das Attributpaket "PowerPack" haben UND die Division "DCTrucks" UND das Metapaket "Complete LKW"
      --a) Metapaketreferenz löschen
      --b) Neue Metapaketreferenz zu "Complete LKW+PowerPack"
      --3) Für alle Verträge in Scope, die das Attributpaket "PowerPack" haben UND die Division "VANs" UND das Metapaket "Complete LKW"
      --a) Metapaketreferenz löschen
      --b) Neue Metapaketreferenz zu "Complete Trapo+PowerPack"
      --4) Für alle Verträge in Scope, die das Attributpaket "PowerPack" haben UND die Division "Vans" UND das Metapaket "Complete Trapo"
      --a) Metapaketreferenz löschen
      --b) Neue Metapaketreferenz zu "Complete Trapo+PowerPack"
      --==================================================================================================================================

      dbms_output.put_line ( chr(10) || 'Begin step B1 - Power Pack: Division DCTrucks and META package Complete LKW and attribute package Power Pack get new META package Complete LKW+PowerPack:' );
      
      l_guid_package := get_guid_package ( I_ICP_CAPTION => 'Complete LKW+PowerPack' );
      FOR c_cpa_guid_contract IN c_powerpack ( 'Complete LKW', 'Power Pack', 'DCTrucks' )
      LOOP
         set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                              IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                              IN_NEW_GUID_PACKAGE => l_guid_package);
         -- dbms_output.put_line('Complete LKW+PowerPack set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
      END LOOP;

      dbms_output.put_line ( chr(10) || 'Begin step B2 - Power Pack: Division VANs and META package Complete LKW and attribute package Power Pack get new META package Complete Trapo+PowerPack' );
      
      l_guid_package := get_guid_package ( I_ICP_CAPTION => 'Complete Trapo+PowerPack' );
      FOR c_cpa_guid_contract IN c_powerpack ( 'Complete LKW', 'Power Pack', 'VANs' )
      LOOP
         set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                              IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                              IN_NEW_GUID_PACKAGE => l_guid_package);
         -- dbms_output.put_line('Complete Trapo+PowerPack set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
      END LOOP;

      dbms_output.put_line ( chr(10) || 'Begin step B3 - Power Pack: Division VANs and META package Complete Trapo and attribute package Power Pack to new META package Complete Trapo+PowerPack:' );
      
      FOR c_cpa_guid_contract IN c_powerpack ( 'Complete Trapo', 'Power Pack', 'VANs' )
      LOOP
         set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                              IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                              IN_NEW_GUID_PACKAGE => l_guid_package);
         -- dbms_output.put_line('Complete Trapo+PowerPack set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
      END LOOP;
      
      --===============================================================================================================
      --C) - Complete + Powerpack_BUNDLE
      --1) Prüfe, ob Metapakete "Complete LKW+PowerPack_BUNDLE" und "Complete Trapo+PowerPack_BUNDLE" existiert. falls nein, erzeuge das METAPAKET neu.
      --2) Für alle Verträge in Scope die als Metapaket "Complete LKW+PowerPack" haben UND der Rechnungsempfänger ist "00000013001"
      --a) Metapaketreferenz löschen
      --b) Neue Metapaketreferenz zu "Complete LKW+PowerPack_BUNDLE"
      --3) Für alle Verträge in Scope die als Metapaket "Complete Trapo+PowerPack" haben UND der Rechnungsempfänger ist "00000013001"
      --a) Metapaketreferenz löschen
      --b) Neue Metapaketreferenz zu "Complete Trapo+PowerPack_BUNDLE"
      --===============================================================================================================

      dbms_output.put_line ( chr(10) || 'Begin step C1 - Complete + Powerpack BUNDLE: META package Complete LKW+PowerPack and alternate invoice receiver 00000013001 get new META package Complete LKW+PowerPack_BUNDLE:' );
      
      l_guid_package := get_guid_package('Complete LKW+PowerPack_BUNDLE','Complete LKW+PowerPack');
      
      FOR c_cpa_guid_contract IN c_powerpack_BUNDLE ( 'Complete LKW+PowerPack' )
      LOOP
         if get_cust_invoice_adress(c_cpa_guid_contract.id_customer) = '00000013001' then
            set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                                 IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                                 IN_NEW_GUID_PACKAGE => l_guid_package);
            -- dbms_output.put_line('Complete LKW+PowerPack_BUNDLE set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
         end if;
      END LOOP;

      dbms_output.put_line ( chr(10) || 'Begin step C2 - Complete + Powerpack BUNDLE: META package Complete Trapo+PowerPack and alternate invoice receiver 00000013001 get new META package Complete Trapo+PowerPack_BUNDLE: ' );
      
      l_guid_package := get_guid_package('Complete Trapo+PowerPack_BUNDLE','Complete Trapo+PowerPack');
      FOR c_cpa_guid_contract IN c_powerpack_BUNDLE ( 'Complete Trapo+PowerPack' )
      LOOP
         if get_cust_invoice_adress(c_cpa_guid_contract.id_customer) = '00000013001' then
            set_new_meta_package(IN_OLD_GUID_PACKAGE => c_cpa_guid_contract.guid_package,
                                 IN_GUID_CONTRACT    => c_cpa_guid_contract.guid_contract,
                                 IN_NEW_GUID_PACKAGE => l_guid_package);
            -- dbms_output.put_line('Complete Trapo+PowerPack_BUNDLE set for contract: ' || get_contract ( c_cpa_guid_contract.guid_contract ));
         end if;
      END LOOP;
      
      dbms_output.put_line ( chr(10) || 'Begin step D - Remove obsolete Attribute Packages' );
      
      --=========================================================================================
      --D) - Remove obsolete Attribute Packages
      -- 
      --1) Lösche in Allen Verträgen:
      --a) Attributreferenz "Power Pack"
      --b) Attributreferenz "GE01"
      --2) Lösche Attributpakete
      --a) "Power Pack"
      --b) "GE01"
      
      -- change all contracts with attribute-package "Power Pack"
      l_guid_package := get_guid_package ( I_ICP_CAPTION => 'Power Pack' );
      for o_pack_contract in (select GUID_CONTRACT
                                from snt.tic_co_pack_ass
                               where guid_package = l_guid_package)
      loop
         -- dbms_output.put_line ( get_contract ( o_pack_contract.guid_contract ));
         -- set reference to higher package_parent
         update snt.tic_co_pack_ass
            set guid_package_parent = (select guid_package_parent
                                         from snt.tic_co_pack_ass
                                        where guid_contract = o_pack_contract.guid_contract
                                          and guid_package  = l_guid_package)
          where guid_contract        = o_pack_contract.guid_contract
            and guid_package_parent  = l_guid_package;
         dbms_output.put_line ( 'Package Power Pack removed from contract: ' || get_contract ( o_pack_contract.guid_contract ));

         -- delete obsolete one
         delete from snt.tic_co_pack_ass
          where guid_contract = o_pack_contract.guid_contract
            and guid_package  = l_guid_package;

      end loop;

      -- at least, delete package
      delete from tic_package where icp_caption = 'Power Pack';
      dbms_output.put_line ( 'Package Power Pack deleted' || chr(10) );

      -- change all contracts with attribute-package "GE01"
      l_guid_package := get_guid_package ( I_ICP_CAPTION => 'GE01' );
      for o_pack_contract in (select GUID_CONTRACT
                                from snt.tic_co_pack_ass
                               where guid_package = l_guid_package)
      loop
         --dbms_output.put_line ( get_contract ( o_pack_contract.guid_contract ));
         -- set reference to higher package_parent
         update snt.tic_co_pack_ass
            set guid_package_parent = (select guid_package_parent
                                         from snt.tic_co_pack_ass
                                        where guid_contract = o_pack_contract.guid_contract
                                          and guid_package  = l_guid_package)
          where guid_contract        = o_pack_contract.guid_contract
            and guid_package_parent  = l_guid_package;
         dbms_output.put_line('Package GE01 removed  from contract: ' || get_contract ( o_pack_contract.guid_contract ));

         -- delete obsolete one
         delete from snt.tic_co_pack_ass
          where guid_contract = o_pack_contract.guid_contract
            and guid_package  = l_guid_package;

      end loop;

      -- at least, delete package
      delete from tic_package where icp_caption = 'GE01';
      dbms_output.put_line ( 'Package GE01 deleted' || chr(10) );


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
alter trigger snt.TIC_CO_PACK_ASS_CHECK_AFT enable;
alter trigger snt.TIC_CO_PACK_ASS_CHECK_BEF enable;
alter trigger snt.TIC_CO_PACK_ASS_CHECK_ROW enable;

alter trigger snt.TIC_SPC_PACK_ASS_CHK_AFT enable;
alter trigger snt.TIC_SPC_PACK_ASS_CHK_BEF enable;
alter trigger snt.TIC_SPC_PACK_ASS_CHK_ROW enable;

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
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataCleansing_PRODUCTHOUSE_MBBEL_Change_Metapackages_and_Attributepackages.log
prompt

exit;
