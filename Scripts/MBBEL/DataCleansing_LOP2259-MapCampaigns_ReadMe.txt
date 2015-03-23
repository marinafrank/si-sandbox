===========================================================================
= SIRIUS Dada Cleansing Script for LOP2259                                =
===========================================================================

Date         : 11.09.2013
Author       : FraBe

Preconditions: 
1) store DataCleansing_LOP2259-MapCampaigns.sql into your working directory
2) the version of your SIRIUS DB must be <2.8.0> or higher
3) the script is especially designed for a MBBEL DB only

===========================================================================
= Description                                                             =
===========================================================================

changes the ID Customer of the campaign customer invoices with value 0 to a real ID Customer <> 0
(- the concerned customer invoices were given by the MPC -)
  
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
         
         If the version of your SIRIUS DB is lower than <2.8.0> you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than <2.8.0>
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2259-MapCampaigns.sql

         As the script is designed for a MBBEL DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==
         
Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: 'Y' saves data into the DB only if ALL customer invoices and credit notes can be changed.
         If at least one invoice / credit note cannot be fixed, no data will be saved into the DB
         even if the answer is 'Y'.
         
Step  7: Does the changes described above.
         The output can be found in the created logfile DataCleansing_LOP2259-MapCampaigns.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2259-MapCampaigns.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.