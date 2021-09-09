/**
* @File Name          : OC_TH_CaseUpdateOnTaskChangeTest
* @Description        : Test class for OC_TH_CaseUpdateOnTaskChange class
* @Author             : IBM
* @Created Date       : 16/08/2021
**/
@isTest
public class OC_TH_CaseUpdateOnTaskChangeTest {
    
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    Public Static List<Task> taskList = new List<Task>();
    Public Static Id standardRecordType = OC_TH_Constants.recordType_StandardCSR;
    Public Static Id getRemedyRecordType = OC_TH_Constants.getTaskRemedyRecordType;
    Public Static Id getAnswerRecordType = OC_TH_Constants.getTaskAnswerRecordType;
    Public Static Id getRequestForInfoRecordType = OC_TH_Constants.getTaskRequestForInfoRecordType;
    
    
    @testsetup 
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuserteamMem@test.com';
        insert testuser;
        
        System.runAs(testuser){
            accountList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accountList[0].Account_Type__c = 'Service';
            accountList[0].Name = 'TestAccount001';
            insert accountList;
            system.assertEquals(accountList.size(), 1);
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            if(!accountList.isEmpty()){
                contactList[0].FirstName = '001testing';
                contactList[0].LastName = 'TestCon0011';
                contactList[0].phone='4352787188';
                contactList[0].AccountId = accountList[0].id;
                contactList[0].Email = 'xyz@ibm.com';
                contactList[0].MailingCountry = 'India';     
                insert contactList;
                system.assertEquals(contactList.size(),1);
                
            }  
            assetList = OC_TestDataGenerator.createSObjectList(new Asset(),1);
            if(!accountList.isEmpty()){
                assetList[0].name = 'afg001';
                assetList[0].AccountId = accountList[0].id;
                assetList[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Node Type').getRecordTypeId();
                insert assetList;
                system.assertEquals(assetList.size(),1);
            }
            
            List<CaseTeamRole> csteam = [select id,name from CaseTeamRole];
         
            if(!accountList.isEmpty() && !contactList.isEmpty() && !assetList.isEmpty()){
                caseList = OC_TestDataGenerator.createSObjectList(new Case(),9);
                
                caseList[0].AccountId = accountList[0].id;
                caseList[0].ContactId = contactList[0].id;
                caseList[0].AssetId = assetList[0].id;
                caseList[0].ownerId =testuser.id;
                caseList[0].RecordTypeId = standardRecordType;
                
                caseList[1].AccountId = accountList[0].id;
                caseList[1].ContactId = contactList[0].id;
                caseList[1].AssetId = assetList[0].id;
                caseList[1].ownerId =testuser.id;
                caseList[1].RecordTypeId = standardRecordType;
                
                caseList[2].AccountId = accountList[0].id;
                caseList[2].ContactId = contactList[0].id;
                caseList[2].AssetId = assetList[0].id;
                caseList[2].ownerId =testuser.id;
                caseList[2].RecordTypeId = standardRecordType;
                
                caseList[3].AccountId = accountList[0].id;
                caseList[3].ContactId = contactList[0].id;
                caseList[3].AssetId = assetList[0].id;
                caseList[3].ownerId =testuser.id;
                caseList[3].RecordTypeId = standardRecordType;
                
                caseList[4].AccountId = accountList[0].id;
                caseList[4].ContactId = contactList[0].id;
                caseList[4].AssetId = assetList[0].id;
                caseList[4].ownerId =testuser.id;
                caseList[4].RecordTypeId = standardRecordType;
                
                caseList[5].AccountId = accountList[0].id;
                caseList[5].ContactId = contactList[0].id;
                caseList[5].AssetId = assetList[0].id;
                caseList[5].ownerId =testuser.id;
                caseList[5].RecordTypeId = standardRecordType;
                
                caseList[6].AccountId = accountList[0].id;
                caseList[6].ContactId = contactList[0].id;
                caseList[6].AssetId = assetList[0].id;
                caseList[6].ownerId =testuser.id;
                caseList[6].RecordTypeId = standardRecordType;
                
                caseList[7].AccountId = accountList[0].id;
                caseList[7].ContactId = contactList[0].id;
                caseList[7].AssetId = assetList[0].id;
                caseList[7].ownerId =testuser.id;
                caseList[7].RecordTypeId = standardRecordType;
                
                caseList[8].AccountId = accountList[0].id;
                caseList[8].ContactId = contactList[0].id;
                caseList[8].AssetId = assetList[0].id;
                caseList[8].ownerId =testuser.id;
                caseList[8].RecordTypeId = standardRecordType;
                
                insert caseList;
                system.assertEquals(caseList.size(),9);
            }
            if(!caseList.isEmpty()){
                taskList = OC_TestDataGenerator.createSObjectList(new Task(),9);
                
                taskList[0].RecordTypeId = getRequestForInfoRecordType;
                taskList[0].WhatId = caseList[0].Id;
                taskList[0].Status = 'Requested';
                taskList[0].ownerId =caseList[0].ownerId;
                
                taskList[1].RecordTypeId = getAnswerRecordType;
                taskList[1].WhatId = caseList[1].Id;
                taskList[1].Status = 'Answered';
                taskList[1].ownerId =caseList[1].ownerId;
                
                taskList[2].RecordTypeId = getRemedyRecordType;
                taskList[2].WhatId = caseList[2].Id;
                taskList[2].Status = 'Answered';
                taskList[2].ownerId =caseList[2].ownerId;
                
                taskList[3].RecordTypeId = getAnswerRecordType;
                taskList[3].WhatId = caseList[3].Id;
                taskList[3].Status = 'Accepted';
                taskList[3].ownerId =caseList[3].ownerId;
                
                taskList[4].RecordTypeId = getRequestForInfoRecordType;
                taskList[4].WhatId = caseList[4].Id;
                taskList[4].Status = 'Info provided';
                taskList[4].ownerId =caseList[4].ownerId;
                
                taskList[5].RecordTypeId = getAnswerRecordType;
                taskList[5].WhatId = caseList[5].Id;
                taskList[5].Status = 'Rejected';
                taskList[5].ownerId =caseList[5].ownerId;
                
                taskList[6].RecordTypeId = getRemedyRecordType;
                taskList[6].WhatId = caseList[6].Id;
                taskList[6].Status = 'Accepted';
                taskList[6].ownerId =caseList[6].ownerId;
                
                taskList[7].RecordTypeId = getRemedyRecordType;
                taskList[7].WhatId = caseList[7].Id;
                taskList[7].Status = 'Rejected';
                taskList[7].ownerId =caseList[7].ownerId;
                
                taskList[8].RecordTypeId = getRequestForInfoRecordType;
                taskList[8].WhatId = caseList[8].Id;
                taskList[8].Status = 'Info accepted';
                taskList[8].ownerId =caseList[8].ownerId;
                
                insert taskList;
                system.assertEquals(taskList.size(),9);
            }
        }
    }
    @isTest
    Static Void taskCreationTest(){
        Set<Id> taskId = new Set<Id>();
        Map<Id,Case> oldMap = new  Map<Id,Case>();
        for(task taskRec: [SELECT id FROM task where status != null]){
            taskId.add(taskRec.Id);
        }
        
        test.startTest();
        if(!taskId.isEmpty()){
            system.assertNotEquals(taskId, null);
            OC_TH_CaseUpdateOnTaskChange.CaseUpdateOnTaskChange(taskId);
        }
        test.stopTest();
    }
    
}