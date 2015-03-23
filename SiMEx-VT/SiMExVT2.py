# -*- coding: utf-8 -*-
__author__ = 'MARZUHL'
# ####################################################
# BEGIN GLOBAL PARAMETERS
#####################################################

VERSION = "2.0"

#####################################################
# END GLOBAL PARAMETERS
#####################################################

#####################################################
# BEGINN CONSTRUCTION PARAMETERS
#####################################################

# Default values...
CONFIG_DICT = {
    "ENVIRONMENT": {
        "CONFIG_FILE": "config.ini"
        , "LOGFILE_ENDING": 'log'
        , "GLOBAL_LOGFILE": ""
        , "GLOBAL_OUTPUT": "SCREEN"
        , 'LOGGING': 'INFO'
        , 'PATH_TO_XMLS': ''
        , 'PATH_TO_XSD': ""
        , 'XML_ENDING': 'xml'
        , 'ORACLE_CONNECT_STRING_SIMEX': ''
        , 'ORACLE_CONNECT_STRING_DB': ''
        #, 'PATH_TO_XPATH_CONFIG': 'C:/mks/icon/7000_Delivery/7100_Shipments/Tools/'
        , 'PATH_TO_XPATH_CONFIG': ''
        , 'PATH_TO_LOGFILES': ''
        , 'NAME_XPATH_CONFIG': 'iCon-Validation.xml'
        , 'NAME_XSD': 'all.xsd'
        , 'CSV_ENDING': 'csv'
        , 'LOGFILE_PREFIX': ''
        , 'ENCODING_DB': 'latin-1'
        , "EXTRACTION_CHECK_INTERVAL": 1
        , "GARBAGECOLLECTORCOUNTER": 2000
        , "CHECKINTEGRITY": False
        , "PATH_TO_ZIPS": ""
        , "ZIPPING": True
        , "ZIP_ENDING": "zip"
        , "FIND_FILE": False
        , "EMAIL": "marco.zuhl@daimler.com"
        , "SMTP_SENDER": "marco.zuhl@daimler.com"
        , "SMTP_SERVER": "smtp.detss.corpintra.net"
        , "SMTP_PORT": 25
        , "LOGNAME_MAIN": "#*TIMESTAMP*#_MAIN"
        , "LOGNAME_EXTRACTION": "#*TIMESTAMP*#_EXTRACTION"
        , "LOGNAME_CHECKXSD": "#*TIMESTAMP*#_#*OBJECT*#_#*SUBOBJECT*#_XSD"
        , "LOGNAME_CHECKXPATH": "#*TIMESTAMP*#_#*OBJECT*#_#*SUBOBJECT*#_XPATH_#*LOGTYPE*#"
        , "LOGNAME_INTEGRITY": "#*TIMESTAMP*#_#*OBJECT*#_#*SUBOBJECT*#_INTEGRITY"
        , "LOGNAME_SEARCH": "#*TIMESTAMP*#_#*DEFECT*#_#*OBJECT*#_SEARCHRESULTS"
        , "LOGNAME_TIMESTAMP_FORMAT": "%Y%m%d_%H%M%S"
        , "LOGGING_TIMESTAMP_FORMAT": "%Y-%m-%d (%H:%M:%S)"
    }
    , 'EXTRACTION': {}
    , 'CHECKLIST': {}
}

ICON_VALIDATION_DICT = {
    "createCustomerContract": {
        "ServicecontractFull": {
            "ValidationXPath": "//blubb"
            , "ValidationSQL": "select blubb"
            , "ValidationIntegrity": {
            "OWNKEY": [
                {"NAME": "CustomerContractId"
                    , "XPATH": "//invocation/parameter/@externalId"
                }
                , {"NAME": "externalId2"
                    , "XPATH": "//invocation/parameter/@externalId"
                }
            ]
            , "REMOTEKEY": [
            {"NAME": "contractingCustomer"
                , "XPATH": "//invocation/parameter/contractingCustomer/@externalId"
                , "TYPE": "//invocation/parameter/contractingCustomer/@xsi:type"
                , "FK_CHECK": [
                {"partner_pl:PhysicalPersonType": [
                    "createOrganisationalPerson_privateCustomer_PartnerId"
                ]
                    , "partner_pl:OrganisationalPersonType": [
                    "createOrganisationalPerson_privateCustomer_PartnerId"
                    , "createOrganisationalPerson_privateCustomer_PartnerId"
                ]
                }
            ]
            }
        ]
        }
        }
    }
}

ICON_VALIDATION_DICT = {}

SEARCH_DICT = {
    "PHYSICALPERSON":{
        "DEF4711": ["1","2","3"]
        , "DEF4712": ["0815"]
    }
    , "ORGANISATIONALPERSON":{}
}

SEARCH_DICT = {}
# Needed as translation table
TRANSLATION_DICT = {
    "MigrationScopeListCustomer": {
        "NONE": {"VALIDATE": ["CSV"], "EXTRACT": "1", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "FinList": {
        "NONE": {"VALIDATE": ["createFinList"], "EXTRACT": "2", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "InventoryList": {
        "NONE": {"VALIDATE": ["CSV"], "EXTRACT": "3", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "PhysicalPerson": {
        "PrivateCustomer": {"VALIDATE": ["createPhysicalPerson", "updatePhysicalPerson"], "EXTRACT": "10", "STANDARD_EXPORT": True, "FILENAME": ["NONE", "UPDATE"]}
        , "ContactPerson": {"VALIDATE": ["createPhysicalPerson"], "EXTRACT": "11", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
        , "Salesman": {"VALIDATE": ["createPhysicalPerson"], "EXTRACT": "12", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "OrganisationalPerson": {
        "CommercialCustomer": {"VALIDATE": ["createOrganisationalPerson", "updateOrganisationalPerson"], "EXTRACT": "21", "STANDARD_EXPORT": True, "FILENAME": ["NONE", "UPDATE"]}
        , "Workshop": {"VALIDATE": ["createOrganisationalPerson"], "EXTRACT": "22", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
        , "Supplier": {"VALIDATE": ["createOrganisationalPerson"], "EXTRACT": "23", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
        , "Dealer": {"VALIDATE": ["createOrganisationalPerson"], "EXTRACT": "24", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "Odometer": {
        "NONE": {"VALIDATE": ["addOdometer"], "EXTRACT": "30", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "ServiceContract": {
        "FullServiceContract": {"VALIDATE": ["createCustomerContract"], "EXTRACT": "40", "STANDARD_EXPORT": False, "FILENAME": ["NONE"]}  # !!!
        , "CustomerContract": {"VALIDATE": ["createCustomerContract"], "EXTRACT": "41", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}  # !!!
    }
    , "VehicleContract": {
        "NONE": {"VALIDATE": ["createVehicleContract"], "EXTRACT": "42", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "Revenue": {
        "NONE": {"VALIDATE": ["createCustomerFinancialDocument"], "EXTRACT": "50", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "Cost": {
        "NONE": {"VALIDATE": ["createWorkshopFinancialDocument"], "EXTRACT": "60", "STANDARD_EXPORT": False, "FILENAME": ["NONE"]}
        , "FullCost": {"VALIDATE": ["createWorkshopFinancialDocument"], "EXTRACT": "61", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "CostCollective": {
        "NONE": {"VALIDATE": ["createCollectiveWorkshopFinancialDocument"], "EXTRACT": "70", "STANDARD_EXPORT": False, "FILENAME": ["NONE"]}
    }
    , "AssignCostToCost": {
        "NONE": {"VALIDATE": ["assignCostToCost"], "EXTRACT": "80", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "ModificationProtocolEntry": {
        "NONE": {"VALIDATE": ["createModificationProtocolEntry"], "EXTRACT": "90", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
    , "VegaMappingList": {
        "NONE": {"VALIDATE": ["CSV"], "EXTRACT": "901", "STANDARD_EXPORT": True, "FILENAME": ["NONE"]}
    }
}

EMAIL_DICT = {
    "TESTMAIL": """From: #*SMTP_SENDER*#
To: undisclosed_recipients
Subject: SMTP e-mail test
This is a test e-mail message.
"""
    , "EXTRACT_SUCCESSFULL": """From: #*SMTP_SENDER*#
To: undisclosed_recipients
Subject: Sirius iCon Migration: Object #*OBJECT_NAME*# extraction completed.
Dear reader,

The extraction of #*OBJECT_NAME*# has finished successfully. The results can be found at the usual place. File zipping was set to: #*ZIPPING*#.
"""

}

SQL_COMMAND_DICT = {
    "CHECK_EXTRACTABLE": "select tas_active from ttask where tas_order = #*TASK_ORDER*#"
    , "ACTIVATE_EXTRACTION": """declare
  l_taskguid varchar2(32);
  l_tas_caption TTASK.tas_caption%type;

begin
-- gather GUID
  select TAS_GUID, tas_caption
  into l_taskguid,l_tas_caption
  from ttask
  where tas_order = #*TASK_ORDER*#;

-- log task as "pending"
  insert into TTASK_HISTORY (TAS_GUID, TASH_STATE) VALUES (l_taskguid,0);
-- set "active" flag
  update ttask set tas_active = 1 where tas_guid = l_taskguid;
commit;
end;
"""

    , "CHECK_ACTIVE": """select
  (select nvl(max(TTASK.TAS_ACTIVE),-1) as ACTIVE from TTASK where TTASK.TAS_ACTIVE > 0) as "Activity"
  , (select nvl(max(TLOG.LOG_SEQUENCE),0) from TLOG)  as "Counter"
from dual"""

    , "LOGQUERY": """
    select distinct
  nvl(tlog.log_sequence,0) as SEQ
  ,ttask.tas_caption      as TaskName
  , tmessage.log_msg_text as MessageState
  , tlog.log_text         as Information
  , tlog.log_timestamp    as TimeInfo
  , ttask.tas_order       as TasOrder
from
  TLOG
  , TMESSAGE
  , TTASK
  , TTASK_HISTORY
where
  TTASK.TAS_GUID=TTASK_HISTORY.TAS_GUID
  and TTASK.TAS_GUID = TLOG.TAS_GUID
  and tlog.log_id = tmessage.log_id
  and tlog.log_sequence > #*REPLACEME*#
order by
  TimeInfo, SEQ
"""

    , "DUMPNAME_QUERY": '''select GET_TGLOBAL_SETTINGS@simex_db_link('DB', 'DUMP', 'NAME', 'name not found', 'could not be determined') from dual'''

    , "DUMP_IMPORT_DATE": '''select GET_TGLOBAL_SETTINGS@simex_db_link('DB', 'DUMP', 'IMPORTDATE', 'name not found', 'could not be determined') from dual'''

    , "SIMEX_MD_VERSION": '''select SIMEX.PCK_CALCULATION.GET_SETTING( 'SETTING','MASTERDATA_VERSION','UNKNOWN') from dual'''

}

EXT_CONFIG = ["None", "All"]
for KEYS in TRANSLATION_DICT.keys():
    EXT_CONFIG.append(KEYS)
    for SUBKEYS in TRANSLATION_DICT[KEYS]:
        if SUBKEYS != "NONE":
            SUBKEYSTRING = KEYS + "_" + SUBKEYS
            EXT_CONFIG.append(SUBKEYSTRING)

VERIFY_CONFIG = ["None", "ALL", "XPATH", "XSD", "INTEGRITY"]
#for KEYS in ICON_VALIDATION_DICT.keys():
#    for SUBKEYS in ICON_VALIDATION_DICT[KEYS].keys():
#        for SUBSUBKEYS in ICON_VALIDATION_DICT[KEYS][SUBKEYS]:
#            if str(SUBSUBKEYS).find("Validation") != -1:
#                WASTE, CONFIGOPTION = str(SUBSUBKEYS).split("Validation")
#                print "here it comes:", CONFIGOPTION
#                if CONFIGOPTION not in VERIFY_CONFIG:
#                    VERIFY_CONFIG.append(CONFIGOPTION)


#####################################################
# END CONSTRUCTION PARAMETERS
#####################################################

STATISTICS = {}

#####################################################
# Init der Umgebung, Variablen und Module
#####################################################

from lxml import etree
from copy import deepcopy
import os, string, logging, time, cx_Oracle, codecs, sys, locale, ConfigParser, threading, Queue, types, argparse, smtplib, xmltodict, gc, zipfile, unicodedata, csv



class ExtractionThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, JOBQUEUE, FILECHECKER):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.JOBQUEUE = JOBQUEUE
        self.FILECHECKER = FILECHECKER
        self.POWERSWITCH = POWERSWITCH
        self.FIRSTCMD = True
        self.SQLCOMMAND = []

    def findObjectByExtractNo(self, EXTRACTNO="0"):
        global TRANSLATION_DICT
        RESULT = (False, False)
        for DICTOBJ in TRANSLATION_DICT.keys():
            for DICTSUBOBJ in TRANSLATION_DICT[DICTOBJ].keys():
                if str(EXTRACTNO) == str(TRANSLATION_DICT[DICTOBJ][DICTSUBOBJ]["EXTRACT"]):
                    RESULT = (DICTOBJ, DICTSUBOBJ)
        return RESULT

    def mapXmlToLogName(self, OBJECT, SUBOBJECT):
        global TRANSLATION_DICT
        #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "mapXmlToLogName: TRANSLATION_DICT" + str(TRANSLATION_DICT)]})
        RESULT = {}
        for KEYS in TRANSLATION_DICT.keys():
            #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "1mapXmlToLogName: KEYS " + str(KEYS) + " -> " + str(OBJECT)]})
            if str(KEYS).upper() == str(OBJECT).upper():
                #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "2mapXmlToLogName: " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) + " -> " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])]})
                if len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) == len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"]):
                    i=0
                    for VALIDATES in TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]:
                        RESULT[VALIDATES] = TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"][i]
                        i += 1
        self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "mapXmlToLogName: SENDING BACK " + str(RESULT)]})
        return RESULT

    def run(self):
        global STATISTICS
        global CONFIG_DICT
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        while True:
            # Hier wird gewartet
            QUEUE_COMMAND = self.JOBQUEUE.get()
            if QUEUE_COMMAND == "init":
                self.LOGFILE.put("init")
                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "ExtractionThread initialized."]})
                self.JOBQUEUE.task_done()
            elif QUEUE_COMMAND == "getenvironment":
                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Requesting environment data."]})
                try:
                    CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                    SQL = CONNECTION.cursor()
                    # Query DB_NAME
                    SQL.execute(SQL_COMMAND_DICT["DUMPNAME_QUERY"])
                    EXTRACT_SQL_RESULT = SQL.fetchall()
                    # Aufraeumen! \o/
                    updateStatistics(OBJECT="DB_INFO", SUBOBJECT="NONE", SPECIAL="NONE", STATTYPE="NONE", MODE="NEW", KEY="DUMPNAME", VALUE=str(EXTRACT_SQL_RESULT[0][0]))
                    # Query IMPORT_DATE
                    SQL.execute(SQL_COMMAND_DICT["DUMP_IMPORT_DATE"])
                    EXTRACT_SQL_RESULT = SQL.fetchall()
                    updateStatistics(OBJECT="DB_INFO", SUBOBJECT="NONE", SPECIAL="NONE", STATTYPE="NONE", MODE="NEW",KEY="DUMPDATE", VALUE=str(EXTRACT_SQL_RESULT[0][0]))
                    # Query IMPORT_DATE
                    SQL.execute(SQL_COMMAND_DICT["SIMEX_MD_VERSION"])
                    EXTRACT_SQL_RESULT = SQL.fetchall()
                    updateStatistics(OBJECT="DB_INFO", SUBOBJECT="NONE", SPECIAL="NONE", STATTYPE="NONE", MODE="NEW",KEY="SIMEX_MD_VERSION", VALUE=str(EXTRACT_SQL_RESULT[0][0]))
                    CONNECTION.close()
                except:
                    #GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not get DB Data (import date and/or import dump name)! Lets see if there are still files that can extracted...")
                    #LOGFILE.writeLog("ERR", "Can not query for DB import dump name and/or date!")
                    self.LOGFILE.put({"extraction": ["ERROR", time.localtime(), "Error! Could not get DB Data (import date and/or import dump name)! Lets see if there are still files that can extracted..."]})
                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Can not query for DB import dump name and/or date!"]})
                self.JOBQUEUE.task_done()
            elif isinstance(QUEUE_COMMAND, dict):
                for KEYS in QUEUE_COMMAND.keys():
                    for TESTKEYS in TRANSLATION_DICT.keys():
                        if string.upper(TESTKEYS) == KEYS:
                            for VALUES in QUEUE_COMMAND[KEYS]:
                                MAP_DICT = self.mapXmlToLogName(KEYS, VALUES)
                                for VALIDATES in MAP_DICT.keys():
                                    SPECIAL = MAP_DICT[VALIDATES]
                                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Trying to extract: " + str(KEYS) + " -> " + str(VALUES) + " -> " + str(VALIDATES)]})
                                    self.LOGFILE.put({"extraction": ["LOGFILE", time.localtime(), "Extracting: " + str(KEYS) + " -> " + str(VALUES) + " (" + str(VALIDATES) + ")"]})

                                    try:
                                        CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                                        SQL = CONNECTION.cursor()
                                        SQL_COMMAND = SQL_COMMAND_DICT["CHECK_EXTRACTABLE"].replace("#*TASK_ORDER*#", str(TRANSLATION_DICT[TESTKEYS][VALUES]["EXTRACT"]))
                                        SQL.execute(SQL_COMMAND)
                                        SQL_RESULT = SQL.fetchone()
                                        CONNECTION.close()
                                        if not isinstance(SQL_RESULT, types.NoneType):
                                            if len(SQL_RESULT) > 0:
                                                if int(SQL_RESULT[0]) > 0:
                                                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"Looks like someone already executed the extraction of this element: " + str(TESTKEYS) + "->" + str(VALUES) + "->" + str(SQL_RESULT[0])]})
                                            self.SQLCOMMAND.append(SQL_COMMAND_DICT["ACTIVATE_EXTRACTION"].replace("#*TASK_ORDER*#", str(TRANSLATION_DICT[TESTKEYS][VALUES]["EXTRACT"])))
                                            updateStatistics(OBJECT=string.upper(TESTKEYS),SUBOBJECT= VALUES, SPECIAL=SPECIAL, STATTYPE="EXTRACTION", MODE="NEW", KEY="INIT", VALUE=time.localtime())
                                        else:
                                            self.LOGFILE.put({"extraction": ["WARN", time.localtime(), "WARNING! Could not find" + str(TESTKEYS) + "(" + str(TRANSLATION_DICT[TESTKEYS][VALUES]["EXTRACT"]) + ") in database! Not extracting this one."]})
                                    except:
                                        self.LOGFILE.put({"extraction": ["ERROR", time.localtime(),"Could not prepare" + str(TESTKEYS) + "(" + str(TRANSLATION_DICT[TESTKEYS][VALUES]["EXTRACT"]) + ") for setup in database! Not extracting this one."]})

                self.JOBQUEUE.task_done()
            elif QUEUE_COMMAND == "send":
                self.LOGFILE.put(
                    {"extraction": ["DEBUG", time.localtime(), "Sending prepared SQL-commands for extraction to DB."]})
                #if True:
                try:
                    CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                    SQL = CONNECTION.cursor()
                    for SQL_COMMAND in self.SQLCOMMAND:
                        # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                        SQL.execute(SQL_COMMAND)
                        #print SQL.fetchall()
                        CONNECTION.ping()
                    # Aufräumen! \o/
                    CONNECTION.close()
                    self.JOBQUEUE.task_done()
                except:
                    #GLOBAL_LOGFILE.writeLog("OUT", "Error! Extraction setup not possible! Lets see if there are still files that can be checked...")
                    #LOGFILE.writeLog("ERR", "Extraction setup not possible!")
                    self.LOGFILE.put({"extraction": ["ERROR", time.localtime(),"Could not send prepared SQL-commands for extraction to DB. Timing out..."]})
                    # no global task_done() this time. This way the caller knows the extraction could NOT be started.

            elif QUEUE_COMMAND == "monitoring":
                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Starting DB-Monitoring..."]})
                try:
                    SQL_COMMAND = SQL_COMMAND_DICT["CHECK_ACTIVE"]
                    CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                    # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                    SQL = CONNECTION.cursor()
                    SQL.execute(SQL_COMMAND)
                    # Wir sind mutig und holen gleich alle Ergebnisse.
                    EXTRACT_SQL_RESULT = SQL.fetchall()
                    # Aufräumen! \o/
                    CONNECTION.close()
                except:
                    #GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not connect to the DB to check for active tasks!")
                    #LOGFILE.writeLog("ERR", "Could not connect to the DB to check for active tasks!")
                    self.LOGFILE.put({"extraction": ["ERROR", time.localtime(),"Error! Could not connect to the DB to check for active tasks!"]})
                    EXTRACT_SQL_RESULT = None

                if len(EXTRACT_SQL_RESULT) > 0 and len(EXTRACT_SQL_RESULT[0]) == 2 and int(EXTRACT_SQL_RESULT[0][0]) == 1:
                    SQL_EXCEPTION_COUNT = 0
                    SQL_TIMEVAR = time.localtime()
                    SQL_TIME_START = time.clock()
                    SQL_EXTRACTION_HOURS = 0
                    #print "Started at: " + str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SQL_TIMEVAR))
                    self.LOGFILE.put({"extraction": ["INFO", time.localtime(), "Started at: " + str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SQL_TIMEVAR))]})
                    #GLOBAL_LOGFILE.writeLog("OUT", "Started at: " + str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SQL_TIMEVAR)))
                    # Wir haben zumindest teilweise Ergebnisse
                    EXTRACTION_RUNNING = 1
                    EXTRACTION_LOG_SEQUENCE = 0
                    if int(EXTRACT_SQL_RESULT[0][1]) > EXTRACTION_LOG_SEQUENCE:
                        # print "Found older extraction log data. Ignoring..."
                        #GLOBAL_LOGFILE.writeLog("OUT", "Found older extraction log data. Ignoring...")
                        self.LOGFILE.put({"extraction": ["INFO", time.localtime(), "Found older extraction log data. Ignoring..."]})
                        #LOGFILE.writeLog("WARN", "We have " + str(EXTRACT_SQL_RESULT[0][1]) + " previous log entries! We are not the first ones here!")
                        self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "We have " + str(EXTRACT_SQL_RESULT[0][1]) + " previous log entries! We are not the first ones here!"]})
                        EXTRACTION_LOG_SEQUENCE = str(EXTRACT_SQL_RESULT[0][1])
                    self.LOGFILE.put({"extraction": ["LOGONLY", time.localtime(),"SEQ; TIMEINFO; TASKNAME; MESSAGESTATE; INFORMATION"]})
                    #LOGFILE.writeLog("INFO", "SEQ; TASKNAME; MESSAGESTATE; INFORMATION; TIMEINFO")
                    while EXTRACTION_RUNNING == 1:
                        try:
                            #if True:
                            CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                            # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                            SQL = CONNECTION.cursor()
                            SQL.execute(
                                SQL_COMMAND_DICT["LOGQUERY"].replace("#*REPLACEME*#", str(EXTRACTION_LOG_SEQUENCE)))
                            # Wir sind mutig und holen gleich alle Ergebnisse.
                            EXTRACT_SQL_RESULT_LOGQUERY = SQL.fetchall()
                            SQL.execute(SQL_COMMAND_DICT["CHECK_ACTIVE"])
                            EXTRACT_SQL_RESULT_CHECK_ACTIVE = SQL.fetchall()
                            # Aufräumen! \o/
                            CONNECTION.close()

                            if len(EXTRACT_SQL_RESULT_LOGQUERY) > 0:
                                for SQL_RESULTS in EXTRACT_SQL_RESULT_LOGQUERY:
                                    if len(SQL_RESULTS) == 6:
                                        self.LOGFILE.put({"extraction": ["LOGONLY", time.localtime(),str(SQL_RESULTS[0]) + "; " + str(SQL_RESULTS[4]) + "; " + str(SQL_RESULTS[1]) + "; " + str(SQL_RESULTS[2]) + "; " + str(SQL_RESULTS[3])]})
                                        # LOGFILE.writeLog("INFO", str(SQL_RESULTS[0]) + "; "+str(SQL_RESULTS[1]) + "; "+str(SQL_RESULTS[2]) + "; "+str(SQL_RESULTS[3]) + "; "+str(SQL_RESULTS[4]))
                                        EXTRACTION_LOG_SEQUENCE = str(SQL_RESULTS[0])
                                        if str(SQL_RESULTS[2]) == "Export started":
                                            OBJTYPE, SUBOBJTYPE = self.findObjectByExtractNo(str(SQL_RESULTS[5]))
                                            self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Export started - working with: " + str(SQL_RESULTS[2]) + " -> " + str(OBJTYPE) + " -> " + str(SUBOBJTYPE)]})
                                            if (OBJTYPE is not False) and (SUBOBJTYPE is not False):
                                                self.FILECHECKER.put({"exportstarted": {string.upper(OBJTYPE): SUBOBJTYPE}})
                                                MAP_DICT = self.mapXmlToLogName(OBJTYPE, SUBOBJTYPE)
                                                for VALIDATES in MAP_DICT.keys():
                                                    SPECIAL = MAP_DICT[VALIDATES]
                                                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"Start of " + str(OBJTYPE) + "_" + str(SUBOBJTYPE) + "-extraction (" + str(VALIDATES) + ") detected at: " + str(SQL_RESULTS[4])]})
                                                    updateStatistics(OBJECT=string.upper(OBJTYPE), SUBOBJECT=SUBOBJTYPE, SPECIAL=SPECIAL, STATTYPE="EXTRACTION", MODE="NEW", KEY="START", VALUE=time.localtime())
                                            else:
                                                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"Start of " + str(SQL_RESULTS[5]) + "-extraction detected at: " + str(SQL_RESULTS[4])]})
                                                pass

                                        if str(SQL_RESULTS[2]) == "Export finished successful":
                                            OBJTYPE, SUBOBJTYPE = self.findObjectByExtractNo(str(SQL_RESULTS[5]))
                                            self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Export finished successful for: " + str(OBJTYPE) + " -> " + str(SUBOBJTYPE)]})
                                            if (OBJTYPE is not False) and (SUBOBJTYPE is not False):
                                                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "Found an 'Export finished successful'"]})
                                                self.FILECHECKER.put({"exportfinished": {string.upper(OBJTYPE): SUBOBJTYPE}})
                                                MAP_DICT = self.mapXmlToLogName(OBJTYPE, SUBOBJTYPE)
                                                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "FILENAME SPECIALS:" + str(MAP_DICT)]})
                                                for VALIDATES in MAP_DICT.keys():
                                                    SPECIAL = MAP_DICT[VALIDATES]
                                                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"End of " + str(OBJTYPE) + "_" + str(SUBOBJTYPE) + "-extraction (" + str(VALIDATES) + ") detected at: " + str(SQL_RESULTS[4])]})
                                                    updateStatistics(OBJECT=string.upper(OBJTYPE), SUBOBJECT=SUBOBJTYPE, SPECIAL=SPECIAL, STATTYPE="EXTRACTION",  MODE="NEW",  KEY="END", VALUE=time.localtime())
                                            else:
                                                self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"End of " + str(SQL_RESULTS[5]) + "-extraction detected at: " + str(SQL_RESULTS[4])]})
                                                pass

                                        if str(SQL_RESULTS[3]).find("successfully written to file ") != -1 or str(SQL_RESULTS[3]).find(" entries written to file ") != -1:
                                            if str(SQL_RESULTS[3]).find("successfully written to file ") != -1:
                                                WASTE, FILENAME = str(SQL_RESULTS[3]).split("successfully written to file ", 1)
                                            elif str(SQL_RESULTS[3]).find(" entries written to file ") != -1:
                                                WASTE, FILENAME = str(SQL_RESULTS[3]).split(" entries written to file ", 1)
                                            #if FILENAME.find(CONFIG_DICT["ENVIRONMENT"]["XML_ENDING"]) != -1:
                                            #    FILENAME, WASTE = FILENAME.split(CONFIG_DICT["ENVIRONMENT"]["XML_ENDING"],1)
                                            #elif FILENAME.find(CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]) != -1:
                                            #    FILENAME, WASTE = FILENAME.split(CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"],1)
                                            #else:
                                            #    print "Not a valid file name ending found!"
                                            #    FILENAME = "INVALID.FILE"
                                            self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"File successfully written to disc: " + str(FILENAME)]})
                                            OBJTYPE, SUBOBJTYPE = self.findObjectByExtractNo(str(SQL_RESULTS[5]))
                                            self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(),"File successfully written to disc: " + str(OBJTYPE) + " -> " + str(SUBOBJTYPE)]})
                                            if OBJTYPE is not False and SUBOBJTYPE is not False:
                                                SPECIAL_FOUND = False
                                                MAP_DICT = self.mapXmlToLogName(OBJTYPE, SUBOBJTYPE)
                                                for VALIDATES in MAP_DICT.keys():
                                                    SPECIAL = MAP_DICT[VALIDATES]
                                                    if len(MAP_DICT)>0:
                                                        for ENTRIES in MAP_DICT.values():
                                                            if ENTRIES != "NONE" and string.find(FILENAME,ENTRIES)!=-1:
                                                                SPECIAL_FOUND = True
                                                    if not ((SPECIAL_FOUND is True and SPECIAL == "NONE") or (SPECIAL_FOUND == False and SPECIAL != "NONE")):
                                                        if string.find(FILENAME,SPECIAL)!=-1 or SPECIAL == "NONE":
                                                            updateStatistics(OBJECT=string.upper(OBJTYPE), SUBOBJECT=SUBOBJTYPE, SPECIAL=SPECIAL, STATTYPE="EXTRACTION", MODE="ADD", KEY="FILES", VALUE=1)
                                                            #if (SPECIAL == "NONE") is not (string.find(FILENAME, SPECIAL) != -1):
                                                            self.FILECHECKER.put({"exported": {string.upper(OBJTYPE): {SUBOBJTYPE: FILENAME}}})

                            if len(EXTRACT_SQL_RESULT_CHECK_ACTIVE) > 0 and int(
                                    EXTRACT_SQL_RESULT_CHECK_ACTIVE[0][0]) == 1:
                                if time.clock() > (SQL_TIME_START + SQL_EXTRACTION_HOURS * 3600 + 3590):
                                    SQL_EXTRACTION_HOURS = SQL_EXTRACTION_HOURS + 1
                                    self.LOGFILE.put({"extraction": ["INFO", time.localtime(),"Still running... ( " + str(SQL_EXTRACTION_HOURS) + " hours for now )"]})
                                    #GLOBAL_LOGFILE.writeLog("OUT", "Still running... ( " + str(SQL_EXTRACTION_HOURS) + " hours for now )")
                                time.sleep(int(CONFIG_DICT["ENVIRONMENT"]["EXTRACTION_CHECK_INTERVAL"]) * 60)
                            else:
                                SQL_TIME_END = time.clock()
                                SQL_TIME_DIFF = SQL_TIME_END - SQL_TIME_START
                                SQL_TIMEVAR = time.localtime()
                                EXTRACTION_RUNNING = 0
                                self.LOGFILE.put({"extraction": ["INFO", time.localtime(), "Finished at: " + str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SQL_TIMEVAR))]})
                                self.LOGFILE.put({"extraction": ["INFO", time.localtime(), "Elapsed time: " + str(time.strftime('%H:%M:%S', time.gmtime(SQL_TIME_DIFF)))]})
                                #GLOBAL_LOGFILE.writeLog("OUT", "Finished at: " + str( time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SQL_TIMEVAR)))
                                #GLOBAL_LOGFILE.writeLog("OUT", "Elapsed time: " + str(time.strftime('%H:%M:%S', time.gmtime(SQL_TIME_DIFF))))

                        except:
                            self.LOGFILE.put({"extraction": ["ERROR", time.localtime(),"Could not connect to the DB to check for active tasks!"]})
                            #GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not connect to the DB to check for active tasks!")
                            #LOGFILE.writeLog("ERR", "Could not connect to the DB to check for active tasks!")
                            if SQL_EXCEPTION_COUNT < 3:
                                self.LOGFILE.put({"extraction": ["ERROR", time.localtime(), "Trying again in 5 minutes..."]})
                                #GLOBAL_LOGFILE.writeLog("OUT", "Trying again in 5 minutes...")
                                #LOGFILE.writeLog("ERR", "Trying again in 5 minutes...")
                                SQL_EXCEPTION_COUNT = SQL_EXCEPTION_COUNT + 1
                                time.sleep(1 * 60)
                                pass
                            else:
                                self.LOGFILE.put({"extraction": ["ERROR", time.localtime(),"Tried for 3 times now. Aborting extraction."]})
                                #GLOBAL_LOGFILE.writeLog("OUT", "Tried for 3 times now. Aborting extraction.")
                                #LOGFILE.writeLog("ERR", "Tried for 3 times now. Aborting extraction.")
                else:
                    self.LOGFILE.put({"extraction": ["ERROR", time.localtime(), "No extraction task can be found."]})
                    #GLOBAL_LOGFILE.writeLog("OUT", "WARNING: No extraction task can be found.")
                    #LOGFILE.writeLog("WARN", "No extraction task can be found.")

                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "quit":
                if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                    self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "ExtractionThread quitting as requested."]})
                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break


class CheckXSDThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, JOBQUEUE, INTEGRITY):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.JOBQUEUE = JOBQUEUE
        self.POWERSWITCH = POWERSWITCH
        self.INTEGRITY = INTEGRITY
        self.FULL_XSD_PATH = False
        self.XMLSCHEMA_DOC = None
        self.XMLSCHEMA = None
        self.INIT = False


    def mapXmlToLogName(self, OBJECT, SUBOBJECT):
        global TRANSLATION_DICT
        #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "mapXmlToLogName: TRANSLATION_DICT" + str(TRANSLATION_DICT)]})
        RESULT = {}
        for KEYS in TRANSLATION_DICT.keys():
            #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "1mapXmlToLogName: KEYS " + str(KEYS) + " -> " + str(OBJECT)]})
            if str(KEYS).upper() == str(OBJECT).upper():
                #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "2mapXmlToLogName: " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) + " -> " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])]})
                if len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) == len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"]):
                    i=0
                    for VALIDATES in TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]:
                        RESULT[VALIDATES] = TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"][i]
                        i += 1
        self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "CheckXSD: mapXmlToLogName: SENDING BACK " + str(RESULT)]})
        return RESULT

    def run(self):
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        while True:
            QUEUE_COMMAND = self.JOBQUEUE.get()
            if QUEUE_COMMAND == "init":
                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "CheckXSDThread initializing"]})
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict):
                if QUEUE_COMMAND.has_key("initverification"):
                    for OBJECTS in QUEUE_COMMAND["initverification"].keys():
                        SUBOBJECTS = QUEUE_COMMAND["initverification"][OBJECTS]
                        self.LOGFILE.put({"checkxsd": ["initlog", OBJECTS, SUBOBJECTS]})
                        MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                        for VALIDATES in MAP_DICT.keys():
                            SPECIAL = MAP_DICT[VALIDATES]
                            updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="NEW", KEY="START", VALUE=time.localtime())
                            updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="ADD", KEY="ERROR", VALUE=0)
                        if self.FULL_XSD_PATH is False:
                            self.FULL_XSD_PATH = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XSD"]) + str(CONFIG_DICT["ENVIRONMENT"]["NAME_XSD"])
                        if self.INIT == False:
                            if os.path.isfile(self.FULL_XSD_PATH):
                                #if True:
                                try:
                                    self.XMLSCHEMA_DOC = etree.parse(self.FULL_XSD_PATH)
                                    self.XMLSCHEMA = etree.XMLSchema(self.XMLSCHEMA_DOC)
                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-File found. Finished Init!"]})
                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-Check will use following validation target: " + str(self.FULL_XSD_PATH)]})
                                    self.INIT = True
                                except:
                                    self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-File found, but could not be initialized: " + str(self.FULL_XSD_PATH)]})
                                    self.FULL_XSD_PATH = False
                            else:
                                self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-File could NOT be found: " + str(self.FULL_XSD_PATH) + " - Finished Init!"]})
                                self.FULL_XSD_PATH = False
                        else:
                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-File exists already. Finished Init!"]})

                elif QUEUE_COMMAND.has_key("endverification"):
                    for OBJECTS in QUEUE_COMMAND["endverification"].keys():
                        SUBOBJECTS = QUEUE_COMMAND["endverification"][OBJECTS]
                        self.LOGFILE.put({"checkxsd": ["endlog", OBJECTS, SUBOBJECTS]})
                        MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                        for VALIDATES in MAP_DICT.keys():
                            SPECIAL = MAP_DICT[VALIDATES]
                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "Ending Verification for: " + str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(VALIDATES) + " -> " + str(SPECIAL)]})
                            updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="NEW", KEY="END", VALUE=time.localtime())
                elif QUEUE_COMMAND.has_key("verify"):
                    for OBJECTS in QUEUE_COMMAND["verify"].keys():
                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-Check: Got a VERIFY for the following: " + str(OBJECTS) + " -> " + str(QUEUE_COMMAND["verify"][OBJECTS])]})
                        for SUBOBJECTS in QUEUE_COMMAND["verify"][OBJECTS].keys():
                            MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                            for FILENAME in QUEUE_COMMAND["verify"][OBJECTS][SUBOBJECTS]:
                                SPECIAL_FOUND = False
                                for VALIDATES in MAP_DICT.keys():
                                    SPECIAL = MAP_DICT[VALIDATES]
                                    for ENTRIES in MAP_DICT.values():
                                        if ENTRIES != "NONE" and string.find(FILENAME, ENTRIES)!=-1:
                                            SPECIAL_FOUND = True
                                    if not ((SPECIAL_FOUND is True and SPECIAL == "NONE") or (SPECIAL_FOUND is False and SPECIAL != "NONE")):
                                        #print 1, FILENAME
                                        #print 2, SPECIAL
                                        #print 3, VALIDATES
                                        #print 4, SUBOBJECTS
                                        #print 5, ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"]
                                        if (string.find(FILENAME, SPECIAL) != -1 or SPECIAL == "NONE") and self.FULL_XSD_PATH is not False and VALIDATES in ICON_VALIDATION_DICT.keys() and ("ExtractFileType" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS].keys() and ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"] in ["CSV", "XML"]):
                                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "Checking XSD for: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " (" + str(SPECIAL) + "/" + str(VALIDATES) + ") -> " + str(FILENAME)]})
                                            if not os.path.isfile(FILENAME):
                                                FILENAME = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + FILENAME
                                                if not os.path.isfile(FILENAME):
                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "FILE NOT FOUND: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(FILENAME)]})
                                                    break
                                            #GLOBAL_LOGFILE.writeLog("OUT", "Checking against Reference XSD: " + str(self.FULL_XSD_PATH))
                                            #GLOBAL_LOGFILE.writeLog("OUT", "Validating (XSD): " + str( XML_FILES))
                                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "CheckInt: Variable for CheckInt is:" + str(CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"]) + " (" + str(type(CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"])) + ")"]})
                                            if CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] is True:
                                                self.LOGFILE.put({"checkxsd": ["LOGFILE", time.localtime(), "Checking XSD/INTEGRITY for: " + str(FILENAME)]})
                                            else:
                                                self.LOGFILE.put({"checkxsd": ["LOGFILE", time.localtime(), "Checking XSD for: " + str(FILENAME)]})
                                            #LOGFILE.writeLog( "INFO", str("Validating: " + str(XML_FILES)) )
                                            #LOGFILE.writeLog( "INFO", str("Against XSD: " + str(FULL_XSD_PATH)) )
                                            # Vorbereitung / Laden des Files
                                            if ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"] == "XML":
                                                PARSER = etree.XMLParser(no_network = True, resolve_entities=False, strip_cdata=False, compact=False)
                                                TREE = etree.parse(FILENAME, PARSER)
                                                ROOT = TREE.getroot()

                                            # Prüfung des kompletten Original-Files auf Konformität (sehr schnell)
                                            #try:
                                            if True:
                                                if CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] is True or (ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"] == "XML" and self.XMLSCHEMA.validate(ROOT) != True):
                                                    # Die Prüfung/Validierung ist fehlgeschlagen. Wir gehen in die Detailprüfung...
                                                    #LOGFILE.writeLog( "WARN", str("Validation failed for:" + str(XML_FILES)))
                                                    if CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] is False:
                                                        self.LOGFILE.put({"checkxsd": ["LOGFILE", time.localtime(), "Validation failed for:" + str(FILENAME)]})
                                                    if ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"] == "XML":
                                                        # ... Kopieren uns das Original-XML 1:1 ...
                                                        NEWROOT=deepcopy(ROOT)
                                                        # ... und werfen erstmal alles weg...
                                                        while len(NEWROOT) > 0:
                                                            del NEWROOT[0]
                                                        # ...um hinterher die executionSettings als Knoten wieder anzufügen.
                                                        NEWROOT.append(deepcopy(ROOT.xpath("//executionSettings"))[0])

                                                        # Nachdem wir jetzt ein vorbereitetes neues, ohne "Betriebsknoten" belastetes XML haben
                                                        # Iterieren wir über alle "invocation" Knoten des Original-XMLs
                                                        for ATTRIBUTES in ROOT.xpath("//invocation"):
                                                            # Da lxml (XML unter Python wohl allgemein) aber Probleme mit "xmlns" hat, müssen wir Umwege gehen...
                                                            # 1. Wir transformieren das neue XML in einen String und zerlegen es zeilenweise
                                                            #ORIG_ATTRIB = dict (NEWROOT)
                                                            NEWROOTTEXT = etree.tostring(NEWROOT)
                                                            NEWROOTLIST = NEWROOTTEXT.splitlines(True)
                                                            # 2. Das Gleiche machen wir mit dem zu validierenden Einzelknoten
                                                            XMLTEXT = etree.tostring(ATTRIBUTES)
                                                            XMLLIST = XMLTEXT.splitlines(True)
                                                            # 3. Wir übernehmen den Knoten in die finale Struktur
                                                            NEWCOMBINEDLIST = XMLLIST[:]
                                                            # 4. Stricken erst das "</common:ServiceInvocationCollection>" des neuen XML-Basis-Konstruktes am Ende dran
                                                            NEWCOMBINEDLIST.append(NEWROOTLIST[-1])
                                                            # Und schieben dann vom Basis-Konstrukt zeilenweise alle Zeilen bis auf die letzte davor
                                                            for lines in reversed(NEWROOTLIST[0:-1]):
                                                                NEWCOMBINEDLIST.insert(0, lines)
                                                            #NEWXMLTEXT = etree.fromstring(XMLTEXT)
                                                            #NEWCOMBINED = string.strip(NEWROOTTEXT) + string.strip(XMLTEXT)

                                                            # 5. Fügen die Einzelzeilen wieder zu einem einzelnen String zusammen
                                                            NEWCOMBINED = string.join(NEWCOMBINEDLIST)

                                                            # 6. Bauen dann noch einen FallBack fuer "xsi:type", was wir fuer RefInt brauchen
                                                            if str(NEWCOMBINED).find("xsi:type") != -1:
                                                                NEWCOMBINED_XSIMOD = str(NEWCOMBINED).replace("xsi:type", "xsi_type")
                                                            else:
                                                                NEWCOMBINED_XSIMOD = str(NEWCOMBINED)

                                                            # HIER SCHLAEGT ZUKUENFTIG DIE SUCHE EIN! DIE BRAUCHT DIESE STRING-VARIANTE!

                                                            # 7. Um am Ende beide als neue Testobjekte zusammenzustellen.
                                                            FINALROOT = etree.fromstring(NEWCOMBINED)
                                                            FINALROOT_XSIMOD = etree.fromstring(NEWCOMBINED_XSIMOD)

                                                            ## SUCHE WOOHOO!
                                                            if OBJECTS in SEARCH_DICT.keys():
                                                                for DEFECTS in SEARCH_DICT[OBJECTS].keys():
                                                                    self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS)]})
                                                                    for DEF_ENTRIES in SEARCH_DICT[OBJECTS][DEFECTS]:
                                                                        self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS) + " -> " + str(DEF_ENTRIES)]})
                                                                        if XMLTEXT.find(str(DEF_ENTRIES)) != -1:
                                                                            self.LOGFILE.put({"search": ["LOGONLY", time.localtime(), str(DEFECTS) + " -> " + str(DEF_ENTRIES) + " in: " + str(FILENAME) + ":\r\n" + str(XMLTEXT)]})
                                                                        else:
                                                                            pass
                                                            else:
                                                                pass

                                                            if CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] is True:
                                                                #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Looking for results in: " + str(FILENAME)]})
                                                                #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: IF: " + str(VALIDATES) + " -> " + str(ICON_VALIDATION_DICT.keys()) + " -> Result is DICT? -> " + str(isinstance(ICON_VALIDATION_DICT[VALIDATES], dict))]})
                                                                #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: IF: " + str(SUBOBJECTS) + " -> " + str(ICON_VALIDATION_DICT[VALIDATES].keys())]})
                                                                #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: IF: " + str("ValidationIntegrity") + " -> " + str(ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS].keys())]})  # + " -> Result is DICT? -> " + str(ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"], dict)

                                                                if VALIDATES in ICON_VALIDATION_DICT.keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES], dict) and SUBOBJECTS in ICON_VALIDATION_DICT[VALIDATES].keys() and "ValidationIntegrity" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS].keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"], dict):
                                                                    if "OWNKEY" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"].keys():
                                                                        #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: OWNKEY-structure found."]})
                                                                        for OWNKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["OWNKEY"]:
                                                                            if isinstance(OWNKEYS, dict) and "NAME" in OWNKEYS.keys() and "XPATH" in OWNKEYS.keys():
                                                                                #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Querying: " + str(OWNKEYS["NAME"] + " -> " + str(OWNKEYS["XPATH"]))]})
                                                                                OWNKEY_RESULT = FINALROOT.xpath(str(OWNKEYS["XPATH"]))
                                                                                for OWNKEY_RESULT_ENTRIES in OWNKEY_RESULT:
                                                                                    try:
                                                                                        if OWNKEY_RESULT_ENTRIES.text == None:
                                                                                            raise
                                                                                        else:
                                                                                            OWNKEY_RESULT_ENTRIES = str(OWNKEY_RESULT_ENTRIES.text)
                                                                                    except:
                                                                                        try:
                                                                                            OWNKEY_RESULT_ENTRIES = str(OWNKEY_RESULT_ENTRIES.tag)
                                                                                        except:
                                                                                            try:
                                                                                                OWNKEY_RESULT_ENTRIES = str(OWNKEY_RESULT_ENTRIES)
                                                                                            except:
                                                                                                self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-INT has a result for OWNKEY but can not handle querying: " + str(OWNKEYS["XPATH"])]})

                                                                                    #self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: OWNKEY-Results: " + str(OWNKEYS["NAME"]) + " -> " + str(OWNKEY_RESULT_ENTRIES)]})
                                                                                    self.INTEGRITY.put({"checkintownkey": {str(VALIDATES) + "_" + str(SUBOBJECTS) + "_" + str(OWNKEYS["NAME"]): [str(OBJECTS), str(SUBOBJECTS), str(SPECIAL), str(OWNKEY_RESULT_ENTRIES), str(FILENAME)]}})
                                                                            else:
                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: OWNKEY-Setup could not be opened: " + str(OWNKEYS)]})
                                                                    else:
                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: No OWNKEY for: " + str(VALIDATES) + " -> " + str(SUBOBJECTS)]})
                                                                    if "REMOTEKEY" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"].keys():
                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY-structure found."]})
                                                                        for REMOTEKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["REMOTEKEY"]:
                                                                            if isinstance(REMOTEKEYS, dict) and "NAME" in REMOTEKEYS.keys() and "XPATH" in REMOTEKEYS.keys() and "TYPE" in REMOTEKEYS.keys() and "FK_CHECK" in REMOTEKEYS.keys() and isinstance(REMOTEKEYS["FK_CHECK"], list):
                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Asking XPATH: " + str(REMOTEKEYS["XPATH"])]})
                                                                                REMOTEKEY_XPATH = ""
                                                                                #try:
                                                                                if True:
                                                                                    REMOTEKEY_XPATH = FINALROOT.xpath(str(REMOTEKEYS["XPATH"]), smart_strings=False)
                                                                                    TMP_XPATH = []
                                                                                    for REMOTEKEYS_XPATH in REMOTEKEY_XPATH:
                                                                                        try:
                                                                                            if REMOTEKEYS_XPATH.text == None:
                                                                                                raise
                                                                                            else:
                                                                                                TMP_XPATH.append(str(REMOTEKEYS_XPATH.text))
                                                                                        except:
                                                                                            try:
                                                                                                TMP_XPATH.append(str(REMOTEKEYS_XPATH.tag))
                                                                                            except:
                                                                                                try:
                                                                                                    TMP_XPATH.append(str(REMOTEKEYS_XPATH))
                                                                                                except:
                                                                                                    self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-INT has a result for REMOTEKEY but can not handle querying: " + str(REMOTEKEYS["XPATH"])]})

                                                                                        REMOTEKEY_XPATH = TMP_XPATH
                                                                                #except:
                                                                                #    self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-INT: REMOTEKEY: Could not query XPATH: " + str(REMOTEKEYS["XPATH"])]})

                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Asking TYPE: " + str(REMOTEKEYS["TYPE"])]})
                                                                                REMOTEKEY_TYPE = ""
                                                                                try:
                                                                                    REMOTEKEY_TYPE = FINALROOT.xpath(str(REMOTEKEYS["TYPE"]))
                                                                                except:
                                                                                    try:
                                                                                        REMOTEKEY_TYPE = FINALROOT_XSIMOD.xpath(str(REMOTEKEYS["TYPE"]).replace("xsi:type", "xsi_type"))
                                                                                    except:
                                                                                        self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "XSD-INT: REMOTEKEY: Could not query TYPE: " + str(REMOTEKEYS["TYPE"])]})

                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Preparing for FK_CHECKS: " + str(REMOTEKEY_XPATH) + ", " + str(REMOTEKEY_TYPE)]})
                                                                                if REMOTEKEY_XPATH != "" and REMOTEKEY_TYPE != "":
                                                                                    if isinstance(REMOTEKEY_XPATH, str):
                                                                                        REMOTEKEY_XPATH = [REMOTEKEY_XPATH]
                                                                                    if isinstance(REMOTEKEY_TYPE, str):
                                                                                        REMOTEKEY_TYPE = [REMOTEKEY_TYPE]
                                                                                    for REMOTEKEY_XPATHS in REMOTEKEY_XPATH:
                                                                                        for REMOTEKEY_TYPES in REMOTEKEY_TYPE:
                                                                                            REMOTEKEY_TYPES = str(REMOTEKEY_TYPES)
                                                                                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Decoding done for FK_CHECKS: " + str(REMOTEKEY_XPATHS) + ", " + str(REMOTEKEY_TYPES)]})
                                                                                            for FK_CHECKS in REMOTEKEYS["FK_CHECK"]:
                                                                                                FK_RESULTS=[]
                                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: We have the FK_CHECKS: " + str(FK_CHECKS)]})
                                                                                                if isinstance(FK_CHECKS, dict):
                                                                                                    if REMOTEKEY_TYPES in FK_CHECKS.keys():
                                                                                                        if isinstance(FK_CHECKS[REMOTEKEY_TYPES], list):
                                                                                                            for FK_CHECKS_KEY in FK_CHECKS[REMOTEKEY_TYPES]:
                                                                                                                FK_CHECKS_KEY = str(FK_CHECKS_KEY)
                                                                                                                FK_RESULTS.append(FK_CHECKS_KEY)
                                                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Check found: " + str(FK_RESULTS)]})
                                                                                                            self.INTEGRITY.put({"checkintremotekey": {"RESULT": [str(OBJECTS), str(SUBOBJECTS), str(SPECIAL), str(REMOTEKEY_XPATHS), str(FILENAME), FK_RESULTS]}})
                                                                                                        else:
                                                                                                            self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: FK_CHECK-RK is no LIST: " + str(FK_CHECKS[REMOTEKEY_TYPES])]})
                                                                                                else:
                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: FK_CHECK is no DICT: " + str(FK_CHECKS)]})
                                                                                else:
                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Asking TYPE: " + str(etree.tostring(FINALROOT))]})
                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Asking TYPE: " + str(REMOTEKEYS["TYPE"])]})

                                                                            else:
                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY-Setup could not be opened: " + str(REMOTEKEYS)]})
                                                                else:
                                                                    pass
                                                                    #if VALIDATES in ICON_VALIDATION_DICT.keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES], dict):
                                                                    #    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Validation-XML invalid? -> " + str(VALIDATES) + " -> " + str(SUBOBJECTS) + " -> " + str(ICON_VALIDATION_DICT[VALIDATES])]})
                                                                    #else:
                                                                    #    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Can not find VALIDATE at all: " + str(VALIDATES) + " -> " + str(ICON_VALIDATION_DICT[VALIDATES])]})

                                                            # Das Error-Log wird gelöscht, damit wir aus den alten Iterationen keine Fehler mitbekommen. (Vermutlich Overhead)
                                                            etree.clear_error_log()
                                                            # Die neue Prüfung folgt. Es wird nur der neue XML-Kopf mit dem einzelnen Knoten geprüft.
                                                            if self.XMLSCHEMA.validate(FINALROOT) != True:
                                                                # Wenn wir einen Knoten mit Validierungsfehlern finden, schauen wir uns jede Logfile-Zeile an...
                                                                for ERROR_MSG in self.XMLSCHEMA.error_log:
                                                                    # ...dürfen noch einen "UTF-8"-Airlock" machen... (Python2-Problem)
                                                                    DECODED_ERROR_MSG = ERROR_MSG.message.encode("utf-8").decode("utf-8")
                                                                    # ... und werfen je Fehler eine sinnlose, weil nichtssagende Zeile des Fehlers weg.
                                                                    if string.find(DECODED_ERROR_MSG, "is not a valid value of the atomic type") >= 0 and len(self.XMLSCHEMA.error_log) > 1:
                                                                        pass

                                                                    # Wenn wir einen validen Fehler haben, loggen wir dies.

                                                                    else:
                                                                        updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="ADD", KEY="ERROR", VALUE=1)
                                                                        #STATISTICS[DATEITYP]["Data_Errors"] = STATISTICS[DATEITYP]["Data_Errors"] + 1
                                                                        #GLOBAL_LOGFILE.writeLog("OUT", "Errors found: " + ERROR_MSG.message.encode("utf-8").decode("utf-8"))
                                                                        self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "Errors found: " + ERROR_MSG.message.encode("utf-8").decode("utf-8")]})
                                                                        #print "Errors found: " + ERROR_MSG.message.encode("utf-8").decode("utf-8")
                                                                        #LOGFILE.writeLog( "WARN", DECODED_ERROR_MSG)

                                                                # Sind alle Fehlerzeilen für den Knoten "durch", geben wir ihn im Logfile aus.
                                                                #LOGFILE.writeLog( "WARN", "Causing XML-Excerpt:")

                                                                #LOGFILE.writeLog( "WARN", str("===========================================================================\n" + etree.tostring(ATTRIBUTES).strip()))
                                                                #LOGFILE.writeLog( "WARN", "===========================================================================")

                                                    elif ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ExtractFileType"] == "CSV":
                                                        SEARCHEDALREADY = False
                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XPath: Checking in CSV-Mode:" + str(FILENAME)]})
                                                        if CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] is True:
                                                            if VALIDATES in ICON_VALIDATION_DICT.keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES], dict) and SUBOBJECTS in ICON_VALIDATION_DICT[VALIDATES].keys() and "ValidationIntegrity" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS].keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"], dict):
                                                                if "OWNKEY" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"].keys():
                                                                    # Just going the round to get a working delimiter. We are wasting some energy here, through...
                                                                    CSVDELIMITER = "ABC"
                                                                    for OWNKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["OWNKEY"]:
                                                                        if isinstance(OWNKEYS, dict) and "NAME" in OWNKEYS.keys() and "XPATH" in OWNKEYS.keys():
                                                                            if str(OWNKEYS["XPATH"])[0:4] == "CSV:":
                                                                                _, WORKSTRING = str(OWNKEYS["XPATH"]).split("CSV:", 1)
                                                                                if WORKSTRING.find("DELIMIT:") != -1:
                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSDCSV: Found DELIMIT-Keyword."]})
                                                                                    if WORKSTRING[0:8] == "DELIMIT:":
                                                                                        if len(WORKSTRING) > 8:
                                                                                            _, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                                        else:
                                                                                            TMPSPLITB = ""
                                                                                    else:
                                                                                        if WORKSTRING[-8:] != "DELIMIT:":
                                                                                            TMPSPLITA, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                                        else:
                                                                                            TMPSPLITB = ""
                                                                                    if TMPSPLITB.find(":") != -1:
                                                                                        if TMPSPLITB[1] == ":":
                                                                                            CSVDELIMITER = TMPSPLITB[0]
                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSDCSV: DELIMITER is: " + str(CSVDELIMITER)]})
                                                                    try:
                                                                        CSVFILE = open(FILENAME, "rb")
                                                                        CSVREADER = csv.DictReader(CSVFILE, delimiter=CSVDELIMITER)
                                                                        for CSVLINES in CSVREADER:
                                                                            for OWNKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["OWNKEY"]:
                                                                                if isinstance(OWNKEYS, dict) and "NAME" in OWNKEYS.keys() and "XPATH" in OWNKEYS.keys():
                                                                                    if str(OWNKEYS["XPATH"])[0:4] == "CSV:":
                                                                                        _, WORKSTRING = str(OWNKEYS["XPATH"]).split("CSV:", 1)
                                                                                        if WORKSTRING.find("NAME:") != -1:
                                                                                            self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: Found NAME-Keyword."]})
                                                                                            if WORKSTRING[0:5] == "NAME:":
                                                                                                if len(WORKSTRING)> 5:
                                                                                                    _, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                                                else:
                                                                                                    TMPSPLITB = ""
                                                                                            else:
                                                                                                if WORKSTRING[-5:] != "NAME:":
                                                                                                    TMPSPLITA, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                                                else:
                                                                                                    TMPSPLITB = ""
                                                                                            if len(TMPSPLITB) > 0 and TMPSPLITB.find(":") == -1:
                                                                                                CSVNAME = TMPSPLITB
                                                                                            else:
                                                                                                CSVNAME = ""

                                                                                            if CSVNAME != "" and CSVNAME in CSVREADER.fieldnames:
                                                                                                OWNKEY_RESULT_ENTRIES = CSVLINES[CSVNAME]
                                                                                                self.INTEGRITY.put({"checkintownkey": {str(VALIDATES) + "_" + str(SUBOBJECTS) + "_" + str(OWNKEYS["NAME"]): [str(OBJECTS), str(SUBOBJECTS), str(SPECIAL), str(OWNKEY_RESULT_ENTRIES), str(FILENAME)]}})
                                                                            ## SUCHE WOOHOO!
                                                                            if SEARCHEDALREADY is False and OBJECTS in SEARCH_DICT.keys():
                                                                                for DEFECTS in SEARCH_DICT[OBJECTS].keys():
                                                                                    self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS)]})
                                                                                    for DEF_ENTRIES in SEARCH_DICT[OBJECTS][DEFECTS]:
                                                                                        self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS) + " -> " + str(DEF_ENTRIES)]})
                                                                                        if str(DEF_ENTRIES) in CSVLINES.values():
                                                                                            self.LOGFILE.put({"search": ["LOGONLY", time.localtime(), str(DEFECTS) + " -> " + str(DEF_ENTRIES) + " in: " + str(FILENAME) + ":\r\n" + str(CSVLINES.items())]})
                                                                                        else:
                                                                                            pass
                                                                            else:
                                                                                pass
                                                                        SEARCHEDALREADY = True

                                                                        CSVFILE.close()
                                                                    except:
                                                                        self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "Could not load payload from CSV-file: " + str(FILENAME)]})
                                                                else:
                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: No OWNKEY for: " + str(VALIDATES) + " -> " + str(SUBOBJECTS)]})

                                                                if "REMOTEKEY" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"].keys():
                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY-structure found."]})
                                                                    if "REMOTEKEY" in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"].keys():
                                                                        # Just going the round to get a working delimiter. We are wasting some energy here, through...
                                                                        CSVDELIMITER = "ABC"
                                                                        for REMOTEKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["REMOTEKEY"]:
                                                                            if isinstance(REMOTEKEYS, dict) and "NAME" in REMOTEKEYS.keys() and "XPATH" in REMOTEKEYS.keys() and "TYPE" in REMOTEKEYS.keys() and "FK_CHECK" in REMOTEKEYS.keys() and isinstance(REMOTEKEYS["FK_CHECK"], list):
                                                                                if str(REMOTEKEYS["XPATH"])[0:4] == "CSV:":
                                                                                    _, WORKSTRING = str(REMOTEKEYS["XPATH"]).split("CSV:", 1)
                                                                                    if WORKSTRING.find("DELIMIT:") != -1:
                                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSDCSV: Found DELIMIT-Keyword."]})
                                                                                        if WORKSTRING[0:8] == "DELIMIT:":
                                                                                            if len(WORKSTRING) > 8:
                                                                                                _, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                                            else:
                                                                                                TMPSPLITB = ""
                                                                                        else:
                                                                                            if WORKSTRING[-8:] != "DELIMIT:":
                                                                                                TMPSPLITA, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                                            else:
                                                                                                TMPSPLITB = ""
                                                                                        if TMPSPLITB.find(":") != -1:
                                                                                            if TMPSPLITB[1] == ":":
                                                                                                CSVDELIMITER = TMPSPLITB[0]
                                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSDCSV: DELIMITER is: " + str(CSVDELIMITER)]})
                                                                        if True:
                                                                        #try:
                                                                            CSVFILE = open(FILENAME, "rb")
                                                                            CSVREADER = csv.DictReader(CSVFILE, delimiter=CSVDELIMITER)
                                                                            for CSVLINES in CSVREADER:
                                                                                for REMOTEKEYS in ICON_VALIDATION_DICT[VALIDATES][SUBOBJECTS]["ValidationIntegrity"]["REMOTEKEY"]:
                                                                                    if isinstance(REMOTEKEYS, dict) and "NAME" in REMOTEKEYS.keys() and "XPATH" in REMOTEKEYS.keys() and "TYPE" in REMOTEKEYS.keys() and "FK_CHECK" in REMOTEKEYS.keys() and isinstance(REMOTEKEYS["FK_CHECK"], list):
                                                                                        if str(REMOTEKEYS["XPATH"])[0:4] == "CSV:":
                                                                                            _, WORKSTRING = str(REMOTEKEYS["XPATH"]).split("CSV:", 1)
                                                                                            if WORKSTRING.find("NAME:") != -1:
                                                                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: Found NAME-Keyword."]})
                                                                                                if WORKSTRING[0:5] == "NAME:":
                                                                                                    if len(WORKSTRING)> 5:
                                                                                                        _, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                                                    else:
                                                                                                        TMPSPLITB = ""
                                                                                                else:
                                                                                                    if WORKSTRING[-5:] != "NAME:":
                                                                                                        TMPSPLITA, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                                                    else:
                                                                                                        TMPSPLITB = ""
                                                                                                if len(TMPSPLITB) > 0 and TMPSPLITB.find(":") == -1:
                                                                                                    CSVNAME = TMPSPLITB
                                                                                                else:
                                                                                                    CSVNAME = ""

                                                                                                if CSVNAME != "" and CSVNAME in CSVREADER.fieldnames:
                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Checking Key: " + str(CSVNAME)]})
                                                                                                    REMOTEKEY_XPATH = [CSVLINES[CSVNAME]]

                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Asking TYPE: " + str(REMOTEKEYS["TYPE"])]})
                                                                                                    REMOTEKEY_TYPE = str(REMOTEKEYS["TYPE"])
                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Preparing for FK_CHECKS: " + str(REMOTEKEY_XPATH) + ", " + str(REMOTEKEY_TYPE)]})
                                                                                                    if REMOTEKEY_XPATH != "" and REMOTEKEY_TYPE != "":
                                                                                                        if isinstance(REMOTEKEY_XPATH, str):
                                                                                                            REMOTEKEY_XPATH = [REMOTEKEY_XPATH]
                                                                                                        if isinstance(REMOTEKEY_TYPE, str):
                                                                                                            REMOTEKEY_TYPE = [REMOTEKEY_TYPE]
                                                                                                        for REMOTEKEY_XPATHS in REMOTEKEY_XPATH:
                                                                                                            for REMOTEKEY_TYPES in REMOTEKEY_TYPE:
                                                                                                                REMOTEKEY_TYPES = str(REMOTEKEY_TYPES)
                                                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Decoding done for FK_CHECKS: " + str(REMOTEKEY_XPATHS) + ", " + str(REMOTEKEY_TYPES)]})
                                                                                                                for FK_CHECKS in REMOTEKEYS["FK_CHECK"]:
                                                                                                                    FK_RESULTS=[]
                                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: We have the FK_CHECKS: " + str(FK_CHECKS)]})
                                                                                                                    if isinstance(FK_CHECKS, dict):
                                                                                                                        REMOTEKEY_TYPES = unicode(REMOTEKEY_TYPES).strip("'")
                                                                                                                        if REMOTEKEY_TYPES in FK_CHECKS.keys():
                                                                                                                            if isinstance(FK_CHECKS[REMOTEKEY_TYPES], list):
                                                                                                                                for FK_CHECKS_KEY in FK_CHECKS[REMOTEKEY_TYPES]:
                                                                                                                                    FK_CHECKS_KEY = str(FK_CHECKS_KEY)
                                                                                                                                    FK_RESULTS.append(FK_CHECKS_KEY)
                                                                                                                                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: Check found: " + str(FK_RESULTS)]})
                                                                                                                                self.INTEGRITY.put({"checkintremotekey": {"RESULT": [str(OBJECTS), str(SUBOBJECTS), str(SPECIAL), str(REMOTEKEY_XPATHS), str(FILENAME), FK_RESULTS]}})
                                                                                                                            else:
                                                                                                                                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: FK_CHECK-RK is no LIST: " + str(FK_CHECKS[REMOTEKEY_TYPES])]})
                                                                                                                    else:
                                                                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY: FK_CHECK is no DICT: " + str(FK_CHECKS)]})
                                                                                    else:
                                                                                        self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: REMOTEKEY-Setup could not be opened: " + str(REMOTEKEYS)]})
                                                                            ## SUCHE WOOHOO!
                                                                            if SEARCHEDALREADY is False and OBJECTS in SEARCH_DICT.keys():
                                                                                for DEFECTS in SEARCH_DICT[OBJECTS].keys():
                                                                                    self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS)]})
                                                                                    for DEF_ENTRIES in SEARCH_DICT[OBJECTS][DEFECTS]:
                                                                                        self.LOGFILE.put({"search": ["DEBUG", time.localtime(), "SEARCH: Searching: " + str(DEFECTS) + " -> " + str(DEF_ENTRIES)]})
                                                                                        if str(DEF_ENTRIES) in CSVLINES.values():
                                                                                            self.LOGFILE.put({"search": ["LOGONLY", time.localtime(), str(DEFECTS) + " -> " + str(DEF_ENTRIES) + " in: " + str(FILENAME) + ":\r\n" + str(CSVLINES.items())]})
                                                                                        else:
                                                                                            pass
                                                                            else:
                                                                                pass

                                                                            CSVFILE.close()
                                                                        #except:
                                                                        #    self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "Could not load payload from CSV-file: " + str(FILENAME)]})
                                                                else:
                                                                    pass
                                                                    #if VALIDATES in ICON_VALIDATION_DICT.keys() and isinstance(ICON_VALIDATION_DICT[VALIDATES], dict):
                                                                    #    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Validation-XML invalid? -> " + str(VALIDATES) + " -> " + str(SUBOBJECTS) + " -> " + str(ICON_VALIDATION_DICT[VALIDATES])]})
                                                                    #else:
                                                                    #    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-INT: Can not find VALIDATE at all: " + str(VALIDATES) + " -> " + str(ICON_VALIDATION_DICT[VALIDATES])]})

                                                    else:
                                                        # No valid XML/CSV. pass... ignorieren.

                                                        pass
                                                else:
                                                    self.LOGFILE.put({"checkxsd": ["LOGFILE", time.localtime(), "Check XSD successfull for: " + str(FILENAME)]})

                                                # (Nachdem wir über alle Knoten des Files iteriert haben:)
                                                # Da Ordnung das halbe Leben ist, wird protokolliert, wie viele Dateien wir verarbeitet haben.
                                                updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="ADD", KEY="FILES", VALUE=1)
                                                #STATISTICS[DATEITYP]["Files_Processed"] = STATISTICS[DATEITYP]["Files_Processed"] + 1
                                            #except:
                                            #    updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXSD", MODE="ADD", KEY="ERROR", VALUE=1)
                                            #    #STATISTICS[DATEITYP]["Data_Errors"] = STATISTICS[DATEITYP]["Data_Errors"] + 1
                                            #    #GLOBAL_LOGFILE.writeLog("OUT", "Error! Issues while XSD-Checking. Trying to continue with other objects...")
                                            #    #LOGFILE.writeLog( "CRIT", "Issues while XSD-Checking. Trying to continue with other objects...")
                                            #    self.LOGFILE.put({"checkxsd": ["ERROR", time.localtime(), "Nicht behandelbarer CHECKXSD-Fehler bei Bearbeitung von: " + str(FILENAME)]})
                                        # Wenn XPATH nicht geprüft werden soll, tu halt nix...
                                    # Dies schließt das Logging für dieses Objekt ab.

                else:
                    self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "CheckXSD got unrecognized command dict: " + str(QUEUE_COMMAND)]})

                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "quit":
                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "CheckXSDThread quitting as requested."]})
                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break
            else:
                self.LOGFILE.put({"checkxsd": ["DEBUG", time.localtime(), "XSD-Check issued for: " + str(QUEUE_COMMAND)]})
                self.JOBQUEUE.task_done()


class CheckXPATHThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, JOBQUEUE):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.JOBQUEUE = JOBQUEUE
        self.POWERSWITCH = POWERSWITCH

    def findInIconVal(self, OBJECT="", SUBOBJECT="", FUNCTION=""):
        RETURNVALUE = False
        if isinstance(ICON_VALIDATION_DICT, dict):
            for IV_OBJECTS in ICON_VALIDATION_DICT.keys():
                UPPER_IV_OBJECTS = str(IV_OBJECTS).upper()
                if UPPER_IV_OBJECTS == str(OBJECT).upper():
                    if SUBOBJECT != "":
                        if isinstance(ICON_VALIDATION_DICT[IV_OBJECTS], dict):
                            if SUBOBJECT in ICON_VALIDATION_DICT[IV_OBJECTS].keys():
                                if FUNCTION != "":
                                    if FUNCTION in ICON_VALIDATION_DICT[IV_OBJECTS][SUBOBJECT].keys() and len(ICON_VALIDATION_DICT[IV_OBJECTS][SUBOBJECT][FUNCTION])>0:
                                        RETURNVALUE = True
                                    else:
                                        pass
                                else:
                                    RETURNVALUE = True
                            else:
                                pass
                        else:
                            pass
                    else:
                        RETURNVALUE = True
                else:
                    pass
        else:
            pass
        return RETURNVALUE

    def normalizeTransDict(self, OBJECT):
        RETURNVALUE = False
        if isinstance(TRANSLATION_DICT, dict):
            for TR_OBJECTS in TRANSLATION_DICT.keys():
                UPPER_TR_OBJECTS = str(TR_OBJECTS).upper()
                if UPPER_TR_OBJECTS == str(OBJECT).upper():
                    RETURNVALUE = TR_OBJECTS
        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "normalizeTransDict: " + str(OBJECT) + " -> " + str(RETURNVALUE)]})
        return RETURNVALUE

    def normalizeIconDict(self, OBJECT, SUBOBJECT):
        RETURNVALUE = False
        if isinstance(ICON_VALIDATION_DICT, dict):
            if isinstance(TRANSLATION_DICT, dict) and OBJECT in TRANSLATION_DICT.keys() and SUBOBJECT in TRANSLATION_DICT[OBJECT].keys() and "VALIDATE" in TRANSLATION_DICT[OBJECT][SUBOBJECT].keys():
                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Survived the big IF!"]})
                UNREFINED_OPERATION = TRANSLATION_DICT[OBJECT][SUBOBJECT]["VALIDATE"]
                RETURNVALUE = []
                for REFINED_OPERATION in UNREFINED_OPERATION:
                    if REFINED_OPERATION in ICON_VALIDATION_DICT.keys() and SUBOBJECT in ICON_VALIDATION_DICT[REFINED_OPERATION]:
                        RETURNVALUE.append(REFINED_OPERATION)
        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "normalizeIconDict: " + str(OBJECT) + "_" + str(SUBOBJECT) + " -> " + str(RETURNVALUE)]})
        return RETURNVALUE

    def mapXmlToLogName(self, OBJECT, SUBOBJECT):
        global TRANSLATION_DICT
        #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "mapXmlToLogName: TRANSLATION_DICT" + str(TRANSLATION_DICT)]})
        RESULT = {}
        for KEYS in TRANSLATION_DICT.keys():
            #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "1mapXmlToLogName: KEYS " + str(KEYS) + " -> " + str(OBJECT)]})
            if str(KEYS).upper() == str(OBJECT).upper():
                #self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "2mapXmlToLogName: " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) + " -> " + str(len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])) + " -> " + str(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"])]})
                if len(TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]) == len(TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"]):
                    i=0
                    for VALIDATES in TRANSLATION_DICT[KEYS][SUBOBJECT]["VALIDATE"]:
                        RESULT[VALIDATES] = TRANSLATION_DICT[KEYS][SUBOBJECT]["FILENAME"][i]
                        i += 1
        self.LOGFILE.put({"extraction": ["DEBUG", time.localtime(), "CheckXPath: mapXmlToLogName: SENDING BACK " + str(RESULT)]})
        return RESULT


    def run(self):
        global STATISTICS
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        while True:
            QUEUE_COMMAND = self.JOBQUEUE.get()
            if QUEUE_COMMAND == "init":
                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "CheckXPATHThread initializing"]})
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict):
                if QUEUE_COMMAND.has_key("initverification"):
                    for OBJECTS in QUEUE_COMMAND["initverification"].keys():
                        SUBOBJECTS = QUEUE_COMMAND["initverification"][OBJECTS]
                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "CheckXPATH: initverification received. Acting."]})
                        MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "CheckXPATH MAP_DICT: " + str(MAP_DICT)]})
                        for XPATHVALIDATES in MAP_DICT.keys():
                            SPECIAL = MAP_DICT[XPATHVALIDATES]
                            if XPATHVALIDATES in ICON_VALIDATION_DICT.keys() and SUBOBJECTS in ICON_VALIDATION_DICT[XPATHVALIDATES].keys() and "ValidationXPath" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys() and "ValidationSQL" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys():
                                self.LOGFILE.put({"checkxpath": ["initlog", OBJECTS, SUBOBJECTS]})
                                updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="NEW", KEY="START", VALUE=time.localtime())
                                updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="ADD", KEY="ERROR", VALUE=0)
                                updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="ADD", KEY="RESULT_SQL", VALUE=0)
                                if STATISTICS[OBJECTS][SUBOBJECTS][SPECIAL]["CHECKXPATH"]["RESULT_SQL"]==0:
                                    try:
                                    #if True:
                                        # Da nicht immer klar ist, welcher Connection-String benötigt wird, prüfen wir das doch einfach
                                        # direkt im SQL. Je nach Variante wird auch gleich die Verbindung aufgezogen.
                                        if str(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationSQL"]).upper().find("SIMEX_DB_LINK") > -1:
                                            self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPATH_SQL: Connecting using SIMEX-Link."]})
                                            CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                                        else:
                                            self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPATH_SQL: Connecting using DB-Link."]})
                                            CONNECTION = cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_DB"])
                                        # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                                        SQL = CONNECTION.cursor()
                                        #self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Querying with: " + str(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationSQL"])]})
                                        SQL.execute(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationSQL"])
                                        # Wir sind mutig und holen gleich alle Ergebnisse.
                                        XPATH_SQL_RESULT=SQL.fetchall()
                                        # Ähnlich wie beim XPATH. Wir zählen die einzelnen Ergebnismengen und pappen sie in das Ergebnis.
                                        # Anders als bei XPATH gibts aber nur eins. Also wird der bestehende Wert überschrieben
                                        updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="ADD", KEY="RESULT_SQL", VALUE=len(XPATH_SQL_RESULT))
                                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Result of XPATH SQL Check: " + str(len(XPATH_SQL_RESULT))]})
                                        # Aufräumen...
                                        CONNECTION.close()

                                        # Und SQL-Ergebnisse auswerten.
                                        # Gleiche Prozedur wie oben... bei Existenz eines Sub-Objekttypes gibts etwas mehr Arbeit...
                                        #if XPATH_ADDITIONAL_PARAM != "NONE":
                                        #    # (Bestehender SQL_CSV-Dateiname aus vorherigen Iterationen weicht vom zusammengebauten Namen ab?)
                                        #    if str(XPATH_SQL_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                        #        # Wenn ja, war hier wohl noch keiner. Also schreiben wir...
                                        #        XPATH_SQL_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                        #        FILE_OBJ_XPATH_SQL = codecs.open(XPATH_SQL_FILE_NAME, "w", encoding="utf-8")

                                        #else:
                                        #    # (Bestehender SQL_CSV-Dateiname aus vorherigen Iterationen weicht vom zusammengebauten Namen ab?)
                                        #    if str(XPATH_SQL_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                        #        # Wenn ja, war hier wohl noch keiner. Also schreiben wir...
                                        #        XPATH_SQL_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                        #        FILE_OBJ_XPATH_SQL = codecs.open(XPATH_SQL_FILE_NAME, "w", encoding="utf-8")

                                        # Die Ergebnisse Datensatz für Datensatz jeweils das erste Ergebnis
                                        COMBINED_CSV_KEY= str(OBJECTS) + "_" + str(SUBOBJECTS) + "_(" + str(XPATHVALIDATES) + ")"
                                        for LINES in XPATH_SQL_RESULT:
                                            VAR0=str(LINES[0])
                                            # nach dem üblichen Coding-Gerümpel
                                            VARA= VAR0.decode(str(CONFIG_DICT["ENVIRONMENT"]["ENCODING_DB"]))
                                            VARB= VARA.encode("utf-8")
                                            #VARB= VARA.encode("utf-8") + os.linesep
                                            VARE = VARB.decode("utf-8")
                                            # in die bereitgestellte Datei.
                                            self.LOGFILE.put({"checkxpath": ["CSV_RESULT", time.localtime(), {COMBINED_CSV_KEY:{"SQL":[VARE]}}]})

                                        #    FILE_OBJ_XPATH_SQL.write(VARE)

                                        # Aufräumen! \o/
                                        #FILE_OBJ_XPATH_SQL.close()
                                        #else:
                                        #    self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Could not find a valid OBJECT/SUBOBJECT definition: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(OPERATION)]})

                                        # Fehlerhandling... insbesondere bei SQL geht das schnell, wenn die DB mal "weg" ist.
                                        # Wobei wir da nur eine laidare Fehlermeldung auswerfen.
                                        # (Man sieht im Ergbnis sehr gut, ob da vielleicht irgendwo was schiefgelaufen ist...
                                        XPATH_SQL_RESULT = ""
                                    except:
                                        self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "Could not SQL_QUERY for " + str(XPATHVALIDATES) + " -> " + str(SUBOBJECTS)]})
                                        #GLOBAL_LOGFILE.writeLog("OUT", "Could not SQL_Query for: " + str(XPATH_BASE_OPERATION) + " / " + str( XPATH_ADDITIONAL_PARAM ))
                                        XPATH_SQL_RESULT = ""

                                else:
                                    self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPATH-SQL-Check has been executed already for: " + str(OBJECTS) + " -> " + str(SUBOBJECTS)]})
                                    self.FULL_XSD_PATH = False
                            else:
                                self.LOGFILE.put({"checkxpath": ["WARN", time.localtime(), "We don't have ValidationXPath / ValidationSQL-Values! -> " + str(OBJECTS) + " -> " + str(SUBOBJECTS) + " (" + str(XPATHVALIDATES) + ")"]})

                elif QUEUE_COMMAND.has_key("verify"):
                    for OBJECTS in QUEUE_COMMAND["verify"].keys():
                        for SUBOBJECTS in QUEUE_COMMAND["verify"][OBJECTS].keys():
                            for FILENAME in QUEUE_COMMAND["verify"][OBJECTS][SUBOBJECTS]:
                                SPECIAL_FOUND = False
                                MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "CheckXPATH MAP_DICT: " + str(MAP_DICT)]})
                                for SPECIAL in MAP_DICT.values():
                                    for TMPVALIDATES in MAP_DICT.keys():
                                        if SPECIAL in MAP_DICT[TMPVALIDATES]:
                                            XPATHVALIDATES = str(TMPVALIDATES)
                                    if len(MAP_DICT)>0:
                                        for ENTRIES in MAP_DICT.values():
                                            if ENTRIES != "NONE" and string.find(FILENAME,ENTRIES)!=-1:
                                                SPECIAL_FOUND = True
                                    if not ((SPECIAL_FOUND is True and SPECIAL == "NONE") or (SPECIAL_FOUND == False and SPECIAL != "NONE")):
                                        if string.find(FILENAME,SPECIAL)!=-1 or SPECIAL == "NONE":
                                            if XPATHVALIDATES in ICON_VALIDATION_DICT.keys() and SUBOBJECTS in ICON_VALIDATION_DICT[XPATHVALIDATES].keys() and "ValidationXPath" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys() and "ValidationSQL" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys():
                                                if OBJECTS in STATISTICS.keys() \
                                                        and SUBOBJECTS in STATISTICS[OBJECTS].keys() \
                                                        and SPECIAL in STATISTICS[OBJECTS][SUBOBJECTS].keys() \
                                                        and ("CHECKXPATH" in STATISTICS[OBJECTS][SUBOBJECTS][SPECIAL].keys()
                                                             and "RESULT_SQL" in STATISTICS[OBJECTS][SUBOBJECTS][SPECIAL]["CHECKXPATH"]
                                                             and STATISTICS[OBJECTS][SUBOBJECTS][SPECIAL]["CHECKXPATH"]["RESULT_SQL"] > 0):
                                                    self.LOGFILE.put({"checkxpath": ["LOGFILE", time.localtime(), "Checking XPATH for: " + str(FILENAME)]})
                                                    self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Checking XPATH for: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(FILENAME)]})
                                                    if not os.path.isfile(FILENAME):
                                                        FILENAME = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + FILENAME
                                                        if not os.path.isfile(FILENAME):
                                                            self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "FILE NOT FOUND: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(FILENAME)]})
                                                            break
                                                    #GLOBAL_LOGFILE.writeLog("OUT", "Checking against Reference XSD: " + str(self.FULL_XSD_PATH))
                                                    #GLOBAL_LOGFILE.writeLog("OUT", "Validating (XSD): " + str( XML_FILES))
                                                    #self.LOGFILE.put({"checkxpath": ["LOGONLY", time.localtime(), "Checking XPATH for: " + str(FILENAME)]})
                                                    #LOGFILE.writeLog( "INFO", str("Validating: " + str(XML_FILES)) )
                                                    #LOGFILE.writeLog( "INFO", str("Against XSD: " + str(FULL_XSD_PATH)) )
                                                    # Vorbereitung / Laden des Files
                                                    if "ExtractFileType" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys() and ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ExtractFileType"] == "XML":
                                                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPath: Checking in XML-Mode:" + str(FILENAME)]})
                                                        TREE = etree.parse(FILENAME)
                                                        ROOT = TREE.getroot()
                                                        #PARSER = etree.XMLParser(no_network = True, resolve_entities=False, strip_cdata=False, compact=False)
                                                        XPATH_XPATH_RESULT = ROOT.xpath(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationXPath"])
                                                        updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="ADD", KEY="RESULT_XPATH", VALUE=len(XPATH_XPATH_RESULT))
                                                        COMBINED_CSV_KEY= str(OBJECTS) + "_" + str(SUBOBJECTS) + "_(" + str(XPATHVALIDATES) + ")"
                                                        for LINES in XPATH_XPATH_RESULT:
                                                            VAR0=LINES
                                                            VARA= VAR0.encode("utf-8")
                                                            VARB= VARA + os.linesep.encode("utf-8")
                                                            #VARE = VARB.decode("utf-8")
                                                            VARE = VARA.decode("utf-8")
                                                            self.LOGFILE.put({"checkxpath": ["CSV_RESULT", time.localtime(), {COMBINED_CSV_KEY:{"XPATH":[VARE]}}]})
                                                        TREE = ""
                                                        ROOT = ""
                                                        XPATH_XPATH_RESULT = ""
                                                    elif "ExtractFileType" in ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS].keys() and ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ExtractFileType"] == "CSV":
                                                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPath: Checking in CSV-Mode:" + str(FILENAME)]})
                                                        if str(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationXPath"][0:4]) == "CSV:":
                                                            _, WORKSTRING = str(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationXPath"]).split("CSV:", 1)
                                                            CSVDELIMITER = "ABC"
                                                            CSVNAME = ""
                                                            if WORKSTRING.find("DELIMIT:") != -1:
                                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: Found DELIMIT-Keyword."]})
                                                                if WORKSTRING[0:8] == "DELIMIT:":
                                                                    if len(WORKSTRING) > 8:
                                                                        _, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                    else:
                                                                        TMPSPLITB = ""
                                                                else:
                                                                    if WORKSTRING[-8:] != "DELIMIT:":
                                                                        TMPSPLITA, TMPSPLITB = WORKSTRING.split("DELIMIT:", 1)
                                                                    else:
                                                                        TMPSPLITB = ""
                                                                if TMPSPLITB.find(":") != -1:
                                                                    if TMPSPLITB[1] == ":":
                                                                        CSVDELIMITER = TMPSPLITB[0]
                                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: DELIMITER is: " + str(CSVDELIMITER)]})
                                                            if WORKSTRING.find("NAME:") != -1:
                                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: Found NAME-Keyword."]})
                                                                if WORKSTRING[0:5] == "NAME:":
                                                                    if len(WORKSTRING)> 5:
                                                                        _, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                    else:
                                                                        TMPSPLITB = ""
                                                                else:
                                                                    if WORKSTRING[-5:] != "NAME:":
                                                                        TMPSPLITA, TMPSPLITB = WORKSTRING.split("NAME:", 1)
                                                                    else:
                                                                        TMPSPLITB = ""
                                                                if len(TMPSPLITB) > 0 and TMPSPLITB.find(":") == -1:
                                                                    CSVNAME = TMPSPLITB
                                                                else:
                                                                    CSVNAME = ""

                                                            if CSVNAME != "":
                                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPathCSV: Doing File analysis now."]})
                                                                try:
                                                                    COMBINED_CSV_KEY= str(OBJECTS) + "_" + str(SUBOBJECTS) + "_(" + str(XPATHVALIDATES) + ")"
                                                                    CSVFILE = open(FILENAME, "rb")
                                                                    CSVREADER = csv.DictReader(CSVFILE, delimiter=CSVDELIMITER)
                                                                    #print "Fieldnames:", reader.fieldnames
                                                                    CSVVALUE = 0
                                                                    for CSVLINES in CSVREADER:
                                                                        CSVVALUE += 1
                                                                        self.LOGFILE.put({"checkxpath": ["CSV_RESULT", time.localtime(), {COMBINED_CSV_KEY:{"XPATH":[CSVLINES[CSVNAME]]}}]})
                                                                        #print lines[CSVNAME]
                                                                    updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="ADD", KEY="RESULT_XPATH", VALUE=CSVVALUE)
                                                                    CSVFILE.close()
                                                                except:
                                                                    self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "Could not load payload from CSV-file: " + str(FILENAME)]})
                                                            else:
                                                                self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "The configuration is invalid for 'XPath-checking' this object: " + str(FILENAME)]})
                                                        else:
                                                            self.LOGFILE.put({"checkxpath": ["ERROR", time.localtime(), "The configuration is invalid! Running in CSV-Mode, but no CSV-Header for XPath! " + str(ICON_VALIDATION_DICT[XPATHVALIDATES][SUBOBJECTS]["ValidationXPath"])]})
                                                    else:
                                                        self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Could not find the CSV/XML definitio for my file: " + str(FILENAME)]})
                                                else:
                                                    self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "FILE could not be processed because function is not initialized: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(FILENAME)]})
                                            else:
                                                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "Could not find a valid OBJECT/SUBOBJECT definition: " + str(OBJECTS) + "_" + str(SUBOBJECTS) + " -> " + str(XPATHVALIDATES)]})

                elif QUEUE_COMMAND.has_key("endverification"):
                    for OBJECTS in QUEUE_COMMAND["endverification"].keys():
                        SUBOBJECTS = QUEUE_COMMAND["endverification"][OBJECTS]
                        MAP_DICT = self.mapXmlToLogName(OBJECTS, SUBOBJECTS)
                        for XPATHVALIDATES in MAP_DICT.keys():
                            SPECIAL = MAP_DICT[XPATHVALIDATES]
                            updateStatistics(OBJECT=OBJECTS, SUBOBJECT=SUBOBJECTS, SPECIAL=SPECIAL, STATTYPE="CHECKXPATH", MODE="NEW", KEY="END", VALUE=time.localtime())
                        self.LOGFILE.put({"checkxsd": ["endlog", OBJECTS, SUBOBJECTS]})

                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "quit":
                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "CheckXPATHThread quitting as requested."]})
                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break
            else:
                self.LOGFILE.put({"checkxpath": ["DEBUG", time.localtime(), "XPath-Check issued for: " + str(QUEUE_COMMAND)]})
                self.JOBQUEUE.task_done()


class CheckIntegrityThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, JOBQUEUE):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.JOBQUEUE = JOBQUEUE
        self.POWERSWITCH = POWERSWITCH
        self.INTDB = {}
        self.GCTIMER = 0
        self.GC_ENABLED = True

    def run(self):
        global CONFIG_DICT
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        TMPO=0

        while True:
            if self.GCTIMER > CONFIG_DICT["ENVIRONMENT"]["GARBAGECOLLECTORCOUNTER"]:
                self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), "CheckIntegrityThread is cleaning up"]})
                self.GCTIMER = 0
                gc.collect()
            else:
                self.GCTIMER += 1
            QUEUE_COMMAND = self.JOBQUEUE.get()

            if QUEUE_COMMAND == "init":
                self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), "CheckIntegrityThread initializing"]})
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict):
                if QUEUE_COMMAND.has_key("initverification"):
                    pass
                elif QUEUE_COMMAND.has_key("checkintownkey"):
                    if self.GC_ENABLED is True and CONFIG_DICT["ENVIRONMENT"]["GARBAGECOLLECTORCOUNTER"] > 100:
                        self.GC_ENABLED = False
                        gc.disable()
                    if isinstance(QUEUE_COMMAND["checkintownkey"], dict):
                        for QUEUE_KEYS in QUEUE_COMMAND["checkintownkey"].keys():
                            if isinstance(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS], list) and len(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS]) == 5:
                                KEY = str(QUEUE_KEYS)
                                OBJECT = str(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS][0])
                                SUBOBJECT = str(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS][1])
                                SPECIAL = str(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS][2])
                                VALUE = str(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS][3])
                                FILE = str(QUEUE_COMMAND["checkintownkey"][QUEUE_KEYS][4])
                                updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="OWN_KEYS_ERROR", VALUE=0)
                                updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="OWN_KEYS_CREATE_COUNT", VALUE=0)

                                #self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), "CheckIntegrityThread got 'SET OWN KEY' for: " + KEY + " -> " + VALUE + " (" + str(FILE) + ")"]})
                                if KEY not in self.INTDB.keys():
                                    self.INTDB[KEY]={}
                                if "VALUES" not in self.INTDB[KEY].keys():
                                    self.INTDB[KEY]["VALUES"]=set()
                                if "FILE" not in self.INTDB[KEY].keys():
                                    self.INTDB[KEY]["FILE"]={}
                                if FILE not in self.INTDB[KEY]["FILE"].keys():
                                    self.INTDB[KEY]["FILE"][FILE] = []
                                if VALUE in self.INTDB[KEY]["VALUES"]:
                                    self.LOGFILE.put({"checkint": ["ERROR", time.localtime(), "Found unique ID more than one time: " + KEY + " -> " + VALUE + " (" + FILE + ")"]})
                                    updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="OWN_KEYS_ERROR", VALUE=1)
                                else:
                                    self.INTDB[KEY]["VALUES"].add(VALUE)
                                    #self.INTDB[KEY]["FILE"][FILE].append(self.INTDB[KEY]["VALUES"].index(VALUE))
                                    self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), "OWNKEY: Set KEY -> VALUE: " + KEY + " -> " + VALUE + " (" + FILE + ")"]})
                                    updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="OWN_KEYS_CREATE_COUNT", VALUE=1)

                elif QUEUE_COMMAND.has_key("checkintremotekey"):
                    TMPO += 1
                    if isinstance(QUEUE_COMMAND["checkintremotekey"], dict):
                        for QUEUE_KEYS in QUEUE_COMMAND["checkintremotekey"].keys():
                            self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread got: " + str(len(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS])) + " -> " + str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS])]})
                            if isinstance(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS], list) and len(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS])==6:
                                self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread got 'CHECKREMOTEKEY' with: " + str(QUEUE_COMMAND["checkintremotekey"])]})
                                #KEY = str(QUEUE_KEYS)
                                OBJECT = str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][0])
                                SUBOBJECT = str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][1])
                                SPECIAL = str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][2])
                                VALUE = str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][3])
                                FILE = str(QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][4])
                                FK_RESULTS = QUEUE_COMMAND["checkintremotekey"][QUEUE_KEYS][5]
                                updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="REMOTE_KEYS_CHECK_ERROR", VALUE=0)
                                updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="REMOTE_KEYS_CHECK_SUCCESS", VALUE=0)
                                updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="REMOTE_KEYS_CHECK_COUNT", VALUE=1)
                                POSITIVE_RESULT = False
                                for KEY in FK_RESULTS:
                                    self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread got 'CHECK REMOTE KEY': " + str(KEY) + " -> " + str(VALUE) + " (" + str(type(VALUE)) + ")"]})
                                    if KEY in self.INTDB.keys() and "VALUES" in self.INTDB[KEY].keys() and VALUE in self.INTDB[KEY]["VALUES"]:
                                        self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Got VALUE: " + str(VALUE)]})
                                        POSITIVE_RESULT = True
                                    else:
                                        if KEY in self.INTDB.keys():
                                            self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Got KEY: " + str(KEY)]})
                                            if "VALUES" in self.INTDB[KEY].keys():
                                                self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Got 'VALUES'. Will check now for: "+ str(VALUE)]})
                                                if VALUE in self.INTDB[KEY]["VALUES"]:
                                                    self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Oops. In the recheck we got a result now?!: " + str(VALUE)]})
                                                else:
                                                    self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: I have values for this, but not this one: " + str(VALUE)]})
                                        else:
                                            self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Got no result for: " + str(KEY) + " -> " + str(self.INTDB.keys())]})

                                if POSITIVE_RESULT:
                                    self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), str(TMPO) + " CheckIntegrityThread: Got a valid result for: " + str(KEY) + " -> " + str(self.INTDB.keys())]})
                                    updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="REMOTE_KEYS_CHECK_SUCCESS", VALUE=1)
                                else:
                                    KEYSTRING = ""
                                    for KEY in FK_RESULTS:
                                        KEYSTRING += str(KEY) + "/ "
                                    if len(KEYSTRING)>2:
                                        KEYSTRING = KEYSTRING[0:-2]
                                    self.LOGFILE.put({"checkint": ["ERROR", time.localtime(), "Could not find remote key: " + KEYSTRING + " -> " + VALUE + " ( Found while checking file: " + FILE + ")"]})
                                    updateStatistics(OBJECT=OBJECT, SUBOBJECT=SUBOBJECT, SPECIAL=SPECIAL, STATTYPE="INTEGRITY", MODE="ADD", KEY="REMOTE_KEYS_CHECK_ERROR", VALUE=1)

                self.JOBQUEUE.task_done()
            elif QUEUE_COMMAND == "quit":
                self.LOGFILE.put({"checkint": ["DEBUG", time.localtime(), "CheckIntegrityThread quitting as requested."]})
                self.GC_ENABLED = True
                gc.enable()
                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break
            else:
                self.LOGFILE.put(
                    {"checkint": ["DEBUG", time.localtime(), "Integrity-Check issued for: " + str(QUEUE_COMMAND)]})
                self.JOBQUEUE.task_done()


