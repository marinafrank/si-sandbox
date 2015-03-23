-- 20130424_Analysis_monthly_invoicing_v1.1.sql
-- CHANGE  MKS-123737: LOP 2590 - EDF - CIM Vertrag - RD - Analysis monthly invoicing  
-- cpauzen 24.04.2013 MKS-123737:1 creation
-- cpauzen 24.04.2013 MKS-123737:2 auch one shot mitnehmen

spool 20130424_Analysis_monthly_invoicing_v1.1.lst

set echo         off
set verify       off
set trimspool    on
set feedback     off
set lines        999
set pages        9999
set serveroutput on  size 1000000
set termout      on

prompt
prompt running. please wait ...
prompt

set termout   off


-- Prompt
-- prompt connect to MBBEL.S415MT216.tst:
-- conn snt/Tss2007$@MBBEL.S415MT216.tst


SELECT RPAD ( snt.GET_TGLOBAL_SETTINGS ( 'Sirius', 'Setting', 'SalesOrganisation'), 10) AS Land
  , fzgv.id_vertrag, fzgv.id_fzgvertrag, dfcos.cos_stat_code 
  , paym.paym_months AS Zahlungsintervall_in_Monaten, cov.cov_caption
    FROM snt.tfzgvertrag fzgv, snt.tfzgv_contracts fzgvc, snt.tdfcontr_state dfcos, snt.tdfpaymode paym, snt.tdfcontr_variant cov
   WHERE     fzgv.id_cos = dfcos.id_cos
         AND fzgv.id_vertrag = fzgvc.id_vertrag
         AND fzgv.id_fzgvertrag = fzgvc.id_fzgvertrag
         AND paym.id_paym = fzgvc.id_paym
         AND fzgvc.id_cov = cov.id_cov
         AND dfcos.cos_stat_code IN ('01', '02')
         AND paym.paym_months NOT IN (0, 1)
         AND fzgvc.id_seq_fzgkmstand_end IS NULL
         AND cov.cov_caption NOT LIKE 'MIG_O%'
ORDER BY paym.paym_months, fzgv.id_vertrag, fzgv.id_fzgvertrag

-- /
-- prompt
-- prompt connect to MBOE.S415MT216.tst:
-- conn snt/Tss2007$@MBOE.S415MT216.tst


-- /
-- Prompt
-- prompt connect to MBCH.S415MT216.tst:
-- conn snt/Tss2007$@MBCH.S415MT216.tst

-- /
-- Prompt
-- prompt connect to MBCZ.S415VM122.tst:
-- conn snt/Tss2007$@MBCZ.S415VM122.tst
/

-- Prompt
-- prompt connect to MBE.S415B017.tst:
-- conn snt/Tss2007$@MBE.S415B017.tst

-- /
-- Prompt
-- prompt connect to MBF.S415B017.tst:
-- conn snt/Tss2007$@MBF.S415B017.tst

-- /
-- Prompt
-- prompt connect to MBI.S415MT216.tst:
-- conn snt/Tss2007$@MBI.S415MT216.tst

-- /
-- Prompt
-- prompt connect to MBNL.S415B017.tst:
-- conn snt/Tss2007$@MBNL.S415B017.tst

-- /
-- Prompt
-- prompt connect to MBP.S415B017.tst:
-- conn snt/Tss2007$@MBP.S415B017.tst

-- /
-- Prompt
-- prompt connect to MBPL.S415VM122.tst:
-- conn snt/Tss2007$@MBPL.S415VM122.tst

-- /
-- Prompt
-- prompt connect to MBSA.S415MT216.tst:
-- conn snt/Tss2007$@MBSA.S415MT216.tst

-- /
-- Prompt
-- prompt connect to MBR.S415VM185.tst:
-- conn snt/Tss2007$@MBR.S415VM185.tst

-- /
-- Prompt
-- prompt connect to MBCL.S415VM445.tst:
-- conn snt/Tss2007$@MBCL.S415VM445.tst

-- /
set termout  on

prompt
prompt
prompt finished.

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile 20130424_Analysis_monthly_invoicing_v1.1.lst
prompt

exit;