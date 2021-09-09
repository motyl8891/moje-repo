@isTest
public class CustomerUnitTextUpdateTest {
	@testSetup
	static void setup() {
		List<CustomerReportingGroup__c> crg = new List<CustomerReportingGroup__c>();
		for (Integer i = 0; i < 200; i++) {
			CustomerReportingGroup__c g = new CustomerReportingGroup__c();
			g.Customer_Unit_Text__c = 'Testing';
			crg.add(g);
		}
		insert crg;
	}

	static testMethod void test() {
		Test.startTest();

		CustomerUnitTextUpdate cutu = new CustomerUnitTextUpdate();
		ID batchId = Database.executeBatch(cutu);
		Test.stopTest();

		System.assertEquals(
			200,
			[
				SELECT COUNT()
				FROM CustomerReportingGroup__c
				WHERE Customer_Unit_Text__c = ''
			]
		);
	}
}