/****************************************************************
* @author: Shubham Kadam 
* @date: 09-07-2020
* @User Story: U-1989
* @description: This class is a test class for SalesIdeaTriggerHelper
*****************************************************************/
@isTest
public class SalesIdeaTriggerHelperTest {
    /****************************************************************
	* @author: Shubham Kadam 
	* @date: 09-07-2020
	* @description: This method is a test setup method
	*****************************************************************/
	@testSetup static void setup()
    {
        try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        //catch block coverage -    
        SalesIdeaTriggerHelper.setSalesIdeaOwner(null, null);
        SalesIdeaTriggerHelper.updateOpportunityOnSalesIdea(null, null);
            
        Account acc;
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
																					UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        testUser.SDOD_Organization_Type__c='SDOD-LHR-EA';
        update testUser;
        
		System.runAs(testUser){  
		acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
		insert acc;
		
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
																					   Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
																					   Description='test', CloseDate= system.today()));  
		insert opp;
        
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp1',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
																					   Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
																					   Description='test1', CloseDate= system.today()));  
		insert opp1;
		
        Id CURecordTypeId = GlobalConstants.cuRecordTypeId;
		CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(RecordTypeId=CURecordTypeId, ID__c='100143',Type__c='CU',
											  Name='CU West Africa & Morocco', ResponsibleSignum__c='EELNOWA', AP_Lower_Limit__c=1111111,
											  AP_Upper_Limit__c=27777778, Small_Value_Limit__c=1111111, Exempt_from_Pre_Sales_Budget_Approval__c=true,
											  Annual_CU_Target__c=0, Next_Year_s_Annual_CU_Target__c=0, Q1_NY_Target__c=0, Q1_Target__c=0,
											  Q2_NY_Target__c=0, Q2_Target__c=0, Q3_NY_Target__c=0, Q3_Target__c=0, Q4_NY_Target__c=0, Q4_Target__c=0));
		insert cu;
		
		CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(Name='Angola Telecom',
											  MarketArea__c='MMEA', CRG_ID__c='200513', Market__c='AO', Type__c='KA',Manager__c='EELHOKA', 
											  CustomerUnit__c=cu.Id, Account_CU_Head__c=testUser.Id, Account_Primary_KAM__c=testUser.Id));
		insert crg;
		
        List<SDOD_Lead__c> salesIdeaList = new List<SDOD_Lead__c>();
		Id salesIdeaSOGRecordTypeId = GlobalConstants.sogRecordTypeId;
		SDOD_Lead__c salesIdea = (SDOD_Lead__c)TestDataGenerator.createSObject(new SDOD_Lead__c(RecordTypeId=salesIdeaSOGRecordTypeId, Title__c='Test',
											   How_to_identify__c='Discussion with CU', MarketArea__c='MMEA', Business_Area__c='BDGS', 
											   Country__c='AO', Product_Or_Service_Area__c='SBSS',LHR__c=testUser.Id,
											   Commodity__c='Services (CS)', Customer_Reporting_Group__c=crg.Id, Opportunity_ID__c=Opp.OpportunityNumber__c));
        
        salesIdeaList.add(salesIdea);
        
        Id salesIdeaAoSRecordTypeId = GlobalConstants.aosRecordTypeId;
		SDOD_Lead__c salesIdea1 = (SDOD_Lead__c)TestDataGenerator.createSObject(new SDOD_Lead__c(RecordTypeId=salesIdeaAoSRecordTypeId, Title__c='Test1',
											   What_is_the_original_project_scope__c='test1', How_to_identify__c='Discussion with CU', MarketArea__c='MMEA', 
                                               Business_Area__c='BDGS', Country__c='AO', Product_Or_Service_Area__c='SBSS', 
											   Commodity__c='Services (CS)', Customer_Reporting_Group__c=crg.Id, EA__c=testUser.Id, 
                                               How_was_it_sold_to_Customer__c='test1'));
        
		salesIdeaList.add(salesIdea1);
        Database.insert(salesIdeaList);
        }
        } catch(DmlException e)
        {
            //System.debug(e.getLineNumber() +' '+e.getMessage()); 
        }
    }
    
    /****************************************************************
	* @author: Shubham Kadam 
	* @date: 09-07-2020
	* @description: This method is a test method for setSalesIdeaOwner
	*****************************************************************/
    @isTest
    public static void setSalesIdeaOwnerTest()
    {
        try { 
            List<SDOD_Lead__c> salesIdeas = [select ID from SDOD_Lead__c
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson778@test.com'+System.currentTimeMillis()),true);
            testUser2.SDOD_Organization_Type__c='SDOD-LHR-EA';
            update testUser2;
            
            Map<Id,SDOD_Lead__c> oldSalesIdeaMap = new  Map<Id,SDOD_Lead__c>();
            oldSalesIdeaMap.put(salesIdeas[0].Id, salesIdeas[0]);
            oldSalesIdeaMap.put(salesIdeas[1].Id, salesIdeas[1]);
            
            salesIdeas[0].LHR__c = testUser2.Id;
            salesIdeas[1].EA__c = testUser2.Id;
            Database.update(salesIdeas);
            
            List<SDOD_Lead__c> newSalesIdea = new List<SDOD_Lead__c>();
            newSalesIdea.add(salesIdeas[0]);
            newSalesIdea.add(salesIdeas[1]);
            
            Test.startTest();
            SalesIdeaTriggerHelper.setSalesIdeaOwner(newSalesIdea, oldSalesIdeaMap);
            Test.stopTest();
            System.assertEquals(salesIdeas[0].LHR__c, salesIdeas[0].OwnerId);
            System.assertEquals(salesIdeas[1].EA__c, salesIdeas[1].OwnerId);
        }
        catch (DMLException e) {
        	//System.debug(e.getMessage()); 
    	}
    }
    
    /****************************************************************
	* @author: Shubham Kadam 
	* @date: 09-07-2020
	* @description: This method is a test method for updateOpportunityOnSalesIdea
	*****************************************************************/
    @isTest
    public static void updateOpportunityOnSalesIdeaTest()
    {
        try {
            SDOD_Lead__c salesIdea = [select ID,Opportunity_ID__c,Opportunity__c from SDOD_Lead__c where Title__c='Test'
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            Opportunity Opp = [Select ID,OpportunityNumber__c from Opportunity where Name='Test Opp1'
                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];

            Map<Id,SDOD_Lead__c> oldSalesIdeaMap = new  Map<Id,SDOD_Lead__c>();
            oldSalesIdeaMap.put(salesIdea.Id, salesIdea);
            
            salesIdea.Opportunity_ID__c = Opp.OpportunityNumber__c;
            Database.update(salesIdea);

            List<SDOD_Lead__c> newSalesIdea = new List<SDOD_Lead__c>();
            newSalesIdea.add(salesIdea);

            Test.startTest();
            SalesIdeaTriggerHelper.updateOpportunityOnSalesIdea(newSalesIdea, oldSalesIdeaMap);
            Test.stopTest();
            System.assertEquals(Opp.OpportunityNumber__c, SalesIdea.Opportunity_ID__c);
        }
        catch (DMLException e) {
        	//System.debug(e.getMessage()); 
    	}
    }
}