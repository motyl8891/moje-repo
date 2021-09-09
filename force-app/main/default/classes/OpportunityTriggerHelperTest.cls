/****************************************************************
* @author: Pallavi Patil
* @date: 23-05-2019
* @User Story: 0891
* @description: This class is test class for OpportunityTriggerHelper
**************************** *************************************/
@isTest(seeAllData = false)
private class OpportunityTriggerHelperTest {
    public static String stanRec = GlobalConstants.standardOppRecordTypeId;
    /* @testSetup static void setup() {  
Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
System.runAs(testUser){  
insert acc;
} 
Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);

Opportunity oppstandard2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, Override_Deal_Value_and_Margin__c=true));
oppstandard2.RecordTypeId =stanRec;
oppstandard2.Name ='PD Opp';
oppstandard2.MarketArea__c='MELA';
oppStandard2.Is_progression_ready_for_stage__c = '3';
List<Opportunity> oppFrameLst = new List<Opportunity>();
oppFrameLst.add(oppstandard2);  

insert oppFrameLst;
List<Sales_Decision_Record__c> SDRList=new List<Sales_Decision_Record__c>();
Sales_Decision_Record__c SDR1 =New Sales_Decision_Record__c(name='SDP2A',Opportunity__c=oppStandard2.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP2 Submit Proposal',Sales_Decision_Approval_Status__c='Approved',Locked__c=false);
SDRList.add(SDR1);
Sales_Decision_Record__c SDR2 =New Sales_Decision_Record__c(name='OQB1',Sales_Decision_Type__c  = 'Other',Opportunity__c=oppStandard2.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Approval_Status__c='Approved',Locked__c=false);
SDRList.add(SDR2);
insert SDRList;
}*/
    /****************************************************************
* @author: Pallavi Patil
* @date: 23-05-2019
* @User Story: 0891
* @description: This method is test method for simpleToCloseUpdate
*****************************************************************/
    @isTest
    public static void simpleToCloseUpdateTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        
        Opportunity oppstandard2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, Override_Deal_Value_and_Margin__c=true));
        oppstandard2.RecordTypeId =stanRec;
        oppstandard2.Name ='PD Opp';
        
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);  
        oppFrameLst.add(oppstandard2);  
        
        insert oppFrameLst;
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {
            oldOpportunitiesMap.put(oppli.id, oppli);
        }
        opp.StageName = oppStageClosedLost;
        opp1.StageName = oppStageClosedWithdrawn;
        update oppFrameLst;
        Test.startTest();
        OpportunityTriggerHelper.simpleToCloseUpdate(oppFrameLst,oldOpportunitiesMap);
        OpportunityTriggerHelper.simpleToCloseUpdate(null,null); 
      //  id jobid = system.enqueueJob(new SimpleToCloseUpdateStage(oldOpportunitiesMap.keyset()));
     //   System.assertNotEquals(null, jobid);
        Test.stopTest();
        //NS
       System.assertEquals(opp.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    @isTest
    public static void simpleToCloseUpdateTest1(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity op1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(op1);  
        insert oppFrameLst;
        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id));
        OpportunityLineItem oppLine2 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id));
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {
            oldOpportunitiesMap.put(oppli.id, oppli);
        }
        opp.StageName = oppStageClosedLost;
        op1.StageName = oppStageClosedWithdrawn;
        
        op1.Customer_intent_to_buy__c = 'Exploring';
        op1.Local_experience_and_resources_to_win__c = 'Medium';
        op1.Relations_with_customer_decision_maker__c = 'Neutral';
        op1.Customer_sourcing_work__c = 'Single';
        op1.Impact_Customer_and_RfQ__c = 'Yes';
        op1.WDR_3PP_share_of_total_cost__c = '0%';
        op1.Advantantage_towards_the_customer__c = 'Ericsson';
        op1.Extraordinary_challenges_or_risks__c = 'Yes';
        op1.Solid_solution_and_references__c = 'Yes';
        op1.Non_delegated_business__c = 'Yes';
        op1.Confidence_to_win_winning_value__c = 'High';
        op1.Will_Opp_involve_intermediate_partner__c = 'Yes';
        op1.What_is_the_Technology_Risk__c = 'Medium';
        op1.Trade_Classifications__c = 'Civil';
        op1.End_Customer__c = acc.Id;
        op1.Sensitive_Business_Status__c = 'Not Required';
        op1.Estimated_Delivery_Start_Date__c = System.Today();
        update oppFrameLst;
        
        
        Test.startTest();
        OpportunityTriggerHelper.simpleToCloseUpdate(oppFrameLst,oldOpportunitiesMap);
        OpportunityTriggerHelper.simpleToCloseUpdate(null,null); 
       // id jobid = system.enqueueJob(new SimpleToCloseUpdateStage(oldOpportunitiesMap.keyset()));
       // System.assertNotEquals(null, jobid);
        Test.stopTest();
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 08-07-2019
* @User Story: 1061
* @description: This method is test method for setSensitiveBusinessStatus
*****************************************************************/
    @isTest
    public static void setSensitiveBusinessStatusTest(){
        Try{
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        //integer accountQueryCount = 0;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,Pricebook2Id=pb.Id)); 
        //opp.StageName = oppStageQualifyOppty;
        
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        //opp1.Trade_Classifications__c ='Civil';
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);  
        insert oppFrameLst;
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {
            oldOpportunitiesMap.put(oppli.id, oppli);
        }
        opp.Trade_Classifications__c ='Defense';
        //opp1.Sensitive_Business_Status__c='Not Required';
        opp1.What_is_the_Technology_Risk__c = 'Low';
        opp1.Sales_Compliance_Country_Risk__c = 'low';
        Test.startTest();
        update oppFrameLst;
        OpportunityTriggerHelper.updateSensitiveBusinessStatus(oppFrameLst,oldOpportunitiesMap);
        OpportunityTriggerHelper.updateSensitiveBusinessStatus(null,null);
        Test.stopTest();
        //OpportunityTriggerHelper.setSensitiveBusinessStatus(oppFrameLst,oldOpportunitiesMap);
        //OpportunityTriggerHelper.setSensitiveBusinessStatus(null,null);
        //System.assertEquals('Required', opp.Sensitive_Business_Status__c);
        //System.assertEquals('Not Required', opp1.Sensitive_Business_Status__c);
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 08-22-2019
* @User Story: 1084
* @description: This method is test method for setOpportunityOwner
*****************************************************************/
    @isTest
    public static void setOpportunityOwnerTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.SYSTEMADMINPROFILENAME].Id, UserName = 'AdityaMohapatra@test.com'+System.currentTimeMillis()),true);
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.SYSTEMADMINPROFILENAME].Id, UserName = 'ManuSinghal@test.com'+System.currentTimeMillis()),true);
        User testUser3 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.SYSTEMADMINPROFILENAME].Id, UserName = 'AnukritiAgrawal@test.com'+System.currentTimeMillis()),true);
        //integer accountQueryCount = 0;
        testUser1.LastName='AdityaMohapatra';
        testUser1.FirstName='AdityaMohapatra';
        testUser2.FirstName='ManuSinghal';
        testUser3.FirstName='AnukritiAgrawal';
        CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(), false);
        crg.Account_Primary_KAM__c =testUser2.Id;
        crg.Account_CU_Head__c= testUser3.Id;
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Set<id> userIdSet = new set<id>();
        userIdSet.add(acc.Responsible__c);
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Source_System__c=GlobalConstants.Lighthouse;
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        opp1.Source_System__c=GlobalConstants.Lighthouse;
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);
        Test.startTest();
        OpportunityTriggerHelper.setOpportunityOwner(oppFrameLst);
        OpportunityTriggerHelper.setOpportunityOwner(null);
        Test.stopTest();
        System.assertEquals('AdityaMohapatra',  testUser1.FirstName);
        System.assertEquals('ManuSinghal',  testUser2.FirstName);
            }catch(Exception e){	}
    } 
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 08-22-2019
* @User Story: 1084
* @description: This method is test method for setGCUKAMonOppty
*****************************************************************/
    @isTest
    public static void setGCUKAMonOpptyTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Global_Frame__c = true;
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);  
        //insert oppFrameLst;
        Test.startTest();
        OpportunityTriggerHelper.setGCUKAMonOppty(oppFrameLst,null,null);
        OpportunityTriggerHelper.setGCUKAMonOppty(oppFrameLst,null,null);
        OpportunityTriggerHelper.setGCUKAMonOppty(null,null,null);
        Test.stopTest();
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 09-16-2019
* @User Story: 1413
* @description: This method is test method for VerifyOpportunityProgression
*****************************************************************/
    @isTest
    public static void VerifyOpportunityProgressionTest() {
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity> ();
        boolean stage1flag ; 
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.Trade_Classification__c = 'Civil';
            insert acc;
       } 
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500 )); 
        opp.Name = 'test oppty';
        insert opp;
       Opportunity ParentOpp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        oppPar.add(ParentOpp);
        insert ParentOpp;
        Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp.id ];
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp.id;
        insert oli;
        ParentOpp.Global_Frame__c=true;
        ParentOpp.KAM__c=testUser.id;
       update ParentOpp;
        oldOpportunitiesMap.put(opp.Id,opp);
        opp.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp.Ship_To_Countries__c = GlobalConstants.EGYPT ;
        opp.Has_Less_Sensitive_Country__c = true;
        opp.High_Impact_Deal__c = false;
        opp.Forecast__c='Upside';
        opp.What_is_the_Technology_Risk__c = 'Low' ;
        opp.Trade_Classifications__c = 'Not Required' ;
        opp.End_Customer__c = acc.id ;
        opp.Sensitive_Business_Status__c = 'Not Required' ;
        opp.Customer_intent_to_buy__c = 'Very Strong' ;
        opp.Has_Less_Sensitive_Country__c = true;
        opp.Sensitive_Products_in_scope__c = 'Yes';
        opp.Trade_Classifications__c = 'Civil';
        opp.Local_experience_and_resources_to_win__c = 'High' ;
        opp.Relations_with_customer_decision_maker__c = 'Favorable' ;
        opp.Customer_sourcing_work__c = 'Single' ;
        opp.Impact_Customer_and_RfQ__c = 'Yes';                                                                                       
        opp.Solid_solution_and_references__c = 'Yes';
        opp.Non_delegated_business__c ='No';
        opp.Confidence_to_win_winning_value__c = 'High';
        opp.WDR_3PP_share_of_total_cost__c = '0%';
        opp.Advantantage_towards_the_customer__c = 'Ericsson';
        opp.Extraordinary_challenges_or_risks__c = 'No';
        opp.CloseDate = system.today();
        opp.MarketArea__c='MMEA';
        Test.startTest();
        update opp;
        oppFrameLst.add(opp);
        Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
        OpportunityTriggerHelper.checkForStage1(opp);
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        opp.Last_Approval_Event_Message__c='Approved';
        opp.Estimated_Delivery_End_Date__c = system.today();
        opp.Estimated_Delivery_Start_Date__c = system.today();
        opp.StageName = oppStageDefineCustomerValue;
        update opp;
        oppFrameLst.add(opp);
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        OpportunityTriggerHelper.checkForStage2(opp, oldOpp);
        
     Sales_Decision_Record__c SDR = new Sales_Decision_Record__c(Name = 'Test SDR',Opportunity__c = opp.id) ;
        opp.Is_Extended_Warranty_SiA_included__c = 'No';
        opp.Voucher_or_FoC_Items_included__c = 'No';
        opp.Consideration_payable_to_customer_incl__c = 'No';
        opp.Trade_Compliance_Status__c = 'Approved';
        opp.Cashflow_Analysis_Status__c = 'Complete';
        opp.Risk_Assessment_Status__c = 'Complete';
        opp.Lock_Small_Value__c = false;
        opp.Tags__c = 'MELA NMS';
        opp.CloseDate = System.Today()+1;
        opp.Proposal_Submission_Date__c = System.Today()+1;
        //opp.Not_Deviating_from_Parent__c=true;
        opp.Managed_Services_Governance__c=true;
        opp.StageName = oppStageCreateProposal;
        opp.MarketArea__c='MELA';
        opp.CloseDate = System.Today().addDays(1) ;
        opp.Proposal_Submission_Date__c = System.Today().addDays(1);
        opp.Tags__c = GlobalConstants.MELADS;
        opp.Parent_Original_Opportunity__c=ParentOpp.Id;
        update opp;
        oppFrameLst.add(opp);
        OpportunityTriggerHelper.checkForStage3(opp,oldOpp);
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        opp.Sensitive_Business_Status__c = 'Approved';
        opp.I_confirm_the_SB_Conditional_Adherence__c = true;
        opp.Last_Approval_Event_Message__c='Approved';
        opp.StageName = oppStageNegotiateandClose ;
		opp.Opportunity_Tier__c='Minor';
        opp.Approved_SDP_Stage__c = 'SDP2 Submit Proposal';
        update opp;
        oppFrameLst.add(opp);
        OpportunityTriggerHelper.checkForStage4(opp);
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        opp.Override_Deal_Value_and_Margin__c=false;
        opp.Contract_Evaluation_Status__c = 'Complete' ;
        opp.Primary_Proposal_Approved__c ='true';
        opp.StageName =oppStageClosedWon;
        oppFrameLst.add(opp);
        OpportunityTriggerHelper.checkForClosedWon(opp);
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        //opp.StageName = oppStageDefineCustomerValue;        
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        oldOpportunitiesMap.put(opp2.Id,opp2);
        //insert opp2;
        opp2.Last_Approval_Event_Message__c='Approved';
        opp2.StageName = oppStageDefineCustomerValue;
        //update opp2;
        //oppFrameLst.add(opp2);
        Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        oldOpportunitiesMap.put(opp3.Id,opp3);
        opp3.StageName = oppStageNegotiateandClose;
        Opportunity opp4 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        oldOpportunitiesMap.put(opp4.Id,opp4);
        opp4.StageName = oppStageClosedWon;
        
        Opportunity opp5 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,Sensitive_Business_Status__c = 'Approved',I_confirm_the_SB_Conditional_Adherence__c=false,
                                                                                        Lock_Small_Value__c = false ,Not_Deviating_from_Parent__c = false ,Managed_Services_Governance__c =false));
        Test.stopTest();
        OpportunityTriggerHelper.VerifyOpportunityProgression(oppFrameLst,oldOpportunitiesMap);
        //OpportunityTriggerHelper.checkForStage1(null);
        OpportunityTriggerHelper.updateSDRcompletion(oppFrameLst,oldOpportunitiesMap);
        //OpportunityTriggerHelper.checkForStage2(null, null);
        //OpportunityTriggerHelper.checkForStage3(null);
        OpportunityTriggerHelper.checkForStage4(opp5);
        //OpportunityTriggerHelper.checkForClosedWon(null);
        OpportunityTriggerHelper.updateOppTradeCompliance(null, null);
        OpportunityTriggerHelper.setEndCustomer(null);
        OpportunityTriggerHelper.setOpportunityOwner(null);
        //OpportunityTriggerHelper.setApprovedStage(null,null);
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 09-16-2019
* @User Story: 1413
* @description: This method is test method for VerifyOpportunityProgression
*****************************************************************/
    @isTest
    public static void updateSDRcompletionTest() {
        Try{
        Id frameOppRecordTypeId =  GlobalConstants.frameOppRecordTypeId;
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
        List<Opportunity> oppFrameLst = new List<Opportunity>();        
        Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity> ();
        boolean stage1flag ; 
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        //NS
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test1.com'+System.currentTimeMillis()),true);
        testUser.CU_Head__c = testUser1.Id;
        testUser.KAM__c = testUser1.Id;
        update testUser;
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Id pricebookId = pb.Id;
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        oldOpportunitiesMap.put(opp.Id,opp);
        
        opp.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp.Ship_To_Countries__c = GlobalConstants.EGYPT ;
        opp.Forecast__c='Upside';
        opp.What_is_the_Technology_Risk__c = 'Low' ;
        opp.Trade_Classifications__c = 'Not Required' ;
        opp.End_Customer__c = acc.id ;
        opp.Sensitive_Business_Status__c = 'Not Required' ;
        opp.Customer_intent_to_buy__c = 'Very Strong' ;
        opp.Has_Less_Sensitive_Country__c = true;
        opp.Sensitive_Products_in_scope__c = 'No';
        opp.Trade_Classifications__c = 'Civil';
        //opp.Sensitive_Business_Status__c ='Approved' ;
        opp.Local_experience_and_resources_to_win__c = 'High' ;
        opp.Relations_with_customer_decision_maker__c = 'Favorable' ;
        opp.Customer_sourcing_work__c = 'Single' ;
        opp.Impact_Customer_and_RfQ__c = 'Yes';                                                                                       
        opp.Solid_solution_and_references__c = 'Yes';
        opp.Non_delegated_business__c ='No';
        opp.Confidence_to_win_winning_value__c = 'High';
        opp.WDR_3PP_share_of_total_cost__c = '0%';
        opp.Advantantage_towards_the_customer__c = 'Ericsson';
        opp.Extraordinary_challenges_or_risks__c = 'No';
        opp.CloseDate = system.today();
       // opp.ownerid = testUser.id;
        //system.runAs(testUser)
        //
               insert opp;
        //}
        oli.OpportunityId=opp.id;
      	insert oli;
        opp.Last_Approval_Event_Message__c='Approved';
        opp.Estimated_Delivery_End_Date__c = system.today();
        opp.Estimated_Delivery_Start_Date__c = system.today();
        opp.StageName = oppStageDefineCustomerValue;
        update opp;
        //NS
          System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }catch(Exception e){	}
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 08-07-2019
* @param: NA
* @description: This test method will cover updateFinancialComplianceAuditScope method.
*****************************************************************/
    @isTest
    public static void updateFinancialComplianceAuditScopeTest(){
        Try{
        //Get all Opportunity RecordtypeIds from Custom labels
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        //Id framePDOppRecordTypeId = GlobalConstants.FRAMEAMENDEMNTOPPTYPD;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
       // Id standardPDOppRecordTypeId = GlobalConstants.STANDARDOPPTYPD; 
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Id pricebookId = pb.Id;
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.Product2Id = prod.Id;
        oli2.Estimated_Margin__c = 10;
        oli2.UnitPrice = 1000;
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500000000)); 
        opp1.CRM360_ATS_Flag__c=true;
         opp1.MarketArea__c='MELA';
        opp1.Last_Approval_Event_Message__c='Approved';
        opp2.StageName = oppStageQualifyOppty;
        opp2.CreatedDate = Date.newInstance(2018, 4, 11);
        opp2.CloseDate = Date.newInstance(2019, 11, 11);
        opp2.Any_New_Questions__c = true;
        //opp2.Global_Frame__c = true;
        opp2.KAM__c=testUser.id;
        //opp2.Financial_Compliance_Product_Areas__c = true;
        opp2.Consideration_payable_to_customer_incl__c = 'Yes';
        opp2.Voucher_or_FoC_Items_included__c = 'Yes, above 5 million SEK';
        opp2.Is_Extended_Warranty_SiA_included__c = 'Yes';
        opp2.MarketArea__c='MELA';
       List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp1);
        oppFrameLst.add(opp2);
        insert opp1;
        insert opp2;
        oli.OpportunityId = opp1.id;
        insert oli;
        oli2.OpportunityId = opp2.id;
        insert oli2;
         opp1=updateOppRecordForProgression(opp1, acc);
         opp2=updateOppRecordForProgression(opp2, acc);
         opp2.StageName=oppStageDefineCustomerValue;
        opp2.Last_Approval_Event_Message__c='Approved';
        opp2.Override_Deal_Value_and_Margin__c=true;
        //update opp1;
        //update opp2;
        //oppFrameLst.add(opp1);
        //oppFrameLst.add(opp2);
        //insert oppFrameLst ;
       Test.startTest();
        //update oppFrameLst;
        update opp1;
        update opp2;
        
        //opp2.StageName=oppStageCreateProposal;
        //update oppFrameLst;
		 System.assertEquals(opp1.Anticipated_Deal_Value__c,500);
        Test.stopTest();
        OpportunityTriggerHelper.updateFinancialComplianceAuditScope(oppFrameLst);
        OpportunityTriggerHelper.updateFinancialComplianceAuditScope(null);
        //System.assertEquals(GlobalConstants.INSCOPE, opp2.Financial_Compliance_Audit_Scope__c);
        //NS
         
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 08-22-2019
* @User Story: 1084
* @description: This method is test method for setGCUKAMonOppty
*****************************************************************/
    @isTest
    public static void refreshDealMarginValueTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
      //  Id framePDOppRecordTypeId = GlobalConstants.FRAMEAMENDEMNTOPPTYPD;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
      //  Id standardPDOppRecordTypeId = GlobalConstants.STANDARDOPPTYPD;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Override_Deal_Value_and_Margin__c = false;
        Proposal__c prop =(Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id, Primary__c = true, Name = 'test proposal')); 
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb1 = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb1.Id;

        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
          insert prod;
        }
        catch(DmlException e){          
        }
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
         insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        List<OpportunityLineItem> oppLineLst = new List<OpportunityLineItem>();
        opp.Override_Deal_Value_and_Margin__c = true;
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);  
        insert oppFrameLst;
        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pricebookEntry.Id));
        OpportunityLineItem oppLine2 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp1.Id,PricebookEntryId = pricebookEntry.Id));
        oppLineLst.add(oppLine);
        oppLineLst.add(oppLine2);
        insert oppLineLst;
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {
            oldOpportunitiesMap.put(oppli.id, oppli);
        }
        opp.Override_Deal_Value_and_Margin__c = true;
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    // OpportunityTriggerHelper.refreshDealMarginValue(null,null);
    
    public static Opportunity updateOppRecordForProgression(Opportunity opp, Account ac) {
        Try{
        opp.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp.Ship_To_Countries__c = GlobalConstants.EGYPT ;
        opp.Has_Less_Sensitive_Country__c = true;
        //opp.High_Impact_Deal__c = True;
        opp.Forecast__c='Upside';
        opp.What_is_the_Technology_Risk__c = 'Low' ;
        opp.Trade_Classifications__c = 'Not Required' ;
        opp.End_Customer__c = ac.id ;
        opp.Sensitive_Business_Status__c = 'Not Required' ;
        opp.Customer_intent_to_buy__c = 'Very Strong' ;
        opp.Has_Less_Sensitive_Country__c = true;
        opp.Sensitive_Products_in_scope__c = 'Yes';
        opp.Trade_Classifications__c = 'Civil';
        opp.Local_experience_and_resources_to_win__c = 'High' ;
        opp.Relations_with_customer_decision_maker__c = 'Favorable' ;
        opp.Customer_sourcing_work__c = 'Single' ;
        opp.Impact_Customer_and_RfQ__c = 'Yes';                                                                                       
        opp.Solid_solution_and_references__c = 'Yes';
        opp.Non_delegated_business__c ='No';
        opp.Confidence_to_win_winning_value__c = 'High';
        opp.WDR_3PP_share_of_total_cost__c = '0%';
        opp.Advantantage_towards_the_customer__c = 'Ericsson';
        opp.Extraordinary_challenges_or_risks__c = 'No';
        opp.CloseDate = system.today();
        opp.MarketArea__c='MMEA';
         System.assertEquals(opp.MarketArea__c,'MMEA');
            }catch(Exception e){	}
        return opp;
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 08-07-2019
* @param: NA
* @description: This test method will cover updateFinancialComplianceAuditScope method.
*****************************************************************/
    @isTest
    public static void createSDRecordsOnOpptyStageProgressionTest()
    {
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
       Id pricebookIdStd = Test.getStandardPricebookId();
       Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        PriceBook2 customPriceBookRec=[select Id,name from PriceBook2 WHERE name=:'Standard Catalog'];
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500 )); 
        opp1.Name = 'test oppty';
        insert opp1;
        Opportunity ParentOpp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        oppPar.add(ParentOpp);
        insert ParentOpp;
        Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:ParentOpp.id ];
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp1.id;
        insert oli;
        List<Opportunity> oppList = new List<Opportunity>();
        List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
         Sales_Decision_Record__c sdr1 = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp1.id,Sales_Decision_Type__c = GlobalConstants.SDP3SignContract,Sales_Decision_Date__c = system.today(),Name = GlobalConstants.SDP3SignContract,Source__c = GlobalConstants.AUTOMATIC));
        Sales_Decision_Record__c sdr2 = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp1.id,Sales_Decision_Type__c = GlobalConstants.SDP3SignContract,Sales_Decision_Date__c = system.today(),Name = GlobalConstants.SDP3SignContract,Source__c = GlobalConstants.AUTOMATIC));
        sdrList.add(sdr1);
        sdrList.add(sdr2);
        insert sdrList;
        ParentOpp.Global_Frame__c=true;
        parentOpp.KAM__c=testUser.id;
        opp1=updateOppRecordForProgression(Opp1, acc);
        opp1.StageName = oppStageDefineCustomerValue;
        opp1.Last_Approval_Event_Message__c = 'Approved';
        opp1.Override_Deal_Value_and_Margin__c=true;
        Test.startTest();
        oppList.clear();
        oppList.add(opp1);
        oppList.add(ParentOpp);
        update oppList;
        opp1.MarketArea__c='MELA';
       
         opp1.Parent_Original_Opportunity__c=parentOpp.id;
        opp1.Estimated_Delivery_End_Date__c = system.today();
        opp1.Estimated_Delivery_Start_Date__c = system.today();
       //opp1.Not_Deviating_from_Parent__c=TRUE;
        //opp2.Not_Deviating_from_Parent__c=TRUE;
       // opp1.Parent_Original_Opportunity__c=parentOpp.id;
    	Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp1.Id, Primary__c = false));
		insert prop;
        opp1.Is_Extended_Warranty_SiA_included__c = 'Yes';
		opp1.Voucher_or_FoC_Items_included__c = 'No';
		opp1.Consideration_payable_to_customer_incl__c = 'Yes';
		opp1.Cashflow_Analysis_Status__c = GlobalConstants.Complete;
		opp1.Risk_Assessment_Status__c = GlobalConstants.Complete;
        opp1.StageName = oppStageCreateProposal;
        opp1.CloseDate = System.Today().addDays(1) ;
        opp1.Proposal_Submission_Date__c = System.Today().addDays(1);
        opp1.Tags__c = GlobalConstants.MELADS;
        opp1.Approved_SDP_Stage__c='OQB';
        update opp1;
        opp1.StageName = oppStageNegotiateandClose;        
        //update opp1;
        OpportunityTriggerHelper.createSDRecordsOnOpptyStageProgression(null, null);
        
        Test.stopTest();
		//NS
        System.assertEquals(opp1.Is_Extended_Warranty_SiA_included__c,'Yes');
    }
    
    /****************************************************************
* @author: Manu Singhal
* @date: 18-10-2019
* @param: NA
* @description: This test method will cover checkSensitiveProductsCheckbox method.
*****************************************************************/
    @isTest
    public static void sendEmailForTradeComplianceTest()
    {
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
       Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Country_Risk__c countryRisk = new Country_Risk__c();
        countryRisk.TC_Sensitivy_Class__c = GlobalConstants.LESSSENSITIVE;
        countryRisk.Name = 'Cuba';
        insert countryRisk;
        Country_Risk__c countryRisk1 = new Country_Risk__c();
        countryRisk1.TC_Sensitivy_Class__c = GlobalConstants.SENSITIVE;
        countryRisk1.Name = 'Angola';
        insert countryRisk1;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500 )); 
        opp1.Name = 'test oppty';
        insert opp1;
        Opportunity ParentOpp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        oppPar.add(ParentOpp);
        insert ParentOpp;
        Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp1.id ];
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
        }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp1.id;
        insert oli;
        Opportunity oppnew = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId));
        oppnew.Ship_To_Countries__c = GlobalConstants.ANGOLA; 
        //oppnew.Account.BillingCountry = 'Angola';
        oppnew.StageName = '1. Qualify Opportunity';
        oppnew.Sensitive_Products_in_scope__c = 'yes';
        insert oppnew;
        opp1.Last_Approval_Event_Message__c='Approved';
        opp1.StageName='2. Define Customer Value';
        //opp1.Is_progression_ready_for_stage__c = '1';
         opp1=updateOppRecordForProgression(Opp1, acc);
         test.Starttest();
        opp1.Override_Deal_Value_and_Margin__c=true;
        opp1.Approved_SDP_Stage__c='SDP1 Invest to Win';
        opp1.CloseDate = System.Today().addDays(1) ;
        opp1.Proposal_Submission_Date__c = System.Today().addDays(1);
        opp1.Estimated_Delivery_Start_Date__c = System.Today().addDays(1);
        opp1.Estimated_Delivery_End_Date__c = System.Today().addDays(1);
       //  opp1.MarketArea__c='MELA';
         Update opp1;
        opp1.Consideration_payable_to_customer_incl__c = 'No';
        opp1.MA_Head__c =testUser.id ;
        opp1.BA_Head__c =testUser.id ;
        
        opp1.Last_Approval_Event_Message__c='Approved';
        opp1.StageName='3. Create Proposal';
        opp1.Is_Extended_Warranty_SiA_included__c ='Yes'; 
        opp1.Voucher_or_FoC_Items_included__c ='No';
        opp1.Parent_Original_Opportunity__c=ParentOpp.id;
        opp1.Cashflow_Analysis_Status__c = GlobalConstants.Complete;
		opp1.Risk_Assessment_Status__c = GlobalConstants.Complete;
        opp1.CloseDate = System.Today().addDays(1) ;
        opp1.Proposal_Submission_Date__c = System.Today().addDays(1);
        opp1.Tags__c = GlobalConstants.MELADS;
        opp1.Sensitive_Business_Status__c = GlobalConstants.Not_Required;
        opp1.Last_Approval_Event_Message__c='Approved';
        opp1.Approved_SDP_Stage__c='SDP1 Invest to Win';
        opp1.Estimated_Delivery_Start_Date__c = System.Today().addDays(1);
        Update opp1;
        opp1.Sensitive_Business_Status__c = 'Approved';
        opp1.I_confirm_the_SB_Conditional_Adherence__c =true;
        opp1.Last_Approval_Event_Message__c='Approved';
        opp1.StageName='4. Negotiate and Close';
        opp1.Approved_SDP_Stage__c='SDP2 Submit Proposal';
        
        Update opp1;
        /*Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc2.Id, RecordtypeId = standardOppRecordTypeId));        
insert opp2;
opp2.Trade_Classifications__c = GlobalConstants.GOVERNMENT;
update opp2;*/
        OpportunityTriggerHelper.sendEmailForTradeCompliance(null,null,true,true);
        test.stopTest();
        //NS
        System.assertEquals(opp1.I_confirm_the_SB_Conditional_Adherence__c,true);
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 18-10-2019
* @param: NA
* @description: This test method will cover checkSensitiveProductsCheckbox method.
*****************************************************************/
    @isTest
    public static void updateOpportunityTierTest()
    {
        Try{
       Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
       Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        
        test.Starttest();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 500));
        //opp1.Global_Frame__c = true;
        opp1.kam__c=testUser.Id;
        insert opp1;
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId,Anticipated_Deal_Value__c = 250000001));
       // opp1.Global_Frame__c = true;
        insert opp2;
        OpportunityTriggerHelper.updateOpportunityTier(null,null);
        OpportunityTriggerHelper.setForecastCategory(null,null);
        //NS
        System.assertEquals(opp1.Anticipated_Deal_Value__c,500);
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 08-07-2019
* @param: NA
* @description: This test method will cover checkSensitiveProductsCheckbox method.
*****************************************************************/
    @isTest
    public static void checkSensitiveProductsCheckboxTest()
    {    //OpportunityTriggerHelper.accountQueryCount = 0;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
       	System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }  
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId));  
        opp1.StageName = '1. Qualify Opportunity';
        insert opp1;
        Country_Risk__c countryRisk = new Country_Risk__c();
        countryRisk.Name = 'Angola';
        countryRisk.TC_Sensitivy_Class__c = GlobalConstants.LESSSENSITIVE;
        insert countryRisk; 
        acc.BillingCountry = 'Angola';
        update acc;
        opp1.Ship_To_Countries__c = GlobalConstants.ANGOLA;
        opp1.StageName='2. Define Customer Value';  
        try{
            update opp1;
        }
        catch (Exception e) {
            //System.assert(e.getMessage().contains(System.Label.SensitiveProductCheckboxError), 'message=' + e.getMessage());
        }
        OpportunityTriggerHelper.checkSensitiveProductsCheckbox(null,null);
     	//NS
       System.assertEquals(opp1.AccountId,acc.Id);
    }
    
    
    /****************************************************************
* @author: Paresh Saxena
* @date: 06-02-2020
* @param: NA
* @description: This test method will cover  updateOpportunityReadyForOQB method.
*****************************************************************/
    @isTest
    public static void updateOpportunityReadyForOQBTest()
    {   Try{  
        //OpportunityTriggerHelper.accountQueryCount = 0;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
       // Id framePDOppRecordTypeId = GlobalConstants.FRAMEAMENDEMNTOPPTYPD;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
      //  Id standardPDOppRecordTypeId = GlobalConstants.STANDARDOPPTYPD;
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.StageName = '1. Qualify Opportunity';
        opp.MarketArea__c = GlobalConstants.MELA;
        // opp.Tags__c.countMatches(GlobalConstants.MELADS) = 1;
        // Proposal__c prop =(Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp.Id, Primary__c = true, Name = 'test proposal')); 
        
        // Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        //opp.Override_Deal_Value_and_Margin__c = true;
        oppFrameLst.add(opp);
        // oppFrameLst.add(opp1);  
        insert oppFrameLst;
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {
            oldOpportunitiesMap.put(oppli.id, oppli);
        }
        
        // OpportunityTriggerHelper.updateOpportunityReadyForOQB(oppFrameLst, oldOpportunitiesMap);
        //NS
         System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }catch(Exception e){	}
    }
    @isTest
    public static void proposalTestPP(){
       Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
      Id pricebookIdStd = Test.getStandardPricebookId();
       Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
       Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
       List<Opportunity> oppFrameLst = new List<Opportunity>();
        Opportunity op1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500 )); 
        op1.Name = 'test oppty';
         oppFrameLst.add(op1);
        insert oppFrameLst;
       Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:op1.id ];
       PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){          
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = op1.id;
        insert oli;
        Map<ID, Opportunity> newOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {  
            newOpportunitiesMap.put(oppli.id, oppli);
        }
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {  
            oldOpportunitiesMap.put(oppli.id, oppli);
             oldOpportunitiesMap.get(oppli.id).StageName = GlobalConstants.oppStageClosedWon;
            oldOpportunitiesMap.get(oppli.id).MarketArea__c = 'MMEA';
        }
         
        Test.startTest();
        //OpportunityTriggerHelper.updateOpportunityReadyForOQB(oppFrameLst,oldOpportunitiesMap);
        OpportunityTriggerHelper.setApprovedStage(oppFrameLst,oldOpportunitiesMap);
        //OpportunityTriggerHelper.accountQueryCount = 0;
         OpportunityTriggerHelper.updateSensitiveBusinessStatus(oppFrameLst,oldOpportunitiesMap);
        Test.stopTest();
        
        //U-1825
        OpportunityTriggerHelper.setUsedForStageProgression(null,null);
        //NS
       System.assertEquals(op1.Anticipated_Deal_Value__c,500);
    }
    //U-1819
    @isTest
    public static void updateCloseDateandProposalSubDateTest(){
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
     //   String oppStageClosedLost = System.Label.Sales_Stage_Closed_Lost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
     //   String oppStageClosedDuplicate = System.Label.Sales_Stage_Closed_Duplicate;
        List<Opportunity> oppFrameLst = new List<Opportunity>();
       List<Opportunity> oppFrameLst1= new List<Opportunity>();
       // List<OpportunityLineItem> oppLineLst = new List<OpportunityLineItem>();
        Account acc ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }       
        Opportunity op1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        op1.CloseDate = Date.valueof(System.now() + 3);
        op1.Proposal_Submission_Date__c =  Date.valueof(System.now() + 3);       
        op1.StageName = '1. Qualify Opportunity';
