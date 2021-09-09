/****************************************************************
* @author: Shubham Kadam 
* @date: 20-10-2020
* @User Story: U-2035
* @description: This class is a test class for EUFTTriggerHelper
*****************************************************************/
@isTest(seeAllData = false)
public class EUFTTriggerHelperTest {
    
    /****************************************************************
* @author: Shubham Kadam 
* @date: 20-10-2020
* @description: This method is a test method for updateSBSStatus
*****************************************************************/
    @isTest
    public static void updateSBSStatusTest()
    {
        try {
            System.debug('##1');
            List<EUFT__c> newEUFT = new List<EUFT__c>();
            Map<ID, EUFT__c> oldEUFTMap = new Map<ID, EUFT__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;           
            Account acc;
            
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
            System.debug('##2');
            System.runAs(testUser){  
                System.debug('##3');
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.SBSPilot__c = true;
                acc.EUFTNumber__c = '9876543';
                acc.BillingCountryCode = 'AL';
                acc.CustomerRisk__c = 4;
                acc.CountryRisk__c = 2;
                insert acc;
                System.debug('##4');
            }
            //product -->        
            Id pricebookIdStd = Test.getStandardPricebookId();
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            System.debug('##oppbefore Product : 5');
            Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
            insert prod;
            
            Opportunity opp1 = new Opportunity(
                Name = 'test non-pilot 2035', AccountId = acc.Id,
                StageName = '1. Qualify Opportunity',
                Anticipated_Deal_Value__c = 12, Proposal_Submission_Date__c = system.today(),
                Probability = 10, Estimated_Delivery_Start_Date__c = system.today(),
                Override_Deal_Value_and_Margin__c = false, CloseDate = system.today(),
                Estimated_Delivery_End_Date__c = system.today()+7, Global_Frame__c = false,
                High_Impact_Deal__c = false, Forecast__c = 'Exclude',
                Not_Deviating_from_Parent__c = false, Description = 'test opp',
                Lead_Domain__c = 'BNEW', Opportunity_Tier__c = 'Minor',
                CountryRiskValue__c = 6.75,
                SBSStatus__c = 'Not Required', Managed_Services_Governance__c = false,
                Customer_intent_to_buy__c = 'Very Strong', Local_experience_and_resources_to_win__c = 'High',
                Relations_with_customer_decision_maker__c = 'Favorable', Customer_sourcing_work__c = 'Single',
                Impact_Customer_and_RfQ__c = 'Yes', WDR_3PP_share_of_total_cost__c = '0%',
                Advantantage_towards_the_customer__c = 'Ericsson', Extraordinary_challenges_or_risks__c = 'No',
                Solid_solution_and_references__c = 'Yes', Non_delegated_business__c = 'No',
                Confidence_to_win_winning_value__c = 'High', Financial_Compliance_Audit_Scope__c = 'OUT OF SCOPE',
                CRM360_ATS_Flag__c = false, Unadjusted_margin_after_risk__c = 0,
                Trade_Compliance_Status__c = 'Not Required', Sensitive_Business_Status__c = 'Not Required',
                Trade_Classifications__c = 'Civil', I_confirm_the_SB_Conditional_Adherence__c = false,
                Ship_To_Countries__c = 'AL', What_is_the_Technology_Risk__c = 'Low',
                Sensitive_Products_in_scope__c = 'Yes', End_Customer__c = acc.Id,
                Will_Opp_involve_intermediate_partner__c = 'No', I_will_adhere_to_the_approval_conditions__c = false,
                Loss_to_Incumbent__c = false, ConfirmEndCustomer__c = true, Proposal_Deal_Value__c = 0, Purpose__c = 'Crime prevention - unrestricted interception, Protection',
                Sales_Compliance_Country_Risk__c = GlobalConstants.MEDIUM_CAMEL, MinimumPurposeRisk__c = 3
            );
            System.debug('##oppbefore insert : 9 '+opp1);
            insert opp1;
            System.debug('##opp : 10 '+opp1.Proposal_Deal_Value__c);
            
            Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp1.id ];
            
            System.debug('##6');
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, 
                                                                  CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            System.debug('##7');
            PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            try{
                insert pricebookEntry1;
            }
            catch(DmlException e){
                System.debug('** Error1'+e.getMessage());
            }
            System.debug('##oppbefore opp1 : 8');
            
            
            //opp1 in stage 1 -> ready to progress to stage 2
            
            
            OpportunityLineItem oppLine1 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp1.Id, 
                                                                                                                        PricebookEntryId = pricebookEntry1.Id 
                                                                                                                       ));
            System.debug('##opp : 11');
            insert oppLine1;
            System.debug('##opp : 12'+oppLine1);
            
            //progress to stage 2
            opp1.StageName = '2. Define Customer Value';
            update opp1;
            System.debug('##Updated to stage 2 : 15'+opp1.StageName);
            Test.startTest();
            
            //SDR Type 1 
            
            Sales_Decision_Record__c sdr = new Sales_Decision_Record__c(
                Name = 'SDR1',               	                        // Sales Decision Record Name
                Sales_Decision_Approval_Status__c = 'In Progress',      // Sales Decision Approval Status
                Sales_Decision_Type__c = 'SDP1 Invest to Win',          // Sales Decision Type
                Sales_Decision_Date__c = System.Today(),			   	// Sales Decision Date
                SDR_Completed__c = 'Yes',                               // SDR ready for Approval?
                Opportunity__c = opp1.Id	                            // Opportunity
            );
            insert sdr;
            System.debug('##sdr : 16'+sdr);
            
            //SDM for Type 1                
            Sales_Decision_Maker__c sdm1 = new Sales_Decision_Maker__c(
                Approver_Role__c = 'KAM; CU Head; GCU Head', 		// Approver Role
                Approver_Name__c = testUser1.Id,          			// Approver Name
                Approval_Status__c = 'Approved',               		// Approval Status
                Sales_Decision_Record__c = sdr.Id,  				// Sales Decision Record
                Actual_Approver__c = testUser.Id        			// Approval set by
            );
            insert sdm1;
            System.debug('##sdm1 : 17'+sdm1);
            
            sdr.Sales_Decision_Approval_Status__c = 'Approved';
            update sdr;
            
            //progress to stage 3
            opp1.StageName = '3. Create Proposal';
            update opp1;
            System.debug('##Updated to stage 3 : 18'+opp1.StageName);
            
            opp1.SBSStatus__c = GlobalConstants.Successful;
            opp1.SBSMessage__c = 'test';
            opp1.SBSResult__c = 'Success';
            update opp1;
            
            EUFT__c eu = new EUFT__c();
            eu.Opportunity__c = opp1.Id;
            eu.EUFT__c = acc.Id;
            eu.Country_Risk_Number__c = 0.70;
            eu.TechnologyRisk__c = 3;
            insert eu;
            oldEUFTMap.put(eu.Id, eu);
            System.debug('##euft : 13'+eu);
            
            eu.ExemptionKeys__c = 'test';
            update eu;
            newEUFT.add(eu);
            System.debug('##Neweuft : 14'+eu);
            
            Proposal__c prop = new Proposal__c(
                Opportunity__c = opp1.Id,                                                                                                                                                                                                                                                                                           
                Name = 'New Proposal',
                Proposal_Id__c = '5016952',
                Delivery_Start_Date__c = Date.Today(),
                Version__c = '1',
                Delivery_End_Date__c = Date.Today()+30,
                Primary__c = true,
                Net_Price__c = 55,
                Effective_Net_Price__c = 55,
                Economic_Profit__c = 49,
                Economic_Profit_Percent__c = 8808,
                Risk_Analysis_Status__c = 'Complete',
                Contract_Evaluation_Status__c = 'Complete',
                Cash_Flow_Status__c = 'Complete',
                Cash_Flow_Opp_WCD__c = '30',
                Cash_Flow_YTD_Value_WCD__c = '41',
                Cash_Flow_Opp_CoC_Net_Sales__c = '0.90642100%',
                Cash_Flow_Opportunity_Customer_DSO__c = '30',
                Cash_Flow_YTD_Value_Customer_DSO__c = '15'
            );
            insert prop;
            
            EUFTTriggerHelper.updateSBSStatus(newEUFT, oldEUFTMap);
            EUFTTriggerHelper.updateSBSStatus(null, null);
            
            delete eu;
            EUFTTriggerHelper.updateShipToCountries(newEUFT);
            EUFTTriggerHelper.updateShipToCountries(null);
            EUFTTriggerHelper.updateCountryRisk(null);
            Test.stopTest();   
        }catch(Exception ex)
        {
            System.debug('** Error'+ex.getMessage());
        }
    }
    
    @isTest
    public static void updateManualSBStatusRequiredTest()
    {
        try {
            List<EUFT__c> newEUFT = new List<EUFT__c>();
            Map<ID, EUFT__c> oldEUFTMap = new Map<ID, EUFT__c>();
            System.debug('** 1');
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;           
            Account acc;
            
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.SBSPilot__c = true;
                acc.EUFTNumber__c = '9876543';
                acc.CustomerRisk__c = 4;
                acc.CountryRisk__c = 2;
                acc.Trade_Classification__c = GlobalConstants.DEFENSE;
                insert acc;
            }
            System.debug('** 2');
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                           Description='test', CloseDate= system.today()));  
            opp.Purpose__c = 'Crime prevention - unrestricted interception, Protection';
            opp.Sales_Compliance_Country_Risk__c = GlobalConstants.CAMEL_LOW;
            opp.MinimumPurposeRisk__c = 3;
            insert opp;
            
            System.debug('** 3');
            EUFT__c eu = new EUFT__c();
            eu.EUFT__c = acc.Id;
            eu.Opportunity__c = opp.Id;
            eu.TechnologyRisk__c = 3;
            eu.Country_Risk_Number__c = 0.70;
            insert eu;
            
            System.debug('** 4');
            newEUFT.add(eu);
            
            System.debug('** TechnologyRiskThreshold__c'+eu.TechnologyRiskThreshold__c);
            
            Proposal__c prop = new Proposal__c(
                Opportunity__c = opp.Id,                                                                                                                                                                                                                                                                                           
                Name = 'New Proposal',
                Proposal_Id__c = '5016952',
                Delivery_Start_Date__c = Date.Today(),
                Version__c = '1',
                Delivery_End_Date__c = Date.Today()+30,
                Primary__c = true,
                Net_Price__c = 55,
                Effective_Net_Price__c = 55,
                Economic_Profit__c = 49,
                Economic_Profit_Percent__c = 8808,
                Risk_Analysis_Status__c = 'Complete',
                Contract_Evaluation_Status__c = 'Complete',
                Cash_Flow_Status__c = 'Complete',
                Cash_Flow_Opp_WCD__c = '30',
                Cash_Flow_YTD_Value_WCD__c = '41',
                Cash_Flow_Opp_CoC_Net_Sales__c = '0.90642100%',
                Cash_Flow_Opportunity_Customer_DSO__c = '30',
                Cash_Flow_YTD_Value_Customer_DSO__c = '15'
            );
            insert prop;
            
            
            Test.startTest();
            EUFTTriggerHelper.updateManualSBStatusRequired(newEUFT);
            EUFTTriggerHelper.updateManualSBStatusRequired(null);
            EUFTTriggerHelper.updateSensitiveBusinessStatus(null, null, null, null);
            EUFTTriggerHelper.CallResetSecondaryApprovalStatusFromEUFT(null, null);
            Test.stopTest();
        }catch(Exception ex) {
            System.debug('** Error'+ex.getMessage());
        }
    }
    
    @isTest
    public static void updateSensitiveBusinessStatusTest()
    {
        try {
            List<EUFT__c> newEUFT = new List<EUFT__c>();
            Map<ID, EUFT__c> oldEUFTMap = new Map<ID, EUFT__c>();
            System.debug('** 1');
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;           
            Account acc;
            
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.SBSPilot__c = true;
                acc.EUFTNumber__c = '9876543';
                acc.CustomerRisk__c = 4;
                acc.CountryRisk__c = 0;
                acc.Trade_Classification__c = GlobalConstants.DEFENSE;
                insert acc;
            }
            System.debug('** 2');
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                           Description='test', CloseDate= system.today()));  
            opp.Purpose__c = 'Crime prevention - unrestricted interception, Protection';
            opp.Sales_Compliance_Country_Risk__c = GlobalConstants.CAMEL_LOW;
            opp.MinimumPurposeRisk__c = 1;
            insert opp;
            
            System.debug('** 3');
            EUFT__c eu = new EUFT__c();
            eu.EUFT__c = acc.Id;
            eu.Opportunity__c = opp.Id;
            eu.TechnologyRisk__c = 3;
            eu.Country_Risk_Number__c = 0;
            insert eu;
            
            System.debug('** 4');
            newEUFT.add(eu);
            oldEUFTMap.put(eu.Id, eu);
            
            Test.startTest();
            EUFTTriggerHelper.updateSensitiveBusinessStatus(newEUFT, oldEUFTMap, true, false);
            EUFTTriggerHelper.updateSensitiveBusinessStatus(newEUFT, oldEUFTMap, false, true);
            EUFTTriggerHelper.updateSensitiveBusinessStatus(null, null, null, null);
            Test.stopTest();
        }catch(Exception ex) {
            System.debug('** Error'+ex.getMessage());
        }
    }
}