/*@File Name : OC_CSM_StagingObjToActualObjScheduler
* @Description : Scheduler class for running the batch class "OC_CSM_StagingObjToActualObjScheduler" 
                to migrate Contract data from staging object to ServiceContract object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.0        2021-04-09                 IBM                   U-2676/U-2675 Contract ResponseProfile/Account Update Changes
**/
public class OC_CSM_StagingObjToActualObjScheduler implements schedulable{
 public void execute(SchedulableContext sc) { 
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        integer batchJobSize=Integer.valueof(mc.OC_CSM_StagingObjToContractObjBatchSize__c);
        Database.executebatch(new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_CSM_inApi),batchJobSize);
    }
}