===========================================================================
= SIRIUS Service-Script DEF6573                                           =
===========================================================================

Date         : 28.11.2014
Author       : ZBerger

Preconditions: 
1) store DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.1 or higher

===========================================================================
= Description                                                             =
===========================================================================

  a) checks and lists contracts formatted other than defined in dd_using
  b) checks and lists contract-doubles (formatted and unformatted)
  
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

Step  4: SQL> @DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets.sql

Step  5: does a) to b) listed above
         The output can be found in the created logfile DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets.log

Step  6: When script has finished: 
         check the generated logfile DataAnalysis_DEF6573_Find_invisible_contracts_or_doublets.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.