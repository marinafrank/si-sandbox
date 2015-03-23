===========================================================================
= SIRIUS Service-Script for LOP2891 add OTHERS_SERV to DHL_ES Contracts   =
===========================================================================

Date         : 2014-04-23
Author       : Marco Zuhl / Tobias Kieninger

Preconditions: 
a) store DataCleansing_LOP2891_Add_OTHER_SERV_attribute_package_to_DHL_ES_contracts.sql into your working directory
b) the version of your SIRIUS DB must be 2.8.1 or higher


===========================================================================
= Description                                                             =
===========================================================================

This script assigns an existing Attribute package "OTHERS_SERV" to all
contracts with ID_VERTRAG='DHL_ES'
  
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
         
         If the version of your SIRIUS DB is lower than 2.8.1 you also get an error message:
         
         DB Version is incorrect!
         Current version is <your SIRIUS DB version>, but version must be same or higher than 2.8.1
         
         Within both cases the execution of the script is aborted:
         ==> Script Execution cancelled <==

Step  5: SQL> @DataCleansing_LOP2891_Add_OTHER_SERV_attribute_package_to_DHL_ES_contracts.sql


Step  6: Answer Y or N within question: Do you want to save the changes to the DB?
         which is shown on the screen (-> simulation mode )

Step  7: Assigns an existing Attribute package "OTHERS_SERV" to all contracts with ID_VERTRAG='DHL_ES'
         The output can be found in the created logfile DataCleansing_LOP2891_Add_OTHER_SERV_attribute_package_to_DHL_ES_contracts.log

Step  8: When script has finished: 
         check the generated logfile DataCleansing_LOP2891_Add_OTHER_SERV_attribute_package_to_DHL_ES_contracts.log 

         If the attribute package was not existing, the script cancelles without any change but with an error message.
         If the attribute package is already assigned to an vehicle contracts, the script will create a warning but do not assign it twice.
         if any ORA- or SP2- error has occured please contact the SIRIUS technical support team @Ulm. 
         
For questions and feedback please contact the SIRIUS technical support team @Ulm.