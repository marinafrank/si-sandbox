===========================================================================
= SIRIUS Service-Script for iCON Ticket LOP2721                           =
===========================================================================

Date         : 03.03.2014
Author       : FraBe

Preconditions: 
1) store DataCleansing_LOP2721-RelocateInvoices.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher
3) the script is especially designed for a MBBeLux DB only

===========================================================================
= Description                                                             =
===========================================================================

moves 10 workshop invoices given by the MPC to another contract.

This change triggers 2 rows for each invoice within the next I50(71) export execution:
- 1st row with the old values
- 2nd one with the new value 

This change also affects the next SCARF Invoice(74) export execution: 
then the values of these 10 invoices are reported within the new contract pos 23 - 34 of RecordType = 01

Other systems are not concerned.

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

Step  5: SQL> @DataCleansing_LOP2721-RelocateInvoices.sql

         As the script is designed for a MBBeLux DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  7: does action described above
         The output can be found in the created logfile DataCleansing_LOP2721-RelocateInvoices.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2721-RelocateInvoices.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm.
         
Step  9: Please also check that only following message may be reported within each of the 10 invoices:
         1 row updated.
         
         If there is another mesaage like e.g. 
         0 rows updated.
         or
         2 rows updated.
         and so on,
         then contact the SIRIUS technical support team @Ulm as well. 

         
For questions and feedback please contact the SIRIUS technical support team @Ulm.