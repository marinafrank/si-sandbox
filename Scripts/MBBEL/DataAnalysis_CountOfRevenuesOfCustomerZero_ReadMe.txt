===========================================================================
= SIRIUS Check-Script DataAnalysis_CountOfRevenuesOfCustomerZero                                       =
===========================================================================

Date         : 26.06.2013
Author       : cPauzen 

Precondition : store DataAnalysis_CountOfRevenuesOfCustomerZero.sql 
               
===========================================================================
= Description                                                             =
===========================================================================

selects all revenue objects related to customer 0 or 00000000000.
columns: CustomerID, CI_DOCUMENT_NUMBER, CI_DATE, CI_AMOUNT

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt

Step  4: SQL> @DataAnalysis_CountOfRevenuesOfCustomerZero.sql

Step  5: creates the report.
         The output can be found in the created logfile DataAnalysis_CountOfRevenuesOfCustomerZero.lst

Step  6: When the script has finished: check the generated logfile 
         CustomerInvoiceCustomerIdIs0.lst for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.