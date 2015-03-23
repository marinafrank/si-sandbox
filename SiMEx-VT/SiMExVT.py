# -*- coding: utf-8 -*-
__author__ = 'MARZUHL'
#####################################################
# BEGIN GLOBAL PARAMETERS
#####################################################

CONFIG_FILE="config.ini"

#####################################################
# END GLOBAL PARAMETERS
#####################################################

#####################################################
# BEGINN CONSTRUCTION PARAMETERS
#####################################################

# Default values...
CONFIG_DICT = {
    "ENVIRONMENT" : {
        "LOGFILE_ENDING": 'log'
        , "GLOBAL_LOGFILE": ""
        , "GLOBAL_OUTPUT":"SCREEN"
        , 'LOGGING': 'INFO'
        , 'PATH_TO_XMLS': ''
        , 'PATH_TO_XSD': ''
        , 'XML_ENDINGS': 'xml'
        , 'ORACLE_CONNECT_STRING_SIMEX': 'simex/simex@simex.s415vm779.tst'
        , 'ORACLE_CONNECT_STRING_DB': 'snt/Tss2007$@ref.s415vm779.tst'
        #, 'PATH_TO_XPATH_CONFIG': 'C:/mks/icon/7000_Delivery/7100_Shipments/Tools/'
        , 'PATH_TO_XPATH_CONFIG': ''
        , 'PATH_TO_LOGFILES': ''
        , 'NAME_XPATH_CONFIG': 'iCon-Validation.xml'
        , 'NAME_XSD' : 'all.xsd'
        , 'CSV_ENDING': 'csv'
        , 'LOGFILE_PREFIX': ''
        , 'ENCODING_DB': 'latin-1'
        , "EXTRACTION_CHECK_INTERVAL": 5
        }
    , 'EXTRACTION': {
        'ALL_OBJECTS':'FALSE'
        , 'SERVICECONTRACT': 'FALSE'
        , 'COSTCOLLECTIVE': 'FALSE'
        , 'ORGANISATIONALPERSON': 'FALSE'
        , 'REVENUE': 'FALSE'
        , 'PHYSICALPERSON': 'FALSE'
        , 'ODOMETER': 'FALSE'
        , 'ASSIGNCOSTTOCOST': 'FALSE'
        , 'COST': 'FALSE'
        , 'MODIFICATIONLOGENTRY': 'FALSE'
        , 'OTHERS':'FALSE'
        }
    , 'CHECKLIST': {
        'ALL_OBJECTS':'ALL'
        , 'SERVICECONTRACT': 'NONE'
        , 'COSTCOLLECTIVE': 'NONE'
        , 'ORGANISATIONALPERSON': 'NONE'
        , 'REVENUE': 'NONE'
        , 'PHYSICALPERSON': 'NONE'
        , 'ODOMETER': 'NONE'
        , 'ASSIGNCOSTTOCOST': 'NONE'
        , 'COST': 'NONE'
        , 'MODIFICATIONLOGENTRY': 'NONE'
        }
    }

# Needed as translation table
XPATH_TRANSLATE_PARTNERS={"IGNORE":"ME"
    , "createPhysicalPerson":"partnerType"
    , "updatePhysicalPerson":"partnerType"
    , "createOrganisationalPerson":"partnerType"
    , "updateOrganisationalPerson":"partnerType"
    }

# SQL logic here...
EXTRACTION_LOOKUP = {
    'SERVICECONTRACT': ["40"]
    , 'COSTCOLLECTIVE': ["70"]
    , 'ORGANISATIONALPERSON':
        [ "21"
        , "22"
        , "23"
        , "24"]
    , 'REVENUE': ["50"]
    , 'PHYSICALPERSON':
        [ "10"
        , "11"
        , "12"]
    , 'ODOMETER': ["30"]
    , 'ASSIGNCOSTTOCOST': ["80"]
    , 'COST': ["60"]
    , 'MODIFICATIONLOGENTRY': ["90"]
    , 'OTHERS':
        [ "1"
        , "2"
        , "3"]
    }

SQL_COMMAND_ACTIVATE_EXTRACTION="""declare
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

#EXTRACTION_SQL_FOOTER = """
#end;"""

SQL_COMMAND_CHECK_ACTIVE="""select
  (select nvl(max(TTASK.TAS_ACTIVE),-1) as ACTIVE from TTASK where TTASK.TAS_ACTIVE > 0) as "Activity"
  , (select nvl(max(TLOG.LOG_SEQUENCE),0) from TLOG)  as "Counter"
from dual"""

