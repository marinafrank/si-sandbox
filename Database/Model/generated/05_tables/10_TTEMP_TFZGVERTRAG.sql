--DROP TABLE TTEMP_TFZGVERTRAG PURGE;
CREATE GLOBAL TEMPORARY TABLE TTEMP_TFZGVERTRAG
( ID_VERTRAG                            VARCHAR2(30 CHAR)  NOT NULL 
, ID_FZGVERTRAG                         VARCHAR2(30 CHAR)  NOT NULL
, ID_CUSTOMER                           VARCHAR2(15 CHAR)  NOT NULL
, GUID_CONTRACT                         VARCHAR2(32 CHAR)  NOT NULL 
, FZGV_CREATED                          DATE               NOT NULL 
, FZGV_I55_VEH_SPEC_TEXT                VARCHAR2(2500 CHAR)
, ID_VERTRAG_PARENT                     VARCHAR2(30 CHAR)
, ID_FZGVERTRAG_PARENT                  VARCHAR2(30 CHAR)
, ID_COS                                NUMBER             NOT NULL 
, ID_GARAGE                             NUMBER             NOT NULL 
, ID_GARAGE_SERV                        NUMBER             NOT NULL 
, FZGV_CAUSE_OF_RETIRE                  NUMBER(1)          NOT NULL 
, FZGV_NO_CUSTOMER                      VARCHAR2(100 CHAR)
, SALESCHANNEL                          VARCHAR2(50 CHAR)       
, DRIVER                                VARCHAR2(100 CHAR)
, FZGV_SIGNATURE_DATE                   DATE   
, FZGV_FIXED_LABOUR_RATE                NUMBER
, FZGV_ERSTZULASSUNG                    DATE
, FZGV_BEARBEITER_KAUF                  VARCHAR2(50 CHAR)
, FZGV_MANUAL_OVERRULE_I55              NUMBER
, FZGV_HANDLE_NOMINATED_DEALER          NUMBER(1)
, FZGV_PROV_AMOUNT                      NUMBER
, FZGV_PROV_MEMO                        VARCHAR2(50 CHAR)
, ID_MANUFACTURE                        VARCHAR2(3 CHAR)
, FZGV_FGSTNR                           VARCHAR2(30 CHAR)
, LASTPRINTDATESERVICECARD              VARCHAR2(10 CHAR)
, MILEAGEBALANCINGREMINDERDATE          VARCHAR2(10 CHAR)
, START_FZGVC_BEGINN                    DATE               NOT NULL
, START_FZGVC_BEGINN_KM                 NUMBER(10)         NOT NULL
, END_FZGVC_BEGINN                      DATE               NOT NULL
, END_FZGVC_ENDE                        DATE               NOT NULL
, END_FZGVC_ENDE_KM                     NUMBER(10)         NOT NULL
, END_ID_KMSTAND_END                    NUMBER    
, END_FZGVC_MEMO                        VARCHAR2(2000 CHAR)
, END_FZGVC_IDX_NEXTDATE                DATE
, END_FZGVC_SPECIAL_CASE                NUMBER(1)          NOT NULL
, END_ID_COV                            NUMBER(4)          NOT NULL
, END_INV_CONSOLID                      NUMBER(1)          NOT NULL
, ID_FAHRZEUGART                        NUMBER(2)
, CUR_CODE                              VARCHAR2(3 CHAR)
, ID_PAYM                               NUMBER(4)          NOT NULL
, PAYM_MONTHS                           NUMBER(2)
, PAYM_TARGETDATE_CI                    NUMBER             NOT NULL 
, END_ID_SEQ_FZGVC                      NUMBER             NOT NULL 
, COS_CAPTION                           VARCHAR2(50 CHAR)
, COS_ACTIVE                            NUMBER(1)          NOT NULL 
, INDV_TYPE                             NUMBER(1)
, INDV_CAPTION                          VARCHAR2(20 CHAR)
, GUID_VI55AV                           VARCHAR2(32 CHAR)
, VI55AV_VALUE                          VARCHAR2(99 CHAR)  NOT NULL
, ID_TYPGRUPPE                          NUMBER(3)
, GUID_BUSINESS_AREA_L2                 VARCHAR2(32 CHAR)  NOT NULL 
, BankAccount                           VARCHAR2(50 CHAR)
, CUST_COST_CENTER                      VARCHAR2(20 CHAR)
, CUST_SAP_NUMBER_DEBITOR               VARCHAR2(15 CHAR)
, CUST_INVOICE_CONS_METHOD              NUMBER             NOT NULL
, CUST_INV_ADRESS_BALFIN                VARCHAR2(15 CHAR)
, CUST_INVOICE_ADRESS                   VARCHAR2(15 CHAR)  NOT NULL 
, GAR_GARNOVEGA                         VARCHAR2(6 CHAR)
, GARSERV_GARNOVEGA                     VARCHAR2(6 CHAR)
, start_km                              NUMBER(10) NOT NULL
, start_km_date                         DATE NOT NULL
, kmstand_begin_km                      NUMBER(10) NOT NULL
, kmstand_begin_km_date                 DATE NOT NULL
, kmstand_end_km                        NUMBER(10)
, kmstand_end_km_date                   DATE
, last_odometer                         NUMBER
, FZGPR_SUBAS                           NUMBER(12,4)                    
, FZGPR_MLP                             NUMBER(12,4)
, FZGPR_SUBSA                           NUMBER(12,4)
, FZGPR_DISCAS                          NUMBER(12,4)
, FZGPR_DISCHA                          NUMBER(12,4)
, FZGPR_DISDE                           NUMBER(12,4)
, FZGPR_SUBBU                           NUMBER(12,4)
, FZGPR_DISSAL                          NUMBER(12,4)                     
, PR_DISCAS_EXIST                       INTEGER
, PR_DISCHA_EXIST                       INTEGER
, PR_DISDE_EXIST                        INTEGER
, PR_SUBBU_EXIST                        INTEGER
, PR_DISSAL_EXIST                       INTEGER
, ICP_CAPTION                           VARCHAR2(50 CHAR)
, ID_BRANCH_SSI                         NUMBER(4)
, PRODUCT                               VARCHAR2(50 CHAR)
, end_COV_SCARF_CONTRACT                NUMBER(1) NOT NULL
);

COMMENT ON TABLE TTEMP_TFZGVERTRAG IS 'Temporary table to store source contracts details bulk fetched via DB Link.';
