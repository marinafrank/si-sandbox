CREATE OR REPLACE PACKAGE BODY SIMEX.PCK_EXPORTER
IS
--
--
-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2015/03/06 16:10:41MEZ $
--
-- $Name:  $
--
-- $Revision: 1.42 $
--
-- $Header: 5100_Code_Base/Database/Source/PCK_EXPORTER.plb 1.42 2015/03/06 16:10:41MEZ Frank, Marina (marinf) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/PCK_EXPORTER.plb $
--
-- $Log: 5100_Code_Base/Database/Source/PCK_EXPORTER.plb  $
-- Revision 1.42 2015/03/06 16:10:41MEZ Frank, Marina (marinf) 
-- MKS-136133:1 Added Cost Full Export
-- Revision 1.41 2015/02/19 16:32:29MEZ Frank, Marina (marinf) 
-- MKS-136487:1 launcher: Moved Vega Mappinglist File Numbering to pck_exports.expVEGAMappingList
-- Revision 1.40 2015/02/02 16:23:28MEZ Zimmerberger, Markus (zimmerb) 
-- launcher: Formatting of CSV filename-timestamp similar to XML, enhanced logging
-- Revision 1.39 2015/01/26 15:28:18MEZ Zimmerberger, Markus (zimmerb) 
-- launcher: Use filenaming standards on csv-exports
-- Revision 1.38 2015/01/08 10:19:11MEZ Zimmerberger, Markus (zimmerb) 
-- launcher: Rename expVEGAMappingList to EXP_VEGAMappingList
-- Revision 1.37 2015/01/08 09:49:45MEZ Zimmerberger, Markus (zimmerb) 
-- Add expVEGAMappingList
-- Revision 1.36 2014/11/26 10:32:18MEZ Berger, Franz (fraberg) 
-- launcher: add calling expCustomerContract / expVehicleContract
-- plus neuen filenamen bei expServiceContract
-- Revision 1.35 2014/10/31 07:26:50MEZ Berger, Franz (fraberg) 
-- launcher: correct ModificationProtocolEntry - filename
-- Revision 1.34 2014/10/30 17:12:16MEZ Zimmerberger, Markus (zimmerb) 
-- Add expModProto
-- Revision 1.33 2014/10/17 17:14:30MESZ Kieninger, Tobias (tkienin) 
-- typo in tas_active=0 entfernt
-- Revision 1.32 2014/10/15 16:21:20MESZ Kieninger, Tobias (tkienin)
-- Commit after each export
-- only one export per Scheduler run
-- Revision 1.31 2014/09/16 10:34:50MESZ Kieninger, Tobias (tkienin)
-- merging Branch
-- Revision 1.30 2014/06/27 14:29:11MESZ Berger, Franz (fraberg)
-- launcher: l�schen trailing blank aus AssignCostToCost filename
-- Revision 1.29 2014/06/02 10:46:21MESZ Berger, Franz (fraberg)
-- launcher: add EXP_AssignCostToCost
-- Revision 1.28 2014/05/16 10:55:49MESZ Berger, Franz (fraberg)
-- launcher: add EXP_CollectiveWorkshopInvoice
-- Revision 1.27 2014/03/04 14:56:16MEZ Berger, Franz (fraberg)
-- ExpFIN CR#10: neuer filename bei EXP_FIN
-- Revision 1.26 2014/01/17 11:27:28MEZ Berger, Franz (fraberg)
-- process:  new order by TAS_ORDER
-- Revision 1.25 2014/01/16 17:20:35MEZ Berger, Franz (fraberg)
-- launcher: add i_filename_cre/upd due to new wave1 pck_partner.expCommercialCustomer - upd logic
-- Revision 1.24 2013/12/04 15:40:10MEZ Zimmerberger, Markus (zimmerb)
-- launcher: add launching of EXP_DEALER
-- Revision 1.23 2013/12/03 13:44:19MEZ Berger, Franz (fraberg)
-- expPrivateCustomer: due to  new wave1 upd logic : split i_filename to i_filename_cre/upd
-- Revision 1.22 2013/11/18 10:32:41MEZ Berger, Franz (fraberg)
-- launcher: change PCK_EXPORTS.expALL_ODOMETER call to PCK_CONTRACT.expALL_ODOMETER
-- Revision 1.21 2013/11/16 07:48:06MEZ Berger, Franz (fraberg)
-- launcher: statt aufruf PCK_EXPORTS. ...
-- aufruf PCK_PARTNER. ...
-- - expPrivateCustomer
-- - expCommercialCustomer
-- - expContactPerson
-- - expWorkshop
-- - expSupplier
-- - expSalesman
--
-- aufruf PCK_CONTRACT:
-- - expServiceContract
-- - expALL_CONTRACTS
--
-- aufruf PCK_COST:
-- - expWorkshopInvoice
--
-- aufruf PCK_REVENUE:
-- - expRevenue
-- Revision 1.20 2013/11/13 14:36:12MEZ Zimmerberger, Markus (zimmerb)
-- launcher: add launching of EXP_REVENUE
-- Revision 1.19 2013/10/29 16:24:43MEZ Berger, Franz (fraberg)
-- launcher: add launching of EXP_WorkshopInvoice
-- Revision 1.18 2013/10/14 17:51:07MESZ Berger, Franz (fraberg)
-- launcher: new logic within finding l_filename for EXP_ODOMETER as well
-- Revision 1.17 2013/06/24 17:52:01MESZ Berger, Franz (fraberg)
-- - add call of pck_exports.expServiceContract
-- - do do not hyphen the filename  - YYYYMMDD and HH24MISS
-- Revision 1.16 2013/06/07 15:16:50MESZ Berger, Franz (fraberg)
-- launcher: new logic within finding l_filename
-- Revision 1.15 2013/03/29 10:25:49MEZ Berger, Franz (fraberg)
-- add expSalesman
-- Revision 1.14 2013/03/28 10:55:44MEZ Berger, Franz (fraberg)
-- launcher: neue logik aufbereiten L_filename EDF PARTNER files
-- Revision 1.13 2013/03/27 15:41:24MEZ Berger, Franz (fraberg)
-- add expSupplier
-- Revision 1.12 2013/03/25 15:38:40MEZ Berger, Franz (fraberg)
-- add export OrganisationalPerson - Workshop
-- Revision 1.11 2013/03/19 12:51:31MEZ Berger, Franz (fraberg)
-- add expInventoryList
-- Revision 1.10 2013/01/14 16:16:42MEZ Berger, Franz (fraberg)
-- add expFIN
-- Revision 1.9 2013/01/05 16:31:50MEZ Berger, Franz (fraberg)
-- add MigrationScopeList Customer
-- Revision 1.8 2012/12/31 21:11:13MEZ Berger, Franz (fraberg)
-- add TAS_PROCEDURE = 'EXP_CONTACTPERSON'
-- Revision 1.7 2012/12/05 14:41:51MEZ Berger, Franz (fraberg)
-- change EXP_PHYSICALPERSON to EXP_PRIVATECUSTOMER / add call of EXP_COMMERCIALCUSTOMER
-- Revision 1.5 2012/10/18 18:27:38MESZ Berger, Franz (fraberg)
-- cancel_job neuerlich �berarbeitet
-- Revision 1.4 2012/10/17 16:17:21MESZ Berger, Franz (fraberg)
-- cancel_job �berarbeitet
-- Revision 1.3 2012/10/12 15:40:47MESZ Kieninger, Tobias (tkienin)
-- odometer added
-- Revision 1.2 2012/10/12 15:27:27MESZ Berger, Franz (fraberg)
-- add variable L_FILE_RUNNING_NO to function Launcher
-- Revision 1.1 2012/10/09 16:25:24MESZ Berger, Franz (fraberg)
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
--
-- MKSEND