SQL_COMMAND_LOGQUERY="""
    select distinct
  nvl(tlog.log_sequence,0) as SEQ
  ,ttask.tas_caption      as TaskName
  , tmessage.log_msg_text as MessageState
  , tlog.log_text         as Information
  , tlog.log_timestamp    as TimeInfo
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

# Bitte SIMEX-Links verwenden! Es wird ein Connect auf SIMEX gemacht!
SQL_COMMAND_DUMPNAME_QUERY = '''select GET_TGLOBAL_SETTINGS@simex_db_link('DB', 'DUMP', 'NAME', 'name not found', 'could not be determined') from dual'''

SQL_COMMAND_DUMP_IMPORT_DATE = '''select GET_TGLOBAL_SETTINGS@simex_db_link('DB', 'DUMP', 'IMPORTDATE', 'name not found', 'could not be determined') from dual'''

#####################################################
# END CONSTRUCTION PARAMETERS
#####################################################

#####################################################
# Init der Umgebung, Variablen und Module
#####################################################

from lxml import etree
from copy import deepcopy
import os, string, logging, time, cx_Oracle, os, codecs, sys, locale, ConfigParser

# Setzen des Ausgangskanals auf das richtige/vom System präferierte Encoding
sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)

# Löschen des Bildschirmes
os.system('cls' if os.name == 'nt' else 'clear')

# Laden der Konfiguration aus einer Datei mit Helferfunktion
def ConfigSectionMap(SECTION):
    TMP_DICT = {}
    CONFIG_OPTIONS = CONFIG.options(SECTION)
    for OPTION in CONFIG_OPTIONS:
        CAP_OPTION = str(OPTION).upper()
        try:
            TMP_DICT[CAP_OPTION] = CONFIG.get(SECTION, OPTION)
            if TMP_DICT[CAP_OPTION] == -1:
                print("skip: %s" % OPTION)
        except:
            try:
                TMP_DICT[CAP_OPTION] = CONFIG.getboolean(SECTION, OPTION)
                if TMP_DICT[CAP_OPTION] == -1:
                    print("skip: %s" % OPTION)
            except:
                print("Exception while reading config on %s!" % CAP_OPTION)
                TMP_DICT[CAP_OPTION] = None
    return TMP_DICT

try:
    CONFIG = ConfigParser.SafeConfigParser()
    CONFIG.read(CONFIG_FILE)
    CONFIG_DICT["ENVIRONMENT"].update(ConfigSectionMap("Environment"))
    CONFIG_DICT["EXTRACTION"].update(ConfigSectionMap("Extraction"))
    CONFIG_DICT["CHECKLIST"].update(ConfigSectionMap("Checklist"))
    CONFIGWARNING=""
except:
    CONFIGWARNING = "WARNING! The config given can not be loaded! Falling back to defaults!"
    print CONFIGWARNING

# Wir ziehen die Handler-Klasse auf. Die wird gebraucht, weil das Basis-Logging
# von Python nicht mit mehreren Logfiles mit wechselnden nacheinander klarkommt.
class Logger(object):
    def __init__(self, OBJECT_LOGNAME= "", GLOBAL_LOG = False ):
        if GLOBAL_LOG is True:
            self.GLOBAL=True
        elif OBJECT_LOGNAME <> "":
            self.GLOBAL=False
        else:
            pass

        if self.GLOBAL is False or (self.GLOBAL is True and CONFIG_DICT["ENVIRONMENT"]["GLOBAL_LOGFILE"] <> "" and (CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "LOGFILE" or CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "BOTH")):
            if self.GLOBAL is True:
                self.GLOBAL_TOFILE = True
                self.FORMATTER_LOGFILE = logging.Formatter('%(message)s')
                self.FORMATTER_DISPLAY = logging.Formatter('%(message)s')
                self.LOGGERNAME='global'
                if CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "BOTH":
                    self.GLOBAL_TOSCREEN = True
                else:
                    self.GLOBAL_TOSCREEN = False
            else:
                self.LOGGERNAME='object'

            self.LOGNAME = OBJECT_LOGNAME
            self.LOGGER = logging.getLogger(self.LOGGERNAME)
            # Da wir im Moment nur eine Entscheidungsebene haben...
            if CONFIG_DICT["ENVIRONMENT"]["LOGGING"] == "DEBUG":
                self.LOGGER.setLevel(logging.DEBUG)
            else:
                self.LOGGER.setLevel(logging.INFO)
            if self.GLOBAL is True:
                self.GLOBAL_TOFILE = True
                self.FORMATTER_LOGFILE = logging.Formatter('%(message)s')
                self.FORMATTER_DISPLAY = logging.Formatter('%(message)s')
                if CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "BOTH":
                    self.GLOBAL_TOSCREEN = True
                else:
                    self.GLOBAL_TOSCREEN = False
            else:
                self.FORMATTER_LOGFILE = logging.Formatter('%(levelname)s: %(message)s')
                self.FORMATTER_DISPLAY = logging.Formatter('%(message)s')
            try:
                self.FILEHANDLER = logging.FileHandler(self.LOGNAME, mode="w")
                self.FILEHANDLER.setFormatter(self.FORMATTER_LOGFILE)
                self.LOGGER.addHandler(self.FILEHANDLER)
                if self.LOGGERNAME == "global":
                    self.LOGGERA = logging.getLogger(self.LOGGERNAME)
                else:
                    self.LOGGERB = logging.getLogger(self.LOGGERNAME)

            except:
                print "CRITICAL! Can not create log entity:",self.LOGNAME
                print "Are the directories there? Do I have file writing/creating permissions? Is the config file correct?"
                print "Terminating!"
                sys.exit()

        elif self.GLOBAL is True and (CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "SCREEN" or CONFIG_DICT["ENVIRONMENT"]["GLOBAL_OUTPUT"] == "BOTH"):
            self.GLOBAL_TOSCREEN = True
            self.GLOBAL_TOFILE = False

        else:
                print "CRITICAL! Can not create log entity!"
                print "Is the config file correct?"
                print "Terminating!"
                sys.exit()

        #self.STREAMHANDLER= logging.StreamHandler()
        #self.STREAMHANDLER.setFormatter(self.FORMATTER_DISPLAY)    # zukünftig: Angepasster Formatter für Log-Output to screen.
        #self.LOGGER.addHandler(self.STREAMHANDLER)         # Dito.

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        try:
            self.LOGGER.removeHandler(self.FILEHANDLER)
        except:
            pass

    def getLogName(self):
        return self.LOGNAME

    def writeLog(self, LOGTYPE="INFO", LOGTEXT= "" ):       # Abfrühstücken der Ausgabe-Level
        if LOGTYPE == "INFO":
            self.LOGGERB.info( LOGTEXT )
        elif LOGTYPE == "OUT":
            if self.GLOBAL_TOSCREEN == True:
                print LOGTEXT
            if self.GLOBAL_TOFILE == True:
                self.LOGGERA.info( LOGTEXT )
        elif LOGTYPE == "WARN":
            self.LOGGERB.warning( LOGTEXT )
        elif LOGTYPE == "ERR":
            self.LOGGERB.error( LOGTEXT )
        elif LOGTYPE == "CRIT":
            self.LOGGERB.critical( LOGTEXT )
        elif LOGTYPE == "DEBUG":
            self.LOGGERB.debug( LOGTEXT )
        elif LOGTYPE == "EXCEPTION":
            self.LOGGERB.exception( LOGTEXT )
        else:
            self.LOGGERB.exception("Could not classify:" + str(LOGTYPE) + ": " + str(LOGTEXT) )
# Ende Objektdeklaration

# Setzen der globalen Settings für den Parser
PARSER = etree.XMLParser(no_network = True, resolve_entities=False, strip_cdata=False, compact=False, encoding="utf-8")

# Vorbereiten der Auswertungsvariable
STATISTICS={}


#####################################################
# Hauptprogramm EXTRAKTION
#####################################################

GLOBAL_LOGFILENAME=""
LOGFILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + CONFIG_DICT["ENVIRONMENT"]["GLOBAL_LOGFILE"] + "." + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_ENDING"]
with Logger(LOGFILE_NAME, True) as GLOBAL_LOGFILE:
    if len(CONFIGWARNING)>0:
        GLOBAL_LOGFILE.writeLog("OUT", CONFIGWARNING)
    GLOBAL_LOGFILE.writeLog("OUT", "Sirius iCON Migration Extraction & Verification Tool")
    GLOBAL_LOGFILE.writeLog("OUT", "====================================================")

    GLOBAL_LOGFILE.writeLog("OUT", "\n*** Extraction ***\n")
    LOGFILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + "EXTRACTION." + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_ENDING"]
    GLOBAL_LOGFILE.writeLog("OUT", "Working/writing to logfile: " + str(LOGFILE_NAME))

    with Logger(LOGFILE_NAME) as LOGFILE:
        EXT_RUNCOUNT=0
        SQL_ALL_QUERIES = []
        SQL_ALL_OBJECTS = {}
        STATISTICS["DB_INFO"] = {}
        for EXT_OBJECTS in EXTRACTION_LOOKUP:
            if (
                ( CONFIG_DICT["EXTRACTION"].has_key("ALL_OBJECTS")
                and str(CONFIG_DICT["EXTRACTION"]["ALL_OBJECTS"]).upper() == "ALL"
                )
                or
                ( CONFIG_DICT["EXTRACTION"].has_key(EXT_OBJECTS)
                and str(CONFIG_DICT["EXTRACTION"][EXT_OBJECTS]).upper() == "ALL"
                )
            ):
                EXT_RUNCOUNT=EXT_RUNCOUNT+1

                for ENTRIES in EXTRACTION_LOOKUP[EXT_OBJECTS]:
                    LOGFILE.writeLog("INFO", "Extracting: " + str(EXT_OBJECTS) + " (" + str(ENTRIES) + ")")
                    SQL_ALL_QUERIES.append(SQL_COMMAND_ACTIVATE_EXTRACTION.replace("#*TASK_ORDER*#", str(ENTRIES)))

        if EXT_RUNCOUNT==0:
            GLOBAL_LOGFILE.writeLog("OUT", "No extraction requested. Skipping extraction block.")
            LOGFILE.writeLog("INFO", "No extraction requested. Skipping extraction block.")
        else:
            try:
                CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                SQL=CONNECTION.cursor()
                # Query DB_NAME
                SQL.execute(SQL_COMMAND_DUMPNAME_QUERY)
                EXTRACT_SQL_RESULT=SQL.fetchall()
                # Aufraeumen! \o/
                STATISTICS["DB_INFO"]["DUMPNAME"] = str(EXTRACT_SQL_RESULT[0][0])
                # Query IMPORT_DATE
                SQL.execute(SQL_COMMAND_DUMP_IMPORT_DATE)
                EXTRACT_SQL_RESULT=SQL.fetchall()
                STATISTICS["DB_INFO"]["IMPORT_DATE"] = str(EXTRACT_SQL_RESULT[0][0])
                # Aufraeumen! \o/
                CONNECTION.close()

            except:
                GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not get DB Data (import date and/or import dump name)! Lets see if there are still files that can extracted...")
                LOGFILE.writeLog("ERR", "Can not query for DB import dump name and/or date!")

            try:
                CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                SQL=CONNECTION.cursor()
                for SQL_COMMAND in SQL_ALL_QUERIES:
                    # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                    SQL.execute(SQL_COMMAND)
                    CONNECTION.ping()
                # Aufräumen! \o/
                CONNECTION.close()
            except:
                GLOBAL_LOGFILE.writeLog("OUT", "Error! Extraction setup not possible! Lets see if there are still files that can be checked...")
                LOGFILE.writeLog("ERR", "Extraction setup not possible!")

            try:
                SQL_COMMAND = SQL_COMMAND_CHECK_ACTIVE
                CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                SQL=CONNECTION.cursor()
                SQL.execute(SQL_COMMAND)
                # Wir sind mutig und holen gleich alle Ergebnisse.
                EXTRACT_SQL_RESULT=SQL.fetchall()
                # Aufräumen! \o/
                CONNECTION.close()
            except:
                GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not connect to the DB to check for active tasks!")
                LOGFILE.writeLog("ERR", "Could not connect to the DB to check for active tasks!")
                EXTRACT_SQL_RESULT=None

            if len(EXTRACT_SQL_RESULT)>0 and len(EXTRACT_SQL_RESULT[0]) == 2 and int(EXTRACT_SQL_RESULT[0][0]) == 1:
                SQL_EXCEPTION_COUNT=0
                SQL_TIMEVAR = time.localtime()
                SQL_TIME_START = time.clock()
                SQL_EXTRACTION_HOURS = 0
                GLOBAL_LOGFILE.writeLog("OUT", "Started at: " + str(time.strftime('%Y-%m-%d (%H:%M:%S)', SQL_TIMEVAR)))
                # Wir haben zumindest teilweise Ergebnisse
                EXTRACTION_RUNNING=1
                EXTRACTION_LOG_SEQUENCE=0
                if int(EXTRACT_SQL_RESULT[0][1]) > EXTRACTION_LOG_SEQUENCE:
                    GLOBAL_LOGFILE.writeLog("OUT", "Found older extraction log data. Ignoring...")
                    LOGFILE.writeLog("WARN", "We have " + str(EXTRACT_SQL_RESULT[0][1]) + " previous log entries! We are not the first ones here!")
                    EXTRACTION_LOG_SEQUENCE = str(EXTRACT_SQL_RESULT[0][1])
                LOGFILE.writeLog("INFO", "SEQ; TASKNAME; MESSAGESTATE; INFORMATION; TIMEINFO")
                while EXTRACTION_RUNNING==1:
                    try:
                        #if True:
                        CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                        # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                        SQL=CONNECTION.cursor()
                        SQL.execute(SQL_COMMAND_LOGQUERY.replace("#*REPLACEME*#", str(EXTRACTION_LOG_SEQUENCE)) )
                        # Wir sind mutig und holen gleich alle Ergebnisse.
                        EXTRACT_SQL_RESULT_LOGQUERY=SQL.fetchall()
                        SQL.execute(SQL_COMMAND_CHECK_ACTIVE)
                        EXTRACT_SQL_RESULT_CHECK_ACTIVE=SQL.fetchall()
                        # Aufräumen! \o/
                        CONNECTION.close()

                        if len(EXTRACT_SQL_RESULT_LOGQUERY)>0:
                            for SQL_RESULTS in EXTRACT_SQL_RESULT_LOGQUERY:
                                if len(SQL_RESULTS) == 5:
                                    LOGFILE.writeLog("INFO", str(SQL_RESULTS[0]) + "; "+str(SQL_RESULTS[1]) + "; "+str(SQL_RESULTS[2]) + "; "+str(SQL_RESULTS[3]) + "; "+str(SQL_RESULTS[4]))
                                    EXTRACTION_LOG_SEQUENCE = str(SQL_RESULTS[0])

                        if len(EXTRACT_SQL_RESULT_CHECK_ACTIVE)>0 and int(EXTRACT_SQL_RESULT_CHECK_ACTIVE[0][0]) == 1:
                            if time.clock() > (SQL_TIME_START + SQL_EXTRACTION_HOURS*3600 + 3590):
                                SQL_EXTRACTION_HOURS= SQL_EXTRACTION_HOURS + 1
                                GLOBAL_LOGFILE.writeLog("OUT", "Still running... ( " + str(SQL_EXTRACTION_HOURS) + " hours for now )")
                            time.sleep(int(CONFIG_DICT["ENVIRONMENT"]["EXTRACTION_CHECK_INTERVAL"])*60)
                        else:
                            SQL_TIME_END=time.clock()
                            SQL_TIME_DIFF = SQL_TIME_END - SQL_TIME_START
                            SQL_TIMEVAR = time.localtime()
                            EXTRACTION_RUNNING = 0
                            GLOBAL_LOGFILE.writeLog("OUT", "Finished at: " + str( time.strftime('%Y-%m-%d (%H:%M:%S)', SQL_TIMEVAR)))
                            GLOBAL_LOGFILE.writeLog("OUT", "Elapsed time: " + str(time.strftime('%H:%M:%S', time.gmtime(SQL_TIME_DIFF))))

                    except:
                        GLOBAL_LOGFILE.writeLog("OUT", "Error! Could not connect to the DB to check for active tasks!")
                        LOGFILE.writeLog("ERR", "Could not connect to the DB to check for active tasks!")
                        if SQL_EXCEPTION_COUNT < 3:
                            GLOBAL_LOGFILE.writeLog("OUT", "Trying again in 5 minutes...")
                            LOGFILE.writeLog("ERR", "Trying again in 5 minutes...")
                            SQL_EXCEPTION_COUNT = SQL_EXCEPTION_COUNT + 1
                            time.sleep(5*60)
                            pass
                        else:
                            GLOBAL_LOGFILE.writeLog("OUT", "Tried for 3 times now. Aborting extraction.")
                            LOGFILE.writeLog("ERR", "Tried for 3 times now. Aborting extraction.")
            else:
                GLOBAL_LOGFILE.writeLog("OUT", "WARNING: No extraction task can be found.")
                LOGFILE.writeLog("WARN", "No extraction task can be found.")

        # Keine Extraktion gewünscht.
    # Dies schließt das Logging für dieses Objekt ab.

    GLOBAL_LOGFILE.writeLog("OUT", "\n*** Verification ***\n")

    #####################################################
    # Vorbereitung VERIFIKATION
    #####################################################
    # Initialisieren der XPATH-Konfiguration aus der CheckXML-Konfiguration
    XPATH_COMMANDS = {}

    FULL_XPATH_CONFIG_PATH = str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XPATH_CONFIG"]) + str(CONFIG_DICT["ENVIRONMENT"]["NAME_XPATH_CONFIG"])
    XML_CONFIG= etree.parse(FULL_XPATH_CONFIG_PATH)
    XML_CONFIG_ROOT = XML_CONFIG.getroot()
    for OPERATION in XML_CONFIG_ROOT:
        if OPERATION.tag == "operation":
            OPERATION_DICT = dict(OPERATION.attrib)
            if OPERATION_DICT.has_key("name"):
                XML_CONFIG_TYPE=OPERATION_DICT["name"]
                if not XPATH_COMMANDS.has_key(XML_CONFIG_TYPE):
                    XPATH_COMMANDS[XML_CONFIG_TYPE] = {}
            else:
                GLOBAL_LOGFILE.writeLog("OUT", "Invalid XML! No key 'name'!")

            XML_CONFIG_SUBTYPE = ""

            for OPERATION_NODES in OPERATION:
                if len(OPERATION.xpath("./type/value")) != 0:
                    XML_CONFIG_SUBTYPE = OPERATION.xpath("./type/value")[0].text
                else:
                    XML_CONFIG_SUBTYPE = "NONE"
                if not XPATH_COMMANDS[XML_CONFIG_TYPE].has_key(XML_CONFIG_SUBTYPE):
                    XPATH_COMMANDS[XML_CONFIG_TYPE][XML_CONFIG_SUBTYPE]={}

                if OPERATION_NODES.tag == "type":
                    pass

                elif OPERATION_NODES.tag == "ValidationSQL":
                    if OPERATION_NODES.text != "":
                        XPATH_COMMANDS[XML_CONFIG_TYPE][XML_CONFIG_SUBTYPE]["ValidationSQL"]=OPERATION_NODES.text
                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "No Text in Node!")

                elif OPERATION_NODES.tag == "ValidationXPath":
                    if OPERATION_NODES.text != "":
                        XPATH_COMMANDS[XML_CONFIG_TYPE][XML_CONFIG_SUBTYPE]["ValidationXPath"]=OPERATION_NODES.text
                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "No Text in Node!")

                elif OPERATION_NODES.tag == "ValidationXSDPath1":
                    if OPERATION_NODES.text != "":
                        XPATH_COMMANDS[XML_CONFIG_TYPE][XML_CONFIG_SUBTYPE]["ValidationXSDPath1"]=OPERATION_NODES.text
                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "No Text in Node!")

                elif OPERATION_NODES.tag == "ValidationXSDPath2":
                    if OPERATION_NODES.text != "":
                        XPATH_COMMANDS[XML_CONFIG_TYPE][XML_CONFIG_SUBTYPE]["ValidationXSDPath2"]=OPERATION_NODES.text
                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "No Text in Node!")

                else:
                    GLOBAL_LOGFILE.writeLog("OUT", "No defined node!")

        else:
            GLOBAL_LOGFILE.writeLog("OUT", "Invalid XML! No node 'operation'!")

    # Holen der Dateistruktur
    FULL_XSD_PATH=CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XSD"] + CONFIG_DICT["ENVIRONMENT"]["NAME_XSD"]

    try:
        DIRLIST = os.listdir(str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]))
    except:
        GLOBAL_LOGFILE.writeLog("OUT", "Error! Got no files in " + str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"]) + " for checking...")
        DIRLIST = []
    DIRLIST.sort()

    REFINED_DIRLIST = {}
    for DATEIEN in DIRLIST:
        if DATEIEN.find("."+str(CONFIG_DICT["ENVIRONMENT"]["XML_ENDINGS"]))!= -1:
            INTERMEDIATE_DATEITYP, _ = string.split(DATEIEN,"_",1)
            _ , MIXED_DATEITYP = string.split(INTERMEDIATE_DATEITYP,"-",1)
            DATEITYP = str(MIXED_DATEITYP).upper()
            if not REFINED_DIRLIST.has_key(DATEITYP):
                REFINED_DIRLIST[DATEITYP] = []
                STATISTICS[DATEITYP] = {}
                STATISTICS[DATEITYP]["Mixed_Dateityp"] = MIXED_DATEITYP
                STATISTICS[DATEITYP]["Data_Errors"] = 0
                STATISTICS[DATEITYP]["Files_Processed"] = 0
                STATISTICS[DATEITYP]["SubTyp"] = {}
            REFINED_DIRLIST[DATEITYP].append(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_XMLS"] + DATEIEN)

    try:
        XMLSCHEMA_DOC = etree.parse(FULL_XSD_PATH)
        XMLSCHEMA = etree.XMLSchema(XMLSCHEMA_DOC)
    except:
        GLOBAL_LOGFILE.writeLog("OUT", "Error! Can not load " + str(FULL_XSD_PATH) + "!")
        GLOBAL_LOGFILE.writeLog("OUT", "There will be errors in XSD Verification!")

    #####################################################
    # Hauptprogramm VERIFIKATION
    #####################################################

    GLOBAL_LOGFILE.writeLog("OUT", "Loading files...")

    # Wir iterieren über die Objekte ("DATEITYP") wie "Cost", "Odometer",...
    for DATEITYP in REFINED_DIRLIST:

        ###################################
        # XSD-Prüfungslogik
        ###################################

        # Prüfen, ob der Objekttyp validiert werden soll

        if (
            ( CONFIG_DICT["CHECKLIST"].has_key("ALL_OBJECTS")
            and (
                    str(CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"]).upper() == "ALL"
                or (
                    str(CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"]).upper() == "XSD"
                    )
                )
            )
        or
            ( CONFIG_DICT["CHECKLIST"].has_key(DATEITYP)
            and (
                    str(CONFIG_DICT["CHECKLIST"][DATEITYP]).upper() == "ALL"
                or (
                    str(CONFIG_DICT["CHECKLIST"][DATEITYP]).upper() == "XSD"
                    )
                )
            )
        ):
            # Dateityp (Objekt) soll überprüft werden.
            # Wir erstellen als erstes ein entsprechendes Logfile
            LOGFILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(STATISTICS[DATEITYP]["Mixed_Dateityp"]) + "_XSD" + "." + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_ENDING"]
            GLOBAL_LOGFILE.writeLog("OUT", "\nWorking/writing to logfile: " + str(LOGFILE_NAME))

            with Logger(LOGFILE_NAME) as LOGFILE:

                # Iteration über alle Elemente des Objekt-Typs
                GLOBAL_LOGFILE.writeLog("OUT", "Checking against Reference XSD: " + str(FULL_XSD_PATH))
                for XML_FILES in REFINED_DIRLIST[DATEITYP]:
                    GLOBAL_LOGFILE.writeLog("OUT", "Validating (XSD): " + str( XML_FILES))

                    LOGFILE.writeLog( "INFO", str("Validating: " + str(XML_FILES)) )
                    LOGFILE.writeLog( "INFO", str("Against XSD: " + str(FULL_XSD_PATH)) )
                    # Vorbereitung / Laden des Files
                    PARSER = etree.XMLParser(no_network = True, resolve_entities=False, strip_cdata=False, compact=False)
                    TREE= etree.parse(XML_FILES, PARSER)
                    ROOT=TREE.getroot()

                    # Prüfung des kompletten Original-Files auf Konformität (sehr schnell)
                    try:
                        if XMLSCHEMA.validate(ROOT) != True:
                            # Die Prüfung/Validierung ist fehlgeschlagen. Wir gehen in die Detailprüfung...
                            LOGFILE.writeLog( "WARN", str("Validation failed for:" + str(XML_FILES)))
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
                                NEWROOTLIST=NEWROOTTEXT.splitlines(True)
                                # 2. Das Gleiche machen wir mit dem zu validierenden Einzelknoten
                                XMLTEXT = etree.tostring(ATTRIBUTES)
                                XMLLIST = XMLTEXT.splitlines(True)
                                # 3. Wir übernehmen den Knoten in die finale Struktur
                                NEWCOMBINEDLIST =XMLLIST[:]
                                # 4. Stricken erst das "</common:ServiceInvocationCollection>" des neuen XML-Basis-Konstruktes am Ende dran
                                NEWCOMBINEDLIST.append(NEWROOTLIST[-1])
                                # Und schieben dann vom Basis-Konstrukt zeilenweise alle Zeilen bis auf die letzte davor
                                for lines in reversed(NEWROOTLIST[0:-1]):
                                    NEWCOMBINEDLIST.insert(0, lines)
                                #NEWXMLTEXT = etree.fromstring(XMLTEXT)
                                #NEWCOMBINED = string.strip(NEWROOTTEXT) + string.strip(XMLTEXT)

                                # 5. Fügen die Einzelzeilen wieder zu einem einzelnen String zusammen
                                NEWCOMBINED = string.join(NEWCOMBINEDLIST)

                                # 6. Um es als neues Testobjekt zusammenzustellen.
                                FINALROOT = etree.fromstring(NEWCOMBINED)

                                # Das Error-Log wird gelöscht, damit wir aus den alten Iterationen keine Fehler mitbekommen. (Vermutlich Overhead)
                                etree.clear_error_log()
                                # Die neue Prüfung folgt. Es wird nur der neue XML-Kopf mit dem einzelnen Knoten geprüft.
                                if XMLSCHEMA.validate(FINALROOT) != True:
                                    # Wenn wir einen Knoten mit Validierungsfehlern finden, schauen wir uns jede Logfile-Zeile an...
                                    for ERROR_MSG in XMLSCHEMA.error_log:
                                        print
                                        # ...dürfen noch einen "UTF-8"-Airlock" machen... (Python2-Problem)
                                        DECODED_ERROR_MSG = ERROR_MSG.message.encode("utf-8").decode("utf-8")
                                        # ... und werfen je Fehler eine sinnlose, weil nichtssagende Zeile des Fehlers weg.
                                        if string.find(DECODED_ERROR_MSG, "is not a valid value of the atomic type") >= 0 and len(XMLSCHEMA.error_log) > 1:
                                            pass

                                        # Wenn wir einen validen Fehler haben, loggen wir dies.

                                        else:
                                            STATISTICS[DATEITYP]["Data_Errors"] = STATISTICS[DATEITYP]["Data_Errors"] + 1
                                            GLOBAL_LOGFILE.writeLog("OUT", "Errors found: " + ERROR_MSG.message.encode("utf-8").decode("utf-8"))
                                            #print "Errors found: " + ERROR_MSG.message.encode("utf-8").decode("utf-8")
                                            LOGFILE.writeLog( "WARN", DECODED_ERROR_MSG)


                                    # Sind alle Fehlerzeilen für den Knoten "durch", geben wir ihn im Logfile aus.
                                    LOGFILE.writeLog( "WARN", "Causing XML-Excerpt:")

                                    LOGFILE.writeLog( "WARN", str("===========================================================================\n" + etree.tostring(ATTRIBUTES).strip()))
                                    LOGFILE.writeLog( "WARN", "===========================================================================")


                        # (Nachdem wir über alle Knoten des Files iteriert haben:)
                        # Da Ordnung das halbe Leben ist, wird protokolliert, wie viele Dateien wir verarbeitet haben.
                        STATISTICS[DATEITYP]["Files_Processed"] = STATISTICS[DATEITYP]["Files_Processed"] + 1
                    except:
                        STATISTICS[DATEITYP]["Data_Errors"] = STATISTICS[DATEITYP]["Data_Errors"] + 1
                        GLOBAL_LOGFILE.writeLog("OUT", "Error! Issues while XSD-Checking. Trying to continue with other objects...")
                        LOGFILE.writeLog( "CRIT", "Issues while XSD-Checking. Trying to continue with other objects...")
                # Wenn XPATH nicht geprüft werden soll, tu halt nix...
            # Dies schließt das Logging für dieses Objekt ab.

        ###################################
        # XPATH-Prüfungslogik
        ###################################

        # Prüfen, ob der Objekttyp validiert werden soll
        if (
            ( CONFIG_DICT["CHECKLIST"].has_key("ALL_OBJECTS")
            and (
                    str(CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"]).upper() == "ALL"
                or (
                    str(CONFIG_DICT["CHECKLIST"]["ALL_OBJECTS"]).upper() == "XPATH"
                    )
                )
            )
        or
            ( CONFIG_DICT["CHECKLIST"].has_key(DATEITYP)
            and (
                    str(CONFIG_DICT["CHECKLIST"][DATEITYP]).upper() == "ALL"
                or (
                    str(CONFIG_DICT["CHECKLIST"][DATEITYP]).upper() == "XPATH"
                    )
                )
            )
        ):
            GLOBAL_LOGFILE.writeLog("OUT", "\nValidating / comparing with database...")
            # Erstellen der generellen Logfiles
            LOGFILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(STATISTICS[DATEITYP]["Mixed_Dateityp"]) + "_XPATH" + "." + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_ENDING"]
            GLOBAL_LOGFILE.writeLog("OUT", "Working/writing to logfile: " + str( LOGFILE_NAME ))

            with Logger(LOGFILE_NAME) as LOGFILE:
                XPATH_SQL_FILE_NAME="NONE"
                XPATH_XPATH_FILE_NAME="NONE"

                # Wir iterieren wieder über alle Dateien des Objekttypes...
                for XML_FILES in REFINED_DIRLIST[DATEITYP]:
                    # Räumen ein wenig von der letzten Iteration auf
                    XPATH_BASE_OPERATION="NONE"
                    XPATH_ADDITIONAL_PARAM="NONE"
                    LOGFILE.writeLog( "INFO", str( "Validating: " + str(XML_FILES)) )
                    GLOBAL_LOGFILE.writeLog("OUT", "Validating (XPATH): " + str(XML_FILES) )
                    # Vorbereitungen... wir versuchen, das File zu laden und zu initialisieren
                    TREE= etree.parse(XML_FILES)
                    ROOT=TREE.getroot()

                    # Um XPATH/SQL-Checks durchführen zu können, müssen wir die exakten Objekttypen finden
                    # Dazu wird geprüft, ob der Knoten mit dem genannten Wert existiert
                    if len(ROOT.find("invocation"))>0 and "operation" in ROOT.find("invocation").keys():
                        # Falls ja, haben wir unseren ersten Basis-Schlüssel gefunden:
                        XPATH_BASE_OPERATION = ROOT.find("invocation").get("operation")
                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "'operation' did not match!")
                        LOGFILE.writeLog( "CRIT", "Could not find a valid operation!")

                    # Jetzt wirds etwas komplizierter... nicht jeder Objekttyp hat Subtypen...
                    # für valide Objekttypen muss daher geprüft werden, ob auch ein "Unterobjekt" existiert. (Thema createPhysicalPersion -> salesman)
                    if XPATH_BASE_OPERATION != "NONE" and XPATH_TRANSLATE_PARTNERS.has_key(XPATH_BASE_OPERATION) and str(XPATH_TRANSLATE_PARTNERS[XPATH_BASE_OPERATION]) in ROOT.find("invocation").find("parameter").keys():
                        XPATH_ADDITIONAL_PARAM=ROOT.find("invocation").find("parameter").get(XPATH_TRANSLATE_PARTNERS[XPATH_BASE_OPERATION])

                    # Ansonsten ignorieren wir das (im Moment)
                    else:
                        pass

                    # Da unklar ist, ob es den Schlüssel in unserem Wörterbuch schon gibt, prüfen wir das.
                    if not STATISTICS[DATEITYP]["SubTyp"].has_key(XPATH_BASE_OPERATION):
                        # Den Schlüssel gibt es noch nicht, also legen wir ihn an.
                        STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION]= {}

                    # Nachdem es den Basis-Schlüssel für XPATH jetzt gibt, brauchen wir noch ein paar weitere Variablen...
                    if not STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION].has_key(XPATH_ADDITIONAL_PARAM):
                        STATISTICS[DATEITYP]["SubTyp"][str(XPATH_BASE_OPERATION)][str(XPATH_ADDITIONAL_PARAM)] = {}
                        STATISTICS[DATEITYP]["SubTyp"][str(XPATH_BASE_OPERATION)][str(XPATH_ADDITIONAL_PARAM)]["XPATH_VALS"] = 0
                        STATISTICS[DATEITYP]["SubTyp"][str(XPATH_BASE_OPERATION)][str(XPATH_ADDITIONAL_PARAM)]["SQL_VALS"] = 0
                        STATISTICS[DATEITYP]["SubTyp"][str(XPATH_BASE_OPERATION)][str(XPATH_ADDITIONAL_PARAM)]["SQL_CHECKED"] = False

                    # Falls es den Objektsubtyp in der XPath-Kommandoliste gibt (Der XPATH_ADDITIONAL_PARAM entweder "NONE" oder spezifiziert)
                    if XPATH_ADDITIONAL_PARAM in XPATH_COMMANDS[XPATH_BASE_OPERATION]:
                        try:
                            # Prügeln wir mit einem Kommando die XPATH-Resultate (Liste mit Werten) in eine Variable
                            XPATH_XPATH_RESULT = ROOT.xpath(XPATH_COMMANDS[XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["ValidationXPath"])
                            # Zählen hinterher die einzelnen Untermengen an Resultaten und erhöhen "XPATH_VALS" um diesen Wert
                            STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["XPATH_VALS"] = STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["XPATH_VALS"] + len(XPATH_XPATH_RESULT)

                            # Jetzt müssen wir die Ergebnisse noch ausgeben.
                            # Problem: Wir wissen nicht, ob von der vorherigen Datei oder vom vorherigen Objektsubtyp(!) noch ein Logfile offen ist
                            # Also prüfen wir genau das. In erstem Fall für ein Objekt mit Sub-Objekt
                            if XPATH_ADDITIONAL_PARAM != "NONE":
                                # Prüfen, ob der oben schon prophylaktisch als "NONE" vorgegebene Dateiname nicht aktiv ist
                                # oder ob wir aus einer Datei-Iteration vielleicht einen abweichenden Dateinahmen führen
                                if str(XPATH_XPATH_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_XPATH." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                    # Falls ja, erzeuge den Dateinamen neu
                                    XPATH_XPATH_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_XPATH." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                    # Und machen damit eine Datei auf. (Das "w" überschreibt den bisherigen Inhalt.)
                                    FILE_OBJ_XPATH_XPATH = codecs.open(XPATH_XPATH_FILE_NAME, "w", encoding="utf-8")

                            else:
                                # Wir haben keine Sub-Objekte. (Das vereinfacht die Abfrage aber nur geringfügig.)
                                # Prüfen, ob der oben schon prophylaktisch als "NONE" vorgegebene Dateiname nicht aktiv ist
                                # oder ob wir aus einer Datei-Iteration vielleicht einen abweichenden Dateinahmen führen
                                if str(XPATH_XPATH_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_XPATH." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                    # Falls ja, erzeuge den Dateinamen neu
                                    XPATH_XPATH_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_XPATH." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                    # Und überschreibe alte Objekt, falls es denn existierte (Damit wird automatisch die Verbindung zum alten File geschlossen.)
                                    FILE_OBJ_XPATH_XPATH = codecs.open(XPATH_XPATH_FILE_NAME, "w", encoding="utf-8")

                            # Falls wir ein Resultat bekommen, welches mindestens eine Ergebnismenge hat...
                            if len(XPATH_XPATH_RESULT)>0:
                                #... zerlegen wir das Ergebnis in einzelne Zeilen und spielen wieder "UTF8-Airlock"
                                for LINES in XPATH_XPATH_RESULT:
                                    VAR0=LINES
                                    VARA= VAR0.encode("utf-8")
                                    VARB= VARA + os.linesep.encode("utf-8")
                                    VARE = VARB.decode("utf-8")
                                    # ... bis wir das Ergebnis Zeilenweise auf die Platte schreiben.
                                    FILE_OBJ_XPATH_XPATH.write(VARE)
                        except:
                            GLOBAL_LOGFILE.writeLog("OUT", "Can not validate XPath for:" + str( XPATH_BASE_OPERATION ) +  " / " + str(XPATH_ADDITIONAL_PARAM))

                        # XPATH abgeschlossen, jetzt folgt SQL!
                        # Da wir für das SQL aber einige Daten aus einem XML brauchen (Stichwort Sub-Objekttypen)
                        # Darf der SQL-Check nur einmal je Objekttyp / Subobjekttyp-Kombi durchlaufen.
                        # Das prüfen wir mittels STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["SQL_CHECKED"] == False
                        # Ansonsten nur noch die üblichen Checks (Gibt es den verwendeten Sub-Objekttypen + Gibt es für diese Kombi ein SQL-Setup?)
                        if (STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["SQL_CHECKED"] == False) and (XPATH_ADDITIONAL_PARAM in XPATH_COMMANDS[XPATH_BASE_OPERATION]) and (XPATH_COMMANDS[XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM].has_key("ValidationSQL")):
                            # Wie es scheint, laufen "wir" hier zum ersten Mal in dieser Kombi. Wir stellen sicher,
                            #  dass selbst bei einem Fehler der SQL-Teil nicht je File läuft...
                            STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["SQL_CHECKED"] = True

                            try:
                                #if True:
                                # Da nicht immer klar ist, welcher Connection-String benötigt wird, prüfen wir das doch einfach
                                # direkt im SQL. Je nach Variante wird auch gleich die Verbindung aufgezogen.
                                if string.find(string.upper(XPATH_COMMANDS[XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["ValidationSQL"]),"SIMEX_DB_LINK")> -1:
                                    CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_SIMEX"])
                                else:
                                    CONNECTION=cx_Oracle.connect(CONFIG_DICT["ENVIRONMENT"]["ORACLE_CONNECT_STRING_DB"])
                                # Ohne Cursor geht nix! ;) (Anschließende Skriptausführung...)
                                SQL=CONNECTION.cursor()
                                SQL.execute(XPATH_COMMANDS[XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["ValidationSQL"])
                                # Wir sind mutig und holen gleich alle Ergebnisse.
                                XPATH_SQL_RESULT=SQL.fetchall()
                                # Ähnlich wie beim XPATH. Wir zählen die einzelnen Ergebnismengen und pappen sie in das Ergebnis.
                                # Anders als bei XPATH gibts aber nur eins. Also wird der bestehende Wert überschrieben
                                STATISTICS[DATEITYP]["SubTyp"][XPATH_BASE_OPERATION][XPATH_ADDITIONAL_PARAM]["SQL_VALS"] = len(XPATH_SQL_RESULT)
                                # Aufräumen...
                                CONNECTION.close()

                                # Und SQL-Ergebnisse auswerten.
                                # Gleiche Prozedur wie oben... bei Existenz eines Sub-Objekttypes gibts etwas mehr Arbeit...
                                if XPATH_ADDITIONAL_PARAM != "NONE":
                                    # (Bestehender SQL_CSV-Dateiname aus vorherigen Iterationen weicht vom zusammengebauten Namen ab?)
                                    if str(XPATH_SQL_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                        # Wenn ja, war hier wohl noch keiner. Also schreiben wir...
                                        XPATH_SQL_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_" + str(XPATH_ADDITIONAL_PARAM) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                        FILE_OBJ_XPATH_SQL = codecs.open(XPATH_SQL_FILE_NAME, "w", encoding="utf-8")

                                else:
                                    # (Bestehender SQL_CSV-Dateiname aus vorherigen Iterationen weicht vom zusammengebauten Namen ab?)
                                    if str(XPATH_SQL_FILE_NAME) != str(CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]):
                                        # Wenn ja, war hier wohl noch keiner. Also schreiben wir...
                                        XPATH_SQL_FILE_NAME = CONFIG_DICT["ENVIRONMENT"]["PATH_TO_LOGFILES"] + CONFIG_DICT["ENVIRONMENT"]["LOGFILE_PREFIX"] + str(XPATH_BASE_OPERATION) + "_XPATH_SQL." + CONFIG_DICT["ENVIRONMENT"]["CSV_ENDING"]
                                        FILE_OBJ_XPATH_SQL = codecs.open(XPATH_SQL_FILE_NAME, "w", encoding="utf-8")

                                # Die Ergebnisse Datensatz für Datensatz jeweils das erste Ergebnis
                                for LINES in XPATH_SQL_RESULT:
                                    VAR0=str(LINES[0])
                                    # nach dem üblichen Coding-Gerümpel
                                    VARA= VAR0.decode(CONFIG_DICT["ENVIRONMENT"]["ENCODING_DB"])
                                    VARB= VARA.encode("utf-8") + os.linesep
                                    VARE = VARB.decode("utf-8")
                                    # in die bereitgestellte Datei.
                                    FILE_OBJ_XPATH_SQL.write(VARE)

                                # Aufräumen! \o/
                                FILE_OBJ_XPATH_SQL.close()

                            # Fehlerhandling... insbesondere bei SQL geht das schnell, wenn die DB mal "weg" ist.
                            # Wobei wir da nur eine laidare Fehlermeldung auswerfen.
                            # (Man sieht im Ergbnis sehr gut, ob da vielleicht irgendwo was schiefgelaufen ist...
                            except:
                                GLOBAL_LOGFILE.writeLog("OUT", "Could not SQL_Query for: " + str(XPATH_BASE_OPERATION) + " / " + str( XPATH_ADDITIONAL_PARAM ))

                        #else:
                        #    print "Can not check XPATH. Some variables seem to be missing."

                    else:
                        GLOBAL_LOGFILE.writeLog("OUT", "For this Object type / subtype there is currently no valid data for processing.")

                # Wir haben den XPATH-Run abgeschlossen und durch alle Dateien iteriert. Wir können das Logfile schließen...
                FILE_OBJ_XPATH_XPATH.close()

            # Wenn XPATH nicht geprüft werden soll, tu halt nix...

        # Dies schließt das Logging für dieses Objekt ab.



    # Auf in die Statistiken! Ein wenig schachteln und etwas fürs Auge...
    GLOBAL_LOGFILE.writeLog("OUT", "\n")
    GLOBAL_LOGFILE.writeLog("OUT", "========================================================================================")
    GLOBAL_LOGFILE.writeLog("OUT", "Statistics:")
    GLOBAL_LOGFILE.writeLog("OUT", "========================================================================================")
    if STATISTICS.has_key("DB_INFO"):
        DB_INFO_STATS=STATISTICS.pop("DB_INFO")
        if DB_INFO_STATS.has_key("IMPORT_DATE"):
            GLOBAL_LOGFILE.writeLog("OUT", "Import date: "+str(DB_INFO_STATS["IMPORT_DATE"]))
        if DB_INFO_STATS.has_key("DUMPNAME"):
            GLOBAL_LOGFILE.writeLog("OUT", "Dump name: "+str(DB_INFO_STATS["DUMPNAME"]))
        if DB_INFO_STATS.has_key("DUMPNAME") or DB_INFO_STATS.has_key("IMPORT_DATE"):
            GLOBAL_LOGFILE.writeLog("OUT", "========================================================================================")

    for KEY in sorted(STATISTICS):
        if STATISTICS[KEY]["Data_Errors"] == 0:
            if STATISTICS[KEY]["Files_Processed"] == 0:
                RESULT_XSD = "No files processed."
            else:
                RESULT_XSD = "OK"
        else:
            RESULT_XSD = "Need verification!"
        GLOBAL_LOGFILE.writeLog("OUT", "XSD: " + str(STATISTICS[KEY]["Mixed_Dateityp"]))
        GLOBAL_LOGFILE.writeLog("OUT", "Files processed: " + str(STATISTICS[KEY]["Files_Processed"]) + " Errors found: " + str(STATISTICS[KEY]["Data_Errors"]) + " Result: " + str( RESULT_XSD))

        if len (STATISTICS[KEY]["SubTyp"])==0:
            GLOBAL_LOGFILE.writeLog("OUT", "XPATH: " + str(STATISTICS[KEY]["Mixed_Dateityp"]) + str( " Not triggered." ))
        else:
            for SUBKEY in sorted(STATISTICS[KEY]["SubTyp"]):
                GLOBAL_LOGFILE.writeLog("OUT", "XPATH: " + str(STATISTICS[KEY]["Mixed_Dateityp"]) + " (" + str(SUBKEY) + ")")
                for SUBSUBKEY in sorted(STATISTICS[KEY]["SubTyp"][SUBKEY]):
                    if len(STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY])>2:
                        if STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY]["SQL_VALS"] == STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY]["XPATH_VALS"]:
                            if STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY]["SQL_VALS"] > 0:
                                RESULT_XPATH = "OK"
                            else:
                                RESULT_XPATH = "No files processed."
                        else:
                            RESULT_XPATH = "Need verification!"
                        GLOBAL_LOGFILE.writeLog("OUT", "Subclass: " + str(SUBSUBKEY) + " SQL_Query: " + str(STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY]["SQL_VALS"]) + " Xpath_Query: " + str(STATISTICS[KEY]["SubTyp"][SUBKEY][SUBSUBKEY]["XPATH_VALS"]) + " Result: " + str( RESULT_XPATH))
                    else:
                         GLOBAL_LOGFILE.writeLog("OUT", "No valid results in XPATH-Check.")
        GLOBAL_LOGFILE.writeLog("OUT", "========================================================================================")
