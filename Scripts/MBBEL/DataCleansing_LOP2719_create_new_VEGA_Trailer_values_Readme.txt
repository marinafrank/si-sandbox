===========================================================================
= SIRIUS Service-Script for LOP-2719		                          =
===========================================================================

Date         : 13.03.2014
Author       : Marco Zuhl

Preconditions: 
1) store DataCleansing_LOP2719_create_new_Vega_Trailer_values.sql into your working directory
2) <additional:> the version of your SIRIUS DB must be <2.n.n> or higher
3) the script is especially designed for a <MBBEL> DB only

===========================================================================
= Description                                                             =
===========================================================================

< a) remove the old VEGA-values
  b) set up the new extended values
  c) update/enhance the translation table for/with the new values >

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump before executing the script.
      
Step  2: Open command window

Step  3: Go to your working folder

Step  4: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         In this case the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2719_create_new_Vega_Trailer_values.sql
         The output can be found in the created logfile DataCleansing_LOP2719_create_new_Vega_Trailer_values.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2719_create_new_Vega_Trailer_values.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.