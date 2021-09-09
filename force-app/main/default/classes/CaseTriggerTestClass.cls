@isTest
public class CaseTriggerTestClass {
    
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OC_TH_Standard_CSR').getRecordTypeId();
    Public Static Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OC_TH_Collaboration_CSR').getRecordTypeId();
    Public Static Id nodeAssetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
    Public Static Id getRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();  
    Public Static Id getAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();


    @testSetup
    static void setup(){ 
        
        List<Case> caseList = new List<Case>();
        List<Task> taskList = new List<Task>();
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
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
            System.assertEquals('TestAccount001', accountData.Name);
            System.debug('Account List :---' +accountData);
            
            Contact contactData = (Contact)OC_TestDataGenerator.createSObject(new Contact());
            contactData.FirstName = '001testing';
            contactData.LastName = 'TestCon0011';
            contactData.phone='4352787188';
            contactData.AccountId = accountData.id;
            contactData.Email = 'xyz@ibm.com';
            contactData.MailingCountry = 'India';     
            insert contactData;
            system.assertEquals(contactData.FirstName,'001testing');
            System.debug('Contact List :---' +contactData);
            
            Asset assetData = (Asset)OC_TestDataGenerator.createSObject(new Asset());
            assetData.name = 'NodeType';
            assetData.AccountId = accountData.id;
            assetData.RecordTypeId = nodeAssetRecordTypeId;
            insert assetData;
            system.assertEquals(assetData.name,'NodeType');
            
            slaProcess slaID = [Select ID,Name from SlaProcess where Name = 'OC_TH_ServiceMilestone' LIMIT 1];
            
            Entitlement entitlementData = (Entitlement)OC_TestDataGenerator.createSObject(new Entitlement());
            entitlementData.Name = 'TestEntitlement001';
            entitlementData.AccountId = accountData.id;
            entitlementData.SlaProcessId = slaID.Id;
            insert entitlementData;
            System.debug('entitlement Data :---' +entitlementData);
            system.assertEquals(entitlementData.Name,'TestEntitlement001'); 
            
            ServiceContract serviceContractData = (ServiceContract)OC_TestDataGenerator.createSObject(new ServiceContract());
            serviceContractData.Name = '0005104220Test - GSM, WCDMA' ;
            serviceContractData.AccountId = accountData.id;
            serviceContractData.StartDate = date.today();
            serviceContractData.EndDate = date.today();
            serviceContractData.OC_TH_Entitlement__c = entitlementData.Id;
            insert serviceContractData;  
            system.debug('Service contract data :--'+serviceContractData);
            system.assertEquals(serviceContractData.Name,'0005104220Test - GSM, WCDMA'); 
            
            Entitlement updateEntitlementData = [Select Id,Name,ServiceContractId from Entitlement where Id =: entitlementData.Id];
            updateEntitlementData.ServiceContractId = serviceContractData.Id;
            update updateEntitlementData;
            system.debug(' entitlement data Updation:---'+updateEntitlementData);
            
            OC_TH_Service_Milestone__c serviceMilestoneData = (OC_TH_Service_Milestone__c)OC_TestDataGenerator.createSObject(new OC_TH_Service_Milestone__c());
                serviceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
                serviceMilestoneData.OC_TH_Contract_Line_Item__c = null;
                serviceMilestoneData.OC_TH_Priority__c = '1';
                serviceMilestoneData.OC_TH_Remedy1__c = '30';
                serviceMilestoneData.OC_TH_Solution1__c ='60';
                serviceMilestoneData.OC_TH_CallBack1__c ='90'; 
            insert serviceMilestoneData;
            System.assertEquals('1', serviceMilestoneData.OC_TH_Priority__c);
            System.debug('Service Milestone Data :--' +serviceMilestoneData);
            
            OC_MD_Installed_Base_Item__c ibItemData  = (OC_MD_Installed_Base_Item__c)OC_TestDataGenerator.createSObject(new OC_MD_Installed_Base_Item__c());
            ibItemData.Name = 'Ibitemtest001';
            ibItemData.OC_MD_Asset__c = assetData.id ;
            ibItemData.OC_MD_Service_Contract__c = serviceContractData.id; 
            ibItemData.OC_MD_Contract_Line_Item__c = null;
            insert ibItemData;
            system.debug(' OC_MD_Installed_Base_Item__c Insertion:'+ibItemData);
            system.assertEquals(ibItemData.Name,'Ibitemtest001');       
            
            if(accountData != null && contactData != null && assetData != null){
                Case case1 = new Case(Subject = 'Test Case for Milestone Status',
                                      AccountId = accountData.id,
                                      ContactId = contactData.id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c = 'Node Type',
                                      AssetId = assetData.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 001',
                                      OC_TH_Installed_Base_Item__c= ibItemData.id);
                System.debug('Case1----' +case1);
                Case case2 = new Case(Subject = 'Test Case Milestone for Collaboration cases',
                                      AccountId = accountData.id,
                                      ContactId = contactData.id,
                                      Status = 'Registered',
                                      Priority = '3',
                                      Type = '902',
                                      OC_TH_Main_Asset_Type__c = 'Node Type',
                                      AssetId = assetData.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 002',
                                      OC_TH_Installed_Base_Item__c= ibItemData.id);
                
                System.debug('Case1----' +case2);
                
                caseList.add(case1);
                caseList.add(case2);
                insert caseList;
                system.assertEquals(caseList.size(),2);
                System.debug('CaseList :--' +caseList);
                system.debug(' caseList Insertion:'+ Limits.getQueries());
            }
           /* Task taskToInsert = (Task)OC_TestDataGenerator.createSObject(new Task());
            taskToInsert.RecordTypeId = getRemedyRecordType;
            taskToInsert.WhatId = caseList[0].Id;
            taskToInsert.Description = 'First Remedy';
            taskToInsert.Status = 'Open';
            taskList.add(taskToInsert);*/
            
            Task taskToInsert2 = (Task)OC_TestDataGenerator.createSObject(new Task());
            taskToInsert2.RecordTypeId = getAnswerRecordType;
            taskToInsert2.WhatId = caseList[1].Id;
            taskToInsert2.Description = 'First Solution Answer Task';
            taskToInsert2.Status = 'Answered';
            taskList.add(taskToInsert2);
              
            insert taskList; 
            system.debug('  ####### taskList Insertion:'+ Limits.getQueries());
           /* OC_checkTriggerRecursive.runAgentTimeSpentValidationCheck = true;
            taskToInsert.status = 'Answered';
            update taskToInsert;
            system.debug('  ####### taskList Updation:'+ Limits.getQueries());*/
            
        }  
    }
    
    @isTest
    static void testCollaborationInsertionForCallback1(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ]; 
        List<Case> fetchStandardCaseList = [SELECT Id,Type,Priority,Status,Subject,AccountId FROM Case WHERE Subject = 'Test Case Milestone for Collaboration cases'];            
        
        if(fetchStandardCaseList != null && !fetchStandardCaseList.isEmpty()){
            Case collaborationCase = new Case(OC_TH_Queue_Type__c = 'Local',
                                              AccountId = fetchStandardCaseList[0].AccountId,
                                              Priority = fetchStandardCaseList[0].Priority,
                                              OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case to auto close Callback1',
                                              RecordTypeId = collaborationRecordType,
                                              ParentId = fetchStandardCaseList[0].Id );  
            Test.startTest();
            System.runAs(userList[0]){
                try{
                    insert collaborationCase; 
                    System.debug('Collaboration case after Insertion:---' +collaborationCase);
                    system.assertEquals(collaborationCase.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case to auto close Callback1');
                }Catch (DmlException e){
                    System.assertEquals(Case.OC_TH_Expectation_of_Collaboration__c, e.getDmlFields(0)[0]);
                }
            } 
            Test.stopTest();
        }   
    }
    
    @isTest
    static void testServiceMilestoneInsertion(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ]; 
        
    }
    
    
    
}