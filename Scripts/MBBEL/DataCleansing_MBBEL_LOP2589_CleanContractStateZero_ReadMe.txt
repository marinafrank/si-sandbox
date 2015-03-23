===========================================================================
= SIRIUS Check-Script DataCleansing_CleanContractStateZero                =
===========================================================================

Date         : 02.07.2013
Author       : M. Zimmerberger
Version	     : 1.0

Precondition : store DataCleansing_MBBEL_LOP2589_CleanContractStateZero.sql

===========================================================================
= Description                                                             =
===========================================================================

selects all contracts that are using ID_COS 0 and if none, deletes ID_COS 0

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus /nolog

Step  4: SQL> @DataCleansing_CleanContractStateZero.sql 

Step  5: creates the report.
         The output can be found in the created logfile DataCleansing_MBBEL_LOP2589_CleanContractStateZero

Step  6: When the script has finished: check the generated logfile 
         DataAnalysis_CampaignRevenueAssignment.lst for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.