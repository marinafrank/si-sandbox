(ReadMe v.0.8)

1. Funktionsumfang und Arbeitsweise
===================================
Dieses Skript liest die in der zugehörigen config.ini unter [Checklist] abgelegten Objekte aus und prüft, welche Aufgaben umzusetzen sind.
Je nach Konfiguration beinhaltet dies (und/oder):
- den Start einer Extraktion
- einen XSD-Check (Validierung gegen ein generisches XSD-Schema des Konzerns)
- einen XPATH-Check (Auswertung der XMLs gegen die Datenbank-Ergebnisse.)

1.1. XSD
====================
In der Grundkonfiguration erwartet das Programm eine "all.xsd" im Ordner B:\iCON_Migration\iCON-Schema-[...]\
Gegen diese werden alle in der Konfiguration angelegten Objekte geprüft. Wird das Resultat mit "0 Files" abgeschlossen, waren zwar zu testende Dateien vorhanden, jedoch keine Freigabe der Tests in der Konfigurationsdatei.

1.2. XPATH
====================
In der Grundkonfiguration erwartet das Programm seine Zusatzkonfiguration unter C:\simex\simex\iCon-Validation.xml
Dieses XML beinhaltet die auszuführenden XPATH- und SQL-Befehle, um die in die XMLs ausgespulten Ergebnisse gegen die Datenbanken zu prüfen.
Die SQL-Checks dürfen je nach Anfrage entweder auf SiMEx oder direkt auf die DB zugreifen. Ein Mischbetrieb innerhalb einer Anfrage ist nicht möglich. 

1.3 Extraktion
====================
Abgesehen von der Konfigurationsdatei wird aktuell keine weitere Unterstützung benötigt. Die zu triggernden Tasks sind im Programm hinterlegt. Der relevante Konfigurationsblock lautet "[Extraction]".

1.4 Logfiles
====================
Der Einsatz des Programmes ist im Moment optimiert für die SiMEx Server-Umgebung. Entsprechend sind folgende Vor-Konfigurationen vorgesehen:
1.) Ausgespulte Objekt-XMLs werden in C:\simex\simex\ erwartet.
2.) Logfiles für tiefere Auswertungen (und CSVs bei den XPATH/SQL-Checks) werden unter C:\simex\simex\LOGS\ abgelegt.
Diese Ordner müssen zum Programmstart existieren!

1.5 Datenbank (Oracle)
====================
Als DB wird Oracle verwendet. (Mehr dazu unter "2. Vorbedingungen")
Die Connection-Strings (ORACLE_CONNECT_STRING_*) sind entsprechend der Datenbanken in der Konfigurationsdatei anzupassen.
Das Encoding der DB ist aus der Datenbank auszulesen und in der config.ini unter "ENCODING_DB" abzulegen. Für MBBEL ist dies beispielsweise "latin-1".


2. Vorbedingungen
===================================
2.1. Ausführung als Binary/Exe
====================
1.) Ein Oracle-Client muss installiert sein. Der Programm-Modus des Oracle-Clients (32 oder 64 Bit) muss bekannt sein. Der Client muss Version 11.2.x.y. sein. Der Oracle Client 12.x wird im Moment NICHT unterstützt!
2.) Eine valide TNSNames.ora muss im System vorhanden, befüllt und ansprechbar sein (Test mittels tnsping)

2.2. Ausführung als .py-File (nicht empfohlen)
====================
Zur Ausführung von SiMExVT müssen folgende Vorbedingungen gegeben sein:
1.) Python Version 2.7.5 (Paket des Daimler-Konzerns oder von Python direkt herunterzuladen)
2.) Modul "lxml". Verifiziert ist im Moment 3.3.5. -> https://pypi.python.org/pypi/lxml/3.3.5 (Für entsprechende Windows-Version und Python-Version herunterladen)
3.) lokal installierter Oracle-Client (passend zur DB-Version)
4.) Eine valide TNSNames.ora muss vorhanden, befüllt und ansprechbar sein (Test mittels tnsping)
5.) Modul cx_Oracle für die richtige Python-Version (Versionsnummer und x32 oder x64) sowie Oracle-Client installieren. Verifiziert ist im Moment 5.1.3.


