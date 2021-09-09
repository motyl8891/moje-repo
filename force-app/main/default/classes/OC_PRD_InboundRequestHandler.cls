/**
* @File Name          : OC_PRD_InboundRequestHandler
* @Description        : Handler class for Product inbound request from EBIP-->SF.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 13th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-13                 IBM                  U-2817 Initial Version
* 1.1        2021-06-21                 IBM                  U-2935 Product update
* 1.2        2021-07-15                 IBM                  U-3066/U-3068 
* 1.3        2021-08-19 	    		IBM					 Pcode Change
**/
public class OC_PRD_InboundRequestHandler { 
    Public Static String objectName; 
    Public Static String fieldDataType;    
    Public Static List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList = new List<OC_IB_InboundIntegrationFieldMapping__mdt> ();
    Public Static List<OC_IB_InboundIntegrationIdentifier__mdt> inboundIntegrationIdentifierMdtRecList = new List<OC_IB_InboundIntegrationIdentifier__mdt> ();
    Public Static  Map<String,Sobject> mapExtFieldToSfFieldmapping = new Map<String,Sobject> ();
    Public Static String integrationIdentifier;
    Public Static String requestBody;
    Public Static  List<String> extFieldList = new List<String> ();
    Public Static Map<String,Id> mapSobjRecnameToId = new Map<String,Id> ();
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    public static Map<String,Sobject> productToSobject = new Map<String,Sobject>(); 
    
    /***************************************************************************************************
* @Method Name : processProductRequestData
* @Description : Based on productType routs to respective handler method to process the product data
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : productObjList - contains product data list
* @Param       : productType - type of the product
* @Return      : Void - Nothing 
****************************************************************************************************/
    
