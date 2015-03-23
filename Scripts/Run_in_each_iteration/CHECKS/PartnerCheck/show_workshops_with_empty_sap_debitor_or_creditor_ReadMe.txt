===========================================================================
= SIRIUS Spool-Script for MKS-122287 / 122286                             =
===========================================================================

Date         : 20.03.2013
Author       : FraBe

Precondition : sirius 2.8.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

Spools workshops with empty SAP Debtior No or SAP Creditor

Following data is spooled:
- workshop-id
- SAP Debitor No
- SAP Creditor No

===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @show_workshops_with_empty_sap_debitor_or_creditor.sql

Step 7:  check the generated log file 
         show_workshops_with_empty_sap_debitor_or_creditor.log in your working folder.
         If there are entries containing ORA- and SP2- please contact the
         SIRIUS technical support. 

For questions and feedback please also contact the SIRIUS technical support.