-- Purpose: main SiMEX package f�r den start / cancel / log SiMEX jobs
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- ---------   ----------  ------------------------------------------
-- FraBe       01.10.2012  MKS-117502:1 creation
-- FraBe       17.10.2012  MKS-117506:2 cancel_job �berarbeitet
-- FraBe       18.10.2012  MKS-117506:2 cancel_job neuerlich �berarbeitet
-- FraBe       18.03.2013  MKS-121684:1 add expInventoryList
-- FraBe       24.03.2013  MKS-122279:1 add expWorkshop
-- FraBe       27.03.2013  MKS-123819:1 add expSupplier
-- FraBe       27.03.2013  MKS-123938:1 launcher: neue logik aufbereiten L_filename EXP PARTNER files
-- FraBe       14.10.2013  MKS-124191:1 launcher: new logic within finding l_filename for EXP_ODOMETER as well
-- FraBe       29.10.2013  MKS-121600:2 launcher: add launching of EXP_WorkshopInvoice
-- ZBerger     13.11.2013  MKS-123543:1 launcher: add launching of EXP_REVENUE
-- FraBe       15.11.2013  MKS-129687:1 launcher: change some PCK_EXPORTS call to PCK_PARTNER / PCK_CONTRACT / PCK_COST / PCK_REVENUE
-- FraBe       18.11.2013  MKS-129687:1 launcher: change PCK_EXPORTS.expALL_ODOMETER call to PCK_CONTRACT.expALL_ODOMETER
-- FraBe       04.12.2013  MKS-129743:1 launcher: add i_filename_cre/upd due to new wave1 pck_partner.expPrivateCustomer - upd logic
-- ZBerger     04.12.2013  MKS-129347:1 launcher: add launching of EXP_DEALER
-- FraBe       16.01.2014  MKS-130369:1 launcher: add i_filename_cre/upd due to new wave1 pck_partner.expCommercialCustomer - upd logic
-- FraBe       16.01.2014  MKS-130540:1 process:  new order by TAS_ORDER
-- FraBe       04.03.2014  MKS-131048:1 launcher: neuer filename bei EXP_FIN
-- FraBe       04.03.2014  MKS-131815:1 launcher: add EXP_CollectiveWorkshopInvoice
-- FraBe       28.05.2014  MKS-130281:1 launcher: add EXP_AssignCostToCost
-- FraBe       27.06.2014  MKS-133416:2 launcher: delete trailing blank from AssignCostToCost filename
-- ZBerger     30.10.2014  MKS-134522:1 launcher: add launching of EXP_MODPROTO
-- FraBe       31.10.2014  MKS-134523:1 launcher: correct ModificationProtocolEntry - filename
-- FraBe       20.11.2014  MKS-135622/135623/135636/135637 / launcher: add calling expCustomerContract / expVehicleContract
--                                       plus neuen filenamen bei expServiceContract
-- ZBerger     23.12.2014  MKS-135606:2 launcher: add launching of expVEGAMappingList
-- ZBerger     08.01.2015  MKS-135606:2 launcher: Rename expVEGAMappingList to EXP_VEGAMappingList
-- ZBerger     23.01.2015  MKS-136002:1 launcher: Use filenaming standards on csv-exports
-- ZBerger     02.02.2015  MKS-136002:2 launcher: Formatting of CSV filename-timestamp similar to XML, enhanced logging
-- Marinf      19.02.2015  MKS-136487:1 launcher: Moved Vega Mappinglist File Numbering to pck_exports.expVEGAMappingList
  
   /* PROCEDURE SiMEXlog:
      New parameter p_force encapsulates checking of DEBUG setting.
      DEFAULT is TRUE for maintaining existing code, i.e. log without checking, in assumption that this check is already made by the caller.
   */
   PROCEDURE SiMEXlog
    ( i_TAS_GUID      TLOG.TAS_GUID%type
    , i_LOG_ID        TLOG.LOG_ID%type
    , i_LOG_TEXT      VARCHAR2                 DEFAULT NULL
    , i_LOG_TIMESTAMP TLOG.LOG_TIMESTAMP%type  DEFAULT systimestamp
    , p_force         BOOLEAN                  DEFAULT TRUE          
    ) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    L_LOG_SEQUENCE   TLOG.LOG_SEQUENCE%type;
    L_STAT           varchar2 ( 1 char );
    l_msg            VARCHAR2(32767);
   BEGIN
     IF PCK_CALCULATION.GET_SETTING('SETTING', 'DEBUG', 'FALSE') = 'TRUE' OR p_force THEN
      l_msg := substr(i_LOG_TEXT,1,500);
      select null
        into L_STAT
        from TLOG
       where TAS_GUID      = i_TAS_GUID
         and LOG_ID        = i_LOG_ID
         and LOG_TEXT      = l_msg
         and LOG_TIMESTAMP = i_LOG_TIMESTAMP;
      --- nix weiteres zu tun, da logeintrag schon existiert - braucht kein zweites mal geinserted zu werden
     END IF; 
   exception
   when NO_DATA_FOUND
        then L_LOG_SEQUENCE := TLOG_SEQ.nextval;

             insert into TLOG
                    (   TAS_GUID,   LOG_ID,   LOG_TEXT,   LOG_SEQUENCE,   LOG_TIMESTAMP )
             values ( i_TAS_GUID, i_LOG_ID,   l_msg   , L_LOG_SEQUENCE, i_LOG_TIMESTAMP );

             commit;

   when DUP_VAL_ON_INDEX then null;
   END;
