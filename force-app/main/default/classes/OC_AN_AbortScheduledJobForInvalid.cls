/**
 * @File Name          : OC_AN_AbortScheduledJobForInvalid
 * @Description        : Abort the scheduled Job when bulletin is marked as invalid 
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 7th Jun 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-06-07                 IBM                   Initial Version
 **/
public class OC_AN_AbortScheduledJobForInvalid{
    @InvocableMethod
     public static void deleteScheduled(List<Id> bulletinId){
         Map<String,id> bulletinofId =new Map<String,Id>();
         string JobName = OC_AN_Constants.JOB_NAME_EXTERNAL;
         for(Id idofBulletin :bulletinId){
             bulletinofId.put(JobName+idofBulletin,idofBulletin);
        }
        
        for (CronTrigger job:[SELECT Id FROM CronTrigger where CronJobDetail.Name IN:bulletinofId.keySet()])  {
            System.abortJob(job.Id);
        }
     }
}