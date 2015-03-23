/*======================================================================================================================
   DBMS name:   ORACLE Version 11g
   Created on:  19.10.2012 13:27:15
   MKS-119157:1 FraBe: add strProgram check within trigger TTASK.TTASK_CRE_HIST
   MKS-120849:8 FraBe: add global temporary table: TFZGPREIS_SIMEX
   MKS-126779:2 FraBe: on commit preserve rows within TFZGPREIS_SIMEX
   MKS-127620:1 FraBe 30.11.2013 table TFZGPREIS_SIMEX: add col FZGPR_PREIS_FIX
                      add index IE1TFZGPREIS_SIMEX / change PK
   MKS-130516:1 FraBe 17.01.2014 add new col TTASK.TAS_ORDER
   MKS-129521:1 FraBe 07.02.2014 new table TPRODUCT_HOUSE
   MKS-129519:2 FraBe 21.02.2014 new col VTASK_CURRENT.TAS_ORDER
   MKS-129519:2 FraBe 24.02.2014 add missing comments to some VTASK_CURRENT cols
   MKS-131791:1 FraBe 18.03.2014 VTASK_CURRENT: show latest / actual status of
                   simex tasks only -> max  ( TASH_TIMESTAMP || ' ' || TASH_STATE )
   MKS-132047:2 FraBe 09.07.2014 Dealer waveFinal - TSUBSTITUTE.UK_TSUBSTITUTE:
                                 obsolete due to multiple  definitions within key (-> SUB_SRS_ATT_NAME ) = 'WorkshopAsCustomer'
   MKS-133635:1 FraBe 09.08.2014 VTASK_CURRENT: fix bug vom 18.03.2014: use to_char bei max ( TASH_TIMESTAMP )
   MKS-133635:2 FraBe 09.08.2014 VTASK_CURRENT: use to_char auf beiden seiten des '=' zeichens!
   MKS-133123:1 FraBe 14.08.2014 add PH_PARAM_IN4 to table TPRODUCT_HOUSE
   MKS-132151:1 FraBe 19.08.2014 add EXT_CREATION_DATE to table TFZGPREIS_SIMEX
   MKS-134447:2 FraBe 23.10.2014 add to_date beim insert into TFZGPREIS_SIMEX
   MKS-136074:2 FraBe 17.12.2014 new table #_IN_SCOPE
   MKS-136294:1 MariF 15.01.2015 new table TTEMP_FZVERTRAG
   MKS-135606:3 MaZi  15.01.2015 new table SNT.TVEGA_MAPPINGLIST@SIMEX_DB_LINK
   MKS-136294:1 MariF 15.01.2015 Renamed table TTEMP_FZVERTRAG to TTEMP_TFZGVERTRAG
   MKS-136461:1 MaZi  27.01.2015 Rename TTEMP_FZVERTRAG consistently to TTEMP_TFZGVERTRAG
                                 Drop table SNT.TVEGA_MAPPINGLIST before creating it
   MKS-136461:1 MariF 27.01.2015 Add TTEMP_TFZGVERTRAG.FZGV_FGSTNR
   MKS-138692:1 MariF 09.02.2015 Deleted unneccesary columns from GTT TTEMP_TFZGVERTRAG, added new GTT TTEMP_TVERTRAGSTAMM
  ======================================================================================================================*/
alter session set current_schema=SIMEX;
  
create sequence TLOG_SEQ
increment by 1
start with 1  
 maxvalue 9999999999
 nominvalue
cycle
 nocache
order
/

/*==============================================================*/
/* Table: TLOG                                                  */
/*==============================================================*/
create table TLOG 
(
   LOG_GUID             varchar2 ( 32 char ) default SYS_GUID() not null,
   LOG_SEQUENCE         NUMBER                                  not null,
   LOG_ID               VARCHAR2(10 char),
   LOG_TEXT             VARCHAR2(500 char),
   LOG_TIMESTAMP        TIMESTAMP(6)         default systimestamp,
   TAS_GUID             varchar2 ( 32 char ),
   constraint PK_TLOG primary key (LOG_GUID)
         using index
       tablespace SIMEX
        nologging,
   constraint UK_TLOG unique (LOG_SEQUENCE)
         using index
       tablespace SIMEX
        nologging
)
tablespace SIMEX
logging
monitoring
/

