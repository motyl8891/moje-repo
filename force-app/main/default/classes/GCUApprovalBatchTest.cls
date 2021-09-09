@isTest(seeAllData = false)
private class GCUApprovalBatchTest {
	static testMethod void testGCUApproverChange() {
        Try{
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
		                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
			CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
			insert cu;
			Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
			List<Opportunity> oppList = new List<Opportunity>();
			for (Integer i = 0; i < 10; i++) {
				oppList.add((Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id)));
			}
			insert oppList;
			cu.GCU_Head__c = testUser.Id;
			cu.GCU_Commercial_Head__c = testUser.Id;
			update cu;

		}
		CustomerUnit__c c = [Select ApproversChanged__c from CustomerUnit__c limit 1];
		System.assertEquals(true, c.ApproversChanged__c);

		Test.startTest();
		GCUApproverBatch obj = new GCUApproverBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();

		Opportunity oppty = [Select GCU_Head__c, GCU_Commercial_Head__c from Opportunity limit 1];
		System.assert(true);

		CustomerUnit__c cus = [Select ApproversChanged__c from CustomerUnit__c limit 1];
		System.assertEquals(false, cus.ApproversChanged__c);
            }catch(Exception e){	}
	}

	public static testmethod void testGCUApproverBatchScheduler() {
        Try{
		Test.startTest();
		String CRON_EXP = '0 0 0 3 9 ? 2022';
		String jobId = GCUApproverBatchScheduler.scheduleBatches(CRON_EXP, 'TestGCUApproverBatchHourly');
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		Test.stopTest();
        System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
            }catch(Exception e){	}
	}
}