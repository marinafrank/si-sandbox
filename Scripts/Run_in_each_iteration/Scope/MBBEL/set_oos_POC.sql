SET ECHO OFF

SET TERMOUT OFF
Define commit_or_rollback = &1 N;
SET TERMOUT ON
prompt SELECTION CHOSEN: &commit_or_rollback;

PROMPT All inactive Contracts which ended earlier than this date will be set to OutOfScope DD.MM.YYYY:

SET TERMOUT OFF
Define Out_Of_Scope_Date = &2 01.01.2011;
SET TERMOUT ON
prompt SELECTION CHOSEN: &Out_Of_Scope_Date 

prompt
PROMPT What scope will be applied? Defaulting to "A":

SET TERMOUT OFF
Define Scope = &3 A;
SET TERMOUT ON

prompt SELECTION CHOSEN: &Scope

prompt
PROMPT SNT password:

SET TERMOUT OFF
Define pwd = &4
SET TERMOUT ON

drop table out_of_scope_contracts;
drop table in_scope_contracts;

CREATE TABLE out_of_scope_contracts
(ID_VERTRAG    varchar2(30) not null
,ID_FZGVERTRAG varchar2(30) default '*' not null
)
/

CREATE TABLE in_scope_contracts
(ID_VERTRAG    varchar2(30) not null
,ID_FZGVERTRAG varchar2(30) default '*' not null
)
/

host sqlldr silent=(HEADER) userid=snt/&&pwd@&&_connect_identifier control=exclude_list.ctl data=Additional_OutOfScope.csv
host sqlldr silent=(HEADER) userid=snt/&&pwd@&&_connect_identifier control=include_list.ctl data=Additional_InScope.csv

set feedback on
set echo on
select * from out_of_scope_contracts;
select * from in_scope_contracts;
exit