    public static void processProductRequestData(String integrationIdentifier,List<Object> productObjList,String productType){
        
        try{
            if(productObjList!=null && !productObjList.isEmpty() && String.isNotBlank(integrationIdentifier) && String.isNotBlank(productType)){
                if(productType.equalsIgnoreCase(OC_IB_Constants.productNodeType)){
                    processNodeTypeProductRequest(integrationIdentifier,productObjList);
                    
                }
                //U-3066,U-3068 start
                else if(productType.equalsIgnoreCase(OC_IB_Constants.productSolutionType) || productType.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType)|| productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeSolution)|| productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeNodeComponent)){
                    processSolutionNCompTypeProductRequest(integrationIdentifier,productObjList,productType); 
                }
                //U-3066,U-3068 end
            }
        }Catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.productInboundhandlerClass, OC_IB_Constants.prdProcessInboundRequest,null, true, e,integrationIdentifier,null,false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
    }
    // U-3066,U-3068 start
    /***************************************************************************************************
* @Method Name : processSolutionTypeProductRequest
* @Description : handler method to process the Solution Type product to the staging object
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : productObjList - contains product data list
* @Return      : Void - Nothing 
****************************************************************************************************/
    public static void processSolutionNCompTypeProductRequest(String integrationIdentifier,List<Object> productObjList,String productType){ 
        if(Test.isRunningTest()){
            extFieldList.clear();  
        }
        fetchMdtRecordsAndDeserializereq(null,integrationIdentifier,false); 
        
        if(String.isNotBlank(productType) && (productType.equalsIgnoreCase(OC_IB_Constants.productSolutionType) ||productType.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType))){
            OC_PRD_Solution_ComponentHandler.processSolutionNCompTypeRecords(objectName, inboundFieldMappingMdtRecordList, inboundIntegrationIdentifierMdtRecList, mapExtFieldToSfFieldmapping, fieldDataType, extFieldList,integrationIdentifier,productObjList,productType);
        }
        else if(String.isNotBlank(productType) && (productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeSolution) ||productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeNodeComponent))){
            OC_PRD_NtSolution_NtComponentHandler.processNtSolutionNtCompRecords(objectName, inboundFieldMappingMdtRecordList, inboundIntegrationIdentifierMdtRecList, mapExtFieldToSfFieldmapping, fieldDataType, extFieldList,integrationIdentifier,productObjList,productType);
        }
    }
    // U-3066/U-3068  end
    
    /***************************************************************************************************
* @Method Name : processNodeTypeProductRequest
* @Description : handler method to process the nodetype product to the staging object
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : productObjList - contains product data list
* @Return      : Void - Nothing 
****************************************************************************************************/
    public static void processNodeTypeProductRequest(String integrationIdentifier,List<Object> productObjList){ 
        fetchMdtRecordsAndDeserializereq(null,integrationIdentifier,false); 
        List<Sobject> productRecList=new List<Sobject>();
        Map<String,Sobject> productRecsMaptoUpsert = new Map<String,Sobject> (); 
        List<OC_IB_IntegrationSobjectRecords__c> integSobjProductRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        Database.UpsertResult[] dmlResultList; 
        Map<String,List<Object>> productToprdModel=new Map<String,List<Object>>();
        Map<String,List<Object>> productToNodeTypePlatform=new Map<String,List<Object>>();
        Map<String,List<Object>> productToTechnologyStd=new Map<String,List<Object>>(); 
        
        Id productRtId = OC_IB_Constants.stagingProductNodeTypeRt;
        for(Object objRec : productObjList){
            Map<String, Object> mapObjRecData = (Map<String, Object>) objRec;
            List<Object> nodeTypePlatformObjRec=new List<Object>();
            List<Object> productModelList=new List<Object>();
            List<Object> techStandardList=new List<Object>();
            
            sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,productRtId);
            sObjRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
            for(integer i=0;i<extFieldList.size();i++){
                
                Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
                String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue) );
                String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(fieldDataType));
                String fieldValue = String.valueOf(mapObjRecData.get(extFieldList[i]));
                
                if(mapObjRecData.get(extFieldList[i]) != null && mapObjRecData.get(extFieldList[i]) != ' ' && fieldValue.length() > 2 && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extProductModels) && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.nodeTypePlatform) && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extTechnologies)){
                    
                    mapsSobjToArrayVal = OC_IB_Utility.ParseDeserializedData(sObjRec,extFieldList[i],fieldApiName,dataType,fieldValue,mdtfieldValue,mapSobjRecnameToId);
                    if(!mapsSobjToArrayVal.isEmpty()) {
                        for(Sobject sobj : mapsSobjToArrayVal.keyset()){
                            sObjRec = sobj;
                        }
                    }
                }
                else{
                    sObjRec.put(fieldApiName,null);
                }
                if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extProductModels) && mapObjRecData.get(extFieldList[i])!=null){
                    productModelList=(List<Object>)mapObjRecData.get(extFieldList[i]);
                }
                if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.nodeTypePlatform) && mapObjRecData.get(extFieldList[i])!=null){
                    nodeTypePlatformObjRec=(List<Object>)mapObjRecData.get(extFieldList[i]);
                } 
                if(extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extTechnologies) &&  mapObjRecData.get(extFieldList[i])!=null){
                    techStandardList=(List<Object>)mapObjRecData.get(extFieldList[i]);
                }
                if(i == extFieldList.size() - 1){
                    productToprdModel.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),productModelList);
                    productToNodeTypePlatform.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),nodeTypePlatformObjRec);
                    productToTechnologyStd.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),techStandardList);
                }
            }
            
            productToSobject.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),sObjRec);
        }
        processProductModelData(productToprdModel);
        processTechnologyStdData(productToTechnologyStd);
        productRecsMaptoUpsert=processPlatformNodeforRelVer(productToNodeTypePlatform);
        if(productRecsMaptoUpsert!=null && !productRecsMaptoUpsert.isEmpty()){
            integSobjProductRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>)productRecsMaptoUpsert.Values()); 
        }
        if(integSobjProductRecList!=null && !integSobjProductRecList.isEmpty()){
            dmlResultList=database.upsert(integSobjProductRecList,OC_IB_IntegrationSobjectRecords__c.OC_PRD_TechConcatProductRelease__c, false);
            for(integer i=0;i<dmlResultList.size();i++){
                if(!dmlResultList[i].isSuccess()){
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.productInboundhandlerClass,OC_IB_Constants.processNodeTypeProductRequestMethod, null, true,null,integrationIdentifier,null,false,true,true,false,false,null,String.ValueOf(dmlResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                }
            }
        }
        if(integEventLogInsertList!=null && !integEventLogInsertList.isEmpty()){
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
    }
    /***************************************************************************************************
* @Method Name : processProductModelData
* @Description : handler method to process the productmodel data
* @Param       : productModelDataMap - map contains product name as key and productmodel data as values
* @Return      : Void - Nothing 
****************************************************************************************************/   
    public static void processProductModelData(Map<String,List<Object>> productModelDataMap){
        if(productToSobject!=null && !productToSobject.isEmpty()){
            for(String productKey:productToSobject.keyset()){
                String productModels='';
                List<object> productModelList=new List<object>();
                if(productModelDataMap!=null && !productModelDataMap.isEmpty() && productModelDataMap.containskey(productKey)){
                    productModelList=(List<Object>)productModelDataMap.get(productKey);
                    if(productModelList!=null && !productModelList.isEmpty()){
                        for(Object prdModelRec:productModelList){
                            Map<String, Object> mapPrdModelRec = (Map<String, Object>) prdModelRec;
                            String prdModel=String.valueOf(mapPrdModelRec.get(OC_IB_Constants.extProductModelName))!=null?String.valueOf(mapPrdModelRec.get(OC_IB_Constants.extProductModelName)):'';
                            productModels+=(String.isNotBlank(prdModel) && String.isNotBlank(productModels))?';'+prdModel:prdModel;
                        }
                    } 
                }
                if(productToSobject!=null && !productToSobject.isEmpty() && productToSobject.containsKey(productKey)){
                    productToSobject.get(productKey).put(OC_IB_Constants.stagingProductModel,productModels);   
                } 
            }
        }
    }
    /***************************************************************************************************
* @Method Name : processTechnologyStdData
* @Description : handler method to process the technology data
* @Param       : productTechMap - map contains product name as key and technology as values
* @Return      : Void - Nothing 
****************************************************************************************************/   
    public static void processTechnologyStdData(Map<String,List<Object>> productTechMap){
        if(productToSobject!=null && !productToSobject.isEmpty()){
            for(String productKey:productToSobject.keyset()){
                String techStandards='';
                List<object> technologyList=new List<object>();
                if(productTechMap!=null && !productTechMap.isEmpty() && productTechMap.containskey(productKey)){
                    technologyList=(List<Object>)productTechMap.get(productKey);
                    if(technologyList!=null && !technologyList.isEmpty()){
                        for(Object techModelRec:technologyList){
                            Map<String, Object> mapTecModelRec = (Map<String, Object>) techModelRec;
                            techStandards+=String.ValueOf(mapTecModelRec.get(OC_IB_Constants.extTechStandName))!=null?String.ValueOf(mapTecModelRec.get(OC_IB_Constants.extTechStandName)):''; 
                        }
                    }
                }
                if(productToSobject!=null && !productToSobject.isEmpty() && productToSobject.containsKey(productKey)){
                    productToSobject.get(productKey).put(OC_IB_Constants.stagingPrdTechnologyStnd,techStandards);    
                } 
            }
        }
    }
    /***************************************************************************************************
* @Method Name : processPlatformNodeforRelVer
* @Description : handler method to process the platfrom node and related release and versions data
* @Param       : platformNodeData - map contains product name as key and PlatformNode data as values
* @Return      : Map<String,Sobject> 
****************************************************************************************************/   
    public static Map<String,Sobject> processPlatformNodeforRelVer(Map<String,List<Object>> platformNodeData){
        Map<String,Sobject> productRecsMap = new Map<String,Sobject> (); 
        if(platformNodeData!=null && !platformNodeData.isEmpty()){
            for(String productKey:platformNodeData.keyset()){
                Map<String,List<object>> platformReleasesMap=new Map<String,List<object>>(); //Pcode
                Map<String,String> platformToPcode=new Map<String,String>(); //Pcode
                Sobject sObjRec;
                String platformDataValue='';
                if(productToSobject!=null && !productToSobject.isEmpty() && productToSobject.containsKey(productKey)){
                    sObjRec= productToSobject.get(productKey).clone();
                }
                List<Object> nodeTypePlatformObjRec=new List<Object>();
                if(platformNodeData.containskey(productKey)){
                    String PlatformName='';
                    
                    nodeTypePlatformObjRec=(List<object>)platformNodeData.get(productKey);
                    if(nodeTypePlatformObjRec!=null && !nodeTypePlatformObjRec.isEmpty()){
                        for(integer i=0;i<nodeTypePlatformObjRec.size();i++){
                            List<Object> softwareRelease=new List<Object>();
                            Map<String, Object> mapObjRecDataPlatform = (Map<String, Object>) nodeTypePlatformObjRec[i];
                            Map<String,Object> platformData=new Map<String,Object>();
                            String Pcode=String.isNotblank(String.ValueOf(mapObjRecDataPlatform.get(OC_IB_Constants.extPrdpcode)))?String.ValueOf(mapObjRecDataPlatform.get(OC_IB_Constants.extPrdpcode)):null; //pcode
                            
                            platformData=(Map<String,Object>)mapObjRecDataPlatform.get(OC_IB_Constants.platform);
                            if(platformData!=null && !platformData.isEmpty()){
                                PlatformName= String.ValueOf(platformData.get(OC_IB_Constants.plaformName))!=null?String.ValueOf(platformData.get(OC_IB_Constants.plaformName)):'';
                                platformDataValue+=(String.isNotBlank(PlatformName) && String.isNotBlank(platformDataValue))?';'+PlatformName:PlatformName;
                            }
                            platformToPcode.put(PlatformName,Pcode); //pcode
                            softwareRelease=(List<Object>)mapObjRecDataPlatform.get(OC_IB_Constants.nodeTypeSoftwareReleases);
                            if(softwareRelease!=null && !softwareRelease.isEmpty()){
                                List<Object> nodeTypePlatformReleases=new List<Object>();
                                
                                nodeTypePlatformReleases.addAll(softwareRelease);
                                if(platformReleasesMap!=null && !platformReleasesMap.isEmpty() && platformReleasesMap.containsKey(PlatformName)){
                                    platformReleasesMap.get(PlatformName).add(nodeTypePlatformReleases);
                                }else{
                                    platformReleasesMap.put(PlatformName,nodeTypePlatformReleases);
                                }
                            }
                            if(i == nodeTypePlatformObjRec.size() - 1){
                                sObjRec.put(OC_IB_Constants.stagingPrdPlatfromName,platformDataValue);
                                if(platformReleasesMap!=null && !platformReleasesMap.isEmpty()){
                                    for(String platformRec:platformReleasesMap.keyset()){
                                        for(Object releaseRec:platformReleasesMap.get(platformRec)){
                                            Sobject stagedObject=sObjRec.clone();
                                            Map<String, Object> mapObjRecDataRelease= (Map<String, Object>) releaseRec;
                                            String platformPcode='"'+platformRec+'+'+platformToPcode.get(platformRec)+'"';
                                            stagedObject.put(OC_IB_Constants.stagingPrdPcodeNodeType,platformPcode);
                                            if(mapObjRecDataRelease!=null && !mapObjRecDataRelease.isEmpty()){
                                                String releaseName=String.ValueOf(mapObjRecDataRelease.get(OC_IB_Constants.releaseName));
                                                if(String.isNotBlank(releaseName)){
                                                    stagedObject.put(OC_IB_Constants.stagingReleaseName,releaseName.trim());
                                                }
                                                else{
                                                    stagedObject.put(OC_IB_Constants.stagingReleaseName,releaseName);
                                                }
                                                //U-2935 start
                                                String competenceSubDomainName=String.ValueOf(mapObjRecDataRelease.get(OC_IB_Constants.extCompetenceSubDomain));
                                                stagedObject.put(OC_IB_Constants.stagingCompetenceSubDomain,competenceSubDomainName);
                                                //U-2935 end
                                                Map<String,Object> releaseRecData=new Map<String,Object>();
                                                releaseRecData=(Map<String,Object>)mapObjRecDataRelease.get(OC_IB_Constants.product);
                                                if(releaseRecData!=null && !releaseRecData.isEmpty()){ 
                                                    
                                                    stagedObject.put(OC_IB_Constants.stagingReleaseEos,String.valueof(releaseRecData.get(OC_IB_Constants.eos)));
                                                    stagedObject.put(OC_IB_Constants.stagingReleaseEom,String.valueof(releaseRecData.get(OC_IB_Constants.eom)));
                                                    stagedObject.put(OC_IB_Constants.stagingReleasePrimNo,String.valueof(releaseRecData.get(OC_IB_Constants.primNo)));
                                                    stagedObject.put(OC_IB_Constants.stagingReleaseGa,String.valueof(releaseRecData.get(OC_IB_Constants.ga)));
                                                    //U-2936 start
                                                    stagedObject.put(OC_IB_Constants.stagingCustomer,String.valueof(releaseRecData.get(OC_IB_Constants.extCustomer)));
                                                    //U-2936 end
                                                }
                                                String productRelExtKey=(String.isNotBlank(String.ValueOf(stagedObject.get(OC_IB_Constants.name)))?String.ValueOf(stagedObject.get(OC_IB_Constants.name)).trim():stagedObject.get(OC_IB_Constants.name))+'+'+String.ValueOf(stagedObject.get(OC_IB_Constants.stagingReleaseName))+'+'+OC_IB_Constants.extIdstagingNodeTypeRt;
                                                stagedObject.put(OC_IB_Constants.stagingPrdRelVerExtkey,productRelExtKey); 
                                                //pcode change start
                                                if(productRecsMap!=null && !productRecsMap.isEmpty() && productRecsMap.containsKey(productRelExtKey)){
                                                    String platformPcodeTemp=String.ValueOf((productRecsMap.get(productRelExtKey)).get(OC_IB_Constants.stagingPrdPcodeNodeType)); 
                                                    String finalPlatformpcode=platformPcodeTemp+';'+platformPcode;
                                                    stagedObject.put(OC_IB_Constants.stagingPrdPcodeNodeType,finalPlatformpcode);
                                                }
                                                //pcode change end
                                                
                                                //get Software versions
                                                List<Object> softwareVersionList=new List<Object>();
                                                String versionNames='';
                                                softwareVersionList=(List<Object>)mapObjRecDataRelease.get(OC_IB_Constants.softwareVersions);
                                                if(softwareVersionList!=null && !softwareVersionList.isEmpty()){
                                                    for(Object versionRec:softwareVersionList){
                                                        Map<String, Object> vesrionRecMap= (Map<String, Object>) versionRec;
                                                        String verName=String.valueOf(vesrionRecMap.get(OC_IB_Constants.versionName))!=null?String.valueOf(vesrionRecMap.get(OC_IB_Constants.versionName)):null;
                                                        if(String.isNotBlank(versionNames)){   
                                                            versionNames+=(String.isNotBlank(verName) && verName!=null)?';'+'"'+verName+'"':'';
                                                        }
                                                        else {
                                                            versionNames=(String.isNotBlank(verName) && verName!=null)?'"'+verName+'"':''; 
                                                        }
                                                    } 
                                                    stagedObject.put(OC_IB_Constants.stagingVersionName,versionNames);
                                                    productRecsMap.put(productRelExtKey,stagedObject);    
                                                } 
                                                else{
                                                    stagedObject.put(OC_IB_Constants.stagingVersionName,versionNames);
                                                    productRecsMap.put(productRelExtKey,stagedObject);    
                                                }
                                            }
                                            
                                        }  
                                    }
                                }else{
                                    
                                    String productExtKey=(String.isNotBlank(String.ValueOf(sObjRec.get(OC_IB_Constants.name)))?String.ValueOf(sObjRec.get(OC_IB_Constants.name)).trim():sObjRec.get(OC_IB_Constants.name))+'+'+null+'+'+OC_IB_Constants.extIdstagingNodeTypeRt;
                                    sObjRec.put(OC_IB_Constants.stagingPrdRelVerExtkey,productExtKey); 
                                    productRecsMap.put(productExtKey,sObjRec);    
                                }
                            } 
                        }
                    }
                    else{
                        String productExtKey=(String.isNotBlank(String.ValueOf(sObjRec.get(OC_IB_Constants.name)))?String.ValueOf(sObjRec.get(OC_IB_Constants.name)).trim():sObjRec.get(OC_IB_Constants.name))+'+'+null+'+'+OC_IB_Constants.extIdstagingNodeTypeRt;
                        sObjRec.put(OC_IB_Constants.stagingPrdRelVerExtkey,productExtKey); 
                        productRecsMap.put(productExtKey,sObjRec);    
                    }
                }
            }
        }
        system.debug('productRecsMap data==>'+productRecsMap);
        return productRecsMap;
    }
    
    /**************************************************************************************************
* @Method Name : fetchMdtRecordsAndDeserializereq
* @Description : Fetches the metadata records based on integration identifier and 
*                deserializes the request payload
* @Return      : Void - Nothing 
****************************************************************************************************/
    
    Public Static Map<string,Object> fetchMdtRecordsAndDeserializereq(RestRequest request,String integrationIdentifier,Boolean deserailize){
        String requestBody;
        Map <string,Object> JsonDataMap = new  Map <string,Object>();
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
            JsonDataMap = (Map<string,Object>)JSON.deserializeUntyped(requestBody);
        }
        return JsonDataMap;
        
    }
}