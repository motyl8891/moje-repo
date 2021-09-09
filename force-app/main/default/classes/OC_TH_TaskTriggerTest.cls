/* Class Name : OC_TH_TaskTriggerTest
* Description : This test class handles all the OC_TH_TaskTriggerHandler functinallity for Task object. 
* Author      : IBM.
*/
@isTest
public class OC_TH_TaskTriggerTest {
    
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    Public Static List<ServiceContract> serviceContractList = new List<ServiceContract>();
    Public Static List<OC_MD_Installed_Base_Item__c> ibItemList = new List<OC_MD_Installed_Base_Item__c>();
    Public Static List<Entitlement> entitlementList = new List<Entitlement>();
    Public Static List<OC_TH_Service_Milestone__c> serviceMilstnList = new List <OC_TH_Service_Milestone__c>();
    Public Static List<Task> taskList = new List<Task>();
    
    
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();   
    Public Static Id rficRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId();      
    Public Static Id remedyRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
    Public Static Id answerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    
    @testSetup    
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuser@test.com';
        
        insert testuser;
        
        Id permisnSetId = [SELECT Id from PermissionSet WHERE Label = 'Ericsson Service Support Engineer'].Id;
        System.debug('Permission set Id:--' +permisnSetId);
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
           // accountList[0].CNS_Queue__c = 'AMX1/CNS';
            insert accountList;
            system.assertEquals(accountList.size(),1);
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            contactList[0].FirstName = '001testing';
            contactList[0].LastName = 'TestCon0011';
            contactList[0].phone='4352787188';
            contactList[0].AccountId = accountList[0].id;
            contactList[0].Email = 'xyz@ibm.com';
            contactList[0].MailingCountry = 'India';
            contactList[0].OC_TH_Ticket_Notifications__c = 'AnswerProvided#RemedyProvided#RFICRequested#TicketCancelled#TicketFinished#TicketCreated#EmailNotificationsEnabled';
            insert contactList;
            system.assertEquals(contactList.size(),1);
            
            //Querry to SLA Entitlement Process name.
            slaProcess slaId = [Select ID,Name from SlaProcess where Name = 'OC_TH_ServiceMilestone' LIMIT 1];
            
            entitlementList = OC_TestDataGenerator.createSObjectList(new Entitlement(),1);
            entitlementList[0].Name = 'TestEntitlement001';
            entitlementList[0].AccountId = accountList[0].id;
            entitlementList[0].SlaProcessId = slaId.Id;
            insert entitlementList;
            system.assertEquals(entitlementList.size(),1);
            
            serviceContractList = OC_TestDataGenerator.createSObjectList(new ServiceContract(),1);
            serviceContractList[0].Name = '0005104220Test - GSM, WCDMA' ;
            serviceContractList[0].AccountId = accountList[0].id;
            serviceContractList[0].StartDate = date.today();
            serviceContractList[0].EndDate = date.today();
            serviceContractList[0].OC_TH_Entitlement__c = entitlementList[0].Id;
            insert serviceContractList;
            system.assertEquals(serviceContractList.size(),1);
            
            OC_TH_Service_Milestone__c serviceMlistn = new OC_TH_Service_Milestone__c (OC_TH_Service_Contract__c=serviceContractList[0].id,
                                                                                       OC_TH_Priority__c = '1',
                                                                                       OC_TH_Remedy1__c = '30',
                                                                                       OC_TH_Solution1__c ='60',
                                                                                       OC_TH_CallBack1__c ='90'
                                                                                      );
            insert serviceMlistn; 
            
            assetList = OC_TestDataGenerator.createSObjectList(new Asset(),1);
            assetList[0].name = 'afg001';
            assetList[0].AccountId = accountList[0].id;
            assetList[0].RecordTypeId = assetRecordTypeId;
            insert assetList;
            system.assertEquals(assetList.size(),1);
            
