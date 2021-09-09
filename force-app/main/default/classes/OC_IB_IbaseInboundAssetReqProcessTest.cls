/**
* @File Name          : OC_IB_IbaseInboundAssetReqProcessTest
* @Description        : Test Class for
*						OC_IB_IbaseInboundAssetRequestProcessor (Direct)
*						OC_IB_DeserializeInboundRequest (Direct)
*						OC_IB_InboundRequestHandler (Direct)
*						OC_IB_ParseInboundReq (Direct)
*						OC_IB_Utility (Direct)
*						OC_IB_Constants (Direct)
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 10th September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Updated Version
**/
@isTest
public class OC_IB_IbaseInboundAssetReqProcessTest {
    @testsetup
    static void setup(){
        
        Id integrationprofileId = [Select Id FROM Profile WHERE Name='Integration User profile'].Id;
        List<User> testUserList = new List<User> ();
        User testUser = (User)OC_TestDataGenerator.createSObject(new User());
        
        testUser.UserName = 'ericsson@test.com';
        testUser.Email='integrationuser@invalid.com';
        testUser.ProfileId = integrationprofileId;
        insert testUser;
        system.assertEquals(testUser.UserName,'ericsson@test.com');
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='Ericsson_Service_Integration'];
        
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        System.runAs(testUser){   
            OC_TestDataGenerator.insertCustomSettingsData();
            OC_TestDataGenerator.insertIntegrationRecords();
        }
    }
    static testMethod void testIbaseAssetReqProcessor() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = 'https://ericsson--omnic1.my.salesforce.com/services/apexrest/IbaseAsset/';
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('[{"id":6539001,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"ERBS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376",""],"swPackage":"B1316R087F","contractNumbers": ["5090678","7893736"]}]');
        RestContext.request = req;
        OC_IB_IbaseInboundAssetRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_Ibase_InApi));
        Test.stopTest();
    }
    
    static testMethod void testIbaseAssetInvalidReq() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = 'https://ericsson--omnic1.my.salesforce.com/services/apexrest/IbaseAsset/';
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('[{"id":6539001,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"ERBS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376",""],"swPackage":}]');
        RestContext.request = req;
        OC_IB_IbaseInboundAssetRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_Ibase_InApi));
        Test.stopTest();
    }
    
    static testMethod void testIbaseAssetReqProcessorChainQueueable() {
        List<Object> sobjRecJsonDataList=new List<Object>();
        sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539001,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"ERBS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376",""],"swPackage":"B1316R087F"}]');
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
        System.enqueueJob(new OC_IB_ParseInboundReq(null,null));
        
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
        
        
    }
    
    //withSoldTo and ServiceTO
    static testMethod void testPostWithSoldandService() {
        List<Object> sobjRecJsonDataList=new List<Object>();
        sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539001,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"ERBS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376"],"swPackage":"B1316R087F"}]');
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
        
    }
    //with only SoldTO
    static testMethod void testPostWithSoldTo() {
        List<Object> sobjRecJsonDataList=new List<Object>();
        sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539005,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"BTS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":null,"swPackage":"B1316R087F"}]');
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
        
    }
    
    //with Null SoldTo and ServiceTo
    static testMethod void testPostNosoldtoServiceto() {
        List<Object> sobjRecJsonDataList=new List<Object>();
        sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539005,"name":"BSCRJ52-TA-1","detectionDate":1502878080000,"isActive":true,"oss":"be2uas1","type":"BTS","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":null,"serviceToIds":[],"swPackage":"B1316R087F"}]');
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
        
    }
    //Testing exceptions by providing invalid product name which is type
    static testMethod void testDMLExceptions() {
        List<Object> sobjRecJsonDataList=new List<Object>();
        sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539006,"name":"BSCRJ52-TA-1","detectionDate":"detection","isActive":true,"oss":"be2uas1","type":"AAAA","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376"],"swPackage":"B1316R087F","contractNumbers": ["5090678","7893736"]}]');
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
    }
    
    static testMethod void SatgedtoActualObjectTesting() {
        Test.startTest();
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
     }
    
}