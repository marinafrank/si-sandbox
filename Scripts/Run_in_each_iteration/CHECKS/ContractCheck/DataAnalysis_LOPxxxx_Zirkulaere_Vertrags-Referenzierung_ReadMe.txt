===========================================================================
= iCON DataAnalysis-Script for circular contract referencies              =
===========================================================================

Date         : 10.12.2014
Author       : FraBe

Preconditions: 
1) store DataAnalysis_LOPxxxx_Zirkulaere_Vertrags-Referenzierung.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.1 or higher

===========================================================================
= Description                                                             =
===========================================================================

perorts all InScope and OutScope contracts with circular contract referencies
(- if e.g. contract 1/1 refers to 2/2, but last contract refers to the 1st one -)
  
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

Step  4: SQL> @DataAnalysis_LOPxxxx_Zirkulaere_Vertrags-Referenzierung.sql

Step  5: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: as only CO are listed but not changed / deleted or added:
         'N' does nothing - only reports the message rollback into the logfile.
         'Y' does not / cannot commit any new / changed or deleted CO.
             But it logs the execution of the script in the SIRIUS log

Step  6: does action described above
         The output can be found in the created logfile DataAnalysis_LOPxxxx_Zirkulaere_Vertrags-Referenzierung.log

Step  7: When script has finished: 
         check the generated logfile DataAnalysis_LOPxxxx_Zirkulaere_Vertrags-Referenzierung.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.