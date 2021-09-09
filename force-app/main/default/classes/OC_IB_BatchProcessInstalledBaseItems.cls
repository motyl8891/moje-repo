/* Class Name : OC_IB_BatchProcessInstalledBaseItems
 * Description :  Batch class which queries the integration staging object records with OC_IB_ActualObjectSyncStatus__c = 'Asset sync success' Or 'Partial sync success'
 *                and calls the handler class OC_IB_InsatlledBaseItemsHandler to create installed base items 
 *               
*/
Global class OC_IB_BatchProcessInstalledBaseItems implements Database.Batchable <Sobject> {
     Public String integrationIdentifier;

     public OC_IB_BatchProcessInstalledBaseItems (String identifier){
        integrationIdentifier = identifier;
    }
    Global Database.Querylocator start(Database.BatchableContext bc) {
        String soqlStr;
        List<String> syncStatusType=new List<String>{OC_IB_constants.SyncAssetCreateSuccess,OC_IB_constants.syncPartialStatus};
        system.debug('syncStatusType==>'+syncStatusType);
        soqlStr = OC_IB_Utility.generateSOQLFromMdtRecord(integrationIdentifier,false,null);
        soqlStr = soqlStr + ' WHERE OC_IB_ActualObjectSyncStatus__c IN:syncStatusType'+' AND '+'RecordType.DeveloperName='+'\''+OC_IB_Constants.assetRecType+'\'';

        system.debug('soqlStr is==>'+soqlStr);
        return Database.getQueryLocator(soqlStr);

    }
    Global Void execute(Database.BatchableContext bc, List<Sobject> sObjrecordsList) {
        system.debug('sObjrecordsList==>'+sObjrecordsList);
        if(sObjrecordsList!=null && !sObjrecordsList.isEmpty()){
            OC_IB_InstalledBaseItemsHandler.ProcessinstalledBaseItems(sObjrecordsList);
        }
    }
    Global void finish(Database.BatchableContext bc) {
    }
    
}