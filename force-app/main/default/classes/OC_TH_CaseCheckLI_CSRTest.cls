/**
* @File Name          : OC_TH_CaseCheckLI_CSRTest
* @Description        : Test class for OC_TH_CaseCheckLI_CSR class
* @Author             : IBM
* @Modification Log   : 
**/
@isTest
public class OC_TH_CaseCheckLI_CSRTest {
        public static Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
    public static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();

    @testsetup 
    static void setup(){
        List<Case> caseList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Id nodeAssetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
        
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
            accountToInsert.Recordtypeid = accountServiceRecordType;
            accList.add(accountToInsert);
            insert accList;
            System.assert(!accList.isEmpty());
            
            Contact contactToInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
            contactToInsert.AccountId = accountToInsert.Id;
            conList.add(contactToInsert);
            insert conList;
            System.assert(!conList.isEmpty());
        }
    }
    @isTest
    Static Void caseAssignmentHanlderTest(){
        
        test.startTest();
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Account accData = [SELECT Id,Account_Type__c,BillingCountry FROM Account WHERE Account.Recordtypeid =: accountServiceRecordType];
        Contact contactData = [SELECT Id,AccountId FROM Contact WHERE AccountId != null];
        List<Case> caseList = new List<case>();
        Case insertCase = new Case(
            Subject = 'Test Case ',
            AccountId = accData.id,
            ContactId = contactData.id,
            Status = 'Registered',
            Priority = '1',
            Type = '901',
            OC_TH_Main_Asset_Type__c = 'Node Type',
            OC_TH_Latest_Queue_Name__c = 'test',
            RecordTypeId = standardRecordType,
            OC_TH_Customer_Description__c = 'Testing test cases 001',
            OC_TH_LI_CSR__c = False);
            
        caseList.add(insertCase);
        System.runAs(userList[0]){
            try{
                 insert caseList;
                 System.assert(!caseList.isEmpty());
                Case updateCase = new case();
                updateCase.OC_TH_LI_CSR__c = True;
                caseList.add(updateCase);
                 OC_TH_CaseCheckLI_CSR.CaseCheckLI_CSR(caseList);
            }catch(Exception ex){}
        } 
        test.stopTest();
    }
    @isTest
    Static Void caseAssignmentHanlderTest1(){
        Map<Id,Case> mapIdToNewCase = new Map<Id,Case>();
        map<String,id> mailToAddresses = new map<String,id>();
         test.startTest();
         List<User> userList = [SELECT id,Name,createddate,isActive, Email
                                 FROM User WHERE Email  = 'testuser@test.com'
                                 ORDER BY createddate LIMIT 1 ];
        Account accData = [SELECT Id,Account_Type__c,BillingCountry FROM Account WHERE Account.Recordtypeid =: accountServiceRecordType];
        Contact contactData = [SELECT Id,AccountId FROM Contact WHERE AccountId != null];
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                       WHERE OC_TH_Accout_Billing_Country__c = 'BR'
                                                       AND OC_TH_Public_Group_Country__c = 'BR'];
            
        Group testGroup = new Group(Name='test', Type='Queue');
        insert testGroup;
        Group testGroup1 = new Group(Name='test1');
        insert testGroup1;
        GroupMember testQueue = new GroupMember(UserOrGroupId = testGroup1.id, GroupId = testGroup.id);
        insert testQueue; 
               
         Case insertCase = new Case(
            Subject = 'Test Case ',
            AccountId = accData.id,
            ContactId = contactData.id,
            Status = 'Registered',
            Priority = '1',
            Type = '901',
            OC_TH_Main_Asset_Type__c = 'Node Type',
            RecordTypeId = standardRecordType,
            OC_TH_Latest_Queue_Name__c = 'test',
            OC_TH_Customer_Description__c = 'Testing test cases 001',
            OC_TH_LI_CSR__c = True);
        System.runAs(userList[0]){
            try{
                 insert insertCase; 
                 System.assert(insertCase != null);
        mapIdToNewCase.put(insertCase.id,insertCase);
            OC_TH_CaseCheckLI_CSR.sendEmailtoPublicGroup(mapIdToNewCase);
                
            }catch(Exception ex){}
        }
      
        test.stopTest();
    }
     @isTest
    Static Void caseAssignmentHanlderTest2(){
        Map<Id,Case> mapIdToNewCase = new Map<Id,Case>();
        map<String,id> mailToAddresses = new map<String,id>();
         test.startTest();
         List<User> userList = [SELECT id,Name,createddate,isActive, Email
                                 FROM User WHERE Email  = 'testuser@test.com'
                                 ORDER BY createddate LIMIT 1 ];
        Account accData = [SELECT Id,Account_Type__c,BillingCountry FROM Account WHERE Account.Recordtypeid =: accountServiceRecordType];
        Contact contactData = [SELECT Id,AccountId FROM Contact WHERE AccountId != null];
        list<OC_TH_LICSR_Country__mdt> listMetadata = [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                       WHERE OC_TH_Accout_Billing_Country__c = 'BR'
                                                       AND OC_TH_Public_Group_Country__c = 'BR'];
            
        Group testGroup = new Group(Name='test', Type='Queue');
        insert testGroup;
        GroupMember testQueue = new GroupMember(UserOrGroupId = UserInfo.getUserId(), GroupId = testGroup.id);
        insert testQueue; 
               
         Case insertCase = new Case(
            Subject = 'Test Case ',
            AccountId = accData.id,
            ContactId = contactData.id,
            Status = 'Registered',
            Priority = '1',
            Type = '901',
            OC_TH_Main_Asset_Type__c = 'Node Type',
            RecordTypeId = standardRecordType,
            OC_TH_Latest_Queue_Name__c = 'test',
            OC_TH_Customer_Description__c = 'Testing test cases 001',
            OC_TH_LI_CSR__c = True);
        System.runAs(userList[0]){
            try{
                 insert insertCase; 
                 System.assert(insertCase != null);
        mapIdToNewCase.put(insertCase.id,insertCase);
            OC_TH_CaseCheckLI_CSR.sendEmailtoPublicGroup(mapIdToNewCase);
                
            }catch(Exception ex){}
        }
      
        test.stopTest();
    }
}