/**
 * @File Name          : OC_AN_ExternalAutomationSchedulerTest
 * @Description        : This test class for OC_AN_ExternalAutomationScheduler
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/

@Istest
public class OC_AN_ExternalAutomationSchedulerTest{
    
    @testSetup
    public static void setup() {
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        System.runAs(testuser){
            OC_TestDataGenerator.insertCustomSettingsData();
            
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            bulletinToInsert.OC_AN_Body_Of_Bulletin__c = 'Test xyz';
            bulletinToInsert.OC_AN_MC_Email_Id__c='1123';
            bulletinToInsert.OC_AN_Delay__c = 2;
            listOfBulletin.add(bulletinToInsert);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }  
        }   
    }
    public static testMethod void testcallouts()
    {
        Map<String, OC_AN_MockBulletinApproved.Response> responses = new Map<String, OC_AN_MockBulletinApproved.Response>();
        
        /*@Description :accessToken, you need URL (Key) then a Response object with the data, status code and if it should throw a exception or not.*/
        responses.put('callout:SFMC/v2/token',
        new OC_AN_MockBulletinApproved.Response('{"access_token":"test"}',
                                            200,
                                            false)); 
        /*@Description :Email*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/asset/v1/content/assets',
                      new OC_AN_MockBulletinApproved.Response('{"id": 3158,"customerKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","objectID": "9c03a728-291a-4a59-90ca-d68ea5b409f1","contentType": "application/vnd.etmc.email.Message; kind=paste","assetType": {"id": 208,"name": "htmlemail","displayName": "HTML Email"},"name": "Test73_a0g1l000002qcDEAAY","owner": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"createdDate": "2021-05-17T06:18:05.47-06:00","createdBy": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"modifiedDate": "2021-05-17T06:18:05.47-06:00","modifiedBy": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"enterpriseId": 510003459,"memberId": 510003459,"status": {"id": 1,"name": "Draft"},"thumbnail": {"thumbnailUrl": "thumbnail"},"category": {"id": 691,"name": "Content Builder","parentId": 0},"views": {"text": {"thumbnail": {},"modelVersion": 2},"subjectline": {"thumbnail": {},"content": "Test73","modelVersion": 2},"preheader": {"thumbnail": {},"modelVersion": 2},"html": {"thumbnail": {},"content": "content","modelVersion": 2}},"availableViews": ["text","subjectline","preheader","html"],"channels": {"web": false,"email": true},"data": {"email": {"options": {"characterEncoding": "us-ascii"},"legacy": {"legacyId": 1233,"legacyKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","legacyType": "email","legacyCategoryId": 584}}},"legacyData": {"legacyId": 1233,"legacyKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","legacyType": "email","legacyCategoryId": 584},"modelVersion": 2}',
                                                              200,
                                                              false));
        /*@Description :DataExtension*/       
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx',
                      new OC_AN_MockBulletinApproved.Response('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:e03e9a28-37a0-4b5a-910c-d0b37b54311c</wsa:MessageID><wsa:RelatesTo>urn:uuid:b2381ead-5d8a-47d5-98ab-662d6c340131</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-5ec952cd-9f9d-46d1-af10-8a4a0f35f2bc"><wsu:Created>2021-05-17T12:18:06Z</wsu:Created><wsu:Expires>2021-05-17T12:23:06Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>Data Extension created.</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>6dbcc8e8-09b7-eb11-b836-f40343c98e90</NewObjectID><Object xsi:type="DataExtension"><PartnerKey xsi:nil="true" /><ObjectID>6dbcc8e8-09b7-eb11-b836-f40343c98e90</ObjectID><CustomerKey>InternalUser_a0g1l000002qcDEAAY</CustomerKey><Name>InternalUser_a0g1l000002qcDEAAY</Name><IsSendable>true</IsSendable><SendableDataExtensionField><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Email</CustomerKey><Name>Email</Name><FieldType>EmailAddress</FieldType></SendableDataExtensionField><SendableSubscriberField><Name>Subscriber Key</Name><Value>Email</Value></SendableSubscriberField><Fields><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Email</CustomerKey><Name>Email</Name><IsRequired>true</IsRequired><IsPrimaryKey>true</IsPrimaryKey><FieldType>EmailAddress</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>First_Name</CustomerKey><Name>First_Name</Name><MaxLength>100</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Last_Name</CustomerKey><Name>Last_Name</Name><MaxLength>100</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Name</CustomerKey><Name>Name</Name><MaxLength>200</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>User_Id</CustomerKey><Name>User_Id</Name><MaxLength>18</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Is_Internal</CustomerKey><Name>Is_Internal</Name><DefaultValue>True</DefaultValue><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Boolean</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Bulletin_Id</CustomerKey><Name>Bulletin_Id</Name><MaxLength>18</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Account__c</CustomerKey><Name>Account__c</Name><MaxLength>50</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Contact__c</CustomerKey><Name>Contact__c</Name><MaxLength>50</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Email__c</CustomerKey><Name>Email__c</Name><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Boolean</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>BulletinName</CustomerKey><Name>BulletinName</Name><MaxLength>50</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>Product__c</CustomerKey><Name>Product__c</Name><MaxLength>50</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field><Field><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>User__c</CustomerKey><Name>User__c</Name><MaxLength>50</MaxLength><IsRequired>false</IsRequired><IsPrimaryKey>false</IsPrimaryKey><FieldType>Text</FieldType></Field></Fields><CategoryID>4471</CategoryID></Object></Results><RequestID>87934af7-2706-4c96-980d-de5c6442bdb7</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>',
                                                              200,
                                                              false));
        /*@Description :Person*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/hub/v1/dataevents/key:0D76B90B-6230-4004-A3E5-B35E6D9DEAB5/rowset',
                      new OC_AN_MockBulletinApproved.Response('[{"keys":{"emailWithBulletinId":"varun.rajpoot@ericsson.coma0g1l000002qcDEAAY"},"values":{"user_Id":"0051l000004JhpSAAS","name":"Varun Rajpoot","last_Name":"Rajpoot","first_Name":"Varun","email":"varun.rajpoot@ericsson.com","bulletin_Id":"a0g1l000002qcDEAAY"}},{"keys":{"emailWithBulletinId":"rehan.ahmad@ibm.coma0g1l000002qcDEAAY"},"values":{"user_Id":"0051l000004K4f9AAC","name":"Rehan Ahmad","last_Name":"Ahmad","first_Name":"Rehan","email":"rehan.ahmad@ibm.com","bulletin_Id":"a0g1l000002qcDEAAY"}},{"keys":{"emailWithBulletinId":"abdulk35@in.ibm.coma0g1l000002qcDEAAY"},"values":{"user_Id":"0051l000004KA5JAAW","name":"Abdul Shaik","last_Name":"Shaik","first_Name":"Abdul","email":"abdulk35@in.ibm.com","bulletin_Id":"a0g1l000002qcDEAAY"}},{"keys":{"emailWithBulletinId":"b.pallavi@ibm.coma0g1l000002qcDEAAY"},"values":{"user_Id":"0051l000004KIY9AAO","name":"Pallavi B","last_Name":"B","first_Name":"Pallavi","email":"b.pallavi@ibm.com","bulletin_Id":"a0g1l000002qcDEAAY"}},{"keys":{"emailWithBulletinId":"krishna.yarlagadda@in.ibm.coma0g1l000002qcDEAAY"},"values":{"user_Id":"0051l000004YxTFAA0","name":"Krishna Yarlagadda","last_Name":"Yarlagadda","first_Name":"Krishna","email":"krishna.yarlagadda@in.ibm.com","bulletin_Id":"a0g1l000002qcDEAAY"}}]',
                                                              200,
                                                              false));
        /*@Description :Query, please note that its the same URL as on row 46 (Create DataExtension)*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx',
                      new OC_AN_MockBulletinApproved.Response('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:03c9394e-f0a7-4c75-b3e7-6c6538b9cdaf</wsa:MessageID><wsa:RelatesTo>urn:uuid:0acc7661-96cc-4923-8cbf-f051bb181cd7</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-f9f0294c-f47f-4328-bf14-cff12c368c4d"><wsu:Created>2021-05-17T12:18:06Z</wsu:Created><wsu:Expires>2021-05-17T12:23:06Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>QueryDefinition created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>5fe4d1d9-dc61-40ad-a3cf-0348505af3db</NewObjectID><Object xsi:type="QueryDefinition"><PartnerKey xsi:nil="true" /><ObjectID>5fe4d1d9-dc61-40ad-a3cf-0348505af3db</ObjectID><CustomerKey>ID_step1_a0g1l000002qcDEAAY</CustomerKey><Name>ID_step1_a0g1l000002qcDEAAY</Name><QueryText>Select US.Account__c,US.Contact__c,Us.Email__c,US.Name as BulletinName,US.Product__c,US.User__c, A.Email,A.First_Name,A.Last_Name,A.User_Id,A.Is_Internal,A.Bulletin_Id from ID_AllUsersdata A inner join 	OC_AN_Bulletin_Account_Product__c_Salesforce B ON A.Bulletin_Id = B.OC_AN_Bulletin__c and B.RecordTypeId = \'0121l000000DgjnAAC\' inner join OC_AN_User_Preferences__c_Salesforce US ON A.User_Id = US.User__c and B.OC_AN_Product__c = US.Product__c where Us.Email__c =\'True\' and A.Bulletin_Id=\'a0g1l000002qcDEAAY\'</QueryText><TargetType>DE</TargetType><DataExtensionTarget><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>InternalUser_a0g1l000002qcDEAAY</CustomerKey><Name>InternalUser_a0g1l000002qcDEAAY</Name></DataExtensionTarget><TargetUpdateType>Overwrite</TargetUpdateType></Object></Results><RequestID>1d8802e8-ff17-44e3-be16-462b2dddc34a</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>',
                                                              200,
                                                              false));
        /*@Description :Journey, please note that its the same URL as above*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/interaction/v1/interactions',
                      new OC_AN_MockBulletinApproved.Response('{"id":"e5f843c8-eaa2-4745-8699-954849a9f0ec","key":"ID_Journey_a0g1l000002qcDEAAY","name":"ID_Journey_a0g1l000002qcDEAAY","lastPublishedDate":"0001-01-01T00:00:00","version":1,"workflowApiVersion":1.0,"createdDate":"2021-05-17T06:18:08.22","modifiedDate":"2021-05-17T06:18:08.22","activities":[{"id":"6239169a-5071-40ba-9a94-d675395bd7b1","key":"EMAILV2-1","name":"Test73_a0g1l000002qcDEAAY","type":"EMAILV2","outcomes":[{"key":"409a390b-40c6-4942-8039-3862e50dc124","next":"WAITBYDURATION-1","arguments":{},"metaData":{}}],"arguments":{},"configurationArguments":{"triggeredSend":{"senderProfileId":"61a06939-8176-eb11-b82c-f40343c996b0","sendClassificationId":"ef074fed-3564-eb11-b82f-f40343c954f0","priority":4,"isTrackingClicks":true,"isStoppedOnJobError":false,"isSendLogging":true,"isSalesforceTracking":true,"isMultipart":true,"emailSubject":"Test73_a0g1l000002qcDEAAY","emailId":1233,"dynamicEmailSubject":"Test73_a0g1l000002qcDEAAY","deliveryProfileId":"ee074fed-3564-eb11-b82f-f40343c954f0","autoUpdateSubscribers":true,"autoAddSubscribers":true},"isModified":true,"applicationExtensionKey":"jb-email-activity"},"metaData":{"isConfigured":true}},{"id":"294af76b-cb99-48ce-b2ef-9b749a8d8e20","key":"WAITBYDURATION-1","name":"1 minute","type":"WAIT","outcomes":[{"arguments":{},"metaData":{}}],"arguments":{},"configurationArguments":{"waitUnit":"MINUTES","waitDuration":1,"timeZone":"India Standard Time","specifiedTime":"00:00"},"metaData":{}}],"triggers":[{"id":"0ff7d7c5-1fc2-406c-9008-4f7275899895","key":"TRIGGER","name":"TRIGGER","type":"EmailAudience","outcomes":[],"arguments":{},"configurationArguments":{},"metaData":{"title":"Data Extension","sourceInteractionId":"00000000-0000-0000-0000-000000000000","scheduleState":"No Schedule","iconUrl":"/images/icon-data-extension.svg","eventDefinitionKey":"EmailAudience-a0g1l000002qcDEAAY","eventDefinitionId":"1ee3f540-853a-4feb-b6cc-361e14e286b1","entrySourceGroupConfigUrl":"jb:///data/entry/audience/entrysourcegroupconfig.json","configurationRequired":false,"chainType":"None","category":"Audience"}}],"goals":[],"exits":[],"entryMode":"MultipleEntries","definitionType":"Multistep","defaults":{"email":["{{Event.EmailAudience-a0g1l000002qcDEAAY.Email}}"],"properties":{}},"metaData":{},"executionMode":"Production","categoryId":687,"status":"Draft","definitionId":"e5f843c8-eaa2-4745-8699-954849a9f0ec","scheduledStatus":"Draft"}',
                                                              200,
                                                              false));  
        /*@Description :Publish*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/interaction/v1/interactions/publishAsync/e5f843c8-eaa2-4745-8699-954849a9f0ec?versionNumber=1',
                      new OC_AN_MockBulletinApproved.Response('{"statusUrl":"/interaction/v1/interactions/publishStatus/430d25ee-52ed-4d0c-997d-405c2536062d","statusId":"430d25ee-52ed-4d0c-997d-405c2536062d"}',
                                                              200,
                                                              false));  
        /*@Description :Event definition*/
        responses.put('https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/interaction/v1/eventDefinitions',
                      new OC_AN_MockBulletinApproved.Response('{"id":"1ee3f540-853a-4feb-b6cc-361e14e286b1","type":"EmailAudience","name":"a0g1l000002qcDEAAY","createdDate":"0001-01-01T00:00:00","createdBy":0,"modifiedDate":"0001-01-01T00:00:00","modifiedBy":0,"mode":"Production","eventDefinitionKey":"EmailAudience-a0g1l000002qcDEAAY","dataExtensionId":"6dbcc8e8-09b7-eb11-b836-f40343c98e90","filterDefinitionId":"00000000-0000-0000-0000-000000000000","iconUrl":"/images/icon-data-extension.svg","arguments":{"serializedObjectType":"EmailAudience","eventDefinitionId":"1ee3f540-853a-4feb-b6cc-361e14e286b1","eventDefinitionKey":"EmailAudience-a0g1l000002qcDEAAY","dataExtensionId":"6dbcc8e8-09b7-eb11-b836-f40343c98e90"},"metaData":{},"interactionCount":0,"isVisibleInPicker":false,"category":"Audience","publishedInteractionCount":0,"automationId":"6c8a792b-e6ac-4a24-a3b7-4bc1c3fda869"}',
                                                              200,
                                                              false));              
        Test.setMock(HttpCalloutMock.class, new OC_AN_MockBulletinApproved(responses));
        
        OC_AN_Bulletin__c bulletinId = new OC_AN_Bulletin__c();
        bulletinId = [select Id from OC_AN_Bulletin__c where Name='Test Bulletin'];
        
        Test.startTest();
        Map<String, String>  testList = new Map<String, String> ();
        testList.put('BulletinId',bulletinId.id);
        OC_AN_ExternalAutomationScheduler ExternalAutomation = new OC_AN_ExternalAutomationScheduler(testList);
        System.assertNotEquals(null,responses,'The callout returned a null response.');
        Test.stopTest();
        
        
    }
    
}