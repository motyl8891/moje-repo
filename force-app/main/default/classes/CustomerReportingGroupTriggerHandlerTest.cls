/**
 * Test class for CustomerReportingGroupTriggerHandler
 */
@isTest(seeAllData = false)
private class CustomerReportingGroupTriggerHandlerTest {
    
    @isTest
    static void testInsertCRG() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(), false);
            insert crg;
        }

        List<CustomerReportingGroup__c> crgList = [Select Id from CustomerReportingGroup__c];
        System.assertEquals(1, crgList.size());
    }

    @isTest
    static void testUpdateCRG() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(), false);
            insert crg;
            crg.Name = 'MyTest';
            update crg;
        }

        List<CustomerReportingGroup__c> crgList = [Select Id, Name from CustomerReportingGroup__c];
        System.assertEquals(1, crgList.size());
        System.assertEquals('MyTest', crgList.get(0).Name);
    }
}