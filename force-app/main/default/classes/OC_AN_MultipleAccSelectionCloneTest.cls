/**
 * @File Name          : OC_AN_MultipleAccSelHandlerTest
 * @Description        : Test Class for OC_AN_MultipleAccountSelectionHandler.
 *
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Created Date       : 10th April 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-04-10              	IBM               Initial Version
 * 2.0        2021-07-26               IBM               Updated as part of U-2867
 **/
@isTest
public class OC_AN_MultipleAccSelectionCloneTest {
  private static final String BULLETIN_NAME = 'Test External Distribution Bulletin';
  private static final String LOCAL_BULLETIN_NAME = 'Test External Distribution Local Bulletin';

  /**
   * @Description : Data setup for test class.
   **/
  @testsetup
  static void setup() {
    Id migrationProfileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Migration User Profile'
    ].Id;

    User testuser = (User) OC_TestDataGenerator.createSObject(new User());
    testuser.UserName = 'ericssonExtDistribution@test.com';
    testuser.ProfileId = migrationProfileId;
    testuser.IsActive = true;
    insert testuser;

    System.runAs(testUser) {
      List<Account> serviceAccList = new List<Account>();
      Account accSales = (Account) OC_TestDataGenerator.createSObject(
        new Account()
      );
      accSales.Account_Type__c = OC_AN_Constants.sales;
      accSales.RecordTypeId = OC_AN_Constants.recTypeId_forSalesAccount;
      insert accSales;

      Account accService = (Account) OC_TestDataGenerator.createSObject(new Account());
      accService.Account_Type__c = OC_AN_Constants.service;
      accService.ParentId = accSales.Id;
      accService.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
      serviceAccList.add(accService);

      CustomerUnit__c custUnitIndia = (CustomerUnit__c) OC_TestDataGenerator.createSObject(
        new CustomerUnit__c());
      custUnitIndia.Name = 'Ext Distribution CU India';
      custUnitIndia.Type__c = 'CU';
      insert custUnitIndia;

      CustomerUnit__c custUnitBrazil = (CustomerUnit__c) OC_TestDataGenerator.createSObject(
        new CustomerUnit__c());
      custUnitBrazil.Name = 'Ext Distribution CU Brazil';
      custUnitBrazil.Type__c = 'CU';
      insert custUnitBrazil;

      CustomerReportingGroup__c custReportingGrpIndia = (CustomerReportingGroup__c) OC_TestDataGenerator.createSObject(
        new CustomerReportingGroup__c());
      custReportingGrpIndia.Name = 'Ext Distribution CRG India';
      custReportingGrpIndia.CustomerUnit__c = custUnitIndia.Id;
      custReportingGrpIndia.MarketArea__c = 'MELA';
      insert custReportingGrpIndia;

      CustomerReportingGroup__c custReportingGrpBrazil = (CustomerReportingGroup__c) OC_TestDataGenerator.createSObject(
        new CustomerReportingGroup__c());
      custReportingGrpBrazil.Name = 'Ext Distribution CRG Brazil';
      custReportingGrpBrazil.CustomerUnit__c = custUnitBrazil.Id;
      insert custReportingGrpBrazil;

      CustomerReportingGroup__c custReportingGrpMarketArea = (CustomerReportingGroup__c) OC_TestDataGenerator.createSObject(
        new CustomerReportingGroup__c());
      custReportingGrpMarketArea.Name = 'Ext Distribution CRG MA';
      custReportingGrpMarketArea.MarketArea__c = 'MANA';
      insert custReportingGrpMarketArea;
      system.debug(
        'custReportingGrpMarketArea--> ' + custReportingGrpMarketArea
      );

      Account accServiceWithCRG = (Account) OC_TestDataGenerator.createSObject(new Account());
      accServiceWithCRG.Account_Type__c = OC_AN_Constants.service;
      accServiceWithCRG.Name = 'Test Account With CRG';
      accServiceWithCRG.ParentId = accSales.Id;
      accServiceWithCRG.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
      accServiceWithCRG.CustomerReportingGroup__c = custReportingGrpIndia.Id;
      serviceAccList.add(accServiceWithCRG);

      Account accServiceWithCustUnit = (Account) OC_TestDataGenerator.createSObject(new Account());
      accServiceWithCustUnit.Account_Type__c = OC_AN_Constants.service;
      accServiceWithCustUnit.Name = 'Test Account With Customer Unit';
      accServiceWithCustUnit.ParentId = accSales.Id;
      accServiceWithCustUnit.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
      accServiceWithCustUnit.CustomerReportingGroup__c = custReportingGrpBrazil.Id;
      serviceAccList.add(accServiceWithCustUnit);

      Account accServiceWithMarketArea = (Account) OC_TestDataGenerator.createSObject(new Account());
      accServiceWithMarketArea.Account_Type__c = OC_AN_Constants.service;
      accServiceWithMarketArea.Name = 'Test Account With Market Area';
      accServiceWithMarketArea.ParentId = accSales.Id;
      accServiceWithMarketArea.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
      accServiceWithMarketArea.CustomerReportingGroup__c = custReportingGrpMarketArea.Id;
      serviceAccList.add(accServiceWithMarketArea);
      insert serviceAccList;

      OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin_Template__c());
      insert bulletinTemplateToInsert;

