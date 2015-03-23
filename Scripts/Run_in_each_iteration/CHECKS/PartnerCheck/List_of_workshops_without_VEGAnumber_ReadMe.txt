===========================================================================
= SIRIUS Spool-Script for MKS-122926                                      =
===========================================================================

Date         : 11.03.2013
Author       : FraBe

Precondition : sirius 2.8.1 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools all workshops without a VEGA number

===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @List_of_workshops_without_VEGAnumber.sql

Step 7:  check the generated log file 
         List_of_workshops_without_VEGAnumber.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.