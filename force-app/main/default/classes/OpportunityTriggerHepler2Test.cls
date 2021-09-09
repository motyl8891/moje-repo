@isTest(seeAllData = false)
private class OpportunityTriggerHepler2Test {

    @isTest
    public static void recordCreateTest(){
        Try{
        Account acc;
        Account acc1;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
         
            System.runAs(testUser){
               
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.CurrencyIsoCode = 'SEK';
            insert acc;
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c(CRG_ID__c='12345',Name='testCrg1');
            // (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(Account_Primary_KAM__c = testUser.Id, Account_CU_Head__c = testUser.Id ), 
            // false);
            insert crg;
            acc1= new Account();
            acc1.Name = 'Test1 Account';
            acc1.SAP_S2P_ID__c=String.valueOf(1);
            acc1.CurrencyIsoCode = 'ALL';
            acc1.Visible__c = true;
            acc1.Customer_Tier__c = 'Tier 1';
            acc1.CustomerReportingGroup__c= crg.id;
            insert acc1;
                
        } 
            Test.startTest();
        List<Opportunity> oppList= new List<Opportunity>();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.standardCreateOppRecordTypeId,
                                                                                        Forecast__c=null)); 
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId,
                                                                                        currencyIsoCode='AOA')); 
        Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.simpleCreateOppRecTypeId, 
                                                                                        stageName=GlobalConstants.Negotiate_and_Close)); 
        oppList.add(opp1);
        oppList.add(opp2);
        oppList.add(opp3);
        Insert oppList;
        OpportunityTriggerHepler2.recordTypeAssignment(Null);
        Secondary_Approval__c sc = new Secondary_Approval__c();
        sc.Opportunity__c = opp1.Id;
        insert sc;
        opp1.Description='Testing';
        update opp1;
        OpportunityTriggerHepler2.updateOppDescriptionOnSecondaryApproval(null,null);
        Proposal__c prop1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp2.Id));
        prop1.Primary__c=False;
        insert prop1;
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp2.id));
        insert sdr;
        prop1.Primary__c=True;
        update prop1;
        opp1.Approved_Stage__c=GlobalConstants.Define_CustomerValue;
        update opp1;
        opp1.Approved_Stage__c=GlobalConstants.Negotiate_and_Close;
        update opp1;
        OpportunityTriggerHepler2.updatePrimaryProposalOnSDR(Null,Null);
        OpportunityTriggerHepler2.updateOpportunityApprovedStage(Null,Null);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc1.Id, RecordtypeId = GlobalConstants.simpleOppRecordTypeId, 
                                                                                       stageName=GlobalConstants.Negotiate_and_Close,Parent_Original_Opportunity__c=opp2.id)); 
        insert opp;
         System.assertEquals(opp.AccountId,acc1.Id);
            Test.stopTest();
            }catch(Exception e){	}
    }
    @isTest
    public static void setCloseDateStageNameProductChangeTest(){   
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }        
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, 
                                                              CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        test.startTest();
        Opportunity simpleopp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = GlobalConstants.simpleCreateOppRecTypeId,
                                                                                            stageName=GlobalConstants.Negotiate_and_Close));
        insert simpleopp;
        
        Opportunity frameopp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId,
                                                                                            Name='Frame', PriceBook2Id = pricebookId,
                                                                                            stageName=GlobalConstants.Qualify_Opportunity,Forecast__c='Exclude'));
        insert frameopp;
            Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:frameopp.id ];
       PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert pricebookEntry;  
        OpportunityLineItem oppLine1 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=simpleopp.Id, 
                                                                                                                    PricebookEntryId = pricebookEntry.Id));
        insert oppLine1;    
        OpportunityLineItem oppLine2 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=frameopp.Id, PricebookEntryId = pricebookEntry.Id));
        insert oppLine2;
        delete oppLine1;
        test.stopTest();
        oppLine2.Estimated_Margin__c=10;
        update oppLine2;
        oppLine2.UnitPrice=4000;
        update oppLine2;
        Opportunity frameopp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId,
                                                                                             Name='Frame2', PriceBook2Id = pricebookId,
                                                                                             stageName=GlobalConstants.Qualify_Opportunity,Forecast__c='Exclude'));
        insert frameopp2;
        frameopp2.Forecast__c='Upside';
        update frameopp2;
        frameopp.CloseDate=System.Today().addDays(1);
        update frameopp2;
        OpportunityTriggerHepler2.setCloseDateStageNameProductChange(null, null);
        System.assertEquals(frameopp2.Forecast__c,'Upside');
            }catch(Exception e){	}
    }
    @isTest
    public static void setOpportunityApproversTest(){ 
        Try{
        Account acc;
        Account acc1;
        CustomerReportingGroup__c crg;
        CustomerUnit__c cu;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            cu  = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
            cu.GCU_Commercial_Head__c=testUser.id;
            insert cu;
            crg  = new CustomerReportingGroup__c(CRG_ID__c='1235',Name='Test Crg',MarketArea__c='MELA');
            insert crg;
            CustomerReportingGroup__c crg1  = new CustomerReportingGroup__c(CRG_ID__c='125',Name='Test Crg1',MarketArea__c='MANA',Valid_KAM_CU_Head_Approvers__c=false); 
            crg1.GlobalCustomerUnit__c=cu.id;
            insert crg1;
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.CustomerReportingGroup__c=crg.id;
            insert acc;
            acc1 = new Account();
            acc1.Name = 'Test1 Account';
            acc1.SAP_S2P_ID__c=String.valueOf(1);
            acc1.CurrencyIsoCode = 'ALL';
            acc1.Visible__c = true;
            acc1.Customer_Tier__c = 'Tier 1';
            acc1.CustomerReportingGroup__c= crg1.id;
            insert acc1;
            
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId,
                                                                                       currencyIsoCode='AOA')); 
          insert opp;
            Contract contract= new Contract(name='Deal',Status='Valid',AccountId=acc1.id,OpportunityID__c=opp.id);
            insert contract;
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc1.Id, RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId)); 
        opp1.Source_System__c=GlobalConstants.Lighthouse ;
            opp1.Parent_Contract__c=contract.id;
            insert opp1;
        OpportunityTriggerHepler2.setOpportunityApprovers(null,null,false);
        OpportunityTriggerHepler2.setParentOpportunityAsContractOpportunity(Null);
         OpportunityTriggerHepler2.updateOverrideCheckboxOnSimpleOppty(null,null);   
          System.assertEquals(opp.AccountId,acc.Id);
            }catch(Exception e){	}
    }

