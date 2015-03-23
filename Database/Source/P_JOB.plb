CREATE OR REPLACE PACKAGE BODY P_JOB
IS
--
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2014/10/17 13:37:58MESZ $
--
-- $Name: CBL_PreInt4  $
--
-- $Revision: 1.3 $
--
-- $Header: 5100_Code_Base/Database/Source/P_JOB.plb 1.3 2014/10/17 13:37:58MESZ Kieninger, Tobias (tkienin) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/P_JOB.plb $
--
-- $Log: 5100_Code_Base/Database/Source/P_JOB.plb  $
-- Revision 1.3 2014/10/17 13:37:58MESZ Kieninger, Tobias (tkienin) 
-- fix
-- Revision 1.2 2014/10/15 16:19:20MESZ Kieninger, Tobias (tkienin) 
-- interval 1
-- Revision 1.1 2012/10/09 16:25:23MESZ Berger, Franz (fraberg) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
--
-- MKSEND

-- Purpose: package für alle SiMEX jobs
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ----------  ------------------------------------------
-- FraBe       01.10.2012  MKS-117502:1 creation

---------------------------------------------------------------------------------
   lgc_modul   CONSTANT VARCHAR2 (100) DEFAULT 'P_JOB';

-------------------------------------------------------------------------------
   PROCEDURE create_JOB_SiMEX (
      i_repeat_interval   VARCHAR2 DEFAULT 'FREQ=MINUTELY; INTERVAL=5'
   )
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      0 -> success / -1 fail: The message is stored in the table TLOG
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitäprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret                   integer               DEFAULT 0;            -- success
      lc_sub_modul   CONSTANT VARCHAR2 (100)        DEFAULT 'CREATE_JOB_SiMEX';
   BEGIN
      DBMS_SCHEDULER.create_job
         (job_name                 => 'JOB_SiMEX'
         ,job_type                 => 'PLSQL_BLOCK'
         ,job_action               => 'begin SiMEX.PCK_EXPORTER.PROCESS; end;'
         ,number_of_arguments      => 0
         ,start_date               => SYSTIMESTAMP
         ,repeat_interval          => i_repeat_interval
         ,end_date                 => NULL
         ,job_class                => 'DEFAULT_JOB_CLASS'
         ,enabled                  => TRUE
         ,auto_drop                => FALSE
         ,comments                 => 'Starts SiMEX job which exports SIRIUS data to xml files'
         );
   END create_JOB_SiMEX;

-------------------------------------------------------------------------------
   PROCEDURE enable_JOB_SiMEX
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      0 -> success / -1 fail: The message is stored in the table TLOG
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitäprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret                   integer               DEFAULT 0;            -- success
      lc_sub_modul   CONSTANT VARCHAR2 (100)        DEFAULT 'enable_JOB_SiMEX';
   BEGIN
      DBMS_SCHEDULER.ENABLE ('JOB_SiMEX');
   END enable_JOB_SiMEX;

-------------------------------------------------------------------------------
   PROCEDURE disable_JOB_SiMEX
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      0 -> success / -1 fail: The message is stored in the table TLOG
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret                   integer               DEFAULT 0;            -- success
      lc_sub_modul   CONSTANT VARCHAR2 (100)        DEFAULT 'DISABLE_JOB_SiMEX';
   BEGIN
      DBMS_SCHEDULER.DISABLE ('JOB_SiMEX');
   END disable_JOB_SiMEX;

-------------------------------------------------------------------------------
   PROCEDURE drop_JOB_SiMEX
   IS
--  PURPOSE
--
--  PARAMETERS
--    In-Parameter
--    Return bei Funktionen
--      0 -> success / -1 fail: The message is stored in the table TLOG
--  DATABASE TRANSACTIONBEHAVIOR
--    atomic
--  EXCEPTIONS
--    In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--    jeweils durchgeführten Plausibilitsprüfungen
--    Auswirkungen auf den Bildschirm
--    durchgeführten Protokollierung
--    abgelegten Tracinginformationen
--  ENDPURPOSE
-------------------------------------------------------------------------------
      l_ret                   integer               DEFAULT 0;            -- success
      lc_sub_modul   CONSTANT VARCHAR2 (100)        DEFAULT 'DROP_JOB_SiMEX';
   BEGIN
      DBMS_SCHEDULER.drop_job ('JOB_SiMEX');
   END drop_JOB_SiMEX;

-------------------------------------------------------------------------------

   FUNCTION whoami
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision: 1.3 $';
   END whoami;
END p_job;
/
