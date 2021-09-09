/**
* @File Name          : OC_DH_FileUploadControllerTest.cls
* @Description        : Apex Class to test the DocumentHub functionality
* @Author             : Mohit Tripathi
* @Group              : Omnichannel - Service
* @Last Modified By   : Richa Gupta
* @Last Modified On   : 2020-5-23
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2020-5-20                 Mohit Tripathi           Initial Version
1.1    2020-5-23                 Richa Gupta              Added code to test Document Hub functionality
**/
@isTest
private class OC_DH_FileUploadControllerTest {
    
    @testSetup public static void setup(){
        Profile integrationUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Integration User Profile' LIMIT 1];
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User integrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = integrationUserProfile.Id, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        
        System.runAs(integrationUser){
            Account tempAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.AccountDefaults', true);
            
            Account tempPartnerAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.PartnerAccountDefaults', true);
            tempPartnerAccount.IsPartner = true;
            update tempPartnerAccount;
            Profile communityPortalUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Partner Community Custom User' LIMIT 1];
            User communityUser = (User) OC_TestDataGenerator.createSObject(new User(), 'OC_TestDataGenerator.PartnerUserDefaults');
            Contact tempPartnerContact = (Contact) OC_TestDataGenerator.createSObject(new Contact(AccountId = tempPartnerAccount.Id, Email = communityUser.Email), 'OC_TestDataGenerator.PartnerContactDefaults', true);
            
            communityUser.ContactId = tempPartnerContact.Id;
            communityUser.ProfileId = communityPortalUserProfile.Id;
            communityUser.FederationIdentifier = 'OCPARTN';
            communityUser.isActive = True;
            
            OC_TestDataGenerator.createSObject(communityUser, true);
            /*Account ac = new Account(name='Test Account', Type='Service',Visible__c = true);
			insert ac;*/
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = tempPartnerAccount.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;  
        }     
    }
    
    //Method to test the File Upload button functionality
    private static testMethod void fileUploadTest(){
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        System.runAs(runningUser){
            //fetch accountId to pass as parent Id
            Account a = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.AccountDefaults', true);
            Test.startTest();
            id fileId = OC_DH_FileUploadController.saveChunk(a.Id , 'Test Title.txt',  'Unit Test ContentVersion Body', '', '');
            OC_DH_FileUploadController.saveChunk(a.Id, 'Test Title.txt',  'Unit Test ContentVersion Body to Append', '', fileId);
            test.stopTest();
            system.assert(fileId != null);
        }
    }
    
    //Method to test the Document list on Document Hub
    private static testMethod void DocumentHubTest(){
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();              
        request.requestType = 'list_documents';            
        String jsonResponse = '{"offset":"0"},{"paggination":"false"},{"currentPageNumber":"1"}';
        request.requestBody = JSON.deserialize(jsonResponse, OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub.class);
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response = OmniChannelThemeContentController.processRequest(request);
        Test.stopTest();
    }
}