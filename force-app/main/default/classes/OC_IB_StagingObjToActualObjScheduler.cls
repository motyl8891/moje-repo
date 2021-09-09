/**
* @File Name          : OC_IB_StagingObjToActualObjScheduler
* @Description        : Scheduler class for running the batch class "OC_IB_BATCH_StagedDataProcessor" 
*                       to migrate Ibase data from staging object to Asset object.
* @Author             : IBM 
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.0        2021-02-15                 IBM                   Updated Version
**/
public class OC_IB_StagingObjToActualObjScheduler implements schedulable{ 
    
    public void execute(SchedulableContext sc) { 
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        integer batchJobSize=Integer.valueof(mc.OC_IBStagingObjToAssetObjBatchSize__c);
        Database.executebatch(new OC_IB_BATCH_StagedDataProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi),batchJobSize);
    }   
    
}