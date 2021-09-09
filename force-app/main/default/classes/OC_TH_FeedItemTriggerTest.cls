/* Class Name : OC_TH_FeedItemTriggerTest
* Description : This class handles all the trigger events for FeedItem object. 
* Author      : IBM. 
*/
@isTest
public class OC_TH_FeedItemTriggerTest {
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    
    @testSetup
    
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuser@test.com';
        insert testuser;
        
        Id permisnSetId = [SELECT Id from PermissionSet WHERE Label = 'Ericsson Service Support Engineer'].Id;        
        if(!testuser.IsActive){
            PermissionSetAssignment permissionSetList = new PermissionSetAssignment();
            permissionSetList.AssigneeId = testuser.Id;
            permissionSetList.PermissionSetId = permisnSetId; 
            insert permissionSetList;
        }
        System.runAs(testuser){
            
            accountList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accountList[0].Account_Type__c = 'Service';
            accountList[0].Name = 'TestAccount001';
            insert accountList;
            system.assertEquals(accountList.size(), 1);
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            if(accountList!= null && !accountList.isEmpty()){
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
            if(accountList != null && !accountList.isEmpty()){
                assetList[0].name = 'afg001';
                assetList[0].AccountId = accountList[0].id;
                assetList[0].RecordTypeId = assetRecordTypeId;
                insert assetList;
                system.assertEquals(assetList.size(),1);
            }
            if(!accountList.isEmpty() && !contactList.isEmpty() && !assetList.isEmpty()){ 
                Case case1 = new Case(Subject = 'Test Case Investigation Leader',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Case owner should be equal to loggedIn user');
                caseList.add(case1);  
                insert caseList;
                System.debug('Case List :--'+caseList);
            } 
        }
    }
    @isTest
    static void testFeedItemOwnerIdBeforeInsert(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        
        Case csList = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case Investigation Leader'] ;
        
        FeedItem fdItem = new FeedItem(
            ParentId = csList.Id,
            Body = 'Testing Id',
            Visibility = 'AllUsers');
        
        System.runAs(userList[0]){
            try{                
                Insert fdItem;
            } catch(Exception ex){}            
        }       
    }
}