===========================================================================
= SIRIUS Support Script for LOP2215                                       =
===========================================================================

Date         : 30.10.2013
Author       : FraBe

Preconditions: 
1) store DataCleansing_LOP2215-ContractRenumbering.sql in your working folder
2) the version of your SIRIUS DB must be 2.8.0 or higher
3) the script is especially designed for a MBBeLux DB only

===========================================================================
= Description                                                             =
===========================================================================

Changes the ID_VERTRAG / ID_FZGVERTRAG of 3739 contracts to new values which were sent by MBBEL.

Please note:
this perhaps interferes following systems to which SIRIUS sends data:
1) VEGA: when the next I55(72) export is executed only the new values are sent.
   But no info, that the old numbers have changed.
   That means: VEGA still 'think' the old numbers are still existing in SIRIUS
2) SCARF: when the SCARF Invoices(74) and SCARF Vehicle(75) exports are executed the next time 
   the data of all contracts is exported. 
   -> I think that SCARF perhaps does not know anything about the old contract numbers anymore.
3) SAP: as the 3 SAP Exports Workshop(35) / Debit(36) / and FWD(38) are journal exports
   where the data is sent once only and not a 2nd time again, SAP 
   - still knows about the old contract numbers
   - but does not know anything about the new ones
4) Same as 3) within MBI Export SAP Customer Master Data(83)

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Create a dump before executing the script.
      
Step  2: Open commdand window

Step  3: Go to your working folder

Step  4: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         Additional: If the version of your SIRIUS DB is lower than 2.8.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2215-ContractRenumbering.sql

         I) As the script is designed for a MBBeLux DB only following errormessage will be reported
         if it is executed aganst another DB:
         
         This script can be executed against a MBBeLux DB only.
         You are executing it against a <DB name> DB.
         ==> Script Execution cancelled <==
         
         II) The script cannot be executed again when the question in next step was answered with 'Y'.
         As then the old data is already changed to the new one.
         If someone tries to execute it once more following errormessage is reported:
         
         This script was already executed on DD.MM.YYYY HH:MI:SS
         It cannot be executed a 2nd time!
         ==> Script Execution cancelled <==

Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

         Please note: 
         I)  'Y' saves data into the DB only if ID_VERTRAG and ID_FZGVERTRAG of ALL found contracts can be changed.
             If at least the update of one contract fails, no data will be saved into the DB even if the answer is 'Y'.
         II) 'Y' saves data into the DB if only messages are reported like
             'Contract <ID_VERTRAG_OLD/ID_FZGVERTRAG_OLD> could not be updated to <ID_VERTRAG_NEW/ID_FZGVERTRAG_NEW> because not found'

Step  7: Does action described above.
         The output can be found in the created logfile DataCleansing_LOP2215-ContractRenumbering.log
        
Step  8: When script has finished: check the generated log file DataCleansing_LOP2215-ContractRenumbering.log 
         for ORA- and SP2- entries. 
         If at least one occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.