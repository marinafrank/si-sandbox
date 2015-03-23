CREATE OR REPLACE PACKAGE BODY SSI.ssi_healthcheck_addon IS
 lgc_modul CONSTANT VARCHAR2 ( 100 ) DEFAULT 'SSI_HEALTHCHECK_ADDON.';


 FUNCTION process ( i_id_vertrag    IN VARCHAR2
                  , i_id_fzgvertrag IN VARCHAR2
                  , i_id_object     IN tssi_journal.id_object%TYPE
                  , i_checkoption   in varchar2 default 'ALL' )
  RETURN db_datatype.db_returnstatus%TYPE IS

--  PURPOSE
--
--  PARAMETERS
--     In-Parameter
--       i_id_vertrag, i_id_fzgvertrag : Searches for this Filename in the Inbox.
--                          It's also possible to search only parts of a filename
--                          example: Sender or Objectname
--                          If empty all files are searched.
--       i_id_object : Is this a initial load?
--     Return bei Funktionen
--       db_const.db_success : The message is stored in the table tssi_journal
--       db_const.db_fail     : There was a error in this function.
--  EXCEPTIONS
--     In der Funktion/Prozedur erzeugte Exceptions ggf. mit Beschreibung der
--     jeweils durchgeführten Plausibilitätsprüfungen
--     Auswirkungen auf den Bildschirm
--     durchgeführten Protokollierung
--  ENDPURPOSE

