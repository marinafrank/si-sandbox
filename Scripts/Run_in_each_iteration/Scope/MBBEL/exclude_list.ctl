OPTIONS (direct=TRUE , errors= 100000000000, SKIP=0 )
LOAD DATA
TRUNCATE
INTO TABLE OUT_OF_SCOPE_CONTRACTS
fields terminated by ';'
TRAILING NULLCOLS
( ID_VERTRAG           "trim(:ID_VERTRAG)"     
, ID_FZGVERTRAG       "nvl(trim(:ID_FZGVERTRAG),'*')"      
)
