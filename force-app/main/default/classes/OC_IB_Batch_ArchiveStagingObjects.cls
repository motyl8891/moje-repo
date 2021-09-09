/**
* @File Name          : OC_IB_Batch_ArchiveStagingObjects
* @Description        : Batch class which queries the integration staging object records with OC_IB_ActualObjectSyncStatus__c = 'sync success'
*                      and last modified date not in last two months and remove those records from system.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2105, U-2669
* @Created Date       : 9th March 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-03-09                 IBM                   Initial Version
**/

global class OC_IB_Batch_ArchiveStagingObjects implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<String> syncStatusType=new List<String>{OC_IB_constants.syncSuccessStatus};
        String noOfmonths= Label.OC_IB_No_Of_Months;
        String query= 'SELECT id, name, OC_IB_Asset_Csdp_Id__c, OC_IB_ActualObjectSyncStatus__c, LastModifiedDate from OC_IB_IntegrationSobjectRecords__c where OC_IB_ActualObjectSyncStatus__c IN:syncStatusType and LastModifiedDate < LAST_N_MONTHS:'+ noOfmonths; 
      	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> stagedRecList)
    {
        String ClassName = OC_IB_Constants.classArchiveStagingObjects;
        String MethodName = OC_IB_Constants.methodExecute;
        String Operation = OC_IB_Constants.deleteOps;
        OC_Utility.DMLhandler(stagedRecList,ClassName,MethodName,Operation);  
    }
    
    global void finish(Database.BatchableContext BC){
    }
}