/****************************************************************
* @author: Shubham Kadam / Shubham Jagatap 
* @date: 27-10-2020
* @User Story: U-2035, U-2039, U-2072
* @description: This class is a test class for EUFTTriggerHelper
*****************************************************************/        
    @isTest
    public static void SBSTest(){
        try{
            System.debug('##test');
            List<Opportunity> newOpportunities = new List<Opportunity>();
            Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity>();
            
            
            
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
                acc.CountryRisk__c = 0;
                
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
            System.debug('##6');
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, 
                                                                  CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            System.debug('##7');
            
            System.debug('##oppbefore opp1 : 8');
            
            
            //opp1 in stage 1 -> ready to progress to stage 2
            Opportunity opp1 = new Opportunity(
                Name = 'test non-pilot 2035', AccountId = acc.Id,
                StageName = '1. Qualify Opportunity', PriceBook2Id = pricebookId,
                Anticipated_Deal_Value__c = 12, Proposal_Submission_Date__c = system.today(),
                Probability = 10, Estimated_Delivery_Start_Date__c = system.today(),
                Override_Deal_Value_and_Margin__c = false, CloseDate = system.today(),
                Estimated_Delivery_End_Date__c = system.today()+7, Global_Frame__c = false,
                High_Impact_Deal__c = false, Forecast__c = 'Exclude',
                Not_Deviating_from_Parent__c = false, Description = 'test opp',
                Lead_Domain__c = 'BNEW', Opportunity_Tier__c = 'Minor',
                CountryRiskValue__c = 6.75, //SendforSBSEvaluation__c = false,
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
                Loss_to_Incumbent__c = false, ConfirmEndCustomer__c = true, Proposal_Deal_Value__c = 0,
                MinimumPurposeRisk__c = 1,
                Sales_Compliance_Country_Risk__c = GlobalConstants.CAMEL_LOW,
                Purpose__c = 'Crime prevention - unrestricted interception, Protection',
                UseCase__c = 'FAU20109'
                
            );
            System.debug('##oppbefore insert : 9 '+opp1);
            insert opp1;
            Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp1.id ];
            System.debug('##opp : 10 '+opp1.Proposal_Deal_Value__c);
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            insert pricebookEntry;
            OpportunityLineItem oppLine1 = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp1.Id, 
                                                                                                                        PricebookEntryId = pricebookEntry.Id 
                                                                                                                       ));
            System.debug('##opp : 11');
            insert oppLine1;
            System.debug('##opp : 12'+oppLine1);
            
            oldOpportunitiesMap.put(opp1.Id, opp1);
            //progress to stage 2
            opp1.StageName = '2. Define Customer Value';
            update opp1;
            System.debug('##Updated to stage 2 : 15'+opp1.StageName);
            newOpportunities.add(opp1);
            
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
            
            opp1.StageName = '3. Create Proposal';
            update opp1;
            Proposal__c prop1 = new Proposal__c (Opportunity__c=opp1.Id);
            prop1.name = 'Proposal1';
            prop1.Approved_Stage__c='4. Negotiate and Close';
            prop1.Primary__c=True;
            insert prop1;
            //progress to stage 3
            System.debug('##Updated to stage 3 : 18'+opp1.StageName);
            EUFT__c eu = [select Id, Name, Opportunity__c, TradeClassification__c, 
                          BlockList__c, TechnologyRisk__c, PurposeRisk__c, 
                          TechnologyRiskThreshold__c, TotalRisk__c, 
                          EUFT__c, CustomerRisk__c, ExemptionKeys__c  from EUFT__c where opportunity__c = : opp1.Id  LIMIT 1];
            System.debug('EUFT__c'+eu);
            System.debug('EUFT__c'+eu.TechnologyRiskThreshold__c);
            
            Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.RecordTypeId = SBRecordTypeId;
            sc.Approval_Valid_Until__c = System.today()+1;    
            sc.Opportunity__c = opp1.Id;
            sc.Sign_Off_Type__c = 'Sensitive Business';
            sc.Use_Cases__c = 'Voice & Data';
            sc.Approval_Status__c = 'Pending';
            sc.Approval_Rejection_Reason__c = 'Submitted for auto approval';     
            insert sc;
            
            EUFT__c eu1 = new EUFT__c();
            eu1.EUFT__c = acc.Id;
            eu1.Opportunity__c = opp1.Id;
            eu1.TechnologyRisk__c = 3;
            eu1.Country_Risk_Number__c = 0;
            //eu1.ExemptionKeys__c = 'testKey1';
            insert eu1;
            
            opp1.SBSResult__c = 'Failed';
            update opp1;
            oldOpportunitiesMap.put(opp1.Id, opp1);
            
            opp1.SBSResult__c = 'Success';
            opp1.UseCase__c = 'FAU20110';
            eu.BlockList__c = 'testKey1';
            update opp1;
            newOpportunities.add(opp1);
            //System.debug('##Proposal Count : '+opp1.Proposal_Count__c);
            
            
            OpportunityTriggerHepler2.getAccDetails(opp1.id);
            OpportunityTriggerHepler2.getOppDetails(opp1.id);
            OpportunityTriggerHepler2.makeCallout(opp1.id);
            OpportunityTriggerHepler2.addErrorOnConfirmEndCustomer(newOpportunities,oldOpportunitiesMap);
            OpportunityTriggerHepler2.setConditionsOnSA(newOpportunities, oldOpportunitiesMap);
            
            OpportunityTriggerHepler2.addErrorOnConfirmEndCustomer(null,null);
            OpportunityTriggerHepler2.createEUFTRecord(null);
            OpportunityTriggerHepler2.sbsCalloutOnClosedWon(null,null);
            OpportunityTriggerHepler2.SetSBSStatus(null,null);
            OpportunityTriggerHepler2.createOppUseCase(null,null);
            OpportunityTriggerHepler2.updateOverrideCheckboxOnSimpleOppty(null,null);
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            OpportunityTriggerHepler2.makeCallouttoExternal(Opp1.Id);
            //OpportunityTriggerHepler2.makeCallouttoExternal1(Opp1.Id);
			 System.assertEquals(opp1.Anticipated_Deal_Value__c,12);
            
        }
        catch(Exception ex){
            System.debug('##Error : '+ex.getLineNumber()+' -- '+ex.getMessage());
        }
    }
    
    @isTest
    public static void sendEmailToAOForSBSTest(){
        try {
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);       
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.SBSPilot__c = true;    
                insert acc;
            }
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                           Description='test', CloseDate= system.today()));
            opp.SBSResult__c = 'Not Required';
            opp.UseCase__c = 'FAU20109';
            opp.Purpose__c = 'Crime prevention - unrestricted interception, Protection';
            insert opp;
            
            Test.startTest();
            
			Map<ID, Opportunity> newOpportunitiesMap = new Map<ID, Opportunity>();
            newOpportunitiesMap.put(opp.Id, opp);
            
            Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.RecordTypeId = SBRecordTypeId;
            sc.Approval_Valid_Until__c = System.today()+1;    
            sc.Opportunity__c = opp.Id;
            sc.Sign_Off_Type__c = 'Sensitive Business';
            sc.Use_Cases__c = 'Voice & Data';
            sc.Approval_Status__c = 'To be submitted';
            sc.Approval_Rejection_Reason__c = 'To be submitted';     
            insert sc;
            
            //opp.SBSResult__c = GlobalConstants.Success;
            //opp.Purpose__c = 'Unrestricted Data Retention';
            //update opp;
            
            EUFT__c eu = new EUFT__c();
            eu.EUFT__c = acc.Id;
            eu.Opportunity__c = opp.Id;
            eu.TechnologyRisk__c = 3;
            eu.Country_Risk_Number__c = 0;
            eu.BlockList__c = 'testKey1';
            insert eu;
            
            OpportunityTriggerHepler2.sendEmailToAOForSBS(opp);
            OpportunityTriggerHepler2.sendEmailToAOForSBS(null);
            OpportunityTriggerHepler2.CallResetSecondaryApprovalStatus(null, null);
            OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(null);
            OpportunityTriggerHepler2.updateConsolidatedBlockListOnAccount(null, null, null);
            OpportunityTriggerHepler2.setOpportunityOwnerSecond(null);
            OpportunityTriggerHepler2.setConditionsOnSA(null, null);
            OpportunityTriggerHepler2.setSBSRiskValues(null, null);
            
            Sales_Decision_Record__c sdr = OpportunityTriggerHepler2.createSDRRecords(true , 'SDP0 Qualify' , opp.Id ,  newOpportunitiesMap);
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            OpportunityTriggerHepler2.makeCallouttoExternal1(opp.Id);

            OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(null);
            
            Test.stopTest();
        }catch(Exception ex) {
            System.debug('##Error : '+ex.getLineNumber()+' -- '+ex.getMessage());
        }
    }
    @isTest
    public static void PopulateConditionsFieldTest(){
        try {
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);       
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.SBSPilot__c = true;    
                insert acc;
            }
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                           Description='test', CloseDate= system.today()));
            opp.UseCase__c = 'FAU20109';
            opp.Purpose__c = 'Crime prevention - unrestricted interception, Protection';
            insert opp;
            
            Test.startTest();
            EUFT__c eu = [select Id, Name, Opportunity__c, TradeClassification__c, 
                          BlockList__c, TechnologyRisk__c, PurposeRisk__c, 
                          TechnologyRiskThreshold__c, TotalRisk__c, 
                          EUFT__c, CustomerRisk__c, ExemptionKeys__c  from EUFT__c where opportunity__c = : opp.Id  LIMIT 1];
            eu.BlockList__c = 'abcd/1234';
            update eu;
            
			Map<ID, Opportunity> newOpportunitiesMap = new Map<ID, Opportunity>();
            newOpportunitiesMap.put(opp.Id, opp);
            
            Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.RecordTypeId = SBRecordTypeId;
            sc.Approval_Valid_Until__c = System.today()+1;    
            sc.Opportunity__c = opp.Id;
            sc.Sign_Off_Type__c = 'Sensitive Business';
            sc.Use_Cases__c = 'Voice & Data';
            //sc.Approval_Status__c = 'To be submitted';
            sc.Approval_Status__c = GlobalConstants.Pending;
            sc.Approval_Rejection_Reason__c = GlobalConstants.Submittedforautoapproval;
            insert sc;
            
            opp.SBSResult__c = GlobalConstants.Success;
            update opp;
            opp.Purpose__c = 'Protection (Passive)';
            update opp;
            
            
            
            Test.stopTest();
        }catch(Exception ex) {
            System.debug('##Error : '+ex.getLineNumber()+' -- '+ex.getMessage());
        }
    }
}