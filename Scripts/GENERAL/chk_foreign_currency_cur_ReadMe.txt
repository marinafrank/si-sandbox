===========================================================================
= HealthCheck script chk_foreign_currency_cur.sql                         =
===========================================================================

Date         : 08.04,2013
Author       : FraBe

Preconditions: 
1) store chk_foreign_currency_cur.sql into your working directory
2) the version of your SIRIUS DB must be 2.7.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Lists all tables with currency data which deviates from the currency of the MPC
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open a commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than <n.n.n> you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, , but version must be same or higher than <n.n.n>
         
         Within both cases the execution of the script is aborted.

Step  4: SQL> @chk_foreign_currency_cur.sql

Step  5: Does the action described above
         The output can be found in the created logfile chk_foreign_currency_cur.log

Step  6: When script has finished: 
         check the generated logfile chk_foreign_currency_cur.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.