      OC_AN_Bulletin__c bulletinRecord = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin__c());
      bulletinRecord.OC_AN_Bulletin_Template__c = bulletinTemplateToInsert.Id;
      bulletinRecord.Name = BULLETIN_NAME;
      insert bulletinRecord;

      OC_AN_Bulletin_Account_Product__c bapRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin_Account_Product__c());
      bapRecord.OC_AN_Bulletin__c = bulletinRecord.Id;
      bapRecord.OC_AN_Account__c = accServiceWithCRG.Id;
      insert bapRecord;

      OC_AN_Group_Member__c localPublisherForAccount = new OC_AN_Group_Member__c();
      localPublisherForAccount.RecordTypeId = OC_AN_Constants.recordTypeId_LocalPublisher;
      localPublisherForAccount.OC_AN_Account__c = accServiceWithCRG.Id;
      localPublisherForAccount.OC_AN_User__c = testUser.Id;
      localPublisherForAccount.OC_AN_Local_Publisher__c = true;
      insert localPublisherForAccount;

      OC_AN_Bulletin__c localBulletinRecord = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(
        new OC_AN_Bulletin__c());
      localBulletinRecord.OC_AN_Parent_Bulletin__c = bulletinRecord.Id;
      localBulletinRecord.Name = LOCAL_BULLETIN_NAME;
      localBulletinRecord.OC_AN_Bulletin_Template__c = bulletinTemplateToInsert.Id;
      insert localBulletinRecord;
    }
  }

  /**
   * @Description : Method to alidate the total count of Accounts to be displayed for Bulletin.
   **/
  @isTest
  static void getCountOfAccountsforBulletin() {
    Integer bulletinAccCount;
    Test.startTest();
    bulletinAccCount = OC_AN_MultipleAccSelectionHandlerClone.getCountOfAccounts();
    Test.stopTest();
    System.assertEquals(4, bulletinAccCount, 'Method did not return the count of all accounts');
  }

  /**
   * @Description : Method to validate the List of existing Accounts related to the Bulletin.
   **/
  @isTest
  static void getExistingBulletinAccountRecords() {
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(BULLETIN_NAME);
    List<Id> bulletinAccIdList;
    Test.startTest();
    bulletinAccIdList = OC_AN_MultipleAccSelectionHandlerClone.getExistingBulletinAccountRecords(
      bulletinRecord.Id);
    Test.stopTest();
    System.assertEquals(1, bulletinAccIdList.size(), 'Bulletin Account records not returned');
  }

  /**
   * @Description : Method to validate the total count of Accounts to be displayed for Local Bulletin.
   **/
  @isTest
  static void getCountOfAccountsforLocalBulletin() {
    User migrationUser = getUserRecord('ericssonExtDistribution@test.com');
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(LOCAL_BULLETIN_NAME);
    Integer bulletinAccCount;
    System.runAs(migrationUser) {
      Test.startTest();
      bulletinAccCount = OC_AN_MultipleAccSelectionHandlerClone.getCountOfAccountsLocalBulletin(
        bulletinRecord.OC_AN_Parent_Bulletin__c, bulletinRecord.Id);
      Test.stopTest();
    }
    System.assertEquals(1, bulletinAccCount,
      'Method did not return the count of accounts related to Parent Bulletin');
  }

  /**
   * @Description : Method to validate the List of Accounts to be displayed for the Bulletin.
   **/
  @isTest
  static void getAccountsForBulletin() {
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(BULLETIN_NAME);
    OC_AN_MultipleAccSelectionHandlerClone.AccGridDataListWrapper accDataList;
    Test.startTest();
    accDataList = OC_AN_MultipleAccSelectionHandlerClone.getAccountsToDisplay(0, 1, 1);
    Test.stopTest();
    System.assertNotEquals(null, accDataList, 'Method did not return accounts to be displayed fro Bulletin');
  }

  /**
   * @Description : Method to validate the List of Accounts to be displayed for Local Bulletin.
   **/
  @isTest
  static void getAccountsForLocalBulletin() {
    User migrationUser = getUserRecord('ericssonExtDistribution@test.com');
    OC_AN_Bulletin__c localBulletinRecord = getBulletinRecord(LOCAL_BULLETIN_NAME);
    OC_AN_MultipleAccSelectionHandlerClone.AccGridDataListWrapper accDataList;
    System.runAs(migrationUser) {
      Test.startTest();
      localBulletinRecord = OC_AN_MultipleAccSelectionHandlerClone.getBulletin(localBulletinRecord.Id);
      accDataList = OC_AN_MultipleAccSelectionHandlerClone.getAccountsForLocalBuletin(0, 1, 1,
        localBulletinRecord.OC_AN_Parent_Bulletin__c,
        localBulletinRecord.Id);
      Test.stopTest();
    }
    System.assertNotEquals(null, accDataList,
      'Method did not return accounts to be displayed for Local Bulletin');
  }

  /**
   * @Description : Method to validate if new Bulletin_Account_Products records are created for Selected Accounts.
   **/
  @isTest
  static void createBapRecordForSelectedAccount() {
    User migrationUser = getUserRecord('ericssonExtDistribution@test.com');
    Account accountRecord = getAccountDetails('Test Account With Market Area');
    OC_AN_Bulletin__c localBulletinRecord = getBulletinRecord(LOCAL_BULLETIN_NAME);
    String selectedAccJson = getJsonForBapCreationOrDeletion(accountRecord, false);
    System.runAs(migrationUser) {
      Test.startTest();
      OC_AN_MultipleAccSelectionHandlerClone.upsertAccountToBulletin(selectedAccJson, localBulletinRecord.Id,
        localBulletinRecord.OC_AN_Parent_Bulletin__c, false);
      Test.stopTest();
    }
    List<Id> bulletinAccIdList = OC_AN_MultipleAccSelectionHandlerClone.getExistingBulletinAccountRecords(
      localBulletinRecord.Id);
    System.assertEquals(1, bulletinAccIdList.size(),
      'Bulletin Account Products record not created for selected Account');
  }

  /**
   * @Description : Method to validate if Bulletin_Account_Products records are deleted for De-selected Accounts.
   **/
  @isTest
  static void deleteExistingBapRecordForDeselectedAccount() {
    Account accountRecord = getAccountDetails('Test Account With CRG');
    OC_AN_Bulletin__c bulletinRecord = getBulletinRecord(BULLETIN_NAME);
    String deselectedAccJson = getJsonForBapCreationOrDeletion(accountRecord, true);
    Test.startTest();
    OC_AN_MultipleAccSelectionHandlerClone.upsertAccountToBulletin(deselectedAccJson, bulletinRecord.Id,
      bulletinRecord.OC_AN_Parent_Bulletin__c, false);
    Test.stopTest();
    List<Id> bulletinAccIdList = OC_AN_MultipleAccSelectionHandlerClone.getExistingBulletinAccountRecords(
      bulletinRecord.Id);
    System.assertEquals(0, bulletinAccIdList.size(),
      'Bulletin Account Products record not deleted for deselected Account');
  }

  /**
   * @Description : Method to validate if Local Bulletin is deleted after confirmation upon deleting all
   * Accounts present in External Distribution List.
   **/
  @isTest
  static void deleteLocalBulltinIfNoExternalDistributionListIsPresent() {
    User migrationUser = getUserRecord('ericssonExtDistribution@test.com');
    Account accountRecord = getAccountDetails('Test Account With CRG');
    OC_AN_Bulletin__c localBulletinRecord = getBulletinRecord(LOCAL_BULLETIN_NAME);
    String selectedAccJson = getJsonForBapCreationOrDeletion(accountRecord, false);
    OC_AN_MultipleAccSelectionHandlerClone.upsertAccountToBulletin(selectedAccJson, localBulletinRecord.Id,
      localBulletinRecord.OC_AN_Parent_Bulletin__c, false);
    String deselectedAccJson = getJsonForBapCreationOrDeletion(accountRecord, true);
    System.runAs(migrationUser) {
      Test.startTest();
      OC_AN_MultipleAccSelectionHandlerClone.upsertAccountToBulletin(deselectedAccJson, localBulletinRecord.Id,
        localBulletinRecord.OC_AN_Parent_Bulletin__c,
        OC_AN_MultipleAccSelectionHandlerClone.showDeleteConfirmation(deselectedAccJson, true));
      Test.stopTest();
    }
    OC_AN_Bulletin__c localBulletinUpdatedRecord = getBulletinRecord(LOCAL_BULLETIN_NAME);
    System.assertEquals(true, localBulletinUpdatedRecord.IsDeleted, 'Local Bulletin not deleted');
  }

  /**
   * @Description : Method to get Account details by Account Name.
   * @Param       : accName - Name of the Account.
   * @Return      : Account record.
   **/
  private static Account getAccountDetails(String accName) {
    return [
      SELECT Id, Name, CustomerUnit__c, MarketArea__c
      FROM Account
      WHERE Name = :accName
    ];
  }

  /**
   * @Description : Method to get User details by username.
   * @Param       : userName - username of the User.
   * @Return      : User record.
   **/
  private static User getUserRecord(String userName) {
    return [SELECT Id FROM User WHERE UserName = :userName];
  }

  /**
   * @Description : Method to get Bulletin details by bulletin Name.
   * @Param       : bulletinName - Name of the Bulletin.
   * @Return      : Bulletin record.
   **/
  private static OC_AN_Bulletin__c getBulletinRecord(String bulletinName) {
    return [
      SELECT Id, OC_AN_Parent_Bulletin__c, IsDeleted
      FROM OC_AN_Bulletin__c
      WHERE Name = :bulletinName
      ALL ROWS
    ];
  }

  /**
   * @Description : Method to form the Account selection/de-selection JSON.
   * @Param       : accRecord - Account record.
   * @Param       : isDeselect - Boolean value to check if record is deselected.
   * @Return      : Account selection/de-selection JSON.
   **/
  private static String getJsonForBapCreationOrDeletion(
    Account accRecord,
    Boolean isDeselect
  ) {
    String inputJson;
    if (isDeselect) {
      inputJson =
        '{"selected":{},"deselected":{"' +
        accRecord.Id +
        '":{"Id":"' +
        accRecord.Id +
        '","Name":"' +
        accRecord.Name +
        '","selectedState":"unchecked"}}}';
    } else {
      inputJson =
        '{"selected":{"' +
        accRecord.Id +
        '":{"Id":"' +
        accRecord.Id +
        '","CustomerUnit__c":"' +
        accRecord.CustomerUnit__c.stripHtmlTags() +
        '","MarketArea__c":"' +
        accRecord.Id +
        '","Name":"' +
        accRecord.Name +
        '","selectedState":"checked"}},"deselected":{}}';
    }
    return inputJson;
  }
}