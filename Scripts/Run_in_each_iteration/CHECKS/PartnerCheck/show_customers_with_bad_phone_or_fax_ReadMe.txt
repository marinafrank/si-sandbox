===========================================================================
= SIRIUS Spool-Script for MKS-120602                                      =
===========================================================================

Date         : 10.12.2012
Author       : M. Zimmerberger

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools PrivateCustomer and commercialCustomer with too long (>15) 
or "GSM" in phone or fax.

Following data is spooled:
- customer-id
- phone
- fax

Only Customers which are not marked OutOfScope are reported.
===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @show_customers_with_bad_phone_or_fax.sql

Step 7:  check the generated log file 
         show_customers_with_bad_phone_or_fax.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.