class LoggingThread(threading.Thread):
    def __init__(self, POWERSWITCH, JOBQUEUE):
        threading.Thread.__init__(self)
        self.JOBQUEUE = JOBQUEUE
        self.POWERSWITCH = POWERSWITCH
        self.LOGGING_DICT = {}
        self.CSV_DICT = {}
        self.INIT = False
        self.INITIALTIMESTAMP = str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGNAME_TIMESTAMP_FORMAT"],time.localtime()))
        self.LOGNAMES = {}
        self.INITMAIN = False

    def writeLogging(self, LOGOBJNAME="", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=100, FORCED=False, MODE="LOG"):
        if LOGOBJNAME == "ALL":
            for KEYS in self.LOGGING_DICT.keys():
                if isinstance(self.LOGGING_DICT[KEYS], dict):
                    for SUBKEYS in self.LOGGING_DICT[KEYS].keys():
                        #print "re-Running myself with: " + str(KEYS) + " -> " + str(SUBKEYS) + " -> " + str(self.LOGGING_DICT[KEYS][SUBKEYS])
                        self.writeLogging(LOGOBJNAME=KEYS, LOGSUBOBJNAME=SUBKEYS, INTERVALL=INTERVALL, FORCED=FORCED)
                else:
                    self.writeLogging(LOGOBJNAME=KEYS, LOGSUBOBJNAME=LOGSUBOBJNAME, INTERVALL=INTERVALL, FORCED=FORCED)
                    #print "re-Running myself with: " + str(KEYS) + " -> " + str(self.LOGGING_DICT[KEYS])

        elif LOGOBJNAME in self.LOGGING_DICT.keys() and self.INITMAIN is True:
            LOGNAME = ""
            if LOGSUBOBJNAME != "":
                if LOGSPECIALTYPE != "":
                    if MODE=="CSV":
                        # YES, YES, YES, YES
                        if isinstance(self.CSV_DICT[LOGOBJNAME], dict) and LOGSUBOBJNAME in self.CSV_DICT[LOGOBJNAME].keys():
                            if isinstance(self.CSV_DICT[LOGOBJNAME][LOGSUBOBJNAME], dict) and LOGSPECIALTYPE in self.CSV_DICT[LOGOBJNAME][LOGSUBOBJNAME].keys():
                                if isinstance(self.CSV_DICT[LOGOBJNAME][LOGSUBOBJNAME][LOGSPECIALTYPE], list):
                                    TMPLIST = self.CSV_DICT[LOGOBJNAME][LOGSUBOBJNAME][LOGSPECIALTYPE]
                                else:
                                    TMPLIST = []
                                if isinstance(self.LOGNAMES, dict) and LOGOBJNAME not in self.LOGNAMES.keys():
                                    self.LOGNAMES[LOGOBJNAME] = {}
                                if isinstance(self.LOGNAMES[LOGOBJNAME], dict) and LOGSUBOBJNAME not in self.LOGNAMES[LOGOBJNAME].keys():
                                    self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME] = {}
                                if isinstance(self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME], dict) and LOGSPECIALTYPE not in self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME].keys():
                                    if "LOGNAME_"+str(LOGOBJNAME) in CONFIG_DICT["ENVIRONMENT"].keys():
                                        TMPLOGNAME = str(CONFIG_DICT["ENVIRONMENT"]["LOGNAME_"+str(LOGOBJNAME)])
                                        if TMPLOGNAME.find("#*TIMESTAMP*#") != -1:
                                            TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", self.INITIALTIMESTAMP)
                                        if TMPLOGNAME.find("#*OBJECT*#") != -1:
                                            TMPLOGNAME = TMPLOGNAME.replace("#*OBJECT*#", str(LOGOBJNAME))
                                        if TMPLOGNAME.find("#*SUBOBJECT*#") != -1:
                                            TMPLOGNAME = TMPLOGNAME.replace("#*SUBOBJECT*#", str(LOGSUBOBJNAME))
                                        if TMPLOGNAME.find("#*LOGTYPE*#") != -1:
                                            TMPLOGNAME = TMPLOGNAME.replace("#*LOGTYPE*#", str(LOGSPECIALTYPE))
                                        if TMPLOGNAME.find("#*DEFECT*#") != -1:
                                            TMPLOGNAME = TMPLOGNAME.replace("#*DEFECT*#", str(LOGSPECIALTYPE))
                                    else:
                                        TMPLOGNAME = str(self.INITIALTIMESTAMP) + "TEMPORARYLOG_(CHECK_AND_FIX_GODDAMNIT)"

                                    if MODE == "LOG":
                                        self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME][LOGSPECIALTYPE] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_ENDING'])
                                    elif MODE == "CSV":
                                        self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME][LOGSPECIALTYPE] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['CSV_ENDING'])
                                    else:
                                        pass
                                LOGNAME = self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME][LOGSPECIALTYPE]

                        else:
                            # Bloed gelaufen... Inkonsistenzen... -.-'
                            TMPLIST = []
                    else:
                        # Bloed gelaufen... Inkonsistenzen... -.-'
                        TMPLIST = []
                else:
                    # YES, YES, NO
                    if isinstance(self.LOGGING_DICT[LOGOBJNAME], dict) and LOGSUBOBJNAME in self.LOGGING_DICT[LOGOBJNAME].keys():
                        if isinstance(self.LOGGING_DICT[LOGOBJNAME][LOGSUBOBJNAME], list):
                            TMPLIST = self.LOGGING_DICT[LOGOBJNAME][LOGSUBOBJNAME]
                        else:
                            TMPLIST = []
                        if isinstance(self.LOGNAMES, dict) and LOGOBJNAME not in self.LOGNAMES.keys():
                            self.LOGNAMES[LOGOBJNAME] = {}
                        if isinstance(self.LOGNAMES[LOGOBJNAME], dict) and LOGSUBOBJNAME not in self.LOGNAMES[LOGOBJNAME].keys():
                            self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME] = {}
                        if isinstance(self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME], dict) and "NONE" not in self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME].keys():
                            if "LOGNAME_"+str(LOGOBJNAME) in CONFIG_DICT["ENVIRONMENT"].keys():
                                TMPLOGNAME = str(CONFIG_DICT["ENVIRONMENT"]["LOGNAME_"+str(LOGOBJNAME)])
                                if TMPLOGNAME.find("#*TIMESTAMP*#") != -1:
                                    TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", self.INITIALTIMESTAMP)
                                if TMPLOGNAME.find("#*OBJECT*#") != -1:
                                    TMPLOGNAME = TMPLOGNAME.replace("#*OBJECT*#", str(LOGOBJNAME))
                                if TMPLOGNAME.find("#*SUBOBJECT*#") != -1:
                                    TMPLOGNAME = TMPLOGNAME.replace("#*SUBOBJECT*#", str(LOGSUBOBJNAME))
                                if TMPLOGNAME.find("#*LOGTYPE*#") != -1:
                                    TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", str(LOGSPECIALTYPE))
                                if TMPLOGNAME.find("#*DEFECT*#") != -1:
                                    TMPLOGNAME = TMPLOGNAME.replace("#*DEFECT*#", str(LOGSPECIALTYPE))
                            else:
                                TMPLOGNAME = str(self.INITIALTIMESTAMP) + "TEMPORARYLOG_(CHECK_AND_FIX_GODDAMNIT)"

                            if MODE == "LOG":
                                self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME]["NONE"] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_ENDING'])
                            elif MODE == "CSV":
                                self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME]["NONE"] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['CSV_ENDING'])
                            else:
                                pass
                        LOGNAME = self.LOGNAMES[LOGOBJNAME][LOGSUBOBJNAME]["NONE"]

                    else:
                        # Bloed gelaufen... Inkonsistenzen... -.-'
                        TMPLIST = []
            else:
                if LOGSPECIALTYPE != "":
                    # YES, NO, YES
                    if isinstance(self.LOGGING_DICT[LOGOBJNAME], dict) and "NONE" in self.LOGGING_DICT[LOGOBJNAME].keys():
                        if isinstance(self.LOGGING_DICT[LOGOBJNAME]["NONE"], dict) and LOGSPECIALTYPE in self.LOGGING_DICT[LOGOBJNAME]["NONE"].keys():
                            if isinstance(self.LOGGING_DICT[LOGOBJNAME]["NONE"][LOGSPECIALTYPE], list):
                                TMPLIST = self.LOGGING_DICT[LOGOBJNAME]["NONE"][LOGSPECIALTYPE]
                            else:
                                TMPLIST = []
                            if isinstance(self.LOGNAMES, dict) and LOGOBJNAME not in self.LOGNAMES.keys():
                                self.LOGNAMES[LOGOBJNAME] = {}
                            if isinstance(self.LOGNAMES[LOGOBJNAME], dict) and "NONE" not in self.LOGNAMES[LOGOBJNAME].keys():
                                self.LOGNAMES[LOGOBJNAME]["NONE"] = {}
                            if isinstance(self.LOGNAMES[LOGOBJNAME]["NONE"], dict) and LOGSPECIALTYPE not in self.LOGNAMES[LOGOBJNAME]["NONE"].keys():
                                if "LOGNAME_"+str(LOGOBJNAME) in CONFIG_DICT["ENVIRONMENT"].keys():
                                    TMPLOGNAME = str(CONFIG_DICT["ENVIRONMENT"]["LOGNAME_"+str(LOGOBJNAME)])
                                    if TMPLOGNAME.find("#*TIMESTAMP*#") != -1:
                                        TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", self.INITIALTIMESTAMP)
                                    if TMPLOGNAME.find("#*OBJECT*#") != -1:
                                        TMPLOGNAME = TMPLOGNAME.replace("#*OBJECT*#", str(LOGOBJNAME))
                                    if TMPLOGNAME.find("#*SUBOBJECT*#") != -1:
                                        TMPLOGNAME = TMPLOGNAME.replace("#*SUBOBJECT*#", str(LOGSUBOBJNAME))
                                    if TMPLOGNAME.find("#*LOGTYPE*#") != -1:
                                        TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", str(LOGSPECIALTYPE))
                                    if TMPLOGNAME.find("#*DEFECT*#") != -1:
                                        TMPLOGNAME = TMPLOGNAME.replace("#*DEFECT*#", str(LOGSPECIALTYPE))
                                else:
                                    TMPLOGNAME = str(self.INITIALTIMESTAMP) + "TEMPORARYLOG_(CHECK_AND_FIX_GODDAMNIT)"

                                if MODE == "LOG":
                                    self.LOGNAMES[LOGOBJNAME]["NONE"][LOGSPECIALTYPE] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_ENDING'])
                                elif MODE == "CSV":
                                    self.LOGNAMES[LOGOBJNAME]["NONE"][LOGSPECIALTYPE] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['CSV_ENDING'])
                                else:
                                    pass
                            LOGNAME = self.LOGNAMES[LOGOBJNAME]["NONE"][LOGSPECIALTYPE]
                        else:
                            # Bloed gelaufen... Inkonsistenzen... -.-'
                            TMPLIST = []
                    else:
                        # Bloed gelaufen... Inkonsistenzen... -.-'
                        TMPLIST = []
                else:
                    # YES, NO, NO
                    if isinstance(self.LOGGING_DICT[LOGOBJNAME], list):
                        TMPLIST = self.LOGGING_DICT[LOGOBJNAME]
                    else:
                        TMPLIST = []
                    if isinstance(self.LOGNAMES, dict) and LOGOBJNAME not in self.LOGNAMES.keys():
                        self.LOGNAMES[LOGOBJNAME] = {}
                    if isinstance(self.LOGNAMES[LOGOBJNAME], dict) and "NONE" not in self.LOGNAMES[LOGOBJNAME].keys():
                        self.LOGNAMES[LOGOBJNAME]["NONE"] = {}
                    if isinstance(self.LOGNAMES[LOGOBJNAME]["NONE"], dict) and "NONE" not in self.LOGNAMES[LOGOBJNAME]["NONE"].keys():
                        if "LOGNAME_"+str(LOGOBJNAME) in CONFIG_DICT["ENVIRONMENT"].keys():
                            TMPLOGNAME = str(CONFIG_DICT["ENVIRONMENT"]["LOGNAME_"+str(LOGOBJNAME)])
                            if TMPLOGNAME.find("#*TIMESTAMP*#") != -1:
                                TMPLOGNAME = TMPLOGNAME.replace("#*TIMESTAMP*#", self.INITIALTIMESTAMP)
                            if TMPLOGNAME.find("#*OBJECT*#") != -1:
                                TMPLOGNAME = TMPLOGNAME.replace("#*OBJECT*#", str(LOGOBJNAME))
                            if TMPLOGNAME.find("#*SUBOBJECT*#") != -1:
                                TMPLOGNAME = TMPLOGNAME.replace("#*SUBOBJECT*#", str(LOGSUBOBJNAME))
                            if TMPLOGNAME.find("#*LOGTYPE*#") != -1:
                                TMPLOGNAME = TMPLOGNAME.replace("#*LOGTYPE*#", str(LOGSPECIALTYPE))
                            if TMPLOGNAME.find("#*DEFECT*#") != -1:
                                TMPLOGNAME = TMPLOGNAME.replace("#*DEFECT*#", str(LOGSPECIALTYPE))
                        else:
                            TMPLOGNAME = str(self.INITIALTIMESTAMP) + "TEMPORARYLOG_(CHECK_AND_FIX_GODDAMNIT)"
                        if MODE == "LOG":
                            self.LOGNAMES[LOGOBJNAME]["NONE"]["NONE"] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_ENDING'])
                        elif MODE == "CSV":
                            self.LOGNAMES[LOGOBJNAME]["NONE"]["NONE"] = str(CONFIG_DICT["ENVIRONMENT"]['PATH_TO_LOGFILES']) + str(CONFIG_DICT["ENVIRONMENT"]['LOGFILE_PREFIX']) + TMPLOGNAME + "." + str(CONFIG_DICT["ENVIRONMENT"]['CSV_ENDING'])
                        else:
                            pass
                    LOGNAME = self.LOGNAMES[LOGOBJNAME]["NONE"]["NONE"]

            if isinstance(TMPLIST, list) and len(TMPLIST) > 0:
                if (len(TMPLIST) >= INTERVALL or FORCED is True) and len(LOGNAME) > 0:
                    try:
                        with codecs.open(LOGNAME, "a", encoding="utf-8") as FILELINK:
                            while len(TMPLIST) > 0:
                                ENTRIES = TMPLIST.pop(0)
                                FILELINK.writelines(ENTRIES)
                                FILELINK.write("\r\n")

                    except EnvironmentError:
                        print "ERROR: Could not open file for writing: " + str(LOGNAME)

                    except:
                        print "ERROR: Could not add following content to logfile: " + str(TMPLIST)
        else:
            pass

    def run(self):
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        global CONFIG_DICT
        while True:
            QUEUE_COMMAND = self.JOBQUEUE.get()
            if QUEUE_COMMAND == "init":
                if not self.INIT:
                    if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                        print "LoggingThread initializing"
                    self.INIT = True
                else:
                    pass
                self.JOBQUEUE.task_done()
            elif isinstance(QUEUE_COMMAND, dict) and "main" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("MAIN"):
                    self.LOGGING_DICT["MAIN"]=[]
                if len(QUEUE_COMMAND["main"]) == 3:
                    if QUEUE_COMMAND["main"][0] == "INFO" or QUEUE_COMMAND["main"][0] == "WARN":
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + "; MAIN; " + str(QUEUE_COMMAND["main"][0]) + "; " + str(QUEUE_COMMAND["main"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + ": " + str(QUEUE_COMMAND["main"][0]) + ": " + str(QUEUE_COMMAND["main"][2])
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    elif QUEUE_COMMAND["main"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + "; " + str(QUEUE_COMMAND["main"][0]) + "; " + str(QUEUE_COMMAND["main"][2])
                            self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + ": MAIN: " + str(QUEUE_COMMAND["main"][0]) + ": " + str(QUEUE_COMMAND["main"][2]))
                            self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["main"][0] == "ERROR":
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + "; MAIN; " + str(QUEUE_COMMAND["main"][0]) + "; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + ": " + str(QUEUE_COMMAND["main"][0]) + ": !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + "; MAIN; " + str(QUEUE_COMMAND["main"][0]) + "; " + str(QUEUE_COMMAND["main"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + ": " + str(QUEUE_COMMAND["main"][0]) + ": " + str(QUEUE_COMMAND["main"][2])
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + "; MAIN; " + str(QUEUE_COMMAND["main"][0]) + "; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["main"][1])) + ": " + str(QUEUE_COMMAND["main"][0]) + ": !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)

                    elif QUEUE_COMMAND["main"][0] == "initlog":
                        self.INITMAIN = True
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=True)

                    else:
                        print "MAIN:", QUEUE_COMMAND["main"]

                else:
                    print "MAIN: INVALID REQUEST! ->", QUEUE_COMMAND["main"]

                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "filecheck" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("MAIN"):
                    self.LOGGING_DICT["MAIN"]=[]
                if len(QUEUE_COMMAND["filecheck"]) == 3:
                    if QUEUE_COMMAND["filecheck"][0] == "INFO" or QUEUE_COMMAND["filecheck"][0] == "WARN":
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + "; MAIN; " + str(QUEUE_COMMAND["filecheck"][0]) + "; " + str(QUEUE_COMMAND["filecheck"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + ": " + str(QUEUE_COMMAND["filecheck"][2])
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    elif QUEUE_COMMAND["filecheck"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + "; MAIN; " + str(QUEUE_COMMAND["filecheck"][0]) + "; " + str(QUEUE_COMMAND["filecheck"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + ": " + str(QUEUE_COMMAND["filecheck"][2])
                            self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    elif QUEUE_COMMAND["filecheck"][0] == "ERROR":
                        #self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + ": !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + "; MAIN; " + str(QUEUE_COMMAND["filecheck"][0]) + "; " + str(QUEUE_COMMAND["filecheck"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + ": " + str(QUEUE_COMMAND["filecheck"][2])
                        #self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + ": !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["filecheck"][1])) + ": " + str(QUEUE_COMMAND["filecheck"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    else:
                        print "FILECHECK:", QUEUE_COMMAND["filecheck"]
                else:
                    print "FILECHECK: INVALID REQUEST! ->", QUEUE_COMMAND["filecheck"]
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "configrunner" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("MAIN"):
                    self.LOGGING_DICT["MAIN"]=[]
                if len(QUEUE_COMMAND["configrunner"]) == 3:
                    if QUEUE_COMMAND["configrunner"][0] == "INFO" or QUEUE_COMMAND["configrunner"][0] == "WARN":
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + "; MAIN; " + str(QUEUE_COMMAND["configrunner"][0]) + "; " + str(QUEUE_COMMAND["configrunner"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + ": " + str(QUEUE_COMMAND["configrunner"][2])
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    elif QUEUE_COMMAND["configrunner"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + "; MAIN; " + str(QUEUE_COMMAND["configrunner"][0]) + "; " + str(QUEUE_COMMAND["configrunner"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + ": " + str(QUEUE_COMMAND["configrunner"][2])
                            self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["configrunner"][0] == "ERROR":
                        #self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + "; MAIN; " + str(QUEUE_COMMAND["configrunner"][0]) + "; " + str(QUEUE_COMMAND["configrunner"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + ": " + str(QUEUE_COMMAND["configrunner"][2])
                        #self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["configrunner"][1])) + ": " + str(QUEUE_COMMAND["configrunner"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", INTERVALL=1, FORCED=False)
                    else:
                        print "configrunner:", QUEUE_COMMAND["configrunner"]
                else:
                    print "configrunner: INVALID REQUEST! ->", QUEUE_COMMAND["configrunner"]
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "checkxsd" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("CHECKXSD"):
                    self.LOGGING_DICT["CHECKXSD"]=[]
                if len(QUEUE_COMMAND["checkxsd"]) == 3:
                    if QUEUE_COMMAND["checkxsd"][0] == "INFO" or QUEUE_COMMAND["checkxsd"][0] == "WARN":
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; CHECKXSD; " + str(QUEUE_COMMAND["checkxsd"][0]) + "; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; " + str(QUEUE_COMMAND["checkxsd"][0]) + "; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": " + str(QUEUE_COMMAND["checkxsd"][0]) + ": " + unicode(QUEUE_COMMAND["checkxsd"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["checkxsd"][0] == "LOGFILE":
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; CHECKXSD; INFO; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": INFO: " + unicode(QUEUE_COMMAND["checkxsd"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkxsd"][0] == "LOGONLY":
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": (LOGONLY): " + str(QUEUE_COMMAND["checkxsd"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkxsd"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; " + str(QUEUE_COMMAND["checkxsd"][0]) + "; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": " + str(QUEUE_COMMAND["checkxsd"][0]) + ": " + unicode(QUEUE_COMMAND["checkxsd"][2])
                            self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["checkxsd"][0] == "ERROR":
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; " + str(QUEUE_COMMAND["checkxsd"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": " + str(QUEUE_COMMAND["checkxsd"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; " + str(QUEUE_COMMAND["checkxsd"][0]) + "; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; CHECKXSD; " + str(QUEUE_COMMAND["checkxsd"][0]) + "; " + unicode(QUEUE_COMMAND["checkxsd"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": " + str(QUEUE_COMMAND["checkxsd"][0]) + ": " + unicode(QUEUE_COMMAND["checkxsd"][2])
                        self.LOGGING_DICT["CHECKXSD"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + "; " + str(QUEUE_COMMAND["checkxsd"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxsd"][1])) + ": " + str(QUEUE_COMMAND["checkxsd"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["checkxsd"][0] == "CSV_RESULT":
                        if not "CHECKXSD" in self.CSV_DICT.keys():
                            self.CSV_DICT["CHECKXSD"]={}
                        if isinstance(QUEUE_COMMAND["checkxsd"][2], dict):
                            for CSVKEYS in QUEUE_COMMAND["checkxsd"][2]:
                                if not CSVKEYS in self.CSV_DICT["CHECKXSD"].keys():
                                    self.CSV_DICT["CHECKXSD"][CSVKEYS] = {}
                                if isinstance(QUEUE_COMMAND["checkxsd"][2][CSVKEYS], dict):
                                    for SPECIAL in QUEUE_COMMAND["checkxsd"][2][CSVKEYS].keys():
                                        if isinstance(QUEUE_COMMAND["checkxsd"][2][CSVKEYS][SPECIAL], list):
                                            if not SPECIAL in self.CSV_DICT["CHECKXSD"][CSVKEYS].keys():
                                                self.CSV_DICT["CHECKXSD"][CSVKEYS][SPECIAL] = []
                                            while len(QUEUE_COMMAND["checkxsd"][2][CSVKEYS][SPECIAL])>0:
                                                self.CSV_DICT["CHECKXSD"][CSVKEYS][SPECIAL].append(QUEUE_COMMAND["checkxsd"][2][CSVKEYS][SPECIAL].pop(0))
                                        self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME=CSVKEYS, LOGSPECIALTYPE=SPECIAL, INTERVALL=1000, FORCED=True, MODE="CSV")

                    elif QUEUE_COMMAND["checkxsd"][0] == "initlog":
                        pass
                        #print "Creating logging for: ", QUEUE_COMMAND["checkxsd"][1] + "_" + QUEUE_COMMAND["checkxsd"][2]
                    elif QUEUE_COMMAND["checkxsd"][0] == "endlog":
                        pass
                        #print "Finishing logging for: ", QUEUE_COMMAND["checkxsd"][1] + "_" + QUEUE_COMMAND["checkxsd"][2]
                        #self.writeLogging(LOGOBJNAME="CHECKXSD", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=True)
                    else:
                        print "checkxsd:", QUEUE_COMMAND["checkxsd"]
                else:
                    print "checkxsd: INVALID REQUEST! ->", QUEUE_COMMAND["checkxsd"]

                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "checkxpath" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("CHECKXPATH"):
                    self.LOGGING_DICT["CHECKXPATH"]=[]
                if len(QUEUE_COMMAND["checkxpath"]) == 3:
                    if QUEUE_COMMAND["checkxpath"][0] == "INFO" or QUEUE_COMMAND["checkxpath"][0] == "WARN":
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; " + str(QUEUE_COMMAND["checkxpath"][0]) + "; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; CHECKXPATH; " + str(QUEUE_COMMAND["checkxpath"][0]) + "; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": " + str(QUEUE_COMMAND["checkxpath"][0]) + ": " + unicode(QUEUE_COMMAND["checkxpath"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["checkxpath"][0] == "LOGFILE":
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; CHECKXPATH; INFO; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": INFO: " + str(QUEUE_COMMAND["checkxpath"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkxpath"][0] == "LOGONLY":
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": (LOGONLY): " + str(QUEUE_COMMAND["checkxpath"][2])
                        self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkxpath"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; " + str(QUEUE_COMMAND["checkxpath"][0]) + "; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": " + str(QUEUE_COMMAND["checkxpath"][0]) + ": " + unicode(QUEUE_COMMAND["checkxpath"][2])
                            self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["checkxpath"][0] == "ERROR":
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; " + str(QUEUE_COMMAND["checkxpath"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": " + str(QUEUE_COMMAND["checkxpath"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; " + str(QUEUE_COMMAND["checkxpath"][0]) + "; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; CHECKXPATH; " + str(QUEUE_COMMAND["checkxpath"][0]) + "; " + unicode(QUEUE_COMMAND["checkxpath"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": " + str(QUEUE_COMMAND["checkxpath"][0]) + ": " + unicode(QUEUE_COMMAND["checkxpath"][2])
                        self.LOGGING_DICT["CHECKXPATH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + "; " + str(QUEUE_COMMAND["checkxpath"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkxpath"][1])) + ": " + str(QUEUE_COMMAND["checkxpath"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["checkxpath"][0] == "CSV_RESULT":
                        if not "CHECKXPATH" in self.CSV_DICT.keys():
                            self.CSV_DICT["CHECKXPATH"]={}
                        if isinstance(QUEUE_COMMAND["checkxpath"][2], dict):
                            for CSVKEYS in QUEUE_COMMAND["checkxpath"][2]:
                                if not CSVKEYS in self.CSV_DICT["CHECKXPATH"].keys():
                                    self.CSV_DICT["CHECKXPATH"][CSVKEYS] = {}
                                if isinstance(QUEUE_COMMAND["checkxpath"][2][CSVKEYS], dict):
                                    for SPECIAL in QUEUE_COMMAND["checkxpath"][2][CSVKEYS].keys():
                                        if isinstance(QUEUE_COMMAND["checkxpath"][2][CSVKEYS][SPECIAL], list):
                                            if not SPECIAL in self.CSV_DICT["CHECKXPATH"][CSVKEYS].keys():
                                                self.CSV_DICT["CHECKXPATH"][CSVKEYS][SPECIAL] = []
                                            while len(QUEUE_COMMAND["checkxpath"][2][CSVKEYS][SPECIAL])>0:
                                                self.CSV_DICT["CHECKXPATH"][CSVKEYS][SPECIAL].append(QUEUE_COMMAND["checkxpath"][2][CSVKEYS][SPECIAL].pop(0))
                                        self.writeLogging(LOGOBJNAME="CHECKXPATH", LOGSUBOBJNAME=CSVKEYS, LOGSPECIALTYPE=SPECIAL, INTERVALL=1000, FORCED=True, MODE="CSV")

                    else:
                        pass
                        #print "checkxpath:", QUEUE_COMMAND["checkxpath"]
                else:
                    print "checkxpath: INVALID REQUEST! ->", QUEUE_COMMAND["checkxpath"]

                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "checkint" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("INTEGRITY"):
                    self.LOGGING_DICT["INTEGRITY"] = []
                if len(QUEUE_COMMAND["checkint"]) == 3:
                    if QUEUE_COMMAND["checkint"][0] == "INFO" or QUEUE_COMMAND["checkint"][0] == "WARN":
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; " + str(QUEUE_COMMAND["checkint"][0]) + "; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; CHECKINT; " + str(QUEUE_COMMAND["checkint"][0]) + "; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": " + str(QUEUE_COMMAND["checkint"][0]) + ": " + unicode(QUEUE_COMMAND["checkint"][2])
                        self.writeLogging(LOGOBJNAME="INTEGRITY", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["checkint"][0] == "LOGFILE":
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; CHECKINT; INFO; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": INFO: " + unicode(QUEUE_COMMAND["checkint"][2])
                        self.writeLogging(LOGOBJNAME="INTEGRITY", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkint"][0] == "LOGONLY":
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": (LOGONLY): " + str(QUEUE_COMMAND["checkint"][2])
                        self.writeLogging(LOGOBJNAME="INTEGRITY", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["checkint"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; " + str(QUEUE_COMMAND["checkint"][0]) + "; " + unicode(QUEUE_COMMAND["checkint"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": " + str(QUEUE_COMMAND["checkint"][0]) + ": " + unicode(QUEUE_COMMAND["checkint"][2])
                            self.writeLogging(LOGOBJNAME="INTEGRITY", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["checkint"][0] == "ERROR":
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; " + str(QUEUE_COMMAND["checkint"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": " + str(QUEUE_COMMAND["checkint"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; " + str(QUEUE_COMMAND["checkint"][0]) + "; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; CHECKINT; " + str(QUEUE_COMMAND["checkint"][0]) + "; " + unicode(QUEUE_COMMAND["checkint"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": " + str(QUEUE_COMMAND["checkint"][0]) + ": " + unicode(QUEUE_COMMAND["checkint"][2])
                        self.LOGGING_DICT["INTEGRITY"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + "; " + str(QUEUE_COMMAND["checkint"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["checkint"][1])) + ": " + str(QUEUE_COMMAND["checkint"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="INTEGRITY", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    else:
                        print "checkint:", QUEUE_COMMAND["checkint"]
                else:
                    print "checkint: INVALID REQUEST! ->", QUEUE_COMMAND["checkint"]

                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "extraction" in QUEUE_COMMAND.keys():
                if not self.LOGGING_DICT.has_key("EXTRACTION"):
                    self.LOGGING_DICT["EXTRACTION"] = []
                if len(QUEUE_COMMAND["extraction"]) == 3:
                    if QUEUE_COMMAND["extraction"][0] == "INFO" or QUEUE_COMMAND["extraction"][0] == "WARN":
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; " + str(QUEUE_COMMAND["extraction"][0]) + "; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; EXTRACTION; " + str(QUEUE_COMMAND["extraction"][0]) + "; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": " + str(QUEUE_COMMAND["extraction"][0]) + ": " + unicode(QUEUE_COMMAND["extraction"][2])
                        self.writeLogging(LOGOBJNAME="EXTRACTION", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["extraction"][0] == "LOGFILE":
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; EXTRACTION; INFO; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": INFO: " + str(QUEUE_COMMAND["extraction"][2])
                        self.writeLogging(LOGOBJNAME="EXTRACTION", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["extraction"][0] == "LOGONLY":
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": (LOGONLY): " + str(QUEUE_COMMAND["extraction"][2])
                        self.writeLogging(LOGOBJNAME="EXTRACTION", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["extraction"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; " + str(QUEUE_COMMAND["extraction"][0]) + "; " + unicode(QUEUE_COMMAND["extraction"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": " + str(QUEUE_COMMAND["extraction"][0]) + ": " + unicode(QUEUE_COMMAND["extraction"][2])
                            self.writeLogging(LOGOBJNAME="EXTRACTION", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["extraction"][0] == "ERROR":
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; " + str(QUEUE_COMMAND["extraction"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": " + str(QUEUE_COMMAND["extraction"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; " + str(QUEUE_COMMAND["extraction"][0]) + "; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; EXTRACTION; " + str(QUEUE_COMMAND["extraction"][0]) + "; " + unicode(QUEUE_COMMAND["extraction"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": " + str(QUEUE_COMMAND["extraction"][0]) + ": " + unicode(QUEUE_COMMAND["extraction"][2])
                        self.LOGGING_DICT["EXTRACTION"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + "; " + str(QUEUE_COMMAND["extraction"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["extraction"][1])) + ": " + str(QUEUE_COMMAND["extraction"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="EXTRACTION", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    else:
                        print "extraction:", QUEUE_COMMAND["extraction"]
                else:
                    print "extraction: INVALID REQUEST! ->", QUEUE_COMMAND["extraction"]
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict) and "search" in QUEUE_COMMAND.keys():
                if not "SEARCH" in self.LOGGING_DICT.keys():
                    self.LOGGING_DICT["SEARCH"] = []
                if len(QUEUE_COMMAND["search"]) == 3:
                    if QUEUE_COMMAND["search"][0] == "INFO" or QUEUE_COMMAND["search"][0] == "WARN":
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; " + str(QUEUE_COMMAND["search"][0]) + "; " + unicode(QUEUE_COMMAND["search"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; SEARCH; " + str(QUEUE_COMMAND["search"][0]) + "; " + unicode(QUEUE_COMMAND["search"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][0]) + ": " + unicode(QUEUE_COMMAND["search"][2])
                        self.writeLogging(LOGOBJNAME="SEARCH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    elif QUEUE_COMMAND["search"][0] == "LOGFILE":
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["search"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; SEARCH; INFO; " + unicode(QUEUE_COMMAND["search"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": INFO: " + unicode(QUEUE_COMMAND["search"][2])
                        self.writeLogging(LOGOBJNAME="SEARCH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["search"][0] == "LOGONLY":
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; INFO; " + unicode(QUEUE_COMMAND["search"][2]))
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][2])
                        self.writeLogging(LOGOBJNAME="SEARCH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                    elif QUEUE_COMMAND["search"][0] == "DEBUG":
                        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                            self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; " + str(QUEUE_COMMAND["search"][0]) + "; " + unicode(QUEUE_COMMAND["search"][2]))
                            print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][0]) + ": " + unicode(QUEUE_COMMAND["search"][2])
                            self.writeLogging(LOGOBJNAME="SEARCH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        else:
                            pass
                    elif QUEUE_COMMAND["search"][0] == "ERROR":
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; " + str(QUEUE_COMMAND["search"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; " + str(QUEUE_COMMAND["search"][0]) + "; " + unicode(QUEUE_COMMAND["search"][2]))
                        self.LOGGING_DICT["MAIN"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; SEARCH; " + str(QUEUE_COMMAND["search"][0]) + "; " + unicode(QUEUE_COMMAND["search"][2]))
                        print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][0]) + ": " + unicode(QUEUE_COMMAND["search"][2])
                        self.LOGGING_DICT["SEARCH"].append(str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + "; " + str(QUEUE_COMMAND["search"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        #print str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], QUEUE_COMMAND["search"][1])) + ": " + str(QUEUE_COMMAND["search"][0]) + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        self.writeLogging(LOGOBJNAME="SEARCH", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=False)
                        self.writeLogging(LOGOBJNAME="MAIN")
                    else:
                        print "search:", QUEUE_COMMAND["search"]
                else:
                    print "search: INVALID REQUEST! ->", QUEUE_COMMAND["search"]

                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "quit":
                self.writeLogging(LOGOBJNAME="ALL", LOGSUBOBJNAME="", LOGSPECIALTYPE="", FORCED=True)
                #if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG" or True:
                #    print "LoggingThread quitting as requested:", QUEUE_COMMAND
                #    print
                #    print "(temporary) LOGFILES:"
                #    print "====================="
                #    for LOGKEYS in self.LOGGING_DICT.keys():
                #        for ENTRIES in self.LOGGING_DICT[LOGKEYS]:
                #            print str(LOGKEYS) + ": " + str(ENTRIES)
                #        print

                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break
            elif CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                print "Logger:", QUEUE_COMMAND
                self.JOBQUEUE.task_done()


class FileCheckerThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, JOBQUEUE, XSDCHECK, XPATHCHECK, INTEGRITY, SEARCH):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.JOBQUEUE = JOBQUEUE
        self.XSDCHECK = XSDCHECK
        self.XPATHCHECK = XPATHCHECK
        self.INTEGRITY = INTEGRITY
        self.SEARCH = SEARCH
        self.POWERSWITCH = POWERSWITCH
        self.INIT = False
        self.EXTRACTED_FILES_DICT = {}
        self.EXTRACTED_FILES_LIST = []
        self.DIRECTORY_FILES_DICT = {}
        self.DIRECTORY_FILES_LIST = []

    def run(self):
        global CONFIG_DICT
        # In einer Schleife wird darauf **gewartet** bis ein neuer Job
        # an die Jobqueue übergeben wird.
        while True:
            QUEUE_COMMAND = self.JOBQUEUE.get()
            if QUEUE_COMMAND == "init":
                if not self.INIT:
                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "Filechecker initializing"]})
                    DIRLIST = []
                    try:
                        if os.path.exists(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]):
                            DIRLIST = os.listdir(str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]))
                    except:
                        self.LOGFILE.put({"filecheck": ["ERROR", time.localtime(), "Error! Got no files in " + str(
                            CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + " for checking..."]})
                        #GLOBAL_LOGFILE.writeLog("OUT", "Error! Got no files in " + str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + " for checking...")
                        break

                    DIRLIST.sort()

                    REFINED_DIRLIST = {}
                    for DATEIEN in DIRLIST:
                        if (DATEIEN.find("." + str(CONFIG_DICT["ENVIRONMENT"]["XML_ENDING"])) != -1 or DATEIEN.find("." + str(CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"])) != -1) and str(DATEIEN).count(".") == 1 and str(DATEIEN).count("_") >= 4:
                            #print DATEIEN
                            INTERMEDIATE_DATEITYP, _ = string.split(DATEIEN, "_", 1)
                            _, MIXED_DATEITYP = string.split(INTERMEDIATE_DATEITYP, "-", 1)
                            if MIXED_DATEITYP in TRANSLATION_DICT.keys():
                                if not self.DIRECTORY_FILES_DICT.has_key(string.upper(MIXED_DATEITYP)):
                                    self.DIRECTORY_FILES_DICT[string.upper(MIXED_DATEITYP)] = {}
                                for SUBKEYS in TRANSLATION_DICT[MIXED_DATEITYP].keys():
                                    if DATEIEN.find(SUBKEYS) != -1 or SUBKEYS == "NONE":
                                        if not self.DIRECTORY_FILES_DICT[string.upper(MIXED_DATEITYP)].has_key(SUBKEYS):
                                            self.DIRECTORY_FILES_DICT[string.upper(MIXED_DATEITYP)][SUBKEYS] = []
                                        if DATEIEN not in self.DIRECTORY_FILES_DICT[string.upper(MIXED_DATEITYP)][SUBKEYS]:
                                            self.DIRECTORY_FILES_DICT[string.upper(MIXED_DATEITYP)][SUBKEYS].append(DATEIEN)
                                        if DATEIEN not in self.DIRECTORY_FILES_LIST:
                                            self.DIRECTORY_FILES_LIST.append(DATEIEN)
                            else:
                                self.LOGFILE.put({"filecheck": ["ERROR", time.localtime(), "Error while reading " + str(DATEIEN) + ". For me not a valid object type!"]})
                        #elif DATEIEN.find("." + str(CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"])) != -1:
                        #    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "FileChecker found CSV: " + str(DATEIEN)]})
                        else:
                            pass
                self.INIT = True
                self.JOBQUEUE.task_done()

            elif isinstance(QUEUE_COMMAND, dict):
                if "exportstarted" in QUEUE_COMMAND.keys():
                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "New export started: " + str(QUEUE_COMMAND["exportstarted"])]})
                    for QUEUE_KEYS in QUEUE_COMMAND["exportstarted"].keys():
                        if QUEUE_KEYS in CONFIG_DICT["CHECKLIST"].keys() and QUEUE_COMMAND["exportstarted"][QUEUE_KEYS] in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS].keys():
                            if "XSD" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_COMMAND["exportstarted"][QUEUE_KEYS]]:
                                self.XSDCHECK.put({"initverification": {QUEUE_KEYS: QUEUE_COMMAND["exportstarted"][QUEUE_KEYS]}})
                            if "XPATH" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_COMMAND["exportstarted"][QUEUE_KEYS]]:
                                self.XPATHCHECK.put({"initverification": {QUEUE_KEYS: QUEUE_COMMAND["exportstarted"][QUEUE_KEYS]}})

                elif "exported" in QUEUE_COMMAND.keys():
                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "New request of type 'exported' to process: " + str(QUEUE_COMMAND["exported"])]})
                    for COMM_KEYS in QUEUE_COMMAND["exported"]:
                        for COMM_SUBKEYS in QUEUE_COMMAND["exported"][COMM_KEYS]:
                            if len(QUEUE_COMMAND["exported"][COMM_KEYS][COMM_SUBKEYS]) > 0 and (str((QUEUE_COMMAND["exported"][COMM_KEYS][COMM_SUBKEYS])).find(CONFIG_DICT["ENVIRONMENT"]['XML_ENDING']) != -1 or str((QUEUE_COMMAND["exported"][COMM_KEYS][COMM_SUBKEYS])).find(CONFIG_DICT["ENVIRONMENT"]['CSV_ENDING'])) != -1:
                                FILENAME = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + str(QUEUE_COMMAND["exported"][COMM_KEYS][COMM_SUBKEYS])
                                if os.path.isfile(FILENAME):
                                    if not FILENAME in self.EXTRACTED_FILES_LIST:
                                        self.EXTRACTED_FILES_LIST.append(FILENAME)
                                        if not self.EXTRACTED_FILES_DICT.has_key(COMM_KEYS):
                                            self.EXTRACTED_FILES_DICT[COMM_KEYS] = {}
                                        if not self.EXTRACTED_FILES_DICT[COMM_KEYS].has_key(COMM_SUBKEYS):
                                            self.EXTRACTED_FILES_DICT[COMM_KEYS][COMM_SUBKEYS] = []
                                        self.EXTRACTED_FILES_DICT[COMM_KEYS][COMM_SUBKEYS].append(FILENAME)
                                        if COMM_KEYS in CONFIG_DICT["CHECKLIST"].keys() and COMM_SUBKEYS in CONFIG_DICT["CHECKLIST"][COMM_KEYS].keys():
                                            if "XSD" in CONFIG_DICT["CHECKLIST"][COMM_KEYS][COMM_SUBKEYS]:
                                                self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"File to be XSD-checked: " + str(FILENAME)]})
                                                self.XSDCHECK.put({"verify": {COMM_KEYS: {COMM_SUBKEYS: [FILENAME]}}})
                                            if "XPATH" in CONFIG_DICT["CHECKLIST"][COMM_KEYS][COMM_SUBKEYS]:
                                                self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"File to be XPath-checked: " + str(FILENAME)]})
                                                self.XPATHCHECK.put({"verify": {COMM_KEYS: {COMM_SUBKEYS: [FILENAME]}}})
                                    else:
                                        self.LOGFILE.put({"filecheck": ["WARN", time.localtime(), "File did show up already: " + str(FILENAME) + ". Will be ignored."]})
                                        pass
                                else:
                                    self.LOGFILE.put({"filecheck": ["ERROR", time.localtime(), "File can not be found in filesystem: " + str(FILENAME) + ". Will be ignored!"]})
                                    pass
                elif "exportfinished" in QUEUE_COMMAND.keys():
                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "Export finished: " + str(QUEUE_COMMAND["exportfinished"])]})
                    for QUEUE_KEYS in QUEUE_COMMAND["exportfinished"].keys():
                        if QUEUE_KEYS in CONFIG_DICT["CHECKLIST"].keys() and QUEUE_COMMAND["exportfinished"][QUEUE_KEYS] in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS].keys():
                            if "XSD" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]]:
                                self.XSDCHECK.put({"endverification": {QUEUE_KEYS: QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]}})
                            if "XPATH" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]]:
                                self.XPATHCHECK.put({"endverification": {QUEUE_KEYS: QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]}})
                            # self.FILECHECKER.put({"exportfinished": {string.upper(OBJTYPE): SUBOBJTYPE}})
                        self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "Zipping-Check: " + str(CONFIG_DICT["ENVIRONMENT"]["ZIPPING"]) + " (" + str(type(CONFIG_DICT["ENVIRONMENT"]["ZIPPING"])) + ")"]})
                        if CONFIG_DICT["ENVIRONMENT"]["ZIPPING"] is True and "PATH_TO_ZIPS" in CONFIG_DICT["ENVIRONMENT"].keys():
                            if QUEUE_KEYS in self.EXTRACTED_FILES_DICT.keys() and len(QUEUE_COMMAND["exportfinished"][QUEUE_KEYS])>0 and QUEUE_COMMAND["exportfinished"][QUEUE_KEYS] in self.EXTRACTED_FILES_DICT[QUEUE_KEYS].keys():
                                ZIPFILENAME = None
                                for FILENAME in sorted(self.EXTRACTED_FILES_DICT[QUEUE_KEYS][QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]]):
                                    FILENAME = str(FILENAME)
                                    if ZIPFILENAME == None:
                                        if FILENAME.find("-") != -1:
                                            ZIPFILENAME,_ = FILENAME.rsplit("-", 1)
                                            if ZIPFILENAME.find("/") != -1:
                                                _, ZIPFILENAME = ZIPFILENAME.rsplit("/", 1)
                                            elif ZIPFILENAME.find("\\") != -1:
                                                _, ZIPFILENAME = ZIPFILENAME.rsplit("\\", 1)
                                            else:
                                                pass
                                            if len(ZIPFILENAME) < 4:
                                                if FILENAME.find("_") != -1:
                                                    ZIPFILENAME,_ = FILENAME.rsplit("_", 1)
                                                    if ZIPFILENAME.find("/") != -1:
                                                        _, ZIPFILENAME = ZIPFILENAME.rsplit("/", 1)
                                                    elif ZIPFILENAME.find("\\") != -1:
                                                        _, ZIPFILENAME = ZIPFILENAME.rsplit("\\", 1)
                                                    else:
                                                        pass

                                        else:
                                            self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "File has no valid number separator (-): " + str(FILENAME)]})
                                    if FILENAME.find(ZIPFILENAME) != -1:
                                        pass
                                    else:
                                        self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "XML-File does not match filename schema: " + str(FILENAME) + " -> " + str(ZIPFILENAME)]})

                                if ZIPFILENAME != None:
                                    FULLZIPFILENAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_ZIPS"] + ZIPFILENAME + "." + CONFIG_DICT["ENVIRONMENT"]["ZIP_ENDING"]
                                    try:
                                        with zipfile.ZipFile(FULLZIPFILENAME, "w", zipfile.ZIP_DEFLATED, True) as ZIP_OBJ:
                                            self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "Checking if files can be ZIPPED: " + str(self.EXTRACTED_FILES_DICT[QUEUE_KEYS][QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]])]})
                                            for FILENAME in sorted(self.EXTRACTED_FILES_DICT[QUEUE_KEYS][QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]]):
                                                self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "Checking if file can be ZIPPED: " + str(FILENAME)]})
                                                FILENAME = str(FILENAME)
                                                DONOTPROCESS = False
                                                ORIG_FILENAME = FILENAME
                                                if not os.path.isfile(FILENAME):
                                                    FILENAME = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + FILENAME
                                                    if not os.path.isfile(FILENAME):
                                                        self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "XML-File does not exist in filesystem: " + str(ORIG_FILENAME)]})
                                                        DONOTPROCESS = True
                                                if DONOTPROCESS == False:
                                                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "File to be ZIPPED: " + str(ORIG_FILENAME)]})
                                                    if FILENAME.find("/") != -1:
                                                        _, ZIPNAME = FILENAME.rsplit("/", 1)
                                                    elif FILENAME.find("\\") != -1:
                                                        _, ZIPNAME = FILENAME.rsplit("\\", 1)
                                                    else:
                                                        ZIPNAME = FILENAME
                                                    ZIP_OBJ.write(FILENAME, ZIPNAME)
                                                else:
                                                    self.LOGFILE.put({"filecheck": ["ERROR", time.localtime(), "Could not ZIP: " + str(ORIG_FILENAME)]})
                                    except:
                                        self.LOGFILE.put({"filecheck": ["ERROR", time.localtime(), "Could not ZIP: " + str(QUEUE_COMMAND["exportfinished"])]})

                            else:
                                self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(), "ZIPPING not possible. OBJECT/SUBOBJECT not found: " + QUEUE_KEYS + "_" + str(QUEUE_COMMAND["exportfinished"][QUEUE_KEYS])]})

                        if CONFIG_DICT["ENVIRONMENT"]["EMAIL"] != False:
                            SMTP_MESSAGE = str(EMAIL_DICT["EXTRACT_SUCCESSFULL"])
                            if SMTP_MESSAGE.find("#*SMTP_SENDER*#") != -1:
                                SMTP_MESSAGE = SMTP_MESSAGE.replace("#*SMTP_SENDER*#", CONFIG_DICT["ENVIRONMENT"]["SMTP_SENDER"])
                            if SMTP_MESSAGE.find("#*OBJECT_NAME*#") != -1:
                                if "NONE" in QUEUE_COMMAND["exportfinished"][QUEUE_KEYS]:
                                    OBJECT_NAME = QUEUE_KEYS
                                else:
                                    OBJECT_NAME = QUEUE_KEYS + "(" + QUEUE_COMMAND["exportfinished"][QUEUE_KEYS] + ")"
                                SMTP_MESSAGE = SMTP_MESSAGE.replace("#*OBJECT_NAME*#", OBJECT_NAME)
                            if SMTP_MESSAGE.find("#*ZIPPING*#") != -1:
                                SMTP_MESSAGE = SMTP_MESSAGE.replace("#*ZIPPING*#", str(CONFIG_DICT["ENVIRONMENT"]["ZIPPING"]))
                            try:
                                smtpObj = smtplib.SMTP(CONFIG_DICT["ENVIRONMENT"]["SMTP_SERVER"], CONFIG_DICT["ENVIRONMENT"]["SMTP_PORT"])
                                smtpObj.sendmail(CONFIG_DICT["ENVIRONMENT"]["SMTP_SENDER"], CONFIG_DICT["ENVIRONMENT"]["EMAIL"], SMTP_MESSAGE)
                                LOGFILE.put({"main": ["DEBUG", time.localtime(), "Email sent successfully."]})
                            except smtplib.SMTPException:
                                LOGFILE.put({"main": ["ERROR", time.localtime(), "Email sent NOT successfully."]})


                    # Hier erzeugen wir später die Logs, Zippen das Ganze und liefern per Email aus.
                elif "send_verify" in QUEUE_COMMAND.keys():
                    self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"New request of type 'send_verify' to process: " + str(QUEUE_COMMAND["send_verify"])]})
                    for QUEUE_KEYS in QUEUE_COMMAND["send_verify"].keys():
                        for QUEUE_SUBKEYS in QUEUE_COMMAND["send_verify"][QUEUE_KEYS]:
                            if QUEUE_KEYS in CONFIG_DICT["CHECKLIST"].keys() and QUEUE_SUBKEYS in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS].keys() and self.DIRECTORY_FILES_DICT.has_key(QUEUE_KEYS) and QUEUE_SUBKEYS in self.DIRECTORY_FILES_DICT[QUEUE_KEYS].keys():
                                if "XSD" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_SUBKEYS]:
                                    self.XSDCHECK.put({"initverification": {QUEUE_KEYS: QUEUE_SUBKEYS}})
                                if "XPATH" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_SUBKEYS]:
                                    self.XPATHCHECK.put({"initverification": {QUEUE_KEYS: QUEUE_SUBKEYS}})
                                if "INTEGRITY" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_SUBKEYS]:
                                    self.XPATHCHECK.put({"initverification": {QUEUE_KEYS: QUEUE_SUBKEYS}})
                            else:
                                self.LOGFILE.put({"filecheck": ["INFO", time.localtime(), "Requested verification of " + str(QUEUE_KEYS) + "_" + str(QUEUE_SUBKEYS) + ", but no files found. skipping."]})

                    for KEYS in QUEUE_COMMAND["send_verify"]:
                        if self.DIRECTORY_FILES_DICT.has_key(KEYS):
                            for ENTRIES in QUEUE_COMMAND["send_verify"][KEYS]:
                                if self.DIRECTORY_FILES_DICT[KEYS].has_key(ENTRIES):
                                    for FILENAME in self.DIRECTORY_FILES_DICT[KEYS][ENTRIES]:
                                        if "XSD" in CONFIG_DICT["CHECKLIST"][KEYS][ENTRIES]:
                                            self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"File to be XSD-checked: " + str(FILENAME)]})
                                            self.XSDCHECK.put({"verify": {KEYS: {ENTRIES: [FILENAME]}}})
                                        if "XPATH" in CONFIG_DICT["CHECKLIST"][KEYS][ENTRIES]:
                                            self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"File to be XPath-checked: " + str(FILENAME)]})
                                            self.XPATHCHECK.put({"verify": {KEYS: {ENTRIES: [FILENAME]}}})
                    for QUEUE_KEYS in QUEUE_COMMAND["send_verify"].keys():
                        for QUEUE_SUBKEYS in  QUEUE_COMMAND["send_verify"][QUEUE_KEYS]:
                            if QUEUE_KEYS in CONFIG_DICT["CHECKLIST"].keys() and QUEUE_SUBKEYS in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS].keys() and self.DIRECTORY_FILES_DICT.has_key(QUEUE_KEYS) and QUEUE_SUBKEYS in self.DIRECTORY_FILES_DICT[QUEUE_KEYS].keys():
                                if "XSD" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_SUBKEYS]:
                                    self.XSDCHECK.put({"endverification": {QUEUE_KEYS: QUEUE_SUBKEYS}})
                                if "XPATH" in CONFIG_DICT["CHECKLIST"][QUEUE_KEYS][QUEUE_SUBKEYS]:
                                    self.XPATHCHECK.put({"endverification": {QUEUE_KEYS: QUEUE_SUBKEYS}})

                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "sync":
                pass
                self.JOBQUEUE.task_done()

            elif QUEUE_COMMAND == "quit":
                self.LOGFILE.put({"filecheck": ["DEBUG", time.localtime(),"FileCheckerThread quitting as requested."]})
                self.JOBQUEUE.task_done()
                self.POWERSWITCH.set()
                break
            else:
                self.LOGFILE.put(
                    {"filecheck": ["DEBUG", time.localtime(), "filecheck issued for: " + str(QUEUE_COMMAND)]})
                self.JOBQUEUE.task_done()


