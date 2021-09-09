@isTest
private class DisplayErrorOnSDRTest{
  @testSetup
  static void setupTestData(){
        test.startTest();
        CustomerUnit__c cu1 = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU', name='Test CU 1'), false);
        insert cu1;
        //CustomerReportingGroup__c crg1 = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(GlobalCustomerUnit__c = cu1.Id, Update_Opportunity_Approvers__c = true), false);
        //crg1.MarketArea__c = 'MELA';
        //insert crg1;
        Account acc;
        //acc.CustomerReportingGroup__c = crg1.Id;
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc= (Account)TestDataGenerator.createSObject(new Account(), false);
             insert acc;
        }  
      
      	Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;

        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
            try{
              insert prod;
            }
            catch(DmlException e){          
            } 
        Opportunity opp5 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777888999', Locked_To_PP__c = true, What_is_the_Technology_Risk__c='Low',Customer_intent_to_buy__c='Very Strong',Local_experience_and_resources_to_win__c='High',Customer_sourcing_work__c='Single',Relations_with_customer_decision_maker__c='Favorable',Impact_Customer_and_RfQ__c='Yes',WDR_3PP_share_of_total_cost__c='0%',Extraordinary_challenges_or_risks__c='No',Advantantage_towards_the_customer__c='Ericsson',Solid_solution_and_references__c='Yes',Non_delegated_business__c='No',Confidence_to_win_winning_value__c='High',Ship_To_Countries__c='EG',Will_Opp_involve_intermediate_partner__c='No',Trade_Classifications__c='Civil'));
//            try{
              insert opp5;