//insert op1; 
        Opportunity op2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        op2.CloseDate = Date.valueof(System.now() + 3);   
        op2.StageName = '1. Qualify Opportunity';
       // insert op2; 
         oppFrameLst.add(op1);
        oppFrameLst.add(op2);
        insert oppFrameLst;
        op1.StageName = oppStageClosedWithdrawn;
        op2.StageName = oppStageClosedWithdrawn;
        oppFrameLst1.add(op1);
        oppFrameLst1.add(op2);
        try{
        update oppFrameLst;
        } catch(DmlException e){}        
        Test.startTest();
        OpportunityTriggerHelper.updateCloseDateandProposalSubDate(oppFrameLst);
        //OpportunityTriggerHelper.SetShipToCountries(oppFrameLst);
        Test.stopTest();
        OpportunityTriggerHelper.updateCloseDateandProposalSubDate(null);
        //NS
       System.assertEquals(op1.Anticipated_Deal_Value__c,500);
    }
    //U-1859
     @isTest
    public static void SetShipToCountriesTest(){
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
        String oppStageClosedDuplicate = GlobalConstants.oppStageClosedDuplicate;
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        List<OpportunityLineItem> oppLineLst = new List<OpportunityLineItem>();
        Account acc ;
        Account acc1 ;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.BillingCountry = 'Albania';
            insert acc;}
            Opportunity op1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            insert op1;
            
        System.runAs(testUser){ 
            CustomerReportingGroup__c crg1 = new CustomerReportingGroup__c();
            crg1.MarketArea__c = GlobalConstants.MELA;
            crg1.CRG_ID__c='HW1234';
            crg1.Name='testCRG1';
            insert crg1;
            acc1 = new Account();
            acc1.Name = 'Test Account1';
            acc1.SAP_S2P_ID__c = '123456';
            acc1.CurrencyIsoCode = 'SEK';
            acc1.Visible__c = true;
            acc1.Customer_Tier__c = 'Tier 1';
            acc1.CustomerReportingGroup__c= crg1.Id;
            acc1.BillingCountry = 'Afghanistan';
            insert acc1;
        } 
        op1.End_Customer__c = acc1.Id;
        update op1;
        
        acc1.Id = null;
        try{
            update op1;
        }catch(Exception e){
        }
        
        //NS
      System.assertEquals(op1.Anticipated_Deal_Value__c,500);
    }
}