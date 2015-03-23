===========================================================================
= iCON DataAnalysis Script for Amount of new and changing objects         =
===========================================================================

Date         : 25.11.2014
Author       : FraBe

Preconditions: 
1) store DataAnalysis_DEF-XXXX_Amount_of_changing_objects.sql into your working directory
2) the version of your SIRIUS DB must be 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

reports following objects which are new / were changed the past <defined by the user> days:

- Partners: CommCust / PrivCust / Supplier / ContactPerson / Workshop/Dealer, but no SalesMan
- VehicleContracts
- COST
- COST-Collective INV/CN
- Revenue
- Odometer

please note:
1) DataMart creation and update date EXT_CREATION_DATE / EXT_UPDATE_DATE is taken to identify new or changed 
   (- as this date exists within all objects listed above, and SIRIUS does not have a creation update date there like CI_CREATED or CI_UPDATED -)
2) within VehicleContracts also duration are checked:
   a new duration is classifed as new even if its VehicleContract was already existing before the past <defined by the user> days
3) within COST and COST-Collective INV/CN and Revenue:
   - classified as new are only new header rows, but not their position (- as not necessary -)
   - classified as a change:
     also position changes are considered, and not only header changes.
     plus all new position rows if their header creation date is before the past <defined by the user> days
4) if you do not specify a value for time-delta (in days, as a command-line parameter), 30 is used as default

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

Step  4: SQL> @DataAnalysis_DEF-XXXX_Amount_of_changing_objects.sql 100
         (where 100 is the value of time-delta in days)

Step  5: Define a value greater 0 within question: report objects which are created or changed the past xy days
         
Step  6: creates the report described above
         The output can be found in the created logfile DataAnalysis_DEF-XXXX_Amount_of_changing_objects.log

Step  7: When script has finished: 
         check the generated logfile DataAnalysis_DEF-XXXX_Amount_of_changing_objects.log if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.