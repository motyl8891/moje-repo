/**
* @File Name          : OC_IB_ArchiveStagingObjectsScheduler
* @Description        : Scheduler class for running the batch class "OC_IB_Batch_ArchiveStagingObjects" 
*                       to delete staging objects.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2105, U-2669
* @Created Date       : 9th March 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-03-09                 IBM                   Initial Version
* 1.1		 2021-04-19					IBM					  Added 'ArchiveSobjectSchedulermethod' to run the schedule class from Developer Console
**/

public class OC_IB_ArchiveStagingObjectsScheduler implements schedulable{
    public void execute(SchedulableContext sc) { 
        
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults(); 
        Integer batchJobSize=Integer.valueof(mc.OC_IB_ArchiveStagingBatchSize__c);
        Database.executebatch(new OC_IB_Batch_ArchiveStagingObjects(),batchJobSize); 
    }  
    public static void ArchiveSobjectSchedulermethod()
    {
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults(); 
        String Cron_Exp= mc.OC_ArchiveStagingObjectCronExp__c;
        OC_IB_ArchiveStagingObjectsScheduler batchJob = new OC_IB_ArchiveStagingObjectsScheduler();
        if(!Test.isRunningTest())
        {
            system.schedule('OC_IB_ArchiveStagingObjectsScheduler', Cron_Exp, batchJob);
        }    
    }
}