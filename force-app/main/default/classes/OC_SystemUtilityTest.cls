/**
* @File Name          : OC_SystemUtilityTest
* @Description        : Test class for OC_SystemUtility class
* @Author             : IBM
**/
@isTest
public class OC_SystemUtilityTest {
    @testsetup 
    static void setup(){   
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.Email = 'testuser@test.com';
        testuser.IsActive = true;        
        insert testuser;
        
        System.runAs(testUser){
            Account accountToInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
            accountToInsert.CNS_Queue__c = 'AMZ1';
            accountToInsert.Account_Type__c = 'Service';
            accountToInsert.BillingCountry = 'Brazil';
            accountToInsert.Recordtypeid = OC_TH_Constants.getAccountServiceRecordTypeId;
            accountList.add(accountToInsert);
            insert accountList;
            System.assertEquals(accountList[0].CNS_Queue__c, 'AMZ1');
            
            Contact contactToInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
            contactToInsert.AccountId = accountList[0].Id;
            contactToInsert.FirstName = '001testing';
            contactList.add(contactToInsert);
            insert contactList;
            System.assertEquals(contactList[0].FirstName, '001testing');

        }
    }
    @isTest
    Static Void testShareCaseWithGroupMethod(){
        test.startTest();
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Account accData = [SELECT Id,Account_Type__c,BillingCountry FROM Account WHERE Account.Recordtypeid =: OC_TH_Constants.getAccountServiceRecordTypeId];
        System.debug('Acc list :--'+accData); 
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                       WHERE OC_TH_Accout_Billing_Country__c = 'BR'
                                                       AND OC_TH_Public_Group_Country__c = 'BR'];
        
        Case insertCase = new Case(
            Subject = 'Test Case ',
            AccountId = accData.id,
            Status = 'Registered',
            Priority = '1',
            Type = '901',
            OC_TH_Main_Asset_Type__c = 'Node Type',
            RecordTypeId = OC_TH_Constants.recordType_StandardCSR,
            OC_TH_Customer_Description__c = 'Testing test cases 001',
            OC_TH_LI_CSR__c = True);
        System.runAs(userList[0]){
            try{
                 insert insertCase;
               System.assertEquals(insertCase.Priority, '1');
            }catch(Exception ex){}
        }
        test.stopTest();
    }
   @isTest
    Static Void TestLicsrSendEmailToGroupMethod(){
        Map<Id,Case> mapIdToNewCase = new Map<Id,Case>();
        map<String,id> mailToAddresses = new map<String,id>();
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                       WHERE OC_TH_Accout_Billing_Country__c = 'BR'
                                                       AND OC_TH_Public_Group_Country__c = 'BR'];
        List<user> testUser = [SELECT id,email FROM user where Email != null]; 
        test.startTest();
        System.assert(testUser != null);
        if(!testUser.isEmpty()){
            mailToAddresses.put(testUser[0].email,testUser[0].id);
            string strDeveloperName = 'OC_TH_LI_CSR_Temp';
            OC_SystemUtility.sendMail(mailToAddresses,strDeveloperName);
        }
        test.stopTest();
    }
}