-- MKS-126779_1.sql

-- FraBe 26.06.2013 MKS-126779:1

drop table SIMEX.TFZGPREIS_SIMEX;

create global temporary table SIMEX.TFZGPREIS_SIMEX
    (ID_SEQ_FZGVC                   number not null,
    ID_VERTRAG                     varchar2(30 char) not null,
    ID_FZGVERTRAG                  varchar2(30 char) not null,
    FZGPR_VON                      date not null,
    FZGPR_BIS                      date not null,
    FZGPR_PREIS_GRKM               number(12,4) not null,
    FZGPR_PREIS_MONATP             number(12,4) not null,
    FZGPR_ADD_MILEAGE              number(38,4),
    FZGPR_LESS_MILEAGE             number(38,4),
    FZGPR_BEGIN_MILEAGE            number,
    FZGPR_END_MILEAGE              number,
    ID_LLEINHEIT                   number,
    INDV_TYPE                      number)
on commit preserve rows
/

create unique index SIMEX.PXTFZGPREIS_SIMEX on SIMEX.TFZGPREIS_SIMEX
  (
    ID_SEQ_FZGVC                    asc,
    ID_VERTRAG                      asc,
    ID_FZGVERTRAG                   asc,
    FZGPR_VON                       asc
  )
/

