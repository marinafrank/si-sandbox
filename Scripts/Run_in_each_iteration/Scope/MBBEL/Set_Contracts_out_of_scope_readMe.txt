===========================================================================
= SIRIUS Support Script for LOP2735                                       =
===========================================================================

Date         : 27.11.2012 / 11.12.2012 / 12.03.2013 / 24.07.2013 / 05.09.2013 / 19.12.2013
Author       : FraBe

Precondition : store 20131219_Set-Contracts-out-of-scope_V6.0.sql in your working folder


===========================================================================
= Description                                                             =
===========================================================================

a) Creates new MIG_OOS contract variants with flag do not send to SCARF 
   -> OutOfScope
b) Changes all inactive contracts with a begin date less than the entered 
   OutOfScope date to the new contract variants created in step above
   Inactive contracts means: 
   - all contarcts with a contract state statistic code not equal to 00, 01 or 02
   - which do not have a SP Collective Invoice of an InScope SP - Supplier
c) Changes all cancelled contracts always to OutOfScope even if their begin 
   date is after the entered OutOfScope date.
   Cancelled contracts means: all contarcts with a contract state statistic 
   equal to 10
d) Changes all IMOs ( Industriemotoren (-> ID fahrzeugart = 20 )) always to OutOfScope 
e) Changes all Buses (-> Businessarealevel2 = 'Buses' ) always to OutOfScope

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump before executing the script.
      
Step  2: Open commdand window

Step  3: Go to your working folder

Step  4: Start sqlplus as user snt
         if you start it with another user you will get following error  
         message and execution of script is aborted:

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         Script aborted .... 

Step  5: SQL> @20131219_Set-Contracts-out-of-scope_V6.0.sql

Step  6: specify a date within question: 
         All inactive Contracts which started earlier than this date will be set to OutOfScope DD.MM.YYYY
         which is shown on the screen

Step  7: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  8: does a) to e) listed above
         The output can be found in the created logfile 20131219_Set-Contracts-out-of-scope_V6.0.log
        
Step  9: When script has finished: check the generated log file 20131219_Set-Contracts-out-of-scope_V6.0.log 
         for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.