            ibItemList  = OC_TestDataGenerator.createSObjectList(new OC_MD_Installed_Base_Item__c(),1);     
            ibItemList[0].Name = 'Ibitemtest001';
            ibItemList[0].OC_MD_Asset__c = assetList[0].id ;
            ibItemList[0].OC_MD_Service_Contract__c = serviceContractList[0].id;
            insert ibItemList;
            system.assertEquals(ibItemList.size(),1);
            
            if(!accountList.isEmpty() && !contactList.isEmpty() && !assetList.isEmpty() && !ibItemList.isEmpty() && !entitlementList.isEmpty()){
                
                Case case1 = new Case(Subject = 'Test Case for Milestone',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 001',
                                      OC_MD_Remedy_Provided__c = null,
                                      OC_TH_Installed_Base_Item__c= ibItemList[0].id,
                                      OC_TH_Service_Contract__c= ibItemList[0].OC_MD_Service_Contract__c,
                                      EntitlementId = ibItemList[0].OC_MD_Service_Contract__r.OC_TH_Entitlement__c);
                
                caseList.add(case1);  
                insert caseList;
                
            }
            
            if(!caseList.isEmpty()){
                Task rficOpenTask = new Task(         
                    RecordTypeId = rficRecordTypeId,
                    Status = 'Open',
                    WhatId = caseList[0].Id,
                    Description = 'Testing task open rfic ',
                	WhoId = contactList[0].id);
                
                Task remedyOpenTask = new Task(         
                    RecordTypeId = remedyRecordTypeId,
                    Status = 'Open',
                    WhatId = caseList[0].Id,
                    Description = 'Testing task open Remedy',
                	WhoId = contactList[0].id);
                
               /* Task remedyAnsweredTask = new Task(         
                    RecordTypeId = remedyRecordTypeId,
                    Status = 'Answered',
                    WhatId = caseList[0].Id,
                    Description = 'Testing task Remedy for Remedy1 milestone',
                	WhoId = contactList[0].id);*/
                
              /*  Task answerAnsweredTask = new Task(
                    RecordTypeId = answerRecordTypeId,
                    Status = 'Answered',
                    WhatId = caseList[0].Id,
                    Description = 'Testing task Answer for Solution1 milestone',
                	WhoId = contactList[0].id);*/
                
                Task answerOpenTask = new Task(
                    RecordTypeId = answerRecordTypeId,
                    Status = 'Open',
                    WhatId = caseList[0].Id,
                    Description = 'Testing task open Answer',
                	WhoId = contactList[0].id);
                
                taskList.add(rficOpenTask);
                taskList.add(remedyOpenTask); 
               //taskList.add(remedyAnsweredTask); 
                taskList.add(answerOpenTask); 
                //taskList.add(answerAnsweredTask); 
                System.debug('taskList:--'+taskList);
                System.debug('task size:-'+taskList.size());
                system.debug('  ####### taskList Insertion:'+ Limits.getQueries()); 
                insert taskList;
                
            }
        }        
    } 
    @isTest
    /* @ Description : This method inserts Rfic,Remedy and Answer tasks with status Requested and Answered.*/
    static void testRficRemedyAnswerAfterInsert(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();        
        List<Case> csList = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case for Milestone Answered and Requested' AND IsClosed != True LIMIT 1] ;
        
        if(!csList.isEmpty()){
            Task rficRequestedTask = new Task(         
                RecordTypeId = rficRecordTypeId,
                Status = 'Requested',
                WhatId = csList[0].Id,
                Description = 'Testing task rfic for callback1. milestone');
            
            Task remedyAnsweredTask = new Task(         
                RecordTypeId = remedyRecordTypeId,
                Status = 'Answered',
                WhatId = csList[0].Id,
                Description = 'Testing task Remedy for Remedy1 milestone');
            
            Task answerAnsweredTask = new Task(
                RecordTypeId = answerRecordTypeId,
                Status = 'Answered',
                WhatId = csList[0].Id,
                Description = 'Testing task Answer for Solution1 milestone');
            
            taskList.add(rficRequestedTask);
            taskList.add(remedyAnsweredTask); 
            taskList.add(answerAnsweredTask); 
            
        }
        
        System.runAs(userList[0]){
            try{              
                insert taskList;
                
            }Catch (Exception ex){} 
        }  Test.stopTest();       
    }
    
    @isTest
    /* @ Description : This method Updates Rfic task status Open to Requested.*/
    static void testTaskRficAfterUpdate(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest(); 
        List<Task> fetchRficTask = [SELECT WhatId,RecordTypeId,Status,Description FROM Task WHERE Status = 'Open' AND RecordTypeId =:rficRecordTypeId];       
        System.runAs(userList[0]){
            try{      
                fetchRficTask[0].Status = 'Requested';             
                update fetchRficTask;
                
            }
            Catch (Exception ex){}
        }    
        Test.stopTest();       
    }
    
    
    @isTest
    /* @ Description : This method Updates Remedy task status Open to Answered.*/
    static void testTaskRemedyAfterUpdate(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest(); 
        List<Task> fetchRemedyTask = [SELECT WhatId,RecordTypeId,Status,Description FROM Task WHERE RecordTypeId =: remedyRecordTypeId AND Status = 'Open'];
        
        System.runAs(userList[0]){
            try{    
                fetchRemedyTask[0].Status = 'Answered';
                update fetchRemedyTask;
            }
            Catch (Exception ex){}
            
        }
        Test.stopTest();       
    }
    
    @isTest
    /* @ Description : This method Updates Solution task status Open to Answered.*/
    static void testTaskSolutionAfterUpdate(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest();         
        List<Task> fetchSolutionTask = [SELECT WhatId,RecordTypeId,Status,Description FROM Task WHERE RecordTypeId =: answerRecordTypeId AND Status = 'Open' LIMIT 1];
        
        System.runAs(userList[0]){
            try{    
                fetchSolutionTask[0].Status = 'Answered';
                update fetchSolutionTask;  
            }
            Catch (Exception ex){} 
        }
        Test.stopTest();       
    }
    
   /* @isTest
    static void testDuplicateRficRecordBeforeInsert(){
        
        
        List<Task> fetchRficTask = new List<Task>();
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        
        
        List<Case> csList = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case for Milestone'] ;
        
        if(!csList.isEmpty()){ 
            fetchRficTask =  [SELECT WhatId,RecordTypeId,Status,Description FROM Task WHERE Status = 'Open' AND RecordTypeId =:rficRecordTypeId AND WhatId =: csList[0].Id];
            
            Task rficOpenTask = new Task(         
                RecordTypeId = rficRecordTypeId,
                Status = 'Open',
                WhatId = csList[0].Id,
                Description = 'Testing task open rfic ');
            taskList.add(rficOpenTask);
        }        
        System.runAs(userList[0]){
            try{                
                Insert taskList; 
            } catch(Exception ex){
                
            }
        }
    }*/
    @isTest
    static void testRficInfoAcceptedBeforeInsert(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser@test.com'
                               ORDER BY createddate LIMIT 1 ];
        Test.startTest(); 
        Case newCase = new Case();
        
        List<Case> csList = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case for Milestone'] ;
        
        if(!csList.isEmpty()){   
            Task rficInfoAcceptedTask = new Task(         
                RecordTypeId = rficRecordTypeId,
                Status = 'Info accepted',
                WhatId = csList[0].Id,
                Description = 'Testing task open rfic ');
            
            taskList.add(rficInfoAcceptedTask);
            Task answerAcceptedTask = new Task(         
                RecordTypeId = answerRecordTypeId,
                Status = 'Accepted',
                WhatId = csList[0].Id,
                Description = 'Testing task accepted answer ');
            taskList.add(answerAcceptedTask);
            
            Task remedyAcceptedTask = new Task(         
                RecordTypeId = remedyRecordTypeId,
                Status = 'Accepted',
                WhatId = csList[0].Id,
                Description = 'Testing task accepted remedy ');
            taskList.add(remedyAcceptedTask);
            System.runAs(userList[0]){
                try{ 
                    Insert taskList;  
                } catch(Exception ex){}
            }  Test.stopTest();
        }  
    }  
}