-----

   PROCEDURE SiMEXhistory
    ( i_TAS_GUID     TTASK_HISTORY.TAS_GUID%type
    , i_TASH_STATE   TTASK_HISTORY.TASH_STATE%type
    ) IS

   BEGIN
      insert into TTASK_HISTORY
             (   TAS_GUID,   TASH_STATE )
      values ( i_TAS_GUID, i_TASH_STATE );

   END;

-----

   PROCEDURE SiMEXstatus
    ( i_TAS_GUID     TTASK.TAS_GUID%type
    , i_TAS_ACTIVE   TTASK.TAS_ACTIVE%type
    ) IS

   BEGIN
      update TTASK
         set TAS_ACTIVE = i_TAS_ACTIVE
       where TAS_GUID   = i_TAS_GUID;

   END;

-----

   function cancel_job
          ( I_TAS_GUID     TTASK.TAS_GUID%TYPE
          , I_TAS_CAPTION  TTASK.TAS_CAPTION%TYPE default null )
       return number is

   -- Change history
   -- FraBe       17.10.2012  MKS-117506:2 �berarbeitet

       L_count_history   integer;
       L_TAS_CAPTION     TTASK.TAS_CAPTION%TYPE := null;
       L_TASH_STATE      TTASK_HISTORY.TASH_STATE%TYPE := null;
       L_RETURNVALUE     integer;

   begin
       if   I_TAS_CAPTION is not null
       then L_TAS_CAPTION := I_TAS_CAPTION;
       else select   TAS_CAPTION
              into L_TAS_CAPTION
              from TTASK
             where TAS_GUID  = I_TAS_GUID;
       end  if;
       ---
       begin
             select th1.TASH_STATE
               into   L_TASH_STATE
               from TTASK_HISTORY th1
              where th1.TAS_GUID       = I_TAS_GUID
                and th1.TASH_TIMESTAMP = ( select max ( th2.TASH_TIMESTAMP )
                                             from TTASK_HISTORY th2
                                            where th2.TAS_GUID       = I_TAS_GUID );
       exception when NO_DATA_FOUND then L_TASH_STATE := 9;
       end;
       ---
       if   L_TASH_STATE = 0
       then SiMEXlog ( i_TAS_GUID   => I_TAS_GUID
                     , i_LOG_ID     => '0006'    -- Job successfully cancelled
                     , i_LOG_TEXT   => L_TAS_CAPTION );

            L_RETURNVALUE := 0;   -- success

       else SiMEXlog ( i_TAS_GUID   => I_TAS_GUID
                     , i_LOG_ID     => '0007'              -- Job cannot be cancelled as already running / finished / cancelled
                     , i_LOG_TEXT   => L_TAS_CAPTION );

            L_RETURNVALUE := -1;  -- fail

       end  if;

            SiMEXhistory ( i_TAS_GUID     => i_TAS_GUID
                         , i_TASH_STATE   => 4 );             -- 4 means: cancelled

       return L_RETURNVALUE;

   exception when others then SiMEXlog ( i_TAS_GUID   => I_TAS_GUID
                                       , i_LOG_ID     => '0008'    -- something went rong within cancelling job
                                       , i_LOG_TEXT   => SQLERRM );

                              raise_application_error ( -20000, SQLERRM );
   end;

   PROCEDURE process
   IS

   -- Change history
   -- FraBe 16.01.2014  MKS-130540:1 new order by TAS_ORDER

      l_ret                 NUMBER;
   BEGIN

      /*   -- ist einstweilen ausgeschaltet, da ja jedes mal eine logzeile geschrieben wird, wenn der job startet und ended
           -- auch wenn er keinen export startet. au�erdem ist dies kein wichtiger logeintrag -> bl�ht die logdatei nur unn�tig auf.
           -- bei probmelen mit dem job kann auch in der ALL_SCHEDULER_JOB_RUN_DETAILS nachgeschaut werden: where jobname = 'JOB_SIMEX'

      SiMEXlog ( i_TAS_GUID   => null
               , i_LOG_ID     => '0001'    -- Job started
               , i_LOG_TEXT   => 'JOB_SiMEX' );
      */

      for crec in (
        SELECT * FROM (SELECT TAS_GUID
                            , TAS_CAPTION
                            , TAS_PROCEDURE
                            , TAS_MAX_NODES
                         FROM TTASK
                        WHERE TAS_ACTIVE = 1
                     ORDER BY TAS_ORDER ASC
                      ) WHERE Rownum = 1 -- get a single task with lowest TAS_ORDER 
      )
      loop

         --> Launcher Aufruf
         l_ret := launcher ( i_TAS_GUID             => crec.TAS_GUID
                           , i_TAS_CAPTION          => crec.TAS_CAPTION
                           , i_TAS_PROCEDURE        => crec.TAS_PROCEDURE
                           , i_TAS_MAX_NODES        => crec.TAS_MAX_NODES
                           );

         SiMEXstatus ( i_TAS_GUID     => crec.TAS_GUID
                     , i_TAS_ACTIVE   => 0 );              -- 0 means: not active anymore

        COMMIT;


      end loop;

      /*   -- siehe kommentar ein paar zeilen oberhalb bei Job started
      SiMEXlog ( i_TAS_GUID   => null
               , i_LOG_ID     => '0002'     -- Job ended
               , i_LOG_TEXT   => 'JOB_SiMEX' );
      */
   END;


