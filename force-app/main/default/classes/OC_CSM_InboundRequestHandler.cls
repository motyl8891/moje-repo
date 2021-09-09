/**
* @File Name          : OC_CSM_InboundRequestHandler
* @Description        : Handler class for Contract inbound request from EBIP-->SF.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2011
* @Created Date       : 10th Novemeber 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-04-11                 IBM                   U-2676 Contract ResponseProfile
**/
public class OC_CSM_InboundRequestHandler {   
    Public Static String objectName; 
    Public Static String fieldDataType;    
    Public Static List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList = new List<OC_IB_InboundIntegrationFieldMapping__mdt> ();
    Public Static List<OC_IB_InboundIntegrationIdentifier__mdt> inboundIntegrationIdentifierMdtRecList = new List<OC_IB_InboundIntegrationIdentifier__mdt> ();
    Public Static  Map<String,Sobject> mapExtFieldToSfFieldmapping = new Map<String,Sobject> ();
    Public Static String integrationIdentifier;
    Public Static String requestBody;
    Public Static  List<String> extFieldList = new List<String> ();
    Public Static  List<Object> sobjRecJsonDataList = new List<Object> ();
    Public Static Map<String,Id> mapSobjRecnameToId = new Map<String,Id> ();
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    public static List<Object> initialSobjJsonDataList = new List<Object> ();
    public static List<Object> nextRunSobjJsonDataList = new List<Object> ();
    /*Start:U-3064 Added for Contract sapOrder*/
    public static Map<String,Map<String,Object>> sapOrderNumberMap=new Map<String,Map<String,Object>>();
    public static Map<String,String> contractNumberNameMap=new Map<String,String>();
    Public Static  List<String> externalFieldList = new List<String> ();
    /*End: Added for Contract sapOrder*/
    
