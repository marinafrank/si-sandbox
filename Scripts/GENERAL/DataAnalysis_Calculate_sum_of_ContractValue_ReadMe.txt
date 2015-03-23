===========================================================================
= SIRIUS Service-Script for iCON LOOP ticket                              =
===========================================================================

Date         : 27.08.2014
Author       : FraBe

Preconditions: 
1) store DataAnalysis_Calculate_sum_of_ContractValue.sql into your working directory
2) additional: the version of your SIRIUS DB must be 2.8.0 or higher
3) this script only can be executed on a SIRIUS DB only / cannot be excuted on any SiMEx DB anymore

===========================================================================
= Description                                                             =
===========================================================================

Calculates the so called ContractValue of all inScope and outScope contracts

Please note: this script takes some time - even more than 10 minutes
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not snt
         For a correct use of this script, executing user must be snt
         
         If the version of SIRIUS DB is lower than 2.8.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  4: SQL> @DataAnalysis_Calculate_sum_of_ContractValue.sql

Step  5: Does action described above

Step  6: When script has finished:
         
         - Check on the screen if any ORA- or SP2- error has occured.
           If yes please contact the SIRIUS technical support team @Ulm.
         
         - No logfile is created - he result is shown on the screen only:
           Contract value of DB <name of the SIRIUS DB>:  <calcualted ContractValue of all CO of this DB>
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.