-- FraBe 10.01.2014  MKS-130325:1 add IN parameter i_scope_only default 'NO' logic
-- FraBe 21.01.2014  MKS-130325:1 rename i_scope_only to i_checkoption with default 'ALL'

  lc_sub_modul     VARCHAR2 ( 100 ) DEFAULT 'PROCESS';
  l_ret        db_datatype.db_boolean%TYPE;
  i_id_seq_fzgrechnung   snt.tfzgrechnung.id_seq_fzgrechnung%TYPE;
  lsuccess       NUMBER;

  CURSOR invoices IS
     SELECT r.id_seq_fzgrechnung
      , r.fzgre_resumme
      , r.fzgre_awsumme
      , r.fzgre_matnetto
      , r.fzgre_matbrutto
      , r.fzgre_sc_provision
      , r.fzgre_sc_buyup
      , r.fzgre_sum_other
      , r.fzgre_sum_rejected
      , r.fzgre_control_state
      , r.fzgre_belegnr
      , r.id_vertrag
      , r.id_fzgvertrag
     FROM snt.tfzgrechnung r
    WHERE r.id_vertrag = i_id_vertrag
      AND r.id_fzgvertrag = i_id_fzgvertrag
      and (  nvl ( i_checkoption, 'ALL' )  <> 'SCOPE'
        or (       i_checkoption            = 'SCOPE'  and r.ID_IMP_TYPE not in ( 6, 10 ) ))  -- MKS-130325:1 do not take care about VEGA INV/CN
   ORDER BY r.id_seq_fzgrechnung;

  CURSOR custinv IS
     SELECT ci.guid_ci
      , ci.id_seq_fzgvc
      , ci.ci_date
      , ci.ci_amount
      , ct.custinvtype_short_caption
      , ci.ci_document_number
      , ci.id_belegart
      , c.id_vertrag
      , c.id_fzgvertrag
      , c.fzgvc_ende
      , c.fzgvc_beginn
     FROM snt.tcustomer_invoice ci, snt.tfzgv_contracts c, snt.tcustomer_invoice_typ ct
    WHERE ci.id_seq_fzgvc = c.id_seq_fzgvc
      AND ci.guid_custinvtype = ct.guid_custinvtype
      AND c.id_vertrag = i_id_vertrag
      AND c.id_fzgvertrag = i_id_fzgvertrag
      AND ct.custinvtype_short_caption = 'MP'
   ORDER BY ci.guid_ci ASC;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check invoices *****' );
  l_ret := db_const.db_success;

  FOR cinv IN invoices LOOP

   IF check_rejection_positions ( i_id_seq_fzgrechnung => cinv.id_seq_fzgrechnung, i_id_object => i_id_object ) <> 0 THEN
    lsuccess := lsuccess - 1;
   END IF;

   IF check_rejpos_less_listprice ( i_id_seq_fzgrechnung => cinv.id_seq_fzgrechnung, i_id_object => i_id_object ) <> 0 THEN
    lsuccess := lsuccess - 1;
   END IF;

   IF check_possum_equal_header (
             i_id_seq_fzgrechnung => cinv.id_seq_fzgrechnung
              , i_fzgre_resumme => cinv.fzgre_resumme
              , i_fzgre_awsumme => cinv.fzgre_awsumme
              , i_fzgre_matnetto => cinv.fzgre_matnetto
              , i_fzgre_sum_other => cinv.fzgre_sum_other
              , i_fzgre_sum_rejected => cinv.fzgre_sum_rejected
              , i_fzgre_control_state => cinv.fzgre_control_state
              , i_id_object => i_id_object
             ) <> 0 THEN
    lsuccess := lsuccess - 1;
   END IF;

   -- FraBe   18.10.2012 MKS-118317 add inexact 0 values check
   -- FraBe   18.12.2012 MKS-121230 auf neue logik umschreiben
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_RESUMME
                                   , i_check_column           => 'FZGRE_RESUMME'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_SUM_REJECTED
                                   , i_check_column           => 'FZGRE_SUM_REJECTED'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_MATBRUTTO
                                   , i_check_column           => 'FZGRE_MATBRUTTO'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_MATNETTO
                                   , i_check_column           => 'FZGRE_MATNETTO'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_AWSUMME
                                   , i_check_column           => 'FZGRE_AWSUMME'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_SUM_OTHER
                                   , i_check_column           => 'FZGRE_SUM_OTHER'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_SC_PROVISION
                                   , i_check_column           => 'FZGRE_SC_PROVISION'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;
 
   if check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung     => cinv.id_seq_fzgrechnung
                                   , i_check_VALUE            => cinv.FZGRE_SC_BUYUP
                                   , i_check_column           => 'FZGRE_SC_BUYUP'
                                   , i_id_object              => i_id_object     ) <> 0 
   then lsuccess := lsuccess - 1;
   end  if;


  END LOOP;

  IF check_import_protocol ( i_id_vertrag => i_id_vertrag, i_id_fzgvertrag => i_id_fzgvertrag, i_id_object => i_id_object ) <> 0 THEN
   lsuccess := lsuccess - 1;
  END IF;

  IF check_run_performance ( i_id_vertrag => i_id_vertrag, i_id_fzgvertrag => i_id_fzgvertrag, i_id_object => i_id_object ) <> 0 THEN
   lsuccess := lsuccess - 1;
  END IF;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check customer invoices *****' );

  FOR cinv IN custinv LOOP
   IF check_custinv_vs_price (
             i_guid_ci => cinv.guid_ci
             , i_id_seq_fzgvc => cinv.id_seq_fzgvc
             , i_ci_amount => cinv.ci_amount
             , i_custinvtype_short_caption => cinv.custinvtype_short_caption
             , i_ci_document_number => cinv.ci_document_number
             , i_id_vertrag => i_id_vertrag
             , i_id_fzgvertrag => i_id_fzgvertrag
             , i_fzgvc_beginn => cinv.fzgvc_beginn
             , i_fzgvc_ende => cinv.fzgvc_ende
             , i_id_object => i_id_object
            ) <> 0 THEN
    lsuccess := lsuccess - 1;

    IF check_custinv_total (
             i_guid_ci => cinv.guid_ci
             , i_ci_amount => cinv.ci_amount
             , i_ci_document_number => cinv.ci_document_number
             , i_id_vertrag => i_id_vertrag
             , i_id_fzgvertrag => i_id_fzgvertrag
             , i_id_object => i_id_object
            ) <> 0 THEN
     lsuccess := lsuccess - 1;
    END IF;
   END IF;
  END LOOP;

  /*
  -- MaZi   12.11.2012 MKS-118420 add check_foreign_currency
  -- FraBe  18.12.2012 MKS-118316 / 121230: check_foreign_currency wird nicht mehr hier durchgeführt, sondern in einem eigenen check sql script 
  IF check_foreign_currency ( i_id_object => i_id_object ) <> 0 THEN
        lsuccess := lsuccess - 1;
  END IF;
  */

  -- FraBe   18.10.2012 MKS-118317 add inexact 0 values check
  -- FraBe   18.12.2012 MKS-121230 auf neue logik umschreiben  
  if check_inexact_0_cinv_values ( i_id_vertrag     => i_id_vertrag
                                 , i_id_fzgvertrag  => i_id_fzgvertrag
                                 , i_id_object      => i_id_object )  <> 0 
  then lsuccess := lsuccess - 1;
  end  if;

  -- FraBe   18.10.2012 MKS-118419 add check_zurueckgefahrene_KM
  IF check_zurueckgefahrene_KM ( i_id_vertrag     => i_id_vertrag
                               , i_id_fzgvertrag  => i_id_fzgvertrag
                               , i_id_object      => i_id_object     ) <> 0 THEN
        lsuccess := lsuccess - 1;
  END IF;

  -- MaZi    24.10.2012 MKS-118315 add inexact 0 values
  IF check_future_ended_contracts ( i_id_vertrag     => i_id_vertrag
                                  , i_id_fzgvertrag  => i_id_fzgvertrag
                                  , i_id_object      => i_id_object     ) <> 0 THEN
        lsuccess := lsuccess - 1;
  END IF;
  
  IF check_invalid_FIN ( i_id_vertrag     => i_id_vertrag
                       , i_id_fzgvertrag  => i_id_fzgvertrag
                       , i_id_object      => i_id_object     ) <> 0 THEN
        lsuccess := lsuccess - 1;
  END IF;
    
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
  
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END process;

 FUNCTION check_rejection_positions ( i_id_seq_fzgrechnung snt.tfzgrechnung.id_seq_fzgrechnung%TYPE, i_id_object IN tssi_journal.id_object%TYPE )
  RETURN NUMBER
       IS
        -- this function checks if the rejected sum is correct calculated out of the three rejection fields
  l_ret    NUMBER;
  lc_sub_modul VARCHAR2 ( 100 ) DEFAULT 'CHECK_REJPOS_LESS_LISTPRICE';

  CURSOR invcur IS
   SELECT id_seq_fzgrechnung
      , tp.ip_reject_sum
      , tp.ip_listprice
      , tp.ip_amount
      , tp.ip_posindex
      , tp.ip_reject_amount
      , tp.ip_reject_quantity
     FROM snt.tinv_position tp
    WHERE ( tp.ip_reject_sum <
        ( ( ROUND ( tp.ip_reject_amount * tp.ip_amount, 2 ) ) + ( ROUND ( tp.ip_reject_quantity * tp.ip_listprice, 2 ) ) - 0.01)
       OR tp.ip_reject_sum >
         ( ( ROUND ( tp.ip_reject_amount * tp.ip_amount, 2 ) ) + ( ROUND ( tp.ip_reject_quantity * tp.ip_listprice, 2 ) ) + 0.01) )
      AND id_seq_fzgrechnung = i_id_seq_fzgrechnung;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  FOR rcur IN invcur LOOP
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60101'
          , i_table_name => 'TINV_POSITION'
          , i_column_name => 'IP_REJECT_SUM'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Rejection position sum of position '
               || rcur.ip_posindex
               || ' ('
               || rcur.ip_reject_sum
               || ') '
               || 'is larger than sum of all rejections [amount rejection + quantity rejection] ('
               || ROUND ( rcur.ip_reject_amount * rcur.ip_amount, 2 )
               || ' + '
               || ROUND ( rcur.ip_reject_quantity * rcur.ip_listprice, 2 )
               || ')'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END LOOP;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_rejection_positions;

 FUNCTION check_rejpos_less_listprice ( i_id_seq_fzgrechnung snt.tfzgrechnung.id_seq_fzgrechnung%TYPE, i_id_object IN tssi_journal.id_object%TYPE )
  RETURN NUMBER
       IS
        -- this function checks if the rejected position value is greater than the position list price
  l_ret    NUMBER;
  lc_sub_modul VARCHAR2 ( 32 ) DEFAULT 'CHECK_REJPOS_LESS_LISTPRICE';

  CURSOR invcur IS
   SELECT id_seq_fzgrechnung
      , tp.ip_reject_sum
      , tp.ip_listprice
      , tp.ip_posindex
     FROM snt.tinv_position tp
    WHERE tp.ip_reject_sum > tp.ip_listprice + 0.01
      AND id_seq_fzgrechnung = i_id_seq_fzgrechnung;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  FOR rcur IN invcur LOOP
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60102'
          , i_table_name => 'TINV_POSITION'
          , i_column_name => 'IP_REJECT_SUM'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Rejection position sum of position '
               || rcur.ip_posindex
               || ' ('
               || rcur.ip_reject_sum
               || ') '
               || 'is larger than than positions listprice ('
               || rcur.ip_listprice
               || ')'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  -- || Replace(Trim(TO_CHAR (Round(rcur.ip_reject_sum - rcur.ip_listprice,2),'9999990.00')),'.',','));
  END LOOP;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );

   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_rejpos_less_listprice;

 FUNCTION check_possum_equal_header (
              i_id_seq_fzgrechnung snt.tfzgrechnung.id_seq_fzgrechnung%TYPE
              , i_fzgre_resumme snt.tfzgrechnung.fzgre_resumme%TYPE
              , i_fzgre_awsumme snt.tfzgrechnung.fzgre_awsumme%TYPE
              , i_fzgre_matnetto snt.tfzgrechnung.fzgre_matnetto%TYPE
              , i_fzgre_sum_other snt.tfzgrechnung.fzgre_sum_other%TYPE
              , i_fzgre_sum_rejected snt.tfzgrechnung.fzgre_sum_rejected%TYPE
              , i_fzgre_control_state snt.tfzgrechnung.fzgre_control_state%TYPE
              , i_id_object IN tssi_journal.id_object%TYPE
             )
  RETURN NUMBER IS
        --this function checks if the sum of the
        --single card types are equal to the stored sums in the header and if the overall position sum is equal to the header sum
  l_ret      NUMBER;
  lc_sub_modul   VARCHAR2 ( 32 ) DEFAULT 'CHECK_POSSUM_EQUAL_HEADER';
  l_sumlistprice   snt.tinv_position.ip_listprice%TYPE;
  l_sumrejected   snt.tinv_position.ip_reject_sum%TYPE;
  l_rowcount    NUMBER;

  CURSOR reject_cur IS
   SELECT ip_reject_sum
      , ip_control_state
      , ip_listprice
      , ip_posindex
     FROM snt.tinv_position
    WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  --
  -- check for header vs positions
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check Header vs. positions *****' );

  SELECT nvl ( SUM ( ip_listprice ), 0 ), COUNT ( ROWID )
    INTO l_sumlistprice, l_rowcount
    FROM snt.tinv_position
   WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung;

  IF ( l_sumlistprice > i_fzgre_resumme + ( l_rowcount * .01 )
    OR l_sumlistprice < i_fzgre_resumme - ( l_rowcount * .01 ) ) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60103'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_RESUMME'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Difference in amount between header ('
               || i_fzgre_resumme
               || ') and sum of all positions ('
               || l_sumlistprice
               || ') ['
               || l_rowcount
               || ' positions ==> tolerance: +-'
               || TO_CHAR ( l_rowcount * .01, '0.00' )
               || ']'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  -- || REPLACE ( TRIM ( TO_CHAR ( i_fzgre_resumme - l_sumlistprice, '9999990.00' ) ), '.', ',' )
  END IF;

  -- --
  -- -- check for cardtype 11 (Work)
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check Cardtype 11 *****' );

  SELECT nvl ( SUM ( ip_listprice ), 0 ), COUNT ( ROWID )
    INTO l_sumlistprice, l_rowcount
    FROM snt.tinv_position
   WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung
     AND ip_cardtype = 11;

  IF ( l_sumlistprice > i_fzgre_awsumme + ( l_rowcount * .01 )
    OR l_sumlistprice < i_fzgre_awsumme - ( l_rowcount * .01 ) ) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60104'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_AWSUMME'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Difference in amount for work between header ('
               || i_fzgre_awsumme
               || ') and sum of all positions ('
               || l_sumlistprice
               || ') ['
               || l_rowcount
               || ' positions ==> tolerance: +-'
               || TO_CHAR ( l_rowcount * .01, '0.00' )
               || ']'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END IF;

  -- --
  -- -- check for cardtype 12 (Parts)
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check Cardtype 12 *****' );

  SELECT nvl ( SUM ( ip_listprice ), 0 ), COUNT ( ROWID )
    INTO l_sumlistprice, l_rowcount
    FROM snt.tinv_position
   WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung
     AND ip_cardtype = 12;

  IF ( l_sumlistprice > i_fzgre_matnetto + ( l_rowcount * .01 )
    OR l_sumlistprice < i_fzgre_matnetto - ( l_rowcount * .01 ) ) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60105'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_MATNETTO'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Difference in amount for parts between header ('
               || i_fzgre_matnetto
               || ') and sum of all positions ('
               || l_sumlistprice
               || ') ['
               || l_rowcount
               || ' positions ==> tolerance: +-'
               || TO_CHAR ( l_rowcount * .01, '0.00' )
               || ']'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END IF;

  --
  -- check for cardtype 13 (Others)
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check Cardtype 13 *****' );

  SELECT nvl ( SUM ( ip_listprice ), 0 ), COUNT ( ROWID )
    INTO l_sumlistprice, l_rowcount
    FROM snt.tinv_position
   WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung
     AND ip_cardtype = 13;

  IF ( l_sumlistprice > i_fzgre_sum_other + ( l_rowcount * .01 )
    OR l_sumlistprice < i_fzgre_sum_other - ( l_rowcount * .01 ) ) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60106'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_SUM_OTHER'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Difference in amount for others between header ('
               || i_fzgre_sum_other
               || ') and sum of all positions ('
               || l_sumlistprice
               || ') ['
               || l_rowcount
               || ' positions ==> tolerance: +-'
               || TO_CHAR ( l_rowcount * .01, '0.00' )
               || ']'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END IF;

  --
  -- check for rejections header/pos
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check for rejections header vs. positions *****' );

  SELECT SUM ( ip_reject_sum ), COUNT ( ROWID )
    INTO l_sumrejected, l_rowcount
    FROM snt.tinv_position
   WHERE id_seq_fzgrechnung = i_id_seq_fzgrechnung;

  IF ( l_sumrejected > i_fzgre_sum_rejected + l_rowcount * .01
    OR l_sumrejected < i_fzgre_sum_rejected - l_rowcount * .01 ) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60107'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_SUM_REJETED'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Difference in Rejection between header ('
               || i_fzgre_sum_rejected
               || ') and sum of all positions ('
               || l_sumrejected
               || ') ['
               || l_rowcount
               || ' positions ==> tolerance: +-'
               || TO_CHAR ( l_rowcount * .01, '0.00' )
               || ']'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  -- || REPLACE ( TRIM ( TO_CHAR ( i_fzgre_sum_rejected - l_sumrejected, '9999990.00' ) ), '.', ',' )
  END IF;

  -- check for rejections (pos = 0 AND Controlstate =2 OR 3)
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check for rejections (rejectsum = 0  AND controlstate = 2 OR 3) *****' );

  IF l_sumrejected = 0
   AND i_fzgre_control_state IN (2, 3) THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60108'
          , i_table_name => 'TFZGRECHNUNG'
          , i_column_name => 'FZGRE_CONTROL_STATE'
          , i_message_class => 'W'
          , i_msg_value => i_id_seq_fzgrechnung
          , i_msg_text =>  'Invoice was (partially) rejected (Control state: '
               || i_fzgre_control_state
               || ') but no position was rejected.'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END IF;

  qerrm.
  trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check for positions (rejectsum < or > listprice  AND controlstate = 3) *****' );

  FOR ccur IN reject_cur LOOP
   IF ccur.ip_control_state = 3
    AND ( ccur.ip_reject_sum < ccur.ip_listprice - 0.01
       OR ccur.ip_reject_sum > ccur.ip_listprice + 0.01 ) THEN
    l_ret := -1;
    l_ret := ssi_log.
       store_msg (
           i_id_object => i_id_object
           , i_msg_code => '60109'
           , i_table_name => 'TINV_POSITION'
           , i_column_name => 'IP_REJECT_SUM'
           , i_message_class => 'W'
           , i_msg_value => i_id_seq_fzgrechnung
           , i_msg_text =>  'Rejection position '
                || ccur.ip_posindex
                || ' was full rejected (Control state: '
                || ccur.ip_control_state
                || ') but rejection sum ('
                || ccur.ip_reject_sum
                || ') is not equal listprice ('
                || ccur.ip_listprice
                || ').'
           , i_msg_modul => lgc_modul || lc_sub_modul );
   --  || REPLACE ( TRIM ( TO_CHAR ( ccur.ip_reject_sum - ccur.ip_listprice, '9999990.00' ) ), '.', ',' )
   END IF;

   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check for positions (rejectsum = 0 AND controlstate = 2) *****' );

   IF ccur.ip_control_state = 2
    AND ccur.ip_reject_sum = 0 THEN
    l_ret := -1;
    l_ret := ssi_log.
       store_msg (
           i_id_object => i_id_object
           , i_msg_code => '60110'
           , i_table_name => 'TINV_POSITION'
           , i_column_name => 'IP_REJECT_SUM'
           , i_message_class => 'W'
           , i_msg_value => i_id_seq_fzgrechnung
           , i_msg_text =>  'Rejection position '
                || ccur.ip_posindex
                || ' was partially rejected (Control state: '
                || ccur.ip_control_state
                || ') but rejection sum is zero.'
           , i_msg_modul => lgc_modul || lc_sub_modul );
   END IF;
  END LOOP;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_possum_equal_header;

 FUNCTION check_import_protocol ( i_id_vertrag IN VARCHAR2, i_id_fzgvertrag IN VARCHAR2, i_id_object IN tssi_journal.id_object%TYPE )
  RETURN NUMBER
       IS
        -- this function checks if the invoice from the contract is in the importprotocol
  l_ret    NUMBER;
  lc_sub_modul VARCHAR2 ( 100 ) DEFAULT 'CHECK_IMPORT_PROTOCOL';
  l_rowcount  NUMBER;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  SELECT COUNT ( * )
    INTO l_rowcount
    FROM snt.tiiinv_xml_header ip
   WHERE ip.iiixh_vehcontract = i_id_fzgvertrag
     AND ip.iiixh_contract = i_id_vertrag
     AND ip.iiixh_done IS NULL; -- MKS-126588:1

  IF l_rowcount <> 0
   OR l_rowcount <> NULL THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60111'
          , i_table_name => 'TIIINV_XML_HEADER'
          , i_column_name => 'IIIXH_CONTRACT'
          , i_message_class => 'W'
          , i_msg_value => i_id_vertrag || '-' || i_id_fzgvertrag
          , i_msg_text =>  'There are '
               || l_rowcount
               || ' invoice(s) from contract  '
               || i_id_vertrag
               || '-'
               || i_id_fzgvertrag
               || ' existent in the import protocol (mask 06.07).'
          , i_msg_modul => lgc_modul || lc_sub_modul );
  END IF;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_import_protocol;

 FUNCTION check_run_performance ( i_id_vertrag IN VARCHAR2, i_id_fzgvertrag IN VARCHAR2, i_id_object IN tssi_journal.id_object%TYPE )
  RETURN NUMBER
       IS
        --this function checks if the delivered mileages from an invoice are ascending
  l_ret        NUMBER;
  lc_sub_modul     VARCHAR2 ( 100 ) DEFAULT 'CHECK_RUN_PERFORMANCE';
  i_id_seq_fzgrechnung   snt.tfzgrechnung.id_seq_fzgrechnung%TYPE;
  i_fzgre_laufstrecke   snt.tfzgrechnung.fzgre_laufstrecke%TYPE;
  i         NUMBER DEFAULT 1;

  CURSOR inv_mlg IS
     SELECT r.id_seq_fzgrechnung, r.fzgre_repdatum, r.fzgre_laufstrecke
     FROM snt.tfzgrechnung r
    WHERE r.id_vertrag = i_id_vertrag
      AND r.id_fzgvertrag = i_id_fzgvertrag                       --id_seq_fzgrechnung = 4784
   ORDER BY r.fzgre_repdatum, r.id_seq_fzgrechnung;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  FOR cur_inv_mlg IN inv_mlg LOOP
   IF cur_inv_mlg.fzgre_laufstrecke < i_fzgre_laufstrecke
    AND i > 1 THEN
    l_ret := -1;
    l_ret := ssi_log.store_msg (
               i_id_object => i_id_object
             , i_msg_code => '60112'
             , i_table_name => 'TFZGRECHNUNG'
             , i_column_name => 'FZGRE_LAUFSTRECKE'
             , i_message_class => 'W'
             , i_msg_value => cur_inv_mlg.id_seq_fzgrechnung
             , i_msg_text => 'The mileage in invoice '
                                                                    || cur_inv_mlg.id_seq_fzgrechnung
                                                                    || ' is not ascending.'
             , i_msg_modul => lgc_modul || lc_sub_modul
              );
   END IF;

   i_id_seq_fzgrechnung := cur_inv_mlg.id_seq_fzgrechnung;
   i_fzgre_laufstrecke := cur_inv_mlg.fzgre_laufstrecke;
   i := i + 1;
  END LOOP;

  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_run_performance;

 FUNCTION check_custinv_vs_price (
             i_guid_ci IN snt.tcustomer_invoice.guid_ci%TYPE
             , i_id_seq_fzgvc IN snt.tcustomer_invoice.id_seq_fzgvc%TYPE
             , i_ci_amount IN snt.tcustomer_invoice.ci_amount%TYPE
             , i_custinvtype_short_caption IN snt.tcustomer_invoice_typ.custinvtype_short_caption%TYPE
             , i_ci_document_number snt.tcustomer_invoice.ci_document_number%TYPE
             , i_id_vertrag IN VARCHAR2
             , i_id_fzgvertrag IN VARCHAR2
             , i_fzgvc_beginn IN snt.tfzgv_contracts.fzgvc_beginn%TYPE
             , i_fzgvc_ende IN snt.tfzgv_contracts.fzgvc_ende%TYPE
             , i_id_object IN tssi_journal.id_object%TYPE
            )
  RETURN NUMBER IS
        --this function checks if the amount from the monthly customer invoice is equal to the stored monthly fee

  l_ret     NUMBER;
  lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_CUSTINV_VS_PRICE';
  l_monthly_fee  snt.tfzgpreis.fzgpr_preis_monatp%TYPE;
  l_dailyprice  NUMBER DEFAULT 0;
  icosts_ende   NUMBER DEFAULT 0;
  icosts_begin  NUMBER DEFAULT 0;
  l_paymethod   NUMBER;

  CURSOR cinv_pos_cur IS
   SELECT *
     FROM snt.tcustomer_invoice_pos cp
    WHERE cp.guid_ci = i_guid_ci;
 BEGIN
  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
  l_ret := 0;

  SELECT p.paym_targetdate_ci
    INTO l_paymethod
    FROM snt.tfzgv_contracts c, snt.tdfpaymode p
   WHERE c.id_paym = p.id_paym
     AND c.id_seq_fzgvc = i_id_seq_fzgvc;

  FOR cinv_pos IN cinv_pos_cur LOOP
   SELECT p.fzgpr_preis_monatp, p.fzgpr_preis_monatp / 30
     INTO l_monthly_fee, l_dailyprice
     FROM snt.tfzgpreis p
    WHERE p.id_seq_fzgvc = i_id_seq_fzgvc
      AND cinv_pos.cip_date >= p.fzgpr_von
      AND cinv_pos.cip_date <= p.fzgpr_bis;

   IF l_paymethod = 1 THEN
    icosts_begin := ROUND ( TO_CHAR ( LAST_DAY ( i_fzgvc_beginn ) - TO_CHAR ( i_fzgvc_beginn, 'DD' ), 'DD' ) * l_dailyprice, 2 );
    icosts_ende := ROUND ( TO_CHAR ( i_fzgvc_ende, 'DD' ) * l_dailyprice, 2 );

    IF l_monthly_fee <> cinv_pos.cip_amount
     AND icosts_ende <> cinv_pos.cip_amount
     AND icosts_begin <> cinv_pos.cip_amount THEN
     l_ret := -1;
     l_ret := ssi_log.
        store_msg (
            i_id_object => i_id_object
            , i_msg_code => '60201'
            , i_table_name => 'TCUSTOMER_INVOICE_POS'
            , i_column_name => 'CIP_AMOUNT'
            , i_message_class => 'W'
            , i_msg_value => i_ci_document_number
            , i_msg_text =>  'The stored monthly price '
                 || l_monthly_fee
                 || ' or (daily price (first/last month) * days left: '
                 || icosts_begin
                 || '/'
                 || icosts_ende
                 || ') do not fit with the monthly invoice with position date '
                 || cinv_pos.cip_date
                 || ' and amount '
                 || cinv_pos.cip_amount
                 || '.'
            , i_msg_modul => lgc_modul || lc_sub_modul );
    END IF;
   ELSE
    IF l_monthly_fee <> cinv_pos.cip_amount THEN
     l_ret := -1;
     l_ret := ssi_log.
        store_msg (
            i_id_object => i_id_object
            , i_msg_code => '60201'
            , i_table_name => 'TCUSTOMER_INVOICE_POS'
            , i_column_name => 'CIP_AMOUNT'
            , i_message_class => 'W'
            , i_msg_value => i_ci_document_number
            , i_msg_text =>  'The stored monthly price '
                 || l_monthly_fee
                 || ') do not fit with the monthly invoice with position date '
                 || cinv_pos.cip_date
                 || ' and amount '
                 || cinv_pos.cip_amount
                 || '.'
            , i_msg_modul => lgc_modul || lc_sub_modul );
    END IF;
   END IF;
  END LOOP;


  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_custinv_vs_price;

 FUNCTION check_custinv_total (
            i_guid_ci IN snt.tcustomer_invoice.guid_ci%TYPE
            , i_ci_amount IN snt.tcustomer_invoice.ci_amount%TYPE
            , i_ci_document_number snt.tcustomer_invoice.ci_document_number%TYPE
            , i_id_vertrag IN VARCHAR2
            , i_id_fzgvertrag IN VARCHAR2
            , i_id_object IN tssi_journal.id_object%TYPE
           )
  RETURN NUMBER IS
        --function checks if the sum of the positions are equal to the header

  l_ret    NUMBER;
  lc_sub_modul VARCHAR2 ( 100 ) DEFAULT 'CHECK_CUSTINV_TOTAL';
  l_sum    NUMBER DEFAULT 0;
 BEGIN
  SELECT SUM ( ip.cip_amount )
    INTO l_sum
    FROM snt.tcustomer_invoice_pos ip
   WHERE ip.guid_ci = i_guid_ci;


  qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function *****' );
  RETURN l_ret;

  IF i_ci_amount <> l_sum THEN
   l_ret := -1;
   l_ret := ssi_log.
      store_msg (
          i_id_object => i_id_object
          , i_msg_code => '60202'
          , i_table_name => 'TCUSTOMER_INVOICE'
          , i_column_name => 'CI_AMOUNT'
          , i_message_class => 'W'
          , i_msg_value => i_ci_document_number
          , i_msg_text => 'Difference in amount between header ('
                                                    || i_ci_amount
                                                    || ') and sum of all positions ('
                                                    || l_sum
                                                    || ')'
          , i_msg_modul => lgc_modul || lc_sub_modul
           );
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
   qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
   RETURN -1;
 END check_custinv_total;
  
 /*
 -- FraBe  18.12.2012 MKS-118316 / 121230: check_foreign_currency wird nicht mehr hier durchgeführt, sondern in einem eigenen check sql script 
 FUNCTION check_foreign_currency (i_id_object IN tssi_journal.id_object%TYPE)
  RETURN NUMBER IS
    -- function checks if there are occurencies of foreign-currencies

    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_FOREIGN_CURRENCY';
    l_sum         NUMBER DEFAULT 0;
    l_id_currency NUMBER;
    l_guid_currency snt.tcurrency.guid_currency%TYPE;
    
    CURSOR chk_foreign_currency_cur (i_id_currency NUMBER, i_guid_currency VARCHAR2) IS 
    SELECT cnt_id_curr, table_name
    FROM (SELECT COUNT (id_currency) cnt_id_curr, 'TSP_CONTRACT' table_name
            FROM snt.tsp_contract
           WHERE id_currency <> i_id_currency 
          UNION
          SELECT COUNT (id_currency), 'TSP_COLLECTIVE_INVOICE'
            FROM snt.tsp_collective_invoice
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (guid_currency), 'TITEM_HIST_PRICE'
            FROM snt.titem_hist_price
           WHERE guid_currency <> i_guid_currency
          UNION
          SELECT COUNT (guid_currency), 'TITEM'
            FROM snt.titem
           WHERE guid_currency <> i_guid_currency
          UNION
          SELECT COUNT (id_currency), 'TGARAGE'
            FROM snt.tgarage
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TFZGRECHNUNG'
            FROM snt.tfzgrechnung
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCUSTOMER_INVOICE'
            FROM snt.tcustomer_invoice
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCUSTOMER'
            FROM snt.tcustomer
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCO_SUBSTITUTE'
            FROM snt.tco_substitute
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCOS_PRICING'
            FROM snt.tcos_pricing
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCONTRACT_SUBSIDIZING'
            FROM snt.tcontract_subsidizing
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCONTRACT_CAMPAIGN'
            FROM snt.tcontract_campaign
           WHERE id_currency <> i_id_currency
          UNION
          SELECT COUNT (id_currency), 'TCAMPAIGN'
            FROM snt.tcampaign
           WHERE id_currency <> i_id_currency)
   WHERE cnt_id_curr <> 0;
    
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check foreign currency *****' );

    BEGIN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** get id_currency of country''s default-currency *****' );
      -- get id_currency of country's default-currency
      SELECT id_currency, guid_currency
        INTO l_id_currency, l_guid_currency
        FROM snt.tcurrency cur
       WHERE cur.cur_code = (SELECT gs.value
                               FROM snt.tglobal_settings gs
                              WHERE UPPER(gs.application_id) = 'SIRIUS'
                                AND UPPER(gs.section)        = 'SETTING'
                                AND UPPER(gs.entry)          = 'LOCALE_SCURRENCY');
    EXCEPTION
      WHEN no_data_found THEN
        qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
        qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION NO DATA FOUND' );
        RETURN -1;
    END;

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** start of loop *****' );
    FOR chk_foreign_currency IN chk_foreign_currency_cur (l_id_currency, l_guid_currency) LOOP
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** in loop *****' );
      l_ret := -1;
      l_ret := ssi_log.
            store_msg (
                     i_id_object => i_id_object
                   , i_msg_code => '60203'
                   , i_table_name => chk_foreign_currency.table_name
                   , i_column_name => 'ID_CURRENCY'
                   , i_message_class => 'W'
                   , i_msg_value => chk_foreign_currency.cnt_id_curr
                   , i_msg_text => 'There are ' || chk_foreign_currency.cnt_id_curr
                                                || ' rows with foreign currency(ies) in table '
                                                || chk_foreign_currency.table_name
                   , i_msg_modul => lgc_modul || lc_sub_modul
                    );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', 'l_ret: ' || l_ret || '. There are ' || chk_foreign_currency.cnt_id_curr || ' rows with foreign currency(ies) in table ' || chk_foreign_currency.table_name);
    END LOOP;
    RETURN l_ret;
    
 EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
 END check_foreign_currency;
 */
  
 FUNCTION check_zurueckgefahrene_KM ( i_id_vertrag    IN VARCHAR2
                                    , i_id_fzgvertrag IN VARCHAR2
                                    , i_id_object     IN tssi_journal.id_object%TYPE)
  RETURN NUMBER IS
    -- function checks if there are newer mileages which are less than older ones
    -- change history
    -- FraBe   18.10.2012 MKS-118419 creation

    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_ZURUECKGEFAHRENE_KM';
    l_sum         NUMBER DEFAULT 0;
        
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check zurueckgefahrene KM *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** get count of mileages which are less than older ones *****' );
    select count(*)
      into l_sum
      from ( select distinct km.ID_VERTRAG, km.ID_FZGVERTRAG
               from snt.TFZGKMSTAND km
              where km.FZGKM_KM > 1
                and km.ID_VERTRAG    = i_ID_VERTRAG
                and km.ID_FZGVERTRAG = i_ID_FZGVERTRAG
                and exists
                        ( select km1.FZGKM_KM
                            from snt.TFZGKMSTAND km1
                           where km.ID_VERTRAG    = km1.ID_VERTRAG
                             and km.ID_FZGVERTRAG = km1.ID_FZGVERTRAG
                             and km.FZGKM_DATUM   < km1.FZGKM_DATUM
                             and km.FZGKM_KM      > km1.FZGKM_KM ));

    -- FraBe 2013-01-15 MKS-118419:2: add if (-> log only if there are newer milages less than older ones )
    if   l_sum > 0
    then 
         qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** log result *****' );
         l_ret := -1;
         l_ret := ssi_log.store_msg (
                          i_id_object => i_id_object
                        , i_msg_code => '60204'
                        , i_table_name => 'TFZGKMSTAND'
                        , i_column_name => 'FZGKM_KM'
                        , i_message_class => 'W'
                        , i_msg_value => i_id_vertrag || '-' || i_id_fzgvertrag
                        , i_msg_text => 'There are ' || l_sum || ' rows with mileages in table snt.TFZGKMSTAND which are less than older ones'
                        , i_msg_modul => lgc_modul || lc_sub_modul
                         );
         qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', 'l_ret: ' || l_ret || '. There are ' || l_sum || ' rows with mileages in table snt.TFZGKMSTAND which are less than older ones' );
    end  if;

    RETURN l_ret;
    
  EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
  END check_zurueckgefahrene_KM;

 FUNCTION check_inexact_0_fzgre_values ( i_id_seq_fzgrechnung IN number
                                       , i_check_VALUE        IN number
                                       , i_check_column       IN VARCHAR2
                                       , i_id_object          IN tssi_journal.id_object%TYPE )
  RETURN NUMBER IS
    -- function checks if there are inexact 0 values: values which are less than -0,000000 or greater than +0,000000
    -- change history
    -- FraBe   18.10.2012 MKS-118317 creation
    -- FraBe   18-12-2012 MKS-121230:1 umschreiben auf neue logik

    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_INEXACT_0_FZGRE_VALUES';
        
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check inexact 0 values ' || i_check_column || ' *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** get count of inexact 0 values *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** TFZGRECHNUNG.' || i_check_column || ' *****' );
      
    -- FraBe MKS-118317:2 correct wrong code
    -- if   abs ( i_check_VALUE ) < 0.0000001        and abs ( i_check_VALUE ) > 0.00000001
    if      abs ( i_check_VALUE ) < 0.00000000000001 and abs ( i_check_VALUE ) > 0.000000000000001
        and length ( to_char ( abs ( i_check_VALUE ))) = 30                                        -- FraBe MKS-118317:3 add missing and
    then qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** log result *****' );
         l_ret := -1;
         l_ret := ssi_log.store_msg (
                          i_id_object => i_id_object
                        , i_msg_code => '60205'
                        , i_table_name => 'TFZGRECHNUNG'
                        , i_column_name => i_check_column
                        , i_message_class => 'W'
                        , i_msg_value => i_id_seq_fzgrechnung
                        , i_msg_text => 'The workshop invoice with SIRIUS-ID ' || i_id_seq_fzgrechnung || ' has an inexact 0 value in column ' || i_check_column || ' of table snt.TFZGRECHNUNG'
                        , i_msg_modul => lgc_modul || lc_sub_modul
                         );
         qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', 'l_ret: ' || l_ret || '. The workshop invoice with SIRIUS-ID ' || i_id_seq_fzgrechnung || ' has an inexact 0 value in column ' || i_check_column || ' of table snt.TFZGRECHNUNG' );

    end if;
    
  -- FraBe MKS-118317:2 add missing return
  RETURN l_ret;

  EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
  END check_inexact_0_fzgre_values;
      
 FUNCTION check_inexact_0_cinv_values ( i_ID_VERTRAG         in varchar2
                                      , i_ID_FZGVERTRAG      in varchar2
                                      , i_id_object          IN tssi_journal.id_object%TYPE )
  RETURN NUMBER IS
    -- function checks if there are inexact 0 values: values which are less than -0,000000 or greater than +0,000000
    -- change history
    -- FraBe   18.10.2012 MKS-118317 creation
    -- FraBe   18-12-2012 MKS-121230:1 umschreiben auf neue logik

    l_sum         number;
    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_INEXACT_0_CINV_VALUES';
        
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check inexact  0 TCUSTOMER_INVOICE.CI_AMOUNT values *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** get count of inexact 0 values *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** TCUSTOMER_INVOICE.CI_AMOUNT *****' );
      
    select count(*)
      into l_sum
      from snt.TCUSTOMER_INVOICE ci
         , snt.TFZGV_CONTRACTS   fzgvc
     where fzgvc.ID_VERTRAG    = i_ID_VERTRAG
       and fzgvc.ID_FZGVERTRAG = i_ID_FZGVERTRAG
       and fzgvc.ID_SEQ_FZGVC  = ci.ID_SEQ_FZGVC           -- FraBe MKS-118317:2 correct wrong code: 
       and abs ( ci.CI_AMOUNT ) < 0.00000000000001         -- < 0.0000001
       and abs ( ci.CI_AMOUNT ) > 0.000000000000001        -- > 0.00000001
       and length ( to_char ( abs ( ci.CI_AMOUNT ))) = 30; -- FraBe MKS-118317:3 add missing and

    if   l_sum > 0
    then qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** log result *****' );
         l_ret := -1;
         l_ret := ssi_log.store_msg (
                          i_id_object => i_id_object
                        , i_msg_code => '60205'
                        , i_table_name => 'TCUSTOMER_INVOICE'
                        , i_column_name => 'CI_AMOUNT'
                        , i_message_class => 'W'
                        , i_msg_value => i_ID_VERTRAG  || '|' || i_ID_FZGVERTRAG
                        , i_msg_text => 'There are ' || l_sum || ' rows with inexact 0 values in column CI_AMOUNT of table snt.TCUSTOMER_INVOICE'
                        , i_msg_modul => lgc_modul || lc_sub_modul
                         );
         qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', 'l_ret: ' || l_ret || '. There are ' || l_sum || ' rows with inexact 0 values in column CI_AMOUNT of table snt.TCUSTOMER_INVOICE' );
    
    end if;
    
    RETURN l_ret;
      
  EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
  END check_inexact_0_cinv_values;

 FUNCTION check_future_ended_contracts ( i_id_vertrag    IN VARCHAR2
                                       , i_id_fzgvertrag IN VARCHAR2
                                       , i_id_object     IN tssi_journal.id_object%TYPE)
  RETURN NUMBER IS
    -- function checks if there are contracts that will be ended in the future
    -- change history
    -- MaZi   23.10.2012 MKS-118315 creation

    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_FUTURE_ENDED_CONTRACTS';
    l_sum         NUMBER DEFAULT 0;
    
    CURSOR chk_future_ended_cur IS 
    SELECT km.id_vertrag, km.id_fzgvertrag, km.fzgkm_datum
      FROM tfzgkmstand km
     WHERE km.ID_VERTRAG    = i_ID_VERTRAG
       and km.ID_FZGVERTRAG = i_ID_FZGVERTRAG
       and km.fzgkm_datum > SYSDATE
       and EXISTS
                 ( SELECT NULL
                     FROM snt.tfzgv_contracts
                    WHERE id_seq_fzgkmstand_end = km.id_seq_fzgkmstand );
 
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check zukünftig beendete Verträge *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** list contracts that are already ended in the future *****' );
    FOR chk_future_ended IN chk_future_ended_cur LOOP
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** in loop *****' );
      --cntContracts := cntContracts + 1;
      l_ret := -1;
      l_ret := ssi_log.
            store_msg (
                     i_id_object => i_id_object
                   , i_msg_code => '60207'
                   , i_table_name => 'TFZGVERTRAG'
                   , i_column_name => 'FZGKM_DATUM'
                   , i_message_class => 'W'
                   , i_msg_value => chk_future_ended.fzgkm_datum
                   , i_msg_text => 'Contract ' || chk_future_ended.id_vertrag || '|' || chk_future_ended.id_fzgvertrag
                                               || ' ends in the future ' || chk_future_ended.fzgkm_datum
                   , i_msg_modul => lgc_modul || lc_sub_modul
                    );
    END LOOP;
    RETURN l_ret;
    
  EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
  END check_future_ended_contracts;

 FUNCTION check_invalid_FIN ( i_id_vertrag    IN VARCHAR2
                            , i_id_fzgvertrag IN VARCHAR2
                            , i_id_object     IN tssi_journal.id_object%TYPE )
  RETURN NUMBER IS
    -- function checks if there are FINs <> 14 digits
    -- change history
    -- MaZi   09.11.2012 MKS-118420 creation
    -- MaZi   13.03.2013 MKS-121925 list FINs including at least one *-digit too

    l_ret         NUMBER;
    lc_sub_modul  VARCHAR2 ( 100 ) DEFAULT 'CHECK_INVALID_FIN';
    l_sum         NUMBER DEFAULT 0;
    
    CURSOR chk_fin_length_cur IS 
    SELECT id_vertrag, id_fzgvertrag, fzgv_fgstnr
      FROM tfzgvertrag
     WHERE ID_VERTRAG    = i_ID_VERTRAG
       and ID_FZGVERTRAG = i_ID_FZGVERTRAG
       and length ( fzgv_fgstnr ) <> 14;

    CURSOR chk_fin_star_digit_cur IS 
    SELECT id_vertrag, id_fzgvertrag, fzgv_fgstnr
      FROM tfzgvertrag
     WHERE ID_VERTRAG    = i_ID_VERTRAG
       and ID_FZGVERTRAG = i_ID_FZGVERTRAG
       and instr ( fzgv_fgstnr, '*' ) > 0;
 
  BEGIN

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check FIN length *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** list contracts that have a FIN <> 14 digits *****' );
    FOR chk_fin_length IN chk_fin_length_cur LOOP
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** in loop *****' );
      --cntContracts := cntContracts + 1;
      l_ret := -1;
      l_ret := ssi_log.
            store_msg (
                     i_id_object => i_id_object
                   , i_msg_code => '60206'
                   , i_table_name => 'TFZGVERTRAG'
                   , i_column_name => 'FZGV_FGSTNR'
                   , i_message_class => 'W'
                   , i_msg_value => chk_fin_length.fzgv_fgstnr
                   , i_msg_text => 'Contract''s ' || chk_fin_length.id_vertrag || '|' || chk_fin_length.id_fzgvertrag
                                               || ' FIN has a length <> 14 digits'
                   , i_msg_modul => lgc_modul || lc_sub_modul
                    );
    END LOOP;

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Start of Function *****' );
    qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** Check FIN for * digit *****' );

    qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** list contracts that have a FIN including at least one * digit *****' );
    FOR chk_fin_star_digit IN chk_fin_star_digit_cur LOOP
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - LOG', '***** in loop *****' );
      --cntContracts := cntContracts + 1;
      l_ret := -1;
      l_ret := ssi_log.
            store_msg (
                     i_id_object => i_id_object
                   , i_msg_code => '60208'
                   , i_table_name => 'TFZGVERTRAG'
                   , i_column_name => 'FZGV_FGSTNR'
                   , i_message_class => 'W'
                   , i_msg_value => chk_fin_star_digit.fzgv_fgstnr
                   , i_msg_text => 'Contract''s ' || chk_fin_star_digit.id_vertrag || '|' || chk_fin_star_digit.id_fzgvertrag
                                               || ' FIN includes at least one * digit'
                   , i_msg_modul => lgc_modul || lc_sub_modul
                    );
    END LOOP;
    RETURN l_ret;
    
  EXCEPTION
    WHEN OTHERS THEN
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - ERROR', SQLERRM );
      qerrm.trace ( lgc_modul || lc_sub_modul || ' - WALKTHROUGH', '***** End of Function ***** - EXCEPTION GLOBAL OTHERS' );
      RETURN -1;
  END check_invalid_FIN;
      
END ssi_healthcheck_addon;
/