===========================================================================
= SIRIUS Service-Script for DEF6668                                       =
===========================================================================

Date         : 10.02.2015
Author       : Markus Zimmerberger

Preconditions: 
1) store DataAnalysis_DEF6668_Find_contracts_without_bank_accounts.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.1 or higher
3) the script is especially designed for a MBBEL DB only

===========================================================================
= Description                                                             =
===========================================================================

  a) Find contracts without bank accounts
     Note: There is a parameter you can use to filter out cancelled contracts,
     therefore set L_IGNORE_STAT_CODE to 0

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

Step  5: SQL> @DataAnalysis_DEF6668_Find_contracts_without_bank_accounts.sql

         I) As the script is designed for a MBBEL DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBL DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: 'Y' saves data into the DB only if ALL invoices and credit notes can be fixed.
         If at least one invoice / credit note cannot be fixed, no data will be saved into the DB
         even if the answer is 'Y'.

Step  7: does a) listed above
         The output can be found in the created logfile DataAnalysis_DEF6668_Find_contracts_without_bank_accounts.log

Step  8: When script has finished: 
         check the generated logfile DataAnalysis_DEF6668_Find_contracts_without_bank_accounts.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.