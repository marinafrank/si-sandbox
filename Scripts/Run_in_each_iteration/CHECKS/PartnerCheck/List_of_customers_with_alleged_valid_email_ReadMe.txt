===========================================================================
= SIRIUS Spool-Script for MKS-120603                                      =
===========================================================================

Date         : 11.12.2012
Author       : FraBe

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools PrivateCustomer and commercialCustomer with filled email field but 
containing no "@"-character

Following data is spooled:
- customer-id
- email

Only Customers which are not marked OutOfScope are reported.
===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @List_of_customers_with_alleged_valid_email.sql

Step 7:  check the generated log file 
         List_of_customers_with_alleged_valid_email.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.