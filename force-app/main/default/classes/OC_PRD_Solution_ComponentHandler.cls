/**
* @File Name          : OC_PRD_Solution_ComponentHandler
* @Description        : Handler class for Product inbound request of type solution and NodeComponent from EBIP-->SF and it is being called from OC_PRD_InboundRequestHandler.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2109
* @Created Date       : 12th July 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-12                 IBM                  U-3066 Initial Version
* 1.1        2021-07-15                 IBM                  U-3068 Initial Version  
**/
public class OC_PRD_Solution_ComponentHandler {
    public static Map<String,Sobject> productToSobject = new Map<String,Sobject>(); 
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    Public static Id productRtId;
    Public static String extProductRelName;
    Public static String recordTypeName;
     /***************************************************************************************************
* @Method Name : processSolutionNCompTypeRecords
* @Description : handler method to process the Solution and NodeComponent type records to staging object records
* @Params      : objectName,inboundFieldMappingMdtRecordList,inboundIntegrationIdentifierMdtRecList
* @Params      : mapExtFieldToSfFieldmapping,fieldDataType
* @Params      : extFieldList,integrationIdentifier,productObjList,productType
* @Return      : Void - Nothing 
****************************************************************************************************/
  
    public static void processSolutionNCompTypeRecords(String objectName,List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList,List<OC_IB_InboundIntegrationIdentifier__mdt> inboundIntegrationIdentifierMdtRecList,Map<String,Sobject> mapExtFieldToSfFieldmapping,String fieldDataType,List<String> extFieldList,String integrationIdentifier,List<Object> productObjList,String productType){
        List<Sobject> productRecList=new List<Sobject>();
        List<OC_IB_IntegrationSobjectRecords__c> integSobjProductRecList = new List<OC_IB_IntegrationSobjectRecords__c> (); 
        Database.UpsertResult[] dmlResultList;
        List<Object> productReleaseList=new List<Object>();
        Map<String,List<Object>> productToReleasesMap=new Map<String,List<Object>>();
        Map<String,Sobject> productRecsMaptoUpsert = new Map<String,Sobject> (); 
        
        if(String.isNotBlank(productType) && productType.equalsIgnoreCase(OC_IB_Constants.productSolutionType)){
            productRtId =OC_IB_Constants.stagingProductSolutionRt;
            extProductRelName=OC_IB_Constants.extsolutionReleases;
            recordTypeName=OC_IB_Constants.solutionRtName;        
        }
        /*U-3068 Start*/
        else if(String.isNotBlank(productType) && productType.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType)){
            productRtId = OC_IB_Constants.stagingProductNodeComponentRt;
            extProductRelName=OC_IB_Constants.extnodeComponentSoftwareReleases; 
            recordTypeName=OC_IB_Constants.nodeCompRtName;      
        }
        /*U-3068 End*/

