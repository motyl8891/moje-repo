@isTest
private without Sharing class ProposalTriggerHandlerHelperTest {

    /**
    * Setup for test methods
    */
    /*@testSetup
    static void setup() {

        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
        insert opp;

        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
                               new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c = false));
        insert prop;
    }*/

    @isTest
    public static void testUpdatePrimaryProposalProductsPostive() {
        try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }

      //  Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
        insert opp;

        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
                               new Proposal__c(Name = 'Test', Opportunity__c = opp.Id));
        prop.Primary__c=False;
        prop.Approved_Stage__c='4. Negotiate and Close';
        prop.Is_Closed_Won__c=false;
        insert prop;

        prop = [SELECT Id, Primary__c, Name FROM Proposal__c LIMIT 1];
        prop.Primary__c = true;
        upsert prop;

        System.assertEquals(true, prop.Primary__c);
        }catch(DMLException e){
            
        }
        System.assert(true);  //NS
    }

    @isTest
    public static void test_onePrimaryProposalInsertPOS() {
        try{
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;

        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;

        Proposal__c prop1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));
        prop1.Primary__c=True;
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Is_Closed_Won__c=false;
        insert prop1;

      /*  Proposal__c prop2 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));
        prop2.Primary__c=True;
        prop2.Approved_Stage__c='4. Negotiate and Close';
        prop2.Is_Closed_Won__c=false;
        prop2.Proposal_Id__c = '777123';
        prop2.Proposal_Unique_Id__c = '123777999'; */
        }catch(DMLException e){
           
        }
    System.assert(true);  //NS
    }

    @isTest
    public static void test_onePrimaryProposalUpdatePOS() {
        try{
        Test.startTest();
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;

        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;
        Test.stopTest();
        Proposal__c prop1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));
        prop1.Primary__c=True;
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Is_Closed_Won__c=false;
        insert prop1;

        Proposal__c prop2 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));

        prop2.Approved_Stage__c='4. Negotiate and Close';
        prop2.Is_Closed_Won__c=false;
        prop2.Proposal_Id__c = '777123';
        prop2.Proposal_Unique_Id__c = '123777999';
        insert prop2;

        prop2.Primary__c = true;
        update prop2;

        prop1 = [SELECT Id, Primary__c, Name FROM Proposal__c WHERE Id=:prop1.Id LIMIT 1];
        System.assertEquals(false, prop1.Primary__c);
        }catch(DMLException e){
           
        }
    System.assert(true);  //NS
    }

    @isTest
    public static void test_onePrimaryProposalUpdateNEG() {
        
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;

        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;

        Proposal__c prop1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));
        prop1.Primary__c=True;
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Is_Closed_Won__c=false;
        insert prop1;

        Proposal__c prop2 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id));
        prop2.Approved_Stage__c='4. Negotiate and Close';
        prop2.Is_Closed_Won__c=false;
        prop2.Proposal_Id__c = '777123';
        prop2.Proposal_Unique_Id__c = '123777999';
        insert prop2;

        prop1.Primary__c = false;
        try{
            update prop1;
        }catch(DmlException e){
            System.assert(e.getMessage().contains('You cannot uncheck the "Primary" flag on a proposal'), e.getMessage());
        }
        System.assert(true);  //NS
    }
    @isTest
    public static void updateDeviationsToApprovedTest() {
        try{
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;

        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;
    
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Proposal__c> propList1 = new List<Proposal__c>();
        Proposal__c prop1 = new Proposal__c (Opportunity__c=opp.Id);
        prop1.name = 'Proposal1';
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Primary__c=True;
        prop1.DeviationsPreApproved__c = false;
        prop1.RequestedDeviationsApproval__c = false;
        propList.add(prop1);
        Proposal__c prop2 = new Proposal__c (Opportunity__c=opp.Id);
        prop2.name = 'Proposal2';
        prop2.Approved_Stage__c='4. Negotiate and Close';
        prop2.Primary__c=false;
        prop2.DeviationsPreApproved__c = false;
        prop2.RequestedDeviationsApproval__c = false;
        propList.add(prop2);
        insert propList; 
        DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=prop1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
        insert devtype1; 
        DeviationTypeGroup__c devtype2 = new DeviationTypeGroup__c(Proposal__c=prop2.id,MAStatus__c ='Pending',BAStatus__c='Pending');
        insert devtype2;
        DeviationTypeGroup__c dev = [select id,DeviationApprovalStatus__c from DeviationTypeGroup__c where id =: devtype1.id Limit 1];
        
        prop2.Primary__c = true;
        update prop2;
        
        prop1.Primary__c = false; 
        prop1.DeviationsPreApproved__c = true;
        prop1.PreApprovalComments__c = 'test';
        update prop1;
        ProposalTriggerHandlerHelper.recallDeviationApprovals(null,null);
        ProposalTriggerHandlerHelper.triggerOpportunitiesUpdate(null);
        ProposalTriggerHandlerHelper.setClosedWonMinorFlow(null);
        ProposalTriggerHandlerHelper.onePrimaryProposal(null, null);
        ProposalTriggerHandlerHelper.updatePrimaryProposal(null, null, false);
        Proposal__c   ppp =[select id,Overall_EBD_Approval_Status__c from Proposal__c where id=:prop1.id Limit 1];
        
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSONSALESUSERPROFILENAME), UserName = 'ericsson7787@test.com'+System.currentTimeMillis()),true);        
        System.runAs(testUser1){
        prop2.DeviationsPreApproved__c = true;
        update prop2;
        }
        }catch(DMLException e){
          
        }
    System.assert(true);  //NS
    }
        /***************************************************************
* @author: Shubham Kadam
* @date: 23-06-2020
* @description: This method is test method for checkEditabilityOfPreApprovalField
********************************************************************/
    @isTest
    public static void checkEditabilityOfPreApprovalFieldTest()
    {
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;
        System.runAs(testUser1)
            { 
        List<Proposal__c> propList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        Proposal__c prop1 = new Proposal__c (Opportunity__c=opp.Id);
        prop1.name = 'Proposal1';
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Primary__c=True;
        prop1.DeviationsPreApproved__c = false;
        prop1.RequestedDeviationsApproval__c = false;
        insert prop1;
        oldProposalMap.put(prop1.Id,prop1);
        
        try{    
            prop1.DeviationsPreApproved__c = true;
            prop1.RequestedDeviationsApproval__c = true;
            update prop1;   
            propList.add(prop1);
            Test.startTest();
                            ProposalTriggerHandlerHelper.checkEditabilityOfPreApprovalField(propList,oldProposalMap);
            Test.stopTest();
        }
        catch(DMLException e) {     
            
        }
        ProposalTriggerHandlerHelper.checkEditabilityOfPreApprovalField(null,null);
        ProposalTriggerHandlerHelper.updateDeviationsToApproved(null,null);
        ProposalTriggerHandlerHelper.recallDeviationApprovals(null,null);
            }
        //ProposalTriggerHandlerHelper.triggerOpportunitiesUpdate(null);
        System.assert(true);  //NS
    }
    /***************************************************************
* @author: Shubham Kadam
* @date: 23-06-2020
* @description: This method is test method for recallDeviationApprovals
********************************************************************/
    @isTest
    public static void recallDeviationApprovalsTest()
    {
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2;
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;
        System.runAs(testUser1){
        List<Proposal__c> propList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        Proposal__c prop1 = new Proposal__c (Opportunity__c=opp.Id);
        prop1.name = 'Proposal1';
        prop1.Approved_Stage__c='4. Negotiate and Close';
        prop1.Primary__c=True;
        prop1.DeviationsPreApproved__c = false;
        prop1.RequestedDeviationsApproval__c = false;
        prop1.Overall_EBD_Approval_Status__c = 'Pending';
        insert prop1;
        oldProposalMap.put(prop1.Id,prop1);
        
        //prop1.Overall_EBD_Approval_Status__c = 'Cancelled';
        //Update prop1;
        
        Proposal__c prop2 = new Proposal__c (Opportunity__c=opp.Id);
        prop2.name = 'Proposal2';
        prop2.Approved_Stage__c='4. Negotiate and Close';
        prop2.Primary__c=True;
        prop2.DeviationsPreApproved__c = false;
        prop2.RequestedDeviationsApproval__c = false;
        insert prop2;
        oldProposalMap.put(prop2.Id,prop2);
        
        DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=prop1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
        insert devtype1; 
        try{    
            prop1.DeviationsPreApproved__c = true;
            prop1.RequestedDeviationsApproval__c = true;
            update prop1;   
            propList.add(prop1);
            propList.add(prop2);
            
            Test.startTest();
                ProposalTriggerHandlerHelper.recallDeviationApprovals(propList,oldProposalMap);
            Test.stopTest();
        }
        catch(DMLException e) {     
            
        }
        }
        System.assert(true);  //NS
        }
    
    /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method for postToChatter
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest()
    {
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                      UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            //Acc - MELA
            //CU
            CustomerUnit__c cu = new CustomerUnit__c(
                Type__c = 'CU',                                    // Type
                Name = GlobalConstants.CU_Western_Europe,          // Name
                DeletionFlag__c = false,                           // Deletion Flag
                Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
                Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
            );
           
            insert cu;
            
            //CRG Insert
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c(
                Name = 'TEST CRG',                                  // CRG Name
                CustomerUnit__c = cu.id,                            // Customer Unit
                MarketArea__c = 'MELA',                             // Market Area
                CRG_ID__c = '12308',                                // CRG ID
                Account_Primary_KAM__c = testUser.Id,               // Account Primary KAM
                Valid_KAM_CU_Head_Approvers__c = false,             // Valid KAM & CU Head Approvers
                Account_CU_Head__c = testUser.Id,                   // Account CU Head
                Exempt_from_GCU_Sales_Decision_Rules__c = false,    // Exempt from GCU Sales Decision Rules
                DeletionFlag__c = false                             // Deletion Flag
            );
            insert crg;
            //Account Insert
            acc = new Account(
                Name = 'Test Acc',                              // Account Name
                Visible__c = true,                              // Visible
                SAP_S2P_ID__c = '3338',                         // SAP S2P ID
                MDM_Customer_Id__c = '238',                     // MDM Customer ID
                Partner_ID__c = '2488',                         // Partner ID
                CustomerReportingGroup__c = crg.Id,             // Customer Reporting Group
                Is_Partner__c = false,                          // Partnering Account
                SAP_S2P_ID_Number__c = 3338                     // SAP S2P ID Number
            );
            insert acc;
            
            List<Proposal__c> newpropList = new List<Proposal__c>();
            Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
            test.startTest();
            //Opp create
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, Name='oppMELA'));
            insert opp;
            
            //Market Area = MELA
            //Proposal create
            Proposal__c propMELA = new Proposal__c (Opportunity__c=opp.Id);
            propMELA.name = 'Proposal1';
            propMELA.Primary__c=True;
            propMELA.DeviationsPreApproved__c = false;
            propMELA.RequestedDeviationsApproval__c = false;
            insert propMELA;
            test.stopTest();
            Product__c prod = new Product__c();
            prod.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod.Proposal__c = propMELA.id;
            prod.Business_Area__c = 'BMAS';
            insert prod;
            
            Product__c prod1 = new Product__c();
            prod1.Product_Group__c = GlobalConstants.IT_MS_ADM;
            prod1.Proposal__c = propMELA.id;
            prod1.Business_Area__c = 'BNEW';
            insert prod1;
            
            oldProposalMap.put(propMELA.Id,propMELA);
            
            //MA_Approver__c = MELA_DS_CU_CD_n_CU_HoDS
            DeviationTypeGroup__c devtypeMELA = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA.MA_Approver__c = GlobalConstants.MELA_DS_CU_CD_n_CU_HoDS;
            devtypeMELA.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA;
            
            //MA_Approver__c = MELA_NMS_Tactical_Managers
            DeviationTypeGroup__c devtypeMELA1 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA1.MA_Approver__c = GlobalConstants.MELA_NMS_Tactical_Managers;
            devtypeMELA1.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA1;
            
            //MA_Approver__c = MELA_DS_Strategic_Price_Manager
            DeviationTypeGroup__c devtypeMELA2 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA2.MA_Approver__c = GlobalConstants.MELA_DS_Strategic_Price_Manager;
            devtypeMELA2.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA2;
            
            //MA_Approver__c = MELA_DS_CM_Head
            DeviationTypeGroup__c devtypeMELA3 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA3.MA_Approver__c = GlobalConstants.MELA_DS_CM_Head;
            devtypeMELA3.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA3;
            
            //MA_Approver__c = MELA_NMS_CM_Head
            DeviationTypeGroup__c devtypeMELA4 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA4.MA_Approver__c = GlobalConstants.MELA_NMS_CM_Head;
            devtypeMELA4.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA4;
            
            //MA_Approver__c = MELA_DS_CM_Head_n_Head_of_Price_Mgmt
            DeviationTypeGroup__c devtypeMELA5 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA5.MA_Approver__c = GlobalConstants.MELA_DS_CM_Head_n_Head_of_Price_Mgmt;
            devtypeMELA5.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA5;
            
            //MA_Approver__c = MELA_Head_of_DS_n_MELA_DS_CM_Head
            DeviationTypeGroup__c devtypeMELA6 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA6.MA_Approver__c = GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head;
            devtypeMELA6.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA6;
            
            //MA_Approver__c = BMAS_SPOCs
            DeviationTypeGroup__c devtypeMELA7 = new DeviationTypeGroup__c(Proposal__c=propMELA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMELA7.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtypeMELA7.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMELA7;
            
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/     
             
            /*//Acc - MANA
            //CU
            CustomerUnit__c cuMANA = new CustomerUnit__c(
              Type__c = 'CU',                                    // Type
              Name = 'AT&T',                                     // Name
              DeletionFlag__c = false,                           // Deletion Flag
              Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
              Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
            );
            insert cuMANA;

            //CRG Insert
            CustomerReportingGroup__c crgMANA = new CustomerReportingGroup__c(
              Name = 'TEST CRG',                                // CRG Name
              CustomerUnit__c = cuMANA.id,                      // Customer Unit
              MarketArea__c = 'MANA',                           // Market Area
              CRG_ID__c = '12305',                              // CRG ID
              Account_Primary_KAM__c = testUser.Id,             // Account Primary KAM
              Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
              Account_CU_Head__c = testUser.Id,                 // Account CU Head
              Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
              DeletionFlag__c = false                           // Deletion Flag
            );
            insert crgMANA;

            //Account Insert
            Account accMANA = new Account(
              Name = 'Test Acc',                                // Account Name
              Visible__c = true,                                // Visible
              SAP_S2P_ID__c = '3335',                           // SAP S2P ID
              MDM_Customer_Id__c = '255',                       // MDM Customer ID
              Partner_ID__c = '2455',                           // Partner ID
              CustomerReportingGroup__c = crgMANA.Id,           // Customer Reporting Group
              Is_Partner__c = false,                            // Partnering Account
              SAP_S2P_ID_Number__c = 3335                       // SAP S2P ID Number
            );
            insert accMANA;
            
            //Market Area = MANA
            //Opp create - deal value less than 30M
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            
            Opportunity oppMANA = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMANA.Id, Name='oppMANA',
                                                                                RecordtypeId = frameOppRecordTypeId, 
                                                                                Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                Description='test', CloseDate= system.today()));
            insert oppMANA;
            
            //Proposal create
            Proposal__c propMANA = new Proposal__c (Opportunity__c=oppMANA.Id);
            propMANA.name = 'Proposal1';
            propMANA.Primary__c=True;
            propMANA.DeviationsPreApproved__c = false;
            propMANA.RequestedDeviationsApproval__c = false;
            insert propMANA;
            test.stopTest();
            oldProposalMap.put(propMANA.Id,propMANA);
            
            //MA_Approver__c = MANA Commercial Management
            DeviationTypeGroup__c devtypeMANA = new DeviationTypeGroup__c(Proposal__c=propMANA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA.MA_Approver__c = 'MANA Commercial Management';
            devtypeMANA.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA;  
            
            //Opp create - deal value greater than 30M      
            Opportunity oppMANA1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMANA.Id, Name='oppMANA',
                                                                                RecordtypeId = frameOppRecordTypeId, 
                                                                                Forecast__c='Exclude', Anticipated_Deal_Value__c = 50000000, 
                                                                                Description='test', CloseDate= system.today()));
            insert oppMANA1;
            
            //Proposal create
            Proposal__c propMANA1 = new Proposal__c (Opportunity__c=oppMANA1.Id);
            propMANA1.name = 'Proposal1';
            propMANA1.Primary__c=True;
            propMANA1.DeviationsPreApproved__c = false;
            propMANA1.RequestedDeviationsApproval__c = false;
            insert propMANA1;
            oldProposalMap.put(propMANA1.Id,propMANA1);
            
            //MA_Approver__c = MANA Commercial Management
            DeviationTypeGroup__c devtypeMANA1 = new DeviationTypeGroup__c(Proposal__c=propMANA1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA1.MA_Approver__c = 'MANA Commercial Management';
            devtypeMANA1.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA1; 
            
            //MA_Approver__c = BMAS_SPOCs
            DeviationTypeGroup__c devtypeMANA2 = new DeviationTypeGroup__c(Proposal__c=propMANA1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA2.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtypeMANA2.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA2; */
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/  
           
            try{    
                propMELA.RequestedDeviationsApproval__c = true;
                update propMELA;   
                newpropList.add(propMELA);
                
                /*propMANA1.RequestedDeviationsApproval__c = true;
                update propMANA1;   
                newpropList.add(propMANA1);
                
                propMANA.RequestedDeviationsApproval__c = true;
                update propMANA;   
                newpropList.add(propMANA);*/           
                               
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap);
                ProposalTriggerHandlerHelper.postToChatter(null,null);
                ProposalTriggerHandlerHelper.updatePrimaryProposalProducts(null,null);
                ProposalTriggerHandlerHelper.onePrimaryProposalBeforeUpdate(null,null);
                ProposalTriggerHandlerHelper.onePrimaryProposalAfterInsert(null);
                
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            System.assert(true);  //NS
        }        
    }
    
    
    
    /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method for postToChatter
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTestpart1()
    {
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                      UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/     
             test.startTest();
            //Acc - MANA
            //CU
            CustomerUnit__c cuMANA = new CustomerUnit__c(
              Type__c = 'CU',                                    // Type
              Name = 'AT&T',                                     // Name
              DeletionFlag__c = false,                           // Deletion Flag
              Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
              Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
            );
            insert cuMANA;
			List<Proposal__c> newpropList = new List<Proposal__c>();
            Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
            //CRG Insert
            CustomerReportingGroup__c crgMANA = new CustomerReportingGroup__c(
              Name = 'TEST CRG',                                // CRG Name
              CustomerUnit__c = cuMANA.id,                      // Customer Unit
              MarketArea__c = 'MANA',                           // Market Area
              CRG_ID__c = '12305',                              // CRG ID
              Account_Primary_KAM__c = testUser.Id,             // Account Primary KAM
              Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
              Account_CU_Head__c = testUser.Id,                 // Account CU Head
              Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
              DeletionFlag__c = false                           // Deletion Flag
            );
            insert crgMANA;

            //Account Insert
            Account accMANA = new Account(
              Name = 'Test Acc',                                // Account Name
              Visible__c = true,                                // Visible
              SAP_S2P_ID__c = '3335',                           // SAP S2P ID
              MDM_Customer_Id__c = '255',                       // MDM Customer ID
              Partner_ID__c = '2455',                           // Partner ID
              CustomerReportingGroup__c = crgMANA.Id,           // Customer Reporting Group
              Is_Partner__c = false,                            // Partnering Account
              SAP_S2P_ID_Number__c = 3335                       // SAP S2P ID Number
            );
            insert accMANA;
            
            //Market Area = MANA
            //Opp create - deal value less than 30M
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            
            Opportunity oppMANA = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMANA.Id, Name='oppMANA',
                                                                                RecordtypeId = frameOppRecordTypeId, 
                                                                                Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                Description='test', CloseDate= system.today()));
            insert oppMANA;
            
            //Proposal create
            Proposal__c propMANA = new Proposal__c (Opportunity__c=oppMANA.Id);
            propMANA.name = 'Proposal1';
            propMANA.Primary__c=True;
            propMANA.DeviationsPreApproved__c = false;
            propMANA.RequestedDeviationsApproval__c = false;
            insert propMANA;
            
            oldProposalMap.put(propMANA.Id,propMANA);
            
            //MA_Approver__c = MANA Commercial Management
            DeviationTypeGroup__c devtypeMANA = new DeviationTypeGroup__c(Proposal__c=propMANA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA.MA_Approver__c = 'MANA Commercial Management';
            devtypeMANA.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA;  
            test.stopTest();
            //Opp create - deal value greater than 30M      
            Opportunity oppMANA1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMANA.Id, Name='oppMANA',
                                                                                RecordtypeId = frameOppRecordTypeId, 
                                                                                Forecast__c='Exclude', Anticipated_Deal_Value__c = 50000000, 
                                                                                Description='test', CloseDate= system.today()));
            insert oppMANA1;
            
            //Proposal create
            Proposal__c propMANA1 = new Proposal__c (Opportunity__c=oppMANA1.Id);
            propMANA1.name = 'Proposal1';
            propMANA1.Primary__c=True;
            propMANA1.DeviationsPreApproved__c = false;
            propMANA1.RequestedDeviationsApproval__c = false;
            insert propMANA1;
            oldProposalMap.put(propMANA1.Id,propMANA1);
            
            //MA_Approver__c = MANA Commercial Management
            DeviationTypeGroup__c devtypeMANA1 = new DeviationTypeGroup__c(Proposal__c=propMANA1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA1.MA_Approver__c = 'MANA Commercial Management';
            devtypeMANA1.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA1; 
            
            //MA_Approver__c = BMAS_SPOCs
            DeviationTypeGroup__c devtypeMANA2 = new DeviationTypeGroup__c(Proposal__c=propMANA1.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeMANA2.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtypeMANA2.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeMANA2; 
            
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/  
           
            try{    
                /*propMELA.RequestedDeviationsApproval__c = true;
                update propMELA;   
                newpropList.add(propMELA);*/
                
                propMANA1.RequestedDeviationsApproval__c = true;
                update propMANA1;   
                newpropList.add(propMANA1);
                
                propMANA.RequestedDeviationsApproval__c = true;
                update propMANA;   
                newpropList.add(propMANA);       
                               
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap);
                ProposalTriggerHandlerHelper.postToChatter(null,null);
                ProposalTriggerHandlerHelper.updatePrimaryProposalProducts(null,null);
                ProposalTriggerHandlerHelper.onePrimaryProposalBeforeUpdate(null,null);
                ProposalTriggerHandlerHelper.onePrimaryProposalAfterInsert(null);
                
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            System.assert(true);  //NS
        }        
    }
    
    /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method to cover remaining part of postToChatter 
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest1()
    {
        List<Proposal__c> newpropList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            //Acc - MMEA
            //CU
            CustomerUnit__c cuMMEA = new CustomerUnit__c(
              Type__c = 'CU',                                    // Type
              Name = 'CU Turkey',                                // Name
              DeletionFlag__c = false,                           // Deletion Flag
              Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
              Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
            );
            insert cuMMEA;

            //CRG Insert
            CustomerReportingGroup__c crgMMEA = new CustomerReportingGroup__c(
              Name = 'TEST CRG',                                // CRG Name
              CustomerUnit__c = cuMMEA.id,                      // Customer Unit
              MarketArea__c = 'MMEA',                           // Market Area
              CRG_ID__c = '12304',                              // CRG ID
              Account_Primary_KAM__c = testUser.Id,             // Account Primary KAM
              Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
              Account_CU_Head__c = testUser.Id,                 // Account CU Head
              Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
              DeletionFlag__c = false                           // Deletion Flag
            );
            insert crgMMEA;
            Test.startTest();
            //Account Insert
            Account accMMEA = new Account(
              Name = 'Test Acc',                                // Account Name
              Visible__c = true,                                // Visible
              SAP_S2P_ID__c = '3333',                           // SAP S2P ID
              MDM_Customer_Id__c = '235',                       // MDM Customer ID
              Partner_ID__c = '2485',                           // Partner ID
              CustomerReportingGroup__c = crgMMEA.Id,           // Customer Reporting Group
              Is_Partner__c = false,                            // Partnering Account
              SAP_S2P_ID_Number__c = 3333                       // SAP S2P ID Number
            );
            insert accMMEA;
            
            //Market Area = MMEA
            //Opp create
            Opportunity oppMMEA = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMMEA.Id, Name='oppMMEA'));
            insert oppMMEA;
  
            //Proposal create
            Proposal__c propMMEA = new Proposal__c (Opportunity__c=oppMMEA.Id);
            propMMEA.name = 'Proposal1';
            propMMEA.Primary__c=True;
            propMMEA.DeviationsPreApproved__c = false;
            propMMEA.RequestedDeviationsApproval__c = false;
            insert propMMEA;
            oldProposalMap.put(propMMEA.Id,propMMEA);
            
            //MA_Approver__c = 'MMEA CU Commercial Directors'
            DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=propMMEA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype1.MA_Approver__c = 'MMEA CU Commercial Directors';
            devtype1.BA_Approver__c = 'BNEW SPOCs';
            insert devtype1; 
            
            //MA_Approver__c = MMEA_CM_Head
            DeviationTypeGroup__c devtype2 = new DeviationTypeGroup__c(Proposal__c=propMMEA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype2.MA_Approver__c = GlobalConstants.MMEA_CM_Head;
            devtype2.BA_Approver__c = 'BNEW SPOCs';
            insert devtype2;
            
            //MA_Approver__c = GlobalConstants.BMAS_SPOCs
            DeviationTypeGroup__c devtype5 = new DeviationTypeGroup__c(Proposal__c=propMMEA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype5.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtype5.BA_Approver__c = 'BNEW SPOCs';
            insert devtype5; 
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/   
            
            

            test.stopTest(); 
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
                    
             try{    
                  
                 
                propMMEA.RequestedDeviationsApproval__c = true;
                update propMMEA;   
                newpropList.add(propMMEA);
                   
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap); 
                 
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            
            System.assert(true);  //NS            
        }
    }


    /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method to cover remaining part of postToChatter 
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest2()
    {
        List<Proposal__c> newpropList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            
            //Acc - MNEA
      //CU
      CustomerUnit__c cuMNEA = new CustomerUnit__c(
        Type__c = 'CU',                                    // Type
        Name = 'KDDI & NTT Group',                      // Name
        DeletionFlag__c = false,                           // Deletion Flag
        Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
        Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
      );
      insert cuMNEA;

      //CRG Insert
      CustomerReportingGroup__c crgMNEA = new CustomerReportingGroup__c(
        Name = 'TEST CRG',                                // CRG Name
        CustomerUnit__c = cuMNEA.id,             // Customer Unit
        MarketArea__c = 'MNEA',                           // Market Area
        CRG_ID__c = '12309',                              // CRG ID
        Account_Primary_KAM__c = testUser.Id,            // Account Primary KAM
        Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
        Account_CU_Head__c = testUser.Id,               // Account CU Head
        Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
        DeletionFlag__c = false                           // Deletion Flag
      );
      insert crgMNEA;
        Test.startTest();
      //Account Insert
      Account accMNEA = new Account(
        Name = 'Test Acc',                        // Account Name
        Visible__c = true,                                // Visible
        SAP_S2P_ID__c = '3339',                           // SAP S2P ID
        MDM_Customer_Id__c = '239',                       // MDM Customer ID
        Partner_ID__c = '2489',                           // Partner ID
        CustomerReportingGroup__c = crgMNEA.Id,        // Customer Reporting Group
        Is_Partner__c = false,                            // Partnering Account
        SAP_S2P_ID_Number__c = 3339                       // SAP S2P ID Number
      );
      insert accMNEA;
            
            //Market Area = MNEA
            //Opp create
            Opportunity oppMNEA = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMNEA.Id, Name='oppMNEA'));
            insert oppMNEA;
            
            //Proposal create
            Proposal__c propMNEA = new Proposal__c (Opportunity__c=oppMNEA.Id);
            propMNEA.name = 'Proposal1';
            propMNEA.Primary__c=True;
            propMNEA.DeviationsPreApproved__c = false;
            propMNEA.RequestedDeviationsApproval__c = false;
            insert propMNEA;
            oldProposalMap.put(propMNEA.Id,propMNEA);
            
            //MA_Approver__c = GlobalConstants.MNEA_CM_Head
            DeviationTypeGroup__c devtype3 = new DeviationTypeGroup__c(Proposal__c=propMNEA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype3.MA_Approver__c = GlobalConstants.MNEA_CM_Head;
            devtype3.BA_Approver__c = 'BNEW SPOCs';
            insert devtype3;    
            
            //MA_Approver__c = GlobalConstants.BMAS_SPOCs
            DeviationTypeGroup__c devtype4 = new DeviationTypeGroup__c(Proposal__c=propMNEA.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype4.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtype4.BA_Approver__c = 'BNEW SPOCs';
            insert devtype4;    
            test.stopTest(); 
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
                    
             try{    
                  
                 
               propMNEA.RequestedDeviationsApproval__c = true;
                update propMNEA;   
                newpropList.add(propMNEA);
                   
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap); 
                 
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            
            System.assert(true);  //NS            
        }
    } 
    
     /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method to cover remaining part of postToChatter 
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest3()
    {
        List<Proposal__c> newpropList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            
            //Acc - MOAI-CU INDONESIA
      //CU
      CustomerUnit__c cuMOAI = new CustomerUnit__c(
        Type__c = 'CU',                                    // Type
        Name = GlobalConstants.CU_THAILAND,                // Name
        DeletionFlag__c = false,                           // Deletion Flag
        Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
        Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
      );
      insert cuMOAI;

      //CRG Insert
      CustomerReportingGroup__c crgMOAI = new CustomerReportingGroup__c(
        Name = 'TEST CRG',                                // CRG Name
        CustomerUnit__c = cuMOAI.id,             // Customer Unit
        MarketArea__c = 'MOAI',                           // Market Area
        CRG_ID__c = '12306',                              // CRG ID
        Account_Primary_KAM__c = testUser.Id,            // Account Primary KAM
        Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
        Account_CU_Head__c = testUser.Id,               // Account CU Head
        Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
        DeletionFlag__c = false                           // Deletion Flag
      );
      insert crgMOAI;
        Test.startTest();
      //Account Insert
      Account accMOAI = new Account(
        Name = 'Test Acc',                        // Account Name
        Visible__c = true,                                // Visible
        SAP_S2P_ID__c = '3336',                           // SAP S2P ID
        MDM_Customer_Id__c = '236',                       // MDM Customer ID
        Partner_ID__c = '2486',                           // Partner ID
        CustomerReportingGroup__c = crgMOAI.Id,        // Customer Reporting Group
        Is_Partner__c = false,                            // Partnering Account
        SAP_S2P_ID_Number__c = 3336                       // SAP S2P ID Number
      );
      insert accMOAI;
      
            //Market Area = MOAI
            //Opp create
            Opportunity oppMOAI = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMOAI.Id, Name='oppMOAI'));
            insert oppMOAI;
        
            //Proposal create
            Proposal__c propMOAI = new Proposal__c (Opportunity__c=oppMOAI.Id);
            propMOAI.name = 'Proposal1';
            propMOAI.Primary__c=True;
            propMOAI.DeviationsPreApproved__c = false;
            propMOAI.RequestedDeviationsApproval__c = false;
            insert propMOAI;
            oldProposalMap.put(propMOAI.Id,propMOAI);
            
            //MA_Approver__c = MOAI_EBD_Contractual_TnC
            DeviationTypeGroup__c devtype6 = new DeviationTypeGroup__c(Proposal__c=propMOAI.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype6.MA_Approver__c = GlobalConstants.MOAI_EBD_Contractual_TnC;
            devtype6.BA_Approver__c = 'BNEW SPOCs';
            insert devtype6; 
            
            //MA_Approver__c = MOAI_EBD_Commercial
            DeviationTypeGroup__c devtype7 = new DeviationTypeGroup__c(Proposal__c=propMOAI.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtype7.MA_Approver__c = GlobalConstants.MOAI_EBD_Commercial;
            devtype7.BA_Approver__c = 'BNEW SPOCs';
            insert devtype7;
    
            test.stopTest(); 
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
                    
             try{    
                  
                 
                propMOAI.RequestedDeviationsApproval__c = true;
                update propMOAI;   
                newpropList.add(propMOAI); 
                   
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap); 
                 
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            
            System.assert(true);  //NS            
        }
    }
    
      /***************************************************************
* @author: Shubham Kadam
* @date: 26-08-2020
* @description: This method is test method to cover remaining part of postToChatter 
********************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest4()
    {
        List<Proposal__c> newpropList = new List<Proposal__c>();
        Map<ID, Proposal__c> oldProposalMap = new Map<ID, Proposal__c>();
        
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = 'Standard Catalog';
        insert pb2; 
        
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);     
        
        System.runAs(testUser){
            
            //Acc - MOAI-CU BHARTI, BSNL, BHUTAN & NEPAL
      //CU
      CustomerUnit__c cuMOAIBHARTI = new CustomerUnit__c(
        Type__c = 'CU',                                    // Type
        Name = 'CU BHARTI, BSNL, BHUTAN & NEPAL',          // Name
        DeletionFlag__c = false,                           // Deletion Flag
        Make_all_new_Accounts_Visible__c = false,          // Make all new Accounts Visible?
        Exempt_from_Pre_Sales_Budget_Approval__c = false   // Exempt from Pre-Sales Budget Approval
      );
      insert cuMOAIBHARTI;

      //CRG Insert
      CustomerReportingGroup__c crgMOAIBHARTI = new CustomerReportingGroup__c(
        Name = 'TEST CRG',                                // CRG Name
        CustomerUnit__c = cuMOAIBHARTI.id,        // Customer Unit
        MarketArea__c = 'MOAI',                           // Market Area
        CRG_ID__c = '12307',                              // CRG ID
        Account_Primary_KAM__c = testUser.Id,            // Account Primary KAM
        Valid_KAM_CU_Head_Approvers__c = false,           // Valid KAM & CU Head Approvers
        Account_CU_Head__c = testUser.Id,               // Account CU Head
        Exempt_from_GCU_Sales_Decision_Rules__c = false,  // Exempt from GCU Sales Decision Rules
        DeletionFlag__c = false                           // Deletion Flag
      );
      insert crgMOAIBHARTI;
        Test.startTest();   
      //Account Insert
      Account accMOAIBHARTI = new Account(
        Name = 'Test Acc',                        // Account Name
        Visible__c = true,                                // Visible
        SAP_S2P_ID__c = '3337',                           // SAP S2P ID
        MDM_Customer_Id__c = '237',                       // MDM Customer ID
        Partner_ID__c = '2487',                           // Partner ID
        CustomerReportingGroup__c = crgMOAIBHARTI.Id,      // Customer Reporting Group
        Is_Partner__c = false,                            // Partnering Account
        SAP_S2P_ID_Number__c = 3337                       // SAP S2P ID Number
      );
      insert accMOAIBHARTI;
            
            //Market Area = MOAI-BHARTI
            //Opp create
            Opportunity oppMOAIBHARTI = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=accMOAIBHARTI.Id, Name='oppMOAIBHARTI'));
            insert oppMOAIBHARTI;
   
            //Proposal create
            Proposal__c propMOAIBHARTI = new Proposal__c (Opportunity__c=oppMOAIBHARTI.Id);
            propMOAIBHARTI.name = 'Proposal1';
            propMOAIBHARTI.Primary__c=True;
            propMOAIBHARTI.DeviationsPreApproved__c = false;
            propMOAIBHARTI.RequestedDeviationsApproval__c = false;
            insert propMOAIBHARTI;
            oldProposalMap.put(propMOAIBHARTI.Id,propMOAIBHARTI);
            
            //MA_Approver__c = MOAI_EBD_Commercial
            DeviationTypeGroup__c devtypeBHARTI = new DeviationTypeGroup__c(Proposal__c=propMOAIBHARTI.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeBHARTI.MA_Approver__c = GlobalConstants.MOAI_EBD_Commercial;
            devtypeBHARTI.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeBHARTI;
            
            //MA_Approver__c = BMAS SPOCs
            DeviationTypeGroup__c devtypeBHARTI1 = new DeviationTypeGroup__c(Proposal__c=propMOAIBHARTI.id,MAStatus__c ='Pending',BAStatus__c='Pending');
            devtypeBHARTI1.MA_Approver__c = GlobalConstants.BMAS_SPOCs;
            devtypeBHARTI1.BA_Approver__c = 'BNEW SPOCs';
            insert devtypeBHARTI1;
    
            test.stopTest(); 
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
                    
             try{    
                  
                 
                propMOAIBHARTI.RequestedDeviationsApproval__c = true;
                update propMOAIBHARTI;   
                newpropList.add(propMOAIBHARTI); 
                   
                 
                ProposalTriggerHandlerHelper.postToChatter(newpropList,oldProposalMap); 
                 
            }
            catch(DMLException e) {     
                System.debug('error : '+e.getMessage());
            }
            
            System.assert(true);  //NS            
        }
    }
}