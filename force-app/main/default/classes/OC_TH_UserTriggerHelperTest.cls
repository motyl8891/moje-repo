/* Class Name : OC_TH_UserTriggerHelper
* Description : This class handles all the trigger events for User object. 
* Author      : IBM. 
*/
@isTest
public class OC_TH_UserTriggerHelperTest {

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
            //assetData.RecordTypeId = nodeAssetRecordTypeId;
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
                                                                                 OC_TH_CSR_Priority__c  = '5',
                                                                                 OC_TH_Active__c = true);
                OC_TH_Routing_Rules__c routingRule3 = new OC_TH_Routing_Rules__c(OC_TH_Selected_Routing_Rule__c = 'Initial Routing',
                                                                                 OC_TH_Queue__c = customQueueList[2].id,
                                                                                 OC_TH_CSR_Priority__c  = '5',
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
                                      //RecordTypeId = standardRecordType,
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
                                      //RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 002',
                                      OC_TH_Installed_Base_Item__c= ibItemData.id);
                
                caseList.add(case1);
                caseList.add(case2);
                insert caseList;
            }
            system.debug('  ####### case Insertion:'+ Limits.getQueries());
            
            Task taskToInsert = (Task)OC_TestDataGenerator.createSObject(new Task());
            if(caseList != null){
            //taskToInsert.RecordTypeId = getRemedyRecordType;
            taskToInsert.WhatId = caseList[0].Id;
            taskToInsert.Description = 'First Remedy';
            taskToInsert.Status = 'Answered';
            insert taskToInsert;
        }  system.debug('  ####### Task Insertion:'+ Limits.getQueries());
        }
    }
    
    @isTest(SeeAllData = false)
    public static void checkConstants(){
        Test.startTest();
        OC_TH_Constants.testConstants();
        Test.stopTest();
    }    
}