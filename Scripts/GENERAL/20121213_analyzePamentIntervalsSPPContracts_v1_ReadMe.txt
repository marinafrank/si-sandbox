===========================================================================
= SIRIUS Check-Script for EDF - CIM                                       =
===========================================================================

Date         : 13.12.2012
Author       : FraBe

Precondition : store 20121213_analyzePamentIntervalsSPPContracts_v1.0.sql
               
===========================================================================
= Description                                                             =
===========================================================================

selects 
- Contract/vehicle# 
- Internal/External-ID 
- SPP Type
- ID and Matchcode of ServiceProvider 
of all ServiceProvider contrats 

point of interrest: SPP Type MF / RP / SI
 
Within this script it isn' t possible to connect to a single DB.
Instead this script connects automatically to the following 13 tst DBs:
MBOE.S415MT216.tst
MBBEL.S415MT216.tst
MBCH.S415MT216.tst
MBCZ.S415VM122.tst
MBE.S415B017.tst
MBF.S415B017.tst
MBI.S415MT216.tst
MBNL.S415B017.tst
MBP.S415B017.tst
MBPL.S415VM122.tst
MBSA.S415MT216.tst
MBR.S415VM185.tst
MBCL.S415VM445.tst

The script reports contracts which are not marked OutOfScope only.
===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus /nolog

Step  4: SQL> @20121213_analyzePamentIntervalsSPPContracts_v1.sql

Step  5: creates the report.
         The output can be found in the created logfile 20121213_analyzePamentIntervalsSPPContracts_v1.lst

Step  7: When the script has finished: check the generated logfile 
         20121213_analyzePamentIntervalsSPPContracts_v1.lst for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.