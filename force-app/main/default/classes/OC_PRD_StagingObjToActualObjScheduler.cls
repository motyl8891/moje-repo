/*@File Name 		  : OC_PRD_StagingObjToActualObjScheduler
* @Description 		  : Scheduler class for running the batch class "OC_IB_BATCH_StagedDataProcessor" 
                        to migrate Product data from staging object to Product object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 20th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                 IBM                   U-2818 Initial Version
*/

global class OC_PRD_StagingObjToActualObjScheduler implements schedulable{
 global void execute(SchedulableContext sc) { 
		 OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        integer batchJobSize=Integer.valueof(mc.OC_PRD_StagingObjToProductObjBatchSize__c); 
        Database.executebatch(new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_PRD_inApi),batchJobSize);
    }
}