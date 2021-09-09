/**
* @File Name          : CustomSearchResultsListControllerTest.cls
* @Description        : U-1278 (Test class for CustomSearchResultsListController)
* @Author             : Ankit Jain
* @Group              : 
* @Last Modified By   : Ankit Jain
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-18           Ankit Jain               Initial Version
         2020-03-19			 Rohit Gaba				  Params correction in dependent methods and Search Result correction for Internal User
         2020-03-30			 Rohit Gaba				  Inserted required GST_API_Details__c records and optimized insertion of GST_API_Details__c records.
         2020-05-22			 Rohit Gaba				  Inserted required GST_API_Details__c records and optimized insertion of GST_API_Details__c records.
         2021-02-22          Sandeep Singh            Added additional parameters to SearchResultWrapper as apart of GST source filter changes.
         2021-02-24          Subashini Arulalan       Added click URLs for test data.
         2021-03-18          Subashini Arulalan       U-2477- Added additional parameters for SearchResultWrapper
         2021-04-16          Sandeep Singh            U-2478 Added additional parameters for SearchHitfilter to SearchResultWrapper
**/
@isTest
private class CustomSearchResultsListControllerTest {
    @testSetup
    public static void setup() {
        Profile sysAdmin = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Ericsson Service'
            LIMIT 1
        ];
        User urs = new User(
            Email = 'access.tester.invalid@ericsson.com',
            Alias = 'Access',
            Username = 'access.tester.invalid@ericsson.com',
            LastName = 'Tester',
            FirstName = 'Test',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = sysAdmin.Id,
            LanguageLocaleKey = 'en_US',
            FederationIdentifier = 'fId1'
        );
        insert urs;
        
