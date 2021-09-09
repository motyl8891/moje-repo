/******************************************************************************************
*
*      	@author       : Ankita Mahobia
*      	@date         : 24-03-2020
		@description  : Test class for SecondaryApprovalTrigger

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Ankita Mahobia			24-03-2020				Initial Version
Shubham Kadam			20-07-2020				Test methods for setOppDescriptionFromOpportunity, updatePreSalesAdjustmentStatus, 
												UpdateOpportunitySalesComplianceStatus, UpdateOpportunityTradeComplianceStatus
******************************************************************************************/
@isTest(seeAllData = false)
private class SecondaryApprovalTriggerTest {
    /****************************************************************
	* @author: Ankita Mahobia
	* @date: 24-03-2020
	* @description: This method is a test method for calculatePurposeRisk, setOppDescriptionFromOpportunity
	*****************************************************************/
    public static testMethod void test1(){
        try{
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        
        CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
        Account acc = (Account)TestDataGenerator.createSObject(new Account(),false);
        crg.CRG_ID__c = '100001';
        crg.MarketArea__c = 'MANA';
        System.runAs(testUser){
            insert crg;
            acc.CustomerReportingGroup__c = crg.Id;
            insert acc;
        }
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777888999', 
                                                                                       Locked_To_PP__c = true, Description = 'test desc'));
        insert opp;
        
        
        Purpose__c pr = new Purpose__c(Name = 'Other unclear purpose',RiskValue__c = 8);
        insert pr;
        
        Purpose__c pr2 = new Purpose__c(Name = 'Mobile Banking');
        pr2.RiskValue__c = 3;
        insert pr2;
        
        Secondary_Approval__c sc = new Secondary_Approval__c();
        sc.Opportunity__c = opp.Id;
        sc.MainPurpose__c = 'Other unclear purpose';
        insert sc;
        
        Secondary_Approval__c secApp = [SELECT id, MainPurposeRisk__c, MainPurpose__c from Secondary_Approval__c where Id =:sc.Id LIMIT 1];
        system.assertEquals(8, secApp.MainPurposeRisk__c);
        
        secApp.MainPurpose__c = 'Mobile Banking';
        update secApp;
        