    /***************************************************************************************************
* @Method Name : processInboundRequest
* @Description : Based on integration identifier routs to respective handler method
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : requestBody - JSON request
* @Return      : Void - Nothing 
****************************************************************************************************/
    Public OC_CSM_InboundRequestHandler (String reqBody,String integIdentifier,List<Object> sobjJsonDataList){
        try{
            if(sobjJsonDataList.size() > 1500){
                initialSobjJsonDataList.addAll(sobjJsonDataList);
                sobjJsonDataList.clear();
                if(initialSobjJsonDataList.size() > 1500){
                    for(integer i=0;i<1500;i++){
                        sobjJsonDataList.add(initialSobjJsonDataList[i]);
                    }
                    for(integer j=1500;j<initialSobjJsonDataList.size();j++){
                        nextRunSobjJsonDataList.add(initialSobjJsonDataList[j]);
                    }
                }
            }
            
            processInboundRequest(reqBody,integIdentifier,sobjJsonDataList);
            
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
            
        }Catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSM_InboundRequestHandler, OC_IB_Constants.methodCSM_InboundRequestHandler,null, true, e,integIdentifier,null,false,true,true,false,false,null,null,true,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            
        }
    }
    public static void processInboundRequest(String reqBody,String integIdentifier,List<Object> sobjJsonDataList){
        integrationIdentifier = integIdentifier;
        sobjRecJsonDataList.addAll(sobjJsonDataList);
        requestBody = reqBody;
        try{
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_inApi)){
                processContractRequest(requestBody,integrationIdentifier);
                if(nextRunSobjJsonDataList.size() > 0){
                    System.enqueueJob(new OC_IB_ParseInboundReq(integIdentifier,nextRunSobjJsonDataList));
                }
                
            }
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
            
        }Catch(Exception e){
            if(e instanceof JSONException){
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSM_InboundRequestHandler, OC_IB_Constants.methodprocessInboundRequest,null, true, e,integIdentifier,reqBody,false,true,true,false,false,null,'Invalid JSON Payload',true,OC_IB_Constants.attachTextContentType,null));
            }else{
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSM_InboundRequestHandler, OC_IB_Constants.methodprocessInboundRequest,null, true, e,integIdentifier,reqBody,false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
                
            }
            EventLog.createIntegrationLog(integEventLogInsertList);
        } 
    }
    
    /**************************************************************************************************
* @Method Name : processContractRequest
* @Description : Deserializes the JSON payload and upserts staging object records
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : requestBody - JSON request
* @Return      : Void - Nothing 
****************************************************************************************************/
    public static void processContractRequest(String requestBody,String integrationIdentifier){ 
        List<EventLog.integrationEventLog> integEventLogContractProcess = new List<EventLog.integrationEventLog> ();
        
        List<OC_IB_IntegrationSobjectRecords__c> integSobjRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        List<Sobject> contractRecList=new List<Sobject>();
        
        /*U-3064- Start: Added for Contract sapOrder*/
        List<OC_IB_IntegrationSobjectRecords__c> integSobjSapOrderRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();
        List<EventLog.integrationEventLog> integEventLogContractSapOrder = new List<EventLog.integrationEventLog> ();
        Map<String,Object> sapOrderNumber=new Map<String,Object>();
        Database.UpsertResult[] dmlResultSapOrderList;
        /*End: Added for Contract sapOrder*/
        
        Database.UpsertResult[] dmlResultList; 
        fetchMdtRecordsAndDeserializereq(null,integrationIdentifier,false); 
        Id contractRtId =Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.ContractRt).getRecordTypeId();
        
        for(Object objRec : sobjRecJsonDataList){
            Map<String, Object> mapObjRecData = (Map<String, Object>) objRec;
            
            sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,contractRtId);
            for(integer i=0;i<extFieldList.size();i++){
                Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
                String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue) );
                String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(fieldDataType));
                String fieldValue = String.valueOf(mapObjRecData.get(extFieldList[i]));
                /*U-3064- Start: Added If Else for Contract sapOrder*/
                if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.sapOrderNumber))  { 
                    sapOrderNumber=(Map<String,Object>)mapObjRecData.get(extFieldList[i]);
                }
                else{
                    if(mapObjRecData.get(extFieldList[i]) != null && mapObjRecData.get(extFieldList[i]) != ' '){
                        mapsSobjToArrayVal = OC_IB_Utility.ParseDeserializedData(sObjRec,extFieldList[i],fieldApiName,dataType,fieldValue,mdtfieldValue,mapSobjRecnameToId);
                        if(!mapsSobjToArrayVal.isEmpty()) {
                            for(Sobject sobj : mapsSobjToArrayVal.keyset()){
                                sObjRec = sobj;
                            }
                            if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.keyCSMJsonserviceElements) && !(mapsSobjToArrayVal.Values()).contains(null)){
                                String ServiceElements='';
                                List<Object> serviceElementsList=new List<Object>();
                                serviceElementsList=(List<Object>)mapObjRecData.get(extFieldList[i]);
                                for(Object serviceEleRec:serviceElementsList){
                                    Map<String, Object> serviceEle = (Map<String, Object>) serviceEleRec;
                                    
                                    if(String.isNotBlank(ServiceElements)){
                                        ServiceElements+=';'+'"'+serviceEle.get(OC_IB_Constants.keyCSMjsonServiceElementName)+'"';
                                    }
                                    else{
                                        ServiceElements='"'+String.valueof(serviceEle.get(OC_IB_Constants.keyCSMjsonServiceElementName))+'"';
                                    }
                                }
                                sObjRec.Put(String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue)),ServiceElements);
                                
                            }
                            /*U-2676 Contract ResponseProfile -begin*/
                            if(mapObjRecData.get(extFieldList[i])!=null && extFieldList[i].equalsIgnoreCase(OC_IB_Constants.responseProfile)){
                                Map<String,Object> responseProfile=new Map<String,Object>();
                                List<Object> ResponseDuration=new List<Object>();
                                responseProfile=(Map<String,Object>)mapObjRecData.get(extFieldList[i]);
                                if(responseProfile!=null && !responseProfile.isEmpty()){
                                    ResponseDuration=(List<Object>)responseProfile.get(OC_IB_Constants.responseDurations);
                                }
                                sObjRec.Put(String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue)),JSON.serialize(ResponseDuration));
                            }
                            /*U-2676 Contract ResponseProfile -end*/
                        }
                    }else{
                        sObjRec.put(fieldApiName,null);
                    }
                }
                sObjRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
                
                /*U-3064- Start: Added for Contract sapOrder*/
                if(i == extFieldList.size() - 1){
                    sapOrderNumberMap.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagedRecContractNumber)),sapOrderNumber);
                    contractNumberNameMap.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagedRecContractNumber)),String.valueOf(sObjRec.get(OC_IB_Constants.stagingContractName)));
                }/*End: Added for Contract sapOrder*/
            }
            contractRecList.add(sObjRec);
            
        } 
        /*U-3064- Start: Added for Contract sapOrder*/
        List<Object> contractSapOrderList= processSapOrderDetails(sapOrderNumberMap,OC_IB_Constants.Sfdc_Ebip_CC_inApi);
        if(!contractSapOrderList.isEmpty() && contractSapOrderList!=null){
            integSobjSapOrderRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>) contractSapOrderList);}
        /*End: Added for Contract sapOrder*/ 
        if(!contractRecList.isEmpty() && contractRecList!=null){
            integSobjRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>) contractRecList);
        }
        if(!integSobjRecList.isEmpty()){
            dmlResultList = database.upsert(integSobjRecList,OC_IB_IntegrationSobjectRecords__c.OC_CSM_Contract_Number__c,false);
            
            for(integer i=0;i<dmlResultList.size();i++){
                if(!dmlResultList[i].isSuccess()){
                    integEventLogContractProcess.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSM_InboundRequestHandler,OC_IB_Constants.MethodprocessContractRequest, null, true,null,integrationIdentifier,null,false,true,true,false,false,null,String.ValueOf(dmlResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));    
                }
            }
            if(integEventLogContractProcess!=null){
                EventLog.createIntegrationLog(integEventLogContractProcess);
            }
        }
        /*U-3064- Start: Added for Contract sapOrder*/
        if(!integSobjSapOrderRecList.isEmpty()){
            dmlResultSapOrderList = database.upsert(integSobjSapOrderRecList,OC_IB_IntegrationSobjectRecords__c.OC_CSM_concatContractNetworkServiceOrder__c,false);  
            for(integer i=0;i<dmlResultSapOrderList.size();i++){
                if(!dmlResultSapOrderList[i].isSuccess()){
                    integEventLogContractSapOrder.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSM_InboundRequestHandler,OC_IB_Constants.MethodprocessContractRequest, null, true,null,integrationIdentifier,null,false,true,true,false,false,null,String.ValueOf(dmlResultSapOrderList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                }
            }
            if(integEventLogContractSapOrder!=null){
                EventLog.createIntegrationLog(integEventLogContractSapOrder);
            }
        } /*End: Added for Contract sapOrder*/
    }
    /**************************************************************************************************
* @Method Name : fetchMdtRecordsAndDeserializereq
* @Description : Fetches the metadata records based on integration identifier and 
*                deserializes the request payload
* @Return      : Void - Nothing 
****************************************************************************************************/
    
    Public Static List<Object> fetchMdtRecordsAndDeserializereq(RestRequest request,String integrationIdentifier,Boolean deserailize){
        String requestBody;
        List<Object> sobjJsonDataList = new List<Object> ();
        inboundIntegrationIdentifierMdtRecList = OC_IB_Utility.getInboundIntegrationIdentifierMdtRecords(integrationIdentifier); 
        if(!inboundIntegrationIdentifierMdtRecList.isEmpty() && !deserailize  ){
            inboundFieldMappingMdtRecordList = OC_IB_Utility.getInboundIntegrationFieldMappingMdtRecords(integrationIdentifier);
            if(!inboundFieldMappingMdtRecordList.isEmpty()){
                objectName = inboundFieldMappingMdtRecordList[0].OC_IB_StagingObjectApiName__c;
                fieldDataType = OC_IB_Constants.stagingObjFieldDataType;
                mapExtFieldToSfFieldmapping = OC_IB_Utility.getInboundIntegrationFieldMapping (inboundFieldMappingMdtRecordList);
                if(mapExtFieldToSfFieldmapping!=null && !mapExtFieldToSfFieldmapping.isEmpty()){
                    /*U-3064- Start: Added if else for Contract sapOrder*/
                    if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CC_inApi)){
                        externalFieldList.addAll(mapExtFieldToSfFieldmapping.keyset());
                    }
                    else{
                        extFieldList.addAll(mapExtFieldToSfFieldmapping.keyset());
                    }    
                }
            }    
            
        }else if(deserailize){
            requestBody = request.requestBody.toString();
            Map <string,Object> JsonDataList = (Map<string,Object>) JSON.deserializeUntyped(requestBody);
            sobjJsonDataList=(List<object>)JsonDataList.get(OC_IB_Constants.keyCSMJsonContent);
            
        }
        return sobjJsonDataList;
        
    }
    
    /**************************************************************************************************
* @Method Name : processSapOrderDetails
* @Description : Fetches the Sap Order Details and creates records in Integration sObject
* @Return      : List<Sobject>
****************************************************************************************************/    
    Public Static List<Sobject> processSapOrderDetails(Map<String,Map<String,Object>> sapOrderNumberDetails,String integrationIdentifier){                
        List<Sobject> contractSapOrderList=new List<Sobject>();
        fetchMdtRecordsAndDeserializereq(null,integrationIdentifier,false);
        
        for(String contractno:sapOrderNumberDetails.keyset()){
            sObject sObjSapRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();      
            sObjSapRec.Put(OC_IB_Constants.sobjrecordTypeId,OC_IB_Constants.ContractSapOrderRtId);
            Map<String,Object> sapOrderNumberMap = (Map<String,Object>)sapOrderNumberDetails.get(contractno);
            
            if(sapOrderNumberMap!=null && !sapOrderNumberMap.isEmpty()){
                for(integer i=0;i<externalFieldList.size();i++){
                    Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
                    
                    String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                    String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(externalFieldList[i]).get(mdtfieldValue) );
                    String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(externalFieldList[i]).get(fieldDataType));
                    String fieldValue = String.valueOf(sapOrderNumberMap.get(externalFieldList[i]));
                    
                    if(sapOrderNumberMap.get(externalFieldList[i]) != null && sapOrderNumberMap.get(externalFieldList[i]) != ' '){
                        mapsSobjToArrayVal = OC_IB_Utility.ParseDeserializedData(sObjSapRec,externalFieldList[i],fieldApiName,dataType,fieldValue,mdtfieldValue,mapSobjRecnameToId);
                        if(!mapsSobjToArrayVal.isEmpty()) {
                            for(Sobject sobj : mapsSobjToArrayVal.keyset()){
                                sObjSapRec = sobj;
                            }
                        }
                    }else{
                        sObjSapRec.put(fieldApiName,null);
                    }
                    if(i == externalFieldList.size() - 1){ 
                        sObjSapRec.Put(OC_IB_Constants.concatContractNetworkServiceOrder, contractno+'+'+sObjSapRec.get(OC_IB_Constants.networkIdField)+'+'+sObjSapRec.get(OC_IB_Constants.serviceOrderNumberField));
                    }
                }
                sObjSapRec.Put(OC_IB_Constants.stagingContractName, contractNumberNameMap.get(contractno));
                sObjSapRec.Put(OC_IB_Constants.contractNumber, contractno);
                sObjSapRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
                contractSapOrderList.add(sObjSapRec);
            }
        }
        return contractSapOrderList;
    }
}