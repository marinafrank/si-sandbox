===========================================================================
= SIRIUS Check-Script DataAnalysis_LOP2362_FixedIndexationWithoutRate     =
===========================================================================

Date         : 17.07.2013
Author       : cPauzen / FraBe

Precondition : store DataAnalysis_LOP2362_FixedIndexationWithoutRate.sql 
               
===========================================================================
= Description                                                             =
===========================================================================

selects all contracts: 
a) - in scope 
   - with indexvariant = fest
   - with missing index percentage
   - where the last contract prices ends before preliminary end date of last 
     contract duration / or final end date if already existing
b) listed columns:
   - contract and vehiclenumber
   - caption of contract variant
   - preliminary end date of last contract duration / or final end date if already existing
   - caption of indexvariant:       its value is always fest as only those are exported
   - Fix index percentage contract: its value is always 0    as only those are exported
   - Preisranges with price price begin and end date and ct/km and MP
   - value 1 as EndStat which means that the last price ends before preliminary end date of last 
     contract duration / or final end date if already existing

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus /nolog

Step  4: SQL> @DataAnalysis_LOP2362_FixedIndexationWithoutRate.sql

Step  5: creates the report.
         The output can be found in the created logfile DataAnalysis_LOP2362_FixedIndexationWithoutRate.lst

Step  6: When the script has finished: check the generated logfile 
         DataAnalysis_LOP2362_FixedIndexationWithoutRate.lst for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.