-----


   FUNCTION launcher (
       i_TAS_GUID            VARCHAR2
     , i_TAS_CAPTION         VARCHAR2
     , i_TAS_PROCEDURE       varchar2
     , i_TAS_MAX_NODES       integer
   )
      RETURN NUMBER
   IS

   -- Change history
   -- FraBe       12.10.2012  MKS-118722:1 add variable L_FILE_RUNNING_NO
   -- FraBe       05.01.2013  MKS-121274:1 add MigrationScopeList Customer
   -- FraBe       14.01.2013  MKS-121478:1 add expFIN
   -- FraBe       19.03.2013  MKS-121684:1 add expInventoryList
   -- FraBe       25.03.2013  MKS-122279:1 add export OrganisationalPerson - Workshop
   -- FraBe       27.03.2013  MKS-123819:1 add expSupplier
   -- FraBe       27.03.2013  MKS-123938:1 neue logik aufbereiten L_filename EDF PARTNER files
   -- FraBe       28.03.2013  MKS-123816:2 add expSalesman
   -- FraBe       07.06.2013  MKS-126276:1 new logic within finding l_filename
   -- FraBe       14.10.2013  MKS-124191:1 new logic within finding l_filename for EXP_ODOMETER as well
   -- FraBe       29.10.2013  MKS-121600:2 add launching of EXP_WorkshopInvoice
   -- ZBerger     13.11.2013  MKS-123543:1 add launching of EXP_REVENUE
   -- FraBe       15.11.2013  MKS-129687:1 statt aufruf PCK_EXPORTS. ...
   --                                      aufruf PCK_PARTNER. ...
   --                                      - expPrivateCustomer
   --                                      - expCommercialCustomer
   --                                      - expContactPerson
   --                                      - expWorkshop
   --                                      - expSupplier
   --                                      - expSalesman
   --                
   --                                      aufruf PCK_CONTRACT:
   --                                      - expServiceContract
   --                                      - expALL_CONTRACTS
   --                
   --                                      aufruf PCK_COST:
   --                                      - expWorkshopInvoice
   --                
   --                                      aufruf PCK_REVENUE:
   --                                      - expRevenue
   -- FraBe       18.11.2013  MKS-129687:1 statt aufruf PCK_EXPORTS. ...
   --                                      aufruf PCK_CONTRACT:
   --                                      - expALL_ODOMETER
   -- FraBe       04.12.2013  MKS-129743:1 add i_filename_cre/upd due to new wave1 pck_partner.expPrivateCustomer - upd logic
   -- ZBerger     04.12.2013  MKS-129347:1 add launching of EXP_DEALER
   -- FraBe       16.01.2014  MKS-130369:1 add i_filename_cre/upd due to new wave1 pck_partner.expCommercialCustomer - upd logic
   -- FraBe       04.03.2014  MKS-131048:1 neuer filename bei EXP_FIN
   -- FraBe       04.03.2014  MKS-131815:1 add EXP_CollectiveWorkshopInvoice
   -- FraBe       28.05.2014  MKS-130281:1 add EXP_AssignCostToCost
   -- FraBe       27.06.2014  MKS-133416:2 l�schen trailing blank aus AssignCostToCost filename
   -- ZBerger     30.10.2014  MKS-134522:1 add launching of EXP_MODPROTO
   -- FraBe       20.11.2014  MKS-135622/135623/135636/135637: add calling expCustomerContract / expVehicleContract
   --                                      plus neuen filenamen bei expServiceContract
   -- ZBerger     23.12.2014  MKS-135606:2 launcher: add launching of expVEGAMappingList
   -- Marinf      19.02.2015  MKS-136487:1 launcher: expVEGAMappingList: moved filenumbering to pck_exports.

      l_ret              NUMBER;
      l_filehandle       UTL_FILE.file_type;
      l_filename         VARCHAR2 ( 400 char );
      l_filename_cre     VARCHAR2 ( 400 char );
      l_filename_upd     VARCHAR2 ( 400 char );
      l_export_path      VARCHAR2 ( 100 char )   DEFAULT 'SIMEX_DIR';
      L_FILE_RUNNING_NO  integer                 default 0;

      function  chk_and_open_file
             (  o_filehandle  out   UTL_FILE.file_type
             ,  i_export_path  in   VARCHAR2
             ,  i_filename     in   VARCHAR2 )
                return number  is

                l_ret            integer := 0;
                l_fexist         BOOLEAN;
                l_file_length    NUMBER;
                l_block_size     NUMBER;

      begin

          -- folgender code wird nur bei csv ausgabe ben�tigt
          -- da wir nur xml haben, ist dieser code h�chstwahrscheinlich obsolete - kann eventuell gel�scht werden

          -- check if file exists -> overwrite

          UTL_FILE.fgetattr ( i_export_path
                            , i_filename
                            , l_fexist
                            , l_file_length
                            , l_block_size
                            );

          IF   l_fexist = TRUE
          THEN
               UTL_FILE.FREMOVE ( l_export_path, l_filename );
          END  IF;

          -- Open File
          o_filehandle := UTL_FILE.fopen ( l_export_path
                                         , l_filename
                                         , 'W'
                                         , 32740
                                         );
          return 0;   ---> success

      exception when others then SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                                          , i_LOG_ID     => '0006'     -- cre / open of file failed
                                          , i_LOG_TEXT   => SQLERRM );
                                 return -1;        ---> fail

      end;

   begin

      -- log export started
      SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
               , i_LOG_ID     => '0003'     -- Export started
               , i_LOG_TEXT   => i_TAS_CAPTION );

      SiMEXhistory ( i_TAS_GUID     => i_TAS_GUID
                   , i_TASH_STATE   => 1 );             -- 1 means: export is running

      l_ret      := 0;


      -- start export
      ---------------------------------------------------------------------------------------------------------------------------
      if   i_TAS_PROCEDURE = 'EXP_CUST'
      then l_filename := i_TAS_CAPTION  || '_' || to_char ( sysdate, 'YYYYMMDD_HH24MISS' ) || '_.xml';
           L_FILE_RUNNING_NO := 0;
           l_ret := pck_exports.expALL_CUSTOMERS ( i_TAS_GUID        => i_TAS_GUID
                                                 , i_export_path     => l_export_path
                                                 , i_filename        => l_filename
                                                 , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                 , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO
                                                 );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE    = 'EXP_CONTRACTS'
      then  l_filename := i_TAS_CAPTION  || '_' || to_char ( sysdate, 'YYYYMMDD_HH24MISS' ) || '.xml';
            L_FILE_RUNNING_NO := 0;
            l_ret := pck_contract.expALL_CONTRACTS ( i_TAS_GUID        => i_TAS_GUID
                                                   , i_export_path     => l_export_path
                                                   , i_filename        => l_filename
                                                   , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                   , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_ODOMETER'
      then  l_filename := '04-Odometer'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_contract.expALL_ODOMETER ( i_TAS_GUID        => i_TAS_GUID
                                                  , i_export_path     => l_export_path
                                                  , i_filename        => l_filename
                                                  , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                  , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_PRIVATECUSTOMER'
      then  l_filename_cre := '01-PhysicalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'PrivateCustomer'|| '-'
                             || '.xml';
            l_filename_upd := '01-PhysicalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'UPDATE_PrivateCustomer'|| '-'
                             || '.xml';
            l_ret := pck_partner.expPrivateCustomer ( i_TAS_GUID        => i_TAS_GUID
                                                    , i_export_path     => l_export_path
                                                    , i_filename_cre    => l_filename_cre
                                                    , i_filename_upd    => l_filename_upd
                                                    , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                    , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_COMMERCIALCUSTOMER'
      then  l_filename_cre := '02-OrganisationalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'CommercialCustomer'|| '-'
                             || '.xml';
            l_filename_upd := '02-OrganisationalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'UPDATE_CommercialCustomer'|| '-'
                             || '.xml';
            l_ret := pck_partner.expCommercialCustomer ( i_TAS_GUID        => i_TAS_GUID
                                                       , i_export_path     => l_export_path
                                                       , i_filename_cre    => l_filename_cre
                                                       , i_filename_upd    => l_filename_upd
                                                       , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                       , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_CONTACTPERSON'
      then  l_filename := '01-PhysicalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'ContactPerson'|| '-'
                             || '.xml';
            l_ret := pck_partner.expContactPerson ( i_TAS_GUID        => i_TAS_GUID
                                                  , i_export_path     => l_export_path
                                                  , i_filename        => l_filename
                                                  , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                  , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_WORKSHOP'
      then  l_filename := '02-OrganisationalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'Workshop'|| '-'
                             || '.xml';
            l_ret := pck_partner.expWorkshop ( i_TAS_GUID        => i_TAS_GUID
                                             , i_export_path     => l_export_path
                                             , i_filename        => l_filename
                                             , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                             , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_DEALER'
      then  l_filename := '02-OrganisationalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'Dealer'|| '-'
                             || '.xml';
            l_ret := pck_partner.expDealer ( i_TAS_GUID        => i_TAS_GUID
                                           , i_export_path     => l_export_path
                                           , i_filename        => l_filename
                                           , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                           , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_SUPPLIER'
      then  l_filename := '02-OrganisationalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'Supplier'|| '-'
                             || '.xml';
            l_ret := pck_partner.expSupplier ( i_TAS_GUID        => i_TAS_GUID
                                             , i_export_path     => l_export_path
                                             , i_filename        => l_filename
                                             , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                             , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_SALESMAN'
      then  l_filename := '01-PhysicalPerson'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'Salesman' || '-'
                             || '.xml';
            l_ret := pck_partner.expSalesman ( i_TAS_GUID        => i_TAS_GUID
                                             , i_export_path     => l_export_path
                                             , i_filename        => l_filename
                                             , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                             , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_SERVICE_CONTRACT'
      then  l_filename := '05-ServiceContract'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'FullServiceContract'
                      || '_' || '.xml';
            l_ret := pck_contract.expServiceContract ( i_TAS_GUID        => i_TAS_GUID
                                                     , i_export_path     => l_export_path
                                                     , i_filename        => l_filename
                                                     , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                     , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_CUSTOMER_CONTRACT'
      then  l_filename := '05-ServiceContract'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || 'CustomerContract'
                      || '_' || '.xml';
            l_ret := pck_contract.expCustomerContract ( i_TAS_GUID        => i_TAS_GUID
                                                      , i_export_path     => l_export_path
                                                      , i_filename        => l_filename
                                                      , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                      , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_VEHICLE_CONTRACT'
      then  l_filename := '06-VehicleContract'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_contract.expVehicleContract ( i_TAS_GUID        => i_TAS_GUID
                                                     , i_export_path     => l_export_path
                                                     , i_filename        => l_filename
                                                     , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                     , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_Revenue'
      then  l_filename := '08-Revenue'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_revenue.expRevenue ( i_TAS_GUID        => i_TAS_GUID
                                            , i_export_path     => l_export_path
                                            , i_filename        => l_filename
                                            , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                            , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_WorkshopInvoice'
      then  l_filename := '09-Cost'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_cost.expWorkshopInvoice ( i_TAS_GUID        => i_TAS_GUID
                                                 , i_export_path     => l_export_path
                                                 , i_export_type     => pck_calculation.c_exptype_Cost
                                                 , i_filename        => l_filename
                                                 , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                 , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_CollectiveWorkshopInvoice'
      then  l_filename := '10-CostCollective'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_cost.expCollectiveWorkshopInv ( i_TAS_GUID        => i_TAS_GUID
                                                       , i_export_path     => l_export_path
                                                       , i_filename        => l_filename
                                                       , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                       , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------                                                       
      elsif i_TAS_PROCEDURE = 'EXP_WorkshopInvoice_full'
      then  l_filename := '09-Cost_FullCost'
                      || '_' || to_char ( sysdate, 'YYYYMMDD"T"HH24MISS' ) 
                      || '_' || pck_calculation.G_TENANT_ID
                      || '_' || pck_calculation.G_USERID
                      || '_.xml';
            l_ret := pck_cost.expWorkshopInvoice ( i_TAS_GUID        => i_TAS_GUID
                                                 , i_export_path     => l_export_path
                                                 , i_export_type     => pck_calculation.c_exptype_CostFull                                                 
                                                 , i_filename        => l_filename
                                                 , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                 , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_AssignCostToCost'
      then  l_filename := '12-AssignCostToCost'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_cost.expAssignCostToCost ( i_TAS_GUID        => i_TAS_GUID
                                                  , i_export_path     => l_export_path
                                                  , i_filename        => l_filename
                                                  , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                                  , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      elsif i_TAS_PROCEDURE = 'EXP_MIG_SCOPE_CUSTOMER'
      then  l_filename := '00-MigrationScopeListCustomer'
                          ||'_'||to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'TENANTID', 'TENANTID' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'USERID',   'SIRIUS'   )
                          ||'_00001.csv';
            l_ret := chk_and_open_file ( o_filehandle     => l_filehandle
                                      , i_export_path    => l_export_path
                                      , i_filename       => l_filename );
            if   l_ret  = 0
            then l_ret := pck_exports.expMigScopeCustomer ( i_TAS_GUID        => i_TAS_GUID
                                                          , i_filehandle      => l_filehandle
                                                          , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO
                                                          , i_filename        => l_filename );
                 UTL_FILE.FCLOSE ( l_filehandle );
            end  if;
      ---------------------------------------------------------------------------------------------------------------------------
      -- FraBe 2013-01-14 MKS-121478 add expFIN
      elsif i_TAS_PROCEDURE = 'EXP_FIN'
      then  /*
            l_filename := i_TAS_CAPTION  || '_' || to_char ( sysdate, 'YYYYMMDD_HH24MISS' ) || '.csv';   -- MKS-131048:1 alter filename bis CR#10 excl.
            */
            l_filename := '00-FinList'
                          ||'_'||to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'TENANTID', 'TENANTID' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'USERID',   'SIRIUS'   )
                          ||'_00001.csv';
            l_ret := chk_and_open_file ( o_filehandle     => l_filehandle
                                       , i_export_path    => l_export_path
                                       , i_filename       => l_filename );
            if   l_ret  = 0
            then l_ret := pck_exports.expFIN ( i_TAS_GUID        => i_TAS_GUID
                                             , i_filehandle      => l_filehandle
                                             , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO
                                             , i_filename        => l_filename );
                 UTL_FILE.FCLOSE ( l_filehandle );
            end  if;
      ---------------------------------------------------------------------------------------------------------------------------
      -- FraBe 2013-03-18 MKS-121684 add expInventoryList
      elsif i_TAS_PROCEDURE = 'EXP_InventoryList'
      then  l_filename := '00-InventoryList'
                          ||'_'||to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'TENANTID', 'TENANTID' )
                          ||'_'||pck_calculation.get_setting ( 'SETTING', 'USERID',   'SIRIUS'   )
                          ||'_00001.csv';
            l_ret := chk_and_open_file ( o_filehandle     => l_filehandle
                                       , i_export_path    => l_export_path
                                       , i_filename       => l_filename );
            if   l_ret  = 0
            then l_ret := pck_exports.expInventoryList ( i_TAS_GUID        => i_TAS_GUID
                                                       , i_filehandle      => l_filehandle
                                                       , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO
                                                       , i_filename        => l_filename );
                 UTL_FILE.FCLOSE ( l_filehandle );
            end  if;
      ---------------------------------------------------------------------------------------------------------------------------
      -- MaZi  2014-10-30 MKS-134522:1 add expModProto
      -- FraBe 2014-10-31 MKS-134523:1 correct filename '13-ModificationProtocolEntry'
      elsif i_TAS_PROCEDURE = 'EXP_ModProto'
      then  l_filename := '13-ModificationProtocolEntry'
                      || '_' || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                      || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                      || '_' || '.xml';
            l_ret := pck_modproto.expModProto ( i_TAS_GUID        => i_TAS_GUID
                                              , i_export_path     => l_export_path
                                              , i_filename        => l_filename
                                              , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                              , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO );
      ---------------------------------------------------------------------------------------------------------------------------
      -- ZBerger  2014-12-23 MKS-135606:2 add expVEGAMappingList
      elsif i_TAS_PROCEDURE = 'EXP_VEGAMappingList'
      then  l_filename := '00-VegaMappingList_'
                          || to_char ( sysdate, 'YYYYMMDD' ) || 'T' || to_char ( sysdate, 'HH24MISS' )
                          || '_' || pck_calculation.get_setting ( 'SETTING', 'TENANTID',      'TENANTID' )
                          || '_' || pck_calculation.get_setting ( 'SETTING', 'USERID',        'SIRIUS'   )
                          || '_.csv';
        l_ret := pck_exports.expVEGAMappingList(i_TAS_GUID        => i_TAS_GUID
                                               , i_export_path    => l_export_path
                                               , i_filename        => l_filename 
                                               , i_TAS_MAX_NODES   => i_TAS_MAX_NODES
                                               , o_FILE_RUNNING_NO => L_FILE_RUNNING_NO);

      end if;
---  log end of export

     if   l_ret = 0
     then SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                   , i_LOG_ID     => '0004'    -- export finished success
                   , i_LOG_TEXT   => to_char ( L_FILE_RUNNING_NO ) || ' files were exported within ' || i_TAS_CAPTION || ' / max ' || i_TAS_MAX_NODES || ' nodes per file ' );

          SiMEXhistory ( i_TAS_GUID     => i_TAS_GUID
                       , i_TASH_STATE   => 2 );             -- 2 means: export finished success
     else SiMEXlog ( i_TAS_GUID   => i_TAS_GUID
                   , i_LOG_ID     => '0005'     -- export failed
                   , i_LOG_TEXT   => i_TAS_CAPTION );

          SiMEXhistory ( i_TAS_GUID     => i_TAS_GUID
                       , i_TASH_STATE   => 3 );             -- 3 means: export failed

     end  if;

     return l_ret;

   end;



end PCK_EXPORTER;
/