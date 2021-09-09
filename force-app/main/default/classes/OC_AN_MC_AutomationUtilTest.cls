@IsTest
public class OC_AN_MC_AutomationUtilTest {
   
        static testMethod void createAutomationQueryTest() {
            String result = OC_AN_MC_AutomationUtils.createAutomationQuery('query', 'bName', 'accessToken', 'soapURL', 'targetDataSource', 'targetDataSourceName');
            System.assertNotEquals(null, result, 'SOAP Body needs to be returned');
        }

        static testMethod void createAutomationTest() {
            String result = OC_AN_MC_AutomationUtils.createAutomation('queryObjectId', 'queryObjectId2', 'bulletinName', 'accessToken', 'soapUrl');
            System.assertNotEquals(null, result, 'SOAP Body needs to be returned');
        }

        static testMethod void startAutomationTest() {
            String result = OC_AN_MC_AutomationUtils.startAutomation('automationId', 'accessToken', 'soapUrl');
            System.assertNotEquals(null, result, 'SOAP Body needs to be returned');
        }

}