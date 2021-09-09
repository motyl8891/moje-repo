/**
* @File Name          : OC_GST_TEST_GSTForumIntegration
* @Description        : Test class for GST Integration Functionality
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-1              Richa Gupta               Initial Version
* 2.0        2021-4-16             Aishwarya Aithal          U-2692 Ticket Handling testMethod on feedItem and FeedComment 
**/
@isTest
private class OC_GST_TEST_GSTForumIntegration {
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    
    @testSetup 
    public static void setup(){
        Id comId = [Select id from Network where Name = 'Customer Community'][0].Id;
        
        System.debug('Network Id:--' +comId);
        
        list<GST_API_Details__c> insertCustomSetting = new list<GST_API_Details__c>();
        GST_API_Details__c cs1=new GST_API_Details__c();
        cs1.Name='OC_GST_CommunityId';
        cs1.Value__c=comId;
        insertCustomSetting.add(cs1);
        
        GST_API_Details__c cs2=new GST_API_Details__c();
        cs2.Name='OC_GST_End_Point';
        cs2.Value__c='Dummy';
        insertCustomSetting.add(cs2);  
        
        GST_API_Details__c cs3=new GST_API_Details__c();
        cs3.Name='OC_GST_ForumIndexing_BatchSize';
        cs3.Value__c='200';
        insertCustomSetting.add(cs3);
        
        GST_API_Details__c cs5=new GST_API_Details__c();
        cs5.Name='OC_GST_Last_GST_Sync';
        cs5.Value__c=String.valueOf(System.now().addminutes(15));
        insertCustomSetting.add(cs5);
        
        GST_API_Details__c cs6=new GST_API_Details__c();
        cs6.Name='OC_GST_Schedule_Job_Name';
        cs6.Value__c='OC_GST_GSTForumIndexing';
        insertCustomSetting.add(cs6);
        
        GST_API_Details__c cs7=new GST_API_Details__c();
        cs7.Name='POST_URL';
        cs7.Value__c='https://msdvservic-ericssoncommunity.cs108.force.com/customer/s/question/';
        insertCustomSetting.add(cs7);
        
        GST_API_Details__c cs8=new GST_API_Details__c();
        cs8.Name='HeaderToken';
        cs8.Value__c='dummy';
        insertCustomSetting.add(cs8);
        
        GST_API_Details__c cs9=new GST_API_Details__c();
        cs9.Name='Referrer_Console';
        cs9.Value__c='https://test.salesforce.com';
        insertCustomSetting.add(cs9);
        
        GST_API_Details__c cs10=new GST_API_Details__c();
        cs10.Name='Referrer_Header';
        cs10.Value__c='referrer';
        insertCustomSetting.add(cs10);
        
        Database.insert(insertCustomSetting);
        
        FeedItem f = new FeedItem();
        f.Body = 'legal test';
        f.parentID = UserInfo.getUserId(); 
        f.Type = 'QuestionPost';
        f.Title = 'Title Feed Item'; 
        f.NetworkScope = comId;
        insert f;
        
        FeedComment fc = new FeedComment();
        fc.CommentBody = 'Comment 1';
        fc.FeedItemId = f.Id;        
        insert fc;
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuser@test.com';
        insert testuser;
        User testuser1 = (User)TestDataGenerator.createSObject(new User());
        testuser1.UserName = 'ericssonService@test.com'+System.currentTimeMillis();
        testuser1.ProfileId = serviceprofileId;
        testuser1.Email = 'testuser1@test.com';
        insert testuser1;
        
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
            }
            if(!caseList.isEmpty()){
                FeedItem fdItem = new FeedItem(
                    ParentId = caseList[0].Id,
                    Body = 'Posting Chatter for testing',
                    Visibility = 'AllUsers');
                insert fdItem;   
            }
        }
        
    }
    
    //Method to test schedule class functionality
    private static testMethod void testScheduleClass() {
        
        Test.StartTest();
        OC_GST_SCH_BATCH_GSTForumIntegration s1 = new OC_GST_SCH_BATCH_GSTForumIntegration();      
        String sch = '0 0 23 * * ?';
        system.schedule('OC_GST_GSTForumIndexing', sch, s1);
        OC_GST_SCH_BATCH_GSTForumIntegration s2 = new OC_GST_SCH_BATCH_GSTForumIntegration();      
        String sch2 = '0 0 23 * * ?';
        system.schedule('OC_GST_GSTForumIndexing3', sch2, s2);
        Test.stopTest();  
    }
    
    //Method to test full batch scenario
    private static testMethod void testFullBatch() {
        Datetime d = System.now().addminutes(-10);
        Test.StartTest();
        OC_GST_SCH_BATCH_GSTForumIntegration s1 = new OC_GST_SCH_BATCH_GSTForumIntegration(d);      
        Database.executebatch(s1,200);
        Test.stopTest();
        
    }
    
    //Method to test delete feeditem and feedcomment scenarios
    private static testMethod void testFeedDelete() {
        Test.StartTest();
        feedItem f = [Select id from FeedItem where Title='Title Feed Item' LIMIT 1];   
        FeedComment fc = [Select id from FeedComment where FeedItemId = :f.Id];   
        Database.delete(fc);
        Database.delete(f);
        Test.stopTest();
        
    }
    //U-2692 Method to test Feed comment for all user's in Tickect handling.
    static testMethod void testFeedCommentOwnerIdBeforeInsert(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser1@test.com'
                               ORDER BY createddate LIMIT 1 ];
        
        Case cs = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case Investigation Leader'] ;
        
        FeedItem fdItems = [Select Id,ParentId, Visibility from FeedItem Where ParentId =: cs.Id AND Visibility = 'AllUsers' ];
        FeedComment comment = new FeedComment(
            FeedItemId = fdItems.Id,
            CommentBody = 'posting comments for testing');
        
        System.runAs(userList[0]){
            try{                
                Insert comment;
            } catch(Exception ex){}
            
        }
    }
     //U-2692 Method to test Feed sharing post for all user's in Tickect handling.
    static testMethod void testFeedItemOwnerIdBeforeInsert(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                               FROM User WHERE Email  = 'testuser1@test.com'
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

    //Method to test Feed comment ann post for forum user.
  /*  static testMethod void testfeedForumAccessibilityPermission(){
        List<User> testuser2 = new List<User>();
        
        //System.assertEquals(false, FeatureManagement.checkPermission('OC_UAM_Forum_Accessibility'));
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            System.debug('Customer user type:--' +customerUserTypes);
        
        List<Account> accList = [SELECT ID,Name from Account where Name = 'TestAccount001' LIMIT 1];
        
        List<Contact> contactList = [Select Id from Contact Where Email = 'xyz@ibm.com' LIMIT 1];
        System.debug('Contact List' +contactList);
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.debug('This user :--' +thisUser);
        
        UserRole usrole = [select Id,PortalType,Name, DeveloperName from UserRole where Name = 'Claro-BR Customer User' LIMIT 1];
        String roleId = System.userInfo.getUserRoleId();
        System.debug('User role :--' +roleId);
        
        Profile profile1 = [Select Id from Profile where name = 'Integration User Profile'];
        User portalAccountOwner1 = new User(
            UserRoleId = roleId,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner1;

        
        Id communityprofileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Custom User' AND UserType in :customerUserTypes limit 1].Id;
        System.debug('Community profile ID :-' +communityprofileId);
        
        User Communityuser = new User(
            UserRoleId = roleId,
            profileId = communityprofileId,
            username = 'ericssonCommunity@test.com'+System.currentTimeMillis(),
            email = 'testuserCommunity@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            CommunityNickname = 'test12345',
            contactId = contactList[0].id);
        testuser2.add(Communityuser);
        insert testuser2;    
        system.debug('Community user :--' +testuser2);
        
        
        Case csList = [SELECT Id,Priority,OC_TH_Service_Contract__c,Subject,AccountId FROM Case Where Subject = 'Test Case Investigation Leader'] ;
        System.debug('CaseList :-- '+csList);
        
        
        FeedItem feed = new FeedItem();
        feed.ParentId = csList.Id;
        feed.Body = 'Testing Id';
        feed.Type = 'QuestionPost';
        feed.Title = 'Title Feed Item';
        
        System.runAs(testuser2[0]){
            try{    
                Test.startTest();
                Insert feed;
                Test.stopTest();
                System.debug('FeedItem access :--' +feed);
            } catch(Exception ex){}            
        }
    }*/
}