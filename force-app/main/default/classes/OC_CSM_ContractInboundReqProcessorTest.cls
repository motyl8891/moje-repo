/**
* @File Name          : OC_CSM_ContractInboundReqProcessorTest
* @Description        : Test Class for
*						OC_CSM_ContractInboundRequestProcessor 
*						OC_IB_BATCH_StagedDataProcessor 
*						OC_CSM_StagedObjToActualObjMapingHandler
*						OC_IB_BatchProcessInstalledBaseItems 
*						OC_IB_Utility 
*						OC_IB_Constants 
*                       OC_IB_InstalledBaseItemsHandler 
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2011
* @Created Date       : 10th October 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Updated Version
* 1.2        2021-04-08                 IBM                   U-2676 Contract ResponseProfile
**/
@isTest
public class OC_CSM_ContractInboundReqProcessorTest {
    
    public static final set<String> assetids=new set<String>();
    
    @testSetup static void setup(){
        Id integrationprofileId = [Select Id FROM Profile WHERE Name='Integration User profile'].Id;
        List<User> testUserList = new List<User> ();
        User testUser = (User)OC_TestDataGenerator.createSObject(new User());
        
        testUser.UserName = 'ericsson@test.com';
        testUser.Email='integrationuser@invalid.com';
        testUser.ProfileId = integrationprofileId;
        insert testUser;
        system.assertEquals(testUser.UserName,'ericsson@test.com');
        
        System.runAs(testUser){ 
            OC_TestDataGenerator.insertCustomSettingsData();
            OC_TestDataGenerator.insertIntegrationRecords();
            assetids.add('6539004+123456');
          }   
     }
    
