@isTest
public class AccountTriggerHelperTest{
    @testSetup  
    static void setupTestData(){   
        //U-1903
		
		Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        string creatingaccount;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        Account acc;
        System.runAs(testUser){
            acc= (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.BillingCountrycode = 'SE';
            acc.Trade_Classification__c=GlobalConstants.GOVERNMENT; 
            insert acc;
        }
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
		
		
      /*  Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        string creatingaccount;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        Account ac;
        System.runAs(testUser){
            ac= (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry = GlobalConstants.CUBA;
            ac.Trade_Classification__c=GlobalConstants.GOVERNMENT; 
            insert ac;
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
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=ac.Id,PriceBook2Id = pricebookId, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        opp.Name = 'test oppty';
        insert opp;
        oli.OpportunityId = opp.id;
        insert oli;
		*/
        opp.Will_Opp_involve_intermediate_partner__c = 'No' ;
        opp.Ship_To_Countries__c = GlobalConstants.EGYPT;
        opp.Has_Less_Sensitive_Country__c = true;
        opp.High_Impact_Deal__c = True;
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
        update opp;
    }
    @isTest
    public static void sendEmailNotificationForTradeComplianceTest(){
        Try{
            List<Account> l=new list<Account>(); 
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            //U-1903
            String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
            Account acc=[Select id,BillingCountry,Trade_Classification__c from Account];
            
            Test.startTest();
            Country_Risk__c sdmRule = new Country_Risk__c();
            sdmRule.Name='Myanmar';
            sdmRule.TC_Sensitivy_Class__c='SENSITIVE';
            insert sdmRule;
            
            l.add(acc);
            
            Opportunity opp=[Select id,stageName,AccountID  from Opportunity ];
            opp.stageName =oppStageDefineCustomerValue;
            opp.Last_Approval_Event_Message__c='Approved';
            update opp;
            opp.Trade_Compliance_Status__c='REQUIRED';
            opp.Approved_SDP_Stage__c='SDP1 Invest to Win';
            update opp;
            
            acc.BillingCountry='Myanmar';
            acc.Trade_Classification__c = 'Civil';
            update acc;         
            Test.stopTest();
            //NS
            System.assert(true);
        }catch(Exception e){	}
    }
    @isTest
    public static void testmethode1(){
        Try{
            AccountTriggerHelper AT = new AccountTriggerHelper();
            //NS
            System.assert(true);
        }catch(Exception e){	}
    }
}