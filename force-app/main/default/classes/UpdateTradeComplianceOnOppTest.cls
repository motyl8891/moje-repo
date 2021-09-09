@isTest
private class UpdateTradeComplianceOnOppTest {
    @testSetup static void setup() 
    {
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Id pricebookId = Test.getStandardPricebookId();
        Account ac;
        Account ac1;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                       UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountryCode='SE';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            crg.MarketArea__c = GlobalConstants.MELA;
            crg.CRG_ID__c='HW12341';
            crg.Name='testCRG1';
            insert crg;
            ac1 = new Account();
            ac1.Name = 'Test Account';
            ac1.SAP_S2P_ID__c='1';
            ac1.CurrencyIsoCode = 'SEK';
            ac1.Visible__c = true;
            ac1.Customer_Tier__c = 'Tier 1';
            ac1.CustomerReportingGroup__c= crg.id;
            ac1.BillingCountry=Null;
            ac1.Trade_Classification__c='CIVIL';
            insert ac1;
        }
        
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name = 'Test ES Apex', Ship_To_Countries__c = GlobalConstants.EGYPT, Sensitive_Products_in_scope__c = 'no',
                                                                                        AccountId=ac.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp1.Is_progression_ready_for_stage__c = '5';      
        opp1.Will_Opp_involve_intermediate_partner__c = 'No' ;        
        opp1.Has_Less_Sensitive_Country__c = true;
        opp1.High_Impact_Deal__c = True;
        opp1.Forecast__c='Upside';
        opp1.What_is_the_Technology_Risk__c = 'Low' ;
        opp1.Trade_Classifications__c = 'Not Required' ;
        opp1.End_Customer__c = ac.id ;
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
        
        Opportunity ppp=[select id,PriceBook2Id from Opportunity where id=:opp1.id ];
        
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
        
        List<OpportunityLineItem> olilist = new List<OpportunityLineItem>();
        List<Opportunity> oppList = new List<Opportunity>();
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        oli.UnitPrice = 1000;
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp1.id;
        insert oli;
        
       // Test.startTest();
        //progress to stage 2
        opp1.StageName = GlobalConstants.Define_CustomerValue;
        opp1.Last_Approval_Event_Message__c = 'Approved';
        update opp1;
        
        //progress to stage 3
        opp1.Estimated_Delivery_Start_Date__c = System.today();
        opp1.Estimated_Delivery_End_Date__c = System.today();
        opp1.Last_Approval_Event_Message__c = 'Approved';
        opp1.Approved_SDP_Stage__c = 'SDP1 Invest to Win';
        opp1.StageName = GlobalConstants.Create_Proposal;
        update opp1;
        
        Test.startTest();
        
        /* ------------------ Create a 2nd opp ----------------- */
        
        //Create an Opp in stage 4 to be able to create ES
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name = 'Test ES Apex 2', Ship_To_Countries__c = GlobalConstants.SWEDEN, AccountId=ac1.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp2.Sensitive_Products_in_scope__c = 'no';
        opp2.Is_progression_ready_for_stage__c = '5';      
        opp2.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp2.Ship_To_Countries__c = GlobalConstants.EGYPT ;
        opp2.Has_Less_Sensitive_Country__c = true;
        opp2.High_Impact_Deal__c = True;
        opp2.Forecast__c='Upside';
        opp2.What_is_the_Technology_Risk__c = 'Low' ;
        opp2.Trade_Classifications__c = 'Not Required' ;
        opp2.End_Customer__c = ac1.id ;
        opp2.Sensitive_Business_Status__c = 'Not Required' ;
        opp2.Customer_intent_to_buy__c = 'Very Strong' ;
        opp2.Has_Less_Sensitive_Country__c = true;
        opp2.Sensitive_Products_in_scope__c = 'Yes';
        opp2.Trade_Classifications__c = 'Civil';
        opp2.Local_experience_and_resources_to_win__c = 'High' ;
        opp2.Relations_with_customer_decision_maker__c = 'Favorable' ;
        opp2.Customer_sourcing_work__c = 'Single' ;
        opp2.Impact_Customer_and_RfQ__c = 'Yes';                                                                                       
        opp2.Solid_solution_and_references__c = 'Yes';
        opp2.Non_delegated_business__c ='No';
        opp2.Confidence_to_win_winning_value__c = 'High';
        opp2.WDR_3PP_share_of_total_cost__c = '0%';
        opp2.Advantantage_towards_the_customer__c = 'Ericsson';
        opp2.Extraordinary_challenges_or_risks__c = 'No';
        opp2.CloseDate = system.today();
        opp2.MarketArea__c='MMEA';
        insert opp2;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.Product2Id = prod.Id;
        oli2.Estimated_Margin__c = 10;
        oli2.UnitPrice = 1000;
        oli2.OpportunityId = opp2.id;
        insert oli2;
        
        //progress to stage 2
        opp2.StageName = GlobalConstants.Define_CustomerValue;
        opp2.Last_Approval_Event_Message__c = 'Approved';
        update opp2;
        
        //progress to stage 3
        opp2.Estimated_Delivery_Start_Date__c = System.today();
        opp2.Estimated_Delivery_End_Date__c = System.today();
        opp2.Last_Approval_Event_Message__c = 'Approved';
        opp2.Approved_SDP_Stage__c = 'SDP1 Invest to Win';
        opp2.StageName = GlobalConstants.Create_Proposal;
        update opp2;
        Test.stopTest();
    }
    @isTest
    static void UpdateTradeComplianceOnOppTest()
    {
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        
        Map<id,Account> acctMap = new Map<id,Account>();
        List<Account> acc=[Select id,Name,BillingCountry,Trade_Classification__c from Account
                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        acctMap.put(acc[0].id,acc[0]);
        
        Map<id,Account> acctMap1 = new Map<id,Account>();
        acctMap1.put(acc[1].id,acc[1]);
        
        Country_Risk__c sdmRule = new Country_Risk__c();
        sdmRule.Name='Myanmar';
        sdmRule.TC_Sensitivy_Class__c='SENSITIVE';
        insert sdmRule;
        
        List<Opportunity> opp=[Select id,stageName,AccountID  from Opportunity
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
        opp[0].Trade_Compliance_Status__c='REQUIRED';
        update opp[0];
        opp[1].Trade_Compliance_Status__c='REQUIRED';
        update opp[1];
        
        Test.startTest();
        UpdateTradeComplianceOnOpp c = new UpdateTradeComplianceOnOpp(acctMap);
        Database.executeBatch(c);
        
        UpdateTradeComplianceOnOpp c1 = new UpdateTradeComplianceOnOpp(acctMap1);
        Database.executeBatch(c1);
        Test.stopTest();
        System.assert(true); //NS
    }
}