/**
* @File Name          : OC_TH_CaseSharingRuletest
* @Description        : Test class for OC_TH_CaseSharingRule class
* @Author             : IBM
* @Modification Log   : 
**/
@isTest
public class OC_TH_CaseSharingRuleTest {
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
        accountToInsert.BillingCountry = 'Brazil';
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
        caseToInsert.OC_TH_LI_CSR__c = true;
        caseList.add(caseToInsert);
        insert caseList;
        
        system.assertEquals(accList.size(),1);
        system.assertEquals(conList.size(),1);
        system.assertEquals(caseList.size(),1);
    }
    
    @isTest
    Static Void caseAssignmentHanlderTest(){
        List<case> cs = [SELECT id,OC_TH_LI_CSR__c FROM case];
        set<id> setCaseId = new set<id>();
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                 WHERE OC_TH_Accout_Billing_Country__c = 'Brazil'
                                                 AND OC_TH_Public_Group_Country__c = 'Brazil'];
        test.startTest();
        if(!cs.isEmpty()){
            setCaseId.add(cs[0].id);
            OC_TH_CaseSharingRule.shareCaseWithPublicGroup(setCaseId);
        }
        test.stopTest();
    }
    
}