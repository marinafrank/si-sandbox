===========================================================================
= SIRIUS Check-Script Campaigns - Analysis                                       =
===========================================================================

Date         : 25.05.2013
Author       : cPauzen 

Precondition : store DataAnalysis_CampaignRevenueAssignment.sql
               
===========================================================================
= Description                                                             =
===========================================================================

selects all Campaigns - with or without revenue assignment

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus /nolog

Step  4: SQL> @DataAnalysis_CampaignRevenueAssignment.sql

Step  5: creates the report.
         The output can be found in the created logfile DataAnalysis_CampaignRevenueAssignment.lst

Step  6: When the script has finished: check the generated logfile 
         DataAnalysis_CampaignRevenueAssignment.lst for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.