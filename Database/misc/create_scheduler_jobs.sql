DECLARE
  l_count NUMBER;
BEGIN
  SELECT COUNT (*)
  INTO   l_count
  FROM   all_scheduler_jobs
  WHERE  job_name = 'JOB_SIMEX';

  IF l_count = 0
  THEN
    simex.p_job.create_JOB_SiMEX;
    DBMS_OUTPUT.put_line ('Job SiMEX created');
  ELSE
    DBMS_OUTPUT.put_line ('Job SiMEX exists already');
  END IF;

END;
/