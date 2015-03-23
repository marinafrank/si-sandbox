CREATE OR REPLACE PACKAGE BODY SIMEX.PCK_CALCULATION
IS
   --
   --
   -- MKSSTART
   --
   -- $CompanyInfo $
   --
   -- $Date: 2015/03/20 16:04:48MEZ $
   --
   -- $Name:  $
   --
   -- $Revision: 1.31 $
   --
   -- $Header: 5100_Code_Base/Database/Source/PCK_CALCULATION.plb 1.31 2015/03/20 16:04:48MEZ Frank, Marina (marinf) CI_Changed  $
   --
   -- $Source: 5100_Code_Base/Database/Source/PCK_CALCULATION.plb $
   --
   -- $Log: 5100_Code_Base/Database/Source/PCK_CALCULATION.plb  $
   -- Revision 1.31 2015/03/20 16:04:48MEZ Frank, Marina (marinf) 
   -- MKS-151824:1 API for changing global settings.
   -- Revision 1.30 2015/03/19 12:38:49MEZ Frank, Marina (marinf) 
   -- MKS-152173:1 DEF8564 Salesmen logins converted to uppercase. Fixed to return default value if empty or non-word value in brackets found.
   -- Revision 1.29 2015/03/06 16:07:09MEZ Frank, Marina (marinf) 
   -- MKS-136133 Added common Cost-related constants:types of export.
   -- Revision 1.28 2015/02/18 17:23:38MEZ Frank, Marina (marinf) 
   -- MKS-136397:1 Implemented contract_number_migrate, contract_number_sirius
   -- Revision 1.27 2014/10/10 09:17:00MESZ Berger, Franz (fraberg) 
   -- get_PART_OF_BEARBEITER_KAUF: some small changes betreffend I_PART und I_VALUE abfrage / details siehe direkt bei function
   -- Revision 1.26 2014/10/07 10:56:03MESZ Berger, Franz (fraberg) 
   -- get_PART_OF_BEARBEITER_KAUF: implement new wavePreInt4 logic
   -- Revision 1.25 2014/10/06 11:19:33MESZ Kieninger, Tobias (tkienin) 
   -- Hotfix Iter10
   -- Revision 1.24 2014/09/25 17:16:32MESZ Kieninger, Tobias (tkienin) 
   -- DefaultSalesmen included
   -- Revision 1.23 2014/09/17 14:24:27MESZ Kieninger, Tobias (tkienin) 
   -- Selecting Workshop or Supplier
   -- Revision 1.22 2014/09/16 12:42:00MESZ Kieninger, Tobias (tkienin) 
   -- merge Branch
   -- Revision 1.21 2014/07/31 21:36:36MESZ Berger, Franz (fraberg) 
   -- ausbessern 'kaufmännisches und' auf 'AND' im kommentar (-> das kaufmännische und ist ja das zeichen für substitute )
   -- Revision 1.20 2014/07/17 17:38:21MESZ Berger, Franz (fraberg) 
   -- getCustomerAsDealer: fix bug: SUB_SRS_ATT_VALUE und SUB_ICO_ATT_VALUE müssen vertauscht werden!
   -- Revision 1.19 2014/07/09 13:38:30MESZ Berger, Franz (fraberg) 
   -- add function getCustomerAsDealer
   -- Revision 1.18 2014/06/28 14:59:22MESZ Berger, Franz (fraberg) 
   -- get_PART_OF_BEARBEITER_KAUF: implement new waviFinal logic
   -- Revision 1.17 2014/06/25 10:04:44MESZ Berger, Franz (fraberg) 
   -- do_substitute: return null within 'WorkshopAsCustomer' - NO_DATA_FOUND without selecting any default substitution value
   -- Revision 1.16 2014/06/18 13:32:54MESZ Kieninger, Tobias (tkienin) 
   -- .
   -- Revision 1.15 2014/06/04 13:41:35MESZ Berger, Franz (fraberg) 
   -- remove get_last_lic as obsolete / no longer needed
   -- Revision 1.14 2014/04/28 15:26:31MESZ Kieninger, Tobias (tkienin) 
   -- .
   -- Revision 1.13 2014/04/04 09:50:19MESZ Berger, Franz (fraberg) 
   -- remove_alpha: use regexp_replace instead of translate
   -- Revision 1.12 2014/03/31 11:03:03MESZ Berger, Franz (fraberg) 
   -- do_substitute: add TOO_MANY_ROWS exception
   -- Revision 1.11 2013/12/05 11:01:55MEZ Berger, Franz (fraberg) 
   -- get_PART_OF_BEARBEITER_KAUF: due to length problems return 'SM_' || ... instead of  'Salesman_'
   -- Revision 1.10 2013/12/02 16:31:41MEZ Berger, Franz (fraberg) 
   -- remove_alpha: do not remove '+' anymore
   -- Revision 1.9 2013/11/13 15:17:47MEZ Zimmerberger, Markus (zimmerb) 
   -- Minor changes
   -- Revision 1.8 2013/11/13 14:36:55MEZ Zimmerberger, Markus (zimmerb) 
   -- add get_REVENUE_AMOUNT
   -- Revision 1.7 2013/07/25 15:06:11MESZ Kieninger, Tobias (tkienin) 
   -- Always fill in most actual License Plate in LISTOFFIN
   -- Revision 1.6 2013/06/24 17:48:10MESZ Berger, Franz (fraberg)
   -- add function get_DB_NAME_of_DB_LINK
   -- Revision 1.5 2013/04/03 14:18:32MESZ Zimmerberger, Markus (zimmerb)
   -- Add get_part_of_bearbeiter_kauf
   -- Revision 1.4 2012/12/18 15:10:29MEZ Berger, Franz (fraberg)
   -- add '_' to remove_alpha
   -- Revision 1.3 2012/12/05 14:45:13MEZ Berger, Franz (fraberg)
   -- add function get_setting
   -- Revision 1.1 2012/10/09 16:25:24MESZ Berger, Franz (fraberg)
   -- Initial revision
   -- Member added to project /Archiv/mks/develop/ICON/5000_Construction/Product.pj
   --
   -- MKSEND

   --
   -- Purpose: package für alle SiMEX berechnungs- und ersetzungs- prozeduren / funktionen
   --
   -- MODIFICATION HISTORY
   -- Person      Date        Comments
   -- ---------   ----------  ------------------------------------------
   -- FraBe       01.10.2012  MKS-117502:1 creation
   -- MaZi        13.11.2013  MKS-123543:1 add get_REVENUE_AMOUNT
   -- FraBe       30.11.2013  MKS-129430:1 remove_alpha: do not remove '+' anymore
   -- FraBe       05.12.2013  MKS-129442:1 get_PART_OF_BEARBEITER_KAUF: due to length problems return 'SM_' || ... instead of  'Salesman_' 
   -- FraBe       27.03.2014  MKS-131260:1 do_substitute: add TOO_MANY_ROWS exception
   -- FraBe       04.04.2014  MKS-132131:1 remove_alpha: use regexp_replace instead of translate
   -- TK          23.04.2104  MKS-132429:1 correct Get_part_bearbeiter_kauf according Salesman-Export.
   -- FraBe       04.06.2014  MKS-132838:1 remove get_last_lic as obsolete / no longer needed
   -- FraBe       23.06.2014  MKS-132103:1 / do_substitute: return null within 'WorkshopAsCustomer' - NO_DATA_FOUND without selecting any default substitution value
   -- FraBe       25.06.2014  MKS-132116:1 get_PART_OF_BEARBEITER_KAUF: implement new waviFinal logic
   -- FraBe       04.07.2014  MKS-132047:1 add function getCustomerAsDealer
   -- FraBe       17.07.2014  MKS-132047:2 / getCustomerAsDealer: fix bug: SUB_SRS_ATT_VALUE und SUB_ICO_ATT_VALUE müssen vertauscht werden!
   -- FraBe       31.07.2014  MKS-133491:1 ausbessern 'kaufmännisches und' auf 'AND' im kommentar (-> das kaufmännische und ist ja das zeichen für substitute )
   -- FraBe       03.10.2014  MKS-134424:1 get_PART_OF_BEARBEITER_KAUF: implement new wavePreInt4 logic
   -- FraBe       09.10.2014  MKS-134426:1 get_PART_OF_BEARBEITER_KAUF: some small changes betreffend I_PART und I_VALUE abfrage / details siehe direkt bei function
   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   -- function SUBSTITUTION overload: zuerst für char werte, dann number / date ist nicht notwendig
   -- return ist aber in beiden fällen char
   -- die eigentliche substitution erfolgt aber in function do_substitute

   FUNCTION do_substitute ( i_TAS_GUID VARCHAR2, i_LOG_TIMESTAMP TIMESTAMP, i_SUBSTITUTE_COLUMN_NAME VARCHAR2, i_SUBSTITUTE_COLUMN_VALUE VARCHAR2)
      RETURN VARCHAR2
   IS
      L_SUB_ICO_ATT_VALUE TSUBSTITUTE.SUB_ICO_ATT_VALUE%TYPE;
   BEGIN
   -- FraBe       27.03.2014  MKS-131260:1 add TOO_MANY_ROWS exception
   -- FraBe       23.06.2014  MKS-132103:1 return null within 'WorkshopAsCustomer' - NO_DATA_FOUND without selecting any default substitution value
      SELECT SUB_ICO_ATT_VALUE
        INTO L_SUB_ICO_ATT_VALUE
        FROM TSUBSTITUTE
       WHERE     SUB_SRS_ATT_NAME = i_SUBSTITUTE_COLUMN_NAME
             AND SUB_SRS_ATT_VALUE = i_SUBSTITUTE_COLUMN_VALUE;

      RETURN L_SUB_ICO_ATT_VALUE;
   EXCEPTION
      WHEN NO_DATA_FOUND 
      THEN if   i_SUBSTITUTE_COLUMN_NAME = 'WorkshopAsCustomer'   -- MKS-132103: return null within 'WorkshopAsCustomer' NO_DATA_FOUND without selecting any default substitution value
           then return null;
           else BEGIN                                             -- select default
                   SELECT   SUB_ICO_ATT_VALUE
                     INTO L_SUB_ICO_ATT_VALUE
                     FROM TSUBSTITUTE
                    WHERE     SUB_SRS_ATT_NAME = i_SUBSTITUTE_COLUMN_NAME
                          AND SUB_DEFAULT = 1;
       
                   RETURN L_SUB_ICO_ATT_VALUE;
                exception
                   when NO_DATA_FOUND 
                   then pck_exporter.SiMEXlog ( i_TAS_GUID => i_TAS_GUID, i_LOG_ID => '0009' -- no default substitution value existing
                                                                                            , i_LOG_TEXT => i_SUBSTITUTE_COLUMN_NAME || ' / ' || i_SUBSTITUTE_COLUMN_VALUE, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP);
                        return i_SUBSTITUTE_COLUMN_VALUE;
                   when TOO_MANY_ROWS
                   then pck_exporter.SiMEXlog ( i_TAS_GUID => i_TAS_GUID, i_LOG_ID => '0015' -- too many default substitution values existing
                                                                                            , i_LOG_TEXT => i_SUBSTITUTE_COLUMN_NAME || ' / ' || i_SUBSTITUTE_COLUMN_VALUE, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP);
                        raise_application_error ( -20000, SQLERRM );
                   when OTHERS 
                   then pck_exporter.SiMEXlog ( i_TAS_GUID => i_TAS_GUID, i_LOG_ID => '0011' -- something went wrong within default value substitution
                                                                                            , i_LOG_TEXT => SQLERRM, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP);
                        raise_application_error ( -20000, SQLERRM );
                end;
           end  if;      
      when TOO_MANY_ROWS
      then pck_exporter.SiMEXlog ( i_TAS_GUID => i_TAS_GUID, i_LOG_ID => '0016' -- too many substitution values existing
                                                                               , i_LOG_TEXT => i_SUBSTITUTE_COLUMN_NAME || ' / ' || i_SUBSTITUTE_COLUMN_VALUE, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP);
           raise_application_error ( -20000, SQLERRM );
      when OTHERS 
      then pck_exporter.SiMEXlog ( i_TAS_GUID => i_TAS_GUID, i_LOG_ID => '0010' -- something went wrong within value substitution
                                                                               , i_LOG_TEXT => SQLERRM);
           raise_application_error ( -20000, SQLERRM );
   END do_substitute;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION SUBSTITUTE ( i_TAS_GUID VARCHAR2, i_LOG_TIMESTAMP TIMESTAMP, i_SUBSTITUTE_COLUMN_NAME VARCHAR2, i_SUBSTITUTE_COLUMN_VALUE VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (do_substitute ( i_TAS_GUID => i_TAS_GUID, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP, i_SUBSTITUTE_COLUMN_NAME => i_SUBSTITUTE_COLUMN_NAME, i_SUBSTITUTE_COLUMN_VALUE => i_SUBSTITUTE_COLUMN_VALUE));
   END SUBSTITUTE;

   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION SUBSTITUTE ( i_TAS_GUID VARCHAR2, i_LOG_TIMESTAMP TIMESTAMP, i_SUBSTITUTE_COLUMN_NAME VARCHAR2, i_SUBSTITUTE_COLUMN_VALUE NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (do_substitute ( i_TAS_GUID => i_TAS_GUID, i_LOG_TIMESTAMP => i_LOG_TIMESTAMP, i_SUBSTITUTE_COLUMN_NAME => i_SUBSTITUTE_COLUMN_NAME, i_SUBSTITUTE_COLUMN_VALUE => TO_CHAR (i_SUBSTITUTE_COLUMN_VALUE)));
   END SUBSTITUTE;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION SUM_COSTS ( i_TAS_GUID VARCHAR2, i_ID_VERTRAG VARCHAR2, i_ID_FZGVERTRAG VARCHAR2)
      RETURN NUMBER
   IS
      L_RETURNVALUE  VARCHAR2 (100 CHAR);
   BEGIN
      SELECT TO_CHAR (SUM (FZGRE_RESUMME))
        INTO L_RETURNVALUE
        FROM TFZGRECHNUNG@SIMEX_DB_LINK
       WHERE     ID_VERTRAG = i_ID_VERTRAG
             AND ID_FZGVERTRAG = i_ID_FZGVERTRAG;

      RETURN L_RETURNVALUE;
   END SUM_COSTS;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION SUM_REVENUES ( i_TAS_GUID VARCHAR2, i_ID_VERTRAG VARCHAR2, i_ID_FZGVERTRAG VARCHAR2)
      RETURN NUMBER
   IS
      L_RETURNVALUE  VARCHAR2 (100 CHAR);
   BEGIN
      SELECT TO_CHAR (SUM (CI_AMOUNT))
        INTO L_RETURNVALUE
        FROM TCUSTOMER_INVOICE@SIMEX_DB_LINK
       WHERE ID_SEQ_FZGVC IN (SELECT ID_SEQ_FZGVC
                                FROM TFZGV_CONTRACTS@SIMEX_DB_LINK
                               WHERE     ID_VERTRAG = i_ID_VERTRAG
                                     AND ID_FZGVERTRAG = i_ID_FZGVERTRAG);

      RETURN L_RETURNVALUE;
   END SUM_REVENUES;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION calc_boolean ( I_BOOL_COLUMN INTEGER, I_TRUE INTEGER := 1, I_FALSE INTEGER := 0)
      RETURN VARCHAR2
   IS
   BEGIN
      IF I_BOOL_COLUMN = I_TRUE THEN
         RETURN 'true';
      ELSE
         RETURN 'false';
      END IF;
   END calc_boolean;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION remove_alpha (I_STRING_VALUE VARCHAR2)
      RETURN VARCHAR2
   IS
   -- purpose: removes any char which is not number
   -- FraBe 30.11.2013 MKS-129430:1 do not remove '+' anymore
   -- FraBe 04.04.2014 MKS-132131:1 use regexp_replace instead of translate
   BEGIN
      /* MKS-132131:1 old: */ -- return translate      ( I_STRING_VALUE, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZßäöüÄÖÜ!"§$%&/()=?}[]{}''*~#<>|´`\-,._ ', '0123456789');
      /*              new: */    return regexp_replace ( I_STRING_VALUE, '[^\+|[:digit:]]', '' ); 
   END remove_alpha;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_setting ( I_SECTION VARCHAR2, I_ENTRY VARCHAR2, I_DEFAULT VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      L_VALUE        TSETTING.SET_VALUE%TYPE;
   BEGIN
      SELECT SET_VALUE
        INTO L_VALUE
        FROM TSETTING
       WHERE     SET_SECTION = I_SECTION
             AND SET_ENTRY = I_ENTRY;

      RETURN L_VALUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN I_DEFAULT;
   END get_setting;
   
   PROCEDURE set_setting ( i_section VARCHAR2, i_entry VARCHAR2, i_value VARCHAR2) IS
   
   CURSOR cur_sett_upd IS
   SELECT set_value
     FROM tsetting
    WHERE set_section = i_section
      AND set_entry = i_entry
      FOR UPDATE NOWAIT;
   
   BEGIN

     FOR i IN cur_sett_upd LOOP

       UPDATE tsetting
          SET set_value = i_value
        WHERE CURRENT OF cur_sett_upd;              

     END LOOP;
     
     IF SQL%ROWCOUNT=0 THEN

       INSERT INTO tsetting
         (set_section, set_entry, set_value)
       VALUES
         (i_section  , i_entry  , i_value);

     END IF;

   EXCEPTION
      WHEN e_resource_busy THEN
        RAISE;
   END set_setting;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   -- erwartet einen string der form 'String1, String2 (String3)' und retourniert denn gewünschten (1, 2 oder 3)
   -- FraBe 05.12.2013 MKS-129442:1 due to length problems return 'SM_' || ... instead of  'Salesman_' 
   -- FraBe 25.06.2014 MKS-132116:1 implement new waveFinal logic (-> details siehe direkt beim code )
   -- FraBe 03.10.2014 MKS-134424:1 implement new wavePreInt4 logic 
   -- FraBe 09.10.2014 MKS-134426:1 fix bug: nicht auf SU% abfragen, sondern SU0% -> sonst kommt zb. bei Suys, Denis (D5DESUYS) ein falsches ergebnis
   --                               plus: bei I_PART = 1 bzw 2: nicht nur auf i_VALUE is NULL abfragen, sondern auch = 'GARAGE' / bzw. like SU0%
   --                               plus: correct when I_VALUE = auf when upper ( I_VALUE ) =
   FUNCTION get_PART_OF_BEARBEITER_KAUF 
          ( I_VALUE    VARCHAR2
          , I_PART     NUMBER
          , I_DEFAULT  VARCHAR2 DEFAULT NULL
          ) RETURN     VARCHAR2

   IS

      L_RETURN                   varchar2 ( 100 char );
      L_POS_1st_COMMA            number;
      L_POS_1st_BRACKET_BEGIN    number;

   BEGIN

      --- 25.06.2014 MKS-132116:1 folgend die neue waveFinal logik
      L_POS_1st_COMMA         := nvl ( instr ( I_VALUE, ',' ), 0 );
      L_POS_1st_BRACKET_BEGIN := nvl ( instr ( I_VALUE, '(' ), 0 );
      
      case 
      -----------------------------------------------------------------------------------
           when I_PART = 1                                                               --- wenn part = 1 (-> last name ):            
           then case 
                when upper ( I_VALUE ) = 'GARAGE' or upper ( I_VALUE ) like 'SU0%' or i_VALUE is NULL
                     -- 25.09.2014, TK, MKS-134909  Changed to DefaultSalesmen when i_value is GARAGE, SU% or NULL 
                then return null;
                when L_POS_1st_COMMA <> 0                                                ---      wenn   ein ',' in FZGV_BEARBEITER_KAUF vorhanden: 
                     then return trim ( substr ( I_VALUE                                 ---             return FZGV_BEARBEITER_KAUF value von beginn bis zum ersten ',' excl. sonderzeichen
                                               , 1
                                               , L_POS_1st_COMMA - 1 ));                 ---             (- 1 wird abgezogen, weil ja ohne ',' sonderzeichen -> endepos 1 stelle nach links )
                     else return trim ( I_VALUE );                                       ---      sonst: return gesamten orginalen FZGV_BEARBEITER_KAUF value
                end case;
      -----------------------------------------------------------------------------------
           when I_PART = 2                                                               --- wenn part = 2 (-> 1st name ): 
           then case 
                     when upper ( I_VALUE ) = 'GARAGE' or upper ( I_VALUE ) like 'SU0%' or i_VALUE is NULL
                     -- 25.09.2014, TK, MKS-134909  Changed to DefaultSalesmen when i_value is GARAGE, SU% or NULL 
                     then return null; 
                     
                     when L_POS_1st_COMMA = 0                                            ---      wenn   kein ',' in FZGV_BEARBEITER_KAUF vorhanden:
                     then return null;                                                   ---             return leer
                     else case when L_POS_1st_BRACKET_BEGIN <> 0                         ---      sonst (-> in FZGV_BEARBEITER_KAUF ist ein ',' vorhanden ): wenn zusätzlich auch eine beginnende '(' vorhanden:
                               then return trim ( substr ( I_VALUE                       ---             return FZGV_BEARBEITER_KAUF von ',' bis klammer '(' excl. der sonderzeichen
                                                         , L_POS_1st_COMMA         +1    ---             (-> bei startpos muß 1 dazugezählt werden, weil substr ja ohne ',' sonderzeichen -> startpos 1 stelle nach rechts )
                                                         , L_POS_1st_BRACKET_BEGIN -1    ---             (-> die laenge vom substr ist: a) pos von '(' minus 1, weil substr ja ohne '(' sonderzeichen  
                                                           - L_POS_1st_COMMA ));         ---                                            b) minus startpos )
                               else return trim ( substr ( I_VALUE                       ---      sonst (-> in FZGV_BEARBEITER_KAUF ist nur ein ',' vorhanden, aber keine '(' ): return FZGV_BEARBEITER_KAUF von ',' bis stringende excl. des sonderzeichens
                                                         , L_POS_1st_COMMA         +1    ---             (-> bei startpos muß 1 dazugezählt werden, weil substr ja ohne ',' sonderzeichen -> startpos 1 stelle nach rechts )
                                                         , length ( I_VALUE )));         ---             (-> bei der länge kann man quickANDdirty die gesamte textlänge angeben, da substr sowieso nur soviele zeichen nehmen kann, wie bis stringende da sind, auch wenn die angegebene länge mehr angibt )
                          end case;
                end case;
      -----------------------------------------------------------------------------------
           when I_PART = 3                                                               --- wenn part = 3 (-> externalId bzw. dealerDirectoryUid ): 
             THEN
               l_return := upper( regexp_substr( i_value,'\(\W*(\w+)\W*\)', 1, 1, 'i', 1));  -- MKS-152173 Return always in UPPER to avoid duplicates
               
               CASE
                 WHEN upper ( i_value ) =    'GARAGE'
                   OR upper ( i_value ) LIKE 'SU0%'
                   OR i_value           IS NULL
                   -- 25.09.2014, TK, MKS-134909  Changed to DefaultSalesmen when i_value is GARAGE, SU% or NULL 
                   THEN l_return := get_Setting('SETTING','DEFAULTSALESPERSON','DDEFAULT');
                    
                 WHEN l_return IS NULL
                   THEN 
                     
                     CASE
                       WHEN I_DEFAULT is not null                     -- wenn ein defaultvalue an diese function übergeben wurde:
                         then L_RETURN := 'SM_' || I_DEFAULT;         -- return diesen mit vorangestelltem 'SM_' präfix
                       ELSE
                         NULL; -- The function will return NULL, because no value in brackets found and no default is given
                     END CASE;                    
                     
                 ELSE
                   NULL;       -- result already calculated by regexp
               END CASE;
               
             RETURN l_return;
             
      end case;
   
      /* --- 25.06.2014 MKS-132116:1 folgende alte logik ist ab jetzt obsolete:
      L_POS_1st_COMMA         := nvl ( instr ( I_VALUE, ',' ), 0 );
      L_POS_1st_BRACKET_BEGIN := nvl ( instr ( I_VALUE, '(' ), 0 );

      DBMS_OUTPUT.put_line (L_POS_1st_COMMA || '-' || L_POS_1st_BRACKET_BEGIN);

      IF     (L_POS_1st_COMMA <> 0)
         AND (L_POS_1st_BRACKET_BEGIN <> 0) THEN
         DBMS_OUTPUT.put_line ('YES');
         L_LEFT    := SUBSTR ( I_VALUE, 1, L_POS_1st_BRACKET_BEGIN - 1);
         L_RIGHT   := SUBSTR ( I_VALUE, L_POS_1st_BRACKET_BEGIN + 1);
         L_RIGHT   := REPLACE ( L_RIGHT, ')');

         IF I_PART = 1 THEN
            L_RETURN   := SUBSTR ( L_LEFT, 1, L_POS_1st_COMMA - 1);
         ELSIF I_PART = 2 THEN
            L_RETURN   := SUBSTR ( L_LEFT, L_POS_1st_COMMA + 1, (L_POS_1st_BRACKET_BEGIN - 1) - (L_POS_1st_COMMA));
         ELSIF I_PART = 3 THEN
            L_RETURN   := L_RIGHT;
         END IF;
      END IF;

   -- TK          23.04.2104  MKS-132429:1 correct get_part_of_bearbeiter_kauf according Salesman-Export.
--      IF     (L_RETURN IS NULL)
--         AND (NOT I_DEFAULT IS NULL) THEN
--         L_RETURN   := 'SM_' || I_DEFAULT;
--      END IF;
        IF (L_RETURN IS NULL)
        AND (NOT I_DEFAULT IS NULL)
        -- this prevents creating salesman_references for explicit dropped Salesman
        AND (upper(I_VALUE) not in ( 'SU001', 'SU002', 'SU007', 'SU008', 'SU009', 'SU011', 'SU015', 'SU017', 'SU018', 'SU020', 'GARAGE'))
        -- this prevents creating salesman_references for not_filled_Fields
        AND (I_VALUE is not null)
        THEN
            L_RETURN := 'SM_' || I_DEFAULT;
        END IF;

      RETURN TRIM (L_RETURN); */
      
   END get_part_of_bearbeiter_kauf;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION get_DB_NAME_of_DB_LINK
   (
      I_DB_LINK_NAME VARCHAR2 DEFAULT 'SIMEX_DB_LINK'
   )
      RETURN VARCHAR2
   IS
      L_DB_NAME      VARCHAR2 (100 CHAR);
   BEGIN
      SELECT HOST
        INTO L_DB_NAME
        FROM ALL_DB_LINKS
       WHERE DB_LINK LIKE I_DB_LINK_NAME || '%';

      RETURN L_DB_NAME;
   END get_DB_NAME_of_DB_LINK;

   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   -- i_VAT: 0=only, 1=excl, 2=incl
   FUNCTION get_revenue_amount(i_GUID_CI TCUSTOMER_INVOICE.GUID_CI@SIMEX_DB_LINK%TYPE, i_VAT NUMBER)
      RETURN NUMBER
   AS
      l_REVENUE_AMOUNT NUMBER;
      
   BEGIN

      SELECT SUM(
        CASE i_VAT
          WHEN 0 THEN cip_amount/100*cip_vat_rate
          WHEN 1 THEN cip_amount
          WHEN 2 THEN cip_amount+cip_amount/100*cip_vat_rate
        END) 
        INTO l_REVENUE_AMOUNT
        FROM snt.TCUSTOMER_INVOICE_POS@SIMEX_DB_LINK cip
       WHERE cip.GUID_CI = i_GUID_CI;
       
       RETURN l_REVENUE_AMOUNT;
       
   END get_revenue_amount;
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION getCustomerAsDealer 
          ( I_ID_GARAGE      snt.TGARAGE.ID_GARAGE@SIMEX_DB_LINK%TYPE
          ) return           varchar2
   as
      L_SUB_SRS_ATT_VALUE    simex.TSUBSTITUTE.SUB_SRS_ATT_VALUE%TYPE;
      
   begin
      -- FraBe 04.07.2014 MKS-132047:2 creation
      -- FraBe 17.07.2014 MKS-132047:2 fix bug: SUB_SRS_ATT_VALUE und SUB_ICO_ATT_VALUE müssen vertauscht werden!

      select   SUB_SRS_ATT_VALUE
        into L_SUB_SRS_ATT_VALUE
        from simex.TSUBSTITUTE
       where SUB_SRS_ATT_NAME  = 'WorkshopAsCustomer'
         and SUB_ICO_ATT_VALUE = trim ( to_char ( I_ID_GARAGE ));   -- -> sonst versucht der CBO schlechtimizer eventuell ein to_number ( SUB_ICO_ATT_VALUE )
                                                                    -- -> was aber einen ORA-01722: invalid number zur folge hat, weil in SUB_ICO_ATT_VALUE 
                                                                    -- -> ja auch varchar2 werte stehen!
      return L_SUB_SRS_ATT_VALUE;
   exception
      when NO_DATA_FOUND 
      then return null;
       
   END getCustomerAsDealer;
   
      FUNCTION getWorkshopOrSupplier
          ( I_ID_GARAGE     snt.TGARAGE.ID_GARAGE@SIMEX_DB_LINK%TYPE
          ) return varchar2
      as
      l_supplierflag snt.tgarage.gar_is_service_provider@simex_db_link%Type;
      l_garnovega snt.tgarage.gar_garnovega@simex_db_link%Type;
      L_COUNTRY_CODE             TSETTING.SET_VALUE%type := pck_calculation.get_setting ( 'SETTING', 'COUNTRY_CODE',             null );
      begin
         select gar_is_service_provider, gar_garnovega 
         into l_supplierflag, l_garnovega
         from tgarage@simex_db_link
         where id_garage = I_ID_GARAGE;
         -- check if garage is workshop or supplier:
         -- according definition, a garage is supplier if she has a supplier flag
         --                     or in MBBEL only, GARGARNOVEGA =11924
         if l_supplierflag = 1 then 
           return 'S'; -- for supplier
         elsif (L_COUNTRY_CODE='51331' and l_garnovega='11924') then 
           return 'S';-- for Supplier
         else return 'W'; --for Workshop
         end if;
         

      exception
       when no_data_found then
         return 'ORA-20000: Workshop '||I_ID_GARAGE||' does not exist';
       when others then
         return sqlerrm;
      end getWorkshopOrSupplier;
   
   FUNCTION contract_number_sirius(
     i_id_vertrag                    VARCHAR2
   , i_id_fzgvertrag                 VARCHAR2 := NULL
   ) RETURN VARCHAR2 IS
   BEGIN
     RETURN i_id_vertrag || CASE WHEN i_id_fzgvertrag IS NOT NULL THEN '/' || i_id_fzgvertrag END;
   END contract_number_sirius;
  
   FUNCTION contract_number_migrate(
     i_id_vertrag                    VARCHAR2
   , i_id_fzgvertrag                 VARCHAR2 := NULL
   ) RETURN VARCHAR2 IS
   BEGIN
     RETURN lpad(i_id_vertrag, 8, '0') || CASE WHEN i_id_fzgvertrag IS NOT NULL THEN '/' || lpad(i_id_fzgvertrag, 6, '0') END;
   END contract_number_migrate;
BEGIN
  G_TENANT_ID                  := get_setting ( 'SETTING', 'TENANTID'               , 'TENANTID'  );
  G_USERID                     := get_setting ( 'SETTING', 'USERID'                 , 'SIRIUS'    );
  G_DFLT_TENANT_CURR           := get_setting ( 'SETTING' ,'DEFAULTTENANTCURRENCY'                );
  g_expdatetime                := get_setting ( 'SETTING', 'GLOBALDATETIME'         , '0'         );
END;
/
