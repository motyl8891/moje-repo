/**
* @File Name          : CustomSearchControllerTest.cls
* @Description        : 
* @Author             : Ankit Jain
* @Group              : 
* @Last Modified By   : Ankit Jain
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-18           Ankit Jain               Initial Version
* 2.0    2020-03-19			 Rohit Gaba				  Params correction in dependent methods
* 3.0    2020-04-24          Nikita Sachdeva          U-1663 Adding Addititonal Header Parameter
* 4.0    2020-05-22			 Rohit Gaba				  Inserted required GST_API_Details__c records and optimized insertion of GST_API_Details__c records.
* 5.0    2021-02-15          Sandeep Singh            U-2473  Added additional parameter for GST static date filter.
* 6.0    2021-02-22          Subashini Arulalan       U-2474  Added additional parameter for GST format filter.
* 7.0    2021-02-24          Sandeep Singh            U-2469 U-2473  Added additional parameter to the 'SeachforIds' method & try catch block.
* 8.0    2021-03-15          Sandeep Singh            U-2472 Added additional parameter as null for GST product filter in searchForIds method.
* 9.0    2021-06-08          Sandeep Singh            U-2808  Added additional parameter for GST SearchHit Product Version filter in searchForIds method.
**/
@isTest
private without sharing class CustomSearchControllerTest {
    @testSetup
    public static void setup() {
        try {
            Profile sysAdmin = [
                SELECT Id
                FROM Profile
                WHERE Name =: 'Ericsson Service'
                LIMIT 1
            ];
            User urs1 = new User(
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
            insert urs1;
            Product2 prd1 = new Product2(
                Platform__c = 'plt',
                Node_Type__c = 'ntp',
                Product_Model__c = 'prdmdl',
                Product_Code_Number__c = 'pdcd',
                Name = 'prdname',
                CurrencyIsoCode = 'SEK',
                SW_Release__c = 'sw',
                Technology__c = 'T',
                RecordtypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Node Type').getRecordTypeId()
            );
            insert prd1;
            //2020-05-22  Rohit Gaba Inserted required GST_API_Details__c records and optimized insertion of GST_API_Details__c records.
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
                new GST_API_Details__c(Name = 'Max_Search_Results', Value__c = '5')
            );
            gstAPICustomSettings.add(
                new GST_API_Details__c(
                    Name = 'POST_URL',
                    Value__c = 'https://test.salesforce.com/customer/s/question/'
                )
            );
            insert gstAPICustomSettings;
            FeedItem feed = new FeedItem();
            feed.Title = 'legal Test';
            feed.Body = 'legal Test';
            feed.parentID = urs1.Id;
            feed.Type = 'QuestionPost';
            insert feed;
            Account ac = (Account) OC_TestDataGenerator.createSObject(
                new Account(),
                false
            );
            User testUser = (User) OC_TestDataGenerator.createSObject(
                new User(
                    ProfileId = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'Integration User Profile'
                        LIMIT 1
                    ]
                    .Id,
                    UserName = 'ericsson111@test.com' + System.currentTimeMillis()
                ),
                true
            );
            System.runAs(testUser) {
                insert ac;
            }
            list<Contact> Contact = new List<Contact>();
            Contact con = new Contact(
                AccountId = ac.id,
                Firstname = 'test123',
                Lastname = 'testlastname',
                Email = 'testemail@gmail.com',
                MailingCountry = 'Cuba'
            );
            Contact.add(con);
            insert Contact;
            Asset a = new Asset(
                Name = 'test',
                AccountId = ac.id,
                Product2Id = prd1.Id,
                RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Node Type').getRecordTypeId()
            );
            system.runAs(testUser){
             insert a;
            }
        } catch (Exception e) {
            EventLog.createLogFuture(
                Json.serialize(
                    new EventLog.Error(
                        'CustomSearchControllerTest',
                        'setup',
                        'CustomSearchControllerTest',
                        true,
                        e
                    )
                )
            );
        }
    }
    @isTest
    static void testCallout1() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        List<CustomSearchController.SearchResultWrapper> searchResultWrapperList;
        System.runAs(usr) {
            Product2 prd = [SELECT id FROM Product2 LIMIT 1];
            searchResultWrapperList = CustomSearchController.searchForIds(
                'Radio',
                1,
                0,
                false,
                prd.id,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
            try{
                searchResultWrapperList=CustomSearchController.searchForIds('(',1,0,true,prd.id,'External',null,'Metis','today',null,null,null,null,null,null,null,null,null);
            } catch(Exception e) {
            }
        }
        Test.stopTest();
        System.assertEquals(true, searchResultWrapperList.size() > 0);
    }
    @isTest
    static void testCallout2() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        List<CustomSearchController.SearchResultWrapper> searchResultWrapperList;
        System.runAs(usr) {
            searchResultWrapperList = CustomSearchController.searchForIds(
                '',
                1,
                0,
                false,
                'pdr',
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
        }
        Test.stopTest();
        System.assertEquals(true, searchResultWrapperList.size() == 0);
    }
    @isTest
    static void testCallout3() {
        Test.startTest();
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        List<CustomSearchController.UniqueProductWrapper> uniqueProductWrapperList;
        System.runAs(usr) {
            uniqueProductWrapperList = CustomSearchController.fetchUniqueProduct();
        }
        Test.stopTest();
        System.assertEquals(true, uniqueProductWrapperList.size() == 1);
    }
    @isTest
    static void testCallout4() {
        //Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        FeedItem fid = [
            SELECT id, Title, Body, parentID, type
            FROM FeedItem
            LIMIT 1
        ];
        Id[] fixedSearchResults = new List<Id>(1);
        fixedSearchResults[0] = fid.id;
        Test.setFixedSearchResults(fixedSearchResults);
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        List<CustomSearchController.SearchResultWrapper> searchResultWrapperList;
        System.runAs(usr) {
            searchResultWrapperList = CustomSearchController.searchForForum('Test');
        }
        Test.stopTest();
        System.assertEquals(false, searchResultWrapperList.size() == 0);
    }
    @isTest
    static void testCallout5() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        Product2 pr = [SELECT id FROM Product2 LIMIT 1];
        List<CustomSearchController.SearchResultWrapper> searchResultWrapperList;
        System.runAs(usr) {
            searchResultWrapperList = CustomSearchController.searchForIds(
                'Test',
                10,
                1,
                false,
                pr.id,
                null,
                null,
                'Metis',
                'today',
                'HTML',
                'AXE',
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
        }
        Test.stopTest();
    }
    @isTest
    static void testCallout6() {
        Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        Test.startTest();
        User usr = [
            SELECT id
            FROM user
            WHERE email = 'access.tester.invalid@ericsson.com'
            LIMIT 1
        ];
        Product2 pr = [SELECT id,Name FROM Product2 LIMIT 1];
        List<CustomSearchController.SearchResultWrapper> searchResultWrapperList;
        System.runAs(usr) {
            searchResultWrapperList = CustomSearchController.searchForIds(
                'Test',
                10,
                1,
                false,
                pr.id,
                null,
                null,
                'Product Information',
                'today',
                'HTML',
                pr.Name,
                new List<String>{pr.Name},
                'TEMP',
                'Active',
                'test',
                'wc1',
                'wc2',
                 null
            );
        }
        Test.stopTest();
    }
}