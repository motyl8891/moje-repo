/**
* @File Name          : OC_TH_CaseMirroringLICSRTest
* @Description        : Test class for OC_TH_CaseMirroringLICSR class
* @Author             : IBM
* @Created Date       : 28th June 2021
* @Modification Log   : 
**/
@isTest
public class OC_TH_CaseMirroringLICSRTest {
    @testsetup 
    static void setup(){
        List<Case> caseList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Product2> prodList = new List<Product2>();
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuser@test.com';
        insert testuser;
        
        System.runAs(testUser){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();
            Account accountToInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
            accountToInsert.CNS_Queue__c = 'Test';
            accountToInsert.Account_Type__c = 'Service';
            accountToInsert.BillingCountryCode = 'Br';
            accountToInsert.RecordTypeId = recTypeId;
            accList.add(accountToInsert);
            insert accList;
            
        }
        
        Contact contactToInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
        contactToInsert.AccountId = accList[0].Id;
        conList.add(contactToInsert);
        insert conList;
        
        Product2 productRec = (Product2) OC_TestDataGenerator.createSObject(new Product2());
        productRec.OC_MD_Product_type__c = 'Node Type';
        productRec.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Node Type').getRecordTypeId();
        productRec.Product_Code_Number__c = 'Test';
        productRec.Name = 'Test';
        prodList.add(productRec);
        insert prodList;
        
        Asset assetToInsert = (Asset)OC_TestDataGenerator.createSObject(new Asset());
        assetToInsert.OC_MD_Version__c ='1.0';
        assetToInsert.name = 'testAsset';
        assetToInsert.accountId = accList[0].Id;
        assetToInsert.ContactId = contactToInsert.Id;
        assetToInsert.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Node Type').getRecordTypeId();
        assetToInsert.Product2Id = productRec.id;
        insert assetToInsert;
        
        ServiceContract serviceContractToInsert = (ServiceContract)OC_TestDataGenerator.createSObject(new ServiceContract());
        serviceContractToInsert.name = 'testServiceContract';
        serviceContractToInsert.AccountId = accList[0].Id;
        insert serviceContractToInsert;
        
        OC_MD_Installed_Base_Item__c contractToInsert = (OC_MD_Installed_Base_Item__c)OC_TestDataGenerator.createSObject(new OC_MD_Installed_Base_Item__c());
        contractToInsert.name = 'testContract';
        contractToInsert.OC_MD_Asset__c = assetToInsert.id;
        contractToInsert.OC_MD_Service_Contract__c = serviceContractToInsert.id;
        insert contractToInsert;
        
        Case caseToInsert = (Case)OC_TestDataGenerator.createSObject(new Case());
        caseToInsert.OC_TH_Customer_Description__c = 'Test Description ' ;
        casetoInsert.OC_TH_Case_Number__c = 'STA-002';
        caseToInsert.ContactId = contactToInsert.Id;
        caseToInsert.OC_TH_LI_CSR__c = true;
        caseList.add(caseToInsert);
        
        Case caseToInsert1 = (Case)OC_TestDataGenerator.createSObject(new Case());
        caseToInsert1.OC_TH_Customer_Description__c = 'Test Description 1' ;
        casetoInsert1.OC_TH_Case_Number__c = 'STA-001';
        caseToInsert1.ContactId = contactToInsert.Id;
        caseToInsert1.OC_TH_LI_CSR__c = true;
        caseList.add(caseToInsert1);
        insert caseList;
        
        caseToInsert.AssetId = assetToInsert.Id;
        caseToInsert.OC_TH_Installed_Base_Item__c = contractToInsert.Id;
        caseToInsert.Priority = 'Low';
        update caseToInsert;
        
        system.assertEquals(accList.size(),1);
        system.assertEquals(conList.size(),1);
        system.assertEquals(caseList.size(),2);
    }
    @isTest
    Static Void caseCreationTest(){
        Set<Id> caseId = new Set<Id>();
        Set<Id> OwnerId = new Set<Id>();
        Map<Id,Case> newMap = new  Map<Id,Case>();
        Map<Id,Case> oldMap = new  Map<Id,Case>();
        Group GroupRec = (Group)OC_TestDataGenerator.createSObject(new Group());
        GroupRec.type = 'Queue';
        GroupRec.Name = 'TestUserGroup';
        insert GroupRec;
        OwnerId.add(GroupRec.Id);
        
        for(Case cs: [SELECT id,OC_TH_Case_Number__c,OwnerId,AssetId,OC_TH_Installed_Base_Item__c,ParentId,OC_TH_LI_CSR__c FROM case]){
            oldMap.put(cs.Id, cs);
            cs.AssetId = null;
            cs.OwnerId = GroupRec.Id;
            newMap.put(cs.Id, cs);
            caseId.add(cs.Id);
        }
        
        test.startTest();
        if(!caseId.isEmpty()){
            OC_TH_CaseMirroringLICSR.partialCaseClone(caseId);
            OC_TH_CaseMirroringLICSR.caseMirroringOnUpdate(caseId,oldMap);
            OC_TH_CaseMirroringLICSR.ownerQueueChangeLICSR(caseId,OwnerId);
            OC_TH_CaseMirroringLICSR.ownerContactChangeValidation(newMap,oldMap,caseId);
        }
        test.stopTest();
    }
    
}