/**
* @File Name  		  : OC_IB_BatchToUpdateExistingAsset 
* @Description 		  : Batch Class to update the existing assets one time as part of new design change for Ibase integration framework
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.1        2021-02-15                 IBM                   Initial Version
**/
global class OC_IB_BatchToUpdateExistingAsset implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT id,Name,OC_IB_Csdp_Id__c,AccountId,OC_IB_ConcatAssetIdSoldToId__c,OC_IB_ConcatAssetIdServiceToId__c,OC_IB_Sold_To_Id__c, '+
            'OC_IB_DecommissionedDate__c,OC_MD_Technology_Standard__c,OC_MD_Release__c,OC_MD_Version__c,Product2Id,OC_IB_DetectionDate__c,OC_IB_SW_Package__c,'+
            'OC_MD_Product_Model__c,OC_MD_Network_Node_Management__c,OC_IB_IsActive__c,OC_MD_Platform__c	 FROM Asset'+
            ' WHERE (OC_IB_ConcatAssetIdSoldToId__c=null AND OC_IB_ConcatAssetIdServiceToId__c!=null) '+
            ' OR (OC_IB_ConcatAssetIdSoldToId__c!=null AND OC_IB_ConcatAssetIdServiceToId__c!=null)';  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> assetRecdList){
        OC_IB_UpdateExistingAssetScriptHandler.updateExistingAsset(assetRecdList);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}