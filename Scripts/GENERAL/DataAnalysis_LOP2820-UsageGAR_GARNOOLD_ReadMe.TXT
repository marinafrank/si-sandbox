===========================================================================
= SIRIUS Service-Script for iCON Support ticket LOP2820 Analyse GAR_GARNOOLD =
===========================================================================

Date         : 28.01.2014
Author       : CPauzen

Preconditions: 
1) store DataAnalysis_LOP2820-UsageGAR_GARNOOLD.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher

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

Step  4: SQL> @DataAnalysis_LOP2820-UsageGAR_GARNOOLD.sql

Step  5: does action described above
         The output can be found in the created logfile DataAnalysis_LOP2820-UsageGAR_GARNOOLD.log

Step  6: When script has finished: 
         check the generated logfile DataAnalysis_LOP2820-UsageGAR_GARNOOLD.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.