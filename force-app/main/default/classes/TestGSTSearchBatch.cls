@isTest
public class TestGSTSearchBatch {
	public static testMethod void unitTest() {
		List<GstCustomSearch__c> searchList = new List<GstCustomSearch__c>();
		User testUser = (User) TestDataGenerator.createSObject(
			new User(
				ProfileId = [SELECT Id FROM Profile WHERE Name = 'Ericsson Sales User']
				.Id,
				UserName = 'ericsson777@test.com' + System.currentTimeMillis()
			),
			true
		);
		// Creating search records with Ericsson Sales User
		for (Integer i = 0; i < 10; i++) {
			searchList.add(
				(GstCustomSearch__c) TestDataGenerator.createSObject(
					new GstCustomSearch__c(
						Search_String__c = 'TestRadio',
						CreatedById = testUser.Id
					)
				)
			);
		}
		// Creating search records with Running user
		for (Integer i = 0; i < 10; i++) {
			searchList.add(
				(GstCustomSearch__c) TestDataGenerator.createSObject(
					new GstCustomSearch__c(Search_String__c = 'TestRadio')
				)
			);
		}
		System.assertEquals(20, searchList.size());
		// running test to GSTSearchBatch
		Test.startTest();
		insert searchList;
		GSTSearchBatch obj = new GSTSearchBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();
		List<GstCustomSearch__c> searchListtemp = [
			SELECT id
			FROM GstCustomSearch__c
		];
		//Validating number of records in the system after deletion
		System.assertEquals(10, searchListtemp.size());
	}
}