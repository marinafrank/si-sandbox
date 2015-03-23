===========================================================================
= SIRIUS iCON Service-Script for LOP2146                                  =
===========================================================================

Date         : 13.11.2013
Author       : FraBe

Preconditions: 
1) store DataAnalysis_LOP2146-Customers_with_Cofico_111111111.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.1 or higher
3) the script is especially designed for a MBBeLux DB only

===========================================================================
= Description                                                             =
===========================================================================

reports all MBBeLux Customers with value 111111 in either Cofico Debitor or Creditor-Nummer

  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than 2.8.1 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.1
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  4: SQL> @DataAnalysis_LOP2146-Customers_with_Cofico_111111111.sql

         As the script is designed for a MBBeLux DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==
         
Step  5: Does action described above.
         The output can be found in the created logfile DataAnalysis_LOP2146-Customers_with_Cofico_111111111.log

Step  6: When script has finished: 
         check the generated logfile DataAnalysis_LOP2146-Customers_with_Cofico_111111111.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.