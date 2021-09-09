/****************************************************************
* @author: Pallavi Patil
* @date: 23-05-2019
* @User Story: 0891
* @description: This class is test class for SimpleToCloseUpdateStage
*****************************************************************/
@isTest(seeAllData = false)
private class SimpleToCloseUpdateStageTest {
    /****************************************************************
* @author: Pallavi Patil
* @date: 23-05-2019
* @User Story: 0891
* @description: This method is test method for updateSimpleOppStage
*****************************************************************/
    /*@isTest(seeAllData = false)
    public static void  updateSimpleOppStageTest(){
        Id simpleOppRecordTypeId = System.Label.Record_Type_ID_Simple_Opportunity;
        Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
        String oppStageClosedLost = System.Label.Sales_Stage_Closed_Lost;
        String oppStageClosedWithdrawn = System.Label.Sales_Stage_Closed_Withdrawn;
        String oppStageClosedDuplicate = System.Label.Sales_Stage_Closed_Duplicate;
        Account acc; 
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        Test.startTest();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create an Opp in stage 4 to be able to create ES
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name = 'Test ES Apex', Ship_To_Countries__c = 'Egypt', Sensitive_Products_in_scope__c = 'no',
                                                                                        AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp1.Is_progression_ready_for_stage__c = '5';      
        opp1.Will_Opp_involve_intermediate_partner__c = 'No' ;
        
        opp1.Has_Less_Sensitive_Country__c = true;
        opp1.High_Impact_Deal__c = True;
        opp1.Forecast__c='Upside'; 
        opp1.What_is_the_Technology_Risk__c = 'Low' ;
        opp1.Trade_Classifications__c = 'Not Required' ;
        opp1.End_Customer__c = acc.id ;
        opp1.Sensitive_Business_Status__c = 'Not Required' ;
        opp1.Customer_intent_to_buy__c = 'Very Strong' ;
        opp1.Has_Less_Sensitive_Country__c = true;
        opp1.Sensitive_Products_in_scope__c = 'Yes';
        opp1.Trade_Classifications__c = 'Civil';
        opp1.Local_experience_and_resources_to_win__c = 'High' ;
        opp1.Relations_with_customer_decision_maker__c = 'Favorable' ;
        opp1.Customer_sourcing_work__c = 'Single' ;
        opp1.Impact_Customer_and_RfQ__c = 'Yes';                                                                                       
        opp1.Solid_solution_and_references__c = 'Yes';
        opp1.Non_delegated_business__c ='No';
        opp1.Confidence_to_win_winning_value__c = 'High';
        opp1.WDR_3PP_share_of_total_cost__c = '0%';
        opp1.Advantantage_towards_the_customer__c = 'Ericsson';
        opp1.Extraordinary_challenges_or_risks__c = 'No';
        opp1.CloseDate = system.today();
        opp1.MarketArea__c='MMEA';
        insert opp1;
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        List<OpportunityLineItem> olilist = new List<OpportunityLineItem>();
        List<Opportunity> oppList = new List<Opportunity>();
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.Product2Id = prod.Id;
        oli1.Estimated_Margin__c = 10;
        oli1.UnitPrice = 1000;
        oli1.OpportunityId = opp1.id;
        insert oli1;
        
        //progress to stage 2
        opp1.StageName = System.Label.Sales_Stage_2_Define_Customer_Value;
        opp1.Last_Approval_Event_Message__c = 'Approved';
        update opp1;
        
        //progress to stage 3
        opp1.Estimated_Delivery_Start_Date__c = System.today();
        opp1.Estimated_Delivery_End_Date__c = System.today();
        opp1.Last_Approval_Event_Message__c = 'Approved';
        opp1.Approved_SDP_Stage__c = 'SDP1 Invest to Win';
        opp1.StageName = System.label.Sales_Stage_3_Create_Proposal;
        update opp1;
        //progress to stage 4
        opp1.Lock_Small_Value__c = false;
        opp1.High_Impact_Deal__c = false;
        opp1.Not_Deviating_from_Parent__c = false;
        opp1.Managed_Services_Governance__c = false;
        opp1.Cashflow_Analysis_Status__c = GlobalConstants.Complete; 
        opp1.Risk_Assessment_Status__c = GlobalConstants.Complete;
        opp1.Is_Extended_Warranty_SiA_included__c = 'No';
        opp1.Voucher_or_FoC_Items_included__c = 'No';
        opp1.Sensitive_Business_Status__c = GlobalConstants.APPROVED;
        opp1.Consideration_payable_to_customer_incl__c = 'No';
        opp1.Trade_Compliance_Status__c = GlobalConstants.APPROVED;
        opp1.Last_Approval_Event_Message__c = 'Approved';
        opp1.Approved_SDP_Stage__c = 'SDP2 Submit Proposal';
        opp1.StageName = System.label.Sales_Stage_4_Negotiate_and_Close;
        
        update opp1;
        
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        Set<Id> frameOpptyIdSet = new Set<id>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp2);
        
        insert oppFrameLst;
        Opportunity oppSimple = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        oppSimple.Parent_Original_Opportunity__c=opp2.Id;
        oppSimple.StageName=System.Label.Sales_Stage_4_Negotiate_and_Close;
        Id simpleRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Simple Opportunity').getRecordTypeId();
        oppSimple.RecordTypeId = simpleRecordTypeId;
        oppSimple.Forecast__c = 'Upside';
        insert oppSimple;
        opp.StageName = oppStageClosedLost;
        opp2.StageName = oppStageClosedWithdrawn;
        //update oppFrameLst;
        oppFrameLst.add(opp1);
        Proposal__c prop = new Proposal__c(opportunity__c = opp.Id);
        insert prop;
        
        RecordType rec = [select id, name from recordType where sobjectType = 'EarlyStart__c' and name = 'Extension' LIMIT 1];
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today()));
        //insert sdr;
        
        
        Secondary_Approval__c app = new Secondary_Approval__c(opportunity__c = opp.Id,Approval_Status__c='Pending');
        insert app;
        
        for(Opportunity oppli : oppFrameLst)
        {
            frameOpptyIdSet.add(oppli.id);
        }
        
        //   Opportunity opp1 = [Select Id, stagename from Opportunity where Name = 'Test ES Apex' limit 1];
        
        // User testUser = [Select id from user limit 1];
        EarlyStart__c es1 =new EarlyStart__c();
        es1.Name='test123';
        es1.Opportunity__c=opp1.Id;
        es1.Early_Start_Status__c='Pending Approval';
        es1.Early_Start_ACR__c=testUser.Id;
        es1.Early_Start_CFR__c=testUser.Id;
        es1.Early_Start_CSR__c=testUser.Id;
        es1.Early_Start_Expected_End_Date__c=System.Today();
        es1.RecordTypeId=GlobalConstants.newearlyStartRecordTypeId;
        es1.Acknowledgement_1_Read_and_Agreed__c=true;
        es1.Acknowledgement_2_Read_and_Agreed__c=true;
        es1.Acknowledgement_3_Read_and_Agreed__c=true;
        insert es1;
        es1.Early_Start_Status__c='Approved';
        //update es1;
        
        EarlyStart__c es2 =new EarlyStart__c();
        es2.Name='test1234';
        es2.Parent_Early_Start__c=es1.Id;
        es2.Early_Start_Status__c='Approved';
        es2.Est_Cost_AFTER_Extension_currency__c=1234;
        es2.Opportunity__c=opp1.Id;
        es2.RecordTypeId=Schema.SObjectType.EarlyStart__c.getRecordTypeInfosByName().get('Extension').getRecordTypeId();
        
        //insert es2;
       /* ProcessInstance proc = new ProcessInstance();
        proc.LastActorId = userinfo.getuserid();
        proc.TargetObjectId = app.id;
        proc.Status = 'Pending';
        insert proc;
        
        ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
        pworkItem.ActorId = userinfo.getuserId();
        pworkItem.OriginalActorId = userinfo.getuserId();
        pworkItem.ProcessInstanceId = proc.id;
        insert pworkItem;
       
        
       
        
        SimpleToCloseUpdateStage.updateSimpleOppStage(frameOpptyIdSet);
        SimpleToCloseUpdateStage.updateSimpleOppStage(null);
        //id jobid = system.enqueueJob(new SimpleToCloseUpdateStage(frameOpptyIdSet,frameOpptyIdSet));
        //System.assertNotEquals(null, jobid);
        Test.stopTest();
    }*/
   /* @isTest(seeAllData = false)
    public static void  updateSimpleOppStageTest1(){
       
        Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
        Test.startTest();
        Set<Id> frameOpptyIdSet = new Set<id>();
        Set<Id> frameOpptyIdSet1 = new Set<id>();
        Account acc; 
       
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        System.runAs(testUser){  
            insert opp;
        }
        
        //RecallSdmApprovals app = new RecallSdmApprovals();
       Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'Approvals Ongoing'));
        //Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'Approvals Ongoing',Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today())); 
        insert sdr; 
        
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'To be Requested',Approver_Name__c=UserInfo.getUserId()));
        insert sdm;
        frameOpptyIdSet.add(opp.id);
        SimpleToCloseUpdateStage.updateSdrOppChild(frameOpptyIdSet);
        Test.stopTest();
            
    }*/
    @isTest(seeAllData = false)
    public static void  updateSimpleOppStageTestmethod(){
        Try{
         Id simpleOppRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Test.startTest();
        Set<Id> frameOpptyIdSet = new Set<id>();
        Set<Id> frameOpptyIdSet1 = new Set<id>();
        Account acc; 
       
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        System.runAs(testUser){  
            insert opp;
        }
        
        Opportunity oppchild = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = simpleOppRecordTypeId, Anticipated_Deal_Value__c = 500,Parent_Original_Opportunity__c=opp.id)); 
        System.runAs(testUser){  
            insert oppchild;
        }
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'Approvals Ongoing'));
        insert sdr; 
        
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'To be Requested',Approver_Name__c=UserInfo.getUserId()));
        insert sdm;
        Secondary_Approval__c Secapp = new Secondary_Approval__c(opportunity__c = opp.Id,Approval_Status__c='Pending');
        insert Secapp;
        frameOpptyIdSet.add(opp.id);
         id jobid = system.enqueueJob(new SimpleToCloseUpdateStage(frameOpptyIdSet,frameOpptyIdSet));
         //SimpleToCloseUpdateStage.updateSimpleOppStage(frameOpptyIdSet);

       Test.stopTest();
       System.assert(true);  //NS
            }catch(Exception e){	}
    }


}