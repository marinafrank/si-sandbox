============================================================================
= SIRIUS iCON Check Script for DataAnalysis_LOP2145-IdentifyDuplicates.sql =
============================================================================

Date         : 30.10.2012 / 09.09.2013 / 16.10.2013
Author       : FraBe

Precondition : store File DataAnalysis_LOP2145-IdentifyDuplicates.sql in your working folder

===========================================================================
= Description                                                             =
===========================================================================

Checks the DB against possible 
- NAME
- SREET
- CoFiCo Debitor#
- CoFiCo Creditor#
- UID
duplicates.

4 files are created:
1) DataAnalysis_LOP2145-IdentifyDuplicates.log              -> For messages during script execution
2) DataAnalysis_LOP2145-IdentifyDuplicates.txt              -> The possible duplicates are well prepared for each
                                                               of the 5 sort and group by criterias listed above
                                                               And each duplicates block is separated by a hyphenline
3) DataAnalysis_LOP2145-IdentifyDuplicates_csv.txt          -> almost the same as 2) but without hyphenline for loading
                                                               into Excel to do e.g. manual sort / filter
4) DataAnalysis_LOP2145-IdentifyDuplicates_distinct_csv.txt -> distinct data without the group by criterias also
                                                               prepared for laoding into Excel

The last 3 columns ID_SEQ_ADRASSOZ / ID_SEQ_NAME / ID_SEQ_ADRESS of file 2) 
to 4) are for internal use only.

===========================================================================
= To do´s                                                                 =
===========================================================================

Step 1:  open commdand window

Step 2:  go to your working folder

Step 3:  start sqlplus as user snt

Step 4:  SQL > @DataAnalysis_LOP2145-IdentifyDuplicates.sql

Step 5:  check the generated log file DataAnalysis_LOP2145-IdentifyDuplicates.log in your working folder 
         for ORA- and SP2-  entries. 
         In case of this entries please contact the SIRIUS technical support.
         If file doesn't contain any text everything is ok.

Step 6:  check the possible duplicates which were found in the 3 other files 
         created by the script during execution 
         (- the content of these files is described above -): 
         DataAnalysis_LOP2145-IdentifyDuplicates.txt
         DataAnalysis_LOP2145-IdentifyDuplicates_csv.txt
         DataAnalysis_LOP2145-IdentifyDuplicates_distinct_csv.txt

For questions and feedback please also contact the SIRIUS technical support.
