@isTest
public class OC_AN_BulletinServicesTest {
    private static final String BULLETIN_NAME = 'Test Revision Bulletin';

    @testsetup
    static void setup() {
        List<OC_AN_Bulletin_Account_Product__c> bulletinAccountProductList = new List<OC_AN_Bulletin_Account_Product__c>();

        Id migrationUserProfileId = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Migration User Profile'
        ].Id;

        User testuser = (User) OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com' + System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        insert testuser;

        System.runAs(testUser) {
        Id serviceProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Ericsson Service'
        ].Id;

        User serviceUser = (User) OC_TestDataGenerator.createSObject(new User());
        serviceUser.ProfileId = serviceProfileId;
        serviceUser.IsActive = true;
        insert serviceUser;

        Account salesAccount = (Account) OC_TestDataGenerator.createSObject(new Account());
        salesAccount.Account_Type__c = OC_AN_Constants.sales;
        salesAccount.RecordTypeId = OC_AN_Constants.recTypeId_forSalesAccount;
        insert salesAccount;

        Account serviceAccount = (Account) OC_TestDataGenerator.createSObject(new Account());
        serviceAccount.Account_Type__c = OC_AN_Constants.service;
        serviceAccount.ParentId = salesAccount.Id;
        serviceAccount.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
        insert serviceAccount;

        Group publicGroupToInsert = (Group) OC_TestDataGenerator.createSobject(new Group());
        publicGroupToInsert.Name = 'A&N - Test Group';
        insert publicGroupToInsert;

        GroupMember groupMemberToInsert = (GroupMember) OC_TestDataGenerator.createSobject(new GroupMember());
        groupMemberToInsert.GroupId = publicGroupToInsert.Id;
        groupMemberToInsert.UserOrGroupId = serviceUser.Id;
        insert groupMemberToInsert;

        OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(
            new OC_AN_Bulletin_Template__c());
        insert bulletinTemplateToInsert;

        OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(
            new OC_AN_Bulletin__c());
        bulletinToInsert.OC_AN_Bulletin_Template__c = bulletinTemplateToInsert.Id;
        bulletinToInsert.Name = BULLETIN_NAME;
        bulletinToInsert.OC_AN_ExternalAutomationId__c = BULLETIN_NAME;
        //bulletinToInsert.OC_AN_Current_Status__c = OC_AN_Constants.Internally_Published_Status;
        insert bulletinToInsert;

        OC_AN_Bulletin_Account_Product__c groupToInsert = new OC_AN_Bulletin_Account_Product__c();
        groupToInsert.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
        groupToInsert.OC_AN_Public_Group_Name__c = publicGroupToInsert.Name;
        groupToInsert.OC_AN_Bulletin__c = bulletinToInsert.Id;
        bulletinAccountProductList.add(groupToInsert);

        OC_AN_Bulletin_Account_Product__c extDistributorToInsert = new OC_AN_Bulletin_Account_Product__c();
        extDistributorToInsert.RecordTypeId = OC_AN_Constants.recTypeId_Account;
        extDistributorToInsert.OC_AN_Public_Group_Name__c = serviceAccount.Name;
        extDistributorToInsert.OC_AN_Bulletin__c = bulletinToInsert.Id;
        bulletinAccountProductList.add(extDistributorToInsert);
        insert bulletinAccountProductList;
        }
    }

    @isTest
    static void createNewRevisionRecordFromMainBulletin() {
        Map<String, OC_AN_MockBulletinApproved.Response> responses = new Map<String, OC_AN_MockBulletinApproved.Response>();
        
        /*@Description :accessToken, you need URL (Key) then a Response object with the data, status code and if it should throw a exception or not.*/
        responses.put('callout:SFMC/v2/token',
        new OC_AN_MockBulletinApproved.Response('{"access_token":"test"}',
            200,
        false)); 
        Test.setMock(HttpCalloutMock.class, new OC_AN_MockBulletinApproved(responses));
        Test.startTest();
        OC_AN_BulletinServices.sendEmailViaJourney(new List<Id>(new Map<Id,OC_AN_Bulletin_Account_Product__c>([SELECT Id FROM OC_AN_Bulletin_Account_Product__c LIMIT 1]).keyset()));
        System.assertNotEquals(null,responses,'The callout returned a null response.');
        Test.stopTest();
    }
}