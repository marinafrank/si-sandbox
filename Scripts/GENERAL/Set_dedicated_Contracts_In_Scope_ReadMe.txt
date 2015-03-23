===========================================================================
= iCON Service-Script for changing contract Scope flag                    =
===========================================================================

Date         : 16.12.2014
Author       : FraBe

Preconditions: 
1) store Set_dedicated_Contracts_In_Scope.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

A) Check if SiMEx table TCONTRACTS_IN_SCOPE contains any contracts
   The table consists of 2 columns: ID_VERTRAG and ID_FZGVERTRAG
   If not: Script reports an data error and aborts itself
   If yes: Script continues with next step
B) Check if all needed OutScope contract variants are already existing
   if not: create them
C) Change all  InScope contracts to OutScope which are not defined in SiMEx table TCONTRACTS_IN_SCOPE 
D) Change all OutScope contracts to  INScope which are     defined in SiMEx table TCONTRACTS_IN_SCOPE if
   a) the contract in SiMEx table TCONTRACTS_IN_SCOPE also exist in SIRIUS (-> ID_VERTRAG and ID_FZGVERTRAG ) 
      if not: report a warning for these contracts
   b) and the OutScope contract variant does not start with MIG_OOS_BYINT 
      -> report a warning for these contracts
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump of the SIRIUS DB to which the SiMEx DB Link points 
         before executing the script.
      
Step  2: Open commdand window

Step  3: Go to your working folder

Step  4: Start sqlplus as user SIMEX
         If you start it with another user you will get following error message: 

         Executing user is not SIMEX
         For a correct use of this script, executing user must be SIMEX
         
         If the version of your SIRIUS DB is lower than 2.8.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @Set_dedicated_Contracts_In_Scope.sql

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: 'Y' saves data into the DB only if no system error occured during script execution.
         If at least one system error occured no data will be saved into the DB even if the answer is 'Y'.

Step  7: does A) to D) listed above
         The output can be found in the created logfile Set_dedicated_Contracts_In_Scope.log

Step  8: When script has finished: 
         check the generated logfile Set_dedicated_Contracts_In_Scope.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.