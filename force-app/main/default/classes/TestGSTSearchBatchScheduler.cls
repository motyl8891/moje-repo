@isTest
public class TestGSTSearchBatchScheduler {
	public static testMethod void unitTest() {
		Test.StartTest();
		GSTSearchBatchScheduler sh1 = new GSTSearchBatchScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test check', sch, sh1);
		Test.stopTest();
	}
}