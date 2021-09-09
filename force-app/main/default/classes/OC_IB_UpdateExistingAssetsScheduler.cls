/**
* @File Name          : OC_IB_UpdateExistingAssetsScheduler
* @Description        : Scheduler class for running the batch class "OC_IB_BatchToUpdateExistingAsset" 
                        to Update the existing assets as per Ib improvements design -> Asset hierarchy
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2103
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-02-15                 IBM                   Initial Version
**/
public class OC_IB_UpdateExistingAssetsScheduler implements schedulable{
    public void execute(SchedulableContext sc) { 
        Database.executebatch(new OC_IB_BatchToUpdateExistingAsset(),1000);
    }   
}