    static testMethod void testCSMContractReqProcessor() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = 'https://ericsson--omnic1.my.salesforce.com/services/apexrest/ServiceContract/';
        req.httpMethod = 'POST';
    //    req.requestBody=Blob.valueof('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[{"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":""}],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[{"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"EMERGENCY","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"}],"isActive":true},"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport"},"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM"}]}');
        /*Commented the above line and added other fields in the Json for Contract sapOrderNumber*/
        req.requestBody=Blob.valueof('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[{"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":""}],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[{"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"EMERGENCY","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"}],"isActive":true},"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport"},"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM","sapOrderNumber": {"networkId":"82344567","serviceOrderNumber": null,"networkDescription": "ABC Desc","companyCode": "2011"}}]}}');  
        RestContext.request = req;
        OC_CSM_ContractInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_CSM_InApi)); 
        
        Test.stopTest();      
    }
    
    static testMethod void testCSMContractReqProcessorException(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestURI = 'https://ericsson--omnic1.my.salesforce.com/services/apexrest/ServiceContract/';
        req.httpMethod = 'POST';
     //   req.requestBody=Blob.valueof('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[{"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":""}],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[{"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"EMERGENCY","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"}],"isActive":true},"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport"},"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM"}]}');
        /*Commented the above line and added other fields in the Json for Contract sapOrderNumber*/
        req.requestBody=Blob.valueof('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[{"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":""}],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[{"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"EMERGENCY","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"},{"responseDurationPriority":"","responseDurationType":"","timeValue":15,"timeUnit":"MINUTE"}],"isActive":true},"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport"},"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM","sapOrderNumber": {"networkId":"8234456","serviceOrderNumber": null,"networkDescription": "ABC Desc","companyCode": "2011"}}]}}');
       	
        RestContext.request = req;
        OC_CSM_ContractInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_CSM_InApi)); 
        
        Test.stopTest();      
    }
    
    static testMethod void testCSMContractReqProcessorChainQueueable() {
        Map <string,Object> sobjRecJsonDataList=new Map <string,Object>();
     //   sobjRecJsonDataList=(Map<string,Object>)JSON.deserializeUntyped('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[ {"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":"" } ],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[ ],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[ {"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE" } ],"isActive":true },"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport" },"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM" }]}}');
        /*Commented the above line and added other fields in the Json for Contract sapOrderNumber*/
        sobjRecJsonDataList=(Map<string,Object>)JSON.deserializeUntyped('{"content":[{"lcmCId":null,"serviceOrderNumber":null,"assignmentId":"60016766","valueContractId":null,"contractValidated":null,"contractStatus":"Open","startDate":"2016-01-01","endDate":"2018-01-01","initialStartDate":null,"soldToParty":"507952","customerBrandingName":"ClaroBrazil","customerLegalName":"CLAROSA","customerCountryCode":"BR","customerCountry":"Brazil","customerMarketAreaCode":"MELA","customerReportingGroup":"Claro","customerUnit":"CUBrazil","globalCustomerId":"302815","globalCustomerUnit":"AMTEL","serviceToParty":"1190376","serviceToName":"CLARO-BR","serviceToCountryCode":"BR","serviceToCountry":"Brazil","globalSupportedContract":false,"globalSupportedMarketArea":null,"globalSupportedCountry":null,"globalSupportedCountryCode":null,"servicePackageCode":"003","servicePackageName":"SecureAdvancedSW","serviceElements":[ {"code":"22","name":"Stand-byafterEmergencyRecovery","comment":"","description":"RemotemonitoringoftheimpactedsystemafteranEmergency,finalizedbyahealthcheckofthesystem.","active":true,"productID":null,"services":null,"isResponseProfile":null,"defaultSWResponseProfile":null,"leadDays":null,"precisionTargetHW":null,"parameters":"" } ],"deleted":null,"sourceSystem":"SMS","createdAt":"2016-01-06T06:21:17","createdBy":"EEDLRAC","csdpChangedAt":"2016-12-19T20:34:51","smsChangedAt":"2017-01-06T04:46:21","deltaIdentifierDate":"2016-12-19T20:34:51","csdpChangedBy":"EDBDCR","smsChangedBy":"EEUNDAO","contractDateChangeHistory":[ ],"responseProfileCode":"ZTA-GSM","responseProfile":{"code":"ZTA-GSM","description":"SLATelecomAmericasGSM","responseDurations":[ {"responseDurationPriority":"EMERGENCY","responseDurationType":"CALLBACK1","timeValue":15,"timeUnit":"MINUTE" } ],"isActive":true },"obligations":null,"customerObligations":null,"responsibleSdms":null,"soldToIsArchived":false,"serviceToCustomerUnit":"","partnerType":{"partnerTypeKey":2,"description":"SystemSupport" },"csContractNumber":"0005104220","contractName":"2272-SuporteGSM,WCDMA,LTE,TX","serviceTypeFlag":false,"3PPFlag":false,"serviceToArchived":false,"serviceToMarketAreaCode":"RLAM", "sapOrderNumber": {"networkId": "82344366","serviceOrderNumber": null,"networkDescription": "2010 GSCO","companyCode": "2178"}}]}}');
        List<object> JsonDataList = new List<object> ();
        JsonDataList=(List<object>)sobjRecJsonDataList.get(OC_IB_Constants.keyCSMJsonContent);
        
        Test.startTest();
        
        System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_CSM_InApi,JsonDataList));
        System.enqueueJob(new OC_IB_ParseInboundReq(null,null));
        
        
        Test.stopTest();	
    }
    
    static testMethod void testCSMContractStagingToActualObject() {
        
        Test.startTest();
        
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor('Sfdc_Ebip_CSM_inApi');
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();	
        
    }
    
    /*****************
* This test method is for installed base items processing class "OC_IB_BatchProcessInstalledBaseItems"
****************/
    
    
static testMethod void testCSMContractInstalledBaseItems() {
    Set<String> sobjectsCsdpIds=new Set<String>{'6539004','6539008','6539007','6539009'};
        
    Test.startTest();
    
    OC_IB_BatchProcessInstalledBaseItems batchInboundProcessor = new OC_IB_BatchProcessInstalledBaseItems('Sfdc_Ebip_Ibase_inApi');
    Database.executeBatch(batchInboundProcessor);
    OC_IB_InstalledBaseItemsHandler.updateAssetStausOutOfScope(assetids,OC_IB_Constants.ibItemsMultipleSTPRecrds);
    OC_IB_InstalledBaseItemsHandler.updateAssetStausOutOfScope(sobjectsCsdpIds,OC_IB_Constants.ibItemsSoldToRecrds);
    
    Test.stopTest();	
    
}
static testMethod void testDMLExceptions() {
    List<Object> sobjRecJsonDataList=new List<Object>();
    sobjRecJsonDataList=(List<Object>)JSON.deserializeUntyped('[{"id":6539006,"name":"BcontractRJ52-TA-1","detectionDate":"detection","isActive":true,"oss":"be2uas1","type":"AAAA","softwareVersion":"BTS G16B.11","softwareVersionShort":"L18.Q3","softwareRelease":"L16B.10-2","softwareLevel":null,"platform":"AXE","soldToId":507952,"serviceToIds":["1190376"],"swPackage":"B1316R087F","contractNumbers": ["5090678","7893736"]}]');
    Test.startTest();
    
    System.enqueueJob(new OC_IB_ParseInboundReq(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi,sobjRecJsonDataList));
    OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi);
    Database.executeBatch(batchInboundProcessor);
    Test.stopTest();
}
}