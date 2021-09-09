@isTest
public class EarlyStartHelperTest {
    @isTest
    public static void setApprovers1Test(){
        try{
     User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        Account acc;
        System.runAs(testUser){
            CustomerUnit__c cu = new CustomerUnit__c(Type__c = 'CU',name='testCu',EarlyStartApprovalValueLimit__c=100);
            insert cu;
            //cu.EarlyStartApprovalValueLimit__c=100;
            //update cu;
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c(CRG_ID__c='12345',Name='testCrg1',CustomerUnit__c=cu.id,MarketArea__c='MMEA');
            insert crg;
            List<EarlyStartApprover__c> esaList= new List<EarlyStartApprover__c>();
            EarlyStartApprover__c esa1= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.MAHeadorDelegate,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='High',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa2= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.CUSupplyHead,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa3= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.TradeFinanceHeadofCustomerFinance,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All' ,CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa4= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All' ,CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa5= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeManagedServices,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa6= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeDigital,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa7= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeEmergingBusIOT,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa8= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeNetworks,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa9= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other2,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa10= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other3,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            esaList.add(esa1);
            esaList.add(esa2);
            esaList.add(esa3);
            esaList.add(esa4);
            esaList.add(esa5);
            esaList.add(esa6);
            esaList.add(esa7);
            esaList.add(esa8);
            esaList.add(esa9);
            esaList.add(esa10);
            insert esaList;
            acc= new Account();
            acc.Name = 'Test1 Account';
            acc.SAP_S2P_ID__c=String.valueOf(1);
            acc.CurrencyIsoCode = 'SEK';
            acc.Visible__c = true;
            acc.Customer_Tier__c = 'Tier 1';
            acc.CustomerReportingGroup__c= crg.id;
            acc.Trade_Classification__c = 'Civil';
            acc.BillingCountryCode = 'AL';
            acc.SBSPilot__c = false;
            insert acc;
            system.debug('accis'+acc.CurrencyIsoCode);
        }  
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
       /* List<Opportunity> oppFrameLst = new List<Opportunity>();
        Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity> ();
        boolean stage1flag ; 
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
        }system.debug('till actch');
      OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Name = 'test oppty';
        oppPar.add(opp);
        insert oppPar;
        oli.OpportunityId = opp.id;
        insert oli;
            */
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Name = 'test oppty';
        insert opp;
        
        Opportunity ppp=[select id,PriceBook2Id from Opportunity where id=:opp.id ];
        
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        
       PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = ppp.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        try{
            insert pricebookEntry1;
        }
        catch(DmlException e){ 
            system.debug('**************Exception : '+e);
        }
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp.id;
        insert oli;	
        system.debug('check yse');
            EUFT__c eu = [Select id, Name, ExemptionKeys__c from EUFT__c where opportunity__c =: opp.Id];
            system.debug('euiserrr'+eu);
         opp.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp.ConfirmEndCustomer__c = false;
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
       opp.Last_Approval_Event_Message__c='Approved';
        opp.Estimated_Delivery_End_Date__c = system.today();
        opp.Estimated_Delivery_Start_Date__c = system.today();
        opp.StageName = oppStageDefineCustomerValue;
       // opp.Is_progression_ready_for_stage__c='1';
         Test.startTest();
         update opp;
         system.debug('updated opp till 23satg');
        Sales_Decision_Record__c SDR = new Sales_Decision_Record__c(Name = 'Test SDR',Opportunity__c = opp.id) ;
        insert SDR;
        opp.Is_Extended_Warranty_SiA_included__c = 'No';
        opp.Voucher_or_FoC_Items_included__c = 'No';
        opp.Consideration_payable_to_customer_incl__c = 'No';
        opp.Trade_Compliance_Status__c = 'Approved';
        opp.Cashflow_Analysis_Status__c = 'Complete';
        opp.Risk_Assessment_Status__c = 'Complete';
        opp.Lock_Small_Value__c = false;
        opp.Tags__c = 'MELA NMS';
        opp.CloseDate = System.Today();
        opp.Proposal_Submission_Date__c = System.Today();
        //opp.Not_Deviating_from_Parent__c=true;
        opp.Managed_Services_Governance__c=true;
        opp.StageName = oppStageCreateProposal;
        opp.MarketArea__c='MELA';
        opp.CloseDate = System.Today();
        opp.Proposal_Submission_Date__c = System.Today();
        opp.Tags__c = GlobalConstants.MELADS;
        update opp; 
         opp.Sensitive_Business_Status__c = 'Approved';
        opp.I_confirm_the_SB_Conditional_Adherence__c = true;
        opp.Last_Approval_Event_Message__c='Approved';
        opp.Opportunity_Tier__c='Minor';
        opp.Approved_SDP_Stage__c = 'SDP2 Submit Proposal';    
        opp.StageName = oppStageNegotiateandClose ;
        update opp;
        Opportunity opp1=[select id,stageName from Opportunity];
        system.debug('upadted opp'+opp1.StageName);
        EarlyStart__c es1 =new EarlyStart__c();
            es1.RecordTypeId = GlobalConstants.newearlyStartRecordTypeId;
            es1.Name='test123';
            es1.Opportunity__c=opp1.Id;
            es1.Early_Start_Status__c='New/Created';
            es1.Early_Start_ACR__c=testUser.Id;
            es1.Early_Start_CFR__c=testUser.Id;
            es1.Early_Start_CSR__c=testUser.Id;
            es1.Early_Start_Status__c='Approved';
            es1.Early_Start_Expected_End_Date__c=System.Today();
            es1.Estimated_Cost_for_Early_Start_Scope__c=10;
            es1.Commodities__c=GlobalConstants.Hardware;
            //es1.Reason_for_Early_Start__c=GlobalConstants.LetterofCredit;
            es1.Reason_for_Early_Start__c=GlobalConstants.LetterofCredit+';'+'Missing terms and conditions for billing and payment (e.g. legal agreement not yet signed)';
            es1.BAPartofEarlyStartScope__c=GlobalConstants.BDGS+';'+GlobalConstants.BMAS+';'+GlobalConstants.BNEW+';'+GlobalConstants.BTEB;
            es1.Scope_of_Early_Start__c='Only Planning';
            es1.Early_Start_Degree__c='D. Installation of HW/SW';
            es1.BoQ_with_Delivery_Objects_Attachments__c='Something';
            es1.CurrencyIsoCode='SEK';
            insert es1;
            test.stopTest();
            es1.Reason_for_Early_Start__c=GlobalConstants.LetterofCredit;
            update es1;
            /*EarlyStart__c es3 =new EarlyStart__c();
           es3.Name='test1234';
           es3.Parent_Early_Start__c=es1.Id;
           es3.Early_Start_Status__c='New/Created';
           es3.RecordTypeId = GlobalConstants.extensionRecordTypeId;
            es3.Opportunity__c=opp1.id;
            insert es3;*/
           EarlyStartHelper.setApprovers(null,null,null);
		   System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }
        catch(Exception e){
            system.debug('exception'+e);
        }
    }
     @isTest
    public static void updateParentOppOnCreationTest(){
        try{
     User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
     User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            Account acc;
        System.runAs(testUser){
            CustomerUnit__c cu = new CustomerUnit__c(Type__c = 'CU',name='testCu',EarlyStartApprovalValueLimit__c=100);
            insert cu;
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c(CRG_ID__c='12345',Name='testCrg1',CustomerUnit__c=cu.id,MarketArea__c='MMEA');
            insert crg;
            List<EarlyStartApprover__c> esaList= new List<EarlyStartApprover__c>();
            EarlyStartApprover__c esa1= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.MAHeadorDelegate,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='High',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa2= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.CUSupplyHead,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa3= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.TradeFinanceHeadofCustomerFinance,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All' ,CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa4= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All' ,CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa5= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeManagedServices,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa6= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeDigital,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa7= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeEmergingBusIOT,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa8= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.BARepresentativeNetworks,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa9= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other2,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            EarlyStartApprover__c esa10= new EarlyStartApprover__c(ApproverName__c=testUser.id,ApproverRole__c=GlobalConstants.Other3,CustomerUnit__c=cu.id,EarlyStartApprovalThresholdLevel__c='All',CurrencyIsoCode='ALL');
            esaList.add(esa1);
            esaList.add(esa2);
            esaList.add(esa3);
            esaList.add(esa4);
            esaList.add(esa5);
            esaList.add(esa6);
            esaList.add(esa7);
            esaList.add(esa8);
            esaList.add(esa9);
            esaList.add(esa10);
            insert esaList;
            acc= new Account();
            acc.Name = 'Test1 Account';
            acc.SAP_S2P_ID__c=String.valueOf(1);
            acc.CurrencyIsoCode = 'SEK';
            acc.Visible__c = true;
            acc.Customer_Tier__c = 'Tier 1';
            acc.CustomerReportingGroup__c= crg.id;
            acc.Trade_Classification__c = 'Civil';
            acc.BillingCountryCode = 'AL';
            acc.SBSPilot__c = false;
            insert acc;
            system.debug('accis'+acc.CurrencyIsoCode);
        }  
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
       /* List<Opportunity> oppFrameLst = new List<Opportunity>();
        Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity> ();
        boolean stage1flag ; 
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
        }system.debug('till actch');
      OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Name = 'test oppty';
        oppPar.add(opp);
        insert oppPar;
        oli.OpportunityId = opp.id;
        insert oli;
        */
            
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Name = 'test oppty';
        insert opp;
        
        Opportunity ppp=[select id,PriceBook2Id from Opportunity where id=:opp.id ];
        
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        
       PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = ppp.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        try{
            insert pricebookEntry1;
        }
        catch(DmlException e){ 
            system.debug('**************Exception : '+e);
        }
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp.id;
        insert oli;	
        system.debug('check yse');
            EUFT__c eu = [Select id, Name, ExemptionKeys__c from EUFT__c where opportunity__c =: opp.Id];
            system.debug('euiserrr'+eu);
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
       opp.Last_Approval_Event_Message__c='Approved';
        opp.Estimated_Delivery_End_Date__c = system.today();
        opp.Estimated_Delivery_Start_Date__c = system.today();
        opp.StageName = oppStageDefineCustomerValue;
       // opp.Is_progression_ready_for_stage__c='1';
         Test.startTest();
         update opp;
         system.debug('updated opp till 23satg');
        Sales_Decision_Record__c SDR = new Sales_Decision_Record__c(Name = 'Test SDR',Opportunity__c = opp.id) ;
        insert SDR;
        opp.Is_Extended_Warranty_SiA_included__c = 'No';
        opp.Voucher_or_FoC_Items_included__c = 'No';
        opp.Consideration_payable_to_customer_incl__c = 'No';
        opp.Trade_Compliance_Status__c = 'Approved';
        opp.Cashflow_Analysis_Status__c = 'Complete';
        opp.Risk_Assessment_Status__c = 'Complete';
        opp.Lock_Small_Value__c = false;
        opp.Tags__c = 'MELA NMS';
        opp.CloseDate = System.Today();
        opp.Proposal_Submission_Date__c = System.Today();
        //opp.Not_Deviating_from_Parent__c=true;
        opp.Managed_Services_Governance__c=true;
        opp.StageName = oppStageCreateProposal;
        opp.MarketArea__c='MELA';
        opp.CloseDate = System.Today();
        opp.Proposal_Submission_Date__c = System.Today();
        opp.Tags__c = GlobalConstants.MELADS;
        update opp; 
         opp.Sensitive_Business_Status__c = 'Approved';
        opp.I_confirm_the_SB_Conditional_Adherence__c = true;
        opp.Last_Approval_Event_Message__c='Approved';
        opp.StageName = oppStageNegotiateandClose ;
        opp.Opportunity_Tier__c='Minor'; 
        opp.Approved_SDP_Stage__c = 'SDP2 Submit Proposal';    
        update opp;
        Opportunity opp1=[select id,stageName from Opportunity];
        system.debug('upadted opp'+opp1.StageName);
        EarlyStart__c es1 =new EarlyStart__c();
            es1.RecordTypeId = GlobalConstants.newearlyStartRecordTypeId;
            es1.Name='test123';
            es1.Opportunity__c=opp1.Id;
            es1.Early_Start_Status__c='New/Created';
            es1.Early_Start_ACR__c=testUser.Id;
            es1.Early_Start_CFR__c=testUser.Id;
            es1.Early_Start_CSR__c=testUser.Id;
            es1.Early_Start_Status__c='Approved';
            es1.Early_Start_Expected_End_Date__c=System.Today();
            es1.Estimated_Cost_for_Early_Start_Scope__c=10;
            es1.Commodities__c=GlobalConstants.Hardware;
           // es1.Reason_for_Early_Start__c=GlobalConstants.LetterofCredit;
            es1.Reason_for_Early_Start__c=GlobalConstants.LetterofCredit+';'+'Missing quantity, products, and price (e.g. Purchase Order)';
            es1.Updated_Reason_for_Early_Start__c=GlobalConstants.LetterofCredit+';'+'Missing quantity, products, and price (e.g. Purchase Order)';
            es1.BAPartofEarlyStartScope__c=GlobalConstants.BDGS+';'+GlobalConstants.BMAS+';'+GlobalConstants.BNEW+';'+GlobalConstants.BTEB;
            es1.Scope_of_Early_Start__c='Only Planning';
            es1.Early_Start_Degree__c='D. Installation of HW/SW';
            es1.BoQ_with_Delivery_Objects_Attachments__c='Something';
            es1.CurrencyIsoCode='SEK';
            insert es1;
           EarlyStart__c es2 =new EarlyStart__c();
          es2.Name='test1234';
         es2.Parent_Early_Start__c=es1.Id;
        es2.Early_Start_Status__c='New/Created';
        es2.Est_Cost_AFTER_Extension_currency__c=1234;
       es2.RecordTypeId = GlobalConstants.extensionRecordTypeId;
        es2.CurrencyIsoCode='INR';
        es2.Updated_Commodities__c=GlobalConstants.Hardware;
        es2.Updated_BoQ_with_Delivery_Objects_Files__c='D. Installation of HW/SW';
        es2.Updated_Early_Start_Degree__c='B. Delivery of HW/SW to Local Company (LC)';
        es2.Updated_Scope_Description__c='Scope';
        es2.Updated_Total_Deal_Value__c=1;
        es2.Updated_Scope_of_Early_Start__c='Only Planning';
        insert es2;
        test.stopTest();
        es2.Early_Start_Status__c='Approved';    
        es2.Updated_Reason_for_Early_Start__c='Missing terms and conditions for billing and payment (e.g. legal agreement not yet signed)';
        es2.Updated_Commodities__c=GlobalConstants.Software;
         es2.Updated_Scope_Description__c=' Updated Scope';
        es2.Updated_Total_Deal_Value__c=11;  
         es2.Updated_BoQ_with_Delivery_Objects_Files__c='C. Delivery of HW/SW to customer’s site/warehouse' ;   
          es2.Updated_Early_Start_Degree__c= 'D. Installation of HW/SW';
           es2.Updated_Scope_of_Early_Start__c='Only Delivery';
            update es2;
           /* es1.other__c=testuser.id;
            es1.Other2__c=testuser.id;
            es1.Other3__c=testuser.id;
            es1.MA_Head_or_Delegate__c=testuser.id;
            es1.Trade_Finance__c=testuser.id;
            es1.CU_Supply_Head__c=testuser.id;
            es1.BA_Representative_Digital__c=testuser.id;
            es1.BA_Representative_Emerging_Bus_IOT__c=testuser.id;
            es1.BA_Representative_Managed_Services__c=testuser.id;
            es1.BA_Representative_Networks__c=testuser.id;
            update es1;
             EarlyStart__c es3 =new EarlyStart__c();
          es3.Name='test1234';
         es3.Parent_Early_Start__c=es1.Id;
          es3.Early_Start_Status__c='New/Created';
            es3.Opportunity__c=opp1.id;
            insert es3;*/
            EarlyStartHelper.setApprovers(null,null,null);
            EarlyStartHelper.updateParentOppOnCreation(null);
            EarlyStartHelper.updateCurrencyFromES(null);
            EarlyStartHelper.updateExtensionFromES(null,null,null);
            EarlyStartHelper.setApproversOnExtension(null);
			EarlyStartHelper.updateParentOpp(null,null);
            EarlyStartHelper.getSignumofUser(null,null,null);
            EarlyStartHelper.disappearApprovers(null,null);
			System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }
        catch(Exception e){
            system.debug('exception'+e);
        }
    }
  
}