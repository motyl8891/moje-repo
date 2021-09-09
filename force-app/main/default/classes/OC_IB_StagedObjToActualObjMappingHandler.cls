/**
* @File Name          : OC_IB_StagedObjToActualObjMappingHandler
* @Description        : Handler class for OC_IB_BATCH_StagedDataProcessor - migrates the integration data from Staging object to Actual object.
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
public class OC_IB_StagedObjToActualObjMappingHandler {
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    Public Static String errorStagingRecordId;
    Public Static OC_IB_IntegrationSobjectRecords__c errorStagingrecord;
    
    /**************************************************************************************************
* @Method Name : copyDataFromStagingObjToActualObj
* @Description : upserts the staging object records into actual object. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing 
****************************************************************************************************/
    Public Static Void copyDataFromStagingObjToActualObj(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
        try{
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
                CopyAssetDataFromStagingToActualObject(integrationIdentifier,stagedRecList);
            }
        }Catch(Exception excp){
            
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classStagedObjToActualObjMappingHandler, OC_IB_Constants.methodCopyDataFromStagingObjToActualObj, null, true,excp,integrationIdentifier,null,false,false,false,true,false,errorStagingRecordId,null,false,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            if(errorStagingrecord!=null){
                errorStagingrecord.OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncErrorStatus;
                database.update(errorStagingrecord);
            }
        }    
    }
    /**************************************************************************************************
* @Method Name : copyDataFromStagingObjToActualObj
* @Description : upserts the staging object records into actual object. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing 
****************************************************************************************************/
    Public Static Void CopyAssetDataFromStagingToActualObject(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
        List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList;
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapActualobjFieldToMdtRec = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        String objectName;
        Map<String,Id> mapStagingFieldValueToSfId = new Map<String,Id> ();
        Boolean mapStagingFieldValueToSfIdNotEmpty;
        Map<String,Sobject> mapSoldToIdExtKeyToUpsertAssetRec = new Map<String,Sobject> ();
        Map<String,Sobject> mapServToIdExtKeyToUpsertAssetRec = new Map<String,Sobject> ();
        List<Asset> assetRecSoldToIdList = new List<Asset> (); 
        List<Asset> assetRecServToIdList = new List<Asset> ();
        Database.UpsertResult[] dmlServToIdResultList; 
        Database.UpsertResult[] dmlSoldToIdResultList;
        Map<String,OC_IB_IntegrationSobjectRecords__c> mapExtKeyToStagingRec  = new Map<String,OC_IB_IntegrationSobjectRecords__c> ();
        Set<String> csdpIds = new Set<String>();
        List<Asset> assetServToPartyUpsertList=new List<Asset>();
        Map<String,String> soldToCsdpRecId=New Map<String,String>();
        
        inboundFieldMappingMdtRecordList = OC_IB_Utility.getInboundIntegrationFieldMappingMdtRecords(integrationIdentifier);
        if(inboundFieldMappingMdtRecordList!=null && !inboundFieldMappingMdtRecordList.isEmpty()){
            mapActualobjFieldToMdtRec = OC_IB_Utility.getActualobjFieldToMdtRecMapping (inboundFieldMappingMdtRecordList);
            objectName = inboundFieldMappingMdtRecordList[0].OC_IB_SfdcObjectApiName__c;
            mapStagingFieldValueToSfId = OC_IB_Utility.getLookupRecordToId(integrationIdentifier,stagedRecList,mapActualobjFieldToMdtRec);
            mapStagingFieldValueToSfIdNotEmpty =  (mapStagingFieldValueToSfId!=null && !mapStagingFieldValueToSfId.isEmpty() ) ? true : false;
            Id nodeTypeRtId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.assetNodeTypeRT).getRecordTypeId();
            for(OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList){
                errorStagingRecordId = stagedRec.Id;
                errorStagingrecord = stagedRec;
                sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                sObjRec.Put(OC_IB_Constants.sobjrecordTypeId,nodeTypeRtId);
                for(String FieldName : mapActualobjFieldToMdtRec.Keyset()){
                    OC_IB_InboundIntegrationFieldMapping__mdt mdtRec = mapActualobjFieldToMdtRec.get(FieldName);
                    if(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c) != null){
                        sObjRec = OC_IB_Utility.DataMapping(mdtRec,sObjRec,FieldName,stagedRec,mapStagingFieldValueToSfIdNotEmpty,mapStagingFieldValueToSfId);
                    }else {
                        sObjRec.Put(FieldName,null);    
                    }
                    //U-2484 changes
                    if(sObjRec.get(OC_IB_Constants.assetExtKeySoldToId) != null && sObjRec.get(OC_IB_Constants.assetExtKeyServToId) == null){
                        sObjRec.put(OC_IB_Constants.AccountId,sObjRec.get(OC_IB_Constants.assetFieldSoldToId));
                        mapSoldToIdExtKeyToUpsertAssetRec.put(String.ValueOf(sObjRec.get(OC_IB_Constants.assetExtKeySoldToId)),sObjRec);
                        mapExtKeyToStagingRec.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagingExtKeySoldToId)),stagedRec);
                        
                    }
                    if(sObjRec.get(OC_IB_Constants.assetExtKeySoldToId) == null && sObjRec.get(OC_IB_Constants.assetExtKeyServToId)!= null){
                        mapServToIdExtKeyToUpsertAssetRec.put(String.ValueOf(sObjRec.get(OC_IB_Constants.assetExtKeyServToId)),sObjRec);
                        csdpIds.add(String.valueof(sObjRec.get(OC_IB_Constants.assetCsdpId)));
                        mapExtKeyToStagingRec.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagingExtKeyServToId)),stagedRec);
                        
                    }
                } 
                
            }
            if(!mapSoldToIdExtKeyToUpsertAssetRec.isEmpty() && mapSoldToIdExtKeyToUpsertAssetRec!=null){
                assetRecSoldToIdList.addAll((List<Asset>)mapSoldToIdExtKeyToUpsertAssetRec.values());  
            }
          
            Map<String,String> getExistingsoldtoids= getExistingSoldToAssets(csdpIds);
            if(!assetRecSoldToIdList.isEmpty()){
                dmlSoldToIdResultList = database.Upsert(assetRecSoldToIdList,Asset.OC_IB_ConcatAssetIdSoldToId__c,false);
                for(integer i=0;i<dmlSoldToIdResultList.size();i++){
                    if(dmlSoldToIdResultList[i].isSuccess()){
                        mapExtKeyToStagingRec.get(assetRecSoldToIdList[i].OC_IB_ConcatAssetIdSoldToId__c).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.SyncAssetCreateSuccess;
                    }else{
                        Id errorStagingRecId = mapExtKeyToStagingRec.get(assetRecSoldToIdList[i].OC_IB_ConcatAssetIdSoldToId__c).id;
                        mapExtKeyToStagingRec.get(assetRecSoldToIdList[i].OC_IB_ConcatAssetIdSoldToId__c).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncErrorStatus;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classStagedObjToActualObjMappingHandler, OC_IB_Constants.methodCopyAssetDataFromStagingToActualObject, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlSoldToIdResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                    }
                }
            }
            errorStagingRecordId = '';
            if(!mapServToIdExtKeyToUpsertAssetRec.isEmpty() && mapServToIdExtKeyToUpsertAssetRec!=null){
                assetRecServToIdList.addAll((List<Asset>)mapServToIdExtKeyToUpsertAssetRec.values());
                for(Asset assetSTPrecrds:assetRecServToIdList){
                  
                   if(!getExistingsoldtoids.isEmpty() && getExistingsoldtoids.containskey(assetSTPrecrds.OC_IB_Csdp_Id__c)){
                        assetSTPrecrds.ParentId=getExistingsoldtoids.get(assetSTPrecrds.OC_IB_Csdp_Id__c);
                        assetSTPrecrds.Status=OC_IB_Constants.assetStatusInScope;              
                        assetServToPartyUpsertList.add(assetSTPrecrds);   
                    }
                    else{
                        assetServToPartyUpsertList.add(assetSTPrecrds);   
                    }
                }
            }
            
            if(!assetServToPartyUpsertList.isEmpty()){
                dmlServToIdResultList = database.Upsert(assetServToPartyUpsertList,Asset.OC_IB_ConcatAssetIdServiceToId__c,false);
                for(integer i=0;i<dmlServToIdResultList.size();i++){
                    if(dmlServToIdResultList[i].isSuccess()){
                        mapExtKeyToStagingRec.get(assetServToPartyUpsertList[i].OC_IB_ConcatAssetIdServiceToId__c).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.SyncAssetCreateSuccess;
                    }else{
                        Id errorStagingRecId = mapExtKeyToStagingRec.get(assetServToPartyUpsertList[i].OC_IB_ConcatAssetIdServiceToId__c).id;
                        mapExtKeyToStagingRec.get(assetServToPartyUpsertList[i].OC_IB_ConcatAssetIdServiceToId__c).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncErrorStatus;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classStagedObjToActualObjMappingHandler, OC_IB_Constants.methodCopyAssetDataFromStagingToActualObject, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlServToIdResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                    }
                }
                
            }
            
            if(!integEventLogInsertList.isEmpty()){
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
            database.update(mapExtKeyToStagingRec.Values());
        }
    }
    /**************************************************************************************************
* @Method Name : getExistingSoldToAssets
* @Description : Queries the asset records whose associated account type is sales.
* @Param       : searchAssetByExternalKey - Set of externalkeys to query associated assets.
* @Return      : Map<String,String> - Key: CsdpId,Value:SoldToAsset Id
****************************************************************************************************/
    public static Map<String,String> getExistingSoldToAssets(Set<String> csdpsIds){
        Map<String,String> cspdidstoAssetIds=new Map<String,String>();
        for(Asset asRec:[Select id,name,OC_IB_Csdp_Id__c from Asset where OC_IB_Csdp_Id__c in:csdpsIds and OC_IB_ConcatAssetIdSoldToId__c!=null ]){
            cspdidstoAssetIds.put(asRec.OC_IB_Csdp_Id__c,asRec.id);   
        }
        return cspdidstoAssetIds;
        
    }
    
}