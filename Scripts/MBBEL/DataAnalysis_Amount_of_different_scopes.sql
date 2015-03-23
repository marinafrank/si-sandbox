/* Formatted on 23.04.2014 16:13:56 (QP5 v5.185.11230.41888) */
--Contracts in Scope

SELECT 'CountofContracts', COUNT ( v.id_vertrag )
  FROM snt.tfzgv_contracts fzgvc, snt.tdfcontr_variant cov, snt.tfzgvertrag v
 WHERE     fzgvc.id_cov = cov.id_cov
       AND v.id_vertrag = fzgvc.id_vertrag
       AND v.id_fzgvertrag = fzgvc.id_fzgvertrag
       AND fzgvc.id_seq_fzgvc = snt.get_max_co ( v.id_vertrag, v.id_fzgvertrag )
       AND cov.cov_caption NOT LIKE 'MIG_OOS%';

-- contract renumbering nrequired (LOP2215)

  SELECT fzg.id_vertrag,
         fzg.id_fzgvertrag,
         cs.id_cos,
         cs.cos_stat_code,
         CV.cov_caption,
         fzgv.id_customer,
         vadr.name_matchcode
    FROM tfzgv_contracts fzgv,
         tdfcontr_state cs,
         tfzgvertrag fzg,
         tdfcontr_variant CV,
         tcustomer cust,
         vadrassoz vadr
   WHERE     fzgv.id_cov = CV.id_cov
         AND fzg.id_cos = cs.id_cos
         AND fzgv.id_customer = cust.id_customer
         AND fzg.id_vertrag = fzgv.id_vertrag
         AND fzg.id_fzgvertrag = fzgv.id_fzgvertrag
         AND cust.id_seq_adrassoz = vadr.id_seq_adrassoz
         AND CV.cov_caption NOT LIKE 'MIG_OOS%'
         AND fzg.id_vertrag IN (  SELECT id_vertrag
                                    FROM (  SELECT v.id_vertrag, v.id_customer, COUNT ( id_fzgvertrag ) fzgvcount
                                              FROM tfzgv_contracts v, tdfcontr_variant CV
                                             WHERE     v.id_cov = CV.id_cov
                                                   AND CV.cov_caption NOT LIKE 'MIG_OOS%'
                                          GROUP BY id_vertrag, id_customer) list1
                                GROUP BY id_vertrag
                                  HAVING COUNT ( id_customer ) > 1)
ORDER BY 1, 3, 2;

-- Realgarant Contract Migration required (LOP2885)

SELECT v.id_vertrag, v.id_fzgvertrag,v.id_manufacture||v.fzgv_fgstnr "VIN", P.ICP_CAPTION, cos.cos_caption
  FROM tfzgvertrag v, tic_co_pack_ass pa, tic_package p, tdfcontr_state cos
 WHERE v.id_manufacture||v.fzgv_fgstnr IN (  SELECT id_manufacture||fzgv_fgstnr
                           FROM tfzgv_contracts fzgv, tdfcontr_variant cov, tfzgvertrag fzg
                          WHERE     fzgv.id_cov = CoV.id_cov
                                AND fzg.id_vertrag = fzgv.id_vertrag
                                AND fzg.id_fzgvertrag = fzgv.id_fzgvertrag
                                AND CoV.cov_caption NOT LIKE 'MIG_OOS%'
                       GROUP BY fzg. id_manufacture||fzgv_fgstnr
                         HAVING COUNT ( fzgv_fgstnr ) > 1)
      AND V.GUID_CONTRACT = pa.guid_contract
      and pa.guid_package = p.guid_package
      and p.icp_package_type=2
      and cos.id_cos = V.ID_COS
      
      order by 3,4