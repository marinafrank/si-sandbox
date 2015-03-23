-- load_SiMEX_basedata.sql

-- FraBe 10.10.2012 MKS-117496: creation
-- FraBe 10.10.2012 MKS-117496: add TMESSAGE
-- FraBe 17.10.2012 MKS-117506: correct LOG_MSG_TEXT of TMESSAGE - LOG_ID = '0007'
-- FraBe 07.12.2012 MKS-120849:1 add some new values (-> EXP_PRIVATECUSTOMER / EXP_COMMERCIALCUSTOMER / TENANTID
-- MaZi  21.03.2013 MKS-121684:1 add two new values -> USERID / SOURCESYSTEM
-- FraBe 24.03.2013 MKS-122279:1 add export OrganisationalPerson - Workshop
-- FraBe 27.03.2013 MKS-123819:1 add export OrganisationalPerson - Supplier
-- FraBe 29.10.2013 MKS-121602:1 add some COST - values
-- FraBe 19.11.2013 MKS-123544:1 add Revenue
-- FraBe 04.12.2013 MKS-130013:1 TSETTING - SOURCESYSTEM geändert auf 'migration'
-- Mazi  05.12.2013 MKS-129347:2 add TSETTING - CAUSATION
-- Mazi  05.12.2013 MKS-129547:1 add TTASK - EXP_DEALER
-- FraBe 16.01.2014 MKS-130540:1 add new col TTASK.TAS_ORDER
-- FraBe 17.01.2014 MKS-130516:1 fix syntax error bei gestrigem add new col TTASK.TAS_ORDER
-- FraBe 12.02.2014 MKS-129521:1 einige TSETTING wave1 anpassen
-- MaZi  24.02.2014 MKS-130181:2 remove TSETTING as it is from now on handled by xml/SiMEx-PowerTool
-- MaZi  24.02.2014 MKS-130181:2 add TSETTING/DB_LINK again
-- FraBe 26.02.2014 MKS-131343:2 add insert TSETTING - COUNTRY_CODE
-- FraBe 03.05.2014 MKS-131298:1 change odometer version to Wave3.2_1
-- FraBe 06.05.2014 MKS-131815:1 a) add Cost CollectiveWorkshopInvoices Wave3.2_1 / b) sortieren TTASK insert nach TAS_ORDER#
-- FraBe 02.06.2014 MKS-131308:1 add AssignCostToCost Wave3.2_1
-- FraBe 02.06.2014 MKS-132656:3 change AssignCostToCost TAS_MAX_NODES from 1 to 1000
-- FraBe 04.06.2014 MKS-132838:1 change 'List of FIN CR#10' to 'List of FIN Wave3.2'
-- FraBe 24.06.2014 MKS-132103:1 change 'PhysicalPerson - PrivateCustomer Wave3.2_1' to '... waveFinal'
-- FraBe 25.06.2014 MKS-132116:1 change 'PhysicalPerson - Salesman Wave3.2_1' to '... waveFinal'
-- FraBe 30.06.2014 MKS-132064:1 change 'OrganisationalPerson - Supplier Wave3.2_1' to '... waveFinal'
-- FraBe 01.07.2014 MKS-132047:1 change 'OrganisationalPerson - Dealer Wave3.2_1' to '... waveFinal'
-- FraBe 01.07.2014 MKS-132090:1 change 'PhysicalPerson - ContactPerson Wave3.2_1' to '... waveFinal'
-- FraBe 18.07.2014 MKS-132077:1 change 'OrganisationalPerson - Workshop Wave3.2_1' to '... waveFinal'
-- FraBe 18.07.2014 MKS-132034:1 change 'OrganisationalPerson - CommCustomer Wave3.2_1' to '... waveFinal'
-- FraBe 17.08.2014 MKS-132151:1 change 'ServiceContract Wave3.2_1' to '... waveFinal'
-- MZu   05.09.2014 MKS-134781:1 Changed "Cost WorkshopInvoices Wave3.2_1" TAS_MAX_NODES from 1000 to 500.
-- FraBe 25.09.2014 MKS-134359:1 change 'OrganisationalPerson - Dealer waveFinal' to '... WavePreInt4'
-- MaZi  29.09.2014 MKS-134348:1 change 'OrganisationalPerson - CommCustomer waveFinal' to '... WavePreInt4'
-- FraBe 30.09.2014 MKS-134374:1 change 'OrganisationalPerson - Supplier waveFinal' to '... WavePreInt4'
-- FraBe 30.09.2014 MKS-134374:1 change 'OrganisationalPerson - Workshop waveFinal' to '... WavePreInt4'
-- FraBe 30.09.2014 MKS-134374:1 change 'PhysicalPerson - ContactPerson waveFinal' to '... WavePreInt4'
-- FraBe 03.10.2014 MKS-134424:1 change 'PhysicalPerson - Salesman waveFinal' to '... WavePreInt4'
-- MaZi  07.10.2014 MKS-134416:3 change 'PhysicalPerson - PrivateCustomer waveFinal' to '... WavePreInt4'
-- MaZi  07.10.2014 MKS-134444:1 change 'ServiceContract waveFinal' to '... WavePreInt4'
-- MaZi  16.10.2014 MKS-134509:1 change 'AssignCostToCost Wave3.2_1' to '... WavePreInt4'
-- MaZi  16.10.2014 MKS-134486:1 change 'Revenue Wave3.2_1' to '... WavePreInt4'
-- FraBe 29.10.2014 MKS-134497:1 change 'Odometer Wave3.2_1' to '... WavePreInt4'
-- FraBe 31.10.2014 MKS-134523:1 add 'ModificationProtocolEntry - WavePreInt4'
-- FraBe 31.10.2014 MKS-134523:1 change ModificationProtocolEntry TAS_PROCEDURE from EXP_MODPROTO to EXP_ModProto
-- FraBe 05.11.2014 MKS-134458:1 change 'Cost WorkshopInvoices Wave3.2_1' to '... WavePreInt4'
-- FraBe 05.11.2014 MKS-134471:1 change 'Cost CollectiveWorkshopInvoices Wave3.2_1' to '... WavePreInt4'
-- FraBe 20.11.2014 MKS-135623:1 add CustomerContract WavePreInt4
-- FraBe 22.11.2014 MKS-135636:1 add VehicleContract WavePreInt4
-- FraBe 22.11.2014 MKS-135636:2 change TAS_MAX_NODES von CustomerContract und VehicleContract
-- MaZi  08.01.2015 MKS-135606:2 add 'VEGA MappingList Int7'
-- MaZi  23.01.2015 MKS-136002:1 remove spaces in 'MigrationScopeList Customer' and 'Inventory List'
-- MaZi  23.01.2015 MKS-136330:1 change 'Revenue Int7'
-- MaZi  26.01.2015 MKS-136002:1 undo space removement in 'MigrationScopeList Customer' and 'Inventory List' (code it instead)
-- MaZi  26.01.2015 MKS-136189:1 change several exports to 'Int7'
-- MaZi  02.02.2015 MKS-136461:1 change several exports to 'Int7'