        for(Object objRec : productObjList){
            sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,productRtId);
            sObjRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
            for(integer i=0;i<extFieldList.size();i++){
                Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
                Map<String, Object> mapObjRecData = (Map<String, Object>) objRec;
                String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue) );
                String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(fieldDataType));
                String fieldValue = String.valueOf(mapObjRecData.get(extFieldList[i]));
                
                if(mapObjRecData.get(extFieldList[i]) != null && mapObjRecData.get(extFieldList[i]) != ' ' && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extProductModels) && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.nodeTypePlatform) && !extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extTechnologies) && String.valueof(mapObjRecData.get(extFieldList[i])).length()>2){
                    
                    mapsSobjToArrayVal = OC_IB_Utility.ParseDeserializedData(sObjRec,extFieldList[i],fieldApiName,dataType,fieldValue,mdtfieldValue,null);
                    if(!mapsSobjToArrayVal.isEmpty()) {
                        for(Sobject sobj : mapsSobjToArrayVal.keyset()){
                            sObjRec = sobj;
                        }
                    }
                }
                else{
                    sObjRec.put(fieldApiName,null);
                }
                if(extFieldList[i].equalsIgnoreCase(extProductRelName) && mapObjRecData.get(extFieldList[i])!=null && String.valueof(mapObjRecData.get(extFieldList[i])).length()>2){
                    productReleaseList=(List<Object>)mapObjRecData.get(extFieldList[i]);
                }
                if(i == extFieldList.size() - 1){
                    productToReleasesMap.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),productReleaseList);
                }
            }
            productToSobject.put(String.valueOf(sObjRec.get(OC_IB_Constants.stagingObjName)),sObjRec);
        }
        productRecsMaptoUpsert=processSolutionNCompReleases(productToReleasesMap);
        if(productRecsMaptoUpsert!=null && !productRecsMaptoUpsert.isEmpty()){
            integSobjProductRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>)productRecsMaptoUpsert.Values()); 
        }
        if(integSobjProductRecList!=null && !integSobjProductRecList.isEmpty()){
            dmlResultList=database.upsert(integSobjProductRecList,OC_IB_IntegrationSobjectRecords__c.OC_PRD_TechConcatProductRelease__c, false);
            for(integer i=0;i<dmlResultList.size();i++){
                if(!dmlResultList[i].isSuccess()){
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classSolnNCompInboundRequestHandler,OC_IB_Constants.methodprocessSolutionNCompTypeRecords, null, true,null,integrationIdentifier,null,false,true,true,false,false,null,String.ValueOf(dmlResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                }
            }
        }
        if(integEventLogInsertList!=null && !integEventLogInsertList.isEmpty()){
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
    }
      /***************************************************************************************************
* @Method Name : processSolutionNCompReleases
* @Description : method to process Solution and Node Component product release records
* @Params      : releaseRecords
* @Return      : Map<String,List<Object>>
****************************************************************************************************/
    public static  Map<String,Sobject>  processSolutionNCompReleases(Map<String,List<Object>> releaseRecords){
        Map<String,Sobject> productRecsMap = new Map<String,Sobject> (); 
       if(productToSobject!=null && !productToSobject.isEmpty()){
            for(String productKey:productToSobject.keyset()){
                Sobject sObjRec=productToSobject.get(productKey).clone();
                
               if(releaseRecords!=null && !releaseRecords.isEmpty() && releaseRecords.containsKey(productKey) && releaseRecords.get(productKey)!=null && String.valueOf(releaseRecords.get(productKey)).length()>2){
                    List<Object> releaseRecrdsList=new List<Object>();
                    releaseRecrdsList=releaseRecords.get(productKey);
                    for(Object relObjRecs:releaseRecrdsList){
                        Map<String,Object> mapRelObjRec=(Map<String,Object>)relObjRecs;
                        if(mapRelObjRec!=null && !mapRelObjRec.isEmpty()){
                            Sobject stagedObject=sObjRec.clone();
                            String releaseName=String.ValueOf(mapRelObjRec.get(OC_IB_Constants.solutionCompReleaseName));
                            String stagingObjectRelName=(String.isNotblank(releaseName))?releaseName.trim():releaseName;
                            stagedObject.put(OC_IB_Constants.stagingReleaseName,stagingObjectRelName);
                            String competenceSubDomainName=String.ValueOf(mapRelObjRec.get(OC_IB_Constants.extCompetenceSubDomain));
                            stagedObject.put(OC_IB_Constants.stagingCompetenceSubDomain,competenceSubDomainName);
                            Map<String,Object> releaseRecData=new Map<String,Object>();
                            releaseRecData=(Map<String,Object>)mapRelObjRec.get(OC_IB_Constants.product);
                            if(releaseRecData!=null && !releaseRecData.isEmpty()){ 
                                stagedObject.put(OC_IB_Constants.stagingReleaseEos,String.valueof(releaseRecData.get(OC_IB_Constants.eos)));
                                stagedObject.put(OC_IB_Constants.stagingReleaseEom,String.valueof(releaseRecData.get(OC_IB_Constants.eom)));
                                stagedObject.put(OC_IB_Constants.stagingReleasePrimNo,String.valueof(releaseRecData.get(OC_IB_Constants.primNo)));
                                stagedObject.put(OC_IB_Constants.stagingReleaseGa,String.valueof(releaseRecData.get(OC_IB_Constants.ga)));
                                stagedObject.put(OC_IB_Constants.stagingCustomer,String.valueof(releaseRecData.get(OC_IB_Constants.extCustomer)));
                            }
                            String productRelExtKey=(String.isNotBlank(String.ValueOf(stagedObject.get(OC_IB_Constants.name)))?String.ValueOf(stagedObject.get(OC_IB_Constants.name)).trim():stagedObject.get(OC_IB_Constants.name))+'+'+String.ValueOf(stagedObject.get(OC_IB_Constants.stagingReleaseName))+'+'+recordTypeName;

                            stagedObject.put(OC_IB_Constants.stagingPrdRelVerExtkey,productRelExtKey); 
                            productRecsMap.put(productRelExtKey,stagedObject);    
                            
                        }
                        
                    }
                }
                else{
                    String productExtKey=(String.isNotBlank(String.ValueOf(sObjRec.get(OC_IB_Constants.name)))?String.ValueOf(sObjRec.get(OC_IB_Constants.name)).trim():sObjRec.get(OC_IB_Constants.name))+'+'+null+'+'+recordTypeName;
                    sObjRec.put(OC_IB_Constants.stagingPrdRelVerExtkey,productExtKey); 
                    productRecsMap.put(productExtKey,sObjRec);    
                }
            }
        }
        return productRecsMap;   
        
    } 
    
}