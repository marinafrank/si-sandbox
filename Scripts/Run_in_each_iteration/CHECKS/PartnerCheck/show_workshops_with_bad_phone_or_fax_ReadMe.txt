===========================================================================
= SIRIUS Spool-Script for MKS-122287                                      =
===========================================================================

Date         : 15.02.2013
Author       : FraBe

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools workshops with too long (>15) or "GSM" in phone or fax.

Following data is spooled:
- workshop-id
- phone
- fax

===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @show_workshops_with_bad_phone_or_fax.sql

Step 7:  check the generated log file 
         show_workshops_with_bad_phone_or_fax.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.