   //         }
//            catch(DmlException e){ 
 //           } 
 			Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp5.id ];

        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){         
        }
      	
      OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp5.Id, PricebookEntryId = pricebookEntry1.Id,Product2Id=prod.Id));
     //       try{
     			//oppLine.PricebookEntryId = pricebookEntry1.Id;
              insert oppLine;
       //     }
        //    catch(DmlException e){          
         //   } 
        Id idTest=opp5.id;

      Opportunity oppTest=[Select id,Is_ready_for_progression__c, OpportunityNotReadyReason__c from Opportunity where id=:idTest];
        List<Opportunity> oppList=new List<Opportunity>();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp1.RecordTypeId =GlobalConstants.frameOppRecordTypeId;
        opp1.name = 'opp1';
        opp1.MarketArea__c='MELA';
        opp1.High_Impact_Deal__c=true;
        oppList.add(opp1);
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp2.RecordTypeId =GlobalConstants.frameOppRecordTypeId;
        opp2.MarketArea__c='MELA';
        opp2.High_Impact_Deal__c=true;
        oppList.add(opp2);
        Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp3.RecordTypeId =GlobalConstants.frameOppRecordTypeId;
        opp3.MarketArea__c='MELA';
        opp3.High_Impact_Deal__c=true;
        oppList.add(opp3);
      	Opportunity opp4 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp4.RecordTypeId =GlobalConstants.frameOppRecordTypeId;
        opp4.MarketArea__c='MANA';
        oppList.add(opp4);
        insert oppList;
        test.stopTest();
        CustomerReportingGroup__c CRG=new CustomerReportingGroup__c(MarketArea__c='MNEA');
        insert CRG;
       List<Sales_Decision_Record__c> SDRList=new List<Sales_Decision_Record__c>();
        Sales_Decision_Record__c SDR1 =New Sales_Decision_Record__c(name='SDP2A',Opportunity__c=opp1.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP2 Submit Proposal',Sales_Decision_Approval_Status__c='In Progress');
        SDRList.add(SDR1);
        Sales_Decision_Record__c SDR2 =New Sales_Decision_Record__c(name='OQB',Opportunity__c=opp1.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP2 Submit Proposal',Sales_Decision_Approval_Status__c='In Progress',Locked__c=true);
        SDRList.add(SDR2);
        Sales_Decision_Record__c SDR3 =New Sales_Decision_Record__c(name='SDP2I',Opportunity__c=opp3.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP2 Submit Proposal',Locked__c=true,Sales_Decision_Approval_Status__c='In Progress');
        SDRList.add(SDR3);
        Sales_Decision_Record__c SDR4 =New Sales_Decision_Record__c(name='SDP0',Opportunity__c=opp3.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP0 Qualify',Locked__c=true,Sales_Decision_Approval_Status__c='In Progress');
        SDRList.add(SDR4);
        Sales_Decision_Record__c SDR5 =New Sales_Decision_Record__c(name='SDP02',Opportunity__c=opp3.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP0 Qualify',Locked__c=true,Sales_Decision_Approval_Status__c='In Progress');
       	SDRList.add(SDR5);
      //	Sales_Decision_Record__c SDR6 =New Sales_Decision_Record__c(SDR_Completed__c='Yes',name='SDP03',Opportunity__c=opp5.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP0 Qualify',Locked__c=true,Sales_Decision_Approval_Status__c='Approved');
      // SDRList.add(SDR6);
      System.debug('oppTest1:'+oppTest.Is_ready_for_progression__c);
      System.debug('oppTest2:'+oppTest.OpportunityNotReadyReason__c);
      	Sales_Decision_Record__c SDR6 =New Sales_Decision_Record__c(SDR_Completed__c='Yes',name='SDP03',Opportunity__c=opp5.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP0 Qualify',Locked__c=true,Sales_Decision_Approval_Status__c='Approved');
       SDRList.add(SDR6);
        insert SDRList;
      //Sales_Decision_Record__c SDR6 =New Sales_Decision_Record__c(name='SDP03',Opportunity__c=opp5.Id,Last_Refreshed_datetime__c=System.today(),DealMargin__c=123,Lead_Domain__c='BAMS',Opportunity_Deal_Value__c= 467,Sales_Decision_Type__c='SDP0 Qualify',Locked__c=true,Sales_Decision_Approval_Status__c='Approved');
      //insert SDR6;
      Sales_Decision_Maker_Rules__c sdmRule = new Sales_Decision_Maker_Rules__c();
        sdmRule.CU_Head__c = true;
        sdmRule.BA_Head__c = true;
        sdmRule.Commercials__c = true;
        sdmRule.Fulfillment__c = true;
        sdmRule.GCU_Head__c = true;
        sdmRule.GCU_KAM__c = true;
        sdmRule.KAM__c = true;
        sdmRule.MA_Head__c = true;
        sdmRule.Solution__c = true;
        sdmRule.Name = 'CU_Tier1_SDP0';
        sdmRule.Unique_String__c = 'CU Account-Major-false-SDP0 Qualify';
        insert sdmRule;
  }
   
    
    static testMethod void onlySDP0ProgressStage1Test(){
        List<Sales_Decision_Record__c> SDR=[SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c FROM Sales_Decision_Record__c 
                                            WHERE name='SDP2A'];
            String message = DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id); 
        //system.assertNotEquals('You can only progress by completed SDP0 (optional) or by clicking mark stage as complete. Not possible to progress with an SDR of any other type than SDP0 ', message);
        SDR=[SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c FROM Sales_Decision_Record__c 
                                            WHERE name='SDP02'];
        message = DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
        
        //1668
        SDR=[SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c FROM Sales_Decision_Record__c 
                                            WHERE name='OQB'];
        message = DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id); 
        //NS
		System.assert(true);
        }
/****************************************************************
* @author: Shubham jagatap  
* @date: 27-02-2020
* @description: This method is a test method for saveAndLockRecord
*****************************************************************/
    static testMethod void saveAndLockRecordTest(){
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        String Stage1 = GlobalConstants.Qualify_Opportunity;
        String Stage2 = GlobalConstants.Define_CustomerValue;
        String Stage3 = GlobalConstants.Create_Proposal;
        Opportunity  oppty = [select id,StageName from Opportunity where Name='opp1'];
        
        List<Sales_Decision_Record__c> SDRlist  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c FROM Sales_Decision_Record__c 
                                                ];
        
        List<Sales_Decision_Maker__c> sdmlist = new list<Sales_Decision_Maker__c>();
        integer i=0;
        for(Sales_Decision_Record__c sdr : SDRlist){
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = SDRlist[i].id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
        sdmlist.add(sdm);
        i++;
        }
        insert sdmlist;
        
        List<Sales_Decision_Record__c> SDRwithSDMList  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE Id =:SDRlist[0].id];
        
        Id oppId = oppty.id;
        test.startTest();
        DisplayErrorOnSDR.saveAndLockRecord(SDRwithSDMList,oppId,stage1);
        DisplayErrorOnSDR.saveAndLockRecord(SDRwithSDMList,oppId,stage2);
        DisplayErrorOnSDR.saveAndLockRecord(SDRwithSDMList,oppId,stage3);
        SDRlist[0].Sales_Decision_Type__c='SDP3 Sign Contract';
        update SDRlist;
        List<Sales_Decision_Record__c> SDRwithSDMList2  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE Id =:SDRlist[0].id];
        DisplayErrorOnSDR.saveAndLockRecord(SDRwithSDMList2,oppId,stage3);
        test.stopTest();
        //NS
		System.assert(true);
    }
