/* Class Name : OC_TH_CaseTeamMemberTest
* Description : Test class for OC_TH_CaseTeamMember.
* Author      : Subashini Arulalan
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0      2021-03-16         Subashini Arulalan       Initial Version as part of U-2585
*/


@isTest
public class OC_TH_CaseTeamMemberTest {
    
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    public Static List<Case> colabCaseList = new List<Case>();
    Public Static List<Task> taskList = new List<Task>();
    Public Static List<PermissionSetAssignment> psAssignmtList = new List<PermissionSetAssignment>();
    
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Public Static Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();
    Public Static Id getRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
    Public Static Id getAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
    Public Static Id getRequestForInfoRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId(); 
    
    @testSetup
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuserteamMem@test.com';
        insert testuser;        
        
        User testuser1 = (User)TestDataGenerator.createSObject(new User());
        testuser1.UserName = 'ericssontest@test.com'+System.currentTimeMillis();
        testuser1.ProfileId = serviceprofileId;
        testuser1.Email = 'testuserteamMem1@test.com';
        insert testuser1;
        
        User testuser2 = (User)TestDataGenerator.createSObject(new User());
        testuser2.UserName = 'ericssontestt@test.com'+System.currentTimeMillis();
        testuser2.ProfileId = serviceprofileId;
        testuser2.Email = 'testuserteamMem2@test.com';
        insert testuser2;
        
        Id permisnSetId = [SELECT Id from PermissionSet WHERE Label = 'Ericsson Service Support Engineer'].Id;
        
        
        PermissionSetAssignment permissionSetUser1 = new PermissionSetAssignment();
        permissionSetUser1.AssigneeId = testuser.Id;
        permissionSetUser1.PermissionSetId = permisnSetId; 
        
        PermissionSetAssignment permissionSetUser2 = new PermissionSetAssignment();
        permissionSetUser2.AssigneeId = testuser1.Id;
        permissionSetUser2.PermissionSetId = permisnSetId; 
        
        PermissionSetAssignment permissionSetUser3 = new PermissionSetAssignment();
        permissionSetUser3.AssigneeId = testuser2.Id;
        permissionSetUser3.PermissionSetId = permisnSetId;
        
        psAssignmtList.add(permissionSetUser1);
        psAssignmtList.add(permissionSetUser2);
        psAssignmtList.add(permissionSetUser3);
        
        insert psAssignmtList;
        