comment on table TLOG is
'log - table'
/

comment on column TLOG.LOG_GUID is
'PK / Unique Identifier'
/

comment on column TLOG.LOG_SEQUENCE is
'unique seqno from sequence TLOG_SEQ'
/

comment on column TLOG.LOG_ID is
'Log ID'
/

comment on column TLOG.LOG_TEXT is
'additional log text'
/

comment on column TLOG.LOG_TIMESTAMP is
'timestamp of log'
/

comment on column TLOG.TAS_GUID is
'FK to TTASK.TAS_GUID'
/

/*==============================================================*/
/* Table: TMESSAGE                                              */
/*==============================================================*/
create table TMESSAGE 
(
   LOG_ID               VARCHAR2(10 char)    not null,
   LOG_MSG_TEXT         VARCHAR2(100 char)   not null,
   LOG_CLASS            VARCHAR2(1 char)     not null
      constraint CKC_LOG_CLASS_TMESSAGE check (LOG_CLASS in ('I','W','E')),
   constraint PK_TMESSAGE primary key (LOG_ID)
         using index
       tablespace SIMEX
        nologging
)
tablespace SIMEX
logging
monitoring
/

comment on table TMESSAGE is
'Message Text'
/

comment on column TMESSAGE.LOG_ID is
'Message ID - PK / Unique Identifier'
/

comment on column TMESSAGE.LOG_MSG_TEXT is
'Message Text'
/

comment on column TMESSAGE.LOG_CLASS is
'I=Info
W=Warning
E=Error'
/

/*==============================================================*/
/* Table: TSETTING                                              */
/*==============================================================*/
create table TSETTING 
(  SET_SECTION          varchar2 (  50 char )    not null  constraint CKC_SET_SECTION_TSETTING check ( SET_SECTION = upper ( SET_SECTION )),
   SET_ENTRY            varchar2 (  50 char )    not null  constraint CKC_SET_ENTRY_TSETTING   check ( SET_ENTRY   = upper ( SET_ENTRY )),
   SET_VALUE            varchar2 ( 100 char )           ,  constraint PK_TSETTING              primary key ( SET_SECTION, SET_ENTRY ) using index tablespace SIMEX nologging
) tablespace SIMEX logging monitoring
/

comment on table TSETTING is
'General settings for SiMEx'
/

comment on column TSETTING.SET_SECTION is
'Setting - Section value'
/

comment on column TSETTING.SET_ENTRY is
'Setting - Entry value'
/

comment on column TSETTING.SET_VALUE is
'Setting value'
/

/*==============================================================*/
/* Table: TSUBSTITUTE                                           */
/*==============================================================*/
create table TSUBSTITUTE 
(
   SUB_GUID             varchar2 ( 32 char )    default SYS_GUID() not null,
   SUB_SRS_ATT_NAME     VARCHAR2(30 CHAR)    not null,
   SUB_SRS_ATT_VALUE    VARCHAR2(100 CHAR),
   SUB_ICO_ATT_VALUE    VARCHAR2(100 CHAR),
   SUB_DEFAULT          INTEGER,
   constraint PK_TSUBSTITUTE primary key (SUB_GUID)
         using index
       tablespace SIMEX
        nologging
   /* MKS-132047:2 Dealer waveFinal: obsolete due to multiple definitions within key (-> SUB_SRS_ATT_NAME ) = 'WorkshopAsCustomer'
   constraint UK_TSUBSTITUTE unique (SUB_SRS_ATT_NAME, SUB_SRS_ATT_VALUE)
         using index
       tablespace SIMEX
        nologging
  */
)
tablespace SIMEX
logging
monitoring
/

comment on table TSUBSTITUTE is
'Substitute sirius-domain values with corresponding iCon values'
/

comment on column TSUBSTITUTE.SUB_GUID is
'PK / Unique Identifier'
/

comment on column TSUBSTITUTE.SUB_SRS_ATT_NAME is
'sirius attribute name'
/

comment on column TSUBSTITUTE.SUB_SRS_ATT_VALUE is
'sirius attribute value'
/

