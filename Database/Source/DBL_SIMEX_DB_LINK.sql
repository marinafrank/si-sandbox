-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/02/26 14:32:22MEZ $
--
-- $Name: CBL_PreInt4 CBL_Wave1 CBL_Wave3.2 CBL_WavePI2_Partner+Vertrag  $
--
-- $Revision: 1.4 $
--
-- $Header: 5100_Code_Base/Database/Source/DBL_SIMEX_DB_LINK.sql 1.4 2014/02/26 14:32:22MEZ Berger, Franz (fraberg) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/DBL_SIMEX_DB_LINK.sql $
--
-- $Log: 5100_Code_Base/Database/Source/DBL_SIMEX_DB_LINK.sql  $
-- Revision 1.4 2014/02/26 14:32:22MEZ Berger, Franz (fraberg) 
-- move insert to script load_SiMEX_basedata.sql (-> die tabelle existiert noch nicht wenn dieses script läuft )
-- Revision 1.3 2014/02/24 17:18:34MEZ Kieninger, Tobias (tkienin) 
-- Fetch CountryCode from Simex_db_link
-- Revision 1.2 2012/10/10 17:31:18MESZ Berger, Franz (fraberg) 
-- some small cosmetic changes
-- Revision 1.1 2012/10/09 16:25:23MESZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
--
-- MKSEND

-- Purpose: creates SiMEX DB link
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ----------  ------------------------------------------
-- FraBe       01.10.2012  MKS-117502:1 creation
-- TK          25.02.2014  add insert COUNTRY_CODE into tsetting
-- FraBe       26.02.2014  MKS-131343:2 beim gestrigen insert fehlt der owner simex. vorm tabellennamen
-- FraBe       26.02.2014  MKS-131343:2 move insert to script (-> die tabelle existiert noch nicht wenn dieses script läuft )

-- DBLINK_SNT_PASSWORD and DBLINK_DATABASE_NAME are defined during start of script

create database link SIMEX_DB_LINK
   connect to SNT identified by &&DBLINK_SNT_PASSWORD
   using '&&DBLINK_DATABASE_NAME';