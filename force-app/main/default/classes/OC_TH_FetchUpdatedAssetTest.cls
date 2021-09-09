/**
* @File Name          : OC_TH_FetchUpdatedAssetTest
* @Description        : Test class for OC_TH_FetchUpdatedAsset 
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 5th August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-05                 IBM                  Initial Version
**/

@isTest
public class OC_TH_FetchUpdatedAssetTest {
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Contact> contactList = new List<Contact>();
    Public Static Id serviceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getServiceAccountRecordType).getRecordTypeId();
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    Public Static Id standardRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    @testsetup 
    static void setup(){
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.IsActive = true;
        testuser.Email = 'testuser@testingAsset.com';
        insert testuser;
        
        System.runAs(testuser){
        Account accountNewInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
        accountNewInsert.CNS_Queue__c = 'Test';
        accountNewInsert.Account_Type__c = 'Service';
        accountNewInsert.RecordTypeId = serviceRecordType;
        accountList.add(accountNewInsert);
        insert accountList;
            
           assetList = OC_TestDataGenerator.createSObjectList(new Asset(),1);
           assetList[0].name = 'afg001';
           assetList[0].AccountId = accountList[0].id;
           assetList[0].RecordTypeId = assetRecordTypeId;
           insert assetList;
        
        Contact contactNewInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
        contactNewInsert.AccountId = accountList[0].Id;
        contactList.add(contactNewInsert);
        insert contactList;
        
        Case caseNewInsert = (Case)OC_TestDataGenerator.createSObject(new Case());
        caseNewInsert.OC_TH_Customer_Description__c = 'Testing Update' ;
        caseNewInsert.ContactId = contactNewInsert.Id;
        caseNewInsert.AssetId = assetList[0].Id;
        caseNewInsert.RecordTypeId = standardRecordTypeId;
        caseList.add(caseNewInsert);
        insert caseList;
        
        system.assertEquals(accountList.size(),1);
        system.assertEquals(contactList.size(),1);
        system.assertEquals(caseList.size(),1);
        system.assertEquals(assetList.size(),1);
        }
    }
    
    @isTest
    Static Void caseAssetUpdationTest(){
        Case caseNew = [SELECT Id, AssetId, Asset.Product2.Name, Asset.OC_TH_Release__c, Asset.OC_TH_Version__c from Case LIMIT 1];
        List<User> userList = [SELECT id,Name,CreatedDate,IsActive, Email
                                FROM User WHERE Email  = 'testuser@testingAsset.com'
                                ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        System.runAs(userList[0]){
          	  OC_TH_FetchUpdatedAsset.updateRecord(caseNew.Id);
              System.assertEquals(null, caseNew.Asset.Product2.Name);
              System.assertEquals('-', caseNew.Asset.OC_TH_Release__c);
              System.assertEquals('-', caseNew.Asset.OC_TH_Version__c);
            try{
                OC_TH_FetchUpdatedAsset.updateRecord(null);
            }
            catch(Exception e){}
            try{
                OC_TH_FetchUpdatedAsset.updateRecord('');}
            catch(Exception e){}
        Test.stopTest();
            
        }
    }
    
}