3. Konfiguration
===================================
Die Konfiguration des Skriptes befindet in der Grundkonfiguration in der Datei "config.ini". Eine Kurzbeschreibung mit Beispielen ist inklusive. Ist keine Konfigurationsdatei vorhanden, werden Defaults (Die Grundkonfiguration) angezogen. 
1) Binary:
Die config.ini wird im ausführenden(!) Verzeichnis, nicht im Executeable-Verzeichnis, erwartet. (Achtung! Eine Ausführung ala C:\> B:\[...]\SiMExVT_32.exe genügt diesen Anforderungen NICHT!)
2) Python:
Arbeitet entsprechend dem Skript. Um den Pfad der Konfigurationsdatei zu ändern, kann dieser im Hauptprogramm angepasst werden. (Kopfbereich)
ACHTUNG: Im Python-Modus innerhalb von MKS weicht die config.ini von der standardmäßig ausgelieferten Datei ab! Sie ist DRINGEND vorher zu konfigurieren oder umzubenennen!


4. Ausführung
===================================
4.1 Binary:
====================
Die Ablage erfolgt unter Sirius Dumpshare \iCON_Migration\SiMEx-VT
1.) Auf 32Bit-Umgebungen oder 32Bit Oracle-Clients startet man die Datei SiMExVT_32.exe. Empfehlung: Start über die Kommandozeile für eine bessere Statusübersicht.
2.) Bei 64Bit-Oracle-Clients startet man die Datei SiMExVT_64.exe. Die Empfehlung von 1) gilt auch hier.

4.2 Python (NICHT empfohlen!)
====================
Die Ablage erfolgt im MKS. Aufgerufen wird das Programm beispielsweise mittels:
1.) "python SiMExVT.py"

5. Begriffsdefinition
===================================
5.1 Grundkonfiguration
====================
Im Basisprogramm hinterlegte Konfiguration, die so auch in der Konfigurationsdatei mitgeliefert wird.
Wird auf die Grundkonfiguration zurückgegriffen, werden folgende Werte voreingestellt:
1) Der globale Output erfolgt nur auf dem Bildschirm. Kein globales Logging.
2) Alle Objektlogfiles werden im aktuellen Verzeichnis abgelegt
3) Alle XMLs werden im aktuellen Ordner erwartet
4) Das "XSD-Referenz-XSD" liegt im aktuellen Ordner und heißt "all.xsd"
5) Als Datenbank wird die SIMEX bzw. REF-Umgebung der DaimlerTSS GmbH angesprochen
6) Es wird nicht extrahiert
7) Für die Vergleiche XSD und XPATH werden alle Objekte herangezogen.
8) Verarbeitet werden alle Dateien im Format "##_[OBJEKTNAME]_*.xml"


5.2 Konfiguration / Konfigurationsdatei
====================
Die vom Programm zum Programmstart zu ladende Konfigurationsdatei. In der Grundkonfiguration ist das die "config.ini" des Startverzeichnises. Wird keine externe Konfiguration gefunden, wird eine Minimal-Config gewählt. (Siehe 5.1)

Appendix:
A) Build
On S415mt217 there is a Python 2.7.8 manuall installation including all modules mentioned above, additionally PyInstaller prepared. To build SiMEx-VT, do the following:
A.1) Copy C:\mks\icon\5000_Construction\5100_Code_Base\SiMEx-VT\SiMExVT.py to \\S415MT217\C$\Python27\Development\
A.2) Open remote desktop connection to said machine and open a CMD window
A.3) Execute the following:
	-> C:
	-> cd C:\Python27
	-> PyInstaller\python pyinstaller.py --onefile Development\SiMExVT.py
	-> move dist\SiMExVT.exe dist\SiMExVT_64.exe
A.4) Copy \\S415MT217\C$\Python27\dist\SiMExVT_64.exe to your zipping area
A.5) Repeat with SiMExVT_32.exe at an 32Bit-Environment. (Not neccessary for extraction purposes, but for competeness). If you don't have a _32-Build, Please DONT DELIVER THE OLD ONE!
	The commands for my machine look like: C:\PyInstaller>python pyinstaller.py --onefile C:\mks\icon\5000_Construction\5100_Code_Base\SiMEx-VT\SiMExVT.py
A.6) pack together: config.ini, current (!) iCon-Validation.xml, ReadMe.txt, SiMExVT_32.exe, SiMExVT_64.exe in a single SiMEx-VT.zip-File.
A.7) Deploy the file at: C:\mks\icon\7000_Delivery\7100_Shipments\Tools\
A.8) Check in the file.
A.9) Optional but highly recommended: Put the content of the ZIP file minus the config.ini - unless something important did change in there - to:
	-> \\S415vm779\c$\simex\simex\SIMEx-VT\
	-> \\S415vm779\c$\simex\simex1\SIMEx-VT\
	-> \\S415vm779\c$\simex\simex2\SIMEx-VT\
	-> \\S415vm779\c$\simex\simex3\SIMEx-VT\
	-> \\S415vm779\c$\simex\simex4\SIMEx-VT\