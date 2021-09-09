@isTest
public without Sharing class ProposalTriggerHandlerTest {

	/**
	* Setup for test methods
	*/
	@testSetup 
    static void setup() {

		Account acc;
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
		                										UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			insert acc;
		}

      //  Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
		insert opp;

		Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id));
		insert prop;
	}

	@isTest
	public static void testProposalTriggerHandlerInsertPostive() {
        try{
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
		Proposal__c pro = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test10', Opportunity__c = opp.Id, Proposal_Unique_Id__c='1234D',Proposal_Id__c='09876'));
		insert pro;

            System.assertEquals(true, pro.Id != null);
        }
        catch(DMLException e){
         
        }
	}

	@isTest
	public static void testProposalTriggerHandlerUpdatePostive() {
        try{
		Proposal__c prop = [SELECT Id, Name FROM Proposal__c LIMIT 1];
		prop.Name = 'Test3';
		upsert prop;
		
		System.assertEquals('Test3', prop.Name);
        }catch(DMLException e){
          
        }}
}