/*
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values( '072A382C15A9489EAEFCBC905C0E17AF'
       , 0
       , 'Customer'
       , 'EXP_CUST'
       , 500
       , 990
       );
       
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '15AA94C945164BB09385D966470AEBF6'
       , 0
       , 'Contracts'
       , 'EXP_CONTRACTS'
       , 1000
       , 991
       );
*/

       
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'D5F1CDF1A7BC42E58069F1F37FE9BE7D'
       , 0
       , 'MigrationScopeList Customer'
       , 'EXP_MIG_SCOPE_CUSTOMER'
       , 999999
       , 1
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'E4162A3A8EF24892AD2B9D9E4A9B7DF9'
       , 0
       , 'List of FIN Wave3.2'
       , 'EXP_FIN'
       , 999999
       , 2
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'C86BB1D078AD416DBCD3A24DB351F2C1'
       , 0
       , 'Inventory List'
       , 'EXP_InventoryList'
       , 999999
       , 3
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '5E850BBA2A0A43A38CF46C9FCDDFD87D'
       , 0
       , 'PhysicalPerson - PrivateCustomer Int7'
       , 'EXP_PRIVATECUSTOMER'
       , 1000
       , 10
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '9095195C51784ED88371D12AFC56C393'
       , 0
       , 'PhysicalPerson - ContactPerson WavePreInt4'
       , 'EXP_CONTACTPERSON'
       , 1000
       , 11
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'A35056C588664463AF03A35D106994B6'
       , 0
       , 'PhysicalPerson - Salesman WavePreInt4'
       , 'EXP_SALESMAN'
       , 1000
       , 12
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '842AB68F51D047F88F29A73F45D566A6'
       , 0
       , 'OrganisationalPerson - CommCustomer Int7'
       , 'EXP_COMMERCIALCUSTOMER'
       , 1000
       , 21
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'CC820E6AB7BF4DFFA690B0B9BA0BBDD5'
       , 0
       , 'OrganisationalPerson - Workshop WavePreInt4'
       , 'EXP_WORKSHOP'
       , 1000
       , 22
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '937E0D9E513C47269F62BAF251F07F61'
       , 0
       , 'OrganisationalPerson - Supplier WavePreInt4'
       , 'EXP_SUPPLIER'
       , 1000
       , 23
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '699BBBFF0FB54C268EA01268968687D3'
       , 0
       , 'OrganisationalPerson - Dealer Int7'
       , 'EXP_DEALER'
       , 1000
       , 24
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '2AF05A6D6CA44EAFA8EA24EA04DE8251'
       , 0
       , 'Odometer WavePreInt4'
       , 'EXP_ODOMETER'
       , 1000
       , 30
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '55AF3A64CEC7492D83237F73A97EBCD0'
       , 0
       , 'ServiceContract WavePreInt4'
       , 'EXP_SERVICE_CONTRACT'
       , 200
       , 40
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '7E6DB5935C3C48EDB51DAB932CAB2849'
       , 0
       , 'CustomerContract WavePreInt4'
       , 'EXP_CUSTOMER_CONTRACT'
       , 200
       , 41
       );
       
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '4EDEFA0D7768490BBDDCB0494A236C54'
       , 0
       , 'VehicleContract WavePreInt4'
       , 'EXP_VEHICLE_CONTRACT'
       , 250
       , 42
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '939231078FE4405B8920FFAA39951C97'
       , 0
       , 'Revenue Int7'
       , 'EXP_Revenue'
       , 1000
       , 50
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'A3EFF471D6F64BE286385A761488308F'
       , 0
       , 'Cost WorkshopInvoices Int7'
       , 'EXP_WorkshopInvoice'
       , 500
       , 60
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '9574C94002994951952A382D6B18D458'
       , 0
       , 'Cost WorkshopInvoices Full Int7'
       , 'EXP_WorkshopInvoice_full'
       , 500
       , 61
       );       
       
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( '05A517F6AD094D1FAC89EAE5E8DB5AA2'
       , 0
       , 'Cost CollectiveWorkshopInvoices Int7'
       , 'EXP_CollectiveWorkshopInvoice'
       , 1
       , 70
       );
       
insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'D570661C072D49F3AA4B6050FCAFA951'
       , 0
       , 'AssignCostToCost WavePreInt4'
       , 'EXP_AssignCostToCost'
       , 1000
       , 80
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'FA6B31AD59FD4B4EAC876236D3EE4CF1'
       , 0
       , 'ModificationProtocolEntry WavePreInt4'
       , 'EXP_ModProto'
       , 1000
       , 90
       );

insert into TTASK 
       ( TAS_GUID
       , TAS_ACTIVE
       , TAS_CAPTION
       , TAS_PROCEDURE
       , TAS_MAX_NODES
       , TAS_ORDER
       ) 
values ( 'AC4474CB1DE34C08B8D006A84F109D34'
       , 0
       , 'VEGA MappingList Int7'
       , 'EXP_VEGAMappingList'
       , 999999
       , 901
       );

insert into TSETTING ( SET_SECTION, SET_ENTRY, SET_VALUE ) values ( 'SETTING', 'DEBUG',        'FALSE' );
insert into TSETTING ( SET_SECTION, SET_ENTRY, SET_VALUE ) values ( 'SETTING', 'DB_LINK',      'SIMEX_DB_LINK' );
insert into TSETTING ( SET_SECTION, SET_ENTRY, SET_VALUE ) values ( 'SETTING', 'COUNTRY_CODE', ( select VALUE from TGLOBAL_SETTINGS@simex_db_link
                                                                                                  where SECTION ='SIVECO' and upper ( ENTRY ) = 'COUNTRY-CD' ));

insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0000','DEBUG INFO',                                                        'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0001','Job started',                                                       'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0002','Job ended',                                                         'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0003','Export started',                                                    'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0004','Export finished successful',                                        'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0005','Export failed',                                                     'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0006','Job successfully cancelled',                                        'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0007','Job cannot be cancelled as already running / finished / cancelled', 'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0008','Something went wrong within cancelling job',                        'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0009','No default substitution value existing',                            'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0010','Something went wrong within value substitution',                    'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0011','Something went wrong within default value substitution',            'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0012','Something went wrong within creation exportfile',                   'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0013','Gathering data finished',                                           'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0014','xml file creation finished',                                        'I');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0015','Too many default substitution values existing',                     'E');
insert into TMESSAGE  ( LOG_ID, LOG_MSG_TEXT, LOG_CLASS ) values ( '0016','Too many substitution values existing',                             'E');
