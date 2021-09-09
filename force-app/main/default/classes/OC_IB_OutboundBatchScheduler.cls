/* Class Name : OC_IB_OutboundBatchScheduler
* Description : Scheduler class for running the batch class "OC_IB_BATCH_OutboundReqProcessor" 
                to trigger  Ibase outbound api requests to EBIP.
*/
public class OC_IB_OutboundBatchScheduler implements schedulable{   
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new OC_IB_BATCH_OutboundReqProcessor(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi),1000);
    }
}