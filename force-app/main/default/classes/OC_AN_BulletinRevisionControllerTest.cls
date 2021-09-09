/**
* @File Name          : OC_AN_BulletinRevisionControllerTest
* @Description        : Test Class for OC_AN_BulletinRevisionController
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 5th August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-05              	IBM               Initial Version
**/
@isTest
public class OC_AN_BulletinRevisionControllerTest {
  private static final String BULLETIN_NAME = 'Test Revision Bulletin';
  private static final String EXTERNALLY_PUBLISHED_STATUS = 'Externally Published';

  /**
   * @Description : Data setup for test class.
   **/
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

      OC_AN_Public_Group__c publicGroupToInsert = new OC_AN_Public_Group__c();
      publicGroupToInsert.Name = 'A&N - Test Group';
      insert publicGroupToInsert;

      OC_AN_Group_Member__c groupMemberToInsert = new OC_AN_Group_Member__c();
      groupMemberToInsert.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroupMember;
      groupMemberToInsert.OC_AN_Child_Group__c = publicGroupToInsert.Id;
      groupMemberToInsert.OC_AN_User__c = serviceUser.Id;
      insert groupMemberToInsert;

      OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin_Template__c());
      insert bulletinTemplateToInsert;

      OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin__c());
      bulletinToInsert.OC_AN_Bulletin_Template__c = bulletinTemplateToInsert.Id;
      bulletinToInsert.Name = BULLETIN_NAME;
      bulletinToInsert.OC_AN_Current_Status__c = EXTERNALLY_PUBLISHED_STATUS;
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
      insert bulletinAccountProductList;    }
  }

  /**
   * @Description : Method to test if a Revision record is created with details from Main Bulletin record
   * along with related Bulletin_Account_products.
   **/
  @isTest
  static void createNewRevisionRecordFromMainBulletin() {
    Id revisionRecord;
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(BULLETIN_NAME);
    Test.startTest();
    revisionRecord = OC_AN_BulletinRevisionController.processRecords(bulletinRecord.Id);
    Test.stopTest();
    System.assertEquals(true, (revisionRecord != null),
      'Revision Bulletin not created from Main Bulletin');
    System.assertEquals(2, getCountOfBapRecordsByBulletinId(revisionRecord),
      'Bulletin_Account_Products records not created for Revision record');
  }

  /**
   * @Description : Method to test if a Revision record is created with details from existing Revision
   * Bulletin record along with related Bulletin_Account_products.
   **/
  @isTest
  static void createNewRevisionRecordFromExistingRevisionBulletin() {
    Id revisionRecord, secondRevisionRecord;
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(BULLETIN_NAME);
    Test.startTest();
    revisionRecord = OC_AN_BulletinRevisionController.processRecords(bulletinRecord.Id);
    secondRevisionRecord = OC_AN_BulletinRevisionController.processRecords(revisionRecord);
    Test.stopTest();
    System.assertEquals(true, (secondRevisionRecord != null),
      'Revision Record not created from existing Revision Bulletin');
    System.assertEquals(2, getCountOfBapRecordsByBulletinId(revisionRecord),
      'Bulletin_Account_Products records not created for Revision record');
  }

  /**
   * @Description : Method to get Bulletin Record by Bulletin Name.
   * @Param       : bulletinName - Name of Bulletin.
   * @Return      : Bulletin Record.
   **/
  private static OC_AN_Bulletin__c getBulletinRecord(String bulletinName) {
    return [SELECT Id FROM OC_AN_Bulletin__c WHERE Name = :bulletinName];
  }

  /**
   * @Description : Method to get count of Bulletin_Account_Products records by Bulletin Id.
   * @Param       : bulletinId - Bulletin id.
   * @Return      : Count of Bulletin_Account_Products records related to Bulletin.
   **/
  private static Integer getCountOfBapRecordsByBulletinId(Id bulletinId) {
    return [
      SELECT COUNT()
      FROM OC_AN_Bulletin_Account_Product__c
      WHERE OC_AN_Bulletin__c = :bulletinId];
  }
}