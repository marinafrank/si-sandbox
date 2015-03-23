DECLARE
  l_count NUMBER;
BEGIN
  SELECT COUNT (*)
  INTO   l_count
  FROM   all_scheduler_jobs
  WHERE  job_name = 'EXPORT_HC';

  IF l_count = 0
  THEN
    DBMS_SCHEDULER.create_job
         (job_name                 => 'EXPORT_HC'
         ,job_type                 => 'PLSQL_BLOCK'
         ,job_action               => 'DECLARE BEGIN ssi.ssi_healthcheck.check_database(''SCOPE''); END;'
         ,number_of_arguments      => 0
         ,start_date               => SYSTIMESTAMP +0.00050
         ,repeat_interval          => 'freq=yearly; interval=10'
         ,end_date                 => NULL
         ,job_class                => 'DEFAULT_JOB_CLASS'
         ,enabled                  => TRUE
         ,auto_drop                => TRUE
         ,comments                 => 'Export Healthcheck once'
         );
    DBMS_OUTPUT.put_line ('Job EXPORT_HC created');
  ELSE
    DBMS_SCHEDULER.drop_job ('EXPORT_HC', force=>true);
    DBMS_OUTPUT.put_line ('Job EXPORT_HC dropped');
    DBMS_SCHEDULER.create_job
         (job_name                 => 'EXPORT_HC'
         ,job_type                 => 'PLSQL_BLOCK'
         ,job_action               => 'DECLARE BEGIN ssi.ssi_healthcheck.check_database(''SCOPE''); END;'
         ,number_of_arguments      => 0
         ,start_date               => SYSTIMESTAMP +0.00050
         ,repeat_interval          => 'freq=yearly; interval=10'
         ,end_date                 => NULL
         ,job_class                => 'DEFAULT_JOB_CLASS'
         ,enabled                  => TRUE
         ,auto_drop                => TRUE
         ,comments                 => 'Export Healthcheck once'
         );
    DBMS_OUTPUT.put_line ('Job EXPORT_HC created');
  END IF;

 END;
/

exit;