/**
* @File Name          : OC_IB_InboundRequestHandler
* @Description        : Handler class for Ibase inbound request from EBIP-->SF.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Updated Version
**/
public class OC_IB_InboundRequestHandler {   
    Public Static String objectName; 
    Public Static String fieldDataType;    
    Public Static List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList = new List<OC_IB_InboundIntegrationFieldMapping__mdt> ();
    Public Static List<OC_IB_InboundIntegrationIdentifier__mdt> inboundIntegrationIdentifierMdtRecList = new List<OC_IB_InboundIntegrationIdentifier__mdt> ();
    Public Static  Map<String,Sobject> mapExtFieldToSfFieldmapping = new Map<String,Sobject> ();
    Public Static String integrationIdentifier;
    Public Static String requestBody;
    Public Static  List<String> extFieldList = new List<String> ();
    Public Static  List<Object> sobjRecJsonDataList = new List<Object> ();
    Public Static  List<Object> sobjRecJsonMasterList = new List<Object> ();
    Public Static  List<Object> sobjRecJsonDataList1 = new List<Object> ();
    Public Static Map<String,Id> mapSobjRecnameToId = new Map<String,Id> ();
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    public static List<Object> initialSobjJsonDataList = new List<Object> ();
    public static List<Object> nextRunSobjJsonDataList = new List<Object> ();
    /***************************************************************************************************
* @Method Name : processInboundRequest
* @Description : Based on integration identifier routs to respective handler method
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : requestBody - JSON request
* @Return      : Void - Nothing 
****************************************************************************************************/
    Public OC_IB_InboundRequestHandler (String reqBody,String integIdentifier,List<Object> sobjJsonDataList){
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
        }Catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInboundRequestHandler, OC_IB_Constants.methodInboundRequestHandler,null, true, e,integIdentifier,reqBody,false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            
        }
        
        
    }
    public static void processInboundRequest(String reqBody,String integIdentifier,List<Object> sobjJsonDataList){
        integrationIdentifier = integIdentifier;
        sobjRecJsonDataList.addAll(sobjJsonDataList);
        requestBody = reqBody;
        try{
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
                processIbaseRequest(requestBody,integrationIdentifier);
                if(nextRunSobjJsonDataList.size() > 0){
                    System.enqueueJob(new OC_IB_ParseInboundReq(integIdentifier,nextRunSobjJsonDataList));
                }
                
            }
        }Catch(Exception e){
            if(e instanceof JSONException){
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInboundRequestHandler, OC_IB_Constants.methodprocessInboundRequest,null, true, e,integIdentifier,reqBody,false,true,true,false,false,null,'Invalid JSON Payload',true,OC_IB_Constants.attachTextContentType,null));
            }else{
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInboundRequestHandler, OC_IB_Constants.methodprocessInboundRequest,null, true, e,integIdentifier,reqBody,false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
                
            }
            EventLog.createIntegrationLog(integEventLogInsertList);
        } 
    }
    /**************************************************************************************************
* @Method Name : processIbaseRequest
* @Description : Deserializes the JSON payload and upserts staging object records
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : requestBody - JSON request
* @Return      : Void - Nothing 
****************************************************************************************************/
    public static void processIbaseRequest(String requestBody,String integrationIdentifier){
        
        List<Asset> assetRecordsList = new List<Asset> ();
        List<OC_IB_IntegrationSobjectRecords__c> integSobjUpdSoldToIdRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        List<OC_IB_IntegrationSobjectRecords__c> existingSoldToIdRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();
        Map<String,Sobject> mapCSDPIdToupdateSoldIdWithServIdRec = new Map<String,Sobject> ();
        Map<String,Sobject> mapConcatSobjNameAccIdToSojectRec = new Map<String,Sobject> ();
        Map<String,Sobject> mapAssetNameAccIdToSojectRec = new Map<String,Sobject> ();
        Map<String,Sobject> mapCSDPIdToServToIdRecList = new Map<String,Sobject> (); 
        Map<String,Sobject> mapCSDPIdToSoldToIdRecList = new Map<String,Sobject> ();  
        Map<String,OC_IB_IntegrationSobjectRecords__c> mapCSDPIdToSoldToIdStagingRec = new Map<String,OC_IB_IntegrationSobjectRecords__c> ();    
        Set<String> csdpIdSet = new  Set<String> ();   
        Map<String,Sobject> mapsoldtokeySobject = new Map<String,Sobject>();
        List<OC_IB_IntegrationSobjectRecords__c> integSobjSoldToIdRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        List<OC_IB_IntegrationSobjectRecords__c> integSobjServToIdRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        
        Database.UpsertResult[] dmlResultList; 
        fetchMdtRecordsAndDeserializereq(null,integrationIdentifier,false); 
        Id assetRtId =Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.assetRecType).getRecordTypeId();
        for(Object objRec : sobjRecJsonDataList){
            Map<String, Object> mapObjRecData = (Map<String, Object>) objRec;
            List<String> serviceToIdList = new List<String> (); 
            List<String> ContractNumbers=new List<String>();
            sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,assetRtId);
            for(integer i=0;i<extFieldList.size();i++){
                Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
                String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue) );
                String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(fieldDataType));
                String fieldValue = String.valueOf(mapObjRecData.get(extFieldList[i]));
                if(mapObjRecData.get(extFieldList[i]) != null && mapObjRecData.get(extFieldList[i]) != ' '){
                    mapsSobjToArrayVal = OC_IB_Utility.ParseDeserializedData(sObjRec,extFieldList[i],fieldApiName,dataType,fieldValue,mdtfieldValue,mapSobjRecnameToId);
                    if(!mapsSobjToArrayVal.isEmpty()) {
                        for(Sobject sobj : mapsSobjToArrayVal.keyset()){
                            sObjRec = sobj;
                        }
                        if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extserviceToIds) && !(mapsSobjToArrayVal.Values()).contains(null)){
                            for(List<String> arrayVal : mapsSobjToArrayVal.Values()){
                                serviceToIdList.addAll(arrayVal);
                            }
                        }
                        if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extcontractNumbers) && !(mapsSobjToArrayVal.Values()).contains(null)){
                            String contractNumber='';   
                            for(List<String> arrayVal : mapsSobjToArrayVal.Values()){
                                for(String ConNumber:arrayVal){
                                    if(String.isNotBlank(contractNumber)){
                                        contractNumber+=';'+ ConNumber; 
                                    }
                                    else{
                                        contractNumber=ConNumber;  
                                    }
                                }
                                sObjRec.put(OC_IB_Constants.IBContractNumbers,contractNumber);
                            }
                        }
                        if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extcontractNumbers) && (mapsSobjToArrayVal.Values()).contains(null)){
                            sObjRec.put(OC_IB_Constants.IBContractNumbers,null);
                        }
                        
                    }
                }else{
                    sObjRec.put(fieldApiName,null);
                }
                if(i == extFieldList.size() - 1){
                    string csdpRecId = String.Valueof(sObjRec.get(OC_IB_Constants.csdpRecId));
                    string recName = String.valueOf(sObjRec.get(OC_IB_Constants.name));
                    sObjRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
                    csdpIdSet.add(csdpRecId);
                    if( !serviceToIdList.isEmpty()){
                        for(integer j=0;j<serviceToIdList.size();j++){
                            String servId = serviceToIdList[j];
                            //U-2484 Changes
                            sObject clonedSobjRec = sObjRec.clone(); 
                            clonedSobjRec.Put(OC_IB_Constants.stagingExtKeyServToId,csdpRecId+ '+' +servId);
                            clonedSobjRec.Put(OC_IB_Constants.stagingServToId,servId);
                            String key = String.valueOf(csdpRecId)+'+'+servId;
                            mapCSDPIdToServToIdRecList.put(key,clonedSobjRec);
                        }
                    }
                    String soldtoPartyExternalkey= string.valueOf(sObjRec.get(OC_IB_Constants.csdpRecId))+'+'+string.valueOf(sObjRec.get(OC_IB_Constants.stagingSoldToId));
                    sObjRec.put(OC_IB_Constants.stagingExtKeySoldToId,soldtoPartyExternalkey);
                    mapsoldtokeySobject.put(soldtoPartyExternalkey,sObjRec);  
                }
            }    
        } 
        
        if(!mapsoldtokeySobject.isEmpty() && mapsoldtokeySobject!=null){
            integSobjSoldToIdRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>)mapsoldtokeySobject.Values()); 
            dmlResultList=database.upsert(integSobjSoldToIdRecList,OC_IB_IntegrationSobjectRecords__c.OC_IB_Asset_ConcatAssetIdSoldToId__c, false);
        }
        
        if(!mapCSDPIdToServToIdRecList.isEmpty() && mapCSDPIdToServToIdRecList!=null){
            integSobjServToIdRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>)mapCSDPIdToServToIdRecList.Values());  
            dmlResultList=database.upsert(integSobjServToIdRecList,OC_IB_IntegrationSobjectRecords__c.OC_IB_Asset_ConcatAssetIdServiceToId__c, false);
            
        }
    }
    
    /**************************************************************************************************
* @Method Name : fetchMdtRecordsAndDeserializereq
* @Description : Fetches the metadata records based on integration identifier and 
*                deserializes the request payload
* @Return      : Void - Nothing 
****************************************************************************************************/
    
    Public Static  List<Object> fetchMdtRecordsAndDeserializereq(RestRequest request,String integrationIdentifier,Boolean deserailize){
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
                    extFieldList.addAll(mapExtFieldToSfFieldmapping.keyset());
                }
            }    
            
        }else if(deserailize){
            requestBody = request.requestBody.toString();
            sobjJsonDataList = (List<Object>) JSON.deserializeUntyped( requestBody);
            
        }
        return sobjJsonDataList;
        
    }
}