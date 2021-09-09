@isTest
public without sharing class DeviationTypeUtilityTest {
    @testsetup
    static void createTestData() {
        Deviation_Approval_Data__c data1 = new Deviation_Approval_Data__c();
        data1.name = 'Test Data1 ';
        data1.Salesforce_Field__c = 'NetDeviationEscalationLevel__c';
        data1.Field_Value__c = 'Threshold 2';
        data1.Active__c = true;
        data1.Tier__c = 'Tier 1';
        data1.Matching_Key__c = 'MANA#Comparison Price#BDGS#Tier 1';
        data1.Business_Area__c = 'BDGS';
        //data1.Include_Deviation_Type__c = '';
        //data1.Include_Product_Groups__c = '';
        data1.Approver_2_Name__c = 'BDGS SPOCs';
        data1.approvingUnit__c = 'MANA/BDGS'; 
        insert data1;
        data1.Approver_1_Name__c = 'MANA Commercial Management';
        update data1;
        Deviation_Approval_Data__c data2 = new Deviation_Approval_Data__c();
        data2.name = 'Test Data2';
        data2.Salesforce_Field__c = 'EscalationLevel__c';
        data2.Field_Value__c = 'Threshold 1';
        data2.Active__c = true;
        data2.Tier__c = 'Tier 1';
        data2.Matching_Key__c = 'MANA#Profitability (UM%)#BNEW#Tier 1';
        data2.Business_Area__c = 'BNEW';
        data2.Include_Deviation_Type__c = '';
        data2.Include_Product_Groups__c = 'Yes';
        data2.Approver_1_Name__c = 'MANA Commercial Management';
        data2.approvingUnit__c = 'MELA';
        insert data2;
        Deviation_Approval_Data__c data3 = new Deviation_Approval_Data__c();
        data3.name = 'Test Data3';
        data3.Salesforce_Field__c = 'EffectiveNetDeviationEscalationLevel__c';
        data3.Field_Value__c = 'Threshold 1';
        data3.Active__c = true;
        data3.Tier__c = 'Tier 1';
        data3.Matching_Key__c = 'MELA#Comparison Price#BDGS#Tier 3';
        data3.Business_Area__c = 'BDGS';
        data3.Include_Deviation_Type__c = '';
        data3.Include_Product_Groups__c = '';
        data3.approvingUnit__c = 'MELA';
        insert data3;
        Deviation_Approval_Data__c data4 = new Deviation_Approval_Data__c();
        data4.name = 'Test Data4';
        data4.Salesforce_Field__c = 'IsdeviationfromEBD__c';
        data4.Field_Value__c = '';
        data4.Active__c = true;
        data4.Tier__c = 'Tier 1';
        data4.Matching_Key__c = 'MELA#EBDTCTRUE#Tier 1';
        data4.Business_Area__c = '';
        data4.Include_Deviation_Type__c = '';
        data4.Include_Product_Groups__c = '';
        data4.approvingUnit__c = 'Sales Ref. Directive';
        insert data4;
        Deviation_Approval_Data__c data5 = new Deviation_Approval_Data__c();
        data5.name = 'Test Data5';
        data5.Salesforce_Field__c = 'SSPSEscalationLevel__c';
        data5.Field_Value__c = 'Threshold 2';
        data5.Active__c = true;
        data5.Tier__c = 'Tier 1';
        data5.Matching_Key__c = 'MANA#Comparison Price#SSPBDGS#Tier 1';
        data5.Business_Area__c = 'BDGS';
        data5.Include_Deviation_Type__c = '';
        data5.Include_Product_Groups__c = '';
        data5.Approver_1_Name__c = 'MANA Commerical Mgmt';
        data5.Approver_2_Name__c = 'BDGS SPOCs';
        data5.approvingUnit__c = 'MANA/BDGS';
        insert data5;
        system.debug('DATA5' + data5);
        Deviation_Approval_Data__c data6 = new Deviation_Approval_Data__c();
        data6.name = 'Test Data6';
        data6.Salesforce_Field__c = 'EscalationLevel__c';
        data6.Field_Value__c = 'Threshold 1';
        data6.Active__c = true;
        data6.Tier__c = 'Tier 1';
        data6.Matching_Key__c = 'MANA#Profitability (UM%)#BNEW#Tier 1';
        data6.Business_Area__c = 'BNEW';
        data6.Include_Deviation_Type__c = '';
        data6.Include_Product_Groups__c = '';
        data6.Approver_1_Name__c = 'MANA Commerical Mgmt';
        data6.approvingUnit__c = 'MELA';
        insert data6;
        system.debug('DATA6' + data6);
        
    }
    @isTest
    public static void createDevTypesTest() {
        try {
            List<Deviation__c> devList = new List<Deviation__c>();
            // String oppStageQualifyOppty = System.Label.Sales_Stage_1_Qualify_Opportunity;
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            // Id standardOppRecordTypeId = System.Label.Record_Type_ID_Standard_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(
                    ProfileId = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'Integration User Profile'
                        LIMIT 1
                    ]
                    .Id,
                    UserName = 'ericsson777@test.com' + System.currentTimeMillis()
                ),
                true
            );
            Account acc;
            Account acc1;
            System.runAs(testUser) {
                acc = (Account) TestDataGenerator.createSObject(new Account(), false);
                insert acc;
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc1 = new Account();
                acc1.Name = 'Test Account';
                acc1.SAP_S2P_ID__c=String.valueOf(1);
                acc1.CurrencyIsoCode = 'SEK';
                acc1.Visible__c = true;
                acc1.Customer_Tier__c = 'Tier 3';
                acc1.CustomerReportingGroup__c= crg.id;
                insert acc1;
            }
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(
                new Pricebook2(),
                true
            );
            Opportunity opp = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(
                    AccountId = acc.Id,
                    RecordtypeId = frameOppRecordTypeId,
                    Anticipated_Deal_Value__c = 500,
                    Lead_Domain__c='BDGS',
                    Pricebook2Id = pb.Id
                )
            );
            insert opp;
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(
                    AccountId = acc1.Id,
                    RecordtypeId = frameOppRecordTypeId,
                    Anticipated_Deal_Value__c = 500,
                    Pricebook2Id = pb.Id
                )
            );
            insert opp1;
            Proposal__c prop = new Proposal__c();
            prop.Opportunity__c = opp.Id;
            insert prop;
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            //prop1.Customer_Tier__c = 'Tier 3';
            insert prop1;
            Deviation__c dev = new Deviation__c();
            dev.Product_Group__c = 'Evolved Pack Core';
            dev.DeviationType__c = 'Comparison Price';
            dev.BusinessArea__c = 'BDGS';
            dev.EscalationLevel__c = 'Threshold 2';
            dev.Proposal__c = prop.Id;
            //insert dev;
            Deviation__c dev1 = new Deviation__c();
            dev1.Product_Group__c = 'NRO Fiber';
            dev1.DeviationType__c = 'Profitability (UM%)';
            dev1.BusinessArea__c = 'BNEW';
            dev1.EscalationLevel__c = 'Threshold 1';
            dev1.Proposal__c = prop.Id;
            //insert dev1;
            Deviation__c dev2 = new Deviation__c();
            dev2.Product_Group__c = 'Evolved Pack Core';
            dev2.DeviationType__c = 'BCTC';
            dev2.BusinessArea__c = 'BDGS';
            dev2.EscalationLevel__c = 'Threshold 1';
            dev2.Proposal__c = prop.Id;
            //insert dev2;
            Deviation__c dev3 = new Deviation__c();
            dev3.Product_Group__c = 'Evolved Pack Core';
            dev3.DeviationType__c = 'Comparison Price';
            dev3.BusinessArea__c = 'BDGS';
            dev3.EscalationLevel__c = 'Threshold 1';
            dev3.Proposal__c = prop1.Id;
            dev3.NetDeviationEscalationLevel__c='Threshold 1';
            dev3.EffectiveNetDeviationEscalationLevel__c='Threshold 1';
            dev3.SSPSEscalationLevel__c='Threshold 3';
            //dev3.Tier__c='Tier 3';
            Deviation__c dev4 = new Deviation__c();
            dev4.Product_Group__c = '';
            dev4.DeviationType__c = 'EBDTC';
            dev4.BusinessArea__c = '';
            dev4.EscalationLevel__c = '';
            dev4.IsdeviationfromEBD__c = 'true';
            dev4.Proposal__c = prop1.Id;
            dev4.NetDeviationEscalationLevel__c='';
            dev4.EffectiveNetDeviationEscalationLevel__c='';
            
            Deviation__c dev5 = new Deviation__c();
            dev5.Product_Group__c = '';
            dev5.DeviationType__c = 'Comparison Price';
            dev5.BusinessArea__c = 'BDGS';
            dev5.EscalationLevel__c = '';
            dev5.SSPSEscalationLevel__c = 'Threshold 2';
            dev5.Proposal__c = prop1.Id;
            dev5.NetDeviationEscalationLevel__c='';
            dev5.EffectiveNetDeviationEscalationLevel__c='';
            
            Deviation__c dev6 = new Deviation__c();
            dev6.Product_Group__c = 'Communication_Services';
            dev6.DeviationType__c = 'Profitability (UM%)';
            dev6.BusinessArea__c = 'BNEW';
            dev6.EscalationLevel__c = 'Threshold 1';
            dev6.Proposal__c = prop.Id;
            
            
            devList.add(dev);
            devList.add(dev1);
            //devList.add(dev6)
            devList.add(dev3);
            devList.add(dev4);
            devList.add(dev5);
            devList.add(dev6);
            insert devList;
            Test.startTest();
            DeviationTypeUtility.createDevTypes(prop.ID,true);
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            Test.stopTest();
        } catch (DMLException e) {
        }
    }
    @isTest
    public static void createDevTypesTest2() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp.MarketArea__c = GlobalConstants.MELA ;
            opp.Lead_Domain__c='BDGS';
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BNEW';
            
            Opportunity opp2 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp2.MarketArea__c = GlobalConstants.MELA ;
            opp2.Lead_Domain__c='BMAS';
            
            Opportunity opp3 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp3.MarketArea__c = GlobalConstants.MELA ;
            opp3.Lead_Domain__c='BDGS';
            
            oppList.add(opp);
            oppList.add(opp1);
            oppList.add(opp2);
            oppList.add(opp3);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop = new Proposal__c();
            prop.Opportunity__c = opp.Id;
            proposalList.add(prop);
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
            Proposal__c prop2 = new Proposal__c();
            prop2.Opportunity__c = opp2.Id;
            proposalList.add(prop2);
            
             insert proposalList;
            
            
            Product__c prod = new Product__c(Business_Area__c='testba',Proposal__c = prop.Id);
            prod.Product_Group__c = 'RAN HW & HWAC';
            prod.Business_Area__c = GlobalConstants.BNEW;
            
            Product__c prod1 = new Product__c(Business_Area__c='testba',Proposal__c = prop.Id);
            prod1.Product_Group__c = 'RAN HW & HWAC';
            prod1.Business_Area__c = GlobalConstants.BNEW;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba',Proposal__c = prop.Id);
            prod2.Product_Group__c = 'IT MS & ADM';
            prod2.Business_Area__c = GlobalConstants.BMAS;
            
            ProdList.add(prod);
            ProdList.add(prod1);
            ProdList.add(prod2);
            insert ProdList;
            Deviation__c dev1 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop.Id);
            dev1.IsdeviationfromEBD__c = GlobalConstants.UpperCase_TRUE;
            Deviation__c dev2 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTCMS, Proposal__c = prop.Id);
            dev2.IsdeviationfromEBD__c = null;
            Deviation__c dev3 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop.Id);
            dev3.IsdeviationfromEBD__c = null; 
            Deviation__c dev4 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop1.Id);
            dev3.IsdeviationfromEBD__c = null; 
            Deviation__c dev5 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop2.Id);
            dev3.IsdeviationfromEBD__c = null; 
            
            Deviation__c dev6 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.Comparison_Price, Proposal__c = prop.Id);
            dev6.IsdeviationfromEBD__c = GlobalConstants.BLANK;
            dev6.BusinessArea__c = 'BDGS';
            dev6.NetDeviationEscalationLevel__c = GlobalConstants.Threshold_1;
            dev6.EffectiveNetDeviationEscalationLevel__c = 'Threshold 2';
            dev6.SSPSEscalationLevel__c = 'Threshold 2';
            dev6.AAPriceObjectEscalationLevel__c = 'Threshold 2';
           
            
            Deviation__c dev7 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.Comparison_Price, Proposal__c = prop1.Id);
            dev7.IsdeviationfromEBD__c = GlobalConstants.UpperCase_TRUE;
            dev7.BusinessArea__c = 'BNEW';
            dev7.NetDeviationEscalationLevel__c = GlobalConstants.Threshold_1;
            dev7.EffectiveNetDeviationEscalationLevel__c = GlobalConstants.Threshold_2;
            dev7.SSPSEscalationLevel__c = GlobalConstants.Threshold_2;
            dev7.AAPriceObjectEscalationLevel__c = GlobalConstants.Threshold_2;
             dev7.Product_Group__c = GlobalConstants.ProductGroup_PassiveAntennaSystems;
            
            Deviation__c dev8 = new Deviation__c(ApprovingUnit__c = GlobalConstants.SLASH ,DeviationType__c = GlobalConstants.EBDTCMS, Proposal__c = prop.Id);
            dev2.IsdeviationfromEBD__c = null;
            
            devList.add(dev1);
            devList.add(dev2);
            devList.add(dev3);
            devList.add(dev4);
            devList.add(dev5);
            devList.add(dev6);
            devList.add(dev7);
            insert devList;
            
            
           /* AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = GlobalConstants.SLASH;
            insert devtype;*/
            
            
            
            DeviationTypeUtility.createDevTypes(prop.ID,true);
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            DeviationTypeUtility.createDevTypes(prop2.ID,true);
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
    //Proiftability or UMAR with only 1 product group that is IT MS & ADM
    @isTest
    public static void createDevTypesTest3() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BNEW';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
     
            Product__c prod1 = new Product__c(Business_Area__c='testba',Proposal__c = prop1.Id);
            prod1.Product_Group__c = 'IT MS & ADM';
            prod1.Business_Area__c = GlobalConstants.BMAS;
            
            ProdList.add(prod1);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.Price_Erosion, Proposal__c = prop1.Id);
            dev9.IsdeviationfromEBD__c = GlobalConstants.UpperCase_TRUE;
            dev9.BusinessArea__c = 'BNEW';
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            
             Deviation__c dev10 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.UMAR, Proposal__c = prop1.Id);
            dev10.IsdeviationfromEBD__c = GlobalConstants.BLANK;
            dev10.BusinessArea__c = 'BMAS';
            dev10.EscalationLevel__c  = GlobalConstants.Threshold_1;
            dev10.Product_Group__c = GlobalConstants.IT_MS_ADM;
           
            devList.add(dev9);
            devList.add(dev10);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = 'MELA/BNEW';
            insert devtype;
      
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
     @isTest
    public static void createDevTypesTest4() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
     
            /*Product__c prod1 = new Product__c(Business_Area__c='testba',Proposal__c = prop1.Id);
            prod1.Product_Group__c = GlobalConstants.BDGS_Other;
            prod1.Business_Area__c = GlobalConstants.BMAS;
            
            ProdList.add(prod1);
            insert ProdList;*/
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop1.Id);
            devList.add(dev9);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = 'MELA';
            insert devtype;
      
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
    
     @isTest
    public static void createDevTypesTest5() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 4';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
     
            Product__c prod1 = new Product__c(Business_Area__c='testba',Proposal__c = prop1.Id);
            prod1.Product_Group__c = GlobalConstants.BDGS_Other;
            prod1.Business_Area__c = GlobalConstants.BMAS;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba1',Proposal__c = prop1.Id);
            prod2.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod2.Business_Area__c = GlobalConstants.BMAS;
            
            ProdList.add(prod1);
            ProdList.add(prod2);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTCMS, Proposal__c = prop1.Id);
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            devList.add(dev9);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = GlobalConstants.SLASH;
            insert devtype;
      
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
      @isTest
    public static void createDevTypesTest6() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba1',Proposal__c = prop1.Id);
            prod2.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod2.Business_Area__c = GlobalConstants.BMAS;
           
            ProdList.add(prod2);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.EBDTC, Proposal__c = prop1.Id);
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            devList.add(dev9);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = GlobalConstants.SLASH;
            insert devtype;
      
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
    // Comparison Price with SSPEScalation Level contains value
    @isTest
    public static void createDevTypesTest7() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 1';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba1',Proposal__c = prop1.Id);
            prod2.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod2.Business_Area__c = GlobalConstants.BMAS;
           
            ProdList.add(prod2);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = 'Comparison Price', Proposal__c = prop1.Id);
            dev9.BusinessArea__c = GlobalConstants.BDGS;
           dev9.SSPSEscalationLevel__c = GlobalConstants.Threshold_2;
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            dev9.Product_Group__c = GlobalConstants.Communication_Services;
            devList.add(dev9);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = 'MELA/BDGS';
            insert devtype;
      
            dev9.DeviationTypeGroup__c = devtype.Id;
            update dev9;
            
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            
            //dev.DeviationType__c = GlobalConstants.EBDTCMS;
            //update dev;
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
    // Profitability OR UMAR with more than 1 Product group containing IT MS and ADM
 @isTest
    public static void createDevTypesTest8() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba1',Proposal__c = prop1.Id);
            prod2.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod2.Business_Area__c = GlobalConstants.BMAS;
           
            ProdList.add(prod2);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.UMAR, Proposal__c = prop1.Id);
            dev9.IsdeviationfromEBD__c = GlobalConstants.BLANK;
            dev9.BusinessArea__c = GlobalConstants.BMAS;
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            dev9.Product_Group__c =  GlobalConstants.IT_MS_ADM;
            
            
            Deviation__c dev6 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.UMAR, Proposal__c = prop1.Id);
           dev6.BusinessArea__c = 'BMAS';
            dev6.EscalationLevel__c = GlobalConstants.Threshold_2;
            dev6.Product_Group__c = 'BMAS OTHER';
            
            devList.add(dev9);
            devList.add(dev6);
            insert devList;
            
            
            AccessSettings__c sett=AccessSettings__c.getInstance();
            sett.CanEditDeviationFields__c=true;
            upsert sett;
            
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop1.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            devtype.ApprovingUnit__c = GlobalConstants.SLASH;
            insert devtype;
      
            DeviationTypeUtility.createDevTypes(prop1.ID,true);
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }
     // Profitability OR UMAR with more than 1 Product group other than IT MS and ADM
 @isTest
    public static void createDevTypesTest9() {
        try {
            List<Product__c> ProdList = new List<Product__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
            User testUser = (User) TestDataGenerator.createSObject(
                new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile' LIMIT 1].Id,
                         UserName = 'ericsson777@test.com' + System.currentTimeMillis() ),true);
            Account acc;
            System.runAs(testUser) {
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
                crg.MarketArea__c = GlobalConstants.MELA;
                crg.CRG_ID__c='HW1234';
                crg.Name='testCRG';
                insert crg;
                
                acc = new Account();
                acc.Name = 'Test Account';
                acc.SAP_S2P_ID__c=String.valueOf(1);
                acc.CurrencyIsoCode = 'SEK';
                acc.Visible__c = true;
                acc.Customer_Tier__c = 'Tier 3';
                acc.CustomerReportingGroup__c= crg.id;
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2) TestDataGenerator.createSObject(new Pricebook2(),true);
            
            Opportunity opp1 = (Opportunity) TestDataGenerator.createSObject(
                new Opportunity(AccountId = acc.Id,RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500,Pricebook2Id = pb.Id));
            opp1.MarketArea__c = GlobalConstants.MELA ;
            opp1.Lead_Domain__c='BDGS';
            
                        oppList.add(opp1);
           
            
            Test.startTest();
             insert oppList;
            
            Proposal__c prop1 = new Proposal__c();
            prop1.Opportunity__c = opp1.Id;
            proposalList.add(prop1);
            
             insert proposalList;
            
            Product__c prod2 = new Product__c(Business_Area__c='testba1',Proposal__c = prop1.Id);
            prod2.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod2.Business_Area__c = GlobalConstants.BMAS;
           
            ProdList.add(prod2);
            insert ProdList;
                      
            Deviation__c dev9 = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = GlobalConstants.UMAR, Proposal__c = prop1.Id);
            dev9.BusinessArea__c = GlobalConstants.BNEW;
            dev9.EscalationLevel__c  = GlobalConstants.Threshold_2;
            dev9.Product_Group__c =  GlobalConstants.ProductGroup_PassiveAntennaSystems;
            
            devList.add(dev9);
            insert devList;
            
          
            
            Test.stopTest();
            
        }catch (DMLException e) {
        }
    }


}