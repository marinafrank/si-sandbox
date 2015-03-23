===========================================================================
= SIRIUS Service-Script for iCON Support ticket LOP2857 - Analyse workshop relations =
===========================================================================

Date         : 31.01.2014
Author       : CPauzen

Preconditions: 
1) store DataAnalysis_LOP2857-AnalyseWorkshopRelations.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher
3) the script is especially designed for a MBBeLux DB only
===========================================================================
= Description                                                             =
===========================================================================

reports all workshop with filled gar_garnoold.
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than 2.8.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  4: SQL> @DataAnalysis_LOP2857-AnalyseWorkshopRelations.sql

         As the script is designed for a MBBeLux DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==

Step  5: does action described above
         The output can be found in the created logfile DataAnalysis_LOP2857-AnalyseWorkshopRelations.log

Step  6: When script has finished: 
         check the generated logfile DataAnalysis_LOP2857-AnalyseWorkshopRelations.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.