===========================================================================
= SIRIUS Service-Script LOP2722
===========================================================================

Date         : 25.05.2012
Author       : FraBe (ReadMe: zisco)

Preconditions: 
1) store DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher
3) the script is especially designed for all sirius MPCs

===========================================================================
= Description                                                             =
===========================================================================

  a) corrects numerical values with too high precision 
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump before executing the script.
      
Step  2: Open commdand window

Step  3: Go to your working folder

Step  4: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than 2.8.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.sql

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: 'Y' saves data into the DB only if ALL invoices and credit notes can be fixed.
         If at least one invoice / credit note cannot be fixed, no data will be saved into the DB
         even if the answer is 'Y'.

Step  7: does a) to c) listed above
         The output can be found in the created logfile DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2722-Inexact_zero_values_in_workshop_or_customer_invoice.log
         if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.