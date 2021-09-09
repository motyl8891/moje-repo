/**
* @File Name          : OC_TH_CaseAssignmentRuleHandlerTest
* @Description        : Test class for OC_TH_CaseAssignmentRuleHandler class
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
**/
@isTest
public class OC_TH_CaseAssignmentRuleHandlerTest {
    @testsetup 
    static void setup(){
        List<Case> caseList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.IsActive = true;
        
        insert testuser;
        System.runAs(testUser){
        Account accountToInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
        accountToInsert.CNS_Queue__c = 'Test';
        accountToInsert.Account_Type__c = 'Service';
        
        accList.add(accountToInsert);
        
        insert accList;
        }
        Contact contactToInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
        contactToInsert.AccountId = accList[0].Id;
        conList.add(contactToInsert);
        
        insert conList;
        
        Case caseToInsert = (Case)OC_TestDataGenerator.createSObject(new Case());
        caseToInsert.OC_TH_Customer_Description__c = 'Test Description ' ;
        caseToInsert.ContactId = contactToInsert.Id;
        caseList.add(caseToInsert);
        insert caseList;
        
        system.assertEquals(accList.size(),1);
        system.assertEquals(conList.size(),1);
        system.assertEquals(caseList.size(),1);
    }
    
    @isTest
    Static Void caseAssignmentHanlderTest(){
        List<Id> caseId = new List<Id>();
        for(Case cs: [SELECT id FROM case]){
            caseId.add(cs.Id);
        }
        
        test.startTest();
        if(!caseId.isEmpty()){
            OC_TH_CaseAssignmentRuleHandler.saveCase(caseId);
        }
        test.stopTest();
    }
    
}