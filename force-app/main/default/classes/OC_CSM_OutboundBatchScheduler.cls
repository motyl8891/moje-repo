/* Class Name : OC_CSM_OutboundBatchScheduler
* Description : Scheduler class for running the batch class "Oc_CSM_BATCH_OutboundReqProcessor" 
                to trigger  Ibase outbound api requests to EBIP.
*/
public class OC_CSM_OutboundBatchScheduler implements schedulable{   
    
    public void execute(SchedulableContext sc) {   
        Database.executeBatch(new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi),1000);
    }
  
}