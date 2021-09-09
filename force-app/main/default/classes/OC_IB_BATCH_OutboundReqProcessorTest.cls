/**
* @File Name          : OC_IB_BATCH_OutboundReqProcessorTest
* @Description        : Test class for OC_IB_BATCH_OutboundReqProcessor
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-05-20                 IBM                   U-2816 & U-2815 Product MR code coverage
**/
@isTest
public Without Sharing class OC_IB_BATCH_OutboundReqProcessorTest{
    @testsetup 
    static void setup(){
        
        List<User> userList = new List<User>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User migrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = migrationUserProfileId, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        System.runAs(migrationUser){    
            AccessSettings__c cs = new AccessSettings__c();
            cs.MigrationUserProfileFlag__c=true;
            insert cs;
            
            List<Account> accList=new List<Account>();
            accList = TestDataGenerator.createSObjectList(new Account(),1); 
            Id serviceAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();
            
            accList[0].Name='Test Account Sales';
            accList[0].SAP_S2P_ID_Number__c=507952;
            insert accList;
            
            Account acc=new Account();
            acc.Name='Test Account Service';
            acc.Account_Type__c='Service';
            acc.ParentId=accList[0].id;
            acc.RecordtypeId=serviceAccRecType;
            acc.SAP_S2P_ID_Number__c=1190367;
            insert acc;
            
            
            System.assert(accList!= null);
            system.assertEquals(accList[0].Name,'Test Account Sales');
            system.assertEquals(acc.Name,'Test Account Service');
            
            
        }
    }
    
    
    Static testmethod void testOutboundReqProcessorValidStatus(){
        
        System.runAs(getIntegrationUser()){
            Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(200));
            Test.startTest();
            OC_IB_BATCH_OutboundReqProcessor batchProcessor = new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi);
            Database.executeBatch(batchProcessor);
            Test.stopTest();
        }
    }     
    Static testmethod void testOutboundReqProcessorInValidStatus(){
        
        System.runAs(getIntegrationUser()){
            Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(400));
            Test.startTest();
            OC_IB_BATCH_OutboundReqProcessor batchProcessor = new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi);
            Database.executeBatch(batchProcessor);
            Test.stopTest();
        }
    }  
    Static testmethod void testOutboundReqProcessorexception(){
        
        System.runAs(getIntegrationUser()){
            Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(0));
            Test.startTest();
            
            OC_IB_BATCH_OutboundReqProcessor batchProcessor = new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi);
            Database.executeBatch(batchProcessor);
            Test.stopTest();
        }
    }  
    Static testmethod void testOutboundReqProcessorGetUrlPayload(){
        
        System.runAs(getIntegrationUser()){
            OC_IB_Utility.httpMethod='GET';
            
            Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(200));
            Test.startTest();
            
            OC_IB_BATCH_OutboundReqProcessor batchProcessor = new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi);
            Database.executeBatch(batchProcessor);
            Test.stopTest();
        }
    }  
    Static testmethod void testOutboundReqProcessorFromUI(){
        Map<string,string> outboundParams=new Map<string,string>();
        outboundParams.put('ServiceToId','1190367');
        outboundParams.put('SoldToId','507952');
        outboundParams.put('FormDate','1502878080000');
        outboundParams.put('ToDate','1504878080000');
        outboundParams.put('ObjectName', 'Asset');
        Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(200));
        
        Test.startTest();
        OC_IB_RequestGenerationHandler.getOutboundRequestParam(outboundParams);
        OC_IB_RequestGenerationHandler.getObjectPicklistValues();
        Test.stopTest();
        
    }
    
    Static testmethod void testOutboundProReqProcessorFromUI(){
        Map<string,string> outboundParams=new Map<string,string>();    
        outboundParams.put('ObjectName', 'Product');
        outboundParams.put('FormDate','1502878080000');
        outboundParams.put('ToDate','1504878080000');
        Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(200));
        
        Test.startTest();
        OC_IB_RequestGenerationHandler.getOutboundRequestParam(outboundParams);
        
        Test.stopTest();
        
    }
    Static testmethod void testOutboundReqProcessorFromUIContract(){
        Map<string,string> outboundParams=new Map<string,string>();
        outboundParams.put('ServiceToId','1190367');
        outboundParams.put('SoldToId','507952');
        outboundParams.put('FormDate','1502878080000');
        outboundParams.put('ToDate','1504878080000');
        
        outboundParams.put('ObjectName', 'ServiceContract');
        Test.setMock(HttpCalloutMock.class, new OC_IB_MockHttpResponseGenerator(200));
        
        Test.startTest();
        OC_IB_RequestGenerationHandler.getOutboundRequestParam(outboundParams);
        Test.stopTest();
        
    }
    Static testmethod User getIntegrationUser(){
        List<User> integrationUser = [Select Id,Name,isActive FROM User WHERE Name='Integration User' AND isActive=true];
        system.assertEquals(1,integrationUser.size());
        PermissionSet servicePermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Ericsson_Service_Integration'][0];
        
        PermissionSetAssignment assignToUser = new PermissionSetAssignment(
            AssigneeId = integrationUser[0].Id,
            PermissionSetId = servicePermissionSet.Id
        );
        return integrationUser[0];
    }
    
    public testmethod static void testAuthenticate(){
        Test.startTest();
        OC_IB_Authenticationhandler.handleAuthentication(null);
        Test.stopTest();
    }
    
    public testmethod static void testGenerateRequest(){
        Test.startTest();
        OC_IB_RequestGenerationHandler.GenerateRequest(null,null,null,null);
        OC_IB_RequestGenerationHandler.sendRequest(null,null);
        OC_IB_RequestGenerationHandler.sendRequestFromUI(null);
        Test.stopTest();
    }
    Static testmethod void testOutboundReqFromUIAsset(){
        
        String Assetrequest = '{"AccountsList":[{"ObjectName":"Asset","filterType":"PER_FIELD_FILTER","isActive":"true","Page":"null","Size":"null","sortBy":"name","sortDirection":"ASC","FilterMap":"null","FromDateTime":"1598670000000","ToDateTime":"1601262000000","ServiceToId":"1190367","SoldToId":"507952"}]}';
        String Contractrequest = '{"AccountsList":[{"ObjectName":"ServiceContract","filterType":"PER_FIELD_FILTER","isActive":"true","Page":"null","Size":"null","sortBy":"name","sortDirection":"ASC","FilterMap":"null","FromDateTime":"1598670000000","ToDateTime":"1601262000000","ServiceToId":"1190367","SoldToId":"507952"}]}';        
        Test.startTest();
        OC_IB_RequestGenerationHandler.sendRequestFromUI(Assetrequest);
        OC_IB_RequestGenerationHandler.sendRequestFromUI(Contractrequest);
        Test.stopTest();
        
    }
}