        //2020-03-31  Rohit Gaba Inserted required GST_API_Details__c records and optimized insertion of GST_API_Details__c records.
        List<GST_API_Details__c> gstAPICustomSettings = new List<GST_API_Details__c>();
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Base_URL',
                Value__c = 'https://acc.customersupport.search.ericsson.net/rest/apps/gst/searchers/omnichannel'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'Default_Hit', Value__c = '10')
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'External_Profile', Value__c = 'dummy')
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Facet_source',
                Value__c = 'Product+Information'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Internal_User_Signum',
                Value__c = 'EMP_INTERNAL'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Token',
                Value__c = '6kxtrJP60cgx0smZdyc7GjLBFIb'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'HeaderToken',
                Value__c = 'RjbzzRpd9fM764hQ6zrzt9bt'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'Click_Base_URL_PWD', Value__c = 'cpi')
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'Click_Base_URL_USR', Value__c = 'cpi')
        );
        //2020-05-22  Rohit Gaba Inserted required GST_API_Details__c records
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'Referrer_Header', Value__c = 'referrer')
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Referrer_Community',
                Value__c = 'https://test.salesforce.com'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Referrer_Console',
                Value__c = 'https://test.salesforce.com'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Cpi_Doc_Number_Param',
                Value__c = 'collapse!0!cpi_document_number'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(
                Name = 'Cpi_Doc_Number_Param_Value',
                Value__c = 'secondary_hits'
            )
        );
        gstAPICustomSettings.add(
            new GST_API_Details__c(Name = 'Max_Search_Results', Value__c = '10000')
        );
        
        insert gstAPICustomSettings;
    }
    
    @isTest
    static void testCallout1() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            '/click?timeOfSearch=1608183585796&stats=%7B%22totalHits%22%3A132375%2C%22searchEngineTimeInMillis%22%3A897%2C%22searchEngineRoundTripTimeInMillis%22%3A903%2C%22searchProcessingTimeInMillis%22%3A906%7D&searchId=e68ff803-b6a2-4901-9110-09917b6b0498&userQuery=%22hits%3D10%26q%3Dradio%26searchapp%3Dsalesforce%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26collapse%210%21deduplication_secondary%3Dsecondary_hits%22&query=%22hits%3D10%26q%3Dradio%26realuser%3DABCDEFGH%26offset%3D0%26searchapp%3Dsalesforce%26q_np_chunks%3D%2522radio%2522%255E1.0%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26q_quoted%3D%2522radio%2522%26collapse%210%21deduplication_secondary%3Dsecondary_hits%26user%3DEMP_INTERNAL%26q_original%3Dradio%22&misc=%7B%7D&hitNo=1&target=https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%253A%252F%252Fmetis-uat3.internal.ericsson.com%252F_layouts%252FEricsson.Metis%252Fhome.aspx%2523Permalink%252FER%252FERSCS127440&doc=%7B%22format%22%3A%22HTML%22%2C%22source%22%3A%22Metis%22%2C%22title%22%3A%22ERSCS127440%20Radio%20Interface%20Failure%2C%20No%20Radio%20Resources%22%2C%22type%22%3A%22knowledge%20object%22%2C%22uri_tree%22%3A%22https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%3A%2F%2Fmetis-uat3.internal.ericsson.com%2F_layouts%2FEricsson.Metis%2Fhome.aspx%23Permalink%2FER%2FERSCS127440%22%7D',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateClick(
                JSON.serialize(obj21),
                null,
                null
            );
        }
        Test.stopTest();
    }
    @isTest
    static void testCallout2() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            'test data7',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateLikeClick(
                JSON.serialize(obj21),
                true
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('Success'));
    }
    @isTest
    static void testCallout3() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        GST_API_Details__c cs1 = new GST_API_Details__c();
        cs1.Name = 'Base_URL';
        cs1.Value__c = 'https://acc.customersupport.search.ericsson.net/rest/apps/gst/searchers/omnichannel';
        insert cs1;
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            '/click?timeOfSearch=1608183585796&stats=%7B%22totalHits%22%3A132375%2C%22searchEngineTimeInMillis%22%3A897%2C%22searchEngineRoundTripTimeInMillis%22%3A903%2C%22searchProcessingTimeInMillis%22%3A906%7D&searchId=e68ff803-b6a2-4901-9110-09917b6b0498&userQuery=%22hits%3D10%26q%3Dradio%26searchapp%3Dsalesforce%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26collapse%210%21deduplication_secondary%3Dsecondary_hits%22&query=%22hits%3D10%26q%3Dradio%26realuser%3DABCDEFGH%26offset%3D0%26searchapp%3Dsalesforce%26q_np_chunks%3D%2522radio%2522%255E1.0%26sessionid%3D00D1w0000000ZNS%2521ARgAQKk1tcgn6fsTnGSf9oNZxzN4zuekkfnH.xdxMQOIjxcxcXwDxN7uIZJLwQsssmaa8BFwlXRuIkC5QqwqTybb_41AE5Jz%26q_quoted%3D%2522radio%2522%26collapse%210%21deduplication_secondary%3Dsecondary_hits%26user%3DEMP_INTERNAL%26q_original%3Dradio%22&misc=%7B%7D&hitNo=1&target=https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%253A%252F%252Fmetis-uat3.internal.ericsson.com%252F_layouts%252FEricsson.Metis%252Fhome.aspx%2523Permalink%252FER%252FERSCS127440&doc=%7B%22format%22%3A%22HTML%22%2C%22source%22%3A%22Metis%22%2C%22title%22%3A%22ERSCS127440%20Radio%20Interface%20Failure%2C%20No%20Radio%20Resources%22%2C%22type%22%3A%22knowledge%20object%22%2C%22uri_tree%22%3A%22https%3A%2F%2Facc.customersupport.search.ericsson.net%2FExtranetGroup%2Frest%2Fgroupinfo%2Fgetpagelink%3Furl%3Dhttps%3A%2F%2Fmetis-uat3.internal.ericsson.com%2F_layouts%2FEricsson.Metis%2Fhome.aspx%23Permalink%2FER%2FERSCS127440%22%7D',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateClick(
                JSON.serialize(obj21),
                null,
                null
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('#'));
    }
    @isTest
    static void testCallout4() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        GST_API_Details__c cs1 = new GST_API_Details__c();
        cs1.Name = 'Base_URL';
        cs1.Value__c = 'https://acc.customersupport.search.ericsson.net/rest/apps/gst/searchers/omnichannel';
        insert cs1;
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            'test data7',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateLikeClick(
                JSON.serialize(obj21),
                true
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('Failed'));
    }
    @isTest
    static void testCallout5() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            'dummy',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateLikeClick(
                JSON.serialize(obj21),
                true
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('Failed'));
    }
    @isTest
    static void testCallout6() {
        //Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper(
            'test data1',
            'test data2',
            'test data3',
            'test data4',
            'test data5',
            'test data6',
            'test data7',
            0,
            'test data8',
            'test data9',
             null,
            'test data10',
            'test data11',
            'test data12',
            'test data13',
            'test data14',
            '2',
            '3',
            null,
            null
        );
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateForumClick(
                JSON.serialize(obj21)
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('test data5'));
    }
    
    @isTest
    static void testCallout7() {
        //Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        //CustomSearchController.SearchResultWrapper obj21 = new CustomSearchController.SearchResultWrapper('test data1','test data2','test data3','test data4','test data5','test data6','test data7',0,'test data8');
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        String result;
        System.runAs(usr) {
            result = CustomSearchResultsListController.updateForumClick(
                'Test String'
            );
        }
        Test.stopTest();
        System.assertEquals(true, result.equals('#'));
    }
    
    @isTest
    public static void getServiceConsolePlaceholders(){
        Map<String, OC_Console_Placeholder__c> placeholders = CustomSearchResultsListController.getServiceConsolePlaceholders();
        System.assertNotEquals(null, placeholders);
    }
}