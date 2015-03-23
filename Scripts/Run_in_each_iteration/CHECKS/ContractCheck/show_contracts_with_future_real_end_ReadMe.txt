===========================================================================
= SIRIUS Spool-Script for MKS-119329                                      =
===========================================================================

Date         : 29.10.2012
Author       : M. Zimmerberger

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools active contracts with future real end-date.

===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @show_contracts_with_future_real_end.sql

Step 7:  check the generated log file 
         show_contracts_with_future_real_end.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.