===========================================================================
= SIRIUS Service-Script for iCON LOP2512                                  =
===========================================================================

Date         : 19.07.2013
Author       : FraBe

Preconditions: 
1) store DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.sql 
   into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

MBBEL provided TSS with a list of costs in foreign currencies instead of EUR, 
the currency of the country.

Theis recalculates them to EUR using the given currency exchange rate.
If at least one cost cannot be recalculated no data will be saved into the DB
even if the question
Do you want to save the changes to the DB? Y/N: 
which is shown at the beginning of the script is answered with 'Y'

There can be 3 messages within each cost:
- successfully converted ...
- Invoice not found ...       (-> this invoice in MBBEL list doesn't exist in the DB )
- These values don't fit ...  (-> the existing DB values are different to the ones in MBBEL list )
- These new values differ ... (-> the values don't fit after EUR recalculation )

Please note:
- This script can be executed against a MBBEL DB only - else following errormassage is displayed:
  This script can be executed against a MBBeLux only.
  You are executing it against a <MPC name> DB.
  and script is aborted.
- It isn't possible to execute this script once more if the question
  Do you want to save the changes to the DB? Y/N: 
  was answered with 'Y', and during recalculation no error occured.
  In such a case following errormessage is displayed:
  This script was already executed on <DD.MM.YYYY HH:MI:SS>
  It cannot be executed a 2nd time!
  and script is aborted.
  
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than <2.8.0> you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, , but version must be same or higher than <2.8.0>
         
         Within both cases the execution of the script is aborted.

Step  4: SQL> @DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.sql

Step  5: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  6: does the EUR recalculation described above
         The output can be found in the created logfile DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.log

Step  7: When script has finished: 
         check the generated logfile DataCleansing_MBBEL_LOP2512_CheckAmountOfCostInForeignCurrency.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.