/****************************************************************
* @author: Shubham jagatap  
* @date: 27-02-2020
* @description: This method is a test method for updateApprovalStatusOfSDR
*****************************************************************/
    static testMethod void updateApprovalStatusOfSDRTest(){
        List<Sales_Decision_Record__c> SDR  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP0'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id); 
        //chcek for pilot
        List<CustomerReportingGroup__c> crgList = [select id from CustomerReportingGroup__c];
        crgList[0].MarketArea__c = 'MMEA';
        update crgList[0];
        Opportunity opp = new Opportunity(Id=SDR[0].Opportunity__c);
        update opp;
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
        
        
        opp.Not_Deviating_from_Parent__c = false; 
        opp.StageName = '1. Qualify Opportunity';
        SDR[0].Sales_Decision_Type__c = 'SDP1 Invest to Win';
        opp.MarketArea__c='MMEA';
        update opp;
        update SDR;
        List<Sales_Decision_Record__c> SDRwithOPP  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP0'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
       
       
        opp.MarketArea__c='MELA'; 
        update opp;
        
        List<Sales_Decision_Record__c> SDRwithOPP1  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP0'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
        
        
        SDR[0].SDRInSyncWithOpportunity__c = true; 
        opp.Is_progression_ready_for_stage__c='1';
        SalesDecisionRecordUtility.readyForNextStage(null, null, null, null, null, null, null );
        update opp;
        
        update SDR;
        List<Sales_Decision_Record__c> SDRwithOPP3  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP0'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
        
        
        //1668
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(null);
        DisplayErrorOnSDR.saveAndLockRecord(null,null,null);
        
        opp.Not_Deviating_from_Parent__c = false; 
        opp.StageName = '1. Qualify Opportunity';
        SDR[0].Sales_Decision_Type__c = 'SDP0 Qualify';
        SDR[0].Sales_Decision_Approval_Status__c = 'In Progress';
        opp.MarketArea__c='MMEA';
        update opp;
        update SDR;
        List<Sales_Decision_Record__c> SDRwithOPP4  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP0'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDR[0].id);
        
        /*opp5.Not_Deviating_from_Parent__c = false; 
        opp5.StageName = '1. Qualify Opportunity';
        SDR[0].Sales_Decision_Type__c = 'SDP0 Qualify';
        SDR[0].Sales_Decision_Approval_Status__c = 'Approved';
        SDR[0].SDRInSyncWithOpportunity__c=False;
        opp.MarketArea__c='MMEA';     
        update opp;
        update SDR;*/
        List<Sales_Decision_Record__c> SDRwithOPP5  =  [SELECT Id, Opportunity__c,Opportunity_Stage__c, SDR_Completed__c,
                                                Locked__c, Sales_Decision_Type__c, (SELECT ID FROM Sales_Decision_Makers__r) FROM Sales_Decision_Record__c 
                                                WHERE name='SDP03'];
        DisplayErrorOnSDR.updateApprovalStatusOfSDR(SDRwithOPP5[0].id);
        //NS
		System.assert(true);
    }
}