class ConfigRunnerThread(threading.Thread):
    def __init__(self, POWERSWITCH, LOGFILE, EXTRACTION, XSDCHECK, XPATHCHECK, INTEGRITY, SEARCH, FILECHECKER):
        threading.Thread.__init__(self)
        self.LOGFILE = LOGFILE
        self.EXTRACTION = EXTRACTION
        self.XSDCHECK = XSDCHECK
        self.XPATHCHECK = XPATHCHECK
        self.INTEGRITY = INTEGRITY
        self.SEARCH = SEARCH
        self.FILECHECKER = FILECHECKER
        self.POWERSWITCH = POWERSWITCH

    def waiting(self, QUEUE, TIMEFRAME=10):
        STOP = time.time() + TIMEFRAME
        while time.time() <= STOP and QUEUE.unfinished_tasks:
            time.sleep(1)
        return QUEUE.empty()

    def findObjectByExtractNo(self, EXTRACTNO=0):
        global TRANSLATION_DICT
        RESULT = (False, False)
        for DICTOBJ in TRANSLATION_DICT.keys():
            for DICTSUBOBJ in TRANSLATION_DICT[DICTOBJ].keys():
                if str(EXTRACTNO) == str(TRANSLATION_DICT[DICTOBJ][DICTSUBOBJ]["EXTRACT"]):
                    RESULT = (DICTOBJ, DICTSUBOBJ)
        return RESULT

    def analyzeStatistics(self, OBJ="NONE", SUBOBJ="NONE", CHECKEXISTED=False):
        self.LOGFILE.put({"main": ["DEBUG", time.localtime(), "Object: " + unicode(OBJ) + " -> " + unicode(STATISTICS.keys())]})
        if OBJ in STATISTICS.keys():
            #self.LOGFILE.put({"main": ["INFO", time.localtime(), unicode(OBJ) + unicode(":")]})
            if isinstance(STATISTICS[OBJ], dict):
                self.LOGFILE.put({"main": ["DEBUG", time.localtime(), "Subobject: " + unicode(SUBOBJ) + " -> " + unicode(STATISTICS[OBJ].keys())]})
                if SUBOBJ in STATISTICS[OBJ].keys():
                    SUBOBJECTS = STATISTICS[OBJ].pop(SUBOBJ)
                    if isinstance(SUBOBJECTS, dict):
                        for SPECIAL in SUBOBJECTS.keys():
                            if isinstance(SUBOBJECTS[SPECIAL], dict):
                                for STATTYPES in SUBOBJECTS[SPECIAL].keys():
                                    if isinstance(SUBOBJECTS[SPECIAL][STATTYPES], dict):
                                        for KEYS in SUBOBJECTS[SPECIAL][STATTYPES]:
                                            PRINTSTRING = ""
                                            if isinstance(SUBOBJECTS[SPECIAL][STATTYPES][KEYS], time.struct_time):
                                                SUBOBJECTS[SPECIAL][STATTYPES][KEYS] = str(time.strftime(CONFIG_DICT["ENVIRONMENT"]["LOGGING_TIMESTAMP_FORMAT"], SUBOBJECTS[SPECIAL][STATTYPES][KEYS]))
                                            if OBJ != "NONE":
                                                PRINTSTRING += str(OBJ) + " -> "
                                            if SUBOBJ != "NONE":
                                                PRINTSTRING += str(SUBOBJ) + " -> "
                                            if SPECIAL != "NONE":
                                                PRINTSTRING += str(SPECIAL) + " -> "
                                            if STATTYPES != "NONE":
                                                PRINTSTRING += str(STATTYPES) + " -> "
                                            PRINTSTRING += str(KEYS) + " -> " + str(SUBOBJECTS[SPECIAL][STATTYPES][KEYS])
                                            #print PRINTSTRING
                                            self.LOGFILE.put({"main": ["INFO", time.localtime(), "" + PRINTSTRING]})
                                    else:
                                        self.LOGFILE.put({"main": ["INFO", time.localtime(), "" + str(STATISTICS[OBJ]) +  "->" + str(SUBOBJECTS) + "->" + str(STATTYPES) +  "->" + str(SUBOBJECTS[SPECIAL][STATTYPES])]})
                    else:
                        self.LOGFILE.put({"main": ["INFO", time.localtime(), "" + str(STATISTICS[OBJ]) + "->" + str(SUBOBJECTS)]})
            else:
                self.LOGFILE.put({"main": ["INFO", time.localtime(), "" + str(STATISTICS[OBJ]) + "->" + str(STATISTICS[OBJ])]})
                #print STATISTICS[OBJ], "->", OBJECTS

            if len(STATISTICS[OBJ])<1:
                STATISTICS.pop(OBJ)

            if CHECKEXISTED:
                return True
        else:
            if CHECKEXISTED:
                return False



    def run(self):
        global STATISTICS
        if len(CONFIG_DICT["EXTRACTION"]) > 0:
            self.FILECHECKER.put("init")
            # We have matters to extract... lets get ready. (Logfile and Co...)
            self.EXTRACTION.put("init")
            # First we need to get some environment data from the db...
            self.EXTRACTION.put("getenvironment")
            for KEYS in CONFIG_DICT["EXTRACTION"].keys():
                self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(),"Extraction requested for: " + str(KEYS) + " -> " + str(CONFIG_DICT["EXTRACTION"][KEYS])]})
                self.EXTRACTION.put({KEYS: CONFIG_DICT["EXTRACTION"][KEYS]})
            self.EXTRACTION.put("send")
            i = 0
            WAITING = 10
            while i < 5:
                i = i + 1
                if not self.waiting(self.EXTRACTION, WAITING):
                    self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(),"WARNING! Could not SEND all extraction requests within " + str(WAITING * i) + " seconds!"]})
                    pass
                else:
                    self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "Setting up extraction tasks finished. Starting monitoring of extraction files."]})
                    break
            if i >= 5:
                self.LOGFILE.put({"configrunner": ["ERROR", time.localtime() ,"ERROR: Something is BROKEN with the DB. I am not going to wait until this is finished. Lets see if we can do other steps..."]})
            else:
                self.EXTRACTION.put("monitoring")

        if len(CONFIG_DICT["CHECKLIST"]) > 0:
            # Seems as if we have something to verify. Lets go!
            self.FILECHECKER.put("init")
            #self.FILECHECKER.put({"exported":{'PHYSICALPERSON': {'ContactPerson': '01-PhysicalPerson_20141205T073621_51331BE_d0tico30_ContactPerson-00005.xml'}}})
            #self.FILECHECKER.put({"exported":{'PHYSICALPERSON': {'ContactPerson': '01-PhysicalPerson_20141205T073621_51331BE_d0tico30_ContactPerson-00005.xml'}}})
            #self.EXTRACTION.put("init")

            self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "ConfigRunner: Checking for things to be validated..."]})
            for i in range(0, 999):
                OBJ, SUBOBJ = self.findObjectByExtractNo(i)
                if OBJ != False and SUBOBJ != False:
                    OBJ = str(OBJ).upper()
                    SUBOBJ= str(SUBOBJ)
                    if not (CONFIG_DICT["EXTRACTION"].has_key(OBJ) and SUBOBJ in CONFIG_DICT["EXTRACTION"][OBJ]):
                        #self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "ConfigRunner: OBJS: " + str(OBJ) + " -> " + str(SUBOBJ)]})
                        #self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "ConfigRunner: CHECKLIST: " + str(CONFIG_DICT["CHECKLIST"])]})
                        if OBJ in CONFIG_DICT["CHECKLIST"].keys() and SUBOBJ in CONFIG_DICT["CHECKLIST"][OBJ].keys():
                            self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(),"Not planned to be extracted, but to be verified: " + str(OBJ) + " -> " + str(SUBOBJ)]})
                            self.FILECHECKER.put({"send_verify": {OBJ: [SUBOBJ]}})
                        else:
                            pass
                            #self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "ConfigRunner: Can not be found in extraction, but also not in Checklist: " + str(OBJ) + " -> " + str(SUBOBJ)]})
                    else:
                        pass
                        self.LOGFILE.put({"configrunner": ["DEBUG", time.localtime(), "ConfigRunner: Can be found in extraction, ignoring here (done there): " + str(OBJ) + " -> " + str(SUBOBJ)]})
                else:
                    pass

        self.EXTRACTION.put("sync")
        self.EXTRACTION.join()
        time.sleep(1)
        self.FILECHECKER.put("sync")
        self.FILECHECKER.join()
        time.sleep(1)
        self.XSDCHECK.put("sync")
        self.XSDCHECK.join()
        time.sleep(1)
        self.XPATHCHECK.put("sync")
        self.XPATHCHECK.join()
        time.sleep(1)
        self.LOGFILE.put("sync")
        self.LOGFILE.join()
        time.sleep(1)
        self.EXTRACTION.put("sync")
        self.EXTRACTION.join()
        time.sleep(1)
        self.FILECHECKER.put("sync")
        self.FILECHECKER.join()
        time.sleep(1)
        self.XSDCHECK.put("sync")
        self.XSDCHECK.join()
        time.sleep(1)
        self.XPATHCHECK.put("sync")
        self.XPATHCHECK.join()
        time.sleep(1)
        self.LOGFILE.put("sync")
        self.LOGFILE.join()
        time.sleep(1)
        self.EXTRACTION.put("quit")
        self.FILECHECKER.put("quit")
        self.XSDCHECK.put("quit")
        self.XPATHCHECK.put("quit")
        self.INTEGRITY.put("quit")
        self.SEARCH.put("quit")
        time.sleep(1)

        if len(STATISTICS) > 0 and isinstance(STATISTICS, dict):
            self.LOGFILE.put({"main": ["INFO", time.localtime(), ""]})
            self.LOGFILE.put({"main": ["INFO", time.localtime(), "Statistics"]})
            self.LOGFILE.put({"main": ["INFO", time.localtime(), "=========="]})
            DBINFOWASHERE = self.analyzeStatistics(OBJ="DB_INFO", CHECKEXISTED=True)
            if DBINFOWASHERE:
                self.LOGFILE.put({"main": ["INFO", time.localtime(), "=========="]})
            for i in range(0, 999):
                OBJ, SUBOBJ = self.findObjectByExtractNo(i)
                OBJ = str(OBJ).upper()
                if OBJ != False and SUBOBJ != False:
                    self.LOGFILE.put({"main": ["DEBUG", time.localtime(), "Handing back over: " + str(OBJ) + " -> " + str(SUBOBJ)]})
                    self.analyzeStatistics(OBJ=OBJ, SUBOBJ=SUBOBJ)

        self.LOGFILE.put("quit")
        self.LOGFILE.join()

