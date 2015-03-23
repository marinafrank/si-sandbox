--  20121213_analyzePamentIntervalsSPPContracts_v1.0.sql

-- FraBe 13.12.2012 MKS-121053: creation

spool 20121213_analyzePamentIntervalsSPPContracts_v1.lst

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


-- check data
set feedback  on
set feedback  1

prompt
prompt connect to MBOE.S415MT216.tst:
conn snt/Tss2007$@MBOE.S415MT216.tst

select fzgvc.ID_VERTRAG
     , fzgvc.ID_FZGVERTRAG
     , spp.SPC_EXTERNAL_ID
     , spp.SPC_INTERNAL_ID
     , decode ( spp.SPC_VARIANT, 0, 'SI', 1, 'MF', 2, 'RP' ) as SPC_VARIANT
     , vadr.ID_PARTNER
     , vadr.NAME_MATCHCODE
  from snt.VPARTNER             vadr
     , snt.TSP_CONTRACT         spp
     , snt.TDFCONTR_VARIANT     cov
     , snt.TFZGV_CONTRACTS      fzgvc     
 where spp.GUID_PARTNER         = vadr.GUID_PARTNER
   and spp.ID_VERTRAG           = fzgvc.ID_VERTRAG
   and spp.ID_FZGVERTRAG        = fzgvc.ID_FZGVERTRAG
   and cov.ID_COV               = fzgvc.ID_COV
   and cov.COV_CAPTION   not like 'MIG_OOS%'
order by 5, 1, 2, 3, 4, 6
/

prompt connect to MBBEL.S415MT216.tst:
conn snt/Tss2007$@MBBEL.S415MT216.tst
/

prompt connect to MBCH.S415MT216.tst:
conn snt/Tss2007$@MBCH.S415MT216.tst
/

prompt connect to MBCZ.S415VM122.tst:
conn snt/Tss2007$@MBCZ.S415VM122.tst
/

prompt connect to MBE.S415B017.tst:
conn snt/Tss2007$@MBE.S415B017.tst
/

prompt connect to MBF.S415B017.tst:
conn snt/Tss2007$@MBF.S415B017.tst
/

prompt connect to MBI.S415MT216.tst:
conn snt/Tss2007$@MBI.S415MT216.tst
/

prompt connect to MBNL.S415B017.tst:
conn snt/Tss2007$@MBNL.S415B017.tst
/

prompt connect to MBP.S415B017.tst:
conn snt/Tss2007$@MBP.S415B017.tst
/

prompt connect to MBPL.S415VM122.tst:
conn snt/Tss2007$@MBPL.S415VM122.tst
/

prompt connect to MBSA.S415MT216.tst:
conn snt/Tss2007$@MBSA.S415MT216.tst
/

prompt connect to MBR.S415VM185.tst:
conn snt/Tss2007$@MBR.S415VM185.tst
/

prompt connect to MBCL.S415VM445.tst:
conn snt/Tss2007$@MBCL.S415VM445.tst
/

set termout  on

prompt
prompt
prompt finished.

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile 20121213_analyzePamentIntervalsSPPContracts_v1.lst
prompt

exit;