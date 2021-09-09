/* Class Name :   OC_IB_BATCH_ServToAssetStagedProcessor
 * Description :  Batch class which queries the integration staging object records with OC_IB_ActualObjectSyncStatus__c != 'syncsuccess'
 *                and called from OC_IB_BATCH_StagedDataProcessor which calls the handler class OC_IB_StagedObjToActualObjMappingHandler to upsert the staging records 
 *                into actual object records. 
 * * * @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-02-17                 IBM                   Initial Version
 *               
*/
public class OC_IB_BATCH_ServToAssetStagedProcessor implements Database.Batchable<sObject> {
    Public String integrationIdentifier;
    public OC_IB_BATCH_ServToAssetStagedProcessor (String identifier){
        integrationIdentifier = identifier;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> syncStatusType=new List<String>{OC_IB_constants.toBeSyncedStatus,OC_IB_constants.syncErrorStatus};

        String soqlStr = OC_IB_Utility.generateSOQLFromMdtRecord(integrationIdentifier,false,null);
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
            soqlStr = soqlStr + ' WHERE OC_IB_ActualObjectSyncStatus__c IN:syncStatusType'+' AND '+'RecordType.DeveloperName='+'\''+OC_IB_Constants.assetRecType+'\'';
            soqlStr= soqlStr + ' AND OC_IB_Asset_ConcatAssetIdServiceToId__c!=null';  
           }
        return Database.getQueryLocator(soqlStr); 
    } 
    public void execute(Database.BatchableContext BC, List<OC_IB_IntegrationSobjectRecords__c> stagedRecList) {
       OC_IB_StagedObjToActualObjMappingHandler.copyDataFromStagingObjToActualObj(integrationIdentifier,stagedRecList);
    }   
    
    public void finish(Database.BatchableContext BC) {


    }
    
}