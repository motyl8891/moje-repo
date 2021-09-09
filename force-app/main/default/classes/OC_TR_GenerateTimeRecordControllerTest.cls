@isTest
public class OC_TR_GenerateTimeRecordControllerTest {
    Public Static Set<String> userEmpNoSet = new Set<String> ();
    @testsetup 
    static void setup(){
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id; 
        List<User> testUserList = new List<User> ();
        String networkScope;
        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList = new List<Contact> ();
        List<ServiceContract> servContractList = new List<ServiceContract> ();
        List<LiveChatTranscript> chatRecList = new List<LiveChatTranscript> ();
        List<OC_TR_TimeRecord__c> timeRecList = new List<OC_TR_TimeRecord__c>();
        List<feedComment> feedCommentList = new List<feedComment> ();
        List<Feeditem> feedItemList = new List<Feeditem> ();
        List<AgentWork> agentWorkList = new List<AgentWork> ();
         Account acc;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.OC_TR_EmployeeNumber__c = '1231110'; 
        testuser.OC_TR_EmployeeCompanyCode__c = '5470';
        insert testuser;
        Id servChannelId = [Select id, DeveloperName from ServiceChannel where DeveloperName='sfdc_liveagent'].Id;
        User testAdminUser = [Select Id,Name,ProfileId,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c FROM USER Where id=:userinfo.getUserId()];
        testAdminUser.OC_TR_EmployeeNumber__c='12322230';
        testAdminuser.OC_TR_EmployeeCompanyCode__c = '5550';
        update testAdminUser;
        
        
        PermissionSet moderatorPs = [SELECT Id,Name  FROM PermissionSet where Name ='Ericsson_Service_Community_Moderator' LIMIT 1];
        List<PermissionSetAssignment> moderatorpsa = [SELECT Id, AssigneeId, PermissionSetId from PermissionSetAssignment WHERE PermissionSetId = :moderatorPs.Id AND AssigneeId = :testAdminuser.Id];
        if(moderatorpsa == null || (moderatorpsa != null && moderatorpsa.size() == 0)){
            moderatorpsa.add(new PermissionSetAssignment(PermissionSetId = moderatorPs.Id, AssigneeId = testAdminuser.Id));
            insert moderatorpsa;
        }
        
        
        System.runAs(testAdminuser){
            for(OC_TR_TimeRecording__mdt mdtRec : [SELECT Id,OC_TR_Value1__c FROM OC_TR_TimeRecording__mdt
                                                   WHERE OC_TR_Value1__c LIKE '%0DB%']){
                                                    networkScope = mdtRec.OC_TR_Value1__c;   
                                                   }
            FeedItem feedItem = (FeedItem)TestDataGenerator.createSObject(new FeedItem());
            feedItem.NetworkScope =networkScope; 
            insert feedItem;
            
            FeedComment feedComment1 = (FeedComment)TestDataGenerator.createSObject(new FeedComment());
            feedComment1.FeedItemId = feedItem.Id;
            feedCommentList.add(feedComment1);
            FeedComment feedComment2 = (FeedComment)TestDataGenerator.createSObject(new FeedComment());
            feedComment2.FeedItemId = feedItem.Id;
            feedCommentList.add(feedComment2);
            insert feedCommentList;
          }
        
       
        System.runAs(testuser){  
            Id salesAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.RecordTypeId = salesAccRtId;
            accSales.Account_Type__c = 'Sales';
            insert accSales;
            
            acc=(Account)OC_TestDataGenerator.createSObject(new Account());
            acc.Account_Type__c = 'Service';
            acc.ParentId = accSales.Id;
            acc.RecordTypeId = salesAccRtId;
            insert acc;
            
            accList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accList[0].Account_Type__c = 'Subdivision';
            accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
            accList[0].ParentID = acc.Id;
            conList = OC_TestDataGenerator.createSObjectList(new Contact(),2);
            if(accList!=null && !accList.isEmpty() && conList!=null && !accList.isEmpty() ){
                conList[0].AccountId = acc.Id;
                conList[1].AccountId = acc.Id;
                insert conList;
                system.assertEquals(conList.size(), 2);
            }
            serviceContract contract = (serviceContract)OC_TestDataGenerator.createSObject(new serviceContract());
            //contract.AccountId = acc.id;
            contract.AccountId = acc.id;
            contract.OC_MD_Assignment_ID__c = '123';
            servContractList.add(contract);
            insert servContractList;
            system.assertEquals(servContractList.size(), 1);
        }
          System.runAs(testAdminuser){
            for(integer i=0;i<5;i++){
                LiveChatTranscript chatTranscriptRec = (LiveChatTranscript)TestDataGenerator.createSObject(new LiveChatTranscript());
                if(i == 0 || i == 1){
                    chatTranscriptRec.StartTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i, i, i);
                    chatTranscriptRec.EndTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i+1, i+20, i);
                    chatTranscriptRec.ContactId = conList[i].Id;
                    chatTranscriptRec.AccountId = conList[i].AccountId;
                    chatTranscriptRec.ownerId = testAdminuser.Id;
                    LiveChatTranscript chatTranscriptSameHourRec = (LiveChatTranscript)TestDataGenerator.createSObject(new LiveChatTranscript());   
                    chatTranscriptSameHourRec.StartTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i, i, i);
                    chatTranscriptSameHourRec.EndTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i+1, i+20, i);
                    chatTranscriptSameHourRec.ContactId = conList[i].Id;
                    chatTranscriptSameHourRec.AccountId = conList[i].AccountId;
                    chatTranscriptSameHourRec.ownerId = testAdminuser.Id;
                    chatRecList.add(chatTranscriptSameHourRec);
                }else{
                    chatTranscriptRec.StartTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i, i, i);
                    chatTranscriptRec.EndTime = DateTime.newInstanceGmt((Date.Today()).year(), (Date.Today()).month(),(Date.Today()).day(), i, i+20, i);
                    chatTranscriptRec.ContactId = conList[0].Id;
                    chatTranscriptRec.AccountId = conList[0].AccountId;
                    chatTranscriptRec.ownerId = testAdminuser.Id;
                }
                chatRecList.add(chatTranscriptRec);
            }
            insert chatRecList;
              AgentWork agntWrk1 = new AgentWork(WorkItemId = chatRecList[0].Id,UserId = testAdminuser.Id,ServiceChannelId = servChannelId );
              AgentWork agntWrk2 = new AgentWork(WorkItemId = chatRecList[1].Id,UserId = testAdminuser.Id,ServiceChannelId = servChannelId);
              AgentWork agntWrk3 = new AgentWork(WorkItemId = chatRecList[2].Id,UserId = testAdminuser.Id,ServiceChannelId = servChannelId );
              agentWorkList.add(agntWrk1);
              agentWorkList.add(agntWrk2);
              agentWorkList.add(agntWrk3);
              List<UserServicePresence> usc = [SELECT ServicePresenceStatus.DeveloperName, Id,  IsCurrentState, ConfiguredCapacity
                  , AtCapacityDuration, ServicePresenceStatusId, UserId, User.Name FROM UserServicePresence
                                         Where UserId =: testAdminuser.Id AND IsCurrentState = True 
                                         AND ServicePresenceStatus.DeveloperName = 'Available_Chat'
                                         LIMIT 1];
              if( usc != null && usc.size()>0)
                 insert agentWorkList;
            
            OC_TR_TimeRecord__c timeRecord1 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today(),
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '14', OC_TR_ServiceToAccount__c = acc.id,
                                                                  OC_TR_ObjectIdCon__c = servContractList[0].id , 
                                                                  OC_TR_Active__c = true,
                                                                  OC_TR_Status__c = 'Not Submitted'
                                                                  );
        
            OC_TR_TimeRecord__c timeRecord2 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today() ,
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '5', OC_TR_ServiceToAccount__c = acc.id,
                                                                  OC_TR_ObjectIdCon__c = servContractList[0].id , 
                                                                   OC_TR_Active__c = true,
                                                                   OC_TR_Status__c = 'Not Submitted',
                                                                   OC_TR_IsManualEntry__c = false);
            OC_TR_TimeRecord__c timeRecord3 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today() ,
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '3.2', 
                                                                  OC_TR_Active__c = true,
                                                                  //OC_TR_Organization__c = 'web_support',
                                                                  //OC_TR_ZZOrgNew__c = '123',
                                                                  //OC_TR_LegalForm__c = '09',
                                                                  OC_TR_Status__c = 'Not Submitted',
                                                                  OC_TR_IsManualEntry__c = true
                                                                   );
            OC_TR_TimeRecord__c timeRecord4 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today()-1 ,
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '1', OC_TR_ServiceToAccount__c = acc.id,
                                                                  OC_TR_ObjectIdCon__c = servContractList[0].id , 
                                                                   OC_TR_Active__c = true,
                                                                   OC_TR_Status__c = 'Not Submitted',
                                                                   OC_TR_IsManualEntry__c = false
                                                                  );
            
            timeRecList.add(timeRecord1);
            timeRecList.add(timeRecord2);
            timeRecList.add(timeRecord3);
            timeRecList.add(timeRecord4);
            insert timeRecList;
            
           
         }
        
    }
    @isTest 
    Static Void GenerateTimeRecordControllerTest1(){
        FeedItem feedItem;
        List<FeedComment> feedCommentList;
        try{
            List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                                   isActive
                                   FROM User WHERE OC_TR_EmployeeNumber__c = '1231110'
                                   ORDER BY createddate LIMIT 1 ];
            List<User> adminUserList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                                        isActive
                                        FROM User WHERE OC_TR_EmployeeNumber__c = '12322230'
                                        ORDER BY createddate LIMIT 1 ];
            system.runAs(adminUserList[0]){
                feedItem = [SELECT id,Title,Body,ParentId FROM FeedItem WHERE ParentId=:adminUserList[0].Id LIMIT 1];
                feedCommentList = [SELECT id,FeedItemId,createddate,CommentBody,CreatedById FROM FeedComment];
            }
            // System.runAs(userList[0]){
            system.runAs(adminUserList[0]){
                List<Account> accountRecList = [ SELECT id,Name,ParentId,Visible__c FROM Account ];
                List<Contact> ContactRecList = [ SELECT id,Name,AccountId FROM Contact ];
                List<OC_TR_TimeRecord__c> timeRecordRecList = [ SELECT id,OC_TR_PostingDate__c,OC_TR_ObjectIdCon__c,OC_TR_ActivityName__c,
                                                               OC_TR_Status__c,OC_TR_TimeSpent__c,OC_TR_IsManualEntry__c,CreatedById
                                                               FROM OC_TR_TimeRecord__c ]; 
                feedCommentList[0].CommentBody = 'Edit Comment-1';
                update feedCommentList[0];
                List<FeedRevision> feedRevList = [SELECT Id, CreatedById, Createddate FROM FeedRevision LIMIT 3];    
                List<ServiceContract> servContractRecList = [SELECT id,Name,AccountId FROM ServiceContract];
                List<LiveChatTranscript> chatRecList =[SELECT Id,StartTime,EndTime,OwnerId,AccountId,ContactId,
                                                       CreatedDate,Status 
                                                       FROM LiveChatTranscript];
                
                Test.startTest();
                system.runAs(adminUserList[0]){
                    OC_TR_GenerateTimeRecordController.fetchActivityOptions();
                    OC_TR_GenerateTimeRecordController.verifyLoggedInUserEmployeeDetails();
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),null);
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),'Chat');
                    OC_TR_GenerateTimeRecordController.generateTimeRecords(timeRecordRecList);  
                    FeedComment feedComment = (FeedComment)TestDataGenerator.createSObject(new FeedComment());
                    feedComment.FeedItemId = feedItem.Id;
                    insert feedComment;
                    Date currentDate = Date.today();
                    Date previousDate = currentDate.addDays(-1);
                    OC_TR_GenerateTimeRecordController.updateTimeRecords(timeRecordRecList, timeRecordRecList, false, false);
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),'Forum');
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today()+5,'Forum');
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(previousDate,'Forum');
                }
                Test.stopTest();
            }
        }
        Catch(Exception e){}
    }
    @isTest 
    Static Void GenerateTimeRecordControllerTest2(){
        List<FeedComment> feedCommentList = new  List<FeedComment> ();
        feeditem feedItem;
        List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1231110'
                               ORDER BY createddate LIMIT 1 ];
        
        List<User> adminUserList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                                    isActive
                                    FROM User WHERE OC_TR_EmployeeNumber__c = '12322230'
                                    ORDER BY createddate LIMIT 1 ];
        try{
            System.runAs(adminUserList[0]){
                List<Account> accountRecList = [ SELECT id,Name,ParentId,Visible__c FROM Account ];
                List<Contact> ContactRecList = [ SELECT id,Name,AccountId FROM Contact ];
                feedItem = [SELECT id,Title,Body,ParentId FROM FeedItem WHERE ParentId=:adminUserList[0].Id LIMIT 1];
                feedCommentList = [SELECT id,FeedItemId,createddate,CommentBody,CreatedById FROM FeedComment];
                List<OC_TR_TimeRecord__c> timeRecordRecList = [ SELECT id,OC_TR_PostingDate__c,OC_TR_ObjectIdCon__c,OC_TR_ActivityName__c,
                                                               OC_TR_Status__c,OC_TR_TimeSpent__c,OC_TR_IsManualEntry__c,CreatedById,OC_TR_Active__c
                                                               FROM OC_TR_TimeRecord__c 
                                                               //WHERE OC_TR_ActivityName__c ='Forum'
                                                              ]; 
                
                List<AgentWork> agentWorkList = [Select Id,OC_TR_Chat_Transcript__c,OC_TR_Chat_Transcript__r.AccountId,OriginalGroupId 
                                                 FROM AgentWork
                                                 WHERE CreatedById=:adminUserList[0].Id
                                                 AND CreatedDate=:date.Today()];
                feedCommentList[0].CommentBody = 'Edit Comment-1';
                update feedCommentList[0];
                List<FeedRevision> feedRevList = [SELECT Id, CreatedById, Createddate FROM FeedRevision LIMIT 3];    
                List<ServiceContract> servContractRecList = [SELECT id,Name,AccountId FROM ServiceContract];
                List<LiveChatTranscript> chatRecList =[SELECT Id,StartTime,EndTime,OwnerId,AccountId,ContactId,
                                                       CreatedDate,Status 
                                                       FROM LiveChatTranscript];
                Test.startTest();
                system.runAs(adminUserList[0]){
                    OC_TR_GenerateTimeRecordController.fetchActivityOptions();
                    OC_TR_GenerateTimeRecordController.verifyLoggedInUserEmployeeDetails();
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),null);
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),'Chat');
                    OC_TR_GenerateTimeRecordController.generateTimeRecords(timeRecordRecList);  
                    FeedComment feedComment = (FeedComment)TestDataGenerator.createSObject(new FeedComment());
                    feedComment.FeedItemId = feedItem.Id;
                    insert feedComment;
                    Date currentDate = Date.today();
                    Date previousDate = currentDate.addDays(-2);
                    OC_TR_GenerateTimeRecordController.updateTimeRecords(timeRecordRecList, timeRecordRecList, false, false);
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today(),'Forum');
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(Date.Today()+5,'Forum');
                    OC_TR_GenerateTimeRecordController.validateTimeRecordGeneration(previousDate,'Forum');
                }
                Test.stopTest();
            }
        }Catch(Exception e){}
    }
    
}