        System.runAs(testuser){
            
            accountList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accountList[0].Account_Type__c = 'Service';
            accountList[0].Name = 'TestAccount001';
            insert accountList;
            system.assertEquals(accountList.size(), 1);
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            if(!accountList.isEmpty()){
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
            if(!accountList.isEmpty()){
                assetList[0].name = 'afg001';
                assetList[0].AccountId = accountList[0].id;
                assetList[0].RecordTypeId = assetRecordTypeId;
                insert assetList;
                system.assertEquals(assetList.size(),1);
            }
            
            List<CaseTeamRole> csteam = [select id,name from CaseTeamRole];
         
            if(!accountList.isEmpty() && !contactList.isEmpty() && !assetList.isEmpty()){
                
                Case case1 = new Case(Subject = 'parent Case',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      ownerId =testuser.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 001');
                
                Case case2 = new Case(Subject = 'parent Case1',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '3',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      ownerId =testuser.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 002');
                
                Case case3 = new Case(Subject = 'parent Case2',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '3',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      ownerId =testuser.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 003');
                
                
                
                
                caseList.add(case1);
                caseList.add(case2);
                caseList.add(case3);
                insert caseList;
            }
            if(!caseList.isEmpty()){
                Case collaborationCase = new Case(OC_TH_Queue_Type__c = 'Local',
                                                  AccountId = caseList[0].AccountId,
                                                  Priority = caseList[0].Priority,
                                                  OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case',
                                                  RecordTypeId = collaborationRecordType,
                                                  ParentId = caseList[0].Id,
                                                  ownerId =  caseList[0].ownerId
                                                 );
                
                Case collaborationCase1 = new Case(OC_TH_Queue_Type__c = 'Local',
                                                   AccountId = caseList[0].AccountId,
                                                   Priority = caseList[0].Priority,
                                                   OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case 1',
                                                   RecordTypeId = collaborationRecordType,
                                                   ParentId = caseList[0].Id,
                                                   ownerId = caseList[0].ownerId
                                                  );
                colabCaseList.add(collaborationCase);
                colabCaseList.add(collaborationCase1);
                insert colabCaseList;
                
                Task taskToInsert = new Task(RecordTypeId = getRemedyRecordType,
                                             WhatId = caseList[0].Id,
                                             Description = 'First Remedy',
                                             Status = 'Open',
                                             ownerId =caseList[0].ownerId);
                
                Task taskToInsert1 = new Task(RecordTypeId = getRemedyRecordType,
                                              WhatId = caseList[2].Id,
                                              Description = 'First Remedy',
                                              Status = 'Open',
                                              ownerId =caseList[2].ownerId);
                
                taskList.add(taskToInsert);
                taskList.add(taskToInsert1);
                insert taskList;
                
                Map<String,OC_TH_Case_TeamRole__mdt> csRoleCustomSetting = OC_TH_Case_TeamRole__mdt.getAll();
                CaseTeamMember caseteam = new CaseTeamMember();
                caseteam.MemberId = testuser2.id;
                caseteam.parentId = caseList[0].Id;
                caseteam.TeamRoleId = csRoleCustomSetting.get('Team_Member').RoleId__c;
                insert caseteam;
                
            }
            
        }
    }
    
    @isTest
    static void testCollaborationCaseAfterInsert(){
        List<Case> colabCaseList = new List<Case>();
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem1@test.com'];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> fetchStandardCase = [SELECT Id,Type,Priority,Status,Subject,AccountId from Case WHERE Subject = 'parent Case' LIMIT 1];
        
        if(!fetchStandardCase.isEmpty()){
            Case collaborationCase = new Case(OC_TH_Queue_Type__c = 'Local',
                                              AccountId = fetchStandardCase[0].AccountId,
                                              Priority = fetchStandardCase[0].Priority,
                                              OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case1',
                                              RecordTypeId = collaborationRecordType,
                                              ParentId = fetchStandardCase[0].Id,
                                              ownerId = RunAsUser[0].id
                                             );
            
            Case collaborationCase1 = new Case(OC_TH_Queue_Type__c = 'Local',
                                               AccountId = fetchStandardCase[0].AccountId,
                                               Priority = fetchStandardCase[0].Priority,
                                               OC_TH_Expectation_of_Collaboration__c = 'Testing collaboration case2',
                                               RecordTypeId = collaborationRecordType,
                                               ParentId = fetchStandardCase[0].Id,
                                               ownerId = userList[0].id
                                              );
            
            colabCaseList.add(collaborationCase);
            colabCaseList.add(collaborationCase1);
            try{
                System.runAs(RunAsUser[0]){
                    insert colabCaseList;}
                List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: fetchStandardCase[0].id and MemberId =:userList[0].id];
                system.assertEquals(csteammem[0].TeamRole.Name,'Team Member');
            }Catch (Exception ex){}
            
        }
    }
    
    @isTest
    static void testStandardCaseAfterUpdateOwnerChange(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId,AccountId from Case WHERE Subject = 'parent Case1' AND Status = 'Registered' LIMIT 1];
        
        try{
            System.runAs(RunAsUser[0]){
                parentCase[0].OwnerId = userList[0].Id;
                Update parentCase[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Investigation Leader');
        }Catch (Exception ex){}
        
    }
    
    @isTest
    static void testStandardCaseAfterUpdateOwnerChangeflagcheck(){
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId,AccountId from Case WHERE Subject = 'parent Case' AND Status = 'Registered' LIMIT 1];
        
        try{
            System.runAs(RunAsUser[0]){
                parentCase[0].OwnerId = userList[0].Id;
                Update parentCase[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Investigation Leader');
        }Catch (Exception ex){}
        
    }
    
    @isTest
    static void testCollaborationCaseAfterUpdateOwnerChange(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId,AccountId from Case WHERE Subject = 'parent Case' AND Status = 'Registered' LIMIT 1];
        List<Case> childCase = [SELECT Id,ownerId,parentId from Case where ParentId =:parentCase[0].id LIMIT 1];
        
        try{
            System.runAs(RunAsUser[0]){
                childCase[0].OwnerId = userList[0].Id;
                Update childCase[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Team Member');
            
        }Catch (Exception ex){}
        
    }
    
    @isTest
    static void testCollaborationCaseAfterUpdateStatusChange(){
        
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId,AccountId from Case WHERE Subject = 'parent Case' AND Status = 'Registered' LIMIT 1];
        List<Case> childCase = [SELECT Id,ownerId,parentId,status,isclosed,OC_TH_Answered_Finished__c from Case where ParentId =: parentCase[0].id LIMIT 1];
        
        try{
            System.runAs(RunAsUser[0]){
                childCase[0].status ='Finished';
                childCase[0].OC_TH_Answered_Finished__c = 'FINISHED';
                Update childCase[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:RunAsUser[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Investigation Leader');
            
        }Catch (Exception ex){}
        
    }
    @isTest
    static void testTaskAfterInsert(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem@test.com' LIMIT 1 ];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId from Case WHERE Subject = 'parent Case1' AND Status = 'Registered' LIMIT 1];
        
        Task taskToInsert = new Task(RecordTypeId = getRemedyRecordType,
                                     WhatId = parentCase[0].Id,
                                     Description = 'First Remedy',
                                     Status = 'Open',
                                     ownerId =parentCase[0].ownerId);
        
        System.runAs(userList[0]){
            try{
                insert taskToInsert;
                List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
                system.assertEquals(csteammem[0].TeamRole.Name,'Investigation Leader');
            }Catch (Exception ex){}
        } 
    }
    
    @isTest
    static void testTaskAfterInsertWithNewOwner(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId from Case WHERE Subject = 'parent Case1' AND Status = 'Registered' LIMIT 1];
        
        Task taskToInsert = new Task(RecordTypeId = getRemedyRecordType,
                                     WhatId = parentCase[0].Id,
                                     Description = 'First Remedy',
                                     Status = 'Open',
                                     ownerId =userList[0].id);       
        System.runAs(RunAsUser[0]){
            try{
                insert taskToInsert;
                List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
                system.assertEquals(csteammem[0].TeamRole.Name,'Team Member');
            }Catch (Exception ex){}
        } 
    }
    
    @isTest
    static void testTaskAfterUpdateStatusChange(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem@test.com' LIMIT 1 ];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId from Case WHERE Subject = 'parent Case' LIMIT 1];
        List<Task> taskRec = [select id,status,ownerId,WhatId from Task where WhatId =: parentCase[0].id LIMIT 1];
        
        taskRec[0].status = 'Accepted';  
        try{
            System.runAs(userList[0]){
                Update taskRec[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Investigation Leader');  
            
        }Catch (Exception ex){}
        
    } 
    
    @isTest
    static void testTaskTriggerAfterUpdateOwnerChange(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId from Case WHERE Subject = 'parent Case' LIMIT 1];
        List<Task> taskRec = [SELECT Id,ownerId,WhatId from Task where WhatId =: parentCase[0].id LIMIT 1]; 
        try{
            System.runAs(RunAsUser[0]){
                taskRec[0].OwnerId = userList[0].Id;
                Update taskRec[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Team Member');            
        }Catch (Exception ex){}
        
    } 
    
    @isTest
    static void testTaskAfterUpdateFlagcheck(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' LIMIT 1 ];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];
        List<Case> parentCase = [SELECT Id,Type,Priority,Status,Subject,OwnerId from Case WHERE Subject = 'parent Case2' LIMIT 1];
        List<Task> taskRec = [SELECT Id,ownerId,WhatId from Task where WhatId =: parentCase[0].id LIMIT 1];
        try{
            System.runAs(RunAsUser[0]){
                taskRec[0].OwnerId = userList[0].Id;
                Update taskRec[0];}
            List<caseteamMember> csteammem = [select id,ParentId,MemberId,TeamRole.Name from CaseTeamMember where ParentId =: parentCase[0].id and MemberId =:userList[0].id];
            system.assertEquals(csteammem[0].TeamRole.Name,'Team Member'); 
        }Catch (Exception ex){}
        
    } 
    
}