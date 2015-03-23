--LOP 2545

-- TK 2013-06-05; V1.0 ;MKS-126221:1
-- Einfache Selects OHNE SPOOL!

-- Werkstattrechnungen
-- Innenabfrage: Anzahl Werkstattrechnungspositionen, die eine VAT-Rate benutzen
-- Aussenabfrage: Welche VAT Rates werden in Welchem Zeitraum benutzt.

  SELECT Salestax, MIN (Jahr), MAX (Jahr)
    FROM (  SELECT TO_CHAR ( fzgre_belegdatum, 'YYYY') Jahr, ip_salestax Salestax, COUNT (ip_salestax) "number of Positions"
              FROM tfzgrechnung r, tinv_position rp, tfzgv_contracts c, tdfcontr_variant cov
             WHERE     r.id_seq_fzgrechnung = rp.id_seq_fzgrechnung
                   AND r.id_seq_fzgvc = c.id_seq_fzgvc
                   AND c.id_cov = cov.id_cov
                   AND COV.COV_CAPTION NOT LIKE 'MIG_OOS%'
          GROUP BY TO_CHAR ( fzgre_belegdatum, 'YYYY'), ip_salestax
          ORDER BY 1, 2) innen
GROUP BY Salestax
ORDER BY 1;

-- Kundenrechnungen
-- Innenabfrage: Anzahl Kundenechnungspositionen, die eine VAT-Rate benutzen
-- Aussenabfrage: Welche VAT Rates werden in Welchem Zeitraum benutzt.

  SELECT VATRATE, MIN (YEAR), MAX (YEAR)
    FROM (  SELECT TO_CHAR ( R.CI_DATE, 'YYYY') YEAR, RP.CIP_VAT_RATE VATRATE, COUNT (CIP_VAT_RATE) "count of Positions"
              FROM tcustomer_invoice r, tcustomer_invoice_pos rp, tfzgv_contracts c, tdfcontr_variant cov
             WHERE     r.guid_ci = RP.GUID_CI
                   AND r.id_seq_fzgvc = c.id_seq_fzgvc
                   AND c.id_cov = cov.id_cov
                   AND COV.COV_CAPTION NOT LIKE 'MIG_OOS%'
          GROUP BY TO_CHAR ( CI_DATE, 'YYYY'), CIP_VAT_RATE
          ORDER BY 1, 2) innen
GROUP BY VATRATE
ORDER BY 1;