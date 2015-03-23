===========================================================================
= SIRIUS Support Script                                                   =
===========================================================================

Date         : 10.12.2012
Author       : FraBe

Precondition : 
1) execute script 20121210_Set-Contracts-out-of-scope_V2.0.sql as the script 
   of this task creCustMigCoutOfScope.sql is based on 20121210_Set-Contracts-out-of-scope_V2.0.sql 
2) store 20121210_Set-customer-out-of-scope-V1.0.sql in your working folder


===========================================================================
= Description                                                             =
===========================================================================

creates new MIG_OOS customer types for all customsers which have only 
OutOfScope contracts

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump before executing the script
      
Step  2: Open commdand window

Step  3: Go to your working folder

Step  4: Start sqlplus as user snt
         if you start it with another user you will get following error  
         message and execution of script is aborted:

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         Script aborted .... 

Step  5: SQL> @20121210_Set-customer-out-of-scope-V1.0.sql

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  7: does the actions described in Description above
         The output can be found in the created logfile 20121210_Set-customer-out-of-scope-V1.0.log
        

Step  9: When script has finished: check the generated log file 20121210_Set-customer-out-of-scope-V1.0.log 
         for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.
