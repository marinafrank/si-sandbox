===========================================================================
= SIRIUS Spool-Script for MKS-120599                                      =
===========================================================================

Date         : 11.12.2012
Author       : FraBe

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools all PrivateCustomer and commercialCustomer without a salutation

Only Customers which are not marked OutOfScope are reported.
===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @List_of_customers_with_empty_salutation.sql

Step 7:  check the generated log file 
         List_of_customers_with_empty_salutation.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.