comment on column TSUBSTITUTE.SUB_ICO_ATT_VALUE is
'corresponding iCon attribute name'
/

comment on column TSUBSTITUTE.SUB_DEFAULT is
'Default value to be delivered to iCon if none of the given attribute-values matchs (maximum one per attribute-name)'
/

/*==============================================================*/
/* Table: TSUBST_OBJECT                                         */
/*==============================================================*/
create table TSUBST_OBJECT 
(
   SUB_SRS_ATT_NAME     VARCHAR2(30 char)    not null,
   SUBSTO_OBJECT        VARCHAR2(100 char)   not null
)
tablespace SIMEX
logging
monitoring
/

comment on table TSUBST_OBJECT is
'Assoz between TSUBSTITUTE and TTASK'
/

comment on column TSUBST_OBJECT.SUB_SRS_ATT_NAME is
'sirius attribute name'
/

comment on column TSUBST_OBJECT.SUBSTO_OBJECT is
'entry belonging to object'
/

/*==============================================================*/
/* Table: TTASK                                                 */
/*==============================================================*/
create table TTASK 
 ( TAS_GUID             varchar2 ( 32 char )    default sys_guid() not null
 , TAS_ACTIVE           INTEGER                                 not null   constraint CKC_TAS_ACTIVE_TTASK    check ( TAS_ACTIVE in ( 0, 1 ))
 , TAS_CAPTION          varchar2 ( 50 char )                       not null
 , TAS_PROCEDURE        varchar2 ( 50 char )                       not null
 , TAS_MAX_NODES        INTEGER              default 500        not null   constraint CKC_TAS_MAX_NODES_TTASK check ( TAS_MAX_NODES between 1 and 999999 )
 , TAS_ORDER            INTEGER                                 not null
 , constraint XAKTTASK_TAS_ORDER   unique      ( TAS_ORDER )  using index tablespace SIMEX
 , constraint PK_TTASK             primary key ( TAS_GUID )   using index tablespace SIMEX
 ) tablespace SIMEX logging monitoring
/

comment on table TTASK is
'Tasks used during Extraction'
/

comment on column TTASK.TAS_GUID is
'PK / Unique Identifier'
/

comment on column TTASK.TAS_ACTIVE is
'if task is active or inactive (-> 1 / 0 )'
/

comment on column TTASK.TAS_CAPTION is
'Caption of Task'
/

comment on column TTASK.TAS_PROCEDURE is
'Name of procedure / function in package PCK_EXPORTS which is executed by this task'
/

comment on column TTASK.TAS_MAX_NODES is
'Number of XML-nodes per file'
/

comment on column TTASK.TAS_ORDER is
'for exort execution sequence'
/

/*==============================================================*/
/* Table: TTASK_HISTORY                                         */
/*==============================================================*/
create table TTASK_HISTORY 
(
   TASH_GUID            varchar2 ( 32 char )    default sys_guid() not null,
   TAS_GUID             varchar2 ( 32 char )    not null,
   TASH_STATE           INTEGER              default 1 not null
      constraint CKC_TASH_STATE_TTASK_HI check (TASH_STATE between 0 and 4),
   TASH_TIMESTAMP       TIMESTAMP(6)         default systimestamp not null,
   constraint PK_TTASK_HISTORY primary key (TASH_GUID)
         using index
       tablespace SIMEX
        nologging
)
tablespace SIMEX
logging
monitoring
/

comment on column TTASK_HISTORY.TASH_GUID is
'PK / Unique Identifier'
/

comment on column TTASK_HISTORY.TAS_GUID is
'FK to TTASK'
/

comment on column TTASK_HISTORY.TASH_STATE is
'0=pending
1=running
2=finished successful
3=failed
4=cancelled'
/

comment on column TTASK_HISTORY.TASH_TIMESTAMP is
'timestamp of log-entry'
/

/*==============================================================*/
/* Table: TXML_SPLIT                                            */
/*==============================================================*/
create global temporary table TXML_SPLIT 
(
   PK_VALUE_CHAR        VARCHAR2(100 char),
   PK_VALUE_NUM         NUMBER
)
on commit delete rows
/

