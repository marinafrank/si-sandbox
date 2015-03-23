-- MKSSTART
--
-- $CompanyInfo $
--
-- $Date: 2015/03/20 15:59:17MEZ $
--
-- $Name:  $
--
-- $Revision: 1.1 $
--
-- $Header: 5100_Code_Base/Database/Source/TRG_TTASK_INITENV.sql 1.1 2015/03/20 15:59:17MEZ Frank, Marina (marinf) CI_Changed  $
--
-- $Source: 5100_Code_Base/Database/Source/TRG_TTASK_INITENV.sql $
--
-- $Log: 5100_Code_Base/Database/Source/TRG_TTASK_INITENV.sql  $
-- Revision 1.1 2015/03/20 15:59:17MEZ Frank, Marina (marinf) 
-- Initial revision
-- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
CREATE OR REPLACE TRIGGER trg_ttask_initenv
  FOR INSERT OR UPDATE OF tas_active OR DELETE ON ttask
  ENABLE COMPOUND TRIGGER
  v_active_before      NUMBER(10);
  v_active_after      NUMBER(10);
BEFORE STATEMENT IS
BEGIN
  
  SELECT COUNT(1)
    INTO v_active_before
    FROM TTASK
   WHERE TAS_ACTIVE = 1;
   
END BEFORE STATEMENT;

AFTER STATEMENT IS 
BEGIN
  SELECT COUNT(1)
    INTO v_active_after
    FROM TTASK
   WHERE TAS_ACTIVE = 1;
   
   IF v_active_before = 0 AND v_active_after <> 0 THEN
     -- Event recognized: Extraction initiated
     IF pck_calculation.get_setting('SETTING',  'GLOBALDATETIME', '0') = '0' THEN
       -- no initial GLOBALDATETIME provided from MASTERDATA
       -- or restarting the whole export
       pck_calculation.set_setting('SETTING',  'GLOBALDATETIME', to_char ( sysdate, pck_calculation.c_xmlDTfmt ));
     END IF;
   ELSIF v_active_before <> 0 AND v_active_after = 0 THEN
     -- Last task is finished, resetting GLOBALDATETIME
     pck_calculation.set_setting('SETTING',  'GLOBALDATETIME', '0');
   ELSE
     /* The rest cases:
        before <> 0 ; after <> 0 - 1. New tasks staged to run in addition to already staged - GLOBALDATETIME already set by this trigger,
                                   unless it had been enabled only before this additional update
                                   2. Task finished, further active tasks exist.
        before = 0 ; after = 0   - DML changes not related to initiating tasks to run
      */
     NULL;  
   END IF;
   
END AFTER STATEMENT;
  
END;
/
