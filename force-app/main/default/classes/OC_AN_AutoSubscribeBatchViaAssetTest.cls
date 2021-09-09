/**
* @File Name          : OC_AN_AutoSubscribeBatchViaAssetTest
* @Description        : Test Class for OC_AN_AutoSubscribeBatchViaAsset
*                       
* @Author             : IBM
* @Group              : 
* @Created Date       : 8th August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-04             	IBM               Initial Version
*/
@isTest
public class OC_AN_AutoSubscribeBatchViaAssetTest {
@testsetup 
    static void setup(){
        
        List<Account> accList       = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList       = new List<Contact> ();
        Account accSales=new Account();
         Product2 productRec=new  Product2();
        OC_MD_ProductAttributes__c release1 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c release2 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c version1 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c version2 = new OC_MD_ProductAttributes__c ();
        
        
        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericssontestuserpreferences@test.com';
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;
        insert testuser;
        
        Id integrationProfileUsr = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser1 = (User)OC_TestDataGenerator.createSObject(new User());
        testuser1.UserName = 'integrationProfileUsr@test.com';
        testuser1.ProfileId = integrationProfileUsr;
        testuser1.IsActive = true;
        insert testuser1;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Ericsson_Service_Integration'];
        insert new PermissionSetAssignment(AssigneeId = testuser1.id, PermissionSetId = ps.Id);
        
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
         Id assetNodeRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
        
        System.runAs(testuser){
            productRec = (Product2) OC_TestDataGenerator.createSObject(
                new Product2(IsActive = true,Name = 'Test Product 00001',RecordTypeId = productNodeRTId));  
            insert productRec;
            release1 = new OC_MD_ProductAttributes__c(OC_MD_Product__c = productRec.Id,Name = 'Release 1', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release);
            insert release1;
            
            version1 = new OC_MD_ProductAttributes__c(OC_MD_Parent__c = release1.Id,Name = 'Version 1', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release);  
            insert version1;
            
            accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.Account_Type__c = OC_AN_Constants.sales;
            accSales.RecordTypeId = OC_AN_Constants.recTypeId_forSalesAccount;
            insert accSales;
            
            Account acc = (Account)OC_TestDataGenerator.createSObject(new Account());
            acc.Account_Type__c = OC_AN_Constants.service;
            acc.ParentId = accSales.Id;
            acc.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
            insert acc;
            
            accList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accList[0].Account_Type__c = OC_AN_Constants.subDivision;
            accList[0].RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
            accList[0].ParentID = acc.Id;
            insert accList;
            
            conList = OC_TestDataGenerator.createSObjectList(new Contact(),2);
            
            if(accList!=null && !accList.isEmpty() && conList!=null && !accList.isEmpty() ){
                conList[0].AccountId = accList[0].Id;
                conList[1].AccountId = acc.Id;
                updateaccList.add(accList[0]);
                insert conList;
                update updateaccList; 
                
            }
        }
        System.runAs(testuser1){
            Asset asstRec = (Asset) OC_TestDataGenerator.createSObject(
                new Asset(Name = 'Test Asset',AccountId=accSales.Id,RecordTypeId = assetNodeRTId,product2Id=productRec.Id,OC_MD_Release__c=release1.Id,OC_MD_Version__c=version1.Name));  
            insert asstRec;    
        }
    }
     @isTest()
    static void autoSubscribeAssetTest(){
        Test.startTest();
        OC_AN_AutoSubscribeBatchViaAsset btch = new OC_AN_AutoSubscribeBatchViaAsset();
        database.executeBatch(btch);
        Test.stopTest();
    }
}