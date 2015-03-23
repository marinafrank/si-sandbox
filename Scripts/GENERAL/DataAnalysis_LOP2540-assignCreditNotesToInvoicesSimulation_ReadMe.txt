===========================================================================
= SIRIUS Service-Script for iCON Ticket LOP2540                           =
===========================================================================

Date         : 05.03.2014
Author       : FraBe

Preconditions: 
1) store DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.sql into your working directory
2) the version of your SIRIUS DB must be 2.7.0 or higher

===========================================================================
= Description                                                             =
===========================================================================

This script tries to find a Workshop Invoice ( -> INV ) for Workshop CreditNotes (-> CN ) which are not related to any Workshop Invoice yet using 2 SEARCH_TYPE routines:
'1': the CN and INV have the same ID_VERTRAG / ID_FZGVERTRAG / FZGRE_LAUFSTRECKE (-> mileage ) / FZGRE_REPDATUM (-> RepairDate )
'2': the CN and INV have the same ID_VERTRAG / ID_FZGVERTRAG / and the INV - FZGRE_BELEGNR (-> DocumentNumber ) can be found in CN - FZGRE_MEMO (-> memo )
     but only complete number matches e.g. DocumentNumber 12345 in MemoField 'agfsfqwew 12345' 
     but no DocumentNumber 123 in the same MemoFiled (-> this DocumentNumber ist only part of the whole number )

These 2 types are split into 3 subtypes (- the 1st char is the main SEARCH_TYPE, the chars after the 2nd char '-' are the subtypes. e.g: 1-0 or 2-I or 1-III )
0:    Gutfall:          exact 1 INV can be found for the CN
I:    Schlechtfall I:   more than 1 INV can be found for the CN
II:   Schlechtfall II:  exact 1 INV can be found for more than 1 CN
III:  Schlechtfall III: more than 1 INV were found for more than 1 CN

Additional main search SEARCH_TYPE routines without any subtype:
'3':  the INV found for the CN using SEARCH_TYPE = '1' differ to those of SEARCH_TYPE = '2'
'4':  no INV could be found for the CN

Therefore following sections exist in the created listfile:
1-0:   For one CN exact one INV was found with same Mileage and RepairDate
2-0:   For one CN exact one INV was found acording invoicenumber in the CN memofield
1-I:   For one CN more than one INV was found with same Mileage and RepairDate
2-I:   For one CN more than one INV was found acording invoicenumber in the CN memofield
1-II:  For CNs exact one INV was found with same Mileage and RepairDate
2-II:  For CNs exact one INV was found acording invoicenumber in the CN memofield
1-III: For CNs more than one INV was found with same Mileage and RepairDate
2-III: For CNs more than one INV was found acording invoicenumber in the CN memofield
3:     These INV are proposed different in 1 and 2
4:     For these CN no matching INV could be found

A) only CN / INV of InScope contracts are considered
B) only INV which are not totally accepted are proposed

===========================================================================
= To do´s                                                                 =
===========================================================================

Step  1: Open commdand window

Step  2: Go to your working folder

Step  3: Start sqlplus as user snt
         If you start it with another user you will get following error message: 

         Executing user is not SNT
         For a correct use of this script, executing user must be SNT
         
         If the version of your SIRIUS DB is lower than 2.7.0 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.7.0
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  4: SQL> @DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.sql

Step  5: does a) to c) listed above
         2 output are created: 
         - logfile  DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.log
         - listfile DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.lst with the proposals described above
         
Step  6: When script has finished: 
         check the generated log- and listfile DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.log / 
         DataAnalysis_LOP2540-assignCreditNotesToInvoicesSimulation.lst if any ORA- or SP2- error has occured.

         If yes please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.