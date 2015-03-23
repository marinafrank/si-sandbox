===========================================================================
= SIRIUS Service-Script for iCON support Ticket LOP2215 / MKS-129019      =
===========================================================================

Date         : 25.10.2013
Author       : FraBe

Preconditions: 
1) store DataAnalysis_LOP2215-Multiple_Customers_in_one_customer_contract.sql 
   into your working directory
2) <additional:> the version of your SIRIUS DB must be 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

List of all customers (- inkl. customer matchcode -) with more than one 
InScope vehicle contract duration

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

Step  4: SQL> @DataAnalysis_LOP2215-Multiple_Customers_in_one_customer_contract.sql

Step  5: does action described above
         The output can be found in the created logfile DataAnalysis_LOP2215-Multiple_Customers_in_one_customer_contract.log

Step  6: When script has finished: 
         check the generated logfile DataAnalysis_LOP2215-Multiple_Customers_in_one_customer_contract.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.