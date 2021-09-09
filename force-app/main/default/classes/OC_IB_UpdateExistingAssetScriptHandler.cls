/**
* @File Name          : OC_IB_UpdateExistingAssetScriptHandler
* @Description        : Handler class which gets called from OC_IB_BatchToUpdateExistingAsset batch class to update the existing assert records in produciton
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2104
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-02-15                 IBM                   Initial Version
**/
public class OC_IB_UpdateExistingAssetScriptHandler {
    
    /***************************************************************************************************************
* Method Name:updateExistingAsset
* Param:List<Asset> 
* Description:To update the existing assets available in production as per the Ibase improvement -asset hierarachy design.
* Return:Void
******************************************************************************************************************/
    
    public static void updateExistingAsset(List<Asset> assetRecrdsList){
        String integrationIdentifier=OC_IB_Constants.Sfdc_Ebip_Ibase_InApi;
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
        
        Map<String,String> accountidToSapNumber=new Map<String,String>();
        Map<String,Sobject> soldToInsertSobjectRecrds=new Map<String,Sobject>();
        Map<String,Sobject> soldToUpsertSobjectRecrds=new Map<String,Sobject>();
        
        List<Asset> soldToAssetinsertList=new List<Asset>();
        List<Asset> soldToAssetUpsertList=new List<Asset>();
        
        List<Asset> servAssetRecrds=new List<Asset>();
        List<Asset> updateSerAssetRecrdsList=new List<Asset>();
        Map<String,String> serviceToSoldtoMap=New Map<String,String>();
        Map<String,String> servToSoldId=new Map<String,String>();
        
        try{
            List<Account> getExistingAccountNumbers=[select id,SAP_S2P_ID_Number__c,parent.SAP_S2P_ID_Number__c,parentid from account];
            for(Account acc:getExistingAccountNumbers){
                accountidToSapNumber.put(acc.id,String.valueof(acc.SAP_S2P_ID_Number__c));
                if(acc.ParentId!=null){
                    servToSoldId.put(acc.id,acc.ParentId);
                }
            }
            
            for(Asset asRec:assetRecrdsList){
                Sobject clonedRec= asRec.Clone();
                String concatSoldtoKey='';
                String assetAccountid='';
                if(String.isNotBlank(asRec.OC_IB_Sold_To_Id__c)){
                    assetAccountid=asRec.OC_IB_Sold_To_Id__c;
                    concatSoldtoKey=asRec.OC_IB_Csdp_Id__c+'+'+accountidToSapNumber.get(asRec.OC_IB_Sold_To_Id__c);
                }
                else{
                    assetAccountid=servToSoldId.get(asRec.AccountId); 
                    concatSoldtoKey=asRec.OC_IB_Csdp_Id__c+'+'+accountidToSapNumber.get(assetAccountid);
                }
                if(String.isNotBlank(asRec.OC_IB_ConcatAssetIdServiceToId__c) && String.isBlank(asRec.OC_IB_ConcatAssetIdSoldToId__c)){
                    clonedRec.put('OC_IB_ConcatAssetIdSoldToId__c',concatSoldtoKey);
                    clonedRec.put('OC_IB_ConcatAssetIdServiceToId__c','');
                    clonedRec.put('AccountId',assetAccountid);
                    soldToUpsertSobjectRecrds.put(concatSoldtoKey,clonedRec);
                    servAssetRecrds.add(asRec);
                }
                else if(String.isNotBlank(asRec.OC_IB_ConcatAssetIdServiceToId__c) && String.isNotBlank(asRec.OC_IB_ConcatAssetIdSoldToId__c)){
                    clonedRec.put('OC_IB_ConcatAssetIdSoldToId__c',concatSoldtoKey);
                    clonedRec.put('OC_IB_ConcatAssetIdServiceToId__c','');
                    clonedRec.put('AccountId',AssetAccountid);
                    soldToInsertSobjectRecrds.put(concatSoldtoKey,clonedRec); //since both concat fields will be having values we cant upsert here because it will update the exsiting one.
                    servAssetRecrds.add(asRec);
                }
            }
            
            soldToAssetinsertList.addAll((List<Asset>)soldToInsertSobjectRecrds.values());
            soldToAssetUpsertList.addAll((List<Asset>)soldToUpsertSobjectRecrds.values());
            database.saveResult[] dmlsoldtoInsertList;
            database.UpsertResult[] dmlsoldtoUpsertList;
            
            Map<String,String> soldToIdafterInsert=new Map<String,String>();
            if(!soldToAssetinsertList.isEmpty()){
                dmlsoldtoInsertList=database.insert(soldToAssetinsertList,false);
                for(integer i=0;i<dmlsoldtoInsertList.size();i++){
                    if(dmlsoldtoInsertList[i].isSuccess()){
                        soldToIdafterInsert.put(soldToAssetinsertList[i].OC_IB_Csdp_Id__c,soldToAssetinsertList[i].id); 
                    }
                    else{
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,'OC_IB_UpdateExistingAssetScriptHandler', 'updateExistingAsset', null, true,null,integrationIdentifier,null,false,false,false,true,false,'',String.ValueOf(dmlsoldtoInsertList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+'SoldToRecrdsFailed'+':'+'CSDP Id'+soldToAssetinsertList[i].OC_IB_Csdp_Id__c,false,null,null));
                    }
                }
            }
            if(!soldToAssetUpsertList.isEmpty()){
                dmlsoldtoUpsertList=database.upsert(soldToAssetUpsertList,Asset.OC_IB_ConcatAssetIdSoldToId__c,false);
                for(integer i=0;i<dmlsoldtoUpsertList.size();i++){
                    if(dmlsoldtoUpsertList[i].isSuccess()){
                        soldToIdafterInsert.put(soldToAssetUpsertList[i].OC_IB_Csdp_Id__c,soldToAssetUpsertList[i].id); 
                    }
                    else{
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,'OC_IB_UpdateExistingAssetScriptHandler', 'updateExistingAsset', null, true,null,integrationIdentifier,null,false,false,false,true,false,'',String.ValueOf(dmlsoldtoUpsertList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+'SoldToRecrdsFailed'+':'+'CSDP Id'+soldToAssetUpsertList[i].OC_IB_Csdp_Id__c,false,null,null));
                    }
                }
            }
            for(Asset asServRecs:servAssetRecrds){
                if(soldToIdafterInsert!=null && !soldToIdafterInsert.isEmpty() && soldToIdafterInsert.containskey(asServRecs.OC_IB_Csdp_Id__c)){
                    asServRecs.parentId= soldToIdafterInsert.get(asServRecs.OC_IB_Csdp_Id__c);
                    asServRecs.Status='In Scope';
                    asServRecs.OC_IB_ConcatAssetIdSoldToId__c='';
                    updateSerAssetRecrdsList.add(asServRecs);
                }
            }
            
            database.UpsertResult[] dmlAssetUpsertList;
            if(!updateSerAssetRecrdsList.isEmpty()){
                dmlAssetUpsertList=Database.upsert(updateSerAssetRecrdsList,Asset.OC_IB_ConcatAssetIdServiceToId__c,False);        
                for(integer i=0;i<dmlAssetUpsertList.size();i++){
                    if(!dmlAssetUpsertList[i].isSuccess()){
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,'OC_IB_UpdateExistingAssetScriptHandler', 'updateExistingAsset', null, true,null,integrationIdentifier,null,false,false,false,true,false,'',String.ValueOf(dmlAssetUpsertList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));                      
                    }
                }
            }
        }catch(exception ex){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,'OC_IB_UpdateExistingAssetScriptHandler', 'updateExistingAsset', null, true,ex,integrationIdentifier,null,false,false,false,true,false,null,null,false,null,null));
        }
        if(!integEventLogInsertList.isEmpty()){
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
        
    }
    
}