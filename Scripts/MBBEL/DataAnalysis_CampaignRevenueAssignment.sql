-- DataAnalysis_CampaignRevenueAssignment.sql
-- CHANGE 125721: LOP2259: iCON-Migration: Campaigns - Analysis
-- cpauzen 24.05.2013 MKS-125721:1 creation
-- FraBe   06.06.2013 MKS-125721:2 some small 'cosmetic' changes

spool DataAnalysis_CampaignRevenueAssignment.lst

set echo         off
set verify       off
set trimspool    on
set feedback     off
set lines        999
set pages        49999
set serveroutput on  size 1000000
set termout      on

prompt
prompt running. please wait ...
prompt

set termout   off


-- check data
set feedback  on
set feedback  1

col ID_VERTRAG         form a10
col ID_FZGVERTRAG      form a13
col CAMP_CAPTION       form a12
col CUR_CAPTION        form a11
col CI_DOCUMENT_NUMBER form a18

  SELECT   fzgv.id_vertrag,
           fzgv.id_fzgvertrag,
           cov.cov_caption,
           camp.camp_caption,
           camp.camp_departement,
           to_char ( concamp.concamp_amount_sirius, '99999G999G999G990D99' ) as concamp_amount_sirius,
           cur1.cur_caption,
           ci.ci_document_number,
           to_char ( ci.ci_date, 'DD.MM.YYYY' )            as ci_date,
           to_char ( ci.ci_amount, '9999G999G999G990D99' ) as ci_amount,
           cur2.cur_caption
    FROM   snt.tcontract_campaign concamp,
           snt.tcampaign camp,
           snt.tcustomer_invoice ci,
           snt.tfzgvertrag fzgv,
           snt.tfzgv_contracts fzgvc,
           snt.tcurrency cur1,
           snt.tcurrency cur2,
           snt.tdfcontr_variant cov
   WHERE       fzgv.guid_contract = concamp.guid_contract
           AND fzgv.id_vertrag = fzgvc.id_vertrag
           AND fzgv.id_fzgvertrag = fzgvc.id_fzgvertrag
           AND fzgvc.id_seq_fzgvc = snt.get_max_co (fzgvc.id_vertrag, fzgvc.id_fzgvertrag)
           AND fzgvc.id_cov = cov.id_cov
           AND cur1.id_currency = concamp.id_currency
           AND cur2.id_currency(+) = ci.id_currency
           AND concamp.guid_campaign = camp.guid_campaign
           AND ci.guid_ci(+) = concamp.guid_ci
   ORDER BY   fzgv.id_vertrag, fzgv.id_fzgvertrag, camp.camp_caption
  
/

set termout  on

prompt
prompt
prompt finished.

prompt
prompt please contact the SIRIUS support team in Ulm if any ORA- or SP2- error is listed in the logfile DataAnalysis_CampaignRevenueAssignment.lst
prompt

exit;