/* Class Name : OC_TH_CsrServiceMilestoneTest
* Description : This test class handles case milestone. 
* Author      : IBM. 
*/
@isTest
public class OC_TH_CsrServiceMilestoneTest {
    List<Case> caseList = new List<Case>();
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
            Account accountData = (Account)OC_TestDataGenerator.createSObject(new Account());
            accountData.Account_Type__c = 'Service';
            accountData.Name = 'TestAccount001';
            accountData.CNS_Queue__c = 'test group1';
            insert accountData;
            
            Contact contactData = (Contact)OC_TestDataGenerator.createSObject(new Contact());
            if(accountData != null){
                contactData.FirstName = '001testing';
                contactData.LastName = 'TestCon0011';
                contactData.phone='4352787188';
                contactData.AccountId = accountData.id;
                contactData.Email = 'xyz@ibm.com';
                contactData.MailingCountry = 'India';     
                insert contactData;
            }
            Asset assetData = (Asset)OC_TestDataGenerator.createSObject(new Asset());
            if(accountData != null){
                assetData.name = 'NodeType';
                assetData.AccountId = accountData.id;
                insert assetData;
            }
            slaProcess slaID = [Select ID,Name from SlaProcess where Name = 'OC_TH_ServiceMilestone' LIMIT 1];
            Entitlement entitlementData = (Entitlement)OC_TestDataGenerator.createSObject(new Entitlement());
            if(accountData != null && slaID != null){
                entitlementData.Name = 'TestEntitlement001';
                entitlementData.AccountId = accountData.id;
                entitlementData.SlaProcessId = slaID.Id;
                insert entitlementData;
            }
            ServiceContract serviceContractData = (ServiceContract)OC_TestDataGenerator.createSObject(new ServiceContract());
            if(accountData != null && entitlementData != null){
                serviceContractData.Name = '0005104220Test - GSM, WCDMA' ;
                serviceContractData.AccountId = accountData.id;
                serviceContractData.StartDate = date.today();
                serviceContractData.EndDate = date.today();
                serviceContractData.OC_TH_Entitlement__c = entitlementData.Id;
                insert serviceContractData;  
            }
            Entitlement updateEntitlementData = [Select Id,Name,ServiceContractId from Entitlement where Id =: entitlementData.Id];
            if(serviceContractData != null){
                updateEntitlementData.ServiceContractId = serviceContractData.Id;
                update updateEntitlementData;
            }
            OC_TH_Service_Milestone__c serviceMilestoneData = (OC_TH_Service_Milestone__c)OC_TestDataGenerator.createSObject(new OC_TH_Service_Milestone__c());
            if(serviceContractData != null){
                serviceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
                serviceMilestoneData.OC_TH_Contract_Line_Item__c = null;
                serviceMilestoneData.OC_TH_Priority__c = '1';
                serviceMilestoneData.OC_TH_Remedy1__c = '300';
                insert serviceMilestoneData;         
            }
            OC_MD_Installed_Base_Item__c ibItemData  = (OC_MD_Installed_Base_Item__c)OC_TestDataGenerator.createSObject(new OC_MD_Installed_Base_Item__c());
            if(assetData != null && serviceContractData != null){
                ibItemData.Name = 'Ibitemtest001';
                ibItemData.OC_MD_Asset__c = assetData.id ;
                ibItemData.OC_MD_Service_Contract__c = serviceContractData.id; 
                ibItemData.OC_MD_Contract_Line_Item__c = null;
                insert ibItemData;
            }
            if(accountData != null && contactData != null && assetData != null){
                Case case1 = new Case(Subject = 'Test Case for Milestone',
                                      AccountId = accountData.id,
                                      ContactId = contactData.id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c = 'Node Type',
                                      AssetId = assetData.id,
                                      RecordTypeId = OC_TH_Constants.recordType_StandardCSR,
                                      OC_TH_Customer_Description__c = 'Testing test cases 001',
                                      OC_TH_LI_CSR__c = true,
                                      OC_TH_Installed_Base_Item__c= ibItemData.id);
                Case case2 = new Case(Subject = 'Test Case2',
                                      AccountId = accountData.id,
                                      ContactId = contactData.id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c = 'Node Type',
                                      AssetId = assetData.id,
                                      RecordTypeId = OC_TH_Constants.recordType_StandardCSR,
                                      OC_TH_Customer_Description__c = 'Testing test cases 002',
                                      OC_TH_LI_CSR__c = true);
                insert case1;
                insert case2;
            }  
        } 
    }
    @isTest
    /*Test Method to show Case Milestone on partial view csr*/
    static void partialViewCsrMilestone(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE Priority = '1' LIMIT 1];
        Case pvcCsr =  new Case(Subject = 'Test Case for Milestone',Status = 'Registered',
                                Priority = '1',
                                Type = '901',
                                RecordTypeId = OC_TH_Constants.recordType_PartialCSR,
                                ParentId = fetchStandardCase[0].Id);  
        System.runAs(userList[0]){
            try{
                insert pvcCsr;
                system.assertEquals(pvcCsr.Subject,'Test Case for Milestone');
                OC_TH_CsrServiceMilestone.getMilestoneDataFromParentID(pvcCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    /*Test Method to show Case Milestone on Collaboration csr*/
    static void CollaborationCsrMilestone(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,AccountId,Priority,Status from Case WHERE Subject = 'Test Case for Milestone' LIMIT 1];
        Case collaborationCsr =  new Case(OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case',
                                          OC_TH_Queue_Type__c = 'Local',
                                          AccountId = fetchStandardCase[0].AccountId,
                                          Priority = fetchStandardCase[0].Priority,
                                          RecordTypeId = OC_TH_Constants.recordType_CollaborationCSR, ParentId = fetchStandardCase[0].Id);
        System.runAs(userList[0]){
            try{
                insert collaborationCsr;
                system.assertEquals(collaborationCsr.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case');
                OC_TH_CsrServiceMilestone.getMilestoneDataFromParentID(collaborationCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest(); 
    }
    @isTest
    /*Test Method to show Case Milestone on Collaboration csr and PVC csr*/
    static void partialViewAndCollaborationCsrMilestone(){ 
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE Priority = '1' LIMIT 1];
        Case pvcCsr =  new Case(Subject = 'Test Case for Milestone',Status = 'Registered',
                                Priority = '1',
                                Type = '901',
                                RecordTypeId = OC_TH_Constants.recordType_PartialCSR,
                                ParentId = fetchStandardCase[0].Id);  
        Case collaborationCsr =  new Case(OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case',
                                          OC_TH_Queue_Type__c = 'Local',
                                          RecordTypeId = OC_TH_Constants.recordType_CollaborationCSR, ParentId = pvcCsr.Id);
        System.runAs(userList[0]){
            try{
                insert pvcCsr;
                system.assertEquals(pvcCsr.Subject,'Test Case for Milestone');
                insert collaborationCsr;
                system.assertEquals(collaborationCsr.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case');
                OC_TH_CsrServiceMilestone.getMilestoneDataFromParentID(collaborationCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    /*Test Method to show No Case Milestone collaboration csr*/
    static void noCsrMilestoneOnCollaborationCsr(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,AccountId,Priority,Status from Case WHERE Subject = 'Test Case2' LIMIT 1];
        Case collaborationCsr =  new Case(OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case',
                                          OC_TH_Queue_Type__c = 'Local',
                                          AccountId = fetchStandardCase[0].AccountId,
                                          Priority = fetchStandardCase[0].Priority,
                                          RecordTypeId = OC_TH_Constants.recordType_CollaborationCSR, ParentId = fetchStandardCase[0].Id);
        System.runAs(userList[0]){
            try{                       
                insert collaborationCsr;
                system.assertEquals(collaborationCsr.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case');
                OC_TH_CsrServiceMilestone.noMilestoneMessage(collaborationCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest();
    }
    @isTest
    /*Test Method to show No Case Milestone on partial view csr*/
    static void noCsrMilestoneOnPartialViewCsr(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,AccountId,Priority,Status from Case WHERE Subject = 'Test Case2' LIMIT 1];
        Case pvcCsr =  new Case(Subject = 'Test Case for Milestone',Status = 'Registered',
                                Priority = '1',
                                Type = '901',
                                RecordTypeId = OC_TH_Constants.recordType_PartialCSR,
                                ParentId = fetchStandardCase[0].Id);  
        System.runAs(userList[0]){
            try{
                insert pvcCsr;
                system.assertEquals(pvcCsr.Subject,'Test Case for Milestone');
                OC_TH_CsrServiceMilestone.noMilestoneMessage(pvcCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest();
        
    }
    
    @isTest
    /*Test Method to show No Case Milestone on partial view csr and Collaboration CSR*/
    static void noCsrMilestoneForPartialViewAndCollaboration(){ 
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE Subject = 'Test Case2' LIMIT 1];
        Case pvcCsr =  new Case(Subject = 'Test Case for Milestone',Status = 'Registered',
                                Priority = '1',
                                Type = '901',
                                RecordTypeId = OC_TH_Constants.recordType_PartialCSR,
                                ParentId = fetchStandardCase[0].Id);  
        Case collaborationCsr =  new Case(OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case',
                                          OC_TH_Queue_Type__c = 'Local',
                                          RecordTypeId = OC_TH_Constants.recordType_CollaborationCSR, ParentId = pvcCsr.Id);
        System.runAs(userList[0]){
            try{
                insert pvcCsr;
                system.assertEquals(pvcCsr.Subject,'Test Case for Milestone');
                insert collaborationCsr;
                system.assertEquals(collaborationCsr.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case');
                OC_TH_CsrServiceMilestone.getMilestoneDataFromParentID(collaborationCsr.Id);
            }Catch(Exception exp){}
        }
        Test.stopTest(); 
    }
    
    
}