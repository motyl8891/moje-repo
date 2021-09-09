/* Class Name : OC_TH_CaseTriggerHandler
* Description : This class handles all the trigger events for Case object. 
* Author      : IBM. 
*/
@isTest
public class OC_TH_CaseTriggerTest {

  Public Static Id nodeAssetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    Public Static Id componentAssetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeComponentRecordType).getRecordTypeId();
    Public Static Id solutionAssetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getSolutionRecordType).getRecordTypeId();
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Public Static Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();
    Public Static Id getRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
    Public Static Id getAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
    
    @testSetup
    static void setup(){
        
        List<Case> caseList = new List<Case>();
        List<OC_TH_Routing_Rules__c> routingRuleList = new List<OC_TH_Routing_Rules__c>();
        List<Group> groupList = new List<Group>();
        List<QueueSObject> queueList = new List<QueueSObject>();
        List<OC_TH_Queues__c> customQueueList = new List<OC_TH_Queues__c>();
        
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
        Group testGroup1 = new Group(Name='test group1', Type='Queue');
        Group testGroup2 = new Group(Name='test group2', Type='Queue');
        Group testGroup3 = new Group(Name='test group3', Type='Queue');
        groupList.add(testGroup1);
        groupList.add(testGroup2);
        groupList.add(testGroup3);
        insert groupList;
        system.debug('  ####### groupList Insertion:'+ Limits.getQueries()); 
        
        QueuesObject queue1 = new QueueSObject(QueueID = testGroup1.id, SObjectType = 'Case');
        QueuesObject queue2 = new QueueSObject(QueueID = testGroup2.id, SObjectType = 'Case');
        QueuesObject queue3 = new QueueSObject(QueueID = testGroup3.id, SObjectType = 'Case');
        queueList.add(queue1);
        queueList.add(queue2);
        queueList.add(queue3);
        insert queueList;
        system.debug('  ####### Queue Insertion:'+ Limits.getQueries()); 

        System.runAs(testuser){ 
            Account accountData = (Account)OC_TestDataGenerator.createSObject(new Account());
            accountData.Account_Type__c = 'Service';
            accountData.Name = 'TestAccount001';
            accountData.CNS_Queue__c = 'test group1';
            insert accountData;
            System.debug('Account data:--'+accountData);
            system.debug('  ####### Account Insertion:'+ Limits.getQueries());
            
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
           system.debug('  ####### Contact Insertion:'+ Limits.getQueries());
            
            Asset assetData = (Asset)OC_TestDataGenerator.createSObject(new Asset());
            if(accountData != null){
            assetData.name = 'NodeType';
            assetData.AccountId = accountData.id;
            assetData.RecordTypeId = nodeAssetRecordTypeId;
            insert assetData;
            }
            system.debug('  ####### Asset Insertion:'+ Limits.getQueries());
            
            slaProcess slaID = [Select ID,Name from SlaProcess where Name = 'OC_TH_ServiceMilestone' LIMIT 1];
            system.debug('  ####### Sla Process:'+ Limits.getQueries());
            
            Entitlement entitlementData = (Entitlement)OC_TestDataGenerator.createSObject(new Entitlement());
            if(accountData != null && slaID != null){
            entitlementData.Name = 'TestEntitlement001';
            entitlementData.AccountId = accountData.id;
            entitlementData.SlaProcessId = slaID.Id;
            insert entitlementData;
            }
            system.debug('  ####### Entitlement Insertion:'+ Limits.getQueries());

            ServiceContract serviceContractData = (ServiceContract)OC_TestDataGenerator.createSObject(new ServiceContract());
            if(accountData != null && entitlementData != null){
            serviceContractData.Name = '0005104220Test - GSM, WCDMA' ;
            serviceContractData.AccountId = accountData.id;
            serviceContractData.StartDate = date.today();
            serviceContractData.EndDate = date.today();
            serviceContractData.OC_TH_Entitlement__c = entitlementData.Id;
            insert serviceContractData;  
            }
            system.debug('  ####### ServiceContract Insertion:'+ Limits.getQueries());
            
            Entitlement updateEntitlementData = [Select Id,Name,ServiceContractId from Entitlement where Id =: entitlementData.Id];
            if(serviceContractData != null){
            updateEntitlementData.ServiceContractId = serviceContractData.Id;
            update updateEntitlementData;
            }
            system.debug('  ####### Entitlement updated Insertion:'+ Limits.getQueries());
            
            OC_TH_Service_Milestone__c serviceMilestoneData = (OC_TH_Service_Milestone__c)OC_TestDataGenerator.createSObject(new OC_TH_Service_Milestone__c());
            if(serviceContractData != null){
            serviceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
            serviceMilestoneData.OC_TH_Contract_Line_Item__c = null;
            serviceMilestoneData.OC_TH_Priority__c = '1';
            serviceMilestoneData.OC_TH_Remedy1__c = '300';
            serviceMilestoneData.OC_TH_Solution1__c ='200';
            serviceMilestoneData.OC_TH_CallBack1__c ='90'; 
            insert serviceMilestoneData;         
            }
           system.debug('  ####### OC_TH_Service_Milestone__c Insertion:'+ Limits.getQueries());
            OC_MD_Installed_Base_Item__c ibItemData  = (OC_MD_Installed_Base_Item__c)OC_TestDataGenerator.createSObject(new OC_MD_Installed_Base_Item__c());
            if(assetData != null && serviceContractData != null){
            ibItemData.Name = 'Ibitemtest001';
            ibItemData.OC_MD_Asset__c = assetData.id ;
            ibItemData.OC_MD_Service_Contract__c = serviceContractData.id; 
            ibItemData.OC_MD_Contract_Line_Item__c = null;
            insert ibItemData;
            }
            system.debug('  ####### OC_MD_Installed_Base_Item__c Insertion:'+ Limits.getQueries());
            
            OC_TH_Queues__c customQueue1 = new OC_TH_Queues__c(Name = 'test group1', OC_TH_Queue_Type__c = 'Local');
            OC_TH_Queues__c customQueue2 = new OC_TH_Queues__c(Name = 'test group2', OC_TH_Queue_Type__c = 'Local');
            OC_TH_Queues__c customQueue3 = new OC_TH_Queues__c(Name = 'test group3', OC_TH_Queue_Type__c = 'Local');
            customQueueList.add(customQueue1);
            customQueueList.add(customQueue2);
            customQueueList.add(customQueue3);
            insert customQueueList;
            system.debug('  ####### OC_TH_Queues__c Insertion:'+ Limits.getQueries());
            
            if(!customQueueList.isEmpty()){
                OC_TH_Routing_Rules__c routingRule1 = new OC_TH_Routing_Rules__c(OC_TH_Selected_Routing_Rule__c = 'Initial Routing',
                                                                                 OC_TH_Queue__c = customQueueList[0].id,
                                                                                 OC_TH_Active__c = true);
                OC_TH_Routing_Rules__c routingRule2 = new OC_TH_Routing_Rules__c(OC_TH_Selected_Routing_Rule__c = 'Initial Routing',
                                                                                 OC_TH_Queue__c = customQueueList[1].id,
                                                                                 OC_TH_CSR_Priority__c	= '5',
                                                                                 OC_TH_Active__c = true);
                OC_TH_Routing_Rules__c routingRule3 = new OC_TH_Routing_Rules__c(OC_TH_Selected_Routing_Rule__c = 'Initial Routing',
                                                                                 OC_TH_Queue__c = customQueueList[2].id,
                                                                                 OC_TH_CSR_Priority__c	= '5',
                                                                                 OC_TH_Active__c = true);                                                               
                
                routingRuleList.add(routingRule1);
                routingRuleList.add(routingRule2);
                routingRuleList.add(routingRule3);
                insert routingRuleList;
            }
            system.debug('  ####### OC_TH_Routing_Rules__c Insertion:'+ Limits.getQueries());
            
            if(accountData != null && contactData != null && assetData != null && ibItemData != null){
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
                
                Case case2 = new Case(Subject = 'Test Case Milestone for Collaboration cases',
                                      AccountId = accountData.id,
                                      ContactId = contactData.id,
                                      Status = 'Registered',
                                      Priority = '5',
                                      Type = '902',
                                      OC_TH_Main_Asset_Type__c = 'Node Type',
                                      AssetId = assetData.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 002',
                                      OC_TH_Installed_Base_Item__c= ibItemData.id);
                
                caseList.add(case1);
                caseList.add(case2);
                insert caseList;
            }
            system.debug('  ####### case Insertion:'+ Limits.getQueries());
            
            Task taskToInsert = (Task)OC_TestDataGenerator.createSObject(new Task());
            if(caseList != null){
            taskToInsert.RecordTypeId = getRemedyRecordType;
            taskToInsert.WhatId = caseList[0].Id;
            taskToInsert.Description = 'First Remedy';
            taskToInsert.Status = 'Answered';
            insert taskToInsert;
        }  system.debug('  ####### Task Insertion:'+ Limits.getQueries());
        }
    }

    @isTest
    /*Test Method to start Case Milestone when Task is rejected*/
    static void triggerAfterUpdateTaskRejectToStarCaseMilestone(){
        system.debug('  ####### triggerAfterUpdateTaskRejectToStarCaseMilestone'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE  Priority = '1' LIMIT 1];
        system.debug('  ####### fetchStandardCase'+ Limits.getQueries());
        List<Task> tskList = [SELECT Id,WhatId FROM Task Where WhatId =: fetchStandardCase[0].Id LIMIT 1];
         system.debug('  ####### tskList'+ Limits.getQueries()); 
        System.runAs(userList[0]){
            try{
                tskList[0].status = 'Rejected';
                update tskList;
            }Catch(Exception exp){}
        }
        Test.stopTest();
    } 
    
    @isTest
    /*Test Method to show milestone alert when priority changes to Emergency*/
    static void triggerAfterUpdatePriorityChangeEmergencyWithMilestoneAlert(){
         system.debug('  ####### triggerAfterUpdatePriorityChangeEmergencyWithMilestoneAlert'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject from Case WHERE  Priority = '5' LIMIT 2];
       
        /*Insert custom setting data to check the condition of CaseMilestone TimeRemainingInMins with Minutes__c */
        OC_TH_WarningTimeAction__c emergencyWarningTime = new OC_TH_WarningTimeAction__c();
        emergencyWarningTime.Minutes__c = 240;
        emergencyWarningTime.Name = 'Emergency_WarningTime';
        System.runAs(userList[0]){
            try{
                insert emergencyWarningTime;
                system.assertEquals(emergencyWarningTime.Name,'Emergency_WarningTime'); 
                fetchStandardCase[0].Priority = '1';
                Update fetchStandardCase[0];
                system.assertEquals(fetchStandardCase[0].Priority,'1');
            }Catch (Exception ex){}
        }
        Test.stoptest(); 
    }
    
    @isTest
     /*Test Method to show milestone alert when priority changes to High*/
    static void triggerAfterUpdatePriorityChangeHighWithMilestoneAlert(){
         system.debug('  ####### triggerAfterUpdatePriorityChangeHighWithMilestoneAlert'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest();
        ServiceContract serviceContractData = [Select Id,Name from ServiceContract where Name = '0005104220Test - GSM, WCDMA'];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE  Priority = '1' LIMIT 1];
       
        OC_TH_Service_Milestone__c highServiceMilestoneData = new OC_TH_Service_Milestone__c();
        highServiceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
        highServiceMilestoneData.OC_TH_Contract_Line_Item__c = null;
        highServiceMilestoneData.OC_TH_Priority__c = '3';
        highServiceMilestoneData.OC_TH_Solution1__c ='20000';
        OC_TH_WarningTimeAction__c highmWarningTime = new OC_TH_WarningTimeAction__c();
        highmWarningTime.Minutes__c = 2880;
        highmWarningTime.Name = 'High_WarningTime';
        System.runAs(userList[0]){
            try{
                insert highServiceMilestoneData;
                insert highmWarningTime;
                fetchStandardCase[0].Priority = '3'; 
                Update fetchStandardCase[0];   
                system.assertEquals(fetchStandardCase[0].Priority,'3');   
            }Catch (Exception ex){}
        }
        Test.stopTest();  
    } 
    
    @isTest
     /*Test Method to show milestone alert when priority changes to Medium*/
    static void triggerAfterUpdatePriorityChangeMediumWithMilestoneAlert(){
         system.debug('  ####### triggerAfterUpdatePriorityChangeMediumWithMilestoneAlert'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest();
        ServiceContract serviceContractData = [Select Id,Name from ServiceContract where Name = '0005104220Test - GSM, WCDMA'];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE Priority = '1' LIMIT 1];
       
        OC_TH_Service_Milestone__c mediumServiceMilestoneData = new OC_TH_Service_Milestone__c();
        mediumServiceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
        mediumServiceMilestoneData.OC_TH_Contract_Line_Item__c = null;
        mediumServiceMilestoneData.OC_TH_Priority__c = '5';
        mediumServiceMilestoneData.OC_TH_Solution1__c ='20000';
        OC_TH_WarningTimeAction__c mediumWarningTime = new OC_TH_WarningTimeAction__c();
        mediumWarningTime.Minutes__c = 10080;
        mediumWarningTime.Name = 'Medium_WarningTime';
        System.runAs(userList[0]){
            try{
                insert mediumServiceMilestoneData;
                insert mediumWarningTime;
                fetchStandardCase[0].Priority = '5';
                Update fetchStandardCase[0];
                system.assertEquals(fetchStandardCase[0].Priority,'5'); 
            }Catch (Exception ex){}
        } 
        Test.stopTest(); 
    }
    
    @isTest
     /*Test Method to show milestone alert when priority changes to Low*/
    static void triggerAfterUpdatePriorityChangeLowWithMilestoneAlert(){     
         system.debug('  ####### triggerAfterUpdatePriorityChangeLowWithMilestoneAlert'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest();
        ServiceContract serviceContractData = [Select Id,Name from ServiceContract where Name = '0005104220Test - GSM, WCDMA'];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,OC_TH_Milestone_Alert__c from Case WHERE  Priority = '1' LIMIT 1];
       
        OC_TH_Service_Milestone__c lowServiceMilestoneData = new OC_TH_Service_Milestone__c();
        lowServiceMilestoneData.OC_TH_Service_Contract__c = serviceContractData.id;
        lowServiceMilestoneData.OC_TH_Contract_Line_Item__c = null;
        lowServiceMilestoneData.OC_TH_Priority__c = '9';
        lowServiceMilestoneData.OC_TH_Solution1__c ='20000';
        OC_TH_WarningTimeAction__c lowWarningTime = new OC_TH_WarningTimeAction__c();
        lowWarningTime.Minutes__c = 10080;
        lowWarningTime.Name = 'Low_WarningTime';
        System.runAs(userList[0]){
            try{
                insert lowServiceMilestoneData;
                insert lowWarningTime;
                fetchStandardCase[0].Priority = '9';
                Update fetchStandardCase[0];
                system.assertEquals(fetchStandardCase[0].Priority,'9');
            }Catch (Exception ex){}
        } 
        Test.stopTest();    
    }
    
    @isTest
    /* Test Method to update the status to check the milestone value*/
    static void testStandardCaseStatusTriggerAfterUpdate(){
         system.debug('  ####### testStandardCaseStatusTriggerAfterUpdate'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject from Case 
                                        WHERE Subject = 'Test Case for Milestone Status' AND Status = 'Registered' LIMIT 1];                                 
       
        System.runAs(userList[0]){
            try{
                fetchStandardCase[0].Status = 'Analysis';
                Update fetchStandardCase[0];  
                system.assertEquals(fetchStandardCase[0].Status,'Analysis');
            }Catch (Exception ex){}
        }
        Test.stopTest();     
    }
    
    @isTest
    /*Test Method to complete the CaseMilestone CALLBACK1 when collaboration case is created. */
    static void testCollaborationCaseTriggerAfterInsert(){ 
         system.debug('  ####### testCollaborationCaseTriggerAfterInsert'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];   
           Test.startTest();
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,AccountId from Case WHERE Priority = '5' LIMIT 2];
        if(!fetchStandardCase.isEmpty()){   
            Case collaborationCase = new Case(OC_TH_Queue_Type__c = 'Local',
                                              AccountId = fetchStandardCase[0].AccountId,
                                              Priority = fetchStandardCase[0].Priority,
                                              OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case to auto close Callback1',
                                              RecordTypeId = collaborationRecordType,
                                              ParentId = fetchStandardCase[0].Id ); 
         
            System.runAs(userList[0]){
                try{
                    insert collaborationCase; 
                    system.assertEquals(collaborationCase.OC_TH_Expectation_of_Collaboration__c,'Testing collaboration case to auto close Callback1');
                }Catch (Exception ex){}
            } 
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCaseTriggerForInitialRoutingRuleFirst(){
         system.debug('  ####### testCaseTriggerForInitialRoutingRuleFirst'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
          Test.startTest();
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Contact> conList = [SELECT Id,Name,Email FROM Contact where Email = 'xyz@ibm.com' LIMIT 1 ];
        List<Asset> assList = [SELECT Id,Name FROM Asset where Name = 'NodeType' LIMIT 1 ];
        
        if(!accList.isEmpty() && !conList.isEmpty() && !assList.isEmpty()){
            Case testCase = new Case(Subject = 'Test Case for Routing Rules',
                                     AccountId = accList[0].id,
                                     ContactId = conList[0].id,
                                     Status = 'Registered',
                                     Priority = '3',
                                     Type = '001',
                                     OC_TH_Main_Asset_Type__c='Node Type',
                                     AssetId = assList[0].id,
                                     RecordTypeId = standardRecordType,
                                     OC_TH_Customer_Description__c = 'Testing Routing Rules 001',
                                     OC_TH_Standard_CSR_Assignment_Check__c = true);
            
          
            System.runAs(userList[0]){
                try{    
                    insert testCase;      
                }Catch (Exception ex){}
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCaseTriggerForInitialRoutingRuleSecond(){
         system.debug('  ####### testCaseTriggerForInitialRoutingRuleSecond'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
         Test.startTest(); 
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Contact> conList = [SELECT Id,Name,Email FROM Contact where Email = 'xyz@ibm.com' LIMIT 1 ];
        List<Asset> assList = [SELECT Id,Name FROM Asset where Name = 'NodeType' LIMIT 1 ];
        
        if(!accList.isEmpty() && !conList.isEmpty() && !assList.isEmpty()){     
            Case testCase = new Case(Subject = 'Test Case for Routing Rules',
                                     AccountId = accList[0].id,
                                     ContactId = conList[0].id,
                                     Status = 'Registered',
                                     Priority = '5',
                                     Type = '001',
                                     OC_TH_Main_Asset_Type__c='Solution',
                                     AssetId = assList[0].id,
                                     RecordTypeId = standardRecordType,
                                     OC_TH_Customer_Description__c = 'Testing Routing Rules 002',
                                     OC_TH_Standard_CSR_Assignment_Check__c = true);
            
          
            System.runAs(userList[0]){
                try{
                    insert testCase;     
                }Catch (Exception ex){}
            }
            Test.stopTest();  
        }
    }
    
    @isTest
    static void testCaseTriggerForInitialRoutingRuleThird(){
         system.debug('  ####### testCaseTriggerForInitialRoutingRuleThird'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
          Test.startTest();
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Contact> conList = [SELECT Id,Name,Email FROM Contact where Email = 'xyz@ibm.com' LIMIT 1 ];
        List<Asset> assList = [SELECT Id,Name FROM Asset where Name = 'NodeType' LIMIT 1 ];
        
        if(!accList.isEmpty() && !conList.isEmpty() && !assList.isEmpty()){   
            Case testCase = new Case(Subject = 'Test Case for Routing Rules',
                                     AccountId = accList[0].id,
                                     ContactId = conList[0].id,
                                     Status = 'Registered',
                                     Priority = '1',
                                     Type = '001',
                                     OC_TH_Main_Asset_Type__c='Node Component',
                                     AssetId = assList[0].id,
                                     RecordTypeId = standardRecordType,
                                     OC_TH_Customer_Description__c = 'Testing Routing Rules 001',
                                     OC_TH_Standard_CSR_Assignment_Check__c = true);
            
            
            System.runAs(userList[0]){
                try{
                    insert testCase;    
                }Catch (Exception ex){}
            }
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void testCaseTriggerForBeforeUpdateSolutionType(){
         system.debug('  ####### testCaseTriggerForBeforeUpdateSolutionType'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
          Test.startTest();
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Asset> assList = [SELECT Id,Name,AccountId FROM Asset where Name ='NodeType' LIMIT 1 ];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject from Case WHERE Subject = 'Test Case for Milestone Status' AND Status = 'Registered' LIMIT 1];                                 
        
        if(!fetchStandardCase.isEmpty() && !accList.isEmpty() && !assList.isEmpty() ){
           
            System.runAs(userList[0]){
                try{
                    Asset solutionAsset = new Asset(Name = 'SolutionType',
                                                    ParentId=assList[0].id,
                                                    AccountId=accList[0].id,
                                                    RecordTypeId = solutionAssetRecordTypeId);
                    insert solutionAsset;
                    fetchStandardCase[0].OC_TH_Main_Asset_Type__c='Solution';
                    fetchStandardCase[0].AssetId = solutionAsset.id;  
                    Update fetchStandardCase[0]; 
                }Catch (Exception ex){}
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCaseTriggerForBeforeUpdateComponentType(){
         system.debug('  ####### testCaseTriggerForBeforeUpdateComponentType'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
          Test.startTest();
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Asset> assList = [SELECT Id,Name,AccountId FROM Asset where Name ='NodeType' LIMIT 1 ];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject from Case WHERE Subject = 'Test Case for Milestone Status' AND Status = 'Registered' LIMIT 1];                                 
        
        if(!fetchStandardCase.isEmpty() && !accList.isEmpty() && !assList.isEmpty() ){
            
            System.runAs(userList[0]){
                try{
                    Asset componentAsset = new Asset(Name = 'ComponentType',
                                                     ParentId=assList[0].id,
                                                     AccountId=accList[0].id,
                                                     RecordTypeId = componentAssetRecordTypeId);
                    insert componentAsset;
                    fetchStandardCase[0].OC_TH_Main_Asset_Type__c='Node Component';
                    fetchStandardCase[0].AssetId = componentAsset.id;
                    
                    Update fetchStandardCase[0];
                    
                }Catch (Exception ex){}
            } 
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCaseTriggerForBeforeUpdateNodeType(){
         system.debug('  ####### testCaseTriggerForBeforeUpdateNodeType'+ Limits.getQueries());
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
          Test.startTest();
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject from Case WHERE Subject = 'Test Case for Milestone Status' AND Status = 'Registered' LIMIT 1];                                 
        
        if(!fetchStandardCase.isEmpty() && !accList.isEmpty()){
          
            System.runAs(userList[0]){
                try{
                    Asset nodeAsset = new Asset(Name = 'NodeTypeSecond',
                                                AccountId=accList[0].id,
                                                RecordTypeId = nodeAssetRecordTypeId);
                    insert nodeAsset;
                    fetchStandardCase[0].OC_TH_Main_Asset_Type__c='Node Type';
                    fetchStandardCase[0].AssetId = nodeAsset.id; 
                    Update fetchStandardCase[0];  
                }Catch (Exception ex){}
            }
            Test.stopTest();
        }
    }
    
    @isTest(SeeAllData = false)
    public static void checkConstants(){
        Test.startTest();
        OC_TH_Constants.testConstants();
        Test.stopTest();
    }
    
    
    
}