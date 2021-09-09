/*@File Name          : OC_PRD_NodeSolnStagingToActualScheduler
* @Description        : Scheduler class for running the batch class "OC_IB_BATCH_StagedDataProcessor"
                        to migrate Node Type Solution data from staging object to Product Relations object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2109
* @Created Date       : 13th july 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                 IBM                   U- 3067 Initial Version
* 2.0        2021-05-20                 IBM                   U- 3069 Initial Version
*/
global class OC_PRD_NodeSolnStagingToActualScheduler implements schedulable{
    global void execute(SchedulableContext sc) {
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
       integer batchJobSize=Integer.valueof(mc.OC_PRD_StagingObjToProductObjBatchSize__c);
       Database.executebatch(new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_PRD_NtSolnComp_InApi),batchJobSize);
   }
}