def ConfigSectionMap(CONFIG, SECTION, CHECKBOOL=False):
    global CONFIG_DICT
    global LOGFILE
    TMP_DICT = {}
    CONFIG_OPTIONS = CONFIG.options(SECTION)
    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Import started for section: " + str(SECTION)]})
    for OPTION in CONFIG_OPTIONS:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Processing: " + str(SECTION) + " -> " + str(OPTION)]})
        CAP_OPTION = str(OPTION).upper()
        try:
            TMP_DICT[CAP_OPTION] = CONFIG.get(SECTION, OPTION).encode('ascii', 'ignore')
            if CHECKBOOL:
                if str(TMP_DICT[CAP_OPTION]).upper() == "TRUE":
                       TMP_DICT[CAP_OPTION] = True
                elif str(TMP_DICT[CAP_OPTION]).upper() == "FALSE":
                    TMP_DICT[CAP_OPTION] = False
            #TMP_DICT[CAP_OPTION] = CONFIG.get(SECTION, OPTION)
            if TMP_DICT[CAP_OPTION] == -1:
                LOGFILE.put({"main": ["DEBUG", time.localtime(), "Skipping: " + str(OPTION)]})
        except:
            try:
                TMP_DICT[CAP_OPTION] = CONFIG.getboolean(SECTION, OPTION)
                if TMP_DICT[CAP_OPTION] == -1:
                    LOGFILE.put({"main": ["ERROR", time.localtime(), "Skipping: " + str(OPTION)]})
            except:
                LOGFILE.put({
                    "main": ["ERROR", time.localtime(), "Unhandled exception while reading config on: " + str(CAP_OPTION)]})
                TMP_DICT[CAP_OPTION] = None
    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Import Finished for section: " + str(SECTION)]})
    return TMP_DICT

def ConfigCleanup(SECTION):
    global CONFIG_DICT
    global LOGFILE
    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Cleaning config section: " + str(SECTION)]})
    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Cleaning config section: " + str(CONFIG_DICT[SECTION])]})
    if CONFIG_DICT.has_key(SECTION) and len(CONFIG_DICT[SECTION]) > 0:
        for KEYS in CONFIG_DICT[SECTION].keys():
            if isinstance(CONFIG_DICT[SECTION][KEYS], str):
                if (((string.upper(CONFIG_DICT[SECTION][KEYS]) in ("YES", "TRUE", "ALL")) or KEYS in ("ALL_OBJECTS")) and (string.upper(SECTION) == "EXTRACTION")):
                    for TESTKEYS in TRANSLATION_DICT.keys():
                        if string.upper(TESTKEYS) == KEYS or (string.upper(KEYS) == "ALL_OBJECTS") and (string.upper(CONFIG_DICT[SECTION][KEYS]) in ("YES", "TRUE", "ALL")):
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Extraction: Got a 'ALL'! " + str(SECTION) + " -> " + str(KEYS)]})
                            if len(TRANSLATION_DICT[TESTKEYS]) > 0:
                                for EXT_SUBOBJECTS in TRANSLATION_DICT[TESTKEYS].keys():
                                    if TRANSLATION_DICT[TESTKEYS][EXT_SUBOBJECTS]["STANDARD_EXPORT"]:
                                        if not CONFIG_DICT[SECTION].has_key(string.upper(TESTKEYS)) or not isinstance(CONFIG_DICT[SECTION][string.upper(TESTKEYS)], list):
                                            CONFIG_DICT[SECTION][string.upper(TESTKEYS)] = []
                                        if EXT_SUBOBJECTS not in CONFIG_DICT[SECTION][string.upper(TESTKEYS)]:
                                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Extraction: Adding " + EXT_SUBOBJECTS + " to " + TESTKEYS + "."]})
                                            CONFIG_DICT[SECTION][string.upper(TESTKEYS)].append(EXT_SUBOBJECTS)
                elif (str(CONFIG_DICT[SECTION][KEYS]).upper() in ("ALL", "XSD", "XPATH", "INTEGRITY") or str(KEYS).upper() in ("ALL_OBJECTS")) and string.upper(SECTION) == "CHECKLIST":
                    TMPVAL = CONFIG_DICT[SECTION][KEYS]
                    for TESTKEYS in TRANSLATION_DICT.keys():
                        if (str(TESTKEYS).upper() == KEYS or str(KEYS).upper() == "ALL_OBJECTS") and CONFIG_DICT[SECTION][KEYS] in VERIFY_CONFIG:
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Verification: Got a 'ALL'-Key!"]})
                            if len(TRANSLATION_DICT[TESTKEYS]) > 0:
                                for EXT_SUBOBJECTS in TRANSLATION_DICT[TESTKEYS].keys():
                                    if TRANSLATION_DICT[TESTKEYS][EXT_SUBOBJECTS]["STANDARD_EXPORT"]:
                                        if not CONFIG_DICT[SECTION].has_key(string.upper(TESTKEYS)) or not isinstance(CONFIG_DICT[SECTION][string.upper(TESTKEYS)], dict):
                                            CONFIG_DICT[SECTION][string.upper(TESTKEYS)] = {}
                                        if EXT_SUBOBJECTS not in CONFIG_DICT[SECTION][string.upper(TESTKEYS)].keys():
                                            CONFIG_DICT[SECTION][string.upper(TESTKEYS)][EXT_SUBOBJECTS] = []
                                        if string.upper(TMPVAL) == "ALL":
                                            for ENTRIES in VERIFY_CONFIG:
                                                if ENTRIES == "None":
                                                    pass
                                                else:
                                                    if not ENTRIES in CONFIG_DICT[SECTION][string.upper(TESTKEYS)][EXT_SUBOBJECTS]:
                                                        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Verification: Adding " + ENTRIES + " to " + EXT_SUBOBJECTS + "."]})
                                                        CONFIG_DICT[SECTION][string.upper(TESTKEYS)][EXT_SUBOBJECTS].append(ENTRIES)
                                        for ENTRIES in VERIFY_CONFIG:
                                            if string.upper(ENTRIES).find(string.upper(TMPVAL)) != -1:
                                                if not ENTRIES in CONFIG_DICT[SECTION][string.upper(TESTKEYS)][EXT_SUBOBJECTS]:
                                                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Verification: Adding " + ENTRIES + " to " + EXT_SUBOBJECTS + "."]})
                                                    CONFIG_DICT[SECTION][string.upper(TESTKEYS)][EXT_SUBOBJECTS].append(ENTRIES)
                else:
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing an invalid/'NONE' config entry :" + str(KEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                    CONFIG_DICT[SECTION].pop(KEYS, None)
                if KEYS in CONFIG_DICT[SECTION].keys() and isinstance(CONFIG_DICT[SECTION][KEYS], str):
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing no longer needed entry :" + str(KEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                    CONFIG_DICT[SECTION].pop(KEYS, None)

            if CONFIG_DICT[SECTION].has_key(KEYS) and isinstance(CONFIG_DICT[SECTION][KEYS], list):
                for SUBKEYS in CONFIG_DICT[SECTION][KEYS]:
                    if doesTrDictEntryExist(OBJECT=KEYS, SUBOBJECT=SUBKEYS):
                        if string.upper(SECTION) == "EXTRACTION":
                            pass
                        elif string.upper(SECTION) == "CHECKLIST":
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing an invalid config entry :" + str(KEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                            CONFIG_DICT[SECTION].pop(KEYS, None)
                        else:
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing an invalid config subobject entry :" + str(SUBKEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                            CONFIG_DICT[SECTION][KEYS].pop( CONFIG_DICT[SECTION][KEYS].index(SUBKEYS))

            if CONFIG_DICT[SECTION].has_key(KEYS) and isinstance(CONFIG_DICT[SECTION][KEYS], dict):
                for SUBKEYS in CONFIG_DICT[SECTION][KEYS].keys():
                    if isinstance(CONFIG_DICT[SECTION][KEYS][SUBKEYS], list):
                        if len(CONFIG_DICT[SECTION][KEYS][SUBKEYS]) > 0:
                            for VALUES in CONFIG_DICT[SECTION][KEYS][SUBKEYS]:
                                if VALUES in VERIFY_CONFIG:
                                    pass
                                else:
                                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing an invalid config value entry :" + str(VALUES) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                                    CONFIG_DICT[SECTION][KEYS][SUBKEYS].pop(CONFIG_DICT[SECTION][KEYS][SUBKEYS].index(VALUES))
                        else:
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing empty/broken config value entry :" + str(SUBKEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                            CONFIG_DICT[SECTION].pop(KEYS, None)
                    else:
                        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Removing empty/broken config value entry :" + str(KEYS) + " -> " + str(CONFIG_DICT[SECTION][KEYS])]})
                        CONFIG_DICT[SECTION].pop(KEYS, None)
    else:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Config section " + str(SECTION) + " does not exist/is empty. Skipping."]})

def handleIconValidation():
    global CURDIR
    global CONFIG_DICT
    global STATISTICS
    global LOGFILE
    global ICON_VALIDATION_DICT
    XMLCONFIGREFINED = {}
    ICON_VALIDATION_DICT = {}

    if CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"] != "":
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Setup iConValidation.xml: Path and/or name values in config found: " + str(CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"])]})
        if os.path.isfile(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XPATH_CONFIG"] + CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"]):
            with open(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XPATH_CONFIG"] + CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"]) as XMLCONFIGFILE:
                XMLCONFIGREFINED = xmltodict.parse(XMLCONFIGFILE.read())
        else:
            LOGFILE.put({"main": ["ERROR", time.localtime(), "Setup iConValidation.xml: Path and/or name values in config is invalid: " + str(CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"])]})
    if XMLCONFIGREFINED.has_key("ICON-Validation"):
        if XMLCONFIGREFINED["ICON-Validation"].has_key("operation"):
            for NODES in XMLCONFIGREFINED["ICON-Validation"]["operation"]:
                OBJECT = "NONE"
                SUBOBJECT = "NONE"
                VALIDATIONXPATH = ""
                VALIDATIONSQL = ""
                EXTRACTFILE = ""
                COUNTER_REMOTEKEY = -1
                if NODES.has_key("@name"):
                    OBJECT = str(NODES["@name"])
                    if not ICON_VALIDATION_DICT.has_key(OBJECT):
                        ICON_VALIDATION_DICT[OBJECT] = {}

                    if NODES.has_key("type"):
                        NODESTYPE = NODES["type"]
                        if isinstance(NODESTYPE, dict) and NODESTYPE.has_key("value"):
                            if not ICON_VALIDATION_DICT[OBJECT].has_key(NODESTYPE["value"]):
                                SUBOBJECT = str(NODESTYPE["value"])
                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT] = {}
                        else:
                            pass
                    if not ICON_VALIDATION_DICT[OBJECT].has_key(SUBOBJECT):
                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT] = {}

                    if NODES.has_key("ExtractFileType"):
                        EXTRACTFILE = str(NODES["ExtractFileType"]).upper()
                    else:
                        pass
                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ExtractFileType"] = EXTRACTFILE

                    if NODES.has_key("ValidationXPath"):
                        VALIDATIONXPATH = str(NODES["ValidationXPath"])
                    else:
                        pass
                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationXPath"] = VALIDATIONXPATH

                    if NODES.has_key("ValidationSQL"):
                        VALIDATIONSQL = str(NODES["ValidationSQL"])
                    else:
                        pass
                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationSQL"] = VALIDATIONSQL

                if NODES.has_key("ValidationIntegrity"):
                    if not ICON_VALIDATION_DICT[OBJECT][SUBOBJECT].has_key("ValidationIntegrity"):
                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"] = {}
                    for INTEGRITYKEYS in NODES["ValidationIntegrity"]:
                        if INTEGRITYKEYS == "OwnKey":
                            if not (ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"].has_key("OWNKEY") and isinstance(ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"], list)):
                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"] = []
                            if isinstance(NODES["ValidationIntegrity"][INTEGRITYKEYS], list):
                                for OWNKEYS in NODES["ValidationIntegrity"][INTEGRITYKEYS]:
                                    if OWNKEYS.has_key("@name") and OWNKEYS.has_key("#text"):
                                        if not {"NAME": OWNKEYS["@name"], "XPATH": OWNKEYS["#text"]} in ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"]:
                                            ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"].append({"NAME": OWNKEYS["@name"], "XPATH": OWNKEYS["#text"]})
                                    else:
                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"No valid entries, even when it looked like an 'OwnKey': " + str(NODES["ValidationIntegrity"][INTEGRITYKEYS])]})
                            elif isinstance(NODES["ValidationIntegrity"][INTEGRITYKEYS], dict):
                                OWNKEYS = NODES["ValidationIntegrity"][INTEGRITYKEYS]
                                if OWNKEYS.has_key("@name") and OWNKEYS.has_key("#text"):
                                    if not {"NAME": OWNKEYS["@name"], "XPATH": OWNKEYS["#text"]} in ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"]:
                                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["OWNKEY"].append({"NAME": OWNKEYS["@name"], "XPATH": OWNKEYS["#text"]})
                                else:
                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"No valid entries, even when it looked like an 'OwnKey': " + str(NODES["ValidationIntegrity"][INTEGRITYKEYS])]})
                            else:
                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"No valid OwnKeyType (List/Dict): " + str(type(NODES["ValidationIntegrity"][INTEGRITYKEYS])) + " -> " + str(NODES["ValidationIntegrity"][INTEGRITYKEYS])]})

                        elif INTEGRITYKEYS == "RemoteKey":
                            if not (ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"].has_key("REMOTEKEY") and isinstance(ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"], list)):
                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"] = []
                            COUNTER_REMOTEKEY = -1
                            if isinstance(NODES["ValidationIntegrity"]["RemoteKey"], list):
                                for REMOTEKEYS in NODES["ValidationIntegrity"]["RemoteKey"]:
                                    if REMOTEKEYS.has_key("@name") and REMOTEKEYS.has_key("@xpath") and REMOTEKEYS.has_key("@type") and REMOTEKEYS.has_key("Type"):
                                        COUNTER_REMOTEKEY += 1
                                        COUNTER_REMOTESUBKEY = -1
                                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"].append({"NAME": REMOTEKEYS["@name"], "XPATH": REMOTEKEYS["@xpath"],"TYPE": REMOTEKEYS["@type"], "FK_CHECK": []})
                                        if isinstance(REMOTEKEYS["Type"], list):
                                            for REMOTEKEYTTYPES in REMOTEKEYS["Type"]:
                                                if REMOTEKEYTTYPES.has_key("@name") and REMOTEKEYTTYPES.has_key("FK"):
                                                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"].append({REMOTEKEYTTYPES["@name"]: []})
                                                    COUNTER_REMOTESUBKEY += 1
                                                    if isinstance(REMOTEKEYTTYPES["FK"], list):
                                                        for FKS in REMOTEKEYTTYPES["FK"]:
                                                            if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                            else:
                                                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-List-List-FK not valid: " + str(FKS)]})
                                                    elif isinstance(REMOTEKEYTTYPES["FK"], dict):
                                                        FKS = REMOTEKEYTTYPES["FK"]
                                                        if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                            ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                        else:
                                                            LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-List-Dict-FK not valid: " + str(FKS)]})
                                                    else:
                                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-List-? can not be determined: " + str(isinstance(REMOTEKEYTTYPES["FK"]))]})
                                                else:
                                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-List-RKType is not valid: " + str(REMOTEKEYTTYPES)]})
                                        elif isinstance(REMOTEKEYS["Type"], dict):
                                            REMOTEKEYTTYPES = REMOTEKEYS["Type"]
                                            if REMOTEKEYTTYPES.has_key("@name") and REMOTEKEYTTYPES.has_key("FK"):
                                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"].append({REMOTEKEYTTYPES["@name"]: []})
                                                COUNTER_REMOTESUBKEY += 1
                                                if isinstance(REMOTEKEYTTYPES["FK"], list):
                                                    for FKS in REMOTEKEYTTYPES["FK"]:
                                                        if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                            ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                        else:
                                                            LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-Dict-List-FK not valid: " + str(FKS)]})
                                                elif isinstance(REMOTEKEYTTYPES["FK"], dict):
                                                    FKS = REMOTEKEYTTYPES["FK"]
                                                    if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                    else:
                                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-Dict-Dict-FK not valid: " + str(FKS)]})
                                                else:
                                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-Dict-? can not be determined: " + str(type(REMOTEKEYTTYPES["FK"])) + " -> " + str(REMOTEKEYTTYPES["FK"])]})
                                            else:
                                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-Dict-RKType is not valid: " + str(REMOTEKEYTTYPES)]})
                                        else:
                                            LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-? can not be determined: " + str(type(REMOTEKEYS["Type"])) + " -> " + str(REMOTEKEYS["Type"])]})
                                    else:
                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-RemoteKey is not valid: " + str(REMOTEKEYS)]})
                            elif isinstance(NODES["ValidationIntegrity"]["RemoteKey"], dict):
                                REMOTEKEYS = NODES["ValidationIntegrity"]["RemoteKey"]
                                if REMOTEKEYS.has_key("@name") and REMOTEKEYS.has_key("@xpath") and REMOTEKEYS.has_key("@type") and REMOTEKEYS.has_key("Type"):
                                    COUNTER_REMOTEKEY += 1
                                    COUNTER_REMOTESUBKEY = -1
                                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"].append({"NAME": REMOTEKEYS["@name"], "XPATH": REMOTEKEYS["@xpath"],"TYPE": REMOTEKEYS["@type"], "FK_CHECK": []})
                                    if isinstance(REMOTEKEYS["Type"], list):
                                        for REMOTEKEYTTYPES in REMOTEKEYS["Type"]:
                                            if REMOTEKEYTTYPES.has_key("@name") and REMOTEKEYTTYPES.has_key("FK"):
                                                ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"].append({REMOTEKEYTTYPES["@name"]: []})
                                                COUNTER_REMOTESUBKEY += 1
                                                if isinstance(REMOTEKEYTTYPES["FK"], list):
                                                    for FKS in REMOTEKEYTTYPES["FK"]:
                                                        if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                            ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                        else:
                                                            LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-List-List-FK not valid: " + str(FKS)]})
                                                elif isinstance(REMOTEKEYTTYPES["FK"], dict):
                                                    FKS = REMOTEKEYTTYPES["FK"]
                                                    if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                    else:
                                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-List-Dict-FK not valid: " + str(FKS)]})
                                                else:
                                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-List-? can not be determined." + str(type(REMOTEKEYTTYPES["FK"])) + " -> " + str(REMOTEKEYTTYPES["FK"])]})
                                            else:
                                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-List-RKType not valid: " + str(REMOTEKEYTTYPES)]})
                                    elif isinstance(REMOTEKEYS["Type"], dict):
                                        REMOTEKEYTTYPES = REMOTEKEYS["Type"]
                                        if REMOTEKEYTTYPES.has_key("@name") and REMOTEKEYTTYPES.has_key("FK"):
                                            ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"].append({REMOTEKEYTTYPES["@name"]: []})
                                            COUNTER_REMOTESUBKEY += 1
                                            if isinstance(REMOTEKEYTTYPES["FK"], list):
                                                for FKS in REMOTEKEYTTYPES["FK"]:
                                                    if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                        ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                    else:
                                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-Dict-List-FK not valid: " + str(FKS)]})
                                            elif isinstance(REMOTEKEYTTYPES["FK"], dict):
                                                FKS = REMOTEKEYTTYPES["FK"]
                                                if FKS.has_key("@name") and FKS.has_key("@type") and FKS.has_key("@key"):
                                                    ICON_VALIDATION_DICT[OBJECT][SUBOBJECT]["ValidationIntegrity"]["REMOTEKEY"][COUNTER_REMOTEKEY]["FK_CHECK"][COUNTER_REMOTESUBKEY][REMOTEKEYTTYPES["@name"]].append(str(FKS["@name"]) + "_" + str(FKS["@type"]) + "_" + str(FKS["@key"]))
                                                else:
                                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-Dict-Dict-FK not valid: " + str(FKS)]})
                                            else:
                                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-Dict-? can not be determined: " + str(type(REMOTEKEYTTYPES["FK"])) + " -> " + str(REMOTEKEYTTYPES["FK"])]})
                                        else:
                                            LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-Dict-RKType not valid: " + str(REMOTEKEYTTYPES)]})
                                    else:
                                        LOGFILE.put({"main": ["DEBUG", time.localtime(),"Dict-? can not be determined: " + str(type(REMOTEKEYTTYPES)) + " -> " + str(REMOTEKEYTTYPES)]})
                                else:
                                    LOGFILE.put({"main": ["DEBUG", time.localtime(),"List-RemoteKey is not valid: " + str(REMOTEKEYS)]})
                            else:
                                LOGFILE.put({"main": ["DEBUG", time.localtime(),"List/Dict-Type of remote key could not be determined: " + str(type(NODES["ValidationIntegrity"]["RemoteKey"])) + " -> " + str(NODES["ValidationIntegrity"]["RemoteKey"])]})

        if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
            for OBJECTS in ICON_VALIDATION_DICT.keys():
                for SUBOBJECTS in ICON_VALIDATION_DICT[OBJECTS].keys():
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS)]})
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationXPath"])]})
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> SQL-Command" + str(type(ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationSQL"])) + " with len: " + str(len(ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationSQL"]))]})
                    if ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS].has_key("ValidationIntegrity"):
                        for VALIDATIONINT in ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationIntegrity"].keys():
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(VALIDATIONINT)]})
                            if VALIDATIONINT == "OWNKEY":
                                for KEYS in ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationIntegrity"][VALIDATIONINT]:
                                    LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(VALIDATIONINT) + " -> " + str(KEYS["NAME"]) + " -> " + str(KEYS["XPATH"])]})
                            if VALIDATIONINT == "REMOTEKEY":
                                for KEYS in ICON_VALIDATION_DICT[OBJECTS][SUBOBJECTS]["ValidationIntegrity"][VALIDATIONINT]:
                                    LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(VALIDATIONINT) + " -> " + str(KEYS["NAME"]) + " -> " + str(KEYS["TYPE"]) + " -> " + str(KEYS["XPATH"])]})
                                    for FK_CHECKS in KEYS["FK_CHECK"]:
                                        LOGFILE.put({"main": ["DEBUG", time.localtime(), str(OBJECTS) + " -> " + str(SUBOBJECTS) + " -> " + str(VALIDATIONINT) + " -> FK_CHECK -> "+ str(FK_CHECKS)]})

    else:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Setup iConValidation.xml: NO path and/or name values in config found!"]})

