/*==============================================================*/
/* FraBe 16.01.2014 MKS-130540:1 add new TTASK column TAS_ORDER */
/*==============================================================*/

alter table SIMEX.TTASK add TAS_ORDER integer;

update SIMEX.TTASK set TAS_ORDER =   1 where TAS_GUID = 'D5F1CDF1A7BC42E58069F1F37FE9BE7D';   --  MigrationScopeList Customer
update SIMEX.TTASK set TAS_ORDER =   2 where TAS_GUID = 'E4162A3A8EF24892AD2B9D9E4A9B7DF9';   --  List of FIN
update SIMEX.TTASK set TAS_ORDER =   3 where TAS_GUID = 'C86BB1D078AD416DBCD3A24DB351F2C1';   --  Inventory List
update SIMEX.TTASK set TAS_ORDER =  10 where TAS_GUID = '5E850BBA2A0A43A38CF46C9FCDDFD87D';   --  PhysicalPerson - PrivateCustomer
update SIMEX.TTASK set TAS_ORDER =  11 where TAS_GUID = '9095195C51784ED88371D12AFC56C393';   --  PhysicalPerson - ContactPerson
update SIMEX.TTASK set TAS_ORDER =  12 where TAS_GUID = 'A35056C588664463AF03A35D106994B6';   --  PhysicalPerson - Salesman
update SIMEX.TTASK set TAS_ORDER =  21 where TAS_GUID = '842AB68F51D047F88F29A73F45D566A6';   --  OrganisationalPerson - CommercialCustomer
update SIMEX.TTASK set TAS_ORDER =  22 where TAS_GUID = 'CC820E6AB7BF4DFFA690B0B9BA0BBDD5';   --  OrganisationalPerson - Workshop
update SIMEX.TTASK set TAS_ORDER =  23 where TAS_GUID = '937E0D9E513C47269F62BAF251F07F61';   --  OrganisationalPerson - Supplier
update SIMEX.TTASK set TAS_ORDER =  24 where TAS_GUID = '699BBBFF0FB54C268EA01268968687D3';   --  OrganisationalPerson - Dealer
update SIMEX.TTASK set TAS_ORDER =  30 where TAS_GUID = '2AF05A6D6CA44EAFA8EA24EA04DE8251';   --  Odometer
update SIMEX.TTASK set TAS_ORDER =  40 where TAS_GUID = '55AF3A64CEC7492D83237F73A97EBCD0';   --  ServiceContract
update SIMEX.TTASK set TAS_ORDER =  50 where TAS_GUID = '939231078FE4405B8920FFAA39951C97';   --  Revenue
update SIMEX.TTASK set TAS_ORDER =  60 where TAS_GUID = 'A3EFF471D6F64BE286385A761488308F';   --  Cost WorkshopInvoices
update SIMEX.TTASK set TAS_ORDER = 990 where TAS_GUID = '072A382C15A9489EAEFCBC905C0E17AF';   --  Customer
update SIMEX.TTASK set TAS_ORDER = 991 where TAS_GUID = '15AA94C945164BB09385D966470AEBF6';   --  Contracts


alter table SIMEX.TTASK modify TAS_ORDER NOT NULL;

alter table SIMEX.TTASK add constraint XAKTTASK_TAS_ORDER unique ( TAS_ORDER ) using index tablespace  SIMEX;