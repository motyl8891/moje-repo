/**
* @File Name          : OC_AN_UserPreferencesControllerTest 
			           (Test class for OC_AN_UserPreferencesController ) 
* @Description        : Process User Preferences for currently logged in user
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th May
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-10                 IBM               Initial Version
**/

@isTest
public with sharing class OC_AN_UserPreferencesControllerTest {
    @TestSetup
    static void makeData(){
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
        Id releaseRTId =  Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Release').getRecordTypeId();
        Id versionRTId =  Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Version').getRecordTypeId();
        Product2 p1 = new Product2(IsActive = true,Name = 'Test Product 00001',RecordTypeId = productNodeRTId);        
        Product2 p2 = new Product2(IsActive = true,Name = 'Test Product 00002',RecordTypeId = productNodeRTId);       
        OC_MD_ProductAttributes__c release1 = new OC_MD_ProductAttributes__c(OC_MD_Product__c = p1.Id,Name = 'Release 1', RecordTypeId = releaseRTId);
        
        OC_MD_ProductAttributes__c release2 = new OC_MD_ProductAttributes__c(OC_MD_Product__c = p2.Id,Name = 'Release 2', RecordTypeId = releaseRTId);
       
        OC_MD_ProductAttributes__c version1 = new OC_MD_ProductAttributes__c(OC_MD_Parent__c = release1.Id,Name = 'Version 1', RecordTypeId = versionRTId);
        
        OC_MD_ProductAttributes__c version2 = new OC_MD_ProductAttributes__c(OC_MD_Parent__c = release2.Id,Name = 'Version 2', RecordTypeId = versionRTId);
        
        Id accountServiceRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
        Id accountSalesRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Sales_Account').getRecordTypeId();
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        testuser.ProfileId = migrationProfileId;
        testuser.UserRoleId = [Select Name, DeveloperName,  Id From UserRole WHERE Id != null LIMIT 1].Id;
        testuser.IsActive = true;  
        insert testuser;

        Account pAccount =(Account)OC_TestDataGenerator.createSObject(new Account(Name = 'TestAccountParent1'
        , CurrencyIsoCode = 'INR', RecordTypeId = accountSalesRTId));
       pAccount.RecordTypeId = accountSalesRTId;
       pAccount.CurrencyIsoCode = 'EUR';

       Account a =(Account)OC_TestDataGenerator.createSObject(new Account(Name = 'TestAccount', CurrencyIsoCode = 'INR', RecordTypeId = accountServiceRTId));
       a.RecordTypeId = accountServiceRTId;
       a.CurrencyIsoCode = 'EUR';

       Account a1 =(Account)OC_TestDataGenerator.createSObject(new Account(Name = 'TestAccount1', CurrencyIsoCode = 'INR', RecordTypeId = accountServiceRTId));
       a1.RecordTypeId = accountServiceRTId;
       a1.CurrencyIsoCode = 'EUR';

        Contact c = (Contact) OC_TestDataGenerator.createSObject(new Contact());
        c.LastName ='Jersy Test 1';

        User user = (User) OC_TestDataGenerator.createSObject(new User());
        user.CommunityNickname = 'Test1';
        user.Email = 'test@test.com';       
        user.alias = 'test';
        user.IsActive = true;
        user.LastName = 'Test AN';
        user.Username = user.Email+ '.test';
        user.profileId = [SELECT Id, Name, Description from Profile WHERE Name = 'Customer Community Plus Custom User' LIMIT 1].Id;
        /*user.TimeZoneSidKey ='GMT';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';*/
        

        
        
        List<Asset> assetList = OC_TestDataGenerator.createSObjectList(new Asset(),7);
        
        

        Id bulletinRTId =  Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Bulletin_Setting').getRecordTypeId();
        Id productRTId =  Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Product_Setting').getRecordTypeId();
        List<OC_AN_User_Preferences__c> preferences = new List<OC_AN_User_Preferences__c>();
        
        System.runAs(testuser){    
            insert pAccount;
            a.ParentId = pAccount.Id;           
            insert a;
            c.AccountId = a.Id;
            insert c;
            user.Contactid = c.Id;
            insert user;
            insert p1;
            
             User u = [Select id from User where LastName = 'Test AN'];
        NetworkMember networkMem = [Select id,MemberId from NetworkMember where MemberId =: u.id ];
        networkMem.PreferencesDisableAllFeedsEmail = true;
        networkMem.PreferencesDisableFollowersEmail = true;    
		networkMem.PreferencesDisableProfilePostEmail = true;
        networkMem.PreferencesDisableSharePostEmail = true;
        networkMem.PreferencesDisableLikeEmail = true;
        networkMem.PreferencesDisableMentionsPostEmail = true;
        networkMem.PreferencesDisMentionsCommentEmail = true;
        networkMem.PreferencesDisableMessageEmail = true;
        networkMem.PreferencesDisableEndorsementEmail = true;
        networkMem.PreferencesDisableChangeCommentEmail = true;
        networkMem.PreferencesDisProfPostCommentEmail = true;
        networkMem.PreferencesDisableLaterCommentEmail = true;
        networkMem.PreferencesDisableBookmarkEmail = true;
        networkMem.PreferencesDisCommentAfterLikeEmail = true;
        networkMem.PreferencesDisableItemFlaggedEmail = true;

        update networkMem;
		
        string success = OC_AN_UserPreferencesController.alertInsertion(c.Id,'checked');
        system.assertEquals('Success',success);
        OC_AN_UserPreferencesController.alertInsertion(null,'checked');
        OC_AN_UserPreferencesController.alertInsertion(c.Id,null);
        OC_AN_UserPreferencesController.alertInsertion(null,null);
        
        OC_AN_UserPreferencesController.checkSelectedState('checked','checked',c.Id);
        OC_AN_UserPreferencesController.checkSelectedState(null,'checked',c.Id);
        OC_AN_UserPreferencesController.checkSelectedState('checked',null,c.Id);
        OC_AN_UserPreferencesController.checkSelectedState(null,null,c.Id);
        OC_AN_UserPreferencesController.checkSelectedState('checked','unchecked',c.Id);

            Map<String, boolean> obj = new Map<String, boolean>();
            obj.put('TicketCreated', false);
            obj.put('TicketFinished', false);
            obj.put('TicketCancelled', false);
            obj.put('RFICRequested', false);
            obj.put('RemedyProvided', false);
            obj.put('AnswerProvided', false);
            obj.put('EmailNotificationsEnabled', false);
           string myjson = JSON.Serialize(obj);

        OC_AN_UserPreferencesController.submitUserPreferences(myjson, String.valueOf(c.id)); 
        OC_AN_UserPreferencesController.submitUserPreferences(myjson, null); 
        
        OC_AN_UserPreferencesController.getEmailAlertSettings();
            
        OC_AN_UserPreferencesController.getEmailSettingsupdates(networkMem);
        OC_AN_UserPreferencesController.getEmailSettingsupdates(null);
        
            
      System.runas(user){
       NetworkMember NTMM = [Select id,MemberId,PreferencesDisableAllFeedsEmail,PreferencesDisableFollowersEmail,PreferencesDisableProfilePostEmail,
                                            PreferencesDisableSharePostEmail,PreferencesDisableLikeEmail,
                                            PreferencesDisableMentionsPostEmail,PreferencesDisMentionsCommentEmail,
                                            PreferencesDisableMessageEmail,PreferencesDisableEndorsementEmail,
                                            PreferencesDisableChangeCommentEmail,PreferencesDisProfPostCommentEmail,
                                            PreferencesDisableLaterCommentEmail,PreferencesDisableBookmarkEmail,
                                            PreferencesDisCommentAfterLikeEmail,PreferencesDisableItemFlaggedEmail from NetworkMember where MemberId =: u.id ];
        NTMM.PreferencesDisableAllFeedsEmail = true;
        NTMM.PreferencesDisableFollowersEmail = true;    
		NTMM.PreferencesDisableProfilePostEmail = true;
        NTMM.PreferencesDisableSharePostEmail = true;
        NTMM.PreferencesDisableLikeEmail = true;
        NTMM.PreferencesDisableMentionsPostEmail = true;
        NTMM.PreferencesDisMentionsCommentEmail = true;
        NTMM.PreferencesDisableMessageEmail = true;
        NTMM.PreferencesDisableEndorsementEmail = true;
        NTMM.PreferencesDisableChangeCommentEmail = true;
        NTMM.PreferencesDisProfPostCommentEmail = true;
        NTMM.PreferencesDisableLaterCommentEmail = true;
        NTMM.PreferencesDisableBookmarkEmail = true;
        NTMM.PreferencesDisCommentAfterLikeEmail = true;
        NTMM.PreferencesDisableItemFlaggedEmail = true;
          
         
            update NTMM;
            system.debug('MY' +NTMM);
            List<NetworkMember> NMM=new List<NetworkMember>(); 
            NMM.add(NTMM);
    	OC_AN_UserPreferencesController.getEmailSettings(); 
            }
            
            Integer index = 0;
            for(Asset assObj : assetList){
                assObj.Name='Asset'+index+' Testing';
                assObj.AccountId=a.id;
                assObj.Product2Id = p1.Id;
                index++;
            }
            
            release1.OC_MD_Product__c = p1.Id;            
            
            insert p2;
            release2.OC_MD_Product__c = p2.Id;

            insert release1;
            insert release2;

            version1.OC_MD_Parent__c = release1.Id;
            version2.OC_MD_Parent__c = release2.Id;
            insert version1;
            insert version2;

            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = p1.Name, OC_AN_Product__c = p1.Id, RecordTypeId = productRTId, OC_AN_User__c = UserInfo.getUserId()));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = p2.Name, OC_AN_Product__c = p2.Id, RecordTypeId = productRTId, OC_AN_User__c = UserInfo.getUserId()));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = release1.Name, OC_AN_ProductAttribute__c = release1.Id, RecordTypeId = productRTId, OC_AN_User__c = UserInfo.getUserId()));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = version1.Name, OC_AN_ProductAttribute__c = version1.Id, RecordTypeId = productRTId, OC_AN_User__c = UserInfo.getUserId()));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = 'High', RecordTypeId = bulletinRTId, OC_AN_User__c = UserInfo.getUserId()));
            
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = p1.Name, OC_AN_Product__c = p1.Id, RecordTypeId = productRTId, OC_AN_User__c = user.Id));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = p2.Name, OC_AN_Product__c = p2.Id, RecordTypeId = productRTId, OC_AN_User__c =  user.Id));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = release1.Name, OC_AN_ProductAttribute__c = release1.Id, RecordTypeId = productRTId, OC_AN_User__c = user.Id));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = version1.Name, OC_AN_ProductAttribute__c = version1.Id, RecordTypeId = productRTId, OC_AN_User__c = user.Id));
            preferences.add(new OC_AN_User_Preferences__c(OC_AN_Email__c = true, OC_AN_Notification_Panel__c = true, Name = 'High', RecordTypeId = bulletinRTId, OC_AN_User__c = user.Id));
        

            insert preferences;
        }
        

    }

    @IsTest
    static void testmethod1() {
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
        System.assertNotEquals(null, productNodeRTId);
        Product2 p1 = [SELECT Id, Name FROM Product2 WHERE Id != null LIMIT 1];
        System.assertNotEquals(null, p1);
        Id releaseRTId =  Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Release').getRecordTypeId();
        Id versionRTId =  Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Version').getRecordTypeId();
        System.assertNotEquals(null, releaseRTId);
        System.assertNotEquals(null, versionRTId);
        OC_MD_ProductAttributes__c releas1 = [SELECT Id, Name FROM OC_MD_ProductAttributes__c WHERE Id != null AND RecordTypeID = :releaseRTId LIMIT 1];
        OC_MD_ProductAttributes__c versio1 = [SELECT Id, Name FROM OC_MD_ProductAttributes__c WHERE Id != null AND RecordTypeID = :versionRTId LIMIT 1];
        System.assertNotEquals(null, releas1);
        System.assertNotEquals(null, releas1);
        Test.startTest();
        try{
            OC_AN_UserPreferencesController.ProductListWrapper plw =  OC_AN_UserPreferencesController.getProducts(null);
            System.assertEquals(0, plw.products.size());
            System.assertNotEquals('success', OC_AN_UserPreferencesController.saveUserPreference(null));
        }catch(Exception e){
            //System.assertEquals(e, e);
        }
        
            
        OC_AN_UserPreferencesController.UserPreferenceWrapper uWrapper = new OC_AN_UserPreferencesController.UserPreferenceWrapper();
        uWrapper.isCommunityUser = false;
        uWrapper.isCompleted = false;
        uWrapper.offsetCount = 0;

        AggregateResult ar = [SELECT count(Id) FROM Product2];
        System.assertNotEquals(0, OC_AN_UserPreferencesController.getProducts(uWrapper).products.size());

        uWrapper.offsetCount = 0;
        uWrapper.productCount = Integer.valueOf(ar.get('expr0'));
        System.assertNotEquals(0, OC_AN_UserPreferencesController.getProducts(uWrapper).products.size());

        uWrapper.offsetCount = Integer.valueOf(ar.get('expr0'));
        uWrapper.productCount = Integer.valueOf(ar.get('expr0'));
        System.assertEquals(0, OC_AN_UserPreferencesController.getProducts(uWrapper).products.size());

        Id commProfileId =  [SELECT Id, Name, Description from Profile WHERE Name = 'Customer Community Plus Custom User' LIMIT 1].Id;
        User commUser = [SELECT Id, IsPortalEnabled, ContactId, Contact.AccountId from User 
         WHERE ProfileId = :commProfileId AND ContactId != null AND Contact.AccountId != null LIMIT 1];
        Map<String, Product2> productList = new Map<String, Product2>([SELECT Id From Product2 WHERE RecordTypeId = :productNodeRTId]);
        
        System.runAs(commUser){
            uWrapper = new OC_AN_UserPreferencesController.UserPreferenceWrapper();
            List<String> productIds = new List<String>();
            productIds.addAll(productList.keySet());
            uWrapper.productCount =0;
            uWrapper.isCommunityUser = true;
            uWrapper.isCompleted = false;
            uWrapper.offsetCount = 0;

            OC_AN_UserPreferencesController.getProducts(uWrapper);

            uWrapper = new OC_AN_UserPreferencesController.UserPreferenceWrapper();
             uWrapper.productCount =0;
            uWrapper.isCommunityUser = true;
            uWrapper.isCompleted = false;
            uWrapper.offsetCount = 0;
            OC_AN_UserPreferencesController.getProducts(uWrapper);

           uWrapper.isCommunityUser = true;
            uWrapper.isCompleted = false;
            uWrapper.offsetCount = 0;
            uWrapper.productCount = Integer.valueOf(ar.get('expr0'));
            OC_AN_UserPreferencesController.getProducts(uWrapper);

            uWrapper.offsetCount = Integer.valueOf(ar.get('expr0'));
            uWrapper.productCount = Integer.valueOf(ar.get('expr0'));
            uWrapper.isCommunityUser = true;
            uWrapper.isCompleted = false;
            OC_AN_UserPreferencesController.getProducts(uWrapper);
            
            OC_AN_UserPreferencesController.EmailAlertsWrapper ewrapper = new OC_AN_UserPreferencesController.EmailAlertsWrapper ();

            ewrapper.isTicketCreated = true;
            ewrapper.isTicketFinished = true;
            ewrapper.isTicketCancelled = false;
            ewrapper.isRFICRequested = true;
            ewrapper.isRemedyProvided = true;
            ewrapper.isAnswerProvided = false;
            ewrapper.isEmailNotificationEnabled = true;	
            
            OC_AN_UserPreferencesController.getEmailAlertSettings();
            ewrapper.isTicketCreated = false;
            ewrapper.isTicketFinished = false;
            ewrapper.isTicketCancelled = true;
            ewrapper.isRFICRequested = false;
            ewrapper.isRemedyProvided = false;
            ewrapper.isAnswerProvided = true;
            ewrapper.isEmailNotificationEnabled = false;
            
            OC_AN_UserPreferencesController.getEmailAlertSettings();
            ewrapper.isTicketCreated = false;
            ewrapper.isTicketFinished = false;
            ewrapper.isTicketCancelled = true;
            ewrapper.isRFICRequested = false;
            ewrapper.isRemedyProvided = false;
            ewrapper.isAnswerProvided = true;
            ewrapper.isEmailNotificationEnabled = false;

            System.assertNotEquals(null, OC_AN_UserPreferencesController.getCurrentUserPreference().bulletin);
            System.assertNotEquals(null, OC_AN_UserPreferencesController.getCurrentUserPreference().product);
        }

        OC_AN_UserPreferencesController.getCurrentUserPreference();
        OC_AN_UserPreferencesController.PreferenceWrapper wrapper = new OC_AN_UserPreferencesController.PreferenceWrapper ();
        wrapper.bulletin = new Map<String, Map<String, Object>>();
        wrapper.product = new Map<String, Map<String, Object>>();
        List<RecordType>  recordTypes = [Select DeveloperName, Id from RecordType 
        Where DeveloperName = :OC_AN_Constants.UserPreference_RT_Bulletin OR DeveloperName = :OC_AN_Constants.UserPreference_RT_Product];   
       for(RecordType rt : recordTypes){
              if(rt.DeveloperName == OC_AN_Constants.UserPreference_RT_Product ){
              wrapper.product.put(OC_AN_Constants.UserPreference_Key_recordType, new Map<String, Object>{OC_AN_Constants.UserPreference_Key_Id => rt.Id, OC_AN_Constants.UserPreference_Field_DeveloperName => rt.DeveloperName});
  
            }
            if(rt.DeveloperName == OC_AN_Constants.UserPreference_RT_Bulletin ){
                wrapper.bulletin.put(OC_AN_Constants.UserPreference_Key_recordType, new Map<String, Object>{OC_AN_Constants.UserPreference_Key_Id => rt.Id, OC_AN_Constants.UserPreference_Field_DeveloperName => rt.DeveloperName});
                wrapper.bulletin.put('High', new Map<String, Object>{'email' => true, 'notification' => true});
                wrapper.bulletin.put('FYI', new Map<String, Object>{'email' => true, 'notification' => true});
                wrapper.bulletin.put('Maintenance', new Map<String, Object>{'email' => true, 'notification' => true});
            }
            
        }
        System.runAs(commUser){  
            OC_AN_UserPreferencesController.getCurrentUserPreference();
            OC_AN_UserPreferencesController.saveUserPreference(wrapper);
        
        }

        Test.stopTest();
             
    }
        
    
}