def handleSearchFile():
    global CURDIR
    global CONFIG_DICT
    global SEARCH_DICT
    global STATISTICS
    global LOGFILE
    global ICON_VALIDATION_DICT
    SEARCHFILEREFINED = {}
    SEARCH_DICT = {}

    if CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"] != False:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Setup search.xml: Path and/or name values in config found: " + str(CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"]) + " -> " + str(type(CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"]))]})
        if isinstance(CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"], str) and os.path.isfile(CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"]):
            with open(CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"]) as XMLCONFIGFILE:
                SEARCHFILEREFINED = xmltodict.parse(XMLCONFIGFILE.read())
    if "KLAMMERUNG" in SEARCHFILEREFINED.keys():
        if isinstance(SEARCHFILEREFINED["KLAMMERUNG"], dict) and len(SEARCHFILEREFINED["KLAMMERUNG"]) > 0:
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Dict found: \n" + str(SEARCHFILEREFINED["KLAMMERUNG"])]})
            for SEARCHOBJECTS in SEARCHFILEREFINED["KLAMMERUNG"].keys():
                if isinstance(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS], dict) and len(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS]) > 0:
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Got a 'DICT' for: " + str(SEARCHOBJECTS) + " -> processing..."]})
                    DEF_LIST = []
                    for DEF in SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS].keys():
                        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Checking: " + str(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF]) + " -> " + str(len(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF]))]})
                        if isinstance(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF], list):
                            for SUBDEFS in SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF]:
                                LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Found: " + str(SUBDEFS)]})
                                DEF_LIST.append(SUBDEFS)
                        elif isinstance(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF], dict):
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Found: " + str(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF])]})
                            DEF_LIST.append(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF])
                        else:
                            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Not a DICT oder LIST: " + str(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS][DEF])]})
                        if len(DEF_LIST)>0:
                            for SEARCHKEYS in DEF_LIST:
                                if isinstance(SEARCHKEYS,dict) and "@NAME" in str(SEARCHKEYS.keys()) and "#text" in str(SEARCHKEYS.keys()):
                                    if not str(SEARCHOBJECTS) in SEARCH_DICT.keys():
                                        SEARCH_DICT[str(SEARCHOBJECTS)]={}
                                    if not str(SEARCHKEYS["@NAME"]) in SEARCH_DICT[str(SEARCHOBJECTS)].keys():
                                        SEARCH_DICT[str(SEARCHOBJECTS)][str(SEARCHKEYS["@NAME"])] = []
                                        for SINGLELINES in str(SEARCHKEYS["#text"]).split("\n"):
                                            #SINGLELINES = SINGLELINES.strip().strip('"').strip("'")  # Deactivated by MKS-136622
                                            SEARCH_DICT[str(SEARCHOBJECTS)][str(SEARCHKEYS["@NAME"])].append(SINGLELINES)
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Result: " + str(SEARCH_DICT[str(SEARCHOBJECTS)])]})
                elif isinstance(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS], types.NoneType):
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Got a 'None' for: " + str(SEARCHOBJECTS) + " -> ignoring..."]})
                else:
                    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Search: Not a valid object result: " + str(SEARCHOBJECTS) + " -> " + str(SEARCHFILEREFINED["KLAMMERUNG"][SEARCHOBJECTS])]})

def commandlineInteraction():
    global CURDIR
    global EXT_CONFIG
    global CONFIG_DICT
    global STATISTICS
    PARSER = argparse.ArgumentParser(prog="SiMEx-VT", description="Planning to take over the world ]:>", epilog="To be used by TSS ONLY!")
    PARSER.add_argument("-v", "--verbose", help="[ACTIVE] Increase output verbosity", action="store_true")
    PARSER.add_argument("-V", '--version', action='version', version='%(prog)s ' + VERSION)
    PARSER.add_argument("-C", '--showconfig', help="[ACTIVE] Show config", action="store_true")
    PARSER.add_argument("-E", '--email', help="[ACTIVE] Sends an Email to the named person", nargs='?', metavar='EMAILADDRESS', const='marco.zuhl@daimler.com')
    PARSER.add_argument("-i", "--checkintegrity", help="""[ACTIVE] Checking crossfile integrity. Will only work when in combination with "-x All" """, action='store_true')
    PARSER.add_argument("-c", "--config", help="[ACTIVE]: Use predefined config file. Specify complete path and filename! Defaulting to config.ini when activated.", nargs='?', metavar='FILENAME', default="config.ini")
    PARSER.add_argument("-o", "--iconvalidation", help="[ACTIVE]: Use predefined iConValidation.xml file. Specify complete path and filename! Defaulting to config.ini when activated. Right now looking for iCON", nargs='?', metavar='(PATH)FILENAME', const="iCon-Validation.xml")
    PARSER.add_argument("-f", "--find", help="[ACTIVE] Use predefined file with values to search for. Specify complete path and filename! Defaulting to search.xml when activated.", nargs='?', metavar='FILENAME', const="search.xml")
    PARSER.add_argument("-W", "--workdir", help="[ACTIVE] Define the working path, where the XML-Files are planned/stored. Currently using: %s" % CURDIR, nargs='?', const=".")
    PARSER.add_argument("-L", "--logdir",   help="[ACTIVE] Define the logging directory. Currently using the relative path'.\\LOGS'", nargs='?', const="\\LOGS")
    PARSER.add_argument("-Z", "--zipdir", help="[ACTIVE] Define the target directory for Object ZIPs. If this option is given, all object/subobjects will be put to separate ZIP-Files. If the option is given, but no path attached, we will be using the relative path'.\\ZIPS'", nargs='?', const="\\ZIPS")
    PARSER.add_argument("-e", "--extract", help="[ACTIVE] Objects wanting to be extracted, defaulting to 'None'", choices=EXT_CONFIG, nargs='*')
    PARSER.add_argument("-x", "--checkxsd", help="[ACTIVE] Objects wanting to be checked against XSD, defaulting to 'None'", choices=EXT_CONFIG, nargs='*')
    PARSER.add_argument("-p", "--checkxpath", help="[ACTIVE] Objects wanting to be checked against XPath, defaulting to 'None'", choices=EXT_CONFIG, nargs='*')

    ARGS = PARSER.parse_args()
    # Verbose needs to be handled first. We need that already for the config.
    if ARGS.verbose:
        LOCAL_VERBOSE = "DEBUG"
        CONFIG_DICT["ENVIRONMENT"]["LOGGING"] = LOCAL_VERBOSE
    else:
        LOCAL_VERBOSE = CONFIG_DICT["ENVIRONMENT"]["LOGGING"]

    # Next we are reading the config file if handed over. Otherwise... we will stick to the defaults.
    if ARGS.config != None:
        CONFIG_DICT["ENVIRONMENT"]["CONFIG_FILE"] = ARGS.config
        try:
            #if True:
            CONFIG = ConfigParser.SafeConfigParser()
            CONFIG.readfp(codecs.open(CONFIG_DICT["ENVIRONMENT"]["CONFIG_FILE"], 'r', "utf-8-sig", "replace"))
            #CONFIG.read(CONFIG_DICT["ENVIRONMENT"]["CONFIG_FILE"])
            CONFIG_DICT["ENVIRONMENT"].update(ConfigSectionMap(CONFIG, "Environment", CHECKBOOL=True))
            # Config.ini might overwrite our verbosity level. But Command line rules them all.
            if LOCAL_VERBOSE == "DEBUG":
                CONFIG_DICT["ENVIRONMENT"]["LOGGING"] = LOCAL_VERBOSE
            CONFIG_DICT["EXTRACTION"].update(ConfigSectionMap(CONFIG, "Extraction"))
            CONFIG_DICT["CHECKLIST"].update(ConfigSectionMap(CONFIG, "Checklist"))
            CONFIGWARNING = ""
        except ConfigParser.MissingSectionHeaderError:
            CONFIGWARNING = "Could not read Config section header!"
            LOGFILE.put({"main": ["ERROR", time.localtime(), CONFIGWARNING]})
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "File: " + str(CONFIG_DICT["ENVIRONMENT"]["CONFIG_FILE"]) + " seems to be malformed. Working path of this executable is: " + str(CURDIR)]})
        except:
            CONFIGWARNING = "WARNING! The config given can not be loaded! Falling back to defaults!"
            LOGFILE.put({"main": ["ERROR", time.localtime(), CONFIGWARNING]})
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "File: " + str(CONFIG_DICT["ENVIRONMENT"]["CONFIG_FILE"]) + " could not be found or loaded. Working path of this executable is:" + str(CURDIR)]})
        finally:
            ConfigCleanup("EXTRACTION")
            ConfigCleanup("CHECKLIST")

    if ARGS.iconvalidation != None:
        if os.path.isfile(str(ARGS.iconvalidation)):
            CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XPATH_CONFIG"] = ""
            CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"] = str(ARGS.iconvalidation)
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Config modified. Set iconvalidation to: " + str(ARGS.iconvalidation)]})
        else:
            LOGFILE.put({
                "main": ["ERROR", time.localtime(), "Could not set iCon-Validation-File to: " + str(ARGS.iconvalidation) + "! Target is not a valid file!"]})

    if ARGS.workdir != None:
        WORKDIR = str(ARGS.workdir)
        if len(WORKDIR) in range(1, 250) or WORKDIR.find("//") != -1:
            if WORKDIR[-1] not in ("/", "\\"):
                WORKDIR = WORKDIR + "/"
            CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"] = WORKDIR
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Config modified. Set workdir to: " + str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"])]})
        else:
            LOGFILE.put({"main": ["ERROR", time.localtime(), "Directory is not allowed to be longer than 250 characters or invalid characters are used! -> " + str(WORKDIR)]})

    if ARGS.zipdir != None:
        WORKDIR = str(ARGS.zipdir)
        if len(WORKDIR) in range(1, 250) or WORKDIR.find("//") != -1:
            if WORKDIR[-1] not in ("/", "\\"):
                WORKDIR = WORKDIR + "/"
            CONFIG_DICT["ENVIRONMENT"]["PATH_TO_ZIPS"] = WORKDIR
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Config modified. Set zipdir to: " + str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_ZIPS"])]})
            CONFIG_DICT["ENVIRONMENT"]["ZIPPING"] = True
        else:
            LOGFILE.put({"main": ["ERROR", time.localtime(), "Directory is not allowed to be longer than 250 characters or invalid characters are used! -> " + str(WORKDIR)]})

    if ARGS.logdir != None:
        WORKDIR = str(ARGS.logdir)
        if len(WORKDIR) in range(1, 250) or WORKDIR.find("//") != -1:
            if WORKDIR[-1] not in ("/", "\\"):
                WORKDIR = WORKDIR + "/"
            CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] = WORKDIR
            LOGFILE.put({"main": ["DEBUG", time.localtime(), "Config modified. Set logdir to: " + str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"])]})
        else:
            LOGFILE.put({"main": ["ERROR", time.localtime(),"Directory is not allowed to be longer than 250 characters or invalid characters are used! -> " + str(WORKDIR)]})

    LOGFILE.put({"main": ["initlog", False, False]})

    if ARGS.email != None:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "Email with following parameters activated: " + str(ARGS.email)]})
        CONFIG_DICT["ENVIRONMENT"]["EMAIL"] = str(ARGS.email)

    if ARGS.extract != None:
        if "None" not in ARGS.extract:
            for ARGUMENTS in ARGS.extract:
                UPPER_ARGUMENTS = str(ARGUMENTS).upper()
                if UPPER_ARGUMENTS.find("_") == -1:
                    if UPPER_ARGUMENTS == "ALL":
                        CONFIG_DICT["EXTRACTION"]["ALL_OBJECTS"]="ALL"
                        ConfigCleanup("EXTRACTION")
                    elif len(TRANSLATION_DICT[ARGUMENTS]) > 0:
                        if not CONFIG_DICT["EXTRACTION"].has_key(UPPER_ARGUMENTS):
                            CONFIG_DICT["EXTRACTION"][UPPER_ARGUMENTS] = []
                        for EXT_SUBOBJECTS in TRANSLATION_DICT[ARGUMENTS].keys():
                            if TRANSLATION_DICT[ARGUMENTS][EXT_SUBOBJECTS]["STANDARD_EXPORT"]:
                                if EXT_SUBOBJECTS not in CONFIG_DICT["EXTRACTION"][UPPER_ARGUMENTS]:
                                    CONFIG_DICT["EXTRACTION"][UPPER_ARGUMENTS].append(EXT_SUBOBJECTS)
                    else:
                        CONFIG_DICT["EXTRACTION"][UPPER_ARGUMENTS] = TRANSLATION_DICT[ARGUMENTS].keys()
                else:
                    MAINOBJECT, SUBOBJECT = ARGUMENTS.split("_", 1)
                    if not CONFIG_DICT["EXTRACTION"].has_key(string.upper(MAINOBJECT)):
                        CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)] = []
                    if isinstance(CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)], str):
                        if CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)] not in ("ALL", "TRUE", "YES"):
                            CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)] = [SUBOBJECT]
                        else:
                            # Es wurde zwar ein Subtyp angefordert, da aber auch der Main-Typ extrahiert
                            # werden soll, werfen wir die Zusatz-Info weg.
                            pass
                    elif isinstance(CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)], list):
                        if SUBOBJECT not in CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)]:
                            CONFIG_DICT["EXTRACTION"][string.upper(MAINOBJECT)].append(SUBOBJECT)

    if ARGS.checkintegrity:
        LOGFILE.put({"main": ["DEBUG", time.localtime(), "CheckInt: We got a command to set the flag to: " + str(ARGS.checkintegrity)]})
        CONFIG_DICT["ENVIRONMENT"]["CHECKINTEGRITY"] = True

    if ARGS.checkxsd != None:
        #if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
        #    print "CheckXSD called:", ARGS.checkxsd
        if "None" not in ARGS.checkxsd:
            for ARGUMENTS in ARGS.checkxsd:
                UPPER_ARGUMENTS = str(ARGUMENTS).upper()
                if UPPER_ARGUMENTS.find("_") == -1:
                    if UPPER_ARGUMENTS == "ALL":
                        CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"] = "XSD"
                        ConfigCleanup("CHECKLIST")
                    elif len(TRANSLATION_DICT[ARGUMENTS]) > 0:
                        if not CONFIG_DICT["CHECKLIST"].has_key(UPPER_ARGUMENTS):
                            CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS] = {}
                        for EXT_SUBOBJECTS in TRANSLATION_DICT[ARGUMENTS].keys():
                            if TRANSLATION_DICT[ARGUMENTS][EXT_SUBOBJECTS]["STANDARD_EXPORT"] or EXT_SUBOBJECTS == "NONE":
                                if EXT_SUBOBJECTS not in CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS].keys():
                                    CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS] = []
                                if "XSD" not in CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS]:
                                    CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS].append("XSD")

                    else:
                        CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS] = TRANSLATION_DICT[ARGUMENTS].keys()
                else:
                    MAINOBJECT, SUBOBJECT = ARGUMENTS.split("_", 1)
                    if not CONFIG_DICT["CHECKLIST"].has_key(string.upper(MAINOBJECT)):
                        CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)] = {}
                    if isinstance(CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)], str):
                        if CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)] not in ("ALL", "XSD", "XPATH", "INT"):
                            CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT] = ["XSD"]
                        else:
                            # Es wurde zwar ein Subtyp angefordert, da aber auch der Main-Typ extrahiert
                            # werden soll, werfen wir die Zusatz-Info weg.
                            pass
                    if not CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)].has_key(SUBOBJECT):
                        CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT] = []
                    if isinstance(CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT], list):
                        if "XSD" not in CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT]:
                            CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT].append("XSD")

        else:
            LOGFILE.put({"main": ["WARN", time.localtime(), "XSD-Check: 'None' mentioned! Not going to extract."]})

    if ARGS.checkxpath != None:
        #if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
        #    print "CheckXSD called:", ARGS.checkxsd
        if "None" not in ARGS.checkxpath:
            for ARGUMENTS in ARGS.checkxpath:
                UPPER_ARGUMENTS = str(ARGUMENTS).upper()
                if UPPER_ARGUMENTS.find("_") == -1:
                    if UPPER_ARGUMENTS == "ALL":
                        CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"] = "XPATH"
                        ConfigCleanup("CHECKLIST")
                    elif len(TRANSLATION_DICT[ARGUMENTS]) > 0:
                        if not CONFIG_DICT["CHECKLIST"].has_key(UPPER_ARGUMENTS):
                            CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS] = {}
                        for EXT_SUBOBJECTS in TRANSLATION_DICT[ARGUMENTS].keys():
                            if TRANSLATION_DICT[ARGUMENTS][EXT_SUBOBJECTS]["STANDARD_EXPORT"] or EXT_SUBOBJECTS == "NONE":
                                if EXT_SUBOBJECTS not in CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS].keys():
                                    CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS] = []
                                if "XPATH" not in CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS]:
                                    CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS][EXT_SUBOBJECTS].append("XPATH")

                    else:
                        CONFIG_DICT["CHECKLIST"][UPPER_ARGUMENTS] = TRANSLATION_DICT[ARGUMENTS].keys()
                else:
                    MAINOBJECT, SUBOBJECT = ARGUMENTS.split("_", 1)
                    if not CONFIG_DICT["CHECKLIST"].has_key(string.upper(MAINOBJECT)):
                        CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)] = {}
                    if isinstance(CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)], str):
                        if CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)] not in ("ALL", "XSD", "XPATH", "INT"):
                            CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT] = ["XSD"]
                        else:
                            # Es wurde zwar ein Subtyp angefordert, da aber auch der Main-Typ extrahiert
                            # werden soll, werfen wir die Zusatz-Info weg.
                            pass
                    if not CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)].has_key(SUBOBJECT):
                        CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT] = []
                    if isinstance(CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT], list):
                        if "XPATH" not in CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT]:
                            CONFIG_DICT["CHECKLIST"][string.upper(MAINOBJECT)][SUBOBJECT].append("XPATH")

        else:
            LOGFILE.put({"main": ["WARN", time.localtime(), "XPATH-Check: 'None' mentioned! Not going to extract."]})

    if ARGS.find != None:
        CONFIG_DICT["ENVIRONMENT"]["FIND_FILE"] = ARGS.find
    if ARGS.showconfig:
        LOGFILE.put({"main": ["INFO", time.localtime(), "Current config settings:"]})
        for KEYS in CONFIG_DICT.keys():
            LOGFILE.put({"main": ["INFO", time.localtime(), str(KEYS) + " -> " + str(CONFIG_DICT[KEYS])]})

def updateStatistics(OBJECT="NONE", SUBOBJECT="NONE", STATTYPE="NONE", SPECIAL="NONE", MODE="NEW", KEY="NONE", VALUE="NONE"):
    global STATISTICS

    if not(len(STATISTICS)>0 and isinstance(STATISTICS, dict)):
        STATISTICS = {}
    if not OBJECT in STATISTICS.keys():
        STATISTICS[OBJECT] = {}
    if not SUBOBJECT in STATISTICS[OBJECT].keys():
        STATISTICS[OBJECT][SUBOBJECT] = {}
    if not SPECIAL in STATISTICS[OBJECT][SUBOBJECT].keys():
        STATISTICS[OBJECT][SUBOBJECT][SPECIAL] = {}
    if not STATTYPE in STATISTICS[OBJECT][SUBOBJECT][SPECIAL].keys():
        STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE] = {}

    if MODE == "NEW":
        STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE][KEY] = VALUE
    elif MODE == "UPD" or MODE == "ADD":
        if KEY not in STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE].keys():
            if isinstance(VALUE, int):
                STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE][KEY] = 0
            elif isinstance(VALUE, str):
                STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE][KEY] = ""
        STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE][KEY] = STATISTICS[OBJECT][SUBOBJECT][SPECIAL][STATTYPE][KEY] + VALUE

def doesTrDictEntryExist(OBJECT="", SUBOBJECT=""):
    RETURNVALUE = False
    for KEYS in TRANSLATION_DICT.keys():
        UPPER_KEYS = string.upper(KEYS)
        if UPPER_KEYS == string.upper(OBJECT) and string.upper(SUBOBJECT) in TRANSLATION_DICT[KEYS].keys():
            RETURNVALUE = True
            break
    return RETURNVALUE

def main():
    # Setzen des Ausgangskanals auf das richtige/vom System präferierte Encoding
    sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)
    global CONFIG_DICT
    global CURDIR
    global LOGFILE
    # Jobqueue erstellen (Queue)
    # gc.disable()
    EXTRACTION = Queue.Queue()
    XSDCHECK = Queue.Queue()
    XPATHCHECK = Queue.Queue()
    INTEGRITY = Queue.Queue(maxsize=2000)
    SEARCH = Queue.Queue()
    FILECHECKER = Queue.Queue()
    LOGFILE = Queue.Queue(maxsize=2000)
    # Ausschalter erstellen (Event)
    POWERSWITCH = threading.Event()
    LOGFILE_THREAD = LoggingThread(POWERSWITCH, LOGFILE)
    LOGFILE_THREAD.daemon = True
    LOGFILE_THREAD.start()
    LOGFILE.put({"main": ["INFO", time.localtime(), "SiMEx-VT " + str(VERSION)]})
    LOGFILE.put({"main": ["INFO", time.localtime(), "============"]})
    LOGFILE.put({"main": ["INFO", time.localtime(), ""]})
    LOGFILE.put({"main": ["INFO", time.localtime(), "Processing... (If you need help, you can run this program with --help (-h) parameter!)"]})
    LOGFILE.put({"main": ["INFO", time.localtime(), ""]})
    CURDIR = os.getcwd()
    BINARYDIR = os.path.dirname(os.path.abspath(sys.argv[0]))
    ConfigCleanup("EXTRACTION")
    ConfigCleanup("CHECKLIST")

    #for KEYS in CONFIG_DICT:
    #    print KEYS, "->", CONFIG_DICT[KEYS]
    commandlineInteraction()
    handleIconValidation()
    handleSearchFile()

    """
    Startet die Threads und führt den Test durch.
    """

    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Program being called from: " + str(CURDIR)]})
    LOGFILE.put({"main": ["DEBUG", time.localtime(), "Program directory: " + str(BINARYDIR)]})

    # Threads initialisieren und dabei die Jobqueue und den
    # Ausschalter übergeben
    try:
        EXTRACTION_THREAD = ExtractionThread(POWERSWITCH, LOGFILE, EXTRACTION, FILECHECKER)
        CHECKXSD_THREAD = CheckXSDThread(POWERSWITCH, LOGFILE, XSDCHECK, INTEGRITY)
        CHECKXPATH_THREAD = CheckXPATHThread(POWERSWITCH, LOGFILE, XPATHCHECK)
        CHECKINTEGRITY_THREAD = CheckIntegrityThread(POWERSWITCH, LOGFILE, INTEGRITY)
        FILECHECKER_THREAD = FileCheckerThread(POWERSWITCH, LOGFILE, FILECHECKER, XSDCHECK, XPATHCHECK, INTEGRITY, SEARCH)

        #CONFIGTHREAD = ConfigRunnerThread(Extraction,XSDCheck,XPATHCheck,Integrity,Search)
        CONFIG_THREAD = ConfigRunnerThread(POWERSWITCH, LOGFILE, EXTRACTION, XSDCHECK, XPATHCHECK, INTEGRITY, SEARCH, FILECHECKER)

        # Threads starten
        #EXTRACTION_THREAD.daemon = True
        EXTRACTION_THREAD.start()
        #CHECKXSD_THREAD.daemon = True
        CHECKXSD_THREAD.start()
        #CHECKXPATH_THREAD.daemon = True
        CHECKXPATH_THREAD.start()
        #CHECKINTEGRITY_THREAD.daemon = True
        CHECKINTEGRITY_THREAD.start()
        #CONFIG_THREAD.daemon = True
        CONFIG_THREAD.start()
        #FILECHECKER_THREAD.daemon = True
        FILECHECKER_THREAD.start()

        # Warten bis der Ausschalter betätigt wurde. Sonst würde das
        # Programm sofort beendet werden.
        #EXTRACTION.join()
        #time.sleep(10)
        #FILECHECKER.join()
        #XSDCHECK.join()
        #XPATHCHECK.join()
        #INTEGRITY.join()
        #self.SEARCH.join()
        POWERSWITCH.wait()
        #print "Waiting for powerswitch is over."
        time.sleep(5)
        print

    except (KeyboardInterrupt, SystemExit):
        sys.exit()

if __name__ == "__main__":
    main()