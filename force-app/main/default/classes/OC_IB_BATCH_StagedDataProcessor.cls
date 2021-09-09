/**
* @File Name          : OC_IB_BATCH_StagedDataProcessor
* @Description        : Batch class which queries the integration staging object records with OC_IB_ActualObjectSyncStatus__c != 'syncsuccess'
*                      and calls the handler class OC_IB_StagedObjToActualObjMappingHandler to upsert the staging records 
*                      into actual object records.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-17                 IBM                   U-2818 Update  Version

**/
public class OC_IB_BATCH_StagedDataProcessor implements Database.Batchable<sObject> {
    Public String integrationIdentifier;
    Public Map<String,OC_IB_IntegrationSobjectRecords__c> mapExtKeyToStagingRec  = new Map<String,OC_IB_IntegrationSobjectRecords__c> ();
    public OC_IB_BATCH_StagedDataProcessor (String identifier){
        integrationIdentifier = identifier;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> syncStatusType=new List<String>{OC_IB_constants.toBeSyncedStatus,OC_IB_constants.syncErrorStatus};
            
            String soqlStr = OC_IB_Utility.generateSOQLFromMdtRecord(integrationIdentifier,false,null);
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
            soqlStr = soqlStr + ' WHERE OC_IB_ActualObjectSyncStatus__c IN:syncStatusType'+' AND '+'RecordType.DeveloperName='+'\''+OC_IB_Constants.assetRecType+'\'';
            soqlStr= soqlStr + ' AND OC_IB_Asset_ConcatAssetIdSoldToId__c!=null';
            
        }
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_InApi)){
            
            soqlStr = soqlStr + ' WHERE OC_IB_ActualObjectSyncStatus__c !='+'\''+OC_IB_Constants.syncSuccessStatus+'\''+' AND '+'RecordType.DeveloperName='+'\''+OC_IB_Constants.stagingObjContractRt+'\'';
            
        }
        /*U-3065: Added for Contract sapOrder*/
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CC_inApi)){
            
            soqlStr = soqlStr + ' WHERE OC_IB_ActualObjectSyncStatus__c !='+'\''+OC_IB_Constants.syncSuccessStatus+'\''+' AND '+'RecordType.DeveloperName='+'\''+OC_IB_Constants.contractSapOrder+'\'';
            
        }
        //U-2818 Product MR Changes Start
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_inApi)){
            // U-3067 Start
            List<String> lstPrdRecTypeName = OC_IB_Constants.lstPRDRecType;
            soqlStr = soqlStr + ' WHERE  OC_IB_ActualObjectSyncStatus__c !='+'\''+OC_IB_Constants.syncSuccessStatus+'\''+' AND '+'RecordType.DeveloperName IN :lstPrdRecTypeName ';
            soqlStr= soqlStr + 'AND (NOT OC_PRD_TechConcatProductRelease__c LIKE'+'\''+OC_IB_Constants.stagingObjNameNull+'\')';
        	   
        }
        else if (integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_NtSolnComp_InApi)) {
            	List<String> lstPrdNodeTypeSolnCompRecTypeName = OC_IB_Constants.lstPRDNodeTypeSolnCompRecType;
            	soqlStr = soqlStr +' WHERE  OC_IB_ActualObjectSyncStatus__c !='+'\''+OC_IB_Constants.syncSuccessStatus+'\''+' AND '+'RecordType.DeveloperName IN :lstPrdNodeTypeSolnCompRecTypeName '+' AND '+'OC_PRD_TechConcatProductRelease__c!=null';
        }
        // U-3067 END
        //U-2818 Product MR Changes End
        return Database.getQueryLocator(soqlStr); 
    } 
    public void execute(Database.BatchableContext BC, List<OC_IB_IntegrationSobjectRecords__c> stagedRecList) {
        
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
            OC_IB_StagedObjToActualObjMappingHandler.copyDataFromStagingObjToActualObj(integrationIdentifier,stagedRecList);
        }
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_InApi)){
            OC_CSM_StagedObjToActualObjMapingHandler.copyDataFromStagingObjToActualObj(integrationIdentifier,stagedRecList);
        }
        /*U-3065: Added for Contract sapOrder*/
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CC_inApi) && !stagedRecList.isEmpty()){
            OC_CSM_StagedObjToActualObjMapingHandler.CopyContractSapOrderFromStagingToActualObj(integrationIdentifier,stagedRecList);
        }
        //U-2818 Product MR Changes Start // U-3067 Start
        else if( (integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_inApi) || integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_NtSolnComp_InApi) ) && !stagedRecList.isEmpty()){
            OC_PRD_StagedObjToActualObjMapingHandler.copyDataFromStagingObjToActualObj(integrationIdentifier, stagedRecList);
        } 
    }   //U-2818 Product MR Changes END // U-3067 END
    
    public void finish(Database.BatchableContext BC) {
        
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
            OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
            integer batchJobSize=Integer.valueof(mc.OC_IBStagingObjToAssetObjBatchSize__c);
            Database.executebatch(new OC_IB_BATCH_ServToAssetStagedProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi),batchJobSize);
        }
         //U-3065: Added for Contract sapOrder
         else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_InApi)){
             OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
             integer batchJobSize=Integer.valueof(mc.OC_CSM_StagingObjToCCObjBatchSize__c);
             Database.executebatch(new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_CC_inApi),batchJobSize);
        }
    }
    
    
}