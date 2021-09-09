/**
 * @File Name          : RecentSearch_Test.cls
 * @Description        : U-1146 (Test class for RecentSearch)
 * @Author             : Bhushan K
 * @Group              :
 * @Last Modified By   : Ankit Jain
 * @Last Modified On   : 2019-9-20
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    2019-9-16 16:02:32       Bhushan K          Initial Version
 * 2.0    2019-9-20 18:30:00       Ankit Jain         Updated for covering exception code
 **/
@isTest
private class RecentSearch_Test {
	@testSetup
	static void setupTestData() {
		Profile sysAdmin = [
			SELECT Id
			FROM Profile
                            WHERE Name =: 'Ericsson Service'
			LIMIT 1
		];
		User urs = new User(
			Email = 'access.tester.invalid@ericsson.com',
			Alias = 'Access',
			Username = 'access.tester.invalid@ericsson.com',
			LastName = 'Tester',
			FirstName = 'Test',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = sysAdmin.Id,
			LanguageLocaleKey = 'en_US'
		);
		insert urs;
	}
	static testMethod void test_recentsearchresult1() {
		test.startTest();
		User usr = [
			SELECT id
			FROM user
			WHERE email = 'access.tester.invalid@ericsson.com'
			LIMIT 1
		];
		List<GstCustomSearch__c> listGstCustomSearch;
		System.runAs(usr) {
			GstCustomSearch__c GstSearch = new GstCustomSearch__c(
				Search_String__c = 'test123'
			);
			insert GstSearch;
			listGstCustomSearch = RecentSearch.recentsearchresult();
		}
		test.stopTest();
		System.assertEquals(true, listGstCustomSearch.size() > 0);
	}
	static testMethod void test_recentsearchresult2() {
		Test.startTest();
		User usr = [
			SELECT id
			FROM user
			WHERE email = 'access.tester.invalid@ericsson.com'
			LIMIT 1
		];
		List<GstCustomSearch__c> listGstCustomSearch;
		System.runAs(usr) {
			listGstCustomSearch = RecentSearch.recentsearchresult();
		}
		test.stopTest();
		System.assertEquals(true, listGstCustomSearch.size() == 0);
	}
}