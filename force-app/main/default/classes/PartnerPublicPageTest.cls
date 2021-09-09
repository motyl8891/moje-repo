@isTest
public class PartnerPublicPageTest {
	static testMethod void checkframeapexTest() {
		Account acc = new Account();
		Test.StartTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		PartnerPublicPage publicPage = new PartnerPublicPage(sc);
		publicPage.checkframeapex();
		Test.StopTest();
	}
}