comment on table TXML_SPLIT is
'for char or num PKs of the driving table / how many are stored is defined in TTSAK.TAS_MAX_NODES'
/

comment on column TXML_SPLIT.PK_VALUE_CHAR is
'char PK value'
/

comment on column TXML_SPLIT.PK_VALUE_NUM is
'num PK value'
/
/*==============================================================*/
/* MKS-138692:1 Table: TTEMP_TVERTRAGSTAMM                      */
/*==============================================================*/
CREATE GLOBAL TEMPORARY TABLE TTEMP_TVERTRAGSTAMM
( LVL                                   INTEGER DEFAULT 1  NOT NULL                         
, ID_VERTRAG                            VARCHAR2(30 CHAR)  NOT NULL 
, ID_CUSTOMER                           VARCHAR2(15 CHAR)  NOT NULL
, COUNT_FZVG_INSCOPE                    NUMBER(10)         NOT NULL
);

COMMENT ON TABLE TTEMP_TVERTRAGSTAMM IS 'Temporary table to store source Customer Contracts.';
COMMENT ON COLUMN TTEMP_TVERTRAGSTAMM.ID_CUSTOMER IS 'ID_CUSTOMER of last Duration.';

/*==============================================================*/
/* MKS-136294:1 Table: TTEMP_TFZGVERTRAG                        */
/*==============================================================*/
CREATE GLOBAL TEMPORARY TABLE TTEMP_TFZGVERTRAG
( LVL                                   INTEGER DEFAULT 1  NOT NULL                         
, ID_VERTRAG                            VARCHAR2(30 CHAR)  NOT NULL 
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

/*==============================================================*/
/* View: VTASK_CURRENT                                          */
/*==============================================================*/
/* MKS-131791:1 FraBe 18.03.2014 show latest / actual status of simex tasks only: */
/*                              -> max  ( TASH_TIMESTAMP || ' ' || TASH_STATE )   */
/* MKS-133635:1 FraBe 09.08.2014 VTASK_CURRENT: fix bug vom 18.03.2014: use       */
/*                               to_char bei max ( TASH_TIMESTAMP )               */

create or replace force view simex.VTASK_CURRENT
     ( TAS_GUID
     , TAS_ACTIVE
     , TAS_CAPTION
     , TAS_PROCEDURE
     , TAS_STATE
     , TASH_STATE_CAPTION
     , TAS_MAX_NODES
     , TAS_TIMESTAMP
     , TAS_ORDER
     ) as
select tt.TAS_GUID
     , tt.TAS_ACTIVE
     , tt.TAS_CAPTION
     , tt.TAS_PROCEDURE
     , th.TASH_STATE
     , decode ( th.TASH_STATE, 0, 'PENDING'
                             , 1, 'RUNNING'
                             , 2, 'FINISHED OK'
                             , 3, 'FINISHED ERROR'
                             , 4, 'CANCELLED'
                                , 'UNKNOWN'
              )
     , tt.TAS_MAX_NODES
     , th.TASH_TIMESTAMP
     , tt.TAS_ORDER
  from simex.TTASK         tt
     , simex.TTASK_HISTORY th
 where th.TAS_GUID          = tt.TAS_GUID
   and                to_char (  th.TASH_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF' ) || ' ' ||  th.TASH_STATE 
     = ( select max ( to_char ( th1.TASH_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF' ) || ' ' || th1.TASH_STATE )
                                  from simex.TTASK_HISTORY th1
                                 where th1.TAS_GUID = tt.TAS_GUID )
 union
select tt.TAS_GUID
     , tt.TAS_ACTIVE
     , tt.TAS_CAPTION
     , tt.TAS_PROCEDURE
     , null
     , null
     , tt.TAS_MAX_NODES
     , null
     , tt.TAS_ORDER
  from simex.TTASK         tt
 where not exists ( select null from simex.TTASK_HISTORY th
                     where th.TAS_GUID = tt.TAS_GUID )
with read only
/

comment on table  simex.VTASK_CURRENT               is 'actual status of TTASK tasks';
comment on column simex.VTASK_CURRENT.TAS_GUID      is 'PK / Unique Identifier';
comment on column simex.VTASK_CURRENT.TAS_ACTIVE    is 'if task is active or inactive (-> 1 / 0 )';
comment on column simex.VTASK_CURRENT.TAS_CAPTION   is 'Caption of Task';
comment on column simex.VTASK_CURRENT.TAS_PROCEDURE is 'Name of procedure / function in package PCK_EXPORTS which is executed by this task';
comment on column simex.VTASK_CURRENT.TAS_MAX_NODES is 'Number of XML-nodes per file';
comment on column simex.VTASK_CURRENT.TAS_TIMESTAMP is 'timestamp of log-entry';
comment on column simex.VTASK_CURRENT.TAS_ORDER     is 'for export execution sequence';

comment on column simex.VTASK_CURRENT.TAS_STATE     is
'0=pending
1=running
2=finished successful
3=failed
4=cancelled';

comment on column simex.VTASK_CURRENT.TASH_STATE_CAPTION is
'actual status of task:
0=pending
1=running
2=finished successful
3=failed
4=cancelled';

alter table TLOG
   add constraint FK_MSG_REFERENCE_LOG foreign key (LOG_ID)
      references TMESSAGE (LOG_ID)
      not deferrable
/

alter table TLOG
   add constraint FK_TLOG_REFERENCE_TTASK foreign key (TAS_GUID)
      references TTASK (TAS_GUID)
      not deferrable
/

alter table TTASK_HISTORY
   add constraint FK_TTASK_HI_REFERENCE_TTASK foreign key (TAS_GUID)
      references TTASK (TAS_GUID)
      not deferrable
/

create or replace trigger TTASK_CRE_HIST
AFTER UPDATE
OF TAS_ACTIVE
ON TTASK
FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       TTASK_CRE_HIST
   PURPOSE:    

   REVISIONS:
   Author   Date       MKS      Description
   -------- ---------- -------- ------------------------------------
   Markus   12.10.2012          Created this trigger
   FraBe    18.10.2012 117506:2 überarbeitet
   FraBe    18.10.2012 117506:2 überarbeitet
   FraBe    04.12.2012 119157:1 add strProgram check

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     TTASK_CRE_HIST
      Sysdate:         12/10/2012
      Date and Time:   12/10/2012, 17:13:29, and 12/10/2012 17:13:29
      Username:        Markus (set in TOAD Options, Proc Templates)
      Table Name:      TTASK (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
    ret NUMBER;
    
    strProgram VARCHAR2(64 char);
   -- Declare program variables as shown above
BEGIN

    if :old.TAS_ACTIVE <> :new.TAS_ACTIVE
    then IF    :new.TAS_ACTIVE = 0
         THEN  -- cancel
               SELECT  PROGRAM
                 INTO strProgram
                 FROM sys.V_$SESSION
                WHERE AUDSID = USERENV ( 'SESSIONID' );      
               if   upper ( strProgram ) like 'SIMEX%'
               then ret:=simex.PCK_EXPORTER.CANCEL_JOB ( :new.TAS_GUID, :new.TAS_CAPTION );
               end  if;
         ELSIF :new.TAS_ACTIVE = 1 THEN
               -- create new
               INSERT INTO simex.TTASK_HISTORY ( TAS_GUID, TASH_STATE ) 
               VALUES ( :new.TAS_GUID, 0 );
         END   IF;
    END IF;

/*
    -- insert into ttask_history
    INSERT INTO simex.ttask_history (TAS_GUID, TASH_STATE) 
    VALUES (:new.TAS_GUID, DECODE(:new.TAS_ACTIVE,0,4,1,0));
*/

   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END TTASK_CRE_HIST;
/

/*==============================================================*/
/* FraBe 25.06.2013 add global temporary table: TFZGPREIS_SIMEX */
/* FraBe 30.11.2013 add col FZGPR_PREIS_FIX                     */ 
/*                  add index IE1TFZGPREIS_SIMEX / change PK    */
/* FraBe 19.08.2014 MKS-132151:1 add EXT_CREATION_DATE          */
/*==============================================================*/
/*==============================================================*/
/* global temporary table: TFZGPREIS_SIMEX                      */
/*==============================================================*/

create global temporary table simex.TFZGPREIS_SIMEX
     ( ID_SEQ_FZGVC                   number               not null
     , ID_VERTRAG                     varchar2 ( 30 char ) not null
     , ID_FZGVERTRAG                  varchar2 ( 30 char ) not null
     , FZGPR_VON                      date                 not null
     , FZGPR_BIS                      date                 not null
     , FZGPR_PREIS_GRKM               number( 12,4 )       not null
     , FZGPR_PREIS_MONATP             number( 12,4 )       not null
     , FZGPR_ADD_MILEAGE              number( 38,4 )
     , FZGPR_LESS_MILEAGE             number( 38,4 )
     , FZGPR_BEGIN_MILEAGE            number
     , FZGPR_END_MILEAGE              number
     , ID_LLEINHEIT                   number
     , INDV_TYPE                      number
     , FZGPR_PREIS_FIX                number
     , EXT_CREATION_DATE              date
     ) on commit  preserve rows;

create unique index simex.PXTFZGPREIS_SIMEX on simex.TFZGPREIS_SIMEX
     ( ID_VERTRAG
     , ID_FZGVERTRAG
     , FZGPR_VON 
     );


create        index simex.IE1TFZGPREIS_SIMEX on simex.TFZGPREIS_SIMEX
     ( ID_SEQ_FZGVC
     , ID_VERTRAG
     , ID_FZGVERTRAG
     );

-- MKS-134447:2 FraBe 23.10.2014: add to_date - formataufbereitung beim insert into TFZGPREIS_SIMEX
insert into simex.TFZGPREIS_SIMEX 
       ( ID_SEQ_FZGVC
       , ID_VERTRAG
       , ID_FZGVERTRAG
       , FZGPR_VON
       , FZGPR_BIS
       , FZGPR_PREIS_GRKM
       , FZGPR_PREIS_MONATP
       , FZGPR_ADD_MILEAGE
       , FZGPR_LESS_MILEAGE
       , FZGPR_BEGIN_MILEAGE
       , FZGPR_END_MILEAGE
       , ID_LLEINHEIT
       , INDV_TYPE
       , FZGPR_PREIS_FIX
       , EXT_CREATION_DATE ) 
values ( 0
       , '000000'
       , '0000'
       , to_date ( '01.01.2000', 'DD.MM.YYYY' )
       , to_date ( '01.01.2000', 'DD.MM.YYYY' )
       , 0
       , 0
       , 0
       , 0
       , 0
       , 0
       , 1
       , 1
       , 0
       , sysdate );
commit;

/*=================================================================================*/
/* MKS-129521:1 FraBe 07.02.2014 new table TPRODUCT_HOUSE                          */
/* MKS-133123:1 FraBe 14.08.2014 add PH_PARAM_IN4                                  */
/*=================================================================================*/
create table simex.TPRODUCT_HOUSE 
 ( GUID_PRODUCT_HOUSE   varchar2 (  32 char ) default sys_guid()  not null
 , PH_TYPE              varchar2 (  32 char )                     not null  constraint CKC_PH_TYPE_TPRODUCT    check ( PH_TYPE in ( 'SUPPLIER', 'PRODUCT', 'PRODUCTCOVERAGE', 'PRODUCTOPTION', 'SPP_PRODUCTS', 'TECHNICALOPTION' ))
 , PH_DEFAULT           INTEGER               default 0           not null  constraint CKC_PH_DEFAULT_TPRODUCT check ( PH_DEFAULT in ( 0,1 ))
 , PH_PARAM_IN1         varchar2 (  50 char )
 , PH_PARAM_IN2         varchar2 (  50 char )
 , PH_PARAM_IN3         varchar2 (  50 char )
 , PH_PARAM_IN4         varchar2 (  50 char )
 , PH_PARAM_OUT1        varchar2 (  50 char )
 , PH_PARAM_OUT2        varchar2 ( 100 char )
 , PH_PARAM_OUT3        varchar2 ( 350 char )
 , PH_PARAM_OUT4        varchar2 (  50 char )
 , PH_PARAM_OUT5        varchar2 (  50 char )
 , PH_PARAM_OUT6        varchar2 (  50 char )
 , PH_PARAM_OUT7        varchar2 (  50 char )
 , PH_PARAM_OUT8        varchar2 (  50 char )
 , constraint PK_TPRODUCT_HOUSE primary key ( GUID_PRODUCT_HOUSE ) using index tablespace SIMEX
 ) tablespace SIMEX logging monitoring;

create index SIMEX.XIE1TPRODUCT_HOUSE on SIMEX.TPRODUCT_HOUSE
 ( PH_PARAM_IN1
 , PH_PARAM_IN2
 , PH_PARAM_IN3
 , PH_PARAM_IN4
 ) tablespace  SIMEX logging;

comment on table  simex.TPRODUCT_HOUSE                    is 'ProductHouse conversion values';
comment on column simex.TPRODUCT_HOUSE.GUID_PRODUCT_HOUSE is 'PK / Unique Identifier';
comment on column simex.TPRODUCT_HOUSE.PH_TYPE            is 'ProductHouse Type';
comment on column simex.TPRODUCT_HOUSE.PH_DEFAULT         is '0: following PARAM_OUT* - values are no default values 
1: following PARAM_OUT1 - value is the TYPE default value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_IN1       is 'PARAMETER1 to be converted';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_IN2       is 'PARAMETER2 to be converted';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_IN3       is 'PARAMETER3 to be converted';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_IN4       is 'PARAMETER4 to be converted';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT1      is 'converted PARAMETER1 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT2      is 'converted PARAMETER2 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT3      is 'converted PARAMETER3 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT4      is 'converted PARAMETER4 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT5      is 'converted PARAMETER5 value'; 
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT6      is 'converted PARAMETER6 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT7      is 'converted PARAMETER7 value';
comment on column simex.TPRODUCT_HOUSE.PH_PARAM_OUT8      is 'converted PARAMETER8 value';

/* MKS-129521:1    FraBe 15.02.2014 increase TSETTING - SET_VALUE from 50 to 100 char due to longer values */

alter table simex.TSETTING modify SET_VALUE varchar2(100 char );

/*=================================================================================*/
/* MKS-136074:2 FraBe 17.12.2014 new table TCONTRACTS_IN_SCOPE                     */
/*=================================================================================*/
create table TCONTRACTS_IN_SCOPE 
 ( ID_VERTRAG           VARCHAR2 ( 30 CHAR )
 , ID_FZGVERTRAG        VARCHAR2 ( 30 CHAR )
 ) tablespace SIMEX logging monitoring;

comment on table TCONTRACTS_IN_SCOPE is
'DEF all contracts in this table are defined InScope';

/*=================================================================================*/
/* MKS-136487:1 MariF  12.02.2015 TFZGV_MIGRATION_MAPPING                          */
/*=================================================================================*/
CREATE TABLE TFZGV_MIGRATION_MAPPING
( mm_guid_contract        VARCHAR2(32 CHAR) NOT NULL
, mm_old_contract_number  VARCHAR2(30 CHAR) NOT NULL
, mm_new_contract_number  VARCHAR2(30 CHAR) NOT NULL
, mm_icon_contract_type   VARCHAR2(50 CHAR)
, mm_icon_coverage        VARCHAR2(50 CHAR)
, mm_mapping_made_by      VARCHAR2(30 CHAR) NOT NULL
, mm_comment              VARCHAR2 (500 CHAR)
);
COMMENT ON TABLE tfzgv_migration_mapping IS 'Cleansing results for affected Vehicle Contracts and Extraction mapping.';

COMMENT ON COLUMN tfzgv_migration_mapping.mm_comment IS 'Mapping reason (Integrated to new contract DEF5658, renumbered DEF5660, etc.).';
COMMENT ON COLUMN tfzgv_migration_mapping.mm_mapping_made_by IS '"Cleansing" - cleansing script; "Extraction" - extraction logic.';

CREATE INDEX tfzgv_migrmap_guidcontract_i ON tfzgv_migration_mapping(mm_guid_contract);
CREATE INDEX tfzgv_migrmap_old_contrnum_i ON tfzgv_migration_mapping(mm_old_contract_number);
/*=================================================================================*/
/* MKS-136487:1 MariF  12.02.2015 TVEGA_MAPPINGLIST@SIMEX_DB_LINK                  */
/*=================================================================================*/
declare
  v_exists number(1);
begin
  select 1
    into v_exists
    from user_tables@simex_db_link
   where table_name='TVEGA_MAPPINGLIST';
   dbms_output.put_line('TVEGA_MAPPINGLIST@SIMEX_DB_LINK already exists, skipping.');
exception when no_data_found then
     dbms_utility.exec_ddl_statement@simex_db_link('CREATE TABLE TVEGA_MAPPINGLIST
      ( VM_VEGA_MARKET                    VARCHAR2(10 CHAR)
      , VM_SOURCE_CONTRACT                VARCHAR2(30 CHAR)
      , VM_FIN                            VARCHAR2(25 CHAR) NOT NULL
      , VM_FOUND_CONTRACT_TYPE            VARCHAR2(50 CHAR)
      , VM_VEGA_DAMAGE_EXISTS             NUMBER(1)         NOT NULL
      , VM_VEGA_ARCHIV_DAMAGE_EXISTS      NUMBER(1)         NOT NULL
      , VM_OLD_VEGA_SC_EXISTS             NUMBER(1)         NOT NULL
      )');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON TABLE  TVEGA_MAPPINGLIST IS ''Vega Mapping List with data received from Vega and updated with Sirius data during export.''');   
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_VEGA_MARKET               IS ''Key info: Vega Market.''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_SOURCE_CONTRACT           IS ''Key info: Sirius Contract Number.''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_FIN                       IS ''Key info: FIN (Vehicle Chassis number including world manufacturer Code).''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_FOUND_CONTRACT_TYPE       IS ''Vega source: Found contract type.''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_VEGA_DAMAGE_EXISTS        IS ''Vega source: Vega damage exists.''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_VEGA_ARCHIV_DAMAGE_EXISTS IS ''Vega source: Vega archiv damage exists.''');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TVEGA_MAPPINGLIST.VM_OLD_VEGA_SC_EXISTS        IS ''Vega source: Old VEGA Service Contract exists.''');
     dbms_output.put_line('Table TVEGA_MAPPINGLIST@SIMEX_DB_LINK created.');
end;
/

/*=================================================================================*/
/* MKS-136487:1 MariF  18.02.2015 TFZGV_CLEANSING_MAPPING@SIMEX_DB_LINK            */
/*=================================================================================*/
DECLARE
  v_exists    smallint;
  begin
  select 1
    into v_exists
    from user_tables@simex_db_link
   where table_name='TFZGV_CLEANSING_MAPPING';
   dbms_output.put_line('Table TFZGV_CLEANSING_MAPPING@SIMEX_DB_LINK is already created. All existing rows will stay untouched.');
  exception when no_data_found then
     dbms_utility.exec_ddl_statement@SIMEX_DB_LINK('CREATE TABLE TFZGV_CLEANSING_MAPPING
      ( cm_guid_contract        VARCHAR2(32 CHAR) NOT NULL
      , cm_old_contract_number  VARCHAR2(30 CHAR) NOT NULL
      , cm_new_contract_number  VARCHAR2(30 CHAR) NOT NULL
      , cm_comment              VARCHAR2 (500 CHAR) NOT NULL
      )');
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON TABLE  TFZGV_CLEANSING_MAPPING IS ''Merging-Splitting-Renumbering history for affected Vehicle Contracts.''');   
     dbms_utility.exec_ddl_statement@simex_db_link('COMMENT ON COLUMN TFZGV_CLEANSING_MAPPING.cm_comment IS ''Mapping reason (Integrated to new contract DEF5658, renumbered DEF5660, etc.).''');
     dbms_utility.exec_ddl_statement@simex_db_link('CREATE INDEX tfzgv_cleansmap_guidcontract_i ON TFZGV_CLEANSING_MAPPING(cm_guid_contract)');
     dbms_utility.exec_ddl_statement@simex_db_link('CREATE UNIQUE INDEX tfzgv_cleansmap_old_contrnum_i ON tfzgv_cleansing_mapping(cm_old_contract_number,cm_new_contract_number)');
     dbms_output.put_line('Table TFZGV_CLEANSING_MAPPING@SIMEX_DB_LINK created.');
  end;
/
