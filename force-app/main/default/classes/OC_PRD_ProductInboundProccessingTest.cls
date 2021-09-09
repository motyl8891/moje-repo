/**
* @File Name          : OC_PRD_ProductInboundProccessingTest
* @Description        : Test Class For Product Inbound 
* @Author             : IBM
* @Created Date       : 4 Jun 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-04                  IBM               Initial Version
* 1.1        2021-07-26                  IBM               U-3066
**/
@isTest
public class OC_PRD_ProductInboundProccessingTest{
    @testSetup 
    static void setup(){
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
        }      
    }
    @isTest
    static void processProductInboundRequest(){
        test.startTest();
        RestRequest req = new RestRequest(); 
        req.httpMethod = 'POST';
        //req.requestBody=Blob.valueof('{"nodeTypes":[{"updatedAt":"2021-02-23T14:09:03","state":"Active","name":"singleProduct1","description":" Juniper/SRX","nodeTypePlatform":[{"updatedAt":"2021-02-11T13:42:00","state":"Active","platform":{"updatedAt":"2021-02-11T13:41:55","state":"Active","name":"Juniper","description":"Juniper","ibmsPlatformTypeId":83993},"nodeTypeSoftwareReleases":[{"updatedAt":"2021-02-26T07:26:58","state":"Active","name":"1.0","description":"Juniper 1.0","competenceSubDomainName":"Test Sub Domain","ibmsNodeInstTypeReleaseId":14923,"product":{"updatedAt":"2021-02-26T07:26:58","state":"Active","ga":"2010-06-20T00:00:00.000+0000","eos":"2010-06-20T00:00:00.000+0000","eom":"2010-05-30T00:00:00.000+0000","primNo":"Windows SoD R2.2","customer":null},"softwareVersions":[]},{"updatedAt":"2021-02-26T07:26:58","state":"Active","name":"2.0","description":"Juniper 1.0","competenceSubDomainName":"Test Sub Domain","ibmsNodeInstTypeReleaseId":14923,"product":{"updatedAt":"2021-02-26T07:26:58","state":"Active","ga":"2010-06-20T00:00:00.000+0000","eos":"2010-06-20T00:00:00.000+0000","eom":"2010-05-30T00:00:00.000+0000","primNo":"Windows SoD R2.2","customer":null},"softwareVersions":[{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"15","description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":null,"description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"1","description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"","description":null}]}]}],"productModels":[{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":null,"description":"APG40C/2 Description"},{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"}],"technologies":[{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"},{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"}]}]}');
        req.requestBody=Blob.valueof('{"nodeTypes":[{"updatedAt":"2021-02-23T14:09:03","state":"Active","name":"singleProduct1","description":" Juniper/SRX","nodeTypePlatform":[{"updatedAt":"2021-02-11T13:42:00","state":"Active","platform":{"updatedAt":"2021-02-11T13:41:55","state":"Active","name":"Juniper","description":"Juniper","ibmsPlatformTypeId":83993},"nodeTypeSoftwareReleases":[{"updatedAt":"2021-02-26T07:26:58","state":"Active","name":"1.0","description":"Juniper 1.0","competenceSubDomainName":"Test Sub Domain","ibmsNodeInstTypeReleaseId":14923,"product":{"updatedAt":"2021-02-26T07:26:58","state":"Active","ga":"2010-06-20T00:00:00.000+0000","eos":"2010-06-20T00:00:00.000+0000","eom":"2010-05-30T00:00:00.000+0000","primNo":"Windows SoD R2.2","customer":null},"softwareVersions":[]},{"updatedAt":"2021-02-26T07:26:58","state":"Active","name":"2.0","description":"Juniper 1.0","competenceSubDomainName":"Test Sub Domain","ibmsNodeInstTypeReleaseId":14923,"product":{"updatedAt":"2021-02-26T07:26:58","state":"Active","ga":"2010-06-20T00:00:00.000+0000","eos":"2010-06-20T00:00:00.000+0000","eom":"2010-05-30T00:00:00.000+0000","primNo":"Windows SoD R2.2","customer":null},"softwareVersions":[{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"15","description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":null,"description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"1","description":null},{"updatedAt":"2021-02-23T14:09:16","state":"Active","name":"","description":null}]}]}],"productModels":[{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":null,"description":"APG40C/2 Description"},{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"}],"technologies":[{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"},{"updatedAt":"2021-04-16 18:57:21","state":"Active","name":"b","description":"APG407"}]}],"solutions":[{"name":" Charging System","description":" Charging System from Ericsson","solutionReleases":[{"name":"Charging System 5.0","description":"5.0 release","competenceSubDomainName":"Test Sub Domain","product":{"updatedAt":"2021-02-26T07:26:58","state":"Active","ga":null,"eos":"2010-06-20T00:00:00.000+0000","eom":"2010-05-30T00:00:00.000+0000","primNo":null,"customer":"1190376"}}]}],"nodeTypeSolution":[{"updatedAt":"2021-02-11T13:42:00","state":"Active","solutionName":"Charging System null check","solutionReleaseName":"NPSolRlease","nodeTypeName":"Juniper/SRX","platfomName":null,"nodeTypeSwReleaseName":"NTRel"}],"nodeComponents":[{"updatedAt":"2021-02-21 18:30:00","state":"ACTIVE","name":"TEST NODE COMPONENT","description":"TEST NODE COMPONENT Desc","nodeComponentSoftwareReleases":[{"updatedAt":"2021-02-18 18:30:00","state":"ACTIVE","name":"TEST Node Compnent SW","description":"TEST DESC 1","product":{"updatedAt":"2021-03-12 11:52:27","state":"Active","ga":null,"eos":null,"eom":null,"primNo":"Windows SoD R2.4","customer":null}}]}],"nodeTypeNodeComponentReleases":[{"state":"ACTIVE","nodeComponentName":"TEST NODE COMPONENT","nodeComponentReleaseName":"TEST Node Compnent SW","nodeTypeName":"Demo Product","platfomName":"Demo1","nodeTypeSwReleaseName":"Demo Release","updatedAt":"2021-02-18 18:30:00"}]}');
        RestContext.request = req;
        OC_PRD_ProductInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_PRD_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_PRD_InApi)); 
        test.stopTest();  
    }
    @isTest
    static void testProdReqProcessorException(){
        test.startTest();
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('{"nodeTypes",test}');       
        RestContext.request = req;
        OC_PRD_ProductInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_PRD_InApi));         
        test.stopTest();      
    }
    @isTest
    static void testProdReqProcessorNoNodetypeData(){
        test.startTest();
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('{"nodeTypes":[]}');       
        RestContext.request = req;
        OC_PRD_ProductInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_PRD_InApi));         
        test.stopTest();      
    }
    @isTest
    static void testProdReqProcessorNoData(){
        test.startTest();
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('{}');       
        RestContext.request = req;
        OC_PRD_ProductInboundRequestProcessor.handleInboundRequest();
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(req,OC_IB_Constants.Sfdc_Ebip_PRD_InApi));         
        test.stopTest();      
    } 
    @isTest
    static void BatchprodscedulerMethod(){
        test.startTest();
        OC_IB_BATCH_StagedDataProcessor batchInboundProcessor = new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_PRD_inApi);
        Database.executeBatch(batchInboundProcessor);
        test.stopTest();
    }
    @isTest
    static void scedulerMethodPRODtagingRoActual(){
        Test.startTest();
        OC_PRD_StagingObjToActualObjScheduler prodStaging=new OC_PRD_StagingObjToActualObjScheduler();
        prodStaging.execute(null);
        //Solution And Node Component Changes Start
        OC_PRD_NodeSolnStagingToActualScheduler prodSolnStaging=new OC_PRD_NodeSolnStagingToActualScheduler();
        prodSolnStaging.execute(null);
        Test.stopTest(); 
        //Solution And Node Component Changes end
    }

    
}