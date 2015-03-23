===========================================================================
= SIRIUS Spool-Script for MKS-121291                                      =
===========================================================================

Date         : 28.12.2012
Author       : FraBe

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Reports all PrivateCustomer and commercialCustomer which have a postal 
phone number different to the fiscal phone number.

Please note:
a) The algorithm which is used for finding the deviations does not consider 
alpha signs and special chars.
That means: if the value of the postal phone number is e.g 0680 / 123 - 90 15
and the value of the fiscal one is 06801239015 both numbers are not reported 
as different as only the alfa and special signs of both values differ, 
but not the digits and their sequence.

b) Only Customers which are not marked OutOfScope are reported.
===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @show_customers_with_second_phoneNumber_in_postalAdress.sql

Step 5:  check the generated log file 
         show_customers_with_second_phoneNumber_in_postalAdress.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.