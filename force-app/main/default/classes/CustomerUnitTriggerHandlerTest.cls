/**
 * Test class for CustomerUnitTriggerHandler
 */
@isTest(seeAllData = false)
private class CustomerUnitTriggerHandlerTest {

    @isTest
	static void testUpdateCU() {
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id
		                FROM Profile
		                WHERE Name =:GlobalConstants.INTEGRATIONUSERPROFILENAME].Id,
		                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
			CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
            insert cu;
			Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			insert acc;
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
			insert opp;
            cu.GCU_Head__c = testUser.Id;
            cu.GCU_Commercial_Head__c = testUser.Id;
			update cu;
		} 

		List<CustomerUnit__c> cuList = [Select Id, ApproversChanged__c, Type__c from CustomerUnit__c];
		System.assertEquals(1, cuList.size());
		System.assertEquals('GCU', cuList.get(0).Type__c);
        System.assertEquals(true, cuList.get(0).ApproversChanged__c);
	}
}