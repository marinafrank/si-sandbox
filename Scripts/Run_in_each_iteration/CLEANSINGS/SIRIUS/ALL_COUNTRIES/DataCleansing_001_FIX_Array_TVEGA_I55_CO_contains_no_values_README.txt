===========================================================================
= SIRIUS Service-Script                                                   =
===========================================================================

Date         : 4.9.2014
Author       : Markus Zimmerberger

Preconditions: 
1) store DataCleansing_LOPXXXX_-_FIX_Array_TVEGA_I55_CO_contains_no_values.sql into your working directory
2) the version of your SIRIUS DB must be 2.8. or higher
3) the script designed for all sirius-markets

===========================================================================
= Description                                                             =
===========================================================================

  a) search contracts without contract-driven VEGA-attributes
  b) assign default VEGA-attributes to these contracts
  
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

Step  5: SQL> @DataCleansing_LOPXXXX_-_FIX_Array_TVEGA_I55_CO_contains_no_values.sql

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  7: does a) to b) listed above
         The output can be found in the created logfile DataCleansing_LOPXXXX_-_FIX_Array_TVEGA_I55_CO_contains_no_values.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOPXXXX_-_FIX_Array_TVEGA_I55_CO_contains_no_values.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.