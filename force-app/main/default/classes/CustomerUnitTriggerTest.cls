/**
 * Test class for CustomerUnitTrigger
 */
@isTest(seeAllData = false)
private class CustomerUnitTriggerTest {

	@isTest
	static void testInsertCU() {
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id
		                FROM Profile
		                WHERE Name =:GlobalConstants.INTEGRATIONUSERPROFILENAME].Id,
		                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
			CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(GCU_Head__c = testUser.Id), false);
			Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			insert acc;
			insert cu;
		}
		List<CustomerUnit__c> cuList = [Select Id from CustomerUnit__c];
		System.assertEquals(1, cuList.size());
	}

	@isTest
	static void testUpdateCU() {
		CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(), false);
		insert cu;
		cu.Type__c = 'GCU';
		update cu;
		List<CustomerUnit__c> cuList = [Select Id, Type__c from CustomerUnit__c];
		System.assertEquals(1, cuList.size());
		System.assertEquals('GCU', cuList.get(0).Type__c);
	}
}