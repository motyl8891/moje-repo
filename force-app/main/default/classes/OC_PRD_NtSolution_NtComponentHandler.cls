/**
* @File Name          : OC_PRD_NtypeSolution_ComponentHandler
* @Description        : Handler class for Product NodeTypeSolution and NodeTypeNodeComponentReleases data processing from EBIP-->SF and it is being called from OC_PRD_InboundRequestHandler.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2109
* @Created Date       : 13th july 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-13                 IBM                  U-3066 Initial Version
* 1.1        2021-07-15                 IBM                  U-3068 Initial Version
*/
public class OC_PRD_NtSolution_NtComponentHandler {
    Public static Id productRtId;
    Public static String recordTypeName;
    public static boolean isNodeTypeSolution=false;
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    /***************************************************************************************************
* @Method Name : processNtSolutionNtCompRecords
* @Description : method to process nodetypesolution and nodetypenodecomponent data from product payload to staging object
* @Params      : objectName,inboundFieldMappingMdtRecordList,inboundIntegrationIdentifierMdtRecList
* @Params      : mapExtFieldToSfFieldmapping,fieldDataType
* @Params      : extFieldList,integrationIdentifier,productObjList,productType
* @Return      : Void - Nothing 
****************************************************************************************************/
    public static void processNtSolutionNtCompRecords(String objectName,List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList,List<OC_IB_InboundIntegrationIdentifier__mdt> inboundIntegrationIdentifierMdtRecList,Map<String,Sobject> mapExtFieldToSfFieldmapping,String fieldDataType,List<String> extFieldList,String integrationIdentifier,List<Object> productObjList,String productType){
        List<Sobject> integSobjNodeTypeSolCmpRecList = new List<Sobject> (); 
        List<OC_IB_IntegrationSobjectRecords__c> integSobjProductRecList = new List<OC_IB_IntegrationSobjectRecords__c> ();    
        Database.UpsertResult[] dmlResultList; 
        
        if(String.isNotBlank(productType) && productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeSolution)){
            productRtId =OC_IB_Constants.stagingNodeTypeSolutionRt;
            recordTypeName=OC_IB_Constants.solutionRtName; 
            isNodeTypeSolution=true;
        }
         /*U-3068 Start*/
        else if(String.isNotBlank(productType) && productType.equalsIgnoreCase(OC_IB_Constants.NodeTypeNodeComponent)){
            productRtId = OC_IB_Constants.stagingNodeTypeNodeComponentRt;
            recordTypeName=OC_IB_Constants.nodeCompRtName;       
        }
        /*U-3068 End*/
        
        for(Object objRec : productObjList){
            Map<String, Object> mapObjRecData = (Map<String, Object>) objRec;
            Map<Sobject,List<String>> mapsSobjToArrayVal = new Map<Sobject,List<String>> ();
            sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,productRtId);
            sObjRec.put(OC_IB_Constants.actualObjSynStatus,OC_IB_Constants.toBeSyncedStatus);
            String SobjName;
            String ReleaseName;
            
            for(integer i=0;i<extFieldList.size();i++){
                String mdtfieldValue =  OC_IB_Constants.stagingObjFieldApiName;
                String fieldApiName =  String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(mdtfieldValue));
                String dataType = String.ValueOf(mapExtFieldToSfFieldmapping.get(extFieldList[i]).get(fieldDataType));
                String fieldValue = String.valueOf(mapObjRecData.get(extFieldList[i]));
                
                if(mapObjRecData.get(extFieldList[i]) != null && mapObjRecData.get(extFieldList[i]) != ' '){
                    
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
                if((extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extsolutionName) && mapObjRecData.get(extFieldList[i])!=null) && isNodeTypeSolution){
                    SobjName=String.valueof(mapObjRecData.get(OC_IB_Constants.extsolutionName)).trim();
                    
                }
                if((extFieldList[i].equalsIgnoreCase(OC_IB_Constants.extnodeComponentName) && mapObjRecData.get(extFieldList[i])!=null) && !isNodeTypeSolution){
                    
                    SobjName=String.valueof(mapObjRecData.get(OC_IB_Constants.extnodeComponentName)).trim();
                }
            }
            sObjRec.put(OC_IB_Constants.stagingObjName,SobjName);
            
            if(isNodeTypeSolution){
                ReleaseName=String.isNotBlank(String.valueOf(sObjRec.get(OC_IB_Constants.stagingSolutionRelname)))?String.valueOf(sObjRec.get(OC_IB_Constants.stagingSolutionRelname)).trim():null;
            }
            else{
                ReleaseName=String.isNotBlank(String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeComponentRelname)))?String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeComponentRelname)).trim():null;
            }
            String extFieldData=SobjName+'+'+(String.isNotBlank(String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeName)))?String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeName)).trim():String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeName)))+
                '+'+(String.isNotBlank(String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeSwRelName)))?String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeSwRelName)).trim():String.valueOf(sObjRec.get(OC_IB_Constants.stagingNodeTypeSwRelName)))+'+'+ReleaseName+'+'+recordTypeName;
            
            sObjRec.put(OC_IB_Constants.stagingPrdRelVerExtkey,extFieldData);
            integSobjNodeTypeSolCmpRecList.add(sObjRec);
        }
        if(integSobjNodeTypeSolCmpRecList!=null && !integSobjNodeTypeSolCmpRecList.isEmpty()){
            integSobjProductRecList.addAll((List<OC_IB_IntegrationSobjectRecords__c>)integSobjNodeTypeSolCmpRecList);   
        }
        if(integSobjProductRecList!=null && !integSobjProductRecList.isEmpty()){
            dmlResultList=database.upsert(integSobjProductRecList,OC_IB_IntegrationSobjectRecords__c.OC_PRD_TechConcatProductRelease__c, false);
            for(integer i=0;i<dmlResultList.size();i++){
                if(!dmlResultList[i].isSuccess()){
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classNTSolutionNComponentHandler,OC_IB_Constants.methodprocessNTSolutionNCompRecords, null, true,null,OC_IB_constants.Sfdc_Ebip_PRD_inApi,null,false,true,true,false,false,null,String.ValueOf(dmlResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                }
            }
        }
        if(integEventLogInsertList!=null && !integEventLogInsertList.isEmpty()){
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
    }
}