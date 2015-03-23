/* ****************************************************************** */
/* Script for setting parameters on Oracle 10g (RBO) for SIRIUS       */
/* Has to run under user SYS !                                        */
/*								                                                    */
/* Author:  D. Mildner, DCTSS GmbH		                        	      */
/* Created: 08.06.2005					                                      */
/*								                                                    */
/* Change Historie                                                    */
/* ---------------------------------				                          */
/* FraBe MKS-46186:3 add nls_length_semantics=char                    */
/* FraBe MKS-48263:1 add nls_sort=binary 			                        */
/* AM	 alter optimizer_mode=CHOOSE                                    */
/* ****************************************************************** */

spool parameter_10rbo.log
set echo on

col name format a30
col value format a20

select name, value from v$parameter
where upper(name) like '%SHARED_POOL%'
or upper(name) like '%DB_CACHE_SIZE%'
or upper(name) like '%LARGE_POOL%'
or upper(name) like '%JAVA_POOL%'
or upper(name) like '%AGGREGATE_T%'
or upper(name) like '%OPTIMIZER_MODE%' 
or upper(name) like '%SESSION_CACHED_C%'
or upper(name) like '%NLS_LENGTH_SEMANTICS%'
or upper(name) like '%NLS_SORT%'
order by name;

alter system set shared_pool_size=50M         scope=spfile;
alter system set shared_pool_reserved_size=5M scope=spfile;
alter system set db_cache_size=600M           scope=spfile;
alter system set large_pool_size=16M          scope=spfile;
alter system set java_pool_size=24M           scope=spfile;
alter system set pga_aggregate_target=250M    scope=spfile;
alter system set optimizer_mode=CHOOSE        scope=spfile;   
alter system set session_cached_cursors=100   scope=spfile;
alter system set nls_length_semantics=char    scope=spfile;
alter system set nls_sort=binary              scope=spfile;

create pfile from spfile;

shutdown immediate
startup

col name format a30
col value format a20

select name, value from v$parameter
where upper(name) like '%SHARED_POOL%'
or upper(name) like '%DB_CACHE_SIZE%'
or upper(name) like '%LARGE_POOL%'
or upper(name) like '%JAVA_POOL%'
or upper(name) like '%AGGREGATE_T%'
or upper(name) like '%OPTIMIZER_MODE%'   
or upper(name) like '%SESSION_CACHED_C%'
or upper(name) like '%NLS_LENGTH_SEMANTICS%'
or upper(name) like '%NLS_SORT%'
order by name;

set echo off   
spool off
exit