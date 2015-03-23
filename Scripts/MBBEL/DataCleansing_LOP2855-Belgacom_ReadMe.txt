===========================================================================
= SIRIUS Service-Script for Relinet Ticket LOP-2855                       =
===========================================================================

Date         : 27.02.2014
Author       : Markus Zimmerberger / FraBe

Preconditions: 
1) store DataCleansing_LOP2855-Belgacom.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher
3) the script is especially designed for a MBBeLux DB only

===========================================================================
= Description                                                             =
===========================================================================

  a) checks for existence of customer 00002670001
     -> if not existing: script abortes
  b) checks for existence of package INSTALL_SUP
     -> if not existing: script abortes
  c) replace customer 00000013001 by 00002670001 for the 2 contracts 048519 and 044177
  d) add package INSTALL_SUP to both contracts

Please note: these 2 contracts 
- will be exported during execution of I55(72) export with the new data.
- have the new customers within the next SCARF Vehicle(75)
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

Step  5: SQL> @DataCleansing_LOP2855-Belgacom.sql

         I) As the script is designed for a MBBeLux DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode)
         
         Please note: 'Y' saves data into the DB only if ALL contracts can be fixed.
         If at least one contract cannot be fixed, no data will be saved into the DB
         even if the answer is 'Y'.

Step  7: does a) to d) listed above
         The output can be found in the created logfile DataCleansing_LOP2855-Belgacom.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2855-Belgacom.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.