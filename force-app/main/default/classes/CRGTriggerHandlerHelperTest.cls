/**
 * Test class for CRGTriggerHandlerHelper
 */
@isTest(seeAllData = false)
private class CRGTriggerHandlerHelperTest {
    
    @isTest
    static void testUpdateAccountCUPrimaryKAMPositive() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestCRG'), true);

        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), CommunityNickname = 'Test2',
                         UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestCRG2'), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(
                                                new CustomerReportingGroup__c(Manager__c = 'TestCRG'), false);

            insert crg;
        }

        CustomerReportingGroup__c crg1 = [SELECT Id, Manager__c, Account_Primary_KAM__c, Account_Primary_KAM__r.Signum__c
                                          FROM CustomerReportingGroup__c];

        System.assertEquals(testUser.Id, crg1.Account_Primary_KAM__c);
        System.assertEquals('TestCRG', crg1.Account_Primary_KAM__r.Signum__c);
        crg1.Manager__c = 'TestCRG2';
        crg1.Account_Primary_KAM__c = null;
        update crg1;
        CustomerReportingGroup__c crg = [SELECT Id, Manager__c, Account_Primary_KAM__c, Account_Primary_KAM__r.Signum__c
                                         FROM CustomerReportingGroup__c LIMIT 1];
        System.assertEquals('TestCRG2', crg.Account_Primary_KAM__r.Signum__c);
    }

    @isTest
    static void testUpdateAccountCUPrimaryKAMNegative() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(
                                                new CustomerReportingGroup__c(Manager__c = 'TestCRG'), false);

            insert crg;
        }

        CustomerReportingGroup__c crg1 = [SELECT Id, Manager__c, Account_Primary_KAM__c, Account_Primary_KAM__r.Signum__c
                                          FROM CustomerReportingGroup__c];

        System.assertEquals(null, crg1.Account_Primary_KAM__c);
    }

    @isTest
    static void queryAndUpdateTargetsOnCU_test() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestCRG'), true);


        System.runAs(testUser) {

            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(
                                                new CustomerUnit__c(), false);
            insert cu;

            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(
                                                new CustomerReportingGroup__c(Manager__c = 'TestCRG', 
                                                    CustomerUnit__c = cu.Id,
                                                    Q1_NY_Target__c = 1,
                                                    Q1_Target__c = 2,
                                                    Q2_NY_Target__c = 3,
                                                    Q2_Target__c = 4,
                                                    Q3_NY_Target__c = 5,
                                                    Q3_Target__c = 6,
                                                    Q4_NY_Target__c = 7,
                                                    Q4_Target__c = 8, 
                                                    Annual_Target__c = 20, 
                                                    Next_Year_Annual_Target__c = 16
                                                    ), false);
            insert crg;

            cu = [SELECT Id, Q1_Target__c, 
                    Q1_NY_Target__c, 
                    Q2_Target__c, 
                    Q2_NY_Target__c, 
                    Q3_Target__c, 
                    Q3_NY_Target__c, 
                    Q4_Target__c, 
                    Q4_NY_Target__c, 
                    Annual_CU_Target__c, 
                    Next_Year_s_Annual_CU_Target__c
                FROM CustomerUnit__c
                WHERE Id =: cu.Id];

            System.assertEquals(crg.Q1_Target__c, cu.Q1_Target__c);
            System.assertEquals(crg.Q1_NY_Target__c, cu.Q1_NY_Target__c);
            System.assertEquals(crg.Q2_Target__c, cu.Q2_Target__c);
            System.assertEquals(crg.Q2_NY_Target__c, cu.Q2_NY_Target__c);
            System.assertEquals(crg.Q3_Target__c, cu.Q3_Target__c);
            System.assertEquals(crg.Q3_NY_Target__c, cu.Q3_NY_Target__c);
            System.assertEquals(crg.Q4_Target__c, cu.Q4_Target__c);
            System.assertEquals(crg.Q4_NY_Target__c, cu.Q4_NY_Target__c);
            System.assertEquals(crg.Annual_Target__c, cu.Annual_CU_Target__c);
            System.assertEquals(crg.Next_Year_Annual_Target__c, cu.Next_Year_s_Annual_CU_Target__c);

            CustomerUnit__c gcu = (CustomerUnit__c)TestDataGenerator.createSObject(
                                                new CustomerUnit__c(Type__c = 'GCU'), false);
            insert gcu;

            CustomerReportingGroup__c crg2 = (CustomerReportingGroup__c)TestDataGenerator.createSObject(
                                                new CustomerReportingGroup__c(Manager__c = 'TestCRG',
                                                    CRG_ID__c = 'Test2', 
                                                    GlobalCustomerUnit__c = gcu.Id,
                                                    Q1_NY_Target__c = 1,
                                                    Q1_Target__c = 2,
                                                    Q2_NY_Target__c = 3,
                                                    Q2_Target__c = 4,
                                                    Q3_NY_Target__c = 5,
                                                    Q3_Target__c = 6,
                                                    Q4_NY_Target__c = 7,
                                                    Q4_Target__c = 8, 
                                                    Annual_Target__c = 20, 
                                                    Next_Year_Annual_Target__c = 16
                                                    ), false);
            insert crg2;

            gcu = [SELECT Id, Q1_Target__c, 
                    Q1_NY_Target__c, 
                    Q2_Target__c, 
                    Q2_NY_Target__c, 
                    Q3_Target__c, 
                    Q3_NY_Target__c, 
                    Q4_Target__c, 
                    Q4_NY_Target__c, 
                    Annual_CU_Target__c, 
                    Next_Year_s_Annual_CU_Target__c
                FROM CustomerUnit__c
                WHERE Id =: gcu.Id];

            System.assertEquals(crg.Q1_Target__c, gcu.Q1_Target__c);
            System.assertEquals(crg.Q1_NY_Target__c, gcu.Q1_NY_Target__c);
            System.assertEquals(crg.Q2_Target__c, gcu.Q2_Target__c);
            System.assertEquals(crg.Q2_NY_Target__c, gcu.Q2_NY_Target__c);
            System.assertEquals(crg.Q3_Target__c, gcu.Q3_Target__c);
            System.assertEquals(crg.Q3_NY_Target__c, gcu.Q3_NY_Target__c);
            System.assertEquals(crg.Q4_Target__c, gcu.Q4_Target__c);
            System.assertEquals(crg.Q4_NY_Target__c, gcu.Q4_NY_Target__c);
            System.assertEquals(crg.Annual_Target__c, gcu.Annual_CU_Target__c);
            System.assertEquals(crg.Next_Year_Annual_Target__c, gcu.Next_Year_s_Annual_CU_Target__c);
        }
    }
}