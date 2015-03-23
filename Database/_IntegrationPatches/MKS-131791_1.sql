-- MKS-131791_1.sql

-- FraBe 18.03.2014 creation due to MKS-131791:1  show latest / actual status of simex tasks only:
--                  -> max  ( TASH_TIMESTAMP || ' ' || TASH_STATE )

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
   and th.TASH_TIMESTAMP  
    || ' ' || th.TASH_STATE = ( select max ( th1.TASH_TIMESTAMP || ' ' || th1.TASH_STATE )
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

