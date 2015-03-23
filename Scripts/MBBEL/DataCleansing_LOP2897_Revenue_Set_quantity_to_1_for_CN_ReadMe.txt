=============================================================================================
= SIRIUS Service-Script for DataCleansing_LOP2897_Revenue_Set_quantity_to_1_for_CN          =
=============================================================================================

Date         : 14.05.2014
Author       : CPauzen

Preconditions: 
1) store DataCleansing_LOP2897_Revenue_Set_quantity_to_1_for_CN.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.1 or higher
3) the script is especially designed for a MBBEL DB only

===========================================================================
= Description                                                             =
===========================================================================

Correct cip_quantity to :=1 for  
this customerinvoices with GUID_CI

7D9B1487000441F583B58D15EE0BFD93
8AFA065DC3F64F0EB8D91C245A038485
B585869DEC664194B585894C76EA4B21
CCCBF596D7274F6195A0423E84158C4A
F776D592F8E34CB785E824B4C76B9098
  
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
         
         If the version of your SIRIUS DB is lower than 2.8.1 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.1
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2897_Revenue_Set_quantity_to_1_for_CN.sql

         As the script is designed for a MBBEL DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBEL DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==
         
Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )
         
         Please note: 'Y' saves data into the DB only if point a) of script description above is not true 
         If at least one CO / CI was already sent to a 3rd party system no data will be saved into the DB
         even if the answer is 'Y'.

Step  7: does a) to b) listed above
         The output can be found in the created logfile DataCleansing_LOP2897_Revenue_Set_quantity_to_1_for_CN.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2897_Revenue_Set_quantity_to_1_for_CN.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.