        Secondary_Approval__c updatedSecApp = [SELECT id, MainPurposeRisk__c, MainPurpose__c from Secondary_Approval__c where Id =:sc.Id LIMIT 1];
        system.assertEquals(3, updatedSecApp.MainPurposeRisk__c);
        } 
       catch (DMLException e) {
        	System.debug('**Error '+e.getMessage()); 
    	}
    }
    
    /****************************************************************
	* @author: Shubham Kadam 
	* @date: 20-07-2020
	* @description: This method is a test method for updatePreSalesAdjustmentStatus, UpdateOpportunityTradeComplianceStatus
	*****************************************************************/
    @isTest
    public static void updatePreSalesAdjustmentStatusTest()
    {
        try { 
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
																					UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);       
		System.runAs(testUser){  
		acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
		insert acc;
        }
             
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
																					   Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
																					   Description='test', CloseDate= system.today()));  
		insert opp;
            
        Secondary_Approval__c sc = new Secondary_Approval__c();
        //sc.Name = 'test sc';
        sc.Approval_Valid_Until__c = System.today()+1;    
        sc.Opportunity__c = opp.Id;
        sc.Sign_Off_Type__c = 'Trade Compliance';    
        sc.Approval_Status__c = 'Pending';    
        insert sc;
            
        Test.startTest();    
        PreSalesBudgetRequests__c ps = new PreSalesBudgetRequests__c();
        ps.Opportunity__c = opp.Id;
        ps.Secondary_Approval__c = sc.Id;
        insert ps;
            
        sc.Approval_Status__c = 'Approved';
        update sc; 
        sc.Approval_Status__c = 'Rejected';
        update sc; 
        
        List<Secondary_Approval__c> newSecondaryApproval = new List<Secondary_Approval__c>();
        newSecondaryApproval.add(sc);
            
        SecondaryApprovalTriggerHelper.updatePreSalesAdjustmentStatus(newSecondaryApproval);             
        Test.stopTest();
            
        SecondaryApprovalTriggerHelper.calculatePurposeRisk(null, null);
        SecondaryApprovalTriggerHelper.setOppDescriptionFromOpportunity(null); 
        SecondaryApprovalTriggerHelper.updatePreSalesAdjustmentStatus(null);
        SecondaryApprovalTriggerHelper.UpdateOpportunityTradeComplianceStatus(null, null);  
        System.assertEquals(opp.Anticipated_Deal_Value__c,500);		
        } catch (DMLException e) {
        	System.debug('**Error '+e.getMessage()); 
    	}
        
    }
    
    /****************************************************************
	* @author: Shubham Kadam 
	* @date: 20-07-2020
	* @description: This method is a test method for UpdateOpportunitySalesComplianceStatus
	*****************************************************************/
    @isTest
    public static void UpdateOpportunitySalesComplianceStatusTest()
    {
        try { 
        SecondaryApprovalTriggerHelper.UpdateOpportunitySalesComplianceStatus(null); 
            
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
																					UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);       
		System.runAs(testUser){  
		acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
        acc.SBSPilot__c = false;    
		insert acc;
        }
 
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
																					   Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
																					   Description='test', CloseDate= system.today()));  
		insert opp;
            
        Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;    
            
        Secondary_Approval__c sc = new Secondary_Approval__c();
        sc.RecordTypeId = SBRecordTypeId;
        //sc.Name = 'test sc';
        sc.Approval_Valid_Until__c = System.today()+1;    
        sc.Opportunity__c = opp.Id;
        sc.Sign_Off_Type__c = 'Sensitive Business';
        sc.Use_Cases__c = 'Voice & Data';
        sc.Approval_Status__c = 'Pending';
        sc.Approval_Rejection_Reason__c = 'Submitted for auto approval';     
        insert sc;  
   		            
        Test.startTest();
        sc.Approval_Status__c = 'Rejected';
        sc.Approval_Rejection_Reason__c = 'Rejected by SB team';        
        update sc;
        sc.Approval_Status__c = 'Pending';
        sc.Approval_Rejection_Reason__c = 'Submitted for auto approval';
        update sc;      
        sc.Approval_Status__c = 'Approved';
        sc.Approval_Rejection_Reason__c = 'Approved';
        update sc;
          
        List<Secondary_Approval__c> newSecondaryApproval = new List<Secondary_Approval__c>();
        newSecondaryApproval.add(sc);
  		
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp1',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
																					   Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
																					   Description='test1', CloseDate= system.today()));  
		insert opp1;
            
        Secondary_Approval__c sc1 = new Secondary_Approval__c();
        sc1.RecordTypeId = SBRecordTypeId;
        //sc1.Name = 'test sc';
        sc1.Approval_Valid_Until__c = System.today()+1;    
        sc1.Opportunity__c = opp1.Id;
        sc1.Sign_Off_Type__c = 'Sensitive Business';
        sc1.Use_Cases__c = 'Voice & Data';  
        sc1.Approval_Status__c = 'Pending'; 
        sc1.Approval_Rejection_Reason__c = null;     
        insert sc1; 
 
        List<Secondary_Approval__c> newSecondaryApproval1 = new List<Secondary_Approval__c>();
        newSecondaryApproval1.add(sc1);

        SecondaryApprovalTriggerHelper.UpdateOpportunitySalesComplianceStatus(newSecondaryApproval);  
        SecondaryApprovalTriggerHelper.UpdateOpportunitySalesComplianceStatus(newSecondaryApproval1);     
        Test.stopTest();
		 System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        } catch (DMLException e) {
        	System.debug('**Error '+e.getMessage()); 
    	}
       
    }
    
    /****************************************************************
* @author: Shubham Kadam 
* @date: 28-01-2021
* @description: This method is a test method for sensitiveBusinessApprovalSubmission
*****************************************************************/
    @isTest
    public static void sensitiveBusinessApprovalSubmissionTest()
    {
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
            opp.ManualSBStatusRequired__c = true;
            opp.SBSAutomationRequired__c = true;
            insert opp;
            
            Test.startTest();

            Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;    
            List<Secondary_Approval__c> newSecondaryApproval = new List<Secondary_Approval__c>();
            Map<ID, Secondary_Approval__c> oldMap = new Map<ID, Secondary_Approval__c>();
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.RecordTypeId = SBRecordTypeId;
            sc.Approval_Valid_Until__c = System.today()+1;    
            sc.Opportunity__c = opp.Id;
            sc.Sign_Off_Type__c = 'Sensitive Business';
            sc.Use_Cases__c = 'Voice & Data';
            sc.Approval_Status__c = 'To be submitted';
            sc.Approval_Rejection_Reason__c = 'To be submitted';     
            insert sc;
            oldmap.put(sc.Id, sc);
			
            sc.Approval_Status__c = 'Pending';
            sc.Approval_Rejection_Reason__c = 'Submitted for manual approval';    
            update sc;
            newSecondaryApproval.add(sc);
                
            SecondaryApprovalTriggerHelper.sensitiveBusinessApprovalSubmission(sc.Id);
            SecondaryApprovalTriggerHelper.callSBSCalloutOrApprovalProcess(newSecondaryApproval, oldmap);
            SecondaryApprovalTriggerHelper.sensitiveBusinessApprovalSubmission(null);
            SecondaryApprovalTriggerHelper.callSBSCalloutOrApprovalProcess(null, null);
            SecondaryApprovalTriggerHelper.restrictCreationOfSecondaryApproval(null);
            SecondaryApprovalTriggerHelper.updateActiveSensitiveBusinessApprovalOnOpp(null);
            SecondaryApprovalTriggerHelper.updateisActiveFlag(null, null, null);
            Test.stopTest();
            
            System.assertEquals(opp.Anticipated_Deal_Value__c,500);            
        }catch (DMLException e) {
            System.debug('**Error '+e.getMessage()); 
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam 
* @date: 28-01-2021
* @description: This method is a test method for clearActiveSensitiveBusinessApprovalOnOpp
*****************************************************************/
    @isTest
    public static void clearActiveSensitiveBusinessApprovalOnOppTest()
    {
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
            insert opp;
            
            Test.startTest();

            Id SBRecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;    
            List<Secondary_Approval__c> newSecondaryApproval = new List<Secondary_Approval__c>();
            Map<ID, Secondary_Approval__c> oldMap = new Map<ID, Secondary_Approval__c>();
            Map<ID, Secondary_Approval__c> newMap = new Map<ID, Secondary_Approval__c>();
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.RecordTypeId = SBRecordTypeId;
            sc.Approval_Valid_Until__c = System.today()+1;    
            sc.Opportunity__c = opp.Id;
            sc.Sign_Off_Type__c = 'Sensitive Business';
            sc.Use_Cases__c = 'Voice & Data';
            sc.Approval_Status__c = 'To be submitted';
            sc.Approval_Rejection_Reason__c = 'To be submitted';     
            insert sc;
            oldmap.put(sc.Id, sc);
			
            sc.Approval_Status__c = GlobalConstants.COMPLETED;
            sc.Approval_Rejection_Reason__c = 'Accepted Approval';
            sc.isActive__c = false;
            update sc;
            newSecondaryApproval.add(sc);
			newmap.put(sc.Id, sc);
            
            SecondaryApprovalTriggerHelper.clearActiveSensitiveBusinessApprovalOnOpp(newSecondaryApproval, oldmap, newmap);
            SecondaryApprovalTriggerHelper.clearActiveSensitiveBusinessApprovalOnOpp(null, null, null);
            Test.stopTest();
            
            System.assertEquals(opp.Anticipated_Deal_Value__c,500);            
        }catch (DMLException e) {
            System.debug('**Error '+e.getMessage()); 
        }
    }
}