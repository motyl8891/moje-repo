/**
* @File Name          : OmniChannelThemeControllersTest
* @Description        : Test Class for
*						OC_ContentControllerSubContentFormatter (Direct)
*						OC_ContentControllerSubForum (Direct)
*						OC_ContentControllerSubGST (Direct)
*						OC_ContentControllerSubGSTClickTemp (Direct)
*						OC_ContentControllerSubProfile (Direct)
*						OC_ContentControllerSubLandingModules (Direct)
*						OC_ContentControllerSubDocuments (Direct)
*						OC_ContentControllerSubBreadcrumbs (Direct)
*						OC_ContentControllerSubNavigation (Direct)
*						OmniChannelThemeAccessController (Indirect)
*						OmniChannelThemeContentController (Indirect)
*						OmniChannelThemeContentControllerSub (Indirect)
*						OmniChannelThemeRequestReponseWrappers (Indirect)
*
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 22nd May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-22              Rohit Gaba               Initial Version
* 2.0        2020-08-28              Richa Gupta              Test class for U2008,2009,2010
* 3.0        2020-11-25              IBM		              Forum Accessibility Check
**/
@isTest
public class OmniChannelThemeControllersTest {
    
    //Landing Modules
    @isTest static void test_processOmniChannelThemeRequestRetrieveLandingModules() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        request.requestType = 'landing_modules';
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertNotEquals(0, ((OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesData) response.requestedData).moduleItems.size());
        Test.stopTest();
    }
    
    //Navigations
    @isTest static void test_processOmniChannelThemeRequestRetrieveNavigations() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        request.requestType = 'navigations';
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertNotEquals(0, ((OmniChannelThemeRequestReponseWrappers.OCResponseNavigationData) response.requestedData).navigationItems.size());
        Test.stopTest();
    }
    
    //Breadcrumbs
    @isTest static void test_processOmniChannelThemeRequestRetrieveBreadcrumbs_Topic() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs();
        request.requestType = 'other';
        request.requestSubType = 'breadcrumbs';
        request.requestBody = requestBody;
        Topic tempTopic = [SELECT Id, Name FROM Topic LIMIT 1];
        requestBody.entityId = tempTopic.Id;
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertEquals(response.requestSubType, request.requestSubType);
        System.assertEquals('Forum', ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemTitle);
        System.assertEquals(tempTopic.Name, ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemChild.itemTitle);
        Test.stopTest();
    }
    
    //Breadcrumbs
    @isTest static void test_processOmniChannelThemeRequestRetrieveBreadcrumbs_QuestionPost() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs();
        request.requestType = 'other';
        request.requestSubType = 'breadcrumbs';
        request.requestBody = requestBody;
        FeedItem questionPost = [SELECT Id, Title FROM FeedItem WHERE Type = 'QuestionPost' LIMIT 1];
        requestBody.entityId = questionPost.Id;
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertEquals(response.requestSubType, request.requestSubType);
        System.assertEquals('Forum', ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemTitle);
        System.assertEquals(questionPost.Title, ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemChild.itemTitle);
        Test.stopTest();
    }
    
    //Breadcrumbs
    @isTest static void test_processOmniChannelThemeRequestRetrieveBreadcrumbs_Case() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs();
        request.requestType = 'other';
        request.requestSubType = 'breadcrumbs';
        request.requestBody = requestBody;
        Case tempCase = [SELECT Id, Subject, OC_TH_Case_Number__c FROM Case LIMIT 1];
        requestBody.entityId = tempCase.Id;
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertEquals(response.requestSubType, request.requestSubType);
        System.assertEquals('Ticket Handling', ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemTitle);
        System.assertEquals(true, ((OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData) response.requestedData).breadcrumbs.itemChild.itemTitle.contains(tempCase.Subject));
        Test.stopTest();
    }
    
    //Profile
    @isTest static void test_processOmniChannelThemeRequestProfile() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        request.requestType = 'profile_menu';
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Partner' AND LastName = 'Testing' LIMIT 1];
        
        System.runAs(runningUser){
            
            Test.startTest();
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            System.assertEquals(UserInfo.getName(), ((OmniChannelThemeRequestReponseWrappers.OCResponseUserProfileData) response.requestedData).user.get('name'));
            Test.stopTest();
        }
    }
    
    //Recent Documents
    @isTest static void test_processOmniChannelThemeRequestRecentDocuments() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        request.requestType = 'recent_documents';
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            ContentDocument tempDocument  = [SELECT Id, Title FROM ContentDocument WHERE Title = 'OC Document' Limit 1];
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            System.assertEquals(tempDocument.Title, ((OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentData) response.requestedData).documentRecentItems[0].documentTitle);
        }
        Test.stopTest();
    }
    
    //Document Hub
    @isTest static void test_processOmniChannelThemeRequestDocumentHub() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub();
        request.requestType = 'list_documents';
        request.requestBody = requestBody;
        requestBody.currentPageNumber = 1;
        requestBody.offset = 0;
        requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            ContentDocument tempDocument  = [SELECT Id, Title FROM ContentDocument WHERE Title = 'OC Document' Limit 1];
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            System.assertEquals(tempDocument.Title, ((OmniChannelThemeRequestReponseWrappers.OCResponseDocumentData) response.requestedData).documentItems[0].documentTitle);
        }
        Test.stopTest();
    }
    
    //Recent Forums
    @isTest static void test_processOmniChannelThemeRequestRecentPosts() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        request.requestType = 'recent_forums';
        FeedItem questionPost = [SELECT Id, Title FROM FeedItem WHERE Type = 'QuestionPost' LIMIT 1];
        
        Test.startTest();
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
        System.assertEquals(response.requestType, request.requestType);
        System.assertEquals(questionPost.Title, ((OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentData) response.requestedData).forumRecentItems[0].itemTitle);
        Test.stopTest();
    }
    
    //GST Search
    @isTest static void test_processOmniChannelThemeRequestSearch() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch();
        request.requestType = 'search';
        request.requestBody = requestBody;
        requestBody.searchText = 'Radio';
        requestBody.maxHits = 10000;
        requestBody.offset = 0;
        requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC' AND LastName = 'Testing' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        System.runAs(runningUser){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
        }
        Test.stopTest();
    }
    
    //GST Search Forum
    @isTest static void test_processOmniChannelThemeRequestSearch_Forum() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch();
        request.requestType = 'search';
        request.requestSubType = 'forum';
        request.requestBody = requestBody;
        requestBody.searchText = 'OC Post Title';
        requestBody.maxHits = 10000;
        requestBody.offset = 0;
        requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC' AND LastName = 'Testing' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        System.runAs(runningUser){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
        }
        Test.stopTest();
    }
    
    //GST Search Click
    @isTest static void test_processOmniChannelThemeRequestSearchClick() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick();
        request.requestType = 'other';
        request.requestSubType = 'click_search';
        request.requestBody = requestBody;
        requestBody.searchItemUrl = 'https://acc.customersupport.search.ericsson.net/ExtranetGroup/rest/groupinfo/cpipage?libid=EN/LZN7931010R17D&documentid=97_1551-LZA7016001_1Uen&user=EMP_Internal';
        requestBody.GSTclickURL ='/click?timeOfSearch=1608183585796&stats=%7B%22totalHits%22%3A132375%2C%22searchEngineTimeInMillis%22%3A897%2C%22searchEngineRoundTripTimeInMillis%22%3A903%2C%22searchProcessingTimeInMillis%22%3A906%7D&searchId=e68ff803-b6a2-4901-9110-09917b6b0498&userQuery=%22hits%3D10%26q%3Dradio%26searchapp%3Dsalesforce%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26collapse%210%21deduplication_secondary%3Dsecondary_hits%22&query=%22hits%3D10%26q%3Dradio%26realuser%3DABCDEFGH%26offset%3D0%26searchapp%3Dsalesforce%26q_np_chunks%3D%2522radio%2522%255E1.0%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26q_quoted%3D%2522radio%2522%26collapse%210%21deduplication_secondary%3Dsecondary_hits%26user%3DEMP_INTERNAL%26q_original%3Dradio%22&misc=%7B%7D&hitNo=1&target=https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%253A%252F%252Fmetis-uat3.internal.ericsson.com%252F_layouts%252FEricsson.Metis%252Fhome.aspx%2523Permalink%252FER%252FERSCS127440&doc=%7B%22format%22%3A%22HTML%22%2C%22source%22%3A%22Metis%22%2C%22title%22%3A%22ERSCS127440%20Radio%20Interface%20Failure%2C%20No%20Radio%20Resources%22%2C%22type%22%3A%22knowledge%20object%22%2C%22uri_tree%22%3A%22https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%3A%2F%2Fmetis-uat3.internal.ericsson.com%2F_layouts%2FEricsson.Metis%2Fhome.aspx%23Permalink%2FER%2FERSCS127440%22%7D';
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC' AND LastName = 'Testing' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        System.runAs(runningUser){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            System.assertEquals(GSTSearchConstantsUtility.HASH, OC_ContentControllerSubGSTClickTemp.updateClick(requestBody.searchItemUrl, '', 'External', NULL, requestBody.GSTclickURL));
        }
        Test.stopTest();
    }
    // GST Search Click for Community Plus User

     @isTest static void test_processOmniChannelThemeRequestSearchClickCommunity() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick();
        request.requestType = 'other';
        request.requestSubType = 'click_search';
        request.requestBody = requestBody;
        requestBody.searchItemUrl = 'https://acc.customersupport.search.ericsson.net/ExtranetGroup/rest/groupinfo/cpipage?libid=EN/LZN7931010R17D&documentid=97_1551-LZA7016001_1Uen&user=EMP_Internal';
        requestBody.GSTclickURL ='/click?timeOfSearch=1608183585796&stats=%7B%22totalHits%22%3A132375%2C%22searchEngineTimeInMillis%22%3A897%2C%22searchEngineRoundTripTimeInMillis%22%3A903%2C%22searchProcessingTimeInMillis%22%3A906%7D&searchId=e68ff803-b6a2-4901-9110-09917b6b0498&userQuery=%22hits%3D10%26q%3Dradio%26searchapp%3Dsalesforce%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26collapse%210%21deduplication_secondary%3Dsecondary_hits%22&query=%22hits%3D10%26q%3Dradio%26realuser%3DABCDEFGH%26offset%3D0%26searchapp%3Dsalesforce%26q_np_chunks%3D%2522radio%2522%255E1.0%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26q_quoted%3D%2522radio%2522%26collapse%210%21deduplication_secondary%3Dsecondary_hits%26user%3DEMP_INTERNAL%26q_original%3Dradio%22&misc=%7B%7D&hitNo=1&target=https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%253A%252F%252Fmetis-uat3.internal.ericsson.com%252F_layouts%252FEricsson.Metis%252Fhome.aspx%2523Permalink%252FER%252FERSCS127440&doc=%7B%22format%22%3A%22HTML%22%2C%22source%22%3A%22Metis%22%2C%22title%22%3A%22ERSCS127440%20Radio%20Interface%20Failure%2C%20No%20Radio%20Resources%22%2C%22type%22%3A%22knowledge%20object%22%2C%22uri_tree%22%3A%22https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%3A%2F%2Fmetis-uat3.internal.ericsson.com%2F_layouts%2FEricsson.Metis%2Fhome.aspx%23Permalink%2FER%2FERSCS127440%22%7D';
  
        User testPortal = [Select Id from User where FederationIdentifier = 'OCPARTN' Limit 1];
        
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        System.runAs(testPortal){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            System.assertEquals(GSTSearchConstantsUtility.HASH, OC_ContentControllerSubGSTClickTemp.updateClick(requestBody.searchItemUrl, '', 'External', NULL, requestBody.GSTclickURL));
        }
        Test.stopTest();
    }
    
    //Blanks
    @isTest static void test_processOmniChannelThemeRequest_Blanks() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs();
        
        Test.startTest();        
        request.requestType = 'random';
        try{
            OmniChannelThemeContentControllerSub.processOmniChannelThemeRequest(request);
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        try{
            OmniChannelThemeContentController.processRequest(request);
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        
        request.requestType = 'other';
        request.requestSubType = 'random';
        try{
            OmniChannelThemeContentControllerSub.processOmniChannelThemeRequest(request);
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        try{
            OmniChannelThemeContentController.processRequest(request);
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        Test.stopTest();
    }
    
    //Content Formatters
    @isTest static void test_processOmniChannelThemeSubContentFormatter() {
        Test.startTest();
        System.assertEquals('900 Bytes', OC_ContentControllerSubContentFormatter.BytesToSize(900));
        System.assertEquals('977.44 KB', OC_ContentControllerSubContentFormatter.BytesToSize(1000900));
        System.assertEquals('953.77 MB', OC_ContentControllerSubContentFormatter.BytesToSize(1000100090));
        System.assertEquals('1.86 GB', OC_ContentControllerSubContentFormatter.BytesToSize(2000100090));
        Test.stopTest();
    }
    
    //Ticket Handling
    @isTest static void test_processOmniChannelThemeTicketHandling() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling();
        request.requestType = 'list_tickets';
        request.requestBody = requestBody;
        requestBody.currentPageNumber = 1;
        requestBody.offset = 0;
        requestBody.contextSearchText = 'Test';
        //requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }
    
    //Recent Tickets
    @isTest static void test_processOmniChannelThemeRequestRecentTickets() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling();
        request.requestType = 'recent_tickets';
        request.requestBody = requestBody;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        User runningUserPartner = [SELECT Id FROM User WHERE FirstName = 'OC Partner' AND LastName = 'Testing' LIMIT 1];
        
        Test.startTest();
        System.runAs(runningUser){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
        }
        
        System.runAs(runningUserPartner){
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
        }
        Test.stopTest();
    }
    
    //Ticket Handling without searchtext
    @isTest static void test_processOmniChannelThemeTicketHandlingWithoutSearchText() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling();
        request.requestType = 'list_tickets';
        request.requestBody = requestBody;
        requestBody.currentPageNumber = 1;
        requestBody.offset = 0;
        requestBody.contextSearchText = '';
        //requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }
    
    //Ticket Detail
    @isTest static void test_processOmniChannelThemeTicketDetail() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketDetail requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestTicketDetail();
        Case caseList  = [SELECT Id, Casenumber From Case Limit 1];
        
        request.requestType = 'ticket_detail';
        request.requestBody = requestBody;
        //requestBody.currentPageNumber = 1;
        requestBody.entityId =caseList.id;
        //requestBody.paggination = false;
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }
    
    //Add Comment
   /* @isTest static void test_processOmniChannelThemeTicketAddComment() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestAddTicketComment requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestAddTicketComment();
        Case caseList  = [SELECT Id, Casenumber,OC_TH_Customer_Description__c From Case Limit 1];
        request.requestType = 'other';
        request.requestSubType = 'add_case_comment';
        request.requestBody = requestBody;
        //requestBody.currentPageNumber = 1;
        requestBody.entityId =caseList.Id;
        requestBody.entityData='testing entitidata comments';
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }*/
    
    //Accept the task
    @isTest static void test_processOmniChannelThemeRequestUpdateTaskStatus() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestUpdateTaskStatus requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestUpdateTaskStatus();
        Task remedyTask  = [SELECT Id From Task where Status = 'Answered' Limit 1];
        request.requestType = 'other';
        request.requestSubType = 'update_task_status';
        request.requestBody = requestBody;
        requestBody.entityId =remedyTask.Id;
        requestBody.entityData='Accepted';
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Partner' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }
    
    //Add response to RFI task
    @isTest static void test_processOmniChannelThemeRequestUpdateRFI() {
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest();
        OmniChannelThemeRequestReponseWrappers.OCRequestAddRFIComment requestBody = new OmniChannelThemeRequestReponseWrappers.OCRequestAddRFIComment();
        Task rfitask  = [SELECT Id From Task where Status = 'Requested' Limit 1];
        request.requestType = 'other';
        request.requestSubType = 'add_rfi_response';
        request.requestBody = requestBody;
        requestBody.taskId = rfitask.Id;
        requestBody.newComment = 'Response added';
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Partner' LIMIT 1];
        Test.startTest();
        System.runAs(runningUser){
            
            OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response =  OmniChannelThemeContentController.processRequest(request);
            System.assertEquals(response.requestType, request.requestType);
            
        }
        Test.stopTest();
    }
    
    
    //3.0 U-1706 Forum Accessibility Check
    @isTest static void test_forumAccessibilityCheck() {        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Partner' LIMIT 1];
        FeedItem tempFI = [Select Id from FeedItem WHERE Type = 'QuestionPost' LIMIT 1];
        
        Test.startTest();
        System.runAs(runningUser){
            try{
                FeedItem tempQuestionPost = (FeedItem) OC_TestDataGenerator.createSObject(new FeedItem(), 'OC_TestDataGenerator.FeedItemDefaults', true);
            }
            catch(Exception ex){
                System.assertEquals(true, ex.getMessage().contains(System.Label.OC_Error_Forum_Accessibility));
            }
            
            try{
                FeedComment tempQuestionAnswer = (FeedComment) OC_TestDataGenerator.createSObject(new FeedComment(), 'OC_TestDataGenerator.FeedCommentDefaults');
                tempQuestionAnswer.FeedItemId = tempFI.Id;
                insert tempQuestionAnswer;
            }
            catch(Exception ex){
                System.assertEquals(true, ex.getMessage().contains(System.Label.OC_Error_Forum_Accessibility));
            }            
        }
        Test.stopTest();
    }
    
    @testSetup public static void setup(){
        
        Profile integrationUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Integration User Profile' LIMIT 1];
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User integrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = integrationUserProfile.Id, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        System.runAs(integrationUser){
            Account tempAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.AccountDefaults', true);
            
            Account tempPartnerAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.PartnerAccountDefaults', true);
            tempPartnerAccount.IsPartner = true;
            update tempPartnerAccount;
            
            ContentVersion tempDocument = (ContentVersion) OC_TestDataGenerator.createSObject(new ContentVersion(), 'OC_TestDataGenerator.ContentVersionDefaults', true);
            
            ContentDocumentLink tempDocumentLink = (ContentDocumentLink) OC_TestDataGenerator.createSObject(new ContentDocumentLink(), 'OC_TestDataGenerator.ContentDocumentLinkDefaults');
            tempDocumentLink.LinkedEntityId = tempPartnerAccount.Id;
            tempDocumentLink.ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Title = 'OC Document' Limit 1].Id;
            insert tempDocumentLink;
            
            FeedItem tempQuestionPost = (FeedItem) OC_TestDataGenerator.createSObject(new FeedItem(), 'OC_TestDataGenerator.FeedItemDefaults', true);
            
            FeedComment tempQuestionAnswer = (FeedComment) OC_TestDataGenerator.createSObject(new FeedComment(), 'OC_TestDataGenerator.FeedCommentDefaults');
            tempQuestionAnswer.FeedItemId = tempQuestionPost.Id;
            insert tempQuestionAnswer;
            
            List<Topic> list_topics = new List<Topic>();
            list_topics.add((Topic) OC_TestDataGenerator.createSObject(new Topic(), 'OC_TestDataGenerator.TopicDefaults'));
            list_topics.add((Topic) OC_TestDataGenerator.createSObject(new Topic(), 'OC_TestDataGenerator.Topic2Defaults'));
            list_topics.add((Topic) OC_TestDataGenerator.createSObject(new Topic(), 'OC_TestDataGenerator.Topic3Defaults'));
            insert list_topics;
            
            List<TopicAssignment> list_topicsAssignment = new List<TopicAssignment>();
            list_topicsAssignment.add((TopicAssignment) OC_TestDataGenerator.createSObject(new TopicAssignment(), 'OC_TestDataGenerator.TopicAssignmentDefaults'));
            list_topicsAssignment.add((TopicAssignment) OC_TestDataGenerator.createSObject(new TopicAssignment(), 'OC_TestDataGenerator.TopicAssignmentDefaults'));
            list_topicsAssignment.add((TopicAssignment) OC_TestDataGenerator.createSObject(new TopicAssignment(), 'OC_TestDataGenerator.TopicAssignmentDefaults'));
            
            for(Topic temp :list_topics){
                list_topicsAssignment.get(list_topics.indexOf(temp)).TopicId = temp.Id;
                list_topicsAssignment.get(list_topics.indexOf(temp)).EntityId = tempQuestionPost.Id;
            }
            
            insert list_topicsAssignment;
            
            OC_TestDataGenerator.insertCustomSettingsData();
            
            Profile serviceUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Ericsson Service' LIMIT 1];
            User serviceUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = serviceUserProfile.Id, FederationIdentifier = 'OCSERVC', isActive = True), 'OC_TestDataGenerator.UserDefaults', true);
            
            Profile communityPortalUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Customer Community Plus Custom User' LIMIT 1];
            User communityUser = (User) OC_TestDataGenerator.createSObject(new User(), 'OC_TestDataGenerator.PartnerUserDefaults');
            Contact tempPartnerContact = (Contact) OC_TestDataGenerator.createSObject(new Contact(AccountId = tempPartnerAccount.Id, Email = communityUser.Email), 'OC_TestDataGenerator.PartnerContactDefaults', true);
            
            communityUser.ContactId = tempPartnerContact.Id;
            communityUser.ProfileId = communityPortalUserProfile.Id;
            communityUser.FederationIdentifier = 'OCPARTN';
            communityUser.isActive = True;
            
            OC_TestDataGenerator.createSObject(communityUser, true);
            
            //casecreationtest
            
            List<Case> caseList = new List<Case>();
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Task> taskList = new List<Task>();
            
            
            Account accountToInsert = (Account)OC_TestDataGenerator.createSObject(new Account());
            accountToInsert.CNS_Queue__c = 'Test';
            accountToInsert.Account_Type__c = 'Service';
            
            accList.add(accountToInsert);
            
            insert accList;
            
            Contact contactToInsert = (Contact)OC_TestDataGenerator.createSObject(new Contact());
            contactToInsert.AccountId = accList[0].Id;
            conList.add(contactToInsert);
            
            insert conList;
            
            Case caseToInsert = (Case)OC_TestDataGenerator.createSObject(new Case());
            caseToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId(); 
            caseToInsert.OC_TH_Customer_Description__c = 'Test Description ' ;
            caseToInsert.ContactId = contactToInsert.Id;
            caseList.add(caseToInsert);
            
            insert caseList;
            ContentDocumentLink tempCaseLink = (ContentDocumentLink) OC_TestDataGenerator.createSObject(new ContentDocumentLink(), 'OC_TestDataGenerator.ContentDocumentLinkDefaults');
            tempCaseLink.LinkedEntityId = caseList[0].Id;
            tempCaseLink.ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Title = 'OC Document' Limit 1].Id;
            insert tempCaseLink;
            
            Case caseToInsert2 = (Case)OC_TestDataGenerator.createSObject(new Case());
            caseToInsert2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId(); 
            caseToInsert2.OC_TH_Customer_Description__c = 'Test Description ' ;
            caseToInsert2.ContactId = tempPartnerContact.Id;
            caseToInsert2.AccountId = tempPartnerAccount.Id;
            insert caseToInsert2;
            
            Task taskToInsert = (Task)OC_TestDataGenerator.createSObject(new Task());
            taskToInsert.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Remedy').getRecordTypeId();
			taskToInsert.WhatId = caseToInsert2.Id;
			taskToInsert.Description = 'First Remedy';
			taskToInsert.Status = 'Answered';
            taskToInsert.OwnerId = serviceUser.Id;
            taskToInsert.WhoId = tempPartnerContact.Id;
            taskToInsert.IsVisibleInSelfService = true;
			taskList.add(taskToInsert);

			Task taskToInsert2 = (Task)OC_TestDataGenerator.createSObject(new Task());
            taskToInsert2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Request for Info').getRecordTypeId();
			taskToInsert2.WhatId = caseToInsert2.Id;
			taskToInsert2.Description = 'Request for Info';
			taskToInsert2.Status = 'Requested';
            taskToInsert2.OwnerId = serviceUser.Id;
            taskToInsert2.WhoId = tempPartnerContact.Id;
            taskToInsert2.IsVisibleInSelfService = true;
			taskList.add(taskToInsert2);

			insert taskList;       
        }
        
        
        
    }
}