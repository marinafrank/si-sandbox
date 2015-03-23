===========================================================================
= SIRIUS Check-Script for EDF - CIM                                       =
===========================================================================

Date         : 15.01.2014
Author       : TKIENIN

Precondition : Run on a scoped database
               
===========================================================================
= Description                                                             =
===========================================================================

This script Extract Export 74 and 75 (SCARF Invoice & SCARF Vehicle) two times
First export pair is a normal export (which is Scoped if run on a scoped database)
After Export, the Contract variants are changed. Only Contract variants
starting with MIG_OOS are now set to SCARF relevant, if their inScope 
reference was also SCARF relevant before.
Then a second pair of Exports is started .
(which causes an empty export on a non-scoped database)

After export, the contract variants are restored as they were before executing the script.

! This script disables the SSE Export job during run. !
! If an SSE Export was queried during runtime of this script, it will be executed as
! normal, but triggered by this script call and not by SSE.

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open command window

Step  2: Go to your working folder

Step  3: Start sqlplus /nolog

Step  4: SQL> DataAnalysis_LOP2827-SCARFexport.sql

Step  5: creates the report.
         The logfile can be found in the created DataAnalysis_LOP2827-SCARFexport.log
         The exports are stored in the defualt Export Outbox of the database.

Step  7: When the script has finished: check the generated logfile 
         DataAnalysis_LOP2827-SCARFexport.log for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 

! If the script cancelles because of "Icompatible Process": Wait until other processes 
! are finished and restart the script.
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.