-- script for enabling all running SiMEX Jobs
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
      IF jobs.state != 'COMPLETED'
      THEN
         BEGIN
            DBMS_SCHEDULER.ENABLE (NAME      => jobs.job_name);
            DBMS_OUTPUT.put_line (jobs.job_name || ' was enabled!');
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (jobs.job_name || ' has an Error and must be checked manually ! ' || SQLERRM);
         END;
      END IF;
   END LOOP;
END;
/