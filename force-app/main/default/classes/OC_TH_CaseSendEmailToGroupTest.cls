/**
* @File Name          : OC_TH_CaseSendEmailToGroupTest
* @Description        : Test class for OC_TH_CaseSendEmailToGroup class
* @Author             : IBM
* @Modification Log   : 
**/
@isTest
public class OC_TH_CaseSendEmailToGroupTest {
    @testsetup 
    static void setup(){
        List<Case> caseList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.Email = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.IsActive = true;
        insert testuser;
        
        System.runAs(testUser){
       // Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAccountServiceRecordType).getRecordTypeId();
        Account accountToInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
        accountToInsert.CNS_Queue__c = 'Test';
        accountToInsert.Account_Type__c = 'Service';
        //accountToInsert.recordtypeid = accountServiceRecordType;
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
        caseToInsert.OC_TH_Latest_Queue_Name__c = 'NOCE/RAN';
        caseList.add(caseToInsert);
        insert caseList;
        
        system.assertEquals(accList.size(),1);
        system.assertEquals(conList.size(),1);
        system.assertEquals(caseList.size(),1);
    }
    
    @isTest
    Static Void caseAssignmentHanlderTest(){
        Map<Id,Case> mapIdToNewCase = new Map<Id,Case>();
        map<String,id> mailToAddresses = new map<String,id>();
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                 WHERE OC_TH_Accout_Billing_Country__c = 'Brazil'
                                                 AND OC_TH_Public_Group_Country__c = 'Brazil'];
        List<case> cs = [SELECT id FROM case where OC_TH_LI_CSR__c = true];
        List<user> testUser = [SELECT id,email FROM user where Email != null]; 
        
        test.startTest();
        if(!cs.isEmpty()){
            mapIdToNewCase.put(cs[0].id,cs[0]);
            OC_TH_CaseSendEmailToGroup.sendEmailtoPublicGroup(mapIdToNewCase);
        }
        if(!testUser.isEmpty()){
            mailToAddresses.put(testUser[0].email,testUser[0].id);
            OC_TH_CaseSendEmailToGroup.sendMail(mailToAddresses);
        }
        test.stopTest();
    }
    
}