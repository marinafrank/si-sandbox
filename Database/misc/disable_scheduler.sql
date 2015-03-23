-- script for disabling all running SIMEX Jobs
-- FraBe 08.10.2012 MKS-117502: copied from SIRIUS

DECLARE
   CURSOR job_cur
   IS
      SELECT job_name
            ,state
        FROM user_scheduler_jobs;
BEGIN
   FOR jobs IN job_cur
   LOOP
      IF jobs.state = 'RUNNING'
      THEN
         DBMS_SCHEDULER.stop_job (job_name      => jobs.job_name, FORCE => TRUE);
         dbms_output.put_line (jobs.Job_name ||' was stopped immediately!');
      END IF;

      DBMS_SCHEDULER.DISABLE (NAME       => jobs.job_name, FORCE => TRUE);
      dbms_output.put_line (jobs.Job_name ||' was disabled!');
     
   END LOOP;
END;
/
