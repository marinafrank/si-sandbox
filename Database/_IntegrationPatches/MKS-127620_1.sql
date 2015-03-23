/*==============================================================*/
/* FraBe 25.06.2013 cre global temporary table: TFZGPREIS_SIMEX */
/* FraBe 30.11.2013 MKS-127620:1 add col FZGPR_PREIS_FIX        */ 
/*                  add index IE1TFZGPREIS_SIMEX / change PK    */
/*==============================================================*/
/*==============================================================*/
/* global temporary table: TFZGPREIS_SIMEX                      */
/*==============================================================*/

drop table SIMEX.TFZGPREIS_SIMEX;

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
